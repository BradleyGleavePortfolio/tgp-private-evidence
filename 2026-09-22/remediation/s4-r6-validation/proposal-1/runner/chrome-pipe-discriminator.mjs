// S4 R6 validation — Chrome-alone `--remote-debugging-pipe` transport discriminator.
//
// R4's browser proof (A3) aborted with "CDP timeout: Browser.getVersion" before
// any loader check ran: nothing ever arrived on fd 4. This script isolates the
// TRANSPORT question from the extension-loader question. It launches the SAME
// Chrome binary with the same isolation flags the proof harness uses (no
// extension loaded, all DNS NOTFOUND, throwaway profile), writes one
// Browser.getVersion request on fd 3 and waits up to --timeout-ms (default
// 15000) for bytes on fd 4. It is a transport diagnostic ONLY — a live pipe is
// not extension-loader proof; a dead pipe is a harness/runtime block, not a
// product failure.
//
// Exit codes: 0 pipe alive (a JSON response with .result.product arrived);
//             1 pipe dead (no bytes / no parseable response before the deadline);
//             2 runtime unavailable (no Chrome binary) or harness error.
// Cleanup: the spawned Chrome is the ONLY process this script signals; it is
// terminated with SIGTERM, then SIGKILL after 5 s, and the exit is recorded.
//
// usage: node chrome-pipe-discriminator.mjs --chrome <path> --out <evidence.json> [--label cold|warm] [--timeout-ms 15000]
import { spawn } from "node:child_process";
import { existsSync, mkdtempSync, rmSync, writeFileSync, readFileSync } from "node:fs";
import { createHash } from "node:crypto";
import { tmpdir } from "node:os";
import { join } from "node:path";

function argument(flag, fallback) {
  const i = process.argv.indexOf(flag);
  return i >= 0 && process.argv[i + 1] ? process.argv[i + 1] : fallback;
}
const chrome = process.env.TGP_CHROME ?? argument("--chrome", "");
const out = argument("--out", "");
const label = argument("--label", "cold");
const timeoutMs = Number(argument("--timeout-ms", "15000"));
if (!out) {
  process.stderr.write("usage: --chrome <path> --out <evidence.json>\n");
  process.exit(2);
}
if (!chrome || !existsSync(chrome)) {
  writeFileSync(out, JSON.stringify({ kind: "chrome-pipe-discriminator", label, verdict: "NO_CHROME", chrome }, null, 2) + "\n");
  process.stderr.write("GAP: no Chrome binary\n");
  process.exit(2);
}
const started = new Date().toISOString();
const began = performance.now();
const scratch = mkdtempSync(join(tmpdir(), "tgp-pipe-discriminator-"));
const child = spawn(
  chrome,
  [
    "--headless=new",
    "--remote-debugging-pipe",
    `--user-data-dir=${join(scratch, "profile")}`,
    "--host-resolver-rules=MAP * ~NOTFOUND",
    "--no-first-run",
    "--no-default-browser-check",
    "--disable-background-networking",
    "--disable-component-update",
    "--disable-sync",
    "--disable-gpu",
    "--no-sandbox",
    "about:blank",
  ],
  { stdio: ["ignore", "ignore", "pipe", "pipe", "pipe"] },
);
const stderrChunks = [];
child.stdio[2]?.on("data", (c) => stderrChunks.push(c.toString("utf8")));
let bytes = 0;
let buffer = Buffer.alloc(0);
let response = null;
let firstByteMs = null;
let childExit = null;
child.on("exit", (code, signal) => {
  childExit = { code, signal, atMs: Math.round(performance.now() - began) };
});
const done = new Promise((resolve) => {
  const timer = setTimeout(() => resolve("timeout"), timeoutMs);
  child.stdio[4]?.on("data", (chunk) => {
    if (firstByteMs === null) firstByteMs = Math.round(performance.now() - began);
    bytes += chunk.length;
    buffer = Buffer.concat([buffer, chunk]);
    const end = buffer.indexOf(0);
    if (end >= 0) {
      try {
        response = JSON.parse(buffer.toString("utf8", 0, end));
      } catch (e) {
        response = { parseError: String(e) };
      }
      clearTimeout(timer);
      resolve("response");
    }
  });
  child.on("error", (e) => {
    clearTimeout(timer);
    response = { spawnError: String(e) };
    resolve("spawn-error");
  });
});
child.stdio[3]?.write(`${JSON.stringify({ id: 1, method: "Browser.getVersion", params: {} })}\0`);
const outcome = await done;

// Cleanup of the ONE owned child.
let cleanup = { signalled: null, exitedWithinMs: null };
if (childExit === null) {
  child.kill("SIGTERM");
  cleanup.signalled = "SIGTERM";
  const t0 = performance.now();
  await new Promise((r) => {
    const k = setTimeout(() => {
      if (childExit === null) {
        child.kill("SIGKILL");
        cleanup.signalled = "SIGTERM+SIGKILL";
      }
      setTimeout(r, 1000);
    }, 5000);
    child.on("exit", () => {
      clearTimeout(k);
      r();
    });
  });
  cleanup.exitedWithinMs = Math.round(performance.now() - t0);
}
try {
  rmSync(scratch, { recursive: true, force: true });
} catch {}

const alive = outcome === "response" && response && response.result && typeof response.result.product === "string";
const evidence = {
  kind: "chrome-pipe-discriminator",
  label,
  verdict: alive ? "PIPE_ALIVE" : outcome === "timeout" ? "PIPE_DEAD_TIMEOUT" : "PIPE_DEAD_OTHER",
  transportOnly: true,
  note: "A live pipe is NOT extension-loader proof; a dead pipe is a harness/runtime block, not a product failure.",
  chrome: { path: chrome, sha256: createHash("sha256").update(readFileSync(chrome)).digest("hex") },
  started,
  ended: new Date().toISOString(),
  durationMs: Math.round(performance.now() - began),
  timeoutMs,
  bytesOnFd4: bytes,
  firstByteMs,
  response: alive ? { product: response.result.product, protocolVersion: response.result.protocolVersion } : response,
  childPid: child.pid,
  childExit,
  cleanup,
  stderrHead: stderrChunks.join("").split("\n").slice(0, 20),
};
writeFileSync(out, `${JSON.stringify(evidence, null, 2)}\n`);
process.stdout.write(`${label}: ${evidence.verdict} bytesOnFd4=${bytes} firstByteMs=${firstByteMs}\n`);
process.exit(alive ? 0 : outcome === "spawn-error" ? 2 : 1);
