# UX-04 / UX-05 / UX-06 readiness brief

Parent: EXEC-CE3748CB. Grant: `execution/ce3748cb/UX04_06_READINESS_GRANT.md`. T3 read-only planning brief; the only write is this file.

Everything was read with `git show`, `git ls-tree` and `git diff` against pinned remote refs. Nothing was checked out, installed, tested, run or pushed. This is not a product acceptance, a contract freeze or a full-doctrine conformance claim. Requested routes are not model or effort telemetry.

## 0. Heads read (verified locally; match `RECONCILIATION_2026-09-24T20Z.md`)

| Repo | Ref | Head |
|---|---|---|
| mobile | `main` | `c7641cb3` (UX-03c) |
| extension | `origin/land/s4-r6` | `aa0abd83` (S4 → UX-07-on-S4 `322b749a` → S4-CQ; PR #27 needs owner approval) |
| backend | `origin/integration/importer` | `c7a5fe8d`; contract `docs/contracts/importer-openapi.json` `2.0.0-c1-s1.1` (backend `main` `c23b9d9f` is at `1.4.0`) |
| mobile donor #294 | `origin/agent/builder/roman-importer-ux-p2` | `5cbf0de3`; not an ancestor of main |

Spec inputs: the journey spec, state/edge matrix and contract questions under `ux03-handoff-prep/archive-members/ux-planning/journey/` (J7–J13, B3/B4, E04–E40, CQ-10…18); `DISPATCH_READY_REGISTER.md`; `DEPENDENCY_DAG.md`; `95633079/ux/design-system/{EXTENSION_POPUP_STYLE_SPEC,ACCESSIBILITY_ACCEPTANCE_CHECKLIST}.md`; `roman-donor/ROMAN_DONOR_DISPOSITION.md`; `cf8ff737/ux-doctrine/UX_DOCTRINE_APPLICABILITY.md`.

## 1. Claim check: "extension popup markup for 4 of 5 panels is unbuilt" — REFUTED

The doctrine note (Gap 4) turned the style spec's §1 wording "Not confirmed in this read-only evidence boundary" into "not built". The style spec never inspected the popup. Live source at `land/s4-r6` `aa0abd83`:

| Panel (style spec §1) | Built? | Evidence |
|---|---|---|
| Pairing (`popup/pair.*`) | **YES** | `popup/pair.html` (code form, `#error`) and `popup/pair.js` (redeem, then route to `popup.html`). Also on extension `main` `0111be66`. |
| Readiness checklist | **NO** | No such markup in `popup.html` or `pair.html`. |
| Ready + run | **YES, without Stop** | Start at `popup.html` L265-267, wired in `popup.js` L129-176 (single-flight; `start_import_unconfirmed` on a lost reply). Running vs interrupted at `outcome.js` L8-18 (`workerActive`). Per-family receipts at `popup.js` L96-113 and `outcome.js` L19-74. **No Stop**: the worker has no import-cancel message kind (`background.js` L90-108). |
| Result | **YES**, inside `popup.html` (no separate `popup/result.*`) | `#status`, `#progress-list`, `#outcome-*` at `popup.html` L232-249. Check status and Copy summary at L250-263 and `popup.js` L178-202. Copy in `_locales/en/messages.json` `outcome_*`; boundary doc `docs/TRANSFER_OUTCOME_BOUNDARY.md`. Tests: `transfer-outcome-popup.spec.js` (16), `transfer-outcome-model.spec.js` (8), `popup-start-import.spec.js` (8). |
| Task page / launcher | **NO** | No file in `git ls-tree`; `manifest.json` `action.default_popup` is the only UI surface. |

Correct statement: 3 of 5 panels are built (the run panel lacks Stop). The two unbuilt panels, readiness checklist and task page, both belong to UX-03 (extension). Doctrine Gap 4's "B (proof-scope)" should read C, because pairing, run and result can be checked against real markup.

## 2. UX-04 — Start, Progress & Stop (J7–J9; B3; E04–E08, E26, E28; CQ-10/11/12)

**Spec requires.** Start happens only in the extension; there is no Start on the phone (CQ-10). The phone shows the run view only after the server accepts the run (`accepted_start_at`, `deadline_at`). Phases are discovering, transferring and reconciling, with measured counts per family. Buckets are never summed into "imported", and unknown is "not yet known", never 0. The view shows freshness and a stale state with no spinner; no percent or ETA. Stop is a secondary control with no confirmation step. The phone must tell "sent, not yet confirmed" apart from "offline, not sent", and never queue a Stop (E06). The final state is whatever the server returns (E26).

**Exists.**
- *Extension:* a truthful Start/run view for the current staging-only boundary (§1). Start stays locked until a validated empty status arrives (`popup.js` L77-78). "Bringing records across" shows only while `workerActive`; otherwise "Transfer status needs checking". Receipts show received / new-staged / no-new-row, with pending and unconfirmed kept separate. No phases, no Stop.
- *Mobile main:* no run view. `src/types/extensionImport.ts` L182-205 still has the deferred `ImportFlowState` vocabulary, which the spec says to replace, not build on. `decodeTerminalStatus` (L155-161) turns unrecognised values into `unknown`.
- *Donor #294 (not on main):* `ImportStatusFrame.tsx` (69 lines) and `ImportProgressView.tsx` (57 lines). Props only, with no clock, polling or hook: observation current/stale/unavailable; phases `finding|transferring|checking`; stop notRequested/pending/offline; `receiptCount`, `sourceCoverage`, `observedAt`.
- *Backend:* the extension writes `POST /api/scout/progress` (`scout.controller.ts` L70; extension-estimated counts), `/ingest` and `/ingest/complete` (L90; terminal `success|partial|failed`). `GET /api/scout/import/status?intent_id` exists (L126-133; `scout.service.ts` L327). It returns `running|success|partial|failed`, committed counts per family and `started_at`/`completed_at`. It is coach/owner-scoped, returns 404 for unknown or foreign ids, and sits behind `FEATURE_SCOUT_INGEST`. Its ADR (`2026-07-15-importer-import-status-read.md`) states there is no cancellation. **No client in either repo calls it** (`git grep`).

**Gap.**
- The phone cannot address any run. The extension mints its own run ids (`background.js` L579 `ext-${Date.now()}`, L825 `imp-${Date.now()}`). The pairing setup id (`import_intent_id`) never reaches the extension (`shared/pairing.js` and `shared/session.js` never read it), so the phone has no id to pass to `import/status`.
- The server has no accepted Start, cancel, deadline, phase, per-bucket split (`observed/staged/created_native`), `last_observed_at` or stale threshold.
- Donor gaps: one total `receiptCount` instead of per-family rows (J8); offline-Stop wording lacks "not sent" (E06); no mapping from server enums (a later adapter's job).

**Depends on.**
- Existing: `import/status` (shape, terminals, flag).
- **Blocked on S7-L:** run ↔ pairing-intent binding, accepted Start/cancel/deadline with fencing, and a phase/bucket read contract (CQ-11/12). This is S7 lifecycle work still left after C. S7-C (`c-prep/C_SLICE_BRIEF.md`) is a database key contraction and does **not** deliver it.
- **Blocked on G3-AUTH:** a phone Stop must reach the same server arbiter, with revocation-aware fencing.
- **Blocked on S8/S9:** any meaning for `created_native`.

## 3. UX-05 — Failure, Partial & Recovery (J10 non-complete; X1; B4; E18–E21, E27, E29, E34/35; CQ-17)

**Spec requires.** One headline per outcome: partial, blocked, failed, cancelled, timed out, legacy, unknown. One reason, shown as approved copy from a fixed catalog; raw server or worker text is never coach-facing (CQ-17). One safe recovery action; retry links to the old result and never erases it. Fact, then remedy, then what was kept (A11Y-07).

**Exists.**
- *Extension, run present:* a fixed issue catalog (`outcome.js` L75-91: source auth, invalid receipt, settlement failed, source incomplete, interrupted). The copy says "not verified migration", "do not retry blindly" and "Automatic recovery is not available yet". These results are exactly the spec's **legacy**, extension-minted boundary (CQ-18).
- *Extension, no run:* **the raw `lastError` is shown** (`popup.js` L115-117 sets `errorBox.textContent = snapshot.lastError`). Sources, all on an empty snapshot: `background.js` L147/210 (session replaced); L507 (`"auth_required"`); L565/793 (`unsupported site: <origin>`); L617 (`no extractor for ${platform}` — shows the vendor slug, against X6); L801 (`unsafe import origin`); L809-812 (`no blueprint for ${platform}` / `blueprint resolve failed`).
- *Mobile:* accepted pairing recovery copy (UX-03a/c `PAIRING_REASON_COPY`, `ExtensionPairingPanel.tsx` L280-292). Donor `ImportResultView.tsx` (94 lines) has outcomes unconfirmed, interrupted, failed, timedOut, cancelled, unavailable, transferOnly, `blocked{denied|scopeUnknown|changed|unknown}`, verifiedSubset, complete and provenZero. Input that fails the proof shape falls back to `unavailable`. There is no `legacy` outcome.

**Gap.** The extension's no-run error box can be fixed now, as copy only. On mobile there is no mounted result view, no reason-code read, no `legacy` (E40) and no linked retry (E29).

**Depends on.**
- Existing: final-state read, but only for extension-minted runs (`import/status`).
- **Blocked on S7-L** (plus S9 for reconciliation reasons): a shared reason catalog (CQ-17); blocked/timed-out/cancelled states, which the server cannot represent today; the legacy marker (CQ-18).
- **Blocked on G3-AUTH:** a fence when the source account changes mid-run (E21).

## 4. UX-06 — Imported Results & Native Deep Links (J10 complete, J11, J12, J13; CQ-03/13/14/15/18)

**Spec requires.** "Complete" only with native reconciliation, plus a per-family coverage manifest; a zero is shown only with a stated basis. "Open my clients" and "Review import details" open native records by the coach's owned native ids. Links to anything else show a neutral "not available in this account" (E31). Results stay readable when new starts are off (CQ-03) and after disconnect.

**Exists.**
- *Mobile:* a neutral "Review clients" link to `ClientsStack/ClientsList` (`ExtensionPairingPanel.tsx` L102, L187-226). This is the CQ-14 fallback: unfiltered roster, no count. The `ClientDetail {clientId, clientName}` route is at `CoachNavigator.tsx` L141-143, L304-305. Donor `ImportResultView` has `openClientsAction`/`reviewVerifiedAction`, gated by `validNative` (verified count above 0, relationships/readback verified).
- *Backend:* `GET /scout/reconstruct/entities` and `/roster` both **require** `intent_id`. Roster people are invite-pending rows with an opaque id. `POST /scout/reconstruct` returns staged/reconstructed/skipped/failed.

**Finding U6-1 (C now; A if enabled): the mobile review read no longer matches either backend contract.**
- *Mobile* (`src/api/importReviewApi.ts` L1-43, `src/types/importReview.ts` L21-48) was written against "contract 1.4.0". It sends no `intent_id` and strictly expects `entities[{id,family}]` plus a required `reasons[]`.
- *Backend `main` (1.4.0) and integration (`2.0.0-c1-s1.1`)* require the `intent_id` query parameter. They return `{entities,family,intent_id,next_cursor,page_count}` with no `reasons`, and entities as `{id,entity_type,source_id,source_platform,client_source_id,label,created_at,updated_at}`.
- *Effect:* a real call would get a 400 or fail strict validation.
- *No harm today:* `importReview` is off by default (`featureFlags.ts` L433), and `useReconstructCounts`/`useRosterReviewDelta` have had no non-test caller since UX-03a.
- *Closure:* it blocks only the UX-06 review-alignment slice, which is the fix (after S7-REV). No fixer now.

**Gap.** No owned-native-id result manifest, no provenance filter, no coverage manifest, and no intent the phone can address. Whether `ClientDetail` ids equal roster-person ids is unproven (an S8 question).

**Depends on.**
- **S8:** native writers and owned ids; provenance (CQ-14).
- **S9:** reconciliation and the coverage manifest (CQ-13).
- **S7-REV:** one generated, intent-required review schema; this needs S7-L.
- **G3-AUTH:** disconnect and results after revoke (CQ-15).
- **S7/S12:** a new-starts capability separate from results-readable (CQ-03).

**UX-06 has no build slice that can run now.** The existing neutral link is already the truthful fallback.

## 5. Findings

| Id | Class | Harm | Blocks | Minimum closure |
|---|---|---|---|---|
| D-4 (doctrine Gap 4) | C | Overstated; would steer work toward rebuilding existing panels | Nothing | §1 correction; reuse the existing popup |
| X-1 (raw no-run `lastError`) | C (X6/CQ-17 conformance defect) | Coach sees jargon such as `no extractor for truecoach`; nothing false, no data effect | Nothing | Slice E1 |
| U6-1 (review read drift) | C now; A if `importReview` is enabled | Review screen would error | UX-06 review alignment only | That slice after S7-REV; never enable the flag before it |
| P2-R (#294 never independently closed; its README says "closure pending") | B (adoption proof only) | Graft would rest on self-review | M1 acceptance | One independent T2 review on the exact M1 head |

Not a finding: mobile having no run view is a truthful absence. Mounting the donor views before S7-L would be the defect.

## 6. Slices that can start now (presentation first, path-disjoint, no invented server behavior)

### M1 — mobile UX-04/05: adopt #294's controlled status/result views, unmounted

**Why the graft is clean.**
- `git diff --stat c7641cb3 5cbf0de3 -- src/screens/coach/import-journey` shows exactly 11 paths, +887/−2.
- `importJourneyUI.tsx`, `ImportOfferCard.tsx`, `ImportSetupView.tsx`, `README.md` and `sideEffectGuards.cjs` are byte-identical on both sides.
- The 3 modified files only add to main: `importJourneyCopy.ts` (+37/−1), `en.json` (+83/0), and the P1 copy test (+4/−2, scoped to its 5 original groups).
- The theme pieces used already exist on main (`typography.h1/body/bodyMd/bodySmall`, `semanticColors.bgPrimary/textPrimary/textMuted`, `react-native-safe-area-context`).

**Base.** Mobile `main` `c7641cb3`.

**Owned paths.** The builder is the **only mobile status/result writer**, first in the 04→05→06 sequence (DAG).
- `src/screens/coach/import-journey/{ImportStatusFrame.tsx, ImportProgressView.tsx, ImportResultView.tsx, P2_README.md, importJourneyCopy.ts, i18n/en.json}`
- `__tests__/{ImportStatusViews.test.tsx, ImportStatus.accessibility.test.tsx, ImportStatus.transitions.test.tsx, importStatusCopy.test.ts, importJourneyCopy.test.ts}`
- Excluded: `src/{navigation,api,hooks,storage,types}/**`, `ExtensionPairingPanel.tsx`, `ImportDataScreen.tsx`.

**Behaviour.** Blob-exact graft from `5cbf0de3`. No mount, route, adapter, Stop wiring or new copy. The spec gaps in §2–§3 (per-family rows, E06 "not sent", `legacy`, linked retry) belong to the later binding slice after S7-L, which keeps M1 a straight reuse.

**Tier: T2** (requested Claude Sonnet 5 / High).
- Why T2: coach-facing truth copy inside the existing architecture.
- Nothing triggers T3/T4: no auth, storage, network, contract, persisted data or navigation.
- Promote to T4 on any mount, status-read hook, Stop wiring, navigation parameter or contract consumer (the register's UX-04/05 mobile tier).

**Acceptance.**
- *Scope:* the tree diff from `c7641cb3` is exactly the 11 paths, each blob-equal to `5cbf0de3`.
- *Not mounted:* `rg 'ImportProgressView|ImportResultView|ImportStatusFrame' src --glob '!**/import-journey/**'` finds 0 hits.
- *Imports:* the 3 views import only react, react-native, safe-area, theme, `importJourneyCopy`, `importJourneyUI` and `ImportStatusFrame`.
- *Gates* (heavy slot `execution/test-validation.lock`): `npm run typecheck` and `npm run lint` rc0. Jest passes for `src/screens/coach/import-journey`, `ExtensionPairingPanel*` and `ImportDataScreen*`; the donor suites include the `sideEffectGuards` throw-on-call harness.
- *Accessibility:* A11Y-01/02/04/06/07/10 asserted by the donor a11y suite.
- *Review and commit:* one independent T2 review on the exact head (closes P2-R); Bradley as author and committer (the mobile repo has no hooks).
- *Not claimed:* device, screen-reader or journey behaviour.

### E1 — extension UX-05: approved reason copy on the no-run error path

**Base.** Extension `origin/land/s4-r6` `aa0abd83`. It stacks on PR #27 (owner-reserved, 1 approval) and lands after #27 under the same protection (test, codeql, linear history).

**Owned paths.** The builder is the only extension presentation writer.
- `popup/popup.js`: `render` error branch L115-120 only.
- `popup/outcome.js`: add one pure `preStartIssue(lastError, message)` mapper next to the L78-91 catalog.
- `_locales/en/messages.json`: additive `prestart_*` keys.
- Tests: `test/transfer-outcome-popup.spec.js` or a new `test/popup-prestart-copy.spec.js`.
- Excluded: `popup/*.html` (UX-07's accepted style file), `background.js`, `shared/**`, `content/**`, `manifest.json` (WS1 logic).

**Behaviour.**
- Map the 7 existing no-run `lastError` families (§3) to approved fact + remedy copy: session changed; pairing needed; page can't be imported (origin may be shown); unsafe origin; no reader for this site (no vendor slug); site setup unavailable; unknown, which gets one generic line.
- The raw text never appears in `#error`.
- Use the same prefix-match idiom as `outcome.js` L80-90; structured codes are WS1 work (§8).
- The run path and Start locking are unchanged.

**Tier: T2** (requested Claude Sonnet 5 / High).
- Why T2: truthful coach-facing error copy; no auth, storage, protocol or run-control change.
- Promote to T3 if `background.js`/`shared/protocol.js` must emit codes (a cross-component contract); to T4 if Start, locking or run control changes.

**Acceptance.**
- *New cases:* each family maps to its key; unknown maps to the generic key; `#error.textContent` never contains the raw `lastError` or a platform slug.
- *Existing tests:* the 16 `transfer-outcome-popup` cases and 8 `popup-start-import` cases still pass unchanged.
- *Gates:* full `npm test` passes (baseline 65 files / 1743 tests at `aa0abd83` per the S4-CQ record, plus the new cases); `npm run gates` rc0; remote CI `test` + `codeql` + `secrets-scan` green on a pushed land branch.
- *Review and commit:* one independent T2 review on the exact head; Bradley as author and committer, linear history.
- *Not claimed:* packaged-browser (EXT-PKG) or installed-source behaviour.

**Running both.** M1 and E1 are in different repos with disjoint paths and writers, so they can run in parallel. Both take the heavy slot for their gates, per current practice.

## 7. Queued (one decision or gate away; not now)

- **E2 — extension "Check status" also reads the server (UX-04/05).** Read `GET /api/scout/import/status?intent_id=<own run id>` and show server-committed counts and the settled final state, labelled separately from local receipts.
  - Needs: a parent consumer-freeze of that one path at `2.0.0-c1-s1.1`, proven by fixture-derived tests (G14; the S7-2′ freeze covered only the 5 pairing paths). Also the WS1 logic owner, because it adds a `background.js` fetch.
  - Tier: T3; T4 if it changes Start locking or recovery.
- **M-bind — mobile run/result binding (UX-04→05→06; same writer as M1).** Mounts the M1 views behind `extensionImport`, fed by an intent-scoped status adapter. Adds per-family rows, E06 wording, `legacy` and linked retry.
  - Waits on: **S7-L** (CQ-11/12/17/18) and **G3-AUTH** (Stop/fencing). T4.
- **UX-06 review alignment** (T2, separate writer; closes U6-1): waits on **S7-REV**.
- **UX-06 results and deep links** (T4): waits on **S8 + S9** (owned native ids, CQ-13/14, E31).

## 8. Not now (correctly blocked)

| Work | Blocked on |
|---|---|
| Stop in the extension or on the phone (no worker cancel, no server cancel) | S7-L + G3-AUTH |
| Readiness checklist and J7 Ready card | UX-03 extension (S7-2′, G3-AUTH, EXT-PKG, CQ-08/09) |
| Structured `lastError` codes | WS1, T3 |
| A Start button on the phone | Excluded by CQ-10 |
| "Ready to use" / `created_native` from real data | S8/S9 |
| Enabling `importReview` | S7-REV (U6-1) |

## 9. Outcome

- **Ready now:** **M1** (mobile, T2: verbatim #294 view adoption, unmounted) and **E1** (extension, T2: no-run reason copy). They are path-disjoint and can run in parallel.
- **UX-06:** no build slice can run now; its truthful fallback already exists.
- **Claim "4 of 5 popup panels unbuilt": refuted.** Pairing, run (without Stop) and result are built. The readiness checklist and task page are unbuilt, and both are UX-03 work.
- **Blocked:** mobile UX-04/05/06 server truth waits on **S7-L** (not delivered by S7-C), **G3-AUTH**, **S7-REV**, **S8** and **S9**, as mapped per section above.
- **Bradley decision needed for M1/E1: NO.** E1's landing inherits the existing owner-reserved PR #27 approval.
