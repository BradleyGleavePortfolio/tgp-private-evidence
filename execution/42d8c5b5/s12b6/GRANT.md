# S12-B6 build grant (EXEC-42D8C5B5) — T2, builder claude_sonnet_5_0
Tier: T2. Why: .github/workflows change (operator flag workflow); no product code; running it stays owner-reserved.
Base: backend 419a756da4e6eebc28e22b19d0c08d72549f6d4e (= origin/cand/x42/s12b1-on-s8d1: S11-DE → S8-D1 → S12-B2 → S12-B1, the composed
stack now in landing proof; integration/importer will FF to it). Fresh clone: `git clone --no-hardlinks /home/user/workspace/repos/backend <clone>`,
fetch origin cand refs with api_credentials github; node_modules `cp -al` from the donor per WORKER_RULES. Commit as Bradley Gleave through the
hooks; push every commit to the preserve ref named below. Rules: execution/42d8c5b5/WORKER_RULES.md (lock for every tsc/jest/prettier run).
Clone /home/user/workspace/worktrees/x42-s12b6, branch x42/s12b6, preserve ref cand/x42/s12b6.
Scope: execution/fa72efb2/s12/S12_PILOT_READINESS.md §2b row S12-B6: add FEATURE_SCOUT_RECONSTRUCT and FEATURE_SCOUT_PILOT_COACH_IDS (S12-B1's
allowlist variable) to .github/workflows/fly-feature-flags-set.yml next to the existing INGEST + PAIRING handling, following the existing pattern
(inputs, validation, defaults = unchanged/dark). The allowlist input must be validated against S12-B1's parser rules (UUID list) or passed through
unchanged with a note. Do NOT run the workflow, touch Fly, or change defaults to on. Update any workflow/deploy-readiness tests that pin this file.
Gates: actionlint if available (else yamllint/python yaml parse), prettier on touched files, jest of any spec that reads the workflow.
Report execution/42d8c5b5/s12b6/BUILD.md.
