# LAND-PREP-1910: exact nonproduction landing recipe for S8-F (plus the S9-A FF path)

## Tier header

- **Tier:** T3. This is bounded landing preparation. Nothing has been executed, installed, gated, committed, pushed or PR'd, and no heavy lock was taken.
- **Why:** This changes the remote-landing procedure for a nonproduction branch (integration/importer). It reuses exact accepted bytes and adds no product change.
- **T4 scan:** No production. `main` (1c10e2a1) is never written. No secrets, no billing, no schema or migration change, no force push, no ref deletion. → no T4 trigger.
- **T3 scan:** It writes a new merge commit and pushes to a shared nonproduction branch. That is parent-only authority, taken under a separate grant.
- **Bounded T1:** Prediction and classification are read-only (scratch bare repo in /tmp, no workspace clone touched).
- **Canonical builder:** Parent, or a parent-granted landing executor. The preparer only ran `bash -n` and the read-only `predict`/`classify` modes.
- **Parent owner:** The EXEC-1910A060 parent, which holds sole remote-landing authority.
- **Acceptance evidence:**
  - `run/predict-*` / `run/classify-*` logs.
  - `analysis/L2-2-DISPOSITION.md`.
  - At execution time: `run/compose-*/export/COMPOSE_RECEIPT.txt`, PR checks JSON, and the ls-remote verification.
- **Promotion triggers (stop and return to the parent):**
  - The remote integration tip is not 1c5fbb04.
  - main is not 1c10e2a1.
  - `land/s8-f*` exists at a different sha.
  - The merge tree differs from 23614f0b.
  - Any hook fails.
  - CI is not green on the first observation.
  - An acceptance record is missing or negative.

## 1. Inputs (exact, verified 2026-09-25 21:15–21:29Z)

| Item | Value |
|---|---|
| Remote integration/importer | `1c5fbb0441178e0cfe6e9f8d72e955c645c265e9`, tree `82b56ad3`, sole parent `1c10e2a1`, one path `A docs/decisions/2026-09-25-s9-reconciliation.md` (blob `c3423725`), PR #541 CI 8 pass + 1 skip |
| Remote main | `1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47` (never written) |
| Remote `land/s8-f*`, `land/s9-a*` | absent |
| S8-F exact candidate | `e1ec2fecb71f315b6721d426ba0dacb84f304498`, tree `2fe0201ff132dfdc53ea82b3f26ed0fc8d1c65d6`, parent `1c10e2a1`, Bradley author+committer, no trailers, 17 paths, 0 migrations |
| S8-F object source | `execution/64e33dc7/s8f/checkpoints/v1/s8f-e1ec2fec.bundle`, sha256 `a69b4fc8…c467`, ref `refs/heads/exec-dace/s8f` (the only source; never rebuilt) |
| Predicted merge tree | `23614f0b7dc33dc37b90cf4f27fcb8331912e60f`: `git merge-tree --write-tree` rc 0 in both orders, no conflicts |
| Union check | tree − S8-F = exactly `A docs/decisions/2026-09-25-s9-reconciliation.md`; tree − tip = the S8-F `diff --raw` byte for byte; contract blob `8ebf936a` (unchanged vs S8-F); schema `0eb41f9a…`, package-lock `b7fed5ed…`, 172 migrations (unchanged) |

The prediction was re-proven by the script itself: `run/predict-20260925T212826Z/run.log` (PREDICT_OK) and `run/classify-20260925T212846Z/` (overlap 0, selection 1 false positive).

## 2. What is reused and what is new

- **Reused unchanged:** the accepted S8-F bytes `e1ec2fec` and its gates (33/33 suites, hooks, deterministic contract regen) from `64e33dc7/s8f/composition/COMMIT_READY.md`. G09 allows reuse because the inputs are unchanged for every S8-F-affected suite (§4).
- **New artifact:** one merge commit M, with parents (`1c5fbb04`, `e1ec2fec`) and tree `23614f0b`, by Bradley Gleave, made through the genuine lefthook hooks. G17 requires proven evidence applicability for a new merge commit; §4 is that proof.
- **Not done, by design:**
  - No 33/33 rerun.
  - No PG proof rerun.
  - No jest.
  - No contract regen.
  - No `npm ci` or `prisma generate`.
  - No hand edits.
  - No adaptation of the old compose-second.sh and its irrelevant pins.

