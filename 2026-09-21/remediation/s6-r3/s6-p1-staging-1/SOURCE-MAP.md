# S6-P1 — identity-bound persisted query cache: source map (prepared, NOT applied)

Base for the follow-up: frozen `d51a1910` (parent-preserved as `955b80c`). Nothing below is in the worktree yet;
staged tests live in `execution/s6-r3/s6-p1/staging/` mirroring repo paths. Worker `s6_r3_identity_fixer_mubv6s7c`.
Requested model Claude Fable 5 / High (not verifiable in-session).

## 0. Sequencing (parent: implement only after discriminating controls run)

1. Slot A (heavy, after `npm ci`): copy `staging/src/services/__tests__/persistedQueryCache.hazardControls.test.tsx`
   **and** `persistedQueryCache.hazardAdapter.tsx` into the worktree **untracked**, run alone against d51 → expected
   log line `[mode=d51-singleton]`, T-WIRING/T0/T1/T2/T3/T4 all PASS. Log → `execution/s6-r3/logs/s6-p1-hazard-controls-d51.log`.
   If T1/T2/T3 do not reproduce, STOP and report (the fix is then unjustified). Also run
   `queryClient.persister.test.ts` + `queryClient.signout.test.ts` as baselines.
   The adapter is capability-detected (singleton present → d51 wiring; else lazy-require of the gate), so the
   post-fix run cannot fail by import/module-load or an early T0: identical inputs and hazard assertions run in
   both modes and T1–T3 must FAIL on their own `expect`s (behavioural flip) while T4 executes and PASSes.
   Both mode branches live in the one adapter file; both run logs are preserved. Provenance of the overwritten v1
   control file: see `PRESERVATION-NOTE.md` (unavailable, unexecuted, never reconstructed).
2. Implement §2 on a new commit above d51 (same branch `execute/20260921-s6-r3`; d51 itself stays intact). Copy the
   two required suites from staging. Commit with verified identity.
3. Re-run the hazard-control file + adapter against the fixed tree → expected `[mode=postfix-gate]`, T-WIRING PASS,
   T0 PASS (fingerprint now reports the identity key), **T1 T2 T3 FAIL on their hazard assertions**, T4 PASS. Log →
   `logs/s6-p1-hazard-controls-postfix.log`. Then delete both files from the tree (controls, not regression tests).
4. Full validation per PLAN.md under the canonical absolute lock, durable execution (see §6), exports ON + OFF.

## 1. Identity authority (decision (b))

