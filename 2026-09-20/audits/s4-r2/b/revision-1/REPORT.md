# S4 Importer extension — Independent R2 Audit B (T4)

## 0. Reviewer identity and independence

| Item | Value |
|---|---|
| Role | S4 independent R2 auditor B (subagent, no implementation role in any S4 head) |
| Requested model | Not stated in my dispatch; the parent's routing setting is not observable from inside this run and is not claimed |
| Actual known identity | Claude (Anthropic). Exact model/version string is not exposed to me; none is invented |
| Report path | `execution/audits/s4-r2/b/REPORT.md` (private; parent is sole publisher) |
| Peer R2 report | NOT read; no coordination. Both R1 reports (`s4-r1/a`, `s4-r1/b`) read as required |
| Written | 2026-09-20 ~21:30Z |

Read-only against candidate source. No edit, commit, push, install into the frozen worktree, hosted-system contact, browser launch, or heavy test run. My only executions were two light `node scripts/package-extension.mjs` builds from a `git archive` copy under my own audit directory (`execution/audits/s4-r2/b/scratch/`), using an already-present TypeScript module (`/usr/local/lib/node_modules/vercel/node_modules/typescript`, 5.9.3) symlinked as the only dependency; no `npm install`.

## 1. Exact identity (verified by me)

