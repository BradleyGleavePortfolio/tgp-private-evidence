// S4 R5 discriminator for S4-R4-A-01 (accepted Start adopts the replacement
// during cold asynchronous preflight).
//
// Schedule: verbatim reviewer A's externally-barriered C3 reproduction
// (execution/audits/s4-r4/a/preflight-barrier-probe.mjs, sha256
// 14a07ea7dfd39c4d1d8a1f73e0434610e5cce88dcf4f41a423f4812722c35896), with the
// repo root and the EXPECTED outcome taken from argv so the same schedule runs
// as a positive check on the R5 candidate and as an adverse control on the
// R4 predecessor. The observation code is unchanged; only the verdict differs:
//
//   --expect fixed   : unchanged-session control still imports under the OLD
//                      minted bearer AND with a replacement queued during the
//                      preflight rotation persist the accepted Start makes NO
//                      /ingest, /progress or /ingest/complete request under
//                      B's bearer, broadcasts no auth_required, and B's
//                      session is intact (storage holds B's refresh token,
//                      request_session_state.hasSession === true).
//   --expect defect  : the R4 predecessor reproduces A's finding (B's bearer
//                      on all three routes) — proves the schedule still bites.
//
// Dependency-free, single process, no network, no lock, no source mutation.
// usage: node a01-preflight-barrier-discriminator.mjs <repo-root> --expect fixed|defect
import { pathToFileURL } from "node:url";
import { resolve } from "node:path";
import { execFileSync } from "node:child_process";
import { webcrypto } from "node:crypto";
globalThis.crypto ??= webcrypto;

const root = resolve(process.argv[2]);
const expectIdx = process.argv.indexOf("--expect");
const expectation = expectIdx > 0 ? process.argv[expectIdx + 1] : null;
if (expectation !== "fixed" && expectation !== "defect") {
  console.error("usage: <repo-root> --expect fixed|defect");
  process.exit(2);
}
const head = (() => {
  try {
    return execFileSync("git", ["-C", root, "rev-parse", "HEAD"], {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    }).trim();
  } catch {
    return process.env.PROBE_HEAD ?? "unknown";
  }
})();
const begin = performance.now();
const started = new Date().toISOString();
const results = [];
const tick = () => new Promise((r) => setTimeout(r, 0));
const until = async (pred, label) => {
  const limit = performance.now() + 5000;
  while (!pred()) {
    if (performance.now() > limit) throw Error("observation timeout: " + label);
    await tick();
  }
};
const flush = async () => {
  for (let i = 0; i < 100; i += 1) await Promise.resolve();
};
const defer = () => {
  let resolve;
  const promise = new Promise((r) => {
    resolve = r;
  });
  return { promise, resolve };
};
const key = "tgp_refresh_token";
const TAB = "https://app.truecoach.co/clients";

const { makeBgMock, acceptedIngest } = await import(
  pathToFileURL(`${root}/test/helpers/background-mock.js`)
);
const mock = makeBgMock({ session: [[key, "OLD_R"]], tab: { url: TAB, token: "SOURCE" } });
globalThis.chrome = mock.chrome;
let calls = [];
globalThis.fetch = async (url, init) => {
  calls.push({
    url,
    bearer: init?.headers?.Authorization ?? null,
    refreshToken: url.endsWith("/api/auth/extension/refresh")
      ? JSON.parse(init.body).refresh_token
      : null,
  });
  if (url.endsWith("/api/auth/extension/refresh"))
    return Response.json({ access_token: "OLD_MINTED_A", refresh_token: "OLD_ROTATED_R" });
  if (url.endsWith("/api/scout/ingest")) return acceptedIngest(init);
  if (url.endsWith("/api/scout/progress")) return new Response(null, { status: 204 });
  if (url.endsWith("/api/scout/ingest/complete")) return new Response(null, { status: 200 });
  if (url.includes("/proxy/api/clients?"))
    return Response.json({ clients: url.includes("page=1") ? [{ id: "c1" }] : [] });
  if (url.endsWith("/clients/c1/notes")) return Response.json({ notes: [] });
  throw Error("unrouted synthetic request");
};
await import(pathToFileURL(`${root}/background.js`));
const session = await import(pathToFileURL(`${root}/shared/session.js`));

