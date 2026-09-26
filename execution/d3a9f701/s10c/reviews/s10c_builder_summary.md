# S10-C builder summary — settle-basis record, coverage wiring, module registration

Worktree `/home/user/workspace/worktrees/d3a9-s10c`, branch `exec-d3a9/s10c`, base HEAD `92b96715` (unchanged;
no commit, no push, no heavy runs, lock untouched). S10-B's 16 untracked base files and the S10-B
`prisma/schema.prisma` diff are untouched (`git diff prisma/schema.prisma` adds only the three S10-B models).

## Files (sha256)

| Path | State | sha256 |
|---|---|---|
| `src/scout/reconciliation/facts.service.ts` | modified | `756cb44bf5282341d53556d6df49c8820ae6762f51a9826af704cffefd667ba7` |
| `src/scout/reconciliation/types.ts` | modified (one line + doc) | `d7815e0679a1de74ea641cecaa53135d00d76e55a278360dca3dd78b1b0c960f` |
| `src/scout/lifecycle/lifecycle.service.ts` | modified | `3deb1fb14d031ea337a99d1335ff9a33ed199375ba68c070df221aff858fafcf` |
| `src/scout/scout.module.ts` | modified (one import) | `682bc3af86f5ba7e981f80f6111090f8e86dab1b092fde3b7666ec00d1492a3f` |
| `test/scout/reconciliation/facts.service.spec.ts` | modified (S9-B FakeDb +2 tables, +1 case) | `681e00364549705dd2a6222dce6ec960854fe3b6beee738d27c593258ddf0adf` |
| `test/scout/reconciliation/facts.service.coverage.spec.ts` | NEW (530 lines) | `671a1b2289cc811b601712a7b07ca7aae2a625cababfb6e9823e6a4eaea4cb27` |
| `test/scout/lifecycle/lifecycle.service.spec.ts` | modified (+3 describes, doubles, 1 assertion widened) | `8dcd2c739b522502af6ad8acf306360d7e1ada14142645b86a6826a42c7673a1` |
| `test/scout/induction/s10c-wiring.spec.ts` | NEW (73 lines) | `9520014683a4e3d76e2283f659848aeab272640734301ce51e23cc8078f1a92c` |
| `test/rls-g2-s10c.spec.ts` | NEW (277 lines; imports the S10-B harness, forks nothing) | `96c26d2f1e683b0985d2044ada11eba5a83dbf83cc28840d24c527eded0e8a07` |

`git diff --stat -- src test`: 6 files, +796 / −53. `rg -F s10_unseen src` → empty. No line I added exceeds
100 chars except `it(`/`describe(` titles (repo convention).

## What each owned path does (D-S10-7 row S10-C)

**facts.service.ts**
- `export function resolveFamily(sourceMappers, platform, token)` — module-level, the ONE `(platform, token) →
  canonical family` classifier; the class's grouping now calls it (old private method removed).
- `export function stagedPlatformFacts(sourceMappers, rows)` — R27 production half: per staged platform,
  `grouped_families` = sorted spec family keys of that platform (so the evaluator's partition-agreement
  check compares against the spec, not against "families that happened to have rows"); every declared
  family is digested (zero rows → the empty-set digest via S10-A `stagedFamilyDigests`); unmapped tokens
  and unregistered platforms are skipped (an unregistered platform yields no staged entry → evaluator R26).
- `collect(db, coach, intent, run: RunBinding | null = null)` — **the run binding is a parameter**, not a
  read. Reason: the landed S9-B live spec (`test/rls-g2-s9.spec.ts` L695-717) pins the collector's SELECT
  count and table list (3 empty / 7 fixture); an in-collector `ScoutImport` read would have broken it. The
  settle tail passes the locked row's `{mode:'server', execution_epoch, accepted_start_at}`, the status
  recompute passes the run row. Without a binding, or with a non-`server` / not-accepted one, `coverage`
  is `null` (unknown) and no S10 table is read — exactly the S9 v1 facts.
- Step 7 `evaluateRunCoverage` → reads `ScoutRunDeclaration` (coach+intent; challenge poisoned to an empty
  buffer if rows disagree) and `ScoutRunObservation` (coach+intent+**epoch**; evidence only) and calls the
  S10-A `evaluateCoverage` with the registry and `stagedPlatformFacts`. Options gain `registry?`; default
  = `buildInductionRegistry` over on-disk manifests filtered to this service's mapper partition (fail-loud
  like the other registries, but a unit spec with synthetic mappers cannot trip on a foreign manifest).

**types.ts** — `basis: 'recomputed' | 'settled'` (+ doc). Only change.

**lifecycle.service.ts**
- Lock SELECT adds `accepted_start_at` (same statement count). `reconcileRun(tx, c, i, run)` passes the
  binding; returns `{verdict, report}`.
