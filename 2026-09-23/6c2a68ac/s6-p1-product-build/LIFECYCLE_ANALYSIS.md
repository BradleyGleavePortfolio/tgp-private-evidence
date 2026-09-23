# S6-P1 — cancellation / observer removal / clear / old-write completion

Source analysis only. All line references are to the **pinned** installed
substrate in `worktrees/s6-diagnostic/node_modules`, `@tanstack/*` 5.100.14
(`query-core`, `query-persist-client-core`, `query-async-storage-persister`),
RNTL 14.0.0, React 19.2.3, Node v20.20.1. Nothing here was executed; no
runtime claim is made.

## 1. The observed defect (C6 outcome i), traced in the pinned sources

C6 recorded two persistent 600 000 ms `Timeout` objects (asyncIds 7343/7893)
created via `Query.removeObserver → scheduleGc → TimeoutManager.setTimeout`
(`query-core/src/query.ts:377`, `removable.ts:18`, `timeoutManager.ts:44/108`)
that survived the suite's `cancelQueries()` + `clear()` teardown. The pinned
code explains exactly how that state is reachable:

- `QueryClient.clear()` (`queryClient.ts:632`) → `QueryCache.clear()`
  (`queryCache.ts:158`) → for each query `remove(query)` (`queryCache.ts:144`)
  → `query.destroy()` then `#queries.delete(hash)`.
- `Query.destroy()` (`query.ts:259`) = `super.destroy()` → `clearGcTimeout()`
  (`removable.ts:10/31`), then `this.cancel({ silent: true })`.
  **It does not touch `this.observers`.**
- So after `clear()`, every still-mounted `useQuery` keeps a `QueryObserver`
  whose `#currentQuery` is an object that is no longer in the cache map.
- When that observer later detaches — `QueryObserver.destroy()`
  (`queryObserver.ts:131-136`, reached from `onUnsubscribe` at :109 on unmount)
  or `#updateQuery()` (`queryObserver.ts:703-719`, on its next render, which
  calls `prevQuery.removeObserver(this)`) — `Query.removeObserver()`
  (`query.ts:362`) sees the observer list drop to empty and calls
  `scheduleGc()` (`query.ts:377`). `Removable.scheduleGc()` arms a
  `gcTime` (600 000 ms) timer whose callback is `optionalRemove()`
  (`query.ts:226`) on an object already deleted from the cache.
  **Nothing holds a reference that can clear it**: the only clear paths are
  `addObserver` (`query.ts:356`), `destroy()` and a further `scheduleGc()`,
  none of which will run for an unreachable query. The timer keeps the event
  loop alive for its full 600 s.
- A second re-arm path exists: `Query.#fetch`'s `finally { this.scheduleGc() }`
  (`query.ts:621-623`). `destroy()`'s `cancel({ silent: true })` rejects the
  retryer (`retryer.ts:88-94`) *after* `clearGcTimeout()` has run, so the
  awaiting `#fetch` resumes later and re-arms gc on the orphan too.
- `removeObserver` is guarded by `if (this.observers.includes(observer))`
  (`query.ts:363`), so **detaching an observer while the query is still cached
  makes every later call on it inert** — this is the property the fix uses.

Note what does *not* fix it: `queryClient.cancelQueries()` alone
(`queryClient.ts:276-289`) settles fetches but leaves observers attached, so a
subsequent `clear()` still produces orphans; and a single added `await` before
`clear()` changes nothing, because the re-arm happens *after* the clear, from
the observer side. The grant's caution here is borne out by the source.

## 2. The correction

`settleAndClearQueryCache(client = queryClient, { shouldContinue? })` in
`src/services/queryClient.ts`:

1. `await client.cancelQueries()` — settles in-flight fetches **while their
   queries are still cached**. Each `Query.cancel()` rejects the retryer, the
   `#fetch` `finally` re-arms gc, and the cancel promise resolves after that
   `finally` runs (it is `retryer.promise.then(noop).catch(noop)`,
   `query.ts:253-257`), so the re-armed timer is still clearable at step 3.
2. Detach every observer from every cached query
   (`query.removeObserver(observer)` over a copy of `query.observers`). Each
   call arms gc on a **cached** query — which step 3 then clears — and makes
   the observer's own later `destroy()`/`#updateQuery()` call a no-op.
3. `client.clear()` — `destroy()` clears each gc timeout for good and empties
   the cache synchronously.

`shouldContinue` lets the gate abandon a superseded transition between steps 1
and 2 instead of clearing a cache the superseding transition has rebuilt.

Properties: privacy is not weakened (the cache is still emptied in the same
call, before `authEvents.emit('logout')` in `signOut`); `gcTime` is unchanged;
no timer is unref'd, faked or force-cleared; detached observers re-attach to
fresh `Query` objects on their next render exactly as they would after a plain
`clear()` (`#updateQuery` builds a new query and `addObserver`s it when the
observer has listeners), or are destroyed on unmount.

