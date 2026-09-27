# GH-LANES report (EXEC-42D8C5B5, T3, builder claude_opus_5_5)

Result: **QUALIFIED.** The PG proof lanes now run on GitHub-hosted runners, one job per stage, all in parallel. Both
qualification heads match the local runners stage by stage. The bad-SHA negative control failed in preflight. No product
code was touched. The only remote writes were to `refs/heads/proof/**`. The evidence repo was not committed.

## Harness
- Branch `proof/harness` in BradleyGleavePortfolio/growth-project-backend. It is an orphan branch with no shared history
  with main.
- Qualified commit: **`4a88f3eb33f5affcc39486eccd0323a95936085f`**. Its parent `e49744d2` had an invalid workflow: it used
  the `runner.temp` context in a job-level `env`, so its runs failed at 0 s before any job started.
- Author and committer: Bradley Gleave <bradley@bradleytgpcoaching.com>. Committed through the lefthook hooks, which found
  no config on the orphan branch and did nothing. No trailers.
- Local clone: `/home/user/workspace/worktrees/ghlanes-harness`. Push to origin is disabled; the remote is `preserve`.
- Files and sha256:
  - `.github/workflows/proof-lanes.yml` `9d31078e…`
  - `proof/lanes.sh` `4a5a5398…`: the local STAGE_TABLEs and lane literals, copied verbatim, plus the pins
  - `proof/preflight.sh` `0c555da0…`
  - `proof/setup-runner.sh` `1ea38fce…`
  - `proof/stage.sh` `23285b02…`: a port of the local common body
  - `proof/aggregate.sh` `f2bbb7ef…`
  - `proof/trigger.sh` `4814a91a…`
  - `README.md`
- Flow:
  1. **preflight** (no PG): checks that the SHA is 40-hex, shallow-fetches exactly that commit (an unknown SHA fails here),
     checks the package-lock sha256 (default `b7fed5ed…9c55`; else REFUSED), refuses unknown PROOF_TARGET keys and unknown
     stages, and fails if a required spec is missing. It then emits the matrix. journey-full is dropped from the matrix and
     recorded as SKIP_ABSENT_AT_HEAD if it is absent at HEAD.
  2. **stage** (matrix, `fail-fast: false`). Each job:
     - fetches the target's full history into `target/`, detached and clean, then re-checks the package-lock sha
     - installs setup-node 20.20.1 and runs `npm ci` from the target's own lock
     - installs PG 17.6: the same zonky 17.6.0 jar as the local runtime, with the same jar/txz/postgres/initdb/pg_ctl sha256
       pins, cached. psql is 18.6 from PGDG, the same major as local.
     - starts a fresh cluster with the local postgresql.conf, runs the lane bootstrap (`migrate deploy`), then the identity
       check: 170006, cluster_name, DB marker, applied == migration dirs at HEAD, last == max dir, port
     - runs the stage with the local pass rules unchanged: rc 0; 0 failed/skipped/todo; passed == total; suites == file
       count; a PASS line per file; total == static `it(` count (>= for it.each). Same jest config, files and env,
       `--runInBand --ci --runTestsByPath`, `NODE_OPTIONS=--max-old-space-size=3072`.
     - uploads a `RESULT` receipt plus logs as artifact `result-<lane>-<stage>`
  3. **aggregate** (`if: always()`):
     - needs preflight success and a PASS receipt with RC=0 for every scheduled stage
     - needs 0 skipped and the same TREE, pkg-lock, client index.d.ts sha and migrations across all jobs
     - checks any pinned `EXPECT_TOTAL_<lane>` / `EXPECT_<stage>`
     - writes SUMMARY.md to the job summary and to artifact `summary`

## How to trigger
From a clean clone that is checked out on `proof/harness` (for example `worktrees/ghlanes-harness`), with push access to `proof/**`:
```
PROOF_REMOTE=<remote> proof/trigger.sh <new-label> <40-hex sha> [EXPECT_TOTAL_s11=N] [EXPECT_TOTAL_s10b=N] [EXPECT_guard=95] [STAGES=a,b] [PKG_LOCK_SHA256=<64hex>]
gh run list --repo BradleyGleavePortfolio/growth-project-backend --branch proof/run/<new-label>
```
Commands used here, from `/home/user/workspace/worktrees/ghlanes-harness`, with bash api_credentials ["github"]:
```
PROOF_REMOTE=preserve proof/trigger.sh qual-419a756d-r1 419a756da4e6eebc28e22b19d0c08d72549f6d4e EXPECT_TOTAL_s11=133 EXPECT_TOTAL_s10b=42 EXPECT_guard=95 EXPECT_journey-full=6
```
- `trigger.sh` does the following:
  - checks out `proof/run/<label>` from `proof/harness`
  - writes `PROOF_TARGET`
  - makes a normal commit, through the hooks
  - pushes to `refs/heads/proof/run/<label>` (it refuses if that branch already exists; never a force-push)
  - returns to the previous branch
- In this sandbox, `gh run view --repo …` returns a 403 rate limit, because it follows api.github.com links without
  authentication. `gh run list` and `gh api repos/<repo>/actions/runs/<id>/jobs` work through the proxy.
- Artifacts: `gh api repos/<repo>/actions/runs/<id>/artifacts`, then `gh api …/artifacts/<aid>/zip`.

