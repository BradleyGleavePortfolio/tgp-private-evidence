# Independent Audit A — S3 T4 round 1 (growth-project-backend)

Status: **NOT CLEARED — source review complete, execution evidence incomplete.** No material source defect identified in the cumulative diff; clearance is blocked by the evidence gaps listed in §5 (S3-A-001 … S3-A-005). This is a finding-level report, not a verdict manufactured to fit a schedule.

Report written: 2026-09-20 ~17:14Z. Any builder log arriving after that time is not reflected here.

## 0. Auditor identity and tooling (honest statement)

- Role: independent auditor A. I did not implement any part of the candidate. I did not read `execution/audits/s3-r1/b/REPORT.md` nor coordinate with auditor B.
- Requested model: "Claude Fable 5 High". The actual model/effort setting is **not exposed** to me; I cannot confirm or deny which setting was in force. Treat model identity as unverified.
- No skills loaded, no subagents, no network access used, no installs, no edits to any candidate file, no commits, no settings/deploy/customer-record access. All checks were read-only (`git`, `rg`, `sed`, `cat`, `ls`) against the pinned worktree and the builder's log directory.

## 1. Exact candidate under audit

| Item | Value |
|---|---|
| Repo | BradleyGleavePortfolio/growth-project-backend |
| Pinned read-only worktree | `/home/user/workspace/worktrees/audit-s3-r1` (no `node_modules`, clean `git status`) |
| Base | `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` (verified `git merge-base --is-ancestor base HEAD`) |
| Head | `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06` |
| Tree | `83211d25d714e4c539cd3aa248a06ef0658fc8e7` |
| Range | 23 commits (`git rev-list --count c23b9d9f..HEAD` = 23), 47 files, +5385 / −712 |
| Identity | All 23 commits author **and** committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`; no Co-authored-by / Signed-off-by / "generated" trailers (independently re-verified) |
| Builder worktree (mutable, with `node_modules`) | `/home/user/workspace/worktrees/s3-backend` at the same head/tree (every builder log header stamps `head=5c7b42b3… tree=83211d25…`) |
| Builder logs read | `/home/user/workspace/execution/s3-backend/logs/01…09-*.log`, `run-*.sh`, `f1-diagnostic.sh`; lock holder files `execution/heavy-validation.lock.holders`, `execution/test-validation.lock.holders` |

Changed-file inventory (from `git diff --name-status c23b9d9f..HEAD`): 47 files — governance/CI (`.github/r75-policy.json` A, `ci.yml` M, `danger.yml` M, `dependency-audit.yml` A, `r100-quality-gate.yml` M, `eslint.config.js` M, `lefthook.yml` M, `scripts/check-r75.js` A), hosting (`fly.toml` M), dependencies (`package.json`, `package-lock.json` M, `docs/dependencies/2026-09-op81-dependency-repair.md` A), source (`src/common/cache-control.interceptor.ts`, `src/filters/http-exception.filter.ts`, `src/filters/throttler-exception.filter.ts`, `src/health/health.controller.ts`, `src/main.ts`, `src/observability/{README.md,logging.interceptor.ts,sentry-config.ts}` M, `src/observability/{orm-diagnostics.ts,process-errors.ts}` A, `src/prisma.service.ts` M, `src/scout/scout.service.ts` M), tests (22 spec/fixture/harness files A or M).

## 2. Scope and what I actually did

Cumulative review of the whole `c23b9d9f..5c7b42b3` diff (not just the final readiness fix), against `repos/context/AGENT_RULES.md` (G01–G22) and the op81 continuation plan sections "Open work to preserve", "Audit and repair #524", "three-slice rolling queue".

Read in full or in relevant part: every `src/` change; `package.json` and the `package-lock.json` deltas (overrides, resolved versions, integrity fields); every new/modified spec; the R75 checker and policy; all workflow diffs; `fly.toml`; the dependency-repair doc; every builder log and lock timeline. Cross-lane items (S2 delivery enforcement/workflow/fly composition, S1 DB authz/recovery, S5 G2 proof) are recorded as prerequisites in §7, not rebuilt.

Small read-only checks performed (all in the pinned worktree unless stated):
- `git rev-parse HEAD HEAD^{tree}`, `git merge-base --is-ancestor`, `git rev-list --count`, `git log --format='%an <%ae>|%cn <%ce>'`, `git diff --name-status`.
- `rg` for `{ cause` on HttpException construction in `src/` (none found → S3-A-010 is latent).
- `rg` for `.skip(|.only(|.todo(|xit(|xdescribe` across changed test files (none).
- `rg` confirming `/readyz` is throttler-whitelisted (`src/throttler/user-throttler.guard.ts:8`), excluded from the `/api` prefix (`src/main.ts:150`), dunning-lockout-exempt, and in `NO_STORE_PREFIXES`.
- `rg` confirming `npm run lint` covers only `"src/**/*.ts"` (package.json:10) while CI's new "Lint control sources" step lints seven control files with `--max-warnings 0`.
- Lockfile: v3, 1150 entries, all `registry.npmjs.org`, all `integrity` present, none sha1; root deps/devDeps match the manifest; forced resolutions present (deepmerge-ts 8.0.0, multer 2.3.0, qs 6.16.0, diff 9.0.0, js-yaml 4.3.2 root + 3.15.2 nested under `@istanbuljs/load-nyc-config`, minimatch 3.1.5/5.1.9/9.0.9/10.2.5/10.2.6, danger 13.0.8, express 5.2.1, ws 8.21.0). Lock root lacks an `overrides` key in both base and head (consistent; `npm ci` exit 0 in `01-npm-ci.log`).

## 3. Execution evidence state (as of ~17:12Z)

All at head `5c7b42b3`, tree `83211d25`, Node v20.20.1 / npm 10.8.2, in the builder worktree, on a 2 vCPU / 8 GB shared sandbox.

| Log | Command | Result | Notes |
|---|---|---|---|
| 01-npm-ci | `npm ci --no-audit …` | exit 0 | No `npm audit` result exists (see S3-A-004). |
| 02-focused-a | `npx jest --ci --maxWorkers=1 <28 suites>` (heavy lock, 16:45:34–16:59:08Z, 811.8 s) | **exit 1**: 27 suites pass, 1 fail; 457/458 tests | Failure: `test/dependency-compatibility.spec.ts › loads an actual Prisma config through c12 and the overridden merger` — `spawnSync /usr/local/bin/node ETIMEDOUT` (probe `timeout: 20000`). `test/rate-limit.spec.ts` took 606.8 s, `src/scout/scout.service.spec.ts` 98 s. Concurrent activity per holder files: S6 `npm ci` 16:39:29–16:48:26Z, S6 stage-A 16:51:36–17:00:55Z, S1 replay until 16:59:00Z. |
| 03-readiness-red-on-925780e | bounded readiness spec on pre-fix head | red ("still pending after 6000ms") | Shows the new test discriminates the pre-fix behaviour. **Not** evidence at head. |
| 04-check-r75 | `node scripts/check-r75.js --mode=range --base=c23b9d9f --head=5c7b42b3` | OK (`as any +2 −2 net 0`) | Intermediate head `4b6385af` had failed (`as never` +2); fixed by switching the test to `partial as Response`. |
| 05-tsc | `npx tsc --noEmit -p tsconfig.json` | **exit 134 — V8 heap OOM (~2 GB)** | Run **without** CI's `NODE_OPTIONS=--max-old-space-size=4096` (`ci.yml` lines 56–59 document that tsc needs >2 GB heap). Methodology gap, not a candidate regression. |
| 06-lint | `npm run lint --silent` | exit 0, 0 errors, 21 warnings | All 21 warnings are in files **outside** the candidate diff (verified by set intersection = ∅). Covers `src/**` only. |
| 07-full-jest | `npx jest --ci --maxWorkers=1 --silent` | **exit 134 — V8 heap OOM after 40 PASS, 0 FAIL, ~210 s** | Same missing `NODE_OPTIONS` (`ci.yml` lines 64–70 document the OOM and the 4 GB fix). In-band single worker also accumulates heap across suites. |
| 08-f1-diagnostic (2nd attempt, 17:09:26Z) | standalone probe + `npx jest --ci --maxWorkers=1 test/dependency-compatibility.spec.ts` | Standalone timing **not captured** (`/usr/bin/time` absent → line 26 failed; the self-timing `node /tmp/f1-probe.js` never ran). Single spec: **PASS**, 10/10; the c12 case took **3955 ms**; load before 5.22, after 5.24. | First attempt (17:02Z) exit 127 (`timeout` binary missing in that invocation). |
| 09-tsc-ci-env | `npx tsc --noEmit -p tsconfig.json` (labelled CI env) | **exit 0** (17:10:31Z start; completed before 17:13Z) | Closes the tsc part of S3-A-003 **with one caveat**: the log header records only the command, not `NODE_OPTIONS`; the 4 GB heap is inferred from the label and the fact that the identical command OOM'd at 17:01Z. Ask the builder to stamp `NODE_OPTIONS` in step headers. |
| run-full-sharded.sh (queued) | `NODE_OPTIONS=--max-old-space-size=4096 npx jest --ci --maxWorkers=1 --silent --shard=N/4` × 4 | not yet run at report time | Reasonable design (bounded per-process heap). Its log, when it exists, is the evidence for §5 item 5. |

Suites in the diff with **zero** execution evidence at head: `test/health-readiness-bounded.spec.ts` (the final fix commit's own proof), `test/ci/r75-gate.spec.ts`, `test/ci/r75-boundaries.spec.ts`, `test/ci/r75-wiring.spec.ts`, `test/ci/r75-enforcement.spec.ts`. Also unevidenced: the full suite, CI's "Lint control sources" step, `npm run build`, `npm audit`. `tsc` is now evidenced (09, exit 0) subject to the env-stamping caveat above.

## 4. Findings — material (block clearance)

All five are **evidence gaps**, not established source defects. They are material because the brief states a finished source review without sufficient execution evidence is not clearance.

### S3-A-001 — `dependency-compatibility.spec.ts` c12 case: one ETIMEDOUT and one PASS at the identical tree; deciding variable not identified
- Evidence: `02-focused-a.log` fail (`spawnSync … ETIMEDOUT`, i.e. child exceeded the hard-coded 20 000 ms bound at `test/dependency-compatibility.spec.ts:40`) vs `08-f1-diagnostic.log` pass (3955 ms) — same head/tree/Node, same host, ~25 minutes apart, both under load ≈ 5–7 on 2 vCPU.
- Consequence: the suite is demonstrably nondeterministic on this host; the margin between typical cost (≈4 s here) and the bound (20 s) is unknown on CI runners. Root cause is **not established**. Load/contention is a hypothesis with circumstantial support (the failing run shared the box with S6 `npm ci`/stage-A and S1 replay; `rate-limit.spec.ts` alone took 606.8 s). I do not assert it is flaky, pre-existing, environmental, or a product defect.
- Diagnostics gap in the test itself: `expect(result.error).toBeUndefined()` fires first, so on timeout the child's partial `stderr` is never printed; the probe also inherits `process.env` (including any `NODE_OPTIONS`).
- Smallest correct remediation (only once cause is measured): (a) capture the standalone probe timing the builder attempted (the script's own `console.error` ms markers suffice — run `node /tmp/f1-probe.js` directly, not via `/usr/bin/time`); (b) collapse the four assertions into one `expect({ error: result.error?.code, signal, status, stderr, stdout }).toEqual({...})` so a future timeout prints child output; (c) set the bound from measurement (e.g. ≥5× the observed p99 on a quiet host) rather than a bare constant, or make it env-overridable for constrained hosts. Do **not** simply raise the timeout without (a).

### S3-A-002 — Final fix commit's own test never executed at head
- `test/health-readiness-bounded.spec.ts` (added in `5c7b42b3` together with the `Promise.race` bound) was excluded from the 02 focused list and both full runs OOM'd before reaching it. The only run of this file is the red run on pre-fix head `925780e0`.
- Consequence: the claim "readiness settles ≤3000 ms with 503 `database_unavailable` and clears its timer" is unproven at head. Source reading supports it (see §6) but reading is not execution. The third case (`elapsed < 5000` over real HTTP with real timers) is load-sensitive and should be run under quiet load.

### S3-A-003 — Full Jest and R75 gate suites unevidenced; first builder runs omitted CI's documented heap setting (tsc since re-run and green)
- `05-tsc.log` and `07-full-jest.log` both died with V8 OOM at the ~2 GB default heap. `ci.yml` (unchanged lines 56–70) documents that both steps need `NODE_OPTIONS=--max-old-space-size=4096`. Not a candidate regression. `09-tsc-ci-env.log` subsequently passed (exit 0) — accepted as type-check evidence at head, with the caveat that the log does not record the env actually used. Full-suite evidence remains open (sharded run queued, not yet executed).
- `test/ci/r75-{gate,boundaries,wiring,enforcement}.spec.ts` spawn the real `scripts/check-r75.js` (verified) and are the only executable proof that the new R75 gate behaves as the workflow and lefthook expect. Never run at head.
- Also `npm run build` (CI "Build" step) unevidenced.

### S3-A-004 — `npm audit` gate state unknown; new workflow would fail CI on any high/critical anywhere in the graph
- `dependency-audit.yml` (new) runs `npm audit --package-lock-only --include=prod --include=dev --include=optional --include=peer --audit-level=high` on Node 20.20.1. No audit has been run against the real lockfile (`01-npm-ci.log` used `--no-audit`; `test/ci/dependency-audit.spec.ts` uses a fake `npm`). `npm ci` printed deprecation notices (`inflight@1.0.6`, `glob@7.2.3`, `glob@10.5.0`, `jpeg-exif@1.1.4`) — deprecation ≠ advisory, but the graph has not been checked.
- Consequence: the first PR touching this branch may fail a new required check for reasons unrelated to the PR. Whether the check is *required* is S2's branch-protection lane (prerequisite, §7). Running the audit needs registry network access → parent decision.

### S3-A-005 — CI "Lint control sources" step (`--max-warnings 0`) not executed locally
- `npm run lint` covers only `src/**/*.ts`. The new CI step lints `scripts/check-r75.js`, the four `test/ci/r75-*.spec.ts`, `test/ci/r100-pathspec.spec.ts`, `test/ci/dependency-audit.spec.ts` with warnings-as-failures. `eslint.config.js` un-ignores `scripts/check-r75.js` (`'!scripts/check-r75.js'`) so it *will* be linted. No log shows this command at head.
- Consequence: a single unused import in any of those seven files fails CI. Cheap to close.

## 5. Requested executions (through parent; builder worktree `/home/user/workspace/worktrees/s3-backend`; serialize under the existing lock; capture `head`/`tree`/`node -v`/`/proc/loadavg` before and after each)

Why current evidence is inadequate: the five suites/steps above have no run at head; the two runs that exist for `dependency-compatibility` disagree; both broad runs OOM'd for a documented, avoidable reason.

1. Readiness fix proof (closes S3-A-002):
   `npx jest --ci --maxWorkers=1 test/health-readiness-bounded.spec.ts test/health-readiness-public.spec.ts test/health.controller.spec.ts`
2. R75 gate proof (closes part of S3-A-003):
   `npx jest --ci --maxWorkers=1 test/ci/r75-gate.spec.ts test/ci/r75-boundaries.spec.ts test/ci/r75-wiring.spec.ts test/ci/r75-enforcement.spec.ts test/ci/r100-pathspec.spec.ts`
3. Type-check with CI env — **satisfied by `09-tsc-ci-env.log` (exit 0)** provided the builder confirms `NODE_OPTIONS=--max-old-space-size=4096` was exported for that step (future step headers should print `NODE_OPTIONS`). No re-run needed if confirmed.
4. Build: `NODE_OPTIONS=--max-old-space-size=4096 npm run build`
5. Full suite with CI env (closes S3-A-003). On this 8 GB box prefer bounded workers to avoid another OOM:
   `NODE_OPTIONS=--max-old-space-size=4096 npx jest --ci --maxWorkers=2 --workerIdleMemoryLimit=1500MB --silent`
   (If it must be `--maxWorkers=1`, keep the 4 GB heap; report exit code and the `Tests:` summary line.)
6. Control-source lint (closes S3-A-005), exactly as CI:
   `npx --no-install eslint --max-warnings 0 scripts/check-r75.js test/ci/r75-gate.spec.ts test/ci/r75-boundaries.spec.ts test/ci/r75-wiring.spec.ts test/ci/r75-enforcement.spec.ts test/ci/r100-pathspec.spec.ts test/ci/dependency-audit.spec.ts`
7. c12 probe timing (informs S3-A-001; no code change first): with the machine otherwise quiet, run the builder's probe file directly three times and record its self-reported ms lines:
   `for i in 1 2 3; do cat /proc/loadavg; node /tmp/f1-probe.js; done`
   then `npx jest --ci --maxWorkers=1 test/dependency-compatibility.spec.ts` once more. Report all timings; I will then classify S3-A-001 (bound too tight vs host contention vs something else) rather than guess.
8. Registry read (parent decision — network): `npm audit --package-lock-only --include=prod --include=dev --include=optional --include=peer --audit-level=high` (closes S3-A-004).

## 6. Findings — nonmaterial (notes; none blocks clearance on its own)

### S3-A-010 — 4xx `HttpException` with an ORM cause returns a 4xx status with an "Internal server error" body and drops `code`
- `src/filters/http-exception.filter.ts`: when `ormBoundary` is true the client body is replaced by the generic 500 text while the original status (404/409/422/…) is kept and any machine-readable `code` is removed. The scout D1/D2 specs deliberately assert this (`expectSanitizedEnvelope` only requires a non-empty message). Result is a self-contradictory envelope (e.g. `409 Conflict` + `"Internal server error"`).
- Latent today: `rg` finds no `HttpException` constructed with `{ cause` anywhere in `src/`. The leak protection itself is correct and preferable to leaking ORM text.
- Smallest correct remediation: when `ormBoundary && status < 500`, emit the status's canonical phrase (e.g. from `HttpStatus`) as both `message` and `error` instead of the 500 text; keep dropping `code`. Update the D1/D2 vectors to assert the phrase.

### S3-A-011 — Readiness bound leaves the Prisma query pending (acknowledged)
- `Promise.race` cannot cancel `$queryRaw`; one stranded promise per probe interval while the DB hangs, bounded by Prisma connect/pool timeouts. Late rejection is swallowed by `Promise.race` (no `unhandledRejection`), so no crash path and no double-log. Acceptable; documented in the code comment. No change requested.

### S3-A-012 — Non-ORM Sentry allowlist drops `contexts.trace`, `sdk`, `transaction`, `extra.responseStatus`
- `sentry-config.ts` `beforeSend` now allowlists a fixed key set for every event. Loses trace correlation and the status extra the filter still sets. Documented trade-off in `src/observability/README.md`. Optional improvement: retain `contexts.trace` and `sdk` (neither carries request data).

### S3-A-013 — `stripSensitiveHeaders` is dead in the production path
- Still exported from `sentry-config.ts` and tested (`test/observability/sentry-config.spec.ts` ~line 76) but no longer called by `beforeSend`. Hygiene only; remove or mark as retained-for-callers.

### S3-A-014 — `danger` 12.3.4 → 13.0.8 major bump only partially exercised
- `test/dependency-compatibility.spec.ts` covers `localGetFileAtSHA`; `dangerfile.js` also uses `danger.git`/`danger.github` APIs that run only in CI on a PR. Not evidenced end-to-end here; cross-lane with S2's workflow enforcement.

### S3-A-015 — R75 policy is read from the candidate head (`head:.github/r75-policy.json`)
- `scripts/check-r75.js` loads its policy from the commit being judged, so a PR can relax its own gate (G01/G07 governance). Pre-existing pattern for this repo's gates; the checker does detect index drift and fails non-PR events as NON-CERTIFYING. S2 lane — recorded as prerequisite, not rebuilt.

### S3-A-016 — Diagnostic path is now the route template or `[unmatched]`
- `logging.interceptor.ts` / `throttler-exception.filter.ts` no longer log the raw URL; the metric label `path` becomes low-cardinality (an improvement over unbounded URL labels). Trade-off: which raw paths 404 is no longer visible in logs (request_id retained). `[unmatched]` appears in `test/rate-limit.spec.ts` because those tests feed route-less mock requests; in real Nest/Express the guard runs inside the matched route handler, so `request.route.path` is populated. Note only.

### S3-A-017 — `fly.toml` readiness check semantics unverified in hosting
- New `[[http_service.checks]]` (GET `/readyz`, grace 30 s, interval 15 s, timeout 5 s, `X-Forwarded-Proto: https`). Whether a failing check withdraws traffic vs restarts the machine, and interplay with `auto_stop_machines = 'suspend'`, are hosting behaviours not provable from source; `test/ci/fly-readiness.spec.ts` is a literal-line config contract only. S2 lane prerequisite.

## 7. Cross-lane prerequisites (recorded, not rebuilt)

- **S2** — branch protection/required checks for `dependency-audit.yml`, the rewritten `r100-quality-gate.yml` R75 job, and `ci.yml` "Lint control sources"; Fly deployment behaviour for the new check (S3-A-017); danger 13 end-to-end (S3-A-014); candidate-controlled R75 policy (S3-A-015).
- **S1** — none of this diff touches DB authz/recovery; `PrismaService` startup log change only alters log shape.
- **S5** — G2 proof lane unaffected; this report supplies no G2 evidence.

## 8. What I verified as sound (source-level, subject to §5 execution)

- Readiness: `READINESS_TIMEOUT_MS = 3000 < 5000` (Fly timeout); timer cleared in `finally`; 503 body fixed to `{ ok:false, db:'down', error:'database_unavailable', timestamp }` with no driver text; distinct `readiness_database_timeout` / `readiness_database_unavailable` structured events; `Cache-Control: no-store` via decorator **and** interceptor prefix; `/readyz` excluded from `/api` prefix, throttler and dunning lockout.
- ORM diagnostics: `safeDiagnostic` walks (cyclic-safe) cause chains and replaces Prisma*/DatabaseRequestError with a code-only `DatabaseRequestError`; used before logger and Sentry sinks in the filter, process reporters (`unhandledRejection`/`uncaughtException` in `main.ts`) and `PrismaService` startup. `beforeSend` detects ORM events via `hint.originalException` or serialized exception type and reduces them to `message`/`exception`/`tags.request_id`.
- Tests select the real code: `orm-composed-http.spec.ts` boots a real Nest app with the real Sentry SDK on a local transport; `sentry-incoming-request.spec.ts` runs the fixture in a separate process with default integrations; `dependency-audit.spec.ts` executes the real workflow shell body with a fake `npm`; R75 specs spawn the real checker; `health-readiness-public.spec.ts` covers string/object/null/undefined/throwing-`toString` rejections over real HTTP. No `.skip/.only/.todo` in changed tests.
- Dependencies: exact pins throughout; nested overrides scoped to the intended consumers (`@prisma/config@6.19.3→deepmerge-ts 8.0.0` is devOptional via `prisma` only; `@nestjs/platform-express@11.1.26→multer 2.3.0`; `@nestjs/swagger@11.4.4→js-yaml 4.3.2`); global `minimatch` override removed and nested versions restored; lockfile integrity complete; doc matches manifest and states honestly that tests were not executed in that commit.
- Customer-facing copy: scout push notifications now say "Import transfer staged / needs attention" with "Migration is not verified" — aligns with the plan's settlement-truth requirement; spec updated to exact strings.
- R75: cumulative range check passes at head (`04-check-r75.log`); interim violation was corrected without weakening policy.
- Lint: 0 errors; all 21 warnings pre-existing and outside the diff.

## 9. Verdict and current limitations

**Verdict: NOT CLEARED (evidence incomplete).**
- No material source defect found in the cumulative `c23b9d9f..5c7b42b3` diff.
- Clearance is blocked until §5 items 1–6 exit 0 at head/tree `5c7b42b3` / `83211d25`, item 7 lets S3-A-001 be classified on evidence, and the parent decides on item 8.
- Item 3 is already green (tsc exit 0 at head). If §5 items 1, 2, 4, 5, 6 pass and item 7 shows the c12 probe comfortably inside 20 s on a quiet host, my recommendation would be CLEAR with nonmaterial notes S3-A-010…017 carried as follow-ups. If item 7 shows the probe routinely near or above the bound, S3-A-001 becomes a material test-robustness defect requiring the remediation in §4 before clearance.

Limitations: I could not execute anything (no `node_modules` in the pinned worktree, no install permitted, no network). Hosting behaviour, branch protection and CI runner performance are outside what source review can establish. The sharded full-suite run (`run-full-sharded.sh`) had not started when this report was written; its result must be read before any clearance decision.
