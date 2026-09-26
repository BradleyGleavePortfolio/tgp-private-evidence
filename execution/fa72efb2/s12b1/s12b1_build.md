# S12-B1 pilot-coach allowlist — build report (EXEC-FA72EFB2, T4 builder)

Grant: `execution/fa72efb2/s12b1/S12B1_BUILD_GRANT.md`. Rules: `execution/fa72efb2/WORKER_RULES.md`.
Spec: `s12/S12_PILOT_READINESS.md` §2b S12-B1 (L139), §3.1 L165, §3.2 kill switch 3 (L203 area), finding B1 (§5).

## 0. Identity

| item | value |
|---|---|
| clone | `/home/user/workspace/worktrees/fa72-s12b1` (standalone `git clone --no-hardlinks` of `worktrees/fa72-s11d2`; no `git worktree add`) |
| origin | `no_push://disabled-fa72efb2` (fetch and push) — nothing pushed, no PR, no ref moved |
| base | `aed23289024898cceca7385d3778cd7373b7424d` (S11-D r3) |
| branch | `fa72/s12b1` |
| **head** | **`3bfe24f0ca82beafea4a9519c6ee4e7bc91b682e`** |
| **tree** | **`e883014ebac226ea7827bca9dbe487f0a2509a4e`** |
| author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` / same; no trailers (`git log -1 --format=%B \| rg -i "co-auth\|generated\|claude\|gpt"` → no match) |
| commit path | ONE commit through installed lefthook hooks (pre-commit: prod-readiness-quick, banned-cast-tokens R75, eslint, prettier, tsc; commit-msg: no-ai-tokens) — all ✔️, no `--no-verify` |
| working tree after commit | clean (`git status --short` → 0 lines) |
| node_modules | `cp -al` from `worktrees/fa72-s11a1/node_modules`; no npm install/ci, no prisma generate |
| production / flags / workflows / deploy | untouched. `fly-feature-flags-set.yml` not edited (S12-B6). No `docs/contracts/**` change (no controller decorator touched, so the importer contract is unchanged; generator not run) |

## 1. Design

**Variable.** `FEATURE_SCOUT_PILOT_COACH_IDS` — comma-separated `User.id` UUIDs (Prisma `User.id @default(uuid())`, the same id every S8/S10 write is keyed by via `req.user.id`).

**Parser** (`src/common/feature-flag/pilot-coach-allowlist.ts`, pure, never throws):
- split on `,`, trim, drop empties; every remaining entry must match the canonical hyphenated UUID form (case-insensitive), stored lower-cased, de-duplicated.
- **ANY non-UUID entry ⇒ the WHOLE list is empty** (`ids = ∅`, `rejectedPositions = [i…]`). `*`, `true`, e-mail, wrong separator, brace/quote-wrapped, truncated or un-hyphenated forms are all junk. A typo can only shrink the audience; there is no "allow all" spelling.
- `resolvePilotCoachAllowlist(warnSink?)` reads the env at call time and memoises on the raw string; a malformed value logs **one** warning per distinct value (so: once at boot via `onModuleInit`, once more if ops set a different bad value). The warning names positions only, never entry text (a mis-pasted secret is not echoed).
- Gated-surface matcher: `matchedGatedRoutes(path)` = the `FEATURE_GATED_ROUTES` rows whose pattern prefixes the **lower-cased** path (segment-wise, so `/api/scouting` is not gated). One registry ⇒ one invariant: flag-gated ≡ pilot-gated. `matchedGatedRoutesForController(@Controller path)` is a URL-independent second signal. `isFlagDark(routes)` = any matched flag `!== 'true'`.

**Guard** (`src/common/feature-flag/pilot-coach-allowlist.guard.ts`, global `APP_GUARD`):
1. not gated by path nor by controller ⇒ `true` (every non-importer route untouched);
2. gated and `isFlagDark` ⇒ `NotFoundException("Cannot <METHOD> <url>")` — **before** the `@Public()` exemption (dark means dark for `redeem` too; see finding F1);
3. `@Public()` handler ⇒ `true` (only `POST extension/pair/redeem`; a code exists only if the gated `init` minted it for an on-list coach);
4. `req.user.id` is a string and lower-cased ∈ list ⇒ `true`; otherwise the same `NotFoundException("Cannot <METHOD> <url>")`.

The thrown exception is exactly what Nest's router raises for an unmounted route, so `HttpExceptionFilter` renders `{statusCode, message, error, timestamp, path, request_id}` identical to `buildNotFoundEnvelope` (the middleware's flag-off body). No owner-role bypass; no timing branch beyond the Set lookup (auth already ran in both on/off-list paths).

**Wiring** (`src/app.module.ts` L397-L446): `JwtAuthGuard` → **`PilotCoachAllowlistGuard`** (L410) → `UserThrottlerGuard` → `RolesGuard` → `DunningLockoutGuard`. Ordering is load-bearing and pinned by a static test:
- after auth so the id is the verified caller;
- **before the throttler** — my first cut ran after it and the bootstrap suite caught that the off-list 404 then carried `X-RateLimit-Limit/Remaining/Reset` while the flag-off 404 and an unmounted-route 404 do not (a distinguishable header signal). Moving it before the throttler makes all three 404s share one header set. Consequence: off-list probes are not per-user throttled — the same posture as the flag-off 404 and any unmounted route; on-list callers are throttled as before (finding F3);
- before `RolesGuard` so an off-list caller of any role (student, other coach, owner) sees 404, never 403.

**Registry.** `.env.example` L868-877 (documented, empty default) and `prod-switches.yml` L1398-1403 (`tier: feature`, `prod_default: STUB_ALLOWED`, `auto_flip_on_in_prod: false` — the auto-flipper skips STUB_ALLOWED as needs-human-judgement, so nothing can ever set it; `OFF` would have made the flipper's target value the literal `'false'`, which is not a meaningful value for an id list). R108 discovery (`test/deploy-readiness.spec.ts`, `test/prod-readiness/**`) is green with the row.

**Decision record.** `docs/decisions/2026-09-26-s12b1-pilot-coach-allowlist.md` (repo pattern: one ADR-style note per importer slice).

## 2. Route inventory (verified with `rg` against controllers and `FEATURE_GATED_ROUTES`; pinned by the static test)

`FEATURE_GATED_ROUTES` (`src/common/feature-flag/feature-flag-not-found.middleware.ts` L20-31): `/api/scout` (INGEST), `/api/scout/reconstruct` (RECONSTRUCT, layered), `/api/extension/pair` (PAIRING).

| # | route | file:line | roles | gate after S12-B1 |
|---|---|---|---|---|
| 1 | `POST /api/scout/progress` | `src/scout/scout.controller.ts:77` | coach, owner | flag + list |
| 2 | `POST /api/scout/ingest` | `src/scout/scout-ingest.controller.ts:86` | coach | flag + list |
| 3 | `POST /api/scout/ingest/complete` | `src/scout/scout.controller.ts:110` | coach, owner | flag + list |
| 4 | `GET /api/scout/import/status` | `src/scout/scout.controller.ts:146` | coach, owner | flag + list |
| 5 | `POST /api/scout/runs/start` | `src/scout/lifecycle/run.controller.ts:88` | coach, owner | flag + list |
| 6 | `POST /api/scout/runs/cancel` | `src/scout/lifecycle/run.controller.ts:126` | coach, owner | flag + list |
| 7 | `POST /api/scout/runs/declaration` | `src/scout/induction/observation.controller.ts:95` | coach, owner | flag + list |
| 8 | `POST /api/scout/runs/observation` | `src/scout/induction/observation.controller.ts:137` | coach, owner | flag + list |
| 9 | `POST /api/scout/reconstruct` | `src/scout/scout-reconstruct.controller.ts:81` | coach | INGEST + RECONSTRUCT + list |
| 10 | `GET /api/scout/reconstruct/roster` | `src/scout/scout-roster.controller.ts:77` | coach | INGEST + RECONSTRUCT + list |
| 11 | `GET /api/scout/reconstruct/entities` | `src/scout/scout-entities.controller.ts:86` | coach | INGEST + RECONSTRUCT + list |
| 12 | `POST /api/extension/pair/init` | `src/extension-pair/extension-pair.controller.ts:116` | coach, owner (+CoachGuard) | flag + list |
| 13 | `POST /api/extension/pair/status` | `src/extension-pair/extension-pair.controller.ts:167` | coach, owner (+CoachGuard) | flag + list (not in the readiness list, covered by prefix) |
| 14 | `POST /api/extension/pair/session` | `src/extension-pair/extension-pair.controller.ts:212` | coach, owner (+CoachGuard) | flag + list |
| 15 | `POST /api/extension/pair/current` | `src/extension-pair/extension-pair.controller.ts:257` | coach, owner (+CoachGuard) | flag + list |
| — | `POST /api/extension/pair/redeem` | `src/extension-pair/extension-pair.controller.ts:315-316` | `@Public()` | flag only (exempt from the list, by grant); dark on case-variant URL via guard |

Controllers with `@Controller('scout')`: `scout.controller.ts:62`, `scout-ingest.controller.ts:18`, `lifecycle/run.controller.ts:49`, `induction/observation.controller.ts:63`, `scout-reconstruct.controller.ts:14`, `scout-roster.controller.ts:14`, `scout-entities.controller.ts:14`; `@Controller('extension/pair')`: `extension-pair.controller.ts:57`. **S8-D unlink / person-link routes: `rg -n "unlink|FEATURE_PERSON_LINK" src --glob '!*.spec.ts'` → no route (only an fs `unlink` in data-export and a comment in native-writers). Note for D5:** when they land under a new prefix they must be added to `FEATURE_GATED_ROUTES` to inherit this gate; under `/api/scout` they inherit it automatically.

## 3. Files, sha256, LOC

| file | Δ | sha256 |
|---|---|---|
| `src/common/feature-flag/pilot-coach-allowlist.ts` (new) | +135 (69 code) | `48bd0e87dc13d8d2911024c9d936fd387b8c71e9d4626209c6200f64942b7f53` |
| `src/common/feature-flag/pilot-coach-allowlist.guard.ts` (new) | +87 (47 code) | `5175c8042d8ed8d6ecf37589153cac2331887fa9a79df12b7698d15f511884f4` |
| `src/app.module.ts` | +14 (3 code: import, provider, blank; 11 comment) | `5dbf0f17797658e716ab404b57e87a16b295eb7d9c3b663dfdb7c84dbeb92e3f` |
| `.env.example` | +10 | `99111735292045477e769355b9c87e0b8ad8cc1688f1f78d57d809ef4ef4f40c` |
| `prod-switches.yml` | +6 | `9cae3f7372b585453ac7dd334f5ca21b0e935790d0396960a7271735ba4db98c` |
| `docs/decisions/2026-09-26-s12b1-pilot-coach-allowlist.md` (new) | +55 | `07307fedf8a5613b5a8979180358a95ea928fd8f8a82bd651b3db45ce6ccc098` |
| `test/common/pilot-coach-allowlist.spec.ts` (new) | +370 | `4efdf9032956674e344439b03fb553f2f78152dcb08c2732f2ecf540a67dfa27` |
| `test/common/pilot-coach-allowlist.bootstrap.spec.ts` (new) | +546 | `f59e8ae656841d448b65248a49ab7f5a45dcee3f6740a068aca80e2cffe3e769` |

LOC: **prod code ≈ 119 non-blank non-comment lines** (69 + 47 + 3) — inside the grant's ≈80-150; prod files incl. comments 236; **test 916**; registry/docs 71. 8 files, +1223, −0. No existing product line modified except the two insertions in `app.module.ts`. Core diff (S10 sense): no `src/scout/**` or extension-pair byte touched.

## 4. Specs (what is proved)

`test/common/pilot-coach-allowlist.spec.ts` — 20 tests: parser (empty forms; trim/lower/dedupe; 11 junk shapes ⇒ whole list empty; positions only), resolver (per-call env read + memo; one warning per bad value, no entry text, none for good values), matcher (every registry pattern + subpaths + case variants; siblings not gated; reconstruct matches both rows; controller paths incl. arrays), `isFlagDark`, guard with a real `Reflector` (on-list true incl. upper-case id; off-list `NotFoundException` with router-identical body `{statusCode:404, message:"Cannot POST /api/scout/ingest", error:"Not Found"}`; unset/empty/malformed ⇒ 404 incl. owner; no/odd `req.user` ⇒ 404; `@Public` redeem passes, sibling `init` gated; non-importer untouched; controller-path belt when `req.path` is odd/undefined; flag dark on case-variant URL ⇒ 404 for on-list coach and for redeem; `onModuleInit` warns once).

`test/common/pilot-coach-allowlist.bootstrap.spec.ts` — 128 tests over real HTTP (NestFactory, real `JwtAuthGuard`/`UserThrottlerGuard`/`RolesGuard`/`PilotCoachAllowlistGuard` in app.module order, R-DARK-1 middleware as main.ts, `RequestIdMiddleware`, CORS, `HttpExceptionFilter`; stub controllers mount all 15 gated routes + public redeem + one ungated `/api/me/feature-flags`; users pilot coach, other coach, student, owner). Per route ×15: flags OFF ⇒ 404 for pilot/other/owner/anon with list set; flags ON + list unset ⇒ 404 for all four authed; list `""`/`"  "`/`",,"` ⇒ 404; list `PILOT,*` / `true` / `*` / `PILOT;OTHER` / `pilot` ⇒ 404 incl. the pilot beside the junk; list = pilot ⇒ pilot 2xx `{ok:true}`, other/student/owner uniform 404 (not 403), anon 401; padded/upper-case two-id list; `/API/…` variant: off-list 404, on-list 2xx; **flags OFF on `/API/…` variant ⇒ 404 for the on-list pilot** (guard re-asserts the flag). Plus: **off-list 404 ≡ flag-off 404 ≡ unmounted 404** (same-length URL `/api/scout/ingesx`, fixed `X-Request-ID`, allow-listed `Origin`): identical bodies bar `timestamp`, identical header key sets (minus `date`), identical `content-type`/`content-length`/`x-request-id`/`vary`, same CORS echo; student ON list ⇒ 403 (list is not a role bypass); redeem reachable with flag on + empty list, 404 with flag off, 404 on `/API/…redeem` with flag off; ungated route untouched for all callers; list edits honoured without restart (no memo reset). Static pins: stub inventory == real controllers parsed from source (15 gated + exactly one public = redeem; total 16); `app.module.ts` order Jwt → Pilot → Throttler → Roles with nothing between Jwt and Pilot.

**PG lane needs: none.** No spec touches Prisma or a database (Prisma is a stub in the bootstrap harness, as in the existing R-DARK-1 bootstrap spec). No `*.pg.spec.ts`, no `rls-g2-*`, no real-PG lane required for this slice.

## 5. Commands run (all heavy ones under `flock -w 3600 /home/user/workspace/execution/test-validation.lock`, inode 686480, while `execution/fa72efb2/PROOF_SLOT_FREE` existed; `NODE_OPTIONS=--max-old-space-size=3072`, `jest --runInBand`)

| # | command | RC |
|---|---|---|
| 1 | `git clone --no-hardlinks worktrees/fa72-s11d2 worktrees/fa72-s12b1`; `git remote set-url [--push] origin no_push://disabled-fa72efb2`; `git config user.*` Bradley; `git checkout -b fa72/s12b1` | 0 |
| 2 | `cp -al worktrees/fa72-s11a1/node_modules ./node_modules`; `npx lefthook install` (sync hooks: pre-commit, commit-msg) | 0 |
| 3 | `prettier --check` (3.9.9 from runtime/tools) over the 7 touched formatted files — first run flagged the 2 new specs; `--write` then `--check` | 1 → 0 |
| 4 | flock: `npx tsc --noEmit -p tsconfig.json` (first pass) — TS2322 in the unit spec's fake `ExecutionContext.getClass` typing; fixed with `Type<unknown>` | 2 |
| 5 | flock: `jest test/common/pilot-coach-allowlist.spec.ts` | 0 (17/17) |
| 6 | flock: `jest test/common/pilot-coach-allowlist.bootstrap.spec.ts` (first pass) — 1 fail: off-list 404 carried `x-ratelimit-*` headers (guard was after the throttler) → moved guard before `UserThrottlerGuard` | 1 |
| 7 | flock: `jest …bootstrap.spec.ts` + scratch probe spec (deleted afterwards, never staged) — 1 fail: my test compared `content-length` against a longer unmounted URL → same-length `/api/scout/ingesx`; probe output: flags OFF, `POST /API/scout/ingest` on-list coach → **201**, anon → **401**; trailing slash → 404; `//api` → 404 (see F1) | 1 |
| 8 | flock: `jest test/common/pilot-coach-allowlist.spec.ts test/common/pilot-coach-allowlist.bootstrap.spec.ts` | **0 (148/148)** |
| 9 | flock: `eslint --no-warn-ignored --max-warnings 0` (5 ts files) / `tsc --noEmit` / `node scripts/check-r75.js --mode=staged` | **0 / 0 / 0** |
| 10 | flock: `jest test/common/feature-flag-not-found.spec.ts test/common/feature-flag-not-found.bootstrap.spec.ts test/roles-enforced.spec.ts test/deploy-readiness.spec.ts test/prod-readiness test/dunning-v2-lockout-guard.e2e.spec.ts src/extension-pair/__tests__/extension-pair.controller-wiring.spec.ts test/scout/{roster,entities,reconstruct}/*.flag.spec.ts src/scout/scout.controller.spec.ts` | **0 (21 suites, 1028 passed, 1 pre-existing skip)** |
| 11 | `prettier --check` on all committed formatted files (md, yml, ts) | 0 |
| 12 | flock: `git commit -F /tmp/s12b1_commit_msg.txt` → lefthook pre-commit ✔️ prod-readiness-quick, banned-cast-tokens, eslint, prettier, tsc (51.7 s); commit-msg ✔️ no-ai-tokens | **0** → `3bfe24f0` |

Not run (parent-only or out of scope): any real-PG lane, bootstraps, `*.pg.spec.ts`, the importer contract generator (`scripts/importer-contract.ts` — no controller decorator changed, so no regeneration needed), `openapi-spec.spec.ts`, the full jest lane.

## 6. Findings (Safety ROI)

**F1 — R-DARK-1 middleware compares `req.path` case-sensitively while express routes case-insensitively. CLASS B.** Reproduced (command 7): with all flags `false`, `POST /API/scout/ingest` from an authenticated coach reaches the handler (201) and from anon returns 401 — not the uniform 404. CONCRETE HARM: (a) kill switch §3.2 #2 ("set the flag to anything but `'true'`, every gated route answers 404") is bypassable by URL casing for any authenticated coach today; (b) R-DARK-1 existence leak (401 ≠ 404). EXACT DECISION BLOCKED: owner item 4 (production flags) relies on that kill switch. MINIMUM CLOSURE: the guard in this slice already re-asserts the matched flags case-insensitively (`isFlagDark`, proved per route incl. redeem), so **after S12-B1 lands, flag-off is 404 for every spelling on the whole gated surface** — the harm is closed in product behaviour. The root cause remains in landed bytes: a one-line change in `feature-flag-not-found.middleware.ts` L38 (`const path = req.path.toLowerCase();` plus lower-casing the pattern compare) and a probe in `feature-flag-not-found.bootstrap.spec.ts`. I did NOT edit the middleware (accepted landed bytes; not in my grant) — parent's call whether to fold it into this landing or a follow-up. EXECUTION UNLOCKED: the pilot kill switch holds however the URL is spelled; the guard's belt makes the middleware fix non-urgent but still worth doing so there is one source of truth.

**F2 — the off-list 404 and the flag-off 404 initially differed by `X-RateLimit-*` headers. CLASS B, closed in this build.** Guard now runs before `UserThrottlerGuard`; header-set identity with both the flag-off 404 and a genuine unmounted 404 is asserted over HTTP. Residual: `X-Powered-By`/`ETag` appear on all three (express defaults), so no signal.

**F3 — off-list probes are not per-user throttled. CLASS C.** Same posture as flag-off and unmounted 404s. Cost per probe = JWT verify (local JWKS) + one `user.findUnique`, which every authenticated request already pays before the throttler runs; no new amplification. Recorded; continue.

**F4 — timing. CLASS C.** Off-list vs on-list differ only by a Set lookup then throw-vs-continue; flag-off (middleware, pre-auth) vs off-list (post-auth) differ by the auth cost, exactly as the already-accepted 401-under-flag-on does. No new oracle.

**F5 — `prod_default: STUB_ALLOWED` rather than `OFF`. CLASS C.** Chosen so the auto-flipper never targets the literal `'false'` for an id list and the readiness report does not WARN on every deploy once the owner sets a value. Mirrors `FEATURE_COMMUNITY_API_ALLOWLIST` (optional/STUB_ALLOWED) but with `tier: feature`/`owner: importer`.

**F6 — `redeem` stays reachable with flag on regardless of the list. CLASS C (by grant).** A 6-digit code exists only if the gated `init` minted it for an on-list coach; the per-IP redeem throttle is unchanged.

**F7 — `owner` role is subject to the list. CLASS C (design).** "Exactly one coach" means Bradley's owner account must also be listed to use the surface; documented in guard, ADR and `.env.example`.

**F8 — `POST extension/pair/status` is gated although the readiness list names only init|session|current. CLASS C.** Prefix coverage; it is coach-authenticated and pairing-internal, so gating it is the fail-closed choice.

## 7. Open risks / for the reviewer

1. F1 root fix location (middleware) — decision for the parent; the guard's belt is proved but is a second implementation of the `=== 'true'` check derived from the same registry.
2. The guard imports `PATH_METADATA` from `@nestjs/common/constants` (a deep import already used by `src/scout/scout.controller.spec.ts`); if Nest ever moves it, tsc fails loudly rather than the gate silently widening.
3. Any future importer route outside `/api/scout` or `/api/extension/pair` (S8-D D5 unlink, person-link) needs a `FEATURE_GATED_ROUTES` row to inherit both gates — the static inventory test in the bootstrap spec will also fail if a new scout/extension-pair route appears without a stub, which is the intended reminder.
4. S12-B6 must add `FEATURE_SCOUT_PILOT_COACH_IDS` to `fly-feature-flags-set.yml` (not done here, per grant).
5. The deploy-readiness R108 discovery accepted the row; I did not run the full jest lane — parent proof binding.

---

# Round 2 — review B1 closure (parent mail, scope extended to the landed R-DARK-1 matcher)

Trigger: `s12b1/s12b1_review.md` B1 — the pilot guard runs after `JwtAuthGuard`, so with a flag off a **case-variant** URL (`/API/scout/ingest`) still produced 401 for anonymous callers (JwtAuthGuard) and 204 for CORS preflights (`enableCors` runs before any guard) instead of the uniform 404, because the pre-auth `featureFlagNotFoundMiddleware` compared `req.path` case-sensitively while express routes case-insensitively. Round-1 F1 root cause; the guard's `isFlagDark` belt could never reach those two paths.

## R2.0 Identity

| item | value |
|---|---|
| **head** | **`f48395dfa57f180ae4bd60fb75d592b387c3c4c5`** (new commit on `fa72/s12b1`, parent `3bfe24f0`; no amend, no rebase) |
| **tree** | **`8b13811ecc677653a631538075d65fd0fff69028`** |
| author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` / same; trailer scan (`co-auth\|generated\|claude\|gpt`) → no match |
| hooks | lefthook pre-commit ✔️ prod-readiness-quick, banned-cast-tokens, eslint, prettier, tsc (48.3 s); commit-msg ✔️ no-ai-tokens; no `--no-verify` |
| working tree | clean after commit; origin still `no_push://disabled-fa72efb2`; nothing pushed; no PG; no production/workflow change |
| commit message | `/tmp/s12b1_r2_commit_msg.txt` (`fix(feature-flag): R-DARK-1 matcher is case-insensitive, closing the pre-auth case-variant gap`) |

## R2.1 Diff summary (`git diff --numstat 3bfe24f0 f48395df`: 3 files, +219 −2)

| file | Δ | sha256 (post) |
|---|---|---|
| `src/common/feature-flag/feature-flag-not-found.middleware.ts` | +8 −2 (**2 code lines changed**, rest doc comment) | `fd9623e5f4436809f66f471be18acdd8e23c94763425d7287cc54a877896ce4f` |
| `test/common/feature-flag-not-found.spec.ts` (landed middleware unit spec) | +33 | `f91f045c9e837f14aecd15c955a193e691991d048d77d7db1810d74e75b0cb2a` |
| `test/common/pilot-coach-allowlist.bootstrap.spec.ts` | +178 | `43971b6d775b14de5fb408e4ee58febb0cb8578285ba832f5d455e277ebf8b70` |

Product change (smallest possible), `feature-flag-not-found.middleware.ts` L43-46:
```
-  const path = req.path;
+  const path = req.path.toLowerCase();
   for (const route of FEATURE_GATED_ROUTES) {
-    if (path === route.pattern || path.startsWith(route.pattern + '/')) {
+    const pattern = route.pattern.toLowerCase();
+    if (path === pattern || path.startsWith(pattern + '/')) {
```
Segment boundary (`+ '/'`) and the layered reconstruct row (INGEST + RECONSTRUCT both required) are unchanged; the 404 envelope (`buildNotFoundEnvelope`) still echoes the caller's original `req.originalUrl`/method, so the body is byte-shaped like Nest's router 404 for the spelling actually requested. Guard, allowlist, registry rows, `app.module.ts`, controllers, `docs/contracts/**`, workflows: untouched in round 2. The round-1 guard belt (`isFlagDark`) stays as defence in depth; the middleware is now the single pre-auth source of truth.

## R2.2 Tests added

`test/common/feature-flag-not-found.spec.ts` L56 — one unit case: `/API/scout/ingest`, `/api/SCOUT`, `/Api/Scout/Reconstruct/roster` ⇒ 404 with flag off and `next` not called; layered `/api/SCOUT/Reconstruct` dark when only RECONSTRUCT is off; siblings `/API/scouting`, `/api/SCOUT-x`, `/API/extension/pairing` ⇒ pass through (segment boundaries survive the fold).

`test/common/pilot-coach-allowlist.bootstrap.spec.ts` L489-… — `CASE_VARIANTS` × 4 (FEATURE_SCOUT_INGEST `POST /API/scout/ingest`; FEATURE_SCOUT_RECONSTRUCT layered `POST /api/SCOUT/Reconstruct` with INGEST on; RECONSTRUCT `GET /API/scout/reconstruct/ROSTER`; FEATURE_EXTENSION_PAIRING `POST /api/Extension/PAIR/init`), each over real HTTP with the production guard chain, R-DARK-1 middleware, RequestId, CORS and filter:
1. flag OFF, **anonymous** ⇒ uniform 404; body bar `timestamp` and header key-set identical to a genuinely unmounted, equal-length URL **outside** every gated prefix (`/API/scoux/ingest` etc. — Nest's own router 404 through the filter), plus equal `content-type`/`content-length`/`x-request-id`/`vary` and the allow-listed CORS echo;
2. flag OFF, **malformed bearer** (`Bearer not-a-real-token`, `Bearer `, `Basic abc`) ⇒ 404, never 401;
3. flag OFF, on-list and off-list coaches ⇒ 404 on the variant spelling;
4. flag OFF, **OPTIONS preflight** with allowed origin ⇒ 404 with CORS echo, never 204; body (bar timestamp) and header set identical to the dark preflight on the canonical spelling;
5. flag ON ⇒ anonymous 401, preflight 204 with origin echo, pilot 2xx, other coach uniform 404 (allowlist behaviour unchanged).
Plus: flag OFF `POST`/`OPTIONS /API/extension/pair/REDEEM` (public route) ⇒ 404 pre-auth, 201 once the flag is on; `/API/scouting` stays an ordinary 404 and the ungated `/API/me/feature-flags` still 401s (fold does not widen the gate).

Note recorded while writing the test: an **unmounted** route under a **lit** prefix (or outside every prefix) answers OPTIONS with 204 from the cors package — that is landed, accepted behaviour (the existing `feature-flag-not-found.bootstrap.spec.ts` asserts dark-OPTIONS 404 vs lit-OPTIONS 204), so the preflight identity reference is the canonical dark spelling, not an unmounted URL. Both references are stated in the test comments.

## R2.3 Commands + RC (all heavy ones under `flock -w 3600 /home/user/workspace/execution/test-validation.lock` while `PROOF_SLOT_FREE` existed; `NODE_OPTIONS=--max-old-space-size=3072`, `jest --runInBand`)

| # | command | RC |
|---|---|---|
| R1 | read `s12b1_review.md` B1; `git status` clean at `3bfe24f0` | 0 |
| R2 | python in-place edit of middleware + two specs; `prettier --write` (3.9.9 runtime tool) on the 3 files; local `rg` for R75 tokens (`as unknown as\|as any\|as never`) → none | 0 |
| R3 | flock: `jest feature-flag-not-found.spec feature-flag-not-found.bootstrap.spec pilot-coach-allowlist.spec pilot-coach-allowlist.bootstrap.spec` — 1 fail: my OPTIONS reference used an unmounted path under a lit prefix (204 from cors) | 1 |
| R4 | edit references (unmounted → outside gated prefixes, equal length; OPTIONS → canonical dark spelling); prettier; flock jest — 4 fails: my preflight requests lacked a fixed `x-request-id`, so `request_id` differed | 1 |
| R5 | add `x-request-id` to `preflight()`; `prettier --check` 3 files → clean; flock jest same 4 suites | **0 (207/207)** |
| R6 | flock: `eslint --no-warn-ignored --max-warnings 0` (3 files) / `tsc --noEmit -p tsconfig.json` / `git add` 3 files + `node scripts/check-r75.js --mode=staged` ("OK — no positive token change") | **0 / 0 / 0** |
| R7 | flock: `jest test/roles-enforced.spec.ts test/deploy-readiness.spec.ts test/prod-readiness test/dunning-v2-lockout-guard.e2e.spec.ts src/extension-pair/__tests__/extension-pair.controller-wiring.spec.ts test/scout src/scout/scout.controller.spec.ts` | **0 (85 suites passed, 6 skipped; 2644 tests passed, 47 pre-existing skips)** |
| R8 | flock: `git commit -F /tmp/s12b1_r2_commit_msg.txt` → hooks all ✔️ → `f48395df` | **0** |
| R9 | `git log -2`, `git status --short` (0 lines), trailer scan, `git diff --numstat HEAD~1 HEAD`, `sha256sum` | 0 |

Not run: real-PG lanes / `*.pg.spec.ts` / `rls-g2-*` (parent-only; nothing in round 2 touches Prisma), full jest lane, importer contract generator (no controller change).

## R2.4 Findings status after round 2

- **Review B1 / round-1 F1 — CLOSED in bytes and proved over HTTP.** Case-variant URLs on all three flag families are dark pre-auth for anonymous callers, malformed bearers, authenticated on/off-list coaches and CORS preflights, with the same 404 envelope and header set as the accepted flag-off contract. EXECUTION UNLOCKED: the §3.2 kill switch is uniform for every caller/method/spelling on the importer surface; owner items 4/6 may rely on it; S12-B1 acceptable as a fail-closed dark-surface boundary subject to the parent's independent re-review.
- Round-1 F2–F8: unchanged (C, or B closed in round 1).
- New C: `isFlagDark` in the guard is now redundant for correctly-spelled and case-variant paths alike; kept deliberately as a second layer (registry-derived, no separate config) — reviewer may prefer removing it in a later slice for single-source clarity. Not removed here to keep round 2 to the minimum closure.
- Residual accepted behaviour (not a finding of this slice): preflight on an unmounted path under a lit prefix is 204 from `enableCors` — identical to any other unmounted path in the app, and independent of the importer gate.
