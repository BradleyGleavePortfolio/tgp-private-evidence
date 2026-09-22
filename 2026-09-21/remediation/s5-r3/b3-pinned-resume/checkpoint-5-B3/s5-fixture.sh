#!/usr/bin/env bash
# S5 R3 disposable PostgreSQL 17.6 cluster helper (lane s5 only). LOCK-FREE BY DESIGN: it takes no
# flock itself and must be invoked only by execution/s5-r3/run-proof.sh, which is the single canonical
# lock holder across init/start/preflight/bootstrap/live/reset/stop (nested flock would otherwise
# conflict, and a lock fd inherited by the daemonised postmaster would pin the lock for its lifetime).
# Standalone use is refused unless S5_RUNNER_PID names a live run-proof.sh process.
#   * cluster_name = 's5-disposable-pg17' (pinned marker required by preflight and bootstrap)
#   * FRESH INIT ONLY: init refuses if the data directory exists (no marking/adopting unknown clusters)
#   * listen 127.0.0.1 only, port 54325, superuser s5_super / s5_local_synthetic (synthetic value)
#   * data directory /home/user/pg17/clusters/s5; binaries from S2's SHA-pinned /home/user/pg17/dist
# Usage (via runner): s5-fixture.sh init|start|stop|status|destroy
set -euo pipefail
PG17_HOME=/home/user/pg17; PGHOME=$PG17_HOME/dist
PORT=54325; SUPER=s5_super; PASS=s5_local_synthetic; MARKER=s5-disposable-pg17
DATA=$PG17_HOME/clusters/s5; LOG=$PG17_HOME/clusters/s5.log; SOCK=$PG17_HOME/run/s5
cmd=${1:?init|start|stop|status|destroy}
[ -n "${S5_RUNNER_PID:-}" ] && [ -d "/proc/$S5_RUNNER_PID" ] && grep -q run-proof.sh "/proc/$S5_RUNNER_PID/cmdline" \
  || { echo "s5-fixture.sh must be invoked by run-proof.sh (single lock holder); refusing standalone $cmd" >&2; exit 2; }
[ -x "$PGHOME/bin/pg_ctl" ] || { echo "PG 17 distribution missing at $PGHOME" >&2; exit 2; }
# Children never see the runner's lock fd; the postmaster gets /dev/null stdin and the server log only.
pgbin(){ local b=$1; shift; LD_LIBRARY_PATH="$PGHOME/lib" "$PGHOME/bin/$b" "$@" 9>&-; }
mkdir -p "$SOCK" "$PG17_HOME/clusters"
case "$cmd" in
  init)
    [ -e "$DATA" ] && { echo "REFUSED: $DATA already exists; fresh init only (no adoption or marking of existing clusters)" >&2; exit 3; }
    pwfile=$(mktemp); echo "$PASS" >"$pwfile"
    pgbin initdb -D "$DATA" -U "$SUPER" -A scram-sha-256 --pwfile="$pwfile" -E UTF8 --locale=C.UTF-8 >"$DATA.initdb.log" 2>&1 </dev/null
    rm -f "$pwfile"
    cat >>"$DATA/postgresql.conf" <<CONF
# --- S5 R3 disposable fixture (2 vCPU / 8 GB sandbox) ---
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
    echo "S5_FIXTURE_INIT_OK data=$DATA port=$PORT superuser=$SUPER cluster_name=$MARKER pg_version=$(cat "$DATA/PG_VERSION")" ;;
  start)
    grep -q "^cluster_name = '$MARKER'" "$DATA/postgresql.conf" || { echo "REFUSED: $DATA lacks the S5 marker; not starting a foreign cluster" >&2; exit 3; }
    if pgbin pg_ctl -D "$DATA" status >/dev/null 2>&1; then echo "already running"; else
      pgbin pg_ctl -D "$DATA" -l "$LOG" -w -t 60 start </dev/null >>"$LOG.pg_ctl" 2>&1; fi
    echo "S5_FIXTURE_START_OK pid=$(head -1 "$DATA/postmaster.pid")" ;;
  stop)    pgbin pg_ctl -D "$DATA" -m fast -w -t 60 stop </dev/null >>"$LOG.pg_ctl" 2>&1 && echo "S5_FIXTURE_STOP_OK" ;;
  status)  pgbin pg_ctl -D "$DATA" status || true ;;
  destroy)
    grep -q "^cluster_name = '$MARKER'" "$DATA/postgresql.conf" 2>/dev/null || { echo "REFUSED: $DATA is not the marked S5 cluster; not destroying" >&2; exit 3; }
    pgbin pg_ctl -D "$DATA" -m immediate stop </dev/null >>"$LOG.pg_ctl" 2>&1 || true; rm -rf "$DATA"; echo "S5_FIXTURE_DESTROY_OK $DATA" ;;
  *) echo "unknown cmd $cmd" >&2; exit 2 ;;
esac
