# S8-G run orchestration — NEW candidate SOURCE_READY (execution 1910a060, builder G-NEW-1)

Status: **SOURCE READY — uncommitted working tree, no gate run, no install, no lock.** Awaiting parent gate relay on canonical lock `/home/user/workspace/execution/test-validation.lock` (inode 667698, untouched).

## Identity

| Field | Value |
|---|---|
| Clone | `/home/user/workspace/worktrees/1910a060-s8g` (standalone clone; object source `/home/user/workspace/growth-project-backend` read-only, no shared hook dir, untouched) |
| Branch / base | `exec1910/s8g` at `1c5fbb0441178e0cfe6e9f8d72e955c645c265e9` (accepted landed integration; S7-L + S8-C present) |
| `git status --porcelain` | 2 modified, 12 untracked (14 files, listed below); `prisma/**` unchanged; no other path touched |
| `git diff --numstat` | `lifecycle.service.ts` +24/−4; `scout-reconstruct.service.ts` +275/−10 |
| Full patch | `build/s8g-candidate-1c5fbb04.patch` (3729 lines, sha256 `0fe0d149a22e0f5c569a3913747ded3c2aa265d051f68afc47e058a5cbcf000b`), 14 `diff --git` sections |
| Provenance | Built fresh from the 64e33dc7 **drafts as design input only** (`draft/DESIGN.md`, `PATHS.md`, `TESTS.md`, `*.draft` files). The old 64e33dc7 `build/SOURCE_READY.md` is an unrecovered, unaccepted draft: **no byte of the old candidate was recovered or is claimed here.** All hashes below are of new bytes written in this execution. |
| node_modules | absent in the clone (no install performed; `-r ts-node/register/transpile-only` in the worker assumes the gate step installs as for S8-C) |

## Files and blob hashes (`git hash-object`, bytes)

| Blob (sha1) | Bytes | Path | Kind |
|---|---|---|---|
| `fb72850284e33249b4b682bbf3f1d28a914357b6` | 25948 | `src/scout/scout-reconstruct.service.ts` | modified (base blob `711bfb09f7bc831d76daff4ce2f69f7ee39daf94`) |
| `1a6db74e41370d3dc34f7bc74996c2e097a0e9e5` | 27188 | `src/scout/lifecycle/lifecycle.service.ts` | modified (base blob `5949a29357f46d545456e178a70069d26c4cc5ad`) |
| `b07ebb853344d59b3b2dd6ac4dcf8d0d1f9182fe` | 3044 | `src/scout/reconstruct/orchestration/run-context.ts` | new |
| `0a75e656d2b1f9d0b411599c6cbd15c684815df4` | 4452 | `src/scout/reconstruct/orchestration/family-plan.ts` | new |
| `46a36eacebbe2056ec331d78b67e48ea64cd8f93` | 5860 | `test/scout/orchestration/family-plan.spec.ts` | new |
| `cefb394f433a89b6ab6fa76450f440bcdd602616` | 19404 | `test/scout/orchestration/reconstruct-run.spec.ts` | new |
| `5533f3cfdd986a602f9fa6355bc17d3425178033` | 12415 | `test/scout/orchestration/settle-hook.spec.ts` | new |
| `f702cc1bf526431e2652bd2ac3e083e6f1a39e52` | 11120 | `test/scout/g2-s8g-db-guard.spec.ts` | new |
| `532356758762fe5205b90e127733802c1bff7556` | 36833 | `test/rls-g2-s8g.spec.ts` | new (guarded; excluded from default suite by existing `test/rls-*.spec.ts` ignore; picked up by `jest.rls.config.js` testMatch — no config change needed) |
| `2fdbedd2398e1083bfc41e83871d6feaf7596429` | 7126 | `test/utils/g2-s8g-db.ts` | new |
| `ffd7c476582ba56aee5ccb273066c0ab7cbb0596` | 10776 | `test/utils/g2-s8g-pg-harness.ts` | new |
| `ee2a41a2c118d4576878b65bf9b65cf220d0cf27` | 14454 | `test/utils/g2-s8g-harness.ts` | new |
| `65ee972d3bb44eca84a6007d81b4675452e2d94c` | 11784 | `test/utils/g2-s8g-worker.cjs` | new (`node --check` OK) |
| `02e9986fc2092ad8b4befaa15a98a6e17fc8ed44` | 19296 | `test/utils/g2-s8g-bootstrap.sh` | new, mode 755 (`bash -n` OK) |

