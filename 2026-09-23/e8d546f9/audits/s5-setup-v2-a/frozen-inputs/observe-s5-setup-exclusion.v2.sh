#!/usr/bin/env bash
# Read-only bounded observer v2 (successor of v1 157bf1f4; closes S5X-A-05): reports holder state from records + /proc identity. Never opens the lock, never signals.
# v2: an unreadable identity for a present pid is UNKNOWN (never "gone"); a LEASE_RELEASE counts only if it names the SAME token+holder_pid+start_time as the
# LEASE_HOLDER snapshot read here; any other release record is a MISMATCH (unresolved), never this attempt's release. usage: observe.sh [EX]
EX=${1:-/home/user/workspace/execution/s5-r4}; H=$EX/LEASE_HOLDER
[ -r "$H" ] || { echo "NO_HOLDER_RECORD ex=$EX (unresolved: cannot claim free or held)"; exit 3; }
SNAP=$(head -1 "$H" 2>/dev/null)
P=$(printf '%s\n' "$SNAP" | sed -n 's/.*holder_pid=\([0-9]*\) .*/\1/p'); ST=$(printf '%s\n' "$SNAP" | sed -n 's/.* start_time=\([0-9]*\) .*/\1/p'); S=$(printf '%s\n' "$SNAP" | sed -n 's/.* state=\([^ ]*\) .*/\1/p'); TOK=$(printf '%s\n' "$SNAP" | sed -n 's/^token=\([^ ]*\) .*/\1/p')
[ -n "$P" ] && [ -n "$ST" ] && [ -n "$TOK" ] || { echo "HOLDER_RECORD_UNPARSEABLE ex=$EX (unresolved)"; exit 3; }
if [ -d "/proc/$P" ]; then CUR=$(cut -d' ' -f22 "/proc/$P/stat" 2>/dev/null)
  [ -n "$CUR" ] || { echo "HOLDER_UNKNOWN pid=$P (/proc present, identity unreadable: unresolved; do not treat exclusion as free)"; exit 3; }
  [ "$CUR" = "$ST" ] && { echo "HOLDER_LIVE pid=$P token=$TOK state=$S $( [ -r "$EX/SELF_HOLD" ] && echo self_hold_record=present )"; exit 0; }; fi
# holder pid absent, or the pid number now belongs to another process (start time differs)
if [ -f "$EX/LEASE_RELEASE" ] && [ -r "$EX/LEASE_RELEASE" ]; then
  if grep -q "^token=$TOK holder_pid=$P start_time=$ST " "$EX/LEASE_RELEASE"; then echo "HOLDER_GONE_RELEASE_RECORDED $(head -1 "$EX/LEASE_RELEASE")"; exit 0
  else echo "HOLDER_GONE_RELEASE_MISMATCH token=$TOK pid=$P start_time=$ST release=[$(head -c 400 "$EX/LEASE_RELEASE" | tr '\n' ' ')] (unresolved: release record is not this attempt's)"; exit 2; fi
elif [ -e "$EX/LEASE_RELEASE" ]; then echo "HOLDER_GONE_RELEASE_UNREADABLE pid=$P (unresolved: LEASE_RELEASE exists but is not a readable file)"; exit 2
else echo "HOLDER_GONE_NO_RELEASE pid=$P token=$TOK (unresolved: launcher ended without RELEASE; do not treat exclusion as clean)"; exit 2; fi