## 3. Prerequisites (all must hold; the script checks the ones it can)

1. **S8-F source + binding reviews: dual GO.**
   - Source GO is present in `s8f/reviews/REVIEW_A.md` and `REVIEW_B.md`.
   - Review B §195 marks binding v1 "NOT executable in this environment". The v2-binding disposition and the S8-F PG proof are still **pending**.
2. **S8-F acceptance record** (`ACCEPT_RECORD`). It must name `e1ec2fec`, carry ACCEPT, and contain no NO-GO/REJECT. It must follow a passing S8-F PG proof under the accepted binding.
3. **Parent landing GO record** (`LAND_RECORD`). It must name the exact merge sha M (known after compose) and carry ACCEPT.
4. **RT-NEW-1 complete.** At 21:24Z it was still running: the clone was OK, and `node_modules` and hooks were not yet present in `worktrees/1910a060-s8f`.
   - The parent relays three sha256 values from its receipt: `DONOR_NM_LOCK_SHA` (`node_modules/.package-lock.json`), `DONOR_CLIENT_DTS_SHA` (`.prisma/client/index.d.ts`) and `DONOR_CLIENT_SCHEMA_SHA` (`.prisma/client/schema.prisma`).
   - The prettier 3.9.9 prefix must exist at `/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9` and verify against the 56-line manifest.
5. **Canonical lock slot.** The lock is `/home/user/workspace/execution/test-validation.lock`, inode 667698. `compose` takes it with `flock -n` on fd 9 and never waits or steals. It must be serialized with the S8-F PG proof, because compose copies (reads) the proof clone's `node_modules`.
6. **Remote precondition at each mode:**
   - integration/importer == `1c5fbb04`.
   - main == `1c10e2a1`.
   - `land/s8-f-accepted` is absent or == `e1ec2fec`.
   - `land/s8-f` is absent (compose) or == M (stage/ff).
7. **GitHub credentials** for `git ls-remote`/`push` and `gh`. Run with the github credential preset.
8. **Environment.** Do not set LEFTHOOK=0, LEFTHOOK_BIN/EXCLUDE, GIT_DIR/GIT_WORK_TREE/GIT_INDEX_FILE, or core.hooksPath.
9. **Clean slate.** `worktrees/1910a060-land-s8f` and `landing/state/compose-s8f.env` must not exist. compose is one-shot, and failed attempts are preserved, never deleted.

## 4. Evidence applicability (the L2-2 repo-reader selection)

`analysis/L2-2-DISPOSITION.md` Case A has the detail; the raw output is `analysis/selection-s8f-onto-1c5fbb04.txt`.

