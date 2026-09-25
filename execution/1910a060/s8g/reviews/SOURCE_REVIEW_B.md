# S8-G source review B (T4 independent, read-only)

Reviewer B, execution 1910a060, 2026-09-25 (PDT). Independent of reviewer A; reviewer A's output was not read.
Scope per task: the fresh S8-G orchestration candidate built by G-NEW-1 from the durable S8-G design
(`execution/64e33dc7/`), evidence under `execution/1910a060/s8g/{build,binding/v1,gate}`. Accepted S7-L / S8-C / S8-F
were not re-audited; they are treated as the base contract. No worktree, remote, lock, test or install was touched;
the live builder clone `worktrees/1910a060-s8g` was not opened. Base bytes came only from read-only git objects
(`git -C worktrees/1910a060-land-s8f show 62471b11:<path>` / `1c5fbb04:<path>`); the candidate was reconstructed in a
throwaway scratch tree outside the workspace by applying the committed patch to those base blobs.

## Verdict

**SOURCE GO (product bytes) — conditional on closing B1 and B2 before any gate/commit/proof grant.**

- The four product blobs are correct against the durable design and the S7-L/S8-C contracts: one ordered, gated,
  transactional reconstruction pass inside `onTransferSettled`, then the S7-L tail verbatim (lock → epoch CAS →
  facts → arbitrate → CAS terminal). No double settle, stale leases rejected, terminal rows immutable, tenant scoping on
  every read/write, rows bounded, no new reason codes/events, no schema/migration/module wiring. No class A.
- Two class B items are **evidence/binding** defects, not product defects: (B1) the published identity in
  `SOURCE_READY.md` does not match the committed patch and the candidate test bytes are still moving; (B2) the binding
  runner draft points the S8-G lane at `clusters/s8-c` while its fixture uses `clusters/s8-g`, which would burn the
  once-only PG grant with a guaranteed marker mismatch. Both have one-line closures and do not require product changes.
- Class C items are recorded below; none blocks.

## 1. Identity verification

| Item | Claimed (SOURCE_READY.md) | Verified | Result |
|---|---|---|---|
| Patch sha256 | `0fe0d149a22e0f5c569a3913747ded3c2aa265d051f68afc47e058a5cbcf000b`, "3729 lines" | committed `build/s8g-candidate-1c5fbb04.patch` (evidence HEAD `06da57d`) = `36c4402fe61e18e55650daf0321a184ee803a281e73ba205f47056141524f55c`, 3741 lines | **MISMATCH** (B1) |
| PATHS count | 14 | 14 `diff --git` sections; applies cleanly to the 1c5fbb04 blobs; every resulting blob sha1 equals committed `build/blob-hashes.txt` | OK |
| Base | `1c5fbb0441178e0cfe6e9f8d72e955c645c265e9` | `git diff --stat 1c5fbb04 62471b11` (S8-F landing) touches none of the 14 S8-G paths | OK, S8-F no overlap |
| Product blobs (stable across all three observed generations) | — | `src/scout/scout-lifecycle.service.ts` `1a6db74e` (27188 B); `src/scout/scout-reconstruct.service.ts` `fb728502` (25948 B); `src/scout/orchestration/family-plan.ts` `0a75e656` (4452 B); `src/scout/orchestration/run-context.ts` `b07ebb85` (3044 B) | **This review pins to these four blobs.** |
| Untouched | `jest.config.js`, `src/scout/scout.module.ts`, `src/analytics/events.ts`, `prisma/**` | not in the patch; runner/bootstrap additionally refuse a differing prisma tree | OK |

Three candidate generations were observed: (1) the SOURCE_READY table (older test blobs, e.g. rls spec `5323567…`
36833 B); (2) the committed patch / `blob-hashes.txt` (rls spec `7e3e4273` 37072 B, db-guard `f702cc1b`, bootstrap
`02e9986f`, db `2fdbedd2`, pg-harness `ffd7c476`); (3) the uncommitted working tree with a new
`build/s8g-candidate-62471b11.patch` (sha256 `9119d6d3…`, rls spec `3c8491bd` 37095 B, db-guard `10781eca`, bootstrap
`2ab85a13`, db `da34f70d`, pg-harness `a0261246`). The diff between (2) and (3) is **only** base-head pin retargets
(`BASE_HEAD` / `G2_S8G_BASE_HEAD` / comments `1c5fbb04 → 62471b11`) in test files; every product hunk is identical.
Product conclusions below therefore hold for all three generations; test/harness conclusions hold for (2) and, modulo
the pin value, (3).

