# GH-LANES report (EXEC-42D8C5B5, T3, builder claude_opus_5_5)

## Rev 2: closure of REVIEW_A, 2026-09-27 21:36Z (this section supersedes the rev-1 sections below)
- **Reviewed harness: `0c97a84f1ca833bacdd7c20c2cfabf20430504a9`** on `proof/harness`.
  - It is a new commit on top of `4a88f3eb`, not a force-push.
  - Diff vs 4a88f3eb: 7 files, +266/-136.
- **Launcher commit: `875aee68`**. It changes only one line: `proof/trigger.sh` `DEFAULT_HARNESS_SHA=0c97a84f…`. This is
  the current head of proof/harness.
  - The runs are parented on 0c97a84f, not on 875aee68.
  - A commit cannot contain its own SHA, so the default is set in this separate commit.
- Identity: Bradley Gleave, through the hooks. Pushes went only to `proof/harness` and `proof/run/*`.
- File sha256 at 875aee68:
  - `stage.sh` `6594c6d5…`
  - `lanes.sh` `612cf7d7…`
  - `preflight.sh` `3fa020f5…`
  - `aggregate.sh` `e2c929a5…`
  - `trigger.sh` `e52fff31…` (0c97a84f differs only in the default line)
  - `setup-runner.sh` `1ea38fce…` (unchanged)
  - `proof-lanes.yml` `c43fbc67…`

| finding | closure (where) |
|---|---|
| A1 partial ≠ proof | The default is FULL mode. The manifest is derived from the target tree: every stage of both lanes, with journey-full included iff it is present (`lanes.sh manifest`). `STAGES` is refused unless `PARTIAL=1`, and `PARTIAL=1` is refused without `STAGES` (`pt_parse`). FULL mode needs every lane nonempty (preflight + aggregate) and each lane total > 0 with all tests passed (aggregate). Only FULL mode can print `VERDICT: PASS`. A clean PARTIAL run prints `PARTIAL (…NOT a proof…)` and the aggregate exits **78**, so the workflow is red. |
| A2 pin on absent stage | Preflight refuses an `EXPECT_<stage>` whose stage is not `run` in the manifest, and an `EXPECT_TOTAL_<lane>` for a lane with no stage. The aggregate also fails if any pin was not checked. The summary lists each checked pin with its observed value. |
| A3 key typos | Exact allowlist in `pt_parse`: `HARNESS_SHA`, `PKG_LOCK_SHA256`, `STAGES`, `PARTIAL`, `EXPECT_TOTAL_{s11,s10b}`, and `EXPECT_<one of the 9 stage names>`. Values must be decimal only. Duplicate keys, unknown keys and malformed lines are refused. The same parser runs in preflight and again in the aggregate. |
| A4 shared state | Matrix jobs `lane s11 ALL` and `lane s10b ALL` are the authoritative jobs. Each runs its lane's stages **serially on one cluster with one bootstrap**, in the lane-s11.sh / lane-s10b.sh order, stopping at the first failure (`stage.sh <lane> ALL`). The two lanes run in parallel. The per-stage jobs are kept as a fast signal. The aggregate needs every per-stage job to PASS with the **same count** as the lane, and the lane receipt's stage list to equal the manifest exactly. |
| A5 job results | The aggregate gets `NEEDS_JSON=${{ toJSON(needs) }}`. It fails unless every needed job is `success`, and `preflight` and `run` must both be present. |
| A6 harness binding | `trigger.sh` takes `HARNESS_SHA` (default 0c97a84f), requires it to be a commit on proof/harness, and parents the run commit on exactly it. It writes `HARNESS_SHA=` into PROOF_TARGET, which is required. Preflight and aggregate (`run_binding`, fetch-depth 2) require exactly one parent == HARNESS_SHA, `git diff --name-only HEAD^ HEAD` == `PROOF_TARGET`, and a clean checkout. The summary prints `harness_sha` and the run commit. |
| B1 migration set | Every live job writes `migrations-applied.txt` (finished, non-rolled-back names, sorted) and `migrations-at-head.txt`. It requires them to be byte-equal, with 0 duplicates and total rows == applied rows (no unfinished or rolled-back row). Bootstrap reports `exact_set=yes`. The aggregate requires it in every receipt. |

### Rev-2 qualification (receipts in `ghlanes/runs/<label>/`)
| run | URL | expected | result | wall-clock |
|---|---|---|---|---|
| qual2-419a756d-full-r1: FULL, pins s11=133, s10b=42, guard=95 (run commit 63f8af92) | https://github.com/BradleyGleavePortfolio/growth-project-backend/actions/runs/36351463274 | PASS | **success, VERDICT: PASS**, 3/3 pins checked | 13 m 58 s (21:22:05–21:36:03Z) |
| neg2-typo-key-r1: `EXPECT_guarrd=95` (run commit f5241e4e) | https://github.com/BradleyGleavePortfolio/growth-project-backend/actions/runs/36351482941 | fail in preflight | **failure**: `PREFLIGHT_FAIL PROOF_TARGET refused: unknown stage in EXPECT_guarrd`. The run matrix was skipped. The aggregate returned FAIL (preflight=failure, run=skipped, refused key). | 55 s |
| partial2-419a756d-r1: `STAGES=guard,s10-unseen PARTIAL=1 EXPECT_guard=95` (run commit 6ca69429) | https://github.com/BradleyGleavePortfolio/growth-project-backend/actions/runs/36351497200 | never PASS | **failure (exit 78)**, `VERDICT: PARTIAL (diagnostic subset; NOT a proof…)`: s11 guard 95/95, s10b s10-unseen 10/10, 1 pin checked | 1 m 54 s |

