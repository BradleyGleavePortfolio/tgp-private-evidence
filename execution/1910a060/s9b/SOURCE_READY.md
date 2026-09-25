# S9-B SOURCE_READY (EXEC-1910A060, lane B-NEW-1 "Build new S9-B reconciliation facts", 2026-09-25)

**State: SOURCE_READY — unformatted, un-type-checked, untested, uncommitted.** No installs, no
gates, no commit, no PG, no lock, no push. Nothing in the repository or evidence tree was deleted.
The S9-A owned files, lifecycle, status DTO, contract generator, S8-G and `prisma/**` are untouched.

## 1. Where

- Standalone clone `/home/user/workspace/worktrees/1910a060-s9b`, branch `exec1910/s9b`, HEAD =
  base `1c5fbb0441178e0cfe6e9f8d72e955c645c265e9` (tree `82b56ad373c9cb4888b7c9b79544fbbb6f55c0d6`),
  no `node_modules`. `git status`: 1 modified (doc addendum), 10 untracked owned files, 4 untracked
  READ-ONLY dependency copies.
- Evidence: `tgp-private-evidence/execution/1910a060/s9b/**` only (this file, `CODE_READ_NOTES.md`,
  `S9_0_ADDENDUM_DRAFT.md`, `binding/v1/`). Evidence repo not committed.

## 2. Pathlist contract (exact sha256, `sha256sum` in the clone)

### 2a. OWNED by S9-B (commit ownership; all new except the doc, which is append-only)

| Path | sha256 | Notes |
| --- | --- | --- |
| `src/scout/reconciliation/facts.service.ts` | `828c9d4c23ca1ff512ca26002d9888d4158eae5e2507cbfa859dabf95ef7f42b` | `ReconciliationFactsService.collect(db, coachId, intentId)`; DI seam `RECONCILIATION_FACTS_OPTIONS`; `identityKey`, `parentSourceIdOf` |
| `src/scout/reconciliation/reconciliation.module.ts` | `f2c1e4476f21830fcc51921ac2b612235b650f1cf74e39bb38a62d80decd84e1` | provides/exports the service; imported by nothing (no `scout.module` edit) |
| `test/scout/reconciliation/facts.service.spec.ts` | `e72fb4b570d862cc33fce55934b2338db0f33a3ccf7e55d47666d21b0a951091` | in-memory Prisma double (reads only; writes throw); 7 groups incl. B-2 and composition with frozen `reconcile` |
| `test/utils/g2-s9-db.ts` | `a1611c51c367fc796e5983d7b0aa7f60de68565febd65ead8346acff0545aaf7` | S9 identity guard; refused ports += 55642, 55643; lane port NOT hard-coded |
| `test/utils/g2-s9-pg-harness.ts` | `8274a85b011f00e60fc9247b550373f9391d27b40c375f55e98f7accb70e2def` | `EXPECTED_MIGRATIONS = 172`, `S7L_MIGRATION`; worker `mode` option |
| `test/utils/g2-s9-harness.ts` | `16a5aeac75f189de09bba7b55b8a829ff96120e42b7e4a619d99b60d17e387ff` | fixture `s9-proof` + `s9-proof-b`, `claim()`, `COMPLETION` reset |
| `test/utils/g2-s9-worker.cjs` | `5e52b9188cc6a46232723dba7ee0db1cfb9241934644bc3992f656b8bfe622db` | `mode: 'facts'` (real facts + frozen reconcile in one RepeatableRead tx) / `mode: 'reconstruct'` (real S8-C writer) |
| `test/utils/g2-s9-bootstrap.sh` | `8452feba381d790f703c956403a0798d56f498def3663df0b6c32155d63ea682` | base 1c5fbb04, 172 migrations, S7-L/S8-B/S8-C objects asserted, structural client check (no invented SHA); `bash -n` OK |
| `test/scout/g2-s9-db-guard.spec.ts` | `307d8fa4a60ae3bc09e5a9084273b5c1f79d23147098e3e472c778a2b5452879` | default-suite guard spec; example/ack port 55645, mismatch probe 55646 |
| `test/rls-g2-s9.spec.ts` | `b854fd59ab1cb174ce55afff3da62974e8373e9d2f672140b34a9a793d485fb6` | live proof: lane identity; empty run; real writer → real facts (R04/R05/R06/R11/R12/RC-3/B-2); read-only + bounded SELECTs |
| `docs/decisions/2026-09-25-s9-reconciliation.md` | `2b60cdaa4379259c6c743108222bf0e5ec954ff62831b439082b907d0a93e3b1` | landed text unchanged (`git diff`: +96 lines, 0 deletions); **Addendum A** appended = `S9_0_ADDENDUM_DRAFT.md` (`e0faee18…`). Parent may `git checkout -- docs/…` to keep the doc evidence-only |

