# S9-B source review A (T4 independent non-builder, read-only)

- Reviewer: A (subagent, independent of B-NEW-1; reviewer B's output not read).
- Subject: uncommitted S9-B reconciliation-facts candidate in `/home/user/workspace/worktrees/1910a060-s9b` (HEAD `1c5fbb0441178e0cfe6e9f8d72e955c645c265e9`, branch `exec1910/s9b`, 1 modified doc + 10 untracked owned files + 4 read-only S9-A copies).
- Method: `cat` / `sed` / `rg` / `sha256sum` / `git diff` / `git show` only. No `npm`, `jest`, `tsc`, `prettier`, lock or git writes. Nothing remote touched.
- Sole write: this file.

## 0. Verification of the evidence bundle

| Check | Result |
|---|---|
| 15 sha256s in `s9b/SOURCE_READY.md` (10 owned, doc, 4 S9-A copies) vs worktree | all match |
| `git diff docs/decisions/2026-09-25-s9-reconciliation.md` (+96/-0) vs `S9_0_ADDENDUM_DRAFT.md` | byte-identical (added lines == draft) |
| S9-A copies (`types.ts`, `coverage.ts`, `reconcile.ts`, `reconcile.spec.ts`) vs committed `be88909f` | `diff -w` shows layout-only (prettier wrapping) differences; every type `facts.service.ts` imports exists in committed `types.ts` |
| `EXPECTED_MIGRATIONS = 172` (`g2-s9-pg-harness.ts`) vs `git ls-tree 1c5fbb04 prisma/migrations/` | 172 (S8-C pinned 171; S8-G added one) |
| `g2-s9-db.ts` vs accepted `g2-s8c-db.ts` | literal-substitution derivative; only substantive change is `55642`, `55643` added to `REFUSED_PORTS`; lane port still not hard-coded, double-entered `<db>:<port>` confirmation kept; candidate-head binding (`G2_S9_BASE_HEAD` refused, clean tree required) kept |
| Binding `binding/v1/{PINS.txt,s9b-pg-proof.sh,s9b-fixture.sh}` | unfilled template (`__FILL_*__` pins; runner refuses while any pin unfilled); cluster marker `s9-disposable-pg17` and DB comment marker consistent across `g2-s9-db.ts`, bootstrap and fixture script; accepted-path blobs pinned; nothing executed |
| R75 lexical scan of candidate (`.github/r75-policy.json` tokens) | **2 hits** — see B-2 |

## 1. Findings

Classes per `OWNER_SAFETY_ROI_AND_EXECUTION_DOCTRINE.md`: A = harm/irreversible, B = proof-invalidating or gate-blocking (product may be right, evidence cannot show it / cannot land), C = record.

### B-1 — Unit spec fixture cannot pass against the candidate (staged step tokens vs canonical ledger tokens)

- Where: `test/scout/reconciliation/facts.service.spec.ts` `verifiedPair` (L257-260) stages `blocks`/`routines` but writes the ledger rows under `programs`/`workouts`; same pattern in the ledger-join case L369-390 (`stage 'routines'` + `ledger 'workouts'`).
- Code: `facts.service.ts` L275-283, L329-330, L395-396 join staging to ledger on `ledgerKey(row.entity_type, source_platform, source_id)` using the **raw staged token**, exactly D-S9-2's wide identity `(coach_id, intent_id, entity_type, source_platform, source_id)` (schema unique, L6996). `routines|P|W1` never equals `workouts|P|W1`.
- Consequence under the code as written: every `verifiedPair` identity gets `ledger: null` (bucket b), both ledger rows become `ledger_without_staged`, and the following cases fail: L369, L422, L443, L456, L465, L498, L549, L564, L572 (child edges still emitted but composition assertions differ), L610 (`ledger_without_staged` would be 2, not 0), L649, L664, L675 — roughly 12 of 31 cases. The spec is also internally inconsistent: L392 ("joins on token + platform + source_id") stages `routines` and ledgers `routines`, i.e. assumes the token join the other cases contradict.
- Which side is right: the **code**. D-S9-2 fixes the wide-identity join; the S8-C engine only ever processes staged rows whose `entity_type == family` and writes the ledger row with that same value (`native-families.ts` L83 "accepted fixtures stage the CANONICAL"); the S9-B PG proof (`g2-s9-harness.ts` `stage()` comment L118, `rls-g2-s9.spec.ts` L108-110) stages canonical tokens. A step-token row with a canonical-token ledger row is a shape S8-C cannot produce.
- Harm: none to product; the gate (`jest`) would fail visibly, so nothing is masked. Decision blocked: "unit bundle attributable and green" precondition of the hooked commit; the candidate cannot be committed as is.
- Minimum closure (fixture-only, no product change): in `verifiedPair` and the ledger/provenance/edge/composition cases, stage the canonical tokens (`programs`, `workouts`) as the PG proof does, or write the ledger rows under the staged token. Keep exactly one explicit case asserting that a step-token staged row does **not** join a canonical-token ledger row (documents the wide identity). Grouping cases that stage step tokens without ledger rows (L292-317, L527-548, L592-606) are unaffected.

### B-2 — R75 banned tokens in the candidate (`as unknown as`)

- Where: `src/scout/reconciliation/facts.service.ts` L542 `return { status: led.status } as unknown as LedgerRowFacts;` and `test/scout/reconciliation/facts.service.spec.ts` L120 `return db as unknown as FactsDb;`.
- `.github/r75-policy.json` lists `as unknown as` (`\bas\b{{gap}}unknown\b{{gap}}as\b`) as a banned token over `src/` and `test/` including `.ts`; `scripts/check-r75.js` runs in the hook and the gate. Both occurrences are deterministic failures; the builder's `CODE_READ_NOTES.md` names both casts as "verify at gate time" but did not check the policy.
- Harm: none to product; the hooked commit is refused. Decision blocked: same as B-1.
- Minimum closure: L542 — surface the out-of-type status without the double cast, e.g. a single comparable assertion `{ status: led.status } as LedgerRowFacts` (string→literal-union members are comparable) or a narrow helper returning `LedgerRowFacts` built from a `string`-typed status; the purpose (let S9-A's bucket (k) `reason_unrecognised` catch an unknown status rather than relabel it) must be kept. L120 — type the fake as `Partial<Record<keyof FactsDb, unknown>>`/a structural stub and cast once, or construct the client through `Object.assign` to a typed shell. `tsc` at gate decides the exact form; any form free of the banned tokens is acceptable.

### C items (recorded, none blocking)

- **C-1 Native existence by id without a coach filter — role dependence.** `facts.service.ts` looks up `person/workoutProgram/workoutPlan/workoutPlanExercise` by `id` only (chunked ≤1000), then compares `coach_id` (S8-C `verifyTarget` precedent, `native-writers.ts` L66-89; unit spec L621-626 pins the shape). Ids come only from this coach's own coach-scoped provenance rows whose ledger row agrees on `(target_kind, target_id)`; only the classification leaves the module, `ownPlan` requires a `coach_id` match before `program_id`/week/day are consulted, and E-R2 requires `exercise.workout_plan_id === ownPlan.id`. No arbitrary-id oracle and no foreign field exposure. Under `service_role` (BYPASSRLS; the proof's runtime role per `g2-s9-db.ts` L19 and the policy comments on `Person`/`WorkoutProgram`) foreign rows are observable, so `foreign_owner` (bucket h) is reachable and R11 is proven as written. If a deployment ran the reader under an RLS-restricted role, the foreign row would be invisible and classified `removed` (bucket i) instead — same `unresolved` outcome and verdict, only the reason-histogram key differs (safe direction). Record as a stated assumption (runtime role = service_role) in the S9-C wiring, not an S9-B defect.
- **C-2 Provenance read is coach-wide, not intent-scoped.** One `findMany` on `ImportNativeProvenance` by `(coach_id, source_namespace ∈ staged platforms, entity_type ∈ mapped families ∪ 'workouts.exercise')` with no `take`; `import_intent_id` is nullable in the schema so intent filtering is not possible. Bounded per coach, but grows with a coach's whole import history (all exercise children across runs). Acceptable for the settle path; the S9-C status recompute-on-read should note it against G15/R16 (query count is bounded, row volume is not). Addendum A.4 states the read scope accurately.
- **C-3 Addendum C-6 sentence overstates accepted S9-A.** "The reason parser validates qualifier domains (family, field and model names from the spec)" — committed `reconcile.ts` L67-90 `parseLedgerReason` validates qualifier **shape** only (`TOKEN` `[A-Za-z0-9_.-]{1,64}`), not domain membership. As written the addendum records a rule the accepted S9-A code does not meet, which would reopen S9-A. Minimum closure before the doc hunk commits: reword to "validates the code prefix against the §3.7 catalogue and the qualifier shape (`[A-Za-z0-9_.-]{1,64}`); domain membership of qualifiers is not asserted in v1".
- **C-4 Addendum C-9 wording.** "single read-only `REPEATABLE READ` transaction" is true for the proof worker (`g2-s9-worker.cjs` L142-145 opens `isolationLevel: 'RepeatableRead'`) and the intended status path, but the settle path inherits S8-G's transaction isolation (the addendum's own parenthesis says so). "Read-only" is by discipline (only `findMany`/`findUnique`; PG proof asserts SELECT-only log and unchanged watched tables), not `SET TRANSACTION READ ONLY`. Reword: "one transaction whose isolation the caller sets (`REPEATABLE READ` on the status path; S8-G's on settle); the service issues reads only".
- **C-5 `test/rls-g2-s9.spec.ts` is not in D-S9-8's S9-B writable-path list.** `jest.rls.config.js` matches `test/rls-*.spec.ts` and S8-C's precedent was `test/rls-g2-s8c.spec.ts`, so the location is right and necessary for the PG proof; it is a path-list deviation for the parent's grant to record, not a code issue.
- **C-6 Addendum scope.** All Addendum A items trace to what `S9_0_REVIEW.md` deferred to "the doc's next opening" (RC-1..3, C-5, C-6, C-7 second half, C-9, C-10), `S9_A_SOURCE_READY.md` deviations 2/3/5 and `S9_A_REVIEW_A.md` B-2 (grant to S9-B). It is append-only (+96/-0), amends by line reference, and does not alter D-S9-1..8 decisions. In scope under SCOPE.md B-NEW-1 "carried addendum obligations", subject to C-3/C-4 wording. Whether the hunk commits with S9-B or is handed to the parent (`SOURCE_READY.md` `git checkout --` option) is the parent's call.
- **C-7 Unresolved child histogram keys are echoed verbatim** (`child.reason ?? 'unresolved:reason_unrecognised'`) and S9-A does not catalogue-filter `unresolved_children` (S9-A review B C-1). Provenance reasons are written only by S8-C from `UNRESOLVED_CODE`, so exposure is bounded to accepted code strings; the S9-C catalogue-equality spec the addendum promises closes it.
- **C-8 Missing-child gap (doc-conformant).** A child the writer never recorded (no provenance row at all) yields no E-R2 edge and cannot be detected; A.3 "one edge per created or already-present child provenance row" states exactly this. Record for S9-C consumers.
- **C-9 Re-interpretation drift.** E-R1 derivation re-runs the interpreter at read time against the current registry; if the spec/rules changed between write and read, an edge may be declared or omitted differently from what S8-C wrote. Safe direction (a spurious edge fails closure → `relationship_unverified`), never a fabricated verified.
- **C-10 Parent from an earlier run.** A `programs` parent staged in a previous intent is not bucket j in this run, so the E-R1 edge is `consistent: false` and C-REL fires — a false "unverified", the S9-A design's accepted conservatism (S9-A review deviation 5).
- **C-11 Comment typo.** `binding/v1/s9b-pg-proof.sh` L62 "Nothing G2_S9_*, G2_S8B_*…" should read `G2_S8C_*`.
- **C-12 Spec title L392** ("joins on token + platform + source_id") becomes accurate only after B-1's fix; keep it as the one negative-join case.

