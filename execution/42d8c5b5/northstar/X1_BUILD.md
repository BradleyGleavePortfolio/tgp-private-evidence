# X1 BUILD — extension origin authorization (T4)

Grant: `X1_GRANT.md`. Repo `BradleyGleavePortfolio/tgp-importer-extension`, base `main` @ `a889f4ad`.

| item | value |
|---|---|
| PR | https://github.com/BradleyGleavePortfolio/tgp-importer-extension/pull/35 (open, **not merged**, not published) |
| branch / head | `x1/origin-authorization` @ `7ac1fe9abf67d0ae65afaaa2f66506471882541e` (one commit, one non-force push) |
| author | Bradley Gleave <bradley@bradleytgpcoaching.com>, no co-author trailer |
| CI | CI (push) run 36353810368 **success** 1m28s; CI (pull_request) run 36353834502 **success** 1m29s; CodeQL 36353834516 **success**; Secrets scan 36353834517 **success** |
| prod LOC | 21 files, **+398 / −205** raw (`git diff a889f4a HEAD -M --shortstat -- . ':!test' ':!scripts' ':!docs' ':!*.md' ':!.gitleaks.toml'`); **+388 / −195** with `-w`. Renames (7 legacy files) counted at their 1-line import change each. Within the ≤400 grant. |
| test LOC | 15 files, +1002 / −355 (one new spec `test/origin-authorization.spec.js`, 286 lines; `chrome-mock.js`, `protocol.spec.js`, `replay-truecoach-blueprint.spec.js` include a 4→2-space prettier reformat forced by `check-format` on touched files) |
| tooling | `scripts/lib/shipping.mjs` +10 (chrome.scripting path is a classic-script reference); `.gitleaks.toml` 1-line path allowlist extension for the same synthetic JWT constant the sibling specs already allowlist |

## What changed (per grant clause)

1. **manifest.json** — every truecoach host removed from `host_permissions`; static `content_scripts` deleted; `optional_host_permissions` tightened to `["https://*/*"]`; `"scripting"` added. `content/main.js` is still needed: `background.js` `collectSourceToken` sends `collect_source_token` to the tab and the classic script is the only producer (usage search: `rg -n collect_source_token` → `background.js`, `content/main.js`, tests). It is now registered dynamically by `registerSourceCollector(origin, tabId)`: `chrome.scripting.registerContentScripts([{ id: "tgp-source-collector", js: ["content/main.js"], matches: [origin + "/*"], runAt: "document_idle", persistAcrossSessions: false }])` plus `executeScript` into the already-loaded tab, and unregistered when the run settles (`settleRun`).
2. **Authorization = Start** — `popup/popup.js` `requestStartImport(runtime, tabs, permissions)` derives the active tab's https origin, refuses non-https (`origin_not_https`) and TGP origins (`origin_is_tgp`) before asking Chrome, then `permissions.request({ origins: [origin + "/*"] })`; denial → `origin_not_authorized` and no message is sent. The worker (`background.js` `authorizeSourceOrigin`) re-checks with `chrome.permissions.contains`, refuses TGP origins, and calls `setAuthorizedOrigin` on `shared/session.js` (memory-only; validated bare `https://host[:port]`; cleared in `settleRun` and in `clearUnderLock`). Never persisted.
3. **Confinement** — `shared/capture-policy.js`: `ALLOWED_CAPTURE_HOSTS` deleted. Order: `capture_no_url` → `capture_bad_url` → `capture_non_https` → `capture_tgp_origin` → `capture_origin_not_authorized` (origin ≠ `getAuthorizedOrigin()`) → `capture_origin_not_granted` (`chrome.permissions.contains` false). Replay path: `allowedOrigins = [authorized.origin]` into `normalizeBlueprint`.
4. **No vendor names in core** — `shared/protocol.js` loses `TRUECOACH_API_BASE`, gains `isTgpOrigin(origin)`. `shared/replay/resolve.js` is a vendor-free registry: `register(originMatcher, factory)`, `registerExtractor(originMatcher, platform, factory)`, `resolveBlueprint(origin)` (throws `UnknownPlatformError` with `.origin`), `resolveExtractor(origin, deps)` → `{ platform, extractor } | null`. `background.js` has no `platform === "truecoach"`; the reader is a registry lookup; it contains exactly one `import "./legacy/index.js";` (pinned by test). `extractors/detect.js` deleted (its hostname dispatch became `legacy/index.js` `matchesTrueCoachOrigin`, registered as the matcher). Moved byte-identical except one import line each: `extractors/truecoach/*` → `legacy/truecoach/*`, `extractors/truecoach.js` → `legacy/truecoach.js`; new `legacy/truecoach/api-base.js` holds the API base; new `legacy/index.js` registers blueprint + extractor. `extractors/_interface.js` stays (vendor-free contract; N1 is editing it concurrently).
5. **Behaviour** — TrueCoach e2e (`replay-truecoach-e2e.spec.js`, `start-import.spec.js` full crawl with real collector producer) unchanged and green; `sourcePlatform: "truecoach"` still emitted from the legacy registrant's `PLATFORM`. Unknown origin → `site_not_learned: <origin>`, resolved **before** the TGP session preflight so it is never reported as a sign-in problem (pinned in `ingest-auth.spec.js`, `router-principal-gate.spec.js`, `origin-authorization.spec.js`).
6. Out of scope untouched (no learning, backend, mobile, CWS).
7. **Vendor-name guard** — `.vendor-name-guard.json` is **not** on `origin/main` at finish (`6387323`), so no shrink was applied. Files that still contain the vendor name after this PR, i.e. the exact allowlist N1's guard would need once both land: `legacy/**`, `test/**` (specs, helpers, `test/fixtures/**`, `test/secrets-scan-controls.py`), `README.md`, `docs/{AUTO_DISCOVERY,DECISION_V03_AUTONOMOUS_CRAWL,DESIGN,PACKAGE_PROOF,REAL_GOAL_EXECUTION_PLAN,ROADMAP,SECRETS_SCANNING,TIER0_CONTRACT_INTEGRITY,first-principles}.md`, `scripts/browser-load-proof.mjs`, `.gitleaks.toml` (spec path names). N1's draft entries for `extractors/truecoach/**`, `extractors/truecoach.js`, `extractors/detect.js`, `manifest.json`, `background.js`, `shared/capture-policy.js`, `shared/protocol.js`, `shared/replay/resolve.js`, `_locales/en/messages.json` are all retired by this PR (those paths are now vendor-free or gone) and would fail its stale-entry check if kept.

