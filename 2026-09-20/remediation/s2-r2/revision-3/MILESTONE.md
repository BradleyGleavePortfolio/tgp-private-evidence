# S2 delivery — early milestone (architecture/boundaries understood)

Time: 2026-09-20 16:20 UTC (09:20 PDT); timestamp corrected from an earlier misestimate. Worktree `/home/user/workspace/worktrees/s2-delivery`, branch `execute/20260920-s2-delivery`, base = main `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` (tree `842f17f78cb0f2ac2233a2bfd3728a9788b1cd06`). Repo-local identity verified via `git var`: author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`.

## Recovery status (S0 dependency)
Agent83 delivery commit `30bc89ea…` (tree `8c598d9`, parent `9c6826`) is absent from every local repo and from GitHub (422) per `evidence/backend-recon.md §0`. No recovered delivery lineage exists to inspect. Everything below is a **new, explicitly labelled candidate** built from current main; it does not claim equivalence to, or inherit audits from, the Agent83 work. PDF-described findings are preserved as findings, not as cleared.

## Confirmed current-source defects (all reproducible at c23b9d9f)
| ID | Defect | Source |
|---|---|---|
| D1 | `fly-deploy.yml` deploys on `push: main` with no `needs:`/`workflow_run`/`environment:` — merge == deploy, independent of CI/CodeQL/SBOM | `.github/workflows/fly-deploy.yml` L4–12 |
| D2 | CodeQL `analyze` has `continue-on-error: true`; validation step defaults GHAS lookup to `disabled` on any API error and exits 0 → fail-open | `codeql.yml` L46, L66–73 |
| D3 | The observed SBOM run for the current main head (34404749261, Sep 9) failed at `npm ci --omit=dev` because `prepare: lefthook install` runs (exit 127); no successful SBOM artifact is known for `c23b9d9f` (full run history not established) | `sbom.yml` L33; run 34404749261 |
| D4 | Production image = single-stage `npm ci` (all devDependencies) + `COPY . .` with a 4-line `.dockerignore` → tests, docs, `.git`, `.github`, jest/eslint/nest-cli/lefthook/ts-node in the runtime artifact | `Dockerfile`, `.dockerignore` |
| D5 | `main` unprotected (404), rulesets `[]`; environment `noble-celebration / production` has no protection rules and `can_admins_bypass: true`; `fly-deploy.yml` does not even reference that environment | `evidence/backend-protection.json`, `backend-rulesets.json`, `backend-environments.json` |
| D6 | `r100-quality-gate.yml` still enforces generic LOC (400) and test:src (2.0) volume quotas retired by G01/G08; `scripts/setup-branch-protection.sh` lists them as required and recommends a second PAT as "reviewer" (forbidden by G05/G10) and says CodeQL does not exist (stale) | `r100-quality-gate.yml`, `scripts/setup-branch-protection.sh` |

Fact preserved: main CodeQL run 34836630579 (Sep 14) **did** analyze and `Successfully uploaded results` (`evidence/backend-codeql-latest.log` L6258). The defect is the fallback branch, not the current upload.

## Candidate design (smallest fail-closed set, in-repo only)
1. **Deploy authorization gate** — `fly-deploy.yml` loses `push: main`; becomes `workflow_dispatch` with a required exact 40-hex `release_sha` input and declares `environment: production` (so hosted required-reviewer rules can bind). New job `evidence-gate` (runs before `deploy`, `needs:`) executes `scripts/ci/release-evidence-gate.sh`, which fails closed unless, for that exact SHA: it is an ancestor of `origin/main`; every required check-run (CI `build-and-test`, `rls-live-tests`, `mwb-3-live-tests`, CodeQL `CodeQL JS/TS (javascript-typescript)`) exists, is `completed` with conclusion `success` (skipped/neutral/missing/in-progress/stale-other-sha all fail); the check runs came from this repository (not a fork head); a CodeQL analysis with `commit_sha == release_sha` exists via the code-scanning API; and a `sbom-cyclonedx-<sha>` artifact exists, is not expired, and came from a successful SBOM run on that sha. Any API error → exit 1 (no `|| echo disabled`).
2. **CodeQL fail-closed** — remove `continue-on-error` and the GHAS-fallback step.
3. **SBOM** — `npm ci --omit=dev --ignore-scripts`; assert component count > 0; assert no package that is devDependency-only (per lockfile) appears in the SBOM; emit `sbom.cdx.json` + `sha256` bound to `github.sha`.
4. **Production artifact** — multi-stage Dockerfile: build stage compiles; runtime stage `npm ci --omit=dev` (lockfile shows `prisma` CLI is `devOptional`, i.e. retained under `--omit=dev` because it is an optional peer of `@prisma/client`, so `scripts/release.sh` keeps working); runtime stage asserts at build time that the prisma CLI resolves and that jest/@nestjs/cli/eslint/lefthook/ts-node/danger are absent. `.dockerignore` excludes `.git`, `.github`, `test`, `docs`, `*.md`, coverage. I cannot run Docker here — verification is lockfile-based plus a local `npm ci --omit=dev --ignore-scripts` proof and a deterministic Dockerfile-structure test.
5. **R100** — retire `loc-budget` and `test-density` jobs; keep `banned-casts` (concrete quality check). Update `scripts/setup-branch-protection.sh` check list and delete the second-PAT advice. **T4 trusted-gate change; flagged for both auditors.**
6. **Focused tests** in `test/ci/` (default jest lane): gate-script negatives against a fake `gh` (missing / skipped / in-progress / stale-other-sha / fork / API-error / no SBOM / expired artifact / non-ancestor / malformed sha), workflow-structure invariants (no `push:` trigger on deploy, no `continue-on-error` in codeql, `--ignore-scripts` in sbom), Dockerfile/.dockerignore invariants.

Landing proposal (hosted settings, reviewer/identity) goes to `execution/s2-delivery/LANDING_PROPOSAL.md` — no API writes.

## Ownership/dependency notes
- No package.json/lockfile, schema, generator, or `src/` writes planned.
- The landing itself is blocked on the identity question: only Bradley is an observed collaborator; `required_approving_review_count ≥ 1` with `enforce_admins` cannot be satisfied by a single identity without a bypass, and a second PAT is not a reviewer (G05/G10). Proposal will lay out the identity-compatible options for Bradley's decision.

Heavy step planned: one `npm ci --ignore-scripts` under `execution/heavy-validation.lock` to run the focused jest tests and the `--omit=dev` proof.
