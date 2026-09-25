# LAND-PREP-1: landing and composition plan for S7-L and S8-C onto `integration/importer`

- **Planner:** `landing_composition_prep`, T3, grant LAND-PREP-1 (`daceddc8/SCOPE.md`).
- **Observed:** 2026-09-25 16:40–16:50Z.
- **Status: PLAN_READY.**

**What this planner did and did not do.** It did not push, open a PR, merge, commit, take the lock, run tsc, Jest, npm or prisma, or start PG. The product repos were only read, with one exception: `git merge-tree --write-tree` necessarily wrote unreferenced loose tree and blob objects into the backend object store (class C; see risk R6). The planner changed no ref, index or worktree. It also made read-only `gh api` calls. Raw evidence is in `analysis/`. The scripts in `scripts/` are drafts that were syntax-checked with `bash -n` and never run.

**Method sources:**

- `cf8ff737/LANDING_LEDGER.md`
- `cf8ff737/OWNER_AMENDMENT_AUTONOMOUS_LANDING.md` (the 16:26Z owner amendment)
- `cf8ff737/landing-census/LANDING_PLAN.md`
- `64e33dc7/S7L_REPLACEMENT_BUILD_GRANT.md` (sole generator ownership)
- `64e33dc7/S8C_SOURCE_GATES_GRANT.md` (the narrow generator transfer and the "later composition must regenerate from the combined real DTOs under a parent composition grant" rule)
- `daceddc8/SCOPE.md` and `daceddc8/HALF_DONE_WORK.md` A5

## LAND-1 revision (17:05Z): S7-L landed first, S8-C is composed second

This section supersedes the order in section 1 and corrects the check list in section 4. The analysis in sections 2 and 3 is unchanged: the final tree does not depend on the order.

**What happened**

