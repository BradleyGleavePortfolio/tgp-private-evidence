# S2 R2 audit — auditor B (independent) — REPORT

Written 2026-09-20 (PDT afternoon). Read-only review of the T4 S2 delivery-controls candidate. No source, test, worktree, hosted or evidence-repo write was made. No subagents. Peer R2 report not read.

## 0. Reviewer / tool identity

- Requested reviewer: "independent R2 auditor B" (parent-assigned role). The parent's requested model name was not passed to me beyond the role; I do not know it.
- Actual identity as known to me: Claude (Anthropic), running as a Perplexity Computer subagent. The exact model version is not exposed to me and is **not** asserted here.
- Tools used: `git`, `rg`, `jq`, `unzip`, `bash` in the sandbox; `gh api` (read-only GET only) via the GitHub connector for tag→commit pin resolution and hosted-state reads; `pplx_sdk.content.fetch` for public commit pages. No `docker`, `shellcheck`, `actionlint`, `flyctl`, jest or PostgreSQL were run by me.

## 1. Exact identity of the candidate (verified by me)

| Item | Value |
| --- | --- |
| Worktree | `/home/user/workspace/worktrees/s2` |
| HEAD | `0b05fcf5352287109ac88ed2ba3682e441e3a076` |
| Tree | `fba0a9f06127979005b70ca3da80584a1e2ce10c` |
| Working tree | clean (`git status --short` = 0 lines); `node_modules` absent |
| Base / merge-base | `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` (= hosted `main` head, read via `gh api` today) |
| Commit chain over base | `b801a776 → 4a63b8ae → cb0bc910 → 47763380 → 0b05fcf5`, all author = committer Bradley Gleave |
| Diff vs base | 29 files, +2121 / −318 |

Not the audit candidate: the builder's combined preview `6b85395f` (S2+S3 composition) — unexecuted, not reviewed for verdict.

## 2. Scope and actions

Reviewed in full (source at HEAD, plus diff vs base): `.github/workflows/fly-deploy.yml`, `codeql.yml`, `sbom.yml`, `ci.yml` (diff), `r100-quality-gate.yml`, `infra-lint.yml`, all `fly-*.yml` operator workflows, `scripts/ci/release-evidence-gate.sh`, `migration-delta.sh`, `filter-machines.sh`, `verify-fly-release.sh`, `assert-prod-sbom.sh`, `scripts/release.sh`, `scripts/setup-branch-protection.sh`, `Dockerfile`, `.dockerignore`, `docs/delivery-controls.md`, `docs/deploy-runbook.md` (diff), `test/ci/release-evidence-gate.spec.ts` (harness + 43 cases), `test/ci/delivery-artifact.spec.ts` (64 generated cases), `test/ci/r100-pathspec.spec.ts` (8 cases, title-only change).

Evidence read: builder packet `repos/evidence/2026-09-20/remediation/s2-r2/revision-3/` (REPORT.md, CROSS_LANE_DISPOSITION.md, LANDING_PROPOSAL.md, MANIFEST.md, action-pin-verification.log, `s2-r2-test-at-0b05fcf5.log`, local runtime-stage replay); R1 reports `audits/s2-r1/{a,b}/revision-1/REPORT.md`; S5 cross-lane `remediation/s5-r2/cross-lane/S5_CROSS_LANE_DISPOSITION.md`; S3 worktree `worktrees/s3` @ `5c7b42b3` for the `dependency-audit.yml` job name.

Bounded probes (outputs under `execution/audits/s2-r2/b/probes/`, nothing written elsewhere):

- (a) `unzip -o -q zip a b` with `b` absent → exit 11 → gate's `|| fail` fires (fail-closed with the intended message). Even if it did not, the sidecar compare fails closed under `set -Eeuo pipefail`.
- (b) `migration-delta.sh` copied into a temp git repo: non-empty delta without ack → exit 1; with ack → exit 0, manifest `.migrations` populated; simulated `git diff` failure (fake `git` on PATH) **with** ack → exit 1, manifest untouched; `labels` missing → "unknown" → refused without ack. All fail-closed.
- (c) Gate step-5 jq expression against six payload shapes (empty rules, `reviewers: []`, missing `can_admins_bypass`, `wait_timer` only, 404 body): only a `required_reviewers` rule with ≥1 reviewer **and** `can_admins_bypass == false` yields `ok`.
- (d) Independent pin re-verification via `gh api` (read-only): `actions/download-artifact` v5.0.0 → `634f93cb…` ✔; `actions/upload-artifact` v5.0.0 → `330a01c4…` ✔; `github/codeql-action` v3.38.1 tag object `e429ea58` peels to `3ea06614…` ✔; `actions/checkout` v6.0.3 tag object peels to `df4cb1c0…` ✔; `superfly/flyctl-actions` `master` today = `ed8efb33…` ✔ (commit dated 2026-04-08). Matches source and the builder's log.
- (e) Hosted state read (GET only): repo `visibility: public`; `main` = `c23b9d9f`; branch protection → 404 "Branch not protected"; rulesets `[]`; environments: exactly one, named `noble-celebration / production`, `protection_rules: []`, `can_admins_bypass: true`; **no environment named `production` exists**; secret scanning / push protection disabled.
- (f) Test-count reconciliation: `it(` occurrences 43 + 50 (+10 from the pinned-files loop, +4 from the environment-binding loop = 64) + 8 = **115**, matching the log total. The builder's per-suite split (43/71/1) is mis-stated; the total and the exact-head stamps are correct. Log sha256 `92370aa4…` recomputed and matches MANIFEST.

