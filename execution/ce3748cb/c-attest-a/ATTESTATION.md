# C attestation A (T4, independent; not the builder) — GO for one PG run

Candidate: `worktrees/s7-c` HEAD `16cd67f490ea363ad7ff3dc8e98246a1ad3f6d76` (tree `9301e7bc`), parent = accepted N/Q1 `29e60705`. Reviewed read-only, 2026-09-24 ~21:40–22:05Z. No PG started, nothing written outside this file, `c-attest-b` not read. Model/effort not claimed.

Authority read: `C_BUILD_GRANT.md` (+18:50Z addendum), `c-prep/C_SLICE_BRIEF.md`, `C_PHASE1_REDRAFT_GRANT.md`, `C_PHASE2_GRANT.md`, `c/PHASE1_DRAFT_READY.md`, `c/PHASE1_REDRAFT_READY.md`, `c/SOURCE_READY.md`, receipts 02–14, binding (`c-pg-proof.sh` `ad6c8c53…`, `BINDING.sha256`).

## Verdict

**GO** — grant a single run of `execution/cf8ff737/c/binding/c-pg-proof.sh` (sentinel rc 76 semantics unchanged). No A or B finding. Six C findings recorded below; none creates a fixer, rerun or delay.

## 1. SQL correctness and atomicity (migration.sql / down.sql)

- **Envelope**: both files `BEGIN; SET LOCAL lock_timeout='5s'; SET LOCAL statement_timeout='30s'; LOCK TABLE public."ScoutIngestEntity", public."ScoutReconstructionLedger" IN ACCESS EXCLUSIVE MODE` — byte-pattern of R.down L9-12. Guards run inside the DO block after the lock; every DDL/DML is schema-qualified (`public.`); no `CONCURRENTLY`, no `CASCADE`; one transaction, so any refusal or late failure is atomic.
- **C.up gate 1** (both narrow keys exact, relkind `r`, RLS enabled+forced, unique/valid/ready/immediate, no predicate/expression, `pg_get_indexdef` byte-equal with `::name` truncation) is R.down L19-40 verbatim with the message changed. The 70-char ledger name resolves through `to_regclass(format('public.%I',…))` and `::name`; this exact predicate executed successfully in the accepted R and N/Q1 PG proofs (`rls-g2-r-ready.spec.ts:627`, `rls-g2-nq1.spec.ts:469` run `rDownFile`), so the truncation handling is empirically proven, not assumed.
- **C.up gate 2** (wide keys exact on their own tables, both CHECKs `contype='c'`, validated, keyed on `source_platform` alone; message `G2-C wide identity absent`) is R.down L44-67 verbatim. **Gate 3** adds both `source_platform` columns `text`, typmod −1, `attnotnull`, no default, not generated/identity, plus `NOT EXISTS … IS NULL` on both tables. Brief §1 items 1–4 satisfied; B's fence neither asserted nor touched.
- **Drops**: `DROP INDEX public."…"` ×2, literal accepted names (lexer truncates the ledger name identically to the stored 63-char name). Catalog-only; zero rows touched.
- **C.down gate 1**: `to_regclass('public."<narrow>"') IS NOT NULL` for both names → `G2-C contract absent`. Catches a rerun, a pre-C DB and any decoy relation kind under either name (index or table), before any CREATE. **Gate 2** = R.down wide/CHECK predicate + NOT NULL on both tables, same message.
- **Collision pre-check**: `EXISTS (… GROUP BY coach_id,intent_id,source_id HAVING count(*)>1)` on staging OR `GROUP BY coach_id,intent_id,entity_type,source_id` on the ledger. All four/five key columns are `NOT NULL` (20261222000000 L34-37, 20261223000200 L54-57), so GROUP BY duplicate detection is exactly the set a `CREATE UNIQUE INDEX` would reject — no false-negative path to a bare 23505 with `DETAIL: Key (…)`. Runs under ACCESS EXCLUSIVE (race-free), both tables before either CREATE (no half-narrow state). `RAISE EXCEPTION '<fixed text>' USING ERRCODE='unique_violation'`; no DETAIL/HINT, no identifiers, no counts. Text equals `C_DOWN_REFUSAL` in the harness.
- **Recreate + postcondition**: `CREATE UNIQUE INDEX "<accepted name>" ON public."<table>" (cols)` ×2 with the accepted names/columns (20261222000000 L46-47, 20261223000200 L66-67), then the R.down L19-40 loop as an in-transaction postcondition (`G2-C narrow key not restored exactly`). Result = R shape: wide keys, CHECKs, NOT NULL, fence, RLS untouched.
- **Older downs with C applied**: R.down L19-40, B.down L13-36, E.down L12-35 each begin with the narrow-key loop → `G2-{R,B,E} unexpected identity prerequisite` before any other check; C15 asserts exactly those texts and full atomicity. Runbook order C → R → B → E recorded in the decision doc.
- **Chain harness (CI PG15)**: `down.sql` present (no `verify.sql`); empty-DB deploy → C.down → C.up → `pg_dump -s` byte diff holds because names/definitions are exact and OIDs are not dumped. PG15 has `attgenerated`/`attidentity`/`to_regclass`. Not run locally (no server; recorded by the builder as C).

