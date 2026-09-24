# S7-C phase 1 re-draft — READY (source-only)

Lane: S7-C (narrow-key contraction + C.down refusal). Builder role: sole T4 builder for the lane.
Authority: `execution/ce3748cb/C_PHASE1_REDRAFT_GRANT.md` → `execution/cf8ff737/c/PHASE1_DRAFT_READY.md`
(lost-draft specification) → `C_BUILD_GRANT.md` / `c-prep/C_SLICE_BRIEF.md`.
Session: `ce3748cb`. Date: 2026-09-24.

## State

- Worktree `/home/user/workspace/worktrees/s7-c`, branch `s7-c`, HEAD `61b93cff7900b24c17011d481fd6c31f5abb59e4`
  (tree `7adad6965d60269046b3240343b54d7f71582d70`), created with
  `git worktree add -b s7-c … 61b93cff…` from `/home/user/workspace/repos/growth-project-backend`.
- Ten files authored, ALL untracked (`git status --short` = 9 `??` entries; the migration directory holds two files).
- Phase-1 constraints held: no `npm install`, no node_modules in `s7-c`, no tests run, no PostgreSQL, no lock,
  no commit, no push. `s7-nq1` and `/home/user/pg17` never written.
- `bash -n` passes on `test/utils/g2-c-bootstrap.sh` and `test/utils/g2-c-old-root.sh`.
- The five `.ts` files parse (syntax only, `typescript.transpileModule` with `reportDiagnostics`, using the
  compiler already present read-only under `s7-nq1/node_modules/typescript`; nothing written there). No
  type-check (needs a dependency tree; phase 2).
- Preserved binding (`execution/cf8ff737/c/binding/`) unchanged — sha256 re-verified, see below. No
  re-derivation mismatch found.

## File table (`wc -l`, `sha256sum`) — worktree-relative

| Path | Lines | sha256 |
|---|---:|---|
| `prisma/migrations/20270121000000_scout_identity_contract/migration.sql` | 106 | `4f2d3bdc0b308bcd2057b417473f02082c9728df767e71c4a3906f9b9f564b1b` |
| `prisma/migrations/20270121000000_scout_identity_contract/down.sql` | 117 | `17bd9354ea4cf8d67ed9aee3a570677110ff6204c030e1e9d577bb537b0d36a0` |
| `test/utils/g2-c-db.ts` | 109 | `1558eb91ecac0e0aa0aeb4683d8ed42320845b14c155a09eec18d8f6d653c172` |
| `test/scout/g2-c-db-guard.spec.ts` | 112 | `758bcc0895e4e36d3db99cdd41a1fa163f11af3cd616c8e4a01feaa3e0e19866` |
| `test/utils/g2-c-pg-harness.ts` | 375 | `4d2d04ef643ad584f5c76ceae9d38e0ac2641e76d083f35ddc60306951d9c003` |
| `test/utils/g2-c-harness.ts` | 231 | `6d8350d188540ed60011985772efdd11c49ea4c80c528c6f756192c47f886123` |
| `test/utils/g2-c-bootstrap.sh` | 279 | `6c19197d69c264fe9f3b18361c1bc51ad33af9d160a8e2df8a83c3e9c032c003` |
| `test/utils/g2-c-old-root.sh` (added to owned paths by the grant) | 105 | `b27ebcef00e56c4765f638d19c537a62785e9c2fe24d2f60695adcdf9cc9921e` |
| `test/rls-g2-c-contract.spec.ts` | 1087 | `700811ebbb9a46134ab54961afe0041445e18c8b5af1b545e13e303faa8b7a1b` |
| `docs/decisions/2026-09-24-g2-identity-contract.md` | 124 | `c56c8fb3f8d92e0cba3f414cd88111d32afa74adc65966a17330bb0a01c9f4f3` |

