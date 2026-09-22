#!/usr/bin/env bash
# C5-S6-RESOURCE-INVENTORY — one causal resource-ownership diagnostic with perturbation controls.
# NOT LAUNCHED until the parent grants a named slot. Requires node_modules from the committed lockfile
# in the isolated worktree (separate setup grant; see C5_PROPOSAL.md §6).
# Invoke (parent-granted):
#   setsid nohup flock -n /home/user/workspace/execution/test-validation.lock \
#     bash /home/user/workspace/execution/s6-diagnostic/run-c5-resource-inventory.sh \
#     > /home/user/workspace/execution/s6-diagnostic/logs/run-c5.out 2>&1 < /dev/null &
# Steps: 0 selftest(pure node) → A noop → B import-only → D persistence lifecycle (no React) → C unchanged v4 hazard+adapter.
# No --forceExit, no --detectOpenHandles, no install, no product/adapter/test-byte change, no assertion change.
set -u
WT=/home/user/workspace/worktrees/s6-diagnostic
EX=/home/user/workspace/execution/s6-diagnostic
DIAG=$EX/diag
IN=$EX/inputs
LOGS=$EX/logs
EXIT_RECORD=$LOGS/c5.EXIT_RECORD
START=$(date +%s)
BUDGET=360            # outer budget (s); worst case A45+15 B45+15 D60+15 C90+20 + setup ≈ 320 s
export CI=1 NODE_OPTIONS=--max-old-space-size=2048 TZ=UTC
export EXPO_PUBLIC_FF_EXTENSION_IMPORT= EXPO_PUBLIC_FF_IMPORT_REVIEW=
export S6DIAG_WT=$WT
CPU="taskset -c 0,1"
CONTINUE_AFTER_D_HANG=${S6DIAG_CONTINUE_AFTER_D_HANG:-0}
TESTDIR=src/services/__tests__

rec() { echo "$(date -u +%FT%TZ) step=$1 rc=$2 elapsed=$(( $(date +%s) - START ))s" >> "$EXIT_RECORD"; }
die() { rec "$1" "$2"; echo "STOP_FIRST_FAILURE step=$1 rc=$2" >> "$EXIT_RECORD"; echo "FINAL rc=$2" >> "$EXIT_RECORD"; group_check; exit "$2"; }
group_check() {  # owned-group cleanup accounting: never touches processes outside this runner's group
  local pg; pg=$(ps -o pgid= $$ | tr -d ' ')
  local left; left=$(pgrep -g "$pg" | grep -vx "$$" || true)
  echo "$(date -u +%FT%TZ) group=$pg leftover_pids=[${left//$'\n'/,}]" >> "$EXIT_RECORD"
  if [ -n "$left" ]; then
    echo "$(date -u +%FT%TZ) owned-group TERM -> $left" >> "$EXIT_RECORD"; kill -TERM $left 2>/dev/null; sleep 5
    left=$(pgrep -g "$pg" | grep -vx "$$" || true)
    if [ -n "$left" ]; then echo "$(date -u +%FT%TZ) owned-group KILL -> $left" >> "$EXIT_RECORD"; kill -KILL $left 2>/dev/null; sleep 1; fi
    left=$(pgrep -g "$pg" | grep -vx "$$" || true); echo "$(date -u +%FT%TZ) survivors_after_cleanup=[${left//$'\n'/,}]" >> "$EXIT_RECORD"
  fi
}
sha() { sha256sum "$1" | cut -d' ' -f1; }
JEST() { # $1 step, $2 budget, $3 grace, $4 spec relative to WT
  local step=$1 budget=$2 grace=$3 spec=$4
  S6DIAG_LOG=$LOGS/c5.$step.inventory.jsonl S6DIAG_STEP=$step \
  $CPU timeout -k "$grace" "$budget" node node_modules/jest/bin/jest.js "$spec" --ci --runInBand --verbose \
    --setupFilesAfterEnv="$WT/jest.setup.js" --setupFilesAfterEnv="$DIAG/s6diag.setupAfterEnv.js" \
    --globalSetup="$DIAG/s6diag.globalSetup.js" --globalTeardown="$DIAG/s6diag.globalTeardown.js" \
    > "$LOGS/c5.$step.jest.log" 2>&1; local rc=$?
  node "$DIAG/s6diag.summarize.js" "$LOGS/c5.$step.inventory.jsonl" "$LOGS/c5.$step.jest.log" "$step" "$rc" > "$LOGS/c5.$step.summary.txt" 2>&1
  echo $rc
}

