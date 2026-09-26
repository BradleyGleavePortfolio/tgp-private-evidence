# S12-B1 independent T4 review — 3bfe24f0

**Verdict: NO-GO as a complete R-DARK-1/kill-switch closure; conditional GO for the authenticated pilot allowlist itself after B1 is closed.** The new guard fails closed for the 15 mounted, non-public importer routes when the feature flags are on: an absent/empty/malformed list allows no authenticated caller, and an off-list caller receives a 404 before the throttler and role guard. But it does **not** close the already-landed case-sensitive flag-middleware defect for unauthenticated case-variant requests or for CORS preflights. Do not describe the kill switch as uniformly dark for every flagged path/caller until the middleware is fixed and the new cases tested.

Scope: read-only review of `/home/user/workspace/worktrees/fa72-s12b1`, HEAD `3bfe24f0ca82beafea4a9519c6ee4e7bc91b682e`, parent `aed23289`, tree `e883014ebac226ea7827bca9dbe487f0a2509a4e`. No product edits, remote writes, or PostgreSQL operations. The existing R-DARK-1 bytes were examined only to assess the explicitly granted F1 interaction, not re-audited broadly.

## A/B findings

### B1 — case-variant requests evade the pre-auth flag gate; the new guard is too late for some callers/methods

- **CLASS:** B (R-DARK-1 existence disclosure and incomplete flag-off kill-switch guarantee; pre-existing root defect, not introduced by this commit).
- **CONCRETE HARM:** `featureFlagNotFoundMiddleware` compares `req.path` with lowercase patterns case-sensitively (`src/common/feature-flag/feature-flag-not-found.middleware.ts:37-39`), while Express routes case-insensitively. For `POST /API/scout/ingest` with `FEATURE_SCOUT_INGEST=false`, middleware passes through. An authenticated on-list coach then receives 404 from the new guard, but a missing/invalid JWT receives **401 from JwtAuthGuard before the pilot guard**; a deleted/scheduled-deletion user may receive **403**. Those differ from the canonical flag-off 404 and disclose the mounted route/flag branch. A CORS `OPTIONS /API/scout/ingest` preflight with an allowed origin is answered by `enableCors` **before any guard** (204 with preflight headers), rather than the canonical flag-off 404. The same defect applies to case variants of `/api/extension/pair/*` (the public `redeem` does reach the new guard for a non-preflight request) and `/api/scout/reconstruct/*`. The builder's prior probe recorded the unauthenticated 401 in `s12b1_build.md` F1; my code-path assessment confirms the new guard cannot intercept it. The new suite checks the case-variant flag-off path only with an authenticated pilot for the 15 routes and with anonymous `redeem`, not anonymous non-public routes or OPTIONS.
- **EXACT DECISION BLOCKED:** Claiming S12-B1 completely closes R-DARK-1 F1 / that owner item 4 or 6 can rely on the flag-off switch returning a uniform 404 for *every* caller and method on the importer surface; approving this T4 slice as a full fail-closed dark-surface boundary.
- **MINIMUM CLOSURE:** Fix the pre-auth middleware match to be case-insensitive (normalize `req.path` and each registry pattern consistently, retaining segment boundaries and layered reconstruct flags). Add real HTTP assertions for all three flag families on case-variant paths with absent/invalid JWT and for OPTIONS preflight: flag off must return the existing 404 envelope and headers rather than 401/204; flag on should keep intended auth/preflight behavior. This is a targeted fix to F1, not a general re-audit of the landed middleware.
- **EXECUTION UNLOCKED:** A reliable pre-auth dark route and kill switch for the entire importer surface, including anonymous callers and browser preflights; a defensible S12-B1 T4 acceptance and subsequent owner flag decision.

**No class A finding.**

## C list — record, qualify, continue

