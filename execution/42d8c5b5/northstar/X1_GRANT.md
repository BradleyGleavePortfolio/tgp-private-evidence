# X1 GRANT: extension origin authorization (remove the vendor lock)
Grade: **T4**. It changes browser permissions, debugger/capture origin confinement and credential handling. Builder: claude_fable_5.
Reviews: gpt_6_sol (A) and claude_opus_5_5 (B), both on the final head. North star: execution/42d8c5b5/northstar/NORTH_STAR.md.
Repo tgp-importer-extension, base main a889f4ad. Branch `x1/origin-authorization`, one PR to main, DO NOT MERGE.
Author Bradley Gleave <bradley@bradleytgpcoaching.com>, no AI co-author. Push with single non-force pushes. ≤400 added prod LOC.

## Parent decisions (binding; L0 incorporates them and does not redesign them)
1. **manifest.json:**
   - Remove every truecoach host from `host_permissions` and delete the static `content_scripts` block. Keep `https://api.tgp.coach/*`.
   - Tighten `optional_host_permissions` to `["https://*/*"]`.
   - If content/main.js is still needed, register it dynamically for the granted origin only (adding `scripting`). Otherwise delete it.
     Prove which one with a usage search.
2. **Authorization = Start:**
   - On the popup's Start gesture, request `chrome.permissions.request({origins:[<active tab origin>/*]})`.
   - Denial or a non-HTTPS origin gives an honest, stable error code, and nothing starts.
   - The granted origin becomes the run's single authorized origin, held in the existing session owner (shared/session.js) and never persisted beyond it.
3. **Confinement:**
   - shared/capture-policy.js: delete ALLOWED_CAPTURE_HOSTS. A tab is allowed only if it is https, its origin equals the run's authorized origin,
     `chrome.permissions.contains` is true for it, and it is not a TGP origin.
   - The replay path passes `allowedOrigins:[authorized origin]` to normalizeBlueprint.
4. **No vendor names in core:**
   - shared/protocol.js loses TRUECOACH_API_BASE.
   - shared/replay/resolve.js becomes a vendor-free registry, `register(originMatcher, factory)` plus `resolveBlueprint(origin)`, and fails closed with UnknownPlatformError.
   - background.js loses `if (platform === "truecoach")`; the extractor is chosen by registry lookup.
   - ALL TrueCoach knowledge moves under `legacy/` (a quarantined oracle): its blueprint registration, its extractor binding and its API base.
     background.js may contain exactly one import of `./legacy/index.js`.
   - extractors/detect.js hostname dispatch: fold it into the registry or quarantine it.
5. **Behaviour:** TrueCoach end to end must stay byte-identical for an authorized app.truecoach.co tab. All existing tests stay green; update only
   tests that asserted the removed constants. An unknown origin fails closed with a truthful "this site is not learned yet" code. The learning
   chain replaces that later.
6. **Out of scope:** learning or inference, backend or mobile changes, and Chrome Web Store publishing (owner-reserved).
7. If N1's `.vendor-name-guard.json` exists on main when you finish, shrink the extension allowlist to `legacy/**` plus tests. Otherwise, list
   the exact new allowlist in your report.

## Proof
Run `npm test` and lint locally (node only), then watch CI to green.
Report: PR, head, CI, prod/test LOC, a permission diff table (before/after), and every error code added.
Write BUILD at execution/42d8c5b5/northstar/X1_BUILD.md (commit locally in the evidence repo, no push).
