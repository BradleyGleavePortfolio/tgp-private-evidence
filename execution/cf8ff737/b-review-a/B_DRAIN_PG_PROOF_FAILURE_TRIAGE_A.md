# B/drain — single PG proof failure triage (reviewer A, successor; same review, not a final pass)

Inputs: `execution/95633079/s7-b-drain/runtime/run/{b-pg-proof.log,jest.log,b-pg-proof.sentinel}` (raw, preserved), committed head `75a2863b…` read via `git show HEAD:…` only for the lines the failures point at. No rerun, no PG start, no peer B report, no broad source re-audit. Fable/High requested only; no telemetry claimed.

## 0. Run facts (recomputed from receipts)
Sentinel `RC=1 STAGE=jest END=2026-09-24T15:14:50Z HEAD=75a2863b…`. Bootstrap rc 0 (164 migrations applied, O client generated with pinned engine `a2924eab…`, candidate client verified), `IDENTITY_OK` (PG 170006, cluster `b-disposable-pg17`), jest `--config jest.rls.config.js test/rls-g2-b-drain.spec.ts --runInBand --ci` → **1 suite failed, 8 failed / 11 passed / 19 total, 52.1 s**, `STOP_FIRST_FAILURE stage=jest`, fixture stop OK, `CLEANUP_STOP rc=0 postgres_procs=0 port55461_listeners=0`. Head unchanged; worktree clean. The "open handles" observation is moot: JEST_END was written at 15:14:49Z and the stop/cleanup completed; no TERM was needed (C, continue).

## 1. Test count: 19 is the count the committed spec defines
`git show HEAD:test/rls-g2-b-drain.spec.ts` (blob `9b31fd18…`, the pinned spec) contains exactly **19** top-level `it(` blocks — stage 1: 1, stage 2: 2, stage 3: 2, stage 4: 4, stage 5: 4, stage 6: 4, stage 7: 2 — with zero `it.skip/todo/each` and no generated cases. Jest's 19 total therefore matches the source exactly. The figure 26 does not occur in reviewer A's source review, fixture review, the phase-A grant, or the sealed proof template, and nothing in the spec produces it; it is not derivable from the committed source and should be treated as a stale non-source expectation. No criteria change.

## 2. The 8 failures — one root cause, two cascades

| # | Test | Observed | Cause |
|---|---|---|---|
| F1 | st5 resolves 1230 in three chunks | `fenced:false` (expected true); counts otherwise exact (nullBefore 1238, nullAfter 8, mismatch 2, outcome unresolved) | **RC** |
| F2 | st5 forward provenance recovery | `fenced:false`, `outcome complete_unfenced` (expected drained) | RC |
| F3 | st6 locked row … drains after release | outcome `complete_unfenced` (passes[0] examined 1/updated 1 correct) | RC |
| F4 | st6 T paused after reading staging | outcome `complete_unfenced` at line 518 | RC |
| F5 | st6 T paused inside its claim | `nullify(intent_id='i3')` 0 (expected 20) | cascade of F4: assertion threw before `paused.release()`/`paused.done`, so T's 20 i3 rows were never reconstructed |
| F6 | st6 concurrent staging writer | outcome `complete_unfenced` | RC |
| F7 | st7 down keeps column/rows | `down.sql:70 ERROR: G2-B fence absent` | RC (same predicate in SQL) |
| F8 | st7 re-applying restores fence | psql error at spec 597 | cascade of F7 (fence never removed → re-apply hits its own "already present" refusal) |

Everything the fence *does* is proven present in the same run: stage 3 `prisma migrate deploy` applied exactly B and `fence()` matched the shipped trigger/function shape; stage 4 shows the trigger firing (NULL-provenance INSERT refused for owner and runtime role; O fails closed; T claims through the fence). So the fence exists and works; what fails is the **structural fence-identity probe** that decides `fenced`.

### Root cause (exact)
Both probes share one predicate on `pg_catalog.pg_trigger`:
- `src/scout/scout-ledger-backfill.ts:257` — `AND t.tgattr::int2[] = '{}'::int2[]`
- `prisma/migrations/20270119000000_scout_ledger_obsolete_writer_fence/down.sql:64` — `AND t.tgattr::int2[] = '{}'::int2[]`

