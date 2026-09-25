# S8-C v5 harness + spec correction — independent T4 review B (REV-3)

Reviewer: nonbuilder T4 reviewer B. Read-only; this file is the only write. Peer `_A` files not read.
Grant: REV-3 (daceddc8/SCOPE.md BC-3/BC-4/BC-5; SCOPE L210 "the three assertion changes do not weaken product assertions").
Worktree read via `git show` / working tree at `/home/user/workspace/worktrees/64e33dc7-s8c` (HEAD observed `f428db9a…`, porcelain 0 at review time).

## PHASE 1 — independent verification

### Commits examined
| commit | tree | parent | change | blob |
|---|---|---|---|---|
| `9cc764013fd1d726dad082eebfa7def50800a6b2` | `82083614…` | `e0cee7e0` | BC-3 harness `catalog()` supplies `updated_at … now()` | harness `d5cbf877` → `1a8f1797` |
| `4d7d4b4ebdb7df2af593bbd809f7df23775fdf29` | `c1949c5b…` | `9cc76401` | BC-4 F1 `json`→`jsonAdmin`, F2 `toBeCloseTo(…, 9)`, F3 `count('User', id <> seed)` | spec `dc804fde` → `84410b5c` |
| `f428db9ab65f638da1651b8cd792c6f93b4983c1` | `f2623be6…` | `4d7d4b4e` | BC-5 pre-writer `usersBefore` baseline at both User sites (+7/−4, spec only) | spec `84410b5c` → `9d701783` |

BC-5 was uncommitted WIP when REV-3 was issued; it is now committed as `f428db9a` (author = committer = Bradley Gleave `<bradley@bradleytgpcoaching.com>`, `%(trailers)` empty). `git show f428db9a` diff == the granted form exactly: `const usersBefore = count('User')` inserted before `run()` at L200 and L385; `expect(count('User')).toBe(usersBefore)` at L293 and L432 replacing `toBe(1)` and the `id <> 'b5-system-coach-tgp'` form; harness blob unchanged `1a8f1797`. Phase 2 will re-pin against the parent's final pins.

### (a) weight_lbs 1-ulp cause and adequacy of the 1e-9 tolerance

**Writer path (product, unchanged by any correction).**
- `src/scout/reconstruct/native/native-contract.ts:128-133`: `KG_PER_LB = 0.45359237` (exact international avoirdupois pound), `toPounds(value, unit) = unit === 'lb' ? value : value / KG_PER_LB`. Pure IEEE-754 division; no rounding, no intermediate scaling.
- `native-rules.ts:299-310 weightField` → `present(toPounds(coerced.value, rule.unit))`; `native-rules.ts:572 weightLbs: weight.value`; `native-writers.ts:201-211 exerciseRow` copies `fields.weightLbs` into `weight_lbs` untouched; `native-writers.ts:308-312 tx.workoutPlanExercise.create({ data: { ...data, workout_plan_id } })`.
- Schema: `WorkoutPlanExercise.weight_lbs Float?` (schema.prisma L2308) = `DOUBLE PRECISION` (migration `20260508000000_add_workout_builder` L29). No Decimal, no numeric cast.
- So the JS number handed to Prisma is exactly `100 / 0.45359237` = `220.46226218487757` = `0x406b8ecada10c741` (computed here in node; `JSON.stringify` of it round-trips bit-exactly via `Number(...)`).

**Read path (spec/harness).** `exercises()` (`g2-s8c-harness.ts:143-149`) = `json(SELECT … jsonb_build_object(…,'weight_lbs',weight_lbs,…) …)` over psql `-qAt` (`g2-s8c-pg-harness.ts:61-75`) → `JSON.parse`. PostgreSQL converts `float8` to jsonb numeric through `float8out`, which on PG 17 with default `extra_float_digits=1` emits the shortest round-trip decimal; the harness sets no `extra_float_digits`. `JSON.parse` of a shortest round-trip decimal is bit-exact. Therefore the value the spec sees **is** the stored double.

**Observation.** diag (b) `jest.log:376-377` received `220.4622621848776` = `0x406b8ecada10c742`; expected `…c741`. Independently recomputed: difference `2.842170943040401e-14` = exactly 1 ulp at 220 (`ulps = 1`). Direction: stored value is 1 ulp above the JS value.

