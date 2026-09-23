# S6-P1 — exact validation request (no runtime performed in this phase)

Nothing below was executed. This phase was static file/Git/hash/diff
inspection only: no npm/node/Jest/tsc/eslint/formatter, no install,
generation, lock/probe/signal, hook install, commit, export, network or remote
action. No runtime success is claimed or implied.

Substrate for any execution: the same worktree
`/home/user/workspace/worktrees/s6-diagnostic`, its existing installed
`node_modules` (read-only, 699 top-level entries; `@tanstack/*` 5.100.14,
RNTL 14.0.0, jest 29.7.0, jest-expo 56.0.4), platform Node **v20.20.1** — the
EBADENGINE qualification stands, **do not upgrade Node**. Canonical lock
sha256 `840be0b8d5f4ed8272afd20290c8ebf6f6dacc394e6edae4ae5403e9fabe6b69`
(blob `6c56385d…`) must be unchanged. `package.json`/`package-lock.json` must
not be modified; no install step.

## Commands requested (in this order)

Run from `/home/user/workspace/worktrees/s6-diagnostic`.

1. Typecheck (contract-level check of the candidate, no emit):

       npx tsc --noEmit

2. The two new required suites:

       npx jest src/services/__tests__/persistedQueryCache.identityGate.test.tsx --runInBand
       npx jest src/__tests__/rootNavigatorPersistedCacheGate.test.tsx --runInBand

3. The two narrowly adapted existing suites:

       npx jest src/services/__tests__/queryClient.persister.test.ts --runInBand
       npx jest src/services/__tests__/queryClient.signout.test.ts --runInBand

4. Existing suites that touch the changed modules (regression, unchanged files):

       npx jest src/__tests__/rootNavigatorAcceptLink.test.tsx src/__tests__/rootNavigatorCheckoutLink.test.tsx src/services/__tests__/authActions.test.ts src/services/__tests__/authActions.signOut.test.ts src/__tests__/entitlementProvider.test.tsx --runInBand

5. Frozen v5 hazard suite against the candidate, with the frozen inputs copied
   in **unmodified** at run time (they are deliberately not in the worktree
   now):
   - `execution/op88/s6-c6-prep/c6/inputs/persistedQueryCache.hazardControls.test.tsx`
     (sha256 `a91bb732716b500122e291714bf437872cb81930c020812042f84ed87f6a184d`)
     → `src/services/__tests__/persistedQueryCache.hazardControls.test.tsx`
   - `execution/op88/s6-c6-prep/c6/inputs/persistedQueryCache.hazardAdapter.tsx`
     (sha256 `3796be8fae738993bcc5c30dd7d4cf9b303329b8faa990ca03e31c2460cd35f3`)
     → `src/services/__tests__/persistedQueryCache.hazardAdapter.tsx`

         npx jest src/services/__tests__/persistedQueryCache.hazardControls.test.tsx --runInBand

   No `--clearCache`, no `--forceExit`, no `--detectOpenHandles`-driven
   mitigation, no timer flags, no C6 classifier change.

## Expected outcome table for step 5 (to be confirmed by execution, not asserted here)

| Case | Expectation on the candidate |
|---|---|
| T-WIRING | executes and **passes** (App.tsx has `<QueryClientProvider client={queryClient}` and no `asyncStoragePersister`; RootNavigator contains `<PersistedQueryCacheGate`; `QUERY_CACHE_BUSTER === 'tgp-rq-v2-samples'`) |
| T0 | executes and **passes** |
| T1 (anonymous-key blob restore) | executes and **fails on its hazard assertion** — the anonymous key is never read for a committed identity |
| T2 (A→C memory carry-over without signOut) | executes and **fails on its hazard assertion** — C never sees A's data; A's PII is not re-persisted |
| T3 (late write during purge surviving) | executes and **fails on its hazard assertion** — retire + drain + purge + fail-closed removal |
| T4 (normal signOut leaves nothing) | executes and **passes** |

A behavioural flip means the assertion itself fails. An import error, hang,
skipped assertion or forced exit is **not** a flip and must be reported as
such.

## Notes for the reviewers

- No repeat of the C6 baseline is requested or needed.
- The two residual 600 000 ms timers observed in C6 originate in
  `Query.removeObserver → scheduleGc` on queries already removed by `clear()`;
  see `LIFECYCLE_ANALYSIS.md` §1 for the pinned-source trace and §2 for the
  correction. The added `queryClient.signout.test.ts` case is the direct
  behavioural check of that ordering (observer detached and no timer-count
  increase on the later `observer.destroy()`).
- Runtime ownership: S3 owns the runtime, S5's setup lane is independent of
  this source work. This request does not assume any particular runner.
