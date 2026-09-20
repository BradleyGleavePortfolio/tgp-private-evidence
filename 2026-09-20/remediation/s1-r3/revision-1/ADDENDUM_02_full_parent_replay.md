# ADDENDUM 02 — withdrawal of `S2_COMPOSITION_INTERFACE.md` §3 ("guaranteed failure" / ledger-only baseline)

Written 2026-09-20 ~23:35 UTC. Original interface note and ADDENDUM 01 preserved unchanged; product source frozen at `b7d7fe5964680050ab441c195055ea946282a9c3`; no execution performed for this addendum (source and run-4 logs read only).

## What §3 claimed, and why it is wrong
§3 said the bootstrap is a "miniature" pre-state on which a full `prisma migrate deploy` would "attempt every historical migration … against tables that do not exist → guaranteed failure that proves nothing", and recommended baselining the ledger with `migrate resolve --applied` (Option A) or bypassing Prisma (Option B).

That contradicts the frozen S1 harness itself and the run-4 evidence:

- `test/db/s1-rls-close-public-exposure.sh` lines 93–98 (`b7d7fe5`): after `supabase-like-bootstrap.sql`, the harness copies `prisma/` to a temp dir, **removes only the candidate** `20261224000000_rls_close_public_exposure`, and runs the **real** `prisma migrate deploy --schema "$TMP/prisma/schema.prisma"` as the non-superuser `postgres` role, then applies the out-of-band `prisma/migrations/rls_fitness_backend.sql` (production pre-state twin).
- Lines 140–144 repeat exactly the same on the second database for the lock/recovery scenario.
- Run 4 (`proof-run-04-head-b7d7fe5.log`): line 34 `PASS replay of parent migration chain (without candidate) as non-superuser postgres`; line 41 `PASS DB2: parent chain + legacy RLS file replayed for the lock/recovery scenario`.
- Detail log (`proof-run-04-head-b7d7fe5-harness-detail.log`): line 4 `164 migrations found in prisma/migrations`, lines 171–503 list **164 applied migration directories** (`00000000000000_baseline` … `20261223000300_scout_reconstructed_entity`) ending `All migrations have been successfully applied.` on `s1_rls_proof`; lines 509–1008 the same **164** on `s1_rls_proof_lock`. With the candidate present the repository has **165** timestamped migration directories (line 1044 `165 migrations found`), so the candidate is the only one not replayed in the pre-state.

So the bootstrap is **not** a miniature: it supplies the Supabase-like role model/default privileges/ownership, and the **entire real parent chain (164 migrations) is replayed through the real `migrate deploy` command**. The ledger is genuine, not baselined. Option A's `resolve --applied` loop is withdrawn as unnecessary and misleading; Option B's stated limitation ("does not exercise Prisma's ledger") is moot.

## Corrected guidance for S2 C1–C4 (reuse the proven S1 pre-state preparation exactly)
```bash
# prerequisites: guard offline+preflight accepted (see interface §1 / ADDENDUM 01-A), fixture running,
# S2 database name inside ^s1_rls_ (dedicated s1_rls_s2comp is fine and leaves s1_rls_proof intact)
WT=/home/user/workspace/worktrees/s1-r3          # or S2's own integrated worktree for 7cbbb039+1c6 content
CLI=$WT/node_modules/prisma/build/index.js        # shared read-only Prisma 6.19.3
cd "$WT"
DB=s1_rls_s2comp
SUPER=postgresql://s1_super:s1_local_synthetic@127.0.0.1:54321/postgres
APP=postgresql://postgres:postgres_local_synthetic@127.0.0.1:54321/$DB
psql "$SUPER" -X -qAt -v ON_ERROR_STOP=1 -c "DROP DATABASE IF EXISTS \"$DB\" WITH (FORCE)" -c "CREATE DATABASE \"$DB\""
psql "${SUPER%/*}/$DB" -X -q -v ON_ERROR_STOP=1 -f test/db/_support/supabase-like-bootstrap.sql
TMP=$(mktemp -d); cp -r prisma "$TMP/prisma"; rm -rf "$TMP/prisma/migrations/20261224000000_rls_close_public_exposure"
DATABASE_URL="$APP" DIRECT_URL="$APP" node "$CLI" migrate deploy --schema "$TMP/prisma/schema.prisma"   # expect: 164 applied
psql "$APP" -X -q -v ON_ERROR_STOP=1 -f prisma/migrations/rls_fitness_backend.sql                       # production pre-state twin
# pre-state now == run-4 pre-state. From here S2 runs the REAL release.sh path (its migrate deploy applies exactly the
# candidate migration(s) — 1 for b7d7fe5 content; more if 1c6… adds migration directories, which is then real too).
```
Observed, not assumed: 164 applied in the pre-state on both databases in run 4; 165 directories present with the candidate; `rls_fitness_backend.sql` is not a migration directory and is applied out of band as in production.

Caveats that DO remain true: PG 17.6 loopback only; Supabase-like roles are synthetic (P1–P4 preconditions); the replay runs as the non-superuser `postgres` role exactly as the harness does; S2 must not write into `worktrees/s1-r3`. ADDENDUM 01 §B (resolve/P3012 facts) stands.
