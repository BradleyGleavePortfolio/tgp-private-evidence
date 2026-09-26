# S11-C real-PG proof binding v1 (EXEC-FA72EFB2) — SOURCE ONLY, NOT RUN

Derived by minimum substitution from the accepted A1 runner `execution/fa72efb2/s11a1/binding/v3/s11-pg-proof.sh`
(sha256 201eced2cb02917cd4c70e2b9ec168ab272ddaf8d3ff8872381c80440e9615f8, RC=0 at 15:27:54Z). Full delta: `DELTA-from-s11a1-v3.diff`
(11 hunks, +53/-26; 342 -> 369 lines). Built by the T3 binding builder; nothing was run (no runner, PG, bootstrap, jest, lock).

Runner filename is kept as `s11-pg-proof.sh` (the grant's preference): the byte-copied fixture refuses unless
`/proc/$S11_RUNNER_PID/cmdline` contains `s11-pg-proof.sh`; `s11c-pg-proof.sh` would not match.

Usage (only under a separate single-run PG grant, parent only):
`timeout -k 30 7200 bash /home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11c/binding/v1/s11-pg-proof.sh`

## Files
- s11-pg-proof.sh — the runner (sha256 5e4b29ec9a00947c004aced3d8b2f309e81f31801092c2b78866734a17ee1c1d)
- s11-fixture.sh — byte copy of v3 fixture (777e6ac3…1636; runner pin EXPECT_FIXTURE_SHA unchanged)
- FREEZE-s11c.sha256 — sha256 of the 7 S11-C paths at 7fdcbc04 (paths == BASE..HEAD delta)
- DELTA-from-s11a1-v3.diff, README.md, BINDING.sha256

## Stage order (template, one added stage)
bootstrap -> identity -> rls-g2-s11 (6, jest.rls.config.js) -> journey-core (8, regression) -> **readiness (6, default config,
jest-readiness.log, bound 900 s)** -> guard (94, no DB) -> teardown -> post. Soft sum 5910 + 900 = 6810 s < unchanged 7200 s outer.

## Precondition that the parent must close before launch (A)
`/home/user/workspace/execution/fa72efb2/runtime/clusters/s11` EXISTS (A1 v3 teardown removed only pg-data; it holds A1's
pg.log, pg.log.pg_ctl, pg-data.initdb.log — pg.log and pg.log.pg_ctl are LONGER than the A1 $R copies, which were taken before
stop). The template's refusal "$LANE exists (fresh lane only; never adopt)" is kept verbatim, so as-is the run PRELOCK_REFUSES
(rc 70, not consumed). Minimum closure (parent, runtime is parent-only): archive those 3 files into the A1 evidence and remove the
now-empty lane dir; `runtime/run/s11` is empty and passes preflight.
