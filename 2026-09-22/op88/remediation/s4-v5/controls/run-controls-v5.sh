#!/usr/bin/env bash
# S4 R6 V5 — bounded sequential safety-control driver (S4-V3-A-03, S4-V4-A-02/A-06). NOT a validation run.
#
#   bash execution/s4-r6-validation/v5/controls/run-controls-v5.sh      (only after an explicit parent grant)
#
# V5 changes versus V4 (frozen reviews S4-V4-A-02, A-05 companion, B-02/B-04):
#  * One enforceable ELAPSED deadline: run_bounded polls wall-clock, an aggregate guard cancels when the
#    remaining budget reaches the cleanup reserve, and every driver phase (predicates, session scan, lease
#    check, direct refusal) runs under an explicit `timeout --foreground`.
#  * Cancellation never KILLs the lease holder: TERM the active launcher, wait its own worst-case teardown
#    (grace + LAUNCHER_POST_S); if it is still alive it is recorded with pid+starttime as an UNRESOLVED
#    holder (exit 97) — the private lease stays with it. No unconditional wait after an unconfirmed KILL.
#  * Every exit path (stop, cancel, TERM/INT) runs the owned-session scan and private-lease check first;
#    survivors of a launcher that already exited are TERM/KILL-reaped (they are the session this driver
#    caused to exist) and any lease-free-with-survivors state is exit 98 (UNSAFE RELEASE observed).
#  * Packet pinned before execution: sha256sum -c of the V5 manifest from the packet root (exit 91 on mismatch).
#  * New control `live-step-double-term` (S4-V4-A-01 discriminator via the control-only lib seam).
#
# Runs the controls in order through the ACTUAL V5 launcher/stub/library. Stops at the first unexpected
# result (no retry). No network, no install, no canonical lock (the controls use the PRIVATE lease
# v5/control-runs/.private-control-lease.lock), no worktree, no browser.
set -u
ROOT=/home/user/workspace
V5=$ROOT/execution/s4-r6-validation/v5
LAUNCHER=$V5/launcher/s4-r6-launch-v5.sh
PRED=$V5/controls/control-predicates-v5.py
RECEIPTS=$V5/control-runs
PRIVATE_LEASE=$RECEIPTS/.private-control-lease.lock
# Budget arithmetic (A-03/A-02, wall-clock): launcher post-deadline constants = confirm 10 + post-exit reap 8 +
# publish 5 + 2*read 5 + quarantine-verify 5 + 2 = 40 (LAUNCHER_POST_S, equals the launcher's own formula minus
# outer+grace). Driver phases per control: predicates 10 + session scan 5 + lease check 5 = 20.
# per-control worst = outer + grace + LAUNCHER_POST_S + PRED_S + SCAN_S + LEASE_S = outer + grace + 60.
LAUNCHER_POST_S=40; PRED_S=10; SCAN_S=5; LEASE_S=5
CLEANUP_RESERVE_S=70         # cancellation worst: TERM + wait (grace<=6 + LAUNCHER_POST_S 40) + post scan/reap (5+3+5) + lease 5 + log 2 <= 66; never used for admission
TOTAL_BUDGET_S=600           # hard aggregate: 88+70+70+73+73+73+73 (seven launcher controls, see CONTROLS) = 520, + 7 direct refusal, + 70 reserve = 597 <= 600; admission checks worst+reserve against remaining before every control
mkdir -p "$RECEIPTS" || exit 70
now() { date -u +%FT%TZ; }
T0=$(date +%s)
elapsed() { echo $(( $(date +%s) - T0 )); }
remaining() { echo $(( TOTAL_BUDGET_S - $(elapsed) )); }
proc_start() { sed 's/^.*) //' "/proc/$1/stat" 2>/dev/null | awk '{print $20}'; }
DRIVER_LOG=$RECEIPTS/DRIVER-$(date -u +%Y%m%dT%H%M%SZ)-$$.log
log() { echo "[$(now)] $*" | tee -a "$DRIVER_LOG"; }

# ---- pin the packet before anything executes (from the packet root; manifest is non-self-including) ----
if ! ( cd "$V5" && timeout --foreground 20 sha256sum -c --quiet SHA256SUMS ) >> "$DRIVER_LOG" 2>&1; then log "STOP: V5 manifest verification failed at $V5 (nothing executed)"; exit 91; fi

