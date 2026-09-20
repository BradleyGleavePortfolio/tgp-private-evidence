// Probe B-1: does readUserCache() see what setUserCache() wrote when react-native-mmkv is absent
// (AsyncStorage shim path, NODE_ENV=production)? Pure Node, in-memory AsyncStorage mock, no installs.
const path = require('path');
const fs = require('fs');
const Module = require('module');
const WT = process.env.WT || '/home/user/workspace/worktrees/s6-final';
const NM = process.env.NM || '/home/user/workspace/worktrees/s6/node_modules';
const ts = require(path.join(NM, 'typescript'));
process.env.NODE_ENV = 'production';

const mem = new Map();
const asyncStorageMock = {
  getItem: async (k) => (mem.has(k) ? mem.get(k) : null),
  setItem: async (k, v) => { mem.set(k, String(v)); },
  removeItem: async (k) => { mem.delete(k); },
  getAllKeys: async () => [...mem.keys()],
  multiRemove: async (ks) => ks.forEach((k) => mem.delete(k)),
  removeMany: async (ks) => ks.forEach((k) => mem.delete(k)),
};
const mocks = {
  '@react-native-async-storage/async-storage': { __esModule: true, default: asyncStorageMock },
  'react-native': { Platform: { OS: process.env.PLATFORM_OS || 'ios' } },
  'react-native-mmkv': null, // absent: require must throw
};
const origResolve = Module._resolveFilename;
Module._resolveFilename = function (request, parent, ...rest) {
  if (request in mocks) {
    if (mocks[request] === null) { const e = new Error(`Cannot find module '${request}'`); e.code = 'MODULE_NOT_FOUND'; throw e; }
    return 'mock:' + request;
  }
  // resolve relative .ts imports from the worktree source
  if (request.startsWith('.') && parent && parent.filename && parent.filename.startsWith(WT)) {
    const base = path.resolve(path.dirname(parent.filename), request);
    for (const cand of [base + '.ts', base + '.tsx', base]) if (fs.existsSync(cand) && fs.statSync(cand).isFile()) return cand;
  }
  return origResolve.call(this, request, parent, ...rest);
};
require.extensions['.ts'] = function (m, filename) {
  const src = fs.readFileSync(filename, 'utf8');
  const out = ts.transpileModule(src, { compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2020, esModuleInterop: true } }).outputText;
  m._compile(out, filename);
};
const origLoad = Module._load;
Module._load = function (request, parent, isMain) {
  if (request in mocks && mocks[request] !== null) return mocks[request];
  return origLoad.call(this, request, parent, isMain);
};
function loadTs(rel) {
  const file = path.join(WT, rel);
  const src = fs.readFileSync(file, 'utf8');
  const out = ts.transpileModule(src, { compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2020, esModuleInterop: true } }).outputText;
  const m = new Module(file, module);
  m.filename = file; m.paths = Module._nodeModulePaths(path.dirname(file));
  m._compile(out, file);
  return m.exports;
}
(async () => {
  const mmkv = loadTs('src/storage/mmkv.ts');
  const uc = loadTs('src/lib/userCache.ts');
  console.log('isMmkvAvailable =', mmkv.isMmkvAvailable());
  console.log('prefsStorage is shim (sync getString undefined) =', mmkv.prefsStorage.getString('x') === undefined);
  // Scenario 1: email/password login path -> setUserCache, then a cold-start style readUserCache()
  uc.setUserCache({ id: 'coach-A', email: 'a@x', role: 'coach' });
  await new Promise((r) => setImmediate(r));
  console.log('after setUserCache, AsyncStorage keys =', [...mem.keys()]);
  const r1 = await uc.readUserCache();
  console.log('S1 readUserCache() after setUserCache ->', r1);
  console.log('S1 readUserCacheSync() ->', uc.readUserCacheSync());
  // Scenario 2: legacy user_data present (Google/Apple auth utilities write it)
  mem.clear();
  await asyncStorageMock.setItem('user_data', JSON.stringify({ id: 'coach-B', role: 'coach' }));
  const r2a = await uc.readUserCache();
  await new Promise((r) => setImmediate(r));
  const r2b = await uc.readUserCache();
  console.log('S2 first readUserCache (migration) ->', r2a && r2a.id, '| keys now =', [...mem.keys()]);
  console.log('S2 second readUserCache (e.g. useCurrentUser mount) ->', r2b);
})().catch((e) => { console.error('PROBE ERROR', e); process.exit(2); });
