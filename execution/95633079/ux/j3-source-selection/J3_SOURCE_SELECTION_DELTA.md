# J3 Source-Selection — Bounded T2 Delta (parent disposition (a))

Status: SOURCE-ONLY delta built and frozen on the exact accepted composed
base. No install/build/typecheck/test/lint/commit/remote/deploy/heavy-slot
executed this mail, per explicit instruction. Working tree holds the edits
uncommitted; nothing staged.

## Pins

- Base commit (unchanged): `716a606e9d23c77a6d705beccb8cefc6e8228284`
- Base tree (unchanged): `430c76a0a686f8756ea0d77f37613d3f85561fb2`
- Candidate tree if this delta were committed as-is (`git write-tree` against
  the staged snapshot of exactly these 3 files, no commit made):
  `28b1f26d421054787ff82a60895179cb40ed42d9`
- Worktree: `worktrees/ux03-j3`, branch `ux03-j3-source-selection`, standalone
  clone (`--no-hardlinks --no-checkout`, 0 remotes) of `worktrees/ux-mobile-composed`.
- Diff: `execution/95633079/ux/j3-source-selection/j3-source-selection.patch`
  (unified diff of the 3 changed files against base), sha256
  `b23baf5273a8e692f59adb8693be0a840b8879d04d3a9d314a7713aeaba77193`, 875 lines.

## Changed files (3 only) + new blob hashes

| File | New blob SHA-1 |
|---|---|
| `src/screens/coach/ImportDataScreen.tsx` | `31990ab0d97a96ae79a0befbbef7f05c1de6edf2` |
| `src/screens/coach/__tests__/ImportDataScreen.test.tsx` | `ea59d57c5d835cc5e61bd3cb44b1451a467d41b1` |
| `src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx` | `846b811d0d005f5b4ed19904ac266d23ead8c4f3` |

No other file changed. Donor primitives read-only and untouched: confirmed
`git diff --cached --name-only` (during hash computation) listed only these
three paths; `ImportSetupView.tsx`, `useImportOfferDecision.ts`,
`importJourneyUI.tsx`, and the i18n copy file (`en.json`) are byte-identical
to base.

## What changed, and why it satisfies the parent's chosen resolution (a)

The prior finding (`J3_SOURCE_SELECTION_FINDING.md`) identified a genuine
mismatch: the donor `ImportSetupView` has a tested two-step contract
(highlight via `onSourceChange`, confirm via a separate `onContinue`), while
`ImportDataScreen`'s real controller (`selectPlatform`) was one-step
(highlight and side-effect fused). Parent chose resolution (a): a bounded
explicit J3 variant matching the real one-step controller, built as a small
companion using the donor's *existing, unmodified* primitive — not a fork,
not a copy, not J4's `computerHandoff` reorder.

Concretely, in `ImportDataScreen.tsx`:

- Added a new **ephemeral, screen-local** `highlightedSourceId` state
  (`useState<string | null>`) — same category as the pre-existing
  `intro`/`customUrlEntry` UI-only phases already permitted by the state
  matrix (non-secret, cleared on unmount, gates no business logic, not a new
  `ImportFlowState` phase). It exists solely so `ImportSetupView`'s
  controlled radio group has somewhere to hold a highlight before the coach
  confirms.
