# B/drain — Reviewer B (successor) same-review diagnosis of the single real-PG proof failure

Reviewer: independent non-builder reviewer B **successor** (session cf8ff737 B/drain continuation). Model/effort: requested T4 Fable/High; no runtime telemetry observable to me, none claimed.
Scope: bounded triage of the actual failing run only. No broad source re-audit, no reruns, no controls invented, no peer-A material read. Fixture was already stopped (cleanup rc0) when I began, so no live catalog query was possible; the root cause below is established from the committed candidate source plus upstream PostgreSQL 17 source, and is fully consistent with every passed and failed assertion.

## 1. Run identity (from real artifacts)

- Runner `execution/95633079/s7-b-drain/runtime/binding/b-pg-proof.sh` sha `a64d24de…b6b9` (== my attestation), launched `timeout -k 30 3600` 15:12:20Z (`LAUNCH.txt`).
- `b-pg-proof.log`: PRECONDITIONS_OK (postgres 17.6 sha `23cd1748…873a`, psql 18.6 client, node v20.20.1), PREFLIGHT_OK (porcelain empty), FIXTURE_INIT/START rc0, OLD_ROOT rc0 (head 925780e0, 164 migrations), BOOTSTRAP rc0 (`applied:164`, candidate client engine `a2924eab…` == O-client engine), IDENTITY_OK (cluster_name b-disposable-pg17, 170006, port 55461), JEST_START 15:12:33Z, `JEST_END rc=1` 15:14:49Z, STOP_FIRST_FAILURE stage=jest, `CLEANUP_STOP rc=0 postgres_procs=0 port55461_listeners=0`, `END rc=1 stage=jest` 15:14:50Z. HEAD `75a2863b` unchanged and clean. Runner behaved exactly as bound (fail-closed at the first nonzero stage, disposable cluster stopped).
- `jest.log`: `Tests: 8 failed, 11 passed, 19 total`, 52.144 s, then "Jest did not exit one second after the test run has completed".

## 2. 19 vs 26 — explained from the committed spec, criteria unchanged

`git show 75a2863b:test/rls-g2-b-drain.spec.ts` declares exactly **19 `it(`** in 7 `describe(` blocks (stages 1–7); zero `it.each/it.skip/it.only/test(`. Jest ran 19/19 — nothing was skipped or dropped at runtime. The "26" figure was a pre-commit planning estimate carried in the earlier binding discussion, not a property of the committed candidate. The committed spec blob `9b31fd18…` is the one pinned as `EXPECT_SPEC_BLOB` in the binding and accepted under the v4 SOURCE_GRANTABLE verdict, so 19 is the correct denominator. No criterion moved.

## 3. Root cause — one deterministic candidate defect, not environment

Failing predicate, present verbatim in exactly two committed places (`git grep tgattr`):

```
src/scout/scout-ledger-backfill.ts:257   AND t.tgattr::int2[] = '{}'::int2[] ...
prisma/migrations/20270119000000_scout_ledger_obsolete_writer_fence/down.sql:64
                                         AND t.tgattr::int2[] = '{}'::int2[]
```

This comparison is **always false on PostgreSQL** for a trigger created without a column list:

- `CREATE TRIGGER` stores `tgattr = buildint2vector(columns, ncolumns)` (upstream `src/backend/commands/trigger.c`, REL_17_STABLE, `tgattr = buildint2vector(columns, ncolumns);`), and `buildint2vector` sets `result->ndim = 1` unconditionally (`src/backend/utils/adt/int.c`), so an empty `int2vector` is a 1-dimensional zero-length array.
- The cast `int2vector → int2[]` is binary-coercible and preserves that header. The literal `'{}'::int2[]` is a 0-dimensional array.
- `array_eq` (`src/backend/utils/adt/arrayfuncs.c`) returns false whenever `ndims1 != ndims2` before comparing elements.

Hence 1-dim-empty ≠ 0-dim-empty → the detector counts `fences = 0` → library reports `fenced:false` and terminal outcome `complete_unfenced` instead of `drained`; `down.sql` raises `G2-B fence absent` and refuses to run.

