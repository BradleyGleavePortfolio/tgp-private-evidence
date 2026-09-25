# S8-C v4 failed proof: parent disposition (EXEC-DACEDDC8, 16:56Z)

## Failed run (preserved unchanged)

PG-4a ran exactly once against candidate `e0cee7e0…` (tree `b249efb6…`) with driver `73b291db…` and fixture `c59326b5…`. It ended `RC=1 STAGE=jest` at 16:49:18Z. Receipts:

- `s8c/binding/v4/run/PROOF_RUN_RECEIPT.md` `281ddbcf…`
- `run/RUN_FREEZE.sha256` `d6203353…`
- `run-prep/LAUNCH_RECEIPTS.sha256`

Nothing is rerun, edited or deleted. The v4 binding is consumed.

## Facts

The v3 bootstrap defect is closed: BOOTSTRAP rc=0, CANDIDATE_CLIENT_VERIFIED, 171 migrations, IDENTITY_OK.

Jest ran 13 of 13 tests and all 13 failed in `beforeEach → catalog()` at `test/utils/g2-s8c-harness.ts:113`. The error was `null value in column "updated_at" of relation "ExerciseCatalogItem" violates not-null constraint`.

The harness raw SQL omits `updated_at`. The committed migration `20260601000000_add_exercise_catalog_video` declares it NOT NULL with no DB default (`@updatedAt` is filled client-side by Prisma). No test body ran, so no product behaviour was exercised or contradicted.

## Classification (Safety ROI)

**Class B (test-harness defect).**

- **Concrete harm:** the S8-C real-PG acceptance cannot pass, so S8-C cannot be accepted or landed. S8-F and S8-G are blocked behind it.
- **Exact decision blocked:** runtime acceptance and landing of S8-C.
- **Minimum closure:** harness-only, under `test/utils/g2-s8c-harness.ts`, and possibly its sibling S8-C test-support files if needed:
  - Every raw INSERT/UPDATE the harness issues must supply every NOT NULL no-default column of its target table, as that table exists after the 171 migrations.
  - The sweep covers all four raw INSERTs (`User`, `ScoutImport`, `ScoutIngestEntity`, `ExerciseCatalogItem`) and any other raw SQL in S8-C test support. Fixing only line 113 would invite the next round.
  - No product source, schema, migration or spec-assertion change.
- **Execution unlocked:** the v5 binding, then dual changed-question review, then one PG-4c proof.

This is not a product defect. Production writes go through Prisma, which sets `@updatedAt`.

## Diagnostic allowance (parent decision)

To avoid another round trip, the builder may run non-accepting diagnostics under the canonical slot on a scratch lane only (`recovery-reset/scratch/s8c-*`, port 55644). It may never use the `proof-v4`/`proof-v5` lanes, the retained v4 pg-data, or a frozen driver.

- **(a)** An authoritative catalog query (information_schema NOT NULL / no-default columns) after applying the migrations with the unchanged bootstrap.
- **(b)** Optionally, the RLS suite against that scratch lane, to surface any further harness defects.

Diagnostic results are recorded under `s8c/harness-correction/diagnostic/` and are never acceptance evidence. The only accepting run is the future PG-4c v5 proof.
