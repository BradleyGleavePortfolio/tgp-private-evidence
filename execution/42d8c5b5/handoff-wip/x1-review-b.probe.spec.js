// Reviewer B adversarial probes for X1 (not part of the PR; scratch only).
import { describe, it, expect, vi } from "vitest";
import {
  makeBgMock,
  installChrome,
  acceptedIngest,
} from "../test/helpers/background-mock.js";
import { fakePageStore, realSourceTab } from "../test/helpers/source-tab.js";

const REFRESH_KEY = "tgp_refresh_token";
const REFRESH_URL = "https://api.tgp.coach/api/auth/extension/refresh";
const INGEST_URL = "https://api.tgp.coach/api/scout/ingest";
const COMPLETE_URL = "https://api.tgp.coach/api/scout/ingest/complete";
const TAB_URL = "https://app.truecoach.co/clients";
const TAB_ORIGIN = "https://app.truecoach.co";
const SRC_JWT = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJjb2FjaCJ9.s1g-nature_TOKEN";
const flush = (n = 6) => {
  let p = Promise.resolve();
  for (let i = 0; i < n; i += 1)
    p = p.then(() => new Promise((r) => setTimeout(r, 0)));
  return p;
};
const snaps = (m) => m.sent.filter((x) => x && x.kind === "status_snapshot");

async function boot(opts) {
  vi.resetModules();
  const mock = makeBgMock(opts);
  installChrome(mock);
  global.fetch = vi.fn();
  const sessionModule = await import("../shared/session.js");
  await import("../background.js");
  return { mock, sessionModule };
}

function tab(url = TAB_URL) {
  return {
    url,
    sendMessage: realSourceTab("test-extension-id", [
      fakePageStore(),
      fakePageStore([["k", SRC_JWT]]),
    ]),
  };
}

describe("P1 revocation mid-run", () => {
  it("a grant revoked after admission does not stop the crawl (no onRemoved, no per-fetch contains)", async () => {
    const { mock } = await boot({
      session: new Map([[REFRESH_KEY, "seed"]]),
      tab: tab(),
    });
    let revoked = false;
    let containsAfterRevoke = 0;
    const realContains = mock.chrome.permissions.contains;
    mock.chrome.permissions.contains = async (q) => {
      if (revoked) {
        containsAfterRevoke += 1;
        return false;
      }
      return realContains(q);
    };
    const sourceFetchesAfterRevoke = [];
    // @ts-expect-error vi.fn
    global.fetch.mockImplementation(async (url, init) => {
      if (url === REFRESH_URL)
        return { ok: true, status: 200, json: async () => ({ access_token: "A" }) };
      if (url.startsWith("https://app.truecoach.co/")) {
        revoked = true; // coach revokes the site grant after the first source page
        sourceFetchesAfterRevoke.push(url);
        if (url.includes("/clients?") && url.includes("page=1"))
          return { ok: true, status: 200, json: async () => ({ clients: [{ id: "c1" }] }) };
        if (url.includes("/clients?"))
          return { ok: true, status: 200, json: async () => ({ clients: [] }) };
        return { ok: true, status: 200, json: async () => ({ notes: [] }) };
      }
      if (url === INGEST_URL) return acceptedIngest(init);
      if (url === COMPLETE_URL) return { ok: true, status: 200 };
      throw new Error(`unrouted ${url}`);
    });
    expect(mock.chrome.permissions.onRemoved).toBeUndefined();
    await mock.dispatch({ kind: "start_import", url: TAB_URL, tabId: 1 });
    const t0 = Date.now();
    while (Date.now() - t0 < 15000) {
      const s = snaps(mock).at(-1)?.intent?.status;
      if (s === "ingest_succeeded" || s === "ingest_failed" || s === "ingest_partial") break;
      await flush(2);
    }
    console.log("P1 last", JSON.stringify(snaps(mock).at(-1)).slice(0, 400));
    const final = snaps(mock).at(-1)?.intent?.status;
    console.log("P1 final", final, "source fetches", sourceFetchesAfterRevoke.length, "contains after revoke", containsAfterRevoke);
    expect(sourceFetchesAfterRevoke.length).toBeGreaterThan(1);
    expect(containsAfterRevoke).toBe(0);
    expect(final).toBe("ingest_succeeded");
  }, 20000);
});

describe("P2 worker restart mid-run", () => {
  it("a fresh worker holds no authorized origin, does not resume, and performs no collector cleanup at startup", async () => {
    const first = await boot({
      session: new Map([[REFRESH_KEY, "seed"]]),
      tab: { url: TAB_URL, sendMessage: () => new Promise(() => {}) }, // collector never answers: run in flight
    });
    // @ts-expect-error vi.fn
    global.fetch.mockImplementation(async (url) =>
      url === REFRESH_URL
        ? { ok: true, status: 200, json: async () => ({ access_token: "A" }) }
        : new Promise(() => {}),
    );
    await first.mock.dispatch({ kind: "start_import", url: TAB_URL, tabId: 1 });
    await flush(10);
    console.log("P2 first-worker registrations", JSON.stringify(first.mock.scripting.registered));
    expect(first.mock.scripting.registered).toHaveLength(1);
    expect(first.sessionModule.getAuthorizedOrigin()).toBe(TAB_ORIGIN);
    // Worker killed: module state gone; Chrome-side scripting registrations are
    // browser state and survive. Model it by carrying the registry over.
    const survivors = first.mock.scripting;
    const second = await boot({ session: new Map([[REFRESH_KEY, "seed"]]), tab: tab() });
    second.mock.scripting.registered.push(...survivors.registered);
    await flush();
    expect(second.sessionModule.getAuthorizedOrigin()).toBeNull();
    // No startup unregister: any registration from the dead run is left live.
    expect(second.mock.scripting.unregistered).toHaveLength(0);
    // Capture refuses (fail closed) on the restarted worker.
    const cap = await second.mock.dispatch({ kind: "start_capture", tabId: 1 });
    expect(cap).toEqual({ ok: false, error: "capture_origin_not_authorized" });
    console.log("P2 capture after restart", JSON.stringify(cap));
  });
});

