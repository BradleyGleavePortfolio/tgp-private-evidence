# RECIPE-S9A: land S9-A (be88909f) onto integration/importer at M (62471b11)

- **Tier:** T3, nonproduction landing preparation for EXEC-1910A060, task LAND-PREP-S9A.
- **Status:** PREPARED. Only `predict` and `classify` (both read-only) have been run. `compose`, `stage` and `ff` each need their own parent grant.
- **Script:** `landing/land-s9a-1910.sh`, sha256 `bbcdef58c2fc6da971f50143e6bb54ad1ff592ccf8202fab129d7d93c61c4b6e`.
  - It is derived from `land-s8f-1910.sh` (sha256 `2adc7e10…`). It keeps the CORRECTION-1 path-normalized hook check and the helper bodies unchanged.
  - Commit 06da57d contains an earlier snapshot of this script. It differs only in 2 comment lines, which name the disposition file.

## Inputs (pinned in the script)
| Item | Value |
|---|---|
| Frontier M (integration/importer) | `62471b116267fdec6746073c4b4c80a154d09834`, tree `23614f0b…`. Verified live 2026-09-25T22:01Z (S8-F ff done, PR #542 MERGED). |
| main | `1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47`. Never written. |
| S9-A accepted | `be88909f4bf6a727a3bd376385aba91f209f989a`, tree `54349476…`, parent `1c5fbb04`. `s9a/S9A_ACCEPTANCE.md` gives verdict ACCEPT. |
| S9-A object source | `/home/user/workspace/worktrees/1910a060-s9a` branch `exec1910/s9a` (read-only). Blobs are cross-checked against `s9a/gate/postformat-*.ts`. |
| merge-base | `1c5fbb0441178e0cfe6e9f8d72e955c645c265e9` |
| Predicted tree | `737c34a3b50cb823c9317d13e1b23797127338b9` |
| S9-A paths (4) | `src/scout/reconciliation/{coverage,reconcile,types}.ts` and `test/scout/reconciliation/reconcile.spec.ts`. Blobs f50d9401 / bcc85e49 / b7599427 / 11f2a524. |
| Contract blob | `docs/contracts/importer-openapi.json` = 8ebf936a. Unchanged by S9-A. |
| Donor runtime | `1910a060-s8f` (HEAD e1ec2fec; schema and lockfile identical to M). Pins relayed at grant: NM 05bc530a…, dts 9042e713…, schema b8439203…. |
| Hook reference | `HOOK_REF_ROOT=1910a060-s8f`, lefthook 2.1.9, path-normalized comparison (CORRECTION-1). |
| Composition clone | `/home/user/workspace/worktrees/1910a060-land-s9a` (currently absent), branch `land1910/s9a`. |
| Branch names | `land/s9-a-accepted` = be88909f and `land/s9-a` = M2. Both are currently absent on the remote. |

## Prediction result: run/s9a-predict-20260925T220133Z, `PREDICT_OK`, rc 0
- The live remote shows integration/importer and land/s8-f both at M, and main at 1c10e2a1.
- `git merge-tree --write-tree` gave `737c34a3…` with rc 0 in both orders (M,S9-A and S9-A,M).
- `diff --raw M T` == `diff --raw 1c5fbb04 be88909f`: exactly the 4 S9-A adds, byte-identical.
- `diff --raw be88909f T` == `diff --raw 1c5fbb04 M`: exactly the 17 S8-F paths.
- 0 overlapping paths. The contract blob is unchanged.
- `classify be88909f` (run/s9a-classify-20260925T220153Z) exits 79 by design. It confirms the same tree, overlap 0, and a conservative selection of 41 suites in both directions.

## L2-2 result (analysis/L2-2-DISPOSITION-S9A.md)
The selection was recomputed on the real tree T, with the real 17 S8-F paths as side X and the real 4 S9-A paths as side Y. Both directions select the same 41 suites. Each hit was then dispositioned by hand.
- **Import closures are disjoint.** S9-A imports only `lifecycle/{arbiter,reason-codes}` and `scout.dto`, none of which S8-F changed. Nothing imports `reconciliation/*`, and S9-A has no module wiring.
- **Must-run, 5 real-repo `src/` walkers that read bytes from both sides:**
  - `test/deploy-readiness.spec.ts`
  - `test/prod-readiness/env-discovery.spec.ts`
  - `test/prod-readiness/operator-keys-artifact.spec.ts`
  - `test/route-doc-drift.spec.ts`
  - `test/scout/reconstruct/mapping-spec.third-source.spec.ts`
- **Conservative adds, 2:**
  - `test/scout/reconciliation/reconcile.spec.ts`
  - `test/dunning-v2-lockout-allowlist-route-table.spec.ts`
- **Excluded, 34:** these read named files, temp repos, fixtures or mocks, or are PG helpers reading a single migration file. Their inputs are identical in M and T.
- The list is in `analysis/s9a-must-run-suites.txt` and equals `SUITES` in the script.

## Prerequisites for compose
1. **Integration tip == M.** This already holds. The script refuses with exit 79 otherwise, and main must equal 1c10e2a1.
2. **S9-A acceptance record** (`s9a/S9A_ACCEPTANCE.md`) names be88909f.
3. **Parent grant plus the canonical lock.** The lock file is `/home/user/workspace/execution/test-validation.lock`, inode 667698. It is taken with `flock -n` and is never created or stolen. No other heavy process may run.
4. **Relayed donor pins** as environment variables. The donor clone is unchanged at e1ec2fec.
5. **Clone path and state file are absent:** `1910a060-land-s9a` and `state/compose-s9a.env` must not exist, and `land/s9-a*` must not exist on the remote.

## Steps
1. **Predict (read-only):**
   ```
   bash land-s9a-1910.sh predict
   ```
   This must print `PREDICT_OK`. If the frontier has moved, it exits 79; then run `classify <sha>` and let the parent disposition. Do not replay.
2. **Compose (granted, under the lock, one shot):**
   ```
   COMPOSE_GRANT=1 DONOR_NM_LOCK_SHA=05bc530a… DONOR_CLIENT_DTS_SHA=9042e713… DONOR_CLIENT_SCHEMA_SHA=b8439203… timeout -k 30 3600 bash land-s9a-1910.sh compose
   ```
   It does the following, in order:
   - Creates a fresh clone, fetches integration/importer (must be M), and fetches the exact S9-A with blob and receipt checks and hygiene checks.
   - Runs `cp -a node_modules` from the donor (no install), runs lefthook install, and checks the normalized hooks.
   - Verifies the prettier 3.9.9 prefix.
   - Runs `git merge --no-ff --no-commit` of be88909f. It then checks that write-tree == 737c34a3, the staged set == the 4 paths, and the worktree == the index.
   - Runs `jest --ci --runInBand --runTestsByPath <7 suites>` once, with no PG. Afterwards the worktree must be clean and the tree still 737c34a3, with no stray untracked files.
   - Makes one genuine hooked commit as Bradley, author and committer, with no trailers. The message is pre-scanned against BANNED_RE.
   - Checks that the parents are (M, be88909f) and the tree is 737c34a3.
   - Writes the bundle M..land1910/s9a, `COMPOSE_RECEIPT.txt` and `state/compose-s9a.env`.
   Nothing is pushed.
3. **Stage (parent):**
   ```
   STAGE_GRANT=1 bash land-s9a-1910.sh stage
   ```
   This pushes `land/s9-a-accepted` = be88909f and `land/s9-a` = M2, using ordinary absent-or-equal pushes. It then opens one PR from land/s9-a with base integration/importer.
4. **FF (parent):**
   ```
   FF_GRANT=1 ACCEPT_RECORD=…/s9a/S9A_ACCEPTANCE.md LAND_RECORD=<record naming M2> bash land-s9a-1910.sh ff
   ```
   It checks, in order:
   - the tip is still M;
   - land/s9-a == M2;
   - PR CI is observed once as green: the 7 required checks are pass, and all others are pass or skipping.
   
   It then does an ordinary FF push to integration/importer and verifies it with ls-remote. main is not touched.

## Stop rules and risks
- The first failure stops the run with state preserved. There is no retry, abort, reset, force, `--no-verify` or amend.
- **FRONTIER_MOVED (exit 79):** classify the exact changed dependency and do not replay.
- **Tree drift:** if the hooks or prettier rewrite any byte, the committed tree differs from 737c34a3 and compose exits 80. The 4 S9-A files are already post-format bytes that passed the S9-A gate's hooks.
- **Must-run Jest failure (exit 79):** this would be a real S8-F×S9-A interaction, most likely in the stub, env or provider scanners or the operator-keys artifact. The parent dispositions it. There is no product edit in this recipe.
- **Operator-keys artifact:** `operator-keys-artifact.spec` checks `OPERATOR_KEYS_NEEDED.md` for drift against the provider scan. S9-A imports no provider SDK and reads no env vars (pure functions). Drift is therefore not expected, but only the compose run proves it.
- **Unmodelled side effects:** a suite that writes a gitignored file would not be detected. Tracked and untracked (non-ignored) changes are refused.
- **Private evidence:** none enters the public repo. The commit message and PR body are factual and scanned.
