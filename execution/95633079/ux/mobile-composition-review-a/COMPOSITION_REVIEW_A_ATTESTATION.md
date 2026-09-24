# Mobile composition — review A binding attestation (pure local union only)

Reviewer A, independent T4 nonbuilder; requested Claude Fable 5 / High (requested setting, not observed). Bounded same-evidence composition binding: exact objects, blob union, overlap, cleanliness, identity/message, hooks, absence of authored change, and evidence applicability. **No product re-audit, no tests, no runtime, no probe, no commit, no remote; peer B not read.** Read-only git plumbing in `worktrees/ux-mobile-composed` plus the packet in `execution/95633079/ux/mobile-composition/`. Sole new writes: `execution/95633079/ux/mobile-composition-review-a/**`. Prior account-state review files preserved (manifests re-verified). Observation 2026-09-24T07:10Z.

## Verdict

**ACCEPTED — for the pure local composition only.** Merge commit `716a606e9d23c77a6d705beccb8cefc6e8228284`, tree `430c76a0a686f8756ea0d77f37613d3f85561fb2`, is the exact 18-blob union of the two accepted deltas over common base `bc7b4e96…`, with zero overlapping paths, zero authored hunks, clean state, Bradley identities, approved single-line message, no hooks or bypass. All previously accepted source reviews and runtime proofs transfer unchanged to identical bytes. **Class A: none. Class B: none.** Two Class C qualifications (§5). Nothing here accepts UX-03/J3 or any UI that does not exist; the next binding gets its own scoped writer.

## 1. Exact objects — independently re-derived

