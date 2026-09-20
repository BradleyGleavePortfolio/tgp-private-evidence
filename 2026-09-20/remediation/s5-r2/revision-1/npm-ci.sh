#!/usr/bin/env bash
set -uo pipefail
LOCK=/home/user/workspace/execution/heavy-validation.lock
LOG=/home/user/workspace/execution/s5-g2/logs/npm-ci.log
exec 9>"$LOCK"
echo "$(date -u +%FT%TZ) S5 waiting for heavy lock (npm ci)" >> "$LOG"
flock 9
echo "$(date -u +%FT%TZ) S5 HOLDS heavy lock: npm ci in worktrees/s5-g2 (postinstall prisma generate)" | tee -a "$LOG" >> "$LOCK.holder"
cd /home/user/workspace/worktrees/s5-g2
npm ci --no-audit --no-fund --ignore-scripts >> "$LOG" 2>&1; rc=$?
echo "$(date -u +%FT%TZ) npm ci exit $rc" >> "$LOG"
if [ $rc -eq 0 ]; then ./node_modules/.bin/prisma generate >> "$LOG" 2>&1; echo "$(date -u +%FT%TZ) prisma generate exit $?" >> "$LOG"; fi
echo "$(date -u +%FT%TZ) S5 RELEASED heavy lock (npm ci)" | tee -a "$LOG" >> "$LOCK.holder"
flock -u 9
