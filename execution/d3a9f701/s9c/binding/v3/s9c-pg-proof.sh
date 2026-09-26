#!/usr/bin/env bash
# S9-C real-PG proof — execution binding v2 (= v1 + pipefail/SIGPIPE precondition fix; v1 S9C-PROOF-1 refused rc=70 at preconditions, preserved). Derived by substitution from the accepted
# S9-B binding execution/1910a060/s9b/binding/v3/s9b-pg-proof.sh (ran once, 10/10; unchanged there; full diff in
# DELTA-from-s9b-v3.diff) with the EXEC-D3A9F701 S9-C deltas: standalone clone worktrees/d3a9-s9c-r2 whose candidate
# head descends from BASE = 5407efae (S9-B landing merge; tree 3e2028e9); lane port 55646 / s9c_super /
# g2_s9c_disposable / cluster s9c-disposable-pg17 / lane dirs runtime/clusters/s9-c + runtime/run/s9-c; NO OLD side
# (S9-C ships no migration, D-S9-5: the base prisma tree — 172 migrations, S8-B and S7-L included — is the only schema);
# the candidate binding G2_S9C_CANDIDATE_HEAD and the S9-C bootstrap/spec. Runs the NEW spec test/rls-g2-s9c.spec.ts
# exactly once via the repo jest + jest.rls.config.js. The spec drives the REAL candidate settle path
# (ScoutService -> ScoutLifecycleService with the S9-B facts service + frozen S9-A reconcile) in separate OS processes;
# no new test framework, no retry, no inherited-proof replay (S9-B / S8-G / S8-C / S8-B / S7-L suites are never invoked).
# Single canonical lock holder: the nonblocking flock on execution/test-validation.lock is taken on fd 9 before any
# state change and held until this process exits — through stop, post checks and receipt hashing; the lock file is
# never deleted. First nonzero stops; the only cleanup attempted is a bounded fixture stop when this run started the
# postmaster. No autonomous cleanup is GUARANTEED: if the outer timeout kills bash, the stop does not run. What governs
# is the observed terminal evidence — sentinel/log lines, `pgrep -cx postgres`, the port listener count and any
# survivor pid the stop reports — not this header. Data dir RETAINED after stop (destroy = separate marker-gated grant).
# Inner stage bounds: init 60 + start 60 + bootstrap 900 + identity 5x15 + jest 1500 + stop 75 = 2670 s soft sum.
# Usage (under the separate single-run PG grant, after the gate commit and fill): timeout -k 30 3900 bash .../binding/v1/s9c-pg-proof.sh
# Fill (parent, after the S9-C gate's hooked commit): EXPECT_HEAD / EXPECT_TREE / the six EXPECT_*_BLOB from the gate
# receipt d3a9f701/s9c/gate/HEAD-<12>.txt (post-format blobs); EXPECT_RECONSTRUCT_DELTA only if a reviewer accepts an
# S9-C path under src/scout/reconstruct. EXPECT_FIXTURE_SHA is already filled (the fixture is head-independent).
set -uo pipefail
D=/home/user/workspace/tgp-private-evidence/execution/d3a9f701/s9c/binding/v3
RUNTIME_ROOT=/home/user/workspace/execution/1910a060/runtime                     # 1910a060 runtime namespace (execution/1910a060/runtime/RUNTIME_SETUP_RECEIPT.md); the fixture carries the same literal and is cross-checked below
W=/home/user/workspace/worktrees/d3a9-s9c-r2
R=$D/run; LOG=$R/s9c-pg-proof.log; SENT=$R/s9c-pg-proof.sentinel; JLOG=$R/jest.log
LOCK=/home/user/workspace/execution/test-validation.lock
# ---- pins: head pins are filled by the parent AFTER the S9-C gate commit exists; the script refuses placeholders.
BASE_HEAD=5407efae319fd913e973c87f3be0d49786c4a3e0                                                 # S9-B landing merge (integration/importer)
BASE_TREE=3e2028e9fc40c77db72152eb0e5c860d0a3661db                                                 # git rev-parse 5407efae^{tree}
HARNESS_BASE_HEAD=5407efae319fd913e973c87f3be0d49786c4a3e0                                         # G2_S9C_BASE_HEAD / bootstrap BASE_HEAD literal in the r2 harness (== BASE_HEAD; freeze-1 had 771db62a)
EXPECT_HEAD=2e9f6c054b86b749b58a9232c79153a872d9ec18
EXPECT_TREE=02e7b312c7a318e80c1e468854ef2555a10e8873
EXPECT_SPEC_BLOB=c4b4458d134226b9b101832f00fe9a481e15013b                                 # test/rls-g2-s9c.spec.ts at the S9-C head
EXPECT_BOOTSTRAP_BLOB=1cf3b0a5a14fbf352226780a3c0f01058fea2b6b                            # test/utils/g2-s9c-bootstrap.sh
EXPECT_DB_BLOB=ec787d0ed8f5171aca4ca171c6abd9a449d5171c                                   # test/utils/g2-s9c-db.ts
EXPECT_PGH_BLOB=3065b620ac6bc29f010e0bad94c6beca26b8cdd1                                  # test/utils/g2-s9c-pg-harness.ts
EXPECT_HARNESS_BLOB=fc6a9b4bd90e1f0c64a24c34470d7137e1facd89                              # test/utils/g2-s9c-harness.ts
EXPECT_WORKER_BLOB=ec3015fb73b086848890392a17b2c200c90553ed                               # test/utils/g2-s9c-worker.cjs
EXPECT_FIXTURE_SHA=ca1e563d9056169aacb60c8bf95d6a41d34ff0619eadc7a998972fe9d8dc1085   # sha256 of binding/v1/s9c-fixture.sh (frozen with this file; BINDING.sha256)
EXPECT_RECONSTRUCT_DELTA='src/scout/reconstruct/native/native-rules.ts'                         # exact `git diff --name-only BASE HEAD -- src/scout/reconstruct` (sorted, space-separated); '' = none (D-S9-8)
# ---- tool pins: filled from the 1910a060 runtime setup receipt (compare only, never adjusted at run time). Prior
#      values identical to the S9-B v3 binding (re-measured on this host 2026-09-26T02:30Z: postgres/initdb/pg_ctl/psql/node).
EXPECT_POSTGRES_SHA=23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a
EXPECT_INITDB_SHA=b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a
EXPECT_PGCTL_SHA=af53d826845af4679a0aaba2bda319f5e527f3b94f3794c67fa174049c9b9401
PSQL=/usr/lib/postgresql/18/bin/psql                # CB1: the real client binary, not the /usr/bin/psql pg_wrapper dispatcher (64e33dc7/s8f/binding/v2 mirror)
EXPECT_PSQL_REAL_SHA=d1108fdb45b87f2313d7acfbb91a0a65ca97c6c2195f15d8ae9295121029ef67   # sha256 of $PSQL (postgresql-client-18 18.6-0ubuntu0.26.04.1; RUNTIME_SETUP_RECEIPT.md, re-measured 2026-09-25)
EXPECT_TESTS=10                                     # it() count in test/rls-g2-s9c.spec.ts (grep -c '^\s*it(' on the r2 source; re-verify at fill against the committed head)
EXPECT_LOCK_INODE=692282                            # execution/d3a9f701/runtime/LOCK_ESTABLISHED.txt (inode=692282)
EXPECT_NODE_SHA=a03953a7b16bff002b94d6fb58ada900b68241cbcaee6efc400b20dadd36dddc       # node v20.x
EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44    # node_modules/.package-lock.json (donor; package-lock unchanged since 93389265)
EXPECT_NM_CLIENT_SHA=9042e713ba5678c99959a345b7b18a60dfc186b2c7d890b8d9c3ed5c8f4edcc6  # node_modules/.prisma/client/index.d.ts generated from schema 0eb41f9a (S9-C ships no schema change)
EXPECT_SCHEMA_SHA=0eb41f9a88ef3b77266e908a5ea814206c188d1bdb031bd96d746491fee84015   # prisma/schema.prisma @1c5fbb04 (sha256sum in the standalone clone)
EXPECT_PKG_LOCK_SHA=b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55   # package-lock.json @1c5fbb04 (unchanged since 93389265; sha256sum in the standalone clone)
DIST=$RUNTIME_ROOT/pg17/dist; CLUSTERS=$RUNTIME_ROOT/clusters; LANE=$CLUSTERS/s9-c; SOCK=$RUNTIME_ROOT/run/s9-c
PORT=55646; DBNAME=g2_s9c_disposable; ADMIN=s9c_super; FIXPASS=s9c_local_synthetic
MARKER=s9c-disposable-pg17; DB_MARKER=s9c-g2-reconciliation-wiring-synthetic-disposable-fixture-safe-to-drop
FIX=$D/s9c-fixture.sh
export GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1 NODE_OPTIONS=--max-old-space-size=4096 CHECKPOINT_DISABLE=1 \
       PRISMA_HIDE_UPDATE_MESSAGE=1 npm_config_offline=true npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false \
       npm_config_cache=$RUNTIME_ROOT/npm-cache XDG_CACHE_HOME=$RUNTIME_ROOT/xdg-cache
