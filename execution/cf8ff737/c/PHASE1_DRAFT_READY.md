# C contract build — PHASE 1 DRAFT READY

**Builder:** sole T4 builder, C slice (narrow-key contraction + C.down refusal). **Time:** 2026-09-24 ~19:05Z.
**Requested route:** Claude Fable 5.1 / High — no telemetry is available to me; I claim nothing about the model or effort actually used.

## State

- Worktree `/home/user/workspace/worktrees/s7-c`, branch `s7-c`, HEAD `7d2895e1fe03ea82353e8ce0b07aacaf66af74c8` (R head), as the grant states.
- All phase-1 files are **untracked and uncommitted** (`git status --short` lists 8 entries). No commit, no `node_modules`, no tests, no PostgreSQL, no lock. `s7-nq1`, other worktrees and `/home/user/pg17/clusters` were not touched (read-only `GIT_OPTIONAL_LOCKS=0 git -C … show/rev-parse` of `s7-nq1` only).
- Only executions: `python3 derive-c-pg-proof.py` (text substitution into `execution/cf8ff737/c/binding/`), `bash -n` on the three shell files, `diff`, `sha256sum`.

## Files drafted (worktree, phase-1 owned paths)

| path | lines | derived from | notes |
|---|---|---|---|
| `prisma/migrations/20270121000000_scout_identity_contract/migration.sql` | 102 | R.down entry gate + original narrow DDL | envelope BEGIN / `SET LOCAL lock_timeout '5s'` / `statement_timeout '30s'` / LOCK both tables ACCESS EXCLUSIVE; asserts both narrow indexes exact (`G2-C unexpected identity prerequisite`), R wide indexes + CHECKs + both `source_platform` NOT NULL / no default / no NULL rows (`G2-C wide identity absent`); `DROP INDEX public."…"` ×2; COMMIT. No verify.sql. |
| `…/down.sql` | 122 | same envelope | decoy check `to_regclass` on both narrow names → `G2-C contract absent`; R wide + NOT NULL required; collision pre-check (GROUP BY HAVING count>1 on staging (c,i,s) and ledger (c,i,e,s)) → `RAISE EXCEPTION '<fixed text>' USING ERRCODE='unique_violation'` (23505, no identifiers); `CREATE UNIQUE INDEX` ×2 schema-qualified; postcondition loop; COMMIT. |
| `test/utils/g2-c-db.ts` | 109 | `g2-r-ready-db.ts` | seventh identity: `G2_C_*`, DB `g2_c_disposable`, role `c_super`, markers `c-disposable-pg17` / `c-g2-contract-synthetic-disposable-fixture-safe-to-drop`; REFUSED_PORTS adds 55471, 55481. |
| `test/scout/g2-c-db-guard.spec.ts` | 112 | `g2-r-ready-db-guard.spec.ts` | DB-free guard: port 55491, ack `g2_c_disposable:55491`, refuses R/N/Q1 identities, marker `^c-`. |
| `test/utils/g2-c-pg-harness.ts` | 371 | `g2-r-ready-pg-harness.ts` + N/Q1 additions | `OLD_HEAD='__NQ1_ACCEPTED_HEAD__'` placeholder; worker prefix `g2c_`; `legacyRosterCursor`; env `G2_C_*`; old side = N/Q1 root + client. |
| `test/utils/g2-c-harness.ts` | 224 | `g2-r-ready-harness.ts` | adds `C_MIGRATION`, `cUpFile/cDownFile/cUp/cDown`, `NARROW_*_DEF/NAME` (63-char ledger name), `C_DOWN_REFUSAL`, `identityRows`, `stagedRows` (no status column on staging), `narrowDuplicates`, `ledgerRow` (id carries family+platform), `runtimeClient`, `ingestClient(name)` → real `ScoutIngestService(prisma, analyticsStub)` with `{received, deduped}` + captured events. |
| `test/utils/g2-c-bootstrap.sh` | 278 | `g2-nq1-bootstrap.sh` (committed 96b7668d) | `OLD_HEAD=__NQ1_ACCEPTED_HEAD__`; old root must carry E+R and lack C; candidate diff vs OLD_HEAD in `prisma/migrations` == exactly C's two files; old-root deploy 169, wide 2 / narrow 2 / C not recorded; old client = N's (narrow `@@unique` present, ledger provenance required); candidate client = C's (no narrow `@@unique`); markers `G2_C_BOOTSTRAP_OK` / `G2_C_GENERATE_OK`. `bash -n` OK. |
| `test/rls-g2-c-contract.spec.ts` | 907 | `rls-g2-r-ready.spec.ts` + N/Q1 spec patterns | 21 `it` blocks in 6 ordered stages (mapping below). `jest.setTimeout(240000)`. |
| `docs/decisions/2026-09-24-g2-identity-contract.md` | 116 | E decision record format | scope; D-C1 no-seal + S9 carry-forward; runbook: down order C→R→B→E with each refusal message, forward-repair-only on 23505, lock-timeout = retry-later, `prisma migrate resolve --rolled-back 20270121000000_scout_identity_contract` after a production C.down (S1-owned recovery semantics); D-C2 stepwise promotion + production preconditions; `readDrainState` over-count + backfill CLI retirement note; CI PG15 dry-run parity note. |