1. **C1 — authenticated allowlist is correctly fail-closed within its scope.** `parsePilotCoachAllowlist` accepts hyphenated hex UUIDs only, trims and lowercases them, and discards the *whole* list if any nonempty entry fails validation; there is no wildcard or owner-role bypass. The guard uses the verified `req.user.id` after `JwtAuthGuard`, re-reads environment at request time, and runs before `UserThrottlerGuard`/`RolesGuard`. All 15 mounted non-public routes under `@Controller('scout')` and `@Controller('extension/pair')` inherit the gate through `FEATURE_GATED_ROUTES`; the actual `main.ts` uses global prefix `api` and does not enable URI versioning. The seven scout controllers and the pair controller match the build inventory. Both new suites passed independently (148 tests); the bootstrap suite uses real guards and HTTP, though stub handlers rather than real services. No new tenant bypass was identified.
2. **C2 — ordinary-path response identity is tested, not a universal timing guarantee.** The HTTP comparison for `POST /api/scout/ingest` pins status, JSON (except timestamp), header-key set, content length/type, request ID, allowed-origin CORS and Vary against flag-off and an equal-length unmounted URL. Guard execution before throttling prevents `X-RateLimit-*` from appearing on off-list 404s; ETag is generated over equivalent bodies. Other routes are checked for their 404 envelope but not individually for header equivalence. Off-list responses still pay JWT verification and user lookup, while flag-off and unmounted responses skip that work; timing is not indistinguishable, and there is no timing assertion. This is an architectural limitation of the specified after-auth design, not evidence of a second newly introduced authorization bypass.
3. **C3 — public redeem is an intentional exemption.** `POST /api/extension/pair/redeem` remains accessible when pairing is on and the list is empty, per the grant: the code must first have been minted by an on-list caller of guarded `init`. Existing redeem rate limiting remains downstream; a case-variant flag-off redeem is rejected by the new guard for non-preflight requests, but the preflight aspect belongs to B1.
4. **C4 — test limitations and future route coupling.** The static controller inventory parses decorator text and pins the 15 + redeem route set but is not a production `AppModule` HTTP boot; it would need updating if a new importer controller is mounted outside the two existing prefixes. S8-D unlink routes do not yet exist in these controllers. New routes outside these prefixes must be explicitly added to `FEATURE_GATED_ROUTES`; no claim is made for them here.
5. **C5 — configuration and operational boundaries.** The commit documents an empty default and adds the switch to `prod-switches.yml` with `auto_flip_on_in_prod: false`; it does not change production flags, deployment workflow, or any existing importer controller. Adding this variable to the operator workflow is the separately granted S12-B6 work, not performed in this slice. No PostgreSQL lane was run; builder's other reported checks were read as claims, not re-run by this reviewer.

## Reviewed files, hashes, LOC

Paths below are relative to `/home/user/workspace/worktrees/fa72-s12b1`; LOC are full file lengths (the commit is +1223/−0). Hashes were computed from the reviewed working tree, which was clean.

| Path | SHA-256 | File LOC | Commit delta |
|---|---|---:|---:|
| `.env.example` | `99111735292045477e769355b9c87e0b8ad8cc1688f1f78d57d809ef4ef4f40c` | 902 | +10 |
| `docs/decisions/2026-09-26-s12b1-pilot-coach-allowlist.md` | `07307fedf8a5613b5a8979180358a95ea928fd8f8a82bd651b3db45ce6ccc098` | 55 | +55 |
| `prod-switches.yml` | `9cae3f7372b585453ac7dd334f5ca21b0e935790d0396960a7271735ba4db98c` | 1403 | +6 |
| `src/app.module.ts` | `5dbf0f17797658e716ab404b57e87a16b295eb7d9c3b663dfdb7c84dbeb92e3f` | 477 | +14 |
| `src/common/feature-flag/pilot-coach-allowlist.guard.ts` | `5175c8042d8ed8d6ecf37589153cac2331887fa9a79df12b7698d15f511884f4` | 87 | +87 |
| `src/common/feature-flag/pilot-coach-allowlist.ts` | `48bd0e87dc13d8d2911024c9d936fd387b8c71e9d4626209c6200f64942b7f53` | 135 | +135 |
| `test/common/pilot-coach-allowlist.bootstrap.spec.ts` | `f59e8ae656841d448b65248a49ab7f5a45dcee3f6740a068aca80e2cffe3e769` | 546 | +546 |
| `test/common/pilot-coach-allowlist.spec.ts` | `4efdf9032956674e344439b03fb553f2f78152dcb08c2732f2ecf540a67dfa27` | 370 | +370 |

