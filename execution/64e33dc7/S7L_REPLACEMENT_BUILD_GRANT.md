# S7-L replacement candidate build grant

Tier T4: migration, persisted identity, tenancy, concurrency/fencing and terminal truth. Canonical requested route: `claude_fable_5_1`, high, per latest durable execution route; requested route is not runtime telemetry. Parent owns orchestration, proof grants, evidence publication and landing; two independent nonbuilder final-head reviews are required.

## Base, owner and source

Owner is the new worker assigned to this grant in current DISPATCHES. Create isolated branch `exec64/s7l-replacement` and worktree `/home/user/workspace/worktrees/64e33dc7-s7l` from accepted `93389265a846095b846fa8f1fb0dad782fb6ee9f` in `/home/user/workspace/growth-project-backend`. New lineage: do not recover, imitate or inherit acceptance from `a585bf76`. See `OWNER_RECOVERY_RESET.md`.

Read completely before writing: live `tgp-agent-context/AGENT_RULES.md`; mission `roadmap/M-IMPORTER-PRODUCT-MISSION_v1.md`; this grant and owner reset; accepted backend `docs/decisions/2026-09-24-s7l-run-lifecycle.md`; `execution/ce3748cb/s7l-prep/S7L_BRIEF.md`; current Safety ROI doctrine `execution/6c2a68ac/OWNER_SAFETY_ROI_AND_EXECUTION_DOCTRINE.md`. The accepted decision is later and overrides the older brief wherever they differ, notably UPDATE-first gating rather than FOR SHARE, guard order, binding constraints, down refusal and lazy deadline semantics.

## Sole writable product surface

- `prisma/migrations/20270123000000_scout_run_lifecycle_expand/{migration,down}.sql`
- `prisma/schema.prisma`: ScoutImport lifecycle fields/constraints representation and required ImportIntent backrelation only.
- `src/scout/lifecycle/**`, `src/scout/scout.controller.ts`, `src/scout/scout.dto.ts`, `src/scout/scout.service.ts`, `src/scout/scout.module.ts`, `src/scout/scout-ingest.service.ts`.
- `src/analytics/events.ts`: only necessary additive lifecycle keys.
- Corresponding existing scout controller/dto/service specs and new `test/scout/lifecycle/**`.
- `test/rls-g2-s7l*.spec.ts`, `test/utils/g2-s7l-*`, `test/scout/g2-s7l-db-guard.spec.ts`.
- Sole generator ownership: `scripts/importer-contract.ts`, `docs/contracts/importer-openapi.json`, `test/contracts/importer-contract.spec.ts`. Generate from real DTOs; no hand-authored generated artifact.

Private source-ready receipts, fresh binding and exact checkpoint exports only under `execution/64e33dc7/s7l/**`. Do not edit historical evidence, S8-C paths, N/Q1/C/S8-B accepted proof files, dependencies, workflow/policy or production configuration. No other writer may touch schema, lifecycle or contract generator.

## Required new behavior and proof boundary

Implement accepted S7-L1/L2/L3 requirements: expand-only lifecycle schema and safe refusing down; one owned paired non-superseded intent per server run; immutable accepted start/deadline; idempotent Start; cancel; monotonic execution epochs; UPDATE-first transaction fence; lazy deadline without self-wait; one CAS-safe terminal arbiter; immutable completion claim separate from server truth; legacy behavior preserved; truthful additive status/family counts with unknowns null; fixed codes; new Start/cancel routes and generated contract `2.0.0-c1-s2.0`. No complete without an S9 reconciliation verdict. No new G3 policy, retention/erasure policy, feature flag or activation.

Prepare tests for all L01-L12 criteria in the accepted decision, including real-service duplicate Start, concurrent ingest/progress and cancel barriers, post-fence denial, late completion no-op, lazy timeout persistence, tenant isolation, legacy compatibility, RLS/rollback, catalog and refusing-down/migration reversibility. Design one new real-PG proof covering new migration and service bytes; do not invoke old accepted suites. Reuse applicable harness patterns as code patterns, not historical result claims. OLD_HEAD is current accepted base; actual history count/pins come from that base, not old S7-L receipt.

## Execution

Source/test/binding drafting starts now in parallel with S8-C. No installs, generate, compiler/Jest, hook execution or PG until parent relays the canonical heavy slot. Runtime setup is a separate worker. Do not use platform node_modules. No local or remote DB/account credentials; disposable local identities only.

When source is ready: checkpoint exact changed/untracked bytes into this lane's private export with a short manifest, report DRAFT_READY and required environment/gates. After parent slot relay, run scoped formatting/lint/R75, TypeScript (heap 4096), relevant default Jest and genuine hooks; ordinary Bradley author/committer commit, no trailers. Report exact base/head/tree and raw outcomes. Export a self-contained Git bundle after committing. No push or PG yet. Dual independent reviews then a separate one-run real-PG grant; accepted dependency-valid work lands to integration/importer, never production main.

If a concrete A/B needs another path or contract change, state harm, blocked decision and minimum closure; continue unaffected owned work. C is record/qualify/continue, not new rerun or redesign.
