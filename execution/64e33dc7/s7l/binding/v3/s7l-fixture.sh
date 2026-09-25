#!/usr/bin/env bash
# S7-L disposable PostgreSQL 17.6 cluster helper (lane s7l only, EXEC-64E33DC7). Derived as a code pattern from the
# S8-C/S8-B fixture shape; no result of any earlier lane is claimed. LOCK-FREE BY DESIGN: it takes no flock itself and
# must be invoked only by the S7-L proof driver execution/64e33dc7/s7l/binding/s7l-pg-proof.sh, the single canonical
# lock holder. Standalone use is refused unless S7L_RUNNER_PID names a live s7l-pg-proof.sh process.
#   * cluster_name = 's7l-disposable-pg17' (pinned marker required by start, bootstrap and destroy; identical to
#     test/utils/g2-s7l-db.ts G2_S7L_CLUSTER_MARKER and test/utils/g2-s7l-bootstrap.sh CLUSTER_MARKER)
#   * FRESH INIT ONLY: init refuses if the data directory exists (no marking/adopting unknown clusters)
#   * listen 127.0.0.1 only, port 55641 (execution/64e33dc7 SCOPE / RUNTIME_SETUP_RECEIPT §7), superuser s7l_super
#     with the synthetic fixture password s7l_local_synthetic (scram; disposable local identity only)
#   * FRESH NAMESPACE (RUNTIME_SETUP_RECEIPT §6-7): binaries from the SHA-pinned recovery-reset/pg17/dist; data and
#     socket directories under recovery-reset/proof-v3/clusters/s7l and recovery-reset/proof-v3/run/s7l (fresh v3 lane; the retained failed v2 lane clusters/s7l is never reused) — never pg17/dist as a data root,
#     never the historical /home/user/pg17 paths. The data directory matches the guard regex the spec/harness enforce:
#     /execution/64e33dc7/recovery-reset/.*/s7l/pg-data$
# `stop` is bounded by S7L_STOP_TIMEOUT (runner-supplied; default 45 s). `destroy` never discards a stop failure: a
# running marked cluster is stopped with a bounded fast stop; a failed stop, a surviving postmaster or any process still
# referencing the data directory REFUSES removal (rc 4); a failed or incomplete removal is propagated (rc 5) and
# DESTROY_OK is printed only after the directory is verified absent. destroy is NOT invoked by the proof driver
# (data dir retained after the run; destruction is a separate marker-gated decision).
# Usage (via runner): s7l-fixture.sh init|start|stop|status|destroy
set -euo pipefail
# ---- lane constants
RUNTIME_ROOT=/home/user/workspace/execution/64e33dc7/recovery-reset
# ---- end lane constants
PGHOME=$RUNTIME_ROOT/pg17/dist
PORT=55641; SUPER=s7l_super; PASS=s7l_local_synthetic; MARKER=s7l-disposable-pg17
LANE=$RUNTIME_ROOT/proof-v3/clusters/s7l
DATA=$LANE/pg-data; LOG=$LANE/pg.log; SOCK=$RUNTIME_ROOT/proof-v3/run/s7l
STOP_TIMEOUT="${S7L_STOP_TIMEOUT:-45}"
cmd=${1:?init|start|stop|status|destroy}
[ -n "${S7L_RUNNER_PID:-}" ] && [ -d "/proc/$S7L_RUNNER_PID" ] && grep -q s7l-pg-proof.sh "/proc/$S7L_RUNNER_PID/cmdline" \
  || { echo "s7l-fixture.sh must be invoked by s7l-pg-proof.sh (single lock holder); refusing standalone $cmd" >&2; exit 2; }