for (const replace of [false, true]) {
  if (replace) {
    await session.clearTokens();
    mock.sessionMap.set(key, "OLD_R");
  }
  calls = [];
  mock.sent.length = 0;
  const original = mock.chrome.storage.session.set;
  const persist = defer();
  let persistEntered = false;
  mock.chrome.storage.session.set = async (obj) => {
    if (obj[key] === "OLD_ROTATED_R") {
      persistEntered = true;
      await persist.promise;
    }
    return original(obj);
  };
  const startAck = await mock.dispatch({ kind: "start_import", url: TAB, tabId: 42 });
  await until(() => persistEntered, "old refresh rotation persist entered");
  // Old refresh holds the session lock. The trusted replacement event now
  // queues behind it, without executing reentrantly inside storage.set.
  const replacement = replace
    ? mock.dispatch({ kind: "session_established", accessToken: "NEW_A", refreshToken: "NEW_R" })
    : null;
  persist.resolve();
  const replacementAck = await replacement;
  const snapshots = () => mock.sent.filter((x) => x.kind === "status_snapshot");
  const authRequired = () => mock.sent.filter((x) => x.kind === "auth_required");
  const terminalStatus = () => snapshots().at(-1)?.intent?.status;
  await until(
    () =>
      ["ingest_succeeded", "ingest_failed", "ingest_empty"].includes(terminalStatus()) ||
      // R5 candidate: the preflight stop has no intent; it reports lastError only.
      (replace && snapshots().at(-1)?.intent === null && snapshots().at(-1)?.lastError) ||
      authRequired().length > 0,
    "terminal observation",
  );
  await flush();
  mock.chrome.storage.session.set = original;
  const sessionState = await mock.dispatch({ kind: "request_session_state" });
  results.push({
    replace,
    startAck,
    replacementAck,
    calls: [...calls],
    session: [...mock.sessionMap],
    sessionState,
    authRequired: authRequired().length,
    lastSnapshot: snapshots().at(-1),
  });
}
await session.clearTokens();

const required = ["/api/scout/ingest", "/api/scout/progress", "/api/scout/ingest/complete"];
const control = results.find((r) => !r.replace);
const replaced = results.find((r) => r.replace);
const checks = {};
const check = (name, pass, detail) => {
  checks[name] = { pass, detail };
};
// Unchanged-session control (must hold on BOTH sides).
check(
  "control.imports_under_old_minted_bearer_on_all_routes",
  required.every((p) => control.calls.some((c) => c.url.endsWith(p) && c.bearer === "Bearer OLD_MINTED_A")),
  control.calls.map((c) => [c.url.split("/api/")[1] ?? c.url, c.bearer]),
);
check("control.no_auth_required", control.authRequired === 0, control.authRequired);
check("control.terminal_succeeded", control.lastSnapshot?.intent?.status === "ingest_succeeded", control.lastSnapshot?.intent?.status);
// Replacement schedule.
const bBearerRoutes = required.filter((p) => replaced.calls.some((c) => c.url.endsWith(p) && c.bearer === "Bearer NEW_A"));
const anyBBearer = replaced.calls.some((c) => c.bearer === "Bearer NEW_A");
const presentedNewR = replaced.calls.some((c) => c.refreshToken === "NEW_R");
const bIntact = replaced.session.some(([k, v]) => k === key && v === "NEW_R") && replaced.sessionState?.hasSession === true;
if (expectation === "fixed") {
  check("replaced.no_request_under_B_bearer", !anyBBearer, replaced.calls.map((c) => [c.url.split("/api/")[1] ?? c.url, c.bearer]));
  check("replaced.B_refresh_token_never_presented", !presentedNewR, replaced.calls.filter((c) => c.refreshToken !== null).map((c) => c.refreshToken));
  check("replaced.no_auth_required_for_B", replaced.authRequired === 0, replaced.authRequired);
  check("replaced.B_session_intact", bIntact, { session: replaced.session, state: replaced.sessionState });
  check(
    "replaced.truthful_stop_reported",
    replaced.lastSnapshot?.lastError ===
      "import stopped — your TGP session changed during the import. Start the import again." &&
      replaced.lastSnapshot?.intent?.status !== "ingest_succeeded",
    { lastError: replaced.lastSnapshot?.lastError, status: replaced.lastSnapshot?.intent?.status ?? null },
  );
} else {
  // Adverse predecessor predicate: reviewer A's reproduced defect.
  check("replaced.predecessor_reproduces_A01_B_bearer_on_all_routes", bBearerRoutes.length === required.length, bBearerRoutes);
  check("replaced.predecessor_terminal_succeeded_under_B", replaced.lastSnapshot?.intent?.status === "ingest_succeeded", replaced.lastSnapshot?.intent?.status);
}
const failures = Object.entries(checks).filter(([, v]) => !v.pass).map(([k]) => k);
console.log(
  JSON.stringify(
    {
      probe: "a01-preflight-barrier-discriminator",
      derivedFrom: "execution/audits/s4-r4/a/preflight-barrier-probe.mjs sha256 14a07ea7dfd39c4d1d8a1f73e0434610e5cce88dcf4f41a423f4812722c35896",
      root,
      head,
      expectation,
      started,
      ended: new Date().toISOString(),
      durationMs: Math.round(performance.now() - begin),
      node: process.version,
      network: false,
      pass: failures.length === 0,
      failures,
      checks,
      results,
    },
    null,
    2,
  ),
);
process.exit(failures.length === 0 ? 0 : 1);
