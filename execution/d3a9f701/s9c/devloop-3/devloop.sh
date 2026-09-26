#!/usr/bin/env bash
set -uo pipefail; C=/home/user/workspace/worktrees/d3a9-s9c; EV=/home/user/workspace/private-evidence/execution/d3a9f701/s9c/devloop-3
LOCK=/home/user/workspace/execution/test-validation.lock; [ "$(stat -c %i $LOCK)" = 692282 ] || exit 75
exec 9>>"$LOCK"; flock -n 9 || { echo "LOCK busy"; exit 75; }; echo "LOCK acquired $(date -u +%FT%TZ)"; cd $C
export NODE_OPTIONS=--max-old-space-size=4096 npm_config_prefix=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 npm_config_offline=true
F="test/scout/reconciliation/catalogue-parity.spec.ts src/scout/scout.service.spec.ts test/scout/g2-s9c-db-guard.spec.ts"
npx --no-install prettier --write $F > $EV/prettier.log 2>&1; echo "PRETTIER rc=$?"; ./node_modules/.bin/eslint --max-warnings 0 $F > $EV/eslint.log 2>&1; echo "ESLINT rc=$?"
timeout 900 ./node_modules/.bin/tsc --noEmit -p tsconfig.json > $EV/tsc.log 2>&1; echo "TSC rc=$? lines=$(wc -l < $EV/tsc.log)"
cp docs/contracts/importer-openapi.json $EV/openapi.before; timeout 900 npm run -s contract:importer > $EV/contract-gen.log 2>&1; echo "CONTRACT_GEN rc=$? stable=$(cmp -s docs/contracts/importer-openapi.json $EV/openapi.before && echo yes || echo no)"
S="test/contracts/importer-contract.spec.ts test/scout/lifecycle/arbiter.spec.ts test/scout/lifecycle/lifecycle.service.spec.ts test/scout/orchestration/settle-hook.spec.ts src/scout/scout.service.spec.ts test/scout/reconciliation/catalogue-parity.spec.ts test/scout/g2-s9c-db-guard.spec.ts test/scout/reconciliation/facts.service.spec.ts test/scout/reconciliation/reconcile.spec.ts test/scout/g2-s9-db-guard.spec.ts test/scout/g2-s8g-db-guard.spec.ts test/scout/orchestration/reconstruct-run.spec.ts test/scout/orchestration/family-plan.spec.ts test/route-doc-drift.spec.ts"
timeout 1500 ./node_modules/.bin/jest --ci --runTestsByPath $S > $EV/jest.log 2>&1; echo "JEST rc=$?"; grep -E '^(Tests|Test Suites):' $EV/jest.log
echo "END $(date -u +%FT%TZ)"
