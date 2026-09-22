#!/usr/bin/env bash
# S4 R6 validation V5 — exact bounded detached launcher / supervisor / lease holder.
#
#   bash execution/s4-r6-validation/v5/launcher/s4-r6-launch-v5.sh              (kind=VALIDATION)
#   S4R6_CONTROL=1 S4R6_SCENARIO=<name> bash .../s4-r6-launch-v5.sh              (kind=CONTROL, stub runner)
#
# V5 changes versus V4 (frozen reviews S4-V4-A-02/03/04, S4-V4-B-01/05):
#  * Cleanup state before outcome precedence (A-03/B-01): SURVIVORS is resolved FIRST on every post-exit
#    path; TIMEOUT/INTERRUPTED never bypass lease retention. The cause stays in bounds.timed_out/interrupt.
#  * Checked quarantine handoff (A-04/B-05): the holder is verified alive with fd 9 -> lease path and a
#    token in its cmdline, identified by pid+starttime+token, and durably recorded BEFORE this process exits.
#    Verification or record failure => QUARANTINE_HOLDER_FAILED (10), the just-spawned holder is terminated
#    (identity-checked), and the unsafe release is recorded. No unrecorded infinite holder, no bare-PID recovery.
#  * Enforced elapsed phases (A-02): grace/confirm/post-exit waits are wall-clock deadlines, both record
#    readers run under `timeout --foreground READ_S`, and bounds.worst_case_s/formula include every phase.
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
V5=$VAL/v5
KIND=VALIDATION; RUNNER=$V5/runner/s4-r6-validate-v5.sh; RUNS=$VAL/runs
LEASE_PATH=$ROOT/execution/test-validation.lock; LEASE_KIND=canonical-held-by-launcher
if [[ ${S4R6_CONTROL:-0} == 1 ]]; then KIND=CONTROL; RUNNER=$V5/controls/s4-r6-control-stub-v5.sh; RUNS=$V5/control-runs; : "${S4R6_SCENARIO:?control scenario required}"; LEASE_PATH=$V5/control-runs/.private-control-lease.lock; LEASE_KIND=private-held-by-launcher; fi
OUTER_S=${S4R6_OUTER_S:-3300}   # mandatory total bound for the runner (validation default 55 min)
GRACE_S=${S4R6_GRACE_S:-45}     # TERM→KILL grace for the owned session
CONFIRM_S=10                    # bounded wait for runner exit after KILL before QUARANTINED
POST_S=8                        # post-exit orphan reap loops (5 s TERM + 3 s KILL)
PUBLISH_S=5                     # record writer bound (timeout --foreground)
READ_S=5                        # each EXIT_RECORD reader bound (timeout --foreground); two readers per run
QH_VERIFY_S=5                   # quarantine holder verification bound
WORST_EXTRA_S=$((READ_S*2+QH_VERIFY_S+2))   # readers + holder verification + slack; formula below
now() { date -u +%FT%TZ; }
sha() { sha256sum "$1" 2>/dev/null | cut -d' ' -f1; }
T0=$(date +%s); LAUNCH_START=$(now)

# ---- state for the record (defaults so every exit path can publish) ----------------------------
RUN_ID=""; OUT=""; CONSOLE=/dev/null; SUP=""; RPID=""; SID=""; RUNNER_SHA=""; RUNNER_PID_FILE=""
RUNNER_RC=""; RUNNER_EXIT_CONFIRMED=false; TIMED_OUT=false; INTERRUPT=""; SIGNALLED=none
MEMBERS_AT_DEADLINE=""; ORPHANS=""; REAPED_HERE=""; SURVIVORS=""; REFUSAL=""
LEASE_HELD=false; LEASE_RELEASED_AT_EXIT=true; QUARANTINE_HOLDER=""; QUARANTINE_HOLDER_START=""; QUARANTINE_TOKEN=""; QUARANTINE_OK=""; QUARANTINE_FAILURE=""

session_members() { [[ -n $SID ]] && pgrep -s "$SID" 2>/dev/null | tr '\n' ' '; }
# wait_session_empty <seconds>: wall-clock bounded (A-02), returns 0 as soon as the owned session is empty.
wait_session_empty() { local until=$(( $(date +%s) + $1 )); while (( $(date +%s) < until )); do [[ -z $(session_members) ]] && return 0; sleep 1; done; [[ -z $(session_members) ]]; }
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
  for p in $(session_members); do g=$(ps -o pgid= -p "$p" 2>/dev/null | tr -d ' '); [[ -n $g ]] && kill "-$sig" -- "-$g" 2>/dev/null; done
  for p in $(session_members); do kill "-$sig" "$p" 2>/dev/null; done
  return 0
}
log() { echo "[$(now)] $*" | tee -a "$CONSOLE"; }

