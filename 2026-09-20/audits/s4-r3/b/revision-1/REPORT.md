# S4 R3 — Independent T4 Audit B (auditor B, revision 1)

## 0. Identity, independence, scope

| Item | Value |
| --- | --- |
| Lane / packet | S4 importer extension, R3 fix packet `execution/s4-r3/` (frozen; `REPORT.md`, `INITIAL_PLAN.md`, `PACKET_SHA256SUMS`, `artifacts/`, `logs/`, `scripts/`) |
| Candidate head | `84471e99b278e964f7cb3f6bf9c78491064c41b7` — tree `f31a978034d0aa8a2c39615ade5ec0255a19b1d0` — branch `execute/20260920-s4-r3` — single commit on R2 base |
| R2 base | `c5a5ae12c5b3c3e32a4601c99319ad7c0d980057` (tree `5f3c8f6a729427ce6c23bcb1ba18dc7b986b7447`); public base `0111be661922234d670bbf23e23d270eec1b4a4e` |
| Package under verdict | `tgp-importer-extension-0.3.0-rc.1.84471e9.zip` sha256 `90883cad44cd78b60a18ab232aba0b965ae40ab6edb99054138cac61c0f6a9a7`, 214,919 bytes, 36 entries |
| Other artifacts | bundle `s4-importer-r3-84471e9.bundle` `57d97895d1b6f5564acc7d78c359c4e0521f284e294857785b8c7db0f240855e`; patch `s4-r3-84471e9.patch` `b6912d9a85b8c0e7ea563794025ec88a3cc6084a604e81a09b11b2a24da0932e`; inventory `3f0585e0…` (all re-verified via `artifacts/SHA256SUMS`) |
| Inherited reports read | `execution/audits/s4-r2/a/REPORT.md` (R2 auditor A — NOT CLEARED on S4-R2-A-01), `execution/audits/s4-r2/b/REPORT.md` (R2 auditor B — CLEARED bounded at `c5a5ae1`) |
| Not read / not contacted | No R3 peer (auditor A) report, no parent summaries of it, no `current_session_context` search, no contact with any other reviewer, no subagents |
| Governing texts read | `repos/context/AGENT_RULES.md` G01–G22 in full; `execution/doctrine/EXECUTE.txt`, `execution/doctrine/ROUTING.txt`; `execution/R3_FIX_AUDIT_BRIEF.md`; `execution/R3_VALIDATION_QUEUE.md` |
| Model identity (honest) | Requested by the brief: "Claude Fable 5 / High". **Actual verifiable identity: an API-hosted AI subagent; no provider, model name or version string is exposed to me at runtime. I do not claim the requested identity as verified.** |
| Constraints honoured | Read-only on candidate source (worktrees `s4-r3` and `s4` both `git status --porcelain` empty before and after my work); no installs, no heavy tests, no browsers, no DB, no hosted actions; outputs written only under `execution/audits/s4-r3/b/` |

### Actions performed

1. Verified `PACKET_SHA256SUMS` and `artifacts/SHA256SUMS` (`sha256sum -c`, all OK); verified worktree head/tree/cleanliness/author identity; verified parent is `c5a5ae12…`, one commit, no AI trailers.
2. Read the full diff `c5a5ae1..84471e9` (5 files, +832/−81): `shared/net.js`, `shared/log.js`, `shared/session.js`, `shared/pairing.js` (largely a Prettier reformat plus the consumer callback), `test/auth-body-deadline.spec.js` (new, 24 tests). Read the full new spec. Mapped every caller of `getAccessToken` / `refreshAccessToken` / `clearTokens` / `establishSession` / `hasActiveSession` in `background.js`.
3. Inspected every `logs/NN.meta.json` and log 01–12, including the three preserved failed WIP runs (03 tsc error, 06 secrets hook without gitleaks) and the builder's own discriminating probe outputs (candidate pass, base fail on the stalled-deadline assertion).
4. Independently verified the package: every one of the 36 zip entries is byte-identical to `git cat-file blob 84471e9:<path>`; no non-tracked entry; `test/` not packaged; versus the R2 zip (`e2ee1f5c…`) the entry set is identical and exactly four entries differ — `shared/log.js`, `shared/net.js`, `shared/pairing.js`, `shared/session.js` (`probes/package-blob-probe.json`).
5. Inspected both browser-proof receipts: bound to zip `90883cad…`, inventory source head `84471e99` clean, Chrome for Testing 147.0.7727.15, positive 11/11 PASS with `exceptions: []`, negative control `detected: true`, `noReceiver: true`, `syntaxExceptionSeen: true`, `unrelatedFailures: []`, extension ids `lfmhblcnhhmofpgollaejpdjhclobjbo` / `apkkeapllidbfcncompnnefnmgkdpacm` matching the packet report.
6. Wrote and ran one bounded, dependency-free, offline Node probe (`probes/auth-body-probe-b.mjs`; single process, intercepted timers, real `Response` over synthetic `ReadableStream`, `chrome.storage.session` stub, no worktree writes) against the candidate and the frozen base. Results: `probes/auth-body-probe-b.candidate-84471e9.json` (pass, 0 unhandled rejections), `probes/auth-body-probe-b.base-c5a5ae1.json` (fails/hangs exactly where the R2 defect lives), plus isolated C5/C6 runs on both roots for attribution.

