# UX-03a paired-state truth correction — source ready

Parent EXEC-cf8ff737. Grant: `execution/cf8ff737/UX03A_PAIRED_STATE_TRUTH_GRANT.md`. Behavior spec: `execution/cf8ff737/ux03-handoff-prep/UX03_HANDOFF_READINESS_BRIEF.md` §2, §4. Rules: `/tmp/tgp-agent-context/AGENT_RULES.md` (G01–G22).

This is a **source-authoring freeze only**. No slot taken, no build/test/lint gates run yet, no commit made. `execution/test-validation.lock` was not touched (B v5 retains it). Waiting for parent's heavy-slot relay per the grant's gate sequencing.

## Worktree / base

- New worktree: `/home/user/workspace/worktrees/ux03a-paired`
- New branch: `ux03a-paired-state-truth`
- Created via `git -C /home/user/workspace/worktrees/ux03-j3 worktree add /home/user/workspace/worktrees/ux03a-paired -b ux03a-paired-state-truth 9ff749c35f64068e156400d2ed37c0b144c2d56d`
- Base commit (J3-accepted head, per grant Q3 and brief §1): `9ff749c35f64068e156400d2ed37c0b144c2d56d`
- `worktrees/ux03-j3` was never checked out, reset, or modified. Verified clean at `9ff749c` (`git status` → "nothing to commit, working tree clean") both before and after this worktree's creation.

## Dependencies

- `package-lock.json` sha256 verified identical at both worktrees before copy:
  - `worktrees/ux03-j3/package-lock.json`: `840be0b8d5f4ed8272afd20290c8ebf6f6dacc394e6edae4ae5403e9fabe6b69`
  - `worktrees/ux03a-paired/package-lock.json` (post-checkout, same commit): `840be0b8d5f4ed8272afd20290c8ebf6f6dacc394e6edae4ae5403e9fabe6b69`
  - Git blob hash for `package-lock.json` at `9ff749c` in both worktrees: `6c56385d33db5fa703f8dc37a78381b8e2ba89a1` (identical)
- Disk free before copy: 7,449,612,288 bytes (~6.94 GiB). `node_modules` size: 768 MiB. Comfortably above the 3 GiB stop-floor.
- Disk free after copy: 5,718,925,312 bytes (~5.32 GiB) — still above the 3 GiB floor.
- Copy method: `cp -a /home/user/workspace/worktrees/ux03-j3/node_modules /home/user/workspace/worktrees/ux03a-paired/node_modules` (physical copy). No `npm install` run.
- Verified no hardlinks: sampled file `node_modules/eslint-plugin-react-hooks/README.md` has different inode numbers in source (820784) vs. destination (991256).
- Verified no cross-worktree symlinks: 61 symlinks exist under the copied `node_modules/.bin/`, all relative and internal to npm's own bin-linking convention (e.g. `.bin/is-docker -> ../is-docker/cli.js`); zero symlinks reference `ux03-j3` or any path outside the new worktree.

## Owned paths touched (exactly the five in the grant, nothing else)

```
 src/components/coach/ExtensionPairingPanel.tsx                          | 266 +++++++--------------
 src/components/coach/__tests__/ExtensionPairingPanel.a11y.test.tsx      |   7 +-
 src/components/coach/__tests__/ExtensionPairingPanel.copy.test.tsx      |  39 ++-
 src/components/coach/__tests__/ExtensionPairingPanel.reconstruct.test.tsx | 257 ++++++++------------
 src/components/coach/__tests__/ExtensionPairingPanel.test.tsx           |  96 ++++----
 5 files changed, 270 insertions(+), 395 deletions(-)
```

`git diff --stat` confirms these are the only five files touched, matching the grant's owned-path list exactly. No file outside this list was created, modified, or deleted. `useRosterReviewDelta.ts`, `useReconstructCounts.ts`, `ImportDataScreen.tsx`, `importJourneyUI.tsx`, `importJourneyCopy.ts`, `ImportSetupView.tsx`, `useExtensionPairing.ts`, `extensionPairApi.ts`, `importPairingMirror.ts`, `extensionImport.ts`, and all extension code remain untouched — reused by reference only, never edited.

## Behavior summary (brief §4 + grant Q1–Q3)

