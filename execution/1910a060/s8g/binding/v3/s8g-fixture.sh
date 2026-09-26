#!/usr/bin/env bash
# S8-G disposable PostgreSQL 17.6 cluster helper (lane s8-g only, EXEC-1910A060), derived by substitution from the
# accepted S8-B fixture execution/ce3748cb/s8b/binding/s8b-fixture.sh (unchanged there). LOCK-FREE BY DESIGN: it
# takes no flock itself and must be invoked only by the S8-G proof binding
# execution/1910a060/s8g/binding/v1/s8g-pg-proof.sh, the single canonical lock holder. Standalone use is refused
# unless S8G_RUNNER_PID names a live s8g-pg-proof.sh process.
#   * cluster_name = 's8g-disposable-pg17' (pinned marker required by start, bootstrap and destroy; identical to
#     test/utils/g2-s8g-db.ts G2_S8G_CLUSTER_MARKER)
#   * FRESH INIT ONLY: init refuses if the data directory exists (no marking/adopting unknown clusters)
#   * listen 127.0.0.1 only, port 55644 (operator-chosen, review C1: 55643 is the retained S8-F lane and is refused by g2-s8g-db.ts; SOURCE_READY-FINAL and PINS.txt pin 55644), superuser s8g_super / s8g_local_synthetic
#     (synthetic value; scram, S5 shape)
#   * FRESH NAMESPACE (RUNTIME_SETUP_RECEIPT §Donor-copy 6-7): binaries from the SHA-pinned
#     runtime/pg17/dist; data and socket directories under runtime/clusters/s8-g and
#     runtime/run/s8-g — never pg17/dist as a data root, never the historical /home/user/pg17 paths.
# `destroy` never discards a stop failure (S5-R3-A-03 revision 2 inherited): a running marked cluster is stopped
# with a bounded fast stop; a failed stop, a surviving postmaster or any process still referencing the data
# directory REFUSES removal (rc 4); a failed or incomplete removal is propagated (rc 5) and DESTROY_OK is printed
# only after the directory is verified absent. `stop` is bounded by S8G_STOP_TIMEOUT (runner-supplied; default 45 s).
# Usage (via runner): s8g-fixture.sh init|start|stop|status|destroy
set -euo pipefail
# ---- lane constants
RUNTIME_ROOT=/home/user/workspace/execution/1910a060/runtime
# ---- end lane constants
PGHOME=$RUNTIME_ROOT/pg17/dist
PORT=55644; SUPER=s8g_super; PASS=s8g_local_synthetic; MARKER=s8g-disposable-pg17
LANE=$RUNTIME_ROOT/clusters/s8-g
DATA=$LANE/pg-data; LOG=$LANE/pg.log; SOCK=$RUNTIME_ROOT/run/s8-g
STOP_TIMEOUT="${S8G_STOP_TIMEOUT:-45}"
cmd=${1:?init|start|stop|status|destroy}
[ -n "${S8G_RUNNER_PID:-}" ] && [ -d "/proc/$S8G_RUNNER_PID" ] && grep -q s8g-pg-proof.sh "/proc/$S8G_RUNNER_PID/cmdline" \
  || { echo "s8g-fixture.sh must be invoked by s8g-pg-proof.sh (single lock holder); refusing standalone $cmd" >&2; exit 2; }
