#!/usr/bin/env bash
# C6 caller-only observer envelope — NOT the runner, NOT an owned workload group. Pinned so the outer status capture
# is reviewable bytes rather than an ad-hoc tool-shell line. Closes the C5 gap "outer.exit never written"
# (S6_C5_REVIEW_B.md §5: observer 4281 lived in the tool shell's session and was neither nohup'd nor setsid'd; set +e alone
# does not address that). Here the OBSERVER itself is detached (setsid nohup) and runs with errexit off, so the outer wait
# status of `timeout` is written even if the tool shell that launched it ends first or a nonzero status occurs.
# Frozen runner bytes and the setsid/nohup/timeout topology around the runner are unchanged from the C5 pattern.
# Usage (parent-granted only): bash /home/user/workspace/execution/op88/s6-c6-prep/c6/launch-c6-observer.sh
set +e
set -u
LOGS=/home/user/workspace/execution/op88/s6-c6-prep/logs/c6
RUNNER=/home/user/workspace/execution/op88/s6-c6-prep/c6/run-c6-hazard-v5-conly.sh
mkdir -p "$LOGS" || exit 70
[ -e "$LOGS/outer.exit" ] && { echo "refuse: $LOGS/outer.exit already exists (one run only)"; exit 71; }
[ -e "$LOGS/c6.EXIT_RECORD" ] && { echo "refuse: $LOGS/c6.EXIT_RECORD already exists (one run only)"; exit 71; }
{ date -u +%FT%T.%NZ
  echo "launcher: setsid nohup timeout -k 30 240 bash $RUNNER (runner sha $(sha256sum "$RUNNER" | cut -c1-16)...)"
  echo "observer: this script, detached with setsid nohup, errexit OFF; writes outer.exit = wait status of timeout"
  LOCK=/home/user/workspace/execution/test-validation.lock
  if [ -e "$LOCK" ]; then lk=$(flock -n "$LOCK" true && echo free || echo BUSY); else lk=absent-not-created-here; fi
  echo "pre-launch: canonical_lock=$lk foreign_node_npm_count=$(pgrep -x -c 'node|npm' 2>/dev/null || echo 0) worktree_porcelain=$(git -C /home/user/workspace/worktrees/s6-diagnostic status --porcelain 2>/dev/null | wc -l) head=$(git -C /home/user/workspace/worktrees/s6-diagnostic rev-parse HEAD 2>/dev/null)"
} > "$LOGS/LAUNCH_START.txt"
setsid nohup bash -c '
  set +e
  LOGS="$1"; RUNNER="$2"
  echo "observer_pid=$$ pgid=$(ps -o pgid= $$ | tr -d " ") sid=$(ps -o sid= $$ | tr -d " ")" >> "$LOGS/LAUNCH_START.txt"
  setsid nohup timeout -k 30 240 bash "$RUNNER" > "$LOGS/run-c6.out" 2>&1 < /dev/null
  rc=$?
  printf "%s\n" "$rc" > "$LOGS/outer.exit"
  echo "$(date -u +%FT%TZ) outer wait status of timeout=$rc (124=external bound hit, 137=KILL after -k; the runner FINAL line and step=C first_exit are separate inner records)" >> "$LOGS/LAUNCH_END.txt"
' observer "$LOGS" "$RUNNER" > "$LOGS/observer.out" 2>&1 < /dev/null &
echo "observer launched (background pid $!); topology recorded in $LOGS/LAUNCH_START.txt; outer status will appear in $LOGS/outer.exit"
