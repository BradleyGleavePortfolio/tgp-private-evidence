# S10-C real-PG proof v4 — RC=72 at the PASS-line check (tests 32/32 passed), preserved
- binding/v4/run: JEST rc=0; 'Tests: 32 passed, 32 total' and 'Test Suites: 2 passed, 2 total' checks passed; then JEST_COUNT_FAIL "PASS lines [rls-live rls-live ] != the two specs".
- Finding (class B, harness parser): jest.rls.config.js sets displayName rls-live, so the line is "PASS rls-live test/rls-g2-s10c.spec.ts (129.707 s)"; awk '{print $2}' reads the display name. Skipped by the early stop: post-run integrity checks (stop state, other lanes, refused ports, worktree/HEAD, clients).
- Concrete harm: none. Blocked: an RC=0 receipt for S10-C. Minimum fix: extract the spec path (grep -oE 'test/[^ ]+\.spec\.ts'). Unblocks: v5 (same pins, new run dir; v4 lane set aside intact).
