# S12-B2 independent T3 review — 726d2227

Parent `fa72efb2`; rules `WORKER_RULES.md`; grant `S12B2_REVIEW_GRANT.md`. Read-only review of `/home/user/workspace/worktrees/fa72-s12b2`, HEAD `726d22276dbedf0bde6bee9e3ef8eaf444297567` (parent `aed23289`, tree `013134c57c21cc321069db0726b9a5ce26ce32f0`). Working tree clean at both checks. No source edits, commit, push, or PostgreSQL.

## Verdict: NO-GO

The data marker and parser work for explicit `production`/`staging`, but the default runtime policy permits the shipped test key when `NODE_ENV` is **unset** (or an unrecognized spelling). That is exactly the production-image configuration not ruled out by the checked-in Dockerfile/Fly configuration. D2 C1 is not closed independently of an operator setting a particular environment string.

## A/B findings — required five-field form

**B1**

1. **CLASS:** B — test-only verifier trusted in a plausible production runtime.
2. **CONCRETE HARM:** `loadInductionManifests()` defaults its `prodLike` argument to `isProdLike(process.env.NODE_ENV)` (`src/scout/induction/manifest-registry.ts:34-36`). `isProdLike(undefined)` is **false** (`src/common/env-validation.ts:769-772`); it is also false for `Production `, `prod`, and any other unrecognized spelling. Thus the marked `s10_unseen.json` and its marked verifier are loaded, and a coach with the committed fixture private key can self-certify a `complete` run for that fictional platform in their own tenant (the D2 C1 scenario). Neither `Dockerfile` (runtime `CMD ["node","dist/main.js"]`; its `ENV` lines set only release IDs) nor `fly.toml` sets `NODE_ENV`; deployment secrets might set it, but these checked-in artifacts do not guarantee it. Existing S12-B2 tests cover explicit strings but not absent/unknown `NODE_ENV` (`test/scout/induction/test-only-exclusion.spec.ts:162-177`).
3. **EXACT DECISION BLOCKED:** Accepting S12-B2 as closing D2 C1 and approving production-like enablement/deployment on that security premise.
4. **MINIMUM CLOSURE:** At the manifest-loading boundary, default to refusing test-only artifacts unless the runtime is **explicitly** a permitted development/test mode, or establish and verify an equivalent fail-closed production-mode invariant at boot for every deployable image. Preserve explicit `test`/`development` behavior; add discriminating no-DB cases for absent and unrecognized/trailing-space values on the default loader, alongside mixed-case production/staging. Do not change the global `isProdLike` helper casually; other callers have separate semantics. A boot-time invariant must be tested against the deployable path, not just asserted in a runbook.
5. **EXECUTION UNLOCKED:** Production-like environments, including an image started without `NODE_ENV`, cannot trust the committed synthetic key; parent can then decide acceptance/landing and re-run parent-only proof lanes.

No A finding. This is a configuration-independent safety requirement, not a claim that the current live Fly secret is absent (no live environment was inspected).

## C list — record, qualify, continue

