# S11-B real-PG proof binding — S10-B lane v1 (R36 flip) (EXEC-FA72EFB2) — SOURCE ONLY, NOT RUN

Built by the T3 binding builder under `s11b/S11B_BINDING_BUILD_GRANT.md`. Nothing was run: no runner, fixture, jest, bootstrap,
PostgreSQL, or lock. Pins were re-derived read-only in `/home/user/workspace/worktrees/fa72-s11b` and the fa72efb2 runtime.

## Provenance
- Mechanics template: `execution/fa72efb2/s10d2/binding/v1/d2-pg-proof.sh` (sha256 9a2f8b366f5391685fd1dff9c7bf7ab0b3510e2bf0d2bdade3ae7f482caa67e8)
  and `d2-fixture.sh` (0fadafa36ff77dbf5621315d5ffca54bc4a57d2a7d8dc0328532798fcea5c24b), both read in full. That run passed
  lock/prestart/clone/donor-copy/bootstrap in this runtime and failed only at the D2 jest assertions (RC=1), so the
  mechanics are the ones exercised in this runtime.
- Spec command and counts: `execution/d3a9f701/s10c/binding/v6` (the accepted S10-C run: `jest -c jest.rls.config.js --runInBand --ci
  test/rls-g2-s10b.spec.ts test/rls-g2-s10c.spec.ts`, 24 + 8 = 32, 2 suites, PASS lines carry the `rls-live` displayName).
  `jest.rls.config.js` at HEAD is blob 44c96915…, and no commit in 2ec74c56..HEAD touches it or jest.config.js.
- Built by `.build-s10b-lane.py` (count-asserted: each substitution must match exactly once; argv = FREEZE-s11b sha). It
  computes the fixture sha and writes it into the runner as `EXPECT_FIXTURE_SHA`.
- Deltas: `DELTA-from-d2-v1.diff` (14 hunks, +72/-87; 421 lines) and `DELTA-fixture-from-d2.diff` (4 hunks, +12/-7; 111 lines).
  `bash -n` rc 0 on both files. The only leftover D2 strings are header history and the template protocol tokens
  `D2_RUNNER_PID`/`D2_STOP_TIMEOUT`/`D2_FIXTURE_*`, which stay verbatim because the runner and fixture both grep for them.

## Changed pins
| pin | D2 v1 | S10-B lane v1 |
|---|---|---|
| D / runner / fixture | s10d2/binding/v1, d2-pg-proof.sh, d2-fixture.sh | s11b/binding/s10b-lane-v1, s10b-lane-pg-proof.sh, s10b-lane-fixture.sh (fixture requires `s10b-lane-pg-proof.sh` in the runner cmdline) |
| SRC / branch / W | fa72-d2 / fa72/d2-r1 / fa72-d2-pg1 | fa72-s11b / fa72/s11b-r1 / fa72-s11b-pg2 (absent) |
| LOG / SENT | d2-pg-proof.* | s10b-lane-pg-proof.log / .sentinel (JLOG jest.log unchanged) |
| EXPECT_HEAD / TREE | 144269d1 / a0bc3c09 | 4d31616f9288402c0cdd6a74fb30b4b15d0658d3 / 366efa9f807cf8c1550bfc8a3394b6840f90287b (BASE 7fdcbc04 unchanged) |
| LAND_REF | origin/land/s10d2 | refs/remotes/origin/land/s11b = 4d31616f |
| EXPECT_DELTA / owned | 8 D2 additions | 5 S11-B paths (3 M, 2 A; all 100644) |
| D2 8-blob pins, pure-addition DADD, DMODES, D2-spec it()/live-switch/import checks | present | replaced by FREEZE-s11b (own-dir copy, sha ca321526…24f4; paths == delta; each path's sha256 at HEAD checked); under-lock recheck includes the FREEZE sha |
| hook pins | 54aa5cd8… / dc998a5e… | pre-commit 67e578d15a4b0d52bd517f06052efbb0e397f7d945fd5582ab639b9928e46a49 / commit-msg 18e15068a4c266d4499eafda9cd1d4d5180eb1e95b02939cf5a400c23260f1a9 |
| EXPECT_S10C_SPEC_BLOB | 50a0deae (not run) | 4a5a6bb6c29222c5c290f3680b4f5b5bd3d209ff (R36 flip; RUN) |
| EXPECT_FIXTURE_SHA | 0fadafa3… | 2fc8012dea542751228a9b1b98e6367fa40cd3d5849e73bcd6f2019147a5db2a |
| lane | clusters/s10d2 + run/s10d2 | clusters/s11b-s10b + run/s11b-s10b (both absent); port 55649 and S10-B harness literals unchanged; refused 55646/55647/55648 |
| jest | jest.config.js --runTestsByPath D2 spec, 8, 1 suite | jest.rls.config.js s10b + s10c specs, **32**, **2 suites**, PASS lines == both specs |

These pins are unchanged and were re-verified at HEAD: contract 1a5deca5 unchanged, the FROZEN 29-path S10-A/S10-B set (premise-P
exception 9b5de374), it() counts s10b 24 / s10c 8 (no skip/only), s10c spec imports g2-s10b-harness with no g2-s10c refs,
ObservationModule wired in scout.module.ts, no prisma/manifest diff, and the donor client/tool/lock pins. Jest bound 1500 s,
soft sum 3555, outer 4500. R1 ordering stays as in the template: STARTED is written after clone/copy, and a prestart refusal
removes W only if this run created it. The data dir is RETAINED after stop, also as in the template.

## Expected counts
bootstrap once -> identity -> ONE jest run: `Tests: 32 passed, 32 total`, `Test Suites: 2 passed, 2 total`
(rls-g2-s10b 24 + rls-g2-s10c 8). The R36 flip under test is the retry case in rls-g2-s10c: 1 terminal CAS, 1 basis,
terminal set, SETTLED 1.

Usage (parent only, under a separate single-run PG grant):
`timeout -k 30 4500 bash /home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s10b-lane-v1/s10b-lane-pg-proof.sh`

## Open risks
- C: `clusters/s11b-s10b/pg-data` is retained after stop (template behaviour). If this lane runs before the S11 lane, the S11 runner fingerprints it (no block). Destroying it needs a separate grant.
- C: `clusters/s10d2/pg-data` (D2, stopped, no postmaster.pid) is fingerprinted as another lane and must stay stopped. Preflight requires zero postgres processes.
- C: the two S11-B lanes share the lock and port 55649 is not used by the S11 lane, but they cannot run concurrently (single lock + no-postgres preflight). Either order works.
- C: jest.rls.config.js is not blob-pinned by this runner (same as the template). It was verified unchanged (44c96915) and it is pinned by the S11-lane runner.
- C: the unit spec `test/scout/lifecycle/s11b-settle-redrive.spec.ts` is not run in this lane. It is only frozen.