## Files drafted (`execution/cf8ff737/c/binding/`)

| file | lines | sha256 |
|---|---|---|
| `c-pg-proof.sh` | 214 | `c84ffb12…b04d4` (substitution-only, pins unfilled) |
| `c-fixture.sh` | 95 | `cf342f4b…f259b3` |
| `derive-c-pg-proof.py` | 215 | `4476ec0e…500a` — reproduces both files from the N/Q1 binding, asserted match counts |
| `c-pg-proof.sh.diff-vs-nq1` | 219 | whole-line diff N/Q1 → C |
| `README.md`, `PINS.txt` (status=UNFILLED), `BINDING.sha256` | — | placeholders `__FILL_AFTER_COMMIT__` ×5, `__NQ1_ACCEPTED_HEAD__`, `__FILL_AFTER_GENERATE__` (C client) |

Binding identity: lane `clusters/c-contract`, socket `run/c-contract`, port 55491, `c_super`/`c_local_synthetic`, DB `g2_c_disposable`, env `G2_C_*`, `C_RUNNER_PID`. Added read-only checks: seven accepted N/Q1 blobs (from 61b93cff) byte-identical at the C head, `$NQ1_HEAD` ancestor, `git diff --name-only $NQ1_HEAD HEAD -- prisma/migrations` == exactly C's `down.sql` + `migration.sql`, retained N/Q1 cluster hashed and never started; bootstrap does NOT apply C (the spec applies it through the candidate's `prisma migrate deploy`).

## Case → test mapping (C01–C18)

