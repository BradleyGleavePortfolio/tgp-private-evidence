# S8-C v4 PG proof — PROOF_RUN_RECEIPT (PG-4a, single invocation, TERMINAL: FAILED rc=1 stage=jest)

Executor: `s8c_bootstrap_completion` under grant PG-4a (`execution/daceddc8/SCOPE.md` §PG-4a, 16:49Z; dual GO `BOOTSTRAP_CORRECTION_REVIEW_A/B`). Written 2026-09-25 ~16:53Z, read-only after the run. **The one authorized invocation has been consumed. No rerun, no edit, no repair was made or is authorized by this receipt.** Result: the bootstrap correction closed (bootstrap rc=0), Jest was reached for the first time, and all 13 tests failed from one shared `beforeEach` harness error. No native-writer runtime behaviour was exercised; this run confers no acceptance of `e0cee7e0`.

## 1. Candidate identity (re-verified read-only at 16:48:39Z, immediately before launch — PREFLIGHT §A/§B all held)

- HEAD `e0cee7e04bef88811310f6dde1fd921f45d103ad`, tree `b249efb66e22f4c13529f255f3510d4a81314a99`, parent `87018a421f5be1064767d2cdd32e75ca935f7cdb`, bootstrap blob `7c3fba471f991e3750eb56fd29e271101652196e`, porcelain 0.
- Driver `binding/v4/s8c-pg-proof.sh` `73b291dba1725353583f27d61cb162017a95bc3d9aca0810227cfae0212db2bd`; fixture `c59326b56d8aaedf2cd509fb602cb64eb41620bf4c0c1773e2b4c5c6710685e9`; `BINDING.sha256` `c2cfd0a3…` (10/10 OK); supervisor `run-prep/supervisor.sh` `798d9f7c40850851a73c798e7c6071f2d51f54d8b0d0cceae7c3b4f5f4933a97` (`RUN_PREP.sha256` OK). In-driver pins EXPECT_HEAD/TREE/BOOTSTRAP_BLOB/FIXTURE_SHA equal the above.
- Live: lock inode 674373, 0 holders; 0 postgres; 55641/55642/55643 free; `proof-v4/clusters/s8-c`, `proof-v4/run/s8-c`, `binding/v4/run/`, `run-prep/LAUNCH.txt`, `run-prep/LAUNCHER.txt` all absent; no jest/tsc/prisma/prettier/eslint/lefthook/driver processes. Tool pins: postgres `23cd1748…`, initdb `b7db9bc2…`, psql `a200e38c…`, node `a03953a7…`, hidden lock `05bc530a…`, client `b6716a86…`, client schema copy `ded50406…`.

## 2. Invocation (exactly one)

- 16:48:46Z `cd …/s8c/binding/v4/run-prep && S8C_PG4_GRANT=1 bash supervisor.sh` (executor pid 21839) → all launch-mode refusals passed → `LAUNCH.txt` written → detached child supervisor pid 21915 (pgid/sid 21915, `setsid nohup`, stdin `/dev/null`).
- Child ran `timeout -k 30 3900 bash /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c/binding/v4/s8c-pg-proof.sh` once: timeout wrapper pid 21939, **driver pid 21941** (held canonical flock fd9, inode 674373, START→END; observed via lslocks at 16:48:54Z). Driver stdout → `run-prep/driver.stdout`, stderr → `run-prep/driver.stderr` (empty).
- `LAUNCHER_EXIT rc=1 16:49:18Z` — natural driver exit (not 124/137; no outer timeout, no signal). `supervisor.stdout/stderr` empty. Total wall time 32 s.

## 3. Driver stage record (`run/s8c-pg-proof.log`)

