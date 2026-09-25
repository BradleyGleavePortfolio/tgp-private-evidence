# S7-L v4 real-PG proof — PROOF RUN RECEIPT (terminal; 17:03Z)

Grant: PG-4b (`execution/daceddc8/SCOPE.md`, parent 16:58Z; dual GO `reviews/WORKER_CORRECTION_REVIEW_A.md` / `_B.md`, class C only). Executor: `s7l_worker_correction_builder` (T4). **Result: FULL PASS — driver rc 0, stage `done`, Jest 24 passed / 24 total, 0 failed.** This run was the one authorized invocation of the frozen v4 binding; it is terminal for this grant. No rerun, no edit, no receipt altered. Acceptance of exactly candidate `df713fd9` is the parent's decision.

## 1. What ran (exactly once)
- Executor re-ran PREFLIGHT §A/§B read-only at 16:58:05Z: HEAD `df713fd9217df524915348ef8a42c797f288dde1`, tree `796f437f…`, HEAD^ `a68cdac7…`, worker blob `155ffdcc…`, spec blob `94e7fac4…`, porcelain 0; driver `8b03f4c2…`, fixture `74aed261…`, `BINDING.sha256` `6c912b96…` (`-c` OK), supervisor `eb9bb86b…` (`RUN_PREP.sha256` OK); driver pins equal; lock inode 674373 with 0 holders, 0 postgres, 55641/55642 free, no proof/Jest/prisma/tsc process; `proof-v4/clusters/s7l`, `proof-v4/run/s7l`, `proof-v4/s7l/old-root`, `binding/v4/run`, `LAUNCH.txt`, `LAUNCHER.txt` all absent; sibling `proof-v4/clusters/s8-c` + `proof-v4/run/s8-c` present (stopped); nm lock `05bc530a`, client `9042e713`, postgres `23cd1748`, PROVENANCE `result=success`.
- Launch 16:58:12Z: `cd …/s7l/binding/v4/run-prep && S7L_PG4_GRANT=1 bash supervisor.sh` → supervisor refusals passed, `LAUNCH.txt` written 16:58:13Z, detached child supervisor pid 28132 (pgid = sid = 28132). Child ran exactly `timeout -k 30 3900 bash /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v4/s7l-pg-proof.sh` (timeout wrapper pid 28156, driver pid 28158), stdin `/dev/null`. The supervisor never opened the lock, never signalled, never relaunched.
- Driver held the canonical `flock -n` fd9 (inode 674373) from START 16:58:13Z to its exit at END 17:00:21Z. `LAUNCHER_EXIT rc=0 17:00:22Z`, `END rc=0`.

## 2. Driver stages (`s7l-pg-proof.log`, 555 lines)
| Stage | Result | UTC |
|---|---|---|
| preconditions | PRECONDITIONS_OK — server `postgres (PostgreSQL) 17.6`, psql 18.6, node v20.20.1, jest 30.4.1, ts-node 10.9.2, prisma 6.19.3; all head/tool pins matched | 16:58:17Z |
| preflight | PREFLIGHT_OK — lane/old-root absent, 55641 free, 0 postgres; other lane `proof-v4/clusters/s8-c` recorded (conf `e5ee5744…`, pg_control `42f2bedc…`), `clusters/` ABSENT (skipped) | 16:58:19Z |
| old-root | OLD_ROOT rc=0 (detached 93389265 at `proof-v4/s7l/old-root`) | 16:58:20Z |
| fixture-init / fixture-start | rc=0 / rc=0 (`proof-v4/clusters/s7l/pg-data`, port 55641, `s7l-disposable-pg17`) | 16:58:21Z / 16:58:22Z |
| bootstrap | BOOTSTRAP rc=0, `G2_S7L_BOOTSTRAP_OK`; 171 migrations applied via OLD root; OLD client generated at `<old-root>/.g2-s7l-old-client` with its own `runtime/library.js` (sha `5a72b6f6…`, pinned runtime `abdeb84c…`, engine `a2924eab…`); candidate client VERIFIED (no generate) | 16:58:31Z |
| identity | IDENTITY_OK — data_directory = lane pg-data, server_version_num 170006, cluster_name `s7l-disposable-pg17`, applied_migrations 171, S7-L columns before spec 0 | 16:58:31Z |
| jest | JEST_START 16:58:31Z → JEST_END rc=0 17:00:21Z; `Tests: 24 passed, 24 total`, `Time: 108.697 s`; POST_JEST applied_migrations=172 (S7-L re-applied by the final up) | 17:00:21Z |
| fixture-stop | FIXTURE_STOP rc=0; STOP_STATE_OK postgres_procs=0, 55641 free, data dir retained | 17:00:21Z |
| post | POST other_lanes_unchanged=[proof-v4/clusters/s8-c:e5ee5744…:42f2bedc…]; worktree unchanged; candidate client unchanged; OLD root unchanged; POST_OK lock still held fd9 | 17:00:21Z |
| done | `END rc=0 stage=done 2026-09-25T17:00:21Z`; sentinel `RC=0 STAGE=done END=2026-09-25T17:00:21Z HEAD=df713fd9217df524915348ef8a42c797f288dde1 LOCK_INODE=674373` | 17:00:21Z |