describe("P3 capture outlives authorization", () => {
  it("a debugger attached during a run stays attached after the run settles and after revocation", async () => {
    const { makeChromeMock, installChrome: inst } = await import("../test/helpers/chrome-mock.js");
    vi.resetModules();
    const mock = makeChromeMock();
    inst(mock);
    const session = await import("../shared/session.js");
    const capture = await import("../shared/capture.js");
    session.setAuthorizedOrigin(mock.defaultOrigin);
    mock.setTabUrl(21, "https://app.truecoach.co/clients");
    await capture.attachDebugger(21);
    session.clearAuthorizedOrigin(); // run settled
    mock.revoke(`${mock.defaultOrigin}/*`); // grant revoked
    const detaches = (mock.calls.detach ?? []).length;
    console.log("P3 detach calls after settle+revoke", detaches);
    expect(detaches).toBe(0);
    // stopCapture still hands back entries for the no-longer-authorized tab.
    const snap = await capture.stopCapture(21);
    expect(snap).toBeTruthy();
  });
});

describe("P4 legacy suffix matcher vs confinement", () => {
  it("start_ingest authorized for a brand subdomain fetches a DIFFERENT origin", async () => {
    const brand = "https://brand.truecoach.co/clients";
    const { mock, sessionModule } = await boot({
      session: new Map([[REFRESH_KEY, "seed"]]),
      tab: tab(brand),
    });
    const urls = [];
    // @ts-expect-error vi.fn
    global.fetch.mockImplementation(async (url, init) => {
      urls.push(url);
      if (url === REFRESH_URL)
        return { ok: true, status: 200, json: async () => ({ access_token: "A" }) };
      if (url === INGEST_URL) return acceptedIngest(init);
      if (url === COMPLETE_URL) return { ok: true, status: 200 };
      return { ok: true, status: 200, json: async () => ({ clients: [], data: [] }) };
    });
    await mock.dispatch({ kind: "start_ingest", url: brand, sourceToken: SRC_JWT });
    await flush(2);
    const authorized = sessionModule.getAuthorizedOrigin();
    { const t0 = Date.now(); while (Date.now() - t0 < 6000 && !urls.some((u) => !u.startsWith("https://api.tgp.coach"))) await flush(2); }
    console.log("P4 urls", JSON.stringify(urls), JSON.stringify(snaps(mock).at(-1)).slice(0,300));
    const source = urls.filter((u) => !u.startsWith("https://api.tgp.coach"));
    console.log("P4 authorized", authorized, "source fetch origins", [...new Set(source.map((u) => new URL(u).origin))]);
    expect(authorized).toBe("https://brand.truecoach.co");
    expect(source.some((u) => new URL(u).origin !== "https://brand.truecoach.co")).toBe(true);
  }, 20000);

  it("matcher table", async () => {
    const { matchesTrueCoachOrigin: m } = await import("../legacy/index.js");
    const rows = {
      "https://app.truecoach.co": m("https://app.truecoach.co"),
      "https://truecoach.co": m("https://truecoach.co"),
      "https://anything.truecoach.co": m("https://anything.truecoach.co"),
      "https://a.b.truecoach.co": m("https://a.b.truecoach.co"),
      "https://eviltruecoach.co": m("https://eviltruecoach.co"),
      "https://truecoach.co.evil.com": m("https://truecoach.co.evil.com"),
      "https://APP.TRUECOACH.CO": m("https://APP.TRUECOACH.CO"),
      "https://app.truecoach.co.": m("https://app.truecoach.co."),
      "https://app.truecoach.co:8443": m("https://app.truecoach.co:8443"),
      "http://app.truecoach.co": m("http://app.truecoach.co"),
    };
    console.log("P4 matcher", JSON.stringify(rows));
    expect(rows["https://eviltruecoach.co"]).toBe(false);
    expect(rows["https://truecoach.co.evil.com"]).toBe(false);
  });

  it("registry fails closed with no registrant and on throwing matcher", async () => {
    vi.resetModules();
    const r = await import("../shared/replay/resolve.js");
    expect(() => r.resolveBlueprint("https://unknown.example")).toThrow("unknown_platform");
    expect(r.resolveExtractor("https://unknown.example", {})).toBeNull();
    r.register(() => {
      throw new Error("boom");
    }, () => ({}));
    let threw = null;
    try {
      r.resolveBlueprint("https://x.example");
    } catch (e) {
      threw = e;
    }
    console.log("P4 throwing matcher ->", threw && threw.message, r.isUnknownPlatform(threw));
  });
});
