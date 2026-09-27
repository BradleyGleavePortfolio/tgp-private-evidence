# S12-B1 independent T4 review, lens B (adversarial): `c9ccb2c9`

**Verdict: GO.** No A finding and no B finding. Seven C items are recorded below.

## Identity (verified)
| item | value |
|---|---|
| candidate | `c9ccb2c9a2dda063e357c9aa8af97ae7f87367ae`, tree `31afe6cac1009046bd854c42478c06c23ab33727`, one commit, parent `54be96f18c314cae35d1e5d3000af9f06d693d81` (`integration/importer`) |
| pushed ref | `git ls-remote preserve refs/heads/cand/x42/s12b1` returns `c9ccb2c9…` (RC 0) |
| author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` for both. No trailers in the message |
| diff | 10 files, +1616 −2. `git diff --check` RC 0. The sha256 of the four prod files matches BUILD.md §3 (`174e6709…`, `9618f51b…`, `32ec142b…`, `0cb27871…`) |
| base drift vs reviewed design | Reviewed base `aed23289` is not an ancestor of `54be96f1`. However, `git diff aed23289 54be96f1` touches only 1 file (−633 lines), and it lies outside `src/{scout,extension-pair,common,auth,filters,observability}`, `main.ts` and `app.module.ts`. So the guard's surroundings are byte-identical to the reviewed round |
| clone | `/tmp/revB`: standalone `git clone --no-hardlinks repos/backend` with push set to `no_push://disabled`. `cand/x42/s12b1` is not a ref in `repos/backend`, so I fetched the commit read-only from the builder clone path. SHA and tree are verified above |

## Fidelity to the reviewed-GO design
The parser, resolver, matcher, guard decision order, wiring and middleware fold all match `fa72efb2/s12b1/s12b1_build.md` §1 and the round-2 closure in `s12b1_review.md`. D1–D7 are cosmetic or structural and do not change behaviour. D3 (`reflector.get(PATH_METADATA)`) gives the same result as the original. D5 (reduced affected-suite set) is acceptable: the `rg -l` importer set is covered, and the parent's full lane is the backstop.

## Adversarial audit (what I checked, with the result)
- **Fail-closed.** Absent, `''`, whitespace and `,,` all give an empty list. Any non-UUID entry empties the whole list. There is no wildcard. My probes: `"uuid"` (quoted) → 404; space-separated pair → 404. Trailing comma, trailing `\n`, NBSP padding and an upper-cased id are all admitted. That is correct: `trim()` removes only whitespace and the id is compared case-folded, so none of these widens the audience.
- **Flag literal.** `TRUE` and ` true` both → 404 for the pilot. Only the exact string `'true'` lights the surface.
- **Coverage is registry-derived.** The guard gates on `req.path` or the `@Controller` path matching `FEATURE_GATED_ROUTES`, so any new non-public route under `/api/scout` or `/api/extension/pair` is gated with no edit. `rg` found no importer controller outside those two prefixes, and `RouterModule` is not used. Nothing rewrites `req.url` (checked with `rg`). The router's path source equals `req.path`: router 2.2.0 `getPathname` is `parseurl().pathname`. The path-to-regexp 8.4.2 regex uses flag `i` without `u`, so non-ASCII characters cannot case-fold onto ASCII route letters.
- **Path-shape probes over real HTTP, flags on, off-list caller:**
  - query string: 404 with body and header keys identical to an equal-length unmounted URL.
  - HEAD on a GET route: 404, headers identical to unmounted.
  - trailing slash: 404 off-list, 200 for the pilot.
  - `%73cout`: ordinary unmounted 404 for both off-list and pilot (not routed).
  - `//scout`: ordinary unmounted 404.
- **Guard order.** Jwt → Pilot → Throttler → Roles → Dunning. The static pin matches `app.module.ts`. No other `APP_GUARD` exists anywhere in `src`. Off-list 404s carry no `x-ratelimit-*` headers (confirmed by probe).
- **No owner bypass.** The owner is subject to the list. Controller-level `CoachGuard`, `JwtAuthGuard` and `RolesGuard` run after the global guards.
- **@Public.** The only `@Public` route is `redeem`. The flag re-check runs before the exemption.
- **Case variants and OPTIONS preflights.** With the fold, the middleware short-circuits every spelling and method before CORS and JWT. This is proved by the bootstrap `CASE_VARIANTS` suite, which I re-ran.
- **Non-importer routes.** An empty match returns `true` immediately. WebSocket and GraphQL entry points do not exist in `src` (`rg`).