Production additions: 14 lines to `app.module.ts` plus 222 new guard/parser lines; tests: 916 new lines. Context files read but unchanged include `src/main.ts`, `src/common/feature-flag/feature-flag-not-found.middleware.ts`, the scout and pair controllers, `src/auth/auth.guard.ts`, request-ID/CORS/error-envelope/filter helpers, and the grant/build/readiness evidence.

## Commands run and RC

1. Parallel read-only shell calls: `sed -n ... WORKER_RULES.md S12B1_REVIEW_GRANT.md` — RC 0; `git status --short; git show --stat --oneline --decorate 3bfe24f0; git show --format=fuller --no-patch 3bfe24f0` — RC 0.
2. Parallel read-only shell calls: `sed -n ... S12B1_BUILD_GRANT.md s12b1_build.md S12_PILOT_READINESS.md` — RC 0; `git show --format= -- [changed source/config/docs]` — RC 0; `rg -n ... src/common src/app.module.ts src/main.ts | head -300` — RC 0.
3. Parallel read-only shell calls: `sed -n ... readiness/build` — RC 0; `sed -n ... feature-flag-not-found.middleware.ts main.ts; rg -n ... src/scout src/extension-pair` — RC 0; `sed -n ... pilot-coach-allowlist.bootstrap.spec.ts` — RC 0; `sed -n ... pilot-coach-allowlist.spec.ts; rg -n ... src` — RC 0.
4. Parallel read-only shell calls: `sed -n ... main.ts pilot-coach-allowlist.bootstrap.spec.ts` — RC 0; `sed -n ... bootstrap/unit specs auth.guard.ts http-exception.filter.ts` — RC 0; `rg -n ... main.ts src/scout src/extension-pair; test -e /home/user/workspace/execution/fa72efb2/PROOF_SLOT_FREE; git diff --check 3bfe24f0^ 3bfe24f0` — RC 0 (proof-slot check 0, diff check 0).
5. Parallel read-only shell calls: `sed -n ... bootstrap.spec.ts app.module.ts; rg -n ... src/scout src/extension-pair src/app.module.ts` — RC 0; `sed -n ... main.ts request-id.middleware.ts not-found-envelope.ts cors-origins.ts extension-pair.controller.ts` — RC 0.
6. `cd /home/user/workspace/worktrees/fa72-s12b1 && NODE_OPTIONS=--max-old-space-size=3072 flock -w 3600 /home/user/workspace/execution/test-validation.lock bash -c './node_modules/.bin/jest --runInBand test/common/pilot-coach-allowlist.spec.ts test/common/pilot-coach-allowlist.bootstrap.spec.ts'` — RC 0, 2 suites/148 tests passed; no DB.
7. `git diff-tree --no-commit-id --name-only -r 3bfe24f0 | while ... sha256sum; wc -l ...; git status --short; git rev-parse 3bfe24f0^{tree}` — RC 0, clean status and tree as above.

Open risk: B1 remains until the parent authorizes a focused middleware follow-up and independent HTTP proof. Timing differences and the public-code design are qualified in C2/C3; the no-DB test does not establish a real deploy or real-PG tenancy result.

---

## Round 2 — independent delta review of `f48395df`

**Current verdict: GO for B1 closure and S12-B1 T4 source acceptance.** This supersedes the first-round NO-GO above, which remains as the historical review of `3bfe24f0`. Scope is *only* the B1 closure delta `3bfe24f0..f48395dfa57f180ae4bd60fb75d592b387c3c4c5`; unchanged guard, registry, controllers, and other first-round findings were not re-audited. The round-2 tree is `8b13811ecc677653a631538075d65fd0fff69028`; no source edits, remote writes, or PostgreSQL activity by this reviewer.

