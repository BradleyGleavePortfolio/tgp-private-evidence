# COMPOSE_RESULT-S9A-2: grant LAND-S9A-COMPOSE-2 STOPPED after a green Jest run, at the untracked-file check (rc 79). No commit was made.

Tier T3, nonproduction. The run used `land-s9a-1910.sh` with sha256 `21f1ed8cc04b23bd0fa18e0a1f849676aaf1476548a88a2ccccd86187384eb2b` (CORRECTION-S9A-1 installed).

## Sequence
1. **Predict** (`run/s9a-predict-20260925T220749Z`): `PREDICT_OK`, rc 0.
   - integration/importer = land/s8-f = M `62471b11`; main = `1c10e2a1`.
   - merge-tree in both orders gave `737c34a3`.
2. **Launch.** At 22:08:13Z `lslocks` showed 0 holders. The S8-G gate had already released the lock, so no polling was needed. The launch is recorded in `run/s9a-compose-2-launch.txt`.
3. **Compose** (`run/s9a-compose-20260925T220813Z`). The console is in `run/s9a-compose-2-console.out`; `run/s9a-compose-2-terminal.txt` reads `RC=79 2026-09-25T22:09:36Z`.
   - **Lock and remote.** The lock was acquired on fd 9 (inode 667698). Remote: tip M, main 1c10e2a1, 16 land refs, `land/s9-a*` absent.
   - **S9-A and identity.** S9-A was fetched exactly: `be88909f`, tree `54349476`, parent `1c5fbb04`, blobs equal to the gate's post-format receipts. The identity and message checks passed.
   - **CORRECTION-S9A-1 check.** The donor comparison now ran in `$W` and passed. The donor pins matched, `node_modules` was copied (`cp -a`), and `lefthook install` ran.
   - **Hooks.** Lefthook is 2.1.9.
     - Raw hashes: own pre-commit `03b0b881…`, commit-msg `2789409b…`; reference pre-commit `e21bece6…`, commit-msg `277018c4…`.
     - Normalized hashes: pre-commit `9dcf80f4…` and commit-msg `4ab9b419…`, equal to the reference. `HOOK_OK`.
   - **Prettier.** The 3.9.9 prefix manifest verified OK.
   - **Merge.** `git merge --no-ff --no-commit be88909f` gave `MERGED (uncommitted) tree=737c34a3b50cb823c9317d13e1b23797127338b9`. The staged set was the 4 S9-A paths, and the contract blob was unchanged.
   - **Jest** (the 7 must-run suites, `--ci --runInBand --runTestsByPath`, run once): rc 0. `Test Suites: 7 passed, 7 total; Tests: 1 skipped, 385 passed, 386 total; Time 42.9 s`. The suites were:
     - env-discovery
     - deploy-readiness
     - reconcile.spec
     - dunning-v2-lockout-allowlist-route-table
     - mapping-spec.third-source
     - operator-keys-artifact
     - route-doc-drift
     
     The raw output is in `jest-affected.raw.log`. After the run the worktree was still identical to the index, and the index tree was still `737c34a3`.
   - **FAILURE.** Line 287 (`refuse 79 "suites left untracked files: A src/scout/reconciliation/… (4 paths)"`) filtered `git status --porcelain --untracked-files=all` only with `grep -v '^?? node_modules/'`. It therefore counted the 4 expected staged merge adds (`A `) as leftovers.
     - This is a script defect. The actual count of untracked, non-node_modules files is 0, verified afterwards. There are also no ignored files outside node_modules.
     - Per the stop rule, there was no retry.

## State preserved
- **Clone `/home/user/workspace/worktrees/1910a060-land-s9a-2`:**
  - HEAD = M `62471b11`, MERGE_HEAD = `be88909f`, index tree = `737c34a3`;
  - the worktree equals the index, the merge is uncommitted, and the hooks are installed.
  
  Nothing was aborted or deleted.
- **First clone** `1910a060-land-s9a`: untouched.
- **Donor clone** `1910a060-s8f`: unchanged.
- **Not written:** there is no `state/compose-s9a.env`. No commit was made (no M2) and nothing was pushed.
- **Lock:** released when the run exited at 22:09:36Z; `lslocks` shows no holder. The lock file is preserved.

## Proposed CORRECTION-S9A-2 (NOT applied; needs a parent grant)
The diff is in `analysis/CORRECTION-S9A-2.proposed.diff`. The full proposed script is `analysis/land-s9a-1910.CORRECTION-S9A-2.proposed.sh`, sha256 `15a7799f4fedd70cd356693c6d55d4fbc00b041ac7abd1d1a7d04ad2f968a252`, and passes `bash -n`.

It makes two changes:
1. **Line 287:** the untracked check now uses `git status --porcelain --untracked-files=all | grep '^??' | grep -v '^?? node_modules/'`, so it looks only at genuinely untracked entries. Run against the current `-2` state, this check passes.
2. **`W`:** changed to `/home/user/workspace/worktrees/1910a060-land-s9a-3`, because the one-shot guard refuses an existing path. Clones `-1` and `-2` stay preserved.

Nothing else changes.

## Pre-audit of the remaining compose steps
These were checked statically or simulated against the `-2` state:
- **Commit message:** the rendered message is clean against BANNED_RE.
- **Hygiene over `M..M2`:** the range covers 2 commits, M2 and be88909f. Both are Bradley's, and the be88909f check already passed.
- **Parents:** checked as `(M, be88909f)`.
- **Bundle and receipts:** the bundle spans `M..land1910/s9a`, and the receipt and SHA256SUMS glob is the same pattern that worked in S8-F.
- **Hooks:** the pre-commit hooks will run on the 4 staged files. These are the same post-format bytes that passed the S9-A gate's genuine hooks.
- **Jest:** the must-run Jest step would run a second time on a fresh `-3` clone, taking about 45 s.
