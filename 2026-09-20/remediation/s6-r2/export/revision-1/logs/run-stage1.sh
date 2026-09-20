#!/bin/bash
# Stage 1: lint, typecheck, focused jest (storage/config/auth/userCache/navigation) on the working tree.
set -u
export PATH=/home/user/workspace/execution/s6-mobile-r2/toolchain/node-v22.13.1-linux-x64/bin:$PATH
export CI=true
cd /home/user/workspace/worktrees/s6-export
LOG=/home/user/workspace/execution/s6-export-r2/logs
exec 9>/home/user/workspace/execution/test-validation.lock
flock -n 9 || { echo "LOCK_HELD $(date -u +%FT%TZ)" | tee -a $LOG/summary.txt; exit 3; }
echo "stage1 lock acquired $(date -u +%FT%TZ) pid $$ (s6-export fixer)" >> $LOG/lock-holder.txt
run() { name=$1; shift; echo "== $name: $* ($(date -u +%FT%TZ))" | tee -a $LOG/summary.txt; "$@" > $LOG/$name.log 2>&1; rc=$?; echo "   exit=$rc ($(date -u +%FT%TZ))" | tee -a $LOG/summary.txt; return $rc; }
echo "HEAD=$(git rev-parse HEAD) TREE=$(git rev-parse HEAD^{tree}) status_lines=$(git status --short | wc -l) node=$(node --version)" | tee -a $LOG/summary.txt
run 01-lint npm run lint
run 02-tsc npx tsc --noEmit
run 03-jest-focused npx jest --ci src/storage src/config src/services/__tests__/authActions.test.ts src/services/__tests__/authActions.signOut.test.ts src/services/__tests__/queryClient.signout.test.ts src/lib src/navigation src/__tests__/biometricLockService.test.ts src/screens/coach/ed/__tests__/firstPaymentGate.test.ts src/screens/client/__tests__/MessagesScreenCache.test.ts
echo "stage1 released $(date -u +%FT%TZ)" >> $LOG/lock-holder.txt
