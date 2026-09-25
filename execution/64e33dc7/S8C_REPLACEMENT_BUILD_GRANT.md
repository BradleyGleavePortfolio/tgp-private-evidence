# S8-C replacement candidate build grant

Tier T4: native customer-data writes, tenant identity, replay and side-effect boundaries. Canonical requested route `claude_fable_5_1`, high; not a runtime telemetry claim. Two independent nonbuilder final-head reviews required. This is a new implementation lineage, not recovered predecessor draft work.

## Base and required reading

New sole writer per current DISPATCHES. Create branch `exec64/s8c-replacement`, isolated worktree `/home/user/workspace/worktrees/64e33dc7-s8c`, from accepted backend integration `93389265a846095b846fa8f1fb0dad782fb6ee9f`, which contains accepted S8-A and S8-B. Do not use the missing `89a84820` draft or its receipts as source/proof.

Read completely before writing: `OWNER_RECOVERY_RESET.md`, live G01-G22, mission `roadmap/M-IMPORTER-PRODUCT-MISSION_v1.md`, Safety ROI doctrine, accepted backend `docs/decisions/2026-09-24-s8-native-contract.md`, predecessor `execution/ce3748cb/S8_C_BUILD_GRANT.md`, applicable S8-C sections of `s8-prep/S8_BRIEF.md` and accepted S8-A/B interfaces. Current accepted code and later accepted decisions override stale implementation facts in planning prose.

## Sole writable surface

- `src/scout/reconstruct/native/**` (new).
- `src/scout/reconstruct/families.ts`: native persist registration and `resolveStep` dispatch wiring only.
- `src/scout/scout-reconstruct.dto.ts`: canonical family list.
- New `test/scout/reconstruct/native/**`, `test/rls-g2-s8c*.spec.ts`, `test/utils/g2-s8c-*`, `test/scout/g2-s8c-db-guard.spec.ts`.
- Private receipts, binding and exact checkpoint exports under `execution/64e33dc7/s8c/**`.

Not owned: schema/migrations, lifecycle, scout service/ingest/controller, contract generator/artifacts, readers, source mapping interpreter or accepted mapper fixtures, workflow/dependency/policy files. S7-L has the sole schema/generator surface; no shared product-file ownership. Report concrete minimal additional-path needs instead of changing them silently. Contract regeneration coordination is parent-owned, not a speculative cross-worktree edit.

## Scope and acceptance

Canonical programs/workouts become actual WorkoutProgram, WorkoutPlan and WorkoutPlanExercise templates using persistence primitives, never assignments or live-action services. Accepted S8-0 rules bind: A1 revisions; A2 unresolved children; D-S8-2 interim coach-owned only; D-S8-3 native identity; D-S8-4 create-only. Route staged step tokens through existing `resolveStep` so the accepted A3 dispatch guard applies. Do not introduce source-specific core code.

Native and provenance rows are atomic in the same tx. Replay creates no duplicate/drift and preserves coach edits. Distinct coaches cannot see/link each other's records. Exercise links require verified exact catalog identifiers; otherwise explicit `unresolved:exercise_reference`, never guessed mappings. Preserve ordering, truthful tally = ledger and unresolved children preventing complete. Missing client principal remains explicit unresolved and does not trigger User creation or S8-D/E work.

Tests must cover real services, exact exercise-ID behavior, replay/concurrent identity, coach-edit preservation, isolation, atomic rollback, stable ordering and zero assignment/notification/email/billing side effects. Prepare one real-PG S8-C proof using fresh identities/paths, accepted S8-B schema and its applicable patterns; never rerun S8-B or inherited accepted suites. S8-G later wires lifecycle commit fencing; don't invent a substitute lifecycle contract in this writer.

## Execution and boundaries

Draft source/test/binding now in parallel with S7-L. No installs, generate, compiler/Jest, hooks or PG until parent relays the canonical heavy slot. Separate runtime owner prepares tooling; never use platform node_modules or production credentials.

Checkpoint exact draft changed/untracked bytes in the new lane and report DRAFT_READY with a compact manifest. On parent slot relay: relevant formatting, eslint, TypeScript heap 4096, R75, affected default Jest, genuine hooks and ordinary Bradley author/committer commit without trailers. Publish no product refs yourself. Report SOURCE_READY with actual head/tree/gates and self-contained bundle. Dual independent reviews and separate one-run PG grant follow; acceptance then autonomous non-production integration landing.

A/B: concrete harm, decision blocked, minimum closure, execution unlocked. C: record and continue, no new audit/rerun. Do not expand into S8-D/E, G3 policy, reader redesign or production.
