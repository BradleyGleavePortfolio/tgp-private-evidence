# S12-B2 build report: test-only manifests excluded from prod-like runtimes (T3, EXEC-FA72EFB2)

Builder: T3 (Claude Opus). Grant: `s12b2/S12B2_BUILD_GRANT.md`. Rules: `WORKER_RULES.md`. Closes D2 C1 (`s10d2/d2_review.md` L217-222).

## Head / tree
- Clone: `/home/user/workspace/worktrees/fa72-s12b2`. It is a standalone `git clone --no-hardlinks` of `worktrees/fa72-s11d2`. origin is `no_push://disabled-fa72efb2`. node_modules is `cp -al` from `fa72-s11a1`, and lefthook is installed (pre-commit and commit-msg).
- Base: `aed23289024898cceca7385d3778cd7373b7424d`. The local branch name `fa72/s11d-r2` was inherited from the source clone and was not renamed.
- **HEAD `726d22276dbedf0bde6bee9e3ef8eaf444297567`, tree `013134c57c21cc321069db0726b9a5ce26ce32f0`**, parent `aed23289`.
- The work is one commit, made through the hooks with no `--no-verify`. Author and committer are both `Bradley Gleave <bradley@bradleytgpcoaching.com>`. There are no trailers. Nothing was pushed, and the working tree is clean.

## Design (generic, data-marked, no slug in src)
- **The marker is data, not a list of slugs.** No test-only marker existed before this change, so I added an optional marker:
  - `"testOnly": true` on an induction manifest;
  - `"test_only": true` on a verifier. Each marker follows its own object's key casing.
  
  When a marker is present it must be literally `true`; any other value throws in every mode. The marker is removed before the strict V1/V5 key check, so every other rule still applies. `contract.ts` (including `MANIFEST_KEYS` and `VERIFIER_KEYS`) is **unchanged**.
- **Refusal happens in a prod-like runtime.** "Prod-like" means `isProdLike(NODE_ENV)`, which reuses the existing helper `src/common/env-validation.ts` L769-772 (`production|staging`, case-insensitive). That makes it one step stricter than "NODE_ENV=production": staging is refused too. In that runtime:
  - **Test-only manifest: not loaded.** Its platform then has no induction package. Two landed paths fail closed and explicitly:
    - the observation route refuses the upload with the existing closed code `observation_not_declared` (`observation.service.ts` L267-273);
    - the evaluator makes every declared family `{known:false}` (`verify.ts` L278-291, E1). It is never `complete` and never zero.
    
    No new reason code and no vocabulary change were needed.
  - **Test-only verifier (key): dropped** from an otherwise trusted manifest. Evidence signed under that key never proves (`verify.ts` L224), so it is also unknown.
  - Every marked artifact is **still fully validated first** (parse, filename rule, duplicate check). A defective test-only manifest therefore fails loudly and is never silently skipped.
- **Non-production is unchanged.** `parseInductionManifest` returns the same frozen `InductionManifestV1` as before, with the marker removed. In dev and test (jest runs with `NODE_ENV=test`), `loadInductionManifests()` returns the same list. Every landed D2, S11-A2 and S11-D PG proof therefore loads the same package.
- **Data:** the shipped `src/scout/induction/sources/s10_unseen.json` gets `"testOnly": true` at the manifest level and `"test_only": true` on its D2 verifier `s10_unseen.source.d2`. The verifier marker is defence in depth.
- **Scope choice (recorded as C-1 below):** the mapping spec and native rule set of a test source still load in production. They grant no trust and only map rows inside the coach's own tenant. C1's harm is the `complete` proof, and the proof root is the manifest and verifier.

## File:line (at 726d2227)
- `src/scout/induction/parse.ts`:
  - L294-317: marker constants `MANIFEST_TEST_ONLY_KEY` / `VERIFIER_TEST_ONLY_KEY` and `takeTestOnly`;
  - L319-336: `parseVerifier`, which now returns `{verifier, testOnly}`;
  - L345-363: `parseInductionManifestForRuntime(raw, origin, prodLike)`, which returns `null` for a test-only manifest (L360) and filters test-only verifiers (L361);
  - L365-440: `parseManifest`, which holds the old body and also returns `testOnly` and `testOnlyKeyIds`. `parseInductionManifest` wraps it, so its signature is unchanged.
