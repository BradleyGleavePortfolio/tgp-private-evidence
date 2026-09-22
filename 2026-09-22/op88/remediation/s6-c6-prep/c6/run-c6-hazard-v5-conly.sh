#!/usr/bin/env bash
# C6-S6-HAZARD-V5-C-ONLY — additive wrapper derived from the frozen V3.1 runner (b7b328a5…0776), which is NOT altered.
#   Purpose (OP88-S6-C6-PREP, after frozen S6_C5_REVIEW_B.md §8): one C step only, hazard v5 (= v4 ee9b94df + `await
#   qc.queryClient.cancelQueries()` before the existing clear() in afterEach and afterAll; nothing else) with the UNCHANGED
#   adapter 3796be8f… and the UNCHANGED v3.1 instrument set (main.js cf470101…, hooks, summarize) verified by MANIFEST.c6.sha256.
#   Differences from V3.1, all declared (see ../DIFF_runner_v3.1_to_c6.patch and ../S6_C6_PREP.md §4):
#     paths  : packet dir C6=/home/user/workspace/execution/op88/s6-c6-prep/c6 (inputs/, diag/, MANIFEST.c6.sha256, c6classify.js);
#              logs in /home/user/workspace/execution/op88/s6-c6-prep/logs/c6 with prefix `c6.`; WT and LOCK unchanged.
#     steps  : selftest (instrument fit in the fresh install) then C only. A/B/D are NOT repeated (C5 A/B/D clean exits stand).
#     inputs : two declared untracked copies (hazard v5 + adapter); v5 fingerprint a91bb732… replaces the v4 gate ee9b94df….
#     budget : C 90 s + 20 s grace and selftest 15 s + 5 s UNCHANGED; inner BUDGET 180 (was 360, five steps); external 240 + 30.
#     outcome: the V3.1 line "C exited on its own => C-PERTURBATION-DIVERGENCE" is REPLACED by the pre-declared C6 outcome
#              classifier (c6classify.js): (i) 2 residual 600000 ms removeObserver timers + hang; (ii) 0 + clean exit;
#              (iii) 5 + hang; (iv) six-assertion/overlap/mode divergence = STOP; else UNCLASSIFIED. FINAL rc semantics unchanged
#              (primary rc preserved; any cleanup evidence forces nonzero). Neither FINAL 143 nor FINAL 0 is acceptance.
#   Unchanged from V3.1: lock fd 9 held by the runner, 9>&- in children, owned setsid groups, zombie-aware poll, TERM/KILL reaping,
#   M-1 stop after cleanup survivors, M-2 rm-failure count + porcelain gate, ancestor inventory gate, strict 20-module resolution,
#   hash-guarded copy removal, provenance HEAD gate d51a1910, no --forceExit/--detectOpenHandles, no install, no product edit.
#   Invoke (parent-granted only; after a separately granted positive setup; see ../C6_EXECUTION_REQUEST.md):
#     mkdir -p /home/user/workspace/execution/op88/s6-c6-prep/logs/c6 && \
#     setsid nohup timeout -k 30 240 bash /home/user/workspace/execution/op88/s6-c6-prep/c6/run-c6-hazard-v5-conly.sh \
#       > /home/user/workspace/execution/op88/s6-c6-prep/logs/c6/run-c6.out 2>&1 < /dev/null &
# (V3.1/V3/V2 headers kept below for lineage; their Invoke/Steps lines describe V3.1, not this wrapper.)
# C5-S6-RESOURCE-INVENTORY V3.1 — execution-only successor of V3 (1664fd47…) closing reviewer-B addendum-2 M-1/M-2:
#   M-1: a nonzero per-step cleanup_exit (owned group still has members after TERM/KILL) now STOPS the run immediately
#        (die rc 90) before any further child is spawned; the step's real first exit is preserved in FIRST_EXIT.
#   M-2: `rm -f` failure of a declared copy is logged and counted; worktree porcelain must be 0 after cleanup (gate).
#   Rebinds only the manifest name (MANIFEST.v3.1.sha256). Instrument cf470101…, hooks, specs, inputs unchanged.
# (V3 header kept below for lineage.)
# C5-S6-RESOURCE-INVENTORY V3 — execution-only successor of V2 (a38994e4…). Closes reviewer-B findings on the runner:
#   B-01 binding: DIAG=$V3/diag with the exact self-checked V3 instrument (main.js cf470101…) and MANIFEST.v3.sha256.
#   B-02: strict module list aligned to the 20 lockfile-present modules (no @babel/preset-env); require.resolve errors caught.
#   B-03: the five untracked copies are removed at the end ONLY if their bytes still equal the frozen sources (hash-guarded);
#         otherwise retained and reported. B-04: lock fd 9 closed in every child (9>&-). B-06: C's expected outcome is
#         budget-TERM(143) or budget-KILL(137) with >=1 post-teardown snapshot. Fail-closed: any nonzero cleanup_exit,
#         survivor, ancestor-inventory change or retained copy forces FINAL rc!=0 while FIRST_EXIT is preserved separately.
# (V2 header kept below for lineage.)
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
#   mkdir -p /home/user/workspace/execution/s6-diagnostic/logs/v3.1 && \
#   setsid nohup timeout -k 30 420 bash /home/user/workspace/execution/s6-diagnostic/v3/run-c5-resource-inventory.v3.1.sh \
#     > /home/user/workspace/execution/s6-diagnostic/logs/v3.1/run-c5.v3.1.out 2>&1 < /dev/null &
# Steps: 0 selftest(pure node) → A noop → B import-only → D persistence lifecycle (no React) → C unchanged v4 hazard+adapter.
# No --forceExit, no --detectOpenHandles, no install, no product/adapter/hazard-test byte change, no assertion change.
set -u
WT=/home/user/workspace/worktrees/s6-diagnostic
C6=/home/user/workspace/execution/op88/s6-c6-prep/c6
DIAG=$C6/diag
IN=$C6/inputs
LOGS=/home/user/workspace/execution/op88/s6-c6-prep/logs/c6
LOCK=/home/user/workspace/execution/test-validation.lock
EXIT_RECORD=$LOGS/c6.EXIT_RECORD
START=$(date +%s)
BUDGET=180            # inner budget (s): steps refuse to start if remaining < their own budget+grace (selftest 25 + C 115 + preflight)
export CI=1 NODE_OPTIONS=--max-old-space-size=2048 TZ=UTC
export EXPO_PUBLIC_FF_EXTENSION_IMPORT= EXPO_PUBLIC_FF_IMPORT_REVIEW=
export S6DIAG_WT=$WT
CPU="taskset -c 0,1"
TESTDIR=src/services/__tests__
OWNED_PGIDS=""        # every child group this runner created (space separated)
CUR_PID=""; CUR_PGID=""; CUR_STEP=""
FIRST_EXIT=""         # "<step> rc=<n> how=<exited|budget-TERM|budget-KILL|runner-signal>"
CLEANUP_FAILURES=0    # any nonzero cleanup_exit / survivor / ancestor change / retained copy -> FINAL cannot be 0
ACCOUNTED=0
COPIES="persistedQueryCache.hazardControls.test.tsx persistedQueryCache.hazardAdapter.tsx"
HAZARD_V5_SHA=a91bb732716b500122e291714bf437872cb81930c020812042f84ed87f6a184d   # v5 = v4 ee9b94df… + two-hook cancelQueries delta
ADAPTER_SHA=3796be8fae738993bcc5c30dd7d4cf9b303329b8faa990ca03e31c2460cd35f3     # unchanged

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
copy_source() { echo "$IN/$1"; } # C6: both declared copies come from the packet inputs/ (no diag specs are placed)
cleanup_copies() { # B-03: remove a declared copy only if its bytes still equal the frozen source; else retain + report
  local f src dst; for f in $COPIES; do src=$(copy_source "$f"); dst=$WT/$TESTDIR/$f
    [ -e "$dst" ] || { echo "$(ts) copy $f absent (never placed or already removed)" >> "$EXIT_RECORD"; continue; }
    if [ "$(sha "$dst")" = "$(sha "$src")" ]; then
      if rm -f "$dst"; then echo "$(ts) copy $f removed (hash-guarded, equal to frozen source)" >> "$EXIT_RECORD"
      else echo "$(ts) copy $f rm FAILED — retained; counted" >> "$EXIT_RECORD"; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); fi
    else echo "$(ts) copy $f RETAINED: bytes differ from frozen source ($(sha "$dst")) — report, not deleted" >> "$EXIT_RECORD"; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); fi; done
  local n; n=$(cd "$WT" && git status --porcelain | wc -l)
  ( cd "$WT" && echo "$(ts) worktree porcelain after cleanup: $n line(s) $(git status --porcelain | tr '\n' ' ')" >> "$EXIT_RECORD" )
  [ "$n" = 0 ] || { echo "$(ts) porcelain GATE FAILED ($n line(s) remain in worktree)" >> "$EXIT_RECORD"; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); }; }