## 3. Disposition of prior R1 findings (stable IDs)

| ID | R1 concern | My R2 disposition at `0b05fcf5` |
| --- | --- | --- |
| S2-A-01 / S2-B3 | environment/branch protection unenforced | **Source fixed; hosted OPEN.** Gate step 5 requires `required_reviewers ≥1` and `can_admins_bypass==false` (probe c). Hosted: no `production` environment exists, `main` unprotected, no rulesets (probe e). First dispatch would auto-create `production` unprotected and the gate would fail closed — safe, but nothing is *enforced* today. Activation blocker, not a merge blocker. |
| S2-A-02 / S2-B4 | empty CodeQL analysis accepted | **Fixed.** `error==""` and `rules_count>0` required; negatives in spec (3 tests). |
| S2-A-03 / S2-B11 | SBOM claim overstated; sidecar | **Fixed.** Gate downloads the artifact, requires both members (probe a), matches the `.sha256` sidecar, re-runs `assert-prod-sbom.sh` against the checked-out lockfile. Scope stated honestly (npm prod closure only). |
| S2-A-04 / S2-B6 | recovery & failed-deploy evidence | **Fixed at the documentation/evidence level.** Manifest uploaded `if: always()` with `deploy_result`; machines-before recorded before deploy; runbook names the direct `fly deploy --image` route as UNGATED. Residual consequences in §4 (S2-R2B-03, -04). |
| S2-A-05 / S2-B7 | migration coupling via `release_command` | **Mitigated.** `migration-delta.sh` fail-closed in all probed paths (probe b). Limits: source delta only, not DB drift; empty-delta+stray-ack refused (good). |
| S2-A-06 | raw machine config in artifacts | **Fixed.** Only `filter-machines.sh` output reaches artifacts; the raw file stays in `RUNNER_TEMP` and feeds delta/verify. Materiality is *higher* than R1 assumed because the repo is **public** (artifacts downloadable by any logged-in GitHub user) — the fix is therefore necessary, and adequate: filtered fields (id, name, region, state, image_ref incl. labels, process group, check name/status) carry no secrets. |
| S2-A-07 / S2-B1 | mutable action refs | **Fixed and independently re-verified** (probe d). All `uses:` in the 11 delivery/operator workflows are 40-hex. Pre-existing tag pins remain in `ci.yml` (`actions/checkout@v6`, `setup-node@v6`) — outside S2 scope, but note that the gate *trusts* ci.yml's runs (§4 S2-R2B-06). |
| S2-A-08 | private `execution/…` paths in product source | **Mostly closed; one residual.** Scripts/docs cleaned, but `ci.yml` line 208 (added by this candidate, following S5 cross-lane item 2) says "see execution/s1-database in the evidence archive". Builder's "no `execution/…` path in repo" claim is not exactly true. Cosmetic/truthfulness nit. |
| S2-B2 | nothing executed; image never built | **Partially addressed, honestly bounded.** Host replay of the runtime stage passed; Docker image still never built; no workflow has run on GitHub as changed. Remains the primary activation gap; not a code defect. |
| S2-B5 | duplicate job names | **Fixed.** All same-name jobs must be `completed/success`; tested. |
| S2-B8 | S3 composition | **Done as inputs.** Gate default `REQUIRED_WORKFLOWS` and `REQUIRED_CHECKS` both name `.github/workflows/dependency-audit.yml` / `npm audit (high+critical, whole graph)`; confirmed to match S3 @ `5c7b42b3`. Consequence: S2 alone can never pass the gate → S3 landing is a hard activation prerequisite (intended; documented in §8). |
| S2-B9 | root user / scarf / typescript | **Fixed** (`USER node`, `SCARF_ANALYTICS=false`; runtime writes only `/tmp/*`, verified). `typescript` remains via Prisma `devOptional` — outside S2. |
| S2-B10 | operator workflows unbound | **Fixed.** Five mutating `fly-*-set` workflows carry `environment: production` (tested). Enforcement still depends on hosted reviewer rule (S2-A-01). |

