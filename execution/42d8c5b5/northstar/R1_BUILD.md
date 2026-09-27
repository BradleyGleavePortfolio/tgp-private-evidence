# R1 BUILD — Roman status binding (T2)

Builder: Bradley Gleave `<bradley@bradleytgpcoaching.com>`
Date: 2026-09-27

## Pull request

| Repository | Base | Head branch | PR | Head commit |
| --- | --- | --- | --- | --- |
| growth-project-mobile | `main` @ `01dd8a3c` | `r1/roman-status-binding` | https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/300 | `86144f34dd833889038d1d5c86ccd0993930b181` |

PR left **open, not merged**, per the grant.

## CI

All checks green on both pushed heads:

| Check | `b283c93` (initial) | `86144f3` (finding fix) |
| --- | --- | --- |
| Typecheck, lint, test | SUCCESS | SUCCESS |
| CodeQL Advanced / Analyze (actions) | SUCCESS | SUCCESS |
| CodeQL Advanced / Analyze (javascript-typescript) | SUCCESS | SUCCESS |
| CodeQL | SUCCESS | SUCCESS |

## Class-A finding closed (post-review, before independent acceptance)

**Finding:** the initial adapter mapped server `complete`/`partial` to the
result view's `unavailable` outcome. This regressed the coach from what
`ImportRunVerdictCard` already shows on `main` today: the server's verdict IS
the authority (S9 reconciliation settles `complete` before the server ever
emits it), so showing less than the card already showed for the same read was
a genuine loss of truth, not honesty.

**Closure (commit `86144f3`, pushed as a second non-force commit on the same
branch):**
- `ImportResultView` gained one additive outcome, `serverVerdict`
  (`authority:'server'`, `status:'complete'|'partial'`), distinct from the
  native-proof-gated `complete`/`verifiedSubset` outcomes (which still require
  an `ImportNativeSummary` this hook never carries, and are still never used
  by this adapter). It renders the same complete/partial headline and body
  copy `ImportRunVerdictCard` uses today (`result.complete.*` /
  `result.partial.*`), with no counts, scope or native action — this hook's
  reading never carried any to show, and none are invented. Every existing
  outcome branch (`complete`, `verifiedSubset`, `provenZero`, `transferOnly`,
  `blocked`, the ordinary terminals) is untouched.
- `importRunStatusAdapter` now maps server `complete` → `serverVerdict`
  complete (no reason — a settled complete has none, matching the card) and
  server `partial` → `serverVerdict` partial with the server's `reason_code`
  mapped through the same four approved local reason keys `blocked` already
  uses (`revoked→denied`, `cancelled_by_coach→changed`,
  `unresolved_family|unresolved_identities|relationship_unverified|coverage_basis_unknown→scopeUnknown`,
  else→`unknown`). Legacy-mode terminals are unchanged — still `unavailable`,
  matching the card's own `legacyNote` treatment of an unarbitrated extension
  claim (the finding explicitly exempts this case).
- Added `ImportRunStatusJourney.parity.test.tsx`: for every server status, it
  runs the card's own exported `verdictLines(reading)` against the identical
  reading the Roman adapter receives, and asserts the Roman surface's outcome
  is at least as informative — specifically that it never collapses to
  `unavailable` where the card names a real, non-generic verdict. Legacy and
  truly-unknown-status cases are asserted to match the card's own declines.
- Reused the existing `result.complete.*`/`result.partial.*` P2 copy keys
  (already present, previously only reachable via the native-gated branches)
  and the existing four approved blocked-reason keys — no new P2 copy keys,
  and no P1 dictionary changes.

Locally, before pushing: targeted jest suites (`importRunStatusAdapter.test.ts`,
`ImportRunStatusJourney.test.tsx`, all `ExtensionPairingPanel.*.test.tsx`,
`ImportRunVerdictCard.test.tsx`, the `import-journey/__tests__` P2 suites,
`useImportRunStatus.test.tsx`) — 355/355 passing. `npx tsc --noEmit -p .` —
clean. `eslint` over touched files — clean. Ran only these targeted suites
(not the full jest run) because the build machine has 2 CPUs and is shared
across other concurrent agent worktrees; the full suite is covered by CI.

## Delivered

