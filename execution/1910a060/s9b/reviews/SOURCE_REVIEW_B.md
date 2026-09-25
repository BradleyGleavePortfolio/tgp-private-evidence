# S9-B source review B (T4 independent non-builder, read-only)

Lane EXEC-1910A060 · S9-B reconciliation facts service · reviewer B, independent of reviewer A (no
reviewer-A S9-B artefact existed or was read). Written 2026-09-25 22:1x UTC.

Method: `cat` / `sed` / `rg` / `sha256sum` / `git diff` / `git show` / `git hash-object` only. No file
of the candidate was modified; no test, lint, tsc, prettier or R75 run was executed; no git write; no
remote write. This document is the sole write of this review.

## 1. Subject and hash verification

Candidate worktree `/home/user/workspace/worktrees/1910a060-s9b`, HEAD `1c5fbb0441178e0cfe6e9f8d72e955c645c265e9`
(= base), `git status`: one modified tracked file (the decision doc) + 14 untracked files (10 owned S9-B
files + 4 S9-A copies). Every sha256 below equals SOURCE_READY.md §2.

| File | sha256 (16) |
| --- | --- |
| `src/scout/reconciliation/facts.service.ts` | `828c9d4c23ca1ff5` |
| `src/scout/reconciliation/reconciliation.module.ts` | `f2c1e4476f21830f` |
| `test/scout/reconciliation/facts.service.spec.ts` | `e72fb4b570d862cc` |
| `test/utils/g2-s9-db.ts` | `a1611c51c367fc79` |
| `test/utils/g2-s9-pg-harness.ts` | `8274a85b011f00e6` |
| `test/utils/g2-s9-harness.ts` | `16a5aeac75f189de` |
| `test/utils/g2-s9-worker.cjs` | `5e52b9188cc6a462` |
| `test/utils/g2-s9-bootstrap.sh` | `8452feba381d790f` |
| `test/scout/g2-s9-db-guard.spec.ts` | `307d8fa4a60ae3bc` |
| `test/rls-g2-s9.spec.ts` | `b854fd59ab1cb174` |
| `docs/decisions/2026-09-25-s9-reconciliation.md` (modified) | `2b60cdaa4379259c` |

S9-A dependency copies in the worktree (`types.ts`, `coverage.ts`, `reconcile.ts`, `reconcile.spec.ts`) are
the pre-format S9_A_SOURCE_READY bytes: `git hash-object` gives `bb28f151 / e13c336a / 3932cd3c / df887df5`,
whereas the accepted S9-A commit `be88909f` carries `b7599427 / f50d9401 / bcc85e49 / 11f2a524`. Stripping
layout (whitespace, commas, parens, `|`) the four pairs are token-identical, so every type S9-B imports
(`ReconciliationFacts`, `FamilyFacts`, `IdentityFacts`, `LedgerRowFacts`, `ProvenanceFacts`,
`RelationshipFacts`, `NativeTargetCheck`, `ClaimStatus`, `NATIVE_TARGET_KINDS`) is compatible with the
committed post-format S9-A bytes. See C-7 for the composition consequence.

Base facts confirmed at `1c5fbb04`: S8-C modules imported by the service exist
(`native-contract`, `native-families`, `native-rule-registry`, `persist-outcome`, `source-mapper-registry`,
`mapping-spec`), `RECONSTRUCT_PAGE_SIZE = 500`, `RECONSTRUCT_MAX_ROWS = 10_000`,
`SCOUT_TERMINAL_STATUSES = ['success','partial','failed']`, `scout.module.ts` and
`lifecycle/lifecycle.service.ts` untouched (not in `git status`), 172 migration directories.

## 2. Verification items

### 2.1 Every query is a read

`rg -n "create|update|delete|upsert|executeRaw|queryRaw|\$transaction" facts.service.ts` finds no Prisma
write or raw method and no transaction opened by the service. Observed calls: `scoutImportCompletion.findUnique`
(L691), `scoutIngestEntity.findMany` paged by id cursor (L703), `scoutReconstructionLedger.findMany` paged
(L726), `importNativeProvenance.findMany` (L755), `person / workoutProgram / workoutPlan /
workoutPlanExercise.findMany` by `id IN chunk` (L776-823, `LOOKUP_CHUNK = 1000`). `coverage: null` is a
literal; nothing is persisted (D-S9-3/D-S9-5). The unit double throws on any method outside
`{findMany, findUnique}` (spec L83-116, asserted L640-645); the live proof asserts every logged statement
matches `^(SELECT|BEGIN|COMMIT|ROLLBACK|SET TRANSACTION|DEALLOCATE)` and that row counts and full
ledger/provenance content are unchanged (rls spec L83-135). Verified.

### 2.2 Tenant scoping and RLS interaction

- Run-scoped reads carry `coach_id` + `intent_id` (completion by compound key; staged/ledger pages by both).
  Provenance carries `coach_id` + `source_namespace IN staged platforms` + `entity_type IN mapped families ∪
  {'workouts.exercise'}` (intent-less by S8-B schema; see C-1).
- Native lookups are by `id IN (...)` with **no coach filter**; ownership is compared afterwards
  (`foreign_owner` when `coach_id ≠ coachId`). This mirrors the accepted S8-C `verifyTarget`
  (`native-writers.ts` L61-89). Exposure: the ids come only from the coach's own provenance/ledger rows;
  only the `NativeTargetCheck` classification leaves the module — no native id, name or foreign column is
  emitted into facts. Correctness: the same-tenant check is what makes `foreign_owner` observable at all.
