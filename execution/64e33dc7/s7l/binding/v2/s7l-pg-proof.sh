#!/usr/bin/env bash
# S7-L real-PG proof — binding v2 (S7L_MINIMUM_CORRECTION_GRANT: F1 classifyClosed guard, F2 L06 SET ROLE entry). Bound to
# the ORDINARY FOLLOW-UP commit whose exact parent is the preserved v1 candidate 839b54c53ccb252f95b4ec63df0b08595bbe7698
# (itself directly on the accepted base 93389265). Identical to binding/s7l-pg-proof.sh (v1) except: versioned paths
# (binding/v2, run receipts under binding/v2/run), EXPECT_PARENT pin + follow-up lineage/delta checks, and the candidate
# head/tree/spec-blob/fixture pins filled by freeze-v2.sh. NOT RUN; NOT GRANTED. Derived as a code pattern from the
# S8-C/S8-B binding shape with the S7-L deltas: port 55641 / s7l_super / g2_s7l_disposable / cluster s7l-disposable-pg17,
# an OLD side (detached checkout of the base 93389265 created offline by the committed helper test/utils/g2-s7l-old-root.sh;
# the OLD `prisma migrate deploy` installs the whole accepted 171-migration history so that the candidate has EXACTLY ONE
# migration pending, applied by the spec itself in L01), an independently generated OLD client inside the OLD root, and
# the committed S7-L bootstrap/spec. Runs the NEW spec test/rls-g2-s7l.spec.ts exactly once via the repo jest +
# jest.rls.config.js. No new test framework, no retry, no inherited-proof replay (S8-B / S8-C / N/Q1 / C / R / B suites are
# never invoked).
# Single canonical lock holder: the nonblocking flock on execution/test-validation.lock is taken on fd 9 before any state
# change and held until this process exits — through stop, post checks and receipt hashing; the lock file is never deleted.
# First nonzero stops; the only cleanup attempted is a bounded fixture stop when this run started the postmaster. No
# autonomous cleanup is GUARANTEED: if the outer timeout kills bash, the stop does not run. What governs is the observed
# terminal evidence — sentinel/log lines, `pgrep -cx postgres`, the port listener count and any survivor pid the stop
# reports — not this header. Data dir RETAINED after stop (destroy = separate marker-gated decision, s7l-fixture.sh destroy).
# Inner stage bounds: init 60 + start 60 + old-root 180 + bootstrap 900 + identity 6x15 + jest 1800 + stop 75 = 3165 s soft sum.
# Usage (later, under the separate single-run PG grant, after two independent attestations of head + this filled binding):
#   timeout -k 30 3900 bash /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v2/s7l-pg-proof.sh
set -uo pipefail
D=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v2
RUNTIME_ROOT=/home/user/workspace/execution/64e33dc7/recovery-reset
W=/home/user/workspace/worktrees/64e33dc7-s7l
R=$D/run; LOG=$R/s7l-pg-proof.log; SENT=$R/s7l-pg-proof.sentinel; JLOG=$R/jest.log
LOCK=/home/user/workspace/execution/test-validation.lock
# ---- head pins (filled 2026-09-25 from the committed, clean head; see PINS.txt for the derivation commands)
BASE_HEAD=93389265a846095b846fa8f1fb0dad782fb6ee9f                         # accepted S8-B head; identical in g2-s7l-db.ts/bootstrap/old-root/pg-harness
BASE_TREE=a315dd651b8c54c2e82f2260fcc6058f0d13b64a
EXPECT_PARENT=839b54c53ccb252f95b4ec63df0b08595bbe7698                       # v1 candidate: the exact parent of the ordinary follow-up commit
EXPECT_HEAD=54970cd937afc8dea689b33243961abfef8b9dd6                                  # v2 candidate head (F1/F2 minimum correction), filled by freeze-v2.sh
EXPECT_TREE=513c71d7c1390787e1521ccbfa46b30bb52b5462
EXPECT_SPEC_BLOB=052fa35d5c03658a5ee90cebe5e6eca467311d0d                   # test/rls-g2-s7l.spec.ts
EXPECT_BOOTSTRAP_BLOB=ebef51fcd355282a222b8f7f789fdfedcb86370c              # test/utils/g2-s7l-bootstrap.sh
EXPECT_OLDROOT_BLOB=cb1137fe7327d456ebd1afa33333f58cba602ea0                # test/utils/g2-s7l-old-root.sh
EXPECT_DB_BLOB=384e1b746bdcace15b7ed51db23b365557ee72de                     # test/utils/g2-s7l-db.ts
EXPECT_PGH_BLOB=d8b71d68da9a1e823ebd9c334d99798da5d12de8                    # test/utils/g2-s7l-pg-harness.ts
EXPECT_HARNESS_BLOB=f0860a8da9fd709dfa8178d9c61415ee6dcb05ff                # test/utils/g2-s7l-harness.ts
EXPECT_WORKER_BLOB=a8fed545d68d1536171de0892f33ef8a9abf2f3e                 # test/utils/g2-s7l-worker.cjs
EXPECT_GUARD_BLOB=27fcba5fcb088f8e16a5316ed5be2a427e7c70fe                  # test/scout/g2-s7l-db-guard.spec.ts
EXPECT_MIGRATION_TREE=4ce576460c7ae325f3ec778d9d616ab766290f29              # prisma/migrations/20270123000000_scout_run_lifecycle_expand (tree)
EXPECT_SCHEMA_BLOB=2e328bbcab0c902c6adb55dfb5ee172defc5f698                 # prisma/schema.prisma at head
EXPECT_FIXTURE_SHA=dc77a7c9b52a439914fe0fdb0903bd6a55b1f47a692a5cda0a22c3a6522b3dd2                                     # sha256 of binding/s7l-fixture.sh (frozen with this file by freeze.sh)
# ---- tool pins (RUNTIME_SETUP_RECEIPT.md 03:29:43Z + read-only sha256 at fill time 04:2xZ; compare only, never adjusted at run time)
EXPECT_POSTGRES_SHA=23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a
EXPECT_INITDB_SHA=b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a
EXPECT_PGCTL_SHA=af53d826845af4679a0aaba2bda319f5e527f3b94f3794c67fa174049c9b9401
EXPECT_PSQL_SHA=a200e38c89b111d3abdf26927b186fdd423bef3d84f157af0f4b65db6f8e6c94       # readlink -f /usr/bin/psql (pg_wrapper, psql 18.6)
EXPECT_NODE_SHA=a03953a7b16bff002b94d6fb58ada900b68241cbcaee6efc400b20dadd36dddc       # /usr/local/bin/node v20.20.1
EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44    # node_modules/.package-lock.json (donor, isolated copy)
EXPECT_NM_CLIENT_SHA=9042e713ba5678c99959a345b7b18a60dfc186b2c7d890b8d9c3ed5c8f4edcc6  # node_modules/.prisma/client/index.d.ts generated in-lane from schema 0eb41f9a
EXPECT_SCHEMA_SHA=0eb41f9a88ef3b77266e908a5ea814206c188d1bdb031bd96d746491fee84015     # prisma/schema.prisma (S7-L hunk)
EXPECT_PKG_LOCK_SHA=b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55   # package-lock.json @93389265 (unchanged)
EXPECT_JEST_RLS_CFG_SHA=99c9f4f1d7be881373b84a3489c7aa207f862810a20724185ff5f20e028e548b # jest.rls.config.js (blob 44c96915 = base)
DIST=$RUNTIME_ROOT/pg17/dist; CLUSTERS=$RUNTIME_ROOT/clusters; LANE=$CLUSTERS/s7l; SOCK=$RUNTIME_ROOT/run/s7l
OLDROOT=$RUNTIME_ROOT/s7l/old-root; OLDCLIENT=$OLDROOT/.g2-s7l-old-client
PORT=55641; DBNAME=g2_s7l_disposable; ADMIN=s7l_super; FIXPASS=s7l_local_synthetic
CLUSTER_MARKER=s7l-disposable-pg17; DB_MARKER=s7l-g2-run-lifecycle-synthetic-disposable-fixture-safe-to-drop
FIX=$D/s7l-fixture.sh
export GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1 NODE_OPTIONS=--max-old-space-size=4096 CHECKPOINT_DISABLE=1 \
       PRISMA_HIDE_UPDATE_MESSAGE=1 PRISMA_GENERATE_SKIP_AUTOINSTALL=1 npm_config_offline=true npm_config_update_notifier=false \
       npm_config_fund=false npm_config_audit=false npm_config_cache=$RUNTIME_ROOT/npm-cache XDG_CACHE_HOME=$RUNTIME_ROOT/xdg-cache
