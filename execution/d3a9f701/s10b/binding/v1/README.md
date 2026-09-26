# S10-B real-PG proof binding v1 (EXEC-D3A9F701) — source only, NOT RUN, NOT GRANTED

This binding is derived by substitution from the S9-C binding `d3a9f701/s9c/binding/v2/`. That binding is S9-B v3 plus the pipefail fix. The full diff is in `DELTA-from-s9c-v2.diff`, and the hashes are in `BINDING.sha256`.

| file | note |
|---|---|
| `s10b-pg-proof.sh` | the runner; 13 `__FILL_*__` pins remain and the runner refuses to start while any is present |
| `s10b-fixture.sh` | sha256 7d9ee89b4333332ea42adcadf538c68c6815127e161d8941db125ac9873120e8 (already filled as `EXPECT_FIXTURE_SHA`) |

Usage, under a separate single-run PG grant, after the S10-B gate commit and the fill:
`timeout -k 30 3900 bash /home/user/workspace/tgp-private-evidence/execution/d3a9f701/s10b/binding/v1/s10b-pg-proof.sh`

## Fill (parent)
| pin | source |
|---|---|
| `BASE_HEAD`, `BASE_TREE` | S10-A landing sha / `git rev-parse <sha>^{tree}` (= gate PINS.env BASE / BASE_TREE) |
| `EXPECT_HEAD`, `EXPECT_TREE`, `EXPECT_MIGRATIONS_TREE` | gate receipt `d3a9f701/s10b/gate/HEAD-<12>.txt`, lines `head=`, `tree=`, `migrations_tree=` |
| `EXPECT_SPEC_BLOB`, `_DB_`, `_PGH_`, `_HARNESS_`, `_WORKER_`, `_FIXTURES_BLOB` | receipt `blob <path> <blob>` lines (these are post-format, so prettier may have changed them) |
| `EXPECT_NM_CLIENT_SHA`, `EXPECT_NM_CLIENT_SCHEMA_SHA` | receipt `postgen_client index_dts=… schema=…` (the client the gate regenerated inside `$W/node_modules`) |

The following are already filled because prettier never touches these files:
- the bootstrap blob `32305683`
- the schema blob `f86c1f5d`
- the migration blob `695c694d`
- the down blob `b5e5243e`

They were computed with `git hash-object` (no `-w`) on the pre-gate bytes, and each must match the receipt. After filling, re-hash `BINDING.sha256`.

## Review fixes (2026-09-26); diff in `DELTA-review-fix.diff`
- **B1: preconditions run before the lock.** All read-only preconditions now run before the lock and before any sentinel write. That covers:
  - pin placeholders
  - fixture sha and lane lines
  - HEAD, trees and lineage
  - the exact deltas and S10-A FREEZE bytes
  - prisma, the migration trees and counts
  - harness literals and it() count
  - committed blobs, clean tree and hooks
  - the not-mounted check
  - node_modules and client shas
  - the donor client
  - tool pins
  
  A refusal writes `PRELOCK_REFUSED` to `run/prelock.log` and exits without the sentinel, so the run is not used up. Under the lock the runner re-checks the fixture sha, HEAD, the clean tree and both client shas. `RECEIPTS.sha256` now also covers `prelock.log`.
- **A B-1 analogue (symlink-aware checks):**
  - The sentinel refuses when `[ -e ] || [ -L ]`.
  - Both lefthook hooks must be regular files, not symlinks.
  - The lane dir and other-lane `postmaster.pid` checks treat a symlink as present.
  - The fixture `init` refuses a symlinked `$DATA`, and `destroy` checks `-L` too. This changed the fixture sha to 7d9ee89b…20e8.
- **Pins:**
  - `S10A_PARENT=e6f20300b495fa9eee9539ae58d30e3b60e5a78c`. `HARNESS_BASE_HEAD` is unchanged (a4af8e33).
  - The prefilled blobs still match the devloop-2 bytes: bootstrap 32305683, schema f86c1f5d, migration 695c694d, down b5e5243e.
  - The six receipt blobs stay `__FILL__`. The comments carry the values the devloop-2 bytes hash to:
    - spec b89fec1c
    - db 3375f08b
    - pg-harness 7cf6d633
    - harness 9956aff7
    - worker e0af8412
    - fixtures 8055dbef
    
    If the receipt differs, the gate changed bytes; investigate before filling.
  - `EXPECT_TESTS=24`, re-counted on the devloop-2 spec (5f21ef89), with no skip/only/todo.

## Deltas vs S9-C v2
- **Paths and pins:**
  - W = `worktrees/d3a9-s10b`, D = `d3a9f701/s10b/binding/v1`.
  - The runner checks `HEAD^ == BASE_HEAD` and `BASE_HEAD^ == S10A_PARENT` (e6f20300, the S9-C landing merge).
  - `HARNESS_BASE_HEAD=a4af8e33` is kept as the harness literal and must be an ancestor of BASE. a4af8e33..e6f20300 touches no prisma.
