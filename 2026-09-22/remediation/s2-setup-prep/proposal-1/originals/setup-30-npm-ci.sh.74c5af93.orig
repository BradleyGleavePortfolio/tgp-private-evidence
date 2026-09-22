#!/usr/bin/env bash
# Copied from the S1 R3 evidence packet (infra/setup-30-npm-ci.sh); retargeted to worktrees/s2-composition and the composition head. Same lockfile hash 62b05b90… (identical at S1 head, S2 head, base and merge).
# Step 30: ONE locked backend dependency tree for S1 and S2 (identical package.json/package-lock graph,
# parent-verified sha256 62b05b90…1390 / blob a23abae6). Installed into worktrees/s1-r3 (node_modules is
# git-ignored, so the worktree stays clean). --ignore-scripts, then an explicit `prisma generate` as in
# R2. S2 consumes read-only: S1_PRISMA_CLI=/home/user/workspace/worktrees/s1-r3/node_modules/prisma/build/index.js
# (or `node <that path> …`). No standalone Prisma install anywhere else.
. "$(dirname "$0")/_common.sh"; step_begin setup-30-npm-ci
WT=$ROOT/worktrees/s2-composition; cd "$WT"
EXPECT_LOCK=62b05b908c835dae51e54af1e553d91f763a070da21813c4419d66e018d61390   # parent-verified full sha256
EXPECT_HEAD=${S2_EXPECT_HEAD:-9742037b153221de565e651ad8ba3b721bc0fb31}   # composition head incl. frozen S1 R4 41f4d6a9; override ONLY with the parent-named frozen head
STAMP=node_modules/.s2-composition-install-stamp
HEAD=$(git rev-parse HEAD)
echo "head=$HEAD clean_before=$([ -z "$(git status --porcelain --untracked-files=all)" ] && echo yes || echo NO)"
[ "$HEAD" = "$EXPECT_HEAD" ] || { echo "head is not $EXPECT_HEAD; refusing"; exit 70; }
LOCKSHA=$(sha package-lock.json); echo "package_lock_sha256=$LOCKSHA package_json_sha256=$(sha package.json)"
[ "$LOCKSHA" = "$EXPECT_LOCK" ] || { echo "package-lock sha256 != parent-verified $EXPECT_LOCK; refusing"; exit 70; }
[ -z "$(git status --porcelain --untracked-files=all)" ] || { echo "worktree dirty; refusing"; exit 70; }
# Existing node_modules is accepted ONLY with this script's own successful-install stamp for this
# exact head+lock; anything else (files merely present) gets a fresh, bounded npm ci.
if [ -f "$STAMP" ] && grep -qx "head=$EXPECT_HEAD" "$STAMP" && grep -qx "lock=$EXPECT_LOCK" "$STAMP" && grep -qx "result=success" "$STAMP" \
   && [ -f node_modules/prisma/build/index.js ] && [ "$(grep '^prisma_cli_sha256=' "$STAMP" | cut -d= -f2)" = "$(sha node_modules/prisma/build/index.js)" ]; then
  echo "node_modules accepted via attributable stamp:"; sed 's/^/  stamp: /' "$STAMP"
else
  [ -d node_modules ] && echo "node_modules present WITHOUT valid stamp -> fresh npm ci (npm ci removes it first)"
  rm -f "$STAMP"
  echo "npm=$(npm --version) node=$(node --version)"
  set +e; timeout --foreground 1500 npm ci --ignore-scripts --no-audit --no-fund --loglevel=error; rc=$?; set -e
  echo "npm_ci_exit=$rc"; [ $rc -eq 0 ] || exit $rc
fi
set +e; timeout --foreground 600 node node_modules/prisma/build/index.js generate --schema prisma/schema.prisma; rc=$?; set -e
echo "prisma_generate_exit=$rc"; [ $rc -eq 0 ] || exit $rc
{ echo "head=$EXPECT_HEAD"; echo "lock=$EXPECT_LOCK"; echo "prisma_cli_sha256=$(sha node_modules/prisma/build/index.js)"; echo "installed_by=execution/s2-composition/infra/setup-30-npm-ci.sh"; echo "utc=$(date -u +%FT%TZ)"; echo "log=$STEP_LOG"; echo "result=success"; } > "$STAMP"
echo "stamp_written=$STAMP"
echo "prisma_cli=$WT/node_modules/prisma/build/index.js"
echo "prisma_cli_sha256=$(sha node_modules/prisma/build/index.js)"
echo "prisma_version=$(node node_modules/prisma/build/index.js --version | tr '\n' ' ')"
echo "prisma_pkg_version=$(node -p "require('./node_modules/prisma/package.json').version") client_pkg_version=$(node -p "require('./node_modules/@prisma/client/package.json').version")"
echo "installed_lock_sha256=$(sha node_modules/.package-lock.json) node_modules_dirs=$(find node_modules -maxdepth 1 -mindepth 1 | wc -l)"
echo "clean_after=$([ -z "$(git status --porcelain --untracked-files=all)" ] && echo yes || echo NO) head_after=$(git rev-parse HEAD)"
[ -z "$(git status --porcelain --untracked-files=all)" ] || { echo "install dirtied the worktree; refusing"; exit 70; }
step_end
