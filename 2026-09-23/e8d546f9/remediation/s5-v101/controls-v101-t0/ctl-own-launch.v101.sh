#!/usr/bin/env bash
# OP88-S5-V10.1 deterministic no-network controls, successor of the v10 driver 4bf2ace2 (NOT EXECUTED by the builder; separate grant required after two independent exact V10.1 reviews).
# Corrects owned-launch-v10-a OWN-V10-A03 ONLY: a failed required enclosure EXIT record (own_record after the fixture is reaped) is LATCHED (PUB_FAIL) and reported per case
# (exit_record=ok|FAILED); finish_ctl then exits 74 when the primary result would otherwise be 0 — raw child, primary and cleanup statuses stay separate and unchanged
# (cleanup failure still governs first with 90; a nonzero primary keeps its own status). Pins/paths name the V10.1 primitive, fixture and consumers. Every check id, predicate
# and expected status (0 / 2 / 143; observed 75 / 143) is the v10 text unchanged: C3-C6 now become satisfiable only because the v10.1 fixture preserves its primary status (A01).
# Static expectation if granted: 25 PASS / 0 FAIL — an expectation, not evidence. Frozen invocation when granted (packet root decided by parent; relative paths only):
#   cd <v10.1 packet root> && S5_CTL_GRANT=granted-by-parent timeout --foreground -k 10 230 bash controls-v101-t0/ctl-own-launch.v101.sh   (caller captures and returns the actual status)
# v10 header follows.
# OP88-S5-V10 deterministic no-network controls for OWN-BLOCK v10 (NOT EXECUTED by the builder; separate grant required after both V10 reviews).
# Enclosure uses the v10 primitive itself (adoption-gated setsid launch, phase-bound pending, in-shell finish/collect, bounded reap, retire).
# Every wait is top-level in this shell. Fixture grandchildren are verified absent by recorded pid with live/zombie distinction and NEVER
# signalled by bare number (FIXTURE_SURVIVOR => rc 90). Fake sleep children only; no Jest, node_modules, worktree, npm, DB, network, lock.
# Invocation (when granted): cd /home/user/workspace/execution/op88/s5-v10-t0 && S5_CTL_GRANT=granted-by-parent \
#   timeout --foreground -k 10 230 bash controls-v10-t0/ctl-own-launch.v10.sh
# Allowance INCLUDING cleanup: 17 launched cases x (<= 20 s fixture + 3 KILL + 3+3 leader + 2+1 session) worst case is NOT guaranteed inside 190 s;
# admission (own_budget left 25 9 6) refuses a new case when it cannot fit; EXIT reap <= 3+3 s; 230 + 10 is a nominal allowance, not a completion attestation.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; PKT="$(cd "$HERE/.." && pwd)"
[ "${S5_CTL_GRANT:-}" = "granted-by-parent" ] || { echo "REFUSE: S5_CTL_GRANT=granted-by-parent not set"; exit 2; }
PIN_OWN=4aebf96f6b7c8962b7a4b10dfc25acb7a793a24744bc0e79de77675031b1c6c5; PIN_SUP=6b7088a8e0f5e19c56ce4ac254888b773d81674db965a44399fd2ce8b1787e65; PIN_T0=51fb43b724ce1571a94c75f232651dc473804af85d75f4cfd9b5ef7e1406d62c; PIN_SETUP=5f94783b44850cce3a16fc9ba68b75b572aa4b8125bc6a2e63fd650b8af98087
h() { sha256sum "$1" | cut -c1-64; }
[ "$(h "$PKT/own-block-v101.sh")" = "$PIN_OWN" ] || { echo "REFUSE: own-block-v101.sh hash != $PIN_OWN"; exit 2; }
[ "$(h "$HERE/sup-under-test.v101.sh")" = "$PIN_SUP" ] || { echo "REFUSE: sup-under-test.v101.sh hash != $PIN_SUP"; exit 2; }
OUT="${S5_V10_OUT:-$PKT/control-results}"; TS=$(date -u +%Y%m%dT%H%M%SZ); mkdir -p "$OUT/$TS" || exit 74; LOG="$OUT/own-launch-$TS.log"
. "$PKT/own-block-v101.sh"; OWN_ROOT="$OUT/$TS/enclosure-attempts"; mkdir -p "$OWN_ROOT" || exit 74
T0=$(date +%s); AGG=190; PASS=0; FAIL=0; CASE_BOUND=25; GRAND=""; PUB_FAIL=0   # A03 (V10.1): required enclosure publication failures are latched here
log() { echo "$(date -u +%FT%TZ) $*" | tee -a "$LOG" || exit 74; }
grand_state() { local st; st=$(own_ps_field "$1" stat); case $? in 1) echo gone;; 2) echo unknown;; 0) [ "${st:0:1}" = Z ] && echo zombie || echo live;; esac; }
finish_ctl() { local prim=$? o rrc surv=0 g s; o=$(own_reap_all 3); rrc=$?; [ -n "$o" ] && printf '%s\n' "$o" | while read -r l; do log "ENCLOSURE_CLEANUP $l"; done
  own_collect > "$OUT/$TS/enclosure-collect.txt"; while read -r l; do log "ENCLOSURE_CLEANUP $l"; done < "$OUT/$TS/enclosure-collect.txt"
  own_census | while read -r l; do log "ENCLOSURE_CENSUS $l"; done; own_census >/dev/null || surv=1
  for g in $GRAND; do s=$(grand_state "$g"); [ "$s" = gone ] || [ "$s" = zombie ] || { local i=0; while [ $i -lt 30 ] && [ "$(grand_state "$g")" = live ]; do sleep 0.1; i=$((i+1)); done; s=$(grand_state "$g"); [ "$s" = gone ] || [ "$s" = zombie ] || { log "FIXTURE_SURVIVOR pid=$g state=$s (fixture grandchild; not signalled by bare number: fail-closed)"; surv=1; }; }; done
  log "SUMMARY pass=$PASS fail=$FAIL primary_rc=$prim enclosure_reap_rc=$rrc unresolved=$surv publication_failures=$PUB_FAIL aggregate_elapsed=$(( $(date +%s) - T0 ))s log=$LOG"
  if [ "$rrc" != 0 ] || [ "$surv" = 1 ]; then log "FINAL rc=90 (primary_rc=$prim; enclosure cleanup failed => fail-closed)"; exit 90; fi
  if [ "$PUB_FAIL" != 0 ] && [ "$prim" = 0 ]; then log "FINAL rc=74 (primary_rc=0 but $PUB_FAIL required enclosure EXIT record(s) failed: evidence incomplete, not a PASS)"; exit 74; fi   # A03 (V10.1)
  exit "$prim"; }