final_accounting() {
  [ "$ACCOUNTED" = 1 ] && return; ACCOUNTED=1
  if [ -n "${ANCESTOR_BEFORE:-}" ]; then local a; a=$(ancestor_inventory)
    if [ "$a" = "$ANCESTOR_BEFORE" ]; then echo "$(ts) ancestor_inventory_before=$ANCESTOR_BEFORE after=$a UNCHANGED" >> "$EXIT_RECORD"
    else echo "$(ts) ancestor_inventory_before=$ANCESTOR_BEFORE after=$a CHANGED — GATE FAILED (this runner never writes there; report to parent)" >> "$EXIT_RECORD"; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); fi; fi
  [ "${COPIES_PLACED:-0}" = 1 ] && cleanup_copies
  local pg; for pg in $OWNED_PGIDS; do
    local m; m=$(pgrep -g "$pg" || true); echo "$(ts) final owned pgid=$pg members=[${m//$'\n'/,}]" >> "$EXIT_RECORD"
    [ -n "$m" ] && CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); done
  echo "$(ts) CLEANUP_FAILURES=$CLEANUP_FAILURES lock held until exit (fd 9); runner pid=$$ pgid=$(ps -o pgid= $$ | tr -d ' ')" >> "$EXIT_RECORD"
}
finish() { # $1 = primary rc. FIRST_EXIT already recorded by caller. Fail closed on any cleanup evidence.
  final_accounting
  if [ "$CLEANUP_FAILURES" -gt 0 ]; then echo "FINAL rc=$(( $1 == 0 ? 90 : $1 )) (primary rc=$1 preserved in FIRST_EXIT; CLEANUP_FAILURES=$CLEANUP_FAILURES => fail-closed, rc 90 if primary was 0)" >> "$EXIT_RECORD"; [ "$1" -eq 0 ] && exit 90 || exit "$1"; fi
  echo "FINAL rc=$1" >> "$EXIT_RECORD"; exit "$1"
}
on_signal() { # runner itself received TERM/INT/HUP (external bound or operator): reap the current owned group, keep first exit
  trap '' TERM INT HUP
  echo "$(ts) RUNNER-SIGNAL received during step=${CUR_STEP:-none} child_pid=${CUR_PID:-none} child_pgid=${CUR_PGID:-none}" >> "$EXIT_RECORD"
  if [ -n "$CUR_PGID" ]; then reap_group "$CUR_PGID" 10 "runner-signal:$CUR_STEP"; fi
  [ -n "$FIRST_EXIT" ] || FIRST_EXIT="${CUR_STEP:-none} rc=143 how=runner-signal"
  echo "FIRST_EXIT $FIRST_EXIT" >> "$EXIT_RECORD"; echo "$(ts) runner terminated externally (primary 143)" >> "$EXIT_RECORD"
  finish 143
}
on_exit() { final_accounting; }
trap on_signal TERM INT HUP
trap on_exit EXIT