## Permission diff

| | before (a889f4a) | after (7ac1fe9) |
|---|---|---|
| `permissions` | tabs, storage, activeTab, notifications, debugger | tabs, storage, activeTab, notifications, debugger, **scripting** |
| `host_permissions` | `https://app.truecoach.co/*`, `https://*.truecoach.co/*`, `https://api.tgp.coach/*` | `https://api.tgp.coach/*` |
| `optional_host_permissions` | `*://*/*` | `https://*/*` |
| `content_scripts` | static: `content/main.js` on `https://app.truecoach.co/*`, `https://*.truecoach.co/*` | none; dynamic registration for `<granted origin>/*`, run-scoped, `persistAcrossSessions:false` |

## Error codes

Added (popup, decided before any message): `origin_not_https`, `origin_is_tgp`, `origin_not_authorized`.
Added (worker snapshot `lastError`): `origin_is_tgp: <origin>`, `origin_not_granted: <origin>`, `site_not_learned: <origin>`. Kept: `unsafe import origin: <origin|(invalid url)>`.
Added (capture policy): `capture_tgp_origin`, `capture_origin_not_authorized`, `capture_origin_not_granted`.
Removed: `unsupported site:`, `no extractor for`, `no blueprint for`, `capture_host_not_allowed`.
Popup copy: `prestart_origin_not_authorized`, `prestart_site_not_learned` added to `_locales/en/messages.json`; `prestart_page_unsupported` and `prestart_no_reader` removed (unreachable); `replay_notify_staged` placeholder example no longer names a vendor.

## Proof run

- Local (node only): `npm run lint`, `npm run type-check`, `node scripts/check-format.mjs`, `check-banned`, `check-flag-discipline`, `check-production-fixtures`, `check-deploy-readiness`, `check-hook-config` all OK; lefthook pre-commit (secrets via gitleaks 8.30.0, banned, deploy-readiness, lint, type-check, format) passed on the commit.
- Local vitest: the sandbox (2 CPUs, load 8–10 from sibling agents) starved a single full `npm test` (policy-gates/policy-alignment spawn child processes and hit 5 s timeouts). Every spec was therefore run file-by-file: 70/70 pass (the five that timed out under peak load — `ingest-acknowledgement`, `ingest-auth`, `policy-alignment`, `popup-staging`, `transfer-outcome-popup` — were re-run and pass). CI on GitHub runs the same `npm test` and is green twice.
- The moved `legacy/**` files keep their original 4-space formatting (moved byte-identical; `scripts/check-format.mjs` scope is `content|extractors|popup|shared|test`, so `legacy/` is a frozen oracle outside the canonical-format scope). `jsconfig.json` includes `legacy/**/*.js` so type-check still covers it.

## Follow-ups (not in this slice)

- `scripts/browser-load-proof.mjs` (Chrome-driven, not CI) still assumes a static content script on a source host; it needs the Start-gesture grant flow when next run.
- `docs/CAPTURE_MODEL.md` had no allowlist wording to update; README still describes host permissions in the old shape (N1 owns README edits).
