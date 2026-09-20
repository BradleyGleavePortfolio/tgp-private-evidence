#!/usr/bin/env bash
# Parent resource exception (09:40 PDT): install-only secondary lock, one extra install.
set -uo pipefail
LOCK=/home/user/workspace/execution/install-secondary.lock
LOG=/home/user/workspace/execution/s5-g2/logs/npm-ci.log
exec 9>"$LOCK"
echo "$(date -u +%FT%TZ) S5 waiting for install-secondary lock (npm ci)" >> "$LOG"
flock 9
echo "$(date -u +%FT%TZ) HOLDER=s5-g2 PURPOSE=npm-ci-s5-worktree (install-secondary.lock, parent exception)" | tee -a "$LOG" >> /home/user/workspace/execution/heavy-validation.lock.log
cd /home/user/workspace/worktrees/s5-g2
npm ci --no-audit --no-fund --ignore-scripts >> "$LOG" 2>&1; rc=$?
echo "$(date -u +%FT%TZ) npm ci exit $rc" >> "$LOG"
if [ $rc -eq 0 ]; then ./node_modules/.bin/prisma generate >> "$LOG" 2>&1; echo "$(date -u +%FT%TZ) prisma generate exit $?" >> "$LOG"; fi
echo "$(date -u +%FT%TZ) RELEASE=s5-g2 (install-secondary.lock) npm rc=$rc" | tee -a "$LOG" >> /home/user/workspace/execution/heavy-validation.lock.log
flock -u 9