## 2. Focus-question answers

- **Read-only guarantee.** `facts.service.ts` uses only `findUnique`/`findMany`, opens no transaction, takes a `Prisma.TransactionClient`. Unit spec L640-645 (fake throws on any non-read method) and PG proof `collect()` (SELECT/BEGIN/COMMIT/SET TRANSACTION/DEALLOCATE only; watched-table counts and full ledger/provenance content unchanged) both prove it, once B-1 makes the unit spec runnable.
- **Tenant scoping.** Staging, ledger, provenance and claim reads are all `coach_id`(+`intent_id`) scoped (unit L621-626 asserts it per call; PG R11 case checks cross-tenant facts both ways). Native lookups are id-only by precedent — see C-1.
- **Single snapshot.** Caller's responsibility; proof worker uses `RepeatableRead`; PG case L520-528 asserts `BEGIN … REPEATABLE READ … COMMIT` with no writes. Wording issue only (C-4).
- **B-2 closure correctness.** One edge per declared relationship instance: E-R1 iff interpreter (`mode: 'native'`) yields `programSourceId`; target is the programs identity whether staged or not; `consistent` only if `ownPlan.program_id` equals the parent's verified native id (parent must be present_owned with non-unresolved provenance) and `(week_index, day_index)` match. E-R2 one per created/already_present child row, `consistent` iff unarchived exercise on `ownPlan` with matching `#ord`. E-R3 `consistent: null`. Unstaged target → S9-A `verifiedByFamily.get(to_family)?.has(to_identity) !== true` → unverified (no crash). Matches Addendum A.3 and closes S9-A review A B-2.
- **R04/R05/R11/RC-3.** PG cases L350-391 (archived program + deleted plan → `removed`, edges emitted and inconsistent, `unresolved:native_target_removed`), L434-448 (2 orphans, attributed to `workouts`, report `ledger_without_staged: 2`), L393-431 (`foreign_owner`, `provenance_mismatch`, tenant symmetry), L450-491 (three unmapped entries with reasons, `spec_families: null`, `required_families: null`, verdict `partial/unresolved_family`) derive the rules directly from the code paths I read; the expectations agree with the code.
- **No fabricated zeros.** `coverage: null`; `ledger: null` when no ledger row; `claim: null` outside the closed terminal set; `spec_families: null` on an unregistered platform. Ceiling flag mirrors the S8-C `count(coach,intent,entity_type)` > `RECONSTRUCT_MAX_ROWS` check per token.
- **Bounded queries.** Staged and ledger paged by id cursor (`take: 500`, stop when `page.length < 500`); one provenance read; native lookups chunked; PG case expects 6-7 SELECTs and +1 for 503 staged rows — consistent with the loop. Row volume of the provenance read: C-2.
- **Composition with frozen S9-A.** Types imported from committed `be88909f` `types.ts` all exist; `reconcile(facts)` is called unchanged in the unit spec and the worker; S9-A copies differ from committed only by formatting.
- **Harness guards.** Refused ports include the S8-C (55642) and S8-G (55643) lanes; lane port double-entered, not hard-coded (guard spec uses 55645 example, 55646 probe); cluster and DB markers pinned as literals; candidate-head binding requires clean tree at the attested head and refuses the base; worker re-checks `git rev-parse HEAD` of its root. Faithful S8-C derivative.
- **Addendum A.** In scope and append-only; two accuracy fixes required before the hunk commits (C-3, C-4).

