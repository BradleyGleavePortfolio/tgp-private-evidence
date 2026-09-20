#!/bin/bash
# Runs the S6 validation sequence under the shared nonblocking lock. Every
# command's full output is kept, pass or fail.
set -u
export PATH=/home/user/workspace/execution/s6-mobile-r2/toolchain/node-v22.13.1-linux-x64/bin:$PATH
export CI=true
cd /home/user/workspace/worktrees/s6
LOG=/home/user/workspace/execution/s6-mobile-r2/logs
run() { name=$1; shift; echo "== $name: $* ($(date -u +%FT%TZ))" | tee -a $LOG/summary.txt; "$@" > $LOG/$name.log 2>&1; rc=$?; echo "   exit=$rc ($(date -u +%FT%TZ))" | tee -a $LOG/summary.txt; return $rc; }
exec 9>/home/user/workspace/execution/test-validation.lock
flock -n 9 || { echo "LOCK_HELD $(date -u)" | tee -a $LOG/summary.txt; exit 3; }
echo "lock acquired $(date -u +%FT%TZ) pid $$" >> $LOG/lock-holder.txt
node --version; npm --version
run 00-npm-ci npm ci --no-audit --no-fund
echo "released $(date -u +%FT%TZ)" >> $LOG/lock-holder.txt