- `src/scout/induction/manifest-registry.ts`:
  - L3: import `isProdLike`;
  - L29-36: the new `prodLike` parameter, which defaults to `isProdLike(process.env.NODE_ENV)`;
  - L46-70: all validation as before, then `parseInductionManifestForRuntime`, keeping only non-null results.
- `src/scout/induction/sources/s10_unseen.json`: L3 (`testOnly`) and L15-16 (`test_only`).
- `test/scout/induction/test-only-exclusion.spec.ts` (new, 16 tests). Specs required by the grant:
  - prod refusal of each artifact kind: manifest; verifier, i.e. the key;
  - the NODE_ENV default for production, staging and PRODUCTION, versus test and development;
  - non-production unchanged;
  - an unmarked manifest is identical and still proves in prod;
  - the marker must be exactly `true`;
  - markers are per object;
  - validation still happens before refusal;
  - shipped data: every shipped manifest that trusts a committed `signer-test-key.json` public key must be `testOnly`, and the prod-like shipped registry still builds without it;
  - no slug in the touched src.
  
  The prod cases are discriminating: the same signed evidence gives three known families without the refusal and `{known:false}` for all three with it.

sha256:
- `parse.ts` a4b6cf59cce899b8faf9d6e51fbd9684db75bd34c3b83e582a4b2541d9366a33
- `manifest-registry.ts` ef1d29f9e2d5d642957a1bd9bf80caba14e3b02d6a559f6f46412f0e1ff967b2
- `s10_unseen.json` b3d428b203a777fbc5b260c7e73164303e4fc60bf45632ce7ce30d677aa6edb8
- spec ab24bc0146e14a469ae7e329732394a804d501fd0c5dccc48062b0e067e33375

## LOC
- `git show --numstat`:
  - parse.ts +66/-8
  - manifest-registry.ts +18/-5
  - s10_unseen.json +3/-1
  - spec +312/-0
  - total: 4 files, +399/-14
- Product .ts without comments or blank lines: **+64/-12**. This is a little above the grant's estimate of about 30-60, mainly because the old parser body was split into a wrapper plus `parseManifest` so that `parseInductionManifest` keeps its signature.

## Core-diff gate impact (D-S10-5 `scripts/s10-core-diff-gate.sh`, S11-D J20)
- **Files touched that are guarded by a gate:**
  - `parse.ts` and `manifest-registry.ts` are core files. Check 4 of the gate requires them to be byte-identical to baseline B.
  - `s10_unseen.json` (induction) is one of the 8 ALLOWED paths.
  
  No check-7 vocabulary file was touched: `contract.ts`, `reason-codes.ts` and `importer-openapi.json` are unchanged. No `s10_unseen` literal was added in `src/**/*.ts`, so checks 5 and 6 still hold.
- **The gate as pinned today is unaffected.** J20 part (2) runs the gate in a scratch worktree at `GATE_HEAD=275e458c` with `B=7fdcbc04`, and both are history pins. I re-ran exactly that and got **PASS** (RC 0, all checks 1-7 ok).
- **The gate is not weakened.** Run with the S12-B2 base, `s10-core-diff-gate.sh aed23289… HEAD` **FAILs check 3** (RC 1): it lists `parse.ts`, `manifest-registry.ts` and the spec as outside the allowed set. That is correct: S12-B2 is a reviewed core change, not a new source. The script is unchanged.
- **Re-pin for the landing** (the parent owns it, in the same reviewed landing):
  - **D-S10-5:** any future new-source gate run uses `B` = the landed S12-B2 commit (or later). Recording that B is a grant/evidence pin, not a byte change to the script. Check 7 then continues to compare vocabularies against a B that already contains S12-B2.
  - **J20 companion check** (`test/scout/s11/journey-full.pg.spec.ts` L524-550, "no src-touching commit in 3db615c0^..HEAD is missing from SLICE_COMMITS"). This check **will go red** in the parent's live S11 lane at any HEAD that contains 726d2227, because this commit touches `src/` and is not pinned there. It is PG-gated, so it is skipped in no-DB CI. A commit cannot contain its own SHA, so the re-pin must be a separate follow-up commit in the same landing. That commit appends the landed S12-B2 SHA to `SLICE_COMMITS` (L486-494), for example `'<landed-sha>', // S12-B2 (test-only manifest exclusion; no slug in src)`. Once it is listed, J20 part (1) scans this commit's src `.ts` hunks too. I simulated this with git: `git show HEAD:<each changed src .ts>` contains neither `s10_unseen` nor `s11_second` (0 hits each), so J20 stays green at full strength.
  - I did not edit J20. It belongs to S11-D PR #565, which is still pending; the file is a PG spec, and it is not in this grant's owned paths.

