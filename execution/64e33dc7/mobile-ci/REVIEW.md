# Mobile CI minimum correction — independent nonbuilder review

Candidate: mobile `7a398598c1a8b175899de9b672213b0df5394277`, tree `03d4044315821ed4fac50e2bc0f83980fead195d`, single parent `67b646f43d1bdb8bb0d1c59b7fdafc9584302c14`, branch `fix/importer-mobile-ci-proof` (local, unpushed). Reviewer did not build the candidate. It did write the read-only `DIAGNOSIS.md` that the grant relies on; disclosed here. No peer review exists.

Scope: exact two-file delta only, against `MOBILE_CI_MINIMUM_CORRECTION_GRANT.md` and `BUILD.md`. No edits, mobile Git writes, installs, repository tests or pushes. The only execution was an isolated `/tmp` type-check probe (not the repo) using TypeScript binaries that were already on the machine.

## Verdict: B — NOT ACCEPT at this head. Do not push this head for the one granted CI run.

### B-1 (proof-blocking): TS2722 at `useCurrentUser.composition.test.tsx:61`

- `let releaseRead: (() => void) | undefined;` (L45) is assigned only inside the nested Promise executor (L49–51). Control-flow analysis cannot see that assignment, so `releaseRead` is typed `undefined` at L57. Inside the `act` closure (L60–63) it reverts to the declared `(() => void) | undefined`, so `releaseRead();` (L61) is `Cannot invoke an object which is possibly 'undefined'` (TS2722). The runtime guard at L57–59 does not narrow inside the closure. This is exactly why the file's existing held-read test uses `(release as unknown as () => void)()`.
- CI runs `npx tsc --noEmit` (`.github/workflows/ci.yml:42`) before `npm test` (L45). `tsconfig.json` extends `expo/tsconfig.base` (expo 56.0.12), which has no `include` and excludes only node_modules, config and native dirs, so `__tests__` are type-checked. At `67b646f4`, run 36057059287 passed that step with this file.
- Probe: a minimal reproduction of the L45–63 pattern under `--strict` fails with TS2722 on TypeScript 5.9.3 and 7.0.2. The repo's locked 6.0.3 was not run (no install); it lies between two versions that both reject it, and this narrowing behavior is long-standing.
- Consequence: the candidate's CI would go red at Typecheck before any test runs, so the granted CI proof cannot pass. This is not a product defect.
- Minimal fix (same two paths, first test only, no cast, no `!`): replace L45 and L48–51/L57–59 with a deferred created up front, for example:
  ```ts
  let releaseRead: () => void = () => {};
  const readReleased = new Promise<void>((resolve) => { releaseRead = resolve; });
  let readHeld = false;
  // in mockImplementation: if (key === 'prefs:auth.user_data' && !readHeld) { readHeld = true; await readReleased; }
  // after the null assertion: expect(readHeld).toBe(true);
  ```
  The Promise executor runs synchronously, so `releaseRead` is the real resolver before use. `expect(readHeld).toBe(true)` keeps the fail-closed "read was actually held" check that L57–59 provides. An equivalent isolated probe type-checks cleanly on 5.9.3 and 7.0.2. Re-review scope after the fix: those lines only.

### Checked and acceptable (carry forward unchanged)

