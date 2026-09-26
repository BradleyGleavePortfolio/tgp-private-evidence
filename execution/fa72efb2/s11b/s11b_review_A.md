# S11-B NEW candidate — T4 Review A (correctness / terminal-truth lens)

Reviewer: independent Review A (EXEC-FA72EFB2, parent fa72efb2). Read-only: no jest/tsc/eslint/prettier/PG, no
lock taken, no edits, no commits. `s11b_review_B.md` not read.

Subject verified: `/home/user/workspace/worktrees/fa72-s11b`, branch `fa72/s11b`, HEAD
`45b4da1d601007c15618e358c307c26f48262a43`, tree `04c4fc8f1a989556979fc287964e01aef36b3a04`, one commit on
`3db615c0`, `git status --porcelain` empty. `git diff 3db615c0 45b4da1d --stat` = 5 files (+868/−9), matching the
builder table. Per-file sha256 recomputed and equal to the builder summary:

| Path | sha256 |
|---|---|
| `src/scout/scout.service.ts` | `d9b7b0e121c4b56f8a65573438e5e0741ad3d7ce3d8c24a5cf04446e6bb45511` |
| `src/scout/lifecycle/lifecycle.service.ts` | `7c8c42c331c028cc6246ae6be8462525e97a9847073f61ce48291ab04962fff4` |
| `test/scout/s11/settle-redrive.pg.spec.ts` | `70ddf75f33e088ac5a182a60e2fb01cd8eda052209b92e11cecc12988b743cc0` |
| `test/scout/lifecycle/s11b-settle-redrive.spec.ts` | `4a6138995b525196911ff5a1d9344de680bd9fbc6b717c215303761a105da2f2` |
| `test/rls-g2-s10c.spec.ts` | `87fd54aaab2a135752199764511016b20f30f95b2c55cf2ac8b4683455ceb7f8` |

Production delta: 25 added non-comment lines in `src/` (counted from `git diff 3db615c0 45b4da1d -- src`), 3 removed;
D-S11-8 cap ≤80 holds. No new import in either production file (both `Tx` and `PrismaClientKnownRequestError` were
already imported). No schema/route/DTO/reason-code/arbiter/reconcile change.

## Verdict: **GO** (no A or B findings; 8 C findings recorded below)

---

## Q1 — Terminal truth (J13, J15 b, J16)

**Can the P2002 re-drive path produce a terminal/basis the original settle would not?** No.

- The re-drive calls exactly the same tail with the same three arguments the first-claim path uses:
  `this.lifecycle.onTransferSettled(coachId, dto.intent_id, pending)` (`scout.service.ts` L409-413) versus
  `onTransferSettled(coachId, dto.intent_id, epoch)` (L424). `onTransferSettled` (`lifecycle.service.ts` L434-473) is
  byte-unchanged in this diff: pass with per-row gate + epoch CAS (L435-439), `classifyClosed` on a closed pass
  (L440-442), `settleWithSnapshot` tail with `lockRun` (L444), terminal-null + epoch check (L445-447), `collectFacts`
  (L448), `reconcileRun` (L453-457), `arbitrate` (L458), `writeTerminal` CAS (L459), `writeSettledBasis` in the same
  tx (L464).
- **Epoch equality.** The only writer of `execution_epoch` other than Start is `fence` (`lifecycle.service.ts` L386-391:
  `execution_epoch = execution_epoch + 1` together with `fenced_at = now()` under `FOR NO KEY UPDATE`). Nothing clears
  `fenced_at`; a replayed Start writes nothing (`startFromExisting`, L~306-318, throws or returns the body). So for any
  row with `terminal_status IS NULL AND fenced_at IS NULL` the epoch is still the Start epoch, which is the epoch the
  claim committed under. `redriveEpoch` (`scout.service.ts` L436-442) reads that epoch from `assertRunOpen`'s
  `RETURNING execution_epoch` (`lifecycle.service.ts` L638-648) inside its own tx; the branch has no epoch input and
  `ScoutCompleteDto` has no epoch field (unit J16 pins that a body-smuggled `execution_epoch: 42` cannot reach the
  tail, `s11b-settle-redrive.spec.ts` L122-150).
- **Claim input.** `collectFacts` reads the stored `ScoutImportCompletion.terminal_status` (`lifecycle.service.ts`
  L585-589). The replay's own INSERT (`scout.service.ts` L386-393) is the refused statement inside a tx that rolled
  back; no update/upsert of that table exists on the server path (`rg scoutImportCompletion\.(create|update|upsert|delete)
  src` → only L311 legacy `create` and L386 server `create`). So the arbiter input is the first claim, exactly as an
  uninterrupted run.
