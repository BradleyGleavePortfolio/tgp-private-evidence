# UX-07 extension popup styling specification (design-only, HTML/CSS presentation)

Parent EXEC-95633079. Bounded T1 planning-only (per `OFFICIAL_UX_JOB_AND_PR_MAP.md`: "Extension T1 (HTML and CSS only; promote if popup logic changes)"), no authority. This spec covers layout and visual presentation only for `popup/*.html` and CSS; it names no logic, message, endpoint, or `background.js`/`shared/protocol.js` behavior, matching the boundary already drawn in the official map ("reads `shared/session.js` and `shared/pairing.js`; never `background.js` or `shared/protocol.js`"). It bases on extension `main` (`0111be66`), not a mobile base, per the same map row.

## 1. Scope: style existing markup only, no new panel shells

Per parent disposition, this spec does **not** author new placeholder panels, contracts, or fake functional controls for surfaces that do not exist yet. It gives styling rules (tokens, type, spacing, motion, focus) that apply **when and if** an implementer styles `popup/*.html` and its CSS, and it inventories the panels named in the official map only as a forward reference table — not as work to perform now.

| Panel (named in the official map) | Consumes state from (read-only, once it exists) | UX outcome it serves | Code-start gate (unchanged by this spec) | Exists in current `popup/*.html`? |
|---|---|---|---|---|
| Pairing panel (`popup/pair.*`) | `shared/pairing.js` | UX-03 (extension) | GATED: must wait on S7-2′, G3-AUTH, EXT-PKG | Not confirmed in this read-only evidence boundary — do not create a placeholder |
| Readiness checklist panel (in `popup/popup.html`) | `shared/session.js` | UX-03 (extension) | GATED: must wait | Not confirmed — do not create a placeholder |
| Ready + run panel (`popup/popup.html` run section, `popup/run.*`) | `shared/progress.js` | UX-04 (extension) | GATED: must wait (S7-L missing) | Not confirmed — do not create a placeholder |
| Result panel (`popup/result.*`) | `shared/progress.js` / status read | UX-05 (extension) | GATED: must wait | Not confirmed — do not create a placeholder |
| Task-page and launcher presentation | n/a (presentation only) | UX-03 (extension) | GATED: must wait | Not confirmed — do not create a placeholder |

None of these five rows authorizes new markup today. If any of this markup already exists in the actual `popup/*.html`/CSS on extension `main` (`0111be66`), an implementer applies §2's tokens/type/motion rules and §3's layout notes to that **actual existing markup**. If a panel does not yet exist, its row stays a forward reference until the surface's own gate (UX-03/04/05 extension, per `DEPENDENCY_DAG.md`) clears and a real implementer builds the real control — this spec does not build a stand-in for it now, and does not claim any control (Start button, Stop button, checklist row) is functional or wired.

## 2. Shared visual language (extends `TOKEN_REUSE_AND_EXCLUSION_LIST.md` to the popup viewport)

- **Tokens**: `bone`/`cream` backgrounds, `ink` text, `forest` primary action. `stone`/`mutedGold` are **excluded from all text use in the popup**, same as mobile — their reported ratios (≈2.3:1, ≈2.9:1) fail AA's ≥4.5:1/≥3:1 thresholds regardless of size, so no caption or badge exception applies. Use `ink`/`forest` alternatives for any secondary or caption text. Token exclusion list §2 applies verbatim inside the extension.
- **Type**: Cormorant for the one panel headline per view; Inter for all body/button/checklist text. Browser extension popups cannot guarantee a fixed viewport width across browsers/zoom levels, so type must be defined in relative units (`rem`/`em`), never fixed `px`, to satisfy 200% zoom (A11Y-03) inside the popup's own render surface (the extension has no OS "large text" setting equivalent; browser zoom is the analog and must be supported).
- **Layout constraint specific to popups**: standard browser action-popup width is narrow (historically ≈320–400 CSS px) and popups cannot scroll the surrounding chrome — only their own content area. Every panel must be single-column, vertically scrollable within its own content region, and must never rely on hover-only affordances (popups have no guaranteed persistent hover state, and are frequently dismissed on outside click/blur — see §4).
- **Motion**: same reduced-motion parity rule as mobile (X2/E42); popup CSS transitions must have a `prefers-reduced-motion: reduce` override that removes motion while preserving the same information.
- **No new tokens, fonts, icons, or brand marks**: identical exclusion list to mobile (§2 of the token document) applies without exception.