- DB role: the live proof runs the facts worker as `service_role`, which the fixture (and hosted Supabase
  shape) defines `BYPASSRLS` (g2-s9-db.ts L23-25, bootstrap L100-108); the app runtime is likewise
  RLS-bypassing. Tenant isolation is therefore the application `where coach_id`, exactly as for every
  accepted S7-L/S8 reader. All touched tables have `ENABLE/FORCE ROW LEVEL SECURITY` at the base, so if
  the collector were ever run under an RLS-subject role a foreign row would read as `removed` rather than
  `foreign_owner`; both are unresolved states with the same verdict effect. Recorded as C-11.
- The unit spec asserts every non-native call carries `coach_id = COACH` and every native call has
  `where` keys exactly `['id']` (L621-627); the live proof asserts coach B's rows never enter coach A's
  facts and vice versa (rls spec L392-435). Verified.

### 2.3 Single REPEATABLE READ transaction and caller contract

`collect(db: FactsDb = Prisma.TransactionClient, coachId, intentId)` (L94, L244) runs every read on the
client it is handed and opens no transaction itself; `Promise.all` fan-out over an interactive transaction
client is serialised by Prisma and is legal. The caller contract is stated in the module doc and Addendum
A C-9: settle path → inside S8-G's transaction; status path / proof worker → its own
`$transaction(fn, { isolationLevel: 'RepeatableRead' })` (worker.cjs L146-150). The live proof asserts
`BEGIN … REPEATABLE READ … COMMIT` ordering and no write keyword in the log (rls spec L512-521). The
isolation level is therefore a property of the caller, not enforced by the service — consistent with the
addendum's wording "passed in by the caller". Verified as designed; wording note in C-9.

### 2.4 B-2: one edge per declared relationship

- **E-R1** (`program_parent`): emitted iff the accepted interpreter (`mode: 'native'`) derives a
  `programSourceId` for a `workouts`-family row; `to_identity = identityKey(platform, programSourceId)`
  regardless of whether that program was staged. `consistent` requires: own plan (coach match,
  unarchived, ledger target = provenance native id), parent program `present_owned` with
  `plan.program_id === programNativeId`, and `(week_index, day_index)` equal to the derivation. An
  unresolvable parent → edge present, `consistent: false` (unit spec L527-541: unstaged parent
  `B-missing` → one edge, consistent false; L564-571 archived parent → one edge, false; rls spec L350-380
  live: archived program → `consistent: false`). Standalone plan / platform without native rules → no
  edge (L542-548).
- **E-R2** (`child_order`): one edge per non-unresolved child provenance row of `native_kind
  workout_plan_exercise` under a `workouts` parent, `from = to = parent`; consistent iff the exercise
  exists unarchived with `workout_plan_id === ownPlan.id` and, for `#ord:<n>`, `order === n` (unit
  L572-591; live L299-320 with the count tied to the writer's `created` child rows).
- **E-R3** (`client_link`): one edge per interpreted `clientSourceId` for non-`clients` families,
  `consistent: null` (unit L592-606; live L459-470 for a platform without native rules).
- Derivations match S8-DOC: E-R1 from `programSourceId/weekIndex/dayIndex` rule kinds, E-R2 from the
  length-prefixed `<n>:<parent>#id|ord` child identity (`parentSourceIdOf`, exact-prefix parse asserted
  L516-523), E-R3 from `clientSourceId`. The A-review B-2 sentence is implemented as stated. Verified.

### 2.5 R05 ledger-without-staged

Counted run-wide over `(entity_type, source_platform, source_id)` after building the staged key set
(L277-283); attributed to the mapped entry the pair resolves to, creating a zero-identity mapped entry when
the ledger alone evidences the family (`entryFor(true, resolved)`); never dropped when unresolvable (unit
L392-418; live L440-452 with `notes` and `workouts` orphans → 2 run-wide, 1 attributed). Verified.

### 2.6 Grouping: unmapped / unsupported

`resolveStagedFamily` first; else a token equal to a spec-declared family of that platform (S8-C `dispatch`
precedent); else unmapped keyed by raw token with `resolution_reason` `unresolved_family:<token>` or
`unsupported_platform:<platform>` (the former preferred when both occur). Entries are unique on
`(mapped, family)` (B-1 invariant; unit L338-349). `spec_families` is `null` for zero staged rows or any
unregistered platform, else the union of all staged platforms' declared families (unit L350-356, L336;
live L472-478). `ceiling_exceeded` counts rows whose token equals the canonical family (the engine's own
`entity_type = family` count) against `> RECONSTRUCT_MAX_ROWS` (unit L357-365). Verified.

### 2.7 Null coverage, unknown split, no persistence, claim

`coverage: null`; the created/already-present split is left to S9-A (`created_native: null`,
`already_present_verified: null` asserted live L322-330). The claim is `ScoutImportCompletion.terminal_status`
filtered to the closed terminal set — identical to the accepted arbiter read in `lifecycle.service.ts`
L370-389 / L521-529. Nothing persisted. Verified.

### 2.8 Boundedness

Staged and ledger pages are cursor-paged at 500 with early exit; native lookups chunked at 1000; the query
count grows only with page count (unit L629-639; live L484-510 asserts +1 SELECT for 503 rows and a 6-7
SELECT floor/ceiling for the small fixture). The one un-paged read is the coach-wide provenance query
(C-1). No unbounded in-memory structure beyond the run's own rows plus that provenance set.

### 2.9 Spec coverage of the rules and edges

