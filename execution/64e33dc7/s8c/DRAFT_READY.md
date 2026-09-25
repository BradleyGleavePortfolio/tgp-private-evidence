# S8-C replacement build — DRAFT_READY

- Grant: `execution/64e33dc7/S8C_REPLACEMENT_BUILD_GRANT.md` (with 2026-09-25 amendment: typed persist result → engine handoff).
- Lane: branch `exec64/s8c-replacement`, worktree `/home/user/workspace/worktrees/64e33dc7-s8c`, HEAD (uncommitted draft) = base `93389265a846095b846fa8f1fb0dad782fb6ee9f`.
- Owner reset honoured: the missing `89a84820` draft and its receipts were not read, used or inherited. Everything below was drafted fresh from `93389265`.
- Runtime gates NOT exercised (per grant): no installs, `prisma generate`, tsc, eslint/prettier, Jest, hooks or PostgreSQL. All source below is unverified by compiler/tests; it is a draft checkpoint for slot relay. `bash -n` on the bootstrap script and `node --check` on the `.cjs` worker are the only syntax checks run.
- Nothing pushed, no commit yet, no production/client-principal policy change, no historical evidence edited, no self-acceptance.

## 1. Checkpoint manifest (exact bytes)

Copies: `execution/64e33dc7/s8c/checkpoint/<repo-relative path>`; hashes: `execution/64e33dc7/s8c/CHECKPOINT_MANIFEST.sha256`; the three tracked edits also as `checkpoint/TRACKED_EDITS.patch` (`git diff` vs `93389265`, sha256 `da1677fd2c47777decd0f52f5d50256f6d16172dc20c78ad43337fea7caf2703`).

| path | status | sha256 |
|---|---|---|
| `src/scout/reconstruct/families.ts` | modified | `2e6471c9a0bc2f4eb94956bd2416cfb79c1fb4af353148242ef56cda540f0bbd` |
| `src/scout/scout-reconstruct.dto.ts` | modified (canonical family list only) | `fbadf20ea36308297a79d0b63a1970242a4132ae7439c7cf74f3cf8bb480f98a` |
| `src/scout/scout-reconstruct.service.ts` | modified (typed handoff + `target_kind` only) | `1e5414483aae4463ba1326987f27f68d06a32d87d8c00040ceb19f994a531b8b` |
| `src/scout/reconstruct/native/native-contract.ts` | new | `298abff89e5a627f9a300b3e62859214999d9db3d6237df8d039781d71d25ada` |
| `src/scout/reconstruct/native/native-rules.ts` | new | `b03b1e3636272bcd5d2ff4be18940edf05074567499e138cc3cc47fbc466cc26` |
| `src/scout/reconstruct/native/native-rule-registry.ts` | new | `ab9ccf755eaa9d3191d10e95ccb838dac9eb5d86cc99bd505e45fece78b0c922` |
| `src/scout/reconstruct/native/persist-outcome.ts` | new | `1ce4bffa67d87043bcd6b7fb6c835670d70b045acbe8aa12b19ec0c051004492` |
| `src/scout/reconstruct/native/native-provenance.ts` | new | `8d1a014e333b0dbdad02d56462dbf831985b539d916d1faa3516779a04617c57` |
| `src/scout/reconstruct/native/native-writers.ts` | new | `0a4c31f38c86140300e3bcd8b399f8e91551c52652698ced0038da143ddaa5c7` |
| `src/scout/reconstruct/native/native-families.ts` | new | `48b9bf3ffff2309fa9d18647ee912e596489dd62d04f53cfa240282a38d13fed` |
| `test/scout/reconstruct/native/native-rules.spec.ts` | new | `6bd88da0e373ff8a15f17b8a8f81101ce2c32996c8103671a22c9047753a33de` |
| `test/scout/reconstruct/native/fake-native-tx.ts` | new (test helper) | `220bef5974c3958872ee5a1278fc47216dbce6e5e8e813d8dee4d05d51594ecc` |
| `test/scout/reconstruct/native/native-writers.spec.ts` | new | `e834f9fadb2aa76b8695cc811b7daff67849653b64c0feb7d74c2d13a74d60e5` |
| `test/scout/reconstruct/native/engine-handoff.spec.ts` | new | `9f63eb34e208b1659f8df0516d2db8c091e66eb2714745ac4133ee40ed158985` |
| `test/scout/reconstruct/native/native-families.spec.ts` | new | `eaf7ea9901a471fc299c678746f51c52f8a5d914c522c1bd69d3c7892fe7531a` |
| `test/scout/g2-s8c-db-guard.spec.ts` | new | `319381138f1abe6891e6c2ad0e589fc10de8cb283894330230955d6f532da0a4` |
| `test/rls-g2-s8c.spec.ts` | new (guarded live proof) | `41ea4383a3b6bb2055ec30774eac33dee4a8df3ee53d95412ecd3a3b1d5a446d` |
| `test/utils/g2-s8c-db.ts` | new | `56c55b3d39340ec3cdf8e6809e711b27aaeb207b59b361843364e5f5f58908c9` |
| `test/utils/g2-s8c-bootstrap.sh` | new (+x) | `cac3066413d905d26f34ff102a8740a3b0c8d55fe65419134c4e76795b35c174` |
| `test/utils/g2-s8c-pg-harness.ts` | new | `ebc3dd429ed7c0388d6090cf0dd801f52e26c7f6e454f4b5666de86ef55a4609` |
| `test/utils/g2-s8c-harness.ts` | new | `d99c42ba2735aa3c80d92e9aea014a59f5d9dc467e6c665b636015a14dbf717d` |
| `test/utils/g2-s8c-worker.cjs` | new | `05aa7b9ff61ab88b501ed77c7bd3a8726ffe08b4596fc151a332ec8928aecb80` |

