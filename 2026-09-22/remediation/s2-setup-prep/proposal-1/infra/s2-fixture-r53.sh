#!/usr/bin/env bash
# S2-RUNNER-53 disposable PostgreSQL 17.6 fixture — REIMPLEMENTATION (2026-09-22, S2-SETUP-FIXTURE-PREP) derived from the latest
# preserved fixture s2-fixture.sh sha256 08987e4cd566e0ee7ee8ef76ac4c39bc327ffd92fb85dfaf52fac8058d8df44c (setup-and-runner-readiness/infra).
# The namespaced fixture 6062f4ce… named by frozen request 03 is NOT preserved; this file does not claim, contain or imitate its bytes.
#
# Retained from 08987e4c byte-for-byte in intent: fd-9 inherited-lock guard (verified via /proc, not env) for init/destroy/lockcheck;
# fixed guard marker cluster_name='s1-disposable-pg17'; data dir under the guard's fixed root /home/user/pg17/clusters/; loopback only;
# synthetic superuser s1_super/s1_local_synthetic; start/stop never take the lock; fd 9 closed for every pg binary and psql.
# Changed (each is a named safety correction or lane pin; see REPORT.md "fixture delta"):
#   D1 namespace pinned to THIS lane: DATA=/home/user/pg17/clusters/s2comp-r53 (fresh, unique; historical s1/s2comp/s2comp-r2/s2comp-r3/S5 dirs never touched)
#   D2 port pinned to 54353 (lane-unique; historical S2 lanes used 54321, S5 54325) — no env override of DATA/PORT/marker/creds exists
#   D3 init: refuses (70) if DATA exists, if anything listens on the port, or if any postgres already serves this DATA — never adopts, never deletes
#   D4 start: refuses (70) instead of adopting an already-running server ("already running" adoption in 08987e4c was an unsafe inherited behaviour)
#   D5 stop: pg_ctl -m fast -w -t 15 (bounded, fits the runner's 20 s stop budget); nonzero exit is returned, never masked
#   D6 destroy: REFUSES unless the server is verifiably stopped (pg_ctl status = not running) — 08987e4c did `stop || true; rm -rf` (destructive removal after a failed stop). Additionally refuses unless S2_FIXTURE_DESTROY_CONFIRM equals the literal data dir. The runner never calls destroy.
#   D7 directory creation moved inside init/after the refusals (08987e4c created $SOCK and the clusters root on every subcommand, including failing ones)
# Usage: s2-fixture-r53.sh init|start|stop|status|destroy|url|lockcheck
set -euo pipefail
PG17_HOME=/home/user/pg17; PGHOME=$PG17_HOME/dist
pgbin(){ local b=$1; shift; LD_LIBRARY_PATH="$PGHOME/lib" "$PGHOME/bin/$b" "$@" 9>&-; }   # never leak the lock fd to children
PORT=54353; SUPER=s1_super; PASS=s1_local_synthetic
NS=s2comp-r53
DATA=$PG17_HOME/clusters/$NS; LOG=$PG17_HOME/clusters/$NS.log; SOCK=$PG17_HOME/run
MARKER=s1-disposable-pg17   # the frozen S1 guard requires exactly this marker
cmd=${1:?init|start|stop|status|destroy|url|lockcheck}
LOCK=/home/user/workspace/execution/test-validation.lock
# Only init/destroy/lockcheck take the lock (nonblocking). start/stop are cheap and MUST NOT hold it: a daemonized postgres inherits
# open fds, so a lock fd held across pg_ctl start would be held by the server for its whole lifetime (observed 2026-09-20 23:11).
# If fd 9 is ALREADY open on the lock file (the runner's hold, verified via /proc), flock -n on the inherited open file description
# succeeds (same lease) and init/destroy run under the caller's hold; otherwise we open+lock ourselves. `lockcheck` exercises only
# this logic (S2_FIXTURE_LOCK override honoured for lockcheck ALONE, for offline tests on a temp lock).
[ "$cmd" = lockcheck ] && LOCK=${S2_FIXTURE_LOCK:-$LOCK}
case "$cmd" in init|destroy|lockcheck)
  if [ "$(readlink /proc/$$/fd/9 2>/dev/null || true)" = "$LOCK" ]; then LOCK_MODE="inherited fd9 from caller pid=$PPID"
  else exec 9>"$LOCK"; LOCK_MODE="acquired here"; fi
  flock -n 9 || { echo "validation lock busy ($LOCK, mode=$LOCK_MODE); not waiting"; exit 75; }
  echo "lock: $LOCK $LOCK_MODE"
  [ "$cmd" = lockcheck ] && exit 0 ;;