die() { rec "$1" "$2" "${3:-}"; echo "STOP_FIRST_FAILURE step=$1 rc=$2" >> "$EXIT_RECORD"; [ -n "$FIRST_EXIT" ] || FIRST_EXIT="$1 rc=$2 how=exited"; echo "FIRST_EXIT $FIRST_EXIT" >> "$EXIT_RECORD"; finish "$2"; }

# --- supervised child in its own owned process group ------------------------------------------------------------------
# run_owned <step> <budget> <grace> <stdout/err log> -- <command...>
# sets RUN_RC (wait status) and RUN_HOW (exited|budget-TERM|budget-KILL)
run_owned() {
  local step=$1 budget=$2 grace=$3 log=$4; shift 4; [ "$1" = "--" ] && shift
  local need=$(( budget + grace + 5 ))
  if [ $(( BUDGET - $(elapsed) )) -lt "$need" ]; then RUN_RC=75; RUN_HOW=budget-refused; echo "$(ts) step=$step REFUSED: remaining $(( BUDGET - $(elapsed) ))s < needed ${need}s" >> "$EXIT_RECORD"; return; fi
  CUR_STEP=$step
  setsid "$@" > "$log" 2>&1 < /dev/null 9>&- &
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
  reap_group "$CUR_PGID" 10 "post:$step"; local ce=$?; echo "$(ts) step=$step cleanup_exit=$ce" >> "$EXIT_RECORD"
  CUR_PID=""; CUR_PGID=""; CUR_STEP=""
  [ "$ce" -eq 0 ] || { CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); [ -n "$FIRST_EXIT" ] || FIRST_EXIT="$step rc=$RUN_RC how=$RUN_HOW"
    die "$step-cleanup-survivors" 90 "cleanup_exit=$ce; quarantined owned group unresolved — stop, do not start next step"; }
}
JEST_ARGS() { # $1 spec
  echo "$1 --ci --runInBand --verbose --setupFilesAfterEnv=$WT/jest.setup.js --setupFilesAfterEnv=$DIAG/s6diag.setupAfterEnv.js --globalSetup=$DIAG/s6diag.globalSetup.js --globalTeardown=$DIAG/s6diag.globalTeardown.js"
}
jest_step() { # $1 step $2 budget $3 grace $4 spec → RUN_RC/RUN_HOW, summary written
  local step=$1
  S6DIAG_LOG=$LOGS/c6.$step.inventory.jsonl S6DIAG_STEP=$step \
    run_owned "$step" "$2" "$3" "$LOGS/c6.$step.jest.log" -- $CPU node node_modules/jest/bin/jest.js $(JEST_ARGS "$4")
  node "$DIAG/s6diag.summarize.js" "$LOGS/c6.$step.inventory.jsonl" "$LOGS/c6.$step.jest.log" "$step" "$RUN_RC" > "$LOGS/c6.$step.summary.txt" 2>&1
  echo "$(ts) step=$step summary: $(head -1 "$LOGS/c6.$step.summary.txt")" >> "$EXIT_RECORD"
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
  git status --porcelain | sed 's/^/status: /'; } > "$LOGS/c6.provenance.txt" 2>&1
