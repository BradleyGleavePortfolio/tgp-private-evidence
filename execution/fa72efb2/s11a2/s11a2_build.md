# S11-A2 build — two-source induction proof J09–J11 (T4, proof only)

Parent session fa72efb2 · builder T4 · 2026-09-26 17:46 UTC
Authority: docs/decisions/2026-09-26-s11-journey.md D-S11-6, §3 J09–J11, D-S11-8 row S11-A2; Q-S11-4 (J09 local synthetic only); grant `s11a2/S11A2_BUILD_GRANT.md` incl. the mandatory D2 learning (s10d2/d2_diagnose_fix.md).

## 0. Result in one screen

| Item | Value |
|---|---|
| Clone | `/home/user/workspace/worktrees/fa72-s11a2`, branch `fa72/s11a2` (standalone clone of fa72-s11b; pushurl `no_push://disabled-fa72efb2`) |
| Base | `dda794d7e8bee0482a7ad373795fcc51dcf54bb5` (S11-B r2) |
| HEAD | `03e7a2344ef95b019c751983527bbc9f78200921` |
| Tree | `738b711610a570357136ad8e8eb1be176d406c51` |
| Parent | `dda794d7e8bee0482a7ad373795fcc51dcf54bb5` |
| Author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` / same |
| Subject | `test(scout): S11-A2 two-source induction proof J09-J11` |
| Commit path | ONE commit via installed lefthook hooks (banned-cast-tokens, eslint, prettier, tsc, prod-readiness-quick, commit-msg no-ai-tokens) — all green; never `--no-verify` |
| Push / PR | none (rule) |
| `git status` after commit | clean (0 lines) |
| `git diff --name-only dda794d7 HEAD -- src prisma` | 0 files — NO src/ change, NO schema change |
| Files | 12 (8 new, 4 modified), +1161 / −12 |
| No-DB jest of touched specs | guard 95 passed; induction spec 4 skipped (describe.skip without lane) |
| Live pg spec | NOT run (parent-only). Expected live count: **4 tests** in `journey-induction.pg.spec.ts` (J09, J10, J11(a), J11(b)) |

## 1. Design

### 1.1 Two sources, data only (D-S11-7(7))

* **first** = the S10-D D2 synthetic source `s10_unseen`: spec / rules / manifest are repository-resident (`src/scout/{reconstruct,reconstruct/native,induction}/sources/s10_unseen.json`, unchanged); rows, statement template and TEST-ONLY key come from `test/fixtures/scout/s10_unseen/` (unchanged). J09 uses its `base` set MINUS the roster rows = the native-clean shape D2 r2 (a) settled `complete` with (2 workouts `u10-w-1`, `u10-w-2`; clients declared and signed empty).
* **second** = the new S11-A2 synthetic source `s11_second`, EVERY artifact under `test/fixtures/scout/s11/s11_second/`: `mapping-spec.json` (`t11-blocks`→programs, `t11-routines`→workouts; NO clients family on purpose), `native-rules.json` (programs weeks/daysPerWeek, workouts type enum), `induction-manifest.json` (expectedFamilies `[programs, workouts]`, nativeRules `declared`, verifier = fixture key), `staged-rows.json` (set `native_clean`: 1 program `t11-b-1`, 1 workout `t11-r-1`, no `t11_owner` → coach-owned templates), `statements.json`, `signer-test-key.json` (fresh ed25519 pair generated once with node crypto; private half committed on purpose, TEST-ONLY).
* Why the second source has no roster family: `clients` stays provable through the first source alone, so **J10 discriminates**: the undeclared second platform leaves exactly the families IT emits (programs, workouts) unknown (`none`/`null`) while `clients` stays a KNOWN empty enumeration (`source_signed_enumeration`/0). With three families on both sources every cell would read null and the case could not tell "unknown because undeclared" from "unknown everywhere".
* Slugs are read from fixture data (`SOURCES.first.platform`, `SOURCES.second.platform`); neither the harness nor the spec types a slug (guard-enforced, §4).

### 1.2 Evidence signing (test/fixtures/scout/s11/s11-sources.ts, 269 LOC)

Byte-for-byte the D2 construction (test/scout/s10/s10-unseen.pg.spec.ts L62-78, L164-201): statement = sorted-key JSON of `{account_scope_id_digest, challenge_b64, date_window, family, id_set_digest, issued_at, observed_unique, snapshot_ref_digest, source_platform, statement_version, terminal}`; `id_set_digest` = the INDEPENDENT reference digest (sorted unique ids as `<len>:<id>` concat, sha256) so the live proof compares two implementations against `stagedFamilyDigests`; `mapping_spec_digest` = `mappingSpecDigest(parsed spec)` (what the evaluator binds, E3); ed25519 `sign(null, bytes, pkcs8)`. Exports: `SOURCES{first,second}`, `MAPPERS` (defaults + parsed second spec — the same partition the worker composes), `INDUCTION_INPUT` (raw second packages), `idsByFamily`, `declarationOf`, `batchOf`, `tokensOf`, `evidenceFor`, `evidenceSet`, `referenceIdDigest`, `sha256`.

Offline confirmation (light, in-process, saved as `s11a2/a2_offline_coverage_check.{js,out}`): `evaluateCoverage` over the composed registry with `stagedPlatformFacts(MAPPERS, rows)` and `evidenceSet` output gives
* J09 shape (both declared, both observed): `clients {known, source_signed_enumeration, 0, covers}`, `programs {known, 1, covers}`, `workouts {known, 3, covers}`;
* J10 shape (first declared only): `clients {known, 0}`, `programs {known:false}`, `workouts {known:false}`.

### 1.3 Worker (test/utils/g2-s11-worker.cjs, +68/−3)

* `input.induction = { specs?, rules?, manifests? }` (raw data-only packages). Composition (L294-317): `[...loadSourceMappingSpecs(), ...parsed]`, `[...loadNativeRuleSets(), ...parsed]`, `[...loadInductionManifests(), ...parsed]` (parsed by the same `parseSourceMappingSpec` / `parseNativeRuleSet` / `parseInductionManifest` the loaders use, origin `g2-s11-worker:induction.<key>[i]`); `buildSourceMapperRegistry`, `buildNativeRuleRegistry`, `buildFamilyRegistry` → `reconstruct.families`, `reconstruct.sourceMappers`; `buildInductionRegistry({manifests, specs, nativeRuleSets})` (S10-C cross-check, throws on any mismatch) → `factsOptions = {sourceMappers, nativeRules, registry}` and `observationOptions = {registry}`. Exclusive of the A1 `input.spec/rules` branch (`else if`, L318), which is unchanged.
* `const induction = new ObservationController(new ObservationService(prisma, lifecycle, observationOptions))` (L344-346): the S10-B route pair over the SAME instrumented client and the SAME lifecycle, so its `FOR NO KEY UPDATE` (`observation.service.ts` L330, via `tx.$queryRaw`) passes the worker's `before-lock` / `locked` barriers (worker L258, L264) unchanged.
* Actions (L426-439): `declare` → `postDeclaration({user:{id: coach}}, {intent_id, platforms: body.platforms ?? []})`; `observe` → `postObservation({user, rawBody: Buffer(JSON(envelope))}, envelope)` with `envelope = {intent_id, observations: body.observations ?? []}` (so the 32 KiB raw-body limit and envelope parse of the accepted route run too). Results: declare `{intent_id, challenge_b64, declared_at}`; observe `{intent_id, execution_epoch, stored, replayed}`; failures via the existing `failure{status,message,response,code}` shape.
* Header comment lists the A2 deltas; action list updated. Everything else byte-identical to A1.

### 1.4 Harness (test/utils/g2-s11-harness.ts, +126; g2-s11-pg-harness.ts, 1 line)

Appended after the A1 wrappers (L404-507): `DECLARATION/OBSERVATION/SETTLED_BASIS` table names (also joined to `resetData`, L287 — the tables cascade from `ScoutImport` anyway); re-exports of the fixture module; `INDUCTION = { induction: INDUCTION_INPUT }`; `onInduction(host, role, options)`; `induction.{start, declare, ingest, observe, complete, status, held}` (`held` = `worker({...INDUCTION, ...options})` for pause barriers, J13 shape); `issuedAfterStart(coach, intent)` (E4 clock ordering: `max(now, accepted_start_at)+5ms`, then wait past it — a clock ordering, never a sync); `utc`; readers `declarationRows`, `observationRows`, `settledBasisRows`. `REGISTRY` and all A1 wrappers untouched (J01–J08 unaffected). pg-harness: PG17_PROCESS log omits `induction` (as it omits `spec`/`rules`).

### 1.5 Guard spec (test/utils/g2-s11-db-guard.spec.ts, +78/−8)

`added` gains `addedA2 = ['declare','observe']`; new worker-shape strings (controller/service construction, `input.induction` branch, three `load*()` spreads, `buildInductionRegistry(...)`, both option assignments, the `else if` A1 branch); `s11Files` gains the induction spec (slug + lane-marker scan); `journeySpecs` (core + induction) for the one-harness and inert-without-lane checks; NEW `it` "the second induction source is data only under test/fixtures/scout/s11 (no src change)": exact fixture file list, slug read from data, `${slug}.json` absent from all three `src/scout/**/sources` dirs, spec/rules/manifest agree on slug, `manifest.expectedFamilies == sorted spec families`, `nativeRules 'declared'`, verifier == fixture signer key, harness imports the fixture module and exports `INDUCTION`, and neither harness nor induction spec contains the slug literal. BASE_HEAD `711c1f8f` and `EXPECTED_MIGRATIONS 173` unchanged (`git diff 711c1f8f HEAD -- prisma` = 0 lines).

## 2. Files, LOC, digests (HEAD 03e7a23)

| File | LOC | +/− | sha256 | blob |
|---|---|---|---|---|
| test/fixtures/scout/s11/s11-sources.ts | 269 | +269 | c56df889ffba4221bd4b55569e39e24fe98b3c79b464fffa1df959ea5d5b12ae | dc8efd6f8c4c4ca56bc982e395563f20c7398e50 |
| test/fixtures/scout/s11/s11_second/induction-manifest.json | 17 | +17 | e58de930ee19d83c743213b4a311768a01777ed57f65123ca93f12fe2ece76f4 | b7914099bc55dc411afc87f1dc94c69c13b169ef |
| test/fixtures/scout/s11/s11_second/mapping-spec.json | 18 | +18 | 58abf8beebde20a900aeec0b1e32a1a36cafe2c0d06f9e1f04c39872e8d20718 | d1e07b375c08acd38e5ef1400e70fe9822d04908 |
| test/fixtures/scout/s11/s11_second/native-rules.json | 18 | +18 | b9077e2189cd92fcebd295701572738c622db9f320ac486f7ed51d70325b001c | f48ebf820752c9c68e486fa2c1bf5f90d44229f2 |
| test/fixtures/scout/s11/s11_second/signer-test-key.json | 9 | +9 | 070a8b48f43dd9c91264929cc956e0449076474761fbf648f513e8a111f515eb | b2c9da9abbbc14c181372cbd2b1cb21c69f1f562 |
| test/fixtures/scout/s11/s11_second/staged-rows.json | 19 | +19 | 99f07a55887b70d70fa025a90e6624835980909d87260afd4839e78441d87f81 | c402ae73e20ab2683af2855db2706ae951152cfd |
| test/fixtures/scout/s11/s11_second/statements.json | 13 | +13 | a63082cd8a1f45480d85f8ad2106459e2967eb8eb7a15e2bc6c83242879edbee | 4013d7aa58fed026308a1e7dbff03486a3780bb0 |
| test/scout/s11/journey-induction.pg.spec.ts | 525 | +525 | 8223f00875d459a226b1120e57ba54197e37b1fc658575e264ae0522bce00922 | 1b9832bcbce7a51da6a58df60c312a5b0416f144 |
| test/utils/g2-s11-db-guard.spec.ts | 430 | +78/−8 | 120cbe806ce024fbec147fefbe3a20d84f54db63c0790c0960f3945b8aada134 | 3975aab13e40ebd43d38c1b772ae54718ceb9d41 |
| test/utils/g2-s11-harness.ts | 507 | +126 | 494a683a5876c8f168d680a2f627728ff943cb89e6c1630a1c8a3461d4b6b4b5 | 1b66137a3a59b3bf396660cbc5606f4de444831e |
| test/utils/g2-s11-pg-harness.ts | 269 | +1/−1 | e7dac8abb6f5a56046ea96974b94c6ba7f6016e331e11f0f2c621acca4c69dd6 | ad32b5693390228bba001184acc2145b898879ac |
| test/utils/g2-s11-worker.cjs | 477 | +68/−3 | 8966789265c0c209a8a23d9e6b0ec6d14bda7852d136ee53593c1f8b2336d488 | 562038a1127f82ec5eb285010f8d8eade4cb2c8e |

All 12 paths are grant-owned (`test/scout/s11/journey-induction.pg.spec.ts`, `test/fixtures/scout/s11/**`, sequential edit of `test/utils/g2-s11-*` + guard spec). Nothing else touched; `test/rls-g2-s11.spec.ts` unchanged.

## 3. The cases — assertions and why the code guarantees them

Spec: `test/scout/s11/journey-induction.pg.spec.ts` (module, `export {}`; `process.env.G2_S11_DATABASE_URL ? describe : describe.skip`; harness `require`d lazily in `beforeAll`; no `new PrismaClient|fork(|spawn(`; header states the native-clean rule and the D2 learning verbatim). Setup per case: `h.resetData()`, `h.intent(coach)` (paired fixture intent; pairing is J01's proof), `induction.start` on one host. `beforeAll` pins the fixture shape the proof relies on (distinct platforms; first families `[clients, programs, workouts]`; second `[programs, workouts]`; first's native-clean set has NO clients id).

### J09 (spec L157-307) — two platforms, `complete`
Steps: start P2 → declare BOTH on P1 (one scope each) → identical declaration replayed on P2 in reversed order → transfer first source (batches P2,P1 by token) and second source (P1,P2) → observe first source's 3 statements on P1, second's 2 on P2, replay second's on P1 → complete on P2 → status on P1 and P2.
Assertions and guarantees:
* declare: 32-byte challenge; 2 `ScoutRunDeclaration` rows = (platform, scope, same challenge) — `observation.service.ts` L172-175 one challenge per run, `insertDeclaration` one row per (platform, scope). Replay on P2 returns `toEqual(declared.result)` and issues NO `INSERT INTO "ScoutRunDeclaration"` — L148-159 exact-set replay returns the ORIGINAL challenge and `declared_at`, no write (order-insensitive: `held`/`wanted` sorted keys).
* transfer: each batch `{received: n, deduped: 0}`; `stagedGroups` equals exactly the (platform, token, count) partition of both native-clean sets (no clients token anywhere).
* observe: first `{execution_epoch:1, stored:3, replayed:0}`, second `{stored:2, replayed:0}`, replay of second on P1 `{stored:0, replayed:2}` — L256-304 digest-keyed unit replay (`replayed += 1` L284), epoch read under the run lock. `observationRows` = 5 units `(platform, family, 'source_signed_enumeration')`, all epoch 1.
* complete: `{acknowledged:true, intent_id}`, exactly 1 terminal UPDATE, `pushes 1`; run row `terminal_status 'complete'`, `reason_code null`, `phase 'reconciling'`, epoch 1, `completed_at` set; completion rows `[[coach, intent, 'success']]`.
* settled basis: exactly 1 `ScoutRunSettledBasis` row, `execution_epoch 1`, `report_version 1`, report `{basis:'settled', conditions: []}` (`lifecycle.service.ts` L572-573 ONE row per run with `basis:'settled'`), `required_families ['clients','programs','workouts']` (union of spec families of staged platforms, `coverage.ts`), coverage cells all `source_signed_enumeration` with `observed_unique` = expected distinct ids (clients **0**, programs 1, workouts 3) — `verify.ts` per-family sum across declared platforms, empty declared family = `EMPTY_IDENTITY_SET_DIGEST` count 0 (L318) — then `coverage.ts` L46-49 `known:true` only when `covers_staged_identities` and claim `success`; identity cells `staged_unique == native_present_verified == expected`, `unresolved/rejected/failed 0` (`reconcile.ts` L159 bucket (j) for `present_owned` typed provenance — programs via `persistProgram` → `LEDGER_TARGET_KIND.workout_program` (`native-writers.ts` L122), workouts via `persistWorkoutTemplate` → `workout_plan` (L251/353)); `observation_digests` set == the 5 stored `evidence_digest`s; native counts `{persons 0, plans 3, programs 1}`; `ScoutReconstructedEntity` rows 0; ledger rows = 4 (one per staged identity).
* status: P1 `{status:'complete', reason_code:null, claimed_status:'success'}`, P2 byte-identical JSON; the reads write nothing (run row and basis rows unchanged).
Why `complete` is reachable at all: no `clients` row is staged on either platform (D2 learning — a staged clients row lands in bucket (f) `unresolved` via the legacy Person handoff and holds `unresolved_identities`, `reconcile.ts` L140-146, L347); clients is DECLARED through the first manifest and signed as the empty enumeration, so C-COV is satisfied for it too.

### J10 (spec L316-409) — second platform staged but undeclared
Steps: start P1 → declare FIRST only on P2 → transfer both → observe first on P1 (stored 3) → attempt second's statements on P2 → complete on P1 → status both hosts.
Assertions and guarantees:
* declaration rows = `[first.platform]` only.
* second's upload: `result` undefined, `failure` = 409 `observation_not_declared` — `observation.service.ts` L273 (unit's (platform, scope) not declared); the whole envelope is refused, `observationRows` still the 3 first-source units (the loop throws before any insert of that envelope — inserts happen per unit after the check, all inside one tx).
* complete: ack, `pushes 1`; run `terminal_status 'partial'`, `reason_code 'coverage_basis_unknown'`; settled report `conditions` EXACTLY `['coverage_basis_unknown']` — `reconcile.ts` L352 (`coverageConditionHolds`) and NOT L347 (`unresolved_identities`), which the identity cells prove: every family `staged == native_present_verified`, `unresolved 0`, `ledger_without_staged 0` (C-ID never masks C-COV).
* coverage cells EXACTLY `[clients: source_signed_enumeration/0, programs: none/null, workouts: none/null]` — `verify.ts` L337-347: every family of an undeclared staged platform is marked failed (`registry.specFamilies.get(platform)` ∪ grouped families) → `{known:false}` (L353) → `coverage.ts` L36 `UNKNOWN` (`observed_unique: null`); the first source's signed part of workouts does NOT leak as a count (unknown, never zero). `clients` is emitted only by the declared platform → known 0.
* `observation_digests` == the 3 first-source digests; native counts `{0, 3, 1}` (the undeclared platform's rows still reconstruct natively — coverage and identity are independent).
* status: `{status:'partial', reason_code:'coverage_basis_unknown'}` identical on both hosts; every token of the second platform in `families[]` has `observed_unique` null (`lifecycle.service.ts` L973-984 `observedUniqueFor` — holder `observed_unique` null → null; the workouts holder also has 3 tokens → null regardless).

### J11 (spec L418-524) — declaration on P1 races the first batch on P2 (both orderings, deterministic)
Shared oracle `xorOutcome` (L418-433): ingest never fails (`{deduped:0}`); EXACTLY ONE of {declare succeeded ∧ 2 declaration rows} / {declare failed 409 `declaration_after_ingest` ∧ 0 declaration rows}; returns which.
* **J11(a)** (L437-475): P1 `declare` held at `locked` (`txTimeout 60000`) — the worker's barrier fires after the `FOR NO KEY UPDATE` `$queryRaw` returns (worker L264; statement `observation.service.ts` L330), lock held, 0 rows yet. P2 `ingest` of the second source's first token started; `pg.blocked(name)` OBSERVES its `wait_event_type='Lock'` in `pg_stat_activity` (pg-harness L208-219) — the §3.1 gate `UPDATE "ScoutImport" … SET last_observed_at` (`lifecycle.service.ts` L654) takes `FOR NO KEY UPDATE` on the same row and conflicts. Staged still 0. `resume()` → declare done `{intent_id}`, exactly 1 lock statement; ingest done `{received: 1, deduped: 0}`; oracle → `declared_then_ingested`; then an identical replay on P2 returns the same result and a different set is `declaration_conflict` (L153) — never `declaration_after_ingest` once declared (L148 `existing.length > 0` path precedes L171).
* **J11(b)** (L477-524): P2 `ingest` held at `gated` (gate UPDATE returned, row lock held, no staged row committed yet — `stagedTotal 0` asserted under the pause). P1 `declare` started; `pg.blocked(name)` observes ITS lock wait. `resume()` → ingest commits (1 gate, ≥1 `INSERT INTO "ScoutIngestEntity"`); declare acquires the lock, `findFirst` staged row sees the committed row (READ COMMITTED, new snapshot per statement) → 409 `declaration_after_ingest` (L171), NO declaration insert; oracle → `declaration_after_ingest`; staged = 1. Afterwards on the other host the same declaration is refused again (deterministic), declaration rows stay `[]`, and an observation upload (any challenge) is refused `declaration_missing` (L237) with 0 observation rows.
No sleep orders anything: the only waits are `ready` (barrier reached), `blocked` (lock wait observed), `done`.

## 4. Worker action contract (A2 additions)

```
input.induction?: { specs?: unknown[], rules?: unknown[], manifests?: unknown[] }   // raw JSON packages
  → registries = repository defaults + parsed injected; exclusive of input.spec/input.rules
action 'declare':  body { platforms: [{ source_platform, account_scope_id_digests: [hex64] }] }
  → ObservationController.postDeclaration({user:{id:coach}}, {intent_id: intent, platforms})
  → result { intent_id, challenge_b64, declared_at } | failure 404 / 409 run_not_started
     / 409 declaration_conflict / 409 declaration_after_ingest / 400
action 'observe':  body { observations: ObservationEvidenceV1[] }
  → ObservationController.postObservation({user, rawBody}, {intent_id: intent, observations})
  → result { intent_id, execution_epoch, stored, replayed } | failure 409 observation_after_claim
     / declaration_missing / observation_not_declared / observation_conflict / 400 / 413
pause 'before-lock' | 'locked' apply to declare/observe (same FOR NO KEY UPDATE template).
```

## 5. Commands and return codes (all in the clone; heavy ones under `flock -w 3600 /home/user/workspace/execution/test-validation.lock` (inode 686480) while `PROOF_SLOT_FREE` existed)

| # | Command | RC | Notes |
|---|---|---|---|
| 1 | node one-liner: generate ed25519 keypair → `signer-test-key.json`; write 5 fixture JSONs | 0 | light |
| 2 | `node -r ts-node/register/transpile-only -e '…buildInductionRegistry(defaults+second)…'` | 0 | light (2 s); packages `[s10_unseen, s11_second]`, `pkg.specDigest === mappingSpecDigest(spec)` |
| 3 | `node -r ts-node/register/transpile-only /tmp/a2_offline_check.js` (saved as `a2_offline_coverage_check.js/.out`) | 0 | light (1.8 s); J09/J10 coverage shapes as §1.2 |
| 4 | `prettier --check <6 files + 6 json>` (3.9.9, runtime tools prefix) | 1 → | induction spec needed formatting |
| 5 | `prettier --write test/scout/s11/journey-induction.pg.spec.ts`; `prettier --check <all 12>` | 0 | "All matched files use Prettier code style!" |
| 6 | PROOF_SLOT_FREE absent 17:19–17:42 UTC → heavy gates paused (two 4.5-min polls) | — | rule followed |
| 7 | `flock … npx eslint --no-warn-ignored --max-warnings 0 <6 files>` | 0 | 2 s |
| 8 | `flock … npx tsc --noEmit` (NODE_OPTIONS=--max-old-space-size=3072) | 0 | 49.7 s |
| 9 | `flock … env -u G2_S11_DATABASE_URL npx jest --runInBand --runTestsByPath test/utils/g2-s11-db-guard.spec.ts test/scout/s11/journey-induction.pg.spec.ts` | 0 | `Test Suites: 1 skipped, 1 passed`; `Tests: 4 skipped, 95 passed, 99 total`; 9.2 s |
| 10 | `git add <12 paths>`; banned-token grep of the message | 0 | "msg clean" |
| 11 | `flock … git commit -F /tmp/a2_msg.txt` with GIT_AUTHOR_*/GIT_COMMITTER_* = Bradley | 0 | hooks: prod-readiness-quick ✔, banned-cast-tokens ✔ ("no positive token change"), eslint ✔ 3.3 s, prettier ✔, tsc ✔ 51.2 s, commit-msg no-ai-tokens ✔ → `03e7a23` |
| 12 | `git status --short | wc -l` = 0; `git diff --name-only dda794d7 HEAD` = the 12 owned paths; `-- src prisma` = 0; `git diff 711c1f8f HEAD -- prisma | wc -l` = 0 | 0 | |

