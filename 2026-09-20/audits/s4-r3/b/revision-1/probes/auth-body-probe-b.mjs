// S4 R3 independent auditor B — bounded offline probe (single Node process,
// no dependencies, no browser, no network, no writes into any worktree).
//
// Exercises the ACTUAL shipped modules (shared/net.js, shared/pairing.js,
// shared/session.js) of a given root with real `Response` objects over
// synthetic ReadableStreams and intercepted timers. The cases target gaps the
// builder's spec does not cover directly:
//
//  C1  COMPLETE valid JSON arrives but the stream never closes (the exact R2
//      reproduction shape). On deadline cancel, a pending read() resolves
//      {done:true} and JSON.parse(partial) may SUCCEED late. Prove that the
//      late-parsed body still cannot establish/commit anything.
//  C2  Real-fetch-shaped abort: the body stream ERRORS with AbortError when the
//      request signal aborts (what browsers do). Confirm settlement, event codes,
//      and that no body bytes reach console output.
//  C3  Byte bound across chunk boundaries (3 × 6000 B of valid JSON) → BodyError
//      whose message carries no body bytes; stream unlocked afterwards.
//  C4  Multi-byte UTF-8 split across two chunks parses correctly.
//  C5  Coalescer ordering: establishSession() queued BEFORE refreshAccessToken()
//      snapshots. R3 detaches the not-yet-snapshotted run; a second caller inside
//      the fetch window then starts a parallel refresh with the SAME refresh
//      token. Measured on base and candidate for honest attribution.
//  C6  Unhandled-rejection count across all cases (Promise.race must absorb the
//      late consumer rejection).
//
// Usage: S4_PROBE_ROOT=<worktree> S4_PROBE_HEAD=<sha> node auth-body-probe-b.mjs <out.json>
// Exit 0 when every expectation of the CANDIDATE behaviour holds; exit 1 with the
// first failing expectation recorded. C5 is recorded as an observation, not an
// expectation, on both roots.
import { writeFileSync } from "node:fs";
import assert from "node:assert/strict";

const root = process.env.S4_PROBE_ROOT ?? "/home/user/workspace/worktrees/s4-r3";
const head = process.env.S4_PROBE_HEAD ?? "unknown";
const out = process.argv[2] ?? "./auth-body-probe-b.json";

let unhandled = 0;
process.on("unhandledRejection", () => {
  unhandled += 1;
});

// Deterministic deadline: intercept setTimeout/clearTimeout; fire on demand.
const realSetTimeout = globalThis.setTimeout;
const pending = new Map();
let nextId = 0;
globalThis.setTimeout = (fn, ms) => {
  const id = ++nextId;
  pending.set(id, { fn, ms });
  return id;
};
globalThis.clearTimeout = (id) => {
  pending.delete(id);
};
const tick = async (n = 6) => {
  for (let i = 0; i < n; i++) await new Promise((r) => realSetTimeout(r, 0));
};
// Await a promise only if it settles within a few ticks (the base defect leaves
// auth promises pending forever; the probe must still terminate on base).
const settleOr = async (p, fallback = "PENDING") => {
  let v = fallback;
  let done = false;
  p.then((x) => { v = x; done = true; }, (e) => { v = { rejected: String(e && e.name) }; done = true; });
  await tick(8);
  return done ? v : fallback;
};
const fireDeadlines = () => {
  const fns = [...pending.values()].map((t) => t.fn);
  pending.clear();
  for (const fn of fns) fn();
};

// Capture everything written to console.warn (shared/log.js) verbatim.
const warnLines = [];
console.warn = (line) => {
  warnLines.push(String(line));
};
const eventsSince = (i) =>
  warnLines.slice(i).map((l) => {
    try {
      return JSON.parse(l).event;
    } catch {
      return l;
    }
  });

const enc = new TextEncoder();
const SECRET = "SECRET_BODY_MARKER_9f2c";

// chrome.storage.session stub
const store = new Map();
globalThis.chrome = {
  storage: {
    session: {
      get: async (k) => (store.has(k) ? { [k]: store.get(k) } : {}),
      set: async (o) => {
        for (const [k, v] of Object.entries(o)) store.set(k, v);
      },
      remove: async (k) => {
        store.delete(k);
      },
    },
  },
};

const fetches = [];
let fetchImpl = async () => new Response("{}", { status: 200 });
globalThis.fetch = async (url, init) => {
  let rt = null;
  try {
    rt = JSON.parse(init.body).refresh_token ?? null;
  } catch {
    rt = null;
  }
  fetches.push({ refreshToken: rt, hadSignal: !!init.signal });
  return fetchImpl(url, init);
};

