# C2b-1 RESCUE GRANT (tgp-importer-extension #20)
Grade: **T3**. Why: it is a new shared inference primitive (endpoint-role candidates) with no runtime wiring. Builder: claude_opus_5_5. Review: gpt_6_sol, on the final head.
- PR #20 head 93a678a4, base main (now a889f4ad). CI `test` is FAILURE; codeql passes. 354 prod LOC in shared/blueprint/roles.js and 888 test LOC.
- Scope: find why CI is red, rebase onto current main, make CI green, and keep production additions ≤400 LOC. Fix only what CI and the C2b-1
  contract in docs/REAL_GOAL_EXECUTION_PLAN.md (§C2b) require. No UI or runtime wiring, no platform names in shared/blueprint/*, no redesign.
- Push to a NEW branch `c2b-1-endpoint-roles-r2` and open a PR to main that references #20. Do not force-push #20.
- Commit author Bradley Gleave <bradley@bradleytgpcoaching.com>, no AI co-author.
- LANDING HOLD: do not merge. The parent lands it only after the L0 learn-and-remember decision confirms the deterministic role layer stays.
- Report: new PR number, head SHA, CI conclusion, prod/test LOC, root cause of the old red. Write execution/42d8c5b5/c2b1/BUILD.md in the evidence repo (do not push the evidence repo).
