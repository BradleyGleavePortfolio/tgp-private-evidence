// S4 R6 auditor B — run-time terminal-401 reporting boundary probe (offline,
// dependency-free, actual modules via the repository's own Chrome mock).
//
// Question (builder REPORT §5 observation, unproven): can a replacement
// establish B commit between the lock-decided `clearTokensIfSession(run.generation)`
// and `run.onAuthLost()` → broadcastAuthRequired("session expired …"), so that
// "session expired"/auth_required is emitted while B is current?
//
// Schedule per (entrypoint, family, offset):
//   warm OLD session; accepted Start; crawl → ingest POST 401 → refresh held;
//   Family P: refresh answered 401, then B dispatched after `offset` microtask
//             turns (B persist immediate) — the fastest B can queue BEHIND the
//             run's clear on the state lock.
//   Family Q: B dispatched BEFORE the refresh is answered, with B's persist
//             parked (B owns the lock); refresh answered 401; B's persist
//             released after `offset` turns — the run's clear is queued BEHIND B.
// Recorded per auth_required emission: session generation and the stored
// refresh-key value AT EMISSION TIME. Stale := auth_required emitted while a
// session other than the run's own is current (generation != OLD and stored
// refresh token present / equal to NEW_R). Also checks: B's NEW_R never removed
// by the obsolete run, hasSession true whenever B was acknowledged, obsolete run
// never presents NEW_R or NEW_A, guard released.
// Exit 0 = no stale emission and controls hold; 1 = stale/control failure;
// 2 = harness error / budget overrun.
// Usage: node runtime401-authlost-boundary-probe.mjs <source-root> [--max-offset N]
import { pathToFileURL } from "node:url";
import { resolve } from "node:path";

const args = process.argv.slice(2);
const root = resolve(args[0] ?? "");
const maxIdx = args.indexOf("--max-offset");
const maxOffset = maxIdx >= 0 ? Number(args[maxIdx + 1]) : 40;
// The legacy TrueCoach extractor paces every source request by a real 500 ms
// timer (extractors/truecoach/net.js RATE_LIMIT_MS), so its enumeration is
// bounded separately to stay inside the audit's 45 s budget. The 401 →
// sessionLossError → onAuthLost code (makeSender) is shared by both entrypoints.
const legIdx = args.indexOf("--legacy-max-offset");
const legacyMaxOffset = legIdx >= 0 ? Number(args[legIdx + 1]) : 6;
if (!root) {
  console.error("usage: <source-root> [--max-offset N]");
  process.exit(2);
}

const REFRESH_URL = "https://api.tgp.coach/api/auth/extension/refresh";
const INGEST_URL = "https://api.tgp.coach/api/scout/ingest";
const COMPLETE_URL = "https://api.tgp.coach/api/scout/ingest/complete";
const PROGRESS_URL = "https://api.tgp.coach/api/scout/progress";
const CLIENTS_PREFIX = "https://app.truecoach.co/proxy/api/clients?";
const NOTES_URL = "https://app.truecoach.co/proxy/api/clients/c1/notes";
const TAB_URL = "https://app.truecoach.co/clients";
const EXPIRED = "session expired — please sign in again";
const REPLACED =
  "import stopped — your TGP session changed during the import. Start the import again.";
const key = "tgp_refresh_token";
const OLD = { accessToken: "OLD_A", refreshToken: "OLD_R" };
const NEW = { accessToken: "NEW_A", refreshToken: "NEW_R" };

const { makeBgMock } = await import(
  pathToFileURL(root + "/test/helpers/background-mock.js")
);
const mock = makeBgMock({ tab: { url: TAB_URL, token: "SYNTHETIC_SOURCE" } });
globalThis.chrome = mock.chrome;
const began = performance.now();
await import(pathToFileURL(root + "/background.js"));
const session = await import(pathToFileURL(root + "/shared/session.js"));
const area = mock.chrome.storage.session;
const originalSet = area.set;
const defer = () => {
  let r;
  const promise = new Promise((res) => (r = res));
  return { promise, resolve: r };
};
const flush = async (n = 100) => {
  for (let i = 0; i < n; i++) await Promise.resolve();
};
const tick = () => new Promise((r) => setTimeout(r, 0));
async function until(pred) {
  for (let i = 0; i < 4000; i++) {
    if (pred()) return;
    await tick();
  }
  throw new Error("observation did not arrive");
}
let captures = [];
let bDispatched = false;
const originalSend = mock.chrome.runtime.sendMessage;
mock.chrome.runtime.sendMessage = (msg) => {
  captures.push({
    kind: msg.kind,
    lastError: msg.lastError ?? null,
    intent: msg.intent === undefined ? undefined : msg.intent,
    generation: session.getSessionGeneration(),
    stored: mock.sessionMap.get(key) ?? null,
    bDispatched,
  });
  return originalSend(msg);
};
const watchdog = setTimeout(() => {
  console.error("PROBE_BUDGET_EXCEEDED");
  process.exit(2);
}, 40000);

