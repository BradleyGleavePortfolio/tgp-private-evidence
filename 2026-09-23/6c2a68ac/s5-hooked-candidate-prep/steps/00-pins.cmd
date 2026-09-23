source $P/steps/chk.sh
eq "HEAD" 143d451ead6ccdbebd92ca3031ba7a89867d6cfc "$(git rev-parse HEAD)"
eq "committed tree" d0e122d35022377196908b7d132fc34c1af2fc6b "$(git rev-parse HEAD^{tree})"
eq "index == HEAD (write-tree)" d0e122d35022377196908b7d132fc34c1af2fc6b "$(git write-tree)"
eq "status pin" $' M test/rls-g2-pg17-etq0.spec.ts\n M test/utils/g2-pg17-bootstrap.sh' "$(git status --porcelain)"
eq "untracked-files=all beyond ignored" 0 "$(git status --porcelain --untracked-files=all | grep -c '^??')"
eq "dirty fingerprint (runner formula)" 6850b32ef19436abe5b02f96c770f4c36ca8bea070e0c759310f17234c616aa0 "$({ git diff HEAD; printf '%s\n' "$(git status --porcelain --untracked-files=all)"; } | sha256sum | cut -c1-64)"
eq "git diff HEAD == frozen patch" c36258b39d0c92f0b760f11982a61427c6e7cce963eecffe2554f447346c5491 "$(git diff HEAD | sha256sum | cut -c1-64)"
eq "lock blob" 354de3dae19449970497da6e4d87f0a1225a8f43 "$(git ls-files -s package-lock.json | awk '{print $2}')"
eq "core.abbrev" 8 "$(git config --local --get core.abbrev)"
eq "user.name unset" "" "$(git config --local --get user.name)"; eq "user.email unset" "" "$(git config --local --get user.email)"
eq "hooks active" 0 "$(ls .git/hooks | grep -vc '\.sample$')"; eq "core.hooksPath unset" "" "$(git config --get core.hooksPath)"
eq "lefthook.yml" 54d037490460fcddf2523ce05801bae9860489ff "$(git rev-parse HEAD:lefthook.yml)"
chk "node_modules present (setup receipt 94584aa8)" test -d node_modules
eq "installed npm record .package-lock.json sha256 prefix" 05bc530a "$(sha256sum node_modules/.package-lock.json | cut -c1-8)"
chk "generated client absent" test ! -e node_modules/.prisma/client
chk "prettier not in app graph" test ! -e node_modules/.bin/prettier
chk "lefthook CLI present" test -f node_modules/lefthook/bin/index.js
chk "prisma CLI present" test -f node_modules/prisma/build/index.js
eq "@prisma/client version (direct file read)" 6.19.3 "$(node -p "JSON.parse(require('fs').readFileSync('node_modules/@prisma/client/package.json','utf8')).version")"
eq "prisma version (direct file read)" 6.19.3 "$(node -p "JSON.parse(require('fs').readFileSync('node_modules/prisma/package.json','utf8')).version")"
eq "lefthook version (direct file read)" 2.1.9 "$(node -p "JSON.parse(require('fs').readFileSync('node_modules/lefthook/package.json','utf8')).version")"
chk "no quarantine" test ! -e /home/user/workspace/execution/s5-r4/QUARANTINE
chk "no ancestor package.json" test ! -e /home/user/package.json
chk "setup receipt seal verifies" bash -c "cd /home/user/workspace/execution/6c2a68ac/s5-canonical-setup-result && sha256sum -c --quiet SHA256SUMS.s5-canonical-setup-result && [ \"\$(sha256sum SHA256SUMS.s5-canonical-setup-result | cut -c1-64)\" = 94584aa85ed55c1e1dba94f9f0f97db8a1b09e93a5a986f51e54e350d6e9d2f0 ]"
chk "T0 result packet present (parent-accepted; path only)" test -d /home/user/workspace/execution/6c2a68ac/s5-t0-result
echo "prisma engine cache: $(ls -la --time-style=+%FT%TZ /home/user/.cache/prisma/master/c2990dca591cba766e3b7ef5d9e8a84796e47ab7/debian-openssl-3.0.x/ 2>&1 | tr '\n' ';')"
echo "PRISMA_ENGINES_MIRROR=${PRISMA_ENGINES_MIRROR-unset} S5X_vars=[$(env | grep -E '^(S5X_|S5_LEASE_INHERITED|LEFTHOOK)' | tr '\n' ' ')] (must be empty)"
eq "no S5X_/LEFTHOOK env" "" "$(env | grep -E '^(S5X_|S5_LEASE_INHERITED|LEFTHOOK)')"
exit $FAIL
