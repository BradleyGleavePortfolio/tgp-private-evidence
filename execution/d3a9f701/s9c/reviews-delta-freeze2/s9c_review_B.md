# S9-C review B — independent T4 review of the S9-C draft (TGP importer)

Reviewer: T4-B (read-only). Candidate: `/home/user/workspace/worktrees/d3a9-s9c`, HEAD `5407efae` (S9-B landing merge), uncommitted draft.
Contract: `docs/decisions/2026-09-25-s9-reconciliation.md` (the doc below; line numbers refer to it at this head).

## 0. Integrity (verified)

- `git diff 5407efae | sha256sum` = `925220a2266208d1b2bb09d6dfb4661506bcff79789f0e7a2a3fa0662031acdf`. This equals the frozen `freeze-1/s9c-draft.patch`, so the reviewed bytes are the frozen bytes. The diff covers 19 paths, +3465/−31.
- Commands I ran: `git diff/show/log/status`, `sha256sum`, `rg`, `sed`, `diff`. I ran no npm, jest, tsc, postgres or lock command. I made no edits. One accidental `git add -N .` ran early in the review. It was a no-op: the index and `git status` were identical before and after it, and every new file was already intent-to-add (` A`).
- Dev-loop-3 (`private-evidence/.../devloop-3/`): PRETTIER 0, ESLINT 0, TSC 0, CONTRACT_GEN rc 0 and stable (`openapi.before` == regenerated output), JEST 14/14 suites and 551/551 tests. `devloop.sh` lists those 14 paths. **The live proof `test/rls-g2-s9c.spec.ts` is not among them and has never run.** It needs a committed head and the lane.

## Verdict: **NO-GO** as frozen

One B defect makes the live PG proof fail as written (B-1). Committing these bytes and spending the single-run S9-C lane grant on them would waste that run. One A-class latent product risk (A-1) is also unproven and should be closed in the same re-freeze. The product wiring itself is otherwise correct. With the minimum fixes below, re-freeze, and I expect GO.

---

## Q1 — Product

**The S9 verdict is the only new input, and precedence is intact.** Evidence from `src/scout/lifecycle/lifecycle.service.ts` at this head:
- **Tail order:**
  - `onTransferSettled` runs `lockRun` at L409.
  - The CAS check at L410-412 returns `null` before any S9 read.
  - Then come `collectFacts` (L413), `reconcileRun(tx, …)` (L418) on the **same** `tx`, `arbitrate({fence, reconciliation, ...facts})` (L419), and the single `writeTerminal` (L420).
- **Precedence:** `arbitrate` (`src/scout/lifecycle/arbiter.ts` L70-86) is unchanged.
  - The fence wins at step 1.
  - Claim `failed` with zero staged rows gives `failed/transfer_failed` at step 2.
  - The S9 verdict applies only at step 3.
- **One terminal write:** `writeTerminal` is the only `UPDATE` (L442-455), with CAS on `terminal_status IS NULL AND execution_epoch`.
- **S9 writes nothing:** `reconcileRun` (L631-642) is `facts.collect` plus the pure `reconcile().verdict`, copied field by field.
- **No false Complete:** v1 facts carry `coverage: null`, so D-S9-3 makes `complete` unreachable. Every S9-derived terminal is therefore `partial` with an S9 code. The unit spec (`lifecycle.service.spec.ts`, "never yields complete in v1") and the arbiter spec pin this.
- **Unknown never becomes 0:**
  - `projectFamilies` (L697-719) keeps `observed_unique`, `created_native` and `already_present_verified` null.
  - `rejected` and `unresolved` become numbers only from a report token row.
  - A token with no report row keeps the S7-L shape, with nulls (L716-717).
- **R13 (legacy unchanged):**
  - `scout.service.ts` L475 calls `readReport` only when `serverRun`.
  - `readReport` (L661-672) returns `null` without opening a transaction unless `reportApplies`, which requires server mode, a terminal, and a reason other than `reconciliation_not_performed`.
  - `lockRun` filters `mode='server'`, so legacy runs never reach S9.
  - The accepted `toEqual` blocks (`scout.service.spec.ts` L766-787, `lifecycle.service.spec.ts` L464-492) are untouched: both diffs are additions only (`-U0` shows no `-` lines).
  - The legacy `/complete` path is untouched.
- **R15 (additive):**
  - All six fields are optional (`FamilyProjection` L133-142; DTO `@ApiPropertyOptional` in `scout.dto.ts` L285-333).
  - They are spread only when the report has a row for the token (L716-717).
  - The required set is unchanged (the contract spec pins the 8 original keys).
