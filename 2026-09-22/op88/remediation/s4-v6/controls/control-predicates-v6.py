#!/usr/bin/env python3
"""S4 R6 V6 — field-level acceptance predicates for the safety controls.

usage: control-predicates-v6.py <scenario> <run_dir> <launcher_exit>
Reads SUPERVISOR_RECORD.json and (when present) EXIT_RECORD.json and prints every checked field.
Exit 0 only if ALL predicates for the scenario hold; exit 1 otherwise (first control mismatch stops
the driver). Exit codes alone are never sufficient: each control names the record facts that
distinguish the intended behaviour from an unrelated failure with the same exit.

V5 changes versus V4 (frozen review S4-V4-A-05; uutils note):
 * Fail-closed mandatory evidence: wherever a scenario asserts EXIT_RECORD/step facts, the record must be
   locally PARSED and `steps` must be a nonempty list of objects — recorded as MISS otherwise, never skipped.
 * Signal-terminated step exits accept the INSTALLED implementation: rust-coreutils 0.8.0 `timeout` returns
   the raw child signal number (15 for TERM) when its child dies of a signal, GNU would return 143; the
   launcher's own deadline gives 124; KILL 137. Set = {15, 124, 137, 143}. The actual value is printed and
   stamped by the run (expectation-setting, not GNU inference).
 * New scenario live-step-double-term (S4-V4-A-01 discriminator): >= 2 SIGNAL_TERM blocks, all after the
   step's own primary block, one recorded 'while latching' (the deferred zone).
 * bounds.worst_case_formula updated to the V6 launcher formula (readers + quarantine verification included).

V6 changes versus V5 (frozen review S4-V5-A-03/A-05 lineage):
 * Formula string follows the V6 launcher (2*quarantine_verify + 16*census); bounds.census_s recorded.
 * Every control requires a VERIFIED standby holder that was RELEASED at exit (lease.standby_holder_verified /
   standby_holder_released true), no quarantine attempted (quarantine_ok None, quarantine_receipt_ok None,
   self_hold false) and a verified-EMPTY final census (owned_session.census_state == "EMPTY"; UNKNOWN is a MISS).
"""
import json, os, sys

scenario, run_dir, launcher_exit = sys.argv[1], sys.argv[2], int(sys.argv[3])

def load(name):
    p = os.path.join(run_dir, name)
    if not os.path.exists(p):
        return None
    try:
        return json.load(open(p))
    except Exception as e:  # unparseable is a fact, not an exception
        return {"_unparseable": str(e)}

sup = load("SUPERVISOR_RECORD.json")
rec = load("EXIT_RECORD.json")
sentinel = os.path.exists(os.path.join(run_dir, "RUN_COMPLETE.sentinel"))
checks = []

def want(name, actual, expected):
    ok = actual == expected
    checks.append((name, actual, expected, ok))
    return ok

def want_in(name, actual, allowed):
    ok = actual in allowed
    checks.append((name, actual, f"one of {allowed}", ok))
    return ok

def parsed(d):
    return isinstance(d, dict) and "_unparseable" not in d

def steps_ok(rec, n=1):
    """S4-V4-A-05: mandatory, typed, nonempty step evidence — a MISS, never a skipped branch."""
    ok = parsed(rec) and isinstance(rec.get("steps"), list) and len(rec["steps"]) >= n and all(isinstance(x, dict) for x in rec["steps"][:n])
    want(f"record.steps is a parsed list of >= {n} step object(s) (mandatory)", ok, True)
    return ok

# signal-terminated step exits under the INSTALLED tooling (rust-coreutils 0.8.0 timeout: raw signal 15 for a
# TERM-killed child; GNU-style 143 if timeout itself is TERM-killed; 124 own deadline; 137 KILL)
SIGNAL_EXITS = [15, 124, 137, 143]

