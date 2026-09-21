#!/usr/bin/env bash
# S5 R3 disposable PostgreSQL 17.6 fixture (lane s5 only), modelled on S1 R3's s1-fixture.sh.
# Differences from the R2 lane-pg.sh s5 lane:
#   * cluster_name = 's5-disposable-pg17' — the pinned marker that run-proof.sh preflight and
#     test/utils/g2-pg17-bootstrap.sh require BEFORE any DROP/CREATE. An R2 lane-pg.sh cluster has a
#     blank cluster_name and is therefore REFUSED (rc 3) until it is re-initialised here (or the
#     operator sets cluster_name in its postgresql.conf and restarts it — `mark` below does exactly
#     that for an existing lane created by lane-pg.sh, without touching any data).
#   * no extra database (R2 created s5_tgp; preflight tolerates it, bootstrap never touches it).
#   * listen 127.0.0.1 only, port 54325, superuser s5_super / s5_local_synthetic (synthetic value),
#     data directory /home/user/pg17/clusters/s5 (the spec asserts .../pg17/clusters/s5).
# Requires S1's shared PG 17.6 zonky distribution at /home/user/pg17/dist (installed by S1's
# setup-20-pg17.sh under the canonical lock); this script installs nothing.
# Usage: s5-fixture.sh init|mark|start|stop|status|destroy|url
#   init/mark/destroy take the canonical validation lock NONBLOCKING (rc 75 if busy);
#   start/stop never hold it (a daemonised postgres would inherit and keep the lock fd).
set -euo pipefail
PG17_HOME=/home/user/pg17; PGHOME=$PG17_HOME/dist
pgbin(){ local b=$1; shift; LD_LIBRARY_PATH="$PGHOME/lib" "$PGHOME/bin/$b" "$@" 9>&-; }
PORT=54325; SUPER=s5_super; PASS=s5_local_synthetic; MARKER=s5-disposable-pg17
DATA=$PG17_HOME/clusters/s5; LOG=$PG17_HOME/clusters/s5.log; SOCK=$PG17_HOME/run
cmd=${1:?init|mark|start|stop|status|destroy|url}
LOCK=/home/user/workspace/execution/test-validation.lock
[ -x "$PGHOME/bin/pg_ctl" ] || { echo "PG 17 distribution missing at $PGHOME (S1 shared infra not installed)"; exit 2; }
case "$cmd" in init|mark|destroy) exec 9>"$LOCK"; flock -n 9 || { echo "validation lock busy; not waiting"; exit 75; }
  echo "$(date -u +%FT%TZ) HOLDER=s5-r3 PURPOSE=s5-fixture-$cmd pid=$$" >> /home/user/workspace/execution/test-validation.lock.log ;; esac
mkdir -p "$SOCK" "$PG17_HOME/clusters"
case "$cmd" in
  init)
    [ -d "$DATA" ] && { echo "exists: $DATA (destroy first, or use mark)"; exit 70; }
    pwfile=$(mktemp); echo "$PASS" >"$pwfile"
    pgbin initdb -D "$DATA" -U "$SUPER" -A scram-sha-256 --pwfile="$pwfile" -E UTF8 --locale=C.UTF-8 >/dev/null
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
    echo "initialised $DATA (port $PORT, superuser $SUPER, cluster_name $MARKER, realpath=$(realpath "$DATA"))" ;;
  mark)
    # Stamp an existing (R2 lane-pg.sh) s5 cluster with the marker; config-only, requires restart.
    [ -f "$DATA/postgresql.conf" ] || { echo "no cluster at $DATA"; exit 70; }
    grep -q "^listen_addresses = '127.0.0.1'" "$DATA/postgresql.conf" || { echo "cluster is not loopback-only; refusing to mark"; exit 3; }
    grep -q "^port = $PORT" "$DATA/postgresql.conf" || { echo "cluster is not on port $PORT; refusing to mark"; exit 3; }
    if grep -q "^cluster_name = '$MARKER'" "$DATA/postgresql.conf"; then echo "already marked"; else
      grep -q "^cluster_name = " "$DATA/postgresql.conf" && { echo "cluster_name already set to something else; refusing"; exit 3; }
      printf "cluster_name = '%s'\n" "$MARKER" >> "$DATA/postgresql.conf"; echo "marked $DATA with cluster_name $MARKER (restart required: stop; start)"; fi ;;
  start)
    if pgbin pg_ctl -D "$DATA" status >/dev/null 2>&1; then echo "already running"; else pgbin pg_ctl -D "$DATA" -l "$LOG" -w -t 60 start >/dev/null; fi
    PGPASSWORD=$PASS PGCONNECT_TIMEOUT=5 psql "host=127.0.0.1 port=$PORT user=$SUPER dbname=postgres" -X -qAt -c \
      "select version()||' | cluster='||current_setting('cluster_name')||' | datadir='||current_setting('data_directory')||' | addr='||host(inet_server_addr())||':'||inet_server_port()||' | dbs='||(select string_agg(datname,',' order by datname) from pg_database)" ;;
  stop)    pgbin pg_ctl -D "$DATA" -m fast -w stop >/dev/null && echo "stopped" ;;
  status)  pgbin pg_ctl -D "$DATA" status || true ;;
  destroy) pgbin pg_ctl -D "$DATA" -m immediate stop >/dev/null 2>&1 || true; rm -rf "$DATA"; echo "destroyed $DATA" ;;
  url)     echo "postgresql://$SUPER@127.0.0.1:$PORT/postgres  (password via G2_PG17_PASSWORD; synthetic value documented in this script)" ;;
  *) echo "unknown cmd $cmd" >&2; exit 2 ;;
esac
