// Independent audit A: real Web Streams; deterministic manual deadline firing.
// No dependencies, network, browser, or candidate writes.
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
import { resolve } from "node:path";
const root=resolve(process.argv[2]);
const net=await import(pathToFileURL(resolve(root,"shared/net.js")));
const {redeemPairingCode}=await import(pathToFileURL(resolve(root,"shared/pairing.js")));
const realSetTimeout=globalThis.setTimeout, realClearTimeout=globalThis.clearTimeout;
const timers=new Set(), logs=[], checks=[];
const originalWarn=console.warn;
console.warn=(...args)=>logs.push(args.join(" "));
globalThis.setTimeout=(fn,ms)=>{ const h={fn,ms}; timers.add(h); return h; };
globalThis.clearTimeout=h=>{timers.delete(h);};
const flush=async()=>{for(let i=0;i<60;i++) await Promise.resolve();};
const tickDeadline=async()=>{
  const active=[...timers].filter(h=>h.ms===15000);
  assert(active.length>0,"deadline was cleared before body completed");
  for(const h of active){timers.delete(h);h.fn();}
  await flush();
};
const open=()=> {
  let cancelled=0;
  const response=new Response(new ReadableStream({
    start(c){c.enqueue(new TextEncoder().encode('{"access_token":'));},
    cancel(){cancelled++; return new Promise(()=>{});}
  }));
  return {response,get cancelled(){return cancelled;}};
};
try {
  for(const status of [200,409]){
    const o=open();
    const response=status===200?o.response:new Response(o.response.body,{status});
    let sends=0, result, settled=false, signal;
    const promise=redeemPairingCode("123456",{
      fetch:async(_url,init)=>{signal=init.signal;return response;},
      sendMessage:async()=>{sends++;return {ok:true};},
    }).then(r=>{result=r;settled=true;});
    await flush();
    assert.equal(settled,false);
    await tickDeadline();
    await promise;
    assert.equal(result.ok,false);
    assert.equal(result.error,"That took too long. Check your connection and try again.");
    assert.equal(signal.aborted,true);
    assert.equal(response.body.locked,false);
    assert.equal(o.cancelled,1);
    assert.equal(sends,0);
    checks.push(`pair ${status}: body stall deadline, hung cancellation, reader release, no forwarding`);
  }
  const exact=JSON.stringify({v:"x".repeat(net.MAX_AUTH_BODY_BYTES-8)});
  assert.equal(new TextEncoder().encode(exact).length,net.MAX_AUTH_BODY_BYTES);
  assert.equal((await net.readBoundedJson(new Response(exact))).v.length,net.MAX_AUTH_BODY_BYTES-8);
  await assert.rejects(net.readBoundedJson(new Response(exact+" ")),{name:"BodyError",message:"body_invalid"});
  checks.push("exact 16384 bytes accepted; 16385 bytes refused");
  await assert.rejects(net.readBoundedJson(new Response(new Uint8Array([0x22,0xff,0x22]))),{name:"BodyError",message:"body_invalid"});
  checks.push("invalid UTF-8 refuses without diagnostic bytes");
  const ac=new AbortController(),o=open();
  const pending=net.fetchWithTimeout(async()=>o.response,"https://synthetic.invalid",{signal:ac.signal},15000,net.readBoundedJson);
  const rejected=assert.rejects(pending,{name:"AbortError",message:"aborted"});
  await flush(); ac.abort(); await rejected; await flush();
  assert.equal(o.response.body.locked,false);
  checks.push("caller abort settles and releases real stream");
  const bad=new Response(new ReadableStream({
    start(c){c.enqueue(new Uint8Array(net.MAX_AUTH_BODY_BYTES+1));},
    cancel(){return Promise.reject(new Error("PRIVATE_BODY_CANCEL_SENTINEL"));}
  }));
  await assert.rejects(net.readBoundedJson(bad),{name:"BodyError",message:"body_invalid"});
  await flush();
  assert(logs.some(line=>line.includes("auth_body_cancel_failed")));
  assert(!logs.some(line=>line.includes("PRIVATE_BODY_CANCEL_SENTINEL")));
  checks.push("cancel rejection yields only fixed event, not underlying error text");
  const store=new Map([["tgp_refresh_token","R1_SYNTHETIC"]]);
  globalThis.chrome={storage:{session:{
    get:async key=>store.has(key)?{[key]:store.get(key)}:{},
    set:async obj=>{for(const[k,v]of Object.entries(obj))store.set(k,v);},
    remove:async key=>{store.delete(key);}
  }}};
  const session=await import(pathToFileURL(resolve(root,"shared/session.js")));
  let fetchCount=0;
  globalThis.fetch=async()=>{fetchCount++;return open().response;};
  const refreshA=session.refreshAccessToken(),refreshB=session.refreshAccessToken();
  await flush(); assert.equal(fetchCount,1);
  await tickDeadline();
  assert.deepEqual(await Promise.all([refreshA,refreshB]),[null,null]);
  assert.equal(store.get("tgp_refresh_token"),"R1_SYNTHETIC");
  globalThis.fetch=async()=>{fetchCount++;return Response.json({access_token:"A2_SYNTHETIC"});};
  assert.equal(await session.refreshAccessToken(),"A2_SYNTHETIC");
  assert.equal(fetchCount,2);
  checks.push("stalled refresh coalesced callers settle null; token retained; next call retries");
  assert.equal(timers.size,0);
  console.log(JSON.stringify({node:process.version,actualNetwork:false,
    pass:true,checks,logs,liveTimersAtEnd:timers.size},null,2));
} finally {
  console.warn=originalWarn;
  globalThis.setTimeout=realSetTimeout;
  globalThis.clearTimeout=realClearTimeout;
}
