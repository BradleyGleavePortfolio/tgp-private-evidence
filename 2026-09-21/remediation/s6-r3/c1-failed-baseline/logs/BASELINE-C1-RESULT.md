# C1-S6-SETUP-BASELINE — result (d51a1910, 2026-09-22 00:17–00:28 UTC)

## Chronology (UTC)
- 00:17:04 grant registered; frozen staging snapshot `s6-p1-frozen-20260922T001704Z` (manifest 6/6 OK).
- 00:17:38 runner started detached (`setsid nohup flock -n <canonical lock> bash run-baseline.sh`), PID 21321, own session 21320; lock verified held from outside.
- 00:17:38 provenance OK: HEAD d51a1910, 0 dirty lines, committed `package-lock.json` blob 6c56385d, node v20.20.1 / npm 10.8.2.
- 00:17:38→00:24:12 `npm ci` (394 s). During it: parent notice of stray `/home/user/node_modules` (00:22); I SIGSTOPped only the runner bash at 00:22:4x (npm kept running); parent quarantine done 00:23:47; absence recorded 00:24:11 (`baseline.env-facts.txt`); SIGCONT 00:24:11. npm ci finished 1 s later with rc=0, tree still clean.
- 00:24:12 staged adapter + hazard controls copied untracked; fingerprints identical to staging (`3796be8f…`, `a31624ac…`); `git diff --stat HEAD` empty.
- 00:24:1x–00:24:40 hazard suite executed (jest 14.7 s). Module resolution recorded after install: all 12 probed packages resolve inside `<wt>/node_modules` (rq / rqpc / async-storage-persister 5.100.14, async-storage 3.1.1); ancestor root absent.
- Jest did not exit (open handles from never-resolving `queryFn`s / throttle timers) after printing results; I SIGTERMed the hung node (26031) at 00:28:02 as cleanup → runner recorded rc=143, STOP_FIRST_FAILURE, lock released. Step 4 (persister/signout controls) therefore did not run.

## Hazard baseline on d51 — mode `d51-singleton`, all six cases genuinely executed
| case | result | reading |
|---|---|---|
| T-WIRING | PASS | adapter mirrors App.tsx wiring |
| T0 fingerprint | PASS | authenticated write landed on `TGP_RQ_CACHE_V1:anonymous` (logged) |
| T1 (H1) | **PASS = hazard reproduced** | authenticated cold start restored B from the shared anonymous key |
| T2 (H2) | **PASS = hazard reproduced** | after token-missing logout, sign-in as C kept B in memory and re-persisted B's PII (`+1 555 0100`) under C's session |
| T3 (H3) | FAIL (assertion `onDisk('user-B') === true` got false) | **harness timing, not hazard absence** — see below |
| T4 (H6 positive control) | FAIL at the last probe only | first three assertions passed (nothing on disk, memory empty); the cold-remount probe `again.getByTestId('me')` found no element — **harness, unexplained statically** |

## T3 causal analysis (pinned `asyncThrottle`, 5.100.14)
Throttle semantics: `lastArgs = args; if (isScheduled) return; … wait until nextExecutionTime … await func(...lastArgs); nextExecutionTime = now + 1000`. In T3 the mount's `added` event executes at t0 (next = t0+1000); the warm `setQueryData` at t0+30 ms is *scheduled* and executes at t0+1000 (next = t0+2000). The test waited only 1.2 s after warm, so the late update inside `signOut` (≈t0+1250) was **scheduled, not immediate**; `queryClient.clear()` ~20 ms later overwrote `lastArgs`, and the single execution at t0+2000 wrote the empty snapshot. Hence no B on disk. H3 requires an *idle* throttle at the moment of the late update (stated precondition in the hazard map); the harness violated it. Correction: settle ≥ 2.1 s after warm (or assert idleness), same inputs, same assertion. Not applied — no retry without instruction.

