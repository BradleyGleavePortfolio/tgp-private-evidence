# S6-P1 — changed-path / rationale map (source-only, frozen candidate)

Worktree `/home/user/workspace/worktrees/s6-diagnostic` at clean HEAD
`d51a191098f483cea9abec6cc7e9f3beffd18c06`, tree `62bf67b8…`, lock sha
`840be0b8…` (see `PINS.txt`). Nothing outside the nine files below was
written; git index/config/hooks/HEAD, node_modules, package/lock and all
existing result packets are unchanged.

## Product files

### 1. `src/services/queryClient.ts` (modified — blob `8a3f2820` → candidate sha256 `1c38d0fd…`)
- **Removed** the import-time anonymous persistence singleton
  (`asyncStoragePersister`), `resolveBootUserId()` and the
  `readUserCacheSync` import. That singleton resolved its key once at module
  load, before `lib/userCache` hydrates, so on every AsyncStorage-shim build it
  was `TGP_RQ_CACHE_V1:anonymous` for the whole process — the defect the
  hazard controls demonstrate (T1).
- **Added** `QUERY_CACHE_BUSTER = 'tgp-rq-v2-samples'` — the same string
  previously inlined in `App.tsx`'s `persistOptions`, now exported because the
  identity-bound persistence and the tests both need it.
- **Added** `createIdentityPersistence(userId, { client? })` →
  `{ userId, key, restore({timeoutMs}), retire(), drain({timeoutMs}), isRetired() }`.
  It wraps the pinned `createAsyncStoragePersister` over a **fenced storage
  adapter**, and owns its own restore (rather than
  `persistQueryClientRestore`) so the retirement/timeout fence sits between the
  storage read and `hydrate()`:
  - *write fence* — `setItem` is dropped when retired. The fence is evaluated
    at the actual write, not at `persistClient` entry, because
    `asyncThrottle` (query-async-storage-persister) accepts a call, then waits
    on `timeoutManager.setTimeout` and serializes before touching storage;
    a queued write can therefore reach storage a second or more after the
    identity has been replaced.
  - *restore fence* — the buster/max-age check mirrors
    `persistQueryClientRestore` exactly (`removeClient()` on expired/busted),
    then `hydrate()` runs only if the persistence is still live and the
    bounded window has not elapsed. A late read is discarded.
  - *fail-closed* — a write that was in flight at retirement and outlived the
    bounded drain removes its own key after it lands, so it cannot resurrect a
    purged blob.
  - subscription is `persistQueryClientSubscribe` with the unchanged
    `dehydrateOptions.shouldDehydrateQuery: q => q.meta?.persist !== false`.
- **Preserved unchanged**: `queryClient` defaults (`staleTime` 30 000,
  `gcTime` 600 000, `refetchOnWindowFocus`, retry/retryDelay, mutation retry),
  `QUERY_CACHE_KEY_PREFIX`, `persisterKeyForUser` (incl. `:anonymous`
  fallback), `QUERY_CACHE_MAX_AGE` (24 h), `purgePersistedQueryCacheForAllUsers`
  (derived-cache-only purge, legacy unsuffixed key included), throttle 1000 ms.
- **Added** `settleAndClearQueryCache(client?, { shouldContinue? })` — the
  minimum observed-lifecycle correction; see `LIFECYCLE_ANALYSIS.md`. No
  dependency change; no private library API is used (only `Query.observers`,
  `Query.removeObserver`, both public in the pinned d.ts).

### 2. `src/services/PersistedQueryCacheGate.tsx` (new — sha256 `7325287f…`)
Structural identity boundary. `userId` is the *committed* bootstrap identity:
`undefined` = bootstrap unknown (no read/write/clear/purge at all — distinct
from committed logged-out), `null` = committed logged-out, `string` = committed
user. Children render only while `committed === userId`, so a replacement
identity's children cannot be mounted while the previous identity's memory is
still present, and the previous children have already unmounted (their
observers detached) before the cache is cleared.

Transition order, identical for A→B, A→null, null→A and interrupted paths:
retire previous → bounded drain → `settleAndClearQueryCache()` → (null: purge |
user: bounded restore) → commit. A superseded transition stops at its next
checkpoint and never commits; retired-but-undrained persistences are carried in
a ref so the superseding transition drains them. `PERSISTED_CACHE_RESTORE_TIMEOUT_MS`
= 4000, `PERSISTED_CACHE_DRAIN_TIMEOUT_MS` = 1000 (values pinned by the staged
test). No general lifecycle framework, no new instrumentation.

*Deviation recorded:* the clear step is skipped while `memoryDirtyRef` is
false (cold boot before any identity restore). Rationale: at that point no
identity memory exists to leak, and clearing would cancel queries owned by
providers mounted **above** the gate (`ThemeProvider`/`useFoundingNumber` in
`App.tsx`), which is behaviour change outside the P1 defect. Every real
identity transition after the first commit still clears.

