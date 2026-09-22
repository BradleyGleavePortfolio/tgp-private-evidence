/**
 * S6 C5 step B — PRODUCTION IMPORT-ONLY perturbation control.
 * Loads the shipped `src/services/queryClient` module exactly as App.tsx does at boot
 * (constructing the module-level `queryClient` and the import-time `asyncStoragePersister`
 * singleton), performs NO cache operation, NO render, NO signOut.
 * Expected: 1/1 pass and clean exit (rc 0). A hang here = the shipped module's import-time
 * construction alone retains a resource (production ownership independent of any harness).
 * Untracked copy target: <wt>/src/services/__tests__/s6diag.B.importOnly.test.js
 */
import * as qc from '../queryClient';

it('B: importing the shipped queryClient module constructs the singleton persister', () => {
  expect(typeof qc.queryClient.getQueryCache).toBe('function');
  expect(typeof qc.asyncStoragePersister.persistClient).toBe('function');
  expect(qc.persisterKeyForUser(null)).toBe(`${qc.QUERY_CACHE_KEY_PREFIX}:anonymous`);
  expect(qc.queryClient.getQueryCache().getAll().length).toBe(0);
});