- After `writeTerminal` returns true (CAS hit): `writeSettledBasis(tx, …)` — `scoutRunObservation.findMany`
  (coach, intent, epoch; `evidence_digest` only, sorted) then `scoutRunSettledBasis.create({coach_id,
  intent_id, execution_epoch, report_version: 1, report: {...report, basis:'settled'}, observation_digests,
  settled_at})`. Same transaction, after the CAS; a CAS miss returns before it; a fenced-but-open row
  still writes its terminal (landed S9-C behaviour) and therefore also records its basis; `fence()` writes
  none; an insert error propagates (transaction rolls back the terminal with it; only P2034 is retried).
- `readReport`: `reportApplies` (now a type guard) → `readSettledBasis` (`findUnique coach_id_intent_id`,
  returned verbatim iff `report_version === 1 && isSettledReport(report)`) → else the unchanged S9-C
  REPEATABLE READ recompute (now with the run binding). `ReportScopeRow` widened to include
  `execution_epoch` and `accepted_start_at` (both callers already pass a full `RunRow`).
- Finding 7: `TokenFill` (exported type); `projectToken` spreads `observed_unique` only when
  `observedUniqueFor(token, report, holders)` is non-null: settled basis, exactly one holder, mapped, the
  holder's single token equals the projected token, numeric value (0 allowed: a verified empty enumeration
  is a fact). Otherwise the S7-L `null`/S9-C shape is untouched.

**scout.module.ts** — `imports: [NotificationsModule, ReconciliationModule, ObservationModule]` + comment.

## R23 resolution (terminal half) — stated exactly