| Item | Value |
|---|---|
| Worktree | `/home/user/workspace/worktrees/s4` — `git status --porcelain` empty |
| R2 head | `c5a5ae12c5b3c3e32a4601c99319ad7c0d980057` |
| R2 tree | `5f3c8f6a729427ce6c23bcb1ba18dc7b986b7447` |
| Merge-base with public main `0111be661922234d670bbf23e23d270eec1b4a4e` | `0111be66…` (confirmed) |
| R1 frozen head (ancestor) | `a6d885a10d7dbc64e99961f44e0f6fe7bea5dfba`; chain `49c1aa9 → a6d885a → a2a52fd → c5a5ae1` |
| Cumulative diff vs base | 65 files, +7598/−1011 |
| a6d885a → c5a5ae1 | 4 files: `background.js` (+31), `docs/PACKAGE_PROOF.md`, `scripts/browser-load-proof.mjs` (+323/−78), `test/router-principal-gate.spec.js` (new) |
| Author/committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` on 49c1aa9, a6d885a, a2a52fd, c5a5ae1; no AI/co-author trailers found in any message since base |
| Shipping package | `tgp-importer-extension-0.3.0-rc.1.zip` 36 entries, 209 725 bytes, sha256 `e2ee1f5cc09094f3485c07db866d02f73f2a086d5a4d22e362da5e904b2e1e98` |
| Recovery bundle | `s4-importer-c5a5ae1.bundle` — `git bundle verify` OK; heads `c5a5ae1` (`execute/20260920-s4-importer`) and `0111be66` (`origin/main`) |
| Packet | `repos/evidence/2026-09-20/remediation/s4-r2/revision-1/` — `sha256sum -c SHA256SUMS`: every file OK. Local evidence repo head `7328446a` (brief snapshot `7ab6af94` is an ancestor; no diff in `s4-r2` or `s4-r1` paths between them) |

## 2. Scope reviewed and actions taken

Reviewed at `c5a5ae1` (read in full): full `a6d885a..c5a5ae1` diff; `background.js` router (lines 847–1000), `describedOrigin`, `collectSourceToken`, `makeSourceFetch`, `makeSender` 401/auth-loss path, every `lastError:` assignment and `failDetail`/catch paths; `content/main.js`; `scripts/browser-load-proof.mjs` (all 753 lines); `scripts/package-extension.mjs` source-identity block; `test/router-principal-gate.spec.js`; `test/helpers/background-mock.js` dispatch/sender shape; `shared/log.js` event allowlist; `manifest.json` from the rebuilt zip; `test/package-integrity.spec.js` manifest pins; `docs/PACKAGE_PROOF.md` diff. Grep-verified: no `chrome.permissions.request/contains` anywhere; no shipped sender for `start_ingest`/`start_capture`/`stop_capture` (only `shared/protocol.js` defines them; popup sends only `start_import`/`request_*`/pairing kinds); no `console.*` outside `shared/log.js` (allowlisted codes) and `content/main.js` (fixed string).

Packet reviewed: `REPORT.md`, `PUBLICATION-MANIFEST.md`, `R2-CHECKPOINT.md`, `HELD-STATUS.md`, `DIAGNOSIS-browser-proof-try1-3.md`, `run-browser-proof.sh`, `run-full-gates.sh`, all logs (`full-gates`, `vitest`, `lint`, `type-check`, `format-check`, `gates` at c5a5ae1; `browser-proof.{try1,try2,try3,r2a,r2b-dry,r2c}.log`; all seven `browser-load-proof.*.json`).

Not re-read line-by-line in R2 (relied on the two R1 reports, whose inputs are unchanged — verified by unzipping the R1 and R2 packages and `diff -rq`: the only differing shipping file is `background.js`): `shared/session.js`, `shared/net.js`, `shared/replay/*`, `shared/ingest-ack.js`, `shared/capture*.js`, `popup/*`, extractors, the pre-existing 59 spec files. Per G09 the R1 shipping-code observations for those files remain applicable because their bytes are identical.

Actions:
1. Reproduced the package twice from `git archive c5a5ae1` → both `e2ee1f5c…`, 36 files, 209 725 bytes; `cmp` byte-identical to packet artifact `artifacts/tgp-importer-extension-0.3.0-rc.1.c5a5ae1.zip`; `unzip -tq` clean.
2. Compared all 36 zip entries to `git cat-file blob c5a5ae1:<path>` — 36/36 identical.
3. Diffed R1 zip (`0b2f377d…`) vs R2 zip contents — only `background.js` differs, matching the claimed shipping delta.
4. Cross-checked evidence JSONs: `package.sha256`, `inventory.zipSha256` and the log header `zip_sha256` all equal `e2ee1f5c…`; inventory `source.head = c5a5ae1, clean = true`; `full-gates` and `browser-proof.r2c` headers record `head=c5a5ae1 tree=5f3c8f6a dirty=0`.
5. Checked vitest log: `61 passed (61)` files, `1678 passed (1678)` tests, `Start at 18:09:04` (matches the full-gates header), `router-principal-gate.spec.js (9 tests)` and `package-integrity.spec.js (15 tests)` present; 1654 + 15 + 9 = 1678. No skipped/todo/failed markers.

Not done by me: no browser launch (heavy; see §6 for the optional parent command), no full suite rerun (G10 does not require duplication; the attributable bundle was inspected instead).

## 3. Disposition of inherited R1 findings (stable IDs)

| ID | R1 class | My R2 disposition at c5a5ae1 | Basis |
|---|---|---|---|
| S4-A-01 / S4-B-01 — no valid loader proof; harness bound to wrong worker, hard-coded pass, no `exceptionDetails`, unreachable abort path, popup expectation wrong | MATERIAL | **CLOSED** | Harness read in full: worker selected by shipped `manifest.background.service_worker` path and then asserted against `chrome.runtime.id`, worker URL host/path and shipped manifest `name`/`version`/`version_name`/`service_worker`; no `check(name, true, …)` remains; `evaluate()` throws on `exceptionDetails`/undefined; `try/catch/finally` writes `browser-load-proof:aborted` JSON with `abortError`/`progress`/`lastPollError` (proven by the preserved r2a aborted JSONs); popup check asserts the truthful fresh-profile redirect to `pair.html` (`#pair-form`, `#code` present, `#start-import` absent). Positive r2c: 11/11 PASS, evidence bound to zip `e2ee1f5c…` and head `c5a5ae1` clean. |
| S4-A-02 / S4-B-02 — no full suite/lint/type-check at head | MATERIAL | **CLOSED** | `full-gates.c5a5ae1.log` header binds head/tree/dirty=0; vitest 61/1678, lint/type-check/format:check/gates all exit 0; package reproduce `e2ee1f5c…` in the same locked run. |
| S4-A-03 / S4-B-05 — `start_ingest`/`start_capture`/`stop_capture` id-only gated | nonmaterial | **CLOSED by code** | `background.js:898–904, 934–941`: `isTrustedExtensionPage(sender)` → `{ok:false,error:"untrusted_sender"}`. Pinned by 4 content-script-principal cases + 1 trusted-page case in `router-principal-gate.spec.js`, asserting no fetch/attach/detach/snapshot side effects. |
| S4-A-04 / S4-B-06 — `debugger` permission, `optional_host_permissions ["*://*/*"]` | nonmaterial, owner decision | **OPEN — owner decision required before store submission; not a merge blocker** | See §5 for consequence analysis. |
| S4-A-05 / S4-B-07 — full tab URL persisted in `lastError` | nonmaterial | **CLOSED for the pre-run paths; residual noted as S4-R2B-04** | `describedOrigin(url)` → origin or `(invalid url)`; 4 tests assert path/query/client identifiers absent. |
| S4-A-06 — cancel surfaces as `ingest_failed`/"import cancelled" | accepted boundary | **UNCHANGED, accepted** | Status vocabulary is a shared contract; cosmetic truthfulness; no credential/data consequence. |
| S4-A-07 — Start locked after any recorded run | deliberate | **UNCHANGED, accepted** | Documented single-run guard. |
| S4-A-08 / S4-B-08 — `jsconfig.json` `string_decoder` path pin | gate-input change | **UNCHANGED, acceptable** | Non-shipping; type-check exit 0 at head with it; zero package effect (verified: not in the 36-entry closure). |
| S4-A-09 / S4-B-10 — CI does not run `package`/`proof:browser` | recommendation | **OPEN, nonmaterial** | Proof remains out-of-band, log-attested. Recommendation stands. |
| S4-B-03 — negative control needs pairing | nonmaterial | **CLOSED (with note S4-R2B-02)** | r2c positive and control run back-to-back in one lock hold, same zip, same Chrome, same head; control DETECTED with `unrelatedFailures=[]`. |
| S4-B-04 — tautological origin check | nonmaterial | **CLOSED** | Replaced by `Network.requestWillBeSent` host assertion across page/popup/worker sessions (`attemptedHosts=["app.truecoach.co"]`), with the resolver rule recorded as isolation evidence. |
| S4-B-09 — cancel vs auth-loss ordering | verify | **CLOSED by inspection** | `makeSender` calls `onAuthLost()` then synchronously `throw tgpAuthLost()`; engine has no `Promise.all/race` over fetches (grep); `isTgpAuthLost` short-circuits the catch. Existing test "keeps the 'session expired' state…" asserts exactly one friendly terminal state. |
| S4-A-10 / B positives | — | Still hold for unchanged bytes (see §2). | |

