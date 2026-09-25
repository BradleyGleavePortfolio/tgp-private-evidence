# S8-G exact owned writable paths (proposed; effective only under a future S8-G build grant)

Base: the `integration/importer` head after **both** S7-L (`a68cdac7` lineage) and S8-C (`87018a42` lineage) are accepted and landed; S8-G rebases onto that head. Until then: no product bytes (READINESS).

## Product (backend repo)

| Path | Status | Allowed change |
|---|---|---|
| `src/scout/reconstruct/orchestration/run-context.ts` | new | `RunContext`, `GateFn`, `LEGACY_RUN`, `RunPassStopped`, `FamilyPassResult`, `RunPassResult` |
| `src/scout/reconstruct/orchestration/family-plan.ts` | new | `RUN_FAMILY_ORDER`, `planRun` (pure) |
| `src/scout/scout-reconstruct.service.ts` | modify | exactly these hunks against `87018a42`: (a) imports of the two orchestration modules and `resolveStagedFamily`/`buildSourceMapperRegistry`; (b) new public `reconstructRun(coachId, intentId, ctx)` and its private family/token driver; (c) `reconstructRow` L178-183 signature `+ ctx: RunContext`, gate block before L218, `RunPassStopped` rethrow before L263; (d) `writeOutcome` L275-282 signature `+ ctx`, gate block before L287; (e) `reconstruct()` passes `LEGACY_RUN` at L99 (through `reconstructRow`) — no other change to `reconstruct()`, `assertSettled`, `assertWithinBound`, `writeLedger`, `tally`, `retryContention`, `summarizeError`; (f) optional: ledger `entity_type` = `row.entity_type ?? family.entityType` at the `writeLedger` call sites (DESIGN §3.4, parent decision C4) |
| `src/scout/lifecycle/lifecycle.service.ts` | modify | exactly three hunks against `a68cdac7`: (a) `import { ScoutReconstructService } from '../scout-reconstruct.service'` (+ `Optional` from `@nestjs/common`); (b) constructor L114-119: `@Optional() reconstruct?: ScoutReconstructService` and `private readonly reconstruct` assigned `reconstruct ?? new ScoutReconstructService(prisma, analytics)`; (c) body of `onTransferSettled` L313-335 per DESIGN §4.2 (the S7-L tail L314-334 kept verbatim). Nothing else in `lifecycle/**` |
| `src/scout/scout.module.ts` | **no change expected** | both services are already providers (L50, L53); touch only if Nest DI fails to resolve the optional parameter, and then provider wiring only |
| `src/analytics/events.ts` | **no change expected** | READINESS allows one additive key; DESIGN uses existing `SCOUT_RECONSTRUCT_COMPLETED` and `SCOUT_RUN_SETTLED` |

## Tests (backend repo)

| Path | Status |
|---|---|
| `test/scout/orchestration/family-plan.spec.ts` | new (draft attached) |
| `test/scout/orchestration/reconstruct-run.spec.ts` | new (draft attached) |
| `test/scout/orchestration/settle-hook.spec.ts` | new (draft attached) |
| `test/rls-g2-s8g.spec.ts` | new (draft attached) |
| `test/scout/g2-s8g-db-guard.spec.ts` | new (draft attached) |
| `test/utils/g2-s8g-worker.cjs` | new (draft attached) |
| `test/utils/g2-s8g-db.ts`, `test/utils/g2-s8g-pg-harness.ts`, `test/utils/g2-s8g-harness.ts`, `test/utils/g2-s8g-bootstrap.sh`, `test/utils/g2-s8g-old-root.sh` | new; S7-L files renamed `s7l→s8g` with lane constants (`g2_s8g_disposable`, `s8g_super`, `s8g-disposable-pg17`), `OLD_HEAD` = the landed pre-S8-G integration head |
| `test/scout/reconstruct/native/fixtures/s8c-rules.json` | new fixture only if S8-C's rule fixture is not already importable; otherwise reuse S8-C's path read-only |
| `jest.config.js` | modify only if `rls-g2-s8g` is not already covered by the existing `rls-g2-*` exclusion glob |

## Explicitly not owned (unchanged by S8-G)

`prisma/**`; `src/scout/lifecycle/{arbiter,reason-codes,lifecycle.dto,run.controller}.ts`; `src/scout/reconstruct/native/**`; `src/scout/reconstruct/{families,mapping-spec,source-mapper-registry}.ts`; `src/scout/reconstruct/sources/**`; `src/scout/scout.service.ts`; `src/scout/scout-ingest.service.ts`; `src/scout/scout-reconstruct.{controller,dto}.ts`; `src/scout/scout-entities.*`, `scout-roster.*` (S8-F); `scripts/importer-contract.ts`, `docs/contracts/**`; `docs/decisions/**` (S8-G needs no decision doc; DESIGN.md is evidence); workflows, flags, policies; all existing spec files (`src/scout/scout.service.spec.ts`, `test/scout/reconstruct/**`, `test/scout/lifecycle/**`, `test/rls-g2-s7l.spec.ts`, `test/rls-g2-s8c.spec.ts`).

## Evidence

`execution/64e33dc7/s8g/**` (this draft under `s8g/draft/`; a future build writes `s8g/build/`, `s8g/binding/v1/`, `s8g/reviews/`, `s8g/checkpoints/`).