ACTIVE_PID=""; ACTIVE_START=""; ACTIVE_GRACE=0; CANCELLED=""; UNRESOLVED=""; LAST_RUN_DIR=""
cancel_active() {
  # aggregate cancellation route (A-02): TERM the launcher (-> its INTERRUPT teardown: owned session TERM/KILL,
  # survivors->quarantine, publish). Wait its OWN worst-case teardown, wall-clock. NEVER KILL the lease holder:
  # an unconfirmed KILL would release the private lease with an unrecorded session. If it is still alive after
  # its worst case it is recorded as UNRESOLVED (identity: pid + starttime) and left holding the lease.
  local why=$1
  [[ -n $ACTIVE_PID ]] && kill -0 "$ACTIVE_PID" 2>/dev/null || return 0
  log "CANCEL active launcher pid=$ACTIVE_PID starttime=$ACTIVE_START reason=$why"
  kill -TERM "$ACTIVE_PID" 2>/dev/null; CANCELLED=$why
  local until=$(( $(date +%s) + ACTIVE_GRACE + LAUNCHER_POST_S ))
  while (( $(date +%s) < until )); do kill -0 "$ACTIVE_PID" 2>/dev/null || return 0; sleep 1; done
  if kill -0 "$ACTIVE_PID" 2>/dev/null && [[ $(proc_start "$ACTIVE_PID") == "$ACTIVE_START" ]]; then
    UNRESOLVED="launcher pid=$ACTIVE_PID starttime=$ACTIVE_START still alive $((ACTIVE_GRACE+LAUNCHER_POST_S))s after TERM; NOT killed; it still holds the private lease; dir=$LAST_RUN_DIR"
    printf '%s\n%s\nRECOVERY: inspect its console.log/SUPERVISOR_RECORD; verify pid+starttime before any signal; never a bare pid.\n' "$(now)" "$UNRESOLVED" > "$RECEIPTS/DRIVER-UNRESOLVED-$(date -u +%Y%m%dT%H%M%SZ)-$ACTIVE_PID.txt"
    log "UNRESOLVED: $UNRESOLVED"
  fi
}
# session_state <run_dir>: bounded owned-session scan. Sets LEFT_INITIAL (what the launcher left behind — the
# fact the controls judge), LEFT_FINAL (after this driver's bounded TERM/KILL reap of a session whose launcher has
# already exited; that session exists only because this driver started it) and LEASE_FREE (private lease probe).
LEFT_INITIAL=""; LEFT_FINAL=""; LEASE_FREE=unchecked
session_state() {
  local d=$1 sid="" p until
  LEFT_INITIAL=""; LEFT_FINAL=""
  sid=$(cat "$d/OWNED_SID" 2>/dev/null)
  if [[ -n $sid ]]; then
    LEFT_INITIAL=$(timeout --foreground "$SCAN_S" pgrep -s "$sid" 2>/dev/null | tr '\n' ' '); LEFT_FINAL=$LEFT_INITIAL
    if [[ -n $LEFT_INITIAL && -z $UNRESOLVED ]] && ! { [[ -n $ACTIVE_PID ]] && kill -0 "$ACTIVE_PID" 2>/dev/null; }; then
      log "owned session $sid leftovers after launcher exit: $LEFT_INITIAL — bounded TERM/KILL by the driver (recorded; still a control failure)"
      for p in $LEFT_INITIAL; do kill -TERM "$p" 2>/dev/null; done; until=$(( $(date +%s) + 5 ))
      while (( $(date +%s) < until )); do [[ -z $(pgrep -s "$sid" 2>/dev/null) ]] && break; sleep 1; done
      if [[ -n $(pgrep -s "$sid" 2>/dev/null) ]]; then for p in $(pgrep -s "$sid"); do kill -KILL "$p" 2>/dev/null; done; until=$(( $(date +%s) + 3 )); while (( $(date +%s) < until )); do [[ -z $(pgrep -s "$sid" 2>/dev/null) ]] && break; sleep 1; done; fi
      LEFT_FINAL=$(timeout --foreground "$SCAN_S" pgrep -s "$sid" 2>/dev/null | tr '\n' ' ')
    fi
  fi
  LEASE_FREE=false; timeout --foreground "$LEASE_S" flock -n "$PRIVATE_LEASE" true && LEASE_FREE=true
  return 0
}
# finish <code> <why>: every exit path — cancel active launcher (bounded, no KILL), scan/reap owned session, check lease, exit.
finish() {
  local code=$1 why=$2
  cancel_active "$why"
  [[ -n $LAST_RUN_DIR ]] && session_state "$LAST_RUN_DIR"
  local qh=""; [[ -n $LAST_RUN_DIR && -f $LAST_RUN_DIR/QUARANTINE_LEASE_HOLDER ]] && qh=$(head -1 "$LAST_RUN_DIR/QUARANTINE_LEASE_HOLDER")
  if [[ -n $UNRESOLVED ]]; then code=97
  elif [[ -n $LEFT_FINAL && $LEASE_FREE == true ]]; then code=98; log "UNSAFE RELEASE OBSERVED: unreaped leftovers '$LEFT_FINAL' in owned session while the private lease is free"
  elif [[ -n $LEFT_INITIAL && $LEASE_FREE == true && -z $qh ]]; then log "launcher released the lease leaving '$LEFT_INITIAL' (reaped by driver: final='$LEFT_FINAL') — launcher cleanup defect, not permission"; fi
  log "EXIT code=$code why=$why leftovers_initial='${LEFT_INITIAL}' leftovers_final='${LEFT_FINAL}' private_lease_free=$LEASE_FREE quarantine_holder='${qh}' elapsed=$(elapsed)s budget=${TOTAL_BUDGET_S}s"
  exit "$code"
}
trap 'finish 143 driver-TERM' TERM
trap 'finish 130 driver-INT' INT

