#!/usr/bin/env bash
# Heavy-run wrapper for the granted test slot. NOT RUN by the S2 R3 fixer.
# Runs test/ci on the exact frozen S2 head using S1's shared read-only npm-ci tree
# (package.json/package-lock.json blobs are byte-identical across S1 7cbbb039, S2 1c6db2b6, base c23b9d9f).
# Preserves the child exit code, fails closed, stamps head/tree/clean/toolchain/command/start/end.
set -uo pipefail
WT=/home/user/workspace/worktrees/s2-r3
SHARED_NM="${SHARED_NODE_MODULES:?set to S1's node_modules dir (read-only share)}"
OUT=/home/user/workspace/execution/s2-r3/logs/jest-test-ci-at-$(git -C "$WT" rev-parse --short=8 HEAD).log
exec 9>/home/user/workspace/execution/test-validation.lock
flock -n 9 || { echo "lock busy; refusing to wait" | tee "$OUT"; exit 3; }
{
  echo "start=$(date -u +%FT%TZ)"
  echo "head=$(git -C "$WT" rev-parse HEAD) tree=$(git -C "$WT" rev-parse HEAD^{tree}) clean=$([ -z "$(git -C "$WT" status --porcelain)" ] && echo yes || echo no)"
  [ "$(git -C "$WT" rev-parse HEAD)" = "1c6db2b68c3521fbdf7c0f468b1f52d0152a16b9" ] || { echo "HEAD is not the frozen S2 R3 head; refusing"; exit 4; }
  [ -z "$(git -C "$WT" status --porcelain)" ] || { echo "worktree dirty; refusing"; exit 4; }
  echo "node=$(node --version) npm=$(npm --version) shared_node_modules=$SHARED_NM"
  echo "shared tree lock check: $(sha256sum "$SHARED_NM/.package-lock.json" 2>/dev/null | cut -c1-16) vs S2 package-lock blob a23abae6"
  cd "$WT"
  echo "command: NODE_PATH=$SHARED_NM node $SHARED_NM/jest/bin/jest.js --ci --runInBand test/ci"
  NODE_PATH="$SHARED_NM" node "$SHARED_NM/jest/bin/jest.js" --ci --runInBand test/ci; rc=$?
  echo "jest exit=$rc"
  echo "post-run clean=$([ -z "$(git status --porcelain)" ] && echo yes || echo no) end=$(date -u +%FT%TZ)"
  exit $rc
} 2>&1 | tee "$OUT"
rc=${PIPESTATUS[0]}; flock -u 9; exit "$rc"
