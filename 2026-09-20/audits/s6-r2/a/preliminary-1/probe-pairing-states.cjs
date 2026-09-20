// Bounded offline real-React probe of unchanged useExtensionPairing.
// Transport, platform, telemetry and resolved identity are controlled.
const fs = require('fs');
const vm = require('vm');
const assert = require('assert/strict');
const deps = '/home/user/workspace/worktrees/s6/node_modules/';
const root = '/home/user/workspace/worktrees/s6-final/';
const ts = require(deps + 'typescript');
const React = require(deps + 'react');
const renderer = require(deps + 'react-test-renderer');
global.IS_REACT_ACT_ENVIRONMENT = true;
const { act } = renderer;
const disk = new Map();
const timers = new Map();
let nextTimer = 1;
let current;
let initCalls = 0;
let statusCalls = 0;
const api = {
  init: async () => { initCalls++; return {data:{pairing_code:'123456',expires_at:'server-stamp'}}; },
  status: async () => { statusCalls++; throw Error('status transport unavailable'); },
};
const mocks = {
  react: React,
  'react-native': {AppState:{addEventListener:()=>({remove(){}})}},
  axios: {AxiosError: class AxiosError extends Error {}},
  '../api/extensionPairApi': {extensionPairApi:api},
  '../types/extensionImport': {decodePairStatus: s => ['pending','paired','expired'].includes(s)?s:'unknown'},
  '../config/featureFlags': {featureFlags:{extensionImport:true}},
  '../analytics/posthog.service': {track(){}},
  '../analytics/events': {AnalyticsEvents:{}},
  './useCurrentUser': {useCurrentUser:()=>({id:'synthetic-A'})},
  '../utils/idempotency': {generateIdempotencyKey:()=> 'synthetic-intent'},
  '../utils/correlation': {extractRequestId:()=>null},
  '../utils/logger': {logger:{warn(){}}},
  '../storage/importPairingMirror': {
    IMPORT_PAIRING_MIRROR_VERSION:1,
    readImportPairingMirror:async id => disk.get(id) ?? null,
    writeImportPairingMirror:async session => { disk.set(session.userId,session); },
    clearImportPairingMirror:async id => { disk.delete(id); },
  },
};
const src = fs.readFileSync(root+'src/hooks/useExtensionPairing.ts','utf8');
const code = ts.transpileModule(src,{compilerOptions:{
  module:ts.ModuleKind.CommonJS,target:ts.ScriptTarget.ES2020,esModuleInterop:true,
}}).outputText;
const moduleBox = {exports:{}};
vm.runInNewContext(code,{
  module:moduleBox,exports:moduleBox.exports,
  require:id=>{if(id in mocks)return mocks[id];throw Error('unexpected '+id);},
  setTimeout:fn=>{const id=nextTimer++;timers.set(id,fn);return id;},
  clearTimeout:id=>timers.delete(id),
});
function Component() { current=moduleBox.exports.useExtensionPairing('trainerize',true);return null; }
async function tick() {
  assert.ok(timers.size);
  const [id,fn]=timers.entries().next().value;
  timers.delete(id);
  await act(async()=>{await fn();});
}
(async()=>{
  let tree;
  await act(async()=>{tree=renderer.create(React.createElement(Component));});
  await act(async()=>{await current.start();});
  assert.equal(current.status,'waiting');
  console.log('initial state',current.status,'code issued',Boolean(current.code),'init calls',initCalls);
  // Extension may redeem at this point. The hook has no observation of it
  // because every mobile status transport request will fail.
  for(let n=0;n<5;n++)await tick();
  console.log('after five status transport failures',current.status,'status calls',statusCalls);
  assert.equal(current.status,'failed');
  console.log('panel failed copy:', /message: '([^']*Nothing was imported[^']*)'/.exec(
    fs.readFileSync(root+'src/components/coach/ExtensionPairingPanel.tsx','utf8'))[1]);
  await act(async()=>{await current.retry();});
  assert.equal(current.status,'waiting');
  await act(async()=>{current.cancel();});
  assert.equal(current.status,'cancelled');
  console.log('after local cancel',current.status,'available transport methods',Object.keys(api).join(','));
  console.log('panel cancelled copy:', /message: '([^']*No import was started[^']*)'/.exec(
    fs.readFileSync(root+'src/components/coach/ExtensionPairingPanel.tsx','utf8'))[1]);
  await act(async()=>{tree.unmount();});
  assert.equal(timers.size,0);
  console.log('CONFIRMED: failure and local cancellation terminal paths have no server import-outcome/revocation evidence.');
})().catch(e=>{console.error(e);process.exitCode=1;});
