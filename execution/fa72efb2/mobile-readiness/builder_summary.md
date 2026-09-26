

---

# Round 2

Triggered by the parent's independent-audit NO-GO mail (two B findings, plus
CI red on PR #296 — audit's C7). Full audit at
`execution/fa72efb2/mobile-readiness/review.md`. Scope for this round: close
B1, B2, C1, C2, C5, C6, C7 in **one new commit** on top of the Round 1 head
(`89590423767f899918da5847efd0803a3ea847b4`), which was **not** amended.

## New head sha

```
a876268c07ceaec5ae56b489466922dfbcda1a05
```

Parent: `89590423767f899918da5847efd0803a3ea847b4` (Round 1, untouched).
Author and committer: `Bradley Gleave <bradley@bradleytgpcoaching.com>`. No
`--no-verify`, no AI/co-author trailers. Not pushed.

## Findings closed

- **B1** — the readiness row never showed a success check/"✓" (including its
  a11y label) for any state, terminal included. Fixed in
  `ExtensionPairingPanel.tsx`: the row now always passes bare `pending` to
  `ChecklistRow` (was `pending={readiness.run !== 'terminal'}`), so it is the
  neutral/pending icon for every `run` value — `'terminal'` covers
  failed/cancelled/timed_out, and a checkmark next to it would fabricate an
  outcome the row does not actually report. Added a dedicated terminal-state
  test plus a parametrized test across all three `run` values, asserting the
  rendered icon's *color* (`textMuted` vs `primary`) rather than a literal
  Ionicons glyph name, since the glyph is a private-use-area code point in
  this render tree, not the string `"ellipse-outline"`.

- **B2** — readiness is now re-read from the existing foreground handler
  while paired. `useExtensionPairing.ts`'s `AppState` `'active'` listener
  calls the same `fetchReadiness()` used by the `waiting→paired` transition
  whenever `status === 'paired'`, sharing its guard rather than duplicating
  logic. The single-flight guard was redesigned from a plain boolean
  (`readinessInFlightRef`) to an **epoch-scoped** ref
  (`readinessInFlightEpochRef`): a global boolean would have incorrectly
  blocked a legitimate new-epoch fetch after a re-pair while an old epoch's
  fetch was still outstanding; the epoch-scoped version only blocks
  overlapping calls *within the same epoch* (e.g. two foreground events back
  to back), so there is no retry loop and late responses from a stale epoch
  are discarded on arrival, not retried. Row copy (`readinessCopy()`) was
  already point-in-time-safe from Round 1 and needed no change for this.
  Added tests: exactly one more `pair/current` call on foreground while
  paired; no double-call when a foreground event overlaps an in-flight read
  (single-flight); no call at all when not paired.

- **C1** — `decodeReadiness` in `extensionImport.ts` now enforces
  `declared_platforms` is a non-negative **integer** (previously accepted any
  finite number, including floats and negatives) and the cross-field rule:
  `declared_platforms === null` iff `run === 'none'`, and
  `source_declared === (declared_platforms ?? 0) > 0`. Any violation makes
  the *whole* reading unknown (`undefined`), never partially coerced. Removed
  the panel's `?? 0` fallback on the declared-count text, since the decoder
  now guarantees a non-null count whenever `sourceDeclared` is true — an
  inconsistent block can no longer reach the panel needing that fallback.
  Added ~6 new fail-closed cases to the contract test's `it.each` table
  (non-integer, negative, null-on-non-none, non-null-on-none, both directions
  of the source_declared/count mismatch) plus one new positive case
  (`declared_platforms: 0` with `source_declared: false` is valid).

- **C2** — the contract test's provenance case asserts
  `s11cFixture.$fixture.source.sha256 ===
  '889d25c6a529512596b01ba6554bbf4038ca7f33fdc66f6c9c14118b44dc53f4'`
  inline, matching what the test's own title already claimed but did not
  previously check.

- **C5** — `fetchReadiness` in `useExtensionPairing.ts` now compares
  `decoded.importIntentId` against the pairing's own
  `importIntentIdRef.current` and discards the reading (does not attach it)
  when both are non-null and differ — a pair/current readiness answering a
  *different* pairing than the one currently active is never surfaced. Added
  tests for both the mismatch-discard and the matching-attach cases.

- **C6** — added a test that isolates the epoch guard from the status guard:
  cancel and re-pair (status returns to `'paired'` with a *new* epoch) before
  the *first* read resolves, then let the first (stale-epoch) read land.
  Proves the epoch guard alone — not merely the `'paired'` status check —
  is what discards the stale response, since status alone would have let it
  through.

- **C4** (bonus — surfaced by the audit as low-cost and consistent, not
  explicitly requested for this round, included anyway): the identity-retire
  path (`ownerRef.current !== userId` branch) now also clears
  `readinessRef.current` and bumps `readinessEpochRef.current`, matching
  every other off-paired transition instead of being the sole exception.

- **C7** — CI red on PR #296 (5 failures in `ExtensionPairingPanel.test.tsx`,
  `Converting circular structure to JSON` from
  `JSON.stringify(getByTestId(...).props.children)`). Replaced with a
  `collectText()` helper that walks RTL's own `toJSON()` snapshot tree
  (`{ type, props, children }`, where `children` is a **sibling** of `props`,
  not nested inside it) collecting string leaves — `toJSON()` is a plain
  serializable snapshot, never a raw React element, so it can never carry a
  circular `_owner` Fiber. Applied to both the existing full-card sweep and,
  per the mail's explicit instruction, to the readiness row's own a11y labels
  via a new `findByTestId()` walker (same node-shape fix) plus a new test
  sweeping every rendered state.

