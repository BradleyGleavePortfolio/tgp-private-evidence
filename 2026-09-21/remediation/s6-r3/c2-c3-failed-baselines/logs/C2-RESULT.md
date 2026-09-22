# C2-S6-BASELINE-V3 — result (frozen d51, v3 harness, adapter unchanged)
Runner sha 99781b6d…6f01 (as granted). START 00:42:31Z pid 19572 pgid 19570, lock held. provenance rc0, module-paths rc0 (12/12 inside <wt>/node_modules, c2.module-paths.txt), copy-v3 rc0 (test 785ac8d6… = v3 manifest, adapter 3796be8f… = staging manifest).

## Functional (Jest results, [mode=d51-singleton], 11.9 s) — 6/6 PASS, ZERO "overlapping act" warnings
- T-WIRING PASS · T0 PASS (authenticated write → `TGP_RQ_CACHE_V1:anonymous`)
- T1 (H1) PASS = hazard reproduced · T2 (H2) PASS = hazard reproduced · T3 (H3) PASS = hazard reproduced
- T4 (H6 positive control) PASS incl. cold remount `me`='none'
Log: c2.hazard-controls-d51.log (immutable).

## Process/runner failure (separate from functional)
"Jest did not exit one second after the test run" → open handle. Runner would have timed out at 300 s; parent authorised bounded cleanup: worker SIGTERM to the exact jest node child 19748 only, 00:44:09Z. Runner recorded step hazard-controls-d51 rc=143 → hazard-controls-d51-OPEN_HANDLES rc=7 → STOP_FIRST_FAILURE, FINAL rc=7; process group 19570 empty, lock FREE 00:44:13Z. Persister/signout controls NOT RUN.

## Residual open-handle owner (source-proven, not guessed)
`blobWith()` (test helper, used by T1/T2 to pre-seed a prior-session blob) does `new QueryClient(); tmp.setQueryData(...)`. query-core `Query` constructor calls `scheduleGc()` (query.js L36); with no `gcTime` option and `isServer=false` under jest-expo, `updateGcTime` defaults to 5*60*1000 (removable.js L21) → a real 5-minute setTimeout per temp client that nothing ever clears (the singleton `queryClient.clear()` teardown cannot reach `tmp`). The same helper exists in identityGate (`blobWith`) and rootNavigator (`blob`) v3.
Smallest causal fix (test-only, no assertion/GC-semantics change): `tmp.clear()` after `dehydrate(tmp)` — destroys the query → `clearGcTimeout`.

## Proposed C3 (not launched)
v4 = v3 + that one line in each of the three helpers: s6-p1/revisions/v4 (MANIFEST.sha256: hazard ee9b94df…, identityGate c1db284e…, rootNavigator 4349a816…). Runner logs/run-c3-baseline.sh sha 61c8d355…93f1 = C2 runner with v4 path + c3.* log names only (diff recorded). Bound: 300 s + 60 s; expected hazard file ≈12 s + clean exit, then the two existing controls. Causal proof = the "did not exit" line absent with identical 6/6 results.
