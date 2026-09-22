let gen = null;
export function initialize({ sab }) { gen = new Int32Array(sab); }
const shim = new URL("./vitest-shim.mjs", import.meta.url).href;
export async function resolve(specifier, context, next) {
  if (specifier === "vitest") return { url: shim, shortCircuit: true };
  const r = await next(specifier, context);
  if (r.url.startsWith("file:") && !r.url.includes("/spec-shim/")) {
    const u = new URL(r.url);
    if (!u.searchParams.has("g")) u.searchParams.set("g", String(gen ? Atomics.load(gen, 0) : 0));
    return { ...r, url: u.href };
  }
  return r;
}