- **Staged/ledger/provenance facts** come from the DB at tail time in both paths; the pass is provenance-first
  (`native-writers.ts` L92-99 `findProvenance` before any create; L66-89 `verifyTarget` reads the target only) and
  the ledger write is an upsert + precedence UPDATE (`scout-reconstruct.service.ts` L558-612), so a re-run on rows the
  killed pass already committed yields the same `status/reason/target_kind`. Live J12/J12-edge/J13/J14 assert
  `settledShape(...) toEqual(reference)` against an uninterrupted run (`settledRedrive.pg.spec.ts` L275, L315, L372,
  L395), which is the right customer-visible check.

**Settle twice?** No. Terminal: single CAS `terminal_status IS NULL AND execution_epoch = $epoch` under the row
lock (`lifecycle.service.ts` L527-534). Basis: inserted only after `writeTerminal` returned true in the same tx
(L459-464), PK `(coach_id,intent_id)` (L544-545). A second re-drive (or a still-running original) is the L445-447
`return null` path — the accepted "a miss is not an error". After a terminal, the next replay's claim gate returns
0 rows → `RunGateClosed` → `classifyClosed` → ack (L400-404); P2002 is never reached (live J12 tail L283-297,
J15 a L398-419; unit "idempotent" L199-214).

**Settle a run whose epoch/fence was revoked?** No. `fence` writes `fenced_at`, `epoch+1` and the terminal in one
tx (L383-403). Any later replay meets a closed claim gate (`assertRunOpen` L643-644 requires `terminal_status IS NULL
AND fenced_at IS NULL`) and never reaches P2002 (live J15 b L421-452 with `revoked`, epoch 2, asserts no completion
INSERT, no pending read, no terminal, no basis, no non-gate write, row/ledger unchanged). A fence landing **between**
`redriveEpoch` commit and the tail is the existing race: pass gate closes → `RunPassStopped` → `stopped='gate_closed'`
→ `classifyClosed` (read-only when terminal set) → tail `lockRun` sees `terminal_status !== null` or `execution_epoch
!== epoch` → null (L445-447). A fence landing during the tail blocks on the tail's `FOR NO KEY UPDATE` and then sees
the terminal (L384). Identical to the first-claim path.

**J13 (two concurrent re-drives).** Both pass P2002 and `redriveEpoch` (each is a short tx; the gate UPDATE holds the
row only until that tx commits). Both passes run; per-row txs serialize on the gate UPDATE lock
(`scout-reconstruct.service.ts` L475-479, `lifecycle.service.ts` L632-636), and the second worker's row tx starts after
the first committed, so `findProvenance` sees the row and takes `verifyTarget`. Tail: the first `lockRun` wins and
writes; the second, under REPEATABLE READ with its snapshot taken at the blocked `lockRun` statement, gets 40001 →
P2034 → `settleWithSnapshot` retries (L490-500, `SETTLE_ATTEMPTS = 3` L53) → fresh snapshot sees the terminal → null,
no write. One terminal, one basis, one `scout.run.settled` — exactly what J13 asserts (L360-366).

## Q2 — Replay semantics (J14, J12 tail, J15 a/c)

- **Stored claim preserved (J14).** The only `ScoutImportCompletion` statement on the replay path is the refused
  INSERT in the rolled-back claim tx (`scout.service.ts` L386-393). Live J14 asserts every write naming that table
  equals the set of completion INSERTs (`settle-redrive.pg.spec.ts` L387-389), the row stays `partial` (L390), the
  status read reports `claimed_status:'partial'` (L393) and the shape equals the uninterrupted `partial` reference
  (L395). Unit J14 shadow asserts the tx object exposes only `create` (L173-175). Never overwritten. ✔
- **Non-pending gate = pure ack?** Two sub-cases:
  - Gate **closed** (terminal/fenced/expired/no row): `redriveEpoch` is not reached — the claim tx's own gate returned
    0 rows first → `RunGateClosed` → `classifyClosed` → ack or 409 `run_not_started` (L400-404). The only statement
    issued is the 0-row gate UPDATE (no write lands). Live J15 a/b assert `isNonGateWrite` empty; J15 c asserts 409 on
    both hosts with no completion INSERT/read and no run row (L454-465). ✔ Unit J15 shadow additionally pins the
    (in practice unreachable, see C-8) "gate closes between refused claim and re-drive" branch: ack, no read, no
    `classifyClosed`, no 409 (L189-197). ✔
  - Gate **open but not pending** (`isSettlePending` false): `redriveEpoch` returns null → ack, no settle (unit
    L179-187). This does commit the gate's `last_observed_at` bump — see C-4; it is not a claim/phase/terminal write.
