#!/bin/bash
# Stage 2: static checks + tests + release export, under the shared lock.
set -u
export PATH=/home/user/workspace/execution/s6-mobile-r2/toolchain/node-v22.13.1-linux-x64/bin:$PATH
export CI=true
cd /home/user/workspace/worktrees/s6
LOG=/home/user/workspace/execution/s6-mobile-r2/logs
run() { name=$1; shift; echo "== $name: $* ($(date -u +%FT%TZ))" | tee -a $LOG/summary.txt; "$@" > $LOG/$name.log 2>&1; rc=$?; echo "   exit=$rc ($(date -u +%FT%TZ))" | tee -a $LOG/summary.txt; return $rc; }
exec 9>/home/user/workspace/execution/test-validation.lock
flock -w 600 9 || { echo "LOCK_HELD $(date -u)" | tee -a $LOG/summary.txt; exit 3; }
echo "stage2 lock acquired $(date -u +%FT%TZ) pid $$" >> $LOG/lock-holder.txt
run 01-validate-config npm run validate:config
run 02-lint npm run lint
run 03-tsc npx tsc --noEmit
run 04-jest-focused npx jest --ci src/config src/hooks/__tests__/useExtensionPairing.test.tsx src/screens/coach src/storage src/navigation
run 05-jest-full npx jest --ci
echo "stage2 released $(date -u +%FT%TZ)" >> $LOG/lock-holder.txt
