# UX-03b closure-2 grant (three test lines)

Parent EXEC-CF8FF737, September 24, 2026.

## Failure recorded

**Gate run 2**, on closure-1 write-tree `3d621d600880b481375055e9d980196b23b263ff`:

| Gate | Result |
|---|---|
| tsc | rc0 |
| eslint | rc0 |
| Jest | rc1 |

Jest ran 396 tests: 389 passed and 7 failed. Three of the 11 suites failed.

**Receipts** are `ux03b/receipts/1*.log` and `run_step5_gates.out`. They are preserved unchanged.

**No commit exists.**

The parent matched the 7 failing tests one-to-one to reviewer B's findings B1–B3, in `ux03b-review-b/UX03B_FINAL_FINDING_B.md`.

## Classification

All three findings are B on the UX-03b proof only. None is A, and no product code is implicated.

### B1

- **Where:** `src/hooks/__tests__/useExtensionPairing.test.tsx:1327`.
- **Failing tests:** 1.
- **Cause:** a base assertion expects a null mirror. The grant-mandated pre-init record (`code: null`, with the retry's nonce) is now legitimately present.
- **Closure:** assert that the late-settled code was not mirrored. That is, the mirrored record's `code` must be null (not `'111111'`), using `?.code ?? null`.

### B2

- **Where:** `src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx`, in the `seedMirror` helper.
- **Failing tests:** 2.
- **Cause:** the v2 seed lacks `setupNonce`, so the fail-closed v2 decoder correctly discards it. This is drift caused by the diff.
- **Closure:** add `setupNonce: 'seeded-nonce-0001'` to the seed.
- **Path extension:** this is a parent-granted single-line extension to this one non-owned J3 test file. It covers the seed line only, because a schema consumer's fixture must track the schema.

### B3

- **Where:** `src/hooks/__tests__/useExtensionPairing.identityWait.test.tsx:119`.
- **Failing tests:** 4.
- **Cause:** an un-awaited `unmount()` under RNTL 14 leaks an act scope into later tests.
- **Closure:** `await unmount();`.

## Product qualification (C, grant-mandated)

A mirror record persisted before this change has no nonce, so it is discarded on upgrade. The coach then gets a new code rather than resuming.

This follows the grant's version rule. Nothing is deployed, so no customer is affected.

## Minimum closure

- Change only these three lines, in the three files named above.
- Change no other line. Keep the test count the same.

## Execution unlocked

1. Refreeze and record the new write-tree and patch sha in `ux03b/CLOSURE_2_READY.md`.
2. Wait for the parent to relay the slot. R currently holds it.
3. Take the lock with flock -n and rerun once from gate 1 into new receipt files.
   - The first nonzero result stops the run.
   - On a Jest failure, list every failing assertion and every masked assertion.
4. If all gates pass, commit, then export the bundle, patch and receipts.
5. Release the lock and report.

Both reviewers bind the actual single commit against the closure-2 tree.
