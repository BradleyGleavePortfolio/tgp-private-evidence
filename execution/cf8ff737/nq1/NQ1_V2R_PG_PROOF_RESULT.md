# N/Q1 v2r single real-PG proof — RESULT: **PASSED (rc=0, stage=done, 20/20)**

Grant: `execution/ce3748cb/NQ1_V2R_SINGLE_PG_PROOF_GRANT.md` (parent ~22:00Z; both delta attestations GO). Executor `n_q1_v2r_builder_mufyro9p`. Run exactly once; no retry was needed or made. No model/effort claim is made.

Candidate `29e60705d8c4e1228fd1d2f248c7e53b6b8e56dd` (tree `511710ee…`) on `s7-nq1`; runner `nq1/binding/nq1-pg-proof.sh` sha `aec602521f377a2b825026b1437fa57439794236321cb617129c48dc7e134756`, `BINDING.sha256` 3/3 OK immediately before the run.

## PRE-1 (receipt 25)
`nq1/runtime` → `nq1/runtime.v1-failed-61b93cff-20260924T204543Z`, rename only (`mv`, rc=0). The four v1 files hash identically before and after (`RECEIPTS.sha256` 78a01a75…, `jest.log` 83f2de3b…, `nq1-pg-proof.log` 96558929…, `nq1-pg-proof.sentinel` c63722df…). Nothing deleted. `clusters/nq1` did not exist (moot; recorded); `/home/user/pg17/clusters` was absent.

## Lock discipline (receipt 26)
Canonical `execution/test-validation.lock` was held by other lanes (UX-M1 jest, then UX-E1 `npm test`). The wrapper polled `flock -n … true` every 2 s from 20:46:04Z (72 polls) and launched the runner at 20:48:28Z, which took the lock itself (`flock -n`, its line 52). No lock was removed or broken.

## Terminal evidence (unchanged)
| item | value |
|---|---|
| command | `timeout -k 30 3600 bash execution/cf8ff737/nq1/binding/nq1-pg-proof.sh` from `/home/user/workspace`, `START 2026-09-24T20:48:28Z pid=10582` |
| sentinel `runtime/run/nq1-pg-proof.sentinel` | `RC=0 STAGE=done END=2026-09-24T20:54:50Z HEAD=29e60705d8c4e1228fd1d2f248c7e53b6b8e56dd` (sha `71cdad2d…`) |
| outer rc | `OUTER_RC=0 2026-09-24T20:54:50Z` |
| stages | `PRECONDITIONS_OK` 20:48:30Z (server `postgres (PostgreSQL) 17.6`, psql 18.6, jest 30.4.1, provenance `postgres_sha256=23cd1748…`) → `PREFLIGHT_OK` 20:48:31Z (ndir absent, port 55481 free, 0 postgres procs, worktree porcelain empty; c1/b/r clusters `ABSENT`, s5 `ABSENT`) → `FIXTURE_INIT rc=0` 20:48:42Z (`NQ1_FIXTURE_INIT_OK … cluster_name=nq1-disposable-pg17`) → `FIXTURE_START rc=0` 20:48:42Z → `OLD_ROOT rc=0` 20:48:44Z (head 7d2895e1) → `BOOTSTRAP rc=0` 20:48:53Z → `IDENTITY_OK` 20:48:54Z (`/home/user/pg17/clusters/nq1/pg-data`, 170006, `nq1-disposable-pg17`) → `JEST_START` 20:48:54Z → **`JEST_END rc=0` 20:54:49Z** → `FIXTURE_STOP rc=0` → `STOP_STATE_OK postgres_procs=0 port55481=free datadir_retained` → `POST s5_cluster=ABSENT unchanged` → `POST_OK` 20:54:50Z → `END rc=0 stage=done` |
| jest | `Test Suites: 1 passed, 1 total · Tests: 20 passed, 20 total · Time: 354.69 s` (`--config jest.rls.config.js test/rls-g2-nq1.spec.ts --runInBand --ci`) |
| in-spec identity | `PG17_DATABASE {"port":55481,"user":"postgres","owner":"postgres","super":false,"address":"127.0.0.1","version":"170006","database":"g2_nq1_disposable","bypassrls":true,"directory":"/home/user/pg17/clusters/nq1/pg-data"}` |

## Pass/fail matrix (receipt 27)
**PASS (20/20):** N01 (3.9 s), N02 (8.8 s), N03 (16.3 s), N04 (4.6 s), N05 (14.9 s; writer surfaced `409 reconstruction provenance conflict`, logged `PG17_N05_WRITER`), N06 (13.1 s), Q01 ×2, Q02 ×2, Q03 ×2, Q04 ×2, Q05 ×2 (20.6 s / 41.8 s), Q06 ×2, Q07 ×2.
**FAIL:** none.
The five v1 failures (N02, N03(a), N06, Q05 ×2) all pass on the corrected spec; `PG17_N03_QUERIES {"t_after_n":19,"n_paused_then_t":[11,12],"t_rollbacks_after_waiting":0,"n_after_t":17}`.

## Receipts
| file | sha256 |
|---|---|
| `runtime/run/jest.log` | `40988d89049f1a275739334f45163327b4e88de32d2d1750a9bdaaf4cf78c776` (runner-sealed in `runtime/run/RECEIPTS.sha256`, verifies OK) |
| `runtime/run/nq1-pg-proof.log` | runner-sealed `c748a5da989da731544fdebbf197f007a9f5dc3189789680d6fc1104b823d920` = the log **minus the final two lines** (`POST_OK`, `END`), which the runner appends after writing `RECEIPTS.sha256` (line 190, then `finish()`); this is the runner's design, identical to R's. Full-file sha at rest: `ca5d38039f5a4ba38e197f9a1cc22748c69e90492d25f408972ec1b50e2bba86` (554 lines). Recorded as C (evidence hygiene), no action. |
| `runtime/run/nq1-pg-proof.sentinel` | `71cdad2d5bb36dbe6edb9acab26b090ba1499f1b5694592c6dbe6a6b0eac37bd` |
| `receipts/25-pre1-runtime-rename.txt`, `26-v2r-pg-proof-run.{txt,stdout}`, `27-v2r-pg-proof-jest-matrix.txt` | sealed in `receipts/RECEIPTS-v2r.sha256` (13/13 OK) |

## Cleanup / lane state after the run (read-only)
- `pgrep -cx postgres` = 0; port 55481 listeners 0; no `postmaster.pid`.
- `/home/user/pg17/clusters/nq1/pg-data` **retained, stopped** per runner (disposal only under a separate destroy grant). It is the only cluster in this sandbox.
- `runtime/old-root` detached at `7d2895e1` (T root), retained per runner.
- `s7-nq1` clean at `29e60705`; runner `POST` worktree check passed. `s7-c` untouched.
- Validation lock: released by the runner at exit; currently held by another lane (not this one). 4.6 GiB free.
- Nothing pushed; no remote write.

## Status
Grant consumed; single run, rc=0, all 20 cases pass on the exact candidate head with raw receipts. This is a local real-PG proof of N/Q1 on the isolated synthetic fixture; it claims no deployment, no drain of any real database, and no customer acceptance. Acceptance/landing is the parent's decision.
