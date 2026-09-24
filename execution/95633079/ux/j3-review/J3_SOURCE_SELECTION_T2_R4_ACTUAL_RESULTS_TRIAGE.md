# J3 Source Selection — T2 Actual Results Triage (r4 Gate-3, Two Distinct Roots)

**Status:** Additive same-review note. All prior files in this directory
remain preserved unedited. This note independently re-triages r4's actual
gate-3 outcome, per the parent's explicit instruction not to accept the
executor's attestation's aggregate "remaining 6 → theme" summary at face
value. No product edit, runtime, or index write was performed by this
reviewer.

---

## 1. Actual head — independently bound

| Field | Attested | Independently verified |
|---|---|---|
| Commit | `820dbd04500b06648ce4c0820c1badced55d6d7c` | `git cat-file -p` confirms exactly this commit: `tree 0ec34e174d52cfdeddfc145b323b6045a3dd5d5c`, `parent 22d056bb9d36d3c9f659e6d870ef443f9a0a697b`, author/committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, single-line subject `test(importer): provide safe area context in J3 screen tests`, empty body, no trailers |
| Tree | `0ec34e174d52cfdeddfc145b323b6045a3dd5d5c` | Matches the r4 candidate tree already bound in the prior changed-lines binding report exactly |
| Parent | `22d056bb9d36d3c9f659e6d870ef443f9a0a697b` | Confirmed — the r3 commit already bound and attested |
| Working tree post-commit | clean | Confirmed via `git status --porcelain` (empty) |

**Passed stages (independently confirmed from raw logs, not attestation prose):**
- Gate 1 (`tsc --noEmit`): raw log confirms `exit code: 0`.
- Gate 2 (`eslint`, two changed test files): raw log confirms `exit code: 0`.
- Gate 3 (`jest`): raw log confirms `Tests: 6 failed, 44 passed, 50 total`. The prior r3 safe-area failure class (49/50 failing) is confirmed resolved — 44 tests now pass, including all tests that render `ImportSetupView` through `ImportDataScreen.test.tsx` and are not affected by the second root below.

## 2. Independent read of all 6 remaining failures — TWO distinct roots, not one

The r4 attestation (`20-r4-ATTESTATION.md`) enumerated 4 of the 6 failing
titles explicitly and described the remaining 2 only as "sharing the same
`bgPrimary` stack trace," implicitly presenting all 6 as one root cause.
Per instruction, all 6 entries were read individually and directly from
the raw log (`19-r4-gate3-jest.txt`), not assumed from the attestation's
partial listing. This is **not** a single root cause:

### Root A — 5 cases, `ImportDataScreen.restore.test.tsx` — confirmed as attested

Failing titles (all under the `'resumes a pairing session after a process
restart'` describe block):
- `'re-enters the awaiting state for the mirrored platform and shows the SAME code, minting nothing'`
- `'starts at intro when there is no pending session'`
- `'never overrides a phase the coach already moved to while the peek was in flight'`
- `'reads no storage at all when the kill switch is OFF'`
- `'names the platform honestly for a custom-URL session too'`

All 5 throw the identical `TypeError: Cannot read properties of undefined
(reading 'bgPrimary')` at `ImportSetupView.tsx:47:50`
(`c.bgPrimary` inside `styles.shell`'s `backgroundColor`). Independently
confirmed: `ImportDataScreen.restore.test.tsx`'s own `useTheme` mock
returns a flat `colors` object with **no `semanticColors` key at all**,
while `ImportDataScreen.test.tsx`'s `useTheme` mock (added at r1, unchanged
since) does include a full `semanticColors` object. `ImportSetupView.tsx`
(donor, unchanged throughout r1–r4) reads
`useTheme().semanticColors.bgPrimary`, which is `undefined.bgPrimary` under
the `restore.test.tsx` mock shape. This root is a pre-existing gap in that
one file's mock, latent for the same reason as the safe-area gap: this is
the first J3 slice version to render `ImportSetupView` from within
`restore.test.tsx`'s renders of `ImportDataScreen`.

### Root B — 1 case, `ImportDataScreen.test.tsx` — a DIFFERENT root, mischaracterized by the aggregate summary

Failing title: `'Later records the truthful "later" decision through the
accepted UX-01 contract, then navigates back'`.

This is in `ImportDataScreen.test.tsx` — **not** `restore.test.tsx` — and
its failure is not a `TypeError`/render crash at all. It is a genuine
assertion failure:

