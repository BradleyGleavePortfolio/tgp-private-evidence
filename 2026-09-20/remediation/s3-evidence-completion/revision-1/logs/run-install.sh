#!/bin/bash
LOCK=/home/user/workspace/execution/heavy-validation.lock
LOG=/home/user/workspace/execution/s3-backend/logs/01-npm-ci.log
cd /home/user/workspace/worktrees/s3-backend
exec 9>"$LOCK"
echo "[$(date -u +%FT%TZ)] S3 waiting for heavy lock (npm ci --ignore-scripts)" >> "$LOG"
flock 9
echo "S3-backend npm ci --ignore-scripts pid=$$ since $(date -u +%FT%TZ)" > "$LOCK"
echo "[$(date -u +%FT%TZ)] S3 acquired heavy lock" >> "$LOG"
npm ci --ignore-scripts --no-audit --no-fund >> "$LOG" 2>&1
echo "[$(date -u +%FT%TZ)] npm ci exit=$?" >> "$LOG"
PRISMA_HIDE_UPDATE_MESSAGE=1 npx prisma generate >> "$LOG" 2>&1
echo "[$(date -u +%FT%TZ)] prisma generate exit=$?" >> "$LOG"
: > "$LOCK"
echo "[$(date -u +%FT%TZ)] S3 released heavy lock" >> "$LOG"
