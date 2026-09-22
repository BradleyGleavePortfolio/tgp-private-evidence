#!/usr/bin/env bash
# C5-S6-RESOURCE-INVENTORY V2 — supervisor with explicit owned child process groups.
# NOT LAUNCHED until the parent grants a named slot. V1 (../run-c5-resource-inventory.sh) is preserved, not executed.
# V2 vs V1: (0) FACTUAL CORRECTION: /home/user/node_modules pre-exists (platform-owned, 212 links, Sep 20; no /home/user/package.json).
#   V1's absent-ancestor-root guard would refuse immediately and is wrong; V2 snapshots the ancestor inventory before/after
#   (must be unchanged) and requires STRICT resolution of every relevant module to $WT/node_modules. (1) runner acquires and HOLDS the canonical lock itself (fd 9) through cleanup; (2) every child is started
# with `setsid` into its own process group that this runner owns and records; no `timeout`, no command substitution
# around children; (3) per-step budget + grace enforced by this supervisor (poll loop) — first_exit (rc from `wait`,
# plus how it ended) is recorded separately from cleanup_exit; (4) TERM/INT/HUP and EXIT traps reap only OWNED groups,
# never the parent, flock, nohup or platform processes; (5) outer BUDGET enforced before every step; external bound
# is the invocation's `timeout` (below), whose group signal reaches this runner, not the owned child groups —
# the trap forwards to them.
# Invoke (parent-granted; external bound 420 s + 30 s):
#   setsid nohup timeout -k 30 420 bash /home/user/workspace/execution/s6-diagnostic/v2/run-c5-resource-inventory.v2.sh \
#     > /home/user/workspace/execution/s6-diagnostic/logs/v2/run-c5.v2.out 2>&1 < /dev/null &
# Steps: 0 selftest(pure node) → A noop → B import-only → D persistence lifecycle (no React) → C unchanged v4 hazard+adapter.
# No --forceExit, no --detectOpenHandles, no install, no product/adapter/hazard-test byte change, no assertion change.
set -u
WT=/home/user/workspace/worktrees/s6-diagnostic
EX=/home/user/workspace/execution/s6-diagnostic
V2=$EX/v2
DIAG=$V2/diag
IN=$EX/inputs
LOGS=$EX/logs/v2
LOCK=/home/user/workspace/execution/test-validation.lock
EXIT_RECORD=$LOGS/c5v2.EXIT_RECORD
START=$(date +%s)
BUDGET=360            # inner budget (s): steps refuse to start if remaining < their own budget+grace
export CI=1 NODE_OPTIONS=--max-old-space-size=2048 TZ=UTC
export EXPO_PUBLIC_FF_EXTENSION_IMPORT= EXPO_PUBLIC_FF_IMPORT_REVIEW=
export S6DIAG_WT=$WT
CPU="taskset -c 0,1"
CONTINUE_AFTER_D_HANG=${S6DIAG_CONTINUE_AFTER_D_HANG:-0}
TESTDIR=src/services/__tests__
OWNED_PGIDS=""        # every child group this runner created (space separated)
CUR_PID=""; CUR_PGID=""; CUR_STEP=""
FIRST_EXIT=""         # "<step> rc=<n> how=<exited|budget-TERM|budget-KILL|runner-signal>"

ts() { date -u +%FT%TZ; }
ancestor_inventory() { ( cd /home/user/node_modules 2>/dev/null && ls -A --time-style=+%s -l | awk '{print $6, $7}' | sort ) | sha256sum | cut -d' ' -f1; }
alive() { # child still running (a not-yet-waited zombie counts as exited; kill -0 alone would report it alive)
  kill -0 "$1" 2>/dev/null || return 1
  [ "$(ps -o stat= -p "$1" 2>/dev/null | cut -c1)" != "Z" ]
}
rec() { echo "$(ts) step=$1 rc=$2 elapsed=$(( $(date +%s) - START ))s ${3:-}" >> "$EXIT_RECORD"; }
elapsed() { echo $(( $(date +%s) - START )); }
sha() { sha256sum "$1" | cut -d' ' -f1; }