# common: the supervisor record must exist and be parsed on EVERY path (A-02/F-02)
want("supervisor_record_parsed", isinstance(sup, dict) and "_unparseable" not in sup, True)
if isinstance(sup, dict) and "_unparseable" not in sup:
    want("supervisor.kind", sup.get("kind"), "CONTROL")
    want("supervisor.scenario", sup.get("scenario"), scenario)
    want("supervisor.launcher_exit_matches_observed", sup.get("launcher_exit"), launcher_exit)
    L = sup.get("lease", {})
    QUARANTINE = scenario in ("fault-survivors-quarantine", "fault-receipt-unwritable", "fault-census-unknown")
    REFUSAL = scenario == "fault-holder-unverifiable"
    want("lease.kind is the PRIVATE control lease", L.get("kind"), "private-held-by-launcher")
    want("lease.path is under v6/control-runs (never canonical)", str(L.get("path", "")).endswith("/v6/control-runs/.private-control-lease.lock"), True)
    want("lease.held_by_launcher", L.get("held_by_launcher"), True)
    want("bounds.worst_case_formula recorded", sup.get("bounds", {}).get("worst_case_formula"), "outer+grace+confirm+post_exit_reap+publish+2*read+2*quarantine_verify+16*census+2")
    want("bounds.phases_are_wall_clock", sup.get("bounds", {}).get("phases_are_wall_clock"), True)
    want("bounds.census_s recorded (int)", isinstance(sup.get("bounds", {}).get("census_s"), int), True)
    want("lease.holder_pid is the launcher (int)", isinstance(L.get("holder_pid"), int), True)
    want("lease.self_hold false (the self-hold fallback is not exercised by any control)", L.get("self_hold"), False)
    want("supervisor.control_fault recorded exactly as injected", sup.get("control_fault"), {"fault-survivors-quarantine": "census-members-persist", "fault-receipt-unwritable": "census-members-persist,receipt-unwritable", "fault-census-unknown": "census-unknown", "fault-holder-unverifiable": "holder-unverifiable"}.get(scenario))
    if not QUARANTINE and not REFUSAL:
        want("supervisor.survivors_after_kill_empty", sup.get("owned_session", {}).get("survivors_after_kill"), [])
        want("lease.released_at_launcher_exit (no quarantine)", L.get("released_at_launcher_exit"), True)
        want("lease.quarantine_holder_pid: the standby holder pid is recorded (int)", isinstance(L.get("quarantine_holder_pid"), int), True)
        want("lease.quarantine_ok absent (no handoff attempted)", L.get("quarantine_ok"), None)
        want("lease.quarantine_receipt_ok absent", L.get("quarantine_receipt_ok"), None)
        want("lease.standby_holder_verified (S4-V5-A-03: holder existed before anything was owned)", L.get("standby_holder_verified"), True)
        want("lease.standby_holder_released at exit (identity-checked, after verified-empty census)", L.get("standby_holder_released"), True)
        want("owned_session.census_state is verified EMPTY (UNKNOWN never counts as empty)", sup.get("owned_session", {}).get("census_state"), "EMPTY")
    elif QUARANTINE:
        # S4-V5-B-06: the REAL quarantine path ran on the private lease with injected census data.
        want("lease.released_at_launcher_exit is FALSE (exclusion retained)", L.get("released_at_launcher_exit"), False)
        want("lease.quarantine_ok (verified holder retains the lease)", L.get("quarantine_ok"), True)
        want("lease.standby_holder_verified", L.get("standby_holder_verified"), True)
        want("lease.standby_holder_released is None (never released on a quarantine path)", L.get("standby_holder_released"), None)
        want("lease.standby_holder_respawned false (standby holder still valid at quarantine time)", L.get("standby_holder_respawned"), False)
        want("lease.quarantine_holder_pid int", isinstance(L.get("quarantine_holder_pid"), int), True)
        want("lease.quarantine_holder_starttime int", isinstance(L.get("quarantine_holder_starttime"), int), True)
        want("lease.quarantine_holder_token names this run", L.get("quarantine_holder_token") == f"s4r6-quarantine-holder-{sup.get('run_id')}", True)
        want("lease.quarantine_holder_pid != launcher (a separate holder, not self-hold)", L.get("quarantine_holder_pid") != L.get("holder_pid"), True)
        receipt = os.path.exists(os.path.join(run_dir, "QUARANTINE_LEASE_HOLDER"))
        if scenario == "fault-receipt-unwritable":
            want("overall", sup.get("overall"), "QUARANTINED_RECEIPT_FAILED"); want("launcher_exit", launcher_exit, 11)
            want("lease.quarantine_receipt_ok false", L.get("quarantine_receipt_ok"), False)
            want("QUARANTINE_LEASE_HOLDER receipt ABSENT (injected)", receipt, False)
            want("lease.quarantine_failure names the receipt", "receipt could not be written" in str(L.get("quarantine_failure")), True)
        else:
            want("overall", sup.get("overall"), "QUARANTINED_SURVIVORS"); want("launcher_exit", launcher_exit, 5)
            want("lease.quarantine_receipt_ok true", L.get("quarantine_receipt_ok"), True)
            want("QUARANTINE_LEASE_HOLDER receipt present", receipt, True)
            if receipt:
                first = open(os.path.join(run_dir, "QUARANTINE_LEASE_HOLDER")).readline()
                want("receipt first line carries pid/starttime/token of the recorded holder", first.startswith(f"pid={L.get('quarantine_holder_pid')} starttime={L.get('quarantine_holder_starttime')} token={L.get('quarantine_holder_token')} "), True)
        if scenario == "fault-census-unknown":
            want("owned_session.census_state UNKNOWN:124 (injected) — treated as unresolved, never SUCCESS", sup.get("owned_session", {}).get("census_state"), "UNKNOWN:124")
            want("runner.exit 0 (workload itself succeeded; quarantine is census-driven)", sup.get("runner", {}).get("exit"), 0)
            want("bounds.timed_out false", sup.get("bounds", {}).get("timed_out"), False)
        else:
            want("owned_session.census_state MEMBERS (injected persistence)", sup.get("owned_session", {}).get("census_state"), "MEMBERS")
            want("bounds.timed_out true (live step hit the 4 s deadline)", sup.get("bounds", {}).get("timed_out"), True)
            want("owned_session.signalled TERM or TERM+KILL", sup.get("owned_session", {}).get("signalled") in ("TERM", "TERM+KILL"), True)
            want("owned_session.survivors_after_kill nonempty (injected)", len(sup.get("owned_session", {}).get("survivors_after_kill") or []) >= 1, True)
    elif REFUSAL:
        want("overall", sup.get("overall"), "STANDBY_HOLDER_FAILED"); want("launcher_exit", launcher_exit, 8)
        want("lease.standby_holder_verified false (injected never-matching token)", L.get("standby_holder_verified"), False)
        want("lease.released_at_launcher_exit true (nothing owned)", L.get("released_at_launcher_exit"), True)
        want("lease.quarantine_ok absent", L.get("quarantine_ok"), None)
        want("runner.spawned_pid absent (refused before spawn)", sup.get("runner", {}).get("spawned_pid"), None)
        want("owned_session.sid absent", sup.get("owned_session", {}).get("sid"), None)
        want("no OWNED_SID file", os.path.exists(os.path.join(run_dir, "OWNED_SID")), False)
        want("no EXIT_RECORD", rec, None)
        want("refusal text names the standby holder", "standby lease holder" in str(sup.get("refusal")), True)
    r = sup.get("runner", {})
    s = sup.get("owned_session", {})
    b = sup.get("bounds", {})
    if scenario == "nested-orphan-after-exit":
        want("overall", sup.get("overall"), "SUCCESS"); want("launcher_exit", launcher_exit, 0)
        want("runner.exit", r.get("exit"), 0); want("runner.exit_confirmed", r.get("exit_confirmed"), True)
        want("runner.handshake_ok", r.get("handshake_ok"), True)
        want("runner.sentinel", r.get("sentinel"), True)
        want("supervisor.reaped_by_supervisor_empty (runner reaped its own step orphan)", s.get("reaped_by_supervisor"), [])
        want("exit_record_parsed", parsed(rec), True)
        if steps_ok(rec):
            st = rec["steps"][0]
            want("step.id", st.get("step"), "C-nested-orphan")
            want("step.exit", st.get("exit"), 0)
            want("step.owned_orphans_found (nested timeout group seen by session census)", st.get("owned_orphans_found"), 1)
            want("step.orphans_reaped_verified", st.get("orphans_reaped_verified"), True)
            want("record.result", rec.get("result"), "SUCCESS")
            want("record.cleanup.exit", rec.get("cleanup", {}).get("exit"), 0)
        reaps = open(os.path.join(run_dir, "reaps.log")).read() if os.path.exists(os.path.join(run_dir, "reaps.log")) else ""
        want("reaps.log shows TERM-immune orphan needed KILL path (found=1 then verified)", ("found=1" in reaps) and ("session verified empty" in reaps), True)
    elif scenario in ("live-step-interrupt", "live-step-double-term"):
        want("overall", sup.get("overall"), "TIMEOUT"); want("launcher_exit", launcher_exit, 124)
        want("bounds.timed_out", b.get("timed_out"), True)
        want_in("owned_session.signalled", s.get("signalled"), ["TERM", "TERM+KILL"])
        want("members_at_deadline_nonempty (live step group was in the session)", len(s.get("members_at_deadline", [])) >= 2, True)
        want("runner.exit_confirmed", r.get("exit_confirmed"), True)
        want_in("runner.exit (signal-terminated primary or latched exit; installed uutils => 15 expected)", r.get("exit"), SIGNAL_EXITS)
        want("runner.exit_record_present (record still written after interruption)", r.get("exit_record_present"), True)
        want("exit_record_parsed (mandatory, S4-V4-A-05)", parsed(rec), True)
        if steps_ok(rec):
            want("record.result", rec.get("result"), "FAILED")
            want("record.first_failure.step is the live step (primary), not the SIGNAL block", rec.get("first_failure", {}).get("step"), "C-live-step")
            want_in("record.first_failure.observed_exit", rec.get("first_failure", {}).get("observed_exit"), SIGNAL_EXITS)
            blocks = rec.get("blocks", [])
            want("record.blocks is a nonempty list", isinstance(blocks, list) and len(blocks) >= 2, True)
            want("record.blocks[0] is the step's own failure", blocks[0].startswith("C-live-step") if blocks else None, True)
            want("record.blocks[1] is the secondary SIGNAL_TERM block", blocks[1].startswith("SIGNAL_TERM") if len(blocks) > 1 else None, True)
            n_sig = sum(1 for x in blocks if isinstance(x, str) and x.startswith("SIGNAL_TERM"))
            # The launcher's route delivers TERM twice (group pass, then per-pid pass). Bash normally coalesces
            # both into one trap run; if the step dies between the passes the second TERM lands in the metadata
            # zone and V6 truthfully records a further secondary block. Counts are therefore lower bounds; the
            # discriminating facts are blocks[0] (step) and that no SIGNAL block precedes it.
            want("record.blocks: no SIGNAL_ block precedes the step's own block", blocks[0].startswith("C-live-step") and all(x.startswith("SIGNAL_TERM") for x in blocks[1:]) if blocks else None, True)
            if scenario == "live-step-double-term":
                want("record.blocks: >= 2 SIGNAL_TERM blocks (launcher TERM + seam TERM), all after the primary (S4-V4-A-01)", n_sig >= 2, True)
                slog = open(os.path.join(run_dir, "steps", "C-live-step.log")).read() if os.path.exists(os.path.join(run_dir, "steps", "C-live-step.log")) else ""
                want("step log shows the seam fired (SEAM step-after-reap)", "SEAM step-after-reap" in slog, True)
                want("a 'while latching' secondary block exists (signal recorded in the deferred zone)", any("while latching step C-live-step" in x for x in blocks), True)
            else:
                want("record.blocks: >= 1 SIGNAL_TERM block after the primary", n_sig >= 1, True)
            want("steps[0].step is C-live-step", rec["steps"][0].get("step"), "C-live-step")
            want("steps[0].signal_during_step recorded", rec["steps"][0].get("signal_during_step"), "TERM")
            want_in("steps[0].exit is a signal termination", rec["steps"][0].get("exit"), SIGNAL_EXITS)
    elif scenario == "predicate-rc0":
        want("overall", sup.get("overall"), "RUNNER_NONZERO"); want("launcher_exit", launcher_exit, 89)
        want("runner.exit", r.get("exit"), 89)
        want("exit_record_parsed", parsed(rec), True)
        if steps_ok(rec):
            ff = rec.get("first_failure", {})
            want("record.result", rec.get("result"), "FAILED")
            want("record.first_failure.step", ff.get("step"), "C-expected-negative")
            want("record.first_failure.validation_exit", ff.get("validation_exit"), 89)
            want("record.first_failure.observed_exit retained as 0", ff.get("observed_exit"), 0)
            want("step.id", rec["steps"][0].get("step"), "C-expected-negative")
            want("step.status", rec["steps"][0].get("status"), "EXIT_0")
    elif scenario == "record-without-sentinel":
        want("overall", sup.get("overall"), "FAILED_PUBLICATION"); want("launcher_exit", launcher_exit, 7)
        want("runner.exit", r.get("exit"), 0)
        want("runner.exit_record_result (parsed SUCCESS record exists)", r.get("exit_record_result"), "SUCCESS")
        want("runner.sentinel absent", r.get("sentinel"), False)
        want("sentinel file absent", sentinel, False)
        want("runner.handshake_ok", r.get("handshake_ok"), True)
        want("exit_record_parsed (SUCCESS record exists locally)", parsed(rec) and rec.get("result") == "SUCCESS", True)
        steps_ok(rec)
    elif scenario == "lease-held-by-supervisor":
        want("overall", sup.get("overall"), "SUCCESS"); want("launcher_exit", launcher_exit, 0)
        want("runner.exit", r.get("exit"), 0); want("runner.handshake_ok", r.get("handshake_ok"), True)
        want("exit_record_parsed", parsed(rec), True)
        if steps_ok(rec):
            st = rec["steps"][0]
            want("step.id", st.get("step"), "C-lease-outside-probe")
            want("record.lock.holder is the launcher with holder_pid == supervisor lease.holder_pid (S4-V4-B-03)", (rec.get("lock", {}).get("holder"), rec.get("lock", {}).get("holder_pid")), ("launcher", L.get("holder_pid")))
            want("record.lock.path is the private lease", rec.get("lock", {}).get("path"), L.get("path"))
            want("step.status (outside flock -n refused ⇒ probe exit 3)", st.get("status"), "EXIT_3")
            want("record.result", rec.get("result"), "SUCCESS")
            want("record.first_failure.step (none: predicate satisfied)", rec.get("first_failure", {}).get("step"), None)
        pl = open(os.path.join(run_dir, "predicates.log")).read() if os.path.exists(os.path.join(run_dir, "predicates.log")) else ""
        want("predicates.log PREDICATE_OK for the lease probe", "PREDICATE_OK C-lease-outside-probe observed=3 wanted=3" in pl, True)
    elif scenario == "refuse":
        want("overall", sup.get("overall"), "RUNNER_REFUSED"); want("launcher_exit", launcher_exit, 71)
        want("runner.exit", r.get("exit"), 71); want("runner.exit_confirmed", r.get("exit_confirmed"), True)
        want("runner.handshake absent (refused before handshake)", r.get("runner_pid_handshake"), None)
        want("refusal recorded", bool(sup.get("refusal")), True)
        want("orphans_after_runner_exit_empty", s.get("orphans_after_runner_exit"), [])
        want("no EXIT_RECORD written by a refused stub", rec, None)
    elif QUARANTINE or REFUSAL:
        pass  # fault controls are fully specified in the common block above (S4-V5-B-06)
    else:
        checks.append(("known_scenario", scenario, "known", False))

ok_all = all(c[3] for c in checks)
for name, actual, expected, ok in checks:
    print(f"{'OK  ' if ok else 'MISS'} {name}: actual={actual!r} expected={expected!r}")
print(f"PREDICATES {scenario}: {'ALL_OK' if ok_all else 'MISMATCH'} ({sum(c[3] for c in checks)}/{len(checks)})")
sys.exit(0 if ok_all else 1)
