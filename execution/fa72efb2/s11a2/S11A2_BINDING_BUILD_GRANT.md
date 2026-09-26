# S11-A2 real-PG proof binding — build grant (EXEC-FA72EFB2)
Grade T3; route Claude Opus 5.5. Source only (never run runner/fixture/jest/PG; never take the lock).
Derive s11a2/binding/v1/ from s11b/binding/s11-lane-v2 (independent T3 GO; ran RC=0 122/122) by MINIMUM substitution:
SRC worktrees/fa72-s11a2 branch fa72/s11a2, W worktrees/fa72-s11a2-pg1 (fresh), BASE dda794d7 (tree 802e1c19), HEAD 03e7a234
(tree 738b7116), exactly ONE commit (drop the S11-B two-commit/r1→r2 checks), LAND_REF origin/land/s11a2 = 03e7a234, delta = the
12 A2 paths (new FREEZE-s11a2 == delta). A2 is the D-S11-6 sequential writer of the A1 harness files: FREEZE-v3 no longer holds for
the files A2 edits — replace those entries by A2 blob pins and keep FREEZE-v3 for the untouched A1 files; FREEZE-s11c and the
S11-B files (FREEZE-s11b, 6 paths) must hold unchanged at HEAD. Stages: bootstrap; rls 6; journey 8; readiness 6; settle-redrive 8;
NEW induction (test/scout/s11/journey-induction.pg.spec.ts, 4, default config, own log, receipts, count parse, stop-first-failure);
guard 95 (was 94 — verify at HEAD). Set G2_S11_CANDIDATE_HEAD per the harness. Time: induction ≈38 worker processes — give an
honest bound and adjust the outer timeout if the sum requires. Lane clusters/s11 (absent; v2 leftovers archived) port 55648.
launch-when-free.sh inside BINDING.sha256. DELTA-from-s11b-v2.diff, bash -n, BINDING.sha256 (relative), README (pins, counts, risks).
Rules: execution/fa72efb2/WORKER_RULES.md.
