git config --local user.name 'Bradley Gleave' && git config --local user.email 'bradley@bradleytgpcoaching.com'
A=$(git var GIT_AUTHOR_IDENT | sed -E 's/ [0-9]+ [+-][0-9]{4}$//'); C=$(git var GIT_COMMITTER_IDENT | sed -E 's/ [0-9]+ [+-][0-9]{4}$//')
echo "GIT_AUTHOR_IDENT=$A"; echo "GIT_COMMITTER_IDENT=$C"
[ "$A" = 'Bradley Gleave <bradley@bradleytgpcoaching.com>' ] && [ "$C" = 'Bradley Gleave <bradley@bradleytgpcoaching.com>' ] || { echo "identity mismatch; not committing"; exit 91; }
echo "hooks about to run: $(ls .git/hooks | grep -v '\.sample$' | tr '\n' ' '); LEFTHOOK=${LEFTHOOK-unset} LEFTHOOK_EXCLUDE=${LEFTHOOK_EXCLUDE-unset}"
LEFTHOOK_VERBOSE=1 git commit -F - < $O/steps/07-commit-message.txt
