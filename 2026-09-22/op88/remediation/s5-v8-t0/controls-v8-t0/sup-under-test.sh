#!/usr/bin/env bash
# OP88-S5-V8 control fixture: a minimal supervisor that exercises OWN-BLOCK v8 (or the v1/v6 predecessor pattern) with a FAKE
# child (sleep), so startup interruption, caller-group decoys and TERM-ignoring children can be driven deterministically.
# No network, no Jest, no node_modules, no lock. Invoked only by ctl-own-startup.sh (NOT EXECUTED by the builder).
# usage: sup-under-test.sh <mode:v8|pred> <scenario:interrupt|decoy-delayed|decoy-never|term-ignoring|plain> <recdir>
set -u
MODE=$1; SC=$2; REC=$3; mkdir -p "$REC"
case "$MODE" in
  v8) . "$(dirname "${BASH_SOURCE[0]}")/../own-block-v8.sh" ;;
  pred) OWNED_PGIDS="" ;;              # predecessor pattern (v6 run_gate L69 / setup v1 L91): sample pgid after sleep 0.2
  *) echo "bad mode"; exit 64 ;;
esac
echo "$$ $(ps -o pgid= -p $$ | tr -d ' ')" > "$REC/sup.pid_pgid"
case "$SC" in
  interrupt|plain)   spawn() { ( exec setsid sleep 20 ) & } ;;
  decoy-delayed)     spawn() { ( sleep 1; exec setsid sleep 20 ) & } ;;   # stays in the CALLER group for ~1 s, then becomes its own session leader
  decoy-never)       spawn() { ( exec sleep 20 ) & } ;;                   # never leaves the caller group
  term-ignoring)     spawn() { ( exec setsid bash -c 'trap "" TERM; sleep 20' ) & } ;;
  *) echo "bad scenario"; exit 64 ;;
esac
if [ "$MODE" = pred ]; then
  trap 'for pg in $OWNED_PGIDS; do echo "pred-trap WOULD/DID signal pgid=$pg" >> "$REC/trap.out"; done; echo "pred-trap owned=[$OWNED_PGIDS]" >> "$REC/trap.out"; exit 143' TERM
  spawn; pid=$!; echo "$pid" > "$REC/child.pid"
  [ "$SC" = interrupt ] && kill -TERM $$                                   # deterministic: TERM arrives before the sample below; trap sees OWNED_PGIDS empty
  sleep 0.2; pg=$(ps -o pgid= "$pid" 2>/dev/null | tr -d ' '); [ -z "$pg" ] && pg=$pid; OWNED_PGIDS="$pg"
  self=$(ps -o pgid= -p $$ | tr -d ' ')
  echo "pred sampled pgid=$pg self_pgid=$self would_target_self=$([ "$pg" = "$self" ] && echo YES || echo no)" > "$REC/sup.out"
  # the predecessor pattern is NOT allowed to fire a group signal here (it could hit the caller group); report only, then pid-only cleanup
  kill -TERM "$pid" 2>/dev/null; sleep 0.3; kill -KILL "$pid" 2>/dev/null; wait "$pid" 2>/dev/null; exit 0
fi
# ---- v8 path
trap 'o=$(own_reap_all 5); printf "%s\n" "$o" > "$REC/trap.out"; echo "v8-trap registered=[$OWN_PIDS] confirmed=[$OWN_PGIDS]" >> "$REC/trap.out"; exit 143' TERM
spawn; pid=$!; own_register "$pid"; echo "$pid" > "$REC/child.pid"
[ "$SC" = interrupt ] && kill -TERM $$                                     # deterministic: TERM between spawn/registration and confirmation
own_confirm "$pid" 2; crc=$?
echo "v8 confirm_rc=$crc identity=[$(own_identity "$pid")] self_pgid=$OWN_SELF_PGID decoy=${OWN_LAST_DECOY:-none} confirmed=[$OWN_PGIDS]" > "$REC/sup.out"
if [ "$crc" != 0 ]; then how=$(own_signal "$pid" TERM); own_wait_gone "$pid" 5 || { how="$how+KILL:$(own_signal "$pid" KILL)"; own_wait_gone "$pid" 3; }; echo "v8 identity-refused signal=$how" >> "$REC/sup.out"; wait "$pid" 2>/dev/null; exit 2; fi
o=$(own_reap_all 1); rc=$?; printf '%s\n' "$o" >> "$REC/sup.out"
wait "$pid" 2>/dev/null; echo "v8 reap_rc=$rc self_alive_after_reap=yes" >> "$REC/sup.out"; exit 0
