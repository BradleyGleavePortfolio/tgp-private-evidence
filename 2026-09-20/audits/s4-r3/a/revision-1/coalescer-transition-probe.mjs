// Independent audit A: no network, no dependencies, no source mutation.
// Pending establish is intentionally overlapped with an auth refresh request.
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
import { resolve } from "node:path";
import { execFileSync } from "node:child_process";
const root = resolve(process.argv[2]);
const flush = async () => { for (let i = 0; i < 40; i++) await Promise.resolve(); };
let releasePersist;
const persistBarrier = new Promise(r => { releasePersist = r; });
const store = new Map([["tgp_refresh_token", "OLD_SYNTHETIC_REFRESH"]]);
let delaySet = true;
globalThis.chrome = { storage: { session: {
  get: async key => store.has(key) ? { [key]: store.get(key) } : {},
  set: async obj => {
    if (delaySet) await persistBarrier;
    for (const [k,v] of Object.entries(obj)) store.set(k,v);
  },
  remove: async key => { store.delete(key); },
} } };
const fetches = [];
const releases = [];
globalThis.fetch = async (_url, init) => {
  fetches.push(JSON.parse(init.body).refresh_token);
  return new Promise(r => releases.push(r));
};
const session = await import(pathToFileURL(resolve(root,"shared/session.js")));
// A trusted session_established handler begins persisting a new session.
const established = session.establishSession("NEW_SYNTHETIC_ACCESS", "NEW_SYNTHETIC_REFRESH");
await flush();
// An already outstanding ingest 401 may request refresh during storage.set.
// It queues its snapshot behind establish, so will read the NEW session.
const queuedRefresh = session.refreshAccessToken();
releasePersist();
delaySet = false;
assert.deepEqual(await established, {ok:true});
await flush();
assert.equal(fetches.length, 1);
// Another caller for the now-established session should join that same run.
const followingRefresh = session.refreshAccessToken();
await flush();
const observedFetches = [...fetches];
for (const r of releases) r(Response.json({
  access_token:"MINTED_SYNTHETIC_ACCESS", refresh_token:"ROTATED_SYNTHETIC_REFRESH"
}));
const results = await Promise.all([queuedRefresh, followingRefresh]);
console.log(JSON.stringify({
  head:execFileSync("git",["-C",root,"rev-parse","HEAD"],{encoding:"utf8"}).trim(),
  node:process.version,
  case:"refresh snapshot queues behind in-progress establish",
  actualNetwork:false,
  fetches:observedFetches,
  expectedFetchCount:1,
  observedFetchCount:observedFetches.length,
  sameEpochCoalescingPreserved:observedFetches.length===1,
  results,
  storedRefresh:store.get("tgp_refresh_token")
},null,2));
