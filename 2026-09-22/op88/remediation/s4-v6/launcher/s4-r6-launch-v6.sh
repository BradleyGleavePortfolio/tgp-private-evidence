#!/usr/bin/env bash
# S4 R6 validation V6 — exact bounded detached launcher / supervisor / lease holder.
#
#   bash execution/s4-r6-validation/v6/launcher/s4-r6-launch-v6.sh              (kind=VALIDATION)
#   S4R6_CONTROL=1 S4R6_SCENARIO=<name> bash .../s4-r6-launch-v6.sh              (kind=CONTROL, stub runner)
#
# V5 changes versus V4 (frozen reviews S4-V4-A-02/03/04, S4-V4-B-01/05):
#  * Cleanup state before outcome precedence (A-03/B-01): SURVIVORS is resolved FIRST on every post-exit
#    path; TIMEOUT/INTERRUPTED never bypass lease retention. The cause stays in bounds.timed_out/interrupt.
#  * Checked quarantine handoff (A-04/B-05): the holder is verified alive with fd 9 -> lease path and a
#    token in its cmdline, identified by pid+starttime+token, and durably recorded BEFORE this process exits.
#    [V5 history: verification/record failure exited 10 with an UNSAFE RELEASE — rejected by S4-V5-A-03 and the
#    parent disposition; V6 below replaces that branch. No unrecorded infinite holder, no bare-PID recovery.]
#  * Enforced elapsed phases (A-02): grace/confirm/post-exit waits are wall-clock deadlines, both record
#    readers run under `timeout --foreground READ_S`, and bounds.worst_case_s/formula include every phase.
#
# V6 changes versus V5 (frozen review S4-V5-A-03 / A-05 lineage; parent disposition: exit 10 "honest unsafe
# release" is NOT containment; never kill/release the last verified exclusion holder while descendants are unresolved):
#  * STANDBY holder (A-03): the tokenized lease holder is spawned and verified (alive, fd 9 -> lease, token) right
#    after the lease is taken and BEFORE anything is owned. Creation failure is therefore a clean pre-spawn refusal
#    (STANDBY_HOLDER_FAILED 8: nothing spawned, nothing unresolved). On every non-quarantine exit the holder is
#    terminated identity-checked AFTER the owned session is verified empty; the driver's lease probe confirms release.
#  * Quarantine (A-03): with unresolved survivors the launcher re-verifies the standby holder, writes the receipt
#    and exits QUARANTINED_SURVIVORS 5. Receipt failure NEVER destroys the holder: QUARANTINED_RECEIPT_FAILED 11,
#    holder retained, identity still attributable (console.log line, SUPERVISOR_RECORD lease.*, cmdline token
#    s4r6-quarantine-holder-<RUN_ID>). If the standby holder was lost, ONE bounded respawn is tried; if that also
#    fails the launcher itself retains fd 9 (SELF-HOLD: exec -a <token>-SELF, TERM/INT/HUP ignored, would-be code 12
#    recorded, process does not exit; the caller sees a live launcher and must apply identity-checked recovery).
#    SELF-HOLD is a flagged decision point (SLOT_REQUEST_V6.md §7) — the only in-contract move that neither releases
#    exclusion nor leaves an unrecorded holder.
#  * Fail-closed census (A-05 lineage): pgrep status is kept; EMPTY (rc 1) is distinct from UNKNOWN (timeout/error).
#    UNKNOWN never counts as empty: it keeps waits waiting, forces the survivors path into quarantine and is recorded
#    as owned_session.census_state. Census calls are bounded (CENSUS_S) and their allowance is in the formula.
#  * Publication: the JSON re-parse is bounded too; mv/log are not (stated in bounds.bound_qualification).
#  * CONTROL-ONLY fault seams (S4-V5-B-06: the survivor/quarantine/creation/publication paths must be exercised on the
#    PRIVATE lease before any canonical first use). Gated on KIND=CONTROL AND S4R6_FAULT (comma list), inert otherwise:
#      holder-unverifiable     standby verification compares a never-matching token -> STANDBY_HOLDER_FAILED 8, nothing owned
#      census-members-persist  after the runner exited, census keeps reporting the members seen at the deadline
#                              (data-level "unkillable survivors") -> quarantine on the REAL holder/receipt code -> 5
#      receipt-unwritable      the receipt is written under a non-existent directory -> holder retained -> 11
#      census-unknown          after the runner exited, census reports UNKNOWN:124 -> quarantine -> 5 with census_state UNKNOWN
#    The driver's fault controls then apply the identity-checked recovery rule (§6) to the recorded holder on the private lease.
#
# V4 changes versus V3 (frozen reviews S4-V3-A-01..04):
#  * Lease outside the killable workload (A-04): the launcher takes `flock -n` on the lease file
#    (VALIDATION: the canonical lock; CONTROL: a PRIVATE control lock under v4/control-runs, never the
#    canonical one) BEFORE spawning and keeps it through verified supervisor cleanup. The runner only
#    verifies the inherited fd 9. If survivors cannot be verified gone, the lease is NOT released: a
#    detached quarantine holder inheriting fd 9 keeps it and its pid is recorded (unsafe handoff).
#  * Aggregate bound (A-03): post-deadline phases are constants (grace, confirm, post-exit reap 8 s,
#    publish 5 s under `timeout --foreground`); `bounds.worst_case_s` records the same formula the
#    request advertises. INTERRUPT (TERM/INT to the launcher) is the cancellation route: it tears down
#    the owned session, reaps, publishes, and exits — the driver forwards TERM here.
# V3 changes versus V2 (frozen reviews S4-V2-A-01..05 / S4-R6-VPB-F01..03):
#  * Ownership by construction, no startup sleep (A-03/F-03): the launcher refuses to run if it is
#    itself a process-group leader, so util-linux `setsid` execs the runner IN PLACE and the runner
#    pid RPID is the session leader: SID == PGID == RPID immediately. The runner (real or stub)
#    writes its $$ to RUNNER_PID as a cross-check; a mismatch is classified, never assumed.
#  * Owned boundary = the SESSION (A-01/F-01): census `pgrep -s SID`; deadline/interrupt signals go
#    to every foreign process group in the session and to every listed pid, so `timeout`-wrapped
#    step groups, npm/Vitest workers and Chrome are reached — not only the runner bash.
#  * Bounded confirmation (A-03): no unconditional `wait`; runner exit is confirmed by bounded
#    polling, otherwise QUARANTINED without blocking.
#  * JSON-safe publication (A-02/F-02): every value reaches Python through argv; Booleans are
#    coerced there. The supervisor record is written on EVERY exit path including refusals, and
#    publication failure is a separate fact (publication_ok) from the primary outcome (overall).
#  * Census + reap on every exit path, refusals included (F-03).
set -u
ROOT=/home/user/workspace
VAL=$ROOT/execution/s4-r6-validation
V6=$VAL/v6
KIND=VALIDATION; RUNNER=$V6/runner/s4-r6-validate-v6.sh; RUNS=$VAL/runs
LEASE_PATH=$ROOT/execution/test-validation.lock; LEASE_KIND=canonical-held-by-launcher
if [[ ${S4R6_CONTROL:-0} == 1 ]]; then KIND=CONTROL; RUNNER=$V6/controls/s4-r6-control-stub-v6.sh; RUNS=$V6/control-runs; : "${S4R6_SCENARIO:?control scenario required}"; LEASE_PATH=$V6/control-runs/.private-control-lease.lock; LEASE_KIND=private-held-by-launcher; fi
OUTER_S=${S4R6_OUTER_S:-3300}   # mandatory total bound for the runner (validation default 55 min)
GRACE_S=${S4R6_GRACE_S:-45}     # TERM→KILL grace for the owned session
CONFIRM_S=10                    # bounded wait for runner exit after KILL before QUARANTINED
POST_S=8                        # post-exit orphan reap loops (5 s TERM + 3 s KILL)
PUBLISH_S=5                     # record writer bound (timeout --foreground)
READ_S=5                        # each EXIT_RECORD reader bound (timeout --foreground); two readers per run
QH_VERIFY_S=5                   # holder verification bound (standby at start; re-verify/respawn at quarantine)
CENSUS_S=2                      # bound of ONE pgrep census (A-05 lineage); state UNKNOWN on timeout/error
CENSUS_CALLS_MAX=16             # census calls outside wall-clock loops on the longest path (counted in source)
WORST_EXTRA_S=$((READ_S*2+QH_VERIFY_S*2+CENSUS_CALLS_MAX*CENSUS_S+2))   # readers + 2 holder verifications + census + slack
now() { date -u +%FT%TZ; }
sha() { sha256sum "$1" 2>/dev/null | cut -d' ' -f1; }
T0=$(date +%s); LAUNCH_START=$(now)

