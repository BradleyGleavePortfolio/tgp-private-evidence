#!/usr/bin/env bash
# S8C-BC-3 diagnostic (a), NON-ACCEPTING: fresh scratch lane (port 55644) + the UNCHANGED committed bootstrap at the
# clean candidate head, then the authoritative information_schema query for NOT NULL / no-default / non-identity /
# non-generated columns of every public table after the 171 migrations. Holds the canonical slot with flock -n and
# YIELDS (rc 75) if any holder exists. Never touches proof-v4/proof-v5 lanes, retained pg-data, or frozen drivers.
set -uo pipefail
LOCK=/home/user/workspace/execution/test-validation.lock
D=$(cd "$(dirname "$0")" && pwd); W=/home/user/workspace/worktrees/64e33dc7-s8c
RUNTIME_ROOT=/home/user/workspace/execution/64e33dc7/recovery-reset
LANE=$RUNTIME_ROOT/scratch/s8c-diag; DATA=$LANE/pg-data
PORT=55644; DBNAME=g2_s8c_disposable; ADMIN=s8c_super; FIXPASS=s8c_local_synthetic
OUT=$D/a; mkdir -p "$OUT"; LOG=$OUT/diag-a.log
ts(){ date -u +%FT%TZ; }; log(){ echo "$*" | tee -a "$LOG"; }
export S8C_DIAG_PID=$$
export GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1 NODE_OPTIONS=--max-old-space-size=4096 CHECKPOINT_DISABLE=1 \
       PRISMA_HIDE_UPDATE_MESSAGE=1 npm_config_offline=true npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false \
       npm_config_cache=$RUNTIME_ROOT/npm-cache XDG_CACHE_HOME=$RUNTIME_ROOT/xdg-cache
[ -e "$LOG" ] && { echo "REFUSED: $LOG exists; diagnostic (a) runs once" >&2; exit 70; }
exec 9>>"$LOCK"
if ! flock -n 9; then echo "YIELD: slot busy ($(ts)) holders: $(fuser "$LOCK" 2>/dev/null)" >&2; exit 75; fi
log "DIAG_A_BEGIN $(ts) pid=$$ lock_inode=$(stat -c %i "$LOCK") lock_acquired=$(ts)"
STARTED=0
fail(){ log "DIAG_A_FAIL rc=$1 stage=$STAGE $(ts)"; if [ $STARTED = 1 ]; then bash "$D/diag-lane.sh" stop >>"$LOG" 2>&1; log "CLEANUP_STOP rc=$?"; fi; log "DIAG_A_END rc=$1 $(ts)"; exit "$1"; }
# preconditions
STAGE=preconditions
pgrep -x postgres >/dev/null && { log "REFUSED: postgres running"; fail 71; }
ss -ltn 2>/dev/null | grep -qE ":(55641|55642|55644) " && { log "REFUSED: port busy"; fail 71; }
[ -e "$LANE" ] && { log "REFUSED: scratch lane $LANE exists"; fail 71; }
HEAD=$(git -C "$W" rev-parse HEAD); [ "$HEAD" = e0cee7e04bef88811310f6dde1fd921f45d103ad ] || { log "REFUSED: head $HEAD"; fail 71; }
[ -z "$(git -C "$W" status --porcelain)" ] || { log "REFUSED: dirty tree"; fail 71; }
log "PRECONDITIONS_OK $(ts) head=$HEAD"
# lane
STAGE=lane-init; timeout -k 30 120 bash "$D/diag-lane.sh" init >>"$LOG" 2>&1 || fail $?
STAGE=lane-start; STARTED=1; timeout -k 30 60 bash "$D/diag-lane.sh" start >>"$LOG" 2>&1 || fail $?
log "LANE_UP $(ts) pid=$(head -1 "$DATA/postmaster.pid")"
# bootstrap (unchanged committed helper)
STAGE=bootstrap
export G2_S8C_DATABASE_URL="postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=4" \
       G2_S8C_CONFIRM="$DBNAME:$PORT" G2_S8C_PASSWORD=$FIXPASS G2_S8C_PSQL=/usr/bin/psql \
       G2_S8C_DATA_DIRECTORY=$DATA G2_S8C_SERVER_VERSION=170006 G2_S8C_CANDIDATE_HEAD=$HEAD
( cd "$W" && timeout -k 30 900 bash test/utils/g2-s8c-bootstrap.sh bootstrap ) >"$OUT/bootstrap.log" 2>&1; rc=$?; log "BOOTSTRAP rc=$rc $(ts)"
grep -q '^G2_S8C_BOOTSTRAP_OK' "$OUT/bootstrap.log" || { log "BOOTSTRAP marker missing"; fail 72; }
[ $rc = 0 ] || fail $rc
# authoritative catalog query
STAGE=catalog
psqlq(){ PGPASSWORD=$FIXPASS timeout -k 30 30 /usr/bin/psql -X -v ON_ERROR_STOP=1 -At -F $'\t' "postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME" "$@" 2>>"$LOG"; }
MC=$(psqlq -c 'SELECT count(*) FROM "_prisma_migrations" WHERE finished_at IS NOT NULL AND rolled_back_at IS NULL'); log "APPLIED_MIGRATIONS=$MC"
[ "$MC" = 171 ] || fail 73
psqlq -c "SELECT table_name, ordinal_position, column_name, data_type, is_nullable, coalesce(column_default,'<none>'), is_identity, is_generated
  FROM information_schema.columns WHERE table_schema='public' ORDER BY table_name, ordinal_position" >"$OUT/columns_all.tsv" || fail 74
psqlq -c "SELECT table_name, column_name, data_type FROM information_schema.columns WHERE table_schema='public'
  AND is_nullable='NO' AND column_default IS NULL AND is_identity='NO' AND is_generated='NEVER' ORDER BY table_name, ordinal_position" >"$OUT/required_no_default_all.tsv" || fail 74
psqlq -c "SELECT table_name, column_name, data_type FROM information_schema.columns WHERE table_schema='public'
  AND table_name IN ('User','ScoutImport','ScoutIngestEntity','ExerciseCatalogItem','ScoutReconstructionLedger')
  AND is_nullable='NO' AND column_default IS NULL AND is_identity='NO' AND is_generated='NEVER' ORDER BY table_name, ordinal_position" >"$OUT/required_no_default_harness_tables.tsv" || fail 74
log "CATALOG_ROWS all=$(wc -l <"$OUT/columns_all.tsv") required_no_default=$(wc -l <"$OUT/required_no_default_all.tsv") harness_tables=$(wc -l <"$OUT/required_no_default_harness_tables.tsv")"
log "HARNESS_TABLES_REQUIRED_NO_DEFAULT:"; sed 's/^/  /' "$OUT/required_no_default_harness_tables.tsv" | tee -a "$LOG"
# stop (data retained for diagnostic (b))
STAGE=lane-stop; STARTED=0; timeout -k 30 75 bash "$D/diag-lane.sh" stop >>"$LOG" 2>&1; rc=$?; log "LANE_STOP rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
log "POST postgres_procs=$(pgrep -cx postgres || true) port55644_listeners=$(ss -ltn 2>/dev/null | grep -c ':55644 ' || true) postmaster_pid_present=$([ -f "$DATA/postmaster.pid" ] && echo yes || echo no)"
( cd "$OUT" && sha256sum diag-a.log bootstrap.log columns_all.tsv required_no_default_all.tsv required_no_default_harness_tables.tsv >RECEIPTS.sha256 ) 2>/dev/null
log "DIAG_A_END rc=0 $(ts) lock_released_at_exit"
exit 0