| Check | Observed |
|---|---|
| HEAD | `716a606e9d23c77a6d705beccb8cefc6e8228284` on branch `compose/importer-presentation-state` |
| Tree | **`430c76a0a686f8756ea0d77f37613d3f85561fb2`** |
| Parents, ordered | 1: `df0ad112529afcd9bfdf084e9930c90ee0bfffb3` (accepted presentation, tree `377e4b7a…`); 2: `8fd4cf759c2a8dd3f9ef9772f6dadb2035d93820` (accepted state, tree `17a6ce1a…`) ✔ both still the HEADs of `worktrees/ux07-mobile` and `worktrees/ux01-state` respectively |
| `git merge-base` | `bc7b4e96fc1db54568bc209dbe1f7a4121501ac9` (accepted S6) ✔ |
| Independent prediction | my own `git merge-tree --write-tree df0ad112 8fd4cf75` (git 2.53.0) → `430c76a0…`, rc 0 (clean) = actual merge tree ✔ |
| Author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com> 1790233568 +0000`, both ✔ |
| Message | `merge(importer): compose accepted journey presentation and account state` — single line, no body, `interpret-trailers --parse` → 0 ✔ |
| Hooks / remotes | `core.hooksPath` unset; non-sample hooks 0; remotes 0 ✔ |
| Clean | `git status --porcelain` empty; `git ls-files -u` 0; no `node_modules` in the clone ✔ |
| Bundle | `ux-mobile-composed-716a606e.bundle` sha `a61e43355ff104ab1d663c0ea4d90beaa0d352c55c7db9f193c100bed6751140`; `git bundle verify` ok; sole head `refs/heads/compose/importer-presentation-state` = `716a606e` ✔ |

## 2. Union, overlap, blob equality

- Paths vs base: presentation 12, state 6, **intersection 0, union 18**; sorted concatenation of the two path sets is byte-equal to the merge's base→HEAD path list ✔ (`union == pres ∪ state exactly`).
- Per-path blob equality, merge tree vs owning parent: **18/18 match, 0 mismatches** (list in `BLOB_UNION_CHECK.txt`). State blobs are the six I accepted at `8fd4cf75` (`83118fff…`, `ddede726…`, `ceb33c45…`, `004e520e…`, `9c10f113…`, `fb3ac27c…`); presentation blobs equal `df0ad112`'s.
- Every other path in the tree equals base (base→HEAD diff-tree yields exactly the 18).
- All 18 paths are under `src/`; no shared config (`package.json`, lock, `jest.setup.js`, `tsconfig.json`, `.eslintrc.js`, CI) touched by either delta ✔.

## 3. Cross-diffs and authored change

| Check | sha256 (mine) | Packet |
|---|---|---|
| `git diff df0ad112 716a606e` | `abaab9f10724e5ebb07ba2594d7c5477d032a2b40a9a59d7f4988adf1cc05dfc` | = `cross-diff-presentation-to-merge.patch` ✔ |
| `git diff bc7b4e96 8fd4cf75` (accepted state delta) | `abaab9f1…5dfc` — identical to the row above ✔ | = `state-delta-base-to-8fd4cf75.patch` ✔ |
| `git diff 8fd4cf75 716a606e` | `54b3c312125cb6deb07f88f0b7c12e630e97d3ca5df62fd3977a1a26df950118` | = `cross-diff-state-to-merge.patch` ✔ |
| `git diff bc7b4e96 df0ad112` (accepted presentation delta) | `54b3c312…0118` — identical ✔ | = `presentation-delta-base-to-df0ad112.patch` ✔ |
| `git diff-tree -p --cc 716a606e` | 41 bytes = commit id line only, **zero hunks** | = `merge-716a606e-combined.patch` ✔ |
| `git diff bc7b4e96 716a606e` | `c93661ac75fe010da86e6d0eef862a2b5e2697f9bd924fbe74d9033b79887795` | = `composed-union-base-to-716a606e.patch` ✔ |

Conclusion: applying the merge to either parent reproduces exactly the other parent's accepted delta; the merge itself authored nothing.

## 4. Evidence applicability (binding)

- Presentation acceptance (tree `377e4b7a…`, receipts under `execution/95633079/ux/mobile-presentation/**`) applies to the 12 presentation blobs, which are byte-identical in `430c76a0…`.
- State acceptance (my `UX01_STATE_REVIEW_A_FINAL_HEAD_ATTESTATION.md` at `8fd4cf75`, tree `17a6ce1a…`: 2 cases run on r2 + 55 reasoned-transfer passes from r1, `tsc`/ESLint RC 0) applies to the 6 state blobs, byte-identical in `430c76a0…`.
- Cross-module edges (static, read from the 18 blobs only, no product re-audit): no state file references any presentation path. Presentation references a state-modified file in exactly one place: `SettingsScreen.tsx` L19 `import { signOut } from '../../services/authActions'` — an import that already exists at base `bc7b4e96` (same line), and `authActions.ts`'s `export` lines are identical base vs state (the state hunk adds one internal import and one array entry). `sideEffectGuards.cjs` mocks `authActions` as a forbidden module in tests (a guard, not a runtime edge). No new import edge is created by the union, so the individually-passed whole-project `tsc --noEmit` results are not invalidated by composition.
- No runtime was run here and none is claimed for the composed tree as such; this is the stated boundary, not a gap requiring closure.

## 5. Class C qualifications (recorded; no cycle)

- **CA-C1:** Whole-project `tsc --noEmit` and the full Jest suite have not been executed on `430c76a0…` itself; applicability rests on byte-identity plus the no-new-edge argument in §4. Sound for a pure union with zero shared paths and zero shared config; recorded because it is an inference, not a replay. If any later phase touches either delta's files, this inference lapses (G09).
- **CA-C2:** `03-merge.txt` shows `Merge made by the 'ort' strategy` with `--no-ff --no-edit -m`; the composed clone has no `node_modules`, so no accidental tool run was possible there. Nothing to fix.

## 6. Boundaries

Accepted: the pure local composition commit `716a606e` as the exact union of two accepted heads. Not accepted or reviewed: UX-03/J3 binding, any UI composition or consumer wiring (none exists in this tree beyond the two accepted deltas), eligibility, intent, server copy, push, merge to any shared branch, deploy, or flag change. The next scoped writer's work requires its own binding.
