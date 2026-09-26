# S10-D D2 builder summary: synthetic unseen source `s10_unseen` (T2/T4)

- Worktree: `/home/user/workspace/worktrees/d3a9-s10d2`, branch `exec-d3a9/s10d2` at `711c1f8f`, with S10-C's 10 in-flight paths as a read-only base layer. I did not edit that layer.
- Nothing is committed or pushed. I did not run tsc, jest, eslint, prettier or npm, and did not take the lock.
- **None of the new specs have been executed.**
- What I did run:
  - JSON parse of the six JSON files;
  - an ed25519 sign/verify check (the source key verifies against the manifest key; the observer key does not);
  - `rg` for the slug and the `u10_*` field keys in `src/**/*.ts` (0 hits for both);
  - the D1 gate plus its four negative controls in a scratch clone (see below).

## Paths written (exactly the D-S10-5 allowed set: 8 paths, all 100644 regular files)

| path | sha256 | lines |
|---|---|---|
| src/scout/reconstruct/sources/s10_unseen.json | cce631bd9ad29efa80f32881891034916cd7ad75c21a6b85e66a85435684eded | 23 |
| src/scout/reconstruct/native/sources/s10_unseen.json | 3da5ba57a6617b214ce64133e19902cfe45e4752b5cc96dc43e5421814f2ac80 | 18 |
| src/scout/induction/sources/s10_unseen.json | 14f7168bf77f156d9a7ba6f709d0422da322afff58c0b14e1787a786fea175f2 | 18 |
| test/fixtures/scout/s10_unseen/staged-rows.json | 64d20d72bb62ee95b4944053588715910e2773a61817e6d52f235e5631c2b646 | 38 |
| test/fixtures/scout/s10_unseen/statements.json | 101fb407b5901465690ab59da121e78fc2d2703ed8b74cfa11c1a9bcde7e330d | 13 |
| test/fixtures/scout/s10_unseen/signer-test-key.json | f7652e25fab3e32bd82f394de0fb0e32dbb02559e761c1ec87a54977ff8611cf | 15 |
| test/scout/s10/s10-unseen.e2e.spec.ts | 54ea91c28877a45ab88f1cb2df9a375566c28222d7cb39709a879eb9396f3450 | 367 |
| test/scout/s10/s10-unseen.pg.spec.ts | d37a65c86b64d4ad853653b0a96c9270a7b51ab9962e8607db21e4ce440ce514 | 361 |

- Full diff against scratch B: `/home/user/workspace/private-evidence/execution/d3a9f701/s10d/d2.diff` (901 lines).
- **Production LOC: 0 lines of TypeScript or JavaScript.** Production data is 59 JSON lines: 23 + 18 + 18 across the three `src/**/s10_unseen.json` files.
- Test data is 66 JSON lines, and there are 728 lines of test TypeScript.

## What the data declares

**Mapping spec**
- Families are `clients`, `programs` and `workouts`. `client_history` is left undeclared.
- Steps are `u10-members`→clients, `u10-routines`→workouts and `u10-sessions`→workouts, with `sharedIdSpaces.workouts = [u10-routines, u10-sessions]`.
- `programs` has **no** `steps` entry; it is staged by the canonical token `programs`.
- Field keys are `u10_*`, which appear quoted nowhere in `src/scout/reconstruct/*.ts` (the mapping-spec "field meaning is data" test).

**Native rule set**
- programs: `weeks` and `daysPerWeek` are integers.
- workouts: `type` is an enum `{lift→strength, run→cardio}` with default `strength`.
- There are no exercises, so there is no catalog dependency.

**Manifest**
- `expectedFamilies` = the three spec families. Each has `basisKinds: [source_signed_enumeration]`.
- One verifier, `s10_unseen.source.d2`, with a fresh test ed25519 key. `nativeRules: 'declared'`.

