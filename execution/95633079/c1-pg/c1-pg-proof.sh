#!/usr/bin/env bash
# C1-only real-PG proof — minimal execution binding of C1_PG_PROOF_PREPARATION.md §5 (frozen sequence) to the
# actual committed candidate a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992. Runs the EXISTING spec test/rls-c1-setup.spec.ts
# (22 cases, blob cc3b0e4d) exactly once via the existing repo jest + jest.rls.config.js. No new test, harness,
# retry, or control system. Single canonical lock holder; first nonzero stops (with bounded fixture stop as the only
# cleanup so no postmaster survives); every raw exit is recorded as observed. RUN ONLY UNDER A SEPARATE RUNTIME GRANT.
# Usage: bash /home/user/workspace/execution/95633079/c1-pg/c1-pg-proof.sh      (outer bound applied by launcher: timeout -k 30 900)
set -uo pipefail
D=/home/user/workspace/execution/95633079/c1-pg
W=/home/user/workspace/worktrees/s7-c1
R=$D/run; LOG=$R/c1-pg-proof.log; SENT=$R/c1-pg-proof.sentinel; JLOG=$R/jest.log
LOCK=/home/user/workspace/execution/test-validation.lock
EXPECT_HEAD=a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992
EXPECT_TREE=87798e742c7b48f56b05e9b5c30efa877180a9b3
EXPECT_SPEC_BLOB=cc3b0e4da17add10aade720c1b7e10a9f78db937
EXPECT_FIXTURE_SHA=27b816afb53ebaa5afbad73b6075eddd366d611799a44a44fa549b5f43ca5040
EXPECT_POSTGRES_SHA=23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a   # S1/S2 PG17_PROVENANCE (setup-20-pg17.sh)
EXPECT_INITDB_SHA=b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a
PG17_HOME=/home/user/pg17; DIST=$PG17_HOME/dist
S5DIR=$PG17_HOME/clusters/s5; C1DIR=$PG17_HOME/clusters/c1-builder
FIX=$D/c1-fixture.sh
export GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1 NODE_OPTIONS=--max-old-space-size=4096 CHECKPOINT_DISABLE=1 \
       PRISMA_HIDE_UPDATE_MESSAGE=1 npm_config_offline=true npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false
export C1_SETUP_TEST_DATABASE_URL=postgresql://user@127.0.0.1:55439/c1_setup_disposable \
       C1_TEST_PSQL=/usr/bin/psql C1_TEST_DATA_DIRECTORY=$C1DIR/pg-data \
       C1_SETUP_DISPOSABLE_ACK=c1-local-only-55439