### 2b. READ-ONLY dependency copies — NOT owned, EXCLUDED from S9-B commit ownership

Byte-identical to the frozen S9-A source (`daceddc8/s9/gate/preformat-*.ts`; parent mail 14:13 PT),
present only so the S9-B files resolve their imports. They belong to A-NEW-1; parent composition
decides how they land. If the parent prefers them absent from this clone, `rm` of these four paths
leaves every owned file intact.

| Path | sha256 | git blob |
| --- | --- | --- |
| `src/scout/reconciliation/types.ts` | `eff1479cd2b735aacadc42ee3e2280dcfaf2e4fcc27a1fb90fd2c2bf2db1dbfa` | `bb28f151a88435abc69d337a92dd3bc2ab7203bd` |
| `src/scout/reconciliation/coverage.ts` | `c6b224fa860261d6240c5bd62b07d419c6b9346c0b0de4eaac64dd9215926701` | `e13c336ad35a43a26a5e8856a8e810eb96c5dd99` |
| `src/scout/reconciliation/reconcile.ts` | `83d7673b024513bbee938bf4a5467c4faa9306739f15ae53b69722936d7d9e1f` | `3932cd3caed21d705c5718e547e225c1a326d5ad` |
| `test/scout/reconciliation/reconcile.spec.ts` | `99068057b0b99d95c9601c02130e4eca2b3b07acd0e0088fae146cb2f54edb74` | `df887df51a25f48b77564931eac75af5ed71a153` |

### 2c. Evidence (this lane; not committed)

`CODE_READ_NOTES.md`, `S9_0_ADDENDUM_DRAFT.md` (`e0faee180473d0cb64d60036d216d6320acdd3e827304e7d6aea834ff79ab7ef`),
`binding/v1/README.md` (`f32123b1…`), `binding/v1/PINS.txt` (`bcb566d5…`),
`binding/v1/s9b-fixture.sh` (`6fb78034…`), `binding/v1/s9b-pg-proof.sh` (`c41a9e79…`).

### 2d. Not touched (asserted by the binding at 1c5fbb04 blobs)

`prisma/**` (schema `2e328bbc`, migrations tree `654550cb`), `src/scout/lifecycle/**`
(`c345dd54`), `src/scout/reconstruct/**` (`c4ae4b8e`), `scout-reconstruct.service.ts`
(`711bfb09`), `jest.rls.config.js` (`44c96915`), all seven `g2-s8c-*` / `rls-g2-s8c` files,
status DTO, contract generator, S8-G paths, `execution/test-validation.lock`.

## 3. What the facts service does (native evidence truth)

- `collect(db: Prisma.TransactionClient, coachId, intentId): Promise<ReconciliationFacts>` —
  pure reads (`findUnique`/`findMany` only), tenant-scoped (`coach_id` on staging, ledger,
  provenance, completion; native rows fetched by id then compared to `coach_id` → `foreign_owner`).
  No persistence, no side effects, no source-specific core (registries injected or built from the
  accepted builders), `coverage: null`, created/already split never computed (S9-A emits `null`).
- Grouping: `resolveStagedFamily`, then spec-declared canonical token (S8-C `dispatch`
  precedent); otherwise unmapped entry keyed by raw token with `unresolved_family:<token>` /
  `unsupported_platform:<platform>`. `spec_families` = union of registered platforms' declared
  families; `null` if zero staged rows or any staged platform is unregistered.
- Ledger join on `(entity_type, source_platform, source_id)`; `ledger_without_staged` counted
  run-wide and attributed to the resolvable mapped entry (zero-identity entry created if needed);
  never dropped, never zeroed.