Not run (by rule): any PostgreSQL, the pg specs live, `rls-g2-s11*`, `npm install/ci`, `prisma generate`.

## 6. Expected live counts (parent's live run, S11 lane)

| Spec | Tests | Notes |
|---|---|---|
| test/scout/s11/journey-induction.pg.spec.ts | **4** (J09, J10, J11(a), J11(b)) | worker processes ≈ J09 15, J10 11, J11(a) 6, J11(b) 6; each a ts-node cold start (~3–6 s) → several minutes total; `jest.setTimeout(600000)` |
| test/utils/g2-s11-db-guard.spec.ts | 95 (no DB) | already green here |
| test/rls-g2-s11.spec.ts | unchanged | its `a.families` check uses `REGISTRY` (A1 path) — unaffected by `input.induction` |

Run alone and in band: `jest --runInBand test/scout/s11/journey-induction.pg.spec.ts` with the G2_S11_* lane env and `G2_S11_CANDIDATE_HEAD=03e7a2344ef95b019c751983527bbc9f78200921` (the worker attests the runtime root at that head, clean).

## 7. Risks and findings (A/B/C)

No A or B findings. C items:

* **C1 — live proof not executed here (by rule).** The pg spec's expectations are backed by the offline evaluator run (§1.2) and code reading (§3), not by a live settle. The one cell not exercised by any earlier live proof in this exact shape is a `programs` identity reaching bucket (j) alongside a second platform in one run; the code path (`persistProgram` → `workout_program`, `present_owned`) is the S9-C one and J02 (A1) already lands a program natively. If J09 turns `partial` live, the first thing to read is `identities(report)` — the spec prints exact cells.
* **C2 — BASE_HEAD `711c1f8f` / EXPECTED_MIGRATIONS 173 kept.** `git diff 711c1f8f HEAD -- prisma` is 0 lines; the guard's "later, well-formed migrations" rule tolerates the 176 directories present. D-S11-6's "moves descriptor" wording was not needed for A2; parent decides whether any pin moves at S11-D.
* **C3 — `blocked()` window.** 400 × 25 ms = 10 s to observe the lock wait; a ts-node cold start of the second worker is 3–6 s on this 2-CPU box. Under heavier contention on the parent's box the poll could expire before the worker reaches PG; the failure is loud (`expected observed PostgreSQL lock wait`), not a false pass. Held workers have the harness's 90 s kill timer; `txTimeout 60000` keeps the paused transaction alive.
* **C4 — E4 clock ordering.** `issuedAfterStart` uses the jest process clock vs the run's PG-written `accepted_start_at`; same host in the lane (as D2). A multi-host lane would need a PG-clock read instead.
* **C5 — committed TEST-ONLY private key.** `signer-test-key.json` holds the second source's private half (as the D2 fixture does); the manifest lives only in fixtures and is never loaded by `src/` loaders, so it can verify nothing in a real deployment.
* **C6 — `stagedGroups` count type.** The reader returns `n` as a JSON number; the spec wraps in `Number()` defensively.
* **Observation (not a finding):** eslint reports nothing for `g2-s11-worker.cjs` (no flat-config match for `.cjs`, `--no-warn-ignored`), identical to the hook's behaviour on A1.