## 2. Product review (lifecycle, fencing, transactions, tenancy, bounds)

### 2.1 `scout-lifecycle.service.ts` (3 hunks only)

- Import of `Optional` + `ScoutReconstructService`; new field and `@Optional() reconstruct?` constructor parameter with
  fallback `new ScoutReconstructService(prisma, analytics)` — no `scout.module.ts` change needed (settle-hook unit test
  "fallback constructs real engine" covers it).
- `onTransferSettled(coachId, intentId, epoch)` body: `reconstructRun(coachId, intentId, { mode:'server', epoch,
  gate:(tx)=>this.assertRunOpen(tx, coachId, intentId) })` → `if (pass.stopped === 'gate_closed') await
  this.classifyClosed(...)` → S7-L tail **verbatim** (`lockRun` FOR NO KEY UPDATE → CAS `terminal_status IS NULL &&
  execution_epoch === epoch` → `collectFacts` → `arbitrate(fence, reconciliation:null)` → `writeTerminal` CAS →
  `SCOUT_RUN_SETTLED`).
- Fencing/immutability traced: `assertRunOpen` WHERE is `mode='server' AND terminal_status IS NULL AND fenced_at IS
  NULL AND deadline_at > now()` and returns the epoch; `fence` bumps epoch, sets `fenced_at`, and writes the terminal in
  one transaction; `writeTerminal` is a CAS with `COALESCE(completed_at, now())` so `completed_at` is written once; a
  stale epoch (cancel/timeout between pass and tail) makes the tail CAS miss → no second terminal, no settled event.
  **No double settle, stale lease rejected, terminal immutable.**
- `classifyClosed` runs only after `gate_closed`, in its own transaction, fences `timed_out` only when the run is still
  open and past deadline; if another writer already fenced, it writes nothing.

### 2.2 `scout-reconstruct.service.ts`

- `reconstructRun`: `groupBy` on `(entity_type, source_platform)` scoped by `{coach_id, intent_id}` (G11) → `planRun`
  → `runFamilySource` per planned source in `RUN_FAMILY_ORDER` → `runUnmappedSource` per unmapped token; catches only
  `RunPassStopped` → `stopped:'gate_closed'`; any other error propagates (hook throws, run stays open → lazy timeout).
  Summary log is PII-free (counts/tokens only).
- `runFamilySource`: `assertWithinBound` first (RECONSTRUCT_MAX_ROWS=10 000 → `over_ceiling` isolation, nothing
  read/written for that source); paged `findMany` (PAGE_SIZE 500) selecting `entity_type`; `RunPassStopped` rethrown;
  `ProvenanceConflict` → `provenance_conflict` isolation; `tallyPass` from the ledger by token+platform;
  `SCOUT_RECONSTRUCT_COMPLETED` per token (existing event, no new payload fields).
- `gateRun` (server mode only): `seen === null || seen !== ctx.epoch` → throw `RunPassStopped` **inside** the row
  transaction, so the row's writes roll back. `reconstructRow` issues the gate as the first statement of the success
  transaction before `family.persist`; the `RunPassStopped` rethrow precedes the `failed` fallback so a closed gate never
  fabricates a `failed` ledger row; `writeOutcome` (skip/fail/unmapped) is gate-first as well. `retryContention`
  retries P2002/P2034 only; `RunPassStopped` is not retried.
- Legacy `reconstruct()` passes `LEGACY_RUN` (no gate, no lock); its select has no `entity_type`, so the ledger type
  stays the family name → byte-identical legacy behaviour (G08). `assertSettled`, `assertWithinBound`, `writeLedger`,
  `tally`, `summarizeError` untouched.
