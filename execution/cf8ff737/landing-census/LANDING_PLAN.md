# Landing census (narrowed scope), EXEC-CF8FF737

Observed around 16:57Z by the sandbox clock, using live `git ls-remote`, fetched refs including `refs/pull/*/head`, and `gh api` reads. The census was read-only on every remote. The scratch clones are in `/tmp/landing-census/*.git`. No source audit was done and nothing was re-proven.

## 1. Accepted tips: ancestry, remote location, status

All of these commits have Bradley Gleave (`bradley@bradleytgpcoaching.com`) as both author and committer.

| Boundary | Commit | Repo | Parent(s) | Descends from old main | Remote containing it | Status |
|---|---|---|---|---|---|---|
| S1 | `56fb0d22` | backend | `41f4d6a9` | `c23b9d9f`, +8 | `integration/importer` / `land/s7-b-drain` / PR #530 head | superseded by B |
| S2 | `d5cd9b8b` | backend | `21ea3252` (merge of S1 into the S2 successor) | +23 | same | superseded by B |
| S3 | `be0ba827` | backend | S2 + `5c7b42b3` | +47 | same | superseded by B |
| S5 | `98d39610` | backend | `143d451e` | +33 | same | superseded, via S7F |
| S7 foundation | `5c760b77` | backend | S3 + S5 | +59 | same | superseded by B |
| C1 | `a0ea1bea` | backend | S7F + `881c4c79` | +62 | same | superseded by B |
| B | `0d69c7ba` | backend | `75a2863b` (failed v4, preserved) ← C1 | +64 | **`integration/importer` head**, tree `d02f9b12` verified | **live tip, landed on integration** |
| R (not accepted) | `df36e331` | backend | B | +65 | local and bundle only | pending |
| S6 | `bc7b4e96` | mobile | `d51a1910` | `a5933fd6`, +16 | mobile `main` | landed |
| UX-02/07 | `df0ad112` | mobile | S6 | +17 | mobile `main` | landed, superseded |
| UX-01 | `8fd4cf75` | mobile | `327731d4` ← S6 | +18 | mobile `main` | landed, superseded |
| Pure composition | `716a606e` | mobile | UX-02/07 + UX-01 | +20 | mobile `main` | landed, superseded |
| J3 | `9ff749c3` | mobile | `820dbd04` ← `22d056bb` ← 716a606e | +23 | mobile `main` | landed, superseded |
| UX-03a | `797be968` | mobile | J3 | +24 | mobile `main` | landed |
| UX-03b | `519b0122` | mobile | J3 (sibling of 03a) | +24 | mobile `main` | landed |
| UX-03 merge + 03c | `76d3bb4c` + `c7641cb3` | mobile | 03a + 03b, then c | +27 | **mobile `main` = `c7641cb3`**, tree `7a5305e5` matching the UX03C acceptance | **landed, live tip** |
| S4 | `91990ae9` | extension | `88287cff`; 22 linear commits, no merges | `0111be66`, +22 | `land/s4-r6` = PR #27 head, open, not draft, base `main` | **live tip, staged** |
| UX-07 ext | `6fd7e4a9` | extension | `0111be66`; 1 commit | +1 | `land/ux07-presentation`, no PR | **diverges from S4**, composition granted |

In summary, the backend and mobile lanes each form a single line of ancestry: every earlier accepted head is an ancestor of the latest tip. No accepted head diverges within those lanes except the two extension slices.

## 2. Mergeability against current remote heads (`git merge-tree --write-tree`)

