# E2: extension "Check status" also reads the server (SOURCE READY)

Builder: `e2_status_reads_server`, sole T3 builder under grant E2-1 (`execution/daceddc8/SCOPE.md`). Brief: `execution/ce3748cb/ux-readiness/UX04_06_BRIEF.md` §1, §3 UX-05, §6 and §7 E2. Consumer freeze: `execution/daceddc8/e2/CONSUMER_FREEZE.md`.

**Status: SOURCE_READY. Source only and uncommitted.** Nothing has been installed, tested, pushed or opened as a PR. The heavy slot has not been taken.

## 1. Head

| Item | Value |
|---|---|
| Repo | `/home/user/workspace/repos/tgp-importer-extension` |
| Branch | `land/e2-status-server`, created from `origin/land/s4-r6` |
| Base (HEAD) | `8901d5f50eaadd6bad19e933c9e76b6539299669`, the E1 commit, authored by Bradley Gleave |
| Repo-local identity | `user.name "Bradley Gleave"`, `user.email bradley@bradleytgpcoaching.com` (used as both author and committer) |
| Working-tree state | 7 tracked files modified and 5 new paths untracked; there is no commit yet |
| Source tree | `1c784e6cb6bbc7732d1ef109ff816cf56095a326`, written with a throwaway `GIT_INDEX_FILE` so the real index is untouched |
| Diff | `git diff --binary 8901d5f5 1c784e6c` is copied to `execution/daceddc8/e2/e2-source.diff`, sha256 `2f80dae0d5005579264fd4b05f665ba2998a9471e960fd61d1a12d4022beb5d6` |
| node_modules | Not installed |

To reproduce the tree: `GIT_INDEX_FILE=/tmp/x git read-tree HEAD && GIT_INDEX_FILE=/tmp/x git add -A && GIT_INDEX_FILE=/tmp/x git write-tree` should print `1c784e6c…`, provided the working tree is unchanged.

## 2. Paths (12 files, +1904 / −9)

```
 _locales/en/messages.json                          |  43 ++   additive keys only
 background.js                                      |  62 ++   one handler + one router branch
 docs/TRANSFER_OUTCOME_BOUNDARY.md                  |   2 +-  Check-status sentence made truthful
 popup/outcome.js                                   | 101 +++  new pure serverStatusView
 popup/popup.html                                   |  12 +   markup only, no CSS
 popup/popup.js                                     |  54 +-  checkLocal then checkServer; paint region
 shared/import-status.js                            | 107 ++++ NEW: parser + reply classifier
 test/fixtures/import-status/import-status.fixture.json | 702  NEW: byte-identical to evidence fixture
 test/import-status-contract.spec.js                | 270 ++++ NEW
 test/popup-server-status.spec.js                   | 344 ++++ NEW
 test/server-status-worker.spec.js                  | 203 ++++ NEW
 test/transfer-outcome-popup.spec.js                |  13 +-  2 assertions updated (E2-F2)
```

These files are untouched: `manifest.json` (no permission, host or CSP change), `shared/session.js`, `shared/net.js` (reused, not modified), `shared/log.js`, the other `shared/**` modules, `content/**`, `extractors/**`, `popup/pair.*`, the popup CSS and every script or gate.

The fixture at `test/fixtures/import-status/import-status.fixture.json` has sha256 `c0d7f222bd553e1c7db0801fc2e19409cc6ca5d7e5e10ebb68a7dc4a9bfda05a`, the same as `execution/daceddc8/e2/import-status.fixture.json`. It is read by tests only, and no shipped module references it, as the `check:fixtures` / package-integrity pattern requires.

## 3. Design

**Contract:** `GET /api/scout/import/status?intent_id=<id>` from `integration/importer` `df713fd9`, `importer-openapi.json` `2.0.0-c1-s2.0` (see CONSUMER_FREEZE §1–§4). It uses the `bearer` scheme, which is the same extension access token already used by ingest, progress and complete. The host `https://api.tgp.coach/*` is already in `host_permissions`, so **no new auth, storage or permission was needed** and the STOP condition was not triggered.

