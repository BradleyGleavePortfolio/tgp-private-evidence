# S10-C gate run-1 — rc=73 at JEST_FULL (preserved; no commit)
- gate/ run: PRELOCK..ESLINT, TSC, contract, JEST_TARGETED 214/214 passed; JEST_FULL 9627 passed, 5 failed (1 suite: test/scout/orchestration/settle-hook.spec.ts). Artifacts in gate/ (STARTED, TERMINAL, jest-full.raw.log) untouched.
- Finding (class B, proof defect in a landed S8-G unit spec): its fake transaction lacked scoutRunObservation/scoutRunSettledBasis, which S10-C's reviewed settled-basis write (D-S10-6) calls inside the settle transaction; and its facts.collect expectation lists 3 args where S10-C passes the run context as a 4th. The devloops ran S10-C's targeted specs only.
- Concrete harm: none (product path is as designed and reviewed).
- Blocked: S10-C commit only.
- Minimum fix: gate-fix/settle-hook.diff (20 lines, test-only: 2 stubs + 1 argument matcher). settle-hook spec 10/10 under the lock (gate-fix/jest-settle-hook-2.log). Owned paths 11 -> 12.
- Unblocks: S10-C gate v2 (new run dir gate-v2/, new grant).