Unit spec: R02/R02b (grouping, step vs canonical tokens, unmapped reasons), R03/R03b (unsupported
platform, `spec_families` null), R04 (removed/foreign/mismatch native states), R05 (three orphan
scenarios), R06/R07 (ledger join and missing row → `null`, out-of-type values not fabricated), R08
(provenance verbatim + child histogram under parent only), R11 (foreign owner, tenancy assertion), R12
(claim filtered), R19 (empty run), B-2 edges E-R1/E-R2/E-R3 including unresolvable parent, read-only,
bounded query count, and composition with the frozen `reconcile`. Live spec: the same over real S8-C rows
plus REPEATABLE READ frame, row-count/content invariance, bounded SELECTs. Coverage is adequate **but the
unit fixture is internally inconsistent with the service's join and would fail — see B-3**.

### 2.10 Module not wired

`reconciliation.module.ts` provides/exports the service and is imported by nothing (`rg
ReconciliationModule src/` → the module file only). `scout.module.ts`, lifecycle hooks, status DTO and
contract generator are untouched. Verified.

### 2.11 Harness, proof guards, binding refusals

- `g2-s9-db.ts`: loopback `127.0.0.1` only, `postgresql:` scheme, database `g2_s9_disposable`, admin user
  `s9_super`, no password in URL, double-entered `G2_S9_CONFIRM = <db>:<port>`, refused ports include
  `5432/5433/6543/54321/54322/55439/54325/55461/55471/55481/55491/55501/55511/55641/55642/55643`; option
  whitelist; candidate head must be 40-hex, ≠ `1c5fbb04`, equal to checked-out HEAD, porcelain clean.
  Pure functions asserted by `g2-s9-db-guard.spec.ts` (6 `it` blocks incl. cross-file pin equality).
- `g2-s9-bootstrap.sh`: refuses unless all five `G2_S9_*` vars set, candidate ≠ base, clean tree,
  descends from base, server on loopback, exact version, role matrix `postgres` NOSUPERUSER BYPASSRLS /
  `service_role` BYPASSRLS / `anon`,`authenticated` NOLOGIN, `prisma` tree unchanged vs base, 172
  migrations, tables owned by `postgres`, no `prisma generate`.
- `g2-s9-worker.cjs`: refuses when `input.root` HEAD ≠ attested head before constructing any client;
  `facts` mode opens the single `RepeatableRead` transaction; query log captures shapes only.
- Binding v1 (`s9b-pg-proof.sh`): `flock -n` on fd 9 of the canonical lock → exit 75 when absent/busy;
  `case … *__*)` refuses (exit 70) while any pin is unfilled — before fixture init/start, so no server is
  started without a fully filled, attested binding; outer bound `timeout -k 30 3900`, per-stage timeouts;
  head/tree/blob/base-ancestor/clean-tree/MERGE_HEAD/lefthook-hooks/accepted-path/frozen-S9-A/isolated
  node_modules checks; `s9b-fixture.sh` refuses standalone use. Pins: the frozen S9-A blob pins in **v1**
  are the pre-format copies and would fail against the accepted `be88909f` bytes — superseded by
  `binding/v2` (verified to pin `b7599427 / f50d9401 / bcc85e49 / 11f2a524`, `PORT=55645`); see C-6.

### 2.12 Addendum A to the landed doc

`git diff` on the doc: exactly `+96 / −0`, hunk `@@ -531,3 +531,99 @@`, appended after the last landed line
("Deployment, customer acceptance … remain owner-reserved"). The added bytes equal
`S9_0_ADDENDUM_DRAFT.md` (sha256 `e0faee18…` on both). No line above the heading changed.

Scope judgment: **in scope as deferred-closure recording, not a reopening.** S9_0_REVIEW.md §8 (RC-1..3) and
§6 (C-5..C-10) explicitly deferred these items "to the doc's next opening"; S9A_ACCEPTANCE carried the
S9-A deviations 2/3/5 and review-A B-2 to be recorded; A.4 records facts rules the text left implicit,
each of which I verified against the code (grouping, R05 attribution, native existence ordering,
coverage/split/no persistence, provenance read shape, claim filter). No D-S9-n decision is changed;
D-S9-2 is re-affirmed as binding in RC-1. Accuracy: A.3 matches the implementation line for line (E-R1
target regardless of staging; E-R2 one edge per created/already-present child; E-R3 `consistent: null`).
One wording nit (C-9): "read-only REPEATABLE READ transaction" — the transaction is not `READ ONLY` at the
SQL level; read-only is by construction and proven by the query-log assertion. Recommend including the
addendum in the commit (`S9B_INCLUDE_ADDENDUM=1`).

## 3. Findings

Classes per the Safety-ROI doctrine: A = block and fix; B = block only the affected proof/gate, fix
minimally; C = record and continue.

### B-1 — R75 banned token `as unknown as` introduced twice (gate-blocking)

- **Where:** `facts.service.ts` L542 `return { status: led.status } as unknown as LedgerRowFacts;`;
  `facts.service.spec.ts` L120 `return db as unknown as FactsDb;`.
- **Defect:** `.github/r75-policy.json` bans `\bas\b{{gap}}unknown\b{{gap}}as\b` across `src/` and `test/`;
  `scripts/check-r75.js` fails when the whole-file after-count exceeds the before-count (L100). Both files
  are new, so net = +2. `lefthook.yml` runs `check-r75.js --mode=staged` in `pre-commit`, so the hooked
  Bradley commit itself is refused; the gate driver's R75 step fails likewise. S9-A's `be88909f` added zero
  occurrences, so this is S9-B's own regression.
