# S8-F native-reader source preparation

Tier T4: tenant-scoped materialization of native customer data and provenance-qualified identities. Requested route `claude_fable_5_1`, high, not runtime telemetry. Parent retains integration and acceptance; two independent nonbuilder reviews will be needed for the final candidate. This grant permits disjoint source preparation only, not gates, commit, proof or landing.

## Frozen requirements and dependency

Accepted base: backend `93389265a846095b846fa8f1fb0dad782fb6ee9f`, containing S8-B's closed nullable ledger target kinds and native provenance schema. The accepted native contract section 6 requires readers to resolve typed native targets only to coach-owned IDs and expose `roster_bridge_pending`. Read that full accepted contract, current G01-G22, mission, Safety ROI, owner reset, `s8f/READINESS.md`, this grant, and S8-C's sealed `s8c/DRAFT_READY.md` plus sequencing addendum before drafting.

The parent freezes S8-C's N1-N4 handoff for this preparation: native programs/plans carry their typed kind and target id atomically in the ledger; client-linked workouts remain reconstructed `scout_entity` evidence, never native client data; `programs` joins the family list; native provenance qualifies native targets, not evidence or Person targets. Historical NULL kinds retain legacy per-family meaning. New reader behavior must not require an unaccepted source-specific rule or infer an intent join through the nullable UUID provenance field.

Create isolated worktree `/home/user/workspace/worktrees/64e33dc7-s8f`, branch `exec64/s8f-readers`, at the accepted base. S8-C is not accepted yet. Do not modify or commit its draft. Before gates/commit, compose onto the accepted landed S8-C state under a later parent relay; if its final interface changes, correct only the affected prepared delta.

## Sole writable surface

- `src/scout/scout-entities.{service,dto,controller}.ts`
- `src/scout/scout-roster.{service,dto,controller}.ts`
- Controller edits limited to necessary API description text.
- `test/scout/entities/**`, `test/scout/roster/**`
- New `test/rls-g2-s8f*.spec.ts`, `test/utils/g2-s8f-*`, `test/scout/g2-s8f-db-guard.spec.ts` if needed to prepare the minimum real-PG proof.
- Private source checkpoint and brief binding under `execution/64e33dc7/s8f/build/**` only. Do not alter the readiness author's file.

Not owned: writers, family list, mapping rules, lifecycle, module wiring, schema, migrations, contract generator/artifact/spec, dependencies/workflows, flags, principal policy. No overlapping writable surface with S7-L or S8-C.

## Required behavior

Keep the one RepeatableRead snapshot, same settled-intent uniform 404, ledger-anchored ordering/cursor, same-coach joins and erased-row drop. NULL/scout_entity targets retain current evidence materialization. Typed workout_plan/workout_program targets must exist, belong to the coach, not be archived, and have same-coach matching native kind/id provenance with created or already_present outcome. Unknown kinds, missing provenance and mismatches fail closed. No raw payload or additional personal data.

Entities add only `target_kind` and nullable `native_id`; legacy rows are otherwise unchanged. Report the effective materialized kind on legacy rows, with null native_id for generic evidence; native rows expose their owned native id, label from name and no invented client_source_id. Preserve all established field meanings and ledger paging even when targets are dropped.

Roster materializes only NULL/person kinds with the existing Person semantics. Add response-level `roster_bridge_pending: true` for the current interim accepted Person bridge, including empty results. This qualifier does not create native principals or decide S8-D/E policy.

Cover F01-F12 from readiness with focused default tests. Prepare only the necessary real-RLS cases for newly introduced native joins, provenance denial and archived-row paging; no accepted full proof rerun. Do not execute them yet. No counts, complete claim, Start/Stop wiring, activation or UI work.

## Checkpoint and continuation

Create an immutable exact source export and manifest under `s8f/build/`, and return DRAFT_READY with changed paths, dependency assumptions and actual unexecuted status. No installs, generate, compiler, Jest, hooks, PG, canonical-lock operations, commit, push or external publication. Parent owns generator coordination, proof grant, independent review, acceptance and non-production landing.
