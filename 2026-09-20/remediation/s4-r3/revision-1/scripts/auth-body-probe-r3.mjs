// S4 R3 builder probe — dependency-free, single process, no browser, no real
// network, no real credentials. Derived from auditor A's R2 reproduction
// (repos/evidence/2026-09-20/audits/s4-r2/a/revision-1/auth-body-probe.mjs).
//
// Deterministic timers: intercept setTimeout/clearTimeout so the 15 s auth
// deadline can be inspected and fired on demand; native timers only tick.
// Real `Response` objects on open synthetic ReadableStreams model an HTTP
// response whose headers arrived but whose JSON body never closes.
//
// Usage: S4_PROBE_ROOT=<worktree> S4_PROBE_HEAD=<sha> node auth-body-probe-r3.mjs <out.json>
// Exit 0 when every expectation of the FIXED behaviour holds; exit 1 with the
// first failing expectation recorded (this is how the frozen base is shown to
// still exhibit the defect).
import { writeFileSync } from "node:fs";
import assert from "node:assert/strict";

const root = process.env.S4_PROBE_ROOT ?? "/home/user/workspace/worktrees/s4-r3";
const head = process.env.S4_PROBE_HEAD ?? "unknown";
const out = process.argv[2] ?? "./auth-body-probe-r3.json";

const realSetTimeout = globalThis.setTimeout;
const realClearTimeout = globalThis.clearTimeout;
const pendingTimers = new Map();
const timerTrace = [];
let nextId = 0;
globalThis.setTimeout = (fn, ms) => {
  const id = ++nextId;
  pendingTimers.set(id, fn);
  timerTrace.push({ op: "set", id, ms });
  return id;
};
globalThis.clearTimeout = (id) => {
  timerTrace.push({ op: "clear", id });
  pendingTimers.delete(id);
};
const tick = async (n = 3) => {
  for (let i = 0; i < n; i++) await new Promise((r) => realSetTimeout(r, 0));
};
const fireDeadlines = () => {
  const fns = [...pendingTimers.values()];
  pendingTimers.clear();
  for (const fn of fns) fn();
};

// Capture PII-free event codes emitted by shared/log.js.
const events = [];
const realWarn = console.warn;
console.warn = (line) => {
  try {
    events.push(JSON.parse(line).event);
  } catch {
    events.push(String(line));
  }
};

const enc = new TextEncoder();
// Headers arrive with a valid JSON prefix; the stream is never closed.
const stalledResponse = (status = 200) =>
  new Response(
    new ReadableStream({
      start(controller) {
        controller.enqueue(enc.encode('{"access_token":'));
      },
    }),
    { status },
  );
const streamedResponse = (text, status = 200) =>
  new Response(
    new ReadableStream({
      start(controller) {
        controller.enqueue(enc.encode(text));
        controller.close();
      },
    }),
    { status },
  );

const observations = [];
const result = { head, root, observations, events, pass: false, failure: null };
const record = (o) => observations.push(o);

