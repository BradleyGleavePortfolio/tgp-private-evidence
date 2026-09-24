# UX-07 extension presentation — independent targeted T1 source review

**Reviewer disposition:** **MINIMAL A BLOCKER — not SOURCE_GRANTABLE as pinned.**

**Review boundary:** source-only, read-only inspection. No source was edited. No install, test, build, browser, package, runtime, deployment, or publication action was performed.

## Candidate identity inspected

| Item | Pin |
|---|---|
| Repository / branch context | `BradleyGleavePortfolio/tgp-importer-extension` / `ux07-extension-presentation` |
| Base commit | `0111be661922234d670bbf23e23d270eec1b4a4e` |
| Base tree | `4465c42dbb915e67b3c2e0e925f284caa3333468` |
| Candidate tree | `130afa99778327b79cc69a494f085493efc4df95` |
| Candidate `popup/popup.html` blob | `f003a81804d15e5fc34fefbeaab228f371a14a7d` |
| Candidate `popup/pair.html` blob | `fd9ebe2eaac7b4ef7b31f3682a1bf91eebb0212a` |
| Unchanged manifest blob | `035373d20b91c05e7fb8b0d628a5570014a812fc` |
| Unchanged popup controller blob | `296e3052001027907b40743c7c615085bff7d686` |
| Unchanged pairing controller blob | `11c0bcb9e324e86e2677a608c00df833be412d11` |
| Unchanged package blob | `cf10ffb7c120a2faba0860f8a9adce1cc6a505ef` |
| Supplied exact patch SHA-256 | `94ac2e96aab28747e4ea731cdc86ab3937dcf8d8345986bf0a0f27beb525d8ab` |

The supplied patch text exactly equals the unified diff from the stated base to the stated candidate tree. The candidate tree changes only `popup/popup.html` and `popup/pair.html`; `git diff --check` reported no whitespace error.

## A-01 — pairing input boundary misses AA non-text contrast

**Classification:** A — customer accessibility risk.

**Affected source:** candidate `popup/pair.html` blob `fd9ebe2eaac7b4ef7b31f3682a1bf91eebb0212a`, `input { border: 1px solid #8e9d91; background: var(--cream); }`.

**Observed harm:** The pairing code field's only visible control boundary is `#8e9d91` against `#fffdf8`; its measured contrast is **2.80:1**, below the AA 3:1 minimum for the visual boundary needed to identify an enabled input. The cream field fill against the bone page is only 1.08:1, so it does not supply an alternative compliant boundary. A coach with reduced contrast sensitivity can have difficulty locating the sole pairing entry control before focus.

**Blocked decision:** source grant for the candidate tree above.

**Minimum closure:** Change only the existing pairing-input border to a color with at least 3:1 contrast against `--cream`. The smallest no-new-token closure is:

```css
input {
  border: 1px solid var(--muted);
}
```

`--muted` (`#53655b`) is already present in the same candidate CSS and is 5.65:1 against bone (and exceeds 3:1 against cream). An equivalent already-approved/reviewed color is acceptable if its actual input-border/background pairing is measured at >=3:1. Do not alter markup, IDs, form semantics, `hidden` behavior, controllers, manifest, assets, CSP, or protocol.

**Unlock:** Produce a new candidate tree and blobs, then perform this same bounded source re-review against the new pins. The closure needs only the one selector/value correction plus exact-diff, contrast, and source-boundary rechecks; it does not need a new test framework or a browser/package run to close this source finding.

## Verified source boundary (apart from A-01)

- The exact diff is CSS-only in the two declared HTML files: 83 additions / 32 removals in `popup/pair.html` and 94 additions / 27 removals in `popup/popup.html`.
- The non-style markup, DOM IDs, `hidden` attributes, existing form/input/button semantics, visible copy, and module-script references are byte-identical before and after the style blocks. Existing controller dependencies remain `empty`, `detail`, `intent-id`, `platform`, `status`, `progress-list`, `error`, `start-import`, `hint`, `pair-form`, `code`, and `submit`.
- The unchanged controllers retain authority over status/error visibility, pairing submission disable/re-enable, and Start Import disable/re-enable. No CSS selector overrides `[hidden]`, `visibility`, `opacity`, `pointer-events`, or disabled-state semantics.
- No JavaScript, manifest, package, protocol, CSP, external resource, font loader, CDN link, asset, or controller hook changed. The Cormorant/Inter declarations are local font-stack preferences with `ui-serif`/`ui-sans-serif` fallbacks; they do not add a packaged or remote font.
- Existing controls have `min-height: 3rem` (48 CSS px at the default root size). The candidate supplies keyboard-only `:focus-visible` outlines; the focus ring measures 9.18:1 against bone and 9.92:1 against cream. Long status/error text has wrapping treatment and popup width is capped at `max-width: 100%`.
- Text-pair calculations meet the stated body-text AA bar: ink/bone 14.47:1; muted/bone 5.65:1; white/forest 8.99:1; error/error-surface 8.52:1; error/bone 8.91:1; ink/disabled fill 7.85:1; forest/bone 8.18:1. Existing text/error copy is unchanged, so this review makes no new error-copy claim.

## C records — qualify and continue; no new loop

1. The advisory design aid says not to introduce new tokens, while the candidate creates several local CSS custom-property aliases and supporting presentation colors. That aid is explicitly advisory for this review, and the aliases do not broaden behavior, resource loading, CSP, or state authority. Record as C only; do not create a token-redesign loop.
2. Default and 200% rendered reflow, focus traversal, popup dimensions, and native progress rendering require the already-planned packaged-extension visual inspection. They were not executed here because C1 owns the heavy slot. This is not a source-only proof claim and does not justify new tooling or a second review loop.

## Targeted validation assessment after A-01 is closed

The proposed plan reuses suitable existing coverage and does not need a new test system:

1. Re-run `git diff --check` against the exact base and replacement candidate tree, and confirm the changed-path/immutable-blob pins.
2. Statically calculate the corrected input-border/background ratio and recheck the source boundary above.
3. When the existing C1 slot is available, run the already-present behavior tests exactly as proposed: `npm test -- test/popup-start-import.spec.js test/pair-ui-catch.spec.js`. They guard the unchanged Start and pairing controller hooks, but do not themselves prove CSS contrast or zoom layout.
4. When normally scheduled, run the repository's existing `npm run gates`; it is an existing deterministic suite, not a requested framework addition.
5. Only after packaged-extension validation is scheduled, inspect the replacement candidate at default and 200% browser zoom for visible focus, >=44 px effective targets, clipping/overflow, disabled/error rendering, and reduced-motion parity.

No test or runtime result is asserted by this report. No acceptance, merge eligibility, package validity, deployment readiness, or customer readiness is claimed.