- `ImportSetupView` is rendered **exactly as exported**, for both its
  `step: 'source'` and `step: 'customSource'` variants, with its **default
  two-step contract fully preserved**:
  - `onSourceChange` → `setHighlightedSourceId(id)` only. Pure state, no
    side effect — matches the donor's own tested meaning
    (`ImportSetupView.test.tsx`: "selects only by callback").
  - `onContinue` (`step: 'source'`) → calls the real, pre-existing
    `selectPlatform(highlightedSourceId)` — unchanged function, unchanged
    signature, unchanged behavior (still transitions to `customUrlEntry` for
    Custom/Other, still calls `openLogin` directly for a catalog platform).
    Continue is disabled by the donor's own `canContinue` logic until a
    selection exists, so this can never fire with a null id (defensive
    guard kept anyway).
  - `onContinue` (`step: 'customSource'`) → calls the real, pre-existing
    `openLogin(CUSTOM_PLATFORM_ID, state.url)` — the exact action the old
    "Open login page" button fired, gated by the same donor `canContinue` /
    `safeImportLoginUrl` validity check the screen already relied on.
  - `onBack` → `navigation.goBack()`, real existing native-stack navigation
    (same `useNavigation<NavigationProp<ParamListBase>>()` pattern used
    verbatim elsewhere in the codebase, e.g. `BlockedUsersScreen.tsx`,
    `ContactView.tsx`).
  - `onLater` → awaits the accepted UX-01 `recordDecision('later')` from
    `useImportOfferDecision()`, then navigates back. The boolean result is
    discarded without any "saved" or error claim, honoring the contract's
    own truthfulness rule (a `false` result — disabled/unresolved/failed —
    needs no error UI; the offer is simply re-asked next entry). The write
    is awaited (not fire-and-forgotten) before `goBack()`, the more
    conservative sequencing, though the hook's own internal write-chain
    refs make the write resilient to unmount regardless.
- **No `computerHandoff` step was built.** J4's reorder remains out of
  scope; the screen still has exactly its five pre-existing phases
  (`intro`, `customUrlEntry`, `openingLogin`, `awaitingExtension`, `failed`).
- `openingLogin`/`awaitingExtension`/`failed` render paths, `ExtensionPairingPanel`
  mounting, the process-restart-continuity peek effect, `safeImportLoginUrl`
  guard, analytics event names/payloads/order, and pairing/storage/hooks/auth
  are all **byte-identical to base** — confirmed by diff (only the JSX for
  the `intro`/`customUrlEntry` render branches, the new callbacks, and the
  now-dead inline-list styles were touched).
- Removed only what became dead code as a direct, minimal consequence of the
  swap: the inline `TouchableOpacity`-based platform list and custom-URL
  box JSX (fully superseded by `ImportSetupView`), the now-unused
  `TextInput`/`IMPORT_PLATFORMS` imports, and their now-orphaned style keys
  (`sectionHeader`, `row`, `rowLabel`, `customBox`, `input`, `primaryBtn*`,
  `hint`). `findImportPlatform`, `CUSTOM_PLATFORM_ID`, and `Ionicons` remain
  in use and untouched.
- Structural note: `ImportSetupView` owns its own `KeyboardAvoidingView`/
  `ScrollView` (confirmed via its own test harness, which always mounts it
  standalone, never nested). Nesting it inside the screen's pre-existing
  outer `ScrollView` would be an invalid nested-scroll layout, not a valid
  presentation choice, so the `intro`/`customUrlEntry` phases now return
  `ImportSetupView` directly as the full screen body; the other three
  phases keep the screen's original `ScrollView` shell verbatim.

## No invented authority

- No new endpoint, storage key, flag, timer, intent, or origin binding.
- No eligibility/role inference; no Home mount.
- No protocol/auth rewrite; no source probe; no fake callbacks.
- `romanEnabled={featureFlags.romanChat}` reuses the exact existing
  app-wide flag used identically elsewhere in the codebase — not a new flag.
- Controller (`openLogin`, `selectPlatform`, `onCustomUrlChange`),
  pairing (`ExtensionPairingPanel`, `useExtensionPairing`), identity
  (`useCurrentUser`), and storage (`readImportPairingMirror`) authority is
  fully intact and untouched.

## New/updated interaction coverage (not run this mail — source only)

Both directly-affected test files were updated to target the new render
(their prior testIDs on the removed inline list/box no longer exist); no
other test file was touched.