## 1. Disposition of S4-R2-A-01 (the material finding R3 exists to close)

R2 auditor A's finding: after response headers arrived, the pairing-redeem and refresh body reads were unbounded in time and bytes; the 15 s deadline was cleared on headers, so a stalled body pinned the sole pairing submit indefinitely (no timeout copy) and pinned the refresh coalescer slot forever.

What I verified at `84471e99` (source + probe, not builder claims):

| Property | Evidence |
| --- | --- |
| Deadline now spans the body | `fetchWithTimeout` passes `controller.signal` to a consumer and settles on `Promise.race([timeout, consumer])`. Probe C1 (candidate): with a 200 whose JSON is complete but whose stream never closes, the deadline is still live (`liveDeadlineBeforeFire: 1`), firing it settles pairing with the exact timeout copy and refresh with `null`; on base the same case is `PENDING` forever with zero live timers. |
| Late body cannot act | Pairing only sends `session_established` from the awaited race result; refresh only commits under the lock from the awaited race result. Probe C1: after settling, `sessionEstablishedSentAfterSettle: 0`; stored refresh token unchanged (`R-c1`), next `getAccessToken()` performs a fresh fetch and publishes the fresh token, not the late one. This closes the specific edge the builder's spec does not test directly (complete JSON + never-closing stream, where the cancelled `read()` resolves `done:true` and `JSON.parse` succeeds late). |
| Byte bound | `readBoundedJson` enforces `MAX_AUTH_BODY_BYTES = 16384` per chunk before decoding. Probe C3: 18,022 bytes across 4 chunks → `BodyError("body_invalid")`, message carries no body bytes, reader lock released; exactly 16,384 bytes parses, 16,385 rejects. |
| Decoder safety | `TextDecoder("utf-8", { fatal: true })` with streaming decode. Probe C4: a 3-byte code point split across chunks parses correctly; invalid UTF-8 → `BodyError`, no bytes echoed. |
| Cancel on abort | Abort listener calls `reader.cancel()` (not awaited) and the `finally` releases the lock; probe C1 shows `streamCancelRequested: true`. |
| Error privacy | Body errors are a fixed `body_invalid`; log events are fixed codes via `logNetworkEvent`; probe C2 confirms no marker bytes reach console output under browser-shaped abort. |
| Coalescer cannot be pinned | `detachRefreshInFlight()` in `clearTokens` and `establishSession`; `finally` clears the slot only if it still owns it. Builder spec + builder probe cover stall→clear, stall→re-establish, stale commit fenced, stale finally cannot clear the new slot; probe C6 confirms same-epoch coalescing (1 fetch for 2 callers) on both roots. |
| Unhandled rejections | 0 across all probe cases on the candidate (the race absorbs the late consumer rejection). |
| Regression suite | Log 09: real `vitest` on committed head, 62 files / 1702 tests passed, head/tree/dirty-0 stamped by `run-heavy.sh` (`PIPESTATUS[0]` preserved, `flock -n`). Log 10: all gates OK. |

**Disposition: S4-R2-A-01 is closed at `84471e99` with respect to the finding as written.** The fix is present in source, exercised by 24 new committed tests that run under real vitest, reproduced offline by the builder's probe and independently by mine, and the packaged bytes are the committed bytes.

## 2. Findings

### 2.1 New findings (R3 auditor B, stable IDs)

