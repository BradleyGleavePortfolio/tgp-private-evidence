#!/usr/bin/env bash
# S4 R6 validation V2 — exact bounded detached launcher / supervisor (VPA-03, VPA-01, VPA-04).
#
#   bash execution/s4-r6-validation/v2/launcher/s4-r6-launch-v2.sh
#
# What it does, in order:
#   1. Generates a fresh safe run id and creates the run directory ATOMICALLY
#      (`mkdir` without -p; an existing directory or sentinel is a refusal, never
#      reuse). Reserves the console log INSIDE that directory before launching.
#   2. Starts the frozen runner with `setsid` so the runner PID is the leader of a
#      brand-new session and process group: every job the runner (or Vitest, npm,
#      Chrome, node probes) spawns stays in that group even if its parent exits
#      (reparented orphans keep their PGID). That PGID is the stable owned
#      boundary; nothing outside it is ever signalled.
#   3. Supervises with a MANDATORY outer deadline: OUTER_S total, then TERM to the
#      whole owned group, GRACE_S, then KILL to the group, then verifies the group
#      is empty (`pgrep -g`). Writes SUPERVISOR_RECORD.json regardless of whether
#      the runner managed to write its own exit record.
#   4. Overall exit: 0 only if the runner exited 0 AND wrote a parseable
#      EXIT_RECORD.json with result SUCCESS AND its sentinel AND the owned group is
#      verifiably empty. Any timeout, interruption, survivor, missing/unparseable
#      record → nonzero and a non-success classification.
#
# Control mode (fake safety controls only, separate grant): S4R6_CONTROL=1 with
# S4R6_RUNNER=<stub path> substitutes the runner; the record is stamped
# kind="CONTROL" and can never be mistaken for a validation run.
set -u
ROOT=/home/user/workspace
VAL=$ROOT/execution/s4-r6-validation
V2=$VAL/v2
RUNNER_DEFAULT=$V2/runner/s4-r6-validate-v2.sh
KIND=VALIDATION
RUNNER=$RUNNER_DEFAULT
if [[ ${S4R6_CONTROL:-0} == 1 ]]; then KIND=CONTROL; RUNNER=${S4R6_RUNNER:?control runner path required}; fi
OUTER_S=${S4R6_OUTER_S:-3300}   # mandatory total bound (validation default 55 min)
GRACE_S=${S4R6_GRACE_S:-45}     # TERM→KILL grace for the owned group
RUNS=$VAL/runs; [[ $KIND == CONTROL ]] && RUNS=$V2/control-runs

now() { date -u +%FT%TZ; }
sha() { sha256sum "$1" 2>/dev/null | cut -d' ' -f1; }

# 1. fresh exclusive run directory + safe id ------------------------------------
mkdir -p "$RUNS" || exit 70
RUN_ID="${KIND}-V2-$(date -u +%Y%m%dT%H%M%SZ)-$$-$(head -c 4 /dev/urandom | od -An -tx1 | tr -d ' \n')"
OUT=$RUNS/$RUN_ID
if ! mkdir "$OUT" 2>/dev/null; then echo "REFUSE: run directory exists: $OUT" >&2; exit 71; fi
[[ -e $OUT/RUN_COMPLETE.sentinel || -e $OUT/EXIT_RECORD.json ]] && { echo "REFUSE: stale completion marker in fresh dir" >&2; exit 71; }
CONSOLE=$OUT/console.log; : > "$CONSOLE" || exit 70
printf '%s\n' "$RUN_ID" > "$OUT/LAUNCH_TOKEN"   # runner refuses to run without this exact token
SUP=$OUT/SUPERVISOR_RECORD.json
RUNNER_SHA=$(sha "$RUNNER")
[[ -n $RUNNER_SHA ]] || { echo "REFUSE: runner missing $RUNNER" >&2; exit 72; }
echo "[$(now)] launch kind=$KIND run=$RUN_ID runner=$RUNNER sha256=$RUNNER_SHA outer=${OUTER_S}s grace=${GRACE_S}s" | tee -a "$CONSOLE"

# 2. detached session/group -------------------------------------------------------
LAUNCH_START=$(now); T0=$(date +%s)
S4R6_RUN_ID=$RUN_ID S4R6_OUT=$OUT S4R6_LAUNCH_TOKEN=$RUN_ID S4R6_KIND=$KIND \
  setsid bash "$RUNNER" >>"$CONSOLE" 2>&1 < /dev/null &
RPID=$!
# setsid forks only if the caller is already a group leader; resolve the actual
# session leader = the process whose SID equals its own PID among our children.
sleep 0.2
PGID=$(ps -o pgid= -p "$RPID" 2>/dev/null | tr -d ' ')
SID=$(ps -o sid= -p "$RPID" 2>/dev/null | tr -d ' ')
if [[ -z $PGID || $PGID == "$(ps -o pgid= -p $$ | tr -d ' ')" ]]; then
  # setsid re-forked: the leader is the child of RPID (or RPID already exited)
  CH=$(pgrep -P "$RPID" | head -1); [[ -n $CH ]] && { PGID=$(ps -o pgid= -p "$CH" | tr -d ' '); SID=$(ps -o sid= -p "$CH" | tr -d ' '); }
fi
echo "$PGID" > "$OUT/OWNED_PGID"
echo "[$(now)] owned session/group pgid=$PGID sid=$SID (runner wrapper pid $RPID)" | tee -a "$CONSOLE"
[[ -n $PGID && $PGID != "$(ps -o pgid= -p $$ | tr -d ' ')" ]] || { echo "REFUSE: could not establish a distinct owned process group" | tee -a "$CONSOLE"; kill -TERM "$RPID" 2>/dev/null; exit 73; }

