# S10-C builder summary — settle-basis record, coverage wiring, module registration

Worktree `/home/user/workspace/worktrees/d3a9-s10c`, branch `exec-d3a9/s10c`, HEAD **`a2c74e90`** (S10-B
committed; the untracked S10-B layer is gone). No commit, no push, no heavy runs, lock untouched. State after
round 1 (devloop-1 + review A + review B delta): edits were made ON TOP of the devloop-1 prettier bytes.
Diff of the round-1 fixes: `/home/user/workspace/s10c_fix1.diff` (sha256
`3af3c9e9aacee797ba3f8a00224c2790b2a888e9b74bd0057156f9643e6a3279`; header explains the two bases).

## Files (sha256) — 9 S10-C paths (L356) + 2 paths taken under grant

| Path | State | sha256 |
|---|---|---|
| `src/scout/reconciliation/facts.service.ts` | modified | `756cb44bf5282341d53556d6df49c8820ae6762f51a9826af704cffefd667ba7` |
| `src/scout/reconciliation/types.ts` | modified (one line + doc) | `d7815e0679a1de74ea641cecaa53135d00d76e55a278360dca3dd78b1b0c960f` |
| `src/scout/lifecycle/lifecycle.service.ts` | modified (round 1: `reportToJson`, no-basis recompute without binding) | `55c8f24aa7c9d377631541548dcecc2682b9089f05111570aa91c7c7de1bc49c` |
| `src/scout/scout.module.ts` | modified (one import) | `682bc3af86f5ba7e981f80f6111090f8e86dab1b092fde3b7666ec00d1492a3f` |
| `src/scout/induction/observation.module.ts` | **now S10-C owned (review B A1)**: module-local `PrismaService` provider + import removed, comment updated | `2998b71d387e4c53e1f0a694e2b18a2e91116513d98021ef13c057ce80e4934f` |
| `test/scout/reconciliation/facts.service.spec.ts` | modified (S9-B FakeDb +2 tables, +1 case) | `681e00364549705dd2a6222dce6ec960854fe3b6beee738d27c593258ddf0adf` |
| `test/scout/reconciliation/facts.service.coverage.spec.ts` | NEW (651 lines) | `681c90315a8d2e7321010da2ec1d9042c1584c38b0068be70d18c75ada8e2958` |
| `test/scout/lifecycle/lifecycle.service.spec.ts` | modified (+3 describes, doubles, review A-1 test) | `4b3ae75e08a195bc0c492742eebfe81b03265deed786364a62c638e66dd4b377` |
| `test/scout/induction/s10c-wiring.spec.ts` | NEW (85 lines) | `63f3d3de9fbb3f0e7e522684375ecc14809261c10de99073b31e182ab986ed3a` |
| `test/rls-g2-s10c.spec.ts` | NEW (327 lines; imports the S10-B harness by parameter, forks nothing) | `5eeb0fe6a760a07a06beffdb748c16b132d630b45f9e9eacca6032efbcb735f5` |
| `test/rls-g2-s9c.spec.ts` | modified under the review A-3 grant (3 assertions superseded by D-S10-4; see below) | `078fcb1a4226fa2703c66db7cac27046f1c826108a0592f107adad4bc47b9434` |

`git diff --stat -- src test` (tracked): 8 files, +857 / −66, plus 3 untracked specs. `rg -F s10_unseen src` → empty.
No line I added exceeds 100 chars except `it(`/`describe(` titles (repo convention); the one 101-char line in the
coverage spec is a single-specifier import as prettier left it.

## Round 1 — what was fixed and why (devloop-1 + review A + review B)

