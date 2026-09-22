// S4 R4 independent audit B — discriminating offline probe (single process,
// dependency-free, no network, no source mutation, no shared lock).
//
// Two schedules the R4 specs do not stage:
//
//  P-A (session module only): clear THEN establish are both queued on the state
//      lock ahead of a refresh that was admitted (slot taken) but has not
//      snapshotted. Expect: nothing presented for the OLD token, exactly one
//      fetch presenting NEW, and both the pre-transition joiner and a
//      post-establish joiner receive the minted token. (Extends
//      refresh-admission-epoch.spec cases 1 and 3, which stage the transitions
//      one at a time.)
//
//  P-C (real router/worker/replay/session, chrome.* + HTTP mocked): an OLD-run
//      ingest 401 requests a refresh while the trusted `session_established`
//      handler for the replacement is still inside chrome.storage.session.set
//      (holding the state lock). By design (A-01 fix) the pending run stays
//      joinable, snapshots the NEW session and presents NEW_RT. Expect: the
//      OLD run then stops as obsolete (ingest_failed + replaced detail, no
//      auth_required, no /complete, no bearer under NEW), the replacement is
//      intact AND rotated (storage = NEW_ROTATED, in-memory access = minted).
//      This schedule contradicts the literal test invariant in
//      session-ownership.spec.js#expectReplacementIntact ("the replacement's
//      refresh token was never presented by the old run"), so it is recorded as
//      a claim-precision finding, not as a defect, unless an assertion fails.
//
// usage: node pending-admission-replacement-probe.mjs <repo-root>
import { pathToFileURL } from "node:url";
import { resolve } from "node:path";
import { execFileSync } from "node:child_process";
import { webcrypto } from "node:crypto";

const root = resolve(process.argv[2] ?? "/home/user/workspace/worktrees/s4-r4");
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
globalThis.crypto ??= webcrypto;
const startedAt = Date.now();
const failures = [];
const record = {};
function check(name, pass, detail) {
  record[name] = { pass, detail };
  if (!pass) failures.push(name);
}
const flush = async (n = 60) => {
  for (let i = 0; i < n; i += 1) await Promise.resolve();
};
const tick = () => new Promise((r) => setTimeout(r, 0));
const until = async (predicate, label) => {
  for (let i = 0; i < 4000; i += 1) {
    if (predicate()) return;
    await tick();
  }
  throw new Error(`observation did not arrive: ${label}`);
};
function deferred() {
  let resolve;
  const promise = new Promise((r) => {
    resolve = r;
  });
  return { promise, resolve };
}
const REFRESH_KEY = "tgp_refresh_token";

// ---------------------------------------------------------------- P-A -------
{
  const store = new Map([[REFRESH_KEY, "OLD_REFRESH"]]);
  let holdSet = null;
  let holdRemove = null;
  globalThis.chrome = {
    storage: {
      session: {
        get: async (k) => (store.has(k) ? { [k]: store.get(k) } : {}),
        set: async (obj) => {
          if (holdSet) await holdSet.promise;
          for (const [k, v] of Object.entries(obj)) store.set(k, v);
        },
        remove: async (k) => {
          if (holdRemove) await holdRemove.promise;
          store.delete(k);
        },
      },
    },
  };
  const presented = [];
  const releases = [];
  globalThis.fetch = async (_url, init) => {
    presented.push(JSON.parse(init.body).refresh_token);
    return new Promise((r) => releases.push(r));
  };
  const session = await import(
    pathToFileURL(resolve(root, "shared/session.js")).href + "?probe=pa"
  );
  const removal = deferred();
  holdRemove = removal;
  const cleared = session.clearTokens(); // holds the lock in storage.remove
  await flush();
  const established = session.establishSession("NEW_ACCESS", "NEW_REFRESH"); // queued
  const pending = session.refreshAccessToken(); // admitted, snapshot queued third
  await flush();
  check("PA.nothing_presented_before_transitions", presented.length === 0, presented.slice());
  removal.resolve();
  holdRemove = null;
  await cleared;
  const est = await established;
  await flush();
  check("PA.establish_ok", est && est.ok === true, est);
  check("PA.one_fetch_presenting_NEW_only", JSON.stringify(presented) === '["NEW_REFRESH"]', presented.slice());
  const joiner = session.refreshAccessToken(); // caller for the NEW session joins
  await flush();
  check("PA.joiner_did_not_start_second_fetch", presented.length === 1, presented.slice());
  releases[0](Response.json({ access_token: "MINTED", refresh_token: "ROTATED" }));
  const results = await Promise.all([pending, joiner]);
  check("PA.both_callers_minted", JSON.stringify(results) === '["MINTED","MINTED"]', results);
  check("PA.storage_rotated", store.get(REFRESH_KEY) === "ROTATED", store.get(REFRESH_KEY));
  check("PA.memory_minted", (await session.getAccessToken()) === "MINTED");
}

