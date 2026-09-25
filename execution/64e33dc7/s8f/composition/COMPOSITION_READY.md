# S8-F native readers — COMPOSITION_READY (source only)

Grant: S8F-COMP-1 (`daceddc8/SCOPE.md`, 16:35Z), builder `s8f_composition_prep` (T4). Written 2026-09-25 ~16:45Z.
Status: **COMPOSITION_READY**. Source composed and checkpointed. **Nothing installed, generated, compiled, linted,
formatted, tested, committed, pushed or run against PostgreSQL.** No lock operation. Worktree left with the 15 paths as
uncommitted changes (10 modified, 5 untracked) on detached `87018a42`; no branch created, index untouched.

## Worktree and base

- Worktree: `/home/user/workspace/worktrees/daceddc8-s8f`, created with
  `git worktree add --detach … 87018a421f5be1064767d2cdd32e75ca935f7cdb` (S8-C v5 candidate, tree
  `cec7d05a91876ec3f6badb1020bb97aacdb9331d`). `COMPOSITION_BASE_HEAD.txt`.
- Not read or written: `worktrees/64e33dc7-s7l`, `worktrees/64e33dc7-s8c`. Read-only use of
  `worktrees/64e33dc7-env/node_modules/typescript` (5.9.3) for a parse-only check (see below).
