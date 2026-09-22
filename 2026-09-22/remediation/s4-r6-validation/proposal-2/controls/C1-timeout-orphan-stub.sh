#!/usr/bin/env bash
# CONTROL C1 (NOT a validation run): stub runner for the launcher's mandatory outer
# deadline and owned-group reaping incl. a REPARENTED orphan. No network, no product.
# Launch: S4R6_CONTROL=1 S4R6_RUNNER=$PWD/C1-timeout-orphan-stub.sh S4R6_OUTER_S=6 S4R6_GRACE_S=3 bash ../launcher/s4-r6-launch-v2.sh
# Expected: OVERALL=TIMEOUT, exit 124, owned_group.signalled=TERM or TERM+KILL,
#           survivors_after_kill="" (the reparented sleep is still in the group and is reaped),
#           SUPERVISOR_RECORD.json present. Runtime ≤ ~15 s.
echo "C1 stub pid=$$ pgid=$(ps -o pgid= -p $$ | tr -d ' ') out=${S4R6_OUT:-?}"
( sleep 300 & )          # grandchild: parent subshell exits → reparented, keeps PGID
trap '' TERM             # stub ignores TERM so the KILL path is exercised
sleep 300