export C1_RUNNER_PID=$$ C1_STOP_TIMEOUT=45
mkdir -p "$R"
[ -e "$SENT" ] && { echo "REFUSED: $SENT exists; this proof runs once, no retry" >&2; exit 76; }
exec 9>"$LOCK"; flock -n 9 || { echo "REFUSED: canonical lock busy ($LOCK)" >&2; exit 75; }
ts(){ date -u +%FT%TZ; }
log(){ echo "$*" | tee -a "$LOG"; }
STAGE=preconditions; STARTED=0
finish(){ # $1=rc ; sentinel is additive and written exactly once
  local rc=$1
  echo "RC=$rc STAGE=$STAGE END=$(ts) HEAD=$(git -C "$W" rev-parse HEAD 2>/dev/null)" >"$SENT"
  log "END rc=$rc stage=$STAGE $(ts)"; exit "$rc"
}
fail(){ # first nonzero: record, then ONLY cleanup = bounded fixture stop if we started it (survivor rule); exit with the FIRST rc
  local rc=$1; log "STOP_FIRST_FAILURE stage=$STAGE rc=$rc $(ts)"
  if [ "$STARTED" = 1 ]; then
    local src=0; timeout -k 30 60 bash "$FIX" stop >>"$LOG" 2>&1 || src=$?
    log "CLEANUP_STOP rc=$src postgres_procs=$(pgrep -cx postgres || true) port55439_listeners=$(ss -ltn 2>/dev/null | grep -c ':55439 ' || true)"
  fi
  finish "$rc"
}
log "START $(ts) pid=$$ head_expect=$EXPECT_HEAD fixture_expect=$EXPECT_FIXTURE_SHA node=$(node --version 2>/dev/null)"
# ---- preconditions (read-only)
[ "$(sha256sum "$FIX" | cut -c1-64)" = "$EXPECT_FIXTURE_SHA" ] || { log "PRECONDITION_FAIL fixture sha256 mismatch"; fail 70; }
[ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] || { log "PRECONDITION_FAIL HEAD != $EXPECT_HEAD"; fail 70; }
[ "$(git -C "$W" rev-parse 'HEAD^{tree}')" = "$EXPECT_TREE" ] || { log "PRECONDITION_FAIL tree mismatch"; fail 70; }
[ "$(git -C "$W" rev-parse HEAD:test/rls-c1-setup.spec.ts)" = "$EXPECT_SPEC_BLOB" ] || { log "PRECONDITION_FAIL spec blob mismatch"; fail 70; }
[ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] || { log "PRECONDITION_FAIL worktree not clean"; fail 70; }
[ ! -e "$W/.git/MERGE_HEAD" ] || { log "PRECONDITION_FAIL MERGE_HEAD present"; fail 70; }
[ -x "$W/node_modules/.bin/jest" ] && [ -x "$W/node_modules/.bin/ts-node" ] || { log "PRECONDITION_FAIL jest/ts-node missing in $W/node_modules"; fail 70; }
grep -q ImportIntent "$W/node_modules/.prisma/client/index.d.ts" 2>/dev/null || { log "PRECONDITION_FAIL generated Prisma client lacks ImportIntent"; fail 70; }
[ -x "$DIST/bin/postgres" ] && [ -x "$DIST/bin/initdb" ] && [ -x "$DIST/bin/pg_ctl" ] || { log "PRECONDITION_FAIL PG17 dist absent at $DIST (recovery is a separate grant; see ENVIRONMENT_RECOVERY.md)"; fail 70; }
[ "$(sha256sum "$DIST/bin/postgres" | cut -c1-64)" = "$EXPECT_POSTGRES_SHA" ] || { log "PRECONDITION_FAIL postgres binary sha256 != recorded"; fail 70; }
[ "$(sha256sum "$DIST/bin/initdb" | cut -c1-64)" = "$EXPECT_INITDB_SHA" ] || { log "PRECONDITION_FAIL initdb binary sha256 != recorded"; fail 70; }
PGV=$(LD_LIBRARY_PATH=$DIST/lib "$DIST/bin/postgres" --version 2>/dev/null); [ "${PGV##* }" = 17.6 ] || { log "PRECONDITION_FAIL server not 17.6: $PGV"; fail 70; }
[ -x /usr/bin/psql ] || { log "PRECONDITION_FAIL /usr/bin/psql absent (recovery is a separate grant)"; fail 70; }
[ "$(readlink -f "$PG17_HOME")" = "$PG17_HOME" ] || { log "PRECONDITION_FAIL $PG17_HOME is not a real path"; fail 70; }
log "PRECONDITIONS_OK $(ts) server='$PGV' psql='$(/usr/bin/psql --version)' jest=$(cd "$W" && ./node_modules/.bin/jest --version)"
# ---- step 1 preflight (read-only)
STAGE=preflight
[ ! -e "$C1DIR" ] || { log "PREFLIGHT_FAIL $C1DIR exists (fresh init only; never adopt)"; fail 71; }
L=$(ss -ltn 2>/dev/null | grep -c ':55439 ' || true); [ "$L" = 0 ] || { log "PREFLIGHT_FAIL port 55439 listeners=$L"; fail 71; }
P=$(pgrep -cx postgres || true); [ "$P" = 0 ] || { log "PREFLIGHT_FAIL postgres procs=$P"; fail 71; }
if [ -e "$S5DIR" ]; then
  [ ! -e "$S5DIR/postmaster.pid" ] || { log "PREFLIGHT_FAIL s5 postmaster.pid present"; fail 71; }
  S5_CONF0=$(sha256sum "$S5DIR/postgresql.conf" | cut -c1-64); S5_CTRL0=$(sha256sum "$S5DIR/global/pg_control" | cut -c1-64)
  log "PREFLIGHT s5_cluster=PRESENT conf=$S5_CONF0 pg_control=$S5_CTRL0 (must be unchanged at end; never started)"
else
  S5_CONF0=ABSENT; S5_CTRL0=ABSENT; log "PREFLIGHT s5_cluster=ABSENT (fresh sandbox; recorded as-is, not reconstructed)"
