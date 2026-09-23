source $O/steps/chk.sh
eq "prettier --version" 3.9.6 "$(node $TOOL/node_modules/prettier/bin/prettier.cjs --version)"
eq "CLI sha256" 6e922134a3c76fd4de202959bb6aef50bde0c994148075003a15569b7197906e "$(sha256sum $TOOL/node_modules/prettier/bin/prettier.cjs | cut -d' ' -f1)"
eq "node_modules entries" ".bin .package-lock.json prettier" "$(find $TOOL/node_modules -mindepth 1 -maxdepth 1 -printf '%f\n' | sort | tr '\n' ' ' | sed 's/ $//')"
exit $FAIL
