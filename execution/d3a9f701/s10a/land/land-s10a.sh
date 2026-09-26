#!/usr/bin/env bash
# S10-A: hooked Bradley commit on integration/importer a4af8e33 in the dev-loop clone, under the canonical lock.
set -uo pipefail; EV=/home/user/workspace/private-evidence/execution/d3a9f701/s10a/land; W=/home/user/workspace/worktrees/d3a9-s10a
TIP=e6f20300b495fa9eee9539ae58d30e3b60e5a78c; BR=exec-d3a9/s10a
LOCK=/home/user/workspace/execution/test-validation.lock; [ "$(stat -c %i $LOCK)" = 692282 ] || exit 75; exec 9>>"$LOCK"; flock -n 9 || { echo LOCK busy; exit 75; }; echo "LOCK acquired $(date -u +%FT%TZ)"
cd $W; [ "$(git rev-parse HEAD)" = $TIP ] && [ "$(git rev-parse --abbrev-ref HEAD)" = $BR ] && [ -z "$(git diff --cached --name-only)" ] || { echo "PRECONDITION head/branch/index"; exit 70; }
[ "$(git ls-remote origin refs/heads/integration/importer | cut -f1)" = $TIP ] || { echo "tip moved"; exit 79; }
FILES=$(awk '{print $3}' $EV/FREEZE.sha256); [ "$(echo "$FILES" | wc -l)" = 14 ] || exit 70
[ "$(git status --porcelain --untracked-files=all | grep -v '^?? node_modules/' | sort)" = "$(echo "$FILES" | sed 's/^/?? /' | sort)" ] || { echo "status set != freeze"; git status --porcelain | head; exit 70; }
while read -r _ s f; do [ "$(sha256sum $f | cut -c1-64)" = "$s" ] || { echo "FREEZE_MISMATCH $f"; exit 70; }; done < $EV/FREEZE.sha256; echo FREEZE_OK
[ -e node_modules ] && [ ! -L node_modules ] || exit 70
git config user.name 'Bradley Gleave'; git config user.email bradley@bradleytgpcoaching.com; [ -z "$(git config --get core.hooksPath)" ] || exit 70
export NODE_OPTIONS=--max-old-space-size=4096 npm_config_prefix=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 npm_config_offline=true
npx --no-install lefthook install > $EV/lefthook-install.log 2>&1; echo "LEFTHOOK rc=$? hooks=$(ls .git/hooks | grep -v sample | tr '\n' ' ')"
timeout 900 ./node_modules/.bin/jest --ci --runTestsByPath $(echo "$FILES" | grep '^test/scout/induction/.*\.spec\.ts$' | tr '\n' ' ') > $EV/jest-on-tip.log 2>&1; rc=$?; echo "JEST_ON_TIP rc=$rc $(grep -E '^Tests:' $EV/jest-on-tip.log)"; [ $rc = 0 ] || exit 71
git add -- $FILES; [ "$(git diff --cached --name-only | sort)" = "$(echo "$FILES" | sort)" ] || { echo "staged set wrong"; git reset -q; exit 70; }
timeout 1500 git commit -q -F $EV/commit-message.txt > $EV/commit.log 2>&1; rc=$?; echo "COMMIT rc=$rc"; tail -20 $EV/commit.log | cut -c1-200
[ $rc = 0 ] || { git reset -q; exit $rc; }
git log -1 --format='HEAD %H tree %T parent %P | %an <%ae> | %cn <%ce>'; git log -1 --format=%B | grep -ciE 'co-authored|signed-off' 
while read -r _ s f; do [ "$(git show HEAD:$f | sha256sum | cut -c1-64)" = "$s" ] || echo "COMMITTED_MISMATCH $f"; done < $EV/FREEZE.sha256; echo COMMITTED_CHECKED
git push -q origin HEAD:refs/heads/land/s10a && echo "PUSHED land/s10a $(git ls-remote origin refs/heads/land/s10a | cut -c1-12)"
git bundle create $EV/s10a.bundle $TIP..HEAD > /dev/null 2>&1; echo "BUNDLE $(sha256sum $EV/s10a.bundle | cut -c1-64)"; echo "END $(date -u +%FT%TZ)"
