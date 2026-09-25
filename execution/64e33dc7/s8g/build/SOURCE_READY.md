# S8-G SOURCE_READY (grant S8G-BUILD-1)

Builder: T4 `s8g_design_test_draft` (sole S8-G builder). SOURCE ONLY: no lock, gates, jest, tsc,
prettier, PG, or commit were run. Nothing under `prisma/**`, `docs/**`, `scripts/**`, `jest*.js`,
`src/scout/scout.module.ts`, `src/analytics/events.ts` or any pre-existing spec was touched.

## Worktree state

- Worktree: `/home/user/workspace/worktrees/64e33dc7-s8c`
- Branch: `exec-dace/s8g` at `2542af44ab5b4d296f84e9f5f311632f7f5aeb25` (S8-C `f428db9a` merged with S7-L `df713fd9`; `prisma` tree `86f1a7474772ef7ff973df539869243383103342`).
- `git status --porcelain`: 2 modified, 12 untracked (all listed below); no other changes.
- `node_modules` untouched (same install as the retired S8-C lane). See "Binding prerequisite" for the generated Prisma client caveat.

## Files (blob sha = `git hash-object`, working tree)

| Status | Path | Blob sha |
|---|---|---|
| M | `src/scout/scout-reconstruct.service.ts` | `6c0aff34d86f245895c3eec83b5f301871605862` (+260/-10 vs 2542af44) |
| M | `src/scout/lifecycle/lifecycle.service.ts` | `0b255e57b781ad9821cda6cb0e4f817d53add20d` (+25/-4 vs 2542af44) |
| A | `src/scout/reconstruct/orchestration/run-context.ts` | `95141d39620f367980a97a05aaa18af682f30297` |
| A | `src/scout/reconstruct/orchestration/family-plan.ts` | `a5455d5ec927f8a77ae52e83438c14018876c1c1` |
| A | `test/scout/orchestration/family-plan.spec.ts` | `88185083ab30ada66b077810869878fc5641ccb3` |
| A | `test/scout/orchestration/reconstruct-run.spec.ts` | `d058ef641fef62fd2afaaa5ecc14d0a583eeac3d` |
| A | `test/scout/orchestration/settle-hook.spec.ts` | `7d68debe6fc10a994b774a2af59aadd4f449b313` |
| A | `test/scout/g2-s8g-db-guard.spec.ts` | `a42fa65a4f6d10841c99bd155925cb1fe1603d96` |
| A | `test/rls-g2-s8g.spec.ts` | `3caa422720fbc1cc47581dd326269f5af010936c` |
| A | `test/utils/g2-s8g-db.ts` | `4a7d56872f2e95405afdc4f97e4f8b03fd8d88dd` |
| A | `test/utils/g2-s8g-pg-harness.ts` | `206202f929532f2105920258f4bef975dbc219a4` |
| A | `test/utils/g2-s8g-harness.ts` | `cae144d441643932d921b1c0312bbbf339a88d1f` |
| A | `test/utils/g2-s8g-worker.cjs` | `d554eefc623456082a77365596ca92147fb35be7` |
| A | `test/utils/g2-s8g-bootstrap.sh` (mode 755) | `5a9e09d877f6a53fbcc015c29403f6c96a88f29a` |

Not created (deliberate): `test/utils/g2-s8g-old-root.sh` (PATHS.md listed it as an S7-L rename; S8-G ships no migration, so there is no OLD/NEW side and no old-root fixture; the db-guard and bootstrap do not reference it). `test/scout/reconstruct/native/fixtures/s8c-rules.json` not created: rules are inline in `test/utils/g2-s8g-harness.ts` (`RULES`, re-keyed to platform `truecoach`). `jest.config.js` not modified: `test/rls-g2-s8g.spec.ts` is already excluded from the default suite by `'<rootDir>/test/rls-.*\\.spec\\.ts$'` (jest.config.js L125) and matched by `jest.rls.config.js` `'<rootDir>/test/rls-*.spec.ts'` (L19).

Product-code hunks follow PATHS.md exactly: reconstruct service (a) imports, (b) `reconstructRun` + `runFamilySource`/`runUnmappedSource`/`tallyPass`/`gateRun`, (c) `reconstructRow(+ctx)` gate-first + `RunPassStopped` rethrow, (d) `writeOutcome(+ctx)` gate-first, (e) `reconstruct()` passes `LEGACY_RUN`, (f) C4 ledger `entity_type = row.entity_type ?? family.entityType`; plus a `sourceMappers` field (constructor default `buildSourceMapperRegistry()`, overridable by the test worker). Lifecycle: `@Optional() reconstruct?` constructor param with `new ScoutReconstructService(prisma, analytics)` fallback; `onTransferSettled` runs the pass, classifies `gate_closed` via `classifyClosed`, then the S7-L tail verbatim.