- Pending S8-C bootstrap correction (S8C-BC-2) touches only `test/utils/g2-s8c-bootstrap.sh` — disjoint from every
  S8-F path. Moving this composition onto the accepted S8-C head is expected to be a clean re-apply of
  `composition-vs-87018a42.patch` (verified below to replay onto a clean `87018a42` tree; the 10 tracked S8-F paths are
  byte-identical between `93389265` and `87018a42`, so nothing in S8-C's tree touched them).

## What was applied (exact paths, 15; all inside the S8-F writable surface)

Frozen draft `s8f/build/CHECKPOINT_MANIFEST.sha256` verified first (`sha256sum -c`, 21/21 OK). All 15 checkpoint copies
applied byte-for-byte (15/15 sha256 match against the frozen manifest after copy; bootstrap mode 755 restored).

Modified (10): `src/scout/scout-entities.controller.ts`, `src/scout/scout-entities.dto.ts`,
`src/scout/scout-entities.service.ts`, `src/scout/scout-roster.controller.ts`, `src/scout/scout-roster.dto.ts`,
`src/scout/scout-roster.service.ts`, `test/scout/entities/scout-entities.contract.spec.ts`,
`test/scout/entities/scout-entities.service.spec.ts`, `test/scout/roster/scout-roster.controller.spec.ts`,
`test/scout/roster/scout-roster.service.spec.ts`.
New (5): `test/rls-g2-s8f.spec.ts`, `test/scout/g2-s8f-db-guard.spec.ts`, `test/utils/g2-s8f-bootstrap.sh` (755),
`test/utils/g2-s8f-db.ts`, `test/utils/g2-s8f-pg-harness.ts`.

## Deltas vs the frozen draft (exactly one file) — `DELTA_vs_frozen_draft.diff`

Only `test/scout/entities/scout-entities.service.spec.ts` changed (`f790d175…` → `e7c3947e…`), the F03 unskip:

1. `const itPrograms = ENTITY_REVIEW_FAMILIES.includes('programs') ? it : it.skip` and the literal `'programs'` are
   replaced by `const PROGRAMS_FAMILY = RECONSTRUCT_FAMILY.programs;` and F03 is a plain `it(...)`. Why: at `87018a42`
   `RECONSTRUCT_FAMILY.programs` exists (`scout-reconstruct.dto.ts` blob `86cebe53…`) and `ENTITY_REVIEW_FAMILIES` is
   derived from `RECONSTRUCT_ENTITY_TYPES` minus `clients`, so `programs` is reviewable without any S8-F DTO change.
2. F03 opens with `expect(ENTITY_REVIEW_FAMILIES).toContain(PROGRAMS_FAMILY)` so a future removal of the family FAILS the
   suite instead of silently skipping.
3. The pre-existing allow-list assertion (`every reviewable family is a non-person family`) now also requires
   `RECONSTRUCT_FAMILY.programs` (three-element `arrayContaining`, wrapped at printWidth 100).

No other byte in the 14 remaining files differs from the frozen draft. Rationale for "no further composition edits": the
S8-C v5 interfaces the readers depend on were re-read and match the draft's assumptions exactly:

- Ledger `target_kind` closed set `LEDGER_TARGET_KIND` = {person, scout_entity, workout_program, workout_plan}
  (`persist-outcome.ts` `2f9bd19d…`); the engine writes it only for typed `PersistOutcome`s and leaves legacy results NULL
  (`scout-reconstruct.service.ts` `711bfb09…` lines 214–258). Reader `effectiveKind`: NULL/`scout_entity` → evidence join;
  `workout_plan`/`workout_program` → native join; anything else dropped. Matches.
- Writers (`native-writers.ts` `4f17e17b…`): `persistProgram` → WorkoutProgram with `coach_id`, `owner_user_id=coach`,
  `visibility='owner_only'`, ledger kind `workout_program`, family `programs`; `persistWorkoutTemplate` → WorkoutPlan
  (`coach_id`, `program_id` nullable, `is_template` mirrors program), kind `workout_plan`, family `workouts`;
  `persistEvidence` → `ScoutReconstructedEntity` with `entity_type='workouts'`, kind `scout_entity` (client-linked
  workouts stay evidence, §3.8). Reader evidence join re-asserts `coach_id` + `entity_type = family`; native joins filter
  `coach_id` + `archived_at IS NULL` only (no `owner_user_id`/`visibility` — owner-reserved policy untouched). Matches.
- Provenance (`native-provenance.ts` `daf4fd0f…`, `native-contract.ts` `3a08d3de…`): identity
  (coach_id, source_namespace, entity_type, source_id); `native_kind` ∈ {workout_program, workout_plan,
  workout_plan_exercise}; outcomes {created, already_present, unresolved}; `import_intent_id` always NULL. Reader joins on
  (coach_id, native_kind, native_id) with `outcome IN ('created','already_present')` — the indexed
  `@@index([coach_id, native_kind, native_id])` — and never touches `import_intent_id`. Note: v5 writers write `created`
  and `unresolved` only (replay verifies and returns without rewriting to `already_present`); the reader's acceptance of
  `already_present` is a permissive superset inside the S8-B CHECK, not a mismatch, and needs no edit.
- Families list (`families.ts` `a6f28601…`, `native-families.ts` `dfa6f6ee…`): `clients`, `workouts`, `client_history`,
  `programs`. Contract artifact at `87018a42` (`493234f1…`, sha256 `727eb523…`) already carries `programs` in both enums
  (S8-C generator transfer, SOURCE_RECEIPT). S8-F's in-surface `scout-entities.contract.spec.ts` compares the family enum
  to `ENTITY_REVIEW_FAMILIES` dynamically, so no edit.
- Schema pin `prisma/schema.prisma` `32e44110…` unchanged from base: `ScoutReconstructionLedger.target_kind` nullable,
  `ImportNativeProvenance` present, WorkoutPlan/WorkoutProgram carry `coach_id`, `name`, `archived_at`.
- `test/utils/g2-tq0-worker.cjs` (`aa35e7e2…`) unchanged, still exposes `roster`/`entities` actions the S8-F harness uses.

Syntax-only receipt: all 14 `.ts` paths parse with zero `parseDiagnostics` under TypeScript 5.9.3
(`createSourceFile` only; no type check); `bash -n test/utils/g2-s8f-bootstrap.sh` OK. That is the full extent of tooling
run.

## Changes needed OUTSIDE the S8-F surface (plan for the sole generator owner; NOT done here)

F12 / draft dependency 4. Two artifacts, both currently frozen and owned elsewhere:

1. `docs/contracts/importer-openapi.json` — regenerate with the unchanged accepted generator,
   `npm run -s contract:importer` (`scripts/export-importer-contract.ts` `77ac9f97…`, `scripts/importer-contract.ts`
   `7b5e8041…`), in the composed S8-F worktree AFTER the gates' `prisma generate`-free preconditions are met (the export
   boots `AppModule` with stub env; needs provisioned `node_modules`, no DB). Expected semantic delta, and nothing else:
   - `components.schemas.ReconstructedEntityDto.properties` gains `target_kind` (`type: string`, `enum:
     [scout_entity, workout_program, workout_plan]`) and `native_id` (`type: string`, `format: uuid`, `nullable: true`);
     both appended to `required`; the `id` property description text changes (format uuid unchanged).
   - `components.schemas.ScoutRosterResult.properties` gains `roster_bridge_pending` (`type: boolean`, example true),
     appended to `required`.
   - `paths['/api/scout/reconstruct/entities'].get.description` and `…/roster.get.description` text extended (the
     `@ApiOperation` description edits; the 404 descriptions still contain "no existence oracle").
   - No path added/removed, no version bump, no enum change (family enum already includes `programs` from S8-C).
   Any other diff is a stop-and-report, not a fix. Record the before/after sha256 and `git diff --stat`.
