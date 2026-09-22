#!/usr/bin/env bash
# S4 R6 validation V3 — exact bounded detached launcher / supervisor.
#
#   bash execution/s4-r6-validation/v3/launcher/s4-r6-launch-v3.sh              (kind=VALIDATION)
#   S4R6_CONTROL=1 S4R6_SCENARIO=<name> bash .../s4-r6-launch-v3.sh              (kind=CONTROL, stub runner)
#
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
V3=$VAL/v3
KIND=VALIDATION; RUNNER=$V3/runner/s4-r6-validate-v3.sh; RUNS=$VAL/runs
if [[ ${S4R6_CONTROL:-0} == 1 ]]; then KIND=CONTROL; RUNNER=$V3/controls/s4-r6-control-stub-v3.sh; RUNS=$V3/control-runs; : "${S4R6_SCENARIO:?control scenario required}"; fi
OUTER_S=${S4R6_OUTER_S:-3300}   # mandatory total bound for the runner (validation default 55 min)
GRACE_S=${S4R6_GRACE_S:-45}     # TERM→KILL grace for the owned session
CONFIRM_S=10                    # bounded wait for runner exit after KILL before QUARANTINED
now() { date -u +%FT%TZ; }
sha() { sha256sum "$1" 2>/dev/null | cut -d' ' -f1; }
T0=$(date +%s); LAUNCH_START=$(now)

# ---- state for the record (defaults so every exit path can publish) ----------------------------
RUN_ID=""; OUT=""; CONSOLE=/dev/null; SUP=""; RPID=""; SID=""; RUNNER_SHA=""; RUNNER_PID_FILE=""
RUNNER_RC=""; RUNNER_EXIT_CONFIRMED=false; TIMED_OUT=false; INTERRUPT=""; SIGNALLED=none
MEMBERS_AT_DEADLINE=""; ORPHANS=""; REAPED_HERE=""; SURVIVORS=""; REFUSAL=""

