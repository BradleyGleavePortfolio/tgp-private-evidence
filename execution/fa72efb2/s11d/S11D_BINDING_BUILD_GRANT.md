# S11-D real-PG proof binding — build grant (EXEC-FA72EFB2)
Grade T3; route Claude Opus 5.5. Source only (never run runner/fixture/jest/PG; never take the lock).
Derive s11d/binding/v1/ from s11a2/binding/v2 (independent T3 GO; ran END rc=0 127/127 at 54be96f1; landed) by minimum
substitution: SRC worktrees/fa72-s11d2 branch fa72/s11d-r2 (standalone clone; clean), W worktrees/fa72-s11d2-pg1 (fresh, absent),
BASE 54be96f18c314cae35d1e5d3000af9f06d693d81 (tree 435fec78, = integration/importer), HEAD 38d0d366730331e4edf19a14cda8247435b89431,
chain BASE → a52d20d6 → 38d0d366 (exactly TWO commits), LAND_REF origin/land/s11d = 38d0d366, delta = exactly
test/scout/s11/journey-full.pg.spec.ts (blob ecfe8cef; nothing in src/prisma/package/test/utils). FREEZE-s11a2 (12 paths),
FREEZE-v3 kept lines, FREEZE-s11c, FREEZE-s11b and all 18 blob pins must hold unchanged at HEAD; new FREEZE-s11d = the delta.
Stages: bootstrap; NEW full (test/scout/s11/journey-full.pg.spec.ts, 6 tests: 2 J19 legs + 4 J20 checks, default config, own log,
receipts, count parse, stop-first-failure); guard 95. DROP rls/journey/readiness/settle-redrive/induction (accepted at BASE in
s11a2 v2 on unchanged bytes — rerunning is forbidden). J20 needs full history in W: verify W's clone keeps 3db615c0^, 7fdcbc04,
275e458c and all objects of their trees (SRC has them: parent checked 0 missing) and that the spec's scratch `git worktree add`
inside W is allowed by the runner's clean-tree / freeze checks (it removes itself; confirm no post-run check trips on
.git/worktrees). Honest time bound for full (J19 spans J12 interrupt + many worker processes) and outer timeout = stage sum +
margin. Lane clusters/s11 absent, port 55648. DELTA-from-s11a2-v2.diff, bash -n, BINDING.sha256, README (pins, counts, risks).
Rules: execution/fa72efb2/WORKER_RULES.md.
