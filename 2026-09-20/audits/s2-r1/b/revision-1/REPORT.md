# S2 delivery — independent audit B, round 1 (T4)

Written 2026-09-20 ~17:25 UTC by independent auditor B. Model requested: Claude Fable 5, High (actual reasoning setting not exposed by the tool; not claimed). No peer report read; no coordination.

## Identity reviewed

| Item | Value |
|---|---|
| Repository | `BradleyGleavePortfolio/growth-project-backend` |
| Snapshot worktree | `worktrees/audit-s2-r1` (read-only) |
| Base (main) | `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` |
| **Head audited** | **`b801a776558d18acea2d03f19029f0ea85ffca39`** |
| Tree | `f24e871b82d00a3bb6b78488b495d67c631793ae` |
| Diff vs base | 14 files, +1252/−284 (matches builder report) |
| Commit identity | author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no co-author trailer (verified with `git log --format`) |
| Bundle | `execution/s2-delivery/s2-delivery-r1.bundle` — `git bundle verify` ok, prerequisite `c23b9d9f` |

Note for the parent: the builder branch `execute/20260920-s2-delivery` has already advanced past the frozen head (`4a63b8ae`, `cb0bc910` observed in `worktrees/s2-delivery`). Nothing below applies to those commits; a later head needs an explicit risk-scoped applicability decision (G09/G10).

## Scope and actual actions

Reviewed every changed file plus unchanged dependencies the change relies on: `ci.yml` (job ids/conditions), `fly.toml`, `scripts/release.sh`, `scripts/sentry-upload-sourcemaps.sh`, `nest-cli.json`, `tsconfig.build.json`, `package.json`/`package-lock.json` flags for `prisma`/`typescript`, `src/health/health.controller.ts` + `src/main.ts` (`/readyz` contract), runtime file reads in `src/`, `h4-readiness.yml`, `migration-dry-run.yml`, the other `fly-*.yml` workflows, `docs/deploy-runbook.md` rollback sections, and the S3 worktree's workflow/`fly.toml` deltas for composition. Read `execution/FLY_RUNTIME_METADATA.md`. Confirmed externally that flyctl derives the `GH_SHA`/`GH_REPO`/`GH_EVENT_NAME` image labels from `GITHUB_SHA`/`GITHUB_REPOSITORY`/`GITHUB_EVENT_NAME` for remote and local Docker builds and that `image_ref.labels` is returned by the Machines API ([flyctl imgsrc/docker.go](https://github.com/superfly/flyctl/blob/master/internal/build/imgsrc/docker.go), [Fly community announcement](https://community.fly.io/t/connecting-github-actions-to-a-fly-deploy/15639)).