**B1 — CLOSED.** The pre-auth middleware now lower-cases `req.path` *and* registry patterns before applying the existing exact-or-`pattern + '/'` prefix comparison (`src/common/feature-flag/feature-flag-not-found.middleware.ts:43-47`). Therefore any case spelling of a matched path, with any HTTP method, is short-circuited before JWT, CORS, or the pilot guard when its flag is not literally `'true'`. This includes anonymous/malformed-bearer, authenticated on/off-list and deleted-account paths, and OPTIONS preflights; the old 401/403/204 escape for case variants is no longer on the request path. It retains the segment boundary (`/API/scouting`, `/api/SCOUT-x`, `/API/extension/pairing` are not swallowed), both reconstruct layers (`INGEST` and `RECONSTRUCT`), and the original URL spelling in the 404 envelope. Flag-on requests still reach JWT, the allowlist guard, and `@Public` redeem as before.

The new tests exercise four real-HTTP representatives across all three flag families (including both a reconstruct write and read), flag-off anonymous/invalid-bearer/on-list/off-list/OPTIONS, flag-on anonymous/preflight/on-list/off-list, and case-variant public redeem POST/OPTIONS. They compare ordinary dark responses with a same-length unmounted reference and dark preflights with their canonical-spelling counterparts, including body except timestamp and header keys. A middleware unit test directly pins case folding, layered reconstruction, and sibling prefixes. I independently ran the four relevant no-DB suites: **207/207 passed**. The generic matcher, rather than method-specific special cases, gives this closure across the mounted route inventory reviewed in round 1.

**Residual C (accepted, not a B1 blocker):** When flags are lit, an unmounted OPTIONS path under a lit prefix receives app-wide `enableCors` 204, like unmounted paths outside the importer prefixes. A dark matched preflight returns 404 before CORS, by the already accepted R-DARK-1 contract. Accordingly, the correct preflight identity reference is the canonical dark URL, *not* an unmounted lit-prefix path. This does not re-open the flag-off case-variant bypass. First-round C2 timing qualification remains unchanged; no claim of equal wall-clock latency is made.

### Round-2 file identities and LOC

All paths relative to `/home/user/workspace/worktrees/fa72-s12b1`; LOC = complete post-commit file length:

| Path | SHA-256 | LOC | Delta |
|---|---|---:|---:|
| `src/common/feature-flag/feature-flag-not-found.middleware.ts` | `fd9623e5f4436809f66f471be18acdd8e23c94763425d7287cc54a877896ce4f` | 74 | +8/−2 |
| `test/common/feature-flag-not-found.spec.ts` | `f91f045c9e837f14aecd15c955a193e691991d048d77d7db1810d74e75b0cb2a` | 259 | +33 |
| `test/common/pilot-coach-allowlist.bootstrap.spec.ts` | `43971b6d775b14de5fb408e4ee58febb0cb8578285ba832f5d455e277ebf8b70` | 724 | +178 |

### Additional commands and RC

8. Parallel read-only: `git status --short; git show --stat --oneline f48395df; git show --format= -- [three changed paths]` — RC 0; `rg -n 'Round 2|F1|case-variant|OPTIONS|sibling|reconstruct|redeem' s12b1_build.md | tail -80; git diff 3bfe24f0 f48395df --numstat; git rev-parse HEAD; test -e PROOF_SLOT_FREE` — RC 0 (slot check 0).
9. Parallel read-only: `sed -n '480,685p' test/common/pilot-coach-allowlist.bootstrap.spec.ts; sed -n '140,220p' s12b1_build.md` — RC 0; `git diff --check 3bfe24f0 f48395df; sha256sum and wc -l on the three changed files` — RC 0 (diff check 0).
10. `cd /home/user/workspace/worktrees/fa72-s12b1 && NODE_OPTIONS=--max-old-space-size=3072 flock -w 3600 /home/user/workspace/execution/test-validation.lock bash -c './node_modules/.bin/jest --runInBand test/common/feature-flag-not-found.spec.ts test/common/feature-flag-not-found.bootstrap.spec.ts test/common/pilot-coach-allowlist.spec.ts test/common/pilot-coach-allowlist.bootstrap.spec.ts'` — RC 0; four suites, 207 tests passed.
