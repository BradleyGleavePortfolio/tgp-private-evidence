#!/usr/bin/env bash
# S1 replay runner: full prisma migrate deploy onto isolated PG17.6 under the test lock.
set -u
cd /home/user/workspace/execution
exec 9>test-validation.lock
flock -w 1200 9 || { echo "lock timeout" > s1-database/replay-main-c23b9d9.log; exit 1; }
echo "S1 prisma migrate deploy replay (168) $(date -u +%FT%TZ)" >> test-validation.lock.holders
cd ../worktrees/s1-database
export DATABASE_URL="postgresql://postgres:postgres_local_synthetic@127.0.0.1:54321/s1_replay"
export DIRECT_URL="$DATABASE_URL"
node node_modules/prisma/build/index.js migrate deploy > /home/user/workspace/execution/s1-database/replay-main-c23b9d9.log 2>&1
echo "deploy exit=$?" >> /home/user/workspace/execution/s1-database/replay-main-c23b9d9.log
cd /home/user/workspace/execution
echo "S1 replay released $(date -u +%FT%TZ)" >> test-validation.lock.holders