### 3. `App.tsx` (modified — blob `bac96bb7` → candidate sha256 `123162b2…`)
`PersistQueryClientProvider` → plain `QueryClientProvider client={queryClient}`;
`asyncStoragePersister` / `QUERY_CACHE_MAX_AGE` imports dropped (the file no
longer contains the string `asyncStoragePersister`). Tree order, ErrorBoundary,
AnalyticsProvider, StatusBar, ThemeProvider, BiometricUnlockGate, RootNavigator
and StatusBarBand are unchanged.

### 4. `src/navigation/RootNavigator.tsx` (modified — blob `3b5217da` → candidate sha256 `dd70665e…`)
- New `sessionUserId` state: `undefined` until the first bootstrap outcome;
  the cached user's id **only** when token present AND cached user readable AND
  `needs_role_selection !== 'true'`; `null` on every other outcome including
  the `catch` paths and the "token but no role" path.
- `<PersistedQueryCacheGate>` wraps the auth-state conditional **inside** the
  existing `NavigationContainer` (container, `ref`, `linking`, theme,
  `OfflineBanner` and the deep-link replay effects untouched; the container is
  never remounted). `Day1WinScreen` renders before the container and is
  therefore ungated, as before. `renderRestoring` reuses the existing
  `loadingContainer` spinner so the restoring phase looks like the existing
  loading phase.

### 5. `src/services/authActions.ts` (modified — blob `386a7802` → candidate sha256 `b7e0b7d5…`)
Only the query/persistence teardown coordination: the final `queryClient.clear()`
becomes `await settleAndClearQueryCache()`, still before
`authEvents.emit('logout')`. Everything else in `signOut` — order of push-token
update, notification unregister, workout-log delete, fasting cancel, the
`Promise.all` storage/secure/purge block (including
`purgePersistedQueryCacheForAllUsers`), `setSentryUser(null)`,
`analyticsReset()`, `resetUserScopedStores()` — is byte-identical. No auth
success/failure rule, credential, analytics or user-store semantic is touched.
This uses the express supersession of the old SOURCE-MAP `authActions`
exclusion, and only for the observed lifecycle defect.

## Test files

### 6. `src/services/__tests__/persistedQueryCache.identityGate.test.tsx` (new, staged copy — sha256 `44031dcb…`, byte-identical to staging)
### 7. `src/__tests__/rootNavigatorPersistedCacheGate.test.tsx` (new, staged copy — sha256 `b1ed2f46…`, byte-identical to staging)
Both placed unmodified. **No staged-test adaptation was required**; the
implementation was written to the contract they pin (`createIdentityPersistence`
outcomes, `PERSISTED_CACHE_RESTORE_TIMEOUT_MS`, `PERSISTED_CACHE_DRAIN_TIMEOUT_MS`,
`QUERY_CACHE_BUSTER`, `persisterKeyForUser`, gate props, `testID`s).

### 8. `src/services/__tests__/queryClient.persister.test.ts` (modified — blob `8377a44d` → candidate sha256 `ee59e4de…`)
Narrow adaptation to the changed public contract, **all four existing
assertions preserved verbatim**:
- removed the now-dead `jest.mock('../../lib/userCache')` (the module no longer
  imports `readUserCacheSync`; leaving the mock would assert a dependency that
  no longer exists);
- added one test asserting the contract change: no `asyncStoragePersister`
  export, `createIdentityPersistence` is a function, and importing the module
  performs no `getItem`/`setItem` (negative protection for the import-time
  singleton that was removed).

### 9. `src/services/__tests__/queryClient.signout.test.ts` (modified — blob `82ee0208` → candidate sha256 `ebeb7814…`)
Both existing privacy assertions preserved verbatim (cache empty after
`signOut`, and when already empty). Added one test for the **actual ordering
defect**: with a live `QueryObserver` subscribed, `signOut` must leave the
observer detached and the query removed, and the observer's later
`destroy()` (the real unmount path after `emit('logout')`) must not raise the
Jest timer count. That is the assertion a bare `clear()` fails.

## Explicitly not changed
`gcTime` 600 000 and all query defaults; no `clearAllTimers`/`forceExit`/`unref`
masking; no shortened cache lifetime; no test-only disposal of hidden query
objects; no C6 classifier change; no new instrumentation; no Node upgrade; no
package/lock/feature-flag/dependency edits; no test-infrastructure expansion;
no touch of offline workout/food mutations, broader AsyncStorage, native DB
rows or credentials; no writes under `source/mobile`, other lanes,
`node_modules`, existing result packets, canonical lock or `/tmp` scratch.
The frozen v5 hazard controls (`a91bb732…`) and adapter (`3796be8f…`) were read
only and were **not** placed in the worktree.
