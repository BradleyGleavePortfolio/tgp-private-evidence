source $P/steps/chk.sh
git log -1 --format='%H%n%T%n%P%n%an <%ae>%n%cn <%ce>%n%B' | tee $O/identity.txt
eq "%T tree" 3d30aeb08c58d47b53837dfe22b60f8dbef37871 "$(git log -1 --format=%T)"
eq "%P parent" 143d451ead6ccdbebd92ca3031ba7a89867d6cfc "$(git log -1 --format=%P)"
eq "author" "Bradley Gleave <bradley@bradleytgpcoaching.com>" "$(git log -1 --format='%an <%ae>')"
eq "committer" "Bradley Gleave <bradley@bradleytgpcoaching.com>" "$(git log -1 --format='%cn <%ce>')"
eq "trailers" "" "$(git log -1 --format='%(trailers)')"
eq "message == authored file (trailing newlines stripped both sides)" "$(cat $P/steps/07-commit-message.txt)" "$(git log -1 --format=%B)"
chk "tree-identical (diff --quiet 3d30aeb0 HEAD^{tree})" git diff --quiet 3d30aeb08c58d47b53837dfe22b60f8dbef37871 HEAD^{tree}
eq "porcelain lines" 0 "$(git status --porcelain | wc -l)"
eq "untracked beyond ignored" 0 "$(git status --porcelain --untracked-files=all | grep -c '^??')"
eq "banned-token grep count in commit object" 0 "$(git cat-file -p HEAD | grep -c -iE 'co-authored|generated with|claude|anthropic|openai|perplexity')"
eq "detached HEAD" detached "$(git symbolic-ref -q HEAD >/dev/null && echo branch || echo detached)"
eq "commit diff vs parent == frozen patch bytes" c36258b39d0c92f0b760f11982a61427c6e7cce963eecffe2554f447346c5491 "$(git diff 143d451ead6ccdbebd92ca3031ba7a89867d6cfc HEAD | sha256sum | cut -c1-64)"
eq "changed files" $'test/rls-g2-pg17-etq0.spec.ts\ntest/utils/g2-pg17-bootstrap.sh' "$(git diff --name-only HEAD^ HEAD)"
eq "numstat" $'16\t0\ttest/rls-g2-pg17-etq0.spec.ts\n34\t4\ttest/utils/g2-pg17-bootstrap.sh' "$(git diff --numstat HEAD^ HEAD)"
eq "refs unchanged" $'c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7 commit\trefs/heads/main\n143d451ead6ccdbebd92ca3031ba7a89867d6cfc commit\trefs/restored/execute/20260921-s5-r3' "$(git for-each-ref)"
echo "HEAD=$(git rev-parse HEAD) commit_object_sha256=$(git cat-file -p HEAD | sha256sum | cut -d' ' -f1) gpgsig=$(git cat-file -p HEAD | grep -c '^gpgsig') committer_ts=$(git log -1 --format=%ct)"
exit $FAIL