Ran (bash/jq/zip only, no installs, no node, nothing written to the snapshot or any hosted system):
- `execution/audits/s2-r1/b/probe-gate.sh` → `probe-gate.log`: 13 independent probes of `release-evidence-gate.sh` through my own fake `gh` (not the builder's fixture).
- Inline probes of `verify-fly-release.sh` (5 machine-list shapes) and `assert-prod-sbom.sh` against the builder's `local-omit-dev-sbom.cdx.json` + the snapshot lockfile (PASS, 357 components, sha256 `f044ef01…c0edf` reproduced).
- `bash -n` on the three new scripts.
- Inspected the builder's shared logs: `/tmp/s2-gate-test.log` (25/25), `/tmp/s2-delivery-test.log` (27/27), `execution/s2-delivery/local-omit-dev-npm-ci.log` (357 packages, exit 0). No log covers the claimed `test/ci/r100-pathspec.spec.ts` run (attribution gap only; the change there is a title rename).

Not done: no jest execution (no `node_modules` in the audit worktree; installs prohibited), no Docker build, no workflow execution, no GitHub/Fly API access.

## What the candidate gets right (verified, not assumed)

- Push-to-main no longer deploys; the workflow file at the landed commit governs, so landing this candidate itself does not trigger a deploy.
- Exact-head binding is sound: `RELEASE_SHA` must be 40-hex lowercase and equal `github.sha`; `deploy` re-checks `outputs.release_sha == github.sha` and asserts the checked-out `HEAD`. Gate skipped (non-main ref or `confirm != deploy`) ⇒ `deploy` cannot run (`result == 'success'` required).
- Provenance filter is correct against real API shapes: `path`, `head_sha`, `repository.full_name`, `head_repository.full_name`, `event ∈ {push, workflow_dispatch, schedule}`, `head_branch`, newest by `run_number`, run `completed/success`, every named job `completed/success`. Job names match what the API will report: `ci.yml` jobs have no `name:` (ids reported), CodeQL matrix job reports `CodeQL JS/TS (javascript-typescript)`, `sbom.yml` job id `build-sbom`. `ci.yml` jobs have no `if:` so they run on every main push.
- Every `gh api` failure or non-JSON body fails closed (probes P2, P3, P7, P8 confirm; builder tests cover API errors, fork, PR-event, stale sha, skipped/missing job, weakened list).
- CodeQL: `continue-on-error` and the GHAS fallback are gone; gate additionally requires an uploaded analysis with `tool.name == "CodeQL"` for the sha (P4 confirms a non-CodeQL analysis is rejected).
- SBOM: install is lifecycle-free (`--ignore-scripts` fixes the `prepare: lefthook install` exit 127), generated from the installed `--omit=dev` tree, proven by `assert-prod-sbom.sh` before upload, re-downloaded and re-checked by the gate. The lockfile has no `os`/`cpu`/`libc`-constrained production packages, so the runner-generated npm closure equals the image's npm closure. `prisma` (CLI) is `devOptional` and survives `--omit=dev` (builder's empirical proof reproduced by my re-run of the assertion).
- Dockerfile runtime stage carries everything runtime code reads outside `dist/`: `prisma/schema.prisma`, `prisma/seed-diagnostic.json`, `package.json` (`src/common/openapi.ts`), `scripts/release.sh`; Handlebars templates are copied into `dist/` by `nest-cli.json` assets. Build-time assertion fails the image if dev tooling is present or the prisma CLI/dist/release inputs are missing. Sentry token stays a build secret in the build stage.
- `/readyz` exists at the bare path (excluded from the `/api` prefix) and returns `{ok:true, db:'up'}` on success, matching the probe's `jq` assertion.
- R100: only the two generic quota jobs were removed; `banned-casts` is byte-identical to main (diff contains only deletions and header comments). Retirement of LOC/test-density quotas is explicitly authorised by G01 and `EXECUTION_RULES.md`.

## Findings

IDs are stable `S2-B*`. "Material" = blocks T4 clearance for the stated scope until closed or explicitly accepted by the authorised owner.

### S2-B1 — Mutable third-party action refs in the job that holds the production Fly token (material; inherited, in-scope, trivial fix)

Evidence: `.github/workflows/fly-deploy.yml` `deploy` job uses `superfly/flyctl-actions/setup-flyctl@master` (unchanged from main) and `actions/download-artifact@v4` (new step), while `checkout`/`upload-artifact` are SHA-pinned. `setup-flyctl` installs the exact binary that later receives `FLY_API_TOKEN` (and Sentry secrets); any step in the job can also poison `$GITHUB_PATH`/`$GITHUB_ENV` for later steps.

Consequence: a compromise or malicious update of either mutable ref bypasses every invariant 1–6 — arbitrary image to production plus token exfiltration — without any change in this repository. This is a credential/enforcement boundary (G05/G12/G16/G17), so it inherits Tier 4 regardless of being pre-existing; the candidate's stated purpose is a trusted release path.

Smallest remediation: pin both to full commit SHAs with version comments (parent can supply the SHAs online; sandbox is offline for that). Optionally scope `FLY_API_TOKEN`/Sentry secrets to the `production` environment so they are only exposed inside this gated job (see S2-B10).

### S2-B2 — No changed workflow, script-on-GitHub path, or Docker image has ever executed (material evidence gap for activation; not a source defect)

Unmeasured claims: (a) `gh api repos/…/actions/artifacts/{id}/zip` redirect handling inside Actions; (b) `actions/upload-artifact@v5` → `actions/download-artifact@v4` cross-version compatibility in the `deploy` job; (c) `flyctl machines list --json` emitting `image_ref.tag/digest/labels` and `config.metadata.fly_process_group` in the shapes `verify-fly-release.sh` expects (inferred from the Machines API read, consistent with flyctl source, but not observed from flyctl); (d) `flyctl deploy --image-label` producing `image_ref.tag == sha-<sha>`; (e) the multi-stage image building at all — `runtime` stage `npm ci --omit=dev` runs `postinstall: prisma generate`, and the build-time assertion `RUN` is the only runnable artifact check; (f) `GITHUB_TOKEN` being permitted to list code-scanning analyses on this repository.

