#!/bin/bash
cd /home/user/workspace/execution/s3-backend/logs
while ! rg -q '^exit=' 02-focused-a.log 2>/dev/null; do sleep 10; done
STEP_TIMEOUT=900 ./run-step.sh 05-tsc npx tsc --noEmit -p tsconfig.json
STEP_TIMEOUT=900 ./run-step.sh 06-lint npm run lint --silent
STEP_TIMEOUT=5400 ./run-step.sh 07-full-jest npx jest --ci --maxWorkers=1 --silent