## Deltas vs the draft (`s8g/draft/*.draft`, DESIGN.md, TESTS.md)

1. `family-plan.ts`: input `StagedGroup.staged` (number) instead of Prisma `_count`; `PlannedFamily` carries the `reconstructor`; `FamilyPassResult` adds `source_platform`; bound check uses the groupBy count (no findMany for an over-ceiling group).
2. New (not in draft): a noncanonical-platform *unmapped* group is tallied `stopped: 'provenance_conflict'` with no write (mirrors `reconstructRow`'s structural refusal; the ledger CHECK would reject the platform anyway).
3. C4 applied: ledger `entity_type` is the staged token (`row.entity_type ?? family.entityType`); legacy `reconstruct()` select does not include `entity_type`, so legacy rows keep the family token (byte-unchanged legacy behaviour).
4. `sourceMappers` is a service field (default registry) so the live worker can inject the fixture registry into both `families` and `sourceMappers`.
5. Unit specs: fixture mapping specs use the S8-A `paths`/`coerce` shape; `settle-hook.spec.ts` doubles log `tx:begin/lock/fence/terminal/tx:commit` order and bump `execution_epoch` on fence so the tail is a real CAS miss (draft used a static row).
6. Live harness: fixture platform is `truecoach` (repo `truecoach.json` spec + `programs` step) with S8-C rules re-keyed inline, instead of the draft's `conformance_s8g` platform + JSON fixture file. Worker: `after-row` counts committed gated transactions (claim tx is #1 for `complete`, so "after N rows" = `pauseRow N+1`); `gated`/`before-gate` count gates the same way (`pauseGate`); `before-lock` fires before the first `FOR NO KEY UPDATE`; side-effect spy is a `Module._load` hook over `src/{notifications,email,billing,nudges,messaging,timeline,regimes}/`; `pushes` and `sideEffectLoads` are reported. Deadline proofs use the fixture clock (`expire()`), not wall-clock sleeps.
7. rls spec vs draft P01–P14: same scenario set; P05/P13 use `expire()`; P13 interrupts with `worker.stop()` (SIGTERM while paused after-row) then polls status to prove the lazy `timed_out` fence; P07/P09 merged into one test; P11 uses the accepted S8-B/S7-L `SET ROLE <role>; …` owner-session pattern (`count=0` for reads, `row-level security` for the insert). `jest.setTimeout(600000)` (many process spawns per test).
8. db-guard and bootstrap assert the base **prefix**, not a count (landing finding L2-1): applied names == candidate tree directories, contain `S8B_MIGRATION` and `S7L_MIGRATION`, none sorts after `LAST_BASE_MIGRATION` (= S7-L `20270123000000_scout_run_lifecycle_expand`); `not.toMatch(/EXPECTED_MIGRATIONS/)` on both bootstrap and harness; bootstrap `LAST_BASE_MIGRATION="$S7L_MIGRATION"`.
9. Candidate Prisma client is verified structurally by the bootstrap (schema contains the S7-L lifecycle columns; prints `CANDIDATE_CLIENT_SCHEMA` sha) rather than by a pinned sha (draft pinned one).
10. Lane constants: db `g2_s8g_disposable`, role `s8g_super`, cluster `s8g-disposable-pg17`, marker `s8g-g2-run-orchestration-synthetic-disposable-fixture-safe-to-drop`, refused ports add `55642` (S8-C lane); db-guard example/ack port `55643`, mismatch probe `55644`.
11. `BASE_HEAD` pinned `2542af44ab5b4d296f84e9f5f311632f7f5aeb25` in `g2-s8g-db.ts`, pg-harness, bootstrap and db-guard.

## Gate list (to be run by the parent; none run here)

Formatting/lint/types (scoped):
- `npx prettier --check` on the 14 files above (repo config: singleQuote, trailingComma all, printWidth 100). Risk: long template literals in `test/rls-g2-s8g.spec.ts` and harness SQL strings may need `--write`.
- `npx eslint` on the 13 TS/CJS files.
- `npx tsc --noEmit -p tsconfig.json` (the rls spec uses `any` on worker results; harness helpers are typed).

Jest (default config) — affected by import closure of the two modified product files:
- `test/scout/orchestration/family-plan.spec.ts`, `reconstruct-run.spec.ts`, `settle-hook.spec.ts` (new)
- `test/scout/reconstruct/scout-reconstruct.service.spec.ts`, `scout-reconstruct.families.spec.ts`, `scout-reconstruct.controller.spec.ts`, `native/engine-handoff.spec.ts`, `conformance-alpha.e2e.spec.ts`, `mapping-spec.third-source.spec.ts`
- `test/scout/lifecycle/lifecycle.service.spec.ts`, `test/scout/lifecycle/run.controller.spec.ts` (constructor now has an optional 3rd param; existing `new ScoutLifecycleService(prisma, analytics)` call sites still compile and use the fallback)
- `src/scout/scout.service.spec.ts`, `src/scout/scout.controller.spec.ts`, `test/scout/scout-ingest.service.spec.ts`, `scout-ingest.controller.spec.ts`, `scout-ingest.validation.integration.spec.ts` (transitively import lifecycle.service)
- `test/scheduling.service.spec.ts`, `test/availability-overrides.spec.ts`, `test/qa-p0-launch-blockers.spec.ts` (import `scheduling.service.ts`, which imports lifecycle.service)
- `test/scout/g2-s8g-db-guard.spec.ts` (new; reads prisma/migrations, bootstrap, harness, db.ts, and `git merge-base` against `2542af44`)

Specs reading `prisma/migrations`, `docs/contracts`, or base-head pins (run regardless of closure):
- All `test/scout/g2-*-db-guard.spec.ts`. **Known red at the composed head**: `test/scout/g2-s8c-db-guard.spec.ts` L135–156 pins `EXPECTED_MIGRATIONS = 171` and asserts no migration name `> S8B_MIGRATION`; the tree has 172 directories including S7-L's `20270123000000_…`, so it fails until the parent's pending test-only guard-spec commit lands (not S8-G's to fix; outside PATHS.md). `g2-s7l-db-guard.spec.ts` pins no count.
- `test/contracts/importer-contract.spec.ts`, `test/ci/delivery-artifact.spec.ts`, `test/invariants/locked_defaults.spec.ts`, `test/migration-backfill-parity-r2.spec.ts`, `test/wearables/metric-bucket.map.spec.ts` (reference `prisma/migrations`/contracts; S8-G changed none of those inputs — expected green, listed for completeness).

Live proof (jest.rls.config.js): `npx jest -c jest.rls.config.js test/rls-g2-s8g.spec.ts` on the bound lane. Other `test/rls-g2-*.spec.ts` are lane-guarded and skip/refuse without their env.

## Expected PG binding shape (parent runtime setup)

- Bootstrap: `test/utils/g2-s8g-bootstrap.sh bootstrap` (or `verify-only`), PG17, one run under `timeout -k 30 3900`.
- Cluster: `cluster_name = s8g-disposable-pg17`; db `g2_s8g_disposable`; owner/runtime role `s8g_super`; port chosen by the parent (`55643` suggested; `55642` and all earlier lanes' ports are refused by `g2-s8g-db.ts`).
- Env consumed by the harness/worker: `G2_S8G_DATABASE_URL=postgresql://s8g_super@127.0.0.1:<port>/g2_s8g_disposable?schema=public&connection_limit=2`, `G2_S8G_CONFIRM=g2_s8g_disposable:<port>`, `G2_S8G_PASSWORD`, `G2_S8G_PSQL`, `G2_S8G_DATA_DIRECTORY`, `G2_S8G_CANDIDATE_HEAD` (40-hex, must be a descendant of `BASE_HEAD` and equal `git rev-parse HEAD` of a clean worktree), optional `G2_S8G_SERVER_VERSION` (default `170006`).
- Bootstrap checks: applied migrations == tree directories, S8B and S7L applied, none newer than `LAST_BASE_MIGRATION`, S7-L's 10 lifecycle columns present, newest directory is S7-L's; exit 7 if the generated client is stale.
- **Binding prerequisite**: the worktree's generated Prisma client (`node_modules/.prisma/client/schema.prisma`, sha256 prefix `ded50406332707e4`) is the S8-B client — 0 occurrences of `execution_epoch`. S7-L lifecycle code cannot run against it. `npx prisma generate` from the composed `prisma/schema.prisma` must be run by the parent's runtime setup before the proof (the bootstrap verifies structurally and exits 7 otherwise). This is a runtime-setup step, not a source change.
- `BASE_HEAD` remains valid if the parent rebases `exec-dace/s8g` onto the post-guard-spec commit: that commit is test-only, the `prisma` tree stays `86f1a747…`, and `2542af44` remains an ancestor (the db-guard checks ancestry, not equality).

## Known risks for the parent's gate run

- Prettier may reflow a few long lines in the new specs/harness (cosmetic).
- `test/rls-g2-s8g.spec.ts` P01 relies on Prisma logging `INSERT INTO "public"."Person"` for the Person upsert (native `ON CONFLICT` upsert on PG); if the client emits SELECT+UPDATE for an existing row it still inserts on first sight, so the ordering assertion holds.
- P04 relies on PostgreSQL FIFO lock granting (cancel fence waits before row c2's gate); ledger `['c1']` is the expected deterministic outcome.
- Existing S8-C guard spec red at the composed head (documented above) is pre-existing, not introduced by S8-G.

END: SOURCE_READY.
