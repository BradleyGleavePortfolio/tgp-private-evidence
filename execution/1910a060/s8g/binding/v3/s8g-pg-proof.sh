#!/usr/bin/env bash
# S8-G real-PG proof — complete execution binding, head pins FILLED from committed 820ce85b (Phase-2 FINAL GO); NOT RUN; run only under the parent's single-run PG grant.
# BIND-1 closures (binding/CLOSURES-BIND-1.md): real psql binary pinned (B3), EXPECT_TESTS=19 count assertion (B4), S8-F lane scan + 17 S8-F blob pins (C), lock inode 667698 asserted, stale text fixed.
# Derived by substitution from the accepted S8-C binding execution/64e33dc7/s8c/binding/v3/s8c-pg-proof.sh with the
# EXEC-1910A060 deltas: runtime root execution/1910a060/runtime (RT-NEW-1 receipt), base 62471b11 (merge of 1c5fbb04 + S8-F e1ec2fec; review B2), fresh runtime namespace (RUNTIME_SETUP_RECEIPT), port 55644 (55643 = retained S8-F lane, refused by g2-s8g-db.ts) / s8g_super / g2_s8g_disposable /
# cluster s8g-disposable-pg17, NO OLD side (S8-G ships no migration: the base 62471b11 (merge of 1c5fbb04 + S8-F e1ec2fec; review B2) prisma tree is the only schema
# and the accepted S7-L/S8-C objects are the proof target), the candidate binding G2_S8G_CANDIDATE_HEAD, and the S8-G
# bootstrap/spec. Runs the NEW spec test/rls-g2-s8g.spec.ts exactly once via the repo jest + jest.rls.config.js.
# No new test framework, no retry, no inherited-proof replay (S8-B / S7-L / N/Q1 / C / R / B suites are never invoked).
# Single canonical lock holder: the nonblocking flock on execution/test-validation.lock is taken on fd 9 before any
# state change and held until this process exits — i.e. through stop, post checks and receipt hashing; the lock file
# is never deleted. First nonzero stops; the only cleanup attempted is a bounded fixture stop when this run started
# the postmaster. No autonomous cleanup is GUARANTEED: if the outer timeout kills bash, the stop does not run. What
# governs is the observed terminal evidence — sentinel/log lines, `pgrep -cx postgres`, the port listener count and
# any survivor pid the stop reports — not this header. Data dir RETAINED after stop (destroy = separate marker-gated grant).
# Inner stage bounds: init 60 + start 60 + bootstrap 900 + identity 5x15 + jest 1500 + stop 75 = 2670 s soft sum.
# Usage (later, under the separate single-run PG grant): timeout -k 30 3600 bash .../binding/s8g-pg-proof.sh
# Pre-steps (each its own receipt, BEFORE the head pins are filled): source gates (prettier --check, eslint, tsc heap 4096,
# check-r75, affected default jest incl. test/scout/g2-s8g-db-guard.spec.ts and test/scout/orchestration/*.spec.ts)
# → generator execution by transfer (if granted) → ordinary Bradley-authored hooked commit → source/binding export →
# two independent non-builder final-head attestations → fill EXPECT_HEAD/EXPECT_TREE/EXPECT_*_BLOB/EXPECT_FIXTURE_SHA
# from the attested head (PINS.txt) → separate PG grant → this script, once.
set -uo pipefail
D=/home/user/workspace/tgp-private-evidence/execution/1910a060/s8g/binding/v3
# (the filled runner file is s8g-pg-proof.sh; history/ keeps the .unfilled template)
RUNTIME_ROOT=/home/user/workspace/execution/1910a060/runtime
W=/home/user/workspace/worktrees/1910a060-s8g
R=$D/run; LOG=$R/s8g-pg-proof.log; SENT=$R/s8g-pg-proof.sentinel; JLOG=$R/jest.log
LOCK=/home/user/workspace/execution/test-validation.lock
# ---- pins: head pins filled from gate/attempt-4/BINDING-PINS-820ce85be2eb.txt (committed head 820ce85b, both reviewers FINAL GO); the script still refuses placeholders.
BASE_HEAD=62471b116267fdec6746073c4b4c80a154d09834                         # accepted base; identical in g2-s8g-db.ts/bootstrap
BASE_TREE=23614f0b7dc33dc37b90cf4f27fcb8331912e60f
EXPECT_HEAD=1279b419ee60b25163c7e6d2809b749dd723fee9
EXPECT_TREE=44ece797c9183ee33198b2c43e402f943911369a
EXPECT_SPEC_BLOB=7cae12ad492f0c98c3288ede43956a450af643d1                                 # test/rls-g2-s8g.spec.ts at the S8-G head
EXPECT_BOOTSTRAP_BLOB=2ab85a1341cd4545edeb145dded67e6bef3fa2bf                            # test/utils/g2-s8g-bootstrap.sh
EXPECT_DB_BLOB=c654e6bd7364be70fba9b63d9f061aa60646b122                                   # test/utils/g2-s8g-db.ts
EXPECT_PGH_BLOB=a02612463dcb2ed8b7605d68348011a0b1321be8                                  # test/utils/g2-s8g-pg-harness.ts
EXPECT_HARNESS_BLOB=ee2a41a2c118d4576878b65bf9b65cf220d0cf27                              # test/utils/g2-s8g-harness.ts
EXPECT_WORKER_BLOB=65ee972d3bb44eca84a6007d81b4675452e2d94c                               # test/utils/g2-s8g-worker.cjs
EXPECT_FIXTURE_SHA=62de28baa4ad3a669729aa33bebdb603b72642e9a41a2a57345b344093b3d24d                                   # sha256 of binding/v1/s8g-fixture.sh (frozen with this file)
# ---- tool pins (RUNTIME_SETUP_RECEIPT.md, 2026-09-25T03:29:43Z; compare only, never adjusted at run time)
EXPECT_POSTGRES_SHA=23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a
EXPECT_INITDB_SHA=b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a
EXPECT_PGCTL_SHA=af53d826845af4679a0aaba2bda319f5e527f3b94f3794c67fa174049c9b9401
PSQL=/usr/lib/postgresql/18/bin/psql                                                     # B3: the real client binary, not the pg_wrapper dispatcher (mirrors S8-F v2 CB1)
EXPECT_PSQL_SHA=d1108fdb45b87f2313d7acfbb91a0a65ca97c6c2195f15d8ae9295121029ef67       # sha256 of $PSQL (postgresql-client-18 18.6-0ubuntu0.26.04.1; measured read-only 2026-09-25)
EXPECT_TESTS=19                                                                         # it() count in test/rls-g2-s8g.spec.ts @820ce85b (19 top-level it(, no it.each/skip/only; verified by grep)
EXPECT_MIGRATIONS=172
EXPECT_LOCK_INODE=692282                                                                # runtime/LOCK_ESTABLISHED.txt
EXPECT_NODE_SHA=a03953a7b16bff002b94d6fb58ada900b68241cbcaee6efc400b20dadd36dddc       # /usr/local/bin/node v20.20.1
EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44    # node_modules/.package-lock.json (1910a060 donor worktrees/1910a060-s8f, RUNTIME_SETUP_RECEIPT §4; measured read-only 2026-09-25)
EXPECT_NM_CLIENT_SHA=9042e713ba5678c99959a345b7b18a60dfc186b2c7d890b8d9c3ed5c8f4edcc6  # node_modules/.prisma/client/index.d.ts generated from schema blob 2e328bbc (== 1c5fbb04 prisma/schema.prisma; S8-G ships no schema change)
EXPECT_SCHEMA_SHA=0eb41f9a88ef3b77266e908a5ea814206c188d1bdb031bd96d746491fee84015      # prisma/schema.prisma @62471b11 == @1c5fbb04 (blob 2e328bbc)
EXPECT_PKG_LOCK_SHA=b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55   # package-lock.json @62471b11 == @1c5fbb04 (blob 354de3da)
DIST=$RUNTIME_ROOT/pg17/dist; CLUSTERS=$RUNTIME_ROOT/clusters; LANE=$CLUSTERS/s8-g; SOCK=$RUNTIME_ROOT/run/s8-g
PORT=55644; DBNAME=g2_s8g_disposable; ADMIN=s8g_super; FIXPASS=s8g_local_synthetic
FIX=$D/s8g-fixture.sh
export GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1 NODE_OPTIONS=--max-old-space-size=4096 CHECKPOINT_DISABLE=1 \
       PRISMA_HIDE_UPDATE_MESSAGE=1 npm_config_offline=true npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false \
       npm_config_cache=$RUNTIME_ROOT/npm-cache XDG_CACHE_HOME=$RUNTIME_ROOT/xdg-cache
