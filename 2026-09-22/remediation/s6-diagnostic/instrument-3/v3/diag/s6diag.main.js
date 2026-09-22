'use strict';
/**
 * S6 C5 V3 — main-process (Jest parent, --runInBand) async-resource inventory.
 * V2 change vs V1 (00e80262…): init hook named `initHook` and used as the
 * captureStack skip function; V1 referenced an undefined `init` and threw
 * ReferenceError at the first hook init (selftest receipt logs/selftest/).
 * V3 change vs V2 (ee00ef3f…): the `diag` category matches only the five
 * instrument files; V2's /s6diag\./ also matched s6diag.selftest.js, so every
 * resource the self-check created was diverted to `diagOwn` and liveRefed=0
 * (selftest-v2 receipt logs/selftest-v2/). Selftest frames now classify as `harness`.
 *
 * OBSERVATION ONLY. Installs one async_hooks hook in the real Node process that
 * runs Jest and the in-band test, records every non-PROMISE resource with its
 * creation stack, and keeps a bounded ring of destroyed resources (including
 * PROMISE ids) so a live resource's causal chain can be walked back across
 * `await` boundaries. Jest's own --detectOpenHandles collector drops exactly
 * that information (see @jest/core/build/collectHandles.js: PROMISE inits are
 * skipped and a resource is reported only if its own stack has a user frame or
 * its trigger is a *currently tracked* resource), which is why C4 printed no
 * owner although the process stayed alive.
 *
 * Never calls process.exit, never clears or unrefs a foreign resource, never
 * touches storage, network or the product tree. Own timers are unref'd and
 * tagged `diag`.
 *
 * Loaded by s6diag.globalSetup.js / s6diag.globalTeardown.js (absolute path).
 * Shared state lives on globalThis.__S6DIAG_MAIN__ so both hooks see it.
 */
const asyncHooks = require('async_hooks');
const fs = require('fs');

const G = globalThis.__S6DIAG_MAIN__ || (globalThis.__S6DIAG_MAIN__ = {});

const LOG = process.env.S6DIAG_LOG || '/dev/null';
const STEP = process.env.S6DIAG_STEP || '?';
const WT = process.env.S6DIAG_WT || '/home/user/workspace/worktrees/s6-diagnostic';

const STACK_FRAMES = 60;
const NO_STACK_TYPES = new Set(['PROMISE', 'TickObject']); // recorded (id/type/trigger) but no stack
const GONE_CAP = 80000; // destroyed-resource ring (light records)
const GONE_STACK_CAP = 6000; // destroyed resources that keep their stack (non-PROMISE/TickObject)

