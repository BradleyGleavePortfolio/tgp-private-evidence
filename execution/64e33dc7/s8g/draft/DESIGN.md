# S8-G design draft — reconstruct-then-arbitrate orchestration (DRAFT_READY, evidence only)

Grant S8G-DRAFT-1 (`daceddc8/SCOPE.md`). Drafted 2026-09-25 ~16:40Z against the two DRAFT_READY candidates, read with `git show HEAD:<path>`:

- S7-L `worktrees/64e33dc7-s7l` HEAD `a68cdac7` (pending `test/utils/g2-s7l-worker.cjs` resolver change ignored).
- S8-C `worktrees/64e33dc7-s8c` HEAD `87018a42` (pending `test/utils/g2-s8c-bootstrap.sh` ignored).

Binding input: `s8g/READINESS.md` (seam 1-4, disjoint ownership, G01-G14, E1-E6/N1-N4). No product, worktree, git, lock, gate, test or PG operation was performed. Line numbers are 1-based in the committed blobs.

Composition fact used throughout: the two candidates touch disjoint files. S7-L's diff vs `93389265` never touches `scout-reconstruct.service.ts`, `reconstruct/**`; S8-C's diff never touches `lifecycle/**`, `scout.service.ts`, `scout.module.ts`, `events.ts`. So the S8-G seam below is expressed against S8-C's engine bytes and S7-L's lifecycle bytes without a merge ambiguity.

## 0. One-paragraph shape

`ScoutService.completeServerRun` (S7-L `scout.service.ts` L368-412) commits the claim transaction and then awaits `this.lifecycle.onTransferSettled(coachId, dto.intent_id, epoch)` (L410). S8-G changes exactly one thing in that hook: before the existing locked CAS tail (L314-327) it runs one multi-family reconstruction pass through a new run-aware engine entry `ScoutReconstructService.reconstructRun(coachId, intentId, ctx)`, whose every per-row transaction begins with the §3.1 gate. The tail — `lockRun` → epoch check → `collectFacts` → `arbitrate` → `writeTerminal` — is kept verbatim, so the verdict is computed from durable rows under the row lock after the pass, and the CAS/epoch semantics are S7-L's bytes, untouched. S8-G never writes `terminal_status`, `completed_at`, `reason_code`, `fenced_at` or `execution_epoch` and never emits `complete`.

## 1. Seam 1 — run-aware engine entry

### 1.1 Actual candidate interface (S8-C `src/scout/scout-reconstruct.service.ts` @87018a42)

| Element | Lines | Fact |
|---|---|---|
| `constructor(prisma: PrismaService, analytics: AnalyticsService)` | L57-60 | no lifecycle dependency |
| `reconstruct(coachId, intentId, entityType = RECONSTRUCT_ENTITY_TYPE): Promise<ScoutReconstructResult>` | L62-132 | family lookup L69-72 (400), `assertSettled` L74, `count` L82, `assertWithinBound` L83, paged loop L90-101 calling `reconstructRow` L99, `tally` L103, analytics `SCOUT_RECONSTRUCT_COMPLETED` L122-129 |
| `assertSettled` | L139-149 | 409 unless `terminal_status IS NOT NULL` — the settled gate readers share (S7-L invariant 5) |
| `assertWithinBound` | L156-170 | 409 when `staged > RECONSTRUCT_MAX_ROWS` (10 000, dto L110) |
| `reconstructRow(family, coachId, intentId, row)` | L178-273 | platform check L186-188 (`ProvenanceConflict`), `map` L191, `writeOutcome(failed)` L193-200, `writeOutcome(skipped)` L204-211, success transaction L215-261, catch L262-272 (`ProvenanceConflict` rethrown L263, anything else → `writeOutcome(failed)` L264-271) |
| success transaction body | L216-260 | **first statement is `family.persist(tx, …)` L218**, then `writeLedger` in the same `tx` (typed outcome L219-248, legacy L250-259) |
| `writeOutcome(entityType, coachId, intentId, row, status, reason)` | L275-290 | a second, separate `$transaction` whose **first statement is `writeLedger`'s upsert** L286-288 |
| `writeLedger(tx, entityType, …, targetKind = null)` | L300-347 | ledger identity uses the `entityType` argument L314 |
| `retryContention` / `isContention` | L389-409 | retries only P2002/P2034; other errors rethrown unchanged |

