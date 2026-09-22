#!/usr/bin/env bash
# S5 R4 durable detached launcher, revision 2. Survives the shell-tool lifetime (setsid), real PID file
# and a sentinel with the runner's first exit and its recorded cleanup status.
# Revision 2 (S5-R3-A-02): the launcher is a BACKSTOP, not a second supervisor. The runner owns the
# canonical lock through owned-work termination, cleanup stop and liveness verification, enforces its
# own inner deadline (WORK_BUDGET=1560 s) and handles TERM. Budget accounting:
#   runner work deadline 1560 s + cleanup (reap 20 s + stop 45 s + records ~15 s = 80 s) = 1640 s
#   outer TERM at 1740 s (margin 100 s) -> the runner's TERM trap runs the same bounded cleanup
#   outer KILL at 1740 + 120 s (margin 40 s over the 80 s cleanup budget)
# If the outer bound is hit, this launcher records OUTER_BOUND_HIT plus a liveness observation and
# writes the lane QUARANTINE marker. It NEVER starts a second runner to take the lock and stop the
# fixture (that reacquisition race was the frozen defect); the parent inspects and stops manually.
# Usage: G2_PG17_PASSWORD=<fixture pw> [STAGE=full|resume] bash execution/s5-r4/launch-full.sh   (returns immediately)
set -uo pipefail
S=/home/user/workspace/execution/s5-r4; L=$S/logs; TS=$(date -u +%Y%m%dT%H%M%SZ)
PIDFILE=$L/full-$TS.pid; SENTINEL=$L/full-$TS.sentinel; OUT=$L/full-$TS.launcher.log
DATA=/home/user/pg17/clusters/s5
mkdir -p "$L"
[ -n "${G2_PG17_PASSWORD:-}" ] || { echo "G2_PG17_PASSWORD required" >&2; exit 2; }
case "${STAGE:-full}" in full|resume|genctl|guard|preflight|live|bootstrap) ;; *) echo "STAGE=${STAGE} not launchable here (destroy/reset/stop are parent-driven single stages)" >&2; exit 2;; esac
setsid -f bash -c '
  echo "$$" > "$1"; echo "LAUNCH $(date -u +%FT%TZ) pid=$$ stage=${STAGE:-full} outer_term=1740s outer_kill=+120s runner_sha256=$(sha256sum "$4/run-proof.sh" | cut -c1-64)" >> "$3"
  timeout --foreground --kill-after=120 1740 bash "$4/run-proof.sh" "${STAGE:-full}" >> "$3" 2>&1; rc=$?
  outer=no
  if [ "$rc" = 124 ] || [ "$rc" = 137 ]; then
    outer=yes
    pm=none; [ -f "$5/postmaster.pid" ] && kill -0 "$(head -1 "$5/postmaster.pid")" 2>/dev/null && pm="alive pid=$(head -1 "$5/postmaster.pid")"
    echo "OUTER_BOUND_HIT rc=$rc $(date -u +%FT%TZ) postmaster=$pm; NO second runner, NO lock reacquisition; lane quarantined for parent inspection" >> "$3"
    mkdir -p "$4/QUARANTINE"; echo "QUARANTINED $(date -u +%FT%TZ) by launcher: outer bound hit rc=$rc stage=${STAGE:-full} postmaster=$pm" > "$4/QUARANTINE/$(date -u +%Y%m%dT%H%M%SZ)-launcher.txt"
  fi
  echo "FULL_EXIT=$rc OUTER_BOUND=$outer END=$(date -u +%FT%TZ) pid=$$" | tee -a "$3" > "$2"
' _ "$PIDFILE" "$SENTINEL" "$OUT" "$S" "$DATA" < /dev/null
sleep 1; echo "launched: pid=$(cat "$PIDFILE" 2>/dev/null) sentinel=$SENTINEL log=$OUT"