# --- owned-group reaping: TERM → grace → KILL, only for a PGID this runner created ---------------------------------
reap_group() { # $1 pgid, $2 grace seconds, $3 label ; echoes cleanup status via EXIT_RECORD
  local pg=$1 grace=$2 label=$3
  case " $OWNED_PGIDS " in *" $pg "*) ;; *) echo "$(ts) REFUSE reap of unowned pgid=$pg ($label)" >> "$EXIT_RECORD"; return 2;; esac
  local members; members=$(pgrep -g "$pg" || true)
  [ -z "$members" ] && { echo "$(ts) cleanup label=$label pgid=$pg members=none cleanup_exit=0" >> "$EXIT_RECORD"; return 0; }
  echo "$(ts) cleanup label=$label pgid=$pg TERM members=[${members//$'\n'/,}]" >> "$EXIT_RECORD"
  kill -TERM -- "-$pg" 2>/dev/null
  local i=0; while [ $i -lt "$grace" ] && pgrep -g "$pg" >/dev/null 2>&1; do sleep 1; i=$((i+1)); done
  if pgrep -g "$pg" >/dev/null 2>&1; then
    members=$(pgrep -g "$pg" || true)
    echo "$(ts) cleanup label=$label pgid=$pg KILL after ${grace}s members=[${members//$'\n'/,}]" >> "$EXIT_RECORD"
    kill -KILL -- "-$pg" 2>/dev/null; sleep 1
  fi
  members=$(pgrep -g "$pg" || true)
  if [ -n "$members" ]; then echo "$(ts) cleanup label=$label pgid=$pg SURVIVORS=[${members//$'\n'/,}] cleanup_exit=1 (quarantine: report, do not retry)" >> "$EXIT_RECORD"; return 1; fi
  echo "$(ts) cleanup label=$label pgid=$pg members=none cleanup_exit=0" >> "$EXIT_RECORD"; return 0
}
final_accounting() {
  if [ -n "${ANCESTOR_BEFORE:-}" ]; then local a; a=$(ancestor_inventory); echo "$(ts) ancestor_inventory_before=$ANCESTOR_BEFORE after=$a $([ "$a" = "$ANCESTOR_BEFORE" ] && echo UNCHANGED || echo CHANGED-report)" >> "$EXIT_RECORD"; fi
  local pg; for pg in $OWNED_PGIDS; do
    local m; m=$(pgrep -g "$pg" || true); echo "$(ts) final owned pgid=$pg members=[${m//$'\n'/,}]" >> "$EXIT_RECORD"; done
  echo "$(ts) lock held until exit (fd 9); runner pid=$$ pgid=$(ps -o pgid= $$ | tr -d ' ')" >> "$EXIT_RECORD"
}
on_signal() { # runner itself received TERM/INT/HUP (external bound or operator): reap the current owned group, keep first exit
  trap '' TERM INT HUP
  echo "$(ts) RUNNER-SIGNAL received during step=${CUR_STEP:-none} child_pid=${CUR_PID:-none} child_pgid=${CUR_PGID:-none}" >> "$EXIT_RECORD"
  if [ -n "$CUR_PGID" ]; then reap_group "$CUR_PGID" 10 "runner-signal:$CUR_STEP"; fi
  [ -n "$FIRST_EXIT" ] || FIRST_EXIT="${CUR_STEP:-none} rc=143 how=runner-signal"
  echo "FIRST_EXIT $FIRST_EXIT" >> "$EXIT_RECORD"; echo "FINAL rc=143 (runner terminated externally)" >> "$EXIT_RECORD"
  final_accounting; exit 143
}
on_exit() { final_accounting; }
trap on_signal TERM INT HUP
trap on_exit EXIT

die() { rec "$1" "$2" "${3:-}"; echo "STOP_FIRST_FAILURE step=$1 rc=$2" >> "$EXIT_RECORD"; [ -n "$FIRST_EXIT" ] || FIRST_EXIT="$1 rc=$2 how=exited"; echo "FIRST_EXIT $FIRST_EXIT" >> "$EXIT_RECORD"; echo "FINAL rc=$2" >> "$EXIT_RECORD"; exit "$2"; }