2. `test/contracts/importer-contract.spec.ts` (`0b1ebb56…`) line ~252 pins `props('ReconstructedEntityDto')` exactly.
   Minimum edit: the sorted list becomes
   `['client_source_id','created_at','entity_type','id','label','native_id','source_id','source_platform','target_kind','updated_at']`.
   The banned-token loop (`email`, `price`, `billing`, `coach_id`, `payload`) stays and still passes. `ScoutEntitiesResult`
   props are unchanged (S8-F did not touch that class). The spec does not pin `ScoutRosterResult` props, so no roster edit.
   The cross-process determinism block re-runs the CLI into `IMPORTER_CONTRACT_OUT`; it passes once (1) is committed.
   Until both land in the same hooked commit as the 15 S8-F paths, `test/contracts/importer-contract.spec.ts` FAILS (drift
   check) — expected, and the reason the contract owner must be sequenced before the S8-F gate commit.
3. Landing note for LAND-PREP-1: S7-L also changes `importer-openapi.json` (lifecycle). Whichever candidate lands second
   onto `integration/importer` regenerates from the combined DTOs; S8-F composes onto S8-C only and must be regenerated
   again if S7-L lands first. Regeneration is idempotent and deterministic (stableSort), so ordering only changes when the
   artifact is produced, not its final content.

Nothing else outside the surface is required: no schema, migration, module wiring, families, flags, dependency or
workflow change. `src/scout/scout.module.ts` already provides both readers.

## Gate list needed later (heavy-slot relay; none run now)

In the composed worktree on the accepted S8-C head, with donor `node_modules` (`05bc530a…`) and the S8-C client
(`b6716a86…`) provisioned by the parent's runtime process (S8-F needs no `prisma generate` of its own — schema unchanged):

1. Scoped pinned prettier 3.9.9 (`recovery-reset/<lane>/tools/prettier-3.9.9`): `--check` then, if needed, `--write` on
   exactly the 15 S8-F paths + the 2 contract-owner paths. Expected reformat candidates (draft was never formatted):
   `test/rls-g2-s8f.spec.ts:79` (object-arg call > 100 cols), possibly wrapped SQL-adjacent lines in
   `g2-s8f-pg-harness.ts`/`g2-s8f-db.ts` (template literals themselves are not rewrapped). Long `it('…')` titles match
   the accepted base's style and are left by prettier. Re-hash after any write.
2. Scoped eslint `--no-warn-ignored --max-warnings 0` on the same paths. Risk noted by the draft: unused imports in the
   new test files, `as const` select typing.
