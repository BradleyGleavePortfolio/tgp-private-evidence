#!/usr/bin/env bash
# S5 R4 control v4 (destroy driver successor): fail-closed destroy (A-03). NOT EXECUTED by the builder. Requires
# S5_CTL_GRANT=granted-by-parent. Budget: <= 30 s wall. Everything is a fake cluster directory under the
# control root; the real /home/user/pg17 is never referenced (and does not exist in this sandbox).
#   D0  PREDECESSOR (frozen checkpoint-5 s5-fixture.sh, one-line PG17_HOME derivation): destroy with a
#       failing stop prints S5_FIXTURE_DESTROY_OK and REMOVES the directory while the fake postmaster is
#       still alive. This is the frozen defect reproduced; the control asserts that failing behaviour.
#   D1  candidate: stop fails -> DESTROY_REFUSED rc 4, directory retained, runner quarantines the lane.
#   D2  candidate: already stopped, removal fails (read-only parent) -> DESTROY_FAILED rc 5, no OK line.
#   D3  candidate: no confirmation variable -> runner refuses rc 2 before any child runs.
#   D4  candidate: already stopped, marker present, confirmed -> DESTROY_OK rc 0, directory absent.
# v4 (distinct successor of controls-v3/ctl-destroy.sh; shares the UNCHANGED v3 lib): parent preparation
# finding — D0 writes $LOGS/D0-predecessor-destroy.out before any derived runner stage has created
# $CR/X/s5-r4/logs. Added: private output-directory precondition (create + writability check) before D0;
# refuses (rc 2) if the directory cannot be created inside the control root. No other change.
source "$(dirname "${BASH_SOURCE[0]}")/../controls-v3/lib.sh"
control_preconditions
make_control_root
trap 'control_cleanup' EXIT
S="$CR/X/s5-r4"; LOGS="$S/logs"; DATA="$CR/pg17/clusters/s5"
case "$LOGS" in "$CR"/*) ;; *) log "REFUSE: private LOGS $LOGS is not inside the control root $CR"; exit 2;; esac
mkdir -p "$LOGS" && [ -w "$LOGS" ] && : > "$LOGS/.ctl-destroy-v4-writable" || { log "REFUSE: cannot create/write private output dir $LOGS"; exit 2; }
log "PRIVATE_LOGS_READY $LOGS"

fake_marked_cluster() { mkdir -p "$DATA"; echo 17 > "$DATA/PG_VERSION"; printf "# fake\ncluster_name = 's5-disposable-pg17'\n" > "$DATA/postgresql.conf"; }
fake_live_postmaster() { setsid sleep 3600 </dev/null >/dev/null 2>&1 & echo "$!" > "$DATA/postmaster.pid"; echo "$!" >> "$CR/scenario/fake-postmasters"; }
fake_runner_parent() { # a live process whose cmdline contains run-proof.sh, so the standalone-fixture guard passes for D0
  bash -c 'exec -a run-proof.sh sleep 600' </dev/null >/dev/null 2>&1 & FAKE_RUNNER=$!; echo "$FAKE_RUNNER" >> "$CR/scenario/fake-postmasters"; sleep 0.2
}

# ---- D0: predecessor fixture, failing stop, live fake postmaster.
derive_fixture "$PRED_FIXTURE" "$S/pred-s5-fixture.sh"
fake_marked_cluster; fake_live_postmaster; pm=$(cat "$DATA/postmaster.pid"); echo fail > "$CR/scenario/pg_ctl_stop"; fake_runner_parent
out="$( cd "$S" && S5_RUNNER_PID=$FAKE_RUNNER bash "$S/pred-s5-fixture.sh" destroy 2>&1 )"; rc=$?
echo "$out" > "$LOGS/D0-predecessor-destroy.out"
check D0.defect "$( [ "$rc" = 0 ] && grep -q S5_FIXTURE_DESTROY_OK <<<"$out" && [ ! -e "$DATA" ] && kill -0 "$pm" 2>/dev/null; echo $? )" "PREDECESSOR: rc=$rc, printed DESTROY_OK and removed the directory while fake postmaster $pm is still alive (frozen defect reproduced; this is the FAILING behaviour)"
kill -TERM "$pm" 2>/dev/null; kill -TERM "$FAKE_RUNNER" 2>/dev/null

# ---- D1: candidate via derived runner, stop fails.
fake_marked_cluster; fake_live_postmaster; pm=$(cat "$DATA/postmaster.pid"); echo fail > "$CR/scenario/pg_ctl_stop"
run_derived destroy G2_PG17_DESTROY_CONFIRM="destroy:$DATA"; rc=$?
E="$(latest exit-destroy-)"; F="$(latest fixture-)"
check D1.rc "$( [ "$rc" = 4 ]; echo $? )" "candidate destroy rc=$rc with failing stop (expected 4)"
check D1.refused "$( grep -q 'DESTROY_REFUSED: stop rc=1 and postmaster pid' "$F" && ! grep -q S5_FIXTURE_DESTROY_OK "$F"; echo $? )" "DESTROY_REFUSED recorded, no DESTROY_OK"
check D1.retained "$( [ -d "$DATA" ] && [ -f "$DATA/postgresql.conf" ] && kill -0 "$pm" 2>/dev/null; echo $? )" "directory retained; fake postmaster untouched by removal"
check D1.quarantine "$( [ -d "$S/QUARANTINE" ] && [ "$(exit_field "$E" QUARANTINE)" = yes ]; echo $? )" "runner quarantined the lane (live postmaster after refused destroy)"
kill -TERM "$pm" 2>/dev/null; rm -f "$DATA/postmaster.pid"; rm -rf "$S/QUARANTINE"; echo ok > "$CR/scenario/pg_ctl_stop"

# ---- D2: candidate, already stopped, removal fails (parent directory not writable).
sleep 1.1; fake_marked_cluster; chmod 555 "$CR/pg17/clusters"
run_derived destroy G2_PG17_DESTROY_CONFIRM="destroy:$DATA"; rc=$?
F="$(latest fixture-)"
chmod 755 "$CR/pg17/clusters"
check D2.rc "$( [ "$rc" = 5 ]; echo $? )" "candidate destroy rc=$rc when removal fails (expected 5)"
check D2.lines "$( grep -q S5_FIXTURE_DESTROY_ALREADY_STOPPED "$F" && grep -q 'DESTROY_FAILED' "$F" && ! grep -q S5_FIXTURE_DESTROY_OK "$F"; echo $? )" "ALREADY_STOPPED then DESTROY_FAILED; no DESTROY_OK"
check D2.retained "$( [ -d "$DATA" ]; echo $? )" "directory retained after failed removal"

# ---- D3: candidate without the confirmation variable (marked cluster re-created; D2 removed its contents).
sleep 1.1; fake_marked_cluster; run_derived destroy; rc=$?
R="$(latest run-destroy-)"
check D3.rc "$( [ "$rc" = 2 ] && grep -q 'destroy requires G2_PG17_DESTROY_CONFIRM' "$R"; echo $? )" "destroy without confirmation refused rc=$rc before any child"
check D3.no_child "$( ! grep -q 'CMD ' "$R"; echo $? )" "no fixture child was started"
check D3.retained "$( [ -f "$DATA/postgresql.conf" ]; echo $? )" "directory and marker retained"

# ---- D4: candidate, already stopped, marker present, confirmed.
sleep 1.1; run_derived destroy G2_PG17_DESTROY_CONFIRM="destroy:$DATA"; rc=$?
E="$(latest exit-destroy-)"; F="$(latest fixture-)"
check D4.rc "$( [ "$rc" = 0 ] && [ "$(exit_field "$E" PROOF_EXIT)" = 0 ]; echo $? )" "confirmed destroy of a stopped marked cluster rc=$rc (expected 0)"
check D4.ok "$( grep -q S5_FIXTURE_DESTROY_ALREADY_STOPPED "$F" && grep -q 'S5_FIXTURE_DESTROY_OK' "$F" && [ ! -e "$DATA" ]; echo $? )" "DESTROY_OK only after verified absence"

# ---- D5: fixture derivation integrity (candidate + predecessor derived copies differ only in PG17_HOME).
check D5.derivation "$( for d in "$S/s5-fixture.sh.derivation.diff" "$S/pred-s5-fixture.sh.derivation.diff"; do [ "$(grep -c '^[<>]' "$d")" = 2 ] && grep '^[<>]' "$d" | grep -q '^[<>] PG17_HOME=' || exit 1; done; echo 0 )" "both derived fixtures differ from their sources only in the PG17_HOME line"
summary
