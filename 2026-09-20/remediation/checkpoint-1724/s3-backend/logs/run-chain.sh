#!/bin/bash
# Wait for the focused run to finish, then take the lock separately for each heavy step.
cd /home/user/workspace/execution/s3-backend/logs
while ! rg -q '^exit=' 02-focused-a.log 2>/dev/null; do sleep 10; done
./run-focused.sh 05-tsc npx tsc --noEmit -p tsconfig.json
./run-focused.sh 06-lint npm run lint --silent
./run-focused.sh 07-full-jest npx jest --ci --maxWorkers=1 --silent