- **Lane:**
  - port 55647, db `g2_s10b_disposable`, admin `s10b_super` / `s10b_local_synthetic`
  - cluster_name `s10b-disposable-pg17`, db marker `s10b-g2-run-observation-synthetic-disposable-fixture-safe-to-drop`
  - lane dirs `runtime/clusters/s10-b` and `runtime/run/s10-b`, under the same RUNTIME_ROOT `execution/1910a060/runtime`
  - The fixture lane lines are cross-checked against the captured fixture text.
- **Migration (new vs S9-C, which had no OLD side and 172 migrations):**
  - Before starting, the runner checks the commit itself:
    - HEAD has 173 migration dirs and the last one is `20270124000000_scout_run_observation_expand`.
    - The BASE migrations tree is 654550cb and the HEAD tree matches the receipt.
    - The prisma diff against the harness base is exactly schema + migration.sql + down.sql.
    - No D/M/R changes to accepted migrations.
  - After bootstrap, the identity checks require:
    - applied == 173
    - `max(migration_name)` == the S10-B dir
    - all 3 S10-B tables have ENABLE+FORCE RLS
- **Exact delta:** `BASE..HEAD` must be the 16 S10-B paths, and `S10A_PARENT..BASE` must be the 14 S10-A FREEZE paths, with the FREEZE bytes at HEAD. This replaces the S9-C per-path accepted-blob list (S8-C/S8-G/S9-A/S9-B), because the exact delta implies all of those.
- **Not mounted:** `scout.module.ts` at HEAD must not reference `ObservationModule`, since that wiring belongs to S10-C. `docs`, `scripts`, the package files and `scout.module.ts` must be unchanged from BASE.
- **Client:**
  - `$W/node_modules/.prisma/client/{index.d.ts,schema.prisma}` must equal the gate's regenerated values, which must differ from the donor's 9042e713. The client must also carry the three models.
  - The donor `1910a060-s8f/node_modules/.prisma/client/index.d.ts` must still be 9042e713, both before the run and in post.
  - The runner never generates. The bootstrap only verifies, and its `CANDIDATE_CLIENT_VERIFIED dir=$W/...` line is required.
- **Schema:** `EXPECT_SCHEMA_SHA` = d6d01f54, the S10-B schema (was 0eb41f9a).
- **Harness literals at HEAD:**
  - bootstrap: `BASE_HEAD`, `CLUSTER_MARKER`, `DB_MARKER`, `EXPECTED_MIGRATIONS=173`, `S10B_MIGRATION`
  - pg-harness: `EXPECTED_MIGRATIONS = 173` and `S10B_MIGRATION`
  - db.ts: database, role, markers, `G2_S10B_BASE_HEAD`
  - 55647 must not be in `REFUSED_PORTS`, and 55646 must be.
  - The it() count must equal `EXPECT_TESTS=24`, counted on the pre-gate spec and re-counted at HEAD.
  - The blob list adds `g2-s10b-fixtures.ts`, the schema and the migration pair.
- **Env:**
  - The runner sets only these: `G2_S10B_DATABASE_URL` (`…?schema=public&connection_limit=4`, allowed by the guard's PRISMA_ONLY set), `_CONFIRM=g2_s10b_disposable:55647`, `_PASSWORD`, `_PSQL`, `_DATA_DIRECTORY`, `_SERVER_VERSION=170006`, and `_CANDIDATE_HEAD`.
  - It unsets every other inherited `G2_*`, plus `G2_S10B_WORKER`.
  - It also sets `PRISMA_GENERATE_SKIP_AUTOINSTALL=1`.
- **Commands:** bootstrap `bash test/utils/g2-s10b-bootstrap.sh bootstrap` (must print `^G2_S10B_BOOTSTRAP_OK`); jest `./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s10b.spec.ts --runInBand --ci`; the run passes only on `Tests: 24 passed, 24 total`.
- **Pipefail:** the runner no longer uses `cmd | grep -q`. The fixture lines, psql/node versions, `ss` listener counts and the it() count are all captured first. The fixture's `data_dir_users` `tr | grep -qF` was also a pipeline condition under `set -euo pipefail` (a SIGPIPE false negative would under-report users before destroy). It now captures the cmdline first.
- **Unchanged:**
  - PG17 dist/psql/node/NM-lock/package-lock pins
  - lock inode 692282 + held fd9
  - port and postgres preflight
  - the other-lane fingerprint scan, which now also sees `clusters/s9-c`
  - porcelain unchanged, bounded stop, `pgrep -cx postgres`=0, port free, data dir retained

## Assumptions to verify
- `EXPECT_TESTS=24` comes from `grep -cE '^\s*it\('` on the pre-gate bytes. The runner re-counts at HEAD, and prettier does not change the count.
- `max(migration_name)` works as "last applied" because migration names start with a timestamp and sort lexically.
- Lane `clusters/s10-b` and `run/s10-b` are absent today. Port 55647 is free, as far as the refused-port lists show.
- The S9-C lane (`clusters/s9-c`) must be stopped. Preflight refuses if any postgres is running or any other lane has a `postmaster.pid`.