# --- supervised child in its own owned process group ------------------------------------------------------------------
# run_owned <step> <budget> <grace> <stdout/err log> -- <command...>
# sets RUN_RC (wait status) and RUN_HOW (exited|budget-TERM|budget-KILL)
run_owned() {
  local step=$1 budget=$2 grace=$3 log=$4; shift 4; [ "$1" = "--" ] && shift
  local need=$(( budget + grace + 5 ))
  if [ $(( BUDGET - $(elapsed) )) -lt "$need" ]; then RUN_RC=75; RUN_HOW=budget-refused; echo "$(ts) step=$step REFUSED: remaining $(( BUDGET - $(elapsed) ))s < needed ${need}s" >> "$EXIT_RECORD"; return; fi
  CUR_STEP=$step
  setsid "$@" > "$log" 2>&1 < /dev/null &
  CUR_PID=$!
  sleep 0.2
  CUR_PGID=$(ps -o pgid= "$CUR_PID" 2>/dev/null | tr -d ' ')
  [ -z "$CUR_PGID" ] && CUR_PGID=$CUR_PID
  OWNED_PGIDS="$OWNED_PGIDS $CUR_PGID"
  echo "$(ts) step=$step START child_pid=$CUR_PID child_pgid=$CUR_PGID budget=${budget}s grace=${grace}s cmd=[$*]" >> "$EXIT_RECORD"
  local waited=0
  while alive "$CUR_PID" && [ $waited -lt "$budget" ]; do sleep 1; waited=$((waited+1)); done
  if alive "$CUR_PID"; then
    RUN_HOW=budget-TERM
    echo "$(ts) step=$step BUDGET ${budget}s reached: TERM owned pgid=$CUR_PGID" >> "$EXIT_RECORD"
    kill -TERM -- "-$CUR_PGID" 2>/dev/null
    local g=0; while alive "$CUR_PID" && [ $g -lt "$grace" ]; do sleep 1; g=$((g+1)); done
    if alive "$CUR_PID"; then RUN_HOW=budget-KILL; echo "$(ts) step=$step grace ${grace}s exhausted: KILL owned pgid=$CUR_PGID" >> "$EXIT_RECORD"; kill -KILL -- "-$CUR_PGID" 2>/dev/null; fi
  else
    RUN_HOW=exited
  fi
  wait "$CUR_PID"; RUN_RC=$?
  echo "$(ts) step=$step first_exit rc=$RUN_RC how=$RUN_HOW child_pid=$CUR_PID" >> "$EXIT_RECORD"
  # any stragglers in the owned group (grandchildren) are reaped separately: cleanup_exit, never merged into first_exit
  reap_group "$CUR_PGID" 10 "post:$step"; echo "$(ts) step=$step cleanup_exit=$?" >> "$EXIT_RECORD"
  CUR_PID=""; CUR_PGID=""; CUR_STEP=""
}
JEST_ARGS() { # $1 spec
  echo "$1 --ci --runInBand --verbose --setupFilesAfterEnv=$WT/jest.setup.js --setupFilesAfterEnv=$DIAG/s6diag.setupAfterEnv.js --globalSetup=$DIAG/s6diag.globalSetup.js --globalTeardown=$DIAG/s6diag.globalTeardown.js"
}
jest_step() { # $1 step $2 budget $3 grace $4 spec → RUN_RC/RUN_HOW, summary written
  local step=$1
  S6DIAG_LOG=$LOGS/c5v2.$step.inventory.jsonl S6DIAG_STEP=$step \
    run_owned "$step" "$2" "$3" "$LOGS/c5v2.$step.jest.log" -- $CPU node node_modules/jest/bin/jest.js $(JEST_ARGS "$4")
  node "$DIAG/s6diag.summarize.js" "$LOGS/c5v2.$step.inventory.jsonl" "$LOGS/c5v2.$step.jest.log" "$step" "$RUN_RC" > "$LOGS/c5v2.$step.summary.txt" 2>&1
  echo "$(ts) step=$step summary: $(head -1 "$LOGS/c5v2.$step.summary.txt")" >> "$EXIT_RECORD"
}

mkdir -p "$LOGS"
echo "$(ts) START pid=$$ pgid=$(ps -o pgid= $$ | tr -d ' ') ppid=$PPID" > "$EXIT_RECORD"
# canonical lock: acquired by the runner itself, held on fd 9 until the process exits (after all cleanup)
exec 9>"$LOCK"
flock -n 9 || die lock-busy 75 "canonical lock held by another owner; not a grant problem to solve here"
echo "$(ts) lock acquired fd=9 path=$LOCK" >> "$EXIT_RECORD"
cd "$WT" || die cd 1

