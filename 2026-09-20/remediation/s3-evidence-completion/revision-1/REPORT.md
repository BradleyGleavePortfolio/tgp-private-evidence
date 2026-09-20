# S3 backend reliability — REPORT

Status: **FINAL for round 1 — candidate written, built, type-checked, linted and tested on the exact head; NOT audit-cleared (auditor attestations pending), NOT merged, NOT deployed, NOT enabled, NOT customer-accepted.** No prior audit inherited; all proof is new work bound to this head. Source unchanged since the R1 freeze (`git status` clean; no held deltas exist). Dispositions of every A/B finding: `execution/s3-backend/R1_DISPOSITIONS.md`. Publication manifest: `execution/s3-backend/PUBLICATION_MANIFEST.md`; checksums `SHA256SUMS.txt`.

## Candidate identity

| Item | Value |
|---|---|
| Repo / worktree | growth-project-backend, `/home/user/workspace/worktrees/s3-backend`, branch `execute/20260920-s3-backend` |
| Base (main) | `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` |
| Preserved cumulative head (#525 incl. #524) | `925780e0a1906593e5383c618311b6b17364b8dc` — 22 commits over base (task brief said 21; count is 22, all preserved, none rebuilt) |
| **Current head (R1)** | `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06`, tree `83211d25d714e4c539cd3aa248a06ef0658fc8e7` = preserved head + 1 S3 commit |
| Identity | all 23 commits author AND committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`; no co-author trailers; `git var GIT_COMMITTER_IDENT` verified |
| Grade/model requested | T4 / Claude Fable 5 / High (actual reasoning setting not observable; not claimed) |
| Deployed baseline (parent, FLY_RUNTIME_METADATA.md) | image GH_SHA 5076a07a (ancestor of main). Neither main nor this candidate is assumed deployed. |

## S3 change on top of the preserved candidate (1 commit, 2 files)

`5c7b42b3` fix(health): bound the readiness probe below the platform check timeout
- `src/health/health.controller.ts` (+35/−7): `/readyz` races `SELECT 1` against `READINESS_TIMEOUT_MS = 3000` (< fly.toml check timeout 5s), clears the timer when the query settles first, logs a distinct structured `readiness_database_timeout` event (no driver text); rejection path, status (503) and client body (`database_unavailable`) unchanged.
- `test/health-readiness-bounded.spec.ts` (new, 3 tests): settles exactly at the bound with fake timers; no stranded timer on success; real HTTP `/readyz` returns 503 + `no-store` in ≥2.95s and <5s.
- Reproduced defect on preserved head 925780e0 before fixing: handler still pending after 6000 ms with a never-resolving query (`logs/03-readiness-red-on-925780e.log`). Rationale: platform probe timeout does not cancel the Prisma call, so each 15s probe against a hung DB left another pending request/pool slot and Fly saw a timeout, not an explicit 503.
- R75 banned-token gate (repo `scripts/check-r75.js --mode=range`) run over base..head: OK (`logs/04-check-r75.log`; first attempt caught two `as never` casts in the new test, removed before the commit was amended — this is the same commit, never pushed).

## Toolchain / install

Node v20.20.1, npm 10.8.2 (matches Dockerfile `node:20-slim` and CI `node-version: '20'`); 2 vCPU / 8 GB sandbox shared by 6 lanes. `npm ci --ignore-scripts --no-audit --no-fund` → exit 0, 1117 packages, 6 min, then explicit reviewed `npx prisma generate` → Prisma Client 6.19.3 (`logs/01-npm-ci.log`). Lifecycle scripts deliberately skipped: root `postinstall` (prisma generate — run explicitly instead), root `prepare` (lefthook install — git hooks therefore NOT installed in this worktree; the hook's check was run by hand, see R75 above), and package postinstalls of @prisma/client, @prisma/engines, @scarf/scarf, core-js, fsevents, lefthook, prisma, unrs-resolver. node_modules private to this worktree (no generated-client sharing). Lockfile: v3, 1150 entries, all registry.npmjs.org with integrity.

## Test selection and execution

Logs: `/home/user/workspace/execution/s3-backend/logs/`. Each log header records head, tree, node/npm, command, UTC time. Runs serialized through `execution/heavy-validation.lock` (install; `02` acquired before the scheduler split) and `execution/test-validation.lock` (later steps), holders appended to `*.lock.holders`.

| Log | Selection | Result |
|---|---|---|
| 03-readiness-red | ts-node probe of `/readyz` on 925780e0 with never-resolving query | RED reproduced (pending > 6000 ms) |
| (ad hoc, outside lock, nice 10) | `test/scout/scout-diagnostics.integrity.spec.ts`; `test/health-readiness-bounded.spec.ts`; `test/health-readiness-public.spec.ts` + `test/health.controller.spec.ts` on 5c7b42b3 | PASS 7/7; PASS 3/3; PASS 17/17 |
| 04-check-r75 | `node scripts/check-r75.js --mode=range --base=c23b9d9f --head=HEAD` | OK |
| 02-focused-a (head 5c7b42b3, 27/28 suites, 457/458 tests) | deps: `test/dependency-compatibility.spec.ts`, `test/ci/lockfile-relevance.spec.ts`, `test/ci/dependency-audit.spec.ts`; readiness/redaction: `test/ci/fly-readiness.spec.ts`, `test/health-readiness-public.spec.ts`, `test/health.controller.spec.ts`, `test/http-exception.filter.spec.ts`, `test/observability/**`, `test/scout/scout-diagnostics-{boundary,public-cause,public}.spec.ts`, `test/scout/scout-diagnostics.integrity.spec.ts`, `src/scout/scout.service.spec.ts`; consumers: `test/rate-limit.spec.ts`, `test/common/feature-flag-not-found*.spec.ts`, `test/diagnostic.controller.spec.ts` | 27 PASS; 1 FAIL `test/dependency-compatibility.spec.ts › loads an actual Prisma config through c12` (ETIMEDOUT, see F1). `test/rate-limit.spec.ts` PASS but took 606 s under contention. |
| 08-f1-diagnostic (test lock, load 5.2) | single re-execution of `test/dependency-compatibility.spec.ts` + standalone child probe | PASS 10/10 (probe test 3955 ms; standalone child 695 ms at load 2.9) — see F1 |
| 05-tsc | `npx tsc --noEmit -p tsconfig.json` with default heap | exit 134, V8 heap OOM at ~2 GB after 60 s |
| 09-tsc-ci-env | same, with the repo's documented CI env `NODE_OPTIONS=--max-old-space-size=4096` (ci.yml "Type-check" step, present on main) | **PASS** (exit 0, no diagnostics) |
| 06-lint | `npm run lint` (`eslint "src/**/*.ts"`, src only per package.json) | exit 0: 0 errors, 21 warnings (`no-unused-vars`, none in candidate-changed files; pre-existing) |
| 07-full-jest | full default suite, `--maxWorkers=1`, default heap | 40 suites PASS then exit 134 heap OOM at ~2 GB (ci.yml "Test" step documents exactly this and sets 4096) |
| 10-full-jest-sharded | full default suite, `NODE_OPTIONS=--max-old-space-size=4096`, `--maxWorkers=1`, 4 sequential `--shard=n/4` (same total selection; sharding only bounds per-process ts-jest memory) | **all 4 shards exit 0**: 545 suites PASS, 12 suite-level skipped (pre-existing DB-dependent e2e/live specs from June 2026, outside the diff: `test/community/**` ×10, `test/mwb-3-autosave.service.spec.ts`, `test/mwb-3-undo.spec.ts`), 8209 tests passed / 159 skipped / 5 todo / 0 failed; 17:12–17:22Z |
| 11-readiness-trio (test lock, NODE_OPTIONS stamped) | `test/health-readiness-bounded.spec.ts test/health-readiness-public.spec.ts test/health.controller.spec.ts` | PASS 3 suites / 20 tests |
| 12-control-source-lint | exact CI "Lint control sources" command, `--max-warnings 0`, 7 control files | exit 0 |
| 13-build | `npm run build` (nest build), CI heap | exit 0 |
| 14-c12-timing | identical c12 child probe ×3 (self-timed) + `test/dependency-compatibility.spec.ts` once, loadavg 1.67 | 474 / 549 / 456 ms; spec 10/10 PASS, c12 case 498 ms |
| 15-npm-audit | `npm audit --package-lock-only --include=prod --include=dev --include=optional --include=peer --audit-level=high` (registry read; no fix) | found 0 vulnerabilities, exit 0 |
| 16-readiness-red-baseline-925780e | detached checkout of pre-fix head `925780e0` (tree `911bea30…`), probe script + command printed verbatim | RED: "still pending after 6000ms"; same probe on `5c7b42b3`: `status 503`, settled |

Not run (needs Postgres, excluded by jest.config.js): `test/rls/**`, `test/rls-*.spec.ts`. Not run: Docker build, Fly deploy/checks, any production query. Not run: any workflow (`.github/workflows/*`), which are S2's domain.

## Findings

**F1 — CLOSED (root cause: host contention; see R1_DISPOSITIONS A-001/B-01 with the four-point load→latency series 0.5 s → 4 s → >20 s)** — original diagnostic text retained below.
**F1 (original) — EXPLAINED by one focused diagnostic (no timeout change, no retry loop): `dependency-compatibility.spec.ts › loads an actual Prisma config through c12 and the overridden merger` → `spawnSync /usr/local/bin/node ETIMEDOUT`.** The probe spawns a child node with a fixed `timeout: 20000` that loads a real `prisma.config.ts` through @prisma/config → c12/jiti (transpile + module graph read) with the deepmerge-ts override. At failure (`02`, 16:48Z): load average 10.9–13.2 on 2 vCPU, two other lanes' `npm ci` writing node_modules plus a `git reset --hard` and kernel flush threads; jest itself at ~9 % CPU (I/O-starved); the spec's other 9 probes finished normally and the suite total was 25.7 s, i.e. this child alone hit its 20 s bound. Diagnostic (`08`, 17:09Z, load 5.2, same head/tree/node/deps, single execution): same spec PASS 10/10 with this probe at 3955 ms; the identical child script standalone: 695 ms (require @prisma/config 463 ms, config load 227 ms). Conclusion: sandbox I/O/CPU starvation stretched a normally sub-second, ~4 s-under-jest child past a fixed 20 s bound; no dependency-graph or override defect is indicated. Residual: the 20 s child bound is environment-sensitive; left unchanged (CI runners are unloaded; changing it is not S3's call without a product reason). Not counted as a candidate defect; both runs are preserved verbatim in the logs.

**F5 — EXPLAINED (pre-existing, documented in the repo): default-heap `tsc --noEmit` and default-heap full jest OOM (exit 134).** `.github/workflows/ci.yml` on main already sets `NODE_OPTIONS=--max-old-space-size=4096` for both steps with the comment that they overrun Node's ~2 GB default heap. Re-run with exactly that documented env: tsc PASS; full suite running sharded (see table). Not a candidate regression; no source or config changed.

**F2 — FIXED (S3 commit 5c7b42b3): unbounded readiness probe** (see above).

**F3 — Ownership overlap (not edited by S3):** preserved candidate touches `fly.toml` (`[[http_service.checks]]` GET /readyz grace 30s / interval 15s / timeout 5s), `.github/workflows/{ci,danger,dependency-audit,r100-quality-gate}.yml`, `.github/r75-policy.json`, `scripts/check-r75.js`, `lefthook.yml`. Parent acknowledged; S2 composes these with its own controls. F2's 3s bound assumes the 5s check timeout survives that composition.

**F4 — Recorded, not changed (judged non-material on this head):**
- `HttpExceptionFilter`: an `HttpException` at 4xx whose cause chain contains an ORM error is rendered as `{statusCode: 4xx, message: 'Internal server error', error: 'Internal Server Error'}` — status/text incoherent. No production code path passes an ORM `cause` into an HttpException today (`rg "{ cause" src` outside filters/observability: none), and the candidate's tests pin the leak-safe behaviour, so left as is.
- `safeDiagnostic` walks `.cause` but not `AggregateError.errors`; no current producer.
- Client envelope `path` still echoes raw `request.url` (query string included); tests assert this as the deliberate mobile-client contract. Logs/Sentry use the route template or `[unmatched]`.
- `uncaughtException` handler reports and does not exit — pre-existing on main, unchanged.
- `prisma.service.ts` startup connect failure logs only a static event (no error code); reduces diagnosability but is the intended credential-safe posture.
- `@types/node 26.0.0` on a Node 20 runtime — pre-existing (`^26` on main), types can describe APIs absent at runtime; tsc result pending.

## Recovery

- S3 incremental bundle (needs only public base `c23b9d9f`): `execution/s3-backend/s3-backend-5c7b42b3.bundle` (`main..execute/20260920-s3-backend`, 104 KB, `git bundle verify` OK). Parent checkpoint bundle `s3-r1-candidate.bundle` (64 MB, full history) is a duplicate and need not be published.
- Frozen audit copy: `worktrees/audit-s3-r1` (read-only for S3).

## Smallest next action

Auditors A and B re-read `R1_DISPOSITIONS.md` and logs 10–16 against the unchanged head `5c7b42b3` / tree `83211d25` and issue final attestations. If either converts a nonmaterial item to material, S3 applies the agreed smallest fix as a new G05 commit and reports the new head/tree immediately. Parent publishes per `PUBLICATION_MANIFEST.md`.
