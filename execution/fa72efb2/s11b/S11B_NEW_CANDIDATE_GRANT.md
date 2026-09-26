# S11-B NEW candidate build grant (EXEC-FA72EFB2)

Slice: S11-B re-drivable settle (G1), decision D-S11-4, J12-J16, D-S11-8 row. Grade: T4 (terminal truth, replay
semantics, customer-visible verdict). Requested route: T4 builder -> Claude Fable 5 (doctrine names Claude Fable 5.1;
the nearest available route is recorded, not claimed as telemetry). Reviews after build: two independent T4 reviewers.

Why NEW: the predecessor's S11-B bytes never reached durable storage (only the builder summary, s11b_fix1.diff and
reviews A/B survive in execution/d3a9f701/s11b/). Build a new candidate from the reviewed design. Do NOT claim byte
continuity with the lost worktree; you may reuse the design, test structure and the fix1 hunk content as reference.

Clone: /home/user/workspace/worktrees/fa72-s11b (branch fa72/s11b) at 3db615c0 = S11-A1 v3 (integration/importer
6a33df9b + the committed g2-s11 harness; PR #559, proof pending). S10-C is landed in this base (it owns lifecycle.service.ts).

Owned paths (only these):
- src/scout/scout.service.ts — P2002 branch + `redriveEpoch` helper exactly as D-S11-4 / builder summary "Design".
- src/scout/lifecycle/lifecycle.service.ts — ONE read-only helper `isSettlePending` (tenant-scoped SELECT; no lock/write).
- test/scout/s11/settle-redrive.pg.spec.ts (new; uses the g2-s11 harness by import only; J13 = BOTH workers at the
  `before-lock` barrier with both `ready` signals observed before release, per review A/B delta GO).
- test/scout/lifecycle/s11b-settle-redrive.spec.ts (new unit, no DB).
- test/rls-g2-s10c.spec.ts — ONLY if an existing R36 (or other) expectation pins the old "replay never re-drives"
  behaviour; flip exactly that expectation, nothing else, and state the before/after lines and why.
Caps: <= 80 hand-written production LOC (D-S11-8). No schema, route, DTO, reason code, arbiter, reconcile, coverage,
push or event change. No new import unless unavoidable (state it).

Inputs to read: docs/decisions/2026-09-26-s11-journey.md (D-S11-4, D-S11-8, J12-J16, the S11-B notes) in the clone;
execution/d3a9f701/s11b/{s11b_builder_summary.md,s11b_review_A.md,s11b_review_B.md,s11b_fix1.diff};
test/utils/g2-s11-{harness,pg-harness,db}.ts and g2-s11-worker.cjs in the clone; execution/fa72efb2/WORKER_RULES.md.

Gates you run (under the flock rule; see WORKER_RULES 3): prettier --check on owned files; eslint --max-warnings 0 on
owned files; `npx tsc --noEmit`; `node scripts/check-r75.js --mode=staged` after staging; unit jest:
`npx jest --runInBand test/scout/lifecycle test/scout/induction test/scout/reconciliation test/module-graph.spec.ts`
plus any existing unit spec covering scout.service/completeServerRun. NOT the PG specs (parent binding).
When all green: one local commit on fa72/s11b through the hooks (Bradley author+committer, no trailers), subject
"feat(scout): re-drive an interrupted settle on a replayed completion (S11-B)".

Report: execution/fa72efb2/s11b/s11b_builder_summary.md — head/tree, per-path sha256 + LOC, the D-S11-4 design
mapping, invariant->test table, every command with RC, the exact live commands the parent must run
(settle-redrive.pg.spec.ts, journey-core.pg.spec.ts, and rls-g2-s10c.spec.ts if touched), and open risks.
