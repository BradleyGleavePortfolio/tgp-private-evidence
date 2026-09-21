// S4 R4 predecessor control for S4-R3-A-01 (adapted from audit A's
// coalescer-transition-probe). Dependency-free, no network, no source mutation.
// usage: node coalescer-admission-probe.mjs <repo-root>
// Expected: base 84471e99 FAILS (2 fetches, second caller null);
//           candidate PASSES (1 fetch, both callers minted).
import { pathToFileURL } from "node:url";
import { resolve } from "node:path";
import { execFileSync } from "node:child_process";
const root = resolve(process.argv[2]);
const flush = async () => {
  for (let i = 0; i < 40; i++) await Promise.resolve();
};
let releasePersist;
const persistBarrier = new Promise((r) => {
  releasePersist = r;
});
const store = new Map([["tgp_refresh_token", "OLD_SYNTHETIC_REFRESH"]]);
let delaySet = true;
globalThis.chrome = {
  storage: {
    session: {
      get: async (key) => (store.has(key) ? { [key]: store.get(key) } : {}),
      set: async (obj) => {
        if (delaySet) await persistBarrier;
        for (const [k, v] of Object.entries(obj)) store.set(k, v);
      },
      remove: async (key) => {
        store.delete(key);
      },
    },
  },
};
const fetches = [];
const releases = [];
globalThis.fetch = async (_url, init) => {
  fetches.push(JSON.parse(init.body).refresh_token);
  return new Promise((r) => releases.push(r));
};
const session = await import(pathToFileURL(resolve(root, "shared/session.js")));
const established = session.establishSession("NEW_SYNTHETIC_ACCESS", "NEW_SYNTHETIC_REFRESH");
await flush();
const queuedRefresh = session.refreshAccessToken();
releasePersist();
delaySet = false;
const establishResult = await established;
await flush();
const followingRefresh = session.refreshAccessToken();
await flush();
const observedFetches = [...fetches];
for (const r of releases)
  r(Response.json({ access_token: "MINTED_SYNTHETIC_ACCESS", refresh_token: "ROTATED_SYNTHETIC_REFRESH" }));
const results = await Promise.all([queuedRefresh, followingRefresh]);
const pass =
  establishResult.ok === true &&
  observedFetches.length === 1 &&
  observedFetches[0] === "NEW_SYNTHETIC_REFRESH" &&
  results.every((r) => r === "MINTED_SYNTHETIC_ACCESS") &&
  store.get("tgp_refresh_token") === "ROTATED_SYNTHETIC_REFRESH";
console.log(
  JSON.stringify(
    {
      probe: "coalescer-admission (S4-R3-A-01)",
      root,
      head: execFileSync("git", ["-C", root, "rev-parse", "HEAD"], { encoding: "utf8" }).trim(),
      node: process.version,
      actualNetwork: false,
      fetches: observedFetches,
      expectedFetchCount: 1,
      results,
      storedRefresh: store.get("tgp_refresh_token"),
      pass,
    },
    null,
    2,
  ),
);
process.exit(pass ? 0 : 1);
