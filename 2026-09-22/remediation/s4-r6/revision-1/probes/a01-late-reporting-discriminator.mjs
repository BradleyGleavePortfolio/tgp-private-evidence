// S4 R6 — S4-R5-A-01 late-reporting discriminator (root-parameterised).
//
// Derived from reviewer A's frozen `preflight-notification-boundary-probe.mjs`
// (2026-09-21/audits/s4-r5/a/revision-1): same observation code (actual
// candidate modules imported through the repository's own Chrome mock, synthetic
// HTTP/storage boundaries only, no network, no child process, no test framework),
// generalised to take the source root as an argument and to render a verdict
// per `--expect fixed|defect`.
//
// Schedule per (entrypoint, offset): cold OLD refresh state; accept Start; hold
// the OLD refresh response; dispatch replacement B whose storage persist is
// parked; answer OLD's refresh 401; release B's persist after `offset` microtask
// turns; let everything settle. Recorded per case: every auth_required emission
// with the session generation AT EMISSION TIME and whether B's acknowledgement
// continuation had already run.
//
// Verdict:
//   --expect defect : PASS (exit 0) iff at least one case emitted auth_required
//                     while B (generation != OLD) was current — predecessor.
//   --expect fixed  : PASS (exit 0) iff ZERO such cases AND the controls hold:
//                     (a) offsets where OLD is still current at the report emit
//                         exactly one auth_required with "login required to
//                         import" (genuine OLD failure stays visible), and
//                     (b) offsets where B is current at the report end with the
//                         replaced detail, no auth_required, B's refresh token
//                         still stored, hasSession true.
//   Any harness error / budget overrun → exit 2.
//
// Usage: node a01-late-reporting-discriminator.mjs <source-root> --expect fixed|defect [--max-offset N]
import { pathToFileURL } from "node:url";
import { resolve } from "node:path";

const args = process.argv.slice(2);
const root = resolve(args[0] ?? "");
const expectIdx = args.indexOf("--expect");
const expectation = expectIdx >= 0 ? args[expectIdx + 1] : null;
const maxIdx = args.indexOf("--max-offset");
const maxOffset = maxIdx >= 0 ? Number(args[maxIdx + 1]) : 40;
if (!root || !["fixed", "defect"].includes(expectation ?? "")) {
  console.error("usage: <source-root> --expect fixed|defect [--max-offset N]");
  process.exit(2);
}

const LOGIN_REQUIRED = "login required to import";
const REPLACED_DETAIL =
  "import stopped — your TGP session changed during the import. Start the import again.";
const key = "tgp_refresh_token";

const { makeBgMock } = await import(
  pathToFileURL(root + "/test/helpers/background-mock.js")
);
const mock = makeBgMock();
const started = new Date().toISOString();
const began = performance.now();
globalThis.chrome = mock.chrome;
await import(pathToFileURL(root + "/background.js"));
const session = await import(pathToFileURL(root + "/shared/session.js"));
const area = mock.chrome.storage.session;
const originalSet = area.set;
const defer = () => {
  let resolve;
  const promise = new Promise((r) => (resolve = r));
  return { promise, resolve };
};
const flush = async (n = 100) => {
  for (let i = 0; i < n; i++) await Promise.resolve();
};
let captures = [];
let acknowledged = false;
const originalSend = mock.chrome.runtime.sendMessage;
mock.chrome.runtime.sendMessage = (msg) => {
  captures.push({
    kind: msg.kind,
    error: msg.lastError ?? null,
    generation: session.getSessionGeneration(),
    acknowledged,
  });
  return originalSend(msg);
};
const watchdog = setTimeout(() => {
  console.error("PROBE_BUDGET_EXCEEDED");
  process.exit(2);
}, 30000);

