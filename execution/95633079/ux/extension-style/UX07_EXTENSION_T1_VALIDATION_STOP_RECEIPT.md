# UX-07 extension presentation — granted validation stop receipt

**Disposition:** stopped at the first nonzero command as instructed. No commit was created.

## Candidate preserved

| Item | Pin |
|---|---|
| Base commit | `0111be661922234d670bbf23e23d270eec1b4a4e` |
| Granted r2 candidate tree | `3750a2ea9f6e57b7de96c0102aab66d761776189` |
| Repository HEAD after stop | `0111be661922234d670bbf23e23d270eec1b4a4e` |
| Working source status | modified only: `popup/popup.html`, `popup/pair.html` |

The candidate source was not changed during execution. The local validation lock was available after the stopped command, so the held lock was released.

## Bounded execution results

| Step | Bound | Result |
|---|---|---|
| `npm ci` from committed lockfile | 600s, then kill 30s | PASS (`0`) |
| `npm test -- test/popup-start-import.spec.js test/pair-ui-catch.spec.js` | 300s, then kill 30s | PASS (`0`): 2 files, 9 tests |
| `npm run gates` | 300s, then kill 30s | **STOP / FAIL (`1`)** |

The first nonzero is the existing `check:hooks` step inside `npm run gates`: `FAIL: pre-commit hook missing/alignment error: semantic type-check execution`. No retry, source change, hook bypass, commit, build, browser/runtime, package proof, deployment, or remote write followed.

## Raw evidence

- `UX07_EXTENSION_T1_NPM_CI.log` and `.status`
- `UX07_EXTENSION_T1_TARGETED_TESTS.log` and `.status`
- `UX07_EXTENSION_T1_GATES.log` and `.status`
- `UX07_EXTENSION_T1_EXECUTION_LOCK_STATUS.txt`

The raw logs are the authoritative execution record. This receipt does not classify the hook check as pre-existing or candidate-caused, and makes no merge, package, deployment, or customer-readiness claim.

