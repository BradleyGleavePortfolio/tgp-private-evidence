# D2 proof-v1 failure — diagnosis and minimum fix (EXEC-FA72EFB2)
Grade T4 (completeness/terminal truth: a wrong fix could make a new source falsely `complete`). Route: Claude Fable 5.
Read PROOF_V1_FINDING.md and binding/v1/run/{jest.log,d2-pg-proof.log} (preserved; never edit them).
Clone: /home/user/workspace/worktrees/fa72-d2 branch fa72/d2-r1 HEAD 144269d1 (base 7fdcbc04). D2-owned paths only (8 files:
3 JSON assets under src/scout/**/sources/s10_unseen.json, 3 fixtures under test/fixtures/scout/s10_unseen/, the e2e and
pg specs under test/scout/s10/). CORE DIFF = 0: never edit any .ts under src/, never edit other tests/harnesses.
1. Root cause (file:line evidence): why the live chain (the pg spec's `chain`: stage → declare → observe/sign → claim →
   reconstruct pass → settle/reconcile) returns partial/unresolved_identities for SET.base although the pass reconstructed
   every row; why the e2e composition half says known+covering for the same set (what the e2e does NOT exercise); compare
   with the accepted S10-A/S10-C live proofs for an existing source (test/rls-g2-s10c.spec.ts, the S10-B/S9 specs) — what
   do they stage/declare that D2 does not? Decide which is wrong: (i) D2 assets (identity keys / mapping / native rules),
   (ii) fixtures/staging, (iii) the spec's expectations, or (iv) core behavior that a data-only source cannot satisfy.
2. If (i)–(iii): implement the minimum fix in D2-owned paths, keep every assertion honest (never weaken (a)'s `complete`
   unless the design says complete is impossible — then say so), run prettier/eslint/tsc and the no-DB e2e under
   `flock -w 3600 /home/user/workspace/execution/test-validation.lock` only while
   /home/user/workspace/execution/fa72efb2/PROOF_SLOT_FREE exists, run scripts/s10-core-diff-gate.sh 7fdcbc04, commit
   ONE new commit on fa72/d2-r1 through hooks (Bradley author/committer, no trailers). No PG runs (the parent runs the
   one real-PG proof after review).
   If (iv): no code; write the product finding (A/B format) — it is a north-star question for the parent.
Report: s10d2/d2_diagnose_fix.md (root cause, evidence, fix diff summary, commands+RC, new head, residual risks).
Rules: execution/fa72efb2/WORKER_RULES.md.
