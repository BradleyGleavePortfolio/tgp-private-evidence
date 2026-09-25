# PR #530 production-merge safety assessment (T4, independent, read-only)

- Assessor: independent T4 production-release assessor (subagent), 2026-09-25 18:15Z
- Repo: BradleyGleavePortfolio/growth-project-backend, PR #530 `integration/importer` -> `main` (draft, MERGEABLE/CLEAN, all checks green)
- Assessed heads:
  - **A = `df713fd9217df524915348ef8a42c797f288dde1`** (= `origin/integration/importer` at 18:15Z; PR #530 head)
  - **B = `1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47`** (land/s8-c = S8-C composition `2542af44` + one test-only commit; PR #540 -> integration/importer, all checks green at 18:15Z, FF not yet performed)
- Base: `main` = `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`; merge-base(A, main) = `c23b9d9f` (A and B are both fast-forwardable onto main; A is an ancestor of B).
- Method: git/gh read-only, GitHub API read-only, Supabase prod catalog read-only (counts/catalog only; no customer rows read). No test runs, no writes anywhere. Tool outputs: `current_session_context/tool_calls/bash/*.log`.

---

## VERDICT: SAFE-WITH-CONDITIONS to merge — SAFE-TO-MERGE at `df713fd9` now, or at `1c10e2a1` once it is on `integration/importer` and PR #530's checks re-run green

**Key fact the whole verdict rests on: merging #530 to `main` is a git-only event. It does not deploy anything and does not touch the production database.** The PR replaces `.github/workflows/fly-deploy.yml` (today `on: push: branches: [main]`) with a `workflow_dispatch`-only workflow. GitHub runs push-triggered workflows from the workflow file *in the pushed commit*, so after the merge the only workflows that fire on `main` are `ci.yml`, `codeql.yml`, `dependency-audit.yml`, `infra-lint.yml`, `release-please.yml` (opens a release PR only), `sbom.yml`. None of them talk to Fly or mutate the prod DB (`ci.yml`'s `rls-floor-guard` uses `DATABASE_URL_AUDIT` read-only, as on main today).

Consequently the production risk of the *merge* is nil; all real risk sits in the *first deploy after the merge*, which is a separate, human-dispatched step with its own preconditions (section 7). That deploy is required anyway: production is currently running image `5076a07a` (last successful Fly deploy 2026-07-23); the `c23b9d9f` deploy of 2026-09-09 (run 34404749133) failed at the builder step with `ensure depot builder failed (status 403): Your account has overdue invoices`.

### Merge conditions (all cheap, all owner-side)
1. **Pin the exact sha.** Merge only with `--match-head-commit <sha>` (or an FF push of that exact sha). Do not merge "whatever integration/importer is at" — LAND-2 may FF `1c10e2a1` onto it at any moment.
2. **Choose A or B explicitly.** Both are assessed SAFE for merge. B adds only flag-gated code under `/api/scout/reconstruct` (no migrations, no workflow/fly/Dockerfile/package changes; see section 2.1). If B is chosen, wait until `integration/importer == 1c10e2a1` and PR #530's checks are green for that head before merging.
3. **Mark PR #530 ready and retitle it** (drop "DO NOT MERGE (prod deploy boundary)"; the title was the production boundary in HALF_DONE_WORK B2, which this assessment supersedes on the owner's instruction). Cosmetic, but a merge commit inherits the title.
4. **Do not dispatch `Fly Deploy` in the same motion.** Deploy preconditions are in section 7; several are not yet met (Fly billing, GitHub `production` environment).

No Safety-ROI blocker: no class-A/B harm reachable from the merge itself. Class-C notes are listed in section 8.

---

## 1. What merging to `main` triggers

| Item | On `main` today (`c23b9d9f`) | After merge (A or B) | Assessment |
| --- | --- | --- | --- |
| `.github/workflows/fly-deploy.yml` | `on: push: branches: [main]` -> `flyctl deploy` | `workflow_dispatch` only. Inputs: `release_sha` (40-hex, must equal `main` head), `confirm=deploy`, `migrations=apply-migrations` ack. Job `Release evidence gate` (`scripts/ci/release-evidence-gate.sh`) then job `deploy` bound to `environment: production`, `--image-label sha-<sha>`, `migration-delta.sh`, `verify-fly-release.sh`, `/readyz` probe | **Merge does not deploy.** Deploy requires a human dispatch. |
| `release-please.yml` | on push main | unchanged: creates/updates a release PR only | harmless |
| `ci.yml`, `codeql.yml`, `sbom.yml`, `dependency-audit.yml`, `infra-lint.yml` | on push main | run on the merge sha; they are exactly the runs the new evidence gate later requires for `release_sha` | expected, desirable |
| `fly.toml` | `release_command = "bash ./scripts/release.sh"` | same, plus `[[http_service.checks]]` `GET /readyz` (grace 30s, interval 15s, timeout 5s). `/readyz` is excluded from the `/api` prefix (`main.ts`) and bounded by a 3s DB timeout | deploy-time only |
| `scripts/release.sh` | status/deploy/verify | S2 closure: step 0 requires `scripts/release-required-verifiers.txt` (lists `20261224000000_rls_close_public_exposure`) and every `verify.sql` present; step 4 runs every `prisma/migrations/*/verify.sql` via `prisma db execute --url $DIRECT_URL`; `set -Eeuo pipefail` | deploy-time only; fails closed before any DB mutation if the contract is missing |
| `Dockerfile` | single stage `node:20-slim` | multi-stage (`build` -> `runtime`), `npm ci --omit=dev`, `postinstall: prisma generate` (fails the build if generation fails), artifact self-check, `USER node`. **No CI job builds this image**; first real build is the Fly remote build | deploy-time risk, class B proof gap -> section 7 |
| Operator workflows (`fly-feature-flags-set.yml`, `fly-secrets-set.yml`, ...) | dispatch only | dispatch only, now bound to `environment: production` | never auto-run |

Verified: 8 new migration directories are the entire `prisma/migrations` delta (164 on main -> 172 at A and at B).

## 2. Migrations in range (8; none added by the S8-C delta)

All eight were verified against the live prod catalog (Supabase project `rpyfdsgxxltzutgqeouk`, PG 17.6 — same major as the v4/v5 proof harness). Prod `_prisma_migrations`: 164 applied, last `20261223000300_scout_reconstructed_entity` (= main). The two unfinished rows are `00000000000000_baseline` attempts from April 2026 with `rolled_back_at` set — harmless to `migrate deploy`.

| Migration | Ops | Locks / timeouts | Prod precondition check (read-only) | Reversible |
| --- | --- | --- | --- | --- |
| `20261224000000_rls_close_public_exposure` (S1-DB-01) | ENABLE + FORCE RLS, `service_role` permissive policy, deny-all `anon`/`authenticated`, REVOKE on 14 tables + `community_messages` partitions; new fn `community_messages_protect_partition`; CREATE OR REPLACE partition-creator + `app.*` helpers with pinned `search_path` | `lock_timeout 5s`, `statement_timeout 60s`; ACCESS EXCLUSIVE per table; idempotent; RAISEs if a table/role is missing | All 14 tables exist, `relkind='r'`, owner `postgres`, RLS off, 0 policies, **all empty (0 live rows)**. ACLs: `postgres`/`anon`/`authenticated`/`service_role` = `arwdDxtm/postgres` on every target and on partitions `2026_12`, `2027_01`, `2027_02`, `default` -> REVOKE by grantor `postgres` succeeds; `verify.sql` "service_role path intact" assertion already true. Roles `anon`, `authenticated`, `service_role` exist | `down.sql` + `verify.sql` present |
| `20270117_durable_import_setup` (C1) | CREATE `ImportIntent` + RLS; `ExtensionPairCode.import_intent_id` nullable + FK | additive | `ExtensionPairCode` exists, RLS+FORCE, 0 rows | `down.sql` |
| `20270118_scout_ledger_platform_expand` (G2-E) | ADD `ScoutReconstructionLedger.source_platform TEXT NULL`; refuses rerun | `LOCK ... ACCESS EXCLUSIVE`, `lock_timeout 5s`, `statement_timeout 30s`, BEGIN/COMMIT | ledger exists, no `source_platform` yet, RLS+FORCE, 0 rows; prerequisite index names match (63-char truncation matches `::name`) | `down.sql` |
| `20270119_scout_ledger_obsolete_writer_fence` (G2-B) | BEFORE INSERT trigger refusing NULL `source_platform` | same | fence fn absent (expected) | `down.sql` |
| `20270120_scout_identity_ready` (G2-R) | SET NOT NULL `source_platform`, canonical CHECKs, wide unique indexes; RAISEs if any NULL rows | same | ledger has **0 rows** -> gate trivially satisfied | `down.sql` |
| `20270121_scout_identity_contract` (G2-C) | DROP two narrow unique indexes (contraction) | same | indexes exist exactly as expected | `down.sql` recreates them; Prisma history is not rewritten (operator `migrate resolve` needed) — forward-only in practice |
| `20270122_scout_native_provenance_expand` (S8-N) | CREATE `ImportNativeProvenance` + RLS; ledger `target_kind` + CHECKs | additive | ledger 0 rows | `down.sql` |
| `20270123_scout_run_lifecycle_expand` (S7-L) | `ScoutImport` +10 cols (`mode DEFAULT 'legacy'`, `execution_epoch DEFAULT 1`, ...), CHECK `mode_shape` requiring legacy `terminal_status in (success,partial,failed)`, partial unique idx, FK to `ImportIntent` | same | `ScoutImport` **0 rows** (no `terminal_status` values) -> CHECK trivially satisfied | `down.sql` |

Would any fail on the live DB? **No finding says so.** Every prerequisite gate the migrations RAISE on is observed satisfied; every data-dependent constraint (NOT NULL, CHECK, unique) is applied to empty tables (`ScoutReconstructionLedger`=0, `ScoutIngestEntity`=0, `ScoutImport`=0, `ExtensionPairCode`=0, `ScoutReconstructedEntity`=0, `Person`=0, `User`=1; DB 24 MB). Lock contention is not a concern at that size; `lock_timeout 5s` bounds it anyway. Collapsing the E/T/B/R/N/C sequencing into one deploy is harmless because there is nothing to backfill (the G2-B backfill CLI `src/scout/scout-ledger-backfill.cli.ts` is operator-run only, never wired into the app).

RLS impact on the serving path: prod `pg_roles` has exactly one login-capable role, `postgres` (`rolbypassrls=true`); `pg_stat_activity` shows the app's 8 client connections as `postgres`; `schema.prisma` documents `DATABASE_URL` as `postgres.<ref>@...pooler`. The RLS migration is therefore a no-op for the app path (FORCE RLS does not apply to BYPASSRLS roles) and closes the long-open "serving role" hold (S1-R3B-03 / S1-A-06 / EVR-04) by direct observation. `main` already has 21 `service_role`-only FORCE-RLS tables, so this is the established pattern. Note: `verify.sql` will print `VERIFY NOTE: current role postgres is not BYPASSRLS` only if run as a non-bypass role — not the case here.

CI dry-run coverage: `migration-dry-run.yml` proves forward apply + `down.sql` byte-identical reversal on `postgres:15.18`; the v4/v5 real-PG proofs (S7L/S8C acceptance) ran on PG 17.6. PR checks "Forward migrations apply cleanly" and "New migrations are reversible" are green at A.

### 2.1 S8-C delta (A -> B, `df713fd9..1c10e2a1`)
25 files, +5251/-19. `src/` changes are confined to `src/scout/reconstruct/{families,mapping-spec}.ts`, `src/scout/reconstruct/native/*.ts` (contract, families, provenance, rule-registry, rules, writers, persist-outcome), `src/scout/scout-reconstruct.{dto,service}.ts`; plus `docs/contracts/importer-openapi.json` and tests. Reviewed `scout-reconstruct.service.ts`: the native-writer outcome is consumed inside the existing per-row `$transaction` (target-before-ledger lock order kept), `target_kind` is written only alongside a typed target, legacy `string|null` results unchanged. New `programs` family in the closed allow-list. No migrations, no `.github/`, `fly.toml`, `Dockerfile`, `package*.json`, env-validation or `prod-switches.yml` changes. Only reachable via `/api/scout/reconstruct` (requires both `FEATURE_SCOUT_INGEST` and `FEATURE_SCOUT_RECONSTRUCT` = `'true'`). PR #540 checks all pass at 18:15Z (build-and-test, rls-floor-guard, rls-live-tests, mwb-3-live-tests, npm audit, test-deploy-readiness, ...).

## 3. Boot safety
- **No new required env vars.** The only new `process.env` reference across the whole range is `FEATURE_EXTENSION_PAIRING` (pre-existing flag). No `env-validation.ts` / `ENV_RULES` / `prod-switches.yml` changes.
- **No new workers/crons.** No new `@Cron`/`@Interval`/`@Timeout`/`setInterval`/`onModuleInit` in the diff. `ScoutModule` gains `ScoutLifecycleService` + `ScoutRunController` (request-driven). The G2-B backfill is a CLI only.
- **No new external calls** at boot. `PrismaService.$connect` remains fire-and-forget; `main.ts` wires `reportProcessError`; `/readyz` bounded by 3s timeout and returns a generic `database_unavailable`.
- Dependencies pinned to exact versions (no range bumps that would change resolution); `prisma` 6.19.3 stays in `dependencies` (needed by `release_command` in the `--omit=dev` runtime image; the Dockerfile asserts it resolves).
- Runtime image now runs as `USER node`; `release.sh` writes only to `/tmp`. Never built in CI (section 7, D3).

## 4. Exposure
- `FEATURE_GATED_ROUTES` unchanged: `/api/scout` -> `FEATURE_SCOUT_INGEST`; `/api/scout/reconstruct` -> additionally `FEATURE_SCOUT_RECONSTRUCT`; `/api/extension/pair` -> `FEATURE_EXTENSION_PAIRING`. Middleware returns a uniform 404 unless the env var is literally `'true'`, evaluated per request.
- `prod-switches.yml`: all three flags tier `feature`, `prod_default OFF`, `auto_flip false`, owner importer. `fly-feature-flags-set.yml` is dispatch-only (its `'true'` defaults are input defaults, never auto-applied). Whether any of the three is currently set in Fly secrets is **unverifiable read-only** -> deploy precondition D4.
- New routes, all inside gated prefixes: `POST /api/scout/runs/start`, `POST /api/scout/runs/cancel` (S7-L), `POST /api/extension/pair/session`, `POST /api/extension/pair/current` (C1), native writers under `/api/scout/reconstruct` (S8-C).
- Changed files **outside** gated prefixes (A and B identical here): `src/analytics/events.ts` (3 new event names), `src/common/cache-control.interceptor.ts` (`/readyz` added to no-store list), `src/filters/http-exception.filter.ts`, `src/filters/throttler-exception.filter.ts`, `src/observability/{logging.interceptor,orm-diagnostics,process-errors,sentry-config}.ts`, `src/health/health.controller.ts`, `src/main.ts`, `src/prisma.service.ts`. These are observability/sanitisation changes: logs/Sentry now record `request.route.path` instead of the raw URL, ORM errors are replaced by a generic `DatabaseRequestError`. **One client-visible behaviour change**: an `HttpException` whose cause chain contains a Prisma error now returns the generic envelope body instead of the exception's own body (status code, correlation id and all non-ORM `HttpException` bodies unchanged). `/readyz` 503 body `error` becomes the constant `database_unavailable`.
- **Mobile `main affc2818` compatibility**: no existing non-gated controller/DTO changed (`git diff --name-only ... -- src | grep controller` -> only `extension-pair`, `health`, `scout/*`). Every changed route is behind a flag that is OFF in prod and already returns 404 on main today, so mobile behaviour is unchanged regardless of which routes the mobile app calls. Direct inspection of the mobile repo was not performed (not needed for this conclusion).
- Adjacent open PRs against `main` (e.g. #522 idempotency key change) are not contained in A/B; they may need rebasing after the merge — not a safety matter.

## 5. Rollback
- **Code**: the new deploy flow is forward-only by design (revert PR on `main` + redispatch). `machines-before.json` in the deploy job records the previous image for the emergency ungated route (runbook §3/§7; target tag from `machines-before.json`). Old-image rollback after the migrations have applied is **data-safe while the three flags stay OFF**: new columns are nullable or defaulted (`mode`, `execution_epoch`), Prisma selects explicit columns (additive columns are invisible to the old client), new tables are ignored, RLS is a no-op for `postgres`, and every scout/extension table is empty.
- **Schema**: all 8 have `down.sql`; `down.sql` does not rewrite `_prisma_migrations` (needs `prisma migrate resolve --rolled-back`), and G2-C is a contraction, so treat the set as forward-only operationally. Runbook §7/§11.4 cover "aborted at step 2+ keeps applied migrations".
- **Merge itself**: reversible by `git revert -m 1 <merge sha>` (merge commit) or by resetting `main` to `c23b9d9f` (unprotected branch; FF case) — nothing downstream consumes the push.

## 6. Evidence state
- `LAST_OPERATOR_STATE.md` (17:12Z): S7-L accepted and landed at `df713fd9` via PR #539 (v4 real-PG proof 24/24, dual GO, `S7L_ACCEPTANCE.md`); S8-C accepted (`64e33dc7/S8C_ACCEPTANCE.md`, v5 proof); LAND-2 composition `2542af44`; L2-1 class-B test-only CI failure fixed by BC-6 = `1c10e2a1`; "No product-defect A/B is open." Consistent with what git/GitHub show at 18:15Z (PR #540 now green, FF still pending).
- `execution/daceddc8/SCOPE.md` "Owner instruction: merge if safe (18:00Z)": backend #530 merge "happens only on a SAFE verdict, pinned to an exact head sha. Bradley confirms the exact payload first." -> this document supplies the verdict and the shas; owner picks A or B.
- `HALF_DONE_WORK.md` B2: #530 "draft, DO NOT MERGE" was the production boundary. Superseded by the owner's instruction, and materially by the fact that the merge no longer deploys (the old boundary assumed auto-deploy on `main`).
- **Stale statements to correct in evidence after merge**: several docs (LAST_OPERATOR_STATE, landing PLAN) say "deploys run only on a push to `main`" / "main auto-deploys". True for `c23b9d9f`; false for A/B.
- `docs/delivery-controls.md` §6 already records the hosted settings as UNKNOWN/not enforced (no branch protection, `can_admins_bypass=true`). Observed: `main` `protected:false`; the only GitHub environment is `noble-celebration / production` (Fly-created 2026-03-14, `protection_rules: []`, `can_admins_bypass: true`); **no `production` environment exists**. Repo is public on a free User plan, so environment protection rules are available.

## 7. Deploy preconditions (NOT merge preconditions — separate owner step)
D1. **Fly billing**: clear the overdue invoices on the `bradleyapple1031` Fly account (last deploy attempt 2026-09-09 failed 403 at the depot builder). Verify with a read-only `Fly Logs (operator)` / `fly status` before dispatching.
D2. **GitHub environment `production`**: create it with >= 1 required reviewer (a real human account; self-approval is allowed by GitHub for environments) and `can_admins_bypass=false`; otherwise `release-evidence-gate.sh` fails closed (`environment 'production' is not protected`). Alternative: the runbook §3/§7 emergency ungated route, which forfeits the gate.
D3. **Runtime image proof gap (class B)**: the multi-stage `Dockerfile` (`--omit=dev`, `USER node`, postinstall `prisma generate`) has never been built by CI. Build it once (local `docker build` or a CI job) and smoke `node dist/main.js` + `bash scripts/release.sh` step 0 in the image before the first dispatch, or accept that a build/boot failure surfaces at deploy time (builder failure = no harm; boot failure after `release_command` = migrations applied, machine unhealthy -> use `machines-before.json` image rollback, data-safe per §5).
D4. **Flags OFF**: dispatch `fly-secrets-list.yml` and confirm `FEATURE_SCOUT_INGEST`, `FEATURE_SCOUT_RECONSTRUCT`, `FEATURE_EXTENSION_PAIRING` are unset or not `'true'`.
D5. Required evidence runs green on `main` for `release_sha`: `ci.yml` (build-and-test, rls-floor-guard, rls-live-tests, mwb-3-live-tests), `codeql.yml`, `sbom.yml`, `dependency-audit.yml` — these are the runs the merge push triggers.
D6. Dispatch `Fly Deploy` with `release_sha=<main head>`, `confirm=deploy`, `migrations=apply-migrations` (the previous image carries no `GH_SHA` label, so `migration-delta.sh` will report an unknown delta and require the ack).

## 8. Class-C notes (no action required for merge)
- `HttpExceptionFilter` ORM-boundary body change (section 4) — intentional sanitisation; clients reading `message` on Prisma-caused 4xx/5xx get generic text.
- `release-please` will open a release PR after the merge; ignore or merge at leisure.
- PR #530 title still says "DO NOT MERGE"; Danger passes, but retitle before merging.
- Evidence docs assert auto-deploy on `main`; update after merge.

---

## Merge method and commands (owner executes; assessor is read-only)

Repo convention: `main` history is mixed (16 merge commits in the last 200 first-parent commits; recent landings were single commits). Integration landings in this program were exact-bytes fast-forwards preserving accepted shas. Squash is **not** recommended: it would discard the 90/91 accepted commit shas that the evidence pins (`df713fd9`, `2542af44`, `1c10e2a1`, ...). Two acceptable methods, in order of preference:

**Option 1 — fast-forward push (main tip == accepted sha; GitHub auto-marks #530 merged):**
```
gh pr ready 530 --repo BradleyGleavePortfolio/growth-project-backend
gh pr edit 530 --repo BradleyGleavePortfolio/growth-project-backend --title "feat(importer): land integration/importer (S1..S8 foundation) to main"
git fetch origin && git merge-base --is-ancestor c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7 df713fd9217df524915348ef8a42c797f288dde1 && \
git push origin df713fd9217df524915348ef8a42c797f288dde1:refs/heads/main
```
(For B, replace the sha with `1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47` after it is on `integration/importer` and #530 is green for that head.)

**Option 2 — merge commit via gh, pinned to the head:**
```
gh pr ready 530 --repo BradleyGleavePortfolio/growth-project-backend
gh pr merge 530 --repo BradleyGleavePortfolio/growth-project-backend --merge \
  --match-head-commit df713fd9217df524915348ef8a42c797f288dde1
```
(or `--match-head-commit 1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47` for B). `--match-head-commit` aborts if LAND-2 has moved the branch in the meantime.

## Post-merge verification checklist
1. `gh api repos/BradleyGleavePortfolio/growth-project-backend/branches/main --jq .commit.sha` equals the chosen sha (Option 1) or `git rev-parse <merge>^2` equals it (Option 2).
2. `gh run list --branch main --limit 15`: `ci`, `CodeQL`, `SBOM`, `dependency-audit`, `infra-lint`, `release-please` present and green; **no `Fly Deploy` run was triggered** (confirms the dispatch-only workflow took effect).
3. Prod unchanged: Supabase `_prisma_migrations` still 164 applied, last `20261223000300_scout_reconstructed_entity`; `GET https://<app>/health` unchanged (image still `5076a07a`).
4. PR #530 state `MERGED`; PR #540 either merged/FF'd (B) or still open (A).
5. Update evidence: `LAST_OPERATOR_STATE.md` (main sha, "merge no longer deploys"), `HALF_DONE_WORK.md` B2 closed, this file referenced.

## Post-deploy verification checklist (after D1–D6, separate step)
1. `Fly Deploy` run: evidence-gate job OK (manifest `release-evidence-<sha>.json`), deploy job OK.
2. Release log: step 0 verifier contract OK; step 2 `prisma migrate deploy` applied 8 migrations; step 3 `ALL_APPLIED=172`; step 4 `verifiers_passed = 1 (discovered=1, required=1)` and `S1-DB-01 VERIFY OK: 18 relations protected (4 community_messages partitions)`.
3. Supabase read-only: `_prisma_migrations` 172 applied, none unfinished; `relrowsecurity && relforcerowsecurity` true on the 14 tables; `ScoutReconstructionLedger.source_platform` NOT NULL; `ScoutImport.mode` present.
4. `GET /readyz` -> 200 `ok:true, db:up`; `GET /healthz` 200; Fly machine image label `sha-<sha>` via `verify-fly-release.sh` output; `/api/scout/*` and `/api/extension/pair/*` return 404 (flags OFF).
5. Sentry: no new `DatabaseRequestError` burst in the first 30 minutes; logs show `request.route.path` (no raw URLs).