## T4 causal analysis
Hazard-relevant assertions held (sign-out purges disk and memory). The failing probe is a second `render()` after `r.unmount()` inside the same test; `PersistQueryClientProvider` renders children unconditionally (lib line 52), so the missing `me` element is a harness/RNTL re-mount question I cannot settle statically. Needs one focused diagnostic run (not a weakened assertion): e.g. move the cold-remount probe into its own `it` or assert via `screen`.

## New pinned library fact (L8) relevant to the fix
`PersistQueryClientProvider` only calls `persistQueryClientSubscribe` once `isRestoring` is false (effect deps `[client, isRestoring]`); writes before restore completes are not persisted. My planned `createIdentityPersistence` subscribes after its own restore resolves — consistent.

## Artifacts
`logs/`: `run-baseline.sh`, `run-baseline.out`, `baseline.EXIT_RECORD`, `baseline.provenance.txt`, `baseline.npm-ci.log`, `baseline.fingerprint.txt`, `baseline.env-facts.txt`, `s6-p1-hazard-controls-d51.log`, `grants.log`. Worktree: HEAD d51a1910 clean apart from the two untracked control files (left in place, fingerprinted). `node_modules` installed from the committed lockfile.

## Addendum 00:35Z — read-only diagnosis (parent-authorized), no rerun
**T4 missing `me` — root cause found (harness):** RNTL 14.0.0 `render`/`rerender`/`unmount` are all async (`dist/render.js` L44-52) and its `act` always wraps callbacks as thenables (`dist/act.js` L67-69). v2 called `r.rerender(...)` (in `recommit`) and `r.unmount()` without `await`, so the next `act` overlapped. React 19.2.3 `popActScope` (react.development.js L554-559) logs "You seem to have overlapping act() calls" — present **6×** in the run log (2 per overlap: T2 recommit, T3 recommit, T4 recommit/unmount) — and leaves `actScopeDepth` at 1, after which completed acts take the `else resolve()` branch (L865) and never flush the act queue: subsequent renders/unmounts do not commit. Consequences: T4's `again` render never committed → no `me`; providers from T2 onward were never really unmounted (their persist subscriptions lived on across tests). T1 executed before any overlap and is valid; T2's assertions do not depend on rendering (memory + singleton persister) and are valid; **T3 and T4 executed under a corrupted React act scope and are not valid evidence either way**.
**T3 on-disk false — root cause (harness timing, still applies):** pinned `asyncThrottle` window: after the warm write executes, `nextExecutionTime = now+1000`; v2 waited 1.2 s from a write that itself executed ~1 s late, so the throttle was still busy when the late update landed inside `signOut`; `queryClient.clear()` then overwrote `lastArgs`, and the single execution wrote the empty snapshot. H3 requires an idle throttle (hazard-map precondition). Correction: wait 2.2 s (window provably open).
**Jest hang owner:** `queryClient` default `gcTime: 10 * 60_000` (`src/services/queryClient.ts` L45); `Removable.scheduleGc` arms a 10-minute `setTimeout` per query once unobserved. Because unmounts never committed (above), queries were never destroyed in-test and the final ones outlived the suite → Jest waited on a 10-min timer ("did not exit one second after"). Scoped cleanup: `await cleanup()` (now effective) + `queryClient.clear()` in `afterEach` and `clear()+unmount()` in `afterAll` (destroy clears gc timers). No `--forceExit`.
**Who TERMed and why:** I (worker) sent SIGTERM to the hung jest node PID 26031 at 00:28:02Z after the final results had printed (Tests: 2 failed, 4 passed, 6 total) so the runner could record an exit (rc=143) and release the canonical lock; not a retry.
**Proposed minimal test-only correction (v3, separate path, staged v2 untouched):** `s6-p1/revisions/v3/src/services/__tests__/persistedQueryCache.hazardControls.test.tsx` — (a) `await r.rerender / await r.unmount`, (b) `THROTTLE_IDLE_MS = 2200` replacing the 1200 ms settles, (c) scoped teardown above. Hazard assertions/inputs identical to v2. Adapter unchanged. Note for later: staged `identityGate` and `rootNavigatorPersistedCacheGate` suites carry the same unawaited-`rerender` defect and will need the same v3 treatment before they are run.