[ -x "$PGHOME/bin/pg_ctl" ] || { echo "PG 17 distribution missing at $PGHOME" >&2; exit 2; }
case "$DATA" in "$PGHOME"/*) echo "REFUSED: data directory inside pg17/dist" >&2; exit 2;; /home/user/pg17/*) echo "REFUSED: historical pg17 path" >&2; exit 2;; esac
# Children never see the runner's lock fd; the postmaster gets /dev/null stdin and the server log only.
pgbin(){ local b=$1; shift; LD_LIBRARY_PATH="$PGHOME/lib" "$PGHOME/bin/$b" "$@" 9>&-; }
mkdir -p "$SOCK" "$LANE"
postmaster_alive() { [ -f "$DATA/postmaster.pid" ] && kill -0 "$(head -1 "$DATA/postmaster.pid")" 2>/dev/null; }
ppid_of() { local s; s="$(cat "/proc/$1/stat" 2>/dev/null)" || { echo x; return; }; s="${s##*) }"; set -- $s; echo "${2:-x}"; }
data_dir_users() { # prints "pid:cmdline" for every OTHER process referencing $DATA on its command line
  local p pid me=$BASHPID; for p in /proc/[0-9]*; do pid=${p#/proc/}; [ "$pid" = "$me" ] || [ "$pid" = "$$" ] && continue; [ "$pid" = "${S8G_RUNNER_PID:-x}" ] && continue
    [ "$(ppid_of "$pid")" = "$me" ] && continue
    if tr '\0' ' ' < "$p/cmdline" 2>/dev/null | grep -qF -- "$DATA"; then echo -n "$pid:$(tr '\0' ' ' < "$p/cmdline" 2>/dev/null | cut -c1-80 | tr -d '\n') "; fi
  done
}
case "$cmd" in
  init)
    [ -e "$DATA" ] && { echo "REFUSED: $DATA already exists; fresh init only (no adoption or marking of existing clusters)" >&2; exit 3; }
    pwfile=$(mktemp); echo "$PASS" >"$pwfile"
    pgbin initdb -D "$DATA" -U "$SUPER" -A scram-sha-256 --pwfile="$pwfile" -E UTF8 --locale=C.UTF-8 >"$DATA.initdb.log" 2>&1 </dev/null
    rm -f "$pwfile"
    cat >>"$DATA/postgresql.conf" <<CONF
# --- S8-G disposable fixture (2 vCPU / 8 GB sandbox) ---
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
    echo "S8G_FIXTURE_INIT_OK data=$DATA port=$PORT superuser=$SUPER cluster_name=$MARKER socket=$SOCK pg_version=$(cat "$DATA/PG_VERSION")" ;;
  start)
    grep -q "^cluster_name = '$MARKER'" "$DATA/postgresql.conf" || { echo "REFUSED: $DATA lacks the S8-G marker; not starting a foreign cluster" >&2; exit 3; }
    if pgbin pg_ctl -D "$DATA" status >/dev/null 2>&1; then echo "already running"; else
      pgbin pg_ctl -D "$DATA" -l "$LOG" -w -t 60 start </dev/null >>"$LOG.pg_ctl" 2>&1; fi
    echo "S8G_FIXTURE_START_OK pid=$(head -1 "$DATA/postmaster.pid")" ;;
  stop)
    rc=0; pgbin pg_ctl -D "$DATA" -m fast -w -t "$STOP_TIMEOUT" stop </dev/null >>"$LOG.pg_ctl" 2>&1 || rc=$?
    if postmaster_alive; then echo "S8G_FIXTURE_STOP_FAILED pg_ctl_rc=$rc survivor_pid=$(head -1 "$DATA/postmaster.pid")" >&2; exit 4; fi
    [ "$rc" = 0 ] || { echo "S8G_FIXTURE_STOP_FAILED pg_ctl_rc=$rc (no postmaster.pid survivor observed)" >&2; exit "$rc"; }
    echo "S8G_FIXTURE_STOP_OK" ;;
  status)  pgbin pg_ctl -D "$DATA" status || true ;;
  destroy)
    grep -q "^cluster_name = '$MARKER'" "$DATA/postgresql.conf" 2>/dev/null || { echo "REFUSED: $DATA is not the marked S8-G cluster; not destroying" >&2; exit 3; }
    if postmaster_alive; then
      rc=0; pgbin pg_ctl -D "$DATA" -m fast -w -t "$STOP_TIMEOUT" stop </dev/null >>"$LOG.pg_ctl" 2>&1 || rc=$?
      if postmaster_alive; then echo "DESTROY_REFUSED: stop rc=$rc and postmaster pid $(head -1 "$DATA/postmaster.pid") still alive; not removing $DATA" >&2; exit 4; fi
      [ "$rc" = 0 ] || { echo "DESTROY_REFUSED: pg_ctl stop rc=$rc; not removing $DATA" >&2; exit 4; }
      echo "S8G_FIXTURE_DESTROY_STOPPED_FIRST"
    else
      echo "S8G_FIXTURE_DESTROY_ALREADY_STOPPED"
    fi
    users="$(data_dir_users)"
    [ -z "$users" ] || { echo "DESTROY_REFUSED: processes still reference $DATA: $users" >&2; exit 4; }
    rm -rf -- "$DATA" || { echo "DESTROY_FAILED: rm rc=$? for $DATA" >&2; exit 5; }
    [ ! -e "$DATA" ] || { echo "DESTROY_FAILED: $DATA still present after removal" >&2; exit 5; }
    echo "S8G_FIXTURE_DESTROY_OK $DATA" ;;
  *) echo "unknown cmd $cmd" >&2; exit 2 ;;
esac