- **Concrete harm:** none to product behaviour; the commit and every downstream gate/proof are blocked.
- **Decision blocked:** hooked commit → export → head pins → attestation → PG grant.
- **Minimum closure:** L542 → a single assertion `as LedgerRowFacts` (TypeScript permits it because the
  union is assignable to `{ status: string }`), or narrow via a local type predicate; L120 → build the
  double as `const db = {} as FactsDb;` / `Object.fromEntries(...) as FactsDb` (one assertion). No
  behaviour change, two lines.
- **Execution unlocked:** pre-commit `banned-cast-tokens` passes; B-1 closes.

### B-2 — unused import fails `eslint --max-warnings 0` (gate-blocking)

- **Where:** `facts.service.ts` L8 imports `childSourceIdPrefix`; its only other occurrence is inside a doc
  comment (L72).
- **Defect:** `eslint.config.js` sets `@typescript-eslint/no-unused-vars: 'warn'`; the pre-commit hook runs
  `eslint --max-warnings 0 {staged_files}` → the warning fails the hook. Every other import in the ten
  owned files is used (checked by occurrence count for facts.service.ts, both specs, pg-harness, harness).
- **Concrete harm:** none to behaviour; commit blocked.
- **Minimum closure:** delete `childSourceIdPrefix,` from the import list (keep the comment, or write it as
  plain text). One line.
- **Execution unlocked:** eslint hook passes.

### B-3 — unit-spec fixture stages step tokens while its ledger rows use canonical tokens; the service joins on the raw wide identity, so ~13 of 30 `it` blocks cannot pass (proof-invalidating, fixture-only)

- **Where:** `facts.service.spec.ts` `verifiedPair` L257-260 (`stage('blocks', 'B1')`, `stage('routines',
  'W1')` vs `ledger('programs', 'B1')`, `ledger('workouts', 'W1')`) and the ledger-join test L371-377
  (`stage('routines', W1..W4)` vs `ledger('workouts', W1..W3)`).