trap finish_ctl EXIT; trap 'log SIGNAL; exit 143' TERM INT HUP
check() { if [ "$2" = 0 ]; then PASS=$((PASS+1)); log "PASS $1 $3"; else FAIL=$((FAIL+1)); log "FAIL $1 $3"; log "STOP_ON_FIRST_FAILURE $1"; exit 1; fi; }
run_sup() { # <case> <scenario>: launch the fixture through the v10 primitive; sets SUP_RC (observed) / SUP_RAW, REC, CHILD
  local left=$((AGG - ($(date +%s) - T0))); [ "$(own_budget "$left" "$CASE_BOUND" 9 6)" -ge "$CASE_BOUND" ] || { log "AGGREGATE_BOUND_HIT before $1 (left=${left}s incl. cleanup reserve)"; exit 1; }
  REC="$OUT/$TS/$1"; mkdir -p "$REC"; local att pid pub gc xr=ok
  att=$(own_attempt) || { log "$1 ENCLOSURE_ATTEMPT_FAILED"; exit 74; }; own_spawn_begin
  ( exec setsid bash -c "$OWN_GATE" own-gate "$att" $$ timeout -k 3 20 bash "$HERE/sup-under-test.v101.sh" "$2" "$REC" ) > "$REC/sup.stdout" 2>&1 < /dev/null &
  pid=$!; own_register "$pid"; own_confirm "$pid" 2 || { log "$1 ENCLOSURE_IDENTITY_UNCONFIRMED pid=$pid rc=$?"; own_signal "$pid" KILL >/dev/null; own_wait_gone "$pid" 3; exit 1; }
  own_record "$att/IDENTITY" "pid=$pid case=$1 scenario=$2 identity=[$(own_identity "$pid")]" || { log "$1 ENCLOSURE_IDENTITY_PUBLICATION_FAILED"; own_signal "$pid" KILL >/dev/null; own_wait_gone "$pid" 3; exit 74; }
  pub=$(own_adopt "$pid" "$att"); [ "$pub" = published ] || { log "$1 ENCLOSURE_PUBLICATION_FAILED $pub"; own_signal "$pid" KILL >/dev/null; own_wait_gone "$pid" 3; exit 1; }
  own_wait_gone "$pid" "$CASE_BOUND" || { log "$1 FIXTURE_OVERRAN ${CASE_BOUND}s: TERM"; own_signal "$pid" TERM >/dev/null; own_wait_gone "$pid" 3 || { own_signal "$pid" KILL >/dev/null; own_wait_gone "$pid" 3; }; }
  own_finish "$pid"; SUP_RAW="$OWN_FIN${OWN_FIN_RC:+ $OWN_FIN_RC}"; case $OWN_FIN in observed) SUP_RC=$OWN_FIN_RC;; *) SUP_RC=none;; esac   # top-level wait in this shell
  own_group_current "$pid"; case $? in 0) own_group_signal "$pid" TERM >/dev/null; own_group_wait_empty "$pid" 2 || { own_group_signal "$pid" KILL >/dev/null; own_group_wait_empty "$pid" 1; };; esac
  own_group_current "$pid"; gc=$?; [ "$OWN_FIN" = observed ] && [ "$gc" = 1 ] && own_retire "$pid"
  CHILD=$(cat "$REC/child.pid" 2>/dev/null || echo ""); [ -n "$CHILD" ] && GRAND="$GRAND $CHILD"
  own_record "$att/EXIT" "raw=$SUP_RAW group_rc=$gc child=$CHILD" || { xr=FAILED; PUB_FAIL=$((PUB_FAIL+1)); log "$1 ENCLOSURE_EXIT_RECORD_FAILED $att/EXIT (latched: publication_failures=$PUB_FAIL; final rc 74 unless a failure already governs)"; }   # A03 (V10.1)
  log "$1 sup_raw=$SUP_RAW sup_rc=$SUP_RC enclosure_group_rc=$gc child=$CHILD exit_record=$xr sup.out=[$(tr '\n' '|' < "$REC/sup.out" 2>/dev/null)] trap.out=[$(tr '\n' '|' < "$REC/trap.out" 2>/dev/null)]"
}
gone() { local i=0 s; while [ $i -lt $(( $2 * 10 )) ]; do s=$(grand_state "$1"); { [ "$s" = gone ] || [ "$s" = zombie ]; } && return 0; sleep 0.1; i=$((i+1)); done; return 1; }
ran() { ls "$REC"/attempts/*/WORKLOAD_RAN >/dev/null 2>&1; }
so() { grep -q -- "$1" "$REC/sup.out"; }; tr_() { grep -q -- "$1" "$REC/trap.out"; }
log "OWN_LAUNCH_CONTROLS_START own=$PIN_OWN sup=$PIN_SUP control_sha256=$(h "$0") stamp=[$(own_stamp)]"
log "CANONICAL_LOCK_PATH_STAT $(stat -c 'exists mtime=%y' /home/user/workspace/execution/test-validation.lock 2>/dev/null || echo absent) (not opened, not probed)"
check C0.precondition "$( own_precondition; echo $? )" "job control off; setsid/pgrep/ps present; self pgid/sid readable"
check C0.budget "$( [ "$(own_budget 6 90 10 10)" = 0 ] && [ "$(own_budget 30 90 10 10)" = 10 ] && [ "$(own_budget 200 90 10 10)" = 90 ]; echo $? )" "own_budget arithmetic"
check C0.finish_subshell_named "$( r=$(own_finish 1; echo "$OWN_FIN"); [ "$r" = mechanism-error-subshell ]; echo $? )" "own_finish inside \$(...) reports mechanism-error-subshell, never a fabricated observed status"
# consumer wiring (static, exact bytes of the T0/setup successors in this packet)
[ "$(h "$HERE/ctl-t0-only.v101.sh")" = "$PIN_T0" ] && [ "$(h "$HERE/run-s5-setup-npm-ci.v101.sh")" = "$PIN_SETUP" ]; check CW.pins "$?" "consumer bytes are the pinned V10.1 successors"
t_trap=$(grep -n '^trap on_exit EXIT; trap' "$HERE/ctl-t0-only.v101.sh" | head -1 | cut -d: -f1); t_spawn=$(grep -n 'exec setsid bash -c "\$OWN_GATE" own-gate' "$HERE/ctl-t0-only.v101.sh" | head -1 | cut -d: -f1)
check CW.t0_traps_before_spawn "$( [ -n "$t_trap" ] && [ -n "$t_spawn" ] && [ "$t_trap" -lt "$t_spawn" ]; echo $? )" "T0: EXIT/TERM/INT/HUP traps registered (line $t_trap) before the only spawn (line $t_spawn)"
s_trap=$(grep -n '^trap on_signal TERM INT HUP; trap final_accounting EXIT' "$HERE/run-s5-setup-npm-ci.v101.sh" | head -1 | cut -d: -f1); s_spawn=$(grep -n '^setsid bash -c "\$OWN_GATE" own-gate' "$HERE/run-s5-setup-npm-ci.v101.sh" | head -1 | cut -d: -f1)
check CW.setup_traps_before_spawn "$( [ -n "$s_trap" ] && [ -n "$s_spawn" ] && [ "$s_trap" -lt "$s_spawn" ]; echo $? )" "setup: traps (line $s_trap) before the only spawn (line $s_spawn)"
check CW.no_subshell_finish "$( ! grep -Eq '\$\(own_finish|own_finish [^;|]*\|[^|]' "$HERE/ctl-t0-only.v101.sh" "$HERE/run-s5-setup-npm-ci.v101.sh" "$HERE/sup-under-test.v101.sh"; echo $? )" "no own_finish call inside \$(...) or a pipe in consumers or fixture (this driver's C0 probe is the only deliberate subshell call)"
check CW.identity_before_adopt "$( for f in ctl-t0-only.v101.sh run-s5-setup-npm-ci.v101.sh; do a=$(grep -n 'own_record "\$att/IDENTITY"\|own_record "\$ATT/IDENTITY"' "$HERE/$f" | head -1 | cut -d: -f1); b=$(grep -n 'own_adopt "\$pid" "\$att"\|own_adopt "\$CUR_PID" "\$ATT"' "$HERE/$f" | head -1 | cut -d: -f1); [ -n "$a" ] && [ -n "$b" ] && [ "$a" -le "$b" ] || exit 1; done; echo $? )" "both consumers publish IDENTITY (checked) on or before the adoption line"
check CW.stamp_after_start "$( a=$(grep -n '^echo "\$(ts) START pid=' "$HERE/run-s5-setup-npm-ci.v101.sh" | cut -d: -f1); b=$(grep -n 'OWN_STAMP \$(own_stamp)' "$HERE/run-s5-setup-npm-ci.v101.sh" | cut -d: -f1); [ -n "$a" ] && [ -n "$b" ] && [ "$a" -lt "$b" ]; echo $? )" "setup OWN_STAMP is appended after the START record creation (not truncated)"
run_sup C1 plain
check C1.adopted_and_ran "$( [ "$SUP_RC" = 0 ] && so 'adoption=published state=released' && ran && so "REAPED pid=$CHILD how=group" && so 'reap_rc=0 group_current_rc=1' && so "retired pid=$CHILD" && gone "$CHILD" 1; echo $? )" "plain: identity published, adopted, workload released, reaped by group, cleanup rc 0, session empty, authority retired"
run_sup C2 natural-exit
check C2.observed_exit "$( [ "$SUP_RC" = 0 ] && so 'finish raw=observed 0 ' && ran && so "retired pid=$CHILD"; echo $? )" "natural exit: in-shell wait observed actual 0; retired"
run_sup C3 no-ack
check C3.no_workload "$( [ "$SUP_RC" = 2 ] && so 'confirm_rc=0' && so 'adoption=not-attempted state=never-released' && so 'raw=observed 75 workload_ran=no' && ! ran; echo $? )" "no ack: gate expired with actual 75; no workload"
run_sup C4 stale-adopt
check C4.stale_refused "$( [ "$SUP_RC" = 2 ] && so 'raw=observed 75 workload_ran=no' && ! ran; echo $? )" "stale/foreign ADOPT content refused by the child: actual 75; no workload"
run_sup C5 write-fail
chmod u+w "$REC"/attempts/* 2>/dev/null
check C5.publication_failure "$( [ "$SUP_RC" = 2 ] && so 'adoption=identity-publication-failed state=never-released' && so 'workload_ran=no' && ! ran; echo $? )" "unwritable attempt dir: pre-release IDENTITY publication fails BEFORE release; no workload"
run_sup C5b identity-pub-fail
check C5b.identity_pub_failure "$( [ "$SUP_RC" = 2 ] && so 'adoption=identity-publication-failed state=never-released' && ! ran && ! [ -e "$REC"/attempts/*/ADOPT ]; echo $? )" "IDENTITY record blocked (path is a directory): never released, ADOPT never written"
run_sup C5c post-release-fail
chmod u+w "$REC/post" 2>/dev/null
check C5c.post_release_cancel "$( [ "$SUP_RC" = 2 ] && so 'state=released' && so 'post-release publication failed -> cancel' && so 'refused state=released-then-cancelled' && so 'workload_ran=YES' && so 'reap_rc=0 census_rc=0' && gone "$CHILD" 1; echo $? )" "post-release record failure: truthfully released-then-cancelled, owned cleanup performed, nonzero"
run_sup C6 never-setsid
check C6.caller_decoy "$( [ "$SUP_RC" = 2 ] && so 'confirm_rc=2' && so "decoy=$(cut -d' ' -f2 "$REC/sup.pid_pgid") " && so 'refused state=never-released signal=pid' && ! ran && gone "$CHILD" 1; echo $? )" "child in caller group: decoy recorded, identity refused, pid-only signal, no workload, fixture not self-killed"
run_sup C7 delayed-setsid
check C7.acknowledged_decoy "$( [ "$SUP_RC" = 0 ] && so "decoy-observed pgid=$(cut -d' ' -f2 "$REC/sup.pid_pgid") self" && so 'confirm_rc=0' && so 'adoption=published state=released' && ran && so 'reap_rc=0'; echo $? )" "held in caller group until the decoy was OBSERVED, then confirmed, adopted, released, reaped"
run_sup C8 interrupt-afterfork
check C8.pending_fork_reaped "$( [ "$SUP_RC" = 143 ] && tr_ 'phase=spawning' && tr_ 'registered=\[\]' && [ -n "$CHILD" ] && tr_ "REAPED pid=$CHILD how=" && tr_ 'reap_rc=0' && gone "$CHILD" 1 && ! ran; echo $? )" "TERM between fork and register: phase-bound \$! (== recorded child) reaped; child gone; no workload"
run_sup C9 interrupt-adopting
check C9.registered_reaped "$( [ "$SUP_RC" = 143 ] && tr_ "REAPED pid=$CHILD" && tr_ 'reap_rc=0' && ! ran && gone "$CHILD" 1; echo $? )" "TERM after register before adopt: reaped, no workload"
run_sup C10 pre-spawn-stale
check C10.no_stale_signal "$( [ "$SUP_RC" = 143 ] && tr_ 'phase=spawning' && tr_ "bang=$CHILD " && ! grep -Eq 'REAPED|SURVIVOR' "$REC/trap.out" && tr_ "retired=\[ *$CHILD\]" && tr_ 'reap_rc=0'; echo $? )" "pre-spawn TERM with \$! == retired child: nothing signalled"
run_sup C11 leader-first-exit
check C11.descendants "$( [ "$SUP_RC" = 0 ] && so 'finish raw=observed 0 ' && grep -Eq "GROUP_REAPED pgid=$CHILD how=group:[0-9]+\+KILL:group:[0-9]+" "$REC/sup.out" && so 'reap_rc=0 group_current_rc=1'; echo $? )" "leader exited after grandchild acknowledged its TERM-ignore; session escalated to KILL; verified empty"
run_sup C12 term-ignoring
check C12.kill_path "$( [ "$SUP_RC" = 0 ] && grep -Eq "REAPED pid=$CHILD how=group:?[0-9]*\+KILL:group" "$REC/sup.out" && so 'reap_rc=0'; echo $? )" "TERM-ignoring leader (marker after ignore): bounded grace then KILL"
run_sup C13 reuse-refusal
check C13.retired_refused "$( [ "$SUP_RC" = 0 ] && grep -Eq 'retired-signal=(gone|notchild) nonchild-signal=notchild retired-group=refused alive_retired=no retire-live-refused=yes' "$REC/sup.out" && so 'census_rc=0'; echo $? )" "retired pid / non-child pid / retired group refused; retiring a live child refused"
run_sup C14 timeout
check C14.budget_term "$( [ "$SUP_RC" = 0 ] && so 'how=budget-TERM' && so 'finish raw=observed 143 ' && so 'reap_rc=0'; echo $? )" "budget exceeded: group TERM, actual 143 observed by in-shell wait, cleanup rc 0"
log "ALL_CASES_DONE pass=$PASS fail=$FAIL"
