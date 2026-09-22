// C3 confirmation with the replacement dispatched OUTSIDE the storage mock,
// while a real await holds the old refresh's rotation persistence open.
// Also records an unchanged-session control. No dependencies/network/children.
import {pathToFileURL} from "node:url";
import {webcrypto} from "node:crypto";
globalThis.crypto ??= webcrypto;
const begin=performance.now(), started=new Date().toISOString(), results=[];
const tick=()=>new Promise(r=>setTimeout(r,0));
const until=async(pred)=>{const limit=performance.now()+5000;while(!pred()){if(performance.now()>limit)throw Error("observation timeout");await tick();}};
const flush=async()=>{for(let i=0;i<100;i++)await Promise.resolve();};
const defer=()=>{let resolve;const promise=new Promise(r=>{resolve=r;});return{promise,resolve};};
const key="tgp_refresh_token", TAB="https://app.truecoach.co/clients";
for(const root of ["/home/user/workspace/worktrees/s4-r4","/home/user/workspace/execution/s4-r4/artifacts/base-84471e99-export"]){
  const{makeBgMock,acceptedIngest}=await import(pathToFileURL(`${root}/test/helpers/background-mock.js`));
  const mock=makeBgMock({session:[[key,"OLD_R"]],tab:{url:TAB,token:"SOURCE"}});
  globalThis.chrome=mock.chrome;
  let calls=[];
  globalThis.fetch=async(url,init)=>{
    calls.push({url,bearer:init?.headers?.Authorization??null});
    if(url.endsWith("/api/auth/extension/refresh"))return Response.json({access_token:"OLD_MINTED_A",refresh_token:"OLD_ROTATED_R"});
    if(url.endsWith("/api/scout/ingest"))return acceptedIngest(init);
    if(url.endsWith("/api/scout/progress"))return new Response(null,{status:204});
    if(url.endsWith("/api/scout/ingest/complete"))return new Response(null,{status:200});
    if(url.includes("/proxy/api/clients?"))return Response.json({clients:url.includes("page=1")?[{id:"c1"}]:[]});
    if(url.endsWith("/clients/c1/notes"))return Response.json({notes:[]});
    throw Error("unrouted synthetic request");
  };
  // Unique module query loads a fresh worker listener, using the fresh session
  // module in this new process (one load per root).
  await import(pathToFileURL(`${root}/background.js`));
  const session=await import(pathToFileURL(`${root}/shared/session.js`));
  for(const replace of [false,true]){
    if(replace){await session.clearTokens();mock.sessionMap.set(key,"OLD_R");}
    calls=[];mock.sent.length=0;
    const original=mock.chrome.storage.session.set, persist=defer();
    let persistEntered=false;
    mock.chrome.storage.session.set=async(obj)=>{
      if(obj[key]==="OLD_ROTATED_R"){persistEntered=true;await persist.promise;}
      return original(obj);
    };
    const startAck=await mock.dispatch({kind:"start_import",url:TAB,tabId:42});
    await until(()=>persistEntered);
    // Old refresh holds the session lock. The trusted replacement event now
    // queues behind it, without executing reentrantly inside storage.set.
    const replacement=replace?mock.dispatch({kind:"session_established",accessToken:"NEW_A",refreshToken:"NEW_R"}):null;
    persist.resolve();
    const replacementAck=await replacement;
    const snapshots=()=>mock.sent.filter(x=>x.kind==="status_snapshot");
    await until(()=>["ingest_succeeded","ingest_failed","ingest_empty"].includes(snapshots().at(-1)?.intent?.status));
    await flush();
    mock.chrome.storage.session.set=original;
    results.push({root,replace,startAck,replacementAck,calls:[...calls],session:[...mock.sessionMap],lastSnapshot:snapshots().at(-1)});
  }
  await session.clearTokens();
}
const required=["/api/scout/ingest","/api/scout/progress","/api/scout/ingest/complete"];
const controlPass=results.filter(r=>!r.replace).every(r=>required.every(p=>r.calls.some(c=>c.url.endsWith(p)&&c.bearer==="Bearer OLD_MINTED_A")));
const defectReproduced=results.filter(r=>r.replace).every(r=>required.every(p=>r.calls.some(c=>c.url.endsWith(p)&&c.bearer==="Bearer NEW_A")));
console.log(JSON.stringify({started,ended:new Date().toISOString(),durationMs:performance.now()-begin,node:process.version,network:false,controlPass,defectReproduced,results},null,2));
if(!controlPass||!defectReproduced)process.exitCode=1;
