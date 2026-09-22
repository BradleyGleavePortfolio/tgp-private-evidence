#!/usr/bin/env node
// S5 R4 dependency-free static wiring probe for the teardown gate (A-01). NOT EXECUTED by the builder
// beyond `node --check`; parent-granted run only. Node 20 only; no node_modules, no Jest, no DB.
// It reads two spec texts — the CANDIDATE (worktree file) and the PREDECESSOR (`git show 143d451e:...`)
// — and asserts the control-flow shape that the Jest-level control (ctl-teardown-gate.sh, needs
// node_modules) later exercises for real. A static probe cannot prove Jest hook semantics; it proves
// the candidate text has the gate in the right place and the predecessor text has none.
// Usage: node probe-spec-wiring.cjs <worktree> [predecessor-commit]
const { execFileSync } = require('child_process');
const { readFileSync } = require('fs');
const { resolve } = require('path');
const worktree = process.argv[2] || '/home/user/workspace/worktrees/s5-r4';
const pred = process.argv[3] || '143d451ead6ccdbebd92ca3031ba7a89867d6cfc';
const rel = 'test/rls-g2-pg17-etq0.spec.ts';
const candidate = readFileSync(resolve(worktree, rel), 'utf8');
const predecessor = execFileSync('git', ['-C', worktree, 'show', `${pred}:${rel}`], { encoding: 'utf8' });
let pass = 0, fail = 0;
const check = (id, ok, text) => { ok ? pass++ : fail++; console.log(`${ok ? 'PASS' : 'FAIL'} ${id} ${text}`); };
const block = (src, open) => { // text of the hook body starting at `open` (e.g. "beforeAll(() => {") up to the matching "});" at column 0
  const i = src.indexOf(open); if (i < 0) return null;
  const j = src.indexOf('\n});', i); return j < 0 ? null : src.slice(i, j + 4);
};
// Every sql()/sqlAdmin() call argument (first backtick or quote literal) in a text, in order.
const sqlCalls = (text) => {
  const out = []; const re = /\b(sql|sqlAdmin)\(\s*(`|')/g; let m;
  while ((m = re.exec(text))) {
    const q = m[2]; const start = re.lastIndex; const end = text.indexOf(q, start);
    out.push({ fn: m[1], stmt: text.slice(start, end < 0 ? start + 80 : end).trim() });
  }
  return out;
};
const mutating = (stmt) => /^(\s*)(GRANT|ALTER|DELETE|INSERT|UPDATE|DROP|CREATE|TRUNCATE|COMMENT)\b/i.test(stmt) || /;\s*(GRANT|ALTER|DELETE|INSERT|UPDATE|DROP|CREATE|TRUNCATE)\b/i.test(stmt);

// ---- Candidate
const cBefore = block(candidate, 'beforeAll(() => {'); const cAfter = block(candidate, 'afterAll(() => {');
check('C1', cBefore && cAfter, 'candidate has one top-level beforeAll and afterAll block');
check('C2', /^let teardownAuthorized = false;$/m.test(candidate), 'candidate declares `let teardownAuthorized = false` at module scope');
const flagAt = cBefore ? cBefore.indexOf('teardownAuthorized = true;') : -1;
check('C3', flagAt > 0, 'candidate sets teardownAuthorized = true inside beforeAll');
if (cBefore && flagAt > 0) {
  const pre = cBefore.slice(0, flagAt), post = cBefore.slice(flagAt);
  const preCalls = sqlCalls(pre), postCalls = sqlCalls(post);
  check('C4', preCalls.length > 0 && preCalls.every((c) => !mutating(c.stmt) && /^SELECT\b/i.test(c.stmt)), `every sql/sqlAdmin before the flag is a SELECT (${preCalls.length} calls: ${preCalls.map((c) => c.stmt.split(/\s+/).slice(0, 2).join(' ')).join(' | ')})`);
  check('C5', /^\s*expect\(/m.test(pre) && !/^\s*expect\(sql\(`\s*(GRANT|ALTER|DELETE)/m.test(pre), 'read-only expect gates precede the flag');
  check('C6', postCalls.some((c) => /^GRANT/i.test(c.stmt)) && postCalls.some((c) => /^ALTER TABLE/i.test(c.stmt)) && /resetData\(\);/.test(post), 'the first mutation (GRANT), ALTER TABLE and resetData() all follow the flag');
  const lastExpect = pre.lastIndexOf('expect('); const firstMutation = cBefore.search(/\bsql\(`\s*GRANT/);
  check('C7', lastExpect < flagAt && flagAt < firstMutation, 'flag is after the last read-only expect and before the first mutating statement');
}
if (cAfter) {
  const guardAt = cAfter.indexOf('if (!teardownAuthorized) {'); const firstCall = cAfter.search(/\b(sql|resetData)\(/);
  check('C8', guardAt > 0 && guardAt < firstCall, 'afterAll checks the flag before its first sql()/resetData() call');
  check('C9', /return;\s*\n\s*}/.test(cAfter.slice(guardAt, firstCall)), 'the refused branch returns without issuing SQL');
  check('C10', cAfter.includes("PG17_TEARDOWN_SKIPPED"), 'refusal is recorded as PG17_TEARDOWN_SKIPPED (no silent skip)');
  const aCalls = sqlCalls(cAfter.slice(firstCall));
  check('C11', aCalls.length === 2 && /^ALTER TABLE "Person" DROP CONSTRAINT/.test(aCalls[0].stmt) && /^DELETE FROM "ScoutImport"/.test(aCalls[1].stmt) && /resetData\(\);/.test(cAfter), 'authorized teardown body is unchanged: DROP CONSTRAINT x2, resetData(), DELETE ScoutImport');
}
// Assertion preservation: every `expect(` line of the predecessor spec still appears in the candidate.
const expectLines = (s) => s.split('\n').filter((l) => /^\s*expect\(/.test(l)).map((l) => l.trim());
const pe = expectLines(predecessor), ce = new Set(expectLines(candidate));
const missing = pe.filter((l) => !ce.has(l));
check('C12', missing.length === 0 && pe.length > 0, `all ${pe.length} predecessor expect( lines present in candidate (missing: ${missing.length})`);
check('C13', (candidate.match(/^\s*(it|test)\(/gm) || []).length === (predecessor.match(/^\s*(it|test)\(/gm) || []).length, `test case count unchanged (${(predecessor.match(/^\s*(it|test)\(/gm) || []).length})`);

// ---- Predecessor (the frozen defect, statically)
const pAfter = block(predecessor, 'afterAll(() => {');
check('P1', pAfter && !pAfter.includes('teardownAuthorized'), 'PREDECESSOR afterAll has no authorization check (frozen S5-R3-A-01)');
check('P2', pAfter && sqlCalls(pAfter).some((c) => mutating(c.stmt)) && /resetData\(\);/.test(pAfter), 'PREDECESSOR afterAll unconditionally issues DDL/DML (DROP CONSTRAINT, resetData DELETEs)');
console.log(`SUMMARY pass=${pass} fail=${fail}`);
process.exit(fail === 0 ? 0 : 1);
