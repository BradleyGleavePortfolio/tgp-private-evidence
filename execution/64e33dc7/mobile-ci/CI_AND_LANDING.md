# Mobile CI correction: proof and landing receipt

## Published candidate

Observed 2026-09-25 00:59Z. Base mobile main: `67b646f43d1bdb8bb0d1c59b7fdafc9584302c14`. Candidate: `affc28184bb18b29d2011d25325ecba50587f9d1`, tree `51403a5387ae8f56e68e6b80fe6098d23995325f`. Parent verified the base was still remote main, the local worktree was clean and the exact two-file delta passed `git diff --check`.

Three ordinary Bradley-authored/committed commits preserve the first B candidate and two follow-ups: `7a398598`, `2cb1702b`, `affc2818`. No trailers, force push or hook bypass. There are no configured mobile repository hooks. Only the two granted test files differ from base; no production, dependency, lockfile or workflow bytes changed.

Independent nonbuilder review in `REVIEW.md` closed B-1 at the final head and returned GO for CI, not runtime acceptance. Parent pushed the candidate branch and opened [PR #295](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/295).

## Initial CI state

The repository's existing automation started once for this PR head:

- [CI run 36080005511](https://github.com/BradleyGleavePortfolio/growth-project-mobile/actions/runs/36080005511), `pull_request`, exact head `affc28184bb18b29d2011d25325ecba50587f9d1`: queued at observation.
- [CodeQL run 36080005510](https://github.com/BradleyGleavePortfolio/growth-project-mobile/actions/runs/36080005510), same event and exact head: queued at observation.

No manual rerun or new workflow was requested. No local test, install, PG or canonical heavy-lock operation occurred in this lane. Existing remote CI does not claim the predecessor local runtime was released.

## Acceptance

ACCEPTED by the parent at 2026-09-25 01:02Z, bounded to this test-only CI correction. [CI run 36080005511](https://github.com/BradleyGleavePortfolio/growth-project-mobile/actions/runs/36080005511) completed successfully on attempt 1: configuration validation, lint, TypeScript and Jest passed; 325/325 suites, 4180/4180 tests and 5/5 snapshots passed. The release-only readiness check was intentionally skipped, not a store-release clearance. [CodeQL run 36080005510](https://github.com/BradleyGleavePortfolio/growth-project-mobile/actions/runs/36080005510) and the CodeQL check passed. Raw run/job metadata and the complete test job log are retained alongside this receipt.

The PR CI checkout was GitHub's synthetic merge `69ccc14b9083f957706f26c8fd08ea2c369b434c`, parents base `67b646f4` and candidate `affc2818`. Parent fetched that exact merge ref and verified tree `51403a5387ae8f56e68e6b80fe6098d23995325f`, identical to the reviewed candidate tree. This is an exact-byte proof, not a claim that CI checked out the candidate commit directly.

The granted conditions are met: exactly two test paths, unchanged production/dependency/workflow bytes, independent exact-delta GO, and green existing CI on the same tree. Both original mobile CI failures are closed for this candidate; original red CI and the initial B-1 review remain historical failures. UX M1 was not reopened. No device, E2E, store or production acceptance is implied.

## Landing

LANDED at 2026-09-25 01:03Z. Parent rechecked remote main `67b646f43d1bdb8bb0d1c59b7fdafc9584302c14`, the clean local exact candidate and unprotected main, then ordinary-pushed `affc28184bb18b29d2011d25325ecba50587f9d1:refs/heads/main`. A fresh `git ls-remote` verified main at that exact accepted head. The [remote commit](https://github.com/BradleyGleavePortfolio/growth-project-mobile/commit/affc28184bb18b29d2011d25325ecba50587f9d1) retains Bradley as author and committer, no trailers, and the accepted tree. No GitHub-generated merge commit was landed.

The immediate PR API response still showed open while GitHub processed the fast-forward; remote branch identity is the landing authority. Existing main-push automation may run automatically; no manual repeat is requested or needed to re-prove unchanged accepted bytes. Main workflows do not publish to a store.

Subsequent verification: [PR #295](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/295) is MERGED at `2026-09-25T01:03:08Z`, merge identity `affc28184bb18b29d2011d25325ecba50587f9d1`. Automatic main-push [CI 36080304504](https://github.com/BradleyGleavePortfolio/growth-project-mobile/actions/runs/36080304504) and [CodeQL 36080304527](https://github.com/BradleyGleavePortfolio/growth-project-mobile/actions/runs/36080304527) were observed in progress on the same head. No manual rerun was issued.

Final observation at 2026-09-25 01:06:36Z: both automatic main-push runs completed SUCCESS, attempt 1, at exact landed head `affc28184bb18b29d2011d25325ecba50587f9d1`. The mobile CI lane has no remaining A/B, active writer or pending gate.

Backend S7-L/S8-C exact-source recovery and predecessor ownership remain unresolved and unaffected. No production or store release is authorized.
