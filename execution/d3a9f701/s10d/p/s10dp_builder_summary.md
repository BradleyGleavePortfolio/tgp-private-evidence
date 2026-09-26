# S10-D P builder summary: test-only prerequisite slice (T2)

- Worktree: `/home/user/workspace/worktrees/d3a9-s10dp`, branch `exec-d3a9/s10dp` at `711c1f8f`.
- Base layer: S10-C's frozen 11 paths, byte-identical to `worktrees/d3a9-s10c` (checked with `cmp`) and untouched.
- Nothing is committed, and nothing was run: no jest, tsc, eslint, prettier or npm, and no lock.
- **Every expectation below comes from reading the loader and registry code.**

## Owned paths edited (exactly 4)

| path | sha256 (after) | lines | base |
|---|---|---|---|
| test/scout/reconstruct/native/native-families.spec.ts | 16d801af0376135905040912a6af5d44709b31c3e7f53d1f355d7848c85eb166 | 345 | 711c1f8f |
| test/scout/induction/manifest-registry.spec.ts | 8c7de025454c77f284e0cf60776933c18de8dffb55ba09d8df0013fa23c02b3b | 308 | 711c1f8f |
| test/scout/reconstruct/mapping-spec.spec.ts | 3d8fea0074765b5f445191d88a53846047aa82f1cb0412eb909036f7e138dde2 | 418 | 711c1f8f |
| test/scout/reconciliation/facts.service.coverage.spec.ts | dd71968afa72c59771bbe9a2f7d1969ea13b730f6b39349935b3e83d58665680 | 682 | S10-C frozen `681c9031…2958` (651 lines) |

- Diff: `/home/user/workspace/private-evidence/execution/d3a9f701/s10d/p.diff` (325 lines).
  - The first three files are shown as `git diff` against 711c1f8f.
  - `facts.service.coverage.spec.ts` is shown as `diff -u` against the S10-C frozen bytes, because it is untracked in B until S10-C lands.
- Production LOC: 0. No file under `src/` was touched.

## Edits: each asserts an invariant over whatever ships, keeps a positive guard, and has a defect control

### 1. `native-families.spec.ts`

Replaces "ships no repository native rule set yet": `loadNativeRuleSets(dir)` toEqual `[]` and `buildNativeRuleRegistry().size` toBe 0.

- **Invariant:**
  - The default registry keys equal the loaded rule sets.
  - The `*.json` file names in the directory equal `<sourcePlatform>.json` for each set.
  - `nativeRuleViolations(sets, buildSourceMapperRegistry())` is `[]`: every rule set has a shipped spec and names only families of that spec.
- **Positive guard (kept):** `guessedProduction(registry)` is `[]`, meaning `truecoach` ships no native rules.
- **Defect control:**
  - An orphan rule set and a foreign-family rule set give exactly two named violations.
  - A registry containing a `truecoach` rule set gives `guessedProduction` = `['truecoach']`.
- The absent-dir and present-but-empty-throws cases are kept, now over temporary directories.

### 2. `manifest-registry.spec.ts`

Replaces "ships no real platform manifest": `loadInductionManifests(INDUCTION_MANIFESTS_DIR)` toEqual `[]`.

- **Invariant:**
  - `buildInductionRegistry({shipped manifests, shipped specs, shipped rule sets})` does not throw. This carries the V2/V3/V6 cross-checks.
  - The package keys equal the shipped manifest platforms.
  - Each package's `specDigest` equals `mappingSpecDigest` of its shipped spec.
- **Positive guard:** no `truecoach` package, since no real source key has been established (Q1/Q2).
- **Defect control:**
  - Adding a manifest with no spec (`p-orphan-manifest`) to the shipped set throws.
  - A `truecoach` manifest trips the guard.
- New imports: `loadNativeRuleSets` and `loadSourceMappingSpecs`.

### 3. `mapping-spec.spec.ts`

Replaces "keeps every shipped 1:1 spec valid with no declaration", which required `sharedIdSpaces` to be undefined for every spec.

- **Invariant:** for every shipped spec (and at least one ships), `sharedIdViolations(spec)` is `[]`. That means:
  - every family with two or more steps declares exactly those steps;
  - no 1:1 family carries a declaration.
