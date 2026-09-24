# UX-03a assertion-only closure grant

Parent EXEC-CF8FF737, September 24, 2026.

## Failure recorded

The first gate run on frozen write-tree `0a876c10aea9e8f8ad3cf2632a394672e6c9e2d3`, with patch `a9c81d0d…`, produced these results:

| Gate | Result |
|---|---|
| tsc | rc0 |
| lint | rc0 |
| Jest | **rc1** |

The Jest run covered 137 tests, of which 132 passed and 5 failed. The failures were in `ExtensionPairingPanel.test.tsx` (4) and `ExtensionPairingPanel.reconstruct.test.tsx` (1). Receipts are preserved at `execution/cf8ff737/ux03a/receipts/` and `GATE_STOP_REPORT.md`, and they stay unchanged.

## Classification

**B, proof-invalidating on UX-03a only.**

- **Harm:** the five new positive assertions call `toHaveTextContent(string)`. In the installed @testing-library/react-native 14.0.0, that call defaults to exact matching. So they fail on the correct rendered text; for example, "Connected to TGP as Jordan Coach ✓" does not exactly equal "Jordan Coach".
- **Decision blocked:** the UX-03a commit and its acceptance.
- **Product impact:** none shown. The product source is not implicated.

The parent checked the absence assertions. They use regex matching against the full rendered or source text, so they are substantive and not vacuous. No change is needed there.

## Minimum closure

- **Scope:** only the five failing positive assertions, in the two named test files.
  - Make each one substring-based: `toHaveTextContent(expected, { exact: false })`, or an anchored-content regex.
  - Keep each expected string unchanged.
- **Must not change:**
  - any other assertion or test
  - the product file or other test files
  - mocks
  - the test count
- **Parity:** the correction must not weaken what each assertion proves.

## Execution unlocked

1. Refreeze the tree and patch, recording the new write-tree and patch sha.
2. Take the lock with flock -n. It is free; UX-03b and R are not ready yet.
3. Rerun all three gates once, in the same order, on the corrected tree.
   - The first nonzero result stops the run.
   - No further automatic retry.
4. If all gates pass, make an ordinary commit with Bradley Gleave as author and committer, with no AI trailers.
5. Export the bundle, patch and receipts.
6. Release the lock and report.

The independent reviewer binds the final head, including this closure.

## Amendment 1 — second stop (parent, same day)

### What happened

The closure rerun on write-tree `10047dbde11e9aa279b873cecdad546637d12202` (patch `d18e0fa2…`) ran as follows:

| Gate | Result |
|---|---|
| tsc | rc0 |
| lint | rc0 |
| Jest | **rc≠0**, 135 of 137 passed |

Two tests still failed:

- `ExtensionPairingPanel.test.tsx:156`
- `ExtensionPairingPanel.reconstruct.test.tsx:168`

Both assert `toHaveTextContent('Not yet known')` on `pairing-check-platform`, whose rendered text is `Previous platformNot yet known`.

The first run hid these two lines. They are later assertions in tests whose earlier assertions failed, so they never executed. The receipts are `receipts/*.rerun.log` and `CLOSURE_RERUN_STOP_REPORT.md`, preserved unchanged.

The builder obeyed its scope correctly. The first closure grant was scoped too narrowly because the parent did not check for masked assertions. This is recorded as a parent error (C, no new control).

### Parent check before this amendment

The parent listed every remaining positive `toHaveTextContent(string)` without `exact: false` in the four owned test files. It found six:

- **Four already executed and passed** under exact matching: a11y 122, a11y 133, a11y 158, and test.tsx 109. These are unchanged.
- **The two lines above** are the last assertions in their tests. No further assertions are masked behind them.

### Closure extended

The extension covers only these two lines, changing them to `toHaveTextContent('Not yet known', { exact: false })`. Nothing else changes.

### Then

1. Refreeze and record the new write-tree and patch in `ux03a/CLOSURE_2_READY.md`.
2. Rerun all three gates once into new `*.rerun2.log` receipts.
3. The first nonzero result stops the run.
4. If all gates pass, commit, bundle, release the lock and report.
