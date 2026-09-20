// Independent audit A: exercise actual worker/router/replay/session modules.
// Only Chrome APIs and HTTP responses are mocked; no source rewriting/network.
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
import { resolve } from "node:path";
import { execFileSync } from "node:child_process";
import { webcrypto } from "node:crypto";
const root = resolve(process.argv[2]);
const flushUntil = async predicate => {
  for(let i=0;i<1000;i++) { if(predicate()) return; await Promise.resolve(); }
  throw new Error("probe observation did not arrive within 1000 microtasks");
};
globalThis.crypto ??= webcrypto;
const {makeBgMock} = await import(pathToFileURL(resolve(root,"test/helpers/background-mock.js")));
const mock = makeBgMock({tab:{url:"https://app.truecoach.co/clients",token:"SYNTHETIC_SOURCE"}});
globalThis.chrome = mock.chrome;
const calls=[];
let releaseRefresh;
globalThis.fetch = async (url, init) => {
  calls.push({url,authorization:init?.headers?.Authorization??null});
  if(url.endsWith("/api/auth/extension/refresh"))
    return new Promise(r=>{releaseRefresh=r;});
  if(url.endsWith("/api/scout/ingest")) return new Response(null,{status:401});
  if(url.includes("/proxy/api/clients?")) return Response.json({clients:[{id:"synthetic-c1"}]});
  if(url.endsWith("/api/scout/progress")) return new Response(null,{status:204});
  throw new Error("unexpected probe route");
};
await import(pathToFileURL(resolve(root,"background.js")));
const first = await mock.dispatch({kind:"session_established",
  accessToken:"OLD_SYNTHETIC_ACCESS",refreshToken:"OLD_SYNTHETIC_REFRESH"});
assert.equal(first.ok,true);
assert.equal((await mock.dispatch({kind:"start_import",
  url:"https://app.truecoach.co/clients",tabId:42})).ok,true);
await flushUntil(()=>releaseRefresh!==undefined);
// Re-pair while the old run's refresh is in flight: actual trusted router.
const replacement = await mock.dispatch({kind:"session_established",
  accessToken:"NEW_SYNTHETIC_ACCESS",refreshToken:"NEW_SYNTHETIC_REFRESH"});
assert.equal(replacement.ok,true);
const immediatelyAfterReplacement = [...mock.sessionMap];
// Even a successful stale response is epoch-fenced to null by session.js.
releaseRefresh(Response.json({
  access_token:"STALE_SYNTHETIC_ACCESS",refresh_token:"STALE_SYNTHETIC_REFRESH"}));
await flushUntil(()=>mock.sent.some(m=>m.kind==="auth_required"));
const finalSession = await mock.dispatch({kind:"request_session_state"});
console.log(JSON.stringify({
  head:execFileSync("git",["-C",root,"rev-parse","HEAD"],{encoding:"utf8"}).trim(),
  node:process.version,
  actualNetwork:false,
  case:"stale refresh null consumed by makeSender after acknowledged replacement session",
  replacementAcknowledgement:replacement,
  immediatelyAfterReplacement,
  afterStaleCallerSettled:[...mock.sessionMap],
  finalSession,
  replacementSessionPreserved:finalSession.hasSession===true,
  authRequiredCount:mock.sent.filter(m=>m.kind==="auth_required").length,
  lastSnapshot:mock.sent.filter(m=>m.kind==="status_snapshot").at(-1),
  calls
},null,2));
