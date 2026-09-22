#!/usr/bin/env bash
# Durable detached launcher for the granted `full` run: survives the shell-tool lifetime (setsid),
# outer wall-clock bound (timeout 1800 s, SIGKILL +60 s), real PID file and a sentinel with the
# runner's exit AND the cleanup-stop status. If the outer bound kills the runner, a bounded `stop`
# stage is run afterwards so no postmaster outlives the slot; its rc is recorded in the sentinel.
# Usage: G2_PG17_PASSWORD=<fixture pw> [STAGE=full|resume] bash execution/s5-r3/launch-full.sh   (returns immediately)
set -uo pipefail
S=/home/user/workspace/execution/s5-r3; L=$S/logs; TS=$(date -u +%Y%m%dT%H%M%SZ)
PIDFILE=$L/full-$TS.pid; SENTINEL=$L/full-$TS.sentinel; OUT=$L/full-$TS.launcher.log
[ -n "${G2_PG17_PASSWORD:-}" ] || { echo "G2_PG17_PASSWORD required" >&2; exit 2; }
setsid -f bash -c '
  echo "$$" > "$1"; echo "LAUNCH $(date -u +%FT%TZ) pid=$$ stage=${STAGE:-full} bound=1800s" >> "$3"
  timeout --kill-after=60 1800 bash "$4/run-proof.sh" "${STAGE:-full}" >> "$3" 2>&1; rc=$?
  stop_rc=na
  if [ "$rc" = 124 ] || [ "$rc" = 137 ]; then
    echo "OUTER_BOUND_HIT rc=$rc $(date -u +%FT%TZ); running bounded cleanup stop" >> "$3"
    timeout --kill-after=15 90 bash "$4/run-proof.sh" stop >> "$3" 2>&1; stop_rc=$?
  fi
  echo "FULL_EXIT=$rc CLEANUP_STOP_RC=$stop_rc END=$(date -u +%FT%TZ) pid=$$" | tee -a "$3" > "$2"
' _ "$PIDFILE" "$SENTINEL" "$OUT" "$S" < /dev/null
sleep 1; echo "launched: pid=$(cat "$PIDFILE" 2>/dev/null) sentinel=$SENTINEL log=$OUT"
