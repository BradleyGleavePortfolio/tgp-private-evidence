// S4 R5 independent audit B — discriminating offline probe (single process,
// dependency-free, no network, no source mutation, no shared lock).
//
// Verdict rule is the parent-adopted identity/authority invariant: work bound
// to a session must never present, consume or be handed another session's
// credentials. My R4 P-C "present NEW once" expectation is consciously
// inverted here.
//
// Schedules NOT staged by test/refresh-admission-epoch.spec.js or
// test/session-ownership-preflight.spec.js at 88287cff:
//
//  S1 session: TWO NEW-bound callers wait behind a pending OLD-bound run that
//     stands down -> exactly one NEW presentation shared by both; OLD-bound
//     caller null; nothing presented for OLD.
//  S2 session: OLD-bound joiner shares an UNBOUND pending run; B lands before
//     the snapshot -> unbound run presents NEW (legitimate, unbound owner), the
//     OLD-bound joiner receives null, never B's token.
//  S3 session: OLD-bound run already on the wire; B lands; stale success is
//     fenced -> null for the bound caller, B unrotated; B's own bound refresh
//     presents NEW once.
//  S4 worker: WARM preflight. B's establish is dispatched first and held in
//     storage.set; start_import is accepted while B holds the lock (bound to
//     OLD); B lands before the crawl reaches its first emit -> zero TGP
//     requests of any kind, replaced detail, no auth_required, B intact.
//  S5 worker: my R4 P-C schedule (ingest 401 fired from inside B's persist),
//     inverted expectation -> refresh presented [], B unrotated (NEW_RT),
//     replaced detail, no auth_required, no /complete.
//  S6 worker: COLD service-worker wake (generation 0, refresh token only in
//     storage). (a) control: cold preflight mints OLD once and imports under
//     the minted bearer; (b) B acknowledged while the cold preflight refresh is
//     on the wire -> replaced detail (not "login required"), no auth_required,
//     B intact, nothing under B.
//
// usage: node bound-admission-probe.mjs <repo-root>
import { pathToFileURL } from "node:url";
import { resolve } from "node:path";
import { execFileSync } from "node:child_process";
import { webcrypto } from "node:crypto";

const root = resolve(process.argv[2] ?? "/home/user/workspace/worktrees/s4-r5");
const headOf = () => {
  try {
    return execFileSync("git", ["-C", root, "rev-parse", "HEAD"], {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    }).trim();
  } catch {
    return process.env.PROBE_HEAD ?? "unknown";
  }
};
globalThis.crypto ??= webcrypto;
const startedAt = Date.now();
const failures = [];
const record = {};
const check = (name, pass, detail) => {
  record[name] = detail === undefined ? { pass } : { pass, detail };
  if (!pass) failures.push(name);
};
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
const deferred = () => {
  let resolve;
  const promise = new Promise((r) => {
    resolve = r;
  });
  return { promise, resolve };
};
const REFRESH_KEY = "tgp_refresh_token";
const REPLACED_DETAIL =
  "import stopped — your TGP session changed during the import. Start the import again.";
const EXPIRED = "session expired — please sign in again";
const LOGIN_REQUIRED = "login required to import";