Full-run serial lane receipts, 419a756d, compared with the local `compose/s11-v1` and `compose/s10b-v1`:

| lane | stage | GH passed/total (jest s) | local |
|---|---|---|---|
| S11 (755 s) | bootstrap | exact_set=yes, 173 migrations | 173 migrations |
| S11 | rls-g2-s11 | 6/6 (54) | 6/6 |
| S11 | journey-core | 8/8 (187) | 8/8 |
| S11 | readiness | 6/6 (80) | 6/6 |
| S11 | settle-redrive | 8/8 (238) | 8/8 |
| S11 | journey-induction | 4/4 (83) | 4/4 |
| S11 | journey-full | 6/6 (93) | 6/6 |
| S11 | guard | 95/95 (9) | 95/95 |
| S11 | **total** | **133/133** | **133/133** |
| S10-B (168 s) | bootstrap | exact_set=yes | |
| S10-B | rls-s10b-s10c | 32/32, 2 suites (146) | 32/32 |
| S10-B | s10-unseen | 10/10 (12) | 10/10 |
| S10-B | **total** | **42/42** | **42/42** |

- Stage order: `bootstrap rls-g2-s11 journey-core readiness settle-redrive journey-induction journey-full guard`, and
  `bootstrap rls-s10b-s10c s10-unseen`. These match the local runners.
- Every per-stage fast-signal job had the same counts as its lane.
- Binding: TREE `6ce65c1b…`, pkg-lock `b7fed5ed…`, client `2c819c8a…`. All equal the local receipts.
- An authoritative proof now takes about 14 min. That is bounded by the serial S11 lane (755 s of script time plus about
  1.5 min of setup), compared with about 38 min for the two serialized local lanes. The per-stage signal arrives in
  about 5 min.

Trigger (rev 2), from a clean clone at proof/harness, with bash api_credentials ["github"]:
```
PROOF_REMOTE=preserve proof/trigger.sh <new-label> <40-hex sha> EXPECT_TOTAL_s11=N EXPECT_TOTAL_s10b=N EXPECT_guard=95
# optional override: HARNESS_SHA=<reviewed sha> ...; diagnostic only: STAGES=a,b PARTIAL=1
```

### Out-of-band acceptance script (automates the REVIEW_A delta checklist)
- Script: `execution/42d8c5b5/proof/gh-accept.sh`, sha256 `95e5b9ff9a67e5de2a3d646325887de709b85427af25b25e2c61b3ccd203e4fe`.
  I did not change proof/harness.
- Usage: `proof/gh-accept.sh <run_id> <target_sha40> EXPECT_TOTAL_s11=N EXPECT_TOTAL_s10b=N EXPECT_guard=N [EXPECT_<stage>=N…]`,
  run with bash api_credentials ["github"].
- These values are fixed in the script and never read from the run: harness `0c97a84f…`, the repo, the workflow path and
  the accepted package-lock.
- Each call downloads what it reads to `ghlanes/runs/<label>/accept-<run>-a<attempt>-<utc>/`:
  - run.json and jobs.json
  - all artifacts
  - PROOF_TARGET
  - the approved lanes.sh
  - the manifest
  - ACCEPTANCE.txt, a copy of the output
- Results:
  - `36351463274` (FULL, 419a756d, pins 133/42/95): **ACCEPT**, exit 0, 18 CHECK lines
  - `36351497200` (PARTIAL): **REJECT** "PROOF_TARGET has STAGES/PARTIAL", exit 1
  - `36351482941` (typo): **REJECT** "PROOF_TARGET pin EXPECT_guarrd=95 not among the supplied pins", exit 1

### Consumer rule (what the harness cannot enforce on itself)
A run commit can carry any workflow. Before accepting a run, check out of band that:
- `harness_sha` in the summary == the reviewed SHA, and `git rev-parse <run commit>^` == that SHA
- `git diff --name-only <run>^ <run>` == `PROOF_TARGET`
- the overall workflow conclusion is `success` and the summary says `mode FULL` and `VERDICT: PASS`

### Remaining limits (rev 2)
- **C, policy on what we accept.** The per-stage jobs still use one fresh cluster per stage. They are a signal only, but a
  failure in one makes the run red. That is fail closed, and a flaky per-stage job costs a re-run.
- **C, local vs GH rule.** The exact migration-set rule (B1) is stricter than the local runners' count+max rule. The local
  runners are unchanged.
- **C, PARTIAL runs are red.** They exit 78 by design. Read their SUMMARY for the diagnostic counts.
- Rev-1 runs, including the rev-1 qualification, were bound to 4a88f3eb and are superseded as proof evidence by the
  rev-2 runs above.

---
# Rev 1 (superseded; kept for history)

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
