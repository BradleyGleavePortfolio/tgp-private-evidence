# S4 — extension reliability and package proof — R2 candidate REPORT

Lane: S4 (importer extension). Grade/model requested: T4, Claude Fable 5 High
(requested setting; the actual reasoning setting is not observable from inside
the run and is not claimed). Date: 2026-09-20, finished 11:20 PDT (18:20Z).

This is a NEW candidate built forward from preserved PR #25 (49c1aa96) through
the frozen R1 head. It is not a recovered Agent83 artifact and inherits none of
Agent83's audit claims. A browser loader proof is NOT native import completion
(G02/G09): nothing here demonstrates a real TrueCoach → TGP import.

## 1. Exact identity

| item | value |
|---|---|
| repo | github.com/BradleyGleavePortfolio/tgp-importer-extension (PUBLIC — nothing pushed) |
| public base (merge-base with origin/main) | `0111be661922234d670bbf23e23d270eec1b4a4e` |
| preserved cumulative chain | #21 fc7fdf6 → #23 15636ff → #24 c0824cb → #25 `49c1aa96` (all ancestors, untouched) |
| R1 frozen head (unchanged) | `a6d885a10d7dbc64e99961f44e0f6fe7bea5dfba` tree `b8abca3c458e6bc1494333b1c44af8f38b651591` |
| R2 intermediate | `a2a52fd461398c34b301e5ebfaeafae7c7c8de6c` (gating + origin-only text + harness rebind) |
| **R2 final head** | **`c5a5ae12c5b3c3e32a4601c99319ad7c0d980057`** |
| **R2 final tree** | **`5f3c8f6a729427ce6c23bcb1ba18dc7b986b7447`** |
| branch / worktree | `execute/20260920-s4-importer` at `/home/user/workspace/worktrees/s4-importer` (clean, `git status --porcelain` empty) |
| author AND committer (both commits) | `Bradley Gleave <bradley@bradleytgpcoaching.com>`; no AI trailers (verified `git log --format=%an/%ae/%cn/%ce`) |
| shipping package | `dist/tgp-importer-extension-0.3.0-rc.1.zip`, 36 files, 209725 bytes, sha256 `e2ee1f5cc09094f3485c07db866d02f73f2a086d5a4d22e362da5e904b2e1e98` — reproduced byte-identical twice (after a2a52fd and again inside the full-gates run at c5a5ae1) |
| R1 package (for comparison) | sha256 `0b2f377dacfeca2eba84e90792cea11ff262b8e78b49717ee2badf81ae927e6c` (208731 bytes; = #25 shipping bytes). Hash changed because `background.js` is a shipping file. |
| recovery bundle | `execution/s4-importer/s4-importer-c5a5ae1.bundle` sha256 `f99feba3b4016159cb7ed9351a0f05d5e41f235a6ebf0210e23b170791d97ca9` (refs: branch + origin/main; `git bundle verify` OK; requires only public base 0111be66) |
| #26 d595092 | not an ancestor; its policy content already present at 49c1aa9 — not reapplied |
| donor 312280bb | inspected, not cherry-picked (touches only non-manifest-reachable files → zero shipping-byte effect) |

## 2. Changed files since R1 frozen head a6d885a (4 files, +414/−78)

| file | shipping? | rationale |
|---|---|---|
| `background.js` (+31) | YES | (a) `start_ingest`, `start_capture`, `stop_capture` now require the full trusted-extension-page sender shape via `isTrustedExtensionPage(sender)`, responding `{ok:false,error:"untrusted_sender"}` — same gate `start_import`/`session_established` already had (A-03/B-05). (b) `describedOrigin(url)`: pre-run `lastError` text is `unsupported site: <origin>` / `unsafe import origin: <origin>` / `(invalid url)` — never a full URL, because lastError is persisted to `chrome.storage.local` and rendered in the popup (A-05/B-07). |
| `test/router-principal-gate.spec.js` (new, 9 tests) | no | pins both: 4 privileged kinds × content-script principal → `untrusted_sender`, no fetch/debugger/snapshot side effects; trusted page still reaches tabId validation; three origin-only text cases + invalid-url case. |
| `scripts/browser-load-proof.mjs` (+323/−78) | no | root-cause harness repair, see §4. |
| `docs/PACKAGE_PROOF.md` | no | describes the truthful checks and the negative-control signature. |

No product-direction change, no manifest change, no schema/generator touch (S1 owns), no new executor.

## 3. What ran at final head c5a5ae1 (all under `execution/test-validation.lock`, holder lines in `test-validation.lock.holders`)

| step | result | log (under `execution/s4-importer/logs/`) |
|---|---|---|
| `npx vitest run --passWithNoTests=false` | **61 files / 1678 tests passed**, 194 s (R1 baseline at 49c1aa9: 59/1654; +15 package-integrity, +9 router-principal-gate) | `vitest.c5a5ae1.log`, `full-gates.c5a5ae1.log` |
| `npm run lint` | exit 0 | `lint.c5a5ae1.log` |
| `npm run type-check` (`tsc -p jsconfig.json && tsc -p jsconfig.scripts.json`) | exit 0 | `type-check.c5a5ae1.log` |
| `npm run format:check` | exit 0 | `format-check.c5a5ae1.log` |
| `npm run gates` | exit 0 | `gates.c5a5ae1.log` |
| `node scripts/package-extension.mjs` | sha256 `e2ee1f5c…` (byte-identical reproduction) | `full-gates.c5a5ae1.log` |
| **positive browser proof** (`run-browser-proof.sh r2c`) | **11/11 PASS, exit 0**; bound to zip `e2ee1f5c…` and inventory source head `c5a5ae1`, clean | `browser-proof.r2c.log`, `browser-load-proof.r2c.positive.json` |
| **negative-control browser proof** (same run, `--negative-control`) | **DETECTED, exit 0**: `noReceiver=true syntaxExceptionSeen=true unrelatedFailures=0`; the 3 failed checks are exactly the receiver/exception checks; mutated `content/main.js` sha256 `5702ac6f…` recorded | `browser-load-proof.r2c.negative-control.json` |

Environment: Node v20.20.1, npm 10.8.2, 2 vCPU Linux sandbox; Chrome for Testing 147.0.7727.15 (`/home/user/.cache/ms-playwright/chromium-1217/chrome-linux64/chrome`, overridable with `TGP_CHROME`); openssl 3.5.5; headless=new; synthetic HTTPS origin `app.truecoach.co` mapped to 127.0.0.1 by `--host-resolver-rules` with `MAP * ~NOTFOUND` for everything else; `--testing-fixed-https-port`; self-signed cert pinned via `--ignore-certificate-errors-spki-list`. No customer, source-account or platform contact; synthetic token `synthetic.header.payload-not-a-real-credential` only.

Preserved failed/held runs: `browser-proof.try1..3.log` + `browser-load-proof.try3.json` (R1 harness bound to Chrome component extension `nkeimh…`/thunk.js — see `DIAGNOSIS-browser-proof-try1-3.md`); try4 cancelled per user override (`run-try4.out`, `HELD-STATUS.md`); **r2a** at a2a52fd: both proofs aborted with `Cannot read properties of undefined (reading 'id')` (`browser-proof.r2a.log`, `browser-load-proof.r2a.*.json`) — root cause: attaching on target discovery preceded the worker's extension bindings (~1.5 s after launch); fixed in c5a5ae1 by polling readiness (one root-caused fix, one dry run `r2b-dry` with the uncommitted fix, then the committed run r2c — no blind retries).

What did NOT run: no native import against a real source account (out of scope and prohibited); no Chrome Web Store packaging/publish; no CI run (CI does not run package/proof — B-10, recommendation only); no run on Windows/macOS Chrome.

## 4. Browser loader harness — root-cause repair (A-01/B-01, B-03, B-04)

Try1–3 root cause: the worker selector took the first `service_worker` target, which in a fresh profile is Chrome's component extension; one check was hard-coded `true`; `Runtime.evaluate` exceptionDetails were ignored; the abort path was unreachable; the popup check expected `#start-import` which a fresh (unpaired) profile never shows.

Repaired behaviour at c5a5ae1 (`scripts/browser-load-proof.mjs`):

- Worker selected by `new URL(target.url).pathname === "/" + manifest.background.service_worker` and then **asserted**: `chrome.runtime.id === extensionId`, URL host === extensionId, pathname === worker path, runtime manifest `name`/`version`/`version_name`/`background.service_worker` equal the shipped manifest read from the zip. No hard-coded passes remain.
- Readiness wait (≤15 s) for `chrome.runtime.id` and `chrome.runtime.onMessage.hasListeners()`; last observed state stored in evidence.
- `evaluate()` throws on `exceptionDetails` or `undefined`; any thrown error aborts the run, writes `browser-load-proof:aborted` evidence with `abortError`, `progress`, `lastPollError`, and exits 1 (exit 2 is reserved for "runtime unavailable" = explicit gap).
- Popup check is the truthful fresh-profile state: module graph loads, `request_session_state` returns no session, `location.replace("pair.html")`, `#pair-form` and `#code` present, `#start-import` absent.
- Content-script isolated world for the packaged id observed on the synthetic origin; worker `collect_source_token` returns the synthetic token when the page holds it and an honest `{ok:false}` when it does not; token never appears in `chrome.storage.local` keys/values or console output.
- `Network.enable` on page, popup and worker sessions; every `Network.requestWillBeSent` host must be `app.truecoach.co` or `chrome-extension:`; the tautological "only the synthetic origin was contacted" check is gone (B-04).
- Evidence binds `package.sha256`, `package.inventory.source.head/clean`, Chrome product string, extension id, per-check details.
- Negative control passes **only** on the deterministic signature: the collect checks fail with `Could not establish connection. Receiving end does not exist.` while every unrelated check (worker identity, popup, storage, network) still passes; verdict written to evidence `negativeControl` (B-03).

Note: the unpacked extension id differs per run (it derives from the temp extraction path: `iceehob…` positive, `fpclbod…` control); binding is by manifest identity + worker URL, not by a fixed id.

## 5. Deterministic new invariants (tests)

- `test/router-principal-gate.spec.js` (9): content-script principal refused on `start_ingest`/`start_capture`/`stop_capture`/`start_import` with zero side effects; trusted page proceeds; lastError origin-only (path/query/user tokens absent); invalid URL described as `(invalid url)`.
- `test/package-integrity.spec.js` (15, from R1): manifest-closure packaging, deterministic zip, CRC corruption detection, classic-script parse of `content/main.js`, etc.
- Browser proof checks (11 positive + control signature) — executable proof, not a unit test; runs via `npm run proof:browser` / `proof:browser:control`.

## 6. Disposition of ALL R1 findings (auditor A = `execution/audits/s4-r1/a/REPORT.md`, B = `.../b/REPORT.md`)

| finding | class | disposition at c5a5ae1 | consequence if left |
|---|---|---|---|
| A-01 / B-01 harness wrong target, hard-coded pass, no exceptionDetails, unreachable abort, popup expectation | MATERIAL | **FIXED** (§4); positive proof 11/11 at committed head + committed package hash | none remaining for this finding; auditors must re-verify from evidence JSON |
| A-02 / B-02 no full suite/lint/type-check at head | MATERIAL | **CLOSED by evidence**: full vitest 61/1678, lint, type-check, format:check, gates all exit 0 at c5a5ae1 (logs §3) | — |
| A-03 / B-05 `start_ingest`/`start_capture`/`stop_capture` gated by `sender.id` only | nonmaterial (pre-existing hardening) | **FIXED** in shipping `background.js`; pinned by 4 tests. Consequence had it stayed: a compromised content script (same id) could drive the legacy token-accepting entrypoint or attach `chrome.debugger` to a tab. Not claiming it was unexploited — closed by code, not by dormancy. | — |
| A-04 / B-06 `optional_host_permissions ["*://*/*"]` unused; `debugger` permission with no shipped UI trigger | nonmaterial, owner decision | **NOT CHANGED — recorded for owner decision.** Consequence of shipping as-is: `debugger` permission triggers Chrome's install warning and widens the surface if the router were ever reachable by an untrusted principal — that reachability is now closed (A-03), so the remaining consequence is the permission prompt/store-review exposure, not a live capability leak. Removing either is a manifest/product-direction change outside this lane's authorization. | store-review friction; larger declared surface |
| A-05 / B-07 full tab URL persisted in `lastError` | nonmaterial (PII boundary) | **FIXED**: origin only; 4 tests. | — |
| A-06 cancel surfaces as `ingest_failed "import cancelled"` | nonmaterial, accepted boundary | **NOT CHANGED**; documented. Consequence: UI shows a failure state for a user cancel; no data or credential consequence. Changing the status vocabulary touches shared status contract → would need S1/product alignment. | cosmetic truthfulness |
| A-07 Start locked after any recorded run | nonmaterial, deliberate | **NOT CHANGED** (deliberate single-run guard). | operator must reset via documented path |
| A-08 / B-08 `jsconfig.json` paths pin `string_decoder`→`types/punycode.d.ts` | nonmaterial, gate-input change | **UNCHANGED, explained**: stray `/home/user/node_modules/string_decoder@1.1.1` pulled by `@types/node`; same class as the pre-existing punycode workaround; type-check exit 0 with it. Consequence: none on shipping bytes (not in manifest closure). Reviewer may drop it on a clean machine. | none for the package |
| A-09 / B-10 CI does not run `package`/`proof:browser` | nonmaterial, recommendation | **NOT CHANGED** (CI/workflow change is settings-adjacent; not authorized). Recommendation stands: add `npm run package` + `proof:browser` job with Chrome for Testing. | proof drift undetected in CI |
| A-10 positive observations | — | n/a | — |
| B-03 negative control needs pairing with positive run | nonmaterial | **FIXED**: same head, same package, same environment, same lock hold (`browser-proof.r2c.log` contains both); control passes only on the deterministic signature. | — |
| B-04 tautological origin check | nonmaterial | **FIXED**: replaced by observed-network-host assertion. | — |
| B-09 cancel vs auth-loss ordering | nonmaterial, verify | **VERIFIED, no code change**: in `makeSender` (background.js:174–182) the retry-401 path calls `onAuthLost()` (abort + `broadcastAuthRequired`) and then synchronously `throw tgpAuthLost()` inside the awaited send; the engine's backpressure means no other fetch is in flight, the engine rethrows non-abort errors, and `isTgpAuthLost` in `background.js` returns while preserving the session-expired state. Covered by existing `test/start-import-hardening.spec.js` "keeps the 'session expired' state and does not overwrite it with a raw error" (passes in the full run). Consequence if wrong: a raw error string would overwrite "session expired" in the popup — cosmetic, no credential effect. | — |

Nothing above claims that dormancy proves absence of a safety issue; each unchanged item lists the consequence instead.

## 7. Open findings / remaining gaps

1. Browser loader proof is a load/identity/messaging proof only; native import completion against a real source is unproven and out of scope.
2. `debugger` permission and `optional_host_permissions` remain in the manifest pending owner decision (A-04/B-06).
3. Proof runs only on Linux Chrome for Testing 147 headless; not exercised on shipped desktop Chrome builds or other OSes.
4. Unpacked-extension id is path-derived; a store-signed id would differ — harness binds by manifest identity, so this is expected, but the packaged CRX id is unverified.
5. CI does not execute package/proof (A-09/B-10).

## 8. Dependency / ownership conflicts

None introduced. S1 remains sole schema/generator owner — untouched. No shared mutable generated clients used. Lock holds: three short `test-validation.lock` holds (r2a 3 s, r2b-dry 25 s, r2c 25 s) and one 4 min full-gates hold; all released (holder file lines).

## 9. Explicit state

- written: yes (c5a5ae1)
- tested: yes at head — full vitest 61/1678, lint, type-check, format, gates; positive + negative-control browser proof bound to committed package
- audited: R1 audits exist (NOT CLEARED); R2 audit NOT performed — **no R2 clearance is claimed**
- merged: NO · pushed: NO · deployed: NO · feature-flag enabled: NO · store-published: NO · customer-accepted: NO

## 10. Smallest next action

Parent dispatches two independent R2 auditors against head `c5a5ae1` / tree `5f3c8f6a…` / zip `e2ee1f5c…` using the bundle and `PUBLICATION-MANIFEST.md`; they should re-run `npm run package` (expect `e2ee1f5c…`) and `npm run proof:browser` + `proof:browser:control` from the bundle in an isolated environment.

## 11. Recovery

`execution/s4-importer/s4-importer-c5a5ae1.bundle` (sha256 `f99feba3…`), plus R1 bundle `s4-importer-a6d885a.bundle` (sha256 `9d6b1c30…`). Both need only the public base `0111be66`.
