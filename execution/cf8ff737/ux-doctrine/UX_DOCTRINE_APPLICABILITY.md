# UX doctrine applicability — TGP importer UI/UX vs. "Mobile App Design Intelligence"

**T2 read-only assessment. Canonical reviewer: this agent. Disposition: parent.**
Scope: `execution/cf8ff737/ux-doctrine/**` only. No product edits, no new runtime/test/screenshot harness, no code touched. Evidence reused as-is. J3 r5 remains a frozen TEST-ONLY blob and is not reopened. B and peer code reviews were not read, per instruction. This is a narrow comparison of the attachment's literal content against current accepted importer UX evidence — not a full line-by-line mapping of every doctrine sentence, and not a blanket conformance claim.

## What the attachment actually is

The attached doctrine (`Mobile-App-Design-Intelligence-Exhaustive-Agent-Training.docx`, 2,543 lines) is a generic consumer-app emotional-engagement manual built from four case studies (Duolingo, Phantom, Revolut, Strava) plus general sections on cognitive load, gamification risk, and "invisible interface" design. **It contains no importer-specific guidance, and it never mentions WCAG, specific contrast ratios, or 44×44pt touch targets.** Those are project-specific requirements that live in this project's own journey spec/matrix (X2), not in the attachment. Where the mapping below cites a project requirement stricter than anything the attachment states, that is flagged explicitly rather than presented as attachment-derived.

## Current built/accepted state (not a plan)

Per `LAST_OPERATOR_STATE.md` and the presentation acceptance records, presentation is **built and accepted**, not merely specified:
- Mobile: commit `df0ad112529afcd9bfdf084e9930c90ee0bfffb3` (11 PR293 presentation/copy/test files + one Settings label), independent T2 review SOURCE_GRANTABLE → ACCEPTED (A0/B0); `tsc --noEmit` raw0, adopted Jest raw0, 4 suites/69 tests (`MOBILE_PRESENTATION_ACCEPTANCE.md`).
- Extension: commit `6fd7e4a95ec2bc400cb8bec62a95955280a31f12`, changed paths `popup/popup.html` and `popup/pair.html` only, independent T1 review ACCEPTED (A0/B0); one input-border contrast defect (A-01) was found and closed at R2 (`EXTENSION_PRESENTATION_ACCEPTANCE.md`).

The `design-system/*.md` planning packet's older hedged language ("not confirmed to exist... do not create a placeholder") describes an earlier planning-time state and is **not** the current built-state description; it is superseded by the two acceptance records above for the paths those commits actually touch (`popup.html`, `pair.html`, the 11 PR293 mobile files). This does not mean every panel named in that packet's forward-reference table is now built — only that the specific accepted commits are real, locally built/reviewed/accepted presentation, not deployment or customer acceptance, and not hypothetical.

---

## Selected alignment (attachment content vs. current accepted evidence)

This is a selective mapping of the attachment passages actually checked against evidence, not an exhaustive pass over the full document.

| Attachment content (literal) | Current accepted importer evidence | Note |
|---|---|---|
| Pt. VII.3, "One concept per moment... present exactly one decision at a time" | Journey spec pattern cited by the design packet: "single column, one headline + one Roman sentence + one primary CTA" (X3) | Attachment states the general principle; the one-headline/one-CTA structure is the project's own stronger, more specific implementation of it. |
| Pt. VII.2, "Smart defaults everywhere... every pre-filled field is work the app did so the user did not have to" | Token/design packet reuses existing defaults (e.g. Roman-on/off parity, existing session state) rather than asking re-entry | Directionally consistent; not verified against a specific pre-fill implementation in this pass. |
| Pt. II.2, "Treat error states as trust-building opportunities... 'Something went wrong' destroys trust" | Accessibility checklist rule `A11Y-07`: error/negative text states fact, remedy, retained progress, in that order, no blame tone | The attachment states the general trust principle in prose; the fact→remedy→retained-progress *sequencing rule* and the "no raw internal error as primary line" rule are project-specific, not stated in the attachment. |
| Pt. VII.2, "Hide the work... implementation details, state management, error handling... none of it should be visible to the user" | Extension acceptance record: no JS/DOM/state/protocol change was part of the accepted presentation commit — presentation stayed inside its own boundary | Consistent in direction; this is a scope-boundary observation, not a direct test of "hidden complexity." |
| Pt. VI.2 Master Checklist item, "Character/mascot state is triggered by user-generated events, not timers" (conditional on having a mascot) | Design packet: `RomanAvatar` frozen at "existing 48px neutral... never resized, never a new mascot" | The attachment's mascot guidance is conditional ("if your product has or can have a mascot") — it does not mandate adding or growing one. The project's choice not to expand the mascot is a scope decision this attachment does not override. |
| Pt. III (PBL Fallacy, S-curve) — points/badges/leaderboards are "the most thoroughly documented failures," risk of cognitive overload past 3–4 mechanics | No streaks, points, badges, or leaderboards in current importer design/acceptance evidence | The attachment itself argues against defaulting to these mechanics; their absence is consistent with the attachment's own caution, not a gap against it. |