// Frame classification. Order matters (first match wins).
const CATEGORY_RULES = [
  ['diag', /s6diag\.(main|globalSetup|globalTeardown|setupAfterEnv|summarize)\.js/],
  ['harness', /__tests__\/persistedQueryCache\.hazard|__tests__\/s6diag|\/jest\.setup\.js|s6diag\.selftest\.js/],
  ['product', new RegExp(WT.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '/(src/(?!.*__tests__)|App\\.tsx)')],
  ['tanstack', /node_modules\/@tanstack\//],
  [
    'preset',
    /node_modules\/(react-native|@react-native(-community|-async-storage)?|jest-expo|expo(-[a-z-]+)?|@expo|@testing-library|react-test-renderer|scheduler|react|react-dom|zustand)\//,
  ],
  [
    'runner',
    /node_modules\/(jest|@jest|jest-[a-z-]+|@sinonjs|source-map-support|pirates|babel-jest|@babel|expect|pretty-format|graceful-fs|yargs|ci-info|chalk)\/|jest-circus|Runtime\./,
  ],
  ['node', /\(node:|node:internal|\(internal\/|\(<anonymous>\)$|^at (new )?Promise|^at process\.|^at [A-Za-z_$][\w$.<>]* \(<anonymous>\)/],
];

function categorize(frame) {
  for (const [name, re] of CATEGORY_RULES) if (re.test(frame)) return name;
  return 'other';
}

/** owner = first frame category outside node/tanstack; immediate = first outside node. */
function ownerOf(frames) {
  let immediate = null;
  let owner = null;
  for (const f of frames) {
    const c = categorize(f);
    if (c === 'node') continue;
    if (immediate === null) immediate = c;
    if (c !== 'tanstack' && c !== 'diag') {
      owner = c;
      break;
    }
  }
  if (owner === null) owner = immediate === 'tanstack' ? 'library-only' : immediate === 'diag' ? 'diag' : 'node-only';
  return { owner, immediate: immediate || 'node-only' };
}

function captureStack(skipFn) {
  const o = {};
  const prev = Error.stackTraceLimit;
  const prevPrepare = Error.prepareStackTrace;
  Error.stackTraceLimit = STACK_FRAMES;
  Error.prepareStackTrace = undefined;
  try {
    Error.captureStackTrace(o, skipFn);
  } finally {
    Error.stackTraceLimit = prev;
    Error.prepareStackTrace = prevPrepare;
  }
  return String(o.stack || '')
    .split('\n')
    .slice(1)
    .map((s) => s.trim());
}

function w(obj) {
  try {
    fs.appendFileSync(LOG, JSON.stringify({ src: 'main', step: STEP, t: new Date().toISOString(), ...obj }) + '\n');
  } catch {
    /* logging must never throw into Jest */
  }
}

function install() {
  if (G.installed) return G;
  G.installed = true;
  G.live = new Map(); // asyncId -> rec
  G.gone = new Map(); // asyncId -> light rec (FIFO)
  G.goneWithStack = 0;
  G.counts = { init: 0, destroy: 0, byType: {} };
  G.beforeExitSeen = false;
  G.t0 = Date.now();

  const hook = asyncHooks.createHook({
    init: function initHook(asyncId, type, triggerAsyncId, resource) {
      G.counts.init++;
      G.counts.byType[type] = (G.counts.byType[type] || 0) + 1;
      const rec = { id: asyncId, type, trigger: triggerAsyncId, at: Date.now() };
      if (!NO_STACK_TYPES.has(type)) {
        rec.stack = captureStack(initHook);
        try {
          if (resource && typeof resource === 'object') rec.ref = new WeakRef(resource);
        } catch {
          /* ignore */
        }
      }
      G.live.set(asyncId, rec);
    },
    destroy(asyncId) {
      G.counts.destroy++;
      const rec = G.live.get(asyncId);
      if (!rec) return;
      G.live.delete(asyncId);
      rec.gone = Date.now();
      if (rec.stack) {
        if (G.goneWithStack >= GONE_STACK_CAP) {
          delete rec.stack; // keep the light record, drop the stack
        } else {
          G.goneWithStack++;
        }
      }
      delete rec.ref;
      G.gone.set(asyncId, rec);
      if (G.gone.size > GONE_CAP) {
        const oldest = G.gone.keys().next().value;
        const o = G.gone.get(oldest);
        if (o && o.stack) G.goneWithStack--;
        G.gone.delete(oldest);
      }
    },
  });
  hook.enable();
  G.hook = hook;

  process.on('beforeExit', (code) => {
    G.beforeExitSeen = true;
    w({ ev: 'beforeExit', code, note: 'event loop drained — process is exiting on its own' });
  });
  process.on('exit', (code) => {
    w({ ev: 'exit', code, beforeExitSeen: G.beforeExitSeen, uptimeMs: Date.now() - G.t0 });
  });
  process.once('SIGTERM', () => {
    try {
      snapshot('SIGTERM');
    } catch (e) {
      w({ ev: 'snapshot-error', label: 'SIGTERM', error: String((e && e.stack) || e) });
    }
    w({ ev: 'SIGTERM-reraise', otherListeners: process.listenerCount('SIGTERM') });
    // Re-deliver with default disposition so the real exit (143 → timeout rc 124) is preserved.
    process.kill(process.pid, 'SIGTERM');
  });

  w({
    ev: 'main-start',
    pid: process.pid,
    ppid: process.ppid,
    node: process.version,
    argv: process.argv,
    cwd: process.cwd(),
    hasGetActiveResourcesInfo: typeof process.getActiveResourcesInfo === 'function',
  });
  return G;
}

function describeResource(rec) {
  const out = {};
  let r;
  try {
    r = rec.ref && rec.ref.deref();
  } catch {
    r = undefined;
  }
  if (!r) {
    out.collected = true;
    return out;
  }
  try {
    out.ctor = r.constructor && r.constructor.name;
    if (typeof r.hasRef === 'function') out.hasRef = r.hasRef();
    if (rec.type === 'Timeout') {
      out.delayMs = r._idleTimeout;
      out.repeat = r._repeat !== null && r._repeat !== undefined ? r._repeat : null;
      out.destroyed = Boolean(r._destroyed);
      const cb = r._onTimeout;
      if (typeof cb === 'function') {
        out.cbName = cb.name || '(anonymous)';
        out.cbSrc = String(cb).replace(/\s+/g, ' ').slice(0, 160);
      }
    } else if (rec.type === 'Immediate') {
      const cb = r._onImmediate;
      if (typeof cb === 'function') {
        out.cbName = cb.name || '(anonymous)';
        out.cbSrc = String(cb).replace(/\s+/g, ' ').slice(0, 160);
      }
    }
  } catch (e) {
    out.describeError = String(e && e.message);
  }
  return out;
}

function topFrames(frames, n) {
  const res = [];
  for (const f of frames || []) {
    if (categorize(f) === 'node') continue;
    res.push(f);
    if (res.length >= n) break;
  }
  return res;
}

/** Walk trigger ids back through live + destroyed records (max hops). */
function chainOf(rec, maxHops) {
  const chain = [];
  let cur = rec;
  const seen = new Set([rec.id]);
  for (let i = 0; i < maxHops; i++) {
    const tid = cur.trigger;
    if (tid === undefined || tid === null || tid <= 0 || seen.has(tid)) break;
    seen.add(tid);
    const anc = G.live.get(tid) || G.gone.get(tid);
    if (!anc) {
      chain.push({ id: tid, type: 'untracked/evicted' });
      break;
    }
    const entry = { id: anc.id, type: anc.type, alive: G.live.has(tid) };
    if (anc.stack) {
      const o = ownerOf(anc.stack);
      entry.owner = o.owner;
      entry.immediate = o.immediate;
      entry.top = topFrames(anc.stack, 3);
    }
    chain.push(entry);
    cur = anc;
  }
  return chain;
}

function snapshot(label) {
  const g = install();
  const live = [];
  const unrefd = [];
  const diag = []; // the instrument's own resources (Signal listener, unref'd ticks) — reported, never counted
  const byOwner = {};
  const byDelay = {};
  const byType = {};
  for (const rec of g.live.values()) {
    if (NO_STACK_TYPES.has(rec.type)) continue;
    const d = describeResource(rec);
    const o = ownerOf(rec.stack || []);
    const item = {
      id: rec.id,
      type: rec.type,
      trigger: rec.trigger,
      ageMs: Date.now() - rec.at,
      ...d,
      owner: o.owner,
      immediate: o.immediate,
      categories: Array.from(new Set((rec.stack || []).map(categorize))).filter((c) => c !== 'node'),
      top: topFrames(rec.stack, 8),
      chain: chainOf(rec, 14),
    };
    // Root = deepest chain ancestor carrying a non-library owner, else own owner.
    let root = item.owner;
    for (const anc of item.chain) if (anc.owner && anc.owner !== 'library-only' && anc.owner !== 'node-only') root = anc.owner;
    item.rootOwner = root;
    if (item.owner === 'diag' || item.immediate === 'diag') {
      diag.push({ id: item.id, type: item.type, hasRef: d.hasRef, delayMs: d.delayMs });
      continue;
    }
    if (d.hasRef === false || d.collected) {
      unrefd.push(item);
      continue;
    }
    live.push(item);
    byOwner[item.owner] = (byOwner[item.owner] || 0) + 1;
    byType[item.type] = (byType[item.type] || 0) + 1;
    if (item.type === 'Timeout') byDelay[String(item.delayMs)] = (byDelay[String(item.delayMs)] || 0) + 1;
  }
  let activeResourcesInfo = null;
  try {
    if (typeof process.getActiveResourcesInfo === 'function') {
      activeResourcesInfo = {};
      for (const t of process.getActiveResourcesInfo()) activeResourcesInfo[t] = (activeResourcesInfo[t] || 0) + 1;
    }
  } catch (e) {
    activeResourcesInfo = { error: String(e && e.message) };
  }
  let nativeHandles = null;
  try {
    if (typeof process._getActiveHandles === 'function') {
      nativeHandles = {};
      for (const h of process._getActiveHandles()) {
        const n = (h && h.constructor && h.constructor.name) || typeof h;
        nativeHandles[n] = (nativeHandles[n] || 0) + 1;
      }
    }
  } catch (e) {
    nativeHandles = { error: String(e && e.message) };
  }
  let nativeRequests = null;
  try {
    if (typeof process._getActiveRequests === 'function') {
      nativeRequests = {};
      for (const h of process._getActiveRequests()) {
        const n = (h && h.constructor && h.constructor.name) || typeof h;
        nativeRequests[n] = (nativeRequests[n] || 0) + 1;
      }
    }
  } catch (e) {
    nativeRequests = { error: String(e && e.message) };
  }
  const out = {
    ev: 'snapshot',
    label,
    sinceStartMs: Date.now() - g.t0,
    beforeExitSeen: g.beforeExitSeen,
    hookCounts: { init: g.counts.init, destroy: g.counts.destroy, liveTracked: g.live.size, goneRing: g.gone.size },
    activeResourcesInfo,
    nativeHandles,
    nativeRequests,
    liveRefedCount: live.length,
    unrefdOrCollectedCount: unrefd.length,
    diagOwn: diag,
    byOwner,
    byType,
    byDelay,
    live: live.sort((a, b) => a.id - b.id),
    unrefd: unrefd.map((u) => ({ id: u.id, type: u.type, owner: u.owner, delayMs: u.delayMs, top: u.top.slice(0, 2) })),
  };
  w(out);
  return out;
}

function scheduleTicks(delays) {
  for (const d of delays) {
    let t;
    try {
      t = setTimeout(() => {
        try {
          snapshot('tick+' + d + 'ms');
        } catch (e) {
          w({ ev: 'snapshot-error', label: 'tick+' + d, error: String((e && e.stack) || e) });
        }
      }, d);
      if (t && typeof t.unref === 'function') t.unref();
    } catch (e) {
      w({ ev: 'tick-schedule-error', delay: d, error: String(e && e.message) });
    }
  }
}

module.exports = { install, snapshot, scheduleTicks, categorize, ownerOf, write: w, state: () => G };