# 0. provenance
{ echo "HEAD=$(git rev-parse HEAD)"; echo "TREE=$(git rev-parse HEAD^{tree})"; echo "lock_blob=$(git ls-files -s package-lock.json | awk '{print $2}')"
  echo "node=$(node -v) npm=$(npm -v)"; echo "node_modules_present=$([ -d node_modules ] && echo yes || echo no)"
  echo "ancestor_package_json_absent=$([ ! -e /home/user/package.json ] && echo yes || echo NO)"
  echo "ancestor_node_modules=$(ls -ld /home/user/node_modules 2>&1) entries=$(ls -A /home/user/node_modules 2>/dev/null | wc -l) (platform-owned, pre-existing Sep 20; never touched by this runner)"
  git status --porcelain | sed 's/^/status: /'; } > "$LOGS/c5v2.provenance.txt" 2>&1
# ancestor inventory snapshot (read-only): names + mtimes of /home/user/node_modules entries; compared again at the end
ANCESTOR_BEFORE=$(ancestor_inventory); echo "ancestor_inventory_before=$ANCESTOR_BEFORE" >> "$LOGS/c5v2.provenance.txt"
[ "$(git rev-parse HEAD)" = "d51a191098f483cea9abec6cc7e9f3beffd18c06" ] || die provenance-head 2
[ -d node_modules ] || die provenance-node-modules-absent-setup-not-granted 2
grep -q "ancestor_package_json_absent=yes" "$LOGS/c5v2.provenance.txt" || die provenance-ancestor-package-json 2
[ "$(git status --porcelain | grep -vc -E '^\?\? src/services/__tests__/(persistedQueryCache\.hazard|s6diag\.)')" = "0" ] || die provenance-clean 2
rec provenance 0

# 1. frozen V2 bytes
(cd "$V2" && sha256sum -c --quiet MANIFEST.v2.sha256) > "$LOGS/c5v2.manifest-check.txt" 2>&1 || die manifest-mismatch-reattribution-required 3
rec manifest 0

# 2. STRICT module resolution: every relevant module must resolve to $WT/node_modules (the ancestor /home/user/node_modules
#    contains @babel/* and would be the fallback if the worktree copy were missing — any such fallback is a hard stop)
node -e '
const p=require("path"); const wt=process.argv[1]; let bad=0;
for (const m of ["react","react-test-renderer","react-native","@testing-library/react-native","@tanstack/react-query","@tanstack/query-core","@tanstack/react-query-persist-client","@tanstack/query-persist-client-core","@tanstack/query-async-storage-persister","@react-native-async-storage/async-storage","jest-expo","jest","jest-circus","jest-runtime","@jest/core","babel-jest","@babel/core","@babel/preset-env","babel-preset-expo","zustand","scheduler"]) {
  const r=require.resolve(m+"/package.json",{paths:[wt]}); const v=require(r).version; const inside=r.startsWith(p.join(wt,"node_modules")+p.sep);
  console.log(`${inside?"OK ":"BAD"} ${m}@${v} ${r}`); if(!inside) bad++; }
process.exit(bad?1:0)' "$WT" > "$LOGS/c5v2.module-paths.txt" 2>&1 || die module-paths 5
rec module-paths 0

# 3. exact inputs (untracked copies, declared) and digests
cp "$IN/persistedQueryCache.hazardControls.test.tsx" "$IN/persistedQueryCache.hazardAdapter.tsx" "$TESTDIR/"
cp "$DIAG/specs/s6diag.A.noop.test.js" "$DIAG/specs/s6diag.B.importOnly.test.js" "$DIAG/specs/s6diag.D.persisterLifecycle.test.js" "$TESTDIR/"
[ "$(sha $TESTDIR/persistedQueryCache.hazardControls.test.tsx)" = "ee9b94df1ceae5d90ad53700f119b75b0a2e9a6640339c27e2dca29d1f51bba6" ] || die fingerprint-v4-hazard 4
[ "$(sha $TESTDIR/persistedQueryCache.hazardAdapter.tsx)" = "3796be8fae738993bcc5c30dd7d4cf9b303329b8faa990ca03e31c2460cd35f3" ] || die fingerprint-adapter 4
{ sha256sum $TESTDIR/persistedQueryCache.hazard* $TESTDIR/s6diag.*; git status --porcelain; } > "$LOGS/c5v2.fingerprint.txt" 2>&1
[ "$(git status --porcelain | grep -vc -E '^\?\? src/services/__tests__/(persistedQueryCache\.hazard|s6diag\.)')" = "0" ] || die fingerprint-clean 4
rec copy-inputs 0

