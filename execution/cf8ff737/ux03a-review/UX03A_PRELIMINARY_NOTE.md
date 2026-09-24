# UX-03a paired-state truth correction — Phase 1 preliminary note (T2 independent review)

Reviewer role: single independent non-builder T2 reviewer. Read-only. No product files edited, `execution/test-validation.lock` not taken, no tests/installs run, no push made.

Authority: `execution/cf8ff737/UX03A_PAIRED_STATE_TRUTH_GRANT.md`; brief `execution/cf8ff737/ux03-handoff-prep/UX03_HANDOFF_READINESS_BRIEF.md` §2, §4; `/tmp/tgp-agent-context/AGENT_RULES.md` (G01–G22).

Source inspected: `/home/user/workspace/worktrees/ux03a-paired`, branch `ux03a-paired-state-truth`, uncommitted working tree matching the frozen diff, vs base `9ff749c35f64068e156400d2ed37c0b144c2d56d`. Builder evidence: `execution/cf8ff737/ux03a/SOURCE_READY.md`, patch `execution/cf8ff737/ux03a/ux03a-source-ready.patch`.

## Frozen-state binding (verified independently, no writes made)

- Base commit confirmed at HEAD of `ux03a-paired-state-truth` before any staged change: `9ff749c35f64068e156400d2ed37c0b144c2d56d` (matches grant Q3 / brief §1 J3-accepted head).
- `git diff --stat` against base: exactly 5 files changed — matches the grant's owned-path list exactly, byte-for-byte matching `SOURCE_READY.md`'s claimed stat block.
- Independently ran `git add -A && git write-tree && git reset` (index-only; no commit, no working-tree mutation) → tree hash `0a876c10aea9e8f8ad3cf2632a394672e6c9e2d3`. **Matches** the frozen tree hash claimed in `SOURCE_READY.md` and in the task's binding target.
- Patch file sha256 independently recomputed: `a9c81d0de612170d6bdb0e7a97beb9f4db92da77242ed9a70eeeac392404fec4`. **Matches** claimed patch sha exactly (also matches the task's cited prefix `a9c81d0d…`).
- `execution/test-validation.lock`: present, empty, untouched by this review (confirmed unchanged before/after inspection).
- No commit exists yet on the branch (`git log` still shows base `9ff749c` at HEAD) — consistent with "source frozen, awaiting heavy-slot relay" status.

## Path-scope check

Only these 5 files are touched, matching the grant's owned-path list exactly:
- `src/components/coach/ExtensionPairingPanel.tsx`
- `src/components/coach/__tests__/ExtensionPairingPanel.test.tsx`
- `src/components/coach/__tests__/ExtensionPairingPanel.copy.test.tsx`
- `src/components/coach/__tests__/ExtensionPairingPanel.a11y.test.tsx`
- `src/components/coach/__tests__/ExtensionPairingPanel.reconstruct.test.tsx`

No other file appears in the diff. `ImportDataScreen.tsx`, `importJourneyUI.tsx`, `importJourneyCopy.ts`, `ImportSetupView.tsx`, `useExtensionPairing.ts`, `extensionPairApi.ts`, `importPairingMirror.ts`, `extensionImport.ts`, `useRosterReviewDelta.ts`, `useReconstructCounts.ts`, and all extension code are absent from `git diff --name-only` — confirmed not touched.

## Behavioral/content checks against brief §2/§4 and grant

1. **Paired headline / checklist.** Renders "Connected to your computer" (line 200) and a checklist with exactly: "Importer available" ✓ (line 202), "Connected to TGP as {identityLabel}" ✓ (line 203–208), "Previous platform" / "Not yet known" (pending, no checkmark; lines 209–216). Matches grant/brief verbatim.
2. **Identity source.** `identityLabel = currentUser?.name || currentUser?.email || 'your account'` (line 196), sourced from `useCurrentUser()` (line 79), matching Q2's default (name, email fallback, never a client-edited field). No client-side-editable field is read.
3. **No roster/reconstruct/running/progress claim.** `useRosterReviewDelta` and `useReconstructCounts` imports are absent from the current panel (confirmed via `grep`). No per-family counts, no delta, no percentage, no "reconstructed so far" rendered. Doc-comment prose mentions these terms only to describe what was *removed* — not rendered/user-visible copy.
4. **"Continue on your computer" has no URL/locator.** Rendered as plain `<Text>` (line 218) with no `href`, no navigation call, no locator string. Test `test.tsx` line 159–165 independently asserts no `https?://` pattern in the paired tree.
5. **6-digit code never enters URL/log/analytics/new storage.** The `code` variable is used only for clipboard copy (`Clipboard.setStringAsync`) and on-screen display in the `waiting` state; it is not referenced in the `paired` block at all (paired state receives `code: null` in all tests) and does not appear in any `track(...)` call — the only analytics call site, `IMPORT_REVIEW_OPENED`, carries only `{ platform: platformId }` (line 101), unchanged from base and confirmed by test assertion (copy.test.tsx / test.tsx "review analytics payload carries ONLY the platform slug").
6. **No retirement/revocation/disconnect claim in any state.** Grepped the full panel source for `retir|revok|disconnect` — only doc-comment occurrences (explaining the invariant), none in rendered strings. All five recoverable states (`expired`, `failed`, `identityUnavailable`, `authExpired`, `unavailable`, `cancelled`) reviewed line-by-line; none asserts extension retirement/revocation/sign-out. `copy.test.tsx` independently pins a `FORBIDDEN_CLAIMS` regex list (revoked/disconnected/retired/signed out/import complete/percentage) against every state including `paired`.
7. **Props/hook usage unchanged.** `interface Props { platformId: string }`, `export default function ExtensionPairingPanel({ platformId }: Props)`, `useExtensionPairing(platformId)`, and the destructure `{ status, code, supportReference, start, retry, cancel }` are byte-identical to the base version (confirmed by direct text diff of those specific lines — only line-number shift from import-block edits, no content change). J3's `ImportDataScreen` consumer is unaffected.
8. **A11Y retained.** `accessibilityLiveRegion="polite"` present on all state containers (minting, waiting, paired, and the shared recoverable layout — lines 117, 130, 198, 281). Digit-by-digit `accessibilityLabel` for the code retained in `waiting` (line 137, unchanged from base). Checklist rows carry semantic icons + text (no icon-only meaning). `a11y.test.tsx` diff is minimal and mechanical (swaps two removed-hook mocks for one added `useCurrentUser` mock) — the actual A11Y assertions in that file are untouched by the diff.
9. **Reconstruct test rewritten, not deleted.** `ExtensionPairingPanel.reconstruct.test.tsx` (171 lines) is fully rewritten to assert *absence*: source-level import-absence checks via `fs.readFileSync` + regex, rendered-tree absence checks for old test ids/copy even under adversarial mocks returning large non-empty state (defence-in-depth: hooks mocked with `delta: 999` and a populated family with count 4137 — panel must still render nothing of it), and one final "what renders instead" check. This is materially real coverage, not a stub.
10. **Tests assert behavior, not weakened.** All four test files inspected in full. `test.tsx` (315 lines) and `copy.test.tsx` (127 lines) both retain/extend prior-style assertions (no 700/800 font weights, live regions, honest-copy regexes) and add new UX-03a-specific assertions (identity fallback, no-URL check, no-count-on-review-CTA, analytics-payload-shape pin). No assertion was loosened or removed without a replacement; net assertion count increased.

## Preliminary assessment

No A or B item identified in Phase 1. The diff appears scoped exactly to the 5 owned paths, the paired-state copy matches the grant's truth constraints exactly, no forbidden claim (roster/reconstruct/running/retirement/revocation/disconnect/URL-locator) is rendered, the 6-digit code handling is unchanged and safe, props/hook usage is unchanged, A11Y attributes are retained, and the reconstruct test was genuinely rewritten with adversarial-mock defence-in-depth rather than deleted or weakened.

One **C-level observation** (record only, no new work): the word "paired" still appears as an internal state-machine literal (`status === 'paired'`) and in testIDs (`pairing-paired`, `pairing-check-*`) — this is not a rendered/user-facing string and is outside the grant's actual constraint (which forbids the *displayed* headline "Paired", not the enum/testID). No closure needed.

This note is preliminary, bound to the *frozen, uncommitted* working tree. Phase 2 will bind the same finding to the actual commit head once gates run and a commit lands, and will issue the final ACCEPT/NOT ACCEPT finding.