# ---- state for the record (defaults so every exit path can publish) ----------------------------
RUN_ID=""; OUT=""; CONSOLE=/dev/null; SUP=""; RPID=""; SID=""; RUNNER_SHA=""; RUNNER_PID_FILE=""
RUNNER_RC=""; RUNNER_EXIT_CONFIRMED=false; TIMED_OUT=false; INTERRUPT=""; SIGNALLED=none
MEMBERS_AT_DEADLINE=""; ORPHANS=""; REAPED_HERE=""; SURVIVORS=""; REFUSAL=""
LEASE_HELD=false; LEASE_RELEASED_AT_EXIT=true; QUARANTINE_HOLDER=""; QUARANTINE_HOLDER_START=""; QUARANTINE_TOKEN=""; QUARANTINE_OK=""; QUARANTINE_FAILURE=""
QUARANTINE_RECEIPT_OK=""; STANDBY_VERIFIED=false; STANDBY_RELEASED=""; STANDBY_RESPAWNED=false; SELF_HOLD=false
MEMBERS=""; CENSUS_STATE=NONE; SURVIVORS_STATE=NONE
FAULT_ARMED=false
has_fault() { [[ $KIND == CONTROL && ",${S4R6_FAULT:-}," == *",$1,"* ]]; }

# census: bounded owned-session census (A-05 lineage). Sets MEMBERS (space-separated pids) and CENSUS_STATE:
#   EMPTY   (pgrep rc 1, no member)   MEMBERS (rc 0)   UNKNOWN:<rc> (124 timeout / other error / no SID yet)
# UNKNOWN is never treated as empty by any caller.
census() {
  local rc; MEMBERS=""
  if [[ -z $SID ]]; then CENSUS_STATE=UNKNOWN:nosid; return 0; fi
  MEMBERS=$(timeout --foreground "$CENSUS_S" pgrep -s "$SID" 2>/dev/null | tr '\n' ' '); rc=${PIPESTATUS[0]}
  case $rc in 0) CENSUS_STATE=MEMBERS;; 1) CENSUS_STATE=EMPTY; MEMBERS="";; *) CENSUS_STATE="UNKNOWN:$rc"; MEMBERS="";; esac
  if [[ $FAULT_ARMED == true ]]; then   # CONTROL-ONLY data-level faults (B-06); real census result replaced AFTER the runner exited
    if has_fault census-members-persist; then CENSUS_STATE=MEMBERS; MEMBERS=${MEMBERS_AT_DEADLINE:-$SID}; fi
    if has_fault census-unknown; then CENSUS_STATE=UNKNOWN:124; MEMBERS=""; fi
  fi
  return 0
}
session_empty() { census; [[ $CENSUS_STATE == EMPTY ]]; }
# wait_session_empty <seconds>: wall-clock bounded (A-02), returns 0 as soon as the owned session is VERIFIED empty.
wait_session_empty() { local until=$(( $(date +%s) + $1 )); while (( $(date +%s) < until )); do session_empty && return 0; sleep 1; done; session_empty; }
# wait_pid_gone <pid> <seconds>: wall-clock bounded, returns 0 once the pid is gone.
wait_pid_gone() { local until=$(( $(date +%s) + $2 )); while (( $(date +%s) < until )); do kill -0 "$1" 2>/dev/null || return 0; sleep 1; done; ! kill -0 "$1" 2>/dev/null; }
# proc_start <pid>: kernel start time (clock ticks) from /proc/<pid>/stat, comm-safe; identity for holder recovery.
proc_start() { sed 's/^.*) //' "/proc/$1/stat" 2>/dev/null | awk '{print $20}'; }
# read_record_result <file>: bounded reader (A-02); prints result or MISSING_OR_UNPARSEABLE.
read_record_result() {
  local r; r=$(timeout --foreground "$READ_S" python3 -c 'import json,sys
try: print(json.load(open(sys.argv[1])).get("result","UNPARSEABLE"))
except Exception: print("MISSING_OR_UNPARSEABLE")' "$1" 2>/dev/null); [[ -n $r ]] && echo "$r" || echo MISSING_OR_UNPARSEABLE
}
# signal_session <SIG>: every foreign process group in the owned session (-pgid), then every pid.
signal_session() {
  local sig=$1 p g
  census; for p in $MEMBERS; do g=$(ps -o pgid= -p "$p" 2>/dev/null | tr -d ' '); [[ -n $g ]] && kill "-$sig" -- "-$g" 2>/dev/null; done
  census; for p in $MEMBERS; do kill "-$sig" "$p" 2>/dev/null; done
  return 0
}
log() { echo "[$(now)] $*" | tee -a "$CONSOLE"; }

# ---- tokenized lease holder (S4-V5-A-03): one bash keeping fd 9; its sleep children close fd 9 (9>&-) so ONLY the
# recorded pid holds the lease. Identity = pid + starttime + token (cmdline) + readlink fd 9. ------------------------
holder_ok() {  # holder_ok <pid> <token>: identity triple verified now
  kill -0 "$1" 2>/dev/null && [[ $(readlink "/proc/$1/fd/9" 2>/dev/null) == "$LEASE_PATH" ]] && tr '\0' ' ' < "/proc/$1/cmdline" 2>/dev/null | grep -q -- "$2"
}
spawn_holder() {  # spawn_holder: sets QUARANTINE_HOLDER/_START/_TOKEN; returns 0 only when verified within QH_VERIFY_S
  QUARANTINE_TOKEN="s4r6-quarantine-holder-$RUN_ID"
  setsid bash -c 'while :; do sleep 60 9>&-; done' "$QUARANTINE_TOKEN" < /dev/null > /dev/null 2>&1 &
  QUARANTINE_HOLDER=$!
  local until=$(( $(date +%s) + QH_VERIFY_S )) vtoken=$QUARANTINE_TOKEN
  has_fault holder-unverifiable && vtoken="$QUARANTINE_TOKEN-NEVER-MATCHES"   # CONTROL-ONLY (B-06): verification must fail
  while (( $(date +%s) < until )); do holder_ok "$QUARANTINE_HOLDER" "$vtoken" && break; sleep 1; done
  QUARANTINE_HOLDER_START=$(proc_start "$QUARANTINE_HOLDER")
  if holder_ok "$QUARANTINE_HOLDER" "$vtoken" && [[ -n $QUARANTINE_HOLDER_START ]]; then return 0; fi
  # not verified: whatever we spawned is terminated identity-checked (token); nothing is owned yet or it is re-tried by the caller
  if kill -0 "$QUARANTINE_HOLDER" 2>/dev/null && tr '\0' ' ' < "/proc/$QUARANTINE_HOLDER/cmdline" 2>/dev/null | grep -q -- "$QUARANTINE_TOKEN"; then kill -KILL "$QUARANTINE_HOLDER" 2>/dev/null; fi
  return 1
}
release_standby_holder() {  # only after the owned session is VERIFIED empty (caller guarantees); identity-checked KILL, bounded wait
  STANDBY_RELEASED=false
  [[ -n $QUARANTINE_HOLDER ]] || { STANDBY_RELEASED=n/a; return 0; }
  if [[ $(proc_start "$QUARANTINE_HOLDER") == "$QUARANTINE_HOLDER_START" ]] && holder_ok "$QUARANTINE_HOLDER" "$QUARANTINE_TOKEN"; then kill -KILL "$QUARANTINE_HOLDER" 2>/dev/null; fi
  wait_pid_gone "$QUARANTINE_HOLDER" 3 && STANDBY_RELEASED=true
  [[ $STANDBY_RELEASED == true ]]
}

publish_and_exit() {
  local overall=$1 code=$2
  # non-quarantine exits release exclusion ONLY here, after the census that led to this outcome; a failed release is
  # recorded and downgrades SUCCESS (the lease stays held => the next launcher refuses 75; fail-closed, never silent)
  if [[ $QUARANTINE_OK != true && $SELF_HOLD != true ]]; then
    release_standby_holder || { log "standby holder pid=$QUARANTINE_HOLDER could not be released (lease may stay held; fail-closed)"; [[ $overall == SUCCESS ]] && { overall=FAILED_PUBLICATION; code=7; }; }
  fi
  local end; end=$(now)
  local runner_result=MISSING_OR_UNPARSEABLE sentinel=no record_present=false runner_pid_seen=""
  if [[ -n $OUT ]]; then
    [[ -f $OUT/RUN_COMPLETE.sentinel ]] && sentinel=yes
    [[ -f $OUT/EXIT_RECORD.json ]] && record_present=true
    runner_result=$(read_record_result "$OUT/EXIT_RECORD.json")
    [[ -f $RUNNER_PID_FILE ]] && runner_pid_seen=$(tr -d ' \n' < "$RUNNER_PID_FILE")
  fi
  local publication_ok=false
  if [[ -n $SUP ]]; then
    timeout --foreground "$PUBLISH_S" python3 - "$SUP.tmp" "$KIND" "${S4R6_SCENARIO:-}" "$RUN_ID" "$overall" "$code" "$RUNNER" "$RUNNER_SHA" "$RPID" "$RUNNER_RC" "$RUNNER_EXIT_CONFIRMED" "$runner_result" "$sentinel" "$record_present" "$SID" "$runner_pid_seen" "$SIGNALLED" "$MEMBERS_AT_DEADLINE" "$ORPHANS" "$REAPED_HERE" "$SURVIVORS" "$OUTER_S" "$GRACE_S" "$CONFIRM_S" "$TIMED_OUT" "$INTERRUPT" "$REFUSAL" "$LAUNCH_START" "$end" "$OUT" "$CONSOLE" "$POST_S" "$PUBLISH_S" "$LEASE_PATH" "$LEASE_KIND" "$LEASE_HELD" "$LEASE_RELEASED_AT_EXIT" "$QUARANTINE_HOLDER" "$$" "$READ_S" "$QH_VERIFY_S" "$WORST_EXTRA_S" "$QUARANTINE_HOLDER_START" "$QUARANTINE_TOKEN" "$QUARANTINE_OK" "$QUARANTINE_FAILURE" "$(proc_start $$)" "$QUARANTINE_RECEIPT_OK" "$STANDBY_VERIFIED" "$STANDBY_RELEASED" "$STANDBY_RESPAWNED" "$SELF_HOLD" "$CENSUS_S" "$CENSUS_CALLS_MAX" "$SURVIVORS_STATE" "${S4R6_FAULT:-}" <<'PY'
import json,sys
a=sys.argv[1:]
(out,kind,scenario,run_id,overall,code,runner,runner_sha,rpid,runner_rc,exit_confirmed,runner_result,sentinel,record_present,sid,runner_pid_seen,signalled,members_at_deadline,orphans,reaped_here,survivors,outer_s,grace_s,confirm_s,timed_out,interrupt,refusal,start,end,outdir,console,post_s,publish_s,lease_path,lease_kind,lease_held,lease_released,quarantine_holder,launcher_pid,read_s,qh_verify_s,worst_extra_s,qh_start,qh_token,qh_ok,qh_failure,launcher_start,qh_receipt_ok,standby_verified,standby_released,standby_respawned,self_hold,census_s,census_calls_max,survivors_state,fault)=a
def num(x):
    try: return int(x)
    except Exception: return None
b=lambda x: x=="true"
json.dump({"kind":kind,"scenario":scenario or None,"control_fault":(fault or None) if kind=="CONTROL" else None,"run_id":run_id or None,"overall":overall,"launcher_exit":num(code),
 "overall_semantics":"SUCCESS only if runner exit 0 confirmed, runner EXIT_RECORD.result==SUCCESS, sentinel present, RUNNER_PID handshake matches, owned session empty without supervisor reaping; everything else is non-success. publication_ok is recorded separately by the caller after this file is parsed.",
 "runner":{"path":runner,"sha256":runner_sha or None,"spawned_pid":num(rpid),"exit":num(runner_rc),"exit_confirmed":b(exit_confirmed),"exit_record_result":runner_result,"exit_record_present":b(record_present),"sentinel":sentinel=="yes","runner_pid_handshake":num(runner_pid_seen),"handshake_ok":(num(runner_pid_seen)==num(rpid)) if runner_pid_seen else None},
 "owned_session":{"sid":num(sid),"census_state":survivors_state,"signal_route":"kill -SIG -- -pgid for every foreign pgid in session, then kill -SIG pid for every member; never outside the session","signalled":signalled,"members_at_deadline":members_at_deadline.split(),"orphans_after_runner_exit":orphans.split(),"reaped_by_supervisor":reaped_here.split(),"survivors_after_kill":survivors.split()},
 "bounds":{"outer_s":num(outer_s),"grace_s":num(grace_s),"confirm_s":num(confirm_s),"post_exit_reap_s":num(post_s),"publish_s":num(publish_s),"read_s":num(read_s),"quarantine_verify_s":num(qh_verify_s),"timed_out":b(timed_out),"interrupt":interrupt or None,"worst_case_s":num(outer_s)+num(grace_s)+num(confirm_s)+num(post_s)+num(publish_s)+num(worst_extra_s),"worst_case_formula":"outer+grace+confirm+post_exit_reap+publish+2*read+2*quarantine_verify+16*census+2","census_s":num(census_s),"census_calls_max":num(census_calls_max),"phases_are_wall_clock":True,"bound_qualification":"sum of declared phase allowances; waits are wall-clock deadlines and every census/reader/writer/re-parse call is under timeout; mv and log lines are not enclosed by a timeout"},
 "lease":{"path":lease_path,"kind":lease_kind,"holder_pid":num(launcher_pid),"holder_starttime":num(launcher_start),"held_by_launcher":b(lease_held),"released_at_launcher_exit":b(lease_released),"quarantine_holder_pid":num(quarantine_holder),"quarantine_holder_starttime":num(qh_start),"quarantine_holder_token":qh_token or None,"quarantine_ok":(qh_ok=="true") if qh_ok else None,"quarantine_receipt_ok":(qh_receipt_ok=="true") if qh_receipt_ok else None,"quarantine_failure":qh_failure or None,"standby_holder_verified":b(standby_verified),"standby_holder_released":(None if standby_released in ("","n/a") else standby_released=="true"),"standby_holder_respawned":b(standby_respawned),"self_hold":b(self_hold),"semantics":"held from before spawn until verified cleanup by launcher AND a verified standby tokenized holder spawned before anything is owned; unverified survivors or UNKNOWN census on ANY path => the holder keeps the lease (QUARANTINED_SURVIVORS 5 with receipt, QUARANTINED_RECEIPT_FAILED 11 without receipt but holder retained, SELF_HOLD 12 launcher retains fd 9 itself and does not exit). Exclusion is never released while descendants are unresolved. Recovery must verify pid+starttime+token+fd9 before any kill."},
 "refusal":refusal or None,"start_utc":start,"end_utc":end,"out_dir":outdir or None,"console":console},open(out,"w"),indent=2)
PY
    if [[ $? == 0 ]] && timeout --foreground "$READ_S" python3 -c 'import json,sys;json.load(open(sys.argv[1]))' "$SUP.tmp" 2>/dev/null && mv "$SUP.tmp" "$SUP"; then publication_ok=true; fi
  fi
  log "OVERALL=$overall launcher_exit=$code publication_ok=$publication_ok runner_exit=${RUNNER_RC:-none} runner_result=$runner_result survivors='${SURVIVORS}' record=${SUP:-none}"
  if [[ $publication_ok != true && $overall == SUCCESS ]]; then log "publication failed on a SUCCESS path — downgrading to FAILED_PUBLICATION"; code=7; fi
  if [[ $SELF_HOLD == true ]]; then
    # the last verified exclusion holder is THIS process: do not exit. Identity for recovery: pid $$ (starttime
    # recorded), cmdline token, fd 9 -> lease. TERM/INT/HUP ignored so a bounded caller cancel cannot release exclusion.
    log "SELF-HOLD: launcher pid=$$ starttime=$(proc_start $$) token=$QUARANTINE_TOKEN retains $LEASE_PATH; would-be exit $code; recovery = identity-checked kill after survivors '$SURVIVORS' are verified gone"
    exec -a "$QUARANTINE_TOKEN" bash -c 'trap "" TERM INT HUP; while :; do sleep 60 9>&-; done'
    exit 12   # unreachable unless exec fails; then the process still exits holding nothing (recorded above)
  fi
  exit "$code"
}

# ---- 0. topology precondition (no sleep, no race): we must NOT be a group leader ------------------
if [[ $(ps -o pgid= -p $$ | tr -d ' ') == "$$" ]]; then
  echo "REFUSE: launcher is a process-group leader; setsid would fork and the spawned pid would not be the session leader. Start it as a plain child (e.g. 'bash launcher.sh' from a script or non-job-control shell)." >&2; exit 73
fi

# ---- 1. fresh exclusive run directory + safe id ------------------------------------------------------
mkdir -p "$RUNS" || exit 70
RUN_ID="${KIND}-V6-$(date -u +%Y%m%dT%H%M%SZ)-$$-$(head -c 4 /dev/urandom | od -An -tx1 | tr -d ' \n')"
OUT=$RUNS/$RUN_ID
if ! mkdir "$OUT" 2>/dev/null; then echo "REFUSE: run directory exists: $OUT" >&2; exit 71; fi
CONSOLE=$OUT/console.log; : > "$CONSOLE" || exit 70
SUP=$OUT/SUPERVISOR_RECORD.json; RUNNER_PID_FILE=$OUT/RUNNER_PID
printf '%s\n' "$RUN_ID" > "$OUT/LAUNCH_TOKEN"
RUNNER_SHA=$(sha "$RUNNER")
[[ -n $RUNNER_SHA ]] || { REFUSAL="runner missing: $RUNNER"; log "REFUSE: $REFUSAL"; publish_and_exit REFUSED 72; }
# ---- 1b. lease (A-04): taken here, outside the killable workload, before anything is spawned -------
exec 9>"$LEASE_PATH" || { REFUSAL="cannot open lease $LEASE_PATH"; log "REFUSE: $REFUSAL"; publish_and_exit REFUSED 70; }
if ! flock -n 9; then REFUSAL="lease busy: $LEASE_PATH (a free lease is not permission; nothing spawned)"; log "REFUSE: $REFUSAL"; publish_and_exit LEASE_BUSY 75; fi
LEASE_HELD=true; echo "$$ launcher $RUN_ID $(now)" >&9
log "lease held kind=$LEASE_KIND path=$LEASE_PATH holder=$$ (fd 9; inherited by runner for verification only; step children close it)"
# ---- 1c. STANDBY tokenized holder (S4-V5-A-03): created and verified BEFORE anything is owned, so holder-creation
# failure is a clean refusal with nothing unresolved. Released identity-checked only after a verified-empty census.
if spawn_holder; then
  STANDBY_VERIFIED=true
  log "standby holder verified pid=$QUARANTINE_HOLDER starttime=$QUARANTINE_HOLDER_START token=$QUARANTINE_TOKEN fd9=$LEASE_PATH"
else
  REFUSAL="standby lease holder could not be verified within ${QH_VERIFY_S}s (nothing spawned; lease released at exit)"; log "REFUSE: $REFUSAL"; publish_and_exit STANDBY_HOLDER_FAILED 8
fi
log "launch kind=$KIND scenario=${S4R6_SCENARIO:-} run=$RUN_ID runner=$RUNNER sha256=$RUNNER_SHA outer=${OUTER_S}s grace=${GRACE_S}s confirm=${CONFIRM_S}s post=${POST_S}s publish=${PUBLISH_S}s read=${READ_S}s qverify=${QH_VERIFY_S}s worst=$((OUTER_S+GRACE_S+CONFIRM_S+POST_S+PUBLISH_S+WORST_EXTRA_S))s launcher_start=$(proc_start $$)"

# ---- 2. detached session; ownership by construction ----------------------------------------------------
INTERRUPT=""; trap 'INTERRUPT=TERM' TERM; trap 'INTERRUPT=INT' INT
S4R6_RUN_ID=$RUN_ID S4R6_OUT=$OUT S4R6_LAUNCH_TOKEN=$RUN_ID S4R6_KIND=$KIND S4R6_SCENARIO=${S4R6_SCENARIO:-} \
S4R6_LEASE=$LEASE_KIND S4R6_LEASE_PID=$$ S4R6_LEASE_PATH=$LEASE_PATH \
  setsid bash "$RUNNER" >>"$CONSOLE" 2>&1 < /dev/null &
RPID=$!
SID=$RPID   # non-leader child ⇒ setsid execs in place ⇒ runner pid is session leader (verified by RUNNER_PID handshake)
echo "$SID" > "$OUT/OWNED_SID"
log "owned session sid=$SID (runner pid $RPID)"

# ---- 3. supervision with mandatory deadline ---------------------------------------------------------------
while kill -0 "$RPID" 2>/dev/null; do
  if [[ -n $INTERRUPT ]]; then log "supervisor received $INTERRUPT"; break; fi
  if (( $(date +%s) - T0 >= OUTER_S )); then TIMED_OUT=true; log "OUTER DEADLINE ${OUTER_S}s reached"; break; fi
  sleep 1
done
if [[ $TIMED_OUT == true || -n $INTERRUPT ]]; then
  census; MEMBERS_AT_DEADLINE=$MEMBERS
  log "TERM owned session $SID members: $MEMBERS_AT_DEADLINE (census=$CENSUS_STATE)"
  signal_session TERM; SIGNALLED=TERM
  wait_session_empty "$GRACE_S" || { census; log "KILL owned session survivors: $MEMBERS (census=$CENSUS_STATE)"; signal_session KILL; SIGNALLED=TERM+KILL; }
fi
# bounded confirmation of the runner's exit (never an unconditional wait); wall-clock (A-02)
wait_pid_gone "$RPID" "$CONFIRM_S" || :
quarantine_exit() {
  # Unresolved survivors (or UNKNOWN census): exclusion is NEVER released. Order (S4-V5-A-03):
  #  1. re-verify the standby holder (identity triple + recorded starttime);
  #  2. if lost: ONE bounded respawn (recorded standby_holder_respawned=true);
  #  3. if no verified holder exists: SELF-HOLD — this process keeps fd 9 and does not exit (would-be code 12);
  #  4. write the receipt tmp+mv; failure keeps the holder and exits 11 (identity remains in console.log,
  #     SUPERVISOR_RECORD.lease.* and the holder's cmdline token; recovery rule unchanged).
  local verified=false
  if [[ -n $QUARANTINE_HOLDER && $(proc_start "$QUARANTINE_HOLDER") == "$QUARANTINE_HOLDER_START" ]] && holder_ok "$QUARANTINE_HOLDER" "$QUARANTINE_TOKEN"; then verified=true
  else
    log "standby holder pid=${QUARANTINE_HOLDER:-none} not verified at quarantine time — one bounded respawn"
    STANDBY_RESPAWNED=true
    if spawn_holder; then verified=true; log "respawned holder verified pid=$QUARANTINE_HOLDER starttime=$QUARANTINE_HOLDER_START"; fi
  fi
  if [[ $verified != true ]]; then
    SELF_HOLD=true; QUARANTINE_HOLDER=$$; QUARANTINE_HOLDER_START=$(proc_start $$); QUARANTINE_TOKEN="s4r6-quarantine-holder-$RUN_ID-SELF"
    QUARANTINE_OK=true; QUARANTINE_RECEIPT_OK=false; LEASE_RELEASED_AT_EXIT=false
    QUARANTINE_FAILURE="no verified tokenized holder (standby lost, respawn failed): launcher retains fd 9 itself and does not exit"
  else
    QUARANTINE_OK=true; LEASE_RELEASED_AT_EXIT=false
  fi
  local receipt=$OUT/QUARANTINE_LEASE_HOLDER
  has_fault receipt-unwritable && receipt=$OUT/no-such-dir/QUARANTINE_LEASE_HOLDER   # CONTROL-ONLY (B-06): publication must fail
  if printf 'pid=%s starttime=%s token=%s lease=%s lease_kind=%s run=%s owned_sid=%s survivors=%s census=%s launcher_pid=%s self_hold=%s recorded=%s\nRECOVERY: kill ONLY if /proc/<pid>/stat starttime == %s AND /proc/<pid>/cmdline contains %s AND readlink /proc/<pid>/fd/9 == %s, after the listed survivors are verified gone. Never signal a bare pid.\n' \
       "$QUARANTINE_HOLDER" "$QUARANTINE_HOLDER_START" "$QUARANTINE_TOKEN" "$LEASE_PATH" "$LEASE_KIND" "$RUN_ID" "$SID" "$SURVIVORS" "$SURVIVORS_STATE" "$$" "$SELF_HOLD" "$(now)" "$QUARANTINE_HOLDER_START" "$QUARANTINE_TOKEN" "$LEASE_PATH" > "$receipt.tmp" 2>/dev/null \
     && mv "$receipt.tmp" "$receipt" 2>/dev/null && [[ -s $receipt ]]; then
    QUARANTINE_RECEIPT_OK=true
  else
    QUARANTINE_RECEIPT_OK=false; QUARANTINE_FAILURE="${QUARANTINE_FAILURE:+$QUARANTINE_FAILURE; }QUARANTINE_LEASE_HOLDER receipt could not be written (holder RETAINED)"
  fi
  log "UNSAFE HANDOFF: survivors='$SURVIVORS' census=$SURVIVORS_STATE — lease $LEASE_PATH retained by holder pid=$QUARANTINE_HOLDER starttime=$QUARANTINE_HOLDER_START token=$QUARANTINE_TOKEN receipt_ok=$QUARANTINE_RECEIPT_OK self_hold=$SELF_HOLD (never SUCCESS, never permission for another lane)"
  if   [[ $SELF_HOLD == true ]]; then publish_and_exit QUARANTINED_SELF_HOLD 12
  elif [[ $QUARANTINE_RECEIPT_OK == true ]]; then publish_and_exit QUARANTINED_SURVIVORS 5
  else publish_and_exit QUARANTINED_RECEIPT_FAILED 11; fi
}
if kill -0 "$RPID" 2>/dev/null; then
  RUNNER_EXIT_CONFIRMED=false; census; SURVIVORS=$MEMBERS; SURVIVORS_STATE=$CENSUS_STATE
  [[ -z $SURVIVORS && $SURVIVORS_STATE == EMPTY ]] && SURVIVORS_STATE="MEMBERS:runner-alive-unlisted"   # runner alive => unresolved regardless of census
  quarantine_exit
fi
wait "$RPID" 2>/dev/null; RUNNER_RC=$?; RUNNER_EXIT_CONFIRMED=true
FAULT_ARMED=true   # CONTROL-ONLY census faults (B-06) apply only from here: the runner has really exited

# ---- 4. census + reap on every path (refusals included) --------------------------------------------------------
census; ORPHANS=$MEMBERS; ORPHANS_STATE=$CENSUS_STATE
if [[ -n $ORPHANS || $ORPHANS_STATE != EMPTY ]]; then
  log "owned orphans after runner exit: '$ORPHANS' census=$ORPHANS_STATE — TERM/KILL (UNKNOWN census is treated as unresolved)"
  for p in $ORPHANS; do printf '%s :: ' "$p"; tr '\0' ' ' < /proc/$p/cmdline 2>/dev/null | cut -c1-160; echo; done >> "$OUT/orphans.log"
  signal_session TERM; wait_session_empty 5 || { signal_session KILL; wait_session_empty 3 || :; }   # POST_S = 5 + 3, wall-clock
  REAPED_HERE=$ORPHANS   # empty when only the census was UNKNOWN; the final census below decides (UNKNOWN => quarantine)
fi
census; SURVIVORS=$MEMBERS; SURVIVORS_STATE=$CENSUS_STATE

# ---- 5. cleanup/lease state FIRST, then classification (S4-V4-A-03 / B-01) ------------------------------------
# Unverified survivors take precedence over TIMEOUT/INTERRUPTED: the lease is never released with owned work
# unaccounted for. The cause remains recorded (bounds.timed_out, bounds.interrupt, owned_session.signalled).
if [[ -n $SURVIVORS || $SURVIVORS_STATE != EMPTY ]]; then quarantine_exit; fi
HANDSHAKE=""; [[ -f $RUNNER_PID_FILE ]] && HANDSHAKE=$(tr -d ' \n' < "$RUNNER_PID_FILE")
RES=$(read_record_result "$OUT/EXIT_RECORD.json")
SENT=no; [[ -f $OUT/RUN_COMPLETE.sentinel ]] && SENT=yes
if   [[ $TIMED_OUT == true ]]; then publish_and_exit TIMEOUT 124
elif [[ -n $INTERRUPT ]]; then publish_and_exit INTERRUPTED 143
elif [[ -n $REAPED_HERE ]]; then publish_and_exit FAILED_RUNNER_LEFT_ORPHANS 6
elif [[ $RUNNER_RC == 71 || $RUNNER_RC == 73 || $RUNNER_RC == 75 ]]; then REFUSAL="runner refused with exit $RUNNER_RC (see console.log)"; publish_and_exit RUNNER_REFUSED "$RUNNER_RC"
elif [[ $RUNNER_RC != 0 ]]; then publish_and_exit RUNNER_NONZERO "$RUNNER_RC"
elif [[ -n $HANDSHAKE && $HANDSHAKE != "$RPID" ]]; then publish_and_exit FAILED_OWNERSHIP_HANDSHAKE 9
elif [[ -z $HANDSHAKE ]]; then publish_and_exit FAILED_OWNERSHIP_HANDSHAKE 9
elif [[ $RES != SUCCESS || $SENT != yes ]]; then publish_and_exit FAILED_PUBLICATION 7
else publish_and_exit SUCCESS 0
fi
