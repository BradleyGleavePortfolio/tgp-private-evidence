# E2 consumer freeze: `GET /api/scout/import/status`

Grant: E2-1 (`daceddc8/SCOPE.md`). Builder: `e2_status_reads_server` (T3). Evidence only. This file freezes one path, as the extension consumes it, from the landed backend contract. It is not a backend change, and it is not a claim about the backend's runtime behaviour beyond what the contract and the landed source state.

## 1. Contract identity (read with `git show`, nothing checked out)

| Item | Value |
|---|---|
| Repo | `BradleyGleavePortfolio/growth-project-backend` |
| Ref | `origin/integration/importer` (fetched 2026-09-25 ~17:15Z) |
| Commit | `df713fd9217df524915348ef8a42c797f288dde1` (PR #539 landing, S7-L) |
| Path | `docs/contracts/importer-openapi.json` |
| Blob | `3c1fd2ac528ef19bb565f4b6f073a2155e8bab3f` |
| sha256 | `fc42af0a8ec8f162dbc8e79dc05eeb09663d735b031314c316d98e834ed8d60e` |
| `info.version` | **`2.0.0-c1-s2.0`** |

**Version drift from the brief.** `UX04_06_BRIEF.md` §7 names `2.0.0-c1-s1.1` (read at `c7a5fe8d`). The landed contract at `df713fd9` is `2.0.0-c1-s2.0`: S7-L added `mode`, `phase`, `accepted_start_at`, `deadline_at`, `last_observed_at`, `execution_epoch`, `claimed_status`, `reason_code`, `families[]`, and the server terminals `complete|blocked|cancelled|timed_out`. The grant (SCOPE.md E2-1) pins `df713fd9`, so this freeze uses `2.0.0-c1-s2.0`. Class C: the pin is the grant's, and the brief's version is superseded.

Fixture derived from this contract: `daceddc8/e2/import-status.fixture.json`. It holds verbatim copies of the six schemas, the request parameter, and synthetic response examples. Its sha256 is recorded in `SOURCE_READY.md`, and a byte-identical copy is committed at `test/fixtures/import-status/import-status.fixture.json` in the extension.

## 2. Request (frozen)

```
GET https://api.tgp.coach/api/scout/import/status?intent_id=<id>
Authorization: Bearer <extension access token>
```

- `operationId`: `ScoutController_getImportStatus`.
- Query: `intent_id` is required, a string with `minLength 1` and `maxLength 128`. It is the only query parameter. The global ValidationPipe uses `forbidNonWhitelisted`, so any extra parameter returns 400.
- Security: `bearer`. The scheme is `http`/`bearer`/JWT, "Supabase-issued JWT". The same scheme is declared on `/api/scout/ingest`, `/ingest/complete` and `/progress`. The controller header (`scout.controller.ts` L24-27 at `df713fd9`) states that JwtAuthGuard verifies "the extension bearer token — the same Supabase access token minted by /auth/extension/*". **So the extension's existing paired-session access token is the correct credential. No new auth is needed.**
- Roles: `@Roles('coach','owner')`, the same as ingest/progress/complete.
- Throttle: `120 / 60 s` per the controller (`@Throttle`). The endpoint is user-triggered only; the extension never polls it.
- Host: `https://api.tgp.coach/*` is already in `manifest.json` `host_permissions`. **No new permission is needed.**
- Body: none. No `Content-Type` is sent.

**Consumer id rule (E2).** The extension sends only its **own** run id: `currentSnapshot.intent.intentId` from the worker. That is `imp-<ms>` or `ext-<ms>`, 17 characters, well inside 1..128. The popup never supplies the id. An id outside 1..128 is not sent; the result is "no run".

## 3. Responses (frozen)

| HTTP | Schema | Meaning (from the contract text) | Extension treatment |
|---|---|---|---|
| 200 | `ScoutImportStatusResult` | Server-authoritative status for that run | Validate the consumed fields strictly (§4), then display |
| 400 | `ErrorEnvelope` | Missing, empty or over-long `intent_id`, or an unknown query parameter | "Could not check" (unavailable) |
| 401 | `ErrorEnvelope` | Missing or invalid bearer | Refresh once, bound to the session generation (the same pattern as `completeIngest`), then "Could not check". Never clears tokens, never broadcasts `auth_required` |
| 403 | `ErrorEnvelope` | Not a coach or owner | "Could not check" |
| 404 | `ErrorEnvelope` | **Uniform**: flag off (dark route), OR unknown, foreign, or no-evidence-yet run. "Deliberately indistinguishable — no existence oracle" | **"Not yet known"** — never 0, never "failed", never "nothing imported" |
| 429 | `RateLimitError` | Rate limited | "Could not check" |
| other / timeout / oversize / malformed | — | — | "Could not check" |

Error bodies are never read or shown. Only the HTTP status class is used.

### `ScoutImportStatusResult` (200). All 14 properties are `required`.

| Field | Type | Consumed by E2? | Note |
|---|---|---|---|
| `intent_id` | string | **yes**: must equal the requested id, else the reply is rejected | |
| `status` | enum `running, success, partial, failed, complete, blocked, cancelled, timed_out` | **yes** | "Proven lifecycle state" |
| `entity_counts[]` | `{entity_type: string, committed: number ≥0}` | **yes** | "Entities actually committed (proof, not an estimate)" |
| `mode` | enum `legacy, server` | **yes** (validated, used to pick the `success` wording) | `server` only for runs started via `POST /scout/runs/start` |
| `completed_at` | date-time \| null | validated only | null while running |
| `started_at` | date-time \| null | no | |
| `phase` | enum `discovering, transferring, reconciling` \| null | no | server runs only; E2 shows no phase |
| `accepted_start_at`, `deadline_at`, `last_observed_at` | date-time \| null | no | E2 shows no deadline, freshness or ETA |
| `execution_epoch` | number ≥1 | no | |
| `claimed_status` | enum `success, partial, failed` \| null | **no, deliberately**: on a server run it is "INPUT to the arbiter, never the terminal itself" | |
| `reason_code` | enum (6) \| null | no | no approved coach copy catalog yet (CQ-17) |
| `families[]` | `ScoutImportFamilyDto` | no | native buckets are null (= not yet known) until S9/S10 |

### Terminal vocabulary (landed source, `df713fd9`)

- Legacy rows (`projectReadStatus`, `scout.service.ts` L528-541): `running` while no settle row exists; otherwise `success|partial|failed` verbatim. An unrecognised persisted value fails closed to `failed`.
- Server rows (`projectServerStatus`; `SERVER_TERMINAL_STATUSES` in `lifecycle/reason-codes.ts` L24-31): `running` while open; otherwise `complete|partial|blocked|failed|cancelled|timed_out`. "`success` never appears on a server row (CQ-18)". "`complete` is written only from an S9 reconciliation verdict."
- A legacy `success` is a **transport settlement**. The backend's own notification title for it is "Import transfer staged" (`notifyComplete`). The consumer must not word it as a verified migration.
- The extension-minted runs (`imp-…`/`ext-…`) are never `POST /scout/runs/start` intents, so today they are `mode: legacy`. E2 still renders the server vocabulary truthfully if it appears.

## 4. Consumer rules (what the fixture-derived tests pin)

1. **Validation.** The worker accepts a 200 only if: the body is a JSON object within the byte bound (64 KiB, through the existing `readBoundedJson`); `intent_id` equals the requested id; `status` is one of the 8 enum values; `mode` is `legacy` or `server`; `completed_at` is a string or null; and `entity_counts` is an array of `{entity_type: non-empty string ≤64 chars, committed: safe integer ≥0}` with no duplicate `entity_type` and at most 32 rows. Anything else is "Could not check". Unconsumed fields are tolerated, so an additive contract change does not break the read.
2. **Unknown is "not yet known", never 0.** A 404 shows "TGP server record: not yet known". A family present in local receipts but absent from `entity_counts` shows "not yet known" on the server line, never 0. The contract's `groupBy` omits zero rows, so absence is not a stated zero.
3. **Never sum buckets.** Each family's committed count is shown on its own row. There is no total, no "imported" wording, and `families[]` buckets are not combined.
4. **No percent and no ETA.** `deadline_at`, `last_observed_at` and `phase` are not rendered, and no progress fraction is computed.
5. **Server terminal is the final state.** When `status ≠ running`, the server section is labelled "Final state (TGP server)". Local receipts stay labelled as this browser's receipts. `claimed_status` is never shown as the result. `running` reads "no final state recorded yet".
6. **Separate labelling.** Server lines live in their own region (`#server-status`) under the heading "TGP server record". The local `#status`/`#progress-list` rendering is unchanged.
7. **No side effect on Start, locking or recovery.** A server reply never touches `start-import`, `outcomeLocked`, the snapshot, storage, tokens or run control.

## 5. Server-side effects of this GET (disclosed, not introduced)

At `df713fd9`, `getImportStatus` is not a pure read:
- `flushRun` persists the coach's own already-accepted in-memory progress snapshot for that key.
- For `mode: server` it runs `lifecycle.enforceDeadline`, which fences an overdue open run to `timed_out` (D-S7L-3, "enforced lazily").
- It emits the analytics event `SCOUT_IMPORT_STATUS_READ`.

Extension-minted ids are legacy, so the lazy deadline fence does not apply to them. The read changes no terminal state on a legacy run. Recorded as Safety-ROI finding E2-F3 in `SOURCE_READY.md`.

## 6. Not frozen

Every other importer path. `families[]`, `phase`, `reason_code` and deadlines as coach-facing content. Mobile consumption. Any `POST /scout/runs/start` binding: extension ids are not paired-setup intents, which is still the §2 UX-04 gap.
