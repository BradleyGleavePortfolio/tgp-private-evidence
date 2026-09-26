# S11-A2 real-PG proof binding v1 (EXEC-FA72EFB2) — SOURCE ONLY, NOT RUN

Built by the T3 binding builder under `s11a2/S11A2_BINDING_BUILD_GRANT.md`. Nothing was run: no runner, fixture, jest, bootstrap,
PostgreSQL or lock. Every pin was re-derived read-only (`git rev-parse` / `git diff` / `git show | sha256sum` / `sha256sum` / `ls`)
in `/home/user/workspace/worktrees/fa72-s11a2` (GIT_OPTIONAL_LOCKS=0) and the fa72efb2 runtime, at about 17:55Z.

## Provenance
- Template: `s11b/binding/s11-lane-v2/s11-pg-proof.sh` (sha256 2e683690880f0e1c25dfd21b390ef3fa8b76bd8fadc06695f044e569c0ee1327;
  independent T3 GO; ran RC=0 17:32:47Z, 122/122: rls 59 s, journey 180 s, readiness 76 s, redrive 226 s, guard 10 s).
- Built by `.build-s11a2-v1.py <FREEZE-s11a2 sha>`: 38 exact runner substitutions + 2 launcher substitutions, each asserted to match
  exactly once, plus an assertion that no `R1_HEAD=` / `$R1_HEAD` / `$R1R2_DELTA` survives. Full delta: `DELTA-from-s11b-v2.diff`
  (runner 411 -> 440 lines; launcher; FREEZE; fixture = no diff). `bash -n` rc 0 on runner, fixture, launcher.
- `s11-fixture.sh` is a byte copy of v2 (`cmp` identical, sha256 777e6ac3…1636), so `EXPECT_FIXTURE_SHA` is unchanged; the runner
  filename `s11-pg-proof.sh` is kept (the fixture checks for it in the runner cmdline).
- A read-only replay of the new/changed pre-lock checks (pin block extracted up to before `mkdir`, sourced in a subshell, only
  `git` reads + `sha256sum`) returned OK for: head/tree, one-commit chain, base tree, land ref, HARNESS_BASE..BASE utils = 6 A1 utils,
  delta = 12, FREEZE-v3 file + 4 kept lines, FREEZE-s11c 7/7, FREEZE-s11b 6/6 (own path list), FREEZE-s11a2 12/12 (== delta),
  no src/prisma/manifest change, test/utils change = 4 A2 utils, all 18 blob pins, W absent, lane absent, socket dir empty, fixture sha.
  This was a check of the pins only. The runner itself was not executed.

