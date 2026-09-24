# Mobile composition — reviewer B binding attestation (pure local union only)

**Disposition: ACCEPTED as a pure local composition** of accepted presentation `df0ad112529afcd9bfdf084e9930c90ee0bfffb3` and accepted UX-01 state `8fd4cf759c2a8dd3f9ef9772f6dadb2035d93820`, at exact merge commit `716a606e9d23c77a6d705beccb8cefc6e8228284`, tree `430c76a0a686f8756ea0d77f37613d3f85561fb2`, in `worktrees/ux-mobile-composed` (branch `compose/importer-presentation-state`).

Class A: none. Class B: none. Class C: two records (§6). Existing source reviews and runtime proofs of both parents transfer unchanged to identical bytes. No runtime, no new criteria, no product re-audit, no UI review (no composed UI exists). UX-03 J3 binding is not accepted here; it gets its own scoped writer.

Bounded same-evidence attestation by the UX-01 account-state reviewer B. Observation time 2026-09-24T07:09Z. Read-only: git plumbing, `git bundle verify`/`list-heads`, file reads, static grep; no commit, merge, checkout, install, test, probe, or remote. `mobile-composition-review-a/` exists and was not opened. Prior reviewer-B reports under `account-state-review-b/` are preserved and unchanged. Inputs: `execution/95633079/ux/mobile-composition/COMPOSITION_ATTESTATION.md`, `01-preflight.txt`, `02-predicted-blob-union.txt`, `03-merge.txt`, `03-merge-commit-object.txt`, `04-crossdiffs-and-exports.txt`, `merge-716a606e-combined.patch`, and the six patch/bundle exports.

## 1. Exact objects — independently re-derived

