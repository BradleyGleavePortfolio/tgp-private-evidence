# S1 database closure — independent audit A, round 1 (T4)

**Auditor:** independent auditor A (Claude Fable 5 requested, High requested; actual reasoning setting not exposed by the tool and not claimed). Independent of the S1 builder and of auditor B; no peer report read.
**Written:** 2026-09-20, finalized 10:15 PDT on parent instruction (finalize with available evidence; do not wait for pending tests).
**Report status:** complete source review; execution evidence partially unavailable (see §6). **Verdict: NOT CLEARED** (§8).

## 1. Snapshot identity

| Item | Value |
|---|---|
| Repository | growth-project-backend (worktree `worktrees/audit-s1-r1`) |
| Head | `620b47fc8517fa5e5950c5b673baf8b002f5c78a` (verified with `git rev-parse HEAD`) |
| Tree | `e9fc265e6dbbe97447e627be20cd467d2016b341` (verified with `git rev-parse HEAD^{tree}`) |
| Base | main `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` |
| Diff vs base | 4 files, +578/−0: `prisma/migrations/20261224000000_rls_close_public_exposure/{migration.sql,verify.sql,rollback.sql}`, `test/db/_support/supabase-like-bootstrap.sql` |
| Builder handoff read | `execution/s1-database/MILESTONE-02-R1-frozen.md`, `MILESTONE-01-infra.md`, `PG17_INFRA.md`, `RUNTIME_ROLE_VERIFICATION_PACKET.md`, `replay-main-c23b9d9.log`, `run-replay.sh` |

Governing sources read: `repos/context/AGENT_RULES.md` (G06/G07/G09/G12/G13), `execution/EXECUTION_RULES.md`, `execution/audits/R1_COMMON.md`, S1 acceptance row in `deliverables/TGP-Fitness-Execution-Takeover-Brief.md`.

## 2. Actual actions taken

Read-only throughout. No source edits, no commits, no installs, no live/production queries, no local database execution, no credential inspection.

- Verified head/tree; read the full 4-file diff.
- Read unchanged dependencies: original partition/helper definitions in `20261212000000_community_v1_1_schema`, `20261212000000_rls_helper_search_path`, `20260704000000_rls01_helper_searchpath_hibp`, the repo RLS pattern `20261220000020_marketplace_abuse_signal_rls`, `scripts/ci/check-relrowsecurity.sh`, `scripts/ci/supabase-shim.sql`, `prisma/migrations/_supabase_bootstrap.sql`, `.github/workflows/ci.yml`, `.github/workflows/migration-dry-run.yml`, `scripts/release.sh`, `fly.toml`, `Dockerfile`, `src/common/middleware/rls-context.middleware.ts`, `src/common/interceptors/rls-context.interceptor.ts`, `src/coach-media/supabase-storage.provider.ts`, `test/community/_support/community-db.ts`, `test/community/schema/community-schema.spec.ts`, `prisma/schema.prisma` datasource block, `package.json` (Prisma `^6.19.3`).
- Independently re-derived the caller map: `rg` over backend `src/` for `SET ROLE`/`set_config('role'`, `.from(`/`.rpc(`/`postgres_changes`/`storage.objects`; over `repos/mobile` (a5933fd) and `repos/importer` (0111be6) for Supabase data-API usage.
- Checked PostgreSQL 17 documentation (inheritance/RLS, BYPASSRLS/FORCE, SET semantics) and Prisma behaviour (single simple-query implicit transaction; `directUrl` use by CLI) via public web sources; citations inline below.
- Reviewed the runtime-role verification packet as a proposal only (not executed).
- Inspected (read-only) the builder's shared replay log as attributable evidence; noted an untracked `test/db/s1-rls-close-public-exposure.sh` in the builder worktree that is **not** part of the frozen head and was not evaluated.

## 3. Reviewed scope

Authorization (RLS/grants/policies) on the 14 server-only tables and the `community_messages` partitions (current and future); function `search_path` pinning and EXECUTE grants; caller compatibility (backend Prisma role, PostgREST roles, mobile, importer, Supabase Storage); rollout bounds (lock/statement timeouts), retry and recovery under Prisma `migrate deploy`; `verify.sql` and `rollback.sql` correctness; deterministic-gate compatibility; truthfulness of claims in the artifact and handoff.

Out of scope (unchanged, pre-existing): `WearableProcessedEvent`, `release.sh`/CI wiring (S2), Prisma schema, all other tables' policies, production backups/PITR.

## 4. What is correct (independently confirmed)

