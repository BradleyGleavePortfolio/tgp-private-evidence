#!/usr/bin/env bash
# S8-F real-PG proof — complete source-only execution binding (drafted under S8F-COMP-1; NOT RUN; NOT GRANTED).
# Derived by substitution from the accepted S8-C binding execution/64e33dc7/s8c/binding/v4/s8c-pg-proof.sh with the
# S8-F deltas: port 55643 / s8f_super / g2_s8f_disposable / cluster s8f-disposable-pg17, fresh lane
# recovery-reset/proof-s8f-v1, NO OLD side (S8-F ships no migration and no schema change: the composed head's
# prisma tree — S7-L schema + S8-C/S8-B objects — is the only schema and the proof target is the two READERS), no
# candidate-head env (the S8-F guard/bootstrap read none), and the S8-F bootstrap invoked WITHOUT a subcommand.
# Runs the NEW spec test/rls-g2-s8f.spec.ts exactly once via the repo jest + jest.rls.config.js. No new test
# framework, no retry, no inherited-proof replay (S8-C / S8-B / S7-L / N/Q1 / C / R / B suites are never invoked).
# Single canonical lock holder: the nonblocking flock on execution/test-validation.lock is taken on fd 9 before any
# state change and held until this process exits — through stop, post checks and receipt hashing; the lock file is
# never deleted, stolen or replaced. First nonzero stops; the only cleanup attempted is a bounded fixture stop when
# this run started the postmaster. No autonomous cleanup is GUARANTEED: if the outer timeout kills bash, the stop does
# not run. What governs is the observed terminal evidence — sentinel/log lines, `pgrep -cx postgres`, the port listener
# count and any survivor pid the stop reports — not this header. Data dir RETAINED after stop (destroy = separate grant).
# Harness NOT-NULL audit (COMMIT_READY.md): every NOT NULL no-default column of every table the harness INSERTs into
# is supplied explicitly (User: supabase_id/email/name; ScoutImport: coach_id/intent_id; Ledger; Provenance;
# WorkoutPlan/WorkoutProgram incl. updated_at). Counts in the spec are API page counts over intent-scoped rows after
# resetData(), never absolute table counts; the role-denial count(*) accepts 0 or permission-denied.
# Inner stage bounds: init 60 + start 60 + bootstrap 900 + identity 5x15 + jest 1500 + stop 75 = 2670 s soft sum.
# Usage (later, under the separate single-run PG grant): timeout -k 30 3600 bash .../binding/v1/s8f-pg-proof.sh
set -uo pipefail
D=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8f/binding/v1
RUNTIME_ROOT=/home/user/workspace/execution/64e33dc7/recovery-reset
W=/home/user/workspace/worktrees/daceddc8-s8f
R=$D/run; LOG=$R/s8f-pg-proof.log; SENT=$R/s8f-pg-proof.sentinel; JLOG=$R/jest.log
LOCK=/home/user/workspace/execution/test-validation.lock
# ---- pins: head pins are filled from the committed S8-F head (parent 1c10e2a1); the script refuses placeholders.
BASE_HEAD=1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47                         # accepted composed base (land/s8-c: S7-L + S8-C)
BASE_TREE=aa160557577f821b6f284435d22037e046991202
EXPECT_HEAD=e1ec2fecb71f315b6721d426ba0dacb84f304498
EXPECT_TREE=2fe0201ff132dfdc53ea82b3f26ed0fc8d1c65d6
EXPECT_SPEC_BLOB=77785ec5fa3d0bb15731ba7787c4ede4968eb51d                                     # test/rls-g2-s8f.spec.ts at the S8-F head
EXPECT_BOOTSTRAP_BLOB=5ac2753bdc0498899d1a9eef297ef4acc467ccb8                                # test/utils/g2-s8f-bootstrap.sh
EXPECT_DB_BLOB=aeff4cb0f06d0d65b969bf7742c1d8cf377f4c79                                       # test/utils/g2-s8f-db.ts
EXPECT_PGH_BLOB=a8acd231d10194d4552546339a7a4309c86fb8d4                                      # test/utils/g2-s8f-pg-harness.ts
EXPECT_WORKER_BLOB=aa35e7e2c38f8d1a990a4eac466824963ae866f4                # test/utils/g2-tq0-worker.cjs (unchanged, at base and head)
EXPECT_FIXTURE_SHA=88e8b2f3123b425211ba9e05c2add93b21a7fc6f5ed8d2bfbf9fd2018e362f30                                   # sha256 of binding/v1/s8f-fixture.sh (frozen with this file)
# ---- tool pins (RUNTIME_SETUP_RECEIPT.md, 2026-09-25T03:29:43Z; compare only, never adjusted at run time)
EXPECT_POSTGRES_SHA=23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a
EXPECT_INITDB_SHA=b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a
EXPECT_PGCTL_SHA=af53d826845af4679a0aaba2bda319f5e527f3b94f3794c67fa174049c9b9401
EXPECT_PSQL_SHA=a200e38c89b111d3abdf26927b186fdd423bef3d84f157af0f4b65db6f8e6c94       # readlink -f /usr/bin/psql (18.6)
EXPECT_NODE_SHA=a03953a7b16bff002b94d6fb58ada900b68241cbcaee6efc400b20dadd36dddc       # /usr/local/bin/node v20.20.1
EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44    # node_modules/.package-lock.json (donor land-s8-c)
EXPECT_NM_CLIENT_SHA=9042e713ba5678c99959a345b7b18a60dfc186b2c7d890b8d9c3ed5c8f4edcc6  # node_modules/.prisma/client/index.d.ts (S7-L schema client)
EXPECT_NM_CLIENT_SCHEMA_SHA=b84392033ab86776533007505c31f57930307a210844067a7407ed20d25abf3e  # node_modules/.prisma/client/schema.prisma
EXPECT_SCHEMA_SHA=0eb41f9a88ef3b77266e908a5ea814206c188d1bdb031bd96d746491fee84015      # prisma/schema.prisma @1c10e2a1 (S7-L)
EXPECT_PKG_LOCK_SHA=b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55   # package-lock.json (unchanged since 93389265)
EXPECT_MIGRATIONS=172                                                                   # tracked prisma/migrations dirs @1c10e2a1 (S8-F adds none)
DIST=$RUNTIME_ROOT/pg17/dist; CLUSTERS=$RUNTIME_ROOT/clusters; LANE=$RUNTIME_ROOT/proof-s8f-v1/clusters/s8-f; SOCK=$RUNTIME_ROOT/proof-s8f-v1/run/s8-f
# fresh S8-F lane; every other lane under $RUNTIME_ROOT/clusters/* and $RUNTIME_ROOT/proof-*/clusters/* (S7-L, S8-C v3/v4/v5) is another lane: never adopted, hashed pre/post
PORT=55643; DBNAME=g2_s8f_disposable; ADMIN=s8f_super; FIXPASS=s8f_local_synthetic
FIX=$D/s8f-fixture.sh
export GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1 NODE_OPTIONS=--max-old-space-size=4096 CHECKPOINT_DISABLE=1 \
       PRISMA_HIDE_UPDATE_MESSAGE=1 npm_config_offline=true npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false \
       npm_config_cache=$RUNTIME_ROOT/npm-cache XDG_CACHE_HOME=$RUNTIME_ROOT/xdg-cache
