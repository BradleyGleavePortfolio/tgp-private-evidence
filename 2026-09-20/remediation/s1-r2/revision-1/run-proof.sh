#!/usr/bin/env bash
set -u
OUT=${1:-/home/user/workspace/execution/s1-database/proof-run-05-head-90a6647.log}
cd /home/user/workspace/execution
exec 9>test-validation.lock
flock -w 1500 9 || { echo "lock timeout" > "$OUT"; exit 1; }
echo "S1 rls proof harness $(date -u +%FT%TZ)" >> test-validation.lock.holders
cd ../worktrees/s1-database
S1_PG_SUPER_URL='postgresql://s1_super:s1_local_synthetic@127.0.0.1:54321/postgres' S1_PROOF_LOG="${OUT%.log}.detail.log" \
  nice -n 10 test/db/s1-rls-close-public-exposure.sh s1_rls_proof > "$OUT" 2>&1
echo "harness exit=$?" >> "$OUT"
cd /home/user/workspace/execution
echo "S1 rls proof harness released $(date -u +%FT%TZ)" >> test-validation.lock.holders
