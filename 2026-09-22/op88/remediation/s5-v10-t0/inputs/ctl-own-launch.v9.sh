#!/usr/bin/env bash
# OP88-S5-V9 deterministic no-network controls for OWN-BLOCK v9 (NOT EXECUTED by the builder; separate grant required).
# The ENCLOSURE ITSELF uses the v9 primitive (adoption-gated setsid launch, phase-bound pending fork, bounded reap, retire), so an outer
# cancellation at any moment reaps the active fixture session; fixture grandchildren are verified absent by recorded pid but NEVER signalled
# by bare number (fail-closed FIXTURE_SURVIVOR instead). Fake sleep children only; no Jest, node_modules, worktree, npm, DB, network, lock.
# Invocation (when granted): cd /home/user/workspace/execution/op88/s5-v9-t0 && S5_CTL_GRANT=granted-by-parent \
#   timeout --foreground -k 10 200 bash controls-v9-t0/ctl-own-launch.v9.sh     (200 + 10 = nominal allowance, not a completion attestation)
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; PKT="$(cd "$HERE/.." && pwd)"
[ "${S5_CTL_GRANT:-}" = "granted-by-parent" ] || { echo "REFUSE: S5_CTL_GRANT=granted-by-parent not set"; exit 2; }
PIN_OWN=9d713d2cc50dcb33500bc13df5d737c1b9a0c6e2b7845113e244c50ab89ae82d; PIN_SUP=b9d3383367d2f4325566bd1374fe5038f8cc00a87d0a53a4bc3d60d6844d98e4
h() { sha256sum "$1" | cut -c1-64; }
[ "$(h "$PKT/own-block-v9.sh")" = "$PIN_OWN" ] || { echo "REFUSE: own-block-v9.sh hash != $PIN_OWN"; exit 2; }
[ "$(h "$HERE/sup-under-test.v9.sh")" = "$PIN_SUP" ] || { echo "REFUSE: sup-under-test.v9.sh hash != $PIN_SUP"; exit 2; }
OUT="${S5_V9_OUT:-$PKT/control-results}"; TS=$(date -u +%Y%m%dT%H%M%SZ); mkdir -p "$OUT/$TS" || exit 74; LOG="$OUT/own-launch-$TS.log"
. "$PKT/own-block-v9.sh"; OWN_ROOT="$OUT/$TS/enclosure-attempts"; mkdir -p "$OWN_ROOT" || exit 74
T0=$(date +%s); AGG=170; PASS=0; FAIL=0; CASE_BOUND=25; GRAND=""
log() { echo "$(date -u +%FT%TZ) $*" | tee -a "$LOG" || exit 74; }
finish_ctl() { local prim=$? o rrc surv=0 g; o=$(own_reap_all 3); rrc=$?; [ -n "$o" ] && printf '%s\n' "$o" | while read -r l; do log "ENCLOSURE_CLEANUP $l"; done
  for g in $GRAND; do kill -0 "$g" 2>/dev/null && { own_wait_gone_any "$g" 3 || { log "FIXTURE_SURVIVOR pid=$g (fixture grandchild alive; not signalled by bare number: fail-closed)"; surv=1; }; }; done
  log "SUMMARY pass=$PASS fail=$FAIL enclosure_reap_rc=$rrc fixture_survivors=$surv aggregate_elapsed=$(( $(date +%s) - T0 ))s log=$LOG"
  if [ "$rrc" != 0 ] || [ "$surv" = 1 ]; then exit 90; fi; exit "$prim"; }
