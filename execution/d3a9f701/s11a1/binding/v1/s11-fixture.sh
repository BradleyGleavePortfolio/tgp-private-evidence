#!/usr/bin/env bash
# S11 disposable PostgreSQL 17.6 cluster helper (lane s11 only, EXEC-D3A9F701), derived by literal substitution from the
# S10-B fixture execution/d3a9f701/s10b/binding/v1/s10b-fixture.sh (sha256 7d9ee89b…20e8; itself the S9-C v2 / S9-B v3
# fixture with lane literals changed; diff in DELTA-from-s10b.diff). LOCK-FREE BY DESIGN: it takes no flock itself and must
# be invoked only by the S11-A1 proof binding execution/d3a9f701/s11a1/binding/v1/s11-pg-proof.sh, the single canonical
# lock holder. Standalone use is refused unless S11_RUNNER_PID names a live s11-pg-proof.sh process.
#   * cluster_name = 's11-disposable-pg17' (pinned marker required by start, bootstrap and destroy; identical to
#     test/utils/g2-s11-db.ts G2_S11_CLUSTER_MARKER and test/utils/g2-s11-bootstrap.sh CLUSTER_MARKER at c8ee9005)
#   * FRESH INIT ONLY: init refuses if the data directory exists (no marking/adopting unknown clusters)
#   * listen 127.0.0.1 only, port 55648 (S11 lane port, execution/d3a9f701; absent from the G2_S11 REFUSED_PORTS, which
#     list 55646 (S9-C), 55647 (S10-B) and every earlier lane; 55649 is the S10-C lane and is refused by the runner),
#     superuser s11_super / s11_local_synthetic (synthetic value; scram, S5 shape)
#   * 1910a060 runtime NAMESPACE (execution/1910a060/runtime/RUNTIME_SETUP_RECEIPT.md): binaries from the SHA-pinned
#     1910a060/runtime/pg17/dist; data and socket directories under 1910a060/runtime/clusters/s11 and
#     1910a060/runtime/run/s11 — never pg17/dist as a data root, never the historical /home/user/pg17 or
#     64e33dc7/recovery-reset paths, never the lanes clusters/s8-g, s9-b, s9-c, s10-b, s10-c. The RUNTIME_ROOT / PORT /
#     MARKER lines below are literals the runner cross-checks whole-line (grep -qx) against its own before init.
# `destroy` never discards a stop failure (S5-R3-A-03 revision 2 inherited): a running marked cluster is stopped
# with a bounded fast stop; a failed stop, a surviving postmaster or any process still referencing the data
# directory REFUSES removal (rc 4); a failed or incomplete removal is propagated (rc 5) and DESTROY_OK is printed
# only after the directory is verified absent. `stop` is bounded by S11_STOP_TIMEOUT (runner-supplied; default 45 s).
# Usage (via runner only): s11-fixture.sh init|start|stop|status|destroy
set -euo pipefail
# ---- lane constants
RUNTIME_ROOT=/home/user/workspace/execution/1910a060/runtime
# ---- end lane constants
PGHOME=$RUNTIME_ROOT/pg17/dist
PORT=55648; SUPER=s11_super; PASS=s11_local_synthetic; MARKER=s11-disposable-pg17
LANE=$RUNTIME_ROOT/clusters/s11
DATA=$LANE/pg-data; LOG=$LANE/pg.log; SOCK=$RUNTIME_ROOT/run/s11
STOP_TIMEOUT="${S11_STOP_TIMEOUT:-45}"
cmd=${1:?init|start|stop|status|destroy}
case "$PORT" in *__*) echo "REFUSED: lane PORT not filled by the parent (binding proposal stage)" >&2; exit 2;; esac
[ -n "${S11_RUNNER_PID:-}" ] && [ -d "/proc/$S11_RUNNER_PID" ] && grep -q s11-pg-proof.sh "/proc/$S11_RUNNER_PID/cmdline" \
  || { echo "s11-fixture.sh must be invoked by s11-pg-proof.sh (single lock holder); refusing standalone $cmd" >&2; exit 2; }
