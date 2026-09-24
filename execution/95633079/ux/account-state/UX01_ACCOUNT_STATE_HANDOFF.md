# UX-01 account-scoped offer-decision STATE — readable handoff

Status: **source packet ready for two independent T4 reviews. Not self-approved. Not run.**
Tier: T4 (account isolation of persisted journey state). Scope: canonical CQ-02 mobile default only (per-account `yes` / `later` / `starting_fresh` persistence following the accepted S6/#291 user-scoped-mirror pattern, cross-user purge, safe async identity binding, sign-out clears app state without claiming extension revocation).

Pins: base `bc7b4e96fc1db54568bc209dbe1f7a4121501ac9` (tree `acb41c2b…`), candidate tree `a33cb8919495ed24e30623188dbb9f59c67df8bd`, patch SHA-256 `d695f8d8…7e0085`. See `EXACT_PINS.md` / `FREEZE_RECEIPT.md`.

## 1. What this delta is (6 paths, +1039/−0)

| Path | Role |
|---|---|
| `src/storage/importOfferDecision.ts` | Storage module. Key `import_offer_decision:<userId>` (exported constant `IMPORT_OFFER_DECISION_KEY_PREFIX`), version `1`, payload `{version, userId, decision}` — no timestamp (R16). `write` throws on failure (caller keeps memory truth). `read` returns `'yes' | 'later' | 'starting_fresh' | null`; any unparseable JSON, version drift, unknown value, shape failure, or **`userId` mismatch with the key** is logged, DISCARDED and the key deleted (#291 cross-user purge). `clear` removes the key (logs on failure, never throws). |
| `src/hooks/useImportOfferDecision.ts` | State hook. Identity from `useCurrentUser()` (same source as #291 `useExtensionPairing`). `enabled` defaults to the existing `featureFlags.extensionImport` kill switch (OFF by default) exactly as `useExtensionPairing` does; no new flag. |
| `src/services/authActions.ts` | Narrow extension: `IMPORT_OFFER_DECISION_KEY_PREFIX` appended to `PER_USER_KEY_PREFIXES` (exact-key removal for the signing-out user). S6 ordering untouched. |
| `src/storage/__tests__/importOfferDecision.test.ts` | Storage tests: key/version/values, round-trip, key isolation between coaches, cross-user purge (payload userId ≠ key), corrupt/version-drift/unknown-value discard + delete, write failure throws and leaves prior record, clear. |
| `src/hooks/__tests__/useImportOfferDecision.test.tsx` | Hook tests: disabled inert, unresolved refuses to record, loading→ready, per-coach read, immediate reflection before disk, tap supersedes in-flight read, serialized overlapping writes (last answer is last on disk), failed write → false + re-offer next mount, A→null and A→B on a live mount (reset before B's read, stale A read discarded, B's own answer), late write after sign-out / switch removed and `false`. |
| `src/services/__tests__/authActions.test.ts` | One added test: sign-out removes `import_offer_decision:user-A`, keeps bystander `…:user-456` and sentinel `import_offer_decisionx_unrelated`. Existing tests unchanged. |

## 2. Contract exposed to the sole UI writer (the only thing the presentation layer should depend on)

```ts
import { useImportOfferDecision, type ImportOfferDecision } from '../../hooks/useImportOfferDecision';

const { status, decision, recordDecision } = useImportOfferDecision(/* enabled = featureFlags.extensionImport */);
// status:   'disabled' | 'unresolved' | 'loading' | 'ready'
// decision: null | 'yes' | 'later' | 'starting_fresh'   (meaningful only when status === 'ready')
// recordDecision(d: ImportOfferDecision): Promise<boolean>
```

Mapping to the frozen `ImportOfferCard` (`variant:'question'` → `onYes` / `onStartingFresh` / `onLater`; `variant:'value'` → `onLater`):

| Card callback | Call | In-memory effect (immediate) | Return |
|---|---|---|---|
| `onYes` | `recordDecision('yes')` | `decision === 'yes'` | `true` iff durably written on this device for the still-signed-in owner |
| `onLater` | `recordDecision('later')` | `decision === 'later'` | same |
| `onStartingFresh` | `recordDecision('starting_fresh')` | `decision === 'starting_fresh'` | same |

Rendering rule the host must honour (truthfulness, R18): render **nothing** while `status !== 'ready'`; when `ready`, `decision === null` means "no recorded answer on this device for this account" — NOT "eligible", NOT "never asked on another device". The boolean result is never a server claim; do not show "saved to your account". `false` needs no error UI: the tap is already reflected in memory and the offer is simply asked again on the next entry.

Guarantees a reviewer can check against the tests:
- No storage read/write when `enabled === false`.
- No write when identity is unresolved (an answer is never bound to a guessed owner).
- Identity change (A→null, A→B) on a live mount resets `decision` to `null` **before** B's read; A's answer never renders under B; a stale A read that settles later is discarded.
- A write that lands after sign-out/switch is removed again (`clearImportOfferDecision(owner)`) and reported `false`, so `signOut()`'s exact-key removal remains a completed boundary.
- Overlapping writes for the same owner are serialized: the latest answer in memory is the last one on disk.

## 3. Functional boundaries (deliberately NOT done)

- No Home eligibility inference (CQ-01 unresolved, server-side). The module remembers WHAT was answered, never decides WHETHER to ask.
- No C1 `intent`/current-session binding (S7-gated). No pairing, no token, no server copy, no new endpoint, no new flag, no new token store.
- No fake Start/Stop, no timer, no polling, no cadence, no "remind me at" (no timestamp stored; nothing compares to `Date.now()`).
- No analytics, no journey engine, no navigation, no controller, no copy, no UI control. The frozen sibling tree `377e4b7a…` (11 PR293 components + Settings label) is untouched and path-disjoint (intersection 0).
- S6 fix not reimplemented; accepted sign-out ordering and existing cache behaviour untouched (one constant array entry only).
- Sign-out semantics claim: clears the local answer only; makes no claim about desktop extension revocation (comment at the edit site).
- `SIGN_OUT_PREFIXES` export not renamed or restructured.

## 4. Design choice flagged for reviewers (reviewer-selectable, one-line swap)

**Chosen:** `IMPORT_OFFER_DECISION_KEY_PREFIX` in `PER_USER_KEY_PREFIXES` → on sign-out remove only `import_offer_decision:<signingOutUserId>` (same treatment as `macro_targets:`). Rationale: the record is non-secret, user-scoped, readable only under its owner's key; a whole-prefix sweep would re-offer bystander coaches on a shared device, contradicting "shown once per account".

**Alternative:** move the constant to `ASYNC_SIGN_OUT_PREFIXES` (whole-prefix sweep, the #291 treatment for the credential-bearing pairing mirror). Effect: removes every coach's answer on the device at any sign-out; closes the residual below at the cost of re-asking bystanders. Swap = move one array element and change the added `authActions.test.ts` assertion for the bystander key from `not.toBeNull()` to `toBeNull()`. Either choice keeps the S6 ordering.

Residual with the chosen option (Class C, recorded): if `resolveSigningOutUserId()` cannot resolve an id at sign-out, the signing-out coach's record persists on the device. Only that same coach's key can ever read it, and a payload/key mismatch is purged on read, so no cross-user leak results; the coach is simply not re-asked on that device.

## 5. Other Class C records (no A/B)

- **Class A/B: none.** No harm, no blocked decision, no minimum-closure or unlock request. Continue.
- C1: A→null→A within a single in-flight write window: the late write finds the owner signed in again and returns `true`; a mount read that settled before the write landed may hold `null` while disk holds the answer. Disk wins on next entry. Same bounded window class as #291.
- C2: The hook's identity source is `useCurrentUser()`; if the accepted identity source changes, this hook follows it automatically (no second identity path introduced).
- C3: Static-only assurance. Points a reviewer should confirm with the runtime gate the parent grants separately: (a) RNTL 14 `act`/`rerender` are async — all `act` calls in the hook test are awaited and `rerender` is awaited; (b) `jest.spyOn(AsyncStorage, …)` wraps the AsyncStorage 3.1.1 jest mock's plain arrow methods (not `jest.fn`s), so `mockRestore()` restores the original — confirmed by reading the installed mock source in the sibling's read-only `node_modules`, not by execution; (c) `it.each<[unknown]>` typing in the storage test; (d) `await rerender({})` where `rerender` returns `Promise<void>`.

## 6. Minimal new test targets (do not repeat S6)

```
npx jest src/storage/__tests__/importOfferDecision.test.ts \
         src/hooks/__tests__/useImportOfferDecision.test.tsx \
         src/services/__tests__/authActions.test.ts
npx tsc --noEmit
npx eslint src/storage/importOfferDecision.ts src/hooks/useImportOfferDecision.ts \
           src/services/authActions.ts src/storage/__tests__ src/hooks/__tests__/useImportOfferDecision.test.tsx \
           src/services/__tests__/authActions.test.ts
```

`authActions.test.ts` is included only because one test was added to it; the pre-existing S6 tests in that file run as a side effect, not as a new S6 cycle.

## 7. Proposed ordinary commit (not made)

```
feat(import): account-scoped offer-decision mirror and hook (UX-01)

Persist the coach's answer to the one-time Roman import offer per account
(import_offer_decision:<userId>, version 1, no timestamp) following the
accepted #291 user-scoped mirror pattern: cross-user purge on read, exact
key removed for the signing-out coach, late writes after sign-out removed.
Expose useImportOfferDecision(enabled) → {status, decision, recordDecision}
for the Home-card host. No eligibility inference, no intent binding, no
server copy, no new flag/endpoint/token store. Sign-out clears local app
state only and makes no claim about the desktop extension connection.
```

Author and committer: `Bradley Gleave <bradley@bradleytgpcoaching.com>`. No co-author trailer. Tree to commit: `a33cb8919495ed24e30623188dbb9f59c67df8bd` on parent `bc7b4e96fc1db54568bc209dbe1f7a4121501ac9`.

## 8. Recovery

Apply from the accepted base in any clean checkout of `bc7b4e96…`:

```
git apply --index execution/95633079/ux/account-state/UX01_ACCOUNT_STATE.patch
git write-tree   # must print a33cb8919495ed24e30623188dbb9f59c67df8bd
```