| ID | Class | Finding | Consequence | Disposition |
| --- | --- | --- | --- | --- |
| **S4-R3B-01** | Nonmaterial reliability edge, **introduced by the R3 detach** (not present on base) | Ordering window in the coalescer: if `establishSession()` (or `clearTokens()`) is queued on the state lock **before** a freshly started `refreshAccessToken()` run has taken its snapshot, the run is detached from the slot (`refreshInFlight = null`) yet then snapshots the **new** epoch/token and proceeds. A second refresh caller arriving during that run's network window finds an empty slot and starts a parallel refresh presenting the **same** refresh token. Probe C5 (isolated): base → one fetch, both callers receive `A-m0`; candidate → two fetches with `R-new`, first caller `A-m0`, second caller `null` (correctly fenced by the epoch bump of the first commit). | Fail-closed, not fail-open: no stale token is resurrected and no cross-session overwrite occurs. But the `null` returned to the second caller flows into `background.js` (`makeSender` 401 path, lines 171–175) → `clearTokens()` + `onAuthLost()`, wiping the just-established session and forcing a re-pair; and duplicate presentation of one refresh token may trip backend reuse detection (backend policy unknown to me). Reachability requires two refresh triggers inside one RTT while a pairing establishment races — in the current single-run import architecture that needs a 401-driven refresh concurrent with a re-pair; I could not construct a realistic customer path with two such triggers. | Not blocking. Record as a follow-up hardening slice, not an R3 re-spin. Narrowest fix: make detach conditional on the run having already snapshotted a now-stale epoch (e.g. `refreshInFlight = { run, epoch: null }`; set `epoch` when the snapshot resolves; `detachRefreshInFlight()` detaches only when `epoch !== null && epoch < stateEpoch`). A run that has not snapshotted will snapshot the new epoch and should remain joinable. Add one spec mirroring probe C5. |
| **S4-R3B-02** | Nonmaterial observability defect (no PII, no state effect) | In a real browser, aborting the fetch signal **errors** the response body stream (Fetch spec), and `reader.cancel()` on an errored stream **rejects**. `readBoundedJson` therefore emits `auth_body_cancel_failed` on every ordinary deadline abort that lands mid-body — twice (once from the abort listener, once from the `catch` path). Probe C2 (browser-shaped abort) on the candidate: events `["auth_body_cancel_failed","auth_body_cancel_failed","pair_timeout"]`, `bodyBytesInConsole: false`. The spec's "no `auth_body_cancel_failed`" assertion only covers the non-2xx `discardBody` path with a synthetic stream that cancels cleanly, so it does not see this. | Diagnostic noise that mislabels the expected path as a failure; the warning is a fixed string and leaks nothing. No functional or security consequence. | Not blocking. Narrowest fix: in `cancel`, swallow the rejection when `signal?.aborted` is true (or when the rejection is an `AbortError`) and log only otherwise; drop the second `cancel()` call when the first already ran. |
| **S4-R3B-03** | Report-accuracy nit | `execution/s4-r3/REPORT.md` says `logNetworkEvent` "fails closed on unknown codes"; the code maps unknown codes to the fixed string `"unknown_network_event"` rather than dropping the event. | None (still a fixed, PII-free string). | Wording only; correct in the next packet revision or leave. |

### 2.2 Inherited findings — cumulative lane eligibility

| ID (origin) | Status at `84471e99` | Disposition |
| --- | --- | --- |
| S4-R2-A-01 (R2 A, material) | **Closed** (section 1). | Cleared for this finding. |
| S4-R2-A-02 (R2 A) — legacy `extractors/truecoach/net.js` surfaces `err.message` | Unchanged; file identical to base and to R2 zip; dormant path per R2 A. | Out of R3 slice by brief; remains an open nonmaterial item for the lane owner. |
| S4-R2-A-03 (R2 A) — harness claims narrower than sandbox reality | Builder kept the R3 browser claim narrow ("bounded, synthetic host resolver, no customer import"); receipts match the claim. | Resolved as a claim-discipline matter for R3; no source change needed. |
| S4-R2B-01 … S4-R2B-06 (R2 B, nonmaterial) | Unchanged; none touched by the diff. | Carry forward as nonmaterial, owner backlog. |
| Permission residuals (`debugger`, `optional_host_permissions *://*/*`) — R2 A/B | `manifest.json` byte-identical to R2 package. | Owner decision before any store submission; not an R3 defect. |
| S4-A-09 / S4-B-10 — CI does not run package build / browser proof | Unchanged. | Evidence gap, not a failure (see 3). |
| S4-A-04 / S4-B-06 (earlier R1 residuals carried by R2) | Not touched by this diff; no new evidence either way. | Unchanged status; not in slice. |

