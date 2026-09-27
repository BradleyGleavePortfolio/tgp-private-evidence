# S8-D1 independent T4 review grant (EXEC-42D8C5B5) — two independent lenses (A: gpt_6_sol, B: claude_opus_5_5)
Candidate: backend cand/x42/s8d1 = 68cfe342248dc61de660a570eb4e565f8bdc0128 on aed23289 (fetch in your own read-only clone:
`git clone --no-hardlinks /home/user/workspace/repos/backend <clone>`; the ref is origin/cand/x42/s8d1). Read-only: no commits, no pushes,
no PostgreSQL, no heavy slot needed (you may run cheap greps/reads; if you run jest/tsc use the flock in WORKER_RULES rule 5).
Contract: `git show origin/land/s8d-doc:docs/decisions/2026-09-26-s8d-person-link.md` §5.1 steps 1-4; owner decision
/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/OWNER_DECISION_S8D_2026-09-26.md (D-S8-2 (a): no User minted; email
never an identity key). Builder report: execution/42d8c5b5/s8d1/BUILD.md. Prior independent review of the LOST predecessor bytes (same
design): execution/fa72efb2/s8d1/s8d1_review.md (A none; B1 journey-full honesty patch is PARENT-owned and out of this candidate — do not
re-raise it). This candidate is a rebuild: check fidelity to the reviewed design AND audit adversarially.
Focus: identity (provenance is the identity; Person ext-ref uniqueness; cross-coach / mismatched provenance → identity_conflict; no
update/upsert of an existing Person; Deleted → native_target_removed, no resurrection), tenant scope, replay/idempotency under concurrent
P2002, S9 facts/verdict truth (complete only when every family verifies), no silent zero, NEW SOURCE → CORE DIFF = 0, test adequacy.
Classify A/B/C per WORKER_RULES rule 8 (harm, exact thing blocked, minimum closure, state unlocked). Do not widen scope.
Verdict: GO / NO-GO. Report: execution/42d8c5b5/s8d1/REVIEW_<A|B>.md. Rules: execution/42d8c5b5/WORKER_RULES.md.
