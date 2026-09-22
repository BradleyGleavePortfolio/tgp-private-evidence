'use strict';
/**
 * S6 C6 — mechanical outcome classifier for the C-only hazard v5 discriminator.
 * Plain Node, no dependencies, read-only, runs in the RUNNER shell AFTER the Jest
 * child has exited (never inside Jest; not part of the frozen instrument set).
 * Usage: node c6classify.js <C.inventory.jsonl> <C.jest.log> <first_exit_rc> <how>
 * Prints key=value lines and exactly one `C6-OUTCOME=` line. The human/parent decides;
 * this only applies the outcomes pre-declared in S6_C5_REVIEW_B.md §8 / OP88_WAVE1 S6-C6-PREP:
 *   (i)   two residual 600000 ms refed timers at EVERY snapshot, both Query.removeObserver stacks, child did not exit
 *         => supports §3b attribution and hook-fix insufficiency
 *   (ii)  zero 600000 ms timers at every snapshot, child exited on its own (rc 0, beforeExit seen)
 *         => refutes the in-case attribution; hook fix sufficient
 *   (iii) five 600000 ms timers, child did not exit
 *         => cancelQueries-before-clear ordering hypothesis failed
 *   (iv)  Tests line != "6 passed, 6 total", or any "overlapping act", or mode line absent
 *         => perturbation divergence: STOP (evaluated first; count is then not interpreted)
 *   anything else => UNCLASSIFIED (report, do not relabel)
 */
const fs = require('fs');
const [, , inv, jestLog, rcArg, howArg] = process.argv;
const rc = Number(rcArg);
const how = String(howArg || '');
const lines = fs.existsSync(inv) ? fs.readFileSync(inv, 'utf8').split('\n').filter(Boolean) : [];
const evs = [];
for (const l of lines) {
  try {
    evs.push(JSON.parse(l));
  } catch {
    evs.push({ ev: 'unparseable' });
  }
}
const jl = fs.existsSync(jestLog) ? fs.readFileSync(jestLog, 'utf8') : '';
const testsLine = (jl.match(/^Tests:.*$/m) || [''])[0];
const sixOfSix = /^Tests:\s+6 passed, 6 total/m.test(jl);
const overlapping = (jl.match(/overlapping act/g) || []).length;
const modeLine = (jl.match(/\[mode=d51-singleton\]/g) || []).length;
const snaps = evs.filter((e) => e.ev === 'snapshot' && e.src === 'main');
const beforeExit = evs.some((e) => e.ev === 'beforeExit');
const exitEv = evs.find((e) => e.ev === 'exit');

function pathOf(timer) {
  const frames = (timer.top || []).join('\n');
  if (/Query\.removeObserver/.test(frames)) return 'R:removeObserver';
  if (/Query\.fetch\b/.test(frames)) return 'F:fetch';
  return 'unknown';
}
const out = [];
out.push(`c6_first_exit_rc=${rc} how=${how} beforeExit=${beforeExit} exit_event=${exitEv ? exitEv.code : 'NONE'}`);
out.push(`c6_tests_line=${testsLine || 'NONE'} six_of_six=${sixOfSix} overlapping_act=${overlapping} mode_line_count=${modeLine}`);
out.push(`c6_snapshots=${snaps.length}${snaps.length ? ' [' + snaps.map((s) => s.label).join(',') + ']' : ''}`);
const counts = [];
let lastTimers = [];
for (const s of snaps) {
  const timers = (s.live || []).filter((r) => r.type === 'Timeout' && String(r.delayMs) === '600000' && r.hasRef !== false);
  counts.push(timers.length);
  lastTimers = timers;
  const t = Date.parse(s.t);
  out.push(
    `c6_snapshot label=${s.label} count600000=${timers.length} activeResourcesInfo=${JSON.stringify(s.activeResourcesInfo)} ` +
      `timers=[${timers.map((r) => `${r.id}:${pathOf(r)}:created=${Number.isFinite(t) ? new Date(t - r.ageMs).toISOString() : 'n/a'}`).join(' ')}]`,
  );
}
const uniq = Array.from(new Set(counts));
const allR = lastTimers.length > 0 && lastTimers.every((r) => pathOf(r) === 'R:removeObserver');
const paths = lastTimers.map(pathOf);
out.push(`c6_counts_per_snapshot=[${counts.join(',')}] distinct=[${uniq.join(',')}] last_paths=[${paths.join(',')}]`);

let outcome;
if (!sixOfSix || overlapping > 0 || modeLine === 0) {
  outcome = 'iv-DIVERGENCE-STOP';
} else if (snaps.length === 0) {
  outcome = 'UNCLASSIFIED-NO-SNAPSHOT';
} else if (uniq.length === 1 && uniq[0] === 2 && how !== 'exited' && allR) {
  outcome = 'i-TWO-RESIDUAL-removeObserver-HANG';
} else if (uniq.length === 1 && uniq[0] === 2 && how !== 'exited') {
  outcome = 'UNCLASSIFIED-TWO-TIMERS-PATH-MISMATCH';
} else if (uniq.length === 1 && uniq[0] === 0 && how === 'exited' && rc === 0 && beforeExit) {
  outcome = 'ii-ZERO-CLEAN-EXIT';
} else if (uniq.length === 1 && uniq[0] === 5 && how !== 'exited') {
  outcome = 'iii-FIVE-ORDERING-HYPOTHESIS-FAILED';
} else {
  outcome = 'UNCLASSIFIED';
}
out.push(`C6-OUTCOME=${outcome}`);
process.stdout.write(out.join('\n') + '\n');
