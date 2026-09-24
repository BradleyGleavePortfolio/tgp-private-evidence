# UX-07 accessibility acceptance checklist (design-only)

Parent EXEC-95633079. Bounded T2 planning-only, no authority. Companion to `TOKEN_REUSE_AND_EXCLUSION_LIST.md`, `SHARED_TEST_PLAN.md`, `EXTENSION_POPUP_STYLE_SPEC.md`. Sole writes `execution/95633079/ux/design-system/**`. This is a per-surface acceptance list, not a new governance gate: it operationalizes X2 (Accessibility, WCAG 2.2 AA) and E41/E42 from `journey/STATE_AND_EDGE_CASE_MATRIX.md`, and the a11y line already written into every J-screen of `journey/CANONICAL_MOBILE_JOURNEY_SPEC.md`. No row here invents a new requirement; each row cites the canonical line it operationalizes.

## How to use this list

Each row is a **pass/fail acceptance criterion** an implementer (mobile UX-07 sole writer for `importJourneyUI.tsx`, or the extension presentation writer for `popup/*.html`/CSS) checks off per surface as that surface lands, exactly as `DEPENDENCY_DAG.md` describes UX-07's edge into "every visible UX PR" as **soft (incremental)**: "a11y suite runs on each surface as it lands; UX-07 does not block code-start of UX-02." This checklist does not block any other UX PR's code-start; it is what that PR's own author checks before calling a surface done.

## A. Universal acceptance rows (apply to every screen/state in both apps)

| ID | Criterion | Canonical source | Applies to |
|---|---|---|---|
| A11Y-01 | Every interactive control (button, link, checklist row acting as a button, code-copy control) has a touch target ≥44×44pt, including padding | matrix X2 "44×44pt targets"; #292 donor precedent | mobile, extension |
| A11Y-02 | Visible focus indicator on every focusable element; tab/traversal order matches visual/logical reading order; focus lands on the screen's heading or primary control on screen entry where the spec names one (e.g., J0 "focus lands on the question when the card appears") | matrix X2 "visible focus and logical traversal"; journey J0 a11y line | mobile, extension |
| A11Y-03 | Layout remains fully usable at 200% text scale / OS large-text setting with no clipped text, no overlapping controls, and no sticky action covering enlarged text, the keyboard, or the bottom safe area; the one documented exception is the pairing digit display, capped at 1.6× under the #292 precedent because a clipped digit is a functional failure | matrix X2 "dynamic type to 200% without clipping (the #292 1.6× cap applies to the pairing code only...)"; journey X3 sticky-action rule | mobile, extension |
| A11Y-04 | No state is signaled by color alone; every status line pairs text with a glyph/icon (e.g., checklist ✓ / not-yet / needs-attention) | matrix X2 "state never by color alone (each status line has text + glyph)" | mobile, extension |
| A11Y-05 | Screen-reader announcements are polite and deduplicated; phase/state changes announce once, not on every tick (counts do not re-announce each update) | matrix X2 "polite deduplicated announcements"; journey J8 a11y line "counts not announced on every tick" | mobile |
| A11Y-06 | Under reduced-motion (OS setting or `prefers-reduced-motion`), every surface renders with static equivalents carrying the same information — no animated loading ritual, spinner-as-only-signal, or transition-dependent state cue | matrix E42; journey X3 "no ... animated loading rituals" | mobile, extension |
| A11Y-07 | Error/negative-state text states the fact, the remedy, and any retained progress in that order; no blame tone, no raw internal error text as the primary line (correlation id, if shown, lives only inside an expandable "details" region) | matrix X2 "error text states fact, remedy, retained progress"; journey X3 "correlation id shown only inside 'details'" | mobile, extension |
| A11Y-08 | `stone`/`mutedGold` tokens never used for any text (body, caption, or badge) at any size; the governing check is the actual rendered ratio against AA (≥4.5:1 normal, ≥3:1 large) via `ink`/`forest` alternatives, per the token exclusion list | `TOKEN_REUSE_AND_EXCLUSION_LIST.md` §2; matrix X2 "stone/mutedGold never as body text"; WCAG 2.2 AA 1.4.3 | mobile, extension |
| A11Y-09 | Roman-off variant exists for every Roman-on surface: identical layout and information, no portrait, plain functional wording; chat-generation-unavailable never blocks the flow (static approved copy substitutes) | journey X4; matrix E36/E37 | mobile |
| A11Y-10 | Every surface with a "Stop" or cancel control makes it reachable early in traversal (first reachable control after the heading, per J8) and operable by screen reader without sighted guidance | journey J8 a11y line; matrix "Stop discoverable without instruction and operable by screen reader (PLAN scenario 19)" | mobile |

