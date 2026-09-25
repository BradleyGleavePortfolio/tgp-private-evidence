# S9-B code-read notes (EXEC-1910A060, lane B-NEW-1, 2026-09-25)

Read-only observations at base `1c5fbb0441178e0cfe6e9f8d72e955c645c265e9` (standalone clone
`/home/user/workspace/worktrees/1910a060-s9b`, branch `exec1910/s9b`; object source: the
no-checkout read-only clone `/home/user/workspace/growth-project-backend`). No toolchain was run:
the sandbox has Node v20.20.1 and no `node_modules`; nothing here is a gate result.

## Base facts the S9-B files depend on

- `prisma/migrations`: 172 directories; last is `20270123000000_scout_run_lifecycle_expand`
  (S7-L). `20270122000000_scout_native_provenance_expand` (S8-B) is present. S9-B ships none
  (D-S9-5, no report table).
- `prisma/schema.prisma` sha256 `0eb41f9a88ef3b77266e908a5ea814206c188d1bdb031bd96d746491fee84015`
  (equals the S7-L lane record `S7L_SCHEMA` in `daceddc8/runtime/lane-provision.sh`, whose
  generated-client record is `9042e713…`); `package-lock.json` sha256 `b7fed5ed…` unchanged since
  `93389265`.
- `ScoutImport` carries S7-L's `mode`, `execution_epoch`, `reason_code`;
  `ScoutImportCompletion @@unique([coach_id, intent_id])` with `terminal_status String`.
- `ScoutReconstructionLedger` identity `(coach_id, intent_id, entity_type, source_platform,
  source_id)`; `target_kind String?` (NULL for legacy/N-writer rows, e.g. the `clients` family).
- `ImportNativeProvenance` identity `(coach_id, source_namespace, entity_type, source_id)`;
  `import_intent_id` NULL at S8-C (intent-less), so provenance is read coach-wide and joined by
  identity, not by intent.
- `WorkoutProgram`, `WorkoutPlan`, `WorkoutPlanExercise` have `archived_at`; `Person` does not
  (an existing `Person` row is `present_owned`). `WorkoutPlan.program_id/week_index/day_index`
  and `WorkoutPlanExercise.order/workout_plan_id` are the E-R1/E-R2 comparands.
- `src/scout/reconstruct/native/sources` is absent (no native sidecar; `loadNativeRuleSets`
  returns `[]`), so the facts service takes its registries through an optional DI seam
  (`RECONCILIATION_FACTS_OPTIONS`) and the proof injects fixture specs/rules exactly as the S8-C
  worker does.
- `mapping-spec.ts` requires `clientSourceId` and `label` rules for every entity family
  (`EntityFieldRules`); `textField` accepts `text` and `identifier` rule kinds (so
  `programSourceId: { kind: 'identifier' }` is readable through the interpreter); `enumField`
  returns the declared `default` as a defaulted value (tag `defaulted:<field>`).
- `eslint.config.js`: `@typescript-eslint/no-unused-vars` is `warn` (the gate runs
  `--max-warnings 0`, so an unused import fails), `no-explicit-any` off, `no-console` allows
  `warn`/`error`. `jest.rls.config.js` matches `test/rls-*.spec.ts` only.
- Frozen S9-A shapes consumed (never edited): `IdentityFacts { token, identity, ledger,
  client_linked }`; `LedgerRowFacts` = `failed | skipped{reason} | reconstructed{target_kind,
  provenance}`; `ProvenanceFacts { outcome, native, reason, unresolved_children }`;
  `RelationshipFacts { edge, from_family, from_identity, to_family, to_identity, consistent }`;
  `ReconciliationFacts { claim, families, relationships, spec_families, ledger_without_staged,
  coverage }`. `closeRelationships` only looks at edges whose `from_identity` is bucket j and
  requires `to_identity` to be bucket j of `to_family`; `reconcile` appends `declaredOnly`
  entries for required families with no staged row and sorts mapped-first then by name.

## S8-C proof pattern reused (test/utils/g2-s8c-*, test/rls-g2-s8c.spec.ts)

- Guard (`g2-s8c-db.ts`): loopback-only URL, double-entered `CONFIRM = <db>:<port>`, refused-port
  list (…, 55641), literal cluster/db markers, candidate head binding (40-hex, ≠ base, clean
  worktree). S9 derivative adds `55642` (S8-C) and `55643` (S8-G) to the refused list and leaves
  the lane port to the parent (55645 suggested; 55644 was S8-G's mismatch probe).
- Bootstrap: roles/marked DB/extensions, `prisma migrate deploy` from the candidate root, object
  assertions, candidate generated client verified (engine/runtime pins; the schema copy is checked
  structurally, as S8-G does — no invented normalized-schema SHA).
- Worker: separate OS process with the candidate generated client, `@prisma/client` resolution
  pinned to the candidate tree, query-event log (shapes only, never parameters), fixture
  registries parsed through the real parsers and injected. S9 derivative adds `mode: 'facts'`
  (default) running `ReconciliationFactsService.collect` inside one `RepeatableRead`
  `$transaction` followed by the frozen `reconcile`; `mode: 'reconstruct'` is the S8-C writer,
  used only to produce genuine rows.
- Harness: fixture SPEC/RULES for platform `s8c-proof` (`blocks→programs`, `routines→workouts`,
  week/day base 1, exercises with `#id:`/`#ord:` children). S9 derivative renames the platform to
  `s9-proof`, adds `s9-proof-b` (spec only, `workouts` only), a `claim()` writer for
  `ScoutImportCompletion`, and resets that table too.

## Things to verify at gate time (cannot be verified without the toolchain)

1. Prettier formatting of all owned files (written by hand; long lines in the rls spec are likely
   to be re-wrapped).
2. `tsc --noEmit`: the `Row`→`FactsDb` double cast in the unit spec, the `as unknown as
   LedgerRowFacts` pass-through of out-of-type ledger statuses, `Prisma.TransactionClient` as the
   `FactsDb` alias, and the interpreter type alias derived from `buildNativeFamilies().workouts`.
3. Prisma query-event log wording for `isolationLevel: 'RepeatableRead'` (the rls spec expects a
   `REPEATABLE READ` statement in the log; if Prisma emits it differently, relax that one line).
4. The exact SELECT count bound (6–7 small, +1 per extra 500-row staged page) assumes one SELECT
   per `findMany`/`findUnique`; adjust if the client adds statements.