- Ledger `entity_type = row.entity_type ?? family.entityType` forwards the staged token (contract), provenance stays
  keyed by canonical family (S8-B).

### 2.3 `run-context.ts`, `family-plan.ts`

`RUN_FAMILY_ORDER = [clients, programs, workouts, client_history]` (contract §3.8, not DTO order); `planRun` is pure,
routes to unmapped when the S8-A step does not resolve **or** the registry lacks the family (fail closed), keeps one
entry per canonical family with sources ordered, never invents families. Non-canonical platform in
`runUnmappedSource` → `provenance_conflict`, nothing written.

### 2.4 Scope checks

No schema/migration; no module wiring; no `events.ts` change; no new reason codes (all reasons used —
`reconciliation_not_performed`, `transfer_failed`, `deadline_exceeded`, `cancelled_by_coach`, `unresolved_family:<t>`,
`unsupported_platform:<p>`, `error:<Name>` — pre-exist in S7-L/S8-A/S8-C); no prod/Supabase/Fly URLs anywhere in the
14 paths (verified by search of the reconstructed tree).

## 3. Acceptance-case trace (design G01–G14 → code → unit → PG case)

All 19 `it` blocks in `test/rls-g2-s8g.spec.ts` are live (no `skip`/`only`); `jest.setTimeout(300000)`; every worker
runs in its own OS process with the real generated client; every assertion reads through psql as the fixture owner.

