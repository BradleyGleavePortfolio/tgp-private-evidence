# Mobile CI minimum correction grant

Tier: T1. Why: formally bounded test-fixture/expectation correction under existing unchanged product contracts; no product behavior, auth semantics, dependency or release-policy change. T4 trigger scan: no production identity, session-trust, persisted-cache or authorization changes; existing identity assertions must remain. T3 trigger scan: none; diagnosis and exact outcome are supplied. Bounded T1: all ten criteria satisfied; outcomes, two-file surface, invariant, dependencies, decisions, blast radius, proof, privilege, data and discovery are fixed below. Canonical builder: GPT-5.6 Terra, medium. Parent owner: EXEC-64E33DC7. Requested route is not runtime telemetry.

## Exact base and ownership

Base: mobile `67b646f43d1bdb8bb0d1c59b7fdafc9584302c14`. Fresh isolated branch `fix/importer-mobile-ci-proof` in the new local mobile clone. Sole product-repository writable paths:

- `src/config/__tests__/declaredDependencies.test.ts`
- `src/hooks/__tests__/useCurrentUser.composition.test.tsx`

Builder may write its receipt under `execution/64e33dc7/mobile-ci/BUILD.md` in private evidence. Parent owns private commits and publication. There is no predecessor mobile writer identified in the active S7-L/S8-C scope; those backend surfaces remain unclaimed and blocked.

## Minimum correction

F1: remove only the stale `@tanstack/react-query-persist-client` member from the root-only package anchor. Its actual source import remains covered by the source-tree dependency check. Do not weaken the generic declaration check.

F2: retain the first test's null-while-loading, resolved-user and Sentry assertions. Make the loading state observable with a controlled pending storage read, using the existing held-read pattern in the same file. Then explicitly release the read and assert the existing final user/Sentry state. Do not remove tests, skip cases, alter other identity tests, or change production source merely to satisfy the test. Prefer a type-safe deferred resolver rather than adding a cast.

Promotion: stop and report if source changes, fixture semantics beyond the first test, dependency/toolchain updates, test suppression, hook bypass, new assertions of auth policy or any other surface is required. Do not turn this into test-harness cleanup.

## Proof and landing

No dependency installation, local test run, PG process or canonical lock operation is granted. Mobile has no configured repository hooks; do not invent or disable hooks. Ordinary Bradley-authored/committed test-only commit, no trailers; report exact head/tree and scoped diff, then stop without pushing.

One independent nonbuilder reviews the exact delta and the preserved coverage. Parent may push the reviewed candidate, open a non-production PR to mobile main, and use the repository's existing GitHub CI once on that head. This does not allocate the shared local runtime or run a real-PG proof. No workflow modification, manual rerun or new service spending is granted.

Acceptance requires exactly the two allowed test paths, unchanged production/dependency/workflow bytes, independent review, and green existing CI on the exact candidate. On acceptance, parent lands without another routine permission request, verifies remote identity, records closure and preserves the prior red CI truthfully. Backend source-recovery and runtime-release blocks remain unchanged.
