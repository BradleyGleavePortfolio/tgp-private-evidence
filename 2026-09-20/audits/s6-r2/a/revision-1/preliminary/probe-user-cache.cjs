// Independent bounded offline probe. Executes unchanged candidate TypeScript
// through TypeScript transpileModule; no source writes, network or native work.
const fs = require('fs');
const vm = require('vm');
const cp = require('child_process');
const assert = require('assert/strict');
const root = '/home/user/workspace/worktrees/s6-final';
const ts = require('/home/user/workspace/worktrees/s6/node_modules/typescript');
const disk = new Map();
const storage = {
  getItem: async k => disk.get(k) ?? null,
  setItem: async (k, v) => { disk.set(k, v); },
  removeItem: async k => { disk.delete(k); },
  getAllKeys: async () => [...disk.keys()],
  removeMany: async ks => { ks.forEach(k => disk.delete(k)); },
};
let missingRequireCount = 0;
const modules = {};
function load(file) {
  const source = fs.readFileSync(root + '/' + file, 'utf8');
  const code = ts.transpileModule(source, { compilerOptions: {
    module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2020,
    esModuleInterop: true,
  }}).outputText;
  const module = { exports: {} };
  const sandbox = {
    module, exports: module.exports, process: { env: { NODE_ENV: 'production' } },
    require(id) {
      if (id === '@react-native-async-storage/async-storage') return storage;
      if (id === 'react-native') return { Platform: { OS: 'android' } };
      if (id === 'react-native-mmkv') { missingRequireCount++; throw Error('optional module absent'); }
      if (id === '../storage/mmkv') return modules.mmkv;
      throw Error('Unexpected dependency ' + id);
    },
  };
  vm.runInNewContext(code, sandbox, { filename: file });
  return module.exports;
}
(async () => {
  console.log('HEAD', cp.execFileSync('git', ['-C', root, 'rev-parse', 'HEAD', 'HEAD^{tree}'], {encoding:'utf8'}).trim());
  modules.mmkv = load('src/storage/mmkv.ts');
  const cache = load('src/lib/userCache.ts');
  console.log('production android optional require attempts', missingRequireCount);
  console.log('MMKV available', modules.mmkv.isMmkvAvailable());
  assert.equal(missingRequireCount, 1);
  assert.equal(modules.mmkv.isMmkvAvailable(), false);
  const user = {id:'synthetic-coach-A', email:'synthetic@example.invalid', role:'coach'};
  cache.setUserCache(user);
  await Promise.resolve();
  const freshRead = await cache.readUserCache();
  console.log('after setUserCache: persisted keys', [...disk.keys()]);
  console.log('readUserCacheSync', cache.readUserCacheSync(), 'readUserCache', freshRead);
  assert.equal(freshRead, null);
  assert.equal(await modules.mmkv.prefsStorage.getStringAsync('auth.user_data'), JSON.stringify(user));
  disk.clear();
  await storage.setItem('user_data', JSON.stringify(user));
  const bootstrapRead = await cache.readUserCache();
  const childRead = await cache.readUserCache();
  console.log('legacy scenario: root bootstrap id', bootstrapRead?.id, 'subsequent child identity', childRead);
  console.log('legacy scenario: remaining keys', [...disk.keys()]);
  assert.equal(bootstrapRead.id, user.id);
  assert.equal(childRead, null);
  // New JS module instance, same durable disk: restart does not repair it.
  const restartCache = load('src/lib/userCache.ts');
  console.log('post-process-restart identity', await restartCache.readUserCache());
  console.log('CONFIRMED: persisted auth user is unreadable through the actual userCache consumer in the shipped fallback.');
})().catch(e => { console.error(e); process.exitCode = 1; });
