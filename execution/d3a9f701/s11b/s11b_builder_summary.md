# S11-B builder summary — re-drivable settle (G1 fix, D-S11-4)

Worktree `/home/user/workspace/worktrees/d3a9-s11b`, branch `exec-d3a9/s11b`, HEAD `711c1f8f`, with the frozen
S10-C 11 paths as the untracked/modified base layer (untouched by me; `lifecycle.service.ts` base sha
`55c8f24a…` verified before editing). Source only: no run, no lock, no commit. S10-C worktree untouched.

## Files (sha256)

| Path | State | sha256 |
|---|---|---|
| `src/scout/scout.service.ts` | modified: P2002 branch + `redriveEpoch` helper (+27 / −3) | `b92c7625e0ba3f8c3dfdd0d998524854f7aa32efdb941bf6c446968c4faf43f5` |
| `src/scout/lifecycle/lifecycle.service.ts` | modified on top of S10-C bytes: ONE separable hunk, `isSettlePending` READ helper (+17 / −0, inserted before `classifyClosed`'s doc comment) | `7738c43cb588ee0a5606b1e8bca20ba1bb1beb1a7b25566566361f02ea1bf7ba` |
| `test/scout/s11/settle-redrive.pg.spec.ts` | NEW (418 lines; imports `test/utils/g2-s11-harness` / `g2-s11-pg-harness` lazily like journey-core; no new utils file). **Fix 1 (review A B-1) applied**: `/home/user/workspace/s11b_fix1.diff` (sha `61cc3f8227ab21a1105156baf2bf4b1078bd321bae99554e520649f934b11e83`) | `c076f5513ada6fca2b348e283fee16d1def16f4d13003cb13b68f22bf6934f23` |
| `test/scout/lifecycle/s11b-settle-redrive.spec.ts` | NEW (242 lines; unit, no DB) | `e91d803fc74edf4d907dacbace450ceaf84d8cee5c9539b531343f9c0da5c88c` |

Separable hunks for the re-base: `/home/user/workspace/s11b_lifecycle_hunk.diff` (lifecycle vs the S10-C frozen
file — exactly my 17 lines) and `/home/user/workspace/s11b_scout_service.diff` (vs 711c1f8f).

The S11-A1 harness (`test/utils/g2-s11-*`, c8ee9005) is NOT in this worktree; the live spec's imports resolve once
S11-A1 is in the base. The harness is used unchanged: `pg.worker` with `pause:'after-row'`/`pauseRow` + `stop()`
is the kill, `pause:'locked'` + `pg.blocked` is the J13 race, `h.on(...,{action:'fence'})` the J15 fence.

## Production LOC

| File | added | removed | added non-comment |
|---|---|---|---|
| `src/scout/scout.service.ts` | 27 | 3 | 15 |
| `src/scout/lifecycle/lifecycle.service.ts` | 17 | 0 | 10 |
| **S11-B total** | **44** | 3 | **25** |

≤ 80 (D-S11-8). No schema, route, DTO, reason-code, arbiter, reconcile or coverage change. No new import.

## Design (D-S11-4, exactly)

`completeServerRun` P2002 branch (the claim transaction already rolled back on the ledger unique):

```
const pending = await this.redriveEpoch(coachId, dto.intent_id);
if (pending !== null) await this.lifecycle.onTransferSettled(coachId, dto.intent_id, pending);
return ack;
```

`redriveEpoch` = one short `$transaction`: `lifecycle.assertRunOpen(tx)` (the §3.1 gate: open, unfenced,
unexpired, holds the row, returns the DB epoch) → null ⇒ null; else `lifecycle.isSettlePending(tx)` ⇒ epoch or
null. `isSettlePending` is a SELECT over `"ScoutImport" r` with `r.coach_id = $1 AND r.intent_id = $2 AND
r.mode='server' AND r.terminal_status IS NULL AND r.fenced_at IS NULL AND r.phase='reconciling' AND EXISTS
(SELECT 1 FROM "ScoutImportCompletion" c WHERE c.coach_id = r.coach_id AND c.intent_id = r.intent_id)`. No lock,
no write, no parameter but coach and intent. Epoch is the gate's re-read; the body has no epoch input. The stored
claim is never written (the only completion statement is the refused INSERT). `notifyComplete` and
`SCOUT_INGEST_COMPLETED` remain in the first-claim path only. `onTransferSettled` is the existing S7-L/S9-C/S10-C
tail unchanged (CAS-guarded, replay-safe pass, one basis INSERT after the CAS), so a lost settle re-driven from
the same epoch produces exactly the uninterrupted verdict.

Behaviour unchanged for: first claim; replay after the terminal / fence (gate closed → `classifyClosed` → ack, no
P2002 reached); replay before any claim (409 `run_not_started`); the other coach's claim on this coach's intent
string (J07: resolves legacy, never touches A). The frozen S10-C "two concurrent claims" case is unaffected: the
second claim's gate UPDATE blocks on the first's row lock and sees the terminal — no P2002 there.

## Invariants → tests

| Invariant | Unit (`test/scout/lifecycle/s11b-settle-redrive.spec.ts`) | Live (`test/scout/s11/settle-redrive.pg.spec.ts`, two hosts, real kill) |
|---|---|---|
| Re-drive when the settle was lost (G1) | "J16": P2002 → 2nd `$transaction` → `assertRunOpen` re-read (9, not the first gate 7, not body 42) → `isSettlePending` → `onTransferSettled(coach, intent, 9)` once | J12: P1 killed at `after-row` 2 (claim + first pass row committed) → run open/`reconciling`/completion row/no basis (asserted); status read on P2 shows `running`/`reconciling` and writes nothing; P2 replay → 1 terminal CAS, 1 basis INSERT, `settledShape` (terminal, reason, ledger tallies, id-free ledger/provenance rows, native counts, evidence, basis count) **equals the uninterrupted reference run**; J12 edge: killed at `after-row` 1 (no pass row) → identical |
| Idempotent: a second retry doesn't double-settle | "idempotent": after the re-drive the gate is closed → no 2nd `onTransferSettled`, no push | "idempotent": third claim → ack, no terminal, no basis INSERT, no non-gate write, no settled event, row and shape byte-equal, `count(ScoutRunSettledBasis)=1` |
| No settle when the original settle succeeded (no-op read) | "no settle when not pending" (`isSettlePending` false → nothing) and "J15" (gate null → nothing, no 409, no `classifyClosed`) | J15 (a): replay after a clean settle → ack, no terminal/basis/non-gate write, no push/event, row + shape unchanged |
| Epoch-fenced | "J16" epoch from the gate re-read; `isSettlePending` statement has no epoch parameter (`values = [coach, intent]`) | J15 (b): kill, then `fence revoked` on P2, then replay → ack, no terminal, row and ledger unchanged (the fence closes the gate); J12/J13 `execution_epoch` stays 1 and the terminal is the arbiter's under it. (A genuine epoch bump without a fence is not reachable through the service — unit-only, stated.) |
| Tenant-scoped | `isSettlePending` SQL pinned: `r.coach_id = ?`, completion EXISTS joined on `c.coach_id = r.coach_id`; only `[COACH, INTENT]` bound | "tenant scope": coach B's claim under A's stuck intent → legacy path (J07 rule), never A's gate, no basis, A's row/ledger byte-equal, A's completion untouched; A's own replay then settles |
| No customer side effect beyond the one existing completion push, at most once | "the replay stores nothing": push 0, capture 0, phase CAS 0, one refused INSERT; "first claim unchanged": push 1, `scout.ingest.completed` 1 | J12/J13/J14: `pushes 0`, `pushCalls []`, `scout.ingest.completed` 0 on every replay; `scout.run.settled` exactly 1 across the re-drive(s) |
| Concurrent re-drive: one terminal (J13) — **both workers provably in the re-drive branch** (review A B-1) | — | J13: after the kill, P2 and P1 both run `complete` with `pause:'before-lock'` — the harness barrier in front of the settle tail's `FOR NO KEY UPDATE`, the first such statement on the replay path. `Promise.all([a.ready, b.ready])` = `['before-lock','before-lock']` is the positive per-worker observation that each passed P2002, the eligibility gate and the pass while the run is still open (asserted: `terminal_status null`, `phase reconciling`, 0 basis rows at that moment). Both resumed; per worker: refused `INSERT INTO "ScoutImportCompletion"` followed by `-- tx:rollback`, ≥1 gate after it, exactly 1 `isSettlePending` read (`FROM "ScoutImport" r` + `phase = 'reconciling'`), ≥1 lock attempt, `pushes 0`, `scout.ingest.completed 0`, ≤1 CAS. Across both: exactly 1 terminal CAS, 1 basis INSERT, `count(ScoutRunSettledBasis)=1`, 1 `scout.run.settled`; unique ledger keys, 2 persons / 1 program |
| Stored claim preserved (J14) | "different claimed status is only a trigger": `partial` replay → refused INSERT only | J14: interrupted `partial` claim, `success` replay → completion row stays `partial`, `claimed_status:'partial'`, shape equals the uninterrupted `partial` reference |
| Before any claim (J15 c) | "a non-P2002 failure propagates" (the branch is P2002-only) | J15 (c): never-started run → 409 `run_not_started`, no completion row |

`isSettlePending` shape: "one row → true; zero → false"; the statement is `SELECT`, contains no
`UPDATE|INSERT|DELETE|FOR UPDATE|FOR SHARE`.

## Fix 1 (review A, 10:48 PM) — J13 proof repaired

Review A B-1 was right: with `pause:'locked'` on A and `pg.blocked` on B, B's *initial* claim gate could be
the statement blocking on A's tail lock; after A's terminal committed B took `RunGateClosed` and acked without
ever entering the P2002 branch, and every J13 assertion still passed. Minimum fix applied, proof only, no
product change: both workers `pause:'before-lock'`; the test waits for BOTH `ready` signals (each one is a
positive observation that the worker is past the refused claim, the eligibility gate and the pass, standing at
the tail lock), checks the run is still open/unsettled at that instant, resumes both, and asserts each trace
contains the refused completion INSERT → `-- tx:rollback`, a later gate, one eligibility read and a lock
attempt; the one-CAS / one-basis / one-event assertions are retained. `pg.blocked` is no longer used (a
worker at an IPC barrier is not in a PostgreSQL lock wait). Pre-fix bytes reconstructed and verified against
the reviewed sha (`d9a25eaa…`) before diffing.

## Notes / risks for the devloop

1. `h.on('P2','phone',{action:'fence', body:{reason:'revoked'}})` — the S11-A1 worker's `fence` action takes
   `body.reason` (default `revoked`); used for J15 (b).
2. J12 asserts `partial.length < expected.ledger_rows.length` after `after-row` 2 — relies on the pass writing
   one ledger row per per-row transaction (S8-G `gateRun` per row; verified by reading
   `scout-reconstruct.service.ts`). If a family's first row ledgers nothing, relax to `>= 0`.
3. The reference/interrupted comparison is id-free (`target_id`, `native_id`, `import_intent_id` stripped);
   ids differ by construction.
4. The worker's `done` rejects with `worker exited <code>` on `stop()`; the spec awaits that rejection.
5. Live "J16-style" assertion `replay.queries.filter(isGate).length >= 2` (claim gate + eligibility gate; the
   pass adds more).

## Heavy commands for the parent (under the canonical lock)

```
npx tsc --noEmit -p tsconfig.json
npx eslint src/scout/scout.service.ts src/scout/lifecycle/lifecycle.service.ts \
  test/scout/lifecycle/s11b-settle-redrive.spec.ts test/scout/s11/settle-redrive.pg.spec.ts
npx prettier --check src/scout/scout.service.ts src/scout/lifecycle/lifecycle.service.ts \
  test/scout/lifecycle/s11b-settle-redrive.spec.ts test/scout/s11/settle-redrive.pg.spec.ts
node scripts/check-r75.js   # (staged) — no as-unknown-as / ts-ignore added in src or test
npx jest test/scout/lifecycle test/scout/induction test/scout/reconciliation test/module-graph.spec.ts
# live (S11 lane, G2_S11_* env, S11-A1 harness present in the base, candidate head attested; alone, in band)
npx jest --runInBand test/scout/s11/settle-redrive.pg.spec.ts          # 7 live cases (J13 repaired)
npx jest --runInBand test/scout/s11/journey-core.pg.spec.ts            # J02 replay path unchanged
npx jest --config jest.rls.config.js test/rls-g2-s10c.spec.ts --runInBand --ci   # frozen S10-C still green
```