fi
PORC0=$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)
log "PREFLIGHT_OK $(ts) c1dir=absent port55439=free postgres_procs=0 worktree_porcelain_sha=$PORC0"
# ---- step 2 init (bound 60 s)
STAGE=fixture-init; timeout -k 30 60 bash "$FIX" init >>"$LOG" 2>&1; rc=$?; log "FIXTURE_INIT rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^C1_FIXTURE_INIT_OK data=$C1DIR/pg-data port=55439 superuser=user" "$LOG" || { log "FIXTURE_INIT marker missing"; fail 72; }
# ---- step 3 start (bound 60 s)
STAGE=fixture-start; STARTED=1; timeout -k 30 60 bash "$FIX" start >>"$LOG" 2>&1; rc=$?; log "FIXTURE_START rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^C1_FIXTURE_START_OK pid=" "$LOG" || { log "FIXTURE_START marker missing"; fail 72; }
# ---- step 4 the ONE database-creation command (bound 30 s)
STAGE=create-database
timeout -k 30 30 /usr/bin/psql -X -v ON_ERROR_STOP=1 -At postgresql://user@127.0.0.1:55439/postgres -c 'CREATE DATABASE c1_setup_disposable' >>"$LOG" 2>&1; rc=$?
log "CREATE_DATABASE rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
# ---- step 5 identity check (read-only, bound 15 s each)
STAGE=identity
DD=$(timeout -k 30 15 /usr/bin/psql -X -v ON_ERROR_STOP=1 -At "$C1_SETUP_TEST_DATABASE_URL" -c 'SHOW data_directory' 2>>"$LOG"); rc=$?
[ $rc = 0 ] && [ "$DD" = "$C1_TEST_DATA_DIRECTORY" ] || { log "IDENTITY_FAIL data_directory='$DD' rc=$rc expect=$C1_TEST_DATA_DIRECTORY"; fail 73; }
VN=$(timeout -k 30 15 /usr/bin/psql -X -v ON_ERROR_STOP=1 -At "$C1_SETUP_TEST_DATABASE_URL" -c 'SHOW server_version_num' 2>>"$LOG"); rc=$?
[ $rc = 0 ] && [ "$VN" = 170006 ] || { log "IDENTITY_FAIL server_version_num='$VN' rc=$rc"; fail 73; }
log "IDENTITY_OK $(ts) data_directory=$DD server_version_num=$VN"
# ---- step 6 the proof, exactly once (bound 600 s); no --testTimeout/--forceExit/--detectOpenHandles/coverage
STAGE=jest; log "JEST_START $(ts) cmd='./node_modules/.bin/jest --config jest.rls.config.js test/rls-c1-setup.spec.ts --runInBand --ci'"
( cd "$W" && timeout -k 30 600 ./node_modules/.bin/jest --config jest.rls.config.js test/rls-c1-setup.spec.ts --runInBand --ci ) >"$JLOG" 2>&1; JRC=$?
log "JEST_END rc=$JRC $(ts)"; grep -E '^(Test Suites|Tests|Snapshots|Time):' "$JLOG" | tee -a "$LOG"
grep -E 'requires an explicitly acknowledged disposable cluster|not the permitted disposable database|server identity mismatch' "$JLOG" >/dev/null && log "GUARD_REFUSAL_OBSERVED_IN_JEST_LOG"
[ $JRC = 0 ] || fail $JRC
# ---- step 7 stop (bound 45 s + kill 30); data dir RETAINED
STAGE=fixture-stop; STARTED=0; timeout -k 30 75 bash "$FIX" stop >>"$LOG" 2>&1; rc=$?; log "FIXTURE_STOP rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
P=$(pgrep -cx postgres || true); L=$(ss -ltn 2>/dev/null | grep -c ':55439 ' || true)
[ "$P" = 0 ] && [ "$L" = 0 ] && [ ! -e "$C1DIR/pg-data/postmaster.pid" ] && [ -d "$C1DIR/pg-data" ] || { log "STOP_STATE_FAIL postgres_procs=$P listeners=$L pidfile=$([ -e "$C1DIR/pg-data/postmaster.pid" ] && echo present || echo absent) datadir=$([ -d "$C1DIR/pg-data" ] && echo retained || echo MISSING)"; fail 74; }
log "STOP_STATE_OK postgres_procs=0 port55439=free datadir_retained=$C1DIR/pg-data"
# ---- step 8 post (read-only)
STAGE=post
if [ "$S5_CONF0" = ABSENT ]; then [ ! -e "$S5DIR" ] || { log "POST_FAIL s5 cluster appeared"; fail 74; }; log "POST s5_cluster=ABSENT unchanged"
else
  [ "$(sha256sum "$S5DIR/postgresql.conf" | cut -c1-64)" = "$S5_CONF0" ] && [ "$(sha256sum "$S5DIR/global/pg_control" | cut -c1-64)" = "$S5_CTRL0" ] && [ ! -e "$S5DIR/postmaster.pid" ] || { log "POST_FAIL s5 cluster changed"; fail 74; }
  log "POST s5_cluster unchanged conf=$S5_CONF0 pg_control=$S5_CTRL0"
fi
[ "$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)" = "$PORC0" ] && [ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] || { log "POST_FAIL worktree changed"; fail 74; }
( cd "$R" && sha256sum c1-pg-proof.log jest.log > RECEIPTS.sha256 ) ; log "POST_OK $(ts) receipts=$R/RECEIPTS.sha256"
STAGE=done; finish 0