- `paired` state: headline "Connected to your computer" (replaces "Paired"/roster/reconstruct copy). Truthful checklist: Importer available ✓ / Connected to TGP as `<useCurrentUser name, falling back to email>` ✓ / Previous platform: "Not yet known". Primary action is the instructional "Continue on your computer" text, no URL/locator. Secondary "Review clients" retained as a neutral link (Q1: kept, no count).
- Server-owned identity (Q2): `useCurrentUser().name || useCurrentUser().email`, never a client-edited field.
- `useRosterReviewDelta` and `useReconstructCounts` imports and their rendered sections (`ReconstructCountsSection`, `ReconstructFamilyRow`) are removed entirely from the panel.
- Other statuses (`minting`, `waiting`, `expired`, `authExpired`, `unavailable`, `failed`, `cancelled`, `identityUnavailable`) unchanged in behavior. `expired` copy rewritten to the fact → remedy → retained-setup pattern: "This code expired" / "Your setup is kept — get a new code to continue." No other state's copy needed changes to satisfy that pattern (none made a retirement/revocation/disconnect claim already).
- Props interface `{ platformId }` and `useExtensionPairing(platformId)` destructure (`status, code, supportReference, start, retry, cancel`) are byte-for-byte unchanged — J3's `ImportDataScreen` consumer is unaffected.
- Analytics: `track(AnalyticsEvents.IMPORT_REVIEW_OPENED, { platform: platformId })` call site and payload shape unchanged.
- The 6-digit code path (mint, display, copy) is unchanged from the accepted S6 source; it does not enter any URL, log, analytics event, or new storage in this diff.
- `ExtensionPairingPanel.reconstruct.test.tsx` was rewritten (not deleted) per the grant, now asserting: (a) source-level import absence of both retired hooks, (b) the rendered `paired` tree contains none of the retired test ids or copy even when the retired hooks are mocked to return large non-empty state (defence in depth), (c) the replacement checklist/confirmation actually renders.

## Promotion-trigger check (none fired)

Grant T2→T4 triggers and their status in this diff:
- `useExtensionPairing`: not touched (confirmed via `git diff --name-only`).
- pairing mirror (`importPairingMirror.ts`): not touched.
- API module (`extensionPairApi.ts`): not touched.
- types module (`extensionImport.ts`): not touched.
- analytics payloads: unchanged call site, unchanged shape (`{ platform: platformId }`).
- new truth claim beyond `pair/status`: none — the paired checklist states only the redemption fact (implicit in reaching `paired`) and the server-owned identity from `useCurrentUser`; "Previous platform: Not yet known" is an explicit non-claim.

No promotion trigger fired. Remaining T2.

## Grep / import-absence proofs

Forbidden strings checked against `ExtensionPairingPanel.tsx` with comments stripped (so only executable/rendered content counts — the words still appear in explanatory doc comments describing what was removed, which is expected):

| Forbidden string | Present in executable/string content? |
|---|---|
| `Paired` | No |
| `reconstructed so far` | No |
| `since you started this import` | No |
| `running` | No |

Import-absence proof:

```
$ grep -n "useRosterReviewDelta\|useReconstructCounts" src/components/coach/ExtensionPairingPanel.tsx
(no matches)
```

The panel no longer imports `useRosterReviewDelta` or `useReconstructCounts`.

## Base / tree / patch identity

- Base commit: `9ff749c35f64068e156400d2ed37c0b144c2d56d`
- `write-tree` hash of the working tree with all five owned-path changes staged (index reset immediately after, no commit made): `0a876c10aea9e8f8ad3cf2632a394672e6c9e2d3`
- Saved patch: `execution/cf8ff737/ux03a/ux03a-source-ready.patch` (`git diff` output against base, 956 lines)
- Patch sha256: `a9c81d0de612170d6bdb0e7a97beb9f4db92da77242ed9a70eeeac392404fec4`

## Status

Source frozen. Working tree left uncommitted and dirty on branch `ux03a-paired-state-truth`, exactly matching the above patch/tree hash. **Stopping here per the grant** — no commit, no `execution/test-validation.lock` slot taken. Awaiting parent's heavy-slot relay before running `tsc --noEmit`, lint, and the Jest gates (grant step 5).
