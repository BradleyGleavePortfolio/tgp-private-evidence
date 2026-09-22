#!/usr/bin/env bash
# C2 — baseline-only rerun with v3 harness correction. NOT LAUNCHED until parent grants C2.
# Invoke: setsid nohup flock -n /home/user/workspace/execution/test-validation.lock bash run-c2-baseline.sh > run-c2-baseline.out 2>&1 < /dev/null &
# Budget 5 min + 60 s cleanup. No install. No product change. No --forceExit.
set -u
WT=/home/user/workspace/worktrees/s6-r3
EX=/home/user/workspace/execution/s6-r3
LOGS=$EX/logs
V3=$EX/s6-p1/revisions/v3
STG=$EX/s6-p1/staging
EXIT_RECORD=$LOGS/c2.EXIT_RECORD
START=$(date +%s)
BUDGET=300
export CI=1 NODE_OPTIONS=--max-old-space-size=2048 TZ=UTC
export EXPO_PUBLIC_FF_EXTENSION_IMPORT= EXPO_PUBLIC_FF_IMPORT_REVIEW=
CPU="taskset -c 0,1"

rec() { echo "$(date -u +%FT%TZ) step=$1 rc=$2 elapsed=$(( $(date +%s) - START ))s" >> "$EXIT_RECORD"; }
remaining() { local r=$(( BUDGET - ( $(date +%s) - START ) )); [ $r -gt 5 ] && echo $r || echo 5; }
die() { rec "$1" "$2"; echo "STOP_FIRST_FAILURE step=$1 rc=$2" >> "$EXIT_RECORD"; echo "FINAL rc=$2" >> "$EXIT_RECORD"; exit "$2"; }
# timeout -k 60: SIGTERM at budget, SIGKILL 60 s later (the cleanup allowance)
JEST() { $CPU timeout -k 60 "$(remaining)" npx jest "$@" --ci --maxWorkers=1 --verbose; }

echo "$(date -u +%FT%TZ) START pid=$$ pgid=$(ps -o pgid= $$ | tr -d ' ') lock=held" > "$EXIT_RECORD"
cd "$WT" || die cd 1

# 0. provenance: frozen d51, no reinstall, existing node_modules from committed lockfile
{ echo "HEAD=$(git rev-parse HEAD)"; echo "lock_blob=$(git ls-files -s package-lock.json | awk '{print $2}')"
  echo "node=$(node -v) npm=$(npm -v)"; echo "node_modules_present=$([ -d node_modules ] && echo yes || echo no)"
  echo "ancestor_root_absent=$([ ! -e /home/user/node_modules ] && [ ! -e /home/user/package.json ] && echo yes || echo NO)"
  git status --porcelain | sed 's/^/tracked_or_untracked: /'; } > "$LOGS/c2.provenance.txt" 2>&1
[ "$(git rev-parse HEAD)" = "d51a191098f483cea9abec6cc7e9f3beffd18c06" ] || die provenance-head 2
[ -d node_modules ] || die provenance-node-modules 2
[ "$(git status --porcelain | grep -vc '^?? src/services/__tests__/persistedQueryCache.hazard')" = "0" ] || die provenance-clean 2
grep -q "ancestor_root_absent=yes" "$LOGS/c2.provenance.txt" || die provenance-ancestor-root 2
rec provenance 0

# 1. module resolution: every relevant module must resolve inside the pinned local root
node -e '
const p=require("path"); const wt=process.argv[1]; let bad=0;
for (const m of ["react","react-test-renderer","react-native","@testing-library/react-native","@tanstack/react-query","@tanstack/query-core","@tanstack/react-query-persist-client","@tanstack/query-persist-client-core","@tanstack/query-async-storage-persister","@react-native-async-storage/async-storage","jest-expo","jest"]) {
  const r=require.resolve(m+"/package.json",{paths:[wt]}); const v=require(r).version; const inside=r.startsWith(p.join(wt,"node_modules")+p.sep);
  console.log(`${inside?"OK ":"BAD"} ${m}@${v} ${r}`); if(!inside) bad++; }
process.exit(bad?1:0)' "$WT" > "$LOGS/c2.module-paths.txt" 2>&1 || die module-paths 5
rec module-paths 0

# 2. copy v3 hazard test + unchanged staged adapter (untracked), verify exact digests
cp "$V3/src/services/__tests__/persistedQueryCache.hazardControls.test.tsx" src/services/__tests__/
cp "$STG/src/services/__tests__/persistedQueryCache.hazardAdapter.tsx" src/services/__tests__/
{ echo "expected v3 test: $(grep hazardControls "$V3/MANIFEST.sha256" | cut -d' ' -f1)"
  echo "expected adapter (staging manifest): $(grep hazardAdapter "$EX/s6-p1/MANIFEST.sha256" | cut -d' ' -f1)"
  sha256sum src/services/__tests__/persistedQueryCache.hazard*; git status --porcelain; } > "$LOGS/c2.fingerprint.txt" 2>&1
[ "$(sha256sum src/services/__tests__/persistedQueryCache.hazardControls.test.tsx | cut -d' ' -f1)" = "$(grep hazardControls "$V3/MANIFEST.sha256" | cut -d' ' -f1)" ] || die fingerprint-v3 4
[ "$(sha256sum src/services/__tests__/persistedQueryCache.hazardAdapter.tsx | cut -d' ' -f1)" = "$(grep hazardAdapter "$EX/s6-p1/MANIFEST.sha256" | cut -d' ' -f1)" ] || die fingerprint-adapter 4
[ "$(git status --porcelain | grep -vc '^?? src/services/__tests__/persistedQueryCache.hazard')" = "0" ] || die fingerprint-clean 4
rec copy-v3 0

# 3. hazard baseline on d51 (mode=d51-singleton expects T1-T3 hazards reproduced, T4 holds → rc 0)
JEST src/services/__tests__/persistedQueryCache.hazardControls.test.tsx > "$LOGS/c2.hazard-controls-d51.log" 2>&1; rc=$?
rec hazard-controls-d51 $rc
[ $rc -eq 124 ] || [ $rc -eq 137 ] && die hazard-controls-d51-TIMEOUT_OR_HANG $rc
grep -q "overlapping act" "$LOGS/c2.hazard-controls-d51.log" && die hazard-controls-d51-OVERLAPPING_ACT 6
grep -q "did not exit one second" "$LOGS/c2.hazard-controls-d51.log" && die hazard-controls-d51-OPEN_HANDLES 7
grep -q "\[mode=d51-singleton\]" "$LOGS/c2.hazard-controls-d51.log" || die hazard-controls-d51-MODE 8
[ $rc -eq 0 ] || die hazard-controls-d51 $rc

# 4. two smallest existing persister/signout composition controls
JEST src/services/__tests__/queryClient.persister.test.ts src/services/__tests__/queryClient.signout.test.ts > "$LOGS/c2.persister-signout-controls.log" 2>&1; rc=$?
rec persister-signout-controls $rc
grep -q "overlapping act" "$LOGS/c2.persister-signout-controls.log" && die persister-signout-OVERLAPPING_ACT 6
[ $rc -eq 0 ] || die persister-signout-controls $rc

echo "FINAL rc=0" >> "$EXIT_RECORD"
exit 0
