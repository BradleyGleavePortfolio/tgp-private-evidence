# ROMAN-DONOR disposition: #293/#294 onto accepted S6-BASE (source-only, T2)

**Parent handoff corrections (2026-09-23 22:47 PDT, recorded here per parent instruction; comparison not redone):**
1. **Actual future mobile implementation base is the accepted successor `bc7b4e96fc1db54568bc209dbe1f7a4121501ac9` itself, not its parent `d51a191098f483cea9abec6cc7e9f3beffd18c06`.** Every table/finding below that labels `d51a1910` as "S6-BASE" is using that SHA only as the **historical pre-S6-fix comparison point** for isolating what the S6 lane itself changed (Finding 1's overlap check needed the pre-fix tree to prove the donors don't collide with the S6 query-cache/sign-out fix). It is not a claim that mobile UX code should branch from `d51a1910`. All reuse/mount findings (Finding 4, the mount-point table, all four proposed T2 slices) were read directly from `bc7b4e96` — the accepted head — and remain valid unchanged under this correction.
2. **The account-keyed offer-decision persistence hook is UX-01 state/identity work, T4 under the official register — not part of any T2 Home-card slice.** Below, every mention of "local per-account decision persistence" as if it were inside UX-02's T2 scope is corrected: UX-02's T2 slice may consume that persistence once UX-01 delivers it, but must not implement it. This does not retroactively promote UX-02 itself, and it does not pre-grade UX-01's own tier — UX-01 was already T4 in `OFFICIAL_UX_JOB_AND_PR_MAP.md` before this comparison. The "no T4 promotion" finding at the end of this report refers only to the donor-comparison surface (#293/#294 content), not to UX-01's decision-persistence hook, which was never in scope for a donor-content promotion call.

Scope: bounded T2 source-only comparison for earliest-codeable UX-02 (Roman Import Entry & Discovery) and UX-07 (Importer Design System & Accessibility). No redesign, no re-audit of accepted S6, no re-composition/retest of #289–#292 (already ancestors), no product worktree, no install, no test run, no remote writes. All evidence below is exact-object comparison inside an isolated bare git object store; nothing was checked out.

## Exact source pins

| Ref | SHA | Role |
|---|---|---|
| S6 acceptance record | `checkpoint-private/execution/e7d2385c/S6_FINAL_ACCEPTANCE.md` | governing acceptance doc |
| S6 accepted HEAD | `bc7b4e96fc1db54568bc209dbe1f7a4121501ac9` | accepted successor (candidate) |
| S6 accepted parent / **S6-BASE** | `d51a191098f483cea9abec6cc7e9f3beffd18c06` | mobile UX base per `OFFICIAL_UX_JOB_AND_PR_MAP.md` / `DEPENDENCY_DAG.md` gate `S6-BASE` |
| S6 accepted tree | `acb41c2baab6e856573d86e02135430c3304828b` | matches acceptance record exactly |
| S6 bundle | `s6-r2-bc7b4e96-from-public-a5933fd6.bundle`, SHA-256 `85836076cc1a99211153a5ad292415e72dd130299ec9dcb13458fec788efccf7` | recovered from `checkpoint-private/execution/e7d2385c/evidence/s6-r2-actual-a9a580da-and-bindings.tar.gz` (manifest-listed, targeted-extracted only); hash verified byte-for-byte before use |
| Public base (bundle prerequisite) | `a5933fd6de5616493de75f0db907098b149b955c` | fetched read-only by exact SHA from `github.com/BradleyGleavePortfolio/growth-project-mobile` |
| Donor #293 (Roman P1) head | `003a9774083812a465fbc78a99aaba5ca16ccfa5` | fetched read-only by exact SHA; base `main` |
| Donor #294 (Roman P2) head | `5cbf0de3f3d1d7f279ac72e43638f9e45acf9cf5` | fetched read-only by exact SHA; base `#293` head (`5cbf0de3` confirmed on GitHub; PR body's `f687ee6f` is a stale self-report per `CANONICAL_MOBILE_JOURNEY_SPEC.md` Findings — recorded, not re-litigated) |

