# S4 R4 — Independent audit B (T4), revision 1 (source review complete; final attestation WITHHELD)

Status: **CONDITIONAL — no final unconditional attestation.** Source review of the exact head is complete and I found **no material defect** in the R4 delta. The T4 attestation is withheld pending the parent's exact final run/artifact packet (see §7), in particular a loader (browser) positive proof plus negative control on the shipped bytes, which runner-2 did not produce.

| Item | Value |
|---|---|
| Candidate | worktree `/home/user/workspace/worktrees/s4-r4`, HEAD `2bcf1563d85bc2109e99805e4ce1b06fce4dcdb3`, tree `3e23f91824689d1f179a116af948eae0ed5ae170`, clean before and after my work |
| Base / cumulative | parent `84471e99b278e964f7cb3f6bf9c78491064c41b7`; bundle prerequisite / public main `0111be661922234d670bbf23e23d270eec1b4a4e` |
| Package | `tgp-importer-extension-0.3.0-rc.1.zip` sha256 `6fe9a7be4be782e2bb28b77f1f6ef55a89db2c4ab8f3ff8bb966bc9dfed82858`; all 36 zipped files byte-identical to HEAD blobs; no test files shipped ([probes/package-blob-compare.result.json](probes/package-blob-compare.result.json)) |
| Model identity | Requested: Claude Fable 5 / High (Sept 19 amendment). Observed: API-hosted AI subagent; model/version/settings not observable at runtime. I make no claim beyond that ([identity.txt](identity.txt)) |
| Constraints | Read-only source; no install/full suite/browser/network/DB/commits. Writes only under `execution/audits/s4-r4/b/`. Own runs: one offline dependency-free node probe (candidate 0.07 s + 0.05 s; base export 16.1 s) and one zip/blob compare (2.4 s) — total < 20 s of the 60 s budget; no lock or shared state touched. Peer `/a/` not read. |
| If the head moves | Every conclusion below is bound to `2bcf1563`; a changed head makes them **pending** until re-read. |

## 1. What I read

AGENT_RULES (G01–G22), the T0–T4 grading/routing doctrine, the EXECUTE doctrine, `LAST_OPERATOR_STATE.md`, `execution/EXECUTION_MANDATE.md`; R3 audit A and B reports (`repos/tgp-private-evidence/2026-09-20/audits/s4-r3/{a,b}/revision-1/REPORT.md`); builder `REPORT.md`, `INITIAL_PLAN.md`, `VALIDATION_REQUEST_1.md`, `L1_PROBES_RESULT.md`, checkpoint-1 `MANIFEST.json`; runner-2 logs/meta 01–10, `slot-run-2.exit.json`, `browser-proof-positive.json`. Source: full `shared/session.js`, full `git diff 84471e99..HEAD`, `background.js` 120–1124, `shared/replay/engine.js` abort/emit/terminal paths, `shared/progress.js` flush/report, `extractors/truecoach/extractor.js` emit path, `popup/popup.js` message surface, `test/helpers/background-mock.js`, both new specs in full, `scripts/browser-load-proof.mjs` CDP/launch path.

## 2. Independent assessment of the two named fixes

### 2.1 A-01 / B-01 — refresh-admission coalescing (`shared/session.js`)

Mechanism at HEAD: the slot is `{ promise, run: { epoch: null } }` (`shared/session.js:79`); `run.epoch` is written **inside** the snapshot lock (`:214-220`); `detachStaleRefresh()` (`:72-80`) detaches only when `run.epoch !== null && run.epoch !== stateEpoch`; it is called from `clearUnderLock` (`:146-152`) and `establishSession` (`:172-183`) after both `stateEpoch` and `sessionGeneration` are bumped; the commit remains fenced by `snapshot.epoch !== stateEpoch` (`:277-292`); the slot is vacated in `finally` only by its owner (`:198-207`).

Schedules I traced (all sound):

| Schedule | Outcome |
|---|---|
| Run admitted while establish holds the lock (the R3 defect) | Run stays joinable, snapshots the NEW token once; a second caller joins. Spec case 1; my probe P-A (clear **then** establish both queued ahead of the pending snapshot) — one fetch, `NEW` only, both callers minted ([candidate.result.json](probes/candidate.result.json) `PA.*`). |
| Run snapshotted under OLD, then establish | Detached (epoch stale); its commit fenced to `null`; NEW callers start their own run; stale `finally` cannot vacate the new slot (spec case 2). |
| Run admitted while clear holds the lock | Snapshots `null` token → returns `null`, presents nothing (spec case 3, probe P-A). |
| Run's own rotation bumps `stateEpoch` | Makes the run "stale" to a *subsequent* establish/clear only; the detach is then a harmless no-op on an already-committed run. Rotation does **not** bump `sessionGeneration` (spec case 5). |
| Two runs coexisting after a detach (stale R1 on the wire, fresh R2) | R2 commits; R1 is fenced regardless of arrival order. |