## B. Surface-specific acceptance rows

| ID | Surface | Criterion | Canonical source |
|---|---|---|---|
| A11Y-11 | J0 offer card (mobile) | Card is one accessible group with a heading and exactly three buttons (Yes / Starting fresh / Later), each ≥44pt; no auto-dismiss; announced once | journey J0 a11y line |
| A11Y-12 | J5 pairing code (mobile) | Code is announced digit-by-digit; a real (non-simulated) clipboard copy result is reported to the user and to assistive tech | journey J5; #292 donor a11y test |
| A11Y-13 | J6 readiness checklist (mobile) | Each of the three lines exposes its state (not-yet / ready / needs attention) as text+glyph, not color; "needs attention" lines expose the remedy text to assistive tech, not just visually | matrix B2 `paired`/`awaiting_source_auth` rows; A11Y-04 |
| A11Y-14 | J8 progress mirror (mobile) | Phase line and freshness line are separately announced (polite, once per change); per-family rows with "not yet known" are exposed as text, not an empty/silent row | journey J8; matrix B3 |
| A11Y-15 | J10 terminal result (mobile) | Terminal headline is the first content announced on screen entry; recovery action(s) are reachable immediately after it; no terminal is conveyed by icon/color change alone | matrix B4; A11Y-04 |
| A11Y-16 | Extension popup — Ready/readiness checklist | Same three-state text+glyph rule as A11Y-13 applies inside the popup's fixed small viewport; no reliance on hover-only affordances (popup has no guaranteed hover) | `EXTENSION_POPUP_STYLE_SPEC.md` §readiness; matrix B2 |
| A11Y-17 | Extension popup — running/result panel | Stop control ≥44×44 CSS px within the popup's constrained width; focus order top-to-bottom matches visual order; reduced-motion equivalent for any progress indicator | `EXTENSION_POPUP_STYLE_SPEC.md` §run/result; A11Y-01, A11Y-06 |
| A11Y-18 | Any surface rendering an unrecognized/`unknown` value | Renders "I do not have a confirmed result yet" (or the setup-equivalent) as real text, never a blank, spinner-only, or silently-zero state | matrix E34, E35; journey "Mobile decode rule" |
| A11Y-19 | Any surface with an "honest unknown" count (`observed_unique`/`staged_unique`/etc. not yet available) | Renders the literal absence as text ("not yet known" / "not yet available in this version"), never `0`, never a blank cell, never inferred | journey J8/J11; matrix E22/E23/E33; this is the "honest unknown counts" invariant named in this task's own scope |
| A11Y-20 | Any surface reachable while the phone/extension is offline | Renders the offline-specific truthful copy already specified (e.g., J9's "not sent" vs "sent, ack unknown" distinction) rather than a generic error or a false "stopped" claim | journey J9; matrix B3 Stop rows; this is the "offline-Stop" invariant named in this task's own scope |

## C. Non-goals of this checklist

This checklist certifies **presentation and interaction accessibility**. It does not certify: backend contract correctness, endpoint existence, analytics event shape, or terminal-state truthfulness at the data layer — those remain owned by the journey spec, the matrix, and the eventual S7/S8/S9 contract owners. A surface can pass every row here and still be blocked from acceptance by its own gate in `journey/CANONICAL_MOBILE_JOURNEY_SPEC.md`'s "Screen-to-gate readiness map."