- **Positive guard:** the `truecoach` spec exists, is 1:1, and has `sharedIdSpaces` undefined.
- **Defect control:**
  - An undeclared fan-in reports a violation.
  - A partial declaration combined with a declaration on a 1:1 family reports both violations.
  - The correct declaration reports `[]`.

### 4. `facts.service.coverage.spec.ts` (moved into P by sequential ownership; S10-C is frozen)

**Why it has to change.** This file's `MAPPERS` come from the S10-A pure fixture, whose slug is also `s10_unseen`. Its `service()` injected `nativeRules: []`. With D2's disk manifest (`nativeRules: 'declared'`) present, `defaultRegistry` would throw V6 at construction.

**The edits:**
- **`service('default')`** now passes the **shipped** rule sets (`loadNativeRuleSets()`), which keeps the disk manifest V6-consistent. Non-default registries still get `[]`.
- **The "default registry" test:**
  - Its premise `existsSync(INDUCTION_MANIFESTS_DIR) === false` is replaced by an invariant: no shipped manifest's verifier `public_key_b64` equals the fixture's source or observer key.
  - The coverage expectation stays all UNKNOWN.
- **New defect control:** the same proven run under a registry that *does* trust the fixture key yields `BASELINE`. So the UNKNOWN result depends on the premise and is not vacuous.
- **The foreign-rules test:**
  - It passes `[...loadNativeRuleSets(), foreignRules]` and still expects `specFamilies` to be `[SLUG]`.
  - `packages` must equal the shipped manifests filtered to `SLUG`, which is `[]` without D2 and `['s10_unseen']` with it.
  - No `elsewhere` package: the foreign rule set is still dropped, not thrown on.
- Removed the now-unused `existsSync` and `INDUCTION_MANIFESTS_DIR` imports. Added `loadNativeRuleSets` and `TEST_KEYS`.

## Both runs (expected; derived, not executed)

| spec | without D2's 8 files (B = S10-C landing + P) | with D2's 8 files |
|---|---|---|
| native-families | sets `[]`, registry `{}`, file check skipped, violations `[]`, no truecoach | sets `[s10_unseen]`; files `[s10_unseen.json]`; its spec has programs and workouts, so violations `[]`; no truecoach |
| manifest-registry | registry over `[]` manifests does not throw; packages `[]` | the `s10_unseen` manifest binds to the disk spec; V6 holds (`declared` with a disk rule set); the digest matches; no truecoach |
| mapping-spec | truecoach and the two conformance specs are all 1:1 with no declaration, so `[]` | `s10_unseen` workouts fan-in `[u10-routines, u10-sessions]` is declared exactly, clients is 1:1, programs has no step, so `[]` |
| facts coverage `'default'` | no manifests, so UNKNOWN; neither fixture key is shipped | the disk manifest binds the *fixture* spec's families (the same three); V6 holds with the disk rules; its only verifier `s10_unseen.source.d2` is not the fixture key, so UNKNOWN |
| facts coverage foreign-rules | packages `[]` | packages `['s10_unseen']`, no `elsewhere` |

- I confirmed with node that D2's source and observer public keys differ from the S10-A fixture keys.
- `buildNativeFamilies` has no throwing cross-check, so constructing the facts service over the fixture spec with D2's disk rules is safe.

**Commands (parent-run, once per state):**

```bash
npx jest -c jest.config.js --runTestsByPath \
  test/scout/reconstruct/native/native-families.spec.ts test/scout/induction/manifest-registry.spec.ts \
  test/scout/reconstruct/mapping-spec.spec.ts test/scout/reconciliation/facts.service.coverage.spec.ts
```

1. Run it at P's head, with no `s10_unseen.json` under `src/`.
2. Overlay D2's 8 files (or run at D2 re-based on P) and run the same command.
3. Add `test/scout/s10/s10-unseen.e2e.spec.ts` to the second run.

## Notes / not proven

- Nothing was run.
- Prettier was not run. The new code lines are at most 100 characters; test titles longer than 100 follow the file's existing style.
- The `guessedProduction` / `PRODUCTION_WITHOUT_*` lists name only `truecoach`. A future *production* source that gains an established shape and key would need to be deliberately removed from the list, which is the intended friction. A new synthetic source needs no edit.
- D2's worktree holds an **older** S10-C layer (for example, a 559-line `facts.service.coverage.spec.ts` against the frozen 651 lines). When the parent re-bases D2 onto S10-C plus P, D2's 8 paths are unaffected, because D2 does not own that file.
