#!/usr/bin/env bash
# Copied from the S1 R3 evidence packet (infra/s1-fixture.sh). S2 change: data dir clusters/s2comp (session-owned,
# still under the guard's fixed root /home/user/pg17/clusters/); cluster_name marker unchanged because the frozen guard
# requires exactly s1-disposable-pg17. Original header follows.
# S1 R3 disposable PostgreSQL 17.6 fixture. Differences from the R2 lane-pg.sh:
#   * cluster_name = 's1-disposable-pg17' (the guard's fixed marker)
#   * data directory /home/user/pg17/clusters/s1 (canonical, under the guard's fixed root)
#   * NO extra database is created (R2 created s1_tgp, which the guard now refuses as foreign)
#   * listen 127.0.0.1 only, port 54321, superuser s1_super / s1_local_synthetic (synthetic)
# Usage: s1-fixture.sh init|start|stop|status|destroy|url   (init/destroy take the lock nonblocking; start/stop never hold it)
set -euo pipefail
PG17_HOME=/home/user/pg17; PGHOME=$PG17_HOME/dist
pgbin(){ local b=$1; shift; LD_LIBRARY_PATH="$PGHOME/lib" "$PGHOME/bin/$b" "$@" 9>&-; }   # never leak the lock fd to children
PORT=54321; SUPER=s1_super; PASS=s1_local_synthetic
DATA=$PG17_HOME/clusters/s2comp; LOG=$PG17_HOME/clusters/s2comp.log; SOCK=$PG17_HOME/run
cmd=${1:?init|start|stop|status|destroy|url}
LOCK=/home/user/workspace/execution/test-validation.lock
# Only init/destroy take the lock (nonblocking). start/stop are cheap and MUST NOT hold it:
# a daemonized postgres inherits open fds, so a lock fd held across pg_ctl start would be
# held by the server for its whole lifetime (observed 2026-09-20 23:11; fixed here).
case "$cmd" in init|destroy) exec 9>"$LOCK"; flock -n 9 || { echo "validation lock busy; not waiting"; exit 75; } ;; esac
mkdir -p "$SOCK" "$PG17_HOME/clusters"
case "$cmd" in
  init)
    [ -d "$DATA" ] && { echo "exists: $DATA (destroy first for a fresh cluster)"; exit 70; }
    pwfile=$(mktemp); echo "$PASS" >"$pwfile"
    pgbin initdb -D "$DATA" -U "$SUPER" -A scram-sha-256 --pwfile="$pwfile" -E UTF8 --locale=C.UTF-8 >/dev/null
    rm -f "$pwfile"
    cat >>"$DATA/postgresql.conf" <<CONF
# --- S1 R3 disposable fixture (2 vCPU / 8 GB sandbox) ---
cluster_name = 's1-disposable-pg17'
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
    echo "initialised $DATA (port $PORT, superuser $SUPER, cluster_name s1-disposable-pg17, realpath=$(realpath "$DATA"))" ;;
  start)
    if pgbin pg_ctl -D "$DATA" status >/dev/null 2>&1; then echo "already running"; else pgbin pg_ctl -D "$DATA" -l "$LOG" -w -t 60 start >/dev/null; fi
    PGPASSWORD=$PASS PGCONNECT_TIMEOUT=5 psql "host=127.0.0.1 port=$PORT user=$SUPER dbname=postgres" -X -qAt -c \
      "select version()||' | cluster='||current_setting('cluster_name')||' | datadir='||current_setting('data_directory')||' | addr='||host(inet_server_addr())||':'||inet_server_port()||' | dbs='||(select string_agg(datname,',' order by datname) from pg_database)" ;;
  stop)    pgbin pg_ctl -D "$DATA" -m fast -w stop >/dev/null && echo "stopped" ;;
  status)  pgbin pg_ctl -D "$DATA" status || true ;;
  destroy) pgbin pg_ctl -D "$DATA" -m immediate stop >/dev/null 2>&1 || true; rm -rf "$DATA"; echo "destroyed $DATA" ;;
  url)     echo "postgresql://$SUPER:$PASS@127.0.0.1:$PORT/postgres" ;;
  *) echo "unknown cmd $cmd" >&2; exit 2 ;;
esac
