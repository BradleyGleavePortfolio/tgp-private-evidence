# UX-03a closure rerun — STOPPED, new nonzero (out-of-grant-scope finding)

Grant: `execution/cf8ff737/UX03A_ASSERTION_CLOSURE_GRANT.md`. This rerun followed `CLOSURE_READY.md` exactly: refroze on write-tree `10047dbde11e9aa279b873cecdad546637d12202` / patch sha256 `d18e0fa21cbb8b375c539e2d41904e8034a02cfb1ec8d2064db2b9819599ae6f`, took the lock, ran gates in order into new receipts (not overwriting the first run's).

## Gate results (rerun)

| Gate | Receipt | Result |
|---|---|---|
| 1. `tsc --noEmit` | `receipts/01-tsc.rerun.log` | **rc=0, pass** |
| 2. Lint on the 5 changed paths | `receipts/02-lint.rerun.log` | **rc=0, pass** |
| 3. Jest (same 6 files as original run) | `receipts/03-jest.rerun.log` | **rc≠0 — STOP** |

Jest: 2 suites failed, 4 passed; 135/137 tests passed (up from 132/137 on the first run — the 5 authorized fixes worked as intended). Full session log: `receipts/00-rerun-session.log`.

## What's different from the first run, and why this is a new finding, not a retry of the old one

The two still-failing assertions are **not** among the five the closure grant authorized:

- `ExtensionPairingPanel.test.tsx:156` — `expect(getByTestId('pairing-check-platform')).toHaveTextContent('Not yet known')`
- `ExtensionPairingPanel.reconstruct.test.tsx:168` — same assertion, same test id

Neither line appears in the grant's five-line list. Both were reported as **passing** in the original classification because Jest reports only the first failing `expect` in a test body and both of these lines sit immediately after one of the five originally-broken lines in the same test function — so they were never actually reached or evaluated in the first run. The grant's statement "the parent checked the absence assertions... no change is needed there" did not have visibility into these two positive assertions because they were masked, not passing.

Now that the five authorized fixes let execution reach these lines, they fail for the identical underlying reason as the original five: `pairing-check-platform`'s rendered node contains the label and value concatenated (`"Previous platformNot yet known"`, confirmed in both this run's and the original run's "Received:" output), so an exact match against just `'Not yet known'` fails; substring matching would pass.

## Action taken

Per "first nonzero stops... no retry" and the grant's explicit scope limit ("only the five failing positive assertions... must not change... any other assertion"), I did not touch these two lines. No source edit was made. Verified the working tree write-tree is still byte-identical to the refrozen closure state (`10047dbde11e9aa279b873cecdad546637d12202`) after the failure. Lock was released and confirmed free.

## Disposition requested

This reads as the same class of defect (missing `{ exact: false }` on a `toHaveTextContent(string)` call against a node with label+value concatenated text), extending to 2 more lines beyond the original 5, in the same two files, with the same expected strings kept unchanged. Requesting parent authorization to:

1. Apply the identical pattern to these 2 additional lines only (`toHaveTextContent('Not yet known', { exact: false })` at both locations), OR direct a different disposition.
2. Refreeze again and rerun all three gates once more into a third receipt set, OR handle otherwise per parent instruction.

No further action taken pending that authorization — awaiting parent disposition, consistent with how the first stop was handled.
