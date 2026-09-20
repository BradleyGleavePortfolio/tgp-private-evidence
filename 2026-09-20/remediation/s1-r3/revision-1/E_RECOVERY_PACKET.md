# G2-E recovery packet — `20270118000000_scout_ledger_platform_expand`

**Status of this document: DIRECTIONS, not implemented or executed proof.** Nothing here has been run against any database in R3. Every "state" below is identified by a catalog query the operator runs first; every "action" is conditional on that observed state. Findings addressed: S5-A-05 / S5-B-04 (generic "re-run idempotently" recovery advice is wrong for E), S5-A-09 (accounting comment overclaims). Source read at G2 head `485c679` (`worktrees/s5`): `prisma/migrations/20270118000000_scout_ledger_platform_expand/{migration,down}.sql`, `src/scout/scout-reconstruct.service.ts`.

## 0. What E actually is (facts from source)

- One explicit transaction: `BEGIN; SET LOCAL lock_timeout='5s'; SET LOCAL statement_timeout='30s'; LOCK TABLE "ScoutIngestEntity","ScoutReconstructionLedger" IN ACCESS EXCLUSIVE MODE; DO $$ … $$; ALTER TABLE "ScoutReconstructionLedger" ADD COLUMN source_platform TEXT; COMMIT;`
- The DO block refuses, atomically, when:
  - either identity unique index (`ScoutIngestEntity_coach_id_intent_id_source_id_key`, `ScoutReconstructionLedger_coach_id_intent_id_entity_type_source_id_key`) is missing / not unique / not valid / has a predicate or expression / the table is not `relrowsecurity AND relforcerowsecurity` → `G2-E unexpected identity prerequisite`;
  - `source_platform` already exists on the ledger (any type) → `G2-E platform column already exists`.
- **E is deliberately NOT idempotent.** A second run against an applied database fails by design. The S1-DB-01 advice "re-apply the file with `psql --single-transaction`" does not transfer to E and must not be quoted for it (S1 R3 also removed that generalisation from the S1-DB-01 comments).
- `down.sql` refuses when: identity prerequisites differ (same check), the column is not exactly `TEXT NULL` without default/identity/generated/constraint → `G2-E unexpected platform column prerequisite`, or **any row has `source_platform IS NOT NULL`** → `G2-E refuses removal of assigned provenance`. It never derives, deletes or force-drops.
- E adds no policy, default, backfill, uniqueness, writer or grant change. Table owner is unchanged (whatever role owned the ledger before, `postgres` on Supabase). Because `SET LOCAL` is used, no session setting can leak regardless of outcome.

## 1. State discovery (run first, read-only)

```sql
-- H: Prisma history for E
select migration_name, started_at, finished_at, rolled_back_at, applied_steps_count, logs is not null as has_logs
from _prisma_migrations where migration_name like '20270118000000%' order by started_at;
-- C: column shape
select a.attname, format_type(a.atttypid,a.atttypmod) typ, a.attnotnull, a.atthasdef, a.attidentity, a.attgenerated,
       exists(select 1 from pg_constraint c where c.conrelid=a.attrelid and a.attnum=any(c.conkey)) has_constraint
from pg_attribute a where a.attrelid='public."ScoutReconstructionLedger"'::regclass and a.attname='source_platform' and not a.attisdropped;
-- I: identity prerequisites (both must return exactly one row, unique+valid, forced RLS)
select t.relname, i.indexrelid::regclass, i.indisunique, i.indisvalid, t.relrowsecurity, t.relforcerowsecurity, pg_get_indexdef(i.indexrelid)
from pg_index i join pg_class t on t.oid=i.indrelid
where i.indexrelid::regclass::text in ('"ScoutIngestEntity_coach_id_intent_id_source_id_key"','"ScoutReconstructionLedger_coach_id_intent_id_entity_type_source_id_key"');
-- O/P: ownership and policies (must be unchanged by E)
select relname, pg_get_userbyid(relowner) owner, relrowsecurity, relforcerowsecurity from pg_class where relname in ('ScoutIngestEntity','ScoutReconstructionLedger');
select polname, polpermissive, polroles::regrole[], polcmd from pg_policy where polrelid='public."ScoutReconstructionLedger"'::regclass order by 1;
-- D: data invariant
select count(*) total, count(source_platform) assigned from public."ScoutReconstructionLedger";
```

Record all five results before acting. The expected post-E state is: H = one row with `finished_at` set and `rolled_back_at` null; C = one row `text, notnull=f, hasdef=f, identity='', generated='', has_constraint=f`; I = two rows all `t`; O/P identical to the pre-E snapshot; D `assigned = 0` until the platform writer (a later slice) is enabled.

## 2. States and the ONLY correct action for each