- **C1 — Correct behavior where `prodLike=true`.** `parseManifest` strips only the literal `true` marker before strict keys, validates all verifiers and duplicate IDs, and returns the unchanged frozen manifest in non-prod (`parse.ts:300-343,353-440`). Runtime parsing drops a marked manifest or filters marked verifier keys; registry filename and duplicate checks still run (`manifest-registry.ts:47-70`). For a missing package, observation is refused as `observation_not_declared` (`observation.service.ts:267-273`), while the evaluator emits unknown families, not known zero (`verify.ts:276-295`). The unmarked package still proves in the positive-control spec. The absence of a dedicated rejection code is acceptable within the closed vocabulary.
- **C2 — Parser path and parent-only PG evidence.** At explicit `NODE_ENV=test`, the marker is stripped and the original manifest/key remain available. The changed parser is exercised by D2 `test/scout/s10/s10-unseen.pg.spec.ts` through the repository default loader (`:122-158`, including `:145`), and by the S11-A2 `journey-induction.pg.spec.ts` J09–J11 and S11-D `journey-full.pg.spec.ts` J19 through their induction worker/default service registry. These must be parent-run, not presumed re-proven by this review. S11-E may change the later J20 proof scope, not this parser behavior.
- **C3 — Gate/J20 coordination, not a B2 runtime dependency.** D-S10-5's historical D2 gate is pinned to B=`7fdcbc04` and GATE_HEAD=`275e458c`; it is not a general gate to run with this core-edit commit as HEAD. Future *new-source* grants must pin their B after reviewed core changes. Current `journey-full.pg.spec.ts:524-550` walks through HEAD and would reject B2's unlisted src-touching commit; the builder's suggested separate `SLICE_COMMITS` companion pin is correct **for those current bytes**. The review grant says S11-E is re-scoping this check to a literal `S11_RANGE_END`; once that change actually lands, later commits such as B2 require no extra `SLICE_COMMITS` pin. Inspect the integrated J20 bytes before parent proof/landing; neither a speculative S11-E change nor a companion pin is part of this B2 commit. B2 itself relies on neither approach to perform runtime refusal.
- **C4 — Other source artifacts.** The synthetic mapping spec/native rules are still loaded under explicit production mode, but without an induction package they cannot create signed completeness. An already stored observation from an earlier runtime does not prove against the absent package. This is a narrower trust-exclusion design, not a claim to remove every synthetic asset from an image.
- **C5 — Scope of strictness/test coverage.** Wrong marker value (`false`, `"true"`, `1`, `null`) throws in both modes; wrong object casing and other unknown keys are rejected by `assertKeys`. Shipped data marks both the synthetic manifest and its D2 verifier. The two shipped-data `>0` assertions require a synthetic fixture to remain in the tree; future removal would require test maintenance. No new source slug or `u10_`/second-source token literal was found in changed `src/**/*.ts` (search RC 1). The positive/negative no-DB controls are meaningful but omit B1's unset-env case.

## Files reviewed / hashes / LOC

Absolute paths below are under `/home/user/workspace/worktrees/fa72-s12b2/`; `wc -l` counts physical lines. The commit changes four files, +399/-14 lines (`git show --numstat`).

| Path | sha256 | LOC | Commit +/− |
|---|---|---:|---:|
| `src/scout/induction/manifest-registry.ts` | `ef1d29f9e2d5d642957a1bd9bf80caba14e3b02d6a559f6f46412f0e1ff967b2` | 165 | +18/-5 |
| `src/scout/induction/parse.ts` | `a4b6cf59cce899b8faf9d6e51fbd9684db75bd34c3b83e582a4b2541d9366a33` | 441 | +66/-8 |
| `src/scout/induction/sources/s10_unseen.json` | `b3d428b203a777fbc5b260c7e73164303e4fc60bf45632ce7ce30d677aa6edb8` | 20 | +3/-1 |
| `test/scout/induction/test-only-exclusion.spec.ts` | `ab24bc0146e14a469ae7e329732394a804d501fd0c5dccc48062b0e067e33375` | 312 | +312/-0 |

Also read worker rules, both grants, builder report, D2 C1 review, S12 readiness row, S11-E build grant, relevant registry/evaluator/observation/PG/J20/gate code, `env-validation.ts`, `Dockerfile`, `fly.toml`, and deployment/package references. No live Fly configuration was read.

## Commands and results

All paths are read-only unless noted; no DB command. Each multi-command shell invocation returned RC 0 overall unless an explicit search status is recorded. `sed`, `nl`, `rg`, `rg --files`, `head`, `git show`, `git status`, `git diff-tree`, `git rev-parse`, `sha256sum`, and `wc -l` were used in the following groups:

