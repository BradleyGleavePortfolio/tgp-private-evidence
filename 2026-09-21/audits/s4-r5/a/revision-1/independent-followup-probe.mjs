// Audit A: actual frozen module imports, synthetic Chrome/HTTP only.
// No dependency framework, child processes, network or source rewriting.
import {pathToFileURL} from "node:url";
import {webcrypto} from "node:crypto";
globalThis.crypto ??= webcrypto;
const started=new Date().toISOString(), began=performance.now(), observations=[];
const deadline=setTimeout(()=>{console.error("AUDIT_BUDGET_EXCEEDED");process.exit(2)},40000);
const tick=()=>new Promise(r=>setTimeout(r,0));
const flush=async()=>{for(let n=0;n<100;n++)await Promise.resolve()};
const until=async(f,label)=>{const end=performance.now()+7000;while(!f()){if(performance.now()>end)throw Error(label);await tick()}};
const defer=()=>{let resolve;const promise=new Promise(r=>resolve=r);return{promise,resolve}};
const key="tgp_refresh_token",TAB="https://app.truecoach.co/clients";
const replacedText="import stopped — your TGP session changed during the import. Start the import again.";
try {
for(const version of ["s4-r5","s4-r4"]){
  const root="/home/user/workspace/worktrees/"+version;
  const {makeBgMock,acceptedIngest}=await import(pathToFileURL(root+"/test/helpers/background-mock.js"));
  const mock=makeBgMock({tab:{url:TAB,token:"SOURCE"}});
  globalThis.chrome=mock.chrome;
  let calls=[],refreshHook,ingestHook,emptySource=false;
  globalThis.fetch=async(url,init)=>{
    const c={url,bearer:init?.headers?.Authorization??null,refreshToken:url.endsWith("/refresh")?JSON.parse(init.body).refresh_token:null};
    calls.push(c);
    if(url.endsWith("/refresh"))return refreshHook(c.refreshToken);
    if(url.endsWith("/scout/ingest"))return ingestHook(init);
    if(url.endsWith("/progress"))return new Response(null,{status:204});
    if(url.endsWith("/complete"))return new Response(null,{status:200});
    if(url.startsWith("https://app.truecoach.co/")){
      if(emptySource)return Response.json({});
      if(url.includes("/clients?"))return Response.json({clients:url.includes("page=1")?[{id:"c1"}]:[]});
      if(url.endsWith("/clients/c1/notes"))return Response.json({notes:[]});
      return Response.json({});
    }
    throw Error("UNROUTED_SYNTHETIC_REQUEST");
  };
  await import(pathToFileURL(root+"/background.js"));
  const session=await import(pathToFileURL(root+"/shared/session.js"));
  const area=mock.chrome.storage.session,originalSet=area.set,originalRemove=area.remove;
  const pair=(a="NEW_A",r="NEW_R")=>mock.dispatch({kind:"session_established",accessToken:a,refreshToken:r});
  const snapshots=()=>mock.sent.filter(m=>m.kind==="status_snapshot");
  const auth=()=>mock.sent.filter(m=>m.kind==="auth_required");
  const terminal=()=>auth().length||snapshots().at(-1)?.lastError||["ingest_succeeded","ingest_empty","ingest_failed"].includes(snapshots().at(-1)?.intent?.status);
  const start=kind=>mock.dispatch({kind,url:TAB,tabId:42,sourceToken:"SOURCE"});
  const reset=async()=>{area.set=originalSet;area.remove=originalRemove;await session.clearTokens();await flush();mock.sessionMap.set(key,"OLD_R");mock.sent.length=0;calls=[]};
  const record=async(name,extras={})=>{
    await until(terminal,name+" terminal");await flush();
    const result={version,name,...extras,calls:[...calls],authRequired:auth().length,session:[...mock.sessionMap],state:await mock.dispatch({kind:"request_session_state"}),terminal:snapshots().at(-1)};
    result.guardReleased=(await mock.dispatch({kind:"start_import",url:"https://example.invalid",tabId:42}))?.ok===true;
    await flush();observations.push(result);return result;
  };
  for(const kind of ["start_import","start_ingest"]){
    for(const mode of ["control","C3","C1-reject"]){
      await reset();emptySource=kind==="start_ingest";
      const hold=defer();let entered=false;
      ingestHook=init=>acceptedIngest(init);
      refreshHook=()=>mode==="C1-reject"?hold.promise:Response.json({access_token:"OLD_MINTED_A",refresh_token:"OLD_ROTATED_R"});
      if(mode==="C3")area.set=async obj=>{if(obj[key]==="OLD_ROTATED_R"){entered=true;await hold.promise}return originalSet(obj)};
      const startAck=await start(kind);let replacementAck=null;
      if(mode==="C3"){
        await until(()=>entered,"C3 rotation entered");
        const replacing=pair();hold.resolve();replacementAck=await replacing;
      }
      if(mode==="C1-reject"){
        await until(()=>calls.some(c=>c.refreshToken),"C1 refresh on wire");
        replacementAck=await pair();hold.resolve(new Response(null,{status:401}));
      }
      await record(mode+":"+kind,{startAck,replacementAck});
    }
  }
  // C2 external barrier, not a replacement call inside the fetch mock.
  await reset();emptySource=false;await pair("OLD_A","OLD_R");mock.sent.length=0;
  const ingest=defer(),persist=defer();let persistEntered=false;
  ingestHook=()=>ingest.promise;
  refreshHook=r=>Response.json({access_token:"MINTED_"+r,refresh_token:"ROTATED_"+r});
  area.set=async obj=>{if(obj[key]==="NEW_R"){persistEntered=true;await persist.promise}return originalSet(obj)};
  await start("start_import");await until(()=>calls.some(c=>c.url.endsWith("/scout/ingest")),"C2 ingest");
  const replacing=pair();await until(()=>persistEntered,"C2 replacement persist");
  ingest.resolve(new Response(null,{status:401}));await flush();await tick();
  const beforeRelease=calls.filter(c=>c.refreshToken).length;
  persist.resolve();const replacementAck=await replacing;
  await record("C2",{beforeRelease,replacementAck});
  await reset();
  if(version==="s4-r5"){
    // Expanded session controls: three unbound/current joiners, pending
    // replacement failure, clear->re-establish, and rotation persist failure.
    for(const mode of ["replace-mixed","clear-replace-mixed","failed-establish","rotation-persist-failure"]){
      await reset();const expected=session.getSessionGeneration(), gate=defer();
      let entered=false, presented=[], releaseFetch;
      globalThis.fetch=async(_u,init)=>{presented.push(JSON.parse(init.body).refresh_token);return new Promise(r=>releaseFetch=r)};
      let transition;
      if(mode==="clear-replace-mixed"){
        area.remove=async k=>{entered=true;await gate.promise;return originalRemove(k)};
        transition=session.clearTokens();await until(()=>entered,"remove entered");
        transition=Promise.all([transition,session.establishSession("NEW_A","NEW_R")]);
      }else if(mode!=="rotation-persist-failure"){
        area.set=async obj=>{entered=true;await gate.promise;if(mode==="failed-establish")throw Error("synthetic persist failure");return originalSet(obj)};
        transition=session.establishSession("NEW_A","NEW_R");await until(()=>entered,"establish entered");
      }
      const bound=session.refreshAccessToken(expected);
      const unbound=[session.refreshAccessToken(),session.refreshAccessToken(),session.refreshAccessToken()];
      gate.resolve();
      const transitionResult=await transition;
      area.set=originalSet;area.remove=originalRemove;
      const current=session.getSessionGeneration();
      const fresh=session.refreshAccessToken(current);
      await until(()=>presented.length,"refresh started");
      const beforeResponse=[...presented];
      if(mode==="rotation-persist-failure")area.set=async()=>{throw Error("synthetic rotation failure")};
      releaseFetch(Response.json({access_token:"MINTED_CURRENT",refresh_token:"ROTATED_CURRENT"}));
      const values=await Promise.all([bound,...unbound,fresh]);await flush();
      observations.push({version,name:"session:"+mode,expected,current,transitionResult,beforeResponse,presented,values,stored:mock.sessionMap.get(key),generationAfter:session.getSessionGeneration()});
      area.set=originalSet;area.remove=originalRemove;
    }
  }
  await session.clearTokens();
}
const checks=[];
const check=(name,pass)=>checks.push({name,pass:!!pass});
for(const r of observations){
  const candidate=r.version==="s4-r5";
  if(r.name.startsWith("control:")){
    check(r.version+":"+r.name,r.authRequired===0&&r.guardReleased&&r.calls.some(c=>c.url.endsWith("/complete")&&c.bearer==="Bearer OLD_MINTED_A")&&["ingest_succeeded","ingest_empty"].includes(r.terminal.intent?.status));
  }else if(r.name.startsWith("C")){
    const intact=r.session.some(([k,v])=>k===key&&v==="NEW_R");
    if(candidate)check(r.version+":"+r.name,r.authRequired===0&&r.guardReleased&&intact&&r.state.hasSession&&r.terminal.lastError===replacedText&&!r.calls.some(c=>c.bearer==="Bearer NEW_A"||c.refreshToken==="NEW_R"));
    else if(r.name.startsWith("C3"))check(r.version+":"+r.name,r.calls.some(c=>c.url.endsWith("/complete")&&c.bearer==="Bearer NEW_A"));
    else if(r.name.startsWith("C1"))check(r.version+":"+r.name,r.authRequired===1&&intact&&r.state.hasSession);
    else check(r.version+":"+r.name,r.calls.some(c=>c.refreshToken==="NEW_R")&&r.session.some(([k,v])=>k===key&&v==="ROTATED_NEW_R"));
  }else{
    const failure=r.name.endsWith("rotation-persist-failure"),failedEstablish=r.name.endsWith("failed-establish");
    const isReplace=!failure&&!failedEstablish;
    check(r.name+":one-presentation",r.presented.length===1&&r.presented[0]===(isReplace?"NEW_R":"OLD_R"));
    check(r.name+":values",JSON.stringify(r.values)===JSON.stringify(failure?[null,null,null,null,null]:isReplace?[null,"MINTED_CURRENT","MINTED_CURRENT","MINTED_CURRENT","MINTED_CURRENT"]:Array(5).fill("MINTED_CURRENT")));
    check(r.name+":stored",r.stored===(failure?"OLD_R":"ROTATED_CURRENT"));
    check(r.name+":rotation-keeps-generation",r.current===r.generationAfter);
  }
}
const pass=checks.every(c=>c.pass);
console.log(JSON.stringify({started,ended:new Date().toISOString(),durationMs:performance.now()-began,node:process.version,network:false,children:false,pass,checks,observations},null,2));
process.exitCode=pass?0:1;
} catch(error){console.log(JSON.stringify({started,ended:new Date().toISOString(),durationMs:performance.now()-began,node:process.version,error:String(error.stack),observations},null,2));process.exitCode=2}
finally{clearTimeout(deadline)}
