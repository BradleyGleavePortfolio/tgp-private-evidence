# S7-L first single real-PG proof — RUN RECEIPT (read-only; written 2026-09-25T05:18Z after terminal)

Result: **FAILED — NOT a passing proof. Candidate 54970cd9 remains unaccepted.** Nothing was rerun, edited or probed.

## Launch and identity
- Grant: `S7L_SINGLE_PG_PROOF_GRANT.md` (activation 05:06Z). Driver `binding/v2/s7l-pg-proof.sh` sha `0287a941…2705`, fixture `dc77a7c9…3dd2`, `BINDING.sha256` sha `01985b85…1be2` — all re-verified equal to the grant before launch; head `54970cd937afc8dea689b33243961abfef8b9dd6`, tree `513c71d7c1390787e1521ccbfa46b30bb52b5462`, worktree clean.
- Launcher (`LAUNCHER.txt`): `setsid -f bash -c 'timeout -k 30 3900 bash …/binding/v2/s7l-pg-proof.sh'` at 05:06:22Z; launcher exit rc=124 at 05:14:22Z (propagated from the driver's own exit code, not the outer 3900 s timeout — total wall 8 min).
- Runner: driver pid 17284 (PGID 17283), canonical `flock -n` on fd 9 acquired 05:06:22Z (inode 691716), held until END.

## Driver stages (`s7l-pg-proof.log`, sha in `RECEIPTS.sha256`)
PRECONDITIONS_OK 05:06:27Z (postgres 17.6, psql 18.6, node v20.20.1, jest 30.4.1, ts-node 10.9.2, prisma 6.19.3) → PREFLIGHT_OK 05:06:34Z (lane/old-root absent, 55641 free, 0 postgres) → OLD_ROOT rc0 05:06:36Z → FIXTURE_INIT rc0 05:06:45Z → FIXTURE_START rc0 05:06:46Z → BOOTSTRAP rc0 05:06:58Z → IDENTITY_OK 05:06:59Z (data_directory `…/clusters/s7l/pg-data`, 170006, cluster `s7l-disposable-pg17`, applied 171, S7-L columns absent) → JEST_START 05:06:59Z (`./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s7l.spec.ts --runInBand --ci`, stage `timeout -k 30 1800`).

## Jest (`jest.log`, 294.68 s)
- `Test Suites: 1 failed, 1 total` · **`Tests: 21 failed, 3 passed, 24 total`** · plus "Test suite failed to run" (afterAll `resetData` → `spawnSync /usr/bin/psql ETIMEDOUT`) · "Jest did not exit one second after the test run has completed" (open handle).
- Passed (3): the stage-1 baseline/identity tests before the first failure (PG17_DATABASE identity line printed; OLD image legacy writer PG17_PROCESS g2l_1 ran).
- **Stage exit was FORCED, not a natural rc 1**: after the completed failed summary Jest stayed alive on the open handle; the parent (authorized, `PARENT_TERM.txt`) sent TERM at 05:14:22Z to the stage process group 19276 only (Jest pid 19277, stage `timeout` 19276); driver 17284 untouched. The driver recorded `JEST_END rc=124` and proceeded through its bound failure path. The builder sent no signal.

## First causal failure (diagnosis, no remediation performed)
1. **Root**: stage 1 test "a held transaction on the run table makes up hit lock_timeout (55P03)" — `refusedFile(upFile, '55P03')` at `test/rls-g2-s7l.spec.ts:269` expects the psql error text to contain the SQLSTATE `55P03`. psql's default (non-verbose) stderr prints only `ERROR:  canceling statement due to lock timeout` — no SQLSTATE — so the assertion failed even though the migration file DID behave correctly (lock_timeout hit at migration.sql:28, nothing applied). The accepted S8-B spec asserts `/canceling statement due to lock timeout/` (`test/rls-g2-s8b.spec.ts:254`); the S7-L spec deviated to the code string. Class: spec assertion text defect, not a product/migration defect (the 5 s lock_timeout budget and the refusal were observed).
2. **Cascade**: the assertion threw before `holder.release()` (spec line 273), so the background psql holding `SELECT … FOR UPDATE` on `"ScoutImport"` inside an open transaction was never committed/killed. Every later statement touching that table waited for the row/relation lock until the harness `execFileSync` 60 s timeout → `spawnSync /usr/bin/psql ETIMEDOUT` (14 occurrences), plus secondary consequences (`column "mode" … does not exist` ×2 because L01 never applied; `current transaction is aborted` ×1; fixed-text expectations for ALREADY/ABSENT unmet). 21 failures + suite-level afterAll failure share this single origin. The lingering holder child is also the plausible open handle that kept Jest alive.
3. Consequently **no S7-L runtime assertion beyond the stage-1 baseline was actually decided** in this run (L01–L12 all cascaded). POST_JEST applied_migrations=171 (S7-L never applied).

## Cleanup / terminal state (bound path only)
STOP_FIRST_FAILURE stage=jest rc=124 05:14:22Z → CLEANUP_STOP rc=0, postgres_procs=0, port55641_listeners=0, survivor_pid=none → END rc=124 05:14:22Z; sentinel `RC=124 STAGE=jest … HEAD=54970cd9…`; `RECEIPTS.sha256` written (log 63d58094…, jest.log d6253d28…). Post-check at 05:18Z: lock probe exit 0 (released), 0 postgres, no postmaster.pid, data directory RETAINED at `recovery-reset/clusters/s7l/pg-data` (PG_VERSION present), old-root retained, worktree clean at 54970cd9. Not run in the failure path (by design): stage-8 stop-state assertions, stage-9 post checks.

## Builder actions after terminal
Read-only only: inspected logs, wrote this receipt. No rerun, no source/pin/driver edits, no database probe, no fixture destroy. Heavy authority ended with this receipt.

## Minimum closure candidate (for parent/reviewer disposition — NOT implemented)
Change the stage-1 assertion at spec:269 to the observed psql text (S8-B pattern `canceling statement due to lock timeout`) and make the holder release/kill unconditional (try/finally) so a failed assertion cannot leak the lock into later tests. Single file `test/rls-g2-s7l.spec.ts`; no product change. Requires a new ordinary commit, v3 binding and a fresh single-run PG grant.
