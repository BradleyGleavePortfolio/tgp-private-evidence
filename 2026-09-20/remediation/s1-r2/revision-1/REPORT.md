# S1 T4 — database closure (S1-DB-01) — handoff REPORT

**State: R2 candidate written, locally proven on synthetic PG 17.6, NOT audited-clear (R1 verdicts were NOT CLEARED; R2 awaits independent re-audit), NOT merged, NOT deployed, NOT live-verified. No production read/DDL/runtime exec performed.**

## Identity
- Base: `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` (public backend main)
- Head: `90a6647513f3566393764eee87237d9b5b1f150b` — tree `01c7fba4443758ad7921a724dfb4680fd1f0f2ab` — branch `execute/20260920-s1-database`, tag `s1-db-R2`; parent commit = frozen R1 `620b47fc8517fa5e5950c5b673baf8b002f5c78a` (tree `e9fc265e…`, tag `s1-db-R1`).
- Author/committer both `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no co-author. Worktree clean.
- Bundles: `execution/s1-database/bundles/s1-database-R2-90a6647.bundle` (verified, requires only c23b9d9f); R1 bundle retained.
- Changed files vs base (5, +908/−0): `prisma/migrations/20261224000000_rls_close_public_exposure/migration.sql` (candidate), `verify.sql` (catalog verifier), `down.sql` (operator reverse, gate-compatible), `test/db/_support/supabase-like-bootstrap.sql` (fixture roles/default privileges), `test/db/s1-rls-close-public-exposure.sh` (proof harness).

## What the candidate does (unchanged boundary since R1)
14 server-only tables → ENABLE+FORCE RLS, PERMISSIVE `service_role` ALL, RESTRICTIVE deny-all `anon`/`authenticated`, REVOKE API-role grants; all current `community_messages` partitions protected identically from `pg_inherits`; future partitions protected inside `community_messages_create_month_partition()` via `community_messages_protect_partition(regclass)` (now guarded to real partitions of `public.community_messages`); `search_path` pinned on the four advisor-flagged functions; `lock_timeout 5s` / `statement_timeout 60s`, RESET at end; idempotent; fails closed if roles/tables missing. Nothing granted to API roles. `WearableProcessedEvent`, Prisma schema, release/CI wiring untouched.

## What ran (all synthetic, isolated PG 17.6 on 127.0.0.1:54321; under `execution/test-validation.lock`)
- Full 165-migration replay from empty as non-superuser BYPASSRLS `postgres` (`replay-main-c23b9d9.log`, exit 0).
- `test/db/s1-rls-close-public-exposure.sh` at head 90a66475, clean tree: **68 passed / 0 failed** (`proof-run-05-head-90a6647.log`). Covered: pre-state twin (parent chain + out-of-band `rls_fitness_backend.sql` reproduces exactly the 18 exposed relations with anon/authenticated CRUD; verify.sql fails naming the exposure); lock held → direct run fails 55P03 in 5 s, Prisma deploy fails in 6 s, both atomic (pre-state untouched), failed row recorded, `resolve --rolled-back` + `deploy` recovers, verify passes; no timeout leakage; clean apply via `prisma migrate deploy` → verify OK "18 relations protected (4 partitions)"; no other table's RLS/ACL changed; parent policies untouched; idempotent re-run; anon/authenticated denied (42501) for SELECT/INSERT/UPDATE/DELETE on all 18 relations and cannot execute the partition helper; `service_role` and `postgres` read/write; RLS layer proven with a non-bypass role holding grants (0 rows / policy violation); parent-path community reads/inserts unchanged (coach, member, non-member, forged sender, row routed into protected partition); helper creates a protected partition, is idempotent; down.sql restores pre-state; forward→down→forward schema dumps byte-identical (reversibility gate parity); false "up to date" invariant + P3012 on clean history; direct re-apply restores; seeded rows/contents intact throughout.
- Runtime-role probe validated on the fixture (4 cases) — see packet rev 2; **not** executed live.

## Invariants encoded
1. After any deploy/restore, only `verify.sql` (catalog) is truth; Prisma's "up to date" is not (prior recovery finding preserved; reproduced).
2. `prisma migrate resolve --rolled-back` is a recovery only for a *failed* attempt; after an out-of-band reversal of a *successful* migration it refuses (P3012) or, with an earlier failed row present, no-ops with a success message. Recovery = `psql --single-transaction -v ON_ERROR_STOP=1 -f migration.sql` then `verify.sql`; never edit `_prisma_migrations`.
3. Partition RLS/grants are not inherited; parent path governed by parent policies only (observed).

## Open findings / external gaps (block any live application; not closable here)
- Actual Fly serving DB role (probe in packet needs Bradley/parent authority; STOP if `bypassrls=false`).
- Grantor of production anon/authenticated grants and ownership of the 18 relations/4 functions (metadata-only read would settle; migration fails closed otherwise).
- Backups/PITR/restore evidence.
- Requirements for S2 (not edited by S1): wire `verify.sql` after `prisma migrate deploy` in `scripts/release.sh`/CI; migration-dry-run reversibility job will now find `down.sql`; `ci.yml` comment "not deployable from empty" is contradicted by the 165/165 replay.
- Routed pre-existing items (not touched): `app.current_user_id()` grant/definer regression from 20261212; systemic default-privilege root cause (`ALTER DEFAULT PRIVILEGES … REVOKE`, live DDL decision); no partition scheduler beyond 2027-02.

## Next action
Parent dispatches independent re-audit of 90a66475 (risk-scoped to R2 diff + harness + head-bound log). No R2 clearance claimed. See `R1_FINDINGS_DISPOSITION.md`, `PUBLICATION_MANIFEST.md`, `infra/RECREATE_PG17_SYNTHETIC.md`.