- Provenance: coach-wide by namespaces ∈ staged platforms and families ∪ `workouts.exercise`;
  native check order `kind_mismatch` → `provenance_mismatch` → `removed` (missing/archived) →
  `foreign_owner` → `present_owned`; `Person` has no `archived_at` (exists ⇒ present).
  `unresolved_children` histogram from child rows by reason.
- **B-2 closure:** one edge per declared relationship instance. E-R1 emitted iff the accepted
  interpreter derives `programSourceId` (targets the `programs` identity even when never staged
  or removed; `consistent` only on own unarchived plan + parent `present_owned` + `program_id` +
  `(week_index, day_index)` match). E-R2 one edge per created/already-present child (parent
  identity both ends; `#ord:<ordinal>` compared to `order`, `#id:` existence + `workout_plan_id`).
  E-R3 one edge per interpreted `clientSourceId`, `consistent: null`. An unresolvable parent is
  never silently dropped: the edge exists with `consistent: false`.
- Claim: `ScoutImportCompletion.terminal_status` ∈ `success|partial|failed`, else `null`.
  `ceiling_exceeded` when a canonical-family token exceeds `RECONSTRUCT_MAX_ROWS`.
  `qualifiers: ['roster_bridge_pending']` for `clients`; `client_owned` for `client_history`.

## 4. Gate plan (parent relay; runtime setup + S9-A gates come first)

Working tree needs an isolated donor `node_modules` (`cp -a`, per `daceddc8/runtime/lane-provision.sh`)
and the in-lane generated client for schema `0eb41f9a` (record `9042e713…`). Then, in order:

1. `B=/home/user/workspace/execution/64e33dc7/recovery-reset/s7l/tools/prettier-3.9.9` (or the
   1c5fbb04 runtime's prefix) — `prettier --write` then `--check` on the 10 owned files (`.cjs`,
   `.ts`, `.md`; the `.sh` is not prettier-formatted).
2. `npx --no-install eslint --no-warn-ignored --max-warnings 0 <owned .ts/.cjs>`.
3. `NODE_OPTIONS=--max-old-space-size=4096 npx tsc --noEmit`.
4. `npx jest test/scout/reconciliation/facts.service.spec.ts test/scout/g2-s9-db-guard.spec.ts
   test/scout/reconciliation/reconcile.spec.ts` (the last proves the frozen S9-A copy still
   passes alongside; not an S9-A re-audit).
