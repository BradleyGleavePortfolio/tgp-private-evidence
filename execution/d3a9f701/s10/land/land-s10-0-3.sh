#!/usr/bin/env bash
set -uo pipefail; EV=/home/user/workspace/private-evidence/execution/d3a9f701/s10/land; W=/home/user/workspace/worktrees/d3a9-land-s10-0; DOC=docs/decisions/2026-09-26-s10-induction.md
LOCK=/home/user/workspace/execution/test-validation.lock; [ "$(stat -c %i $LOCK)" = 692282 ] || exit 75; exec 9>>"$LOCK"; flock -n 9 || { echo LOCK busy; exit 75; }; echo "LOCK acquired $(date -u +%FT%TZ)"
cd $W; [ "$(git rev-parse HEAD)" = ba6c740afafa71d0470b36a5066fa4811e7f1a49 ] && [ -z "$(git status --porcelain -- docs)" ] || exit 70
python3 - "$DOC" <<'PY'
import sys; p=sys.argv[1]; s=open(p).read()
a="statement\n  > 1024 bytes; signature/key/challenge of wrong length; `snapshot_ref_digest` not 64 hex;\n  > `issued_at` not RFC 3339 UTC;"
b="statement\n  over 1024 bytes; signature/key/challenge of wrong length; `snapshot_ref_digest` not 64 hex;\n  `issued_at` not RFC 3339 UTC;"
assert s.count(a)==1; open(p,'w').write(s.replace(a,b))
PY
export npm_config_prefix=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 npm_config_offline=true NODE_OPTIONS=--max-old-space-size=4096
npx --no-install prettier --write $DOC > /dev/null 2>&1; npx --no-install prettier --check $DOC > /dev/null 2>&1 || exit 70
git diff --numstat -- $DOC; git diff -- $DOC | grep '^[-+][^-+]' | cut -c1-140
git add $DOC; printf 'docs(s10-0): fix R21 line misparsed as a blockquote\n\nA wrapped line starting with ">" rendered as a blockquote; reword to "over 1024 bytes".\nNo content change.\n' > $EV/commit-message-2.txt
timeout 1200 git commit -q -F $EV/commit-message-2.txt > $EV/commit-2.log 2>&1; rc=$?; echo "COMMIT rc=$rc"; [ $rc = 0 ] || { tail -8 $EV/commit-2.log; exit $rc; }
git log -2 --format='%H %T %P | %an <%ae> | %cn <%ce>'; echo "BLOB sha256=$(git show HEAD:$DOC | sha256sum | cut -c1-64) lines=$(git show HEAD:$DOC | wc -l)"
git push -q origin HEAD:refs/heads/land/s10-0 && git ls-remote origin refs/heads/land/s10-0 | cut -c1-12
git bundle create $EV/s10-0.bundle 5407efae319fd913e973c87f3be0d49786c4a3e0..HEAD > /dev/null 2>&1; echo "BUNDLE $(sha256sum $EV/s10-0.bundle | cut -c1-64)"
