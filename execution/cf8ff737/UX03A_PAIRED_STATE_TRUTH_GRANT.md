# UX-03a paired-state truth correction — mobile build grant

Parent EXEC-CF8FF737, September 24, 2026. This grant is disposed from `ux03-handoff-prep/UX03_HANDOFF_READINESS_BRIEF.md` §4. It is a local build only. It does not authorize a remote push or merge, a deployment, or any customer claim.

## Tier and route

**T2.** The change is presentation-only: one panel, with no change to auth, storage, network, contract, flags or analytics payloads.

Requested route: Claude Sonnet 5 / High. This is the requested setting only, not claimed telemetry.

The task is promoted to T4, and the builder must stop and report, if any change becomes needed to any of:

- `useExtensionPairing`
- the pairing mirror
- the API module
- the types module
- analytics payloads
- any new truth claim beyond `pair/status`

## Sole writer and owned areas

- Builder: this dispatch's single worker.
- New worktree `worktrees/ux03a-paired`, on a new branch `ux03a-paired-state-truth` from accepted J3 head `9ff749c35f64068e156400d2ed37c0b144c2d56d`. Create it with `git worktree add` from the `worktrees/ux03-j3` repository.
  - Do not modify, check out in or reset `worktrees/ux03-j3`. It is preserved J3 acceptance evidence.
- Dependencies: make a physical copy of `worktrees/ux03-j3/node_modules` with `cp -a`. Do not hardlink, symlink or run `npm install`.
  - Before copying, record the `package-lock.json` sha at both heads. They must be identical, because the J3 lock is unchanged.
  - Record free disk space. Stop if less than 3 GiB would remain.
- Product paths, and only these:
  - `src/components/coach/ExtensionPairingPanel.tsx`
  - `src/components/coach/__tests__/ExtensionPairingPanel.test.tsx`
  - `src/components/coach/__tests__/ExtensionPairingPanel.copy.test.tsx`
  - `src/components/coach/__tests__/ExtensionPairingPanel.a11y.test.tsx`
  - `src/components/coach/__tests__/ExtensionPairingPanel.reconstruct.test.tsx`. Rewrite this one to assert that the roster and reconstruct claims are absent. Do not silently delete it.
- Evidence: `execution/cf8ff737/ux03a/**`.

Everything else is not owned. That includes `ImportDataScreen.tsx` and its tests, `importJourneyUI.tsx`, `importJourneyCopy.ts`, `ImportSetupView.tsx`, the hook, API, mirror, types and roster/reconstruct hooks, and any extension code. Reuse the presentation primitives and tokens without editing them.

## Behavior

Follow brief §4 exactly, with the parent answering the routine questions as follows:

- **Q1:** Keep "Review clients" as a neutral secondary link, with no count or progress claim.
- **Q2:** Server-owned identity comes from `useCurrentUser`. Show the display name, falling back to email. Never use client-edited fields.
- **Q3:** Use the J3-accepted base named above.

The `paired` state:

- Show "Connected to your computer".
- Show the truthful checklist:
  - Importer available ✓
  - Connected to TGP as the server-owned identity ✓
  - Previous platform: Not yet known
- The primary action is the instructional "Continue on your computer", with no URL or locator.

Other statuses keep their behavior. Copy changes only where needed to follow the fact → remedy → retained-setup pattern, and must make no retirement, revocation or disconnect claim. The props interface and hook usage stay unchanged. The 6-digit code must never enter a URL, log, analytics event or new storage.

## Gates

Author the source first; this needs no slot. Then report the frozen diff and tree to the parent and **wait for a heavy-slot relay**. The canonical lock, `execution/test-validation.lock`, is held for B v5 and must not be taken early.

Once the slot is granted, work under nonblocking flock:

1. `tsc --noEmit`
2. Lint on the changed paths
3. Jest on the four `ExtensionPairingPanel*` tests plus the existing `ImportDataScreen*` tests as an unchanged-consumer regression

After the gates:

- Run a grep proof that "Paired", "reconstructed so far", "since you started this import" and "running" no longer appear in the paired branch.
- Confirm the panel no longer imports `useRosterReviewDelta` or `useReconstructCounts`.
- Make an ordinary commit with author and committer both `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no AI trailers and no amend. The mobile repo has no configured hooks, so none are claimed.
- Export the commit as a bundle and a patch.

The first nonzero result stops the work. Preserve it, and do not retry automatically.

## Acceptance

One independent non-builder review of the exact head, gate receipts and diff scope, done after the build. No rendered-device, browser or E2E proof is claimed, and there is no under-three-minute claim. A11Y-01, A11Y-02 and A11Y-07 must be retained for this panel.