## Gates and commands (RC)
Every heavy command was run as `flock -w 3600 /home/user/workspace/execution/test-validation.lock bash -c '…'` (inode 686480), each time after `[ -e …/fa72efb2/PROOF_SLOT_FREE ]` succeeded, with `NODE_OPTIONS=--max-old-space-size=3072`. When the slot was first checked at the start it was absent; the first heavy command ran only after it appeared (file dated 19:47Z). Logs are in `s12b2/logs/`.
1. `git clone --no-hardlinks …fa72-s11d2 …fa72-s12b2`, set the remote URL, set Bradley's identity: RC 0.
2. `cp -al ../fa72-s11a1/node_modules`: the tool call timed out at 630 s, but the copy had completed; I checked this with `find | wc -l` (60424 entries = 60424). Then `lefthook install`: RC 0.
3. `prettier --write` (3.9.9 runtime tool) on the 4 files: RC 0.
4. `npx eslint --max-warnings 0` on the 3 .ts files: RC 0.
5. `npx tsc --noEmit`: RC 0 (`logs/s12b2_tsc.log`). A first launch without `setsid` died when the tool call ended and produced no result; it was re-run.
6. `npx jest --runInBand test/scout/induction test/scout/s10/s10-unseen.e2e.spec.ts test/scout/reconciliation test/utils/g2-s11-db-guard.spec.ts --testPathIgnorePatterns '\.pg\.spec\.ts$'`: RC 0, **15 suites / 482 tests passed** (`logs/s12b2_jest.log`).
7. Negative control (mutation): I made `if (!prodLike) return manifest` unconditional and ran jest on the new spec. RC 1: 4 prod-mode tests failed, 12 passed. I then restored the file from a backup and confirmed 0 mutant lines.
8. Commit through the hooks (R75, prettier, eslint, tsc, prod-readiness-quick, no-ai-tokens): RC 0 (`logs/s12b2_commit.log`).
9. `rg -F -l s10_unseen src --type ts`: RC 1 (no hits). There are also no `truecoach`, `conformance` or `s11_second` literals in the added src lines.
10. `bash scripts/s10-core-diff-gate.sh 7fdcbc04… HEAD` in a scratch worktree at 275e458c (created and then removed in my clone): RC 0, PASS.
11. `bash scripts/s10-core-diff-gate.sh aed23289… HEAD` at 726d2227: RC 1, FAIL check 3 (expected, as described above).
12. J20 simulation with git only (a `rev-list` walk and `git show` slug grep): the only new src-touching commit is 726d2227, and it has 0 slug hits.

Not run: any real-PG lane, any `*.pg.spec.ts` live run, `rls-g2-*`, npm install or ci, prisma generate.

## PG lane needs (parent-only)
- There is no behaviour change under `NODE_ENV=test`, so the landed D2 9/9, S11-A2 and S11-D proofs are expected to remain valid. The one exception is the J20 companion check, which needs the SLICE_COMMITS re-pin above.
- **Recommended:** re-run the D2 `s10-unseen.pg.spec.ts` lane and the S11 journey lane at the landed head plus the J20 re-pin commit. That confirms the marked `s10_unseen.json` still yields `complete` in test mode.
- A PG case that runs in production mode is not needed, because the refusal is decided at load time in pure code and is covered by the no-DB spec.

