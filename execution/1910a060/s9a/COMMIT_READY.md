# S9-A COMMIT_READY (A-NEW-1, EXEC-1910A060) — single authorized gate run RC=0

Run: `gate/s9a-gate-1910.sh` sha256 `ef78b007a1b70e94a6743381fc43cfefc972ade25f4f7065c68ac751773cdb05` (parent pre-relay hook-check correction applied before launch; `gate/RELAY.txt`). Launched once 2026-09-25T21:30:25Z under the canonical lock (inode 667698, `flock -n`, released 21:35:53Z; 0 holders after). `gate/TERMINAL`: `RC=0 STAGE=done END=2026-09-25T21:35:53Z`. Not pushed.

## Candidate

- Commit `be88909f4bf6a727a3bd376385aba91f209f989a`, tree `54349476c9f92296f4595bda45d64a48534c4553`, parent `1c5fbb0441178e0cfe6e9f8d72e955c645c265e9`, branch `exec1910/s9a`, clone `/home/user/workspace/worktrees/1910a060-s9a`.
- Author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, 2026-09-25T21:35:07Z. Message = `gate/commit-message.txt` byte-identical (`gate/committed-message.txt`); no trailers, commit-msg hook passed.
- Delta vs H: exactly 4 added paths (`gate/MANIFEST-name-status-*.txt`, `gate/s9a-*.patch`), 2614 insertions.

| Path | blob | committed sha256 | frozen pre-format sha256 |
| --- | --- | --- | --- |
| src/scout/reconciliation/types.ts | b7599427 | 211b474ac29e6fb04c5dadbf5bca9bf3cb86e8da7fb0256bd111d57f68c77114 | eff1479c… |
| src/scout/reconciliation/coverage.ts | f50d9401 | eca66f334b73ce3eb3c5902a8392829104e38b3cdef49e9a5c00f35e46eaa8e7 | c6b224fa… |
| src/scout/reconciliation/reconcile.ts | bcc85e49 | d16158ad4f2c1c6315fd04ac4ca35c8d3c2f94bf8df1fe3905147ab2583d30ab | 83d7673b… |
| test/scout/reconciliation/reconcile.spec.ts | 11f2a524 | dc084dcefe607a09575bdb23bcca57c5ee665509d89e17c007d471a57a2408ee | 99068057… |

Only prettier 3.9.9 `--write` (repo `.prettierrc.json`) sits between frozen and committed bytes; the `--write` touched exactly the four files (`gate/prettier-write-1.log`), no tracked file changed. Post-format copies: `gate/postformat-*`. Review A's predicted post-format shas match exactly for types.ts and coverage.ts; reconcile.ts and the spec differ from A's prediction because A predicted on the pre-B-1 bytes (efb8f799/5b015fae), so Phase 2 should diff those two files' changed hunk (the B-1 union + R06 row) rather than expect A's numbers.

## Gate receipts (`gate/gate.log` + raw logs)

- Preconditions: HEAD==H, branch, exactly 4 untracked at frozen shas (= `freeze/`), no node_modules, schema 0eb41f9a, package-lock b7fed5ed, S9-0 doc cda68d82, no pre-existing hooks, hooksPath unset.
- node_modules: `cp -a` from read-only donor `worktrees/1910a060-s8f/node_modules` (donor HEAD e1ec2fec; 649 entries; hidden lock 05bc530a; client index.d.ts 9042e713; client schema b8439203 — base-H pins met, no in-lane generate needed), 149 s.
- Hooks: `lefthook install` 2.1.9 into this clone; raw pre-commit 57303fa4 / commit-msg a2ae3de7; path-normalized 9dcf80f4 / 4ab9b419 == reference S8-F clone (raw e21bece6 / 277018c4); hooks reference this clone's `node_modules/lefthook-linux-x64/bin/lefthook`.
- Prettier prefix `/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9`: 56/56 manifest OK, `npx` 3.9.9; check-1 rc1 (4 files), write, check-2 rc0.
- eslint rc0 (`--max-warnings 0`, 4 files). tsc `--noEmit` whole repo rc0, 0 lines.
- jest `--ci` 10 suites: 10 passed; 418 passed, 1 skipped (pre-existing skip outside S9-A), 75 s.
- Commit through genuine lefthook pre-commit (prod-readiness-quick, banned-cast-tokens, prettier, eslint, tsc all ✔, 45 s) and commit-msg (no-ai-tokens ✔).

## Not done / next (parent-owned)

No push, no landing, no acceptance. Phase-2 independent reviews on `be88909f` (changed-hunk vs frozen bytes modulo prettier, receipts, identity). Historical daceddc8 gate.log untouched.
