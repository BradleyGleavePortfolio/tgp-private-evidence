# State and edge-case matrix: UX-01 Importer Journey & State Architecture

Companion to `CANONICAL_MOBILE_JOURNEY_SPEC.md` (J/X ids). Source-only; T4 cumulative planning artifact. Labels: **SOURCE FACT** (pinned source), **CANON** (PLAN/MISSION requirement, not implemented), **PROPOSED** (this spec's choice within CANON). Addendum 2026-09-23 14:03 PDT: the current mobile implementation base is S6 baseline `d51a191098f483cea9abec6cc7e9f3beffd18c06` (mobile #289–#292 heads are its ancestors per parent read-only git); “exists today / none / not present” below means **not present within the inspected source boundary** (public main `a5933fd6`, public PRs, S7 map), not absent everywhere: see the spec's Current-state qualification addendum. Every row that names a backend state refers to the **PLAN-proposed additive contract**, which is not a current API response and must be frozen through the authoritative backend generator with consumer fixtures before any mobile consumer is coded (PLAN §Proposed run-state contract; S7 map “Missing”).

## Section A: Authority and vocabulary

### A1: Who owns which truth

| Truth | Owner | Mobile reads it via | Present in inspected boundary? |
|---|---|---|---|
| Coach identity, role, onboarding completion | Backend | `GET /coach/onboarding.is_complete` (SOURCE FACT) | Yes (completion only; no eligibility) |
| Offer eligibility (role, completed onboarding, rollout enablement) | Backend | CQ-01 | Partially (completion only) |
| Per-account offer decision `yes / later / starting_fresh` | Mobile account-keyed persistence by default (CQ-02); server storage optional | local user-scoped store (#291 pattern) | Pattern yes (S6 lineage); decision store not yet |
| Import intent (`import_intent_id`), setup state, bound extension, destination account | Backend | C1 `pair/current`, `pair/session`, echoes on init/status (SOURCE FACT #526, unlanded) | Partially, unlanded |
| Pairing challenge lifecycle `pending|paired|expired` | Backend | `POST /extension/pair/status` (SOURCE FACT) | Yes |
| Extension capability/version, wrong profile, disabled | Extension → backend handshake | CQ-09 | No |
| Source account identity, permissions, source readiness | Extension preflight → backend | CQ-08 | No |
| Accepted Start, deadline, phase, per-family counts, freshness | Backend (single arbiter) | CQ-11/12 | No |
| Cancellation acknowledgement, fencing | Backend | CQ-11 | No |
| Terminal outcome + coverage manifest + reason codes | Backend | CQ-12/13 | No |
| Native records, owned native IDs, provenance | Backend native domain | existing native reads + CQ-14 | Native writers absent (S8) |
| Extension disconnect/revocation confirmation | Backend/auth authority | CQ-15 | No |
| Local pairing mirror (short-lived pairing code: sensitive credential, stored only under the #291 user-scoped policy, never logged or emitted); `import_intent_id`, idempotency key, cached offer decision (non-secret correlation) | Mobile, user-scoped | #291 pattern (SOURCE FACT) | Yes (#291 is in the S6 `d51` lineage; not on public main) |

### A2: Vocabulary (PLAN-proposed server states; mobile renders, never sets)

| Layer | Values | Notes |
|---|---|---|
| Setup state | `created`, `awaiting_extension`, `paired`, `awaiting_source_auth`, `source_ready`, `expired` | Pairing never implies a run. `expired` here is challenge/setup retention expiry, distinct from pairing-code `expired` (CQ-05). |
| Execution phase | `discovering`, `transferring`, `reconciling` | Set only after server-accepted Start. |
| Terminal | `complete`, `partial`, `blocked`, `failed`, `cancelled`, `timed_out`; plus `legacy` read-marker for pre-contract extension-minted intents | One arbiter; late client completions cannot overwrite. |
| Per-family counts | `observed_unique`, `staged_unique`, `created_native`, `already_present_verified`, `rejected`, `unresolved` + coverage + reason codes | Never summed into “imported”. |
| Timing | `accepted_start_at`, `deadline_at`, `last_observed_at` | Server clocks only; mobile displays relative age, decides nothing. |
| Mobile decode rule | any unrecognized value → `unknown` | SOURCE FACT posture from `decodePairStatus`/`decodeTerminalStatus`: `unknown` never reads as paired/ready/complete/success. |

## Section B: Authoritative state × mobile presentation

Columns: **Must show** (facts mobile is allowed to state), **Must not show**, **Primary / secondary action**, **Roman sentence intent** (voice, not final string), **Screen**, **Gate**.

### B1: Pre-intent

| Server truth | Must show | Must not show | Primary / secondary | Roman intent | Screen | Gate |
|---|---|---|---|---|---|---|
| Not eligible / rollout off / eligibility unreadable | Nothing on Home; Settings entry only if flag on and result access applies | Any offer, “coming soon” teaser |: |: | J2 | now |
| Eligible, no decision, first home entry after `is_complete` true (not fail-open) | Offer card | Time or completeness promises | Yes / Starting fresh / Later | Ask whether the coach has coached elsewhere | J0 | S7 |
| Decision `later` | Compact resume card + Settings entry | Nag cadence, badges | Continue setup | Keep your place | J1/J2 | accepted S6 successor (card); S7 (intent resume) |
| Decision `starting_fresh` | Settings entry only | Home promo | none | none | J2 | accepted S6 successor |
| Decision `yes`, no intent yet | Source selection | Support badges | Choose / Find another platform | Where are your records | J3 | S7 |

### B2: Setup states

| Server truth | Must show | Must not show | Primary / secondary | Roman intent | Screen | Gate |
|---|---|---|---|---|---|---|
| `created` | Chosen shortcut label; “continue on your computer”; handoff options | “Connected”, store name unless verified | Copy setup address / Share… | I will keep your place here | J4 | S7 (+S11 for store identity) |
| `awaiting_extension` (challenge `pending`) | Pairing code (digit-readable, copyable), “enter it in the importer on your computer” | Countdown from client clock; “installed” | Copy code / Cancel pairing (local abandon + server retire when available) | Read this code into the importer | J5 | now (M5 stack) → S7 |
| Challenge `expired`, setup retained | “That code expired; your setup is kept” | Loss of intent, error tone | Get a new code | Codes are short-lived; your place is kept | J5 | S7 (CQ-05) |
| `paired` | Checklist: Importer available ✓, Connected to TGP ✓ (destination account as returned), Previous platform: not yet | Roster deltas, “reconstructed so far”, “running” | Refresh / Open on computer | Your computer is connected to this account | J6 | S7 |
| `awaiting_source_auth` | Previous platform line “sign in on your computer, directly on that site” | Source-specific instructions, screenshots | Refresh | Sign in directly to your coaching platform | J6 | S7 |
| Source identity unconfirmed (evidence missing) | “Confirm source account on your computer” | Assumed account | Refresh | I need to be sure which account this is | J6 | S7/S11 |
| `source_ready` | All three lines ready; “Ready on your computer: press Start there” | Start button on phone (CQ-10); any run phase | Refresh / Stop setup (return to J2 state; PROPOSED) | Everything is ready on your computer | J7 | S7 |
| Setup `expired` (retention) | “This setup expired; nothing was imported” | Failure blame | Start a new setup | Nothing was brought across | J10-like recovery | S7 |

### B3: Running

| Server truth | Must show | Must not show | Primary / secondary | Roman intent | Screen | Gate |
|---|---|---|---|---|---|---|
| Accepted, `discovering`, no denominators | Phase line; indeterminate indicator; families as “not yet known”; freshness; deadline age | Percent, ETA, counts of 0 | Stop import (secondary) | Finding your records | J8 | S7 |
| `transferring`, counts present | Per-family `observed_unique`, `staged_unique` rows; determinate only per family with evidenced stable denominator | 100%; “imported N”; sum across buckets | Stop import | Bringing your records across | J8 | S7 (S8 for `created_native`) |
| `reconciling` | “Checking everything in TGP”; `created_native` / `already_present_verified` as they arrive | “Complete”; final counts | Stop import | Checking everything in TGP | J8 | S8/S9 |
| Heartbeat stale (`last_observed_at` older than server-declared threshold) | “I have not heard from your computer since …”; last known phase | Spinner, progress motion | Refresh / Stop import | I will tell you when I hear from it | J8 | S7 |
| Stop request transmitted, acknowledgement unknown | “Stop requested at …, waiting for the server to confirm” | “Stopped”, “Cancelled” | (button disabled) | I have asked the server to stop | J9 | S7 |
| Stop pressed while phone offline (request not sent) | “No connection. Your Stop request was not sent. Stop from your computer, or retry when connected” | “Stopping”, “asked the server”, claim desktop stopped | Retry Stop / Refresh | I could not reach the server | J9 | S7 |

### B4: Terminal

| Server truth | Must show | Must not show | Primary / secondary | Roman intent | Screen | Gate |
|---|---|---|---|---|---|---|
| `complete` with native reconciliation and native links | Verified families, coverage dates, `created_native`, `already_present_verified`, native links | “Complete” if any required family/period/relationship unresolved (server would not send it; mobile still checks presence of reconciliation block) | Open my clients / Review import details | Your records are ready in TGP | J10/J12 | S9 |
| `complete` with server-asserted verified zero for a family (basis present) | “None found: basis: …” | Blank row, hidden family | Review import details |: | J11 | S9 |
| `partial` | Verified subset labeled partial; missing families/periods; one reason; one recovery action | Success headline; retry as “new success” | Review what is available / Retry (linked to old result) | I could not complete this import | J10/J11 | S9 |
| `blocked` | Exact blocker (reason code → copy): login expired, CAPTCHA, permission revoked, new origin needed, unknown family, inaccessible history, account changed mid-run | Automatic retry loop | What to do on your computer / Review what is available | I stopped before anything unsafe happened | J10 | S7→S9 |
| `failed` | Fact; retained verified progress; correlation id under details | Blame; raw error codes as headline | Try again (new linked attempt) / Review what is available | I could not finish; here is what remains | J10 | S7→S9 |
| `cancelled` | Which verified records remain | “Deleted”, “undone” | Review what is available / Start a new import | I stopped as you asked | J10 | S7 |
| `timed_out` | Deadline reached; verified subset | “Almost done”; five-minute success | Review what is available / Try again | The time limit was reached | J10 | S7 |
| `legacy` (pre-contract intent) | Read-only historical result as recorded; “from an earlier version” | Verified-complete semantics, native counts | Review what is available |: | J10 | S7 |
| Terminal `unknown` (unrecognized enum) | “I do not have a confirmed result yet” + freshness | Any terminal | Refresh |: | J10 | now (decode posture) |

### B5: Account and connection

| Server truth | Must show | Must not show | Primary / secondary | Screen | Gate |
|---|---|---|---|---|---|
| Extension bound to another TGP account | Block; “that computer is connected to a different TGP account” | Silent switch; which other account | Disconnect that connection (server action) / Use a different computer | J6/J13 | S7 (G3) |
| Disconnect requested, unconfirmed | “Disconnecting… server confirmation pending”; re-pair blocked | “Disconnected” | Refresh | J13 | S7 |
| Disconnect confirmed | Connection removed; results still reviewable | Results removed | Connect a computer / Review past imports | J13 | S7 |
| Signed out on phone | Account-scoped local state cleared | Any claim about the extension |: |: | now (#291) |
| Different coach signs in on same phone | That coach's own intent/result or nothing | Previous coach's card, mirror, cached pages |: | all | now (#291 + query-key precedent) |

## Section C: Transition matrix (event → server transition → mobile behavior)

| # | Event | Server transition (authority) | Mobile behavior | Forbidden mobile behavior |
|---|---|---|---|---|
| T01 | Coach answers Yes | offer decision `yes` | route J3 | creating an intent locally |
| T02 | Coach picks shortcut / custom | `created` intent with shortcut label; origin scope pending | route J4; persist idempotency key before init (X1) | opening source login first (current behavior, superseded) |
| T03 | Coach requests code | challenge `pending` under intent | J5; write mirror before showing code (#291) | client countdown |
| T04 | Extension redeems | `paired` | J6 checklist | showing progress/roster delta |
| T05 | Code expires | challenge `expired`, setup retained | J5 recovery “setup kept” | treating as failure of import |
| T06 | Extension handshake reports capability | readiness lines | J6 lines update | inventing remedies |
| T07 | Source login observed with positive evidence | `awaiting_source_auth` → `source_ready` | J7 | Start button |
| T08 | Extension Start accepted | run accepted; `accepted_start_at`, `deadline_at`; phase `discovering` | J8 | local “started” before server confirms |
| T09 | Duplicate Start | same run returned | no change | second run view |
| T10 | Phase advances | `discovering`→`transferring`→`reconciling` | J8 phase line; announce once | percent from counts |
| T11 | Counts update | per-family buckets | rows update; determinate only per evidenced denominator | summing buckets |
| T12 | Heartbeat stale | none (server marks stale or client compares server timestamps only) | stale state; indicator stops | spinner continues |
| T13 | Coach taps Stop | cancel requested; fence at commit epoch | “Stopping…” | “Stopped” |
| T14 | Server resolves cancel vs completion race | one terminal | J10 as returned (may be `complete`) | overriding with `cancelled` |
| T15 | Deadline reached | `timed_out` (or `partial` per arbiter rule) | J10 | client-side timeout decision |
| T16 | Source principal changes mid-run | fence, `blocked` with reason | J10 blocked | continuing progress view |
| T17 | Extension disconnected | binding revoked; active run fenced | J13 confirmed; run shows fenced terminal | claiming revoke before confirm |
| T18 | Coach retries after terminal | new intent linked to old result | new J-flow with link to prior result | reset of old result |
| T19 | New start capability disabled by rollout | new intents refused; results readable | J2 result access; no start entry | hiding results |
| T20 | Flag `extensionImport` turned off |: | route removed; nothing mounts (SOURCE FACT) |: |
| T21 | `IMPORT_REVIEW` off (#290) |: | review reads disabled; journey states still render from status read | showing stale cached review pages |

## Section D: Edge cases E01–E42

Columns: trigger · truth source · mobile state · must show · must not show · recovery · screen · gate · UX label.

| # | Trigger | Truth source | Mobile state | Must show | Must not show | Recovery | Screen | Gate | UX |
|---|---|---|---|---|---|---|---|---|---|
| E01 | Init response lost (network drop after POST) | idempotent init with persisted key (C1 `setup_nonce`) | retry returns same setup | code or setup as returned | second setup, duplicate code | automatic single retry then manual “Try again” | J5 | S7 | UX-03 |
| E02 | Double tap on “Get code” | single-flight (SOURCE FACT hook) + server idempotency | one mint | one code | two codes |: | J5 | now | UX-03 |
| E03 | OS kills app while code shown | #291 mirror | rehydrate → waiting, poll immediately | same code, “still waiting” | “paired” | server status decides | J5 | now (#291) | UX-03 |
| E04 | App restarted mid-run | `pair/current` + status read | J8 as returned | server phase | remembered local phase | foreground re-read | J8 | S7 | UX-04 |
| E05 | Phone offline during run | last successful read | stale view with age | “showing what I last knew at …” | live spinner | refresh on reconnect | J8 | S7 | UX-04 |
| E06 | Phone offline, Stop pressed (request not sent) | none until reconnect | not-sent state; no queue (PROPOSED) | “No connection. Your Stop request was not sent. Stop from your computer, or retry when connected” | “stopping”, “asked the server” | retry when online | J9 | S7 | UX-04/05 |
| E07 | Extension popup closed / worker terminated | backend durable intent | unaffected on phone | phase from server | assumption of failure |: | J8 | S7 | UX-04 |
| E08 | Heartbeat stale > threshold | server `last_observed_at` | stale | age; last phase | progress motion | Refresh; Stop remains | J8 | S7 | UX-04 |
| E09 | Coach signs out on phone mid-run | server run continues | account-scoped state cleared | nothing about extension | “import cancelled” | sign back in → J8 |: | now/S7 | UX-01 |
| E10 | Second coach signs in on same phone | server coach id | first coach's mirrors/pages purged | new coach's own state or nothing | inherited card/intent |: | all | now (#291) | UX-01 |
| E11 | Account switch on phone while previous coach's run active | server | previous run invisible |: | cross-account status |: | all | S7 | UX-01 |
| E12 | Extension missing / not installed | handshake absent | J6 line “Importer available: not yet” | remedy performed on computer; store only if verified | “install failed” guesses | Refresh | J6 | S11 | UX-03 |
| E13 | Extension disabled / outdated / wrong browser profile | capability negotiation | J6 attention line with exact remedy | version requirement as reported | phone-side detection claims | Refresh | J6 | S11 | UX-03 |
| E14 | Extension paired to another TGP account | server binding check | blocked | mismatch fact | other account identity; silent switch | Disconnect (server) / another computer | J6/J13 | S7 | UX-03/05 |
| E15 | Unsupported device only (no desktop) |: | J4 graceful postponement | computer requirement before source login | “connected” | keep place (J1) | J4 | now | UX-03 |
| E16 | Setup URL opened on wrong account's browser | server destination binding | blocked before capture | mismatch | switch | disconnect/re-pair | J6 | S7 | UX-03 |
| E17 | Custom URL private/loopback/link-local/non-HTTPS/lookalike | phone format check + server/extension validation | denied | factual reason | “unsupported platform” blame | edit URL | J3 | now/S7 | UX-03 |
| E18 | Source login expiry mid-run | extension evidence → server `blocked` | J10 blocked | blocker + computer action | retry loop | new linked attempt after re-login | J10 | S7→S9 | UX-05 |
| E19 | CAPTCHA / MFA encountered | same | blocked | fact; TGP does not bypass | instructions to bypass | coach completes on computer, new attempt | J10 | S7 | UX-05 |
| E20 | Permission revoked or new origin required after Start | server `blocked` | blocked | exact need | silent widen | new attempt with pre-Start permission | J10 | S7/S11 | UX-05 |
| E21 | Same-origin workspace switch / shared-cookie account change | fence + `blocked` | blocked | “account changed on your computer” | continuing counts | new authorized attempt | J10 | S7 (G3) | UX-05 |
| E22 | Unknown family discovered with no native destination | reconciliation | `partial` with unresolved family row | family as “no destination yet” | silent omission; `complete` |: | J11 | S9 | UX-06 |
| E23 | Family unobserved / permission-blocked | coverage manifest | row “not available: reason” | reason code copy | 0 |: | J11 | S9 | UX-06 |
| E24 | Attachments/media without destination policy | manifest gap | gap row | gap | “media imported” |: | J11 | S9 | UX-06 |
| E25 | Ingest 200 but native records absent | reconciliation | not complete | staged vs created distinction | usable-client count from staged |: | J8/J10 | S8/S9 | UX-04/06 |
| E26 | Cancel vs completion race | server arbiter | terminal as returned | one outcome | phone override |: | J10 | S7 | UX-04 |
| E27 | Deadline reached during reconciliation | server | `timed_out`/`partial` per arbiter | verified subset | “complete” | review / new attempt | J10 | S7→S9 | UX-05 |
| E28 | Late client completion after terminal | server rejects | unchanged |: | flicker to complete |: | J10 | S7 | UX-04 |
| E29 | Retry after incomplete run | new linked intent | new flow; prior result reachable | link to previous | erased history; duplicate writes (server provenance) |: | J10 | S7→S9 | UX-05 |
| E30 | Duplicate IDs across family/platform/workspace | backend identity | no mobile effect |: | duplicate rows |: | J12 | S8/S9 | UX-06 |
| E31 | Deep link to native id not owned by account | server ownership | neutral “not available in this account” | neutral | existence oracle |: | J12 | S8 | UX-06 |
| E32 | Deep link when `IMPORT_REVIEW` off | flag | native screens still open (they are native), import-detail view off | native record | import detail |: | J12 | now (#290) | UX-06 |
| E33 | Verified zero for a family | server asserts zero **with basis** | J11 disclosure row rendered | “None found, basis: …” | blank/hidden row; inferred zero | none needed | J11 | S9 | UX-06 |
| E34 | Terminal enum unrecognized (version skew) | decode → `unknown` | non-terminal | “no confirmed result yet” | any terminal | refresh; update app | J10 | now | UX-01 |
| E35 | Status read contract drift (Zod strict fails) | boundary throws `contract` error (SOURCE FACT posture) | error state | “I cannot read the import status in this version” | partial render of drifted data | update app / retry | J8 | S7 | UX-01 |
| E36 | Roman flag off | flag | functional variant | plain wording, no face | Roman voice fragments |: | all | now | UX-02/07 |
| E37 | Roman chat generation unavailable |: | static copy | deterministic card | blocked setup |: | J0 | now | UX-02 |
| E38 | Eligibility read fails / fail-open dashboard | server | no offer | nothing | offer on fail-open | Settings entry remains | J0 | S7 | UX-02 |
| E39 | New starts disabled by rollout; run active | server policy (safety fence vs settle) | run view per server; no new-start entry | results | hidden results |: | J2/J8 | S7/S12 | UX-01 |
| E40 | Legacy extension-minted intent found | server `legacy` marker | read-only result | “earlier version” | verified-complete |: | J10 | S7 | UX-06 |
| E41 | Large text (200%) / screen reader on any surface |: | all states remain operable | text + glyph per state; digit-by-digit code | color-only state; clipped digits |: | all | now (UX-07) | UX-07 |
| E42 | Reduced motion enabled |: | static indicators | same information | animated rituals |: | all | now (UX-07) | UX-07 |

## Section E: Local-only state mobile may hold

| Item | Scope | Secret? | Purpose | Cleared when |
|---|---|---|---|---|
| Idempotency key / `setup_nonce` before init | user-scoped | no (non-authorizing) | E01 | setup resolved or purged on sign-out |
| Pairing mirror: pairing code | user-scoped, versioned, shape-guarded (#291) | **Yes**, a short-lived single-use credential; stored only per #291 policy, never logged or emitted in telemetry, deleted at terminal pairing state | E03 | terminal pairing state, sign-out, cross-user detection |
| Pairing mirror: `import_intent_id` | user-scoped (#291 record) | no (non-authorizing correlation) | E03/E04 | sign-out, cross-user detection |
| Offer decision cache | user-scoped | no | render J1 card before server read returns | server read returns / sign-out |
| Last successful status snapshot + server `last_observed_at` | user-scoped, memory or cache | no PII beyond counts | E05 stale view | next successful read / sign-out |
| UI-only phases (`intro`, `customUrlEntry`, `openingLogin`) | ephemeral | no | screen flow | unmount |

Nothing else. In particular: no local phase, no local terminal, no local counts, no client-clock timers that decide state (SOURCE FACT precedent: `useExtensionPairing` reads no wall clock).
