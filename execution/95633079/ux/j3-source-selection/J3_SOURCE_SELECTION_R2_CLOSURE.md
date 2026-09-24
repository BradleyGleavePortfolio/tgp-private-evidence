# J3 Source-Selection — R2 Minimum Closure (Findings A & B)

Status: SOURCE-ONLY r2 delta built and frozen on top of the same base,
addressing exactly the two findings raised by independent T2 source review
`ux_mobile_independent_review_muf47x7e`
(`execution/95633079/ux/j3-review/J3_SOURCE_SELECTION_T2_SOURCE_REVIEW.md`
§§3.7–3.8). No install/copy/tests/hooks/commit/remote executed. r1's own
frozen report/patch are preserved unchanged (not edited, not retracted).

## Pins

- Base commit (unchanged throughout): `716a606e9d23c77a6d705beccb8cefc6e8228284`
- Base tree (unchanged): `430c76a0a686f8756ea0d77f37613d3f85561fb2`
- r1 candidate tree (superseded by r2, kept immutable for record):
  `28b1f26d421054787ff82a60895179cb40ed42d9`
- **r2 candidate tree** (current working-tree snapshot, uncommitted):
  `51c5ec9efda380cc7dd7862ed665cdccf4d0fa47`
- r2 diff: `execution/95633079/ux/j3-source-selection/j3-source-selection-r2.patch`,
  sha256 `714e36a2e01e3cc16a25fa724173f381743d1d2369da065101922bc525e30fdd`,
  986 lines, against the same base as r1.
- r1 diff/patch preserved unchanged at
  `execution/95633079/ux/j3-source-selection/j3-source-selection.patch`
  (sha256 `b23baf5273a8e692f59adb8693be0a840b8879d04d3a9d314a7713aeaba77193`).

## Changed files (same 3 as r1, no additions) + new blob hashes

| File | r1 blob | r2 blob |
|---|---|---|
| `src/screens/coach/ImportDataScreen.tsx` | `31990ab0d97a96ae79a0befbbef7f05c1de6edf2` | `c2a9d54cb9903713af29c77983d67f7df38f98ca` |
| `src/screens/coach/__tests__/ImportDataScreen.test.tsx` | `ea59d57c5d835cc5e61bd3cb44b1451a467d41b1` | `ce6b319c91babfc315209bb6f1fd158458962fd6` |
| `src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx` | `846b811d0d005f5b4ed19904ac266d23ead8c4f3` | `846b811d0d005f5b4ed19904ac266d23ead8c4f3` (unchanged — not touched by r2) |

No file outside this set changed. Donor primitives (`ImportSetupView.tsx`,
`useImportOfferDecision.ts`, `importJourneyUI.tsx`, i18n copy) remain
byte-identical to base — reconfirmed via `git diff --cached --name-only`
during hash computation.

## Closure for Finding A (failed-state reselection)

Restored an explicit, accessible "Choose a different platform" action inside
the `failed` status banner (the screen's original, unmodified shell — same
branch the reviewer inspected in §3.7), reachable only from that phase:

- `onTryAnotherPlatform` — a new callback doing exactly `setState({ phase:
  'intro' })` plus clearing the ephemeral `highlightedSourceId` back to
  `null` so the picker reopens unselected, matching a fresh `intro`. Pure
  local state reset: no navigation call, no new endpoint/flag/storage/timer,
  no change to `selectPlatform`/`openLogin`/the controller.
- Rendered as a `TouchableOpacity` with `accessibilityRole="button"`,
  `accessibilityLabel="Choose a different platform"`, `testID`
  `import-try-another-platform`, directly beneath the failure message inside
  the existing `status`/`statusError`-styled `View` — no new screen, no new
  phase, no new component file.
- This matches the reviewer's own stated minimum-closure text verbatim:
  "add an explicit... action reachable from the `failed` phase that returns
  to `state.phase = 'intro'` (a purely local state reset, no new
  endpoint/flag/storage)."
- Does **not** touch `openingLogin` or `awaitingExtension` — the reviewer's
  Finding A was scoped specifically to `failed` (§3.7); those two phases
  were not flagged and were left untouched.
- No exit/re-entry workaround: the coach never leaves the screen or the
  `ImportDataScreen` component tree; this is an in-place phase transition.
- No pairing/auth redesign: `ExtensionPairingPanel`, `useExtensionPairing`,
  `useCurrentUser`, and `readImportPairingMirror` are untouched (confirmed
  by diff — none of these files or their call sites in `ImportDataScreen`
  changed).