## 4. New findings (stable IDs S2-R2B-nn)

| ID | Finding | Consequence / materiality | Boundary affected |
| --- | --- | --- | --- |
| **S2-R2B-01** | `docs/delivery-controls.md` misstates three implementation facts: §2.5 says admin-bypass is "reported in the manifest" (the gate actually *requires* it false and the manifest does **not** record it); §2 names the manifest `release-evidence/manifest.json` (actual: `release-evidence/release-evidence-<sha>.json`); §3 says `verify-fly-release.sh` requires "passing checks" (it does not check `checks[].status`; only the separate `/readyz` curl probes health). §6 also calls the observed unprotected environment `production` — the hosted one is `noble-celebration / production`. | Truthfulness of the canonical control description (G09-type). No security effect; the code is stricter than the doc in one place and looser in another. | Merge: **fix-before-or-at-merge doc edit** (non-blocking if tracked). Release: none. |
| **S2-R2B-02** | Recovery text inconsistency: revision-3 `CROSS_LANE_DISPOSITION.md` (S3-B-10) says recovery is "re-dispatch of the previous main sha through the same gate"; the gate forbids this (`RELEASE_SHA == github.sha`, i.e. only the *current* main head can be released). The runbook correctly says forward-only via revert; the disposition text is stale. | Operator confusion during an incident. | Evidence-packet wording; no code change. |
| **S2-R2B-03** | Forward-only rollback of a release that added a migration: a revert PR that *deletes* the migration directory will hit `release.sh` step 3 (`prisma migrate status` sees an applied migration missing locally) and is likely to fail closed, blocking the gated rollback path; the correct revert is code-only (keep the migration, expand/contract). The runbook implies this ("previous image still expects the new schema") but does not state the rule explicitly. **Not exercised by me.** | Recovery time under incident; fail-closed (safe) direction, but the documented recovery route may not work as written for schema-bearing releases. | Release/runbook guidance; S1/S2 shared wording. |
| **S2-R2B-04** | Rollback target naming: runbook §3.4 says the previous image is `sha-<commit>`; the currently running production image (GH_SHA `5076a07a`, deployed 2026-09-18 outside the gate) does **not** carry a `sha-*` tag. For the *first* gated release the rollback target must be read from `machines-before.json` `image_ref.tag`, not derived from the commit. | First-release incident recovery. Minor doc precision. | Runbook. |
| **S2-R2B-05** | Verify/readiness failures happen *after* machines are replaced (single machine, rolling, no Fly auto-rollback): a red `Fly Deploy` run can coexist with changed production. The candidate records this honestly (manifest `deploy_result`), but the only remediation is the ungated `fly deploy --image` route or a revert cycle through CI. Retained from R1-B; unchanged in R2. | Accepted design limit; needs to be understood by the dispatcher. | Release acceptance; no code change requested for S2. |
| **S2-R2B-06** | Trust boundary of the gate: it consumes `ci.yml`/`codeql.yml`/`sbom.yml` run results on the exact sha. `ci.yml` still uses tag-pinned `actions/checkout@v6` / `setup-node@v6` and the `pull_request` workflow file is candidate-controlled; with `main` unprotected and a single maintainer, gate trust reduces to "Bradley's own pushes + Actions' integrity". Hosted controls in `LANDING_PROPOSAL.md` (app-bound required checks, `bypass_actors: []`) are the mitigation and are unimplemented. | Not a defect in S2 code; a truthful statement of what the gate can and cannot attest. | Activation (hosted). |
| **S2-R2B-07** | `infra-lint.yml` (shellcheck + actionlint) has never run on the candidate and cannot run in this sandbox. Five new/changed shell scripts and 13 changed workflows are unlinted. Candidate risk: `for d in $DENY_LIST` (`assert-prod-sbom.sh:53`) may trip default-severity shellcheck; `migration-delta.sh` already carries a `disable=SC2086`. | If lint fails on the PR it is a red, fixable check — not a security issue. | Merge (PR check). |
| **S2-R2B-08** | Gate step 5 does not check `deployment_branch_policy` (main-only) or `prevent_self_review`. With one maintainer, the environment "approval" is the dispatcher approving their own dispatch (recorded option B in `LANDING_PROPOSAL.md` §4, `prevent_self_review: false`). | The control gained is an explicit recorded approval, not four-eyes. This is a Bradley decision, already surfaced by the builder; I concur it is correctly framed. | Activation; owner decision. |
| **S2-R2B-09** | `release.sh` step 4 passes `DIRECT_URL` on the `prisma db execute --url` argv (visible in `ps` on the ephemeral release machine). Verifier failure after `migrate deploy` leaves the DB ahead of running code (Fly keeps old machines) — documented boundary, S1 owns migration/verifier content; zero verifiers exist on base so the loop is a no-op until S1 lands. | Low. | None for merge. |
| **S2-R2B-10** | Builder REPORT per-suite counts (43/71/1) are wrong; total 115 is right (probe f). `ci.yml` comment now claims the S1 chain "replayed 165/165 from empty" — an S1 evidence claim I did not verify. | Reporting precision only. | None. |

