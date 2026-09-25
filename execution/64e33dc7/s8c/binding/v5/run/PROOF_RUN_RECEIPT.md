# S8-C v5 PG proof — PROOF RUN RECEIPT (PG-4c, EXEC-DACEDDC8)

**Result: rc=0, stage=done, Jest 13 passed / 13 total.** One launch, no relaunch, no rerun. Grant: PG-4c
(`execution/daceddc8/SCOPE.md §PG-4c`), REV-3 dual GO (A `a63a80f8…`, B final GO). Executor: T4 builder
`s8c_bootstrap_completion`. Evidence repo not committed by the executor.

## Binding executed (all pins re-verified read-only at PREFLIGHT 17:38:10Z before launch)
| item | value |
|---|---|
| head / tree | `f428db9ab65f638da1651b8cd792c6f93b4983c1` / `f2623be642ddfbba025ffe8360256a683ac57997` (parent `4d7d4b4e…`, porcelain 0 before and after) |
| blobs | bootstrap `7c3fba471f991e3750eb56fd29e271101652196e`, harness `1a8f17970a1095f9b802badacf093e773caabd76`, spec `9d701783eeb7701126d158b45bfee3d5f0f686b3` |
| driver `binding/v5/s8c-pg-proof.sh` | `b641db2d5fae07d9220e573a04cb512c5ec35814b08ae7c506c02499c314fd1d` |
| fixture `binding/v5/s8c-fixture.sh` | `34a42ab8b2ffa75256f5fa600ca7a51bcdb3ae1f224ad989ff1ca7a4dd716f10` |
| `binding/v5/BINDING.sha256` | `2995ed837fd352e3ea663949cc74e66ca5eec4566444739e8b7f53aab87c9eba` (10/10 OK before and after) |
| supervisor `run-prep/supervisor.sh` | `5407d27458ea705c471dda2c328067ea0219233769826383e5f8770b099eabec` (`S8C_PG5_GRANT=1`) |
| lane | `recovery-reset/proof-v5/clusters/s8-c` (fresh initdb), socket `proof-v5/run/s8-c`, port 55642, cluster `s8c-disposable-pg17`, PostgreSQL 17.6 (`170006`), Node v20.20.1, Jest 30.4.1, Prisma 6.19.3 |

## Slot and launch discipline
- Parent preflight 17:33:19Z found the canonical slot held by the E2 extension gates (`git` pid 1072 under `npm run gates`, `run-gates.sh` pid 18831 — observed read-only 17:33:42Z). Polled read-only at 60 s: 17:34:47Z, 17:35:47Z, 17:36:47Z, 17:37:47Z → 0 holders; gates processes gone by 17:38:0xZ.
- PREFLIGHT §A/§B re-run 17:38:10Z: all pins equal; lock inode 674373, 0 holders, 0 postgres, 55641/55642/55644 free, `proof-v5` lane+socket absent, `binding/v5/run` absent, LAUNCH/LAUNCHER absent, v4 lane retained with no `postmaster.pid`.
- Single launch 17:38:29Z: `cd binding/v5/run-prep && S8C_PG5_GRANT=1 bash supervisor.sh` → `LAUNCHED supervisor_pid=5077`; driver pid 5104 under `timeout -k 30 3900`. Lock taken by the driver `flock -n` (fd 9, inode 674373) and held through its END. No refusal, no second invocation.

## Timeline (UTC, from `s8c-pg-proof.log` / `LAUNCHER.txt`)
| stage | time |
|---|---|
| START (lock held) | 17:38:29 |
| PRECONDITIONS_OK | 17:38:31 |
| PREFLIGHT_OK (other lanes hashed: `proof-v4/clusters/s7l`, `proof-v4/clusters/s8-c`; `clusters/` dir absent) | 17:38:33 |
| FIXTURE_INIT rc=0 / FIXTURE_START rc=0 (pid 5635) | 17:38:38 |
| BOOTSTRAP rc=0 — `G2_S8C_BOOTSTRAP_OK`, 171 migrations applied, `CANDIDATE_CLIENT_VERIFIED` (engine `a2924eab…`) | 17:38:42 |
| IDENTITY_OK (data_directory = v5 lane, server 170006, cluster s8c-disposable-pg17, 171 applied) | 17:38:42 |
| JEST_START `jest --config jest.rls.config.js test/rls-g2-s8c.spec.ts --runInBand --ci` | 17:38:42 |
| JEST_END rc=0 (`Time: 39.632 s`) | 17:39:23 |
| FIXTURE_STOP rc=0 → STOP_STATE_OK (0 postgres, 55642 free, pg-data retained) | 17:39:23 |
| POST other_lanes_unchanged (both v4 lanes: pre-hash == post-hash) → POST_OK → END rc=0 stage=done | 17:39:23 |
| LAUNCHER_EXIT rc=0 → END rc=0 (total wall ≈ 54 s of the 3900 s bound) | 17:39:23 |