## Commands run this round (all under `flock -w 3600
  /home/user/workspace/execution/test-validation.lock`, checked
  `PROOF_SLOT_FREE` present before each)

| Command | RC | Notes |
|---|---|---|
| `npm ci` (`npm_config_cache=/home/user/workspace/execution/fa72efb2/runtime/npm-cache`) | 0 | First real `node_modules` in this clone this grant — 768M, 699 top-level packages. No `lefthook`/`husky` config exists in this repo at all (confirmed before and after `npm ci`), so the "install hooks" step is a no-op here. |
| `npx tsc --noEmit` | 0 | Clean. |
| `npm run lint` | 0 | 76 pre-existing warnings, 0 errors; none in touched files. |
| `npx jest --runInBand` (3 touched test files, scoped) | 1 → 0 | First run: 2 failed / 301 passed / 303 total. Both failures were bugs in the new tests, not the source fixes (below) — fixed, then reran clean at 303/303. |
| `npm test` (full suite) | 0 | 325 suites / 4249 tests / 5 snapshots, all passed. A separate `rls-g2-s11.spec.ts` process visible in `ps` during this run belongs to another concurrent worker on the shared sandbox, not this grant. |

### The two scoped-jest failures, and what they actually were

1. **B1 icon assertion** — the first draft of the terminal-icon test asserted
   a literal glyph string (`"ellipse-outline"`) that does not appear in this
   test env's render tree (Ionicons renders as a private-use-area code point,
   not its icon name). Fixed by asserting the row's icon *color*
   (`MUTED_ICON_COLOR`/`PRIMARY_ICON_COLOR`, mirroring the theme mock)
   instead — this is a test bug, not a B1 regression; the source fix itself
   was correct on the first pass.

2. **New a11y-label sweep test** (`'banned-words sweep over every rendered
   a11y label on the readiness row, every state'`) — failed with `Unable to
   find an element with testID: pairing-check-readiness`, but only from the
   third loop iteration onward, and non-deterministically (a `null`
   `toJSON()`, a "Cannot access `.container` on unmounted test renderer"
   crash, or a clean miss depending on the exact fix attempt). Root cause:
   this panel's mount-time effects (auto-mint, the `copyState` reset keyed on
   `code`) schedule a post-mount state update on every rendered instance;
   repeated manual `render()` + `unmount()` cycles inside one `it` (needed to
   sweep every readiness state without five separate `it`s) left one
   iteration's effect unflushed into the next iteration's render, corrupting
   it (`"You seem to have overlapping act() calls"` from React). This
   pre-existing timing hazard was never previously exercised because the
   *other* multi-state loop test in this file (the full-card banned-words
   sweep) only asserts the *absence* of banned words — a corrupted/empty
   render trivially satisfies that too, so it never surfaced the bug. Fixed
   by wrapping each iteration's `render()` and `unmount()` explicitly in
   `act(async () => { ...; await Promise.resolve(); })` to flush pending
   effects before moving to the next iteration. Separately (and initially
   mistaken for the same bug before the act-fix made it moot) the original
   `findByTestId`/`collectText` helpers had a real shape bug: RTL's
   `toJSON()` node is `{ type, props, children }` with `children` as a
   **sibling** of `props`, not nested inside it — the first draft only
   recursed via `props.children`, so it could never find anything below the
   root. Fixed by recursing via the node's own `children` field.

## Node version note (per the mail's explicit request)

Local sandbox node is `v20.20.1`; the mail states CI uses `22.13`.
`package.json` has no `engines` field, so `npm ci` emitted no engine-mismatch
warning locally — flagging the version gap anyway since nothing in this repo
enforces or surfaces it, so a CI-only-visible incompatibility remains
possible in principle even though every gate here passed clean under 20.

## Files touched this round (6 files, +452/-37 per `git show --stat HEAD`)

- `src/types/extensionImport.ts` — 30 lines changed (C1 decoder hardening)
- `src/components/coach/ExtensionPairingPanel.tsx` — 26 lines changed (B1, C1 panel-side fixes)
- `src/hooks/useExtensionPairing.ts` — 62 lines changed (B2, C5, C4)
- `src/types/__tests__/extensionImport.contract.test.ts` — 30 lines changed (C1, C2 tests)
- `src/hooks/__tests__/useExtensionPairing.test.tsx` — 152 lines changed (B2, C5, C6 tests)
- `src/components/coach/__tests__/ExtensionPairingPanel.test.tsx` — 189 lines changed (B1, C7 tests + helpers)

Exact per-file stat: `git show --stat a876268c07ceaec5ae56b489466922dfbcda1a05`.

## Open questions / explicitly out of scope this round

- The audit's C3, C8, C9 findings (from its full C-record) were **not**
  requested for closure in the mail — only B1, B2, C1, C2, C5, C6, C7 were
  named. Left untouched; flagging in case the parent intended a fuller
  sweep and only enumerated a subset by oversight.
- The pre-existing "overlapping act() calls" console warning is still
  present elsewhere in this test file (in the `it.each` per-state tests and
  the full-card sweep, which don't flush between renders the way this
  round's new test now does) — benign (all assertions there pass, RC=0
  throughout), but noting it since it is the same underlying mount-effect
  timing behavior that caused this round's test-authoring bug, just not yet
  exercised into a real failure in those other tests.
- Did not push, per grant rules; this report only covers the local clone at
  `/home/user/workspace/worktrees/fa72-mobile-rdy`, branch
  `fa72/mobile-readiness`, now at `a876268c07ceaec5ae56b489466922dfbcda1a05`.
