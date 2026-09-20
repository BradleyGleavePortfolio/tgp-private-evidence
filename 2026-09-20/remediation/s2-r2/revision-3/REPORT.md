# S2 delivery — R2 candidate (post-R1 remediation) — frozen handoff

Grade/model: T4 (trusted-check change), Claude (Fable 5 High lane) as S2 canonical builder. Compact by rule. Previous R1 report preserved verbatim as `REPORT_R1_frozen_b801a776.md`.

## Exact identity

| | value |
| --- | --- |
| Base (public main) | `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` (tree `842f17f7…`) |
| **Final head** | `0b05fcf5352287109ac88ed2ba3682e441e3a076` |
| **Final tree** | `fba0a9f06127979005b70ca3da80584a1e2ce10c` |
| Branch | `execute/20260920-s2-delivery` (worktree `/home/user/workspace/worktrees/s2-delivery`) |
| Chain | `b801a776` (R1 frozen, tag `s2-r1-frozen`, untouched) → `4a63b8ae` → `cb0bc910` (held commits reused byte-identical from `s2-post-r1-held`) → `47763380` (checkpoint, tree `17fbb37e…`) → `0b05fcf5` |
| Identity | author = committer = Bradley Gleave <bradley@bradleytgpcoaching.com> on every commit (`git var` checked before each); no co-author trailer |
| Bundles | `s2-delivery-r2-final.bundle` (prereq only `c23b9d9f`; refs branch, `s2-post-r1-held`, tag `s2-r1-frozen`; verified) — sha256 in `MANIFEST.md`. `s2-delivery-r2-checkpoint.bundle` (head `47763380`). `s2-compose-preview.bundle` (see Composition). |
| Composition preview (NOT the audit candidate) | local branch `s2-compose-preview` = `6b85395fd60a3a6fc91314f32f91a7cd2985b96c` (tree `801b5d3a…`) = S2 `0b05fcf5` + S3 `5c7b42b3` + S1 `90a66475`; requires those three heads. |

State: **written, focused-tested locally, R1-audited (two independent reports, NOT cleared), R2 NOT audited, not merged, not deployed, not enabled, not customer-accepted.** No audit clearance is claimed.

## Changed files vs base (29; +2121/−318) — R2 delta since cb0bc910 marked ★

Workflows: `fly-deploy.yml` ★ (pinned download-artifact v5.0.0 / setup-flyctl commit; `fetch-depth: 0`; `migrations` input; machines-before recorded and filtered; `migration-delta.sh` before deploy; `--wait-timeout 5m`; manifest finalized with `deploy_result`, uploaded as `release-manifest-<sha>-<job.status>`), `codeql.yml` ★ (codeql-action pinned `3ea06614` = v3.38.1), `sbom.yml`, `ci.yml` ★ (stale "not deployable from empty" note corrected to the measured S1 synthetic replay; no logic change), `r100-quality-gate.yml` (quotas retired, banned casts kept), 8× `fly-*.yml` ★ (setup-flyctl pinned; the 5 production-mutating ones bound to `environment: production`).
Scripts: `scripts/ci/release-evidence-gate.sh` ★ (CodeQL `error==""` and `rules_count>0`; duplicate job names all-green; SBOM zip must carry `sbom.cdx.json` + matching `.sha256` and is re-proved by `assert-prod-sbom.sh` against the lockfile; job separator `|`; default adds `dependency-audit.yml=npm audit (high+critical, whole graph)`), `filter-machines.sh` ★ new, `migration-delta.sh` ★ new, `verify-fly-release.sh`, `assert-prod-sbom.sh` ★ (header cite), `scripts/release.sh` ★ (step 4: every `prisma/migrations/*/verify.sql` via `prisma db execute --url DIRECT_URL`, fail-closed), `scripts/setup-branch-protection.sh` ★ (`REQUIRED_APPROVING_REVIEW_COUNT` and `CHECKS_APP_ID` are required inputs; no `app_id -1`; `build-sbom` and the dependency-audit job listed; no private path).
Image: `Dockerfile` ★ (`USER node`; `SCARF_ANALYTICS=false` on runtime `npm ci`), `.dockerignore`.
Docs: `docs/delivery-controls.md` ★ new (enforced vs claimed vs unmeasured; hosted settings UNKNOWN; recovery forward-only, direct `fly deploy --image` named ungated; §7.1 DB recovery rule from S1), `docs/deploy-runbook.md` ★ (§3 steps 4–5, §8, §8.1: no push-to-deploy; dispatch with `release_sha`; verifier is truth; never `migrate resolve --rolled-back` for a successful migration reversed out-of-band).
Tests: `test/ci/release-evidence-gate.spec.ts` ★ (43), `test/ci/delivery-artifact.spec.ts` ★ (71, incl. temp-git-repo behavioural negatives for `migration-delta.sh`, `filter-machines.sh` redaction, pin-format check on 11 workflows), `test/ci/r100-pathspec.spec.ts` (1), fixtures `fake-gh.sh`, `gate-lockfile.json` ★.

## Finding dispositions (every R1 finding)

