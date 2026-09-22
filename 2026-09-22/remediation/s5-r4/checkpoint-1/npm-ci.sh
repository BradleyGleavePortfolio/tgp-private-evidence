#!/usr/bin/env bash
# S5 R4 dependency install for worktrees/s5-r4 (revision 3; path successor of the frozen revision 2). S5's own locked tree: package-lock blob
# 354de3da (identical to S3, different from S1/S2) — no substitution of another lane's node_modules.
# Holds the ONE canonical validation lock /home/user/workspace/execution/test-validation.lock
# NON-BLOCKING (flock -n; rc 75 if busy, never queues). Run only when the parent grants the slot.
# Network: npm registry fetch per package-lock.json only (no other remote action).
set -uo pipefail
W=/home/user/workspace/worktrees/s5-r4
X=/home/user/workspace/execution
LOCK=$X/test-validation.lock
TS=$(date -u +%Y%m%dT%H%M%SZ)
LOG=$X/s5-r4/logs/npm-ci-$TS.log
mkdir -p "$(dirname "$LOG")"
EXPECTED_LOCK_BLOB=354de3dae19449970497da6e4d87f0a1225a8f43
# Nothing here may see hosted credentials; prisma generate reads the schema only, never a database.
unset DATABASE_URL DIRECT_URL SHADOW_DATABASE_URL TEST_DATABASE_URL SUPABASE_URL SUPABASE_ANON_KEY SUPABASE_SERVICE_ROLE_KEY SUPABASE_DB_URL

blob=$(git -C "$W" rev-parse HEAD:package-lock.json)
[ "$blob" = "$EXPECTED_LOCK_BLOB" ] || { echo "package-lock blob $blob != expected $EXPECTED_LOCK_BLOB; refusing" | tee -a "$LOG"; exit 2; }
git -C "$W" diff --quiet HEAD -- package.json package-lock.json || { echo "package.json/package-lock.json dirty in $W; refusing" | tee -a "$LOG"; exit 2; }

exec 9>"$LOCK"
flock -n 9 || { echo "$(date -u +%FT%TZ) test-validation.lock busy; S5-R3 npm-ci not queueing (rc 75)" | tee -a "$LOG"; exit 75; }
echo "$(date -u +%FT%TZ) HOLDER=s5-r4 PURPOSE=npm-ci pid=$$" >> "$X/test-validation.lock.log"
{
  echo "TS=$TS START=$(date -u +%FT%TZ) RUNNER=s5-r4-npm-ci REV=3"
  echo "HEAD=$(git -C "$W" rev-parse HEAD) TREE=$(git -C "$W" rev-parse HEAD^{tree}) CLEAN=$([ -z "$(git -C "$W" status --porcelain)" ] && echo yes || echo no)"
  git -C "$W" status --porcelain
  echo "PACKAGE_LOCK_BLOB=$blob node $(node -v) npm $(npm -v)"
  echo "CMD (cwd=$W): npm ci --no-audit --no-fund --ignore-scripts; then ./node_modules/.bin/prisma generate"
} | tee -a "$LOG"
( cd "$W" && exec npm ci --no-audit --no-fund --ignore-scripts 9>&- ) >> "$LOG" 2>&1; rc=$?
echo "$(date -u +%FT%TZ) npm ci exit $rc" | tee -a "$LOG"
if [ $rc -eq 0 ]; then
  ( cd "$W" && exec ./node_modules/.bin/prisma generate 9>&- ) >> "$LOG" 2>&1; rc=$?
  echo "$(date -u +%FT%TZ) prisma generate exit $rc" | tee -a "$LOG"
  echo "NODE_MODULES_PACKAGE_LOCK_SHA256=$(sha256sum "$W/node_modules/.package-lock.json" | cut -c1-64)" | tee -a "$LOG"
fi
echo "$(date -u +%FT%TZ) RELEASE=s5-r4 stage=npm-ci rc=$rc" >> "$X/test-validation.lock.log"
echo "PROOF_EXIT=$rc STAGE=npm-ci TS=$TS END=$(date -u +%FT%TZ)" | tee -a "$LOG" | tee "$X/s5-r4/logs/exit-npm-ci-$TS.log"
exit "$rc"