### 1.2 Proposed entry (owned: this file only, hunks listed in PATHS.md)

```ts
// src/scout/reconstruct/orchestration/run-context.ts (new, owned)
export type GateFn = (tx: Prisma.TransactionClient) => Promise<number | null>;
export type RunContext =
  | { readonly mode: 'legacy' }
  | { readonly mode: 'server'; readonly epoch: number; readonly gate: GateFn };
export const LEGACY_RUN: RunContext = { mode: 'legacy' };
/** Thrown out of a per-row transaction when the §3.1 gate returned zero rows or a foreign epoch. */
export class RunPassStopped extends Error { constructor() { super('scout run pass stopped: gate closed'); this.name = 'RunPassStopped'; } }
export interface FamilyPassResult { token: string; family: string | null; staged: number; reconstructed: number; skipped: number; failed: number; stopped: 'gate_closed' | 'over_ceiling' | 'provenance_conflict' | null; }
export interface RunPassResult { families: FamilyPassResult[]; unmapped_families: string[]; stopped: 'gate_closed' | null; }
```

```ts
// scout-reconstruct.service.ts — additions
async reconstructRun(coachId: string, intentId: string, ctx: Extract<RunContext, { mode: 'server' }>): Promise<RunPassResult>
```

Behaviour of `reconstructRun` (server mode only; the legacy route never calls it):

1. No `assertSettled` (the run is open in phase `reconciling`, terminal null). No other precondition: the gate inside each row transaction is the only admission check (§3.1). A run with zero staged rows performs zero transactions.
2. Enumerate `SELECT DISTINCT source_platform, entity_type FROM "ScoutIngestEntity" WHERE coach_id=$1 AND intent_id=$2` (Prisma `groupBy({ by: ['source_platform','entity_type'], _count })`). Plan with the pure helper (§3).
3. For each canonical family in `RUN_FAMILY_ORDER`, for each (platform, token) planned into it: `count` by `{coach_id, intent_id, entity_type: token, source_platform}` → `assertWithinBound` (409 caught at family level, see §3.3) → paged read exactly as L90-101 but selecting `entity_type` too and forwarding it on the `StagedRow` (families.ts L25-26 already declares the optional field) → `reconstructRow(family, coachId, intentId, row, ctx)`.
4. `RunPassStopped` from any row stops the whole pass immediately (no further family), records `stopped: 'gate_closed'` and returns; the hook then calls `classifyClosed` (§4.2).
5. Unmapped tokens: one `writeOutcome(token, …, RECONSTRUCT_STATUS.skipped, 'unresolved_family:<token>', ctx)` per staged row of that token (gate-first, so a fenced run stops here too), collected into `unmapped_families`. This uses S8-A's exact reason string (`mapping-spec.ts` L140 `unresolvedFamilyReason`), no new reason code (E5).
6. Per family: `tally` (L350-370) by token, the existing `SCOUT_RECONSTRUCT_COMPLETED` capture (same properties as L122-129, `entity_type` = token). No new event key.

`reconstruct()` (coach-JWT route) is refactored only to pass `LEGACY_RUN` into `reconstructRow`/`writeOutcome`; its statement sequence is unchanged (see §5).

## 2. Seam 2 — gate first in every per-row transaction

### 2.1 Insertion points (S8-C engine bytes)