I found **no schedule in which the same refresh token is presented twice in parallel**, and no path in which a caller for the new session is handed a run that snapshotted the old one. Base control: on the `84471e99` export my probe P-A shows the duplicate `NEW_REFRESH` presentation and one joiner receiving `null` ([base.result.json](probes/base.result.json) `PA.joiner_did_not_start_second_fetch`, `PA.both_callers_minted`), so the probe discriminates the fix.

### 2.2 A-02 — obsolete-caller replacement-session cleanup (`background.js`)

Mechanism at HEAD: `sessionGeneration` is an identity bumped only by establish/clear (`session.js:55`); `clearTokensIfSession(generation)` (`:136-144`) clears only under the same lock and only if the bound generation is current; the worker binds `generation` at run start (`background.js:526`, `:775`), checks it before presenting the refresh token (`:240`) and after the refresh returns (`:248`), in `ownedAccessToken` before and after `getAccessToken()` (`:154-162`, used by send/settle/progress), and in `sessionLossError` (`:169-177`): not cleared → `onObsolete()` + `TgpSessionReplacedError`; cleared → `onAuthLost()` + `TgpAuthLostError`. Settlement under a replaced session is skipped and logged as `settlement_skipped_session_replaced` (`:355-374`, `shared/log.js` KNOWN_EVENTS).

Schedules I traced (all sound): stale-refresh success / rejection / timeout after replacement; replacement between refresh and the retry 401; replacement with no 401 at all (next batch not sent under NEW); replacement during the pre-crawl `collectSourceToken`/`getDeviceId` awaits (first emit stops the run, nothing sent to TGP); replacement landing after a fully-crawled run but before settlement (settle skipped, `ingest_failed` + replaced detail); popup or other runtime callers clearing tokens mid-run — **there is no runtime caller of `clearTokens`**: the popup sends only `start_import`, `request_status`, `request_session_state` (`popup/popup.js:136,183,249,259`); `clearTokens` is exported at `background.js:1119` for the harness only, so the builder-flagged "sign-out during run" risk has no production trigger at this head.

Terminal-message race check: `onObsolete()`/`onAuthLost()` abort the run's controller, but they are only ever invoked from inside the awaited `emit` (`sendEntities`), so the engine sees the thrown `TgpSessionReplacedError`/`TgpAuthLostError` first; the engine converts only `AbortError` to `status:"cancelled"` (`shared/replay/engine.js:396-410`) and rethrows everything else. The handler's `cancelled` branch (`background.js:826-836`, "import cancelled") is therefore defensive, not a live path — the popup receives the replaced-session or expired text deterministically. Not a defect.

Worker-level probe P-C (real router/worker/engine/session; chrome.* and HTTP mocked) stages the schedule the specs do not: the OLD run's ingest 401 requests a refresh **while the replacement's `session_established` handler is still inside `chrome.storage.session.set`** (holding the lock). Candidate: pending run presents `NEW_RT` exactly once, replacement remains intact and validly rotated (`storage = ROTATED_FROM_NEW_RT`, in-memory access = `MINTED_FOR_NEW_RT`), the OLD run stops `ingest_failed` with the replaced detail, `auth_required = 0`, no `/complete`, every ingest bearer `OLD_ACCESS`, `request_session_state.hasSession = true`, single-flight released ([candidate.result.json](probes/candidate.result.json) `PC.*`). Base control on the same schedule: the OLD run **resumes under `Bearer MINTED_FOR_NEW_RT`, sends two batches and settles `/complete` as `ingest_succeeded`** ([base.result.json](probes/base.result.json)) — the "resume under the replacement's credentials" mode of A-02 that the R3 reports named and the builder's L1 probes (success/reject modes) did not stage. The probe discriminates the fix on that mode too.

### 2.3 Cumulative retained behaviour (unchanged bytes vs base)

`shared/net.js`, `shared/pairing.js`, `scripts/browser-load-proof.mjs`, `manifest.json` are byte-identical to `84471e99` (`git diff --stat` lists only the 6 files above). Request/body deadlines (`DEFAULT_TIMEOUT_MS = 15000`, `readBoundedJson`), `logNetworkEvent` fixed codes, loader script and permissions therefore carry the R3 dispositions unchanged. `shared/replay/engine.js` changed by a comment only (confirmed in the diff). Legacy `start_ingest` extractor propagates `sendEntities` rejections (`extractors/truecoach/extractor.js:113`), so the generation fences apply to it as well.