Mutations: `MutationCache.clear()` (`mutationCache.ts:190`) drops its map
without calling `Mutation.destroy()`, and `Mutation.removeObserver()`
(`mutation.ts:143`) also calls `scheduleGc()`. Pending offline mutations are
explicitly out of scope for P1 and are **not** touched here; `clear()` keeps
its existing mutation behaviour.

## 3. Transition-by-transition

Throughout: the gate renders children only while `committed === userId`, so the
identity change itself unmounts the previous identity's subtree in the commit
that schedules the transition effect. React runs that subtree's passive
cleanups (hence `QueryObserver.destroy()` → `removeObserver` on still-cached
queries) before the gate's effect body runs.

### A → B (in-session replacement, no signOut)
1. A's children unmount; their observers detach from live queries (harmless,
   gc armed on cached queries).
2. Gate effect: `A.retire()` — unsubscribes A's persistence and fences its
   storage writes. Any write `asyncThrottle` still has queued
   (`asyncThrottle.ts`: it may sit in `timeoutManager.setTimeout(interval)`
   loops for ≥ 1 s) is dropped at `setItem`, so A's bytes can never be written
   after retirement — this is the "fenced at the actual write" requirement.
3. `A.drain({1000})` — waits for writes already inside `AsyncStorage.setItem`.
   On expiry, `drainTimedOut` makes those writes self-remove their key when
   they land (fail-closed).
4. `settleAndClearQueryCache()` — A's in-memory data is gone, with no orphan
   gc timers (§2). B's children do not exist yet.
5. `createIdentityPersistence('user-B').restore({4000})` reads **B's own key**
   only (`TGP_RQ_CACHE_V1:user-B`); no anonymous key is ever touched.
6. Commit B → B's children mount and can only ever observe B's memory.

A's deferred restore resolving late: its `restore()` already returned (or its
race already settled); on resumption the `retired` check short-circuits before
`hydrate()`, so nothing of A enters B's session, and nothing of A is
re-persisted (A is unsubscribed and write-fenced).

### A → null (committed logout, incl. the `signOut` path)
Same steps 1-4, then `purgePersistedQueryCacheForAllUsers()` removes every
`TGP_RQ_CACHE_V1*` key, then commit `null`. No persistence object exists for
the logged-out state, so nothing is read or written while logged out. A write
that outlived the drain removes its own key after landing, so it cannot
resurrect the purged blob.

`signOut()` itself runs *before* this, while the signed-in screens are still
mounted (`authEvents.emit('logout')` at the end is what drives
`bootstrapAuth` → `sessionUserId = null` → the gate transition). That is
precisely the ordering that made the bare `clear()` unsafe, and why
`settleAndClearQueryCache()` is the one change made there.

### null → A (cold boot / sign-in)
`sessionUserId` is `undefined` until bootstrap completes: the gate reads,
writes, clears and purges nothing (bootstrap-unknown is distinct from
committed logged-out). On a committed user, A's own key is restored under a
4 s bound; on a committed logged-out outcome, the purge runs. Sign-in screens
still call `purgePersistedQueryCacheForAllUsers()` after `setUserCache()` —
unchanged and still correct, since it runs before the new identity's
persistence is created.

### Interrupted transitions (A → B → A, A → B → null, replaced mid-restore)
`transitionRef` invalidates the superseded async body at every checkpoint
(after drain, after clear, after restore), and a persistence created by a
superseded transition is retired by the effect cleanup and re-drained by the
superseding one via the retired set, so no in-flight write is ever dropped
from the drain accounting. A superseded transition never calls `setCommitted`,
so no identity other than the requested one can be committed — including when
its own restore timeout fires after it was replaced.

### Bounded restoring phase
`restore({timeoutMs})` races the storage read against a timer. On timeout the
gate still commits (children render with an empty cache — no deadlock), the
persistence subscribes so live data is persisted normally, and the late read
is discarded at the restore→hydrate boundary so a stale blob can never
overwrite the live session.

## 4. Expected effect on the frozen v5 hazard suite (source reasoning only)

The frozen adapter (`3796be8f…`) capability-detects `qc.asyncStoragePersister`;
with the candidate that export is gone, so it takes the postfix branch,
requires `../PersistedQueryCacheGate` (present, both named and default export
with `{ userId, children }`) and renders
`<QueryClientProvider client={qc.queryClient}><Gate userId={identity}>`.
`qc.QUERY_CACHE_BUSTER === 'tgp-rq-v2-samples'` holds; `App.tsx` contains
`<QueryClientProvider client={queryClient}` and no longer contains the string
`asyncStoragePersister`; `RootNavigator.tsx` contains `<PersistedQueryCacheGate`.
So T-WIRING/T0/T4 should execute, and T1/T2/T3 should fail on their intended
hazard assertions (anonymous-key restore, A-memory visible to C, late write
surviving purge) because the candidate structurally prevents each. This is the
expectation to be **verified by execution**, not a result.