| ID | Disposition | Where |
| --- | --- | --- |
| S2-A-01 env unenforced (material for deploy) | **Fixed in source, hosted state UNKNOWN**: gate refuses when `production` lacks a `required_reviewers` rule (`4a63b8ae`); hosted rule not set (no authorization). | gate step 5; `delivery-controls.md` §6 |
| S2-A-02 / S2-B4 empty CodeQL | **Fixed**: `error` must be empty, `rules_count>0`; 3 negatives. | gate; spec |
| S2-A-03 invariant 5 overstated | **Fixed**: gate now actually re-runs `assert-prod-sbom.sh` on the artifact against the checked-out lockfile; claim in docs matches. | gate; `delivery-controls.md` §2.4 |
| S2-A-04 / S2-B6 recovery & failed-deploy manifest | **Fixed (docs + evidence)**: forward-only gated route documented; direct `fly deploy --image` named **ungated** in runbook; manifest uploaded on failure with `deploy_result`; machines-before recorded. No gated rollback workflow was built (decision: forward-only). | runbook §3; workflow; §7 |
| S2-A-05 / S2-B7 migration coupling | **Mitigated at gate level**: `migration-delta.sh` refuses a release whose `prisma/migrations`/`schema.prisma` differ from the running `GH_SHA` without `migrations=apply-migrations`; stray ack refused; unknown running commit refused without ack; delta recorded in manifest. Verifier execution wired in `release.sh` step 4. Migration contents remain S1. | scripts; 8 behavioural tests |
| S2-A-06 raw machine config uploaded | **Fixed**: only `filter-machines.sh` output (no `config.env/services`, no check output text) reaches artifacts; test asserts redaction. | workflow; spec |
| S2-A-07 / S2-B1 mutable refs (material) | **Fixed & verified**: all `uses:` in 11 delivery/operator workflows are 40-hex; pins resolved with `git ls-remote` and confirmed via `gh api` after reauth (`action-pin-verification.log`): codeql-action `3ea06614`=v3.38.1 (peeled), download-artifact `634f93cb`=v5.0.0, upload-artifact `330a01c4`=v5.0.0, flyctl-actions `ed8efb33`=master@2026-09-20. `flyctl` binary itself still unpinned (documented). | workflows; log |
| S2-A-08 / S2-B3 private path refs; proposal absent; review count | **Fixed**: no `execution/…` path in repo; `docs/delivery-controls.md` carries the landing requirements; `setup-branch-protection.sh` takes `REQUIRED_APPROVING_REVIEW_COUNT` (0 = recorded single-maintainer decision, 1 = second real human) and `CHECKS_APP_ID` explicitly — no identity assumption, no fictional second identity. `LANDING_PROPOSAL.md` stays in the private evidence dir (API payloads). | script; docs |
| A-obs: build-sbom PR trigger | **Fixed** in `cb0bc910` (reused). | sbom.yml |
| A-obs: `deployment_branch_policy.protected_branches` vs rulesets | **Open (hosted, unmeasured)**; documented as verify-before-apply. | `LANDING_PROPOSAL.md` |
| A-obs / S2-B10: env-scoping `FLY_API_TOKEN` breaks other `fly-*.yml` | **Fixed**: the 5 mutating workflows now bind `environment: production` (so they can read an env secret and become reviewer-gated); the 3 read-only ones (`fly-logs`, `fly-logs-dump`, `fly-secrets-list`) are pinned but not env-bound — they would break if the token is moved; documented. | workflows; §6 |
| S2-B2 nothing executed (material gap) | **Partially addressed, honestly bounded**: isolated host replay of the runtime stage (`npm ci --omit=dev` with lifecycle → 357 pkgs, prisma generate OK; `nest build` OK; Dockerfile artifact assertion `OK`, exit 0) — `local-runtime-stage-replay.{log,sh}`. **No Docker image built, no workflow executed on GitHub** (no container runtime here; no dispatch authorized). Remains the first-run risk. | evidence dir |
| S2-B5 duplicate job names | **Fixed**: all same-name entries must be `completed/success`; 2 tests. | gate |
| S2-B8 composition with S3 | **Done as preview + inputs**: gate default and `REQUIRED_CHECKS` include `npm audit (high+critical, whole graph)` (fails closed until S3's `dependency-audit.yml` is on main — intended order). Local preview branch `s2-compose-preview` merges S3 `5c7b42b3` (one conflict, `r100-quality-gate.yml`: S3 checker body + S2 quota retirement; header records both sources) and S1 `90a66475` (no conflicts); two S3 scope tests re-pointed to `.github/r75-policy.json`; `npx jest test/ci` **394/394** on the tree of `367c3094` (pre-S1-merge); final `6b85395f` unexecuted. Not committed to the candidate; parent/S3 decide how to land. Found and fixed a real defect during composition: comma in the S3 job name broke the gate's job list parser. | preview bundle; `s2-compose-preview-test.log` |
| S2-B9 root / scarf / typescript | **Fixed** `USER node`, `SCARF_ANALYTICS=false`. `typescript` remains in the runtime closure (devOptional via Prisma; removing it is a dependency change outside S2). | Dockerfile |
| S2-B11 SBOM scope / sidecar | **Fixed**: sidecar required and matched; scope stated (npm production closure only; not OS/Node/engines) in manifest and docs. | gate; §5 |
| S3-B-10 (`/readyz` check), S3-B-11 (check-r75 base policy), pool risk | **Unchanged**: S3/S1-owned; dispositions in `CROSS_LANE_DISPOSITION.md`. `fly.toml` from S3 merges cleanly in the preview. | — |
| S1 requests (verify.sql wiring; `down.sql`; ci.yml note; `--rolled-back` rule) | **Done**: `release.sh` step 4; ci.yml note; runbook/docs recovery rule exactly as S1 states; S5 suggestion not adopted. `migration-dry-run.yml` untouched (it will find `down.sql` on the integrated head — not executed here). | scripts/docs |

## What ran (sandbox, node v20.20.1, under `execution/test-validation.lock`)

- **Revision 3 (authorized bounded proof):** `npx jest test/ci/release-evidence-gate.spec.ts test/ci/delivery-artifact.spec.ts test/ci/r100-pathspec.spec.ts` executed on the clean frozen head — contemporaneous stamps before and after: `head=0b05fcf5352287109ac88ed2ba3682e441e3a076 tree=fba0a9f06127979005b70ca3da80584a1e2ce10c`, `git status --short` 0 lines, node v20.20.1 / npm 10.8.2 / `NODE_OPTIONS` unset, 18:02:04Z → 18:02:26Z, `jest_exit=0`, **115 passed / 115** (`s2-r2-test-at-0b05fcf5.log`; exit captured directly, no pipe). This closes the candidate-identity gap for the focused suites; the earlier `s2-r2-test.log` remains as builder-attested pre-commit assurance. Final preview `6b85395f` still unexecuted.

- `npx jest test/ci/release-evidence-gate.spec.ts test/ci/delivery-artifact.spec.ts test/ci/r100-pathspec.spec.ts`: **115/115** (`s2-r2-test.log`, mtime 17:45:40Z). **Provenance is builder-attested, not self-stamped**: the log carries no head/tree header; it ran on the working tree 30 s before commit `0b05fcf5` (17:46:10Z). Between the run and the commit only `docs/delivery-controls.md` and `docs/deploy-runbook.md` were edited (prose; no spec reads their content). No test has been executed at exactly committed `0b05fcf5`.
- `npx jest test/ci` **394/394** (`s2-compose-preview-test.log`, mtime 17:55:52Z) ran on the working tree committed 10 s later as preview commit `367c3094` (S2+S3 only). **The final preview head `6b85395f` (after the S1 merge) is UNEXECUTED**; no inheritance is claimed.
- `bash -n` on all changed scripts; all `.github/workflows/*.yml` parse.
- Isolated runtime-stage replay (above), `git ls-remote`/`gh api` pin verification, `git bundle verify` on all bundles.

## What did NOT run / unmeasured (explicit)

Docker image build; any GitHub workflow run of the changed files; `flyctl` against the app; `migration-dry-run.yml` on `down.sql`; the full jest suite (S3 reports 8,209 on its head; not on mine); `GITHUB_TOKEN` ability to read environment protection (403 → gate fails closed); hosted settings (still `protection_rules: []`, `can_admins_bypass: true`, no branch protection/rulesets as last read); source↔image equivalence (unattested by design of `--remote-only`).

## Deterministic invariants (audit targets)

1. `fly-deploy.yml` has only `workflow_dispatch`; deploy job needs gate `success` and `release_sha == github.sha`; every `uses:` is a 40-hex pin.
2. Gate fails on: non-main/fork sha, missing/skipped/cancelled/in-progress/newest-failed required job, duplicate job with one non-success, CodeQL `error!=""` or `rules_count==0`, SBOM missing/sidecar mismatch/dev-only package present, environment without `required_reviewers`, dependency-audit run absent.
3. `migration-delta.sh`: non-empty or unknown delta ⇒ refused without `apply-migrations`; empty delta with ack ⇒ refused.
4. `release.sh` exits non-zero if any `prisma/migrations/*/verify.sql` fails; runs after `migrate deploy`, before success banner.
5. Uploaded evidence contains no machine `config`.
6. `setup-branch-protection.sh` cannot run without an explicit review-count and app-id decision.

## Ownership / boundaries

S2 owns workflows, Docker, release/CI scripts, focused tests, composition. Not touched: schema/migration contents (S1), `check-r75.js`/policy, `dependency-audit.yml` body (S3), hosted settings, secrets, production. Composition preview edits two S3-authored spec files (`r100-pathspec.spec.ts`, `r75-gate.spec.ts`) only to re-point scope assertions — flagged for S3.

## Smallest next action

Parent: publish `MANIFEST.md`-listed items privately; dispatch R2 dual audit at `0b05fcf5` (tree `fba0a9f0`) with the preview `6b85395f` as a separate, clearly-scoped exhibit. Owner (Bradley): record the review-count decision, then — with authorization — configure `production` reviewers and run `setup-branch-protection.sh`; first `Fly Deploy` dispatch is the first runtime evidence.
