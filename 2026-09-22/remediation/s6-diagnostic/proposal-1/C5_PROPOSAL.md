# S6 C5 — resource-ownership diagnostic: frozen proposal (NOT executed)

Worker: S6-DIAGNOSTIC-PROPOSAL. Scope: proposal/instrumentation only. No install, no test execution, no product/adapter/hazard-test byte change, no forceExit, no baseline retry. C1–C4 evidence untouched.

## 1. Restored candidate (verified)

| Item | Value |
|---|---|
| Bundle | `tgp-private-evidence/2026-09-21/remediation/s6-r3/checkpoint-1/s6-r3.bundle` SHA256 `c0ad2994f899775bd821029b62c1c492991bf1ddf1ab184ec0a88a9d7e439662` (matches brief); `git bundle verify` OK; prerequisite `a5933fd6` present in `source/mobile` |
| Worktree | `/home/user/workspace/worktrees/s6-diagnostic` (fresh clone of `source/mobile`, bundle fetched, branch `execute/20260921-s6-r3`) |
| HEAD / tree | `d51a191098f483cea9abec6cc7e9f3beffd18c06` / `62bf67b88e0f123f1a23ee34a1a75cb43029d9fb` |
| Ancestry | public `a5933fd6…` is an ancestor; 15 commits above it; d51 author+committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no AI trailer |
| Status | clean (`git status --porcelain` empty); **no `node_modules`** (fresh sandbox; C1's install is historical) |
| Toolchain seen | node v20.20.1, npm 10.8.2; lockfile blob `6c56385d…` pins jest 29.7.0, jest-expo 56.0.4, RN 0.85.3, React 19.2.3, RNTL 14.0.0, @tanstack/* 5.100.14, async-storage 3.1.1 |

## 2. Exact unresolved ownership question

After the unchanged v4 hazard file passes 6/6, **which object still holds a referenced libuv/timer resource in the in-band Jest process, and is that object (a) constructed by the test harness (hazard test, adapter, RNTL/React under the preset), (b) a production module-level object of the shipped composition (`queryClient.ts` singleton `queryClient` / `asyncStoragePersister`, `authActions.signOut` path), or (c) the runner/preset itself?**

Why C4 could not answer it (read from the pinned `@jest/core@29.7.0/build/collectHandles.js`, saved in `lib-src/`): the collector skips `PROMISE` inits entirely and records a resource only if its own creation stack contains a test-file/circus frame **or** its `triggerAsyncId` is a resource *currently* in its map. Node runs an `await` continuation after the fired timer's `destroy` hook, with the awaited PROMISE as execution context. So **every timer armed after an `await` inside library code** (asyncThrottle waits, `scheduleGc` reached from `hydrate` after `restoreClient`, retryer sleeps, notifyManager flush callbacks) is invisible to `--detectOpenHandles` even while it keeps the loop alive. C4's empty report therefore neither proves absence nor names an owner.

## 3. Source reasoning before proposing another detector (static, d51 + pinned libs)

- Product modules reached by the suite (`queryClient.ts`, `authActions.ts`, `lib/userCache.ts`, `storage/mmkv.ts`, `utils/logger.ts`, `utils/authEvents.ts`, four zustand stores, mirrors, `secureStorage.ts`) contain **no** `setTimeout/setInterval/addEventListener/AppState/NetInfo` (rg sweep on the restored tree; confirms C3's sweep).
- `@react-native-async-storage/async-storage@3.1.1/jest` mock is a plain in-memory `Map` class with `async` methods — no `jest.fn`, no timers; every `getItem/setItem/removeMany/clear` settles in a microtask. So `asyncThrottle`'s `while (isExecuting) await setTimeout(1000)` **cannot loop forever** from storage (H-A "infinite throttle loop" is falsified statically); the throttle can only leave **one pending ≤1000 ms wait per cache event burst**.
- query-core 5.100.14 timer sites (saved `lib-src/query-core_*`): `Removable.scheduleGc` (gcTime; queryClient default **600000**, bare `new QueryClient()` default **300000** because `window` is defined under the RN env), `QueryObserver` stale timeout (`staleTime+1`; `me` uses `Infinity` → none) and refetchInterval (none), `retryer.sleep` (only on rejection; `me`'s queryFn never settles), `notifyManager` `setTimeout(0)` flush, `queryClient.mount()` focus/online listeners (no-ops: no `window.addEventListener` in the env). `Query.destroy()` = `clearGcTimeout()` + `cancel({silent:true})`, and `queryCache.clear()` destroys every query — so any surviving gc timer belongs to a Query **created after** the last `clear()` (e.g. a late `hydrate` from a restore, or a late `setQueryData`).
- `PersistQueryClientProvider` restores once per mount and resubscribes on `[client, isRestoring]`; unmount unsubscribes. `asyncStoragePersister` is a **module-level singleton created at import** (`queryClient.ts:129`) and is never retired by anything in production or in the harness.

Net: statically every known timer settles, yet C2/C3/C4 hung three times. The owner is therefore only observable at runtime, with an instrument that (i) keeps PROMISE ancestry, (ii) fingerprints each live timer by delay/callback, and (iii) also reads Node's own view (`process.getActiveResourcesInfo()`, `_getActiveHandles()`) for non-timer types.

## 4. Falsifiable hypotheses and the observation that settles each

| ID | Hypothesis | Observation that confirms | Observation that refutes |
|---|---|---|---|
| H-A' | Self-re-arming ≤1000 ms `Timeout` chain in `asyncThrottle`/`timeoutManager` (singleton persister) | across ticks: same signature (delay ≤1000, native resolver cb, `asyncThrottle` frame) with **fresh asyncIds**; chain `Timeout†←PROMISE←Timeout†…` | no live ≤1000 ms timer at globalTeardown+ticks |
| H-B | A `Query` alive in the production `queryClient` after teardown (gc timer) | live `Timeout` delay **600000**, `cbName=optionalRemove`-class (`() => { this.optionalRemove() }`), sandbox deferred snapshot lists ≥1 query | sandbox deferred snapshot: `queries: []`, no 600000 timer |
| H-B' | Harness temp `QueryClient` (v4 regression of C2's finding) | live `Timeout` delay **300000**, root owner `harness` | none present |
| H-C | RN/jest-expo preset construct (module-load timers/intervals, `repeat` set) | owner `preset`, created before first test, or step A also hangs | step A exits (rc 0, `beforeExit`) |
| H-D | Non-timer resource (MessagePort/Worker/ChildProcess/FSReq/socket) | `activeResourcesInfo`/`nativeHandles` show the type; inventory `type≠Timeout` | only `Timeout`/stdio types |
| H-E | Runner/Node-level retention with zero user-attributable resources | `liveRefedCount=0`, no `beforeExit`, rc 124 | any live refed tracked handle |

## 5. Discriminating observation: harness vs production ownership

For every live **refed** resource at `globalTeardown`, `tick+1..70 s` and `SIGTERM`, the inventory records: type, delay, `repeat`, callback name/source head, 60-frame creation stack, frame categories, and the trigger chain through live+destroyed records (incl. PROMISE ids). Frame categories: `harness` (hazard test/adapter/jest.setup), `product` (`<wt>/src/**` excluding `__tests__`, `App.tsx`), `tanstack`, `preset` (react-native/expo/RNTL/react/scheduler), `runner` (jest*), `node`, `diag`. `owner` = first non-node, non-tanstack frame; `rootOwner` = deepest chain ancestor with a non-library owner.

Decision rule (proposal; parent/independent reviewer decides):
- **Production ownership** if (1) step B or D hangs (production code alone retains a resource), or (2) in step C a live refed handle has `owner=product` or `rootOwner=product`, or (3) a live `Timeout` of **600000 ms** exists (a Query alive inside the shipped singleton client after `clear()`), or (4) H-A' pattern is confirmed on the singleton persister **and** D shows the same pattern.
- **Harness ownership** if A, B, D all exit on their own (rc 0, `beforeExit`) and every live refed handle in C has `owner∈{harness, preset}` or `rootOwner=harness` (incl. any 300000 ms timer, RNTL/React scheduling, test `setTimeout`s).
- **Runner/environment** if A hangs, or C has `liveRefedCount=0` yet no `beforeExit`.
- **Mixed / inconclusive**: report both classes verbatim; no fix inferred.

Perturbation controls built in: A (preset+instrument, nothing else), B (shipped module import only), D (shipped persistence lifecycle, no React/act/signOut), C (unchanged v4 bytes). The instrument must preserve C's six behavioral assertions and zero `overlapping act`; C exiting cleanly under the instrument is recorded as `C-PERTURBATION-DIVERGENCE`, not acceptance. Step 0 (`s6diag.selftest.js`, pure Node, ≤1.5 s, no node_modules) proves the instrument sees an await-re-armed chain, recovers a gc-style callback name, and excludes unref'd timers, then exits 0 on its own.

## 6. Setup prerequisite (separate grant; not run)

```
cd /home/user/workspace/worktrees/s6-diagnostic && \
  CI=1 taskset -c 0,1 timeout 1200 npm ci --no-audit --no-fund --loglevel=error \
  > /home/user/workspace/execution/s6-diagnostic/logs/c5.npm-ci.log 2>&1; echo rc=$?; git status --porcelain | wc -l
```
Same invocation as C1 (394 s, 1099 packages then); must leave the tree clean; `/home/user/{node_modules,package.json}` must remain absent (runner refuses otherwise). Nothing in this proposal needs any other dependency, network or DB.

## 7. Run request (after setup; parent grant)

```
setsid nohup flock -n /home/user/workspace/execution/test-validation.lock \
  bash /home/user/workspace/execution/s6-diagnostic/run-c5-resource-inventory.sh \
  > /home/user/workspace/execution/s6-diagnostic/logs/run-c5.out 2>&1 < /dev/null &
```
Jest invocation per step (from the runner): `taskset -c 0,1 timeout -k <grace> <budget> node node_modules/jest/bin/jest.js <spec> --ci --runInBand --verbose --setupFilesAfterEnv=<wt>/jest.setup.js --setupFilesAfterEnv=<diag>/s6diag.setupAfterEnv.js --globalSetup=<diag>/s6diag.globalSetup.js --globalTeardown=<diag>/s6diag.globalTeardown.js` with env `S6DIAG_LOG/S6DIAG_STEP/S6DIAG_WT`. `node …/jest.js` directly (no `npx`) so `timeout`'s SIGTERM lands on the Jest process and the instrument's SIGTERM snapshot fires, then re-raises SIGTERM with default disposition (exit 143 → rc 124 preserved).

Budgets: selftest 15+5 s; A 45+15; B 45+15; D 60+15; C 90+20; outer 360 s. Expected typical: A/B/D ≈15 s each and exit 0; C ≈20–30 s tests then hang to 90 s (rc 124 **expected and preserved** as the real first exit). Cleanup: `timeout -k` per step; runner then lists/TERMs/KILLs only leftovers of its **own process group**, records survivors; never signals unowned processes. Stop-on-first-unexplained-failure: selftest≠0, A≠0 (or no `beforeExit`), B∉{0}, D∉{0} (D hang stops by default; `S6DIAG_CONTINUE_AFTER_D_HANG=1` lets C run), manifest mismatch (re-attribution needed). Untracked copies (5 files) stay declared in `c5.fingerprint.txt`, as in C2–C4.

Outputs (`execution/s6-diagnostic/logs/`): `c5.EXIT_RECORD`, `c5.provenance.txt`, `c5.manifest-check.txt`, `c5.module-paths.txt`, `c5.fingerprint.txt`, `c5.selftest.{out,inventory.jsonl}`, per step `c5.<A|B|D|C>.{jest.log,inventory.jsonl,summary.txt}`, `c5.C.checks.txt`, `run-c5.out`.

Positive criteria (diagnostic succeeded, not product acceptance): selftest 0; A rc 0 + `beforeExit`; B rc 0; D rc 0 or a documented hang; C `Tests: 6 passed, 6 total`, `overlapping_act 0`, `[mode=d51-singleton]`, rc 124, and at least one snapshot after `globalTeardown` with `liveRefedCount≥1` **or** `liveRefedCount=0` (H-E) — either way an attributable answer. Negative: any divergence above, or empty inventory (instrument did not observe the Jest process → `runInBand=false` warning in the log).

## 8. Frozen bytes (also in `MANIFEST.sha256`, non-self-including)

| File | SHA256 |
|---|---|
| `run-c5-resource-inventory.sh` | `f18faad9246e80ec9c1fb8a5c2cf104d8270e4c3c72e1e2bece396c7e5c2fbe1` |
| `diag/s6diag.main.js` | `00e802620a54975bfef01f84bab1b2cf25108941b3e2b305bba82e0b7d6bfb52` |
| `diag/s6diag.globalSetup.js` | `c0e3f2bb495c83e0a68338f0b9325dfe2ddeeb4972492621752f15ef0b77ab9c` |
| `diag/s6diag.globalTeardown.js` | `5b4d6766886a3f1a79877d1d428c15fb5750df2c5ae83b9bf8e71fa693e43e42` |
| `diag/s6diag.setupAfterEnv.js` | `88d9dd8b4f870ba8938a2b8f5b4a6141f1121438e0b6ca334e03f8e973708846` |
| `diag/s6diag.selftest.js` | `2ac7ccaaa785a5a921c2b15e7f5a292b67358d5793f04d3498c5c0fadeb4aff3` |
| `diag/s6diag.summarize.js` | `cbf26855a95d8496214534b8ad6c0a2a5b35de5f621b50d82db3f19c27e16e06` |
| `diag/specs/s6diag.A.noop.test.js` | `e8c07fccaf6e22da52aea533bb923f2522abe7a444542c3acc40c34a11b8d06c` |
| `diag/specs/s6diag.B.importOnly.test.js` | `78f98d1a59cbc20c7bbd4937ca04f0be28caa71a58103a605f8e168dbf2e3630` |
| `diag/specs/s6diag.D.persisterLifecycle.test.js` | `6a3be8a84da724746bbdd4dea8319cf7e21d4c4ac1a98acfb76bfc30d65095c8` |
| `inputs/persistedQueryCache.hazardControls.test.tsx` (v4, unchanged) | `ee9b94df1ceae5d90ad53700f119b75b0a2e9a6640339c27e2dca29d1f51bba6` |
| `inputs/persistedQueryCache.hazardAdapter.tsx` (unchanged) | `3796be8fae738993bcc5c30dd7d4cf9b303329b8faa990ca03e31c2460cd35f3` |

Checks performed here: `node --check` on all six `.js` diag files, ESM syntax check of the three specs (as `.mjs` copies), `bash -n` on the runner. Not performed: any execution of Jest, the selftest, or product code.

Qualifications: C4-RESULT.md referenced a prior worker's `handleInventory.setupAfterEnv.js` (sha `56042144…`) and `run-c5-handle-inventory.sh` (`12f53e2b…`); those bytes are **not** in the archive — the files above are a fresh implementation, not a recovery. The sandbox preload's `afterAll` may run before the hazard file's own `afterAll` (jest-circus declaration order); its unref'd deferred snapshots (+1.5/4/8 s) are what observe the cache after the file's synchronous final `clear()/unmount()`. Diag files live outside the worktree and are transformed by the project's `babel.config.js` via jest-expo's babel-jest; they are plain CommonJS so the transform is a no-op in effect.

## 9. What a result would and would not authorize (no fix applied here)

- H-A'/H-B on the singleton → a **test-only** drain/teardown in the adapter or hazard file would be the smallest next candidate, and the same lifetime defect is P1-relevant evidence (import-time singleton never retired); no product edit without parent scope and dual T4 review.
- H-B' → v4 helper regression, test-only.
- H-C/H-E → runner-level disposition by parent (mock/preset or Jest process), never `--forceExit` by this lane.
- Success of C5 does not prove a clean baseline, P1 closure, account isolation, native startup or release readiness.