| Point | Today | S8-G insertion |
|---|---|---|
| Success transaction, L216-217 (before `family.persist` L218) | `persist` is the first statement | `if (ctx.mode === 'server') { const seen = await ctx.gate(tx); if (seen === null || seen !== ctx.epoch) throw new RunPassStopped(); }` then `persist` → provenance (inside persist) → `writeLedger` unchanged |
| `writeOutcome`, L286-287 (before `writeLedger`) | ledger upsert is the first statement | same gate block first |
| `reconstructRow` catch, L262-263 | `ProvenanceConflict` rethrown, everything else → `writeOutcome(failed)` | add `if (err instanceof RunPassStopped) throw err;` before the fallback, so a closed gate never produces a fabricated `failed` outcome |
| `reconstructRow` signature L178-183, `writeOutcome` L275-282 | no ctx | add trailing `ctx: RunContext` parameter; `reconstruct()` passes `LEGACY_RUN` |

The gate is S7-L's `assertRunOpen(tx, coachId, intentId)` (`lifecycle.service.ts` L422-432): an UPDATE that is itself the row lock, `RETURNING execution_epoch`, one row ⇒ open. Its WHERE (L427-429) is `mode='server' AND terminal_status IS NULL AND fenced_at IS NULL AND deadline_at > now()` — **no phase predicate**, so a run in `reconciling` is admitted (E1 confirmed). The row lock is held to the row transaction's commit, so no fence (`FOR NO KEY UPDATE`, L338-342) can commit between the gate and the row's commit; the equality check `seen === ctx.epoch` is therefore the per-row CAS READINESS seam 2 asks for and is deterministic (a fence always sets `fenced_at`, which the gate already excludes, and increments the epoch, which the equality catches).

`retryContention` (L389-403) does not retry `RunPassStopped` (`isContention` L405-409 admits only P2002/P2034), so a closed gate is rethrown once, unchanged. Nested transactions: none — S8-C's native writers open no `$transaction` (grep over `reconstruct/native/*.ts`: 0 occurrences; `native-writers.ts` L34-36 states they run on the engine's per-row transaction). So one row = one transaction = gate → persist (native rows + provenance) → ledger (N1 confirmed).

### 2.2 Legacy path

`ctx.mode === 'legacy'` skips the block: no gate, no `assertRunOpen` import, no epoch. Statement sequence identical to L216-260 / L286-288.

## 3. Seam 3 — family orchestration (new `src/scout/reconstruct/orchestration/family-plan.ts`, pure)

### 3.1 Order

Contract §3.8 (`docs/decisions/2026-09-24-s8-native-contract.md` L314-315): `clients → programs → workouts (coach templates) → client-owned families`. Proposed constant:

```ts
export const RUN_FAMILY_ORDER = [RECONSTRUCT_FAMILY.clients, RECONSTRUCT_FAMILY.programs, RECONSTRUCT_FAMILY.workouts, RECONSTRUCT_FAMILY.client_history] as const;
```

`RECONSTRUCT_FAMILY` declaration order (dto L13-18: clients, workouts, client_history, programs) and `buildFamilyRegistry` insertion order (families.ts L174-179) are **not** §3.8 order; S8-G must not iterate the registry. `programs` before `workouts` is load-bearing: program-day plans resolve their parent through provenance (`native-writers.ts` L131-165, `relationship_pending` when absent), proven in S8-C's PG case "program-day workouts: relationship pending until the program lands" (`test/rls-g2-s8c.spec.ts` L323).

### 3.2 Token → family (no double-mapping at the engine level)

```ts
export function planRun(staged: readonly { source_platform: string; entity_type: string; _count: { _all: number } }[], mappers: ReadonlyMap<string, SourceMapper>, registry: ReadonlyMap<string, FamilyReconstructor>): RunPlan
// RunPlan = { ordered: { family: CanonicalFamily; sources: { source_platform: string; token: string; staged: number }[] }[]; unmapped: { source_platform: string; token: string; staged: number }[] }
```

Rule per (platform, token): `resolveStagedFamily(mappers, platform, token)` (`source-mapper-registry.ts` L101-109 → `resolveStep` `mapping-spec.ts` L251-257). `ok` and `registry.has(family)` → planned into that family; otherwise unmapped (`unsupported_platform:<p>` is also treated as unmapped for planning, but the per-row reason string is the one `resolveStagedFamily` returned).