session_members() { [[ -n $SID ]] && pgrep -s "$SID" 2>/dev/null | tr '\n' ' '; }
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
    runner_result=$(python3 -c 'import json,sys
try: print(json.load(open(sys.argv[1])).get("result","UNPARSEABLE"))
except Exception: print("MISSING_OR_UNPARSEABLE")' "$OUT/EXIT_RECORD.json" 2>/dev/null)
    [[ -f $RUNNER_PID_FILE ]] && runner_pid_seen=$(tr -d ' \n' < "$RUNNER_PID_FILE")
  fi
  local publication_ok=false
  if [[ -n $SUP ]]; then
    python3 - "$SUP.tmp" "$KIND" "${S4R6_SCENARIO:-}" "$RUN_ID" "$overall" "$code" "$RUNNER" "$RUNNER_SHA" "$RPID" "$RUNNER_RC" "$RUNNER_EXIT_CONFIRMED" "$runner_result" "$sentinel" "$record_present" "$SID" "$runner_pid_seen" "$SIGNALLED" "$MEMBERS_AT_DEADLINE" "$ORPHANS" "$REAPED_HERE" "$SURVIVORS" "$OUTER_S" "$GRACE_S" "$CONFIRM_S" "$TIMED_OUT" "$INTERRUPT" "$REFUSAL" "$LAUNCH_START" "$end" "$OUT" "$CONSOLE" <<'PY'
import json,sys
a=sys.argv[1:]
(out,kind,scenario,run_id,overall,code,runner,runner_sha,rpid,runner_rc,exit_confirmed,runner_result,sentinel,record_present,sid,runner_pid_seen,signalled,members_at_deadline,orphans,reaped_here,survivors,outer_s,grace_s,confirm_s,timed_out,interrupt,refusal,start,end,outdir,console)=a
def num(x):
    try: return int(x)
    except Exception: return None
b=lambda x: x=="true"
json.dump({"kind":kind,"scenario":scenario or None,"run_id":run_id or None,"overall":overall,"launcher_exit":num(code),
 "overall_semantics":"SUCCESS only if runner exit 0 confirmed, runner EXIT_RECORD.result==SUCCESS, sentinel present, RUNNER_PID handshake matches, owned session empty without supervisor reaping; everything else is non-success. publication_ok is recorded separately by the caller after this file is parsed.",
 "runner":{"path":runner,"sha256":runner_sha or None,"spawned_pid":num(rpid),"exit":num(runner_rc),"exit_confirmed":b(exit_confirmed),"exit_record_result":runner_result,"exit_record_present":b(record_present),"sentinel":sentinel=="yes","runner_pid_handshake":num(runner_pid_seen),"handshake_ok":(num(runner_pid_seen)==num(rpid)) if runner_pid_seen else None},
 "owned_session":{"sid":num(sid),"signal_route":"kill -SIG -- -pgid for every foreign pgid in session, then kill -SIG pid for every member; never outside the session","signalled":signalled,"members_at_deadline":members_at_deadline.split(),"orphans_after_runner_exit":orphans.split(),"reaped_by_supervisor":reaped_here.split(),"survivors_after_kill":survivors.split()},
 "bounds":{"outer_s":num(outer_s),"grace_s":num(grace_s),"confirm_s":num(confirm_s),"timed_out":b(timed_out),"interrupt":interrupt or None,"worst_case_s":num(outer_s)+num(grace_s)+num(confirm_s)+7},
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
RUN_ID="${KIND}-V3-$(date -u +%Y%m%dT%H%M%SZ)-$$-$(head -c 4 /dev/urandom | od -An -tx1 | tr -d ' \n')"
OUT=$RUNS/$RUN_ID
if ! mkdir "$OUT" 2>/dev/null; then echo "REFUSE: run directory exists: $OUT" >&2; exit 71; fi
CONSOLE=$OUT/console.log; : > "$CONSOLE" || exit 70
SUP=$OUT/SUPERVISOR_RECORD.json; RUNNER_PID_FILE=$OUT/RUNNER_PID
printf '%s\n' "$RUN_ID" > "$OUT/LAUNCH_TOKEN"
RUNNER_SHA=$(sha "$RUNNER")
[[ -n $RUNNER_SHA ]] || { REFUSAL="runner missing: $RUNNER"; log "REFUSE: $REFUSAL"; publish_and_exit REFUSED 72; }
log "launch kind=$KIND scenario=${S4R6_SCENARIO:-} run=$RUN_ID runner=$RUNNER sha256=$RUNNER_SHA outer=${OUTER_S}s grace=${GRACE_S}s confirm=${CONFIRM_S}s"

# ---- 2. detached session; ownership by construction ----------------------------------------------------
INTERRUPT=""; trap 'INTERRUPT=TERM' TERM; trap 'INTERRUPT=INT' INT
S4R6_RUN_ID=$RUN_ID S4R6_OUT=$OUT S4R6_LAUNCH_TOKEN=$RUN_ID S4R6_KIND=$KIND S4R6_SCENARIO=${S4R6_SCENARIO:-} \
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
  for ((i=0;i<GRACE_S;i++)); do [[ -z $(session_members) ]] && break; sleep 1; done
  if [[ -n $(session_members) ]]; then log "KILL owned session survivors: $(session_members)"; signal_session KILL; SIGNALLED=TERM+KILL; fi
fi
# bounded confirmation of the runner's exit (never an unconditional wait)
for ((i=0;i<CONFIRM_S;i++)); do kill -0 "$RPID" 2>/dev/null || break; sleep 1; done
if kill -0 "$RPID" 2>/dev/null; then
  RUNNER_EXIT_CONFIRMED=false; SURVIVORS=$(session_members)
  publish_and_exit QUARANTINED_SURVIVORS 5
fi
wait "$RPID" 2>/dev/null; RUNNER_RC=$?; RUNNER_EXIT_CONFIRMED=true

# ---- 4. census + reap on every path (refusals included) --------------------------------------------------------
ORPHANS=$(session_members)
if [[ -n $ORPHANS ]]; then
  log "owned orphans after runner exit: $ORPHANS — TERM/KILL"
  for p in $ORPHANS; do printf '%s :: ' "$p"; tr '\0' ' ' < /proc/$p/cmdline 2>/dev/null | cut -c1-160; echo; done >> "$OUT/orphans.log"
  signal_session TERM; for ((i=0;i<5;i++)); do [[ -z $(session_members) ]] && break; sleep 1; done
  if [[ -n $(session_members) ]]; then signal_session KILL; for ((i=0;i<3;i++)); do [[ -z $(session_members) ]] && break; sleep 1; done; fi
  REAPED_HERE=$ORPHANS
fi
SURVIVORS=$(session_members)

# ---- 5. classification ---------------------------------------------------------------------------------------------
HANDSHAKE=""; [[ -f $RUNNER_PID_FILE ]] && HANDSHAKE=$(tr -d ' \n' < "$RUNNER_PID_FILE")
RES=$(python3 -c 'import json,sys
try: print(json.load(open(sys.argv[1])).get("result","UNPARSEABLE"))
except Exception: print("MISSING_OR_UNPARSEABLE")' "$OUT/EXIT_RECORD.json" 2>/dev/null)
SENT=no; [[ -f $OUT/RUN_COMPLETE.sentinel ]] && SENT=yes
if   [[ $TIMED_OUT == true ]]; then publish_and_exit TIMEOUT 124
elif [[ -n $INTERRUPT ]]; then publish_and_exit INTERRUPTED 143
elif [[ -n $SURVIVORS ]]; then publish_and_exit QUARANTINED_SURVIVORS 5
elif [[ -n $REAPED_HERE ]]; then publish_and_exit FAILED_RUNNER_LEFT_ORPHANS 6
elif [[ $RUNNER_RC == 71 || $RUNNER_RC == 73 || $RUNNER_RC == 75 ]]; then REFUSAL="runner refused with exit $RUNNER_RC (see console.log)"; publish_and_exit RUNNER_REFUSED "$RUNNER_RC"
elif [[ $RUNNER_RC != 0 ]]; then publish_and_exit RUNNER_NONZERO "$RUNNER_RC"
elif [[ -n $HANDSHAKE && $HANDSHAKE != "$RPID" ]]; then publish_and_exit FAILED_OWNERSHIP_HANDSHAKE 9
elif [[ -z $HANDSHAKE ]]; then publish_and_exit FAILED_OWNERSHIP_HANDSHAKE 9
elif [[ $RES != SUCCESS || $SENT != yes ]]; then publish_and_exit FAILED_PUBLICATION 7
else publish_and_exit SUCCESS 0
fi
