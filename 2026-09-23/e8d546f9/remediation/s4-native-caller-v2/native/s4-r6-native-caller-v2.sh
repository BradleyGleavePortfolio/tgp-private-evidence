#!/usr/bin/env bash
# S4 R6 — NATIVE bounded-observer caller V2 (V1 + S4-NATIVE-V1-A01 receipt-write propagation; additive successor to the SLOT_REQUEST_V6/V61 §5 `bash -c` caller).
# Sole purpose (S4_V6_RECOVERY_RULING §Decision; SLOT_REQUEST_V61 §5.1): keep THREE facts separate that the plain
# `bash -c` caller collapses into one hang when the launcher SELF-HOLDs (retains fd 9 and never exits):
#   (1) ACTUAL launcher exit      -> this caller prints `launcher exit=N` and exits N (raw, unchanged; 12 is never faked);
#   (2) BOUNDED observer return   -> the launcher is still alive at the observer bound: exactly ONE TERM (the accepted
#                                    driver cancel route), wait its own teardown allowance, then RETURN 97 — never KILL,
#                                    never a second allowance, never an unbounded wait;
#   (3) IDENTITY-BOUND retained owner -> whatever is still alive/holding is RECORDED (pid, starttime, cmdline token,
#                                    fd 9 -> lease, console SELF-HOLD line, record lease.*) in a receipt with the §6
#                                    recovery rule; nothing is signalled beyond the one TERM, nothing is cleaned up.
# The launcher/runner/lib/controls/product are NOT changed: this file only replaces the caller line. Every reused
# function is copied from the accepted V6.1 driver (controls/run-controls-v6.sh) with only path/constant renames,
# marked `[driver Lnn]`. No fault seams, no controls, no lock probe (a `flock -n` probe would touch the canonical
# lock), no reaping of anybody's session, no recovery.
# Invocation (non-job-control; exact bytes below are the only "caller" a native grant needs to quote):
#   bash /home/user/workspace/execution/s4-r6-validation/native-caller-v2/s4-r6-native-caller-v2.sh   (restored OUTSIDE the frozen v6 dir)
# Exit map of THIS process (observer):  N = launcher's actual exit (any N incl. 0/5/6/7/8/9/11/12/70-75/124/143)
#   97 launcher alive at the observer bound after one TERM + teardown allowance (retained/unresolved; receipt written)
#   91 packet manifest verification failed (nothing spawned)   70 packet dir / receipt dir unusable (nothing spawned)
#   94 launcher ACTUALLY exited 0 but a current fact contradicts it (no run dir / no OWNED_SID / census not EMPTY /
#      live identity-checked holder) — the stdout line still shows the actual 0; the observer refuses to call it success
#   90 receipt could not be written on a confirmed observer-0 path (downgrade; the 0 is still in the stdout line)
set -u
set +m                                   # never job control: the launcher must not become a process-group leader (73)
ROOT=/home/user/workspace
VAL=$ROOT/execution/s4-r6-validation
V6=$VAL/v6
LAUNCHER=$V6/launcher/s4-r6-launch-v6.sh
RUNS=$VAL/runs                           # the launcher's own run directories (VALIDATION-V6-<utc>-<launcher pid>-<rand>)
LEASE_PATH=$ROOT/execution/test-validation.lock   # canonical lease: READ ONLY here (readlink of fd 9), never opened/flocked
RECEIPTS=${S4R6_CALLER_RECEIPTS:-$VAL/caller-receipts}
# Bound arithmetic = the launcher's own advertised worst case (SLOT_REQUEST §5): OUTER + GRACE + confirm 10 + post 8 +
# publish 5 + 2*read 5 + 2*qverify 5 + 16*census 2 + 2  = 3300 + 45 + 77 = 3422 s with the defaults. The observer
# waits at most that, then cancels ONCE and waits GRACE + LAUNCHER_POST_S + CANCEL_SLACK_S (= 127 s with defaults),
# so this process returns within OBSERVE_S + 127 s + census/receipt (~10 s) regardless of what the launcher does.
OUTER_S=${S4R6_OUTER_S:-3300}; GRACE_S=${S4R6_GRACE_S:-45}       # same env names the launcher reads; passed through untouched
LAUNCHER_POST_S=77; CANCEL_SLACK_S=5; SCAN_S=5                   # [driver L64]
OBSERVE_S=$(( OUTER_S + GRACE_S + LAUNCHER_POST_S ))

