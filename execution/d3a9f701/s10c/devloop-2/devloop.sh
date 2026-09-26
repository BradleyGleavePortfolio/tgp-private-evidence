#!/usr/bin/env bash
set -uo pipefail; C=/home/user/workspace/worktrees/d3a9-s10c; EV=/home/user/workspace/private-evidence/execution/d3a9f701/s10c/devloop-2; DONOR=/home/user/workspace/worktrees/1910a060-s8f/node_modules
LOCK=/home/user/workspace/execution/test-validation.lock; [ "$(stat -c %i $LOCK)" = 692282 ] || exit 75; exec 9>>"$LOCK"; flock -n 9 || { echo "LOCK busy"; exit 75; }; echo "LOCK acquired $(date -u +%FT%TZ)"; cd $C
export NODE_OPTIONS=--max-old-space-size=4096
F=$(git status --porcelain --untracked-files=all | awk '{print $2}' | grep -v '^node_modules'); for f in $F; do mkdir -p $EV/preformat/$(dirname $f); cp -p $f $EV/preformat/$f; done
[ -e node_modules ] || cp -a $DONOR node_modules; D0=$(sha256sum $DONOR/.prisma/client/index.d.ts | cut -c1-64)
./node_modules/.bin/prisma generate --schema prisma/schema.prisma > $EV/prisma-generate.log 2>&1; echo "PRISMA_GENERATE rc=$? donor_unchanged=$([ "$(sha256sum $DONOR/.prisma/client/index.d.ts | cut -c1-64)" = "$D0" ] && echo yes || echo NO)"
env npm_config_prefix=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 npm_config_offline=true npx --no-install prettier --write $F > $EV/prettier.log 2>&1; echo "PRETTIER rc=$?"; for f in $F; do cmp -s $f $EV/preformat/$f || echo "REFLOWED $f"; done
timeout 900 ./node_modules/.bin/tsc --noEmit -p tsconfig.json > $EV/tsc.log 2>&1; echo "TSC rc=$? lines=$(wc -l < $EV/tsc.log)"
./node_modules/.bin/eslint --no-warn-ignored --max-warnings 0 $(printf '%s\n' $F | grep -E '\.(ts|cjs)$') > $EV/eslint.log 2>&1; echo "ESLINT rc=$?"
git add -- $F; node scripts/check-r75.js --mode=staged > $EV/r75-staged.log 2>&1; echo "R75_STAGED rc=$?"; git reset -q; [ -z "$(git diff --cached --name-only)" ] && echo INDEX_CLEAN
T=$(printf '%s\n' $F | grep -E '^test/scout/.*\.spec\.ts$' | tr '\n' ' '); timeout 900 ./node_modules/.bin/jest --ci --runTestsByPath $T test/scout/induction/observation.service.spec.ts test/scout/induction/observation.controller.spec.ts > $EV/jest.log 2>&1; echo "JEST rc=$?"; grep -E '^(Tests|Test Suites):' $EV/jest.log
for f in $F; do echo "POST $(sha256sum $f | cut -c1-64) $f"; done > $EV/POSTFORMAT.sha256; echo "END $(date -u +%FT%TZ)"
