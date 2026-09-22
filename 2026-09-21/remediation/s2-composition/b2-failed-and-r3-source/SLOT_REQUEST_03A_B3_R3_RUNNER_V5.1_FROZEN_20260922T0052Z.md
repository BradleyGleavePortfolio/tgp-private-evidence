# SLOT REQUEST 03A — addendum to SLOT_REQUEST_03 (8b99879c…8913, left unchanged). IMMUTABLE, frozen 2026-09-22T00:52Z.

## Correction (only change): runner v5.1 replaces v5.0 for B3
- v5.0 run-composition-r3-when-granted.sh 6b75a933…8122 (kept, NOT to be run): line 18 DB=s1_rls_s2comp_r2 contradicted header/request (s1_rls_s2comp_r3). NS was already s2comp-r3.
- v5.1 run-composition-r3-v5.1-when-granted.sh sha256 0f4467e00c1ec878f4b8ff204a910d271a817a3c6bdc28a0df44f25023842e15 (frozen copy runner-history/run-composition-r3-v5.1-when-granted.sh.frozen)
  diff v5.0→v5.1: line 2 header label (v5.1, DB s1_rls_s2comp_r3, reason) and line 18 DB=s1_rls_s2comp_r3. Nothing else. Confirm literal derives from $DB → DESTROY-127.0.0.1:54321/s1_rls_s2comp_r3,s1_rls_s2comp_r3_lock.
- Source d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c / bundle 3b6cee48…0f75 unchanged. Launch command for B3 (supersedes request 03's):
  cd /home/user/workspace/execution/s2-composition && ./launch-detached.sh start composition-r3 env -u S2_RUNNER_STUBS timeout --foreground -k 60 2100 bash /home/user/workspace/execution/s2-composition/run-composition-r3-v5.1-when-granted.sh
  All other bounds/prechecks/reporting as in request 03.

## Cheap stub / no-contact consistency (runner-selftest-r3/, STUB MODE — NOT EVIDENCE of DB behaviour)
A success at pinned head d5cd9b8b: final 0; stamps carry s1_rls_s2comp_r3 only (4 occurrences, 0 of _r2); steps 20/21 refusals 64/64, 40, 45 reached.
B planted /tmp/prisma_verify.log → final 70 "30 precheck REFUSED: pre-existing release.sh /tmp scratch files (not touched)"; file content verified intact afterwards, then removed by me.
C during all stub runs: 0 listeners on 54321, 0 pg17 postgres processes.

## Outer-timeout (TERM) cleanup behaviour — existing evidence: NONE before this; control run now (stub, runner-selftest-r3/20260922T004937Z/, runner-selftest-r3/term-control/)
Setup: stub harness that sleeps 40 s; runner under `timeout --foreground -k 5 3` (outer bound fires during step 40). Observed:
- outer exit 124; bash DID run the EXIT trap on SIGTERM: fixture stop (stub) exit 0, status-after-stop, exit-codes.txt written
  (final=1 composition=notrun …), "LOCK: released by runner exit; no survivors".
- BUT the step-40 child tree (timeout 1500 → bash harness → sleep) SURVIVED the runner for its full duration (pids observed 8 s after exit);
  `timeout --foreground` signals only the direct child and the EXIT trap does not kill the running step. The stub harness escaped the survivor scan
  only because its cmdline (bash /tmp/…/harness.sh) is not the real one; in a real run the harness is exec'd as `bash test/release/s1s2-composition.sh <db>`
  which the anchored scan matches → result would be downgraded to 71 with "LOCK: NOT safely handed off" (correct signal), but the fixture would have been
  stopped under a live harness and composition would be mislabelled "notrun" instead of "interrupted".
- Lock: the runner's fd 9 closes at exit (lock free) while the child survives — the child does not hold fd 9 (9>&- on every step), so the "released" wording
  is literally true but the handoff is unsafe; in the real case the scan would say so.
- In a real B3 the inner bounds (harness 1500 s, discriminator 300 s, fixture ops) are designed to fire before the 2100 s outer bound, so this path should not
  be reached; it is a robustness gap, not a correctness gap in the proof.
Proposed (NOT implemented — outside the authorised DB-constant-only correction): v5.2 adds `trap` on TERM/INT/HUP that records the current step's child pid,
TERM-kills that child tree (pkill -TERM -P / process-group), waits briefly, labels the step "interrupted(124)" and then runs the same cleanup; plus the stub
survivor pattern for self-tests. Awaiting authorisation; v5.1 is proposed for B3 as-is unless parent prefers v5.2 first.
