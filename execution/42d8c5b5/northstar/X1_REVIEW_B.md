# X1 REVIEW B (T4, second lens): PARTIAL (stopped by the parent's handoff)

PR tgp-importer-extension #35, head `7ac1fe9abf67d0ae65afaaa2f66506471882541e`, base `a889f4ad`. Worktree `/home/user/workspace/worktrees/rev-x1-b` (detached at the head; PR not modified).
Reviewer probes (scratch file, not in the PR): `execution/42d8c5b5/handoff-wip/x1-review-b.probe.spec.js`. Per-spec log: `handoff-wip/x1-review-b-specs.log`.

## Verdict: **NO-GO** (0 A, 4 B, 4 C). All B items have small closures; after they close, the PR is GO from this lens.

## Test run (file by file, shared machine)
- 69 of 70 specs pass.
- `policy-gates.spec.js`: 7 tests hit the 5 s timeout while the machine load was about 8.5. This is the same child-process starvation the build report describes; I did not attribute it to the PR. CI is green.

## What holds (verified)
- **Worker restart fails closed.** Probe P2 shows a fresh worker holds `authorizedOrigin=null`, does not resume the run, and refuses `start_capture` with `capture_origin_not_authorized`.
- **The registry is vendor-free and fails closed.**
  - An unknown origin throws `UnknownPlatformError` (blueprint) or returns `null` (extractor), which becomes `site_not_learned: <origin>`, reported before the TGP auth check.
  - The core has no vendor names. The only non-legacy, non-test match is `scripts/browser-load-proof.mjs`, which is tooling and is already listed in the build report.
- **The legacy matcher does not over-match lookalike hosts.** Probe P4 found no false positives for `eviltruecoach.co`, `truecoach.co.evil.com`, `http://` or a trailing dot. By design (carried over from `detect.js`) it does accept any `*.truecoach.co` and any port.
- **The capture attach gate is correct at attach time.** Its order is https → not TGP → equals the authorized origin → `permissions.contains`.
- **The collector ID lifecycle holds.** `registerSourceCollector` unregisters first, so a duplicate ID is impossible, and an unregister error is swallowed.
- **Denial is covered.** The popup sends nothing when the request is denied or returns a non-boolean.

## Findings
**B1: Revoking the grant mid-run is not honoured; it is checked only when the run is admitted and when the debugger attaches.**
- Evidence: probe P1 revokes the grant after the first source page. The crawl makes 3 more source fetches, never calls `contains` again, and ends `ingest_succeeded`.
- Evidence: probe P3 attaches the debugger, then clears the authorized origin and revokes the grant. The debugger stays attached (0 detach calls) and `stopCapture` still returns entries.
- No `chrome.permissions.onRemoved` listener exists, and `settleRun` does not tear down capture sessions.
- Harm: after the coach revokes access, the run keeps using the coach's bearer. In real Chrome, CORS usually breaks these fetches, but that is not deterministic and gives no honest error code. The debugger does not need host permission, so a capture continues after revocation. The capture path has no product sender today, so that part is latent.
- Blocks: the grant's clause 3 guarantee that a tab is allowed only while `contains` is true.
- Minimum closure:
  - Add a `permissions.onRemoved` listener in the worker: abort the in-flight run's controller, tear down capture sessions for that origin, and clear the authorized origin, with the stable code `origin_revoked: <origin>`.
  - Make `settleRun` tear down capture sessions.
  - Add a test for each.

**B2: The legacy `start_ingest` path escapes the single authorized origin (suffix matcher).**
- Evidence: probe P4 authorizes `https://brand.truecoach.co`, and the legacy extractor then fetches `https://app.truecoach.co/proxy/api/organizations` with the bearer and `credentials: "include"`.
- The extractor never receives `allowedOrigins`.
- `start_ingest` has no product sender, but any trusted extension page can reach it.
- Blocks: the claim in the `background.js` header that the run is confined to the one authorized origin.
- Minimum closure (either one):
  - Make the legacy matcher an exact origin match on `new URL(TRUECOACH_API_BASE).origin`. This is allowed because the grant only requires byte-identical behaviour for `app.truecoach.co`.
  - Or refuse to run the extractor unless the authorized origin equals the extractor's API origin.

**B3: The dynamic collector outlives a dead worker.**
- With `persistAcrossSessions:false`, the registration lives until the browser restarts, and it survives a worker restart.
- Evidence: probe P2 shows the first worker registered the collector and the new worker never unregisters it at startup.
- Harm: `content/main.js` keeps injecting into every page load on the granted origin outside any run. Each load wakes the worker with `platform_tab_live` and the full URL.
- Blocks: the build report's claim that the collector is "run-scoped".
- Minimum closure: call `unregisterSourceCollector()` when the worker module starts. No run can be in flight at that moment. Add a test.

**B4: The tests cannot prove origin binding, mid-run revocation or a worker restart.**
- The `permissions.contains` mock in `background-mock.js` returns true for any https origin. So "granted A, start on B → `origin_not_granted`" is not tested, and a check against the wrong origin would still pass.
- There is no test for mid-run revocation, a worker restart, or the tab navigating to another origin between Start and token collection.
- Minimum closure: make the mock's grants specific to each origin and mutable, then add these tests (probes P1–P4 can seed them).

**C1: The popup's Chrome behaviour is unproven in real Chrome.**
- `permissions.request` runs after `await tabs.query`, and a spec pins that order. This relies on Chrome's roughly 5 s transient user activation. The pattern is common, but only mocks test it.
- The permission prompt may also close the action popup (there is old Stack Overflow evidence), which would drop the `.then` that sends `start_import`. The first Start on a new site would then do nothing, and a second press would work.
- This fails closed, but it breaks "Start once".
- Closure: prove it in real Chrome with an updated `browser-load-proof`. Otherwise, read the tab origin when the popup opens and call `request` synchronously in the click handler, and/or have the worker complete a pending Start from `permissions.onAdded`.

**C2:** The Chrome host grant persists after the run (there is no `permissions.remove`). This is acceptable if intended, and it should be stated as such.

**C3:** `executeScript` plus the registration can inject the collector twice into one tab, adding duplicate listeners. It is harmless: the first reply wins.

**C4:** A matcher that throws surfaces as "blueprint resolve failed" (start_import) or as an unhandled rejection (start_ingest, where `resolveExtractor` is outside the try). It still fails closed. Closure: catch the error in `lookup`.

## Not done
- `popup/outcome.js` and `_locales` copy review.
- A real-Chrome run.
- A full `optional_host_permissions` port-pattern check.
