#!/usr/bin/env bash
# OP88-S5-V10 control fixture (NOT EXECUTED by the builder): minimal supervisor running the exact OWN-BLOCK v10 consumer sequence
# (attempt -> spawn_begin -> setsid gate child -> register -> confirm -> pre-release IDENTITY record -> adopt -> bounded wait -> in-shell finish
# -> session escalation -> retire) around a FAKE workload (marker + sleep). All waits are top-level in this shell (A-01/V9B-02).
# Acknowledged seams (no sleeps-as-proof): delayed-setsid holds in the caller group until the fixture has OBSERVED the decoy and removes HOLD;
# TERM-ignoring workloads write their marker only AFTER installing the ignore; the leader-first-exit leader waits for the grandchild's marker.
# usage: sup-under-test.v10.sh <scenario> <recdir>
#  plain natural-exit no-ack stale-adopt write-fail never-setsid delayed-setsid interrupt-afterfork interrupt-adopting pre-spawn-stale
#  leader-first-exit term-ignoring reuse-refusal timeout post-release-fail identity-pub-fail
set -u
SC=$1; REC=$2; mkdir -p "$REC"; . "$(dirname "${BASH_SOURCE[0]}")/../own-block-v10.sh"
OWN_ROOT="$REC/attempts"; mkdir -p "$OWN_ROOT"; O="$REC/sup.out"; : > "$O"; POST="$REC/post"; mkdir -p "$POST"
say() { echo "$*" >> "$O"; }
echo "$$ $OWN_SELF_PGID $OWN_SELF_SID" > "$REC/sup.pid_pgid"
on_term() { local o rrc; o=$(own_reap_all 2); rrc=$?; { printf '%s\n' "$o"; echo "v10-trap phase=$OWN_PHASE bang=${!:-none} registered=[$OWN_PIDS] confirmed=[$OWN_PGIDS] retired=[$OWN_RETIRED] reap_rc=$rrc"; } > "$REC/trap.out"
  [ -e "$REC/child.pid" ] || { [ "$OWN_PHASE" = spawning ] && [ -n "${!:-}" ] && echo "$!" > "$REC/child.pid"; }
  own_collect "trap-" >> "$REC/trap.out"; own_census >> "$REC/trap.out"; crc=$?; exit $(( (rrc || crc) ? 91 : 143 )); }
trap on_term TERM
WL_SLEEP='echo ran > "$0"; exec sleep 20'
case "$SC" in
  natural-exit)      WL='echo ran > "$0"; exit 0' ;;
  leader-first-exit) WL='( trap "" TERM; echo ran > "$0"; exec sleep 20 ) & i=0; until [ -e "$0" ] || [ $i -ge 100 ]; do sleep 0.05; i=$((i+1)); done; exit 0' ;;  # grandchild acknowledged (marker after ignore) before leader exits
  term-ignoring)     WL='trap "" TERM; echo ran > "$0"; exec sleep 20' ;;                                                               # marker only after the ignore is installed
  *)                 WL=$WL_SLEEP ;;
esac
spawn() { # <attempt>: exact consumer shape (setsid bash -c "$OWN_GATE" own-gate <attempt> <parent> <workload...>)
  case "$SC" in
    never-setsid)   ( exec        bash -c "$OWN_GATE" own-gate "$1" $$ bash -c "$WL" "$1/WORKLOAD_RAN" ) > "$REC/child.stdout" 2>&1 < /dev/null & ;;
    delayed-setsid) ( i=0; while [ -e "$1/HOLD" ] && [ $i -lt 100 ]; do sleep 0.05; i=$((i+1)); done; exec setsid bash -c "$OWN_GATE" own-gate "$1" $$ bash -c "$WL" "$1/WORKLOAD_RAN" ) > "$REC/child.stdout" 2>&1 < /dev/null & ;;
    *)              ( exec setsid bash -c "$OWN_GATE" own-gate "$1" $$ bash -c "$WL" "$1/WORKLOAD_RAN" ) > "$REC/child.stdout" 2>&1 < /dev/null & ;;
  esac
  [ "$SC" = interrupt-afterfork ] && kill -TERM $$; :; }