| Stage | Result | UTC |
|---|---|---|
| START | pid 21941, head_expect `e0cee7e0…`, fixture_expect `c59326b5…` | 16:48:46 |
| PRECONDITIONS_OK | postgres 17.6, psql 18.6, node v20.20.1, jest 30.4.1, ts-node 10.9.2, prisma 6.19.3 | 16:48:48 |
| PREFLIGHT_OK | `clusters_dir=ABSENT (first lane under the runtime root)` — no other lanes exist in this sandbox; lane absent, 55642 free, postgres 0, porcelain sha = empty-string sha, lock inode 674373 | 16:48:49 |
| FIXTURE_INIT rc=0 | `proof-v4/clusters/s8-c/pg-data`, port 55642, superuser `s8c_super`, cluster `s8c-disposable-pg17`, socket `proof-v4/run/s8-c`, pg 17 | 16:48:52 |
| FIXTURE_START rc=0 | postmaster pid 22428 | 16:48:52 |
| BOOTSTRAP **rc=0** | `CANDIDATE_HEAD=e0cee7e0…`; supabase shim (3 benign "already granted" NOTICEs); 171 migrations found and applied incl. `20270122000000_scout_native_provenance_expand`; **`CANDIDATE_CLIENT_VERIFIED`** (engine `a2924eab…`, runtime `library.js` `abdeb84c…`) — the corrected step-6 SHA256 check of the generated schema copy passed; identity JSON `{version 170006, directory proof-v4/…/pg-data, port 55642, applied 171}`; `G2_S8C_BOOTSTRAP_OK` | 16:48:56 |
| IDENTITY_OK | data_directory = fresh v4 lane, server_version_num 170006, cluster_name `s8c-disposable-pg17`, applied_migrations 171 | 16:48:56 |
| JEST_START | `./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s8c.spec.ts --runInBand --ci`, candidate_head `e0cee7e0…` | 16:48:56 |
| **JEST_END rc=1** | `Test Suites: 1 failed, 1 total · Tests: 13 failed, 13 total · Snapshots: 0 · Time: 20.546 s` | 16:49:17 |
| STOP_FIRST_FAILURE stage=jest rc=1 | `S8C_FIXTURE_STOP_OK`; `CLEANUP_STOP rc=0 postgres_procs=0 port55642_listeners=0 survivor_pid=none` | 16:49:17–18 |
| END rc=1 stage=jest | lock fd9 held until exit | 16:49:18 |

Sentinel `run/s8c-pg-proof.sentinel`: `RC=1 STAGE=jest END=2026-09-25T16:49:18Z HEAD=e0cee7e04bef88811310f6dde1fd921f45d103ad LOCK_INODE=674373` — the driver now refuses re-invocation by design; none attempted.

## 4. Jest results per test (`run/jest.log`, ANSI-stripped) — 0 passed / 13 failed

| Describe | Test | Result (ms) |
|---|---|---|
| lane identity (bootstrap state, never repaired here) | is the S8-C disposable PG17 lane with the full accepted history and S8-B objects present | ✕ 250 |
| lane identity | is bound to one attested candidate head that descends from the base | ✕ 134 |
| lane identity | the worker exposes the canonical family list with programs (N3) and refuses an unknown family | ✕ 130 |
| native persistence: target + provenance + typed ledger in one transaction | creates a WorkoutProgram from a programs row with workout_program provenance and ledger kind (N1, N4) | ✕ 128 |
| native persistence | creates a standalone WorkoutPlan with ordered exercises, exact catalog links and unresolved children | ✕ 126 |
| native persistence | replays byte-identical: no duplicate targets, no provenance drift, coach edits preserved | ✕ 128 |
| native persistence | program-day workouts: relationship pending until the program lands, then converge with revision 0 | ✕ 137 |
| client principal: explicit unresolved, never a User (N2) | client-linked workout stays generic evidence with an unresolved provenance marker; no plan, no User | ✕ 127 |
| tenant isolation | the same source identifiers for two coaches yield separate targets; neither coach sees the other | ✕ 127 |
| contention and atomicity | two concurrent identical runs converge on ONE plan; the loser rolls its target back with its transaction | ✕ 129 |
| contention and atomicity | a held ledger identity blocks the writer; its first attempt (target included) rolls back and the retry converges | ✕ 128 |
| legacy compatibility and unchanged precedence | legacy families and pre-existing NULL-kind ledger rows are untouched by the native writer | ✕ 126 |
| legacy compatibility | a later-removed or archived native target does not downgrade the reconstructed ledger row and mints nothing new | ✕ 122 |

All 13 failures carry the identical stack: `psqlRun (test/utils/g2-s8c-pg-harness.ts:62)` ← `sql (…pg-harness.ts:69)` ← `catalog (test/utils/g2-s8c-harness.ts:113)` ← `beforeEach (test/rls-g2-s8c.spec.ts:85)`. No test body ran.

## 5. Observed cause (read-only reads of the committed head; no diagnosis beyond what the logs and source show)