Not created (deliberate): `test/utils/g2-s8g-old-root.sh` — S8-G ships no migration, so there is no OLD schema side; the S8-C accepted precedent (no old-root) is followed. `jest.config.js`, `scout.module.ts`, `events.ts`: unchanged (both services already providers L50/L53; existing event keys reused).

## Product delta (what the source does)

**`run-context.ts`** — `GateFn = (tx) => Promise<number|null>`; `ServerRunContext {mode:'server', epoch, gate}`; `LegacyRunContext`/`LEGACY_RUN`; `RunPassStopped` (Error, thrown inside a per-row tx when the gate sees zero rows or another epoch → tx rolls back); `FamilyStop = 'gate_closed'|'over_ceiling'|'provenance_conflict'`; `FamilyPassResult {token, source_platform, family|null, staged, reconstructed, skipped, failed, stopped}`; `RunPassResult {families, unmapped_families, stopped:'gate_closed'|null}`.

**`family-plan.ts`** — `RUN_FAMILY_ORDER = [clients, programs, workouts, client_history]` (contract §3.8, not registry order); pure `planRun(stagedGroups, mappers, registry)` resolving each `(source_platform, entity_type)` group through the accepted `resolveStagedFamily`; unresolved → `unmapped` with S8-A's exact reason (`unsupported_platform:<p>` / `unresolved_family:<token>`); resolved-but-unregistered family → `unresolved_family:<token>`; sources sorted (platform, token).

**`scout-reconstruct.service.ts`** (hunks per PATHS row): (a) imports; field `sourceMappers = buildSourceMapperRegistry()`; (b) public `reconstructRun(coachId, intentId, ctx: ServerRunContext)`: `groupBy(['source_platform','entity_type'])` → `planRun` → per planned source `runFamilySource` (bound check → `over_ceiling` stop for that source only; paged `findMany` selecting `entity_type`; `ProvenanceConflict` → `provenance_conflict` stop for that source; `RunPassStopped` rethrown; tally read back from ledger by token+platform; `SCOUT_RECONSTRUCT_COMPLETED` per token) → per unmapped group `runUnmappedSource` (non-canonical platform → `provenance_conflict`, nothing written; else per-row gate-first `writeOutcome(skipped, reason)`); a `RunPassStopped` anywhere → `stopped:'gate_closed'`, pass ends; PII-free summary log. (c) `reconstructRow(..., ctx)`: `gateRun(tx, ctx)` is the FIRST statement of the success transaction; `RunPassStopped` rethrown, never converted to a `failed` ledger row; ledger `entity_type = row.entity_type ?? family.entityType` (token forwarding, C4). (d) `writeOutcome(..., ctx)`: gate-first then `writeLedger` in one tx. (e) `reconstruct()` passes `LEGACY_RUN`; its statement sequence is unchanged (no gate). `assertSettled`, `assertWithinBound`, `writeLedger`, `tally`, `retryContention`, `summarizeError` untouched.

**`lifecycle.service.ts`** (three hunks): import `Optional` + `ScoutReconstructService`; ctor `@Optional() reconstruct?` with `reconstruct ?? new ScoutReconstructService(prisma, analytics)`; `onTransferSettled` body = `reconstructRun(coachId, intentId, {mode:'server', epoch, gate: (tx) => this.assertRunOpen(tx, coachId, intentId)})` → `if (pass.stopped === 'gate_closed') await this.classifyClosed(coachId, intentId)` → S7-L tail verbatim (lock, CAS on epoch, collectFacts, arbitrate, single terminal write). No S9 wiring; `reconciliation: null` stays → arbiter step 4 `partial/reconciliation_not_performed`.

## Tests written (not run)