- The integration-side delta is one Markdown decision doc.
- No default-config spec imports it, reads it, walks `docs/` or enumerates repo-root Markdown.
- The single conservative hit, `test/ci/delivery-artifact.spec.ts`, reads only `.github/`, `scripts/`, `Dockerfile` and `.dockerignore`, so it is a false positive.
- **Result: 0 composition-affected suites.**
- The contract generator's inputs are byte-identical to the S8-F-gated tree, so there is no regen.
- No `prisma/` path changes, so there is no Migration Dry-Run.
- The genuine pre-commit hook re-runs whole-project `tsc`, plus R75, eslint and prettier on the 17 staged S8-F paths (same bytes as S8-F's own hooked commit). Full `npm test` then runs once in PR CI.

## 5. Steps (parent runs each once; any nonzero exit stops)

Script: `landing/land-s8f-1910.sh`. Runs write `landing/run/<mode>-<UTC>/` and `landing/state/*.env`.

```bash
L=/home/user/workspace/tgp-private-evidence/execution/1910a060/landing
# 0. Read-only re-prediction right before the grant (safe any time; exit 79 = frontier moved -> §7)
bash $L/land-s8f-1910.sh predict
# 1. Compose (canonical lock; fresh clone; merge --no-ff --no-commit; tree==23614f0b; one hooked Bradley commit; export)
COMPOSE_GRANT=1 DONOR_NM_LOCK_SHA=<rt> DONOR_CLIENT_DTS_SHA=<rt> DONOR_CLIENT_SCHEMA_SHA=<rt> \
  timeout -k 30 3600 bash $L/land-s8f-1910.sh compose
# 2. Stage (push land/s8-f-accepted=e1ec2fec and land/s8-f=M, ordinary; open ONE PR base integration/importer)
STAGE_GRANT=1 bash $L/land-s8f-1910.sh stage
# 3. After that PR's CI completes (observe ONCE; not green => stop, no re-stage)
FF_GRANT=1 ACCEPT_RECORD=<S8-F acceptance naming e1ec2fec> LAND_RECORD=<parent GO naming M> bash $L/land-s8f-1910.sh ff
```

### What compose verifies

1. Refuses any hook-bypass environment, then takes the lock and checks the remote precondition.
2. Creates a fresh standalone clone `worktrees/1910a060-land-s8f` on branch `land1910/s8f`.
3. Fetches the tip from origin and checks it equals `1c5fbb04` with tree `82b56ad3`.
4. Fetches S8-F from the bundle only, verified by sha256 and `bundle verify`. It must equal `e1ec2fec`, with tree `2fe0201f` and parent `1c10e2a1`, and pass the hygiene check.
5. Checks the schema and lockfile pins.
6. Copies `node_modules` from the RT-NEW-1 donor with `cp -a`. The donor HEAD must be `e1ec2fec` and its pins must equal the relayed values. The donor is never modified.
7. Runs `lefthook install` into the new clone and checks the hooks by path-normalized comparison against `worktrees/1910a060-s8f/.git/hooks` (lefthook 2.1.9, own-clone lefthook reference). This superseded the fixed raw pins `3b741de3…`/`71029ce8…`; see `CORRECTION-1.md` (script sha256 `2adc7e10…`).
8. Checks prettier 3.9.9 through the verified prefix.
9. Runs `git merge --no-ff --no-commit refs/heads/s8f-accepted`, then checks:
   - MERGE_HEAD is `e1ec2fec`.
   - There are no unmerged paths.
   - `write-tree` equals `23614f0b`.
   - The staged set against the tip is exactly S8-F's 17 paths.
   - The contract and doc blobs are pinned.
10. Makes one `git commit -F` with the genuine hooks (no `--no-verify`, no amend). The message is pre-scanned against the commit-msg banned-token regex and has no trailers.
11. After the commit, checks:
    - The parents are exactly (`1c5fbb04`, `e1ec2fec`).
    - The tree is `23614f0b`.
    - Author and committer are Bradley Gleave <bradley@bradleytgpcoaching.com>.
    - The worktree is clean.
12. Exports the bundle `1c5fbb04..land1910/s8f`, the receipt and SHA256SUMS.

### What stage and ff do

- `stage`:
  - Makes ordinary absent-or-equal pushes of `land/s8-f-accepted` and `land/s8-f`, each verified by ls-remote.
  - Opens exactly one PR, `land/s8-f` → `integration/importer`.
  - Refuses a second stage.
- `ff`:
  - Checks both acceptance records.
  - Checks that the tip is still `1c5fbb04` and that `land/s8-f` == M.
  - Checks that the PR head is M and CI is green. The required checks are build-and-test, rls-floor-guard, rls-live-tests, mwb-3-live-tests, npm audit (high+critical, whole graph), test-deploy-readiness and size-label. All others must pass or be skipping, and pending counts as not green.
  - Makes one ordinary `git push <origin> M:refs/heads/integration/importer`.
  - Verifies with ls-remote and `gh api` (author, committer, tree), and checks main is unchanged.
  - The PR closes as merged through the FF. The merge button is never used.

## 6. S9-A pure fast-forward path (if S9-A is accepted before S8-F lands)

**Preconditions:**

- The S9-A gate (`s9a/gate/s9a-gate-1910.sh`) has produced one hooked Bradley commit S9 on `exec1910/s9a` in `worktrees/1910a060-s9a`.
- The S9-A acceptance record names S9.
- The remote tip is still `1c5fbb04`.

```bash
STAGE_GRANT=1 bash $L/land-s8f-1910.sh s9a-stage <S9>
FF_GRANT=1 ACCEPT_RECORD=<S9-A acceptance naming S9> LAND_RECORD=<parent GO naming S9> bash $L/land-s8f-1910.sh s9a-ff <S9>
```

**What s9a-stage and s9a-ff check:**

- S9's single parent is the current tip (a pure FF, no merges).
- The diff is exactly the 4 paths `src/scout/reconciliation/{coverage,reconcile,types}.ts` and `test/scout/reconciliation/reconcile.spec.ts`.
- There are no `prisma/`, `docs/` or package changes.
- The commit passes identity and hygiene checks, and the clone is clean.
- `land/s9-a` is an ordinary push, with one PR and CI observed once.
- The FF push is ordinary, and main is checked unchanged.

**Ordering consequence:** whichever of the two lands first changes the frontier for the other. S9-A is then no longer a pure FF, and the S8-F compose/stage/ff steps refuse with exit 79.

## 7. Frontier moved: classify the exact changed dependency (never blind replay)

If any mode exits 79, or the tip is not `1c5fbb04`:

1. Run `bash $L/land-s8f-1910.sh classify <candidate sha>` (e1ec2fec, or S9). It is read-only and always exits 79. It records:
   - The tip commits and the tip delta name-status.
   - Paths both sides touched.
   - The merge-tree result (the new predicted tree or the conflicts).
   - The conservative L2-2 selection on the predicted tree.
   - Pinned-path changes (migrations, contract, schema, package files).
2. The parent dispositions the result. This script is pinned to `TIP=1c5fbb04` and `PRED_TREE=23614f0b` and will not compose onto another tip. A moved frontier needs a new bounded prep delta:
   - New `TIP`, `TIP_TREE` and `PRED_TREE` constants.
   - The same 17-path staged-set check against the new tip.
   - A jest step, under the lock, running exactly the narrowed suite set.
   - A new message and PR text.
3. The likely case is S9-A landing first. The predicted must-run set (10 suites that walk `src/` and so read both sides; no import closure spans both) is listed in `analysis/L2-2-DISPOSITION.md` Case B. It is a prediction on pre-format S9-A bytes and must be recomputed on the real S9 head.
4. Any overlap path, conflict, migration, contract, schema or package change is a real dependency change. It means stop, with no composition until it is classified and re-granted.

## 8. Risks and notes

- **Hook environment.** The pre-commit `tsc`, `eslint` and `prettier` need the copied `node_modules` and the prefix. A donor mismatch is refused rather than repinned.
- **Commit sha.** M's sha depends on commit time, so it is known only after compose. `LAND_RECORD` must name that exact M.
- **Composition clone.** The composition clone is a separate standalone clone. The shared `growth-project-backend` clone (a `--no-checkout` blob:none promisor clone) and the S8-F PG-proof clone are never modified.
- **apply_patch.** The apply_patch binary was not available to the preparer, so files were written with the equivalent manual file-write tool, only under `landing/**`. Nothing here is committed. The parent publishes the evidence repo.
- **Public repo.** No private evidence goes into the public repo. The PR body and commit message contain only shas, paths and landing facts.

## 9. Files

- `land-s8f-1910.sh` is the recipe script (`bash -n` OK).
- `analysis/select_suites.py` is the L2-2 selector, run read-only.
- `analysis/side-*.txt` hold the changed-path lists (S8-F 17, S9-0 1, S9-A 4).
- `analysis/selection-s8f-onto-1c5fbb04.txt` and `analysis/selection-s8f-onto-s9a-preformat.txt` are the raw selector outputs.
- `analysis/L2-2-DISPOSITION.md` is the manual disposition of each hit.
- `run/predict-20260925T212826Z/` and `run/classify-20260925T212846Z/` are the read-only proof runs of the script.
- `SHA256SUMS` covers the files above.