**Not claimed:** WCAG AA thresholds, 44×44pt targets, and the specific `stone`/`mutedGold` contrast-ratio exclusions in the current design packet and acceptance records are real, and the extension acceptance record shows a real contrast defect (A-01) found and fixed — but none of that is presented here as compliance *with the attachment*, because the attachment does not state those thresholds. They are this project's own, independently stronger accessibility bar.

---

## Confirmed gaps / non-adoptions, with consequence

- **No mascot emotional-state expansion, no gamification mechanics (streaks/points/badges/leaderboards).** This is a deliberate scope boundary already recorded in the design packet (X3 "No new brand or mascot") and consistent with the attachment's own PBL-fallacy caution, not an overlooked gap. **Consequence: C** — record, no fixer/audit needed.
- **No 3D/tactile "premium object" animation** (the attachment's Revolut example) on any importer progress surface. The design packet separately excludes presenting percent-complete/ETA/summed counts as a single number (matrix B3), which forecloses that style of decorative treatment regardless of the attachment. **Consequence: C.**

No A-class (real product/customer/data/security) consequence was identified in this comparison.

---

## Unverified claims (flagged as unverified — not treated as invalidating any existing acceptance)

- Attachment §6.2 Master Checklist items — "the emotional target for this interaction is explicitly defined," "every confirmation moment has a dedicated micro-interaction," and "new user test: primary path navigable in under 3 minutes without instruction" — are **not verified in this comparison**. No evidence reviewed in this pass confirms or denies whether an explicit emotional target was defined per screen, whether importer confirmation moments have a dedicated micro-interaction, or whether the primary path has been tested unassisted under 3 minutes. This gap matters for honesty about scope: the alignment claims above are limited to the specific passages checked, not full §6.2 conformance.
- This assessment did not re-run or re-measure the contrast figures, tests, or hook results cited in `MOBILE_PRESENTATION_ACCEPTANCE.md` / `EXTENSION_PRESENTATION_ACCEPTANCE.md`; they are reused as accepted evidence, consistent with instructions not to reopen accepted unchanged evidence.
- No screenshot or rendered device view was produced or inspected in this pass, so any claim about how the accepted commits actually *look* (versus what their acceptance records state) is unverified here. This is a documentation gap in this review's own coverage, not a claim that the accepted work is deficient.
- The attachment's own case-study business metrics (Duolingo DAU, Phantom App Store rank, Strava Kudos volume) are third-party claims from the source document, not independently re-verified here, and are not load-bearing for anything in this mapping.
- Whether every panel named in the design packet's forward-reference table (beyond `popup.html`/`pair.html`) currently has real markup is not verified in this pass; only the two accepted commits' actual changed paths were checked.

---

## Answer to Bradley's question

Against the specific attachment passages checked in this pass, current accepted importer presentation (mobile `df0ad112...`, extension `6fd7e4a9...`) is **directionally consistent** with the attachment's general-purpose guidance on decision-per-moment simplicity, trust-building error copy, hidden complexity, and mascot restraint — and it does not adopt the attachment's gamification/tactile-motion techniques, which is consistent with the attachment's own stated caution about those techniques rather than a deviation from it. This is not a claim that every sentence of the attachment was checked or that the importer conforms to the attachment in full; it is a selected mapping over the passages compared. Separately, and not because the attachment requires it, the project carries its own stronger accessibility bar (WCAG-level contrast math, 44pt targets, reduced-motion parity) that the attachment never states.
