#!/bin/bash
set -u
export PATH=/home/user/workspace/execution/s6-mobile-r2/toolchain/node-v22.13.1-linux-x64/bin:$PATH
export CI=true
LOG=/home/user/workspace/execution/s6-mobile-r2/logs
cd /home/user/workspace/execution/s6-mobile-r2/baseline-probe/main-a5933fd6
exec 9>/home/user/workspace/execution/test-validation.lock
flock -w 600 9 || { echo "LOCK_HELD" | tee -a $LOG/summary.txt; exit 3; }
echo "== 10-baseline-main-a5933fd6-jest-full: timeout 420 npx jest --ci (git archive of main, node_modules symlinked) ($(date -u +%FT%TZ))" | tee -a $LOG/summary.txt
timeout 420 npx jest --ci > $LOG/10-baseline-main-a5933fd6-jest-full.log 2>&1
echo "   exit=$? (124 = killed by timeout after results) ($(date -u +%FT%TZ))" | tee -a $LOG/summary.txt
