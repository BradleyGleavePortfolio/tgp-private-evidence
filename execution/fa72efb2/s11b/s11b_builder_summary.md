# S11-B NEW candidate — builder summary (EXEC-FA72EFB2, T4)

Slice: S11-B re-drivable settle (G1), D-S11-4, J12–J16, D-S11-8 row S11-B. Built NEW from the reviewed design
(execution/d3a9f701/s11b/{builder summary, reviews A/B with delta GO, s11b_fix1.diff}) and
docs/decisions/2026-09-26-s11-journey.md. **No byte continuity with the lost predecessor worktree is claimed**:
design, test structure and the fix-1 J13 hunk were used as reference only; every byte here was re-authored.

Clone: `/home/user/workspace/worktrees/fa72-s11b`, branch `fa72/s11b`, base `3db615c0` (S11-A1 v3). Base shas
verified before editing: `lifecycle.service.ts` = `55c8f24a…` (the same S10-C base the predecessor recorded),
`scout.service.ts` = `adff9ab7…`, `rls-g2-s10c.spec.ts` = `28d32a88…`.

## Commit (local only, hooks run, no push)

| | |
|---|---|
| head | `45b4da1d601007c15618e358c307c26f48262a43` |
| tree | `04c4fc8f1a989556979fc287964e01aef36b3a04` |
| parent | `3db615c0a5e64a63b910d34ce7c732ee6e63f24d` |
| author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` (both; no trailers, empty body) |
| subject | `feat(scout): re-drive an interrupted settle on a replayed completion (S11-B)` |
| hooks | lefthook v2.1.9 pre-commit: prod-readiness-quick, banned-cast-tokens (R75 staged), prettier, eslint, tsc — all ✔; commit-msg no-ai-tokens ✔ (`s11b_commit.log`) |
| working tree after commit | clean (`git status --porcelain` empty) |

## Files (at head 45b4da1d) — sha256, LOC

| Path | State | sha256 | Lines |
|---|---|---|---|
| `src/scout/scout.service.ts` | modified: P2002 branch + private `redriveEpoch` (+34 / −3; 15 added non-comment) | `d9b7b0e121c4b56f8a65573438e5e0741ad3d7ce3d8c24a5cf04446e6bb45511` | 607 |
| `src/scout/lifecycle/lifecycle.service.ts` | modified: ONE read helper `isSettlePending` (+19 / −0; 10 added non-comment), inserted between `assertRunOpen` and `classifyClosed` | `7c8c42c331c028cc6246ae6be8462525e97a9847073f61ce48291ab04962fff4` | 1058 |
| `test/scout/s11/settle-redrive.pg.spec.ts` | NEW live spec, 8 cases, harness by import only | `70ddf75f33e088ac5a182a60e2fb01cd8eda052209b92e11cecc12988b743cc0` | 499 |
| `test/scout/lifecycle/s11b-settle-redrive.spec.ts` | NEW unit spec, 11 cases, no DB | `4a6138995b525196911ff5a1d9344de680bd9fbc6b717c215303761a105da2f2` | 308 |
| `test/rls-g2-s10c.spec.ts` | modified: R36 retry expectation flipped (see below), nothing else | `87fd54aaab2a135752199764511016b20f30f95b2c55cf2ac8b4683455ceb7f8` | 346 |

Production LOC (D-S11-8 cap ≤ 80 hand-written): **53 added lines total (25 non-comment), 3 removed** — well under
the cap. The src-only diff is saved as `s11b_new_candidate_src.diff` (sha `b7e942c7…`) in this directory.

No schema, route, DTO, reason code, arbiter, reconcile, coverage, push or event change. **No new import** in
either production file (`Tx`, `PrismaClientKnownRequestError`, `ScoutLifecycleService` were already imported).
No new `test/utils/g2-s11*` file; the S11-A1 harness is used unchanged.

## D-S11-4 design mapping

`completeServerRun` P2002 branch (the claim transaction has already rolled back on the ledger unique):

```ts
if (err instanceof PrismaClientKnownRequestError && err.code === 'P2002') {
  const pending = await this.redriveEpoch(coachId, dto.intent_id);
  if (pending !== null) await this.lifecycle.onTransferSettled(coachId, dto.intent_id, pending);
  return ack;
}
```

`redriveEpoch(coach, intent)` = one short `this.prisma.$transaction(fn)`: `lifecycle.assertRunOpen(tx)` is the first
statement (the §3.1 gate: open, unfenced, unexpired, holds the row, returns the DB epoch) → null ⇒ null (ack no-op,
no 409, no `classifyClosed`, exactly the pre-S11-B answer); else `lifecycle.isSettlePending(tx)` ⇒ epoch or null.

`isSettlePending(tx, coach, intent)` (lifecycle, the ONE read helper; D-S11-4 names it `isReDrivable`, the grant and
predecessor name it `isSettlePending` — the grant's name is used):

```sql
SELECT 1 AS pending FROM "ScoutImport" r
 WHERE r.coach_id = $1 AND r.intent_id = $2 AND r.mode = 'server'
   AND r.terminal_status IS NULL AND r.fenced_at IS NULL AND r.phase = 'reconciling'
   AND EXISTS (SELECT 1 FROM "ScoutImportCompletion" c WHERE c.coach_id = r.coach_id AND c.intent_id = r.intent_id)