**`shared/import-status.js` (new, pure, no chrome APIs):**
- `IMPORT_STATUS_PATH`, `MAX_STATUS_BODY_BYTES = 65536`, `SERVER_STATUSES` (the 8-value frozen enum) and `isSendableIntentId` (a string of 1..128 characters).
- `parseImportStatus(body, intentId)` is strict:
  - `intent_id` must equal the requested id.
  - `status` must be in the enum, `mode` must be `legacy` or `server`, and `completed_at` must be a string or null.
  - `entity_counts` may have at most 32 rows. Each `entity_type` must be a non-empty string of at most 64 characters, with no duplicates, and each `committed` must be a safe integer ≥ 0.
  - Unconsumed fields are tolerated.
  - On success it returns `{state:"known", intentId, status, mode, settled, counts:[{entityType, committed}]}`. `claimed_status`, `reason_code`, `phase`, `families` and the deadlines are not carried. Anything else returns `null`.
- `readImportStatusReply(response, intentId, signal)`:
  - A 200 goes through the existing `readBoundedJson` and then the parser; a malformed, oversize or wrong-shape body is `unavailable`.
  - A 404 becomes `{state:"not_yet_known", intentId}`. The contract uses 404 for both "no evidence" and "dark route".
  - Every other status becomes `unavailable`, with the body discarded through `discardBody`.
  - The HTTP code is returned beside the classification so that the caller can apply the 401 refresh.

**`background.js`:**
- There is one new message kind, `request_server_status`, handled by `handleRequestServerStatus()`.
- The handler captures the session generation first. If no import is in flight, it rehydrates the snapshot. It takes the intent id **from the worker's own recorded snapshot only**; any id supplied by the caller is ignored. No sendable id gives `{kind:"server_status", state:"no_run"}` and no fetch is made.
- Otherwise it sends one GET through `fetchWithTimeout` with `Authorization: Bearer <ownedAccessToken(generation)>`.
- On a 401 it calls `refreshAccessToken(generation)` exactly once and retries once. If the refresh returns null, or the generation moved, the result is `unavailable`. This mirrors `completeIngest`.
- Any throw, whether no session, a replaced session, a timeout or a transport fault, gives `unavailable` with no detail.
- The handler never clears tokens, never broadcasts `auth_required` or a snapshot, and never writes storage, the snapshot, Start or run control.
- The router branch sits before `request_session_state`. Because the handler spends the bearer, only `isTrustedExtensionPage(sender)` may call it; anything else gets `{ok:false, error:"untrusted_sender"}` and no fetch.

**`popup/outcome.js`:** the new pure `serverStatusView(reply, snapshot, message)` returns `{heading, note, intentId, state, lines:[{label,text}]}` or `null` (hidden).
- **Hidden** when there is no local intent, when the reply is `no_run`, or when `reply.intentId ≠ snapshot.intent.intentId` (a stale or foreign reply).
- **`not_yet_known`** shows "Not yet known… does not mean nothing was sent." with no family rows.
- **`unavailable`**, a malformed reply, an unknown status or invalid counts show "Could not check TGP. The receipts above are unchanged."
- **`known` + running** shows "No final state recorded on TGP yet."
- **`known` + terminal** shows "Final state (TGP server): <approved state copy>". A legacy `success` reads "transfer settled; records staged, migration not verified".
- **Family rows** come in server order as "N committed on TGP". They are followed by local-only families, taken from the `staging` keys and `pendingTransfer.entityType`, shown as "Committed on TGP: not yet known", never 0.
- Nothing is summed. There is no percent, phase or ETA, and the word "imported" never appears.
- `outcomeView` and `preStartIssue` are unchanged.

**`popup/popup.js`:**
- The existing Check status body is now the inner `checkLocalStatus()`, with identical behaviour and the `snapshotVersion` guard. It is followed by `checkServerStatus()`, which sends `{kind:"request_server_status"}`. A rejection is treated as `unavailable`, and a `serverCheckVersion` sequence drops superseded replies.
- `paintServerStatus(doc, view)` fills `#server-status`, `#server-status-state` and `#server-status-families` (`div.row` > `span.label` + `span`), or hides and clears them. It uses non-throwing lookups.
- `render()` hides and clears the region whenever the run on screen changes (`dataset.intentId ≠ snapshot.intent?.intentId`), so one run's server counts never appear under another.
- Start, `outcomeLocked` and `start.disabled` are not referenced by any new code.

