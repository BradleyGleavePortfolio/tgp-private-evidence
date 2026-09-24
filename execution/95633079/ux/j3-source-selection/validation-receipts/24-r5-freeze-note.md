# r5 — combined minimum two-root closure — additive test-only freeze note

**Scope:** source-only, additive, unstaged. No commit, no env copy/install, no
formatter, no runtime/gate invocation, no lock action taken (per parent grant:
"No commit/envcopy/formatter/runtime/lock; B currently owns PhaseA").

## What changed (exactly two edits, nothing else)

1. **`ImportDataScreen.restore.test.tsx`** — added `semanticColors` to the
   existing `useTheme` mock, using the exact already-working shape copied
   verbatim from the sibling `ImportDataScreen.test.tsx` mock (7 keys:
   `bgPrimary`, `bgSurface`, `textPrimary`, `textMuted`, `textOnAccent`,
   `textOnDisabled`, `disabledBg`). No new palette values invented. No
   provider/global config touched. +4 lines.
2. **`ImportDataScreen.test.tsx`** — added `openUrl.mockClear()` immediately
   after the existing `openUrl = jest.spyOn(Linking, 'openURL')...` assignment
   inside `beforeEach`, so the spy's call history starts empty each case. No
   clear added after any test action, no negative assertion weakened or
   deleted, no wait/tick/timer added, no test case changed. +1 line.

Nothing else was touched: no other mock, no assertion, no test title, no
import, and the product file `ImportDataScreen.tsx` has a zero-byte diff.

## Frozen identities (r4 → r5)

| Item | r4 (committed, `820dbd04`) | r5 (candidate, unstaged) |
|---|---|---|
| `ImportDataScreen.tsx` blob | `92ed52f5cc108f3a098062364d6af793cbb8e2b7` | **unchanged** — `92ed52f5cc108f3a098062364d6af793cbb8e2b7` (verified via `git hash-object`) |
| `ImportDataScreen.test.tsx` blob | `2c032159c0af9cbeb052e1902817569448a987c8` | `a1f65a6b61c3d3cda5d38ac53dac39575c21978c` |
| `ImportDataScreen.restore.test.tsx` blob | `50bd855aaa9b2e93a6233017f5ab20c8d0bb46bd` | `34263aee6c60cebe4fedd192b5fd7ec9ec23401f` |
| Candidate tree | `0ec34e174d52cfdeddfc145b323b6045a3dd5d5c` | `823b97006f7df9617bad5516d7ef578189095e82` |

Candidate tree `823b97006f7df9617bad5516d7ef578189095e82` was produced via a
**temporary index** (`git add` of the three scoped paths on top of unamended
HEAD `820dbd04`, then `git write-tree`), immediately followed by restoring the
real index from a pre-operation backup. **No commit was made.** Post-restore,
`git status --porcelain` correctly shows both edited test files as
unstaged-modified again, and `git rev-parse HEAD` is unchanged at `820dbd04`.

## r4 → r5 patch

Saved to `22-r4-to-r5.patch` (27 lines) — SHA-256
`48d1c58355cd8d1d0129d802a3832b686ad9f18a6b877f5806df097e425a5fb6`. Contains
exactly the two hunks described above: a 4-line `semanticColors` addition in
`restore.test.tsx`, and a 1-line `openUrl.mockClear()` addition in
`test.tsx`'s `beforeEach`.

## Approved follow-up commit message (saved, not yet committed)

Saved to `23-r5-commit-message.txt`, 49 bytes, no trailing newline, single
subject, no body/trailers:

```
test(importer): complete J3 screen mock isolation
```

## Preserved / untouched

- Committed head `820dbd04500b06648ce4c0820c1badced55d6d7c` (tree
  `0ec34e174d52cfdeddfc145b323b6045a3dd5d5c`) — unamended, unchanged.
- All r1–r4 evidence, the original failed-50 r3 gate-3 receipt, the r4
  gate-3 6-failure raw receipt, and the two prior failure-attribution
  correction notes — untouched.
- `execution/test-validation.lock` — not acquired, not touched; B currently
  owns the heavy slot (Phase A) per parent's mail.

## On the upcoming proof (not granted yet, noted per parent's framing only)

Per parent's mail, the eventual gate re-run must be the **full two-file
50-case Jest run** (not `Later` filtered alone), because `beforeEach` is
shared across the whole `test.tsx` suite and the `Later` failure's proof of
isolation depends on prior-case call history/file order — a filtered
single-test run could pass even without the fix actually working. No
additional async drain was added, and this freeze does not conflate adding
`mockClear()` with proof that stale/late calls actually cease; that
determination is left entirely to the actual full-file gate run once
granted. No such run was performed here.