```
expect(jest.fn()).not.toHaveBeenCalled()
Expected number of calls: 0
Received number of calls: 16
1: "https://my.everfit.io/login"
2: "https://www.trainerize.com/login.aspx"
3: "https://app.truecoach.co/login"
```

Independent read of the test body confirms it reaches and passes its first
two assertions (`mockRecordDecision` called with `'later'`;
`mockGoBack` called once) — Jest reports failure only at the final line,
`expect(openUrl).not.toHaveBeenCalled()`. This means:

- **The actual "Later" behavior under test is correct**: `recordDecision('later')`
  fires and `navigation.goBack()` fires exactly once, both independently
  confirmed passing within this same test run.
- The failing assertion is a **negative** one (asserting `openUrl` was never
  called during this test's own action), and it is receiving 16 accumulated
  calls carrying three real login URLs (Everfit, Trainerize, TrueCoach).
  Those three platforms are exactly the ones exercised by the newer
  reselection tests this same slice's r3 closure added earlier in file
  order (`'lets the coach choose a different platform after a failed
  login-open, in place'` at line 240, which drives TrueCoach → retry →
  Trainerize; `'lets the coach choose a different platform from the
  awaiting-extension state too, in place'` at line 273, which drives
  TrueCoach → retry → Everfit; plus the `it.each` platform-open loops at
  lines 133 and 415).
- The file's own `beforeEach` reassigns `openUrl = jest.spyOn(Linking,
  'openURL')...` fresh before every test, and its `afterEach` explicitly
  calls `cleanup()`, then awaits one `setImmediate` tick, then
  `jest.restoreAllMocks()` — a guard whose own comment states its purpose
  is exactly "so a prior test's async Linking chain can't resolve into the
  next test's fresh spies." The presence of leaked calls in this run
  indicates that guard is **insufficient** for tests whose `openLogin`
  async chain (`canOpenURL` → `openURL` → `track` → `setState`) has not
  fully settled within that single microtask tick — a risk that was latent
  since the guard's own comment already anticipated it, but was not
  triggered until r3 added tests that drive two sequential real opens
  (`choosePlatform` called twice) in one test body, immediately upstream of
  "Later" in file order.

**This is a test-isolation/cleanup-timing defect in the test file's own
`afterEach` drain, not a defect in the reviewed production code.** The
reviewed `onLaterFromSourceSelection`/`recordDecision`/`navigation.goBack`
logic is independently confirmed behaving correctly within this very test
run (its own positive assertions pass). No claim is made that this proves
the production code has no defect beyond what this run shows — only that
this specific failure's evidence points at test leakage, not at
`onLaterFromSourceSelection` itself, and the passing positive assertions
in the same test corroborate that read directly, not by inference alone.

## 3. Distinguishing product from proof (per explicit instruction)

- **Root A (5 cases):** proof-only. The donor `ImportSetupView.tsx` is
  confirmed unchanged; the gap is entirely in one test file's own mock
  shape. No product defect is indicated or claimed.
- **Root B (1 case):** proof-only, with a caveat. The failure is a
  polluted negative assertion, not a crash inside the reviewed source; the
  same test's own positive assertions about the reviewed
  `onLaterFromSourceSelection` behavior pass within this same run. This is
  evidence toward, not proof against, correctness — an aborted/failed
  assertion under known test-isolation interference does not by itself
  certify the production code defect-free beyond what this run showed
  passing. No broader "no product defect" claim is made; the finding is
  scoped to what is directly observable: the recordDecision/goBack path
  passed, and the openUrl pollution is attributable to leaked calls from
  named, identified earlier tests in the same file, not to
  `onLaterFromSourceSelection` calling `openUrl` itself (which would
  require an actual code path from `onLaterFromSourceSelection` to
  `openLogin`, and no such path exists in the reviewed source — confirmed
  by the unchanged `onLaterFromSourceSelection` body, which only calls
  `recordDecision` and `navigation.goBack`, never `openLogin`/`selectPlatform`).

## 4. Minimum existing mock/assertion correction — identified, concrete, source-only

Two independent, narrowly-scoped corrections, each reusing an already-present pattern in the same codebase:

1. **Root A close:** add the missing `semanticColors` key to
   `ImportDataScreen.restore.test.tsx`'s existing `useTheme` mock, matching
   the shape already present and working in `ImportDataScreen.test.tsx`'s
   own `useTheme` mock (both files sit in the same directory and mock the
   same module; this is a direct, already-proven-working shape to copy, not
   a new design).
2. **Root B close:** strengthen `ImportDataScreen.test.tsx`'s `afterEach`
   drain so a preceding test's `openLogin` async chain cannot leak calls
   into a later test's fresh spy — e.g., explicitly call `openUrl.mockClear()`
   (or `canOpen.mockClear()`/`openUrl.mockClear()` together) inside
   `beforeEach` immediately after the fresh `jest.spyOn` assignment (belt
   and suspenders against any leaked-but-still-referenced call), or await
   an additional drain tick/`flushPromises` equivalent already used
   elsewhere in this codebase's suites before asserting negatives.
   Because `openUrl` is freshly assigned via `jest.spyOn` each
   `beforeEach`, an explicit `mockClear()` immediately after assignment is
   the minimal, most direct fix and does not require touching the
   `afterEach` timing logic at all.

Both corrections are test-file-only; **no product/donor file, no global
Jest config, and no assertion strength reduction is required** — the
`'Later'` test's own negative assertion (`openUrl` not called) should be
preserved exactly as written, not weakened or removed, once the leak is
closed at its source (the spy's own call history).

## 5. Proposed successor scope

Consolidate both corrections into **one** additive, source-only successor
delta (r5), touching exactly:
- `src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx` (add
  `semanticColors` to its `useTheme` mock)
- `src/screens/coach/__tests__/ImportDataScreen.test.tsx` (clear `openUrl`
  immediately after each `beforeEach` spy assignment)

No product file, no `ImportSetupView.tsx`, no other donor/controller/hook
file, no global config.

## 6. Proposed post-fix proof scope (per parent's stated preference)

Once r5 lands and is committed, if applicability genuinely transfers (i.e.
the fix set is confined to exactly these two mock/cleanup lines with no
other change), the minimum re-proof is the **6 previously-failing cases
only**, not a full 44+6 re-run:

```
npx jest src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx -t "re-enters the awaiting state for the mirrored platform|starts at intro when there is no pending session|never overrides a phase the coach already moved to|reads no storage at all when the kill switch is OFF|names the platform honestly for a custom-URL session too" --silent --runInBand
npx jest src/screens/coach/__tests__/ImportDataScreen.test.tsx -t "Later records the truthful" --silent --runInBand
```

If the executor or parent determines the 44 already-green cases are
provably unaffected by these two narrow, additive-only mock/cleanup lines
(no shared setup touched, no shared module mock changed), re-asserting
only the 6 previously-red cases is proposed as sufficient; a full 50-case
re-run remains available if that provenance is not accepted without
re-verification.

## 7. Carried-forward C-qualifications (unchanged)

All qualifications from the prior actual-head results note and r4
changed-lines binding stand unchanged: (1) r1 report's patch-hash
transcription remains uncorrected in that immutable file, corrected in
Addendum 1; (2) no index write performed by this reviewer, this round
included — verification used `git cat-file`, `git status`, and direct log
reads only; (3) tree identities throughout this review family are reasoned
from verified base/path/blob evidence, not always from an independently
run `write-tree`; (4) the authored Jest tests are mocked
component-interaction coverage, evidenced here by their own actual failure
modes, never real browser/device/end-to-end proof; (5) the
`navigation.goBack()` unmount-safety general claim remains an open,
unrelied-upon qualification.

## 8. Constraints observed this round

No product edit, runtime execution, or index write was performed by this
reviewer. Verification was limited to `git cat-file -p` (read-only object
inspection), `git status --porcelain`, and direct reads of the existing
raw log file (`19-r4-gate3-jest.txt`) and existing source/test files
already present in the worktree. No broad pattern inventory was performed;
only the 6 directly failing cases and the directly relevant donor
(`ImportSetupView.tsx`) and mock-declaration contracts needed to explain
them were read.

---

## Sources

- `execution/95633079/ux/j3-source-selection/validation-receipts/19-r4-gate3-jest.txt` (raw log, all 6 failure entries read individually)
- `execution/95633079/ux/j3-source-selection/validation-receipts/20-r4-ATTESTATION.md`
- `worktrees/ux03-j3` (live git worktree, commit `820dbd04500b06648ce4c0820c1badced55d6d7c` independently read via `git cat-file`)
- `src/screens/coach/__tests__/ImportDataScreen.test.tsx` (full `useTheme` mock, `beforeEach`/`afterEach`, and the failing `'Later records...'` test body read directly)
- `src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx` (`useTheme` mock shape confirmed missing `semanticColors`)
- `src/screens/coach/import-journey/ImportSetupView.tsx` (donor, unchanged; confirmed as the throw site for Root A)
