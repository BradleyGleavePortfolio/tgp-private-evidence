#!/usr/bin/env bash
L=/tmp/s11c/logs2; mkdir -p $L; C=/home/user/workspace/worktrees/fa72-s11c; LOCK=/home/user/workspace/execution/test-validation.lock
export npm_config_prefix=/home/user/workspace/execution/fa72efb2/runtime/tools/prettier-3.9.9 PATH=/home/user/workspace/execution/fa72efb2/runtime/tools/prettier-3.9.9/bin:$PATH npm_config_offline=true
while [ ! -e /home/user/workspace/execution/fa72efb2/PROOF_SLOT_FREE ]; do sleep 60; done; echo "slot free $(date -u +%T)" >> $L/rc.txt
cd $C
T="src/extension-pair/extension-pair.dto.ts src/extension-pair/extension-pair.service.ts src/extension-pair/__tests__/readiness.spec.ts test/contracts/importer-contract.spec.ts test/rls-c1-setup.spec.ts test/scout/s11/readiness.pg.spec.ts"
run(){ n=$1; shift; flock -w 3600 $LOCK bash -c "cd $C && NODE_OPTIONS=--max-old-space-size=3072 $*" > $L/$n.log 2>&1; r=$?; echo "$n rc=$r $(date -u +%T)" >> $L/rc.txt; return $r; }
ok=1
prettier --check $T docs/contracts/importer-openapi.json > $L/prettier.log 2>&1; r=$?; echo "prettier rc=$r" >> $L/rc.txt; [ $r = 0 ] || ok=0
run eslint ./node_modules/.bin/eslint --no-warn-ignored --max-warnings 0 $T || ok=0
run tsc npx tsc --noEmit || ok=0
git add -- $T docs/contracts/importer-openapi.json
node scripts/check-r75.js --mode=staged > $L/r75.log 2>&1; r=$?; echo "r75_staged rc=$r" >> $L/rc.txt; [ $r = 0 ] || ok=0
git diff --cached --name-only > $L/staged.txt
if [ $ok = 1 ]; then
  run commit bash /tmp/s11c/commit.sh
else echo "commit SKIPPED (gate red)" >> $L/rc.txt; fi
echo DONE >> $L/rc.txt
