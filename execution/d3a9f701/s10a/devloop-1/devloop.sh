#!/usr/bin/env bash
set -uo pipefail; C=/home/user/workspace/worktrees/d3a9-s10a; EV=/home/user/workspace/private-evidence/execution/d3a9f701/s10a/devloop-1
LOCK=/home/user/workspace/execution/test-validation.lock; [ "$(stat -c %i $LOCK)" = 692282 ] || exit 75; exec 9>>"$LOCK"; flock -n 9 || { echo "LOCK busy"; exit 75; }; echo "LOCK acquired $(date -u +%FT%TZ)"; cd $C
[ -e node_modules ] || cp -a /home/user/workspace/worktrees/1910a060-s8f/node_modules node_modules
export NODE_OPTIONS=--max-old-space-size=4096 npm_config_prefix=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 npm_config_offline=true
ALL=$(git status --porcelain --untracked-files=all | awk '{print $2}' | grep -v '^node_modules')
for f in $ALL; do mkdir -p $EV/preformat/$(dirname $f); cp -p $f $EV/preformat/$f; done
F=$(printf '%s\n' $ALL | grep -E '\.(ts|cjs|md|json)$' | tr '\n' ' ')
npx --no-install prettier --write $F > $EV/prettier.log 2>&1; echo "PRETTIER rc=$?"; for f in $ALL; do cmp -s $f $EV/preformat/$f || echo "REFLOWED $f"; done
timeout 900 ./node_modules/.bin/tsc --noEmit -p tsconfig.json > $EV/tsc.log 2>&1; echo "TSC rc=$? lines=$(wc -l < $EV/tsc.log)"
L=$(printf '%s\n' $ALL | grep -E '\.(ts|cjs)$' | tr '\n' ' '); ./node_modules/.bin/eslint --no-warn-ignored --max-warnings 0 $L > $EV/eslint.log 2>&1; echo "ESLINT rc=$?"
git add -- $ALL; node scripts/check-r75.js --mode=staged > $EV/r75-staged.log 2>&1; echo "R75_STAGED rc=$?"; git reset -q; [ -z "$(git diff --cached --name-only)" ] && echo INDEX_CLEAN
S=$(printf '%s\n' $ALL | grep -E '^test/scout/induction/.*\.spec\.ts$' | tr '\n' ' '); echo "SUITES $S"
timeout 900 ./node_modules/.bin/jest --ci --runTestsByPath $S > $EV/jest.log 2>&1; echo "JEST rc=$?"; grep -E '^(Tests|Test Suites):' $EV/jest.log
for f in $ALL; do echo "POST $(sha256sum $f | cut -c1-64) $f"; done > $EV/POSTFORMAT.sha256; echo "END $(date -u +%FT%TZ)"
