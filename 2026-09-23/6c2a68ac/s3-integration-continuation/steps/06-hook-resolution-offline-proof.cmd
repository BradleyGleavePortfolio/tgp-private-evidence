source $O/steps/chk.sh
export npm_config_offline=true
N0=$(ls -d "$HOME/.npm/_npx"/* 2>/dev/null | wc -l); echo "npx cache dirs before=$N0"
eq "readlink -f node_modules/.bin/prettier" "$TOOL/node_modules/prettier/bin/prettier.cjs" "$(readlink -f node_modules/.bin/prettier)"
eq "sha256 of resolved prettier" 6e922134a3c76fd4de202959bb6aef50bde0c994148075003a15569b7197906e "$(sha256sum "$(readlink -f node_modules/.bin/prettier)" | cut -d' ' -f1)"
eq "npx --no-install prettier --version" 3.9.6 "$(npx --no-install prettier --version 2>&1)"
OUT=$(npx prettier --version 2>&1); eq "npx prettier --version (hook form)" 3.9.6 "$OUT"
chk "no 'Need to install' prompt" bash -c "! printf '%s' \"$OUT\" | grep -qi 'need to install'"
eq "npx cache dirs unchanged" "$N0" "$(ls -d "$HOME/.npm/_npx"/* 2>/dev/null | wc -l)"
eq "npx --no-install tsc --version" "Version 5.9.3" "$(npx --no-install tsc --version 2>&1)"
eq "npx --no-install eslint --version" "v10.5.0" "$(npx --no-install eslint --version 2>&1)"
echo "which eslint on npx path: $(readlink -f node_modules/.bin/eslint)"
chk "checker present" test -f scripts/check-r75.js
node scripts/check-r75.js --mode=staged; r=$?; echo "staged-mode exit=$r"; eq "check-r75 staged exit" 0 "$r"
eq "CHECKPOINT_DISABLE" 1 "${CHECKPOINT_DISABLE-unset}"
eq "write-tree" a584a1b95423f95dae8daabf673ef3776604acbb "$(git write-tree)"
exit $FAIL
