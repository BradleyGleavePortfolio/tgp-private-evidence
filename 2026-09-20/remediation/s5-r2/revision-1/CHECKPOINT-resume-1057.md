# S5 G2 — early checkpoint after 10:57 PDT resume authorization

Time: 2026-09-20 ~11:05 PDT. Lane: S5 (T4 Claude Fable 5 High requested; validation only).
Worktree `/home/user/workspace/worktrees/s5-g2`, branch `execute/20260920-s5-g2`, base HEAD 65b1da27d9dab4f51f5fad6d8a05be8b64e53dde (= R1 audit snapshot 785d9022 tree 9bbc0223), parent d7404cd4 (#529), main c23b9d9f.

## Done since resume (uncommitted working delta, test/harness files only)
- `test/utils/g2-pg17-db.ts`: explicit fixture role matrix constants (admin s5_super / migration postgres / runtime service_role / API anon+authenticated); `withFixturePassword` refuses any non-matrix login role.
- `test/utils/g2-pg17-bootstrap.sh`: creates non-superuser `postgres` LOGIN NOSUPERUSER CREATEDB CREATEROLE BYPASSRLS (password from env), service_role LOGIN BYPASSRLS, anon/authenticated NOLOGIN; DB owned by postgres; Supabase-like default privileges (same shape as S1 fixture `test/db/_support/supabase-like-bootstrap.sql`, not copied); base 164-migration `prisma migrate deploy` runs AS postgres and asserts every public table is owned by postgres; single-shot guard refuses a DB that already has tables (explicit `reset` stage in runner drops only the disposable DB).
- `test/utils/g2-pg17-harness.ts`: all DDL/data via `postgres`; cluster superuser only observes `pg_stat_activity` lock waits; `sqlFile` = `psql --single-transaction -f`; `prisma()` helper returns ok/output for negative CLI assertions; staging PK now includes family+platform so collision assertions isolate product keys (S5-A-10).
- `test/rls-g2-pg17-etq0.spec.ts`: identity asserts user postgres / super:false / bypassrls:true / owner postgres; ported E prerequisite negatives (wrong public index owner up/down, search_path decoys, NOBYPASSRLS owner refused by RLS) onto the populated 1230-row base (S5-A-06); stage 5 recovery adapted from S1's verified semantics: after a successful out-of-band down, `prisma migrate resolve --rolled-back E` is asserted REFUSED (P3012, history unchanged), forward repair = `psql --single-transaction -f migration.sql`, then `migrate deploy` → "No pending migrations" (S5-A-05/B-04 asserted, S1 owns the fix). Collision `toThrow` assertions now match the product constraint names.
- `execution/s5-g2/run-proof.sh`: fail-fast per stage (no live proof after bootstrap failure), timestamped per-stage logs, env log records NODE_OPTIONS=--max-old-space-size=4096 and HEAD/TREE, fixture password required from environment (removed from file).
- Type-check (tsc, 4GB heap): clean for the five S5 files.

## Running next
`run-proof.sh all` (guard → bootstrap → live) queued behind S4 `full-gates` on `execution/test-validation.lock` (holders file), waits ≤30 min, will not kill other jobs.

## Known unknowns
- Live proof has never completed on this fixture (R1 blocker). Timing-sensitive assertions (volume, lock budget 5–30 s, P2002 ROLLBACK count [0,1]) are classified infra/characterization if they fail; one focused unexplained failure stops that slice.
- 2 rolled_back migrations in live history (from S1 R1 notes) — names not yet requested from S1.
