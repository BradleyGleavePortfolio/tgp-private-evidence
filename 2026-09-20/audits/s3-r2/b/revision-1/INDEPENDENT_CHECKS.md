# S3 R2 auditor B — independent read-only checks (2026-09-20, ~21:00Z)

All commands run read-only against `/home/user/workspace/worktrees/s3` (pinned) and the archived packet
`/home/user/workspace/repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/`. No installs, no candidate edits, no heavy tests, no lock taken.

## Identity
- `git rev-parse HEAD HEAD^{tree}` → `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06` / `83211d25d714e4c539cd3aa248a06ef0658fc8e7`
- `git status --porcelain` → empty
- `git merge-base --is-ancestor c23b9d9f… HEAD` → true; `git rev-list --count c23b9d9f..HEAD` → 23
- author|committer over the 23 commits → 23 × `Bradley Gleave <bradley@bradleytgpcoaching.com>`
- `git rev-parse 925780e0^{tree}` → `911bea30d2e58c2573dd8af948c27d8bd4ccb952` (matches log 16 header)
- `git diff --stat 925780e0 5c7b42b3 -- package-lock.json package.json` → empty (lockfile identical between pre-fix and fixed head, as log 16 asserts)
- `git diff --stat 925780e0 5c7b42b3` → 2 files (`src/health/health.controller.ts` +42/−7-ish, `test/health-readiness-bounded.spec.ts` +100)
- Evidence repo HEAD `7ab6af940c16f087dcaabbf07a55e9154405e68a` (matches brief)

## Packet integrity
- `sed 's#execution/s3-backend/##' SHA256SUMS.txt | sha256sum -c -` → every listed file OK (no non-OK lines)
- `git bundle verify s3-backend-5c7b42b3.bundle` from inside worktrees/s3 → "is okay"; head `5c7b42b3` on `refs/heads/execute/20260920-s3-backend`
- `diff -rq revision-1/logs revision-2/logs` → no differences (logs unchanged between revisions; only prose + publication/ files changed)

## Full-suite applicability (log 10)
- Shard suite totals 140+139+139+139 = 557; passed 137+135+136+137 = 545; skipped 3+4+3+2 = 12
- Tests 2105+2211+1886+2007 = 8209 passed; skipped 35+22+56+46 = 159; todo 5; `grep -c '^FAIL'` → 0; `overall_exit=0`
- Independent count of spec files selected by `jest.config.js` roots/testRegex/testPathIgnorePatterns in worktrees/s3 → **557** (matches)
- All candidate-diff suites appear as PASS in log 10 (dependency-compatibility, health-readiness-bounded/public, health.controller, r75-gate/boundaries/wiring/enforcement, r100-pathspec, dependency-audit, fly-readiness, lockfile-relevance, orm-composed-http, sentry-incoming-request, sentry-config(+extended), http-exception.filter, scout-diagnostics-*, scout.service.spec, rate-limit)
- Skipped-suite names are not printed (`--silent`, default reporter); DB-gated `describe.skip` suites exist in default selection (`test/community/**` e2e/live, `test/mwb-3-*`), none in the diff (`git diff --name-status c23b9d9f..HEAD | grep -E 'community|mwb'` → empty)
- `test/rate-limit.spec.ts`: 606.8 s in log 02 (load 10.9–13.2) vs no duration printed in log 10 (i.e. < 5 s slow-threshold) — same tree

## c12 / deepmerge-ts seam adequacy
- Lockfile: `@prisma/config 6.19.3`, `c12 3.1.0`, `deepmerge-ts 8.0.0`, `jiti 2.7.0` (all devOptional); `package.json` overrides `@prisma/config@6.19.3 → deepmerge-ts 8.0.0`
- `@prisma/config@6.19.3/dist/index.js` (unpkg): `loadConfigTsOrJs` passes `merger: deepmerge` (from `deepmerge-ts`) to c12 `loadConfig`
- `c12@3.1.0/dist/shared/c12.*.mjs` (unpkg): `const _merger = options.merger || defu;` and `r.config = _merger(configs.overrides, configs.main, configs.rc, configs.packageJson, configs.defaultConfig)` — invoked unconditionally, so the spec's c12 case exercises deepmerge-ts@8 as the real merger and asserts the merged result
- Probe body in logs 08/14 vs spec case (`test/dependency-compatibility.spec.ts:133–160`): same `require('@prisma/config')`, same fixture, same `loadConfigFromFile` + `ConfigFileNotFound` assertions (spec adds resolvedPath/migrations assertions and fixture retention)
- No `prisma.config.*` in the repo → the release path (`scripts/release.sh` → `prisma migrate deploy`) does not exercise this loader today

## Readiness / redaction source spot-checks
- `test/health-readiness-bounded.spec.ts` imports `READINESS_TIMEOUT_MS` (not exported on 925780e0) → running that spec on the pre-fix head would fail at compile, not behaviourally (builder's statement verified)
- Bounded spec mocks `Logger.prototype.error`; the `readiness_database_unavailable` line in log 11 therefore comes from `health.controller.spec.ts`, not the bounded spec
- `/readyz`: `HEALTH_PATHS` in `src/throttler/user-throttler.guard.ts:8`; excluded from `/api` prefix `src/main.ts:150`; `NO_STORE_PREFIXES` in `src/common/cache-control.interceptor.ts:39`
- `HttpException` producers with an ORM `cause` in `src/` (non-spec): none. `ProviderHttpError` (`src/wearables/http/provider-http-client.ts:51`) carries `cause` but extends `Error`, not `HttpException` → maps to generic 500 envelope. `AggregateError` / `Promise.any` in `src/`: none.
- Raw-URL fallbacks remaining: `src/throttler/user-throttler.guard.ts:50,115` (path-matching only), `src/billing/subscription.guard.ts:246` (pre-existing, outside diff)
- Real Prisma error classes used by tests: `test/observability/orm-composed-http.spec.ts:24,114`, `test/scout/diagnostics-public-harness.ts:31–43` (Known/Unknown/Validation/Initialization/RustPanic)

## Env stamping
- `run-step.sh` (used for 05/06/07/09) stamps head/tree/node/npm only; `run-step2.sh` (11–15) stamps `NODE_OPTIONS` and loadavg. Log 09 therefore has no `NODE_OPTIONS` record and no end timestamp; `run-chain3.sh` exports `NODE_OPTIONS=--max-old-space-size=4096` for 11–13 and unsets it for 14–15.