| Item | Class | Fix |
|---|---|---|
| (1) TSC `lifecycle.service.spec.ts` spread into `{known:false}` arm | B | test narrows `provenWorkouts.known` before spreading |
| (2) ESLINT unused `ledger` in `rls-g2-s10c.spec.ts` | C | that helper is gone in the B-1 rewrite (report-key projection instead of "everything but ledger") |
| (3) R75 `settled as unknown as Prisma.InputJsonValue` | B | `static reportToJson(report): Prisma.InputJsonValue` — `JSON.parse(JSON.stringify(report))` typed once, no double cast; asserted in the lifecycle spec |
| (4) JEST "without a registry option → unknown" got known | **test premise bug, not product** | `service(undefined)` hit the default parameter → fixture `REGISTRY`. Fixed with a `'default'` sentinel; the test now also asserts `existsSync(INDUCTION_MANIFESTS_DIR)` is false at this head (`src/scout/induction/sources` absent). Product path was correct. |
| Review A-1 no-basis fallback | product | `readReport`: no settled row / malformed row → S9-C recompute `this.facts.collect(tx, coach, intent)` with **no binding** (coverage null, `basis:'recomputed'`); `ReportScopeRow` back to the S9-C 3-field Pick; `reportApplies` boolean. Tests at lifecycle tier ("review A-1 fence-path terminal": `collect.mock.calls[0].length === 3`) and collector tier (coverage spec "review A-1 no-basis recompute") |
| Review A-2 live `complete` | proof | R33 live relabelled STRUCTURAL half; verdict half is unit (see open question 1 — now with a real-composition unit proof per B-2) |
| Review A-3 superseded S9-C assertions | proof | edited under grant, list below |
| Review B A1 ObservationModule | product | module-local `PrismaService` removed from `providers` (+ import); uses the @Global `PrismaModule`. Wiring spec: `Reflect.getMetadata(PROVIDERS, ObservationModule)` does not contain `PrismaService`, does contain `ObservationService`, and the module source does not match `/prisma\.service/` |
| Review B B1 R35 live drift | proof | between the two status reads the spec **stages a third `clients` row**; asserts live `staged_unique` 2→3 while report-derived `rejected` stays 2 (a recompute would say 3), `reasons` count `[2]`; all 9 report-derived keys byte-equal across reads and equal to `settledRow().report`'s token holder; exactly one `"ScoutRunSettledBasis"` SELECT, `queries.filter(q => q === '-- tx:begin')` empty, no `isS9Read` (S9-B provenance signature), no write |
| Review B B2 native-clean fixture | proof | `cleanRun()`: one `plans p1` reconstructed into an owned live `workoutProgram` with matching ledger (`reconstructed`, `workout_program`) + provenance (`created`), no client link; `clients`/`workouts` staged empty with verified empty-set statements. "R33 (real composition)" asserts `verdict` **`toEqual({outcome:'complete', reason_code:null})`**, `conditions []`, programs `native_present_verified 1`, empty families `observed_unique 0` with basis. "R23 terminal half (exact)": same run, programs statement enumerates `['p1','p9']` → `toEqual({outcome:'partial', reason_code:'coverage_basis_unknown'})`, `conditions ['coverage_basis_unknown']`. The old BASELINE fixture is kept and now states it is NOT native-clean (`unresolved_identities`) |
| Review B B3 no write before CAS | proof | R33 live: last `FOR NO KEY UPDATE` before the CAS = tail lock; `q.slice(lock, cas).filter(isWrite)` is `[]`, no tx marker inside, no write between CAS and INSERT, none between INSERT and `-- tx:commit` |
| Review B C2 | proof | `basis.report.families.length > 0` before the per-family loop; weak `casWrites >= 1` dropped (carried by `count(SETTLED) === 1`) |
| Review B C3 | wording | an **unregistered platform yields an entry with `grouped_families: []` and empty `families`** (not "no entry") — corrected below |
| Review B B4 | parent's | not mine; untouched |

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
| 1. `complete` only from a known covering basis + success claim + clean natives | coverage spec "R33 (real composition)": native-clean `cleanRun()` → collector → evaluator → `familyCoverage` → `reconcile` → **exactly `{complete, null}`**; "R23 terminal half (exact)" non-covering twin → **exactly `{partial, coverage_basis_unknown}`**; "R33 unit half BASELINE" (evaluator → known/covering, but `unresolved_identities` because not native-clean); lifecycle "invariant 1" (settle writes `complete`/`null`, basis conditions `[]`; `covers:false` → `partial/coverage_basis_unknown`) | R33 STRUCTURAL only (terminal ∈ S9 set, never `complete` with no manifest on disk) — verdict half not live-proven, open question 1 |
| 2. Unknown never becomes zero | coverage spec "unknown never zero" (`observed_unique` null, basis `'none'`), "R26 empty statement → KNOWN(0)"; lifecycle finding-7 "observed 0 verified → 0" vs null cases; wiring none | R33: every family `completeness_basis:'none'`, `observed_unique:null`; R35 status `observed_unique` null |
| 3. Insert-only record, one per run, epoch-bound digests | lifecycle "R33 structural half" (data shape, `observationFindMany` where = coach/intent/epoch, order CAS < insert, one tx); "R36 insert failure" | R33 (`observation_digests` == stored digests at the terminal epoch; INSERT after the terminal UPDATE with no tx marker between, next marker `-- tx:commit`; one INSERT), "second claim → 409, still 1 row", "two concurrent claims → 1 row" |
| 4. Status prefers the settled record, byte-identical, S9 recompute otherwise | lifecycle "status read" describe (verbatim return, coach-scoped `findUnique`, no tx/collect; R35 drift test; no row → recompute with binding; malformed stored → recompute; R37 no-report → no basis read); `isSettledReport` shape test | R35 (B-1): a third staged row lands between the reads; live `staged_unique` 2→3, report-derived `rejected` stays 2 and all report keys equal the stored basis row; one basis SELECT, zero `-- tx:begin`, no S9 read, no write; R37 other coach → 404 and no basis read |
| 5. No customer side effect | `s10c-wiring.spec.ts`: settle path files + `src/scout/induction/*` import nothing matching notification/drip/email/mail/messag/sms/push; ObservationModule imports `[]` and declares no `PrismaService` provider (A1) | `noSideEffects` on complete and status workers (`pushes === 0`, all `sideEffectLoads` 0) |
| 6. Reads only in the collector; the arbiter's UPDATE is the only run-row write | coverage spec "invariant 5/6" (findMany/findUnique only, 1 declaration + 1 observation read, no `scoutImport` read); lifecycle "R33" (`executeRaw` once) | R33 (`isTerminalCas` exactly once; lock→CAS window has no INSERT/UPDATE/DELETE and no tx marker (B-3); nothing but the basis INSERT after it before commit) |
| R30 old epoch ignored | coverage spec "old epoch excluded" (where asserts epoch), "current epoch used despite old rows", "settle epoch binds" (epoch+1 → unknown) | (not live — needs an epoch bump without a fence; unit-only, stated) |
| Coach-scoped reads | coverage spec "coach-scoped reads" (every S10 where has `coach_id`); lifecycle basis `findUnique` where | R35 "other coach → 404, no basis read" |
| Flag-off → 404 | S10-B controller behaviour; `test/scout/induction/observation.controller.spec.ts` (S10-B, untracked base) covers it. S10-C adds none (registration only) | S10-B live spec L316/L327 |
| D-S10-8 no source-name literal in src | `s10c-wiring.spec.ts` walks `src/**/*.ts` for the fixture slug read from the mapping spec; coverage spec checks the four touched files | — |
| R27 production grouping | coverage spec `stagedPlatformFacts` describe (spec-key partition, empty digest, unmapped/unregistered → entry with `grouped_families: []` and empty `families`, lone surrogate) | — |

