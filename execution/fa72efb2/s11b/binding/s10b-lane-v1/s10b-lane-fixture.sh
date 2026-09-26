#!/usr/bin/env bash
# EXEC-FA72EFB2 S11-B S10-B-lane fixture v1: minimum substitution of the reviewed D2 fixture execution/fa72efb2/s10d2/binding/v1/
# d2-fixture.sh (sha256 0fadafa3…c24b): lane clusters/s10d2 + run/s10d2 -> clusters/s11b-s10b + run/s11b-s10b, required runner
# d2-pg-proof.sh -> s10b-lane-pg-proof.sh, lane labels. Port 55649, the reused S10-B harness literals, the refused ports and
# every mechanism are unchanged; the D2_RUNNER_PID / D2_STOP_TIMEOUT / D2_FIXTURE_* names are template protocol tokens carried
# verbatim (the runner greps them). Full delta: DELTA-fixture-from-d2.diff. Text below is the D2 fixture header.
# S10-D D2 disposable PostgreSQL 17.6 cluster helper (lane s10d2 only, EXEC-FA72EFB2), derived by MINIMUM literal substitution
# from the accepted S10-C fixture execution/d3a9f701/s10c/binding/v6/s10c-fixture.sh (sha256 c1b57239…92e7; that run rc 0,
# 32/32; diff in DELTA-fixture.diff). LOCK-FREE BY DESIGN: it takes no flock itself and must be invoked only by the D2 proof
# binding execution/fa72efb2/s10d2/binding/v1/d2-pg-proof.sh, the single canonical lock holder. Standalone use is refused
# unless D2_RUNNER_PID names a live d2-pg-proof.sh process.
#   * lane clusters/s10d2 + run/s10d2 on port 55649 in the fa72efb2 runtime. The D2 live spec
#     (test/scout/s10/s10-unseen.pg.spec.ts) reuses the landed S10-B harness by import, whose only parameterizable lane
#     inputs are port and data directory, so the harness literals are REUSED unchanged: cluster_name =
#     's10b-disposable-pg17' (= test/utils/g2-s10b-db.ts G2_S10B_CLUSTER_MARKER and g2-s10b-bootstrap.sh CLUSTER_MARKER),
#     superuser s10b_super / s10b_local_synthetic, database g2_s10b_disposable (created by the bootstrap). The lane is told
#     apart by its data directory and port only: start and destroy require the marker AND `port = 55649` in THIS data
#     directory's postgresql.conf; any lane path other than clusters/s10d2 is refused; ports 55646 (S9-C), 55647 (S10-B)
#     and 55648 (S11, the other lane binding in this runtime) are refused outright.
#   * FRESH INIT ONLY: init refuses if the data directory exists (no marking/adopting unknown clusters)
#   * listen 127.0.0.1 only; fa72efb2 runtime NAMESPACE (execution/fa72efb2/runtime/raw/rt-setup.log): binaries from the
#     SHA-pinned fa72efb2/runtime/pg17/dist; data and socket directories under fa72efb2/runtime/clusters/s10d2 and
#     fa72efb2/runtime/run/s10d2 — never pg17/dist, never /home/user/pg17, never any other clusters/* lane.
#     The RUNTIME_ROOT / PORT / LANE / DATA lines below are literals the runner cross-checks whole-line.
# `destroy` never discards a stop failure (S5-R3-A-03 revision 2 inherited): a running marked cluster is stopped
# with a bounded fast stop; a failed stop, a surviving postmaster or any process still referencing the data
# directory REFUSES removal (rc 4); a failed or incomplete removal is propagated (rc 5) and DESTROY_OK is printed
# only after the directory is verified absent. `stop` is bounded by D2_STOP_TIMEOUT (runner-supplied; default 45 s).
# Usage (via runner): d2-fixture.sh init|start|stop|status|destroy
set -euo pipefail
# ---- lane constants
RUNTIME_ROOT=/home/user/workspace/execution/fa72efb2/runtime
# ---- end lane constants
PGHOME=$RUNTIME_ROOT/pg17/dist
PORT=55649; SUPER=s10b_super; PASS=s10b_local_synthetic; MARKER=s10b-disposable-pg17
LANE=$RUNTIME_ROOT/clusters/s11b-s10b
DATA=$LANE/pg-data; LOG=$LANE/pg.log; SOCK=$RUNTIME_ROOT/run/s11b-s10b
STOP_TIMEOUT="${D2_STOP_TIMEOUT:-45}"
cmd=${1:?init|start|stop|status|destroy}
case "$PORT" in 55646|55647|55648) echo "REFUSED: port $PORT belongs to the S9-C/S10-B/S11 lane" >&2; exit 2;; esac
case "$LANE" in "$RUNTIME_ROOT/clusters/s11b-s10b") ;; *) echo "REFUSED: lane $LANE is not clusters/s11b-s10b (any s10-b lane and every other lane are never touched)" >&2; exit 2;; esac
lane_conf_ok(){ grep -q "^cluster_name = '$MARKER'" "$DATA/postgresql.conf" 2>/dev/null && grep -qx "port = $PORT" "$DATA/postgresql.conf" 2>/dev/null; }
case "$PORT" in *__*) echo "REFUSED: lane PORT not filled by the parent (binding proposal stage)" >&2; exit 2;; esac
[ -n "${D2_RUNNER_PID:-}" ] && [ -d "/proc/$D2_RUNNER_PID" ] && grep -q s10b-lane-pg-proof.sh "/proc/$D2_RUNNER_PID/cmdline" \
  || { echo "s10b-lane-fixture.sh must be invoked by s10b-lane-pg-proof.sh (single lock holder); refusing standalone $cmd" >&2; exit 2; }