cd "$V6" || exit 70
if ! ( timeout --foreground 20 sha256sum -c --quiet SHA256SUMS ) >/dev/null 2>&1; then echo "STOP: V6 manifest verification failed at $V6 (nothing executed)" >&2; exit 91; fi   # [driver L77]
mkdir -p "$RECEIPTS" || exit 70
now() { date -u +%FT%TZ; }                                                              # [driver L68]
proc_start() { sed 's/^.*) //' "/proc/$1/stat" 2>/dev/null | awk '{print $20}'; }        # [driver L72]
RECEIPT=$RECEIPTS/NATIVE-CALLER-$(date -u +%Y%m%dT%H%M%SZ)-$$.txt
NOTES=()
note() { NOTES+=("[$(now)] $*"); echo "[$(now)] caller: $*" >&2; }

ACTIVE_PID=""; ACTIVE_START=""; ACTIVE_RUN_DIR=""; RUN_IDENTITY=NONE
CANCELLED=""; CANCEL_SENT=""; CANCEL_DEADLINE=""; UNRESOLVED=""; INTERRUPT=""
resolve_active_run() {                                                                   # [driver L83-90; glob VALIDATION-V6-*-<pid>-*]
  [[ -n $ACTIVE_PID ]] || return 0
  if [[ -z $ACTIVE_RUN_DIR ]]; then
    local d; d=$(ls -1d "$RUNS"/VALIDATION-V6-*-"$ACTIVE_PID"-* 2>/dev/null | head -1)
    if [[ -n $d ]]; then ACTIVE_RUN_DIR=$d; RUN_IDENTITY=BOUND; else RUN_IDENTITY=UNKNOWN_NO_SPAWN; fi
  fi
  return 0
}
cancel_active() {                                                                        # [driver L91-115; receipt lines -> note()]
  local why=$1
  [[ -n $ACTIVE_PID ]] && kill -0 "$ACTIVE_PID" 2>/dev/null || return 0
  resolve_active_run
  if [[ -z $CANCEL_SENT ]]; then
    CANCEL_SENT=$(date +%s); CANCEL_DEADLINE=$(( CANCEL_SENT + GRACE_S + LAUNCHER_POST_S + CANCEL_SLACK_S )); CANCELLED=$why
    note "CANCEL active launcher pid=$ACTIVE_PID starttime=${ACTIVE_START:-unknown} run=${ACTIVE_RUN_DIR:-<none yet>} identity=$RUN_IDENTITY reason=$why deadline=+$((GRACE_S+LAUNCHER_POST_S+CANCEL_SLACK_S))s (one TERM, no second allowance)"
    kill -TERM "$ACTIVE_PID" 2>/dev/null
  else
    note "cancel_active re-entered (reason=$why): TERM already sent at $CANCEL_SENT; waiting only the remaining $(( CANCEL_DEADLINE - $(date +%s) ))s"
  fi
  while (( $(date +%s) < CANCEL_DEADLINE )); do kill -0 "$ACTIVE_PID" 2>/dev/null || return 0; resolve_active_run; sleep 1; done
  if kill -0 "$ACTIVE_PID" 2>/dev/null; then
    resolve_active_run
    local fd9 st; fd9=$(readlink "/proc/$ACTIVE_PID/fd/9" 2>/dev/null); st=$(proc_start "$ACTIVE_PID")
    local ident="starttime=${st:-unknown}"; [[ -n $ACTIVE_START && $st == "$ACTIVE_START" ]] || ident="$ident (spawn-time starttime '${ACTIVE_START:-unknown}' NOT confirmed — treat identity as uncertain)"
    UNRESOLVED="launcher pid=$ACTIVE_PID $ident still alive at its cancel deadline (TERM sent once at $CANCEL_SENT, +$((GRACE_S+LAUNCHER_POST_S+CANCEL_SLACK_S))s); NOT killed; fd9=${fd9:-<none>} lease_held_by_it=$([[ $fd9 == "$LEASE_PATH" ]] && echo true || echo false); run=${ACTIVE_RUN_DIR:-<none>} identity=$RUN_IDENTITY"
    note "UNRESOLVED: $UNRESOLVED"
  fi
}
census() {                                                                               # [driver L117-126, V6.1 A-01 form; read-only]
  local raw rc; C_MEMBERS=""; C_STATE=""
  raw=$(timeout --foreground "$SCAN_S" pgrep -s "$1" 2>/dev/null); rc=$?
  case $rc in
    0) if [[ -n $raw ]]; then C_STATE=MEMBERS; C_MEMBERS=${raw//$'\n'/ }; else C_STATE=UNKNOWN:0-empty; fi;;
    1) C_STATE=EMPTY;;
    *) C_STATE="UNKNOWN:$rc";;
  esac
  return 0
}
holder_identity() {                                                                      # [driver L129-137, V6.1 A-02 form]
  local d f; d=$1; f=$d/QUARANTINE_LEASE_HOLDER
  if [[ -s $f ]]; then sed -n '1s/^pid=\([0-9]*\) starttime=\([0-9]*\) token=\([^ ]*\) .*/\1 \2 \3/p' "$f"; return 0; fi
  [[ -f $d/SUPERVISOR_RECORD.json ]] || return 0
  timeout --foreground "$SCAN_S" python3 -c 'import json,sys
L=json.load(open(sys.argv[1])).get("lease",{})
p,s,t=L.get("quarantine_holder_pid"),L.get("quarantine_holder_starttime"),L.get("quarantine_holder_token")
if p and s and t: print(p,s,t)' "$d/SUPERVISOR_RECORD.json" 2>/dev/null
}
holder_alive() {                                                                         # [driver L139-143; lease = canonical path, read-only]
  local id pid st tok; id=$(holder_identity "$1"); [[ -n $id ]] || return 1
  read -r pid st tok <<< "$id"
  kill -0 "$pid" 2>/dev/null && [[ $(proc_start "$pid") == "$st" ]] && tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null | grep -q -- "$tok" && [[ $(readlink "/proc/$pid/fd/9" 2>/dev/null) == "$LEASE_PATH" ]]
}
trap 'INTERRUPT=TERM' TERM; trap 'INTERRUPT=INT' INT     # forwarded ONCE via cancel_active from the observer loop (launcher B-02 pattern)

