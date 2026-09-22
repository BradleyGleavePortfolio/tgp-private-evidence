#!/usr/bin/env bash
# S4 R6 V4 — bounded sequential safety-control driver (S4-V3-A-03). NOT a validation run.
#
#   bash execution/s4-r6-validation/v4/controls/run-controls-v4.sh      (only after an explicit parent grant)
#
# Runs the controls in order through the ACTUAL V4 launcher/stub/library with a HARD aggregate deadline:
# every phase (launcher, predicates, lease/leftover scan) runs under an explicit bound derived from the
# remaining budget; when a bound expires the driver CANCELS the active launcher by TERM (its INTERRUPT
# route tears down the owned session, reaps and publishes), waits a bounded grace, KILLs if needed, and
# stops. A cleanup reserve is kept at the end. Stops at the first unexpected result (no retry).
# No network, no install, no canonical lock (the controls use the PRIVATE lease v4/control-runs/
# .private-control-lease.lock), no worktree, no browser.
set -u
ROOT=/home/user/workspace
V4=$ROOT/execution/s4-r6-validation/v4
LAUNCHER=$V4/launcher/s4-r6-launch-v4.sh
PRED=$V4/controls/control-predicates-v4.py
RECEIPTS=$V4/control-runs
PRIVATE_LEASE=$RECEIPTS/.private-control-lease.lock
# Budget arithmetic (A-03): per-control worst = outer + grace + launcher post-deadline constants
# (confirm 10 + post-exit reap 8 + publish 5 + 2) + driver phases (predicates 10 + scan 2) = outer+grace+37.
LAUNCHER_POST_S=25; PRED_S=10; SCAN_S=2
CLEANUP_RESERVE_S=15         # reserved for cancellation grace/KILL + final log, never used for admission
TOTAL_BUDGET_S=340           # hard aggregate: 65+47+50+50+50+50 (six launcher controls) + 5 (direct refusal) + 15 reserve = 332 ≤ 340; admission checks worst+reserve against remaining before every control
mkdir -p "$RECEIPTS" || exit 70
now() { date -u +%FT%TZ; }
T0=$(date +%s)
elapsed() { echo $(( $(date +%s) - T0 )); }
remaining() { echo $(( TOTAL_BUDGET_S - $(elapsed) )); }
DRIVER_LOG=$RECEIPTS/DRIVER-$(date -u +%Y%m%dT%H%M%SZ)-$$.log
log() { echo "[$(now)] $*" | tee -a "$DRIVER_LOG"; }

ACTIVE_PID=""; CANCELLED=""
cancel_active() {
  # aggregate cancellation route: TERM the launcher (→ INTERRUPT teardown of its owned session), bounded grace, KILL
  local why=$1
  [[ -n $ACTIVE_PID ]] && kill -0 "$ACTIVE_PID" 2>/dev/null || return 0
  log "CANCEL active launcher pid=$ACTIVE_PID reason=$why"
  kill -TERM "$ACTIVE_PID" 2>/dev/null; CANCELLED=$why
  for ((i=0;i<CLEANUP_RESERVE_S-5;i++)); do kill -0 "$ACTIVE_PID" 2>/dev/null || return 0; sleep 1; done
  kill -KILL "$ACTIVE_PID" 2>/dev/null; sleep 1
  log "launcher pid=$ACTIVE_PID did not exit within grace after TERM — KILLed; its owned session is reported by the leftover scan"
}
trap 'cancel_active driver-TERM; log "driver interrupted"; exit 143' TERM
trap 'cancel_active driver-INT; log "driver interrupted"; exit 130' INT

# run_bounded <deadline_s> <logfile> <cmd...>: background + poll; on deadline → cancel_active. Sets RB_RC.
run_bounded() {
  local deadline=$1 logf=$2; shift 2
  "$@" >> "$logf" 2>&1 & ACTIVE_PID=$!
  local t=0
  while kill -0 "$ACTIVE_PID" 2>/dev/null; do
    if (( t >= deadline )); then cancel_active "phase deadline ${deadline}s"; break; fi
    sleep 1; t=$((t+1))
  done
  wait "$ACTIVE_PID" 2>/dev/null; RB_RC=$?; ACTIVE_PID=""
}

