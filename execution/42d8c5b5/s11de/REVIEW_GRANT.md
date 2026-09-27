# S11-DE independent T4 review grant (EXEC-42D8C5B5) — two independent lenses (A: gpt_6_sol, B: claude_opus_5_5)
Candidate: backend cand/x42/s11de = c8ca65f95efd5126e2e5c86e8ffd61e551e78a6c (commit 1 src 238ecc15, commit 2 test c8ca65f9) on
aed23289 (S11-D r3, PR #565) on integration/importer 54be96f1. Read-only clone: `git clone --no-hardlinks /home/user/workspace/repos/backend
<clone>`; ref origin/cand/x42/s11de. Read-only: no commits/pushes/PG. The parent is running the S11-lane PG proof in parallel.
Purpose: (1) roster (IMPORTER-G) and entities (IMPORTER-I) readers were blind to any source whose people/workout token is not literally the
family name — `staged 0 / persons []` for every newly inducted source (violates NEW SOURCE → CORE DIFF = 0 and "unknown never silently
becomes zero"). Fix: classify staged/ledger (platform, token) pairs through the same registry + resolveFamily the engine uses; count
unclassifiable staged rows in additive fields. (2) S11-D J19/J20 spec fixes (leg A J17, worker registry seam, leg B unclassified 0, J20 range).
Inputs: execution/42d8c5b5/s11de/{GRANT.md,BUILD.md}; execution/fa72efb2/s11d/{S11D_R4_LEG_B_ROSTER_FINDING.md,PROOF_V2_FINDING.md};
execution/fa72efb2/s11e/s11e_build.md (lost predecessor design); docs/decisions/2026-09-26-s11-journey.md.
Audit adversarially: tenant scope (coach_id, intent_id) preserved on every read incl. cursor paths; empty scope can never widen to all rows;
registry parity with the engine (same builder/default; harness injection mirrors the engine and cannot mask a prod divergence); legacy
token==family still served; other-family rows excluded; cursor/pagination correctness and determinism across merged pairs; bounded queries
(no N+1); DTO/contract additive and truthful (`staged` semantics change is honest and documented); no slug/token literal in src; spec
assertions trace to executing code (two prior live failures of this spec); J20 range logic sound.
Classify A/B/C per WORKER_RULES rule 8. Verdict GO/NO-GO. Report execution/42d8c5b5/s11de/REVIEW_<A|B>.md. Rules: execution/42d8c5b5/WORKER_RULES.md.