- **Pattern fidelity.** The per-table block (ENABLE + FORCE RLS, PERMISSIVE `FOR ALL TO service_role`, RESTRICTIVE deny-all `TO anon` / `TO authenticated`) matches `20261220000020_marketplace_abuse_signal_rls` exactly; the added `REVOKE ALL ... FROM anon, authenticated` is strictly tightening. No grant is added for any API role.
- **Partition semantics are correctly reasoned.** PostgreSQL applies the parent's policies to rows from children in an inherited query, and "a child table's policies, if any, are applied only when it is the table explicitly named in the query" ([PostgreSQL 17 docs, inheritance](https://www.postgresql.org/docs/17/ddl-inherit.html)). So deny-all on partitions leaves the parent path (`community_messages`) governed only by the unchanged parent policies, and closes direct `/rest/v1/community_messages_YYYY_MM` access. The DEFAULT partition is covered via the `pg_inherits` loop. Future partitions created via `community_messages_create_month_partition()` are protected at creation.
- **BYPASSRLS/FORCE interplay.** "Superusers and roles with the BYPASSRLS attribute always bypass the row security system"; FORCE only subjects non-bypass owners ([PostgreSQL 17 docs, RLS](https://www.postgresql.org/docs/17/ddl-rowsecurity.html)). The candidate is therefore a no-op for a BYPASSRLS serving role and for `service_role`. This does **not** establish the real serving role (see S1-A-06).
- **Caller map re-derived and consistent with the builder.** Backend never issues `SET ROLE`/`set_config('role')`; it only sets `app.current_user_id`/`app.current_user_role` GUCs (`rls-context.middleware.ts`, `rls-context.interceptor.ts`). No backend/mobile/importer code uses PostgREST `.from()`/`.rpc()` or realtime `postgres_changes`; mobile uses `@supabase/supabase-js` only for auth and `channel()` broadcast (`src/api/communityRealtime.ts`, `src/services/realtime.ts`, `src/utils/supabaseAuth.ts`). Supabase Storage is used server-side with the service-role key (`supabase-storage.provider.ts`); no `storage.objects` policies in the repo reference the 14 tables. Partition tables are referenced directly only by tests.
- **Function bodies validate under the pinned `search_path`.** PostgreSQL applies `proconfig` before the validator runs, and the builder's replay applied the candidate successfully as the non-superuser BYPASSRLS `postgres` role on PG 17.6 (`replay-main-c23b9d9.log`: 165 migrations, "All migrations have been successfully applied", exit 0). Signatures are unchanged so `CREATE OR REPLACE` preserves OIDs and dependent policies.
- **Transactionality claim holds.** Prisma sends the whole `migration.sql` as one simple query, which PostgreSQL runs as an implicit transaction ([prisma/orm#22922](https://github.com/prisma/orm/issues/22922), [prisma discussion #10601](https://github.com/prisma/prisma/discussions/10601)); a `lock_timeout` error therefore rolls back the entire migration, and the documented `migrate resolve --rolled-back` + re-deploy path is the correct Prisma recovery.
- **Populated-data risk is bounded by design.** `ENABLE/FORCE ROW LEVEL SECURITY`, `CREATE POLICY`, `REVOKE` and `CREATE OR REPLACE FUNCTION` are catalog-only, O(1) in row count; no rows are read or rewritten. The residual rollout risk is lock contention, which is bounded (S1-A-03 refines this).
- **`verify.sql` is catalog-truthful.** It checks `relrowsecurity`/`relforcerowsecurity`, exact single-role policy sets, absence of PERMISSIVE policies reachable by `anon`/`authenticated`/PUBLIC, effective `has_table_privilege` (catches a silent no-op REVOKE by a non-grantor), `search_path` pinning on all 5 functions and EXECUTE denial on the two public helpers. The "Prisma reports up to date after out-of-band reversal" invariant is correctly encoded and is a real Prisma limitation.
- **Precondition fail-closed.** The migration RAISEs if the three API roles are missing, rather than silently creating policies on a target without them.

## 5. Findings

Stable IDs `S1-A-NN`. "Material" means it blocks T4 clearance for this candidate under G11 until closed; "nonmaterial" is recorded for closure hygiene only.

### S1-A-01 — Candidate fails the existing deterministic reversibility gate (`down.sql` / `IRREVERSIBLE` marker) — **MATERIAL (landing blocker, trivial fix)**

**Evidence.** `.github/workflows/migration-dry-run.yml` (unchanged, triggered by `pull_request` with `paths: prisma/migrations/**`) job `reversibility-check` iterates every migration directory *added* in the PR and fails unless the directory contains a sibling **`down.sql`** or `migration.sql` contains a line matching `^-- IRREVERSIBLE:` (lines 574–592). The candidate ships **`rollback.sql`** and no `IRREVERSIBLE` marker. Ten existing migration directories follow the `down.sql` convention; none uses `rollback.sql`.

**Consequence.** The PR's migration-dry-run workflow fails deterministically on the frozen head. Under G07 this trusted check may not be weakened to admit the candidate; under G17 a failing applicable check blocks landing regardless of whether the job is currently in the required-status list (path-filtered jobs are deliberately not "required" per `scripts/setup-branch-protection.sh`, but a red deterministic gate is still a defect, not noise).

**Secondary effect.** Once renamed, the gate will run forward → `down.sql` → forward and compare `pg_dump --schema-only --no-owner --no-privileges` output for byte identity. My source reading says parity should hold (policies, RLS flags, function bodies and comments return to identical state; ACLs are excluded by `--no-privileges`), but that has not been executed — it is an evidence gap (§6).

**Smallest remediation.** Rename `rollback.sql` → `down.sql` (content unchanged) and update the three in-file references (`migration.sql` INVARIANT comment, `verify.sql` header, `rollback.sql` header). Alternatively add `-- IRREVERSIBLE: <reason>` — but the candidate *is* reversible, so the marker would be untruthful; rename is the correct fix.

### S1-A-02 — `migration.sql` cites a proof artifact that does not exist at the head — **MATERIAL (truthfulness, G09)**

**Evidence.** `migration.sql` §2 comment: "BYPASSRLS roles and the parent path are unaffected — **proven by test/db/s1-rls-close-public-exposure.spec.ts**." No such file exists at `620b47fc` (`test/db/` contains only `_support/supabase-like-bootstrap.sql`). The builder worktree holds an untracked `test/db/s1-rls-close-public-exposure.sh`, not part of the frozen candidate, and the milestone itself lists all behavioural tests as *pending*.

**Consequence.** The committed artifact asserts a proof that has not run and is not in the candidate. This is exactly the overclaim class G09 forbids, and it would mislead any future reader/auditor of the migration history.

**Smallest remediation.** Change the comment to "intended to be proven by …; see execution evidence" until a test lands in the same head; or land the test in the candidate and re-freeze.

### S1-A-03 — Session-level `SET lock_timeout/statement_timeout` leak into every later migration in the same deploy — **MATERIAL-LOW (reliability/determinism; trivial fix)**

**Evidence.** `migration.sql` lines 63–64 use `SET` (not `SET LOCAL`) and never `RESET`. Prisma applies pending migrations sequentially over one connection, each as an implicit transaction (§4). Per PostgreSQL, "once the surrounding transaction is committed, the effects will persist until the end of the session" ([PostgreSQL 17 docs, SET](https://www.postgresql.org/docs/17/sql-set.html)). Therefore, in any `migrate deploy` run where migrations sorted after `20261224000000_…` are also pending (fresh replay in CI/shadow DB/staging, or a production deploy that ships this together with later migrations), those later migrations run under `lock_timeout=5s` and `statement_timeout=60s` that they did not declare.

**Consequence.** Environment-dependent failures of unrelated future migrations — notably the S5/G2 populated-data phases the plan depends on, whose backfills may legitimately exceed 60 s. The failure appears in environments where both migrations are pending together and not in environments where this one was applied earlier: a hidden, nondeterministic coupling. Recoverable (Prisma marks failed, `resolve --rolled-back`), but it would abort a Fly release (`release_command` 5-min budget, `fly.toml`) for a reason unrelated to the failing migration's own content. No data-loss consequence.

**Smallest remediation.** Append `RESET lock_timeout; RESET statement_timeout;` as the last statements of `migration.sql` and `rollback.sql`/`down.sql` (SET is transactional, so an aborted migration already discards the values); or use `SET LOCAL` and document `psql --single-transaction` for manual runs.

### S1-A-04 — Runtime-role packet Option A measures the wrong URL — **NONMATERIAL for the candidate; MATERIAL for the packet if adopted as authority**

**Evidence.** `RUNTIME_ROLE_VERIFICATION_PACKET.md` states "`prisma db execute` uses the `datasource` URL (DATABASE_URL)". `prisma/schema.prisma` defines both `url` and `directUrl`, and Prisma ≤ 6.19 documents that "Prisma CLI commands that require a direct connection to the database use the URL in the `directUrl` argument" ([Prisma config reference, v6](https://www.prisma.io/docs/orm/v6/reference/prisma-config-reference)). Option A would most plausibly report the **migration** role (DIRECT_URL, `postgres.<ref>` per the schema comment) while labelling it as the serving role. Option B (`new PrismaClient()` + `$queryRaw`) uses `url` and is the correct measurement. Additionally, `inet_server_port()` reports the PostgreSQL server-side port (5432) even when the client connected through the Supavisor pooler, so it cannot distinguish 6543 vs 5432 as the packet claims.

**Consequence.** If the parent/Bradley executes Option A, the STOP/GO table could be answered with the wrong role and the candidate's central compatibility assumption would be "verified" on a false basis. Both options print only role/flag columns and no secrets — the packet's redaction invariants are sound.

**Smallest remediation.** Make Option B the authoritative measurement of the serving role; if Option A is kept, pass `--url "$DATABASE_URL"` explicitly and label the result as the role of whichever URL was passed; drop the port inference or read the pooler port from the (redacted) URL scheme instead.

### S1-A-05 — Manual `rollback.sql` and re-apply-via-psql paths are not atomic — **NONMATERIAL (operator guidance)**

`rollback.sql` and the documented recovery ("run migration.sql again directly") are executed statement-by-statement by `psql -f`; a mid-file failure (e.g., `lock_timeout` on one table) leaves a mixed state. Both scripts are idempotent so a re-run converges, and `verify.sql` detects drift, but the guidance should say `psql --single-transaction -v ON_ERROR_STOP=1`. Also, `rollback.sql`'s claim to restore state "EXACTLY" is slightly over-stated: `app.*` bodies stay schema-qualified (behaviour-identical) and any partitions created after the migration receive `GRANT ALL TO anon, authenticated` they never had. Neither alters the security conclusion.

### S1-A-06 — Serving-role and caller-matrix closure remains external — **EVIDENCE GAP (not a defect of the candidate)**

The candidate is caller-neutral only if the Fly process's `DATABASE_URL` role is BYPASSRLS or `service_role`. The builder's inference (the app already reads many FORCE-RLS/service_role-only tables such as `MarketplaceAbuseSignal`, so a non-bypass role "would already be broken") is strong but circumstantial: it assumes those code paths are exercised in production and that a partially broken state would have been noticed. The acceptance row requires the *actual* serving-role/caller matrix. This can only be closed by the parent/Bradley-authorized read-only measurement (S1-A-04 corrected). Until then, no live DDL may be applied — the candidate itself says so and I concur.

### S1-A-07 — Robustness nits — **NONMATERIAL**

- `community_messages_protect_partition(regclass)` resolves the relation name but hard-codes `public.%I`; a partition in another schema (none today) would either fail or, worse, alter a same-named table in `public`. Use `p_partition::text` or `pg_class.relnamespace` for the target.
- `GRANT EXECUTE ... TO service_role` on both helpers is harmless but misleading: `CREATE TABLE … PARTITION OF` / `ALTER TABLE` require ownership of the parent/partition, so only the owner (`postgres`) or a superuser can actually run them (pre-existing).
- Partitions created by any path other than the helper (manual DDL, a future migration adding partitions directly as `20261212000000` did) will not be protected automatically; `verify.sql` and `scripts/ci/check-relrowsecurity.sh` (soft mode) would detect it. Recommend scheduling `verify.sql` after every deploy/restore (S2 wiring) and revisiting an event trigger later.
- Milestone says "168-migration replay"; the log shows 165 applied (169 directory entries minus 4 non-migration files). Cosmetic, but the handoff number should match the log.
- The `DO $s1$` block for 14 tables is a single statement, so `statement_timeout=60s` bounds the whole block, not each table; ACCESS EXCLUSIVE locks acquired on earlier tables are held while waiting (≤5 s each) on later ones, including the hot `recent_auth_nonce`. Bounded and acceptable, but the migration comment "brief ACCESS EXCLUSIVE lock" understates worst-case hold time; recommend a low-traffic window in the live packet.

### Pre-existing, out of S1 scope (recorded, not counted)

`20261212000000_community_v1_1_schema` re-created `app.current_user_id()` without `SECURITY DEFINER`/pinned `search_path` and re-granted EXECUTE to `anon`, partially undoing `20260704000000_rls01_helper_searchpath_hibp`; `20261212000000_rls_helper_search_path` (sorts after it) re-pins `search_path` but not the grant/definer changes. The Supabase advisor did not flag `current_user_id`, so production state is consistent with this ordering. Not introduced or touched by the candidate; parent may route separately.

## 6. Evidence gaps (execution not available at finalization)

None of the following was run on the frozen head; the builder's milestone lists them as pending, and per the parent's finalization instruction I did not wait or run them myself. Each is required before either attestation can apply:

1. `verify.sql` executed against a PG 17.6 database after `migrate deploy` of the head (psql exit 0 with the `VERIFY OK` notice).
2. Behavioural spec: `anon` and `authenticated` (via `SET ROLE` under a NOINHERIT `authenticator`) denied SELECT/INSERT/UPDATE/DELETE on all 14 tables **and** on each partition directly; `service_role` and BYPASSRLS `postgres` allowed; parent-path `community_messages` INSERT/SELECT behaviour unchanged under the existing `community_rls_test_role` harness; `community_messages_create_month_partition('2027-03-01')` yields a partition that passes `verify.sql`.
3. Populated-data preservation: seed rows in the 18 relations before applying; assert identical counts/contents afterwards for a bypass role.
4. Lock-timeout failure/recovery: hold an open transaction on `recent_auth_nonce`, run `migrate deploy`, assert failure within ~5 s, a failed `_prisma_migrations` row, `verify.sql` failing cleanly (no partial state), then `migrate resolve --rolled-back` + `migrate deploy` succeeding and `verify.sql` passing.
5. Rollback invariant: apply `rollback.sql`, assert `prisma migrate status` still says up to date and `resolve --rolled-back` refuses (P3012), `verify.sql` fails, re-apply `migration.sql` idempotently, `verify.sql` passes.
6. Reversibility gate parity (after S1-A-01 rename): forward → `down.sql` → forward, normalized `pg_dump -s` byte-identical.
7. Serving-role measurement (S1-A-06) under parent/Bradley authority, using the corrected packet (S1-A-04).
8. Backups/PITR/restore capability: external; not producible in the sandbox.

The builder's full-history replay (`replay-main-c23b9d9.log`) is accepted as attributable evidence that the candidate **applies cleanly from empty on PG 17.6 as a non-superuser BYPASSRLS owner**; it does not prove any denial, preservation, or recovery behaviour.

## 7. Disposition summary

| ID | Title | Disposition |
|---|---|---|
| S1-A-01 | Fails existing `down.sql`/IRREVERSIBLE gate (ships `rollback.sql`) | **Material** — landing blocker; rename |
| S1-A-02 | Migration comment cites a non-existent proof file | **Material** — truthfulness; reword or land test |
| S1-A-03 | Session-level timeouts leak into later migrations | **Material-low** — add `RESET`/`SET LOCAL` |
| S1-A-04 | Runtime packet Option A measures DIRECT_URL role; port inference invalid | Nonmaterial for candidate; **must fix before the packet is executed** |
| S1-A-05 | Manual rollback/re-apply not atomic; "EXACTLY" over-stated | Nonmaterial |
| S1-A-06 | Actual serving role / caller matrix unverified | Evidence gap (external) |
| S1-A-07 | Robustness nits, count mismatch, lock-hold wording | Nonmaterial |

No security regression, cross-tenant widening, data-loss path, or credential exposure was found in the candidate. The authorization design is correct and tightening-only for the 18 relations, and the function `search_path` hardening is behaviour-preserving.

## 8. Verdict and limits

**NOT CLEARED for T4 at head `620b47fc8517fa5e5950c5b673baf8b002f5c78a`.**

Reasons: two material findings on the frozen artifact (S1-A-01 deterministic gate failure; S1-A-02 untrue proof claim) plus one material-low reliability defect (S1-A-03), and the absence of every behavioural, populated-data, recovery and reversibility execution proof required by the S1 acceptance row (§6 items 1–6), with the serving-role matrix (item 7) still external.

What this verdict does **not** say: it does not find the security design wrong, does not require architectural rework, and does not contradict the builder's compatibility reasoning — it records that the reasoning is not yet *proven* and that the artifact as frozen would not pass its own repository's gates. All three material items have one-line remediations; a re-frozen head carrying them plus the §6 execution evidence can be re-attested with risk-scoped applicability (G10), not inherited approval.

**State of the candidate as I can attest it:** written; applies cleanly from empty on PG 17.6 (builder replay); **not** behaviourally tested; **not** audited-clear; not merged; not deployed; not live-verified; no production DDL authorized by this report.

## 9. Requests to parent

1. Execute §6 items 1–6 on the (re-frozen) head under the test-validation lock; attach logs bound to the exact head.
2. Correct the runtime-role packet per S1-A-04 before seeking Bradley's authority to run it; run Option B (or `--url "$DATABASE_URL"`) inside the Fly machine; share only the role/flag columns.
3. Route the pre-existing `app.current_user_id()` grant/definer regression (§5, last item) to the appropriate owner as a separate finding.

No secrets, customer records, raw environment values or sensitive log payloads are included in this report.
