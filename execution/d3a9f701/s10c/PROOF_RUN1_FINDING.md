# S10-C real-PG proof run-1 — RC=1 STAGE=jest (28/32), preserved, not rerun
- Run: binding/v1/run (candidate 6674bc59). rls-g2-s10b 24/24 passed; rls-g2-s10c 4/8 failed. First real-PG execution of the new S10-C RLS spec (devloops had no PG).
- All four are class B (spec premises contradict the landed completeServerRun contract; scout.service.ts doc: "a fenced or terminal run (late or duplicate settle) -> 200 ack no-op, unchanged"; the claim commits in its own transaction before onTransferSettled; notifyComplete pushes the importing coach's own import.complete notice):
  1. R33 complete: expected pushes 0, got 1 = the landed coach notice (coach-facing, not a customer side effect). Fix: pushes 1 + sideEffectLoads all zero (R38).
  2. R33 second claim after terminal: expected 409, got 200 ack. Fix: ack, pushes 0, still one basis row, no basis insert.
  3. R34 fenced run late claim: expected 409, got 200 ack. Fix: ack, pushes 0, no basis insert, zero basis rows, reason revoked.
  4. R36 retry after injected basis-insert failure: expected the retry to settle; the retry is a refused claim (200 ack) because the claim committed before the settle. Re-drive is S11-B's (dual GO, queued). Fix: terminal and basis stay paired after the retry (never one without the other).
- Concrete harm: none from S10-C. Pre-existing gap (a failed settle after a committed claim leaves the run open until deadline or re-drive) is S11-B's scope.
- Blocked: S10-C acceptance only. Minimum fix: proof-fix/rls-g2-s10c.diff (spec only; excluded from default jest, so gate-v2 JEST_FULL stands).
- Unblocks: S10-C candidate v2 (single commit on 711c1f8f = gate tree + fixed spec) and proof v2 (binding/v2, new run dir).