- **R15 (bounded):** bounded only by the fixture, with no structural cap (see C-6).
- **Cross-tenant:**
  - Every S9 read is `facts.collect(tx, coachId, intentId)`, the frozen S9-B collector. Its R11 case was proven on the S9-B lane.
  - S9-C adds no query of its own.
  - The status read's `importRow` is looked up by `(coach_id, intent_id)` (`scout.service.ts` L440-442).
- **Customer-facing side effects:**
  - The only new outward effects are the extra optional status fields and new `reason_code` values on `scout.run.settled` analytics and on the status body.
  - There is no notification, email or native write.

**A-1 (A, latent; close in the re-freeze): S9 work is added to two interactive transactions that use Prisma's default 5 s timeout, while the doc's own performance budget is 10 s.**
- **Evidence:**
  - The settle tail `this.prisma.$transaction(async (tx) => …)` at `lifecycle.service.ts` L408 has no options.
  - `readReport` at L667-670 sets only `isolationLevel`.
  - `PrismaService` (`src/prisma.service.ts`) sets no `transactionOptions`, so Prisma 6.19.3 applies its interactive defaults: `timeout` 5000 ms and `maxWait` 2000 ms. The repo overrides these elsewhere when it needs to (`src/wearables/ingestion/ingestion.service.ts` L150 uses `timeout: 10_000`).
  - R16 (doc L487-490) allows **10 000 ms** for a 10k-row reconcile.
  - `facts.collect` reads staged and ledger rows in 500-row pages (`facts.service.ts` L713-753), reads provenance coach-wide in one `findMany` (L765), and reads natives in 1000-id chunks. At 10k rows that is about 55 queries plus row transfer. The collect now runs **inside** the tail, under the `FOR NO KEY UPDATE` row lock.
  - The R16 wall-time half has no proof on any lane: `rls-g2-s9.spec.ts` checks query counts only, and `reconcile.spec.ts` L38 defers "the PG half of R16".
- **Concrete harm:**
  - A large server run, or a coach with a large provenance history, can exceed 5 s in the tail. Prisma then aborts (P2028), the tail rolls back, `/complete` returns 500 after the claim has committed (`scout.service.ts` L410), and the run waits for the lazy deadline, ending `timed_out/deadline_exceeded`. At S8-G it would have ended `partial`. That is a wrong customer-visible terminal for exactly the large imports S9 exists to account for.
  - The same run's `GET /api/scout/import/status` also recomputes on every poll inside a 5 s `RepeatableRead` transaction. The status endpoint can then fail deterministically for that run, where it worked at S8-G.
  - The row lock is also held for the whole collect, so a coach cancel waits behind it.
- **What it blocks:** accepting S9-C as safe for realistic run sizes. It does not affect correctness of the verdict.
- **Minimum fix:**
  1. Pass an explicit `{ timeout, maxWait }` of at least the R16 budget to the `readReport` transaction (L667-670). This is S9-C's own hunk.
  2. Do the same on the settle-tail `$transaction` (L408). That hunk is not enumerated in the S9-C row of D-S9-8, so it needs a parent grant. The builder's residual risk #5 already names this as a one-line option.
  3. Alternatively, keep the defaults but add a live 10k-row settle plus status case on the S9-C lane that shows the tail and the report stay under 5 s, and record the margin.

**B-2 (B, doc-conformance; parent decision): C-9's REPEATABLE READ requirement is met on the status path but not on the settle path.**
- **What C-9 requires:** Addendum C-9 (doc L570-575) says the facts caller "is responsible for running it at `REPEATABLE READ` … On the settle path that transaction is S8-G's". The settle tail at L408 runs at the default READ COMMITTED. `readReport` does set `RepeatableRead` (L669).
- **Harm:** the settle-time `reason_code` can come from reads torn across staging, ledger, provenance and native tables when natives change concurrently, for example a coach archiving a program mid-settle. The outcome is `partial` either way in v1, so there is no false Complete. Only the persisted reason code can differ from a one-snapshot answer.
- **Blocks:** literal conformance to C-9.
- **Minimum fix, either:**
  - add `isolationLevel: RepeatableRead` to the tail transaction. This needs the same grant as A-1, and a note that RR plus the row lock can raise a serialization failure. That failure lands on the same fail-closed path as a pass failure.
  - or record a deviation that the tail's row lock plus v1's `partial`-only outcome makes READ COMMITTED acceptable until S10.

**C-1 (hygiene):** `reconcileRun` runs even when `fence !== null`, where its result is discarded (L414-419). This is harmless and matches D-S9-1's order. It does add a failure source: a collect error on a fenced run now blocks the fence terminal until the deadline. Optionally short-circuit.

