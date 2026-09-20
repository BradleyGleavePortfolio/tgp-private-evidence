# S1 → S2 interface for composition proof C1–C4 (source-only handoff; nothing here is run by S1)

S1 remains sole owner of fixture, schema, migrations, bootstrap, guard, grants. S2 reuses; S2 does not override the guard or choose an arbitrary target.

## 1. Guarded disposable target (what S2 may connect to)
- Fixture lifecycle is S1-owned: `execution/s1-r3/infra/s1-fixture.sh start|stop|status|url` (start/stop are cheap and do not hold the validation lock; `init`/`destroy` are S1-only and `destroy` is not authorized). S2 asks the parent for a slot; S1 (or the parent using the script) starts the fixture.
- Superuser bootstrap URL: `S1_PG_SUPER_URL=$(execution/s1-r3/infra/s1-fixture.sh url)` → `postgresql://s1_super:…@127.0.0.1:54321/postgres` (synthetic credentials, loopback only).
- **Guard reuse (mandatory, unchanged):** in S2's runner, before any connection or destructive step:
  ```bash
  . /home/user/workspace/worktrees/s1-r3/test/db/_support/s1-target-guard.sh   # head b7d7fe5
  S1_PG_PORT=54321
  S1_PG_DISPOSABLE_CONFIRM="DESTROY-127.0.0.1:54321/<db>,<db>_lock"
  s1_guard_offline  "$S1_PG_SUPER_URL" "<db>"    # refusals exit 64, no connection
  s1_guard_preflight "$S1_PG_SUPER_URL" "<db>"   # ONE bounded read-only connection
  ```
  `<db>` must match `^s1_rls_[a-z0-9_]{1,40}$`. Suggested S2 name: `s1_rls_s2comp` (so its scratch DBs are admitted and are distinguishable from S1's `s1_rls_proof`). The guard refuses any other database on the cluster as FOREIGN, so S2 must not create databases outside that namespace. Call the guard with `set -e` suspended (`set +e; s1_guard_…; rc=$?; set -e`) — see `run-proof.sh` for the pattern.
- Guard facts a rerun must satisfy: cluster `s1-disposable-pg17`, data dir `/home/user/pg17/clusters/s1`, PG 17.x, role flags `postgres=fttt authenticator=fftf service_role=ftff anon,authenticated=ffff` (already true on the current fixture after S1's runs).

## 2. Bootstrap (miniature Supabase-like pre-state) — S1-owned SQL, S2-invoked verbatim
Per S2 database:
```bash
psql "$S1_PG_SUPER_URL" -X -v ON_ERROR_STOP=1 -c "drop database if exists \"<db>\"" -c "create database \"<db>\""
psql "postgresql://s1_super:…@127.0.0.1:54321/<db>" -X -v ON_ERROR_STOP=1 -f /home/user/workspace/worktrees/s1-r3/test/db/_support/supabase-like-bootstrap.sql
```
Bootstrap creates roles idempotently (cluster-wide, harmless on rerun) and the pre-state tables/grants for the S1 migration only. The app connection S2 should then use for Prisma is the non-superuser owner, exactly as the S1 harness does: `postgresql://postgres:postgres_local_synthetic@127.0.0.1:54321/<db>`.

## 3. Migration ledger — how C1–C4 can run the REAL release path without replaying history
The bootstrap is a **miniature** pre-state: it contains only what `20261224000000_rls_close_public_exposure` touches. Running the full `prisma migrate deploy` on it would attempt every historical migration in `prisma/migrations/` against tables that do not exist → guaranteed failure that proves nothing. Two legitimate options; S2 picks one and states it in its packet:

**Option A (recommended): baseline the ledger, then run the exact production command.**
```bash
CLI=/home/user/workspace/worktrees/s1-r3/node_modules/prisma/build/index.js
cd /home/user/workspace/worktrees/s1-r3          # correct cwd: prisma/schema.prisma + migrations live here
for m in $(ls prisma/migrations | grep -E '^[0-9]{14}_' | sort); do
  [ "$m" = 20261224000000_rls_close_public_exposure ] && break
  DATABASE_URL="$APP_URL" node $CLI migrate resolve --applied "$m" --schema prisma/schema.prisma
done
DATABASE_URL="$APP_URL" node $CLI migrate deploy --schema prisma/schema.prisma      # applies ONLY the S1 migration
```
`migrate resolve --applied` writes `_prisma_migrations` rows without executing SQL — this is Prisma's documented baselining mechanism, it is exactly how a pre-existing production database is brought under Migrate, and it makes `migrate deploy` (the real `release.sh` command) apply just the S1 migration. Limitation to state: earlier migrations are ledger-only; their DDL is represented by the bootstrap's hand-built pre-state, so C1–C4 prove the release *command path* and the S1 migration's behaviour, not the historical migrations.
Any migration folder newer than S1's (if 1c6… adds one) must be handled deliberately: either include it in the bootstrap pre-state or `resolve --applied` it too and say so.

**Option B (narrower): compose release.sh's exact commands but point the migration step at S1's harness-tested equivalents** (`psql --single-transaction -f migration.sql` + `verify.sql`). Simpler, but it does not exercise Prisma's ledger/P3018 path — say so explicitly if chosen.

## 4. Drift / recovery hooks available (already proven on the fixture, S1 run 4)
- Drift signal: `node $CLI migrate status --schema prisma/schema.prisma` (exit non-zero with pending/failed rows). `verify.sql` exit code distinguishes ALLOWED-PATH vs EXPOSURE text; `psql -v ON_ERROR_STOP=1 -f prisma/migrations/20261224000000_rls_close_public_exposure/verify.sql`.
- Induce a late-stage failure the S1 way (lock `community_messages_2027_01` from a session tagged `PGAPPNAME=s1_blocker`; release with `pg_terminate_backend` **not** client kill — see harness lines 153–190 at b7d7fe5).
- Recovery after failed deploy (proven): release the lock → `migrate resolve --rolled-back 20261224000000_rls_close_public_exposure` → `migrate deploy` → `verify.sql` exit 0. Reversal: `psql --single-transaction -f down.sql` then `migrate resolve --rolled-back …` (Prisma state unchanged by reversal until resolved — asserted in run 4).
- E-packet recovery directions (`E_RECOVERY_PACKET.md`) remain **directions, not run**; if S2 exercises any of them it becomes S2 evidence, still not S1 self-proof.

## 5. Not provided / not allowed
- No guard bypass, no alternate target, no `S1_PG_*` overrides beyond the values above, no additional databases outside `s1_rls_*`, no `destroy`.
- Do not write into `worktrees/s1-r3` (read-only for S2, including `node_modules`); run Prisma with `--schema` pointing at S2's own integrated worktree if S2 needs 7cbbb039+1c6 content, but keep the CLI path above.
- Concurrency: one fixture, one validation slot; do not run while S1 holds the lock.
