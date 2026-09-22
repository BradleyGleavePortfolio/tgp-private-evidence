#!/usr/bin/env bash
# S5 R4 control: supervisor lifecycle (A-02) and pre-live busy-session refusal (A-04) on the DERIVED
# candidate runner with fake pg_ctl/psql/jest. NOT EXECUTED by the builder. Requires
# S5_CTL_GRANT=granted-by-parent. v3 budget: <= 100 s wall. Wave-1 measured pre-live overhead of the derived
# resume stage (guard-unit + old-root + start + preflight + generate-only) = ~4 s; L1 ~7 s, L2 ~10 s (wait <= 20 s
# + reap + stop), L3 ~20 s (WORK_BUDGET 12 s + reap <= 5 s + stop), L4 3 stages ~10 s, L5 ~5 s, 1.1 s spacing;
# sequential; one fake postmaster at a time; owned pids recorded and cleaned by control_cleanup.
# Positive criteria per scenario are asserted below; a nonzero runner exit is EXPECTED in L2-L5 and is
# never turned into a pass by itself — the exit RECORD fields are what is checked.
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
control_preconditions
make_control_root
trap 'control_cleanup' EXIT
S="$CR/X/s5-r4"; LOGS="$S/logs"; LOCKLOG="$CR/X/test-validation.lock.log"; DATA="$CR/pg17/clusters/s5"

# One-time: fresh init through the derived runner (fake initdb), so resume finds a marked, stopped cluster.
run_derived init; rc=$?
check L0.init "$( [ "$rc" = 0 ] && grep -q "^cluster_name = 's5-disposable-pg17'" "$DATA/postgresql.conf"; echo $? )" "derived runner init rc=$rc created the marked fake cluster"

# ---- L1: normal resume; fake jest exits 0 after 1 s. Lock held through stop; clean exit record.
echo "1 0" > "$CR/scenario/jest"; echo ok > "$CR/scenario/pg_ctl_stop"; echo 0 > "$CR/scenario/psql_sessions"; : > "$CR/scenario/stop-observations"
run_derived resume; rc=$?
E="$(latest exit-resume-)"
check L1.rc "$( [ "$rc" = 0 ]; echo $? )" "resume rc=$rc (expected 0)"
check L1.exit "$( [ "$(exit_field "$E" PROOF_EXIT)" = 0 ] && [ "$(exit_field "$E" FIRST_RC)" = 0 ] && [ "$(exit_field "$E" STOP_RC)" = 0 ] && [ "$(exit_field "$E" DAEMON)" = none ] && [ "$(exit_field "$E" SURVIVORS)" = none ]; echo $? )" "exit record: PROOF_EXIT=0 FIRST_RC=0 STOP_RC=0 DAEMON=none SURVIVORS=none ($E)"
check L1.lock_at_stop "$( grep -q 'lock_at_stop=HELD' "$CR/scenario/stop-observations"; echo $? )" "fake pg_ctl observed the lane lock HELD during the cleanup stop"
check L1.locklog "$( [ "$(grep -c 'HOLDER=s5-r4 PURPOSE=g2-pg17-proof-resume' "$LOCKLOG")" = 1 ] && [ "$(grep -c 'RELEASE=s5-r4 stage=resume first_rc=0 rc=0 stop_rc=0 daemon=none' "$LOCKLOG")" = 1 ]; echo $? )" "exactly one HOLDER/RELEASE pair for resume"
check L1.order "$( grep -q 'PREFLIGHT_OK' "$(latest run-resume-)" && grep -q 'CMD.*generate-only' "$(latest run-resume-)" && grep -q 'CMD.*jest' "$(latest run-resume-)"; echo $? )" "stage order preflight -> generate-only -> live present"
check L1.postmaster_gone "$( [ ! -f "$DATA/postmaster.pid" ]; echo $? )" "fake postmaster pid file removed by stop"

# ---- L2: outer TERM while live runs (fake jest sleeps 300 s with a grandchild). Supervisor must
# reap the owned group, THEN stop the fixture under the still-held lock, and record first_rc=143.
echo "300 0" > "$CR/scenario/jest"; : > "$CR/scenario/stop-observations"; : > "$CR/scenario/jest.grandchildren"
sleep 1.1; prev_runs=$(ls "$LOGS"/run-resume-* 2>/dev/null | wc -l); prev_live=$(ls "$LOGS"/live-etq0-* 2>/dev/null | wc -l)
run_derived_bg resume
# v3 precondition (wave-1 CONTROL-TARGETING failure): signal only once THIS run has (a) a NEW live-etq0 log that
# already carries the fake jest grandchild marker and (b) the fake postmaster pid file present. <= 20 s wait.
live_ready=1
for i in $(seq 1 80); do
  if [ "$(ls "$LOGS"/run-resume-* 2>/dev/null | wc -l)" -gt "$prev_runs" ] && [ "$(ls "$LOGS"/live-etq0-* 2>/dev/null | wc -l)" -gt "$prev_live" ] \
     && grep -q FAKE_JEST_GRANDCHILD "$(latest live-etq0-)" 2>/dev/null && [ -f "$DATA/postmaster.pid" ] && kill -0 "$RUNNER_PID" 2>/dev/null; then live_ready=0; break; fi
  sleep 0.25