// ---------------------------------------------------------------- P-C -------
{
  const { makeBgMock } = await import(
    pathToFileURL(resolve(root, "test/helpers/background-mock.js")).href
  );
  const mock = makeBgMock({
    tab: { url: "https://app.truecoach.co/clients", token: "SYNTHETIC_SOURCE" },
  });
  // Hold chrome.storage.session.set while the replacement persists.
  const rawSet = mock.chrome.storage.session.set;
  let holdSet = null;
  mock.chrome.storage.session.set = async (obj) => {
    if (holdSet && obj[REFRESH_KEY] === "NEW_RT") await holdSet.promise;
    return rawSet(obj);
  };
  globalThis.chrome = mock.chrome;

  const calls = [];
  let replacementAck = null;
  const persist = deferred();
  let ingestCount = 0;
  globalThis.fetch = async (url, init) => {
    const entry = {
      url,
      authorization: init?.headers?.Authorization ?? null,
      refreshToken: url.endsWith("/api/auth/extension/refresh")
        ? JSON.parse(init.body).refresh_token
        : null,
    };
    calls.push(entry);
    if (entry.refreshToken !== null) {
      // Mint for whichever token was presented; the probe records which.
      return Response.json({
        access_token: `MINTED_FOR_${entry.refreshToken}`,
        refresh_token: `ROTATED_FROM_${entry.refreshToken}`,
      });
    }
    if (url.endsWith("/api/scout/ingest")) {
      ingestCount += 1;
      if (ingestCount === 1) {
        // Replacement lands NOW and is held inside storage.set (lock owner).
        holdSet = persist;
        replacementAck = mock.dispatch({
          kind: "session_established",
          accessToken: "NEW_ACCESS",
          refreshToken: "NEW_RT",
        });
        await flush(); // establish is now awaiting storage.set under the lock
        return new Response(null, { status: 401 }); // OLD run's 401 → refresh admitted
      }
      return Response.json({ received: JSON.parse(init.body).entities.length, deduped: 0 }, { status: 202 });
    }
    if (url.includes("/proxy/api/clients?")) {
      return url.includes("page=1")
        ? Response.json({ clients: [{ id: "c1" }] })
        : Response.json({ clients: [] });
    }
    if (url.endsWith("/proxy/api/clients/c1/notes")) return Response.json({ notes: [{ id: "n1" }] });
    if (url.endsWith("/api/scout/progress")) return new Response(null, { status: 204 });
    if (url.endsWith("/api/scout/ingest/complete")) return new Response(null, { status: 200 });
    throw new Error("unexpected probe route " + url);
  };
  await import(pathToFileURL(resolve(root, "background.js")).href);
  const session = await import(pathToFileURL(resolve(root, "shared/session.js")).href); // same instance as background.js
  const first = await mock.dispatch({ kind: "session_established", accessToken: "OLD_ACCESS", refreshToken: "OLD_RT" });
  check("PC.old_session_established", first && first.ok === true, first);
  const genOld = typeof session.getSessionGeneration === "function" ? session.getSessionGeneration() : "n/a (base has no generation API)";
  const started = await mock.dispatch({ kind: "start_import", url: "https://app.truecoach.co/clients", tabId: 42 });
  check("PC.import_started", started && started.ok === true, started);
  await until(() => ingestCount === 1 && replacementAck !== null, "first ingest + replacement dispatched");
  // Give the worker a few macrotasks to process the 401 and admit its refresh
  // while the establish still holds the lock.
  for (let i = 0; i < 5; i += 1) await tick();
  const refreshesBeforeRelease = calls.filter((c) => c.refreshToken !== null).length;
  check("PC.no_refresh_presented_while_establish_holds_lock", refreshesBeforeRelease === 0, refreshesBeforeRelease);
  persist.resolve();
  holdSet = null;
  const ack = await replacementAck;
  check("PC.replacement_acknowledged", ack && ack.ok === true, ack);
  const snapshots = () => mock.sent.filter((m) => m && m.kind === "status_snapshot");
  const authRequired = () => mock.sent.filter((m) => m && m.kind === "auth_required");
  const terminal = () => {
    const s = snapshots().at(-1)?.intent?.status;
    return s === "ingest_failed" || s === "ingest_succeeded" || s === "ingest_partial" || authRequired().length > 0;
  };
  await until(terminal, "terminal status");
  await flush();
  const refreshes = calls.filter((c) => c.refreshToken !== null).map((c) => c.refreshToken);
  const ingestBearers = calls.filter((c) => c.url.endsWith("/api/scout/ingest")).map((c) => c.authorization);
  const completes = calls.filter((c) => c.url.endsWith("/api/scout/ingest/complete")).length;
  const last = snapshots().at(-1);
  const REPLACED_DETAIL = "import stopped — your TGP session changed during the import. Start the import again.";
  record.observed = {
    refreshTokensPresented: refreshes,
    ingestBearers,
    completeCalls: completes,
    authRequired: authRequired().length,
    lastStatus: last?.intent?.status ?? null,
    lastError: last?.lastError ?? null,
    storageRefreshToken: mock.sessionMap.get(REFRESH_KEY) ?? null,
    generationOld: genOld,
    generationNow: typeof session.getSessionGeneration === "function" ? session.getSessionGeneration() : "n/a",
  };
  // Design-level expectations (the A-01 fix REQUIRES the pending run to read the NEW session):
  check("PC.pending_run_presented_NEW_RT_exactly_once", JSON.stringify(refreshes) === '["NEW_RT"]', refreshes);
  check("PC.replacement_rotated_by_that_refresh", mock.sessionMap.get(REFRESH_KEY) === "ROTATED_FROM_NEW_RT", mock.sessionMap.get(REFRESH_KEY));
  check("PC.memory_access_is_minted_for_NEW", (await session.getAccessToken()) === "MINTED_FOR_NEW_RT");
  // Ownership expectations (A-02):
  check("PC.old_run_stopped_ingest_failed", last?.intent?.status === "ingest_failed", last?.intent?.status);
  check("PC.replaced_detail", last?.lastError === REPLACED_DETAIL, last?.lastError);
  check("PC.no_auth_required", authRequired().length === 0, authRequired().length);
  check("PC.no_complete_call", completes === 0, completes);
  check("PC.no_ingest_under_NEW_or_minted_bearer",
    ingestBearers.every((b) => b === "Bearer OLD_ACCESS"), ingestBearers);
  check("PC.no_expired_message_anywhere",
    !snapshots().some((s) => s.lastError === "session expired — please sign in again"));
  const state = await mock.dispatch({ kind: "request_session_state" });
  check("PC.session_state_has_session", state && state.hasSession === true, state);
  // Single-flight released: an unsupported URL is admitted by the router.
  const again = await mock.dispatch({ kind: "start_import", url: "https://example.invalid/", tabId: 42 });
  check("PC.single_flight_released", again && again.ok === true, again);
  // Literal spec invariant (session-ownership.spec.js expectReplacementIntact):
  // "the replacement's refresh token was never presented by the old run".
  record.spec_invariant_old_run_never_presented_NEW_RT = refreshes.every((t) => t === "OLD_RT");
}

const out = {
  probe: "pending-admission-replacement-probe",
  auditor: "S4 R4 independent audit B",
  repoRoot: root,
  head,
  node: process.version,
  elapsedMs: Date.now() - startedAt,
  pass: failures.length === 0,
  failures,
  record,
};
console.log(JSON.stringify(out, null, 2));
process.exit(failures.length === 0 ? 0 : 1);
