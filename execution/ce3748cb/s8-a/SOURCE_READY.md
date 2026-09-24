# S8-A SOURCE_READY — data-only mapping interpreter

Builder: S8-A (T3), sole writer. Worktree `/home/user/workspace/worktrees/s8-a`, branch `s8-a`, base N/Q1 v1 `61b93cff7900b24c17011d481fd6c31f5abb59e4`. Draft head only. Nothing was pushed, and PG was not run.

## Heads
| # | Commit | Subject | Diffstat |
|---|---|---|---|
| 1 | `138cc9c1868b86294b618c860beb3c1385f48460` | feat(importer): interpret source mappings from data instead of per-source mappers | 14 files, +1531 / −302 |
| 2 | `68be527aa3d97daec6b16e8a1f8f2d7ef1fc2307` (HEAD) | test(importer): add a third synthetic source as mapping data only | 2 files, +406 / −0 |

- Commit 1 is an amend of my own unpushed `b5804bbf`. The amend folds in parent requirement A3 (below).
- Both commits: Bradley Gleave <bradley@bradleytgpcoaching.com> as author and committer, no trailers.
- Genuine lefthook hooks ran and passed on both commits: banned-cast-tokens (R75 staged), tsc, eslint, prettier, prod-readiness-quick, commit-msg no-ai-tokens. Hook logs: `commit1-amend-hooks.log`, `commit2-hooks.log`.

**Commit 2 diffstat** (CORE DIFF = 0 for mapping). `git diff --name-only HEAD~1 HEAD -- 'src/**/*.ts'` returns 0 files.
```
src/scout/reconstruct/sources/conformance_beta.json        |  40 +++
test/scout/reconstruct/mapping-spec.third-source.spec.ts   | 366 +++
```

**Commit 1 files.** Every file is inside the brief §3 S8-A owned paths. None of the three C-owned fake specs is touched.
- Deleted: `src/scout/mappers/{conformance-alpha,truecoach-clients,truecoach-entity}.mapper.ts`.
- Modified: `src/scout/reconstruct/families.ts`. Only the map side changed: the imports and `mapper.mapEntity(entityType, row)`. **The persist hunks are byte-unchanged.**
- Rewritten: `source-mapper-registry.ts`.
- New: `mapping-spec.ts`, `sources/{truecoach,conformance_alpha}.json`.
- Tests: `test/scout/reconstruct/{truecoach-clients.mapper,truecoach-entity.mapper,conformance-alpha.mapper,source-mapper-registry}.spec.ts` are retargeted with their assertions unchanged. New: `mapping-spec.spec.ts`, `mapping-spec.equivalence.spec.ts`.

## Design (D-S8-1)
- **`SourceMappingSpec` JSON:**
  - `specVersion: 1` and `sourcePlatform`, which must be a canonical token (`isCanonicalPlatform`).
  - `steps`: a map from each source step token to a canonical family.
  - `families`: per-family field rules. The person family has `displayName`; entity families have `clientSourceId` and `label`.
  - Each rule is `{paths: string[][], coerce: string|string_or_finite_number}`. Paths are tried in order, and the first value that is not null or absent wins (the retired `??` semantics). Keys are own properties only.
  - Optional `sharedIdSpaces` (see A3).
- **Validation is strict and fails closed at load time.** It rejects:
  - unknown or missing keys, including any extra field such as `email`;
  - non-canonical families (e.g. `billing`);
  - a step that targets a family with no mapping;
  - bad paths or bad coercion names.
- **The loader** (`loadSourceMappingSpecs`) reads `sources/*.json` in byte-sorted filename order. It throws on a missing or empty directory, a malformed spec, or a duplicate `sourcePlatform`.
- **Identity and skip reasons are core code**, byte-identical to the retired mappers: `unsupported_platform:<token>`, then `missing_source_id`. `source_id` is trimmed exactly once, in `guardIdentity`.
- **Unresolved families.** `resolveStep` and `resolveStagedFamily` return an explicit `unresolved_family:<token>` for any unmapped step. Examples: TrueCoach `notes`, conformance_alpha `coaches`, conformance_beta `messages`. A family missing from a spec also returns `unresolved_family:<family>`.
- **A3 (parent S8-0 review).** If two or more steps map to one canonical family, the spec is rejected unless `sharedIdSpaces[family]` lists exactly that set of steps. Stale, partial or malformed declarations are also rejected. Unit tests in `mapping-spec.spec.ts` (6 cases, "one id space per canonical family (A3)") cover:
  - rejection;
  - the declared-shared case being accepted;
  - a declaration that omits a step;
  - a declaration with no fan-in;
  - malformed declarations;
  - all shipped specs being 1:1.

