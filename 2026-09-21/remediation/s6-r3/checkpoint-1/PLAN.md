# S6 R3 — identity/cache/pairing reimplementation: ownership + validation plan

Worker: `s6_r3_identity_fixer_mubv6s7c` (requested model Claude Fable 5 / High — not verifiable in-session).
Role: builder (not auditor). Historical search closed; this is a **reimplementation** of the
unpreserved R3 delta on the preserved exact base.

## Ownership / fingerprint

| Item | Value |
|---|---|
| Worktree (sole writer) | `/home/user/workspace/worktrees/s6-r3` |
| Branch | `execute/20260921-s6-r3` |
| Base head (frozen) | `55db31a0696ebd07d0cb9abb18ffd31dce29457d` |
| Base tree | `130ef9bfdcdbc038b87466529f5980e759f3451a` |
| Dirty at plan time | 0 paths (`git status --porcelain` empty) |
| Known public main | `a5933fd6de5616493de75f0db907098b149b955c` (bundle prerequisite) |
| Evidence dir (sole writer) | `/home/user/workspace/execution/s6-r3/` |
| Git identity | worktree-local `Bradley Gleave <bradley@bradleytgpcoaching.com>`; `git var GIT_AUTHOR_IDENT/GIT_COMMITTER_IDENT` verified before each commit; author+committer checked after |
| Remote push | none |
| Untouched | `initialization/recovered/*`, feature-flag defaults, `react-native-mmkv` (stays undeclared), crypto, backend |

## Source scope (cheap/static now)

1. `src/lib/userCache.ts` — async namespaced read (`getStringAsync`) before legacy migration; verified,
   repeatable legacy migration; truthful async `set/patch/clear`; in-memory mirror + `isUserCacheHydrated()`;
   mutation **generation fence** (stale hydration/patch never overwrites a newer set/clear); single-flight read.
2. Writers awaited: `LoginScreen`, `CreateAccountScreen`, `RoleSelectionScreen`, `EditProfileScreen`,
   `ReadyScreen`, `lib/finalizeLeanOnboarding`, `RootNavigator`.
3. `src/services/authActions.ts` — `signOut` clears the mirror (`clearUserCache`) before `authEvents.emit('logout')`.
4. `src/hooks/useCurrentUser.ts` — epoch/unmount fence so a stale read cannot resurrect a signed-out user.
5. `src/services/foodLogQueue.ts` — capture owner once per operation; refuse write-back if owner changed (narrow).
6. `src/offline/database.ts` — remove blind `UPDATE workout_logs SET user_id=? WHERE user_id IS NULL` backfill
   (newly reachable once the sync mirror hydrates); NULL rows stay unowned, `pushPending` already filters by owner.
7. `src/hooks/useExtensionPairing.ts` — bounded first-identity wait → new `identityUnavailable` state (retryable).
8. `src/components/coach/ExtensionPairingPanel.tsx` — truthful copy for `failed` / `cancelled` / `identityUnavailable`.
9. `src/services/queryClient.ts` — **assessment only**: a 14-line `//` comment block recording the R3 applicability
   finding (verified via `git diff`: zero non-comment lines changed); no persister rewiring, no key/rehydration change.
   Boundary paused pending parent definition if any code change there is wanted.
10. Tests (real composition: no mock of `lib/userCache` or `storage/mmkv`; AsyncStorage jest mock only) +
    mock updates in 3 existing signOut suites that stub `lib/userCache` (add `clearUserCache`).

## Validation (requires parent-granted heavy slot; NONBLOCKING flock on canonical `/home/user/workspace/execution/test-validation.lock`, held for the WHOLE granted run — never a repo-local lock)

Dependency provenance: `package.json`/`package-lock.json` unchanged from 55db31a0 (which differs from main only by
`zod`, `@babel/core`, `@types/node`). Toolchain present in sandbox: node v20.20.1 (`/usr/local/bin/node`); prior R2
tarball (`execution/s6-mobile-r2/toolchain`, Node 22) and prior `npm ci` tree (`worktrees/s6/node_modules`) are NOT
present in this session → fresh `npm ci` from the committed lockfile (`--ignore-scripts` not used; no postinstall
surprises expected — record `npm ls --depth=0` provenance to logs).

Commands (run under ONE lock holder: `flock -n /home/user/workspace/execution/test-validation.lock -c '<whole granted run script>'`;
cwd `/home/user/workspace/worktrees/s6-r3`; output to `/home/user/workspace/execution/s6-r3/logs/`):
0. **Setup-only readiness (requestable now)**: `npm ci` from the committed lockfile is independent of remaining source
   work (package.json/package-lock.json unchanged from 55db31a0) and would unblock focused tests immediately.
1. `npm ci` (~3–6 min)
2. `npm run validate:config`; `npm run lint`; `npx tsc --noEmit` (~2 min total)
3. Focused: `npx jest src/lib src/hooks/__tests__/useCurrentUser* src/hooks/__tests__/useExtensionPairing* src/components/coach src/services/__tests__ src/storage src/__tests__/syncEngine.test.ts src/screens/coach/__tests__` (~1 min)
4. Full: `timeout 660 npx jest --ci` (~2 min + known ~5 min delayed exit)
5. **Predecessor negative control**: check out `55db31a0` source of `src/lib/userCache.ts`, `useExtensionPairing.ts`,
   `foodLogQueue.ts`, `database.ts` into a scratch worktree with the NEW tests copied in → new tests must FAIL
   (round-trip, restart, race, owner fence, bounded wait). Recorded to `logs/negative-control.log`.
6. Export proof (if slot allows): cold `npx expo export --platform android --no-bytecode --clear` TWICE — flag
   `EXPO_PUBLIC_FF_EXTENSION_IMPORT=true` (ON) and unset/OFF — because R3 ships consumer changes reachable under both;
   bundle residue grep for `react-native-mmkv`, the new pairing copy strings (present ON, absent OFF) and the removed
   `Nothing was imported` / `No import was started` strings (absent in both); ~80–120 s each.
Resource bounds: single process at a time, ≤ 4 GB RAM, ≤ 15 min wall total. Negative controls: flag-OFF export
must still not contain import UI strings; `declaredDependencies.test.ts` must still pass (mmkv undeclared).

## Artifact destinations
`execution/s6-r3/{PLAN.md,REPORT.md,s6-r3.bundle,delta.patch,SHA256SUMS,logs/}`.
