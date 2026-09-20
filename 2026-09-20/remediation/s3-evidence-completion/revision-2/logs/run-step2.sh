#!/bin/bash
# S3 validation step, serialized through the shared test lock. Usage: run-step2.sh <label> <cmd...>
set -u
LOCK=/home/user/workspace/execution/test-validation.lock
LABEL="$1"; shift
LOG=/home/user/workspace/execution/s3-backend/logs/${LABEL}.log
cd "${WORKTREE:-/home/user/workspace/worktrees/s3-backend}"
exec 9>"$LOCK"
echo "[$(date -u +%FT%TZ)] S3 waiting for test lock ($LABEL)" >> "$LOG"
flock 9
echo "S3 $LABEL $(date -u +%FT%TZ)" >> "$LOCK.holders"
{
  echo "label=$LABEL cwd=$PWD head=$(git rev-parse HEAD) tree=$(git rev-parse HEAD^{tree}) node=$(node -v) npm=$(npm -v) NODE_OPTIONS='${NODE_OPTIONS:-}' loadavg_before='$(cat /proc/loadavg)' date=$(date -u +%FT%TZ)"
  echo "cmd: $*"
  timeout ${STEP_TIMEOUT:-1500} "$@" 2>&1
  echo "exit=$? loadavg_after='$(cat /proc/loadavg)' date=$(date -u +%FT%TZ)"
} >> "$LOG"
echo "S3 $LABEL released $(date -u +%FT%TZ)" >> "$LOCK.holders"