Isolated read-only object store: `execution/95633079/ux/roman-donor/objectstore/` (bare repo, no working tree, ~8.1MB). Refs: `refs/bundle/HEAD` (S6 accepted commit graph), `refs/remote-objects/public-base`, `refs/remote-objects/pr293-head`, `refs/remote-objects/pr294-head`. No push, no clone into a product tree, no `npm`/`jest`/`tsc` invoked anywhere in this task.

## Comparison method

1. `git diff --name-status` of #293 against its declared base (`main` `a5933fd6`) and #294 against its declared base (#293 head) — establishes exactly what each donor PR adds/changes in isolation.
2. `git ls-tree -r` of the accepted S6 head (`bc7b4e96`) and S6-BASE (`d51a1910`) for the donor paths and for the real mount-point files — establishes whether S6 already touched or collides with anything the donors add.
3. `git diff --name-status a5933fd6 d51a1910` filtered to import/extension paths — establishes the actual S6 changed-file set for overlap checking.
4. Content inspection of the donor files for network calls, storage calls, or endpoint/flag invention, cross-checked against the donors' own `sideEffectGuards.cjs` Jest-mock harness (which throws if `services/api`, `extensionPairApi`, `useExtensionPairing`, `authActions`, `AsyncStorage`, `expo-secure-store`, `fetch`, `Linking`, `Share`, etc. are touched).

## Finding 1 — Zero path overlap between donors and S6's actual delta

S6 (`a5933fd6` → `d51a1910`) touched exactly:
`docs/importer/MOBILE_IMPORT_DECISION.md`, `src/api/extensionPairApi.ts` (+test), `src/components/coach/ExtensionPairingPanel.tsx` (+3 tests), `src/config/__tests__/importFlags.test.ts`, `src/hooks/useExtensionPairing.ts` (+2 tests), `src/screens/coach/ImportDataScreen.tsx` (+1 test), `src/storage/importPairingMirror.ts` (+test).

Donors #293/#294 add exactly one new directory, `src/screens/coach/import-journey/**` (11 files in #293, +11 more/modified in #294; see Finding 2). `import-journey/` does not exist anywhere in S6-BASE or the accepted S6 head (`git ls-tree` returns nothing). **No file-path collision exists between the donors and S6's changed set.** This is a clean grft, not a merge-conflict risk.

## Finding 2 — Donor #293 → #294 is purely additive, not divergent

`git diff --name-status` between the two donor heads shows zero deletions. The two files #294 modifies that #293 created (`importJourneyCopy.ts`, `i18n/en.json`) are extended only:
- `importJourneyCopy.ts`: #294 adds `QuantityKey`, `isImportQuantity`, `importQuantityCopy`, `importObservationCopy`, `importCheckedScopeCopy` and narrows the exported `ImportJourneyCopyKey` type to exclude the new variable-bearing keys. Every symbol #293 exported is still exported unchanged.
- `i18n/en.json`: 83 pure insertions, 0 removals.