No file outside the granted surface was touched. `prisma/**`, `docs/contracts/**`, `mapping-spec.ts`, `source-mapper-registry.ts`, `sources/*.json`, `nest-cli.json`, workflows, lifecycle, ingest/controller/readers are byte-identical to `93389265` (`git diff --name-only 93389265 -- prisma` is empty; asserted again by the bootstrap step 4 and the guard spec).

## 2. What the draft does (owned scope only)

- `native/native-contract.ts`: closed constants from the S8-B contract — `NATIVE_KIND` (person, scout_entity, workout_program, workout_plan, workout_plan_exercise), `PROVENANCE_OUTCOME`, `NATIVE_FAMILY {programs, workouts}`, `UNRESOLVED_CODE` and the `unresolved:<code>[:<qualifier>]` reason grammar, child identity `<len>:<parent>#id:<x>` / `#ord:<n>`, superset group id, `toPounds`.
- `native/native-rules.ts`: data-only native rule grammar per source (`sources/<platform>.json`, none shipped) + strict fail-closed parser + pure interpreters `interpretProgram` / `interpretWorkout` over S8-A's already-resolved seam (label, clientSourceId, payload). Ranges/text in Int prescription columns → `prescription_not_integral:<field>`; missing → `missing_required_field:<field>`; client-linked → `no_native_client_principal`.
- `native/native-rule-registry.ts`: loads `src/scout/reconstruct/native/sources/*.json` (absent dir → empty registry; present-but-empty or misnamed → refuse). Zero sidecars shipped, so **no source is native yet**; every workout row keeps the accepted evidence write until a source declares rules.
- `native/native-provenance.ts`: `ImportNativeProvenance` reads/writes on the five-field identity (`coach_id, source_namespace, entity_type, source_id` + kind), `created` / promote-from-unresolved / `unresolved` upsert, unresolved-children count by child prefix. `import_intent_id` is written NULL (see C3).
- `native/native-writers.ts`: `persistProgram` (WorkoutProgram template: `is_template=true`, `is_regime=false`, `owner_user_id=coach`, `visibility=owner_only`, version 1), `persistWorkoutTemplate` (WorkoutPlan standalone or program-day; program-day gets `WorkoutPlanRevision` 0 / `author_kind coach` / `cause initial` and the head pointer exactly like `copyProgramPlans`; exercises linked only when `exercise_external_id` equals an exact `ExerciseCatalogItem.id` or `.slug`, else child provenance `unresolved:exercise_reference`; children before parent; existing `created` provenance → verify target (missing/archived → `native_target_removed`, kind/coach mismatch → `identity_conflict`) → `already_present`, never re-create or overwrite coach edits), `persistEvidence` (byte-identical generic upsert typed `scout_entity`; with declared rules and a client link also records `unresolved:no_native_client_principal` provenance, kind `workout_plan`).
- `native/native-families.ts`: the `programs` and `workouts` `FamilyReconstructor`s. `map` routes the staged token through the accepted `resolveStagedFamily`/`resolveStep` guard (A3): unregistered platform → `unsupported_platform:<p>`; token resolving to another family → `unresolved_family:<token>`; then S8-A `mapEntity` for label/link, then the native interpreter. No source-specific core code.
- `families.ts` (owned lines only): imports/re-exports, `StagedRow.entity_type?`, `persist(): Promise<PersistResult>` (`string | null | PersistOutcome`), `FamilyRegistryOptions` injection seam, registry = clients, native.workouts, client_history (generic), native.programs.
- `scout-reconstruct.dto.ts`: `RECONSTRUCT_FAMILY.programs = 'programs'` + doc.
- `scout-reconstruct.service.ts` (amendment surface only): inside the existing per-row `$transaction`, `isPersistOutcome(result)` → typed `ok:false` writes `skipped` with the database-determined reason; typed `ok` writes `reconstructed` with `target_id` **and** `target_kind`; legacy `string|null` path unchanged (kind stays NULL). `writeLedger` gains `targetKind = null` and spreads `target_kind` only when non-null. Target-before-ledger order, `retryContention`, success precedence (`status != reconstructed` filter), failure propagation and `tally` are untouched.

