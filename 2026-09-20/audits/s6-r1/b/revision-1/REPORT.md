# S6 independent audit B — round 1 (T4R1)

**Auditor:** independent auditor B (Claude Fable 5, High requested; actual reasoning setting not exposed, not claimed).
**Written:** 2026-09-20 10:15 PDT. Private report; peer report A not read; builder not contacted.

## 1. Identity of the frozen candidate

| Item | Value |
|---|---|
| Worktree (read-only) | `worktrees/audit-s6-r1` |
| Head | `27b48f64b1dc8df139310941e6a6d7676ce587e6` |
| Tree | `beb21b5b09297810563b2379148cb49034932ee7` (verified `git cat-file -p HEAD`) |
| Base (mobile main) | `a5933fd6de5616493de75f0db907098b149b955c` |
| Lineage | a5933fd → 4be69b9 → ed0342e → d2f0d31 → 3408867 (#292 head); #289 tail 8f0b584, ba3fd40, 2235498; merge 3e9249f; 27b48f6 |
| Cumulative diff vs base | 31 files, +2688 / −45 |
| Author/committer | single identity on all candidate commits |

**Changed-head notice.** The builder worktree `worktrees/s6-mobile` has since advanced to `4dcc16496b67792f45cd428d4770c405e707319b` ("declare @babel/core devDep for the inlining guard; fix comment false-positive"). That commit is **outside** this snapshot and is **not attested** here. Findings S6-B-1 and S6-B-2 below are stated against 27b48f6; any later head needs explicit, risk-scoped re-applicability and closure, not inherited approval. (Observation only, not a verdict on 4dcc164: its regex fix `/(?<!`)process\.env\[/` excludes template literals, not comments; a comment-stripping or AST check would be the robust form.)

## 2. Scope reviewed / not reviewed

Reviewed (source read, cumulative diff a5933fd..27b48f6):
- `src/config/featureFlags.ts`, `src/config/aiGatewayFlags.ts`, `src/config/__tests__/featureFlagsReleaseInlining.test.ts`, `src/config/__tests__/importFlags.test.ts`, `src/config/__tests__/declaredDependencies.test.ts` (preserved #289 guard)
- `src/hooks/useExtensionPairing.ts`, `src/hooks/useReconstructCounts.ts`, `src/hooks/useCurrentUser.ts`, `src/lib/userCache.ts`
- `src/storage/importPairingMirror.ts`, `src/services/authActions.ts` (sign-out sweep)
- `src/api/extensionPairApi.ts`, `src/api/api.ts` (request-id interceptor, 401 refresh path)
- `src/components/coach/ExtensionPairingPanel.tsx`, `src/screens/coach/ImportDataScreen.tsx`, `src/navigation/CoachNavigator.tsx` (mount site)
- Tests: `useExtensionPairing.test.tsx`, `importPairingMirror.test.ts`, `authActions.test.ts`, `ExtensionPairingPanel.a11y.test.tsx`, `importFlags.test.ts`
- `.env.example`, `package.json`, `.github/workflows/ci.yml` (`npm install` → `npm ci`)
- Backend contract (read-only, `repos/backend` @ c23b9d9): `src/extension-pair/extension-pair.controller.ts`, `src/observability/request-id.middleware.ts`
- Builder evidence: `execution/s6-mobile/REPORT.md`, `execution/s6-mobile/logs/*`

Not reviewed / not executed: full Jest run, `tsc --noEmit`, `expo export` release bundle, lint, `validate:config`; iOS/Android device behaviour; `docs/importer/MOBILE_IMPORT_DECISION.md` and README wording only skimmed via diff stat.

Actions actually taken by me: git inspection and file reads only, plus two tiny read-only `node -e` Babel transforms of audit-worktree source using the builder worktree's installed `node_modules` (babel-preset-expo 56.0.15, Node 22.13.1) to independently verify the F1 inlining claim. No installs, commits, pushes, deploys, hosted-setting changes, credential access, or live actions.

## 3. Builder evidence status (as found in `execution/s6-mobile/`)

| Stage | Status | Note |
|---|---|---|
| A1 `validate:config` | OK | on pre-merge tree |
| A2 lint | 0 errors | on pre-merge tree |
| A3 `tsc --noEmit` | **exit 2** on 3e9249f+dirty (babel caller typing) | fixed at 27b48f6 by cast; **tsc not rerun on 27b48f6** |
| A4 focused Jest | **3 failed / 972 passed, 2 suites failed** on 3e9249f dirty=7 | log is `tail -80` only |
| A5 rerun | log contains only `exit=1` | no detail |
| M1 Babel transform measurement | present | matches my independent transform |
| B1 full Jest | **NOT RUN** | |
| C1 `expo export` release bundle grep | **NOT RUN** | |

No stage was executed on the exact frozen head 27b48f6. The builder's own evidence therefore does not establish a green CI on the candidate.

## 4. Findings

### S6-B-1 — New release-inlining guard fails deterministically at HEAD (material)
- **Evidence:** `src/config/__tests__/featureFlagsReleaseInlining.test.ts` lines ~113–115 assert that each scanned source does not match `/process\.env\[/`. HEAD's own comments contain the literal `process.env[key]` in `src/config/featureFlags.ts:26` and `src/config/aiGatewayFlags.ts:28`. Two assertions therefore fail on every run. Consistent with builder A4 (2 of 3 failures) and the builder's later fix commit message.
- **Consequence:** `ci.yml` (`npm ci` → validate → lint → tsc → jest --ci) is red at 27b48f6. The candidate cannot be merged as-is; the guard that is meant to protect release inlining produces false positives rather than proof.
- **Smallest remediation:** strip comments (or use Babel AST) before matching, or change the comment wording; rerun the suite on the exact head.

### S6-B-2 — New test imports undeclared `@babel/core`; preserved dependency guard fires (material)
- **Evidence:** the same new test imports `@babel/core`, which is absent from `package.json` at HEAD (only `zod ^3.25.76` dep and `@types/node ^25.9.1` devDep added). `src/config/__tests__/declaredDependencies.test.ts` → "has no undeclared package imports" fails (3rd A4 failure; confirmed by 4dcc164's message).
- **Consequence:** CI red; also positive proof that the #289 dependency guard is preserved and effective (it scans `src/` and root modules, workflows, aliases, and covers test files).
- **Smallest remediation:** declare `@babel/core` as a devDependency with a lockfile entry (one lockfile line). Do not weaken the guard.

### S6-B-3 — Durable pairing-session restore cannot fire in the real app composition; tests prove it only under a synchronous user mock (material — claimed customer behaviour not delivered / evidence overclaim; not a safety defect)
- **Evidence (deterministic, from source):**
  1. `useCurrentUser()` initialises `useState(null)` and loads the user in an `async` effect (`await readUserCache()`), so the **first render always yields `null`** and the user id only arrives after a microtask + re-render.
  2. `useExtensionPairing` hydration effect (`useEffect(..., [enabled, doPoll])`) reads `userIdRef.current` synchronously in the same passive-effects flush; with `uid === null` it skips `readImportPairingMirror`, sets `hydratedRef = true`, and **never re-runs** because `userId` is not a dependency.
  3. `src/hooks/__tests__/useExtensionPairing.test.tsx:35` mocks `useCurrentUser` to return `{id:'coach-1'}` synchronously on first render — timing the production hook never exhibits. The "restores a killed session" tests pass only under that mock.
  4. Additionally, `ExtensionPairingPanel` (which hosts the hook) mounts only when `ImportDataScreen` local state is `awaitingExtension`; that state is `useState({phase:'intro'})` and is not persisted, so after an OS kill the panel/hook does not mount on relaunch at all.
- **Consequence:** the M5-C claim "pairing code survives process death" is not delivered; on relaunch a fresh mint occurs (server expires the earlier code — fail-safe). The mirror is written but never read in production, so it is dead weight plus a plaintext short-TTL code in AsyncStorage with no benefit. This is a truthful-claims / customer-quality finding, not a data-safety one.
- **Smallest remediation:** add `userId` to the hydration dependencies (reset `hydratedRef` when the id becomes available) and either persist the screen phase or hydrate at screen level; replace the synchronous mock with a null-then-user mock in at least one restore test. Alternatively, truthfully drop the durability claim and the mirror.

### S6-B-4 — Isolation review: user switch / logout / expiry / pairing state (no material defect found)
- Mirror key `import_pairing_session:<userId>`; payload `userId` must equal key; version + shape guard; malformed → discarded.
- `authActions.ts` sweeps the exported `IMPORT_PAIRING_MIRROR_KEY_PREFIX` on sign-out (test pins the exact prefix and a look-alike key survives). Sweep is global across users — conservative, acceptable.
- Every terminal (`expired`, `failed`, `authExpired`, `unavailable`, `cancelled`, `paired`) clears the mirror; cancel is durable.
- Expiry is decided solely by server `/status` (`expired`); client clock ignored; a code the caller did not mint reads `expired` at the backend (cross-user defence in depth).
- `api.ts` 401 → refresh mutex → hook `authExpired` only after refresh failure → logout event; panel copy "sign in again" is honest.
- Nonmaterial: hook dependency omission above (S6-B-3) also means an in-session user switch without unmount would not re-hydrate; the coach navigator unmounts on logout so no cross-user leak path was found.

### S6-B-5 — Independent flags, default OFF, no activation (no defect found)
- `featureFlags.extensionImport` and `featureFlags.importReview` are hard `false` defaults (not `isDev`), declared in `.env.example` (test enforces), `useReconstructCounts` requires both flags AND coachId; pairing gated on `extensionImport` only (tests pin both). No env/EAS/profile in the candidate sets either flag on. No new backend consumers added in non-test `src` (only `extensionPairApi.ts` init/status, pre-existing contract). No Roman P1/P2 files touched (diff stat contains no roman/checkin/streak paths).

### S6-B-6 — Expo static-inlining proof adequacy (partially adequate; release-bundle proof missing)
- Independently reproduced: with production caller (`isDev:false`) the transform of the flag modules yields 0 `process.env.EXPO_PUBLIC_`, 0 `process.env[`, 0 `expo/virtual/env`; `EXPO_PUBLIC_FF_EXTENSION_IMPORT:"true"` inlined when set; evaluated with empty env → extensionImport=true, importReview=false, deliverables=false, coachBrief=false. Root cause of the pre-existing main defect is correct: babel-preset-expo `inline-env-vars` only inlines static member access, so the old `process.env[key]` was never inlined.
- **Limit:** this is a per-module transform proof, not a whole-app `expo export`. Stage C (release bundle grep) was not run by anyone. Without it, the "release-bundle flag verification" acceptance row is unproven.

### S6-B-7 — Pairing contract and safe errors / accessibility (no material defect found)
- Client matches backend: `POST extension/pair/init {chosen_platform}` → `{pairing_code, expires_at}`; `POST extension/pair/status {code}` → `pending|paired|expired`; 404 → `unavailable`, 401 → `authExpired`, other → `failed`. Support reference shown only when server supplies `request_id`; request-id middleware sanitises and echoes.
- A11y: digit-by-digit label, `maxFontSizeMultiplier` 1.6 + `adjustsFontSizeToFit`, 44pt copy target, honest copy-failure copy, polite live regions, no "undefined" announcement.
- Nonmaterial: `failed` copy says "check your connection" also for 400/429/5xx (telemetry reason `network` misattributed); support-reference `accessibilityLabel` reads the id as one token; request-id generation now runs on every API request (not flag-gated) and throws if `crypto.getRandomValues` is missing — acceptable because `react-native-get-random-values` is the first import in `index.ts`, but it widens blast radius beyond the feature.

## 5. Evidence gaps (requested through the parent; not executed by me)

On the exact head 27b48f6 (or any successor head, re-scoped):
1. `npx tsc --noEmit` — A3 last failed and was not rerun.
2. `npx jest --ci` full, untruncated log — B1 never run; A4 log truncated.
3. `EXPO_PUBLIC_FF_EXTENSION_IMPORT=true NODE_ENV=production npx expo export --platform android --no-bytecode` followed by the grep in `execution/s6-mobile/logs/run-stage.sh` — C1 never run; only whole-bundle proof settles S6-B-6.
4. A restore test with a null-then-user `useCurrentUser` sequence — needed to substantiate or retire the M5-C durability claim (S6-B-3).

## 6. Verdict

**NOT CLEARED** at head `27b48f64b1dc8df139310941e6a6d7676ce587e6` (tree `beb21b5b…2ee7`).

Grounds: two deterministic test failures at HEAD (S6-B-1, S6-B-2) make CI red; the durable-pairing claim is unproven in real composition and its tests mask the defect (S6-B-3); required execution evidence (tsc, full Jest, release-bundle export) is absent on the frozen head. Isolation, flag independence/default-off, no-activation, pairing contract, error honesty, and accessibility reviews found no material defect. The #289 dependency guard is preserved and demonstrably effective.

Limits: source review plus two local transform reproductions only; no device testing; no peer report consulted; the later builder head 4dcc164 is not covered by this verdict. No secrets, customer records, environment values, or sensitive log payloads are included.
