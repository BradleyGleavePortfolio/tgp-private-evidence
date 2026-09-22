# S3-R2-INTEGRATION-APPLICABILITY — integration analysis (revision 1)

Written 2026-09-22 ~04:55 UTC (Monday 2026-09-21 21:55 PDT). Role: integration analyst (requested Claude Fable 5; actual model/reasoning setting not exposed by the runtime and not claimed). Read-only Git ancestry/diff/merge-tree simulation and pinned prior reports only. No install, test, build, DB, network, commit, merge, push, or edit to any restored source. This is preparation for a parent integration judgment; it is **not** an independent audit, not a constructed candidate, and not clearance of anything. S3 remains accepted only within its bounded R2 scope.

## 1. Inputs verified

| Item | Result |
|---|---|
| S3 packet | `tgp-private-evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/`; `sha256sum -c SHA256SUMS.txt` → 34/34 OK; `SHA256SUMS.txt` itself `8646c0753c2ac566e420a863f180b85fee9827c6d3d524918269d82b116ca9fd` (matches packet README) |
| S3 bundle | `s3-backend-5c7b42b3.bundle` sha256 `940ce711a692b40325f3a1ad77aa0b1153cbfbad29c9fe8ef2a1a85b1c6f7b29`; `git bundle verify` OK; sole prerequisite `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` (public main, present in `source/backend`) |
| S3 restoration | isolated clone `initialization/recovered/s3-r2-5c7b` (no worktree link to `source/backend`), detached at **`5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06`, tree `83211d25d714e4c539cd3aa248a06ef0658fc8e7`**, `git status` clean; 23 commits over base, all author+committer `bradley@bradleytgpcoaching.com`, no co-author/signed-off/generated trailers; includes #524 head `238f0f1f` and #525 head `925780e0` |
| S2 bundle | `tgp-private-evidence/2026-09-21/remediation/s2-composition/b2-failed-and-r3-source/s2-composition-r3-d5cd9b8b-from-public-c23b9d9.bundle` sha256 `3b6cee481319dd518268b7573ebed142fa234e193b874d8712a6cdf5493c0f75` (matches `ARCHIVE_SHA256SUMS` line 92 and the operator-state advertised identity `3b6cee48…0f75`); `git bundle verify` OK |
| S2 restoration | isolated read-only clone `initialization/recovered/s2-r3-d5cd-readonly`, detached at **`d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c`, tree `c0ab87d4dc584b2a7ccad53db16fa551b93fe359`**, clean; 23 commits over base (S1 b7d7fe59→41f4d6a9→56fb0d22 merged in). S3 objects fetched into this clone under `refs/analysis/s3-5c7b` for diff/merge-tree only. Builder worktrees under `worktrees/` untouched. |
| Prior reports read | S3 revision-2 `REPORT.md`, `R1_DISPOSITIONS.md`, `PUBLICATION_MANIFEST.md`; R2 audit A `audits/s3-r2/a/revision-1/REPORT.md` (sha256 `8a6ef946a95312383f86e89d3caccedec1c9bbf50e0d777c204894a44c2a4139`, verdict: bounded CLEAR, closes S3-A-001…005/B-01…03, S3-R2A-001 nonmaterial); R2 audit B `audits/s3-r2/b/revision-1/REPORT.md` (sha256 `c13910f4f09f087d2d58dc9e7c66ecdc3ed751af3e17117a7933f876aaa11cee`, verdict: CLEARED (bounded) S3-lane, S3-R2B-01/02 nonmaterial); S2 `FROZEN_COMPOSED_SUCCESSOR.md`, `commits-r3.txt` |

## 2. Ancestry decision