# S8-F-only identity: exactly the G2_S8F_* names the guard/harness/bootstrap read. Nothing G2_S8C_*, G2_S8B_*, G2_S7L_* or earlier is exported.
export G2_S8F_DATABASE_URL="postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=2" \
       G2_S8F_CONFIRM="$DBNAME:$PORT" G2_S8F_PASSWORD=$FIXPASS G2_S8F_PSQL=/usr/bin/psql \
       G2_S8F_SERVER_VERSION=170006
export S8F_RUNNER_PID=$$ S8F_STOP_TIMEOUT=45
mkdir -p "$R"
[ -e "$SENT" ] && { echo "REFUSED: $SENT exists; this proof runs once, no retry" >&2; exit 76; }
[ -e "$LOCK" ] || { echo "REFUSED: canonical lock file $LOCK absent; runtime setup created it and it is never deleted or recreated here" >&2; exit 75; }
exec 9>>"$LOCK"; flock -n 9 || { echo "REFUSED: canonical lock busy ($LOCK)" >&2; exit 75; }
ts(){ date -u +%FT%TZ; }
log(){ echo "$*" | tee -a "$LOG"; }
sha(){ sha256sum "$1" | cut -c1-64; }
STAGE=preconditions; STARTED=0
finish(){ local rc=$1
  ( cd "$R" && sha256sum s8f-pg-proof.log $( [ -e jest.log ] && echo jest.log ) > RECEIPTS.sha256 2>/dev/null )
  echo "RC=$rc STAGE=$STAGE END=$(ts) HEAD=$(git -C "$W" rev-parse HEAD 2>/dev/null) LOCK_INODE=$(stat -c %i "$LOCK")" >"$SENT"
  log "END rc=$rc stage=$STAGE $(ts) (lock fd9 held until this exit; receipts=$R/RECEIPTS.sha256)"; exit "$rc"; }