# S8-G-only identity: exactly the G2_S8G_* names the guard/harness/bootstrap read. Nothing G2_S8B_*, G2_S7L_* or earlier is exported.
export G2_S8G_DATABASE_URL="postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=4" \
       G2_S8G_CONFIRM="$DBNAME:$PORT" G2_S8G_PASSWORD=$FIXPASS G2_S8G_PSQL=$PSQL \
       G2_S8G_DATA_DIRECTORY=$LANE/pg-data G2_S8G_SERVER_VERSION=170006 \
       G2_S8G_CANDIDATE_HEAD=$EXPECT_HEAD
export S8G_RUNNER_PID=$$ S8G_STOP_TIMEOUT=45
mkdir -p "$R"
[ -e "$SENT" ] && { echo "REFUSED: $SENT exists; this proof runs once, no retry" >&2; exit 76; }
[ -e "$LOCK" ] || { echo "REFUSED: canonical lock file $LOCK absent; runtime setup created it and it is never deleted or recreated here" >&2; exit 75; }
[ "$(stat -c %i "$LOCK")" = "$EXPECT_LOCK_INODE" ] || { echo "REFUSED: canonical lock inode $(stat -c %i "$LOCK") != $EXPECT_LOCK_INODE" >&2; exit 75; }
exec 9>>"$LOCK"; flock -n 9 || { echo "REFUSED: canonical lock busy ($LOCK)" >&2; exit 75; }
ts(){ date -u +%FT%TZ; }
log(){ echo "$*" | tee -a "$LOG"; }
sha(){ sha256sum "$1" | cut -c1-64; }
STAGE=preconditions; STARTED=0
finish(){ local rc=$1
  ( cd "$R" && sha256sum s8g-pg-proof.log $( [ -e jest.log ] && echo jest.log ) > RECEIPTS.sha256 2>/dev/null )
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
case "$EXPECT_HEAD$EXPECT_TREE$EXPECT_SPEC_BLOB$EXPECT_BOOTSTRAP_BLOB$EXPECT_DB_BLOB$EXPECT_PGH_BLOB$EXPECT_HARNESS_BLOB$EXPECT_WORKER_BLOB$EXPECT_FIXTURE_SHA" in *__*) log "PRECONDITION_FAIL pins not filled (proposal stage)"; fail 70;; esac
[ "$EXPECT_HEAD" != "$BASE_HEAD" ] || { log "PRECONDITION_FAIL EXPECT_HEAD is the base, not a candidate"; fail 70; }
[ "$(sha "$FIX")" = "$EXPECT_FIXTURE_SHA" ] || { log "PRECONDITION_FAIL fixture sha256 mismatch"; fail 70; }
[ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] || { log "PRECONDITION_FAIL HEAD != $EXPECT_HEAD"; fail 70; }
[ "$(git -C "$W" rev-parse 'HEAD^{tree}')" = "$EXPECT_TREE" ] || { log "PRECONDITION_FAIL tree mismatch"; fail 70; }
[ "$(git -C "$W" rev-parse "$BASE_HEAD^{tree}")" = "$BASE_TREE" ] || { log "PRECONDITION_FAIL base tree mismatch"; fail 70; }
git -C "$W" merge-base --is-ancestor "$BASE_HEAD" HEAD || { log "PRECONDITION_FAIL base $BASE_HEAD not an ancestor"; fail 70; }
for pin in "test/rls-g2-s8g.spec.ts $EXPECT_SPEC_BLOB" "test/utils/g2-s8g-bootstrap.sh $EXPECT_BOOTSTRAP_BLOB" "test/utils/g2-s8g-db.ts $EXPECT_DB_BLOB" \
           "test/utils/g2-s8g-pg-harness.ts $EXPECT_PGH_BLOB" "test/utils/g2-s8g-harness.ts $EXPECT_HARNESS_BLOB" "test/utils/g2-s8g-worker.cjs $EXPECT_WORKER_BLOB"; do set -- $pin
  [ "$(git -C "$W" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL S8-G proof file $1 blob mismatch"; fail 70; }; done
[ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] || { log "PRECONDITION_FAIL worktree not clean"; fail 70; }
[ ! -e "$(git -C "$W" rev-parse --git-path MERGE_HEAD)" ] || { log "PRECONDITION_FAIL MERGE_HEAD present"; fail 70; }
# the committed head must have been produced through the tracked lefthook hooks (installed by the runtime donor's `prepare`)
H=$(git -C "$W" rev-parse --git-path hooks); case "$H" in /*) ;; *) H="$W/$H";; esac
grep -q lefthook "$H/pre-commit" 2>/dev/null && grep -q lefthook "$H/commit-msg" 2>/dev/null \
  || { log "PRECONDITION_FAIL $H/pre-commit or commit-msg absent or not lefthook (hookless commit)"; fail 70; }
# S8-G ships no schema/migration change and touches no accepted S8-B proof file, sidecar or contract generator input it does not own
[ -z "$(git -C "$W" diff --name-only "$BASE_HEAD" HEAD -- prisma)" ] || { log "PRECONDITION_FAIL prisma tree differs from base"; fail 70; }
for pin in "test/utils/g2-s8c-db.ts a7d67217fe959f65daae9615e5f00806cc3764d3" "test/utils/g2-s8c-pg-harness.ts 4059883d70c26aed46398af707645aaacb306868" \
           "test/utils/g2-s8c-harness.ts 1a8f17970a1095f9b802badacf093e773caabd76" "test/utils/g2-s8c-bootstrap.sh 7c3fba471f991e3750eb56fd29e271101652196e" \
           "test/utils/g2-s8c-worker.cjs 484030636dee841bcd5aff1af42536128858ac77" "test/scout/g2-s8c-db-guard.spec.ts c3fc6bded0906fb27fd5cab49dc51fb17825db04" \
           "test/rls-g2-s8c.spec.ts 9d701783eeb7701126d158b45bfee3d5f0f686b3" "test/utils/g2-s7l-db.ts 384e1b746bdcace15b7ed51db23b365557ee72de" \
           "test/utils/g2-s7l-pg-harness.ts d8b71d68da9a1e823ebd9c334d99798da5d12de8" "test/utils/g2-s7l-harness.ts f0860a8da9fd709dfa8178d9c61415ee6dcb05ff" \
           "test/utils/g2-s7l-bootstrap.sh ebef51fcd355282a222b8f7f789fdfedcb86370c" "test/utils/g2-s7l-worker.cjs 155ffdccd3d4e472cede84e7b11523d18201b450" \
           "test/rls-g2-s7l.spec.ts 94e7fac4b8cbb8a8e2146700cbdc7ce9129b9f92" \
           "prisma/migrations/20270123000000_scout_run_lifecycle_expand 4ce576460c7ae325f3ec778d9d616ab766290f29" \
           "prisma/migrations/20270122000000_scout_native_provenance_expand 94c4d201676ff509e9faee5597d7611562fd9668" \
           "prisma/schema.prisma 2e328bbcab0c902c6adb55dfb5ee172defc5f698" "src/scout/reconstruct/sources a1a296eefa6da65a4c9df94688f2f320d52f95a2" \
           "jest.rls.config.js 44c9691533be2ea27f9a416271d9ff400f7faa3f" "jest.config.js 769a414698125340d6e347160f6ad81122cce863" \
           "package-lock.json 354de3dae19449970497da6e4d87f0a1225a8f43" \
           "docs/contracts/importer-openapi.json 8ebf936a9f12087a807cb37b069592d0c1e96cb2" "src/scout/scout-entities.controller.ts 8060a3685e707d88a4ccf65fe19e3f111a70e53c" \
           "src/scout/scout-entities.dto.ts 8b0f8ec063344702e13139a69d9165b8479fc6cc" "src/scout/scout-entities.service.ts 77db2ee4f72993b22db8af19e730c2cbd155462a" \
           "src/scout/scout-roster.controller.ts 02904b3db04a3245eab32d8cc070f0bef5d9670d" "src/scout/scout-roster.dto.ts 939713d7846fe1020074c9e77840f16f11a89ac2" \
           "src/scout/scout-roster.service.ts 4435cbf03805a15daab0964b79c98098b438a828" "test/contracts/importer-contract.spec.ts 4300eec371c3edbde48cf058e6f1f06021924b60" \
           "test/rls-g2-s8f.spec.ts 77785ec5fa3d0bb15731ba7787c4ede4968eb51d" "test/scout/entities/scout-entities.contract.spec.ts 1b2f183e3a0dc7e55da6b7b9a5bb77c2345bcccb" \
           "test/scout/entities/scout-entities.service.spec.ts b16d0b752ae3da384420dc41f8a9ade5f51c2c54" "test/scout/g2-s8f-db-guard.spec.ts 9d1042a432f13d3f49409ca436e3cffad152da6f" \
           "test/scout/roster/scout-roster.controller.spec.ts 1c94e4de73557b2c46c2a7c16c117cd1e92ac43f" "test/scout/roster/scout-roster.service.spec.ts 882ad737f5ebfe03549ad7eaef10c3f36ec66fd1" \
           "test/utils/g2-s8f-bootstrap.sh 5ac2753bdc0498899d1a9eef297ef4acc467ccb8" "test/utils/g2-s8f-db.ts aeff4cb0f06d0d65b969bf7742c1d8cf377f4c79" \
           "test/utils/g2-s8f-pg-harness.ts a8acd231d10194d4552546339a7a4309c86fb8d4"; do set -- $pin
  [ "$(git -C "$W" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL accepted file $1 changed (blob != 62471b11; S7-L/S8-C/S8-F accepted-at-base)"; fail 70; }; done
# the S8-G orchestration surface is present at the head; no native sidecar, migration or S9 wiring is shipped by this candidate
[ -e "$W/src/scout/reconstruct/orchestration/run-context.ts" ] && [ -e "$W/src/scout/reconstruct/orchestration/family-plan.ts" ] || { log "PRECONDITION_FAIL S8-G orchestration files absent"; fail 70; }
[ ! -e "$W/src/scout/reconstruct/native/sources" ] || { log "PRECONDITION_FAIL native sidecar directory present (none granted for this candidate)"; fail 70; }
# dependency tree: an ISOLATED real copy of the runtime donor (not a symlink, not platform node_modules, not a fresh npm ci)
[ -d "$W/node_modules" ] && [ ! -L "$W/node_modules" ] || { log "PRECONDITION_FAIL $W/node_modules absent or a symlink (isolated copy required)"; fail 70; }
case "$(readlink -f "$W/node_modules")" in "$W"/*) ;; *) log "PRECONDITION_FAIL node_modules resolves outside $W"; fail 70;; esac
[ "$(sha "$W/package-lock.json")" = "$EXPECT_PKG_LOCK_SHA" ] || { log "PRECONDITION_FAIL package-lock.json != base record"; fail 70; }
[ "$(sha "$W/node_modules/.package-lock.json")" = "$EXPECT_NM_LOCK_SHA" ] || { log "PRECONDITION_FAIL node_modules/.package-lock.json != donor record"; fail 70; }
[ "$(sha "$W/prisma/schema.prisma")" = "$EXPECT_SCHEMA_SHA" ] || { log "PRECONDITION_FAIL prisma/schema.prisma sha256 != pin (blob 2e328bbc, identical at 1c5fbb04 and 62471b11)"; fail 70; }
[ "$(sha "$W/node_modules/.prisma/client/index.d.ts")" = "$EXPECT_NM_CLIENT_SHA" ] || { log "PRECONDITION_FAIL generated client != donor record (no S8-G generate expected)"; fail 70; }
[ -x "$W/node_modules/.bin/jest" ] && [ -x "$W/node_modules/.bin/ts-node" ] && [ -x "$W/node_modules/.bin/prisma" ] || { log "PRECONDITION_FAIL jest/ts-node/prisma missing"; fail 70; }
# tools: pinned PG 17.6 server binaries in the fresh namespace, the real psql 18 client binary (B3) and Node 20
[ -x "$DIST/bin/postgres" ] && [ -x "$DIST/bin/initdb" ] && [ -x "$DIST/bin/pg_ctl" ] || { log "PRECONDITION_FAIL PG17 dist absent at $DIST"; fail 70; }
[ "$(sha "$DIST/bin/postgres")" = "$EXPECT_POSTGRES_SHA" ] || { log "PRECONDITION_FAIL postgres binary sha256 != pin"; fail 70; }
[ "$(sha "$DIST/bin/initdb")" = "$EXPECT_INITDB_SHA" ] || { log "PRECONDITION_FAIL initdb binary sha256 != pin"; fail 70; }
[ "$(sha "$DIST/bin/pg_ctl")" = "$EXPECT_PGCTL_SHA" ] || { log "PRECONDITION_FAIL pg_ctl binary sha256 != pin"; fail 70; }
PGV=$(LD_LIBRARY_PATH=$DIST/lib "$DIST/bin/postgres" --version 2>/dev/null); [ "${PGV##* }" = 17.6 ] || { log "PRECONDITION_FAIL server not 17.6: $PGV"; fail 70; }
[ -x "$PSQL" ] && [ "$(sha "$PSQL")" = "$EXPECT_PSQL_SHA" ] || { log "PRECONDITION_FAIL $PSQL absent or sha256 != pin"; fail 70; }
"$PSQL" --version | grep -qE "^psql \(PostgreSQL\) 18\." || { log "PRECONDITION_FAIL psql major != 18: $("$PSQL" --version)"; fail 70; }
NODE=$(command -v node); [ "$(sha "$(readlink -f "$NODE")")" = "$EXPECT_NODE_SHA" ] || { log "PRECONDITION_FAIL node sha256 != pin ($NODE)"; fail 70; }
node --version | grep -q '^v20\.' || { log "PRECONDITION_FAIL node major != 20"; fail 70; }
[ "$(readlink -f "$RUNTIME_ROOT")" = "$RUNTIME_ROOT" ] || { log "PRECONDITION_FAIL $RUNTIME_ROOT is not a real path"; fail 70; }
grep -q '^result=success' "$RUNTIME_ROOT/pg17/PROVENANCE.txt" 2>/dev/null || { log "PRECONDITION_FAIL pg17 PROVENANCE.txt lacks result=success"; fail 70; }
log "PRECONDITIONS_OK $(ts) server='$PGV' psql='$("$PSQL" --version)' node=$(node --version) jest=$(cd "$W" && ./node_modules/.bin/jest --version) ts_node=$(cd "$W" && ./node_modules/.bin/ts-node --version 2>/dev/null | head -1) prisma=$(cd "$W" && ./node_modules/.bin/prisma --version 2>/dev/null | awk '/^prisma /{print $3}')"
# ---- step 1 preflight (read-only): S8-G lane absent; port $PORT (55644) free; no postgres; other lanes under the runtime root (legacy clusters/* AND proof-*/clusters/*, i.e. the retained S8-F lane proof-s8f-v2/clusters/s8-f) recorded and never started
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
[ -e "$CLUSTERS" ] || log "PREFLIGHT clusters_dir=ABSENT (first lane under $CLUSTERS; the S8-F lane lives under proof-s8f-v2/ and is scanned above)"
PORC0=$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)
log "PREFLIGHT_OK $(ts) lane=absent port$PORT=free postgres_procs=0 worktree_porcelain_sha=$PORC0 lock_inode=$(stat -c %i "$LOCK")"
# ---- step 2 init (bound 60 s)
STAGE=fixture-init; timeout -k 30 60 bash "$FIX" init >>"$LOG" 2>&1; rc=$?; log "FIXTURE_INIT rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^S8G_FIXTURE_INIT_OK data=$LANE/pg-data port=$PORT superuser=$ADMIN cluster_name=s8g-disposable-pg17" "$LOG" || { log "FIXTURE_INIT marker missing"; fail 72; }
# ---- step 3 start (bound 60 s)
STAGE=fixture-start; STARTED=1; timeout -k 30 60 bash "$FIX" start >>"$LOG" 2>&1; rc=$?; log "FIXTURE_START rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^S8G_FIXTURE_START_OK pid=" "$LOG" || { log "FIXTURE_START marker missing"; fail 72; }
# ---- step 4 S8-G bootstrap (committed helper at the attested head; roles, marked DB, extensions, the whole accepted
#      172-migration history through the candidate's `prisma migrate deploy` as postgres, S8-B/S7-L objects asserted, candidate
#      client VERIFIED — no generate) (bound 900 s)
STAGE=bootstrap
( cd "$W" && timeout -k 30 900 bash test/utils/g2-s8g-bootstrap.sh bootstrap ) >>"$LOG" 2>&1; rc=$?; log "BOOTSTRAP rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^G2_S8G_BOOTSTRAP_OK" "$LOG" || { log "BOOTSTRAP marker missing"; fail 72; }
grep -q "^CANDIDATE_HEAD=$EXPECT_HEAD" "$LOG" || { log "BOOTSTRAP candidate binding line missing"; fail 72; }
# ---- step 5 identity (read-only, bound 15 s each; admin login with PGPASSWORD only, never a URL password)
STAGE=identity
psqlq(){ PGPASSWORD=$FIXPASS timeout -k 30 15 "$PSQL" -X -v ON_ERROR_STOP=1 -At "postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME" -c "$1" 2>>"$LOG"; }
DD=$(psqlq 'SHOW data_directory'); [ "$DD" = "$G2_S8G_DATA_DIRECTORY" ] || { log "IDENTITY_FAIL data_directory='$DD'"; fail 73; }
VN=$(psqlq 'SHOW server_version_num'); [ "$VN" = 170006 ] || { log "IDENTITY_FAIL server_version_num='$VN'"; fail 73; }
CN=$(psqlq "SELECT current_setting('cluster_name')"); [ "$CN" = s8g-disposable-pg17 ] || { log "IDENTITY_FAIL cluster_name='$CN'"; fail 73; }
DM=$(psqlq "SELECT shobj_description(oid,'pg_database') FROM pg_database WHERE datname=current_database()")
[ "$DM" = s8g-g2-run-orchestration-synthetic-disposable-fixture-safe-to-drop ] || { log "IDENTITY_FAIL db marker='$DM'"; fail 73; }
MC=$(psqlq 'SELECT count(*) FROM "_prisma_migrations" WHERE finished_at IS NOT NULL AND rolled_back_at IS NULL'); [ "$MC" = "$EXPECT_MIGRATIONS" ] || { log "IDENTITY_FAIL applied migrations=$MC"; fail 73; }
log "IDENTITY_OK $(ts) data_directory=$DD server_version_num=$VN cluster_name=$CN applied_migrations=$MC"
# ---- step 6 the proof, exactly once (bound 1500 s); no --testTimeout/--forceExit/--detectOpenHandles/coverage
STAGE=jest; log "JEST_START $(ts) cmd='./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s8g.spec.ts --runInBand --ci' candidate_head=$G2_S8G_CANDIDATE_HEAD"
( cd "$W" && timeout -k 30 1500 ./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s8g.spec.ts --runInBand --ci ) >"$JLOG" 2>&1; JRC=$?
log "JEST_END rc=$JRC $(ts)"; grep -E '^(Test Suites|Tests|Snapshots|Time):' "$JLOG" | tee -a "$LOG"
grep -E 'requires an explicitly acknowledged|not the permitted disposable database|server identity mismatch|G2 proof requires|not the attested candidate|uncommitted changes' "$JLOG" >/dev/null && log "GUARD_REFUSAL_OBSERVED_IN_JEST_LOG"
[ $JRC = 0 ] || fail $JRC
# B4: the proof must have executed the whole spec — exactly the pinned test count in exactly one suite, none skipped/todo
grep -qE "^Tests: +$EXPECT_TESTS passed, $EXPECT_TESTS total" "$JLOG" || { log "JEST_COUNT_FAIL expected 'Tests: $EXPECT_TESTS passed, $EXPECT_TESTS total' (got: $(grep -E '^Tests:' "$JLOG" | head -1))"; fail 72; }
grep -qE "^Test Suites: +1 passed, 1 total" "$JLOG" || { log "JEST_COUNT_FAIL expected 'Test Suites: 1 passed, 1 total' (got: $(grep -E '^Test Suites:' "$JLOG" | head -1))"; fail 72; }
log "JEST_COUNT_OK tests=$EXPECT_TESTS suites=1"
# ---- step 7 stop (bound 45 s + kill 30); data dir RETAINED (destroy only via separate grant: s8g-fixture.sh destroy)
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
