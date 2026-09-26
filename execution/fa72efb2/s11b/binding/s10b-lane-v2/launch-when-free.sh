#!/usr/bin/env bash
# Parent launcher: waits until no process holds or waits on the canonical lock for 3 consecutive 5 s polls, then starts the
# single granted S11-B S10-B-lane v2 proof run detached. It never touches the lock itself.
L=/home/user/workspace/execution/test-validation.lock; D=$(cd "$(dirname "$0")" && pwd)
ok=0; for i in $(seq 1 720); do
  H=$(lslocks -n -o PATH 2>/dev/null | grep -c test-validation || true); Wt=$(pgrep -fc 'flock -w [0-9]+ /home/user/workspace/execution/test-validation.lock' || true)
  if [ "$H" = 0 ] && [ "$Wt" = 0 ]; then ok=$((ok+1)); else ok=0; fi
  [ $ok -ge 3 ] && break; sleep 5; done
echo "LAUNCH $(date -u +%FT%TZ) after_polls=$i"
exec timeout -k 30 4500 bash "$D/s10b-lane-pg-proof.sh"
