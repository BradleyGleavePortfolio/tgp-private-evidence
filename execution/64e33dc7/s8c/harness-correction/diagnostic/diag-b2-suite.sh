#!/usr/bin/env bash
# S8C-BC-4 diagnostic (b) RE-RUN (b2), NON-ACCEPTING: the RLS suite (test/rls-g2-s8c.spec.ts) against the scratch lane bootstrapped
# by diag-a-catalog.sh (port 55644), at the clean committed harness-correction head. Surfaces any further harness
# defects before the v5 binding. Holds the canonical slot with flock -n and YIELDS (rc 75) if any holder exists.
# Never touches proof-v4/proof-v5 lanes, retained pg-data, or frozen drivers. Runs once; results are diagnostic only.
set -uo pipefail
LOCK=/home/user/workspace/execution/test-validation.lock
D=$(cd "$(dirname "$0")" && pwd); W=/home/user/workspace/worktrees/64e33dc7-s8c
RUNTIME_ROOT=/home/user/workspace/execution/64e33dc7/recovery-reset
LANE=$RUNTIME_ROOT/scratch/s8c-diag; DATA=$LANE/pg-data
PORT=55644; DBNAME=g2_s8c_disposable; ADMIN=s8c_super; FIXPASS=s8c_local_synthetic
EXPECT_HEAD=${S8C_DIAG_B2_HEAD:?attested harness-correction head (40 hex)}
OUT=$D/b2; mkdir -p "$OUT"; LOG=$OUT/diag-b.log; JLOG=$OUT/jest.log
ts(){ date -u +%FT%TZ; }; log(){ echo "$*" | tee -a "$LOG"; }
export S8C_DIAG_PID=$$
export GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1 NODE_OPTIONS=--max-old-space-size=4096 CHECKPOINT_DISABLE=1 \
       PRISMA_HIDE_UPDATE_MESSAGE=1 npm_config_offline=true npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false \
       npm_config_cache=$RUNTIME_ROOT/npm-cache XDG_CACHE_HOME=$RUNTIME_ROOT/xdg-cache
[ -e "$LOG" ] && { echo "REFUSED: $LOG exists; diagnostic (b) runs once" >&2; exit 70; }
exec 9>>"$LOCK"
if ! flock -n 9; then echo "YIELD: slot busy ($(ts)) holders: $(fuser "$LOCK" 2>/dev/null)" >&2; exit 75; fi
log "DIAG_B2_BEGIN $(ts) pid=$$ lock_inode=$(stat -c %i "$LOCK") lock_acquired=$(ts)"
STARTED=0
fail(){ log "DIAG_B2_FAIL rc=$1 stage=$STAGE $(ts)"; if [ $STARTED = 1 ]; then bash "$D/diag-lane.sh" stop >>"$LOG" 2>&1; log "CLEANUP_STOP rc=$?"; fi; log "DIAG_B2_END rc=$1 $(ts)"; exit "$1"; }
STAGE=preconditions
pgrep -x postgres >/dev/null && { log "REFUSED: postgres running"; fail 71; }
ss -ltn 2>/dev/null | grep -qE ":(55641|55642|55644) " && { log "REFUSED: port busy"; fail 71; }
[ -d "$DATA" ] && [ ! -f "$DATA/postmaster.pid" ] || { log "REFUSED: scratch pg-data missing or postmaster.pid present"; fail 71; }
grep -q '^DIAG_A_END rc=0' "$D/a/diag-a.log" 2>/dev/null || { log "REFUSED: diagnostic (a) did not end rc=0"; fail 71; }
HEAD=$(git -C "$W" rev-parse HEAD); [ "$HEAD" = "$EXPECT_HEAD" ] || { log "REFUSED: head $HEAD != $EXPECT_HEAD"; fail 71; }
[ -z "$(git -C "$W" status --porcelain)" ] || { log "REFUSED: dirty tree"; fail 71; }
git -C "$W" merge-base --is-ancestor 9cc764013fd1d726dad082eebfa7def50800a6b2 "$HEAD" || { log "REFUSED: not a descendant of 9cc76401"; fail 71; }
log "PRECONDITIONS_OK $(ts) head=$HEAD"
STAGE=lane-start; STARTED=1; timeout -k 30 60 bash "$D/diag-lane.sh" start >>"$LOG" 2>&1 || fail $?
log "LANE_UP $(ts) pid=$(head -1 "$DATA/postmaster.pid")"
STAGE=identity
psqlq(){ PGPASSWORD=$FIXPASS timeout -k 30 15 /usr/bin/psql -X -v ON_ERROR_STOP=1 -At "postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME" -c "$1" 2>>"$LOG"; }
MC=$(psqlq 'SELECT count(*) FROM "_prisma_migrations" WHERE finished_at IS NOT NULL AND rolled_back_at IS NULL'); [ "$MC" = 171 ] || { log "IDENTITY_FAIL migrations=$MC"; fail 73; }
CN=$(psqlq "SELECT current_setting('cluster_name')"); [ "$CN" = s8c-disposable-pg17 ] || { log "IDENTITY_FAIL cluster=$CN"; fail 73; }
log "IDENTITY_OK $(ts) applied_migrations=$MC cluster_name=$CN"
STAGE=jest
export G2_S8C_DATABASE_URL="postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=4" \
       G2_S8C_CONFIRM="$DBNAME:$PORT" G2_S8C_PASSWORD=$FIXPASS G2_S8C_PSQL=/usr/bin/psql \
       G2_S8C_DATA_DIRECTORY=$DATA G2_S8C_SERVER_VERSION=170006 G2_S8C_CANDIDATE_HEAD=$HEAD
log "JEST_START $(ts) cmd='./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s8c.spec.ts --runInBand --ci' candidate_head=$HEAD"
( cd "$W" && timeout -k 30 1500 ./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s8c.spec.ts --runInBand --ci ) >"$JLOG" 2>&1; JRC=$?
log "JEST_END rc=$JRC $(ts)"; grep -E '^(Test Suites|Tests|Snapshots|Time):' "$JLOG" | tee -a "$LOG"
STAGE=lane-stop; STARTED=0; timeout -k 30 75 bash "$D/diag-lane.sh" stop >>"$LOG" 2>&1; rc=$?; log "LANE_STOP rc=$rc $(ts)"
log "POST postgres_procs=$(pgrep -cx postgres || true) port55644_listeners=$(ss -ltn 2>/dev/null | grep -c ':55644 ' || true) postmaster_pid_present=$([ -f "$DATA/postmaster.pid" ] && echo yes || echo no)"
( cd "$OUT" && sha256sum diag-b.log jest.log >RECEIPTS.sha256 ) 2>/dev/null
log "DIAG_B2_END rc=$JRC $(ts) (jest rc; diagnostic only, never acceptance)"
exit "$JRC"