## Equivalence evidence
- **Frozen oracle.** `mapping-spec.equivalence.spec.ts` embeds the retired mapper code from 61b93cff. `oracle-verbatim-check.txt` shows the oracle is identical to `git show 61b93cff:src/scout/mappers/*.ts` for all three files, after removing import/export lines and normalizing whitespace. The oracle's family layer reproduces the 61b93cff `families.ts` dispatch.
- **Corpus: 78,560 rows.**
  - Payloads: 22 recorded fixture payloads (TrueCoach clients/workouts/client-history goldens and every conformance-alpha `expect_records` payload), 442 adversarial payloads (including `??` no-fall-through cases, `__proto__` and NaN/Infinity), and 1,500 seeded-random payloads.
  - Each payload is crossed with 8 source_ids (padded, blank, tab, NBSP) and 5 platforms (including `TrueCoach`, `trainerize` and `''`).
- **Comparisons**, each with `util.isDeepStrictEqual`, over every row:
  - `mapClient` for each source;
  - `mapEntity` under both `workouts` and `client_history` for each source;
  - the family-layer `map()` for all 3 families.
  - The sweep also checks that every legacy skip-reason class occurs.
- **Result: 0 mismatches.**
- **Mutation check** (`jest-head-68be527a.log`): changing only TrueCoach `workouts.label` coercion to `string_or_finite_number` fails exactly the two affected tests. The file was then restored and `git diff` is clean.
- **Retargeted specs.** The existing mapper and registry spec assertions are unchanged apart from two registry-level edits:
  - the key-order test now asserts the two sources are present and the keys are sorted;
  - `mapEntity` now takes the family as an argument.
- **Persisted output.** `persist` is byte-unchanged and `map` output is deep-equal, so persisted values are unchanged. **No T4 trigger:** no schema, persist or persisted-value change.
- **`sourcePersonId` trimming is not unified.** `clients` still keys on the trimmed id, while entities and the ledger still use the raw `source_id`. Unifying them would change persisted keys for padded ids, which is a T4 change, so I did not do it. Trimming now happens in a single code point.