- **J12 tail.** Third claim after the re-drive: ack, no completion INSERT, no pending read, no terminal, no basis, no
  non-gate write, no push/event, `runRow` and shape byte-equal, `count(basis)=1` (L283-297). ✔

## Q3 — Unknown never zero / no fabricated server behaviour

No path turns an unknown into complete/zero:
- The branch computes nothing: it either hands the DB-derived epoch to the unchanged tail or returns the pre-existing
  ack. `isSettlePending` is `rows.length === 1` of a SELECT with no aggregate, no default (`lifecycle.service.ts`
  L658-667).
- An ineligible or contended replay ends in `ack` with the run still open (truthful: the status read shows `running`/
  `reconciling`, live J12 L249-257) and the lazy deadline still ends it `timed_out` (D-S11-4 "A dead extension is
  still ended truthfully by the lazy deadline").
- Any non-P2002 failure propagates (`throw err` L415; unit "P2002-only" L225-238). Any pass failure propagates from
  `onTransferSettled` unchanged ("nothing terminal is ever written from a failed pass", L425-427).
- No push, no `SCOUT_INGEST_COMPLETED` on a re-drive: those statements stay after the `try` on the first-claim path
  only (L418-423); every live replay asserts `pushes 0`, `pushCalls []`, `scout.ingest.completed 0` (L232-236).

## Q4 — Do the tests discriminate?

**Unit spec (11 cases).** Plausible wrong implementations and the case that fails:
- Re-drive with the claim tx's `seen` (or a body value) → J16 asserts `onTransferSettled(COACH, INTENT, 9)` and
  `not 7 / not 42` (L143-145) with distinct fixture epochs 7/9. ✔
- No second gate / pending read outside the gate's tx → J16 asserts `assertRunOpen` called with `redriveTx` and
  `isSettlePending` called with the same `redriveTx`, gate before read (L132-141). ✔
- Ignore `isSettlePending` → "not pending" case asserts `onTransferSettled` not called (L184). ✔
- 409/`classifyClosed` on a closed re-drive gate → J15 shadow (L192-196). ✔
- Push/capture on re-drive → L158-159, L185-186, L212-213. ✔
- Regress the first-claim path → "first claim unchanged" (L240-255). ✔
- Helper SQL shape (SELECT-only, tenant-bound, no lock, no `execution_epoch`, no `last_observed_at`) → L287-307. ✔
- Weak spot (C-1): the comment at L146 ("decided after the eligibility transaction returned, not inside it") is not
  what L147-149 proves — it only orders the two calls, which also holds if the settle ran inside the tx. The live spec
  catches that wrong implementation (a settle inside the gate tx would block every per-row gate on the outer row lock
  → Prisma tx timeout → `replay.failure` defined in J12).

**Live spec (8 cases).**
- No re-drive at all → `expectRedriveTrace` fails (no pending read / no lock, L216-230), terminal null (L270). ✔
- Re-drive that pushes / re-emits → `expectNoClaimSideEffects` (L232-236). ✔
- Re-drive that rewrites the claim → J14 L387-390. ✔
- Re-drive that reaches a fenced/settled run → J15 a/b assert empty INSERT/read/terminal/basis/non-gate-write sets. ✔
- Cross-tenant leak → tenant case asserts no gate/read/terminal/basis/lock on B's call and A's row/targets/claims
  byte-equal (L474-484). ✔
- Verdict drift → `settledShape` equality against an uninterrupted reference in J12/J12-edge/J13/J14. ✔

**J13 barrier — does it prove both workers are in the re-drive branch?** Yes.
- The S11 worker's `before-lock` barrier fires in `$queryRaw` immediately before any statement containing
  `FOR NO KEY UPDATE` (`g2-s11-worker.cjs` L193-194, L237). On the replay path the first such statement is the tail's
  `lockRun` (`lifecycle.service.ts` L506-513): the claim tx has none (gate UPDATE + INSERT), `redriveEpoch` has none
  (gate UPDATE + the SELECT whose text the unit spec pins lock-free, L303), the pass has none (`rg "FOR NO KEY UPDATE"
  src/scout` → only `lifecycle.service.ts` L512 and `observation.service.ts` L330, the declaration route). The
  `fence` lock (via `classifyClosed`) is only reachable when a pass gate closed, which J13 asserts did not happen
  (run open/`reconciling`/unfenced at the barrier, L343-348).
- The first-claim path cannot be the route to the lock because `completeAndKill` asserted the completion row already
  exists (L208-210), so each worker's claim INSERT must be refused; `expectRedriveTrace(r)` per worker (L355) then
  positively asserts refused INSERT → `-- tx:rollback` → gate → exactly one pending read → lock, in order.
- Both `ready` values are awaited before either `resume()` (L341, L349-350); `paused` in the worker is one-shot
  (L185-190), so the loser's P2034 retry does not re-pause. Reaching the barrier means P2002 + eligibility + pass are
  complete for that worker while neither holds the row. ✔ (C-3 on the hang mode if a worker never pauses.)

**R36 flip in `test/rls-g2-s10c.spec.ts`.** `git diff 3db615c0 45b4da1d -- test/rls-g2-s10c.spec.ts` is one hunk,
L238-248: four expectations flipped `0→1`, `0→1`, `toBeNull→not.toBeNull`, `0→1`; `retry.failure` undefined and
`retry.pushes === 0` kept; a 2-line comment replaced by a 4-line one. Nothing else in the file changed. The
injected-failure half (L228-237: terminal NULL, reason NULL, basis 0, no settled event, `-- tx:rollback`) is
untouched, so the R36 invariant "CAS miss or insert failure → no terminal, no basis" still holds for the failing
settle; only the *retry* semantics changed, which is exactly D-S11-4 (after the rolled-back tail the run is open in
`reconciling` with its completion row). Not weaker: the new lines assert exactly one CAS, exactly one basis INSERT,
terminal not null and `count(SETTLED)=1`. (C-6: the `describe`/`it` titles were not updated; they remain accurate for
the injected failure but no longer describe the retry.)

## Q5 — First-run risk for the single real-PG proof

Builder C-2 (J13: paused tail inside a 20 000 ms `S9_SNAPSHOT_TX_OPTIONS` tx, `lifecycle.service.ts` L63-67; the
worker applies fixture `txTimeout` only when `options.length === 0`, `g2-s11-worker.cjs` L217-219): I agree it is
**C**, not A/B.
- Exposure = skew between the two workers reaching `before-lock` + two sync `psql` reads (L343-348) + `resume()`.
  Both workers are forked back-to-back (L339-340) and run the same 5-row pass interleaved on the gate lock; the
  first arriver's tail tx has issued only BEGIN/SET TRANSACTION (no snapshot yet in PG, no lock held), so it does not
  slow the other. Expected wait is seconds; 20 s is a wide margin on a quiet 2-CPU host, and the accepted S10-C
  `pause:'locked'` case already lived under the same ceiling.
- After resume the loser blocks on `lockRun` for the winner's tail (sub-second for 5 rows) and then retries with a
  fresh tx and timer (L490-500), so the 20 s ceiling is not cumulative across the race.
- If it does flake: the failure is a Prisma P2028 in one worker (`r.failure` defined, L353), not a wrong terminal, and
  the minimum closure is harness-side (S11-A1 owner): let the worker merge `{ ...options[0], timeout: input.txTimeout }`
  when `txTimeout` is set, or accept a single re-run. No product change; not a reason to hold the proof.

Other first-run observations (all C): C-3 (hang-to-600 s mode only on a broken candidate), builder C-3/C-4 stand as
written (partial-ledger bound ≥1 holds because every gated per-row tx writes its ledger row in the same tx,
`scout-reconstruct.service.ts` L475-525, L549-556).

---

## Findings (Safety ROI)

No A. No B.

- **C-1 — unit comment overclaims.** `s11b-settle-redrive.spec.ts` L146 says the settle is proven to run "after the
  eligibility transaction returned"; L147-149 only order `isSettlePending` before `onTransferSettled`. Live J12 is
  the real discriminator for an in-tx settle. Record; optionally reword the comment when the file is next touched.
- **C-2 — J13 20 s tail ceiling** (builder C-2). Agreed C; closure harness-side only if observed (above).
- **C-3 — `ready` never rejects.** `g2-s11-pg-harness.ts` L159-162: if a worker never reaches its pause phase
  (`completeAndKill` L198, J13 L341), the test waits for `jest.setTimeout(600000)` instead of failing fast. Only bites a
  broken candidate; inherited S11-A1 pattern, not S11-B's to fix.
- **C-4 — the re-drive gate commits a heartbeat.** `redriveEpoch`'s `assertRunOpen` UPDATE (`lifecycle.service.ts`
  L639-646) commits `last_observed_at = now()` on every P2002 replay against an open run (the claim tx's gate was
  rolled back). `last_observed_at` is only reported (`lifecycle.service.ts` L1048, `scout.dto.ts` L409); nothing derives
  `deadline_at` from it (`rg last_observed_at src` → L641 write, L744/L1048 read only). Truthful (a writer did observe
  the run); the live spec's `isNonGateWrite` wording (`settle-redrive.pg.spec.ts` L64-65) already carves it out.