## S9-C live assertions superseded by D-S10-4 (edited in `test/rls-g2-s9c.spec.ts` under the review A-3 grant)

| S9-C line (pre-edit) | Assertion | Why superseded | Replacement |
|---|---|---|---|
| L289 | `expect(terminalAt).toBe(tail.length - 1)` — terminal UPDATE is the last statement of the tail | D-S10-4 puts the observation SELECT + `ScoutRunSettledBasis` INSERT after the CAS in the same tx | no `"ScoutImport"` statement after the terminal; exactly one write after it and it is the basis INSERT |
| L297 | `basis: 'recomputed'` on the post-complete report | the report/status now return the settled record | `basis: 'settled'` |
| L444-448 | status after `complete` opens one `-- tx:begin` and issues an S9 read | status prefers the settled record: point read, no transaction, no recompute | zero `-- tx:begin`, zero `isS9Read`, a `"ScoutRunSettledBasis"` query present |

Unchanged: L431 (fence-path RC-2 `basis: 'recomputed'`) — the fence path has no basis row, so the S9-C recompute
still runs (review A-1); `test/rls-g2-s9.spec.ts` (S9-B collector SELECT counts 3/7 — the binding is a
parameter, the collector adds no run-row read). `test/rls-g2-s10b.spec.ts` L403-415 runs the real
`complete`; the basis insert must succeed there (needs `prisma generate`).