N2 fact: `resolveStep` dispatch is applied today **only inside the native families' `map`** (`native-families.ts` `dispatch` L92-110: token = `row.entity_type ?? family` L102, refuse when it resolves elsewhere L104-106). `clientsFamily.map` (families.ts L77-82) and `genericEntityFamily.map` (L115-120) do not call `resolveStep`. So S8-G's plan-level `resolveStep` is the *only* A3 binding for `clients`/`client_history` (S8-A carry-forward C2) and, for native families, a second pure evaluation of the same function with the same inputs — idempotent, not a conflict. The engine forwards `entity_type: token` on each `StagedRow` so `dispatch` sees the token, not the fallback.

### 3.3 Family-level isolation

Inside `reconstructRun`, each planned family runs in its own `try`: `ConflictException` from `assertWithinBound` (L156-170) or `ProvenanceConflict` (L374-378, also produced by `retryContention` L397-399) is caught, logged PII-free, recorded on `FamilyPassResult.stopped`, and the loop continues with the next family. `RunPassStopped` is **not** caught there — it ends the pass. No new reason code for over-ceiling (READINESS C): the family simply has no ledger rows, so the arbiter's default `partial` holds.

### 3.4 Ledger grouping (recorded decision, C — parent may overrule)

S7-L groups everything by the staged `entity_type` token: `collectFacts` (`lifecycle.service.ts` L374-383, `unmapped_families` L392 = tokens not in `registry`), `projectFamilies` (L552, keyed by staged `entity_type` ∪ ledger keys). Invariant 6 (`staged === reconstructed + skipped + failed`) is therefore evaluated **per token**. S8-G proposes writing the ledger row's `entity_type` as the staged token (`row.entity_type ?? family.entityType`, one-line change at `reconstructRow`'s `writeLedger` calls) so staged and ledger group identically. With every committed spec today (`sources/truecoach.json` steps are the identity map `clients/workouts/client_history`; the two conformance specs are fixtures) token ≡ family, so this is byte-identical to current behaviour and only matters for a future non-identity spec. Alternative (change `collectFacts`/`projectFamilies` to canonical grouping) is not S8-G-owned. E4 answer: grouping is by staged token, and S8-G fills none of the null native buckets (L556-563 stay null).

## 4. Seam 4 — arbiter handoff and CAS

### 4.1 S7-L hook as it is (`lifecycle.service.ts` L313-335)

```ts
async onTransferSettled(coachId: string, intentId: string, epoch: number): Promise<void> {
  const outcome = await this.prisma.$transaction(async (tx) => {
    const locked = await this.lockRun(tx, coachId, intentId);                       // L315 FOR NO KEY UPDATE
    if (!locked || locked.terminal_status !== null || locked.execution_epoch !== epoch) return null; // L316-318 CAS pre-check
    const facts = await this.collectFacts(tx, coachId, intentId);                    // L319 claim, staged_by_family, ledger_by_family, unmapped_families
    const fence = locked.fenced_at !== null && isFenceReason(locked.fence_reason) ? locked.fence_reason : null; // L320-323
    const verdict = arbitrate({ fence, reconciliation: null, ...facts });             // L324
    const written = await this.writeTerminal(tx, coachId, intentId, epoch, verdict);  // L325 CAS UPDATE … terminal_status IS NULL AND execution_epoch = epoch
    return written ? verdict : null;
  });
  if (outcome) this.analytics.capture(coachId, Events.SCOUT_RUN_SETTLED, {...});     // L328-334
}
```

`writeTerminal` (L350-365) is the one terminal write: `terminal_status`, `state`, `reason_code`, `completed_at = COALESCE(completed_at, now())`, CAS on `terminal_status IS NULL AND execution_epoch = ${epoch}`.

### 4.2 S8-G body (the only lifecycle.service.ts hunks: import, one optional constructor parameter, this body)

