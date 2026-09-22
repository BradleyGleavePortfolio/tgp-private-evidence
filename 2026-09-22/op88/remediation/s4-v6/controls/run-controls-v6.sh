#!/usr/bin/env bash
# S4 R6 V6 — bounded sequential safety-control driver (S4-V3-A-03, S4-V4-A-02/A-06). NOT a validation run.
#
#   bash execution/s4-r6-validation/v6/controls/run-controls-v6.sh      (only after an explicit parent grant)
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
#  * Packet pinned before execution: sha256sum -c of the V6 manifest from the packet root (exit 91 on mismatch).
#  * New control `live-step-double-term` (S4-V4-A-01 discriminator via the control-only lib seam).
#
# V6 changes versus V5 (frozen review S4-V5-A-01/A-02/A-04/A-05):
#  * Current-run identity (A-01): the active launcher's run directory is bound to ACTIVE_PID as soon as it appears
#    (RUN_ID embeds the launcher pid) and re-resolved inside finish; a cancel receipt names the ACTIVE run, never a
#    preceding one. "No run directory yet" is recorded as RUN_IDENTITY=UNKNOWN_NO_SPAWN, not as verified empty.
#  * Once-budgeted cancellation (A-02): exactly one TERM per launcher against one absolute CANCEL_DEADLINE; a later
#    cancel_active (finish) only waits the remainder and never restarts the allowance.
#  * Fail-closed census (A-05): pgrep status is kept; EMPTY (rc 1) is distinct from UNKNOWN (timeout/error), which
#    stops the run (exit 99) without reaping or declaring anything. LEFT_FIRST (as the launcher left it) is kept
#    separately from the final post-reap census so finalisation cannot overwrite the judged snapshot.
#  * Terminal receipt (A-04): success goes through finish 0 too, which re-checks current facts (identity, census,
#    lease, holder) and downgrades the code if any contradicts; every non-pre-spawn exit emits one `EXIT code=` line
#    and a DRIVER-TERMINAL-*.txt receipt (write checked: exit 90 if it cannot be written on a success path).
#  * Budget re-itemised for the V6 launcher constants and startup (manifest 20 + lease probe 5): TOTAL 960 s (worst 956).
#  * UNRESOLVED (97) records a readlink fd 9 check of the live launcher instead of asserting lease retention.
#  * Exit 91 (manifest) and 70/95 are PRE-SPAWN refusals: nothing owned, no census, no finish (stated, not overclaimed).
#  * Fault controls (S4-V5-B-06): four CONTROL-ONLY fault injections on the PRIVATE lease exercise the real
#    survivor/quarantine, holder-creation, receipt-publication and unknown-census paths (launcher seams S4R6_FAULT).
#    For a quarantine-class control the driver verifies the RECORDED holder (pid+starttime+token+fd 9) is alive and the
#    private lease is held, then applies the identity-checked recovery rule (recover_holder) and verifies release.
#    Holder presence is judged by a LIVE identity-checked holder, never by the receipt file alone.
#  * Cancel wait has +5 s slack over the launcher's own teardown allowance (V5B-04); a launcher alive at the deadline is
#    UNRESOLVED even when its starttime cannot be compared (never an unconditional wait).
#
# Runs the controls in order through the ACTUAL V6 launcher/stub/library. Stops at the first unexpected
# result (no retry). No network, no install, no canonical lock (the controls use the PRIVATE lease
# v6/control-runs/.private-control-lease.lock), no worktree, no browser.
set -u
ROOT=/home/user/workspace
V6=$ROOT/execution/s4-r6-validation/v6
LAUNCHER=$V6/launcher/s4-r6-launch-v6.sh
PRED=$V6/controls/control-predicates-v6.py
RECEIPTS=$V6/control-runs
PRIVATE_LEASE=$RECEIPTS/.private-control-lease.lock
# Budget arithmetic (wall-clock): launcher post-deadline constants (V6 launcher formula minus outer+grace) =
# confirm 10 + post-exit reap 8 + publish 5 + 2*read 5 + 2*quarantine-verify 5 + 16*census 2 + 2 = 77 (LAUNCHER_POST_S).
# Driver phases per control: predicates 10 + census 2*SCAN_S 5 + lease check 5 = 25.
# per-control worst = outer + grace + LAUNCHER_POST_S + PRED_S + 2*SCAN_S + LEASE_S = outer + grace + 102.
LAUNCHER_POST_S=77; PRED_S=10; SCAN_S=5; LEASE_S=5; STARTUP_S=25; CANCEL_SLACK_S=5; RECOVER_S=10
CLEANUP_RESERVE_S=115        # cancellation worst (ONE TERM, one absolute deadline): grace<=6 + LAUNCHER_POST_S 77 + slack 5 + census 2*5 + driver reap 5+3 + lease 5 + receipts/log 3 = 114; never used for admission
TOTAL_BUDGET_S=1500          # hard aggregate: 130+112+112+115+115+115+115 (seven behaviour controls) + 122+122+125+115 (four fault controls incl. 10 s recovery) = 1298, + 7 direct refusal, + 25 startup (manifest 20 + lease probe 5), + 115 reserve = 1445 <= 1500; admission checks worst+reserve against remaining before every control (stop 92, never overrun). Qualification: sums declared allowances of bounded phases; mv/log lines are not enclosed by a timeout.
mkdir -p "$RECEIPTS" || exit 70
now() { date -u +%FT%TZ; }
T0=$(date +%s)
elapsed() { echo $(( $(date +%s) - T0 )); }
remaining() { echo $(( TOTAL_BUDGET_S - $(elapsed) )); }
proc_start() { sed 's/^.*) //' "/proc/$1/stat" 2>/dev/null | awk '{print $20}'; }
DRIVER_LOG=$RECEIPTS/DRIVER-$(date -u +%Y%m%dT%H%M%SZ)-$$.log
log() { echo "[$(now)] $*" | tee -a "$DRIVER_LOG"; }

