# S6 R3 identity fixer — checkpoint report (source complete, validation pending slot)

Worker: `s6_r3_identity_fixer_mubv6s7c` · Role: S6 R3 builder (T4). Requested model: Claude Fable 5 / High —
**not verifiable in-session**; reported as requested, not observed.

## Exact fingerprint

| Item | Value |
|---|---|
| Worktree / branch | `/home/user/workspace/worktrees/s6-r3` · `execute/20260921-s6-r3` |
| Frozen base (parent of R3 commit) | `55db31a0696ebd07d0cb9abb18ffd31dce29457d` (tree `130ef9bfdcdbc038b87466529f5980e759f3451a`) |
| **R3 head** | `d51a191098f483cea9abec6cc7e9f3beffd18c06` (tree `62bf67b88e0f123f1a23ee34a1a75cb43029d9fb`) |
| Dirty state | **clean** (`git status --porcelain` empty after commit) |
| Author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` both; `git var` verified before, `%an/%ae/%cn/%ce` verified after; no trailers |
| Remote | none pushed (`origin` unchanged, no push performed) |
| Bundle | `execution/s6-r3/s6-r3.bundle` — `a5933fd6..execute/20260921-s6-r3`, requires public main `a5933fd6`; `git bundle verify` = okay |
| Delta | `execution/s6-r3/delta.patch` (+ `delta.stat`): 25 files, +1195 / −153 vs 55db31a0 |
| package.json / lockfile | unchanged from 55db31a0 |
| Recovered base | `initialization/recovered/s6-r2-final-55db31a0` untouched |

Edits were made with the `edit`/`write` tools and Python string replacement — `apply_patch` is not available in
this session (mandate says "where available").

## Delta — reimplementation of the unpreserved R3 scope (labelled as such in the commit)

### 1. Async identity/cache hydration (`src/lib/userCache.ts`, rewritten)
- Root cause closed (S6-R2-A-01 / S6-B2-1): on the shipped composition `storage/mmkv` resolves to the AsyncStorage
  shim whose `getString` is always `undefined`; the old read path never consulted `getStringAsync` for the
  namespaced key, so a freshly written identity was unreadable and the legacy migration could delete the only copy.
- New read order: sync native (`getString`) → `await prefsStorage.getStringAsync('auth.user_data')` → legacy raw
  `user_data`; migration writes the namespaced key, **reads it back and compares**, and only then removes legacy
  (so a failed write leaves the legacy copy; the migration is repeatable).
- In-memory `mirror` + `hydrated` + `generation`; `readUserCacheSync()` = native value else mirror;
  `isUserCacheHydrated()` exported. Single-flight `inflightRead`.
- `setUserCache/patchUserCache/clearUserCache` are **async** and awaited at every call site (LoginScreen ×3,
  CreateAccountScreen, RoleSelectionScreen, EditProfileScreen, ReadyScreen, finalizeLeanOnboarding,
  RootNavigator, authActions). Nothing async hides behind a sync API; sync readers are truthful about hydration.
- Generation fence: mutations bump `generation` and update the mirror synchronously before the storage write;
  a hydration that started earlier discards its result if the generation moved (`commitRead`). Patch hydrates
  first (cold-process patch cannot wipe unseen fields), merges against the mirror at merge time.
- `readUserCache()` always consults storage (never mirror-only) because raw legacy writers still exist:
  `utils/googleAuth.ts`, `utils/appleAuth.ts`, `RecipesScreen.tsx` (not modified — out of scope, noted).

### 2. Logout / account-switch isolation
- `services/authActions.ts`: `clearUserCache()` is the first entry of the sign-out `Promise.all`, i.e. before
  `authEvents.emit('logout')`; `resolveSigningOutUserId` gains an `await readUserCache()` step so the per-user
  wipe resolves on the shim composition (previously silently unresolved).
- `hooks/useCurrentUser.ts`: effect-local mounted/epoch fence; logout bumps the epoch and applies `null`, so an
  in-flight hydration cannot resurrect the signed-out user; login re-reads.
- `RootNavigator.tsx`: `await clearUserCache()` on bootstrap failure.

### 3. Food-log queue captured-owner fence (`src/services/foodLogQueue.ts`)
- `currentOwnerId()` captured once per operation; every write-back goes through `writeQueueFenced(owner, queue)`
  which throws exported `FoodLogQueueOwnerChangedError` if the owner differs at write time.
- `flush()`: owner re-checked at the top of each iteration; `commitRemoval(item)` performs the fenced write; on
  refusal the loop stops, memory and disk stay untouched, counters are not incremented.
- **Deliberate contract change vs P2-1 test** ("captures userId once… sign-out mid-flush"): predecessor kept
  POSTing the remaining items under whatever credentials the device now held and drained user-A's key.
  New expectation: `logFood` called once, `flushed 0 / remaining 2`, user-A disk queue `[a,b]` intact
  (retry is idempotent by `client_uuid`), anonymous key untouched. Test updated in place with rationale.
- No blind attribution: an anonymous queue is never merged into a signed-in user's queue by R3
  (`mergeAnonymousQueueIntoUser` unchanged; not called from app code).

### 4. No blind attribution of NULL legacy rows (`src/offline/database.ts`)
- Removed `UPDATE workout_logs SET user_id = ? WHERE user_id IS NULL` backfill. Unowned rows remain unowned;
  `pushPending` already filters `user_id = ?`, so they are neither pushed for nor shown to the current user.
  `syncEngine.test.ts` fake DB tolerates the absence (checked statically).

### 5. Bounded identity wait + truthful pairing copy
- `hooks/useExtensionPairing.ts`: new status `identityUnavailable`, `export const IDENTITY_WAIT_MS = 8000`,
  `FailReason` adds `'identity'`. The timer arms **only** when identity has never resolved on this mount (the
  existing A→null-after-resolution test pins "stays idle at 45 s", preserved). Identity arriving later (before or
  after the bound) clears the timer / returns to idle with the deferred start re-armed → single mint. Unmount
  clears the timer. Telemetry: `IMPORT_PAIRING_FAILED {platform, reason:'identity'}` — no code/token.
- `components/coach/ExtensionPairingPanel.tsx` (S6-R2-A-02): `failed` → "We could not check the pairing status
  from this device. If you already entered a code in the browser extension, check there…"; `cancelled` → "This
  device stopped checking for the pairing. If you already entered the code in the browser extension, the import
  may still run there…"; new `identityUnavailable` card ("We couldn't confirm your account" / "…no pairing code
  was created…" / CTA "Try again" → `retry`, testID `pairing-identityUnavailable`). `paired` zero-delta copy
  softened from "Your import is still running in the browser extension" to a conditional ("If the import is
  running…") and body gains "this app can't see its progress" — `paired` means the code was accepted, not that
  an import is in progress. Existing pinned string in `ExtensionPairingPanel.test.tsx` updated accordingly
  (regex `/runs in the browser extension/i` still satisfied). Spinner label kept (a11y test).

### 6. Global query-persister applicability — **assessed, not changed** (`src/services/queryClient.ts`)
- Change is a 14-line `//` comment block only (`git diff` shows zero non-comment lines).
- Finding: the persister key is resolved at module import via `readUserCacheSync()`, i.e. before any hydration;
  on the shim composition this is always `:anonymous` — identical to pre-R3 behaviour, so R3 neither improves nor
  regresses it. Cross-account isolation there continues to rely on `purgePersistedQueryCacheForAllUsers()` +
  `queryClient.clear()` at sign-out. A real fix requires re-creating the persister after hydration in the
  `App.tsx` composition (wider mutable surface / architecture decision) → **paused at this boundary, escalated
  for parent re-scope**. No rehydration or key change was made.