try {
  // ---------------------------------------------------------------- pairing
  const { redeemPairingCode } = await import(`${root}/shared/pairing.js`);
  {
    let state = "pending";
    let value;
    let signal;
    let sent = 0;
    redeemPairingCode("123456", {
      fetch: async (_url, init) => {
        signal = init.signal;
        return stalledResponse();
      },
      sendMessage: async () => {
        sent++;
        return { ok: true };
      },
    }).then(
      (v) => {
        state = "resolved";
        value = v;
      },
      () => (state = "rejected"),
    );
    await tick();
    const liveBeforeDeadline = pendingTimers.size;
    fireDeadlines();
    await tick();
    record({
      case: "pair: 200 headers, JSON body never ends",
      liveDeadlineBeforeFire: liveBeforeDeadline,
      stateAfterDeadline: state,
      value,
      signalAborted: signal.aborted,
      sessionEstablishedSent: sent,
      liveDeadlineAfter: pendingTimers.size,
    });
    assert.equal(liveBeforeDeadline, 1, "pair deadline must still be live while body stalls");
    assert.equal(state, "resolved", "pair must settle when the deadline fires");
    assert.deepEqual(value, {
      ok: false,
      error: "That took too long. Check your connection and try again.",
    });
    assert.equal(signal.aborted, true);
    assert.equal(sent, 0);
    assert.equal(pendingTimers.size, 0);
    assert.ok(events.includes("pair_timeout"));
    assert.ok(!events.includes("pair_body_parse_error"), "stall is a timeout, not a parse error");
  }
  {
    // Non-2xx with stalled body must also settle (error-code lookup is bounded).
    let value;
    const p = redeemPairingCode("123456", {
      fetch: async () => stalledResponse(409),
      sendMessage: async () => ({ ok: true }),
    }).then((v) => (value = v));
    await tick();
    fireDeadlines();
    await p;
    record({ case: "pair: 409 headers, body never ends", value });
    assert.equal(value.ok, false);
    assert.equal(value.error, "That took too long. Check your connection and try again.");
  }
  {
    // Normal streamed success still works, and token material only goes to session_established.
    const messages = [];
    const value = await redeemPairingCode("123456", {
      fetch: async () =>
        streamedResponse(
          JSON.stringify({ access_token: "A1", refresh_token: "R1", chosen_platform: "truecoach" }),
        ),
      sendMessage: async (m) => {
        messages.push(m);
        return { ok: true };
      },
    });
    record({ case: "pair: streamed success", value, messageKinds: messages.map((m) => m.kind) });
    assert.deepEqual(value, { ok: true, chosenPlatform: "truecoach" });
    assert.deepEqual(messages, [{ kind: "session_established", accessToken: "A1", refreshToken: "R1" }]);
    assert.equal(pendingTimers.size, 0);
  }
  {
    // Oversized body is rejected as a parse failure (bounded bytes), never handed on.
    let sent = 0;
    const big = JSON.stringify({ access_token: "x".repeat(20000), refresh_token: "y" });
    const value = await redeemPairingCode("123456", {
      fetch: async () => streamedResponse(big),
      sendMessage: async () => {
        sent++;
        return { ok: true };
      },
    });
    record({ case: "pair: oversized 200 body", value, sent, bytes: big.length });
    assert.deepEqual(value, { ok: false, error: "Unexpected pairing response." });
    assert.equal(sent, 0);
    assert.ok(events.includes("pair_body_parse_error"));
  }
  {
    // Legacy non-stream mock shape (existing unit tests) still parses.
    const value = await redeemPairingCode("123456", {
      fetch: async () => ({ ok: false, status: 409, json: async () => ({ code: "expired" }) }),
      sendMessage: async () => ({ ok: true }),
    });
    record({ case: "pair: plain-object response fallback", value });
    assert.equal(value.error, "That code has expired. Generate a fresh one in the TGP app.");
  }

  // ---------------------------------------------------------------- refresh
  const store = new Map([["tgp_refresh_token", "synthetic-refresh-1"]]);
  globalThis.chrome = {
    storage: {
      session: {
        get: async (k) => (store.has(k) ? { [k]: store.get(k) } : {}),
        set: async (obj) => Object.entries(obj).forEach(([k, v]) => store.set(k, v)),
        remove: async (k) => store.delete(k),
      },
    },
  };
  const fetchLog = [];
  let fetchImpl = async () => stalledResponse();
  globalThis.fetch = async (url, init) => {
    fetchLog.push({ url, refreshToken: JSON.parse(init.body).refresh_token });
    return fetchImpl(url, init);
  };
  const session = await import(`${root}/shared/session.js`);

  {
    // Stalled refresh body settles null at the deadline; stored token preserved.
    let state = "pending";
    let value;
    session.refreshAccessToken().then(
      (v) => {
        state = "resolved";
        value = v;
      },
      () => (state = "rejected"),
    );
    await tick();
    const live = pendingTimers.size;
    fireDeadlines();
    await tick();
    record({
      case: "refresh: 200 headers, body never ends",
      liveDeadlineBeforeFire: live,
      stateAfterDeadline: state,
      value,
      storedRefreshToken: store.get("tgp_refresh_token"),
      fetches: fetchLog.length,
    });
    assert.equal(live, 1, "refresh deadline must still be live while body stalls");
    assert.equal(state, "resolved");
    assert.equal(value, null);
    assert.equal(store.get("tgp_refresh_token"), "synthetic-refresh-1");
    assert.ok(events.includes("refresh_timeout"));
    // Recovery after the timeout: a fresh refresh performs its own fetch.
    fetchImpl = async () => streamedResponse(JSON.stringify({ access_token: "A-after-timeout" }));
    const next = await session.refreshAccessToken();
    record({ case: "refresh: fresh refresh after timeout", value: next, fetches: fetchLog.length });
    assert.equal(next, "A-after-timeout");
    assert.equal(fetchLog.length, 2);
  }
  {
    // Stalled refresh, then clear + re-establish: the new session's refresh
    // must NOT join the stale in-flight work, and the stale result must never
    // overwrite the new session.
    fetchImpl = async () => stalledResponse();
    await session.clearTokens();
    await session.establishSession("A-old", "synthetic-refresh-old");
    const fetchesBefore = fetchLog.length;
    let staleState = "pending";
    let staleValue;
    session.refreshAccessToken().then(
      (v) => {
        staleState = "resolved";
        staleValue = v;
      },
      () => (staleState = "rejected"),
    );
    await tick();
    assert.equal(fetchLog.length, fetchesBefore + 1);
    await session.clearTokens();
    await session.establishSession("A-new", "synthetic-refresh-new");
    fetchImpl = async () =>
      streamedResponse(JSON.stringify({ access_token: "A-new-minted", refresh_token: "synthetic-refresh-new-2" }));
    let freshState = "pending";
    let freshValue;
    session.refreshAccessToken().then(
      (v) => {
        freshState = "resolved";
        freshValue = v;
      },
      () => (freshState = "rejected"),
    );
    await tick(6);
    record({
      case: "refresh: stalled, then clear + establish, then refresh",
      staleStateBeforeDeadline: staleState,
      freshState,
      freshValue,
      fetches: fetchLog.slice(fetchesBefore),
      storedRefreshToken: store.get("tgp_refresh_token"),
    });
    assert.equal(freshState, "resolved", "new-session refresh must not join stale in-flight refresh");
    assert.equal(freshValue, "A-new-minted");
    assert.equal(fetchLog.length, fetchesBefore + 2, "new session performs its own fetch");
    assert.equal(fetchLog.at(-1).refreshToken, "synthetic-refresh-new");
    assert.equal(store.get("tgp_refresh_token"), "synthetic-refresh-new-2");
    assert.equal(staleState, "pending");
    // Now the stale body's deadline fires: stale settles null; new session untouched.
    fireDeadlines();
    await tick();
    const current = await session.getAccessToken();
    record({
      case: "refresh: stale deadline fires after re-establish",
      staleState,
      staleValue,
      currentAccessToken: current,
      storedRefreshToken: store.get("tgp_refresh_token"),
      liveDeadlines: pendingTimers.size,
    });
    assert.equal(staleState, "resolved");
    assert.equal(staleValue, null);
    assert.equal(current, "A-new-minted");
    assert.equal(store.get("tgp_refresh_token"), "synthetic-refresh-new-2");
    assert.equal(pendingTimers.size, 0);
  }
  {
    // Stale success arriving AFTER re-establish (no timeout) is still fenced.
    let release;
    fetchImpl = () => new Promise((r) => (release = r));
    await session.clearTokens();
    await session.establishSession("A-e1", "R-e1");
    const staleP = session.refreshAccessToken();
    await tick();
    await session.clearTokens();
    await session.establishSession("A-e2", "R-e2");
    release(streamedResponse(JSON.stringify({ access_token: "RESURRECT", refresh_token: "R-resurrect" })));
    const stale = await staleP;
    record({
      case: "refresh: stale success after re-establish",
      stale,
      current: await session.getAccessToken(),
      storedRefreshToken: store.get("tgp_refresh_token"),
    });
    assert.equal(stale, null);
    assert.equal(await session.getAccessToken(), "A-e2");
    assert.equal(store.get("tgp_refresh_token"), "R-e2");
  }
  {
    // Stalled refresh then clear only: next refresh is null without network.
    fetchImpl = async () => stalledResponse();
    await session.clearTokens();
    await session.establishSession("A-c", "R-c");
    const before = fetchLog.length;
    const staleP = session.refreshAccessToken();
    await tick();
    await session.clearTokens();
    const after = await session.refreshAccessToken();
    record({ case: "refresh: stalled then clear only", after, fetches: fetchLog.length - before, hasSession: await session.hasActiveSession() });
    assert.equal(after, null);
    assert.equal(fetchLog.length - before, 1);
    fireDeadlines();
    assert.equal(await staleP, null);
  }
  {
    // Oversized refresh body: parse-error category, nothing committed.
    await session.clearTokens();
    await session.establishSession("A-o", "R-o");
    fetchImpl = async () => streamedResponse(JSON.stringify({ access_token: "x".repeat(20000) }));
    const v = await session.refreshAccessToken();
    record({ case: "refresh: oversized body", value: v, current: await session.getAccessToken() });
    assert.equal(v, null);
    assert.equal(await session.getAccessToken(), "A-o");
    assert.ok(events.includes("refresh_body_parse_error"));
  }
  {
    // Coalescing of concurrent same-epoch refreshes is preserved (one fetch).
    await session.clearTokens();
    await session.establishSession("A-k", "R-k");
    const before = fetchLog.length;
    let release;
    fetchImpl = () => new Promise((r) => (release = r));
    const a = session.refreshAccessToken();
    const b = session.refreshAccessToken();
    const c = session.refreshAccessToken();
    await tick();
    release(streamedResponse(JSON.stringify({ access_token: "A-k2" })));
    const vals = await Promise.all([a, b, c]);
    record({ case: "refresh: same-epoch coalescing", vals, fetches: fetchLog.length - before });
    assert.deepEqual(vals, ["A-k2", "A-k2", "A-k2"]);
    assert.equal(fetchLog.length - before, 1);
  }
  result.pass = true;
} catch (err) {
  result.failure = { message: err.message, name: err.name };
} finally {
  globalThis.setTimeout = realSetTimeout;
  globalThis.clearTimeout = realClearTimeout;
  console.warn = realWarn;
  result.timerTrace = timerTrace;
  result.scope =
    "actual shipped modules, actual Response bodies on synthetic ReadableStreams, deterministic timer interception; single process; not a browser execution and not customer import";
  writeFileSync(out, JSON.stringify(result, null, 2) + "\n");
  console.log(JSON.stringify({ head, pass: result.pass, failure: result.failure }, null, 2));
  process.exit(result.pass ? 0 : 1);
}
