# S1 milestone 02 — R1 candidate frozen for audit (17:02 UTC)

**Head:** `620b47fc8517fa5e5950c5b673baf8b002f5c78a` (tree `e9fc265e6dbbe97447e627be20cd467d2016b341`), branch `execute/20260920-s1-database`, tag `s1-db-R1`, base `c23b9d9f`.
Author/committer Bradley Gleave <bradley@bradleytgpcoaching.com>, no co-author.
Bundle: `execution/s1-database/bundles/s1-database-R1-620b47f.bundle` (verified).
**Status: WRITTEN, NOT yet locally tested end-to-end; NOT audited/merged/deployed.** NEW candidate — no inherited audits.

## Selected repair boundary (smallest caller-compatible)
1. 14 server-only tables (ClientAssetGrant, CoachMediaAsset, CoachPackageContent, DripResolverMarker, DunningAttempt, MuxProcessedEvent, NudgeLog, PaymentRecoveryToken, PayoutMethod, PurchaseFanout, ScheduledDrop, UserAIQuota, coach_ltv_peak, recent_auth_nonce): ENABLE+FORCE RLS, PERMISSIVE `service_role` ALL, RESTRICTIVE deny-all `anon`/`authenticated`, REVOKE API-role table grants. Exactly the repo pattern of `20261220000020_marketplace_abuse_signal_rls`; no allow-all for API roles; nothing new granted.
2. `community_messages` partitions: every current partition discovered from `pg_inherits` and protected the same way (RLS on partitions is not inherited from the parent); future partitions protected inside `community_messages_create_month_partition()` via new `community_messages_protect_partition(regclass)`; EXECUTE revoked from PUBLIC/anon/authenticated on both helpers.
3. `app.is_community_workspace_coach/member`, `app.shares_community_cohort`, `community_messages_create_month_partition`: `SET search_path` pinned; bodies schema-qualified; signatures unchanged (OIDs/policies preserved); EXECUTE grants on app.* untouched (policies are `TO public`).
4. Bounds: `SET lock_timeout='5s'`, `statement_timeout='60s'`; fully idempotent for re-run recovery.
5. Prior-recovery finding encoded: `verify.sql` (catalog truth) + `rollback.sql` warning that after an out-of-band reversal Prisma reports "up to date" and `migrate resolve --rolled-back` refuses (P3012).
Out of scope, deliberately: `WearableProcessedEvent` (RLS-enabled, no policies = intended deny), `release.sh`/CI wiring (S2), Prisma schema (unchanged), any production DDL.

## Evidence completed
- Source caller map: all 14 tables reached only via backend Prisma client; no `.from()`/`postgres_changes` in backend/mobile/importer for any of the 18 relations; mobile uses Supabase for auth + broadcast only; no app caller of the partition function (test-only). Source says app role is `postgres`/`service_role` (both BYPASSRLS) — **source assumption, not runtime fact**.
- PG 17.6 isolated clusters up (S1 :54321, S5 :54325). Supabase-like bootstrap (non-superuser BYPASSRLS `postgres`, `authenticator`, default privileges) written.

## Pending tests (running/next)
- Full 168-migration replay onto PG17.6 as `postgres` (background, test lock) → then apply R1, run `verify.sql`, behavioural spec: anon/authenticated denied (direct table + direct partition, SELECT/INSERT/UPDATE/DELETE), `service_role`/`postgres` allowed, parent-path insert/select with community policies unchanged, `create_month_partition` produces a protected partition, populated data preserved, lock_timeout failure rolls back cleanly + re-run succeeds, rollback → Prisma false "up to date" reproduced → verify fails → idempotent re-apply passes.
- Runtime-role packet corrections (single tested Node/Prisma read-only tx query) after local measurement.

## Material unknowns / blockers
- Actual Fly serving DB role (external gap; no exec authorised). Candidate is designed to be a no-op for BYPASSRLS/service_role but a non-BYPASSRLS serving role would require re-mapping before any live change.
- Grantor of the existing anon/authenticated grants in production: if not `postgres`, `REVOKE` by `postgres` is a no-op (verify.sql catches via `has_table_privilege`).
- Backups/PITR/restore evidence: external; not producible locally.
- Full history replayability from empty DB: being measured now.
