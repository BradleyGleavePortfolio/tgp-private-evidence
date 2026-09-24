# UX-07.design packet — handoff index

Parent EXEC-95633079. Resumes the outstanding `UX-07.design tokens exclusion list, a11y checklist, shared test plan, extension popup style spec` row from `resume-evidence/ux-planning/DISPATCH_READY_REGISTER.md` (state **READY-NOW**, tier T2 planning-only). Requested route Claude Sonnet 5 / High (requested setting, not a runtime identity claim). Sole writes `execution/95633079/ux/design-system/**`. This packet adds zero new journey states, zero backend contracts/endpoints/flags/analytics, and zero code; it does not start a new fixer/audit/control cycle (SafetyROI C-class rule) and is a design proposal, not new authoritative governance. `resume-evidence/ux-planning/journey/**` (the frozen journey spec, matrix, and contract questions) is unmodified by this packet and by the clarification below.

## Parent clarification applied (additive only, this revision)

Parent disposition confirmed this packet is an **implementation aid**, not a new acceptance/control layer, and requested four minimal additive clarifications, now reflected in the packet: (1) actual AA contrast remains governing — ≥4.5:1 body / ≥3:1 large text; the reported ≈2.3:1 (`stone`) and ≈2.9:1 (`mutedGold`) fail both thresholds and are **not** made acceptable by font size, so both tokens are now excluded from all text use (not just body text) with `ink`/`forest` named as the compliant alternative (`TOKEN_REUSE_AND_EXCLUSION_LIST.md` §1–§2, mirrored in `ACCESSIBILITY_ACCEPTANCE_CHECKLIST.md` A11Y-08 and `EXTENSION_POPUP_STYLE_SPEC.md` §2); (2) `SHARED_TEST_PLAN.md` reframed — its eight check types apply selectively, per changed surface, through existing test infrastructure (mobile Jest/RTL, existing contrast/lint step), not as eight mandatory new test systems; (3) `EXTENSION_POPUP_STYLE_SPEC.md` reframed — it styles only actual existing extension markup when and if an implementer touches it, and no longer proposes new placeholder panels, contracts, or fake functional controls for surfaces not confirmed to exist; (4) no journey/matrix/questions file was or is altered by this packet or this clarification.

## Packet contents

| File | Answers |
|---|---|
| `TOKEN_REUSE_AND_EXCLUSION_LIST.md` | Which existing tokens/fonts UX-07 may reuse, and the hard exclusion list (no new brand color, no vendor badges, no motion rituals, no color-only state) |
| `ACCESSIBILITY_ACCEPTANCE_CHECKLIST.md` | Per-surface pass/fail acceptance rows (44pt targets, AA contrast, 200% text, reduced motion, non-color states, honest-unknown counts, offline-Stop copy) |
| `SHARED_TEST_PLAN.md` | How mobile and extension implementers prove the checklist rows with one shared method, without a second writer conflict |
| `EXTENSION_POPUP_STYLE_SPEC.md` | Layout/CSS spec for the five extension popup panels (pairing, readiness, ready+run, result, task-page/launcher), T1, HTML/CSS only |

## Ownership handoff (so mobile and extension implementation can consume without conflict)

- **Mobile UX-07 sole writer** (`importJourneyUI.tsx`, shared with UX-02 per `DEPENDENCY_DAG.md` "Parallel lanes"): consumes the token list, the mobile-tagged rows of the acceptance checklist (A11Y-01/02/03/04/05/06/07/08/09/10 plus A11Y-11–15/18–19–20 mobile half), and test layers 1–6 + 8 (mobile half) of the shared test plan.
- **Extension presentation writer** (`popup/*.html`/CSS, sequential UX-03→UX-04→UX-05→UX-07 CSS per the same table): consumes the token list, the extension-tagged acceptance rows (A11Y-16/17 plus the shared universal rows), test layers 1, 4, 7, 8 (extension half), and the full `EXTENSION_POPUP_STYLE_SPEC.md`.
- Neither writer's file set overlaps (`DEPENDENCY_DAG.md` "Serialization points" already excludes cross-writes between `importJourneyUI.tsx` and `popup/*.html`); this packet introduces no new shared-file writer and does not change either writer's assignment.

## Code-start gates (unchanged by this packet)

Per `DISPATCH_READY_REGISTER.md`: mobile UX-07 code-start needs `JOURNEY-SPEC` (satisfied — journey files are COMPLETE) and `ROMAN-DONOR` disposition (pending parent, outside this packet's scope) plus the assigned sole writer; extension UX-07 code-start needs `JOURNEY-SPEC` plus the WS6 writer-split honored, with `S6-BASE` not applicable to the extension PR. This packet satisfies the design-only obligation named in the map's "Start now versus wait" section; it does not clear either ROMAN-DONOR or writer assignment, both of which remain parent-level dispositions.

## Concrete next implementation slice

The next concrete, unblocked step is: **parent disposes ROMAN-DONOR (#293/#294) and assigns the two sole writers named above**; once assigned, the mobile writer can immediately start `importJourneyUI.tsx` primitives against this packet's token list and acceptance rows (no S7 contract needed, per `DEPENDENCY_DAG.md`'s "Earliest codeable without any S7 contract" list), and the extension writer can immediately start the five popup panel shells against `EXTENSION_POPUP_STYLE_SPEC.md` (no mobile base, extension `main` `0111be66` only). Neither step requires any further design-planning cycle from this packet.

## Manifest

See `MANIFEST.sha256` in this directory for file hashes of this packet.
