// Probe B-2: real useCurrentUser() + real lib/userCache + real storage/mmkv (react-native-mmkv ABSENT
// => AsyncStorage shim), rendered with react-test-renderer, after the email/password login path's
// setUserCache(). Question: does the coach identity ever resolve for a hook consumer such as
// useExtensionPairing's hydration gate? Pure Node, in-memory AsyncStorage mock, no installs.
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
};
const React = require(path.join(NM, 'react'));
const mocks = {
  '@react-native-async-storage/async-storage': { __esModule: true, default: asyncStorageMock },
  'react-native': { Platform: { OS: 'ios' } },
  // absent in every current build (undeclared, not in lockfile). CONTROL=1 substitutes an in-memory
  // MMKV so the same harness can show identity DOES resolve when a sync getString works.
  'react-native-mmkv': process.env.CONTROL ? { MMKV: class { constructor(){ this.m=new Map(); } set(k,v){ this.m.set(k,v); } getString(k){ return this.m.get(k); } getBoolean(k){ return this.m.get(k); } getNumber(k){ return this.m.get(k); } contains(k){ return this.m.has(k); } delete(k){ this.m.delete(k); } getAllKeys(){ return [...this.m.keys()]; } clearAll(){ this.m.clear(); } } } : null,
  react: React,
};
// sentry setSentryUser is a side effect we do not need; stub the module by path
const sentryStub = { setSentryUser: () => {} };
const origResolve = Module._resolveFilename;
Module._resolveFilename = function (request, parent, ...rest) {
  if (request in mocks) {
    if (mocks[request] === null) { const e = new Error(`Cannot find module '${request}'`); e.code = 'MODULE_NOT_FOUND'; throw e; }
    return 'mock:' + request;
  }
  if (request.startsWith('.') && parent && parent.filename && parent.filename.startsWith(WT)) {
    const base = path.resolve(path.dirname(parent.filename), request);
    if (base.endsWith(path.join('services', 'sentry'))) return 'mock:sentry';
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
  if (request === 'mock:sentry' || request.endsWith('/services/sentry')) return sentryStub;
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
const flush = () => new Promise((r) => setTimeout(r, 20));
(async () => {
  const TestRenderer = require(path.join(NM, 'react-test-renderer'));
  const mmkv = loadTs('src/storage/mmkv.ts');
  const uc = loadTs('src/lib/userCache.ts');
  const { authEvents } = loadTs('src/utils/authEvents.ts');
  const { useCurrentUser } = loadTs('src/hooks/useCurrentUser.ts');
  console.log('isMmkvAvailable =', mmkv.isMmkvAvailable());

  // LoginScreen email/password path (RootNavigator not involved for this probe): setUserCache then emit.
  uc.setUserCache({ id: 'coach-A', email: 'a@x', role: 'coach' });
  await flush();
  console.log('AsyncStorage keys after setUserCache =', [...mem.keys()]);

  const seen = [];
  function Probe() { const u = useCurrentUser(); seen.push(u ? u.id : null); return null; }
  let root;
  const act = React.act || TestRenderer.act || (async (f) => { await f(); }); global.IS_REACT_ACT_ENVIRONMENT = true;
  await act(async () => { root = TestRenderer.create(React.createElement(Probe)); });
  await act(async () => { await flush(); });
  console.log('useCurrentUser() values observed on mount (shim, after setUserCache):', JSON.stringify(seen));
  await act(async () => { authEvents.emit('login'); await flush(); });
  console.log('after authEvents.emit("login") re-load:', JSON.stringify(seen));
  const resolved = seen.some((v) => v === 'coach-A');
  console.log('IDENTITY RESOLVED FOR HOOK CONSUMER =', resolved);
  console.log('=> useExtensionPairing hydration gate (needs userId) would', resolved ? 'open' : 'NEVER open; start() deferred indefinitely; panel stays in idle/minting spinner');
  await act(async () => { root.unmount(); });
  process.exit(resolved ? 0 : 3);
})().catch((e) => { console.error('PROBE ERROR', e); process.exit(2); });
