# S10-C source — independent review B (T4)

**Scope.** I read the source only and ran nothing: no jest, tsc, postgres or index commands. I used read-only git with `GIT_OPTIONAL_LOCKS=0`.
- **Worktree:** `worktrees/d3a9-s10c`, branch `exec-d3a9/s10c`, HEAD `a2c74e90`.
- **What changed:** 9 working-tree paths (6 ` M`, 3 `??`).
- **Spec:** `docs/decisions/2026-09-26-s10-induction.md` D-S10-4..8 and R23/R27/R33-R37.

## Verdict: NO-GO as it stands

Production code:
- The settle-write and status-read code is correct.
- The transaction boundaries match D-S10-4 exactly.
- There is one low-severity A: mounting the S10-B module gives it its own PrismaClient. The fix is one line, but the file belongs to S10-B.

The blockers are proof defects in the S10-C tests (B1-B3), plus one binding-plan gap (B4). Every fix is small, and B1-B3 are in S10-C-owned test paths.

## 1. Transaction boundaries of the settled-basis insert: correct (no finding)

**Settle tail**
- `onTransferSettled` → `settleWithSnapshot(body, S9_SNAPSHOT_TX_OPTIONS)` (REPEATABLE READ; lifecycle.service.ts:447-495).
- The locked row must match `execution_epoch === epoch` (:450). The binding handed to `reconcileRun` is `locked.execution_epoch` / `locked.accepted_start_at` (:456-460). The CAS then runs on the same `epoch` (:462).

**Insert placement**
- The insert runs only after `writeTerminal` returns true (:463-467).
- A CAS miss (`!written`) returns null before the insert.
- `fence()` (:380-404) has no insert.

**Rollback**
- An insert error throws out of the transaction, so the terminal rolls back with it.
- Only P2034 is retried, and a retry re-runs the whole body, insert included.
- `analytics.capture` fires only when `outcome` is non-null, i.e. after commit (:469).

**Digest consistency**
- `writeSettledBasis` (:550-573) reads `scoutRunObservation.findMany({coach, intent, execution_epoch: epoch})` in the same REPEATABLE READ snapshot as the evaluator's `readObservations` (facts.service.ts, same `where`).
- So the recorded `observation_digests` are exactly the set the verdict was computed from.

**Other checks**
- **One row per run:** the PK is `(coach_id, intent_id)`, so a second insert fails and rolls back rather than merging. A second settle cannot reach the insert anyway (`terminal_status !== null` at :450).
- **Status read:**
  - `readSettledBasis` does a `findUnique` on `coach_id_intent_id` (coach-scoped) outside any transaction.
  - The basis commits atomically with the terminal, and `reportApplies` requires a terminal, so a status read either sees both or neither. Fence-path terminals have no basis and fall back to the S9-C recompute, as D-S10-4 requires.
  - The recompute fallback now passes the full run binding. `scout.service.ts:440-475` passes the full `ScoutImport` row, so `execution_epoch` and `accepted_start_at` are present. `epoch: undefined` cannot turn into a Prisma no-filter.

## 2. Real-PG spec: harness import, lane, vacuity

**Harness: imported, not forked.**
- `test/rls-g2-s10c.spec.ts:21-37` imports `g2-s10b-harness`, `g2-s10b-pg-harness`, `g2-s10b-fixtures` and the S10-B worker (via `run`/`worker`).
- All the helpers it uses exist and are exported: `SETTLED` (harness.ts:20), `observationRows` (:157), `count` (:165), `json`/`quote` (pg-harness.ts:77-78).
- The worker's `failAfter` proxy works for any model name inside a transaction (worker.cjs:131-141), so `failAfter: {model: 'scoutRunSettledBasis', n: 0}` actually injects.

**Cannot pass vacuously on the guard side**
- `pg-harness.ts:45` evaluates `g2S10bTestTarget(raw, G2_S10B_CONFIRM)` at import time and throws without the confirmed lane.
- The candidate-head and clean-tree guards are the S10-B ones.
- There are 8 `it(` and no skip/only/todo/xit.