```ts
constructor(prisma, analytics, @Optional() reconstruct?: ScoutReconstructService) {
  …existing…; this.reconstruct = reconstruct ?? new ScoutReconstructService(prisma, analytics); // S7-L's own @Optional pattern, scout.service.ts L94-96
}

async onTransferSettled(coachId: string, intentId: string, epoch: number): Promise<void> {
  // S8-G: reconstruct first, outside any run lock. Every row transaction gates itself (§3.1).
  const pass = await this.reconstruct.reconstructRun(coachId, intentId, {
    mode: 'server', epoch,
    gate: (tx) => this.assertRunOpen(tx, coachId, intentId),
  });
  if (pass.stopped === 'gate_closed') {
    // Zero-row gate: classify after the writer's rollback (lazy timed_out fence lives here, L443-471). Never a terminal write of our own.
    await this.classifyClosed(coachId, intentId);
  }
  // ── S7-L tail, verbatim (L314-334) ──
  …
}
```

Facts binding this shape:

- The pass must run **outside** the tail's `FOR NO KEY UPDATE` transaction: each row transaction's gate UPDATE needs the same run row; holding the lock across the pass would block every row (self-wait on another connection). Hence "reconstruct, then lock and arbitrate".
- The arbiter payload READINESS seam 4 describes (`{fence, claim, staged_by_family, ledger_by_family, unmapped_families, reconciliation: null}`) is exactly `ArbiterInput` (`arbiter.ts` L27-40) and is already built by `collectFacts` (L368-394) from durable rows **under the lock, after the pass**. S8-G keeps that: the pass result is informational (log/analytics), never the verdict's input. This is stronger than an in-memory payload (a row committed by the pass and a fence that raced it are both seen truthfully).
- CAS: `epoch` is the value `completeServerRun` observed at the claim's gate (`scout.service.ts` L376, returned L391, passed L410). A fence between hook entry and the tail increments `execution_epoch` (L281) → L316 returns null → no write, no event (G14). A fence *after* the tail's lock is impossible (row locked). `completed_at` set once by COALESCE (L361).
- Error contract (E2): `reconstructRun` must not throw on ordinary family failures (§3.3). If it throws unexpectedly (e.g. connection loss), the exception propagates out of `complete` → 5xx to the extension **after** the claim committed (L375-392) and after `notifyComplete` (L405); the run stays open in `reconciling` and is fenced `timed_out` lazily by the next status read/writer (`enforceDeadline` L484-496, `classifyClosed` L443-471). G13 covers this. No retry loop is introduced.
- DI: `ScoutReconstructService` is already a provider of `ScoutModule` (`scout.module.ts` L53) alongside `ScoutLifecycleService` (L50); Nest resolves the new optional parameter with no module change. `ScoutService`'s fallback `new ScoutLifecycleService(prisma, analytics)` (L96) gets a self-constructed reconstruct service, so the DI and non-DI paths behave identically. Import direction: `lifecycle.service.ts → scout-reconstruct.service.ts → reconstruct/orchestration/*`; the engine imports nothing from `lifecycle/**` (the gate arrives as a closure), so no import cycle.

## 5. Legacy byte-identity (G08)

- Coach-JWT `POST /api/scout/reconstruct` (`scout-reconstruct.controller.ts` L81-94) → `reconstruct()` L62-132: unchanged except `ctx = LEGACY_RUN` threading; `assertSettled` L74 keeps the 409 on any run with `terminal_status IS NULL`, including a server run in `reconciling` (G09 first half). After the terminal it runs exactly as today (no gate, converges through the same ledger) — G09 second half; this is the *existing* behaviour, not a 409, and READINESS's "recommend the existing 409" is corrected in FINDINGS C3.
- Legacy `/complete` (`scout.service.ts` L305-355) is untouched by S8-G; `resolve` (L302-303, `lifecycle.service.ts` L140-154) routes non-UUID and foreign UUID strings there before any gate (E6 confirmed).
- Per-row SQL for the legacy route: identical statement list (persist → ledger upsert → ledger updateMany; outcome: upsert → updateMany). The unit draft `reconstruct-run.spec.ts.draft` pins this with the S8-C `FakePrisma` txLog pattern (`engine-handoff.spec.ts` L28-70).

