# S2 delivery — candidate handoff (frozen for dual independent audit)

Written 2026-09-20 17:05 UTC; updated 17:35 UTC; **corrected 17:50 UTC under user override: R1 `b801a776` is the only candidate. Two post-freeze commits made before the override (`4a63b8ae`, `cb0bc910`) are HELD, not part of the candidate — branch `execute/20260920-s2-delivery` reset to `b801a776`; held work preserved on local branch `s2-post-r1-held` + bundle. No fixers started.** Status: **NEW candidate, written + focused-tested locally; NOT audited, NOT merged, NOT deployed, NOT enabled, NOT customer-accepted.** No historical audit inheritance (Agent83 `30bc89ea` not recovered; S0 closed per parent).

## Exact identity
- Repo: `BradleyGleavePortfolio/growth-project-backend`; worktree `/home/user/workspace/worktrees/s2-delivery`; branch `execute/20260920-s2-delivery`
- Base (main): `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` (tree `842f17f78cb0f2ac2233a2bfd3728a9788b1cd06`)
- **Frozen candidate head: `b801a776558d18acea2d03f19029f0ea85ffca39`, tree `f24e871b82d00a3bb6b78488b495d67c631793ae`** (1 commit over main; local tag `s2-r1-frozen`; branch `execute/20260920-s2-delivery` points here)
- Author and committer: `Bradley Gleave <bradley@bradleytgpcoaching.com>` (verified with `git var`); no co-author trailer (same for the held commits)
- Bundles in `/home/user/workspace/execution/s2-delivery/`: `s2-delivery-r1.bundle` (candidate, `main..b801a776`); `s2-post-r1-held.bundle` (held work, head `cb0bc910` tree `8222bdd7`, ref `refs/heads/s2-post-r1-held`); `s2-delivery-r1.2.bundle` (same held head, earlier name). All `git bundle verify` ok.
- **Held (NOT candidate) work, for disclosure — changes already made before the override, 5 files, +86 lines over R1:**
  - `4a63b8ae` — `release-evidence-gate.sh` step 5: reads `repos/<repo>/environments/<REQUIRED_ENVIRONMENT>` and fails unless a `required_reviewers` rule with ≥1 reviewer exists and `can_admins_bypass == false`; `fly-deploy.yml` passes `REQUIRED_ENVIRONMENT: production` (must equal the deploy job's `environment.name`; structural test added). Reason: GitHub auto-creates an unprotected environment on first reference, so a dispatch before hosted settings exist would otherwise skip the human step. Manifest gains `environment`. +6 negatives (no rule / empty reviewers / wait_timer only / admin bypass / 404 / env selector).
  - `cb0bc910` — `sbom.yml` also triggers on `pull_request: [main]` so `build-sbom` can be a required PR check; gate still only accepts push/dispatch/schedule main runs. +1 structural test.
- Grade/model requested: T4 (trusted-gate change), Claude Fable 5, High

## Changed files (14) and why
| File | Change |
|---|---|
| `.github/workflows/fly-deploy.yml` | `push: main` trigger removed. `workflow_dispatch` only, inputs `release_sha` (required) + `confirm: "deploy"`. Job `evidence-gate` (`if: github.ref == 'refs/heads/main'`, perms `actions: read`, `security-events: read`) runs `scripts/ci/release-evidence-gate.sh` and uploads `release-evidence-<sha>`. Job `deploy` `needs: evidence-gate`, `if: result == 'success' && outputs.release_sha == github.sha`, `environment: production`, checks out the sha and asserts `HEAD == sha`, `flyctl deploy --image-label sha-<sha> --build-arg RELEASE_VERSION/GIT_SHA=<sha>`, then `flyctl machines list --json` → `scripts/ci/verify-fly-release.sh`, `/readyz` probe, uploads `release-manifest-<sha>` (always). No `continue-on-error`, no `|| true/echo`. |
| `scripts/ci/release-evidence-gate.sh` (new) | Fail-closed gate. Requires: 40-hex sha == `DISPATCH_SHA`; for each of `ci.yml` (jobs build-and-test, rls-floor-guard, rls-live-tests, mwb-3-live-tests), `codeql.yml` (`CodeQL JS/TS (javascript-typescript)`), `sbom.yml` (`build-sbom`): the **newest** run with `head_sha == sha`, `repository` and `head_repository == GH_REPO`, event ∈ {push, workflow_dispatch, schedule}, `head_branch == main`, is `completed/success` and every listed job is `completed/success`; a code-scanning analysis with `commit_sha == sha` and tool CodeQL exists; artifact `sbom-cyclonedx-<sha>` on the SBOM run is non-expired, downloads, is CycloneDX with >0 components. Any `gh api` error → exit 1. Writes manifest `release-evidence-<sha>.json` (runs, analysis id, SBOM sha256, `image: null`). |
| `scripts/ci/verify-fly-release.sh` (new) | Reads Fly machines JSON; all started `app` machines must have `image_ref.tag == sha-<sha>`, `image_ref.labels.GH_SHA == sha`, a well-formed `sha256:` digest, and one converged digest; appends `image {ref,digest,tag,machines}` to the manifest. Field shape taken from the parent's read-only Fly Machines observation (`execution/FLY_RUNTIME_METADATA.md`). |
| `.github/workflows/codeql.yml` | Removed `continue-on-error: true` and the "Validate CodeQL outcome" GHAS-fallback step; checkout pinned to the repo's v6.0.3 sha. Triggers unchanged. |
| `.github/workflows/sbom.yml` | `npm ci --omit=dev --ignore-scripts` (fixes exit 127 from `prepare: lefthook install`, run 34404749261); SBOM via `npm sbom` from the installed tree (devDependencies dropped from a manifest copy to avoid `ESBOMPROBLEMS`); `scripts/ci/assert-prod-sbom.sh` must pass before upload; uploads `sbom.cdx.json` + `.sha256`, `if-no-files-found: error`, `persist-credentials: false`. cdxgen dependency removed. |
| `scripts/ci/assert-prod-sbom.sh` (new) | Proves CycloneDX, >0 components, no name@version that exists in the lockfile only as `dev: true`, none of jest/ts-jest/ts-node/@nestjs/cli/@nestjs/testing/eslint/typescript-eslint/lefthook/danger/@cyclonedx/cdxgen/supertest, and `@nestjs/core`, `@prisma/client`, `prisma` present. Emits sha256. |
| `Dockerfile` | Multi-stage. `build`: as before (full `npm ci`, prisma generate, nest build, Sentry upload with build secret). `runtime`: `package*.json`, `prisma/`, `scripts/release.sh`, `npm ci --omit=dev` (lifecycle scripts kept so Prisma engines/client are produced), `COPY --from=build /app/dist`, build-time assertion: `prisma`, `@prisma/client`, `@nestjs/core` resolve; jest, ts-jest, ts-node, @nestjs/cli, @nestjs/testing, eslint, lefthook, danger, supertest absent; `dist/main.js`, `prisma/schema.prisma`, `prisma/seed-diagnostic.json`, `scripts/release.sh` exist. No `NODE_ENV`, no `USER` change. |
| `.dockerignore` | Excludes `.git/ .github/ test/ docs/ *.md lefthook.yml jest/eslint/babel configs dangerfile.js prod-switches.yml scripts/setup-branch-protection.sh scripts/secrets/ .env*` etc. Runtime-read paths kept (`prisma/`, templates under `src/`). |
| `.github/workflows/r100-quality-gate.yml` | Jobs `loc-budget` ("LOC budget (R100.A3)") and `test-density` ("Test density (R100.A1)") deleted; `banned-casts` untouched; header rewritten. **T4 trusted-gate change.** |
| `scripts/setup-branch-protection.sh` | `REQUIRED_CHECKS`: −LOC budget, −Test density, +`CodeQL JS/TS (javascript-typescript)`; comment block replaces the "second PAT as reviewer" decision with the G05/G10 position; stale "CodeQL not present" note removed. Script not run. |
| `test/ci/release-evidence-gate.spec.ts`, `test/ci/fixtures/fake-gh.sh` (new) | 25 cases through a fake `gh`: passing world + manifest; newest-wins; short sha; sha≠dispatch; missing run; stale sha; newer-failed-after-older-success; in_progress; cancelled/skipped/neutral/timed_out; fork head repo; pull_request event; non-main branch; same-name other path; skipped job; missing job; weakened required list (SBOM dropped); empty list; no analysis for sha; code-scanning API error; SBOM artifact missing / other sha / expired / zero components / download failure; runs API error. |
| `test/ci/delivery-artifact.spec.ts` (new) | 27 cases: workflow structure invariants (no push trigger, needs/if/environment, no continue-on-error/fallbacks, sha-bound build args; CodeQL fail-closed; SBOM install/generate/prove order; R100 only banned-casts; protection script list), Dockerfile/.dockerignore shape, `verify-fly-release.sh` negatives (stale tag, GH_SHA mismatch, none started, two digests, bad digest, non-array), `assert-prod-sbom.sh` negatives (dev-only leak, explicit tool, prisma missing, zero components, non-CycloneDX). |
| `test/ci/r100-pathspec.spec.ts` | One test title renamed (asserted strings still present in `banned-casts`). |

## What ran (all on this sandbox, node v20.20.1 / npm 10.8.2, 2 vCPU)
- `npm ci --ignore-scripts --no-audit --no-fund` in worktree (heavy lock; log `/tmp/s2-npm-ci.log`, exit 0).
- `npx jest test/ci/release-evidence-gate.spec.ts` → 25/25 pass (`/tmp/s2-gate-test.log`, 105 s under CPU contention).
- `npx jest test/ci/delivery-artifact.spec.ts` → 27/27 pass at R1; `test/ci/r100-pathspec.spec.ts` → pass (`/tmp/s2-delivery-test.log`).
- On the held head `cb0bc910` only: `release-evidence-gate.spec.ts` 31/31 + `delivery-artifact.spec.ts` 29/29 pass (`/tmp/s2-r2-test.log`). Not part of the candidate.
- **Empirical `--omit=dev` proof** in `/tmp/s2-omit` (package.json + lockfile only; heavy lock; `execution/s2-delivery/local-omit-dev-npm-ci.log`): `npm ci --omit=dev --ignore-scripts` installed 357 packages; **present:** prisma (CLI, `.bin/prisma`), @prisma/client, @prisma/engines, @nestjs/core, typescript (dev-optional); **absent:** jest, @nestjs/cli, @nestjs/testing, eslint, lefthook, ts-jest, ts-node, danger, supertest. `npm sbom` on that tree (after dropping devDependencies from the manifest copy) → 357 components; `assert-prod-sbom.sh` PASS, sha256 `f044ef01…c0edf` (`execution/s2-delivery/local-omit-dev-sbom.cdx.json`). First attempt flagged nested dev copies of mime-db/mime-types/source-map as leaks → script fixed to treat name@version as dev-only only when no production lockfile entry has it.

## What did NOT run / known limits (explicit)
- **Docker image not built** (no Docker here). Multi-stage Dockerfile is verified structurally and by the `--omit=dev` proof only; the build-time assertion RUN is the runnable artifact check and would first execute on Fly's remote builder. Do not treat the production image as certified.
- **Workflows not executed on GitHub** (no push). `actions/download-artifact@v4` is tag-pinned (no sha available offline); `superfly/flyctl-actions/setup-flyctl@master` unchanged from main.
- `flyctl machines list --json` field names (`image_ref.tag/digest/labels.GH_SHA`, `config.metadata.fly_process_group`) are inferred from the parent's Machines API read, not from a live flyctl run.
- `GITHUB_TOKEN` reading `environments/production` needs `actions: read` on a private repo (declared on the gate job); not exercised live.
- `GITHUB_TOKEN` must be allowed to read code-scanning analyses (`security-events: read` is declared; if GHAS/code scanning is unavailable the gate fails closed by design).
- No shellcheck/actionlint locally; `bash -n` only.
- Full jest suite, lint, build not run by S2 (S3 lane).

## Deterministic new invariants (audit targets)
1. Nothing deploys on push; only `workflow_dispatch` from `main` with `release_sha == github.sha`.
2. `deploy` cannot run unless `evidence-gate` concluded success for that same sha.
3. Evidence must be for the exact sha, from this repository, on main, non-PR event, newest run, every required job success; absence/skip/in-progress/stale/fork/API error → fail.
4. CodeQL = uploaded analysis for the sha, not just a green job; CodeQL workflow itself can no longer pass on analyze failure.
5. SBOM artifact is produced only from a lifecycle-free `--omit=dev` tree that provably contains no dev-only package and does contain the prisma CLI; gate re-downloads and re-checks it.
6. Runtime image build fails if dev tooling is present or the prisma CLI / dist / release inputs are missing.
7. R100 no longer enforces LOC or test-density quotas; banned-casts unchanged.
8. *(held, not in candidate)* environment-protection precondition in the gate — see held commit `4a63b8ae`. **R1 limitation this exposes:** the R1 gate does not check that `production` is protected, so a dispatch before the hosted settings exist would auto-create an unprotected environment and skip the human step; ordering in `LANDING_PROPOSAL.md` §0–1 is the only R1 mitigation.

## Open material findings (not fixed here)
- Hosted controls still absent: main unprotected, rulesets `[]`, only environment `noble-celebration / production` (no reviewers, admin bypass). Proposal written: `execution/s2-delivery/LANDING_PROPOSAL.md` (ordering: protect env → ruleset with `integration_id`-bound checks → landing PR by Bradley → first gated dispatch). No API writes performed.
- Single collaborator (Bradley): any `required_approving_review_count ≥ 1` needs a second real human; no second identity will be fabricated.
- `h4-readiness.yml` `deploy-readiness-gate` (strict) is not in the deploy path and is not required by the gate (would need production secret wiring to pass); listed as an option in the proposal.
- Runtime image still runs as root (unchanged); `@scarf/scarf` postinstall telemetry still runs in the runtime-stage install (unchanged behaviour).
- `fly.toml` still carries `[build.args] GIT_SHA = ""`; workflow now passes it explicitly.
- Historical: current production machine runs image labelled GH_SHA `5076a07a` (ancestor of main), deployed 2026-09-18 outside any gate — source/image equivalence not attested.

## Dependency / ownership
- No edits to package.json/lockfile, prisma, src. S3's preserved #525 head `925780e0` touches `r100-quality-gate.yml` (banned-casts rewritten to `scripts/check-r75.js` + policy JSON), `ci.yml` (+lint step), `danger.yml`, `dependency-audit.yml`, `fly.toml` (`/readyz` http check), `lefthook.yml`; it does not touch fly-deploy/codeql/sbom/Dockerfile/.dockerignore. Composition on the integrated head: take #525's `banned-casts` job + this candidate's removal of `loc-budget`/`test-density` (header conflict only); on that head `test/ci/r100-pathspec.spec.ts`'s three `toContain(':(glob)…')` assertions must be re-pointed (the pathspecs move to `.github/r75-policy.json`). #525's `/readyz` Fly check is compatible with the post-deploy probe here.

## Cross-lane (S3 auditor B)
S3-B-10 (Fly readiness activation evidence), S3-B-11 (R75 policy from candidate head → hosted composition), residual pool risk: disposition and dependencies recorded in `execution/s2-delivery/CROSS_LANE_DISPOSITION.md`; no source/hosted change made. Proposal addition: `.github/r75-policy.json` and `scripts/check-r75.js` join the review-required path set.

## Smallest next action
Await both R1 audit reports on `b801a776`. S2 makes no further worktree, source, test or harness changes (user override). If a Docker-capable runner appears later, build the image once to exercise the runtime-stage assertion.
