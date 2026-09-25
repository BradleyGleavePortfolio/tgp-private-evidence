# S8-C harness/spec correction (BC-3/4/5, v5) — independent changed-question review (reviewer A)

Reviewer: independent nonbuilder T4 reviewer A (REV-3, `daceddc8/SCOPE.md`). Read-only; this file is the only output. Peer `_B` files never opened. Method: `git show/diff/diff-tree/hash-object` on the named commits in `worktrees/64e33dc7-s8c`, reads of `s8c/harness-correction/**`, `s8c/spec-correction/**`, the migrations and the native-writer sources; a Python check of the float values. No lock, gate, test, PG, generator, or git write.

Status: **PHASE 1 complete (~17:35Z). PHASE 2 pending the parent's final pins** (head, checkpoint v7, binding v5, run-prep v5).

---

## PHASE 1 — do the changes fix the cited causes without weakening product assertions?

### 1.1 What changed (bytes)

| Commit | Parent / tree | Path (only) | Blob | Size |
|---|---|---|---|---|
| `9cc764013fd1d726dad082eebfa7def50800a6b2` (BC-3) | `e0cee7e0` / `82083614…` | `test/utils/g2-s8c-harness.ts` | `d5cbf877…` → `1a8f1797…` | +8/−3 |
| `4d7d4b4ebdb7df2af593bbd809f7df23775fdf29` (BC-4) | `9cc76401` / `c1949c5b…` | `test/rls-g2-s8c.spec.ts` | `dc804fde…` → `84410b5c…` | +9/−4 |
| BC-5 WIP (uncommitted at review time; porcelain exactly ` M test/rls-g2-s8c.spec.ts`) | on `4d7d4b4e` | `test/rls-g2-s8c.spec.ts` | `84410b5c…` → `9d701783…` | +7/−4 |

Both commits: Bradley author and committer, one path each (`git diff-tree`), commit bodies equal the recorded `commit-message.txt`, no trailer lines. `harness-correction/harness.patch` body equals `git diff e0cee7e0 9cc76401`; `spec-correction/spec.patch` equals `git diff 9cc76401 4d7d4b4e` byte-for-byte. Gate logs show hooked commits (`COMMIT rc=0 hook_lines=8`, prettier ✔ eslint ✔ tsc ✔ no-ai-tokens ✔) at 17:04:16Z and 17:13:27Z; BC-4's first gate launch stopped at its own pre-commit eslint step (unused `json` import) before any commit or hook — preserved in `spec-correction/run-attempt1-lint-stop/`, not a rerun of a failed commit. Full receipt verification is Phase 2.

### 1.2 BC-3 — `catalog()` `updated_at` (the PG-4a cause)

- Cited cause: PG-4a failed 13/13 in `beforeEach → catalog()` with `null value in column "updated_at" of relation "ExerciseCatalogItem"` (`S8C_V4_FAILED_PROOF_DISPOSITION.md`). `prisma/schema.prisma` declares the field `@updatedAt` (client-side fill; no DB default), and migration `20260601000000_add_exercise_catalog_video` creates it NOT NULL without default.
- Change: `INSERT INTO "ExerciseCatalogItem" (…,updated_at) VALUES (…,now())` plus a doc comment. Nothing else in the harness changed (diff is exactly the one function and its comment).
- Sufficiency: diagnostic (a) — fresh initdb, unchanged committed bootstrap, 171 migrations, `information_schema` query — lists 27 NOT NULL/no-default columns across the five tables the S8-C test support writes raw (`diagnostic/a/required_no_default_harness_tables.tsv`); I cross-read each against the harness (`ensureUser` L85, `settle` L92, `stage` L105, `catalog` L118) and the two spec ledger INSERTs (`holdTransaction`, L518): every listed column is supplied; `updated_at` was the single omission. `STATIC_SWEEP.md` agrees from the migration text. Diagnostic (b) at `9cc76401`: every `beforeEach` passed; 10/13 test bodies green. The cited cause is closed and the sweep leaves no further NOT NULL/no-default gap in the raw SQL.
- Product assertions: none touched (test support only).

### 1.3 BC-4 F1 — lane identity observed via `jsonAdmin`