**Lane it needs**
- The S10-B lane identity is **literal, not a parameter**:
  - cluster marker `s10b-disposable-pg17`, DB `g2_s10b_disposable`, role `s10b_super` (g2-s10b-db.ts:14, 23, 44);
  - bootstrap `CLUSTER_MARKER`/`DB_MARKER`.
- Only the **port** (URL plus `G2_S10B_CONFIRM`, and not in REFUSED_PORTS, which stops at 55646) and the **data dir** (`G2_S10B_DATA_DIRECTORY`) are parameters.
- Bootstrap prerequisites still hold at S10-C: `EXPECTED_MIGRATIONS=173`, and the prisma diff against `a4af8e33` is exactly 3 files (S10-C touches no prisma).
- There is no collision with s9-c (55646, refused) or any earlier lane. The constraints on the binding are in B4.

## 3. Findings

### A1 (low): mounting ObservationModule instantiates a second PrismaService
- **Evidence:**
  - `src/scout/induction/observation.module.ts` lists `PrismaService` (and its own `ScoutLifecycleService` and `JwksVerifierService`) in `providers`.
  - `src/prisma/prisma.module.ts:4-7` is `@Global` and says: "every feature module shares a single PrismaClient + connection pool. Previously each feature module declared PrismaService in providers, creating ~14 separate PrismaClient instances and exhausting the Supabase pool".
  - S10-C's `scout.module.ts` import (`imports: [..., ObservationModule]`) is what puts this module live in production.