This means UX-02 (consuming #293's `ImportOfferCard`/`ImportSetupView`) and UX-04/05/06 (consuming #294's status/result views, out of this task's scope but noted for the DAG) can both build on the same `importJourneyCopy.ts`/`i18n/en.json` files sequentially without rebasing conflict, exactly as `DEPENDENCY_DAG.md`'s serialization-point table already asserts for that shared-file pair.

## Finding 3 — No wiring, no invented contracts (verified in content, not just asserted)

Both donor PRs are self-enforcing "presentation only": their `__tests__/sideEffectGuards.cjs` harness mocks `services/api`, `api/extensionPairApi`, `hooks/useExtensionPairing`, `services/authActions`, `utils/supabaseAuth`, analytics, `AsyncStorage`, `expo-secure-store`, `expo-clipboard`, `expo-sharing`, `Linking`, `Share`, and global `fetch` to throw on any call, then asserts zero calls. Direct inspection of `ImportOfferCard.tsx` and `ImportStatusFrame.tsx` independently confirms no `fetch`/`axios`/`api.`/`AsyncStorage`/`SecureStore` reference exists in either file. Every donor component is a controlled component (callback props only: `onYes`, `onImportRecords`, `onResume`, etc.); no component mounts a provider, reads storage, or calls a network boundary. **No endpoint, flag, or storage path is invented anywhere in the donor set** — this matches the task's constraint and the job-map's own characterization of #293/#294 as "no wiring, no storage, no auth, no analytics."

`ImportSetupView.tsx` correctly imports real S6-BASE contract surfaces (`IMPORT_PLATFORMS`, `findImportPlatform` from `src/constants/importPlatforms.ts`; `safeImportLoginUrl` from `src/utils/safeImportLoginUrl.ts`) rather than inventing its own — the only "contract" touched is the existing, already-accepted source-selection shortcut list.

## Finding 4 — Actual mount points confirmed live in the accepted S6 head

Directly read from `bc7b4e96` (not inferred):

- **Settings row** (`src/screens/coach/SettingsScreen.tsx` L354–368): existing "Import Data" row, gated by `featureFlags.extensionImport &&`, `onPress={() => navigation.navigate('ImportData')}`, `accessibilityLabel="Import data from another platform"`. This is the exact, single mount point UX-02 must add a Home-card sibling to — not invent.
- **Navigation route** (`src/navigation/CoachNavigator.tsx` L80–81, 214, 431–433): `ImportDataScreen` registered as `SettingsStack.Screen name="ImportData"`, gated by the same `featureFlags.extensionImport` flag.
- **Flag definition** (`src/config/featureFlags.ts` L419): `extensionImport: readFlag('EXPO_PUBLIC_FF_EXTENSION_IMPORT', false)` — default OFF, exactly as the spec states. No second flag is needed for UX-02's card shell.
- **CoachHomeScreen.tsx**: contains zero import/journey references today — confirmed clean insertion point for the J0/J1 offer/resume card; no existing code to reconcile.

No eligibility endpoint, offer-decision persistence endpoint, or per-account decision store exists anywhere in the inspected boundary (S6-BASE, accepted S6 head, donor PRs). This matches `CONTRACT_QUESTIONS.md` CQ-01/CQ-02 exactly: eligibility stays server-side and unbuilt (S7 gate), and per-account decision persistence is a mobile-side design choice with no mandatory new endpoint. This report invents neither.

## Reuse vs. minimal-needed-delta disposition

### UX-02 Roman Import Entry & Discovery

| Donor asset | Disposition | Delta needed |
|---|---|---|
| `ImportOfferCard.tsx` (#293) | **Reuse as-is.** Controlled component, all three variants (`question`/`value`/`resume`) already match J0/J1's Yes/Starting-fresh/Later and compact-resume needs. | None to the component itself. Needs one mount in `CoachHomeScreen.tsx` supplying the callbacks. **Correction:** the account-keyed offer-decision persistence those callbacks write to is UX-01 state/identity, T4 — not built inside this component or inside any T2 slice; the Home mount is a future UX-01-gated integration, not a standalone T2 deliverable (see corrections note at top). |
| `ImportSetupView.tsx` (#293), `step: 'source'`/`'customSource'` | **Reuse for J3 restyle only** (explicitly named in the map as "J3 source-selection restyle... presentation only, no binding"). | None structurally; swap in real `onContinue`/`onCustomSourceChange` handlers that currently only exist as typed no-op-safe callback props. Binding the choice to a server intent is S7-gated, out of UX-02's exit criteria. |
| `importJourneyCopy.ts`, `i18n/en.json` (#293 slice only — do not pull #294's additions yet) | **Reuse the #293-authored keys.** | Copy is intent-only per spec; final strings are a copy-owner task, not this comparison's job. |
| `importJourneyUI.tsx` (#293) | **Reuse as shared primitive** (also UX-07, see below); `ImportJourneyAction`, `ImportJourneyPortrait`, `useImportHeadingFocus`. | None; already 48×44pt-plus, focus-managed, accessibility-labeled. |
| Settings row rename ("Import my records") | **Minimal delta.** One string edit to the existing row at `SettingsScreen.tsx` L368, not a new row. | Trivial. |

Net: UX-02's donor-derived T2 surface needs **zero new files beyond the Settings string edit and the J3 restyle**; the Home-card mount and its account-keyed decision-persistence hook are correctly UX-01 T4 territory (corrected above) and are excluded from this task's T2 execution slices below.

### UX-07 Importer Design System & Accessibility

| Donor asset | Disposition | Delta needed |
|---|---|---|
| `importJourneyUI.tsx` (#293) | **Reuse as the shared a11y primitive module**, exactly as the job-map names it ("UX-07 primitives", shared with UX-02 "under the mobile entry UI writer"). | None to the file. It already implements: 44×44pt-plus `minHeight/minWidth: 48`, visible focus ring (`focusFrame`), `accessibilityRole="button"`, `accessibilityHint`, `accessibilityState`, one localized announcement path (`ImportJourneyPortrait`), and a `useImportHeadingFocus` hook that focuses only on step/variant change or explicit mount (never on every render) — directly satisfies X2's "polite deduplicated announcements" and "focus lands on the question" requirements from J0. |
| `__tests__/*.a11y*`/accessibility test suites (#292 donor per map, #294's `ImportStatus.accessibility.test.tsx`) | **Reuse as the a11y test pattern donor** for UX-07's own suite under `import-journey/__tests__/`. | UX-02/UX-07 need an equivalent accessibility test file for `ImportOfferCard`/`ImportSetupView`; #293 already ships `ImportOfferCard.test.tsx`/`ImportSetupView.test.tsx` — check whether they already assert accessibility roles/labels (component-test scope) before writing a new a11y-specific file; do not duplicate coverage that already exists in `__tests__/ImportOfferCard.test.tsx`. |
| `src/theme/tokens.ts` | **Reuse only, no change** (both `importJourneyUI.tsx` and `ImportOfferCard.tsx` already import `radius`, `spacing`, `typography`, `brand`, `colors` from the existing token module; no new tokens invented). | None. |

Net: UX-07's mobile deliverable is **almost entirely already-written** inside `importJourneyUI.tsx`; the incremental work is packaging it as the officially-owned shared module and adding/confirming the a11y test file under `import-journey/__tests__/` — not authoring new interaction primitives.

## Conflicts / owner overlaps

- **No file-level conflict** between donors and S6's actual changed set (Finding 1).
- **No divergence conflict** between #293 and #294 on their one shared pair of files (Finding 2) — safe to adopt #293 now for UX-02/07 without waiting on #294 (#294 is self-declared WIP/do-not-merge and belongs to UX-04/05/06, out of this task's scope).
- **Owner overlap to watch, not a conflict today:** `DEPENDENCY_DAG.md`'s "Mobile journey entry UI" lane names one sole writer for `import-journey/{ImportOfferCard,ImportSetupView,importJourneyUI}.tsx` plus the single mounts in `CoachHomeScreen.tsx`, `SettingsScreen.tsx`, `CoachNavigator.tsx`. UX-07 shares `importJourneyUI.tsx` with UX-02 under that same writer — the map already says this, this comparison finds nothing to add or contradict.
- **Navigation file is a single-writer serialization point** (`CoachNavigator.tsx`): UX-02's new Home-card mount and any later UX-03/04/05/06 route changes must go through the same writer sequentially; no evidence in the donors themselves that this is violated (they touch no navigation file).

## Proposed smallest independently executable T2 slices

Both remain T2 as classified in `OFFICIAL_UX_JOB_AND_PR_MAP.md` unless client-side eligibility or role inference is introduced (promotion trigger named explicitly in the map — none found in the donors).

1. **T2 slice A — UX-07 primitive adoption (no product behavior change).** Move `importJourneyUI.tsx` from donor #293 into its owned mobile location verbatim (or reference it directly if #293 lands first); no mount, no screen change. Independently reviewable/testable in isolation since it has no external dependency beyond `theme/tokens.ts` and `components/roman/RomanAvatar` (both already in S6-BASE).
2. **T2 slice B — UX-02 Home entry card shell — DEFERRED to UX-01 T4, not a T2 slice (correction).** Mounting `ImportOfferCard` in `CoachHomeScreen.tsx` requires the account-keyed offer-decision persistence hook, which is UX-01 state/identity work classified T4 in the official register. This slice does not proceed under T2 mobile-presentation execution; it becomes executable only after UX-01 delivers that persistence contract. No Home mount with guessed eligibility or ad hoc persistence is authorized here.
3. **T2 slice C — UX-02 Settings row rename + result-access preservation.** One-string edit at `SettingsScreen.tsx` L368 ("Import my records") plus confirmation that the route still resolves for review access independent of new-start enablement (CQ-03 is unresolved, so this slice should not attempt to implement the distinct capability — just avoid regressing the existing single-flag behavior). Independent of slices A/B; touches a disjoint line of the same already-owned file.
4. **T2 slice D — J3 source-selection restyle.** Swap `ImportDataScreen.tsx`'s picker presentation for `ImportSetupView`'s `step: 'source'`/`'customSource'` variants with real (not donor-stub) callbacks wired to the existing `chosen_platform`/`safeImportLoginUrl` flow already in S6-BASE; explicitly presentation-only, no intent binding (per spec gate: "restyle now... binding the choice to an intent is S7"). Independently testable against the existing `ImportDataScreen` test suite already in S6-BASE.

Each slice above touches a disjoint or already-single-owned file set per `DEPENDENCY_DAG.md`'s parallel-lanes table, so all four can be independently executed T2 units without new cross-lane coordination.

## Genuine T4 boundary promotion

None identified. The map's own promotion trigger for UX-02 — "promote if any client-side eligibility or role inference appears" — is not present in either donor: both #293's `ImportOfferCard` and `ImportSetupView` take eligibility/role/decision entirely as caller-supplied props/callbacks; they compute no eligibility and infer no role. No new T4 boundary (auth, tenancy, PII, money, irreversible migration) is touched by anything in this comparison; the only structural change identified (Settings-row rename, Home-card mount) is copy/layout/one-mount level, consistent with the map's existing T2 classification. No promotion is proposed.

## Account safety / no-phoneStart / no-serverStop confirmation

Nothing in this task executed a phone-initiated Start, a server Stop/cancel request, a live account action, or any network mutation. All GitHub access was exact-SHA read fetches (`git fetch origin <sha>:<local-ref>`) into a bare, working-tree-less object store; no clone into a product directory, no `npm install`, no `jest`/`tsc` run, no product worktree created, no remote push. The isolated object store and this report are the only writes, both confined to `execution/95633079/ux/roman-donor/**`.

## Sources

- [`growth-project-mobile` PR #293](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/293)
- [`growth-project-mobile` PR #294](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/294)
- [`growth-project-mobile` PR #289](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/289)
- [`growth-project-mobile` PR #290](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/290)
- [`growth-project-mobile` PR #291](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/291)
- [`growth-project-mobile` PR #292](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/292)
- Internal: `checkpoint-private/execution/e7d2385c/S6_FINAL_ACCEPTANCE.md`, `checkpoint-private/execution/6c2a68ac/OWNER_SAFETY_ROI_AND_EXECUTION_DOCTRINE.md`, `agent-context/AGENT_RULES.md`, `resume-evidence/ux-planning/OFFICIAL_UX_JOB_AND_PR_MAP.md`, `resume-evidence/ux-planning/DEPENDENCY_DAG.md`, `resume-evidence/ux-planning/journey/CANONICAL_MOBILE_JOURNEY_SPEC.md`, `resume-evidence/ux-planning/journey/STATE_AND_EDGE_CASE_MATRIX.md`, `resume-evidence/ux-planning/journey/CONTRACT_QUESTIONS.md`.