## 4. New findings (stable IDs `S4-R2B-nn`)

None is material under G11. Each lists actual consequence.

**S4-R2B-01 — Browser check "synthetic token never reaches extension storage or console output" does not exercise the worker's real token-handling path (nonmaterial; evidence-strength).** The harness invokes `chrome.tabs.sendMessage(…collect_source_token)` directly from a `Runtime.evaluate` in the worker session; the reply returns to the harness, not to `collectSourceToken`/`handleStartImport`. The check therefore proves only that the content script's reply and its console emit nothing beyond the message boundary, and that fresh-profile storage (`tgp_schema_version`, `tgp_status_snapshot`) holds no token. Background handling of the token remains proven by unit tests, not by the browser proof. Consequence: none on shipping bytes; readers of `REPORT.md §4`/`PACKAGE_PROOF.md` must read the claim narrowly. Fix when cheap: rename the check or drive `start_import` from the popup context in a later harness revision.

**S4-R2B-02 — Negative-control acceptance is slightly looser than described (nonmaterial; harness).** `detected = noReceiver && unrelatedFailures.length === 0`; `syntaxExceptionSeen` is recorded but not required, and "content script isolated world created" is excluded from `unrelatedFailures` although in a correct control that check must still PASS (it did in r2c). Consequence: a control run in which the content script were not injected at all would still print DETECTED. Mitigated in r2c by the paired positive run under identical conditions. Fix when cheap: require `syntaxSeen` and remove the isolated-world exclusion.

