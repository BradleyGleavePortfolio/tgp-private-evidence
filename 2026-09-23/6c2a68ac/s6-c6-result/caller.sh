#!/bin/bash
# simple detached caller (transport + actual wait receipt only): no timeout, no supervision, no signals, no observer.
R=/home/user/workspace/execution/6c2a68ac/s6-c6-result; L=/home/user/workspace/execution/6c2a68ac/s6-exclusion-v1/launch-s6-c6-exclusion.v1.sh
ts() { date -u +%Y-%m-%dT%H:%M:%SZ; }
echo "$(ts) CALLER_START caller_pid=$$ caller_sid=$(cut -d' ' -f6 /proc/$$/stat) cmd=[setsid -w env S6_C6_GRANT=granted-by-parent bash $L]" > "$R/LAUNCHER_WAIT_RECEIPT"
setsid -w env S6_C6_GRANT=granted-by-parent bash "$L" > "$R/launcher.out" 2>&1 < /dev/null; rc=$?
echo "$(ts) CALLER_WAIT_OBSERVED launcher_wait_rc=$rc (actual wait status of the setsid -w'd launcher process, observed by this caller; separate from the launcher's own published final_rc)" >> "$R/LAUNCHER_WAIT_RECEIPT"
