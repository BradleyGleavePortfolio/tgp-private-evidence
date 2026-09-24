#!/usr/bin/env bash
# S8-B disposable PostgreSQL 17.6 cluster helper (lane s8-b only), derived by substitution from the S7-L
# fixture execution/ce3748cb/s7l/binding/s7l-fixture.sh (draft sha256 6b3a76f4…). LOCK-FREE BY DESIGN: it takes no flock itself and must be
# invoked only by the frozen S8-B proof binding execution/ce3748cb/s8b/binding/s8b-pg-proof.sh,
# the single canonical lock holder. Standalone use is refused unless S8B_RUNNER_PID names a live s8b-pg-proof.sh process.
#   * cluster_name = 's8b-disposable-pg17' (pinned marker required by start, bootstrap and destroy)
#   * FRESH INIT ONLY: init refuses if the data directory exists (no marking/adopting unknown clusters)
#   * listen 127.0.0.1 only, port 55511, superuser s8b_super / s8b_local_synthetic (synthetic value; scram, S5 shape)
#   * data directory $PG17_HOME/clusters/s8-b/pg-data; binaries from S2's SHA-pinned $PG17_HOME/dist
# Revision 2 (S5-R3-A-03, inherited): `destroy` never discards a stop failure. A running marked cluster is
# stopped with a bounded fast stop; a failed stop, a surviving postmaster or any process still
# referencing the data directory REFUSES removal (rc 4); a failed or incomplete removal is
# propagated (rc 5) and DESTROY_OK is printed only after the directory is verified absent.
# `stop` is bounded by S8B_STOP_TIMEOUT (runner-supplied; default 45 s) and reports a survivor.
# Usage (via runner): s8b-fixture.sh init|start|stop|status|destroy
set -euo pipefail
# ---- lane constants (the ONLY line a frozen control driver may substitute; see controls/README.md)
PG17_HOME=/home/user/pg17
# ---- end lane constants
PGHOME=$PG17_HOME/dist
PORT=55511; SUPER=s8b_super; PASS=s8b_local_synthetic; MARKER=s8b-disposable-pg17
DATA=$PG17_HOME/clusters/s8-b/pg-data; LOG=$PG17_HOME/clusters/s8-b/pg.log; SOCK=$PG17_HOME/run/s8-b
STOP_TIMEOUT="${S8B_STOP_TIMEOUT:-45}"
cmd=${1:?init|start|stop|status|destroy}
[ -n "${S8B_RUNNER_PID:-}" ] && [ -d "/proc/$S8B_RUNNER_PID" ] && grep -q s8b-pg-proof.sh "/proc/$S8B_RUNNER_PID/cmdline" \
  || { echo "s8b-fixture.sh must be invoked by s8b-pg-proof.sh (single lock holder); refusing standalone $cmd" >&2; exit 2; }