Unit (default suite): `family-plan.spec.ts` (8), `reconstruct-run.spec.ts` (gate-first for success/skip/fail/unmapped; per-row epoch CAS; analytics per token; legacy no-gate sequence + result shape; closed gate stops with no fabricated failed; §3.8 order; over-ceiling isolation; noncanonical platform → structural conflict; in-family provenance conflict via a hand-built rogue mapper; no terminal fields; tenancy), `settle-hook.spec.ts` (order pass→lock→terminal; gate closure bound to run; verdict from facts not pass result; G14 CAS miss; terminal-already-set miss; gate_closed → classifyClosed once → fence timed_out prefix; fenced-elsewhere no writes; G06 verdicts; pass failure propagates with no writes; fallback constructs the real engine), `g2-s8g-db-guard.spec.ts` (target/confirmation/password guard with s8g identity, refuses 55641/55642 + s8c variants; markers; BASE_HEAD/172/S7L pins across bootstrap+harness+repo; candidate-head binding; worker attests before client and injects both seams; G12 static import scan; hook seam literals).

Guarded live proof `test/rls-g2-s8g.spec.ts` (P01–P14 minus an OLD-image step; separate OS processes via `g2-s8g-worker.cjs`, barriers `before-gate|gated|before-ledger|after-row(pauseRow)|before-lock|locked`): lane identity; P01 full `/complete` with §3.8 order and token forwarding; P02 gate-first per row / legacy no gate + replay identity; P03 cancel between rows; P04 cancel racing a gated row (lock wait observed); P05 deadline mid-pass (gate→rollback→new tx lock, one terminal); P06 claim vs truth; P07 duplicate/late/absent `/complete`; P09 409 during, idempotent after; P10 unmapped `notes` + over-ceiling isolation (RECONSTRUCT_MAX_ROWS+1 rows inserted as owner); P11 tenancy + RLS SET ROLE denials + service_role rollback; P12 zero side effects (pushes==1 for `/complete`, 0 for replay pass; lazy side-effect loads 0); P13 SIGTERM-interrupted pass → deadline poll fences → replay run converges without duplicates; P14 CAS miss on the settle tail.

## Gates to run (parent relay only, on lock inode 667698) — proposed order

1. `npm ci` (or the S8-C-accepted install step) in the clone; `npx prisma generate`.
2. `npx jest test/scout/orchestration test/scout/g2-s8g-db-guard.spec.ts`
3. Full default unit suite `npx jest` (byte-identity of existing specs: `git diff --stat 1c5fbb04 -- src/scout/scout.service.spec.ts test/scout/reconstruct test/scout/lifecycle test/rls-g2-s7l.spec.ts test/rls-g2-s8c.spec.ts` must be empty — it is).
4. `npx tsc --noEmit -p tsconfig.json`; `npx prettier --check` on the 14 files; `npx eslint` on the 14 files.
5. Commit on `exec1910/s8g` (only then is a candidate head attested); then the guarded lane: bootstrap `test/utils/g2-s8g-bootstrap.sh` (operator-chosen port, suggested 55643, `G2_S8G_CONFIRM=g2_s8g_disposable:<port>`, `G2_S8G_CANDIDATE_HEAD=<commit>`), then `npx jest -c jest.rls.config.js test/rls-g2-s8g.spec.ts`. PG-proof binding template: `binding/v1/{s8g-pg-proof.sh.unfilled,s8g-fixture.sh,PINS.txt.unfilled,README.md}` (derived from accepted S8-C v3; nine head pins unfilled; not executed).

Expected first-run risk areas (unverified until gates run): TS strictness in the test doubles (`as any` seams, tuple `as const` in P01), prettier line-length in `rls-g2-s8g.spec.ts` (long lines written intentionally compact; `prettier --write` on the 14 files is acceptable formatting, not a design change), Prisma `query` event text shapes assumed by the log helpers (`SET terminal_status = `, `SET fenced_at = `, `INSERT INTO "public"."WorkoutPlan" `).

## Narrow findings (see `build/FINDINGS.md`)

F1 fixture platform must be canonical (`s8g-proof`); F2 in-family `provenance_conflict` reachable only through a non-canonical platform row (planner routes those to unmapped → structural stop; unit test uses a hand-built mapper for the in-family path); F3 `clients`/`client_history` families resolve mappers through the ACCEPTED registry (fixture-platform rows of those tokens ledger `unsupported_platform:s8g-proof`) — accepted S8-A/S8-C behaviour, outside S8-G PATHS; F4 S7-L `collectFacts.unmapped_families` tests staged tokens against family names (not the spec) — informational only today (arbiter ignores it), S9C should source it from `planRun`; F5 worker side-effect spy counts lazy loads only (startup import graph includes notifications via ScoutService); F6 no OLD side / old-root script.