# 3. supervision with mandatory deadline ------------------------------------------
INTERRUPT=""; trap 'INTERRUPT=TERM' TERM; trap 'INTERRUPT=INT' INT
TIMED_OUT=false
while kill -0 "$RPID" 2>/dev/null; do
  if [[ -n $INTERRUPT ]]; then echo "[$(now)] supervisor received $INTERRUPT" | tee -a "$CONSOLE"; break; fi
  if (( $(date +%s) - T0 >= OUTER_S )); then TIMED_OUT=true; echo "[$(now)] OUTER DEADLINE ${OUTER_S}s reached" | tee -a "$CONSOLE"; break; fi
  sleep 1
done
group_members() { pgrep -g "$PGID" 2>/dev/null | tr '\n' ' '; }
SIGNALLED=none
if [[ $TIMED_OUT == true || -n $INTERRUPT ]]; then
  echo "[$(now)] TERM owned group -$PGID members: $(group_members)" | tee -a "$CONSOLE"
  kill -TERM -- "-$PGID" 2>/dev/null; SIGNALLED=TERM
  for ((i=0;i<GRACE_S;i++)); do [[ -z $(group_members) ]] && break; sleep 1; done
  if [[ -n $(group_members) ]]; then
    echo "[$(now)] KILL owned group -$PGID survivors: $(group_members)" | tee -a "$CONSOLE"
    kill -KILL -- "-$PGID" 2>/dev/null; SIGNALLED=TERM+KILL; sleep 2
  fi
fi
wait "$RPID" 2>/dev/null; RUNNER_RC=$?
# Final ownership census: after a normal runner exit the group must ALREADY be
# empty (the runner reaps its own jobs); anything left is an owned orphan the
# runner failed to reap → reap it here, verify, and classify non-success.
ORPHANS=$(group_members)
REAPED_HERE=""
if [[ -n $ORPHANS ]]; then
  echo "[$(now)] owned orphans after runner exit: $ORPHANS — TERM/KILL" | tee -a "$CONSOLE"
  for p in $ORPHANS; do tr '\0' ' ' < /proc/$p/cmdline 2>/dev/null | cut -c1-160; echo; done >> "$OUT/orphans.log"
  kill -TERM -- "-$PGID" 2>/dev/null; sleep 5; [[ -n $(group_members) ]] && kill -KILL -- "-$PGID" 2>/dev/null; sleep 2
  REAPED_HERE=$ORPHANS
fi
SURVIVORS=$(group_members)
LAUNCH_END=$(now)

# 4. classification + durable supervisor record -------------------------------------
RESULT_RUNNER=$(python3 -c 'import json,sys
try:
  d=json.load(open(sys.argv[1])); print(d.get("result","UNPARSEABLE"))
except Exception as e: print("MISSING_OR_UNPARSEABLE")' "$OUT/EXIT_RECORD.json")
SENTINEL=$([[ -f $OUT/RUN_COMPLETE.sentinel ]] && echo yes || echo no)
if [[ $TIMED_OUT == true ]]; then OVERALL=TIMEOUT
elif [[ -n $INTERRUPT ]]; then OVERALL=INTERRUPTED
elif [[ -n $SURVIVORS ]]; then OVERALL=QUARANTINED_SURVIVORS
elif [[ -n $REAPED_HERE ]]; then OVERALL=FAILED_RUNNER_LEFT_ORPHANS
elif [[ $RUNNER_RC != 0 ]]; then OVERALL=RUNNER_NONZERO
elif [[ $RESULT_RUNNER != SUCCESS || $SENTINEL != yes ]]; then OVERALL=FAILED_PUBLICATION
else OVERALL=SUCCESS; fi
python3 - "$SUP" <<PY
import json
json.dump({"kind":"$KIND","run_id":"$RUN_ID","overall":"$OVERALL",
 "overall_semantics":"SUCCESS only if runner exit 0, runner EXIT_RECORD.result==SUCCESS, sentinel present, owned group empty without supervisor reaping; everything else is non-success",
 "runner":{"path":"$RUNNER","sha256":"$RUNNER_SHA","wrapper_pid":$RPID,"exit":$RUNNER_RC,"exit_record_result":"$RESULT_RUNNER","sentinel":"$SENTINEL"},
 "owned_group":{"pgid":"$PGID","sid":"$SID","signal_route":"kill -- -PGID (whole owned group only)","signalled":"$SIGNALLED","orphans_after_runner_exit":"$ORPHANS","reaped_by_supervisor":"$REAPED_HERE","survivors_after_kill":"$SURVIVORS"},
 "bounds":{"outer_s":$OUTER_S,"grace_s":$GRACE_S,"timed_out":$TIMED_OUT,"interrupt":"$INTERRUPT"},
 "start_utc":"$LAUNCH_START","end_utc":"$LAUNCH_END","out_dir":"$OUT","console":"$CONSOLE"},open("$SUP","w"),indent=2)
PY
PUB_RC=$?
python3 -c 'import json,sys;json.load(open(sys.argv[1]))' "$SUP" 2>/dev/null || { OVERALL=FAILED_PUBLICATION; PUB_RC=1; }
echo "[$(now)] OVERALL=$OVERALL runner_exit=$RUNNER_RC runner_result=$RESULT_RUNNER survivors='${SURVIVORS}' record=$SUP" | tee -a "$CONSOLE"
case $OVERALL in SUCCESS) exit 0;; TIMEOUT) exit 124;; INTERRUPTED) exit 143;; QUARANTINED_SURVIVORS) exit 5;; FAILED_RUNNER_LEFT_ORPHANS) exit 6;; FAILED_PUBLICATION) exit 7;; *) exit $(( RUNNER_RC == 0 ? 1 : RUNNER_RC ));; esac
