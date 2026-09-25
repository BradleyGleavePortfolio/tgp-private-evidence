# LAND-S8F-1 compose result (one granted run, 2026-09-25)

The script ran was `land-s8f-1910.sh`, sha256 `2adc7e1054cc660045b32378f328dc72ed4b1618364533581b914df5e3f64dfd` (post CORRECTION-1).

## Predict

The predict run is `run/predict-20260925T214904Z`, which was the prediction in effect for this grant (21:49Z). An earlier read-only predict run, `run/predict-20260925T212826Z`, also exists.

- It returned PREDICT_OK at 21:49:16Z, with rc 0.
- Remote integration/importer was `1c5fbb04` and main was `1c10e2a1`.
- merge-tree gave `23614f0b` in both orders.

## Compose

The compose run is `run/compose-20260925T214925Z`. It ended with `RC=0 END=2026-09-25T21:51:43Z` (`run/compose-terminal.txt`).

**Lock**

- Acquired 21:49:25Z with fd9 `flock -n` on inode 667698.
- Released at exit. `lslocks` shows no holder, and the lock file is preserved with inode 667698.

**Merge M**

- M is `62471b116267fdec6746073c4b4c80a154d09834`.
- Tree is `23614f0b7dc33dc37b90cf4f27fcb8331912e60f`, which equals the prediction.
- Parents are (`1c5fbb0441178e0cfe6e9f8d72e955c645c265e9`, `e1ec2fecb71f315b6721d426ba0dacb84f304498`).
- M − S8-F is exactly `A docs/decisions/2026-09-25-s9-reconciliation.md`. M − tip is 17 paths (the S8-F set).
- Contract blob is `8ebf936a` and doc blob is `c3423725`.

**Identity and message**

- Author and committer are both Bradley Gleave <bradley@bradleytgpcoaching.com>, at 2026-09-25T21:50:52Z.
- There are no trailers.
- HYGIENE passed on `1c5fbb04..62471b11`, which covers 2 commits.

**Hooks** (genuine lefthook 2.1.9, no bypass; `commit.raw.log`)

- pre-commit passed all five checks: prod-readiness-quick, banned-cast-tokens, prettier, eslint and tsc (48.2 s). No check was skipped.
- commit-msg passed no-ai-tokens.
- Raw hook hashes:
  - own clone: pre-commit `013c55ac…`, commit-msg `7f4aada5…`
  - reference clone `1910a060-s8f`: pre-commit `e21bece6…`, commit-msg `277018c4…`
- Normalized hashes are equal for own and reference: pre-commit `9dcf80f4…`, commit-msg `4ab9b419…`.
- The own hooks reference `worktrees/1910a060-land-s8f/node_modules/lefthook-linux-x64/bin/lefthook`.

**Runtime**

- `node_modules` was copied from the donor, with pins 05bc530a / 9042e713 / b8439203 verified.
- Prettier is 3.9.9 from the verified prefix.
- No jest, regen, install, generate or PG was run.
- The worktree is clean after the commit.

**Donor clone**

- `worktrees/1910a060-s8f` is unchanged: HEAD is `e1ec2fec`, it has 0 tracked changes, and its hooks still hash to e21bece6/277018c4.

**Receipts**

- `run/compose-20260925T214925Z/export/`: `COMPOSE_RECEIPT.txt`, `land-s8f-62471b116267.bundle` (`1c5fbb04..land1910/s8f`, verified), `name-status-vs-{tip,s8f}.txt`, `SHA256SUMS` (all OK).
- State file: `landing/state/compose-s8f.env`.

**Not done** (reserved to the parent): stage, ff, any push or PR. No remote writes happened.
