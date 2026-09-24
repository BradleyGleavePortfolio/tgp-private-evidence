# Mobile composition — pure two-parent merge of accepted state into accepted presentation: actual results

Outcome: **clean ordinary two-parent local merge; resulting tree equals the predicted `merge-tree` result and is the exact blob union of both accepted deltas. No conflict, no authored edit, no install, no generator, no test run, no hooks bypass, no remote, no deploy.** Local git only; heavy slot not touched. This is a factual composition record for the same A+B to bind evidence applicability — not an acceptance.

## Exact composition bindings

| Item | Value |
|---|---|
| Clone | `worktrees/ux-mobile-composed` — standalone `git clone --no-hardlinks --no-checkout` of the accepted presentation worktree, `origin` removed (0 remotes); state fetched by local path into `refs/heads/state/ux01-account-state`, no remote retained |
| Branch | `compose/importer-presentation-state` |
| First parent (accepted presentation) | `df0ad112529afcd9bfdf084e9930c90ee0bfffb3`, tree `377e4b7a497a69c2f1e68236a3f1527913c7429b` |
| Second parent (accepted state) | `8fd4cf759c2a8dd3f9ef9772f6dadb2035d93820`, tree `17a6ce1acea7e4d6e926113faeb6a57eafa684f3` (parent `327731d4…`) |
| Common base (`git merge-base`) | `bc7b4e96fc1db54568bc209dbe1f7a4121501ac9` (accepted S6) |
| Changed paths vs base | presentation 12, state 6, **intersection 0, union 18** |
| Predicted tree (`git merge-tree --write-tree`, rc 0 = clean, before merging) | `430c76a0a686f8756ea0d77f37613d3f85561fb2` |
| **Merge commit** | **`716a606e9d23c77a6d705beccb8cefc6e8228284`** |
| **Merge tree** | **`430c76a0a686f8756ea0d77f37613d3f85561fb2`** = predicted |
| Ordered parents | `df0ad112529afcd9bfdf084e9930c90ee0bfffb3`, `8fd4cf759c2a8dd3f9ef9772f6dadb2035d93820` |
| Message | `merge(importer): compose accepted journey presentation and account state` (single line, verbatim; body empty; trailers 0) |
| Author / Committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` 1790233568 +0000 (both; repo-local config) |
| Hooks | `core.hooksPath` unset; `.git/hooks` only `*.sample`; no bypass flag (`git merge --no-ff --no-edit -m …`) |
| Strategy | `ort` (git 2.53.0), 6 files added/changed relative to first parent, 1051 insertions, 0 deletions |
| Clean state | `git status --porcelain` empty; `git ls-files -u` 0; no `node_modules` in the clone |
| Raw object | `03-merge-commit-object.txt` |

## Each accepted delta retained exactly (cross-diffs on the actual merge commit)

| Check | Result |
|---|---|
| `git diff df0ad112 716a606e` vs `git diff bc7b4e96 8fd4cf75` | byte-identical (`cmp`), sha256 `abaab9f10724e5ebb07ba2594d7c5477d032a2b40a9a59d7f4988adf1cc05dfc` → state delta retained exactly |
| `git diff 8fd4cf75 716a606e` vs `git diff bc7b4e96 df0ad112` | byte-identical (`cmp`), sha256 `54b3c312125cb6deb07f88f0b7c12e630e97d3ca5df62fd3977a1a26df950118` → presentation delta retained exactly |
| `git diff-tree -p --cc 716a606e` (combined merge diff) | only the commit-id header line, zero hunks → no change beyond either parent (`merge-716a606e-combined.patch`, 41 bytes) |
| Paths differing merge-tree vs base | 18 (= union) |
| Per-path blob equality, merge tree vs owning parent (18/18) | 0 mismatches (`02-predicted-blob-union.txt`) |

18-path blob table of the merge tree (all identical to the accepted parents' blobs): presentation — `SettingsScreen.tsx c8bcb5f1…`, `ImportOfferCard.tsx f20456f6…`, `ImportSetupView.tsx 23584782…`, `README.md c30fc355…`, `ImportJourney.navigation.test.tsx 04c9a42b…`, `ImportOfferCard.test.tsx cbaa44c6…`, `ImportSetupView.test.tsx 9255cf73…`, `importJourneyCopy.test.ts 904c7e05…`, `sideEffectGuards.cjs 834b6a18…`, `i18n/en.json 7768128e…`, `importJourneyCopy.ts 4c09b1b8…`, `importJourneyUI.tsx 3f1fb60e…`; state — `importOfferDecision.ts 83118fff…`, `useImportOfferDecision.ts ddede726…`, `authActions.ts ceb33c45…`, `importOfferDecision.test.ts 004e520e…`, `useImportOfferDecision.test.tsx 9c10f113…`, `authActions.test.ts fb3ac27c…`. Full 40-char list in `04-crossdiffs-and-exports.txt`.

## Evidence applicability (stated, for the reviewers to bind — not re-proven here)

Because the merge tree is the exact blob union with zero intersecting paths and zero combined-diff hunks, every previously accepted source review and runtime proof applies to identical bytes: presentation receipts (`execution/95633079/ux/mobile-presentation/**`, tree `377e4b7a…`) and state receipts (`execution/95633079/ux/account-state/**`, tree `17a6ce1a…`, 55 inherited + 1 corrected + 1 new case, tsc/ESLint RC 0). No new runtime test was run here, per grant. Not proven by this composition: any cross-module interaction (none exists in source — no path in either delta imports the other), and whole-project typecheck over the union (both parents individually passed `tsc --noEmit` on identical files; the union adds no new import edges).

## Files in `execution/95633079/ux/mobile-composition/`

| File | sha256 / note |
|---|---|
| `01-preflight.txt` | clone, fetch, identity, merge-base, path counts, predicted tree |
| `02-predicted-blob-union.txt` | 18/18 blob MATCH vs predicted tree; diff-of-diffs identical |
| `03-merge.txt`, `03-merge-commit-object.txt` | merge output, result, raw commit object |
| `04-crossdiffs-and-exports.txt` | cross-diff proofs, blob table, hashes |
| `state-delta-base-to-8fd4cf75.patch` = `cross-diff-presentation-to-merge.patch` | `abaab9f1…5dfc` |
| `presentation-delta-base-to-df0ad112.patch` = `cross-diff-state-to-merge.patch` | `54b3c312…0118` |
| `merge-716a606e-combined.patch` | 41 bytes, header only |
| `composed-union-base-to-716a606e.patch` (`git diff bc7b4e96 716a606e`, 18 paths) | `c93661ac75fe010da86e6d0eef862a2b5e2697f9bd924fbe74d9033b79887795` |
| `ux-mobile-composed-716a606e.bundle` (`git bundle verify`: okay; bc7b4e96 → df0ad112 / 327731d4 → 8fd4cf75 → 716a606e) | `a61e43355ff104ab1d663c0ea4d90beaa0d352c55c7db9f193c100bed6751140` |

## Boundaries kept
- `worktrees/ux01-state` (HEAD `8fd4cf75`) and `worktrees/ux07-mobile` (HEAD `df0ad112`) untouched (read-only clone/fetch sources).
- Writes only to `worktrees/ux-mobile-composed/**` and `execution/95633079/ux/mobile-composition/**`.
- No J3/UI implementation started. Mobile UI ownership is to transfer to the parent-named writer after composition acceptance.
- Class A/B: none.