fail(){ local rc=$1; log "STOP_FIRST_FAILURE stage=$STAGE rc=$rc $(ts)"
  if [ "$STARTED" = 1 ]; then
    local src=0; timeout -k 30 60 bash "$FIX" stop >>"$LOG" 2>&1 || src=$?
    log "CLEANUP_STOP rc=$src postgres_procs=$(pgrep -cx postgres || true) port${PORT}_listeners=$(ss -ltn 2>/dev/null | grep -c ":$PORT " || true) survivor_pid=$(head -1 "$LANE/pg-data/postmaster.pid" 2>/dev/null || echo none)"
  fi
  finish "$rc"; }
log "START $(ts) pid=$$ user=$(id -un) lock=$LOCK(held nonblocking fd9, inode $(stat -c %i "$LOCK")) head_expect=$EXPECT_HEAD fixture_expect=$EXPECT_FIXTURE_SHA"
# ---- preconditions (read-only)
case "$EXPECT_HEAD$EXPECT_TREE$EXPECT_SPEC_BLOB$EXPECT_BOOTSTRAP_BLOB$EXPECT_DB_BLOB$EXPECT_PGH_BLOB$EXPECT_WORKER_BLOB$EXPECT_FIXTURE_SHA" in *__*) log "PRECONDITION_FAIL pins not filled (proposal stage)"; fail 70;; esac
[ "$EXPECT_HEAD" != "$BASE_HEAD" ] || { log "PRECONDITION_FAIL EXPECT_HEAD is the base, not a candidate"; fail 70; }
[ "$(sha "$FIX")" = "$EXPECT_FIXTURE_SHA" ] || { log "PRECONDITION_FAIL fixture sha256 mismatch"; fail 70; }
[ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] || { log "PRECONDITION_FAIL HEAD != $EXPECT_HEAD"; fail 70; }
[ "$(git -C "$W" rev-parse 'HEAD^{tree}')" = "$EXPECT_TREE" ] || { log "PRECONDITION_FAIL tree mismatch"; fail 70; }
[ "$(git -C "$W" rev-parse "$BASE_HEAD^{tree}")" = "$BASE_TREE" ] || { log "PRECONDITION_FAIL base tree mismatch"; fail 70; }
git -C "$W" merge-base --is-ancestor "$BASE_HEAD" HEAD || { log "PRECONDITION_FAIL base $BASE_HEAD not an ancestor"; fail 70; }
[ "$(git -C "$W" rev-parse HEAD^)" = "$BASE_HEAD" ] || { log "PRECONDITION_FAIL head is not exactly one commit on the base"; fail 70; }
for pin in "test/rls-g2-s8f.spec.ts $EXPECT_SPEC_BLOB" "test/utils/g2-s8f-bootstrap.sh $EXPECT_BOOTSTRAP_BLOB" "test/utils/g2-s8f-db.ts $EXPECT_DB_BLOB" \
           "test/utils/g2-s8f-pg-harness.ts $EXPECT_PGH_BLOB" "test/utils/g2-tq0-worker.cjs $EXPECT_WORKER_BLOB"; do set -- $pin
  [ "$(git -C "$W" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL S8-F proof file $1 blob mismatch"; fail 70; }; done
