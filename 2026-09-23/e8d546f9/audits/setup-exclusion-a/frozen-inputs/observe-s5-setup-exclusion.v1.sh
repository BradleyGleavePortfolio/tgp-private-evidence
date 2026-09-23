#!/usr/bin/env bash
# Read-only bounded observer: reports holder state from records + /proc identity. Never opens the lock, never signals. usage: observe.sh [EX]
EX=${1:-/home/user/workspace/execution/s5-r4}; H=$EX/LEASE_HOLDER
[ -r "$H" ] || { echo "NO_HOLDER_RECORD ex=$EX (unresolved: cannot claim free or held)"; exit 3; }
P=$(sed -n 's/.*holder_pid=\([0-9]*\) .*/\1/p' "$H" | head -1); ST=$(sed -n 's/.* start_time=\([0-9]*\) .*/\1/p' "$H" | head -1); S=$(sed -n 's/.* state=\([^ ]*\) .*/\1/p' "$H" | head -1)
CUR=$(cut -d' ' -f22 "/proc/$P/stat" 2>/dev/null)
if [ -n "$CUR" ] && [ "$CUR" = "$ST" ]; then echo "HOLDER_LIVE pid=$P state=$S $( [ -r "$EX/SELF_HOLD" ] && echo self_hold_record=present )"; exit 0
elif [ -r "$EX/LEASE_RELEASE" ]; then echo "HOLDER_GONE_RELEASE_RECORDED $(cat "$EX/LEASE_RELEASE")"; exit 0
else echo "HOLDER_GONE_NO_RELEASE pid=$P (unresolved: launcher ended without RELEASE; do not treat exclusion as clean)"; exit 2; fi
