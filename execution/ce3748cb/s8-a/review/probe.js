// Reviewer probes against the independently built dist (scratch copy of 35eeb6ce).
const path = require('path');
const fs = require('fs'); const os = require('os');
const dist = process.argv[2];
const ms = require(path.join(dist, 'scout/reconstruct/mapping-spec'));
const reg = require(path.join(dist, 'scout/reconstruct/source-mapper-registry'));
const fam = require(path.join(dist, 'scout/reconstruct/families'));
const r = (x) => ({ paths: [x], coerce: 'string' });
const ent = { clientSourceId: r(['c']), label: r(['l']) };
const base = () => ({ specVersion: 1, sourcePlatform: 'probe_x', steps: { a: 'workouts' }, families: { workouts: { clientSourceId: r(['c']), label: r(['l']) } } });
const cases = {
  ok: base(),
  unknownTopKey: { ...base(), extra: 1 },
  emailField: { ...base(), families: { workouts: { ...ent, email: r(['e']) } } },
  billingFamily: { ...base(), families: { billing: ent } },
  programsFamily: { ...base(), families: { programs: ent } },
  badCoerce: { ...base(), families: { workouts: { clientSourceId: { paths: [['c']], coerce: 'number' }, label: r(['l']) } } },
  emptyPaths: { ...base(), families: { workouts: { clientSourceId: { paths: [], coerce: 'string' }, label: r(['l']) } } },
  emptyKey: { ...base(), families: { workouts: { clientSourceId: { paths: [['']], coerce: 'string' }, label: r(['l']) } } },
  specV2: { ...base(), specVersion: 2 },
  platformUpper: { ...base(), sourcePlatform: 'TrueCoach' },
  stepToUnmappedFamily: { ...base(), steps: { a: 'client_history' } },
  fanInNoDecl: { ...base(), steps: { a: 'workouts', b: 'workouts' } },
  fanInDecl: { ...base(), steps: { a: 'workouts', b: 'workouts' }, sharedIdSpaces: { workouts: ['b', 'a'] } },
  fanInPartial: { ...base(), steps: { a: 'workouts', b: 'workouts', c: 'workouts' }, sharedIdSpaces: { workouts: ['a', 'b'] } },
  fanInExtraStep: { ...base(), steps: { a: 'workouts', b: 'workouts' }, sharedIdSpaces: { workouts: ['a', 'b', 'z'] } },
  staleDecl: { ...base(), sharedIdSpaces: { workouts: ['a'] } },
  dupDeclMembers: { ...base(), steps: { a: 'workouts', b: 'workouts' }, sharedIdSpaces: { workouts: ['a', 'b', 'a'] } },
  declNotArray: { ...base(), sharedIdSpaces: { workouts: 'a' } },
  protoDeclJSON: JSON.parse('{"specVersion":1,"sourcePlatform":"probe_x","steps":{"a":"workouts"},"families":{"workouts":{"clientSourceId":{"paths":[["c"]],"coerce":"string"},"label":{"paths":[["l"]],"coerce":"string"}}},"sharedIdSpaces":{"__proto__":["a"]}}'),
  protoStepFanInJSON: JSON.parse('{"specVersion":1,"sourcePlatform":"probe_x","steps":{"__proto__":"workouts","a":"workouts"},"families":{"workouts":{"clientSourceId":{"paths":[["c"]],"coerce":"string"},"label":{"paths":[["l"]],"coerce":"string"}}}}'),
  notObject: [],
};
const out = {};
for (const [k, v] of Object.entries(cases)) {
  try { const s = ms.parseSourceMappingSpec(v, k); out[k] = 'ACCEPTED steps=' + JSON.stringify(Object.keys(s.steps)) + (k==='protoStepFanInJSON' ? ' resolve(__proto__)=' + JSON.stringify(ms.resolveStep(s, '__proto__')) : ''); }
  catch (e) { out[k] = 'REJECTED: ' + e.message; }
}
console.log(JSON.stringify(out, null, 1));
// loader fail-closed
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 's8a-probe-'));
const tryLoad = (label, d) => { try { reg.loadSourceMappingSpecs(d); console.log(label, 'LOADED'); } catch (e) { console.log(label, 'THREW:', e.message); } };
tryLoad('missingDir', path.join(tmp, 'nope'));
tryLoad('emptyDir', tmp);
fs.writeFileSync(path.join(tmp, 'a.json'), JSON.stringify(base())); fs.writeFileSync(path.join(tmp, 'b.json'), JSON.stringify(base()));
tryLoad('duplicatePlatform', tmp);
fs.unlinkSync(path.join(tmp, 'b.json')); fs.writeFileSync(path.join(tmp, 'b.json'), '{not json');
tryLoad('malformedJson', tmp);
// dist registry + family map
const R = reg.buildSourceMapperRegistry();
console.log('distRegistry', [...R.keys()].join(','));
const F = fam.buildFamilyRegistry();
const row = (p, id, payload) => ({ source_platform: p, source_id: id, payload });
console.log('tc clients', JSON.stringify(F.get('clients').map(row('truecoach', ' 7 ', { name: ' Dana ' }))));
console.log('tc workouts', JSON.stringify(F.get('workouts').map(row('truecoach', '9', { client_id: null, clientId: 8, title: '', name: 'x' }))));
console.log('beta hist', JSON.stringify(F.get('client_history').map(row('conformance_beta', '1', { links: { athlete: { ref: 'a1' } }, summary: 'S' }))));
console.log('unsupported', JSON.stringify(F.get('clients').map(row('trainerize', '1', {}))));
console.log('blank id', JSON.stringify(F.get('workouts').map(row('truecoach', ' \t', {}))));
console.log('notes', JSON.stringify(reg.resolveStagedFamily(R, 'truecoach', 'notes')));
for (const f of fs.readdirSync(path.join(dist, 'scout/reconstruct/sources'))) {
  const a = fs.readFileSync(path.join(dist, 'scout/reconstruct/sources', f)); const b = fs.readFileSync(path.join(dist, '../src/scout/reconstruct/sources', f));
  console.log('asset', f, Buffer.compare(a, b) === 0 ? 'byte-equal' : 'DIFFERS');
}