wait_marker() { local i=0; until [ -e "$1" ] || [ $i -ge 100 ]; do sleep 0.05; i=$((i+1)); done; [ -e "$1" ]; }   # acknowledged readiness, bounded 5 s
cycle() { # sets PID ATT PUB STATE FIN RRC
  ATT=$(own_attempt) || { say "attempt-failed"; exit 70; }; STATE=never-released; PUB=not-attempted
  [ "$SC" = stale-adopt ] && printf '%s' "999 bogus" > "$ATT/ADOPT"
  [ "$SC" = write-fail ] && chmod a-w "$ATT"
  [ "$SC" = delayed-setsid ] && : > "$ATT/HOLD"
  [ "$SC" = identity-pub-fail ] && { mkdir -p "$ATT/IDENTITY"; }                 # a directory where the record must be: own_record must fail BEFORE release
  [ "$SC" = post-release-fail ] && chmod a-w "$POST"                             # post-release record dir unwritable
  own_spawn_begin; spawn "$ATT"; PID=$!; own_register "$PID"; echo "$PID" > "$REC/child.pid"
  [ "$SC" = interrupt-adopting ] && kill -TERM $$
  if [ "$SC" = delayed-setsid ]; then i=0; until [ "$(own_ps_field "$PID" pgid)" = "$OWN_SELF_PGID" ] || [ $i -ge 40 ]; do sleep 0.05; i=$((i+1)); done; say "decoy-observed pgid=$(own_ps_field "$PID" pgid) self=$OWN_SELF_PGID"; rm -f "$ATT/HOLD"; fi
  own_confirm "$PID" 2; crc=$?
  if [ "$crc" = 0 ] && [ "$SC" != no-ack ] && [ "$SC" != stale-adopt ]; then
    if own_record "$ATT/IDENTITY" "pid=$PID attempt=${ATT##*/} identity=[$(own_identity "$PID")] self_pgid=$OWN_SELF_PGID decoy=${OWN_LAST_DECOY:-none}"; then PUB=$(own_adopt "$PID" "$ATT"); [ "$PUB" = published ] && STATE=released; else PUB=identity-publication-failed; fi; fi
  say "cycle pid=$PID attempt=${ATT##*/} confirm_rc=$crc identity=[$(own_identity "$PID" 2>/dev/null)] self_pgid=$OWN_SELF_PGID decoy=${OWN_LAST_DECOY:-none} adoption=$PUB state=$STATE"
  if [ "$STATE" = released ]; then own_record "$POST/START" "released pid=$PID attempt=${ATT##*/}" || { STATE=released-then-cancelled; say "post-release publication failed -> cancel"; }; fi
  if [ "$STATE" != released ]; then
    [ "$STATE" = released-then-cancelled ] && wait_marker "$ATT/WORKLOAD_RAN"                    # released work is acknowledged before cancellation
    [ "$crc" = 0 ] && [ "$PUB" = not-attempted ] && own_wait_gone "$PID" 7                      # confirmed but never adopted: the gate itself must exit 75
    how=$(own_signal "$PID" TERM); own_wait_gone "$PID" 3 || { how="$how+KILL:$(own_signal "$PID" KILL)"; own_wait_gone "$PID" 3; }
    own_finish "$PID"; FIN="$OWN_FIN${OWN_FIN_RC:+ $OWN_FIN_RC}"; say "refused state=$STATE signal=$how raw=$FIN workload_ran=$([ -e "$ATT/WORKLOAD_RAN" ] && echo YES || echo no)"
    o=$(own_reap_all 1); rrc=$?; printf '%s\n' "$o" >> "$O"; own_collect "post-" >> "$O"; own_census >> "$O"; crc2=$?; say "reap_rc=$rrc census_rc=$crc2 retired=[$OWN_RETIRED]"; RRC=$(( rrc || crc2 )); return 2; fi
  case "$SC" in
    timeout) w=0; while own_alive "$PID" && [ $w -lt 1 ]; do sleep 1; w=$((w+1)); done; how=exited
             own_alive "$PID" && { how=budget-TERM; own_signal "$PID" TERM >/dev/null; own_wait_gone "$PID" 3 || { how=budget-KILL; own_signal "$PID" KILL >/dev/null; own_wait_gone "$PID" 3; }; } ;;
    natural-exit|leader-first-exit) wait_marker "$ATT/WORKLOAD_RAN"; own_wait_gone "$PID" 5; how=exited ;;
    *) wait_marker "$ATT/WORKLOAD_RAN" || say "marker-timeout"; how=running ;;
  esac
  own_finish "$PID"; FIN="$OWN_FIN${OWN_FIN_RC:+ $OWN_FIN_RC}"; say "finish raw=$FIN how=$how workload_ran=$([ -e "$ATT/WORKLOAD_RAN" ] && echo YES || echo no)"
  o=$(own_reap_all 1); rrc=$?; printf '%s\n' "$o" >> "$O"; own_group_current "$PID"; gc=$?; say "reap_rc=$rrc group_current_rc=$gc"
  [ "$OWN_FIN" = observed ] || { own_finish "$PID"; FIN="$OWN_FIN${OWN_FIN_RC:+ $OWN_FIN_RC}"; say "finish-after-reap raw=$FIN"; }
  if [ "$OWN_FIN" = observed ] && [ "$rrc" = 0 ] && [ "$gc" = 1 ]; then own_retire "$PID" && say "retired pid=$PID retired_list=[$OWN_RETIRED]"; fi
  own_census >> "$O"; crc2=$?; RRC=$(( rrc || crc2 )); return 0; }
case "$SC" in
  pre-spawn-stale) cycle; say "phase2 bang=$! retired=$PID"; own_spawn_begin; kill -TERM $$; sleep 1; say "UNREACHABLE"; exit 99 ;;
  reuse-refusal)   cycle; own_spawn_begin; ( exec setsid sleep 20 ) & Q=$!; own_register "$Q"; own_confirm "$Q" 2; own_retire "$Q" && RL=NO || RL=yes   # retiring a LIVE child must be refused
                   own_signal "$Q" KILL >/dev/null; own_wait_gone "$Q" 3; own_finish "$Q"; own_retire "$Q"; own_census >> "$O"; c2=$?
                   say "retired-signal=$(own_signal "$PID" TERM) nonchild-signal=$(own_signal 1 TERM) retired-group=$(own_group_signal "$PID" TERM) alive_retired=$(own_alive "$PID" && echo YES || echo no) retire-live-refused=$RL second_raw=$OWN_FIN${OWN_FIN_RC:+ $OWN_FIN_RC} census_rc=$c2"; exit $(( RRC || c2 )) ;;
  *) cycle; rc=$?; exit "$RRC" ;;
esac
