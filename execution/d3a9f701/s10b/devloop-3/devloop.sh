#!/usr/bin/env bash
set -uo pipefail; B=/home/user/workspace/worktrees/d3a9-s10b; A=/home/user/workspace/worktrees/d3a9-s10a; EV=/home/user/workspace/private-evidence/execution/d3a9f701/s10b/devloop-3
FR=/home/user/workspace/private-evidence/execution/d3a9f701/s10a/land/FREEZE.sha256; DONOR=/home/user/workspace/worktrees/1910a060-s8f/node_modules
LOCK=/home/user/workspace/execution/test-validation.lock; [ "$(stat -c %i $LOCK)" = 692282 ] || exit 75; exec 9>>"$LOCK"; flock -n 9 || { echo "LOCK busy"; exit 75; }; echo "LOCK acquired $(date -u +%FT%TZ)"; cd $B
DS0=$(sha256sum $DONOR/.prisma/client/index.d.ts | cut -c1-64)
S10B=$(git status --porcelain --untracked-files=all | awk '{print $2}' | grep -v '^node_modules')
for f in $S10B; do mkdir -p $EV/preformat/$(dirname $f); cp -p $f $EV/preformat/$f; done
AF=$(awk '{print $3}' $FR); echo "S10A_TRACKED_AT_HEAD"
[ -e node_modules ] || cp -a $DONOR node_modules; [ -d node_modules/.prisma/client ] && [ ! -L node_modules/.prisma ] || exit 70
export NODE_OPTIONS=--max-old-space-size=4096
./node_modules/.bin/prisma generate --schema prisma/schema.prisma > $EV/prisma-generate.log 2>&1; echo "PRISMA_GENERATE rc=$? client=$(sha256sum node_modules/.prisma/client/index.d.ts | cut -c1-12) donor_unchanged=$([ "$(sha256sum $DONOR/.prisma/client/index.d.ts | cut -c1-64)" = "$DS0" ] && echo yes || echo NO)"
grep -c 'ScoutRunDeclaration' node_modules/.prisma/client/index.d.ts
F=$(printf '%s\n' $S10B | grep -E '\.(ts|cjs|json|md)$' | tr '\n' ' ')
env npm_config_prefix=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 npm_config_offline=true npx --no-install prettier --write $F > $EV/prettier.log 2>&1; echo "PRETTIER rc=$?"; for f in $S10B; do cmp -s $f $EV/preformat/$f || echo "REFLOWED $f"; done
timeout 900 ./node_modules/.bin/tsc --noEmit -p tsconfig.json > $EV/tsc.log 2>&1; echo "TSC rc=$? lines=$(wc -l < $EV/tsc.log)"
L=$(printf '%s\n' $S10B | grep -E '\.(ts|cjs)$' | tr '\n' ' '); ./node_modules/.bin/eslint --no-warn-ignored --max-warnings 0 $L > $EV/eslint.log 2>&1; echo "ESLINT rc=$?"
git add -- $S10B; node scripts/check-r75.js --mode=staged > $EV/r75-staged.log 2>&1; echo "R75_STAGED rc=$?"; git reset -q; [ -z "$(git diff --cached --name-only)" ] && echo INDEX_CLEAN
timeout 900 ./node_modules/.bin/jest --ci --runTestsByPath test/scout/induction/observation.service.spec.ts test/scout/induction/observation.controller.spec.ts $(printf '%s\n' $AF | grep '\.spec\.ts$' | tr '\n' ' ') > $EV/jest.log 2>&1; echo "JEST rc=$?"; grep -E '^(Tests|Test Suites):' $EV/jest.log
for f in $S10B; do echo "POST $(sha256sum $f | cut -c1-64) $f"; done > $EV/POSTFORMAT.sha256
echo "S10A_TRACKED status_lines=$(git status --porcelain --untracked-files=all | grep -vc "^?? node_modules")"
echo "END $(date -u +%FT%TZ)"