esac
port_listener(){ ss -ltnH 2>/dev/null | grep -E ":${PORT}\b" || true; }
serving_this_data(){ pgrep -af "^$PGHOME/bin/postgres .*-D $DATA( |$)" 2>/dev/null || true; }
case "$cmd" in
  init)
    [ -d "$DATA" ] && { echo "REFUSED: exists: $DATA (not adopting, not deleting; a fresh namespace is required)"; exit 70; }
    [ -z "$(port_listener)" ] || { echo "REFUSED: something already listens on 127.0.0.1:$PORT: $(port_listener | head -1)"; exit 70; }
    [ -z "$(serving_this_data)" ] || { echo "REFUSED: a postgres already serves $DATA: $(serving_this_data | head -1)"; exit 70; }
    [ -x "$PGHOME/bin/initdb" ] || { echo "REFUSED: $PGHOME/bin/initdb missing (setup-20 not done)"; exit 70; }
    mkdir -p "$SOCK" "$PG17_HOME/clusters"
    pwfile=$(mktemp); echo "$PASS" >"$pwfile"
    pgbin initdb -D "$DATA" -U "$SUPER" -A scram-sha-256 --pwfile="$pwfile" -E UTF8 --locale=C.UTF-8 >/dev/null
    rm -f "$pwfile"
    cat >>"$DATA/postgresql.conf" <<CONF
# --- S2-RUNNER-53 disposable fixture (2 vCPU / 8 GB sandbox) ---
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
  start)
    [ -d "$DATA" ] || { echo "REFUSED: $DATA missing (init first)"; exit 70; }
    if pgbin pg_ctl -D "$DATA" status >/dev/null 2>&1; then echo "REFUSED: a server is already running on $DATA (not adopting)"; exit 70; fi
    [ -z "$(port_listener)" ] || { echo "REFUSED: something already listens on 127.0.0.1:$PORT: $(port_listener | head -1)"; exit 70; }
    pgbin pg_ctl -D "$DATA" -l "$LOG" -w -t 60 start >/dev/null
    PGPASSWORD=$PASS PGCONNECT_TIMEOUT=5 psql "host=127.0.0.1 port=$PORT user=$SUPER dbname=postgres" -X -qAt 9>&- -c \
      "select version()||' | cluster='||current_setting('cluster_name')||' | datadir='||current_setting('data_directory')||' | addr='||host(inet_server_addr())||':'||inet_server_port()||' | dbs='||(select string_agg(datname,',' order by datname) from pg_database)" ;;
  stop)    pgbin pg_ctl -D "$DATA" -m fast -w -t 15 stop >/dev/null && echo "stopped" ;;
  status)  pgbin pg_ctl -D "$DATA" status || true ;;
  destroy)
    # Never remove a data directory whose server may still be running: a failed/unknown stop forbids destructive removal.
    [ -d "$DATA" ] || { echo "nothing to destroy: $DATA absent"; exit 0; }
    if pgbin pg_ctl -D "$DATA" status >/dev/null 2>&1; then echo "REFUSED: server still running on $DATA; stop it (and verify) before destroy"; exit 70; fi
    [ -z "$(serving_this_data)" ] || { echo "REFUSED: a postgres process still references $DATA: $(serving_this_data | head -1)"; exit 70; }
    [ "${S2_FIXTURE_DESTROY_CONFIRM-}" = "$DATA" ] || { echo "REFUSED: S2_FIXTURE_DESTROY_CONFIRM must equal the literal '$DATA'"; exit 70; }
    rm -rf "$DATA"; echo "destroyed $DATA" ;;
  url)     echo "postgresql://$SUPER:$PASS@127.0.0.1:$PORT/postgres" ;;
  *) echo "unknown cmd $cmd" >&2; exit 2 ;;
esac
