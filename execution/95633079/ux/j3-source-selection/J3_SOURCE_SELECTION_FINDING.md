# UX-03 J3 source-selection: sole writer finding — genuine authority boundary, no product edit landed

Grant: T2 Sonnet 5 / High, sole writes `worktrees/ux03-j3/**` and `execution/95633079/ux/j3-source-selection/**`. Source-only: no install/copy `node_modules`/test/build/commit/browser/remote/deploy, no heavy slot taken. Required reading completed: `CANONICAL_MOBILE_JOURNEY_SPEC.md` (J3/J4), `STATE_AND_EDGE_CASE_MATRIX.md` (B1/E17/E36), `CONTRACT_QUESTIONS.md` (CQ-02, CQ-06), `UX01_ACCOUNT_STATE_HANDOFF.md` (accepted `useImportOfferDecision` contract), `COMPOSITION_ATTESTATION.md` + both independent review attestations (Review A, Review B) for the composed tree.

## Recovery (done)

Isolated standalone clone (`--no-hardlinks --no-checkout`, `origin` removed, 0 remotes) from `worktrees/ux-mobile-composed` at exact accepted head, no public-main/recompose:

| Item | Value |
|---|---|
| Worktree | `worktrees/ux03-j3` |
| Branch | `ux03-j3-source-selection` |
| Base commit | `716a606e9d23c77a6d705beccb8cefc6e8228284` |
| Base tree | `430c76a0a686f8756ea0d77f37613d3f85561fb2` |
| Current HEAD/tree after this session | **unchanged** — `716a606e…` / `430c76a0…` (verified `git status --short` empty) |

## What was consumed (accepted, read-only, per grant)

- `ImportSetupView.tsx` (blob `23584782bcc0f1ee5a31fde06f501c135f98269c`, PR293-adopted, path-identical since `df0ad112`/`716a606e`) — the `'source'`/`'customSource'` step variants.
- `useImportOfferDecision.ts` (blob `ddede7266e3146ecfb5507b75983f565722966ee`, UX-01 accepted) — `{status, decision, recordDecision}` contract, used only for a truthful `onLater`.
- `ImportDataScreen.tsx` (blob `f97adfc53dd88c060cf8731fce620fa782b811ab`) — the real existing controller: `selectPlatform`, `onCustomUrlChange`, `openLogin`, `safeImportLoginUrl`, `ImportFlowState` phases.

## What was built, then withheld (no invented behavior)

I wired the two safe, unambiguous pieces first:
- `onBack` → `navigation.goBack()` (native `SettingsStack.Screen` back; free, truthful, no new dependency beyond `useNavigation`, already the exact pattern `SettingsScreen.tsx` itself uses).
- `onLater` → `void recordDecision('later')` from the accepted `useImportOfferDecision()` hook, discarding the boolean per the contract's own truthfulness rule (a `false` result needs no error UI and no "saved to your account" claim — `UX01_ACCOUNT_STATE_HANDOFF.md` §2), followed by `navigation.goBack()`.

I then attempted to replace the controller's inline platform list + custom-URL box with `ImportSetupView`'s `'source'`/`'customSource'` steps and found a **genuine interaction-authority mismatch**, not a styling difference:

### The concrete issue

`ImportSetupView`'s own asserted contract (`ImportSetupView.test.tsx`, test name `"selects $label only by callback and renders the controlled selection"`) is a **two-step interaction**: tapping a platform radio calls `onSourceChange(id)` **only** — no navigation, no side effect — and a separate, initially-disabled **Continue** button (enabled once `selectedSourceId` is set) is what calls `onContinue()` to advance. The reference journey harness (`ImportJourney.navigation.test.tsx`) confirms `onContinue` for the `'source'` step is what would advance to a `'computerHandoff'` step.

`ImportDataScreen`'s actual controller (`selectPlatform`) is a **one-step interaction**: tapping a platform **immediately** calls `openLogin` (a real side effect — opens the source login URL, transitions to `awaitingExtension`) or, for the custom platform, transitions straight to `customUrlEntry`. There is no intermediate "selected but not yet continuing" state, no Continue button, and — critically — **no `computerHandoff` step exists in `ImportDataScreen` at all.**

Wiring `onSourceChange={selectPlatform}` directly would make the radio tap itself open the login URL, silently defeating `ImportSetupView`'s own tested "select then continue" contract and rendering its Continue button decorative/dead. That is authoring new interaction behavior on a component whose donor tests explicitly assert the opposite behavior — not a presentation-only restyle. The alternative (building the missing intermediate step so `onContinue` has real meaning) is exactly the **J4** "computer handoff precedes source login" reordering that the canonical spec states in its own words is *"a behavioral change to `ImportDataScreen`, not a restyle"*, gated **S7/S11**, explicitly out of this J3 T2 slice's scope (`CANONICAL_MOBILE_JOURNEY_SPEC.md` J3: *"the existing screen can be restyled now... binding the choice to an intent is S7"*; J4: *"This is a behavioral change... not a restyle"*).