Preserved binding, unchanged (sha256): `c-pg-proof.sh c84ffb12…dbdb04d4`, `c-fixture.sh cf342f4b…f259b3`,
`derive-c-pg-proof.py 4476ec0e…37500a`, `README.md 6655f5b1…dd441f`, `PINS.txt 102727c9…324d6e`,
`BINDING.sha256 5edd77b1…12da57`, `c-pg-proof.sh.diff-vs-nq1 3598bd98…80ca4`.

## What each file is (as specified; deltas noted in "Deviations")

- **migration.sql (C.up)**: `BEGIN; SET LOCAL lock_timeout='5s'; SET LOCAL statement_timeout='30s'; LOCK TABLE`
  both public tables `ACCESS EXCLUSIVE`; gate 1 = both narrow keys exact (R.down's loop verbatim) else
  `G2-C unexpected identity prerequisite`; gate 2 = R's wide keys + both canonical CHECKs valid else
  `G2-C wide identity absent`; gate 3 = both `source_platform` columns TEXT NOT NULL without default and no NULL
  ledger rows else `G2-C wide identity absent`; `DROP INDEX public."…"` ×2 (schema-qualified); `COMMIT`.
- **down.sql (C.down)**: same envelope; decoy/entry check via `to_regclass` on both `public.`-qualified narrow names
  → `G2-C contract absent`; R wide/CHECK/NOT NULL loop → `G2-C contract absent`; collision pre-check
  (`GROUP BY … HAVING count(*)>1` on staging `(c,i,s)` and ledger `(c,i,e,s)`, both BEFORE either CREATE) →
  `RAISE EXCEPTION '<fixed text>' USING ERRCODE='unique_violation'` (no identifiers, no `DETAIL`); byte-exact
  `CREATE UNIQUE INDEX` ×2 `ON public."…"`; postcondition loop → `G2-C narrow key not restored exactly`; `COMMIT`.
- **g2-c-db.ts / g2-c-db-guard.spec.ts**: `G2_C_*` target contract; DB `g2_c_disposable`; role `c_super`; markers
  `c-disposable-pg17` / `c-g2-contract-synthetic-disposable-fixture-safe-to-drop`; REFUSED_PORTS + `55481`;
  guard port `55491`, ack `g2_c_disposable:55491`, refuses nq1/r/b identities, marker regex `^c-`.
- **g2-c-pg-harness.ts**: substitution of the committed N/Q1 pg-harness (`OLD_HEAD='__NQ1_ACCEPTED_HEAD__'`,
  worker prefix `g2c_`, env `G2_C_*`); same exports. One addition: `holdTransaction(...).rollback()` (ends the held
  transaction with `ROLLBACK`, used by C09b's "held ingest insert never lands").
- **g2-c-harness.ts**: `C_MIGRATION`, `cUp/cDown(File)`, `NARROW_*_NAME/DEF`, `C_DOWN_REFUSAL`, `wide()`,
  `narrow()`, `narrowNamed()`, `identityRows`, `stagedRows`, `narrowDuplicates(intent?)` (scoped or global),
  `ledgerRow`, `appliedSince`, `fence`, counts/snapshots, `runtimeClient`, `ingestClient(name)` = the REAL
  `ScoutIngestService` on the candidate C client as service_role with in-memory analytics (worker not modified).
- **g2-c-bootstrap.sh**: derived from committed `g2-nq1-bootstrap.sh`; `OLD_HEAD=__NQ1_ACCEPTED_HEAD__` with a
  40-hex gate; ancestor check; old root has E+R and lacks C; candidate-vs-old `prisma/migrations` diff == exactly
  C's two files; no `verify.sql`; old-root `prisma migrate deploy` → 169; wide 2 / narrow 2 / C not recorded; old
  client = N's (required String, both narrow `@@unique`); candidate client = C's (no narrow `@@unique`); markers
  `G2_C_GENERATE_OK` / `G2_C_BOOTSTRAP_OK`.
- **g2-c-old-root.sh**: derived from committed `g2-nq1-old-root.sh` (grant disposition 7): `OLD_HEAD` placeholder
  + 40-hex gate, `G2_C_OLD_ROOT(_SHARED)`, marker `G2_C_OLD_ROOT_OK`, `EXPECTED_MIGRATIONS=169`, old root must have
  E+R and lack `20270121000000_scout_identity_contract`, exact-two-files migrations diff, byte-compare of
  `src/scout/{scout-reconstruct,scout-roster,scout-entities,scout-ingest}.service.ts` + `scout-cursor.ts` against
  `$OLD_HEAD:`, old ledger `source_platform +String( |$)` and BOTH narrow `@@unique` present.
- **rls-g2-c-contract.spec.ts**: 6 ordered `describe` stages, 21 `it` blocks (one `it.each` over
  `['clients','workouts']`), `jest.setTimeout(240000)`, `--runInBand`. Case → test mapping below.
- **decision record**: E-record format; scope; D-C1 (no seal, S9 carry-forward); C.down refusal semantics +
  forward-repair-only; runbook down order C→R→B→E with every refusal message; lock-timeout = retry later;
  `prisma migrate resolve --rolled-back …` as S1's step; D-C2 stepwise promotion + production preconditions;
  `readDrainState` over-count / backfill-CLI retirement note; CI PG15 empty-DB parity note; sources with URLs.

## Case → test mapping (spec)

| Stage | Test | Cases |
|---|---|---|
| 1 | real ingest dedupes 2nd family / 2nd platform on R; raw 23505 names narrow index | C02 (negative control) |
| 2 | C.down before C → `G2-C contract absent`, unchanged | C14a |
| 2 | held ledger read vs C.up → 55P03, 4500≤ms<30000, unchanged, lock freed | C09a |
| 3 | `prismaMigrateDeploy` names only C; `appliedSince==[C]`; 170; `narrow()==[]`; wide/fence/tables/policies equal; index set −2 == exactly both narrow defs; rows identical; 2nd deploy "No pending" | C01 |
| 3 | C.up rerun → `G2-C unexpected identity prerequisite`; shadow search_path; catalog still −2 | C14b |
| 4 | one source × 2 then × 3 families, deduped 0; `narrowDuplicates` scoped 1/1, global 2; `ON CONFLICT DO NOTHING` with no target | C03, C04 |
| 4 | replay / captured_at / in-batch (3→1) dedupe; other intent & coach insert | C05 |
| 4 | one source × 2 platforms: 2 rows, replay deduped 2, events [[2,0],[2,2]], writer → 2 identities, 2 Persons | C06 |
| 4 | workouts `w` on truecoach/conformance_alpha/unknown_platform → 3/2/1/0, reason `unsupported_platform:unknown_platform`; replay + old writer identical | C07 |
| 4 | races a–e (`before-ledger` / `staged` pauses, `blocked()`, mapper `skip`, concurrent cross-family/platform) | C08 |
| 4 | held uncommitted ingest vs C.down → 55P03; `rollback()`; row never lands; later ingest counts exact | C09b |
| 4 | `it.each` real ties: enumerate at limit 1 on both heads; tied legacy → 400 no page read; untied resolves; old reader on candidate v2 token | C16 |
| 4 | anon/authenticated 42501 + 0 rows; service_role ROLLBACK leaves nothing; 23514 CHECK/fence, 23502 NOT NULL | C17a |
| 4 | late ingest at `staged`: tally 1/1; e2 staged, no ledger row, no target; replay 2/2 == ledger; 3rd replay identical | C18 (D-C1) |
| 5 | cross-family staging collision → fixed text, `ERROR:  23505:`, no `DETAIL: Key`, no identifiers, unchanged, `narrowNamed()==[]` | C11 |
| 5 | cross-platform staging collision → same | C12 |
| 5 | ledger-only collision → same (no half-narrow state) | C13 |
| 5 | decoy table named as staging key + decoy index named as ledger key: C.down `contract absent`, C.up `unexpected prerequisite`, shadow both directions, decoys untouched | C14c |
| 5 | R.down / B.down / E.down with C applied → `G2-{R,B,E} unexpected identity prerequisite` | C15 |
| 6 | C.down under shadow → R shape (OIDs aside), rows/targets intact, history not rewritten, narrow arbitrates, writers idle; C.down rerun `contract absent` (C14d); security repeated (C17b); R.down→B.down→E.down (first `G2-E refuses removal of assigned provenance`, then ledger emptied for E only)→E.up→B.up→R.up→C.up; staging byte-equivalent; catalog shape == C shape; ledger re-derived identical (incl. target ids) | C10 (+C14d, C17b) |
| 6 | old writer admits a cross-family tuple after re-C; both readers page it; clients reader unaffected | N/Q1 continues on C |

## Verified facts (against the 61b93cff source, this session)

- The seven N/Q1 blob ids named in the preserved runner match HEAD (`g2-nq1-db.ts dbe10bcb…`,
  `g2-nq1-pg-harness.ts c8f6fea8…`, `g2-nq1-harness.ts a629c591…`, `g2-nq1-bootstrap.sh 96b7668d…`,
  `g2-nq1-old-root.sh 4569f5fe…`, `g2-nq1-db-guard.spec.ts 9bc14800…`, `rls-g2-nq1.spec.ts 8ad3af3f…`).
- `schema.prisma`: staging narrow `@@unique([coach_id, intent_id, source_id])` (L6893), ledger narrow
  `@@unique([coach_id, intent_id, entity_type, source_id])` (L6951), wide maps L6896/L6957, ledger
  `source_platform String` (required, N). `ScoutIngestEntity` has no status column. Ledger has no `updated_at`;
  `Person` and `ScoutReconstructedEntity` have `@updatedAt` (so a writer replay bumps target `updated_at` only —
  the spec compares targets without it after replays, strictly across pure DDL steps).
- `ScoutIngestService.ingest` → `createMany({skipDuplicates:true})`, returns `{received, deduped}`, captures
  `analytics.capture(coachId, 'scout.ingest.received', {intent_id, entity_type, received, deduped})`; no
  `ScoutImport` settlement check on ingest.
- Reconstruct: count → offset-paged findMany (500) ordered `(source_id, source_platform)`; per row: mapper →
  target upsert (Person `update:{display_name}`) → ledger upsert on
  `coach_id_intent_id_entity_type_source_platform_source_id` with `update:{}` then precedence `updateMany`
  (success dominates); skipped/failed via the same write; tally cumulative over the ledger; P2002 after retry →
  409 `reconstruction provenance conflict`.
- Registered mappers: `truecoach`, `conformance_alpha` only; unregistered → `{ok:false, reason:'unsupported_platform:<token>'}`
  → `skipped`.
- Worker `g2-tq0-worker.cjs` barriers: `staged` after `findMany`, `before-ledger` before the ledger upsert;
  options as used (`action`, `family`, `intent`, `cursor`, `limit`, `pause`, `txTimeout`, `mapper`). Not modified.
- Q1 readers page only `status='reconstructed'` rows ordered `(source_id, source_platform)`, `take limit+1`;
  legacy token scoped to reconstructed rows: 0 or ≥2 matches → 400 `malformed cursor`.
- Down gates: B.down L36 `G2-B unexpected identity prerequisite`; E.down L35 `G2-E unexpected identity
  prerequisite`, L52 `G2-E refuses removal of assigned provenance`, and E.down also requires the column nullable
  with no constraints (so R.down must precede it); R.down afterwards → `wide()` =
  `{indexes:[], checks:[], ledgerNotNull:false}` (R.down L78-85; nq1 N05 L395 asserts the same); R.up requires the
  fence (`G2-R fence absent`) so B.up precedes it. Chain C→R→B→E down and E→B→R→C up is therefore valid.
- `sql()` runs psql over stdin (`-X -w -qAt -v ON_ERROR_STOP=1`), so `\set VERBOSITY verbose` + `\i <file>`
  in one input is valid (the R spec's `refusedCode` already relies on the stdin form).
- CI: `migration-dry-run.yml` uses `postgres:15.18`; `ci.yml` `postgres:15`. `readDrainState`
  (`scout-ledger-backfill.ts` L227) joins the narrow tuple and reports `mismatch`.
- Prettier: singleQuote, trailingComma all, printWidth 100 (long `it(...)` titles/`expect` lines exceed 100 and
  will be reflowed by `prettier --write` in phase 2, as the R/N-Q1 specs were).

## Deviations from the preserved specification (`PHASE1_DRAFT_READY.md`)

1. **C16 tokens (real reader behaviour).** The lost draft expected
   `[v2(a,conformance_alpha), v2(a,p3), v2(a,truecoach), v2(d,truecoach), null]`. With registered mappers only
   `truecoach` and `conformance_alpha`, the `p3` row is `skipped`, and the Q1 readers page reconstructed rows
   only; at limit 1 the tokens are `[v2(a,'conformance_alpha'), v2(a,'truecoach'), null]` and the union is the
   three reconstructed targets. Tied legacy `a` → `{400,'malformed cursor'}` (2 reconstructed matches); untied
   `d` resolves to an empty final page. Encoded that way.
2. **C02 ledger wording.** The draft said the ledger narrow key "refuses a second platform and a second family";
   the ledger narrow key is `(c,i,e,s)`, so a second family is a distinct key and is admitted. The spec asserts:
   ledger refuses a second platform (23505 naming the 63-char narrow name), staging refuses a second family.
3. **`narrowDuplicates(intent?)`** gained an optional intent scope so C03/C04/C06/C07 assert per-intent
   `{staging, ledger}` exactly while stage-4 fixtures accumulate; global counts are still asserted where the draft
   did (C04 global staging == 2; stage 5/6 `{0,0}` preconditions).
4. **`holdTransaction().rollback()`** added to the C pg-harness (C09b: the held ingest insert must NOT land).
   Everything else in the pg-harness is pure `nq1→c` substitution.
5. **C10 target comparison** strips `updated_at` after writer replays (fact above); strict `targets()` equality
   is kept across the pure DDL transitions (C.down, E.down, chain up) where no writer ran in between.
6. **C14c** covers both narrow names with two decoy kinds (a table named as the staging key, an index on
   `public.g2c_decoy` named as the ledger key — the 70-char text truncates to the stored 63-char name) and then
   the ledger-named decoy alone; the draft named one decoy table.
7. **C08** adds (e): concurrent candidate-clients / old-workouts runs on one source across families and platforms
   (3 outcomes, 2 Persons, 1 entity), per the brief's "other platform/family → distinct outcomes".
8. **old-root.sh** byte-compares `scout-ingest.service.ts` and `scout-cursor.ts` in addition to the three N/Q1
   files (the C proof uses the real ingest service and the Q1 cursor module).
9. Line counts differ from the lost draft's by a few lines per file (re-authoring); no case was dropped.

## Phase-2 open items (carried, not started)

- `prisma/schema.prisma`: remove the two narrow `@@unique` declarations (C client), keep the wide maps.
- Fill `__NQ1_ACCEPTED_HEAD__` in `g2-c-pg-harness.ts`, `g2-c-bootstrap.sh`, `g2-c-old-root.sh` (and the binding
  PINS) once the parent records N/Q1 acceptance.
- `npm ci` (lockfile unchanged), `prisma generate` for both roots, `prettier --write` on the new `.ts`,
  type-check, `jest test/scout/g2-c-db-guard.spec.ts`, then the lane run via the preserved binding runner.
- Commit → fill `EXPECT_SPEC_BLOB`/`EXPECT_BOOTSTRAP_BLOB`/tree pins in the binding (append-only lane record).
- `readDrainState`/backfill CLI retirement is recorded in the decision record, not implemented (out of C's owned
  paths).

STOP: awaiting the phase-2 message. No commit, no push, no tests, no PostgreSQL touched.
