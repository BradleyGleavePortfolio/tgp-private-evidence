# S5-R4-V3-LIFECYCLE — single run, first-failure stop (no retry; probe NOT run because the driver did not succeed)

Command (once): `S5_CTL_GRANT=granted-by-parent S5_CTL_KEEP=1 timeout --foreground -k 20 120 bash controls-v3/ctl-lifecycle.sh`, 05:18:40–05:19:28Z, driver rc=1 (STOP_ON_FIRST_FAILURE), no timeout. Control root retained `/tmp/s5-r4-ctl-dSElRC`; copies in `wave2-v3-lifecycle-evidence/`. Wave-1 root `/tmp/s5-r4-ctl-rlvDaH` untouched. Canonical lock `execution/test-validation.lock` (created by S2 at 05:05:46Z) only stat'ed, never opened. Real `/home/user/pg17` untouched (fake PG17_HOME under the control root).

## Results: 28 PASS, 1 FAIL
- L0/L1 (7): init; clean resume; lock HELD during stop; one HOLDER/RELEASE; order; postmaster gone.
- L2 (8, the intended live-phase hold): `L2.pre` live phase reached in THIS run (3 s wait) → TERM → runner rc 143; record `FIRST_RC=143 SIGNALLED=TERM STOP_RC=0 DAEMON=none SURVIVORS=none`; owned group reaped; grandchild dead; fake pg_ctl observed `lock_at_stop=HELD`; signal-to-exit 1 s; RELEASE written with first_rc=143 after the stop.
- L3 (6): `L3.pre` deadline expired inside live; rc 124; `FIRST_RC=124 STOP_RC=0`; reaped; wall 13 s; lock HELD at stop.
- L4 (5): failed stop → `FIRST_RC=0 PROOF_EXIT=3`, DAEMON alive, QUARANTINE written; next resume refused rc 4; destroy refused rc 4 with data retained.
- L5: `L5.rc` (rc 3 with 2 sessions) PASS; `L5.refusal_line` PASS; **`L5.no_mutating_children` FAIL**.

## First failure — raw evidence (run-resume-20260922T051924Z.log)
Line 45 `CMD … ./node_modules/.bin/jest test/scout/g2-pg17-db-guard.spec.ts` (guard-unit, pre-start) · 47 old-root create · 49 fixture start · 52 PREFLIGHT · 53 `preflight: 2 session(s) attached … mutating stage resume refuses (required: exactly 0)` · 54 exit `PROOF_EXIT=3 FIRST_RC=3 STOP_RC=0 DAEMON=none`. There is NO `generate-only` CMD and NO `rls-g2-pg17-etq0.spec.ts` CMD after line 53. 

Classification: CONTROL-CHECK defect (over-broad pattern), not a runner finding. The check `! grep -q 'CMD.*jest'` matched the guard-unit jest CMD, which by runner design (run-proof.sh 411–413) runs before the fixture start and preflight and touches no database. The runner did exactly what A-04 requires: refused before generate-only and before the live spec, and stopped the fixture it started (`STOP_RC=0`). The property the check meant to assert holds in the raw log; the check's pattern does not distinguish the guard-unit jest from the live jest.

Minimal repair (v4, driver only, NOT written/run): `L5.no_mutating_children` = no `CMD.*generate-only` AND no `CMD.*rls-g2-pg17-etq0.spec.ts` AND every remaining CMD line precedes the refusal line. Not executed here; not a re-run.

## Survivor accounting
Recorded fake pids (postmasters 4584 6205 8270 10591 12208; grandchildren 8879 11200) all gone after the run; no process referencing `sleep 3600`/`sleep 300`/run-proof.sh/s5-fixture; control-root quarantine cleared by the L4 control-owned recovery; canonical lock file unchanged (mtime 05:05:46Z). Next independent setup slot can start from a process standpoint.

## Not proven / not done
Static probe not run (driver did not succeed). Destroy and genctl drivers not run. Nothing about real PG, Jest hook semantics, or fresh bootstrap is proven. Not clearance.