# ancestor inventory snapshot (read-only): names + mtimes of /home/user/node_modules entries; compared again at the end
ANCESTOR_BEFORE=$(ancestor_inventory); echo "ancestor_inventory_before=$ANCESTOR_BEFORE" >> "$LOGS/c6.provenance.txt"
[ "$(git rev-parse HEAD)" = "d51a191098f483cea9abec6cc7e9f3beffd18c06" ] || die provenance-head 2
[ -d node_modules ] || die provenance-node-modules-absent-setup-not-granted 2
grep -q "ancestor_package_json_absent=yes" "$LOGS/c6.provenance.txt" || die provenance-ancestor-package-json 2
[ "$(git status --porcelain | grep -vc -E '^\?\? src/services/__tests__/(persistedQueryCache\.hazard|s6diag\.)')" = "0" ] || die provenance-clean 2
rec provenance 0

# 1. frozen C6 packet bytes: unchanged v3.1 instrument set (diag/*, same hashes as MANIFEST.v3.1.sha256), inputs/ (v5 + adapter),
#    c6classify.js and this runner. Non-self-including (the manifest file itself is not listed).
(cd "$C6" && sha256sum -c --quiet MANIFEST.c6.sha256) > "$LOGS/c6.manifest-check.txt" 2>&1 || die manifest-mismatch-reattribution-required 3
rec manifest 0

# 2. STRICT module resolution: every relevant module must resolve to $WT/node_modules (the ancestor /home/user/node_modules
#    contains @babel/* and would be the fallback if the worktree copy were missing — any such fallback is a hard stop)
node -e '
const p=require("path"); const wt=process.argv[1]; let bad=0;
for (const m of ["react","react-test-renderer","react-native","@testing-library/react-native","@tanstack/react-query","@tanstack/query-core","@tanstack/react-query-persist-client","@tanstack/query-persist-client-core","@tanstack/query-async-storage-persister","@react-native-async-storage/async-storage","jest-expo","jest","jest-circus","jest-runtime","@jest/core","babel-jest","@babel/core","babel-preset-expo","zustand","scheduler"]) {
  let r; try { r=require.resolve(m+"/package.json",{paths:[wt]}); } catch(e){ console.log(`BAD ${m} unresolved: ${e.code||e.message}`); bad++; continue; }
  const v=require(r).version; const inside=r.startsWith(p.join(wt,"node_modules")+p.sep);
  console.log(`${inside?"OK ":"BAD"} ${m}@${v} ${r}`); if(!inside) bad++; }
process.exit(bad?1:0)' "$WT" > "$LOGS/c6.module-paths.txt" 2>&1 || die module-paths 5
rec module-paths 0