**Location of the loss (by exclusion).** Both ends are exact (JS division; PG float8 storage + shortest-repr JSON). The only lossy segment is Prisma client → query engine → driver parameter binding. The pinned engine binary (`node_modules/.prisma/client/libquery_engine-debian-openssl-3.0.x.so.node`) contains `bigdecimal-0.3.1`, `"Prisma Float (BigDecimal)"` and quaint's `"decimal to f64 conversion"` strings: Prisma represents `Float` as a BigDecimal inside the engine and converts it back to `f64` for the `float8` bind — a decimal↔binary round trip that the old bigdecimal `to_f64` does not perform correctly-rounded. I could not reproduce the exact arithmetic path in a JS/Python emulation (both `int_val·10^-scale` variants I tried return `…c741`), so the precise instruction is not pinned; the **segment** is, and it is pre-existing platform behaviour of every Prisma `Float` write in the app, not anything S8-C introduced. The accepting spec is asserting the writer's contract (kg → lb by the exact factor), which holds to 1 ulp.

**Tolerance adequacy.** `toBeCloseTo(x, 9)` passes iff `|received − expected| < 5e-10`. Magnitudes (computed):
| error hypothesis | |Δ| vs 220.46226218487757 | caught? |
|---|---|---|
| kg written as lb (no conversion) | 120.46 | yes |
| wrong direction (×0.45359237) | 175.1 | yes |
| factor 2.2 | 0.462 | yes |
| factor 2.20462 (6 s.f.) | 2.6e-4 | yes |
| factor 2.20462262 (9 s.f.) | 1.85e-7 | yes |
| factor 2.2046226218 (11 s.f.) | 4.9e-9 | yes |
| result rounded to 2 dp | 2.3e-3 | yes |
| observed Prisma Float round trip | 2.8e-14 | tolerated (intended) |
The tolerance is ~1.8×10^7 ulps wide but still ≥ 10× below the smallest plausible constant/unit mistake (a factor truncated at 11 significant figures). A result rounded to ≥ 9 decimal places (Δ ≈ 1.2e-10) would slip through, but the writer contains no rounding and such a mistake is not a unit/conversion error. All other fields of `rows[0]` (`sets, reps_or_duration_seconds, rest_seconds, superset_group_id, notes`) stay under exact `toMatchObject`; `rows[1].weight_lbs: null` stays exact (spec L231-235). Conclusion: F2 does not weaken the product assertion.

### (b) User-count baseline still proves the writer mints no User
- Writer sweep (`src/scout/reconstruct/native/*.ts`): the only Prisma writes are `importNativeProvenance.{create,update,upsert}`, `scoutReconstructedEntity.upsert`, `workoutPlan.{create,update}`, `workoutPlanExercise.create`, `workoutPlanRevision.create`, `workoutProgram.create`; no `user`, no `"User"`, no `$executeRaw/$queryRaw`, no nested `connectOrCreate`; the two nested `create:` blocks are the upsert bodies of provenance/entity rows.
- Between baseline and assertion at both sites the only actor is `run()` = `worker(options).done` (`g2-s8c-pg-harness.ts:188`, forks `g2-s8c-worker.cjs`); the harness itself inserts into `User` only in `ensureUser()` (`g2-s8c-harness.ts:84-88`, called from `settle()`), which runs in `beforeEach` / the two-coach test — before the baseline or in a later test. No test deletes Users (`resetData()` L165-171 never touches `User`; the seed coach is an FK target).
- Hence `count('User') after run == usersBefore` ⇔ the writer created zero User rows, independent of seed rows (`20261215000100_seed_b5_contract_templates` inserts `b5-system-coach-tgp`) and of lane history. Same logical strength as the old absolute `toBe(1)` on a virgin lane; strictly more robust. N2 site (L385) takes the baseline before **both** runs (workouts, programs), so both writer passes are covered.
- Cross-check on a fresh lane: diag b3 (`harness-correction/diagnostic/b3/jest.log` 13/13; `diag-b3.log` `PRECONDITIONS_OK head=f428db9a`, fresh `scratch/s8c-diag2` initdb, port 55644, PG 17) — non-accepting, but consistent.