### Disposition: left pending, exact need stated

Per the grant's own instruction (*"If this needs authority changes, stop only affected branch and report concrete issue"* / *"already accepted primitives read-only unless a concrete fit issue needs a scoped minimal change"*), I am **not** shipping either of the two false options:
1. Silently repurposing `onSourceChange` to carry `selectPlatform`'s side effect (breaks the donor's own tested contract, invents new component behavior), or
2. Building the missing `computerHandoff` intermediate screen to give `onContinue` real meaning (is J4, S7/S11-gated, not this slice).

**Exact need to unblock J3's full `ImportSetupView` adoption:** a product/UX decision on one of two paths, neither of which this source-only pass should make unilaterally:
- **(a)** Accept a **scoped fork** of the source-selection step that matches the current one-step controller model (radio tap directly triggers `selectPlatform`'s existing side effect, no Continue button, no `computerHandoff` step) — this would be new source (not the donor component verbatim) and needs its own review, but stays entirely within J3's S6-successor gate.
- **(b)** Wait for J4's `computerHandoff` step to be built (S7/S11) so `ImportSetupView`'s full two-step contract has a real destination, and only then adopt it unmodified.

No endpoint, storage, flag, or timer was invented to paper over this gap.

## What was NOT touched (verified)

- `ImportDataScreen.tsx`: reverted to the exact accepted blob `f97adfc53dd88c060cf8731fce620fa782b811ab` after the finding — `git status --short` and `git diff --stat` both empty against `716a606e`/`430c76a0`.
- `ExtensionPairingPanel`, `useExtensionPairing`, `authActions.ts`, `importPairingMirror.ts`, `extensionPairApi.ts`, `featureFlags.ts`, `CoachNavigator.tsx`, `useImportOfferDecision.ts`, `importOfferDecision.ts` — none modified; all remain the accepted composed blobs.
- No Home mount, no eligibility/role inference, no new persistence/server copy/endpoint/flag/timer/intent/origin binding, no protocol/auth rewrite, no source probe, no fake callbacks.
- `openingLogin` / `awaitingExtension` / `failed` presentation in `ImportDataScreen` were read but never edited — fully preserved.
- No install, no `node_modules`, no test run, no build, no browser, no commit, no remote write, no heavy slot taken.

## Frozen exact pins (base/tree/diff/blobs)

| Item | Value |
|---|---|
| Base commit (unchanged) | `716a606e9d23c77a6d705beccb8cefc6e8228284` |
| Base tree (unchanged) | `430c76a0a686f8756ea0d77f37613d3f85561fb2` |
| Diff vs base | **empty** — no commit, no staged change, no working-tree change |
| `ImportDataScreen.tsx` blob (consumed, unmodified) | `f97adfc53dd88c060cf8731fce620fa782b811ab` |
| `ImportSetupView.tsx` blob (consumed, unmodified) | `23584782bcc0f1ee5a31fde06f501c135f98269c` |
| `useImportOfferDecision.ts` blob (consumed, unmodified) | `ddede7266e3146ecfb5507b75983f565722966ee` |

No portable bundle/patch is produced this turn because there is no product delta to freeze — the worktree is byte-identical to its accepted base. If path (a) or (b) above is chosen, the next pass will produce the actual delta, blob accounting, new-interaction-coverage plan, and a proposed Bradley commit message against this same base.

## Minimum validation proposal for whichever path is chosen next (not run; C1/heavy-slot territory)

Once a disposition is chosen and a real edit lands:
```
npx tsc --noEmit
npx jest src/screens/coach/import-journey/__tests__/ --silent --runInBand
npx jest src/screens/coach/__tests__/ImportDataScreen.test.tsx --silent   # if/when such a file exists; none found in this tree today — confirmed absent, not assumed
```
No blanket coach-suite, S6-proof, or `useImportOfferDecision`-suite rerun is proposed: the state hook is unmodified and its own suite already covers it; the presentation suite covers only what changes.

## Sources

- Internal: `resume-evidence/ux-planning/journey/CANONICAL_MOBILE_JOURNEY_SPEC.md` (J3, J4 sections), `resume-evidence/ux-planning/journey/STATE_AND_EDGE_CASE_MATRIX.md` (B1, E17, E36), `resume-evidence/ux-planning/journey/CONTRACT_QUESTIONS.md` (CQ-02, CQ-06), `execution/95633079/ux/account-state/UX01_ACCOUNT_STATE_HANDOFF.md`, `execution/95633079/ux/mobile-composition/COMPOSITION_ATTESTATION.md`, `execution/95633079/ux/mobile-composition-review-a/COMPOSITION_REVIEW_A_ATTESTATION.md`, `execution/95633079/ux/mobile-composition-review-b/COMPOSITION_BINDING_REVIEW_B.md`.
