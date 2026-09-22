# S4 R6 — independent audit B (read-only, exact head 91990ae9 / tree 840fb285)

Reviewer: S4 R6 independent auditor B. Requested identity: Claude Fable 5. **Actually observable identity: an API-hosted AI subagent; no model name, version or reasoning setting is exposed to me — not confirmed or denied, no telemetry invented.** I did not author 88287cff or 91990ae9, did not read auditor A's current R6 conclusions, and did not edit `/home/user/workspace/worktrees/s4-r6` (porcelain clean before and after; verified `git status --porcelain | wc -l` = 0).

Read: `execution/S4_R6_REVIEW_BRIEF.md`, builder `execution/s4-r6/REPORT.md`, `VALIDATION_REQUEST_1.md`, `PREDECESSOR_EXPORT_NOTE.txt`, `SHA256SUMS`, receipts R6-01/15/16/17/18/19/20/21, builder probe `a01-late-reporting-discriminator.mjs`, exact head source (`background.js` in full, `shared/session.js` in full, popup routing, `test/helpers/background-mock.js`, the new spec block, the R5 spec helpers).

## 1. Verdicts (two separate frozen statements)

| Statement | Verdict |
|---|---|
| **Source-only assessment of S4-R5-A-01 at exact 91990ae9** | **CLOSED at source, offline scope.** The synchronous owner recheck in `reportPreflightFailure(failure, generation)` sits in the same job as the emission decision; no await exists between `getSessionGeneration() !== generation` and `broadcastStatus`/`broadcastAuthRequired`. Both entrypoints pass the admission-time generation. Genuine current-OLD failure still emits exactly one `login required to import`. Nothing of B is read, presented, rotated or cleared on either branch. No credential misuse or destructive-cleanup regression found. `shared/session.js` byte-identical to 88287cff. |
| **Builder's §5 runtime-401 observation (`clearTokensIfSession` → `onAuthLost` interleaving)** | **NOT REPRODUCIBLE; no stale emission is reachable via the state lock.** Determined by source ordering argument and an audit-owned 96-case offline probe on real modules (§3). No source change required. |
| **Artifact / acceptance attestation** | **WITHHELD — not a source question.** 0/6 lefthook gates executed (verified `.git/hooks` has 0 non-sample hooks, `lefthook.yml` has 6 `run:` gates, no `node_modules`). New spec ran only under a homemade shim (18/19; the 1 failure is an unsupported `vi.useFakeTimers`), never Vitest. No package, no browser positive/negative, no gitleaks range/history scan. Expected counts (16→19; ≥1742) are not evidence. Retain 91990ae9 as authentic frozen **unaccepted** candidate; do not recreate an identical tree to imply hooks ran. |

No majority-vote waiver is requested or implied. Nothing here proves installed-browser behaviour, native Chrome scheduling, remote revocation, server-owned terminal authority, merge/deploy/enablement or release acceptance.

## 2. Independent source reading — what I challenged

**2a. The fix itself (`background.js` +15/−6, three hunks; diff read in full).**
- Reachability of the R5 defect at 88287cff: `preflightOwnedSession` classifies `{replaced:false}` *before* resolving back through `await` into the handler; `withStateLock` chains `establishSession` B on `stateLock`, so B can commit inside that resolution gap. Builder receipt R6-01 reproduces at `start_import@10,@11`, `start_ingest@10,@11` (exit 0, 4 stale, 58/24 split); R6-15 on the clean head: 0 stale, 0 control failures (exit 0); R6-16 inverted expectation fails as required (exit 1). I read the builder's probe: it imports the actual `background.js`/`shared/session.js` through the repo's `test/helpers/background-mock.js`, no child processes, no network, and classifies "current at report" by the generation recorded at the last `status_snapshot` emission, not by the outcome under test — not circular.
- New check correctness: `generation` is captured synchronously in the router-invoked handler before any await (`const generation = getSessionGeneration()` at `handleStartIngest`/`handleStartImport` entry). The recheck compares against that binding, so a *rotation* (same session, epoch bump only) does not trip it — correct, since `sessionGeneration` is bumped only by establish/clear.
- Secondary consequence: if the generation moved because of an unconditional `clearTokens()` rather than a replacement, the message would read "session changed" rather than `login required`. Non-issue in product: `clearTokens` is exported (`background.js:1166`) but no product code calls it (grep over non-test sources; only the export and comments).
- Popup consequence of a stale `auth_required` (context for severity): `popup/*.js` registers no listener for `kind:"auth_required"`; the popup renders persisted `lastError` and routes on `request_session_state.hasSession`. A stale emission is therefore a reporting-truthfulness defect, never a credential-destructive action — consistent with A's frozen temporal limit.