### (c) jsonAdmin identity observation keeps the same assertions
Diffed `e0cee7e0:test/rls-g2-s8c.spec.ts` vs HEAD for the `lane identity` test: the SQL text (`json_build_object('version',…,'cluster',…,'directory',current_setting('data_directory'),'port',inet_server_port(),'db',current_database())`) and the `toEqual({version: expectedVersion, cluster: 's8c-disposable-pg17', directory, port: target.port, db: 'g2_s8c_disposable'})` object are byte-identical; only `json` → `jsonAdmin` plus a two-line comment. `jsonAdmin = JSON.parse(sqlAdmin(text))`, `sqlAdmin = psqlRun(adminUrl)`, `adminUrl = asRole('s8c_super')` which only swaps the URL username (`pg-harness.ts:51-55`) — same host/port/database, so `db`, `port`, `directory`, `cluster` still describe the lane under test. `data_directory` is superuser-only in PG ≥ 15 and the migration role is `NOSUPERUSER` by bootstrap design (`g2-s8c-bootstrap.sh:87-106`), so the F1 failure was a role-privilege observation error, not a lane defect. The same test already used `sqlAdmin` for the `pg_roles` check, so no new dependency is introduced; the migration role remains the actor for every DDL/data statement.

### (d) Other seeded-table / fresh-lane assumptions
- Migrations seed exactly five tables: `BuildWeekDay`, `CoachBriefPushLedger`, `ContractTemplate`, `User`, `WearableMetricDef`. The spec asserts absolute counts only on `ClientWorkoutAssignment, ImportNativeProvenance, Notification, Person, ScoutReconstructionLedger, WorkoutPlan, WorkoutPlanExercise, WorkoutProgram` — none seeded. `User` is the only seeded table asserted, and both sites are now baseline-form. No remaining seeded-table assumption.
- `resetData()` does not clear `Notification`, `ClientWorkoutAssignment` or `User`. `expect(count('Notification')).toBe(0)` (L292) and the two `count('ClientWorkoutAssignment')).toBe(0)` sites are therefore lane-history dependent in principle, but no migration seeds them, no test inserts them and the writer never touches them; the accepting proof lane is a fresh initdb (v5). Record-only (C2).
- Harness NOT NULL / no-default sweep: `diagnostic/a/required_no_default_harness_tables.tsv` lists 27 columns across `ExerciseCatalogItem, ScoutImport, ScoutIngestEntity, ScoutReconstructionLedger, User`; every column except `ExerciseCatalogItem.updated_at` was already supplied by the corresponding harness INSERT (the `beforeEach` inserts succeeded in all 13 tests of diag b/b2/b3). BC-3 closes the only gap; `updated_at DateTime @updatedAt` (schema L44) has no DB default, so `now()` in the raw INSERT is the correct fixture form.

## Findings (Safety-ROI form)
- **C1 — expected value derived from the product's own `toPounds`.** Class C. Concrete harm: none demonstrated — the factor is a literal `0.45359237` in `native-contract.ts:128`; the spec would not detect a change to that literal, but this was already true in v4 (`weight_lbs: toPounds(100,'kg')`) and is outside the BC-4 grant. Decision blocked: none. Minimum closure: none required (optional future: an independent literal `220.46226218487757`). Execution unlocked: yes.
- **C2 — absolute zero counts on non-reset tables (`Notification`, `ClientWorkoutAssignment`).** Class C. Concrete harm: none on the fresh accepting lane; only a reused scratch lane with prior inserts into those tables could fail them, and none exists. Decision blocked: none. Minimum closure: none; noted for future harness `resetData()` hygiene. Execution unlocked: yes.
- **C3 — 1-ulp Prisma `Float` round trip is platform-wide.** Class C. Concrete harm: none (1.3e-16 relative on a coach-facing weight). The exact engine instruction is not pinned by this review, only the segment (engine BigDecimal ↔ f64); an issue for the platform backlog, not S8-C. Decision blocked: none. Execution unlocked: yes.
- No class A/B finding: each of the three assertion changes (F1 observation role, F2 tolerance, F3/BC-5 baseline) preserves the product property it asserts; BC-3 is a fixture-completeness fix in a raw harness INSERT with no product change.

## PHASE1 DONE — verdict-so-far: **GO** (pending Phase 2 pins)
Phase 2 will verify: BC-5 head/tree pins as delivered by the parent (observed `f428db9a` / `f2623be6…`, spec blob `9d701783`, harness blob `1a8f1797`), checkpoint v7, binding v5 (proof-v5 paths, PINS L57 fill fix), run-prep v5 `S8C_PG5_GRANT`, gate receipts, genuine lefthook hooks, Bradley identity, no trailers.
