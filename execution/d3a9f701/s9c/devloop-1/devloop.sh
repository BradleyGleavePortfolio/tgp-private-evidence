#!/usr/bin/env bash
# S9-C dev loop 1 (diagnostic only; no commit): prettier --write on owned .ts/.cjs, tsc --noEmit, eslint. Canonical lock nonblocking.
set -uo pipefail; C=/home/user/workspace/worktrees/d3a9-s9c; EV=/home/user/workspace/private-evidence/execution/d3a9f701/s9c/devloop-1
LOCK=/home/user/workspace/execution/test-validation.lock; [ "$(stat -c %i $LOCK)" = 692282 ] || exit 75
exec 9>>"$LOCK"; flock -n 9 || { echo "LOCK busy"; exit 75; }; echo "LOCK acquired $(date -u +%FT%TZ)"
cd $C; [ -e node_modules ] || cp -a /home/user/workspace/worktrees/1910a060-s8f/node_modules node_modules
export NODE_OPTIONS=--max-old-space-size=4096 npm_config_prefix=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 npm_config_offline=true
F=$(git status --porcelain --untracked-files=all | awk '{print $2}' | grep -E '\.(ts|cjs)$' | grep -vE 'facts\.service|reconciliation\.module|g2-s9-|rls-g2-s9\.spec|g2-s9-db-guard' | tr '\n' ' ')
echo "OWNED_TS=$F"; npx --no-install prettier --write $F > $EV/prettier.log 2>&1; echo "PRETTIER rc=$?"
timeout 900 ./node_modules/.bin/tsc --noEmit -p tsconfig.json > $EV/tsc.log 2>&1; echo "TSC rc=$? lines=$(wc -l < $EV/tsc.log)"
./node_modules/.bin/eslint --max-warnings 0 $F > $EV/eslint.log 2>&1; echo "ESLINT rc=$?"
for f in $(git status --porcelain --untracked-files=all | awk '{print $2}' | grep -v '^node_modules'); do echo "POST $f $(sha256sum $f | cut -c1-64)"; done
echo "END $(date -u +%FT%TZ)"
