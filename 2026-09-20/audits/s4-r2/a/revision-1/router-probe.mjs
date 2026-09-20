import assert from "node:assert/strict";
import {writeFileSync} from "node:fs";
const root = "/home/user/workspace/worktrees/s4";
const {makeBgMock, installChrome} = await import(`${root}/test/helpers/background-mock.js`);
const mock = makeBgMock();
installChrome(mock);
const effects = [];
globalThis.fetch = async () => {effects.push("fetch"); throw new Error("unexpected fetch");};
mock.chrome.debugger.attach = async () => effects.push("attach");
mock.chrome.debugger.detach = async () => effects.push("detach");
await import(`${root}/background.js`);
const results = [];
for (const kind of ["start_import", "start_ingest", "start_capture", "stop_capture"]) {
  const ack = await mock.dispatch({kind, url: "https://app.truecoach.co/clients", sourceToken: "synthetic", tabId: 9},
    {id: mock.chrome.runtime.id, url: "https://app.truecoach.co/clients", tab: {id: 9}});
  assert.deepEqual(ack, {ok: false, error: "untrusted_sender"});
  results.push({kind, ack});
}
assert.equal(mock.sent.length, 0);
assert.equal(mock.localMap.size, 0);
assert.equal(effects.length, 0);
const capture = await mock.dispatch({kind: "start_capture"});
assert.deepEqual(capture, {ok: false, error: "start_capture: missing tabId"});
await mock.dispatch({kind: "start_import", url: "https://example.com/clients/private-person?access_token=synthetic-secret"});
await new Promise(r => setTimeout(r, 0));
const saved = mock.localMap.get("tgp_status_snapshot");
assert.equal(saved.lastError, "unsupported site: https://example.com");
const result = {head: "c5a5ae12c5b3c3e32a4601c99319ad7c0d980057", results,
  deniedEffects: effects, trustedPageReachesValidation: capture,
  persistedPreflightError: saved.lastError,
  scope: "real router module with repository Chrome mock, not real-browser principal proof"};
writeFileSync(new URL("./router-probe.json", import.meta.url), JSON.stringify(result, null, 2) + "\n");
console.log(JSON.stringify(result, null, 2));