`RUN_REASON_CODES` (`src/scout/lifecycle/reason-codes.ts` L50-60) **already contains
`coverage_basis_unknown`** at this head (it landed with S9-C's D-S9-7 widening), and it is in `S9_REASON_CODES`.
So the parent's premise that the enum lacks it is false here; nothing is added (D-S10-8). Path: evaluator
`known:true, covers_staged_identities:false` (or `known:false`, or `coverage: null`) → S9 `familyCoverage`
returns `known:false` (basis `'none'`, the count still shown when known) → C-COV holds → reconciler
`partial / coverage_basis_unknown` → arbiter writes it. Tested: coverage spec "R23 terminal half",
lifecycle spec "R34 / D-S10-8" and "invariant 1" (the `covers:false` twin), live R33 (`RUN_REASON_CODES`
∋ `reason_code`).

## D-S10-6 invariants → tests

| Invariant | Unit | Live (PG, S10-B harness by parameter) |
|---|---|---|
| 1. `complete` only from a known covering basis + success claim + clean natives | coverage spec "R33 unit half BASELINE" (evaluator → `source_signed_enumeration`, observed 2/1/3); lifecycle "invariant 1" (`complete`, reason `null`, basis row conditions `[]`; `covers:false` → `partial/coverage_basis_unknown`) | R33 structural: terminal ∈ S9 set, never `complete` with no manifest on disk (see open question 1) |
| 2. Unknown never becomes zero | coverage spec "unknown never zero" (`observed_unique` null, basis `'none'`), "R26 empty statement → KNOWN(0)"; lifecycle finding-7 "observed 0 verified → 0" vs null cases; wiring none | R33: every family `completeness_basis:'none'`, `observed_unique:null`; R35 status `observed_unique` null |
| 3. Insert-only record, one per run, epoch-bound digests | lifecycle "R33 structural half" (data shape, `observationFindMany` where = coach/intent/epoch, order CAS < insert, one tx); "R36 insert failure" | R33 (`observation_digests` == stored digests at the terminal epoch; INSERT after the terminal UPDATE with no tx marker between, next marker `-- tx:commit`; one INSERT), "second claim → 409, still 1 row", "two concurrent claims → 1 row" |
| 4. Status prefers the settled record, byte-identical, S9 recompute otherwise | lifecycle "status read" describe (verbatim return, coach-scoped `findUnique`, no tx/collect; R35 drift test; no row → recompute with binding; malformed stored → recompute; R37 no-report → no basis read); `isSettledReport` shape test | R35/R37: two status reads identical, basis SELECT present, no REPEATABLE READ, no writes; other coach → 404 and no basis read |
| 5. No customer side effect | `s10c-wiring.spec.ts`: settle path files + `src/scout/induction/*` import nothing matching notification/drip/email/mail/messag/sms/push; ObservationModule imports `[]` | `noSideEffects` on complete and status workers (`pushes === 0`, all `sideEffectLoads` 0) |
| 6. Reads only in the collector; the arbiter's UPDATE is the only run-row write | coverage spec "invariant 5/6" (findMany/findUnique only, 1 declaration + 1 observation read, no `scoutImport` read); lifecycle "R33" (`executeRaw` once) | R33 (`isTerminalCas` exactly once; no `ScoutImport` UPDATE after it) |
| R30 old epoch ignored | coverage spec "old epoch excluded" (where asserts epoch), "current epoch used despite old rows", "settle epoch binds" (epoch+1 → unknown) | (not live — needs an epoch bump without a fence; unit-only, stated) |
| Coach-scoped reads | coverage spec "coach-scoped reads" (every S10 where has `coach_id`); lifecycle basis `findUnique` where | R35 "other coach → 404, no basis read" |
| Flag-off → 404 | S10-B controller behaviour; `test/scout/induction/observation.controller.spec.ts` (S10-B, untracked base) covers it. S10-C adds none (registration only) | S10-B live spec L316/L327 |
| D-S10-8 no source-name literal in src | `s10c-wiring.spec.ts` walks `src/**/*.ts` for the fixture slug read from the mapping spec; coverage spec checks the four touched files | — |
| R27 production grouping | coverage spec `stagedPlatformFacts` describe (spec-key partition, empty digest, unmapped/unregistered skipped, lone surrogate) | — |

## Landed specs this change is EXPECTED to break (parent decision; not my owned paths, not edited)

1. `test/rls-g2-s9c.spec.ts` L289 `expect(terminalAt).toBe(tail.length - 1)` — D-S10-4 puts the basis
   SELECT + INSERT after the terminal UPDATE in the same tail. Suggested relaxation: terminal UPDATE is the
   last **ScoutImport** write and the only statements after it are the observation SELECT and the
   `ScoutRunSettledBasis` INSERT.
2. `test/rls-g2-s9c.spec.ts` L444-448 — status after `complete` asserted one `-- tx:begin` and an S9 read;
   under D-S10-4 the status read returns the settled record with no transaction. The families[] byte
   equality with `report` still holds (the `report` action also returns the settled record).
3. `test/scout/lifecycle/lifecycle.service.spec.ts` L674 — I widened the S9-C `collect` args assertion to
   include the binding (in an owned test path; noted for transparency).
4. `test/rls-g2-s9.spec.ts` — NOT affected (the collector issues no run-row read; count stays 3/7).
5. `test/rls-g2-s10b.spec.ts` L403-415 runs the real `complete`; the basis insert must succeed there
   (needs `prisma generate` so `scoutRunSettledBasis` exists on the client).

## Open questions / limits

1. **Live R33 `complete` verdict half.** The S10-B worker (`test/utils/g2-s10b-worker.cjs`, frozen) builds
   `new ScoutLifecycleService(prisma, analytics)` → default `ReconciliationFactsService()` → on-disk
   induction manifests (none at this head) → every basis unknown. The live spec therefore proves the
   structural half (one terminal + one basis row, same tx, after CAS, digests, S9 code) and the
   `complete → complete` half is unit-only. Options: (a) add an `S10_INDUCTION_MANIFESTS_DIR`-style seam
   the worker can pass (touches the frozen worker / manifest-registry), or (b) accept unit-tier proof.
   Per the throughput rule I did not fork a harness.
2. `RunBinding` parameter vs. in-collector read: I chose the parameter to keep the S9-B live spec pinned
   and the collector read-bounded. If the parent prefers the collector to self-bind, it is a 12-line
   revert plus the S9-B spec count update.
3. Contract regen: `scout.dto.ts` gains no field (`basis` is not in the status DTO; `observed_unique` is
   an existing S7-L key). No generated JSON expected to change — please confirm with
   `npm run contract:importer`.
4. `prettier` not run (rule); long `it()` titles follow the repo's existing pattern.

## Heavy commands for the parent (under the canonical lock)

```
npx prisma generate
npx tsc --noEmit -p tsconfig.json
npx jest test/scout/reconciliation test/scout/lifecycle test/scout/induction test/module-graph.spec.ts
npx eslint src/scout/reconciliation/facts.service.ts src/scout/lifecycle/lifecycle.service.ts \
  src/scout/scout.module.ts test/scout/reconciliation/facts.service.coverage.spec.ts \
  test/scout/induction/s10c-wiring.spec.ts test/rls-g2-s10c.spec.ts test/scout/lifecycle/lifecycle.service.spec.ts
# live (same guards as S10-B): G2_S10B_* env + G2_S10B_CANDIDATE_HEAD, clean tree
npx jest test/rls-g2-s10b.spec.ts test/rls-g2-s10c.spec.ts test/rls-g2-s9c.spec.ts test/rls-g2-s9.spec.ts
npm run contract:importer
```

## Production LOC (parent rule "large change scrutiny", mail 10:10 PM)

`git diff -U0` added lines vs `92b96715`, hand-written production only (src + prisma):

| File | added | removed | added non-comment |
|---|---|---|---|
| `src/scout/reconciliation/facts.service.ts` | 231 | 18 | 159 |
| `src/scout/lifecycle/lifecycle.service.ts` | 154 | 31 | 106 |
| `src/scout/reconciliation/types.ts` | 6 | 1 | 1 |
| `src/scout/scout.module.ts` | 8 | 1 | 2 |
| `prisma/schema.prisma` | 57 (S10-B's models, not S10-C's; unchanged by me) | 0 | — |
| **S10-C total** | **399** (268 non-comment) | 51 | |

S10-C is 399 hand-written prod LOC — under the 1,000 threshold, so the scrutiny question does not
apply. For the record, in one sentence: PROCEED — the facts/coverage half is behaviour-preserving on its
own but only the lifecycle half uses it, so splitting adds a review round without shrinking the
terminal-truth blast radius, which is entirely the +162-LOC lifecycle/types/module diff either way.