## Gates (at HEAD 68be527a unless noted)
- **tsc:** `NODE_OPTIONS=--max-old-space-size=4096 npx tsc --noEmit` exit 0 (standalone run and in both commits' hooks).
- **eslint** (`--max-warnings 0`) and **prettier --check** passed on all changed files.
- **R75** `check-r75.js --mode=staged`: OK, no positive token change.
- **Affected Jest** (`npx jest test/scout src/scout`), run under `flock -n` on `/home/user/workspace/execution/test-validation.lock`. When the lock was busy (held by `ux-e1`) I waited and retried; I never removed it.
  - HEAD: **41/41 suites, 821 passed, 5 skipped**. Log: `jest-head-68be527a.log`.
  - Earlier pre-amend run (`jest-commit1.log`): 40/40 suites.
  - The C-owned `conformance-alpha.e2e`, `scout-reconstruct.families` and `scout-reconstruct.service` specs pass unmodified.
- **node_modules:** copied from `worktrees/s7-nq1` (read-only source; nothing written there) after the `nq1/env` E3 verified install. `.package-lock.json` sha256 `05bc530a…` and prisma `index.d.ts` `92d42c56…` match E3.

## Third source (commit 2)
`conformance_beta` is structurally distinct from both existing sources:
- the person name is at `data.person.fullName`, with `nickname` as fallback;
- the client link is at `links.athlete.ref`, with `athleteRef` as fallback;
- the label is at `meta.headline`, with `summary` as fallback;
- its own steps are `athletes`, `programs` and `sessions`; `messages` is unmapped.

The spec checks:
- the source registers from data alone;
- no `src/**/*.ts` mentions the new source;
- its step resolution;
- family-layer `map()`;
- the **unmodified `ScoutReconstructService` end to end** (in-memory double): counts 3/2/1/0 and 1/1/0/0, full persisted Person/entity rows, a `missing_source_id` skip in the ledger, and a replay that produces identical counts and no new rows.

## Findings
- **A — landing blocker, outside owned paths. `nest-cli.json` must ship `sources/*.json`.**
  - **Harm:** `nest build` does not copy the JSON specs into `dist/`. Proof: with the current config, `require('./dist/scout/reconstruct/families')` throws ENOENT on `dist/scout/reconstruct/sources`. Because the loader fails closed, a production boot would crash rather than silently skip every row as unsupported.
  - **Blocked:** landing and deploying S8-A. Nothing else.
  - **Minimum closure:** add one asset entry to `nest-cli.json` → `compilerOptions.assets`: `{ "include": "scout/reconstruct/sources/*.json", "outDir": "dist" }`. The full proposed file is `nest-cli.proposed.json`. Verified: `nest build -c <proposed>` ships all three specs, `dist` loads the registry (`conformance_alpha,conformance_beta,truecoach`), and `clients.map` output is correct. The glob means later sources still need no config change, so CORE DIFF stays 0.
  - **Needs:** a parent grant for that one file, or it rides with the landing rebase. The Dockerfile already copies `dist/`.
- **Wiring left to later slices.** `unresolved_family` is exposed as a pure API (`resolveStagedFamily`). Wiring it into the engine or terminal arbiter needs `scout-reconstruct.service.ts`/DTO, which are outside S8-A's owned paths. That belongs to S8-G/S9, per brief §4 item 4. The engine still returns 400 for families outside the allow-list.
- **C (record):**
  - The registry key order changed from declaration order to sorted filename order. No production consumer depends on the order.
  - `SourceMapper.mapEntity` now takes `family`. The only callers are `families.ts` and the owned specs.
- **Landing** still waits for C (fake-spec overlap) and a rebase, per the grant.

## Artifacts (`/home/user/workspace/execution/ce3748cb/s8-a/`)
- `SOURCE_READY.md` (this file) and `oracle-verbatim-check.txt`.
- `legacy/*.mapper.ts`: `git show` copies of the retired mappers.
- `nest-cli.proposed.json`.
- Jest logs: `jest-commit1.log`, `jest-final-scout.log`, `jest-head-68be527a.log`, `jest-commit2-reconstruct-verbose.log` (the pre-fix third-source run, which failed on a test-double bug).
- Hook logs: `commit1-hooks.log`, `commit1-amend-hooks.log`, `commit2-hooks.log`.
- `commit2-staging/`: pre-commit drafts of the commit-2 files.

## Update — landing closure A (parent grant ~21:13Z)
- **New head:** `35eeb6ce9e38cca18fa006cca890401a15270137`, subject `build(importer): ship source mapping specs with the compiled output`. This is a third commit on top of `68be527a`; the earlier commits were not amended.
- **Diff:** `nest-cli.json` only, +2/−1. It adds exactly one assets entry: `{ "include": "scout/reconstruct/sources/*.json", "outDir": "dist" }`.
- **Commit identity:** Bradley Gleave as author and committer, no trailers.
- **Hooks:** genuine lefthook hooks passed: prod-readiness-quick, banned-cast-tokens, prettier, tsc, no-ai-tokens. eslint was skipped because no files matched its glob. Log: `commit3-hooks.log`.
- **Build receipt** (`NEST_BUILD_RECEIPT.txt`):
  - Plain `npx nest build` at a clean HEAD exits 0.
  - `dist/scout/reconstruct/sources/` contains all three specs, and each one's sha256 equals its `src` counterpart.
  - The `dist` registry loads with keys `conformance_alpha,conformance_beta,truecoach`.
  - `dist` family `map()` gives the correct output for TrueCoach clients, conformance_alpha workouts and conformance_beta client_history.
  - `trainerize` returns `unsupported_platform:trainerize`, and TrueCoach `notes` returns `unresolved_family:notes`.
  - The tree is clean after the build (`dist/` is gitignored).
- **Parent dispositions recorded:** deferring `unresolved_family` wiring to S8-G/S9 is accepted (C). Leaving the `sourcePersonId` split unchanged is accepted (T4 avoided).
- **Stopped here** for the independent T3 review.

## Update — rebase onto accepted C `1b6cc66164b3398d573ba92f0c8f6b039494be24` (parent ~21:57Z)
- **Method:** `s8-a` was reset to 1b6cc661, then each commit was replayed in order with `cherry-pick -n` and committed again using its original message.
  - Every commit has Bradley Gleave as author and committer, no trailers.
  - Genuine lefthook hooks passed on all three commits. Log: `rebase-1b6cc661-hooks.log`.
  - The old chain is preserved at local branch `s8-a-pre-rebase-35eeb6ce`.
- **New heads:**

  | Old | New | Subject |
  |---|---|---|
  | 138cc9c1 | `e2df2e01c5a84267b4db54e3f682d74cdf4b1911` | feat(importer): interpret source mappings from data instead of per-source mappers |
  | 68be527a | `b5f8501aed4b3cc0754b0a085325868b41c3bafc` | test(importer): add a third synthetic source as mapping data only |
  | 35eeb6ce | `2db062b00d45e9a4168a107485ad05e9ed9466b5` (HEAD) | build(importer): ship source mapping specs with the compiled output |

- **Conflicts / content change: none.** Evidence is in `REBASE_1b6cc661_BLOBS.txt`:
  - All 17 S8-A paths have the same blob at 2db062b0 as at 35eeb6ce (the three deletions are still deletions).
  - None of those paths changed between 61b93cff and 1b6cc661; the intersection with C's file list is empty.
  - Each commit's `patch-id --stable` matches its original.
  - The `name-status` list for 1b6cc661..2db062b0 is identical to the one for 61b93cff..35eeb6ce.
  - Commit 2 still touches 0 `src/**/*.ts` files.
- **Gates at 2db062b0:**
  - `tsc --noEmit` (4096 MB heap) exit 0. Log: `tsc-2db062b0.log`.
  - Jest `test/scout src/scout`, run under `flock -n` on the canonical `test-validation.lock`: **42/42 suites, 860 passed, 5 skipped**, exit 0. Log: `jest-2db062b0.log`. There is one more suite than before because C added `g2-c-db-guard`.
- Nothing pushed; no PG run. Stopped here.
