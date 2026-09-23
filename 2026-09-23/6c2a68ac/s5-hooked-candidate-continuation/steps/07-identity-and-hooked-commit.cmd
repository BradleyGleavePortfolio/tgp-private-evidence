git config --local user.name 'Bradley Gleave' && git config --local user.email 'bradley@bradleytgpcoaching.com'
A=$(git var GIT_AUTHOR_IDENT | sed -E 's/ [0-9]+ [+-][0-9]{4}$//'); C=$(git var GIT_COMMITTER_IDENT | sed -E 's/ [0-9]+ [+-][0-9]{4}$//')
echo "GIT_AUTHOR_IDENT=$A"; echo "GIT_COMMITTER_IDENT=$C"
[ "$A" = 'Bradley Gleave <bradley@bradleytgpcoaching.com>' ] && [ "$C" = 'Bradley Gleave <bradley@bradleytgpcoaching.com>' ] || { echo "identity mismatch; not committing"; exit 91; }
[ "$(git write-tree)" = 756a0d7966c9125749339abbcfd681eb7e713ede ] || { echo "staged tree drifted; not committing"; exit 92; }
[ "$(sha256sum $P/steps/07-commit-message.txt | cut -c1-64)" = 1da4490843c224baa244331121e32fd298847b47f0009ed860e4456f4e0a645b ] || { echo "message file hash mismatch; not committing"; exit 93; }
echo "hooks about to run: $(ls .git/hooks | grep -v '\.sample$' | tr '\n' ' '); LEFTHOOK=${LEFTHOOK-unset} LEFTHOOK_EXCLUDE=${LEFTHOOK_EXCLUDE-unset}"
LEFTHOOK_VERBOSE=1 git commit -F - < $P/steps/07-commit-message.txt