## 3. Verdict

**SOURCE NO-GO as-is** — two class-B, gate-blocking defects with small, local, deterministic closures; **no class-A finding**. The product read path (`facts.service.ts`) is read-only, tenant-scoped by the accepted precedent, doc-conformant on the wide-identity join, fabricates no zeros, and composes with the frozen S9-A.

Re-review needed after closure: diff-only over (a) the unit spec fixture/cases changed for B-1, (b) the two cast sites for B-2, (c) the C-3/C-4 wording in the doc hunk. No re-read of the harness, PG spec, binding or the rest of `facts.service.ts` is required if their sha256s are otherwise unchanged. With B-1, B-2 and C-3 closed, my expectation is SOURCE GO.

## Re-review 1 (diff-only, after CLOSURES-1) — 15:2x PT

Scope: parent's diff-only request. Read-only (`sha256sum`, `diff`, `rg`, `git status/diff --stat`). Reviewer B's re-review not read. `binding/v2`, `gate/` scripts and `SOURCE_READY.md` §8 prose were not reviewed beyond the hash lines quoted below.

### Byte accounting

- `closures-1/pre-*` sha256s equal the bytes I reviewed: `facts.service.ts` `828c9d4c…`, `facts.service.spec.ts` `e72fb4b5…`, doc `2b60cdaa…`.
- Current worktree: `facts.service.ts` `e2f40a79…`, `facts.service.spec.ts` `9dcfbd96…`, doc `be591e97…` (`git diff --stat`: +99/−0) — as announced, and as pinned in `CLOSURES-1.md` L9-11 and `gate/PINS.env` (`SHA_FACTS_SERVICE`, `SHA_FACTS_SPEC`, `SHA_DOC_ADDENDUM`).
- The other 12 files (module, rls spec, guard spec, bootstrap, db, harness, pg-harness, worker, 4 S9-A copies) hash exactly as in my first review / `SOURCE_READY.md` §2. `git status` shows the same 1 modified + 9 untracked paths; nothing else changed. Only the three announced files moved.

