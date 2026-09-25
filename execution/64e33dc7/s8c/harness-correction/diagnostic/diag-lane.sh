#!/usr/bin/env bash
# S8C-BC-3 diagnostic scratch lane (NON-ACCEPTING; S8C_V4_FAILED_PROOF_DISPOSITION "Diagnostic allowance").
# Scratch lane ONLY: recovery-reset/scratch/s8c-diag (pg-data + run), port 55644. Never proof-v4/proof-v5, never the
# retained v4 pg-data, never a frozen driver/fixture. Same PG17 dist + initdb recipe as the S8-C fixture (marker
# s8c-disposable-pg17, superuser s8c_super, scram) so the unchanged committed bootstrap accepts the server.
# Usage: diag-lane.sh init|start|stop|status   (invoked only by diag-a-catalog.sh / diag-b-suite.sh, which hold the slot)
set -uo pipefail
RUNTIME_ROOT=/home/user/workspace/execution/64e33dc7/recovery-reset
PGHOME=$RUNTIME_ROOT/pg17/dist; PORT=55644; SUPER=s8c_super; PASS=s8c_local_synthetic; MARKER=s8c-disposable-pg17
LANE=$RUNTIME_ROOT/scratch/s8c-diag; DATA=$LANE/pg-data; LOG=$LANE/pg.log; SOCK=$LANE/run
cmd=${1:?init|start|stop|status}
[ -n "${S8C_DIAG_PID:-}" ] && [ -d "/proc/$S8C_DIAG_PID" ] || { echo "diag-lane.sh: refuse standalone use (S8C_DIAG_PID)" >&2; exit 2; }
[ -x "$PGHOME/bin/pg_ctl" ] || { echo "PG17 dist missing" >&2; exit 2; }
case "$DATA" in "$PGHOME"/*|/home/user/pg17/*|*/proof-v*|*/clusters/*) echo "REFUSED: data path $DATA" >&2; exit 2;; esac
pgbin(){ local b=$1; shift; LD_LIBRARY_PATH="$PGHOME/lib" "$PGHOME/bin/$b" "$@" 9>&-; }
mkdir -p "$SOCK" "$LANE"
case "$cmd" in
  init)
    [ -e "$DATA" ] && { echo "REFUSED: $DATA exists (fresh init only)" >&2; exit 3; }
    pwfile=$(mktemp); echo "$PASS" >"$pwfile"
    pgbin initdb -D "$DATA" -U "$SUPER" -A scram-sha-256 --pwfile="$pwfile" -E UTF8 --locale=C.UTF-8 >"$DATA.initdb.log" 2>&1 </dev/null || { rm -f "$pwfile"; echo "initdb failed" >&2; exit 3; }
    rm -f "$pwfile"
    cat >>"$DATA/postgresql.conf" <<CONF
# --- S8-C DIAGNOSTIC scratch lane (non-accepting) ---
cluster_name = '$MARKER'
port = $PORT
listen_addresses = '127.0.0.1'
unix_socket_directories = '$SOCK'
shared_buffers = 128MB
work_mem = 8MB
maintenance_work_mem = 64MB
max_connections = 40
fsync = off
synchronous_commit = off
full_page_writes = off
log_min_messages = warning
log_lock_waits = on
deadlock_timeout = 500ms
CONF
    echo "DIAG_LANE_INIT_OK data=$DATA port=$PORT superuser=$SUPER cluster_name=$MARKER socket=$SOCK pg_version=$(cat "$DATA/PG_VERSION")" ;;
  start)
    grep -q "^cluster_name = '$MARKER'" "$DATA/postgresql.conf" || { echo "REFUSED: unmarked cluster" >&2; exit 3; }
    grep -q "^# --- S8-C DIAGNOSTIC scratch lane" "$DATA/postgresql.conf" || { echo "REFUSED: not the diagnostic scratch lane" >&2; exit 3; }
    pgbin pg_ctl -D "$DATA" -l "$LOG" -w -t 60 start </dev/null >>"$LOG.pg_ctl" 2>&1 || { echo "start failed" >&2; exit 3; }
    echo "DIAG_LANE_START_OK pid=$(head -1 "$DATA/postmaster.pid")" ;;
  stop)
    rc=0; pgbin pg_ctl -D "$DATA" -m fast -w -t 45 stop </dev/null >>"$LOG.pg_ctl" 2>&1 || rc=$?
    if [ -f "$DATA/postmaster.pid" ] && kill -0 "$(head -1 "$DATA/postmaster.pid")" 2>/dev/null; then echo "DIAG_LANE_STOP_FAILED survivor=$(head -1 "$DATA/postmaster.pid")" >&2; exit 4; fi
    [ "$rc" = 0 ] || { echo "DIAG_LANE_STOP_FAILED rc=$rc" >&2; exit "$rc"; }
    echo "DIAG_LANE_STOP_OK" ;;
  status) pgbin pg_ctl -D "$DATA" status || true ;;
  *) echo "unknown cmd" >&2; exit 2 ;;
esac