## 3. N1–N4 pins (from `s8f/READINESS.md`)

- **N1 — persisted kind/id.** The ledger row for a native or evidence outcome now carries `target_kind ∈ {person, scout_entity, workout_program, workout_plan}` (`LEDGER_TARGET_KIND`, `native/persist-outcome.ts`) together with `target_id`, written by the same `writeLedger` upsert + precedence update, in the same interactive transaction as the target row and its provenance row(s). Concretely: `programs` → `workout_program` / `WorkoutProgram.id`; `workouts` native → `workout_plan` / `WorkoutPlan.id`; `workouts` evidence → `scout_entity` / `ScoutReconstructedEntity.id`. `clients` and `client_history` keep the legacy `string|null` return, so their `target_kind` stays NULL and historical NULL rows are never rewritten (`engine-handoff.spec.ts`, `rls-g2-s8c.spec.ts` "legacy compatibility").
- **N2 — client-linked workout evidence behaviour.** A `workouts` row with a resolved `clientSourceId` never becomes a WorkoutPlan and never creates a User. It is written as the accepted generic evidence row and the ledger records `status=reconstructed, target_id=<ScoutReconstructedEntity.id>, target_kind='scout_entity'`. If (and only if) the source has declared native workout rules, an explicit provenance row `entity_type=workouts, native_kind=workout_plan, outcome=unresolved, native_id=NULL, reason='unresolved:no_native_client_principal'` is also recorded (same transaction). A client-linked `programs` row has no evidence fallback: ledger `skipped`, reason `unresolved:no_native_client_principal`, no target, no provenance. No S8-D/E linking is attempted.
- **N3 — canonical family exposure.** `RECONSTRUCT_FAMILY` gains `programs` (DTO hunk). By construction that adds `programs` to `RECONSTRUCT_ENTITY_TYPES`, to `ENTITY_REVIEW_FAMILIES` (`scout-entities.dto.ts` L41, unowned, unchanged) and therefore to two generated-contract enums (see §5). No reader, materializer, flag or customer path is activated by this draft (A2: record-and-continue; S8-F owns the review read of native targets).
- **N4 — which targets receive native provenance.** Provenance rows are written for `workout_program` (programs), `workout_plan` (native workouts) and `workout_plan_exercise` children (created or unresolved), plus the explicit `unresolved` marker for client-linked workouts when rules are declared (N2). **No provenance row is written for `scout_entity` evidence targets themselves, nor for `person`** — legacy/evidence rows are validated exactly as today (assumption in READINESS N4 confirmed: "no").

