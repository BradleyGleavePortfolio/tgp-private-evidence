import { register } from "node:module";
const sab = new SharedArrayBuffer(4);
globalThis.__shimGen = new Int32Array(sab);
register("./shim-hooks.mjs", import.meta.url, { data: { sab } });
const { run } = await import("./mini-vitest-shim.mjs");
const ok = await run(process.argv[2]);
process.exit(ok ? 0 : 1);