const results = [];
const failures = [];
let exitCode = 2;
try {
  for (const kind of ["start_import", "start_ingest"]) {
    for (const family of ["P", "Q"]) {
      const bound = kind === "start_ingest" ? legacyMaxOffset : maxOffset;
      for (let offset = 0; offset <= bound; offset++) {
        area.set = originalSet;
        await session.clearTokens();
        await flush();
        await tick();
        const ackOld = await mock.dispatch({
          kind: "session_established",
          ...OLD,
        });
        if (!ackOld?.ok) throw Error("OLD establish failed");
        mock.sent.length = 0;
        captures = [];
        bDispatched = false;
        const calls = [];
        const refreshHeld = defer();
        globalThis.fetch = async (url, init) => {
          const headers = init?.headers ?? {};
          const bearer =
            typeof headers.Authorization === "string"
              ? headers.Authorization
              : null;
          const refreshToken =
            url === REFRESH_URL ? JSON.parse(init.body).refresh_token : null;
          calls.push({ url, bearer, refreshToken });
          if (url === REFRESH_URL) return refreshHeld.promise;
          if (url === INGEST_URL) return new Response(null, { status: 401 });
          if (url === COMPLETE_URL) return new Response(null, { status: 200 });
          if (url === PROGRESS_URL) return new Response(null, { status: 204 });
          if (url.startsWith(CLIENTS_PREFIX) && url.includes("page=1"))
            return Response.json({ clients: [{ id: "c1" }] });
          if (url.startsWith(CLIENTS_PREFIX))
            return Response.json({ clients: [] });
          if (url === NOTES_URL) return Response.json({ notes: [{ id: "n1" }] });
          if (url === "https://app.truecoach.co/proxy/api/organizations")
            return Response.json({
              organizations: [{ id: 7, name: "Acme Strength" }],
              users: [
                { id: 3, role: "Trainer", first_name: "Dana", last_name: "Reed" },
              ],
            });
          throw new Error("unrouted fetch " + url);
        };
        const oldGeneration = session.getSessionGeneration();
        const startAck = await mock.dispatch({
          kind,
          url: TAB_URL,
          tabId: 42,
          sourceToken: "SYNTHETIC_SOURCE",
        });
        if (!startAck?.ok) throw Error("start not admitted: " + kind);
        await until(() => calls.some((c) => c.url === REFRESH_URL));
        await flush();
        const refreshCount = calls.filter((c) => c.url === REFRESH_URL).length;
        if (refreshCount !== 1) throw Error("expected one refresh");

        let pairing;
        let entered = false;
        if (family === "P") {
          refreshHeld.resolve(new Response(null, { status: 401 }));
          await flush(offset);
          pairing = mock.dispatch({ kind: "session_established", ...NEW });
          bDispatched = true;
        } else {
          const persist = defer();
          area.set = async (obj) => {
            if (obj[key] === NEW.refreshToken) {
              entered = true;
              await persist.promise;
            }
            return originalSet(obj);
          };
          pairing = mock.dispatch({ kind: "session_established", ...NEW });
          bDispatched = true;
          await flush();
          if (!entered) throw Error("replacement not parked");
          refreshHeld.resolve(new Response(null, { status: 401 }));
          await flush(offset);
          persist.resolve();
        }
        const replacementAck = await pairing;
        const generationAfterB = session.getSessionGeneration();
        await until(() => {
          const snaps = mock.sent.filter((m) => m.kind === "status_snapshot");
          const last = snaps.at(-1);
          return (
            mock.sent.some((m) => m.kind === "auth_required") ||
            (last && last.intent && last.intent.status === "ingest_failed")
          );
        });
        await flush();
        await tick();
        area.set = originalSet;
        const authEvents = captures.filter((c) => c.kind === "auth_required");
        const snaps = captures.filter((c) => c.kind === "status_snapshot");
        const terminalSnap = snaps.at(-1);
        const sessionState = await mock.dispatch({
          kind: "request_session_state",
        });
        const again = await mock.dispatch({
          kind: "start_import",
          url: "https://example.invalid/",
          tabId: 42,
        });
        await tick();
        const r = {
          kind,
          family,
          offset,
          oldGeneration,
          generationAfterB,
          finalGeneration: session.getSessionGeneration(),
          replacementAck,
          authEvents,
          terminal: terminalSnap
            ? {
                lastError: terminalSnap.lastError,
                intentStatus: terminalSnap.intent?.status ?? null,
                generation: terminalSnap.generation,
              }
            : null,
          stored: mock.sessionMap.get(key) ?? null,
          sessionState,
          guardReleased: again?.ok === true,
          presentedNew: calls.filter(
            (c) => c.refreshToken === NEW.refreshToken || c.bearer === `Bearer ${NEW.accessToken}`,
          ).length,
          refreshes: calls.filter((c) => c.url === REFRESH_URL).length,
        };
        results.push(r);

        // Invariants.
        const tag = `${kind}/${family}@${offset}`;
        // Stale: auth_required emitted while a session other than OLD is current.
        for (const e of r.authEvents) {
          if (e.generation !== r.oldGeneration) {
            // After a genuine clear the generation is OLD+1 with NOTHING stored.
            const clearedState =
              e.generation === r.oldGeneration + 1 && e.stored === null;
            if (!clearedState)
              failures.push(
                `STALE_AUTH[${tag}]: auth_required at generation ${e.generation} stored=${e.stored}`,
              );
          } else {
            failures.push(
              `IMPOSSIBLE[${tag}]: auth_required at OLD generation (clear did not advance?)`,
            );
          }
        }
        if (r.authEvents.length > 1)
          failures.push(`MULTI_AUTH[${tag}]: ${r.authEvents.length}`);
        if (r.replacementAck?.ok !== true)
          failures.push(`B_NOT_ACKED[${tag}]`);
        if (r.stored !== NEW.refreshToken)
          failures.push(`B_TOKEN_LOST[${tag}]: stored=${r.stored}`);
        if (r.sessionState?.hasSession !== true)
          failures.push(`B_NO_SESSION[${tag}]`);
        if (r.presentedNew !== 0)
          failures.push(`B_PRESENTED[${tag}]: ${r.presentedNew}`);
        if (!r.guardReleased) failures.push(`GUARD_HELD[${tag}]`);
        if (r.authEvents.length === 1) {
          if (r.terminal?.lastError !== EXPIRED)
            failures.push(`EXPIRED_TEXT[${tag}]: ${r.terminal?.lastError}`);
          // a genuine clear happened → B committed after it
          if (r.finalGeneration !== r.oldGeneration + 2)
            failures.push(`GEN_SEQ[${tag}]: final=${r.finalGeneration}`);
        } else {
          if (r.terminal?.lastError !== REPLACED)
            failures.push(`REPLACED_TEXT[${tag}]: ${r.terminal?.lastError}`);
          if (r.terminal?.intentStatus !== "ingest_failed")
            failures.push(`REPLACED_STATUS[${tag}]: ${r.terminal?.intentStatus}`);
          if (r.finalGeneration !== r.oldGeneration + 1)
            failures.push(`GEN_SEQ[${tag}]: final=${r.finalGeneration}`);
        }
      }
    }
  }
  const expired = results.filter((r) => r.authEvents.length === 1).length;
  const replaced = results.filter((r) => r.authEvents.length === 0).length;
  // Expired-class cases where B had ALREADY been dispatched (queued on the
  // state lock behind the run's clear) when "session expired" was emitted:
  // the builder's hypothesised window. Stale would require B committed there.
  const queuedBehindClearAtEmission = results
    .filter((r) => r.authEvents.length === 1 && r.authEvents[0].bDispatched)
    .map((r) => `${r.kind}/${r.family}@${r.offset}`);
  const byFamily = {};
  for (const r of results) {
    const k = `${r.kind}/${r.family}`;
    byFamily[k] ??= { expired: 0, replaced: 0, expiredOffsets: [] };
    if (r.authEvents.length === 1) {
      byFamily[k].expired++;
      byFamily[k].expiredOffsets.push(r.offset);
    } else byFamily[k].replaced++;
  }
  exitCode = failures.length === 0 && expired > 0 && replaced > 0 ? 0 : 1;
  if (expired === 0) failures.push("NON_DISCRIMINATING: no expired-class case");
  if (replaced === 0) failures.push("NON_DISCRIMINATING: no replaced-class case");
  console.log(
    JSON.stringify(
      {
        probe: "runtime401-authlost-boundary-probe",
        root,
        node: process.version,
        cases: results.length,
        expiredClass: expired,
        replacedClass: replaced,
        byFamily,
        queuedBehindClearAtEmission,
        staleAuth: failures.filter((f) => f.startsWith("STALE_AUTH")).length,
        failures,
        wallMs: Math.round(performance.now() - began),
        verdict: exitCode === 0 ? "PASS_NO_STALE_EMISSION" : "FAIL",
        results,
      },
      null,
      1,
    ),
  );
} catch (err) {
  console.error("HARNESS_ERROR", err?.stack ?? String(err));
  exitCode = 2;
} finally {
  clearTimeout(watchdog);
  process.exit(exitCode);
}
