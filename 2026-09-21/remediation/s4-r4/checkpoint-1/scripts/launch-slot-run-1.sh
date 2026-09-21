#!/usr/bin/env bash
# Durable launcher for slot-run-1 — run ONLY after the parent grants the slot.
# Starts the run in its own session (setsid) so tool-call process-group teardown
# cannot kill it; the lock is taken NONBLOCKING by flock around the whole run.
# Prints the pid; progress is verified by checking the live process and the
# lock holder, and completion ONLY by logs/slot-run-1.exit.json.
set -u
EV=/home/user/workspace/execution/s4-r4
LOCK=/home/user/workspace/execution/test-validation.lock
mkdir -p "$EV/logs"
if [ -f "$EV/logs/slot-run-1.exit.json" ]; then
  echo "refusing: exit record already exists ($EV/logs/slot-run-1.exit.json); move it aside first" >&2
  exit 64
fi
setsid nohup flock -n "$LOCK" bash "$EV/scripts/slot-run-1.sh" \
  > "$EV/logs/slot-run-1.console.log" 2>&1 < /dev/null &
LPID=$!
sleep 2
if ! kill -0 "$LPID" 2>/dev/null; then
  echo "launcher process $LPID exited early (lock busy? see console log):"; tail -5 "$EV/logs/slot-run-1.console.log"
  exit 75
fi
echo "launched flock wrapper pid=$LPID; runner pid file: $EV/logs/slot-run-1.pid"
echo "verify with: bash $EV/scripts/status-slot-run-1.sh"