1. `sed` worker rules, review grant; `git status --short`, `git show --stat --format=fuller 726d2227` — RC 0.
2. `sed` builder grant/report, D2 review, S12 readiness; `git show 726d2227 -- <four paths>`; `rg` markers/gates/slug across relevant src/test/evidence — RC 0.
3. `nl` env-validation/registry/verify/observation, spec/parser/J20; `rg` S11-E/J20 and NODE_ENV references; `git status`, `git diff-tree`, `git show --numstat`, `sha256sum`, `wc -l` — RC 0.
4. `rg --files` deploy/package files; `rg` NODE_ENV/PG loader paths; `sed` Dockerfile, Fly config, S11-E grant, gate; `test -e /home/user/workspace/execution/fa72efb2/PROOF_SLOT_FREE` — RC 0 (slot marker present).
5. `git diff aed23289 726d2227 -- <changed src files> | rg` for source-specific added lines — `rg` RC 1 (no hits); `git rev-parse HEAD HEAD^{tree}` and `git status --porcelain` — RC 0, clean; `rg -n -F s10_unseen src --type ts` — RC 1; `rg -n -e u10_ -e s11_second <changed src files>` — RC 1.
6. No-DB tests, queued with the canonical lock: `NODE_OPTIONS=--max-old-space-size=3072 flock -w 3600 /home/user/workspace/execution/test-validation.lock bash -c './node_modules/.bin/jest --runInBand --runTestsByPath test/scout/induction/test-only-exclusion.spec.ts test/scout/induction/manifest-registry.spec.ts test/scout/s10/s10-unseen.e2e.spec.ts'` from subject root — RC 0; 3 suites/53 tests passed. No `*.pg.spec.ts`, `rls-g2-*`, tsc, eslint, npm install, or PostgreSQL.

## Open risks / handoff

The present tests' green result does not cover B1. Parent should route a small security fix and independently review it, then run D2 and S11 induction/J19 PG lanes at the final landed head under the parent-only proof binding. Before the S11/J20 proof, resolve the integrated S11-E range-boundary version versus the current full-to-HEAD version; do not weaken either gate by silently omitting this commit.

---

## Round 2 — independent delta review of `c516d463`

**Updated verdict: GO** for S12-B2 at `c516d463e71c5c97d290368dec4f91c66bda7503` (tree `11350cdb3e91f02b85d3aad18e52c1d8c26bffb2`, parent `726d2227`). This supersedes the round-1 NO-GO above. **B1 closed; no open A/B findings.** This was a delta review against B1, not a fresh re-audit of accepted round-1 bytes. Subject worktree was clean; no source edit, push, or PostgreSQL.

### B1 closure, in the required five fields

1. **CLASS:** B (round 1), now **closed**.
2. **CONCRETE HARM:** The prior default trusted the committed synthetic key when `NODE_ENV` was unset/unrecognized. At r2, `testOnlyArtifactsAllowed(nodeEnv)` returns true *only* for trimmed, case-folded `development` or `test` (`manifest-registry.ts:28-36`); `loadInductionManifests()` defaults `refuseTestOnly` to its negation (`:43-45`) and passes that boolean to `parseInductionManifestForRuntime` (`:76`). An absent/empty/unknown environment now refuses the marked manifest and marked verifier instead of trusting them. `isProdLike` and its other callers are unchanged.
3. **EXACT DECISION BLOCKED:** The B1 security-closure decision is no longer blocked at this reviewed head. The parent still owns acceptance/landing and proof execution.
4. **MINIMUM CLOSURE:** Implement an explicit development/test allow-list and discriminate missing, blank, unknown and production-like strings on the **default** loader. Done: `test-only-exclusion.spec.ts:170-210` checks 12 refusing and 4 allowing values; each refusing case tests both a marked manifest and a mixed manifest with a marked verifier. The original full-coverage positive/unknown controls remain.
5. **EXECUTION UNLOCKED:** The parent can consider D2 C1 closed at this candidate head, subject to integrated proof and J20 coordination; a production image with no `NODE_ENV` no longer loads the synthetic key.

### C list / execution qualifications

