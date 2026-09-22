#!/usr/bin/env bash
# CONTROL C4: invoke the real V2 runner WITHOUT the launcher. It must refuse before
# touching the lock, the worktree or any tool. Expected exit 71, no files created.
# Run: bash C4-direct-runner-refusal.sh   (≤2 s; no lock, no network)
bash /home/user/workspace/execution/s4-r6-validation/v2/runner/s4-r6-validate-v2.sh; rc=$?
echo "direct invocation exit=$rc (expect 71)"; [[ $rc == 71 ]]
