# S11-A2 real-PG proof v1 — FAILED (preserved unchanged) — EXEC-FA72EFB2
Run binding/v1/run, candidate 03e7a234 on dda794d7, LAUNCH 18:01:25Z, END rc=1 stage=jest-rls 18:04:47Z; teardown clean
(postgres_procs=0, port free, datadir absent); lane logs archived to run/post-teardown; clusters/s11 removed.
Result: rls-g2-s11.spec.ts 4 passed / 2 failed (+ suite hook failure): `ERROR: G2-S10B insert-only: DELETE on ScoutRunObservation
refused` from resetData (test/utils/g2-s11-harness.ts L285-287) called by rls-g2-s11.spec.ts L61/L62. Later stages not reached.
Root cause: A2 added `DELETE FROM "ScoutRunObservation"; DELETE FROM "ScoutRunDeclaration"; DELETE FROM "ScoutRunSettledBasis";`
to resetData. The S10-B migration (20270124000000, L13-14, L176-188, L228-237) refuses top-level DELETE/TRUNCATE on those three
tables by trigger; they are cleared only by the parent-run ON DELETE CASCADE (FKs L104-107, L141-146, L170-171). Resets passed
while the tables were empty (row-level trigger, zero rows) and failed once J07's run wrote observation rows. The S10-B harness
(g2-s10b-harness.ts L173-176) never deletes them directly — it deletes the run and relies on the cascade. No-DB gates cannot see
the trigger.
Classification: B (candidate harness defect). CONCRETE HARM: every S11 spec that resets after an observation row exists fails;
A2 unprovable. EXACT DECISION BLOCKED: landing S11-A2 (#564) and S11-D (stacked). MINIMUM CLOSURE: drop the three direct
DELETEs from resetData (the existing `DELETE FROM "${RUN}"` cascades them), update the harness header/guard text if it names
them, new commit (r2), T4 delta review, binding v2, one new run. These bytes are not rerun. EXECUTION UNLOCKED: S11-A2 landing.