| Item | Observed | Match |
|---|---|---|
| HEAD | `716a606e9d23c77a6d705beccb8cefc6e8228284` | as attested |
| Tree | `430c76a0a686f8756ea0d77f37613d3f85561fb2` | = builder's pre-merge `merge-tree` prediction (receipt `01-preflight.txt`) |
| Parents (ordered, exactly 2 `parent` lines) | `df0ad112…` (tree `377e4b7a…`), then `8fd4cf75…` (tree `17a6ce1a…`) | accepted presentation first, accepted state second |
| `merge-base` of the parents | `bc7b4e96fc1db54568bc209dbe1f7a4121501ac9` | accepted S6 base |
| Author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>`, `1790233568 +0000` both | G05 |
| Subject / body / trailers | `merge(importer): compose accepted journey presentation and account state` / empty / 0 | approved single-line message |
| Hooks / remotes | `core.hooksPath` unset; `.git/hooks` sample-only; `git remote` → 0 | ordinary local merge, nothing to bypass, nothing remote |
| Clean | `status --porcelain` 0; `ls-files -u` 0; untracked 0; no `node_modules` | clean |
| Source worktrees | `ux01-state` HEAD `8fd4cf75` clean; `ux07-mobile` HEAD `df0ad112` clean | untouched |

## 2. 18-blob union, zero overlap, no authored change

- Path sets vs base (`diff-tree --name-only`, sorted): presentation 12 (all under `src/screens/coach/`), state 6, intersection **0**, and `sort -u(P ∪ S)` is byte-identical to the 18 paths differing between the merge tree and base. Therefore every path outside the 18 is identical to base in the merge tree.
- Per-path blob equality, merge tree vs owning parent: **18/18**, 0 mismatches (my own `rev-parse HEAD:<path>` loop; list in §7). For each of the 6 state paths the presentation parent's entry equals base (absent or same blob), so no three-way content merge occurred anywhere; the result is a pure tree union.
- `diff-tree --name-only HEAD^1 HEAD` == state path set; `HEAD^2 HEAD` == presentation path set. `HEAD^1..HEAD` shortstat: 6 files, +1051, −0 (= 163+168+9+206+473+32).
- Cross-diffs recomputed by me: `diff df0ad112 HEAD` sha256 `abaab9f1…5dfc` == `diff bc7b4e96 8fd4cf75`; `diff 8fd4cf75 HEAD` sha256 `54b3c312…0118` == `diff bc7b4e96 df0ad112`. Each accepted delta is retained byte-exactly.
- Combined merge diff `diff-tree -p --cc HEAD`: 41 bytes = the commit-id header only, **zero hunks** → no change beyond either parent; no authored content.
- Exports: bundle `a61e4335…1140` (`bundle verify` complete history, single head `716a606e` = `refs/heads/compose/importer-presentation-state`); `composed-union-base-to-716a606e.patch` `c93661ac…7795` == my `diff bc7b4e96 HEAD`; the four cross-diff/delta patches hash pairwise as attested.

## 3. Applicability binding

Because the composed tree is the exact blob union with zero intersecting paths and zero combined hunks, every previously accepted proof was produced against bytes that are identical in this tree:

- Presentation: source review and receipts under `execution/95633079/ux/mobile-presentation/**` and `mobile-review/**` for tree `377e4b7a…` — the 12 blobs are unchanged.
- State: reviewer-B frozen report, addenda 01–02 and receipts under `execution/95633079/ux/account-state/**` for tree `17a6ce1a…` — the 6 blobs are unchanged (55 inherited + 1 corrected + 1 new case, `tsc`/ESLint RC 0 on `8fd4cf75`).

Cross-module edges (static grep of the 18 blobs; bounded, not a re-audit): no state blob references `screens/coach`, `import-journey`, `ImportOfferCard`, or `importJourney`; no presentation blob references `importOfferDecision` or `useImportOfferDecision`. The single shared edge is `SettingsScreen.tsx` → `services/authActions.signOut`, which already exists at base `bc7b4e96` (line 19), is not touched by the presentation delta, and the state delta changes no `export` line of `authActions.ts` (one import + one array element). `sideEffectGuards.cjs` mocks `authActions` wholesale via `jest.mock`, so the state change cannot reach it. Neither delta touches package, lock, jest, tsconfig, eslint, babel, env, or app config. No new import edge, no shared file, no merged hunk: the transferred proofs cover the union.

Not claimed (and not required for this acceptance): a whole-project `tsc`/Jest run on the union tree; any composed UI behaviour; wiring of `useImportOfferDecision` into `ImportOfferCard`/Home (does not exist in this tree); merge, push, deploy, or release; behaviour with `extensionImport` ON on a device.

## 4. Scope and authority boundary kept

The merge changes no product behaviour relative to either parent: no file is different from what one of the two accepted parents already carried. Account state remains a local UX decision cache; the presentation remains presentation-only. No new endpoint, flag, credential store, or governance surface. Heavy slot not touched (no runtime). Writes by the builder confined to `worktrees/ux-mobile-composed/**` and `execution/95633079/ux/mobile-composition/**` as attested; source worktrees verified untouched (§1).

## 5. Disposition

**ACCEPTED — pure local composition only**, exactly commit `716a606e…` / tree `430c76a0…`. Any tree other than `430c76a0…` or any authored change on top of it requires a new applicability decision. The next step (UX-03 J3 binding of state into presentation) is new source and belongs to its own scoped writer with its own A/B binding; nothing in this attestation pre-accepts it.

## 6. Class C records (continue; no fixer, control, or retest)

- RB-CC01: whole-project typecheck on the union was not run; not needed for acceptance of a byte-union with no new import edges (both parents individually pass `tsc` on identical files), and any later J3 delta will run `tsc` on its own tree anyway. Recorded so nobody reads "composition accepted" as "union typechecked".
- RB-CC02: the r1 commit `327731d4` (red test case, superseded by `8fd4cf75`) is now in the composed branch's history via the second parent; correct additive history, acceptable only at or after `8fd4cf75`/`716a606e`.

## 7. 18-path blob table (merge tree; all equal to owning parent)

Presentation (`df0ad112`): `c8bcb5f1…` SettingsScreen.tsx; `f20456f6…` ImportOfferCard.tsx; `23584782…` ImportSetupView.tsx; `c30fc355…` README.md; `04c9a42b…` ImportJourney.navigation.test.tsx; `cbaa44c6…` ImportOfferCard.test.tsx; `9255cf73…` ImportSetupView.test.tsx; `904c7e05…` importJourneyCopy.test.ts; `834b6a18…` sideEffectGuards.cjs; `7768128e…` i18n/en.json; `4c09b1b8…` importJourneyCopy.ts; `3f1fb60e…` importJourneyUI.tsx.
State (`8fd4cf75`): `83118fff…` storage/importOfferDecision.ts; `ddede726…` hooks/useImportOfferDecision.ts; `ceb33c45…` services/authActions.ts; `004e520e…` storage/__tests__/importOfferDecision.test.ts; `9c10f113…` hooks/__tests__/useImportOfferDecision.test.tsx; `fb3ac27c…` services/__tests__/authActions.test.ts.

Bradley decision required: NO.
