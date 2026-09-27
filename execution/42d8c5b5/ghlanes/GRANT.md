# GH-LANES build grant (EXEC-42D8C5B5) — T3, builder claude_opus_5_5
Tier: T3. Why: a binding proof harness (evidence integrity for every landing); no product code; no change to main/integration/ci.yml.
Owner (12:22-12:33 PDT): backend repo is now PUBLIC → GitHub-hosted runners are free; "open up github supported lanes" and parallelize now.
Goal: run the PG proof lanes on GitHub Actions, one job per stage in parallel, against ANY backend commit SHA, so one landing proof drops from
~25 min serialized on this 2-CPU sandbox to one stage's wall-clock, and several candidates can prove at once.
Design (keep it this simple):
- Harness lives on an ORPHAN branch in BradleyGleavePortfolio/growth-project-backend: `proof/harness` (only .github/workflows/proof-lanes.yml +
  proof/*.sh + README). A run = push a new commit on a branch `proof/run/<label>` whose tree = harness + file `PROOF_TARGET` (40-hex backend SHA,
  optional stage list). Push trigger `on: push: branches: ['proof/run/**']` uses the workflow in the pushed commit, so nothing lands on
  main/integration and candidate trees are never modified. Concurrency group per branch.
- Jobs: matrix over stages of the two local runners: S11 lane {rls-g2-s11, journey-core, readiness, settle-redrive, journey-induction,
  journey-full (skip-if-absent), guard} and S10-B lane {rls-s10b-s10c, s10-unseen}. Each job: checkout harness; `git fetch` the target SHA into
  a separate dir; verify package-lock sha; setup-node 20.20.1; npm ci; PostgreSQL 17 (apt PGDG or official binaries — match the local 17.6 major);
  bootstrap = migrate deploy (assert migration count/last name = local runner's rule) ; run the stage exactly as the local runner does (same jest
  config, files, env, --runInBand, expected counts/static it counts, skip rules). Reuse/port the local runner logic
  (execution/42d8c5b5/proof/lane-s11.sh, lane-s10b.sh, REPORT.md — read them first) with sandbox paths parameterised; do not re-invent stage
  definitions. Fail closed: exit non-zero on count mismatch, skipped>0, missing suite, bad SHA (preflight, before PG).
- Aggregate job: collects per-stage RESULT receipts (artifact upload), writes a summary with HEAD/TREE/pkg-lock/migrations/per-stage counts and
  TOTAL, compares to the expected totals, and fails if any stage failed or is missing.
- Qualification (binding before the parent relies on it): run on 54be96f18c314cae35d1e5d3000af9f06d693d81 (local baseline S11 127/127 incl. guard
  95, S10-B 41/41) and on 419a756da4e6eebc28e22b19d0c08d72549f6d4e (composed landing head; local run in progress). Counts must match the local
  runners. Also one negative run with a bad SHA that must fail in preflight.
Access: git/gh with api_credentials ["github"]; pushes allowed ONLY to refs/heads/proof/** (never force-push anything else; never touch main,
integration/importer, land/*, cand/*). Commit as Bradley Gleave. Secrets: none needed (throwaway PG inside the job); never add repo secrets.
Watch runs with `gh run list/view/watch --repo BradleyGleavePortfolio/growth-project-backend`.
Report execution/42d8c5b5/ghlanes/REPORT.md: harness commit, how to trigger (exact commands), qualification run URLs + per-stage counts vs local,
wall-clock per run, limits. Rules: execution/42d8c5b5/WORKER_RULES.md (no local PG runs needed; the local lock is not required for GH runs).
