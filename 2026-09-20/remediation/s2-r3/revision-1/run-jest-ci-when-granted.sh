#!/usr/bin/env bash
# Heavy-run wrapper for the granted test slot. Revision 3 (SLOT D, 23:27Z): attempt 1 (rev 2, NODE_PATH only) failed at
# ts-jest type-check — TypeScript resolves @types via node_modules/ walking up from the spec, which NODE_PATH does not
# affect (4 suites, TS2582/TS2304 "Cannot find name it/expect/jest", 0 tests run). Rev 3 requires the CI layout instead:
# <worktree>/node_modules must be a SYMLINK to $SHARED_ROOT/node_modules (git-ignored; no install; shared tree read-only).
# Runs test/ci on the exact frozen S2 head using S1's shared read-only npm-ci tree.
# Fails closed on: lock busy, wrong/dirty head, shared tree root manifests differing from S2's, missing jest,
# cd failure, existing attempt log. Preserves the child exit code (timeout → 124). No install, no writes to the
# shared tree, no hosted calls.
set -uo pipefail
WT=/home/user/workspace/worktrees/s2-r3
EXPECT_HEAD=${EXPECT_HEAD:-e15e25c28824b43558f7c231eec26a5ac64bafa9}
SHARED_ROOT="${SHARED_ROOT:?set to the root of the S1 npm-ci checkout (contains package.json, package-lock.json, node_modules/)}"
OUTER_TIMEOUT="${OUTER_TIMEOUT:-1500}"   # seconds; generous, test/ci is fixture-driven
LOGDIR=/home/user/workspace/execution/s2-r3/logs
STAMP=$(date -u +%Y%m%dT%H%M%SZ)
OUT="$LOGDIR/jest-test-ci-at-${EXPECT_HEAD:0:8}-attempt-${STAMP}.log"
[ -e "$OUT" ] && { echo "attempt log already exists: $OUT — refusing to overwrite" >&2; exit 5; }
exec 9>/home/user/workspace/execution/test-validation.lock
if ! flock -n 9; then echo "lock busy at $STAMP; refusing to wait" | tee "$OUT" >&2; exit 3; fi
run() {
  echo "start=$(date -u +%FT%TZ) attempt=$STAMP"
  local head; head=$(git -C "$WT" rev-parse HEAD) || { echo "cannot read head"; return 4; }
  local tree clean; tree=$(git -C "$WT" rev-parse 'HEAD^{tree}'); clean=$([ -z "$(git -C "$WT" status --porcelain)" ] && echo yes || echo no)
  echo "head=$head tree=$tree clean=$clean"
  [ "$head" = "$EXPECT_HEAD" ] || { echo "HEAD is not the frozen S2 R3 head $EXPECT_HEAD; refusing"; return 4; }
  [ -z "$(git -C "$WT" status --porcelain)" ] || { echo "worktree dirty; refusing"; return 4; }
  echo "shared_root=$SHARED_ROOT"
  for f in package.json package-lock.json; do
    if cmp -s "$SHARED_ROOT/$f" "$WT/$f"; then echo "cmp $f: identical (sha256 $(sha256sum "$WT/$f" | cut -c1-16))"
    else echo "cmp $f: DIFFERS between shared root and S2 worktree; refusing"; return 6; fi
  done
  local NM="$SHARED_ROOT/node_modules" JEST="$SHARED_ROOT/node_modules/jest/bin/jest.js"
  if [ -L "$WT/node_modules" ] && [ "$(readlink -f "$WT/node_modules")" = "$(readlink -f "$NM")" ]; then echo "layout: $WT/node_modules -> $(readlink "$WT/node_modules") (symlink to shared tree)"
  else echo "layout: $WT/node_modules is not a symlink to $NM; refusing (no install performed)"; return 6; fi
  [ -d "$NM" ] || { echo "shared node_modules missing: $NM"; return 6; }
  [ -f "$JEST" ] || { echo "jest entrypoint missing: $JEST"; return 6; }
  if ! { [ -d "$NM/ts-jest" ] && [ -d "$NM/js-yaml" ]; }; then echo "ts-jest or js-yaml missing in shared tree"; return 6; fi
  echo "node=$(node --version) npm=$(npm --version) jest=$(node "$JEST" --version 2>/dev/null || echo unknown)"
  echo "toolchain: shellcheck/actionlint not involved; bash $BASH_VERSION"
  cd "$WT" || { echo "cd $WT failed"; return 4; }
  echo "command: timeout --foreground -k 30 $OUTER_TIMEOUT node $JEST --ci --runInBand test/ci"
  timeout --foreground -k 30 "$OUTER_TIMEOUT" node "$JEST" --ci --runInBand test/ci; local rc=$?
  [ "$rc" -eq 124 ] && echo "TIMEOUT after ${OUTER_TIMEOUT}s (exit 124 preserved)"
  echo "jest exit=$rc"
  echo "post-run clean=$([ -z "$(git status --porcelain)" ] && echo yes || echo no) head=$(git rev-parse HEAD) end=$(date -u +%FT%TZ)"
  return "$rc"
}
run 2>&1 | tee "$OUT"; rc=${PIPESTATUS[0]}
flock -u 9
echo "wrapper exit=$rc log=$OUT" | tee -a "$OUT"
exit "$rc"
