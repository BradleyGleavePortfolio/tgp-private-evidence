// Independent follow-up: finite microtask interleavings at public HTTP/storage
// boundaries only. Actual source imports; no rewritten module or test framework.
import { pathToFileURL } from "node:url";
const root="/home/user/workspace/worktrees/s4-r5";
const {makeBgMock}=await import(pathToFileURL(root+"/test/helpers/background-mock.js"));
const mock=makeBgMock(), started=new Date().toISOString(), began=performance.now();
globalThis.chrome=mock.chrome;
await import(pathToFileURL(root+"/background.js"));
const session=await import(pathToFileURL(root+"/shared/session.js"));
const key="tgp_refresh_token", area=mock.chrome.storage.session, originalSet=area.set;
const defer=()=>{let resolve;const promise=new Promise(r=>resolve=r);return{promise,resolve}};
const flush=async(n=100)=>{for(let i=0;i<n;i++)await Promise.resolve()};
let captures=[], acknowledged=false;
const originalSend=mock.chrome.runtime.sendMessage;
mock.chrome.runtime.sendMessage=msg=>{
 captures.push({kind:msg.kind,error:msg.lastError??null,generation:session.getSessionGeneration(),acknowledged});
 return originalSend(msg);
};
const watchdog=setTimeout(()=>{console.error("AUDIT_BUDGET_EXCEEDED");process.exit(2)},10000);
const results=[];
try {
 for(const kind of ["start_import","start_ingest"]){
  for(let delay=0;delay<=40;delay++){
   area.set=originalSet;await session.clearTokens();await flush();
   mock.sessionMap.set(key,"OLD_R");mock.sent.length=0;captures=[];acknowledged=false;
   const response=defer(),persist=defer();let fetches=0,entered=false;
   globalThis.fetch=async(url)=>{if(!url.endsWith("/refresh"))throw Error("unexpected request");fetches++;return response.promise};
   area.set=async obj=>{entered=true;await persist.promise;return originalSet(obj)};
   const oldGeneration=session.getSessionGeneration();
   const startAck=await mock.dispatch({kind,url:"https://app.truecoach.co/clients",tabId:42});
   await flush();
   if(fetches!==1)throw Error("refresh not admitted");
   const pairing=mock.dispatch({kind:"session_established",accessToken:"NEW_A",refreshToken:"NEW_R"}).then(r=>{acknowledged=true;return r});
   await flush();if(!entered)throw Error("replacement not parked");
   response.resolve(new Response(null,{status:401}));
   await flush(delay);persist.resolve();const replacementAck=await pairing;
   await flush();
   const authEvents=captures.filter(c=>c.kind==="auth_required");
   results.push({kind,delay,oldGeneration,newGeneration:session.getSessionGeneration(),startAck,replacementAck,authEvents,terminal:mock.sent.filter(m=>m.kind==="status_snapshot").at(-1),sessionState:await mock.dispatch({kind:"request_session_state"}),stored:mock.sessionMap.get(key)});
  }
 }
 const stale=results.filter(r=>r.authEvents.some(e=>e.generation!==r.oldGeneration));
 const acknowledgedStale=stale.filter(r=>r.authEvents.some(e=>e.acknowledged));
 console.log(JSON.stringify({started,ended:new Date().toISOString(),durationMs:performance.now()-began,node:process.version,network:false,children:false,cases:results.length,staleAuthCases:stale.length,acknowledgedStaleAuthCases:acknowledgedStale.length,results},null,2));
 // A discriminator: exit 1 specifically denotes observed stale auth reporting.
 process.exitCode=stale.length?1:0;
}catch(error){console.log(JSON.stringify({error:String(error.stack),results},null,2));process.exitCode=2}
finally{clearTimeout(watchdog);area.set=originalSet;await session.clearTokens()}