Every other predicate of the detector is independently confirmed TRUE by the *passing* stage-3 test on the same database: trigger name, relation `public."ScoutReconstructionLedger"`, `tgenabled='O'`, `tgtype=7`, canonical `pg_get_triggerdef` text (no WHEN → `tgqual IS NULL`, no args → `tgnargs=0`, plain trigger → `tgconstraint=0`), function `public.scout_ledger_platform_fence()`, `prosecdef=false` (`PG17_FENCE` console line in jest.log). `migration.sql`'s own presence check (tgrelid+tgname OR `to_regprocedure`) does not use the `tgattr` predicate and correctly reports "already present" (stage 3 rerun refusal passed; stage 7.2 error message). The fence itself works: stage 4 (owner/runtime NULL INSERT refused, O binary fails closed 500, API roles denied, T claims through fence) passed 4/4.

Why earlier gates did not catch it: the v4 unit spec `src/scout/scout-ledger-backfill.spec.ts` runs against a fake Prisma that returns `fences: 1`; a fake cannot evaluate a catalog predicate. This live proof was the first execution of the detector against a real PostgreSQL — which is precisely what the proof exists for. Not environment: the psql 18.6 client / postgres 17.6 server split and the `jest` CLI print 30.4.1 (package `jest`/`jest-cli` 30.4.2 in tree; CLI banner differs) have no bearing on `array_eq` semantics.

## 4. Failure-by-failure mapping (all 8 explained; 0 unexplained)

| # | Test | Observed | Cause |
|---|---|---|---|
| 1 | 5.2 resolves exactly the 1230… | only `fenced:true→false` differs; batch/ledgerTotal 1250/nullBefore 1238/nullAfter 8/mismatch 2/outcome unresolved all matched | root |
| 2 | 5.4 forward provenance recovery… | `fenced false`, outcome `complete_unfenced`; nullBefore 8→nullAfter 0, mismatch 2 matched | root |
| 3 | 6.1 skips a locked row… | `passes[0] examined 1 updated 1` passed (l.508); outcome `complete_unfenced` (l.509) | root |
| 4 | 6.2 T paused after reading staging | `nullAfter 0` matched; outcome `complete_unfenced` (l.518) → test aborted **before** `paused.release()` (l.519) | root |
| 5 | 6.3 T paused inside its claim | `nullify(intent_id='i3')` 20 expected, 0 received (l.525) | **cascade of #4**: the paused T worker from 6.2 was never released, its 20 reconstructed rows never committed |
| 6 | 6.4 concurrent staging writer | `nullAfter 0` matched; outcome `complete_unfenced` (l.569) | root |
| 7 | 7.1 down keeps column… | `down.sql:70 ERROR: G2-B fence absent` | root (same predicate in down.sql) |
| 8 | 7.2 re-applying the file… | `migration.sql:68 ERROR: G2-B fence already present` | **cascade of #7**: down never ran, fence still installed, migration.sql correctly refuses |
| — | "Jest did not exit" / open handle | — | **cascade of #4**: 6.2's paused worker connection/transaction left open because `release()` follows the failing `expect` with no `finally`. Not a separate PG or runner defect. |

The drain arithmetic (1238 NULL → 1230 resolved in 3×500 chunks, 8 remaining by class, idempotent rerun, lock skip examined/updated counts, staging-writer lock_timeout path) is correct on real PG in every failure where it is visible.

## 5. Classification (owner Safety ROI)

**A — real product consequence (blocks only the B/drain product path: landing/deploying migration `20270119000000` and the backfill library/CLI).**
- Concrete harm: (a) the shipped rollback `down.sql` can never execute against any real PostgreSQL — migration B has no working down path; (b) `backfillLedgerPlatform` can never report `fenced:true`, so the terminal outcome `drained` is unreachable and the operator-facing verdict is permanently false (`complete_unfenced` while the fence is in fact installed). This is a truthfulness defect in the mission's own completion signal.
- Decision blocked: acceptance/landing of candidate `75a2863b` for B. Nothing else — C1 (a0ea1bea) accepted work, the fence trigger/function, RLS, and the resolve/chunk/lock logic are not implicated.
- Minimum closure (v5 candidate; ordinary path): replace the predicate in **both** places with a dimension-independent form, e.g. `cardinality(t.tgattr::int2[]) = 0` (or `t.tgattr = ''::int2vector`); no other detector change. Keep `FENCE_TRIGGER_DEFINITION`/`FENCE_TRIGGER_TYPE` unchanged.
- Execution unlocked: builder edit (2 lines in 2 files) → existing gates → genuine commit → refill the 5 binding placeholders for the new head/tree/spec blob (spec blob unchanged unless §B fix below is taken) → **one** new single-PG proof under the same sealed template. No harness redesign.

