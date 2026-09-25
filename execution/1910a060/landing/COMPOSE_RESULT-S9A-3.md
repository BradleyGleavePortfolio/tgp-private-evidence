# COMPOSE_RESULT-S9A-3: grant LAND-S9A-COMPOSE-3, rc 0, M2 = 9497ca5275938c9228c6ec6fa0dfa8c34f39f724

Tier T3, nonproduction. The run used `land-s9a-1910.sh` with sha256 `15a7799f4fedd70cd356693c6d55d4fbc00b041ac7abd1d1a7d04ad2f968a252` (CORRECTION-S9A-1 and CORRECTION-S9A-2 installed). The static trace done before launch is in `CORRECTION-S9A-2.md`. Nothing was pushed, and stage and ff were not run.

## Sequence
1. **Predict** (`run/s9a-predict-20260925T221411Z`): `PREDICT_OK`, rc 0.
   - Tip = land/s8-f = M `62471b11`; main = `1c10e2a1`.
   - merge-tree in both orders gave `737c34a3`.
2. **Lock wait.** The poll log is `run/s9a-lock-poll-3.txt`; the poller script is `run/s9a-poll-launch-3.sh`, which checks `lslocks` every 60 s.
   - First holder: pid 18819 (S8-G dev loop), free at 22:14:05Z.
   - At 22:14:43Z the lock was retaken by pid 20683 (`s8g/gate/dev-loop/hold-slot-2.sh`), and from 22:16:03Z it was held by pid 21509 (`s8g-gate-1910-a4.sh`).
   - It was free at 22:28:04Z, and the poller launched immediately. The script's own `flock -n` acquired the lock. Nothing was stolen.
3. **Compose** (`run/s9a-compose-20260925T222804Z`, 22:28:04Z to 22:30:29Z). `run/s9a-compose-3-terminal.txt` reads `RC=0 2026-09-25T22:30:29Z`.
   - **Lock and remote.** Lock fd 9 on inode 667698. Remote: tip M, main 1c10e2a1, `land/s9-a*` absent.
   - **S9-A and identity.** S9-A was fetched exactly: `be88909f`, tree `54349476`, parent `1c5fbb04`, blobs equal to the gate's post-format receipts. The identity and message checks passed for `1c5fbb04..be88909f`.
   - **Runtime.** The donor check ran in `$W` (CORRECTION-S9A-1) and passed. The donor pins matched and `node_modules` was copied (`cp -a`).
   - **Hooks.** lefthook 2.1.9.
     - Raw hashes: pre-commit `0a485c15…`, commit-msg `c04a0b73…`.
     - Normalized: pre-commit `9dcf80f4…` and commit-msg `4ab9b419…`, equal to the reference (`HOOK_OK`). The hooks reference `1910a060-land-s9a-3/node_modules/lefthook-linux-x64/bin/lefthook`.
   - **Prettier.** The 3.9.9 prefix verified OK.
   - **Merge.** `git merge --no-ff --no-commit be88909f` gave tree `737c34a3`. The staged set was the 4 S9-A paths, and the contract blob was unchanged.
   - **Jest** (7 suites, `--ci --runInBand --runTestsByPath`, run once, 22:28:57Z to 22:29:42Z): rc 0. `Test Suites: 7 passed, 7 total; Tests: 1 skipped, 385 passed, 386 total`. After the run the worktree equaled the index and the tree was still `737c34a3`. The corrected untracked check found nothing.
   - **Hooked commit.** The raw hook output is in `commit.raw.log`.
     - pre-commit, done in 45.73 s:

       | Hook | Result |
       |---|---|
       | prod-readiness-quick | ✔ |
       | banned-cast-tokens | ✔ |
       | prettier | ✔ |
       | eslint | ✔ |
       | tsc | ✔ (45.72 s) |

     - commit-msg: no-ai-tokens ✔.
   - **Post-commit checks.**
     - Parents are `62471b11… be88909f…`, exactly (M, S9-A).
     - The committed tree is `737c34a3b50cb823c9317d13e1b23797127338b9`, which is the prediction.
     - Hygiene passed for `62471b11..9497ca52`, 2 commits.
     - The worktree is clean.
   - **Export.** The bundle `land-s9a-9497ca527593.bundle` covers `M..land1910/s9a` and verifies OK. `name-status-vs-tip.txt` lists exactly the 4 `A` paths.

## Result
| Field | Value |
|---|---|
| M2 | `9497ca5275938c9228c6ec6fa0dfa8c34f39f724` |
| Tree | `737c34a3b50cb823c9317d13e1b23797127338b9` |
| Parents | `62471b116267fdec6746073c4b4c80a154d09834`, `be88909f4bf6a727a3bd376385aba91f209f989a` |
| Author / committer | Bradley Gleave <bradley@bradleytgpcoaching.com> / same, 2026-09-25T22:29:42Z. No trailers. |
| Subject | `Merge S9-A reconciler (be88909f) into integration/importer` |
| Clone | `/home/user/workspace/worktrees/1910a060-land-s9a-3`, branch `land1910/s9a` = M2, clean |
| Receipt | `run/s9a-compose-20260925T222804Z/export/COMPOSE_RECEIPT.txt`, sha256 `0737c5b4d40200a6967d01b1606a57e32832023ec334d5285419e75b97871008` |
| Bundle | `export/land-s9a-9497ca527593.bundle`, sha256 `f70e65e69077e02bf7e2776ed1214c5595967dbe90173fb50491ffa8a4efea60` |
| State | `state/compose-s9a.env` (MERGE=9497ca52…, WT=…-land-s9a-3) |

## Lock and preservation
- **Lock:** released when the script exited at 22:30:29Z; `lslocks` then showed no holder. The lock file is preserved. The poller has exited.
- **Remote, after the run:** integration/importer = M `62471b11`, main = `1c10e2a1`, and `land/s9-a*` absent. Nothing was pushed.
- **Clone `-1`:** HEAD M, no merge in progress. Untouched.
- **Clone `-2`:** HEAD M with MERGE_HEAD be88909f. Untouched.
- **Donor `1910a060-s8f`:** e1ec2fec with 0 tracked changes.
- **Next (parent):** `STAGE_GRANT=1 bash land-s9a-1910.sh stage`, which pushes land/s9-a-accepted = be88909f and land/s9-a = 9497ca52 and opens one PR. After that, run `ff` with `ACCEPT_RECORD` naming be88909f and `LAND_RECORD` naming 9497ca52, once CI is green.
