# PROOF-RT lane runners + baseline qualification (EXEC-42D8C5B5, T3 runtime executor)

Result: both runners qualified on baseline 54be96f18c314cae35d1e5d3000af9f06d693d81 (tree 435fec78). **S11 lane RC=0, 127/127.
S10-B lane RC=0, 41/41.** No product code was edited. No other worker's clone was touched. The donor was only read (its
prisma tree signature matched before and after each run). The evidence repo was not committed.

## Runners (qualified bytes)
| runner | sha256 |
|---|---|
| `proof/lane-s11.sh` | `e9470a92f1f9a35c0f0be765cd7d6f6dc2a0d16857396dc48662fb09e7a61a9f` |
| `proof/lane-s10b.sh` | `ec15b4d08a7ed10c21edf1938c7e8d8d5f12bbef50006d8bcbff0f649e01a6e2` |

Each runner is self-contained: a lane header, then a common body that is byte-identical in both. The build parts are in
`proof/.build/{lane-s11.head,lane-s10b.head,common.body}` and the file is `cat head body`. The baseline launcher is
`.build/launch-baseline.sh` and its output is `.build/launch-baseline.out`.

## Usage
```
nohup setsid /home/user/workspace/repos/tgp-private-evidence/execution/42d8c5b5/proof/lane-s11.sh  <HEAD_SHA> <RUN_DIR> [--stages a,b] >/dev/null 2>&1 &
nohup setsid /home/user/workspace/repos/tgp-private-evidence/execution/42d8c5b5/proof/lane-s10b.sh <HEAD_SHA> <RUN_DIR> [--stages a,b] >/dev/null 2>&1 &
```
- `RUN_DIR` must be an absolute path that does not exist yet. The runner creates it with `mkdir`, so if it exists the runner
  refuses with rc 76. Its parent directory must already exist. Poll `RUN_DIR/RESULT` for the outcome.
- S11 stages: `bootstrap, rls-g2-s11, journey-core, readiness, settle-redrive, journey-induction, journey-full, guard`.
  - `journey-full` runs only if the spec exists at HEAD. When it is absent, RESULT records `SKIP_ABSENT_AT_HEAD`.
  - If you name `journey-full` in `--stages` and it is absent, that is a FAIL.
- S10-B stages: `bootstrap, rls-s10b-s10c, s10-unseen`.
  - `rls-s10b-s10c` is one jest run of both files through jest.rls.config.js (the S11-B s10b-lane v2 command).
  - `s10-unseen` uses jest.config.js (the D2 v2 command).
- Any live stage adds `bootstrap` automatically. A `--stages guard` run needs no PG.
- Environment knobs:
  - `LANE_LOCK_WAIT`: `flock -w` wait, default 3600 s.
  - `LANE_OUTER_TIMEOUT`: watchdog, default s11 18000 s and s10b 6000 s.
  - `LANE_KEEP_SCRATCH=1`: keep the clone source, but still remove pg-data and node_modules.
- Exit codes:
  - 0: pass
  - 64: usage
  - 70: precondition failed or refused (including a package-lock mismatch with the donor)
  - 71: clone or deps
  - 72: jest count or skip check
  - 73: DB identity
  - 74: teardown or post check
  - 75: lock
  - 76: run dir exists
  - 124: timeout or signal
  - any other value: the stage command's own rc

## What is bound (RUN_DIR/RESULT)
RESULT records:
- RC, the failing stage (or `done`), HEAD, tree, and the package-lock sha256 at HEAD next to the donor's
- migration dirs at HEAD, applied migrations, and the last migration
- the generated client index.d.ts sha256, runner path, runner sha256 and port
- one `STAGE_RESULT` line per stage: status, passed, failed, skipped, todo, total, expected, suites, rc and seconds (parsed from
  the jest summary)
- the TOTAL line, start/end/duration, teardown state and lock inode

The binding is HEAD + tree + runner sha256. There are no per-blob pin tables. `RECEIPTS.sha256` covers every file in RUN_DIR.

Mechanics, all enforced inside the runner:
1. Refuse unless `runtime/raw/rt-setup.sentinel` says RC=0.
2. HEAD must already exist in `repos/backend`.
3. The canonical lock (inode 657581) is taken with `flock -w` on fd 9 and held for the whole run. `STARTED` is created O_EXCL.
4. Fresh clone: `git clone --no-hardlinks --no-checkout` of the backend, then a detached checkout of HEAD. Push is disabled and
   hooks are off. It goes under `/home/user/workspace/execution/42d8c5b5/proof-scratch/<lane>-<run>-<pid>/`.
5. The package-lock sha256 at HEAD must equal the donor's. The donor's `node_modules` is copied with `cp -a` (a real copy), and
   `prisma generate` runs in the clone only.
6. A fresh PG 17.6 cluster starts on the first free port in 55650–55699 that the lane's `db.ts` at HEAD does not refuse. The
   DB, role and markers are read from the harness at HEAD.
