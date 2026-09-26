#!/usr/bin/env bash
set -uo pipefail; C=/home/user/workspace/worktrees/d3a9-s9c-r2; EV=/home/user/workspace/private-evidence/execution/d3a9f701/s9c/devloop-6; F=test/scout/lifecycle/lifecycle.service.spec.ts
LOCK=/home/user/workspace/execution/test-validation.lock; [ "$(stat -c %i $LOCK)" = 692282 ] || exit 75; exec 9>>"$LOCK"; flock -n 9 || { echo "LOCK busy"; exit 75; }; echo "LOCK acquired $(date -u +%FT%TZ)"; cd $C
export NODE_OPTIONS=--max-old-space-size=4096 npm_config_prefix=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 npm_config_offline=true
npx --no-install prettier --write $F >/dev/null 2>&1; npx --no-install prettier --check $F >/dev/null 2>&1; echo "PRETTIER_CHECK rc=$?"
./node_modules/.bin/eslint --no-warn-ignored --max-warnings 0 $F > $EV/eslint.log 2>&1; echo "ESLINT rc=$?"
timeout 900 ./node_modules/.bin/tsc --noEmit -p tsconfig.json > $EV/tsc.log 2>&1; echo "TSC rc=$? lines=$(wc -l < $EV/tsc.log)"
timeout 900 ./node_modules/.bin/jest --ci --runTestsByPath $F > $EV/jest.log 2>&1; echo "JEST rc=$?"; grep -E '^(Tests|Test Suites):' $EV/jest.log
git add -- $F; node scripts/check-r75.js --mode=staged > $EV/r75-staged.log 2>&1; echo "R75_STAGED rc=$?"; tail -3 $EV/r75-staged.log
git reset -q; echo "INDEX_CLEAN=$([ -z "$(git diff --cached --name-only)" ] && echo yes)"; echo "POST $(sha256sum $F | cut -c1-64)"; echo "END $(date -u +%FT%TZ)"
