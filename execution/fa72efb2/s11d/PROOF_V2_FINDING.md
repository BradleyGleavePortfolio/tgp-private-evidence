# S11-D real-PG proof v2 — FAILED (preserved unchanged) — EXEC-FA72EFB2
Run s11d/binding/v2/run, candidate r3 aed23289 on 54be96f1, LAUNCH 19:41:37Z, END rc=1 stage=jest-full 19:44:04Z; teardown clean;
lane logs archived to run/post-teardown; clusters/s11 removed. Guard not reached. journey-full 4 passed / 2 failed; J20 4/4 again.
Both r3 fixes held: leg A passed J01→J09→J12 incl. the re-drive (pushes 0, one terminal write); leg B passed the settle assertions
(partial/unresolved_identities, basis families + roster_bridge_pending).
- Leg A FAILED at journey-full.pg.spec.ts:313 — J17 late readiness `h.pairCurrent('P2', …)` returned 404 "Pairing session not
  found. Create a new pairing code." (the spec assumes the pairing session is still readable after the terminal settle / after the
  J12 kill-and-replay on the other host).
- Leg B FAILED at :426 — `roster.result.accounting.staged` 0, expected 2 (roster_bridge_pending true passed at :425).
Classification: B (candidate spec assumptions, never run live; no src in S11-D). Route escalated: two consecutive live failures of a
T2-built spec → the fix goes to a T4 builder (Claude Fable 5) with a mandate to trace every remaining assertion to the executing code
path and a live-passing precedent. MINIMUM CLOSURE: r4 spec-only commit, independent delta review, binding v3, one new run. These
bytes are not rerun. EXECUTION UNLOCKED: S11-D landing.
