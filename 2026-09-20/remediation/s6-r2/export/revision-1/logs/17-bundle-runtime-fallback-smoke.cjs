// Executes the storage/mmkv module factory EXACTLY as serialized in the exported Android bundle
// (extracted to 16-bundle-module-1120-storage-mmkv.extracted.js) under a minimal Metro-like `require`
// that behaves as metro-runtime does for an unresolved optional dependency: `require(null)` throws.
const fs = require('fs');
const src = fs.readFileSync(__dirname + '/16-bundle-module-1120-storage-mmkv.extracted.js', 'utf8');
const calls = [];
const asyncStorageStub = { default: {
  getItem: async (k) => { calls.push(['getItem', k]); return null; },
  setItem: async (k, v) => { calls.push(['setItem', k, v]); },
  removeItem: async (k) => { calls.push(['removeItem', k]); },
  getAllKeys: async () => { calls.push(['getAllKeys']); return ['prefs:a', 'cache:b', 'secure:c', 'other']; },
  removeMany: async (ks) => { calls.push(['removeMany', ks.join(',')]); },
}, __esModule: true };
let captured = null;
global.__d = (factory, id, deps) => { captured = { factory, id, deps }; };
eval(src);
console.log('module id', captured.id, 'deps', JSON.stringify(captured.deps));
const requireLog = [];
const r = (dep, name) => {
  requireLog.push([dep, name]);
  if (dep == null) throw Error('Requiring unknown module "' + dep + '".'); // metro-runtime unknownModuleError
  if (dep === captured.deps[0]) return asyncStorageStub;
  if (dep === captured.deps[1]) return { Platform: { OS: 'android' } };
  throw new Error('unexpected dep ' + dep);
};
const mod = { exports: {} };
captured.factory(global, r, null, null, mod, mod.exports, captured.deps);
const e = mod.exports;
console.log('require calls:', JSON.stringify(requireLog));
console.log('isMmkvAvailable():', e.isMmkvAvailable());
console.log('prefsStorage.getString sync:', e.prefsStorage.getString('user'));
(async () => {
  await e.prefsStorage.set('user', 'A');
  await e.secureStorage.set('pin', 'h');
  await e.clearAllStorage();
  console.log('asyncstorage calls:', JSON.stringify(calls));
  const ok = e.isMmkvAvailable() === false && calls.some(c => c[0]==='setItem' && c[1]==='prefs:user') && calls.some(c => c[0]==='removeMany' && c[1].includes('prefs:a') && !c[1].includes('other'));
  console.log(ok ? 'RUNTIME_FALLBACK_SMOKE=PASS' : 'RUNTIME_FALLBACK_SMOKE=FAIL');
  process.exit(ok ? 0 : 1);
})();
