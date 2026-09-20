# S4 Importer — Independent Audit A, Round 1 (T4R1)

Auditor: S4 independent auditor A (subagent). Canonical model: Claude Fable 5, High requested; the actual reasoning setting is not exposed to me and I do not claim one.
Report path: `execution/audits/s4-r1/a/REPORT.md` (private; parent is publisher). Peer report B was not read.
Finalised under parent instruction to close against the frozen candidate and the evidence available at 2026-09-20 ~17:15Z; investigation was not expanded after that instruction.

## 1. Identity (verified by me)

| Item | Value |
|---|---|
| Worktree | `worktrees/audit-s4-r1` (read-only; `git status --porcelain` empty) |
| Head | `a6d885a10d7dbc64e99961f44e0f6fe7bea5dfba` |
| Tree | `b8abca3c458e6bc1494333b1c44af8f38b651591` |
| Base (importer main) | `0111be661922234d670bbf23e23d270eec1b4a4e` (confirmed as merge-base) |
| Chain | `fc7fdf6` (#21) ← `15636ff` (#23) ← `c0824cb` (#24) ← `49c1aa9` (#25) ← `a6d885a` (packaging/browser proof) |
| Cumulative diff vs base | 64 files, +7259 / −1008 |
| Commit identity | author/committer Bradley Gleave <bradley@bradleytgpcoaching.com> on all chain commits inspected |

## 2. Scope reviewed and actions actually taken

Reviewed (read in full or targeted): `manifest.json`, `background.js`, `content.js`, `popup/popup.js`, `popup/outcome.js`, `popup/pair.js` (partial), `shared/session.js`, `shared/replay/engine.js`, `shared/replay/blueprint.js` (origin/template enforcement sections), `shared/replay/source-fetch.js` and ingest/settlement helpers reached from `background.js`, `_locales/en/messages.json`, `scripts/package-extension.mjs`, `scripts/browser-load-proof.mjs`, `test/package-integrity.spec.js`, `jsconfig.json` + `types/punycode.d.ts`, `.github/workflows/ci.yml`, `.github/workflows/secrets-scan.yml`, `lefthook.yml`, `docs/TRANSFER_OUTCOME_BOUNDARY.md`, `execution/s4-importer/R1-HANDOFF.md`, `MILESTONE-1.md`, all files under `execution/s4-importer/logs/`.

Not reviewed line-by-line (pre-existing on main or outside this round's risk): the TrueCoach extractor/adapter internals, blueprint normaliser beyond origin/template gates, popup pairing UI beyond the `session_established` producer, tests other than `package-integrity.spec.js`.

Actions (all outside the candidate worktree; nothing committed, pushed, installed, deployed; no account or credential contact):
1. `git archive a6d885a` → `/tmp/s4audit/src`, node_modules symlinked from the builder worktree (same lockfile). Ran `node scripts/package-extension.mjs` twice.
2. `git clone --shared` of the repo → `/tmp/s4audit/repo` at `a6d885a` with `main` pointed at `0111be66`; ran the repository's own gates there.
3. Compared produced zip with `execution/s4-importer/artifacts/tgp-importer-extension-0.3.0-rc.1.zip` (`cmp`), listed entries, and compared every entry to `git cat-file a6d885a:<path>`.
4. Ran `vitest run test/package-integrity.spec.js` on the snapshot.
5. Read the builder's browser-proof logs try1–try3 and `browser-load-proof.try3.json`. I did not launch Chrome (heavy validation; not within my step/lock budget and finalisation was ordered).

## 3. Independent evidence produced

| Check | Result |
|---|---|
| Package reproducibility | Two independent builds → sha256 `0b2f377dacfeca2eba84e90792cea11ff262b8e78b49717ee2badf81ae927e6c`, 208731 bytes, 36 entries; byte-identical (`cmp`) to the builder's artifact in `execution/s4-importer/artifacts/`. |
| Package content = source | Every zip entry byte-identical to the blob at `a6d885a`; `unzip -tq` OK. Packager is manifest-closure based; grep found no runtime `chrome.runtime.getURL`/`executeScript` references outside the closure except `popup/icon-128.png` (packaged). All 10 `getMessage` keys and popup `data-i18n` keys resolve in `_locales/en/messages.json`. |
| `test/package-integrity.spec.js` | 15/15 pass at `a6d885a` (4.25 s). |
| Repo gates at `a6d885a` | `check-banned`, `check-flag-discipline`, `check-production-fixtures`, `check-deploy-readiness`, `check-hook-config`: all OK. `format:check` OK (45 tracked files). `lint` rc=0. `type-check` (both tsconfigs) rc=0. |
| Manifest vs main | Only `default_locale: "en"` added. Permissions: activeTab, debugger, notifications, storage, tabs; hosts `https://app.truecoach.co/*`, `https://*.truecoach.co/*`, `https://api.tgp.coach/*`; `optional_host_permissions ["*://*/*"]`; no `externally_connectable`, no `web_accessible_resources`, no custom CSP; content script only on truecoach https. |

Not produced by me (evidence gaps, see §6): full vitest at `a6d885a`; browser proof.

## 4. Findings

Stable IDs `S4-A-NN`. "Material" = prevents clearance on its own.

### S4-A-01 — MATERIAL (evidence/harness): browser loader proof does not exist for this head, and the frozen harness is invalid
Evidence:
- `logs/browser-proof.try1.log` (head `a6d885a`, frozen script): aborted with `SyntaxError: "undefined" is not valid JSON` at `scripts/browser-load-proof.mjs:323` — `Runtime.evaluate` returned no `result.value` and the script does not handle `exceptionDetails`.
- `logs/browser-proof.try2.log`: line numbers match the *modified, uncommitted* script in the builder worktree (`scripts/browser-load-proof.mjs` dirty, ~75+/40−), not the frozen head.
- `logs/browser-load-proof.try3.json` (modified script): the worker the harness bound to is `chrome-extension://nkeimhogjdpnpccoofpliimaahmaaome/thunk.js`, manifest version `1.4.5`, API surface includes `feedbackPrivate`/`webrtcLoggingPrivate` — a Chrome component extension, not the TGP importer. The TGP extension id appears only in the isolated-world list (`aechanidjooefekldeahmenklembgapa`), which does show the packaged content script was injected on the synthetic origin. 7 of 11 checks FAIL; exit 1.
- Frozen script defects (read at `a6d885a`): (a) worker target selection is "first `service_worker` target whose URL starts with `chrome-extension://`" — not bound to the loaded package's extension id; `--disable-extensions-except` does not disable component extensions; (b) check "service worker evaluated from the package" is `check(name, true, …)` — hard-coded pass, vacuous; (c) no `exceptionDetails` handling on evaluate results.
Consequence: the S4 acceptance item "real loader/browser proof" is unmet at this head. Any proof later produced with the modified script is not bound to `a6d885a` (G09) and would require a new head plus re-attestation. Positive and negative-control runs both absent. Only Chrome for Testing 147 is available; `minimum_chrome_version` 116 is unexercised.
Smallest remediation (for the owner, not applied by me): in a new head, select the worker whose `chrome.runtime.id` equals the loaded extension id (derive from the load path or match `getManifest().name`/`version_name`), replace the hard-coded `true` with a real assertion, handle `exceptionDetails`, then run positive + negative control and record the JSON with the new head/zip hash.

### S4-A-02 — MATERIAL (evidence gap): no full test-suite run at the candidate head
`logs/baseline-49c1aa9-vitest.log` shows 59 files / 1654 tests pass at parent `49c1aa9` (exit 0, 193 s). No run exists at `a6d885a` (expected 60 files / 1669 with `package-integrity.spec.js`). I ran only the new spec (15/15) plus the deterministic gates above. Under R1_COMMON ("missing tests … prevent clearance") this is a clearance blocker until the parent runs `npm test` at `a6d885a`. The a6d885a-only changes are non-shipping (scripts, test, jsconfig, types, docs, CI), so I assess the regression risk as low, but that is an inference, not evidence.

### S4-A-03 — Nonmaterial (hardening, partly pre-existing): router gating inconsistent across message types
`start_import` requires `isTrustedExtensionPage(sender)` (no tab, `chrome-extension://` URL) and re-derives the source token/origin itself. `start_ingest` (legacy path accepting caller-supplied `sourceToken` and `url`) and `start_capture`/`stop_capture` (debugger attach) are gated only by `sender.id === chrome.runtime.id`. No shipping sender of `start_ingest` exists at head (grep), `externally_connectable` is absent, and the builder's own threat model (compromised content script) is what motivated the `start_import` gate — so the legacy path is unreachable in practice but inconsistently protected. Remediation: gate all three with `isTrustedExtensionPage` or delete `start_ingest`.

### S4-A-04 — Nonmaterial (pre-existing): unused `optional_host_permissions ["*://*/*"]`
Declared since main (`a856385`/`4f11683`), never requested by shipping code; the manifest test tolerates ≤1 optional entry. Dead surface that widens what a future `permissions.request` could obtain. Remediation: remove.

### S4-A-05 — Nonmaterial (PII boundary, note): `lastError` persisted to `chrome.storage.local` may contain a full tab URL
`broadcastStatus` persists `lastError`; messages include `unsupported site: ${url}` / `unsafe import origin: ${url}` (full tab URL, query included) and arbitrary `err.message` from blueprint normalisation. `storage.local` is disk-persisted, extension-private, unencrypted. No token or customer record path found; tokens are confined to memory (`accessTokenInMemory`) and `chrome.storage.session` (`tgp_refresh_token`), never `.local`. Remediation: persist `new URL(url).origin` only, and map `err.message` to static categories.

### S4-A-06 — Nonmaterial (state truthfulness, accepted boundary): "cancelled" surfaces as `ingest_failed` / "import cancelled"
Engine returns `status: "cancelled"` only on `AbortError`; the sole abort source is TGP auth loss, whose sender throws a `TgpAuthLostError` first, so `cancelled` is effectively reachable only if an in-flight source fetch is aborted. Background maps it to `ingest_failed` with detail "import cancelled" and does not settle; popup shows "Transfer needs attention" + interrupted detail. Labelled and non-lying, but there is no customer cancel affordance and no explicit cancelled state in the receipt schema. Documented in `docs/TRANSFER_OUTCOME_BOUNDARY.md`. Not a defect against the acceptance row; noted for the owner.

### S4-A-07 — Nonmaterial (accepted boundary): Start permanently locked after any recorded run
`popup/outcome.js` disables Start whenever a recorded intent exists; clearing occurs only via session-expiry → pairing. Copy is consistent ("have this result reviewed before another transfer", "Automatic recovery is not available yet"). Truthful; usability limitation, deliberate per docs.

### S4-A-08 — Nonmaterial (gate input change, T4 note): sandbox workaround embedded in `jsconfig.json`
`paths` pins `string_decoder` → `types/punycode.d.ts` (`declare module "string_decoder";` = `any`) to defeat a stray ancestor `node_modules` in the sandbox breaking `tsc` and thus `check:hooks`. Harmless for extension source (no `string_decoder` use; `skipLibCheck`), follows the existing `punycode` precedent, and `type-check` passes in my clone. It is an environment-driven change to a trusted-check input and should be called out to reviewers.

### S4-A-09 — Nonmaterial (gate changes reviewed): CI
`ci.yml` drops the LOC-budget and test:src-ratio steps (consistent with the constitution's deletion of volume quotas); `secrets-scan.yml` added on `pull_request` with SHA-pinned actions and redacted-artifact retention; `lefthook.yml` adds staged secrets scan. CI runs `npm test` (which includes `package-integrity.spec.js`) but does not run `npm run package` or the browser proof; browser proof remains out-of-band evidence. Node 22 in CI vs Node 20.20.1 locally — packager uses only Buffer/crypto, so no determinism concern identified.

### S4-A-10 — Positive observations (no finding)
- Session boundary: access token memory-only; refresh token in `chrome.storage.session` (trusted contexts only by default); epoch/mutex guards against torn or resurrected sessions; token never logged/broadcast/returned. `clearTokens` is local-only and says so.
- Source fetch: adapter `Authorization` stripped, bearer applied last, `redirect: "error"`, 401/403 → `AuthLostError` without clearing TGP tokens.
- Origin confinement: `allowedOrigins` is required, must be https, must exactly match `apiBase` origin; templates root-relative with sentinel-origin proof; cursor values must be query strings; IP-literal hosts refused.
- Receipts: ingest ack fail-closed (bounded body, `received === expected`, `0 ≤ deduped ≤ received`); complete refreshes once on 401 and throws on non-2xx; engine distinguishes `complete` / `partial` / `empty` / `failed`; all customer copy says "staged … Migration is not verified", satisfying "explicit distinction from native import completion".
- Content script answers only `sender.id === chrome.runtime.id`; bearer read is a labelled heuristic ("credential candidate"); fixed console text only.
- Debugger capture allowlist is exact `https://app.truecoach.co`.
- #26 content already present at `49c1aa9` (not re-applied — correct). Donor `312280bb` not cherry-picked; only `shared/blueprint/url-templates.js` of its files exists at head and is not manifest-reachable — disposition left to owner, not a blind pick.

## 5. Distinctions

- Defects at head: S4-A-01 harness defects (non-shipping code but acceptance-critical); S4-A-03/04/05 shipping hardening items (nonmaterial).
- Evidence gaps: S4-A-01 (no valid proof), S4-A-02 (no full suite at head).
- Infrastructure limits: only Chrome for Testing 147 available; sandbox stray `node_modules` (S4-A-08 cause); I did not hold the heavy-validation lock.
- Pre-existing scope: S4-A-04; `start_ingest`/capture gating in S4-A-03 predates this chain.

## 6. Evidence gaps / requests to parent

1. `npm test` at exactly `a6d885a` (expect 60 files / 1669) with head recorded in the log.
2. Browser proof positive + negative-control JSON produced by a *committed* harness at a new head that binds to the TGP extension id and has no vacuous checks; re-attest package hash at that head.
3. Owner decision on S4-A-03/04/05 (may ship as-is with documented acceptance).

## 7. Verdict

**NOT CLEARED at `a6d885a10d7dbc64e99961f44e0f6fe7bea5dfba` (tree `b8abca3c…`).**

Reason: two material items — S4-A-01 (no valid loader/browser proof; frozen harness binds to the wrong extension and contains a hard-coded pass) and S4-A-02 (no full test run at head). The shipping extension code reviewed shows no credential leak, constrained origins/permissions, truthful staged/receipt/settlement copy, and a reproducible, source-identical package (independently confirmed). If items 1–2 of §6 are satisfied at a new head, a risk-scoped re-audit of the harness diff and the new logs would be sufficient; a full re-read is not indicated unless shipping files change.

Limits: no Chrome run by me; no full suite by me; unreviewed areas listed in §2; all conclusions rest on static reading plus the reproductions in §3. No secrets, customer records, environment values or raw log payloads are included in this report.