Explicitly **not** findings: page-1-only (`per_page=100`) listing of runs/analyses (low risk, newest-first); `unzip` partial-match (fails closed, probe a); `fly-launch-env-set`/`fly-logs-dump`/`fly-recent-auth-set`/`fly-secrets-list` lacking top-level `permissions:` (pre-existing, read-only tokens); `r100-quality-gate.yml` reduction to the banned-casts job (intended, tested).

## 5. S5 cross-lane directions — status relative to this candidate

- Item 1 (never `migrate resolve --rolled-back` after a successful out-of-band reversal): **consistent** — runbook §3.5 and `delivery-controls.md` §7.1 carry the rule.
- Item 2 (`ci.yml` PG15 = compatibility floor, proofs on 17.6): **partially applied** — comment added near the schema-setup note (not next to the `postgres:15` services) and omits the words "compatibility floor". It introduces the `execution/s1-database` path (S2-A-08 residual).
- Item 4 (worker stop/start ordering around E migration = process boundary, owner S2 release workflow): **not implemented** (direction only, as S5 recorded). `fly-deploy.yml` has no worker-drain step; `release_command` runs while `app` machines serve. This is a future E-rollout requirement, not an S2 R2 defect.

## 6. Unexplained failures

None observed. Every fail-closed path I probed failed for the documented reason. The exact-head jest log is internally consistent (BEFORE/AFTER stamps identical, clean tree, exit 0).

## 7. Remaining gaps (what is *not* proven)

1. No workflow in this candidate has executed on GitHub; first dispatch is first runtime evidence (S2-B2).
2. Docker image never built; host replay of the runtime stage is a control proof only.
3. `GITHUB_TOKEN` read of `environments/{name}` and `code-scanning/analyses`: unmeasured. The repo being **public** makes both very likely to succeed with `contents/actions/security-events: read`; a 403 fails closed.
4. Hosted enforcement absent: no `production` environment, no branch protection, no rulesets.
5. `dependency-audit.yml` (S3) not on `main` → gate fails closed for every release until S3 lands.
6. `infra-lint` not executed on the candidate (S2-R2B-07).
7. Source↔image equivalence unattested (`--remote-only` build), stated honestly by the builder.

## 8. Bounded verdict

**Code / merge boundary: PASS with two tracked doc corrections (S2-R2B-01, -02) and one pre-merge check to run (S2-R2B-07).** I found no security defect, no fail-open path, and no untruthful control claim in the *scripts or workflows* at `0b05fcf5`. Every R1 material finding is either fixed in source and tested, or honestly bounded as a hosted/activation gap. The candidate is stricter than the base in every reviewed dimension and never deploys on push.

**Activation / release boundary: NOT CLEARED.** Nothing here is enforced until (in order) the `production` environment is created and protected (reviewers ≥1, admin bypass off, main-only branch policy, `FLY_API_TOKEN` moved), `main` gets app-bound required checks, S3's `dependency-audit.yml` lands on `main`, `infra-lint` and all required checks are green on the merged head, and a first gated dispatch produces the first real manifest. Residual risk if activated as-is: a red deploy can leave production changed (S2-R2B-05); gated rollback for schema-bearing releases may fail closed if the revert deletes the migration (S2-R2B-03); with one maintainer, approval is self-approval (S2-R2B-08) — a Bradley decision already framed correctly by the builder.

Nothing above should be read as: tested on GitHub, audited-clean for hosted state, merged, deployed, enabled, or customer-proven.

## 9. Smallest follow-up actions

1. Builder: correct `docs/delivery-controls.md` §2/§3/§5-6 wording per S2-R2B-01 and the stale re-dispatch sentence per S2-R2B-02 (doc-only commit; no test impact).
2. Parent: run `shellcheck scripts/**/*.sh scripts/*.sh` and `actionlint` on `0b05fcf5` (either the pinned `infra-lint.yml` on the PR or a coordinated sandbox install) — S2-R2B-07.
3. Runbook one-liner for S2-R2B-03/-04: "revert code only; never delete an applied migration directory; first-release rollback target = `machines-before.json` `image_ref.tag`".
4. Landing sequencing unchanged from `LANDING_PROPOSAL.md`: environment first, then protection, then merge (S3 before or with S2), then first dispatch.