# ---- spawn: plain background child of a non-job-control shell (launcher pgid == this shell's pgid != launcher pid) ----
T0=$(date +%s)
bash "$LAUNCHER" & ACTIVE_PID=$!; ACTIVE_START=$(proc_start "$ACTIVE_PID")            # [driver L211 shape; stdout/stderr inherited]
note "spawned launcher pid=$ACTIVE_PID starttime=${ACTIVE_START:-unknown} caller_pid=$$ caller_start=$(proc_start $$) pgid=$(ps -o pgid= -p $$ | tr -d ' ') observe_s=$OBSERVE_S (outer=$OUTER_S grace=$GRACE_S post=$LAUNCHER_POST_S) cancel_wait_s=$((GRACE_S+LAUNCHER_POST_S+CANCEL_SLACK_S)) lease=$LEASE_PATH (read-only)"

# ---- observe: wall-clock bound; ONE cancel on interrupt or at the bound; never KILL; never unbounded ----
while kill -0 "$ACTIVE_PID" 2>/dev/null; do
  resolve_active_run
  if [[ -n $INTERRUPT ]]; then cancel_active "caller-$INTERRUPT"; break; fi
  if (( $(date +%s) - T0 >= OBSERVE_S )); then cancel_active "observer bound ${OBSERVE_S}s reached"; break; fi
  sleep 1
