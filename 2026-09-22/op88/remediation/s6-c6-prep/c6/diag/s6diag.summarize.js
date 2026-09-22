'use strict';
/**
 * S6 C5 — summarize one step's inventory JSONL + Jest log into a short text
 * report. Plain Node, no dependencies. Read-only; prints to stdout.
 * Usage: node s6diag.summarize.js <inventory.jsonl> <jest.log> <step> <timeout-rc>
 */
const fs = require('fs');
const [, , inv, jestLog, step, rcArg] = process.argv;
const rc = Number(rcArg);
const lines = fs.existsSync(inv) ? fs.readFileSync(inv, 'utf8').split('\n').filter(Boolean) : [];
const evs = [];
for (const l of lines) {
  try {
    evs.push(JSON.parse(l));
  } catch {
    evs.push({ ev: 'unparseable', raw: l.slice(0, 200) });
  }
}
const jl = fs.existsSync(jestLog) ? fs.readFileSync(jestLog, 'utf8') : '';
const testsLine = (jl.match(/^Tests:.*$/m) || [''])[0];
const passed = Number((testsLine.match(/(\d+) passed/) || [0, 0])[1]);
const failed = Number((testsLine.match(/(\d+) failed/) || [0, 0])[1]);
const overlapping = (jl.match(/overlapping act/g) || []).length;
const didNotExit = /did not exit one second/.test(jl);
const snaps = evs.filter((e) => e.ev === 'snapshot');
const last = snaps[snaps.length - 1];
const mainStart = evs.find((e) => e.ev === 'main-start');
const exitEv = evs.find((e) => e.ev === 'exit');
const beforeExit = evs.some((e) => e.ev === 'beforeExit');
const sigterm = snaps.find((s) => s.label === 'SIGTERM');
const sandboxAfterAll = evs.find((e) => e.ev === 'sandbox-afterAll');
const deferred = evs.filter((e) => e.ev === 'sandbox-deferred');
const out = [];
out.push(`step=${step} timeout_rc=${rc} jest_pid=${mainStart ? mainStart.pid : 'n/a'} exit_event=${exitEv ? exitEv.code : 'NONE'} beforeExit=${beforeExit} snapshots=${snaps.map((s) => s.label).join(',') || 'NONE'}`);
out.push(`tests_line=${testsLine || 'NONE'} passed=${passed} failed=${failed} overlapping_act=${overlapping} did_not_exit_line=${didNotExit}`);
if (last) {
  out.push(`last_snapshot=${last.label} liveRefed=${last.liveRefedCount} byOwner=${JSON.stringify(last.byOwner)} byType=${JSON.stringify(last.byType)} byDelay=${JSON.stringify(last.byDelay)} activeResourcesInfo=${JSON.stringify(last.activeResourcesInfo)} nativeHandles=${JSON.stringify(last.nativeHandles)}`);
  for (const r of last.live) {
    out.push(`  live id=${r.id} type=${r.type} owner=${r.owner} root=${r.rootOwner} immediate=${r.immediate} delay=${r.delayMs} repeat=${r.repeat} cb=${r.cbName} age=${r.ageMs}ms cats=${(r.categories || []).join('|')}`);
    for (const f of (r.top || []).slice(0, 4)) out.push(`      ${f}`);
    out.push(`      chain: ${(r.chain || []).map((a) => `${a.type}#${a.id}${a.alive === false ? '†' : ''}${a.owner ? '(' + a.owner + ')' : ''}`).join(' <- ')}`);
  }
}
// Cross-snapshot chain evidence: same delay+cb appearing with fresh ids across ticks = self-re-arming loop.
if (snaps.length >= 2) {
  const sig = (r) => `${r.type}|${r.delayMs}|${r.cbName}|${(r.top && r.top[0]) || ''}`;
  const first = snaps[0].live.map(sig);
  const lastSigs = last.live.map(sig);
  const persistentSig = lastSigs.filter((s) => first.includes(s));
  const sameIds = last.live.filter((r) => snaps[0].live.some((q) => q.id === r.id)).length;
  out.push(`across_snapshots: persistent_signatures=${persistentSig.length} same_asyncIds=${sameIds} (signature persists but asyncId changes => re-arming chain; same id => single long timer)`);
}
if (sandboxAfterAll) out.push(`sandbox_afterAll: qcLoaded=${sandboxAfterAll.qcLoaded} queries=${sandboxAfterAll.qc ? JSON.stringify(sandboxAfterAll.qc.queries) : 'n/a'}`);
for (const d of deferred) out.push(`sandbox_deferred+${d.afterMs}ms: ${JSON.stringify(d.qc)}`);
// Verdict hints (mechanical; the human/parent decides)
const hints = [];
if (rc === 0 && beforeExit) hints.push('PROCESS_EXITED_ON_ITS_OWN');
if (rc === 124 || rc === 137) hints.push('HANG_PRESERVED_TIMEOUT_' + rc);
if (last) {
  if (last.liveRefedCount === 0 && !beforeExit && (rc === 124 || rc === 137)) hints.push('NO_LIVE_TRACKED_HANDLE_BUT_ALIVE=>runner/native-level (H-E) — inspect activeResourcesInfo/nativeHandles');
  const owners = Object.keys(last.byOwner);
  if (owners.includes('product')) hints.push('PRODUCT_OWNED_HANDLE_PRESENT');
  if (owners.includes('harness')) hints.push('HARNESS_OWNED_HANDLE_PRESENT');
  if (owners.includes('library-only')) hints.push('LIBRARY_ONLY_STACK_PRESENT=>read rootOwner/chain');
  if (last.byDelay && last.byDelay['600000']) hints.push('DELAY_600000=>queryClient(default gcTime 10min) Query alive after teardown');
  if (last.byDelay && last.byDelay['300000']) hints.push('DELAY_300000=>default QueryClient gcTime (5min) — harness tmp client class');
  if (last.byDelay && Object.keys(last.byDelay).some((d) => Number(d) > 0 && Number(d) <= 1000)) hints.push('DELAY_<=1000=>asyncThrottle/notifyManager class — check re-arming across ticks');
}
out.push(`hints=${hints.join(';') || 'none'}`);
process.stdout.write(out.join('\n') + '\n');