# S7-L-only identity: exactly the G2_S7L_* names the guard/harness/bootstrap read. Nothing G2_S8B_*, G2_S8C_* or earlier is exported.
export G2_S7L_DATABASE_URL="postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=4" \
       G2_S7L_CONFIRM="$DBNAME:$PORT" G2_S7L_PASSWORD=$FIXPASS G2_S7L_PSQL=/usr/bin/psql \
       G2_S7L_DATA_DIRECTORY=$LANE/pg-data G2_S7L_SERVER_VERSION=170006 \
       G2_S7L_OLD_ROOT=$OLDROOT G2_S7L_OLD_CLIENT=$OLDCLIENT
export S7L_RUNNER_PID=$$ S7L_STOP_TIMEOUT=45
mkdir -p "$R"
[ -e "$SENT" ] && { echo "REFUSED: $SENT exists; this proof runs once, no retry" >&2; exit 76; }
[ -e "$LOCK" ] || { echo "REFUSED: canonical lock file $LOCK absent; runtime setup created it and it is never deleted or recreated here" >&2; exit 75; }
exec 9>>"$LOCK"; flock -n 9 || { echo "REFUSED: canonical lock busy ($LOCK)" >&2; exit 75; }
ts(){ date -u +%FT%TZ; }
log(){ echo "$*" | tee -a "$LOG"; }
sha(){ sha256sum "$1" | cut -c1-64; }
STAGE=preconditions; STARTED=0
finish(){ local rc=$1
  ( cd "$R" && sha256sum s7l-pg-proof.log $( [ -e jest.log ] && echo jest.log ) > RECEIPTS.sha256 2>/dev/null )
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
case "$EXPECT_FIXTURE_SHA$EXPECT_HEAD$EXPECT_TREE$EXPECT_SPEC_BLOB" in *__*) log "PRECONDITION_FAIL v2 pins not frozen (run freeze-v2.sh after the follow-up commit)"; fail 70;; esac
[ "$EXPECT_HEAD" != "$BASE_HEAD" ] && [ "$EXPECT_HEAD" != "$EXPECT_PARENT" ] || { log "PRECONDITION_FAIL EXPECT_HEAD is the base or the v1 parent, not the v2 candidate"; fail 70; }
[ "$(sha "$FIX")" = "$EXPECT_FIXTURE_SHA" ] || { log "PRECONDITION_FAIL fixture sha256 mismatch"; fail 70; }
[ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] || { log "PRECONDITION_FAIL HEAD != $EXPECT_HEAD"; fail 70; }
[ "$(git -C "$W" rev-parse 'HEAD^{tree}')" = "$EXPECT_TREE" ] || { log "PRECONDITION_FAIL tree mismatch"; fail 70; }
[ "$(git -C "$W" rev-parse "$BASE_HEAD^{tree}")" = "$BASE_TREE" ] || { log "PRECONDITION_FAIL base tree mismatch"; fail 70; }
# ordinary follow-up lineage: HEAD^ is exactly the v1 candidate (never amended/replaced), whose own parent is the accepted base
[ "$(git -C "$W" rev-parse HEAD^)" = "$EXPECT_PARENT" ] || { log "PRECONDITION_FAIL HEAD parent != $EXPECT_PARENT (ordinary follow-up on the preserved v1 candidate expected)"; fail 70; }
[ "$(git -C "$W" rev-parse "$EXPECT_PARENT^")" = "$BASE_HEAD" ] || { log "PRECONDITION_FAIL v1 parent $EXPECT_PARENT does not sit directly on the accepted base"; fail 70; }
[ "$(git -C "$W" rev-parse "$EXPECT_PARENT^{tree}")" = f02205c60ad0bfeb24ce82d74b0025ee9a185df6 ] || { log "PRECONDITION_FAIL v1 parent tree changed (839b54c5 must be preserved byte-for-byte)"; fail 70; }
git -C "$W" merge-base --is-ancestor "$BASE_HEAD" HEAD || { log "PRECONDITION_FAIL base $BASE_HEAD not an ancestor"; fail 70; }
# the follow-up delta from v1 is exactly the three granted correction paths
[ "$(git -C "$W" diff --name-only "$EXPECT_PARENT" HEAD | sort | tr '\n' ' ')" = \
  "src/scout/lifecycle/lifecycle.service.ts test/rls-g2-s7l.spec.ts test/scout/lifecycle/lifecycle.service.spec.ts " ] \
  || { log "PRECONDITION_FAIL follow-up delta from v1 is not exactly the three granted F1/F2 paths"; fail 70; }