3. `npx tsc --noEmit` (whole project; the hook runs it, heap 4096 as in S8-C). Draft-flagged unverified spots: Prisma `OR`
   typing in the provenance `where`, `NativeRecord` select typing, `PROGRAMS_FAMILY` now typed as the literal `'programs'`
   (used only where `string` is accepted).
4. Affected default Jest suites (`jest.config.js`, `--ci --runInBand`), all of which import the changed modules:
   `test/scout/entities/scout-entities.service.spec.ts` (F01–F09, F11, F03 now un-skipped: expect 0 skipped),
   `test/scout/entities/scout-entities.contract.spec.ts`, `test/scout/entities/scout-entities.controller.spec.ts`,
   `test/scout/roster/scout-roster.service.spec.ts`, `test/scout/roster/scout-roster.controller.spec.ts`,
   `test/scout/scout-cursor.spec.ts`, `test/scout/g2-s8f-db-guard.spec.ts`, `test/scout/reconstruct/conformance-alpha.e2e.spec.ts`,
   `test/contracts/importer-contract.spec.ts` (only after the generator owner's two edits) and
   `test/contracts/importer-contract-extraction.spec.ts`. `test/rls-g2-s8f.spec.ts` is excluded from the default run by
   `testPathIgnorePatterns` and runs only under the proof.
5. `node scripts/check-r75.js --mode=staged` (banned casts) — S8-F adds no `as` casts beyond `as const` / `as readonly
   string[]`; verify.
6. One genuine hooked commit (lefthook pre-commit: prod-readiness-quick, banned-cast-tokens, prettier, eslint, tsc;
   commit-msg no-ai-tokens), author/committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, message with no banned
   tokens, no amend. The 15 S8-F paths + the 2 contract-owner paths in the same commit (the drift test requires it), or the
   contract owner's commit first and S8-F's second — parent decides; never a partial state that leaves `main`-bound history
   with a red drift test.
7. Export `s8f/checkpoints/v1/` (bundle, HEAD.txt, MANIFEST) exactly as S8-C's v5 shape.

## Real-PG proof expected later (bind shape; nothing bound yet)

Reuse the S8-C v4 / S7-L v4 pattern (`s8c/binding/v4/{s8c-pg-proof.sh,s8c-fixture.sh,PINS.txt}`), substituting the lane:

- Lane identity: `PORT=55643` (the guard spec's example; refused set already contains 55511/55641/55642),
  `DB=g2_s8f_disposable`, `ADMIN=s8f_super`, `CLUSTER=s8f-disposable-pg17`,
  `DB_MARKER=s8f-g2-native-reader-synthetic-disposable-fixture-safe-to-drop`; env exported by the runner:
  `G2_S8F_DATABASE_URL`, `G2_S8F_CONFIRM=g2_s8f_disposable:55643`, `G2_S8F_PASSWORD`, `G2_S8F_PSQL` (the RT-2 psql 18.6
  `a200e38c…`), `G2_S8F_SERVER_VERSION=170006`.
- Fresh paths: `RUNTIME_ROOT/proof-v4/clusters/s8f`, `proof-v4/run/s8f`; the three-glob other-lane enumeration excluding
  own `$LANE/` (SCOPE S8C-BC-2 reconsideration); sentinel once-only; `flock -n` fd 9 on
  `/home/user/workspace/execution/test-validation.lock`, never deleted.
- Pins to fill only from the committed S8-F head: `EXPECT_HEAD`, `EXPECT_TREE`, five proof-file blobs
  (`test/rls-g2-s8f.spec.ts`, `test/utils/g2-s8f-bootstrap.sh`, `test/utils/g2-s8f-db.ts`,
  `test/utils/g2-s8f-pg-harness.ts`, `test/utils/g2-tq0-worker.cjs` — the last must equal `aa35e7e2…`), fixture sha;
  base ancestry = accepted S8-C head; `prisma/` tree identical to base (S8-F ships no migration — the bootstrap itself
  refuses uncommitted schema/migration changes, exit 4). Tool pins identical to S8-C v4 (PG 17.6 `23cd1748…`/`b7db9bc2…`,
  node `a03953a7…`, hidden lock `05bc530a…`, client `b6716a86…`).
- Sequence: init → start → `bash test/utils/g2-s8f-bootstrap.sh` (no subcommand; S8-B-derived; `prisma migrate deploy`
  of the whole accepted history, then asserts `ImportNativeProvenance` + `ScoutReconstructionLedger.target_kind` exist and
  applied == tracked migration count) → identity (170006, cluster marker, DB marker) →
  `./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s8f.spec.ts --runInBand --ci` exactly once → bounded
  stop → post (other lanes, worktree, client unchanged) → `RECEIPTS.sha256` + sentinel.
- Fixture shape (synthetic only, seeded as the BYPASSRLS owner role): `User(id,supabase_id,email,name,role)`,
  `ScoutImport(id,coach_id,intent_id,state,terminal_status)`, ledger rows with nullable `target_kind`,
  `ScoutReconstructedEntity`, `WorkoutPlan(type='strength')`, `WorkoutProgram(owner_user_id, weeks=1, days_per_week=1)`,
  `ImportNativeProvenance` rows honouring the S8-B CHECKs (`native_id IS NULL ⇔ outcome='unresolved'`, unresolved ⇒ reason).
  Stages: 0 lane identity; 1 F01/F02/F04 native joins on RLS-enabled tables + cross-tenant drop + API-role denial;
  2 F05 provenance denial + CHECK forgeries refused; 3 F07 archived-row paging (limit 2 over 5) + un-archive reappearance;
  4 F10 roster qualifier + uniform 404. Expected: all stages pass, 0 skipped; a full pass accepts that exact head only.
- Draft-flagged unverified fixture assumptions (first real run will tell): `User` insert column set, `PersonState` default,
  `WorkoutProgram` required ints. A failure there is a class-B proof-tool defect to be preserved and dispositioned, not
  looped.

## Open A/B findings (Safety-ROI form)

**none.** Observations recorded for reviewers (class C, no blocked decision, no edit made under this grant):

- C1 — The reader does not couple ledger `family` to `target_kind` (a `workouts` ledger row typed `workout_program` would
  be served under `workouts` if the coach owns a vouched program). Concrete harm: none cross-tenant or cross-coach — the
  row is the caller's own, provenance-vouched native record; S8-C writers never emit that combination. The RLS spec's
  stage 1 seeds exactly such a row (program under `workouts`) for compactness; if reviewers prefer realism, the minimum
  follow-up is to seed it under `programs` with a matching `entity_type` — a test-only edit inside the S8-F surface.
- C2 — `effectiveKind` treats an absent (`undefined`) `target_kind` as unknown → dropped. Unreachable through the real
  select (always projects the column); only a fake that omits the column would see it, and the direction is fail-closed.
- C3 — Reader accepts `already_present` although v5 writers only ever write `created`/`unresolved`; permissive within the
  closed CHECK set, matching the accepted contract §3.2 wording.

## Files in this checkpoint (`MANIFEST.sha256`)

`checkpoint/<15 repo paths>` (byte copies; bootstrap 755), `composition-vs-87018a42.patch` (2215 lines; tracked hunks via
`git diff HEAD`, untracked via `git diff --no-index /dev/null <path>` with `new file mode 100755` for the bootstrap;
verified with `git apply --check` + apply on a clean `git archive 87018a42` tree — all 15 resulting sha256 equal the
manifest), `DELTA_vs_frozen_draft.diff`, `CHANGED_PATHS.txt`, `COMPOSITION_BASE_HEAD.txt`, `GIT_STATUS_PORCELAIN.txt`,
`S8C_INTERFACE_BLOB_PINS_87018a42.txt`, this file. Verify: `cd s8f/composition && sha256sum -c MANIFEST.sha256`.
