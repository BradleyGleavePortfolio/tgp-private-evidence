# S9-C real-PG proof binding v1 (EXEC-D3A9F701) — source only, NOT RUN, NOT GRANTED

Derived by substitution from the accepted S9-B binding `execution/1910a060/s9b/binding/v3/` (ran once, 10/10). Full diff: `DELTA-from-s9b-v3.diff`.

| file | sha256 |
|---|---|
| `s9c-pg-proof.sh` | see `BINDING.sha256` |
| `s9c-fixture.sh` | ca1e563d9056169aacb60c8bf95d6a41d34ff0619eadc7a998972fe9d8dc1085 (= `EXPECT_FIXTURE_SHA`) |

Usage (separate single-run PG grant, after the gate commit and fill):
`timeout -k 30 3900 bash /home/user/workspace/tgp-private-evidence/execution/d3a9f701/s9c/binding/v1/s9c-pg-proof.sh`

## Deltas vs S9-B v3
- W = `worktrees/d3a9-s9c-r2`; D = `d3a9f701/s9c/binding/v1`; BASE_HEAD 5407efae / BASE_TREE 3e2028e9; also requires `HEAD^ == BASE_HEAD`.
- Lane: port 55646, db `g2_s9c_disposable`, admin `s9c_super` / `s9c_local_synthetic`, cluster_name `s9c-disposable-pg17`,
  db marker `s9c-g2-reconciliation-wiring-synthetic-disposable-fixture-safe-to-drop`, `runtime/clusters/s9-c`, `runtime/run/s9-c`
  (same RUNTIME_ROOT `execution/1910a060/runtime`). Runner cross-checks the fixture's RUNTIME_ROOT/PORT/MARKER/LANE/SOCK lines whole-line.
- NEW: runner checks the committed harness literals at HEAD (bootstrap BASE_HEAD/CLUSTER_MARKER/DB_MARKER/EXPECTED_MIGRATIONS=172;
  g2-s9c-db.ts database/role/markers/BASE_HEAD; 55646 not in REFUSED_PORTS; it() count == EXPECT_TESTS=10).
- Env: only `G2_S9C_DATABASE_URL` (`…?schema=public&connection_limit=4`), `_CONFIRM=g2_s9c_disposable:55646`, `_PASSWORD`, `_PSQL`,
  `_DATA_DIRECTORY`, `_SERVER_VERSION=170006`, `_CANDIDATE_HEAD`; every other inherited `G2_*` is unset.
- Bootstrap `bash test/utils/g2-s9c-bootstrap.sh bootstrap` (`^G2_S9C_BOOTSTRAP_OK`); jest
  `./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s9c.spec.ts --runInBand --ci`; identity adds `inet_server_port()`.
- Accepted-path pins at 5407efae replace S9-B's: prisma schema/migrations, package-lock, jest.rls.config.js, reconstruct/orchestration,
  scout-reconstruct.service.ts, run.controller.ts, families.ts, all S8-C/S8-G proof files, S9-A 4 files, S9-B 10 files;
  `src/scout/reconciliation` must be unchanged; `src/scout/reconstruct` delta must equal `EXPECT_RECONSTRUCT_DELTA` (default '').
  The S9-B "facts files present" check is replaced by "lifecycle.service.ts references ReconciliationFactsService".
- Unchanged: PG17 dist/psql/node/NM/schema/lockfile pins, lock inode 692282 + held fd9, port/postgres preflight, other-lane fingerprint
  scan (now also sees clusters/s9-b), porcelain unchanged, bounded stop, `pgrep -cx postgres`=0, port free, data dir retained.

## Parent must fill (refused while `__FILL_*__`)
`EXPECT_HEAD`, `EXPECT_TREE`, the six `EXPECT_*_BLOB` (rls-g2-s9c.spec, bootstrap, db, pg-harness, harness, worker) from the gate
receipt `d3a9f701/s9c/gate/HEAD-<12>.txt`. If native-rules.ts is committed, set
`EXPECT_RECONSTRUCT_DELTA='src/scout/reconstruct/native/native-rules.ts'` (otherwise the proof refuses 70).

## Assumptions to verify
- r2 harness pins `G2_S9C_BASE_HEAD` / bootstrap `BASE_HEAD` = 5407efae (freeze-1 had 771db62a); binding `HARNESS_BASE_HEAD` = 5407efae.
- `EXPECT_TESTS=10` counted on the r2 working copy; re-count at the committed head (the runner does this too).
