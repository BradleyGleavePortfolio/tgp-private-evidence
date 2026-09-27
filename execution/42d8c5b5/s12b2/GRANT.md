# S12-B2 test-only manifest production exclusion rebuild grant (EXEC-42D8C5B5) — T3, builder claude_opus_5_5
Tier: T3. Why: shared induction-registry loading behaviour across runtimes (closes D2 review C1: a prod run must never be able to
declare a committed test-only source such as s10_unseen).
Situation: predecessor bytes (726d2227 → c516d463, r2 fixed unset NODE_ENV) were LOST. Rebuild from the durable design incl. the r2
closure (refuse outside explicit development/test, i.e. unset NODE_ENV is refused) so the result equals the reviewed-GO design.
Base: origin/integration/importer 54be96f18c314cae35d1e5d3000af9f06d693d81. Clone /home/user/workspace/worktrees/x42-s12b2,
branch x42/s12b2; preserve ref cand/x42/s12b2.
Read: /home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s12b2/{S12B2_BUILD_GRANT.md,s12b2_build.md,s12b2_review.md},
s10d2/d2_review.md C1 (L217-222).
Gates (lock): prettier, eslint, tsc, jest test/scout + any induction/registry suites. No PostgreSQL. No slug in src; contract.ts
MANIFEST_KEYS/VERIFIER_KEYS unchanged. List which PG lanes the parent must run (parser path). Report: execution/42d8c5b5/s12b2/BUILD.md.
Rules: execution/42d8c5b5/WORKER_RULES.md.
