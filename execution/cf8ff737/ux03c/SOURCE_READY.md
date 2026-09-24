# UX-03c: composition + reason copy — frozen, awaiting relay

Grant: `execution/cf8ff737/UX03C_COMPOSITION_GRANT.md`. Activation condition met: UX-03a accepted at `797be968` (`UX03A_LOCAL_ACCEPTANCE.md`), UX-03b accepted at `519b0122` (`UX03B_LOCAL_ACCEPTANCE.md`).

## Step 1 — Worktree

Created `worktrees/ux03c-compose` on new branch `ux03c-compose` from `797be96806745624e09b949fae10831e52e7078b` via `git worktree add` run from `worktrees/ux03a-paired`. `ux03-j3`, `ux03a-paired`, and `ux03b-correlation` verified untouched (each still clean at its own HEAD) before and after every step below.

## Step 2 — Dependencies

- `package-lock.json` sha256 identical across `ux03a-paired` and `ux03b-correlation`: `840be0b8d5f4ed8272afd20290c8ebf6f6dacc394e6edae4ae5403e9fabe6b69`.
- Disk before copy: 4.6 GiB free. `cp -a` of `node_modules` (768M) from `ux03a-paired` → 3.9 GiB free after, above the 3 GiB floor.
- Verified 0 hardlinked files (`find node_modules -type f -links +1` empty) and all 61 symlinks are relative, internal `node_modules/.bin` links (e.g. `../escodegen/bin/esgenerate.js`) — none target another worktree.

## Step 3 — Composition (merge) commit

`git merge --no-ff 519b01227f2855fc7968994d389094008f222e20` onto `ux03c-compose` (base `797be968`). **Conflict-free** (`Merge made by the 'ort' strategy`, no conflict markers found in `src/`).