7. Bootstrap, then an identity check: data_directory, 170006, cluster_name, DB marker, and applied migrations must equal the
   migration dirs at HEAD, with the last one matching.
8. Each stage command runs with setsid, its own hard `timeout -k 30 <bound>`, and fd 9 closed. The whole run has a watchdog
   (`timeout -k 180`).
9. A stage passes only if all of these hold:
   - rc is 0
   - 0 failed, 0 skipped and 0 todo
   - passed equals total
   - every suite passed, and the suite count equals the number of spec files
   - there is a PASS line for each file
   - total equals the static `it(` count at HEAD. The count is only a lower bound when the file uses `it.each`/`test(` (the
     guard file: its static count is 11, and RESULT records 95).
10. The runner stops at the first failure and never retries.
11. The guard stage runs with every `G2_*` variable unset.
12. Teardown always runs from the EXIT trap, including after TERM/INT/HUP. It stops PG (fast, then immediate, then KILL),
    copies pg.log, and removes the scratch dir. A teardown failure turns the RC into 74.

## Baseline results (54be96f1)
| lane | run dir | RC | stages (passed/total, secs) | wall |
|---|---|---|---|---|
| S11 | `proof/baseline-s11` | 0 | bootstrap 5 s (173/173 migrations); rls-g2-s11 6/6 64 s; journey-core 8/8 192 s; readiness 6/6 80 s; settle-redrive 8/8 239 s; journey-induction 4/4 88 s; journey-full SKIP_ABSENT_AT_HEAD; guard 95/95 10 s. **127/127**, 0 skipped | 986 s, including a 131 s lock wait and a 158 s node_modules copy |
| S10-B | `proof/baseline-s10b` | 0 | bootstrap 5 s (173/173); rls-s10b-s10c 32/32 (2 suites) 222 s; s10-unseen 9/9 16 s. **41/41**, 0 skipped | 461 s, including a 167 s lock wait |

Both runs used port 55650 and generated client index.d.ts `2c819c8a…aa56c`. Package-lock `b7fed5ed…9c55` matched the donor.
Teardown in both: `postmaster_alive=no port_listeners=0 scratch=removed`. After both runs, `pgrep -cx postgres` returned 0 and
proof-scratch was empty.

These results match the precedents:
- s11a2 v2: 127/127 at 54be96f1.
- s11b s10b-lane v2: 32/32.
- s10d2 v2: 9/9.

## Runtime/runner findings
- **C: an unplanned live run, which I aborted.** I meant to run a negative test before the sentinel existed. The sentinel had
  already turned RC=0 at 17:17:19Z, so `lane-s11.sh 54be96f1 /tmp/t1-6466` became a real run.
  - The runner bytes at that point had sha256 b30d089e…. They differ from the qualified bytes only in not recording an
    ABORTED stage line.
  - It held the lock from 17:20 to 17:30. bootstrap and rls passed (6/6).
  - I sent TERM to its watchdog during journey-core. It ended RC=124, the postmaster was stopped and the scratch dir removed
    within 14 s.
  - It does not count as a qualification run. It is evidence that signal-path teardown works. Its run dir `/tmp/t1-6466` is
    outside the evidence repo and was left in place.
- **C: RECEIPTS.sha256 and runner.log.** The runner writes the final `END rc=… stage=…` line to runner.log after it computes
  RECEIPTS. As a result, `sha256sum -c` reports runner.log FAILED.
  - Every other file verifies.
  - `head -n -1 runner.log | sha256sum` equals the receipt in both baseline dirs.
  - Fix, next revision: log END before `write_result`. I did not apply it, so the qualified bytes stay the ones that ran.
- C: the node_modules copy (`cp -a`, about 700 MB) took between 30 s and 158 s, depending on disk contention from other workers.
- C: other workers' `flock -w` jobs run between lane runs. The lock wait is logged (`LOCK_HELD … waited_s=`).
- C: the guard stage count is checked only as a lower bound (static `it(` count 11, because it uses `it.each`). RESULT records
  the exact 95. Compare that number when you accept a result.
- C: these runners depart from the precedent bindings in the following ways. All of them passed on the baseline.
  - They run every stage with `--runTestsByPath`.
  - The S10-B lane runs `rls-s10b-s10c` and `s10-unseen` on one cluster with one bootstrap. D2 used its own cluster.
  - They use `NODE_OPTIONS=--max-old-space-size=3072`, per WORKER_RULES. The precedents used 4096.
  - The port is dynamic (55650+). The harness accepts any port it does not refuse.
- C, product literal, not a runner issue: the lane bootstraps pin `EXPECTED_MIGRATIONS=173`. A candidate that adds a migration
  must update them, and the runner separately checks that applied migrations equal the migration dirs at HEAD.
- C, runtime: the header comment in `rt-setup-42d8c5b5.sh` says the lock inode is 686480, but the script checks 657581, which
  is correct.
- No A or B findings.
