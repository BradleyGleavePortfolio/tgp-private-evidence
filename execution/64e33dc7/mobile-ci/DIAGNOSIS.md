# Mobile CI disposition — main 67b646f4 / run 36057059287

Read-only diagnosis (T3 bounded). No implementation, tests, installs, commits, pushes or PG. Tests were NOT run; all behavior claims come from GitHub CI logs, repository source at the verified head, and the upstream RNTL v14.0.0 source.

## Verified facts

- Clone of `BradleyGleavePortfolio/growth-project-mobile`: `main` = `67b646f43d1bdb8bb0d1c59b7fdafc9584302c14` (UX-04/05, FF from `c7641cb3`).
- CI run 36057059287 (push, head `67b646f4`, job "Typecheck, lint, test", Node 22.13.1, `npm ci`): 2 failed / 323 passed suites; 2 failed / 4178 passed tests. CodeQL 36057059084 green.
- Attributable baseline (G08): identical two failures, identical diffs, on main CI 36029895556 (`c7641cb3`) and 36028571779 (`797be968`, plus 4 `useExtensionPairing.identityWait` failures since resolved). Last green main CI: 29786438490 (`a5933fd6`, 2026-07-20). No CI run exists for the intermediate commits `d51a191`/`bc7b4e9` (24 commits `a5933fd6..797be968`).
- Delta `c7641cb3..67b646f4`: 11 files, all under `src/screens/coach/import-journey/`. No overlap with `App.tsx`, `index.ts`, `package*.json`, `jest*`, `src/config`, `src/hooks`, `src/lib`, `src/services`, `src/storage`. New third-party imports: only `react`, `react-native`, `react-native-safe-area-context`, `@testing-library/react-native`. **Delta relevance: none.** Accepted UX M1 is not implicated and is not reopened.

## F1 — `src/config/__tests__/declaredDependencies.test.ts:598`

- Assertion: `expect(ENTRYPOINT_ONLY).toEqual(ENTRYPOINT_ONLY_PACKAGES)`. Derived set (L389–391: packages imported by repo-root `.ts/.tsx` and by no `src/` file) no longer contains `@tanstack/react-query-persist-client`; the hand-written anchor (L403–411, entry at L406) still does.
- Cause: `bc7b4e9` (2026-09-23, "identity-bound persisted query cache gate") replaced `PersistQueryClientProvider` in `App.tsx` with plain `QueryClientProvider`; the package is now imported only from `src/services/queryClient.ts:30–31` (`persistQueryClientSubscribe`, `PersistedClient`). The anchor was designed to fail on exactly this move (L396–401 comment: moving an import into `src/` is "a fact a reviewer should have to look at").
- Product effect: none. Package remains declared (`package.json:44`, lock 5.100.14) and imported from `src/`, so the src/ walk + "every imported package is declared" check still guard it. Removing the anchor entry weakens no guard.
- **Class: stale test anchor (proof defect), not A.**
- Minimal edit: delete L406 `'@tanstack/react-query-persist-client',` from `ENTRYPOINT_ONLY_PACKAGES`. Nothing else.

## F2 — `src/hooks/__tests__/useCurrentUser.composition.test.tsx:46`

- Assertion: after `await setUserCache(userA)` (L44) and `const { result } = await renderHook(...)` (L45), `expect(result.current).toBeNull()` (L46); received `{"email":"a@example.com","id":"user-A"}`. L48–49 (resolves to userA; Sentry tagged) are the intended end state and match what was received.
- Cause: toolchain semantics, not the hook. Lock pins `@testing-library/react-native` 14.0.0 and `react` 19.2.3 (lock last changed `60975b5`, 2026-09-20, before the test was authored in `d51a191`, 2026-09-21; the S6-R3 checkpoint report states the suite was written unexecuted). In RNTL v14 `renderHook` awaits `render`, which awaits `act()`, and RNTL's `act` always wraps the callback as async (`src/act.ts`: `_act(async () => await callback())`). React 19 async `act` drains the act queue across macrotask turns before resolving, so the effect's `readUserCache()` (jest AsyncStorage mock, microtask-resolved) and `setUser(userA)` commit before `await renderHook` returns. The pre-hydration `null` render occurs but is unobservable at L46.
- Product effect: none. `src/hooks/useCurrentUser.ts:55` initializes `useState(null)`; hydration is async (L68–83) with logout/epoch fences (L84–87). Null-while-hydrating is already asserted and passes in CI in the same file (L72–86, held-read test, `expect(result.current).toBeNull(); // read is held open`).
- **Class: test asserts an unobservable intermediate state (proof defect), not A.**
- Minimal edit (preferred): delete L46 and rename L43 to `'resolves the identity written by a sign-in'` (or annotate that pre-hydration null is covered by the held-read case). Alternative that preserves the assertion: before L45, hold `AsyncStorage.getItem('prefs:auth.user_data')` open using the L74–83 spy pattern, assert null, release inside `act`, `flush()`, then L48–49.

## Disposition

- **Class B, scoped to the mobile CI gate only.** Neither failure is a product/customer/data defect (not A). Not merely C, because a permanently red required `CI` job on `main` since `797be968` cannot distinguish a new regression from these two known failures, so no mobile head can currently claim clean CI (G07/G09).
- Blocks: clean-CI claims for future mobile landings. Does NOT block or reopen UX M1 acceptance/landing at `67b646f4` (failures pre-date the delta with identical signatures) or any other lane.
- **Proposed tier: T1** (test-only, two files, no product/runtime/dependency change; no boundary weakened — package stays guarded by the src walk, null-before-hydration stays asserted by the held-read test). Targeted review should confirm exactly those two coverage points. If the reviewer considers the identity test T4-boundary-adjacent, use the alternative F2 edit (assertion preserved) to keep it at T1.
- Minimal closure: one builder commit (Bradley author/committer, no AI trailer) with the two edits above → one GitHub CI run on that head showing 325/325 suites, 0 failed → targeted review → land. GitHub CI is the proof executor; no local heavy slot needed. No other proof is rebought.

## Not done / unknown

- No local test execution; no dependency install. The RNTL/React act mechanism is inferred from upstream v14.0.0 source plus the CI-observed value, not from a local run.
- Whether F2 ever passed anywhere is unknown; no attributable green run of that assertion was found.
