# UX-07 token reuse and exclusion list (design-only)

Parent EXEC-95633079. Bounded T2 planning-only, no authority. Requested route Claude Sonnet 5 / High (requested setting, not observed runtime identity). Sole writes `execution/95633079/ux/design-system/**`. Nothing built, branched, installed, run or pushed; no product tree touched. This resumes the outstanding **UX-07.design** row from `resume-evidence/ux-planning/DISPATCH_READY_REGISTER.md` ("UX-07.design tokens exclusion list, a11y checklist, shared test plan, extension popup style spec... **READY-NOW**"). It does not redo `journey/CANONICAL_MOBILE_JOURNEY_SPEC.md`, `STATE_AND_EDGE_CASE_MATRIX.md` or `CONTRACT_QUESTIONS.md`, all of which are read as COMPLETE inputs and cited by section id, never re-authored.

Inputs consulted (read-only, no new inventory beyond what those documents already establish): `OFFICIAL_UX_JOB_AND_PR_MAP.md` UX-07 row; `DEPENDENCY_DAG.md` UX-07 edges and "Parallel lanes" table; `DISPATCH_READY_REGISTER.md` UX-07 rows; `journey/CANONICAL_MOBILE_JOURNEY_SPEC.md` X2/X3/X6 and the mobile-main tokens fact; `journey/STATE_AND_EDGE_CASE_MATRIX.md` E41/E42. `src/theme/tokens.ts` itself is not in this read-only evidence boundary (mobile product repo, not the design-planning tree) and is not fetched here; every claim below cites the journey spec's own pinned observation of it rather than a new inspection, consistent with "consult only existing referenced design source... do not broad-inventory."

## 1. Reuse list (already-approved tokens; UX-07 may only apply, never invent)

| Token family | Approved use | Source of the rule |
|---|---|---|
| `bone`, `cream` | Backgrounds, surfaces, low-emphasis fills | `journey/CANONICAL_MOBILE_JOURNEY_SPEC.md` X3 "Existing bone/cream/ink/forest palette" |
| `ink` | Primary text, primary icon glyphs, focus ring core | same (X3) |
| `forest` | Primary action fill, selected/active state, links | same (X3) |
| `stone` | **Excluded from all text use.** WCAG 2.2 AA requires ≥4.5:1 for normal text and ≥3:1 for large text (≥18pt, or ≥14pt bold); the reported stone-on-bone ratio ≈2.3:1 fails both thresholds, so no text size makes it compliant. Use `ink` on `bone`/`cream` for any text that would otherwise use `stone`; if a muted/secondary tone is wanted, it must come from an existing `ink`/`forest` tint that independently meets the size-appropriate ratio, never from `stone` itself | mobile-main tokens fact: "stone-on-bone ≈2.3:1... fail AA for body text" (journey spec, "Verified starting point" table); WCAG 2.2 AA 1.4.3 thresholds |
| `mutedGold` | **Excluded from all text use**, same reasoning: reported ratio ≈2.9:1 fails both the 4.5:1 (normal) and 3:1 (large-text) AA thresholds regardless of point size. Use `ink`/`forest` alternatives for any text, badge, or caption role | same tokens fact; matrix X2 "stone/mutedGold never as body text"; WCAG 2.2 AA 1.4.3 thresholds |
| Cormorant (headings) | Screen titles, one headline per screen (X3: "single column, one headline + one Roman sentence + one primary CTA") | X3 |
| Inter (body) | All body copy, remedy text, checklist lines, button labels | X3 |
| `RomanAvatar` (existing 48px neutral) | Roman-on variant only; never resized, never a new mascot | X3 "No new brand or mascot"; journey J0/X4 |
| Existing subtle transitions (as shipped) | Screen/state entry only | X3 "subtle existing transitions only" |
| Existing generic Ionicons (source catalog) | Navigation-shortcut icons in J3 only | journey spec J3 "current catalog uses generic Ionicons: acceptable" |

Reuse is mandatory before any new value is proposed: UX-07 adds **zero new color, font, or spacing primitives**. If a surface seems to need something outside this table, the correct move is to flag a CONTRACT_QUESTIONS-style open item to the design-system owner, not to invent a token here.

## 2. Exclusion list (hard "never" for every UX surface, mobile and extension)

| Excluded | Why | Enforcement point |
|---|---|---|
| `stone` or `mutedGold` as text of any kind, at any size, including captions and badges | Governing rule is the AA contrast ratio, not point size: AA requires ≥4.5:1 normal / ≥3:1 large; reported ≈2.3:1 (`stone`) and ≈2.9:1 (`mutedGold`) fail both thresholds, so size never cures it. Use `ink`/`forest` alternatives instead | Visual QA + automated contrast check per surface (see checklist); check the actual rendered ratio against 4.5:1/3:1, not against a size rule |
| Any new brand color, gradient, or accent not in {bone, cream, ink, forest, stone, mutedGold} | X3 "No new brand or mascot"; token minimalism is the standing rule, not a UX-07 addition | Design review before implementation PR |
| Confetti, bouncing Roman, fake typing delay, animated loading ritual | X3 explicit exclusion list | a11y/motion review; reduced-motion snapshot |
| Any source-platform badge, "fully supported" label, or vendor-specific icon/copy branch | X6 "NEW SOURCE → CORE DIFF = 0"; journey J3 CANON | Design review — a per-vendor branch is "a spec violation and must be rejected at review" (X6, verbatim) |
| Percent complete, ETA, or summed counts presented as a single "imported" number | Matrix B3 rows T10/T11; not an accessibility item but a presentation contract UX-07 must not contradict with a "progress ring" style choice | Component-level review of any progress primitive donated from #294 |
| Color-only state signaling (a colored dot/border with no text or glyph) | Matrix X2 "state never by color alone (each status line has text + glyph)" | Accessibility acceptance row A11Y-04 below |
| New mascot, new avatar pose set, or resizing `RomanAvatar` | X3 "No new brand or mascot" | Design review |
| Any animation or transition that cannot be fully suppressed under `prefers-reduced-motion` / OS reduce-motion | X2 "reduced-motion parity"; E42 | A11Y-06 below |
| Any font other than Cormorant (headings) / Inter (body) | X3 | Design review |
| Any layout with sticky actions covering large-text content, keyboard, or the bottom safe area | X3 "sticky actions never cover large text, keyboard content or the bottom safe area" | A11Y-03 below |

## 3. Scope boundary (what this list does not do)

This list assigns no endpoint, flag, analytics event, or storage location; it changes no journey state, no terminal vocabulary, and no matrix row. It is a presentation-token contract for whoever implements `importJourneyUI.tsx` (mobile, UX-07 sole writer per `DEPENDENCY_DAG.md` "Parallel lanes") and the extension `popup/*.html`/CSS (extension presentation writer, UX-07 T1 row). Gate for code-start: `JOURNEY-SPEC` (satisfied, journey files are COMPLETE) plus `ROMAN-DONOR` disposition (pending parent, unchanged by this document) plus an assigned sole writer per `DISPATCH_READY_REGISTER.md`.