## 2. schema.prisma / client / src consistency

- `schema.prisma` diff = exactly the two narrow `@@unique` removals and three comment blocks (24 lines); wide `@@unique(…, map: …)` unchanged. `prisma/schema.prisma` sha `8ff0082d…` = the generate-time sha (receipt 03); `node_modules/.prisma/client/index.d.ts` sha `2141225d…` = pin; generated client schema contains 0 narrow `@@unique`.
- `rg` over `src/`, `scripts/`, `test/` for `coach_id_intent_id_source_id` / `coach_id_intent_id_entity_type_source_id` selectors (non-`_key`): none. The only compound selector in `src` is the five-field `coach_id_intent_id_entity_type_source_platform_source_id` (`scout-reconstruct.service.ts:287`). `tsc` rc=0 (receipt 10, hook ✓).
- `src` hunks (4 files): controller `description` strings, service doc comments, one inline comment. No executable change. OpenAPI regen = the two description strings; drift spec passed in the affected Jest run (receipt 12: 41 suites / 765 passed / 0 failed).
- The 409 fail-closed fallback (`retryContention` → `ProvenanceConflict`) is kept in code and still unit-covered (`scout-reconstruct.service.spec.ts:446` "maps a P2002 that survives the single retry to the 409"); the removed narrow-collision `it.each` is replaced by a real distinct-identity case with cumulative tally asserted per the addendum's staging-semantics rule.

## 3. Spec C01–C18 + N/Q1 continuity — do they prove what they claim?

Read all 1199 lines plus `g2-c-harness.ts`, `g2-c-pg-harness.ts` (pure `nq1→c` substitution + `rollback()`; diffed), `g2-c-db.ts` (substitution + port 55481 refused; diffed), `g2-c-bootstrap.sh`, `g2-c-old-root.sh`, `g2-c-db-guard.spec.ts`, and the pinned worker `g2-tq0-worker.cjs`.

