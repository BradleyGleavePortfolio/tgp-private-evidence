# J3 r5 driver — queued readiness (NOT RUN)

- **Driver:** `run/j3-r5-env-commit-gates.sh`, sha256 `2fe6a00f0dd4540f21821813f31ed76143e11b309f700de5c9ed68f2d416a632` (also in `run/DRIVER.sha256`). `bash -n` passes. The driver has not been executed.
- **Receipts directory:** `run/receipts/` exists and is empty.
- **Lock:** not acquired. A single non-blocking `flock -n` probe in `READINESS_CHECK.txt` found the lock held by B, so nothing was taken.

## Stages (first nonzero stops; no retry, fix or amend)

| Stage | Action | Stop rc |
|---|---|---|
| — | Refuse to run if a prior sentinel exists; take `flock -n` fd 9 on `execution/test-validation.lock` | 75 if busy |
| 0 | Preflight: Node 20.20.1 / npm 10.8.2; HEAD `820dbd04`, branch `ux03-j3-source-selection`; index clean; status is exactly the two ` M` tests; diff sha `48d1c583…`; blobs `92ed52f5` / `a1f65a6b` / `34263aee`; package.json `63e2e2e2…` and lock `840be0b8…`; recovery `hooksPath=/dev/null` present; only `*.sample` hooks, no `.husky`; 0 remotes; no `node_modules`; message is 49 bytes with the exact subject | 70 |
| 1 | One plain `npm ci` under `timeout -k 10 1500`, raw log and status kept. Then check: installed record = `c4d7824b…`; package inputs unchanged; tracked bytes and patch sha unchanged; `node_modules` is not a symlink. Record the gate-binary versions | 71 (raw rc recorded) / 72 |
| 2 | `git config --local --unset core.hooksPath`; confirm the effective value is unset and no non-sample hooks exist; set repo-local Bradley name/email; verify both idents | 73 |
| 3 | `git add` of exactly the two tests; `write-tree` = `823b9700…`; staged set = 2 paths; `git commit -F 23-r5-commit-message.txt` (no bypass or override flags) | 74 |
| 4 | Verify the new commit: tree `823b9700`, single parent `820dbd04`, exact subject with empty body, both idents Bradley, product blob `92ed52f5`, clean tracked state; save the raw commit object | 76 |
| 5 | `tsc --noEmit` (180 s), then ESLint on the two tests (120 s), then Jest on the full two files with `--silent --runInBand` (180 s); kill grace 10 s | 81 / 82 / 83 (raw rc recorded) |
| 6 | Full-history bundle of the branch (no prerequisite), `format-patch`, and the committed diff checked against the patch sha. Runs on pass or on gate failure | — |

- **Always recorded:** the owned-survivor check after each process stage (`99-survivors.txt`) and the sentinel (`driver.sentinel`). The lock is released when the driver exits.
- **Environment:** the only exports are `GIT_OPTIONAL_LOCKS=0` and `GIT_NO_LAZY_FETCH=1`. It sets no npm offline/audit/fund config, so the plain recorded recipe is kept.
- **Not claimed:** no hooks are configured, so no hook execution is claimed.
