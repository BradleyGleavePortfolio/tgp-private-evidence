# Landing ledger (owner amendment, 16:26Z)

This ledger lists only the remote identities that have been verified with `git ls-remote` after the push. Every push was an ordinary push with no force.

## Landed

| Repo | Ref | Before → after | Accepted content | Verified |
|---|---|---|---|---|
| growth-project-mobile | `main` | `a5933fd6` → `797be96806745624e09b949fae10831e52e7078b` | Fast-forward of 24 commits: S6 `bc7b4e96` → UX-02/07 `df0ad112` → UX-01 `8fd4cf75` → pure composition `716a606e` → J3 `9ff749c3` → UX-03a `797be968`. These are the exact accepted bytes. | 16:44Z |
| growth-project-mobile | `main` | `797be968` → `c7641cb3a4b69de4846a5b5b3a5a939da2c97ebc` | Fast-forward of 3 commits: UX-03b `519b0122`, the merge `76d3bb4c` and UX-03c `c7641cb3`. These are the exact accepted bytes. | 16:59Z |
| growth-project-backend | `integration/importer` (new, non-production) | created at `c23b9d9f` → `0d69c7ba7e7d257311cfcb21fa325ebb1ddc1f1c` | Fast-forward of 64 commits: S1 `56fb0d22`, S2 `d5cd9b8b`, S3 `be0ba827`, S5 `98d39610`, S7 foundation `5c760b77`, C1 `a0ea1bea` and B/drain `0d69c7ba`. These are the exact accepted bytes. | 16:46Z |
| growth-project-backend | `integration/importer` | `0d69c7ba` → `7d2895e1fe03ea82353e8ce0b07aacaf66af74c8` | Fast-forward of R: `df36e331` then `7d2895e1`. These are the exact accepted bytes. | 17:01Z |

**Mobile `main`.** No branch protection and no deploy trigger. The heads of PRs #289–#292 are contained in it.

**Backend `main`.** It is still `c23b9d9f` and was not touched.

## Staged: exact bytes pushed, not yet on the target branch

### Extension S4 `91990ae9`

- **Pushed:** `land/s4-r6` on `tgp-importer-extension`. It is a fast-forward of 22 commits over `main` `0111be66`.
- **PR:** [PR #27](https://github.com/BradleyGleavePortfolio/tgp-importer-extension/pull/27) targets `main`.
- **Why it has not landed:** extension `main` is protected. The direct push was rejected with "protected branch hook declined". The protection requires the `test` and `codeql` checks to pass on an up-to-date branch, one approving review, and linear history, and it is enforced for admins.
- **Owner-reserved step:** an approving review can only come from an account other than the PR author. Bypassing or changing the protection would be a governance change. **The owner action is to approve PR #27.** The parent then rebase-merges it. The commit SHAs change, but every tree stays the same. That identity change is classified C.

### Extension UX-07 `6fd7e4a9`

- **Pushed:** `land/ux07-presentation`.
- **Why it has not landed:** it genuinely conflicts with S4 in `popup/popup.html`. That conflict is a B finding for this landing only.
- **Closure:** `UX07_EXT_ON_S4_COMPOSITION_GRANT.md` (builder `ux_07_extension_on_s4_build_mufrc6s6`).

### Backend production boundary

- **PR:** [PR #530](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/530), a draft from `integration/importer` to `main`, titled DO NOT MERGE.
- **Purpose:** PR CI evidence (`migration-dry-run` on PG15) and the single place for the owner's production-deploy decision.
- **Why it is reserved:** merging it is a production deploy to Fly app `backend-spring-lake-3890`, and it runs production `prisma migrate deploy`.

## Contained, left open

These remote PRs have heads contained in a landed composition.

- **Backend drafts #524, #525, #526, #528 and #529:** contained in `integration/importer`. They target `main` and stay open until the production boundary.
- **Mobile #289–#292:** contained in `main`. GitHub marks them merged or they close automatically.
- **Not contained, left alone:** mobile #293 and #294 (the accepted `df0ad112` reuses PR 293's presentation files; supersession to be confirmed by the census), backend #527 and #522, and extension #19–#26.

## Pending accepted work, to land as soon as each is accepted

| Work | Lands on |
|---|---|
| UX-07 extension | extension `main` through a PR after the composition is accepted, then the same review requirement as PR #27 |

## Qualifications (C)

**Commit identity**

- Seven historical mobile commits from July 2026, the PR #289–#292 era, carry Bradley's GitHub noreply identity, not the bradleytgpcoaching address. They are pre-existing accepted history with no AI attribution. Recorded only.

**Release dependencies**

- Mobile `main` now contains importer UX that depends on backend endpoints that exist only on `integration/importer` (the C1 pair surface). Mobile `main` has no deploy trigger, but **no store or production build should be cut from mobile `main` before the backend production boundary is crossed**.
- The same applies to extension store packaging.

## Census correction (G05)

The landing census found that GitHub's rebase-merge rewrites the committer to `GitHub <noreply@github.com>`, as on every earlier GitHub merge to extension `main`. G05 requires Bradley as committer.

- **Order of attempts for PR #27 after owner approval.** First try an ordinary fast-forward push of the exact PR head, if the protection accepts it once the approval and checks are satisfied. Otherwise use rebase-merge, but only with the owner's explicit acceptance of a GitHub committer on those commits.
- **Backend production.** It must be an ordinary fast-forward push of the exact integration tip, not the GitHub merge button.

| 17:44Z | backend `integration/importer` | PROD-CI-1 `c7a5fe8d` | FF from `7d2895e1` | accepted: T3 review plus #532 real-PG proof (5/5 OK) |