| Case | Verdict | Notes |
|---|---|---|
| beforeAll | real | identity/marker/version gates; 169 applied, C unrecorded; both narrow present; `git diff --name-only OLD_HEAD HEAD -- prisma/migrations` == C's two files; candidate client has neither narrow `@@unique`, old client has both; teardown authority gate. |
| C02 | real negative control | real `ScoutIngestService` on R: second family/platform deduped by narrow key; raw 23505 names the narrow indexes (63-char ledger name asserted with closing quote). |
| C14a / C09a | real | C.down pre-C → `contract absent`, snapshot equal (OIDs included); C.up vs held ACCESS SHARE → 55P03 in [4.5 s, 30 s), nothing applied, table freed. |
| C01 | real, strong | candidate `prisma migrate deploy` applies exactly C (`appliedSince` = [C], 170); removed index set == the two narrow defs AND their pre-drop OIDs; tables/policies/wide/fence byte-equal with OIDs; rows byte-equal; second deploy "No pending". |
| C14b | real | raw C.up rerun refused; shadow schema first on `search_path` cannot redirect (shadow tables acquire nothing). |
| C03/C04 | real | 2 then 3 families of one source insert (deduped 0); `ON CONFLICT DO NOTHING` without a target asserted from the real query log; per-intent and global `narrowDuplicates`. |
| C05 | real | replay 0, changed `captured_at` 0, in-batch 3→1 row, other intent/coach insert; rows (incl. `captured_at`, payload) byte-equal. |
| C06 | real | two platforms through the real service, replay deduped 2, N writer → 2 ledger rows, 2 Persons (distinct platforms), replay identical, NULL count 0. |
| C07 | real | three platforms of one workout: 2 reconstructed / 1 skipped (`unsupported_platform:unknown_platform`) / 0 failed; 2 entities; replay and old N writer identical (ledger has no `updated_at`, so strict `records()` equality is valid). |
| C08 | real | (a) candidate/candidate with observed `pg_stat_activity` Lock wait; (b)/(c) old↔candidate orderings; (d) success dominates a later `mapper: 'skip'` from both writers with target preserved; (e) concurrent cross-family/platform → 3 rows, 2 Persons, 1 entity. Mirrors accepted N/Q1 M07 pattern. |
| C09b | real | uncommitted service_role INSERT → C.down 55P03 atomic; ROLLBACK → row never lands; subsequent real-service replay/new-identity counts exact. |
| C16 ×2 | real | real ties on the real schema; `take: limit+1` lookahead in both readers makes `[v2(a,ca), v2(a,tc), null]` the correct token sequence at limit 1; tied legacy → 400 with no page/count read (`resolveScoutCursor` `take: 2` path, verified in `scout-cursor.ts:110-124`); untied resolves; cross-head token continuity. |
| C17a / C17b | real | anon/authenticated INSERT 42501, SELECT/UPDATE/DELETE see nothing, on both tables, after C and after C.down; service_role rollback leaves nothing; CHECK/NOT NULL/fence refusals unchanged (23514 / 23502, fence before NOT NULL). |
| C18 | real (see C-1) | ingest during the pass leaves e2 in staging, absent from ledger, no Person; replay → staged 2 / reconstructed 2; ledger count == staging count; third pass identical. |
| C11 / C12 / C13 | real | fixed text, `ERROR:  23505:` under verbose, no `DETAIL: Key`, none of the fixture identifiers in psql output, full snapshot unchanged, `narrowNamed()==[]` (no half-narrow). |
| C14c / C14d | real | table decoy under the staging name + index decoy under the 70-char ledger name (truncates to the stored name): C.down `contract absent`, C.up `unexpected prerequisite`, shadow or not, decoys untouched; ledger-named decoy alone; C.down rerun after restore refused. |
| C15 | real | R/B/E downs each refuse with their own narrow-prerequisite text, snapshot unchanged, deploy still "No pending". |
| C10 | real | C.down under shadow path restores exact narrow defs, wide/fence/rows/targets byte-equal, +2 indexes, history not rewritten; narrow arbitrates again (23505); both writers idle; full R→B→E down (E first refuses assigned provenance, ledger emptied for the E step only as dispositioned) and E→B→R→C up; index defs equal the installed C catalog; staging byte-equal; ledger re-derived to identical identities/targets. |
| N/Q1 continues | real | old N writer admits a cross-family tuple on re-C; both readers page it; roster unaffected. |

No tautologies found: every expected value is either a literal, a pre-recorded independent snapshot, or a cross-source comparison (reader output vs ledger query). No expectation was tuned to an observed failure in the PG spec; the one gate-time correction (unit fake tally cumulative) follows the addendum's "assertions follow the real behaviour" rule and is documented.

Run-time sanity for the single run: N/Q1 (20 tests, same fixture) took 355 s; this spec has ~60 worker forks and ~6 deploys — well under the runner's 1500 s jest bound and the 240 s per-test timeout. `max_connections=40` vs 8 long-lived ingest PrismaClients + transient workers/psql: adequate headroom. Disk: 3.7 G free; old-root clone + cluster ≈ 150–250 MB.

## 4. Binding — pins correct, drift refused