## Open questions / limits

1. **Live R33 `complete` verdict half — owner decision.** The S10-B worker (`test/utils/g2-s10b-worker.cjs`,
   frozen) builds `new ScoutLifecycleService(prisma, analytics)` → default `ReconciliationFactsService()` →
   on-disk induction manifests (none at this head) → every basis unknown, and the harness platform
   `synthetic-src-a` has no production mapper (every staged row `rejected`). A live `complete` needs (a) a
   worker seam (`input.manifestsDir` → `new ReconciliationFactsService({ registry })`) and (b) a
   signed-evidence fixture for a production-mapped platform plus a native-clean staged set in PG. Per the
   throughput rule I did not fork a harness or touch the frozen worker. The verdict half is proven at unit
   tier by REAL composition (B-2: collector + evaluator + `familyCoverage` + `reconcile` on a native-clean
   FakeDb, exact `{complete,null}` / `{partial,coverage_basis_unknown}`); the live spec header says so.
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
  src/scout/scout.module.ts src/scout/induction/observation.module.ts \
  test/scout/reconciliation/facts.service.coverage.spec.ts test/scout/induction/s10c-wiring.spec.ts \
  test/rls-g2-s10c.spec.ts test/scout/lifecycle/lifecycle.service.spec.ts test/rls-g2-s9c.spec.ts
# live (same guards as S10-B): G2_S10B_* env + G2_S10B_CANDIDATE_HEAD, clean tree
npx jest --config jest.rls.config.js test/rls-g2-s10b.spec.ts test/rls-g2-s10c.spec.ts --runInBand --ci   # 24 + 8 = 32
npx jest --config jest.rls.config.js test/rls-g2-s9c.spec.ts test/rls-g2-s9.spec.ts --runInBand --ci
npm run contract:importer
```

## Production LOC (parent rule "large change scrutiny", mail 10:10 PM)

`git diff -U0` added lines vs `92b96715`, hand-written production only (src + prisma):

| File | added | removed | added non-comment |
|---|---|---|---|
| `src/scout/reconciliation/facts.service.ts` | 231 | 18 | 159 |
| `src/scout/lifecycle/lifecycle.service.ts` | 155 | 28 | 99 |
| `src/scout/reconciliation/types.ts` | 6 | 1 | 1 |
| `src/scout/scout.module.ts` | 8 | 1 | 2 |
| `src/scout/induction/observation.module.ts` | 7 (comment) | 8 | 0 |
| `prisma/schema.prisma` | 57 (S10-B's models, not S10-C's; unchanged by me) | 0 | — |
| **S10-C total** | **407** (261 non-comment) | 56 | |

S10-C is 407 hand-written prod LOC (261 non-comment) — under the 1,000 threshold, so the scrutiny question does not
apply. For the record, in one sentence: PROCEED — the facts/coverage half is behaviour-preserving on its
own but only the lifecycle half uses it, so splitting adds a review round without shrinking the
terminal-truth blast radius, which is entirely the +162-LOC lifecycle/types/module diff either way.
