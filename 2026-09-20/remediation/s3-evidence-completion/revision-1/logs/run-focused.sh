#!/bin/bash
# S3 focused validation on the cumulative candidate. Serialized through the shared heavy lock.
# Usage: run-focused.sh <label> <jest args...>
set -u
LOCK=/home/user/workspace/execution/heavy-validation.lock
LABEL="$1"; shift
LOG=/home/user/workspace/execution/s3-backend/logs/${LABEL}.log
cd /home/user/workspace/worktrees/s3-backend
exec 9>"$LOCK"
echo "[$(date -u +%FT%TZ)] S3 waiting for heavy lock ($LABEL)" >> "$LOG"
flock 9
echo "S3 $LABEL $(date -u +%FT%TZ)" >> "$LOCK.holders"
{
  echo "label=$LABEL head=$(git rev-parse HEAD) tree=$(git rev-parse HEAD^{tree}) node=$(node -v) npm=$(npm -v) date=$(date -u +%FT%TZ)"
  echo "cmd: $*"
  timeout 1500 "$@" 2>&1
  echo "exit=$?"
} >> "$LOG"
echo "S3 $LABEL released $(date -u +%FT%TZ)" >> "$LOCK.holders"
