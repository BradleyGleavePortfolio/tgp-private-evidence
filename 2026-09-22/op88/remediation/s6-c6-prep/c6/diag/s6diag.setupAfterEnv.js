'use strict';
/**
 * S6 C5 — sandbox-side preload (setupFilesAfterEnv; runs INSIDE the test
 * module sandbox, after the project's own jest.setup.js). Observation only.
 *
 * Records, without evaluating any module the test did not already load, the
 * shipped singleton QueryClient's cache contents at afterAll time and again on
 * UNREF'D deferred ticks (after the test file's own synchronous afterAll has run).
 * Uses Jest's read-only `require.cache` proxy over the module registry
 * (jest-runtime _createRequireImplementation) so nothing is imported here.
 * Invoked via CLI:
 *   --setupFilesAfterEnv=<wt>/jest.setup.js --setupFilesAfterEnv=/home/user/workspace/execution/s6-diagnostic/diag/s6diag.setupAfterEnv.js
 */
const fs = require('fs');
const LOG = process.env.S6DIAG_LOG || '/dev/null';
const STEP = process.env.S6DIAG_STEP || '?';

function w(o) {
  try {
    fs.appendFileSync(LOG, JSON.stringify({ src: 'sandbox', step: STEP, t: new Date().toISOString(), ...o }) + '\n');
  } catch {
    /* never throw into the test */
  }
}

function registryKeys() {
  try {
    return Object.keys(require.cache).filter((k) => /services\/queryClient|persistedQueryCache\.hazard|s6diag|query-async-storage-persister\/build|query-persist-client-core\/build/.test(k));
  } catch (e) {
    return ['n/a: ' + String(e && e.message)];
  }
}

function findQueryClientModule() {
  try {
    const key = Object.keys(require.cache).find((k) => /\/src\/services\/queryClient\.(ts|tsx|js)$/.test(k));
    if (!key) return null;
    const rec = require.cache[key];
    return rec && rec.exports ? { key, exports: rec.exports } : null;
  } catch (e) {
    w({ ev: 'sandbox-registry-error', error: String(e && e.message) });
    return null;
  }
}

function qcState(exportsObj) {
  try {
    const c = exportsObj.queryClient;
    const queries = c
      .getQueryCache()
      .getAll()
      .map((q) => ({
        hash: q.queryHash,
        status: q.state.status,
        fetchStatus: q.state.fetchStatus,
        observers: q.getObserversCount(),
        gcTime: q.gcTime,
        dataUpdatedAt: q.state.dataUpdatedAt,
      }));
    const mutations = c.getMutationCache().getAll().length;
    return { queries, mutations, isFetching: c.isFetching() };
  } catch (e) {
    return { error: String(e && e.message) };
  }
}

w({ ev: 'sandbox-loaded', hasAfterAll: typeof afterAll === 'function', registryKeys: registryKeys() });

if (typeof afterAll === 'function') {
  afterAll(() => {
    const mod = findQueryClientModule();
    w({ ev: 'sandbox-afterAll', qcLoaded: Boolean(mod), qcKey: mod && mod.key, registryKeys: registryKeys(), qc: mod ? qcState(mod.exports) : null });
    if (!mod) return;
    for (const d of [1500, 4000, 8000]) {
      try {
        const t = setTimeout(() => w({ ev: 'sandbox-deferred', afterMs: d, qc: qcState(mod.exports) }), d);
        if (t && typeof t.unref === 'function') t.unref();
        else w({ ev: 'sandbox-deferred-warning', afterMs: d, msg: 'timer has no unref(); sandbox timers may be faked' });
      } catch (e) {
        w({ ev: 'sandbox-deferred-error', afterMs: d, error: String(e && e.message) });
      }
    }
  });
}