[ -x "$PGHOME/bin/pg_ctl" ] || { echo "PG 17 distribution missing at $PGHOME" >&2; exit 2; }
# Children never see the runner's lock fd; the postmaster gets /dev/null stdin and the server log only.
pgbin(){ local b=$1; shift; LD_LIBRARY_PATH="$PGHOME/lib" "$PGHOME/bin/$b" "$@" 9>&-; }
mkdir -p "$SOCK" "$(dirname "$DATA")"
# Postmaster liveness from the data directory's own pid file (first line), plus any other process
# whose command line names the data directory (a postmaster started outside pg_ctl, a stray child).
postmaster_alive() { [ -f "$DATA/postmaster.pid" ] && kill -0 "$(head -1 "$DATA/postmaster.pid")" 2>/dev/null; }
ppid_of() { local s; s="$(cat "/proc/$1/stat" 2>/dev/null)" || { echo x; return; }; s="${s##*) }"; set -- $s; echo "${2:-x}"; }  # after "(comm) ": state ppid pgrp ...
data_dir_users() { # prints "pid:cmdline" for every OTHER process referencing $DATA on its command line
  local p pid me=$BASHPID; for p in /proc/[0-9]*; do pid=${p#/proc/}; [ "$pid" = "$me" ] || [ "$pid" = "$$" ] && continue; [ "$pid" = "${S8B_RUNNER_PID:-x}" ] && continue
    [ "$(ppid_of "$pid")" = "$me" ] && continue   # this scan's own helpers
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
# --- S8-B disposable fixture (2 vCPU / 8 GB sandbox) ---
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
    echo "S8B_FIXTURE_INIT_OK data=$DATA port=$PORT superuser=$SUPER cluster_name=$MARKER pg_version=$(cat "$DATA/PG_VERSION")" ;;
  start)
    grep -q "^cluster_name = '$MARKER'" "$DATA/postgresql.conf" || { echo "REFUSED: $DATA lacks the S8-B marker; not starting a foreign cluster" >&2; exit 3; }
    if pgbin pg_ctl -D "$DATA" status >/dev/null 2>&1; then echo "already running"; else
      pgbin pg_ctl -D "$DATA" -l "$LOG" -w -t 60 start </dev/null >>"$LOG.pg_ctl" 2>&1; fi
    echo "S8B_FIXTURE_START_OK pid=$(head -1 "$DATA/postmaster.pid")" ;;
  stop)
    # Bounded fast stop. The real pg_ctl rc is the first exit; a survivor after a "successful" stop is
    # still a failure (rc 4) so the runner never records a clean stop over a live postmaster.
    rc=0; pgbin pg_ctl -D "$DATA" -m fast -w -t "$STOP_TIMEOUT" stop </dev/null >>"$LOG.pg_ctl" 2>&1 || rc=$?
    if postmaster_alive; then echo "S8B_FIXTURE_STOP_FAILED pg_ctl_rc=$rc survivor_pid=$(head -1 "$DATA/postmaster.pid")" >&2; exit 4; fi
    [ "$rc" = 0 ] || { echo "S8B_FIXTURE_STOP_FAILED pg_ctl_rc=$rc (no postmaster.pid survivor observed)" >&2; exit "$rc"; }
    echo "S8B_FIXTURE_STOP_OK" ;;
  status)  pgbin pg_ctl -D "$DATA" status || true ;;
  destroy)
    grep -q "^cluster_name = '$MARKER'" "$DATA/postgresql.conf" 2>/dev/null || { echo "REFUSED: $DATA is not the marked S8-B cluster; not destroying" >&2; exit 3; }
    if postmaster_alive; then
      # Running marked cluster: bounded fast stop first. Its failure is NEVER discarded.
      rc=0; pgbin pg_ctl -D "$DATA" -m fast -w -t "$STOP_TIMEOUT" stop </dev/null >>"$LOG.pg_ctl" 2>&1 || rc=$?
      if postmaster_alive; then echo "DESTROY_REFUSED: stop rc=$rc and postmaster pid $(head -1 "$DATA/postmaster.pid") still alive; not removing $DATA" >&2; exit 4; fi
      [ "$rc" = 0 ] || { echo "DESTROY_REFUSED: pg_ctl stop rc=$rc; not removing $DATA" >&2; exit 4; }
      echo "S8B_FIXTURE_DESTROY_STOPPED_FIRST"
    else
      echo "S8B_FIXTURE_DESTROY_ALREADY_STOPPED"
    fi
    users="$(data_dir_users)"
    [ -z "$users" ] || { echo "DESTROY_REFUSED: processes still reference $DATA: $users" >&2; exit 4; }
    rm -rf -- "$DATA" || { echo "DESTROY_FAILED: rm rc=$? for $DATA" >&2; exit 5; }
    [ ! -e "$DATA" ] || { echo "DESTROY_FAILED: $DATA still present after removal" >&2; exit 5; }
    echo "S8B_FIXTURE_DESTROY_OK $DATA" ;;
  *) echo "unknown cmd $cmd" >&2; exit 2 ;;
esac