Consequence: a false negative in any of (a)–(d) fails the deploy job *after* `flyctl deploy` has already replaced the production machine (verify/readyz run post-deploy), leaving production changed with a red workflow and no automated containment. Failure in (e) blocks release (safe). Failure in (f) fails closed (safe, but blocks every release).

Smallest remediation: one attributable execution of `sbom.yml` and `codeql.yml` on the landed main head (they run on push automatically) and one `Fly Deploy` dispatch treated as a supervised validation release with the runbook §7 rollback prepared; alternatively a Docker-capable runner for `docker build --target runtime`. Source review can complete now; activation cannot.

### S2-B3 — Identity-compatible hosted landing proposal is absent from the snapshot; product source references a private path (material for S2 acceptance closure; not a code defect)

Evidence: the acceptance row (`deliverables/TGP-Fitness-Execution-Takeover-Brief.md`, S2) requires "protected identity-compatible landing; hosted enforcement and recovery verified before activation." `execution/s2-delivery/LANDING_PROPOSAL.md` does not exist. `fly-deploy.yml` header and `scripts/setup-branch-protection.sh` both point readers to that path, which lives outside the product repository. The script still encodes `required_approving_review_count: 1` + `enforce_admins: true` + `require_code_owner_reviews: true`, which a single-collaborator repository cannot satisfy without a second real human; its comment correctly says "do not run".

Consequence: the gate's own policy (`REQUIRED_WORKFLOWS` default inside `scripts/ci/release-evidence-gate.sh`, and the `deploy` `if:` conditions) is only trusted if changes to `.github/workflows/**` and `scripts/ci/**` on main require review — today main is unprotected, so G07's "outside the candidate's unilateral control" is not yet met by anything. Probe P12 shows the env override surface; the workflow does not set it, so the only override path is a push to main.

Smallest remediation: write the proposal (exact API payloads, no writes) covering: branch protection with required checks `build-and-test, rls-floor-guard, rls-live-tests, mwb-3-live-tests, danger, Banned cast tokens (R75 / R100.A2), CodeQL JS/TS (javascript-typescript), test-deploy-readiness`; the review-count decision recorded by the owner; `production` environment required reviewer(s) or an explicit recorded acceptance that dispatch == release; fork PR workflow approval; token scoping. Replace the dangling private path in product source with a repo-local doc or PR reference.

### S2-B4 — Gate accepts a CodeQL analysis that analysed nothing (nonmaterial defect)

Probe P5: an analysis object for the sha with `rules_count: 0, results_count: 0` passes. G07 says empty scans are not success. Remediation: require `.rules_count > 0` (and record `results_count` in the manifest).

### S2-B5 — Duplicate job names resolve to `.[0]` (nonmaterial)

Probe P10: if the jobs list contains two entries with the same `name`, only the first is checked. Real API default `filter=latest` should not return duplicates, but `all(.status=="completed" and .conclusion=="success")` over the selection is strictly safer and free.

### S2-B6 — Recovery evidence and failed-deploy manifest ambiguity (nonmaterial; recovery-relevant)

The workflow never records the *previous* running image (rollback target) and the post-deploy `release-manifest-<sha>` is uploaded `if: always()` with the same name whether the deploy succeeded or not (`image: null` is the only tell). Remediation: capture `flyctl machines list --json` into `release-evidence/machines-before.json` before `flyctl deploy`, and write `deploy_result: ${{ job.status }}` (or name the artifact `release-manifest-<sha>-<result>`).

### S2-B7 — Migration/release coupling has no gate-level evidence (pre-existing; material at integrated release acceptance, not a S2 source defect)

`fly.toml` `release_command = bash ./scripts/release.sh` still applies every pending Prisma migration to production before rollout. The only migration proof workflow (`migration-dry-run.yml`) is `pull_request`-only and path-filtered; PR-event runs are — correctly — untrusted by the gate, so a release commit's migrations arrive with zero gate evidence and the manifest does not even list them. `release.sh` fails closed on `migrate deploy` errors (existing machines unaffected), but a successful destructive/irreversible migration has no gate, no backup check, and rollback is the manual runbook (§3/§7). Owner: S1 + release acceptance (G13/G17/G18). Smallest S2-side step: record `prisma/migrations` delta between the currently running `GH_SHA` and `RELEASE_SHA` in the manifest and fail when non-empty unless an explicit input acknowledges it.

### S2-B8 — Composition with S3 (#524/#525 preserved changes) — must not be dropped silently

