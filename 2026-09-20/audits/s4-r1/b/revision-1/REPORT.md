# S4 Extension closure — Independent Audit B, Round 1

Auditor: S4 independent auditor B (T4R1). Canonical model: Claude Fable 5, High requested; the actual reasoning setting is not exposed to me and is not claimed.
Report written: 2026-09-20 ~17:20Z. Private output; no peer report read; no verdict coordinated.

## 1. Candidate identity (verified by me)

| Item | Value |
|---|---|
| Snapshot worktree | `worktrees/audit-s4-r1` |
| Head | `a6d885a10d7dbc64e99961f44e0f6fe7bea5dfba` |
| Tree | `b8abca3c458e6bc1494333b1c44af8f38b651591` |
| Merge base with `origin/main` | `0111be661922234d670bbf23e23d270eec1b4a4e` |
| Ancestry | `fc7fdf6` (#21) → `15636ff` (#23) → `c0824cb` (#24) → `49c1aa9` (#25) → `a6d885a` (new packaging/browser-proof commit) |
| Commit identity | author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no co-author trailer |
| Cumulative diff vs base | 64 files, +7259/−1008 |
| a6d885a vs 49c1aa9 | 8 non-shipping files only: `docs/PACKAGE_PROOF.md`, `jsconfig.json`, `package.json`, `scripts/browser-load-proof.mjs`, `scripts/lib/shipping.mjs`, `scripts/package-extension.mjs`, `test/package-integrity.spec.js`, `types/punycode.d.ts` |

Byte identity: shipped-file sha256s at `49c1aa9` and `a6d885a` are identical; the new commit has zero shipping-byte effect. Donor `312280bb` is separately preserved (not a blind pick) and the three donor-only modules (`shared/blueprint/shapes.js`, `shared/blueprint/url-templates.js`, `shared/replay/state.js`) are not reachable from the manifest closure and are not packaged — consistent with the handoff claim.

## 2. Scope reviewed / actions taken

Read-only on candidate source. No implementation, commit, push, install, deploy, hosted-setting change, credential inspection, or customer/source account contact.

Reviewed (read in full or in the relevant sections): `manifest.json`, `background.js`, `content/main.js`, `popup/popup.html`, `popup/popup.js`, `popup/pair.html`, `popup/pair.js`, `shared/protocol.js`, `shared/ingest-ack.js`, `shared/log.js`, `shared/net.js`, `shared/session.js`, `shared/capture-policy.js` (allowlist/redaction entry), `shared/replay/engine.js` (run loop/terminal states), `shared/replay/resolve.js`, `popup/outcome.js`, `_locales/en/messages.json` (outcome/replay copy), `scripts/lib/shipping.mjs`, `scripts/package-extension.mjs`, `scripts/browser-load-proof.mjs`, `test/package-integrity.spec.js`, `jsconfig.json`, `types/punycode.d.ts`, `package.json`, `lefthook.yml`, `scripts/check-hook-config.mjs`, `scripts/secrets-scan.sh`, `.github/workflows/ci.yml`, `docs/PACKAGE_PROOF.md`, `docs/TIER0_CONTRACT_INTEGRITY.md`, `docs/TRANSFER_OUTCOME_BOUNDARY.md`, `execution/s4-importer/R1-HANDOFF.md` and `logs/`.

Not reviewed line-by-line (unreviewed scope): `shared/capture.js` body (debugger event handling beyond the allowlist gate), `shared/credential-policy.js`, `shared/pairing.js`, `shared/progress.js`, `extractors/truecoach/extractor.js`, the pre-existing test suite (59 files) beyond names, `.github/workflows/secrets-scan.yml`/`codeql.yml` content, `.gitleaks.toml`.

Actions I executed (outside the candidate tree, in `/tmp/s4-audit-b-7f31`):
1. `git archive HEAD` → clean tree; `node scripts/package-extension.mjs --out …` → 36 files, 208 731 bytes, zip sha256 `0b2f377dacfeca2eba84e90792cea11ff262b8e78b49717ee2badf81ae927e6c`; `cmp` byte-identical to `execution/s4-importer/artifacts/tgp-importer-extension-0.3.0-rc.1.zip` and to the builder's `worktrees/s4-importer/dist` zip. Unzipped contents sha256-match the source tree.
2. Repeated the same build from a `49c1aa9` archive: identical shipped-file hashes (confirms #25 shipping equivalence).
3. `vitest run test/package-integrity.spec.js` on the `a6d885a` archive: 15/15 pass (run 17:12Z; vitest picked the spec up twice via project globbing because a peer's scratch directory collided with my first scratch path — the second run in an isolated directory is the one relied on for the hash above; test result was pass in both).
4. Browser proof: I attempted a bounded run of the committed harness under `execution/test-validation.lock`. The lock was held by the S3 backend jest run with multiple queued waiters (including the builder's `run-browser-proof.sh try4`); I withdrew my queued run on the parent's finalize instruction. **I did not obtain a browser-proof result.**

## 3. Findings

IDs are stable `S4-B-nn`. "Material" = blocks clearance under R1_COMMON; "nonmaterial" = record/recommend only.

### S4-B-01 — No passing real loader/browser proof exists for the candidate (MATERIAL; evidence gap + harness defect)
Evidence: `execution/s4-importer/logs/browser-proof.try1.log` — committed harness aborted at `scripts/browser-load-proof.mjs:323` (`JSON.parse(manifestResult.result.value)` → `"undefined" is not valid JSON`). `browser-proof.try2.log` — a *different, uncommitted* harness revision (its stack line numbers 143/496 do not correspond to the committed file) aborted with `Cannot read properties of undefined (reading 'local')`. `worktrees/s4-importer` shows `scripts/browser-load-proof.mjs` modified in the working tree (+75/−40) relative to the frozen head, i.e., the builder is iterating on the harness; the frozen candidate's harness is not the one being exercised. No `browser-load-proof*.json` exists for positive or negative-control mode.
Harness defects that make aborted runs undiagnosable and evidence-free:
- `Runtime.evaluate` results are consumed without checking `result.exceptionDetails` (lines 315–323); a thrown expression surfaces only as the opaque JSON error seen in try1.
- The `browser-load-proof:aborted` evidence branch (lines 531–540) is unreachable when the try block throws (try/finally, no catch): the exception propagates before `writeFileSync(outPath, …)`. Aborted runs therefore leave no evidence JSON, contradicting `docs/PACKAGE_PROOF.md`'s implied "explicit gap" recording.
- Predicted failure of the popup check (line 364) even once the worker check passes: in a fresh profile there is no paired session, so `popup/popup.js` redirects to `pair.html` after `request_session_state`; `pair.html` has no `#start-import` element, so `start: Boolean(document.getElementById('start-import'))` will be false (or the evaluate races the navigation). The "no session" state is the truthful fresh-install state, so the check as written cannot pass for a correct extension.
Consequence: the acceptance row requires "real loader/browser proof". None exists; the committed harness would need to change to produce one, which changes the frozen head.
Smallest remediation (for the parent/builder, not applied by me): read and record `exceptionDetails`; wrap the body in try/catch so the aborted-evidence JSON is always written; make the popup check accept the redirected pairing view (`#pair-form`) or explicitly wait for the redirect; then produce positive and negative-control JSON at a re-frozen head. Command: `cd worktrees/s4-importer && npm run package && npm run proof:browser && npm run proof:browser:control` under `test-validation.lock`, with `TGP_CHROME` set to the Playwright Chromium if auto-detection fails.

### S4-B-02 — Full test/lint/format evidence at the frozen head is missing (MATERIAL; evidence gap)
Evidence: the only full vitest log is `logs/baseline-49c1aa9-vitest.log` (head `49c1aa9`, 59 files / 1654 tests pass). The handoff itself lists full vitest, `lint`, `format:check` and `type-check` on `a6d885a` as pending, and states the package-integrity spec passed on a "pre-commit tree; two spec defects fixed before commit". I independently ran only `test/package-integrity.spec.js` at `a6d885a` (15/15 pass). Type-check is relevant because `a6d885a` changes `jsconfig.json` paths (see S4-B-08).
Requested from parent: `cd worktrees/s4-importer && git stash -u && npm test && npm run lint && npm run type-check && npm run format:check` at exactly `a6d885a` (or on a clean `git archive` copy), logs attached with head binding.

### S4-B-03 — Negative-control mode is only meaningful paired with a passing positive run (nonmaterial; harness validity)
`--negative-control` passes if *any* of three checks fails, including timeouts unrelated to the reintroduced defect. On its own it cannot demonstrate detection power. Not a defect once S4-B-01 is closed with a positive run from the same head and environment.

### S4-B-04 — "only the synthetic origin was contacted" check is tautological (nonmaterial; wording)
Line 504: the check only inspects requests that reached the local synthetic server; requests to any other host resolve to NOTFOUND by `--host-resolver-rules` and are unobserved. Isolation is real (resolver mapping) but the check name overstates what is measured. Rename or record the resolver rule as the isolation evidence.

### S4-B-05 — Message handlers gated by `sender.id` only, inconsistent with the stated §13.4 threat model (nonmaterial; pre-existing hardening)
`background.js`: `start_import` (line 874) and `session_established` (904) require `isTrustedExtensionPage(sender)` (extension-origin page, no tab). `start_ingest` (887), `start_capture` (920) and `stop_capture` (934) accept any sender with `sender.id === chrome.runtime.id`, which includes the content script. `start_ingest` accepts a caller-supplied `sourceToken`/`url`; `start_capture`/`stop_capture` drive `chrome.debugger` on a caller-supplied `tabId` (host-allowlisted to `app.truecoach.co` by `shared/capture-policy.js`) and return captured entries to the sender. No shipped UI sends these three kinds (grep: only `shared/protocol.js` defines them). Exploitation requires a compromised content script (isolated world), which the code's own comments treat as in scope. Pre-existing (gating introduced in `a8a6af6`/`a856385`, not in #21–#25). Smallest remediation: apply `isTrustedExtensionPage` to all three or remove the dormant `start_ingest` entry.

### S4-B-06 — `debugger` permission shipped with no reachable UI path (nonmaterial; owner decision to record)
`manifest.json` permissions are `activeTab, debugger, notifications, storage, tabs`, frozen by `test/package-integrity.spec.js`. Capture (the only `chrome.debugger` user) has no shipped trigger (S4-B-05). Shipping `debugger` in a release whose customer flow never uses it widens the permission surface and triggers Chrome's debugging banner if ever invoked. Pre-existing scope; the acceptance row asks for "constrained permissions/origins" — record the owner's explicit acceptance or drop the permission until capture ships. `optional_host_permissions ["*://*/*"]` is declared but never requested (no `chrome.permissions` usage) — dormant, nonmaterial.

### S4-B-07 — Full tab URL persisted into error snapshot/popup (nonmaterial; low PII)
`background.js` writes `lastError: "unsupported site: ${url}"` / `"unsafe import origin: ${url}"` (full tab URL) into `chrome.storage.local` and the popup error box. Truecoach URLs may carry client identifiers in paths. Reduce to origin/hostname.

### S4-B-08 — Type-check input change for a local environment quirk (nonmaterial; gate-input change, explained)
`jsconfig.json` maps `string_decoder` to `types/punycode.d.ts` (`declare module "string_decoder"`) so a stray ancestor `node_modules` package does not enter the checked program. This is a repo-permanent workaround for a sandbox artifact; it only affects `@types/node` internals (`skipLibCheck` already true) and no shipped module imports `string_decoder`. Acceptable, but it must be exercised by a `type-check` run at the frozen head (S4-B-02).

### S4-B-09 — Cancel vs. auth-loss ordering (nonmaterial; verify)
Engine returns `status:"cancelled"` only on AbortError; TGP auth loss throws `TgpAuthLostError` after the sender calls `controller.abort()`. If an in-flight `fetchJson` observes the abort first, the run could terminate as "cancelled" and broadcast `ingest_failed`/"import cancelled", overwriting the session-expired snapshot. Not reproduced; request a targeted unit test if the builder cannot show ordering is deterministic.

### S4-B-10 — Package/CI gate shape (nonmaterial; recommendation)
`ci.yml` runs `npm test`, so determinism, frozen permissions/hosts, no-dev-reference and fail-closed loader cases are now CI-enforced. `npm run package` and `proof:browser` are not run in CI and produce no CI artifact; the reproducible hash and loader proof remain manual, log-attested steps. Recommend a CI step that packages, uploads zip+inventory, and runs the browser proof (GitHub runners ship Chrome).

### Positive observations (no finding)
- Packaging is the manifest load closure via TS AST; fails closed on missing/escaping/dev-only references; classic content script compiled as a script (the exact historical `export` defect on `origin/main` `content/main.js:37` is caught, verified by me); deterministic STORE zip with CRC-verified reader; independent rebuild byte-identical (Section 2).
- Manifest: no `externally_connectable`, no `web_accessible_resources`, module worker, `content_scripts` limited to `https://*.truecoach.co/*` declared hosts, no `all_frames`; popup/pair pages use a single `<script type="module">`, no inline scripts.
- Secrets/bearer: access token memory-only; refresh in `storage.session`; no token logging; `log.js` allowlisted event codes; ingest-ack bounded to 4096 bytes with strict counts; `completeIngest` refresh-once on 401 and throws on non-2xx; `settleFailed` never throws; `redirect:"error"`; Authorization from adapter data dropped; capture allowlist `app.truecoach.co` asserted before `debugger.attach`.
- Truthful states: `outcome_*`/`replay_*` copy consistently says "staged … Migration is not verified", "confirmed received", "unconfirmed … do not retry blindly", and distinguishes transfer receipts from native import completion; Start remains disabled after any recorded run (documented presentation safeguard).
- Gate changes in #23 (`lefthook.yml` secrets hook, `check-hook-config.mjs` unconditional-secrets assertion, pinned gitleaks 8.30.0 with forbidden `.gitleaksignore`) are consistent with hooks-as-feedback / CI-as-enforcement (`secrets-scan.yml` present).

## 4. Evidence gaps (distinct from defects)
1. No browser/loader proof JSON for positive or negative-control mode at `a6d885a` (S4-B-01).
2. No full vitest / lint / type-check / format log bound to `a6d885a` (S4-B-02).
3. Builder worktree diverges from the frozen head (`scripts/browser-load-proof.mjs` modified); any proof produced there is not evidence for this candidate until re-frozen.
4. Infrastructure limit: `execution/test-validation.lock` was held by the S3 backend full jest run for the duration of my audit window with multiple queued waiters; heavy proof could not be run by me.

## 5. Verdict

**NOT CLEARED** (Round 1).

Reasons: S4-B-01 (no real loader/browser proof; committed harness has defects that prevent producing one at this head) and S4-B-02 (missing full test/lint/type-check evidence at the frozen head). Both are required by the S4 acceptance row ("real loader/browser proof") and R1_COMMON ("missing tests … prevent clearance").

What is established: reproducible package hash `0b2f377d…27e6c` independently reproduced and byte-identical to the attested artifact; package-integrity spec 15/15 at the frozen head; permission/origin surface bounded and frozen by test; no bearer/secret leak found in reviewed code; receipt/settlement/cancel copy and states truthful and explicitly distinct from native import completion; #26 content already present, donor separately preserved.

Limits: source review only for the unreviewed files listed in Section 2; S4-B-05/06/07/09 are pre-existing or unverified and are recorded as nonmaterial pending owner decision or a targeted test; I have not read peer report A and did not coordinate this verdict.