- **C6 — PG environment inheritance:** Jest's installed launcher sets `NODE_ENV=test` when unset (`node_modules/jest-cli/bin/jest.js:11-14`); D2 `s10-unseen.pg.spec.ts` calls the default manifest loader in-process (`:143-146`), and the S10-B/S11 worker forks spread `...process.env` without overwriting `NODE_ENV` (`test/utils/g2-s10b-pg-harness.ts:126-133`, `g2-s11-pg-harness.ts:139-146`). The S11 worker includes repository default manifests in its induction registry (`g2-s11-worker.cjs:295-315`). The new no-DB structural guard checks these harness/worker files. **Condition:** if the parent launches Jest with an explicit `NODE_ENV` other than development/test, Jest preserves that value and the old synthetic `complete` PG assertions will fail **closed**, not become false positives. Parent reports no NODE_ENV override in the proof bindings; this review did not run those bindings or any PG lane.
- **C7 — Current J20 versus planned S11-E:** Both B2 commits touch `src/`. If J20 remains the `3db615c0^..HEAD` walk, **both** SHAs need a companion pin. If the S11-E change to a literal `S11_RANGE_END` lands first, later B2 commits require neither pin. This r2 runtime fix does not depend on either; parent must inspect the integrated J20 version before its parent-only lane. The historical D-S10-5 check keeps its history pins; future new-source baseline B should be after reviewed B2.
- **C8 — Narrow explicit-test authorization:** A production deployment deliberately configured with `NODE_ENV=test` or `development` still loads test-only assets by design. That is an operator configuration outside the code's ability to distinguish from an actual test/development process; no assertion is made about live environment variables. Neither the production Dockerfile nor `fly.toml` themselves set `NODE_ENV`.

### Delta files / SHA / LOC

All paths are under `/home/user/workspace/worktrees/fa72-s12b2/`. `git diff 726d2227 c516d463 --numstat`: three files, +90/-26; the synthetic JSON is unchanged.

| Path | sha256 at r2 | Physical LOC | Delta +/− |
|---|---|---:|---:|
| `src/scout/induction/manifest-registry.ts` | `ced166da74e1ec329d78f186c7cf2495da2c2d9dd9ef07ed3484d812bea4e147` | 174 | +14/-5 |
| `src/scout/induction/parse.ts` | `6c8c1e790f1ea621e835b8df939d360d1227adc9852db64c6deb654d54e88842` | 441 | +4/-4 |
| `test/scout/induction/test-only-exclusion.spec.ts` | `6a3d67102d324ea39a6d00ec82e7e46aff601f5765bfbbd6068c4e3747b13c30` | 367 | +72/-17 |
| `src/scout/induction/sources/s10_unseen.json` (unchanged) | `b3d428b203a777fbc5b260c7e73164303e4fc60bf45632ce7ce30d677aa6edb8` | 20 | +0/-0 |

### Delta-review commands / RC

1. `git status --porcelain`, `git show --stat --format=fuller c516d463`, `git diff 726d2227 c516d463 -- <three paths>`; `rg`/`sed` round-2 builder report; `rg` r2 symbols/slot marker — RC 0; slot present.
2. `git diff` of the spec, `nl` r2 loader/parser and fork/worker/Jest entrypoint, `rg NODE_ENV` over relevant worker/harness/PG files — RC 0 for the reading commands; the final `rg` returned RC 1 (no NODE_ENV hits in that enumerated source set).
3. `sha256sum`, `wc -l`, `git rev-parse HEAD HEAD^{tree}`, `git status --porcelain` — RC 0; clean. `rg -F -l s10_unseen src --type ts` — RC 1 (no slug in source TypeScript).
4. With `PROOF_SLOT_FREE` present, from the subject root: `NODE_OPTIONS=--max-old-space-size=3072 flock -w 3600 /home/user/workspace/execution/test-validation.lock bash -c './node_modules/.bin/jest --runInBand --runTestsByPath test/scout/induction/test-only-exclusion.spec.ts test/scout/induction/manifest-registry.spec.ts test/scout/s10/s10-unseen.e2e.spec.ts'` — RC 0, **3 suites / 70 tests passed**. No PG tests, tsc, eslint, npm install, or database.