**C-2 (hygiene):** C-10 closure merge (L754-758). A token held by two families whose closures are `verified` and `not_applicable` projects `not_applicable`, which means "no identity carries a declared edge". That is untrue when one holder has verified edges. It is not an overstatement of completeness, but the value should be `verified` in that case, or the rule should be documented.

**C-3 (hygiene):** `reasons` for a token is the **family-level** histogram (`holders.flatMap(f => f.reasons)`, L767), per D-S9-5's "filled from the report's token row and its family". When two tokens map to one family, each entry carries the whole family histogram, so the sum of `reasons.count` can exceed that entry's `rejected + unresolved`. This conforms to the doc, but the DTO description ("histogram over the staged identities", `scout.dto.ts` L318-322) should say "of the family".

## Q2 — Contract / API

- **Additive and regenerated.** The regenerated `docs/contracts/importer-openapi.json` differs from the base only by additions:
  - six optional properties on `ScoutImportFamilyDto`;
  - the new `ScoutImportReasonCountDto` schema (`required: [code, count]`);
  - three `reason_code` enum values appended after `revoked`, in D-S9-7 order.
  The dev-loop regenerated it with `npm run contract:importer`, and a second run was byte-stable, so it was not hand-edited.
- **`CONTRACT_VERSION`** is untouched (`scripts/importer-contract.ts` L53 = `'2.0.0-c1-s2.0'`), and `scripts/**` has no diff.
- **Reason codes:** `src/scout/lifecycle/reason-codes.ts` appends `unresolved_identities`, `relationship_unverified` and `coverage_basis_unknown` after the six S7-L codes, whose order is unchanged. The compile-time subset proof is `S9_RUN_REASON_CODES: readonly RunReasonCode[] = S9_REASON_CODES` (`lifecycle.service.ts` L99). `catalogue-parity.spec.ts` (last `it`) pins the append order. `importer-contract.spec.ts` sorts before comparing, so only the catalogue-parity spec pins the order.
- **Catalogue parity: C-9 says "equals"; the draft pins subset plus exact delta. I accept this as a reading of C-9, with a recorded deviation (C-4, not a defect).**
  - Runtime `UNRESOLVED_CODE` (`native-contract.ts` L43-56) has 12 codes. S9-A `UNRESOLVED_CATALOGUE` (`reconciliation/types.ts` L359-375) has 15. Literal equality cannot hold without editing frozen S9-A or widening S8-C, and both are outside the S9-C row.
  - The spec pins the runtime count (12), the catalogue count (15), runtime ⊆ catalogue with identical qualifier shapes (derived from `unresolved()` throwing), and a surplus of exactly `{date_zone_unknown, no_native_destination, unit_unknown}`. Drift in either direction still turns the test red, which is the purpose of C-9.
  - The safety-relevant direction is covered: no runtime reason can fold into `reason_unrecognised`.
  - **C-4:** the parent should record this as an Addendum deviation, so the doc does not keep asking for something that is structurally false.
- **C-5 (hygiene):**
  - `native_present_verified` renders as `type: number` (D-S9-5 says `int`). Other count fields follow the same generator habit, but `type: 'integer'` would be more exact.
  - `reasons[].code` is an open `string`. That is acceptable, because C-7 closes only `qualifiers`.
  - `qualifiers.items.enum = ['roster_bridge_pending']` and the `relationship_closure` enum are closed, per C-7.

## Q3 — Tests

**B-1 (B, blocking the live proof): `test/rls-g2-s9c.spec.ts` L286 is false for the real stack and will fail on the lane.**
- **The assertion:**
  - `isS9Read` (L106) is any `SELECT … "ImportNativeProvenance"`.
  - L286 asserts `done.queries.filter(isS9Read).length === tail.filter(isS9Read).length`, meaning "no S9 read outside the tail" across the whole `/complete`.
- **Why it fails:**
  - The worker logs **every** statement of the client through `db.$on('query')` (`g2-s9c-worker.cjs` L83-87), including the S8-G pass's per-row transactions.
  - The accepted S8-C writers issue `SELECT … FROM "ImportNativeProvenance"` through `findProvenance` (`src/scout/reconstruct/native/native-provenance.ts` L45-50), called from `persistProgram` (`native-writers.ts` L99), the workout parent lookup (L140), L245 and L373.
  - This case's fixture reconstructs 1 program and 2 workouts (the test's own `ledgerByToken` expectation, L263-268), so the pass produces at least 3 such SELECTs outside the tail.
