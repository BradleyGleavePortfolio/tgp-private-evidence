# S8-F reader readiness (planning only; not a review, grant or acceptance)

Lane `s8_f_reader_readiness_muge8avl`, 2026-09-25 ~03:30Z. This was a read-only look at accepted backend integration `93389265`: contract `docs/decisions/2026-09-24-s8-native-contract.md` §3.2/§3.3/§4.1/§4.3/§6, the entities and roster service/DTO/controller, S8-B schema/migration `20270122000000`, `families.ts` and `scout-reconstruct.service.ts`. At that time both replacement worktrees (`64e33dc7-s7l`, `64e33dc7-s8c`) were clean at `93389265`. No S8-C or S8-F source exists, and none is claimed here.

## Frozen now (accepted at 93389265)
- Ledger `target_kind` is nullable. A closed CHECK allows only `person|scout_entity|workout_program|workout_plan`, and a shape CHECK requires a `target_id` whenever a kind is set. NULL means the row came from the legacy N/Q1/C writer.
- `ImportNativeProvenance` is unique on (coach, namespace, entity_type, source_id) and indexed on (coach_id, native_kind, native_id). `native_id` is NULL exactly when the outcome is `unresolved`. `import_intent_id` is a nullable UUID, so it cannot yet be joined to the ledger's string `intent_id`.
- Existing reader rules stay binding: one RepeatableRead snapshot, the settled-intent 404 gate, a cursor anchored to the ledger (source_id, source_platform), coach_id checked again on every join, and erased targets simply dropped (Q06).
- Contract §6 for S8-F: native targets resolve by `target_kind` to native IDs the coach owns, and `roster_bridge_pending` is visible (§4.1). Family counts belong to S7-L status, not to these readers.

## Needs the final S8-C interface (don't guess)
- N1. Nobody writes ledger `target_kind` today. `writeLedger` (`scout-reconstruct.service.ts` L268-307) writes only `target_id`, and `persist` returns `string|null` (`families.ts` L37). That service file is in neither S8-C's nor S7-L's writable surface. See A1.
- N2. For client-linked workouts that still get a generic evidence row: the ledger status/target_id/target_kind that S8-C records for them (§4.3, "evidence row may continue").
- N3. Adding `programs` to `RECONSTRUCT_FAMILY` automatically adds it to `ENTITY_REVIEW_FAMILIES` (`scout-entities.dto.ts` L41) and to the published entities `family` enum. Until S8-F lands, the materializer reads only `ScoutReconstructedEntity`, so native programs and unlinked-workout plans would silently drop out of review (F4 harm).
- N4. Whether provenance rows are written for `scout_entity` evidence targets. Assumed no; legacy/evidence rows are validated as today.

## Smallest S8-F continuation (backend, T3; becomes T4 only if identity/erasure semantics change)
- Entities `materialize`: split ledger rows by `target_kind`. NULL or `scout_entity` → `ScoutReconstructedEntity`, as today. `workout_plan` → `WorkoutPlan`, and `workout_program` → `WorkoutProgram`, each filtered on {id, coach_id, archived_at null}. Both native kinds also require a provenance row (coach, native_kind, native_id, outcome created|already_present), which gives the "brought across" guard. Unknown kinds or mismatches are dropped (fail closed). Ledger order and cursor stay unchanged.
- Entities DTO: additive fields only. Proposed: required `target_kind` plus nullable `native_id` for deep links; native routes are `/workout-plans/:planId` and `/workout-programs`. Native rows fill `label` from `name` and use `client_source_id` null. Existing field meanings stay the same.
- Roster: materialize only `target_kind` NULL or `person`. Add a result-level `roster_bridge_pending` qualifier (the exact shape is the parent's call). Person semantics stay unchanged.
- Out of scope: counts, status, the writer, family list, schema, generator, mobile, S8-D/E and G3 policy.

## Proposed exact writable paths for the S8-F grant
- `src/scout/scout-entities.{service,dto,controller}.ts` and `src/scout/scout-roster.{service,dto,controller}.ts` (controllers: API description text only).
- `test/scout/entities/**` and `test/scout/roster/**`. If a PG proof is granted: new `test/rls-g2-s8f*.spec.ts`, `test/utils/g2-s8f-*` and `test/scout/g2-s8f-db-guard.spec.ts`. Private evidence goes under `execution/64e33dc7/s8f/**`.
- Not owned: `scout-reconstruct.{dto,service}.ts`, `families.ts`, `reconstruct/native/**`, schema/migrations, `scripts/importer-contract.ts`, `docs/contracts/importer-openapi.json`, `test/contracts/**`.

## Fixed acceptance cases
- F01: Legacy rows with NULL `target_kind` (workouts/client_history evidence rows, clients Person rows) render byte-identical apart from the approved additive fields.
- F02: A `workout_plan` target resolves to the coach's WorkoutPlan with `native_id`. F03: A `programs` / `workout_program` target resolves to the coach's WorkoutProgram.
- F04: A target_id pointing at another coach's native row is absent, with no existence oracle. F05: A coach's own non-imported plan (no provenance) is absent.
- F06: A kind mismatch (ledger kind differs from the provenance kind or the table actually hit) is absent. F07: An archived native target is absent, the cursor still advances by ledger row, and no Deleted state leaks.
- F08: A mixed page (evidence + native in one family/intent) keeps ledger order; `page_count` equals rows rendered; `next_cursor` is anchored to the last ledger row.
- F09: Unknown, unsettled or cross-tenant intents still get a uniform 404. F10: The roster always carries `roster_bridge_pending`, and a non-person `target_kind` never becomes a Person.
- F11: Read-only, no raw payload or PII added, analytics keys unchanged or additive. F12: The entities `family` enum equals `ENTITY_REVIEW_FAMILIES` in a regenerated artifact, with additive fields only.

## Dependency event and generator coordination (single owner: S7-L)
- Design and drafting can start on S8-C DRAFT_READY, provided its manifest pins N1-N4. Build/commit starts only once S8-C is accepted and landed on integration/importer, then rebased onto that head.
- S8-C (N3) and S8-F both change the generated artifact and the drift check (`test/contracts/importer-contract.spec.ts` L62). Only the generator owner regenerates; S8-F never edits generator files. The contract version bump lives in `scripts/importer-contract.ts` L49 and spec L442, S7-L currently targets `2.0.0-c1-s2.0`, and the parent sequences any later regeneration.
- PG: S8_BRIEF says "one case folded into the S8-C PG run". That only works if S8-F bytes exist when that PG grant is issued. Otherwise S8-F needs its own one-run PG case (F04/F05/F07 on real RLS). The parent decides.

## A/B
- A1 (S8-C interface). Harm: native and legacy targets in `workouts` are indistinguishable, so rows get misrouted or disappear. Blocked: the S8-F dispatch design. Minimum closure (either one): (a) S8-C writes ledger `target_kind` on every reconstructed row, which needs the parent to add `scout-reconstruct.service.ts` writeLedger plus the persist return type to S8-C's surface; or (b) the parent freezes a provenance lookup (coach, native_kind, native_id), with NULL meaning a legacy default per family. Unlocks: the S8-F build. Recommended: (a), because (b) costs an extra lookup per page and can't type evidence rows.
- A2 (landing order, N3). Harm: native targets drop out of review between S8-C landing and S8-F landing. Minimum closure: the parent records "no reader/flag activation before S8-F lands" and lands S8-F as the next dependent candidate. With flags dark on non-production integration, this is effectively record-and-continue (C). Unlocks: S8-C can land independently.