| # | Observed | Meaning | Action |
|---|---|---|---|
| E0 | H empty, C empty, I ok | never applied | `prisma migrate deploy` (normal). Nothing to recover. |
| E1 | H: row with `finished_at` null, `rolled_back_at` null; C empty; logs contain `55P03` / `lock timeout` | failed attempt at the `LOCK TABLE` (contention); transaction rolled back, nothing changed | `prisma migrate resolve --rolled-back 20270118000000_scout_ledger_platform_expand`, then `prisma migrate deploy` in a low-traffic window. Verify C afterwards. |
| E2 | H: failed row; C empty; logs contain `G2-E unexpected identity prerequisite` | the target does not have the identity indexes/forced RLS E depends on | **Do not resolve/redeploy.** Investigate I: the earlier identity migration is missing, altered or the index is invalid. Fix the prerequisite via its own migration/recovery; only then resolve `--rolled-back` and deploy. |
| E3 | H: failed row; C non-empty; logs contain `G2-E platform column already exists` | E was run against a database that already had the column (out-of-band DDL, or a prior successful apply whose history row was lost) | Compare C to the exact expected shape. If exact: `prisma migrate resolve --applied 20270118000000_scout_ledger_platform_expand` is the truthful history repair (the DDL outcome is present). If the shape differs → E5. Never drop the column to make E "re-run". |
| E4 | H: applied row (`finished_at` set); C matches expected shape | applied, healthy | Nothing. A re-run is refused by design; `G2-E platform column already exists` on a rerun is not a fault. |
| E5 | C present but shape differs (NOT NULL, default, constraint, non-text) | not E's column; someone else's DDL | **Not an E recovery.** Escalate to the owner of the ledger schema; do not run E or E-down. |
| E6 | H: applied row; C EMPTY | applied then reversed out-of-band (`down.sql` or manual DROP), Prisma still reports "up to date" (same class of blind spot as S1-DB-01) | Prisma cannot express this (`resolve --rolled-back` → P3012). Forward repair: run `psql --single-transaction -v ON_ERROR_STOP=1 -f .../migration.sql` **only after confirming H says applied and C is empty and I passes** — E's own guards will refuse anything else. Then re-check C. Do not edit `_prisma_migrations`. |
| E7 | `down.sql` failed with `G2-E refuses removal of assigned provenance` | rows carry `source_platform`; drain not proven | State is unchanged (single transaction). Reversal is **not available** until the platform provenance is drained by the owning slice's documented procedure; there is no shortcut. |
| E8 | `down.sql` failed with `G2-E unexpected platform column prerequisite` | column shape is not E's | State unchanged. Same as E5: escalate, do not force-drop. |
| E9 | H contains a `rolled_back_at` row AND an applied row for E | hosted history with a prior failed attempt already resolved, then a successful deploy | Normal. But note the S1-DB-01 observation: with such history `resolve --rolled-back` prints "marked as rolled back" while changing nothing about the applied row — Prisma output is not a state signal; C is. |

Ownership/policy/RLS: E changes none of them. If O/P differ from the pre-E snapshot after any of the above, that drift came from elsewhere; record it, do not "fix" it inside an E recovery.

## 3. What is asserted vs. what is proven

- Asserted from source reading only: the guard messages, transaction shape, `SET LOCAL` behaviour, refusal conditions.
- Proven elsewhere (S5 R2 stage evidence at `485c679`, PG17 synthetic): rerun refusal, down refusal on assigned provenance, atomic failure. S1 R3 has not re-run any of it. **No R3 E execution exists.**
- Smallest follow-up if the parent wants E-state directions executed: a validation-only S5 slot that constructs E1, E3, E6 on the synthetic fixture and records each guard message and history row (~10 min of DB time). S1 would supply this table; S5 owns the run.

## 4. S5-A-09 — accounting comment overclaim (direction + proposed patch, NOT applied)

File: `src/scout/scout-reconstruct.service.ts` (G2 head `485c679`, lines 42–43; the file differs from backend `main c23b9d9`, so this must be applied by the G2 stack owner, not in `worktrees/s1-r3`).

Fact (source): `staged` is `scoutIngestEntity.count({ where })` for the current intent; `tally()` groups **the whole ledger** for `(coach_id, intent_id, entity_type)` by status. Ledger rows that pre-date this replay (legacy/prior runs) are included in `reconstructed/skipped/failed` but not in `staged`. S5 observed exactly this live: 600 staged → 596 reconstructed / 8 skipped / 21 failed (625 = 600 + 25 legacy rows).

Current text (overclaims):
```
 *  - Honest accounting: counts are read back from the durable ledger, so
 *    `staged === reconstructed + skipped + failed` always holds.
```
Proposed replacement:
```
 *  - Honest accounting: `reconstructed`, `skipped` and `failed` are read back
 *    from the durable ledger for this (coach, intent, entity_type), so a replay
 *    reports the ledger's actual state rather than this process's tallies.
 *    `staged` counts the CURRENT staged rows only; the ledger may already hold
 *    rows from earlier runs, so `reconstructed + skipped + failed >= staged`
 *    and equality holds only for a first run against an empty ledger.
```
No behaviour change is proposed; only the comment. If the product wants per-run accounting, that is a separate design decision (owner: G2 stack / Bradley for product intent), not a comment fix.