publish_and_exit() {
  local overall=$1 code=$2
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
    timeout --foreground "$PUBLISH_S" python3 - "$SUP.tmp" "$KIND" "${S4R6_SCENARIO:-}" "$RUN_ID" "$overall" "$code" "$RUNNER" "$RUNNER_SHA" "$RPID" "$RUNNER_RC" "$RUNNER_EXIT_CONFIRMED" "$runner_result" "$sentinel" "$record_present" "$SID" "$runner_pid_seen" "$SIGNALLED" "$MEMBERS_AT_DEADLINE" "$ORPHANS" "$REAPED_HERE" "$SURVIVORS" "$OUTER_S" "$GRACE_S" "$CONFIRM_S" "$TIMED_OUT" "$INTERRUPT" "$REFUSAL" "$LAUNCH_START" "$end" "$OUT" "$CONSOLE" "$POST_S" "$PUBLISH_S" "$LEASE_PATH" "$LEASE_KIND" "$LEASE_HELD" "$LEASE_RELEASED_AT_EXIT" "$QUARANTINE_HOLDER" "$$" "$READ_S" "$QH_VERIFY_S" "$WORST_EXTRA_S" "$QUARANTINE_HOLDER_START" "$QUARANTINE_TOKEN" "$QUARANTINE_OK" "$QUARANTINE_FAILURE" "$(proc_start $$)" <<'PY'
import json,sys
a=sys.argv[1:]
(out,kind,scenario,run_id,overall,code,runner,runner_sha,rpid,runner_rc,exit_confirmed,runner_result,sentinel,record_present,sid,runner_pid_seen,signalled,members_at_deadline,orphans,reaped_here,survivors,outer_s,grace_s,confirm_s,timed_out,interrupt,refusal,start,end,outdir,console,post_s,publish_s,lease_path,lease_kind,lease_held,lease_released,quarantine_holder,launcher_pid,read_s,qh_verify_s,worst_extra_s,qh_start,qh_token,qh_ok,qh_failure,launcher_start)=a
def num(x):
    try: return int(x)
    except Exception: return None
b=lambda x: x=="true"
json.dump({"kind":kind,"scenario":scenario or None,"run_id":run_id or None,"overall":overall,"launcher_exit":num(code),
 "overall_semantics":"SUCCESS only if runner exit 0 confirmed, runner EXIT_RECORD.result==SUCCESS, sentinel present, RUNNER_PID handshake matches, owned session empty without supervisor reaping; everything else is non-success. publication_ok is recorded separately by the caller after this file is parsed.",
 "runner":{"path":runner,"sha256":runner_sha or None,"spawned_pid":num(rpid),"exit":num(runner_rc),"exit_confirmed":b(exit_confirmed),"exit_record_result":runner_result,"exit_record_present":b(record_present),"sentinel":sentinel=="yes","runner_pid_handshake":num(runner_pid_seen),"handshake_ok":(num(runner_pid_seen)==num(rpid)) if runner_pid_seen else None},
 "owned_session":{"sid":num(sid),"signal_route":"kill -SIG -- -pgid for every foreign pgid in session, then kill -SIG pid for every member; never outside the session","signalled":signalled,"members_at_deadline":members_at_deadline.split(),"orphans_after_runner_exit":orphans.split(),"reaped_by_supervisor":reaped_here.split(),"survivors_after_kill":survivors.split()},
 "bounds":{"outer_s":num(outer_s),"grace_s":num(grace_s),"confirm_s":num(confirm_s),"post_exit_reap_s":num(post_s),"publish_s":num(publish_s),"read_s":num(read_s),"quarantine_verify_s":num(qh_verify_s),"timed_out":b(timed_out),"interrupt":interrupt or None,"worst_case_s":num(outer_s)+num(grace_s)+num(confirm_s)+num(post_s)+num(publish_s)+num(worst_extra_s),"worst_case_formula":"outer+grace+confirm+post_exit_reap+publish+2*read+quarantine_verify+2","phases_are_wall_clock":True},
 "lease":{"path":lease_path,"kind":lease_kind,"holder_pid":num(launcher_pid),"holder_starttime":num(launcher_start),"held_by_launcher":b(lease_held),"released_at_launcher_exit":b(lease_released),"quarantine_holder_pid":num(quarantine_holder),"quarantine_holder_starttime":num(qh_start),"quarantine_holder_token":qh_token or None,"quarantine_ok":(qh_ok=="true") if qh_ok else None,"quarantine_failure":qh_failure or None,"semantics":"held from before spawn until verified cleanup; unverified survivors on ANY path => checked quarantine holder keeps it (QUARANTINED_SURVIVORS 5, unsafe handoff, never permission for another lane); if the holder cannot be verified/recorded => QUARANTINE_HOLDER_FAILED 10 and released_at_launcher_exit=true is an UNSAFE RELEASE, recorded, never SUCCESS. Recovery must verify pid+starttime+token+fd9 before any kill."},
 "refusal":refusal or None,"start_utc":start,"end_utc":end,"out_dir":outdir or None,"console":console},open(out,"w"),indent=2)
PY
    if [[ $? == 0 ]] && python3 -c 'import json,sys;json.load(open(sys.argv[1]))' "$SUP.tmp" 2>/dev/null && mv "$SUP.tmp" "$SUP"; then publication_ok=true; fi
  fi
  log "OVERALL=$overall launcher_exit=$code publication_ok=$publication_ok runner_exit=${RUNNER_RC:-none} runner_result=$runner_result survivors='${SURVIVORS}' record=${SUP:-none}"
  if [[ $publication_ok != true && $overall == SUCCESS ]]; then log "publication failed on a SUCCESS path — downgrading to FAILED_PUBLICATION"; code=7; fi
  exit "$code"
}