| case | stage / `it` | proof |
|---|---|---|
| C01 C via release mechanism | 3 "C01" | `prismaMigrateDeploy(root)` output names C only; `appliedSince(start)==[C]`; applied 170; `narrow()==[]`; tables/policies/wide/fence byte-equal; index set −2 == exactly both narrow defs; rows byte-identical; second deploy "No pending migrations". |
| C02 negative control on R | 1 "C02" | real ingest service: 3 families of `s` → deduped 0,1,1; other platform deduped 1; raw insert 23505 naming the narrow index; ledger narrow key refuses a second platform and a second family of the same `(source)`. |
| C03 cross-family activation | 4 "C03/C04" | after C, clients+workouts of `s` → 2 staged rows, deduped 0. |
| C04 three types share id | 4 "C03/C04" | fresh intent, clients/workouts/client_history of `t` → deduped 0 ×3; `narrowDuplicates().staging==2`. |
| C05 retained idempotency | 4 "C05" | replay deduped 3; captured_at change deduped 3 (rows unchanged); in-batch dup deduped 2 of 3; other intent / other coach → new rows; total 10. |
| C06 two platforms, one id | 4 "C06" | real ingest: received 2 deduped 0; replay deduped 2; analytics events `[2,0],[2,2]`. |
| C07 three platforms through the writer | 4 "C07" | workouts `w` on truecoach / conformance_alpha / unknown_platform → reconstructed 2, skipped 1 (`unsupported_platform:unknown_platform`), failed 0; 2 targets; replay identical; old N/Q1 writer identical; `narrowDuplicates == {1,1}`. |
| C08 races | 4 "C08" | (a) candidate paused `before-ledger` + blocked second candidate → 1 row, 1 Person; (b) old paused `staged`, candidate completes, old converges; (c) reverse; (d) success dominates later `mapper:'skip'` from both writers. |
| C09 lock timeout | 2 "C09a" (C.up vs held ledger read) + 4 "C09b" (C.down vs held ingest insert) | `canceling statement due to lock timeout`, 4500 ≤ elapsed < 30000 ms, snapshot unchanged, held insert rolled back, lock released. |
| C10 collision-free reverse/forward | 6 "C10" | C.down (under shadow search_path) restores R shape (OIDs aside) with rows/targets intact; history not rewritten, deploy "No pending"; narrow arbitrates again (23505); both writers idle; then R.down → B.down → E.down (refuses assigned provenance first; ledger emptied for the E step only) → E.up → B.up → R.up → C.up; staging byte-equivalent throughout; catalog shape == C shape; ledger re-derived with identical identities. |
| C11 cross-family collision refusal | 5 "C11" | `expectDownRefusedCollision`: fixed text, `ERROR:  23505:`, no `DETAIL: Key`, no source/coach id in output, snapshot unchanged, `narrow()==[]`. |
| C12 platform collision (staging) | 5 "C12" | same helper. |
| C13 ledger-only collision | 5 "C13" | same helper + staging narrow relation absent (atomic). |
| C14 entry guards / decoys / shadow | 2 "C14a" (C.down before C), 3 "C14b" (C.up rerun + shadow), 5 "C14c" (decoy table named as the narrow key: C.down `contract absent`, C.up `unexpected identity prerequisite`, decoy oid/relkind unchanged, shadow both directions), 6 inside C10 "C14d" (C.down rerun after C.down) | all atomic via `expectUnchanged`. |
| C15 older downs refuse with C applied | 5 "C15" | R.down `G2-R unexpected identity prerequisite`, B.down `G2-B unexpected identity prerequisite`, E.down `G2-E unexpected identity prerequisite`; snapshot unchanged; fence intact. |
| C16 ties through Q1 readers | 4 `it.each(['clients','workouts'])` "C16" | `a` on truecoach/conformance_alpha/p3 + `d`; limit-1 enumeration on both heads: union == reconstructed targets exactly once; tokens `v2(a,conformance_alpha), v2(a,p3), v2(a,truecoach), v2(d,truecoach), null`; tied legacy token → `{400,'malformed cursor'}`; untied legacy resolves. |
| C17 security | 4 "C17a" + 6 inside C10 "C17b" | anon/authenticated 42501 on INSERT, 0 rows SELECT/UPDATE/DELETE, both tables; service_role tx ROLLBACK leaves nothing; 23514 CHECK refusals unchanged; repeated after C.down. |
| C18 late ingest (D-C1) | 4 "C18" | worker paused `staged` (after count+page read), real ingest adds `e2`; release → tally staged 1 / reconstructed 1; `e2` present in staging, absent from ledger; replay → staged 2 / reconstructed 2, `ledgerCount()==stagedRows().length`; third replay identical. |
| N/Q1 continuity (grant "old process continues") | 6 "N/Q1 continues on C" | old writer admits cross-family tuple after re-C; both readers page it. |

## Facts verified while drafting (read-only)

- `ScoutIngestEntity` has **no status column**; "still staged" = present in staging, absent from the ledger (harness `stagedRows` and C18 written accordingly).
- Reconstruct pass reads **all** staged rows of the scope each replay (precedence-guarded upserts); the returned tally is **cumulative over the ledger** (`{intent_id, staged, reconstructed, skipped, failed}`), so replays report the same non-zero tally, not 0 — C07/C10/C18 assert that.
- Shared worker `staged` barrier fires **after** `scoutIngestEntity.findMany` (count already taken); `before-ledger` before the ledger upsert.
- Unregistered platform → family `map` returns `{ok:false, reason:'unsupported_platform:<token>'}` → ledger `skipped`. Both `truecoach` and `conformance_alpha` mappers are total for clients and non-person families (payload content optional).
- B.down / E.down narrow-key gates: `G2-B unexpected identity prerequisite` (L36), `G2-E unexpected identity prerequisite` (L35); E.down also `G2-E refuses removal of assigned provenance` (L52).
- N/Q1 is **committed** in `s7-nq1` at `61b93cff7900b24c17011d481fd6c31f5abb59e4` (tree `7adad696…`, author Bradley Gleave, 25 files); acceptance not yet recorded by the parent. Blob ids of its seven test files recorded in the binding preconditions.

