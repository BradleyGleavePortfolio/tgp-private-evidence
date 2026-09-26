# S11-C binding v1 — independent T3 delta review (EXEC-FA72EFB2)

Verdict: **GO**. No A or B findings. Four C findings are recorded below.

Reviewer scope: this review covers only `DELTA-from-s11a1-v3.diff`, checked against the live bytes in `worktrees/fa72-s11c`.
It was read-only. I did not run the runner, jest, PG or bootstrap, did not take the lock, and made no edits or commits.

## Subject (sha256 re-computed)
- s11c/binding/v1/s11-pg-proof.sh 5e4b29ec9a00947c004aced3d8b2f309e81f31801092c2b78866734a17ee1c1d (== BINDING.sha256, == builder report)
- s11-fixture.sh 777e6ac3…1636 (`cmp`-identical to s11a1/binding/v3/s11-fixture.sh; EXPECT_FIXTURE_SHA unchanged)
- FREEZE-s11c.sha256 2d58f9d1…137e (== S11C_FREEZE_SHA), DELTA-from-s11a1-v3.diff 6819fad7…c3ea, README.md 1b754f59…a83f
- Template s11a1/binding/v3/s11-pg-proof.sh 201eced2…15f8. FREEZE-v3 e6e3a15a…4187 (== S11_FREEZE_SHA).
- I re-ran `diff -u` template vs runner, and the result is identical to the DELTA file (lines 3+ compared). The DELTA file is complete: the runner has no changes beyond it.
- `bash -n` on the runner: RC 0.
- Note: BINDING.sha256 uses `binding/v1/…` paths, so `sha256sum -c` only works from `s11c/`. From inside v1 it reports "FAILED open". I verified the files by direct sha256sum instead.

## Pins vs live bytes (fa72-s11c, git read-only)
- HEAD 7fdcbc04…b752. Tree a802231e…e8d5. HEAD^ = 3db615c0 (BASE_HEAD). BASE tree 6ea6852c…8b3688e8d5 is correct.
- origin/land/s11c = 7fdcbc04. The clean-status check found 0 lines.
- BASE..HEAD delta == the 7 EXPECT_DELTA paths, in exact sorted order.
- FREEZE-s11c: all 7 files match `git show HEAD:p | sha256sum`.
- FREEZE-v3: all 8 A1 files match at HEAD.
- New blob pins are all correct:
  - readiness.pg.spec 1afcb07d
  - service dfd2e267
  - dto 9eb9f3d3
