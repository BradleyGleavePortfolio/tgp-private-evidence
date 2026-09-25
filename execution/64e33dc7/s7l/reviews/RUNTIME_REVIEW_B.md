# S7-L runtime failure disposition — independent reviewer B (non-builder)

Written 2026-09-25 ~05:16Z after the parent reported terminal cleanup observed (05:14:22Z).
Read-only: no tests, probes, Git, PG, installs or peer reads. `REVIEW_B.md` and `REVIEW_B_V2.md`
are untouched. This file is the only artifact created for this disposition.

## 0. Run identity (as observed in the receipts)

| Item | Observed |
|---|---|
| Driver | `s7l/binding/v2/s7l-pg-proof.sh` (v2 binding, BINDING.sha256 `01985b85…`), launched `timeout -k 30 3900`, `setsid -f` (`run/LAUNCHER.txt`) |
| Head | `54970cd937afc8dea689b33243961abfef8b9dd6` (`JEST_START` line 546, sentinel) |
| Cluster | pg17 `170006`, `g2_s7l_disposable`, port 55641, `applied=171` after OLD-root bootstrap (`BOOTSTRAP rc=0 05:06:58Z`, `IDENTITY_OK 05:06:59Z`, `s7l_columns_before=0`) |
| Jest | `JEST_START 05:06:59Z` → terminal summary `Tests: 21 failed, 3 passed, 24 total`, `Time: 294.68 s`; "Jest did not exit one second after the test run has completed" (open handles) |
| Termination | `run/PARENT_TERM.txt`: parent verified stage PGID 19276 / jest pid 19277 / driver pid 17284 untouched; TERM sent 05:14:22Z after the completed failed summary |
| Driver end | `JEST_END rc=124 05:14:22Z`; `POST_JEST applied_migrations=171`; `STOP_FIRST_FAILURE stage=jest rc=124`; `S7L_FIXTURE_STOP_OK`; `CLEANUP_STOP rc=0 postgres_procs=0 port55641_listeners=0 survivor_pid=none`; `END rc=124 stage=jest`; `LAUNCHER_EXIT rc=124 05:14:22Z` |
| Sentinel | `RC=124 STAGE=jest END=2026-09-25T05:14:22Z HEAD=54970cd9… LOCK_INODE=691716` |
| Receipts | `RECEIPTS.sha256`: jest.log `d6253d28…` (matches current file); s7l-pg-proof.log `63d58094…` = hash of the log **without** its final `END` line (recomputed; the receipt is taken at driver line 80 before the `END` log at line 82). Current full log `2eae19cd…`. Recorded as C-R4. |

Result: **failed run, not accepted.** Nothing below changes that.

## 1. First causal failure (the only independent failure)

**Test:** `stage 1 › a held transaction on the run table makes up hit lock_timeout (55P03); nothing applied; release → free` — `test/rls-g2-s7l.spec.ts` L263-279.

**Observed (jest.log L28-52):** `refusedFile(upFile, '55P03')` (spec L269) received
```
psql:…/20270123000000_scout_run_lifecycle_expand/migration.sql:25: WARNING:  there is already a transaction in progress
psql:…/20270123000000_scout_run_lifecycle_expand/migration.sql:28: ERROR:  canceling statement due to lock timeout
```
and failed `toContain("55P03")` at `test/utils/g2-s7l-pg-harness.ts` L100.

**Product behaviour was correct.** `migration.sql` L25-28 (`BEGIN; SET LOCAL lock_timeout='5s'; … LOCK TABLE public."ScoutImport" IN ACCESS EXCLUSIVE MODE;`) was cancelled by its own `lock_timeout` while a `service_role` holder held `SELECT … FOR UPDATE` on the run table (spec L264-265, harness `holdTransaction` L228-247). The error *is* SQLSTATE 55P03 (`lock_not_available`, message "canceling statement due to lock timeout"). The file did not apply: every later stanza observes the OLD shape (`column "mode" of relation "ScoutImport" does not exist`, jest.log L122 and L135) and `POST_JEST applied_migrations=171`.

**Proof defect.** psql at default `VERBOSITY` prints only the message text, never the SQLSTATE; `-qAt -v ON_ERROR_STOP=1` (harness L58) does not change that. The expected substring `'55P03'` can never appear in the received string on this psql invocation, so the stanza fails deterministically regardless of product correctness. The accepted S8-B proof asserted this exact scenario with `expect(String(error)).toMatch(/canceling statement due to lock timeout/)` (`test/rls-g2-s8b.spec.ts` L254) — the S7-L spec deviated from the accepted pattern. My REVIEW_B.md listed the lock-timeout stanza among the "unverified runtime" items; I did not catch the literal mismatch statically and record that here.