Wall time launch → END: 2 min 9 s (within the 3900 s outer bound; inner soft sum 3165 s).

## 3. Per-test Jest results (`jest.log`, `test/rls-g2-s7l.spec.ts`, --runInBand --ci; 1 suite, 24 tests, 0 snapshots)
- ✓ the OLD legacy /complete writer settles a legacy run on the pre-S7-L schema (baseline) (1782 ms)
- ✓ a decoy relation holding the partial-unique name refuses up; the decoy and the run table are untouched (1879 ms)
- ✓ a decoy constraint holding an S7-L name refuses up; nothing is created (839 ms)
- ✓ a held transaction on the run table makes up hit lock_timeout (55P03); nothing applied; release → free (5897 ms)
- ✓ down on the OLD shape refuses with the fixed absent text; nothing changes (575 ms)
- ✓ L01: prisma migrate deploy applies exactly S7-L; catalog exact; RLS byte-equal; legacy rows untouched (3777 ms)
- ✓ L02: a raw rerun is refused atomically; OIDs, rows and history unchanged; deploy has nothing pending (1821 ms)
- ✓ §3.1 gate SQL: two sessions on one run serialize on the UPDATE (no 40P01); last_observed_at monotonic; phase moves once (871 ms)
- ✓ a FOR NO KEY UPDATE fence waits for the gated writer to commit, then sees the committed observation (765 ms)
- ✓ CHECK/FK/partial-unique refuse every malformed run row for the owner and the runtime role; nothing is written (1524 ms)
- ✓ L06: anon/authenticated are refused by policy; a service_role transaction that rolls back persists nothing (488 ms)
- ✓ L07: Start guards — 404 foreign/unknown, 409 intent_not_paired, 409 intent_superseded, 409 legacy_run (6465 ms)
- ✓ L07: a duplicate Start race produces exactly one server row; both callers receive the same body (3283 ms)
- ✓ L08: cancel vs in-flight ingest — the fence waits on the gated writer, both succeed in order, no 40P01 (6628 ms)
- ✓ L08: concurrent ingest and /progress on one run serialize on the row lock; last_observed_at monotonic; no 40P01 (5171 ms)
- ✓ L09: /complete on an open run stores the claim and settles partial/reconciliation_not_performed (never complete); a duplicate is a no-op ack (10210 ms)
- ✓ L09: /complete after a cancel is a no-op ack (fence beats late complete); /complete without a Start is 409 run_not_started (6378 ms)
- ✓ L10: lazy deadline — an expired open run is fenced timed_out by the next writer AFTER its own rollback (no self-wait); the read path fences too (7893 ms)
- ✓ CAS terminal-once: a stale settle epoch after a fence writes nothing (6250 ms)
- ✓ L11: projections — legacy rows read as mode legacy with the accepted fields; non-UUID intents never touch the lifecycle; unknown intents 404 (5013 ms)
- ✓ L05/L12: the OLD image legacy writers on the S7-L schema — byte-identical legacy rows; a server row is protected by the legacy marker (6871 ms)
- ✓ L03: down refuses with one server row (fixed text); nothing deleted; schema, OIDs and history unchanged (1873 ms)
- ✓ L04: down removes exactly S7-L and keeps every legacy row; the OLD writer continues; a second down refuses (2650 ms)
- ✓ re-applying the file restores the identical shape (OIDs aside); legacy rows keep defaults; a raw rerun is refused again (1279 ms)

