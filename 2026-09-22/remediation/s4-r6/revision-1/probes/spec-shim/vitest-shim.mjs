// Minimal, dependency-free stand-in for the vitest API surface used by the
// targeted describe block. NOT vitest: no reporter parity, no fake timers, no
// snapshot support. Any assertion failure throws with a descriptive message.
import { isDeepStrictEqual } from "node:util";

const suites = [];
let current = null;
export function describe(name, fn) {
  const s = { name, tests: [], afterEach: [] };
  suites.push(s);
  const prev = current; current = s; fn(); current = prev;
}
export function it(name, fn) { (current ?? rootSuite()).tests.push({ name, fn }); }
export const test = it;
const root = { name: "(root)", tests: [], afterEach: [] };
function rootSuite() { return root; }
export function afterEach(fn) { (current ?? root).afterEach.push(fn); }
export function beforeEach() {}
export function afterAll() {}
export function beforeAll() {}
function fail(msg) { const e = new Error(msg); e.name = "AssertionError"; throw e; }
function fmt(v) { try { return JSON.stringify(v); } catch { return String(v); } }
export function expect(actual) {
  const make = (neg) => ({
    toBe: (e) => { if ((Object.is(actual, e)) === neg) fail(`expected ${fmt(actual)} ${neg?"not ":""}toBe ${fmt(e)}`); },
    toEqual: (e) => { if (isDeepStrictEqual(actual, e) === neg) fail(`expected ${fmt(actual)} ${neg?"not ":""}toEqual ${fmt(e)}`); },
    toHaveLength: (n) => { if ((actual?.length === n) === neg) fail(`expected length ${fmt(actual?.length)} ${neg?"not ":""}toBe ${n}`); },
    toBeDefined: () => { if ((actual !== undefined) === neg) fail(`expected ${neg?"undefined":"defined"}`); },
    toBeNull: () => { if ((actual === null) === neg) fail(`expected ${fmt(actual)} ${neg?"not ":""}toBeNull`); },
    toBeGreaterThan: (n) => { if ((actual > n) === neg) fail(`expected ${fmt(actual)} ${neg?"not ":""}> ${n}`); },
    toContain: (v) => { if ((Array.isArray(actual) ? actual.includes(v) : String(actual).includes(v)) === neg) fail(`expected ${fmt(actual)} ${neg?"not ":""}toContain ${fmt(v)}`); },
    toBeGreaterThanOrEqual: (n) => { if ((actual >= n) === neg) fail(`expected ${fmt(actual)} ${neg?"not ":""}>= ${n}`); },
    toBeTruthy: () => { if ((!!actual) === neg) fail(`expected truthy`); },
  });
  return { ...make(false), not: make(true) };
}
const stubbed = new Map();
export const vi = {
  fn: (impl) => { const f = (...a) => impl ? impl(...a) : undefined; f.mock = { calls: [] }; return f; },
  resetModules: () => { Atomics.add(globalThis.__shimGen, 0, 1); },
  stubGlobal: (name, value) => { if (!stubbed.has(name)) stubbed.set(name, globalThis[name]); globalThis[name] = value; },
  unstubAllGlobals: () => { for (const [k, v] of stubbed) globalThis[k] = v; stubbed.clear(); },
  useRealTimers: () => {},
  useFakeTimers: () => { fail("fake timers unsupported in shim"); },
};
// Runner: filter describe titles by SHIM_FILTER substring.
export async function __run() {
  const filter = process.env.SHIM_FILTER ?? "";
  const out = { suites: [], passed: 0, failed: 0, skipped: 0 };
  for (const s of suites) {
    if (filter && !s.name.includes(filter)) { out.skipped += s.tests.length; continue; }
    for (const t of s.tests) {
      const began = performance.now();
      let status = "pass", error = null;
      try { await t.fn(); } catch (e) { status = "fail"; error = String(e && e.stack || e).split("\n").slice(0, 4).join(" | "); }
      for (const a of [...s.afterEach, ...root.afterEach]) { try { await a(); } catch {} }
      out[status === "pass" ? "passed" : "failed"] += 1;
      out.suites.push({ suite: s.name, test: t.name, status, error, ms: Math.round(performance.now() - began) });
    }
  }
  return out;
}
