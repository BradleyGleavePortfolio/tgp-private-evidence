# C phase 2 grant (T4) — parent ~21:30Z

N/Q1 ACCEPTED at `29e60705d8c4e1228fd1d2f248c7e53b6b8e56dd` (tree 511710ee): dual GO, single PG 20/20, dual FINAL ACCEPT (`NQ1_V2R_LOCAL_ACCEPTANCE.md`). Landing via PR #533 (merge 7ea039f3 with PROD-CI-1) to `integration/importer`.

Sole writer `c_phase_1_re_draft_builder_mufyro8l`. Execute the phase-2 fills of `c/PHASE1_DRAFT_READY.md` and `c/PHASE1_REDRAFT_READY.md` in order:
1. Rebase/reset `s7-c` so its base is `29e60705` (untracked phase-1 files carried over unchanged; preserve a copy + hashes under `c/phase1-redraft-snapshot/` first).
2. Fill `__NQ1_ACCEPTED_HEAD__` = `29e60705…` (harness, bootstrap, runner NQ1_HEAD, PINS). The seven-N/Q1-blob precondition list must use the blobs at 29e60705 (spec + pg-harness changed vs 61b93cff).
3. `schema.prisma` two narrow `@@unique` removals + comments; phase-2 doc/text edits and OpenAPI regeneration per the preserved list (item 9); the three C-owned reconstruct fake specs if needed.
4. node_modules: copy from `worktrees/s7-nq1` (read-only), C-only `prisma generate` (receipts 02/03, record client sha).
5. Light + heavy gates (tsc heap 4096, eslint, prettier, check-r75, affected default Jest, g2-c db-guard) under the canonical flock; chain-harness PG15 dry-run only if it runs without a new environment (else record C and leave to the PR's CI `migration-dry-run`).
6. One ordinary hooked Bradley commit (no trailers). Fill EXPECT_*/NM_CLIENT pins, reseal `BINDING.sha256`, export bundle+patch.
Stop with `c/SOURCE_READY.md`. No PG run (separate grant after dual attestation). No push.
