# C single real-PG proof — RESULT: **PASSED (rc=0, stage=done, 22/22)**

Grant: `execution/ce3748cb/C_SINGLE_PG_PROOF_GRANT.md` (parent ~23:40Z; both attestations GO on 1b6cc661). Executor: C phase-1 re-draft builder (sole). Run exactly once; no retry was needed or made. No model/effort claim is made. Nothing pushed.

Candidate `1b6cc66164b3398d573ba92f0c8f6b039494be24` (tree `cea54631…`, parent 16cd67f4 → N/Q1 29e60705) on `s7-c`; runner `c/binding/c-pg-proof.sh` sha `cf462851ae988d616148d709e2afa7532a2ef0503cc3f1bd757b700acb674ef9`, `BINDING.sha256` 3/3 OK immediately before launch (wrapper log, receipt 18). Runner unchanged.

## Pre-state (grant preconditions)
`c/runtime` ABSENT, `/home/user/pg17/clusters/c-contract` ABSENT (no PRE rename needed), `pgrep -cx postgres` = 0, port 55491 free, `s7-c` porcelain empty at HEAD 1b6cc661 — all confirmed by me before launch and again by the runner's `PREFLIGHT_OK`.

## Lock discipline (receipt 18)
Wrapper polled `flock -n … true` on the canonical `execution/test-validation.lock`: free at the first poll (`LOCK_FREE_AFTER_POLLS=0`), launched the runner at 21:48:44Z, which took the lock itself (`flock -n`, its line 55). Lock file never removed or broken; still present.
Recorded slip (receipt 17): a first wrapper attempt failed its own `sha256sum -c` self-check by running it from the wrong cwd and exited 70 **before launching the runner** — nothing ran, no PG process, no `c/runtime`, no lock taken. Receipt 17 kept with a note; the corrected wrapper (receipt 18) is the only launch.

## Terminal evidence (unchanged)
| item | value |
|---|---|
| command | `timeout -k 30 3600 bash execution/cf8ff737/c/binding/c-pg-proof.sh` from `/home/user/workspace`, `START 2026-09-24T21:48:44Z pid=5572` |
| sentinel `runtime/run/c-pg-proof.sentinel` | `RC=0 STAGE=done END=2026-09-24T21:50:54Z HEAD=1b6cc66164b3398d573ba92f0c8f6b039494be24` (sha `334ea2a09205bc1f2c72ad5dca994c6cd6bebe553f81712bd1af6215455aa9b0`) |
| outer rc | `OUTER_RC=0 2026-09-24T21:50:55Z`; `END rc=0 stage=done` |
| stages | `PRECONDITIONS_OK` 21:48:47Z (server `postgres (PostgreSQL) 17.6`, psql 18.6, jest 30.4.1, provenance `postgres_sha256=23cd1748…` result=success) → `PREFLIGHT_OK` 21:48:47Z (cdir absent, port 55491 free, 0 postgres procs, worktree porcelain sha `e3b0c442…` = empty; s5/c1/b/r ABSENT; nq1 PRESENT_STOPPED conf `40ac76b2…` pg_control `c102d5b1…`) → `FIXTURE_INIT rc=0` → `FIXTURE_START rc=0` 21:48:49Z → `OLD_ROOT rc=0` 21:48:52Z head=29e60705 → `BOOTSTRAP rc=0` 21:49:02Z → `IDENTITY_OK` (data_directory `/home/user/pg17/clusters/c-contract/pg-data`, 170006, cluster `c-disposable-pg17`) → `JEST_START` 21:49:02Z → `JEST_END rc=0` 21:50:54Z → `FIXTURE_STOP rc=0` → `STOP_STATE_OK` → `POST_OK` → `END` |
| jest | `Test Suites: 1 passed, 1 total · Tests: 22 passed, 22 total · Time: 111.335 s` (`./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-c-contract.spec.ts --runInBand --ci`) |
| in-spec identity | `PG17_DATABASE {"port":55491,"user":"postgres","owner":"postgres","super":false,"address":"127.0.0.1","version":"170006","database":"g2_c_disposable","bypassrls":true,"directory":"/home/user/pg17/clusters/c-contract/pg-data"}` |
| C01 evidence | `PG17_C01 removed` = exactly the two narrow unique indexes (`ScoutIngestEntity_coach_id_intent_id_source_id_key`, `ScoutReconstructionLedger_coach_id_intent_id_entity_type_source…`); `PG17_LOCK_TIMEOUT {"file":"20270121000000_scout_identity_contract/migration.sql","elapsed":5033}` (C09a, bounded 5 s) |