# ---- 0. topology precondition (no sleep, no race): we must NOT be a group leader ------------------
if [[ $(ps -o pgid= -p $$ | tr -d ' ') == "$$" ]]; then
  echo "REFUSE: launcher is a process-group leader; setsid would fork and the spawned pid would not be the session leader. Start it as a plain child (e.g. 'bash launcher.sh' from a script or non-job-control shell)." >&2; exit 73
fi

# ---- 1. fresh exclusive run directory + safe id ------------------------------------------------------
mkdir -p "$RUNS" || exit 70
RUN_ID="${KIND}-V5-$(date -u +%Y%m%dT%H%M%SZ)-$$-$(head -c 4 /dev/urandom | od -An -tx1 | tr -d ' \n')"
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
  MEMBERS_AT_DEADLINE=$(session_members)
  log "TERM owned session $SID members: $MEMBERS_AT_DEADLINE"
  signal_session TERM; SIGNALLED=TERM
  wait_session_empty "$GRACE_S" || { log "KILL owned session survivors: $(session_members)"; signal_session KILL; SIGNALLED=TERM+KILL; }
fi
# bounded confirmation of the runner's exit (never an unconditional wait); wall-clock (A-02)
wait_pid_gone "$RPID" "$CONFIRM_S" || :
hold_quarantine_lease() {
  # Unverified survivors: keep the lease beyond our own exit as a CHECKED owned-resource handoff (S4-V4-A-04).
  # The holder inherits fd 9 (same open file description => the flock persists while it lives). It is
  # verified alive with fd 9 -> lease path and our token in its cmdline, identified by pid+starttime+token
  # and recorded durably BEFORE we exit. Returns 0 only on verified+recorded handoff; otherwise the holder
  # we spawned is terminated (identity-checked) and the caller publishes QUARANTINE_HOLDER_FAILED.
  # Parent recovery: verify pid+starttime+token+fd9 against QUARANTINE_LEASE_HOLDER, then kill. Never a bare pid.
  QUARANTINE_TOKEN="s4r6-quarantine-holder-$RUN_ID"
  # holder = one bash keeping fd 9; its sleep children close fd 9 (9>&-) so ONLY the recorded pid holds the lease
  setsid bash -c 'while :; do sleep 60 9>&-; done' "$QUARANTINE_TOKEN" < /dev/null > /dev/null 2>&1 &
  QUARANTINE_HOLDER=$!
  local until=$(( $(date +%s) + QH_VERIFY_S )) verified=false
  while (( $(date +%s) < until )); do
    if kill -0 "$QUARANTINE_HOLDER" 2>/dev/null && [[ $(readlink "/proc/$QUARANTINE_HOLDER/fd/9" 2>/dev/null) == "$LEASE_PATH" ]] && tr '\0' ' ' < "/proc/$QUARANTINE_HOLDER/cmdline" 2>/dev/null | grep -q -- "$QUARANTINE_TOKEN"; then verified=true; break; fi
    sleep 1
  done
  QUARANTINE_HOLDER_START=$(proc_start "$QUARANTINE_HOLDER")
  if [[ $verified == true && -n $QUARANTINE_HOLDER_START ]]; then
    if printf 'pid=%s starttime=%s token=%s lease=%s lease_kind=%s run=%s owned_sid=%s survivors=%s launcher_pid=%s recorded=%s\nRECOVERY: kill ONLY if /proc/<pid>/stat starttime == %s AND /proc/<pid>/cmdline contains %s AND readlink /proc/<pid>/fd/9 == %s, after the listed survivors are verified gone. Never signal a bare pid.\n' \
         "$QUARANTINE_HOLDER" "$QUARANTINE_HOLDER_START" "$QUARANTINE_TOKEN" "$LEASE_PATH" "$LEASE_KIND" "$RUN_ID" "$SID" "$SURVIVORS" "$$" "$(now)" "$QUARANTINE_HOLDER_START" "$QUARANTINE_TOKEN" "$LEASE_PATH" > "$OUT/QUARANTINE_LEASE_HOLDER.tmp" \
       && mv "$OUT/QUARANTINE_LEASE_HOLDER.tmp" "$OUT/QUARANTINE_LEASE_HOLDER" && [[ -s $OUT/QUARANTINE_LEASE_HOLDER ]]; then
      QUARANTINE_OK=true; LEASE_RELEASED_AT_EXIT=false
      log "UNSAFE HANDOFF: survivors '$SURVIVORS' — lease $LEASE_PATH retained by VERIFIED quarantine holder pid=$QUARANTINE_HOLDER starttime=$QUARANTINE_HOLDER_START token=$QUARANTINE_TOKEN (recorded in QUARANTINE_LEASE_HOLDER)"
      return 0
    fi
    QUARANTINE_FAILURE="holder verified but QUARANTINE_LEASE_HOLDER record could not be written"
  else
    QUARANTINE_FAILURE="holder pid $QUARANTINE_HOLDER not verified alive with fd 9 -> $LEASE_PATH and token within ${QH_VERIFY_S}s"
  fi
  # failure: never leave an unrecorded infinite holder — terminate what we just spawned, identity-checked by token
  if kill -0 "$QUARANTINE_HOLDER" 2>/dev/null && tr '\0' ' ' < "/proc/$QUARANTINE_HOLDER/cmdline" 2>/dev/null | grep -q -- "$QUARANTINE_TOKEN"; then kill -KILL "$QUARANTINE_HOLDER" 2>/dev/null; fi
  QUARANTINE_OK=false; LEASE_RELEASED_AT_EXIT=true
  log "QUARANTINE HOLDER FAILED: $QUARANTINE_FAILURE — lease $LEASE_PATH WILL be released at exit while survivors '$SURVIVORS' are unverified (UNSAFE RELEASE, recorded; never SUCCESS)"
  return 1
}
# quarantine_exit: cleanup/lease state is secured BEFORE any outcome precedence (S4-V4-A-03 / B-01)
quarantine_exit() { if hold_quarantine_lease; then publish_and_exit QUARANTINED_SURVIVORS 5; else publish_and_exit QUARANTINE_HOLDER_FAILED 10; fi; }
if kill -0 "$RPID" 2>/dev/null; then
  RUNNER_EXIT_CONFIRMED=false; SURVIVORS=$(session_members)
  quarantine_exit
fi
wait "$RPID" 2>/dev/null; RUNNER_RC=$?; RUNNER_EXIT_CONFIRMED=true

# ---- 4. census + reap on every path (refusals included) --------------------------------------------------------
ORPHANS=$(session_members)
if [[ -n $ORPHANS ]]; then
  log "owned orphans after runner exit: $ORPHANS — TERM/KILL"
  for p in $ORPHANS; do printf '%s :: ' "$p"; tr '\0' ' ' < /proc/$p/cmdline 2>/dev/null | cut -c1-160; echo; done >> "$OUT/orphans.log"
  signal_session TERM; wait_session_empty 5 || { signal_session KILL; wait_session_empty 3 || :; }   # POST_S = 5 + 3, wall-clock
  REAPED_HERE=$ORPHANS
fi
SURVIVORS=$(session_members)

# ---- 5. cleanup/lease state FIRST, then classification (S4-V4-A-03 / B-01) ------------------------------------
# Unverified survivors take precedence over TIMEOUT/INTERRUPTED: the lease is never released with owned work
# unaccounted for. The cause remains recorded (bounds.timed_out, bounds.interrupt, owned_session.signalled).
if [[ -n $SURVIVORS ]]; then quarantine_exit; fi
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
