// No source edits, browser, real network, dependencies, or real credentials.
// Deterministic timers: inspect the actual 15s deadline registration/clearing,
// then advance all still-live deadlines. Native timers are only observation ticks.
import { writeFileSync } from "node:fs";
import assert from "node:assert/strict";
const root = process.env.S4_PROBE_ROOT ?? "/home/user/workspace/worktrees/s4";
const realSetTimeout = globalThis.setTimeout;
const realClearTimeout = globalThis.clearTimeout;
const pendingTimers = new Map();
const timerTrace = [];
let nextId = 0;
globalThis.setTimeout = (fn, ms) => {
  const id = ++nextId;
  pendingTimers.set(id, fn);
  timerTrace.push({op: "set", id, ms});
  return id;
};
globalThis.clearTimeout = (id) => {
  timerTrace.push({op: "clear", id});
  pendingTimers.delete(id);
};
const tick = () => new Promise(r => realSetTimeout(r, 0));
// Real streamed Response parser: a valid JSON prefix arrives, stream stays open.
const stalledResponse = () => new Response(new ReadableStream({
  start(controller) { controller.enqueue(new TextEncoder().encode('{"access_token":')); }
}), {status: 200});
const {redeemPairingCode} = await import(`${root}/shared/pairing.js`);
const observations = [];
let pairState = "pending";
let pairSignal;
redeemPairingCode("123456", {
  fetch: async (_url, init) => {
    pairSignal = init.signal;
    return stalledResponse();
  },
  sendMessage: async () => { throw new Error("must not send partial body"); }
}).then(() => pairState = "resolved", () => pairState = "rejected");
await tick();
for (const fn of [...pendingTimers.values()]) fn();
await tick();
observations.push({case: "pair redeem headers received, JSON body never ends",
  state: pairState, liveDeadlineCount: pendingTimers.size,
  signalAborted: pairSignal.aborted, timerTrace: [...timerTrace]});
assert.equal(pairState, "pending");
assert.equal(pendingTimers.size, 0);

const store = new Map([["tgp_refresh_token", "synthetic-refresh"]]);
globalThis.chrome = {storage: {session: {
  get: async k => ({[k]: store.get(k)}),
  set: async obj => Object.entries(obj).forEach(([k,v]) => store.set(k,v)),
  remove: async k => store.delete(k)
}}};
let refreshFetches = 0;
globalThis.fetch = async () => {
  refreshFetches++;
  return stalledResponse();
};
const {refreshAccessToken, clearTokens, establishSession} = await import(`${root}/shared/session.js`);
let refreshState = "pending";
refreshAccessToken().then(() => refreshState = "resolved", () => refreshState = "rejected");
await tick();
for (const fn of [...pendingTimers.values()]) fn();
await tick();
await clearTokens();
await establishSession("synthetic-new-access", "synthetic-new-refresh");
let subsequentState = "pending";
refreshAccessToken().then(() => subsequentState = "resolved", () => subsequentState = "rejected");
await tick();
observations.push({case: "refresh body never ends; clear then establish then refresh",
  firstRefreshState: refreshState, subsequentRefreshState: subsequentState,
  refreshFetches, liveDeadlineCount: pendingTimers.size, timerTrace: [...timerTrace]});
assert.equal(refreshState, "pending");
assert.equal(subsequentState, "pending");
assert.equal(refreshFetches, 1);
globalThis.setTimeout = realSetTimeout;
globalThis.clearTimeout = realClearTimeout;
const result = {head: process.env.S4_PROBE_HEAD ?? "c5a5ae12c5b3c3e32a4601c99319ad7c0d980057", observations,
  scope: "actual shipped modules and actual Response.json on open synthetic ReadableStreams, deterministic timer interception; not a browser execution"};
writeFileSync(new URL(process.env.S4_PROBE_OUTPUT ?? "./auth-body-probe.json", import.meta.url), JSON.stringify(result, null, 2) + "\n");
console.log(JSON.stringify(result, null, 2));
