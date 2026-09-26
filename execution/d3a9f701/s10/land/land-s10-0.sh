#!/usr/bin/env bash
# S10-0 doc-only commit on integration/importer 5407efae with genuine lefthook hooks, under the canonical lock.
set -uo pipefail; EV=/home/user/workspace/private-evidence/execution/d3a9f701/s10/land; W=/home/user/workspace/worktrees/d3a9-land-s10-0
TIP=5407efae319fd913e973c87f3be0d49786c4a3e0; DOC=docs/decisions/2026-09-26-s10-induction.md; SRC=/home/user/workspace/private-evidence/execution/d3a9f701/s10/final-f29b95fa.md
LOCK=/home/user/workspace/execution/test-validation.lock; [ "$(stat -c %i $LOCK)" = 692282 ] || exit 75; exec 9>>"$LOCK"; flock -n 9 || { echo LOCK busy; exit 75; }; echo "LOCK acquired $(date -u +%FT%TZ)"
[ ! -e $W ] || { echo "W exists"; exit 76; }
git clone -q --no-checkout https://github.com/BradleyGleavePortfolio/growth-project-backend.git $W || exit 72
cd $W; git fetch -q origin integration/importer; [ "$(git rev-parse FETCH_HEAD)" = $TIP ] || { echo "tip moved $(git rev-parse FETCH_HEAD)"; exit 79; }
git checkout -q -b land-d3a9/s10-0 $TIP; git config user.name 'Bradley Gleave'; git config user.email bradley@bradleytgpcoaching.com
cp -a /home/user/workspace/worktrees/1910a060-s8f/node_modules node_modules; echo "NM lock=$(sha256sum node_modules/.package-lock.json | cut -c1-12) client=$(sha256sum node_modules/.prisma/client/index.d.ts | cut -c1-12)"
git diff --quiet e1ec2fecb71f315b6721d426ba0dacb84f304498 $TIP -- prisma package.json package-lock.json 2>/dev/null; echo "donor-inputs-equal rc=$?"
npx --no-install lefthook install > $EV/lefthook-install.log 2>&1; echo "LEFTHOOK rc=$?"; ls .git/hooks | grep -v sample | tr '\n' ' '; echo
mkdir -p docs/decisions; cp $SRC $DOC; echo "PRE sha=$(sha256sum $DOC | cut -c1-64)"
./node_modules/.bin/prettier --write $DOC > $EV/prettier.log 2>&1; echo "PRETTIER rc=$? POST sha=$(sha256sum $DOC | cut -c1-64) lines=$(wc -l < $DOC)"
[ "$(tr -d ' \n\t' < $SRC | sha256sum)" = "$(tr -d ' \n\t' < $DOC | sha256sum)" ] && echo "LAYOUT_ONLY yes" || echo "LAYOUT_ONLY NO"
diff $SRC $DOC > $EV/prettier-delta.diff; echo "prettier delta lines=$(grep -c '^[<>]' $EV/prettier-delta.diff)"
git add $DOC; [ "$(git diff --cached --name-status)" = "A	$DOC" ] || { echo "staged set wrong"; exit 70; }
printf 'docs(s10-0): unseen-source induction decision (observation contract, CORE DIFF = 0)\n\nDoc-only S10-0 decision for the importer: induction package, per-run declaration and\nsource-signed observation evidence, server evaluator producing the S9 coverage facts,\ninsert-only persistence design for S10-B, the CORE DIFF = 0 gate and the S10-A..D slice\nplan. Owner-reserved questions Q1-Q5 recorded, not decided. No runtime change.\n' > $EV/commit-message.txt
NODE_OPTIONS=--max-old-space-size=4096 timeout 1200 git commit -q -F $EV/commit-message.txt > $EV/commit.log 2>&1; rc=$?; echo "COMMIT rc=$rc"; tail -15 $EV/commit.log
[ $rc = 0 ] || exit $rc
git log -1 --format='HEAD %H tree %T parent %P | %an <%ae> | %cn <%ce>'; git show --stat --format= HEAD | tail -2
git bundle create $EV/s10-0.bundle $TIP..land-d3a9/s10-0 > /dev/null 2>&1; sha256sum $EV/s10-0.bundle | cut -c1-64
echo "END $(date -u +%FT%TZ)"