mkdir -p "$LOGS"
echo "$(date -u +%FT%TZ) START pid=$$ pgid=$(ps -o pgid= $$ | tr -d ' ') lock=held" > "$EXIT_RECORD"
cd "$WT" || die cd 1

# 0. provenance: exact d51, node_modules present (from a separate setup grant), no ancestor package root, clean tree
{ echo "HEAD=$(git rev-parse HEAD)"; echo "TREE=$(git rev-parse HEAD^{tree})"; echo "lock_blob=$(git ls-files -s package-lock.json | awk '{print $2}')"
  echo "node=$(node -v) npm=$(npm -v)"; echo "node_modules_present=$([ -d node_modules ] && echo yes || echo no)"
  echo "ancestor_root_absent=$([ ! -e /home/user/node_modules ] && [ ! -e /home/user/package.json ] && echo yes || echo NO)"
  git status --porcelain | sed 's/^/status: /'; } > "$LOGS/c5.provenance.txt" 2>&1
[ "$(git rev-parse HEAD)" = "d51a191098f483cea9abec6cc7e9f3beffd18c06" ] || die provenance-head 2
[ -d node_modules ] || die provenance-node-modules-absent-setup-not-granted 2
grep -q "ancestor_root_absent=yes" "$LOGS/c5.provenance.txt" || die provenance-ancestor-root 2
[ "$(git status --porcelain | grep -vc -E '^\?\? src/services/__tests__/(persistedQueryCache\.hazard|s6diag\.)')" = "0" ] || die provenance-clean 2
rec provenance 0

# 1. frozen diagnostic bytes: every diag file must match the manifest frozen at request time
(cd "$EX" && sha256sum -c --quiet MANIFEST.sha256) > "$LOGS/c5.manifest-check.txt" 2>&1 || die manifest-mismatch-reattribution-required 3
rec manifest 0

# 2. module resolution inside the pinned worktree root only
node -e '
const p=require("path"); const wt=process.argv[1]; let bad=0;
for (const m of ["react","react-test-renderer","react-native","@testing-library/react-native","@tanstack/react-query","@tanstack/query-core","@tanstack/react-query-persist-client","@tanstack/query-persist-client-core","@tanstack/query-async-storage-persister","@react-native-async-storage/async-storage","jest-expo","jest"]) {
  const r=require.resolve(m+"/package.json",{paths:[wt]}); const v=require(r).version; const inside=r.startsWith(p.join(wt,"node_modules")+p.sep);
  console.log(`${inside?"OK ":"BAD"} ${m}@${v} ${r}`); if(!inside) bad++; }
process.exit(bad?1:0)' "$WT" > "$LOGS/c5.module-paths.txt" 2>&1 || die module-paths 5
rec module-paths 0

# 3. copy exact inputs (untracked) and verify digests
cp "$IN/persistedQueryCache.hazardControls.test.tsx" "$TESTDIR/"
cp "$IN/persistedQueryCache.hazardAdapter.tsx" "$TESTDIR/"
cp "$DIAG/specs/s6diag.A.noop.test.js" "$DIAG/specs/s6diag.B.importOnly.test.js" "$DIAG/specs/s6diag.D.persisterLifecycle.test.js" "$TESTDIR/"
[ "$(sha $TESTDIR/persistedQueryCache.hazardControls.test.tsx)" = "ee9b94df1ceae5d90ad53700f119b75b0a2e9a6640339c27e2dca29d1f51bba6" ] || die fingerprint-v4-hazard 4
[ "$(sha $TESTDIR/persistedQueryCache.hazardAdapter.tsx)" = "3796be8fae738993bcc5c30dd7d4cf9b303329b8faa990ca03e31c2460cd35f3" ] || die fingerprint-adapter 4
{ sha256sum $TESTDIR/persistedQueryCache.hazard* $TESTDIR/s6diag.*; git status --porcelain; } > "$LOGS/c5.fingerprint.txt" 2>&1
[ "$(git status --porcelain | grep -vc -E '^\?\? src/services/__tests__/(persistedQueryCache\.hazard|s6diag\.)')" = "0" ] || die fingerprint-clean 4
rec copy-inputs 0

