# S1 database closure — independent audit B, round 1 (T4)

**Auditor:** independent auditor B (canonical model Claude Fable 5, High requested; the tool does not expose the actual reasoning setting, so none is claimed). Independent of the builder and of auditor A; no peer report read.
**Written:** 2026-09-20 ~10:45 PDT (17:45 UTC).
**Verdict: NOT CLEARED for T4 (R1).** Source review complete. No defect found in the DDL semantics of the repair itself; one material packaging defect against the repository's own deterministic gate (S1-B-02), one material evidence gap (S1-B-01: no behavioural/boundary/recovery test exists at this head while the source claims one), one external unknown that the candidate correctly gates on (serving role). Details, limits and exact test requests below.

## 1. Snapshot audited

| Item | Value |
|---|---|
| Repository | growth-project-backend (worktree `worktrees/audit-s1-r1`) |
| Head | `620b47fc8517fa5e5950c5b673baf8b002f5c78a` (tag `s1-db-R1`, branch `execute/20260920-s1-database`) |
| Tree | `e9fc265e6dbbe97447e627be20cd467d2016b341` |
| Base | main `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` |
| Commit identity | author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no co-author trailer (checked with `git log --format='%an <%ae> | %cn <%ce>'`) |
| Bundle | `execution/s1-database/bundles/s1-database-R1-620b47f.bundle` — `git bundle verify` okay; single head = 620b47fc |
| Diff vs base | 4 files, +578/−0: `prisma/migrations/20261224000000_rls_close_public_exposure/{migration,verify,rollback}.sql`, `test/db/_support/supabase-like-bootstrap.sql` |

Worktree clean at head. No spec file exists under `test/db/` at this head (`ls test/db/*.spec.ts` → none).

## 2. Scope reviewed and actual actions

Reviewed (read-only): the four changed files; original definitions of the four replaced functions (`20261212000000_community_v1_1_schema`), `app.current_user_id()` (`20260704000000_rls01_helper_searchpath_hibp`), repo RLS convention (`20261220000020_marketplace_abuse_signal_rls`), all migrations referencing the 14 tables, backend RLS context code (`src/common/middleware/rls-context.middleware.ts`, `src/common/interceptors/rls-context.interceptor.ts`), backend/mobile/importer for PostgREST/realtime callers, `scripts/release.sh`, `scripts/ci/*.sql|sh`, `.github/workflows/ci.yml`, `.github/workflows/migration-dry-run.yml`, `prisma/migrations/_supabase_bootstrap.sql`, `package.json` (Prisma 6.19.3), builder artefacts `MILESTONE-01/02`, `PG17_INFRA.md`, `RUNTIME_ROLE_VERIFICATION_PACKET.md`, `whoami-db-role.js`, `run-replay.sh`, `replay-main-c23b9d9.log`.

Actions: `git` read-only inspection; `rg` source searches; public-documentation lookups (PostgreSQL 17 docs, Prisma CLI reference, Supabase docs) to confirm semantics. No source edits, no commits, no installs, no database connections (local or hosted), no credential inspection, no execution of the runtime packet.

## 3. What the candidate does (my independent reading)

1. 14 server-only tables: `ENABLE`+`FORCE ROW LEVEL SECURITY`; `PERMISSIVE FOR ALL TO service_role USING(true) WITH CHECK(true)`; `RESTRICTIVE FOR ALL TO anon` and `TO authenticated` with `USING(false) WITH CHECK(false)`; `REVOKE ALL PRIVILEGES … FROM anon, authenticated`. Fails closed if the three API roles or any table is missing.
2. `community_messages` partitions: every current partition discovered from `pg_inherits` (four at head: `_default`, `_2026_12`, `_2027_01`, `_2027_02`) protected identically by a new `public.community_messages_protect_partition(regclass)`; `community_messages_create_month_partition(date)` re-created to call it; both helpers `REVOKE … FROM PUBLIC, anon, authenticated`, `GRANT EXECUTE TO service_role`.
3. `app.is_community_workspace_coach/member`, `app.shares_community_cohort`: bodies schema-qualified, `SET search_path = ''`; signatures/return types/volatility unchanged; EXECUTE grants untouched.
4. `SET lock_timeout='5s'`, `SET statement_timeout='60s'`; all statements idempotent (`DROP POLICY IF EXISTS` before `CREATE POLICY`, `CREATE OR REPLACE`, idempotent ALTER/REVOKE/GRANT/COMMENT).
5. `verify.sql`: catalog verifier (relrowsecurity/relforcerowsecurity, exact policy shapes, no permissive policy reachable by API roles or PUBLIC, `has_table_privilege` false for anon/authenticated on all four operations, `search_path` pinned on the five functions, API roles cannot EXECUTE the two public helpers). `rollback.sql`: operator reverse with the documented Prisma false-"up to date"/P3012 caveat.

