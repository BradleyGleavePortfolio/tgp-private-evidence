# S8-D1 typed person handoff rebuild grant (EXEC-42D8C5B5) — T4, builder claude_fable_5
Tier: T4. Why: durable identity provenance for imported coach clients + S9 completeness truth. Owner decision D-S8-2 option (a)
is OFFICIAL (no User minted; email never an identity key); D1 depends on no open owner question.
Customer value: without D1, no source that imports clients can ever settle `complete`; with it, imported clients become native
Persons with verified provenance and runs can be truthfully complete.
Situation: predecessor candidate (42c8ed30 / 03b574e4) was LOST with its sandbox. Build a NEW candidate from the durable design.
Base: aed23289024898cceca7385d3778cd7373b7424d (S11-D r3). The parent will rebase you onto the landed S11-DE; do not wait for it.
Clone: /home/user/workspace/worktrees/x42-s8d1, branch x42/s8d1; preserve ref cand/x42/s8d1.
Contract: docs/decisions/2026-09-26-s8d-person-link.md §5.1 steps 1-4 — on origin/land/s8d-doc (77b7f0bb; `git show
origin/land/s8d-doc:docs/decisions/2026-09-26-s8d-person-link.md`). Do not commit that doc.
Read first (evidence /home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/): s8d1/S8D1_BUILD_GRANT.md (scope and
named specs — still binding except paths/session ids), s8d1/s8d1_build.md (full design, file:line, spec inventory), s8d1/s8d1_review.md
(independent review: A none; B1 = journey-full honesty update, which the PARENT applies after S11-DE lands — you do NOT edit
test/scout/s11/journey-full.pg.spec.ts). Also OWNER_DECISION_S8D_2026-09-26.md.
Scope: src/scout/reconstruct/families.ts (clientsFamily.persist → persistPerson create-only, provenance-verified, typed outcome),
src/scout/reconstruct/native/{person-writer.ts (new), native-provenance.ts, native-contract.ts}, src/scout/reconciliation/facts.service.ts
readPersons, and the specs listed in s8d1_build.md (incl. s10-unseen case (h) flip to `complete`). No migration (S11 lane pins 173).
Gates (lock): prettier, eslint, tsc, jest of touched specs + test/scout unit suites. No PostgreSQL. Stop if prod LOC > 1,000.
Report: execution/42d8c5b5/s8d1/BUILD.md incl. which PG lanes/specs the parent must run with expected counts.
Rules: execution/42d8c5b5/WORKER_RULES.md.