For a trigger without a column list, PostgreSQL stores `tgattr` as an `int2vector` built by `buildint2vector(NULL, 0)`, which has **ndim = 1, dim1 = 0, lbound 0**; the literal `'{}'::int2[]` has **ndim = 0**. `array_eq` compares dimensionality before elements and returns false when ndims differ, so this predicate is false for exactly the trigger it is meant to recognise. The remaining shared predicates (`tgtype = 7`, `tgqual IS NULL`, `tgnargs = 0`, `tgconstraint = 0`, `pronargs = 0`, `tgenabled <> 'D'` / `NOT prosecdef`) are constants that hold for the shipped trigger. Net effect: `fenced` is always false → `decideOutcome` yields `complete_unfenced` instead of `drained`, and `down.sql` always raises `G2-B fence absent`.

Confidence: high — inferred from PostgreSQL's int2vector construction plus the run evidence (trigger demonstrably present and firing; both independent checks with the same predicate fail; no other predicate can differ). The single confirming observation is one catalog row (`SELECT tgattr::int2[] = '{}'::int2[], cardinality(tgattr), array_ndims(tgattr::int2[]) FROM pg_trigger WHERE tgname = 'ScoutReconstructionLedger_platform_fence'`) which the executor can take inside the next authorised run's existing fixture; no new mechanism.

Why phase A did not catch it: the unit spec `scout-ledger-backfill.spec.ts` (42 tests, passed) exercises the probe against a fake that returns the count the code expects, i.e. it encodes the same array-equality assumption; my static v4 source trace likewise did not evaluate int2vector/int2[] comparison semantics. This is a genuine miss of reviewer A's source review and is recorded as such; the PG proof did its job.

## 3. Classification — **A** (real product consequence)
- **Harm:** as shipped, the operator entry `scout-ledger-backfill.cli` can never report `drained` or exit 0 even after a complete, fenced drain (exit code path lines 294–299 makes only `drained` → 0); every complete drain is mis-reported as `complete_unfenced`. The `down.sql` rollback for B is unusable (always refuses). Both are truthfulness/operability defects on the G2-B product path.
- **Blocked decision:** acceptance of the B/drain candidate at head `75a2863b…` and any "drain complete" claim derived from it. The v4 SOURCE_GRANTABLE verdict was a phase-A source verdict; it does not stand as product acceptance and the failed proof is recorded as a failure, not rewritten.
- **Not blocked:** phase-A environment/hook/gate/identity receipts (still valid for the same base and tooling); the fixture/proof template (it worked end-to-end and stopped honestly); C1/S5 lanes; J3's use of the slot.
- **Minimum closure:** a v5 candidate on the same base `a0ea1bea…` that changes only the two predicate lines to an int2vector-native emptiness test, identically in both places — e.g. `AND t.tgattr = ''::int2vector` (or `cardinality(t.tgattr) = 0`) — so the structural identity remains "no column list". No spec change (19 tests unchanged, criteria unmoved), no template change, no new control. Optional C follow-up, not required for closure: make the unit fake's `fences` answer depend on the corrected predicate text so it cannot pass on the old one again.
- **Execution unlocked on closure:** phase-A remainder on v5 (env already recovered; hooks/gates/hooked commit as before, minutes), mechanical re-fill of the five pins (`EXPECT_HEAD`, `EXPECT_TREE`, spec blob unchanged unless touched, bootstrap blob unchanged, fixture sha unchanged), then one PG proof run under a fresh single-run grant when the slot is free. Expected: the 6 RC failures and 2 cascades resolve with no other change; if stage 5–7 then expose anything further it is new evidence, not a repeat.

## 4. C items (record, continue)
- Down-file run under `--single-transaction` while the file has its own `BEGIN` → psql WARNING "already a transaction in progress"; harmless, same shape passed in stage 3's raw-rerun refusal test.
- Run/cleanup hygiene was correct (no survivors, data dir retained per template); no TERM needed.

Files: this note; `MANIFEST.sha256` updated. Nothing else written.