- S8-C's v4 proof failed (class B, harness only). S8-C will get a new head, a child of `e0cee7e0`.
- The parent therefore took the symmetric fallback from section 1.
- **S7-L `df713fd9` was accepted and landed by fast-forward.** PR [#539](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/539) was pre-staged as a draft. Its CI was green: 11 pass, 1 expected skip, no red. It was marked ready and then fast-forwarded with one ordinary push, `93389265..df713fd9`, at 17:05:00Z. The remote was verified with ls-remote and `gh api`. GitHub marked the PR MERGED at 17:05:02Z. `main` is still `c23b9d9f`. Full record: `ci/s7-l/LANDED.md`.

**Next: compose S8-C second onto `df713fd9`.**
- Command: `SECOND=s8c SECOND_HEAD=<accepted S8-C head> FIRST_HEAD=df713fd9217df524915348ef8a42c797f288dde1 timeout -k 30 5400 bash scripts/compose-second.sh`.
- It uses prettier prefix `recovery-reset/s8c/tools/prettier-3.9.9`, which is manifest-verified at 17:06Z.
- It uses the S7-L worktree `node_modules`, whose schema equals the combined schema. That worktree must stay unmodified until composition finishes.
- Contract regeneration is unchanged: S7-L's generator, now landed, runs over the combined DTOs. Expected output is blob `f9109c06`.
- With today's S8-C head `e0cee7e0`, the predicted merged tree is `5dab5d5e`. With the corrected head, it is `5dab5d5e` plus the S8-C harness paths.
- Then run `SECOND=s8c [DRAFT=1] bash scripts/land-second.sh stage`, followed by `ff` after acceptance.
- PR title: "Land S8-C: native reconstruct writers, composed with S7-L (<short>)". The Migration Dry-Run checks do not trigger for S8-C, which has no migration.

**Script changes**
- Default order is now `FIRST=s7l`, `SECOND=s8c`. Both remain symmetric.
- The S8-C head is a parameter.
- Lineage is now anchor-based:
  - the anchor `a68cdac7` or `87018a42` must be an ancestor of the head;
  - for S8-C, `e0cee7e0` must also be an ancestor;
  - no merges;
  - post-anchor paths must match the lane-private harness pattern (`test/utils/g2-<lane>-*`, `test/rls-g2-<lane>.spec.ts`, `test/scout/g2-<lane>-db-guard.spec.ts`) and must lie outside the static import closure of the 27 composition suites (`analysis/composition-suite-closure.txt`, 975 files);
  - the contract blob must be unchanged.
- The predicted-tree check allows only those post-anchor paths as differences from `bb5436dd`.
- `land-first.sh` opens the fast-forward PR from `land/<slice>-accepted`, as done for #539.
- `check_pr_ci` now requires the checks that trigger on an integration/importer base (correction below).

**Correction to section 4 (class C, plan text only).** The 20 checks attributed to PR #538 are really two sets:
- **The 12-check set** that runs on a PR whose base is `integration/importer`: CI ×4, Migration Dry-Run ×3 (only when migrations are touched), npm audit, H4 ×3 and size-label.
- **The main-only set:** Danger ×2, CodeQL ×2, R75, actionlint, shellcheck and build-sbom. This set ran because draft PR #530 (`integration/importer` → `main`) synchronized at 22:46Z. Those workflows filter on `pull_request: branches: [main]`.

So Danger never runs on a `land/*` PR. Its title failure is a #530 artifact, which is known class C. Every integration fast-forward, including this one at 17:05:06Z, re-triggers the main-only set on #530. That is not a landing gate. It does not deploy, because deploys run only on a push to `main`.

**Risk updates**
- **R1 has now happened (class C).** The label `2.0.0-c1-s2.0` currently means S7-L's contract without `programs`. After S8-C is composed, the same label will mean the contract with `programs`. No consumer is pinned to those enums. Recorded; no action.
- **R4 no longer applies** to `land/*` PRs.
- **R5 was used** under LAND-1.
- **R3 is unchanged:** S8-F should move onto the composed tip before it regenerates the contract.

## 0. Live facts

| Fact | Value | Evidence |
|---|---|---|
| `integration/importer` | `93389265a846095b846fa8f1fb0dad782fb6ee9f`. Unprotected: the protection API returns 404 and there are 0 rulesets. No open PRs target it. | `analysis/remote-integration-importer.txt` |
| backend `main` | `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`. Never written by this plan. | same |
| S7-L | `exec64/s7l-replacement` at `a68cdac7` (tree `6c00e248`). 3 commits over base, no merges, 30 paths. Pending: one uncommitted path, `test/utils/g2-s7l-worker.cjs`. | worktree status |
| S8-C | `exec64/s8c-replacement` at `87018a42` (tree `cec7d05a`). 3 commits over base, no merges, 25 paths. Pending: one staged path, `test/utils/g2-s8c-bootstrap.sh`. | worktree status |
| Identity | Every commit in `93389265..a68cdac7` and `93389265..87018a42` has Bradley Gleave `<bradley@bradleytgpcoaching.com>` as author and committer. | `git log` |
| Existing `land/*` refs | `prod-ci-1`, `s7-b-drain`, `s7-c`(`-accepted`), `s7-l0`, `s7-nq1`(`-accepted`), `s8-0`, `s8-a`, `s8-b`(`-accepted`). `land/s7-l` and `land/s8-c` do not exist. | `gh api matching-refs` |
| Hooks | Common `.git/hooks/pre-commit` `3b741de3…` and `commit-msg` `71029ce8…` (lefthook). `core.hooksPath` is unset. **There is no `pre-merge-commit` hook**, only the sample. | `sha256sum` |

### 0a. Addendum, 16:54Z: both follow-ups are now committed (observed read-only; `analysis/FOLLOWUP_HEADS.txt`)

Both new heads were checked against the lineage rules that the scripts enforce, and both pass.

| Lane | Head | Tree | Parent | Only path | Blob |
|---|---|---|---|---|---|
| S7-L | **`df713fd9217df524915348ef8a42c797f288dde1`** | `796f437f` | `a68cdac7` | `test/utils/g2-s7l-worker.cjs` | `155ffdcc` |
| S8-C | **`e0cee7e04bef88811310f6dde1fd921f45d103ad`** | `b249efb6` | `87018a42` | `test/utils/g2-s8c-bootstrap.sh` | `7c3fba47` (matches the recorded WIP blob) |

- **Commit rules:** each head is a single-parent commit with Bradley as author and committer, no trailers, and R3-clean.
- **Merge result:** `git merge-tree --write-tree df713fd9 e0cee7e0` returns rc 0 and tree **`5dab5d5ea1265e61d080faaa31c810c72a5fa702`**, the same in both orders. It differs from `bb5436dd` in exactly the two follow-up blobs. The contract blob is still `f9109c06`.
- **Expected result of `compose-second.sh`:** a composition with these heads should produce committed tree `5dab5d5e`.
- **Acceptance still decides:** the scripts take the head named in each acceptance record, not these observed values. Any further change to a lane after this point is refused.
- **Remote tip:** still `93389265`.

## 1. Order recommendation: S8-C first by fast-forward, then S7-L composed

Both candidates descend directly from the current tip `93389265`, so whichever lands first is an exact-bytes fast-forward. The second one has to be a merge.

`git merge-tree` gives the identical tree `bb5436dd` in both merge directions (section 2). **The final bytes do not depend on the order.** The order therefore only decides which candidate carries a landing delta and how cheaply that delta can be proven. Recommend **S8-C first**, for these reasons:

1. **It is likely accepted first.** In the heavy-slot queue (SCOPE), the S8-C v4 proof is item 4 and the S7-L v4 proof is item 5. Landing S8-C by FF as soon as it is accepted wastes no time. Composition gates are item 6, which is exactly when S7-L is being accepted.
2. **The regeneration owner is also the side being composed.** S7-L holds sole generator ownership: `scripts/importer-contract.ts`, the contract JSON, and `test/contracts/importer-contract.spec.ts` with its version pin and drift and cross-process determinism tests. S8-C only had a narrow, temporary generation exception. When S7-L is merged onto S8-C, S7-L's unchanged generator and its own contract spec check the combined DTOs. That meets the S8-C gates grant's rule to regenerate from the combined real DTOs under a parent composition grant, with no other owner involved.
3. **The runtime is already correct.** The combined `prisma/schema.prisma` is byte-identical to S7-L's (sha `0eb41f9a…`), and S8-C does not touch the schema. The S7-L lane already holds the matching generated client: `index.d.ts` `9042e713…`, client schema `b8439203…`. The composition worktree copies it with `cp -a` and runs no `prisma generate`. This is true in either order, but with S8-C first the composing side is also the side the runtime came from.
4. **The contract version label stays unambiguous.** S8-C's accepted bytes add `programs` under the unchanged `2.0.0-c1-s1.2` label (the grant forbade version edits). That label reuse is already-accepted bytes. With S8-C first, `2.0.0-c1-s2.0` appears on the branch exactly once, already including `programs`. With S7-L first, `s2.0` would first denote the artifact without `programs` and then, after the composition, the one with it. That would be a new landing-created label ambiguity (R1).
5. **S8-F's base is simpler.** S8-F composes onto the accepted S8-C head (SCOPE S8F-COMP-1). If S8-C lands first, that head is an exact landed commit.
6. **Migration CI still runs where it should.** S7-L carries the only new migration folder, `20270123000000_scout_run_lifecycle_expand`. On the composition PR, the diff against the base (S8-C) contains that folder, so the three Migration Dry-Run checks trigger on its PR.

**Fallback (do not hold accepted work).** If S7-L is accepted while S8-C is not, land S7-L first with `FIRST=s7l`, then compose S8-C with `SECOND=s8c`. The scripts are symmetric. The only extra cost is the R1 label qualification (C).

If both are accepted before either lands, use S8-C first.

## 2. `git merge-tree` analysis of `a68cdac7` and `87018a42`

Raw output is in `analysis/MERGE_TREE_RAW.txt` and `analysis/CONTRACT_OVERLAP.txt` (git 2.53.0).

**Merge result**

- `git merge-tree --write-tree a68cdac7 87018a42` returns rc 0 and tree **`bb5436dd249744c52d5d1d0a30618a81c2b62829`**. Its only message is `Auto-merging docs/contracts/importer-openapi.json`.
- The reversed order gives the same tree with rc 0. The merge-base is `93389265`.

**Exact overlap.** The two candidates' path sets intersect in exactly one path, `docs/contracts/importer-openapi.json`. Every other path in the merged tree is byte-identical to the one side that changed it. Both directions were checked blob by blob.

| Blob | Contract artifact |
|---|---|
| base `c0d62590` | `68dfd959…`, version `2.0.0-c1-s1.2`, 13 paths, 30 schemas |
| S7-L `3c1fd2ac` | `fc42af0a…`, `2.0.0-c1-s2.0`, 15 paths, 36 schemas. 563 lines added, 6 removed: runs/start and runs/cancel, lifecycle/status/families fields, 409 codes |
| S8-C `493234f1` | `727eb523…`, `2.0.0-c1-s1.2`. Exactly two semantic deltas: `programs` appended to `components.schemas.ScoutReconstructDto.properties.entity_type.enum` and to the `family` query-parameter enum of `GET /api/scout/reconstruct/entities` |
| Textual merge `f9109c06` | sha256 **`77d5ffd10efefb4400b87c1d802d8c6f2bb92a4182f4d067a9e9fe217ed50f09`**, `2.0.0-c1-s2.0`, 15 paths, 36 schemas. Valid JSON. The semantic diff from S7-L to the merge is exactly S8-C's two enum additions and nothing else |

**The follow-ups are test-only and lane-private.** `test/utils/g2-s7l-worker.cjs` is in S7-L only. `test/utils/g2-s8c-bootstrap.sh` is in S8-C only. Neither the other candidate nor any default Jest root touches either one, because `jest.config.js` ignores `test/rls-*.spec.ts`, which is where they are used. So the post-follow-up merge tree is `bb5436dd` with those two blobs replaced. It adds no overlap, and the contract blob stays `f9109c06`. `compose-second.sh` asserts both facts on the real heads.

**Can the textual contract merge be trusted?** It is expected to be correct, but it must be regenerated and proven, not trusted. Two grant rules require this:

- The S8-C gates grant says composition must regenerate from the combined real DTOs.
- No hand-authored generated artifact is allowed (S7-L grant).

Static prediction says regeneration will be **byte-identical** to the textual merge:

- The enum is derived from `RECONSTRUCT_ENTITY_TYPES = Object.values(RECONSTRUCT_FAMILY)`, which S8-C changes, and from `ENTITY_REVIEW_FAMILIES`, which filters it. No S7-L DTO references those constants.
- S7-L's `ScoutImportFamilyDto.family` is a free `string` with no enum.
- S7-L's generator delta only adds `/scout/runs/{start,cancel}` and bumps `CONTRACT_VERSION`. `stableSort` and serialization are unchanged.
- The S7-L contract spec asserts only `not.toContain('clients')` and a nonzero length on the entities family enum, so adding `programs` passes.
- `.prettierignore` lists the artifact, so the prettier hook cannot reflow it.

**Regeneration**

- **Owner.** The sole generator is S7-L's unchanged generator (`scripts/export-importer-contract.ts` → `scripts/importer-contract.ts`). The parent composition grantee runs it in a fresh composition worktree, as the single writer of that worktree. Neither lane builder may run it, and no one edits the generator, spec, version constant or JSON.
- **Command**, in the merged, uncommitted worktree, with `NODE_OPTIONS=--max-old-space-size=4096 npm_config_offline=true`:
  1. `npm run contract:importer`, which is `ts-node scripts/export-importer-contract.ts` and writes `docs/contracts/importer-openapi.json`.
- **Determinism check**:
  1. The in-place output sha256 must equal `77d5ffd1…` and `git diff --quiet -- docs/contracts/importer-openapi.json` must hold, meaning the worktree equals the staged textual merge.
  2. A second cold process, `IMPORTER_CONTRACT_OUT=<run>/contract-scratch.json npm run contract:importer`, must give `cmp`-identical output.
  3. `test/contracts/importer-contract.spec.ts` must pass: drift check, same-process determinism, cross-process determinism and the `2.0.0-c1-s2.0` pin. It is in the Jest set.
- **If the output differs:** stop with rc 73 and keep the diff. The regenerated bytes are then a landing-changed delta that the parent must classify before anything is committed. Never hand-edit.

## 3. Composing the second candidate (`scripts/compose-second.sh`)

**Preconditions**

- A parent composition grant exists, for example LAND-COMP-1. It names the composing executor as sole writer of `worktrees/daceddc8-land-<slice>` and holder of heavy-slot item 6.
- FIRST is landed, meaning `ls-remote integration/importer` equals FIRST_HEAD.
- SECOND_HEAD is the committed follow-up head. Composition may run before SECOND's PG proof if the slot is idle. Its result is used only if SECOND is then accepted.

**Command**

```
SECOND=s7l SECOND_HEAD=<H7> FIRST_HEAD=<H8> timeout -k 30 5400 bash scripts/compose-second.sh
```

**Steps.** The first failure exits nonzero. State is preserved: no `merge --abort`, no retry.

1. **Refusals.**
   - Refuse any of `LEFTHOOK=0`, `LEFTHOOK_BIN`, `LEFTHOOK_EXCLUDE`, `GIT_DIR`, `GIT_WORK_TREE`, `GIT_INDEX_FILE`, or a set `core.hooksPath`.
   - The hook shas must be `3b741de3…` and `71029ce8…`.
   - The remote tip must equal FIRST_HEAD.
   - Lineage for both candidates:
     - HEAD^ is `a68cdac7` or `87018a42`, a single parent;
     - HEAD^..HEAD touches exactly the one follow-up path;
     - the head descends from `93389265` with no merges;
     - the lane branch is at that head;
     - the contract blob is the one analysed here;
     - every commit has Bradley as author and committer, no trailers and no R3 tokens.
2. **Predicted tree.** Run `git merge-tree --write-tree FIRST_HEAD SECOND_HEAD`. It must return rc 0. Its difference from `bb5436dd` must be at most the two follow-up paths, and its contract blob must be `f9109c06`.
3. **Slot.** `exec 9>>/home/user/workspace/execution/test-validation.lock; flock -n 9`. Refuse if the lock is busy or the file is absent. The lock is held until the process exits and is never deleted. Refuse if any relevant process (jest, tsc, prisma, postgres, prettier or lefthook) is live.
4. **Worktree and runtime.**
   - `git worktree add -b land/s7-l /home/user/workspace/worktrees/daceddc8-land-s7-l FIRST_HEAD`.
   - `cp -a` `worktrees/64e33dc7-s7l/node_modules`. Verify hidden lock `05bc530a…`, client `9042e713…` and client schema `b8439203…`. No install, no generate.
   - Prettier prefix: `npm_config_prefix=/home/user/workspace/execution/64e33dc7/recovery-reset/<SECOND lane>/tools/prettier-3.9.9` (so `s7l` for S7-L) with `npm_config_offline=true`. Verify against the 56-line manifest and the relative bin link. `npx --no-install prettier --version` must print `3.9.9`.
   - Heap: `NODE_OPTIONS=--max-old-space-size=4096`.
   - Identity: `GIT_{AUTHOR,COMMITTER}_{NAME,EMAIL}` set to Bradley.
5. **Merge.** Run `git merge --no-ff --no-commit SECOND_HEAD`. Conclude with `git commit`, not a plain `git merge`. Git runs `pre-merge-commit` (not installed) for an auto-committing merge, but runs the genuine lefthook `pre-commit` and `commit-msg` when `git commit` concludes the merge. Checks: MERGE_HEAD equals SECOND_HEAD, there are no unmerged paths, `git write-tree` equals the predicted tree, and the schema sha equals `0eb41f9a…`.
6. **Contract regeneration and determinism**, exactly as in section 2.
7. **Affected Jest**, with heap 4096: `jest --ci --runTestsByPath` over the 27 suites in `analysis/composition-jest-suites.txt`.
   - **Selection:** default-config suites whose static import closure (`analysis/impgraph.py`, on the merged tree) contains bytes from both candidates. The two artifact readers, `importer-contract.spec` and `scout-entities.contract.spec`, are included.
   - **Exclusions:** `test/rls-g2-c-contract.spec.ts` is excluded because the default config ignores `rls-*`. Suites that touch only one side are unchanged and are not rerun (owner amendment).
   - **Groups:**
     - scout lifecycle, service and controller, and ingest ×3;
     - reconstruct ×5, including native `engine-handoff`;
     - entities ×3, roster ×2, cursor;
     - the two contract specs;
     - the AppModule-booting specs: module-graph, openapi-spec, auth ×2, rate-limit, roles-enforced, throttler.
   - The remote `build-and-test` job still runs the full `npm test`.
   - Afterwards, `git diff --quiet` must hold and the index must still equal the predicted tree.
8. **Genuine hooked commit.** Run `git commit -F <msg>` with no `--no-verify`.
   - **Hooks run:** lefthook pre-commit (R75 staged, `npx tsc --noEmit` at heap 4096, eslint `--max-warnings 0` and prettier 3.9.9 `--check` on the staged files) and the commit-msg R3 token check.
   - **Message:** `Merge S7-L server-owned run lifecycle (<H7:8>) into integration/importer`, plus a factual body with no trailers. It is prescanned against the hook's token regex. This follows the `93389265`, `7325e8cb` and `7ea039f3` convention.
   - **Checks after commit:** the parents are exactly (FIRST_HEAD, SECOND_HEAD), the committed tree equals the predicted tree, Bradley is author and committer in FIRST_HEAD..M, and the worktree is clean.
9. **Export.** Bundle `BASE..M` (verified), name-status against FIRST, `COMPOSE_RECEIPT.txt` and `SHA256SUMS` go under `landing/run/compose-second-*/export/`. The script writes `landing/state/compose-<lane>.env` and exits, which releases the lock.

**Delta classification.** If the regenerated contract equals the textual merge and the committed tree equals the predicted tree, the landing-created delta is only the merge commit identity over an exact union of accepted bytes. That is class C, with no re-review and no rerun of accepted proofs. Any other result stops the run for parent classification.

## 4. PR and CI procedure (`scripts/land-first.sh`, `scripts/land-second.sh`)

**Naming.** This follows the backend convention seen on #533–#538:

- `land/<slice>-accepted` holds the exact accepted candidate head.
- `land/<slice>` holds the landing head.
- For S8-C first: `land/s8-c-accepted` = `land/s8-c` = H8.
- For S7-L second: `land/s7-l-accepted` = H7 and `land/s7-l` = M, the merge.

**Titles**, in the established "Land …" form:

- `Land S8-C: native reconstruct writers for workouts and programs (<H8:8>)`
- `Land S7-L: server-owned import run lifecycle, composed with S8-C (<H7:8>)`

These fail the Danger Conventional-Commits title rule. That failure is known class C (see R4).

**Steps**

1. `land-first.sh preflight`. It fetches, then checks that the remote tip is `93389265`, the lineage and identity, that the lane worktree is clean at the head, and that main was not written.
2. `land-first.sh stage` (with `DRAFT=1` if acceptance is still pending).
   - It pushes the two `land/` refs. Each push is ordinary: the ref must be absent or already equal, there is no `+` and no force, and `ls-remote` verifies it.
   - It runs `gh pr create --base integration/importer --head land/s8-c`.
   - **Near-instant option:** staging for CI in parallel with the reviews or proof is a non-production remote write before acceptance. There is precedent in PROD-CI-1, PR #531. The parent decides. Without this option, stage right after acceptance and wait one CI cycle of about 6 minutes; `build-and-test` took 5m34s on #538.
3. **Checks that must pass**, as observed on the last integration PR, [PR #538](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/538) (20 checks, `analysis/pr538-checks.json`):
   - **Must pass:** `build-and-test` (CI: lint, tsc at 4096, build, full `npm test`), `rls-floor-guard`, `rls-live-tests`, `mwb-3-live-tests`, `Banned cast tokens (R75 / R100.A2)`, `CodeQL JS/TS`, `actionlint`, `shellcheck`, `npm audit (high+critical)`, `build-sbom` and `test-deploy-readiness`.
   - **May pass or skip:** `CodeQL`, `comment-deploy-readiness`, `size-label`, and `deploy-readiness-gate` (skipping).
   - **Only when the PR diff touches `prisma/migrations/**`**, which means the S7-L PR in either order: `Forward migrations apply cleanly`, `New migrations are reversible (or explicitly marked IRREVERSIBLE)` and `Schema parity (deferred…)`.
   - **Class C only:** `danger` and `danger dry-run (dangerfile.js)` may fail, but only with the single rule "PR title is not Conventional Commits format" and "there is 1 fail". The script reads the failed-job log and refuses on any other Danger failure.
   - The branch is unprotected, so none of these is GitHub-enforced. The plan enforces them.
4. `land-first.sh ff`, with `ACCEPT_RECORD` set to the PG-4 terminal receipt or acceptance record, which must name the exact head and ACCEPT.
   - The PR head must equal H8 and CI must be green as defined above. A draft PR is marked ready.
   - The remote tip must still be `93389265` and must be an ancestor of H8.
   - It then runs **`git push origin <H8>:refs/heads/integration/importer`**, an ordinary FF with no force. If the push is rejected, it stops and does not retry.
   - It verifies **`git ls-remote origin refs/heads/integration/importer` = H8**, checks the remote commit's author, committer and tree through `gh api`, and confirms main is unchanged. GitHub then marks the PR MERGED, as with #538.
5. After `compose-second.sh`, run `land-second.sh stage` and then `land-second.sh ff`. The values come only from `state/compose-s7l.env`.
   - It re-checks the remote tip (H8), the parents and tree of M, the contract blob and identity.
   - It pushes `land/s7-l-accepted` (H7) and `land/s7-l` (M), and opens the PR. When accepted and green (migration checks required), it runs **`git push origin <M>:refs/heads/integration/importer`** and checks `ls-remote` = M.
   - It asserts H7 is contained in the landed tip.
6. **Ledger.** The parent appends a row for each landing to `cf8ff737/LANDING_LEDGER.md`, or to the daceddc8 landing ledger if it keeps one, with the UTC time, before and after SHAs, method and evidence. This planner does not write the ledger.

**Never, in any script:** `integration/importer` → `main`, which is PR #530, the production deploy and owner-reserved. Also never: the GitHub merge button, force, `--no-verify`, amend or ref deletion.

## 5. Risks (Safety-ROI)

There are no A or B findings against landing either candidate.

| # | Class | Harm | Decision blocked | Minimum closure | Unlocked |
|---|---|---|---|---|---|
| R1 | C | A contract version label can denote two artifacts. `2.0.0-c1-s1.2` already does (base vs S8-C accepted bytes; the grant forbade a version edit). With S7-L first, `2.0.0-c1-s2.0` would too. No importer consumer is frozen on these enums; the frozen C1 pair surface is not touched by the `programs` enums. | None | Choose S8-C first, so `s2.0` is unique on the branch. Otherwise record it. No generator or version edit. | Both landings |
| R2 | C | The composition runs no single PG proof. Each candidate's PG proof ran against base plus itself. The interaction points found statically are benign. (a) `ScoutLifecycleService.collectFacts` uses `buildFamilyRegistry().has()` only for informational `unmapped_families`; after composition, `programs` is correctly no longer "unmapped", and the arbiter does not use that field. (b) S8-C's PG harness inserts legacy `ScoutImport` rows with explicit columns; S7-L's new columns are nullable or defaulted (`mode 'legacy'`, `execution_epoch 1`), so the CHECKs hold. (c) S7-L does not touch reconstruct, and S8-C does not touch lifecycle, ingest or schema. (d) S8-C's `buildFamilyRegistry(options = {})` is backward compatible with S7-L's no-argument call. | None | Covered by tsc in the hook, the 27 spanning suites, and remote full `npm test` plus `rls-live-tests`. Rerunning accepted PG proofs is not required by the owner amendment. | Landing the second without another PG slot |
| R3 | C | S8-F's frozen 15-path draft and its "narrow contract regeneration" were planned on `87018a42`. If S8-F regenerates before S7-L lands, it creates a third overlap on `importer-openapi.json` and needs another composition merge. | S8-F landing base, not this landing | Move S8-F onto the landed composed tip (M) before its generator run, and regenerate there with the unchanged S7-L generator. | S8-F lands by FF, not by merge |
| R4 | C | The Danger PR-title check fails on the "Land …" titles. A Conventional title such as `feat(scout): …` would clear it but break the #533–#538 convention. | None | Known class C per owner constraint. The script verifies the failure is only that rule. | CI verdict |
| R5 | C | Staging a PR before acceptance (`DRAFT=1`) pushes not-yet-accepted bytes to `land/*`. This is non-production, and there is no FF until acceptance. | None | Parent decides. There is precedent (PROD-CI-1 #531). Without it, landing waits one CI cycle of about 6 minutes after acceptance. | Near-instant landing |
| R6 | C | During planning, `git merge-tree --write-tree` wrote unreferenced loose objects into `growth-project-backend/.git/objects`. No ref, index, worktree or history changed. | None | Record only. gc can remove them. | n/a |
| R7 | C | Regeneration might not equal the textual merge. It is statically predicted equal (section 2). If it happens, it is a landing-changed byte set. | Landing the second, only if it occurs | `compose-second.sh` stops with rc 73 and keeps the diff. The parent classifies it. No hand edit. | n/a |
| R8 | C | The local clone's `refs/remotes/origin/*` can be stale. | None | The scripts decide with `ls-remote` and an ordinary fetch of the target ref only. | n/a |

## Files

- `PLAN.md`: this file.
- `scripts/landing-lib.sh`: shared pins and refusals (identity, lineage, acceptance, CI, ordinary push, FF, and hook/bypass refusals).
- `scripts/land-first.sh`: `preflight`, `stage` and `ff` for the first candidate.
- `scripts/compose-second.sh`: merge, regeneration, determinism, Jest and hooked commit, under the canonical slot.
- `scripts/land-second.sh`: `stage` and `ff` for the composed merge.
- `analysis/MERGE_TREE_RAW.txt`, `analysis/CONTRACT_OVERLAP.txt`, `analysis/spanning-specs*.txt`, `analysis/composition-jest-suites.txt` (27 suites), `analysis/impgraph.py`, `analysis/pr538-checks.json` and `analysis/remote-integration-importer.txt`.
- `SHA256SUMS`.
