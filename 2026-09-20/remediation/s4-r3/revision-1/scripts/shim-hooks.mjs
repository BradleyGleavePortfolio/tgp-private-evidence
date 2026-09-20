// Node module customization hooks (run on the loader thread): map "vitest" to
// the shim and bust the cache for the extension's own modules whenever
// vi.resetModules() bumped the shared generation counter.
let gen = new Int32Array(new SharedArrayBuffer(4));
export function initialize(data) {
  gen = new Int32Array(data.sab);
}
const shim = new URL("./mini-vitest-shim.mjs", import.meta.url).href;
export async function resolve(specifier, context, next) {
  if (specifier === "vitest") return { url: shim, shortCircuit: true };
  const r = await next(specifier, context);
  const g = Atomics.load(gen, 0);
  if (g > 0 && /\/(shared|popup|extractors|content)\/[^?]*\.js$/.test(r.url) && !r.url.includes("?gen=")) {
    return { ...r, url: `${r.url}?gen=${g}` };
  }
  return r;
}
