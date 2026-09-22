// S4 R5 discriminator for S4-R4-A-02 / S4-R4B-01 (an obsolete caller's queued
// refresh presents and rotates the replacement's refresh token) and for the
// related C1 cold-preflight schedule (obsolete work falsely announces that the
// replacement needs authentication).
//
// Schedules are taken from both R4 reviewers' independently attributable
// probes; observation code is kept, only the verdict predicates differ by side:
//   C1, C2  — reviewer A, execution/audits/s4-r4/a/independent-race-probe.mjs
//             sha256 1a9201602bd34e88a103967f34da03733c975cf8161143b7ec4ddfe728761a1d
//   P-C     — reviewer B, execution/audits/s4-r4/b/probes/pending-admission-replacement-probe.mjs
//             sha256 545d04c9ece12c6f07bbc196864de9558c22d185810d55d1b30962138bd6db0c
//             (B's design-level expectation "pending run presents NEW_RT exactly
//             once" is REPLACED here by the parent-adopted identity/authority
//             invariant: the obsolete run presents nothing and B is not rotated.)
//
//   --expect fixed   (R5 candidate): in every schedule the OLD run presents no
//                    refresh token of B, sends nothing under B's bearer, B's
//                    stored refresh token is unchanged (not rotated), no
//                    auth_required is broadcast, request_session_state has a
//                    session, and the OLD run stops with the replaced detail.
//   --expect defect  (R4 predecessor 2bcf1563): C2 and P-C present NEW_R/NEW_RT
//                    from the obsolete run and rotate B's token; C1 broadcasts
//                    auth_required "login required to import" while B remains.
//
// Dependency-free, single process, no network, no lock, no source mutation.
// usage: node a02-queued-refresh-discriminator.mjs <repo-root> --expect fixed|defect
import { pathToFileURL } from "node:url";
import { resolve } from "node:path";
import { execFileSync } from "node:child_process";
import { webcrypto } from "node:crypto";
globalThis.crypto ??= webcrypto;

const root = resolve(process.argv[2]);
const expectIdx = process.argv.indexOf("--expect");
const expectation = expectIdx > 0 ? process.argv[expectIdx + 1] : null;
if (expectation !== "fixed" && expectation !== "defect") {
  console.error("usage: <repo-root> --expect fixed|defect");
  process.exit(2);
}
const head = (() => {
  try {
    return execFileSync("git", ["-C", root, "rev-parse", "HEAD"], {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    }).trim();
  } catch {
    return process.env.PROBE_HEAD ?? "unknown";
  }
})();
const started = new Date().toISOString();
const startMs = performance.now();
const tick = () => new Promise((r) => setTimeout(r, 0));
const flush = async () => {
  for (let i = 0; i < 100; i += 1) await Promise.resolve();
};
const until = async (pred, label) => {
  const deadline = performance.now() + 4000;
  while (!pred()) {
    if (performance.now() > deadline) throw Error("observation timeout: " + label);
    await tick();
  }
};
const deferred = () => {
  let resolve;
  const promise = new Promise((r) => {
    resolve = r;
  });
  return { promise, resolve };
};
const REFRESH = "https://api.tgp.coach/api/auth/extension/refresh";
const INGEST = "https://api.tgp.coach/api/scout/ingest";
const COMPLETE = "https://api.tgp.coach/api/scout/ingest/complete";
const TAB = "https://app.truecoach.co/clients";
const key = "tgp_refresh_token";
const REPLACED_DETAIL =
  "import stopped — your TGP session changed during the import. Start the import again.";
const EXPIRED = "session expired — please sign in again";

const { makeBgMock, acceptedIngest } = await import(
  pathToFileURL(`${root}/test/helpers/background-mock.js`)
);
const mock = makeBgMock({ session: [[key, "OLD_R"]], tab: { url: TAB, token: "SOURCE" } });
globalThis.chrome = mock.chrome;
let calls = [];
let refreshHook;
let ingestHook;
globalThis.fetch = async (url, init) => {
  calls.push({
    url,
    authorization: init?.headers?.Authorization ?? null,
    refreshToken: url === REFRESH ? JSON.parse(init.body).refresh_token : null,
  });
  if (url === REFRESH) return refreshHook(calls.at(-1).refreshToken);
  if (url === INGEST) return ingestHook(init);
  if (url === COMPLETE) return new Response(null, { status: 200 });
  if (url.endsWith("/api/scout/progress")) return new Response(null, { status: 204 });
  if (url.includes("/proxy/api/clients?"))
    return Response.json({ clients: url.includes("page=1") ? [{ id: "c1" }] : [] });
  if (url.endsWith("/clients/c1/notes")) return Response.json({ notes: [{ id: "n1" }] });
  throw Error("unexpected synthetic route " + url);
};
await import(pathToFileURL(`${root}/background.js`));
const session = await import(pathToFileURL(`${root}/shared/session.js`));
const originalSet = mock.chrome.storage.session.set;
const pair = (a = "NEW_A", r = "NEW_R") =>
  mock.dispatch({ kind: "session_established", accessToken: a, refreshToken: r });
