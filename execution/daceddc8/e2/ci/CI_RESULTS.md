# E2 phase 2: gates, commit, push, draft PR and CI

Grant: `daceddc8/SCOPE.md`, "E2-1 phase 2 grant (17:40Z)". Builder: `e2_status_reads_server`.

## Head

| Item | Value |
|---|---|
| Commit | `a889f4ade0e13d9f45aabd69c5878ff07e2038bf` on `land/e2-status-server`. It is one ordinary commit on top of `8901d5f50eaadd6bad19e933c9e76b6539299669` (`land/s4-r6`), so history is linear. |
| Tree | `1c784e6cb6bbc7732d1ef109ff816cf56095a326`, identical to the SOURCE_READY tree. No byte changed between SOURCE_READY and the commit. |
| Author / committer | Both are `Bradley Gleave <bradley@bradleytgpcoaching.com>`, from the repo-local config. |
| Commit message | Grepped for `co-authored`, `generated`, model or assistant names: no matches. There is no amend and no `--no-verify`. |
| Push | `git push origin land/e2-status-server` created a new branch, with no force. The remote now points to `a889f4ad`. |

## Canonical slot (`/home/user/workspace/execution/test-validation.lock`, inode 674373)

The raw log is `../gates/lock-attempts.log`.

- **17:26:49Z, attempt 1: acquired with `flock -n`.** The runner was killed during `npm ci` together with the shell that launched it; its `npm-ci.log` is empty. There was no commit, and the lock was freed when the process exited. The logs are kept in `../gates/attempt1-killed/`.
- **17:29:18Z, attempt 2: acquired with `flock -n`,** detached with `setsid`. It ran `npm ci`, `npm test`, `npm run gates`, `npm audit`, the hooked commit and the gates again after the commit.
- **17:34:15Z: released** as soon as the post-commit gates finished.
- **Disclosed:** one more `flock -n -c echo` availability probe after the release took and dropped the lock for a moment, with no work under it. An earlier probe during the source phase found the lock busy.

## Local results (under the slot; logs in `../gates/`)

| Step | Result |
|---|---|
| env | node v20.20.1, npm 10.8.2, repo prettier 3.9.6, gitleaks 8.30.0 (checksum-verified by `scripts/install-gitleaks.sh`), lefthook pre-commit installed by `npm ci`/`prepare` |
| `npm ci` | rc 0 |
| `npm test` | rc 0: **69 files / 1859 tests passed**. The baseline at `8901d5f5` is 66 / 1772, so this adds 3 files and 87 tests. |
| `npm run gates` (staged, pre-commit) | rc 0 |
| `npm audit --audit-level=high` | rc 0, 0 vulnerabilities |
| Genuine lefthook pre-commit | secrets, deploy-readiness, banned, lint, format and type-check all passed (11.2 s) |
| `npm run gates` (post-commit, on HEAD) | rc 0. Prettier checked 57 files against `origin/main`. |

## Draft PR

- The PR is https://github.com/BradleyGleavePortfolio/tgp-importer-extension/pull/30. It is a **DRAFT** and OPEN, with base `land/s4-r6` and head `land/e2-status-server` @ `a889f4ad`. `mergeStateStatus` is CLEAN.
- **Why this base:** every workflow (`ci.yml`, `secrets-scan.yml`, `codeql.yml`) triggers on `pull_request` with no branch filter. `ci.yml` checks out `pull_request.head.sha`, so the required `test` and `codeql` contexts run on the exact head.
- Stacking on `land/s4-r6` scopes the diff-based gates (banned, identity, format) to the E2 commit alone, via `GITHUB_BASE_REF`. It also means the PR cannot land on `main` before PR #27.
- The PR has not been marked ready or merged. No protection or settings changes were made.

## CI verdict on `a889f4ade0e13d9f45aabd69c5878ff07e2038bf`: **GREEN**

| Check | Event | Run | Conclusion |
|---|---|---|---|
| test (CI) | pull_request | 36168071736 | success. 69 files / 1859 tests; banned and identity checked against `origin/land/s4-r6`; Prettier checked 8 files; 0 vulnerabilities |
| test (CI) | push | 36168013371 | success. 69 / 1859; identity checked against `origin/main`; Prettier checked 57 files; 0 vulnerabilities |
| codeql | pull_request | 36168071675 | success |
| secrets-scan | pull_request | 36168071893 | success |

The raw data is in `runs.json`, `check-runs.tsv`, `pr30-checks.txt`, `pr30.json` and `ci-<run>.log` in this directory. The code-scanning alerts API returned 404 "no analysis found" for the PR merge ref and needed an extra scope. The `codeql` check-run concluded success, and no alert listing was obtained.

## Remaining (not done here)

- One independent T3 review on the exact head `a889f4ad`, per the grant.
- The owner-reserved non-author approval path for `main`, which lands through PR #27 first.
- The evidence repo is not committed.