## Pass/fail matrix
**PASS (22/22), in run order:** C02 (492 ms); C14a (601); C09a (5635); C01 (2898); C14b (2074); C03/C04 (308); C05 (348); C06 (2321); C07 (3110); C08 (9260); C09b (5835); C16 clients (15342); C16 workouts (11122); C17a (1160); C18 (D-C1) (3063); C11 (758); C12 (773); C13 (799); **C14c (2330)** — the B1-closed case, decoys refused and untouched; C15 (2447); C10 (14592); N/Q1 continues on C (7280).
**FAIL:** none. **Skipped:** none.
Cross-process writer evidence: `PG17_PROCESS` g2c_1..g2c_6 (candidate and old `29e60705` writers), `PG17_BLOCKED` observed for the held-transaction race (C08). Note: the earlier records said 21 `it`; Jest reports 22 because C16 is an `it.each` over the two families.

## Cleanup state (runner-observed, then re-checked by me)
| item | state |
|---|---|
| postmaster | stopped by the runner's bounded fixture stop (`FIXTURE_STOP rc=0`); `STOP_STATE_OK postgres_procs=0 port55491=free`; wrapper end `pgrep_postgres=0 listeners_55491=0`; no `postmaster.pid` in the data dir |
| data dir | **RETAINED** `/home/user/pg17/clusters/c-contract/pg-data` (destroy = separate marker-gated grant, not requested) |
| retained clusters | `nq1` unchanged (`POST nq1_cluster unchanged` conf/pg_control identical); s5 ABSENT unchanged; c1/b/r absent |
| worktree `s7-c` | clean (0 porcelain lines incl. untracked), HEAD still 1b6cc661; `s7-nq1` untouched |
| lock | `execution/test-validation.lock` present; released by the runner on exit |
| `c/runtime/run` | `c-pg-proof.log`, `jest.log`, `c-pg-proof.sentinel`, `RECEIPTS.sha256` (runner-sealed) |

## Receipts
| file | sha256 |
|---|---|
| `runtime/run/jest.log` | `75a2c4ea13d540b50523e507823d82919333a4bb6a33cb37e3a8d03807ab9fab` (runner-sealed in `runtime/run/RECEIPTS.sha256`, verifies OK) |
| `runtime/run/c-pg-proof.log` | runner-sealed `0739306ed3a07a61dc0f1e6a7f9095ee5d4f96a5acd76ea9263a016f671407c5` = the log **minus the final two lines** (`POST_OK`, `END`), which the runner appends after sealing (same pattern as the accepted N/Q1 run; verified: `head -n -2 | sha256sum` reproduces the sealed hash). Terminal file sha `dc32bf77362c43a44437c17bf5478124ef66f1aad17cb86c62a9ebb3e178b968` |
| `runtime/run/c-pg-proof.sentinel` | `334ea2a09205bc1f2c72ad5dca994c6cd6bebe553f81712bd1af6215455aa9b0` |
| `receipts/17-pg-proof-wrapper.log` | aborted wrapper self-check (runner not launched), kept |
| `receipts/18-pg-proof-wrapper.log` | full wrapper + runner stdout/stderr of the single run |
`receipts/RECEIPTS.sha256` resealed to include 17–18.

**Result: C real-PG proof PASSED on 1b6cc661, rc=0, stage=done, 22/22 cases green, cleanup complete (postmaster stopped, data dir retained). STOPPED.** No push; landing/PR is the parent's decision.