Observed S3 head `5c7b42b3` (the S2 report cites `925780e0`; S3 has moved). S3 touches `ci.yml` (adds a *step*, not a job — `REQUIRED_WORKFLOWS` for `ci.yml` stays valid), `r100-quality-gate.yml` (rewrites `banned-casts` to `scripts/check-r75.js` + `.github/r75-policy.json` but **keeps** `loc-budget`/`test-density`), `danger.yml`, new `dependency-audit.yml` (`push: main`, `pull_request`, job name `npm audit (high+critical, whole graph)`), `fly.toml` (`/readyz` http check, compatible with the post-deploy probe). On the integrated head: take S3's `banned-casts` + S2's deletion of the two quota jobs; add `.github/workflows/dependency-audit.yml=npm audit (high+critical, whole graph)` to the gate's `REQUIRED_WORKFLOWS` and to `REQUIRED_CHECKS`; re-point the three `:(glob)` assertions in `test/ci/r100-pathspec.spec.ts` as the S2 report says. Neither snapshot alone is the release candidate.

### S2-B9 — Runtime artifact residue (nonmaterial, disclosed by builder)

Image runs as root; `typescript` (devOptional) and `@scarf/scarf` (postinstall telemetry executes during the runtime-stage install) remain in the production closure; `fly.toml` still declares `GIT_SHA = ""` (workflow overrides). Recommend `USER node`, `SCARF_ANALYTICS=false` in the runtime install, and leaving the rest for ordinary cleanup.

### S2-B10 — Other production-mutating workflows sit outside the gate (observation; hosted-control input)

`fly-secrets-set.yml`, `fly-db-secrets-set.yml`, `fly-feature-flags-set.yml`, `fly-launch-env-set.yml`, `fly-recent-auth-set.yml` are `workflow_dispatch` jobs using `FLY_API_TOKEN` with no `environment:`. Outside S2's changed files, but if the token remains a repository secret, "nothing reaches production without the gate" is true only for image deploys, not for secrets/flag flips (G16 "switches must not silently activate"). Feed into S2-B3's proposal (environment-scope the token or these workflows).

### S2-B11 — SBOM scope should be stated, not implied (nonmaterial)

The SBOM is the npm production closure only (no base-image OS packages, Node binary, Prisma engine binaries, or the build-stage `@sentry/cli` download). That is a legitimate release dependency inventory under G16, but the manifest should say `scope: "npm production closure"` so nobody reads it as a full image SBOM. Also the gate ignores the uploaded `.sha256` sidecar; cross-checking it is free.

## Truthfulness of the builder report

Claims checked and found accurate: identity, base/head/tree, changed-file list and descriptions, "Docker image not built", "workflows not executed", inferred Fly field names, `download-artifact` tag pin, no shellcheck, 25/27 test counts (logs present), 357-package `--omit=dev` proof and SBOM sha256 (reproduced). Minor inaccuracies: `.dockerignore` presented as if new (it existed on main with 4 lines — the report's stat is right, the prose is slightly loose); the `r100-pathspec.spec.ts` run has no attached log; S3 head reference is stale. No overclaim of readiness: the report correctly states NOT audited/merged/deployed/enabled.

## Verdict

**Source review: complete for head `b801a776`. T4 clearance: NOT granted at this head.**

- Material, must close before activation: **S2-B1** (pin the two mutable action refs), **S2-B2** (one real execution of the changed paths or a supervised validation release with rollback prepared), **S2-B3** (identity-compatible hosted proposal exists and the hosted controls are actually applied before `Fly Deploy` is considered enforced). S2-B7 is material for integrated release acceptance and is owned jointly with S1.
- Nonmaterial, fix when cheap: S2-B4, S2-B5, S2-B6, S2-B9, S2-B11.
- Composition obligations: S2-B8.

The deterministic invariants 1–7 in the builder report hold in source as written and survived independent negative probing; none of them is *enforced* until the hosted controls in S2-B3 exist, because today anyone who can push to main can rewrite the gate. Reviewing this snapshot establishes neither readiness nor clearance; a changed head requires a new applicability decision, and both auditors' attestations must apply to the final head.

## Limits

No network access to GitHub/Fly APIs, no Docker, no jest run by this auditor (builder test evidence reused and challenged, not re-executed), no hosted-settings inspection beyond the parent's read-only `FLY_RUNTIME_METADATA.md`. No secrets, customer data, or raw environment values were read or recorded. Probe artifacts: `execution/audits/s2-r1/b/probe-gate.sh`, `execution/audits/s2-r1/b/probe-gate.log`.