done
resolve_active_run
LAUNCHER_RC=""
if [[ -z $UNRESOLVED ]]; then wait "$ACTIVE_PID" 2>/dev/null; LAUNCHER_RC=$?; fi          # [driver L221]: real reaped status only

# ---- identity facts for the receipt (read-only; no signal, no cleanup, no lock probe) ----
d=${ACTIVE_RUN_DIR:-}
alive=false; kill -0 "$ACTIVE_PID" 2>/dev/null && alive=true
fd9=""; cmd=""; st_now=""; if [[ $alive == true ]]; then fd9=$(readlink "/proc/$ACTIVE_PID/fd/9" 2>/dev/null); cmd=$(tr '\0' ' ' < "/proc/$ACTIVE_PID/cmdline" 2>/dev/null | cut -c1-200); st_now=$(proc_start "$ACTIVE_PID"); fi
self_hold_line=""; self_hold_rec=""; qh_id=""; qh_live=false; sid=""; C_MEMBERS=""; C_STATE=NONE
if [[ -n $d ]]; then
  self_hold_line=$(grep -m1 'SELF-HOLD: launcher pid=' "$d/console.log" 2>/dev/null)
  self_hold_rec=$(timeout --foreground "$SCAN_S" python3 -c 'import json,sys;L=json.load(open(sys.argv[1]));print(L.get("overall"),L.get("launcher_exit"),L.get("lease",{}).get("self_hold"),L.get("lease",{}).get("quarantine_ok"),L.get("lease",{}).get("quarantine_receipt_ok"))' "$d/SUPERVISOR_RECORD.json" 2>/dev/null)
  qh_id=$(holder_identity "$d"); holder_alive "$d" && qh_live=true
  sid=$(cat "$d/OWNED_SID" 2>/dev/null); [[ -n $sid ]] && census "$sid"
fi
# classification of THIS process's return (never reinterprets the launcher's code):
if   [[ -n $UNRESOLVED ]]; then OBSERVER=97; kind=RETAINED_OR_UNRESOLVED
elif [[ -n $LAUNCHER_RC ]]; then OBSERVER=$LAUNCHER_RC; kind=ACTUAL_LAUNCHER_EXIT
else OBSERVER=97; kind=RETAINED_OR_UNRESOLVED; UNRESOLVED="launcher pid=$ACTIVE_PID exit status not reaped and not confirmed alive — unknown"; fi
if [[ $alive == true && $cmd == *"s4r6-quarantine-holder-"*"-SELF"* && $fd9 == "$LEASE_PATH" && -n $ACTIVE_START && $st_now == "$ACTIVE_START" ]]; then kind="SELF_HOLD_RETAINED(identity verified: pid+starttime+token+fd9)"; fi
# [driver L195 reuse] a raw 0 contradicted by current facts is not passed through as the observer's success: the stdout line
# still reports the ACTUAL 0, the observer returns 94 (success contradicted) — never the other way round, never a faked 0.
if [[ $OBSERVER == 0 ]] && { [[ -z $d || -z $sid || $C_STATE != EMPTY || $qh_live == true ]]; }; then OBSERVER=94; kind="ACTUAL_LAUNCHER_EXIT_0_CONTRADICTED(run='${d:-<none>}' sid='${sid:-<none>}' census=$C_STATE live_holder=$qh_live)"; note "launcher exit 0 contradicted by current facts: $kind — observer 94"; fi
if [[ -n $LAUNCHER_RC && $LAUNCHER_RC == 12 ]]; then note "launcher ACTUALLY exited 12: SELF-HOLD exec failed and the process is gone (recorded in its console/record); this is an exit, not a retained holder — STOP and inspect"; fi

