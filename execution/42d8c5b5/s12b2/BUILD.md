# S12-B2 build report (rebuild): test-only manifests refused outside explicit development/test (T3, EXEC-42D8C5B5)

Grant `s12b2/GRANT.md`; rules `WORKER_RULES.md`. Rebuilt from the durable reviewed-GO design
(`fa72efb2/s12b2/s12b2_build.md` r1+r2, `s12b2_review.md` r2 GO); predecessor objects 726d2227/c516d463 are absent from
`repos/backend` (checked `git cat-file`), and `ls-remote preserve refs/heads/cand/*` was empty before my push.

## Head / tree / ref
- Clone `/home/user/workspace/worktrees/x42-s12b2` (standalone `git clone --no-hardlinks /home/user/workspace/repos/backend`),
  branch `x42/s12b2`, origin push `no_push://disabled`, remote `preserve` added. node_modules `cp -al` from x42-donor after
  sentinel `RC=0 STAGE=done`; `lefthook install` RC 0.
- Base `54be96f18c314cae35d1e5d3000af9f06d693d81` (origin/integration/importer).
- **HEAD `ec96d9bbfae59a94966692301dd81eb17097ed6f`, tree `1a56c52a264127c0177edbbb78889eac327175fc`**, one commit, through hooks
  (R75, eslint, prettier, tsc, prod-readiness-quick, no-ai-tokens), author = committer = Bradley Gleave
  <bradley@bradleytgpcoaching.com>, no trailers. Working tree clean.
- **Pushed `refs/heads/cand/x42/s12b2` = `ec96d9bbfae59a94966692301dd81eb17097ed6f`** (`git ls-remote` confirmed). No other remote write.

## Design (equals reviewed r2)
- Data marker: `"testOnly": true` (manifest), `"test_only": true` (verifier). Must be literally `true` (else throws in every mode);
  removed before `assertKeys`, so `contract.ts` / `MANIFEST_KEYS` / `VERIFIER_KEYS` unchanged (git diff RC 0).
- `parse.ts` L294-352 marker constants, `takeTestOnly`, `parseVerifier` → `{verifier,testOnly}`; L363-376
  `parseInductionManifestForRuntime(raw, origin, refuseTestOnly)`: full validation first; refuse → `null` for marked manifest,
  marked verifiers filtered (frozen); L378+ `parseManifest` (old body). `parseInductionManifest` signature/result unchanged.
- `manifest-registry.ts` L28-37 exported allow-list `testOnlyArtifactsAllowed(nodeEnv)` = trimmed lower-case
  `development|test`; L44-47 `loadInductionManifests(dir, refuseTestOnly = !testOnlyArtifactsAllowed(process.env.NODE_ENV))`;
  filename + duplicate checks as before, then runtime parse, nulls filtered. Unset/blank/unknown NODE_ENV refuses. `isProdLike`
  untouched.
- Refusal effect (existing closed paths, no vocabulary change): no package → `observation_not_declared` on upload and
  `{known:false}` for every declared family in `evaluateCoverage`; dropped key → evidence never verifies → unknown.
- Data: shipped `src/scout/induction/sources/s10_unseen.json` L4 `testOnly`, L16 `test_only`.
- Spec `test/scout/induction/test-only-exclusion.spec.ts` (new, 40 tests): unmarked positive control in both modes; manifest
  and verifier refusal with discriminating evaluator results (PROVEN 3 known vs all unknown on identical evidence); marker stripped
  and input not mutated; default loader refuses for 13 values (unset, '', '   ', production, PRODUCTION, 'Production ', staging,
  Staging, prod, qa, ci, develop, testing) and loads for test, development, TEST, ' Development '; jest NODE_ENV=test; strict
  marker values; per-object casing; validation before refusal (version, filename, alg); shipped data (every shipped verifier whose
  key is committed in any `test/fixtures/**/signer-test-key.json` is marked; refusing shipped loader trusts no committed key and the
  registry still builds with shipped specs/rule sets); no slug in touched src; harness/worker/bootstrap (10 files) never mention
  NODE_ENV and both PG harness forks spread `...process.env`.

sha256 @ec96d9bb: parse.ts 7b75d472…cb375; manifest-registry.ts 564b8dce…f35d2; s10_unseen.json 6c905c74…85b3f;
spec acb35846…0d730.