**Classification: B (proof defect; blocks only this proof).**
- Concrete harm: the PG proof cannot pass on any run; one PG grant burned (~7.5 min wall clock including parent TERM); F1/F2 closures and every L01-L12 claim remain runtime-unverified.
- Exact decision blocked: acceptance of S7-L on head 54970cd9 via the v2 filled binding.
- Minimum closure (one path, one line): `test/rls-g2-s7l.spec.ts` L269 → `refusedFile(upFile, 'canceling statement due to lock timeout');` (title text "(55P03)" may stay; it is descriptive). No product, migration, harness or binding-driver change is required for this closure.
- Execution unlocked: a fresh single PG run of the v2 driver against a new head whose delta vs 54970cd9 is exactly this spec change (plus whatever the parent grants for §3 below), with a re-pinned `SPEC_BLOB`/HEAD/TREE in a v3 binding (the v2 driver pins the spec blob and head and will correctly refuse the new head).

## 2. Cascades (20 failures + "Test suite failed to run") — all downstream of §1

Because the assertion at spec L269 threw **before** `holder.release()` at L273, the `service_role` psql holder (open transaction, `FOR UPDATE` row locks on `ScoutImport`) stayed alive for the rest of the suite. That single leaked session explains every remaining failure; none is an independent product or proof finding:

| # | Stanza (spec) | Observed first error | Mechanism |
|---|---|---|---|
| 2 | stage 1 `down on the OLD shape refuses…` (L280) | `down.sql:17 ERROR: canceling statement due to lock timeout` | down.sql's `LOCK TABLE` waits on the leaked holder → its own 5 s `lock_timeout` fires before the fixed ABSENT text could be raised. Product behaviour again correct; expectation unreachable while the holder lives. |
| 3 | stage 2 `L01: prisma migrate deploy…` (L288) | `ERROR: current transaction is aborted…` inside `Applying migration 20270123000000_scout_run_lifecycle_expand` | Same lock timeout on `LOCK TABLE`; Prisma surfaces the following statement's "aborted transaction" error. S7-L never applied (`POST_JEST applied_migrations=171`). |
| 4 | stage 2 `L02: raw rerun…` (L347) | `migration.sql:28 … lock timeout` (expected ALREADY text) | Shape still OLD + holder alive. |
| 5-6 | stage 2 `§3.1 gate SQL…` (L358), `FOR NO KEY UPDATE fence…` | `column "mode" of relation "ScoutImport" does not exist` | S7-L columns absent (from #3). These stanzas also spawn `holdTransaction` sessions and threw before their `release()` (L375/L380, L403/L406) — additional leaked holders/open handles. |
| 7-19 | stage 3 (2), stage 4 (11) | `spawnSync /usr/bin/psql ETIMEDOUT` | `sql()`'s 60 s `execFileSync` timeout (harness L61) expires while `resetData()` (`test/utils/g2-s7l-harness.ts` L246-252: `DELETE FROM "ScoutImport" …`) waits on the leaked `FOR UPDATE` locks; the harness `sql()` session sets no `lock_timeout`, so it blocks until the JS-side timeout. F1 (L10 lazy deadline / fresh-run classification) and F2 (L06 owner-session SET ROLE) were **never exercised**. |
| 20-21 | stage 5 `L04 down…`, `re-applying the file…` | `down.sql:17` / `migration.sql:28` lock timeout | Holder alive. (Stage-5 `L03` was ETIMEDOUT in `resetData`.) |
| — | `Test suite failed to run` | `spawnSync psql ETIMEDOUT` at `resetData` (spec L218, afterAll) | Same blocked DELETE. |
| — | "Jest did not exit one second after…" | open handles | The leaked psql child processes (stdin pipes never ended; `holdTransaction` has no finally/kill on failure). This is why the invocation needed the parent's verified TERM (rc 124 is the TERM path, not a natural test exit). |

Error-class census over the whole log: 5 × `canceling statement due to lock timeout`, 2 × `column "mode" … does not exist`, 1 × `current transaction is aborted`, 13 × `spawnSync psql ETIMEDOUT`, 0 × any other SQL error, 0 × 40P01, 0 × FATAL/role errors, 0 × constraint or RLS surprises. No failure text points at `lifecycle.service.ts`, the arbiter, the migration/down bodies, RLS policies, the fixture, or the driver.

## 3. Product-vs-proof disposition summary

| Class | Item | Paths |
|---|---|---|
| **B (proof)** | Unreachable literal `'55P03'` expectation (§1) | `test/rls-g2-s7l.spec.ts` L269 |
| **C (record; no fix authorized by me)** | C-R1 — the failing stanza and the §3.1/fence stanzas release/kill their holders only on the success path (spec L273, L375/L380, L403/L406); the accepted S8-B stanza wrapped the same logic in `try { … } finally { holder.release() }` (`test/rls-g2-s8b.spec.ts` L245-…). Without it, any single assertion failure in those stanzas turns into the full cascade seen here plus a non-exiting Jest. Recommended minimal hardening if the parent chooses to authorize it alongside the B closure: move each `release()` into a `finally`. Not required for the B closure to make the proof pass. | `test/rls-g2-s7l.spec.ts` |
| C | C-R2 — harness `sql()`/`sqlAdmin()`/`sqlAs()` sessions carry no `SET lock_timeout`, so a blocked DELETE surfaces only as a 60 s `ETIMEDOUT` (harness L58-64). Slows cascades; not a correctness issue. | `test/utils/g2-s7l-pg-harness.ts` |
| C | C-R3 — after the failed L01 the `_prisma_migrations` table of the disposable cluster holds a failed row for S7-L; irrelevant to a fresh fixture (`s7l-fixture.sh` initdb's a new cluster) and the data dir is disposable by design. | — |
| C | C-R4 — `RECEIPTS.sha256` covers `s7l-pg-proof.log` as it stood before the driver's final `END` line (driver L80 vs L82); verified by recomputing `head -n -1` = `63d58094…`. Deterministic and reproducible, but a reader hashing the final file gets `2eae19cd…`. | `s7l/binding/v2/s7l-pg-proof.sh` L80-82 |
| C | C-R5 — `WARNING: there is already a transaction in progress` at `migration.sql:25` / `down.sql:11` is the documented redundancy of `--single-transaction` over the files' own `BEGIN` (harness comment L70-72). Not an error. | — |
| **Product defects found: none.** | The three passes (OLD legacy `/complete` baseline g2l_1 acknowledged with 4 queries; the two decoy refusals with the ALREADY text at spec L244-262) and the lock-timeout cancellations at `migration.sql:28` / `down.sql:17` are all correct product behaviour. Nothing in this run falsifies any S7-L claim; it verifies only: OLD bootstrap 171 applied, decoy-name refusal (×2), `lock_timeout` refusal on up and down with nothing applied. | |

## 4. Driver / fixture / cleanup behaviour (proof infrastructure)

Worked as bound: OLD_ROOT, FIXTURE_INIT/START, BOOTSTRAP, IDENTITY_OK, JEST_START all rc 0 with the pinned head; on rc 124 the driver took `STOP_FIRST_FAILURE`, stopped the fixture (`S7L_FIXTURE_STOP_OK`), reported `CLEANUP_STOP rc=0 postgres_procs=0 port55641_listeners=0 survivor_pid=none`, wrote receipts and sentinel, held the lock fd until exit. The only thing the driver could not do on its own was exit Jest, which the leaked child processes kept alive; the parent's verified group-TERM (`PARENT_TERM.txt`) was the bounded remedy. No worktree drift alarm (`POST_FAIL worktree changed`) fired.

## 5. What this run does and does not tell the parent

- Does: the fixture, bootstrap, identity gate and OLD legacy writer work on head 54970cd9; the migration's entry gates refuse correctly under decoys and under a lock hold; the driver's failure path and cleanup are bounded and honest.
- Does not: verify F1, F2, L01-L12, catalog exactness, RLS byte-equality, barriers, or the constraint matrix. All of REVIEW_B_V2.md §"unverified runtime limitations" remain open.
- Minimum path to a meaningful second run: the one-line B closure in §1 on a new head (ordinary commit, delta exactly `test/rls-g2-s7l.spec.ts`), scoped gates, a v3 binding re-pinning HEAD/TREE/SPEC_BLOB/EXPECT_PARENT (=54970cd9), and one PG grant. If the parent also authorizes C-R1, it is the same single spec path. I will re-attest only the changed question when asked, in a separately assigned file.

Verdict on this run: **FAILED — not accepted; cause is one proof-side literal (B), no product defect identified, all other failures are cascades of the leaked lock holder.**