- Merge base of `d5cd9b8b` and `5c7b42b3` is exactly public main `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`.
- `5c7b42b3` is **not** an ancestor of `d5cd9b8b`; neither `925780e0` (#525) nor `238f0f1f` (#524) is. `56fb0d22` (S1) is not an ancestor of `5c7b42b3`.
- **Neither candidate contains any of the other's source.** S3 is not "already in" the S2 composition; the operator state's "not yet included" is confirmed at the object level. S2 does, however, *reference* S3 by name (see §3.3 forward dependency).
- Both lineages are linear over the same base, so any composition is a genuine two-parent merge (or rebase) with the overlaps below; there is no partial-inclusion ambiguity.

## 3. Overlap analysis (paths, contracts, dependencies, config)

S2 changes 41 paths (+5062/−477), S3 changes 47 paths (+5385/−712). Full lists: `paths-s2-d5cd-vs-base.txt`, `paths-s3-5c7b-vs-base.txt`.

### 3.1 Textual path intersection: exactly two files

| Path | S2 change | S3 change | merge-tree result |
|---|---|---|---|
| `.github/workflows/ci.yml` | comment-only rewrite of the RLS job's schema-setup NOTE (lines ~206–210) | adds step `Lint control sources` in `build-and-test` after `Lint` (lines ~47–53) | **auto-merges cleanly**; hunks are disjoint and non-interacting; merged file contains both (verified in tree `0aa8a00a…`) |
| `.github/workflows/r100-quality-gate.yml` | retires jobs `loc-budget` and `test-density` (deleted), rewrites header comment to record the retirement and a "measurement scope" paragraph; leaves the inline `grep -c` banned-casts body unchanged | replaces the `banned-casts` job body with `node scripts/check-r75.js --mode=range --base --head` + setup-node + non-certifying `workflow_dispatch` + fail-closed missing base/head; rewrites header; **keeps** `loc-budget`/`test-density` untouched | **CONFLICT (content)**, both directions (`git merge-tree --write-tree d5cd9b8b 5c7b42b3` → tree `0aa8a00ab60aea5041d584824bb07b6fec0f58e6`, exit 1; reverse → `f25579b2…`, exit 1). Two hunks: header lines 6–23 and job tail lines 81–204 (S2 side = the single `echo "OK …"` line S3 replaced; S3 side = checker invocation plus the two whole jobs S2 deleted). Raw conflicted file preserved as `merge-tree-conflict-r100-quality-gate.yml`. |

Intended semantic resolution (not applied here): S3's `banned-casts` job body **must win** (S2's inline `grep -c` scan is the divergent second implementation S3's `r75-gate.spec.ts` and `r75-wiring.spec.ts` forbid); S2's retirement of `loc-budget`/`test-density` **must win** (S2's `delivery-artifact.spec.ts` asserts `jobIds == ['banned-casts']` and `setup-branch-protection.sh` no longer lists those checks); the header must be reconciled — S2's sentence "Measurement scope for the banned-cast diff: src/**, scripts/**, test/** … excluding … *.test.* / *.spec.* files" is **false** against S3's `.github/r75-policy.json` (test/spec sources are in scope, `excludeSuffixes: []`) and must point to the policy file instead. Check name `Banned cast tokens (R75 / R100.A2)` is unchanged on both sides, so S2's `REQUIRED_CHECKS` and `docs/delivery-controls.md` stay valid.

### 3.2 Semantic (non-textual) conflicts: two test files fail in any correctly resolved composed tree

These are attributable, concrete, and are the only source edits the composition needs beyond the conflict above.

| File | Owner side | Failing assertion in composed tree | Why | Smallest closure |
|---|---|---|---|---|
| `test/ci/r100-pathspec.spec.ts` | S2 modified (renamed one `it` title); S3 has base version | describe "R100 workflow guards against reintroducing the bare pathspec": `uses :(glob) directory file-globs (guard is not vacuous)` expects ≥1 `:(glob)…/**/` match in the workflow; `banned-cast scan covers scripts/**/*.js and src js/jsx` expects literal `:(glob)scripts/**/*.js'`, `:(glob)src/**/*.js'`, `:(glob)src/**/*.jsx'` | In S2's tree these literals live in the inline banned-casts body; in S3's tree only in `test-density` (lines 169–177; S3 removed them from banned-casts). A composed workflow with S3's checker body and S2's job retirement contains **zero** `:(glob)` occurrences. (In S3's own tree the spec passed only because `test-density` survived.) | Retarget the workflow-guard describe to `.github/r75-policy.json` (`scan.includeRoots` contains `src/`, `scripts/`, `test/`; `scan.includeExtensions` contains `.js`, `.jsx`) or delete it as superseded by S3's `r75-boundaries.spec.ts`/`r75-gate.spec.ts`. The first describe (git pathspec plumbing) is self-contained and can stay. |
| `test/ci/r75-gate.spec.ts` | S3 | `the LOC and density jobs keep their own measurement pathspecs`: expects `loc-budget:`, `test-density:` and `:(glob)scripts/**/*.js'` in the workflow | Written as an S3 ownership-boundary guard ("this repair touches the banned-casts job only"); S2 deliberately retired those jobs under G01/G08. | Delete that single `it` (its intent is already covered, inverted, by S2's `delivery-artifact.spec.ts` "has only the banned-casts job"). |

Verified **not** affected: S3 `r75-wiring.spec.ts` (loads only `jobs['banned-casts']`), S3 `r75-enforcement.spec.ts` (reads `ci.yml` steps + `dependency-audit.yml`; S2's ci.yml change is comment-only), S2 `delivery-artifact.spec.ts` r100 section (passes with the intended resolution: only `banned-casts` job id at two-space indent; S3 job body contains no `LOC-EXEMPT|TEST-EXEMPT|LOC_LIMIT|RATIO_MIN`), S2 `release-evidence-gate.spec.ts` (uses `ci.yml`/`dependency-audit.yml` as path constants against a fake `gh`).

### 3.3 Forward dependency: S2 already binds itself to S3's `dependency-audit.yml`

S2 `scripts/ci/release-evidence-gate.sh` line 54 defaults `REQUIRED_WORKFLOWS` to include `.github/workflows/dependency-audit.yml=npm audit (high+critical, whole graph)`, with the comment "composed from the S3 lane (job name as of its head 5c7b42b3). Until that workflow exists on main with this job name the gate fails closed on every release — intentional". `scripts/setup-branch-protection.sh` `REQUIRED_CHECKS` lists `"npm audit (high+critical, whole graph)"`; `docs/delivery-controls.md` §219–222 says "compose first, then release". S3 `.github/workflows/dependency-audit.yml` job `audit` has `name: npm audit (high+critical, whole graph)` — **exact match**. Consequence: S2's release path is *inoperable by design* until S3 is composed; S3 has no reverse dependency on S2 (all S3 tests pass on base+S3).

### 3.4 Dependency graph / lockfile

S2 leaves `package.json`, `package-lock.json`, `prisma/schema.prisma`, `jest.config.js`, `fly.toml` byte-identical to base. S3 pins all manifest ranges and changes the lockfile: 1151→1150 entries, 44 version changes, 20 added, 21 removed; **non-dev (production) closure 357→358 entries with 11 production version changes** (`body-parser`, `deepmerge-ts` 7.1.5→8.0.0, `form-data`, `hasown`, `js-yaml` 4.2.0→4.3.2, `multer` 2.1.1→2.3.0, `qs` 6.15.2→6.16.0, `side-channel`, `type-is`, `undici`, `ws` 8.20.1→8.21.0). Resolved toolchain versions are unchanged (`typescript` 5.9.3, `@types/node` 26.0.0, `@types/jest` 30.0.0, `jest` 30.4.2, `ts-jest` 29.4.9, `ts-node` 10.9.2), so S2's new spec files face the same compiler; still not evidence until run.

Release-command relevance: all 8 `prisma`-related lock entries (`prisma`, `@prisma/client`, `@prisma/engines`, `@prisma/config`, …) are identical (version + integrity + `devOptional`) between base and S3, so the S2 Dockerfile runtime-stage premise (`prisma` CLI retained under `--omit=dev` as dev-optional) still holds structurally. But `deepmerge-ts`'s **sole dependent is `@prisma/config`**, i.e. the `prisma migrate status/deploy` path that `scripts/release.sh` executes. A composed tree therefore changes the release_command's real dependency closure in exactly that transitive package (plus the unrelated prod bumps above). S3 proved the c12/deepmerge-ts@8 composition only under jest (`dependency-compatibility.spec.ts`, logs 08/10/14), never via `prisma migrate`; S2's B1/B2 ran real Prisma 6.19.3 with deepmerge-ts 7.1.5. The repo has no `prisma.config.*`, so the loader runs its defaults path; low risk, but it is a changed material input for any release.sh evidence (G09).

S2 `sbom.yml` header records a local observation "357 components, prisma CLI present" against the base lockfile; on the composed lockfile the production closure is 358 entries with different versions, so that observation is invalidated (the gate script itself is lockfile-agnostic and re-runs in CI).

### 3.5 Contracts and config

- `/readyz` body: S3 returns `{ok:true, db:'up', timestamp}` / 503 `{ok:false, db:'down', error:'database_unavailable', timestamp}`; S2 `fly-deploy.yml` "Readiness probe" asserts `jq -e '.ok == true and .db == "up"'` — **compatible** (S3 kept the base body; only the 3 s bound and timeout log event are new).
- `fly.toml`: S3 adds `[[http_service.checks]]` GET `/readyz` grace 30s / interval 15s / timeout 5s; S2 does not touch `fly.toml`, `auto_stop_machines='suspend'` stays from base. S3-A-017/B-10 (check activation semantics vs. suspend) and S3-A-011 (stranded query, connection-string bounds) remain S2/S1 release prerequisites exactly as both R2 auditors recorded; composition neither worsens nor closes them.
- Docker: S2 rewrites `Dockerfile` (two-stage, `npm ci --omit=dev` with lifecycle scripts, artifact assertions) and `.dockerignore` (excludes `.github/`, `test/`, `lefthook.yml`, `eslint.config.js`, `scripts/setup-branch-protection.sh`); S3 touches none of these and nothing S3 adds is needed at runtime. S3's local install used `--ignore-scripts` + explicit `prisma generate`; the Docker lifecycle path is untested by both lanes (both say so).
- S1-owned surfaces (`prisma/migrations/**`, `test/db/**`, generators): S3 changes none. `scripts/release.sh`, `scripts/ci/**`, `test/release/**`: S3 changes none.
- CI `Lint control sources` (S3 step inside `build-and-test`) lints `test/ci/r100-pathspec.spec.ts`, which S2 modified and which the composition will modify again → that step's S3 log 12 does not cover the composed file.

## 4. Overlapping ownership boundary (reported, not decided)

The R100 gate is co-owned de facto: S2 (delivery/governance) retired its volume jobs and edited `test/ci/r100-pathspec.spec.ts`; S3 (R75 checker) rewrote its banned-casts job and guards it with `test/ci/r75-gate.spec.ts`/`r75-wiring.spec.ts`. Three files need one writer during composition: `.github/workflows/r100-quality-gate.yml`, `test/ci/r100-pathspec.spec.ts`, `test/ci/r75-gate.spec.ts`. No other ownership overlap was found. This is a bounded, expected collision, not an architectural surprise; it is reported here so the parent assigns a single integration writer rather than letting S2 or S3 lanes edit each other's files.

## 5. Evidence applicability: what stays valid, what is invalidated

"Reusable" means the evidence's material inputs are unchanged in a composed tree **provided** the composition preserves the listed blobs (check: `git diff 5c7b42b3 <composed> -- <paths>` empty; blob ids in `s3-key-blobs-5c7b.txt`). It never means the composed head is attested — a new head needs its own applicability decision and two independent attestations (G09/G10).

| Retained evidence | Status for a composed S1+S2+S3 tree | Reason |
|---|---|---|
| R2 A/B source review of S3 `src/**` (health controller, filters, observability, scout, prisma.service, main.ts) and `fly.toml` | **Reusable** as source review of unchanged blobs | S2 touches no `src/**`, `fly.toml`, `jest.config.js`, `tsconfig*` |
| Log 16 readiness red (925780e0) / green (5c7b42b3); log 11 readiness trio 20/20 | **Reusable** | controller + specs + lockfile unchanged by S2 |
| Logs 08/14 c12 + deepmerge-ts@8 under jest; log 10 `dependency-compatibility.spec.ts` PASS | **Reusable** for the jest consumer path | lockfile unchanged by S2 |
| Log 15 `npm audit` 0 high/critical (2026-09-20T17:26Z) | **Reusable for the lockfile, time-dependent** | same lockfile; S3's `dependency-audit.yml` re-evaluates on every PR |
| Log 09 `tsc --noEmit` (CI heap) | **Invalidated** for composed head | composed `test/**` gains S2's `delivery-artifact.spec.ts`, `release-evidence-gate.spec.ts`, S2's `r100-pathspec.spec.ts` edit and the two composition test edits; also carries S3-R2B-01 (heap not stamped) |
| Log 12 control-source lint | **Invalidated** for `test/ci/r100-pathspec.spec.ts` and `test/ci/r75-gate.spec.ts` (composed files differ); reusable for the other five listed files | exact file bytes differ |
| Log 10 full default suite 545/12/0 | **Not transferable** as a suite result; targeted invalidation: `r100-pathspec.spec.ts` and `r75-gate.spec.ts` (known-failing until edited), `r75-wiring.spec.ts`, `r75-enforcement.spec.ts`, `delivery-artifact.spec.ts`, `release-evidence-gate.spec.ts`, `dependency-audit.spec.ts`, `fly-readiness.spec.ts` (read merged workflow/config text). S2's specs were never selected in S3's run and vice versa. | new head; workflow readers see merged text |
| Log 13 `nest build` | Reusable in the narrow sense that `tsconfig.build.json` covers `src/**` only and S2 changes no `src/**`; **not** a build-artifact claim — S2 changed `Dockerfile`/`.dockerignore` (G17) | |
| S3 log 04 `check-r75.js --mode=range c23b9d9f..5c7b42b3` OK | **Invalidated as a range result** for the composed range (S2's shell/spec additions are in R75 scope: `.sh`, `.ts` under `scripts/`, `test/`); trivially re-runnable offline (`node scripts/check-r75.js --mode=range --base=c23b9d9f --head=<composed>`) once `node_modules` exist | range changes |
| S2 `sbom.yml` local note "357 components" | **Invalidated** | production closure 358 entries / 11 version changes under S3 lockfile |
| S2 B1 (9742037b 63/4) / B2 (21ea3252 66/2) composition runs; pending B3 on d5cd | Bound to base lockfile (`deepmerge-ts` 7.1.5). For a composed tree the `release.sh` → `prisma migrate` path resolves `deepmerge-ts` 8.0.0 via `@prisma/config`. `prisma`/`@prisma/*` entries identical. **Bounded applicability**: S1/S2 SQL/guard/verifier behaviour unaffected (S3 changes no S1 path); the prisma CLI config-loader dependency is the one changed input. Do not claim B3 (when run on d5cd) proves the composed tree's release_command closure without one targeted `release.sh` step re-observation on the composed tree. | |
| Open cross-lane items S3-A-011/A-014/A-015/A-017, B-10/B-11/B-12, S3-R2A-001, S3-R2B-01/02 | **Unchanged** — composition neither closes nor worsens them; S2's `setup-branch-protection.sh` is still "NOT yet run" per its own docs | |

## 6. Minimal safe composition ordering

1. **Do not touch `d5cd9b8b` before the pending S1/S2 real proof (B3) and the S1 TRUNCATE discriminator.** The frozen runner pins `EXPECT_HEAD`, and the S1/S2 evidence chain is bound to tree `c0ab87d4…`. Composing S3 first would change the lockfile input of that proof and force a re-run of the heavy DB slot.
2. **S3 has no dependency on S2, but S2's release gate cannot pass without S3** (§3.3). Hence S3 composes *after* the S1/S2 proof, *before* any governed landing/release attempt. Merging S3 to public main on its own first is not recommended: it produces the identical conflict later against S2 and would land S3's `r100-quality-gate.yml` still carrying the volume jobs S2 retires.
3. Composition shape: one `--no-ff` merge of `5c7b42b3` into the S1+S2 trunk (`d5cd9b8b` or its frozen, proven successor if S2-RUNNER-53 changes product bytes — it is execution-only, so expected to be `d5cd9b8b`), resolving one file (§3.1) and editing two test files (§3.2). Alternative of rebasing 23 S3 commits onto d5cd would rewrite the preserved #524→#525 lineage and is not smaller.

## 7. Smallest explicit next integration slice (for parent dispatch; not executed here)

- **Slice**: S3-INTO-S1S2-COMPOSITION-1 (T4 — inherits S3's credential/PII diagnostics + S2's delivery boundary + shared R100 gate).
- **Writer surface**: new isolated worktree `worktrees/s3-composition` on branch `execute/2026092x-s3-into-s1s2`, plus `execution/s3-composition/`. Nothing else. No S1 paths, no `src/**` edits.
- **Exact inputs**: parent `d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c` (tree `c0ab87d4dc584b2a7ccad53db16fa551b93fe359`, restore from bundle `3b6cee48…0f75`), merge `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06` (tree `83211d25…`, bundle `940ce711…7b29`), identity Bradley Gleave author+committer, no trailers.
- **Edits (exactly three files)**: (1) resolve `.github/workflows/r100-quality-gate.yml` per §3.1 — S3 banned-casts body, S2 job retirement, header scope sentence replaced by a pointer to `.github/r75-policy.json`; (2) `test/ci/r100-pathspec.spec.ts` — retarget or drop the workflow-guard describe per §3.2; (3) `test/ci/r75-gate.spec.ts` — drop the single `it('the LOC and density jobs keep their own measurement pathspecs')`. Preferably the merge commit carries the resolution and a second small commit carries the two test edits, so the conflict resolution is inspectable on its own.
- **Meaningful targeted checks (offline first, then one bounded slot)**:
  - a. `git diff 5c7b42b3 HEAD -- src fly.toml package.json package-lock.json lefthook.yml eslint.config.js .github/r75-policy.json scripts/check-r75.js .github/workflows/dependency-audit.yml .github/workflows/danger.yml` → must be empty (S3 evidence blobs preserved; compare to `s3-key-blobs-5c7b.txt`).
  - b. `git diff d5cd9b8b HEAD -- prisma test/db scripts docs Dockerfile .dockerignore test/release .github/workflows/fly-*.yml .github/workflows/sbom.yml .github/workflows/codeql.yml` → must be empty (S1/S2 blobs preserved).
  - c. `git diff --name-only d5cd9b8b HEAD` minus S3's 47 paths → must be exactly `test/ci/r100-pathspec.spec.ts` (and nothing else); `git diff --name-only 5c7b42b3 HEAD` minus S2's 41 paths → exactly `test/ci/r75-gate.spec.ts` plus the merged `r100-quality-gate.yml`.
  - d. YAML parse of the merged `r100-quality-gate.yml` and `ci.yml`; `node scripts/check-r75.js --mode=range --base=c23b9d9f --head=HEAD`.
  - e. Under a granted bounded slot after `npm ci --ignore-scripts` + `prisma generate` (S3's documented install): jest on exactly `test/ci/r100-pathspec.spec.ts test/ci/r75-gate.spec.ts test/ci/r75-wiring.spec.ts test/ci/r75-enforcement.spec.ts test/ci/r75-boundaries.spec.ts test/ci/delivery-artifact.spec.ts test/ci/release-evidence-gate.spec.ts test/ci/dependency-audit.spec.ts test/ci/fly-readiness.spec.ts`; `NODE_OPTIONS=--max-old-space-size=4096 npx tsc --noEmit -p tsconfig.json` with the env stamped in the log header (also closes S3-R2B-01 for the composed head); the CI `Lint control sources` command. Expected: all pass; any failure outside the three edited files is a new finding, not a retry.
  - f. Not requested now: full default suite, build, Docker, Fly, DB. Those run as the ordinary CI/release gates on the composed head, and the S1/S2 `release.sh` re-observation from §5 belongs to the composition proof owner, not to this slice.
- **Then**: two independent non-author exact-head attestations of the composed head (T4), scoped to the three edited files plus applicability of §5, per the brief. This analysis does not substitute for either.
- **Recovery**: `5c7b42b3` and `d5cd9b8b` bundles untouched; composed head published as an incremental bundle from `c23b9d9f` with a non-self-including SHA256SUMS.

## 8. What this analysis does not establish

S3 landed or composed; the composed tree's runtime behaviour; Docker/Fly/hosted behaviour (`auto_stop_machines='suspend'` × new http check, stranded `$queryRaw`, branch-protection wiring — all still open S1/S2 prerequisites); release readiness; any new audit clearance for S3 or S2. Local restorations are analysis copies only and must not be used as builder worktrees.

## 9. Artifacts in this directory

`REPORT.md` (this), `analysis.json` (machine-readable facts), `merge-tree-conflict-r100-quality-gate.yml` (raw conflicted file from tree `0aa8a00a…`), `merge-tree-d5cd-into-5c7b.raw.txt`, `paths-s2-d5cd-vs-base.txt`, `paths-s3-5c7b-vs-base.txt`, `s3-key-blobs-5c7b.txt`, `SHA256SUMS.txt` (excludes itself).