# ---- pin the packet before anything executes (from the packet root; manifest is non-self-including) ----
if ! ( cd "$V6" && timeout --foreground 20 sha256sum -c --quiet SHA256SUMS ) >> "$DRIVER_LOG" 2>&1; then log "STOP: V6 manifest verification failed at $V6 (nothing executed)"; exit 91; fi

ACTIVE_PID=""; ACTIVE_START=""; ACTIVE_GRACE=0; ACTIVE_RUN_DIR=""; RUN_IDENTITY=NONE
CANCELLED=""; CANCEL_SENT=""; CANCEL_DEADLINE=""; UNRESOLVED=""; LAST_RUN_DIR=""
# resolve_active_run: bind the ACTIVE launcher's run directory (RUN_ID = CONTROL-V6-<utc>-<launcher pid>-<rand>) once it
# exists (A-01). RUN_IDENTITY: NONE (no active launcher) | UNKNOWN_NO_SPAWN (alive/exited without a directory) | BOUND.
resolve_active_run() {
  [[ -n $ACTIVE_PID ]] || return 0
  if [[ -z $ACTIVE_RUN_DIR ]]; then
    local d; d=$(ls -1d "$RECEIPTS"/CONTROL-V6-*-"$ACTIVE_PID"-* 2>/dev/null | head -1)
    if [[ -n $d ]]; then ACTIVE_RUN_DIR=$d; LAST_RUN_DIR=$d; RUN_IDENTITY=BOUND; else RUN_IDENTITY=UNKNOWN_NO_SPAWN; fi
  fi
  return 0
}
cancel_active() {
  # aggregate cancellation route (A-02, once-budgeted): exactly ONE TERM to the active launcher (-> its INTERRUPT
  # teardown: owned session TERM/KILL, survivors->quarantine holder, publish) against ONE absolute deadline
  # (grace + LAUNCHER_POST_S from the TERM). Any later call only waits the remainder. NEVER KILL the lease holder.
  # If it is still alive at the deadline it is recorded as UNRESOLVED (pid + starttime + fd 9 check) and left alone.
  local why=$1
  [[ -n $ACTIVE_PID ]] && kill -0 "$ACTIVE_PID" 2>/dev/null || return 0
  resolve_active_run
  if [[ -z $CANCEL_SENT ]]; then
    CANCEL_SENT=$(date +%s); CANCEL_DEADLINE=$(( CANCEL_SENT + ACTIVE_GRACE + LAUNCHER_POST_S + CANCEL_SLACK_S )); CANCELLED=$why
    log "CANCEL active launcher pid=$ACTIVE_PID starttime=${ACTIVE_START:-unknown} run=${ACTIVE_RUN_DIR:-<none yet>} identity=$RUN_IDENTITY reason=$why deadline=+$((ACTIVE_GRACE+LAUNCHER_POST_S+CANCEL_SLACK_S))s (one TERM, no second allowance)"
    kill -TERM "$ACTIVE_PID" 2>/dev/null
  else
    log "cancel_active re-entered (reason=$why): TERM already sent at $CANCEL_SENT; waiting only the remaining $(( CANCEL_DEADLINE - $(date +%s) ))s"
  fi
  while (( $(date +%s) < CANCEL_DEADLINE )); do kill -0 "$ACTIVE_PID" 2>/dev/null || return 0; resolve_active_run; sleep 1; done
  if kill -0 "$ACTIVE_PID" 2>/dev/null; then
    resolve_active_run
    local fd9 st; fd9=$(readlink "/proc/$ACTIVE_PID/fd/9" 2>/dev/null); st=$(proc_start "$ACTIVE_PID")
    local ident="starttime=${st:-unknown}"; [[ -n $ACTIVE_START && $st == "$ACTIVE_START" ]] || ident="$ident (spawn-time starttime '${ACTIVE_START:-unknown}' NOT confirmed — treat identity as uncertain)"
    UNRESOLVED="launcher pid=$ACTIVE_PID $ident still alive at its cancel deadline (TERM sent once at $CANCEL_SENT, +$((ACTIVE_GRACE+LAUNCHER_POST_S+CANCEL_SLACK_S))s); NOT killed; fd9=${fd9:-<none>} lease_held_by_it=$([[ $fd9 == "$PRIVATE_LEASE" ]] && echo true || echo false); run=${ACTIVE_RUN_DIR:-<none>} identity=$RUN_IDENTITY"
    if ! printf '%s\n%s\nRECOVERY: inspect its console.log/SUPERVISOR_RECORD/QUARANTINE_LEASE_HOLDER; verify pid+starttime(+token, fd 9) before any signal; never a bare pid.\n' "$(now)" "$UNRESOLVED" > "$RECEIPTS/DRIVER-UNRESOLVED-$(date -u +%Y%m%dT%H%M%SZ)-$ACTIVE_PID.txt"; then log "WARNING: DRIVER-UNRESOLVED receipt could not be written"; fi
    log "UNRESOLVED: $UNRESOLVED"
  fi
}
# census <sid>: bounded owned-session census (A-05). Sets C_MEMBERS and C_STATE: EMPTY | MEMBERS | UNKNOWN:<rc>.
census() {
  local rc; C_MEMBERS=""; C_STATE=""
  C_MEMBERS=$(timeout --foreground "$SCAN_S" pgrep -s "$1" 2>/dev/null | tr '\n' ' '); rc=${PIPESTATUS[0]}
  case $rc in 0) C_STATE=MEMBERS;; 1) C_STATE=EMPTY; C_MEMBERS="";; *) C_STATE="UNKNOWN:$rc"; C_MEMBERS="";; esac
  return 0
}
# holder_identity <run_dir>: prints "pid starttime token" of the recorded quarantine holder from the receipt, else from
# SUPERVISOR_RECORD.json (the receipt-failure case), else nothing. Bounded read.
holder_identity() {
  local d=$1 f=$d/QUARANTINE_LEASE_HOLDER
  if [[ -s $f ]]; then sed -n '1s/^pid=\([0-9]*\) starttime=\([0-9]*\) token=\([^ ]*\) .*/\1 \2 \3/p' "$f"; return 0; fi
  [[ -f $d/SUPERVISOR_RECORD.json ]] || return 0
  timeout --foreground "$SCAN_S" python3 -c 'import json,sys
L=json.load(open(sys.argv[1])).get("lease",{})
p,s,t=L.get("quarantine_holder_pid"),L.get("quarantine_holder_starttime"),L.get("quarantine_holder_token")
if p and s and t: print(p,s,t)' "$d/SUPERVISOR_RECORD.json" 2>/dev/null
}
# holder_alive <run_dir>: 0 iff the recorded holder is alive with matching starttime, cmdline token AND fd 9 -> private lease.
holder_alive() {
  local id pid st tok; id=$(holder_identity "$1"); [[ -n $id ]] || return 1
  read -r pid st tok <<< "$id"
  kill -0 "$pid" 2>/dev/null && [[ $(proc_start "$pid") == "$st" ]] && tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null | grep -q -- "$tok" && [[ $(readlink "/proc/$pid/fd/9" 2>/dev/null) == "$PRIVATE_LEASE" ]]
}
# recover_holder <run_dir>: the §6 recovery rule on the PRIVATE lease only, for fault controls whose survivors are the
# injected census (verified EMPTY by this driver first). KILL only after the identity triple matches; bounded wait.
recover_holder() {
  local d=$1 id pid st tok
  id=$(holder_identity "$d"); [[ -n $id ]] || { log "recover_holder: no recorded holder identity in $d"; return 1; }
  read -r pid st tok <<< "$id"
  if ! holder_alive "$d"; then log "recover_holder: recorded holder pid=$pid not alive with matching identity — nothing signalled"; return 1; fi
  log "recover_holder: identity verified pid=$pid starttime=$st token=$tok fd9=$PRIVATE_LEASE — KILL (private lease, injected survivors verified gone)"
  kill -KILL "$pid" 2>/dev/null
  local until=$(( $(date +%s) + RECOVER_S )); while (( $(date +%s) < until )); do kill -0 "$pid" 2>/dev/null || break; sleep 1; done
  ! kill -0 "$pid" 2>/dev/null
}
# session_state <run_dir>: LEFT_FIRST/LEFT_FIRST_STATE = the session as the launcher LEFT it (set once per run; the
# fact the controls judge); LEFT_FINAL/LEFT_FINAL_STATE = after this driver's bounded TERM/KILL reap of a session whose
# launcher has already exited (that session exists only because this driver started it); LEASE_FREE = private lease probe.
# UNKNOWN census never reaps and never counts as empty.
LEFT_FIRST=""; LEFT_FIRST_STATE=NONE; LEFT_FINAL=""; LEFT_FINAL_STATE=NONE; LEASE_FREE=unchecked; JUDGED_DIR=""; JUDGED_OK_DIR=""
session_state() {
  local d=$1 sid="" p until
  if [[ $JUDGED_DIR != "$d" ]]; then JUDGED_DIR=$d; LEFT_FIRST=""; LEFT_FIRST_STATE=NONE; fi
  LEFT_FINAL=""; LEFT_FINAL_STATE=NONE
  sid=$(cat "$d/OWNED_SID" 2>/dev/null)
  if [[ -z $sid ]]; then LEFT_FIRST_STATE=${LEFT_FIRST_STATE/NONE/NO_SESSION}; LEFT_FINAL_STATE=NO_SESSION   # no OWNED_SID: only a pre-spawn refusal may end here
  else
    census "$sid"
    if [[ $LEFT_FIRST_STATE == NONE ]]; then LEFT_FIRST=$C_MEMBERS; LEFT_FIRST_STATE=$C_STATE; fi
    LEFT_FINAL=$C_MEMBERS; LEFT_FINAL_STATE=$C_STATE
    if [[ $C_STATE == MEMBERS && -z $UNRESOLVED ]] && ! { [[ -n $ACTIVE_PID ]] && kill -0 "$ACTIVE_PID" 2>/dev/null; }; then
      log "owned session $sid leftovers after launcher exit: $C_MEMBERS — bounded TERM/KILL by the driver (recorded; still a control failure)"
      for p in $C_MEMBERS; do kill -TERM "$p" 2>/dev/null; done; until=$(( $(date +%s) + 5 ))
      while (( $(date +%s) < until )); do census "$sid"; [[ $C_STATE == EMPTY ]] && break; sleep 1; done
      if [[ $C_STATE == MEMBERS ]]; then for p in $C_MEMBERS; do kill -KILL "$p" 2>/dev/null; done; until=$(( $(date +%s) + 3 )); while (( $(date +%s) < until )); do census "$sid"; [[ $C_STATE == EMPTY ]] && break; sleep 1; done; fi
      census "$sid"; LEFT_FINAL=$C_MEMBERS; LEFT_FINAL_STATE=$C_STATE
    fi
  fi
  LEASE_FREE=false; timeout --foreground "$LEASE_S" flock -n "$PRIVATE_LEASE" true && LEASE_FREE=true
  return 0
}
# finish <code> <why>: every post-spawn exit path INCLUDING success — cancel (once-budgeted), bind current run, census,
# lease probe, holder check; the code is downgraded when any current fact contradicts it; one terminal receipt.
finish() {
  local code=$1 why=$2
  cancel_active "$why"; resolve_active_run
  local d=${ACTIVE_RUN_DIR:-$LAST_RUN_DIR}
  [[ -n $d ]] && session_state "$d"
  local qh=""; [[ -n $d ]] && holder_alive "$d" && qh=$(holder_identity "$d")
  if   [[ -n $UNRESOLVED ]]; then code=97
  elif [[ -n $ACTIVE_PID && $RUN_IDENTITY == UNKNOWN_NO_SPAWN ]]; then code=99; log "CENSUS UNKNOWN: active launcher pid=$ACTIVE_PID left no run directory; no owned session can be identified"
  elif [[ -n $d && $LEFT_FINAL_STATE == NO_SESSION && $JUDGED_OK_DIR != "$d" ]]; then code=99; log "NO OWNED SESSION RECORDED for $d and the run was not judged as a pre-spawn refusal — unknown ownership state"
  elif [[ -n $d && $LEFT_FINAL_STATE != EMPTY && $LEFT_FINAL_STATE != NONE && $LEFT_FINAL_STATE != NO_SESSION ]]; then code=99; log "CENSUS UNKNOWN/UNRESOLVED: state=$LEFT_FINAL_STATE members='$LEFT_FINAL' — nothing declared empty, nothing reaped"
  elif [[ -n $LEFT_FINAL && $LEASE_FREE == true ]]; then code=98; log "UNSAFE RELEASE OBSERVED: unreaped leftovers '$LEFT_FINAL' in owned session while the private lease is free"
  elif [[ $code == 0 && ( -n $qh || -n $LEFT_FIRST || $LEASE_FREE != true ) ]]; then code=94; log "success contradicted by final facts: holder='${qh}' leftovers_first='${LEFT_FIRST}' lease_free=$LEASE_FREE"
  elif [[ -n $LEFT_FIRST && $LEASE_FREE == true && -z $qh ]]; then log "launcher released the lease leaving '$LEFT_FIRST' (reaped by driver: final='$LEFT_FINAL') — launcher cleanup defect, not permission"; fi
  local line="EXIT code=$code why=$why run=${d:-<none>} identity=$RUN_IDENTITY leftovers_first='${LEFT_FIRST}' (state=$LEFT_FIRST_STATE) leftovers_final='${LEFT_FINAL}' (state=$LEFT_FINAL_STATE) private_lease_free=$LEASE_FREE live_quarantine_holder='${qh}' cancelled='${CANCELLED}' elapsed=$(elapsed)s budget=${TOTAL_BUDGET_S}s"
  if ! printf '%s\n%s\n' "$(now)" "$line" > "$RECEIPTS/DRIVER-TERMINAL-$(date -u +%Y%m%dT%H%M%SZ)-$$.txt"; then [[ $code == 0 ]] && code=90; line="$line terminal_receipt_write=FAILED code_now=$code"; fi
  log "$line"
  exit "$code"
}
trap 'finish 143 driver-TERM' TERM
trap 'finish 130 driver-INT' INT