- **Concrete harm:** the one-run S9-C proof bound to one attested head goes red on this line. The run is spent, and a new head plus a new grant is needed.
- **Blocks:** the R09 live case, and therefore the C-tier proof of R09.
- **Minimum fix:** narrow the S9-read signature to the facts collector's own statement shape, then keep the assertion. The collector's provenance read is the `findMany` with `source_namespace IN (…)` / `entity_type IN (…)` and no `LIMIT` (`facts.service.ts` L765-770). The pass uses a `findUnique` by the full key, which Prisma renders with `LIMIT`. For example:
  ```ts
  isS9Read = q => /"ImportNativeProvenance"/.test(q) && /^\s*SELECT/i.test(q) && /"source_namespace" IN \(/.test(q)
  ```
  Alternatively, drop L286 and assert only `tail.filter(isS9Read).length > 0` with the pass segments excluded. The other isS9Read uses are all tail- or status-scoped and stay valid under either fix: L279, L393 and L411 are tail-only; L441 is the status segment; L533 is the legacy status.

**B-3 (B, minor proof gap; non-blocking): the R10(C) live case proves replay by re-reading, not by replaying an intent.**
- R10 (doc L465-467) also requires that "a replayed intent that converged `already_present` gives the same report". The live R10(C)/R15 case replays the **status read** only (second `status` and second `report` compared with `toEqual`). No live or unit S9-C case settles a second intent over the same source identities, to show `already_present` convergence reaches the same terminal and projection with `created_native`/`already_present_verified` null.
- S9-B covers this at the facts tier (`rls-g2-s9.spec.ts` L253, "replay leaves the facts identical").
- **Minimum fix:** in the same live file, one extra case: a second intent re-stages `blk-1`/`rt-1`, settles, and the test compares `reason_code` and per-token `native_present_verified`/`rejected`/`unresolved` with the first run, and checks the D-S9-4 nulls.

**B-4 (B, conformance of a PII guard; non-blocking if recorded): C-6 qualifier validation is by grammar, not by the spec's own names.**
- Addendum C-6 (doc L560-566) asks S9-C to validate qualifiers "against the spec's family, field and model names".
- `admitReasonCode` (`lifecycle.service.ts` L803-816) does:
  - check `unresolved_family:<token>` exactly against the staged tokens (good);
  - check `unsupported_platform:<p>` against the regex `PLATFORM_QUALIFIER` (L117);
  - check `unresolved:<code>:<q>` against `NATIVE_NAME_QUALIFIER = /^[a-z_.A-Z]+$/` (L115), the same regex the S8-C `unresolved()` writer enforces (`native-contract.ts` L77).
- A grammatical but non-spec qualifier, for example a surname, would be echoed to the DTO. Today only `unresolved()` writes the `unresolved:` prefix, and its qualifiers are chosen by code (rg finds no other writer), so there is no present leak.
- The unit C-6 case tests grammar failures only.
- **Minimum fix:** record the grammar-level check as an accepted C-6 reading, or check the qualifier against a registry-derived set of native field and model names.

**Unit specs are meaningful and not vacuous:**
- `lifecycle.service.spec.ts`, S9-C settle wiring: verdict written; fence wins; claim failed with zero staged gives `transfer_failed`; CAS miss means no collect, no write, no event; one `executeRaw`; `complete` never written.
- `lifecycle.service.spec.ts`, recompute-on-read: `transaction.mock.calls[0][1]` equals `{isolationLevel:'RepeatableRead'}`, and the report equals `reconcile(MIXED).report`.
- `lifecycle.service.spec.ts`, projection: two-argument and null-report calls give exactly the S7-L keys; C-10 sum and null; C-6 fold.
- `scout.service.spec.ts`: R13 (`readReport` never called); R15 with a 32-family fixture of 128-character tokens and roughly 14 reasons each, at or under 64 KiB.
- `arbiter.spec.ts`: the fence beats `complete`.

**C-6 (hygiene):** the R15 fixture is representative, not a proven worst case.
- The histogram size is bounded only by catalogue × qualifier domain, including `unresolved_family:<128-char token>` and `unsupported_platform:<64-char platform>` keys. The projection has no cap or truncation.
- My estimate for the fixture body is about 45 KB against a 64 KiB limit.
- Acceptable against doc R15 as written. The note should say "fixture-bounded".

**C-7 (hygiene):** `rls-g2-s9c.spec.ts` L337 `expect(call).not.toMatch(/'complete'/)` is vacuous: the worker logs statement text without parameters, and terminal values are bound parameters. The real check is the row assertion above it. Delete the line or replace it with a row check.

