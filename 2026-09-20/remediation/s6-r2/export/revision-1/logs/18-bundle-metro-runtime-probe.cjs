// Production-mode probe with AUTHENTIC Metro runtime semantics: loads metro-runtime's real `require` polyfill
// (the same one prepended to the exported bundle), registers stub modules for the two resolved deps,
// registers the storage/mmkv module factory EXACTLY as serialized in the export (16-...extracted.js),
// then __r() it. Metro's runtime throws its own unknownModuleError for the null dependency id.
const fs = require('fs');
const vm = require('vm');
const NM = '/home/user/workspace/worktrees/s6/node_modules';
const polyfill = fs.readFileSync(NM + '/metro-runtime/src/polyfills/require.js', 'utf8');
const modSrc = fs.readFileSync(__dirname + '/16-bundle-module-1120-storage-mmkv.extracted.js', 'utf8');
const depsMatch = modSrc.match(/\},(\d+),\[([^\]]*)\]\)\s*$/);
const [asyncStorageId, reactNativeId, mmkvId] = depsMatch[2].split(',').map(s => s === 'null' ? null : Number(s));
const calls = [];
const ctx = { console, calls, process: { env: { NODE_ENV: 'production' } }, __DEV__: false, __METRO_GLOBAL_PREFIX__: '', setTimeout, clearTimeout };
ctx.global = ctx; ctx.globalThis = ctx;
vm.createContext(ctx);
vm.runInContext(polyfill, ctx, { filename: 'metro-runtime/require.js' });
vm.runInContext(`
  __d(function(g,r,i,a,m,e,d){ e.__esModule = true; e.default = {
    getItem: async (k) => { calls.push(['getItem', k]); return null; },
    setItem: async (k, v) => { calls.push(['setItem', k, v]); },
    removeItem: async (k) => { calls.push(['removeItem', k]); },
    getAllKeys: async () => { calls.push(['getAllKeys']); return ['prefs:a','cache:b','secure:c','other']; },
    removeMany: async (ks) => { calls.push(['removeMany', ks.join(',')]); },
  }; }, ${asyncStorageId}, []);
  __d(function(g,r,i,a,m,e,d){ e.Platform = { OS: 'android' }; }, ${reactNativeId}, []);
`, ctx);
vm.runInContext(modSrc, ctx, { filename: 'bundle-module-1120.js' });
console.log('deps: asyncStorage=%s reactNative=%s mmkv=%s', asyncStorageId, reactNativeId, mmkvId);
let e;
try { e = vm.runInContext('__r(' + depsMatch[1] + ')', ctx); }
catch (err) { console.log('MODULE_INIT_THREW:', err.message); process.exit(2); }
console.log('module initialised without throwing; isMmkvAvailable():', e.isMmkvAvailable());
console.log('prefsStorage.getString("user") sync:', e.prefsStorage.getString('user'));
// what Metro's runtime does for require(null): reproduce visibly for the log
try { vm.runInContext('__r(null)', ctx); } catch (err) { console.log('metro-runtime require(null) throws:', err.message.split('\n')[0]); }
(async () => {
  await e.prefsStorage.set('user', 'A'); await e.cacheStorage.set('c', 1); await e.secureStorage.set('pin', 'h');
  await e.clearAllStorage();
  console.log('asyncstorage calls:', JSON.stringify(calls));
  const ok = mmkvId === null && e.isMmkvAvailable() === false
    && calls.some(c => c[0] === 'setItem' && c[1] === 'prefs:user') && calls.some(c => c[0] === 'setItem' && c[1] === 'secure:pin')
    && calls.filter(c => c[0] === 'removeMany').length === 3 && !calls.some(c => c[0] === 'removeMany' && c[1].includes('other'));
  console.log(ok ? 'METRO_RUNTIME_PROBE=PASS' : 'METRO_RUNTIME_PROBE=FAIL');
  process.exit(ok ? 0 : 1);
})();