const start = () => mock.dispatch({ kind: "start_import", url: TAB, tabId: 42 });
const snaps = () => mock.sent.filter((m) => m.kind === "status_snapshot");
const auth = () => mock.sent.filter((m) => m.kind === "auth_required");
const terminal = () =>
  auth().length > 0 ||
  ["ingest_failed", "ingest_succeeded", "ingest_empty", "ingest_partial"].includes(
    snaps().at(-1)?.intent?.status,
  ) ||
  // R5 preflight stop: no intent, replaced detail only.
  (snaps().at(-1)?.intent === null && snaps().at(-1)?.lastError === REPLACED_DETAIL);
const finish = async () => {
  await until(terminal, "terminal");
  await flush();
};
const scenarios = {};
const record = async (name, extra = {}) => {
  scenarios[name] = {
    ...extra,
    calls: [...calls],
    refreshTokensPresented: calls.filter((c) => c.refreshToken !== null).map((c) => c.refreshToken),
    ingestBearers: calls.filter((c) => c.url === INGEST).map((c) => c.authorization),
    completeCalls: calls.filter((c) => c.url === COMPLETE).length,
    session: [...mock.sessionMap],
    sessionState: await mock.dispatch({ kind: "request_session_state" }),
    authRequired: auth().length,
    lastSnapshot: snaps().at(-1),
    expiredSeen: snaps().some((s) => s.lastError === EXPIRED),
  };
  await flush();
  calls = [];
  mock.sent.length = 0;
};

// ---- C1 (A): cold-worker preflight refresh under A on the wire; B acknowledged
// before A's refresh result. No run generation had been captured on R4.
{
  const held = deferred();
  refreshHook = () => held.promise;
  ingestHook = (init) => acceptedIngest(init);
  await start();
  await until(() => calls.some((c) => c.url === REFRESH), "C1 refresh on wire");
  const replacementAck = await pair();
  held.resolve(Response.json({ access_token: "MINTED_A", refresh_token: "ROTATED_A" }));
  await finish();
  await record("C1", { replacementAck });
}

// ---- C2 (A): OLD run sending; B's establish holds the state lock (persist held);
// OLD ingest 401s and requests a refresh before B has bumped the generation.
{
  await pair("OLD_A", "OLD_R");
  mock.sent.length = 0;
  calls = [];
  const held = deferred();
  const persist = deferred();
  let persistEntered = false;
  mock.chrome.storage.session.set = async (obj) => {
    if (obj[key] === "NEW_R") {
      persistEntered = true;
      await persist.promise;
    }
    return originalSet(obj);
  };
  ingestHook = () => held.promise;
  refreshHook = (presented) =>
    Response.json({ access_token: `MINTED_FOR_${presented}`, refresh_token: `ROTATED_FROM_${presented}` });
  await start();
  await until(() => calls.some((c) => c.url === INGEST), "C2 first ingest");
  const replacing = pair();
  await until(() => persistEntered, "C2 B persist entered");
  held.resolve(new Response(null, { status: 401 }));
  await flush();
  for (let i = 0; i < 5; i += 1) await tick();
  const refreshesWhilePersistHeld = calls.filter((c) => c.url === REFRESH).length;
  persist.resolve();
  const pendingReplacementAck = await replacing;
  await finish();
  mock.chrome.storage.session.set = originalSet;
  await record("C2", { pendingReplacementAck, refreshesWhilePersistHeld });
}

// ---- P-C (B): OLD run's first ingest 401s WHILE the replacement's
// session_established handler is inside chrome.storage.session.set (lock owner).
{
  await session.clearTokens();
  mock.sent.length = 0;
  calls = [];
  const first = await pair("OLD_ACCESS", "OLD_RT");
  const persist = deferred();
  let holdSet = null;
  let replacementAck = null;
  let ingestCount = 0;
  mock.chrome.storage.session.set = async (obj) => {
    if (holdSet && obj[key] === "NEW_RT") await holdSet.promise;
    return originalSet(obj);
  };
  refreshHook = (presented) =>
    Response.json({ access_token: `MINTED_FOR_${presented}`, refresh_token: `ROTATED_FROM_${presented}` });
  ingestHook = async (init) => {
    ingestCount += 1;
    if (ingestCount === 1) {
      holdSet = persist;
      replacementAck = pair("NEW_ACCESS", "NEW_RT");
      await flush();
      return new Response(null, { status: 401 });
    }
    return acceptedIngest(init);
  };
  const startedAck = await start();
  await until(() => ingestCount === 1 && replacementAck !== null, "PC first ingest + replacement");
  for (let i = 0; i < 5; i += 1) await tick();
  const refreshesBeforeRelease = calls.filter((c) => c.url === REFRESH).length;
  persist.resolve();
  holdSet = null;
  const ack = await replacementAck;
  await finish();
  mock.chrome.storage.session.set = originalSet;
  await record("PC", { first, startedAck, replacementAck: ack, refreshesBeforeRelease });
  await session.clearTokens();
}