**`popup/popup.html`:** `<section id="server-status" aria-labelledby="server-status-heading" hidden>` is inserted after `#outcome-guidance` and before `<details>`. It holds an h3 heading, a note and a state `<p role="status" aria-live="polite">` for announcements, followed by the families div.

**`_locales/en/messages.json`:** 15 keys added at the end: `server_status_heading`, `_note`, `_not_yet_known`, `_unavailable`, `_open`, `_final` (with a `$STATE$` placeholder), the 7 `server_state_*` terminals, `server_family_committed` (with a `$COUNT$` placeholder) and `server_family_unknown`. No existing key changed.

**Grade check:** Start locking, recovery, resume, token lifecycle and run control are unchanged. A grep of the `popup.js` and `background.js` diffs for `start|outcomeLocked|disabled|resume|recover|clearTokens|broadcast|persist` finds only the import line and a comment. **The work stays T3; it was not promoted to T4.**

## 4. Tests (source written, NOT yet run)

| File | Cases | Pins |
|---|---|---|
| `test/import-status-contract.spec.js` | 11 `it`/`it.each` blocks (about 45 cases) | The contract identity (commit, path, `2.0.0-c1-s2.0`). The frozen request shape (a bearer GET with one required 1..128 `intent_id`). The consumer enum equals the frozen enum. A mini OpenAPI validator proves **every** fixture example against its frozen schema (200 → ScoutImportStatusResult, 4xx → ErrorEnvelope or RateLimitError). The parser turns every 200 into the exact known reply without `claimed*`. An additive field is tolerated. 13 rejection shapes. The HTTP classification: 200 is known, 404 is not_yet_known, 400/401/403/429/500, malformed, oversize and wrong-shape are unavailable. |
| `test/server-status-worker.spec.js` | 9 blocks (11 cases) | The exact URL uses the worker's own id and ignores a forged caller id. GET, no body and `Authorization: Bearer`. The snapshot, refresh token and broadcasts are unchanged and no token leaks into the reply. 404 is not_yet_known. 401 refreshes once and retries with the new bearer. A second 401 is unavailable, with tokens kept and no `auth_required`. 403/429/400 and a transport fault are unavailable. With no run the result is no_run and nothing is fetched. With no session the result is unavailable and no status request is made. A content-script sender is refused before any fetch. |
| `test/popup-server-status.spec.js` | 13 blocks (about 25 cases) | Separate labelling, with local receipts, `#status` and the feedback unchanged. Start stays disabled and `outcomeLocked === "true"`, with no `start_import`. The open state has no `%`, ETA or phase. A 404 reads "Not yet known" with no `0`. A local-only family reads "not yet known". Families are never summed (12 and 3, with no "15", "imported" or "total"). The legacy success wording. 6 fault shapes read "Could not check TGP" with no private detail. A foreign reply is hidden. A different-run broadcast clears the region and a same-run broadcast keeps it. With no run, Start stays enabled and the region stays hidden. `serverStatusView` covers every 200 fixture example and every enum terminal has approved copy. |
| `test/transfer-outcome-popup.spec.js` (existing) | 2 assertions changed | See E2-F2. |

**Pre-checks done without the heavy slot** (source-only, no install):
- The 8 changed and new JS files pass `prettier --check` with a cached prettier **3.9.9**. The repo pins **3.9.6**; the base files are canonical under 3.9.9 too. The authoritative check is `npm run check:format` under the slot.
- `messages.json` parses.
- A grep of the new code finds no empty catch, `as any`, `@ts-ignore` or `console.*`; every new `catch` has a body and a comment.
- There is no `@ts-expect-error` in the new tests.

## 5. Gate list (to run ONLY after the parent relays the heavy slot)