No inherited finding is re-opened or worsened by the R3 diff, with the single exception noted in S4-R3B-01 (a new narrow window created by the detach that fixes the larger pinned-slot defect; strictly fail-closed).

## 3. Evidence gaps versus failures

**Failures found: none material.** Nothing in section 2 fails a G01–G22 gate.

**Evidence gaps (stated, not claimed away):**

1. Real-network cancel semantics are not testable offline; my C2 case is a spec-faithful simulation of the browser body-stream error, not a browser run. The browser-load proof (run 12) does not exercise the pairing or refresh network paths at all (it proves load, identity, message boundary, storage/console hygiene and origin isolation on a synthetic host).
2. Run 12's wrapper exit is not on its own proof (inner `bash -c` echoes child exits, as the builder disclosed); acceptance rests on the echoed `positive_exit=0` / `negative_control_exit=0` and on the two JSON receipts, which I inspected directly.
3. Pre-lock local "mini-vitest shim" runs (`shim-smoke.*.wip.log`) are builder convenience evidence only; I give them no weight. The 62/1702 real-vitest run (log 09) on the committed head is the regression evidence.
4. CI does not build the package or run the browser proof (inherited A-09/B-10); package↔blob equivalence is proven here by my offline probe, not by CI.
5. `execution/test-validation.lock` is an empty flock file with no holder ledger; serialization is inferred from non-overlapping timestamps in logs 09–12 and `flock -n` in `run-heavy.sh`, not from a ledger.
6. The builder's probe and the new spec do not cover S4-R3B-01's interleaving or the "complete JSON + never-closing stream" edge; both are now covered by my probe, but not by a committed test.
7. No claim is made here about the hosted backend's reaction to duplicate refresh-token presentation (relevant only to S4-R3B-01).

## 4. Narrowest remediation (non-blocking, for the lane owner)

1. S4-R3B-01: epoch-aware detach in `shared/session.js` (≈6 lines) + one spec derived from probe C5. Suitable as a small T2 follow-up slice; does not require re-spinning R3.
2. S4-R3B-02: suppress `auth_body_cancel_failed` when the abort signal is already aborted; avoid the duplicate `cancel()`. ≈3 lines + one spec with an abort-erroring stream.
3. S4-R3B-03: one-word wording fix in the packet report.
4. Carry S4-R2-A-02, R2B-01..06, permission residuals and the CI package/browser gap on the owner backlog as before.

## 5. Bounded verdict

**CLEARED — bounded — for candidate head `84471e99b278e964f7cb3f6bf9c78491064c41b7` (tree `f31a978034d0aa8a2c39615ade5ec0255a19b1d0`) and package `tgp-importer-extension-0.3.0-rc.1` sha256 `90883cad44cd78b60a18ab232aba0b965ae40ab6edb99054138cac61c0f6a9a7`, at the merge-candidate boundary.**

Basis: the material R2 finding S4-R2-A-01 is closed in source, tests, package and independent reproduction; no new material finding; two new nonmaterial findings (one R3-introduced, fail-closed, narrowly reachable) and one wording nit are recorded with narrowest remediation; packaged bytes equal committed bytes; all lane evidence is head-bound and internally consistent.

Explicit non-claims: this verdict does **not** assert merged, deployed, enabled, customer-accepted or production-proven status; it does not cover the hosted backend, the store-submission permission decision, or any customer import against a real source. Anything not listed in sections 1–3 as verified is unknown.

## 6. Outputs (all under `execution/audits/s4-r3/b/`)

- `REPORT.md` (this file)
- `probes/auth-body-probe-b.mjs` — the offline probe (dependency-free, single process)
- `probes/auth-body-probe-b.candidate-84471e9.json`, `probes/candidate.stdout.log` — full run, pass
- `probes/auth-body-probe-b.base-c5a5ae1.json`, `probes/base.stdout.log` — full run on frozen base (fails/hangs at the R2 defect; C5 there is contaminated by the pinned slot from C1, hence the isolated runs below)
- `probes/auth-body-probe-b.candidate-84471e9.C5C6.json`, `probes/auth-body-probe-b.base-c5a5ae1.C5C6.json` and matching `.stdout.log` — isolated coalescer attribution runs
- `probes/package-blob-probe.json` — zip entries vs git blobs at `84471e99` and vs the R2 zip
- `SHA256SUMS` — checksums of every file above

Frozen on delivery by auditor B.