## Closure for Finding B (prerequisite reassurance)

Restored the exact, pre-existing credential-handling disclosure — same copy
string used in the screen's original shell, character-for-character, no new
wording invented — so it renders **before** Continue can ever be pressed:

- Extracted the screen's own existing `prereq`/`prereqText` styled `View`
  (verbatim copy: *"You'll log in with your own account. The Growth Project
  browser extension then asks to start the import — we never see or store
  your other platform's password."*, same `accessibilityRole="summary"`,
  same icon) into a local `sourceSelectionPrereq` JSX constant.
- Composed it **above** `ImportSetupView` in both the `intro` and
  `customUrlEntry` render branches, inside a new `setupShell` wrapper `View`
  (`flex: 1`) that stacks the fixed banner above `ImportSetupView`'s own
  `flex: 1` `KeyboardAvoidingView`/`ScrollView` body.
- This is exactly resolution path (a) the reviewer named: "add it above
  `ImportSetupView` in `ImportDataScreen`'s own JSX for those two phases."
- No new copy invented — the string is byte-identical to the base screen's
  existing disclosure (still also present, unchanged, in the later
  `failed`/`openingLogin`/`awaitingExtension` shell, where it always was).
- No donor authority touched: `ImportSetupView.tsx` itself was not modified
  to add this text; composition happens entirely in `ImportDataScreen.tsx`.
- Accessible semantics preserved: same `accessibilityRole="summary"` region
  as the base screen used, now visible pre-Continue rather than only
  post-commitment.

## What was deliberately NOT changed

- No J4 `computerHandoff` work, no eligibility/identity/intent logic added.
- No re-render of the full picker inside the `failed` branch (would require
  nesting `ImportSetupView`'s own scroll body inside the screen's other
  `ScrollView` shell — the same invalid nested-scroll problem avoided in
  r1); the reviewer's own proposed minimum closure explicitly asked for a
  single explicit action instead, which is what was built.
- No change to `selectPlatform`, `openLogin`, `onCustomUrlChange`,
  `safeImportLoginUrl`, `useImportOfferDecision`, navigation registration,
  or any hook/auth/pairing/storage code.
- No change to `ImportSetupView.tsx` or any other donor/accepted primitive.
- No unrelated cleanup — every line changed in `ImportDataScreen.tsx` traces
  directly to closing Finding A or Finding B.

## Updated/added interaction coverage (not run this mail — source only)

**`ImportDataScreen.test.tsx`** (4 new tests, existing tests untouched
except where they already exercised the affected branches):
- `'shows the credential-handling prerequisite reassurance before any
  platform is chosen'` — asserts the disclosure text renders on first
  mount, in the `intro` phase, before any interaction (Finding B, `source`
  step).
- `'still shows the prerequisite reassurance on the Custom/Other step,
  before Continue'` — same assertion for the `customSource` step, plus
  confirms `openLogin` has not fired yet (Finding B, `customSource` step).
- `'lets the coach choose a different platform after a failed login-open, in
  place'` — drives a real failure (`canOpenURL` false), locates the new
  accessible retry action, presses it, asserts `navigation.goBack` was
  **not** called (proving this is an in-place reset, not an exit/re-entry
  workaround), asserts the intro picker with every catalog platform is back,
  and then drives a full second selection through to the honest
  awaiting-extension state — proving the restored path is not just present
  but actually functional end-to-end (Finding A).
- `'does not offer the retry action outside the failed phase'` — asserts the
  new action is absent both before any interaction and in the
  `awaitingExtension` phase, so it cannot be mistaken for a general-purpose
  escape hatch outside its intended scope.

**`ImportDataScreen.restore.test.tsx`** — unchanged from r1 (blob hash
identical); none of its five tests touch the `failed` phase or the
prerequisite copy, so none were affected by this closure.

No other file in the import-journey/S6 suites was touched or is proposed
for re-run.

## Minimum validation proposal (not executed — source only)

Unchanged in scope from r1's proposal, still confined to the same 3 files:

```
npx tsc --noEmit
npx eslint src/screens/coach/ImportDataScreen.tsx src/screens/coach/__tests__/ImportDataScreen.test.tsx src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx
npx jest src/screens/coach/__tests__/ImportDataScreen.test.tsx src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx --silent --runInBand
```

## No authority conflict

Both closures were achievable entirely within `ImportDataScreen.tsx`'s own
existing render branches, using only local state and the screen's own
pre-existing copy string. No controller, identity, pairing, storage, safeURL,
or donor-primitive authority change was required or made.
