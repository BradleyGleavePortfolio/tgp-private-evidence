#!/usr/bin/env python3
"""S4 R6 V4 — field-level acceptance predicates for the safety controls.

usage: control-predicates-v4.py <scenario> <run_dir> <launcher_exit>
Reads SUPERVISOR_RECORD.json and (when present) EXIT_RECORD.json and prints every checked field.
Exit 0 only if ALL predicates for the scenario hold; exit 1 otherwise (first control mismatch stops
the driver). Exit codes alone are never sufficient: each control names the record facts that
distinguish the intended behaviour from an unrelated failure with the same exit.
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

# common: the supervisor record must exist and be parsed on EVERY path (A-02/F-02)
want("supervisor_record_parsed", isinstance(sup, dict) and "_unparseable" not in sup, True)
if isinstance(sup, dict) and "_unparseable" not in sup:
    want("supervisor.kind", sup.get("kind"), "CONTROL")
    want("supervisor.scenario", sup.get("scenario"), scenario)
    want("supervisor.launcher_exit_matches_observed", sup.get("launcher_exit"), launcher_exit)
    want("supervisor.survivors_after_kill_empty", sup.get("owned_session", {}).get("survivors_after_kill"), [])
    L = sup.get("lease", {})
    want("lease.kind is the PRIVATE control lease", L.get("kind"), "private-held-by-launcher")
    want("lease.path is under v4/control-runs (never canonical)", str(L.get("path", "")).endswith("/v4/control-runs/.private-control-lease.lock"), True)
    want("lease.held_by_launcher", L.get("held_by_launcher"), True)
    want("lease.released_at_launcher_exit (no quarantine)", L.get("released_at_launcher_exit"), True)
    want("lease.quarantine_holder_pid absent", L.get("quarantine_holder_pid"), None)
    want("bounds.worst_case_formula recorded", sup.get("bounds", {}).get("worst_case_formula"), "outer+grace+confirm+post_exit_reap+publish+2")
    r = sup.get("runner", {})
    s = sup.get("owned_session", {})
    b = sup.get("bounds", {})
    if scenario == "nested-orphan-after-exit":
        want("overall", sup.get("overall"), "SUCCESS"); want("launcher_exit", launcher_exit, 0)
        want("runner.exit", r.get("exit"), 0); want("runner.exit_confirmed", r.get("exit_confirmed"), True)
        want("runner.handshake_ok", r.get("handshake_ok"), True)
        want("runner.sentinel", r.get("sentinel"), True)
        want("supervisor.reaped_by_supervisor_empty (runner reaped its own step orphan)", s.get("reaped_by_supervisor"), [])
        want("exit_record_parsed", isinstance(rec, dict) and "_unparseable" not in rec, True)
        if isinstance(rec, dict) and rec.get("steps"):
            st = rec["steps"][0]
            want("step.id", st.get("step"), "C-nested-orphan")
            want("step.exit", st.get("exit"), 0)
            want("step.owned_orphans_found (nested timeout group seen by session census)", st.get("owned_orphans_found"), 1)
            want("step.orphans_reaped_verified", st.get("orphans_reaped_verified"), True)
            want("record.result", rec.get("result"), "SUCCESS")
            want("record.cleanup.exit", rec.get("cleanup", {}).get("exit"), 0)
        reaps = open(os.path.join(run_dir, "reaps.log")).read() if os.path.exists(os.path.join(run_dir, "reaps.log")) else ""
        want("reaps.log shows TERM-immune orphan needed KILL path (found=1 then verified)", ("found=1" in reaps) and ("session verified empty" in reaps), True)
    elif scenario == "live-step-interrupt":
        want("overall", sup.get("overall"), "TIMEOUT"); want("launcher_exit", launcher_exit, 124)
        want("bounds.timed_out", b.get("timed_out"), True)
        want_in("owned_session.signalled", s.get("signalled"), ["TERM", "TERM+KILL"])
        want("members_at_deadline_nonempty (live step group was in the session)", len(s.get("members_at_deadline", [])) >= 2, True)
        want("runner.exit_confirmed", r.get("exit_confirmed"), True)
        want_in("runner.exit (signal-terminated primary or latched exit)", r.get("exit"), [124, 137, 143])
        want("runner.exit_record_present (record still written after interruption)", r.get("exit_record_present"), True)
        if isinstance(rec, dict) and "_unparseable" not in rec:
            want("record.result", rec.get("result"), "FAILED")
            want("record.first_failure.step is the live step (primary), not the SIGNAL block", rec.get("first_failure", {}).get("step"), "C-live-step")
            want_in("record.first_failure.observed_exit", rec.get("first_failure", {}).get("observed_exit"), [124, 137, 143])
            blocks = rec.get("blocks", [])
            want("record.blocks[0] is the step's own failure", blocks[0].startswith("C-live-step") if blocks else None, True)
            want("record.blocks[1] is the secondary SIGNAL_TERM block", blocks[1].startswith("SIGNAL_TERM") if len(blocks) > 1 else None, True)
            want("steps[0].signal_during_step recorded", rec["steps"][0].get("signal_during_step") if rec.get("steps") else None, "TERM")
    elif scenario == "predicate-rc0":
        want("overall", sup.get("overall"), "RUNNER_NONZERO"); want("launcher_exit", launcher_exit, 89)
        want("runner.exit", r.get("exit"), 89)
        want("exit_record_parsed", isinstance(rec, dict) and "_unparseable" not in rec, True)
        if isinstance(rec, dict) and "_unparseable" not in rec:
            ff = rec.get("first_failure", {})
            want("record.result", rec.get("result"), "FAILED")
            want("record.first_failure.step", ff.get("step"), "C-expected-negative")
            want("record.first_failure.validation_exit", ff.get("validation_exit"), 89)
            want("record.first_failure.observed_exit retained as 0", ff.get("observed_exit"), 0)
            want("step.status", rec["steps"][0].get("status") if rec.get("steps") else None, "EXIT_0")
    elif scenario == "record-without-sentinel":
        want("overall", sup.get("overall"), "FAILED_PUBLICATION"); want("launcher_exit", launcher_exit, 7)
        want("runner.exit", r.get("exit"), 0)
        want("runner.exit_record_result (parsed SUCCESS record exists)", r.get("exit_record_result"), "SUCCESS")
        want("runner.sentinel absent", r.get("sentinel"), False)
        want("sentinel file absent", sentinel, False)
        want("runner.handshake_ok", r.get("handshake_ok"), True)
    elif scenario == "lease-held-by-supervisor":
        want("overall", sup.get("overall"), "SUCCESS"); want("launcher_exit", launcher_exit, 0)
        want("runner.exit", r.get("exit"), 0); want("runner.handshake_ok", r.get("handshake_ok"), True)
        want("exit_record_parsed", isinstance(rec, dict) and "_unparseable" not in rec, True)
        if isinstance(rec, dict) and "_unparseable" not in rec and rec.get("steps"):
            st = rec["steps"][0]
            want("step.id", st.get("step"), "C-lease-outside-probe")
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
    else:
        checks.append(("known_scenario", scenario, "known", False))

ok_all = all(c[3] for c in checks)
for name, actual, expected, ok in checks:
    print(f"{'OK  ' if ok else 'MISS'} {name}: actual={actual!r} expected={expected!r}")
print(f"PREDICATES {scenario}: {'ALL_OK' if ok_all else 'MISMATCH'} ({sum(c[3] for c in checks)}/{len(checks)})")
sys.exit(0 if ok_all else 1)
