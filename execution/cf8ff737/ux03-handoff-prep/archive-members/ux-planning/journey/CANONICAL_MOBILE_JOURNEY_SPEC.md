# Canonical mobile importer journey spec (source-only): UX-01 Importer Journey & State Architecture

Official UX labels (owner direction 2026-09-23 13:55 PDT): **UX-01** Importer Journey & State Architecture (this document and its two companions); **UX-02** Roman Import Entry & Discovery; **UX-03** Desktop Handoff & Pairing Experience; **UX-04** Import Start, Progress & Stop Experience; **UX-05** Failure, Partial & Recovery Experience; **UX-06** Imported Results & Native Deep Links; **UX-07** Importer Design System & Accessibility (starts in parallel with UX-01, cross-cutting, does not wait for UX-06); **UX-08** End-to-End Journey Usability Proof (final S11/S12 proof). The mapping section maps every J/X/E/CQ id into these labels; no other hierarchy is introduced. The official job/PR map and DAG are owned by the job-map planner and are not duplicated here.

Parent EXEC-e7d2385c. Planning job classified **T4 cumulative** (it specifies behavior at identity, tenant, completion-truth and account-binding boundaries; a wrong spec would propagate into T4 consumer PRs). Requested routing Claude Fable 5 / High: a requested setting, not observed runtime identity. Sole writes: `execution/e7d2385c/ux-planning/journey/**`. Nothing built, run, installed, edited or pushed. No PR numbering, job naming or DAG is proposed here; the separate UX job-map planner owns those and should reference this document by section id (J0–J13, X1–X6, CQ-nn).

Companion files: `STATE_AND_EDGE_CASE_MATRIX.md` (authoritative state × mobile presentation, transitions, edge cases E01–E42) and `CONTRACT_QUESTIONS.md` (CQ-01–CQ-18, what design can and cannot start).

## Current-state qualification (addendum, 2026-09-23 14:03 PDT; bounded, no source code)

