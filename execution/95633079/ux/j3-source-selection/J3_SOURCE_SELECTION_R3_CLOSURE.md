# J3 Source-Selection — R3 Additive Closure (missing awaitingExtension reselection)

Status: SOURCE-ONLY r3 delta, additive on top of r2, addressing the one
outstanding parent-grant clause flagged after r2 receipt: "preserve the
preexisting post-login reselection affordance where the removed base
picker allowed it." r1 and r2 are unchanged and preserved as historical
pins; this document does not retract or edit either. No
install/copy/tests/hooks/commit/remote executed.

## Why r3 was needed

The base screen kept every platform row reachable not only alongside the
`failed` banner (closed in r2) but also alongside the pairing panel in
`awaitingExtension` — the base's own test guarantee was "keeps every
platform row reachable after opening a login (coach can switch)". r2's
"Choose a different platform" action was added only to the `failed` branch,
so a coach already past `openingLogin` and into `awaitingExtension` still
had no in-screen way to switch platforms. This was explicitly named in the
original parent closure grant (Mail 8) and was not new scope — r2 simply
missed applying the closure to the second location the base guarantee
covered.

## Pins

- Base commit/tree (unchanged throughout): `716a606e9d23c77a6d705beccb8cefc6e8228284`
  / `430c76a0a686f8756ea0d77f37613d3f85561fb2`
- r1 candidate tree (unchanged, historical): `28b1f26d421054787ff82a60895179cb40ed42d9`
- r2 candidate tree (unchanged, historical): `51c5ec9efda380cc7dd7862ed665cdccf4d0fa47`
- **r3 candidate tree** (current working-tree snapshot, uncommitted):
  `4e139900f0f10a3c63bc0baf150257dd0ce8fd60`
- r3 diff: `execution/95633079/ux/j3-source-selection/j3-source-selection-r3.patch`,
  sha256 `9dd31ed6ceda1ddaa0ee7eedbbf15eef2bc3b7335479a4d3d24f9f6c327456c9`,
  1042 lines, against the same base as r1/r2.
- r1 and r2 diffs/patches preserved unchanged at their original paths.

## Changed files (same 3 as r1/r2, no additions)

| File | r2 blob | r3 blob |
|---|---|---|
| `src/screens/coach/ImportDataScreen.tsx` | `c2a9d54cb9903713af29c77983d67f7df38f98ca` | `92ed52f5cc108f3a098062364d6af793cbb8e2b7` |
| `src/screens/coach/__tests__/ImportDataScreen.test.tsx` | `ce6b319c91babfc315209bb6f1fd158458962fd6` | `8922c27a73ebae2281f1790787049bc67d9cedc8` |
| `src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx` | `846b811d0d005f5b4ed19904ac266d23ead8c4f3` | `846b811d0d005f5b4ed19904ac266d23ead8c4f3` (unchanged — still not touched) |

No file outside this set changed; reconfirmed via `git diff --cached
--name-only` filtered against the two touched paths (empty result).

## The closure

Reused `onTryAnotherPlatform` — the exact same pure local-reset callback
added in r2 for `failed` (`setHighlightedSourceId(null); setState({ phase:
'intro' })`), with **no changes to the callback itself** — and added the
identical `TouchableOpacity` (same `accessibilityRole="button"`, same
`accessibilityLabel="Choose a different platform"`, same `testID`
`import-try-another-platform`, same `styles.retryLink`/`retryLinkText`)
inside the `awaitingExtension` branch, directly beneath the existing
`ExtensionPairingPanel`.

- **No new state.** No new flag, timer, endpoint, or ref was introduced —
  literally one more JSX usage of the same handler and the same styles
  already defined in r2.
- **No pairing/auth change.** `ExtensionPairingPanel`, `useExtensionPairing`,
  `useCurrentUser`, and the pairing-mirror storage are untouched; pressing
  the new action does nothing pairing-specific — it only resets
  `ImportDataScreen`'s own local `phase`/`highlightedSourceId` state, which
  naturally unmounts the keyed `ExtensionPairingPanel` the same way any
  other phase transition already does (the base's own comment notes the
  panel is `key`ed specifically so a platform change remounts it cleanly).
- **No new race.** The reset is a synchronous `setState` call with no new
  async operation, promise, or subscription; it introduces nothing that
  could race with the pairing hook's own polling/lifecycle, which is
  unmodified and was already exercised by existing pairing-panel-owned
  tests (not part of this file's scope).
- **`openingLogin` deliberately left as-is.** Per the parent's own
  instruction ("No need restore picker while opening pending merely for
  completeness unless existing flow requires it"), no action was added to
  the transient `openingLogin` phase: no prior base test required
  reselection to be reachable there, and it resolves to `awaitingExtension`
  or `failed` within moments on its own, both of which now carry the
  action.

## Updated/added interaction coverage (not run this mail — source only)

**`ImportDataScreen.test.tsx`**:
- Renamed/refocused the r2 "outside the failed phase" negative test to
  `'does not offer the retry action before any interaction (intro/customSource
  steps)'` — this is now factually accurate (the action legitimately exists
  in two phases, not zero, post-`failed`), and still proves no reselection
  affordance exists before any platform interaction has happened.
- Added `'lets the coach choose a different platform from the
  awaiting-extension state too, in place'` — the direct successor to the
  base's removed guarantee. Drives a real successful `openLogin` through to
  `awaitingExtension`, locates the same accessible retry action, presses
  it, asserts `navigation.goBack` was **not** called (in-place, no
  exit/re-entry), asserts the full intro picker is back, then drives a
  second, different real selection (Everfit) through to a second successful
  `awaitingExtension`/`openUrl` call — proving the path is not just present
  but functionally correct end-to-end, matching the "successful-open→reselect"
  assertion the parent grant asked to restore.
- Added `'does not offer the retry action during the transient opening-login
  state'` — holds `canOpenURL` pending via a manually-released promise,
  confirms the action is absent while `state.phase === 'openingLogin'`
  specifically (matching the parent's explicit "no need to restore picker
  while opening-pending" guidance), then releases the promise to avoid an
  unresolved-act warning/leak in the test itself.

**`ImportDataScreen.restore.test.tsx`** — unchanged from r1/r2 (blob hash
identical); none of its tests touch `failed`/`awaitingExtension`/the retry
action, so none were affected.

## Minimum validation proposal (not executed — source only)

Unchanged in scope from r1/r2, still confined to the same 3 files:

```
npx tsc --noEmit
npx eslint src/screens/coach/ImportDataScreen.tsx src/screens/coach/__tests__/ImportDataScreen.test.tsx src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx
npx jest src/screens/coach/__tests__/ImportDataScreen.test.tsx src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx --silent --runInBand
```

## No authority conflict

The r3 closure required no controller, identity, pairing, storage, safeURL,
or donor-primitive authority change — it reuses the exact r2 handler and
r2 styles in one additional, already-mutually-exclusive render branch.

## Reviewer note

Per parent instruction, review is not being requested again separately for
r2 vs r3: this r3 freeze is additive and final: the reviewer
(`ux_mobile_independent_review_muf47x7e`) should assess the combined r1 → r2
→ r3 state as a single closure package against both Finding A and Finding B
plus this awaitingExtension completeness clause, using r3's tree
(`4e139900f0f10a3c63bc0baf150257dd0ce8fd60`) as the candidate to bind.
