# S5 → S1 handoff: E recovery wording (S5-R2-A-01 / S5-R2B-02)

Routed via parent to S1 R3 safety fixer (`s1_r3_safety_fixer_muaeeplu`), sole owner of E recovery text, schema, migrations and `down.sql`/`migration.sql`. S5 has NOT edited any of those. S5 only corrected wording inside its own fixture files (`test/utils/g2-pg17-harness.ts` comment, spec comments), which now defer to S1 for recovery semantics.

## Measured facts S5's live proof establishes (head 485c6797, run 20260920T185210Z, 50/50)

1. **E's forward file is not idempotent; it fails closed on rerun.** `psql -f migration.sql` on an already-applied E aborts with `G2-E platform column already exists` and leaves the catalog byte-identical (spec: "E up refuses a raw rerun", `refused(up, 'G2-E platform column already exists')`, `catalog()` unchanged). Any recovery text that says "the forward file is idempotent / safe to re-run" is wrong for E. Correct statement: *forward repair applies only while the column is absent; the catalog (`pg_attribute ... attname='source_platform' AND NOT attisdropped`) is the only truth signal; a rerun on applied E is refused atomically.*
2. **Prisma history is not a truth signal after an out-of-band down.** After a successful `down.sql`, `_prisma_migrations` still shows 165 applied, `prisma migrate deploy` reports "No pending migrations" and would NOT re-apply E; `prisma migrate resolve --rolled-back <E>` is refused (P3012) because there is no failed row. Recovery must start from the catalog check, then run the forward file once.
3. **`--single-transaction` is redundant around E's files.** Both `migration.sql` and `down.sql` open with `BEGIN;` and end with `COMMIT;` (with `SET LOCAL lock_timeout='5s'`, `statement_timeout='30s'`). Wrapping them with `psql --single-transaction` only produces "there is already a transaction in progress" / "there is no transaction in progress" WARNINGs; behaviour is unchanged. The operator form S1 documents should state either `psql -v ON_ERROR_STOP=1 -f <file>` alone, or keep `--single-transaction` and say explicitly that it is harmless/redundant. S5's harness keeps `--single-transaction` so it runs the command the packet currently documents; it will follow whatever S1 settles.
4. **Down against live T is a process-boundary problem, not a lock-budget guarantee.** With production Prisma defaults, the paused T claim's interactive transaction expires (5 s) before E's `lock_timeout` (5 s), so `down` wins on a drained ledger and the T request fails with 500/P2022 (characterized, asserted at 9f38ab03, explicitly labelled not acceptable production behaviour). Only when the fixture widens the transaction ceiling does `down` get refused with a lock timeout (new deterministic test). Recovery/rollout text must therefore require T to be drained/stopped by process control before `down`, and must not present the lock budget as protection for in-flight writers.

## What S5 asks of S1

- Replace "idempotent forward file" wording (if present in the S1 recovery packet) with fact 1; add fact 2's catalog-first ordering; decide fact 3's operator form and tell S5 (interface fact) if the harness should drop `--single-transaction`.
- No change to E SQL is requested by S5. If S1 changes E SQL for any reason, S5's spec strings (`G2-E platform column already exists`, `G2-E refuses removal of assigned provenance`, `G2-E unexpected platform column prerequisite`, `G2-E unexpected identity prerequisite`, `lock timeout`) must be re-checked before the S5 replay.

## Interface facts S5 can give S1/S2 directly

- Catalog check used by S5: `SELECT count(*) FROM pg_attribute WHERE attrelid='public."ScoutReconstructionLedger"'::regclass AND attname='source_platform' AND NOT attisdropped` → `'1'`/`'0'`.
- History check: `SELECT count(*) FROM "_prisma_migrations" WHERE finished_at IS NOT NULL AND rolled_back_at IS NULL` → `165` with E, `164` without.
