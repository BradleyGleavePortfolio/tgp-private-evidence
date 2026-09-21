# S6-P1 — persisted query-cache identity: source-only hazard map (no code changed)

Worker `s6_r3_identity_fixer_mubv6s7c`, 2026-09-21. Status: **mapping only**. Checkpoint `d51a1910` untouched.
Nothing installed or executed. Requested model Claude Fable 5 / High (not verifiable in-session).

## 1. Pinned library lifecycle — validated from the exact locked sources

Lockfile pins `@tanstack/react-query-persist-client`, `query-persist-client-core`, `query-async-storage-persister`,
`query-core`, `react-query` all at **5.100.14**. Sources fetched read-only from unpkg into
`execution/s6-r3/lib-src/` (checksums in `SHA256SUMS.libsrc`). Facts that the follow-up design must respect:

| # | Fact (5.100.14) | Where |
|---|---|---|
| L1 | `PersistQueryClientProvider` restores **once per mount** (`didRestore` ref). Later changes to `persistOptions` (incl. a new `persister`) are captured in `refs.current` but never trigger a new restore; the subscribe effect re-runs only on `[props.client, isRestoring]`. | `PersistQueryClientProvider.tsx` |
| L2 | Therefore the only library-supported ways to re-key are **remounting the provider** (e.g. React `key`) or swapping `client`; swapping `client` re-subscribes but still does not restore. | same |
| L3 | Restore = `persister.restoreClient()` → if `timestamp` fresh and `buster` matches → `hydrate(queryClient, state)`. `hydrate` **merges into the existing client**; it never clears prior in-memory entries. Expired/busted/malformed → `removeClient()`. | `persist.ts` |
| L4 | Persistence is event-driven: every `added/removed/updated` cache event calls `persistQueryClientSave`, which **dehydrates at call time** and hands the snapshot to `persister.persistClient`. | `persist.ts` |
| L5 | `createAsyncStoragePersister.persistClient` is `asyncThrottle(interval = throttleTime = 1000 ms)`: if idle it executes **immediately**; otherwise it waits and then executes with **`lastArgs` = the most recent snapshot**. A queued write can therefore land up to ~1 s after the event that scheduled it, and after any purge that ran in between. | `asyncThrottle.ts`, `index.ts` |
| L6 | `restoreClient` = `storage.getItem(key)`; `removeClient` = `storage.removeItem(key)`; the `key` is fixed at persister construction. `storage: null/undefined` yields a **noop persister** (no restore, no write). | `index.ts` |
| L7 | App passes no `onSuccess`; nothing invalidates or clears after restore. | `App.tsx` L233–249 |

## 2. Actual app wiring (d51a1910 = 55db31a0 for these files, except the comment block)