**Landed S8-G spec modification (`test/scout/orchestration/settle-hook.spec.ts`): minimal and justified.**
- Once D-S9-1 passes a verdict, step 4 (`reconciliation_not_performed`) is unreachable from the hook, so the landed assertions must change.
- The diff:
  - injects a facts double that returns empty facts, whose verdict is `partial/coverage_basis_unknown`;
  - substitutes that code in 3 assertions;
  - extends the order pin to `pass,lock,facts,terminal`;
  - adds "CAS miss never reaches facts";
  - adds a default-constructor `facts` check.
- No case was removed, and the `it` count stays 10.
- One fixture inconsistency: the claim-`failed`-with-rows case feeds `EMPTY_FACTS.claim='success'` (harmless, C).
- Note for the parent: the landed live proofs `rls-g2-s7l.spec.ts` and `rls-g2-s8g.spec.ts` would fail if re-pointed at this head. That is acceptable because "no accepted suite is rerun" (doc L428-429), but it should be recorded.

**DB guard versus sibling `test/utils/g2-s9-db.ts`: the guard is not weaker.**
- The logic is a literal substitution. The refused-port list adds `55645` to the sibling's set (`g2-s9c-db.ts` L60-72).
- The confirmation is double-entered (`g2_s9c_disposable:<port>`).
- The login-role whitelist is unchanged, the markers are pinned literals, and the candidate-head binding is identical.
- The guard spec adds `g2_s8c`/`s8c_super` URL refusals and the `g2_s8g`/`g2_s9` confirmation-mismatch cases. The dev-loop round-1 fix restored the 55644 refusal.
- **C-8 (hygiene):**
  - The spec's role-refusal list (`g2-s9c-db-guard.spec.ts` L118-133) dropped `s8g_super`, which the sibling lists, and does not add `s9_super`. The whitelist still refuses both, so coverage is one role narrower than the sibling. Add both.
  - `G2_S9C_BASE_HEAD` (`g2-s9c-db.ts` L137), the bootstrap `BASE_HEAD` and the guard-spec pin are `771db62a` (S8-G), not the actual base `5407efae` (S9-B merge). The binding still holds, because 771db62a is an ancestor and S9-B added no prisma change. It is stale, though, and the "not the base" refusal would not refuse `5407efae`. Update all three pins together at the re-freeze.

## Q4 — Scope (S9-C row of D-S9-8, doc L409; Gen row L410)

- **Prisma and migrations:** none. `git diff 5407efae --stat` has no `prisma/**` path, and the live spec asserts an empty diff for `prisma/migrations` and `prisma/schema.prisma`.
- **Frozen S9-A and S9-B files** (`src/scout/reconciliation/**`, their specs and harness): untouched.
- **Forbidden paths** (`run.controller.ts`, `reconstruct/orchestration/**`, `scout-reconstruct.service.ts`): untouched.
- **Outside the enumerated S9-C paths.** All are C; each needs a parent grant or adoption line, none is a defect:
  1. `test/contracts/importer-contract.spec.ts` (+42) and `docs/contracts/importer-openapi.json`. The Gen row reserves these to the **generator owner only** ("S9 builders" forbidden). The JSON was produced by the generator, which is fine. The spec hunks (pin extensions plus one new `it`) were written by the builder. The parent should adopt them as Gen owner, or have the Gen owner re-author them.
  2. `test/scout/orchestration/settle-hook.spec.ts`, a landed S8-G spec: necessary, as covered under Q3.
  3. `test/scout/reconciliation/catalogue-parity.spec.ts`: mandated by C-9 ("S9-C adds a spec"), but the path is not in the row.
  4. `test/rls-g2-s9c.spec.ts`, `test/scout/g2-s9c-db-guard.spec.ts` and `test/utils/g2-s9c-{bootstrap.sh,db.ts,harness.ts,pg-harness.ts,worker.cjs}`. §3 (L425-428) calls for one C-tier PG proof, and §5 leaves the PG slot to the parent. The paths are not enumerated.
- **Extra hunks inside granted files.** The row forbids "every other hunk of the files it touches".
  - In `reason-codes.ts`: the row grants "three appended entries". The draft also adds `FAMILY_QUALIFIERS` and `RELATIONSHIP_CLOSURES` (L63-71) and a rewritten doc comment.
  - In `scout.dto.ts`: the row grants "optional additive properties only". The draft also adds the new class `ScoutImportReasonCountDto` (L217-228) and a class docstring edit.
  - In `lifecycle.service.ts`: the draft also adds the exported consts `PROJECTED_*`, the regexes, `reportApplies`, `projectToken`, `projectReasons`, `admitReasonCode` and `ReportScopeRow`. These serve granted items (the projection, the C-6 obligation, the D-S9-7 compile-time proof), but the text does not enumerate them.
  - Recommendation: accept them in a scope-deviation note, rather than churn.

