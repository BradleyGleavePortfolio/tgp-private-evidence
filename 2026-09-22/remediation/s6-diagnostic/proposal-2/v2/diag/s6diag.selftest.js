'use strict';
/**
 * S6 C5 V2 step 0 — instrument self-check (V2: two snapshots, re-arming shown by fresh asyncId). Plain Node, NO node_modules, NO Jest,
 * NO product code, ~1.5 s. Proves the inventory (a) sees a self-re-arming
 * await-timer chain that Jest's collector cannot attribute, (b) fingerprints a
 * long gc-style timer by delay + callback, (c) excludes unref'd timers, and then
 * releases everything it created so the process exits 0 on its own.
 * Exit 0 = instrument fit for the granted run; nonzero = do not run A–C.
 * NOT a product test. Written to $S6DIAG_LOG (or a temp file).
 */
const path = require('path');
const fs = require('fs');
const os = require('os');
if (!process.env.S6DIAG_LOG) process.env.S6DIAG_LOG = path.join(os.tmpdir(), 's6diag.selftest.' + process.pid + '.jsonl');
process.env.S6DIAG_STEP = process.env.S6DIAG_STEP || 'selftest';
const main = require(path.join(__dirname, 's6diag.main.js'));
main.install();

let hops = 0;
let stop = false;
async function reArmingChain() {
  // Mirrors asyncThrottle's `while (...) await new Promise(done => setTimeout(done, interval))`
  while (!stop) {
    await new Promise((done) => setTimeout(done, 100));
    hops++;
  }
}
function optionalRemove() {
  /* stand-in for Removable.scheduleGc callback */
}
const gcLike = setTimeout(optionalRemove, 5 * 60 * 1000);
const unrefd = setTimeout(() => {}, 5 * 60 * 1000);
unrefd.unref();
reArmingChain();

let early;
setTimeout(() => {
  early = main.snapshot('selftest-early');
}, 800);
setTimeout(() => {
  const snap = main.snapshot('selftest');
  const problems = [];
  // Re-arming chain: same signature (delay 100, native resolver) present in both snapshots with a DIFFERENT asyncId.
  const sig = (r) => r.type === 'Timeout' && r.delayMs === 100;
  const e = early && early.live.find(sig);
  const l = snap.live.find(sig);
  if (!e || !l) problems.push('100 ms chain timer missing in one of the two snapshots');
  else if (e.id === l.id) problems.push('100 ms chain timer kept the same asyncId across snapshots (not re-arming)');
  const chainTimer = snap.live.find((r) => r.type === 'Timeout' && r.delayMs === 100);
  const gc = snap.live.find((r) => r.type === 'Timeout' && r.delayMs === 300000);
  if (!chainTimer) problems.push('re-arming 100 ms chain not observed as a live refed Timeout');
  else {
    if (!chainTimer.top.some((f) => /s6diag\.selftest\.js/.test(f))) problems.push('chain timer stack lacks its creating frame');
    if (!chainTimer.chain.some((a) => a.type === 'PROMISE')) problems.push('chain ancestry did not cross a PROMISE boundary');
  }
  if (!gc) problems.push('300000 ms gc-like timer not observed');
  else if (gc.cbName !== 'optionalRemove') problems.push('gc-like timer callback name not recovered: ' + gc.cbName);
  if (snap.live.some((r) => r.hasRef === false)) problems.push('an unref\'d timer was counted as live');
  if (!snap.unrefd.some((u) => u.delayMs === 300000)) problems.push('unref\'d 300000 ms timer not listed under unrefd');
  if (hops < 5) problems.push('chain hops too few: ' + hops);
  // release everything we created; the process must now exit by itself (beforeExit fires)
  stop = true;
  clearTimeout(gcLike);
  clearTimeout(unrefd);
  process.stdout.write(
    `s6diag selftest: hops=${hops} liveRefed=${snap.liveRefedCount} byDelay=${JSON.stringify(snap.byDelay)} problems=${problems.length} log=${process.env.S6DIAG_LOG}\n`,
  );
  for (const p of problems) process.stdout.write('  PROBLEM: ' + p + '\n');
  process.exitCode = problems.length ? 3 : 0;
}, 1200);