# run_bounded <deadline_s> <grace_s> <logfile> <cmd...>: background + wall-clock poll; on phase deadline or when the
# aggregate budget reaches the cleanup reserve -> cancel_active (never KILL). Sets RB_RC ("" if unresolved).
run_bounded() {
  local deadline=$1 grace=$2 logf=$3; shift 3
  "$@" >> "$logf" 2>&1 & ACTIVE_PID=$!; ACTIVE_START=$(proc_start "$ACTIVE_PID"); ACTIVE_GRACE=$grace
  local start; start=$(date +%s)
  while kill -0 "$ACTIVE_PID" 2>/dev/null; do
    if (( $(date +%s) - start >= deadline )); then cancel_active "phase deadline ${deadline}s"; break; fi
    if (( $(remaining) <= CLEANUP_RESERVE_S )); then cancel_active "aggregate budget ${TOTAL_BUDGET_S}s reached cleanup reserve"; break; fi
    sleep 1
  done
  if [[ -n $UNRESOLVED ]]; then RB_RC=""; else wait "$ACTIVE_PID" 2>/dev/null; RB_RC=$?; ACTIVE_PID=""; fi
}

# name | outer_s | grace_s | worst_case_s (= outer + grace + 60) | seam (control-only lib synchronisation, empty = none)
CONTROLS=(
  "nested-orphan-after-exit|25|3|88|"
  "live-step-interrupt|4|6|70|"
  "live-step-double-term|4|6|70|step-after-reap"
  "predicate-rc0|10|3|73|"
  "record-without-sentinel|10|3|73|"
  "lease-held-by-supervisor|10|3|73|"
  "refuse|10|3|73|"
)
log "V5 controls start total_budget=${TOTAL_BUDGET_S}s reserve=${CLEANUP_RESERVE_S}s launcher=$(sha256sum "$LAUNCHER" | cut -c1-16) lib=$(sha256sum "$V5/runner/s4-r6-lib-v5.sh" | cut -c1-16) stub=$(sha256sum "$V5/controls/s4-r6-control-stub-v5.sh" | cut -c1-16) predicates=$(sha256sum "$PRED" | cut -c1-16) private_lease=$PRIVATE_LEASE driver_pid=$$ driver_start=$(proc_start $$) timeout=$(readlink -f "$(command -v timeout)") sleep=$(readlink -f "$(command -v sleep)")"
if ! timeout --foreground "$LEASE_S" flock -n "$PRIVATE_LEASE" true; then log "STOP: private control lease already held before start (stale holder? inspect $RECEIPTS/*/QUARANTINE_LEASE_HOLDER and DRIVER-UNRESOLVED-*)"; exit 95; fi
n=0
for spec in "${CONTROLS[@]}"; do
  IFS='|' read -r name outer grace worst seam <<< "$spec"; n=$((n+1))
  if (( worst + CLEANUP_RESERVE_S > $(remaining) )); then finish 92 "control $n ($name) worst ${worst}s + reserve exceeds remaining $(remaining)s"; fi
  before=$(ls -1 "$RECEIPTS" | grep -c '^CONTROL-V5-' || :)
  log "control $n/$((${#CONTROLS[@]}+1)) $name outer=${outer}s grace=${grace}s seam='${seam}' launcher_bound=$((outer+grace+LAUNCHER_POST_S))s elapsed=$(elapsed)s remaining=$(remaining)s"
  S4R6_CONTROL=1 S4R6_SCENARIO=$name S4R6_OUTER_S=$outer S4R6_GRACE_S=$grace S4R6_SEAM=$seam \
    run_bounded $((outer+grace+LAUNCHER_POST_S)) "$grace" "$DRIVER_LOG" bash "$LAUNCHER"
  lrc=$RB_RC
  run_dir=$(ls -1dt "$RECEIPTS"/CONTROL-V5-* 2>/dev/null | head -1); LAST_RUN_DIR=$run_dir
  after=$(ls -1 "$RECEIPTS" | grep -c '^CONTROL-V5-' || :)
  [[ -z $CANCELLED ]] || finish 96 "control $name was cancelled by the driver ($CANCELLED); launcher_exit=${lrc:-unresolved} dir=$run_dir"
  [[ $after == $((before+1)) && -n $run_dir ]] || finish 93 "expected exactly one new run directory (before=$before after=$after)"
  timeout --foreground "$PRED_S" python3 "$PRED" "$name" "$run_dir" "$lrc" | tee "$run_dir/PREDICATES.txt" | tee -a "$DRIVER_LOG"
  prc=${PIPESTATUS[0]}
  # independent facts: owned session empty as the launcher LEFT it (LEFT_INITIAL, bounded scan); private lease released by the launcher
  session_state "$run_dir"
  qh=""; [[ -f $run_dir/QUARANTINE_LEASE_HOLDER ]] && qh=$(head -1 "$run_dir/QUARANTINE_LEASE_HOLDER")
  log "control $name launcher_exit=$lrc predicates_rc=$prc leftovers_in_session='${LEFT_INITIAL}' (after driver reap: '${LEFT_FINAL}') private_lease_free=$LEASE_FREE quarantine_holder='${qh}' dir=$run_dir elapsed=$(elapsed)s"
  if [[ -n $qh ]]; then finish 94 "control $name left a RECORDED quarantine holder ($qh) — lease intentionally retained; do not kill without identity check"; fi
  if [[ $prc != 0 || -n $LEFT_INITIAL || $LEASE_FREE != true ]]; then finish 94 "first unexpected result: $name"; fi