- **Harm:** one more PrismaClient and connection pool in production, which is the documented pool-exhaustion pattern. `ScoutModule` itself still does this (scout.module.ts:68), so this is incremental, not new in kind.
- **Blocks:** nothing in the proof; it is a production resource consequence of the mount.
- **Minimum fix:** remove `PrismaService` from `ObservationModule.providers`; the global PrismaModule supplies it. That file is S10-B-owned (staged in PR #549), so the fix is either an S10-B follow-up or a recorded parent acceptance.
- **Unblocks:** mounting without adding a pool.

### B1: the R35 live "drift" test performs no drift, and its no-recompute check cannot fail
- **Evidence (rls-g2-s10c.spec.ts:236-262):**
  - The comment says "Drift the live world after the settle: an extra ledger row the recompute WOULD count", but nothing is written between `first` and `again`. Both reads run against an unchanged world.
  - The run is `partial/coverage_basis_unknown` either way, so a recompute would return the same bytes. `after === before` therefore proves nothing about the settled basis being preferred.
  - The negative check `queries.filter(/ISOLATION LEVEL REPEATABLE READ/)` has length 0, but the query log never contains the isolation statement. The S9-C live spec says so itself: "the isolation option itself is pinned by the unit spec" (rls-g2-s9c.spec.ts:442-446) and uses `-- tx:begin` markers instead. So this check is 0 whether or not a recompute ran.
- **Harm:** D-S10-4 "Status" and R35 ("archive a native row … settled report byte-identical to settle time") have no live proof. A regression back to recompute-after-basis-read would still pass. The only positive live check is "a basis SELECT happened".
- **Blocks:** live acceptance of R35 and invariant 4.
- **Minimum fix:**
  1. Between the two status reads, change the world through the harness's admin `sql` in a way the recompute would reflect. For example, archive or delete a native/provenance row, or insert a ledger row for a staged identity.
  2. Assert that `again`'s report-derived fields are unchanged **and** equal the projection of `settledRow(...).report`.
  3. Replace the RR regex with `expect(again.queries.filter(q => q === '-- tx:begin')).toHaveLength(0)`, and assert no S9 fact-table read (for example the staged, ledger or provenance SELECTs).
- **Unblocks:** a real live R35/D-S10-4 status proof.

### B2: R33 `complete` and R23 exact code are proven only on hand-built facts
- **Evidence:**
  - Coverage spec "R33 unit half" (facts.service.coverage.spec.ts:332-342) runs the real collector and evaluator, and asserts coverage `BASELINE` and that `conditions` lacks `coverage_basis_unknown`. It does **not** assert `reconcile(facts).verdict` is `{complete, null}`, and the service uses `nativeRules: buildNativeRuleRegistry([])` (:157). So the real-facts path to `complete` is never exercised.
  - "R23 terminal half" (:344-361) asserts `outcome === 'partial'` and `conditions ∋ coverage_basis_unknown`, but only that `verdict.reason_code ∈ S9_REASON_CODES`. The code could be another S9 code (for example `unresolved_identities`, with natives empty) and the test would still pass.
  - The exact `{partial, coverage_basis_unknown}` and the `complete` terminal write are asserted only in lifecycle.service.spec "invariant 1", which uses hand-written `ReconciliationFacts` with a synthetic `coverage` object.
  - The live spec deliberately asserts `not.toBe('complete')` (rls-g2-s10c.spec.ts:109) because the worker has no manifests.
- **Harm:** no test at any tier shows that the production chain (collector → S10-A evaluator → `familyCoverage` → `reconcile` → arbiter) yields `complete` (R33, invariant 1). Nor does any test show that R23 lands on exactly `coverage_basis_unknown` from real facts. A mismatch at a seam, such as the evaluator's family keys not matching `families[]` keys, would go unseen until R39 (S10-D).
- **Blocks:** R33 (C) and the terminal half of R23, the two headline S10-C acceptances.
- **Minimum fix:** in the coverage spec, give the fixture a native-clean state (a native rule set or verified provenance for the staged identities, the same thing the lifecycle "clean natives" facts assume). Then assert:
  - R33: `reconcile(facts).verdict` equals `{outcome:'complete', reason_code:null}`;
  - R23: `verdict` equals `{outcome:'partial', reason_code:'coverage_basis_unknown'}` exactly.

  Optionally, feed those real facts through `onTransferSettled` with a stubbed db, as "invariant 1" does. If the parent instead assigns the R33 `complete` half to R39, record that in the decision doc; do not leave it implicit.
- **Unblocks:** end-to-end proof of R33 and R23 on real composition.

### B3: the S9-C live invariants that D-S10-4 changes are not carried over
- **Evidence:**
  - The builder lists `test/rls-g2-s9c.spec.ts` L289 (`terminalAt === tail.length - 1`) and L444-448 (status: one `-- tx:begin`, S9 read) as "expected to break". These are exactly the two assertions D-S10-4 changes: a basis SELECT and INSERT after the terminal in the tail, and status from the settled record.
  - That spec cannot be re-run at S10 heads anyway, because `g2-s9c-bootstrap.sh:27,31` pins `BASE_HEAD=5407efae` and `EXPECTED_MIGRATIONS=172`, and the S10 head has 173. So it is frozen historical evidence, not a spec S10-C would break.
  - Nothing else in S10-C needs to change in S9-C. The only landed assertion S10-C edits is the unit `lifecycle.service.spec.ts` L674 `collect` args, widened for the `RunBinding` parameter. That is a consequence of the chosen design and is correctly limited. S10-C does not touch `rls-g2-s9c.spec.ts` (not an S10-C owned path, D-S10-7), which is correct.
  - However, the S10-C live spec does not re-assert the S9-C tail invariant that survives D-S10-4: no write in the tail before the CAS (S9-C `tail.slice(0, terminalAt).filter(isWrite) == []`). R33 (rls-g2-s10c.spec.ts:136-147) checks CAS→INSERT ordering and counts only.
- **Harm:** at S10 heads nothing proves live that the settle tail issues no write before the arbiter's CAS (invariant 6, "the S9 arbiter stays the sole terminal writer"). The S9-C spec that did cannot run here.
- **Blocks:** invariant 6 live at S10-C.
- **Minimum fix:** in R33, add `expect(q.slice(lockIndex, cas).filter(isWriteStatement)).toEqual([])`. Take `isWrite` from the same regex family the S9-C spec uses (INSERT/UPDATE/DELETE), and bound the check to the tail from the `FOR NO KEY UPDATE` lock. Also, in the S10-C doc or README, record that the S9-C live assertions at L289 and L444-448 are superseded by S10-C R33/R35 at S10 heads.
- **Unblocks:** invariant 6 live proof, and a clean record of which S9-C assertions D-S10-4 retired.

### B4: the binding plan (for the parent) is not yet runnable as written
- **Evidence:**
  - The builder's heavy command is `npx jest test/rls-g2-s10b.spec.ts test/rls-g2-s10c.spec.ts test/rls-g2-s9c.spec.ts test/rls-g2-s9.spec.ts`. That mixes G2_S9C_*/G2_S9_* lanes into a G2_S10B_*-only environment, and the S9-C bootstrap cannot run at 173 migrations.
  - The S10-B lane `runtime/clusters/s10-b` is **retained** after the S10-B proof. `s10b-fixture.sh init` refuses an existing `$DATA`.
  - The fixture refuses any runner whose cmdline is not `s10b-pg-proof.sh` (fixture:34-35).
  - The cluster marker, DB and role are literals.
- **Harm:** a derived S10-C binding would either refuse (fail-closed), or need a lane decision made under time pressure. A mixed jest run could not produce a clean pinned count.
- **Blocks:** the S10-C real-PG proof.
- **Minimum fix:**
  1. Run only `jest --config jest.rls.config.js test/rls-g2-s10b.spec.ts test/rls-g2-s10c.spec.ts --runInBand --ci`, pinned to `Tests: 32 passed, 32 total` (24 + 8). Pin the `it(` counts and blobs of both files.
  2. For the lane, choose one of:
     - (a) destroy the s10-b lane under a separate grant, then fresh-init it at 55647 with a derived fixture/runner pair (literal substitution of the runner name only); or
     - (b) a new dir `clusters/s10-c` on a new port (for example 55648) with the same s10b literals, since only the port and data dir are parameters. Add the S10-B lane port 55647 to the preflight "other lanes" fingerprinting, and check `data_directory` as the S10-B binding already does.
  3. Run `prisma generate` for the S10-C head in the clone copy (the client already has `scoutRunSettledBasis` from S10-B; confirm the sha).
- **Unblocks:** a single, well-shaped live proof.

### R27 production-grouping half: adequately proven (no B)
- `stagedPlatformFacts` (facts.service.ts) uses the **same** module-level `resolveFamily` as S9-B `group()`; the old private method is removed. That makes the evaluator's staged partition and S9-B's grouping the same classifier by construction.
- A canonical-family token without a `steps` entry (`row('workouts','w2')`) is counted in `workouts` (coverage spec :288-301). Declared-but-unstaged families are the empty digest (:303-307). Unmapped tokens are skipped (:309-323). Lone surrogates give a `null` digest (:325-329).
- The "forced disagreement → known:false" clause is necessarily evaluator-tier (S10-A). Production `grouped_families` equals the spec keys plus any non-spec family the classifier returns, so it cannot manufacture false agreement.
- See C3 for a doc mismatch.

### C findings
- **C1:** the builder summary says "base HEAD `92b96715` … S10-B's 16 untracked base files". The worktree is at `a2c74e90`, where S10-B is committed, and status shows only the 9 S10-C paths.
- **C2:** in R33 live, `for (const family of basis.report.families)` (rls-g2-s10c.spec.ts:124-127) would pass on an empty array. Add `expect(basis.report.families.length).toBeGreaterThan(0)`. In R36 concurrent, `casWrites.length >= 1` is weak (:230); `count(SETTLED) === 1` and one INSERT carry that test.
- **C3:** the summary says "an unregistered platform yields no staged entry". The code and test yield an entry with `grouped_families: []` and empty `families` (coverage spec :316-320). Either behaviour feeds R25 (known:false), but the doc should match the code.
- **C4:**
  - `settled_at: new Date()` uses the app clock, not DB `now()`.
  - jsonb reorders keys, so a "verbatim" settled report is key-reordered compared with a recomputed one. The same run's status JSON key order can differ from its recomputed form. This is harmless for JSON clients; worth one line in the doc.
- **C5:** `ObservationModule` also provides its own `ScoutLifecycleService` and `JwksVerifierService` instances (see A1). They are stateless apart from caches, so there is no correctness issue.

## Delta review 1 (fix-1: `s10c_fix1.diff`; round-1 table in `s10c_builder_summary.md`)

**Verdict: GO.** A1, B1, B2 and B3 are closed. B4 is the gate/binding builder's item (lane s10-c on 55649, only the s10b+s10c specs, 32 tests) and was not re-reviewed here. I accept the parent decision that the live `complete` half is proven at unit tier by real composition (B2 below) and end-to-end by S11-A2.

This was a read-only review: I read the diff plus the worktree at `worktrees/d3a9-s10c` and ran nothing. The 11 changed paths are the 9 S10-C paths plus `observation.module.ts` and `test/rls-g2-s9c.spec.ts`, both taken under grant per the summary.

| Finding | Status | Evidence |
|---|---|---|
| A1: second PrismaService | **Closed** | `observation.module.ts`: the `PrismaService` import and provider are removed (fix1.diff L673-710). `@Global PrismaModule` is imported by `AppModule` (`src/app.module.ts:32,156`). No spec builds `ObservationModule` standalone (rg), so DI resolution is unchanged for AppModule-based specs. There is a new wiring assertion: `PROVIDERS` lacks `PrismaService`, contains `ObservationService`, and the source has no `prisma.service` (s10c-wiring.spec.ts). |
| B1: R35 vacuous drift | **Closed** | A real drift happens between the reads: `stage(COACH,intentId,'clients','c3')`, a direct SQL insert (g2-s10b-harness.ts:82-93). The discriminators are:<br>• live `staged_unique` goes 2→3 while report-derived `rejected` stays 2, where a recompute would give 3;<br>• `reasons` equal the stored row and counts are `[2]`;<br>• all 9 report keys are byte-equal across reads and match `settledRow().report`.<br>The read-path check is now non-vacuous: exactly 1 basis SELECT, 0 `-- tx:begin` (the worker emits these markers for every interactive tx, g2-s10b-worker.cjs:96-107), 0 `isS9Read` (the same matcher the S9-C spec accepted, rls-g2-s9c.spec.ts:112-113), and 0 writes. The ISOLATION regex is removed. |
| B2: `complete` / exact R23 on real composition | **Closed** | `cleanRun()` builds a native-clean fixture: `plans p1` → owned `workoutProgram`, a ledger row with `reconstructed`/`workout_program`, and `created` provenance. The collector → evaluator → `familyCoverage` → `reconcile` chain is asserted to reach `verdict toEqual {complete, null}`, with `conditions []` and empty families at `observed_unique 0` with a basis (invariant 2). R23 exact: statement `['p1','p9']` → `KNOWN(2,false)` → `toEqual {partial, coverage_basis_unknown}`, `conditions ['coverage_basis_unknown']`. The baseline case now states that its `unresolved_identities` is why it is not `complete`. |
| B3: invariant 6 live | **Closed** | R33 live now asserts that from the tail lock (the last `FOR NO KEY UPDATE` before the CAS) to the CAS there are no writes and no tx marker, and that there are no writes between CAS→INSERT or INSERT→`-- tx:commit`. C2 is also closed: `families.length > 0`, and the weak `casWrites >= 1` is dropped. |

**Residual (C, non-blocking)**
- **C6:** `test/rls-g2-s9c.spec.ts` was edited under the review A-3 grant. Its three superseded assertions are coherent with D-S10-4:
  - the terminal is the last run-row statement, and after it comes exactly one write, the basis INSERT;
  - `basis:'settled'`;
  - status runs with no tx and no S9 read.

  However, that spec **cannot execute at S10 heads**: `g2-s9c-bootstrap.sh:27,31` pins base `5407efae` and 172 migrations. So these edits are unexecuted text. S10-C R33/R35 carry the live proof. The summary's heavy-command lines 160-163 still list `rls-g2-s9c.spec.ts` and `rls-g2-s9.spec.ts`; the S10-C binding should run only s10b+s10c (B4 owner).
- **C7:** review A-1 changed the no-basis fallback so that `readReport` calls `collect(tx, coach, intent)` with no binding (coverage null). This matches D-S10-4 "byte-identical S9 recompute" and has tests at both the lifecycle and collector tiers. No finding.