**B — proof-invalidating (blocks only this proof).**
- The sealed live spec does not pass on `75a2863b`; the single PG proof is NOT grantable as passed. Cleanly recorded as RC=1 stage=jest; no rewrite.
- Test hygiene in the same fix: 6.2/6.3 (and any other `worker({pause})` test) should release/await the paused worker in `finally` (or an `afterEach` guard) so an assertion failure cannot leave an open transaction and hang Jest. This is what produced the open handle; minimum is a `try/finally` around lines 517–521 and 528–540. Without it a future failing run again needs an external TERM. Small spec edit → new `EXPECT_SPEC_BLOB`.

**C — record/qualify/continue (no new work).**
- C-7: the fake-Prisma unit spec is not an oracle for catalog SQL; recorded as a known limit, not a new harness.
- C-8: `jest` CLI prints 30.4.1 while `jest`/`jest-cli` packages are 30.4.2 — banner/package mismatch only; the pinned package check passed; no action.
- C-9: psql client 18.6 against server 17.6 — permitted by the binding (pins are on postgres/initdb binaries); irrelevant to the failure.
- C-10: `WARNING: there is already a transaction in progress` — `down.sql`/`migration.sql` contain their own `BEGIN` while the harness adds `--single-transaction`; harmless duplicate, pre-existing shape.
- C-6 (carried): head detached; builder should name a ref when next writing.

## 6. Disposition

- Single real-PG proof for `75a2863b`: **FAILED, recorded as failure** (RC=1 stage=jest, 11/19). Not grantable; no rerun of the same candidate has value — the predicate is deterministically false on PostgreSQL.
- My actual-head/identity/gates/binding attestation for `75a2863b` stands as written (it attested identity and gate receipts, not live-PG success).
- Next candidate: A-closure (2-line predicate fix) + B-closure (finally-release) as one v5 delta; reviewer B re-verifies **only the delta** against v4 (no full re-audit) and binds one new proof. Expected on v5, if the fix is correct: 19/19 and clean Jest exit.

Not a final pass. Nothing landed, deployed or product-accepted.

## 7. Addendum 2026-09-24 15:2xZ — parent disposition recorded (same review)

- Root cause and A classification (B/drain product path only) accepted by parent; v5 grant `execution/cf8ff737/B_V5_MINIMUM_CORRECTION_AND_PHASE_A_GRANT.md` authorizes exactly the two predicate replacements with `cardinality(t.tgattr::int2[]) = 0`, message `fix(importer): recognize empty trigger column vectors`, parent `75a2863b`, no spec/harness/fixture change.
- **§5 B-item "finally-release" re-qualified to C (cascade hygiene), accepted.** Actual evidence: the test run finished at ~52 s after JEST_START 15:12:33Z, and `JEST_END rc=1` was written 15:14:49Z — Jest exited on its own within the existing bounds (paused-worker `txTimeout 60000` / harness 60 s psql timeout), the runner then completed `B_FIXTURE_STOP_OK` and `CLEANUP_STOP rc=0` with no external TERM. The open handle therefore cost ~80 s of wall time and no proof integrity, and it is caused solely by the assertion the two-line correction removes. No remaining proof-invalidating need → no spec edit, no new control, no extra cycle. Recorded as C-11; continue.
- Consequence for the v5 review: `EXPECT_SPEC_BLOB` `9b31fd18…`, `EXPECT_BOOTSTRAP_BLOB` `b4503eef…` and `EXPECT_FIXTURE_SHA` `4525f01d…` must be byte-identical to the v4 binding; only `EXPECT_HEAD`/`EXPECT_TREE` change. Delta review scope = 2 blobs (`src/scout/scout-ledger-backfill.ts`, `.../20270119000000_scout_ledger_obsolete_writer_fence/down.sql`), each differing from the `75a2863b` blob in exactly one predicate; all other 9 blobs must equal frozen-v4. No full audit, no runtime.