## 8. Evidence files in this directory

* `s11a2_build.md` (this report)
* `a2_offline_coverage_check.js`, `a2_offline_coverage_check.out` — the in-process evaluator check (§1.2)
* `S11A2_BUILD_GRANT.md` (parent's)

Evidence repo not git-committed (parent commits). Clone left in place at HEAD `03e7a23`, clean, no push.

## Round 2 — r2 fix after proof v1 finding (2026-09-26 18:2x UTC)

Trigger: `s11a2/PROOF_V1_FINDING.md` (B, candidate harness defect). Round-1 `resetData` added
`DELETE FROM "ScoutRunObservation"; DELETE FROM "ScoutRunDeclaration"; DELETE FROM "ScoutRunSettledBasis";`.
Those three tables are insert-only: migration `20270124000000_scout_run_observation_expand` L10-16 (posture) and
L176-188 (`scout_run_observation_insert_only()` refuses TRUNCATE, UPDATE and any DELETE at `pg_trigger_depth() = 1`),
row triggers L226-237. Only the parent-run `ON DELETE CASCADE` may remove them; `test/utils/g2-s10b-harness.ts`
L170-176 deletes the run and relies on the cascade. The no-DB gates could not see the trigger (round-1 risk C1 was
the honest bound; this defect was outside what the offline check exercised).

### Change (ONE new commit, 03e7a234 not amended)

| Item | Value |
|---|---|
| HEAD r2 | `54be96f18c314cae35d1e5d3000af9f06d693d81` |
| Tree | `435fec782672214c7e8e81b2eb91f8f9266331b4` |
| Parent | `03e7a2344ef95b019c751983527bbc9f78200921` (r1) → base `dda794d7` |
| Author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` / same; hooks all green; no `--no-verify`; no push |
| Subject | `test(scout): S11-A2 r2 reset the S10-B tables only by cascade` |
| Files in r2 | 1: `test/utils/g2-s11-harness.ts` (+5 / −3) |
| `git status` | clean (0) |
| `git diff --name-only dda794d7 HEAD` | the same 12 A2 paths; `-- src prisma` = 0 |

`test/utils/g2-s11-harness.ts` @ r2: 509 LOC, sha256 `502c97c9f54e9ed6da7d16404559bddf87c6c45faf857046d14b20b5b1ce7be3`,
blob `927d73655c586a188556353a59fa1c5939cae09a`. Every other A2 blob is unchanged from §2 (r1 pins hold for the
other 11 paths).

Edits (all in that file):
1. `resetData` (L287-292): the three direct DELETEs removed. The function is now BYTE-IDENTICAL to A1's
   (`git diff dda794d7 HEAD -- test/utils/g2-s11-harness.ts` shows NO `-`/`+` line inside `resetData`, and no removed
   line anywhere in the file vs base: A2 is purely additive to the A1 harness again). Children-first order kept; the S10-B rows
   leave through `DELETE FROM "${RUN}"` (`ScoutImport`) → ON DELETE CASCADE (FKs migration L104-107, L141-146,
   L170-171).
2. Header (L16-17): "the S10-B table names join `resetData`" replaced by "`resetData` is UNCHANGED (the S10-B tables
   are insert-only and are cleared only by the run row's ON DELETE CASCADE — r2 fix, proof v1 finding)".
3. Constant comment (L43-45): the DECLARATION/OBSERVATION/SETTLED_BASIS names are "read only here", trigger and
   cascade path named.

Guard spec: NOT changed — it never asserted the resetData text or the header sentence (`rg "resetData|OBSERVATION\}|
DECLARATION\}|SETTLED_BASIS\}" test/utils/g2-s11-db-guard.spec.ts` → no matches).

