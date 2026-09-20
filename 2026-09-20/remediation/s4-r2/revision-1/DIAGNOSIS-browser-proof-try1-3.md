# Browser proof attempts try1–try3 on package 0b2f377d… — root cause

All three runs used the same package bytes (sha256
`0b2f377dacfeca2eba84e90792cea11ff262b8e78b49717ee2badf81ae927e6c`) and Chrome
for Testing 147.0.7727.15 (`HeadlessChrome/147.0.0.0`). Logs preserved in
`execution/s4-importer/logs/browser-proof.try{1,2,3}.log`, evidence
`browser-load-proof.try3.json`.

## Classification: harness target-identity defect, not a shipping defect

Evidence in try3 JSON:

- Worker target selected: `chrome-extension://nkeimhogjdpnpccoofpliimaahmaaome/thunk.js`,
  `chrome.runtime.getManifest().version === "1.4.5"`, `chrome.storage` undefined,
  `chrome.*` surface includes `feedbackPrivate`, `webrtcLoggingPrivate`,
  `processes`, `management`. That is a Chrome-internal component extension
  (private APIs are only granted to component extensions). `thunk.js` is not in
  the shipped inventory (36 files, none named thunk.js); the shipped manifest is
  version `0.3.0`.
- The synthetic source page recorded an isolated world for
  `chrome-extension://aechanidjooefekldeahmenklembgapa` — a different id. That is
  the packaged extension: Chrome created a content-script isolated world on
  `https://app.truecoach.co/clients` for exactly one non-component extension, and
  the only one loaded via `--load-extension` was ours. So the classic content
  script `content/main.js` was injected and its world created (this is measured,
  but it was not credited because the harness compared against the wrong id).
- Popup check opened `chrome-extension://nkeimhog…/popup/popup.html` — the wrong
  extension's origin, so `#start-import` was absent by construction.
- `chrome.tabs.query` returned 0 tabs from the wrong worker (component
  extension without `tabs` permission over that URL), so both collect checks and
  the `{ ok:false }` check never exercised our worker.

Harness bug (`scripts/browser-load-proof.mjs` as committed in `a6d885a`): the
worker selector was
`targets.find(t => t.type === "service_worker" && t.url.startsWith("chrome-extension://"))`
— first match wins, and Chrome's component extension worker is discovered
first. `check("service worker evaluated from the package", true, …)` was
hard-coded PASS once any worker attached, which is vacuous. try1 and try2
failed earlier in the same wrong session (`JSON.parse(undefined)` because the
first `Runtime.evaluate` returned no value / `chrome.storage.local` undefined)
— same root cause, surfaced earlier before diagnostics were added.

## Fix (harness only; new candidate head once committed — R1 `a6d885a` unchanged)

1. Read the shipped `manifest.json` from the extracted archive and select the
   worker whose URL pathname equals `/${manifest.background.service_worker}`
   (`/background.js`); wait up to 20 s for that specific target.
2. Derive `extensionId` from that worker URL; the manifest check then compares
   `chrome.runtime.getManifest().version/version_name` against the shipped
   manifest (`0.3.0` / `0.3.0-rc.1`), which is the identity assertion the
   first PASS lacked. Popup, content-world, `tabs.query` and storage checks all
   key off that id.
3. `evaluate()` helper now throws on `exceptionDetails` or undefined value;
   abort path writes evidence JSON with `abortError` and marks the run failed.
4. Negative control (`--negative-control`) appends an `export` to
   `content/main.js` in the extracted tree before launch; Chrome refuses a
   classic script with module syntax, so the content-world and collect checks
   must FAIL and the run exits 0 only when that failure is detected.
   Deterministic: same bytes, same defect, same detection path.

What the shipped bytes did demonstrably do in try3 despite the harness error:
load in Chrome 147 without loader error (no `exceptionThrown` from any
attached session; extension id `aechan…` present), and inject a content
script isolated world on the synthetic source origin. What is NOT yet
demonstrated: worker evaluation/manifest identity, popup graph, token
boundary, `{ ok:false }` path, storage hygiene. Those await try4 (queued
behind `test-validation.lock`, currently held by another agent's full jest).
