// Builder scratch ONLY — a tiny vitest-compatible shim so the new spec can be
// smoke-run without installing dependencies (no slot). It is NOT vitest and
// its pass is NOT the gate evidence; the parent slot runs real vitest.
import { pathToFileURL } from "node:url";
import { isDeepStrictEqual } from "node:util";

const suites = [];
let current = { name: "", tests: [], before: [], after: [] };
export function describe(name, fn) {
  const parent = current;
  current = { name: `${parent.name} ${name}`.trim(), tests: [], before: [...parent.before], after: [...parent.after] };
  fn();
  suites.push(current);
  current = parent;
}
export function it(name, fn) {
  current.tests.push({ name, fn });
}
export function beforeEach(fn) {
  current.before.push(fn);
}
export function afterEach(fn) {
  current.after.push(fn);
}

// ---- fake timers ----------------------------------------------------------
const real = { setTimeout: globalThis.setTimeout, clearTimeout: globalThis.clearTimeout };
let fake = null;
function installFake() {
  fake = { now: 0, timers: new Map(), id: 0 };
  globalThis.setTimeout = (fn, ms = 0, ...args) => {
    const id = ++fake.id;
    fake.timers.set(id, { at: fake.now + Math.max(0, Number(ms) || 0), fn, args });
    return id;
  };
  globalThis.clearTimeout = (id) => {
    if (fake) fake.timers.delete(id);
    else real.clearTimeout(id);
  };
}
function uninstallFake() {
  fake = null;
  globalThis.setTimeout = real.setTimeout;
  globalThis.clearTimeout = real.clearTimeout;
}
const flush = async () => {
  for (let i = 0; i < 20; i++) await new Promise((r) => real.setTimeout(r, 0));
};
async function advanceTimersByTimeAsync(ms) {
  if (!fake) throw new Error("fake timers not installed");
  const target = fake.now + ms;
  await flush();
  for (;;) {
    const due = [...fake.timers.entries()].filter(([, t]) => t.at <= target).sort((a, b) => a[1].at - b[1].at);
    if (due.length === 0) break;
    const [id, t] = due[0];
    fake.timers.delete(id);
    fake.now = t.at;
    t.fn(...t.args);
    await flush();
  }
  fake.now = target;
  await flush();
}

// ---- mocks / globals --------------------------------------------------------
const spies = [];
const stubs = [];
function makeFn(impl) {
  const f = (...args) => {
    f.mock.calls.push(args);
    return f.impl ? f.impl(...args) : undefined;
  };
  f.mock = { calls: [] };
  f.impl = impl;
  f.mockImplementation = (i) => ((f.impl = i), f);
  f.mockResolvedValue = (v) => ((f.impl = async () => v), f);
  f.mockRejectedValue = (v) => ((f.impl = async () => { throw v; }), f);
  f.mockRestore = () => f.restore && f.restore();
  return f;
}
let moduleGen = 0;
export const vi = {
  fn: (impl) => makeFn(impl),
  spyOn(obj, key) {
    const original = obj[key];
    const f = makeFn((...a) => original.apply(obj, a));
    f.restore = () => (obj[key] = original);
    obj[key] = f;
    spies.push(f);
    return f;
  },
  restoreAllMocks() {
    while (spies.length) spies.pop().restore();
  },
  useFakeTimers: installFake,
  useRealTimers: uninstallFake,
  advanceTimersByTimeAsync,
  resetModules() {
    moduleGen++;
    if (globalThis.__shimGen) Atomics.store(globalThis.__shimGen, 0, moduleGen);
  },
  stubGlobal(name, value) {
    stubs.push([name, globalThis[name], Object.prototype.hasOwnProperty.call(globalThis, name)]);
    globalThis[name] = value;
  },
  unstubAllGlobals() {
    while (stubs.length) {
      const [name, prev, had] = stubs.pop();
      if (had) globalThis[name] = prev;
      else delete globalThis[name];
    }
  },
};
// Spec files do `await import("../shared/session.js")`; module cache busting
// is achieved by the loader hook appending ?gen=N. Export for the hook.
export const currentModuleGen = () => moduleGen;
globalThis.__shimModuleGen = currentModuleGen;

// ---- expect -----------------------------------------------------------------
class AssertionError extends Error {}
function fail(msg) {
  throw new AssertionError(msg);
}
function matchers(actual, negate = false) {
  const check = (ok, msg) => {
    if (Boolean(ok) === negate) fail(`${negate ? "NOT " : ""}${msg}`);
  };
  const m = {
    toBe: (v) => check(Object.is(actual, v), `expected ${String(actual)} toBe ${String(v)}`),
    toEqual: (v) => check(isDeepStrictEqual(actual, v), `expected ${JSON.stringify(actual)} toEqual ${JSON.stringify(v)}`),
    toBeNull: () => check(actual === null, `expected ${String(actual)} toBeNull`),
    toBeInstanceOf: (c) => check(actual instanceof c, `expected instanceof ${c.name}`),
    toContain: (v) => check(Array.isArray(actual) ? actual.includes(v) : String(actual).includes(v), `expected ${JSON.stringify(actual)} toContain ${JSON.stringify(v)}`),
    toSatisfy: (p) => check(p(actual), `expected value to satisfy predicate`),
    toThrow: (msg) => {
      let threw = null;
      try { actual(); } catch (e) { threw = e; }
      check(threw && (!msg || String(threw.message).includes(msg)), `expected to throw ${msg ?? ""}`);
    },
    toHaveBeenCalled: () => check(actual.mock.calls.length > 0, `expected mock to have been called`),
    toHaveBeenCalledTimes: (n) => check(actual.mock.calls.length === n, `expected ${n} calls, got ${actual.mock.calls.length}`),
    toHaveBeenCalledExactlyOnceWith: (...args) =>
      check(actual.mock.calls.length === 1 && isDeepStrictEqual(actual.mock.calls[0], args), `expected exactly once with ${JSON.stringify(args)}, got ${JSON.stringify(actual.mock.calls)}`),
  };
  return m;
}
export function expect(actual) {
  const m = matchers(actual);
  m.not = matchers(actual, true);
  m.resolves = new Proxy({}, { get: (_t, key) => async (...a) => matchers(await actual)[key](...a) });
  m.rejects = new Proxy({}, {
    get: (_t, key) => async (...a) => {
      let err, rejected = false;
      try { await actual; } catch (e) { rejected = true; err = e; }
      if (!rejected) fail("expected promise to reject");
      return matchers(err)[key](...a);
    },
  });
  return m;
}

// ---- runner -----------------------------------------------------------------
export async function run(specPath) {
  await import(pathToFileURL(specPath).href);
  let passed = 0, failed = 0;
  const failures = [];
  for (const suite of suites) {
    for (const t of suite.tests) {
      try {
        for (const b of suite.before) await b();
        await t.fn();
        passed++;
        console.log(`  ok   ${suite.name} > ${t.name}`);
      } catch (e) {
        failed++;
        failures.push({ test: `${suite.name} > ${t.name}`, error: String(e && e.stack || e) });
        console.log(`  FAIL ${suite.name} > ${t.name}\n       ${e && e.message}`);
      } finally {
        for (const a of suite.after) await a();
      }
    }
  }
  console.log(JSON.stringify({ passed, failed, failures }, null, 2));
  return failed === 0;
}
