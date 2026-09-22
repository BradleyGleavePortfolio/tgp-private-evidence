#!/usr/bin/env bash
# OP88-S5-V8 deterministic no-network controls for OWN-BLOCK v8 (NOT EXECUTED by the builder; separate grant required).
# Drives sup-under-test.sh with FAKE children (sleep) — no Jest, node_modules, worktree, npm, DB, network or canonical lock.
# Each case is bounded by `timeout -k 3 15`; aggregate bound 90 s; first unexpected result stops (owned pid cleanup of fixtures).
# Invocation (when granted): cd /home/user/workspace/execution/op88/s5-v8-t0 && S5_CTL_GRANT=granted-by-parent \
#   timeout --foreground -k 10 120 bash controls-v8-t0/ctl-own-startup.sh   (120 + 10 = nominal allowance, not a completion attestation)
# Outputs: $S5_V8_OUT (default <packet>/control-results)/own-startup-<UTC>.log and per-case record dirs.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; PKT="$(cd "$HERE/.." && pwd)"
[ "${S5_CTL_GRANT:-}" = "granted-by-parent" ] || { echo "REFUSE: S5_CTL_GRANT=granted-by-parent not set"; exit 2; }
PIN_OWN=cc8346cdf298922dedc5ea3f7dfed538d3aec16be87e2c085ae8b7a89eaeba9c; PIN_SUP=9dc308ab1439479030ee219ce29fe9596612b0adcc8d19dd19613525ef6f50b4
h() { sha256sum "$1" | cut -c1-64; }
[ "$(h "$PKT/own-block-v8.sh")" = "$PIN_OWN" ] || { echo "REFUSE: own-block-v8.sh hash != $PIN_OWN"; exit 2; }
[ "$(h "$HERE/sup-under-test.sh")" = "$PIN_SUP" ] || { echo "REFUSE: sup-under-test.sh hash != $PIN_SUP"; exit 2; }
OUT="${S5_V8_OUT:-$PKT/control-results}"; TS=$(date -u +%Y%m%dT%H%M%SZ); mkdir -p "$OUT/$TS"; LOG="$OUT/own-startup-$TS.log"
T0=$(date +%s); AGG=90; PASS=0; FAIL=0; FIXTURE_PIDS=""
log() { echo "$(date -u +%FT%TZ) $*" | tee -a "$LOG"; }
. "$PKT/own-block-v8.sh"   # for own_alive/own_budget in the control itself
cleanup_fixtures() { local p; for p in $FIXTURE_PIDS; do own_alive "$p" && { kill -TERM "$p" 2>/dev/null; sleep 0.3; own_alive "$p" && kill -KILL "$p" 2>/dev/null; log "FIXTURE_CLEANUP pid=$p (recorded child pid, never by name)"; }; done; }
trap 'cleanup_fixtures; log "SUMMARY pass=$PASS fail=$FAIL aggregate_elapsed=$(( $(date +%s) - T0 ))s log=$LOG"' EXIT
check() { if [ "$2" = 0 ]; then PASS=$((PASS+1)); log "PASS $1 $3"; else FAIL=$((FAIL+1)); log "FAIL $1 $3"; log "STOP_ON_FIRST_FAILURE $1"; exit 1; fi; }
run_sup() { # <case> <mode> <scenario> -> SUP_RC, REC
  local left=$((AGG - ($(date +%s) - T0))); [ "$left" -gt 18 ] || { log "AGGREGATE_BOUND_HIT before $1"; exit 1; }
  REC="$OUT/$TS/$1"; mkdir -p "$REC"
  timeout -k 3 15 bash "$HERE/sup-under-test.sh" "$2" "$3" "$REC" > "$REC/sup.stdout" 2>&1 < /dev/null; SUP_RC=$?
  CHILD=$(cat "$REC/child.pid" 2>/dev/null || echo ""); [ -n "$CHILD" ] && FIXTURE_PIDS="$FIXTURE_PIDS $CHILD"
  log "$1 sup_rc=$SUP_RC child=$CHILD sup.out=[$(tr '\n' '|' < "$REC/sup.out" 2>/dev/null)] trap.out=[$(tr '\n' '|' < "$REC/trap.out" 2>/dev/null)]"
}
child_gone_within() { own_wait_gone "$1" "$2"; }
log "OWN_STARTUP_CONTROLS_START own=$PIN_OWN sup=$PIN_SUP control_sha256=$(h "$0") self_pgid=$OWN_SELF_PGID"
log "CANONICAL_LOCK_PATH_STAT $(stat -c 'exists mtime=%y' /home/user/workspace/execution/test-validation.lock 2>/dev/null || echo absent) (not opened, not probed)"
# C0 budget arithmetic (pure)
check C0.budget "$( [ "$(own_budget 6 90 10 10)" = 0 ] && [ "$(own_budget 30 90 10 10)" = 10 ] && [ "$(own_budget 200 90 10 10)" = 90 ] && [ "$(own_budget 25 90 10 10)" = 5 ]; echo $? )" "own_budget: 6->0 (refuse), 30->10, 200->90 (cap), 25->5; budget+grace+reserve never exceeds remaining"
# C1 predecessor pattern under startup interruption: child SURVIVES (demonstrates the A-02 / SETUP-01 hole), then owned pid cleanup
run_sup C1pred pred interrupt
check C1pred.rc143 "$( [ "$SUP_RC" = 143 ]; echo $? )" "predecessor supervisor exited 143 from its TERM trap"
check C1pred.child_survives "$( own_alive "$CHILD"; echo $? )" "predecessor trap had OWNED_PGIDS empty -> fake child pid=$CHILD still alive (the inherited hole, reproduced)"
check C1pred.trap_owned_empty "$( grep -q 'pred-trap owned=\[\]' "$REC/trap.out"; echo $? )" "trap saw an empty owned list"
kill -TERM "$CHILD" 2>/dev/null; check C1pred.fixture_cleanup "$( child_gone_within "$CHILD" 3; echo $? )" "control cleaned its own fixture child by recorded pid"
# C1 v8 under the same deterministic interruption: registered pid reaped, no survivor
run_sup C1v8 v8 interrupt
check C1v8.rc143 "$( [ "$SUP_RC" = 143 ]; echo $? )" "v8 supervisor exited 143 from its TERM trap"
check C1v8.child_reaped "$( child_gone_within "$CHILD" 3; echo $? )" "v8 trap reaped the registered child pid=$CHILD although confirmation had not happened"
check C1v8.reap_record "$( grep -q "REAPED pid=$CHILD" "$REC/trap.out"; echo $? )" "trap record names the reaped registered pid"
# C2 caller-group decoy: child stays in the caller group for ~1 s then becomes its own session leader
run_sup C2pred pred decoy-delayed
check C2pred.would_target_self "$( grep -q 'would_target_self=YES' "$REC/sup.out"; echo $? )" "predecessor 0.2 s sample selected the supervisor's OWN pgid as signal target (decoy adopted; not fired by the fixture)"
child_gone_within "$CHILD" 3 || kill -KILL "$CHILD" 2>/dev/null
run_sup C2v8 v8 decoy-delayed
check C2v8.rc0 "$( [ "$SUP_RC" = 0 ]; echo $? )" "v8 supervisor completed (not self-signalled) rc 0"
check C2v8.confirmed_after_decoy "$( grep -q 'confirm_rc=0' "$REC/sup.out" && grep -Eq "decoy=[0-9]+" "$REC/sup.out"; echo $? )" "v8 observed the caller-group decoy, refused it, and confirmed the child once pgid==sid==pid"
check C2v8.group_reap "$( grep -q "REAPED pid=$CHILD how=group" "$REC/sup.out" && child_gone_within "$CHILD" 3; echo $? )" "confirmed own-session leader reaped by group signal; child gone"
# C2b child that never leaves the caller group: v8 must refuse identity, signal pid-only, never the group
run_sup C2bv8 v8 decoy-never
check C2bv8.rc2 "$( [ "$SUP_RC" = 2 ]; echo $? )" "v8 supervisor refused an unconfirmed identity with rc 2 (and was not killed by its own signal)"
check C2bv8.pid_only "$( grep -q 'confirm_rc=2' "$REC/sup.out" && grep -q 'identity-refused signal=pid' "$REC/sup.out" && child_gone_within "$CHILD" 3; echo $? )" "unconfirmed child signalled pid-only (never a group signal); child gone"
# C3 TERM-ignoring confirmed child: bounded TERM grace then KILL, no survivor, no unconditional wait
run_sup C3v8 v8 term-ignoring
check C3v8.kill_path "$( [ "$SUP_RC" = 0 ] && grep -Eq "REAPED pid=$CHILD how=group\+KILL:group" "$REC/sup.out" && child_gone_within "$CHILD" 3; echo $? )" "TERM ignored -> bounded grace -> KILL -> child gone within bound"
# C4 plain confirmed child: positive path
run_sup C4v8 v8 plain
check C4v8.positive "$( [ "$SUP_RC" = 0 ] && grep -q 'confirm_rc=0' "$REC/sup.out" && grep -q "REAPED pid=$CHILD how=group" "$REC/sup.out"; echo $? )" "plain setsid child confirmed and reaped by group signal (a transient pre-setsid decoy observation is timing-dependent and not asserted)"
log "ALL_CASES_DONE pass=$PASS fail=$FAIL"