const net = await import(`${root}/shared/net.js`);
const pairing = await import(`${root}/shared/pairing.js`);
const session = await import(`${root}/shared/session.js`);
const observations = [];
const record = (o) => {
  observations.push(o);
};
const isCandidateShape = typeof net.readBoundedJson === "function";

// A 200 whose COMPLETE JSON has arrived but whose stream never closes.
function completeButOpen(json, status = 200) {
  const st = { cancelled: false };
  return {
    st,
    res: new Response(
      new ReadableStream({
        start(c) {
          c.enqueue(enc.encode(json));
        },
        cancel() {
          st.cancelled = true;
        },
      }),
      { status },
    ),
  };
}
// Browser-shaped: body stream errors with AbortError when the request signal aborts.
function abortErroringResponse(prefix, signal, status = 200) {
  const st = { errored: false, cancelCalled: false };
  const res = new Response(
    new ReadableStream({
      start(c) {
        c.enqueue(enc.encode(prefix));
        signal.addEventListener(
          "abort",
          () => {
            st.errored = true;
            try {
              c.error(new DOMException("The user aborted a request.", "AbortError"));
            } catch {
              /* already closed */
            }
          },
          { once: true },
        );
      },
      cancel() {
        st.cancelled = true;
      },
    }),
    { status },
  );
  return { res, st };
}
function chunked(chunks, status = 200) {
  return new Response(
    new ReadableStream({
      start(c) {
        for (const ch of chunks) c.enqueue(typeof ch === "string" ? enc.encode(ch) : ch);
        c.close();
      },
    }),
    { status },
  );
}

