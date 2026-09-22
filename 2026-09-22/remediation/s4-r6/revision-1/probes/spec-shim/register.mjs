// Dependency-free loader shim: resolves the bare specifier "vitest" to the
// minimal shim below and, after each vi.resetModules(), re-instantiates the
// whole file: graph by appending a generation query to every file URL so the
// spec's loadCold()/loadWarm() get a fresh background.js + shared/session.js
// instance, as vitest's module reset would provide. Generation counter is a
// SharedArrayBuffer because Node 20 runs loader hooks off-thread.
import { register } from "node:module";
const sab = new SharedArrayBuffer(4);
globalThis.__shimGen = new Int32Array(sab);
register("./hooks.mjs", import.meta.url, { data: { sab } });