done
check L2.pre "$live_ready" "live phase reached in THIS run (new live log with grandchild marker, postmaster.pid present, runner alive) before TERM; waited $((i / 4)) s"
kill -TERM "$RUNNER_PID"; t0=$(date +%s); wait "$RUNNER_PID"; rc=$?; t1=$(date +%s)
E="$(latest exit-resume-)"
check L2.rc "$( [ "$rc" = 143 ]; echo $? )" "runner exited $rc after TERM (expected 143 = first rc preserved; cleanup succeeded so not upgraded)"
check L2.exit "$( [ "$(exit_field "$E" FIRST_RC)" = 143 ] && [ "$(exit_field "$E" SIGNALLED)" = TERM ] && [ "$(exit_field "$E" STOP_RC)" = 0 ] && [ "$(exit_field "$E" DAEMON)" = none ] && [ "$(exit_field "$E" SURVIVORS)" = none ]; echo $? )" "exit record FIRST_RC=143 SIGNALLED=TERM STOP_RC=0 DAEMON=none SURVIVORS=none ($E)"
check L2.reaped "$( grep -q 'OWNED_GROUP_REAPED' "$(latest run-resume-)"; echo $? )" "owned jest group reaped before cleanup stop"
check L2.grandchild "$( alive=0; while read -r p; do [ -n "$p" ] && kill -0 "$p" 2>/dev/null && alive=1; done < "$CR/scenario/jest.grandchildren"; [ "$alive" = 0 ]; echo $? )" "fake jest grandchild did not survive group termination"
check L2.lock_at_stop "$( grep -q 'lock_at_stop=HELD' "$CR/scenario/stop-observations"; echo $? )" "lock still HELD during the post-signal cleanup stop"
check L2.budget "$( [ $((t1 - t0)) -le 30 ]; echo $? )" "signal-to-exit took $((t1 - t0)) s (budget: reap 20 + stop <= 30)"
check L2.release_after_stop "$( r=$(grep -n 'RELEASE=s5-r4 stage=resume first_rc=143' "$LOCKLOG" | tail -1 | cut -d: -f1); [ -n "$r" ]; echo $? )" "RELEASE record written with first_rc=143 (after stop; lock release = process exit)"

# ---- L3: inner deadline. v3: WORK_BUDGET=12 s so the deadline expires INSIDE the live phase (pre-live overhead
# measured ~4 s in wave 1; guard-unit fake jest now exits in 0.2 s); fake live jest sleeps 300 s. Causality is
# asserted (L3.pre): the live CMD line must precede OWNED_WORK_DEADLINE in the same run log.
derive_runner "$CANDIDATE_RUNNER" "$S/run-proof.sh" 12 5 45
: > "$CR/scenario/stop-observations"; : > "$CR/scenario/jest.grandchildren"
sleep 1.1; t0=$(date +%s); run_derived resume; rc=$?; t1=$(date +%s)
E="$(latest exit-resume-)"
R3="$(latest run-resume-)"
check L3.pre "$( a=$(grep -n 'CMD.*rls-g2-pg17-etq0.spec.ts' "$R3" | head -1 | cut -d: -f1); b=$(grep -n 'OWNED_WORK_DEADLINE' "$R3" | head -1 | cut -d: -f1); [ -n "$a" ] && [ -n "$b" ] && [ "$a" -lt "$b" ]; echo $? )" "deadline expired inside the live phase (live CMD line precedes OWNED_WORK_DEADLINE in $R3)"
check L3.rc "$( [ "$rc" = 124 ]; echo $? )" "runner rc=$rc on inner deadline (expected 124)"
check L3.exit "$( [ "$(exit_field "$E" FIRST_RC)" = 124 ] && [ "$(exit_field "$E" STOP_RC)" = 0 ] && [ "$(exit_field "$E" DAEMON)" = none ] && [ "$(exit_field "$E" SURVIVORS)" = none ]; echo $? )" "exit record FIRST_RC=124 STOP_RC=0 DAEMON=none SURVIVORS=none"
check L3.deadline_line "$( grep -q 'OWNED_WORK_DEADLINE' "$(latest run-resume-)" && grep -q 'OWNED_GROUP_REAPED' "$(latest run-resume-)"; echo $? )" "deadline recorded and owned group reaped"
check L3.wall "$( [ $((t1 - t0)) -le 30 ]; echo $? )" "wall $((t1 - t0)) s (budget 12 + reap <= 5 + stop + records <= 30)"
check L3.lock_at_stop "$( grep -q 'lock_at_stop=HELD' "$CR/scenario/stop-observations"; echo $? )" "lock HELD during deadline cleanup stop"
derive_runner "$CANDIDATE_RUNNER" "$S/run-proof.sh" 1560 20 45

