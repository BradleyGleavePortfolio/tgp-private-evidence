# S11-B proof bindings: independent T3 delta review (EXEC-FA72EFB2)

Reviewer: fresh T3 agent (not the builder), working under `s11b/S11B_BINDING_REVIEW_GRANT.md` and `WORKER_RULES.md`.
Mode: read-only. I did not run any runner, fixture, jest, bootstrap, PostgreSQL, npm or lock. I did not take `test-validation.lock`
(I only ran `stat` on it). The only file I edited is this report.
Scope: the delta from the accepted templates only. I did not re-audit unchanged template bytes.

## Verdict
| binding | verdict |
|---|---|
| A — `s11b/binding/s11-lane-v1/` (S11 lane, s11-pg-proof.sh) | **GO** |
| B — `s11b/binding/s10b-lane-v1/` (S10-B lane, s10b-lane-pg-proof.sh) | **GO** |

A/B findings: **none**. The builder's open risk A (a leftover `runtime/clusters/s11` would cause a PRELOCK_REFUSED) is **closed**.
`clusters/s11` is absent, and `s11c/binding/v1/run/post-teardown/` holds pg.log, pg.log.pg_ctl and pg-data.initdb.log.
The builder's risk B (the outer timeout) is closed by the parent launcher `s11-lane-v1/launch-when-free.sh`, which uses `timeout -k 30 10200`.

## Subjects (sha256 verified; `sha256sum -c BINDING.sha256` rc 0 in each binding dir)
- A: s11-pg-proof.sh ef0024b2…ef36a (399 lines), s11-fixture.sh 777e6ac3…1636 (`cmp` = s11c v1 fixture), FREEZE-s11b.sha256 ca321526…24f4,
  DELTA-from-s11c-v1.diff 4a9fb798…a978, README a539c059…6625, .build-s11-lane-runner.py d35ce45c…2c1f, BINDING.sha256 4a52c541…3fbb.
- B: s10b-lane-pg-proof.sh 2a5c5d19…2a3b (421 lines), s10b-lane-fixture.sh 2fc8012d…a5db2a, FREEZE-s11b.sha256 ca321526…24f4,
  DELTA-from-d2-v1.diff 5de16b47…f318, DELTA-fixture-from-d2.diff fbc45929…b6f6, README 5cb3f4ea…e447, .build-s10b-lane.py f9ff9a9a…8bf8c,
  BINDING.sha256 31f9a7e5…17d0.
- Templates: s11c v1 BINDING rc 0 (from s11c/, runner 5e4b29ec…1c1d, sentinel RC=0 15:49:19Z). s10d2 v1 BINDING rc 0 (runner 9a2f8b36…67e8).
- Builder DELTA files: I regenerated both runner diffs and the fixture diff with `diff -u`. Apart from the header they are identical to the builder's DELTA files.

## Pins verified at worktrees/fa72-s11b (read-only git, GIT_OPTIONAL_LOCKS=0)
- HEAD 4d31616f9288402c0cdd6a74fb30b4b15d0658d3, tree 366efa9f807cf8c1550bfc8a3394b6840f90287b.
- HEAD^ = 7fdcbc04, with tree a802231e and `rev-list --count` = 1. origin/land/s11b = HEAD.
- The branch is fa72/s11b-r1 and the worktree is clean. Author and committer are both Bradley Gleave.
- `.git` is a real directory, hooksPath is unset, and the hook sha256 values match B's pins (pre-commit 67e578d1…6a49, commit-msg 18e15068…a9).
- BASE..HEAD is exactly the 5 paths, all 100644: M lifecycle.service.ts, M scout.service.ts, M test/rls-g2-s10c.spec.ts,
  A s11b-settle-redrive.spec.ts, A settle-redrive.pg.spec.ts.
- The sorted delta equals EXPECT_DELTA in both runners.
- FREEZE-s11b: `git show HEAD:<p> | sha256sum` matches all 5 lines, and its paths equal the delta.
- New A blob pins match `git rev-parse HEAD:<p>`: redrive aac3f7a8, lifecycle 974e2c83, scout.service 9afaac48.
  The 14 template blob pins are unchanged and still OK.
- FREEZE-v3 (e6e3a15a…) still matches all 8 A1 files at HEAD. FREEZE-s11c (2d58f9d1…) still matches all 7 S11-C files.
- The new `S11C_FILES` literal equals the sorted FREEZE-s11c paths.
- `git diff 7fdcbc04 HEAD -- prisma package.json package-lock.json test/utils docs` is empty. The migrations tree is 7b6fe0ed.
  The contract blob is 1a5deca5 at both BASE and HEAD.