- **C-5 — G1 death before the push leaves the coach with no `import.complete` push.** With `pauseRow:1` the victim
  dies after the claim commit and before `notifyComplete` (`scout.service.ts` L384-399 → L418); the re-drive pushes
  nothing by D-S11-4. So in that sub-case no push is ever sent for the run. Design-accepted (push is first-claim-only,
  status read is truthful); record for the roadmap, no change requested.
- **C-6 — R36 titles.** `test/rls-g2-s10c.spec.ts` L226-227 titles still read "no terminal, no basis" / "rolls the
  terminal back"; accurate for the injected failure, silent about the retry re-drive. Cosmetic.
- **C-7 — `redriveEpoch` under contention.** Its tx uses Prisma's default interactive timeout (no options,
  `scout.service.ts` L437). If the gate UPDATE waits behind a concurrent settle tail holding `FOR NO KEY UPDATE` (up to
  20 s), the replay fails with P2028 → 500, with nothing committed (the UPDATE rolls back). The client's next replay
  meets the terminal → ack. Same exposure the claim tx already has (S10-C two-concurrent-claims); not new.
- **C-8 — `isSettlePending` is defense in depth.** After a P2002 on an open gate, `phase='reconciling'` and the
  completion row were committed atomically by the first claim (`scout.service.ts` L386-398, under the gate lock so the
  phase CAS always matches), and no writer moves `phase` off `reconciling` (`rg "phase =" src/scout` → Start
  `discovering`, gate `discovering→transferring`, claim `→reconciling`). The `pending === null` on an open gate is
  unit-only. Fine — D-S11-4 asks for the explicit predicate, and it costs one indexed SELECT.