**Fixtures**
- The key file holds a source pair and an observer pair. The observer key is never a verifier.
- Staged-row sets: `base`, `client_linked`, `undeclared_family` (token `client_history`) and `canonical_token` (token `programs`).
- The statements file is a template. `challenge_b64`, `issued_at`, `id_set_digest` and `observed_unique` are filled at test time from the run's server challenge and the staged ids, using an independent reference digest.

## Tests

**`s10-unseen.e2e.spec.ts`** (no-DB tier; every case uses the repository-default loaders)
- The source is data-only: no slug in `src/**/*.ts`, and all three JSONs are loaded.
- Spec shape: families, two steps into workouts with `sharedIdSpaces`, and no programs step.
- S8 seam vs S9/S10 partition:
  - `programs` resolves as `unresolved_family:programs` at the S8 seam, while `resolveFamily` returns `programs`.
  - `client_history` is null in both.
- `planRun` plans clients and workouts, and leaves `programs` and `client_history` unmapped.
- Native dispatch: a coach template maps `native`, a client-linked row maps to `evidence`.
- The default induction package binds `mappingSpecDigest(loaded spec)` and only the source key.
- R39 composition half, through `evaluateCoverage` over `ReconciliationFactsService.defaultRegistry`:
  - (a) all three families known and covering, with counts 2/0/2;
  - (c) and (d) do not unprove coverage;
  - R27: the canonical-token programs row is counted;
  - (e) unproven programs → unknown;
  - (f) observer-signed only → all unknown;
  - (b) is V6-consistent only without the rule set.
- R41 load half: the spec without `sharedIdSpaces` throws in `parseSourceMappingSpec` and in `loadSourceMappingSpecs(dir)`.

**`s10-unseen.pg.spec.ts`** (T4, real PG17)
- It imports the S10-B lane (`g2-s10b-{db,pg-harness,harness}`) by import only; no harness fork and no new helper file.
- The guards come with that import: `G2_S10B_*` env, attested head and clean tree.
- The services run in the jest process as `service_role`, with the real ObservationController/Service, ScoutIngestService, ScoutService, ScoutLifecycleService, ScoutReconstructService and ReconciliationFactsService.
- All registries are the defaults except in case (b).
- Chain: start → declare (plus an identical replay that returns the same challenge) → ingest per token → observe (signed at test time over the declared challenge, with `issued_at` inside [accepted_start_at, received_at]) → complete (S8-G pass, S10-C evaluator, S9 verdict, terminal CAS and settled basis) → status.
- Cases:

| case | input | expected |
|---|---|---|
| R39 (a) | base | `complete` with `reason_code` null; empty `conditions`; `source_signed_enumeration` basis on every token; 2 Person, 2 WorkoutPlan, 0 evidence rows |
| R41 | a second intent over the same ids | native counts unchanged, `complete` |
| R39 (b) | native rule set withheld and manifest set to `absent` (injected through the S8-G/S9-B option seams) | `partial/unresolved_identities` |
| R39 (c) | client-linked row | `partial`, `conditions` include `unresolved_identities` |
| R39 (d) | undeclared `client_history` | `partial/unresolved_family` |
| R39 (e) | no programs statement | `partial/coverage_basis_unknown` |
| R39 (f) | observer-signed | `partial/coverage_basis_unknown`, every basis `none` / null |
| R27 live | canonical-token programs row | `partial`, coverage not the failing condition, 0 WorkoutProgram |

- Without `G2_S10B_DATABASE_URL` the whole file is `describe.skip` and loads nothing from the PG lane. It lives under `test/scout/**`, which the default jest config collects, so it must not hard-fail there.

## Exact test commands (parent-run)

