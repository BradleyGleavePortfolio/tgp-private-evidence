# S3 independent audit B — round 1 (T4, backend reliability/dependency candidate)

Status: **NOT CLEARED — material evidence gaps open; no material product defect proven.** This is a source-review-complete, execution-evidence-incomplete report. It is not a verdict manufactured from source existence.

## Identity, independence, inputs

- Auditor: B. Read-only. Did not implement, did not read auditor A's report, did not coordinate verdicts, made no edits/installs/commits/pushes/network writes, accessed no customer records or live systems.
- Tool identity (honest): Claude (Anthropic) running as a Perplexity Computer subagent. The brief requested "Claude Fable 5, High". The runtime does not expose the concrete model version or reasoning setting to me; I cannot independently confirm either. Record the dispatch's requested setting separately; do not treat this report as proof of a specific runtime identifier.
- Repository: `BradleyGleavePortfolio/growth-project-backend`
- Read-only snapshot: `/home/user/workspace/worktrees/audit-s3-r1`
- Base: `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`
- Head: `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06` (verified `git rev-parse HEAD`)
- Tree: `83211d25d714e4c539cd3aa248a06ef0658fc8e7` (verified `git rev-parse HEAD^{tree}`)
- Range: 23 commits, base is an ancestor of head; `git diff --stat`: 47 files, +5385/−712.
- G05 identity: all 23 commits author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`; no co-author/AI trailers found in commit bodies. (Not a signature claim.)
- Rules read: `repos/context/AGENT_RULES.md` G01–G22. Plan sections read: "Verified starting point", "Audit and repair #524", "Immediate three-slice rolling queue".
- Builder evidence read: `execution/s3-backend/REPORT.md` (milestone, not audit) and `execution/s3-backend/logs/01–10` as of 2026‑09‑20 17:08 UTC.

## Scope reviewed (cumulative base..head, not only the last commit)

Read in full: `src/health/health.controller.ts`, `src/main.ts`, `src/prisma.service.ts`, `src/common/cache-control.interceptor.ts`, `src/filters/http-exception.filter.ts`, `src/filters/throttler-exception.filter.ts`, `src/observability/{orm-diagnostics,process-errors,sentry-config,logging.interceptor}.ts`, `src/observability/README.md`, `src/scout/scout.service.ts` (+spec), `package.json`, `docs/dependencies/2026-09-op81-dependency-repair.md`, `fly.toml`, `eslint.config.js`, `lefthook.yml`, `.github/workflows/{ci,danger,dependency-audit,r100-quality-gate}.yml`, `.github/r75-policy.json`, `scripts/check-r75.js`, `test/dependency-compatibility.spec.ts`, `test/health-readiness-bounded.spec.ts`, `test/health-readiness-public.spec.ts`, `test/health.controller.spec.ts` diff, `test/ci/fly-readiness.spec.ts`, `test/ci/dependency-audit.spec.ts` (structure), `test/observability/orm-composed-http.spec.ts`, `test/observability/sentry-incoming-request.spec.ts` + fixture, `test/observability/sentry-config.spec.ts` diff, `test/scout/diagnostics-public-harness.ts`, `test/scout/scout-diagnostics.integrity.spec.ts`, `test/scout/scout-diagnostics-public-cause.spec.ts` (framing), `test/ci/r75-wiring.spec.ts` (harness portion). Skimmed: `test/ci/r75-*.spec.ts` headers, `jest.config.js`, `tsconfig*.json`, `Dockerfile`, `scripts/release.sh`, `src/instrument.ts`.

Independent read-only checks performed:
1. Lockfile graph diff base→head (Python over both `package-lock.json`): 85 changed entries (20 added, 21 removed); production-runtime version moves: `multer` 2.1.1→2.3.0, `body-parser` 2.2.2→2.3.0, `type-is` 2.0.1→2.1.0, `qs` 6.15.2→6.16.0, `js-yaml` 4.2.0→4.3.2, `ws` 8.20.1→8.21.0, `undici` 7.26.0→7.29.1; dev-only majors: `danger` 12.3.4→13.0.8 with the `@octokit/*` majors, `ini` 1.3.8→5.0.0, `deepmerge-ts` 7.1.5→8.0.0 (consumed only by `@prisma/config`, consumed only by `prisma`), `supports-hyperlinks`, `http-proxy-agent`.
2. Consumer mapping of every override/floor from the lockfile: `@prisma/config` ← `prisma` only; `deepmerge-ts` ← `@prisma/config` (declares 7.1.5, resolved 8.0.0); `multer` ← `@nestjs/platform-express` (declares 2.1.1, resolved 2.3.0); `qs` consumers all `^6.x`; `js-yaml` 4.3.2 root + `@nestjs/swagger` (declares 4.1.1), 3.15.2 under `@istanbuljs/load-nyc-config`; `minimatch` 3.1.5/5.1.9/9.0.9/10.2.5/10.2.6 — consistent with the docs note.
3. Grep for `HttpException(..., { cause })` producers in `src` (non-spec): none exist today.
4. Grep for remaining raw-URL diagnostics: `src/billing/subscription.guard.ts:246` still falls back to `req.url` (pre-existing, outside diff, guard runs post-routing).
5. Inspected artifacts left by the failed probe in the builder's worktree/tmp (read-only): `/tmp/prisma-dependency-dPi6cO/prisma.config.ts` retained (16:47Z); `worktrees/s3-backend/node_modules/.cache/jiti/` exists (created 16:28Z by `prisma generate`) and is empty.

## Findings

Classification: **M** = material (blocks clearance until closed), **N** = nonmaterial (fix when cheap; does not block), **EG** = evidence gap (not a defect; blocks clearance until evidence exists), **X** = cross-lane prerequisite (recorded, not adjudicated here).

### S3-B-01 (M / EG) — The one test that proves the cross-major `deepmerge-ts@8` force under its real consumer failed (`spawnSync … ETIMEDOUT`); root cause not established

- Evidence: `logs/02-focused-a.log` bound to head `5c7b42b3…`/tree `83211d25…`, Node 20.20.1, npm 10.8.2: `FAIL test/dependency-compatibility.spec.ts` → `loads an actual Prisma config through c12 and the overridden merger`, `Received: [Error: spawnSync /usr/local/bin/node ETIMEDOUT]` at `test/dependency-compatibility.spec.ts:40` (probe `timeout: 20000`). 457/458 tests in the focused set passed.
- Why it matters (consequence): `@prisma/config` is the only consumer of `deepmerge-ts`, and it hands `deepmerge` to `c12` as the config `merger` (`node_modules/@prisma/config/dist/index.js` ~L893–916). That is exactly the seam the 7.x→8.x force can break. The `prisma` CLI is in the production image (`Dockerfile`: `npm ci` with dev deps, `npx prisma generate`) and on the release path (`scripts/release.sh` → `prisma migrate deploy`). The other deepmerge probes (CJS/ESM) exercise `deepmerge-ts` directly, not through `@prisma/config → c12`. So this single test carries the #524 compatibility claim for the riskiest override, and it has no green result on this head.
- What is known: `prisma generate` exited 0 on this graph (`01-npm-ci.log`), which shows the CLI loads with `deepmerge-ts@8` present, but it did not exercise `loadConfigFromFile` with a TypeScript config (repo has no `prisma.config.ts`). The probe was killed externally at 20 s: the `finally` cleanup did not run (retained fixture dir observed), and jiti's fs cache stayed empty, so the child had not completed transpiling the fixture when killed. The machine was heavily contended at the time: S6 `npm ci` held the heavy lock 16:39–16:48Z overlapping the 16:47Z failure; `test/rate-limit.spec.ts` took 606 s and `scout.service.spec.ts` 98 s in the same run; 15‑min load average ≈ 8.5 on 2 vCPU. Contention is the leading hypothesis; it is **not** established, and a genuine hang in `c12`/`jiti`/`deepmerge-ts@8` composition has not been excluded.
- Do not classify as flaky/pre-existing: the test is new in this range; there is no baseline. G08 applies.
- Requested execution (via parent; builder's `08-f1-diagnostic.log` attempted this but failed on a missing `timeout` binary in PATH — exit 127; rerun needed):
  1. With no other heavy-lock holder and load average < 2: `cd worktrees/s3-backend && /usr/bin/time -v node /tmp/f1-probe.js` (builder's `f1-diagnostic.sh` probe body is acceptable) — record `require(@prisma/config) ms`, `loadConfigFromFile ms`, `total ms`, peak RSS. Acceptance: exits 0 with `dependency-probe-ok`, total well under 20 s on an idle machine.
  2. Then `npx jest --ci --maxWorkers=1 test/dependency-compatibility.spec.ts` on head `5c7b42b3…` with the same isolation, logged with head/tree/node/npm header. Acceptance: 10/10 pass.
  3. If (1) exceeds ~5 s idle or hangs, treat as a candidate defect in the override composition (re-key or drop `deepmerge-ts` force and re-evaluate the advisory), not a test tweak.
- Smallest correct remediation if root cause is load: none to product; see S3-B-05 for the test-design bound.

### S3-B-02 (M / EG) — No execution evidence on this head for the only behavioural change in the final commit (`test/health-readiness-bounded.spec.ts`)

- Evidence: the focused command in `02-focused-a.log` does not list `test/health-readiness-bounded.spec.ts`; `07-full-jest.log` aborted with heap OOM (exit 134) before completion; `10-full-jest-sharded.log` was empty at 17:08Z. The only readiness artifact is `03-readiness-red-on-925780e.log`, a one-line note (`still pending after 6000ms`) with no command, file, or test output — insufficient provenance for a red baseline (G09).
- Source review of the fix itself (`src/health/health.controller.ts`): `Promise.race` against a 3000 ms timer (`READINESS_TIMEOUT_MS < 5 s` fly `timeout`), timer cleared in `finally`, private `ReadinessTimeout` marker distinguishes timeout from rejection, static log events, static client error `database_unavailable`, `@Header('Cache-Control','no-store')`. Because `Promise.race` subscribes to both promises, a later rejection of the stranded `$queryRaw` cannot surface as an `unhandledRejection`. The test file selects the real controller with a `PrismaService` double, asserts settle at exactly the bound with fake timers, timer-count zero on the fast path, and a real HTTP 503 with `no-store` in 3–5 s. Selection and assertions are appropriate. I found no defect; I have no run.
- Requested execution: `npx jest --ci --maxWorkers=1 test/health-readiness-bounded.spec.ts test/health-readiness-public.spec.ts test/health.controller.spec.ts` on head with header line. Also request the red proof be reproduced attributably: same bounded spec run against `925780e0` (expected to fail the first and third cases) with the command and output captured, or drop the red claim.

### S3-B-03 (EG) — Validation bundle incomplete on this head; two runs failed for harness reasons unrelated to the candidate

- `05-tsc.log`: `npx tsc --noEmit -p tsconfig.json` exit 134 (V8 heap OOM at default ~2 GB). `06-lint.log`: exit 0, 0 errors, 21 warnings. `07-full-jest.log`: exit 134 heap OOM after ~210 s in-band. CI documents `NODE_OPTIONS=--max-old-space-size=4096` for both Type-check and Test (`.github/workflows/ci.yml`); the builder's 05/07 did not set it, so these are harness mismatches, not product findings. Builder's `09-tsc-ci-env` and `10-full-jest-sharded` are the correct follow-ups; results pending.
- Not executed on this head at dispatch: `test/ci/r75-gate|boundaries|wiring|enforcement.spec.ts` (~1,100 lines, S2 domain but part of this candidate), `npm run build` (production compile via `tsconfig.build.json`), `npm audit --package-lock-only …` (needs network; the new workflow has not run remotely on this head as far as any log shows), `danger` 13 against `dangerfile.js` (see S3-B-12).
- Requested: complete `09` and `10` (or an equivalent worker-based run), plus `npm run build`, each with head/tree header. `04-check-r75.log` already shows `check-r75.js --mode=range --base=c23b9d9f --head=HEAD` → `OK` on `5c7b42b3…` (the `as never` +2 on `4b6385af` was fixed by the final commit) — reusable.

### S3-B-04 (N, latent) — 4xx `HttpException` with an ORM cause is returned as `statusCode: 4xx, message: "Internal server error", error: "Internal Server Error"`

- `src/filters/http-exception.filter.ts`: when `ormBoundary` is true the filter skips the `HttpException` body and falls through to the defaults `message='Internal server error'`, `error='Internal Server Error'` while keeping `exception.getStatus()`. For the tested vectors (404 from P2025, 409 conflict, 422, 503 in `scout-diagnostics-public-cause.spec.ts`) the client receives a 4xx labelled "Internal Server Error". The harness only asserts a non-empty message, so the tests accept this. Mobile reads `message` (per the filter's own header comment), so this is customer-visible copy. G02 requires accurate, actionable errors.
- Not live today: no `src` producer constructs an `HttpException` with a `cause` (grep). Hence nonmaterial for this head, but the D1 lane exists precisely to allow such wrappers, so it will become live.
- Smallest fix: when `ormBoundary && exception instanceof HttpException`, set `error` from `exception.name.replace(/Exception$/,'')` (e.g. `Not Found`) and a generic status-appropriate message (e.g. `Request could not be completed`), never the 500 text for a 4xx; add one assertion in `expectSanitizedEnvelope` that `body.error` is not `Internal Server Error` when `status < 500`.

### S3-B-05 (N) — Probe design: fixed 20 s `spawnSync` bound on a cold ESM load of `c12`/`jiti` is load-sensitive, and the "fixture retained only on failure" contract does not hold on external kill

- `test/dependency-compatibility.spec.ts` `probe()` uses `timeout: 20000` for all probes including the c12 one, which cold-loads ESM `c12` (+ `jiti`, `chokidar`, `giget`, `dotenv`, …) and transpiles TS. Under contention it times out (S3-B-01) and the `finally` never runs, leaving `/tmp/prisma-dependency-*` behind (observed). A required gate that fails on machine load, not on behaviour, weakens G07's "valid evidence" property.
- Smallest fix: give this probe a hang-guard bound (e.g. 90–120 s) distinct from behavioural assertions, and have the child print elapsed ms to stderr on failure paths only. Do not loosen behavioural assertions.

### S3-B-06 (N) — Startup and readiness database-failure diagnostics drop the failure class

- `src/prisma.service.ts` now logs only `{event:'database_startup_connection_failed'}`; readiness logs only `readiness_database_unavailable|timeout`. Prisma init/known errors carry a safe class code (`P1000` auth, `P1001` unreachable, `P1002` timeout, `P2xxx`), which `safeDiagnostic` already extracts for known request errors. Operators lose the distinction between a bad credential and an unreachable host. Redaction goal is met; actionable state is reduced (G15).
- Smallest fix: include `error_code` when the rejection is `PrismaClientInitializationError` (`errorCode`) or `PrismaClientKnownRequestError` (`code`) and matches `/^P\d{4}$/`; keep messages out. Extend the readiness/startup redaction tests with a `P1000` case asserting code present, sentinel absent.

### S3-B-07 (N) — `stripSensitiveHeaders` is dead in the production path but still tested and listed as active

- `beforeSend` no longer calls it (request data is dropped wholesale). `sentry-config.spec.ts` still enumerates it as item 8. Cheap cleanup: delete or mark as unused; not a boundary weakness (the new allowlist is stricter).

### S3-B-08 (N) — Non-ORM Sentry error events drop `contexts` (including `trace`), `user`, `server_name`, `fingerprint`

- Intentional per README ("not forwarded"). Cost: error↔trace linking in Sentry is lost. Acceptable trade-off for the stated boundary; record so nobody later files it as a regression without context.

### S3-B-09 (N) — Scout push copy

- `src/scout/scout.service.ts`: "Records were staged in TGP. Migration is not verified. Check the importer status." Truthful direction is right (G02: no completion claim). "TGP" is an internal abbreviation and "importer status" is not an identified coach-facing surface in the plan's current contract gap. Product copy owner should confirm; not an S3 blocker.

### S3-B-10 (X → S2) — Readiness check activation is a platform-behaviour change

- `fly.toml` adds the first `[[http_service.checks]]` (base had none), so DB outage now withdraws every machine from routing, including DB-independent public/trust/help pages and `/.well-known/*`; a DB outage during `fly deploy` will also block rollout. This matches the documented `/readyz` intent and the code comments, and `X-Forwarded-Proto: https` is consistent with `force_https` (app has no https redirect middleware; helmet only). It is nonetheless a deploy-time activation that S2 owns; S3 should not be treated as having established the deployed behaviour, outage, or recovery evidence (`fly-readiness.spec.ts` is a literal-text contract, as it says).

### S3-B-11 (X → S2) — R75 gate policy is read from the candidate head

- `scripts/check-r75.js` reads `${head}:.github/r75-policy.json`. In `pull_request` runs the workflow file itself also comes from the candidate, so this is not a regression versus the previous inline YAML, but G07's "trusted policy outside the candidate's unilateral control" is still not met by repository content alone. Branch-protection/required-context evidence is S2's.

### S3-B-12 (N / EG) — `danger` 12→13 major with `@octokit/*` majors; `dangerfile.js` not executed against 13

- Dev-only; the Danger job fails visibly if the DSL broke (`danger.git.JSONDiffForFile`, `diffForFile`, `github.pr` are retained in 13 per my reading of the fixture rationale; not executed). Nonmaterial; note that the compatibility spec's Danger probe covers only `localGetFileAtSHA`.

### Residual risk noted, not a finding against this head

- After the 3 s bound, the underlying `$queryRaw` is not cancelled. Under a black-hole DB (no `socket_timeout`/`statement_timeout` in `DATABASE_URL`), one stranded query per 15 s probe can occupy pool slots (default pool ≈ 5 on 2 vCPU, `pool_timeout` 10 s) and could keep readiness failing after DB recovery until restart. Strict improvement over base (which waited unbounded), so not blocking here; owner of connection-string parameters (S1/S2) should decide whether to bound server-side.

## Acceptance-scope checklist

| Scope item | Assessment |
|---|---|
| Dependency/consumer compatibility, scoped overrides, resolved graph | Manifest exact-pins, three version-keyed overrides, `minimatch` override removal, and floors match the lockfile (independently mapped). Resolved-floor test design is sound. **Consumer proof for `deepmerge-ts@8` under `@prisma/config→c12` is open (S3-B-01).** `npm audit` on this lockfile not evidenced. |
| Redaction/diagnostics | Route-template-only paths in filter/throttler/interceptor; ORM chain sanitizer with cycle guard; Sentry allowlist verified by a separate-process default-integration fixture; readiness/startup static events. Sound. Class-code loss (S3-B-06) and 4xx copy incoherence (S3-B-04) are nonmaterial. `subscription.guard.ts` raw-URL fallback pre-existing, out of diff. |
| Tenant/auth boundaries | Only `@Public()` health/readiness touched; `readyz` already excluded from `/api` prefix; `no-store` added. No auth/tenant change. |
| Bounded readiness/retries/resources/settlement truth | Readiness bounded below platform timeout; scout copy no longer claims completion; no retry loops added. Residual pool risk recorded. **Execution evidence pending (S3-B-02).** |
| Tests select intended code and failure modes | Yes for all read tests (real filter/controller/SDK serializer, sanitized envelopes, cyclic causes, unmatched routes). Weak spot: harness accepts "Internal Server Error" on 4xx. |
| Preservation/applicability of inherited workflow/dependency changes | `.github/*`, `lefthook.yml`, `fly.toml`, `scripts/check-r75.js` preserved intact from #525 lineage; `check-r75` OK on final head; r75 spec suites not executed here (S3-B-03). |
| No accidental activation / no deployed-outcome claims | Only platform activation is the intended fly readiness check (S3-B-10, S2). Builder report makes no deployed/customer claims. This report makes none. |

## Verdict and limitations

- **Verdict: NOT CLEARED (round 1).** No material product defect was demonstrated in source review. Clearance is withheld for evidence reasons: S3-B-01 (unresolved failure on the decisive compatibility test), S3-B-02 (no run of the final fix), S3-B-03 (type-check, full suite, build not completed on this head).
- Closing condition for my attestation on this exact head/tree: attributable logs (head/tree/node/npm header) showing (a) `test/dependency-compatibility.spec.ts` 10/10 green under isolated conditions with the timed probe recorded; (b) the three readiness specs green; (c) `tsc --noEmit` (CI heap) exit 0, `npm run build` exit 0, full jest (CI heap, in-band shards or workers) green including `test/ci/r75-*`. If (a) reveals a real hang or >5 s idle latency, S3-B-01 converts to a material defect and the override composition must change; that would be a new head and this report would need the re-review scope stated below.
- Nonmaterial items S3-B-04…09/12 do not block; S3-B-04 should be fixed before the D1 lane introduces a live `HttpException`-with-cause producer.
- Cross-lane prerequisites for T4/release, not established by S3: S2 (fly check activation, branch protection/required contexts, policy trust, source-image equivalence), S1 (DB authorization/recovery), S5 (G2 proof).
- If source changes: preserve this report; re-review scope = the changed files plus `test/dependency-compatibility.spec.ts` and `docs/dependencies/…repair.md` if any override moves, plus re-execution of (a)–(c) on the new head. No approval transfers automatically.
