#!/usr/bin/env bash
# attempt-2: continue in the attempt-1 clone (nothing committed); prettier from the verified 3.9.9 prefix for both the format step and the hook.
set -uo pipefail; EV=/home/user/workspace/private-evidence/execution/d3a9f701/s10/land; W=/home/user/workspace/worktrees/d3a9-land-s10-0
TIP=5407efae319fd913e973c87f3be0d49786c4a3e0; DOC=docs/decisions/2026-09-26-s10-induction.md; SRC=/home/user/workspace/private-evidence/execution/d3a9f701/s10/final-f29b95fa.md
LOCK=/home/user/workspace/execution/test-validation.lock; [ "$(stat -c %i $LOCK)" = 692282 ] || exit 75; exec 9>>"$LOCK"; flock -n 9 || { echo LOCK busy; exit 75; }; echo "LOCK acquired $(date -u +%FT%TZ)"
cd $W; [ "$(git rev-parse HEAD)" = $TIP ] && [ "$(git diff --cached --name-status)" = "A	$DOC" ] || { echo "clone state unexpected"; exit 70; }
export npm_config_prefix=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 npm_config_offline=true NODE_OPTIONS=--max-old-space-size=4096
echo "PRETTIER_VERSION $(npx --no-install prettier --version)"
npx --no-install prettier --write $DOC > $EV/prettier.log 2>&1; echo "PRETTIER rc=$? POST sha=$(sha256sum $DOC | cut -c1-64) lines=$(wc -l < $DOC)"
[ "$(tr -d ' \n\t' < $SRC | sha256sum)" = "$(tr -d ' \n\t' < $DOC | sha256sum)" ] && echo "LAYOUT_ONLY yes (non-whitespace bytes identical)" || echo "LAYOUT_ONLY NO"
diff $SRC $DOC > $EV/prettier-delta.diff; echo "prettier delta lines=$(grep -c '^[<>]' $EV/prettier-delta.diff)"
npx --no-install prettier --check $DOC > /dev/null 2>&1 || { echo "check still fails"; exit 70; }
git add $DOC; [ "$(git diff --cached --name-status)" = "A	$DOC" ] || exit 70
timeout 1200 git commit -q -F $EV/commit-message.txt > $EV/commit.log 2>&1; rc=$?; echo "COMMIT rc=$rc"; tail -8 $EV/commit.log | cut -c1-120
[ $rc = 0 ] || exit $rc
git log -1 --format='HEAD %H tree %T parent %P | %an <%ae> | %cn <%ce>'; git log -1 --format=%B | grep -ciE 'co-authored|generated' ; git show --stat --format= HEAD | tail -1
echo "BLOB $(git rev-parse HEAD:$DOC) sha256=$(git show HEAD:$DOC | sha256sum | cut -c1-64)"
git bundle create $EV/s10-0.bundle $TIP..land-d3a9/s10-0 > /dev/null 2>&1; echo "BUNDLE $(sha256sum $EV/s10-0.bundle | cut -c1-64)"
echo "END $(date -u +%FT%TZ)"