- Ancestry holds: HARNESS_BASE 711c1f8f is an ancestor of HEAD, and S10B_HEAD a2c74e90 and HARNESS_BASE_HEAD a4af8e33 are ancestors of BASE.
- B: `test/rls-g2-s10c.spec.ts` at HEAD is 4a5a6bb6 (BASE 50a0deae). The diff is only the R36 retry assertions, flipped from 0 to 1.
  All 10 S10-B proof-file blob pins are OK.
- B: d3a9f701 FROZEN.sha256 (e9c71f09…) matches 29/29 at HEAD, with the premise-P exception. None of the 5 S11-B paths is in FROZEN.
- `git diff a2c74e90 HEAD -- prisma package.json package-lock.json 'test/utils/g2-s10b-*'` is empty.

## Spec counts at HEAD (grant values match)
- A: rls 6, journey 8 and readiness 6 are template-pinned blobs, unchanged. Guard 94 is unchanged.
- A, **settle-redrive**: `^\s*it\(` = 8 (J12, J12 edge, J13, J14, J15 a/b/c, tenant scope).
  The live switch is exactly `const live = process.env.G2_S11_DATABASE_URL ? describe : describe.skip;`. The runner's BADPAT finds nothing.
  There is no `it(` beyond the 8 at line start.
  The spec needs only the frozen `g2-s11-harness`/`g2-s11-pg-harness`/`g2-s11-worker.cjs`, whose `before-lock`/`after-row` barriers are present at HEAD.
- B: rls-g2-s10b 24 + rls-g2-s10c 8 = 32.
  Neither spec carries skip/only/todo. The s10c spec imports `./utils/g2-s10b-harness` and has no g2-s10c/G2_S10C references.

## New jest-redrive stage (A) mirrors the pattern
- It uses its own log `JLOG5=$R/jest-redrive.log`, added to the RECEIPTS list.
- It uses the same `( cd "$W" && timeout -k 30 N ./node_modules/.bin/jest --runInBand --ci <spec> ) >log 2>&1; JRC=$?` form with the default config, like readiness.
- It calls the shared `jcheck`, which requires rc 0, `Test Suites: 1 passed, 1 total` and `Tests: 8 passed, 8 total`.
  jcheck calls `fail` (STOP_FIRST_FAILURE, teardown, finish) on the first failure.
- It is placed after readiness and before guard, as granted. The step-8 comment now says "five specs".
- Its pins join the pins-not-filled `case`, the harness-bytes read, the live-switch and BADPAT checks, the it()-count gate and the blob loop.
- FREEZE-s11b is checked both before the lock and again under the lock.

## B command
It is `./node_modules/.bin/jest -c jest.rls.config.js --runInBand --ci test/rls-g2-s10b.spec.ts test/rls-g2-s10c.spec.ts` with bound 1500.
Expected output is `Tests: 32 passed, 32 total`, `Test Suites: 2 passed, 2 total`, and PASS-path set = {s10b, s10c}.
I checked the PASS-line parser against the accepted v6 jest.log (`PASS rls-live test/…`); it produces exactly
`test/rls-g2-s10b.spec.ts test/rls-g2-s10c.spec.ts `. The v6 run took 220 s for the same 32.
The D2-specific checks (8 blobs, pure-add, mode, D2 spec, D2 live-line) were removed. The FREEZE-s11b checks replace them.

## Timeouts
- A: the inner bounds present in the runner are clone 2×120, cp 600, generate 600, init 60, start 60, bootstrap 900,
  8 psqlq calls ×15, rls 1500, journey 1500, readiness 900, redrive 3000, guard 300, stop 75 and destroy 75.
  That sums to 9930 s, not 9810 (see C3), which is under the 10200 outer bound.
  Any stage timeout stops the run, so at most one `-k 30` adds to that.
- The 3000 s redrive bound is honest against the 90 s worker kill timer (`g2-s11-pg-harness.ts:156 setTimeout(... child.kill(), 90000)`).
  It also compares well with the observed journey time of 177.4 s in the S11-C run.
- B: the outer bound is 4500 and the stage sum 3555, unchanged from the template.

## Lanes, ports, one-shot
| | A | B |
|---|---|---|
| lane | clusters/s11 | clusters/s11b-s10b |
| socket | run/s11 | run/s11b-s10b |
| port | 55648 | 55649 |
| clone W | fa72-s11b-pg1 | fa72-s11b-pg2 |
| run dir | own D/run | own D/run |