**`src/screens/coach/__tests__/ImportDataScreen.test.tsx`** (rewritten,
preserves every pre-existing behavioral guarantee, re-expressed through the
donor's two-step radio+Continue interaction, plus new J3-specific cases):
- Intro renders a radio (accessibility role `"radio"`, correct
  checked/selected state) for every catalog platform; Continue starts
  disabled and only enables after a highlight (pure `onSourceChange`, no
  side effect — verified no `openURL`/telemetry fires on highlight alone).
- For every catalog platform with a login URL: highlighting then pressing
  Continue opens the exact safe https URL via `Linking`, in the correct
  `canOpenURL` → `openURL` order, with `IMPORT_PLATFORM_SELECTED` firing
  before `IMPORT_LOGIN_OPENED` (funnel order preserved).
- Awaiting-extension state renders and never claims completion; open and
  openURL-throw failures still recover to the honest `failed` message and
  still tag `IMPORT_LOGIN_OPEN_FAILED` with the correct reason.
- Custom/Other: reveals the field, gates Continue on `safeImportLoginUrl`
  validity exactly as before (valid enables, invalid/insecure shows the
  donor's own `"Enter a valid public HTTPS address."` alert and keeps
  Continue disabled, re-editing to invalid re-disables, editing back to
  empty re-disables and clears the alert), and Continue opens the exact
  entered URL via the real `openLogin`.
- Telemetry payload hygiene (no tokens/URLs/codes) preserved verbatim.
- Accessibility: header role on the source-selection title, polite live
  region on status, no premature status region, no completion/progress
  language anywhere in the rendered tree.
- New: **Back** calls `navigation.goBack()` exactly once and never touches
  `recordDecision`. **Later** calls the accepted `recordDecision('later')`
  and then `navigation.goBack()`, from both the `source` and `customSource`
  steps, and never opens a URL (proving Later cannot silently carry a
  selection through as a side effect). A truthful `false` resolution from
  `recordDecision` is asserted to produce no "saved" or error/failure text
  anywhere in the tree.

**`src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx`** (one
test updated; the other four were already unaffected — they never
interacted with the removed inline list):
- `'never overrides a phase the coach already moved to while the peek was in
  flight'` — the interaction that used to press the old
  `import-platform-custom` testID now highlights "Custom / Other" and
  confirms with "Continue" (the same two-step contract exercised
  everywhere else), then asserts the custom-URL field is still present and
  unclobbered after the slow mirror peek resolves. Assertion intent
  (in-flight peek must not override a phase the coach already moved to) is
  unchanged.

No `ImportSetupView.test.tsx`, `useImportOfferDecision` test suite, or any
other file in the 69-test import-journey directory was touched or is
proposed to be re-run; both remain the responsibility of their own accepted
owners.

## Minimum validation proposal (not executed — source only, per this mail)

Scoped strictly to the 3 changed files, not the full import-journey or S6
suites:

1. `npx tsc --noEmit` (repo-wide is the only supported invocation, but no
   other file changed, so no other diagnostics should move).
2. `npx eslint src/screens/coach/ImportDataScreen.tsx src/screens/coach/__tests__/ImportDataScreen.test.tsx src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx`
   (relevant-file lint only).
3. `npx jest src/screens/coach/__tests__/ImportDataScreen.test.tsx src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx --silent --runInBand`
   (the two directly-affected suites only — not the full
   `import-journey/__tests__/` directory, not a blanket 69-test or S6/state
   replay).

All three require the accepted mobile environment's `node_modules` (already
provisioned by the accepted heavy-slot grant this mail is told to reuse —
"Later runtime will reuse matching accepted mobile environment, not npm
ci"); none were run this mail.

## Proposed Bradley commit message (not committed this mail)

```
feat(importer): restyle J3 source selection onto ImportSetupView

Present the source-selection step (catalog picker + Custom/Other URL entry)
through the accepted ImportSetupView primitive, preserving its default
two-step contract (highlight via onSourceChange, confirm via Continue) and
wiring Continue to the real existing selectPlatform/openLogin controller
actions. Back uses native navigation; Later truthfully records the UX-01
'later' decision before navigating back. No behavioral change to
openingLogin/awaitingExtension/failed, pairing, storage, or identity
handling, and no computerHandoff step (J4, out of scope).
```

Author/committer to be `Bradley Gleave <bradley@bradleytgpcoaching.com>`
when/if a commit is authorized; no AI trailers or co-author lines, per
standing instruction.

## No authority conflict this mail

Nothing required an authority change to complete this bounded slice. The
prior finding's blocking issue is resolved per the parent's own chosen
path (a), using only the donor's existing exported primitive and the
screen's existing controller functions.
