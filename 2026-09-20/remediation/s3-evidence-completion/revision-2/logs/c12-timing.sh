#!/bin/bash
# A-7 / B01: self-timed c12/deepmerge probe x3 (identical body to the spec's child at test/dependency-compatibility.spec.ts:133), then the spec once.
cd /home/user/workspace/worktrees/s3-backend
cp /tmp/f1-probe.js ./.f1-probe.tmp.cjs
echo "--- probe body (sha256 $(sha256sum ./.f1-probe.tmp.cjs | cut -c1-16)):"; cat ./.f1-probe.tmp.cjs
for i in 1 2 3; do echo "--- run $i loadavg=$(cat /proc/loadavg)"; node ./.f1-probe.tmp.cjs; echo "probe exit=$?"; done
rm -f ./.f1-probe.tmp.cjs
echo "--- spec once"
npx jest --ci --maxWorkers=1 test/dependency-compatibility.spec.ts 2>&1 | rg -v "^\s*$"