## 3. Findings (stable IDs). No material defect found.

| ID | Class | Where | Finding | Consequence | Closure criteria / owner |
|---|---|---|---|---|---|
| **S4-R4B-01** | Nonmaterial — claim precision in tests | `test/session-ownership.spec.js:157-165` (comment + assertion "the replacement's refresh token was never presented by the old run") | The invariant as worded does not hold at this head: in the pending-admission schedule the A-01 fix *requires* the OLD run's queued refresh to snapshot and present `NEW_RT` (probe P-C, candidate). The five spec schedules avoid that window, so the assertion passes there. The real guarantees — no send/settle/report under NEW credentials, replacement intact and validly rotated, no clear, no `auth_required` — hold in every schedule I traced or probed. | None for security or data; a future maintainer could read the comment as a guarantee and "fix" the pending-join, reintroducing A-01. | Reword the comment/assertion to the guarantee actually held (bearer/settle ownership; "a pending refresh may rotate the replacement on its behalf") and/or add the pending-admission schedule as a spec case (probe P-C is a ready template). Owner: S4 builder. Not blocking. |
| **S4-R4B-02** | Inherited nonmaterial (= S4-R3B-02) | `shared/net.js:108,149,153` (unchanged bytes) | `auth_body_cancel_failed` is emitted on ordinary deadline aborts that land mid-body in a real browser (errored stream → `reader.cancel()` rejects), twice per abort. | Diagnostic noise; fixed string; no PII, no state effect. | Swallow the cancel rejection when `signal.aborted`/AbortError; drop the duplicate cancel. Owner backlog. Not blocking. |
| **S4-R4B-03** | Inherited nonmaterial — message truthfulness (fail-closed) | `shared/session.js:257-264` (`null` for timeout/network error and for non-OK alike); `background.js:243-245,169-177` | A transient refresh network failure/timeout during the 401-retry path is indistinguishable from rejection; the worker then clears the **current** session and shows "session expired — please sign in again". Present on base; R4 only narrows it to the owning session. | Coach re-pairs after a network blip; wording is inaccurate (G02) but state is safe. | Distinguish `refresh_rejected` from `refresh_unavailable` and clear only on rejection, or keep fail-closed with truthful text. Owner backlog. Not blocking. |
| **S4-R4B-04** | Truthful boundary (not a defect) | `background.js:17-23,367,829,871-880` | Obsolete and auth-lost runs leave the backend intent **unsettled**; the superseded session is not revoked server-side (no logout endpoint). Both are documented in code and README. | Server-side intent lifecycle and revocation remain G3/backend scope; no extension claim is overstated. | Track on the backend backlog (intent expiry; `/auth/extension/logout`). |
| **S4-R4B-05** | Nonmaterial — wording | `background.js:146-148` (`SESSION_REPLACED_DETAIL`), used at `:880-887` | When replacement lands after a fully-crawled run but before settlement, the popup says "import stopped … Start the import again" although the crawl completed and every batch was acknowledged (intent left unsettled). | Slight over-statement of "stopped"; safe because the intent is not settled and a re-run under the new session is the correct action. | Optional: "import could not be completed" wording. Not blocking. |

Analyzed and **cleared** (recorded so nobody re-audits them): cancelled-vs-replaced terminal race (§2.2); `no_session` leaking as a terminal detail via `ownedAccessToken` (unreachable mid-run: `accessTokenInMemory` is only unset by a clear, which also bumps the generation and is checked synchronously before `getAccessToken()`); service-worker restart resetting `sessionGeneration` to 0 (runs are in-memory and die with the worker; no persisted generation to mismatch); double `controller.abort()` (idempotent); `postProgress` failures under replacement (swallowed by the reporter, `shared/progress.js:100-104`; never clears); `hasActiveSession`/`request_session_state` (unchanged).

## 4. Builder packet and runner-2 evidence — independent evaluation

