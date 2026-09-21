# S1 R3 auditor B — precise evidence requests (smallest sufficient)

Subject head `b7d7fe5964680050ab441c195055ea946282a9c3`. Each request names the finding it unblocks, the exact artifact wanted, and what would be judged sufficient. None requires a mutation of any non-disposable target. I will not accept prose in place of the artifact.

## EVIDENCE-REQ-01 — composed release gate actually runs verify.sql (unblocks S1-R3B-02)
- **Artifact:** console log of the *composed* `scripts/release.sh` (S1+S2 tree) run against a disposable `s1_rls_*` database that already contains the applied candidate, plus the same run after one induced drift (`revoke select on table "DunningAttempt" from service_role` **or** `alter table "DunningAttempt" disable row level security`).
- **Sufficient when:** (a) log shows `prisma migrate deploy`, then `prisma db execute … verify.sql` (or psql equivalent) with its exit code; (b) protected run ends 0 and prints `S1-DB-01 VERIFY OK: 18 relations protected (4 community_messages partitions)`; (c) drifted run ends non-zero, prints the `ALLOWED-PATH`/`EXPOSURE` line and release.sh refuses to mark green; (d) header stamps composed head sha, `sha256sum scripts/release.sh`, and `verify_sql_sha256=2bbce0d7ca2e2761f6a6b3d5cebe2df752ac47767f9936d0b77357a46996323e` (unchanged verify.sql) or the new hash with a diff.

## EVIDENCE-REQ-02 — live role / ownership / grantor facts (unblocks S1-R3B-03)
- **Artifact:** output of one read-only query set against the real target (or a schema+ACL dump of it), credentials redacted, run by the operator with a named slot:
  ```sql
  select rolname, rolsuper, rolbypassrls, rolinherit from pg_roles
   where rolname in ('postgres','service_role','authenticator','anon','authenticated','supabase_admin');
  select current_user;  -- as the DIRECT_URL role
  select c.relname, pg_get_userbyid(c.relowner) owner, c.relrowsecurity, c.relforcerowsecurity, c.relacl
    from pg_class c join pg_namespace n on n.oid=c.relnamespace
   where n.nspname='public' and c.relname in ('ClientAssetGrant','CoachMediaAsset','CoachPackageContent','DripResolverMarker','DunningAttempt','MuxProcessedEvent','NudgeLog','PaymentRecoveryToken','PayoutMethod','PurchaseFanout','ScheduledDrop','UserAIQuota','coach_ltv_peak','recent_auth_nonce')
      or c.oid in (select inhrelid from pg_inherits where inhparent='public.community_messages'::regclass);
  select n.nspname, p.proname, pg_get_userbyid(p.proowner) owner from pg_proc p join pg_namespace n on n.oid=p.pronamespace
   where (n.nspname,p.proname) in (('public','community_messages_create_month_partition'),('app','is_community_workspace_coach'),('app','is_community_workspace_member'),('app','shares_community_cohort'));
  ```
- **Sufficient when:** the serving role(s) used by the application and by `DIRECT_URL` are identified by name with `rolbypassrls`, the 18 relations' owner and ACL grantor (`grantor=` in `relacl`, e.g. `anon=arwdDxt/postgres`) are visible, and the four functions' owner equals the migration-executing role. If `relacl` shows a grantor other than the executing role, S1-R3B-03 becomes a DEFECT requiring `REVOKE … GRANTED BY` or execution as that grantor.

## EVIDENCE-REQ-03 — PG 15.18 behaviour (unblocks S1-R3B-04)
- **Artifact:** the GitHub Actions `migration-dry-run` job log for the composed (or b7d7fe5) tree on `postgres:15.18`, including the reversibility step for `20261224000000_rls_close_public_exposure` (forward, `down.sql`, re-apply, dump parity result).
- **Optional but decisive for CI gating:** one `psql … -f verify.sql` run on that same CI database with exit code and message, to establish whether `_supabase_bootstrap.sql`'s missing default privileges produce ALLOWED-PATH failures (expected by my static read).
- **Sufficient when:** exit codes are visible and the parity step reports identical dumps.

## EVIDENCE-REQ-04 — Prisma CLI version pin in the composed tree (carry-over for S1-R3B-06)
- **Artifact:** `sha256sum package-lock.json` of the composed tree **or** `node node_modules/prisma/build/index.js --version` output.
- **Sufficient when:** CLI is `6.19.3` (lockfile `62b05b908c835dae51e54af1e553d91f763a070da21813c4419d66e018d61390`). Any other version → re-run harness section 3 (late-stage blocker) under that version in a named slot; the whole-file rollback claim is version-specific.

## Not requested (already sufficient at this head)
- Guard negative cases (72/72 offline spec at b7d7fe5, hash OK).
- Timeout/atomicity/recovery on PG 17.6 (run 4, stamped hashes match head).
- Verifier exit-code propagation via `prisma db execute` on 6.19.3 (run 4).
