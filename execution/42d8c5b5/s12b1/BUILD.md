# S12-B1 pilot-coach allowlist — rebuild report (EXEC-42D8C5B5, T4 builder claude_fable_5)

Grant: `execution/42d8c5b5/s12b1/GRANT.md`. Rules: `execution/42d8c5b5/WORKER_RULES.md`.
Design source (predecessor bytes `3bfe24f0 → f48395df` LOST): `execution/fa72efb2/s12b1/{S12B1_BUILD_GRANT.md,s12b1_build.md,s12b1_review.md}` (round-2 review verdict GO), `s12/S12_PILOT_READINESS.md` §2b S12-B1, §3.1, §3.2.

## 0. Identity

| item | value |
|---|---|
| clone | `/home/user/workspace/worktrees/x42-s12b1` — standalone `git clone --no-hardlinks /home/user/workspace/repos/backend` (no `git worktree add`) |
| origin | fetch `/home/user/workspace/repos/backend`, push `no_push://disabled` |
| preserve | `https://github.com/BradleyGleavePortfolio/growth-project-backend.git` |
| base | `54be96f18c314cae35d1e5d3000af9f06d693d81` (`origin/integration/importer`, "test(scout): S11-A2 r2 reset the S10-B tables only by cascade") |
| branch | `x42/s12b1` |
| **head** | **`c9ccb2c9a2dda063e357c9aa8af97ae7f87367ae`** (ONE commit, parent `54be96f1`) |
| **tree** | **`31afe6cac1009046bd854c42478c06c23ab33727`** |
| **pushed** | **`refs/heads/cand/x42/s12b1` = `c9ccb2c9a2dda063e357c9aa8af97ae7f87367ae`** (`git push preserve HEAD:refs/heads/cand/x42/s12b1`, RC 0, `[new branch]`; verified with `git ls-remote`). No other remote write. |
| author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` / same. Trailer scan `rg -i "co-auth\|generated\|claude\|gpt\|anthropic"` on the message → no match |
| hooks | lefthook pre-commit ✔️ prod-readiness-quick, banned-cast-tokens (R75 "OK — no positive token change"), prettier, eslint, tsc (49.05 s); commit-msg ✔️ no-ai-tokens. No `--no-verify`. |
| working tree after commit | clean (`git status --short` → 0 lines) |
| node_modules | `cp -al worktrees/x42-donor/node_modules` after `rt-setup.sentinel` read `RC=0`; `./node_modules/.bin/lefthook install`. No npm install/ci, no prisma generate. Prettier 3.9.9 from `runtime/tools` via `npm_config_prefix`. |
| PostgreSQL / workflows / fly / flags / deploy | none touched, none run. `fly-feature-flags-set.yml` unchanged (S12-B6). No `docs/contracts/**` change (no controller decorator touched; generator not run). Evidence repo not committed. |

## 1. What was rebuilt (equals the reviewed-GO design, round 1 + round 2 in one commit)

**Variable** `FEATURE_SCOUT_PILOT_COACH_IDS` — comma-separated `User.id` UUIDs.

**Parser / resolver / matcher** `src/common/feature-flag/pilot-coach-allowlist.ts` (pure, never throws): trim, drop empties, canonical hyphenated UUID only (case-insensitive, stored lower-cased, de-duplicated); **any junk entry ⇒ whole list empty** (`rejectedPositions` = 1-based positions among non-empty entries). `resolvePilotCoachAllowlist(warn?)` reads env per call, memoises on the raw string, warns once per distinct malformed value naming positions only. `matchedGatedRoutes(path)` = `FEATURE_GATED_ROUTES` rows prefixing the lower-cased path segment-wise; `matchedGatedRoutesForController(@Controller path)` under `/api`; `unionGatedRoutes`; `isFlagDark(routes)` = any matched flag `!== 'true'`.

**Guard** `src/common/feature-flag/pilot-coach-allowlist.guard.ts` (global `APP_GUARD`, `OnModuleInit` boot warning): not gated ⇒ pass; gated + flag dark ⇒ `NotFoundException("Cannot <METHOD> <url>")` before the `@Public()` exemption; `@Public()` ⇒ pass (only `redeem`); `req.user.id` string, lower-cased ∈ list ⇒ pass; else the same 404. No owner bypass.

**Wiring** `src/app.module.ts`: `JwtAuthGuard` → **`PilotCoachAllowlistGuard`** → `UserThrottlerGuard` → `RolesGuard` → `DunningLockoutGuard` (import + provider + comment; 3 code lines).

**Round-2 closure (review B1)** `src/common/feature-flag/feature-flag-not-found.middleware.ts`: `const path = req.path.toLowerCase();` + `const pattern = route.pattern.toLowerCase();` in the compare (2 code lines changed, rest doc comment). Segment boundary and layered reconstruct row unchanged; envelope still echoes the caller's spelling.

**Registry** `.env.example` (documented, `FEATURE_SCOUT_PILOT_COACH_IDS=` empty default), `prod-switches.yml` (`tier: feature`, `prod_default: STUB_ALLOWED`, `auto_flip_on_in_prod: false`, `owner: importer`). **ADR** `docs/decisions/2026-09-26-s12b1-pilot-coach-allowlist.md`.

## 2. Route inventory (re-verified with `rg` against controllers at base 54be96f1; identical to the reviewed design; pinned by the static test)

`FEATURE_GATED_ROUTES`: `/api/scout` (INGEST), `/api/scout/reconstruct` (RECONSTRUCT, layered), `/api/extension/pair` (PAIRING).

| # | route | file:line | gate |
|---|---|---|---|
| 1 | `POST /api/scout/progress` | `src/scout/scout.controller.ts:77` | flag + list |
| 2 | `POST /api/scout/ingest` | `src/scout/scout-ingest.controller.ts:86` | flag + list |
| 3 | `POST /api/scout/ingest/complete` | `src/scout/scout.controller.ts:110` | flag + list |
| 4 | `GET /api/scout/import/status` | `src/scout/scout.controller.ts:146` | flag + list |
| 5 | `POST /api/scout/runs/start` | `src/scout/lifecycle/run.controller.ts:88` | flag + list |
| 6 | `POST /api/scout/runs/cancel` | `src/scout/lifecycle/run.controller.ts:126` | flag + list |
| 7 | `POST /api/scout/runs/declaration` | `src/scout/induction/observation.controller.ts:95` | flag + list |
| 8 | `POST /api/scout/runs/observation` | `src/scout/induction/observation.controller.ts:137` | flag + list |
| 9 | `POST /api/scout/reconstruct` | `src/scout/scout-reconstruct.controller.ts:81` | INGEST + RECONSTRUCT + list |
| 10 | `GET /api/scout/reconstruct/roster` | `src/scout/scout-roster.controller.ts:77` | INGEST + RECONSTRUCT + list |
| 11 | `GET /api/scout/reconstruct/entities` | `src/scout/scout-entities.controller.ts:86` | INGEST + RECONSTRUCT + list |
| 12-15 | `POST /api/extension/pair/{init,status,session,current}` | `src/extension-pair/extension-pair.controller.ts:116,167,212,257` | flag + list |
| — | `POST /api/extension/pair/redeem` | `extension-pair.controller.ts:315-316` `@Public()` | flag only |

S8-D unlink / person-link routes: `rg -n "unlink|FEATURE_PERSON_LINK" src --glob '!*.spec.ts'` → no route (fs `unlink` in data-export, comments only). Note for D5 unchanged.

## 3. Files, sha256, LOC (`git diff --numstat 54be96f1 c9ccb2c9`: 10 files, +1616 −2)

| file | Δ | sha256 |
|---|---|---|
| `src/common/feature-flag/pilot-coach-allowlist.ts` (new) | +149 (78 code) | `174e6709abcc72a54250f82ae7855e2f04cff8079ed349e159e66719763be7c7` |
| `src/common/feature-flag/pilot-coach-allowlist.guard.ts` (new) | +96 (54 code) | `9618f51b9a8ac50a60cd3b7cfab7165f80cb2b53537d9a0d6b76dfdf050a03ac` |
| `src/app.module.ts` | +13 (3 code) | `0cb27871da17d53a24bd57f72973696c8aebb056fffcbe328e02774f4946ad18` |
| `src/common/feature-flag/feature-flag-not-found.middleware.ts` | +9 −2 (2 code lines changed) | `32ec142bbeb623b6e550e4dd8f416b2f50910fd75b1ed7fc860dc207dabe8500` |
| `.env.example` | +10 | `5a87a87eb2adeed7ad1e33832677522230bf9303a04b4c3ad37594b91c39b52e` |
| `prod-switches.yml` | +6 | `297c171212634dbff8939f0d9012f7137ca7fc3d3e1375e3453a565b31889d38` |
| `docs/decisions/2026-09-26-s12b1-pilot-coach-allowlist.md` (new) | +61 | `c081be1dd01d779fb7b3e2ec83fe1da00884d6e29929541b81846f59d797d7f1` |
| `test/common/pilot-coach-allowlist.spec.ts` (new) | +422 | `09c94e44253dfb0b1692815d84479cef9979c3d131bdfce86a0fd3c13a360312` |
| `test/common/pilot-coach-allowlist.bootstrap.spec.ts` (new) | +807 | `c9e8b0d4d1931749e4f4c272badc6b6c0c8046819a62996f495ad7bf450ad93c` |
| `test/common/feature-flag-not-found.spec.ts` | +43 | `4787a54f625105e92ece150fed933ab7d3dd106c885856fbf25b392f52e475f1` |

**LOC: prod code ≈ 137 non-blank non-comment lines** (78 + 54 + 3 + 2 changed) — inside the grant's ≈80-150; prod files incl. comments 267 added; **test +1272**; registry/docs +77. No `src/scout/**` or extension-pair byte touched (CORE DIFF = 0; no platform slug/token literal).

## 4. Specs (296 tests in the two new suites, 15 in the middleware unit spec)

`pilot-coach-allowlist.spec.ts` (46): parser (6 empty forms; trim/lower/dedupe; 11 junk shapes ⇒ whole list empty; positions only), resolver (per-call env read; one warning per distinct bad value, no entry text, none for good), matcher (every registry pattern + subpaths + case variants; siblings not gated; layered reconstruct; controller paths string/array/slashes; union dedupe; `isFlagDark`), guard with a real `Reflector` and real decorated stubs (on-list incl. upper-case id; off-list ⇒ `NotFoundException` with router-identical body `{statusCode:404,message:"Cannot POST /api/scout/ingest",error:"Not Found"}`; unset/empty/whitespace/malformed ⇒ 404 incl. owner; 6 odd `req.user` shapes ⇒ 404; `@Public` redeem passes, sibling init gated; non-importer untouched; controller-path belt with `req.path` undefined/odd; flag dark on case-variant URL ⇒ 404 for on-list coach and redeem; layered reconstruct; `onModuleInit` warns once).

`pilot-coach-allowlist.bootstrap.spec.ts` (250) — real HTTP: `NestFactory`, real `JwtAuthGuard`/`PilotCoachAllowlistGuard`/`UserThrottlerGuard`/`RolesGuard` in app.module order, R-DARK-1 middleware as main.ts, `RequestIdMiddleware`, CORS, `HttpExceptionFilter`; stubs mount all 15 gated routes (same `@Roles`) + public redeem + ungated `/api/me/feature-flags`; users pilot/other coach/student/owner. Per route ×15: flags OFF ⇒ 404 for pilot/other/owner/anon with list set; flags ON + list unset ⇒ 404 for all four; `""`/`"  "`/`",,"` ⇒ 404; 6 malformed lists ⇒ 404 for pilot and owner; list = pilot ⇒ pilot 2xx `{ok:true}`, other/student/owner uniform 404 (never 403), anon 401; padded upper-case two-id list admits both; `/API/…` variant on/off-list and flags-OFF. Plus: layered reconstruct over HTTP; **off-list 404 ≡ flag-off 404 ≡ unmounted 404** (`/api/scout/ingesx`, fixed `X-Request-ID`, allow-listed `Origin`: bodies bar timestamp, header key sets minus `date`, `content-type/length`, `x-request-id`, `vary`, CORS echo; no `x-ratelimit-*`); student ON list ⇒ 403; owner ON list admitted; redeem reachable flag-on regardless of list, 404 flag-off incl. `/API/…/REDEEM`; ungated route untouched for 5 list states; list edits honoured without restart. **Round 2** `CASE_VARIANTS`×4 (INGEST `POST /API/scout/ingest`, layered `POST /api/SCOUT/Reconstruct`, `GET /API/scout/reconstruct/ROSTER`, PAIRING `POST /api/Extension/PAIR/init`): flag OFF anonymous ⇒ 404 identical to an equal-length unmounted URL outside every gated prefix; malformed bearers ×3 ⇒ 404 never 401; on/off-list ⇒ 404; OPTIONS preflight ⇒ 404 with CORS echo, same shape as the canonical dark preflight; flag ON ⇒ 401/204/2xx/404 unchanged. Case-variant public redeem POST/OPTIONS 404 pre-auth, 201 once on; `/API/scouting` ordinary 404, ungated still 401. Static pins: stub inventory == real controllers parsed from source (15 gated + exactly one public = redeem, 16 total); `app.module.ts` guard order `Jwt → Pilot → Throttler → Roles → Dunning`; registry rows present.

`feature-flag-not-found.spec.ts` +1 case: 4 case-variant spellings ⇒ 404 with the caller's spelling echoed, layered reconstruct dark, 3 siblings pass through.

**PG lane needs: none.** No spec touches Prisma or a database (Prisma is a stub). No `*.pg.spec.ts`, no `rls-g2-*`.

## 5. Commands + RC (heavy ones under `flock -w 3600 /home/user/workspace/execution/test-validation.lock` inode 657581; `NODE_OPTIONS=--max-old-space-size=3072`; `jest --runInBand`; launched with `nohup setsid`)

| # | command | RC |
|---|---|---|
| 1 | `git clone --no-hardlinks repos/backend worktrees/x42-s12b1`; `remote set-url --push origin no_push://disabled`; `remote add preserve …`; Bradley `user.*`; `checkout -b x42/s12b1 54be96f1` | 0 |
| 2 | sentinel `RC=0` → `cp -al x42-donor/node_modules`; `./node_modules/.bin/lefthook install` | 0 |
| 3 | `prettier --check` (3.9.9) 9 touched formatted files — 2 new specs flagged → `--write` → `--check` | 1 → 0 |
| 4 | flock: `eslint --no-warn-ignored --max-warnings 0` (7 ts files) | **0** |
| 5 | flock: `tsc --noEmit -p tsconfig.json` (first pass) — TS2322 `getClass: () => Type<unknown>` in the unit spec's fake ExecutionContext → `Type` (=`Type<any>`) | 2 |
| 6 | flock: `jest test/common/pilot-coach-allowlist.spec.ts test/common/feature-flag-not-found.spec.ts` (same pass) — allowlist suite failed to compile (same TS2322); middleware spec 14/14 | 1 |
| 7 | flock: `tsc --noEmit -p tsconfig.json` | **0** |
| 8 | flock: `jest test/common/pilot-coach-allowlist.spec.ts test/common/pilot-coach-allowlist.bootstrap.spec.ts` | **0 (2 suites, 296/296)** |
| 9 | `git add` 10 files; `node scripts/check-r75.js --mode=staged` → "OK — no positive token change"; `rg "as unknown as\|as any\|as never"` over new files → none | 0 |
| 10 | flock: `jest --testPathIgnorePatterns '\.pg\.spec\.ts$' rls-g2 -- test/common/feature-flag-not-found.spec.ts test/common/feature-flag-not-found.bootstrap.spec.ts test/roles-enforced.spec.ts test/deploy-readiness.spec.ts test/prod-readiness test/dunning-v2-lockout-guard.e2e.spec.ts src/extension-pair/__tests__/extension-pair.controller-wiring.spec.ts test/scout/{entities,reconstruct,roster}/*.flag.spec.ts test/scout/scout-ingest.controller.spec.ts src/scout/scout.controller.spec.ts` | **0 (22 suites, 1059 passed, 1 pre-existing skip)**; console `[GAP] SMTP_PASS` is pre-existing, unrelated |
| 11 | flock: `git commit -F /tmp/s12b1_commit_msg.txt` → hooks ✔️ (tsc 49.05 s) → `c9ccb2c9` | **0** |
| 12 | `git push preserve HEAD:refs/heads/cand/x42/s12b1` (api_credentials github); `git ls-remote preserve refs/heads/cand/x42/s12b1` → `c9ccb2c9` | **0** |
| 13 | flock: `jest src/extension-pair/__tests__/durable-session.spec.ts` (the one further suite that imports the folded middleware, found by `rg -l` after the commit; run post-commit, no byte changed) | **0 (19/19)** |

Lock waits: ~15 min (parent `rls-g2-s11` PG lane + other workers' queued gates) before #4, ~10 min before #11. Not run (parent-only / out of scope): real-PG lanes, `*.pg.spec.ts`, `rls-g2-*`, the full jest lane, the whole `test/scout` tree (predecessor's R7 ran it; I ran the flag specs + ingest controller spec, see deviation D5), importer contract generator (no controller decorator changed).

## 6. Deviations from the reviewed design (each is C unless stated)

- **D1** ONE commit carries round 1 + round 2 (the reviewed candidate had two: `3bfe24f0` guard, `f48395df` middleware fold). Same end state; nothing to bisect between them since the round-1 state was NO-GO.
- **D2** `pilot-coach-allowlist.ts` additionally exports `unionGatedRoutes` (dedupe helper used by the guard; the predecessor inlined it). `rejectedPositions` are 1-based among non-empty entries (the design said "positions only" without fixing the base).
- **D3** Guard reads the controller path via `this.reflector.get(PATH_METADATA, context.getClass())` instead of `Reflect.getMetadata`; same deep import `@nestjs/common/constants` (already used by `src/scout/scout.controller.spec.ts`).
- **D4** Test count differs (296 vs 207 + 148 in the reviewed rounds) because the per-route matrices are parameterised differently; the proof matrix is a superset: adds owner-ON-list admitted, layered reconstruct over HTTP, 6 odd `req.user` shapes, registry static pin. Preflight identity compares `message` case-insensitively (the variant and canonical spellings legitimately differ in case) plus key sets, `request_id`, `content-length`.
- **D5 (B-adjacent, recorded)** Affected-suite gate ran the three `*.flag.spec.ts` + `scout-ingest.controller.spec.ts` from `test/scout` rather than the whole tree (the predecessor's R7: 85 suites) to keep the shared lock short while a PG lane and three other workers were queued. `rg -l "pilot-coach-allowlist|feature-flag-not-found" test src` → every importing spec is covered: the four suites in #8/#10 plus `src/extension-pair/__tests__/durable-session.spec.ts` (#13, run after the commit); the remaining hits are comments in controllers and `src/main.ts`, so the omitted `test/scout` suites cannot observe this change. The parent's proof binding (full lane) is the backstop.
- **D6** Prod-switches description wording is new (predecessor's exact text lost); fields identical (`feature` / `STUB_ALLOWED` / `false` / `importer`). `.env.example` block wording is new; contract identical.
- **D7** The guard's `isFlagDark` belt is kept exactly as in the reviewed round 2 (reviewer's residual C: redundant for correctly-spelled and case-variant paths; intentionally not removed).

## 7. Findings (Safety ROI) and A/B risks

- **No A finding.**
- **B (closed here, from the reviewed design):** review B1 / round-1 F1 — case-variant pre-auth gap — closed by the middleware fold and proved over HTTP for anonymous, malformed-bearer, on/off-list and OPTIONS callers on all three flag families (#8). Round-1 F2 (rate-limit header fingerprint) closed by guard order, proved by header-set identity (#8).
- **C1** Off-list probes are not per-user throttled (guard before throttler) — same posture as flag-off and unmounted 404s; cost = JWT verify + one `user.findUnique`, already paid before the throttler today.
- **C2** Timing: off-list vs on-list differ by a Set lookup; flag-off (pre-auth) vs off-list (post-auth) differ by auth cost, exactly as the accepted 401-under-flag-on. No timing assertion; no new oracle.
- **C3** `prod_default: STUB_ALLOWED` rather than `OFF` (list, not boolean; auto-flipper skips it). R108 discovery green (#10).
- **C4** `redeem` reachable with pairing on regardless of the list (by grant); `POST extension/pair/status` gated by prefix although not in the readiness list (fail-closed choice); owner role subject to the list.
- **C5** Future importer routes outside the two prefixes (S8-D D5 unlink, person-link) need a `FEATURE_GATED_ROUTES` row; the static inventory test fails on any new scout/extension-pair route without a stub (intended reminder). S12-B6 must add `FEATURE_SCOUT_PILOT_COACH_IDS` to `fly-feature-flags-set.yml`.
- **Risk for the parent:** independent re-review is the T4 acceptance path; I did not run the full jest lane (parent proof binding). Deep import `PATH_METADATA` fails loudly in tsc if Nest ever moves it (never widens the gate silently).