# run_bounded <deadline_s> <grace_s> <logfile> <cmd...>: background + wall-clock poll; binds the current run directory as
# soon as it appears (A-01); on phase deadline or when the aggregate budget reaches the cleanup reserve -> cancel_active
# (once, never KILL). Sets RB_RC ("" if unresolved).
run_bounded() {
  local deadline=$1 grace=$2 logf=$3; shift 3
  ACTIVE_RUN_DIR=""; RUN_IDENTITY=NONE; CANCEL_SENT=""; CANCEL_DEADLINE=""
  "$@" >> "$logf" 2>&1 & ACTIVE_PID=$!; ACTIVE_START=$(proc_start "$ACTIVE_PID"); ACTIVE_GRACE=$grace
  local start; start=$(date +%s)
  while kill -0 "$ACTIVE_PID" 2>/dev/null; do
    resolve_active_run
    if (( $(date +%s) - start >= deadline )); then cancel_active "phase deadline ${deadline}s"; break; fi
    if (( $(remaining) <= CLEANUP_RESERVE_S )); then cancel_active "aggregate budget ${TOTAL_BUDGET_S}s reached cleanup reserve"; break; fi
    sleep 1
  done
  resolve_active_run
  if [[ -n $UNRESOLVED ]]; then RB_RC=""; else wait "$ACTIVE_PID" 2>/dev/null; RB_RC=$?; fi
}