## Findings table

| ID | Class | Blocking | One-line |
|---|---|---|---|
| B-1 | B | **Yes** (live proof) | `rls-g2-s9c.spec.ts` L286: `isS9Read` also matches the S8-C pass's `findProvenance` SELECTs, so the assertion fails on the lane. Narrow the signature. |
| A-1 | A (latent) | Yes (close in same re-freeze, or prove) | The settle tail (L408) and `readReport` (L667) now carry the S9 collect under Prisma's 5 s default interactive timeout, versus R16's 10 s. Large runs can end `timed_out` instead of `partial`, and their status can fail on every poll. Set explicit timeouts (tail needs a grant) or prove under 5 s at 10k rows. |
| B-2 | B | Parent decision | C-9 REPEATABLE READ is not applied on the settle tail (READ COMMITTED). Add it (with a grant) or record a deviation. |
| B-3 | B | No | R10(C) "replayed intent converged `already_present`" is not exercised at C tier. Add one live case. |
| B-4 | B | No (if recorded) | C-6 validates qualifiers by writer grammar, not by spec names. Record or tighten. |
| C-1..C-8 | C | No | Fence short-circuit; `verified`/`not_applicable` merge; family-level `reasons` wording; C-9 subset deviation note; `integer` type; R15 fixture-bounded note; vacuous `'complete'` regex; guard-spec role list and stale `BASE_HEAD` 771db62a → 5407efae. |

**Minimum path to GO:**
1. Fix B-1 (one predicate).
2. Resolve A-1 with an explicit `timeout`/`maxWait` on `readReport`, plus a parent-granted one-line option on the settle tail. Or record an under-5 s 10k-row measurement.
3. Decide on B-2.
4. Optionally update the stale `BASE_HEAD` pins (C-8) while re-freezing.
5. Re-run dev-loop, re-freeze, commit, then run the single S9-C lane proof.

---

## Delta re-review (freeze-2 01132b71)

Scope: only the freeze-1→freeze-2 delta (`freeze-2/delta-freeze1-to-freeze2.diff`, 11 files, +534/-35), read against the read-only worktree `worktrees/d3a9-s9c-r2` (HEAD 5407efae).
- Integrity: `s9c-freeze2.patch` sha256 = 0a31e897… and the delta = ae332a55…, both matching `FREEZE.env`.
- The worktree bytes match all 22 `MANIFEST.sha256` entries.
- No tests were run (read-only). Green status is taken from the parent's devloop-4/5 evidence.

**Process disclosure.** While checking integrity I ran `git add -N .` in `d3a9-s9c-r2` by mistake. It changes only the index and marked the 9 untracked files intent-to-add. I reversed it straight away with `git reset -q -- <those 9 paths>`. `git status` is back to 13 `M` + 9 `??`, and the working-tree bytes were never touched: they still match the MANIFEST, and I re-checked that after the reset. Nothing was committed, formatted or run.

### Verdict: **GO** (for the S9-C landing, subject to the live PG lane run passing on the freeze-2 candidate)

All freeze-1 A/B findings (B-1, A-1, B-2, B-3, B-4) are closed. No new A or B findings. What remains is C-class only.

### Q1 — B-1 `isS9Read`: CLOSED
- **New predicate** (`test/rls-g2-s9c.spec.ts:112-113`): it needs `SELECT`, `"ImportNativeProvenance"` and `"source_namespace" IN (`.
- **Every non-S9 provenance access uses equality or no `source_namespace` predicate at all:**
  - `findProvenance` is a findUnique on the compound key (`native-provenance.ts:46`).
  - `create`, `update` and `upsert` (`:60, :79, :101`) are writes or compound-key lookups.
  - `countUnresolvedChildren` uses `source_namespace: parent.sourceNamespace` equality (`:116-124`).
  - `scout-entities.service.ts:286-292` filters `coach_id`, `outcome: {in}` and `OR: kinds`, with no `source_namespace`.
- **The only `source_namespace: { in: … }` is the S9-B collector** (`facts.service.ts:768`, called at `:298`). Prisma's PG rendering `"public"."ImportNativeProvenance"."source_namespace" IN ($1…)` contains the literal `"source_namespace" IN (`, so it matches.
- **The assertions can neither pass vacuously nor fail falsely.** The positive checks guard the negatives:
  - `:286` `s9At` (and the order checks after it) and `:448` `.some(isS9Read) === true` would fail loudly if the predicate never matched.
  - That keeps the negatives at `:400`, `:418` and `:540` (`toEqual([])`) meaningful.
