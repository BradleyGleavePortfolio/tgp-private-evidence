# S7-L landed on `integration/importer` by fast-forward (LAND-1)

- **Status: LANDED.**
- **Executor:** `landing_composition_prep`.
- **Grants:** `daceddc8/SCOPE.md`, sections "LAND-1 grant" (17:00Z) and "S7-L accepted; LAND-1 fast-forward authorized" (17:03Z).
- **Acceptance:** `64e33dc7/S7L_ACCEPTANCE.md`, evidence commit `5d758ba`. The v4 real-PG proof passed 24/24.

| Item | Value |
|---|---|
| PR | [#539](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/539) "Land S7-L: server-owned import run lifecycle (df713fd9)", base `integration/importer`, head `land/s7-l-accepted` |
| Accepted head | `df713fd9217df524915348ef8a42c797f288dde1`, tree `796f437fea80550a379b5f54dc485bc5dbba67e1` |
| `land/s7-l-accepted` pushed | 2026-09-25T16:56:09Z, new branch at exactly `df713fd9`, no new commit (`push.log`) |
| Draft PR opened | 16:56Z (`pr-create.log`, `pr.json`) |
| CI | 16:56:32Z–17:02:32Z. **Green:** 11 pass and 1 expected skip, all on head `df713fd9`. |
| Marked ready | 17:04:58Z (`gh pr ready 539`) |
| Remote `integration/importer` before | `93389265a846095b846fa8f1fb0dad782fb6ee9f` (ls-remote, 17:04:55Z) |
| Push | 17:05:00Z. One ordinary `git push origin df713fd9…:refs/heads/integration/importer`, output `93389265..df713fd9`, rc 0. No force, no `+`. |
| Remote `integration/importer` after | `df713fd9217df524915348ef8a42c797f288dde1`, confirmed by ls-remote and `gh api branches/integration/importer`. Tree `796f437f…`. Author and committer are both Bradley Gleave `<bradley@bradleytgpcoaching.com>`. |
| PR state | **MERGED** at 2026-09-25T17:05:02Z, merge commit `df713fd9` (a fast-forward, so no new commit). GitHub detected this automatically. |
| `main` | `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` before and after, untouched |
| Protection and settings | Untouched |

## Checks on #539 (head `df713fd9`)

The raw data is in `pr539-checks-final.json` and `check-runs-df713fd9.json`. Workflow runs are listed in `workflow-runs.tsv`.

| Workflow | Check | Result |
|---|---|---|
| CI (run 36163967065) | build-and-test | pass: lint, `tsc --noEmit`, build, full `npm test`. Test Suites: 12 skipped, 567 passed (579 total). Tests: 159 skipped, 5 todo, 8855 passed (9019 total). Snapshots: 6 passed. See `build-and-test-108167074028.log`. |
| CI | rls-floor-guard | pass |
| CI | rls-live-tests | pass |
| CI | mwb-3-live-tests | pass |
| Migration Dry-Run (36163967076) | Forward migrations apply cleanly | pass |
| Migration Dry-Run | New migrations are reversible (or explicitly marked IRREVERSIBLE) | pass |
| Migration Dry-Run | Schema parity (deferred to BL-MIGRATION-REBASELINE) | pass |
| Dependency Audit (36163967022) | npm audit (high+critical, whole graph) | pass |
| H4 deploy readiness (36163967050) | test-deploy-readiness | pass |
| H4 deploy readiness | comment-deploy-readiness | pass |
| H4 deploy readiness | deploy-readiness-gate | skipping (as on #538) |
| pr-size-labeler (36163967075) | size-label | pass |

**Red checks: none.**

**Danger did not run on #539.** It triggers only for `pull_request` events whose base is `main`, so there was no Danger log to check. The known class C title rule was never exercised here. The same base filter applies to CodeQL, R75 / R100.A2, SBOM and Infra Lint (see the correction below).

## Correction to the LAND-PREP-1 plan (class C, plan text only)

`analysis/pr538-checks.json` listed 20 checks on PR #538's head `93389265`. Those checks came from two different PRs:

- **#538 itself** (base `integration/importer`, 22:37Z) triggered only the 12-check set above.
- **Draft PR #530** (`integration/importer` → `main`, the owner-reserved production boundary) triggered the main-only set when its head advanced to `93389265` at 22:46Z: Danger ×2, CodeQL ×2, R75, actionlint, shellcheck and build-sbom. The Danger title failures recorded there belong to #530's title, "DO NOT MERGE (prod deploy boundary)…".

The `pull_request: branches: [main]` filters in `danger.yml`, `codeql.yml`, `r100-quality-gate.yml`, `sbom.yml` and `infra-lint.yml` at `df713fd9` confirm this. `check_pr_ci` in `scripts/landing-lib.sh` now requires the checks that trigger on an integration/importer base. If a main-only check appears, it must pass, except the Danger title rule.

**Expected side effect of this landing (not a landing gate).** Advancing `integration/importer` synchronizes draft PR #530. At 17:05:06Z, main-targeted runs started on `df713fd9` for #530: Infra Lint, SBOM, Danger, codeql, CI, Migration Dry-Run, H4, R100 Quality Gate (success), Dependency Audit (success) and size-label (success). Pushing a PR head does not deploy. Fly deploys and `prisma migrate deploy` happen only on a push to `main`, which remains owner-reserved. #530 stays draft and open. Its Danger failure, if any, is the known title class C on #530.

## Follow-on

S8-C is now composed second, on top of `df713fd9`. It uses the updated `scripts/compose-second.sh` with `SECOND=s8c`. `SECOND_HEAD` is a parameter and must be the accepted S8-C harness-correction head, a descendant of `e0cee7e0`. See PLAN.md section 1, LAND-1 revision.
