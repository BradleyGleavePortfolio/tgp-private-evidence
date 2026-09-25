# S9-0 landed on `integration/importer` by fast-forward (LAND-3)

- **Status: LANDED.**
- **Executor:** `landing_composition_prep`.
- **Grant:** LAND-3, pre-granted in the parent mail at 18:14Z and relayed at 18:24Z.
- **Commit record:** `daceddc8/s9/S9_0_COMMIT.md`.
- **Review:** `daceddc8/s9/reviews/S9_0_REVIEW.md`. The initial verdict was NO-GO (R-A1, R-B1). The re-review gave **Final verdict: GO** on doc bytes sha256 `cda68d826be08e5bf5cd1152ecbb092b10dfc373c7234bd73943815d0d07bab1`. Those are the committed bytes.

| Item | Value |
|---|---|
| PR | [#541](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/541) "S9-0: reconciliation decision record (docs only)", base `integration/importer`, head `land/s9-0` |
| Head | `1c5fbb0441178e0cfe6e9f8d72e955c645c265e9`, tree `82b56ad373c9cb4888b7c9b79544fbbb6f55c0d6`, sole parent `1c10e2a1`. Local branch `exec-dace/s9-0b`, shared object store. |
| Delta | One path: `docs/decisions/2026-09-25-s9-reconciliation.md`, blob `c3423725ed51b68967074a97a0975a7245543c22`, content sha256 `cda68d82…` (recomputed from the object). Bradley is author and committer. No trailers. Banned-token check clean. |
| Stage | `land-ff.sh stage` at 18:24:36Z. It checked that the remote tip was `1c10e2a1`, that the head descends from it, that there are no merges, the identity range, and that every path matches `^docs/`. It pushed `land/s9-0` = `1c5fbb04` (ls-remote verified) and opened PR #541 (not a draft) at 18:24:43Z. |
| CI | 18:24:46Z–18:29:10Z. **Green:** 8 pass and 1 expected skip, no red. |
| Remote `integration/importer` before | `1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47` (ls-remote at 18:29:18Z, and re-checked by `ff_push_integration` immediately before the push) |
| Push | 18:29:24Z. One ordinary `git push origin 1c5fbb04…:refs/heads/integration/importer`, no force. |
| Remote `integration/importer` after | `1c5fbb0441178e0cfe6e9f8d72e955c645c265e9`, confirmed by ls-remote and `gh api branches/integration/importer`. Tree `82b56ad3…`. Author and committer are Bradley Gleave `<bradley@bradleytgpcoaching.com>`. |
| PR state | **MERGED** at 2026-09-25T18:29:24Z, merge commit `1c5fbb04` (a fast-forward, detected automatically) |
| Run dirs | `run/land-ff-stage-s9-0-20260925T182436Z/`, `run/land-ff-ff-s9-0-20260925T182918Z/`; state in `state/ff-s9-0.env` |

## Checks on #541 (head `1c5fbb04`)

Raw data: `pr541-checks.json` and `check-runs-1c5fbb04.json`.

| Workflow | Check | Result |
|---|---|---|
| CI | build-and-test | pass (18:24:48Z to 18:29:10Z) |
| CI | rls-floor-guard / rls-live-tests / mwb-3-live-tests | pass / pass / pass |
| Dependency Audit | npm audit (high+critical, whole graph) | pass |
| H4 deploy readiness | test-deploy-readiness / comment-deploy-readiness / deploy-readiness-gate | pass / pass / skipping |
| pr-size-labeler | size-label | pass |

## `main` (not touched by this executor)

This run never writes `main`. During LAND-3 I observed that backend `main` is now `1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47`: PR #530 shows MERGED at 2026-09-25T18:20:30Z, head `1c10e2a1`. That was the separate owner-bridge executor the parent mentioned; I did not touch it. The script's `check_main_untouched` logged it as a NOTE, not a refusal.

Now that #530 is merged, fast-forwards of `integration/importer` no longer re-trigger #530's main-only workflow set. `integration/importer` is now one docs-only commit ahead of `main`.
