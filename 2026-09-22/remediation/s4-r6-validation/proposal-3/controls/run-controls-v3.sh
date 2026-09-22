#!/usr/bin/env bash
# S4 R6 V3 — bounded sequential safety-control driver (A-05). NOT a validation run.
#
#   bash execution/s4-r6-validation/v3/controls/run-controls-v3.sh      (only after an explicit parent grant)
#
# Runs the six controls in order through the ACTUAL V3 launcher/stub/library, with explicit per-control
# deadline/grace and an explicit total budget that includes failure cleanup; evaluates field-level
# predicates after each; stops at the first unexpected result (no retry). No network, no install, no
# canonical lock, no worktree, no browser: the only workloads are `sleep`/`true` in owned sessions.
set -u
ROOT=/home/user/workspace
V3=$ROOT/execution/s4-r6-validation/v3
LAUNCHER=$V3/launcher/s4-r6-launch-v3.sh
PRED=$V3/controls/control-predicates-v3.py
RECEIPTS=$V3/control-runs
TOTAL_BUDGET_S=185   # explicit aggregate bound = sum of per-control worst cases below (48+30+33+33+33) + direct-refusal 5 + slack; not a typical duration
mkdir -p "$RECEIPTS" || exit 70
now() { date -u +%FT%TZ; }
T0=$(date +%s)
DRIVER_LOG=$RECEIPTS/DRIVER-$(date -u +%Y%m%dT%H%M%SZ)-$$.log
log() { echo "[$(now)] $*" | tee -a "$DRIVER_LOG"; }
elapsed() { echo $(( $(date +%s) - T0 )); }

# name | outer_s | grace_s | worst_case_s (outer + grace + confirm 10 + reap/publish 7 + driver 3)
CONTROLS=(
  "nested-orphan-after-exit|25|3|48"
  "live-step-interrupt|4|6|30"
  "predicate-rc0|10|3|33"
  "record-without-sentinel|10|3|33"
  "refuse|10|3|33"
)
log "V3 controls start total_budget=${TOTAL_BUDGET_S}s launcher=$(sha256sum "$LAUNCHER" | cut -c1-16) lib=$(sha256sum "$V3/runner/s4-r6-lib-v3.sh" | cut -c1-16) stub=$(sha256sum "$V3/controls/s4-r6-control-stub-v3.sh" | cut -c1-16)"
n=0
for spec in "${CONTROLS[@]}"; do
  IFS='|' read -r name outer grace worst <<< "$spec"; n=$((n+1))
  if (( $(elapsed) + worst > TOTAL_BUDGET_S )); then log "STOP: control $n ($name) worst case ${worst}s would exceed total budget (elapsed $(elapsed)s)"; exit 92; fi
  before=$(ls -1 "$RECEIPTS" | grep -c '^CONTROL-V3-' || :)
  log "control $n/$((${#CONTROLS[@]}+1)) $name outer=${outer}s grace=${grace}s worst=${worst}s"
  S4R6_CONTROL=1 S4R6_SCENARIO=$name S4R6_OUTER_S=$outer S4R6_GRACE_S=$grace bash "$LAUNCHER" >> "$DRIVER_LOG" 2>&1
  lrc=$?
  run_dir=$(ls -1dt "$RECEIPTS"/CONTROL-V3-* 2>/dev/null | head -1)
  after=$(ls -1 "$RECEIPTS" | grep -c '^CONTROL-V3-' || :)
  [[ $after == $((before+1)) && -n $run_dir ]] || { log "STOP: expected exactly one new run directory (before=$before after=$after)"; exit 93; }
  python3 "$PRED" "$name" "$run_dir" "$lrc" | tee "$run_dir/PREDICATES.txt" | tee -a "$DRIVER_LOG"
  prc=${PIPESTATUS[0]}
  # independent survivor scan for the just-used session (fact, never signalled here)
  sid=$(cat "$run_dir/OWNED_SID" 2>/dev/null); leftovers=""; [[ -n $sid ]] && leftovers=$(pgrep -s "$sid" | tr '\n' ' ')
  log "control $name launcher_exit=$lrc predicates_rc=$prc leftovers_in_session='${leftovers}' dir=$run_dir elapsed=$(elapsed)s"
  if [[ $prc != 0 || -n $leftovers ]]; then log "STOP at first unexpected result: $name"; exit 94; fi
done
# control 6: direct invocation of the REAL runner without the launcher must refuse (71) and create nothing
if (( $(elapsed) + 5 > TOTAL_BUDGET_S )); then log "STOP: no budget for direct-refusal control"; exit 92; fi
runs_before=$(ls -1 "$ROOT/execution/s4-r6-validation/runs" 2>/dev/null | wc -l)
out=$(timeout 5 bash "$V3/runner/s4-r6-validate-v3.sh" 2>&1); drc=$?
runs_after=$(ls -1 "$ROOT/execution/s4-r6-validation/runs" 2>/dev/null | wc -l)
printf '%s\nexit=%s runs_before=%s runs_after=%s\n' "$out" "$drc" "$runs_before" "$runs_after" > "$RECEIPTS/DIRECT-REFUSAL-$(date -u +%Y%m%dT%H%M%SZ).txt"
log "control 6/6 direct-runner-refusal exit=$drc (expect 71) message='$out' runs_dir_unchanged=$([[ $runs_before == "$runs_after" ]] && echo true || echo false)"
if [[ $drc != 71 || $runs_before != "$runs_after" || $out != *"REFUSE: not launched through the V3 launcher"* ]]; then log "STOP: direct refusal predicate failed"; exit 94; fi
log "ALL 6 CONTROLS OK elapsed=$(elapsed)s (budget ${TOTAL_BUDGET_S}s). Controls prove wrapper/ownership/publication behaviour only — not gates, Vitest, package, browser or acceptance."
exit 0
