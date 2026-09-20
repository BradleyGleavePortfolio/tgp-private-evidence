#!/bin/bash
# Full default jest suite, CI-documented heap (NODE_OPTIONS=--max-old-space-size=4096 in .github/workflows/ci.yml),
# in-band, split into 4 sequential shards so a single process never accumulates the whole suite's ts-jest state.
cd /home/user/workspace/worktrees/s3-backend
export NODE_OPTIONS=--max-old-space-size=4096
overall=0
for s in 1 2 3 4; do
  echo "=== shard $s/4 start $(date -u +%FT%TZ) load=$(cat /proc/loadavg)"
  npx jest --ci --maxWorkers=1 --silent --shard=$s/4 2>&1 | rg -v "^\s*$"
  rc=${PIPESTATUS[0]}
  echo "=== shard $s/4 exit=$rc $(date -u +%FT%TZ)"
  [ $rc -ne 0 ] && overall=1
done
echo "overall_exit=$overall"
exit $overall