# 4. step 0: instrument self-check (pure node, no node_modules, no product code)
S6DIAG_LOG=$LOGS/c5.selftest.inventory.jsonl $CPU timeout -k 5 15 node "$DIAG/s6diag.selftest.js" > "$LOGS/c5.selftest.out" 2>&1; rc=$?
rec selftest $rc; [ $rc -eq 0 ] || die selftest-instrument-unfit $rc

# 5. step A: preset + instrument negative control — must exit on its own
rc=$(JEST A 45 15 "$TESTDIR/s6diag.A.noop.test.js"); rec A-noop "$rc"
[ "$rc" -eq 0 ] || die A-noop-HANG_OR_FAIL-runner_or_preset_or_instrument "$rc"
grep -q 'PROCESS_EXITED_ON_ITS_OWN' "$LOGS/c5.A.summary.txt" || die A-noop-no-beforeExit 9

# 6. step B: production import-only control
rc=$(JEST B 45 15 "$TESTDIR/s6diag.B.importOnly.test.js"); rec B-importOnly "$rc"
[ "$rc" -eq 124 ] || [ "$rc" -eq 137 ] && die B-importOnly-HANG-production_import_time_ownership "$rc"
[ "$rc" -eq 0 ] || die B-importOnly "$rc"

# 7. step D: production persistence lifecycle without React/signOut
rc=$(JEST D 60 15 "$TESTDIR/s6diag.D.persisterLifecycle.test.js"); rec D-persisterLifecycle "$rc"
if [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ]; then
  echo "D-HANG: production persistence lifecycle retains a resource without any harness" >> "$EXIT_RECORD"
  [ "$CONTINUE_AFTER_D_HANG" = "1" ] || die D-persisterLifecycle-HANG-production_lifecycle_ownership "$rc"
elif [ "$rc" -ne 0 ]; then die D-persisterLifecycle "$rc"; fi

# 8. step C: the unchanged v4 hazard file + adapter under the inventory. Expected: 6/6, 0 overlapping act,
#    then the C2/C3/C4 hang preserved (rc 124) with owners recorded at globalTeardown/ticks/SIGTERM.
rc=$(JEST C 90 20 "$TESTDIR/persistedQueryCache.hazardControls.test.tsx"); rec C-hazard-v4-inventory "$rc"
{ echo "tests_line: $(grep -m1 '^Tests:' "$LOGS/c5.C.jest.log")"
  echo "overlapping_act: $(grep -c 'overlapping act' "$LOGS/c5.C.jest.log")"
  echo "mode_line_present: $(grep -c '\[mode=d51-singleton\]' "$LOGS/c5.C.jest.log")"
  echo "did_not_exit_line: $(grep -c 'did not exit one second' "$LOGS/c5.C.jest.log")"
  echo "timeout_rc: $rc"; } > "$LOGS/c5.C.checks.txt"
grep -q '^Tests:       6 passed, 6 total' "$LOGS/c5.C.jest.log" || echo "C-BEHAVIOURAL-DIVERGENCE: six assertions not preserved under instrument" >> "$EXIT_RECORD"
[ "$(grep -c 'overlapping act' "$LOGS/c5.C.jest.log")" = "0" ] || echo "C-OVERLAPPING-ACT under instrument" >> "$EXIT_RECORD"
if [ "$rc" -eq 0 ]; then echo "C-PERTURBATION-DIVERGENCE: hazard file exited cleanly under instrument (C2/C3/C4 hung) — not acceptance" >> "$EXIT_RECORD"; fi
echo "FINAL rc=$rc" >> "$EXIT_RECORD"   # real first exit of the diagnostic step; 124 is the EXPECTED preserved hang
group_check
exit "$rc"