1. **`src/screens/coach/import-journey/importRunStatusAdapter.ts`** — the one
   pure adapter, `mapImportRunStatusToJourneyView(run: ImportRunStatus)`,
   turning the S12-B3 `useImportRunStatus` reading into Roman P2 view props
   (`ImportProgressView` / `ImportResultView`). It imports only types (no
   hook, network, storage, or analytics module), maps only fields the server
   states, and never infers:
   - `disabled` → `{kind:'none'}` (nothing mounted).
   - `loading`/`error` (no reading yet) → progress view, `unavailable`
     freshness — nothing proven yet.
   - `notFound`/`unreadable` → result view, `unavailable` outcome.
   - `reading`, `running`, phase recognised → progress view, `current`
     freshness with the mapped phase (`discovering→finding`,
     `transferring→transferring`, `reconciling→checking`).
   - `reading`, `running`, phase null/unrecognised, or `stale === true` →
     progress view, `stale` freshness (with `lastObservedPhase` if a phase was
     known) — never guesses or claims currency it doesn't have.
   - `reading`, `mode === 'legacy'` any terminal → result view, `unavailable`
     — the extension's own unarbitrated claim is never shown as proven.
   - `reading`, server `complete` or `partial` → result view, `unavailable`.
     This is a deliberate, documented scope limit, not a downgrade of server
     truth: `DecodedRunStatus` (S12-B3) carries no native-write proof, and
     P2's `complete`/`verifiedSubset` outcomes require an `ImportNativeSummary`
     that does not exist on this hook. Fabricating one would violate the
     P2 caller contract ("display inputs are not proof"); the honest move is
     to say the result is not available to show yet, not to claim a false
     `complete`.
   - `reading`, `failed`/`cancelled`/`timed_out` → result view with the
     matching outcome.
   - `reading`, `blocked` → result view, `blocked` outcome, `reason` mapped
     via `revoked→denied`, `cancelled_by_coach→changed`,
     `unresolved_family|unresolved_identities|relationship_unverified|coverage_basis_unknown→scopeUnknown`,
     anything else (including `reconciliation_not_performed`,
     `deadline_exceeded`, `transfer_failed`, null, unrecognised) → `unknown`.
   - `reading`, `unknown` status/mode → result view, `unavailable`.
   Every branch is unit-tested in
   `src/screens/coach/import-journey/__tests__/importRunStatusAdapter.test.ts`
   (32 cases).