- **Residual (C-9 below):** that Prisma renders `in` as `IN (…)` rather than `= ANY(…)` is an assumption. I found no captured statement text in the evidence to confirm it. If it were wrong, the result would be a red lane run, not a false green.

### Q2 — A-1 / B-2 snapshot options and retry: CLOSED
- **One shared options object** (`lifecycle.service.ts:63-67`): `{ RepeatableRead, timeout 20_000, maxWait 5_000 }`.
  - The settle tail uses it through `settleWithSnapshot` (`:423`, `:460-470`).
  - `readReport` uses it too (`:714`).
  - Unit tests assert it by identity on both paths.
- **Timing vs R16 and the run deadline:**
  - 20 s is 2× R16's 10 s.
  - Worst case is 3 attempts × 20 s = 60 s plus maxWait, still well inside `SCOUT_RUN_DEADLINE_MS_DEFAULT` = 300 s.
  - The spec asserts `timeout ≤ deadline/10`.
- **Why the retry is safe:**
  - It retries only `P2034` (`isSerializationFailure`, `:472-474`) and at most `SETTLE_ATTEMPTS = 3` times (`:53`). Anything else propagates after one attempt, and exhaustion rethrows. All of this is tested.
  - Each attempt is a fresh `$transaction`. The failed attempt has been rolled back by PG, so its UPDATE has no effect.
  - Every attempt re-runs `lockRun` (`FOR NO KEY UPDATE`) and re-checks terminal/epoch before collecting facts. A concurrent fence, cancel or revoke that caused the 40001 therefore wins, and the retry returns null with no write (tested: "retry that re-locks a now-terminal row is a no-op").
  - Analytics capture runs after the transaction returns, so it fires once (tested).
  - Under RR, a concurrently changed row surfaces as 40001 on the lock or CAS statement rather than as a silent stale write, and this path handles exactly that.
- **`readReport` is read-only and not retried.** A P2034 there surfaces as a status-read error, not a wrong report. That is acceptable.

### Q3 — guard roles/DBs and base pins: CLOSED (my C-8 closed)
- **Refusals added** (`g2-s9c-db-guard.spec.ts:50-51, 59-60`): `g2_s8g_disposable`, `g2_s9_disposable`, `s8g_super@`, `s9_super@`.
- **BASE_HEAD `5407efae319f…` is pinned in all four places:**
  - guard spec `:145, :181`
  - `g2-s9c-db.ts:137`
  - `g2-s9c-bootstrap.sh:27`
  - `g2-s9c-pg-harness.ts:10` (comment)
- The remaining `771db62a` strings are accurate "derived from S8-G at 771db62a" provenance comments (db.ts:3, pg-harness.ts:3, worker.cjs:3, rls spec:5, harness.ts:3, bootstrap.sh:3).
- **The pin premises hold:**
  - `git diff 1c5fbb04 5407efae -- prisma` is empty.
  - `git diff 5407efae -- prisma` on the candidate is empty.
  - The base tracks 172 `migration.sql`, so `EXPECTED_MIGRATIONS = 172` still holds.

### Q4 — B-3 R10(C) replay → already_present: CLOSED, non-vacuous
- `lifecycle.service.spec.ts:922+` flips every `reconstructed`/`created` provenance in MIXED to `already_present`.
- It proves the flip happened: `replayed` contains `already_present` and MIXED does not.
- It then asserts:
  - `reconcile(replayed)` equals `reconcile(MIXED)`;
  - the projection is identical, with `native_present_verified = 1` and `created_native` / `already_present_verified` both `null` (D-S9-4);
  - the settle tail writes the same terminal, `partial` / `unresolved_identities`.
- The parent's TS2339 narrowing (`i.ledger?.status === 'reconstructed' && i.ledger.provenance?.…`) is test-only and changes no behaviour.

### Q5 — B-4 closed-domain `admitReasonCode`: CLOSED
- **`reason-domains.ts` builds every set from constants:**
  - `RECONSTRUCT_FAMILY`, `NATIVE_FAMILY`, `CHILD_ENTITY_TYPE`;
  - `Prisma.ModelName` for 4 models;
  - 4 `Prisma.*ScalarFieldEnum`s;
  - `NATIVE_RULE_FIELDS`;
  - `S9_REPORT_CODE`, `WRITER_CODE`;
  - `UNRESOLVED_CATALOGUE` for the code shape.
