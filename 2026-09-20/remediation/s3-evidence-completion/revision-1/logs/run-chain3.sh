#!/bin/bash
cd /home/user/workspace/execution/s3-backend/logs
export NODE_OPTIONS=--max-old-space-size=4096
./run-step2.sh 11-readiness-trio npx jest --ci --maxWorkers=1 test/health-readiness-bounded.spec.ts test/health-readiness-public.spec.ts test/health.controller.spec.ts
./run-step2.sh 12-control-source-lint npx --no-install eslint --max-warnings 0 scripts/check-r75.js test/ci/r75-gate.spec.ts test/ci/r75-boundaries.spec.ts test/ci/r75-wiring.spec.ts test/ci/r75-enforcement.spec.ts test/ci/r100-pathspec.spec.ts test/ci/dependency-audit.spec.ts
./run-step2.sh 13-build npm run build
unset NODE_OPTIONS
./run-step2.sh 14-c12-timing /home/user/workspace/execution/s3-backend/logs/c12-timing.sh
STEP_TIMEOUT=600 ./run-step2.sh 15-npm-audit npm audit --package-lock-only --include=prod --include=dev --include=optional --include=peer --audit-level=high
