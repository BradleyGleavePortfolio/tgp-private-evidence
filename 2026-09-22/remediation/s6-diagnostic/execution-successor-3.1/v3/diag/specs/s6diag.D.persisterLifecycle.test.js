/**
 * S6 C5 step D — PRODUCTION PERSISTENCE LIFECYCLE perturbation control, WITHOUT React/RNTL/act
 * and WITHOUT authActions.signOut. Drives the exact shipped composition's persistence
 * primitives (the same singleton persister, buster, maxAge and dehydrate filter App.tsx passes
 * to PersistQueryClientProvider) through: restore (empty disk) → subscribe → immediate write →
 * queued (throttled) write → unsubscribe → clear. Every step is what the pinned library does
 * for the shipped app on boot and on cache churn.
 * Expected: 1/1 pass and clean exit (rc 0). A hang here = production persistence lifecycle
 * retains a resource with no harness involvement (production ownership).
 * Exit 0 here while C hangs = the retention needs the React/RNTL harness or the signOut path;
 * C's inventory chain then names the layer.
 * Untracked copy target: <wt>/src/services/__tests__/s6diag.D.persisterLifecycle.test.js
 */
import AsyncStorage from '@react-native-async-storage/async-storage';
import { persistQueryClientRestore, persistQueryClientSubscribe } from '@tanstack/react-query-persist-client';
import * as qc from '../queryClient';

const BUSTER = 'tgp-rq-v2-samples'; // App.tsx literal, as mirrored by the hazard adapter
const wait = (ms) => new Promise((res) => setTimeout(res, ms));
const options = () => ({
  queryClient: qc.queryClient,
  persister: qc.asyncStoragePersister,
  maxAge: qc.QUERY_CACHE_MAX_AGE,
  buster: BUSTER,
  dehydrateOptions: { shouldDehydrateQuery: (q) => q.meta?.persist !== false },
});

afterAll(() => {
  qc.queryClient.clear();
});

it('D: shipped persistence lifecycle without React — restore, write, throttled write, unsubscribe, clear', async () => {
  await AsyncStorage.clear();
  await persistQueryClientRestore(options()); // boot with nothing on disk
  const unsubscribe = persistQueryClientSubscribe(options());
  const key = qc.persisterKeyForUser(null);

  qc.queryClient.setQueryData(['me'], { id: 'user-D' }); // throttle idle → immediate write
  await wait(60);
  const first = JSON.parse(await AsyncStorage.getItem(key));
  expect(first.clientState.queries.length).toBe(1);

  qc.queryClient.setQueryData(['me'], { id: 'user-D', n: 2 }); // inside the 1 s window → queued write
  await wait(1200); // window closes; queued write lands with the latest snapshot
  expect(await AsyncStorage.getItem(key)).toContain('"n":2');

  unsubscribe();
  qc.queryClient.clear();
  await wait(1200); // any trailing throttle wait armed before unsubscribe has expired
  expect(qc.queryClient.getQueryCache().getAll().length).toBe(0);
});