**2b. Cumulative ownership boundaries re-read for analogues (concrete, not speculative).**

| Boundary | Await between decision and notification? | Current owner at emission | Result |
|---|---|---|---|
| Preflight failure report (fixed) | none | rechecked synchronously | closed |
| Run-time terminal 401: `sessionLossError` → `clearTokensIfSession` → `onAuthLost` | yes (one `await` on the lock's `run` promise) | OLD+1 = cleared, nothing stored (probe §3, 28/28 expired-class cases incl. the 5 where B was already queued behind the clear) | truthful; not reachable as stale |
| Run-time 401 while B already current / B holds the lock | n/a | `clearTokensIfSession` returns false under lock → `onObsolete` → `TgpSessionReplacedError` → "session changed" | truthful (probe families P@0–12 and Q@0–40, 68/68) |
| `completeIngest` 401 → refresh null → `complete 401` thrown | n/a | no `auth_required`, no clear; `settleFailed` logs | pre-existing; not a stale-authority path |
| Preflight transport failure of a still-current OLD → `login required` | n/a | OLD current | R5B-02 (nonmaterial), untouched by design |
| Post-preflight awaits (`collectSourceToken`, `getDeviceId`) before first send | yes | first `ownedAccessToken(run.generation)` throws replaced → "session changed" | truthful |

**2c. Regression spec (`test/session-ownership-preflight.spec.js` +151).** Read in full. Records generation at emission time via a `sendMessage` wrapper, enumerates offsets 0..40 for both entrypoints, requires both classes non-empty (a non-discriminating enumeration fails), asserts B never presented/rotated/removed and guard released, plus a late-pairing control. Discriminates the predecessor under the shim (R6-08 exit 1, `auth_required … generation 22` vs `[]`). Vitest acceptance is still pending; the shim is not a framework.

## 3. Audit-owned probe (material: resolves the builder's unproven observation)

`probes/runtime401-authlost-boundary-probe.mjs` (sha256 `4f3cf776ec89e6624c6ab8086504be7854e9a74e5cf0982acf1fb1aed2050ccf`), dependency-free, imports the actual `background.js`/`shared/session.js` through the repo's own mock; synthetic HTTP/storage only; no child processes, network, DB, lock, install, browser, framework; source read-only. Warm OLD session; accepted Start; crawl → ingest 401 → held refresh → refresh 401 → `sessionLossError`. Family **P**: B dispatched `offset` microtask turns after the refresh 401 (fastest B can queue *behind* the run's clear). Family **Q**: B dispatched before the 401 with its persist parked (B owns the lock), released `offset` turns after. Records generation and stored refresh-key value **at each `auth_required` emission**, whether B had already been dispatched, final generation, stored token, `hasSession`, presented tokens, guard release.

| receipt | root | cases | expired-class | replaced-class | stale | failures | exit | wall |
|---|---|---|---|---|---|---|---|---|
| B1 (`logs/B1-runtime401-candidate-91990ae9.json`) | clean exact head 91990ae9 (dirty=0) | 96 | 28 | 68 | **0** | 0 | 0 | 7.54 s |
| B2 (`logs/B2-runtime401-predecessor-88287cff.json`) | predecessor export (verified = tree a2879859 + 1 added file) | 96 | 28 | 68 | **0** | 0 | 0 | 7.55 s |

Key evidence: `start_import/P@13..17` are exactly the hypothesised window — B **already dispatched and queued behind the clear** when `session expired — please sign in again` was emitted — and in all five the emission happens at generation OLD+1 with **nothing stored**, B commits afterwards (final OLD+2, `NEW_R` stored, `hasSession:true`, B never presented, guard released). Example P@13: `oldGeneration 41 → auth_required @42 stored=null → final 43, stored NEW_R`.