## Changed pins (everything else is s11-lane v2 verbatim)
| pin | s11-lane v2 | s11a2 v1 (verified at fa72-s11a2) |
|---|---|---|
| D | s11b/binding/s11-lane-v2 | s11a2/binding/v1 |
| SRC | worktrees/fa72-s11b (fa72/s11b-r2) | worktrees/fa72-s11a2 (branch fa72/s11a2, clean, no MERGE_HEAD, hooksPath unset, lefthook hooks 30eef29f… / 3f86eafa…) |
| W | worktrees/fa72-s11b-pg3 | worktrees/fa72-s11a2-pg1 (absent) |
| BASE_HEAD / BASE_TREE | 275e458c / 6267ef6a | dda794d7e8bee0482a7ad373795fcc51dcf54bb5 / 802e1c196c7a0bd27f091218407f5f0b031dd760 |
| EXPECT_HEAD / EXPECT_TREE | dda794d7 / 802e1c19 | 03e7a2344ef95b019c751983527bbc9f78200921 / 738b711610a570357136ad8e8eb1be176d406c51 (author+committer Bradley Gleave) |
| chain | HEAD^ = R1_HEAD, HEAD^^ = BASE, count 2, r1->r2 diff check | HEAD^ = BASE, `rev-list --count BASE..HEAD` = 1 (pre-lock and fresh clone); R1_HEAD / R1R2_DELTA removed |
| LAND_REF | origin/land/s11b-r2 | refs/remotes/origin/land/s11a2 = 03e7a234 |
| EXPECT_DELTA | 6 S11-B paths | the 12 A2 paths (8 A, 4 M, all 100644) == `git diff --name-only BASE HEAD` |
| FREEZE-s11a2 (new) | — | own-dir `FREEZE-s11a2.sha256` a73f921125e64a0a21df765c0f9c439f19066ef74bc78b471af3b55552481b59 (12 lines, paths == delta, each checked at HEAD, re-checked under lock) |
| FREEZE-v3 | 8/8 byte-equal | file/sha e6e3a15a… and its 8-path list unchanged; the 4 lines in `A2_A1_EDITS` (guard spec, harness, pg-harness, worker) are skipped; the other 4 (rls spec, journey-core, bootstrap, db.ts) must be byte-equal (verified) |
| FREEZE-s11b | == delta | same file/sha 603ffa02…; paths compared to the new literal `S11B_FILES` (6), 6/6 byte-equal at HEAD (verified) |
| FREEZE-s11c | 7/7 | unchanged, 7/7 byte-equal at HEAD (verified) |
| BASE..HEAD scope | no prisma/manifests/test/utils | no src/prisma/package.json/package-lock.json change (0 files); test/utils change == exactly the 4 A2 utils |
| EXPECT_GUARD_BLOB | e1ace171 | 3975aab13e40ebd43d38c1b772ae54718ceb9d41 |
| EXPECT_HARNESS_BLOB | 240a4969 | 1b66137a3a59b3bf396660cbc5606f4de444831e |
| EXPECT_PGH_BLOB | 2cb6e79a | ad32b5693390228bba001184acc2145b898879ac |
| EXPECT_WORKER_BLOB | d1504f6a | 562038a1127f82ec5eb285010f8d8eade4cb2c8e |
| EXPECT_INDUCTION_BLOB (new) | — | 1b9832bcbce7a51da6a58df60c312a5b0416f144 (test/scout/s11/journey-induction.pg.spec.ts) |
| induction spec bytes (new) | — | live switch `const live = process.env.G2_S11_DATABASE_URL ? describe : describe.skip;` (L52), no skip/only/todo/each, `^\s*it\(` = 4 (L157 J09, L316 J10, L437 J11(a), L477 J11(b)), `jest.setTimeout(600000)` |
| EXPECT_TESTS_GUARD | 94 | 95 (11 `it` + it.each 61 + 20 + 3; A2 hunks start at L297, the it.each tables at L25-127 are untouched) |
| new stage | — | `jest --runInBand --ci test/scout/s11/journey-induction.pg.spec.ts`, default config, `jest-induction.log` (JLOG6, in RECEIPTS), `jcheck` count parse "Tests: 4 passed, 4 total", stop-first-failure, bound `timeout -k 30 3000` |
| outer bound | 10200 | 13500 (runner Usage line and `launch-when-free.sh`) |
| G2_S11_CANDIDATE_HEAD | =$EXPECT_HEAD | unchanged line, so now 03e7a234 (db.ts L137-151: must equal the runtime root's checked-out HEAD) |

Unchanged pins re-verified at 03e7a234: rls spec a4ba04ee, journey-core 95aee484, bootstrap 0e234b58 (mode 100755), db.ts 3f04f566,
jest.rls 44c96915, jest 769a4146, schema f86c1f5d (sha d6d01f54…), readiness 1afcb07d, S11-C service dfd2e267 / dto 9eb9f3d3, redrive
aac3f7a8, lifecycle a4a79648, scout.service 9afaac48; package-lock b7fed5ed…; migrations tree 7b6fe0ed at BASE and HEAD (173 dirs, last
20270124000000_scout_run_observation_expand); HARNESS_BASE 711c1f8f ancestor of BASE, no prisma/deps change since, test/utils = the 6
A1 utils; harness literals at HEAD (bootstrap BASE_HEAD 711c1f8f / markers / 173 / S10B_MIGRATION; db.ts database/role/marker/base
head, REFUSED_PORTS 55646+55647 present, 55648 absent; pg-harness EXPECTED_MIGRATIONS 173 / S10B_MIGRATION) equal the runner.

## Expected counts (one command each, no retry)
bootstrap (G2_S11_BOOTSTRAP_OK) -> identity -> rls **6** -> journey **8** -> readiness **6** -> settle-redrive **8** -> induction **4**
(J09, J10, J11(a), J11(b)) -> guard **95** (no DB) -> teardown -> post. Total **127 tests / 6 suites**.

## Timeouts
Inner stage bounds (true sum, including checkout 120 which v1/v2 headers omitted): clone 120 + checkout 120 + cp 600 + generate 600
+ init 60 + start 60 + bootstrap 900 + identity 8x15 + rls 1500 + journey 1500 + readiness 900 + redrive 3000 + **induction 3000** +
guard 300 + stop 75 + destroy 75 = **12930 s**; outer **13500 s** (570 s margin; v2 true margin was 270 s).
Induction bound: 4 cases x `jest.setTimeout(600000)` = 2400 s is the hard jest ceiling for the cases; +600 s for jest boot and
beforeAll/afterAll. The spec drives ~38 ts-node worker processes (A2 build report §6: J09 15, J10 11, J11(a) 6, J11(b) 6), each with
the harness's own 90 s kill cap. Realistic expectation, from the v2 run (journey-core 8 cases 180 s, redrive 8 cases 226 s): a few
minutes (roughly 200-500 s). Expected whole-run wall time about 15-20 min (v2 took 12.4 min). A timeout is a failure (rc 124), never a retry.

Usage (parent only, under a separate single-run PG grant): `bash launch-when-free.sh` or
`timeout -k 30 13500 bash /home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11a2/binding/v1/s11-pg-proof.sh`

## Lane decision
Lane `runtime/clusters/s11` (port 55648, socket `run/s11`) is reused: `clusters/s11` is ABSENT (v2 leftovers archived to
`s11b/binding/s11-lane-v2/run/post-teardown`); `run/s11` exists and is empty (preflight allows it). `runtime/clusters` holds s10d2,
s10d2-v2 and (new since the v2 run) s11b-s10b (cluster_name s10b-disposable-pg17, port 55649). All three have no postmaster.pid.
The preflight fingerprints them and does not block on them. `pgrep -cx postgres` = 0 at build time.

## Findings (Safety ROI)
No A findings.
- **B — SRC is a shared worktree.** CLASS: launch precondition. CONCRETE HARM: any HEAD/branch/clean change of fa72-s11a2 before
  launch gives PRECONDITION_FAIL rc 70 pre-lock (run not consumed); after the clone it gives POST rc 74 (run consumed). DECISION BLOCKED:
  launching this binding. MINIMUM CLOSURE: parent keeps fa72-s11a2 at fa72/s11a2 = 03e7a234, clean, until the run ends. EXECUTION
  UNLOCKED: the S11-A2 lane run.
- **B — outer timeout.** CLASS: launch parameter. CONCRETE HARM: a 10200 s outer bound (v2 launcher) can kill bash mid-stage before
  teardown and leave the lane up. DECISION BLOCKED: choosing the launch command. MINIMUM CLOSURE: launch only with 13500 (as
  `launch-when-free.sh` does). EXECUTION UNLOCKED: the run.
- **B — preflight requires zero postgres processes on the host.** CLASS: launch precondition. CONCRETE HARM: if any other lane is
  live, preflight fails with rc 71 after STARTED, and the run is consumed. DECISION BLOCKED: launch timing. MINIMUM CLOSURE: launch
  only when `pgrep -cx postgres` = 0 and the lock is free (the launcher waits for the lock only). EXECUTION UNLOCKED: the run.
- C — the J11 `blocked()` window is 10 s (400 x 25 ms), against a 3-6 s ts-node cold start of the second worker. Under heavy host
  load it could expire. The failure is loud (`expected observed PostgreSQL lock wait`), never a false pass. This is A2 build risk C3.
- C — the live induction expectations are backed by the A2 builder's offline evaluator run and code reading. No live settle has
  run yet (A2 C1). If J09 comes out `partial`, read `identities(report)` in `jest-induction.log` first.
- C — `sort` in the runner is locale-dependent. `EXPECT_DELTA` / FREEZE-s11a2 order is C order (`s11-sources.ts` before
  `s11_second/`). Only C/C.utf8/POSIX locales are installed and LANG/LC_* are unset, so this holds. A different locale would fail
  pre-lock (rc 70, not consumed).
- C — the 3000 s induction bound covers the 4 x 600 s jest case ceiling. Hook time beyond 600 s total is not covered.
- C — after this run, `clusters/s11` will again hold pg.log / pg.log.pg_ctl / pg-data.initdb.log. A later S11-lane binding needs the
  same archive-and-remove step.
- C — the header history comments inherited from v1/v2 (soft sum 9810, "pins from c8ee9005", inode 692282) are history. They are
  never compared. The A2 paragraph states the true sum.
- C — the unit specs in the delta-adjacent files (lifecycle.service.spec.ts, s11b-settle-redrive.spec.ts) are covered only through
  FREEZE-s11b byte-equality, as in v2.