## Mission invariants

Core diff 0 (no platform slug keyed; helper is tenant/intent-bound only); no model-generated JS; unknown never zero
(Q3); no fabricated server behaviour in UI (ack unchanged, status read unchanged); owner-reserved boundaries untouched
(no route, flag, principal, G3-AUTH, CWS, production change). R75 staged check RC=0 per builder log.

## Commands run (all read-only, none heavy, no lock)

| Command | RC |
|---|---|
| `cat WORKER_RULES.md S11B_REVIEW_GRANT.md S11B_NEW_CANDIDATE_GRANT.md s11b_builder_summary.md s11b_new_candidate_src.diff` + gate logs | 0 |
| `git log --oneline -3; git status --porcelain; git rev-parse HEAD; git rev-parse HEAD^{tree}; git diff 3db615c0 45b4da1d --stat` (in the clone) | 0 |
| `git diff 3db615c0 45b4da1d -- test/rls-g2-s10c.spec.ts`; `git diff 3db615c0 45b4da1d -- src \| rg …` (non-comment LOC = 25) | 0 |
| `sed`/`cat -n` reads: `docs/decisions/2026-09-26-s11-journey.md` (G1, D-S11-4, D-S11-7, J09-J18), `src/scout/scout.service.ts` L270-450, `src/scout/lifecycle/lifecycle.service.ts` L55-75, L262-345, L365-720, `src/scout/scout-reconstruct.service.ts` L173-205, L236-290, L366-560, `src/scout/reconstruct/native/native-writers.ts` L55-100, `test/scout/lifecycle/s11b-settle-redrive.spec.ts` (all), `test/scout/s11/settle-redrive.pg.spec.ts` (all), `test/rls-g2-s10c.spec.ts` L70-80, L200-250, `test/utils/g2-s11-worker.cjs` L180-260, L318-330, `test/utils/g2-s11-pg-harness.ts` L150-206, `test/utils/g2-s11-harness.ts` L185-260 | 0 |
| `rg` over `src/scout` for `execution_epoch =`, `phase =`, `FOR NO KEY UPDATE`, `last_observed_at`, `scoutImportCompletion.(create\|update\|upsert\|delete)`, `FROM "ScoutImport" r`, `SETTLE_ATTEMPTS`, `startFromExisting`; over the worker for barrier/txTimeout/markers | 0 |
| `sha256sum` of the 5 owned files | 0 |

Not run (grant): jest, tsc, eslint, prettier, any PG lane, `check-r75`. Nothing written outside this report.

## Open risks (for the parent's live run)

1. Live proof unobserved by me; my GO is from code reading. The 8 live cases + flipped R36 are the binding.
2. C-2 timing (J13) — flake, not truth risk; closure harness-side.
3. C-3 hang mode would cost up to 600 s only if the candidate were broken in a way the unit spec did not catch.
