node $TOOL/node_modules/prettier/bin/prettier.cjs --version; sha256sum $TOOL/node_modules/prettier/bin/prettier.cjs; find $TOOL/node_modules -mindepth 1 -maxdepth 1 | sort
sha256sum $TOOL/package.json $TOOL/package-lock.json