# 3. exact inputs (untracked copies, declared) and digests
COPIES_PLACED=1
cp "$IN/persistedQueryCache.hazardControls.test.tsx" "$IN/persistedQueryCache.hazardAdapter.tsx" "$TESTDIR/"
[ "$(sha $TESTDIR/persistedQueryCache.hazardControls.test.tsx)" = "$HAZARD_V5_SHA" ] || die fingerprint-v5-hazard 4
[ "$(sha $TESTDIR/persistedQueryCache.hazardAdapter.tsx)" = "$ADAPTER_SHA" ] || die fingerprint-adapter 4
{ sha256sum $TESTDIR/persistedQueryCache.hazard*; git status --porcelain; } > "$LOGS/c6.fingerprint.txt" 2>&1
[ "$(git status --porcelain | grep -vc -E '^\?\? src/services/__tests__/(persistedQueryCache\.hazard|s6diag\.)')" = "0" ] || die fingerprint-clean 4
rec copy-inputs 0

# 4. step 0: instrument self-check (pure node, no node_modules, no product code) — kept: the install is fresh, the instrument must
#    still fit this process before its C observation is trusted.
S6DIAG_LOG=$LOGS/c6.selftest.inventory.jsonl S6DIAG_STEP=selftest run_owned selftest 15 5 "$LOGS/c6.selftest.out" -- $CPU node "$DIAG/s6diag.selftest.js"
rec selftest "$RUN_RC" "how=$RUN_HOW"; [ "$RUN_RC" -eq 0 ] || die selftest-instrument-unfit "$RUN_RC"

# 5. (V3.1 steps A/B/D are NOT repeated: their C5 clean exits stand; brief non-goal.)

# 6. step C: hazard v5 (cancelQueries before clear in afterEach/afterAll) + unchanged adapter under the unchanged inventory.
#    Same budget/grace as C5's C step (90 s + 20 s) so tick snapshots (+1/3/6/10/20/40/70 s) are comparable.
#    Pre-declared outcomes (S6_C5_REVIEW_B.md §8): (i) 2 residual 600000 ms removeObserver timers + budget-TERM/KILL;
#    (ii) 0 timers + clean exit (rc 0, beforeExit); (iii) 5 timers + hang; (iv) six-assertion/overlap/mode divergence = STOP.
#    A clean exit here is a pre-declared outcome, NOT the V3.1 "perturbation divergence" and NOT acceptance.
jest_step C 90 20 "$TESTDIR/persistedQueryCache.hazardControls.test.tsx"; rec C-hazard-v5-cancel-before-clear "$RUN_RC" "how=$RUN_HOW"
{ echo "tests_line: $(grep -m1 '^Tests:' "$LOGS/c6.C.jest.log")"
  echo "overlapping_act: $(grep -c 'overlapping act' "$LOGS/c6.C.jest.log")"
  echo "mode_line_present: $(grep -c '\[mode=d51-singleton\]' "$LOGS/c6.C.jest.log")"
  echo "did_not_exit_line: $(grep -c 'did not exit one second' "$LOGS/c6.C.jest.log")"
  echo "first_exit_rc: $RUN_RC how: $RUN_HOW"
  node "$C6/c6classify.js" "$LOGS/c6.C.inventory.jsonl" "$LOGS/c6.C.jest.log" "$RUN_RC" "$RUN_HOW" 2>&1; } > "$LOGS/c6.C.checks.txt"
grep -q '^Tests:       6 passed, 6 total' "$LOGS/c6.C.jest.log" || echo "C-BEHAVIOURAL-DIVERGENCE: six assertions not preserved under instrument — outcome (iv), STOP" >> "$EXIT_RECORD"
[ "$(grep -c 'overlapping act' "$LOGS/c6.C.jest.log")" = "0" ] || echo "C-OVERLAPPING-ACT under instrument — outcome (iv), STOP" >> "$EXIT_RECORD"
echo "$(ts) $(grep -m1 '^C6-OUTCOME=' "$LOGS/c6.C.checks.txt" || echo 'C6-OUTCOME=CLASSIFIER-ABSENT')" >> "$EXIT_RECORD"
FIRST_EXIT="C rc=$RUN_RC how=$RUN_HOW"
echo "FIRST_EXIT $FIRST_EXIT" >> "$EXIT_RECORD"
echo "$(ts) C real first exit rc=$RUN_RC how=$RUN_HOW (interpret ONLY via the C6-OUTCOME line and raw c6.C.* files; neither 143 nor 0 is acceptance)" >> "$EXIT_RECORD"
finish "$RUN_RC"
