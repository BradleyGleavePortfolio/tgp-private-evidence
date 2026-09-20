// Independent per-module release transform. Not whole-app/native proof.
const fs=require('fs'),vm=require('vm'),assert=require('assert/strict');
const deps='/home/user/workspace/worktrees/s6/node_modules/';
const root='/home/user/workspace/worktrees/s6-final/';
const babel=require(deps+'@babel/core');
const keys=['EXPO_PUBLIC_FF_EXTENSION_IMPORT','EXPO_PUBLIC_FF_IMPORT_REVIEW'];
const source=fs.readFileSync(root+'src/config/featureFlags.ts','utf8');
function build(values) {
  keys.forEach((k,i)=>{if(values[i]===undefined)delete process.env[k];else process.env[k]=values[i];});
  const result=babel.transformSync(source,{
    filename:root+'src/config/featureFlags.ts',babelrc:false,configFile:false,
    presets:[[deps+'babel-preset-expo',{}]],
    caller:{name:'metro',bundler:'metro',platform:'android',isDev:false,isServer:false,isNodeModule:false,engine:'hermes'},
  }).code;
  const m={exports:{}};
  vm.runInNewContext(result,{module:m,exports:m.exports,process:{env:{}},__DEV__:false,require:id=>{throw Error(id);}});
  assert.equal(/process\.env\.EXPO_PUBLIC_|process\.env\[|expo\/virtual\/env/.test(result),false);
  return [m.exports.featureFlags.extensionImport,m.exports.featureFlags.importReview];
}
for(const [input,expected] of [
  [[undefined,undefined],[false,false]],[['true',undefined],[true,false]],
  [[undefined,'true'],[false,true]],[['true','true'],[true,true]],
  [['off','garbage'],[false,false]],
]) {
  const result=build(input);
  assert.deepEqual(result,expected);
  console.log(JSON.stringify({input:input.map(v=>v??'UNSET'),result,publicRuntimeResidue:false}));
}
const pkg=JSON.parse(fs.readFileSync(root+'package.json','utf8'));
const lock=JSON.parse(fs.readFileSync(root+'package-lock.json','utf8'));
for(const [kind,key] of [['dependencies','zod'],['devDependencies','@types/node'],['devDependencies','@babel/core']]) {
  assert.equal(pkg[kind][key],lock.packages[''][kind][key]);
  const p=lock.packages['node_modules/'+key];
  assert.ok(p.integrity && p.resolved);
  console.log(JSON.stringify({dependency:key,declared:pkg[kind][key],resolvedVersion:p.version,integrityPresent:true}));
}
assert.equal(lock.packages['node_modules/react-native-mmkv'],undefined);
console.log('MMKV absent from lockfile; current fallback is required, not hypothetical.');
