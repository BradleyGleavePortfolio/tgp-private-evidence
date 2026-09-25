# Mobile CI minimum correction — source-only build receipt

## Initial candidate — retained B review record

- Repository: `/home/user/workspace/growth-project-mobile`
- Branch: `fix/importer-mobile-ci-proof`
- Required base: `67b646f43d1bdb8bb0d1c59b7fdafc9584302c14`
- Candidate head: `7a398598c1a8b175899de9b672213b0df5394277`
- Candidate tree: `03d4044315821ed4fac50e2bc0f83980fead195d`
- Commit: `test: correct mobile CI proof fixtures`
- Author and committer: `Bradley Gleave <bradley@bradleytgpcoaching.com>`
- Commit trailers: none
- Independent review outcome: **B — not accepted at this head**. `REVIEW.md`
  records B-1: the mutable `releaseRead` union was not safely narrowed inside
  the `act` callback.

## Exact source delta

Only the two granted test paths differ from the required base:

1. `src/config/__tests__/declaredDependencies.test.ts`
   - Removed the stale root-only anchor entry for
     `@tanstack/react-query-persist-client`.
   - The generic import/declaration validation is unchanged.
2. `src/hooks/__tests__/useCurrentUser.composition.test.tsx`
   - In the first test only, held the existing AsyncStorage user-cache read
     deterministically, retained the null assertion, explicitly released the
     read, then retained the existing resolved-user and Sentry assertions.
   - The added resolver has no cast. No other identity case changed.

Diff summary against the required base: 2 files changed; 17 insertions and 1
deletion. The changed paths are exactly the two granted paths.

`git diff --check 67b646f43d1bdb8bb0d1c59b7fdafc9584302c14..7a398598c1a8b175899de9b672213b0df5394277`
completed without output.

## Deliberately not performed

No dependency installation, local test execution, PG process, canonical-lock
operation, push, pull request, or workflow/dependency/product-source change
was performed. No hook was bypassed.

## Follow-up candidate after B-1

- Candidate head: `affc28184bb18b29d2011d25325ecba50587f9d1`
- Candidate tree: `51403a5387ae8f56e68e6b80fe6098d23995325f`
- Final follow-up commit: `test: type held storage resolver`
- Author and committer: `Bradley Gleave <bradley@bradleytgpcoaching.com>`
- Commit trailers: none

The initial B candidate was preserved. Two ordinary follow-up commits were
made without amendment:

1. `2cb1702b13fd4d18c73ec75224cc46c51739fbdb`
   `test: narrow held storage resolver`
2. `affc28184bb18b29d2011d25325ecba50587f9d1`
   `test: type held storage resolver`

The final follow-up replaces the mutable optional resolver fixture in the
first test only with a typed resolver initialized to throw, a synchronously
created deferred read promise, and a `readHeld` guard asserted after the
existing null assertion. It then explicitly releases the deferred read in
`act`. The existing null, resolved-user, and Sentry assertions remain.

Final diff against the required base:

- 2 files changed; 20 insertions and 1 deletion.
- Paths: `src/config/__tests__/declaredDependencies.test.ts` and
  `src/hooks/__tests__/useCurrentUser.composition.test.tsx` only.
- The resolver follow-up relative to the initial B candidate changes only
  `src/hooks/__tests__/useCurrentUser.composition.test.tsx` (19 lines: 11
  insertions, 8 deletions).

`git diff --check 67b646f43d1bdb8bb0d1c59b7fdafc9584302c14..affc28184bb18b29d2011d25325ecba50587f9d1`
completed without output.

## Handoff

This is a source-only builder receipt. Independent review and the existing
remote CI on follow-up head `affc28184bb18b29d2011d25325ecba50587f9d1` remain
for the parent owner.
