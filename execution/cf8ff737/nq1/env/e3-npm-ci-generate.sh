#!/usr/bin/env bash
# N/Q1 v2r Phase E steps 3+4 — isolated node_modules for worktrees/s7-nq1 from the committed lock
# (receipt-02/03 method: lock sha 05bc530a…, then N-only prisma generate, client index.d.ts 92d42c56…),
# under the heavy-slot lock execution/test-validation.lock (flock -n; exit 75 if busy).
set -euo pipefail
ROOT=/home/user/workspace; LOCK=$ROOT/execution/test-validation.lock; WT=$ROOT/worktrees/s7-nq1
sha(){ sha256sum "$1" | cut -c1-64; }
EXPECT_HEAD=61b93cff7900b24c17011d481fd6c31f5abb59e4
EXPECT_PKG_LOCK=b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55   # package-lock.json (receipt 02)
EXPECT_NM_LOCK=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44    # node_modules/.package-lock.json (receipt 02)
EXPECT_CLIENT=92d42c56a7f199d41ea518c1f5b9a8c17f34a17f97486942f2691026a1461cf4     # .prisma/client/index.d.ts after N generate (receipt 03)
EXPECT_ENGINE=a2924eab1c78a0a7bb67edac5738939fa10589ef073af5542f53812a22e4a7d8     # engine pin (receipt 03)
exec 9>"$LOCK"; flock -n 9 || { echo "validation lock busy ($LOCK); not waiting"; exit 75; }
echo "== e3-npm-ci-generate start_utc=$(date -u +%FT%TZ) pid=$$ lock=$LOCK(held nonblocking)"
cd "$WT"
HEAD=$(git rev-parse HEAD); echo "head=$HEAD tree=$(git rev-parse HEAD^{tree})"
[ "$HEAD" = "$EXPECT_HEAD" ] || { echo "head is not $EXPECT_HEAD; refusing"; exit 70; }
[ -z "$(git status --porcelain --untracked-files=all)" ] || { echo "worktree dirty; refusing"; exit 70; }
echo "package_lock_sha256=$(sha package-lock.json) expected=$EXPECT_PKG_LOCK"
[ "$(sha package-lock.json)" = "$EXPECT_PKG_LOCK" ] || { echo "package-lock sha != receipt-02; refusing"; exit 70; }
[ -e node_modules ] && { echo "node_modules already present; refusing"; exit 70; }
export PRISMA_GENERATE_SKIP_AUTOINSTALL=1
OUTSIDE_BEFORE="nm=$(ls -1 /home/user/node_modules 2>/dev/null | wc -l) prisma_outside=$([ -e /home/user/node_modules/prisma ] || [ -e /home/user/node_modules/@prisma ] && echo PRESENT || echo absent)"
echo "outside_root_before: $OUTSIDE_BEFORE"; echo "npm=$(npm --version) node=$(node --version)"; df -h / | tail -1
set +e; timeout --foreground 1500 npm ci --ignore-scripts --no-audit --no-fund --loglevel=error; rc=$?; set -e
echo "npm_ci_exit=$rc utc=$(date -u +%FT%TZ)"; [ $rc -eq 0 ] || exit $rc
NM_LOCK=$(sha node_modules/.package-lock.json); echo "nm_hidden_lock_sha256=$NM_LOCK expected=$EXPECT_NM_LOCK"
[ "$NM_LOCK" = "$EXPECT_NM_LOCK" ] || { echo "STOP: node_modules/.package-lock.json sha mismatch"; exit 70; }
[ -f node_modules/prisma/build/index.js ] && [ -d node_modules/@prisma/client ] || { echo "REFUSED: prisma cli/client missing after npm ci"; exit 70; }
echo "pre_client_index_d_ts=$( [ -f node_modules/.prisma/client/index.d.ts ] && sha node_modules/.prisma/client/index.d.ts || echo absent)"
echo "prisma_version=$(node node_modules/prisma/build/index.js --version | tr '\n' ' ')"
set +e; timeout --foreground 600 node node_modules/prisma/build/index.js generate --schema prisma/schema.prisma; rc=$?; set -e
echo "prisma_generate_exit=$rc utc=$(date -u +%FT%TZ)"; [ $rc -eq 0 ] || exit $rc
CLIENT=$(sha node_modules/.prisma/client/index.d.ts); echo "post_client_index_d_ts=$CLIENT expected=$EXPECT_CLIENT"
[ "$CLIENT" = "$EXPECT_CLIENT" ] || { echo "STOP: .prisma/client/index.d.ts sha mismatch"; exit 70; }
ENG=$(ls node_modules/.prisma/client/libquery_engine-*.so.node 2>/dev/null | head -1); [ -n "$ENG" ] && echo "client_engine=$(basename "$ENG") sha256=$(sha "$ENG") expected=$EXPECT_ENGINE"
echo "hidden_lock_after_generate=$(sha node_modules/.package-lock.json)"
echo "outside_root_after:  nm=$(ls -1 /home/user/node_modules 2>/dev/null | wc -l) prisma_outside=$([ -e /home/user/node_modules/prisma ] || [ -e /home/user/node_modules/@prisma ] && echo PRESENT || echo absent)"
echo "clean_after=$([ -z "$(git status --porcelain --untracked-files=all)" ] && echo yes || echo NO) head_after=$(git rev-parse HEAD)"; df -h / | tail -1
echo "== e3-npm-ci-generate end_utc=$(date -u +%FT%TZ) exit=0 (lock released on exit)"
