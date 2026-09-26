# S11-B NEW candidate — two independent T4 reviews (EXEC-FA72EFB2)

Grade T4 (terminal truth, settle re-drive and replay semantics; concurrency across processes). Doctrine: dual
independent review. Routes: Review A = Claude Fable 5 (correctness / terminal-truth lens); Review B = GPT-6 Sol
(adversarial concurrency / fencing / idempotency lens). Reviewers do not see each other's reports.
Read-only: no jest/tsc/eslint/prettier/PG, no lock, no edits, no commits.

Subject: /home/user/workspace/worktrees/fa72-s11b branch fa72/s11b HEAD 45b4da1d601007c15618e358c307c26f48262a43
(tree 04c4fc8f), one commit on 3db615c0 (S11-A1). `git diff 3db615c0 45b4da1d` = 5 files (builder summary table).
Builder report: execution/fa72efb2/s11b/s11b_builder_summary.md (+ s11b_new_candidate_src.diff, gate logs).
Design authority: docs/decisions/2026-09-26-s11-journey.md in the clone (D-S11-4 G1 re-drivable settle; J12–J16;
D-S11-8 row S11-B ≤80 prod LOC; D-S11-7 invariants). Predecessor reviews of the LOST S11-B bytes (design reference only):
search execution/d3a9f701/s11b* in /home/user/workspace/repos/tgp-private-evidence.

Questions (answer each):
1. Terminal truth: can the P2002 re-drive path ever produce a terminal/basis that the original settle would not, settle
   twice, or settle a run whose epoch/fence was revoked? (J13, J15 b, J16.)
2. Replay: does a replayed completion preserve the stored claim (J14) and never overwrite it; is a non-pending gate a
   pure ack (J12 tail, J15 a/c)?
3. Unknown never zero / no fabricated server behavior: any path that turns an unknown into complete/zero?
4. Tests discriminate: would the live spec (8) and unit spec (11) fail on a plausible wrong implementation? Is the J13
   barrier truly proving both workers are in the re-drive branch? Is the R36 flip in test/rls-g2-s10c.spec.ts exactly
   the intended semantic change (old: CAS miss/insert failure → no terminal, no basis; new retry behavior) and nothing
   weaker?
5. First-run risk for the single real-PG proof (builder C-2: 20 s S9_SNAPSHOT_TX_OPTIONS tail under J13) — A/B only if
   it plausibly wastes the run; give the minimum closure.
Verdict GO/NO-GO; A/B only with CLASS, CONCRETE HARM, EXACT DECISION BLOCKED, MINIMUM CLOSURE, EXECUTION UNLOCKED.
Reports: execution/fa72efb2/s11b/s11b_review_A.md and s11b_review_B.md. Rules: execution/fa72efb2/WORKER_RULES.md.
