# S8-A independent T3 review — data-only mapping interpreter

**Verdict: ACCEPT** (source/unit scope, draft head `35eeb6ce` on base `61b93cff`). No A or B findings. The C items are recorded below and do not block anything.

- **Reviewer:** independent T3 reviewer (not the builder).
- **Worktree:** `/home/user/workspace/worktrees/s8-a` was not modified; `git status` is clean before and after.
- **Scratch build:** a `git archive 35eeb6ce` copy at `/tmp/s8a-review-build`, with `node_modules` symlinked in.
- **Contract:** `e322602d:docs/decisions/2026-09-24-s8-native-contract.md` (D-S8-1, including the A3 rule, and §6 S8-A hooks).
- **Grant:** `S8_0_A_GRANT.md` together with brief §3 row S8-A.
- **Reviewer artifacts** (`s8-a/review/`): `probe.js`, `probe.out`, `nest-build.log`, `jest-review-head-35eeb6ce.log`, `jest-review-mutation.log`.

## Question-by-question (all independently verified)

| Question | Result | Evidence |
|---|---|---|
| **Owned-path scope** | PASS | `git diff --stat 61b93cff HEAD` shows 17 files. All are inside brief §3 S8-A owned paths, except `nest-cli.json`, which is the parent-granted landing closure in `35eeb6ce` and has a single asset line. The three C-owned fake specs (`conformance-alpha.e2e`, `scout-reconstruct.families`, `scout-reconstruct.service`) are untouched: `git diff --quiet 61b93cff HEAD -- …` passes. |
| **Persist unchanged** | PASS | The `families.ts` diff has exactly two code hunks: the type import moves to `./mapping-spec`, and `mapper.mapEntity(row)` becomes `mapper.mapEntity(entityType, row)`. Both `persist` bodies and `buildFamilyRegistry` are byte-unchanged. The engine, DTO and schema are untouched. There is no T4 trigger. |
| **Equivalence is genuine, not a tautology** | PASS | (1) **Oracle is verbatim.** I compared the frozen oracle blocks (spec L36-95, L100-185, L190-274) with `git show 61b93cff:src/scout/mappers/*.ts`. After removing only import lines and `export`, stripping whitespace and removing trailing commas, all three files are identical. Comments were kept, so this check is stricter than the builder's. (2) **Oracle dispatch matches base.** `legacyFamilyMap` reproduces the 61b93cff `families.ts` `map()` dispatch: platform lookup, then `unsupported_platform:`, then client or entity. (3) **Actual side is live code.** It is the live `buildSourceMapperRegistry()` / `buildFamilyRegistry()` over the shipped JSON. (4) **Comparison is strict.** It uses `isDeepStrictEqual` over 78,560 rows (22 fixture payloads, adversarial and seeded-random payloads) × padded/blank/NBSP ids × foreign/case-variant/empty platforms. It also asserts that every skip-reason class occurs. (5) **My own mutation fails it.** In the scratch copy I swapped TrueCoach `workouts.label` paths to `[name],[title]`. Exactly the two affected tests fail (`mapEntity(workouts)` and family `map()` for workouts); the other 10 pass. (6) **Code reading agrees.** Tracing `??` fall-through, the `string` vs `string_or_finite_number` split, NaN/Infinity, own-key reads and the trim-once guard by hand matches the retired code. |
| **68be527a: CORE DIFF = 0** | PASS | The commit touches `sources/conformance_beta.json` and `test/…/mapping-spec.third-source.spec.ts` only. `git diff --name-only 68be527a~1 68be527a -- 'src/**/*.ts'` returns 0 files. The spec drives the unmodified engine end to end. |
| **Fail-closed on malformed or unknown specs** | PASS | Probes against the built `dist` (`probe.out`) reject each of these at load time with a located error: unknown top-level key, extra field (`email`), non-canonical family (`billing`, `programs`), bad coercion, empty paths, empty key, `specVersion` 2, non-canonical platform (`TrueCoach`), a step targeting an unmapped family, and a non-object spec. The loader throws on a missing directory, an empty directory, a duplicate `sourcePlatform`, and malformed JSON. At row time the interpreter is total. An unmapped step or family gives `unresolved_family:<token>` (`truecoach`/`notes` confirmed from `dist`). An unregistered platform gives `unsupported_platform:<token>`. |
| **A3 shared-id-space validator** | PASS | These are rejected: fan-in without a declaration; a partial declaration; a declaration with an extra step; a stale declaration (no fan-in); duplicate members; a non-array declaration; and a `__proto__` declaration key. A fan-in with the exact declared set is accepted in any order. The rule matches contract D-S8-1: "at most one source step per family unless declared shared; whole spec rejected before any row". |
| **JSON ships in the production build** | PASS | Independent `npx nest build` on the scratch copy of `35eeb6ce` exits 0. `dist/scout/reconstruct/sources/` holds all three specs, byte-equal to `src`. The `dist` registry is `conformance_alpha,conformance_beta,truecoach`, and `dist` `map()` output is correct for TrueCoach, conformance_alpha and beta. `.dockerignore` excludes neither `src/**/*.json` nor `nest-cli.json`. The Dockerfile runs `npm run build` (`nest build`) and copies `dist/`. |
| **Gates** | PASS | Affected Jest at HEAD `35eeb6ce` (`npx jest test/scout src/scout`, run under `flock -n` on the heavy-slot lock after waiting while it was busy; the lock was never removed): **41/41 suites, 821 passed, 5 skipped**, exit 0. This matches the builder's result. |
| **Identity** | PASS | All three commits have Bradley Gleave `<bradley@bradleytgpcoaching.com>` as both author and committer. `%(trailers)` is empty for all three. The retargeted mapper and registry specs keep their assertions; the only changes are the two registry-level edits the builder disclosed. |