# S9-C-only identity: exactly the G2_S9C_* names the guard/harness/bootstrap read (G2_S9C_DATABASE_URL, _CONFIRM, _PASSWORD,
# _PSQL, _DATA_DIRECTORY, _SERVER_VERSION, _CANDIDATE_HEAD). G2_S9C_BASE_HEAD is a source literal, never read from env.
# Nothing G2_S9_*, G2_S8G_*, G2_S8F_*, G2_S8C_*, G2_S8B_*, G2_S7L_* or earlier is exported (and any inherited one is unset).
for v in $(compgen -e | grep -E '^G2_' | grep -vE '^G2_S9C_'); do unset "$v"; done
export G2_S9C_DATABASE_URL="postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=4" \
       G2_S9C_CONFIRM="$DBNAME:$PORT" G2_S9C_PASSWORD=$FIXPASS G2_S9C_PSQL=$PSQL \
       G2_S9C_DATA_DIRECTORY=$LANE/pg-data G2_S9C_SERVER_VERSION=170006 \
       G2_S9C_CANDIDATE_HEAD=$EXPECT_HEAD
export S9C_RUNNER_PID=$$ S9C_STOP_TIMEOUT=45
mkdir -p "$R"
[ -e "$SENT" ] && { echo "REFUSED: $SENT exists; this proof runs once, no retry" >&2; exit 76; }
[ -e "$LOCK" ] || { echo "REFUSED: canonical lock file $LOCK absent; runtime setup created it and it is never deleted or recreated here" >&2; exit 75; }
exec 9>>"$LOCK"; flock -n 9 || { echo "REFUSED: canonical lock busy ($LOCK)" >&2; exit 75; }
[ "$(stat -c %i "$LOCK")" = "$EXPECT_LOCK_INODE" ] || { echo "REFUSED: $LOCK inode $(stat -c %i "$LOCK") != $EXPECT_LOCK_INODE (LOCK_ESTABLISHED.txt); not the canonical lock file" >&2; exit 75; }
ts(){ date -u +%FT%TZ; }
log(){ echo "$*" | tee -a "$LOG"; }
sha(){ sha256sum "$1" | cut -c1-64; }
STAGE=preconditions; STARTED=0
finish(){ local rc=$1
  ( cd "$R" && sha256sum s9c-pg-proof.log $( [ -e jest.log ] && echo jest.log ) > RECEIPTS.sha256 2>/dev/null )
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
case "$EXPECT_HEAD$EXPECT_TREE$HARNESS_BASE_HEAD$EXPECT_SPEC_BLOB$EXPECT_BOOTSTRAP_BLOB$EXPECT_DB_BLOB$EXPECT_PGH_BLOB$EXPECT_HARNESS_BLOB$EXPECT_WORKER_BLOB$EXPECT_FIXTURE_SHA$PORT$RUNTIME_ROOT$EXPECT_POSTGRES_SHA$EXPECT_INITDB_SHA$EXPECT_PGCTL_SHA$EXPECT_PSQL_REAL_SHA$EXPECT_NODE_SHA$EXPECT_NM_LOCK_SHA$EXPECT_NM_CLIENT_SHA$BASE_HEAD$BASE_TREE" in *__*) log "PRECONDITION_FAIL pins not filled (proposal stage: head, port, runtime root or tool pins)"; fail 70;; esac
[ "$EXPECT_HEAD" != "$BASE_HEAD" ] || { log "PRECONDITION_FAIL EXPECT_HEAD is the base, not a candidate"; fail 70; }
[ "$(sha "$FIX")" = "$EXPECT_FIXTURE_SHA" ] || { log "PRECONDITION_FAIL fixture sha256 mismatch"; fail 70; }
# the fixture must carry exactly this runner's lane constants (whole-line, literal): one runtime root, one port, one marker
grep -qx "RUNTIME_ROOT=$RUNTIME_ROOT" "$FIX" || { log "PRECONDITION_FAIL fixture RUNTIME_ROOT line != $RUNTIME_ROOT"; fail 70; }
grep -qx "PORT=$PORT; SUPER=$ADMIN; PASS=$FIXPASS; MARKER=$MARKER" "$FIX" || { log "PRECONDITION_FAIL fixture PORT/SUPER/PASS/MARKER line != runner (PORT=$PORT ADMIN=$ADMIN MARKER=$MARKER)"; fail 70; }
grep -qx "LANE=\$RUNTIME_ROOT/clusters/s9-c" "$FIX" && grep -qx "DATA=\$LANE/pg-data; LOG=\$LANE/pg.log; SOCK=\$RUNTIME_ROOT/run/s9-c" "$FIX" || { log "PRECONDITION_FAIL fixture lane/socket lines != clusters/s9-c + run/s9-c"; fail 70; }
[ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] || { log "PRECONDITION_FAIL HEAD != $EXPECT_HEAD"; fail 70; }
[ "$(git -C "$W" rev-parse 'HEAD^{tree}')" = "$EXPECT_TREE" ] || { log "PRECONDITION_FAIL tree mismatch"; fail 70; }
[ "$(git -C "$W" rev-parse "$BASE_HEAD^{tree}")" = "$BASE_TREE" ] || { log "PRECONDITION_FAIL base tree mismatch"; fail 70; }
git -C "$W" merge-base --is-ancestor "$BASE_HEAD" HEAD || { log "PRECONDITION_FAIL base $BASE_HEAD not an ancestor"; fail 70; }
[ "$(git -C "$W" rev-parse HEAD^)" = "$BASE_HEAD" ] || { log "PRECONDITION_FAIL HEAD^ != $BASE_HEAD (the gate makes exactly one commit on BASE)"; fail 70; }
git -C "$W" merge-base --is-ancestor "$HARNESS_BASE_HEAD" "$BASE_HEAD" || { log "PRECONDITION_FAIL harness base $HARNESS_BASE_HEAD not an ancestor of $BASE_HEAD"; fail 70; }
# harness literals must match this runner (lane identity, base pin, migrations): read from the committed bytes at HEAD
BOOT_AT_HEAD=$(git -C "$W" show HEAD:test/utils/g2-s9c-bootstrap.sh) && DBTS_AT_HEAD=$(git -C "$W" show HEAD:test/utils/g2-s9c-db.ts) || { log "PRECONDITION_FAIL cannot read harness bytes at HEAD"; fail 70; }
# v2: grep captured bytes, never `git show | grep -q` under pipefail (grep -q exits early -> SIGPIPE 141 = false refusal; S9C-PROOF-1 rc=70)
grep -qx "BASE_HEAD=$HARNESS_BASE_HEAD" <<<"$BOOT_AT_HEAD" || { log "PRECONDITION_FAIL bootstrap BASE_HEAD != $HARNESS_BASE_HEAD"; fail 70; }
grep -qx "CLUSTER_MARKER=$MARKER" <<<"$BOOT_AT_HEAD" && grep -qx "DB_MARKER=$DB_MARKER" <<<"$BOOT_AT_HEAD" \
  && grep -qx "EXPECTED_MIGRATIONS=172" <<<"$BOOT_AT_HEAD" || { log "PRECONDITION_FAIL bootstrap marker/migration literals != runner"; fail 70; }