### `diff pre → current`

`facts.service.ts` (2 hunks):
1. Import list drops `childSourceIdPrefix` — it was imported but referenced only in a comment (L71) in the pre bytes; removing it clears an unused import. All remaining imports are referenced at least once outside the import block (checked per symbol).
2. L539-544: `default:` now builds `const passthrough: { status: string } = { status: led.status }` and returns `passthrough as LedgerRowFacts`. Semantics identical to before (an out-of-type ledger status still reaches S9-A's bucket (k) unrelabelled); one comparable assertion, no `unknown` hop. **B-2 closed at this site.** `tsc` at gate confirms comparability; the form is acceptable.

`facts.service.spec.ts` (5 hunks):
1. L120 `return db as FactsDb;` (single assertion from `Record<string, any>`). **B-2 closed at this site.** R75 scan of both files for `as unknown as` / `as any` / `as never` / `@ts-ignore` / `@ts-expect-error`: no hits.
2. `verifiedPair` stages `programs`/`workouts` (canonical), with a comment pointing at the negative case. **B-1 closed** for every case built on `verifiedPair` (buckets g-j, edges, tenancy, composition).
3. L375-378 ledger-join case stages `workouts` W1..W4 — matches its `workouts` ledger rows; expectations unchanged.
4. L405-419 **new negative case** "does NOT join a step-token staged row to a canonical-token ledger row for the same id": stages `routines/W1`, writes a `workouts/W1` reconstructed ledger row *and* a matching provenance row, asserts the staged identity is `['routines', key(W1), null]` and `ledger_without_staged` is 1 at both family and run level. Meaningful: it is precisely the B-1 shape, it asserts the orphan is attributed (not dropped) and that provenance alone cannot rescue the join. It pins D-S9-2's raw wide identity.
5. L500 unresolved-provenance case stages `workouts` (was `routines`) to match its `workouts` ledger/provenance rows; expectations unchanged.

Remaining step-token stagings (`routines`/`blocks` at L298, L300, L325, L356, L364, L398, L409, L422, L431, L548, L563, L613, L616) either have no ledger rows, use a same-token ledger row (L398 `routines`/W2), or expect the orphan (L422, L431, L409). All consistent with the code's join. No `expect` was removed or loosened anywhere in the diff; the diff adds one case and changes fixture tokens only.

Doc (2 hunks, both inside Addendum A; landed text still untouched, +99/−0):
- **C-6** now reads: the accepted S9-A parser "recognises reason codes by their catalogue prefix and does not validate qualifier domains; validating the qualifier against the spec's family, field and model names before anything reaches a DTO is an S9-C obligation, recorded here, not a property of the landed reconciler." Accurate against committed `reconcile.ts` L67-90 (prefix + `TOKEN` shape). **C-3 closed.** (Minor: "does not validate qualifier domains" is true; it does validate qualifier *shape* — omission, not misstatement.)
- **C-9** now reads: the facts service "opens no transaction and issues only reads; the caller supplies one `Prisma.TransactionClient` and is responsible for running it at `REPEATABLE READ` … On the settle path that transaction is S8-G's (which also writes the terminal); on the status path S9-C opens one for the read." Matches `facts.service.ts` and `g2-s9-worker.cjs` L142-145. **C-4 closed.**

### New A/B introduced?

None. The product change is a type-level rewrite of one return statement plus an import removal; no query, filter, classification or edge logic changed (confirmed by the 2-hunk diff). Spec changes are fixture tokens and one added case. Doc changes are wording within the addendum.

### Carried C items

C-1, C-2, C-5, C-7..C-12 stand as recorded (none blocking). C-5 is now acknowledged in `SOURCE_READY.md` §8 as a parent-granted path. New C-13: `SOURCE_READY.md` §8 declares `binding/v1` historical and `binding/v2` the binding; `binding/v2` was not part of this diff-only re-review and needs its own read before the PG-proof grant.

### Verdict

**SOURCE GO** on the three re-pinned files (`e2f40a79…`, `9dcfbd96…`, `be591e97…`) together with the 12 unchanged files at their §2 hashes. B-1, B-2, C-3 and C-4 are closed; no assertion weakened; no R75 banned tokens or unused imports remain in the changed files; no new A/B. Gate (`tsc`, `jest`, `check-r75`, lint) remains the arbiter of the two single assertions compiling — if `tsc` rejects either, the fix is local and does not reopen this review.
