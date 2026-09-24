# UX-03c: UX-03a + UX-03b composition and reason copy (T2)

Parent EXEC-CF8FF737, September 24, 2026.

**Activation condition:** this grant activates only when the parent records UX-03b local acceptance at `519b01227f2855fc7968994d389094008f222e20` from both independent T4 findings. UX-03a is already accepted at `797be96806745624e09b949fae10831e52e7078b` (`UX03A_LOCAL_ACCEPTANCE.md`).

**Scope:** local build only. No push, PR, merge to main, deployment, device or E2E claim.

## Why this is the next constraint

The two accepted children of J3 `9ff749c3` touch disjoint files; the parent verified there is no overlap.

UX-03b adds `reason` (`conflict` or `challengeUnavailable`) and the frozen fact→remedy copy `PAIRING_REASON_COPY` to the hook. Nothing renders that copy yet.

As a result, a coach who hits a 409 nonce conflict, or a 410 code-no-longer-valid, would see the generic failed or expired text instead of the contract-named remedy. That is a product-truth gap, not a safety defect. The composition closes it.

## Tier and route

- **Tier:** T2, with the requested route Claude Sonnet 5 / High (requested setting only, no telemetry claimed).
- **Builder:** `ux_03a_paired_state_truth_build_mufp5bub`, requeued as the sole UX-03c builder.
- **Review:** one independent T2 reviewer.

## Steps

1. **Worktree.** Create `worktrees/ux03c-compose` on the new branch `ux03c-compose` from `797be968`.
   - Use `git worktree add` from `worktrees/ux03a-paired`.
   - Never write in `ux03-j3`, `ux03a-paired` or `ux03b-correlation`.
2. **Dependencies.** Confirm the lock sha is identical across the worktrees, then `cp -a` `node_modules` from `ux03a-paired`.
   - Verify there are no hardlinks or cross-worktree symlinks.
   - Stop if less than 3 GiB of disk would remain. The R PG proof also needs space.
3. **Composition commit.** Make an ordinary `git merge --no-ff 519b0122`.
   - Author and committer: Bradley Gleave <bradley@bradleytgpcoaching.com>. No trailers.
   - The expected result is conflict-free.
   - Record the merge tree. Prove it equals the union by checking that every path's blob matches whichever child changed it.
   - Stop on any conflict.
4. **Reason copy commit.** Owned paths are `src/components/coach/ExtensionPairingPanel.tsx` and its four `__tests__/ExtensionPairingPanel*` tests only.
   - Render `PAIRING_REASON_COPY[reason]` from the hook when `status` is `failed` with `reason: 'conflict'`, and when `status` is `expired` with `reason: 'challengeUnavailable'`.
   - Use the exact frozen strings: "Get a new code" as the remedy action for conflict, and "Your code is no longer valid; your setup is kept" for challenge unavailable.
   - Keep the existing failed and expired copy when `reason` is null.
   - Keep the UX-03a paired-state truth unchanged.
   - Never render the setup nonce, the intent id, or any locator.
   - Retain the A11Y live region and labels.
   - Add tests for both reasons and for the null-reason fallback. Positive text assertions must use substring or regex matching.
   - Do not change the hook, API, mirror or types. If any is needed, stop and report.
5. **Freeze.** Record the write-tree and patch sha.
6. **Gates.** Wait for the parent's heavy-slot relay, then take the lock with flock -n.
   - Run tsc, then lint on the changed paths, then Jest on `ExtensionPairingPanel*`, `ImportDataScreen*`, and the UX-03b owned tests on the composed tree.
   - The first nonzero result stops the run. On a failure, list every failing and masked assertion. No retry.
7. **On pass.** Make an ordinary commit with Bradley as author and committer. Record the no-hooks posture. Export the bundle, patch and receipts to `execution/cf8ff737/ux03c/`, then release the lock and report.

## Acceptance

- The merge commit's tree is the proven union of both accepted children.
- The reason copy renders exactly per the frozen strings.
- Null-reason behavior is unchanged.
- The combined gates pass.
- One independent T2 review accepts.

The scope is mocked component and hook coverage only.

## Out of scope

- G3-AUTH items: locator, revocation, disconnect, account mismatch, capability, code retirement.
- The extension UX-03 surface.
- Any backend change.