## Qualification (downloaded receipts in `ghlanes/runs/<label>/`)
| run | URL | verdict | wall-clock (push → aggregate done) |
|---|---|---|---|
| qual-54be96f1-r2 (run commit ad0267d2) | https://github.com/BradleyGleavePortfolio/growth-project-backend/actions/runs/36349189355 | success | 5 m 24 s (20:45:12–20:50:36Z) |
| qual-419a756d-r1 (run commit 609c0d83) | https://github.com/BradleyGleavePortfolio/growth-project-backend/actions/runs/36349435510 | success | 6 m 07 s (20:49:15–20:55:22Z) |
| neg-badsha-r2 (deadbeef…, run commit 69a43778) | https://github.com/BradleyGleavePortfolio/growth-project-backend/actions/runs/36349192804 | **failure, as intended** | 16 s |

The two runs ran concurrently, which shows that several candidates can prove at once.

Per-stage passed/total, GH vs local. Local receipts: `proof/baseline-s11`, `proof/baseline-s10b`, `compose/s11-v1`,
`compose/s10b-v1`. GH jest seconds are in parentheses.
| stage | 54be96f1 GH | 54be96f1 local | 419a756d GH | 419a756d local |
|---|---|---|---|---|
| rls-g2-s11 | 6/6 (54) | 6/6 | 6/6 (42) | 6/6 |
| journey-core | 8/8 (136) | 8/8 | 8/8 (186) | 8/8 |
| readiness | 6/6 (75) | 6/6 | 6/6 (79) | 6/6 |
| settle-redrive | 8/8 (235) | 8/8 | 8/8 (246) | 8/8 |
| journey-induction | 4/4 (86) | 4/4 | 4/4 (90) | 4/4 |
| journey-full | SKIP_ABSENT_AT_HEAD | SKIP_ABSENT_AT_HEAD | 6/6 (94) | 6/6 |
| guard | 95/95 (9) | 95/95 | 95/95 (9) | 95/95 |
| **S11 TOTAL** | **127/127** | **127/127** | **133/133** | **133/133** |
| rls-s10b-s10c | 32/32, 2 suites (194) | 32/32 | 32/32 (199) | 32/32 |
| s10-unseen | 9/9 (16) | 9/9 | 10/10 (16) | 10/10 |
| **S10-B TOTAL** | **41/41** | **41/41** | **42/42** | **42/42** |

- Binding values are identical to the local receipts:
  - TREE `435fec78…` (54be96f1) and `6ce65c1b…` (419a756d)
  - pkg-lock `b7fed5ed…`
  - generated client index.d.ts `2c819c8a…aa56c`
  - 173/173 migrations, last `20270124000000_scout_run_observation_expand`
- 0 skipped in every job, and every bootstrap and identity check passed.
- Runner: ubuntu24 image 20260920.314.1, 4 vCPU, node v20.20.1, pg 17.6, psql 18.6.
- Speed: local serialized wall time was 986+461 s (about 24 min) for 54be96f1 and 1310+997 s (about 38 min) for 419a756d.
  On GH it is about 5–6 min, bounded by settle-redrive plus about 1.5 min of setup.
- Negative control: preflight logged `fatal: remote error: upload-pack: not our ref deadbeef…` and
  `PREFLIGHT_FAIL target … not fetchable`, then exited 70. The stage matrix was skipped and no PG was started. The aggregate
  failed on "preflight result=failure / no PREFLIGHT_OK receipt / empty matrix".
- Extra check, run locally with no PG: running aggregate.sh on the downloaded 54be96f1 receipts with `EXPECT_TOTAL_s11=128`
  exits 1 and prints "TOTAL 127/127 vs EXPECT_TOTAL_s11=128". A scheduled stage whose RESULT is missing is reported as a
  FAIL.

## Limits and findings
- **C, stage isolation.** Each live stage gets its own fresh cluster and bootstrap. Locally, the stages of a lane share one
  cluster in sequence. The counts are identical on both qualified heads. A future spec that relied on state left by an
  earlier stage would pass locally and fail on GH, never the other way round.
- **C, dependencies.** Locally, deps are copied from the donor. On GH they come from `npm ci` of the target lock. Equality
  is enforced by the pinned lock sha256 plus the matching generated-client sha. A candidate with a new lock needs
  `PKG_LOCK_SHA256=` in PROOF_TARGET, which is an explicit, recorded choice.
- **C, no lock, sentinel or donor checks on GH.** A hosted runner is private to its job, so these checks are omitted. The
  RESULT records HARNESS_COMMIT, which is the run commit; its parent is the harness. It also records the sha256 of
  stage.sh and lanes.sh instead of the local RUNNER_SHA256.
- **C, expectations are opt-in.** Without `EXPECT_*` keys, a stage checks only against its static `it(` count, and guard
  only as a lower bound (>= 11). Pin `EXPECT_guard=95` and the lane totals when you rely on a run.
- **C, external dependencies.** Maven Central (the jar is cached after the first run), PGDG apt and the npm registry.
  An outage fails the run closed; it does not produce a false pass.
- C: two failed 0-second runs remain from harness e49744d2 (runs 36349107451 and 36349110552 on proof/run/*-r1, plus one
  on proof/harness). Their branches are `proof/run/qual-54be96f1-r1` and `proof/run/neg-badsha-r1`. They are harmless and
  I did not delete them.
- No A or B findings. Stage definitions were not changed: `lanes.sh` equals the local STAGE_TABLEs.