## Open questions for phase 2 (parent decision or verification)

1. **Base of the C head (blocking for phase 2, not phase 1).** The grant creates `s7-c` at `7d2895e1` (R head). C needs N's writer (required ledger provenance, five-field upsert) and Q1's readers; the harness/bootstrap/binding all treat the accepted N/Q1 head as the OLD side and require it to be an **ancestor** of the C head with `prisma/migrations` differing by exactly C. Phase 2 must therefore rebase/reset `s7-c` onto the accepted N/Q1 head (expected `61b93cff` if accepted unchanged) before the schema edit and commit. Placeholders `__NQ1_ACCEPTED_HEAD__` (pg-harness, bootstrap, runner `NQ1_HEAD`, PINS) are filled then.
2. Brief §4 said "history applied by file"; the draft adopts the N/Q1 old-root `prisma migrate deploy` for S1..R (169) and the candidate's deploy for C (release mechanism, stronger). Recorded deviation; confirm.
3. Shared worker has no ingest action; C06/C09b/C11/C18 use an in-process real `ScoutIngestService` via `ingestClient` (analytics captured, nothing forwarded). Confirm acceptable versus adding an `ingest` action to `g2-tq0-worker.cjs` (accepted R/N/Q1 file — would break their blob pins; not recommended).
4. C16 token order/semantics (legacy tied cursor → 400 `malformed cursor`; v2 token per ledger row including skipped rows; alphabetical platform order) taken from the Q1 spec pattern — verify against the committed Q1 readers at phase 2.
5. Candidate-client assertions (no narrow `@@unique`) require the phase-2 `prisma/schema.prisma` edit and a C-only `prisma generate` (receipt 03) before the bootstrap step 7 / spec beforeAll can pass.
6. `wide()` after R.down assumed `{indexes:[], checks:[], ledgerNotNull:false}` (R.down reverts NOT NULL) — verify from R.down at phase 2.
7. `test/utils/g2-c-old-root.sh` is invoked by the runner and bootstrap but is **not** in the phase-1 owned list — decide: derive from committed `g2-nq1-old-root.sh` (4569f5fe…) with OLD_HEAD/markers substituted (recommended, one more owned file) or generalise the N/Q1 helper (breaks its blob pin; not recommended).
8. REFUSED_PORTS assumes N/Q1 port 55481 (confirmed from the committed binding) — no action.
9. Phase-2 doc/text fixes outside phase-1 paths (brief): ingest/reconstruct controller idempotency wording, OpenAPI regeneration, reconstruct `retryContention` "narrow key" comment, ingest service spec comment, two `@@unique` lines + three comments in `schema.prisma`.
10. `prisma migrate resolve --rolled-back` after a production C.down is recorded in the runbook as S1-owned recovery semantics, not proven locally (C10 asserts the un-rewritten history as-is).
11. E.down inside C10 requires an empty ledger (it refuses assigned provenance); the draft deletes ledger rows for that step only and re-derives them after the forward chain. If the parent prefers a pure "rows byte-equivalent" reverse including the ledger, stop the reverse at B.down instead.

## Phase-2 fills (in order)

rebase onto accepted N/Q1 head → replace `__NQ1_ACCEPTED_HEAD__` (3 files + PINS) → `schema.prisma` two `@@unique` lines → `g2-c-old-root.sh` → src/doc text edits + OpenAPI → node_modules isolated copy + C-only generate (receipts 02/03) → light + heavy gates → chain-harness PG15 dry-run → hooked Bradley commit (no AI trailers) → fill `EXPECT_*`/`NM_CLIENT` pins, refresh `BINDING.sha256` → separate single-run PG grant.

Stopping here as instructed; awaiting the parent's phase-2 message.
