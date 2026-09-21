// S4 R4 predecessor control for S4-R3-A-02 (adapted from audit A's
// stale-caller-probe). Real router/worker/replay/session modules; only chrome.*
// and HTTP are mocked. No network, no source mutation.
// usage: node stale-caller-probe.mjs <repo-root> [success|reject]
// Expected: base 84471e99 FAILS (replacement session wiped, auth_required=1);
//           candidate PASSES (replacement preserved, auth_required=0, run stopped).
import { pathToFileURL } from "node:url";
import { resolve } from "node:path";
import { execFileSync } from "node:child_process";
import { webcrypto } from "node:crypto";
const root = resolve(process.argv[2]);
// A `git archive` export has no .git; the caller then supplies PROBE_HEAD.
function headOf(dir) {
  try {
    return execFileSync("git", ["-C", dir, "rev-parse", "HEAD"], { encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] }).trim();
  } catch {
    return process.env.PROBE_HEAD ? `${process.env.PROBE_HEAD} (from PROBE_HEAD; exported tree, no .git)` : "unknown";
  }
}
const mode = process.argv[3] ?? "success";
const tick = () => new Promise((r) => setTimeout(r, 0));
const until = async (predicate) => {
  for (let i = 0; i < 4000; i++) {
    if (predicate()) return;
    await tick();
  }
  throw new Error("probe observation did not arrive");
};
globalThis.crypto ??= webcrypto;
const { makeBgMock } = await import(pathToFileURL(resolve(root, "test/helpers/background-mock.js")));
const mock = makeBgMock({ tab: { url: "https://app.truecoach.co/clients", token: "SYNTHETIC_SOURCE" } });
globalThis.chrome = mock.chrome;
const calls = [];
let releaseRefresh;
globalThis.fetch = async (url, init) => {
  calls.push({ url, authorization: init?.headers?.Authorization ?? null });
  if (url.endsWith("/api/auth/extension/refresh"))
    return new Promise((r) => {
      releaseRefresh = r;
    });
  if (url.endsWith("/api/scout/ingest")) return new Response(null, { status: 401 });
  if (url.includes("/proxy/api/clients?")) return Response.json({ clients: [{ id: "synthetic-c1" }] });
  if (url.endsWith("/api/scout/progress")) return new Response(null, { status: 204 });
  if (url.endsWith("/api/scout/ingest/complete")) return new Response(null, { status: 200 });
  throw new Error("unexpected probe route " + url);
};
await import(pathToFileURL(resolve(root, "background.js")));
const first = await mock.dispatch({ kind: "session_established", accessToken: "OLD_SYNTHETIC_ACCESS", refreshToken: "OLD_SYNTHETIC_REFRESH" });
const started = await mock.dispatch({ kind: "start_import", url: "https://app.truecoach.co/clients", tabId: 42 });
await until(() => releaseRefresh !== undefined);
const replacement = await mock.dispatch({ kind: "session_established", accessToken: "NEW_SYNTHETIC_ACCESS", refreshToken: "NEW_SYNTHETIC_REFRESH" });
const immediatelyAfterReplacement = [...mock.sessionMap];
releaseRefresh(
  mode === "reject"
    ? new Response(null, { status: 401 })
    : Response.json({ access_token: "STALE_SYNTHETIC_ACCESS", refresh_token: "STALE_SYNTHETIC_REFRESH" }),
);
const snapshots = () => mock.sent.filter((m) => m.kind === "status_snapshot");
const authRequired = () => mock.sent.filter((m) => m.kind === "auth_required");
await until(() => authRequired().length > 0 || snapshots().at(-1)?.intent?.status === "ingest_failed");
const finalSession = await mock.dispatch({ kind: "request_session_state" });
const lastSnapshot = snapshots().at(-1);
const pass =
  first.ok === true &&
  started.ok === true &&
  replacement.ok === true &&
  finalSession.hasSession === true &&
  mock.sessionMap.get("tgp_refresh_token") === "NEW_SYNTHETIC_REFRESH" &&
  authRequired().length === 0 &&
  lastSnapshot?.intent?.status === "ingest_failed" &&
  !calls.some((c) => c.authorization === "Bearer NEW_SYNTHETIC_ACCESS") &&
  !calls.some((c) => c.url.endsWith("/api/scout/ingest/complete"));
console.log(
  JSON.stringify(
    {
      probe: `stale-caller (S4-R3-A-02) mode=${mode}`,
      root,
      head: headOf(root),
      node: process.version,
      actualNetwork: false,
      replacementAcknowledgement: replacement,
      immediatelyAfterReplacement,
      afterStaleCallerSettled: [...mock.sessionMap],
      finalSession,
      authRequiredCount: authRequired().length,
      lastSnapshot,
      calls,
      pass,
    },
    null,
    2,
  ),
);
process.exit(pass ? 0 : 1);