| Case | Code path | Unit (settle-hook / reconstruct-run / family-plan .spec) | PG case | Trace |
|---|---|---|---|---|
| G01 one ordered pass → truthful terminal | `onTransferSettled` → `reconstructRun` → tail | settle-hook "pass → lock → terminal", "verdict from facts" | P01: §3.8 order in query log, token forwarding, `partial/reconciliation_not_performed`, epoch 1, one push, one settled event | OK |
| G02 gate first statement of every row tx | `gateRun` in `reconstructRow`/`writeOutcome` | reconstruct-run gate-first for success/skip/fail/unmapped (FakePrisma txLog) | P02a: 8 segments, each `segments()[0]` is the gate; 0 locks, 0 terminals inside the pass | OK |
| G03 cancel between rows | `RunPassStopped` → `classifyClosed` (already fenced → no write) → tail CAS miss | settle-hook "classifyClosed once → fence prefix", "fenced elsewhere no writes"; reconstruct-run "closed gate stops, no fabricated failed" | P03: 3 gates, last tx rollback, 0 terminals from the pass, snapshot after row 2 is final, `cancelled/cancelled_by_coach`, epoch 2 | OK |
| G04 cancel racing an in-flight gated row | row lock held by gated tx; cancel waits on `FOR NO KEY UPDATE` | — (PG-only by design) | P04: `blocked()` observes lock wait, row k commits and counts, next gate closes, no 40P01 | OK |
| G05 deadline mid-pass | gate `deadline_at > now()` fails → rollback → `classifyClosed` fences `timed_out` in a new tx → tail CAS miss | settle-hook G03/G05 | P05: gate → rollback → begin → lock ordering asserted; 1 fence, 1 terminal (the fence's), `timed_out/deadline_exceeded`, epoch 2, fenced event, no settled event | OK |
| G06 claim vs truth | S7-L `completeServerRun` facts; pass runs only with staged rows | settle-hook G06 | P06: zero staged + claim failed → `failed/transfer_failed`, 1 gate (the complete's own), no pass; staged + claim failed → 3 gates, `partial` | OK |
| G07 duplicate / late /complete | S7-L accepted `completeServerRun` no-op ack | (accepted S7-L) | P07: concurrent second claim → ack, 1 gate, 0 lock, 0 terminal, rollback, 0 pushes; exactly one completion row and one terminal write; late claim → row byte-equal; no Start → 409 `run_not_started` | OK |
| G08 legacy route never gates | `reconstruct()` with `LEGACY_RUN` | reconstruct-run "legacy no-gate sequence" | P02b: 0 gates, 0 locks, family-named ledger, replay byte-identical | OK (folded into P02) |
| G09 post-settle gate / readers | S8-C `assertSettled` 409 during pass; status reads `running/reconciling` | (accepted S8-C) | P09: 409 during pass with 0 gates; after terminal legacy route runs and replays idempotently; pass ledgers `unresolved_family:workouts` for a family-named token the spec does not map | OK |
| G10 unmapped token, over-ceiling source | `runUnmappedSource`; `assertWithinBound` | reconstruct-run over-ceiling isolation; family-plan unmapped/unsupported | P10a: notes → `skipped unresolved_family:notes`, status lists token; P10b: 10 001 rows → `over_ceiling`, 0 targets, 0 ledger for that source, other family runs, one terminal | OK |
| G11 tenant isolation, RLS, rollback | all reads/writes `{coach_id,intent_id}` scoped | reconstruct-run "groupBy args" | P11: B's rows untouched; anon/authenticated read 0 and INSERT refused by RLS; rolled-back service_role write persists nothing | OK |
| G12 zero side effects | no side-effect module in the path | worker resets side-effect load spies after startup | P01/P12: 1 push per /complete, 0 side-effect loads; replayed pass over terminal run → `gate_closed`, 0 pushes, targets unchanged, 0 assignments/notifications | OK |
| G13 interrupted pass | killed worker leaves run open; poll fences `timed_out`; run 2 verifies existing targets | — (PG-only by design) | P13: `phase reconciling, terminal null, epoch 1` after kill; poll → `timed_out/deadline_exceeded` epoch 2; second run → 1 program, 1 plan, provenance native_id equal, no duplicates | OK |
| G14 CAS/epoch on the tail | tail CAS on epoch | settle-hook "CAS miss", "terminal already set → miss" | P14: cancel while paused `before-lock` → 1 lock, 0 terminals, no settled event, row byte-equal to fenced snapshot, `completed_at` set once; stale settle epoch 1 no-op | OK |

Barrier accounting (builder F8) is consistent with the code: `after-row` counts committed gated transactions, and in
`complete` actions the /complete's own gated claim tx is the first, so `pauseRow: 2` in P07/P09/P13 pauses after the
first reconstruction row — the assertions (e.g. P13 "1 program, 0 plans") match that.

## 4. Harness and guard review

- `test/utils/g2-s8g-db.ts`: loopback `127.0.0.1` only; database `g2_s8g_disposable`, superuser `s8g_super`;
  double-entry confirmation `G2_S8G_CONFIRM=g2_s8g_disposable:<port>` with port match; password from env only; refused
  ports `5432, 5433, 6543, 54321, 54322, 55439, 54325, 55461, 55471, 55481, 55491, 55501, 55511, 55641, 55642`
  (**55642 refused; 55643 NOT refused** — see C1); `g2S8gCandidateHead` refuses missing/non-40-hex/upper-case value,
  the base head, a mismatched `git rev-parse HEAD`, and a dirty tree. Guard spec covers each refusal and pins
  `BASE_HEAD`/`EXPECTED_MIGRATIONS`/migration names identically across bootstrap, harness and repository, and asserts the
  worker attests HEAD **before** `new PrismaClient`.
- `test/utils/g2-s8g-pg-harness.ts`: throws (no silent skip) when any of URL/password/psql/data-directory is absent;
  candidate head attested at module load; psql runs with `-X -w` and `PGPASSWORD` only; worker `fork` with
  `ts-node/register/transpile-only`, 90 s kill timer, settles only after exit code and IPC disconnect are both known; log
  lines carry query shapes/counts only, never parameters.
- `test/utils/g2-s8g-bootstrap.sh`: `set -euo pipefail`; requires all `G2_S8G_*` incl. `G2_S8G_CANDIDATE_HEAD`; refuses
  base head, mismatched HEAD, non-descendant; `PRISMA_GENERATE_SKIP_AUTOINSTALL=1`, no `npm ci`; server identity
  (17.x exact version, loopback, superuser) then **cluster marker `s8g-disposable-pg17` checked before any write**;
  hosted-platform roles (`supabase_admin`, `authenticator`, `pgbouncer`, …) → refuse; database created once with the
  disposable marker comment, an existing database without exactly that comment refused, never dropped; prisma tree,
  package manifests and migration count (172) must equal base; S7-L columns and S8-B objects must be present;
  candidate client engine/runtime provenance pinned (missing file = refusal).
- `test/utils/g2-s8g-worker.cjs`: attests `git rev-parse HEAD == input.head` before constructing the client; pause-only
  barriers (`before-gate|gated|before-ledger|after-row|before-lock|locked`) and `-- tx:*` markers are instrumentation on
  the real services; the `mapper:'throw'` fault replaces a mapper, not a query; constructs
  `ScoutLifecycleService(prisma, analytics, reconstruct)` with the injected registry — the same constructor shape the
  Nest fallback uses.
- Fixture `expire()` sets `deadline_at = accepted_start_at + 1 ms` as the owner (fixture-only; product never updates
  `deadline_at`).
- No hosted/prod URL, Supabase project ref, or Fly hostname appears in any of the 14 paths or the binding draft.

## 5. Binding v1 draft (`s8g/binding/v1`, unfilled, not granted)

Refusal logic present and correct: sentinel `runs once, no retry` (exit 76); canonical lock `execution/test-validation.lock`
must pre-exist, `flock -n` on fd 9 (exit 75), inode logged in the sentinel; nine `__FILL_AFTER_ATTESTATION__` pins
refuse execution while unfilled; `EXPECT_HEAD != BASE_HEAD`, HEAD/tree/base-tree equality, ancestry, S8-G blob pins,
accepted-file blobs equal to base, clean worktree incl. untracked, no `MERGE_HEAD`, hooks path, prisma tree equal to
base; isolated real `node_modules` copy required; tool pins compare-only; preflight lane absent / port free / no
postgres; single `timeout -k 30 …` stage budgets (60+60+900+1500+75 s) inside the documented 3600 s outer timeout;
bounded stop with survivor detection; post-check worktree unchanged. Fixture refuses standalone use unless
`S8G_RUNNER_PID` is a live `s8g-pg-proof.sh`, fresh-init only, marker required for start/destroy.

**Defect (B2):** runner line 50 sets `LANE=$CLUSTERS/s8-c` (S8-C substitution residue) while `s8g-fixture.sh` line 26
sets `LANE=$RUNTIME_ROOT/clusters/s8-g`. Consequences: `G2_S8G_DATA_DIRECTORY=$LANE/pg-data` points at
`clusters/s8-c/pg-data`; the runner's `FIXTURE_INIT` marker grep (`data=$LANE/pg-data …`) can never match the fixture's
`S8G_FIXTURE_INIT_OK data=…/clusters/s8-g/pg-data` line → `fail 72` right after `initdb`, the once-only sentinel is
written and the single granted run is consumed with no proof. Even if that grep were loosened, the lane-identity test
(`directory` must equal `current_setting('data_directory')`) and `CLEANUP_STOP survivor_pid` would read the wrong path.
Fail-closed, but it wastes the grant.

## 6. Findings

### Class A (harm to a real customer or coach's data, or a false pass)
None.

### Class B (evidence cannot reliably tell us whether the product is correct)

**B1 — Candidate identity is stale and still moving.**
Harm: the gate, commit and PG proof would attest bytes that `SOURCE_READY.md` does not describe (sha256 `0fe0d149…`
vs committed `36c4402f…`; three test-blob generations; base pin already retargeted to 62471b11 in an uncommitted
patch). Decision blocked: which exact 14 blobs are the S8-G candidate for gate/hooked commit/pin fill.
Minimum closure: builder republishes `SOURCE_READY.md`, `build/blob-hashes.txt` and one patch for the final base
(62471b11 after the S8-F landing) with a matching sha256/line count and parent pin, then freezes; product blobs are
unchanged across generations, so this review's product conclusions carry without re-review — only the pinned test-blob
sha1s in the pin fill must be taken from the final committed head.

**B2 — Binding runner lane path mismatch (`s8-c` vs `s8-g`).**
Harm: the single granted real-PG run fails at `FIXTURE_INIT` (exit 72) after `initdb`, writes the once-only sentinel,
and no proof is produced; a retry needs a new grant. Decision blocked: granting the PG run on binding v1 as drafted.
Minimum closure: in `s8g-pg-proof.sh.unfilled` line 50 change `LANE=$CLUSTERS/s8-c` to `LANE=$CLUSTERS/s8-g` (one
token), re-`bash -n`, and record the template sha256 in `BINDING.sha256` at fill time. Recommended at the same time:
make the fixture and runner read a single `LANE` definition or assert equality at start.

### Class C (recorded; no action required to land)

- **C1 Port 55643 reuse.** 55643 is the S8-F proof lane (`proof-s8f-v2/clusters/s8-f`, data dir retained, stopped).
  Accepted convention (S8-C refused 55641; S8-F refused 55641/55642) is that a retained stopped lane's port is never
  reused, yet S8-G suggests 55643 and does not refuse it. Cluster marker (`s8g-disposable-pg17`), database marker and
  the runner's port-free preflight keep any collision fail-closed, so not B. Closure at binding level without a source
  change: `PORT=55644` in runner and fixture (the guard accepts any non-refused loopback port); optionally add `55643`
  to `REFUSED_PORTS` in a later T1 change.
- **C2** Deadline now also bounds the reconstruction pass: a large roster may truthfully end `timed_out` with partial
  native rows; the coach-JWT reconstruct converges post-terminal. Design-accepted (G05).
- **C3** Deadline expiring between the last row and the tail → tail writes `partial` (no deadline predicate on
  `writeTerminal`); inherited S7-L window, widened by pass length.
- **C4** `classifyClosed` compares Node clock to `deadline_at`; DB/Node skew could yield `not_started` (no fence) then
  `partial` from the tail. Inherited S7-L semantics.
- **C5** `assertRunOpen` has no phase predicate: a late ingest during `reconciling` is admitted; the pass enumerates a
  snapshot, so staged > ledger → `partial` (truthful). Skip/take paging under concurrent inserts is S8-C-accepted.
- **C6** `ProvenanceConflict` thrown from `writeOutcome` inside `runUnmappedSource` is not isolated (propagates → hook
  throws → run left open for lazy timeout), asymmetric with planned-family isolation. Fail-closed.
- **C7** `planRun` silently drops a registry family absent from `RUN_FAMILY_ORDER` (today 4 == 4).
  `family-plan.spec.ts` asserts the order list and the reverse fail-closed case (spec family missing from registry) but
  not that `RUN_FAMILY_ORDER` covers the registry; suggest one unit assertion.
- **C8** Builder F3/F4 recorded: fixture platform `s8g-proof` makes `clients`/`client_history` rows ledger
  `unsupported_platform:s8g-proof` (accepted module-level mapper registry); S7-L `collectFacts.unmapped_families` uses
  the family-name test and the arbiter ignores it. Token forwarding into the ledger vs family-keyed provenance is the
  contract and is asserted in P01.
- **C9** Phase `discovering` is visible to the owner while a gated writer is paused (P04) because the phase move is in
  the uncommitted row transaction — expected, asserted.
- **C10** Worker per-process kill timer is 90 s while jest per-test timeout is 300 s; the over-ceiling case does no row
  work so the budget is safe today, but a future large-fixture case must raise the worker timer first.

## 7. Files read (evidence)

`execution/1910a060/SCOPE.md`; `tgp-agent-context/AGENT_RULES.md`;
`execution/6c2a68ac/OWNER_SAFETY_ROI_AND_EXECUTION_DOCTRINE.md`; durable S8-G design/PATHS/TESTS/READINESS/FINDINGS/
GRADE under `execution/64e33dc7/`; `execution/1910a060/s8g/build/{SOURCE_READY.md,FINDINGS.md,blob-hashes.txt,
s8g-candidate-1c5fbb04.patch}`; `execution/1910a060/s8g/binding/v1/*`; `execution/1910a060/s8g/gate/` (listing only);
`execution/1910a060/s8f/S8F_ACCEPTANCE.md` (for the 55643 lane fact); all 14 candidate paths as reconstructed from the
committed patch; base blobs `scout-lifecycle.service.ts` `5949a293`, `scout-reconstruct.service.ts` `711bfb09`.
