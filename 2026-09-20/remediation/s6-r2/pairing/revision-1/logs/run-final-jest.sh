#!/bin/bash
set -u
export PATH=/home/user/workspace/execution/s6-mobile-r2/toolchain/node-v22.13.1-linux-x64/bin:$PATH
export CI=true
LOG=/home/user/workspace/execution/s6-mobile-r2/logs
cd /home/user/workspace/worktrees/s6
exec 9>/home/user/workspace/execution/test-validation.lock
flock -w 600 9 || { echo "LOCK_HELD" | tee -a $LOG/summary.txt; exit 3; }
STAMP=$LOG/11-final-clean-head-jest-full.STAMP
{
  echo "HEAD=$(git rev-parse HEAD)"
  echo "TREE=$(git rev-parse HEAD^{tree})"
  echo "BRANCH=$(git rev-parse --abbrev-ref HEAD)"
  echo "STATUS_SHORT_LINES=$(git status --short | wc -l) (0 = clean)"
  echo "NODE=$(node --version) NPM=$(npm --version) NODE_BIN=$(command -v node)"
  echo "JEST=$(npx jest --version)"
  echo "MMKV_STUB_PRESENT=$([ -e node_modules/react-native-mmkv ] && echo yes || echo no)"
  echo "CMD=timeout 660 npx jest --ci"
  echo "START=$(date -u +%FT%TZ)"
} > $STAMP
echo "== 11-final-clean-head-jest-full: timeout 660 npx jest --ci at $(git rev-parse --short HEAD) ($(date -u +%FT%TZ))" | tee -a $LOG/summary.txt
timeout 660 npx jest --ci > $LOG/11-final-clean-head-jest-full.log 2>&1
RC=$?
echo "END=$(date -u +%FT%TZ)" >> $STAMP
echo "CHILD_EXIT=$RC (124 would mean timeout fired)" >> $STAMP
echo "   exit=$RC ($(date -u +%FT%TZ))" | tee -a $LOG/summary.txt