done
# last control: direct invocation of the REAL runner without the launcher must refuse (71) and create nothing
if (( 7 + CLEANUP_RESERVE_S > $(remaining) )); then finish 92 "no budget for direct-refusal control"; fi
runs_before=$(ls -1 "$ROOT/execution/s4-r6-validation/runs" 2>/dev/null | wc -l)
out=$(timeout --foreground 5 bash "$V5/runner/s4-r6-validate-v5.sh" 2>&1); drc=$?
runs_after=$(ls -1 "$ROOT/execution/s4-r6-validation/runs" 2>/dev/null | wc -l)
printf '%s\nexit=%s runs_before=%s runs_after=%s\n' "$out" "$drc" "$runs_before" "$runs_after" > "$RECEIPTS/DIRECT-REFUSAL-$(date -u +%Y%m%dT%H%M%SZ).txt"
log "control $((${#CONTROLS[@]}+1))/$((${#CONTROLS[@]}+1)) direct-runner-refusal exit=$drc (expect 71) message='$out' runs_dir_unchanged=$([[ $runs_before == "$runs_after" ]] && echo true || echo false)"
if [[ $drc != 71 || $runs_before != "$runs_after" || $out != *"REFUSE: not launched through the V5 launcher"* ]]; then finish 94 "direct refusal predicate failed"; fi
log "ALL $((${#CONTROLS[@]}+1)) CONTROLS OK elapsed=$(elapsed)s (hard budget ${TOTAL_BUDGET_S}s). Controls prove wrapper/ownership/lease/publication behaviour on the PRIVATE lease only — not the canonical lock's occupancy, not gates, Vitest, package, browser or acceptance."
exit 0