1. **Implementation base.** The primary current mobile implementation base is the **S6 lane baseline `d51a191098f483cea9abec6cc7e9f3beffd18c06`**, not only public main `a5933fd6`. Parent read-only git confirms that mobile PR heads [#289 `22354984`](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/289), [#290 `ed0342e9`](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/290), [#291 `d2f0d31c`](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/291) and [#292 `34088677`](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/292) are **all ancestors of `d51`**. The M5 flags, durable user-scoped pairing mirror, correlation and readable/copyable code therefore already exist in the actual candidate lineage; the main-only observations are **main-only** facts and must not be generalized into “pairing/auth/flags are lacking in the candidate.”
2. **#290 base gap.** #290's declared public base `4be69b90` versus #289's head `22354984` is **Class C public-branch lag**, not a missing M5 recomposition or a new gate. No rebase, recomposition or repeated test is demanded by this spec.
3. **Eventual code base.** S6's current product fixes (query-cache/auth) are source-closed with proof under way; any UX implementation must target the **accepted S6 successor**, never public main or a PR head directly.
4. **Absence claims.** Where this spec or the matrix says a capability is “missing”, “does not exist” or “none”, read it as: **not present within the inspected source boundary** (public mobile main `a5933fd6`, public mobile PRs #289–#294, backend PR526/528/529 via the S7 map, mobile decision record) **and canonically required but unproven**. It is not a claim that nothing exists anywhere; private lanes are not enumerated here.
5. The official UX-01–UX-08 names and all other content are unchanged by this addendum except the minimal qualifications marked “(addendum)” below.
6. Revision note (2026-09-23 14:08 PDT): one bounded consistency/format pass on the three planning files. Official labels written as UX-01…UX-08; J0/J1 now separate canonical server eligibility from per-account decision persistence (PLAN requires persistence per account only; no mandatory new server endpoint or gate, no M5 rebase gate; shell and persistence target the accepted S6 successor lineage); J9/B3/E06 distinguish a transmitted Stop request with unknown acknowledgement from an offline unsent request, with no queue; E33 columns aligned; the pairing code is described as a short-lived credential under the #291 policy, distinct from non-secret correlation; CQ-17 uses an approved bounded reason catalog rather than raw server prose; CQ-07 asserts no store availability until verified; numbered header prefixes, em dashes and italics removed. No substantive assertion, case, authority boundary or gate changed; these are edits to the planning artifact, not product findings.

## How to read this document

Every statement carries one label:

- **SOURCE FACT**: verified in pinned source: mobile main `a5933fd6de5616493de75f0db907098b149b955c`, mobile PRs #289–#294 (heads as observed 2026-09-23 via `gh`), the S7 continuation map for backend PR526/528/529, and the canonical documents `live_CONTINUATION_AND_ROMAN_IMPORT_PLAN.md` (“PLAN”) and `live_M-IMPORTER-PRODUCT-MISSION_v1.md` (“MISSION”).
- **CANON**: required by PLAN or MISSION; not yet implemented anywhere inspected.
- **PROPOSED**: this spec's design choice within CANON; changeable without a Bradley decision unless marked otherwise.

Copy is written as **intent**, not final strings. Final strings are a later copy-owner task and must obey the Roman voice contract (SOURCE FACT `src/lib/roman/copy.ts`: no emoji, no contractions, short composed sentences, face-plus-voice invariant).

## Non-negotiable mobile authority boundary

CANON, derived from PLAN §“One control plane” and MISSION §2/§1.9. Mobile is a **mirror and a router**, never an arbiter.

| Mobile may | Mobile must never |
|---|---|
| Show the coach the authoritative server state for their own setup/run, as last observed, with freshness | Invent, infer or “smooth” run authority, phase, progress, counts, coverage, success or failure |
| Route to setup, continuation, review, Stop, Disconnect | Start a run, decide a terminal outcome, or promote `paired` to “importing” |
| Hold a user-scoped local mirror (non-secret correlation plus the short-lived pairing code under the #291 policy) to survive OS kill and re-enter the correct waiting view | Treat a local mirror, a roster delta, a page-local count, an HTTP 200 or an “unknown” enum as truth |
| Render **zero** only when the server explicitly asserts a verified zero with basis | Render silent zero, empty list as “nothing to import”, or `unknown` as zero |
| Show the canonical family names (`workouts`, `client_history`, …) and the coach-chosen platform label as a **navigation shortcut** | Render any source-specific UI, badges (“fully supported”), per-vendor flows or per-vendor code paths (NEW SOURCE → CORE DIFF = 0) |
| Request cancellation, disconnect | Claim a cancellation, disconnect or account switch took effect before the server acknowledges |

Consequence for every screen below: the **primary source of truth column** must be an authoritative backend read (or the frozen pairing status read that exists today). If that read does not exist yet, the screen is **blocked for implementation**, and design may only produce states that degrade truthfully to what exists.

## Verified starting point (SOURCE FACT unless marked)

### Mobile main `a5933fd6` (main-only observations)

| Area | Fact |
|---|---|
| Flag | `featureFlags.extensionImport` ← `EXPO_PUBLIC_FF_EXTENSION_IMPORT`, default OFF unconditionally; OFF removes the Settings row and the `ImportData` route (`src/config/featureFlags.ts` L366–374; `CoachNavigator.tsx` L432–433). |
| Only entry | Coach **Settings → “Import Data”** row (`src/screens/coach/SettingsScreen.tsx` L354–368, a11y label “Import data from another platform”). **No Home entry, no post-onboarding offer, no Roman involvement exists.** `CoachHomeScreen.tsx` contains no import reference. |
| Screen | `ImportDataScreen.tsx`: intro → data-driven picker → safe https open of the chosen login URL via `Linking` → `awaitingExtension` → `ExtensionPairingPanel`. |
| Source catalog | `src/constants/importPlatforms.ts`: 4 named shortcuts + `custom`; comment states shortcuts are “launch SHORTCUTS to a login page, not per-platform mapped tooling”; `id` is sent as `chosen_platform`. |
| Pairing | `useExtensionPairing.ts`: mint `POST /extension/pair/init {chosen_platform}` → poll `POST /extension/pair/status {code}`; states `idle|minting|waiting|paired|expired|authExpired|unavailable|failed|cancelled`; server-authoritative expiry (no client clock); backoff 2s→15s; AppState pause/resume; unknown wire status fails closed to a non-terminal wait; `cancel()` is **local abandon only** because no server cancel exists. |
| Paired view | `ExtensionPairingPanel.tsx` L108–139: after `paired`, the panel shows a **roster delta** (“N new clients since you started this import” / “No new clients have arrived yet. Your import is still running in the browser extension.”), a “What we’ve reconstructed so far” page-local count section and a **“Review clients”** CTA. PLAN §“Contract gap” rules that roster-count changes are **not intent-scoped migration results**; this presentation must be replaced, not extended. |
| Review read | `importReviewApi.ts` → `GET /scout/reconstruct/entities?family&limit&cursor` (contract 1.4.0), Zod-strict, families `workouts|client_history`, `page_count` is page-local, no totals. `useReconstructCounts` renders “distinct entities LOADED SO FAR”. No intent id is sent or returned. |
| Typed vocabulary | `src/types/extensionImport.ts`: `ImportFlowState` phases include a **deferred vocabulary** (`pairing|paired|learning|importing|partial|complete|cancelled`) explicitly “not constructed today”; `decodeTerminalStatus` maps `success|partial|failed`, else `unknown`. |
| Decision record | `docs/importer/MOBILE_IMPORT_DECISION.md`: “No mobile-readable import progress/status endpoint exists”; “No cancel endpoint exists”; progress mirror deferred until a coach-scoped read “plus the intent-id linkage from a paired code” lands. |
| Roman gate | `featureFlags.romanChat` default OFF; `RomanChat` screen registered only under that flag (`CoachNavigator.tsx` L412–417). Roman P3 surfaces obey face-plus-voice invariant (`src/lib/roman/copy.ts` L27–36). Neutral 48px `RomanAvatar` exists. |
| Onboarding completion signal | `RootNavigator.tsx` L612–640: coach role → `GET /coach/onboarding` → `is_complete:false` ⇒ `coach_wizard`; 404 ⇒ `POST /coach/onboarding/start` then wizard; network/5xx ⇒ **fail open to dashboard**. Coach home is reached only when the server says `is_complete !== false` or on fail-open. |
| Tokens | `src/theme/tokens.ts` L17–22: stone-on-bone ≈2.3:1 and mutedGold-on-bone ≈2.9:1 **fail AA for body text**; permitted only as ≥18pt caption/meta or ≥14pt bold badge. |
| Analytics | `src/analytics/events.ts`: `import_entry_opened`, `import_platform_selected`, `import_login_opened/_open_failed`, `import_pairing_*`, `import_paired`, `import_review_opened`. Platform slug is the only import dimension emitted. |

### Open mobile PRs (drafts; observed heads)

| PR | Head | Base (declared) | Content | Tier (register) |
|---|---|---|---|---|
| #289 M5-A | `22354984` | main `a5933fd6` | declare `zod`, `npm ci`, declared-dependency guard | T4 |
| #290 M5-B | `ed0342e9` | `4be69b90` (public base lags #289 head `22354984`; Class C branch lag: addendum item 2; head is an ancestor of S6 `d51`) | `.env.example` flags; new `EXPO_PUBLIC_FF_IMPORT_REVIEW` independent kill switch; review reads require **both** flags | T4 |
| #291 M5-C/D | `d2f0d31c` | #290 head | `importPairingMirror.ts` user-scoped durable pairing mirror (versioned, shape-guarded, cross-user records deleted); rehydrate → `waiting`; sign-out purge; support correlation id | T4 |
| #292 M5-F | `34088677` | #291 head | digit-by-digit a11y announcement, 1.6× scaling cap, 44pt copy control reporting real clipboard result | T4 |
| #293 Roman P1 | `003a9774` | main | private unregistered `ImportOfferCard` (question / value / compact-resume variants; `sir` only with Roman on), `ImportSetupView`, typed local copy, side-effect guards | T1 |
| #294 Roman P2 | `5cbf0de3` (PR body declares `f687ee6f`; **mismatch, record as C**) | #293 head | WIP halted: controlled `ImportProgressView`, `ImportResultView`, `ImportStatusFrame`; copy separates receipt confirmations from unconfirmed records; callbacks only, no lifecycle engine | T2 |

Treatment: #289–#292 are **prerequisite inputs** (flags, durability, a11y of the code), already present in the S6 baseline lineage (addendum item 1), and are reused, not reinvented. #293/#294 are **presentation donors**: their variants and copy tests are useful design input, but a mock or private view is **not product acceptance** and nothing in them may be described as a working journey.

### Backend facts relevant to mobile

| Fact | Source |
|---|---|
| Mobile-callable today: `pair/init`, `pair/status`, `GET scout/reconstruct/entities` (and `/roster`). Everything else in `scout/*` is extension-only; `pair/redeem` is extension-only. | mobile decision record; S7 map §2 |
| C1 (#526, head `881c4c79`, **not landed, not in any accepted lane**) adds `ImportIntent`, `import_intent_id` echoes on init/status/redeem, idempotent `pair/init` with `setup_nonce` (409/410), bearer-only `POST pair/current` and `pair/session`, contract prerelease `2.0.0-c1-s1.0`. | S7 map §2 |
| Not present within the inspected source boundary (addendum item 4): server-accepted Start/cancel/deadline, execution epoch/commit fencing, extension disconnect/revocation, source-principal attribution, intent-required review requests and single generated response schema, native writers, relationships, reconciliation. | S7 map §2 “Missing” |
| PLAN proposes (not current API): setup states `created, awaiting_extension, paired, awaiting_source_auth, source_ready, expired`; phases `discovering, transferring, reconciling`; terminals `complete, partial, blocked, failed, cancelled, timed_out`; per-family counts `observed_unique, staged_unique, created_native, already_present_verified, rejected, unresolved` + coverage + reason codes; immutable `accepted_start_at`, `deadline_at`, `last_observed_at`. | PLAN §“Proposed run-state contract” |
| Readiness gates (state telemetry): S7 composed foundation + C1/lifecycle/forward-2.x; S8 native writers; S9 relationships/reconciliation; S10 unseen-source induction; S11 complete customer/multi-host journey; S12 real acceptance/pilot. | `LAST_OPERATOR_STATE.md` |

## Journey overview

One server-owned **import intent** per coach attempt; one engine; the phone explains, routes and mirrors. Stages:

```
J0 Eligibility + Roman offer (first coach-home entry after authoritative onboarding completion)
J1 Answer: Yes → J3 | Later → J2 compact resume | Starting fresh → J2 Settings only
J2 Permanent entries: Home compact card (resume) + Settings → Import my records
J3 Source selection (shortcut, not adapter)
J4 Continue on your computer (extension install/discovery explained before any source login)
J5 Pairing code (existing M2 + M5 stack) → server `paired`
J6 Readiness mirror: extension capability, destination account, source account, permissions
J7 Start-once (extension-owned; phone shows “ready on your computer”, never a Start button)
J8 Progress mirror (phase, per-family measured counts, freshness, Stop)
J9 Stop / cancel (request → stopping → server-confirmed)
J10 Terminal result (complete | partial | blocked | failed | cancelled | timed_out | legacy)
J11 Reconciliation / completeness disclosure (per family, coverage, unresolved, basis)
J12 Native review + deep links (owned native IDs; fail closed elsewhere)
J13 Disconnect importer (Settings), sign-out and account-switch behavior
X  Cross-cutting: recovery, accessibility, quiet-luxury, Roman-off, analytics
```

## Screen-by-screen specification

Each screen lists: purpose · truth source · presentation (PROPOSED unless labeled) · actions · truth rules · copy intent · negative states · a11y · gate · start-now?

### J0: Eligibility and Roman post-onboarding offer

- **Purpose.** CANON (PLAN §Entry): one skippable Roman offer on the **first eligible coach-home entry after authoritative onboarding completion**; not a seventh wizard step; never blocks the app.
- **Truth source.** Eligibility must be **server-side** (PLAN “server-side eligibility”, ruling R-ONBOARDING-ROLE-GATE-1 as cited). SOURCE FACT: the only completion signal today is `GET /coach/onboarding.is_complete`; there is **no eligibility/offer-state read** (CQ-01). The fail-open path (network/5xx → dashboard) must **not** count as “onboarding complete” for offer purposes.
- **Presentation.** One card on coach Home, Roman face (existing `RomanAvatar`) + one question: “Have you coached on another platform before[, sir]?” Address form only when the coach's known preference permits; otherwise omit (CANON). Responses: **Yes** / **I am starting fresh** / quiet **Later**. Roman-flag OFF ⇒ same card without face/voice, plain functional wording (CANON).
- **Actions.** Yes → reveal value line + primary “Import my records” → J3. Later → J1 defer. Starting fresh → J1 decline.
- **Truth rules.** Shown once per account per eligibility. PLAN requires only that the decision is persisted per account; storage location is a design choice (CQ-02), not a new mandatory server endpoint or gate. Eligibility itself stays server-side (role, completed onboarding, rollout enablement). Clients never see it; role is server-authorized, never inferred (PLAN open decision “role terminology”).
- **Copy intent.** Question, not pitch. Value line: bring clients and coaching history into TGP; no promise of time, completeness or platform support.
- **Negative states.** Eligibility read unavailable → show **nothing** (Home unchanged); Settings entry remains. Rollout disabled → nothing. Roman chat generation unavailable → static approved copy still works (CANON: deterministic task card, not LLM output).
- **A11y.** Card is a single group with heading + 3 buttons ≥44pt; focus lands on the question when the card appears; no auto-dismiss; announced once (polite).
- **Gate.** Design: now. Card shell and per-account decision persistence: implementable on the accepted S6 successor lineage (no M5 rebase gate). Showing the offer to real coaches: **S7** (server eligibility/rollout enablement, CQ-01; C1 intent so “Yes” leads somewhere durable).

### J1: Defer, decline, resume

- **Purpose.** CANON: “Later” dismisses and persists per account, leaving a compact “Continue import setup” card + Settings entry; “starting fresh” removes the promotional reminder but keeps the permanent Settings entry. Resume returns to the **same intent** without repeating onboarding questions.
- **Truth source.** Per-account offer decision (PLAN: persisted per account; storage per CQ-02, default account-keyed user-scoped persistence following the #291 mirror pattern) and `pair/current` owned-setup lookup once C1 lands (SOURCE FACT: #526 adds bearer-only `POST pair/current`). Until then, resume can only re-enter the local mirror `waiting` state (#291), which is pairing resume, not intent resume.
- **Presentation.** Compact Home card: one line + one action. No countdown, no nag cadence, no badge.
- **Truth rules.** Another account on the same device must not inherit the card or the intent (PLAN scenario 2; #291's cross-user purge pattern is the existing precedent). Decline is reversible only through Settings (PROPOSED).
- **Negative states.** Decision write fails → keep the card visible and retry silently on next entry; never claim “saved”.
- **Gate.** Design now. Defer/decline persistence and the compact card: accepted S6 successor lineage. Resume of a durable intent: S7 (C1 `pair/current`).

### J2: Permanent entries: Home and Settings

- **SOURCE FACT.** Only the Settings row exists (“Import Data”). CANON requires **one named Home entry** plus Settings → “Import my records”.
- **Presentation.** Settings row label intent “Import my records” (rename of the existing row, PROPOSED; string not final). Home entry is the J1 compact card when an intent exists or was deferred; otherwise Home shows nothing (PROPOSED: no permanent Home promo for coaches who declined).
- **Truth rules.** Entry visibility: `extensionImport` flag ON **and** server eligibility; the route must still resolve for **result review** even when new starts are disabled (CANON “do not remove result access when new starts are disabled”; CQ-03 asks for a distinct “new starts enabled” capability).
- **Gate.** Settings rename + card shell: design now, implementation on the accepted S6 successor (addendum; no contract needed for the shell). Resume semantics: S7.

### J3: Source selection

- **SOURCE FACT.** Catalog picker with `custom` exists; https-only guard `safeImportLoginUrl`; slug sent as `chosen_platform`.
- **CANON.** “Where are your records?” Searchable familiar names + “Find another platform.” **No “fully supported” badges without evidence.** Choice is a **navigation shortcut**, not a vendor adapter or completeness guarantee. Custom targets: only independently validated **public HTTPS** origins may proceed; private/loopback/link-local, non-HTTPS, privileged schemes and redirects into denied destinations are hard-denied regardless of consent.
- **Presentation.** Searchable list (PROPOSED: search field appears only above N entries), custom URL entry with format feedback only (no reachability probe from the phone: PROPOSED, avoids phone-side SSRF/rebinding surface; server/extension validate). No icons implying partnership (SOURCE FACT: current catalog uses generic Ionicons: acceptable).
- **Truth rules.** The selected label is stored on the intent as a **friendly shortcut**; origin scope is a separate contract field decided by the extension preflight (PLAN decision 3; CQ-06). Mobile never renders source-specific steps, screenshots, or help text.
- **Negative states.** Invalid/denied URL → factual reason + edit; unknown platform → proceeds identically to any other (CORE DIFF = 0).
- **Gate.** Design now; the existing screen can be restyled now (T-graded separately by the job-map owner); binding the choice to an intent is S7.

### J4: Continue on your computer (desktop continuation, extension install/discovery)

- **CANON.** “Continue on your computer. I will keep your place here.” Explain **before any source login** that a supported desktop browser performs the import and the phone follows progress; installation/approval belongs to the browser (Add to Chrome / Add extension gesture; org policy may block). Open/copy a **trusted TGP setup address containing at most a non-authorizing opaque locator**: never tokens, pairing codes, emails or credentials; optional OS share sheet **only after the coach chooses**; no automatic email. Phone-only migration is **not promised**; postponement stays graceful.
- **SOURCE FACT.** Today the phone opens the **source login URL** directly with `Linking.openURL`, then shows the pairing panel. CANON reorders this: computer handoff and extension readiness precede source login, and the source tab is bound on the desktop, not opened from the phone. This is a **behavioral change to `ImportDataScreen`**, not a restyle.
- **Presentation.** One headline, one Roman sentence, primary “Copy setup address” / “Open on this device” (when the device is a supported desktop-class browser: detection is the extension's, not the phone's), secondary “Share…”. Checklist preview (Importer available → Connected to TGP → Previous platform ready) is **read-only mirror** of desktop state (J6).
- **Truth rules.** The phone never says “connected”, “installed” or “ready” from its own reasoning (PLAN scenario 3). No store availability, listing name or version is asserted until verified (open decision “verified store listing”; CQ-07).
- **Negative states.** Unsupported device only → explain computer requirement, preserve place (J1 card), no error tone. Locator issuance fails → offer the pairing code path (J5) which needs no URL.
- **Gate.** Design now. Implementation: **S7** (locator/`pair/current`, CQ-04) and **S11** (extension distribution/store identity, capability negotiation).

### J5: Pairing code

- **SOURCE FACT.** Mint/poll state machine, server-authoritative expiry, durable user-scoped mirror (#291), a11y digit reading and honest copy result (#292), recovery copy for expired/failed/authExpired/unavailable/cancelled. C1 (#526) makes init idempotent with `setup_nonce` and echoes `import_intent_id`.
- **CANON.** First-connect may require the code; **returning valid paired coaches do not repeat it**; account binding checked again before Start on the extension; pairing never implies a run; a retained intent must not reserve a code forever.
- **Presentation.** Keep the M5 stack's panel; remove from `paired` any roster-delta or “reconstructed so far” claim (see J8). PROPOSED: after `paired`, the phone transitions to J6 mirror, headline intent “Connected to your computer”, not “Paired”.
- **Truth rules.** The `paired` terminal means exactly “this extension redeemed this code for this account”; nothing about source readiness or running.
- **Negative states.** Existing recovery set is adequate as intent; add **“this computer is connected to a different TGP account”** (J6/E14) and **“pairing challenge retired, setup kept”** (expiry of the code without loss of intent: CQ-05).
- **Gate.** Existing behavior: present in the S6 baseline lineage (#289–#292 ancestors of `d51`; addendum); code base is the accepted S6 successor. Intent echo/idempotency consumption: **S7**.

### J6: Readiness mirror: capability, destination account, source account, permissions

- **CANON.** Distinct recoverable states for missing / disabled / outdated / wrong-profile extension, unsupported device, expired pairing; **account mismatch** (extension paired to another TGP account) stops before capture and offers explicit disconnect/re-pair, never silent switching; source identity established by positive evidence, else “Confirm source account” persists; permissions requested only for chosen origins.
- **Truth source.** Setup state on the intent (`awaiting_extension | paired | awaiting_source_auth | source_ready | expired`, PLAN-proposed; CQ-08) plus capability/version negotiation results (CQ-09). None exists today.
- **Presentation.** Three-line checklist on the phone, each line one of {not yet, ready, needs attention}; “needs attention” lines carry the exact remedy performed **on the computer**; the phone offers only “I have done this: refresh” (PROPOSED) and never a remedy it cannot perform.
- **Truth rules.** Every line is a server-observed fact with a `last_observed_at`; stale ⇒ the line shows its age, not a guess. Destination account line shows the **server-owned** coach identity (name/email as returned), never client-supplied.
- **Negative states.** Mismatch → block + “Disconnect that connection” routes to J13 flow; wrong profile / disabled → remedy text; stale > threshold → “I have not heard from your computer since …”.
- **Gate.** Design now. Implementation **S7 (setup states) + S11 (capability negotiation, extension handshake)**.

### J7: Start-once confirmation

- **CANON.** The **Ready card is extension-owned** (source site/account, destination account, read-only promise, scope; one “Start importing”). Start occurs on the extension-owned origin because on-page rendering is not trusted identity proof. Duplicate Start returns the same accepted run with the original deadline.
- **Mobile role (PROPOSED within CANON).** The phone shows “Ready on your computer: press Start there.” **No Start button on the phone** in this journey version; this avoids a second Start authority and a phone-side claim about source identity. Recorded as CQ-10 (whether a future phone-initiated Start is desired is a product choice the canonical sources answer implicitly by placing Start on the extension; not a Bradley decision now).
- **Truth rules.** Phone flips to J8 only when the server reports an **accepted** run (`accepted_start_at`, `deadline_at`), never on a local or extension-side claim.
- **Gate.** Design now; implementation **S7 (server-accepted Start, CQ-11)**.

### J8: Progress mirror

- **CANON.** Phases “Finding your records” (`discovering`), “Bringing your records across” (`transferring`), “Checking everything in TGP” (`reconciling`); **measured per-family counts and freshness**; accessible secondary **Stop import** on the phone; indeterminate while scope unknown, determinate only with an evidenced stable denominator; no 100% before native reconciliation; no spinner claiming work after heartbeat stale; closing the UI does not cancel.
- **Truth source.** Authoritative intent-scoped run status read (phase, per-family counts, `last_observed_at`, `deadline_at`): **not present within the inspected boundary** (SOURCE FACT decision record; S7 map “Missing”; addendum item 4). Transport: reuse existing realtime where suitable, else bounded foreground-only reads with backoff and refresh on focus, explicit stale state; any polling exception documented (PLAN decision 6; CQ-12).
- **Presentation.** Stable panel: phase line, freshness line (“as of …”), per-family rows showing only server-supplied `observed_unique` / `staged_unique` / `created_native` with explicit labels; a family with no basis shows “not yet known”, never 0. Deadline shown as server `deadline_at` relative time (PROPOSED: display only; never a client-computed timeout decision: Rule “no client clock” precedent in `useExtensionPairing`).
- **Truth rules.** “Sent” ≠ “stored”: mobile must display `created_native` and `already_present_verified` distinctly from `staged_unique`; never sum them into “imported”. The current `paired`-view roster delta and page-local reconstruct counts are **removed from the run view** (they are not intent-scoped; PLAN §Contract gap).
- **Negative states.** Stale heartbeat → “I have not heard from your computer since …” + no spinner; offline phone → “Showing what I last knew at …” and Stop shows the not-sent wording if pressed (J9); app background/restart → re-read on foreground, no local phase memory beyond the intent id.
- **A11y.** Polite, deduplicated announcements on phase change only; counts not announced on every tick; Stop is a real button, reachable first in traversal after the heading (PROPOSED).
- **Gate.** Design now. Implementation **S7 (status read/contract) → S9 (native counts have meaning only after writers S8 and reconciliation S9)**. A progress mirror wired before S8/S9 may show phase + observed/staged counts only, with created_native rows labeled “not yet available in this version” (truthful boundary, PROPOSED).

### J9: Stop / cancel

- **CANON.** Stop requests cancellation, not deletion; **no confirmation ritual**; until acknowledged show “Stopping”; the desktop offline wording is “Stopped on this computer. I am waiting to confirm the server has stopped”. Phone variants must distinguish two cases: request **sent, acknowledgement unknown** (“Stop requested at …, waiting for the server to confirm”) and request **not sent because the phone is offline** (“No connection. Your Stop request was not sent. Stop from your computer, or retry when connected”); the phone never says it asked the server unless the request was transmitted, and never queues a Stop for later (E06). A phone stop must reach the **same server arbiter**; an offline phone cannot claim it stopped the desktop executor; the final view states which verified records remain.
- **SOURCE FACT.** No server cancel exists; current `cancel()` is local abandon of pairing only.
- **Presentation.** Secondary button on J8; pressing it switches the button to a non-interactive “Stopping…” state with the request time; result arrives via J10 as `cancelled` (or as another terminal if the server resolved a race, e.g. `complete`).
- **Truth rules.** Never show “Stopped” or “Cancelled” from the phone's own request; duplicate taps are idempotent at the server (PLAN).
- **Gate.** Design now; implementation **S7 (server cancel + fencing, CQ-11)**.

### J10: Terminal result

- **CANON terminals.** `complete | partial | blocked | failed | cancelled | timed_out`, one server arbiter. MISSION §1.9 names `complete | partial | failed | cancelled`; PLAN adds `blocked`, `timed_out`. Legacy extension-minted intents must be readable as **legacy**, never promoted to verified-complete (PLAN decision 5).
- **Presentation.** One headline per terminal; one reason (low-cardinality reason code rendered as approved copy) and one safe recovery action for non-complete; verified families, coverage dates, created/already-present counts and native links for complete. “Open my clients” primary, “Review import details” secondary (both inspect **actual native records**). Partial: existing verified records labeled partial; retry cannot manufacture new success or erase the old outcome.
- **Truth rules.** `complete` is rendered **only** when the server says complete **and** the response carries native reconciliation (PLAN Goal 5; scenario 12). `unknown`/unrecognized terminal → “I do not have a confirmed result yet” (existing `decodeTerminalStatus` posture). Zero created with complete ⇒ only if server asserts verified zero with basis (E33).
- **Negative states per terminal.** `blocked`: exact blocker (login expired, CAPTCHA, permission revoked, new origin required, unknown family, inaccessible history) + “what to do on the computer”; `failed`: fact + retained progress + retry route that links to the old result; `cancelled`: which verified records remain; `timed_out`: deadline reached, verified subset remains, “not a five-minute success”; `legacy`: read-only, no completion claim.
- **Gate.** Design now. Implementation **S7 (terminal read) + S8/S9 (native counts, reconciliation manifest) → S11**.

### J11: Reconciliation and completeness disclosure

- **CANON.** For each observed family: source total or alternative completeness basis, pagination terminal evidence, date windows, relationship closure, exclusions and contradictions; unique source identities vs verified created / already-present vs unresolved / rejected. Unsupported, unobserved, permission-blocked or unknown is **never silently zero or “not applicable”**; attachments/media need an explicit destination policy or appear as gaps; no completeness basis ⇒ status stays incomplete.
- **Presentation.** “Review import details”: family list; each row shows counts by named bucket, coverage window, basis kind, and an expandable list of reason codes (rendered copy, no PII); an “Additional discovered family: no destination yet” row appears when the server reports one.
- **Truth rules.** Rows are rendered from the server **coverage manifest** only (CQ-13). Family names are canonical (`workouts`, `client_history`, …): no source vocabulary.
- **Gate.** Design now; implementation **S9** (reconciliation) and **S8** (native families exist to reconcile against).

### J12: Native review and deep links

- **CANON.** User-facing views refresh from the **native domain** and link by **owned native IDs**, not a roster delta; links work in the owning account and fail closed elsewhere; imported identity creates no login and sends no invitation; conflicts are recorded, not overwritten.
- **SOURCE FACT.** `useRosterReviewDelta` and `useReconstructCounts` exist as the current “review”; #290 puts reads behind an independent `IMPORT_REVIEW` kill switch (retain).
- **Presentation.** “Open my clients” → existing native client list, optionally filtered by an `import_intent_id` provenance filter (CQ-14). Client detail → existing screens showing imported history with provenance label (“brought across from your previous platform on …”: no vendor name required; showing the coach's chosen label is acceptable as a shortcut).
- **Truth rules.** A deep link carrying a native id that is not owned by the current account resolves to a neutral “not available in this account”: no existence oracle.
- **Gate.** Design now (list/detail provenance treatment is design-only). Implementation **S8 (native writers) → S9**; kill-switch semantics from #290 now.

### J13: Disconnect importer; sign-out; account switch

- **CANON.** Disconnect is a **server-confirmed security action**: revokes the extension binding, fences its active run, rejects future Start/ingest/native-commit from the old binding; if offline or revocation fails, “Disconnected on this computer; server confirmation pending” and re-pair blocked until confirmed. Ordinary app sign-out clears account-scoped local state but **does not claim** the extension connection is revoked; a separate “Disconnect importer” action exists; previously authorized results remain reviewable after reauthentication.
- **SOURCE FACT.** #291 purges the user-scoped pairing mirror on sign-out; no revocation endpoint exists (S7 map “Missing”; PLAN G3 auth-owner freeze).
- **Presentation.** Settings → Import my records → “Connected computers” (PROPOSED name) listing the server-known binding(s) with last seen; “Disconnect” → pending → confirmed. Account switch on the phone shows the new account's own intent/result or nothing.
- **Truth rules.** Phone never says “disconnected” until server confirms; sign-out copy must not mention the extension.
- **Gate.** Design now; implementation **S7 (G3 revocation freeze by auth owner; CQ-15)**.

## Cross-cutting requirements

### X1: Crash, restart, reconnect, account switch (mobile side)

- Persist only: `import_intent_id` (non-secret correlation), offer decision cache, and the pairing mirror (#291 pattern; the pairing code inside it is a short-lived credential handled under that policy, not non-secret). Never phase, counts, or terminal.
- On foreground/restart: `pair/current`-class lookup (CQ-04) then status read; render exactly what returns. If the lookup says none, show J2 entries only.
- Lost init response: idempotency key persisted **before** init (PLAN crash-safe creation; #526 `setup_nonce`), retry returns the same setup (E01).
- Account switch: all import UI is keyed by server coach id; cached pages and mirrors for another id are discarded (existing #291 / `useReconstructCounts` precedent).

### X2: Accessibility (WCAG 2.2 AA; PLAN §Interaction; G02)

44×44pt targets; visible focus and logical traversal; dynamic type to 200% without clipping (the #292 1.6× cap applies to the **pairing code only**, because a clipped digit is a functional failure: everything else scales); reduced-motion parity; state never by color alone (each status line has text + glyph); polite deduplicated announcements; error text states fact, remedy, retained progress; stone/mutedGold never as body text (SOURCE FACT tokens matrix). Stop discoverable without instruction and operable by screen reader (PLAN scenario 19).

### X3: Quiet-luxury presentation (PLAN §Luxury; MISSION §1.10)

Existing bone/cream/ink/forest palette, Cormorant headings, Inter body, semantic dark-mode tokens, existing `RomanAvatar`; single column, one headline + one Roman sentence + one primary CTA; details expand in place; sticky actions never cover large text, keyboard content or the bottom safe area; subtle existing transitions only (no confetti, bouncing Roman, fake typing delays, animated loading rituals); expert diagnostics collapsed; correlation id shown only inside “details” for support (#291 precedent). No new brand or mascot.

### X4: Roman-off and chat-unavailable parity

Every surface has a Roman-on variant (face + voice) and a Roman-off variant (same layout, no portrait, functional wording). Chat generation unavailable never blocks setup: static approved copy. A typed “Import my records” in Roman chat routes to the same controller as the card (CANON): a routing action, not an LLM-decided flow.

### X5: Analytics and privacy (PLAN §Success metrics)

Funnel: offer viewed → import selected → desktop ready → paired → source ready → Start accepted → native complete/incomplete → native review opened. Opaque correlation, low-cardinality reason codes, aggregate durations; no credentials, raw URLs with queries, client names, health values, payment data. Existing events cover entry → paired → review opened; the remaining steps are server-observed facts and should be emitted from the authoritative status transitions, not from phone-side guesses (PROPOSED).

### X6: NEW SOURCE → CORE DIFF = 0 conformance (mobile)

Adding a platform to the catalog is a **data row** (label, shortcut URL). No mobile screen, copy branch, test or flag may key on a platform id except analytics dimension and the shortcut label. Families are canonical. Any proposed mobile change that requires a per-vendor branch is a spec violation and must be rejected at review.

## Screen-to-gate readiness map

| Screen / state | Needs (contract or capability) | Gate for implementation | Design-only now? |
|---|---|---|---|
| J0 offer, J1 defer/decline | server eligibility/rollout enablement (CQ-01); per-account decision persistence (CQ-02, design choice, no new endpoint required); C1 intent for “Yes” | shell and decision persistence: accepted S6 successor; live offer: S7 | Yes: layout, variants, copy intent, Roman on/off |
| J2 entries | flag + eligibility; result access independent of new-start enablement (CQ-03) | shell on accepted S6 successor; semantics S7 | Yes |
| J3 source selection | none for restyle; intent binding + origin/shortcut split (CQ-06) | restyle now (graded by job-map owner); binding S7 | Yes |
| J4 computer continuation | opaque locator / `pair/current` (CQ-04); verified store identity (CQ-07) | S7 + S11 | Yes |
| J5 pairing | existing in S6 lineage; intent echo/idempotency (C1) | accepted S6 successor; C1 consumption S7 | Yes (only negative-state additions) |
| J6 readiness mirror | setup states (CQ-08), capability negotiation (CQ-09), source identity evidence | S7 + S11 | Yes |
| J7 ready / start-once | server-accepted Start (CQ-11) | S7 | Yes |
| J8 progress | intent-scoped status read + transport (CQ-12); native counts | S7 (phase/observed) → S8/S9 (native) | Yes |
| J9 stop | server cancel + fencing (CQ-11) | S7 | Yes |
| J10 terminals | terminal read, legacy flag, reason codes | S7 → S9 → S11 | Yes |
| J11 reconciliation | coverage manifest (CQ-13) | S8 + S9 | Yes |
| J12 native review/deep links | native writers, provenance filter (CQ-14), fail-closed link resolution | S8 → S9 | Yes |
| J13 disconnect | G3 revocation contract (CQ-15) | S7 (auth-owner freeze) | Yes |
| Multi-host, unseen-source, pilot proof of the whole journey |: | S10 (induction), S11 (multi-host journey), S12 (pilot/acceptance) | Usability/a11y test plans now; results only at S12 |

**Design-only work that can start now without touching data flow:** every J-screen's layout, variant matrix, copy-intent tables, Roman on/off parity, a11y annotations, reduced-motion specs, negative-state inventory, and usability/a11y test scripts; classification of which #293/#294 views map to which J-ids (as donors).

**Implementation blocked on contracts/native writers:** any consumer of setup/run/terminal/coverage reads, Start/cancel/disconnect actions, eligibility/offer-state, locator, and native provenance; the `ImportDataScreen` reordering (J4 before source login) may be **built dark** behind the existing flag but cannot be accepted as a journey until the readiness mirror has a truth source.

## What this spec removes from the current mobile flow (PROPOSED, within CANON)

1. Roster-delta and “reconstructed so far” as progress on the `paired` view (not intent-scoped; PLAN Contract gap).
2. Phone-side direct open of the source login URL as the first step (moves after computer readiness; J4/J6).
3. The label “Paired” as a coach-facing terminal; it becomes a checklist line.
4. Deferred vocabulary `learning|importing|partial|complete` in `ImportFlowState` is superseded by the server contract vocabulary once frozen; do not implement the old local vocabulary.

## Usability target versus observed (for UX-08)

- **Canonical target (PLAN §Success metrics, “Usability”):** at least 9 of 10 unfamiliar-coach pilot participants complete authorized setup and find native results without moderator instruction; setup time measured separately. Companion canonical targets: 100% of eligible enabled new-coach test sessions reach the skippable offer; ≥90% of ≥10 first accepted runs by distinct coaches within a **predeclared** source/account-size envelope fully reconciled `complete` within 300 s, with partial/blocked/failed/timed-out/cancelled runs kept in the denominator; zero required coach actions after accepted Start; no unresolved blocking a11y issue on any surface.
- **Observed:** **none.** No pilot, usability session, or journey test has been run against any candidate; #293/#294 are private presentation views with component tests only. This spec records no observed completion rate and none may be inferred from design review (PLAN: “Record confusion and abandonment rather than claiming ‘luxury’ from a design review alone”).
- **UX-08 obligation:** unfamiliar coaches on phone + computer, screen readers and large text; live paths, not fixture screenshots; results reported with the full denominator and the declared envelope; only at S11/S12.

## Mapping of this spec into the official UX labels

| Official label | This spec's ids | Reuse inputs (job-map owner verifies, does not assume) |
|---|---|---|
| **UX-01** Importer Journey & State Architecture | authority boundary; journey overview; screen-to-gate readiness map; removals section; all of `STATE_AND_EDGE_CASE_MATRIX.md` (A/B/T tables, E01–E42); `CONTRACT_QUESTIONS.md` CQ-01–CQ-18 | `src/types/extensionImport.ts` vocabulary (to be superseded by the frozen server contract); mobile decision record |
| **UX-02** Roman Import Entry & Discovery | J0, J1, J2, X4 (Roman-off parity), CQ-01/02/03/16 | #293 `ImportOfferCard` variants and copy tests (presentation donor); existing Settings row; `RomanAvatar` |
| **UX-03** Desktop Handoff & Pairing Experience | J3, J4, J5, J6, CQ-04/05/06/07/08/09 | #291 durable user-scoped pairing mirror; #292 copyable/readable code; #293 `ImportSetupView`; existing `useExtensionPairing`, `importPlatforms`, `safeImportLoginUrl` |
| **UX-04** Import Start, Progress & Stop Experience | J7, J8, J9, CQ-10/11/12 | #294 `ImportProgressView` / `ImportStatusFrame` (controlled donor; no lifecycle engine) |
| **UX-05** Failure, Partial & Recovery Experience | J10 non-complete terminals, X1 recovery, E01–E42 negative rows, CQ-17 | #294 `ImportResultView` blocked/interrupted/failed/timed-out/cancelled variants; existing pairing recovery copy set |
| **UX-06** Imported Results & Native Deep Links | J10 complete, J11, J12, J13 (results remain reviewable after disconnect), CQ-13/14/15 | #290 independent `IMPORT_REVIEW` kill switch; `importReviewApi` (to be replaced by intent-required generated contract); `useRosterReviewDelta` (retire as progress) |
| **UX-07** Importer Design System & Accessibility | X2, X3, X6, tokens matrix facts in the mobile main observations, a11y lines of every J-screen | `src/theme/tokens.ts`; #292 a11y patterns; Roman copy voice contract |
| **UX-08** End-to-End Journey Usability Proof | usability targets section, PLAN functional scenarios 1–19 as the acceptance script, S11/S12 rows of the readiness map | none yet (no observed results exist) |

## Findings and decision status

- **No Class A/B finding.** Class C records: (i) #290 public base `4be69b90` lags #289 head `22354984`: public-branch lag only; all four M5 heads are ancestors of S6 `d51` (addendum item 2), so no recomposition or gate is added; (ii) #294 body declares head `f687ee6f` while GitHub reports `5cbf0de3`: record the observed head, treat the body as stale; (iii) the current `paired` presentation contradicts PLAN's intent-scoped rule and must be superseded, not extended.
- **Bradley decision required: NO.** Canonical sources resolve every material user/product choice encountered (offer placement, Start location, Stop semantics, terminals, disconnect semantics, phone-only non-promise, billing as read-only records). CQ-10 (phone-initiated Start) and CQ-16 (whether “starting fresh” hides the Home card permanently) are recorded as design defaults resolvable by the product owner at any time, not blockers.