- Merge head: `76d3bb4c8259ac3b50f15fe7f28aca1c419a8c34`
- Merge tree: `7b8dc77891f7d209db9974caf8f36854cc7338c2`
- Parents: `797be96806745624e09b949fae10831e52e7078b` (UX-03a), `519b01227f2855fc7968994d389094008f222e20` (UX-03b)
- Author/committer: `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no AI trailers.

**Union proof.** UX-03a changed 5 files vs. J3; UX-03b changed 11 files vs. J3; the two sets are disjoint (empty intersection, confirmed by comm). The merge tree differs from J3 in exactly those 16 paths (confirmed: `git diff --name-only J3 merge` produces the same 16-path set as the sorted union, byte-for-byte list match) — no other path was touched by the merge. For every one of the 16 paths, the merge tree's blob hash was checked against the corresponding child's blob hash at that path and matched exactly (`git rev-parse <child>:<path>` == `git rev-parse <merge>:<path>` for all 16). This proves the merge tree is the true union of both accepted children with no silent divergence.

## Step 4 — Reason copy commit (owned paths only)

Owned paths, exactly as scoped: `src/components/coach/ExtensionPairingPanel.tsx` and its four `__tests__/ExtensionPairingPanel*.test.tsx` files.

**Panel change:**
- Imports `PAIRING_REASON_COPY` directly from `../../hooks/useExtensionPairing` (the real, frozen constant — not a local re-declaration).
- Destructures `reason` from the hook's returned state (previously unused).
- When `status` is `failed` or `expired` and `reason` maps to a `PAIRING_REASON_COPY` entry, renders that entry's `message` and `remedy` verbatim (`reasonCopy.message`, `reasonCopy.remedy`) as the card body/CTA, in place of the generic fallback. Title (`view.title`) is kept from the existing `recoverable[status]` map — the grant specifies only the message + remedy strings, not a title override.
- When `reason` is `null`/`undefined`/unrecognized, `view` falls back unchanged to the pre-existing `recoverable[status]` copy — UX-03a/pre-existing `failed`/`expired` text is byte-identical to before.
- The existing `onPress={retry}` wiring on the CTA button is untouched — no new handler needed, since "Get a new code" (the remedy for both reasons) is exactly what `retry`/`start` already does (mint a fresh code).
- The paired-state block (UX-03a truth content) is untouched — confirmed by diff: only the imports, destructure, and the `recoverable`-consumption block near the failed/expired render changed.
- No nonce, intent id, or locator rendered (grep-confirmed empty).
- `accessibilityLiveRegion="polite"` retained on the failed/expired card (unchanged from UX-03a).
- Added `testID="pairing-reason-message"` on the message `<Text>` node to give the new tests a stable, minimal target (additive, does not remove or rename any existing testID).

**Test changes:**
- All four owned test files' `jest.mock('../../../hooks/useExtensionPairing', ...)` factories now also re-export the real `PAIRING_REASON_COPY` via `jest.requireActual`, since the panel imports it directly from that module (module-level mock must supply it or the import resolves to `undefined`). This is a mechanical mock-completeness fix required by the reason-copy change, not a behavior change to any existing assertion.
- Added 6 new tests to `ExtensionPairingPanel.test.tsx` under a new `describe('ExtensionPairingPanel — contract-named reason copy (UX-03c)')` block: conflict copy renders exact frozen message + remedy; challengeUnavailable copy renders exact frozen message + remedy; null-reason failed keeps existing generic copy; absent-reason (undefined) expired keeps existing generic copy; no nonce/intent-id/locator leak; live region retained. **Every new positive text assertion uses a regex matcher** (`toHaveTextContent(/.../)`), never a bare exact-match string, per the grant's explicit requirement.
- `copy.test.tsx`, `a11y.test.tsx`, `reconstruct.test.tsx` received no new tests — only the mock-factory completeness fix described above. Their own pre-existing assertions (including the two pre-existing bare-string `toHaveTextContent` calls on dedicated single-purpose nodes `pairing-copy-status` and `pairing-support-reference` in `a11y.test.tsx`) are untouched and unaffected, since those tests never set `reason` and the panel's `reason ? ... : null` short-circuit means `PAIRING_REASON_COPY` is never dereferenced when `reason` is falsy.
- Test counts: `.test.tsx` 19 → 25 (+6, exactly the new describe block). `.copy.test.tsx` 5 → 5. `.a11y.test.tsx` 14 → 14. `.reconstruct.test.tsx` 11 → 11.

**Frozen-string verification.** Grant-specified strings confirmed present verbatim in the hook's `PAIRING_REASON_COPY` and referenced (not re-typed) by the panel:
- `conflict.message`: "This setup was started for a different platform, so it can't be reused here."
- `conflict.remedy` / `challengeUnavailable.remedy`: "Get a new code"
- `challengeUnavailable.message`: "Your code is no longer valid; your setup is kept"

**No hook/API/mirror/types change in this working-tree diff.** `git diff --name-only HEAD` (i.e. changes made on top of the merge commit) touches only the 5 owned paths — confirmed by direct grep exclusion check against `hooks/useExtensionPairing.ts`, `api/extensionPairApi.ts`, `storage/importPairingMirror.ts`, `types/extensionImport.ts`. Those four files were already changed by the already-accepted UX-03b merge parent, not by this step.

## Step 5 — Freeze

- Base for the reason-copy diff: merge head `76d3bb4c8259ac3b50f15fe7f28aca1c419a8c34`
- Final write-tree (merge + reason-copy edits): `7a5305e50c4cdeb2b1272ab9c9ace9fb704f67d9`
- Patch: `execution/cf8ff737/ux03c/ux03c-source-ready.patch` (diff of reason-copy edits on top of the merge commit)
- Patch sha256: `10586f016d21fcb4ec6d2ddd0a099ec128c4c980d204a8506fc825a074eaff54`
- Diff stat: `5 files changed, 114 insertions(+), 32 deletions(-)`

## Status

STOP. Frozen and reported. Awaiting the parent's heavy-slot relay before taking `execution/test-validation.lock` or running any gate. No push. No self-acceptance.
