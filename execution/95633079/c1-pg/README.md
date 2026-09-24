# C1 PG proof packet — source only (nothing run)

Builder: C1 recovery/builder/executor, session 95633079. Not a self-audit; A+B review the two new files only.

| File | Role |
|---|---|
| `donor/s5-fixture.sh` | exact donor, sha256 `3a7d57bf951ab27e2161dc91db1d816f31d4af079ede076e7a2dfd1c44f3a721`, retrieved from `checkpoint-private/execution/e7d2385c/evidence/s5-proof-preparation-080b9574.tar.gz` (`caa41b4f…`) path `s5-proof-preparation/retrieved/2026-09-22/remediation/s5-r4/checkpoint-1/s5-fixture.sh`; matches that packet's `SHA256SUMS` |
| `derive-c1-fixture.sh` | deterministic sed derivation donor → variant (re-runnable by reviewers; refuses on donor hash mismatch) |
| **`c1-fixture.sh`** | **the variant under review** — substitution only per `C1_PG_PROOF_PREPARATION.md` §4 |
| `c1-fixture.diff-vs-3a7d57bf.txt` | `diff -u` donor → variant: 3 hunks, 31−/29+ |
| **`c1-pg-proof.sh`** | **the runtime binding under review** — §5 sequence bound to head `a0ea1bea…` |
| `ENVIRONMENT_RECOVERY.md` + `recorded-inputs/` | PG17.6/psql absence record and recorded provenance/setup inputs (not run) |

## Variant changes (every line is one of these; nothing else differs)
1. Constants: `PORT=55439; SUPER=user; MARKER=c1-disposable-pg17` (PASS dropped); `DATA=$PG17_HOME/clusters/c1-builder/pg-data; LOG=…/c1-builder/pg.log; SOCK=$PG17_HOME/run/c1`; `mkdir -p "$SOCK" "$(dirname "$DATA")"` (donor's `"$PG17_HOME/clusters"` was exactly `dirname $DATA`; needed because the pre-initdb log redirect `>"$DATA.initdb.log"` requires the parent).
2. `initdb … -A trust` — `pwfile` create/remove lines (donor 44, 46) dropped, `-A scram-sha-256 --pwfile=` replaced.
3. Caller guard re-pointed: `S5_RUNNER_PID`→`C1_RUNNER_PID`, `run-proof.sh`→`c1-pg-proof.sh` (lines 25–26, 36); `S5_STOP_TIMEOUT`→`C1_STOP_TIMEOUT`.
4. Identifier/message prefix `S5_FIXTURE_`→`C1_FIXTURE_`, "S5 marker/cluster"→"C1 marker/cluster", conf comment, header comments.

Unchanged bytes: fresh-init-only refusal (rc 3), marker checks on start/destroy, bounded fast stop with survivor detection (rc 4), destroy semantics (rc 4/5, DESTROY_OK only after verified absence), `pgbin` fd hygiene, `data_dir_users` scan, postgresql.conf tuning block. No new subcommand; the single `CREATE DATABASE c1_setup_disposable` lives in the binding (§5 step 4), not the fixture.

## Binding (`c1-pg-proof.sh`) — §5 verbatim sequence, no new criteria
- `flock -n` on `execution/test-validation.lock` (75 busy); refuses if its sentinel already exists (76; run once, no retry).
- Preconditions (rc 70): fixture sha256 = `27b816af…`; worktree `s7-c1` HEAD `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992`, tree `87798e74…`, spec blob `cc3b0e4d…`, porcelain 0, no MERGE_HEAD; jest/ts-node present; Prisma client has `ImportIntent`; PG dist present with postgres `23cd1748…`/initdb `b7db9bc2…` and `--version` 17.6; `/usr/bin/psql` present; `/home/user/pg17` real path.
- Step 1 preflight (rc 71): `clusters/c1-builder` absent, port 55439 free, 0 postgres; S5 cluster hashed if present / recorded `ABSENT` if not (never reconstructed).
- Step 2 init (60 s) → `C1_FIXTURE_INIT_OK data=… port=55439 superuser=user`; 3 start (60 s) → `C1_FIXTURE_START_OK`; 4 `psql -X -v ON_ERROR_STOP=1 -At postgresql://user@127.0.0.1:55439/postgres -c 'CREATE DATABASE c1_setup_disposable'` (30 s); 5 `SHOW data_directory` == `C1_TEST_DATA_DIRECTORY`, `server_version_num` == 170006 (15 s each, rc 73).
- Step 6 exactly once, bound 600 s, cwd `s7-c1`: `./node_modules/.bin/jest --config jest.rls.config.js test/rls-c1-setup.spec.ts --runInBand --ci` — **no `--testTimeout`** (spec's own 30 s/45 s, repo default 10 s), no `--forceExit`/`--detectOpenHandles`/coverage. Env exactly §5 (`C1_SETUP_TEST_DATABASE_URL=postgresql://user@127.0.0.1:55439/c1_setup_disposable`, `C1_TEST_PSQL=/usr/bin/psql`, `C1_TEST_DATA_DIRECTORY=/home/user/pg17/clusters/c1-builder/pg-data`, `C1_SETUP_DISPOSABLE_ACK=c1-local-only-55439`, `NODE_OPTIONS=--max-old-space-size=4096`, offline npm flags).
- Step 7 stop (45 s + kill 30) then 0 postgres, port free, no `postmaster.pid`, data dir RETAINED (rc 74 otherwise). Step 8: S5 unchanged/absent-unchanged, worktree porcelain and HEAD unchanged, `run/RECEIPTS.sha256`.
- First nonzero stops; the only cleanup after a start is one bounded fixture `stop` (survivor rule); the sentinel carries the FIRST rc. Receipts: `run/c1-pg-proof.log`, `run/jest.log`, `run/c1-pg-proof.sentinel` (`RC= STAGE= END= HEAD=`), all additive. `run/` does not exist yet.
- Launch (when granted): `timeout -k 30 900 bash /home/user/workspace/execution/95633079/c1-pg/c1-pg-proof.sh` — outer ≤ 900 s; step bounds sum 810 s.

Acceptance is §6 as written (1/1 suites, 22/22 tests, rc 0, guards silent, fixture init/start/stop rc 0, S5 untouched, no survivors) — observed as-is, not redefined.

## Not done / not claimed
No process, cluster, database, install, download, probe, or worktree change. `/home/user/pg17` and `/usr/bin/psql` absent (see `ENVIRONMENT_RECOVERY.md`). Heavy lock not held by this worker (re-created by another owner at 06:11:20Z, untouched). The `c1-fixture.sh status` refusal check (rc 2) exited at the guard before any `mkdir`; filesystem unchanged. Original `13-C1_ACTUAL_RESULTS_SEAL.md` untouched. Runtime requires A+B review of the two new files, environment recovery by the next heavy owner, and a separate runtime grant.
