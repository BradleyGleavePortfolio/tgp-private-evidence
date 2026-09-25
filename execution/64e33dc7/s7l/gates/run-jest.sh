#!/usr/bin/env bash
cd /home/user/workspace/worktrees/64e33dc7-s7l
export NODE_OPTIONS=--max-old-space-size=4096
start=$(date +%s)
npx jest --ci src/scout test/scout test/contracts/importer-contract.spec.ts test/contracts/importer-contract-extraction.spec.ts test/utils
echo "jest exit=$? elapsed=$(( $(date +%s) - start ))s"
