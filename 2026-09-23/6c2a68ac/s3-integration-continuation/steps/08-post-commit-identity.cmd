source $O/steps/chk.sh
git log -1 --format='%H%n%T%n%P%n%an <%ae>%n%cn <%ce>%n%B' | tee $O/identity.txt
eq "%T tree" a584a1b95423f95dae8daabf673ef3776604acbb "$(git log -1 --format=%T)"
eq "%P parents" "d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c 5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06" "$(git log -1 --format=%P)"
eq "author" "Bradley Gleave <bradley@bradleytgpcoaching.com>" "$(git log -1 --format='%an <%ae>')"
eq "committer" "Bradley Gleave <bradley@bradleytgpcoaching.com>" "$(git log -1 --format='%cn <%ce>')"
eq "trailers" "" "$(git log -1 --format=%(trailers))"
eq "message sha256 == authored message file" "$(sha256sum $O/steps/07-commit-message.txt | cut -d' ' -f1)" "$(git log -1 --format=%B | sha256sum | cut -d' ' -f1)"
chk "tree-identical (diff --quiet a584a1b9 HEAD^{tree})" git diff --quiet a584a1b95423f95dae8daabf673ef3776604acbb HEAD^{tree}
chk "MERGE_HEAD absent" test ! -e .git/MERGE_HEAD
eq "porcelain lines" 0 "$(git status --porcelain | wc -l)"
eq "banned-token grep count in commit object" 0 "$(git cat-file -p HEAD | grep -c -iE 'co-authored|generated|claude|anthropic|openai|perplexity')"
eq "detached HEAD" detached "$(git symbolic-ref -q HEAD >/dev/null && echo branch || echo detached)"
eq "HEAD^1" d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c "$(git rev-parse HEAD^1)"; eq "HEAD^2" 5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06 "$(git rev-parse HEAD^2)"
echo "HEAD=$(git rev-parse HEAD) commit_object_sha256=$(git cat-file -p HEAD | sha256sum | cut -d' ' -f1) gpgsig=$(git cat-file -p HEAD | grep -c '^gpgsig')"
exit $FAIL
