# Correction to `20-r4-ATTESTATION.md` — raw per-entry failure attribution

**Trigger:** parent mail flagged that my prior attestation attributed all 6 r4 gate-3
failures to the `restore.test.tsx` `semanticColors`/`bgPrimary` cause without raw
per-entry confirmation, and noted the restore suite previously had 5 cases in scope
(not 6) — no assumption of a single shared cause is warranted. This corrects that
gap using only the raw `19-r4-gate3-jest.txt` log, no new test run, no lock use.

**No new source/runtime/lock action taken.** This is a read-only re-examination of
the already-saved raw log. `820dbd04...` remains held unamended.

## Raw per-entry breakdown (from `19-r4-gate3-jest.txt`, verbatim titles + first error line)

| # | Suite file | Test title | Actual error (raw, first line) |
|---|---|---|---|
| 1 | `ImportDataScreen.test.tsx` | `Later records the truthful "later" decision through the accepted UX-01 contract, then navigates back` | `expect(jest.fn()).not.toHaveBeenCalled()` — **a real assertion failure, NOT the `bgPrimary` TypeError** |
| 2 | `ImportDataScreen.restore.test.tsx` | `re-enters the awaiting state for the mirrored platform and shows the SAME code, minting nothing` | `TypeError: Cannot read properties of undefined (reading 'bgPrimary')` |
| 3 | `ImportDataScreen.restore.test.tsx` | `starts at intro when there is no pending session` | `TypeError: Cannot read properties of undefined (reading 'bgPrimary')` |
| 4 | `ImportDataScreen.restore.test.tsx` | `never overrides a phase the coach already moved to while the peek was in flight` | `TypeError: Cannot read properties of undefined (reading 'bgPrimary')` |
| 5 | `ImportDataScreen.restore.test.tsx` | `reads no storage at all when the kill switch is OFF` | `TypeError: Cannot read properties of undefined (reading 'bgPrimary')` |
| 6 | `ImportDataScreen.restore.test.tsx` | `names the platform honestly for a custom-URL session too` | `TypeError: Cannot read properties of undefined (reading 'bgPrimary')` |

## Corrected finding

- **File split confirmed:** 1 failure in `ImportDataScreen.test.tsx`, **5** failures in
  `ImportDataScreen.restore.test.tsx` — consistent with the mail's note that the
  restore suite previously had 5 cases in scope. My prior attestation's wording
  ("all 6... traces to `restore.test.tsx`'s mocked `useTheme`") was **incorrect**: it
  undercounted the listed titles (showed 4 of 6) and wrongly implied all 6 shared one
  file/cause.
- **Two distinct causes, not one:**
  - Entry #1 (`ImportDataScreen.test.tsx`) fails on a **behavioral assertion**
    (`expect(jest.fn()).not.toHaveBeenCalled()` — a mock-call-count mismatch), which
    has **no relation** to `bgPrimary`/`semanticColors`/safe-area at all. This needs
    its own raw investigation; it is not explained by the `restore.test.tsx` theme-mock
    gap.
  - Entries #2–#6 (all 5 in `ImportDataScreen.restore.test.tsx`) share the identical
    `TypeError: Cannot read properties of undefined (reading 'bgPrimary')` raw error,
    consistent with — but not yet independently proven beyond the stack trace already
    in the raw log — the `restore.test.tsx` `useTheme` mock's missing `semanticColors`
    key, since all 5 traces point to the same `ImportSetupView.tsx:47:50` line.
- **No behavior is proven or disproven** by this correction beyond what the raw log
  already shows. This is strictly a bookkeeping/attribution correction of the prior
  attestation's prose, not a new test run, fix, or disposition.

## Status

- `20-r4-ATTESTATION.md` is left unedited (additive-only evidence policy); this file
  is the authoritative correction for its failure-attribution section.
- Held: HEAD `820dbd04500b06648ce4c0820c1badced55d6d7c`, unamended.
- No lock acquired for this correction (read-only analysis of an existing saved file).
- B now owns the heavy slot (phase A) per parent mail; no J3 runtime/lock activity
  will be taken here regardless.
- Awaiting the same reviewer's minimal combined disposition. No acknowledgment
  receipt requested by parent; this file is saved as the requested raw-confirmation
  correction only.