for pin in "test/rls-g2-s7l.spec.ts $EXPECT_SPEC_BLOB" "test/utils/g2-s7l-bootstrap.sh $EXPECT_BOOTSTRAP_BLOB" "test/utils/g2-s7l-old-root.sh $EXPECT_OLDROOT_BLOB" \
           "test/utils/g2-s7l-db.ts $EXPECT_DB_BLOB" "test/utils/g2-s7l-pg-harness.ts $EXPECT_PGH_BLOB" "test/utils/g2-s7l-harness.ts $EXPECT_HARNESS_BLOB" \
           "test/utils/g2-s7l-worker.cjs $EXPECT_WORKER_BLOB" "test/scout/g2-s7l-db-guard.spec.ts $EXPECT_GUARD_BLOB" \
           "prisma/migrations/20270123000000_scout_run_lifecycle_expand $EXPECT_MIGRATION_TREE" "prisma/schema.prisma $EXPECT_SCHEMA_BLOB"; do set -- $pin
  [ "$(git -C "$W" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL S7-L proof file $1 object mismatch"; fail 70; }; done
[ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] || { log "PRECONDITION_FAIL worktree not clean"; fail 70; }
[ ! -e "$(git -C "$W" rev-parse --git-path MERGE_HEAD)" ] || { log "PRECONDITION_FAIL MERGE_HEAD present"; fail 70; }
git -C "$W" log -1 --format='%an <%ae> / %cn <%ce>' | grep -qx 'Bradley Gleave <bradley@bradleytgpcoaching.com> / Bradley Gleave <bradley@bradleytgpcoaching.com>' || { log "PRECONDITION_FAIL author/committer identity"; fail 70; }
H=$(git -C "$W" rev-parse --git-path hooks); case "$H" in /*) ;; *) H="$W/$H";; esac
grep -q lefthook "$H/pre-commit" 2>/dev/null && grep -q lefthook "$H/commit-msg" 2>/dev/null \
  || { log "PRECONDITION_FAIL $H/pre-commit or commit-msg absent or not lefthook (hookless commit)"; fail 70; }
# the candidate's migration delta from the base is exactly S7-L's two files (bootstrap/old-root repeat this gate)
[ "$(git -C "$W" diff --name-only "$BASE_HEAD" HEAD -- prisma/migrations | sort | tr '\n' ' ')" = \
  "prisma/migrations/20270123000000_scout_run_lifecycle_expand/down.sql prisma/migrations/20270123000000_scout_run_lifecycle_expand/migration.sql " ] \
  || { log "PRECONDITION_FAIL migration delta is not exactly S7-L's two files"; fail 70; }
# accepted S8-B proof files, the S8-C-owned reconstruct service and jest.rls.config.js are untouched by this candidate (blob == base)
for pin in "test/utils/g2-s8b-db.ts" "test/utils/g2-s8b-pg-harness.ts" "test/utils/g2-s8b-harness.ts" "test/utils/g2-s8b-bootstrap.sh" "test/utils/g2-s8b-old-root.sh" \
           "test/scout/g2-s8b-db-guard.spec.ts" "test/rls-g2-s8b.spec.ts" "prisma/migrations/20270122000000_scout_native_provenance_expand" \
           "src/scout/scout-reconstruct.service.ts" "jest.rls.config.js" "package.json" "package-lock.json" "lefthook.yml" ".github"; do
  [ "$(git -C "$W" rev-parse "HEAD:$pin")" = "$(git -C "$W" rev-parse "$BASE_HEAD:$pin")" ] || { log "PRECONDITION_FAIL $pin changed from base (out of S7-L surface)"; fail 70; }; done
# dependency tree: an ISOLATED real copy of the runtime donor (not a symlink, not platform node_modules, not a fresh npm ci)
[ -d "$W/node_modules" ] && [ ! -L "$W/node_modules" ] || { log "PRECONDITION_FAIL $W/node_modules absent or a symlink (isolated copy required)"; fail 70; }
case "$(readlink -f "$W/node_modules")" in "$W"/*) ;; *) log "PRECONDITION_FAIL node_modules resolves outside $W"; fail 70;; esac
[ "$(sha "$W/package-lock.json")" = "$EXPECT_PKG_LOCK_SHA" ] || { log "PRECONDITION_FAIL package-lock.json != base record"; fail 70; }
[ "$(sha "$W/node_modules/.package-lock.json")" = "$EXPECT_NM_LOCK_SHA" ] || { log "PRECONDITION_FAIL node_modules/.package-lock.json != donor record"; fail 70; }
[ "$(sha "$W/prisma/schema.prisma")" = "$EXPECT_SCHEMA_SHA" ] || { log "PRECONDITION_FAIL prisma/schema.prisma != 0eb41f9a"; fail 70; }
[ "$(sha "$W/node_modules/.prisma/client/index.d.ts")" = "$EXPECT_NM_CLIENT_SHA" ] || { log "PRECONDITION_FAIL generated candidate client != in-lane generate record 9042e713 (bootstrap verifies, never regenerates)"; fail 70; }
[ "$(sha "$W/jest.rls.config.js")" = "$EXPECT_JEST_RLS_CFG_SHA" ] || { log "PRECONDITION_FAIL jest.rls.config.js sha mismatch"; fail 70; }
[ -x "$W/node_modules/.bin/jest" ] && [ -x "$W/node_modules/.bin/ts-node" ] && [ -x "$W/node_modules/.bin/prisma" ] || { log "PRECONDITION_FAIL jest/ts-node/prisma missing"; fail 70; }
[ ! -e "$W/node_modules/.bin/prettier" ] || { log "PRECONDITION_FAIL prettier inside the product tree (tooling must stay isolated)"; fail 70; }
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
log "PRECONDITIONS_OK $(ts) server='$PGV' psql='$(/usr/bin/psql --version)' node=$(node --version) jest=$(cd "$W" && ./node_modules/.bin/jest --version) ts_node=$(cd "$W" && ./node_modules/.bin/ts-node --version 2>/dev/null) prisma=$(cd "$W" && ./node_modules/.bin/prisma --version 2>/dev/null | grep -E '^prisma ' | tr -s ' ')"
# ---- step 1 preflight (read-only): S7-L lane + OLD root absent; port 55641 free; no postgres; other lanes under the runtime root recorded and never started
STAGE=preflight
[ ! -e "$LANE" ] || { log "PREFLIGHT_FAIL $LANE exists (fresh init only; never adopt)"; fail 71; }
[ ! -e "$OLDROOT" ] || { log "PREFLIGHT_FAIL $OLDROOT exists (fresh detached checkout only)"; fail 71; }
[ ! -e "$SOCK" ] || [ -z "$(ls -A "$SOCK" 2>/dev/null)" ] || { log "PREFLIGHT_FAIL socket dir $SOCK not empty"; fail 71; }
L=$(ss -ltn 2>/dev/null | grep -c ":$PORT " || true); [ "$L" = 0 ] || { log "PREFLIGHT_FAIL port $PORT listeners=$L"; fail 71; }
P=$(pgrep -cx postgres || true); [ "$P" = 0 ] || { log "PREFLIGHT_FAIL postgres procs=$P (another lane live; this proof never shares a server)"; fail 71; }
OTHER0=""
for d in "$CLUSTERS"/*/; do [ -d "$d" ] || continue; n=$(basename "$d"); [ "$n" != s7l ] || continue
  [ ! -e "$d/pg-data/postmaster.pid" ] || { log "PREFLIGHT_FAIL $n postmaster.pid present"; fail 71; }
  h="$n:$(sha "$d/pg-data/postgresql.conf" 2>/dev/null || echo ABSENT):$(sha "$d/pg-data/global/pg_control" 2>/dev/null || echo ABSENT)"; OTHER0="$OTHER0 $h"
  log "PREFLIGHT other_lane=$h (must be unchanged at end; never started)"; done
