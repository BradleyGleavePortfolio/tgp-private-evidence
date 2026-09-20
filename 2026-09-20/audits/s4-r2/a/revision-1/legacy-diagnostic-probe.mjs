import assert from "node:assert/strict";
import {writeFileSync} from "node:fs";
const root = "/home/user/workspace/worktrees/s4";
const {makeBgMock, installChrome} = await import(`${root}/test/helpers/background-mock.js`);
const mock = makeBgMock();
installChrome(mock);
const requests = [];
const marker = "SYNTHETIC_PRIVATE_CLIENT_SENTINEL";
globalThis.fetch = async (url, init) => {
  requests.push({url, body: init.body ?? null});
  if (url === "https://app.truecoach.co/proxy/api/organizations")
    return new Response(marker, {status: 200});
  if (url === "https://api.tgp.coach/api/scout/ingest/complete")
    return new Response("{}", {status: 200});
  throw new Error("unexpected synthetic request");
};
await import(`${root}/background.js`);
await mock.dispatch({kind: "session_established", accessToken: "synthetic-access", refreshToken: "synthetic-refresh"});
const ack = await mock.dispatch({kind: "start_ingest", url: "https://app.truecoach.co/clients", sourceToken: "synthetic-source"});
let saved;
for (let i = 0; i < 100; i++) {
  await new Promise(r => setTimeout(r, 10));
  saved = mock.localMap.get("tgp_status_snapshot");
  if (saved?.intent?.status === "ingest_failed") break;
}
const settlement = requests.find(r => r.url.endsWith("/complete"));
assert.equal(saved?.intent?.status, "ingest_failed");
// V8 includes a prefix of a malformed response in the parser diagnostic.
assert.ok(saved.lastError.includes("SYNTHETIC"));
assert.ok(settlement.body.includes("SYNTHETIC"));
const result = {
  head: "c5a5ae12c5b3c3e32a4601c99319ad7c0d980057", ack,
  savedLastError: saved.lastError,
  settlementErrorSummary: JSON.parse(settlement.body).error_summary,
  broadcastsContainResponsePrefix: JSON.stringify(mock.sent).includes("SYNTHETIC"),
  conclusion: "Legacy trusted-page start_ingest persists and uploads malformed source body prefix through raw JSON SyntaxError; no shipped UI producer identified.",
  scope: "actual background/router/extractor/network modules, actual Node Response.json parser, synthetic fetch and Chrome mock; no real account/network"
};
writeFileSync(new URL("./legacy-diagnostic-probe.json", import.meta.url), JSON.stringify(result, null, 2) + "\n");
console.log(JSON.stringify(result, null, 2));