```

No lock, no write, only `[coach, intent]` bound; the text contains neither `last_observed_at` nor
`FOR NO KEY UPDATE`, so the S11 (and S10-B) worker barrier matchers never fire on it (asserted in the unit spec).

| D-S11-4 bullet | Where |
|---|---|
| re-drive iff open, unfenced, `reconciling`, completion row exists | gate (`assertRunOpen`) + `isSettlePending` predicates |
| epoch re-read under the gate in the replay's own short tx, never from the client | `redriveEpoch` returns the gate's `RETURNING execution_epoch`; the branch has no epoch input; DTO has no epoch field |
| stored claim never overwritten; a different replay status is only a trigger | the only completion statement on the replay path is the refused INSERT; no update/upsert exists |
| settle is CAS-guarded / replay-safe; two concurrent re-drives → at most one CAS wins silently | `onTransferSettled` unchanged (S7-L/S9-C/S10-C tail) |
| no new push / analytics event on a re-drive | `notifyComplete` + `SCOUT_INGEST_COMPLETED` remain after the `try` on the first-claim path only |
| status read never triggers settle; no timer; no `/settle` route | untouched |

Behaviour unchanged for: first claim; replay after terminal/fence (gate closed → `classifyClosed` → ack; P2002 never
reached); replay before any claim (409 `run_not_started`); coach B's claim on A's intent string (J07: B's legacy path,
never A's gate). The S10-C "two concurrent claims" case is unaffected (the second claim's gate blocks on the first's
tail lock and sees the terminal — no P2002).

### R36 flip in `test/rls-g2-s10c.spec.ts` (the only edit there)

The R36 case "an injected ScoutRunSettledBasis insert failure rolls the terminal back…" pinned the OLD retry behaviour
and said so in its own comment ("S11-B's settle re-drive supersedes exactly this assertion"). After the injected
basis-insert failure the run is open in `reconciling` with its completion row — exactly the S11-B eligibility
state — so the retry now re-drives. Flipped lines (before → after):

```
-    expect(retry.queries.filter(isTerminalCas)).toHaveLength(0);   →  toHaveLength(1)
-    expect(retry.queries.filter(isBasisInsert)).toHaveLength(0);   →  toHaveLength(1)
-    expect(runRow(COACH, intentId).terminal_status).toBeNull();    →  .not.toBeNull()
-    expect(count(SETTLED)).toBe(0);                                →  toBe(1)
```

`retry.failure` undefined and `retry.pushes === 0` are kept (the re-drive pushes nothing). The two-line comment was
replaced by a four-line one stating the S11-B reason. The full hunk is at the end of this summary's src diff
companion (`git diff 3db615c0 HEAD -- test/rls-g2-s10c.spec.ts`).

## Invariant → test table

| Invariant | Unit (`test/scout/lifecycle/s11b-settle-redrive.spec.ts`, 11 cases, all PASS) | Live (`test/scout/s11/settle-redrive.pg.spec.ts`, 8 cases, two hosts, real kill — PARENT runs) |
|---|---|---|
| Re-drive when the settle was lost (G1) | "J16": P2002 → 2nd `$transaction` → `assertRunOpen` re-read (9; not the claim gate's 7, not a body-smuggled 42) → `isSettlePending` in the SAME tx, after the gate → `onTransferSettled(coach, intent, 9)` once, after the tx returned | J12: P1 killed at `after-row` 2 (claim + first pass row committed); DB asserted open/`reconciling`/claim stored/no basis; partial ledger `1 ≤ n < reference`; P2 status read shows `running`/`reconciling`/`claimed_status success`, writes nothing; P2 replay → trace (refused INSERT → `-- tx:rollback` → gate → ONE pending read → tail lock, in that order), 1 terminal CAS, 1 basis INSERT, 1 `scout.run.settled`, epoch 1; `settledShape` (terminal, state, reason, phase, epoch, ledger tallies, id-free ledger + provenance rows, native counts, evidence, basis count, claims) **equals the uninterrupted reference run**; both hosts read the same status. J12 edge: killed at `after-row` 1 (no pass row) → identical |
| Idempotent: a further retry does not double-settle | "idempotent": after the re-drive the gate is closed → `classifyClosed`, no 2nd `onTransferSettled`, no push | J12 tail: third claim → ack, no completion INSERT, no pending read, no terminal, no basis INSERT, no non-gate write, no push/event, row + shape byte-equal, `count(basis)=1` |
| No settle when not pending / gate closed in between | "no re-drive when the settle is not pending"; "J15 (unit shadow)": gate null → no read, no settle, no 409, no `classifyClosed` | J15 (a): replay after a clean settle → ack; no completion INSERT (gate closed first), no pending read, no terminal/basis/non-gate write, no push/event, row + shape unchanged |
| Epoch-fenced | "J16" (gate re-read wins); `isSettlePending` statement has no epoch parameter and no `execution_epoch` text | J15 (b): kill, `fence revoked` on P2 (epoch 2, terminal, no basis), replay on P1 → ack, no INSERT/read/terminal/basis/non-gate write, row + ledger unchanged, basis 0, claim unchanged. (A genuine epoch bump without a fence is not reachable through the service — stated, unit-only) |
| Tenant-scoped | SQL pinned: `r.coach_id = ?`, EXISTS joined on `c.coach_id = r.coach_id AND c.intent_id = r.intent_id`, exactly `[COACH, INTENT]` bound | "tenant scope": B's claim under A's stuck intent → no gate, no pending read, no terminal, no basis, no lock; A's row, targets (persons/programs/plans/evidence/provenance/ledger) and claim byte-equal; A's own replay then re-drives (trace asserted) and settles with exactly one basis row for A |
| No customer side effect beyond the one first-claim push | "the replay stores nothing of its own": 1 refused INSERT, no phase CAS, push 0, capture 0, no `classifyClosed`; "first claim unchanged": 1 tx, phase CAS on epoch 7, push 1, `scout.ingest.completed` 1, settle under 7, no pending read | every replay: `pushes 0`, `pushCalls []`, `scout.ingest.completed 0`; `scout.run.settled` exactly 1 across the re-drive(s) |
| Concurrent re-drive: one terminal (J13), **both workers provably in the re-drive branch** (review A B-1 / B B1 delta GO) | — | J13: after the kill, P2 and P1 both `complete` with `pause:'before-lock'`; `Promise.all([a.ready, b.ready]) === ['before-lock','before-lock']`; at that instant run open/`reconciling`/unfenced, basis 0; both resumed; per worker: refused INSERT → `-- tx:rollback`, ≥1 later gate, exactly 1 pending read, ≥1 lock attempt, gate < read < lock order, push 0, completed 0, ≤1 CAS, ≤1 basis INSERT; across both: exactly 1 terminal CAS, 1 basis INSERT, 1 settled event, `count(basis)=1`, one claim row, unique ledger keys, epoch 1, **shape equals the reference** |
| Stored claim preserved (J14) | "J14 (unit shadow)": `partial` replay → only the refused INSERT (`create` called once with `partial`), no update/upsert seam on the tx, settle re-driven from DB state | J14: interrupted `partial` claim, `success` replay → the replay's only `ScoutImportCompletion` write is the refused INSERT; completion row stays `partial`; status `claimed_status:'partial'`; shape equals the uninterrupted `partial` reference |
| Before any claim (J15 c) | "J15 (c)": closed gate → `classifyClosed not_started` → 409, branch not reached; "P2002-only": P2025 and a generic Error propagate with no re-drive | J15 (c): paired-never-started intent → 409 `run_not_started` on both hosts, no completion INSERT/read, no completion row, no run row |
| `isSettlePending` shape | "one row → true; zero → false"; SELECT-only, no `UPDATE|INSERT|DELETE`, no `FOR … UPDATE/SHARE`, no `last_observed_at`, no `execution_epoch` | (exercised by every live re-drive: exactly one pending read per replay) |

J13 mechanics (why the barrier is discriminating): the S11-A1 worker's `before-lock` barrier is installed in
`$queryRaw` immediately before any `FOR NO KEY UPDATE` statement (`g2-s11-worker.cjs` instrument). On the replay path
the only such statement is the settle tail's `lockRun` (`lifecycle.service.ts` L512; the fence's lock is not on
this path while the gate stays open; the pass has none). Reaching it therefore proves, per worker, that P2002, the
eligibility transaction and the pass have completed while the run is still open. Per-row pass transactions serialize
on the gate row lock, so the two concurrent passes interleave row by row (no contention retries expected).

## Commands run (every heavy one under `flock -w 3600 /home/user/workspace/execution/test-validation.lock`, `NODE_OPTIONS=--max-old-space-size=3072`, in the clone)

Waited for `node_modules/.bin/tsc` to appear and, per the parent's 08:20 mail, started no flock command until
`/home/user/workspace/execution/fa72efb2/PROOF_SLOT_FREE` existed (observed 15:29 UTC). Never ran npm install /
prisma generate / any PG or `rls-g2-*` spec. Prettier = runtime 3.9.9 (`npm_config_prefix`/PATH per WORKER_RULES 4;
`node_modules/.bin/prettier` does not exist in the clone, so the hook's `npx prettier` resolved to it too).

| # | Command | RC | Log |
|---|---|---|---|
| 1 | `prettier --check` on the 5 owned files (light, no flock) — 2 new specs needed `--write` once (line wraps / quote style only), then re-check | 0 | — |
| 2 | flock: `npx eslint --no-warn-ignored --max-warnings 0 <5 owned files>` | 0 | `s11b_eslint.log` (empty output) |
| 3 | flock: `npx tsc --noEmit` — first run RC=2: TS6200 name conflict between `journey-core.pg.spec.ts` and the new spec (both were scripts with the same top-level names); fixed by making the new spec a module (`export {};` + 2-line comment); re-run | 2 → **0** | `s11b_tsc.log` (final) |
| 4 | flock: `npx jest --runInBand test/scout/lifecycle test/scout/induction test/scout/reconciliation test/module-graph.spec.ts src/scout/scout.service.spec.ts` (the last is the existing unit spec covering `ScoutService.complete`) | 0 — 18 suites, 534 tests passed | `s11b_jest.log` |
| 5 | flock: `npx jest --runInBand --verbose test/scout/lifecycle/s11b-settle-redrive.spec.ts` | 0 — 11/11 | `s11b_jest_unit_verbose.log` |
| 6 | flock: `npx jest --runInBand test/scout/s11/settle-redrive.pg.spec.ts` WITHOUT `G2_S11_*` (inert-path check only, not a live run) | 0 — 1 suite skipped, 8 tests skipped | `s11b_jest_live_inert.log` |
| 7 | `git add <5 files>`; `node scripts/check-r75.js --mode=staged` | 0 ("OK — no positive token change") | in transcript |
| 8 | flock: `git commit -m "feat(scout): re-drive an interrupted settle on a replayed completion (S11-B)"` with Bradley author+committer env; hooks ran tsc/eslint/prettier/R75 again | 0 → `45b4da1` | `s11b_commit.log` |

## Live commands the PARENT must run (S11 lane, `G2_S11_*` env, `G2_S11_CANDIDATE_HEAD=45b4da1d601007c15618e358c307c26f48262a43`, clean tree at that head, alone, in band, under the canonical lock)

```
cd /home/user/workspace/worktrees/fa72-s11b
NODE_OPTIONS=--max-old-space-size=3072 npx jest --runInBand test/scout/s11/settle-redrive.pg.spec.ts   # 8 live cases: J12, J12 edge, J13, J14, J15 a/b/c, tenant scope
NODE_OPTIONS=--max-old-space-size=3072 npx jest --runInBand test/scout/s11/journey-core.pg.spec.ts     # J01-J08 unchanged (J02 replay path)
# rls-g2-s10c.spec.ts WAS touched (R36 flip) → S10-B lane (G2_S10B_* env, its own attested head / prisma generate rule):
NODE_OPTIONS=--max-old-space-size=3072 npx jest --config jest.rls.config.js test/rls-g2-s10c.spec.ts --runInBand --ci
```

The S11 harness binds the worker root to the attested head (`g2-s11-worker.cjs` head check) — the head above is the
value to attest. The live spec is `describe.skip` without `G2_S11_DATABASE_URL`.

## Findings (Safety ROI, A/B/C)

No A or B findings against the product delta.

- **C-1 (record, qualify, continue) — "replay stores nothing" wording.** As review A noted, the eligibility gate is
  the existing `assertRunOpen` UPDATE of `last_observed_at`; "stores nothing" means no completion/claim write, no
  phase CAS, no terminal. The live spec therefore asserts "no NON-gate write" (`isNonGateWrite`) on closed-gate
  replays and asserts the refused INSERT is the only `ScoutImportCompletion` write on re-drives.
- **C-2 — J13 tail-transaction timeout.** The settle tail opens with `S9_SNAPSHOT_TX_OPTIONS` (20 000 ms), and the
  worker applies the fixture `txTimeout` only to transactions opened without options, so `txTimeout: 60000` on the
  J13 workers does not widen the tail. Both workers are forked simultaneously and each pauses only after its own
  pass; the wait for the second `ready` is expected to be a few seconds, but if a slow host makes a paused tail
  exceed 20 s the loser would fail with a Prisma transaction timeout (a proof flake, not a product defect). The same
  limit already applied to the accepted S10-C "two concurrent claims" case (`pause:'locked'`). If observed, the
  minimum fix is harness-side (an S11-A2/harness-owner edit), not a product change.
- **C-3 — J12 partial-ledger bound.** `completeAndKill(…, 2)` asserts `1 ≤ ledger.length < reference.ledger.length`
  (predecessor note 2). The first planned row is a `clients` row (`p-1`, a Person upsert + one ledger row), so 1 is
  expected; the bound is loose on purpose.
- **C-4 — ledger/provenance equality under re-drive.** `settledShape` compares ledger rows minus `target_id`
  (`status`, `reason`, `target_kind` kept) and provenance rows minus `native_id` / `import_intent_id` (`outcome`
  kept), against an uninterrupted reference run. The re-driven pass re-walks every staged row (paged read,
  `scout-reconstruct.service.ts` L98-112: "a re-run picks up exactly where a prior pass left off"). Read to confirm
  the comparison holds: a re-run success row ledgers `reconstructed` / `reason null` / same `target_kind` exactly
  like the first pass (`writeLedger` upsert `update: {}` + precedence UPDATE, L565-612); a row whose provenance
  already exists non-unresolved takes `verifyTarget` (`native-writers.ts` L66-89), which only reads the target and
  never rewrites the stored `outcome`, so `created` stays `created`. If the live run shows a difference, that is an
  S8-C replay-semantics finding to route, not something to relax silently.
- **C-5 — helper name.** D-S11-4 says "at most one read helper, `isReDrivable`"; the grant and the reviewed design
  call it `isSettlePending`. The grant's name was used (one helper either way).
- **C-6 — `export {}` in the live spec.** Needed because `journey-core.pg.spec.ts` is a script (no import/export)
  declaring the same top-level identifiers, and `tsc --noEmit` compiles all of `test/` in one program. Test-only,
  no runtime effect (ts-jest emits the same CommonJS).

## Open risks

1. Live proof not run by me (parent binding). The eight live cases and the flipped R36 are inferred green from the
   design and code reading, not observed.
2. C-2 timing above (J13), and the general 90 s per-worker kill timer in the harness for the long J12/J13 cases (each
   worker is short; the case total is bounded by `jest.setTimeout(600000)`).
3. `test/rls-g2-s10c.spec.ts` runs on the S10-B lane through the S10-B worker (2-arg lifecycle, default registry, S9
   closed-set verdict); the flipped R36 only asserts the structural half (one CAS, one basis, terminal not null).