## 4. Semantics I verified independently

- **Partition policies are not applied through the parent; child policies apply only when the child is named.** PostgreSQL 17 docs: "the parent table's row security policies … are applied to rows coming from child tables during an inherited query" and "A child table's policies, if any, are applied only when it is the table explicitly named in the query" ([PostgreSQL 17, Inheritance](https://www.postgresql.org/docs/17/ddl-inherit.html)). The candidate's design (deny direct partition access, leave the parent path governed by the existing community policies) rests on this and is correct. The 20261212 migration's comment that new partitions "inherit … the parent RLS policies" was wrong; the candidate corrects it.
- **Revoking partition grants does not break parent-path callers**: "Inherited queries perform access permission checks on the parent table only" ([PostgreSQL 17, Inheritance](https://www.postgresql.org/docs/17/ddl-inherit.html)). Parent grants are untouched.
- **Timeout bounds are per statement / per lock attempt**: `statement_timeout` "is applied to each statement separately" in a multi-statement simple-query message; `lock_timeout` "applies separately to each lock acquisition attempt" ([PostgreSQL 17, client connection defaults](https://www.postgresql.org/docs/17/runtime-config-client.html)). The 14-table `DO` block is one statement for `statement_timeout` (60 s cap) and each table's ACCESS EXCLUSIVE acquisition is capped at 5 s, so the worst case is bounded and errors rather than queues indefinitely.
- **Atomicity of the script**: PostgreSQL executes a multi-statement simple Query message "as a single transaction, unless explicit transaction control commands are included" ([PostgreSQL 17, protocol flow](https://www.postgresql.org/docs/17/protocol-flow.html)). Whether Prisma 6.19.3 `migrate deploy` sends `migration.sql` as one message is not documented by Prisma; Prisma's own statements have been contradictory ([prisma/orm#22922](https://github.com/prisma/orm/issues/22922)). See S1-B-04.
- **Supabase default privileges are the exposure root cause and their grantor is `postgres`**: Supabase documents that tables created in `public` on existing projects receive SELECT/INSERT/UPDATE/DELETE for `anon`, `authenticated`, `service_role` by default and that the revoke is `alter default privileges for role postgres in schema public revoke …` ([Supabase, Securing your API](https://supabase.com/docs/guides/api/securing-your-api), [Supabase changelog](https://supabase.com/changelog/45329-breaking-change-tables-not-exposed-to-data-and-graphql-api-automatically)). So a `REVOKE` executed by `postgres` (the Prisma migrate role) is effective for grants that arose this way; verify.sql's `has_table_privilege` check catches the case where it is not.
- **Caller map (independent re-derivation)**: backend `src/` contains no `.from('<table>')`, `.rpc(`, or `postgres_changes` usage (only `storage.from(bucket)` and `channel(...)`); the backend never `SET ROLE`s in production code (only test suites do); the RLS interceptor/middleware only `set_config('app.current_user_id' …)`. Mobile creates anon-key clients solely for auth, password reset and realtime channels (`repos/mobile/src/**`), with no table queries. Importer has none. None of the 14 tables is referenced by any trigger, view, or SQL/plpgsql function in the migration history (only their own DDL and comments). `community_messages_create_month_partition` has no application caller; only test teardown drops it. Conclusion matches the builder's: denying `anon`/`authenticated` removes no known legitimate caller.
- **Function replacements preserve behaviour**: bodies equal to the originals except schema qualification; `app.current_user_id()` is itself `SECURITY DEFINER` with its own pinned `search_path`, so an empty caller `search_path` cannot break it; casts/types resolve via the implicit `pg_catalog`. `CREATE OR REPLACE` keeps OIDs so the existing `TO public` community policies keep resolving.
- **Idempotency**: every statement re-runs cleanly by construction; no statement depends on prior partial state except the `RAISE` guards, which are the intended fail-closed behaviour.
- **Builder replay evidence (shared, attributable; reviewed, not re-run)**: `replay-main-c23b9d9.log` shows `prisma migrate deploy` applying all 165 migrations from empty, including `20261224000000_rls_close_public_exposure`, on the isolated PG 17.6 cluster as the fixture's non-superuser BYPASSRLS `postgres` (`run-replay.sh`), exit 0, lock released 17:02:37Z. This proves forward-applicability and that owner privileges suffice in the fixture; it proves nothing about denial/allow behaviour, timeouts, recovery or rollback.

## 5. Findings (stable IDs S1-B-nn)

### S1-B-01 — No behavioural, boundary or recovery test exists at head; source asserts one that does not exist — MATERIAL (evidence gap; blocks clearance)
Evidence: `migration.sql` line 135: "BYPASSRLS roles and the parent path are unaffected — proven by test/db/s1-rls-close-public-exposure.spec.ts". `git ls-tree -r HEAD test/db` lists only `_support/supabase-like-bootstrap.sql`. MILESTONE-02 itself says "WRITTEN, NOT yet locally tested end-to-end".
Consequence: the T4 acceptance row requires denied anonymous/cross-tenant and allowed legitimate operations, partition/future-partition protection, populated-data, timeout, retry and recovery proof. None of that exists for this head, and the candidate's own comment overclaims (G09). Source review cannot substitute for these executions.
Smallest remediation: land the spec (or remove the "proven by" sentence if it cannot land at the final head), and execute the runs listed in §7 on the PG 17.6 fixture with logs bound to the exact head.

### S1-B-02 — Candidate fails the repository's reversibility gate as packaged — MATERIAL (deterministic-gate incompatibility; blocks merge-eligibility)
Evidence: `.github/workflows/migration-dry-run.yml` job `reversibility-check` (lines 454–626) requires, for every migration directory added in a PR, either a sibling `down.sql` or a `^-- IRREVERSIBLE: <reason>` line in `migration.sql`; otherwise `FAIL … lacks both down.sql AND '-- IRREVERSIBLE: <reason>' marker` and the job exits 1. The candidate ships `rollback.sql` (not `down.sql`) and no marker.
Consequence: any PR carrying this directory turns the migration-dry-run workflow red. Because backend main is unprotected, this would not mechanically block a push, but landing with a failing policy check contradicts G07 and the repo's own R106 reversibility rule.
Smallest remediation: rename `rollback.sql` → `down.sql` (the file already claims exact reversal, so it should pass the forward→down→forward `pg_dump --schema-only --no-owner --no-privileges` parity check; note that `--no-privileges` means CI will not prove grant restoration — verify.sql and the spec should). Run that CI job (or its local equivalent) before re-freezing. Alternatively add the `-- IRREVERSIBLE:` marker, but that would be untruthful here since a reverse exists.

### S1-B-03 — Runtime-role verification packet Option A cannot return the answer — NONMATERIAL (packet defect; not executed)
Evidence: `RUNTIME_ROLE_VERIFICATION_PACKET.md` Option A uses `prisma db execute --stdin` with a `SELECT current_user …`. Prisma's CLI reference states the command's output "is not meant for returning data, but only to report success or failure" ([Prisma CLI reference](https://www.prisma.io/docs/orm/reference/prisma-cli-reference)). It would print success and no role.
Also: the `.md` packet's decision columns use `pg_has_role(current_user,'service_role','MEMBER')`; policy applicability follows inherited privileges (USAGE), which the `whoami-db-role.js` probe already adds (`inherits_service_role`) but the `.md` table does not.
Consequence: if the parent/Bradley ran Option A, they would get no evidence and might misread success as an answer. Option B / `whoami-db-role.js` are viable (they print role names, DB name, flags only — no URL, password, env or row data; I found no secret exposure in either). The builder already lists "packet corrections" as pending.
Smallest remediation: delete Option A; make the JS probe (or Option B) the single command; add the USAGE column to the decision table; keep the STOP rule for `bypassrls=false`.

### S1-B-04 — Overstated/imprecise claims in comments and milestone — NONMATERIAL (truthfulness; cheap fix)
- `migration.sql` lines 49–52 and `rollback.sql` header assert Prisma "runs each migration.sql in one transaction on PostgreSQL". Prisma does not document this; atomicity, if observed, comes from PostgreSQL's implicit transaction block for a multi-statement simple query. The candidate's idempotency makes recovery correct either way (partial apply + `migrate resolve --rolled-back` + re-`deploy` converges), so this is precision, not a defect. The pending lock_timeout test should *record* what actually happened (full rollback vs partial) rather than assert it.
- MILESTONE-02 says "Full 168-migration replay"; the log shows 165 migrations found/applied.
- `rollback.sql` header paragraph 2 contains a self-answering draft sentence; cosmetic.

### S1-B-05 — `community_messages_protect_partition` trusts relname and ignores namespace/parentage — NONMATERIAL (hardening)
Evidence: lines 144–163 derive `v_name` from `pg_class.relname` and then act on `public.%I`; there is no check that `p_partition` is in `public` or is a partition of `community_messages`.
Consequence: low — EXECUTE is limited to `service_role`/owner, and `ALTER TABLE`/`CREATE POLICY` still require ownership, so no privilege escalation; but a same-named relation in another schema would be silently mis-targeted.
Smallest remediation: use `p_partition::text`/`pg_namespace` for the identifier and `RAISE` unless `EXISTS (SELECT 1 FROM pg_inherits WHERE inhrelid = p_partition AND inhparent = 'public.community_messages'::regclass)`.

### S1-B-06 — verify.sql proves denial only, not allowed legitimate operations — NONMATERIAL (invariant completeness)
Evidence: no assertion that `service_role` retains table privileges or that the `postgres` role is BYPASSRLS; no assertion that partitions still route from the parent. The rollback also does not restore the original function COMMENTs (cosmetic).
Smallest remediation: add `has_table_privilege('service_role', rel, priv)` = true for all four privileges and `(SELECT rolbypassrls FROM pg_roles WHERE rolname = current_user)` = true (or an explicit skip with reason) to verify.sql; keep the allow-path proof in the spec.

### S1-B-07 — External unknowns the candidate correctly gates on — EVIDENCE GAPS (not defects)
- **Serving DB role** unknown; the candidate is a no-op for BYPASSRLS/`service_role` and the packet defines STOP for `bypassrls=false`. I do not treat the builder's "a non-BYPASSRLS role would already be broken today" argument as proof: the cited FORCE-RLS/service_role-only tables (e.g. `MarketplaceAbuseSignal`) may sit behind feature flags, while core tables use `TO public` policies keyed on `app.current_user_id`, which the interceptor sets — a non-BYPASSRLS role could be *partially* working today. The probe therefore remains a hard prerequisite for any live application.
- **Grantor of production grants**: if not `postgres`, the `REVOKE` is a silent no-op; RLS deny-all still blocks rows, but PostgREST still advertises the relations. verify.sql detects this post-apply; it cannot be settled locally.
- **Ownership in production**: the DDL assumes the 18 relations and 4 functions are owned by `postgres`. If not, `ALTER TABLE`/`CREATE OR REPLACE` errors "must be owner" and the migration fails closed — acceptable but should be confirmed from catalog metadata (read-only) before scheduling.
- **Backups/PITR/restore capability**: external; not producible locally. The verify-after-restore invariant is the right control but is only as good as its wiring (release.sh/CI wiring is S2 scope and absent here).
- **Fixture fidelity**: the local Supabase-like bootstrap is a reasonable reproduction (non-superuser BYPASSRLS `postgres`, NOINHERIT `authenticator`, default privileges) but is not Supabase; CI dry-run uses Postgres 15.18, production is 17.6.

### S1-B-08 — Out-of-scope observations (recorded, not charged to this candidate)
- No scheduler in the backend creates future `community_messages` partitions; from 2027-03 rows land in `community_messages_default`. Pre-existing; the future-partition protection only matters when someone runs the helper.
- The systemic root cause remains: every new `public` table created by `postgres` receives anon/authenticated CRUD via default privileges until its own migration adds RLS. A separate T4 decision on `ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public REVOKE …` (per Supabase guidance above) would close the class; it is live DDL and not part of this candidate.
- `20261212000000_community_v1_1_schema` re-granted `EXECUTE ON app.current_user_id() TO anon` after `20260704…` had revoked it; unrelated to this candidate.
- `ci.yml` still says the migration chain is not deployable from empty; the S1 replay shows it now is (165/165). Worth updating when S2 touches workflows.

## 6. Disposition summary

| ID | Disposition | Blocks clearance? |
|---|---|---|
| S1-B-01 | Material evidence gap + source overclaim | Yes — until spec/runs exist for the final head |
| S1-B-02 | Material packaging defect vs deterministic gate | Yes — trivial fix, requires new head |
| S1-B-03 | Nonmaterial packet defect | No — fix before the packet is handed to Bradley |
| S1-B-04 | Nonmaterial truthfulness/precision | No |
| S1-B-05 | Nonmaterial hardening | No |
| S1-B-06 | Nonmaterial invariant completeness | No |
| S1-B-07 | External evidence gaps | Serving-role probe blocks any *live* application, not local clearance of the source |
| S1-B-08 | Out of scope | No |

Positive conclusions (bound to head 620b47fc): the repair boundary is the smallest caller-compatible one I can construct from source; the pattern matches the repository convention plus an additional grant revoke; partition semantics, permission semantics, and timeout bounds are correct per PostgreSQL documentation; function replacements are behaviour-preserving; the script is idempotent and fails closed on missing roles/tables; nothing is granted to API roles; no secrets, customer data, or environment values appear in the changed files or builder artefacts I read.

## 7. Execution evidence requested from the parent (why + exact command)

All on the isolated PG 17.6 S1 cluster with `test/db/_support/supabase-like-bootstrap.sql` applied, under `execution/test-validation.lock`, logs bound to the exact head. I request these rather than run them because the mandate routes additional tests to the parent and the sandbox is shared.

1. **Denied/allowed matrix** (S1-B-01): as `authenticator` → `SET ROLE anon` and `SET ROLE authenticated`, for each of the 18 relations run `SELECT`, `INSERT`, `UPDATE`, `DELETE` directly (expect `42501 permission denied` or zero rows / RLS violation); as `postgres` and `SET ROLE service_role` expect success. Include a direct read of `community_messages_2026_12` and an insert/select through the parent `community_messages` as `authenticated` with `app.current_user_id` set to a member (expect the pre-existing community policy behaviour, unchanged).
2. **Future partition**: `SELECT community_messages_create_month_partition(DATE '2027-03-01')` as `postgres`; then `verify.sql` must list 5 partitions and pass; as `authenticated`, `SELECT community_messages_create_month_partition(...)` must fail with permission denied.
3. **Lock/timeout failure and retry**: hold `BEGIN; SELECT * FROM "ScheduledDrop" FOR UPDATE;` open in one session, run `prisma migrate deploy` in another; expect failure within ~5 s, a failed `_prisma_migrations` row, and `verify.sql` failing; record whether earlier tables were left protected (partial) or not (atomic). Then `prisma migrate resolve --rolled-back 20261224000000_rls_close_public_exposure && prisma migrate deploy` → success, `verify.sql` OK.
4. **Rollback invariant**: `psql -v ON_ERROR_STOP=1 -f rollback.sql`; `prisma migrate status` (expect false "up to date"); `prisma migrate resolve --rolled-back …` (expect P3012); `verify.sql` FAIL; `psql -f migration.sql` re-apply; `verify.sql` OK.
5. **Populated data**: seed representative rows in all 18 relations before step 3/4; row counts and checksums identical afterwards.
6. **CI gate parity** (S1-B-02): after renaming to `down.sql`, run the `reversibility-check` steps locally (bootstrap → `migrate deploy` → `pg_dump -s --no-owner --no-privileges` → `down.sql` → `migration.sql` → dump → `diff`).
7. **Runtime role** (S1-B-07): parent/Bradley executes only the corrected single probe from inside the Fly machine; outcome table per packet; STOP on `bypassrls=false`.

## 8. Limits of this attestation

This report attests to source review of head 620b47fc only. It does not attest to behaviour, rollout, recovery, or production applicability. Fixing S1-B-02 (and the overclaim in S1-B-01) necessarily changes the head; the follow-up attestation should be risk-scoped to the renamed/edited files plus the new spec and its logs, not inherited. Missing tests and the two material items prevent T4 clearance at this head.