grep -qF "G2_S9C_DATABASE = '$DBNAME'" <<<"$DBTS_AT_HEAD" && grep -qF "G2_S9C_ROLE = '$ADMIN'" <<<"$DBTS_AT_HEAD" \
  && grep -qF "G2_S9C_CLUSTER_MARKER = '$MARKER'" <<<"$DBTS_AT_HEAD" && grep -qF "'$DB_MARKER'" <<<"$DBTS_AT_HEAD" \
  && grep -qF "G2_S9C_BASE_HEAD = '$HARNESS_BASE_HEAD'" <<<"$DBTS_AT_HEAD" || { log "PRECONDITION_FAIL g2-s9c-db.ts literals != runner"; fail 70; }
! grep -qE "^ +'$PORT',\$" <<<"$DBTS_AT_HEAD" || { log "PRECONDITION_FAIL lane port $PORT is in the S9-C guard's REFUSED_PORTS"; fail 70; }
[ "$(git -C "$W" show HEAD:test/rls-g2-s9c.spec.ts | grep -cE '^\s*it\(')" = "$EXPECT_TESTS" ] || { log "PRECONDITION_FAIL it() count in committed test/rls-g2-s9c.spec.ts != $EXPECT_TESTS"; fail 70; }
for pin in "test/rls-g2-s9c.spec.ts $EXPECT_SPEC_BLOB" "test/utils/g2-s9c-bootstrap.sh $EXPECT_BOOTSTRAP_BLOB" "test/utils/g2-s9c-db.ts $EXPECT_DB_BLOB" \
           "test/utils/g2-s9c-pg-harness.ts $EXPECT_PGH_BLOB" "test/utils/g2-s9c-harness.ts $EXPECT_HARNESS_BLOB" "test/utils/g2-s9c-worker.cjs $EXPECT_WORKER_BLOB"; do set -- $pin
  [ "$(git -C "$W" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL S9-C proof file $1 blob mismatch"; fail 70; }; done
[ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] || { log "PRECONDITION_FAIL worktree not clean"; fail 70; }
[ ! -e "$(git -C "$W" rev-parse --git-path MERGE_HEAD)" ] || { log "PRECONDITION_FAIL MERGE_HEAD present"; fail 70; }
# the committed head must have been produced through the tracked lefthook hooks (installed by the runtime donor's `prepare`)
H=$(git -C "$W" rev-parse --git-path hooks); case "$H" in /*) ;; *) H="$W/$H";; esac
grep -q lefthook "$H/pre-commit" 2>/dev/null && grep -q lefthook "$H/commit-msg" 2>/dev/null \
  || { log "PRECONDITION_FAIL $H/pre-commit or commit-msg absent or not lefthook (hookless commit)"; fail 70; }
# S9-C ships no schema/migration change (D-S9-5) and touches no accepted S9-B / S8-G / S8-C proof file, orchestration,
# reconstruct writer or run controller (literal blobs read at 5407efae in the standalone clone, 2026-09-26)
[ -z "$(git -C "$W" diff --name-only "$BASE_HEAD" HEAD -- prisma package.json package-lock.json)" ] || { log "PRECONDITION_FAIL prisma tree / dependency manifests differ from base"; fail 70; }
for pin in "prisma/schema.prisma 2e328bbcab0c902c6adb55dfb5ee172defc5f698" "prisma/migrations 654550cb99b55473429a9c60ee08319e1b649106" \
           "package-lock.json 354de3dae19449970497da6e4d87f0a1225a8f43" "jest.rls.config.js 44c9691533be2ea27f9a416271d9ff400f7faa3f" \
           "src/scout/reconstruct/orchestration bfbdc8200476364c3f3f288bf01d1e30aa94e39a" "src/scout/scout-reconstruct.service.ts fb72850284e33249b4b682bbf3f1d28a914357b6" \
           "src/scout/lifecycle/run.controller.ts 2bdeffc0e258453535c854e81799302b81f78e12" "src/scout/reconstruct/families.ts a6f286011741723491178af18dcd01f341aac448" \
           "test/utils/g2-s8c-db.ts a7d67217fe959f65daae9615e5f00806cc3764d3" "test/utils/g2-s8c-pg-harness.ts 4059883d70c26aed46398af707645aaacb306868" \
           "test/utils/g2-s8c-harness.ts 1a8f17970a1095f9b802badacf093e773caabd76" "test/utils/g2-s8c-bootstrap.sh 7c3fba471f991e3750eb56fd29e271101652196e" \
           "test/utils/g2-s8c-worker.cjs 484030636dee841bcd5aff1af42536128858ac77" "test/scout/g2-s8c-db-guard.spec.ts c3fc6bded0906fb27fd5cab49dc51fb17825db04" \
           "test/rls-g2-s8c.spec.ts 9d701783eeb7701126d158b45bfee3d5f0f686b3" \
           "test/utils/g2-s8g-db.ts c654e6bd7364be70fba9b63d9f061aa60646b122" "test/utils/g2-s8g-pg-harness.ts a02612463dcb2ed8b7605d68348011a0b1321be8" \
           "test/utils/g2-s8g-harness.ts ee2a41a2c118d4576878b65bf9b65cf220d0cf27" "test/utils/g2-s8g-bootstrap.sh 2ab85a1341cd4545edeb145dded67e6bef3fa2bf" \
           "test/utils/g2-s8g-worker.cjs 65ee972d3bb44eca84a6007d81b4675452e2d94c" "test/scout/g2-s8g-db-guard.spec.ts 4009f753a8d194fc9f9b180960a53f50a28bc79f" \
           "test/rls-g2-s8g.spec.ts 7cae12ad492f0c98c3288ede43956a450af643d1"; do set -- $pin
  [ "$(git -C "$W" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL accepted path $1 changed (blob/tree != base)"; fail 70; }; done
RD=$(git -C "$W" diff --name-only "$BASE_HEAD" HEAD -- src/scout/reconstruct | sort | tr '\n' ' ' | sed 's/ $//')
[ "$RD" = "$EXPECT_RECONSTRUCT_DELTA" ] || { log "PRECONDITION_FAIL src/scout/reconstruct delta [$RD] != expected [$EXPECT_RECONSTRUCT_DELTA]"; fail 70; }
# the accepted S9-A files (be88909f post-format) and the accepted S9-B files (1e6e5735, landed in 5407efae) must be
# present at the head exactly as accepted — never re-authored by S9-C (the S9 doc is S9-C-owned as append-only Addendum B)
for pin in "src/scout/reconciliation/types.ts b75994271f22cef235ff945edded0c27a4c4e796" "src/scout/reconciliation/coverage.ts f50d9401adbf6dc79bcc6a30cee0c9ada60ddb06" \
           "src/scout/reconciliation/reconcile.ts bcc85e491c9d48fa9c63ed3489e13eaa2993b116" "test/scout/reconciliation/reconcile.spec.ts 11f2a524e790815396c7b1bb97564f8dc1ba5394" \
           "src/scout/reconciliation/facts.service.ts 5ecd690182ba882c0a309d180c049c75a7861760" "src/scout/reconciliation/reconciliation.module.ts 9b88c2279c79ea8def155bb283bb3b8fce97924c" \
           "test/rls-g2-s9.spec.ts cbde1f538ba88293a0d431f06db19d69825c01e0" "test/scout/g2-s9-db-guard.spec.ts 1a719b2208b1f7bebca11bddf4a6b2d195ac735e" \
           "test/scout/reconciliation/facts.service.spec.ts b708ac854023a56414950be117b698b8338f5ce7" "test/utils/g2-s9-bootstrap.sh ce61b5866922c88f3766df888eafda2f00bcac74" \
           "test/utils/g2-s9-db.ts 02ee7bc8b580889c89ccba448ee288c000b48ea1" "test/utils/g2-s9-harness.ts cdbf154313d504d5c45c7b058bd1169b11f81a2f" \
           "test/utils/g2-s9-pg-harness.ts 88f3d0506b6e1835cd8628d9ff4f465b46d22cc8" "test/utils/g2-s9-worker.cjs 9fcff4c9f8deb7e800e9db1dd4daf66a4ec45e5b"; do set -- $pin
  [ "$(git -C "$W" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL frozen S9-A/S9-B file $1 blob != accepted record"; fail 70; }; done
[ -z "$(git -C "$W" diff --name-only "$BASE_HEAD" HEAD -- src/scout/reconciliation)" ] || { log "PRECONDITION_FAIL src/scout/reconciliation changed by S9-C"; fail 70; }
# the S9-C wiring surface is present at the head (lifecycle wired to the facts service; no report table; no native sidecar)
LCS_AT_HEAD=$(git -C "$W" show HEAD:src/scout/lifecycle/lifecycle.service.ts) && grep -q "ReconciliationFactsService" <<<"$LCS_AT_HEAD" || { log "PRECONDITION_FAIL lifecycle.service.ts at HEAD does not reference ReconciliationFactsService (S9-C wiring absent)"; fail 70; }
[ ! -e "$W/src/scout/reconstruct/native/sources" ] || { log "PRECONDITION_FAIL native sidecar directory present (none granted for this candidate)"; fail 70; }
# dependency tree: an ISOLATED real copy of the runtime donor (not a symlink, not platform node_modules, not a fresh npm ci)
[ -d "$W/node_modules" ] && [ ! -L "$W/node_modules" ] || { log "PRECONDITION_FAIL $W/node_modules absent or a symlink (isolated copy required)"; fail 70; }
case "$(readlink -f "$W/node_modules")" in "$W"/*) ;; *) log "PRECONDITION_FAIL node_modules resolves outside $W"; fail 70;; esac
[ "$(sha "$W/package-lock.json")" = "$EXPECT_PKG_LOCK_SHA" ] || { log "PRECONDITION_FAIL package-lock.json != base record"; fail 70; }
[ "$(sha "$W/node_modules/.package-lock.json")" = "$EXPECT_NM_LOCK_SHA" ] || { log "PRECONDITION_FAIL node_modules/.package-lock.json != donor record"; fail 70; }
[ "$(sha "$W/prisma/schema.prisma")" = "$EXPECT_SCHEMA_SHA" ] || { log "PRECONDITION_FAIL prisma/schema.prisma != 0eb41f9a"; fail 70; }
[ "$(sha "$W/node_modules/.prisma/client/index.d.ts")" = "$EXPECT_NM_CLIENT_SHA" ] || { log "PRECONDITION_FAIL generated client != runtime receipt record (no S9-C generate expected)"; fail 70; }
[ -x "$W/node_modules/.bin/jest" ] && [ -x "$W/node_modules/.bin/ts-node" ] && [ -x "$W/node_modules/.bin/prisma" ] || { log "PRECONDITION_FAIL jest/ts-node/prisma missing"; fail 70; }
# tools: pinned PG 17.6 server binaries in the 1910a060 namespace, the real psql 18.6 client binary (CB1) and Node 20
[ -x "$DIST/bin/postgres" ] && [ -x "$DIST/bin/initdb" ] && [ -x "$DIST/bin/pg_ctl" ] || { log "PRECONDITION_FAIL PG17 dist absent at $DIST"; fail 70; }
[ "$(sha "$DIST/bin/postgres")" = "$EXPECT_POSTGRES_SHA" ] || { log "PRECONDITION_FAIL postgres binary sha256 != pin"; fail 70; }
[ "$(sha "$DIST/bin/initdb")" = "$EXPECT_INITDB_SHA" ] || { log "PRECONDITION_FAIL initdb binary sha256 != pin"; fail 70; }
[ "$(sha "$DIST/bin/pg_ctl")" = "$EXPECT_PGCTL_SHA" ] || { log "PRECONDITION_FAIL pg_ctl binary sha256 != pin"; fail 70; }
PGV=$(LD_LIBRARY_PATH=$DIST/lib "$DIST/bin/postgres" --version 2>/dev/null); [ "${PGV##* }" = 17.6 ] || { log "PRECONDITION_FAIL server not 17.6: $PGV"; fail 70; }
[ -x "$PSQL" ] && [ "$(sha "$PSQL")" = "$EXPECT_PSQL_REAL_SHA" ] || { log "PRECONDITION_FAIL $PSQL absent or sha256 != pin"; fail 70; }
"$PSQL" --version | grep -qE "^psql \(PostgreSQL\) 18\." || { log "PRECONDITION_FAIL psql major != 18: $("$PSQL" --version)"; fail 70; }
NODE=$(command -v node); [ "$(sha "$(readlink -f "$NODE")")" = "$EXPECT_NODE_SHA" ] || { log "PRECONDITION_FAIL node sha256 != pin ($NODE)"; fail 70; }
node --version | grep -q '^v20\.' || { log "PRECONDITION_FAIL node major != 20"; fail 70; }
[ "$(readlink -f "$RUNTIME_ROOT")" = "$RUNTIME_ROOT" ] || { log "PRECONDITION_FAIL $RUNTIME_ROOT is not a real path"; fail 70; }
grep -q '^result=success' "$RUNTIME_ROOT/pg17/PROVENANCE.txt" 2>/dev/null || { log "PRECONDITION_FAIL pg17 PROVENANCE.txt lacks result=success"; fail 70; }
log "PRECONDITIONS_OK $(ts) server='$PGV' psql='$("$PSQL" --version)' node=$(node --version) jest=$(cd "$W" && ./node_modules/.bin/jest --version) ts_node=$(cd "$W" && ./node_modules/.bin/ts-node --version 2>/dev/null | head -1) prisma=$(cd "$W" && ./node_modules/.bin/prisma --version 2>/dev/null | awk '/^prisma /{print $3}')"
# ---- step 1 preflight (read-only): S9-C lane absent; lane port free; no postgres; other lanes under the runtime root (clusters/* incl.
#      clusters/s8-g and the retained S9-B clusters/s9-b, and proof-*/clusters/* incl. proof-s8g-diag1/clusters/s8-g) fingerprinted and never started
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
[ -e "$CLUSTERS" ] || log "PREFLIGHT clusters_dir=ABSENT (no clusters/* lane yet under the runtime root; proof-*/clusters/* scanned above)"
PORC0=$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)
log "PREFLIGHT_OK $(ts) lane=absent port$PORT=free postgres_procs=0 worktree_porcelain_sha=$PORC0 lock_inode=$(stat -c %i "$LOCK")"
# ---- step 2 init (bound 60 s)
STAGE=fixture-init; timeout -k 30 60 bash "$FIX" init >>"$LOG" 2>&1; rc=$?; log "FIXTURE_INIT rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^S9C_FIXTURE_INIT_OK data=$LANE/pg-data port=$PORT superuser=$ADMIN cluster_name=$MARKER socket=$SOCK " "$LOG" || { log "FIXTURE_INIT marker missing"; fail 72; }
# ---- step 3 start (bound 60 s)
STAGE=fixture-start; STARTED=1; timeout -k 30 60 bash "$FIX" start >>"$LOG" 2>&1; rc=$?; log "FIXTURE_START rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^S9C_FIXTURE_START_OK pid=" "$LOG" || { log "FIXTURE_START marker missing"; fail 72; }
# ---- step 4 S9-C bootstrap (committed helper at the attested head; roles, marked DB, extensions, the whole accepted
#      172-migration history through the candidate's `prisma migrate deploy` as postgres, S7-L/S8-B objects asserted,
#      candidate client VERIFIED structurally — no generate) (bound 900 s)
STAGE=bootstrap
( cd "$W" && timeout -k 30 900 bash test/utils/g2-s9c-bootstrap.sh bootstrap ) >>"$LOG" 2>&1; rc=$?; log "BOOTSTRAP rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^G2_S9C_BOOTSTRAP_OK" "$LOG" || { log "BOOTSTRAP marker missing"; fail 72; }
grep -q "^CANDIDATE_HEAD=$EXPECT_HEAD" "$LOG" || { log "BOOTSTRAP candidate binding line missing"; fail 72; }
# ---- step 5 identity (read-only, bound 15 s each; admin login with PGPASSWORD only, never a URL password)
STAGE=identity
psqlq(){ PGPASSWORD=$FIXPASS timeout -k 30 15 "$PSQL" -X -v ON_ERROR_STOP=1 -At "postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME" -c "$1" 2>>"$LOG"; }
DD=$(psqlq 'SHOW data_directory'); [ "$DD" = "$G2_S9C_DATA_DIRECTORY" ] || { log "IDENTITY_FAIL data_directory='$DD'"; fail 73; }
VN=$(psqlq 'SHOW server_version_num'); [ "$VN" = 170006 ] || { log "IDENTITY_FAIL server_version_num='$VN'"; fail 73; }
CN=$(psqlq "SELECT current_setting('cluster_name')"); [ "$CN" = "$MARKER" ] || { log "IDENTITY_FAIL cluster_name='$CN'"; fail 73; }
DM=$(psqlq "SELECT shobj_description(oid,'pg_database') FROM pg_database WHERE datname=current_database()")
[ "$DM" = "$DB_MARKER" ] || { log "IDENTITY_FAIL db marker='$DM'"; fail 73; }
MC=$(psqlq 'SELECT count(*) FROM "_prisma_migrations" WHERE finished_at IS NOT NULL AND rolled_back_at IS NULL'); [ "$MC" = 172 ] || { log "IDENTITY_FAIL applied migrations=$MC"; fail 73; }
PT=$(psqlq 'SELECT inet_server_port()'); [ "$PT" = "$PORT" ] || { log "IDENTITY_FAIL inet_server_port='$PT'"; fail 73; }
log "IDENTITY_OK $(ts) data_directory=$DD server_version_num=$VN cluster_name=$CN applied_migrations=$MC"
# ---- step 6 the proof, exactly once (bound 1500 s); no --testTimeout/--forceExit/--detectOpenHandles/coverage
STAGE=jest; log "JEST_START $(ts) cmd='./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s9c.spec.ts --runInBand --ci' candidate_head=$G2_S9C_CANDIDATE_HEAD"
( cd "$W" && timeout -k 30 1500 ./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s9c.spec.ts --runInBand --ci ) >"$JLOG" 2>&1; JRC=$?
log "JEST_END rc=$JRC $(ts)"; grep -E '^(Test Suites|Tests|Snapshots|Time):' "$JLOG" | tee -a "$LOG"
grep -E 'requires its explicitly confirmed|requires explicit database|unsupported or ambiguous connection option|requires the attested candidate head|not the accepted base|not the attested candidate|uncommitted changes|G2 proof requires|server identity mismatch' "$JLOG" >/dev/null && log "GUARD_REFUSAL_OBSERVED_IN_JEST_LOG"
[ $JRC = 0 ] || fail $JRC
grep -qE "^Tests: +$EXPECT_TESTS passed, $EXPECT_TESTS total" "$JLOG" || { log "JEST_COUNT_FAIL expected 'Tests: $EXPECT_TESTS passed, $EXPECT_TESTS total' (got: $(grep -E '^Tests:' "$JLOG" | head -1))"; fail 72; }
log "JEST_COUNT_OK tests=$EXPECT_TESTS"
# ---- step 7 stop (bound 45 s + kill 30); data dir RETAINED (destroy only via separate grant: s9c-fixture.sh destroy)
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