## Consumer inventory (identity readers affected by hydration now actually working on shim builds)
`useCurrentUser`, `useExtensionPairing`/`ExtensionPairingPanel`, `foodLogQueue`, `authActions.signOut`,
`sync-engine` (`writeWorkoutLog` now records an owner; `pushPending` now pushes on shim builds — behaviour change
to note, previously a silent no-op), `queryClient` persister (unchanged, see §6), `RootNavigator` bootstrap,
onboarding/profile writers listed in §1. Not touched: `googleAuth`/`appleAuth`/`RecipesScreen` raw `user_data`
writes (still consumed correctly via the legacy fallback).

## Tests added (real composition: no mock of `lib/userCache` or `storage/mmkv`; AsyncStorage jest mock only)
- `src/lib/__tests__/userCache.composition.test.ts` — round-trip, restart via `jest.isolateModules`, single-flight,
  verified/repeatable legacy migration, set/clear generation fences, cold patch, logout/switch isolation.
- `src/services/__tests__/foodLogQueue.ownerFence.test.ts` — anonymous vs user keys (no re-attribution), enqueue
  fence, mid-flush A→B switch (one POST, nothing under B), stable-owner drain.
- `src/hooks/__tests__/useCurrentUser.composition.test.tsx` — resolves written identity, restart, logout,
  in-flight-read-during-logout fence, A→B.
- `src/hooks/__tests__/useExtensionPairing.identityWait.test.tsx` — real `useCurrentUser` over empty store →
  `identityUnavailable` at 8 s, no init/no storage, retry re-arms, unmount; stub transitions (late identity
  before/after bound → single mint; A→null never arms; cancel).
- `src/components/coach/__tests__/ExtensionPairingPanel.copy.test.tsx` — forbidden outcome-claim regexes across
  all terminal states, new copy, `identityUnavailable` CTA wiring.
- Mock updates: `authActions.signOut.test.ts`, `authActions.test.ts`, `queryClient.signout.test.ts`
  (`readUserCache`, async `clearUserCache`).

**Not yet executed**: no `npm ci`, jest, tsc, lint or export has run (no slot granted). Tests are unverified
source; predecessor negative control (new suites must FAIL against 55db31a0 sources) is part of the granted run.

## Validation plan (see PLAN.md; corrected per parent mail)
- Single lock holder for the whole run: `flock -n /home/user/workspace/execution/test-validation.lock -c '<run>'`
  (canonical absolute path; no repo-local lock).
- **Setup-only readiness: requestable now** — `npm ci` from the committed, unchanged lockfile is independent of
  any remaining work and would unblock focused tests immediately.
- Then: `npm run validate:config`, `npm run lint`, `npx tsc --noEmit`, focused jest on the 5 new + 4 touched suites,
  `timeout 660 npx jest --ci`, negative control vs 55db31a0, export proof **both** `EXPO_PUBLIC_FF_EXTENSION_IMPORT=true`
  and unset/OFF (consumer changes ship under both) with residue greps (`react-native-mmkv`; new copy present ON /
  absent OFF; "Nothing was imported" / "No import was started" absent in both). Logs → `execution/s6-r3/logs/`.

## Limits / honesty
- Source-only checkpoint; nothing compiled or run. TS narrowing in `useExtensionPairing.start()` and the
  `emitFailed('identity')` type were reviewed by reading only.
- `flushed` semantics in the fenced flush count only items actually removed from the queue (an item accepted by the
  server whose write-back was refused counts as remaining; retry is idempotent).
- No native dependency, crypto, or backend lifecycle changes. `react-native-mmkv` remains undeclared. Feature flags
  untouched (default OFF).
