# UX-02/UX-07 mobile presentation — sole-writer execution handoff (T2, source-only)

Parent EXEC-95633079. Sole writes: `worktrees/ux07-mobile/**` and `execution/95633079/ux/mobile-presentation/**`. No npm/install/tests/typecheck/build/browser/commit performed — C1 owns heavy validation; this handoff freezes the exact delta and blob accounting for that later independent T2 source audit. No remote or private-checkout writes. Nothing pushed.

## Recovery

Standalone worktree recovered at `worktrees/ux07-mobile` by cloning the isolated bare object store at `execution/95633079/ux/roman-donor/objectstore` (already fetched read-only by exact SHA in the prior ROMAN-DONOR task; not re-fetched, not re-audited) and checking out the accepted commit directly:

- Base checkout: `bc7b4e96fc1db54568bc209dbe1f7a4121501ac9` (accepted S6 successor — the actual future mobile base, per parent's correction; not `d51a1910`, which is used nowhere in this recovery).
- Base tree: `acb41c2baab6e856573d86e02135430c3304828b`.
- Base parent: `d51a191098f483cea9abec6cc7e9f3beffd18c06` (recorded only as git's own parent pointer, not as a build target).
- No fetch from public main, no S6 recomposition, no new clone from GitHub — the origin remote was removed after cloning from the local object store; only local branch `ux02-ux07-presentation` was created on top of the checked-out commit.

## What was built (smallest useful presentation slice)

### 1. PR293 asset adoption — verbatim, zero re-authoring

Eleven files from PR293 (`003a9774083812a465fbc78a99aaba5ca16ccfa5`) were brought in with `git checkout 003a9774... -- src/screens/coach/import-journey/` directly against the recovered worktree, then blob-hash-verified byte-identical (see `BLOB_ACCOUNTING.md`): `ImportOfferCard.tsx`, `ImportSetupView.tsx`, `importJourneyUI.tsx`, `importJourneyCopy.ts`, `i18n/en.json`, `README.md`, and all five `__tests__/*` files including `sideEffectGuards.cjs`. PR294 (`5cbf0de3...`) was **not** touched, per instruction — it remains deferred. No new interaction primitives or a11y tests were authored: the donor's own `ImportOfferCard.test.tsx`/`ImportSetupView.test.tsx` already assert accessibility roles/labels/focus behavior, so nothing was duplicated.

Path is new (`src/screens/coach/import-journey/`); confirmed absent from the base tree before this change, so this is a pure addition with no merge conflict against S6's actual delta (re-confirming, not re-auditing, the prior ROMAN-DONOR finding).

### 2. Settings row label — one-line presentation edit

`src/screens/coach/SettingsScreen.tsx` line 368: `"Import Data"` → `"Import my records"`, per the journey spec's J2 row-label intent (`journey/CANONICAL_MOBILE_JOURNEY_SPEC.md` J2: "Settings row label intent 'Import my records'"). Confirmed before editing that no test asserts the literal visible string (`src/navigation/__tests__/importDataFlagOff.test.ts` only asserts flag-gating behavior via `describe`/route presence, not text content). `onPress`, `navigation.navigate('ImportData')`, `featureFlags.extensionImport` gate, `accessibilityLabel`, and `testID` are all byte-unchanged — this is strictly a display-string change, not a controller change.

### 3. J3 source-selection restyle — NOT executed; exact pending need identified

Read the full existing controller (`ImportDataScreen.tsx`, 287 lines) and the full donor (`ImportSetupView.tsx`, 176 lines) before attempting the swap. Finding: `ImportSetupView`'s `step: 'source'`/`'customSource'` variants map cleanly onto the controller's existing `selectPlatform`/`onCustomUrlChange`/`openLogin` logic and existing `IMPORT_PLATFORMS`/`safeImportLoginUrl` contracts — **except** for two required callback props, `onBack` and `onLater`, which correspond to no phase in the controller's actual `ImportFlowState` union (`intro | customUrlEntry | openingLogin | awaitingExtension | failed`, per `src/types/extensionImport.ts`).

- `onBack` has a truthful native equivalent already available for free: `ImportDataScreen` is mounted as an ordinary `SettingsStack.Screen` (`CoachNavigator.tsx` L433), so React Navigation's native stack back button already returns to Settings with zero added code. Wiring the donor's `onBack` to `navigation.goBack()` would be presentation-faithful and requires only adding the already-precedented `useNavigation()` hook (identical pattern to `SettingsScreen.tsx`'s own usage) — **not** an invented API.
- `onLater` has **no truthful implementation available today**. In the donor's intended journey it means "defer the whole import decision and persist that per account" — that persistence hook is exactly the account-keyed offer-decision mechanism the parent's handoff correction just classified as UX-01 state/identity, T4, explicitly excluded from this T2 slice. Implementing `onLater` as a silent no-op, a fake dismiss, or an ad hoc local flag would either misrepresent the screen's behavior or invent a storage/flag boundary this task is explicitly forbidden from inventing.

Per the parent's own instruction ("If integration would touch controller/identity/intent/eligibility authority, leave binding pending with exact need; do not invent endpoint/storage/flag" and "Stop/report if genuine T4 boundary rather than expanding"), **the J3 restyle is left pending, not partially built.** `ImportDataScreen.tsx` is confirmed byte-identical to the accepted `bc7b4e96` state (see verification below) — it was read but not written.

**Exact need to unblock J3, stated once:** either (a) UX-01 delivers the account-keyed offer-decision persistence contract so `onLater` has a truthful implementation, or (b) the product owner accepts a narrower J3-only variant of `ImportSetupView` that drops `onLater` entirely (own the component fork as a UX-02-scoped variant rather than the donor's full multi-step journey shape) — a design decision for the assigned writer/product owner, not one this source-only pass should make unilaterally.

## Verification: no controller/identity/pairing/cache/flag/navigation bytes touched

```
UNCHANGED: src/hooks/useExtensionPairing.ts
UNCHANGED: src/services/authActions.ts
UNCHANGED: src/storage/importPairingMirror.ts
UNCHANGED: src/api/extensionPairApi.ts
UNCHANGED: src/config/featureFlags.ts
UNCHANGED: src/navigation/CoachNavigator.tsx
UNCHANGED: src/screens/coach/ImportDataScreen.tsx
```
(`git diff --quiet HEAD -- <path>` against the recovered `bc7b4e96` checkout, run per file; all seven report unchanged.) All accepted S6 query-cache/sign-out fix bytes are preserved untouched — they were never part of this delta's file set.

## Font/token reuse confirmation

No new token, color, or font was introduced. `importJourneyUI.tsx` and `ImportOfferCard.tsx` import only `radius`, `spacing`, `typography`, `brand`, `colors` from the existing `src/theme/tokens.ts` (present, unchanged, in the accepted head). Cross-checked against `execution/95633079/ux/design-system/TOKEN_REUSE_AND_EXCLUSION_LIST.md`: no `stone` or `mutedGold` text usage appears in any adopted file (both are excluded from all text per that list's AA ≥4.5:1 normal / ≥3:1 large-text reasoning); the adopted components use `textPrimary`/`textMuted`/`disabledBg`-class semantic tokens only, consistent with the exclusion list's guidance. No independent contrast measurement was run in this pass (that belongs to the deferred install/test phase); this is a static-import-source check only.

## Frozen delta artifacts (for the next independent T2 source audit — not executed here)

- `execution/95633079/ux/mobile-presentation/UX02_UX07_PRESENTATION.patch` — full `git diff` of the working tree against the recovered `bc7b4e96` checkout (text patch).
- `execution/95633079/ux/mobile-presentation/UX02_UX07_PRESENTATION.binary.patch` — same, with `--binary` (covers any non-text donor asset; none currently present, kept for completeness/future-proofing).
- `execution/95633079/ux/mobile-presentation/BLOB_ACCOUNTING.md` — per-file reuse-vs-authored accounting: all 11 new files' SHA-1 blob hashes verified identical to PR293's exact blobs; the 1 modified file's diff shown in full (the Settings label line).
- `execution/95633079/ux/mobile-presentation/EXACT_PINS.md` — exact base commit/tree/parent this delta applies onto, plus the donor commits consumed (PR293) and explicitly not consumed (PR294).

## Minimum existing validation commands for the next independent T2 source audit (not run in this pass)

Recorded for the auditor, per the "C1 owns heavy" boundary — none of these were executed here:

```
# from worktrees/ux07-mobile, git checkout ux02-ux07-presentation
npm ci
npx tsc --noEmit
npx jest src/screens/coach/import-journey/__tests__/ --silent
npx jest src/navigation/__tests__/importDataFlagOff.test.ts --silent
npx jest src/screens/coach/__tests__/ --silent
```

The first three exercise exactly the adopted PR293 files (component + copy + side-effect-guard tests) and typecheck the whole tree. The fourth re-confirms the flag-off guarantee is unbroken by the label edit (it asserts route/behavior, not the changed string, so it should be unaffected — the auditor should still run it, not assume it from this report). The fifth covers `ImportDataScreen`'s and `SettingsScreen`'s own existing suites, which were not modified in source but should still pass unchanged given the one-line non-functional edit.

## Sources

- [`growth-project-mobile` PR #293](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/293) (donor, adopted verbatim)
- [`growth-project-mobile` PR #294](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/294) (donor, explicitly deferred, not touched)
- Internal: `execution/95633079/ux/roman-donor/ROMAN_DONOR_DISPOSITION.md` (prior comparison, corrected, not redone here), `checkpoint-private/execution/e7d2385c/S6_FINAL_ACCEPTANCE.md`, `resume-evidence/ux-planning/journey/CANONICAL_MOBILE_JOURNEY_SPEC.md` (J2/J3), `resume-evidence/ux-planning/journey/CONTRACT_QUESTIONS.md` (CQ-02), `execution/95633079/ux/design-system/TOKEN_REUSE_AND_EXCLUSION_LIST.md`.
