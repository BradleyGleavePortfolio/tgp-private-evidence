#!/usr/bin/env bash
# Durable, bounded launcher for slot-run-2 (SLOT A3-S4-VALIDATION).
# setsid: survives tool-call process-group teardown. timeout: bounds the WHOLE
# allocation (880 s + 20 s kill grace < 15 min). flock -n: canonical lock held
# for the whole run, fails closed if busy.
set -u
EV=/home/user/workspace/execution/s4-r4
LOCK=/home/user/workspace/execution/test-validation.lock
mkdir -p "$EV/logs"
[ -f "$EV/logs/slot-run-2.exit.json" ] && { echo "refusing: exit record exists"; exit 64; }
setsid nohup timeout --kill-after=20 880 flock -n "$LOCK" bash "$EV/scripts/slot-run-2.sh" \
  > "$EV/logs/slot-run-2.console.log" 2>&1 < /dev/null &
LPID=$!
sleep 3
if ! kill -0 "$LPID" 2>/dev/null; then
  echo "launcher pid $LPID exited early:"; tail -5 "$EV/logs/slot-run-2.console.log"; exit 75
fi
echo "launched pid=$LPID start=$(date -u +%Y-%m-%dT%H:%M:%SZ) deadline=$(date -u -d '+900 seconds' +%Y-%m-%dT%H:%M:%SZ)"