| Merge | Result | Fast-forward? |
|---|---|---|
| backend `main c23b9d9f` ← `integration/importer 0d69c7ba` | clean, tree = `d02f9b12` (B's tree) | yes |
| backend `integration/importer 0d69c7ba` ← R `df36e331` | clean, tree = `74ddf4dd` (R's tree) | yes |
| extension `main 0111be66` ← S4 `91990ae9` | clean, tree = `840fb285` (S4's tree) | yes |
| extension `main` ← UX-07 `6fd7e4a9` | clean, tree = `3750a2ea` | yes, but alone it would conflict with S4 |
| extension S4 `91990ae9` ← UX-07 `6fd7e4a9` | **CONFLICT (content) `popup/popup.html`**; `popup/pair.html` merges clean | no |
| mobile `main c7641cb3` | nothing left to land | n/a |

## 3. Remote PRs

"Contained" below means the PR head commit is an ancestor of the landed or staged accepted tip.

| Repo | PR | Head | Base | State | Relation | Recommendation |
|---|---|---|---|---|---|---|
| backend | #530 | `0d69c7ba` | main | open, draft | the B tip | leave; it is the owner's production boundary |
| backend | #524 | `238f0f1f` | main | open, draft | contained (S3 lineage) | leave. It will mark merged when main takes the tip. |
| backend | #525 | `925780e0` | #524 branch | open, draft | contained (S3) | close as superseded after the production boundary; stacked, so it will not auto-merge |
| backend | #526 | `881c4c79` | #525 branch | open, draft | contained (C1 second parent) | close as superseded after the boundary |
| backend | #528 | `8644715c` | #525 branch | open, draft | contained (S5) | close as superseded after the boundary |
| backend | #529 | `d7404cd4` | #528 branch | open, draft | contained (S5) | close as superseded after the boundary |
| backend | #527 | `92777d94` | #525 branch | open, draft | 22 of its 23 commits are contained; one commit is not accepted | leave |
| backend | #522, #491, #471–485, #427–428 | n/a | main | open | not covered | leave |
| mobile | #289 | `22354984` | main | merged 16:36:40Z | contained | done |
| mobile | #290, #291, #292 | `ed0342e9`, `d2f0d31c`, `34088677` | stacked m5 branches | open, draft | contained in main | close as superseded, since stacked PRs will not auto-merge |
| mobile | #293 | `003a9774` | main | open, draft | **content-superseded**: all 11 paths are byte-identical in main, and merge-tree gives main's tree `7a5305e5` | close as superseded. **Keep its branch**, because it is #294's base. |
| mobile | #294 | `5cbf0de3` | #293 branch | open, draft | not covered: 11 of 19 paths differ, add/add conflicts in 3 files | leave |
| mobile | #262–286 other | n/a | n/a | open | not covered | leave |
| extension | #27 | `91990ae9` | main | open | the S4 tip | land (see §4); optionally update it to the composition tip |
| extension | #21, #23, #24, #25 | `fc7fdf6e`, `15636ff2`, `c0824cbb`, `49c1aa96` | stacked | open, draft | contained in S4 | close as superseded after #27 lands. The rebase rewrites SHAs, so they will never auto-merge. |
| extension | #26, #20, #19 | n/a | main | open | not covered | leave |

## 4. Landing sequence (remaining)

**Already landed, and verified live by this census**

| Repo | Ref | Commit |
|---|---|---|
| backend | `integration/importer` | `0d69c7ba` (S1–S7F/C1/B) |
| mobile | `main` | `c7641cb3` (everything through UX-03c) |

**Backend R**, once it is accepted:

1. Run `git push origin df36e3310d4088501c93bcac3ce07617d02c749d:refs/heads/integration/importer`. This is an ordinary fast-forward.
2. Verify that `ls-remote` shows `df36e331`, the tree is `74ddf4dd`, and B is an ancestor.

Continue with N/Q1 and C the same way, each as a fast-forward on integration.

**Backend production (owner decision)**

- Backend `main` is **unprotected**. Use an ordinary fast-forward push, `git push origin <accepted integration tip>:main`. This preserves the exact SHAs and Bradley as committer.
- Do not use GitHub's merge button, which creates a commit whose committer is GitHub.
- Verify `main == tip`. Then #524 auto-marks as merged, and #525–#529 should be closed as superseded.

**Extension S4**

- Branch protection on `main`:
  - required checks `test` and `codeql`, strict
  - 1 approving review
  - linear history required
  - enforced for admins
- So only rebase-merge or squash via PR are possible. **Rebase-merge** keeps 22 commits and identical trees. Squash would collapse them and is not recommended.
- Verify:
  - main tree = `840fb285`
  - 22 new commits
  - authors are Bradley
  - record the committer actually written

**Extension UX-07**

- It lands as the granted composition of UX-07 on S4, which resolves the `popup.html` conflict.
- **Recommended:** if that composition is accepted before #27 is approved, fast-forward push its tip to `land/s4-r6`. The composition descends from `91990ae9`, so this is a plain update-to-tip of #27. Then **one** approval and one rebase-merge lands both.
- Otherwise, after #27 is rebase-merged, the composition branch will not be up to date under the strict check. It needs a rebase onto the new main. Trees are identical because the new main's tree is `840fb285`, so the bytes delta is none (C). CI then runs again on the new SHA.

## 5. Blockers

**A:** none.

**Extension landing (owner-reserved, already known).**
- **What is needed:** PR #27 needs an approving review from a non-author account.
- **Refinement: G05 identity conflict.** Every GitHub-performed merge on extension `main` so far records the committer as `GitHub <noreply@github.com>`: `0111be66` and the six "Split-N" commits before it. GitHub's rebase-merge rewrites committer information, so the landed S4 commits would **not** have Bradley as committer. G05 requires Bradley as author *and* committer and says: "if they conflict, stop for an operator decision; do not bypass protection."
- **Minimum closure:** when approving #27, the owner also records whether GitHub web-flow committer identity is acceptable for rebase-merged commits. Authors and trees are unchanged. The alternative is a protection change, which is governance.
- **Unlocks:** the S4 landing, and then UX-07.

**B, UX-07 extension only (already granted).** The `popup/popup.html` conflict is closed by `UX07_EXT_ON_S4_COMPOSITION_GRANT.md`.

**C, recorded only:**
- B's history includes the failed v4 `75a2863b` as its parent. That is intended, preserved history.
- Seven July-2026 mobile commits carry the noreply identity. The parent already recorded this.
- Backend `main` has no branch protection. This is a G17 observation, not in scope here.