Single source of truth = `RootNavigator.bootstrapAuth`'s committed result: `token present AND readUserCache()
non-null AND no needs_role_selection` → `authState ∈ authenticated states` + new `sessionUserId`. `useCurrentUser`
/ `readUserCache` alone never authorize a restore. Invalid token at runtime → existing `api.ts` 401 path →
`signOut()` → bootstrap → unauthenticated → gate retires (no new authority created).

## 2. Planned changes (exact)

### 2.1 `src/services/queryClient.ts`
- Remove: `import { readUserCacheSync }`, `resolveBootUserId()`, `export const asyncStoragePersister` (superseded
  singleton; only consumer is App.tsx — verified by rg), the P1-1 and R3 assessment comment blocks (replace with the
  new rationale).
- Keep: `queryClient`, `QUERY_CACHE_KEY_PREFIX`, `persisterKeyForUser`, `purgePersistedQueryCacheForAllUsers`,
  `QUERY_CACHE_MAX_AGE`.
- Add: `export const QUERY_CACHE_BUSTER = 'tgp-rq-v2-samples'` (moved from App.tsx literal; unchanged value so
  existing blobs stay valid for the same user).
- Add `createIdentityPersistence(userId, opts?)` built ONLY from declared-dependency exports:
  `createAsyncStoragePersister` (`@tanstack/query-async-storage-persister`), `persistQueryClientRestore` +
  `persistQueryClientSubscribe` (re-exported by `@tanstack/react-query-persist-client`, verified in pinned index).

  ```ts
  export interface IdentityPersistence {
    readonly userId: string; readonly key: string;
    restore(opts?: { timeoutMs?: number }): Promise<'restored' | 'empty' | 'timeout' | 'retired' | 'failed'>;
    retire(): void;           // idempotent: unsubscribe + fence reads/writes at execution time
    drain(opts?: { timeoutMs?: number }): Promise<'drained' | 'timeout'>; // 'timeout' = write still outstanding, never silent
    isRetired(): boolean;
  }
  ```
  Implementation notes (pinned-API driven, see hazard map §1). No reliance on microtask-ordering arguments:
  every fence is a synchronous check at the exact boundary where bytes move or state hydrates.
  - **Fenced storage** passed to `createAsyncStoragePersister({ storage: fenced, key, throttleTime: 1000 })`:
    `setItem` checks `retired` **at execution** (inside the library's `asyncThrottle` callback) and drops the write;
    otherwise `inflight = (async () => { await realSetItem(key, v); if (retired) await realRemoveItem(key); })()`
    so `drain()` can await it and — **fail-closed** — a write that was already inside storage when retirement
    happened deletes its own result the moment it completes. A completion cannot be stopped, so it is compensated at
    the only point it becomes observable; cache-only (this key), no other storage touched. `getItem` passthrough (the
    restore-side fence sits at hydrate, below). `removeItem` passthrough.
  - **Restore→hydrate fence (own restore, existing primitives only)**: `restore()` does
    `const c = await persister.restoreClient()` then, synchronously in the same tick:
    `if (retired || restoreFenced) return 'retired'|'timeout'; if (!c) → 'empty'; if (c.buster !== QUERY_CACHE_BUSTER
    || Date.now() - c.timestamp > QUERY_CACHE_MAX_AGE) { await persister.removeClient(); → 'empty' }
    hydrate(queryClient, c.clientState) → 'restored'`. `hydrate` is exported by `@tanstack/react-query`; this is
    exactly `persistQueryClientRestore`'s logic with the fence placed between read completion and hydrate, so a
    stale completion can never hydrate after retirement or timeout regardless of scheduling. On throw →
    `removeClient()` best-effort, `'failed'`.
  - **Bounded restore**: with `timeoutMs`, `Promise.race` against a timer; on timeout set `restoreFenced = true`
    (late completion discarded at the fence above), return `'timeout'`. Subscribing happens in both the
    `'restored'`/`'empty'` and `'timeout'` outcomes (never when retired):
    `unsubscribe = persistQueryClientSubscribe({ queryClient, persister, buster: QUERY_CACHE_BUSTER,
    dehydrateOptions: { shouldDehydrateQuery: (q) => q.meta?.persist !== false } })`, so live data of the
    committed identity persists while stale disk data is never re-introduced.
  - `retire()`: `retired = true; unsubscribe?.()`. `drain({timeoutMs})`: `Promise.race([inflight → 'drained',
    timer → 'timeout'])`; `'timeout'` means the write is still outstanding — the gate proceeds (bounded) but the
    compensation above guarantees the eventual completion is removed again, so the purge is never claimed as final
    over a write that can recreate the blob. Both outcomes are tested.
- `purgePersistedQueryCacheForAllUsers` unchanged (still called by sign-in screens and `signOut`; belt-and-braces).

### 2.2 `src/services/PersistedQueryCacheGate.tsx` (new, provider-composition piece)
```tsx
export const PERSISTED_CACHE_RESTORE_TIMEOUT_MS = 4000;
export function PersistedQueryCacheGate({ userId, children, renderRestoring }): JSX.Element
```
- Props: `userId: string | null | undefined` — `undefined` = bootstrap not yet committed (render restoring, do
  nothing: no purge, no restore); `null` = committed unauthenticated; string = committed identity.
- State `committed: string | null | undefined`.
- **Render**: `if (userId === undefined || committed !== userId) return renderRestoring?.() ??
  <ActivityIndicator testID="persisted-cache-restoring" />`. Children are structurally unmounted the instant
  `userId` changes and cannot observe old memory (parent: clearing before children can observe, not passive).
- **Effect on `[userId]`**, with a per-run `cancelled` flag so an older run never commits (pins "timeout never
  commits another identity"):
  1. previous cleanup already ran `prev.retire()` (fences writes/hydrate immediately);
  2. `await prev.drain({ timeoutMs: PERSISTED_CACHE_DRAIN_TIMEOUT_MS })` (`export const
     PERSISTED_CACHE_DRAIN_TIMEOUT_MS = 1000`; a hung native write cannot block auth forever; on `'timeout'` the
     retired identity's self-removing write is the fail-closed guarantee);
  3. `queryClient.clear()`;
  4. `userId === null` → `await purgePersistedQueryCacheForAllUsers()` (explicit logout lifecycle: nothing left
     to resurrect, closes the T3 late-write race deterministically because it runs after retire+drain) →
     `setCommitted(null)`;
     string → `p = createIdentityPersistence(userId)`; `await p.restore({ timeoutMs:
     PERSISTED_CACHE_RESTORE_TIMEOUT_MS })` (any outcome) → `if (!cancelled) setCommitted(userId)`.
  Cleanup: `cancelled = true; p?.retire()`.
- Parent decision (5:06 PM mail): YES — on the committed unauthenticated/null transition, purge derived persisted
  query-cache blobs under `QUERY_CACHE_KEY_PREFIX` (incl. cold cached-user/missing-token). Cache invalidation only:
  pending workout/food/offline mutations, broader AsyncStorage, native DB rows and credentials are NOT touched
  (`purgePersistedQueryCacheForAllUsers` already filters to the prefix — no change to it).
- No `IsRestoringProvider` needed: children are not mounted while restoring (no `useIsRestoring` consumers in
  `src/`, checked).

### 2.3 `App.tsx`
- Replace `PersistQueryClientProvider` + `persistOptions` block with plain `QueryClientProvider client={queryClient}`
  (from `@tanstack/react-query`, declared). Remove imports of `asyncStoragePersister`, `QUERY_CACHE_MAX_AGE`,
  `PersistQueryClientProvider`. Comment explains the gate lives in RootNavigator.
- Behaviour change to report: public queries above RootNavigator (`useFoundingNumber` in ThemeProvider) are no
  longer restored from disk while logged out; while logged in they persist under the identity key like everything
  else.

### 2.4 `src/navigation/RootNavigator.tsx` (composition only)
- `const [sessionUserId, setSessionUserId] = useState<string | null | undefined>(undefined)` (undefined while
  `authState === 'loading'` so the gate neither purges nor restores before bootstrap commits).
- In `bootstrapAuth`: every `setAuthState('unauthenticated')` site (5 incl. catch) also `setSessionUserId(null)`;
  after the `token && parsedUser && !needsRoleSelection` checks pass: `setSessionUserId(parsedUser.id)`.
- Wrap the stack conditional **inside** `NavigationContainer` (container itself never remounts, so
  `navigationRef` / accept-invite replay `isReady()` loop keep working):
  ```tsx
  <OfflineBanner />
  <PersistedQueryCacheGate userId={authState === 'loading' ? undefined : authState === 'unauthenticated' ? null : sessionUserId}
                           renderRestoring={() => <View style={styles.loadingContainer}><ActivityIndicator …/></View>}>
    {…existing conditional unchanged…}
  </PersistedQueryCacheGate>
  ```
  `Day1WinScreen` (outside the container, no query usage — verified by rg) stays ungated.
- Nothing else in RootNavigator changes; deep-link, sync and reconcile effects untouched.

### 2.5 Tests
- Add staged `persistedQueryCache.identityGate.test.tsx`, `rootNavigatorPersistedCacheGate.test.tsx`.
- `queryClient.persister.test.ts`: its `jest.mock('../../lib/userCache', …)` becomes unnecessary (module no longer
  imports userCache) — leave or drop; assertions unchanged.
- `queryClient.signout.test.ts`: unchanged (still asserts `queryClient.clear()` in `signOut`).
- Remove hazard-control file after step 3 (logs retained).

### 2.6 Explicitly NOT changed
`package.json`/lockfile, feature flags, crypto, backend, `authActions.signOut` order, sign-in purges, `lib/userCache`,
`useCurrentUser`, any screen.

## 3. Exit-criteria → test matrix

| Parent exit criterion | Pinned by |
|---|---|
| No anonymous shared-key restore/write for authenticated state | identityGate `afterEach` global assertion; RootNavigator "WITH token" test |
| Delayed old restore cannot contaminate replacement identity | identityGate "deferred OLD restore" |
| Queued/throttled old write fenced at actual write | identityGate "queued/throttled OLD storage write" (write count + blob content on both keys) |
| Clearing before new private children observe old memory | identityGate "A→B" frame log (`frames`), "A→null" |
| Cached user + token missing must not restore | RootNavigator "MISSING token", "needs_role_selection" |
| Normal same-user restore | identityGate "normal same-user restore"; RootNavigator "WITH token" |
| Normal logout | identityGate "A→null"; hazard T4 (kept passing pre/post) |
| Bounded restoring phase, no bootstrap deadlock | identityGate "bounded restoring"; RootNavigator "hung read" |
| Timeout never re-introduces stale/old-identity memory | identityGate "restore completing AFTER the timeout is discarded", "timeout never commits another identity"; unit `restore({timeoutMs})` |
| Delayed old restore / queued old write under LOGGED-OUT identity | identityGate "A → logged out (null) with delayed OLD operations" (2 tests) |
| Actual in-flight write drained before replacement commit | identityGate "in-flight OLD storage write is drained"; unit `drain()` → 'drained' |
| Drain timeout is explicit and fail-closed (old completion cannot recreate the blob after purge) | identityGate "OLD write still in flight when the bounded drain expires"; unit `drain({timeoutMs})` → 'timeout' + self-remove |
| Max-age / buster / error semantics preserved | own restore mirrors `persistQueryClientRestore` (removeClient on stale/mismatch/throw); existing `queryClient.persister.test.ts` unchanged |
| Hazard controls flip behaviourally, T4 executes both sides | hazardControls v2 + adapter, two logs |
| Superseded singleton removed | T-WIRING post-fix asserts App.tsx has no `asyncStoragePersister`; rg = 0 hits |
| OFF remains OFF | exports ON + OFF residue greps (PLAN.md); no flag touched |

## 4. Known verification items at slot time (cannot be settled statically)
- The AsyncStorage jest mock must expose `removeMany` (app code calls it; sign-out tests mock it). If absent, the
  hazard T3/T4 `signOut` path needs the same `removeMany` shim as `queryClient.signout.test.ts` — do not change app code.
- `jest.spyOn(qc, 'purgePersistedQueryCacheForAllUsers')` relies on babel CJS export shape; fallback: hook
  `AsyncStorage.getAllKeys`.
- Fake timers + `asyncThrottle` (`timeoutManager.setTimeout` → global setTimeout) — confirm with the "queued write"
  test; if `timeoutManager` captured real timers at import, switch that test to real timers with 1.2 s waits.
- RootNavigator harness: confirm no additional module needs mocking under the real AsyncStorage mock (the
  accept-link harness stubs AsyncStorage; this one uses the real mock so `readUserCache` is real).

## 5. Ambiguities → stop-and-escalate triggers
- If `NavigationContainer` requires a navigator child at mount for `linking` handling in a way the spinner child
  breaks (unknown statically) → stop; alternative is gating inside each navigator (wider surface).
- If any pre-auth screen (AuthNavigator subtree) depends on persisted public queries → report; not gated by design.

## 6. Durable execution for the granted run (per parent scheduling warning)
`setsid nohup bash run.sh > logs/run.log 2>&1 & echo $! > logs/run.pid` with `run.sh` holding the canonical lock
`flock -n /home/user/workspace/execution/test-validation.lock -c '…'` for the whole run and writing
`logs/EXIT_RECORD` (`<cmd> <exit code> <utc>` per step) as the completion signal; verify liveness with
`kill -0 $(cat logs/run.pid)` and lock ownership with `flock -n … true` failing, never by log presence.
