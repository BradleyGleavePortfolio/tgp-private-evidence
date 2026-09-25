# E2 independent T3 review: "Check status also reads the server"

Reviewer: independent non-builder T3 (`E2 independent review`). I only read files. I made no git writes, pushes, PR actions, lock acquisitions or test runs, and I did not commit the evidence repo. This file is my only output.

## Verdict: **GO** (T3 confirmed, no promotion to T4)

There are no class A or B findings. I found 8 new class C findings (R-C1 to R-C8). I also accept all 10 of the builder's C findings as correctly classed. E2-F10 is now closed.

## 1. Subject, verified on exact bytes

| Item | Verified value |
|---|---|
| Head | `a889f4ade0e13d9f45aabd69c5878ff07e2038bf`. Local `land/e2-status-server` and `origin/land/e2-status-server` both resolve to it. |
| Tree | `1c784e6cb6bbc7732d1ef109ff816cf56095a326` (`git rev-parse a889f4ad^{tree}`) |
| Parent | `8901d5f50eaadd6bad19e933c9e76b6539299669`, which is `origin/land/s4-r6`. It is a single commit with author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`. |
| Diff | `git diff --binary 8901d5f5 a889f4ad` has sha256 `2f80dae0…d5`, which is byte-identical to `e2/e2-source.diff`. It touches 12 files (+1904/−9). `manifest.json`, `shared/session.js`, `shared/net.js`, `content/**` and `extractors/**` are not in the diff. |
| PR #30 | `pr30.json` shows DRAFT, OPEN, `headRefOid a889f4ad…`, base `land/s4-r6`. `check-runs.tsv` shows test ×2, codeql and secrets-scan all `success` on `a889f4ad`. The local gate logs show 69 files and 1859 tests passing, with `npm run gates` returning rc 0. |
| Backend contract | `origin/integration/importer` = `df713fd9217df524915348ef8a42c797f288dde1`. `docs/contracts/importer-openapi.json` has blob `3c1fd2ac…` and sha256 `fc42af0a…ed8d60e`, and `info.version` is `2.0.0-c1-s2.0`. |
| Fixture | `test/fixtures/import-status/import-status.fixture.json` has sha256 `c0d7f222…a05a`, which is byte-identical to the evidence copy. |

## 2. Checks and results

### 2.1 The consumer freeze matches the landed contract: PASS
- I compared the 6 fixture schemas (`ScoutImportStatusResult`, `ScoutImportEntityCountDto`, `ScoutImportFamilyDto`, `ScoutImportFamilyLedgerDto`, `ErrorEnvelope`, `RateLimitError`) against `components.schemas` at `df713fd9` with Python `==`. All 6 are equal, so they are verbatim.
- The request matches the contract. The fixture's `request` block has the GET verb, the `intent_id` query (required, string, 1..128), `security: [{bearer: []}]` and `operationId ScoutController_getImportStatus`, all as in the contract. The path appears as the key under `paths`.
- The status enum `running, success, partial, failed, complete, blocked, cancelled, timed_out` equals `SERVER_STATUSES`, and the contract spec pins that equality.
- The 404 description in the contract is "Uniform not-found … deliberately indistinguishable". The freeze maps it to "not yet known", which is correct.
- In `scout.controller.ts` at `df713fd9`, L146-153 is `@Get('import/status') @Roles('coach','owner') @Throttle(120/60s)`, routed by `req.user.id`. The header comment says the "same Supabase access token minted by /auth/extension/*". The freeze's auth claim holds.
- The brief's version pin (`2.0.0-c1-s1.1`) is superseded by the grant's pin `df713fd9` (SCOPE.md E2-1). E2-F1 is correctly class C.

### 2.2 Fetch, auth, run id, sender, permissions and storage: PASS
- **Auth.** `handleRequestServerStatus` uses only `ownedAccessToken(generation)` and `refreshAccessToken(generation)`, the existing paired-session path. The only header is `Authorization: Bearer`, with no body and no Content-Type.
- **URL.** The URL is `TGP_API_ORIGIN + IMPORT_STATUS_PATH + ?intent_id=encodeURIComponent(id)` on the host `https://api.tgp.coach`, which is already permitted.
- **Own run id only.** The id is `readString(currentSnapshot.intent, "intentId")` after the existing `rehydrateSnapshot()` (called only when no import is in flight). The `message` object is never read by the handler; it takes no arguments. The worker spec sends `intentId: "imp-FORGED"` and asserts the URL is exactly the own-id URL and does not contain `FORGED`.
- **Sender.** The top-level listener guard (`sender.id === chrome.runtime.id`) runs first. After it, the branch requires `isTrustedExtensionPage(sender)`: same id, no `tab`, and a `chrome-extension://<id>/` URL. Anything else gets `{ok:false, error:"untrusted_sender"}` with no fetch, and a spec tests this with a content-script-shaped sender.
- **No new permission, storage or host.** `manifest.json` is not in the diff. The new code writes no storage and makes no `chrome.storage.*.set` call. Its only storage access is the existing read inside `rehydrateSnapshot`. It calls neither `broadcastStatus` nor `broadcastAuthRequired`, and it changes no module state except the rehydrated `currentSnapshot` described in R-C5.

### 2.3 The 401 refresh-once handling is safe: PASS
- Flow: first attempt, then on `http === 401` exactly one `refreshAccessToken(generation)`. If that returns null or the generation has moved, the result is `unavailable`. Otherwise there is exactly one retry, and its result is final: a second 401 is simply `unavailable`. There is no loop.
- `refreshAccessToken` / `refreshAccessTokenOnce` in `shared/session.js` (unchanged) never call `clearTokens`. On failure they return null. On rotation they persist the new refresh token and the new access token only under the epoch check. So the status read cannot clear or wipe a session.
- Same-generation callers coalesce into one refresh slot, so a status-read refresh during a live import does not send a second parallel refresh token.
- The worst case is two refresh calls per user click: one from the cold-path mint in `getAccessToken` and one after the 401. The action is user-triggered only, so this is bounded. The worker spec's `calls.refresh === 2` pins this.
- The fixed-shape reply never includes a token. The spec asserts that no `TGP-ACCESS` string appears in the reply.

### 2.4 Error, 404 and unknown handling is truthful: PASS
- A 200 must pass `readBoundedJson(…, 65536)` and then the strict `parseImportStatus`, which checks: `intent_id` equals the requested id, the status is in the enum, the mode is `legacy` or `server`, `completed_at` is a string or null, there are at most 32 count rows, each `entity_type` is a non-empty string of at most 64 characters with no duplicates, and each `committed` is a safe integer ≥ 0. Anything else is `unavailable`.
- A 404 is `not_yet_known`, with the copy "Not yet known … This does not mean nothing was sent." There is no 0 and no "failed".
- Every other status is `unavailable`, and the body is discarded with `discardBody`, so error bodies are never read.
- Any thrown error (no session, replaced session, timeout, transport fault) is `unavailable` with no detail.
- In the popup, a rejected `sendMessage` is treated as `unavailable`. A reply of the wrong kind, an unknown status or invalid counts also show "Could not check TGP". A reply for another run is hidden, and `serverCheckVersion` drops replies that have been superseded.
- On the backend, a `flushRun` persist failure propagates as a 5xx. The extension shows that as "Could not check", never as "not yet known", which is also truthful.

### 2.5 No change to Start, locking, recovery or run control: PASS (stays T3)
- The `popup.js` diff moves the old Check-status body verbatim into `checkLocalStatus()`, with the `snapshotVersion` guard intact. It adds `checkServerStatus`, `paintServerStatus`, and a hide-on-run-change block in `render()`.
- `wireStartImport`, `outcomeLocked`, `start.disabled`, `preStartIssue` and `outcomeView` are untouched.
- The `background.js` diff adds one import, one predicate, one handler and one router branch. No existing handler, `importInFlight` path or session function changed.
- A grep of the added lines for `chrome.storage`, `.set(`, `clearTokens`, `broadcast`, `start_import`, `outcomeLocked`, `disabled` and `permissions` finds only a comment and test-harness lines.
- The popup specs assert that Start stays disabled with `outcomeLocked === "true"` for a recorded run, that no `start_import` is sent, and that Start stays enabled when there is no run.

### 2.6 Brief §2/§3/§7 display rules: PASS
- **Separate labelling.** The server record has its own `<section id="server-status">` with the heading "TGP server record" and a note saying it is shown separately from this browser's receipts. The local `#status` and `#progress-list` rendering is unchanged, and a spec asserts this.
- **Unknown is never 0.** A 404 reads "Not yet known". A local family missing from `entity_counts` reads "Committed on TGP: not yet known". This matches E2-F8, which I checked in code (`serverStatusView` local-only loop) and in a spec where settled `legacy_partial` has local `notes` and gets a "Notes / Committed on TGP: not yet known" row. The backend's `groupBy(['entity_type'])` returns only groups that have rows, so absence is not a stated zero. The builder's conservative choice is correct.
- **Nothing summed, no "imported".** Each family has its own row reading "N committed on TGP". A spec checks 12 and 3 with no "15" and no match for `/imported|total/i`, and none of the new locale strings contain "imported".
- **No percent or ETA.** `phase`, `deadline_at` and `last_observed_at` are never carried past the parser. The open-run copy is "No final state recorded on TGP yet."
- **The server terminal is the final state.** The copy is "Final state (TGP server): <approved copy>". `claimed_status` is never carried. A legacy `success` reads "transfer settled; records staged, migration not verified", which matches the backend's own `notifyComplete` title "Import transfer staged".

### 2.7 Tests are derived from the fixture and meaningful, and the two edited assertions are not weakened: PASS
- **Contract spec.** It pins the contract identity and runs a mini OpenAPI validator that checks every fixture example against its schema. The parser is tested on every 200 example, on an additive field and on 13 rejection shapes, and HTTP classification is tested separately.
- **Worker and popup specs.** Both drive the real `background.js` and `popup.js` with fixture bodies. The popup spec's `known()` helper passes fixture bodies through the real parser. The popup spec covers `serverStatusView` for every 200 example and checks that every terminal has approved copy.
- **The two edited assertions** in `test/transfer-outcome-popup.spec.js` (L185, L333) change from `toHaveBeenCalledExactlyOnceWith({kind:"request_status"})` to `mock.calls.map(r=>r).toEqual([{kind:"request_status"},{kind:"request_server_status"}])`. That is still an exact, ordered, complete list of calls, so any extra message, including `start_import`, still fails. They are not weakened. E2-F2 is accepted.
- The remaining gaps are in R-C1 and R-C2.

### 2.8 Body-size bound: PASS, with a test gap
- `MAX_STATUS_BODY_BYTES = 65536` is passed to the existing `readBoundedJson`. That function counts bytes from the stream inside the `fetchWithTimeout` deadline and rejects anything over the bound with a `BodyError`, which becomes `unavailable`.
- The fallback when a body has no stream (`response.json()`) predates E2. Chrome `fetch` always exposes a stream.
- The test proving this bound is non-discriminating; see R-C1.

### 2.9 Backend side effects of the GET (E2-F3): confirmed and correctly class C
From `scout.service.ts` `getImportStatus` (L427-490) at `df713fd9`:
1. `flushRun(coachId, intentId)` persists only this coach and run's own already-accepted in-memory progress keys. It is idempotent, and a failure makes the read fail closed with a 5xx.
2. `lifecycle.resolve()` (`lifecycle.service.ts` L140) returns `{mode:'legacy'}` without touching the database for any id that is not a UUID. Extension ids are `imp-${Date.now()}` (`background.js` L878) and `ext-${Date.now()}` (L632), never UUIDs, so `enforceDeadline` never runs for E2's reads. Even for a server-mode run, `enforceDeadline` only fences an open run that is already past its deadline, which is the contract's documented lazy rule.
3. One `SCOUT_IMPORT_STATUS_READ` analytics event is emitted per read.

No legacy terminal state is written. The read happens once per click, with no polling.

## 3. The builder's findings

| # | Disposition |
|---|---|
| E2-F1 | Accepted as C. The version drift is verified, and the grant pin is `df713fd9`. |
| E2-F2 | Accepted as C. The edited assertions are still exact-list (§2.7). |
| E2-F3 | Accepted as C. The side effects are confirmed and disclosed, and none of them is a terminal write for legacy ids (§2.9). |
| E2-F4 | Accepted as C. The markup is additive only, with a hidden section and no CSS. |
| E2-F5 | Accepted as C. No reason copy is correct under CQ-17. |
| E2-F6 | Accepted as C. |
| E2-F7 | Accepted as C. `resolve()` confirms that ids which are not UUIDs are always legacy. |
| E2-F8 | Accepted as C. It is conservative and correct: `groupBy` omits zero groups, and a spec covers it on a settled run. |
| E2-F9 | Accepted as C. |
| E2-F10 | **Closed.** `check:format` under the repo-pinned prettier 3.9.6 passed locally and in CI. |

## 4. Reviewer findings (Safety-ROI)

None of these has a concrete harm to data, auth, Start or run control. They are all class C.

| # | Class | Concrete harm | Decision blocked | Minimum closure | Execution unlocked |
|---|---|---|---|---|---|
| R-C1 | C | The "oversize 200" case in `import-status-contract.spec.js` uses `"x".repeat(65537)`, which is also invalid JSON. It passes even if the byte bound were removed, so the bound is proven by reading the code, not by a test. There is no runtime harm, because the code does enforce the bound. | None | Add a valid-JSON body just over 65536 bytes (for example `legacy_partial` plus a padding field) that must be `unavailable`, and one just under the bound that must be `known`. | Test-proven body bound |
| R-C2 | C | Some worker-spec gaps are covered only by reading the code. (a) The double-401 case does not assert `calls.refresh === 2` or `calls.status.length === 2`, so "exactly one retry" is not pinned. (b) No case covers the session generation changing between the 401 and the refresh or retry. (c) No case covers the `importInFlight` path, which uses the in-memory snapshot without rehydrating. I verified all three are correct in code. | None | Add those assertions and cases in a later test-only change. | Stronger regression pins |
| R-C3 | C | The server region is a snapshot taken at click time with no "as of" framing, and it survives same-run broadcasts by design. If a coach clicks during a live run, sees "No final state recorded on TGP yet", and the run then settles locally, that line stays until the next click. The coach sees a stale open state. No false count, Start change or decision follows from it. | None | When `snapshot.intent.status` changes for the same run, clear or mark the region, or add approved "at last check" wording. This is copy or UX work. | Fresher server-record framing |
| R-C4 | C | TrueCoach families `identity`, `library` and `goals` (`extractors/truecoach/extractor.js` L56) all fall back to the label "Records", in the server region as in the existing local view. Several "Records" rows can appear, for example "Records: 40 committed on TGP" next to "Records: not yet known", and the coach cannot tell which family each row is. They are never summed and no number is false. | None | Approved family labels for those types, which is copy work. The same fix also covers the existing local view. | Unambiguous family rows |
| R-C5 | C | E2 adds a second call site for the existing `if (!importInFlight) await rehydrateSnapshot()` pattern (the first is `request_status`). In theory, a storage read issued just before a `start_import` could resolve after that run's first broadcast and briefly replace the in-memory `currentSnapshot`. The first broadcast comes after the awaited `preflightOwnedSession`, so the window is far smaller than a human double-click. This is not introduced by E2. | None | A later WS1 hardening: only assign the rehydrated snapshot if `importInFlight` is still false when the read resolves. | n/a |
| R-C6 | C | The 64 KiB bound is well above today's reply size, but the S9-0 disposition adds optional `families[]` report fields (see SCOPE.md, "a note on E2's 64 KiB body bound"). A larger future body would fail closed to "Could not check TGP". The read would degrade in availability but never become false. | None | S9-0 text should state the worst-case size of the status body. Raise the E2 bound or freeze a new consumer if S9 can exceed it. | S9 and E2 compatibility |
| R-C7 | C | The contract types `committed` as `number` with `minimum 0`, while the consumer requires a safe integer. This is stricter than the contract, and a non-integer would read "Could not check". It is fail-closed, and `_count._all` is always an integer. | None | Record it. It is informational. | n/a |
| R-C8 | C | `serverStatusView` returns `null` (hidden) rather than "Could not check" when the reply is falsy, such as `undefined`. Chrome rejects `sendMessage` when no response arrives, and that path does become `unavailable`, so this is reachable only if the runtime resolves `undefined`. The only effect is a hidden region instead of an explicit "Could not check". | None | Optional: treat a falsy reply as `unavailable` when a local run exists. | n/a |

## 5. Summary

The E2 head `a889f4ad` (tree `1c784e6c`) matches the stated evidence byte for byte.

- The consumer freeze is faithful to the landed contract at `df713fd9`: 6 schemas verbatim and the request shape identical.
- The fetch uses only the existing paired-session bearer and the worker's own recorded run id; the caller id is ignored. It is limited to trusted extension pages and adds no permission, storage or host.
- The 401 handling refreshes once and retries once, and it cannot clear tokens.
- 404 reads "not yet known", every other fault reads "Could not check", and all 200s are strictly validated within a 64 KiB bound.
- Nothing touches Start, the lock, recovery or run control, so the slice stays T3.
- The brief's display rules hold: separate labelling, unknown never shown as 0, no sums and no "imported", no percent or ETA, and the server terminal labelled as the final state.
- The tests come from the fixture, and the two edited assertions are still exact-list.

**GO.** All findings are class C and none blocks landing. Merging to `main` still goes through the owner-reserved non-author approval path, after PR #27.