[ -e "$CLUSTERS" ] || log "PREFLIGHT clusters_dir=ABSENT (first lane under the runtime root)"
PORC0=$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)
log "PREFLIGHT_OK $(ts) lane=absent old_root=absent port$PORT=free postgres_procs=0 worktree_porcelain_sha=$PORC0 lock_inode=$(stat -c %i "$LOCK")"
# ---- step 2 OLD root (offline; committed helper; detached checkout of the base; bound 180 s)
STAGE=old-root; mkdir -p "$(dirname "$OLDROOT")"
( cd "$W" && timeout -k 30 180 bash test/utils/g2-s7l-old-root.sh create ) >>"$LOG" 2>&1; rc=$?; log "OLD_ROOT rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^G2_S7L_OLD_ROOT_OK" "$LOG" || { log "OLD_ROOT marker missing"; fail 72; }
[ "$(git -C "$OLDROOT" rev-parse HEAD)" = "$BASE_HEAD" ] || { log "OLD_ROOT head != base"; fail 72; }
# ---- step 3 init (bound 60 s)
STAGE=fixture-init; timeout -k 30 60 bash "$FIX" init >>"$LOG" 2>&1; rc=$?; log "FIXTURE_INIT rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^S7L_FIXTURE_INIT_OK data=$LANE/pg-data port=$PORT superuser=$ADMIN cluster_name=$CLUSTER_MARKER" "$LOG" || { log "FIXTURE_INIT marker missing"; fail 72; }
# ---- step 4 start (bound 60 s)
STAGE=fixture-start; STARTED=1; timeout -k 30 60 bash "$FIX" start >>"$LOG" 2>&1; rc=$?; log "FIXTURE_START rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^S7L_FIXTURE_START_OK pid=" "$LOG" || { log "FIXTURE_START marker missing"; fail 72; }
# ---- step 5 S7-L bootstrap (committed helper at the head: roles, marked DB, extensions, the whole accepted 171-migration
#      history through the OLD root's `prisma migrate deploy` as postgres, S8-B objects asserted and S7-L columns ABSENT,
#      OLD client generated inside the OLD root, candidate client VERIFIED — no generate) (bound 900 s)
STAGE=bootstrap
( cd "$W" && timeout -k 30 900 bash test/utils/g2-s7l-bootstrap.sh bootstrap ) >>"$LOG" 2>&1; rc=$?; log "BOOTSTRAP rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^G2_S7L_BOOTSTRAP_OK" "$LOG" || { log "BOOTSTRAP marker missing"; fail 72; }
grep -q "^OLD_CLIENT_GENERATED dir=$OLDCLIENT " "$LOG" && grep -q "^CANDIDATE_CLIENT_VERIFIED dir=$W/node_modules/.prisma/client " "$LOG" || { log "BOOTSTRAP client lines missing"; fail 72; }
# ---- step 6 identity (read-only, bound 15 s each; admin login with PGPASSWORD only, never a URL password)
STAGE=identity
psqlq(){ PGPASSWORD=$FIXPASS timeout -k 30 15 /usr/bin/psql -X -v ON_ERROR_STOP=1 -At "postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME" -c "$1" 2>>"$LOG"; }
DD=$(psqlq 'SHOW data_directory'); [ "$DD" = "$G2_S7L_DATA_DIRECTORY" ] || { log "IDENTITY_FAIL data_directory='$DD'"; fail 73; }
VN=$(psqlq 'SHOW server_version_num'); [ "$VN" = 170006 ] || { log "IDENTITY_FAIL server_version_num='$VN'"; fail 73; }
CN=$(psqlq "SELECT current_setting('cluster_name')"); [ "$CN" = "$CLUSTER_MARKER" ] || { log "IDENTITY_FAIL cluster_name='$CN'"; fail 73; }
DM=$(psqlq "SELECT shobj_description(oid,'pg_database') FROM pg_database WHERE datname=current_database()"); [ "$DM" = "$DB_MARKER" ] || { log "IDENTITY_FAIL db marker='$DM'"; fail 73; }
MC=$(psqlq 'SELECT count(*) FROM "_prisma_migrations" WHERE finished_at IS NOT NULL AND rolled_back_at IS NULL'); [ "$MC" = 171 ] || { log "IDENTITY_FAIL applied migrations=$MC (OLD history must be exactly 171; S7-L applied by the spec in L01)"; fail 73; }
SC=$(psqlq "SELECT count(*) FROM pg_attribute WHERE attrelid='public.\"ScoutImport\"'::regclass AND attname IN ('mode','import_intent_id','phase','execution_epoch','fenced_at') AND NOT attisdropped"); [ "$SC" = 0 ] || { log "IDENTITY_FAIL S7-L columns already present before the spec ($SC)"; fail 73; }
log "IDENTITY_OK $(ts) data_directory=$DD server_version_num=$VN cluster_name=$CN applied_migrations=$MC s7l_columns_before=$SC"
# ---- step 7 the proof, exactly once (bound 1800 s); no --testTimeout/--forceExit/--detectOpenHandles/coverage
STAGE=jest; log "JEST_START $(ts) cmd='./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s7l.spec.ts --runInBand --ci' head=$EXPECT_HEAD"
( cd "$W" && timeout -k 30 1800 ./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s7l.spec.ts --runInBand --ci ) >"$JLOG" 2>&1; JRC=$?
log "JEST_END rc=$JRC $(ts)"; grep -E '^(Test Suites|Tests|Snapshots|Time):' "$JLOG" | tee -a "$LOG"
grep -E 'requires an explicitly acknowledged|not the permitted disposable database|server identity mismatch|G2 proof requires|uncommitted changes' "$JLOG" >/dev/null && log "GUARD_REFUSAL_OBSERVED (see jest.log)"
MC2=$(psqlq 'SELECT count(*) FROM "_prisma_migrations" WHERE finished_at IS NOT NULL AND rolled_back_at IS NULL' || echo ERR); log "POST_JEST applied_migrations=$MC2 (spec ends after L03/L04 down/up; expected 172 if the final state is the re-applied S7-L, else recorded as observed)"
[ $JRC = 0 ] || fail $JRC
# ---- step 8 stop (bound 45 s + kill 30); data dir RETAINED (destroy only via separate decision: s7l-fixture.sh destroy)
STAGE=fixture-stop; STARTED=0; timeout -k 30 75 bash "$FIX" stop >>"$LOG" 2>&1; rc=$?; log "FIXTURE_STOP rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
P=$(pgrep -cx postgres || true); L=$(ss -ltn 2>/dev/null | grep -c ":$PORT " || true)
[ "$P" = 0 ] && [ "$L" = 0 ] && [ ! -e "$LANE/pg-data/postmaster.pid" ] && [ -d "$LANE/pg-data" ] || { log "STOP_STATE_FAIL postgres_procs=$P listeners=$L"; fail 74; }
log "STOP_STATE_OK postgres_procs=0 port$PORT=free datadir_retained=$LANE/pg-data"
# ---- step 9 post (read-only)
STAGE=post
OTHER1=""
for d in "$CLUSTERS"/*/; do [ -d "$d" ] || continue; n=$(basename "$d"); [ "$n" != s7l ] || continue
  [ ! -e "$d/pg-data/postmaster.pid" ] || { log "POST_FAIL $n postmaster.pid appeared"; fail 74; }
  OTHER1="$OTHER1 $n:$(sha "$d/pg-data/postgresql.conf" 2>/dev/null || echo ABSENT):$(sha "$d/pg-data/global/pg_control" 2>/dev/null || echo ABSENT)"; done
[ "$OTHER0" = "$OTHER1" ] || { log "POST_FAIL other lanes changed: before=[$OTHER0] after=[$OTHER1]"; fail 74; }
log "POST other_lanes_unchanged=[${OTHER0:-none}]"
[ "$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)" = "$PORC0" ] && [ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] || { log "POST_FAIL worktree changed"; fail 74; }
[ "$(sha "$W/node_modules/.prisma/client/index.d.ts")" = "$EXPECT_NM_CLIENT_SHA" ] || { log "POST_FAIL generated candidate client changed during the proof"; fail 74; }
[ "$(git -C "$OLDROOT" rev-parse HEAD)" = "$BASE_HEAD" ] && git -C "$OLDROOT" diff --quiet HEAD -- package.json package-lock.json src prisma || { log "POST_FAIL OLD root changed"; fail 74; }
log "POST_OK $(ts) lock_still_held_fd9 inode=$(stat -c %i "$LOCK")"
STAGE=done; finish 0