5. `node scripts/check-r75.js`.
6. Re-hash the 10 owned files after formatting (this file's hashes are PRE-format); export.
7. Genuine hooked commit as `Bradley Gleave <bradley@bradleytgpcoaching.com>` (lefthook
   pre-commit/commit-msg present), only after parent composition with S9-A decides the four
   dependency paths.

## 5. Proof plan (separate parent grant; nothing run)

`binding/v1/s9b-pg-proof.sh` (derived from the accepted S8-C runner; refuses while any pin is
unfilled: 9 head pins, `PORT`, `RUNTIME_ROOT`, 7 tool pins) → `s9b-fixture.sh init/start` (PG 17.6
pins from the 1c5fbb04 runtime receipt; `daceddc8/runtime/rt-setup.sh` lineage) → committed
`test/utils/g2-s9-bootstrap.sh bootstrap` (172 migrations) → identity (`s9-disposable-pg17`,
`s9-g2-reconciliation-facts-…-safe-to-drop`, 170006) → `jest --config jest.rls.config.js
test/rls-g2-s9.spec.ts --runInBand --ci` once → bounded stop, data dir retained. Lock:
`exec 9>>"$LOCK"; flock -n 9 || exit 75`, held to exit; outer `timeout -k 30 3900`. Env style
`G2_S9_*`; grant flag suggested `S9B_PG_GRANT=1` for the parent's driver. Lane port: parent's
choice (55645 suggested).

## 6. Honest limitations

- Every file is hand-written without prettier/eslint/tsc/jest; expect formatting churn and
  possibly a handful of type errors (see `CODE_READ_NOTES.md` §"verify at gate time").
- The rls spec's `REPEATABLE READ` log assertion and the exact SELECT-count bound depend on
  Prisma's query-event wording; both are flagged for adjustment, not assumed.
- The S8-C-pattern harness keeps the pause/barrier instrumentation (unused in `facts` mode) to
  stay a literal derivative rather than a redesign.
- No decision text above Addendum A was changed; the addendum records RC-1..3, C-5..C-10 (second
  half of C-7), deviations 2/3/5 and the B-2 sentence, plus the facts rules the doc left implicit.

## 7. Addendum (14:59 PT relay): gate driver prepared, binding v2, lane port 55645

- `gate/s9b-gate-1910.sh` (`bash -n` clean; refusal paths exercised, nothing acquired), `gate/PINS.env`
  (`BASE=__FILL_M2__` only unfilled value), `gate/commit-message.txt`, `gate/commit-message-no-addendum.txt`,
  `gate/README.md` (relay line, required clone state, exit codes). Modeled on `s9a/gate/s9a-gate-1910.sh`; S9-B
  deltas: BASE variable, S9-A files asserted tracked+clean at accepted post-format shas, owned-path-only prettier
  (`.sh` excluded), eslint on owned `.ts`/`.cjs`, whole-repo tsc, R75 working-tree + staged, jest targeted then full
  default once, `S9B_INCLUDE_ADDENDUM=1|0` selects doc inclusion and message file.
- `binding/v2/` (v1 kept byte-identical as history: `6fb78034`/`c41a9e79`/`bcb566d5`/`f32123b1`): `PORT=55645`,
  `BASE_HEAD`/`BASE_TREE` → `__FILL_M2__` (covered by the runner's fill check), S9-A blob pins → accepted be88909f
  post-format blobs. Accepted-path pins verified identical at `1c5fbb04` and `62471b11`.
- Clone files untouched since §2 (reviews in progress): `git status` still 1 modified doc + 10 untracked owned + 4
  untracked S9-A copies; shas as in §2.
- Composition note for the parent (not actionable by this lane now): `g2-s9-db-guard.spec.ts` / `g2-s9-pg-harness.ts`
  pin exactly 172 migration dirs ending at the S7-L migration — the same shape `1c10e2a1` had to relax for the S8-C
  guard when a later lane landed a migration. Fine for M2 (no migration since 1c5fbb04); flag for any later
  composition that adds one.

## 8. CLOSURES-1 (15:16 PT disposition) — see `CLOSURES-1.md`

- Re-pinned owned files: `facts.service.ts` `e2f40a79…`, `facts.service.spec.ts` `9dcfbd96…`, doc (Addendum A)
  `be591e97…` (+99/-0 vs landed). All other owned shas in §2 stand. `gate/PINS.env` updated.
- `test/rls-g2-s9.spec.ts` is a parent-GRANTED added test-only path (deviation from the S9-0 exact-path sketch;
  the rls job's `test/rls-*.spec.ts` match is the reason it lives at the test root, as `rls-g2-s8c.spec.ts` does).
- Binding: `binding/v1` historical, not to be used; `binding/v2` is the binding.
- S9-A pre-format copies (four paths, §2b) are NOT in commit ownership; the gate runs on M2 where the accepted
  post-format bytes are tracked and asserts the copies are gone.

## 9. CLOSURES-2 (15:31 PT disposition) — see `CLOSURES-2.md`

- Owned test util: `test/utils/g2-s9-db.ts` → `39ba033b…` (refuses 55644, S8-G's lane; comment corrected: 55643 = S8-F);
  `test/scout/g2-s9-db-guard.spec.ts` → `a99cf9c9…` (matrix adds 55642/55643/55644). `gate/PINS.env` re-pinned.
- Binding v2 closed per items 1-6: runner `7ba9353b…`, fixture `1ee36964…` (EXPECT_FIXTURE_SHA filled), PINS.txt
  `11882143…`, README `c9210cbd…`, `BINDING.sha256` added. RUNTIME_ROOT literal = 1910a060 runtime in both files with a
  whole-line cross-check; real psql `d1108fdb…` pinned + `18.` asserted; `EXPECT_TESTS=10`; lock inode 667698 asserted;
  other-lane scan covers `clusters/*` and `proof-*/clusters/*`. Not run. Gate still waits for M2.