**S4-R2B-03 — Packet `REPORT.md §4` attributes the wrong extension ids to r2c (nonmaterial; report accuracy).** It cites `iceehob…`/`fpclbod…`, which are the r2b-dry ids; the r2c ids are `opefelmelhcgipfoogkclefmdadflhpd` (positive) and `gndnloahgmmibdheomeedhpamgeihnjl` (control). Consequence: none on evidence validity (binding is by manifest identity + worker URL, and the JSONs are internally consistent). Parent should footnote this when publishing rather than editing the packet.

**S4-R2B-04 — Raw `err.message` still persisted/transmitted on the generic failure path (nonmaterial; PII-boundary residual of A-05).** `handleStartImport`/`handleStartIngest` catch blocks write `err.message` to `lastError` (storage.local + popup) and `errorSummary` (settlement POST). Every reachable constructor on the shipped replay path carries only status codes or fixed strings (`source <status>`, `ingest <type> -> <status>`, `complete <status>`, `progress <status>`, `source_bad_json`, blueprint errors are pre-mapped to `"blueprint resolve failed"`). The one interpolated path (`extractors/truecoach/net.js:71` `GET ${path} -> <status>`) sits behind the legacy `start_ingest` entrypoint, which is now trusted-page gated and has no shipped sender. Consequence: low; a future error source could reintroduce identifiers. Recommend the static-category mapping A-05 proposed.

**S4-R2B-05 — `request_status` / `request_session_state` remain id-only gated (observation).** A content-script principal can read the status snapshot (intent status, counts, origin-only `lastError`, `workerActive`) and the `hasSession` boolean. No credential or customer record is exposed. Nonmaterial; note for owner.

**S4-R2B-06 — Lock-discipline claims not independently verifiable (scope limit).** `execution/test-validation.lock.holders` is not present locally, so the builder's hold durations cannot be checked. Log timestamps are sequential and consistent (r2c 18:08:01–18:08:22Z; full-gates 18:09:04–18:12:58Z). No consequence for the candidate.

## 5. Permission residuals — actual consequence

Manifest at head (from the rebuilt zip): `permissions: tabs, storage, activeTab, notifications, debugger`; `host_permissions: https://app.truecoach.co/*, https://*.truecoach.co/*, https://api.tgp.coach/*`; `optional_host_permissions: ["*://*/*"]`; content script on truecoach hosts only; no `externally_connectable`, no `web_accessible_resources` (pinned by `package-integrity.spec.js`).

- **`debugger`**: the sole exerciser is `shared/capture.js` via `start_capture`, which (a) is refused for any non-trusted-page sender at c5a5ae1, (b) has no shipped sender, (c) asserts the exact `https://app.truecoach.co` allowlist before `chrome.debugger.attach`. Live consequence at this head: no customer, page, or compromised content script can cause a debugger attach. Remaining consequence is release-side, not code-side: Chrome's install-time permission warning and Chrome Web Store review scrutiny for a permission the shipped customer flow never uses, plus latent surface if a future change adds a sender. This is a product/permission decision reserved to the owner (G11 residual acceptance must name owner, limits, expiry, rationale) or a one-line manifest+test removal until capture ships.
- **`optional_host_permissions ["*://*/*"]`**: no `chrome.permissions.request` exists anywhere in the tree; optional host permissions are not prompted at install and grant nothing until requested. Live consequence: none. Latent: a future `permissions.request` could obtain all-host access with a single prompt. Removal is trivially reversible and recommended.
- **`tabs`**: required for `tabs.get/query/sendMessage` on the coach's tab; background reads only the popup-supplied tabId's URL for the origin re-check. Acceptable.
- Host permissions and content-script matches are the minimum for the TrueCoach + TGP API flow.