## Findings

**A: none. B: none.**

**C (record / qualify / continue — none of these creates work or blocks anything):**

1. **Test file name differs from the contract.** Contract §6 and D-S8-1 name the A3 test file `test/scout/reconstruct/mapping-spec-validation.spec.ts`. The A3 cases actually live in `mapping-spec.spec.ts`, under "one id space per canonical family (A3)". That file is inside the owned glob and the evidence is equivalent. Qualify the citation; do not rename.
2. **`steps` and A3 are not yet on the production dispatch path.** The engine still selects rows by `entity_type == family` (`scout-reconstruct.service.ts` L66-78). `resolveStep` and `resolveStagedFamily` are pure APIs with no production caller, so there is no fan-in route today and the A3 validator is preventive. Carry this forward: S8-C/S8-G must route staged step tokens through `resolveStep`, or the A3 protection does not bind. The parent has already accepted the deferral of `unresolved_family` wiring and the remaining 400 for non-allow-listed families.
3. **A `__proto__` step key is silently dropped.** `steps["__proto__"]` assignment is a no-op, so that step vanishes from the validator's fan-in count. It then resolves to `unresolved_family:__proto__` and never merges into another step, so there is no harm. Hardening option for later (not required): `Object.create(null)` or an explicit rejection.
4. **Loader error for malformed JSON omits the file name.** On a JSON syntax error the loader throws the raw `JSON.parse` message without the file name. It still fails closed, and structural errors do name the file.
5. **A synthetic source now ships in `dist`.** `conformance_beta` is loaded by the production registry, in the same posture as `conformance_alpha` at base. Reconstruct stays behind the existing default-off flags and RLS. No new exposure class.
6. **Keep the three commits together when landing.** `138cc9c1` alone would fail to boot, because `dist` lacks `sources/`. The landing rebase or squash must keep `35eeb6ce` with it.
7. **No durable grant file for `nest-cli.json`.** The parent grant for this change exists only as the parent's dispatch statement, not as a written grant file.

## Decision

- **S8-A source/unit: ACCEPT** at `35eeb6ce`.
- **Landing** still waits on C landing (fake-spec overlap) and a rebase of all three commits, per the grant. After the rebase, a delta-only re-check is needed only if the rebase touches the S8-A files.
- **Next unlocked:** S8-C can build on the interpreter and must honor C2.