### L05/L12 — the question this correction was bound to answer
The v3 run failed exactly here (OLD-image `instanceof PrismaClientKnownRequestError` false → P2002 rethrown → emulated 500 instead of the replay ack). In this run the test passed on its merits (6871 ms). OLD-image worker processes observed in `jest.log` (`"old":true`, query shapes and identifiers only, never parameters):
- `g2l_1` complete `intent_legacy_2026` → `{acknowledged:true}` (baseline legacy writer on the pre-S7-L schema).
- `g2l_47` complete `intent_old_ext_2026` terminal_status partial → `{acknowledged:true}` (first write on the S7-L schema; byte-identical legacy row).
- `g2l_49` **replay** complete `intent_old_ext_2026` terminal_status success → `{acknowledged:true}` — the P2002 replay-as-ack path: the OLD writer's `catch (err instanceof PrismaClientKnownRequestError && err.code === 'P2002')` now holds because the worker resolves `@prisma/client/runtime/library` to the custom-output client's own runtime; row unchanged (spec L986-987).
- OLD `status` read of the legacy row: no failure, `status: 'partial'` (spec L989-991).
- `g2l_52` OLD complete aimed at a SERVER run `d674c946-…` → `failure {status:500}` — **expected** (spec L1001: the database mode-shape CHECK refuses the legacy upsert on a server row; nothing moves; L12 legacy-marker protection). This is the only 500 in the run and it is asserted, not a defect.
- `g2l_53` OLD complete `intent_after_down` after L04 down → `{acknowledged:true}` (the OLD writer continues on the OLD shape).
Identity sanity for the correction: `OLD_CLIENT_GENERATED … runtime=<old-root>/.g2-s7l-old-client/runtime/library.js runtime_sha256=5a72b6f6…` vs `CANDIDATE_CLIENT_VERIFIED … runtime=<worktree>/node_modules/@prisma/client/runtime/library.js runtime_sha256=abdeb84c…` — two distinct runtime files, as the v3 reviews diagnosed; the worker's redirect makes the OLD process load one instance. The candidate (default-output) client has no `runtime/` copy, so the redirect fell through for every candidate-image worker (L07–L11 all passed unchanged).

## 4. Post-run state (executor, read-only, 17:01:08Z)
- `lslocks | grep -c test-validation.lock` = 0; `pgrep -cx postgres` = 0; port 55641 free; no `s7l-pg-proof`/supervisor/jest process. Lock file `/home/user/workspace/execution/test-validation.lock` inode 674373, size 0, present (never deleted or recreated).
- `proof-v4/clusters/s7l/pg-data` retained (75M), no `postmaster.pid`. `proof-v4/s7l/old-root` retained. Not destroyed (separate marker-gated decision).
- Sibling S8-C lane untouched (conf/control hashes identical pre/post, per driver POST).
- Worktree `64e33dc7-s7l` HEAD still `df713fd9`, clean.
- Note (supervisor `POST` line at 17:00:22Z shows `lock_holders=1`): sampled in the same second the driver exited; `lslocks` still listed the closing holder. The executor's independent check 46 s later shows 0 holders and the driver's own END line records fd9 held to exit. No other process ever held the lock during this run.
- Known, unchanged C finding: the driver's `finish()` hashes `s7l-pg-proof.log` into `RECEIPTS.sha256` (`0ab254a5…`) before appending the final END line; the log's sha with the END line is `a9396194…` (recorded in `RUN_FREEZE.sha256`). `jest.log` sha matches `RECEIPTS.sha256` exactly.

## 5. Receipts (all preserved unmodified)
- `run/s7l-pg-proof.log` — pre-END sha (RECEIPTS.sha256) `0ab254a55dfb73e68a6aa12399a63886935d142ce2705d66c0b31defc4d423f8`; final sha `a9396194b95510c1286dc5bea4f42ae1f6b3b4e1b5aa2f462f20464337a91d2c`
- `run/jest.log` `df8fdc4599c09baaad2b3454d96dea16ba7e8ee340ccf941759d1357f4d1e975`
- `run/s7l-pg-proof.sentinel` (`RC=0 STAGE=done …`), `run/RECEIPTS.sha256`
- `run-prep/LAUNCH.txt` `2d289f72…`, `run-prep/LAUNCHER.txt` pre-END sha (LAUNCH_RECEIPTS.sha256) `12ee1633…` / final sha with its END line `5464e47d…` (same hash-before-END pattern as the driver; only the END line was appended after hashing), `run-prep/driver.stdout` `d09bcafe…` (2423 B, driver tee output), `run-prep/driver.stderr` empty (`e3b0c442…`), `run-prep/supervisor.stdout`/`.stderr` empty, `run-prep/LAUNCH_RECEIPTS.sha256`
- Binding used: `binding/v4/BINDING.sha256` `6c912b96…` (driver `8b03f4c2…`, fixture `74aed261…`), supervisor `eb9bb86b…`.
- `run/RUN_FREEZE.sha256` — hashes of every file in `run/` and `run-prep/` at receipt time (this receipt included).

## 6. Not done / boundaries
No second invocation, no signal, no destroy, no edit of any receipt or binding, no evidence-repo commit or push (parent publishes), no landing, no acceptance declared by the executor. Disposition (acceptance of exactly `df713fd9` and the composition/landing steps) is the parent's.