## Findings / risks (Safety ROI)
- **C-1:** mapping specs and native rule sets of a test-only source still load in prod-like runtimes. This grants no trust and never makes a result `complete`; rows map only inside the owning tenant. It could be extended later with the same data marker, which would be a core edit to `mapping-spec.ts` and `native-rules.ts`. Record only.
- **C-2:** the J20 companion check goes red until the parent's follow-up re-pin commit adds the S12-B2 SHA. That is the check working as designed; the closure is described above.
- **C-3:** refusal is by omission plus the existing closed code `observation_not_declared`. There is no dedicated "test source refused" reason code or boot log, because adding one would change a closed vocabulary (gate check 7 / contract). The declaration route itself still accepts a declaration naming the platform, which is the landed behaviour for any platform without a manifest. Record only.
- **C-4:** "prod-like" includes staging (the `isProdLike` precedent), which is stricter than the literal "NODE_ENV=production". If staging pilots ever need `s10_unseen` completeness, that would be an owner choice. Record only.
- **C-5:** two shipped-data tests assert that at least one shipped manifest is test-only or trusts a committed key, which is true today (`s10_unseen`). If that manifest is ever removed, those two `>0` assertions must be relaxed. Record only.
- **C-6:** the local branch name `fa72/s11d-r2` was inherited from the clone source; the parent chooses the landing ref.

No A/B findings.

---

## Round 2 (closes review B1, `s12b2/s12b2_review.md` L11-17)

### Head / tree
- **HEAD `c516d463e71c5c97d290368dec4f91c66bda7503`, tree `11350cdb3e91f02b85d3aad18e52c1d8c26bffb2`**, parent `726d2227`. This is one new commit, not an amend.
- It went through all hooks: prod-readiness-quick, R75, prettier, eslint, tsc 48.7 s and no-ai-tokens.
- Author and committer are both Bradley, with no trailers. Nothing was pushed, and the working tree is clean.

### Diff summary
Commit numstat:

| File | Lines |
|---|---|
| `manifest-registry.ts` | +14/-5 |
| `parse.ts` | +4/-4 |
| spec | +72/-17 |

Cumulative vs `aed23289`: 4 files, +463/-14.

- `src/scout/induction/manifest-registry.ts`:
  - L28-36: new exported `testOnlyArtifactsAllowed(nodeEnv)`. It returns `(nodeEnv ?? '').trim().toLowerCase()` equal to `'development'` or `'test'`, which makes it an **allow-list**.
  - L45: the loader's second parameter is now `refuseTestOnly = !testOnlyArtifactsAllowed(process.env.NODE_ENV)`. The boolean polarity is the same as round 1's `prodLike`, so explicit-argument callers are unchanged.
  - L76: passes `refuseTestOnly` to the parser.
  - The `isProdLike` import is removed. `src/common/env-validation.ts` and its other callers are **untouched**.
- `src/scout/induction/parse.ts` L347-359: the `prodLike` parameter is renamed to `refuseTestOnly`, and the doc comment is updated. Behaviour is unchanged.
- `test/scout/induction/test-only-exclusion.spec.ts`:
  - L170-195: the default loader, with no argument, **refuses** for 12 values, and also drops the marked verifier from a mixed manifest. The values are: unset (deleted), `''`, `'   '`, `production`, `PRODUCTION`, `'Production '`, `staging`, `Staging`, `prod`, `qa`, `develop`, `testing`.
  - L196-210: the default loader **loads** for `test`, `development`, `TEST` and `' Development '`, with both verifiers kept.
  - L212-214: this jest process has `NODE_ENV=test`.
  - L216-237: a no-DB guard over the PG harness source. The S10-B and S11 worker forks build their env from `...process.env`, and none of the 8 harness/db/worker files mentions `NODE_ENV`.
  - The file is now 33 tests (was 16).
- src `.ts`: `rg -F -l s10_unseen src --type ts` gives RC 1. The added src lines contain no `s10_unseen` or `s11_second` (RC 1).