Why (source ordering, not luck): `withStateLock` registers `stateLock = run.then(...)` on `run` *before* the caller's `await run` reaction; when `run` fulfils, the jobs enqueue in that order, so the caller continuation (→ `onAuthLost` → synchronous `broadcastAuthRequired`) runs before B's `work` is even started by the resolved `stateLock`, and B's commit is at least one more turn behind its `chrome.storage.session.set`. Promise reaction FIFO is ECMAScript-specified, not V8-specific, though only Node 20.20.1 was exercised here. Legacy `start_ingest` was bounded to offsets 0..6 per family because `extractors/truecoach/net.js` paces every source request by a real 500 ms timer; its 401 path is the same `makeSender`/`sessionLossError` code.

Probe wall time: two frozen runs 15.1 s; development runs (one harness error from an unrouted legacy `/organizations` request, one 1 s debug, one 7.5 s pre-instrumentation run) ≈ 14 s; total ≈ 29 s < 45 s. Hashes in `SHA256SUMS` (non-self-including).

## 4. Findings / observations

| ID | Class | Statement | Consequence | Counterexample | Minimal closure |
|---|---|---|---|---|---|
| **S4-R5-A-01** | prior finding | Source-closed at 91990ae9 (offline scope). | — | none at head (R6-15, my §2a reading) | Vitest run of the new block + full suite under real toolchain. |
| **Builder §5 observation** | resolved, not a finding | No lock-chained B can commit before "session expired" is emitted; emission always occurs in the cleared state. | none | none in 96 cases incl. the exact window | none; no re-scope needed. Recommend recording B1/B2 as the answer rather than a source change. |
| **S4-R6B-01** | nonmaterial, pre-existing, not a regression | Post-emission staleness: after a genuine `session expired` / `login required` (emitted while OLD/cleared was current), a *later* B pairing leaves the persisted `lastError` untouched; `pair.js` then `location.replace("popup.html")`, which renders that `lastError` while `hasSession` is true. Truthful at emission; outside A's temporal limit; the builder's own control test asserts "no retroactive second notification" as intended behaviour. | UX only, no credential effect | P@13–17 (B1), spec control | Optional, out of R6 scope: pairing success could reset the snapshot's `lastError`. Not required for acceptance. |
| **S4-R6B-E01** | evidence gap (blocker for acceptance, not for source verdict) | 0/6 hooks; no Vitest; no package; no browser negative; no gitleaks range/history. | acceptance impossible | — | Run `VALIDATION_REQUEST_1.md` steps 1–8 under a named grant; real Vitest, not the shim. |

## 5. Verification of builder-stated facts (independent)

| claim | my check |
|---|---|
| HEAD / tree / parent | `91990ae9…`, `840fb285…`, parent `88287cff…` — match |
| `background.js` blob sha256 `e0e67434…` | match |
| spec sha256 `b03754b9…` | match |
| `shared/session.js` unchanged `b4f45900…` | match at both HEAD and HEAD^ |
| diffstat 2 files +166/−6 | match |
| author = committer, no trailers | `Bradley Gleave <bradley@bradleytgpcoaching.com>` both; `%(trailers)` empty |
| bundle sha256 `af2c8207…`, verify okay | match; okay |
| `SHA256SUMS` (86 entries) | all OK |
| predecessor export = `git archive 88287cff` + 1 file | 158/158 blobs equal to tree `88287cff`; exactly one extra (`test/R6-CANDIDATE-COPY.…spec.js`) |
| hooks 0/6 | `.git/hooks` 0 non-sample; `lefthook.yml` 6 gates; no `node_modules` |
| R6-01/15/16/17/18/19/20/21 exits | 0/0/1/0/0/0/1/0 as reported; R6-20's single failure is `vi.useFakeTimers` unsupported in shim |

## 6. Limits
Node 20.20.1 microtask semantics only; no Chrome; no Vitest; no package/ZIP; legacy entrypoint enumerated to offset 6 for budget; identity unobservable. This report is frozen; new evidence must go in a separate revision/addendum.