| Stage (exact head, clean, `working_diff_sha256 = e3b0…b855`) | Result | My assessment |
|---|---|---|
| 01 `npm ci`, 02 prettier on changed files, 05 gitleaks install | exit 0 | Preconditions met. |
| 03 focused vitest (10 files) | exit 0 | Includes both new specs; builder/parent count 113 — I did not recount. |
| 04 `npm test` full | exit 0, **64 files / 1714 tests passed**, 196 s | Full suite on the exact head — closes the "full suite pending" gap. |
| 06 `npm run gates` | exit 0 (static preflight, check:hooks, eslint `--max-warnings=0`, `tsc` ×2, prettier 51 files) | Substitutes for the hooks that did not run at commit time (lefthook absent in the clone — disclosed in MANIFEST). |
| 07/08 stale-caller probe `reject` mode | candidate 0 / base 1 | Closes the "reject mode unrun" gap; success mode was L1-07/08. Timeout mode is covered by the spec (fake timers) and full suite. |
| 09 package | zip `6fe9a7be…`, 36 files, source `2bcf1563` | Independently confirmed byte-equivalence to HEAD blobs (§ header). |
| **10 browser positive proof** | **exit 1 — `browser-load-proof:aborted`, `checks: []`, `exceptions: []`, `stderr: []`, `CDP timeout: Browser.getVersion`** | See §5. |
| 11 negative control | **NOT RUN** (runner stopped at 10) | Evidence gap. |
| Checkpoint bundle | `git bundle verify` OK; SHA256SUMS 6/6 OK; bundle sha256 `dbaa346c…` | Recovery artifact sound. |

## 5. The aborted browser proof — evidence limitation, not yet classifiable

Facts: the harness `scripts/browser-load-proof.mjs` is byte-identical to base; the same Chrome binary (`/home/user/.cache/ms-playwright/chromium-1217/chrome-linux64/chrome`, Chrome/147.0.7727.15) ran the same harness to 11/11 PASS + negative control on 2026-09-20 against zip `90883cad…` (`repos/tgp-private-evidence/2026-09-20/remediation/s4-r3/revision-1/logs/browser-load-proof.84471e9.positive.json`). Here the very first CDP request (`Browser.getVersion`, 15 s pipe timeout, `browser-load-proof.mjs:120`) never got a reply and Chrome wrote nothing to stderr in 16 s, one second after a 196 s test run finished on the same host.

What this does and does not tell us: `Browser.getVersion` is answered by the browser process before any extension code can influence CDP, and the delta ships only worker JS + a log-code table; a product-caused failure at that stage is implausible, **but the run produced zero checks, so it neither indicts nor exonerates the candidate package.** I do not call it environment-only on logs alone (the parent's instruction). The discriminating step is cheap and belongs in the shared bundle, not a duplicate run: in one slot, run the harness against **the candidate zip `6fe9a7be…` and the base zip `90883cad…`** back to back (positive for both, negative control for the candidate), capturing `chrome --version` output, Chrome stderr, exit code and host load before launch. Base-also-fails ⇒ environment; base-passes-candidate-fails ⇒ product investigation before any attestation.

## 6. Inherited dispositions (unchanged at this head)

Legacy `start_ingest` raw `err.message` in terminal detail; permissions (`debugger`, optional `*://*/*`); CI does not build the package or run the loader proof (A-09/B-10); no Stop UI; unsettled intents on auth loss / replacement (S4-R4B-04); R3B-02 (S4-R4B-02). None is introduced or worsened by R4.

## 7. Evidence requests (to parent; one attributable bundle)

Before a final T4 attestation on `2bcf1563` I need, on the exact head and clean tree:

1. **Loader proof pair**: positive receipt for zip `6fe9a7be…` with all checks passing and `exceptions: []`, plus the negative control (`noReceiver`, `syntaxExceptionSeen`, `unrelatedFailures: []`), with Chrome product/version recorded in the receipt — and, per §5, the base-zip control in the same slot if the candidate aborts again.
2. Runner exit JSON showing `failed_steps: 0` for the final run, with `head_at_end`/`tree_at_end`/`dirty_at_end` unchanged.
3. Final packet manifest binding: bundle sha256, zip sha256, inventory, and all stage logs (01–11) under one SHA256SUMS.

Everything else I would normally request (full suite, gates, package, reject-mode probe, bundle integrity) is already in runner-2's packet and I have evaluated it above.

## 8. Attestation

**Withheld.** Source review at HEAD `2bcf1563` is complete and adverse to no material claim: the A-01/B-01 and A-02 fixes are correct on every schedule I could construct, including two the specs do not stage; the R4 delta introduces no new defect I could find; the shipped package matches the head byte-for-byte; full suite and gates passed on the exact head. Outstanding: the loader positive proof and negative control (item 1 above). I will issue the final attestation only against the parent's exact final run/artifact packet, and only if the head is unchanged. I assert no model identity, deployment, customer completion, or hosted enforcement not observed.

Files in this directory: `REPORT.md` (this), `identity.txt`, `EVIDENCE_REQUEST.md`, `probes/pending-admission-replacement-probe.mjs`, `probes/candidate.result.json`, `probes/base.result.json`, `probes/*.stderr.txt`, `probes/package-blob-compare.py`, `probes/package-blob-compare.result.json`, `SHA256SUMS`.