- **Defect:** the service joins staged ↔ ledger on `ledgerKey(entity_type, source_platform, source_id)` with
  the raw staged token (L277-283, L329-330), which is D-S9-2's wide identity and matches reality: the S8-C
  engine selects staged rows `WHERE entity_type = family` and writes the ledger with that same token, so a
  staged `blocks` row never has a `programs` ledger row. With the fixture as written `B1`/`W1` get
  `ledger: null`, both ledger rows become `ledger_without_staged`, no `program_parent` edge can be
  consistent, and every provenance/native/composition expectation built on `verifiedPair` is false.
  Affected (by my reading): L369, L422, L443, L456, L465, L498, L549, L564, L572, L610, L649, L664,
  L675 (L479-497 stages and ledgers the same token and is unaffected). The service is correct; the fixture is not. The live proof already stages
  canonical tokens (rls spec L107-109) and is unaffected. The spec's own `joins on token + platform +
  source_id` test (L392-400) passes under either join, so it does not pin the semantics.
- **Concrete harm:** none to product behaviour; the unit suite is red at gate, and — had it been green by
  accident — would have proven the wrong join.
- **Decision blocked:** targeted + default jest gate steps; hence commit/attestation.
- **Minimum closure:** in `verifiedPair` stage `'programs'`/`'workouts'` (2 lines) and in L371-374 stage
  `'workouts'` (4 lines) — the accepted canonical-token convention; keep L292-317 as the step-token grouping
  test (it has no ledger rows and remains valid). I walked the post-fix expectations of `verifiedPair`:
  program `present_owned`; plan `present_owned` with reason `defaulted:type`; E-R1 consistent (`program_id`
  equal, `week:1/day:2` base 1 → `(0,1)` = plan `(0,1)`); L572 child edges `[true,false,false,false]` in
  provenance insertion order; L610 `ledger_without_staged 0`; composition L649 `partial /
  coverage_basis_unknown`. No service change is needed.
- **Execution unlocked:** unit spec runnable; the facts ↔ ledger join is then proven on the documented
  identity in both suites.

### Class C (recorded, continue)

- **C-1 Coach-wide, un-paged provenance read.** `readProvenance` (L755-769) is bounded by tenant history,
  not by intent (S8-B provenance is intent-less at this base). Inside the S8-G settle transaction this is
  the one read whose size the run does not control. Acceptable for M2 (fixture-scale) and truthful (children
  are inherently coach-wide); recommend chunked `source_id IN (…)` for parents once N3-FILL attributes
  provenance to intents, and a measured R16 budget on a populated tenant before the status path ships.
- **C-2 `deriveTemplate` `try/catch → null`** (L667-675) drops a declared E-R1 edge if the interpreter throws
  on a row. The interpreter is total by contract and such a row already carries a `failed` ledger (bucket c
  → `unresolved_identities`), so no `complete` can result; safe direction. Not a banned swallowed-catch form
  under R75 (only `.catch(() => null|undefined|{})` promise forms are banned).
- **C-3 `person` lookups are dead at this base.** The `clients` writer is legacy (string id, `target_kind`
  NULL → bucket f `evidence_only`), so `readPersons` never receives ids. Base behaviour, not an S9-B defect;
  the code path is correct if a native clients writer lands.
- **C-4 Duplicate identity strings.** Two staged rows of one family with the same `(platform, source_id)`
  under different tokens (e.g. `routines/W1` and `workouts/W1`) produce two `IdentityFacts` with one
  `identity` string; `staged_unique` then counts tokens, and S9-A's `verified` set dedups. Marginal; the
  doc's shared-id-space rule makes this a source defect, not a normal case.
- **C-5 Entry order** `family asc, mapped desc` differs from S9-A's mapped-first order; S9-A re-sorts.
  Harmless.
- **C-6 Binding v1 frozen-S9-A pins are pre-format blobs** (`bb28f151…`) and would fail precondition 70
  against an M2 head carrying `be88909f` bytes; `binding/v2/PINS.txt` pins the accepted blobs and
  `PORT=55645`. v1 is history only; the parent must fill and attest v2. Also inherited from S8-C: the
  `flock` is taken before the pin check (lock released on exit 70; no server started) — acceptable.
- **C-7 Composition hazard.** The worktree holds the four S9-A files as untracked pre-format copies; they
  must not be committed by the S9-B commit (they would differ from `be88909f` and, being pre-format, fail
  `prettier --check`). SOURCE_READY §7 says the gate driver asserts S9-A files tracked + clean at the
  post-format shas; I read `gate/PINS.env` SHA lines but did not execute the driver. M2 compatibility
  checked read-only: `1c5fbb04` is an ancestor of `62471b11`; the 17 files changed between them are S8-F
  entities/roster only; `prisma/` unchanged; 172 migrations; none of `facts.service.ts`'s imports change.
- **C-8 Live-proof bounds depend on Prisma query-event wording** (`REPEATABLE READ` match, 6-7 SELECT
  window). The builder flags these as adjustable; they are assertions about the log, not the product.
- **C-9 Addendum C-9 wording** "read-only REPEATABLE READ transaction": not `READ ONLY` at SQL level; the
  service cannot enforce isolation on a passed-in client. Suggest "SELECT-only, REPEATABLE READ (opened by
  the caller)" at the doc's next opening. Not blocking.
- **C-10 `ledger_without_staged` run-wide** includes orphans on unregistered platforms / unknown tokens
  that resolve to no entry (counted, unattributed) — as the doc requires; S9-A trips `unresolved_identities`
  on the run-wide count.
- **C-11 RLS posture** as in §2.2: BYPASSRLS runtime role, application tenancy, id-only native lookups
  mirroring S8-C `verifyTarget`, classification-only egress.

## 4. What this review does not claim

- I did not run tsc, eslint, prettier, jest, check-r75 or any gate; B-1..B-3 are read-derived. Formatting
  churn from `prettier --write` (predicted by the builder) is out of scope and does not alter these findings.
- I did not re-audit S9-0 or S9-A decisions, `reconcile.ts`, or S8-C writer behaviour; S8-C facts quoted
  (engine selection, ledger token, `verifyTarget`, role matrix) were read at `1c5fbb04` only to check S9-B's
  mirroring.
- I did not read reviewer A's S9-B review (none existed in `s9b/reviews/` at start).
- Live-proof expectations that depend on S8-C writer outcomes for the exercise fixture (2 unresolved / 3
  created children) are taken from the spec and not independently re-derived.

## 5. Verdict

**SOURCE GO — conditional on the three class-B closures (B-1 R75 double-casts, B-2 unused import,
B-3 unit-fixture canonical tokens), all source-local, none a design or service change.** The facts
service is read-only, tenant-scoped on the application key with S8-C-precedent native lookups, transaction-
agnostic with a documented caller contract, implements B-2 one-edge-per-declared-relationship with
unresolvable parents failing closure, mirrors S8-C grouping/ceiling/claim semantics, counts orphans
run-wide with resolvable attribution, keeps `coverage: null` and the split unknown, persists nothing, is
not wired into the app, and is guarded by refusal-first harness/binding scripts. Addendum A is append-only,
byte-identical to the reviewed draft, in scope as deferred-closure recording, and accurate (one wording nit,
C-9). Binding **v2**, not v1, is the one to fill and attest (C-6). Class C items C-1..C-11 are recorded for
the parent; none blocks.

---

## Re-review 1 (diff-only, CLOSURES-1) — 2026-09-25 22:2x UTC

Read-only, same method. Read `CLOSURES-1.md`, `closures-1/*`, SOURCE_READY §8, `gate/PINS.env`. Reviewer A's
re-review (`SOURCE_REVIEW_A.md` now exists in this directory) was not opened.

### Only the three named files changed

`git status` in the candidate: still 1 modified tracked file + 14 untracked. sha256 of every owned file now:
`facts.service.ts` `e2f40a794b6cf9aa`, `facts.service.spec.ts` `9dcfbd966757cc12`, doc `be591e977c43fdce`;
the other eight owned files are byte-identical to §1 of this review (`f2c1e447 / a1611c51 / 8274a85b /
16a5aeac / 5e52b918 / 8452feba / 307d8fa4 / b854fd59`). The four S9-A copies are unchanged pre-format bytes
(`eff1479c / c6b224fa / 83d7673b / 99068057`, still not commit-owned per §8). The `closures-1/pre-*` copies
hash exactly to the bytes I reviewed (`828c9d4c… / e72fb4b5… / 2b60cdaa…`), and my own `diff -u pre → worktree`
is byte-identical (after the two header lines) to the published `.diff` files for both TypeScript files; the
doc delta contains only the C-6 and C-9 rewrites. `gate/PINS.env` pins the three new shas and
`DOC_ADDED_LINES=99`.

### B-1 (R75) — closed

`facts.service.ts` default branch now `const passthrough: { status: string } = { status: led.status };
return passthrough as LedgerRowFacts;` inside a `default: { … }` block (satisfies `no-case-declarations`);
spec `client()` now `return db as FactsDb;`. `rg "as unknown as|as any\b|as never|@ts-"` over both files: no
hits (the only remaining occurrence of the phrase is in this review). Both single assertions are permitted by
TypeScript's comparability rule (`LedgerRowFacts` union → `{ status: string }`; `Record<string, any>` ↔
`Prisma.TransactionClient`), read-derived, not compiled here. Behaviour unchanged: an out-of-type status
still reaches S9-A's bucket (k) unrelabelled.

### B-2 (unused import) — closed

`childSourceIdPrefix` removed from the import list; the remaining mention (now L71) is prose in a doc comment.
No other import in the ten owned files changed.

### B-3 (fixture tokens) — closed; negative case meaningful; no assertion weakened

`verifiedPair` stages `programs`/`workouts`; the "attaches failed / skipped / reconstructed" case (L375-378) and
the "unresolved top-level provenance" case (L500) stage `workouts`. Every prior `expect` is intact (35 changed
lines, all in staging calls, comments, the two casts, and the new test). The remaining `routines` / `blocks` /
`people` / `log` stagings (L298-302, 325, 356, 364, 398, 422, 431, 548, 563, 613-616) are the step-token
grouping, unmapped, union, ceiling, orphan, B-2 and client-link cases, none of which joins a step-token staged
row to a canonical-token ledger row, so they were and remain valid.

New negative case (L405-419) `does NOT join a step-token staged row to a canonical-token ledger row for the same
id`: stages `routines/W1`, ledgers + provenances `workouts/W1` → asserts the single identity is
`['routines', identityKey(PLATFORM,'W1'), null]`, family `ledger_without_staged` 1, run-wide 1. Walked against
the service: staged key `routines|p|W1` ≠ ledger key `workouts|p|W1` → orphan → `resolveFamily(p,'workouts')`
→ attributed to the existing mapped `workouts` entry; identity `ledger: null`. This pins exactly the D-S9-2
raw-wide-identity semantics that the pre-closure fixture contradicted, and it would have failed under a
canonical-token join — meaningful, not decorative.

### Addendum A wording — accurate

- **C-6:** the new text ("recognises reason codes by their catalogue prefix and does not validate qualifier
  domains; domain validation before a DTO is an S9-C obligation") matches the accepted `be88909f`
  `parseLedgerReason` (reconcile.ts L53-90): prefix dispatch, a lexical `TOKEN` / `UNRESOLVED_REASON` shape
  check, catalogue `bare|qualified` shape — no membership check against spec family/field/model names. The
  previous sentence over-claimed; the fix is a correction, not a reopening.
- **C-9:** the new text ("opens no transaction and issues only reads; the caller supplies one
  `Prisma.TransactionClient` and is responsible for `REPEATABLE READ`; settle path = S8-G's transaction, which
  also writes the terminal; status path opened by S9-C") matches `collect(db: FactsDb …)`, the module doc and
  worker.cjs L146-150, and removes the "read-only transaction" phrasing I flagged in C-9 above. Accurate.
- Append-only preserved: `git diff --numstat` = `99 0`, single hunk `@@ -531,3 +531,102 @@`, zero deletions;
  added bytes sha256 `6cb90d92…` = updated `S9_0_ADDENDUM_DRAFT.md`.

### New A/B

None. Nothing outside the three files moved; no service logic changed; no guard, harness, binding or proof
file changed. Class-C items C-1..C-11 stand unchanged (C-6/C-7 already reflected in SOURCE_READY §8: v2 is the
binding; S9-A copies not commit-owned; `test/rls-g2-s9.spec.ts` recorded as a parent-granted added path).

### Verdict

**SOURCE GO (unconditional at source level).** B-1, B-2 and B-3 are closed by minimal, behaviour-neutral
edits; the added negative case pins the corrected join semantics; no assertion was weakened; Addendum A is
append-only (+99/−0) and its two rewritten sentences are accurate. Not run by me: tsc, eslint, prettier, R75
checker, jest — these remain the gate's job.

---

## Binding v2 review (reviewer B, independent; read-only; nothing executed)

Scope: `tgp-private-evidence/execution/1910a060/s9b/binding/v2/{s9b-pg-proof.sh,s9b-fixture.sh,PINS.txt,README.md}`
(sha256 prefixes `0633ec92` / `02dd93da` / `84b548f9` / `4de31052`). Compared against `../v1` by `diff`, against
git objects in the read-only clone `/home/user/workspace/growth-project-backend`, against
`execution/1910a060/runtime/RUNTIME_SETUP_RECEIPT.md` + `LOCK_ESTABLISHED.txt`, and against the executed S8-F v2
binding (`execution/64e33dc7/s8f/binding/v2`) as the only precedent bound to the same 1910a060 runtime. Reviewer A's
files were not opened. No git/object writes, no scripts run (the `--version` calls below are read-only binary probes).

### V2.1 What v1 → v2 changed (verified by diff, nothing else)
Runner: header, `PORT=55645`, `BASE_HEAD/BASE_TREE=__FILL_M2__`, `$BASE_HEAD$BASE_TREE` appended to the L88 fill
`case`, S9-A pins → be88909f post-format blobs (L115-119). Fixture: `PORT=55645` (L10 comment, L25). PINS: same three
deltas. README claim "nothing else" holds.

### V2.2 Verified pins and invariants
| Check | Result |
|---|---|
| Refusal while unfilled | L88 `case … in *__*)` covers all 20 pins incl. `BASE_HEAD`/`BASE_TREE` → `fail 70`. Ordering note: refusal happens after the flock (L71) and START log line (L86) and `finish` writes the sentinel → a premature invocation consumes the once-only sentinel (inherited S8-C design; operator must not invoke before fill). |
| Accepted-path blobs/trees (13) | All 13 `ACCEPTED_*` values equal `git rev-parse` at **both** 1c5fbb04 and 62471b11: `2e328bbc 654550cb 44c96915 c4ae4b8e c345dd54 711bfb09 a7d67217 4059883d 1a8f1797 7c3fba47 48403063 c3fc6bde 9d701783`. |
| Migrations | `git ls-tree 62471b11 prisma/migrations/` → 172 tree entries (+ `migration_lock.toml`, `rls_fitness_backend.sql` blobs); runner identity asserts `count=172` applied (L178). |
| Schema / lockfile | `git show 62471b11:prisma/schema.prisma | sha256sum` = `0eb41f9a…` = `EXPECT_SCHEMA_SHA`; `package-lock.json` blob `354de3da`, sha256 `b7fed5ed…` = `EXPECT_PKG_LOCK_SHA`; receipt §3 records the same. |
| S9-A blobs | `b7599427 f50d9401 bcc85e49 11f2a524` = be88909f post-format (already verified in §2 of this review vs `1910a060-s9a`). |
| M2 / predicted tree 737c34a3 | Not verifiable read-only (no M2 object on disk; 62471b11 tree is `23614f0b`). Acceptable: the runner re-derives `BASE_TREE == rev-parse BASE_HEAD^{tree}` (L93) and `merge-base --is-ancestor` (L94) at run time, so a wrong fill fails closed. |
| Runtime tool pins vs receipt/disk | `pg17/dist/bin/{postgres,initdb,pg_ctl}` on disk = `23cd1748… b7db9bc2… af53d826…` = receipt = PINS "prior record" comparison values; `postgres --version` = 17.6; `pg17/PROVENANCE.txt` has `result=success`; node `/usr/local/bin/node` v20.20.1 `a03953a7…` = receipt; nm-lock `05bc530a…` and client `9042e713…` per receipt §4 (not re-hashed: the s9b worktree has **no** `node_modules` yet — runner L124 will refuse until the donor copy exists). `RUNTIME_ROOT` per receipt = `/home/user/workspace/execution/1910a060/runtime` (exists; contains `pg17 npm-cache xdg-cache tools proof-s8f-v2`, no `clusters/`). |
| psql | `/usr/bin/psql` → `readlink -f` = `/usr/share/postgresql-common/pg_wrapper` (`a200e38c…`, perl dispatcher). Real 18.6 binary `/usr/lib/postgresql/18/bin/psql` = `d1108fdb…`, `psql (PostgreSQL) 18.6`. Receipt §4 designates the real binary as "binding v2 pin, CB1". **See B-v2-3.** |
| Port | `55645` in runner L57, fixture L25, PINS, guard spec example/ack (L13-14,21-22; 55646 mismatch probe). `g2-s9-db.ts` REFUSED_PORTS contains 55641/55642/55643 (not 55644 — see C-v2-1). 55643 is the retained S8-F v2 lane on this runtime; no other binding under 1910a060 pins 55645. |
| Lane dir / cluster marker | Marker `s9-disposable-pg17` identical in runner (L159,175), fixture (L25), `g2-s9-db.ts`; DB marker literal L177 matches bootstrap. Lane **paths are inconsistent** — see B-v2-2. |
| Lock | `LOCK=/home/user/workspace/execution/test-validation.lock`; on disk inode **667698** = `LOCK_ESTABLISHED.txt`; `exec 9>>` + `flock -n 9` (L71), never deleted; fixture is lock-free and closes fd 9 for children (`9>&-`, L36) and refuses standalone use unless `S9B_RUNNER_PID` is a live `s9b-pg-proof.sh` (L31-32). |
| Once-only sentinel | L69 refuses if `$SENT` exists (rc 76); `finish` always writes it (L78). |
| Read-only assertions | Worktree porcelain sha before/after (L155/L199), HEAD unchanged, generated client unchanged (L200), other lanes' `postgresql.conf`/`pg_control` hashes unchanged (L150-153/L194-197), prisma tree == base (L106), no sidecar dir (L122). Fixture `init` refuses an existing data dir (L48), `start` refuses an unmarked cluster (L71), `destroy` is marker-gated and never invoked by the runner (data dir retained, L189). |
| Bounded stop | Stage timeouts 60/60/900/15×5/1500/75 (+`-k 30`); fixture stop `pg_ctl -m fast -w -t 45` (`S9B_STOP_TIMEOUT`), survivor pid reported (L77, L83); post-stop asserts `pgrep -cx postgres`=0, no listener, no `postmaster.pid`, data dir present (L189). |
| Prod URLs / secrets | `rg supabase|pooler|amazonaws|https?://|5432|6543` over the four files → no hits (only the PROVENANCE Maven URL lives outside the binding). Password passed via `PGPASSWORD`, never in a URL (L172). |
| Expected Tests count | **Absent** — see B-v2-4. `test/rls-g2-s9.spec.ts` has 10 `it(` in 4 `describe(` (no `it.skip`/`it.each`/`test(`). |

### V2.3 Findings

**B-v2-1 — runner `D` still points at `binding/v1` (L28).** `FIX=$D/s9b-fixture.sh`, `R=$D/run`, `LOG/SENT/JLOG` all
resolve into the immutable v1 directory. Harm: the fixture-sha precondition (L90) hashes the **v1** fixture
(`6fb78034…`, PORT unfilled) against a pin filled from the v2 fixture → guaranteed `fail 70` after the lock is taken,
with log + sentinel written into `v1/run/` (contaminates history, burns the once-only sentinel for a path nobody
intends to run). If instead the pin were filled from the v1 fixture, v1 refuses at L30 (PORT unfilled, rc 2). Either
way the v2 proof cannot succeed as written. Decision: NO-GO until fixed. Min closure: `D=…/s9b/binding/v2`; also fix
the stale `binding/v1` mentions at runner L19 (usage) and L44 (comment), fixture L5, PINS L1/L28 comment (fixture sha
`6fb78034…` is v1's; v2's is `02dd93da…` and will change again with the closures).

**B-v2-2 — fixture `RUNTIME_ROOT` is the absent predecessor root (fixture L22
`/home/user/workspace/execution/64e33dc7/recovery-reset`; comments L12-14).** The runner's `RUNTIME_ROOT` is
`__FILL_FROM_RUNTIME_RECEIPT__` (→ `/home/user/workspace/execution/1910a060/runtime`), so runner
`LANE=$RUNTIME_ROOT/clusters/s9-b` and fixture `LANE`/`SOCK`/`PGHOME` disagree; the runner's INIT marker grep
(L159, `data=$LANE/pg-data`) can never match the fixture's echoed `$DATA`. Receipt §1 states the 64e33dc7 root does not
exist on this host, so in practice the fixture exits 2 at L33 (`pg_ctl` missing) before `mkdir -p` — a safe failure,
but the lane-dir/cluster consistency the parent asked for does not hold. Min closure: fixture L22 =
`/home/user/workspace/execution/1910a060/runtime` (the same literal the runner fill will carry), update L12-14
comments; recommended cheap guard in the runner preconditions:
`grep -qx "RUNTIME_ROOT=$RUNTIME_ROOT" "$FIX" || fail 70` (S8-F v2 kept the two literals equal by construction).

**B-v2-3 — psql pin targets the pg_wrapper dispatcher, not the 18.6 binary (runner L137, L64, L172; PINS L26
comment `readlink -f /usr/bin/psql`).** `readlink -f /usr/bin/psql` resolves to the perl `pg_wrapper`
(`a200e38c…`), whose dispatch target depends on postgresql-common configuration at run time. The receipt fills
`EXPECT_PSQL_SHA` with the real binary `d1108fdb…` ("binding v2 pin, CB1"); with that fill L137 fails 70 on every
run; with the wrapper sha the binding pins the wrong artifact and asserts nothing about 18.6. Min closure (mirror S8-F
v2 L49-50/L144-145): `PSQL=/usr/lib/postgresql/18/bin/psql`; `[ -x "$PSQL" ] && [ "$(sha "$PSQL")" = "$EXPECT_PSQL_SHA" ]`;
`"$PSQL" --version | grep -qE '^psql \(PostgreSQL\) 18\.'`; use `$PSQL` for `G2_S9_PSQL` (L64) and `psqlq` (L172);
fix the PINS comment.

**B-v2-4 — no expected `Tests:` count assertion (L183-185).** Jest rc 0 alone accepts `Tests: 10 skipped` or a
partially matched file; the proof's strength depends on all 10 cases executing. S8-F v2 (L58/L197) pins
`EXPECT_TESTS` and greps `^Tests: +N passed, N total`. Min closure: `EXPECT_TESTS=10` (the `it(` count at the attested
head — re-grep after the hooked commit; the L88 `case` need not include it) and
`grep -qE "^Tests: +$EXPECT_TESTS passed, $EXPECT_TESTS total" "$JLOG" || fail 72` after L185.

Class C (recorded, no closure required for one run):
- C-v2-1: `g2-s9-db.ts` REFUSED_PORTS omits 55644 and its comment calls 55643 "S8-G" while S8-F v2 runs on 55643 on
  this runtime. Committed-code nit, not binding; the literal 55645 plus `G2_S9_CONFIRM` double entry mitigate.
- C-v2-2: the other-lane scan (L150-153/L194-197) walks `$RUNTIME_ROOT/clusters/*/` only; the retained S8-F lane lives
  at `$RUNTIME_ROOT/proof-s8f-v2/clusters/s8-f` and is not covered by the "unchanged/never started" invariant. Live
  servers are still caught by `pgrep -cx postgres`=0 and the port check. Suggest adding that path to both loops.
- C-v2-3: a refused run (unfilled pins, tool mismatch) still consumes the once-only sentinel and writes RECEIPTS —
  inherited S8-C semantics, acceptable, but the grant must say "fill, attest, then invoke exactly once".
- C-v2-4: `BASE_TREE` predicted `737c34a3` cannot be checked here; runtime L93/L94 make a wrong fill fail closed.
- C-v2-5: the s9b worktree has no `node_modules`; L124-129 will refuse until the donor copy (receipt §Donor-copy step
  1) lands and `EXPECT_NM_*` are filled from it.
- C-v2-6: fixture header L5 names the v1 runner path, but its runner check is by `/proc/<pid>/cmdline` grep of
  `s9b-pg-proof.sh`, so it is path-agnostic; cosmetic once B-v2-1 is fixed.

### V2.4 Verdict
**NO-GO for the v2 files as they stand**; **GO-for-one-run-after-fill** once B-v2-1..B-v2-4 are applied (as a v3 or an
in-place v2.1 with template→filled diff + BINDING.sha256 per PINS doctrine) and the head/runtime/tool/M2 pins are filled
from the attested hooked head and the runtime receipt. None of the four defects can damage data or another lane — each
fails closed — but B-v2-1/B-v2-2/B-v2-3 make a successful run impossible and B-v2-4 weakens what a success would prove.
Everything else the parent listed (refusal while unfilled, 13 accepted-path pins at both bases, 172 migrations, schema
`2e328bbc`/`0eb41f9a`, lockfile `b7fed5ed`, PG17.6 binaries, node 20, lock inode 667698, once-only, read-only and
bounded-stop assertions, no prod URLs) verifies. Not read: reviewer A. Not run: any script.
