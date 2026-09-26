#!/usr/bin/env bash
L=/tmp/s11c/logs; C=/home/user/workspace/worktrees/fa72-s11c; LOCK=/home/user/workspace/execution/test-validation.lock
export npm_config_prefix=/home/user/workspace/execution/fa72efb2/runtime/tools/prettier-3.9.9 PATH=/home/user/workspace/execution/fa72efb2/runtime/tools/prettier-3.9.9/bin:$PATH
cd $C
sha256sum docs/contracts/importer-openapi.json > $L/gen1.sha
run(){ n=$1; shift; flock -w 3600 $LOCK bash -c "cd $C && NODE_OPTIONS=--max-old-space-size=3072 $*" > $L/$n.log 2>&1; echo "$n rc=$? $(date -u +%T)" >> $L/rc.txt; }
run gen2 npm run contract:importer
sha256sum docs/contracts/importer-openapi.json > $L/gen2.sha; cmp -s <(cut -c1-64 $L/gen1.sha) <(cut -c1-64 $L/gen2.sha) && echo "GEN_BYTE_STABLE yes" >> $L/rc.txt || echo "GEN_BYTE_STABLE NO" >> $L/rc.txt
T="src/extension-pair/extension-pair.dto.ts src/extension-pair/extension-pair.service.ts src/extension-pair/__tests__/readiness.spec.ts test/contracts/importer-contract.spec.ts test/rls-c1-setup.spec.ts test/scout/s11/readiness.pg.spec.ts"
prettier --check $T docs/contracts/importer-openapi.json > $L/prettier.log 2>&1; echo "prettier rc=$?" >> $L/rc.txt
run eslint ./node_modules/.bin/eslint --no-warn-ignored --max-warnings 0 $T
run tsc npx tsc --noEmit
run jest ./node_modules/.bin/jest --ci --runInBand src/extension-pair/__tests__ test/contracts/importer-contract.spec.ts
echo DONE >> $L/rc.txt