// ---- verdict --------------------------------------------------------------
const checks = {};
const check = (name, pass, detail) => {
  checks[name] = { pass, detail };
};
// Schedule sanity (both sides): the transitions were acknowledged and the refresh
// really was queued behind the held persist (nothing presented while held).
check("C1.replacement_acknowledged", scenarios.C1.replacementAck?.ok === true, scenarios.C1.replacementAck);
check("C2.replacement_acknowledged", scenarios.C2.pendingReplacementAck?.ok === true, scenarios.C2.pendingReplacementAck);
check("C2.nothing_presented_while_B_persist_held", scenarios.C2.refreshesWhilePersistHeld === 0, scenarios.C2.refreshesWhilePersistHeld);
check("PC.replacement_acknowledged", scenarios.PC.replacementAck?.ok === true, scenarios.PC.replacementAck);
check("PC.nothing_presented_while_B_persist_held", scenarios.PC.refreshesBeforeRelease === 0, scenarios.PC.refreshesBeforeRelease);

const B = { C1: { r: "NEW_R", a: "NEW_A" }, C2: { r: "NEW_R", a: "NEW_A" }, PC: { r: "NEW_RT", a: "NEW_ACCESS" } };
for (const name of ["C1", "C2", "PC"]) {
  const s = scenarios[name];
  const b = B[name];
  const presentedB = s.refreshTokensPresented.includes(b.r);
  const storedB = s.session.some(([k, v]) => k === key && v === b.r);
  const rotatedB = s.session.some(([k, v]) => k === key && String(v).startsWith("ROTATED_FROM_" + b.r));
  const bBearer = s.calls.some((c) => c.authorization === `Bearer ${b.a}` || c.authorization === `Bearer MINTED_FOR_${b.r}`);
  if (expectation === "fixed") {
    check(`${name}.old_run_never_presented_B_refresh_token`, !presentedB, s.refreshTokensPresented);
    check(`${name}.B_refresh_token_stored_unrotated`, storedB, s.session);
    check(`${name}.no_request_under_B_or_B_minted_bearer`, !bBearer, s.calls.map((c) => [c.url.split("/api/")[1] ?? c.url, c.authorization]));
    check(`${name}.no_complete_call`, s.completeCalls === 0, s.completeCalls);
    check(`${name}.no_auth_required`, s.authRequired === 0, s.authRequired);
    check(`${name}.no_expired_message`, !s.expiredSeen, s.expiredSeen);
    check(`${name}.session_state_has_session`, s.sessionState?.hasSession === true, s.sessionState);
    check(
      `${name}.old_run_stopped_with_replaced_detail`,
      s.lastSnapshot?.lastError === REPLACED_DETAIL && s.lastSnapshot?.intent?.status !== "ingest_succeeded",
      { lastError: s.lastSnapshot?.lastError, status: s.lastSnapshot?.intent?.status ?? null },
    );
  } else if (name === "C1") {
    // A's C1 on R4: unowned catch broadcasts auth_required + "login required"
    // although B remains stored.
    check("C1.predecessor_broadcasts_auth_required_while_B_remains", s.authRequired > 0 && storedB && s.sessionState?.hasSession === true, {
      authRequired: s.authRequired,
      lastError: s.lastSnapshot?.lastError,
      session: s.session,
    });
  } else {
    check(`${name}.predecessor_obsolete_run_presented_B_refresh_token`, presentedB, s.refreshTokensPresented);
    check(`${name}.predecessor_rotated_B_token`, rotatedB, s.session);
  }
}
const failures = Object.entries(checks).filter(([, v]) => !v.pass).map(([k]) => k);
console.log(
  JSON.stringify(
    {
      probe: "a02-queued-refresh-discriminator",
      derivedFrom: [
        "execution/audits/s4-r4/a/independent-race-probe.mjs sha256 1a9201602bd34e88a103967f34da03733c975cf8161143b7ec4ddfe728761a1d (C1, C2)",
        "execution/audits/s4-r4/b/probes/pending-admission-replacement-probe.mjs sha256 545d04c9ece12c6f07bbc196864de9558c22d185810d55d1b30962138bd6db0c (P-C schedule; verdict inverted to the identity invariant)",
      ],
      root,
      head,
      expectation,
      started,
      ended: new Date().toISOString(),
      durationMs: Math.round(performance.now() - startMs),
      node: process.version,
      network: false,
      pass: failures.length === 0,
      failures,
      checks,
      scenarios,
    },
    null,
    2,
  ),
);
process.exit(failures.length === 0 ? 0 : 1);