## LOC (`git show --numstat`)
parse.ts +71/-5, manifest-registry.ts +46/-24, s10_unseen.json +3/-1, spec +413/-0 (total +533/-30).
Prod .ts code lines (excl. comment/blank): +85/-27 (manifest-registry churn is prettier re-indent of the `.map(...).filter(...)` chain).

## Commands (RC). Heavy ones under `flock -w 3600 /home/user/workspace/execution/test-validation.lock` (inode 657581), NODE_OPTIONS=--max-old-space-size=3072, nohup setsid. Logs in `s12b2/logs/`.
1. prettier 3.9.9 (runtime tool) `--write` 4 files: RC 0.
2. eslint `--max-warnings 0` parse.ts, manifest-registry.ts, spec: RC 0.
3. `tsc --noEmit`: RC 0 (`logs/tsc.log`).
4. jest `--runInBand --runTestsByPath test/scout/induction/test-only-exclusion.spec.ts`: RC 0, 40/40 (`logs/jest1.log`).
5. Mutation M1 (allow-list → deny-list production|staging): RC 1, 8 failed (unset, '', blank, prod, qa, ci, develop, testing).
   M2 (never refuse): RC 1, 16 failed. Both restored; sha256 of files = backups (`logs/restore.log`).
6. jest `--runInBand test/scout test/utils/g2-s11-db-guard.spec.ts --testPathIgnorePatterns '\.pg\.spec\.ts$'`: RC 0,
   71 suites, 1800 passed / 5 skipped (`logs/jest_broad.log`). Includes all test/scout/induction and registry suites.
7. `git commit` (hooks, under flock): RC 0 (`logs/commit.log`). A first queued commit attempt died without output or commit
   (nohup process vanished while waiting on the lock); re-queued via a script, succeeded.
8. `rg -F -l s10_unseen src --type ts`: RC 1. Added src .ts lines vs slugs (s10_unseen|s11_second|truecoach|conformance|u10_): RC 1.
9. `scripts/s10-core-diff-gate.sh 54be96f1 HEAD`: RC 1, FAIL check 3 (core files outside the new-source allowed set) — expected
   for a reviewed core change; script unchanged (`logs/gate.log`).
Not run: any PG lane, `*.pg.spec.ts`, `rls-g2-*`, npm install/ci, prisma generate.

## PG lanes the parent must run (parser path; NODE_ENV unset or `test`)
- Required: `test/scout/s10/s10-unseen.pg.spec.ts` (D2; in-process default loader) and
  `test/scout/s11/journey-induction.pg.spec.ts` (S11-A2 J09-J11; worker `...loadInductionManifests()`).
- Recommended (S11 worker also builds the default induction registry): `test/scout/s11/journey-core.pg.spec.ts`,
  `readiness.pg.spec.ts`, `settle-redrive.pg.spec.ts`.
- Condition: a lane that exports NODE_ENV other than development/test (e.g. `''`, `ci`) will refuse the marked manifest and fail
  closed (red), not open.

## Gate impact / re-pin
- D-S10-5: historical pins (B=7fdcbc04, GATE_HEAD=275e458c) unaffected; future new-source runs must use B ≥ landed ec96d9bb.
- J20 (`journey-full.pg.spec.ts` SLICE_COMMITS walk) is NOT in this base (S11-D not in integration/importer@54be96f1). If S11-D
  lands with the `3db615c0^..HEAD` walk, ec96d9bb must be appended to SLICE_COMMITS in a companion commit (or S11-E range end).

## Deviations from the reviewed design
- One commit (r1+r2 folded) instead of two; line numbers differ (different base, 54be96f1 vs aed23289).
- Spec 40 tests vs 33: added `ci` refusal case, input-not-mutated case, key-level validation-before-refusal case; harness guard
  covers 10 files (adds both bootstrap .sh) vs 8; committed-key detection walks all `test/fixtures/**/signer-test-key.json`.
- Behaviour identical to r2 (allow-list, parameter polarity, marker names, null/filter semantics).

## Findings
No A/B.
- C-1 mapping specs/native rules of a test-only source still load everywhere (no trust; reviewed C4).
- C-2 refusal is by omission + existing `observation_not_declared`; no boot log/reason code (closed vocabulary).
- C-3 a deployment deliberately set to NODE_ENV=test/development still loads test-only artifacts (reviewed C8).
- C-4 two shipped-data `>0` assertions require a marked committed-key manifest to remain shipped.
- C-5 the lefthook prettier step runs `npx prettier`, which fetched prettier@3.9.9 into the npx cache (not the clone) during commit.
