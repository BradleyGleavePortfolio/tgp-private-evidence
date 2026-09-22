// Auditor A: actual worker/session/replay modules; synthetic Chrome/HTTP only.
// One dependency-free process; no sockets, children, package loads or writes.
import { pathToFileURL } from "node:url";
import { webcrypto } from "node:crypto";
globalThis.crypto ??= webcrypto;
const started = new Date().toISOString();
const startMs = performance.now();
const ROOTS = [
  ["/home/user/workspace/worktrees/s4-r4", "2bcf1563d85bc2109e99805e4ce1b06fce4dcdb3"],
  ["/home/user/workspace/execution/s4-r4/artifacts/base-84471e99-export", "84471e99b278e964f7cb3f6bf9c78491064c41b7"],
];
const results = [];
const realTimeout = setTimeout;
const tick = () => new Promise(r => realTimeout(r, 0));
const flush = async () => { for(let i=0;i<100;i++) await Promise.resolve(); };
const until = async (pred) => {
  const deadline = performance.now()+4000;
  while (!pred()) { if(performance.now()>deadline) throw Error("observation timeout"); await tick(); }
};
const deferred = () => { let resolve; const promise = new Promise(r=>{resolve=r;}); return {promise,resolve}; };
const REFRESH = "https://api.tgp.coach/api/auth/extension/refresh";
const INGEST = "https://api.tgp.coach/api/scout/ingest";
const COMPLETE = "https://api.tgp.coach/api/scout/ingest/complete";
const TAB = "https://app.truecoach.co/clients";
const key = "tgp_refresh_token";
const mint = () => Response.json({access_token:"MINTED_A",refresh_token:"ROTATED_A"});
for (const [root,head] of ROOTS) {
  const {makeBgMock,acceptedIngest} = await import(pathToFileURL(`${root}/test/helpers/background-mock.js`));
  const mock=makeBgMock({session:[[key,"OLD_R"]],tab:{url:TAB,token:"SOURCE"}});
  globalThis.chrome=mock.chrome;
  let calls=[], refreshHook, ingestHook, completeHook;
  globalThis.fetch=async(url,init)=>{
    calls.push({url,authorization:init?.headers?.Authorization??null,refreshToken:url===REFRESH?JSON.parse(init.body).refresh_token:null});
    if(url===REFRESH) return refreshHook();
    if(url===INGEST) return ingestHook(init);
    if(url===COMPLETE) return completeHook();
    if(url.endsWith("/api/scout/progress")) return new Response(null,{status:204});
    if(url.includes("/proxy/api/clients?")) return Response.json({clients:url.includes("page=1")?[{id:"c1"}]:[]});
    if(url.endsWith("/clients/c1/notes")) return Response.json({notes:[]});
    throw Error("unexpected synthetic route");
  };
  await import(pathToFileURL(`${root}/background.js`));
  const session = await import(pathToFileURL(`${root}/shared/session.js`));
  const pair=(a="NEW_A",r="NEW_R")=>mock.dispatch({kind:"session_established",accessToken:a,refreshToken:r});
  const start=()=>mock.dispatch({kind:"start_import",url:TAB,tabId:42});
  const snaps=()=>mock.sent.filter(m=>m.kind==="status_snapshot");
  const auth=()=>mock.sent.filter(m=>m.kind==="auth_required");
  const finish=async()=>{
    await until(()=>auth().length>0||["ingest_failed","ingest_succeeded","ingest_empty","ingest_partial"].includes(snaps().at(-1)?.intent?.status));
    await flush();
  };
  const record=async(name,extra={})=>{
    results.push({root,head,scenario:name,...extra,calls:[...calls],session:[...mock.sessionMap],sessionState:await mock.dispatch({kind:"request_session_state"}),authRequired:auth().length,lastSnapshot:snaps().at(-1)});
    await flush();
    calls=[]; mock.sent.length=0;
  };
  // C1: Cold-worker preflight starts under A, then B is acknowledged before
  // A's refresh result. No run generation has been captured yet.
  let held=deferred();
  refreshHook=()=>held.promise;
  ingestHook=init=>acceptedIngest(init);
  completeHook=()=>new Response(null,{status:200});
  await start();
  await until(()=>calls.some(c=>c.url===REFRESH));
  const replacementAck=await pair();
  held.resolve(mint());
  await finish();
  await record("C1 cold-preflight replacement before stale success",{replacementAck});

  // C2: Old run is sending. B's establishment holds the state lock.
  // Old ingest then 401s and calls refresh before B has incremented generation.
  await pair("OLD_A","OLD_R");
  mock.sent.length=0;
  held=deferred(); const persist=deferred();
  let persistEntered=false;
  const originalSet=mock.chrome.storage.session.set;
  mock.chrome.storage.session.set=async obj=>{
    if(obj[key]==="NEW_R"){persistEntered=true;await persist.promise;}
    return originalSet(obj);
  };
  ingestHook=()=>held.promise;
  refreshHook=()=>Response.json({access_token:"NEW_MINTED_A",refresh_token:"NEW_ROTATED_R"});
  await start();
  await until(()=>calls.some(c=>c.url===INGEST));
  const replacing=pair();
  await until(()=>persistEntered);
  held.resolve(new Response(null,{status:401}));
  await flush();
  const refreshesWhilePersistHeld=calls.filter(c=>c.url===REFRESH).length;
  persist.resolve();
  const pendingReplacementAck=await replacing;
  await finish();
  mock.chrome.storage.session.set=originalSet;
  await record("C2 refresh admitted behind replacement persist",{pendingReplacementAck,refreshesWhilePersistHeld});

  // C3: Refresh A commits. A pairing is queued DURING its rotation persist,
  // hence serialized after the old commit but before all outer token promises
  // resolve. The accepted Start must not silently adopt B at preflight return.
  await session.clearTokens();
  mock.sessionMap.set(key,"COLD_OLD_R");
  calls=[]; mock.sent.length=0;
  let queuedPair, queued=false;
  mock.chrome.storage.session.set=async obj=>{
    if(obj[key]==="ROTATED_A"&&!queued){
      queued=true;
      queuedPair=pair();
    }
    return originalSet(obj);
  };
  refreshHook=()=>mint();
  ingestHook=init=>acceptedIngest(init);
  await start();
  await finish();
  const queuedPairAck=await queuedPair;
  mock.chrome.storage.session.set=originalSet;
  await record("C3 replacement queued during preflight rotation persist",{queuedPairAck,queued});
  await session.clearTokens();
}
console.log(JSON.stringify({started,ended:new Date().toISOString(),durationMs:performance.now()-startMs,node:process.version,network:false,processes:1,results},null,2));
