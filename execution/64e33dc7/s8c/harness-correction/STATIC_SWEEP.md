# S8C-BC-3 static sweep of raw SQL in S8-C test support (source-only, 17:00Z)

Base: worktree `/home/user/workspace/worktrees/64e33dc7-s8c` at `e0cee7e04bef88811310f6dde1fd921f45d103ad`, porcelain 0.
Files swept (`rg -n 'INSERT|UPDATE |DELETE|CREATE |ALTER '`): `test/utils/g2-s8c-harness.ts`, `test/utils/g2-s8c-pg-harness.ts`,
`test/utils/g2-s8c-db.ts`, `test/utils/g2-s8c-worker.cjs`, `test/rls-g2-s8c.spec.ts` (fixture SQL only; assertions untouched).
Column facts come from the committed migrations (CREATE TABLE + later ALTERs), cross-checked against `prisma/schema.prisma`;
the authoritative confirmation is diagnostic (a) `diagnostic/a/required_no_default_harness_tables.tsv` (information_schema after
the 171 migrations on the scratch lane).

| # | File:line | Statement | Target | NOT NULL / no-default columns (migrations) | Supplied | Missing |
|---|---|---|---|---|---|---|
| 1 | harness.ts:85 `ensureUser` | INSERT | `User` | id, supabase_id, email, name (baseline `00000000000000`; all later `User` ADD COLUMNs nullable) | id, supabase_id, email, name, role | none |
| 2 | harness.ts:92 `settle` | INSERT | `ScoutImport` | id, coach_id, intent_id (`20261223000100`) | id, coach_id, intent_id, state, terminal_status | none |
| 3 | harness.ts:105 `stage` | INSERT … ON CONFLICT DO UPDATE SET payload | `ScoutIngestEntity` | id, coach_id, intent_id, entity_type, source_id, source_platform, payload (`20261222000000`) | all seven | none |
| 4 | harness.ts:113 `catalog` | INSERT | `ExerciseCatalogItem` | id, slug, name, category, primary_muscle, **updated_at** (`20260601000000` L20; `created_at` has DEFAULT CURRENT_TIMESTAMP; every other NOT NULL column has a DEFAULT) | id, slug, name, category, primary_muscle | **updated_at** — the PG-4a failure |
| 5 | spec.ts:490 `holdTransaction` | INSERT | `ScoutReconstructionLedger` | id, coach_id, intent_id, entity_type, source_id, status (`20261223000200`) + source_platform (SET NOT NULL in `20270120000000`, no default); `target_kind` (`20270122000000`) nullable | id, coach_id, intent_id, entity_type, source_id, source_platform, status, reason | none |
| 6 | spec.ts:518 | INSERT | `ScoutReconstructionLedger` | as #5 | id, coach_id, intent_id, entity_type, source_id, source_platform, status, target_id, target_kind(NULL, nullable) | none |
| 7 | spec.ts:309-310 | UPDATE name/version; UPDATE sets | `WorkoutPlan`, `WorkoutPlanExercise` | n/a (UPDATE assigns non-null literals) | — | none |
| 8 | spec.ts:564-565 | UPDATE archived_at=now(); DELETE | `WorkoutProgram`, `WorkoutPlan` | n/a | — | none |
| 9 | harness.ts:161 `resetData` | DELETEs | 13 tables | n/a | — | none |

`g2-s8c-pg-harness.ts`, `g2-s8c-db.ts`, `g2-s8c-worker.cjs`: no raw INSERT/UPDATE (helpers, guards, worker exec only).
Schema cross-check: `@updatedAt` appears only on `ExerciseCatalogItem` among the five target models; no other required
field without `@default` is omitted by any statement above.

## Minimum fix (prepared, NOT yet applied — diagnostic (a) needs the clean tree first)
`harness.patch` sha256 `1a23604ab27cf75bba592a681b275d2392f51efdd58664ed3b53d70114150426`, +8/−3, one function (`catalog`):
adds `updated_at` to the column list and `now()` to VALUES, plus a doc-comment explaining why. `git apply --check` OK at
e0cee7e0; prettier 3.9.9 `--check` clean on a scratch copy. No product/schema/migration/spec-assertion change.