- `src/services/queryClient.ts`: `asyncStoragePersister = createAsyncStoragePersister({ storage: AsyncStorage,
  key: persisterKeyForUser(resolveBootUserId()), throttleTime: 1000 })` — key resolved **at module import** from
  `readUserCacheSync()`. On the shipped AsyncStorage-shim composition that is `null` before hydration (R3 mirror
  is truthfully empty; pre-R3 the shim's sync read was always `undefined`), so the key is
  **`TGP_RQ_CACHE_V1:anonymous` for the whole process lifetime, for every user**.
- `App.tsx`: one `PersistQueryClientProvider` above `RootNavigator`, mounted at boot, never re-keyed; restore
  runs concurrently with `bootstrapAuth`.
- Controls that exist today: `purgePersistedQueryCacheForAllUsers()` (disk, all `TGP_RQ_CACHE_V1*` keys) at every
  sign-in (`LoginScreen` ×3, `CreateAccountScreen`, `RoleSelectionScreen`, after `setUserCache`) and inside
  `signOut()`'s `Promise.all`; `queryClient.clear()` (memory) **only in `signOut()`**, after the `Promise.all`
  and before `authEvents.emit('logout')`. The 401-refresh-failure path (`api.ts`) calls the same `signOut()`.
- Paths that make the device unauthenticated **without** `signOut()`: `bootstrapAuth` → `unauthenticated` when
  token or `user_data` is missing / `needs_role_selection` / user-parse failure (`clearUserCache()` only). On R2
  shim builds the identity was unreadable (S6-R2-A-01), so **every** R2 cold start took this path with the
  previous user's cache blob still on disk.

## 3. Hazards and whether current controls prevent a counterexample

| ID | Scenario | Deterministic? | Current control | Verdict |
|---|---|---|---|---|
| H1 | Authenticated user B's queries persist under the shared **`:anonymous`** key and are restored from it on every cold start. | Yes (by construction, L6 + import-time key). | none — namespacing is inert on shim builds | **Exit criterion "no anonymous shared-key restore for authenticated state" is violated deterministically.** Same-user only until combined with H2/H3. |
| H2 | B becomes unauthenticated via a non-`signOut` path (§2). Cold start restores B's blob into memory (L3) while the login screen shows. C signs in: `purge…()` removes disk, but **memory is never cleared on sign-in**. C's session serves B's hydrated entries for shared query keys until each refetch lands, and the first throttled save re-persists B's not-yet-refetched entries under `:anonymous` **for C** (L4/L5). | Yes, given the precondition (which R2 builds produced routinely). | purge (disk only) | **Cross-user counterexample, no race needed.** Discriminating test T2. |
| H3 | Normal `signOut()`: a query `updated` event lands during the awaited `Promise.all` (I/O window). Persister idle → **writes B's snapshot immediately, after the purge** (L5). `queryClient.clear()` then schedules an empty snapshot ~1 s later, which repairs the blob — unless the process is killed in that ≤1 s window. Next cold start restores B's PII (→ H2 continuation). | Race (fetch landing mid-sign-out + kill within ~1 s). | purge then clear ordering; the follow-up empty write | **Counterexample exists but is timing-bound**; deterministic only under fake timers (T3). Not accepted residual per parent. |
| H4 | Late/delayed write contaminating a *replacement* identity's key. | n/a today | — | Cannot occur today only because there is **one shared key**; i.e. H1 makes H4 moot in the worst possible way. Becomes a real hazard the moment keys become identity-bound (see §5 guard). |
| H5 | `hydrate` merges (L3): a restore that resolves after a sign-in has already populated the client overlays stale entries onto fresh ones. | Boot-order dependent | none | Real on slow storage; covered by T1/T2 timing variants. |
| H6 | Sign-out resurrection: after `signOut()` normal path (no race), remounting the provider restores nothing. | Yes | purge + clear | Expected to **hold** (positive control T4). |

Conclusion: existing purge/order does **not** already prevent a counterexample — H1 is deterministic and H2 is a
deterministic cross-user leak under a precondition the R2 defect itself created. A speculative rewrite is not
needed; the fix is a small identity-bound lifecycle (§5), but only after T1–T4 return the discriminating proof.

## 4. Discriminating tests to run first (real wiring, no mocked `lib/userCache`)

Harness: render the real `PersistQueryClientProvider` with the real `queryClient` + `asyncStoragePersister` from
`src/services/queryClient` over the AsyncStorage jest mock; real `lib/userCache`; `authActions.signOut` real with
its existing api/secureStorage mocks; fake timers for L5.

- **T1 cold restore from anonymous key** — seed `TGP_RQ_CACHE_V1:anonymous` with `{buster:'tgp-rq-v2-samples',
  timestamp: now, clientState: dehydrated ['me'] = B}`; mount; expect `queryClient.getQueryData(['me'])` = B.
  PASS ⇒ H1 proven.
- **T2 sign-in does not evict memory** — after T1, perform the LoginScreen sequence (`await setUserCache(C)`;
  `await purgePersistedQueryCacheForAllUsers()`); expect `getQueryData(['me'])` **still** B; trigger one cache event
  and advance 1 s; expect the anonymous blob on disk to contain B's `['me']` again. PASS ⇒ H2 proven.
- **T3 mid-sign-out late write** — with B's data in the client, start `signOut()`; while its `Promise.all` is
  pending, `queryClient.setQueryData(['me'], B')`; let `signOut` resolve; **do not** advance timers (simulated
  kill); expect disk blob under `:anonymous` to contain B'. Then advance 1 s; expect it to be emptied (shows the
  repair and the window). PASS ⇒ H3 proven with an exact window.
- **T4 normal sign-out control** — `signOut()`, advance 2 s, unmount/remount provider; expect no restored entries
  and no `TGP_RQ_CACHE_V1*` keys with data. Must PASS before and after any fix.
- **Negative control** — T1–T3 must FAIL after the fix; T4 must still pass; `EXPO_PUBLIC_FF_*` untouched.

## 5. Minimal identity-bound lifecycle — design only, for parent authorization (existing primitives, no deps)

Ownership limited to `App.tsx` provider composition, `src/services/queryClient.ts`, and dedicated tests.

1. `queryClient.ts`: `createPersisterForIdentity(userId | null)` → for `null` return
   `createAsyncStoragePersister({ storage: null })` (**noop**, L6: logged-out state never restores or writes);
   for a user return the AsyncStorage persister keyed `persisterKeyForUser(userId)`. Wrap `persistClient` with a
   `retired` flag so a throttled write scheduled before an identity change is dropped (**H4 guard**; L5).
   Remove the import-time `asyncStoragePersister` singleton (or keep as `@deprecated` noop for tests).
2. `App.tsx`: derive `identityKey` from the existing `useCurrentUser()` + `isUserCacheHydrated()` (R3 export).
   While unhydrated → render the noop persister (no anonymous restore of anything). Mount
   `<PersistQueryClientProvider key={identityKey} …persister={createPersisterForIdentity(id)}>` so every identity
   change **remounts** → fresh restore from the identity's own key (L1/L2), old subscription torn down by effect
   cleanup, old persister retired.
3. On identity change (A→B, null→B, B→null) call `queryClient.clear()` **before** the remount commits
   (tiny effect keyed on `identityKey`) so `hydrate` (L3) cannot merge onto another identity's entries.
   Sign-in purge stays as belt-and-braces; sign-out path unchanged.
4. Cost: ~40 lines; no dependency, flag, crypto, backend or broad App change. Restore latency: gated on identity
   hydration (one AsyncStorage read) instead of running blind at boot.

Open questions for the parent boundary: (a) whether children below the provider may briefly render with
`isRestoring=true` twice (remount) — `useIsRestoring` has no consumers in `src/` today (checked); (b) whether
`RootNavigator`'s own `readUserCache()` bootstrap should be the single identity source instead of `useCurrentUser`
inside `App.tsx` (both are existing primitives; the former needs a prop or context — slightly wider surface).

## 6. Provenance

- App/queryClient/authActions/LoginScreen/RootNavigator read from `worktrees/s6-r3` at `d51a1910`.
- Library facts from `execution/s6-r3/lib-src/*` (unpkg, versions exactly as in `package-lock.json`).
