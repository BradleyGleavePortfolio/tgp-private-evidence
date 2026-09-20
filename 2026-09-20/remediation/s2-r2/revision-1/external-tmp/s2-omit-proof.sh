#!/usr/bin/env bash
LOCK=/home/user/workspace/execution/heavy-validation.lock
cd /tmp/s2-omit || exit 1
exec 9>>"$LOCK"
flock -w 7200 9 || { echo "lock timeout" > /tmp/s2-omit-ci.log; exit 1; }
echo "S2-delivery npm ci --omit=dev proof (/tmp/s2-omit) pid=$$ since $(date -u +%FT%TZ)" > "$LOCK"
npm ci --omit=dev --ignore-scripts --no-audit --no-fund > /tmp/s2-omit-ci.log 2>&1
echo "exit=$?" >> /tmp/s2-omit-ci.log
echo "released by S2-delivery at $(date -u +%FT%TZ)" > "$LOCK"
