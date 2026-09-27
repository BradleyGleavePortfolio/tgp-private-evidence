# N1 BUILD — vendor-name guard (T1)

Builder: Bradley Gleave `<bradley@bradleytgpcoaching.com>`  
Date: 2026-09-27

## Pull requests

| Repository | Base | Head | PR | Commit |
| --- | --- | --- | --- | --- |
| growth-project-backend | `integration/importer` | `ci/vendor-name-guard` | https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/573 | `27bca92d` |
| tgp-importer-extension | `main` | `ci/vendor-name-guard` | https://github.com/BradleyGleavePortfolio/tgp-importer-extension/pull/33 | `1087d2a` |
| growth-project-mobile | `main` | `ci/vendor-name-guard` | https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/299 | `3038572` |

## Delivered

- Added dependency-free Node guards that enumerate tracked files with `git
  ls-files`, match the prescribed names case-insensitively, reject unallowlisted
  hits, print each allowlist count, and reject stale zero-hit entries.
- Added `guard:vendors` and a CI step in each repository's main workflow.
- Kept the allowlists explicit and retained source-specific extension runtime
  files only under the T4 retirement marker.
- Neutralised vendor wording outside the allowlists. Backend Swagger values now
  use `example-site`.

## Allowlist counts

### Backend

| Glob | Hits |
| --- | ---: |
| `.vendor-name-guard.json` | 1 |
| `test/**` | 656 |
| `src/**/__tests__/**` | 47 |
| `src/**/*.spec.ts` | 53 |
| `docs/decisions/**` | 17 |
| `docs/importer/NORTH_STAR.md` | 3 |
| `src/scout/reconstruct/sources/truecoach.json` | 1 |

### Extension

| Glob | Hits |
| --- | ---: |
| `.vendor-name-guard.json` | 2 |
| `test/**` | 249 |
| `docs/AUTO_DISCOVERY.md` | 21 |
| `docs/DECISION_V03_AUTONOMOUS_CRAWL.md` | 14 |
| `docs/DESIGN.md` | 22 |
| `docs/PACKAGE_PROOF.md` | 1 |
| `docs/REAL_GOAL_EXECUTION_PLAN.md` | 8 |
| `docs/ROADMAP.md` | 53 |
| `docs/SECRETS_SCANNING.md` | 1 |
| `docs/TIER0_CONTRACT_INTEGRITY.md` | 2 |
| `docs/first-principles.md` | 3 |
| `extractors/truecoach/**` | 26 |
| `extractors/truecoach.js` | 10 |
| `extractors/detect.js` | 16 |
| `manifest.json` | 4 |
| `background.js` | 5 |
| `shared/capture-policy.js` | 3 |
| `shared/protocol.js` | 2 |
| `shared/replay/resolve.js` | 4 |
| `scripts/browser-load-proof.mjs` | 1 |
| `_locales/en/messages.json` | 1 |
| `.gitleaks.toml` | 1 |

### Mobile

| Glob | Hits |
| --- | ---: |
| `docs/importer/NORTH_STAR.md` | 3 |
| `src/**/__tests__/**` | 275 |
| `src/**/__fixtures__/**` | 11 |
| `src/constants/importPlatforms.ts` | 11 |

## Validation

- Guard passed in all three repositories.
- Extension: lint, formatting, type check, hook checks, and
  `test/policy-alignment.spec.js` passed locally. The full extension suite was
  also run; its policy suites failed before the guard integration update and
  are superseded by the green PR CI run.
- Backend and mobile local dependency installs were incomplete on the shared
  host; the affected local lint commands could not load their toolchains. Their
  PR CI runs are the authoritative clean-environment validation.
- No PostgreSQL lane was run locally.

## Snapshot updated

- Backend: `docs/contracts/importer-openapi.json`, updating the importer
  contract examples and source-slug description to `example-site`.

## CI conclusion at record time

- Extension PR #33: green.
- Mobile PR #299: green.
- Backend PR #573: vendor guard, migration, RLS, audit, deployment-readiness,
  and size checks passed. `build-and-test` failed on ten pre-existing unused
  imports in unrelated files introduced by the updated base branch; the failing
  step's guard, Prisma generation, and N1 linted surfaces had already passed.

No PR was merged.

## Correction — 2026-09-27

- Backend #573 was corrected to preserve applied migrations and to scope the
  guard to importer paths only. Its final head is `0e2cd9cd`; all reported CI
  checks are green. The final backend ratchet counts are configuration 1,
  `src/scout/**/*.spec.ts` 6, extension-pair tests 47, `test/scout/**` 349,
  importer North Star 3, and the quarantined oracle 1.
- Extension #33 was closed as superseded. Replacement PR #34 is
  `ci/vendor-name-guard-r2` at `23bcb38d`, created from `main` `63873237`
  without changing `extractors/_interface.js`; all its CI checks are green.
- The backend importer-contract snapshot description was regenerated to match
  the DTO output after the neutral `example-site` change.