- Cause (diag b): `permission denied to examine "data_directory"` — PG restricts that GUC to superusers/`pg_read_all_settings`, and `json()` runs as the NOSUPERUSER migration role `postgres`.
- Change: `json(` → `jsonAdmin(` for the one `json_build_object(version, cluster_name, data_directory, port, current_database())` observation; the unused `json` import removed (eslint `--max-warnings 0`). Asserted values unchanged: `expectedVersion`, `'s8c-disposable-pg17'`, `directory` (= `G2_S8C_DATA_DIRECTORY`, which the driver sets to `$LANE/pg-data`), `target.port`, `'g2_s8c_disposable'`.
- Does it still prove lane identity? Yes. `jsonAdmin` = `sqlAdmin` = the same `target.psqlUrl` (same host, port, database) with only the username swapped to the cluster superuser `s8c_super` (`g2-s8c-pg-harness.ts` L51–59, L70, L76). `cluster_name`, `data_directory`, `inet_server_port()`, `server_version_num` are server-level facts and `current_database()` is connection-level; none depends on the role. The migration role stays unprivileged (no GRANT, no bootstrap change), and the same test already used `sqlAdmin` for the `pg_roles` check (L114). Not weakened.

### 1.4 BC-4 F2 — `weight_lbs` tolerance