{  # V2 (S4-NATIVE-V1-A01): every required write is AND-chained, so ANY failed printf fails the group, skips mv and reaches the failure branch
  printf 'NATIVE-CALLER receipt %s\ncaller_pid=%s caller_start=%s launcher=%s launcher_sha256=%s\n' "$(now)" "$$" "$(proc_start $$)" "$LAUNCHER" "$(sha256sum "$LAUNCHER" 2>/dev/null | cut -d" " -f1)" &&
  printf 'launcher_pid=%s launcher_start_at_spawn=%s launcher_start_now=%s alive_now=%s run=%s identity=%s\n' "$ACTIVE_PID" "${ACTIVE_START:-unknown}" "${st_now:-<gone>}" "$alive" "${d:-<none>}" "$RUN_IDENTITY" &&
  printf 'ACTUAL_LAUNCHER_EXIT=%s   OBSERVER_RETURN=%s   classification=%s\n' "${LAUNCHER_RC:-none}" "$OBSERVER" "$kind" &&
  printf 'observer_bound_s=%s elapsed_s=%s cancelled=%s cancel_sent_epoch=%s\n' "$OBSERVE_S" "$(( $(date +%s) - T0 ))" "${CANCELLED:-}" "${CANCEL_SENT:-}" &&
  printf 'live_launcher_fd9=%s live_launcher_cmdline=%s lease_path=%s lease_held_by_live_launcher=%s\n' "${fd9:-<none>}" "${cmd:-<none>}" "$LEASE_PATH" "$([[ $fd9 == "$LEASE_PATH" ]] && echo true || echo false)" &&
  printf 'console_SELF_HOLD_line=%s\nrecord(overall launcher_exit self_hold quarantine_ok receipt_ok)=%s\n' "${self_hold_line:-<none>}" "${self_hold_rec:-<none>}" &&
  printf 'recorded_quarantine_holder(pid starttime token)=%s live_identity_checked=%s\n' "${qh_id:-<none>}" "$qh_live" &&
  printf 'owned_session_sid=%s census_now=%s members=%s (read-only; UNKNOWN is never empty)\n' "${sid:-<none>}" "$C_STATE" "${C_MEMBERS:-}" &&
  printf 'UNRESOLVED=%s\n' "${UNRESOLVED:-}" &&
  printf '%s\n' "${NOTES[@]}" &&
  printf 'SEMANTICS: OBSERVER_RETURN 97 is a bounded observer return, NOT a launcher exit, NOT success, NOT a normal exit 12. A live launcher or holder listed above is the last exclusion owner: recovery ONLY by the parent, ONLY if /proc/<pid>/stat starttime, cmdline token and readlink /proc/<pid>/fd/9 == %s all match the recorded values, after the owned session is verified EMPTY (UNKNOWN never counts). Never signal a bare pid. Nothing was killed or cleaned by this caller.\n' "$LEASE_PATH"
} > "$RECEIPT.tmp" 2>/dev/null && mv -f "$RECEIPT.tmp" "$RECEIPT" 2>/dev/null || { [[ $OBSERVER == 0 ]] && OBSERVER=90; echo "caller: receipt could not be written ($RECEIPT); observer now $OBSERVER" >&2; }

# stdout contract: the accepted caller's line, byte-for-byte, when the launcher actually exited; a distinct line otherwise
if [[ -n $LAUNCHER_RC ]]; then printf "launcher exit=%s\n" "$LAUNCHER_RC"; else printf "launcher exit=none observer=%s %s\n" "$OBSERVER" "$kind"; fi
printf "caller receipt=%s observer_return=%s\n" "$RECEIPT" "$OBSERVER"
exit "$OBSERVER"