- Identity: author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`; message `test: correct mobile CI proof fixtures`; no trailers.
- Surface: `git diff --stat 67b646f4 7a398598` shows exactly `src/config/__tests__/declaredDependencies.test.ts` (−1) and `src/hooks/__tests__/useCurrentUser.composition.test.tsx` (+17), 17 insertions and 1 deletion. No product, dependency, lockfile or workflow bytes changed.
- F1: removes only `'@tanstack/react-query-persist-client',` from `ENTRYPOINT_ONLY_PACKAGES`. `ENTRYPOINT_ONLY` derivation, the L601 declared-check and the generic import/declaration guard are untouched. The package stays imported by `src/services/queryClient.ts:30–31` and declared in `package.json:44`, so the src walk still guards it. This is accurate.
- F2 semantics: runtime behavior is sound. On the jest shim, `prefsStorage.getString` returns `undefined`, so `readUserCache` goes through `getStringAsync`, which calls `AsyncStorage.getItem('prefs:auth.user_data')`. The spy holds only the first matching call and passes everything else through `realGet`. The null (L56), resolved-user (L65) and Sentry (L66) assertions are all kept. The release is explicit inside `act`, followed by `flush`. The spy is reset by the existing `beforeEach` `jest.restoreAllMocks()`. No test is skipped or removed, no other identity case changed, and there are no harness, setup or hook changes.

## Not claimed

No CI, local test or local tsc run on the repository. No proof exists for either head. Acceptance still requires a fixed candidate, a delta-only re-review and green existing CI on that exact head.

---

# Re-review (B-1 resolver question only) — exact head `affc2818`

Candidate: `affc28184bb18b29d2011d25325ecba50587f9d1`, tree `51403a5387ae8f56e68e6b80fe6098d23995325f`. Chain: `67b646f4` → `7a398598` (preserved, B above) → `2cb1702b` ("test: narrow held storage resolver", tree `2aa072ad`) → `affc2818` ("test: type held storage resolver"). Both follow-ups have author and committer Bradley Gleave <bradley@bradleytgpcoaching.com> and no trailers, and each touches only `src/hooks/__tests__/useCurrentUser.composition.test.tsx`. `7a398598..affc2818`: 1 file, +11/−8, first test only. Cumulative `67b646f4..affc2818`: the same two granted paths, +20/−1. The original B-1 finding above stands as the record for `7a398598`.

Method: read-only diff and source reading. No installs, tests, compiler probes, Git writes, push or CI for this re-review.

## Verdict: B-1 CLOSED at `affc2818`. GO for the parent's existing-CI gate on this exact head. This is not runtime proof or product acceptance.

- **Closure question:** L45–47 declare `let releaseRead: () => void` with a throwing initializer, so it is always a callable, non-union type. Neither control-flow nor closure analysis has an `undefined` member to widen back to, so `releaseRead()` at L64 inside `act` has no TS2722.
- **Assignment at L48–50:** `releaseRead = resolve` assigns `(value: void | PromiseLike<void>) => void` to `() => void`. That is valid because a void-accepting trailing parameter is optional for arity. The earlier `/tmp` probe of the same shape (initializer, synchronous `new Promise<void>` executor assignment, call inside an async `act` closure) type-checked on TypeScript 5.9.3 and 7.0.2. It was not re-run here, per instruction.
- **The throwing default never runs:** the Promise executor runs synchronously at construction (L48), before render. It is a fail-closed default rather than an empty no-op. No cast and no `!`.
- **`readHeld` (L51, L54–55, L62):** set inside the spy on the first `prefs:auth.user_data` read. At L62 its flow type is narrowed to `false`, but `@types/jest` (lock 29.5.14) declares `toBe<E = any>(expected: E)`, unconstrained by the actual value's type, so `expect(readHeld).toBe(true)` type-checks. At runtime it fails the test if the read was never held, preserving the fail-closed intent of the removed L57–59 guard.
- **Runtime path unchanged from the prior review:** shim `getString` → `undefined` → `getStringAsync` → held `AsyncStorage.getItem`. The first matching read awaits `readReleased`; others pass through `realGet`. The release happens inside `act` (L63–66), then `flush`.
- **Assertions preserved:** null while the read is held (L61), resolved `userA` (L68), Sentry `{ id: 'user-A', email: 'a@example.com' }` (L69). No other test, harness, setup, product, dependency or workflow change. The spy is still reset by the existing `beforeEach` `jest.restoreAllMocks()`.
- **F1 and the rest of the prior disposition carry forward unchanged.**

Not claimed: no repository tsc/jest/CI result for `affc2818`. Proof and acceptance still require green existing GitHub CI on exactly `affc28184bb18b29d2011d25325ecba50587f9d1`.