const results = [];
const failures = [];
let exitCode = 2;
try {
  for (const kind of ["start_import", "start_ingest"]) {
    for (let delay = 0; delay <= maxOffset; delay++) {
      area.set = originalSet;
      await session.clearTokens();
      await flush();
      mock.sessionMap.set(key, "OLD_R");
      mock.sent.length = 0;
      captures = [];
      acknowledged = false;
      const response = defer();
      const persist = defer();
      let fetches = 0;
      let entered = false;
      globalThis.fetch = async (url) => {
        if (!url.endsWith("/refresh")) throw Error("unexpected request " + url);
        fetches++;
        return response.promise;
      };
      area.set = async (obj) => {
        entered = true;
        await persist.promise;
        return originalSet(obj);
      };
      const oldGeneration = session.getSessionGeneration();
      const startAck = await mock.dispatch({
        kind,
        url: "https://app.truecoach.co/clients",
        tabId: 42,
      });
      await flush();
      if (fetches !== 1) throw Error("refresh not admitted");
      const pairing = mock
        .dispatch({
          kind: "session_established",
          accessToken: "NEW_A",
          refreshToken: "NEW_R",
        })
        .then((r) => {
          acknowledged = true;
          return r;
        });
      await flush();
      if (!entered) throw Error("replacement not parked");
      response.resolve(new Response(null, { status: 401 }));
      await flush(delay);
      persist.resolve();
      const replacementAck = await pairing;
      await flush();
      const authEvents = captures.filter((c) => c.kind === "auth_required");
      const snapshots = captures.filter((c) => c.kind === "status_snapshot");
      const terminal = mock.sent
        .filter((m) => m.kind === "status_snapshot")
        .at(-1);
      const sessionState = await mock.dispatch({
        kind: "request_session_state",
      });
      results.push({
        kind,
        delay,
        oldGeneration,
        newGeneration: session.getSessionGeneration(),
        startAck,
        replacementAck,
        fetches,
        authEvents,
        // generation observed when the terminal snapshot was emitted
        terminalSnapshotGeneration: snapshots.at(-1)?.generation ?? null,
        terminal: terminal
          ? { lastError: terminal.lastError, intent: terminal.intent }
          : null,
        sessionState,
        stored: mock.sessionMap.get(key),
      });
    }
  }

  // Classification.
  const staleAuth = results.filter((r) =>
    r.authEvents.some((e) => e.generation !== r.oldGeneration),
  );
  const acknowledgedStale = staleAuth.filter((r) =>
    r.authEvents.some((e) => e.acknowledged),
  );
  // Control (a): OLD still current at the terminal report → genuine failure visible.
  const oldCurrentAtReport = results.filter(
    (r) => r.terminalSnapshotGeneration === r.oldGeneration,
  );
  for (const r of oldCurrentAtReport) {
    const ok =
      r.authEvents.length === 1 &&
      r.authEvents[0].generation === r.oldGeneration &&
      r.terminal?.lastError === LOGIN_REQUIRED;
    if (!ok)
      failures.push(
        `control_a[${r.kind}@${r.delay}]: OLD current at report but not exactly one genuine login-required`,
      );
  }
  // Control (b): B current at the terminal report → replaced detail, no auth_required, B intact.
  const bCurrentAtReport = results.filter(
    (r) =>
      r.terminalSnapshotGeneration !== null &&
      r.terminalSnapshotGeneration !== r.oldGeneration,
  );
  for (const r of bCurrentAtReport) {
    const ok =
      r.authEvents.length === 0 &&
      r.terminal?.lastError === REPLACED_DETAIL &&
      r.terminal?.intent === null &&
      r.stored === "NEW_R" &&
      r.sessionState?.hasSession === true;
    if (!ok)
      failures.push(
        `control_b[${r.kind}@${r.delay}]: B current at report but terminal is not the honest replaced stop`,
      );
  }
  // Universal: B's credentials never presented or removed; every case terminal.
  for (const r of results) {
    if (r.fetches !== 1)
      failures.push(`universal[${r.kind}@${r.delay}]: refresh count ${r.fetches}`);
    if (r.stored !== "NEW_R")
      failures.push(`universal[${r.kind}@${r.delay}]: stored ${r.stored}`);
    if (r.replacementAck?.ok !== true)
      failures.push(`universal[${r.kind}@${r.delay}]: replacement not acknowledged`);
    if (r.terminal === null)
      failures.push(`universal[${r.kind}@${r.delay}]: no terminal snapshot`);
    if (oldCurrentAtReport.length === 0)
      failures.push(`coverage: no offset left OLD current at report (control a empty)`);
    if (bCurrentAtReport.length === 0)
      failures.push(`coverage: no offset made B current at report (control b empty)`);
  }
  const uniqueFailures = [...new Set(failures)];

  let verdict;
  if (expectation === "defect") {
    verdict = staleAuth.length > 0 ? "PASS_DEFECT_REPRODUCED" : "FAIL_DEFECT_NOT_OBSERVED";
    exitCode = staleAuth.length > 0 ? 0 : 1;
  } else {
    const ok = staleAuth.length === 0 && uniqueFailures.length === 0;
    verdict = ok ? "PASS_FIXED" : "FAIL_FIXED_EXPECTATION";
    exitCode = ok ? 0 : 1;
  }
  console.log(
    JSON.stringify(
      {
        probe: "a01-late-reporting-discriminator",
        root,
        expectation,
        verdict,
        started,
        ended: new Date().toISOString(),
        durationMs: performance.now() - began,
        node: process.version,
        network: false,
        children: false,
        cases: results.length,
        staleAuthCases: staleAuth.length,
        staleAuthOffsets: staleAuth.map((r) => `${r.kind}@${r.delay}`),
        acknowledgedStaleAuthCases: acknowledgedStale.length,
        oldCurrentAtReportCases: oldCurrentAtReport.length,
        bCurrentAtReportCases: bCurrentAtReport.length,
        controlFailures: uniqueFailures,
        results,
      },
      null,
      2,
    ),
  );
} catch (error) {
  console.log(
    JSON.stringify({ error: String(error && error.stack), results }, null, 2),
  );
  exitCode = 2;
} finally {
  clearTimeout(watchdog);
  area.set = originalSet;
  await session.clearTokens();
}
process.exitCode = exitCode;
