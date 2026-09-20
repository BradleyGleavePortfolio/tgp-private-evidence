#!/usr/bin/env bash
# Isolated PostgreSQL 17.6 clusters for TGP execution lanes (synthetic data only).
# Binaries: zonky embedded-postgres-binaries-linux-amd64 17.6.0 (official PG 17.6 build),
# sha1-verified against Maven Central; client tools: Ubuntu postgresql-client-18.
#
# Usage: lane-pg.sh <lane> <init|start|stop|status|url|destroy>
#   lane: s1 (port 54321, superuser s1_super, db s1_tgp)
#         s5 (port 54325, superuser s5_super, db s5_tgp)
set -euo pipefail
PG17_HOME=${PG17_HOME:-$HOME/pg17}
PGHOME=$PG17_HOME/dist
# server binaries need the bundled libs; system psql (v18) must NOT see them.
pgbin() { local b="$1"; shift; LD_LIBRARY_PATH="$PGHOME/lib" "$PGHOME/bin/$b" "$@"; }
initdb() { pgbin initdb "$@"; }
pg_ctl() { pgbin pg_ctl "$@"; }

lane="${1:?lane}"; cmd="${2:?cmd}"
case "$lane" in
  s1) PORT=54321; SUPER=s1_super; DB=s1_tgp ;;
  s5) PORT=54325; SUPER=s5_super; DB=s5_tgp ;;
  *) echo "unknown lane $lane" >&2; exit 2 ;;
esac
DATA=$PG17_HOME/clusters/$lane
LOG=$PG17_HOME/clusters/$lane.log
SOCK=$PG17_HOME/run
PASS="${lane}_local_synthetic"
mkdir -p "$SOCK" $PG17_HOME/clusters

case "$cmd" in
  init)
    if [ -d "$DATA" ]; then echo "exists: $DATA"; exit 0; fi
    pwfile=$(mktemp); echo "$PASS" > "$pwfile"
    initdb -D "$DATA" -U "$SUPER" -A scram-sha-256 --pwfile="$pwfile" -E UTF8 --locale=C.UTF-8 >/dev/null
    rm -f "$pwfile"
    cat >> "$DATA/postgresql.conf" <<EOF
# --- lane $lane overrides (2 vCPU / 8 GB sandbox) ---
port = $PORT
listen_addresses = '127.0.0.1'
unix_socket_directories = '$SOCK'
shared_buffers = 128MB
work_mem = 8MB
maintenance_work_mem = 64MB
max_connections = 40
wal_level = replica
max_wal_senders = 3
fsync = off
synchronous_commit = off
full_page_writes = off
log_min_messages = warning
log_lock_waits = on
deadlock_timeout = 500ms
shared_preload_libraries = 'pg_stat_statements'
EOF
    echo "initialised $DATA (port $PORT, superuser $SUPER)"
    ;;
  start)
    if pg_ctl -D "$DATA" status >/dev/null 2>&1; then echo "already running lane $lane"; else
      pg_ctl -D "$DATA" -l "$LOG" -w -t 60 start >/dev/null; fi
    if [ "$(PGPASSWORD="$PASS" psql "host=$SOCK port=$PORT user=$SUPER dbname=postgres" -qtAc "SELECT 1 FROM pg_database WHERE datname='$DB'")" != "1" ]; then
      PGPASSWORD="$PASS" psql "host=$SOCK port=$PORT user=$SUPER dbname=postgres" -qtAc "CREATE DATABASE $DB" >/dev/null; fi
    echo "started lane $lane on 127.0.0.1:$PORT (socket $SOCK)"
    ;;
  stop)   pg_ctl -D "$DATA" -m fast -w stop >/dev/null && echo "stopped lane $lane" ;;
  status) pg_ctl -D "$DATA" status || true ;;
  url)    echo "postgresql://$SUPER:$PASS@127.0.0.1:$PORT/$DB" ;;
  destroy) pg_ctl -D "$DATA" -m immediate stop >/dev/null 2>&1 || true; rm -rf "$DATA"; echo "destroyed lane $lane" ;;
  *) echo "unknown cmd $cmd" >&2; exit 2 ;;
esac
