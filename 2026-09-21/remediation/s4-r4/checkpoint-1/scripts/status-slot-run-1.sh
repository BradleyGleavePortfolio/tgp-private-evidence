#!/usr/bin/env bash
# Verifies the ACTUAL run state: live process tree, lock holder, exit record.
EV=/home/user/workspace/execution/s4-r4
LOCK=/home/user/workspace/execution/test-validation.lock
echo "== runner pid file"; cat "$EV/logs/slot-run-1.pid" 2>/dev/null || echo "(none)"
PID=$(cat "$EV/logs/slot-run-1.pid" 2>/dev/null)
if [ -n "${PID:-}" ] && kill -0 "$PID" 2>/dev/null; then
  echo "== runner ALIVE"; ps -o pid,ppid,sid,etime,cmd --pid "$PID" $(pgrep -P "$PID" | tr '\n' ' ') 2>/dev/null
else
  echo "== runner NOT running"
fi
echo "== processes holding the lock file open (/proc scan; fuser unavailable)"
found=0
for d in /proc/[0-9]*; do
  if ls -l "$d/fd" 2>/dev/null | grep -q "$LOCK"; then
    found=1; echo "pid ${d#/proc/}: $(tr '\0' ' ' < "$d/cmdline" 2>/dev/null | cut -c1-120)"
  fi
done
[ "$found" = 1 ] || echo "(lock file not open by any process)"
echo "== exit record"; cat "$EV/logs/slot-run-1.exit.json" 2>/dev/null || echo "(none yet — run not finished)"
echo "== step meta so far"; ls "$EV/logs"/*.meta.json 2>/dev/null | xargs -r -n1 basename