- **`admitReasonCode` (`lifecycle.service.ts:860+`)** now needs the key to be a constant code, or a catalogue code of the right shape plus an in-domain qualifier. Anything else returns false. The grammar regex `NATIVE_NAME_QUALIFIER` has been removed.
- **Pinned negatives are present:** `…missing_required_field:Jane`, `…:title`, `frobnicate`, `unresolved:frobnicate:name`, bare-with-qualifier, and empty or extra parts.
- **Coverage check against the real writers.** I listed every qualifier S8-C actually emits:
  - `native-rules.ts` `missing()`/`*Field(..., '<f>')`/`invalid_value` literals: `day_index`, `days_per_week`, `description`, `exercise_external_id`, `id`, `name`, `notes`, `order`, `program_id`, `reps_or_duration_seconds`, `rest_seconds`, `sets`, `superset_group_id`, `type`, `week_index`, `weeks`, `weight_lbs`, `duration_estimate_minutes`, `exercises`;
  - `native-writers.ts:151-163`: `programs`.
  - Each one is a scalar column of WorkoutProgram, WorkoutPlan or WorkoutPlanExercise in `prisma/schema.prisma` (so it is in a ScalarFieldEnum), or `exercises`, or a family.
  - So no real reason folds to `reason_unrecognised`.
  - The fixture renames `title`→`name`, `minutes`→`duration_estimate_minutes` and `kind`→`type` in `scout.service.spec.ts` and the lifecycle spec. These are corrections to what the writer really emits, not a weakening of the tests.
- **native-rules.ts exception** (`:623-638`): exactly +17/-0. It is a new const plus an exported `Set` built from the existing `PROGRAM_FIELDS`/`WORKOUT_FIELDS`/`EXERCISE_FIELDS` keys, with no change to existing bytes and no runtime behaviour change. It stays within the parent grant. See C-10.

### Q6 — Addendum B.4 scope list: CLOSED
- `docs/decisions/…s9-reconciliation.md:697+` lists every deviation I flagged at freeze-1:
  - Gen-owner adoption of `importer-contract.spec.ts` / openapi;
  - `settle-hook.spec.ts`;
  - `catalogue-parity.spec.ts`;
  - the PG proof lane files;
  - the helper hunks in reason-codes, dto and lifecycle (plus the new reason-domains);
  - the native-rules additive export;
  - the settle-tail isolation/timeout/retry grant;
  - the C-9 subset deviation (B.1).
- The addendum is append-only (the hunk starts after the old `:632`, 87 added lines, 0 removed).

### New / residual findings (all C)
- **C-9 (new): Prisma SQL-shape assumption in `isS9Read`.** It relies on Prisma 6.19.3 rendering `in` as `IN (`. I found no captured statement text to confirm this. If it fails, it fails loudly (`:286`/`:448` go red), not vacuously. Optional: record one logged S9 statement in the lane evidence.
- **C-10 (new): `NATIVE_RULE_FIELDS` is surplus.** It adds camelCase rule keys (`daysPerWeek`, `exerciseRef`, …), which no writer emits as a qualifier. Every emitted qualifier is already a ScalarFieldEnum column. It is harmless: these are code identifiers, not user data. But the scoped exception to the landed S8-C file was not needed to close B-4. The comment at `native-rules.ts:624-627` ("every `<field>` qualifier … is either one of these keys or a native column name") is true only through the column arm. Optional follow-up: drop the export and the exception at a later slice.
- **C-11 (new): `unsupported_platform:<p>` is still admitted by grammar alone in production.** `projectReasons` calls `admitReasonCode(code, stagedTokens)` without `stagedPlatforms` (`lifecycle.service.ts:835`), so the membership arm is exercised only in unit tests. B.3 says this accurately ("when the caller supplies"). Exposure is low: the value is the staged `source_platform` token under `PLATFORM_QUALIFIER`, which is lowercase and ≤64 characters with no spaces or `@`. Optional: pass the staged platform set.
- **C-12 (new): doc wording.** B.2 (`:665`) calls 10 000 ms "R16's proven bound". The delta adds no live 10k-row wall-time evidence, so "R16's budget" is the accurate term.
- **C-13 (new): lock hold time.** The 20 s timeout means a slow settle can hold the run row's `FOR NO KEY UPDATE` lock for up to about 20 s per attempt. Concurrent cancel or fence requests wait that long. It is bounded and fails closed, so this is a note only.
- **Freeze-1 C-1..C-7 are unchanged** and outside this delta. C-4 is superseded by B.1 and C-8 is closed.