- All 11 unchanged blob pins match at HEAD (loop over the runner's own `for pin` list: 14/14 ok).
- Other unchanged pins also match:
  - migrations tree 7b6fe0ed at HEAD and at BASE
  - 173 migration dirs
  - schema sha d6d01f54
  - package-lock b7fed5ed
- W worktrees/fa72-s11c-pg1 does not exist. runtime/clusters/ is empty, so the builder's open risk A (a leftover `$LANE`) is closed. The A1 lane logs are in s11a1/binding/v3/run/post-teardown/.
- Note: runtime/run/s11 is not empty; it holds pg-data.initdb.log, pg.log and pg.log.pg_ctl. That directory is not `$LANE`, and the runner's only exists-refusals are on `$W` and `$LANE`, so it does not block the run.

## Split harness-base check
- HARNESS_BASE 711c1f8f is an ancestor of BASE (checked with merge-base).
- From HARNESS_BASE to BASE_HEAD, `prisma/package.json/package-lock.json` has no changes.
- Over the same range, the test/utils changes (sorted) are exactly the 6 A1 test/utils paths.
- From BASE to HEAD, `prisma/manifests/test/utils` has no changes.

Does this still stop a harness that differs from the one the bootstrap and spec expect? Yes, because content is fixed independently of this names-only check:
- Blob pins and FREEZE-v3 fix the bytes of all 6 harness files at HEAD.
- The bootstrap's own checks against 711c1f8f cover prisma/manifests only, and those ranges are empty.
- An extra test/utils file added at BASE would fail the names-equality check.
- An extra test/utils file added at HEAD would fail the BASE..HEAD empty check.
- `A1_UTILS` comes from the already-sorted A1_FILES, so its order matches the output of `sort`.

## FREEZE handling
- FREEZE-v3 is now checked as "paths == the 8 A1_FILES, and the bytes at HEAD match". This is correct: none of the A1 files are in the S11-C delta.
- FREEZE-s11c is checked as "paths == EXPECT_DELTA, and the bytes at HEAD match".
- Both FREEZE shas are re-checked under the lock.

## Readiness stage
- Count: HEAD bytes have 6 `^\s*it\(`, which matches EXPECT_TESTS_READINESS=6.
- BADPAT: the file has no only/todo/x/f/skip/each patterns.
- Live switch: the pinned `const live = process.env.G2_S11_DATABASE_URL ? describe : describe.skip;` is present at line 28.
- Harness use: the spec uses only exports that exist in the pinned harness and pg-harness:
  - pairInit/Redeem/Session/Current, startRun, cancelRun, statusOf, expire, runRow, runCount, intentRow, resetData, SETUP_LABEL
  - sql, quote
  - `Result.queries`
- Worker: the worker already handles `pair-session`/`pair-current`/`start`/`cancel`/`status`. It builds `ExtensionPairService(prisma, auth)` from `$W/src`, so the candidate service is the code actually exercised. S11-C does not change the constructor.
- Pass condition: jcheck requires RC 0, `Test Suites: 1 passed, 1 total` and `Tests: 6 passed, 6 total`. So a skipped or inert describe, or a wrong count, fails closed with code 72.
- Log: the new log jest-readiness.log is included in RECEIPTS.
- Order: journey → readiness → guard, with STAGE set to jest-readiness.
- Budget: 5910 + 900 = 6810 s soft sum, against the unchanged 7200 s outer bound. The A1 v3 journey stage (8 tests, 64 awaits) took 180 s; readiness has 19 awaits, so 900 s leaves ample margin.

## Does the S11-C candidate make the unchanged template body wrong?
I found nothing concrete.
- `session()` and `current()` share `readSetup`, which now adds the same `readiness` block to both. So journey-core's `expect(session.result).toEqual(paired.result)` (line 201) still holds, and its other pair assertions are `toMatchObject`.
- The new read is one SELECT on ScoutImport. It does not match journey-core's `isGate` (`SET last_observed_at =`) or `isTerminal` filters.
- On foreign or unknown intents, readSetup throws 404 before the readiness read.
- There are no prisma or manifest changes, so the donor client and schema pins remain valid.

## Findings (all C)
- C1: The live-switch `grep -F` and BADPAT do not exclude a second `describe.skip` in the readiness spec. This is the same as the journey spec in the template. The exact `6 passed, 6 total` check closes it. Recorded only.
- C2: Worst case, a hung readiness run hits `timeout 900` (per-test jest timeout 300 s × 6 exceeds 900). It would fail closed with RC 124, charged to stage jest-readiness. It cannot produce a false pass.
- C3: This binding does not re-prove test/rls-c1-setup.spec.ts, src/extension-pair/__tests__/readiness.spec.ts or the contract spec, per the grant. Those belong to their own lanes or gates, so the parent should not read this binding as covering them.
- C4: BINDING.sha256 paths are relative to `s11c/`, not `binding/v1/` (cosmetic). As noted above, runtime/run/s11 holds 3 A1 log files, not empty as the parent note says. It does not block the run.

Minimum closures before launch: none.

## Commands run (all read-only)
- `cat`/`ls`/`find` on the evidence and runtime dirs: RC 0.
- `sha256sum` on the binding and template files: RC 0.
- `sha256sum -c BINDING.sha256` from v1: RC 1, caused by the path base (C4).
- `diff -u` template vs runner, compared against the DELTA file: identical. `cmp` on the fixture: RC 0.
- `bash -n` on the runner: RC 0.
- Git in fa72-s11c, all RC 0 except where noted:
  - `rev-parse` (HEAD, trees, HEAD^, land ref, blob pins, migrations)
  - `status --porcelain`
  - `diff --name-only` / `--stat` over the three ranges
  - `merge-base --is-ancestor`: 0
  - `show` for the spec, harness, worker, service, bootstrap and jest.config bytes
  - `ls-tree`
  - The FREEZE loops: all ok.
- `grep`/`sed` over the runner, the A1 run logs and the jest timings.
