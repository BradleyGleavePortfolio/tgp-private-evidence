# S8C-BC-3 diagnostics — findings (NON-ACCEPTING; scratch lane 55644 only)

Builder `s8c_bootstrap_completion` (T4). Scratch lane `recovery-reset/scratch/s8c-diag` (pg-data + run), port 55644, own
`diag-lane.sh` (same initdb recipe/marker as the S8-C fixture, never the frozen fixture/driver, never proof-v4/proof-v5 or the
retained v4 pg-data). Both runs held the canonical slot via `flock -n` (inode 674373) and exited with 0 holders, 0 postgres,
55644 free, pg-data retained (76 MB) with no `postmaster.pid`. Slot order respected: nothing acquired until the S7-L v4 LAUNCHER
showed `END rc=0 2026-09-25T17:00:22Z` and lslocks showed 0 holders.

## (a) authoritative catalog — `diag-a-catalog.sh`, rc=0
Slot 17:02:44Z → 17:02:53Z. Clean tree at `e0cee7e0…`. Fresh initdb, unchanged committed `test/utils/g2-s8c-bootstrap.sh bootstrap`
rc=0 (`G2_S8C_BOOTSTRAP_OK`, 171 applied). information_schema (public): 2163 columns, 808 NOT NULL/no-default/non-identity/
non-generated; for the five tables the S8-C test support writes raw: 27 columns (`a/required_no_default_harness_tables.tsv`):

- `User`: id, supabase_id, email, name — harness supplies all (+role).
- `ScoutImport`: id, coach_id, intent_id — supplied.
- `ScoutIngestEntity`: id, coach_id, intent_id, entity_type, source_id, source_platform, payload — supplied.
- `ExerciseCatalogItem`: id, slug, name, category, primary_muscle, **updated_at** — `updated_at` was omitted → the PG-4a failure.
- `ScoutReconstructionLedger`: id, coach_id, intent_id, entity_type, source_id, status, source_platform — both spec INSERTs supply all.

Exactly one omission, matching `../STATIC_SWEEP.md`. The prepared one-function fix was then applied and committed as
`9cc764013fd1d726dad082eebfa7def50800a6b2` (see `../run/s8c-harness-gate.log`).

## (b) RLS suite at the clean corrected head — `diag-b-suite.sh`, jest rc=1
Slot 17:04:52Z → 17:05:44Z. Head `9cc76401…` porcelain 0; same scratch DB (no re-bootstrap; the DB holds no head).
`Tests: 3 failed, 10 passed, 13 total (50.07 s)`. The `catalog()` defect is closed: every `beforeEach` passed and 10 test
bodies ran green, including replay, program-day convergence, two-coach isolation, concurrent convergence, held-ledger retry,
legacy precedence and archive/no-downgrade. Three further defects surfaced — **none is in the harness file, none is fixable
within the S8C-BC-3 harness-only grant, and none looks like a product defect** (classification is the parent's/reviewers'):

| # | Test | Observed | Cause (read-only) | Minimum closure candidates (outside grant) |
|---|---|---|---|---|
| F1 | lane identity › is the S8-C disposable PG17 lane … | `ERROR: permission denied to examine "data_directory"` (needs `pg_read_all_settings`) at `spec.ts:94` | The identity observation runs through `json()` = migration role `postgres` (NOSUPERUSER). PG restricts `data_directory` to superusers / `pg_read_all_settings`. Fixture roles are correct; the observation role is wrong. | `spec.ts:93` `json(` → `jsonAdmin(` (cluster superuser `s8c_super`; assertion values unchanged) — a spec observation-call change, or `GRANT pg_read_all_settings TO postgres` in the bootstrap (changes fixture privilege model; less minimal). |
| F2 | native persistence › creates a standalone WorkoutPlan … | `weight_lbs` received `220.4622621848776`, expected `toPounds(100,'kg')` = `220.46226218487757` | Stored double is exactly 1 ulp above (`0x406b8ecada10c742` vs `…c741`): a Float round-trip through the Prisma client/engine is not bit-exact. `toPounds` (`native-contract.ts:131`, `value / KG_PER_LB`) is correct; the writer passes it unchanged. | Spec assertion tolerance (`toBeCloseTo(toPounds(100,'kg'), 9)` or compare rounded) — a spec-assertion change. |
| F3 | client principal (N2) › … no plan, no User | `count('User')` received 2, expected 1 | Accepted migration `20261215000100_seed_b5_contract_templates` seeds the system-coach `User` `b5-system-coach-tgp`; with the fixture coach that is 2 rows before any writer runs. The writer created no User (no `User` write exists in `src/scout/reconstruct/native/*`). | Spec assertion scoped to non-seed rows (e.g. `count('User', "id <> 'b5-system-coach-tgp'")` or `id = 'coach'`) or a before/after equality — a spec-assertion change. |

Passing list and full output: `b/jest.log` (sha256 `254afd05ff805c951c41355a087e7ffbf45148ea81503b719a3f1f48c1dd5791`).

## Consequence
A v5 binding of `9cc76401…` would fail PG-4c 3/13 for the reasons above. Per the standing invariant ("a failure is preserved
and stopped for disposition, never looped") step 4 (checkpoint v7 / binding v5 / run-prep v5) is WITHHELD until the parent
disposes of F1–F3. No further commits were made (one-commit grant). Nothing was rerun.

## Receipts
- `a/RECEIPTS.sha256` (`6ac8977d…`; `diag-a.log` there is hashed before its final END line = `937443cb…`; complete `67b2f493…`)
- `b/RECEIPTS.sha256` (`9b94442a…`; `diag-b.log` pre-END `4e0630ad…`; complete `12324b87…`; `jest.log` `254afd05…`)
- scripts: `diag-lane.sh` `383dbb68…`, `diag-a-catalog.sh` `3b7495ee…`, `diag-b-suite.sh` `420322a1…`