# name | outer_s | grace_s | worst_case_s (= outer + grace + 37)
CONTROLS=(
  "nested-orphan-after-exit|25|3|65"
  "live-step-interrupt|4|6|47"
  "predicate-rc0|10|3|50"
  "record-without-sentinel|10|3|50"
  "lease-held-by-supervisor|10|3|50"
  "refuse|10|3|50"
)
log "V4 controls start total_budget=${TOTAL_BUDGET_S}s reserve=${CLEANUP_RESERVE_S}s launcher=$(sha256sum "$LAUNCHER" | cut -c1-16) lib=$(sha256sum "$V4/runner/s4-r6-lib-v4.sh" | cut -c1-16) stub=$(sha256sum "$V4/controls/s4-r6-control-stub-v4.sh" | cut -c1-16) private_lease=$PRIVATE_LEASE"
if ! flock -n "$PRIVATE_LEASE" true; then log "STOP: private control lease already held before start (stale holder?)"; exit 95; fi
n=0
for spec in "${CONTROLS[@]}"; do
  IFS='|' read -r name outer grace worst <<< "$spec"; n=$((n+1))
  if (( worst + CLEANUP_RESERVE_S > $(remaining) )); then log "STOP: control $n ($name) worst ${worst}s + reserve exceeds remaining $(remaining)s"; exit 92; fi
  before=$(ls -1 "$RECEIPTS" | grep -c '^CONTROL-V4-' || :)
  log "control $n/$((${#CONTROLS[@]}+1)) $name outer=${outer}s grace=${grace}s launcher_bound=$((outer+grace+LAUNCHER_POST_S))s elapsed=$(elapsed)s remaining=$(remaining)s"
  S4R6_CONTROL=1 S4R6_SCENARIO=$name S4R6_OUTER_S=$outer S4R6_GRACE_S=$grace \
    run_bounded $((outer+grace+LAUNCHER_POST_S)) "$DRIVER_LOG" bash "$LAUNCHER"
  lrc=$RB_RC
  run_dir=$(ls -1dt "$RECEIPTS"/CONTROL-V4-* 2>/dev/null | head -1)
  after=$(ls -1 "$RECEIPTS" | grep -c '^CONTROL-V4-' || :)
  [[ -z $CANCELLED ]] || { log "STOP: control $name was cancelled by the driver ($CANCELLED); launcher_exit=$lrc dir=$run_dir"; exit 96; }
  [[ $after == $((before+1)) && -n $run_dir ]] || { log "STOP: expected exactly one new run directory (before=$before after=$after)"; exit 93; }
  timeout --foreground "$PRED_S" python3 "$PRED" "$name" "$run_dir" "$lrc" | tee "$run_dir/PREDICATES.txt" | tee -a "$DRIVER_LOG"
  prc=${PIPESTATUS[0]}
  # independent facts (never signalled here): owned session empty; private lease released by the launcher
  sid=$(cat "$run_dir/OWNED_SID" 2>/dev/null); leftovers=""; [[ -n $sid ]] && leftovers=$(pgrep -s "$sid" | tr '\n' ' ')
  lease_free=false; flock -n "$PRIVATE_LEASE" true && lease_free=true
  log "control $name launcher_exit=$lrc predicates_rc=$prc leftovers_in_session='${leftovers}' private_lease_free=$lease_free dir=$run_dir elapsed=$(elapsed)s"
  if [[ $prc != 0 || -n $leftovers || $lease_free != true ]]; then log "STOP at first unexpected result: $name"; exit 94; fi
done
# last control: direct invocation of the REAL runner without the launcher must refuse (71) and create nothing
if (( 5 + CLEANUP_RESERVE_S > $(remaining) )); then log "STOP: no budget for direct-refusal control"; exit 92; fi
runs_before=$(ls -1 "$ROOT/execution/s4-r6-validation/runs" 2>/dev/null | wc -l)
out=$(timeout --foreground 5 bash "$V4/runner/s4-r6-validate-v4.sh" 2>&1); drc=$?
runs_after=$(ls -1 "$ROOT/execution/s4-r6-validation/runs" 2>/dev/null | wc -l)
printf '%s\nexit=%s runs_before=%s runs_after=%s\n' "$out" "$drc" "$runs_before" "$runs_after" > "$RECEIPTS/DIRECT-REFUSAL-$(date -u +%Y%m%dT%H%M%SZ).txt"
log "control $((${#CONTROLS[@]}+1))/$((${#CONTROLS[@]}+1)) direct-runner-refusal exit=$drc (expect 71) message='$out' runs_dir_unchanged=$([[ $runs_before == "$runs_after" ]] && echo true || echo false)"
if [[ $drc != 71 || $runs_before != "$runs_after" || $out != *"REFUSE: not launched through the V4 launcher"* ]]; then log "STOP: direct refusal predicate failed"; exit 94; fi
log "ALL $((${#CONTROLS[@]}+1)) CONTROLS OK elapsed=$(elapsed)s (hard budget ${TOTAL_BUDGET_S}s). Controls prove wrapper/ownership/lease/publication behaviour on the PRIVATE lease only — not the canonical lock's occupancy, not gates, Vitest, package, browser or acceptance."
exit 0