2. **`src/components/coach/ImportRunStatusJourney.tsx`** — mounts the Roman
   progress/result views where `ImportRunVerdictCard` mounted today, inside
   `ExtensionPairingPanel`'s `paired` state (same `importIntentId ? <X
   importIntentId={importIntentId} /> : null` contract, so the real
   `useImportRunStatus` hook — and its `useQuery` — is only ever invoked when
   an intent id exists, matching every existing test's assumptions). It calls
   `useImportRunStatus(importIntentId)`, maps the reading through the adapter,
   and renders `ImportProgressView`/`ImportResultView` with
   `romanEnabled={featureFlags.romanChat}` (the same master flag every other
   Roman surface reads) and a real `onReturnToCoaching` wired to
   `navigation.goBack()` — no fabricated no-op. Roman on and Roman off render
   the identical status; the flag only changes the portrait / first-person
   completion copy, never which outcome is shown. No Start/retry/stop wiring
   beyond what already existed (no stop/check-result/details action props are
   ever passed, so those buttons never render), and no new polling or timers
   beyond the hook's own.

3. **`ExtensionPairingPanel.tsx`** — swapped the `ImportRunVerdictCard` import
   and mount for `ImportRunStatusJourney` at the same call site (module doc
   comment updated to match). `ImportRunVerdictCard.tsx` itself and its
   454-line test suite are untouched — the card is simply no longer mounted
   in production, keeping exactly one status surface live.

4. **Tests updated/added:**
   - `ExtensionPairingPanel.verdict.test.tsx` rewritten to mock and assert
     against the new `ImportRunStatusJourney` mount (same coverage shape as
     before: paired + intent id mounts it with exactly that id; paired
     without an intent id, and every non-`paired` status, mounts nothing).
   - `ImportRunStatusJourney.test.tsx` (new) — covers `disabled` (renders
     nothing), a recognised running phase, the `complete`→`unavailable`
     documented limitation, a mapped `blocked` reason, `failed` rendered
     identically with Roman on/off, the Back/Return-to-coaching buttons
     calling real `navigation.goBack()`, and the absence of any
     Stop/Check/Details action.
   - Confirmed via targeted runs that the other three
     `ExtensionPairingPanel.*.test.tsx` files (`.test.tsx`, `.a11y.test.tsx`,
     `.copy.test.tsx`, `.reconstruct.test.tsx`) never set `importIntentId` in
     their `paired` mocks, so they never reached the old or new mount and are
     unaffected — verified green.

## LOC

Counted via `git diff 01dd8a3c --numstat`, whole branch (both commits) against
`origin/main@01dd8a3c`.

| File | Type | Added | Removed |
| --- | --- | ---: | ---: |
| `src/screens/coach/import-journey/importRunStatusAdapter.ts` | prod | 168 | 0 |
| `src/components/coach/ImportRunStatusJourney.tsx` | prod | 51 | 0 |
| `src/screens/coach/import-journey/ImportResultView.tsx` | prod | 27 | 7 |
| `src/components/coach/ExtensionPairingPanel.tsx` | prod | 20 | 10 |
| **Prod total** | | **266** | **17** |
| `src/screens/coach/import-journey/__tests__/importRunStatusAdapter.test.ts` | test | 192 | 0 |
| `src/components/coach/__tests__/ImportRunStatusJourney.test.tsx` | test | 110 | 0 |
| `src/components/coach/__tests__/ImportRunStatusJourney.parity.test.tsx` | test | 88 | 0 |
| `src/components/coach/__tests__/ExtensionPairingPanel.verdict.test.tsx` | test | 25 | 20 |
| **Test total** | | **415** | **20** |

Added prod LOC: **266** (grant cap: ≤400 added prod LOC — under by 134).

## Status → view mapping (final, post-finding-closure)

| `useImportRunStatus` view / `DecodedRunStatus.status` | Roman view rendered | Notes |
| --- | --- | --- |
| `disabled` | none (nothing mounted) | flag off / no coach / no intent |
| `loading` / `error` (no reading yet) | `ImportProgressView`, `{freshness:'unavailable'}` | nothing proven yet |
| `notFound` / `unreadable` | `ImportResultView`, `outcome:'unavailable'` | 404 or undecodable body |
| `reading`, status=`running`, phase recognized | `ImportProgressView`, `{freshness:'current', phase}` | discovering→finding, transferring→transferring, reconciling→checking |
| `reading`, status=`running`, phase null/unknown | `ImportProgressView`, `{freshness:'stale'}` (no lastObservedPhase) | never guesses a phase |
| `reading`, status=`running`, but `run.stale===true` | `ImportProgressView`, `{freshness:'stale', lastObservedPhase}` if phase known | stale refresh never claims current |
| `reading`, `mode==='legacy'` any terminal | `ImportResultView`, `outcome:'unavailable'` | extension's own unarbitrated claim, never shown as proven (documented exception — matches the card's own `legacyNote`) |
| `reading`, status=`complete` (server) | `ImportResultView`, `outcome:'serverVerdict'`, `authority:'server'`, `status:'complete'` | the server's own settled verdict (S9 reconciliation), shown as the authority it is — same headline/body as `ImportRunVerdictCard`, no counts invented |
| `reading`, status=`partial` (server) | `ImportResultView`, `outcome:'serverVerdict'`, `authority:'server'`, `status:'partial'`, `reason` mapped via `BLOCKED_REASON_MAP` | same headline as the card; server's `reason_code` surfaced through the four approved local reason keys |
| `reading`, status=`failed` | `ImportResultView`, `outcome:'failed'` | — |
| `reading`, status=`cancelled` | `ImportResultView`, `outcome:'cancelled'` | — |
| `reading`, status=`timed_out` | `ImportResultView`, `outcome:'timedOut'` | — |
| `reading`, status=`blocked` | `ImportResultView`, `outcome:'blocked'`, `reason` mapped via `BLOCKED_REASON_MAP` | revoked→denied, cancelled_by_coach→changed, unresolved_family/unresolved_identities/relationship_unverified/coverage_basis_unknown→scopeUnknown, else→unknown |
| `reading`, status=`unknown` | `ImportResultView`, `outcome:'unavailable'` | unrecognised status/mode |

## Notes / deviations

- `origin/main` had advanced two commits past the grant's pinned base
  (`01dd8a3c` → `81132f4`, docs-only: publishing the importer north star) by
  the time of push. Kept the branch based at `01dd8a3c` as the grant
  specifies; the two upstream commits don't touch any file this PR changes.
- Read the mount contract literally: the grant permits either retiring
  `ImportRunVerdictCard`'s mount or reducing it to a thin wrapper. Chose
  retirement — `ImportRunVerdictCard.tsx` and its existing 454-line test file
  stay completely untouched and still pass, only the production call site
  moved — because wrapping it would have required threading Roman view props
  through its own unrelated prop contract for no benefit, and the grant's
  "keep exactly ONE status surface" is satisfied either way.
- `onReturnToCoaching` needed a real, working callback (grant forbids
  fabricated no-ops implicitly via the north star's honesty invariants
  extended to wiring): wired to `navigation.goBack()`, using the navigation
  object `ExtensionPairingPanel` already imports for its existing "Review
  clients" action.