### Re-check of the whole A2 diff for DML on the three S10-B tables

`git diff dda794d7 -- <A2 paths> | rg '^\+.*(DELETE|TRUNCATE|UPDATE\s+"|\$executeRaw|sql\()'` after the fix yields only:
* induction spec L56-57: the `isTerminal` READER predicate over the worker's query log `/UPDATE "ScoutImport"/.test(q) && /SET terminal_status = /.test(q)`
  (matches the lifecycle's own statement text on `ScoutImport`, not an S10-B table; issues nothing);
* the three r2 comment lines.
The A2 readers `declarationRows` / `observationRows` / `settledBasisRows` (harness L487-509) are `SELECT … jsonb_agg`
only. The induction spec issues no SQL of its own (only harness readers and worker actions); the fixtures are data.
The worker's `declare`/`observe` actions call the production `ObservationService`, whose writes to the three tables are
INSERT-only (`observation.service.ts` `insertDeclaration` / observation insert L256-304; the run-row `UPDATE` it does is
on `ScoutImport`). Result: no direct DELETE / UPDATE / TRUNCATE on ScoutRunDeclaration, ScoutRunObservation or
ScoutRunSettledBasis anywhere in the A2 delta.

### Commands (clone; heavy under `flock -w 3600 /home/user/workspace/execution/test-validation.lock`, PROOF_SLOT_FREE present)

| # | Command | RC |
|---|---|---|
| r2-1 | python edit of the 3 hunks in `test/utils/g2-s11-harness.ts` (asserted unique matches) | 0 |
| r2-2 | `rg` for DML on S10-B tables across guard spec / A2 diff (above) | 0 (only comments + reader regex) |
| r2-3 | `prettier --check test/utils/g2-s11-harness.ts` (3.9.9) | 0 |
| r2-4 | `flock … npx eslint --no-warn-ignored --max-warnings 0 test/utils/g2-s11-harness.ts` | 0 |
| r2-5 | `flock … env -u G2_S11_DATABASE_URL npx jest --runInBand --runTestsByPath test/utils/g2-s11-db-guard.spec.ts test/scout/s11/journey-induction.pg.spec.ts` | 0 — `Tests: 4 skipped, 95 passed, 99 total` (guard **95**, induction spec 4 skipped) |
| r2-6 | banned-token grep of the message → `msg_clean`; `git add test/utils/g2-s11-harness.ts` | 0 |
| r2-7 | `flock … git commit -F /tmp/a2_r2_msg.txt` (GIT_AUTHOR_*/GIT_COMMITTER_* = Bradley) — hooks: prod-readiness-quick ✔, banned-cast-tokens ✔ ("no positive token change"), eslint ✔ 3.1 s, prettier ✔, tsc ✔ 48.3 s, no-ai-tokens ✔ → `54be96f` | 0 |
| r2-8 | `git status --short` = 0 lines; `git diff --name-only dda794d7 HEAD` = 12 A2 paths, `-- src prisma` = 0; sha256/blob of the harness recorded | 0 |

Not run (by rule): PostgreSQL, pg specs live, rls-g2-s11 live. Expected live counts unchanged (§6): induction spec 4,
guard 95, rls/journey/readiness/settle-redrive as the binding pins. `G2_S11_CANDIDATE_HEAD` for binding v2 =
`54be96f18c314cae35d1e5d3000af9f06d693d81`; FREEZE pin for `test/utils/g2-s11-harness.ts` becomes blob `927d7365…`.

### Risks after r2
* C1 (live proof not executed here) stands; the resetData path is now the A1 path that S11-B's lane-v2 ran RC=0
  122/122, and the S10-B tables are cleared exactly as `g2-s10b-harness.ts` clears them.
* The r1 evidence (`03e7a234`) and the v1 run/binding are preserved unedited.