# name | outer_s | grace_s | worst_case_s (= outer + grace + 102, +10 recovery for quarantine class) | seam | class | fault
#   class: normal      launcher must release the lease, session EMPTY, no live holder
#          quarantine  launcher must leave a LIVE identity-checked holder on the private lease (exit 5/11); driver recovers it
#          refusal     launcher refuses pre-spawn (8): no OWNED_SID, lease released, no holder
CONTROLS=(
  "nested-orphan-after-exit|25|3|130||normal|"
  "live-step-interrupt|4|6|112||normal|"
  "live-step-double-term|4|6|112|step-after-reap|normal|"
  "predicate-rc0|10|3|115||normal|"
  "record-without-sentinel|10|3|115||normal|"
  "lease-held-by-supervisor|10|3|115||normal|"
  "refuse|10|3|115||normal|"
  "fault-holder-unverifiable|10|3|115||refusal|holder-unverifiable"
  "fault-survivors-quarantine|4|6|122||quarantine|census-members-persist"
  "fault-receipt-unwritable|4|6|122||quarantine|census-members-persist,receipt-unwritable"
  "fault-census-unknown|10|3|125||quarantine|census-unknown"
)
log "V6 controls start total_budget=${TOTAL_BUDGET_S}s reserve=${CLEANUP_RESERVE_S}s launcher=$(sha256sum "$LAUNCHER" | cut -c1-16) lib=$(sha256sum "$V6/runner/s4-r6-lib-v6.sh" | cut -c1-16) stub=$(sha256sum "$V6/controls/s4-r6-control-stub-v6.sh" | cut -c1-16) predicates=$(sha256sum "$PRED" | cut -c1-16) private_lease=$PRIVATE_LEASE driver_pid=$$ driver_start=$(proc_start $$) timeout=$(readlink -f "$(command -v timeout)") sleep=$(readlink -f "$(command -v sleep)")"
if ! timeout --foreground "$LEASE_S" flock -n "$PRIVATE_LEASE" true; then log "STOP: private control lease already held before start (stale holder? inspect $RECEIPTS/*/QUARANTINE_LEASE_HOLDER and DRIVER-UNRESOLVED-*)"; exit 95; fi
n=0
for spec in "${CONTROLS[@]}"; do
  IFS='|' read -r name outer grace worst seam klass fault <<< "$spec"; n=$((n+1))
  if (( worst + CLEANUP_RESERVE_S > $(remaining) )); then finish 92 "control $n ($name) worst ${worst}s + reserve exceeds remaining $(remaining)s"; fi
  before=$(ls -1 "$RECEIPTS" | grep -c '^CONTROL-V6-' || :)
  log "control $n/$((${#CONTROLS[@]}+1)) $name class=$klass fault='${fault}' outer=${outer}s grace=${grace}s seam='${seam}' launcher_bound=$((outer+grace+LAUNCHER_POST_S))s elapsed=$(elapsed)s remaining=$(remaining)s"
  S4R6_CONTROL=1 S4R6_SCENARIO=$name S4R6_OUTER_S=$outer S4R6_GRACE_S=$grace S4R6_SEAM=$seam S4R6_FAULT=$fault \
    run_bounded $((outer+grace+LAUNCHER_POST_S)) "$grace" "$DRIVER_LOG" bash "$LAUNCHER"
  lrc=$RB_RC
  run_dir=$ACTIVE_RUN_DIR; LAST_RUN_DIR=${run_dir:-$LAST_RUN_DIR}
  after=$(ls -1 "$RECEIPTS" | grep -c '^CONTROL-V6-' || :)
  [[ -z $CANCELLED ]] || finish 96 "control $name was cancelled by the driver ($CANCELLED); launcher_exit=${lrc:-unresolved} run=${run_dir:-<none>} identity=$RUN_IDENTITY"
  [[ $after == $((before+1)) && -n $run_dir && $RUN_IDENTITY == BOUND ]] || finish 93 "expected exactly one new run directory bound to launcher pid $ACTIVE_PID (before=$before after=$after identity=$RUN_IDENTITY)"
  ACTIVE_PID=""   # launcher exited and is reaped (wait); the run stays bound in LAST_RUN_DIR for finish
  timeout --foreground "$PRED_S" python3 "$PRED" "$name" "$run_dir" "$lrc" | tee "$run_dir/PREDICATES.txt" | tee -a "$DRIVER_LOG"
  prc=${PIPESTATUS[0]}
  # independent facts: owned session empty as the launcher LEFT it (LEFT_FIRST, bounded census with state); private lease released by the launcher
  session_state "$run_dir"
  qh=""; holder_alive "$run_dir" && qh=$(holder_identity "$run_dir")
  log "control $name class=$klass launcher_exit=$lrc predicates_rc=$prc leftovers_in_session='${LEFT_FIRST}' (census=$LEFT_FIRST_STATE; after driver reap: '${LEFT_FINAL}' census=$LEFT_FINAL_STATE) private_lease_free=$LEASE_FREE live_quarantine_holder='${qh}' dir=$run_dir elapsed=$(elapsed)s"
  if [[ $klass == refusal ]]; then
    [[ $LEFT_FIRST_STATE == NO_SESSION ]] || finish 94 "refusal control $name: an owned session was recorded ($LEFT_FIRST_STATE) although the launcher must refuse before spawning"
  elif [[ $LEFT_FIRST_STATE != EMPTY && $LEFT_FIRST_STATE != MEMBERS ]]; then finish 99 "control $name: owned-session census not verified ($LEFT_FIRST_STATE) — not evidence of an empty session"; fi
  [[ $prc == 0 ]] || finish 94 "first unexpected result: $name (predicates)"
  case $klass in
    normal|refusal)
      # the launcher must have released: no live holder, lease free, session EMPTY as left
      if [[ -n $qh ]]; then finish 94 "control $name left a LIVE quarantine holder ($qh) — lease intentionally retained; not expected here; do not kill without identity check"; fi
      if [[ -n $LEFT_FIRST || $LEASE_FREE != true ]]; then finish 94 "first unexpected result: $name (leftovers='${LEFT_FIRST}' lease_free=$LEASE_FREE)"; fi
      ;;
    quarantine)
      # B-06: the REAL quarantine path ran on the private lease. Expected facts BEFORE recovery: live identity-checked holder,
      # private lease NOT free, real session EMPTY (the survivors were injected census data, so nothing is actually unresolved).
      if [[ -z $qh ]]; then finish 94 "fault control $name: no LIVE identity-checked holder (exit=$lrc) — quarantine did not retain exclusion"; fi
      if [[ $LEASE_FREE == true ]]; then finish 98 "fault control $name: private lease FREE while a holder is recorded (exit=$lrc) — unsafe release"; fi
      if [[ -n $LEFT_FIRST ]]; then finish 94 "fault control $name: real owned-session leftovers '${LEFT_FIRST}' (injected census expected EMPTY reality)"; fi
      recover_holder "$run_dir" || finish 94 "fault control $name: identity-checked recovery did not terminate the holder"
      session_state "$run_dir"
      log "control $name recovery: holder terminated; private_lease_free=$LEASE_FREE final_census=$LEFT_FINAL_STATE"
      if [[ $LEASE_FREE != true || $LEFT_FINAL_STATE != EMPTY ]]; then finish 94 "fault control $name: after recovery lease_free=$LEASE_FREE census=$LEFT_FINAL_STATE"; fi
      ;;
  esac
  JUDGED_OK_DIR=$run_dir
