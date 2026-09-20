# S4 R3 fixer packet — bounded authentication body reads (S4-R2-A-01)

**Builder evidence. Not an audit, not self-clearance.** Dual independent R3 reviewers decide.

## 0. Identity

| Item | Value |
|---|---|
| Worktree / branch | `/home/user/workspace/worktrees/s4-r3` · `execute/20260920-s4-r3` |
| Base (frozen R2 head, untouched) | `c5a5ae12c5b3c3e32a4601c99319ad7c0d980057` (tree `5f3c8f6a729427ce6c23bcb1ba18dc7b986b7447`); `worktrees/s4` re-verified at this head with 0 dirty paths after all work |
| **Candidate head** | **`84471e99b278e964f7cb3f6bf9c78491064c41b7`** |
| Candidate tree | `f31a978034d0aa8a2c39615ade5ec0255a19b1d0` |
| Status at freeze | `git status --porcelain` = 0 paths (all heavy runs 09–12 stamped `dirty_paths: 0` at this head) |
| Author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` for both, verified via `git var` before and `git log --format=%an/%ae/%cn/%ce` after; message contains no AI/tooling trailers (grep for banned identity tokens: none) |
| Commit path | Normal `git commit` with the pinned lefthook pre-commit chain (secrets/banned/deploy-readiness/lint/type-check/format) — no `--no-verify` |
| Public base for the bundle | `0111be661922234d670bbf23e23d270eec1b4a4e` (origin/main) — bundle lists it as a prerequisite |
| Bundle | `artifacts/s4-importer-r3-84471e9.bundle` sha256 `57d97895d1b6f5564acc7d78c359c4e0521f284e294857785b8c7db0f240855e` — `git bundle verify` OK, single head `refs/heads/execute/20260920-s4-r3` = `84471e99…` |
| Patch (single commit) | `artifacts/s4-r3-84471e9.patch` sha256 `b6912d9a85b8c0e7ea563794025ec88a3cc6084a604e81a09b11b2a24da0932e` |
| **Package** | `tgp-importer-extension-0.3.0-rc.1.zip` — **36 files, 214,919 bytes, sha256 `90883cad44cd78b60a18ab232aba0b965ae40ab6edb99054138cac61c0f6a9a7`**, inventory `source = 84471e99…` (copies in `artifacts/`, `artifacts/SHA256SUMS`) |
| R2 package (for contrast) | `e2ee1f5cc09094f3485c07db866d02f73f2a086d5a4d22e362da5e904b2e1e98` (36 files, 209,725 bytes) — superseded; byte difference is the four `shared/*.js` changes only (test files are not packaged) |
| Toolchain | node v20.20.1, npm 10.8.2, Linux x86_64; `npm ci` from the committed lockfile (package.json sha256 `74abc0d5…`, package-lock.json sha256 `262d4b69…`); installed vitest 4.1.11, eslint 10.10.0, prettier 3.9.6, typescript 5.9.2 — all equal to the pins. No pre-existing node_modules was reused (none matched; `worktrees/s4` had none). |
| Additional tool installed | gitleaks 8.30.0 via the repo's own checksum-pinned `scripts/install-gitleaks.sh` into `/home/user/.local/tgp-gitleaks` (binary sha256 `8b6fd684fcd5b4ebe39b68abb072ce59e1063ce7ed4abd556157697845f1f088`), required by the `secrets` pre-commit hook (log 07) |
| Browser | `/home/user/.cache/ms-playwright/chromium-1217/chrome-linux64/chrome` — "Google Chrome for Testing 147.0.7727.15", revision `@6b5a1b80ccc1e8a4967901d8e58fc2e162cdf050`, executable sha256 `696170a79640ec5b50c7518140ace06c69a49cfb295bf527d4a85e26a12b89a7` (pre-existing Playwright cache; passed explicitly via `--chrome`) |
| Worker identity | Requested "Claude Fable 5 / High"; actual verifiable identity: API-hosted AI subagent operating this lane. Model identity is not otherwise verified. |

## 1. Changed files (5; no manifest / permission / flag / native change)

| File | Change |
|---|---|
| `shared/net.js` | `fetchWithTimeout` now calls `consume(response, controller.signal)` (consumer gets the deadline's AbortSignal; JSDoc updated). New `MAX_AUTH_BODY_BYTES = 16384`, `readBoundedJson(response, signal, maxBytes)` — reads the body stream inside the caller's deadline, bounded in bytes, `TextDecoder(fatal)`, throws a tagged `BodyError("body_invalid")` carrying no response bytes; on abort/error it *requests* `reader.cancel()` without awaiting it (a hung cancel cannot block settlement; rejection is logged as the fixed code `auth_body_cancel_failed`); always `releaseLock()`; falls back to `response.json()` for runtimes/mocks with no body stream. New `discardBody(response)` — fire-and-forget cancel of bodies we will not read; never throws, returns whether cancellation was requested. |
| `shared/pairing.js` | Body consumption moved inside the `fetchWithTimeout` consumer so the 15 s deadline covers headers **and** body. A deadline abort mid-body maps to the existing timeout copy and `pair_timeout` (not `pair_body_parse_error`). Copy strings, event codes, status→copy mapping, `session_established` forwarding and sender boundaries unchanged. File is now Prettier-formatted (it was previously in tsc-emit style and never format-gated because it had not changed since the merge-base; `format:check` now covers it — passes). |
| `shared/session.js` | Refresh consumer: non-2xx → `discardBody(response)` then `{ok:false, body:null}` (still no parsing of rejected bodies, still null/fixed categories); 2xx → `readBoundedJson` inside the deadline, `refresh_body_parse_error` preserved for malformed/oversized bodies. Commit remains epoch-fenced under the state lock (unchanged). Coalescer: `detachRefreshInFlight()` on `clearTokens()` and on `establishSession()`'s epoch bump; the in-flight slot is cleared in `finally` **only if it still holds this run** (`if (refreshInFlight === run)`), so an old run's settlement can never clear a newer session's slot. |
| `shared/log.js` | `KNOWN_EVENTS` += `"auth_body_cancel_failed"`. **Why (parent asked):** the banned-pattern gate rejects net-new silent `.catch(() => …)` bodies, and `logNetworkEvent` fails closed on unknown codes; the cancel-rejection path therefore needs an allow-listed fixed code. It carries no bytes/PII (fixed string only). **Affected proof:** `test/log.spec.js` (4/4 pass — allowlist shape unchanged), `check:banned` (pass), and the new spec asserts the code is *not* emitted on the happy non-2xx path and that reader-cancel failure never echoes body bytes. |
| `test/auth-body-deadline.spec.js` | New, 24 tests (see §3). |

Not touched: `manifest.json`, permissions, host permissions, flags, `background.js` message routing, popup, extractors, content scripts, other tests.

## 2. Finding dispositions (stable IDs)

| ID | Disposition at `84471e99` | Evidence |
|---|---|---|
| **S4-R2-A-01** (material) — auth body reads outside deadline; stalled refresh remains coalesced across clear/re-establish | **Fixed in source; proven by real Vitest on the exact head and by the dependency-free probe (base fails, candidate passes). Awaiting independent R3 review — no clearance claimed.** | `logs/09-npm-test-full.log`, `logs/auth-body-probe-r3.base-c5a5ae1.json` (pass:false — "pair deadline must still be live while body stalls"), `logs/auth-body-probe-r3.candidate-84471e9.json` (pass:true) |
| Parent lifecycle add-on — non-2xx refresh body left live | Fixed (`discardBody`); test asserts cancellation requested and no parsing of the rejected body. | spec "a non-2xx refresh reply is not parsed but its body is cancelled" |
| S4-R2-A-02 — residual `err.message` diagnostic in dormant legacy entrypoint | **Not in this slice; unchanged.** Recorded as residual. | — |
| S4-R2-A-03 — harness/report claims narrower than a security sandbox | Unchanged; this report keeps the browser claim narrow (§4). | — |
| S4-R2B-01…06 (nonmaterial harness/report/PII residuals) | **Unchanged**; not touched. Pairing `sendMessage` wait after the network deadline (parent note) is likewise unchanged — no contract extension. | — |
| Permission residuals | Unchanged; no permission or native change. | `check:production-preflight` PASS |

## 3. What was run (all under `execution/test-validation.lock` via nonblocking `flock -n`, one hold per command; stamps in `logs/NN-*.meta.json`, child exit codes preserved, `timeout` bounded)

| # | Command | Head (dirty) | Result |
|---|---|---|---|
| 01 | `npm ci --no-audit --no-fund` | c5a5ae1 (5 wip paths) | exit 0, 133 packages |
| 02 | `prettier --check` on the 5 changed files | wip | exit 0 |
| 03 | `npm run lint && npm run type-check && npm run check:banned` | wip | **exit 2 — failed**: lint passed, `tsc` reported 9 errors in the new spec only (`TS18048 possibly undefined` on lazily-assigned `let` trackers/release functions). Cause: test-only typing of uninitialised `let`s; fixed by initialising them (`settleTracker(Promise.reject(...))`, `new AbortController().signal`, typed no-op release functions). No source change. |
| 04 | re-run type-check + prettier + lint | wip | exit 0 |
| 05 | focused Vitest: `auth-body-deadline, net, net-retry-after, pairing, pair-ui-catch, session-establishment, session-lifecycle, session-refresh-path, refresh-coalesce, log, ingest-ack-cancellation, credential-policy-regression` | wip | exit 0 — 12 files, 204 tests pass (new spec 24/24) |
| 06 | `git commit` (hooks) | — | **exit 1 — failed**: `secrets` hook: gitleaks unavailable. Other five hook commands passed. Not bypassed. |
| 07 | `scripts/install-gitleaks.sh /home/user/.local/tgp-gitleaks` | — | exit 0, checksum-verified 8.30.0 |
| 08 | `git commit` (hooks, gitleaks on PATH) | → **84471e99** | exit 0 — all six hook commands ✔ |
| 09 | `npm test` (full Vitest) | 84471e99 (0) | exit 0 — **62 files, 1702 tests pass** (22:57:24–23:00:39Z) |
| 10 | `npm run gates` | 84471e99 (0) | exit 0 — banned, flags, fixtures, production-preflight, hooks, lint, type-check, format:check all OK |
| 11 | `npm run package` | 84471e99 (0) | exit 0 — zip sha256 `90883cad…f6a9a7`, 36 files, 214,919 bytes, source `84471e99…` |
| 12 | browser positive then negative-control, same zip, same Chrome, **one lock hold** | 84471e99 (0) | exit 0 — positive: 11 checks PASS, 0 failed (ext id `lfmhblcnhhmofpgollaejpdjhclobjbo`); control: `DETECTED`, `noReceiver=true syntaxExceptionSeen=true unrelatedFailures=[]` (ext id `apkkeapllidbfcncompnnefnmgkdpacm`) |

**Wrapper limitation (run 12, disclosed):** the browser command was a `bash -c` sequence that *echoes* `positive_exit`/`negative_control_exit` and therefore returns 0 to the wrapper regardless of the children; the wrapper's `exit_code: 0` for run 12 does not by itself prove the children passed. The accepted evidence for this run is the echoed `positive_exit=0` and `negative_control_exit=0` in `logs/12-browser-proof.log` together with the two JSON receipts (`checks` all PASS / `negativeControl.detected=true`, `unrelatedFailures=[]`), which the parent inspected. Runs 01–11 invoke the child directly and preserve its exit code.

Pre-slot, dependency-free work (not Vitest, not gate evidence): `scripts/auth-body-probe-r3.mjs` (base vs candidate discriminating probe) and `scripts/mini-vitest-shim.mjs` + `run-spec-shim.mjs` (builder scratch used to smoke the spec before the slot; `logs/shim-smoke.*.wip.log`). Shim results are **not** counted as proof; the shim lacks matchers/`it.each` and its failures on neighbouring specs are shim gaps, superseded by run 09.

### New regression coverage (`test/auth-body-deadline.spec.js`, real `Response` over open `ReadableStream`s, `vi.useFakeTimers`)

- net: deadline covers consumer body read; non-stream `json()` fallback bounded; deadline abort settles the consumer even when the stream's `cancel()` never resolves (stream unlocked afterwards); caller `init.signal` abort mid-body → `AbortError`, stream released; oversized / malformed bodies → `BodyError` with no bytes; `discardBody` requests cancel without awaiting a hung cancel; well-formed body parses.
- pairing: 200 and 409 with never-ending bodies settle at exactly 15 s with the timeout copy, `pair_timeout` logged, no `session_established`, request signal aborted; body completing **after** the deadline (stream and non-stream) never establishes a session — stream was cancelled so late bytes are refused; oversized 200 → "Unexpected pairing response", nothing forwarded; well-formed streamed body still pairs.
- session: stalled refresh → null at deadline, stored refresh token kept, `refresh_timeout`, coalesced callers released, next call fetches; late-completing body (stream and non-stream) never committed; clear + re-establish during a stalled refresh → new session refreshes with its own fetch, stale settles null and never overwrites the new access/refresh tokens; stale refresh that later **succeeds** after re-establish is fenced; stale run's `finally` cannot clear the new in-flight slot (third caller joins the new refresh, no extra fetch); stalled then clear only → null with no network; non-2xx body cancelled without parsing; oversized body → parse-error category, nothing committed; same-epoch coalescing preserved.

## 4. What is and is not proven

Proven on the exact clean head `84471e99` (builder-run, reviewer-verifiable from the logs and bundle): full Vitest, full gates, byte-identifiable package, Chrome loader positive + negative-control on that package with the existing approved harness.

Not proven / not claimed: independent R3 audit; product merge, deployment, enablement, customer import or any customer acceptance; any real credentials or hosted service (all synthetic); behaviour of a real network stack's `reader.cancel()` (tests model hung cancel synthetically); S4-R2-A-02 and S4-R2B-01…06 residuals; the browser proof remains the narrow loader/message-boundary claim of R2 (S4-R2-A-03), not a security sandbox.

## 5. Unknowns

- Slot B released: no lock is held; every wrapper hold ended with its command (last release 23:02:34Z, run 12).

- Whether the reviewers accept `MAX_AUTH_BODY_BYTES = 16384` as the bound for token responses (a token pair is a few KB).
- Lock-holder ledger (`.lock.holders`) is not maintained by this lane's wrapper; hold windows are evidenced by the `meta.json` start/end stamps only.

## 6. Smallest follow-up

1. Independent R3 review pair on `84471e99` (read the diff via `artifacts/s4-r3-84471e9.patch`; re-run 09–12 from the bundle if desired).
2. If cleared: S4-R2-A-02 static-category mapping for `lastError`/`errorSummary` as a separate small slice.
3. Harness nits S4-R2B-01/02 (rename or drive `start_import` from the popup; require `syntaxSeen` in control) — separate, nonmaterial.

## 7. Packet layout

```
execution/s4-r3/
  INITIAL_PLAN.md                 approved plan
  REPORT.md                       this file
  artifacts/  s4-importer-r3-84471e9.bundle · s4-r3-84471e9.patch ·
              tgp-importer-extension-0.3.0-rc.1.84471e9.{zip,inventory.json} · SHA256SUMS
  logs/       01..12 *.log + *.meta.json (incl. failed 03 and 06) ·
              auth-body-probe-r3.{base-c5a5ae1,candidate-84471e9,candidate-wip,candidate-wip2}.json ·
              browser-load-proof.84471e9.{positive,negative-control}.json · shim-smoke.*.wip.log
  scripts/    run-heavy.sh · auth-body-probe-r3.mjs · mini-vitest-shim.mjs · shim-hooks.mjs · run-spec-shim.mjs
```