# 4. step 0: instrument self-check (pure node, no node_modules, no product code)
S6DIAG_LOG=$LOGS/c5v2.selftest.inventory.jsonl S6DIAG_STEP=selftest run_owned selftest 15 5 "$LOGS/c5v2.selftest.out" -- $CPU node "$DIAG/s6diag.selftest.js"
rec selftest "$RUN_RC" "how=$RUN_HOW"; [ "$RUN_RC" -eq 0 ] || die selftest-instrument-unfit "$RUN_RC"

# 5. step A: preset + instrument negative control — must exit on its own
jest_step A 45 15 "$TESTDIR/s6diag.A.noop.test.js"; rec A-noop "$RUN_RC" "how=$RUN_HOW"
[ "$RUN_RC" -eq 0 ] || die A-noop-HANG_OR_FAIL-runner_or_preset_or_instrument "$RUN_RC"
grep -q 'PROCESS_EXITED_ON_ITS_OWN' "$LOGS/c5v2.A.summary.txt" || die A-noop-no-beforeExit 9

# 6. step B: production import-only control
jest_step B 45 15 "$TESTDIR/s6diag.B.importOnly.test.js"; rec B-importOnly "$RUN_RC" "how=$RUN_HOW"
[ "$RUN_HOW" = "exited" ] || die B-importOnly-HANG-production_import_time_ownership "$RUN_RC"
[ "$RUN_RC" -eq 0 ] || die B-importOnly "$RUN_RC"

# 7. step D: production persistence lifecycle without React/signOut
jest_step D 60 15 "$TESTDIR/s6diag.D.persisterLifecycle.test.js"; rec D-persisterLifecycle "$RUN_RC" "how=$RUN_HOW"
if [ "$RUN_HOW" != "exited" ]; then
  echo "D-HANG: production persistence lifecycle retains a resource without any harness" >> "$EXIT_RECORD"
  [ "$CONTINUE_AFTER_D_HANG" = "1" ] || die D-persisterLifecycle-HANG-production_lifecycle_ownership "$RUN_RC"
elif [ "$RUN_RC" -ne 0 ]; then die D-persisterLifecycle "$RUN_RC"; fi

# 8. step C: unchanged v4 hazard file + adapter under the inventory. Expected: 6/6, 0 overlapping act, then the
#    C2/C3/C4 hang preserved (how=budget-TERM, rc 143 from the re-raised SIGTERM) with owners recorded.
jest_step C 90 20 "$TESTDIR/persistedQueryCache.hazardControls.test.tsx"; rec C-hazard-v4-inventory "$RUN_RC" "how=$RUN_HOW"
{ echo "tests_line: $(grep -m1 '^Tests:' "$LOGS/c5v2.C.jest.log")"
  echo "overlapping_act: $(grep -c 'overlapping act' "$LOGS/c5v2.C.jest.log")"
  echo "mode_line_present: $(grep -c '\[mode=d51-singleton\]' "$LOGS/c5v2.C.jest.log")"
  echo "did_not_exit_line: $(grep -c 'did not exit one second' "$LOGS/c5v2.C.jest.log")"
  echo "first_exit_rc: $RUN_RC how: $RUN_HOW"; } > "$LOGS/c5v2.C.checks.txt"
grep -q '^Tests:       6 passed, 6 total' "$LOGS/c5v2.C.jest.log" || echo "C-BEHAVIOURAL-DIVERGENCE: six assertions not preserved under instrument" >> "$EXIT_RECORD"
[ "$(grep -c 'overlapping act' "$LOGS/c5v2.C.jest.log")" = "0" ] || echo "C-OVERLAPPING-ACT under instrument" >> "$EXIT_RECORD"
[ "$RUN_HOW" = "exited" ] && echo "C-PERTURBATION-DIVERGENCE: hazard file exited on its own under instrument (C2/C3/C4 hung) — not acceptance" >> "$EXIT_RECORD"
FIRST_EXIT="C rc=$RUN_RC how=$RUN_HOW"
echo "FIRST_EXIT $FIRST_EXIT" >> "$EXIT_RECORD"
echo "FINAL rc=$RUN_RC (diagnostic step's real first exit; budget-TERM/143 is the EXPECTED preserved hang, not success)" >> "$EXIT_RECORD"
exit "$RUN_RC"
