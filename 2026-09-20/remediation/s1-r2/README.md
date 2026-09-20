# S1 remediation candidate, awaiting independent R2 audit

Received 2026-09-20 17:42 UTC. Head `90a6647513f3566393764eee87237d9b5b1f150b`, tree `01c7fba4443758ad7921a724dfb4680fd1f0f2ab`, parent frozen R1 `620b47fc8517fa5e5950c5b673baf8b002f5c78a`. Builder worktree was clean at receipt; author and committer are Bradley Gleave.

## Complete recovery packet

`revision-1/` preserves the entire returned S1 execution directory: both source bundles, reports/dispositions, runtime-role packet, synthetic PostgreSQL recreation instructions, portable infrastructure script, runner scripts, held R1 harness, all failed/intermediate/final logs, and synthetic schema dumps. No database data directories, installed binaries, node_modules or production credentials are included.

The R2 bundle verifies with only public base `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` required. Bundle SHA-256: `0ffd66f12e95c082871942f885e07591d4f80992e8039a9cbb8a02cb14ef066c`. The final run log hash matches the builder manifest: `c113512cb5d180ab9a5ad2c3b2608877bf042c906bbcd2c24132cf22f8642e79`.

Clone `https://github.com/BradleyGleavePortfolio/growth-project-backend.git`, verify `revision-1/SHA256SUMS`, verify the bundle, then import its `refs/heads/execute/20260920-s1-database` into a fresh branch. Follow `revision-1/infra/RECREATE_PG17_SYNTHETIC.md` for the disposable local environment; never substitute a production connection into teardown/proof commands.

## Evidence scope and next boundary

The final log records **68 passed / 0 failed on synthetic PostgreSQL 17.6** at the new head. This is builder-produced proof and proposed finding closure, not an independent audit verdict or proof of the production environment.

The builder reports observing that `prisma migrate resolve --rolled-back` is not a valid way to undo a successful migration's history after an out-of-band reversal: it refused or silently left the applied row intact in the tested histories. S1's proposed recovery uses transactional forward reapplication plus catalog verification, without editing migration-history rows. Independent review must assess this recovery packet before any live use.

S2 received the verification-after-deploy/restore requirements. Serving database role, production ownership/grantor, backups/restore assurance, integrated release behavior and live execution authority remain unresolved external boundaries.

State: written, committed, synthetic-tested, privately preserved; **not R2 audit-cleared, merged, deployed, enabled or customer-accepted**. Original R1 reports remain unchanged under `../../audits/s1-r1/`.