## 6. E1-E6 / N1-N4 against candidate bytes

| Id | Status | Evidence |
|---|---|---|
| E1 | **Confirmed** | `assertRunOpen(tx, coachId, intentId): Promise<number \| null>` `lifecycle.service.ts` L422-432; WHERE L427-429 has no `phase` predicate → admits `reconciling`. The helper does **not** classify or fence; the caller must roll back and call `classifyClosed(coachId, intentId): Promise<ClosedRun>` L443-471, which performs the lazy `timed_out` fence in its own transaction (L450) only when past deadline and not otherwise (L447-449). Legacy coach-JWT route stays fence-free (no call site); server pass fences lazily via the helper. D-S7L-3 wording (decision L88 "reconstruct do not fence") applies to the legacy route. C, recorded. |
| E2 | **Confirmed** | `onTransferSettled(coachId: string, intentId: string, epoch: number): Promise<void>` L313; called at `scout.service.ts` L410 **after** the claim `$transaction` (L375-392) committed and after `notifyComplete`/analytics (L405-409); awaited inline, response after the pass. Fires once: duplicate `/complete` on an open run hits the completion unique → P2002 → ack, no hook (L399-401); closed gate → ack or 409, no hook (L394-398). Errors: thrown → propagate to the HTTP response; run left open for lazy timeout. Inline-vs-detached remains the parent's C decision; inline is what the bytes do. |
| E3 | **Confirmed** | `arbitrate(input: ArbiterInput): ArbiterVerdict` `arbiter.ts` L71-88; `ArbiterInput` L27-40: `staged_by_family: Record<string, number>`, `ledger_by_family: Record<string, LedgerTally>` (`{reconstructed, skipped, failed}` L12-16), `unmapped_families: readonly string[]`, `claim: ScoutTerminalStatus \| null`, `reconciliation: ReconciliationVerdict \| null`. Grouping key = staged `entity_type` token (`collectFacts` L374-392). CAS terminal writer = `private writeTerminal(tx, coachId, intentId, epoch, verdict)` L350-365, reached only through `onTransferSettled`/`fence`; S8-G calls neither directly — it keeps the hook tail. |
| E4 | **Confirmed (by token)** | `projectFamilies` L548-565 keys by staged `entity_type` ∪ ledger `entity_type`; `staged_unique` L558 = staged row count per token; native buckets null L556-562. Arbiter and status use the same (token) grouping; §3.4 keeps S8-G's ledger writes on that key. |
| E5 | **Confirmed** | `RUN_REASON_CODES` `reason-codes.ts` L46-54 already contains `unresolved_family` (L51); S8-G adds no code; per-row unmapped reason is S8-A's `unresolved_family:<token>` string in the ledger `reason` column, not a run reason code. |
| E6 | **Confirmed** | `resolve(coachId, intentId): Promise<IntentResolution>` L140-154 (`{mode:'legacy'} \| {mode:'server', intent}`); UUID syntax first (L141), then owned intent + not-already-legacy row (L152). S8-G needs no routing helper of its own: the hook is only reached from the server branch (`scout.service.ts` L303). |
| N1 | **Confirmed** | `PersistResult = string \| null \| PersistOutcome` (`persist-outcome.ts` L34); `PersistOutcome` L23-31 `{ok:true, targetId, targetKind, unresolvedChildren} \| {ok:false, reason}`; engine writes the ledger in the same `tx` (`scout-reconstruct.service.ts` L216-260). No nested transaction: 0 `$transaction` in `reconstruct/native/*.ts`. `writeOutcome` remains a separate transaction for map-level skip/fail (L285-289) — gate-first applies there too (§2.1). |
| N2 | **Confirmed** | `RECONSTRUCT_FAMILY` = `{clients, workouts, client_history, programs}` dto L13-18; registry L174-179 registers `clientsFamily`, `native.workouts`, generic `client_history`, `native.programs`. `resolveStep` dispatch lives in `native-families.ts` `dispatch` L92-110 (native families only); legacy families do not resolve. S8-G resolves once at plan level and forwards the token (§3.2). |
| N3 | **Confirmed (null); fill stays OUT of S8-G** | `native-provenance.ts` L16-17: `import_intent_id` stays NULL; `persist` has no context parameter (`families.ts` L52). Every provenance INSERT/UPDATE is in `native-provenance.ts` (`recordCreated` L53-70, `promoteToCreated` L72-92, `recordUnresolved` L95-113) called from `native-writers.ts` (L119-121, L408-413 and the template/child paths) — none is an S8-G-owned path. `PersistOutcome` (`persist-outcome.ts` L23-31) returns `ok:true` for both `created` and `already_present` (`verifyTarget` L83-88 vs `persistProgram` L122), so an engine-level post-persist `UPDATE … SET import_intent_id` in the owned per-row transaction could not distinguish a row this run created from one an earlier intent created, and would stamp the earlier intent's rows with the current run (the S9 F2 overstatement in the other direction). A truthful fill needs a run context on `persist` (or a `created` flag / provenance ids on `PersistOutcome`) — S8-C-owned bytes, excluded by READINESS ("S8-G will not extend `persist`'s signature itself"). Also: `import_intent_id` is an FK to `ImportIntent(id, coach_id)` with `onDelete: Restrict` (`schema.prisma` L6978-6979), so filling it changes intent-deletion semantics (L8-class retention decision, owner-reserved). S8-G's `RunContext` is designed so a later N3-fill slice is additive (add `intentUuid` to the server context; the engine already holds the per-row `tx`). See FINDINGS C5. Consequence for G13 today: a new intent's pass converges `already_present` through the intent-free provenance key (`native-writers.ts` L99-101, L246, L374). |
| N4 | **Confirmed with nuance** | Client-linked workouts: `persistEvidence` with `recordNoNativePrincipal: true` (`native-families.ts` L152-159, L182-189) → `ScoutReconstructedEntity` upsert (`native-writers.ts` L387-406), provenance `unresolved` `no_native_client_principal` (L408-413), returns `ok(record.id, LEDGER_TARGET_KIND.scout_entity)` L415 → ledger `status = reconstructed`, `target_kind = scout_entity`. `LedgerTally` has no evidence bucket, so `ledger_by_family.workouts.reconstructed` counts them; the truthful "evidence, not native" distinction is `target_kind` (and the null native buckets, S9). S8-G adds no bucket; TESTS G01 asserts the kind. |

## 7. Statement contract the proof pins (G02)

Server pass, per staged row (success path): `-- tx:begin` · `UPDATE "ScoutImport" SET last_observed_at … RETURNING execution_epoch` · persist statements (native/evidence + provenance) · ledger upsert · ledger updateMany · `-- tx:commit`. Skip/fail path: `-- tx:begin` · gate UPDATE · ledger upsert · ledger updateMany · `-- tx:commit`. Closed gate: `-- tx:begin` · gate UPDATE · `-- tx:rollback`, then (only if past deadline) a **new** transaction whose first lock statement is `FOR NO KEY UPDATE` (S7-L L10 pattern, `rls-g2-s7l.spec.ts` L850-858). Tail: one transaction: `FOR NO KEY UPDATE` · three groupBy/findUnique reads · terminal UPDATE (or no UPDATE on CAS miss). Legacy route: no statement containing `last_observed_at` and no `FOR NO KEY UPDATE` anywhere.

## 8. Not in S8-G (unchanged)

Schema/migrations; `lifecycle/**` beyond the hunks in PATHS.md; `reconstruct/native/**`; `families.ts`; `mapping-spec.ts`; readers (S8-F); generator/contract; `events.ts`; flags; `scout.module.ts` (no change needed, §4.2).