[ -x "$PGHOME/bin/pg_ctl" ] || { echo "PG 17 distribution missing at $PGHOME" >&2; exit 2; }
case "$DATA" in "$PGHOME"/*) echo "REFUSED: data directory inside pg17/dist" >&2; exit 2;; /home/user/pg17/*) echo "REFUSED: historical pg17 path" >&2; exit 2;; esac
# Children never see the runner's lock fd; the postmaster gets /dev/null stdin and the server log only.
pgbin(){ local b=$1; shift; LD_LIBRARY_PATH="$PGHOME/lib" "$PGHOME/bin/$b" "$@" 9>&-; }
mkdir -p "$SOCK" "$LANE"
postmaster_alive() { [ -f "$DATA/postmaster.pid" ] && kill -0 "$(head -1 "$DATA/postmaster.pid")" 2>/dev/null; }
ppid_of() { local s; s="$(cat "/proc/$1/stat" 2>/dev/null)" || { echo x; return; }; s="${s##*) }"; set -- $s; echo "${2:-x}"; }
data_dir_users() { # prints "pid:cmdline" for every OTHER process referencing $DATA on its command line
  local p pid me=$BASHPID; for p in /proc/[0-9]*; do pid=${p#/proc/}; [ "$pid" = "$me" ] || [ "$pid" = "$$" ] && continue; [ "$pid" = "${S11_RUNNER_PID:-x}" ] && continue
    [ "$(ppid_of "$pid")" = "$me" ] && continue
    local cl; cl=$(tr '\0' ' ' < "$p/cmdline" 2>/dev/null || true)   # captured, never `tr | grep -q` under pipefail (SIGPIPE false negative)
    if grep -qF -- "$DATA" <<<"$cl"; then echo -n "$pid:$(cut -c1-80 <<<"$cl" | tr -d '\n') "; fi
  done
}
case "$cmd" in
  init)
    { [ -e "$DATA" ] || [ -L "$DATA" ]; } && { echo "REFUSED: $DATA already exists (or is a symlink); fresh init only (no adoption or marking of existing clusters)" >&2; exit 3; }
    pwfile=$(mktemp); echo "$PASS" >"$pwfile"
    pgbin initdb -D "$DATA" -U "$SUPER" -A scram-sha-256 --pwfile="$pwfile" -E UTF8 --locale=C.UTF-8 >"$DATA.initdb.log" 2>&1 </dev/null
    rm -f "$pwfile"
    cat >>"$DATA/postgresql.conf" <<CONF
# --- S11 disposable fixture (2 vCPU / 8 GB sandbox) ---
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
    echo "S11_FIXTURE_INIT_OK data=$DATA port=$PORT superuser=$SUPER cluster_name=$MARKER socket=$SOCK pg_version=$(cat "$DATA/PG_VERSION")" ;;
  start)
    grep -q "^cluster_name = '$MARKER'" "$DATA/postgresql.conf" || { echo "REFUSED: $DATA lacks the S11 marker; not starting a foreign cluster" >&2; exit 3; }
    if pgbin pg_ctl -D "$DATA" status >/dev/null 2>&1; then echo "already running"; else
      pgbin pg_ctl -D "$DATA" -l "$LOG" -w -t 60 start </dev/null >>"$LOG.pg_ctl" 2>&1; fi
    echo "S11_FIXTURE_START_OK pid=$(head -1 "$DATA/postmaster.pid")" ;;
  stop)
    rc=0; pgbin pg_ctl -D "$DATA" -m fast -w -t "$STOP_TIMEOUT" stop </dev/null >>"$LOG.pg_ctl" 2>&1 || rc=$?
    if postmaster_alive; then echo "S11_FIXTURE_STOP_FAILED pg_ctl_rc=$rc survivor_pid=$(head -1 "$DATA/postmaster.pid")" >&2; exit 4; fi
    [ "$rc" = 0 ] || { echo "S11_FIXTURE_STOP_FAILED pg_ctl_rc=$rc (no postmaster.pid survivor observed)" >&2; exit "$rc"; }
    echo "S11_FIXTURE_STOP_OK" ;;
  status)  pgbin pg_ctl -D "$DATA" status || true ;;
  destroy)
    grep -q "^cluster_name = '$MARKER'" "$DATA/postgresql.conf" 2>/dev/null || { echo "REFUSED: $DATA is not the marked S11 cluster; not destroying" >&2; exit 3; }
    if postmaster_alive; then
      rc=0; pgbin pg_ctl -D "$DATA" -m fast -w -t "$STOP_TIMEOUT" stop </dev/null >>"$LOG.pg_ctl" 2>&1 || rc=$?
      if postmaster_alive; then echo "DESTROY_REFUSED: stop rc=$rc and postmaster pid $(head -1 "$DATA/postmaster.pid") still alive; not removing $DATA" >&2; exit 4; fi
      [ "$rc" = 0 ] || { echo "DESTROY_REFUSED: pg_ctl stop rc=$rc; not removing $DATA" >&2; exit 4; }
      echo "S11_FIXTURE_DESTROY_STOPPED_FIRST"
    else
      echo "S11_FIXTURE_DESTROY_ALREADY_STOPPED"
    fi
    users="$(data_dir_users)"
    [ -z "$users" ] || { echo "DESTROY_REFUSED: processes still reference $DATA: $users" >&2; exit 4; }
    rm -rf -- "$DATA" || { echo "DESTROY_FAILED: rm rc=$? for $DATA" >&2; exit 5; }
    [ ! -e "$DATA" ] && [ ! -L "$DATA" ] || { echo "DESTROY_FAILED: $DATA still present after removal" >&2; exit 5; }
    echo "S11_FIXTURE_DESTROY_OK $DATA" ;;
  *) echo "unknown cmd $cmd" >&2; exit 2 ;;
esac
