# S12-B1 pilot-coach allowlist rebuild grant (EXEC-42D8C5B5) — T4, builder claude_fable_5
Tier: T4. Why: authorization gate deciding which authenticated coaches may reach importer routes in a pilot.
Customer value: lets Bradley enable the importer for named pilot coaches only (S12 prerequisite). Enabling flags stays owner-reserved.
Situation: predecessor bytes (3bfe24f0 → f48395df) were LOST. Rebuild from the durable design, INCLUDING the round-2 B1 closure
(case-variant/CORS pre-auth gap in the flag middleware → lower-case fold) so the result equals the reviewed-GO design.
Base: origin/integration/importer 54be96f18c314cae35d1e5d3000af9f06d693d81. Clone /home/user/workspace/worktrees/x42-s12b1,
branch x42/s12b1; preserve ref cand/x42/s12b1.
Read: /home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s12b1/{S12B1_BUILD_GRANT.md,s12b1_build.md,s12b1_review.md}
and s12/S12_PILOT_READINESS.md §2b S12-B1, §3.1, §3.2.
Gates (lock): prettier, eslint, tsc, jest of touched + affected guard/middleware/feature-flag suites. No PostgreSQL. No workflow,
fly config, or flag value change. Report: execution/42d8c5b5/s12b1/BUILD.md (note every deviation from the reviewed design).
Rules: execution/42d8c5b5/WORKER_RULES.md.
