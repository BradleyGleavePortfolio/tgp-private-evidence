# S2 hosted-settings landing proposal — `BradleyGleavePortfolio/growth-project-backend`

Status: **proposal only. No API writes were made by S2.** Everything below is to be executed by the repository owner (Bradley) after dual audit clearance, in the order given. Written 2026-09-20 17:20 UTC against candidate head `4a63b8ae` (see REPORT.md).

Observed baseline (read-only, `evidence/`): main has no branch protection (404), rulesets `[]`; one environment `noble-celebration / production` with `protection_rules: []`, `can_admins_bypass: true`, `deployment_branch_policy: null`; only collaborator observed: Bradley (G05 — no second identity will be invented).

## 0. Ordering constraint (why order matters)
The candidate's `fly-deploy.yml` binds the deploy job to environment **`production`** and its gate refuses to run unless that environment already has ≥1 required reviewer and admin bypass off. GitHub auto-creates an environment, unprotected, the first time a workflow references it. Therefore step 1 must complete **before** the candidate is merged or dispatched; steps 2–3 before merge; step 4 is the merge; step 5 the first gated deploy.

## 1. Environment `production` (create + protect) — before merge
`PUT /repos/{owner}/{repo}/environments/production`
```json
{
  "wait_timer": 0,
  "prevent_self_review": false,
  "reviewers": [{ "type": "User", "id": <Bradley user id> }],
  "deployment_branch_policy": { "protected_branches": true, "custom_branch_policies": false }
}
```
Then `PUT /repos/{owner}/{repo}/environments/production/deployment-protection-rules` is not needed; set **"Allow administrators to bypass configured protection rules" = off** in the UI (API field `can_admins_bypass: false` is exposed on the environment object; the REST PUT does not currently accept it, so this is a UI toggle — verify with `GET /repos/{owner}/{repo}/environments/production` → `can_admins_bypass == false`).
- `prevent_self_review: false` is deliberate: with one human maintainer, the dispatcher and the reviewer are the same person; the control gained is a recorded, explicit approval on the deployment, not four-eyes. If a second human maintainer exists later, flip to `true`.
- Secrets: `FLY_API_TOKEN` (deploy token scoped to app `backend-spring-lake-3890`) and `SENTRY_AUTH_TOKEN` move from repository secrets to **environment secrets** on `production`; delete the repository-level copies so a workflow outside the environment cannot read them.
- `noble-celebration / production`: provenance unknown (likely auto-created by an integration). Not used by the candidate. Recommend leaving it and, once the gated path works, deleting it so it cannot be referenced by a stale workflow.

## 2. Ruleset on `main` — before merge
`POST /repos/{owner}/{repo}/rulesets` (rulesets are preferred over classic branch protection: they support `required_workflows`-style provenance and are not silently weakened by admin status when `bypass_actors` is empty).
```json
{
  "name": "main-trusted-delivery",
  "target": "branch",
  "enforcement": "active",
  "bypass_actors": [],
  "conditions": { "ref_name": { "include": ["refs/heads/main"], "exclude": [] } },
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    { "type": "required_linear_history" },
    { "type": "required_signatures" },
    { "type": "pull_request", "parameters": {
        "required_approving_review_count": 0,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": true } },
    { "type": "required_status_checks", "parameters": {
        "strict_required_status_checks_policy": true,
        "do_not_enforce_on_create": false,
        "required_status_checks": [
          { "context": "build-and-test" },
          { "context": "rls-floor-guard" },
          { "context": "rls-live-tests" },
          { "context": "mwb-3-live-tests" },
          { "context": "danger" },
          { "context": "Banned cast tokens (R75 / R100.A2)" },
          { "context": "test-deploy-readiness" },
          { "context": "CodeQL JS/TS (javascript-typescript)" },
          { "context": "build-sbom" }
        ] } }
  ]
}
```
Notes:
- **`integration_id`** must be set on every `required_status_checks[]` entry to the GitHub Actions app id (`15368`) once confirmed via `GET /repos/{owner}/{repo}/commits/{sha}/check-runs` → `.check_runs[].app.id`. This is what makes the check *provenance-bound*: a check with the same name posted by any other app or a PAT does not satisfy the rule. Names alone are not trusted (parent acceptance criterion).
- `required_approving_review_count: 0` is the honest setting for a one-maintainer repository (option B below). `bypass_actors: []` keeps the owner subject to the rules.
- `required_signatures`: only if Bradley's commits are signed today; otherwise drop it now and add later — do not block landing on it.
- `build-sbom` and CodeQL are PR-triggered in the candidate workflows (`pull_request: [main]`), so they appear on PRs and can be required; the deploy gate separately re-verifies the *main push* runs for the exact sha.
- Retired names **not** to be required: `LOC budget (R100.A3)`, `Test density (R100.A1)`.
- The existing `scripts/setup-branch-protection.sh` (classic protection API) is now consistent with this list but the ruleset above is the preferred vehicle; if the script is used instead, it must be run by Bradley, not by an agent.

