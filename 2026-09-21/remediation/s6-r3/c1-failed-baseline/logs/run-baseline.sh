#!/usr/bin/env bash
# C1-S6-SETUP-BASELINE — durable, lock-guarded, stop-on-first-failure.
# Invoked as: setsid nohup flock -n <LOCK> bash run-baseline.sh > run-baseline.out 2>&1 &
set -u
WT=/home/user/workspace/worktrees/s6-r3
EX=/home/user/workspace/execution/s6-r3
LOGS=$EX/logs
STG=$EX/s6-p1/staging
EXIT_RECORD=$LOGS/baseline.EXIT_RECORD
START=$(date +%s)
BUDGET=1200  # 20 min
export CI=1 NODE_OPTIONS=--max-old-space-size=2048 TZ=UTC
export EXPO_PUBLIC_FF_EXTENSION_IMPORT= EXPO_PUBLIC_FF_IMPORT_REVIEW=
CPU="taskset -c 0,1"

rec() { echo "$(date -u +%FT%TZ) step=$1 rc=$2 elapsed=$(( $(date +%s) - START ))s" >> "$EXIT_RECORD"; }
remaining() { echo $(( BUDGET - ( $(date +%s) - START ) )); }
die() { rec "$1" "$2"; echo "STOP_FIRST_FAILURE step=$1 rc=$2" >> "$EXIT_RECORD"; echo "FINAL rc=$2" >> "$EXIT_RECORD"; exit "$2"; }

echo "$(date -u +%FT%TZ) START pid=$$ pgid=$(ps -o pgid= $$ | tr -d ' ') lock=held" > "$EXIT_RECORD"
cd "$WT" || die cd 1

# 0. provenance: frozen d51, clean, committed lockfile/toolchain
{
  echo "HEAD=$(git rev-parse HEAD)"; echo "dirty_lines=$(git status --porcelain | wc -l)"
  echo "lock_blob=$(git ls-files -s package-lock.json | awk '{print $2}')"; echo "lock_sha256=$(sha256sum package-lock.json | cut -d' ' -f1)"
  echo "node=$(node -v) npm=$(npm -v)"; grep -n '"jest-expo"\|"@tanstack/' package.json
} > "$LOGS/baseline.provenance.txt" 2>&1
[ "$(git status --porcelain | wc -l)" = "0" ] || die provenance-clean 2
[ "$(git rev-parse HEAD)" = "d51a191098f483cea9abec6cc7e9f3beffd18c06" ] || die provenance-head 2
rec provenance 0

# 1. npm ci (exact lockfile), bounded
$CPU timeout "$(remaining)" npm ci --no-audit --no-fund --loglevel=error > "$LOGS/baseline.npm-ci.log" 2>&1; rc=$?
[ "$(git status --porcelain | wc -l)" = "0" ] || { echo "npm ci dirtied tree:" >> "$LOGS/baseline.npm-ci.log"; git status --porcelain >> "$LOGS/baseline.npm-ci.log"; die npm-ci-dirty 3; }
[ $rc -eq 0 ] || die npm-ci $rc
{ echo "rq=$(node -p "require('@tanstack/react-query/package.json').version")";
  echo "rqpc=$(node -p "require('@tanstack/react-query-persist-client/package.json').version")";
  echo "asp=$(node -p "require('@tanstack/query-async-storage-persister/package.json').version")";
  echo "asyncstorage=$(node -p "require('@react-native-async-storage/async-storage/package.json').version")";
  echo "asyncstorage_jest_mock_removeMany=$(node -p "typeof require('@react-native-async-storage/async-storage/jest/async-storage-mock').removeMany")"; } >> "$LOGS/baseline.provenance.txt" 2>&1
rec npm-ci 0

# 2. copy staged controls (untracked), fingerprint
cp "$STG/src/services/__tests__/persistedQueryCache.hazardAdapter.tsx" src/services/__tests__/
cp "$STG/src/services/__tests__/persistedQueryCache.hazardControls.test.tsx" src/services/__tests__/
{ git status --porcelain; sha256sum src/services/__tests__/persistedQueryCache.hazard*; (cd "$STG" && sha256sum src/services/__tests__/persistedQueryCache.hazard*); git diff --stat HEAD; } > "$LOGS/baseline.fingerprint.txt" 2>&1
[ "$(git status --porcelain | grep -vc '^?? src/services/__tests__/persistedQueryCache.hazard')" = "0" ] || die fingerprint 4
rec copy-controls 0

# 3. hazard baseline on d51 (must genuinely execute T1-T4)
$CPU timeout "$(remaining)" npx jest src/services/__tests__/persistedQueryCache.hazardControls.test.tsx --ci --maxWorkers=1 --verbose > "$LOGS/s6-p1-hazard-controls-d51.log" 2>&1; rc=$?
rec hazard-controls-d51 $rc
[ $rc -eq 0 ] || die hazard-controls-d51 $rc

# 4. smallest existing persister/signout composition controls
$CPU timeout "$(remaining)" npx jest src/services/__tests__/queryClient.persister.test.ts src/services/__tests__/queryClient.signout.test.ts --ci --maxWorkers=1 --verbose > "$LOGS/baseline.persister-signout-controls.log" 2>&1; rc=$?
rec persister-signout-controls $rc
[ $rc -eq 0 ] || die persister-signout-controls $rc

echo "FINAL rc=0" >> "$EXIT_RECORD"
exit 0