```bash
cd <D2 candidate root at the attested head, clean>
# No-DB tier
npx jest -c jest.config.js --runTestsByPath test/scout/s10/s10-unseen.e2e.spec.ts
# The B-side specs D2 changes the premise of (see BLOCKERS)
npx jest -c jest.config.js --runTestsByPath \
  test/scout/reconstruct/native/native-families.spec.ts test/scout/induction/manifest-registry.spec.ts \
  test/scout/reconciliation/facts.service.coverage.spec.ts test/scout/reconstruct/mapping-spec.spec.ts \
  test/scout/reconstruct/source-mapper-registry.spec.ts test/scout/induction/s10c-wiring.spec.ts
# Real PG17 (S10-B disposable lane; same env as test/rls-g2-s10b.spec.ts)
export G2_S10B_DATABASE_URL='postgresql://s10b_super@127.0.0.1:<port>/g2_s10b_disposable?schema=public&connection_limit=2'
export G2_S10B_CONFIRM='g2_s10b_disposable:<port>' G2_S10B_PASSWORD=<fixture pw> G2_S10B_PSQL=<abs psql 17>
export G2_S10B_DATA_DIRECTORY=<cluster dir> G2_S10B_CANDIDATE_HEAD=$(git rev-parse HEAD)
bash test/utils/g2-s10b-bootstrap.sh            # prisma generate at the head + migrate deploy
npx jest -c jest.config.js --runInBand --runTestsByPath test/scout/s10/s10-unseen.pg.spec.ts
```

- Run the PG spec on its own, not concurrently with `rls-g2-s10b.spec.ts` (that spec runs down/up migration proofs).
- The PG spec wipes the chain's tables across the whole disposable DB, as the S9-C harness `resetData` does.

## Gate (R40): scratch proof and the check-8 recipe

**Scratch run**
- Clone: `/tmp/tmp.rXDxMskxpq/repo`.
- Scratch B = `970d259b00c7478b98c3dda3bccac9b9189eb798`, which is 711c1f8f plus the S10-C layer committed.
- D2 = branch `d2`.
- `bash scripts/s10-core-diff-gate.sh 970d259b…` passes checks [1]–[7] and exits 0.
- For the real B (the S10-C landing commit), the gate passes if D2 is re-based so that `git diff --name-only B HEAD` is exactly these 8 paths and S10-C adds none of them.

**Check 8: four negative controls, each on a scratch branch off the D2 commit, never landed**

| # | control | recipe | observed |
|---|---|---|---|
| a | planted slug literal in a core file | `git checkout -b n1 d2; echo '// s10_unseen' >> src/scout/scout.module.ts; git commit -qam n1; bash scripts/s10-core-diff-gate.sh <B>` | `FAIL [3]`, exit 1 |
| b | dirty modified core file | `git checkout -b n2 d2; echo '// dirty' >> src/scout/scout.module.ts; gate` | `FAIL [2]`, exit 1 |
| c | untracked `src/` file | `git checkout -b n3 d2; echo x > src/scout/untracked.ts; gate` | `FAIL [2]`, exit 1 |
| d | symlink at an allowed path (D1 fix-1) | `git checkout -b n4 d2; rm src/scout/induction/sources/s10_unseen.json; ln -s ../../reconstruct/sources/s10_unseen.json src/scout/induction/sources/s10_unseen.json; git add -A; git commit -qm n4; gate` | `FAIL [3] … mode 120000`, exit 1 |

- For control (a), the gate stops at [3] because the core file is now a changed path. The literal would also trip [5].

## BLOCKERS: B-side assertions D2's files break (CORE DIFF = 0 means D2 cannot fix them)

These must land in B, through S10-C or the parent, before the D2 suite is green. Each is a minimal, generic edit that names no real source.

1. **`test/scout/reconstruct/native/native-families.spec.ts` L236-237** ("ships no repository native rule set yet").
   - Current: `loadNativeRuleSets(NATIVE_RULES_DIR)` toEqual `[]`, and `buildNativeRuleRegistry().size` toBe 0.
   - Proposed: `expect(loadNativeRuleSets(NATIVE_RULES_DIR).map((s) => s.sourcePlatform)).not.toContain('truecoach')` (no production source has native rules guessed), plus `every(set => buildSourceMapperRegistry().has(set.sourcePlatform))`. Keep the empty-dir throw.