## 3. Conditional per-panel styling notes (apply only if and when the corresponding markup exists; do not build ahead of it)

Each note below is styling guidance to apply **to that panel's actual existing markup**, if and when it exists in `popup/*.html`/CSS on extension `main`. None of this section authorizes creating a new panel, a new placeholder DOM node, or a functional-looking control (button, checklist row, code display) that is not backed by real markup and real logic already present or being built under its own gated UX-03/04/05 job. Where a panel is not yet present, its note is deferred guidance for that future implementer, not present-tense work.

### 3.1 Pairing panel (styling notes for if/when `popup/pair.*` exists)
- Single column; one Cormorant headline, one Inter instruction line, one digit-grouped code display, one primary action control, one secondary text link — apply these rules to the existing structure rather than introducing new elements.
- Code display: monospace or tabular-figure numerals so digit grouping is visually stable; digit-level exposure to assistive tech mirrors #292's mobile pattern (reuse the announcement approach, do not invent a new one).
- Expired/retained state styling reuses the same panel shell; no red error-only styling — pair any state change with the glyph+text rule (A11Y-04). Copy strings are the copy owner's responsibility, not fixed here.

### 3.2 Readiness checklist panel (styling notes for if/when it exists in `popup/popup.html`)
- If three status rows exist, each row's state indicator should be glyph + label (not-yet / ready / needs-attention), never color-only.
- Any tappable/expandable row should meet the ≥44 CSS px target and use a focus-visible disclosure pattern, not a hover-only reveal (§2 hover constraint).
- A mismatch state, if present, should be a full-panel treatment rather than a single row, consistent with journey J6/B5's severity.

### 3.3 Ready + run panel (styling notes for if/when it exists)
- If a single Start control exists, style it as the one primary action per the map's rule that Start is extension-owned; this note does not add a Start control where none exists.
- If a running/phase view exists, its phase and freshness text should use disclosure text rather than motion as the primary information carrier, and any Stop control should meet ≥44×44 CSS px and sit early in DOM order after the phase heading (mirrors mobile A11Y-10) — this styles a real control, it does not fabricate one.
- Any indeterminate progress indicator, if present, needs a static reduced-motion equivalent (§2) — a text-only state label instead of a moving bar.

### 3.4 Result panel (styling notes for if/when it exists)
- If terminal-state views exist, each terminal should differ by text + one glyph, never color alone (A11Y-04), and should avoid confetti/success animation (exclusion list) — this styles existing terminal states, it does not define new terminal copy or invent a panel.

### 3.5 Task-page and launcher presentation (styling notes for if/when it exists)
- Full-tab (not popup-constrained) layout may use a wider single-column reading width but keeps the same token/type rules; the launcher itself renders no privileged content and injects nothing (map: "launcher cannot inject privileged messages") — this spec constrains it to a static, styled instructional shell only.

## 4. Popup-specific accessibility notes (extend, do not replace, `ACCESSIBILITY_ACCEPTANCE_CHECKLIST.md`)

- Popups can lose focus/dismiss on outside click; any transient state (e.g., "Copied") must not be the only record of an action — the underlying state (code copied, Stop requested) must still be correctly represented if the popup is reopened, though this spec assigns no persistence mechanism (that is extension logic, out of scope for a T1 CSS-only spec).
- Keyboard traversal inside the popup must start at the panel's heading and proceed top-to-bottom through visible controls only; no keyboard trap.
- Because popup zoom behavior varies by browser, test at both default and 200% browser zoom (test layer 7 in `SHARED_TEST_PLAN.md`) rather than assuming OS-level dynamic type applies.

## 5. What this spec does not do

It does not define `background.js`, `shared/protocol.js`, message formats, storage, or any endpoint; it does not change the sequencing already fixed in `DEPENDENCY_DAG.md` (UX-03 → UX-04 → UX-05 extension presentation, sequential, one writer); it does not promote this T1 item to a higher tier — if implementing these panels requires touching popup **logic** rather than markup/CSS, the map's own rule applies ("promote if popup logic changes") and that promotion decision belongs to whoever implements it, not to this planning packet. Per parent disposition, it also does not create new placeholder panels, contracts, or fake functional controls for surfaces absent from the actual current `popup/*.html`/CSS: an implementer applies §2's shared visual language and §3's conditional notes only to markup that already exists or is being built under its own gated UX-03/04/05 job, never to a stand-in this document invents.