## 3. Required review for trusted-gate paths — before merge
Push ruleset (or a second branch ruleset) requiring a PR and, when available on the plan, `required_workflows`; at minimum add a **CODEOWNERS** file owned by S2 lane at landing time:
```
/.github/workflows/  @BradleyGleave
/scripts/ci/         @BradleyGleave
/Dockerfile          @BradleyGleave
/.dockerignore       @BradleyGleave
```
and set `require_code_owner_review: true` in the ruleset **only if** option A below is chosen (with one maintainer, code-owner review of one's own PR cannot be satisfied without self-approval, which GitHub forbids).

Actions settings (`PUT /repos/{owner}/{repo}/actions/permissions/workflow`): `{"default_workflow_permissions":"read","can_approve_pull_request_reviews":false}`. Fork PR workflows: "Require approval for all outside collaborators".

## 4. Identity / reviewer route (owner decision required — pick one)
| | A. Second human maintainer | B. Single-maintainer, recorded decision |
|---|---|---|
| PR approvals | `required_approving_review_count: 1`, `require_code_owner_review: true` | `0` (checks + environment gate carry the control) |
| Deploy approval | second human as environment reviewer, `prevent_self_review: true` | Bradley as reviewer, `prevent_self_review: false` |
| What it proves | independent human review of trusted-gate changes | explicit, logged owner authorization per deploy; no second identity fabricated |
Not acceptable under G05/G10: a second PAT/bot account posing as a reviewer; auto-approval workflows; `bypass_actors` containing the owner.

**Landing the candidate itself (G07 — no self-approved gate):** the candidate changes trusted checks (T4). It lands through a PR from `execute/20260920-s2-delivery` opened by Bradley (bundle import, no agent push), with both independent audit reports attached to the PR, ruleset from step 2 already active so all listed checks must pass on the PR head, and merge executed by Bradley. The evidence gate for the first deploy will then verify the merge sha on main.

## 5. First gated deploy (after merge)
1. Confirm `main` head sha `S` = merge commit; confirm `ci.yml`, `codeql.yml`, `sbom.yml` push runs for `S` all succeeded (`gh run list --commit S`).
2. `gh workflow run fly-deploy.yml --ref main -f release_sha=S -f confirm=deploy` — run by Bradley.
3. `evidence-gate` must pass; approve the `production` deployment when prompted; deploy runs; download `release-manifest-S` and file it under `tgp-private-evidence`.
4. Compare `image.digest` in the manifest with `flyctl machines list -a backend-spring-lake-3890 --json` read independently. Until this run, the currently serving image (GH_SHA `5076a07a`, digest `sha256:5eed9e51…`) remains un-attested.

## 6. Verification reads after each step (no writes)
```
gh api repos/{owner}/{repo}/environments/production                # reviewers ≥1, can_admins_bypass=false, branch policy protected
gh api repos/{owner}/{repo}/rulesets --jq '.[].name'               # main-trusted-delivery
gh api repos/{owner}/{repo}/rules/branches/main                    # effective rules incl. required_status_checks with integration_id
gh api repos/{owner}/{repo}/actions/permissions/workflow           # read / false
gh api repos/{owner}/{repo}/actions/secrets --jq '.secrets[].name' # FLY_API_TOKEN, SENTRY_AUTH_TOKEN absent at repo level
gh api repos/{owner}/{repo}/environments/production/secrets --jq '.secrets[].name'
```

## Out of scope / not proposed
Changing Fly app settings, DNS, database, feature flags; creating accounts; any billing action. `h4-readiness.yml`'s strict `deploy-readiness-gate` is a candidate for a later required check once its secrets are environment-scoped; it is not in this proposal.