done
# last control: direct invocation of the REAL runner without the launcher must refuse (71) and create nothing
if (( 7 + CLEANUP_RESERVE_S > $(remaining) )); then finish 92 "no budget for direct-refusal control"; fi
runs_before=$(ls -1 "$ROOT/execution/s4-r6-validation/runs" 2>/dev/null | wc -l)
out=$(timeout --foreground 5 bash "$V6/runner/s4-r6-validate-v6.sh" 2>&1); drc=$?
runs_after=$(ls -1 "$ROOT/execution/s4-r6-validation/runs" 2>/dev/null | wc -l)
printf '%s\nexit=%s runs_before=%s runs_after=%s\n' "$out" "$drc" "$runs_before" "$runs_after" > "$RECEIPTS/DIRECT-REFUSAL-$(date -u +%Y%m%dT%H%M%SZ).txt"
log "control $((${#CONTROLS[@]}+1))/$((${#CONTROLS[@]}+1)) direct-runner-refusal exit=$drc (expect 71) message='$out' runs_dir_unchanged=$([[ $runs_before == "$runs_after" ]] && echo true || echo false)"
if [[ $drc != 71 || $runs_before != "$runs_after" || $out != *"REFUSE: not launched through the V6 launcher"* ]]; then finish 94 "direct refusal predicate failed"; fi
log "ALL $((${#CONTROLS[@]}+1)) CONTROLS OK elapsed=$(elapsed)s (hard budget ${TOTAL_BUDGET_S}s). Controls prove wrapper/ownership/lease/publication behaviour on the PRIVATE lease only — not the canonical lock's occupancy, not gates, Vitest, package, browser or acceptance."
# A-04: success is a finish() outcome too — re-checks the last run's current facts and emits the terminal receipt.
finish 0 "all controls passed"