Merge boundary: not blocking. Release/store-submission boundary: an explicit owner decision must be recorded before publication.

## 6. Evidence gaps, unexplained failures, requests to parent

Unexplained failures: none. Every failed run (try1–3, r2a) has a preserved log, a root cause I could confirm from the artefacts (component-extension worker `nkeimh…/thunk.js` in try3 JSON; `chrome.runtime` undefined ~1.5 s after launch in r2a aborted JSONs) and a code fix visible in the diff (`waitForAsync` readiness poll added in c5a5ae1). r2b-dry is honestly labelled `dirty=1` in its own header and superseded.

Remaining gaps (scope limits, not defects):
1. Browser proof is a loader/identity/messaging proof on Linux Chrome for Testing 147 headless only; `minimum_chrome_version 116`, desktop Chrome, other OSes and a store-signed CRX id are unexercised.
2. **Loader proof is not customer import proof.** Nothing at this head demonstrates a real TrueCoach → TGP import; the extension's receipts explicitly say "staged … Migration is not verified" and that remains the truthful customer state.
3. CI does not execute `package`/`proof:browser` (A-09/B-10).
4. Browser evidence is builder-produced. I judge it adequate (harness read in full, package hash independently reproduced, head/tree/dirty bound in every header). Optional, not required for my verdict: parent may run one auditor-independent replay (~1 min under the lock):
   `cd $(mktemp -d) && git -C /home/user/workspace/worktrees/s4 archive c5a5ae1 | tar -x && ln -s /home/user/workspace/worktrees/s4-importer/node_modules node_modules && node scripts/package-extension.mjs && node scripts/browser-load-proof.mjs --zip dist/tgp-importer-extension-0.3.0-rc.1.zip --out proof.json && node scripts/browser-load-proof.mjs --negative-control --zip dist/tgp-importer-extension-0.3.0-rc.1.zip --out control.json` — expect zip `e2ee1f5c…`, exit 0 twice, `negativeControl.detected=true`.
5. Publication footnote for S4-R2B-03 (id attribution) — no packet edit needed.
6. Owner (Bradley) decision on `debugger` / `optional_host_permissions` before store submission (§5).

## 7. Verdict

**CLEARED — bounded — at head `c5a5ae12c5b3c3e32a4601c99319ad7c0d980057`, tree `5f3c8f6a729427ce6c23bcb1ba18dc7b986b7447`, package `e2ee1f5cc09094f3485c07db866d02f73f2a086d5a4d22e362da5e904b2e1e98`, for the S4 lane's merge boundary (extension reliability + reproducible package + real loader proof).**

Basis: both R1 material findings (harness validity; full-suite evidence at head) are closed by attributable exact-head evidence that I cross-checked; the shipping delta since R1 is a single file (`background.js`) that only tightens the principal gate and narrows persisted error text, pinned by 9 new deterministic tests; the package is independently reproduced byte-identical and source-identical; the harness contains no vacuous checks and fails closed. No new material finding.

Explicit boundaries of this clearance:
- Not release acceptance (G18) and not store-publication clearance: owner decision on `debugger`/`optional_host_permissions` (§5) must be recorded first; CI proof gap stands.
- Not evidence of native import completion or customer acceptance; the loader proof is exactly and only what §6.2 states.
- Nonmaterial residuals S4-R2B-01…05 are recorded for ordinary cleanup; none waives anything.
- Merged: NO · pushed: NO · deployed: NO · enabled: NO · customer-accepted: NO — unchanged and correctly stated by the packet.

Scratch artefacts (rebuilt zips, unzipped trees) are left under `execution/audits/s4-r2/b/scratch/` for the parent.
