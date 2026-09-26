#!/usr/bin/env bash
set -uo pipefail; R=/home/user/workspace/worktrees/d3a9-s9c-r2; EVS=/home/user/workspace/private-evidence/execution/d3a9f701/s9c/fix-r11; F=test/rls-g2-s9c.spec.ts
LOCK=/home/user/workspace/execution/test-validation.lock; [ "$(stat -c %i $LOCK)" = 692282 ] || exit 75; exec 9>>"$LOCK"; flock -n 9 || { echo "LOCK busy"; exit 75; }; echo "LOCK acquired $(date -u +%FT%TZ)"; cd $R
export NODE_OPTIONS=--max-old-space-size=4096; P="env npm_config_prefix=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 npm_config_offline=true npx --no-install prettier"
$P --check $F > $EVS/prettier.log 2>&1; echo "PRETTIER_CHECK rc=$?"
./node_modules/.bin/eslint --no-warn-ignored --max-warnings 0 $F > $EVS/eslint.log 2>&1; echo "ESLINT rc=$?"
timeout 900 ./node_modules/.bin/tsc --noEmit -p tsconfig.json > $EVS/tsc.log 2>&1; echo "TSC rc=$? lines=$(wc -l < $EVS/tsc.log)"
git add -- $F; node scripts/check-r75.js --mode=staged > $EVS/r75.log 2>&1; echo "R75_STAGED rc=$?"; git reset -q; [ -z "$(git diff --cached --name-only)" ] && echo INDEX_CLEAN
echo "SPEC_SHA $(sha256sum $F | cut -c1-64)"; echo "END $(date -u +%FT%TZ)"