own_wait_gone_any() { local i=0 n=$(( $2 * 10 )); while kill -0 "$1" 2>/dev/null && [ $i -lt $n ]; do sleep 0.1; i=$((i+1)); done; ! kill -0 "$1" 2>/dev/null; }
trap finish_ctl EXIT; trap 'log SIGNAL; exit 143' TERM INT HUP
check() { if [ "$2" = 0 ]; then PASS=$((PASS+1)); log "PASS $1 $3"; else FAIL=$((FAIL+1)); log "FAIL $1 $3"; log "STOP_ON_FIRST_FAILURE $1"; exit 1; fi; }
run_sup() { # <case> <scenario>: launch the fixture through the v9 primitive; sets SUP_RC (observed or 137 synthetic), REC, CHILD
  local left=$((AGG - ($(date +%s) - T0))); [ "$(own_budget "$left" "$CASE_BOUND" 3 5)" -ge "$CASE_BOUND" ] || { log "AGGREGATE_BOUND_HIT before $1 (left=${left}s)"; exit 1; }
  REC="$OUT/$TS/$1"; mkdir -p "$REC"; local att pid fin pub
  att=$(own_attempt) || { log "$1 ENCLOSURE_ATTEMPT_FAILED"; exit 74; }; own_spawn_begin
  ( exec setsid bash -c "$OWN_GATE" own-gate "$att" $$ timeout -k 3 20 bash "$HERE/sup-under-test.v9.sh" "$2" "$REC" ) > "$REC/sup.stdout" 2>&1 < /dev/null &
  pid=$!; own_register "$pid"; own_confirm "$pid" 2 || { log "$1 ENCLOSURE_IDENTITY_UNCONFIRMED pid=$pid"; own_signal "$pid" KILL >/dev/null; own_wait_gone "$pid" 3; exit 1; }
  pub=$(own_adopt "$pid" "$att"); [ "$pub" = published ] || { log "$1 ENCLOSURE_PUBLICATION_FAILED $pub"; own_signal "$pid" KILL >/dev/null; own_wait_gone "$pid" 3; exit 1; }
  own_wait_gone "$pid" "$CASE_BOUND" || { log "$1 FIXTURE_OVERRAN ${CASE_BOUND}s: TERM"; own_signal "$pid" TERM >/dev/null; own_wait_gone "$pid" 3 || { own_signal "$pid" KILL >/dev/null; own_wait_gone "$pid" 3; }; }
  fin=$(own_finish "$pid"); if [ "${fin%% *}" = observed ]; then SUP_RC=${fin#* }; else SUP_RC=137; fi
  own_group_current "$pid"; case $? in 0) own_group_signal "$pid" TERM >/dev/null; own_group_wait_empty "$pid" 2 || { own_group_signal "$pid" KILL >/dev/null; own_group_wait_empty "$pid" 1; };; esac
  own_group_current "$pid"; local gc=$?; [ "${fin%% *}" = observed ] && [ "$gc" != 0 ] && own_retire "$pid"
  CHILD=$(cat "$REC/child.pid" 2>/dev/null || echo ""); [ -n "$CHILD" ] && GRAND="$GRAND $CHILD"
  log "$1 sup_raw=$fin sup_rc=$SUP_RC enclosure_group_rc=$gc child=$CHILD sup.out=[$(tr '\n' '|' < "$REC/sup.out" 2>/dev/null)] trap.out=[$(tr '\n' '|' < "$REC/trap.out" 2>/dev/null)]"
}
gone() { own_wait_gone_any "$1" "$2"; }
ran() { ls "$REC"/attempts/*/WORKLOAD_RAN >/dev/null 2>&1; }
log "OWN_LAUNCH_CONTROLS_START own=$PIN_OWN sup=$PIN_SUP control_sha256=$(h "$0") self_pgid=$OWN_SELF_PGID"
log "CANONICAL_LOCK_PATH_STAT $(stat -c 'exists mtime=%y' /home/user/workspace/execution/test-validation.lock 2>/dev/null || echo absent) (not opened, not probed)"
check C0.budget "$( [ "$(own_budget 6 90 10 10)" = 0 ] && [ "$(own_budget 30 90 10 10)" = 10 ] && [ "$(own_budget 200 90 10 10)" = 90 ]; echo $? )" "own_budget arithmetic"
run_sup C1 plain
check C1.adopted_and_ran "$( [ "$SUP_RC" = 0 ] && grep -q 'adoption=published' "$REC/sup.out" && ran && grep -q "REAPED pid=$CHILD how=group" "$REC/sup.out" && grep -q 'reap_rc=0' "$REC/sup.out" && grep -q "retired pid=$CHILD" "$REC/sup.out" && gone "$CHILD" 1; echo $? )" "plain: confirmed, adopted on fresh path, workload released, reaped by group, cleanup rc 0, authority retired"
run_sup C2 natural-exit
check C2.observed_exit "$( [ "$SUP_RC" = 0 ] && grep -q 'finish raw=observed 0' "$REC/sup.out" && ran && grep -q "retired pid=$CHILD" "$REC/sup.out"; echo $? )" "natural exit observed via wait after verified absence; retired"
run_sup C3 no-ack
check C3.no_workload "$( [ "$SUP_RC" = 2 ] && grep -q 'confirm_rc=0' "$REC/sup.out" && grep -q 'adoption=not-attempted' "$REC/sup.out" && grep -q 'raw=observed 75 workload_ran=no' "$REC/sup.out" && ! ran; echo $? )" "no ack: child gate expired (75) and NO workload ran"
run_sup C4 stale-adopt
check C4.stale_refused "$( [ "$SUP_RC" = 2 ] && grep -q 'raw=observed 75 workload_ran=no' "$REC/sup.out" && ! ran; echo $? )" "stale/foreign ADOPT content refused by the child; no workload"
run_sup C5 write-fail
chmod u+w "$REC"/attempts/* 2>/dev/null
check C5.publication_failure "$( [ "$SUP_RC" = 2 ] && grep -q 'adoption=publication-write-failed' "$REC/sup.out" && grep -q 'workload_ran=no' "$REC/sup.out" && ! ran; echo $? )" "publication write failure named and fail-closed; no workload"
run_sup C6 never-setsid
check C6.caller_decoy "$( [ "$SUP_RC" = 2 ] && grep -q 'confirm_rc=2' "$REC/sup.out" && grep -Eq "decoy=$(cut -d' ' -f2 "$REC/sup.pid_pgid")" "$REC/sup.out" && grep -q 'refused signal=pid' "$REC/sup.out" && ! ran && gone "$CHILD" 1; echo $? )" "child in caller group: decoy recorded, identity refused, pid-only signal, no workload, fixture not self-killed"
run_sup C7 delayed-setsid
check C7.delayed_identity "$( [ "$SUP_RC" = 0 ] && grep -q 'confirm_rc=0' "$REC/sup.out" && grep -q 'adoption=published' "$REC/sup.out" && ran && grep -q 'reap_rc=0' "$REC/sup.out"; echo $? )" "delayed setsid: confirmed after the decoy phase, adopted, workload released, reaped"
run_sup C8 interrupt-afterfork
check C8.pending_fork_reaped "$( [ "$SUP_RC" = 143 ] && grep -q 'phase=spawning' "$REC/trap.out" && grep -q 'registered=\[\]' "$REC/trap.out" && grep -Eq 'REAPED pid=[0-9]+ how=(pid|group)' "$REC/trap.out" && grep -q 'reap_rc=0' "$REC/trap.out" && ! ran; echo $? )" "TERM between fork and register: phase-bound \$! fallback reaped the unregistered child; no workload"
run_sup C9 interrupt-adopting
check C9.registered_reaped "$( [ "$SUP_RC" = 143 ] && grep -q "REAPED pid=$CHILD" "$REC/trap.out" && grep -q 'reap_rc=0' "$REC/trap.out" && ! ran && gone "$CHILD" 1; echo $? )" "TERM after register before adopt: reaped, no workload"
run_sup C10 pre-spawn-stale
check C10.no_stale_signal "$( [ "$SUP_RC" = 143 ] && grep -q 'phase=spawning' "$REC/trap.out" && ! grep -Eq 'REAPED|SURVIVOR' "$REC/trap.out" && grep -q "retired=\[ *$CHILD\]" "$REC/trap.out" && grep -q 'reap_rc=0' "$REC/trap.out"; echo $? )" "pre-spawn TERM with stale \$! == retired pid: nothing signalled"
run_sup C11 leader-first-exit
check C11.descendants "$( [ "$SUP_RC" = 0 ] && grep -q 'finish raw=observed 0' "$REC/sup.out" && grep -Eq "GROUP_REAPED pgid=$CHILD how=group:[0-9]+\+KILL:group:[0-9]+" "$REC/sup.out" && grep -q 'reap_rc=0' "$REC/sup.out" && grep -q 'group_current_rc=1' "$REC/sup.out"; echo $? )" "leader exited first; TERM-ignoring same-group grandchild escalated to KILL; group verified empty"
run_sup C12 term-ignoring
check C12.kill_path "$( [ "$SUP_RC" = 0 ] && grep -Eq "REAPED pid=$CHILD how=group\+KILL:group" "$REC/sup.out" && grep -q 'reap_rc=0' "$REC/sup.out"; echo $? )" "TERM-ignoring leader: bounded grace then KILL"
run_sup C13 reuse-refusal
check C13.retired_refused "$( [ "$SUP_RC" = 0 ] && grep -q 'retired-signal=notchild nonchild-signal=notchild retired-group=refused alive_retired=no' "$REC/sup.out"; echo $? )" "retired pid / non-child pid / retired group: refused, nothing signalled"
run_sup C14 timeout
check C14.budget_term "$( [ "$SUP_RC" = 0 ] && grep -q 'how=budget-TERM' "$REC/sup.out" && grep -q 'finish raw=observed 143' "$REC/sup.out" && grep -q 'reap_rc=0' "$REC/sup.out"; echo $? )" "budget exceeded: group TERM, exit observed after verified absence, cleanup rc 0"
log "ALL_CASES_DONE pass=$PASS fail=$FAIL"
