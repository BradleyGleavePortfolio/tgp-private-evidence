#!/usr/bin/env bash
# OP88-S5-V9 control fixture (NOT EXECUTED by the builder): a minimal supervisor that runs the exact OWN-BLOCK v9 launch sequence
# (attempt path -> spawn_begin -> setsid gate child -> register -> confirm -> adopt -> bounded wait -> finish -> group escalation -> retire)
# around a FAKE workload that only writes a WORKLOAD_RAN marker and sleeps. Deterministic seams: interruptions are self-delivered
# (`kill -TERM $$`) at exact phases; no-ack/stale/write-failure are configured before spawn. No network, Jest, npm, DB or lock.
# usage: sup-under-test.v9.sh <scenario> <recdir>   scenarios: plain natural-exit no-ack stale-adopt write-fail never-setsid delayed-setsid
#        interrupt-afterfork interrupt-adopting pre-spawn-stale leader-first-exit term-ignoring reuse-refusal timeout
set -u
SC=$1; REC=$2; mkdir -p "$REC"; . "$(dirname "${BASH_SOURCE[0]}")/../own-block-v9.sh"
OWN_ROOT="$REC/attempts"; mkdir -p "$OWN_ROOT"; O="$REC/sup.out"; : > "$O"
say() { echo "$*" >> "$O"; }
echo "$$ $OWN_SELF_PGID" > "$REC/sup.pid_pgid"
trap 'o=$(own_reap_all 2); rrc=$?; { printf "%s\n" "$o"; echo "v9-trap phase=$OWN_PHASE bang=${!:-none} registered=[$OWN_PIDS] confirmed=[$OWN_PGIDS] retired=[$OWN_RETIRED] reap_rc=$rrc"; } > "$REC/trap.out"; exit $(( rrc ? 91 : 143 ))' TERM
WL_SLEEP='echo ran > "$0"; exec sleep 20'
case "$SC" in
  natural-exit)      WL='echo ran > "$0"; exit 0' ;;
  leader-first-exit) WL='echo ran > "$0"; ( trap "" TERM; sleep 20 ) & exit 0' ;;    # leader gone, TERM-ignoring same-group grandchild remains
  term-ignoring)     WL='echo ran > "$0"; trap "" TERM; sleep 20' ;;
  *)                 WL=$WL_SLEEP ;;
esac
spawn() { # <attempt>: exact consumer shape; interrupt-afterfork self-TERMs after `&` BEFORE the caller can read $!
  case "$SC" in
    never-setsid)   ( exec        bash -c "$OWN_GATE" own-gate "$1" $$ bash -c "$WL" "$1/WORKLOAD_RAN" ) > "$REC/child.stdout" 2>&1 < /dev/null & ;;
    delayed-setsid) ( sleep 1; exec setsid bash -c "$OWN_GATE" own-gate "$1" $$ bash -c "$WL" "$1/WORKLOAD_RAN" ) > "$REC/child.stdout" 2>&1 < /dev/null & ;;
    *)              ( exec setsid bash -c "$OWN_GATE" own-gate "$1" $$ bash -c "$WL" "$1/WORKLOAD_RAN" ) > "$REC/child.stdout" 2>&1 < /dev/null & ;;
  esac
  [ "$SC" = interrupt-afterfork ] && kill -TERM $$; :; }
cycle() { # one full launch/adopt/finish cycle; sets PID ATT PUB FIN
  ATT=$(own_attempt) || { say "attempt-failed"; exit 70; }
  [ "$SC" = stale-adopt ] && printf '%s' "999 bogus" > "$ATT/ADOPT"        # stale/foreign publication that the child must refuse
  [ "$SC" = write-fail ] && chmod a-w "$ATT"                                 # publication must fail and be reported, workload never released
  own_spawn_begin; spawn "$ATT"; PID=$!; own_register "$PID"; echo "$PID" > "$REC/child.pid"
  [ "$SC" = interrupt-adopting ] && kill -TERM $$                            # registered but not yet adopted
  own_confirm "$PID" 2; crc=$?; PUB=not-attempted
  if [ "$crc" = 0 ] && [ "$SC" != no-ack ] && [ "$SC" != stale-adopt ]; then PUB=$(own_adopt "$PID" "$ATT"); fi
  say "cycle pid=$PID attempt=${ATT##*/} confirm_rc=$crc identity=[$(own_identity "$PID")] self_pgid=$OWN_SELF_PGID decoy=${OWN_LAST_DECOY:-none} adoption=$PUB"
  if [ "$PUB" != published ]; then
    if [ "$crc" = 0 ]; then own_wait_gone "$PID" 7; fi                        # confirmed but never adopted: the gate itself must exit 75 (no workload)
    how=$(own_signal "$PID" TERM); own_wait_gone "$PID" 3 || { how="$how+KILL:$(own_signal "$PID" KILL)"; own_wait_gone "$PID" 3; }
    FIN=$(own_finish "$PID"); say "refused signal=$how raw=$FIN workload_ran=$([ -e "$ATT/WORKLOAD_RAN" ] && echo YES || echo no)"
    [ "${FIN%% *}" = observed ] && own_retire "$PID"; return 2; fi
  case "$SC" in
    timeout) w=0; while own_alive "$PID" && [ $w -lt 1 ]; do sleep 1; w=$((w+1)); done; how=exited
             own_alive "$PID" && { how=budget-TERM; own_signal "$PID" TERM >/dev/null; own_wait_gone "$PID" 3 || { how=budget-KILL; own_signal "$PID" KILL >/dev/null; own_wait_gone "$PID" 3; }; } ;;
    natural-exit|leader-first-exit) own_wait_gone "$PID" 5; how=exited ;;
    *) sleep 0.5; how=running ;;
  esac
  FIN=$(own_finish "$PID"); say "finish raw=$FIN how=$how workload_ran=$([ -e "$ATT/WORKLOAD_RAN" ] && echo YES || echo no)"
  o=$(own_reap_all 1); rrc=$?; printf '%s\n' "$o" >> "$O"; say "reap_rc=$rrc group_current_rc=$(own_group_current "$PID"; echo $?)"
  [ "${FIN%% *}" = observed ] || { FIN=$(own_finish "$PID"); say "finish-after-reap raw=$FIN"; }
  if [ "${FIN%% *}" = observed ] && [ "$rrc" = 0 ]; then own_retire "$PID" && say "retired pid=$PID retired_list=[$OWN_RETIRED]"; fi
  RRC=$rrc; return 0; }
case "$SC" in
  pre-spawn-stale) cycle; say "phase2 bang=$! (must equal retired pid $PID)"; own_spawn_begin; kill -TERM $$; sleep 1; say "UNREACHABLE"; exit 99 ;;
  reuse-refusal)   cycle; say "retired-signal=$(own_signal "$PID" TERM) nonchild-signal=$(own_signal 1 TERM) retired-group=$(own_group_signal "$PID" TERM) alive_retired=$(own_alive "$PID" && echo YES || echo no)"; exit "$RRC" ;;
  *) cycle; rc=$?; [ "$rc" = 2 ] && exit 2; exit "$RRC" ;;
esac