// Fresh session-module instance per schedule (distinct URL query).
async function sessionInstance(tag, seed) {
  const store = new Map(seed ?? []);
  const holds = { set: null, remove: null };
  globalThis.chrome = {
    storage: {
      session: {
        get: async (k) => (store.has(k) ? { [k]: store.get(k) } : {}),
        set: async (obj) => {
          if (holds.set) await holds.set.promise;
          for (const [k, v] of Object.entries(obj)) store.set(k, v);
        },
        remove: async (k) => {
          if (holds.remove) await holds.remove.promise;
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
    pathToFileURL(resolve(root, "shared/session.js")).href + `?probe=${tag}`
  );
  return { session, store, holds, presented, releases };
}
const minted = (rt) =>
  Response.json({ access_token: `MINTED_FOR_${rt}`, refresh_token: `ROTATED_FROM_${rt}` });

// ---------------------------------------------------------------- S1 -------
{
  const { session, store, holds, presented, releases } = await sessionInstance("s1", [
    [REFRESH_KEY, "OLD_RT"],
  ]);
  await session.establishSession("OLD_ACCESS", "OLD_RT");
  const gOld = session.getSessionGeneration();
  const persist = deferred();
  holds.set = persist;
  const est = session.establishSession("NEW_ACCESS", "NEW_RT"); // holds the lock
  await flush();
  const oldBound = session.refreshAccessToken(gOld); // admitted, pending behind establish
  await flush();
  check("S1.nothing_presented_while_pending", presented.length === 0, presented.slice());
  persist.resolve();
  holds.set = null;
  await est;
  const gNew = session.getSessionGeneration();
  const n1 = session.refreshAccessToken(gNew); // two NEW-bound callers
  const n2 = session.refreshAccessToken(gNew);
  const oldResult = await oldBound;
  await flush();
  check("S1.old_bound_caller_null", oldResult === null, oldResult);
  check("S1.exactly_one_NEW_presentation_for_two_waiters", JSON.stringify(presented) === '["NEW_RT"]', presented.slice());
  releases[0](minted("NEW_RT"));
  const both = await Promise.all([n1, n2]);
  check("S1.both_new_callers_minted", JSON.stringify(both) === '["MINTED_FOR_NEW_RT","MINTED_FOR_NEW_RT"]', both);
  check("S1.storage_rotated_by_new_session_only", store.get(REFRESH_KEY) === "ROTATED_FROM_NEW_RT", store.get(REFRESH_KEY));
}

// ---------------------------------------------------------------- S2 -------
{
  const { session, store, holds, presented, releases } = await sessionInstance("s2", [
    [REFRESH_KEY, "OLD_RT"],
  ]);
  await session.establishSession("OLD_ACCESS", "OLD_RT");
  const gOld = session.getSessionGeneration();
  const persist = deferred();
  holds.set = persist;
  const est = session.establishSession("NEW_ACCESS", "NEW_RT");
  await flush();
  const unbound = session.refreshAccessToken(); // unbound pending run
  const oldJoiner = session.refreshAccessToken(gOld); // bound joiner shares it
  await flush();
  persist.resolve();
  holds.set = null;
  await est;
  await flush();
  check("S2.unbound_run_presented_NEW_once", JSON.stringify(presented) === '["NEW_RT"]', presented.slice());
  releases[0](minted("NEW_RT"));
  const [u, j] = await Promise.all([unbound, oldJoiner]);
  check("S2.unbound_caller_gets_current_token", u === "MINTED_FOR_NEW_RT", u);
  check("S2.old_bound_joiner_refused_B_token", j === null, j);
  check("S2.storage_rotated_once", store.get(REFRESH_KEY) === "ROTATED_FROM_NEW_RT", store.get(REFRESH_KEY));
}

// ---------------------------------------------------------------- S3 -------
{
  const { session, store, presented, releases } = await sessionInstance("s3", [
    [REFRESH_KEY, "OLD_RT"],
  ]);
  await session.establishSession("OLD_ACCESS", "OLD_RT");
  const gOld = session.getSessionGeneration();
  const stale = session.refreshAccessToken(gOld);
  await flush();
  check("S3.old_presented_on_wire", JSON.stringify(presented) === '["OLD_RT"]', presented.slice());
  await session.establishSession("NEW_ACCESS", "NEW_RT");
  const gNew = session.getSessionGeneration();
  const fresh = session.refreshAccessToken(gNew);
  await flush();
  check("S3.new_bound_did_not_join_stale_and_presented_NEW_once", JSON.stringify(presented) === '["OLD_RT","NEW_RT"]', presented.slice());
  releases[0](minted("OLD_RT")); // stale success
  const staleResult = await stale;
  check("S3.stale_success_fenced_null", staleResult === null, staleResult);
  check("S3.B_not_overwritten_by_stale", store.get(REFRESH_KEY) === "NEW_RT", store.get(REFRESH_KEY));
  releases[1](minted("NEW_RT"));
  check("S3.new_caller_minted", (await fresh) === "MINTED_FOR_NEW_RT");
  check("S3.storage_rotated_by_B", store.get(REFRESH_KEY) === "ROTATED_FROM_NEW_RT", store.get(REFRESH_KEY));
}

// ------------------------------------------------ worker harness -----------
const { makeBgMock } = await import(
  pathToFileURL(resolve(root, "test/helpers/background-mock.js")).href
);
let bgLoads = 0;
async function worker({ seedSession, onIngest, onRefresh, holdSetWhen }) {
  const mock = makeBgMock({
    session: seedSession,
    tab: { url: "https://app.truecoach.co/clients", token: "SYNTHETIC_SOURCE" },
  });
  const rawSet = mock.chrome.storage.session.set;
  const state = { holdSet: null, calls: [], ingestCount: 0 };
  mock.chrome.storage.session.set = async (obj) => {
    if (state.holdSet && (!holdSetWhen || holdSetWhen(obj))) await state.holdSet.promise;
    return rawSet(obj);
  };
  globalThis.chrome = mock.chrome;
  globalThis.fetch = async (url, init) => {
    const entry = {
      url,
      authorization: init?.headers?.Authorization ?? null,
      refreshToken: url.endsWith("/api/auth/extension/refresh") ? JSON.parse(init.body).refresh_token : null,
    };
    state.calls.push(entry);
    if (entry.refreshToken !== null) return onRefresh ? onRefresh(entry, state) : minted(entry.refreshToken);
    if (url.endsWith("/api/scout/ingest")) {
      state.ingestCount += 1;
      return onIngest ? onIngest(state.ingestCount, init, state) : Response.json({ received: JSON.parse(init.body).entities.length, deduped: 0 }, { status: 202 });
    }
    if (url.includes("/proxy/api/clients?")) return url.includes("page=1") ? Response.json({ clients: [{ id: "c1" }] }) : Response.json({ clients: [] });
    if (url.endsWith("/proxy/api/clients/c1/notes")) return Response.json({ notes: [{ id: "n1" }] });
    if (url.endsWith("/api/scout/progress")) return new Response(null, { status: 204 });
    if (url.endsWith("/api/scout/ingest/complete")) return new Response(null, { status: 200 });
    throw new Error("unexpected probe route " + url);
  };
  bgLoads += 1;
  await import(pathToFileURL(resolve(root, "background.js")).href + `?probe=${bgLoads}`);
  const session = await import(pathToFileURL(resolve(root, "shared/session.js")).href + (bgLoads === 1 ? "" : ""));
  // NOTE: background.js imports ./shared/session.js without a query, so all
  // worker schedules share ONE session-module instance; each schedule uses
  // fresh generations (establish bumps) and the mock storage is per worker.
  const snapshots = () => mock.sent.filter((m) => m && m.kind === "status_snapshot");
  const authRequired = () => mock.sent.filter((m) => m && m.kind === "auth_required");
  const terminal = () => {
    const s = snapshots().at(-1)?.intent?.status;
    return s === "ingest_failed" || s === "ingest_succeeded" || s === "ingest_partial" || authRequired().length > 0 ||
      (snapshots().at(-1)?.intent === null && typeof snapshots().at(-1)?.lastError === "string");
  };
  const summary = () => {
    const last = snapshots().at(-1);
    return {
      refreshTokensPresented: state.calls.filter((c) => c.refreshToken !== null).map((c) => c.refreshToken),
      ingestBearers: state.calls.filter((c) => c.url.endsWith("/api/scout/ingest")).map((c) => c.authorization),
      progressBearers: [...new Set(state.calls.filter((c) => c.url.endsWith("/api/scout/progress")).map((c) => c.authorization))],
      completeBearers: state.calls.filter((c) => c.url.endsWith("/api/scout/ingest/complete")).map((c) => c.authorization),
      authRequired: authRequired().length,
      lastStatus: last?.intent?.status ?? null,
      lastError: last?.lastError ?? null,
      storageRefreshToken: mock.sessionMap.get(REFRESH_KEY) ?? null,
      snapshotErrors: [...new Set(snapshots().map((s) => s.lastError).filter(Boolean))],
    };
  };
  return { mock, session, state, snapshots, authRequired, terminal, summary };
}
const noB = (s) =>
  ![...s.ingestBearers, ...s.progressBearers, ...s.completeBearers].some(
    (b) => b === "Bearer NEW_ACCESS" || b === "Bearer MINTED_FOR_NEW_RT",
  );

// ---------------------------------------------------------------- S4 -------
{
  const w = await worker({ holdSetWhen: (obj) => obj[REFRESH_KEY] === "NEW_RT" });
  check("S4.old_established", (await w.mock.dispatch({ kind: "session_established", accessToken: "OLD_ACCESS", refreshToken: "OLD_RT" }))?.ok === true);
  const persist = deferred();
  w.state.holdSet = persist;
  const bAck = w.mock.dispatch({ kind: "session_established", accessToken: "NEW_ACCESS", refreshToken: "NEW_RT" });
  await flush(); // B owns the lock, inside storage.set
  const started = await w.mock.dispatch({ kind: "start_import", url: "https://app.truecoach.co/clients", tabId: 42 });
  check("S4.start_accepted_while_B_persisting", started?.ok === true, started);
  persist.resolve();
  w.state.holdSet = null;
  check("S4.B_acknowledged", (await bAck)?.ok === true);
  await until(w.terminal, "S4 terminal");
  await flush();
  const s = w.summary();
  record["S4.observed"] = s;
  check("S4.zero_tgp_requests", s.refreshTokensPresented.length === 0 && s.ingestBearers.length === 0 && s.progressBearers.length === 0 && s.completeBearers.length === 0);
  check("S4.replaced_detail", s.lastError === REPLACED_DETAIL, s.lastError);
  check("S4.no_auth_required", s.authRequired === 0);
  check("S4.B_intact", s.storageRefreshToken === "NEW_RT", s.storageRefreshToken);
  check("S4.no_login_required_or_expired", !s.snapshotErrors.includes(LOGIN_REQUIRED) && !s.snapshotErrors.includes(EXPIRED), s.snapshotErrors);
  const st = await w.mock.dispatch({ kind: "request_session_state" });
  check("S4.hasSession_true", st?.hasSession === true, st);
  const again = await w.mock.dispatch({ kind: "start_import", url: "https://example.invalid/", tabId: 42 });
  check("S4.single_flight_released", again?.ok === true, again);
}

// ---------------------------------------------------------------- S5 -------
{
  let bAck = null;
  const persist = deferred();
  const w = await worker({
    holdSetWhen: (obj) => obj[REFRESH_KEY] === "NEW_RT",
    onIngest: async (n, init, state) => {
      if (n === 1) {
        state.holdSet = persist;
        bAck = w.mock.dispatch({ kind: "session_established", accessToken: "NEW_ACCESS", refreshToken: "NEW_RT" });
        await flush();
        return new Response(null, { status: 401 });
      }
      return Response.json({ received: JSON.parse(init.body).entities.length, deduped: 0 }, { status: 202 });
    },
  });
  check("S5.old_established", (await w.mock.dispatch({ kind: "session_established", accessToken: "OLD_ACCESS", refreshToken: "OLD_RT" }))?.ok === true);
  check("S5.started", (await w.mock.dispatch({ kind: "start_import", url: "https://app.truecoach.co/clients", tabId: 42 }))?.ok === true);
  await until(() => w.state.ingestCount === 1 && bAck !== null, "S5 first ingest");
  for (let i = 0; i < 5; i += 1) await tick(); // worker admits its refresh behind B's lock
  persist.resolve();
  w.state.holdSet = null;
  check("S5.B_acknowledged", (await bAck)?.ok === true);
  await until(w.terminal, "S5 terminal");
  await flush();
  const s = w.summary();
  record["S5.observed"] = s;
  check("S5.obsolete_run_presented_nothing", s.refreshTokensPresented.length === 0, s.refreshTokensPresented);
  check("S5.B_unrotated", s.storageRefreshToken === "NEW_RT", s.storageRefreshToken);
  check("S5.old_bearer_only", s.ingestBearers.every((b) => b === "Bearer OLD_ACCESS") && s.ingestBearers.length === 1, s.ingestBearers);
  check("S5.no_B_credentials_used", noB(s));
  check("S5.no_complete", s.completeBearers.length === 0);
  check("S5.replaced_detail_ingest_failed", s.lastStatus === "ingest_failed" && s.lastError === REPLACED_DETAIL, [s.lastStatus, s.lastError]);
  check("S5.no_auth_required", s.authRequired === 0);
  check("S5.hasSession_true", (await w.mock.dispatch({ kind: "request_session_state" }))?.hasSession === true);
}

// ---------------------------------------------------------------- S6 -------
// Cold wake: NOTE the shared session-module instance carries generation state
// from S4/S5 (in a real cold worker it is 0). To model the true cold binding
// value, S6 imports a FRESH session+worker graph via a distinct query on
// background.js only if the module graph allows it; otherwise the schedule is
// still valid (bound generation = current, cold in-memory token) and the
// generation actually bound is recorded.
{
  // (a) control
  {
    const w = await worker({ seedSession: [[REFRESH_KEY, "OLD_RT"]] });
    // No establish in this worker life -> in-memory token absent; but the
    // shared session module may still hold a token from S5. Force cold: clear
    // then re-seed storage directly (what a SW restart looks like: storage
    // survives, memory does not).
    await w.session.clearTokens();
    w.mock.sessionMap.set(REFRESH_KEY, "OLD_RT");
    record["S6.bound_generation_cold"] = w.session.getSessionGeneration();
    check("S6a.started", (await w.mock.dispatch({ kind: "start_import", url: "https://app.truecoach.co/clients", tabId: 42 }))?.ok === true);
    await until(w.terminal, "S6a terminal");
    await flush();
    const s = w.summary();
    record["S6a.observed"] = s;
    check("S6a.cold_preflight_presented_OLD_once", JSON.stringify(s.refreshTokensPresented) === '["OLD_RT"]', s.refreshTokensPresented);
    check("S6a.imported_under_minted_bearer", s.ingestBearers.length > 0 && s.ingestBearers.every((b) => b === "Bearer MINTED_FOR_OLD_RT"), s.ingestBearers);
    check("S6a.succeeded", s.lastStatus === "ingest_succeeded", s.lastStatus);
    check("S6a.no_auth_required", s.authRequired === 0);
  }
  // (b) B acknowledged while the cold preflight refresh is on the wire
  {
    const held = deferred();
    const w = await worker({
      seedSession: [[REFRESH_KEY, "OLD_RT"]],
      onRefresh: (entry) => (entry.refreshToken === "OLD_RT" ? held.promise : minted(entry.refreshToken)),
    });
    await w.session.clearTokens();
    w.mock.sessionMap.set(REFRESH_KEY, "OLD_RT");
    check("S6b.started", (await w.mock.dispatch({ kind: "start_import", url: "https://app.truecoach.co/clients", tabId: 42 }))?.ok === true);
    await until(() => w.state.calls.some((c) => c.refreshToken === "OLD_RT"), "S6b cold refresh on wire");
    check("S6b.B_acknowledged", (await w.mock.dispatch({ kind: "session_established", accessToken: "NEW_ACCESS", refreshToken: "NEW_RT" }))?.ok === true);
    held.resolve(minted("OLD_RT")); // stale success
    await until(w.terminal, "S6b terminal");
    await flush();
    const s = w.summary();
    record["S6b.observed"] = s;
    check("S6b.only_OLD_presented", JSON.stringify(s.refreshTokensPresented) === '["OLD_RT"]', s.refreshTokensPresented);
    check("S6b.zero_ingest_progress_complete", s.ingestBearers.length === 0 && s.progressBearers.length === 0 && s.completeBearers.length === 0);
    check("S6b.replaced_not_login_required", s.lastError === REPLACED_DETAIL && !s.snapshotErrors.includes(LOGIN_REQUIRED), s.snapshotErrors);
    check("S6b.no_auth_required", s.authRequired === 0);
    check("S6b.B_intact_not_stale_rotated", s.storageRefreshToken === "NEW_RT", s.storageRefreshToken);
    check("S6b.hasSession_true", (await w.mock.dispatch({ kind: "request_session_state" }))?.hasSession === true);
  }
}

// ---------------------------------------------------------------- S7 -------
// True cold binding value: a fresh session-module instance whose worker life
// has seen no establish (generation 0, token only in storage). (a) control:
// getAccessToken(0) mints OLD once. (b) B established while the generation-0
// refresh is on the wire -> caller gets no_session, nothing under B, B intact.
{
  const { session, store, presented, releases } = await sessionInstance("s7a", [[REFRESH_KEY, "OLD_RT"]]);
  check("S7.cold_generation_is_zero", session.getSessionGeneration() === 0, session.getSessionGeneration());
  const p = session.getAccessToken(0);
  await flush();
  check("S7a.zero_bound_cold_presents_OLD_once", JSON.stringify(presented) === '["OLD_RT"]', presented.slice());
  releases[0](minted("OLD_RT"));
  check("S7a.minted", (await p) === "MINTED_FOR_OLD_RT");
  check("S7a.rotated", store.get(REFRESH_KEY) === "ROTATED_FROM_OLD_RT", store.get(REFRESH_KEY));
}
{
  const { session, store, presented, releases } = await sessionInstance("s7b", [[REFRESH_KEY, "OLD_RT"]]);
  const p = session.getAccessToken(0).then((t) => ({ t }), (e) => ({ err: e.message }));
  await flush();
  await session.establishSession("NEW_ACCESS", "NEW_RT");
  releases[0](minted("OLD_RT"));
  const r = await p;
  check("S7b.zero_bound_caller_no_session_after_B", r.err === "no_session", r);
  check("S7b.only_OLD_presented", JSON.stringify(presented) === '["OLD_RT"]', presented.slice());
  check("S7b.B_intact", store.get(REFRESH_KEY) === "NEW_RT", store.get(REFRESH_KEY));
}

const out = {
  probe: "bound-admission-probe",
  auditor: "S4 R5 independent audit B",
  repoRoot: root,
  head: headOf(),
  node: process.version,
  elapsedMs: Date.now() - startedAt,
  pass: failures.length === 0,
  failures,
  record,
};
console.log(JSON.stringify(out, null, 2));
process.exit(failures.length === 0 ? 0 : 1);
