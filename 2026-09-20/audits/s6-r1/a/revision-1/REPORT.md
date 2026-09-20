# S6 mobile foundation — independent audit A, round 1 (T4)

**Status: SOURCE REVIEW COMPLETE ON FROZEN HEAD; VERDICT: NOT CLEARED (material findings open, execution evidence incomplete).**
Auditor A; Claude Fable 5, High requested (actual reasoning setting not exposed by the tool, not claimed). Independent of the builder and of auditor B; peer report not read.

## 1. Snapshot audited

| | value |
|---|---|
| Worktree | `worktrees/audit-s6-r1` (read-only for this audit) |
| HEAD | `27b48f64b1dc8df139310941e6a6d7676ce587e6` |
| Tree | `beb21b5b09297810563b2379148cb49034932ee7` |
| Base (mobile main) | `a5933fd6de5616493de75f0db907098b149b955c` |
| Lineage | `4be69b9` (#289 first) → `ed0342e` (#290) → `d2f0d31` (#291) → `3408867` (#292) ⟵ merge `3e9249f` of #289 tail (`8f0b584`,`ba3fd40`,`2235498`) → `27b48f6` (S6 F1/F2 repair) |
| Cumulative diff vs main | 31 files, +2688/−45 (verified `git diff --stat a5933fd HEAD`) |
| Backend contract reference | `repos/backend` at main `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` (read-only) |

Head and tree match the dispatch. Identity: `27b48f6` and `3e9249f` author = committer = `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no co-author trailer. The seven preserved PR commits carry `BradleyGleavePortfolio <264851314+…@users.noreply.github.com>` (author and committer) — see S6-A5.

## 2. Scope reviewed and actions taken

Read: `execution/audits/R1_COMMON.md`, `repos/context/AGENT_RULES.md`, `execution/EXECUTION_RULES.md`, S6 acceptance row in `deliverables/TGP-Fitness-Execution-Takeover-Brief.md`, `execution/s6-mobile/REPORT.md`, `MILESTONE-1-architecture.md`, all builder logs under `execution/s6-mobile/logs/`.

Source reviewed in full: `src/config/featureFlags.ts`, `src/config/aiGatewayFlags.ts`, `src/config/__tests__/featureFlagsReleaseInlining.test.ts`, `src/hooks/useExtensionPairing.ts`, `src/storage/importPairingMirror.ts`, `src/services/authActions.ts` (sweep + `signOut`), `src/services/api.ts` (request-id + refresh/401 path), `src/api/extensionPairApi.ts`, `src/utils/correlation.ts`, `src/utils/idempotency.ts`, `src/types/extensionImport.ts` (decoder), `src/components/coach/ExtensionPairingPanel.tsx`, `src/screens/coach/ImportDataScreen.tsx` (mount path), `src/hooks/useCurrentUser.ts`, `src/lib/userCache.ts`, `src/hooks/useReconstructCounts.ts`, `.github/workflows/ci.yml`, `eas.json`, `babel.config.js`, `metro.config.js`, `.env.example`, structure of `src/config/__tests__/declaredDependencies.test.ts`, restore tests in `useExtensionPairing.test.tsx`. Unchanged dependencies read: `babel-preset-expo@56.0.15` `build/plugins/inline-env-vars.js` + `common.js`, `@expo/metro-config@56.0.14` `babel-transformer.js`, `expo/virtual/env.js`, `@sentry/react-native` `tools/metroconfig.js`; backend `extension-pair.controller.ts`, `extension-pair.service.ts`, `extension-pair.dto.ts`, `observability/request-id.middleware.ts`.

Executed (read-only, no install, no lock, seconds): one Node 22.13.1 babel transform of the two flag modules using the builder's already-installed `worktrees/s6-mobile/node_modules` via `NODE_PATH`, production Metro caller shape, `EXPO_PUBLIC_FF_EXTENSION_IMPORT=true`. Result: featureFlags.ts / aiGatewayFlags.ts → `process.env[`=0, `process.env.EXPO_PUBLIC_`=0, `expo/virtual/env`=0, `EXPO_PUBLIC_FF_EXTENSION_IMPORT:"true"` inlined; control `process.env[k]` survives untransformed. Independently confirms the builder's M1 measurement and F1 mechanism (plugin `toMemberProperty` returns the identifier name `key`, which fails the `EXPO_PUBLIC_` prefix test).

Not done: no Jest/tsc/lint/export runs (requested from parent, §6), no device/EAS, no hosted settings, no credentials.

## 3. Findings

### S6-A1 — MATERIAL (merge-blocking, deterministic): the new release-inlining guard fails on the frozen HEAD

**Evidence.** `featureFlagsReleaseInlining.test.ts:113-115` asserts `expect(sources[file]).not.toMatch(/process\.env\[/)` against the raw source text of both modules. Both committed modules contain the literal `process.env[key]` inside the explanatory comment (`featureFlags.ts:26`, `aiGatewayFlags.ts:28` — `grep -n 'process\.env\[' src/config/*.ts`). The builder's own `logs/A4-jest-focused.log` (working tree = HEAD content, Node 22.13.1) shows this exact assertion failing for `aiGatewayFlags.ts` at line 114, "Test Suites: 2 failed, 73 passed; Tests: 3 failed, 972 passed", `exit=1`; `A5-jest-config-rerun.log` = `exit=1`.

**Consequence.** The candidate ships a red deterministic guard: CI (`npm test -- --ci`) fails on `27b48f6`; the guard cannot serve as the release-bundle invariant it is claimed to be (§4 of builder report) until it distinguishes code from comments. Not a runtime/customer defect — the transform-level assertions and the evaluated-with-empty-env assertions are sound and pass — but G07/G09: a failing required check is not evidence, and REPORT.md §4 lists this invariant as if established.

**Smallest remediation.** Either strip comments before the regex (or assert on the babel AST — e.g. no `MemberExpression` with `computed: true` on `process.env`), or reword the two comments so they do not contain the literal `process.env[`. One further commit; re-run the focused config suite and full `--ci`. The two failing tests are accounted for; the third failing test in A4 is unidentified (log tail truncated) — see gap E1.

### S6-A2 — MATERIAL (correctness / truthful customer state; default-off feature): durable pairing-session restore is unreachable in the real mount order

**Evidence.** `useExtensionPairing.ts:140-146, 344-372`: `userId` comes from `useCurrentUser()`, whose state is `useState(null)` and only becomes non-null after an effect awaits `readUserCache()` (`useCurrentUser.ts`, `userCache.ts:48` async). The hydration effect (deps `[enabled, doPoll]`, both stable) reads `userIdRef.current` synchronously on first mount — at that instant it is always `null` — so `restored = null`, `hydratedRef.current = true`, and the effect never re-runs when the user resolves. `ExtensionPairingPanel.tsx:97-103` then auto-calls `start()`, which passes the `hydratedRef` gate and mints a fresh code. `readImportPairingMirror` is therefore never called with a real user id on any real mount; `IMPORT_PAIRING_RESTORED` can never fire. The mirror *write* still works (by the time `/pair/init` responds, `userIdRef.current` has usually resolved), so records accumulate but are only ever cleared, never restored.

The hook tests pass only because `useExtensionPairing.test.tsx:35-36` mocks `useCurrentUser` to return the user synchronously on the first render — an assumption the real hook does not satisfy. No test renders with an initially-null user that resolves later.

**Consequence.** The headline behaviour of #291 ("durable user-scoped pairing state … rehydrated on relaunch") does not occur. After an OS kill mid-pairing: the coach re-enters the flow, the app mints code B and the backend expires still-live code A (`extension-pair.service.ts:79-87`). If the coach already redeemed A in the extension, the app now polls B and shows "waiting" indefinitely while the import actually runs — a misleading customer state that a working restore would have reported as `paired`. Isolation properties (per-user key, mismatch discard, sign-out sweep, no read when flag OFF) still hold; there is no security/tenant consequence. Feature is default OFF (nothing customer-visible until activation), but G02/G09: the candidate and REPORT.md claim a completed behaviour that is not delivered, and the evidence (mocked-sync tests) overclaims.

**Smallest remediation.** Gate hydration on a resolved user: include `userId` in the hydration effect's deps and treat `hydratedRef` as false until a non-null user has been consulted (deferring `start()` via the existing `pendingStartRef` path, which already exists for this race). Optionally also discard a restored record whose `platformId !== platformSlug` (currently a session minted for platform X would be shown under a Y screen). Add one test where the mocked `useCurrentUser` returns `null` on first render and the id on a later render, asserting restore + no `init` call.

### S6-A3 — MATERIAL as a release/activation precondition (not a code defect): F1 changes the effective release value of ~38 flags from "always fallback" to "whatever the EAS environment says"

**Evidence.** Pre-repair, every `readFlag`/`envBool` in release resolved to its fallback regardless of EAS env (confirmed by plugin read and transform). Post-repair, the inlined value is `process.env.<KEY>` at bundle time. `eas.json` pins only `EXPO_PUBLIC_USE_MOCK_COMMAND_CENTER` and `EXPO_PUBLIC_NOTIFICATIONS_MOCK` to `"false"`; all other `EXPO_PUBLIC_FF_*` / `EXPO_PUBLIC_FEATURE_*` values come from the hosted EAS `production` / `preview` environments, whose current contents are unverified (brief: "actual flag values … remain unverified").

**Consequence.** Any `EXPO_PUBLIC_FF_*`=true present in the hosted EAS environment (set at any time in the past with no effect) would silently activate that surface in the first release built from this head — including `isDev`-fallback flags (`clientPathCopilot`, `coachBrief`, `adminControlRoom`, `privateCommunityHub`, `verifiedProgressSignoff`, `deliverables`, `aiGatewayEnabled`). This is exactly the "no accidental activation" exit criterion. The code is correct; the release input is unknown.

**Smallest remediation.** Before any build from this lineage: read-only inventory of `EXPO_PUBLIC_*` in the EAS `production` and `preview` environments (parent/Bradley, no mutation), recorded in evidence; expected state is that none of the ~38 keys is set, or each set value is intentionally approved. Consider pinning the import kill switches to `"false"` in `eas.json` `production.env` the same way the mock flags are pinned, so the first release after F1 cannot enable import without a reviewed diff.

### S6-A4 — NONMATERIAL: transform-level proof is a good CI invariant but does not by itself prove the release bundle

The test mirrors Metro's real caller (`@expo/metro-config` sets `isDev: options.dev`, `bundler:'metro'`, `preserveEnvVars` only when explicitly requested), uses the project's only preset (`babel.config.js`), and the Sentry Metro wrapper does not alter the transformer unless `annotateReactComponents` is configured. Residual gaps: whole-graph `expo export` (stage C, not run) would confirm no other module reintroduces a computed read and that `NODE_ENV`/`__DEV__` fold as assumed; an EAS build with the env var actually present is the only end-to-end proof; Hermes `.hbc` cannot be grepped, so stage C must use `--no-bytecode` as scripted. Disposition: accept the test as the deterministic guard once S6-A1 is fixed; stage C is confirmatory evidence, not a substitute for S6-A3.

### S6-A5 — NONMATERIAL for product, relevant to landing route: preserved PR commits do not carry the required identity

Commits `4be69b9`, `ed0342e`, `d2f0d31`, `3408867`, `8f0b584`, `ba3fd40`, `2235498` have author and committer `BradleyGleavePortfolio <264851314+BradleyGleavePortfolio@users.noreply.github.com>`. G05 requires `Bradley Gleave <bradley@bradleytgpcoaching.com>` on commits that land. A merge/rebase of this branch as-is lands seven non-compliant commits; a squash would lose the preserved per-PR provenance. Not a candidate defect (originals are preserved by instruction) — parent must choose the landing route deliberately and record it.

### S6-A6 — NONMATERIAL observations (record, no action required for clearance)

- `authExpired` state offers "Please sign in again, then retry" with a "Retry" CTA that re-mints with the same token. Reachable only when the axios refresh succeeded yet the retried request still returned 401/403 (refresh failure routes to full `signOut()` and unmounts the panel). Wording, not safety.
- Copy-status text uses `accessibilityLiveRegion="polite"` (Android only); iOS VoiceOver gets no announcement of "Copied"/"Couldn't copy" (no `AccessibilityInfo.announceForAccessibility`). Minor WCAG 4.1.3 gap; digit-by-digit label, 44pt target, `maxFontSizeMultiplier` are sound.
- Pairing code (short-TTL, single-use bearer for `/redeem`) mirrored in plaintext AsyncStorage; also on the clipboard by design. Device-sandboxed; acceptable for this candidate, SecureStore later.
- Backend `init` performs create then `updateMany` (expire prior codes) non-transactionally; a failure between them leaves two live codes. Pre-existing backend behaviour, outside S6.
- Sign-out sweep removes every `import_pairing_session:*` key (all users), which is stricter than per-user and correct for this data.

## 4. Verified OK (independent source review)

- **Pairing contract** matches backend main: `POST /extension/pair/init {chosen_platform}` → `{pairing_code, expires_at}` (201; 400 `code_mint_failed` or ValidationPipe; 401/403/404/429); `POST /extension/pair/status {code}` → `{status: pending|paired|expired}`; another coach's or unknown code reads `expired`. Mobile decoder fails closed (`unknown` → keep waiting, never `paired`). `Idempotency-Key` is not read by the backend (F2 correction accurate); one-live-code outcome comes from the service invariant.
- **Correlation**: mobile sets `X-Request-Id` (v4 UUID from the single CSPRNG path); backend `RequestIdMiddleware` sanitises/echoes `X-Request-ID` and the filter body `request_id`; `extractRequestId` prefers body then header. Support reference shown only when present; never presented as diagnosis.
- **User-switch / logout / expiry isolation**: mirror key `import_pairing_session:<userId>`, payload `userId` cross-checked and discarded on mismatch, version/shape drift discarded; prefix swept in `ASYNC_SIGN_OUT_PREFIXES`; refresh-failure path calls the same `signOut()`; server `expired`/401/403/404 → mirror cleared; no storage read when `enabled` is false. `useReconstructCounts` keyed by coach id and requires `extensionImport && importReview && coachId`.
- **Independent switches / default-off**: `extensionImport` and `importReview` both hard-`false`; `useExtensionPairing` reads only `extensionImport` (pinned by `importFlags.test.ts`); `.env.example` documents both as `false`; no `isDev` fallback on import flags.
- **No new unfrozen C1 consumers**: no new `api.*` paths or `PATH` constants in the cumulative non-test diff; only `/extension/pair/*` (pre-existing) is used. `src/components/roman`, Roman P1/P2 surfaces untouched (no files under the cumulative diff).
- **Preserved dependency guard** (#289 tail): tsc-based import scan across `src/` + root entrypoints, lockfile-root pins for `zod` and `@types/node`, workflow scan for `npm ci`-only installs with alias/lookalike handling; CI workflow uses Node 22.13 and `npm ci`. `expo-clipboard` is declared.
- **Telemetry/log safety**: only `platform` slug in new `track()` payloads; code/token never logged; `logger` is `__DEV__`-gated.
- **F1 preserved semantics**: `readFlag` parse rules unchanged; every `readFlag`/`envBool` key present as a literal `KEY: process.env.KEY`; no other callers of the readers outside the two modules; no other computed `process.env[` reads in `src/`.

## 5. Adequacy of shared test evidence

Builder evidence is on `head=3e9249f dirty=7` (working tree content equal to `27b48f6` per REPORT.md; not independently provable from logs). `validate:config` OK; lint 0 errors; `tsc` **exit 2** on the pre-commit tree (fixed before commit, not re-run); focused Jest **3 failed / 972 passed**; full suite and `expo export` **not run**. None of it is attributable to the frozen head. I challenge the restore-path coverage (S6-A2) and the source-regex guard (S6-A1) as inadequate irrespective of pass/fail.

## 6. Evidence requested from parent (exact head `27b48f6`, Node 22.13.1 toolchain, test-validation lock)

- E1: `npx jest --ci src/config src/hooks/__tests__/useExtensionPairing.test.tsx src/storage src/navigation 2>&1 | grep -E "✕|●.*›|Tests:|Test Suites:"` — full list of failing test names (to identify the third A4 failure).
- E2: `npx tsc --noEmit; echo exit=$?` on `27b48f6`.
- E3: `npx jest --ci 2>&1 | tail -40` (stage B).
- E4: stage C as scripted (`expo export --platform android --no-bytecode`, flag on) — confirmatory for S6-A4.
- E5 (release gate, not a command in this sandbox): read-only listing of `EXPO_PUBLIC_*` names/values in EAS `production` and `preview` environments (S6-A3).

## 7. Verdict and limits

**NOT CLEARED for T4 at `27b48f6`.** Blocking: S6-A1 (red deterministic guard in HEAD, CI fails), S6-A2 (claimed restore behaviour unreachable; tests overclaim). S6-A3 must be closed with evidence before any release build from this lineage, not before merge. S6-A4/A5/A6 nonblocking. Source review is complete for this head; remaining execution evidence (E1–E4) is pending and would not by itself clear A1/A2. A changed head requires a risk-scoped re-attestation; I expect the A1/A2 fixes to be small and scoped to `featureFlagsReleaseInlining.test.ts` (or the two comments), `useExtensionPairing.ts`, and one new hook test, in which case a focused re-review of those files plus fresh E1–E3 on the new head would suffice.

No secrets, customer records, environment values or sensitive payloads are recorded here.