## 4. A / B / C items

- **A1 — unowned 2-line interpreter change required before `tsc` can pass (blocks SOURCE_READY, not DRAFT_READY).** Adding `programs` to `RECONSTRUCT_FAMILY` widens `CanonicalFamily`; `src/scout/reconstruct/mapping-spec.ts` indexes `spec.families[family]` (≈L252, `resolveStep`/`isFamilyDeclared`) with that union, and `SourceMappingSpec.families` (≈L118-121) has no `programs` member → TS7053. Minimum closure, for the S7-L/mapping owner (or parent grant of these two lines to S8-C): (a) `readonly programs?: EntityFieldRules;` in `SourceMappingSpec.families`; (b) `if (family === RECONSTRUCT_FAMILY.programs) return spec.families.programs;` in `entityRules` (≈L238). Behaviour for the two accepted sidecars is unchanged (neither declares `programs`; `conformance_beta`'s `programs` step token maps to `workouts` and keeps doing so). Fallback if refused: drop the DTO hunk and the `native.programs` registration (programs then stays unreachable; workouts typed handoff still lands). `native-families.spec.ts` and the PG proof's `programs` cases depend on (a)+(b).
- **A2 — generated contract artifact delta (S7-L generator owner; do not run the drift gate before regeneration).** See §5. `test/contracts/importer-contract.spec.ts` drift check (L62) will fail against the committed `docs/contracts/importer-openapi.json` until the sole generator owner regenerates; the parent sequences this. Not a source blocker.
- **B — none identified.** No decision is blocked on the parent beyond A1/A2 sequencing.
- **C1 — engine does not forward the staged step token.** `scoutIngestEntity.findMany` selects `source_id, source_platform, payload` only; `StagedRow.entity_type` is optional and native `map` falls back to the family name (accepted staging convention: `entity_type` = canonical family). The A3 guard still runs (`token === family` passes; a foreign token is refused). Carry-forward for the engine owner; recorded, continue.
- **C2 — `import_intent_id` written NULL.** `ImportNativeProvenance.import_intent_id` is nullable with FK `(import_intent_id, coach_id) → ImportIntent`; the family `persist` seam receives no intent id and `FamilyReconstructor.persist` is not widened (no generic pipeline redesign). S8-G/lifecycle can populate it later. Recorded, continue.
- **C3 — success precedence keeps a stale `reconstructed` row when the native target is later deleted/archived.** The writer reports `unresolved:native_target_removed` (typed `ok:false` → `skipped` write) but the accepted precedence update (`status != reconstructed`) leaves the earlier row and the `created` provenance in place and mints nothing new. Observed semantic pinned in `rls-g2-s8c.spec.ts` ("later-removed"); completion fencing is S8-G's. Recorded, continue.
- **C4 — `nest-cli.json` assets glob.** When the first `src/scout/reconstruct/native/sources/<platform>.json` sidecar lands, `nest-cli.json` needs the analogue of the S8-A `scout/reconstruct/sources/*.json` assets line for `scout/reconstruct/native/sources/*.json`. Not needed by this draft (zero sidecars). Recorded, continue.
- **C5 — Prisma query-log dependent assertions.** Two live-proof assertions rely on Prisma emitting `BEGIN`/`COMMIT`/`ROLLBACK` and `INSERT INTO "public"."<Table>"` in `query` events (same dependency the accepted N/Q1 and S8-B proofs carry). If the pinned Prisma version phrases them differently the assertions are tightened after the first run, never loosened to pass.
- **C6 — accepted-test impact expectation.** `test/scout/reconstruct/families.spec.ts` and the conformance e2e should remain green: undeclared-rules mode is the byte-identical generic upsert, and the accepted FakePrisma tolerates the extra `target_kind` key only where a typed outcome is produced (workouts evidence → `scout_entity`). If the accepted families spec asserts the exact `outcome` object of a workouts ledger write, it will see `target_kind: 'scout_entity'` — that is the intended N1 delta and must be reported, not hidden.

## 5. Exact generated-contract delta needed from the S7-L generator owner

Source of truth is the DTO hunk; the generator derives both enums. After `scripts/importer-contract.ts` regeneration, `docs/contracts/importer-openapi.json` is expected to change in exactly two enum arrays:

1. `components.schemas.ScoutReconstructDto.properties.entity_type.enum` (≈L676-680): `["clients","workouts","client_history"]` → `["clients","workouts","client_history","programs"]`.
2. `paths./api/scout/reconstruct/entities.get.parameters[name=family].schema.enum` (≈L1992-1995, from `ENTITY_REVIEW_FAMILIES`): `["workouts","client_history"]` → `["workouts","client_history","programs"]`.

No path, schema, response or version-string change originates from S8-C; the contract version bump (`scripts/importer-contract.ts` L49 / spec L442) is S7-L's call and the parent sequences it. S8-C did not edit the artifact or run the drift gate.

## 6. Concrete additional-path needs (summary for the parent)

| need | file (unowned) | minimum | class |
|---|---|---|---|
| `programs` family declarable in S8-A specs | `src/scout/reconstruct/mapping-spec.ts` | 2 lines (§4 A1 a+b) | A |
| regenerate contract enums | `docs/contracts/importer-openapi.json` via generator | §5 | A (sequenced) |
| assets glob for future native sidecars | `nest-cli.json` | 1 line, only when first sidecar lands | C |
| forward staged token to families | `scout-reconstruct.service.ts` select (engine owner) | optional carry-forward | C |

## 7. Live proof plan (after relay; nothing run yet)

- Lane: S8-C-only disposable PG17 cluster, `cluster_name = s8c-disposable-pg17`, port **55642**, DB `g2_s8c_disposable`, superuser `s8c_super`, DB comment marker `s8c-g2-native-writer-synthetic-disposable-fixture-safe-to-drop`; refused ports include 55511 (S8-B) and 55641 (concurrent S7-L). Runtime root per `runtime/RUNTIME_SETUP_RECEIPT.md`: `/home/user/workspace/execution/64e33dc7/recovery-reset` — never platform `node_modules`, never production credentials, never `/home/user/workspace/execution/test-validation.lock`.
- `test/utils/g2-s8c-bootstrap.sh bootstrap`: server/marker/role checks → `prisma migrate deploy` from the candidate root as `postgres` → asserts 171 applied, S8-B objects present, prisma tree identical to `93389265`, candidate client verified (no generate).
- `jest --config jest.rls.config.js test/rls-g2-s8c.spec.ts --runInBand` with `G2_S8C_DATABASE_URL`, `G2_S8C_CONFIRM=g2_s8c_disposable:55642`, `G2_S8C_PASSWORD`, `G2_S8C_PSQL`, `G2_S8C_DATA_DIRECTORY`. Cases: lane identity; canonical family list from the real service; program create + same-tx provenance + typed ledger; standalone plan with ordered exercises, exact id/slug links, unresolved children, no assignment/notification/User/Person rows, CHECK-consistent rows; byte-identical replay with coach edits preserved; program-day `relationship_pending:programs` → converge with revision 0/head pointer; client-linked N2 behaviour; tenant isolation; concurrent identity convergence (paused after target INSERT, loser rolls back); held ledger identity → observed lock wait → rollback + retry convergence; legacy NULL-kind rows and legacy families untouched; later-removed/archived target keeps precedence.
- Unit specs (default Jest, no PG): the four `test/scout/reconstruct/native/*.spec.ts` + `test/scout/g2-s8c-db-guard.spec.ts`. Never rerun S8-B or inherited suites as proof.
- Then prettier/eslint/`tsc` (heap 4096), R75, affected Jest, hooks; single commit as `Bradley Gleave <bradley@bradleytgpcoaching.com>` (author+committer, no trailers); report SOURCE_READY. No push.
