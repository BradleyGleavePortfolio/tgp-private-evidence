# S5-R4-TIER1-V2 wave 1 — first failure freeze (no retry, no repair executed)

Executed once: `S5_CTL_GRANT=granted-by-parent S5_CTL_KEEP=1 timeout --foreground -k 20 110 bash controls-v2/ctl-lifecycle.sh` at 2026-09-22T05:02:02Z–05:02:14Z. Driver rc=1. Remaining drivers (destroy, genctl, probe) NOT run. Note: an earlier shell invocation at ~05:01 never started the driver (stdout redirect target `control-results/` did not exist; the bash driver was not launched) — recorded in `wave-notes.txt`.

Checks: 8 PASS (L0.init, L1.rc, L1.exit, L1.lock_at_stop, L1.locklog, L1.order, L1.postmaster_gone, L2.rc), 1 FAIL (L2.exit), then STOP_ON_FIRST_FAILURE. Control root retained: `/tmp/s5-r4-ctl-rlvDaH`; copied to `wave1-lifecycle-evidence/` (derived run/exit/env/fixture logs, lane lock log, recorded fake pids, derivation diff).

Raw exit record (exit-resume-20260922T050212Z.log):
`PROOF_EXIT=143 FIRST_RC=143 STAGE=resume STOP_RC=na DAEMON=none SURVIVORS=none SIGNALLED=TERM CLEANUP_SECONDS=0 QUARANTINE=no START=05:02:12Z END=05:02:14Z`
Run log lines 45–48: `CMD ... ./node_modules/.bin/jest test/scout/g2-pg17-db-guard.spec.ts` (05:02:12) → `SIGNAL TERM received ... owned_pgid=28636` (05:02:13) → `OWNED_GROUP_REAPED pgid=28636 term_wait=0s` → exit record. Lane lock log: HOLDER 05:02:12 / RELEASE first_rc=143 stop_rc=na 05:02:14.

## Root cause (source-only reading; nothing modified)
Classification: CONTROL-DRIVER precondition/timing defect. NOT "runner did not stop".
- Runner rev 7 `resume` order (run-proof.sh lines 411–431): guard-unit jest (`test/scout/g2-pg17-db-guard.spec.ts`) → old-root → **fixture start (`SERVER_STARTED_HERE=1`, line 427)** → preflight → generate-only → live jest. The TERM landed during the guard-unit jest, i.e. before any fixture start, so no fake postmaster existed; `finish` correctly reports `STOP_RC=na DAEMON=none` (line 294 gate) and released after reaping the owned group. L1's postmaster had already been stopped by L1 (pid file absent; pid 27494 gone). Runner behaviour is consistent with its design for that phase.
- Driver defect 1: fake jest (`lib.sh` fake `node_modules/.bin/jest`) applies the scenario `"300 0"` to EVERY jest invocation, so the 300 s sleep was hit by the guard-unit jest, not the live spec.
- Driver defect 2: the L2 wait loop keyed on `grep 'CMD.*jest' "$(latest run-resume-)"` (matches the guard-unit CMD) and `grep FAKE_JEST_GRANDCHILD "$(latest live-etq0-)"` — the only live log was L1's stale `live-etq0-20260922T050205Z.log`, so the "live phase reached" precondition was satisfied by a stale file. The TERM was sent 0.5 s later, during guard-unit.
- Consequently L2.exit expected STOP_RC=0 (a stop under the held lock) but the scenario never created anything to stop. The check's expectation was correct for the intended scenario; the scenario was not established.

## Minimal repair proposal (controls-v3, driver only; NOT written, NOT run)
1. `lib.sh` fake jest: apply the scenario sleep only when the argv contains `rls-g2-pg17-etq0.spec.ts`; every other jest invocation exits 0 after 0.2 s.
2. `ctl-lifecycle.sh` L2/L3: record `prev_live=$(ls live-etq0-* | wc -l)` before launching and wait until a NEW live log exists AND contains `FAKE_JEST_GRANDCHILD` AND the fake postmaster pid file exists; only then signal. Same for L3 (deadline must expire inside the live phase: set WORK_BUDGET so the guard/oldroot/start/preflight/generate-only phases, ~4 s here, complete first — e.g. WORK_BUDGET=12 with the live sleep 300).
3. Keep L2.exit's expectation (STOP_RC=0, lock HELD at stop) unchanged; add an explicit precondition check `L2.pre` (postmaster.pid present, new live log) so a mis-targeted signal fails as a precondition, not as a runner finding.
No change to run-proof.sh (`19ab936a…`), s5-fixture.sh, patch, app, schema or deps.

## Survivor accounting (before → after)
Before wave: no control roots, no fake processes, canonical lock path absent. After: recorded fake pids 27494 (L1 fake postmaster), 28636 (L2 owned pgid), 28641 (L2 jest grandchild) all gone; no process with a cmdline referencing the control root, run-proof.sh or s5-fixture; control-root postmaster.pid absent; canonical lock path still absent (never created); `/home/user/pg17` and `execution/s5-r4/QUARANTINE` absent as before. All recorded fake processes dead; S2 setup may proceed from a process standpoint. Control root `/tmp/s5-r4-ctl-rlvDaH` retained (S5_CTL_KEEP=1), not erased.

## Immutability
Original 17-file `SHA256SUMS` 0 mismatches; `SHA256SUMS.controls-v2` 0 mismatches; worktree HEAD 143d451e…, dirty fingerprint 6850b32e…6aa0 unchanged; runner `19ab936a…` untouched. This wave is evidence collection only; nothing here is safety or audit clearance.