[ -x "$PGHOME/bin/pg_ctl" ] || { echo "PG 17 distribution missing at $PGHOME" >&2; exit 2; }
case "$DATA" in "$PGHOME"/*) echo "REFUSED: data directory inside pg17/dist" >&2; exit 2;; /home/user/pg17/*) echo "REFUSED: historical pg17 path" >&2; exit 2;; esac
[[ "$DATA" =~ /execution/64e33dc7/recovery-reset/.*/s7l/pg-data$ ]] || { echo "REFUSED: $DATA does not match the S7-L guard directory pattern" >&2; exit 2; }
# Children never see the runner's lock fd; the postmaster gets /dev/null stdin and the server log only.
pgbin(){ local b=$1; shift; LD_LIBRARY_PATH="$PGHOME/lib" "$PGHOME/bin/$b" "$@" 9>&-; }
mkdir -p "$SOCK" "$LANE"
postmaster_alive() { [ -f "$DATA/postmaster.pid" ] && kill -0 "$(head -1 "$DATA/postmaster.pid")" 2>/dev/null; }
ppid_of() { local s; s="$(cat "/proc/$1/stat" 2>/dev/null)" || { echo x; return; }; s="${s##*) }"; set -- $s; echo "${2:-x}"; }
data_dir_users() { # prints "pid:cmdline" for every OTHER process referencing $DATA on its command line
  local p pid me=$BASHPID; for p in /proc/[0-9]*; do pid=${p#/proc/}; [ "$pid" = "$me" ] || [ "$pid" = "$$" ] && continue; [ "$pid" = "${S7L_RUNNER_PID:-x}" ] && continue
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
# --- S7-L disposable fixture (2 vCPU / 8 GB sandbox) ---
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
    echo "S7L_FIXTURE_INIT_OK data=$DATA port=$PORT superuser=$SUPER cluster_name=$MARKER socket=$SOCK pg_version=$(cat "$DATA/PG_VERSION")" ;;
  start)
    grep -q "^cluster_name = '$MARKER'" "$DATA/postgresql.conf" || { echo "REFUSED: $DATA lacks the S7-L marker; not starting a foreign cluster" >&2; exit 3; }
    if pgbin pg_ctl -D "$DATA" status >/dev/null 2>&1; then echo "already running"; else
      pgbin pg_ctl -D "$DATA" -l "$LOG" -w -t 60 start </dev/null >>"$LOG.pg_ctl" 2>&1; fi
    echo "S7L_FIXTURE_START_OK pid=$(head -1 "$DATA/postmaster.pid")" ;;
  stop)
    rc=0; pgbin pg_ctl -D "$DATA" -m fast -w -t "$STOP_TIMEOUT" stop </dev/null >>"$LOG.pg_ctl" 2>&1 || rc=$?
    if postmaster_alive; then echo "S7L_FIXTURE_STOP_FAILED pg_ctl_rc=$rc survivor_pid=$(head -1 "$DATA/postmaster.pid")" >&2; exit 4; fi
    [ "$rc" = 0 ] || { echo "S7L_FIXTURE_STOP_FAILED pg_ctl_rc=$rc (no postmaster.pid survivor observed)" >&2; exit "$rc"; }
    echo "S7L_FIXTURE_STOP_OK" ;;
  status)  pgbin pg_ctl -D "$DATA" status || true ;;
  destroy)
    grep -q "^cluster_name = '$MARKER'" "$DATA/postgresql.conf" 2>/dev/null || { echo "REFUSED: $DATA is not the marked S7-L cluster; not destroying" >&2; exit 3; }
    if postmaster_alive; then
      rc=0; pgbin pg_ctl -D "$DATA" -m fast -w -t "$STOP_TIMEOUT" stop </dev/null >>"$LOG.pg_ctl" 2>&1 || rc=$?
      if postmaster_alive; then echo "DESTROY_REFUSED: stop rc=$rc and postmaster pid $(head -1 "$DATA/postmaster.pid") still alive; not removing $DATA" >&2; exit 4; fi
      [ "$rc" = 0 ] || { echo "DESTROY_REFUSED: pg_ctl stop rc=$rc; not removing $DATA" >&2; exit 4; }
      echo "S7L_FIXTURE_DESTROY_STOPPED_FIRST"
    else
      echo "S7L_FIXTURE_DESTROY_ALREADY_STOPPED"
    fi
    users="$(data_dir_users)"
    [ -z "$users" ] || { echo "DESTROY_REFUSED: processes still reference $DATA: $users" >&2; exit 4; }
    rm -rf -- "$DATA" || { echo "DESTROY_FAILED: rm rc=$? for $DATA" >&2; exit 5; }
    [ ! -e "$DATA" ] || { echo "DESTROY_FAILED: $DATA still present after removal" >&2; exit 5; }
    echo "S7L_FIXTURE_DESTROY_OK $DATA" ;;
  *) echo "unknown cmd $cmd" >&2; exit 2 ;;
esac