- Cause (diag b): stored `220.4622621848776` (`0x406b8ecada10c742`) vs `toPounds(100,'kg')` = `220.46226218487757` (`0x…c741`). I recomputed: `100/0.45359237` is bit pattern `…c741`; the next double is `…c742`; the difference is one ulp = 2.84e-14. The writer passes `toPounds(coerced.value, rule.unit)` unchanged (`native-rules.ts` L309; `native-contract.ts` L128–132, `value / KG_PER_LB`, `KG_PER_LB = 0.45359237`).
- Change: `weight_lbs` removed from the `toMatchObject` literal and asserted separately as `expect(rows[0].weight_lbs).toBeCloseTo(toPounds(100,'kg'), 9)`. All other fields of both rows stay exact, including `rows[1].weight_lbs: null`.
- Masking analysis: `toBeCloseTo(x, 9)` accepts |diff| < 5e-10. Any unit or factor error produces a difference ≥ 0.4: kg stored unconverted → 100 (diff 120.5); multiplied instead of divided → 45.36 (diff 175); a 2.2 factor → 220.0 (diff 0.46); a 2.205 factor → 220.5 (diff 0.04); rounding to 2 decimals → 220.46 (diff 0.002). All fail by 7+ orders of magnitude. The tolerance can only absorb floating-point representation noise. Not weakened.
- C-note: the 1-ulp drift sits somewhere in the Prisma Float write path (engine float serialization), not in the writer or the read path (`jsonb_build_object` on float8 uses PG's shortest round-trip text). Immaterial for a pounds column; recorded for completeness.

### 1.5 BC-4 F3 and BC-5 F3/F4 — `count('User')` sites

- Cause: accepted migration `20261215000100_seed_b5_contract_templates` inserts `User` `b5-system-coach-tgp`; with the fixture `coach` the table holds 2 rows before any writer runs. `resetData()` never deletes `User` (FK target). The BC-4 form `count('User', "id <> 'b5-system-coach-tgp'") = 1` at the N2 site was correct on a fresh lane; b2 failed there only because the scratch DB carried `coach-b` from run (b). F4 (L290) was the same absolute `toBe(1)`, previously masked by the F2 throw at L218.
- BC-5 WIP (the granted baseline form): at both sites `const usersBefore = count('User')` is captured after `stage()` and immediately before the writer `run(...)` calls, then `expect(count('User')).toBe(usersBefore)` after all writer runs and product assertions. The BC-4 seed-exclusion comment/form is replaced by the baseline at the N2 site. No other line changes (I read all four hunks).
- Does it still prove "no User minted"? Yes, and strictly for the writer: the only code executing between baseline and assertion is `run()` (the real `ScoutReconstructService` in the worker) plus read-only observations. `count()` runs as the BYPASSRLS owner `postgres` via raw `SELECT count(*)`, so it sees every row. Any User created by the writer — including one attributed to another coach — changes the count. `rg` over `src/scout/reconstruct/native/` finds no `User` write (nor `Person`/`Notification`/`ClientWorkoutAssignment`), consistent with the assertion's intent. The form is independent of seeds and lane history, as the grant intended. Not weakened; it drops only the pre-writer absolute count, which was never a writer property.

### 1.6 Remaining raw-SQL / seed assumptions on a fresh lane

- Seeded tables after 171 migrations (grep of `INSERT INTO` in `prisma/migrations/**`): `User` (1 row), `ContractTemplate` (4), `BuildWeekDay` (7), `CoachBriefPushLedger` (1), `WearableMetricDef` (2). The spec's remaining absolute counts are over `WorkoutPlan`, `WorkoutPlanExercise`, `WorkoutProgram`, `ClientWorkoutAssignment`, `Notification`, `Person`, `ImportNativeProvenance`, `ScoutReconstructionLedger` — none seeded; all except `ClientWorkoutAssignment`/`Notification` are reset in `beforeEach`, and those two are neither seeded nor written by the native writer. No further seed collision exists.
- Raw INSERTs: all NOT NULL/no-default columns supplied (§1.2). `ON CONFLICT` targets (`User.id`, `ScoutIngestEntity.id`, `ExerciseCatalogItem.id`, `ScoutImport` `DO NOTHING`) exercised green in (b)/(b2).
- Lines never yet executed on a live lane: in the L196 test, everything after the User assertion (L294 `Person` = 0, L296 provenance-CHECK count = 0, L300 ledger `target_kind IS NOT NULL AND target_id IS NULL` = 0); in the N2 test, L433 `ClientWorkoutAssignment` = 0. These are product/consistency assertions on writer output, not harness assumptions; the first two are implied by S8-B CHECK constraints (a violation would have aborted the writer's transaction, which (b2) shows committing). They are first exercised by the required b3 (fresh `scratch/s8c-diag2`, must be 13/13) and then by PG-4c. I see no seed/raw-SQL reason for them to fail.
- The fixture's `resetData()` deletes `ExerciseCatalogItem` wholesale; the catalog is not seeded by migrations, so this is safe on a fresh lane.

### 1.7 Phase 1 findings (Safety-ROI form)

- **C-1 (note):** 1-ulp float drift in the Prisma Float write path (§1.4). Harm: none at 2.8e-14 lb. Decision blocked: none. Closure: none.
- **C-2 (note):** the harness `catalog()` now relies on `now()` for `updated_at`, matching the semantics Prisma would apply; no product row depends on it. No harm.
- **C-3 (note):** the BC-4 `json` import removal is a required consequence of F1, not scope creep (eslint fails at `--max-warnings 0`); recorded so the "exactly three sites" grant reading is explicit.
- No A or B findings. The baseline User form (BC-5) has not yet been proven on a fresh lane (b3 pending); that is a Phase 2 gate, not a defect.

**Phase 1 verdict-so-far: GO on the changed bytes** — `9cc76401` closes the PG-4a cause with a complete raw-SQL sweep; `4d7d4b4e` closes F1/F2 with the asserted lane-identity values unchanged and a tolerance that cannot mask any unit/factor error; the BC-5 baseline form at both User sites still proves the writer minted no User and is immune to seeds and history. No product source, schema, migration, bootstrap or privilege change; no product assertion weakened.

---

## PHASE 2 — committed head, receipts, checkpoint v7, binding v5, run-prep v5 (pending final pins)

To verify on the parent's pins: BC-5 commit = child of `4d7d4b4e` with exactly the WIP diff above (spec blob `9d701783…` if unchanged), Bradley identity, no trailers, genuine hooks per `s8c/spec-correction/**` or the BC-5 run directory; b3 on a fresh scratch lane 13/13; harness/spec gate `RUN_*` manifests; `checkpoints/v7` manifest and bundle (head, prerequisite `93389265`, `HEAD.patch`); `binding/v5`: manifest verifies, v4→v5 diffs limited to `D=` path, `EXPECT_HEAD/TREE`, changed blob pins (`EXPECT_HARNESS_BLOB`, `EXPECT_SPEC_BLOB`), `EXPECT_FIXTURE_SHA`, `proof-v5` LANE/SOCK and loop globs, PINS L57 lane-path fill; all other pins byte-equal to v4; `run-prep` v5 (`S8C_PG5_GRANT`) supervisor; fresh `proof-v5` paths absent; v4 run receipts untouched.

**Final verdict: pending Phase 2.**
