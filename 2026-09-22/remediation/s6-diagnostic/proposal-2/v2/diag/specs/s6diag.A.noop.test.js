/**
 * S6 C5 step A — instrument + preset NEGATIVE CONTROL (no product module, no React render).
 * Expected: 1/1 pass, process exits on its own (rc 0, `beforeExit` recorded), no live refed
 * handle owned by product/harness at globalTeardown. A hang here implicates the runner/preset
 * or the instrument itself (H-E/H-C) and STOPS the run before B/D/C.
 * Untracked copy target: <wt>/src/services/__tests__/s6diag.A.noop.test.js
 */
it('A: jest-expo preset + inventory hook alone', () => {
  expect(1 + 1).toBe(2);
});
