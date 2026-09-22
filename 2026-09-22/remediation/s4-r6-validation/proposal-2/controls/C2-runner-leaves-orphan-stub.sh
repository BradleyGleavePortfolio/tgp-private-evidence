#!/usr/bin/env bash
# CONTROL C2: stub runner that exits 0 "successfully" but leaves an owned orphan.
# Launch: S4R6_CONTROL=1 S4R6_RUNNER=$PWD/C2-runner-leaves-orphan-stub.sh S4R6_OUTER_S=30 bash ../launcher/s4-r6-launch-v2.sh
# Expected: OVERALL=FAILED_RUNNER_LEFT_ORPHANS, exit 6, reaped_by_supervisor non-empty,
#           survivors_after_kill="" — a clean-looking runner exit is NOT success.
echo "C2 stub pid=$$"
nohup sleep 300 >/dev/null 2>&1 &
disown
exit 0
