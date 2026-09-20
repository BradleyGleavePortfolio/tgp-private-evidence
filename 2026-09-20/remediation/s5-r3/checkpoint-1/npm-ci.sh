#!/usr/bin/env bash
# S5 R3 dependency install for worktrees/s5-r3 (S5's own locked tree: package-lock blob 354de3da, identical to S3,
# different from S1/S2 — no substitution of another lane's node_modules). Holds the heavy lock NON-BLOCKING; if busy,
# exits 75 immediately for the parent to reschedule. Run only when the parent grants a heavy slot.
set -uo pipefail
LOCK=/home/user/workspace/execution/heavy-validation.lock
LOG=/home/user/workspace/execution/s5-r3/logs/npm-ci-$(date -u +%Y%m%dT%H%M%SZ).log
mkdir -p "$(dirname "$LOG")"
exec 9>"$LOCK"
flock -n 9 || { echo "$(date -u +%FT%TZ) heavy lock busy; S5-R3 not queueing (rc 75)" | tee -a "$LOG"; exit 75; }
echo "$(date -u +%FT%TZ) S5-R3 HOLDS heavy lock: npm ci --ignore-scripts + prisma generate in worktrees/s5-r3" | tee -a "$LOG" >> "$LOCK.holder"
cd /home/user/workspace/worktrees/s5-r3 || exit 1
{ echo "HEAD=$(git rev-parse HEAD) TREE=$(git rev-parse HEAD^{tree})"; git status --short; echo "lock blob $(git rev-parse HEAD:package-lock.json)"; node -v; npm -v; } >> "$LOG"
npm ci --no-audit --no-fund --ignore-scripts >> "$LOG" 2>&1; rc=$?
echo "$(date -u +%FT%TZ) npm ci exit $rc" >> "$LOG"
if [ $rc -eq 0 ]; then ./node_modules/.bin/prisma generate >> "$LOG" 2>&1; rc=$?; echo "$(date -u +%FT%TZ) prisma generate exit $rc" >> "$LOG"; fi
echo "$(date -u +%FT%TZ) S5-R3 RELEASED heavy lock rc=$rc" | tee -a "$LOG" >> "$LOCK.holder"
flock -u 9
exit "$rc"
