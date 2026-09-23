# Review B — P2 reachability disposition (addendum; frozen P2 bytes unchanged)

Written 2026-09-23 13:1x PDT at the parent's request. `P2_REPORT.md` / `P2_FINDINGS.md` keep their original text and hashes; this file adds the narrow reachability resolution and two self-corrections. Reviewer A's frozen P2 packet was read only after this review's P2 packet was sealed.

## 1. S6-B-P2-01 — narrow reachability resolution → **conditional C**

Question: does existing evidence supply an actual supported product producer of an in-session committed-identity change A→B (non-null to a different non-null) with the previous identity's memory still dirty, so that the P2 gate's lost step-3 clear could be reached?

Evidence chain (P2 worktree, read-only):
- `RootNavigator.tsx:585-756` (`bootstrapAuth`) is the only writer of `sessionUserId`. A non-null id is set at `:618` solely from `readUserCache()`; every other outcome sets `null`.
- Writers of the cached user identity in product code: `LoginScreen.tsx:87,139,176`, `CreateAccountScreen.tsx:224`, `RoleSelectionScreen.tsx:141` (via `setUserCache`), `utils/appleAuth.ts:127`, `utils/googleAuth.ts:147` (legacy key, invoked from the auth screens/button). All are screens of `AuthNavigator`, which `RootNavigator.tsx:845-846` mounts only for `authState==='unauthenticated'`, and every bootstrap outcome that yields `'unauthenticated'` also commits `sessionUserId=null` (`:594-601`, `:749-753`). `RecipesScreen.tsx:177-187` rewrites the same user's profile (same id). `AuthCallbackScreen` is not mounted anywhere (`RootNavigator.tsx:163-173` comment; no navigator registers it) and performs no identity write.
- Every route from a committed non-null identity to committed null with dirty memory passes through `signOut()` — user action, `DeleteAccountScreen`, and the refresh-failure path (`api.ts:177-197` calls `signOut()`), and `signOut()` clears memory itself via `settleAndClearQueryCache()` (`authActions.ts:375`) independent of the gate. The one non-`signOut` route to null (`:594` token-present/user-cache-unreadable) starts from a fresh boot where identity memory is empty apart from above-gate providers (P1 C2, pre-existing).

Result: **no supported product producer** of an in-session A→B or of a dirty-memory null was found. The scenario in S6-B-P2-01 therefore rests on externally swapped storage (the frozen T2 hazard premise), not on a product call chain. Under the owner doctrine a premise-only scenario cannot open a fix cycle. **Disposition: S6-B-P2-01 is reclassified to conditional C** (record; becomes A only if concrete evidence of such a producer appears). The finding's text, exact lines and minimum correction stay on record for any later authorized change; no regression is requested for it.

Effective P2 product-source verdict after this disposition: **product paths source-closed / grantable** (A01, A02 closed; A03 partially, see §2). This does not alter the frozen P2 packet's own wording; it supersedes its grant recommendation.

## 2. Self-corrections established from my own byte check after reading A's P2 packet

- **Recursive storage delegates (A's S6-A-P2-B04, first part) — confirmed by bytes.** `beforeEach` installs `getItemSpy`/`setItemSpy` (`identityGate.test.tsx:82-83`); each test then captures `AsyncStorage.getItem/setItem.bind(AsyncStorage)` *after* that replacement (`:153,206,234,280,318,394,436,474,496,520`), so `realGet`/`realSet` are the spies themselves and every `mockImplementation` delegates back into itself. In the pass-through branch there is no await before the re-entry, so the recursion is synchronous and unbounded; in the held branch a second unreleased promise can be created. This pattern is present in the P1-staged bytes as well; my P1 REPORT §5 and P2_REPORT §3 statements that these suites are "consistent with the candidate" / "pass by source reasoning" were wrong on this mechanic. It is a Class B (proof) defect of the test files only; product-path conclusions are unaffected.
- **Fixture seed counted as forbidden write (B04, second part) — confirmed by bytes.** The new A01 regression seeds `KEY_B` at `:312` through the installed spy and asserts `filter(KEY_B) === []` at `:342` without a baseline; my P2_REPORT §3 trace missed this.

Both are within the P3 test-only correction scope the parent has assigned; I add no criteria beyond A's minimum correction (delegate to the underlying mock implementation captured before spying, baseline fixture writes, keep delays/releases and assertions).

## 3. Ownership
Source-read ownership of `worktrees/s6-p2` remains released. Holding for P3 READY pins; P3 review will cover only the P2→P3 changed test bytes and the exact-tree/pin derivation.