- Neither lane refuses its own port, and each refuses the other's port. The lane literals in the B fixture match its runner checks, so there is no collision.
- Neither W exists, and neither binding has a run/ dir yet. `runtime/clusters` currently holds only s10d2 (stopped). `run/s11` is empty, which the preflight allows.
- Pre-STARTED refusals leave the run unconsumed:
  - A: PRELOCK `fail` exits with no lock. flock -n failure → rc 75 before STARTED. STARTED is O_EXCL.
  - B: template R1 ordering → PRESTART_REFUSED, removing W only if this run created it.
- The canonical lock inode is 686480, which equals EXPECT_LOCK_INODE in both runners.

## C findings (record, qualify, continue)
- C1 — The parent launchers (`launch-when-free.sh` in both dirs) were created after BINDING.sha256 and are not listed in it.
  Their header comment still says "S11-A1 v3".
  Their bounds are correct (10200 for A, 4500 for B). If both are started together, both can see the lock free and one will exit rc 75. That run is not consumed, but the relaunch is manual.
  Qualification: launch them one after the other.
- C2 — Inherited template comments are stale ("inode 692282" at L41 of A and L31 of B; "pins from c8ee9005"; B's "D2 changes no prisma" at L69/L109).
  These are comment text in unchanged template bytes and are never compared.
- C3 — A's soft-sum comment says "clone 120" but the runner has two 120 s clone steps. The true sum is 9930, still under 10200 (270 s margin).
  This undercount is inherited from the template's arithmetic.
- C4 — B's argument order and form (`-c`, flags before the specs) differ from the v6 form (`--config`, specs before flags). They are equivalent for jest, and the parser was checked against the v6 output.
- C5 — B shares port 55649 and marker `s10b-disposable-pg17` with the stopped `clusters/s10d2/pg-data`.
  This is safe because the lock serialises runs, the preflight requires the port to be free and zero postgres processes, and other lanes are fingerprinted.
  Nobody should start s10d2 manually.
- C6 — After A runs, `clusters/s11` will again hold the three logs, because teardown destroys only pg-data. Any later S11-lane binding needs the same archive-and-remove step.
  After B runs, `clusters/s11b-s10b/pg-data` is kept (template behaviour). The other runner fingerprints it and it does not block. Either order works.
- C7 — The unit spec `test/scout/lifecycle/s11b-settle-redrive.spec.ts` is frozen but neither lane runs it (the builder also noted this).
- C8 — The redrive bound is a practical bound, not the 8×600 s jest ceiling. A timeout is a failure (rc 124), not a retry.

## Commands run (all read-only; rc)
- `cat` WORKER_RULES, the review and build grants, the build report and both READMEs; `ls -la` on the binding/template/runtime/worktree dirs: rc 0.
  One `ls` of the not-yet-existing pg1/pg2/run paths: rc 2, as expected.
- `sha256sum -c BINDING.sha256` in s11-lane-v1, s10b-lane-v1 and s10d2/binding/v1: rc 0.
  In s11c/binding/v1 this failed on relative paths (rc 1). Rerun from s11c/: rc 0.
- `sha256sum` of every binding file, FREEZE-v3, FREEZE-s11c and d3a9f701 FROZEN.sha256: rc 0.
- `diff -u` of the two runners and the B fixture against their templates: rc 1 (differences). `diff` against the builder's DELTA files after the header: rc 0. `cmp` of the A fixture: rc 0.
- `git rev-parse|status --porcelain|log -1|diff --name-status|diff --name-only|ls-tree|show HEAD:<p>|merge-base --is-ancestor|rev-list --count|grep` in fa72-s11b (GIT_OPTIONAL_LOCKS=0): rc 0.
- Read-only shell loops with `git show HEAD:<p> | sha256sum` and `git rev-parse HEAD:<p>` over FREEZE-s11b, FREEZE-v3, FREEZE-s11c, FROZEN and all blob pins: all OK.
  One loop printed a false "BAD" for EXPECT_S10C_SPEC_BLOB because my variable-extraction regex skipped the digits in the name. I verified that pin separately with ls-tree (4a5a6bb6).
- `grep`/`sed` on the runners, the specs at HEAD and the v6 jest.log; `grep -cE '^\s*it\('` counts: rc 0.
- `stat -c %i` on the lock: 686480. `sha256sum` of SRC hooks and `git config --get core.hooksPath`: rc 1, unset.
- `bash -n` (parse-only, no execution) on both runners and the B fixture: rc 0.
- `git status --porcelain` in the evidence repo: the binding dir is untracked, and the parent commits it.

## Open risks
None at A or B level. C1–C8 are recorded above.