1. Take `/home/user/workspace/execution/test-validation.lock` with a nonblocking `flock -n` and never steal it. (One `flock -n … -c true` availability probe was made at pre-check. It found the lock **BUSY**, acquired nothing and was not repeated.)
2. `npm ci`
3. `npm test`. The baseline at `8901d5f5` is 66 files / 1772 tests; expect 69 files and the new cases on top.
4. `npm run gates`, which includes type-check (`jsconfig` checkJs over popup, shared and test), lint, banned, check:fixtures, check:format, deploy-readiness and package integrity.
5. Run `prettier --write` with the repo's 3.9.6 on the changed files only if check:format disagrees with 3.9.9, then rerun.
6. Commit one ordinary commit through the genuine lefthook hooks: gitleaks secrets (the binary from E1's `scripts/install-gitleaks.sh`), banned, deploy-readiness, lint, type-check and format. Bradley Gleave is author and committer, from the repo-local config. No AI trailers, no amend, no bypass, linear history.
7. Record the commit sha and tree in this file, then release the lock.
8. No push or draft PR until instructed; E2-1 permits them later.

## 6. Findings (Safety-ROI)

There are no class A or B findings.

| # | Class | Harm | Decision blocked | Minimum closure | Unlocked |
|---|---|---|---|---|---|
| E2-F1 | C | The brief cites contract `2.0.0-c1-s1.1`; the landed `df713fd9` file is `2.0.0-c1-s2.0`. The consumer is frozen on the landed bytes (blob `3c1fd2ac…`, sha256 `fc42af0a…`). | None | Record it. The tests pin the commit, path and version, so a regenerated contract fails the contract spec rather than silently drifting. | E2 build on landed bytes |
| E2-F2 | C | Two existing assertions in `test/transfer-outcome-popup.spec.js` expected Check status to send exactly one `request_status`. They now expect the exact ordered list `[request_status, request_server_status]`. The same no-Start guarantee is kept: no other message, in particular no `start_import`. | Reviewer acceptance of an edited existing test | The reviewer confirms the change is minimal (13 lines) and still exact-list. | Gates green |
| E2-F3 | C | The backend GET is not a pure read: `flushRun`, a lazy `enforceDeadline` for `mode: server`, and the `SCOUT_IMPORT_STATUS_READ` analytics event. Extension ids are legacy, so the deadline fence does not apply, and no legacy terminal changes. A 401 also triggers one existing-path token refresh and rotation. | None | Disclose it. The read is one GET per user click, with no polling. | n/a |
| E2-F4 | C | `popup/popup.html` (the UX-07 surface) is touched additively: one hidden `<section>`, with no CSS and no change to existing nodes. The rows reuse the existing `.row` / `.label` classes. | UX-07 composition order | If UX-07 lands first, rebase this markup-only hunk. No visual styling is introduced. | UX-07 independence |
| E2-F5 | C | `reason_code`, `phase`, `families[]` and the deadlines are deliberately not shown (CQ-17 / brief). Coaches see a terminal such as "blocked" or "failed" without the server's reason. | None | A later slice needs approved reason copy, which is owner or UX work. | Richer server detail |
| E2-F6 | C | "Copy summary" still copies local receipts only; server lines are not included. | None | Record it. Including them needs approved copy-summary wording. | n/a |
| E2-F7 | C | Extension-minted ids (`imp-…`) are legacy mode and are not paired-setup intents, so the phone or mobile app still cannot address this run. That is the §2 UX-04 gap, and it is unchanged. | Mobile status parity | A backend `runs/start` binding, out of E2 scope. | UX-04 |
| E2-F8 | C | The backend `groupBy` omits zero rows, so a family with local receipts but no server row shows "Committed on TGP: not yet known", even on a settled run where the true value may be 0. This is conservative, following the rule that unknown is never 0. | None | Record it. Showing 0 would need a contract statement that absence after settlement means 0. | n/a |
| E2-F9 | C | The popup copy is English-only (`_locales/en`), like the rest of the popup. | None | Record it. | n/a |
| E2-F10 | C | Pre-formatting used prettier 3.9.9, while the repo pins 3.9.6. | None | The authoritative `check:format` runs under the slot (gate 5). | Commit |

SOURCE_READY