## A/B findings
None.

## C items (record and continue)
1. **C1: the static inventory pin is regex-based.** It parses only single-quoted `@Get/Post/Put/Patch/Delete('x')` and a string `@Controller('x')`. It silently skips `@Get()` with no argument, `@All/@Head/@Options`, object or array `@Controller`, and a class-level `@Public()`. A future list-exempt `@Public` importer route could therefore land unpinned. Non-public routes are unaffected, because the runtime gate is prefix-derived. Optional hardening: exempt `redeem` by explicit handler identity, or enumerate routes through Nest discovery.
2. **C2: dark 404 headers differ for callers without an `Origin` header (baseline, out of scope).** When no `Origin` is sent, the R-DARK-1 middleware's dark 404 lacks `access-control-allow-credentials`, while router and guard 404s (after CORS) carry it. The effect is that it reveals "path is under a gated prefix", not route existence. Off-list ≡ unmounted still holds. This is pre-existing landed middleware behaviour, not introduced by this slice.
3. **C3:** Off-list probes are not per-user throttled (agrees with the builder's C1). They cost a JWT verify plus one user lookup, the same as a 401 today.
4. **C4:** Kill switch 3 (removing an id from the list) leaves that coach's open run open until they are re-listed and read status, which then fences it `timed_out`. Nothing becomes zero or `complete`. The runbook (S12-B4) should say so.
5. **C5:** The decision record header says "Accepted T4 decision record" before T4 acceptance. Wording only; it becomes true when the parent lands the commit.
6. **C6:** `cand/x42/s12b1` is not fetched into `repos/backend` (only `s12b2` and `s8d1` are). The parent should fetch it from `preserve` before landing.
7. **C7:** The builder's C3–C5 are agreed as stated: STUB_ALLOWED, `status` gated by prefix, D5/S8-D rows needed later, and S12-B6 must add the variable to `fly-feature-flags-set.yml`.

## Commands and RC
1. `git clone --no-hardlinks repos/backend /tmp/revB`; set push URL to `no_push://disabled`; `git fetch <builder clone> c9ccb2c9`; `git checkout c9ccb2c9`. RC 0. (`origin/cand/x42/s12b1` is absent from `repos/backend`: RC 128, then the fetch fallback above.)
2. Read-only `git log/diff/show`, `rg`, `sed` over the grant, rules, BUILD.md, the predecessor build/review, readiness §2b/§3.1/§3.2, prod and test files, `main.ts`, `auth.guard.ts`, the controllers, and router/path-to-regexp in the donor `node_modules`. RC 0.
3. `cp -al worktrees/x42-donor/node_modules /tmp/revB/node_modules` (sentinel `RC=0`). Completed: 60424 inodes, equal to the donor.
4. flock (inode 657581 lock), `NODE_OPTIONS=--max-old-space-size=3072`: `jest --runInBand test/common/zz-reviewb-probe.spec.ts`. RC 0. This is an uncommitted reviewer probe in `/tmp/revB` only; it reuses the bootstrap harness and adds the path-shape, list-spelling and flag-literal probes above.
5. Same lock: `jest --runInBand test/common/pilot-coach-allowlist.spec.ts test/common/pilot-coach-allowlist.bootstrap.spec.ts test/common/feature-flag-not-found.spec.ts test/common/feature-flag-not-found.bootstrap.spec.ts`. **RC 0, 4 suites, 333/333.**
6. `git ls-remote preserve refs/heads/cand/x42/s12b1` → `c9ccb2c9`; `git diff --check` RC 0; `sha256sum` on the prod files; `git merge-base --is-ancestor aed23289 54be96f1` → 1; `git diff --shortstat` of the relevant paths → empty. All RC 0 except the ancestor check (1, as reported).

Not run: PostgreSQL, the full jest lane, tsc and eslint (the builder's hooks ran them), and the contract generator. Nothing was committed or pushed, and the evidence repo is not committed.

LOC reviewed: prod +267 (≈137 code lines), test +1272, registry/docs +77.