[ "$(git -C "$W" ls-files -s test/utils/g2-s8f-bootstrap.sh | cut -c1-6)" = 100755 ] || { log "PRECONDITION_FAIL bootstrap not executable in the tree"; fail 70; }
[ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] || { log "PRECONDITION_FAIL worktree not clean"; fail 70; }
[ ! -e "$(git -C "$W" rev-parse --git-path MERGE_HEAD)" ] || { log "PRECONDITION_FAIL MERGE_HEAD present"; fail 70; }
# the committed head must have been produced through the tracked lefthook hooks
H=$(git -C "$W" rev-parse --git-path hooks); case "$H" in /*) ;; *) H="$W/$H";; esac
grep -q lefthook "$H/pre-commit" 2>/dev/null && grep -q lefthook "$H/commit-msg" 2>/dev/null \
  || { log "PRECONDITION_FAIL $H/pre-commit or commit-msg absent or not lefthook (hookless commit)"; fail 70; }
# S8-F ships no schema/migration change and touches no accepted S8-C / S8-B / S7-L proof file, native writer, generator or jest.rls config
[ -z "$(git -C "$W" diff --name-only "$BASE_HEAD" HEAD -- prisma)" ] || { log "PRECONDITION_FAIL prisma tree differs from base"; fail 70; }
for pin in "test/utils/g2-s8c-db.ts a7d67217fe959f65daae9615e5f00806cc3764d3" "test/utils/g2-s8c-bootstrap.sh 7c3fba471f991e3750eb56fd29e271101652196e" \
           "test/rls-g2-s8c.spec.ts 9d701783eeb7701126d158b45bfee3d5f0f686b3" "src/scout/reconstruct/native dfd8ef66fd0ebe1fab0380de9e6b378bb16b39c2" \
           "prisma/schema.prisma 2e328bbcab0c902c6adb55dfb5ee172defc5f698" "scripts/ci/supabase-shim.sql 0f99f9249959acd6d3b3990808c85228b1a8a87b" \
           "jest.rls.config.js 44c9691533be2ea27f9a416271d9ff400f7faa3f"; do set -- $pin
  [ "$(git -C "$W" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL accepted file $1 changed (blob != base)"; fail 70; }; done
# the delta vs base is exactly the 17 S8-F commit paths (6 src, 10 test, 1 regenerated contract artifact)
[ "$(git -C "$W" diff --name-only "$BASE_HEAD" HEAD | wc -l)" = 17 ] || { log "PRECONDITION_FAIL base..head delta is not 17 paths"; fail 70; }
[ -z "$(git -C "$W" diff --name-only "$BASE_HEAD" HEAD | grep -vE '^(src/scout/scout-(entities|roster)\.(controller|dto|service)\.ts|test/(rls-g2-s8f\.spec\.ts|scout/g2-s8f-db-guard\.spec\.ts|utils/g2-s8f-(bootstrap\.sh|db\.ts|pg-harness\.ts)|scout/(entities|roster)/scout-(entities|roster)\.(contract|service|controller)\.spec\.ts|contracts/importer-contract\.spec\.ts)|docs/contracts/importer-openapi\.json)$')" ] \
  || { log "PRECONDITION_FAIL base..head touches a path outside the S8-F surface"; fail 70; }
# dependency tree: an ISOLATED real copy of the runtime donor (not a symlink, not platform node_modules, not a fresh npm ci)
[ -d "$W/node_modules" ] && [ ! -L "$W/node_modules" ] || { log "PRECONDITION_FAIL $W/node_modules absent or a symlink (isolated copy required)"; fail 70; }
case "$(readlink -f "$W/node_modules")" in "$W"/*) ;; *) log "PRECONDITION_FAIL node_modules resolves outside $W"; fail 70;; esac
[ "$(sha "$W/package-lock.json")" = "$EXPECT_PKG_LOCK_SHA" ] || { log "PRECONDITION_FAIL package-lock.json != record"; fail 70; }
[ "$(sha "$W/node_modules/.package-lock.json")" = "$EXPECT_NM_LOCK_SHA" ] || { log "PRECONDITION_FAIL node_modules/.package-lock.json != donor record"; fail 70; }
[ "$(sha "$W/prisma/schema.prisma")" = "$EXPECT_SCHEMA_SHA" ] || { log "PRECONDITION_FAIL prisma/schema.prisma != 0eb41f9a"; fail 70; }
[ "$(sha "$W/node_modules/.prisma/client/index.d.ts")" = "$EXPECT_NM_CLIENT_SHA" ] || { log "PRECONDITION_FAIL generated client != donor record (no S8-F generate expected)"; fail 70; }
[ "$(sha "$W/node_modules/.prisma/client/schema.prisma")" = "$EXPECT_NM_CLIENT_SCHEMA_SHA" ] || { log "PRECONDITION_FAIL generated client schema != donor record"; fail 70; }
cmp -s "$W/node_modules/.prisma/client/schema.prisma" "$W/prisma/schema.prisma" || log "NOTE client schema.prisma bytes differ from prisma/schema.prisma (generator normalises; identity is the sha pins above)"
[ -x "$W/node_modules/.bin/jest" ] && [ -x "$W/node_modules/.bin/ts-node" ] && [ -x "$W/node_modules/.bin/prisma" ] || { log "PRECONDITION_FAIL jest/ts-node/prisma missing"; fail 70; }
[ "$(find "$W/prisma/migrations" -mindepth 1 -maxdepth 1 -type d | wc -l)" = "$EXPECT_MIGRATIONS" ] || { log "PRECONDITION_FAIL tracked migrations != $EXPECT_MIGRATIONS"; fail 70; }
# tools: pinned PG 17.6 server binaries in the fresh namespace, the recorded psql 18.6 client and Node 20
[ -x "$DIST/bin/postgres" ] && [ -x "$DIST/bin/initdb" ] && [ -x "$DIST/bin/pg_ctl" ] || { log "PRECONDITION_FAIL PG17 dist absent at $DIST"; fail 70; }
[ "$(sha "$DIST/bin/postgres")" = "$EXPECT_POSTGRES_SHA" ] || { log "PRECONDITION_FAIL postgres binary sha256 != pin"; fail 70; }
[ "$(sha "$DIST/bin/initdb")" = "$EXPECT_INITDB_SHA" ] || { log "PRECONDITION_FAIL initdb binary sha256 != pin"; fail 70; }
[ "$(sha "$DIST/bin/pg_ctl")" = "$EXPECT_PGCTL_SHA" ] || { log "PRECONDITION_FAIL pg_ctl binary sha256 != pin"; fail 70; }
PGV=$(LD_LIBRARY_PATH=$DIST/lib "$DIST/bin/postgres" --version 2>/dev/null); [ "${PGV##* }" = 17.6 ] || { log "PRECONDITION_FAIL server not 17.6: $PGV"; fail 70; }
[ -x /usr/bin/psql ] && [ "$(sha "$(readlink -f /usr/bin/psql)")" = "$EXPECT_PSQL_SHA" ] || { log "PRECONDITION_FAIL /usr/bin/psql absent or sha256 != pin"; fail 70; }
NODE=$(command -v node); [ "$(sha "$(readlink -f "$NODE")")" = "$EXPECT_NODE_SHA" ] || { log "PRECONDITION_FAIL node sha256 != pin ($NODE)"; fail 70; }
node --version | grep -q '^v20\.' || { log "PRECONDITION_FAIL node major != 20"; fail 70; }
[ "$(readlink -f "$RUNTIME_ROOT")" = "$RUNTIME_ROOT" ] || { log "PRECONDITION_FAIL $RUNTIME_ROOT is not a real path"; fail 70; }
grep -q '^result=success' "$RUNTIME_ROOT/pg17/PROVENANCE.txt" 2>/dev/null || { log "PRECONDITION_FAIL pg17 PROVENANCE.txt lacks result=success"; fail 70; }
log "PRECONDITIONS_OK $(ts) server='$PGV' psql='$(/usr/bin/psql --version)' node=$(node --version) jest=$(cd "$W" && ./node_modules/.bin/jest --version) ts_node=$(cd "$W" && ./node_modules/.bin/ts-node --version 2>/dev/null | head -1) prisma=$(cd "$W" && ./node_modules/.bin/prisma --version 2>/dev/null | awk '/^prisma /{print $3}')"
# ---- step 1 preflight (read-only): S8-F lane absent; port 55643 free; no postgres; other lanes under the runtime root recorded and never started
STAGE=preflight
[ ! -e "$LANE" ] || { log "PREFLIGHT_FAIL $LANE exists (fresh init only; never adopt)"; fail 71; }
[ ! -e "$SOCK" ] || [ -z "$(ls -A "$SOCK" 2>/dev/null)" ] || { log "PREFLIGHT_FAIL socket dir $SOCK not empty"; fail 71; }
L=$(ss -ltn 2>/dev/null | grep -c ":$PORT " || true); [ "$L" = 0 ] || { log "PREFLIGHT_FAIL port $PORT listeners=$L"; fail 71; }
P=$(pgrep -cx postgres || true); [ "$P" = 0 ] || { log "PREFLIGHT_FAIL postgres procs=$P (another lane live; this proof never shares a server)"; fail 71; }
OTHER0=""
for d in "$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-*/clusters/*/; do [ -d "$d" ] || continue; [ "${d%/}" != "$LANE" ] || continue; n=${d#$RUNTIME_ROOT/}; n=${n%/}
  [ ! -e "$d/pg-data/postmaster.pid" ] || { log "PREFLIGHT_FAIL $n postmaster.pid present"; fail 71; }
  h="$n:$(sha "$d/pg-data/postgresql.conf" 2>/dev/null || echo ABSENT):$(sha "$d/pg-data/global/pg_control" 2>/dev/null || echo ABSENT)"; OTHER0="$OTHER0 $h"
  log "PREFLIGHT other_lane=$h (must be unchanged at end; never started)"; done
[ -e "$CLUSTERS" ] || log "PREFLIGHT clusters_dir=ABSENT (legacy v3 root not present)"
PORC0=$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)
log "PREFLIGHT_OK $(ts) lane=absent port$PORT=free postgres_procs=0 worktree_porcelain_sha=$PORC0 lock_inode=$(stat -c %i "$LOCK")"
# ---- step 2 init (bound 60 s)
STAGE=fixture-init; timeout -k 30 60 bash "$FIX" init >>"$LOG" 2>&1; rc=$?; log "FIXTURE_INIT rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^S8F_FIXTURE_INIT_OK data=$LANE/pg-data port=$PORT superuser=$ADMIN cluster_name=s8f-disposable-pg17" "$LOG" || { log "FIXTURE_INIT marker missing"; fail 72; }
# ---- step 3 start (bound 60 s)
STAGE=fixture-start; STARTED=1; timeout -k 30 60 bash "$FIX" start >>"$LOG" 2>&1; rc=$?; log "FIXTURE_START rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^S8F_FIXTURE_START_OK pid=" "$LOG" || { log "FIXTURE_START marker missing"; fail 72; }
# ---- step 4 S8-F bootstrap (committed helper at the attested head, NO subcommand: roles, marked DB, shim, extensions,
#      the whole accepted 172-migration history through the candidate's `prisma migrate deploy` as postgres, S8-B
#      catalog shape asserted (ImportNativeProvenance, Ledger.target_kind), applied == tracked — no generate) (bound 900 s)
STAGE=bootstrap
( cd "$W" && timeout -k 30 900 bash test/utils/g2-s8f-bootstrap.sh ) >>"$LOG" 2>&1; rc=$?; log "BOOTSTRAP rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^G2_S8F_BOOTSTRAP_OK" "$LOG" || { log "BOOTSTRAP marker missing"; fail 72; }
# ---- step 5 identity (read-only, bound 15 s each; admin login with PGPASSWORD only, never a URL password)
STAGE=identity
psqlq(){ PGPASSWORD=$FIXPASS timeout -k 30 15 /usr/bin/psql -X -v ON_ERROR_STOP=1 -At "postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME" -c "$1" 2>>"$LOG"; }
DD=$(psqlq 'SHOW data_directory'); [ "$DD" = "$LANE/pg-data" ] || { log "IDENTITY_FAIL data_directory='$DD'"; fail 73; }
VN=$(psqlq 'SHOW server_version_num'); [ "$VN" = 170006 ] || { log "IDENTITY_FAIL server_version_num='$VN'"; fail 73; }
CN=$(psqlq "SELECT current_setting('cluster_name')"); [ "$CN" = s8f-disposable-pg17 ] || { log "IDENTITY_FAIL cluster_name='$CN'"; fail 73; }
DM=$(psqlq "SELECT shobj_description(oid,'pg_database') FROM pg_database WHERE datname=current_database()")
[ "$DM" = s8f-g2-native-reader-synthetic-disposable-fixture-safe-to-drop ] || { log "IDENTITY_FAIL db marker='$DM'"; fail 73; }
MC=$(psqlq 'SELECT count(*) FROM "_prisma_migrations" WHERE finished_at IS NOT NULL AND rolled_back_at IS NULL'); [ "$MC" = "$EXPECT_MIGRATIONS" ] || { log "IDENTITY_FAIL applied migrations=$MC"; fail 73; }
# db-guard note: the S8-F guard (test/scout/g2-s8f-db-guard.spec.ts) pins markers/ports only and asserts NO migration list; the
# bootstrap asserts applied == tracked dynamically. This runner additionally pins the tracked count (172) so that only the
# base-prefix history (S7-L + S8-C composed head; S8-F adds no migration) can satisfy the identity stage.
log "IDENTITY_OK $(ts) data_directory=$DD server_version_num=$VN cluster_name=$CN applied_migrations=$MC"
# ---- step 6 the proof, exactly once (bound 1500 s); no --testTimeout/--forceExit/--detectOpenHandles/coverage
STAGE=jest; log "JEST_START $(ts) cmd='./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s8f.spec.ts --runInBand --ci' head=$EXPECT_HEAD"
( cd "$W" && timeout -k 30 1500 ./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s8f.spec.ts --runInBand --ci ) >"$JLOG" 2>&1; JRC=$?
log "JEST_END rc=$JRC $(ts)"; grep -E '^(Test Suites|Tests|Snapshots|Time):' "$JLOG" | tee -a "$LOG"
grep -E 'requires an explicitly acknowledged|not the permitted disposable database|server identity mismatch|G2 proof requires|uncommitted changes|fixture marker' "$JLOG" >/dev/null && log "GUARD_REFUSAL_OBSERVED_IN_JEST_LOG"
[ $JRC = 0 ] || fail $JRC
# ---- step 7 stop (bound 45 s + kill 30); data dir RETAINED (destroy only via separate grant: s8f-fixture.sh destroy)
STAGE=fixture-stop; STARTED=0; timeout -k 30 75 bash "$FIX" stop >>"$LOG" 2>&1; rc=$?; log "FIXTURE_STOP rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
P=$(pgrep -cx postgres || true); L=$(ss -ltn 2>/dev/null | grep -c ":$PORT " || true)
[ "$P" = 0 ] && [ "$L" = 0 ] && [ ! -e "$LANE/pg-data/postmaster.pid" ] && [ -d "$LANE/pg-data" ] || { log "STOP_STATE_FAIL postgres_procs=$P listeners=$L"; fail 74; }
log "STOP_STATE_OK postgres_procs=0 port$PORT=free datadir_retained=$LANE/pg-data"
# ---- step 8 post (read-only)
STAGE=post
OTHER1=""
for d in "$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-*/clusters/*/; do [ -d "$d" ] || continue; [ "${d%/}" != "$LANE" ] || continue; n=${d#$RUNTIME_ROOT/}; n=${n%/}
  [ ! -e "$d/pg-data/postmaster.pid" ] || { log "POST_FAIL $n postmaster.pid appeared"; fail 74; }
  OTHER1="$OTHER1 $n:$(sha "$d/pg-data/postgresql.conf" 2>/dev/null || echo ABSENT):$(sha "$d/pg-data/global/pg_control" 2>/dev/null || echo ABSENT)"; done
[ "$OTHER0" = "$OTHER1" ] || { log "POST_FAIL other lanes changed: before=[$OTHER0] after=[$OTHER1]"; fail 74; }
log "POST other_lanes_unchanged=[${OTHER0:-none}]"
[ "$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)" = "$PORC0" ] && [ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] || { log "POST_FAIL worktree changed"; fail 74; }
[ "$(sha "$W/node_modules/.prisma/client/index.d.ts")" = "$EXPECT_NM_CLIENT_SHA" ] || { log "POST_FAIL generated client changed during the proof"; fail 74; }
log "POST_OK $(ts) lock_still_held_fd9 inode=$(stat -c %i "$LOCK")"
STAGE=done; finish 0