# ---- L4: failed cleanup stop. Fake pg_ctl stop returns 1 and leaves the daemon; the runner must record
# FIRST_RC=0 but PROOF_EXIT=3, DAEMON alive, write QUARANTINE, and the NEXT stage must refuse (rc 4).
echo "1 0" > "$CR/scenario/jest"; echo fail > "$CR/scenario/pg_ctl_stop"; : > "$CR/scenario/stop-observations"
sleep 1.1; run_derived resume; rc=$?
E="$(latest exit-resume-)"
check L4.rc "$( [ "$rc" = 3 ]; echo $? )" "runner rc=$rc with failed stop (expected 3: first rc 0 not hidden, cleanup failure surfaced)"
check L4.exit "$( [ "$(exit_field "$E" FIRST_RC)" = 0 ] && [ "$(exit_field "$E" PROOF_EXIT)" = 3 ] && [ "$(exit_field "$E" STOP_RC)" != 0 ] && [ "$(exit_field "$E" DAEMON)" != none ] && [ "$(exit_field "$E" QUARANTINE)" = yes ]; echo $? )" "exit record FIRST_RC=0 PROOF_EXIT=3 STOP_RC!=0 DAEMON alive QUARANTINE=yes"
check L4.quarantine_dir "$( [ -d "$S/QUARANTINE" ] && ls "$S/QUARANTINE"/*.txt >/dev/null 2>&1; echo $? )" "QUARANTINE marker written"
sleep 1.1; run_derived resume; rc=$?
check L4.refuse_next "$( [ "$rc" = 4 ] && grep -q 'lane quarantined' "$(latest run-resume-)"; echo $? )" "next stage refused rc=$rc while QUARANTINE exists"
run_derived destroy G2_PG17_DESTROY_CONFIRM="destroy:$DATA"; rc=$?
check L4.refuse_destroy "$( [ "$rc" = 4 ] && [ -d "$DATA" ]; echo $? )" "destroy refused rc=$rc under quarantine; data directory retained"
# Control-owned recovery of the fake daemon (by recorded pid), then clear the control-root quarantine.
control_cleanup_fake_daemon() { while read -r p; do [ -n "$p" ] && kill -0 "$p" 2>/dev/null && kill -TERM "$p"; done < "$CR/scenario/fake-postmasters"; rm -f "$DATA/postmaster.pid"; }
control_cleanup_fake_daemon; rm -rf "$S/QUARANTINE"; echo ok > "$CR/scenario/pg_ctl_stop"

# ---- L5: busy sessions at preflight (A-04). Fake psql reports 2 attached sessions: resume must refuse
# before generate-only/live, stop the fixture it started, and record rc 3.
echo 2 > "$CR/scenario/psql_sessions"; : > "$CR/scenario/stop-observations"
sleep 1.1; run_derived resume; rc=$?
R="$(latest run-resume-)"; E="$(latest exit-resume-)"
check L5.rc "$( [ "$rc" = 3 ]; echo $? )" "resume rc=$rc with 2 attached sessions (expected 3)"
check L5.refusal_line "$( grep -q '2 session(s) attached .* mutating stage resume refuses' "$R"; echo $? )" "explicit busy refusal recorded"
check L5.no_mutating_children "$( ! grep -q 'CMD.*generate-only' "$R" && ! grep -q 'CMD.*jest' "$R"; echo $? )" "no generate-only and no live child started after the busy snapshot"
check L5.stopped "$( [ "$(exit_field "$E" STOP_RC)" = 0 ] && [ "$(exit_field "$E" DAEMON)" = none ]; echo $? )" "fixture started by this stage was stopped (STOP_RC=0 DAEMON=none)"
echo 0 > "$CR/scenario/psql_sessions"

# ---- L6: derivation integrity — the derived runner differs from the candidate ONLY in lane constants.
check L6.derivation "$( n=$(grep -c '^[<>]' "$S/run-proof.sh.derivation.diff"); [ "$n" -le 12 ] && ! grep '^[<>]' "$S/run-proof.sh.derivation.diff" | grep -vqE '^[<>] (W|X|PG17_HOME|WORK_BUDGET|REAP_BUDGET|STOP_BUDGET)='; echo $? )" "derived runner diff limited to lane constants"
summary