2. **`test/scout/induction/manifest-registry.spec.ts` L71-72.**
   - Current: `loadInductionManifests(INDUCTION_MANIFESTS_DIR)` toEqual `[]`.
   - Proposed: `.map(m => m.sourcePlatform)` `not.toContain('truecoach')` (no real platform manifest), plus every manifest having exactly one disk spec.
3. **`test/scout/reconciliation/facts.service.coverage.spec.ts` (S10-C in-flight). Two breaks:**
   - **L505-509:** `existsSync(INDUCTION_MANIFESTS_DIR)` toBe false.
   - **Worse, a constructor throw:** this file's `MAPPERS` come from the S10-A pure spec, whose slug is also `s10_unseen`, and it injects `nativeRules: buildNativeRuleRegistry([])`. `service('default')` and `defaultRegistry(MAPPERS, …[foreignRules])` (L537) would load D2's on-disk manifest (`nativeRules: 'declared'`) with no rule set, so `buildInductionRegistry` throws V6 ("contradicts the loaded native rule sets").
   - The slug collision between the S10-A pure fixture and the D-S10-5 synthetic source is inherent, because the doc names both `s10_unseen`.
   - Proposed fix: in those two tests only, build the mapper partition from a copy of the pure spec with `sourcePlatform` renamed (for example `s10_pure_only`), so that no disk manifest names it. Replace the `existsSync` premise with `expect(loadInductionManifests().map(m => m.sourcePlatform)).not.toContain(<renamed>)`, and keep the UNKNOWN / `packages.size === 0` expectations.
4. **`test/scout/reconstruct/mapping-spec.spec.ts` L164-170** ("keeps every shipped 1:1 spec valid with no declaration").
   - This fails because the doc mandates `sharedIdSpaces.workouts` for `s10_unseen`.
   - Proposed: `for (const spec of loadSourceMappingSpecs().filter((s) => s.sharedIdSpaces === undefined))`, plus an assertion that every declared space equals its fan-in, which the loader already enforces.
5. **Checked and unaffected:**
   - `mapping-spec.spec.ts` "field meaning is data": the `u10_*` keys are absent from `src/scout/reconstruct/*.ts`.
   - `source-mapper-registry.spec.ts`: it uses `arrayContaining` plus sort.
   - `s10c-wiring.spec.ts`: its slug check covers `src/**/*.ts` only.
   - `rls-g2-s10c.spec.ts`: platform `synthetic-src-a`.
   - `facts.service.spec.ts`: its own platforms.
   - `lifecycle` and `settle-hook` specs: stubbed facts.

## Not proven / open

- **Nothing was executed.** The live R39 expectations are derived by reading the code:
  - `planRun` leaves canonical tokens unmapped;
  - the native dispatch accepts token === family;
  - rows with no native rules take the evidence path (`evidence_only` → `unresolved_identities`);
  - the D-S9-2 condition order.
- The most likely spots for a first-run correction:
  - R39 (a) `complete`: this depends on the S9 C-REL/C-ID classification of coach-template WorkoutPlans with no program link, and on clients' Person verification in the server pass.
  - R41: whether a second run re-verifies as `complete`.
  - The R27-live reason code: I assert only `partial`.
- **Doc tension.** "Stages one declared family by canonical token without a `steps` entry" and R39(a) "all declared units → `complete`" cannot hold in the same run. The S8-G planner (`family-plan.ts` L94-101) ledgers such rows as `skipped unresolved_family:<token>`. So (a) stages no programs row (programs is proven as the empty set), and the canonical-token row gets its own truthful `partial` case (R27 live). Changing this would need a core edit, which is out of scope for D2.
- The PG spec runs the services in-process rather than in a separate OS process. The S10-B worker has no S8-G pass action and injects a synthetic induction registry, and D2 may not add a worker.
- Prettier was not run. A few test-title lines exceed 100 bytes only because of multi-byte arrows. SQL template lines at pg.spec L98-99 are 102-107 characters.