Machine-checked against HEAD (all OK): `EXPECT_HEAD`, `EXPECT_TREE`, `EXPECT_SPEC_BLOB` (`6c40544d`), `EXPECT_BOOTSTRAP_BLOB` (`54ad1352`), `EXPECT_FIXTURE_SHA`, `EXPECT_NM_LOCK_SHA`, `EXPECT_NM_CLIENT_SHA`, all 5 S5 + 6 B + 8 R + 7 N/Q1 blob pins, N/Q1 and R ancestor checks, `postgres`/`initdb` sha256 and `17.6`, `BINDING.sha256` 3/3 OK, receipts 13/13 OK. Filled runner differs from the phase-1 template only by the header word, seven pin lines and the two N/Q1 blob ids (diffed). Refusals: placeholders, sha/blob/tree/HEAD mismatch, dirty worktree, MERGE_HEAD, hookless commit, symlinked/foreign node_modules, existing `c-contract` cluster or `c/runtime/old-root`, port busy, any postgres process, S5 present, sentinel present, lock busy. Environment now: `c-contract` and `c/runtime` absent, port 55491 free, 0 postgres processes, `nq1` cluster stopped (no `postmaster.pid`), S5 absent, hooks are lefthook at the shared `.git/hooks`. Guard/bootstrap/fixture markers agree (`c-disposable-pg17`, `c-g2-contract-synthetic-disposable-fixture-safe-to-drop`, port 55491, db `g2_c_disposable`, role `c_super`, `connection_limit=4` within the guard's ≤10).

## 5. Identity / hooks

Author = committer = `Bradley Gleave <bradley@bradleytgpcoaching.com>`, 2026-09-24T21:22:53Z, no trailers, body clean (checked); one ordinary commit on top of `29e60705`; worktree porcelain 0 lines; receipts 14 (hooks ✓) sealed.

## 6. Findings (Safety ROI)

No A. No B.

- **C-1 (record) — C18 window wording.** The pinned worker's `staged` barrier fires after the count *and* the first page read (`g2-tq0-worker.cjs:48-50`), so the late ingest is exercised after paging and before the ledger write, not "between the count and the page" as the `it` title says (the inline comment is accurate). Grant requirements (a) convergence/tally-equals-ledger and (b) staged observability are proven; page-shift across pages (>500 rows) is not exercised. Closure is wording only; the worker may not be modified. Continue.
- **C-2 (record; D-C2 owner input) — C.down at production volume.** Two full-table GROUP BY scans and two index builds each run under `statement_timeout='30s'`; the decision doc says "retry later", but a scan that exceeds 30 s does not get faster on retry. Brief §5's "stop and design an online build" advisory should ride with the C promotion dispatch. Not a local blocker.
- **C-3 (record) — chain-harness PG15 dry-run** deferred to the PR's CI `migration-dry-run` (no server locally; grant forbade PG). Local PG17 covers refusal paths CI cannot.
- **C-4 (record) — C16 title** says "three platforms"; only two are registered mappers, the third is a genuine `skipped` (documented deviation 1). Assertions are correct for the real readers.
- **C-5 (record) — unit fake coverage shift**: narrow-collision→409 fake case removed; P2002-persists→409 still covered at L446. No gap.
- **C-6 (record) — C10 does not diff against the stage-3 `beforeCatalog`** directly; it proves the same content (tables/policies with OIDs, wide with OIDs, exact narrow defs, index count) against the installed C catalog plus `narrowDefs()==NARROW_SHAPE`. Equivalent.

## 7. Decision

**GO** for a single `c-pg-proof.sh` run on the committed head `16cd67f4`. Nothing here authorizes push, merge, deployment or production C.down.

---

## Addendum — B1 closure delta check (~22:45Z): GO on `1b6cc661`

Scope: delta only, `16cd67f4..1b6cc661` (`SOURCE_READY_B1.md`, `c/export/c-b1-delta-16cd67f4-to-1b6cc661.patch`, rebound runner `cf462851…`). Read-only; no PG.

**Defect was real (my miss in the first pass).** `narrow()` joined `pg_index` to `pg_class` filtered by relname + `relnamespace='public'` only. C14c creates `CREATE INDEX "ScoutReconstructionLedger_coach_id_intent_id_entity_type_source_id_key" ON public.g2c_decoy (x)` (spec L1021) *before* `const before = snapshot(); expect(before.narrow).toEqual([])` (L1027-1028), so `narrow()` would have returned the decoy index and C14c failed deterministically before its own `DROP` statements (L1042/1045); the surviving decoys then break C15's and C10's `before.narrow`/`narrowDefs()` preconditions. Classification B (proof-invalidating, would burn the single run); no product harm.

**Closure correct and complete.** The hunk adds `AND i.indrelid IN ('public."ScoutIngestEntity"'::regclass,'public."ScoutReconstructionLedger"'::regclass)` — the same relation binding the migration gates use — and nothing else (`git diff 16cd67f4..HEAD` == the exported delta patch, 1 file +2 −1; verified byte-equal). With it, C14c's decoy index (indrelid = `g2c_decoy`) is excluded, the decoy *table* under the staging name never entered `pg_index`, and C10's restored indexes (indrelid = the real tables) are still returned. Remaining catalog helpers re-checked: `wide()` is relname-only for the two `*_identity_key` names but the spec decoys only the narrow names; `narrowNamed()` is relname-only by design (it is the decoy detector C14c asserts on); `catalog()` is already `indrelid`-scoped; `expectTableUnlocked` matches `pg_locks` by table relname and is only called when no `shadow` schema exists (C09a/C09b). No other helper affected. No new A/B.

**Rebound runner correct.** HEAD `1b6cc661` (parent `16cd67f4`, grandparent `29e60705`; no amend), tree `cea54631`; SPEC `6c40544d` and BOOTSTRAP `54ad1352` blobs unchanged; harness blob now `5186c351`. `c-pg-proof.sh` sha `cf462851…` differs from the phase-2 runner only by the header head-id and `EXPECT_HEAD`/`EXPECT_TREE` (diffed); `BINDING.sha256` 3/3 OK; receipts 15/15 OK; worktree clean; author = committer = Bradley, no trailers, lefthook hooks (receipt 16). All other pins unchanged and still valid (client/lock shas, N/Q1 blobs, PG17 binaries).

**Verdict: GO** for a single `c-pg-proof.sh` (`cf462851…`) run on `1b6cc661`. Prior C-1…C-6 stand unchanged.

---

## Addendum — single PG run outcome (~22:55Z): FINAL ACCEPT

Verified from `c/C_PG_PROOF_RESULT.md`, `c/runtime/run/*`, receipts 17–18 (no source re-audit):

- **Exact head / runner**: sentinel `RC=0 STAGE=done END=2026-09-24T21:50:54Z HEAD=1b6cc661…`; runner `START … head_expect=1b6cc661…` and `PRECONDITIONS_OK` (HEAD/tree/spec/bootstrap/all blob pins/client/lock/PG17 shas pass or the runner fails 70); wrapper receipt 18 shows `c-pg-proof.sh: OK` against `BINDING.sha256` immediately before launch, and `binding/c-pg-proof.sh` still hashes `cf462851…` now. Receipt 17 is an aborted wrapper self-check that never launched the runner (no lock, no PG, no `c/runtime`) — recorded, not a retry. `s7-c` HEAD is still `1b6cc661`, porcelain empty.
- **Evidence**: `jest.log` sealed (`75a2c4ea…` OK); `c-pg-proof.log` seal `0739306e…` reproduces from `head -n -2` (the runner appends `POST_OK`/`END` after sealing, same as N/Q1). Jest: 1 suite, **22/22 passed**, 0 failed/skipped, 111 s, `--runInBand --ci`; every C01–C18 case plus N/Q1 continuity present as ✓ (C14c — the B1-closed case — green). In-spec identity `g2_c_disposable` on 127.0.0.1:55491, PG 170006, data dir `clusters/c-contract/pg-data`, non-superuser BYPASSRLS `postgres`. `PG17_C01 removed` = exactly the two narrow unique index definitions; `PG17_LOCK_TIMEOUT` 5033 ms (C.up) / 5034 ms (C.down); `PG17_C11_REFUSAL` shows `ERROR:  23505: G2-C.down refused…` with no identifiers; old writers ran from `29e60705` (`PG17_PROCESS old:true`).
- **Cleanup**: `STOP_STATE_OK postgres_procs=0 port55491=free`, no `postmaster.pid`, 0 postgres processes now; data dir retained (destroy is a separate grant); `nq1` cluster conf/pg_control unchanged; S5 absent unchanged; lock file present.

**FINAL ACCEPT** — C (`20270121000000_scout_identity_contract`, C.up + refusing C.down) is locally accepted on `1b6cc661` per C01–C18 + D-C1/C18 + N/Q1 continuity. Local proof only: not deployment, drain of any real database, or customer acceptance; C-1…C-6 carry as recorded (C-2 rides with the D-C2 promotion dispatch).
