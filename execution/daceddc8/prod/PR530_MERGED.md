# PR #530 MERGED — backend `integration/importer` → `main` (PROD-MERGE-1)

- Executor: T4 production-merge executor (subagent), grant PROD-MERGE-1 in `execution/daceddc8/SCOPE.md`
- Authority: Bradley 10:59 PT ("if they're ready to merge safely, lets go ahead and get them merged!"); 11:07 PT (method left to operator). Safety basis: `prod/PR530_MERGE_SAFETY.md` (SAFE at `1c10e2a1` once #530 green there).
- Repo: `BradleyGleavePortfolio/growth-project-backend`, PR #530 `integration/importer` → `main`
- Method: plain fast-forward `git push origin <sha>:refs/heads/main`. No `--force`, no merge/squash commit, no new commits, no protection change, no workflow dispatch, no secrets/flags touched.
- Raw tool outputs: `prod/pr530_merge_logs/01_*` … `09_*` (paths below are relative to that directory).

## RESULT: MERGED at 2026-09-25T18:20:30Z. No deploy ran. Production unchanged.

| Item | Pre | Post |
| --- | --- | --- |
| `refs/heads/main` | `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` | `1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47` |
| `refs/heads/integration/importer` | `1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47` | `1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47` (unchanged) |
| PR #530 | OPEN, draft, MERGEABLE/CLEAN, head `1c10e2a1` | `state=MERGED`, `merged=true`, `merged_at=2026-09-25T18:20:30Z`, `merge_commit_sha=1c10e2a1`, `merged_by=BradleyGleavePortfolio` |
| Fly Deploy newest run | 34404749133 (2026-09-09, push, failure) | 34404749133 (unchanged — no new run) |
| Prod `/health` uptime | 658,559 s at 18:22:05Z | 658,885 s at 18:27:31Z (monotonic, no restart) |
| Prod `_prisma_migrations` applied | 164 (assessment baseline) | 164; last `20261223000300_scout_reconstructed_entity`; `public.ImportIntent` absent (18:28:10Z) |

Timeline (UTC): fetch/checks 18:18:56 → assertions 18:19:31 → pre-push ls-remote 18:20:28 → push 18:20:28–18:20:30 → PR auto-marked merged 18:20:30 → push workflows created 18:20:34 → all completed 18:26:47 → final verification 18:27:14–18:28:10.

## Step 1 — PR #530 checks on head `1c10e2a1` (`01_pr_checks_pre.txt`, `01_check_runs_1c10e2a1.json`)

`gh pr checks 530` at 18:18:56Z: 20 checks, 19 `pass`, 1 `skipping` (`deploy-readiness-gate`, expected). Check-runs API for the commit: 29 check runs (two CI cycles on the same sha: 18:06Z when #540 was FF'd, 18:12–18:18Z re-run), every one `status=completed`, conclusion `success` ×27 / `skipped` ×2 (`deploy-readiness-gate` both cycles). Zero failures, zero in-progress. No wait was needed.

## Step 2 — pre-push assertions (`02_pre_push_assertions.txt`, `02b_workflow_trigger_audit.txt`) — all OK

- `origin/main` local = `git ls-remote` = `gh api branches/main` = `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`. `main` `protected:false`.
- `git merge-base --is-ancestor c23b9d9f 1c10e2a1` → true; merge-base = `c23b9d9f`. Range `c23b9d9f..1c10e2a1` = 99 commits (13 of them merge commits already inside the integration history); FF is exact-bytes, no new commit.
- `git show 1c10e2a1:.github/workflows/fly-deploy.yml`: `on:` has exactly `workflow_dispatch` (inputs `release_sha`, `confirm`, `migrations`); jobs `evidence-gate` (`if: github.ref == 'refs/heads/main' && inputs.confirm == 'deploy'`) then `deploy` (`environment: production`). No `push`, no `pull_request`. Contrast `main@c23b9d9f`: `on: push: branches: [main]`.
- YAML audit of all 20 workflows in the `1c10e2a1` tree: every file that mentions `flyctl`/`superfly` (`fly-deploy`, `fly-db-secrets-set`, `fly-feature-flags-set`, `fly-launch-env-set`, `fly-logs`, `fly-recent-auth-set`, `fly-secrets-list`, `fly-secrets-set`) is `workflow_dispatch`-only. Push-on-main workflows: `ci`, `codeql`, `dependency-audit`, `infra-lint` (path-filtered), `release-please`, `sbom` — none reference Fly. **FLY WORKFLOWS WITH push/pull_request TRIGGER: NONE.**

## Step 3 — push (`03_push.txt`)

```
T_pre: 2026-09-25T18:20:28Z   remote main immediately before push: c23b9d9f… (re-checked, matched)
git push origin 1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47:refs/heads/main
   c23b9d9f..1c10e2a1  1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47 -> main      (push exit 0)
T_post: 2026-09-25T18:20:30Z
ls-remote main after: 1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47
gh api main after:    1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47
```
Plain FF (`c23b9d9f..1c10e2a1`, not `+`/forced). Pre-push snapshot of `main` runs in `03_main_runs_pre_push.json`; newest Fly Deploy run pre-push = 34404749133 (`03_fly_deploy_runs_pre_push.json`).

## Step 4 — PR state (`04_pr530_state_post_push.txt`)

- PR #530: `state=MERGED`, `merged=true`, `mergedAt=2026-09-25T18:20:30Z`, `closedAt=18:20:31Z`, `mergeCommit.oid=1c10e2a1…`, `base_sha=c23b9d9f…`, `mergedBy=BradleyGleavePortfolio` (the pushing account). GitHub auto-marked it merged because `main` now contains the head. `integration/importer` had not moved (still `1c10e2a1`), so the PR did not stay open.
- PR #540 (`land/s8-c` → `integration/importer`): already merged 18:12:32Z (S8-C LANDED), head `1c10e2a1`.
- Not done (cosmetic, outside grant): PR title still "DO NOT MERGE (prod deploy boundary): importer integration through R" and `isDraft:true`. Because the merge was an FF push, no merge commit inherited the title; the title is now just a historical label on a merged PR.

## Step 5 — push-triggered workflow runs on `main` @ `1c10e2a1` (`05_watch_log.txt`, `05_main_runs_1c10e2a1_latest.json`, `08_final_verification.txt`)

Exactly six runs were created by the push (all `event=push`, created 18:20:34Z). Polled at 18:21:40, 18:24:28, 18:25:27, 18:26:12, 18:26:52Z; all completed by 18:26:47Z.

| Run | Workflow | Jobs | Result |
| --- | --- | --- | --- |
| 36172802147 | Infra Lint | shellcheck ✓, actionlint ✓, danger dry-run skipped (PR-only) | success (18:20:46Z) |
| 36172802039 | Dependency Audit | npm audit (high+critical) ✓ | success (18:20:50Z) |
| 36172802026 | SBOM (CycloneDX) | build-sbom ✓ | success (18:21:01Z) |
| 36172802020 | codeql | CodeQL JS/TS ✓ | success (18:23:47Z) |
| 36172802118 | CI | build-and-test ✓, mwb-3-live-tests ✓, rls-live-tests ✓, rls-floor-guard ✓ | success (18:26:47Z) |
| 36172802104 | Release Please | release-please ✗ | **failure** (18:23:18Z) — pre-existing, see below |

These five green runs (`ci`, `codeql`, `sbom`, `dependency-audit`, plus `infra-lint`) are exactly the evidence set the new `release-evidence-gate.sh` will require for `release_sha=1c10e2a1` (assessment D5).

**Release Please failure (`07_release_please_failure.txt`) — chronic, not caused by this merge, not deploy-related.** The action parsed 752 commits, created its release branch commit `c89352ab` on its own side branch `release-please--branches--main--components--growth-project-backend`, then failed at PR creation with `GitHub Actions is not permitted to create or approve pull requests` (repo Actions setting). Identical `failure` on every one of the 8 prior `main` pushes (c23b9d9f 2026-09-09, 5076a07a 2026-07-23, 07ff9740, 4cb05eff, 9c1bcbd3, ccb7e400, d476fd6d 2026-07-21). It did not touch `main`. Class-C; fixing it (Actions settings → allow PR creation) is an owner-side repo setting, outside this grant.

### Deploy-absence evidence (`06_deploy_absence_t1.txt`, `08_final_verification.txt`, `08b_dispatch_absence.txt`, `09_supabase_prod_migrations_readonly.json`)

1. **No Fly workflow ran.** `gh run list --workflow fly-deploy.yml --limit 1` at 18:27Z still returns 34404749133 (2026-09-09, push, failure). Newest run of each of the 8 `fly-*.yml` workflows is dated 2026-09-09 or earlier (`fly-db-secrets-set` 2026-05-20, `fly-feature-flags-set` 2026-07-09, `fly-launch-env-set` 2026-07-09, `fly-logs` 2026-05-20, `fly-recent-auth-set` 2026-07-09, `fly-secrets-list` 2026-07-09, `fly-secrets-set` 2026-04-30).
2. **No workflow_dispatch anywhere.** `actions/runs?event=workflow_dispatch&created>=2026-09-25T18:00:00Z` → `total_count: 0`. The executor dispatched nothing.
3. **All runs in the repo created ≥ 18:20:00Z (any branch/event) = 10:** the six `main` push runs above, plus four `pull_request` runs on `land/s9-0` @ `1c5fbb04` (another lane's S9-0 PR: CI, H4 deploy readiness, pr-size-labeler, Dependency Audit). The only run whose name matches /fly|deploy/i is `H4 deploy readiness` = `h4-readiness.yml`, a PR readiness check with no Fly reference (trigger audit). No `Fly Deploy`.
4. **No GitHub deployment object created.** Newest 3 deployments are `noble-celebration / production` from 2026-04-01/02 (Fly-created legacy environment); nothing new.
5. **Prod process not restarted.** `GET https://backend-spring-lake-3890.fly.dev/health` → `{"ok":true,"uptime":658559}` at 18:22:05Z and `uptime:658885` at 18:27:31Z (≈7.6 days continuous, monotonic across the merge). `/healthz` 200. `/readyz` → `{"ok":true,"db":"up"}` 200 — note: `/readyz` already exists on the running image `5076a07a` (`git grep readyz 5076a07a -- src/health` → `@Get('readyz')`), so 200 is consistent with the old image; my in-log label "404 expected" in `06_deploy_absence_t1.txt` was a wrong assumption and is corrected here (`06b_readyz_investigation.txt`).
6. **Prod DB schema unchanged** (Supabase `rpyfdsgxxltzutgqeouk`, read-only catalog query at 18:28:10Z): `_prisma_migrations` applied = 164 (166 rows incl. the 2 rolled-back baseline attempts), `max(finished_at)=2026-07-19`, last migration `20261223000300_scout_reconstructed_entity`, `public."ImportIntent"` does not exist. Matches the assessment's pre-merge baseline exactly; none of the 8 in-range migrations applied.

## Invariants respected

- No commits authored (FF push only; author/committer invariant not engaged). No amend, no force, no bypass, no protection change (`main` `protected:false` before and after — untouched). No workflow dispatched, no secret/flag set, no settings changed.
- Evidence repo `tgp-private-evidence` NOT committed by this executor (pre-existing staged files from other lanes left as-is). Only additions: this file and `prod/pr530_merge_logs/*`.
- No lock taken (no heavy/PG work). Read-only Supabase query only (counts/catalog; no customer rows).

## Follow-ups (owner / parent; none blocking)

1. Deployment remains owner-reserved: preconditions D1–D6 in `PR530_MERGE_SAFETY.md` §7 (Fly billing, `production` environment with required reviewer, one-off runtime image build proof, flags OFF, then dispatch `Fly Deploy` with `release_sha=1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47`). D5 (green `ci`/`codeql`/`sbom`/`dependency-audit` on `main` for that sha) is now satisfied by runs 36172802118 / 36172802020 / 36172802026 / 36172802039.
2. Evidence docs stating "main auto-deploys" (`LAST_OPERATOR_STATE.md`, landing PLAN, `HALF_DONE_WORK.md` B2) are now stale; update per assessment §6.
3. Release Please: enable "Allow GitHub Actions to create and approve pull requests" in repo Actions settings, or accept the chronic failure. Its side branch `release-please--branches--main--components--growth-project-backend` now sits at `c89352ab` (proposes 1.0.0 → 0.1.1; ignore).
4. Open PRs against `main` (e.g. #522) may need rebasing (assessment §4).
5. Next release cycle: `integration/importer` == `main` == `1c10e2a1`; S9-0 LAND-3 will move `integration/importer` ahead again and a new PR to `main` will be needed (PR #530 is closed/merged).