const onlyCases = (process.env.S4_PROBE_CASES ?? "").split(",").filter(Boolean);
const run = (n) => onlyCases.length === 0 || onlyCases.includes(n);
let failure = null;
try {
  // ---------------- C1 pairing: complete JSON, never-closing stream ----------
  if (run("C1")) {
    const sent = [];
    const { res, st } = completeButOpen(
      JSON.stringify({ access_token: SECRET + "-A", refresh_token: SECRET + "-R", chosen_platform: "truecoach" }),
    );
    let reqSignal = null;
    const p = pairing.redeemPairingCode("123456", {
      fetch: async (_u, init) => {
        reqSignal = init.signal;
        return res;
      },
      sendMessage: async (m) => {
        sent.push(m.kind);
        return { ok: true };
      },
    });
    let state = "pending";
    p.then(() => (state = "resolved"), () => (state = "rejected"));
    await tick();
    const live = pending.size;
    const w0 = warnLines.length;
    fireDeadlines();
    await tick();
    const value = await settleOr(p);
    await tick(10);
    record({
      case: "C1 pair: complete JSON, stream never closes, deadline fires",
      liveDeadlineBeforeFire: live,
      stateAfterDeadline: state,
      value,
      requestSignalAborted: reqSignal?.aborted ?? null,
      streamCancelRequested: st.cancelled,
      sessionEstablishedSentAfterSettle: sent.length,
      events: eventsSince(w0),
    });
    if (isCandidateShape) {
      assert.equal(live, 1, "pair deadline must be live while body is open");
      assert.equal(value.ok, false);
      assert.equal(value.error, "That took too long. Check your connection and try again.");
      assert.equal(sent.length, 0, "late-parsed complete body must not establish a session");
      assert.equal(st.cancelled, true, "deadline must cancel the body stream");
    }
  }

  // ---------------- C1 refresh: complete JSON, never-closing stream ----------
  if (run("C1")) {
    store.clear();
    store.set("tgp_refresh_token", "R-c1");
    fetches.length = 0;
    const { res, st } = completeButOpen(
      JSON.stringify({ access_token: SECRET + "-LATE", refresh_token: SECRET + "-ROT" }),
    );
    fetchImpl = async () => res;
    const p = session.refreshAccessToken();
    let state = "pending";
    p.then(() => (state = "resolved"), () => (state = "rejected"));
    await tick();
    const live = pending.size;
    const w0 = warnLines.length;
    fireDeadlines();
    await tick();
    const value = await settleOr(p);
    await tick(10);
    const storedAfter = store.get("tgp_refresh_token");
    // The next getAccessToken must have to refresh again (nothing committed).
    fetchImpl = async () => chunked([JSON.stringify({ access_token: "A-fresh" })]);
    const fresh = await settleOr(session.getAccessToken());
    record({
      case: "C1 refresh: complete JSON, stream never closes, deadline fires",
      liveDeadlineBeforeFire: live,
      stateAfterDeadline: state,
      value,
      streamCancelRequested: st.cancelled,
      storedRefreshAfter: storedAfter,
      nextGetAccessToken: fresh,
      fetchesTotal: fetches.length,
      events: eventsSince(w0),
    });
    if (isCandidateShape) {
      assert.equal(live, 1);
      assert.equal(value, null, "stalled refresh must settle null");
      assert.equal(storedAfter, "R-c1", "late rotation must not be committed");
      assert.equal(fresh, "A-fresh", "late access token must not be published");
      assert.equal(fetches.length, 2);
    }
  }

  // ---------------- C2 browser-shaped abort (stream errors on abort) --------
  if (run("C2")) {
    const sent = [];
    let reqSignal = null;
    let holder = null;
    const w0 = warnLines.length;
    const p = pairing.redeemPairingCode("123456", {
      fetch: async (_u, init) => {
        reqSignal = init.signal;
        holder = abortErroringResponse('{"access_token":"' + SECRET, init.signal);
        return holder.res;
      },
      sendMessage: async (m) => {
        sent.push(m.kind);
        return { ok: true };
      },
    });
    await tick();
    fireDeadlines();
    await tick();
    const value = await settleOr(p);
    await tick(10);
    const events = eventsSince(w0);
    const leaked = warnLines.slice(w0).some((l) => l.includes(SECRET));
    record({
      case: "C2 pair: body stream errors with AbortError on deadline abort (browser-shaped)",
      value,
      requestSignalAborted: reqSignal?.aborted ?? null,
      streamErrored: holder?.st.errored ?? null,
      events,
      spuriousCancelFailedLogged: events.includes("auth_body_cancel_failed"),
      bodyBytesInConsole: leaked,
      sessionEstablishedSent: sent.length,
    });
    if (isCandidateShape) {
      assert.equal(value.ok, false);
      assert.equal(value.error, "That took too long. Check your connection and try again.");
      assert.equal(leaked, false, "no body bytes may reach console output");
      assert.equal(sent.length, 0);
    }
  }
  // C2 refresh variant
  if (run("C2")) {
    store.clear();
    store.set("tgp_refresh_token", "R-c2");
    fetches.length = 0;
    let holder = null;
    const w0 = warnLines.length;
    fetchImpl = async (_u, init) => {
      holder = abortErroringResponse('{"access_token":"' + SECRET, init.signal);
      return holder.res;
    };
    const p = session.refreshAccessToken();
    await tick();
    fireDeadlines();
    await tick();
    const value = await settleOr(p);
    await tick(10);
    const events = eventsSince(w0);
    record({
      case: "C2 refresh: body stream errors with AbortError on deadline abort",
      value,
      streamErrored: holder?.st.errored ?? null,
      events,
      spuriousCancelFailedLogged: events.includes("auth_body_cancel_failed"),
      bodyBytesInConsole: warnLines.slice(w0).some((l) => l.includes(SECRET)),
      storedRefreshAfter: store.get("tgp_refresh_token"),
    });
    if (isCandidateShape) {
      assert.equal(value, null);
      assert.equal(store.get("tgp_refresh_token"), "R-c2");
    }
  }

  // ---------------- C3 byte bound across chunks -----------------------------
  if (isCandidateShape && run("C3")) {
    const part = '"' + "x".repeat(5990) + '"';
    const json = '{"a":' + part + ',"b":' + part + ',"c":' + part + ',"s":"' + SECRET + '"}';
    // split into ~6000-byte chunks
    const chunks = [];
    for (let i = 0; i < json.length; i += 6000) chunks.push(json.slice(i, i + 6000));
    const res = chunked(chunks);
    let err = null;
    try {
      await net.readBoundedJson(res, null);
    } catch (e) {
      err = e;
    }
    record({
      case: "C3 readBoundedJson: chunked body exceeding MAX_AUTH_BODY_BYTES",
      totalBytes: enc.encode(json).byteLength,
      chunkCount: chunks.length,
      maxAuthBodyBytes: net.MAX_AUTH_BODY_BYTES,
      errorName: err?.name ?? null,
      errorMessage: err?.message ?? null,
      messageCarriesBytes: err ? err.message.includes("x".repeat(20)) || err.message.includes(SECRET) : null,
      bodyLockedAfter: res.body.locked,
    });
    assert.equal(err?.name, "BodyError");
    assert.equal(err.message, "body_invalid");
    assert.equal(res.body.locked, false);
    // exact boundary: a body of exactly MAX bytes parses; MAX+1 rejects
    const exact = '{"k":"' + "y".repeat(net.MAX_AUTH_BODY_BYTES - 8) + '"}';
    assert.equal(enc.encode(exact).byteLength, net.MAX_AUTH_BODY_BYTES);
    const ok = await net.readBoundedJson(chunked([exact]), null);
    assert.equal(typeof ok.k, "string");
    let over = null;
    try {
      await net.readBoundedJson(chunked([exact + " "]), null);
    } catch (e) {
      over = e;
    }
    record({ case: "C3b exact bound", exactBytesParsed: true, plusOneRejected: over?.name === "BodyError" });
    assert.equal(over?.name, "BodyError");
  }

  // ---------------- C4 UTF-8 split across chunks ----------------------------
  if (isCandidateShape && run("C4")) {
    const bytes = enc.encode('{"access_token":"é-ü-€","refresh_token":"r"}');
    // find the euro sign (3 bytes) and split in its middle
    const euro = enc.encode("€");
    let idx = -1;
    for (let i = 0; i < bytes.length - 2; i++) {
      if (bytes[i] === euro[0] && bytes[i + 1] === euro[1] && bytes[i + 2] === euro[2]) idx = i;
    }
    const a = bytes.slice(0, idx + 1);
    const b = bytes.slice(idx + 1);
    const parsed = await net.readBoundedJson(chunked([a, b]), null);
    record({ case: "C4 UTF-8 multibyte split across chunks", parsedAccessToken: parsed.access_token });
    assert.equal(parsed.access_token, "é-ü-€");
    // invalid UTF-8 → BodyError, no bytes
    let bad = null;
    try {
      await net.readBoundedJson(chunked([new Uint8Array([0x7b, 0xff, 0xfe, 0x7d])]), null);
    } catch (e) {
      bad = e;
    }
    record({ case: "C4b invalid UTF-8", errorName: bad?.name ?? null, message: bad?.message ?? null });
    assert.equal(bad?.name, "BodyError");
  }

  // ---------------- C5 establish queued before refresh snapshot -------------
  if (run("C5")) {
    store.clear();
    store.set("tgp_refresh_token", "R-old");
    fetches.length = 0;
    // park every refresh on the network until released
    const releases = [];
    fetchImpl = () =>
      new Promise((r) => {
        releases.push(r);
      });
    // establishSession is queued on the state lock FIRST; refreshAccessToken is
    // invoked synchronously afterwards (its snapshot runs after establish).
    const est = session.establishSession("A-new", "R-new");
    const a = session.refreshAccessToken();
    await est;
    await tick();
    const fetchesAfterA = fetches.map((f) => f.refreshToken);
    // second caller inside the fetch window
    const c = session.refreshAccessToken();
    await tick();
    const fetchesAfterC = fetches.map((f) => f.refreshToken);
    const parallelSameToken = fetchesAfterC.length === 2 && fetchesAfterC[0] === fetchesAfterC[1];
    // release both (if two) with rotations
    releases.forEach((r, i) =>
      r(chunked([JSON.stringify({ access_token: `A-m${i}`, refresh_token: `R-rot${i}` })])),
    );
    const va = await settleOr(a); const vc = await settleOr(c);
    record({
      case: "C5 coalescer: establishSession queued before refresh snapshot, then second caller",
      fetchesAfterFirstCaller: fetchesAfterA,
      fetchesAfterSecondCaller: fetchesAfterC,
      parallelPresentationOfSameRefreshToken: parallelSameToken,
      resultA: va,
      resultC: vc,
      storedRefreshAfter: store.get("tgp_refresh_token"),
      note: "observation only; not asserted",
    });
  }

  // ---------------- C6 same-epoch coalescing sanity (both roots) ------------
  if (run("C6")) {
    store.clear();
    store.set("tgp_refresh_token", "R-k");
    fetches.length = 0;
    let release = null;
    fetchImpl = () =>
      new Promise((r) => {
        release = r;
      });
    const all = Promise.all([session.refreshAccessToken(), session.refreshAccessToken()]);
    await tick();
    release(chunked([JSON.stringify({ access_token: "A-k" })]));
    const vals = await all;
    record({ case: "C6 same-epoch coalescing", vals, fetches: fetches.length });
    assert.equal(fetches.length, 1);
  }
} catch (e) {
  failure = { name: e.name, message: e.message };
}
await tick(10);

const result = {
  head,
  root,
  cases: onlyCases.length ? onlyCases : "all",
  candidateShape: isCandidateShape,
  observations,
  unhandledRejections: unhandled,
  pass: failure === null && unhandled === 0,
  failure,
  scope:
    "actual shipped modules of the named root; real Response bodies on synthetic ReadableStreams; intercepted timers; single Node process; no browser, no network, no dependencies, no worktree writes",
};
writeFileSync(out, JSON.stringify(result, null, 2));
console.log(JSON.stringify(result, null, 2));
process.exit(result.pass ? 0 : 1);