[ -x "$PGHOME/bin/pg_ctl" ] || { echo "PG 17 distribution missing at $PGHOME" >&2; exit 2; }
case "$DATA" in "$PGHOME"/*) echo "REFUSED: data directory inside pg17/dist" >&2; exit 2;; /home/user/pg17/*) echo "REFUSED: historical pg17 path" >&2; exit 2;; esac
# Children never see the runner's lock fd; the postmaster gets /dev/null stdin and the server log only.
pgbin(){ local b=$1; shift; LD_LIBRARY_PATH="$PGHOME/lib" "$PGHOME/bin/$b" "$@" 9>&-; }
mkdir -p "$SOCK" "$LANE"
postmaster_alive() { [ -f "$DATA/postmaster.pid" ] && kill -0 "$(head -1 "$DATA/postmaster.pid")" 2>/dev/null; }
ppid_of() { local s; s="$(cat "/proc/$1/stat" 2>/dev/null)" || { echo x; return; }; s="${s##*) }"; set -- $s; echo "${2:-x}"; }
data_dir_users() { # prints "pid:cmdline" for every OTHER process referencing $DATA on its command line
  local p pid me=$BASHPID; for p in /proc/[0-9]*; do pid=${p#/proc/}; [ "$pid" = "$me" ] || [ "$pid" = "$$" ] && continue; [ "$pid" = "${D2_RUNNER_PID:-x}" ] && continue
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
# --- S11-B S10-B-lane disposable fixture (S10-B harness marker reused) (2 vCPU / 8 GB sandbox) ---
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
    echo "D2_FIXTURE_INIT_OK data=$DATA port=$PORT superuser=$SUPER cluster_name=$MARKER socket=$SOCK pg_version=$(cat "$DATA/PG_VERSION")" ;;
  start)
    lane_conf_ok || { echo "REFUSED: $DATA lacks the reused S10-B marker or port = $PORT; not starting a foreign cluster" >&2; exit 3; }
    if pgbin pg_ctl -D "$DATA" status >/dev/null 2>&1; then echo "already running"; else
      pgbin pg_ctl -D "$DATA" -l "$LOG" -w -t 60 start </dev/null >>"$LOG.pg_ctl" 2>&1; fi
    echo "D2_FIXTURE_START_OK pid=$(head -1 "$DATA/postmaster.pid")" ;;
  stop)
    rc=0; pgbin pg_ctl -D "$DATA" -m fast -w -t "$STOP_TIMEOUT" stop </dev/null >>"$LOG.pg_ctl" 2>&1 || rc=$?
    if postmaster_alive; then echo "D2_FIXTURE_STOP_FAILED pg_ctl_rc=$rc survivor_pid=$(head -1 "$DATA/postmaster.pid")" >&2; exit 4; fi
    [ "$rc" = 0 ] || { echo "D2_FIXTURE_STOP_FAILED pg_ctl_rc=$rc (no postmaster.pid survivor observed)" >&2; exit "$rc"; }
    echo "D2_FIXTURE_STOP_OK" ;;
  status)  pgbin pg_ctl -D "$DATA" status || true ;;
  destroy)
    lane_conf_ok || { echo "REFUSED: $DATA is not the marked S11-B S10-B-lane cluster (marker + port = $PORT); not destroying" >&2; exit 3; }
    if postmaster_alive; then
      rc=0; pgbin pg_ctl -D "$DATA" -m fast -w -t "$STOP_TIMEOUT" stop </dev/null >>"$LOG.pg_ctl" 2>&1 || rc=$?
      if postmaster_alive; then echo "DESTROY_REFUSED: stop rc=$rc and postmaster pid $(head -1 "$DATA/postmaster.pid") still alive; not removing $DATA" >&2; exit 4; fi
      [ "$rc" = 0 ] || { echo "DESTROY_REFUSED: pg_ctl stop rc=$rc; not removing $DATA" >&2; exit 4; }
      echo "D2_FIXTURE_DESTROY_STOPPED_FIRST"
    else
      echo "D2_FIXTURE_DESTROY_ALREADY_STOPPED"
    fi
    users="$(data_dir_users)"
    [ -z "$users" ] || { echo "DESTROY_REFUSED: processes still reference $DATA: $users" >&2; exit 4; }
    rm -rf -- "$DATA" || { echo "DESTROY_FAILED: rm rc=$? for $DATA" >&2; exit 5; }
    [ ! -e "$DATA" ] && [ ! -L "$DATA" ] || { echo "DESTROY_FAILED: $DATA still present after removal" >&2; exit 5; }
    echo "D2_FIXTURE_DESTROY_OK $DATA" ;;
  *) echo "unknown cmd $cmd" >&2; exit 2 ;;
esac