psql error (as role `postgres`, `ON_ERROR_STOP=1`):
```
ERROR:  null value in column "updated_at" of relation "ExerciseCatalogItem" violates not-null constraint
DETAIL:  Failing row contains (11111111-1111-4111-8111-111111111111, synthetic-bench-press, Synthetic synthetic-bench-press, strength, full_body, {}, {}, beginner, {}, null, null, null, public, none, null, null, null, 2026-09-25 16:49:16.162, null, null, null).
```
- `test/utils/g2-s8c-harness.ts` L112–116 (blob `d5cbf877…`, pinned unchanged since base by `EXPECT_HARNESS_BLOB`) `catalog()` runs `INSERT INTO "ExerciseCatalogItem" (id,slug,name,category,primary_muscle) VALUES (…) ON CONFLICT (id) DO NOTHING` — it does not supply `updated_at`.
- Committed schema `prisma/schema.prisma` model `ExerciseCatalogItem`: `updated_at DateTime @updatedAt` (a Prisma-client-side value, no DB default); migration `20260601000000_add_exercise_catalog_video/migration.sql` L20: `"updated_at" TIMESTAMP(3) NOT NULL` with no `DEFAULT`, while `created_at` has `DEFAULT CURRENT_TIMESTAMP`.
- The spec's `beforeEach` (L82–89) calls `resetData(); settle(); catalog([...])`, so every test fails before its body. The other harness inserts (`User`, `ScoutImport`, `ScoutIngestEntity`) did not error.
- Executor's read-only observation for the parent's disposition (not a classification decision): the failing statement is proof-harness fixture SQL, not product code, and it is independent of the bootstrap correction that this run was bound to. Classification, minimum closure and any further grant are the parent's and the reviewers'.

## 6. Cleanup and post-state (verified read-only ~16:50–16:53Z)

- Driver: `S8C_FIXTURE_STOP_OK`, `CLEANUP_STOP rc=0 postgres_procs=0 port55642_listeners=0 survivor_pid=none`.
- Now: `lslocks` 0 holders on `test-validation.lock` (inode 674373 preserved); `pgrep -cx postgres` 0; port 55642 free; `proof-v4/clusters/s8-c/pg-data` retained (75 MB) with **no `postmaster.pid`**; `proof-v4/run/s8-c` empty; worktree HEAD `e0cee7e0…`, porcelain 0; generated client `index.d.ts` still `b6716a86…`.
- Qualification: the supervisor's `POST` line (written the same second as `LAUNCHER_EXIT`, 16:49:18Z) recorded `lock_holders=1`; the driver's fd9 was released at its process exit and every later probe (16:49:21Z onward) shows 0 holders. No process held the lock afterwards.
- No other lane existed to protect in this sandbox (`clusters_dir=ABSENT`); S7-L worktree untouched (`a68cdac7`).

## 7. Receipts (immutable)

Driver-written `run/RECEIPTS.sha256`: `s8c-pg-proof.log` `fed92138aec2fd3e22f9b0f979b3692189420b8ef56f75fe70d77859e9703388`, `jest.log` `1cd6fc99897edefd409669692127ec19c5ef7cb8f977ada41fd073fa194a79b4`.
Qualification (same shape as v3): `RECEIPTS.sha256` is written inside `finish()` before the final `END` line is logged, so it hashes the log **minus its last line**; recomputed `head -n -1 s8c-pg-proof.log | sha256sum` = `fed92138…` (match). Complete 551-line log sha256 `4e07a2cdc5d324e661cfe12fe607d309282eb35a14b25600d3d54b823e76abd0`. Sentinel `d5acfff5b3176eb8e4cda854a2995c62a1e1503f6b0086955d609f3a83d8fb45`.

Supervisor-written `run-prep/LAUNCH_RECEIPTS.sha256`: `LAUNCH.txt` `7d849f21…`, `LAUNCHER.txt` `8450f793…`, `driver.stdout` `f94b5e55…`, `driver.stderr` empty (`e3b0c442…`). `supervisor.stdout`/`stderr` empty. Qualification (same pattern as the driver): the supervisor hashes `LAUNCHER.txt` before appending its own final `END` line, so `8450f793…` is `LAUNCHER.txt` minus its last line; the complete file is `94b2ce13ef1dc3eec3a87adf6670d94f8b8a3ce8ca7f67e5cfcf5f77c5e531c6` (recorded in `RUN_FREEZE.sha256`).

`run/RUN_FREEZE.sha256` (written after this receipt) covers every file in `run/` and `run-prep/`.

Status: **terminal, failed at stage jest (rc=1); proof authority PG-4a consumed; candidate `e0cee7e0` and v4 binding frozen; nothing rerun, edited or deleted. Awaiting parent disposition.**
