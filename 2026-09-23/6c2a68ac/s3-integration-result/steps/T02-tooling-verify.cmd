source $O/steps/chk.sh
eq "prettier --version" 3.9.6 "$(node "$TOOL/node_modules/prettier/bin/prettier.cjs" --version)"
eq "package.json version" 3.9.6 "$(node -p "require('$TOOL/node_modules/prettier/package.json').version")"
C="$HOME/.npm/_cacache/content-v2/sha512/3a/93/74cf355d89a880871a6eba3e5e7e9212e2c63d8fb6d8eae4799a78f9c8fcc691d92334a4897944e13dbeb4270dbd42e019800e28fbf881e3d90589a057ea"
chk "cached tarball at integrity address" ls -la "$C"
eq "tarball sha512" 3a9374cf355d89a880871a6eba3e5e7e9212e2c63d8fb6d8eae4799a78f9c8fcc691d92334a4897944e13dbeb4270dbd42e019800e28fbf881e3d90589a057ea "$(sha512sum "$C" | cut -d' ' -f1)"
sha256sum "$TOOL/node_modules/prettier/bin/prettier.cjs" "$TOOL/node_modules/prettier/package.json" | tee $O/tooling-verify.txt
eq "installed CLI sha256 (grant pin)" 6e922134a3c76fd4de202959bb6aef50bde0c994148075003a15569b7197906e "$(sha256sum "$TOOL/node_modules/prettier/bin/prettier.cjs" | cut -d' ' -f1)"
eq "node_modules top-level entries" ".bin .package-lock.json prettier" "$(find "$TOOL/node_modules" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort | tr '\n' ' ' | sed 's/ $//')"
exit $FAIL
