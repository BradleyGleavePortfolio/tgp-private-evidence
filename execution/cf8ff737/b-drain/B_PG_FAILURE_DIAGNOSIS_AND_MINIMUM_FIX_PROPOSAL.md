# B single PG proof failure — source-only diagnosis and minimum-fix proposal

Builder `b_drain_exact_recovery_and_remainder_mufn6ybc`, 2026-09-24 15:20Z. Read-only over head `75a2863b` and the preserved `runtime/run/jest.log`. No source edits, runtime, install, retry or rerun performed. Peer reviews not read. Failed run immutable (`runtime/run/RECEIPTS.sha256`).

## 1. Failed-run report (bounded)

Covered in `B_SINGLE_PG_PROOF_RESULT.md`: runner `a64d24de…` once, `timeout -k 30 3600`; RC=1 STAGE=jest; 8 failed / 11 passed / 19; Jest exited by itself at 15:14:49Z after the open-handle warning (~2 min after the 52 s run). **No owned TERM was sent by this builder**; the runner's own first-failure cleanup ran (`CLEANUP_STOP rc=0 postgres_procs=0 port55461_listeners=0`), slot released 15:14:50Z, datadir retained.

## 2. Failure map — one primary defect plus cascades

| # | Test | Observed | Class |
|---|---|---|---|
| 1 | st5 `resolves exactly the 1230…` (spec:418) | `fenced:false` expected `true`; every count matched | primary |
| 2 | st5 `forward provenance recovery…` | `fenced:false`; counts matched | primary |
| 3 | st6 `skips a row locked…` (spec:509) | outcome `complete_unfenced` expected `drained`; examined/updated matched | primary |
| 4 | st6 `T paused after reading staging…` (spec:518) | outcome `complete_unfenced` expected `drained` | primary |
| 5 | st6 `T paused inside its claim…` (spec:525) | `nullify(...)` 20 expected, 0 received | cascade of #4 aborting before its rows were re-opened |
| 6 | st6 `a concurrent staging writer…` (spec:569) | outcome `complete_unfenced` expected `drained` | primary |
| 7 | st7 `down keeps column…` (spec:597) | `down.sql:70 ERROR: G2-B fence absent` | primary (same predicate, in SQL) |
| 8 | st7 `re-applying the file restores…` | `migration.sql:68 ERROR: G2-B fence already present` | cascade of #7 (trigger never dropped) |

Proof the fence *is* installed and effective in the same database: stage-4 `prisma migrate deploy applies exactly B…` passed asserting the trigger tuple `['ScoutReconstructionLedger_platform_fence','O',7,FENCE_TRIGGER_DEFINITION]` and function `prosecdef:false`, and `refuses a NULL-provenance INSERT…` / `the actual O binary fails closed…` passed. So the fence exists and fires; only the **structural detector predicate** reports it absent. Note `migration.sql`'s own presence check (line 61–64) matches by `tgrelid`+`tgname` only and correctly said "already present" — consistent with the trigger being there.

## 3. Root cause (source-level, high confidence; one-query live confirmation still pending)

Both detector copies contain the term

```sql
AND t.tgattr::int2[] = '{}'::int2[]
```

- `src/scout/scout-ledger-backfill.ts:257` (inside `readDrainState`, the only place `fenced` is computed; `decideOutcome` at :114 maps `fenced=false` → `complete_unfenced`, i.e. exactly failures 1–4, 6).
- `prisma/migrations/20270119000000_scout_ledger_obsolete_writer_fence/down.sql:64` (the `IF NOT EXISTS … RAISE 'G2-B fence absent'` guard, failure 7).

`pg_trigger.tgattr` is `int2vector`. For a trigger with no column list PostgreSQL stores an *empty one-dimensional* int2vector (`buildint2vector(NULL,0)`: `ndim=1, dim1=0, lbound1=0`). Casting it to `int2[]` keeps that header, whereas the literal `'{}'::int2[]` is a zero-dimension array. Array equality (`array_eq`) compares `ndim` and dims before elements, so `'{}'`(ndim 0) ≠ empty int2vector (ndim 1) → the row is excluded → `fences = 0` → `fenced = false`, and the same in `down.sql`. Every other term in the predicate was independently confirmed by the passing stage-4 assertions (`tgtype=7`, `tgenabled='O'`, function name/schema/`pronargs=0`/`prosecdef=false`) or is trivially true (`tgqual IS NULL`, `tgnargs=0`, `tgconstraint=0`, `NOT tgisinternal`).

Why it was never caught: the predicate was introduced in v3 (`V3_CLOSURE_MAP.md` §1 A-BD-FENCE, replacing the `pg_get_triggerdef` text compare) and v3/v4 were only exercised by the DB-free unit fake (`scout-ledger-backfill.spec.ts:102` returns `{fences: this.fenced?1:0}` for any query containing `pg_trigger`) — the RC71 environment failure meant this was the first execution of the predicate against a real server. C1/S5 never contained it.

## 4. Harm / decision / closure / unlock

- **Harm (B, proof-invalidating; not A):** the operator CLI would report `complete_unfenced` (exit 4) on a correctly fenced ledger and `down.sql` would refuse a legitimate rollback. No customer/data harm: the fence itself, RLS, migration and backfill writes behaved as specified (stages 1–4 pass, counts match). Local disposable fixture only.
- **Decision blocked:** B/drain acceptance and the G2-B PG proof.
- **Minimum closure (2 lines, both files, identical semantics):** replace `t.tgattr::int2[] = '{}'::int2[]` with `cardinality(t.tgattr::int2[]) = 0` (returns 0 for both the zero-dim literal and the empty 1-dim vector; still rejects any column-list trigger). Alternative with identical effect: `coalesce(array_length(t.tgattr::int2[],1),0) = 0`. No spec change, no fixture/harness change, no migration.sql change, no gate change; `FENCE_TRIGGER_TYPE`/`FENCE_TRIGGER_DEFINITION` untouched; the DB-free fake still dispatches on `pg_trigger`.
- **Confirmation before/with the fix (reviewer-runnable, read-only, one statement on any PG17):** `SELECT tgattr::int2[] = '{}'::int2[] AS eq, cardinality(tgattr::int2[]) AS n FROM pg_trigger WHERE tgname='ScoutReconstructionLedger_platform_fence';` — expected today `eq=false, n=0` on the retained datadir (requires starting the fixture; not done here).
- **Execution unlocked once granted:** new candidate v5 = head `75a2863b` + the two-line change → ordinary path only: stage 2 files, affected gates (tsc/eslint/prettier/check-r75/jest unit), hooked Bradley commit with an amended-scope message (new commit, no `--amend`), five-placeholder refill of the sealed binding for the new head/tree/blob pins, then **one** new single PG proof. Expected to clear #1–4, 6, 7 directly and #5, 8 as cascades; if any of the 8 remains after the fix, that is a genuinely different defect and stops again. Predecessor RC=1 run stays as-is.

## 5. Residual C (nonblocking)

- Jest open-handle warning (`Jest did not exit one second after the test run`) delayed exit ~2 min after failures; likely an un-closed Prisma/pg client on the failed path. Does not affect results; not part of the minimum fix.
- Runner precondition prints `jest=30.4.1` (CLI banner) while the package resolved is 30.4.2 (from `.package-lock.json`); recorded, not a pin.