### NODE_ENV inheritance evidence (every PG path runs with NODE_ENV=test)
1. **The jest process sets it.** `node_modules/jest-cli/bin/jest.js` L12-14 (jest 30.4.2) contains `if (process.env.NODE_ENV == null) { process.env.NODE_ENV = 'test'; }`. Nothing in the repo sets it otherwise: rg `NODE_ENV` over `package.json` (`"test": "jest"`, L11), `jest.config.js`, `scripts/*.sh`, `test/utils/**` (including `g2-s10b-bootstrap.sh` and `g2-s11-bootstrap.sh`) and `test/scout/**` finds no hits other than this spec's own save/restore.
2. **D2 lane** (`test/scout/s10/s10-unseen.pg.spec.ts`). L20 says "The services run IN this jest process". The manifests are loaded in-process at L143-146 (`ind.loadInductionManifests()`), so they get NODE_ENV=test from item 1.
3. **S10-B worker children.** `test/utils/g2-s10b-pg-harness.ts` L126-133 forks `g2-s10b-worker.cjs` with `env: { ...process.env, G2_S10B_WORKER, TS_NODE_PROJECT }` (spread at L130), so NODE_ENV is inherited and not overridden.
4. **S11 worker children** (the J19 two-host journey). `test/utils/g2-s11-pg-harness.ts` L139-146 forks `g2-s11-worker.cjs` with `env: { ...process.env, G2_S11_WORKER, TS_NODE_PROJECT }` (spread at L143). The worker loads the manifests at `g2-s11-worker.cjs` L110 (require) and L308 (`...loadInductionManifests()`), and `observation.service.ts` L111 also uses the default loader.
5. **No harness or worker writes NODE_ENV.** The worker files only set `SCOUT_RUN_DEADLINE_MS` (s10b L41, s11 L63). Their only child processes are `execFileSync('git', ['rev-parse','HEAD'])`, which does not load manifests. The prisma `execFileSync` calls in the harnesses (s10b L243, s11 L256) also spread `...process.env`.
6. This is pinned by the new no-DB spec L216-237, so a future harness change that stops the env spread, or sets NODE_ENV, fails in default CI.

**Condition on the parent lane:** jest only fills NODE_ENV when it is `null`/unset. If a lane shell exports `NODE_ENV` to anything other than `development` or `test` (for example `''` or `ci`), test-only manifests are refused and the D2/S11 `complete` assertions go red. That fails closed, not open. The lanes should leave NODE_ENV unset (or `test`).

### Commands (RC)
All heavy commands ran under `flock -w 3600 …/test-validation.lock` after the `PROOF_SLOT_FREE` check, with `NODE_OPTIONS=--max-old-space-size=3072`.
1. prettier 3.9.9 `--write` on the 3 files: RC 0 (all unchanged).
2. eslint `--max-warnings 0` on the 3 files: RC 0.
3. `npx jest --runInBand test/scout/induction test/scout/s10/s10-unseen.e2e.spec.ts test/scout/reconciliation test/utils/g2-s11-db-guard.spec.ts --testPathIgnorePatterns '\.pg\.spec\.ts$'`: RC 0, **15 suites / 499 tests** (`logs/s12b2_r2_jest.log`).
4. Mutation control: I replaced the allow-list with a deny-list `!(v==='production'||v==='staging')` and ran jest on the spec. RC 1, **7 failed** (unset, empty, blank, prod, qa, develop, testing), 26 passed. I then restored from a backup (0 mutant lines).
5. Commit through the hooks (tsc included): RC 0 (`logs/s12b2_r2_commit.log`).
6. `rg -F -l s10_unseen src --type ts`: RC 1. Slug grep over the added src lines: RC 1.

Not run: PG lanes, `*.pg.spec.ts`, `rls-g2-*`, npm install, prisma generate.

sha256 at c516d463:
- `parse.ts` 6c8c1e790f1ea621e835b8df939d360d1227adc9852db64c6deb654d54e88842
- `manifest-registry.ts` ced166da74e1ec329d78f186c7cf2495da2c2d9dd9ef07ed3484d812bea4e147
- spec 6a3d67102d324ea39a6d00ec82e7e46aff601f5765bfbbd6068c4e3747b13c30

### Gate impact update
- **J20:** both `726d2227` and `c516d463` touch `src/`. The J20 re-pin (the parent's follow-up commit) must append **both** landed SHAs to `SLICE_COMMITS`. The D-S10-5 future baseline B is the landed r2 commit or later.
- **Round-1 C-4 is withdrawn.** Staging is still refused, but now through the allow-list, not `isProdLike`.
- **New C-7:** the lane NODE_ENV condition above. Record only.