## Per-test results (`jest.log`, `PASS rls-live test/rls-g2-s8c.spec.ts (39.385 s)`)
| # | test | ms |
|---|---|---|
| 1 | is the S8-C disposable PG17 lane with the full accepted history and S8-B objects present | 404 ✓ |
| 2 | is bound to one attested candidate head that descends from the base | 281 ✓ |
| 3 | the worker exposes the canonical family list with programs (N3) and refuses an unknown family | 2300 ✓ |
| 4 | creates a WorkoutProgram from a programs row with workout_program provenance and ledger kind (N1, N4) | 1322 ✓ |
| 5 | creates a standalone WorkoutPlan with ordered exercises, exact catalog links and unresolved children | 1756 ✓ |
| 6 | replays byte-identical: no duplicate targets, no provenance drift, coach edits preserved | 2661 ✓ |
| 7 | program-day workouts: relationship pending until the program lands, then converge with revision 0 | 3542 ✓ |
| 8 | client-linked workout stays generic evidence with an unresolved provenance marker; no plan, no User | 2566 ✓ |
| 9 | the same source identifiers for two coaches yield separate targets; neither coach sees the other | 2866 ✓ |
| 10 | two concurrent identical runs converge on ONE plan; the loser rolls its target back with its transaction | 2493 ✓ |
| 11 | a held ledger identity blocks the writer; its first attempt (target included) rolls back and the retry converges | 1581 ✓ |
| 12 | legacy families and pre-existing NULL-kind ledger rows are untouched by the native writer | 2463 ✓ |
| 13 | a later-removed or archived native target does not downgrade the reconstructed ledger row and mints nothing new | 6618 ✓ |
`Tests: 13 passed, 13 total; Snapshots: 0`. The 46 `console.warn` blocks are the harness's designed `PG17_PROCESS` /
`PG17_BLOCKED` observability lines (query shapes, outcomes, pids only). The server log `proof-v5/clusters/s8-c/pg.log`
(18 lines, sha `d12ac3d7f52f4cb93468efdcbf3feb7b915984d932e02cc7681ce569c9c5cb38`) holds exactly two ERRORs — unique-key
violations on `ImportNativeProvenance_identity_key` (17:39:12) and `ScoutReconstructionLedger_identity_key` (17:39:13) —
the loser-rollback paths that tests 10 and 11 assert on.

## Post-state (17:40:29Z)
0 lock holders (inode 674373 unchanged), 0 postgres, 55641/55642/55644 free, no supervisor/driver process. v5 lane pg-data
retained (76 MB) without `postmaster.pid`; socket dir empty. v4 lanes byte-identical to pre-run hashes (driver POST) and
`proof-v4/clusters/s8-c` still has no `postmaster.pid`. Worktree head f428db9a, porcelain 0. `binding/v5/BINDING.sha256`
10/10 OK, `run-prep/RUN_PREP.sha256` OK.

## Receipts
- Driver `run/RECEIPTS.sha256`: `s8c-pg-proof.log` `e0bdcd508474ca4c1ba54cd8d4632d0898ad0d5817f97e113476021d7304c755`, `jest.log` `3687d40a7a50a9cfbe43aec9ea5ee8a4691a4a59ee1c25de53bb8c82d03c3956`.
- Supervisor `run-prep/LAUNCH_RECEIPTS.sha256`: `LAUNCH.txt` `d5b71833…`, `LAUNCHER.txt` `ebffc628…`, `driver.stdout` `9c58c6d6…`, `driver.stderr` `e3b0c442…` (empty).
- Known, by-design characteristic (identical in the consumed v4 run and inherent to the frozen driver/supervisor): each
  manifest hashes its log *before* the final `END` line is appended (driver L72 vs L74), so `sha256sum -c` reports
  `s8c-pg-proof.log` and `LAUNCHER.txt` as mismatched against the final files while `jest.log`, `LAUNCH.txt`,
  `driver.stdout/stderr` verify OK. Verified here: sha256 of each file **minus its last line** equals the recorded value
  exactly (`e0bdcd50…`, `ebffc628…`). `RUN_FREEZE.sha256` (below) pins the final bytes of every file.
- Sentinel `s8c-pg-proof.sentinel`: `RC=0 STAGE=done END=2026-09-25T17:39:23Z HEAD=f428db9a… LOCK_INODE=674373`.
- `RUN_FREEZE.sha256` (this directory): final shas of all `run/` and `run-prep/` files plus the lane's `pg.log`,
  `pg.log.pg_ctl` and `pg-data.initdb.log`.
