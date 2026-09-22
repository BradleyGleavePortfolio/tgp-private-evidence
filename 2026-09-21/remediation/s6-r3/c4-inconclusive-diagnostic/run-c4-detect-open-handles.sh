#!/usr/bin/env bash
# C4 — ONE-FILE OPEN-HANDLE DIAGNOSTIC on unchanged v4 hazard test + staging adapter. NOT LAUNCHED until parent grants.
# Invoke: setsid nohup flock -n /home/user/workspace/execution/test-validation.lock bash run-c4-detect-open-handles.sh > run-c4-detect-open-handles.out 2>&1 < /dev/null &
# Purpose: obtain Jest's owning stack for each handle that keeps the process alive. No controls, no product change, no --forceExit.
set -u
WT=/home/user/workspace/worktrees/s6-r3
EX=/home/user/workspace/execution/s6-r3
LOGS=$EX/logs
V4=$EX/s6-p1/revisions/v4
STG=$EX/s6-p1/staging
EXIT_RECORD=$LOGS/c4.EXIT_RECORD
START=$(date +%s)
BUDGET=120
export CI=1 NODE_OPTIONS=--max-old-space-size=2048 TZ=UTC
export EXPO_PUBLIC_FF_EXTENSION_IMPORT= EXPO_PUBLIC_FF_IMPORT_REVIEW=
CPU="taskset -c 0,1"
rec() { echo "$(date -u +%FT%TZ) step=$1 rc=$2 elapsed=$(( $(date +%s) - START ))s" >> "$EXIT_RECORD"; }
die() { rec "$1" "$2"; echo "STOP step=$1 rc=$2" >> "$EXIT_RECORD"; echo "FINAL rc=$2" >> "$EXIT_RECORD"; exit "$2"; }
echo "$(date -u +%FT%TZ) START pid=$$ pgid=$(ps -o pgid= $$ | tr -d ' ') lock=held" > "$EXIT_RECORD"
cd "$WT" || die cd 1
[ "$(git rev-parse HEAD)" = "d51a191098f483cea9abec6cc7e9f3beffd18c06" ] || die provenance-head 2
[ ! -e /home/user/node_modules ] && [ ! -e /home/user/package.json ] || die provenance-ancestor-root 2
cp "$V4/src/services/__tests__/persistedQueryCache.hazardControls.test.tsx" src/services/__tests__/
cp "$STG/src/services/__tests__/persistedQueryCache.hazardAdapter.tsx" src/services/__tests__/
[ "$(sha256sum src/services/__tests__/persistedQueryCache.hazardControls.test.tsx | cut -d' ' -f1)" = "$(grep hazardControls "$V4/MANIFEST.sha256" | cut -d' ' -f1)" ] || die fingerprint-v4 4
[ "$(sha256sum src/services/__tests__/persistedQueryCache.hazardAdapter.tsx | cut -d' ' -f1)" = "$(grep hazardAdapter "$EX/s6-p1/MANIFEST.sha256" | cut -d' ' -f1)" ] || die fingerprint-adapter 4
[ "$(git status --porcelain | grep -vc '^?? src/services/__tests__/persistedQueryCache.hazard')" = "0" ] || die fingerprint-clean 4
rec copy-v4 0
# --detectOpenHandles: Jest collects async_hooks stacks and prints "Jest has detected the following N open handles" with owners.
# Diagnostic expectation: tests 6/6 as in C2/C3, then the handle report. A timeout here (rc 124/137) still leaves the report in the log if printed.
$CPU timeout -k 60 100 npx jest src/services/__tests__/persistedQueryCache.hazardControls.test.tsx --ci --maxWorkers=1 --verbose --detectOpenHandles > "$LOGS/c4.detect-open-handles.log" 2>&1; rc=$?
rec detect-open-handles $rc
{ echo "tests_line: $(grep -m1 '^Tests:' "$LOGS/c4.detect-open-handles.log")"
  echo "overlapping_act: $(grep -c 'overlapping act' "$LOGS/c4.detect-open-handles.log")"
  echo "open_handles_header: $(grep -m1 'open handle' "$LOGS/c4.detect-open-handles.log")"
  echo "handle_types:"; grep -E '^\s*●\s+' "$LOGS/c4.detect-open-handles.log" | sort | uniq -c; } > "$LOGS/c4.summary.txt" 2>&1
echo "FINAL rc=$rc" >> "$EXIT_RECORD"
exit $rc
