// usage: node --import ./register.mjs run-spec.mjs <spec-file>
import { pathToFileURL } from "node:url";
import { resolve } from "node:path";
const spec = resolve(process.argv[2]);
const started = new Date().toISOString(); const began = performance.now();
await import(pathToFileURL(spec).href);
const shim = await import("vitest");
const result = await shim.__run();
console.log(JSON.stringify({ harness: "spec-shim (NOT vitest)", spec, filter: process.env.SHIM_FILTER ?? "", started, ended: new Date().toISOString(), durationMs: Math.round(performance.now() - began), node: process.version, ...result }, null, 2));
process.exitCode = result.failed === 0 && result.passed > 0 ? 0 : 1;
