# UX-07 extension presentation — T1 source candidate

**Status:** READY for independent targeted T1 review. Not committed, packaged, tested, built, deployed, or published.

## Scope and boundary

- **Repository:** `BradleyGleavePortfolio/tgp-importer-extension`
- **Candidate branch:** `ux07-extension-presentation`
- **Exact base:** `0111be661922234d670bbf23e23d270eec1b4a4e`
- **Base tree:** `4465c42dbb915e67b3c2e0e925f284caa3333468`
- **Task:** bounded UX-07.extension presentation-only slice.
- **Changed paths:** `popup/popup.html`, `popup/pair.html`.
- **Not changed:** all JavaScript, `manifest.json`, `package.json`, protocol, background/service-worker code, configuration, and build tooling.

The source changes are limited to the two existing inline CSS blocks. They retain the existing HTML copy, DOM IDs, `hidden` state behavior, module-script paths, pairing form and controller hooks. No new panels, controls, state branches, vendor-specific treatment, external assets, fonts, CDN links, behavior, protocol, or authentication/trust wiring were introduced.

## Presentation changes

- Replaced the prior dark default styling with compact bone/cream, ink/forest popup tokens and existing-panel single-column reflow.
- Reused the UX-07 design aid’s intended Cormorant/Inter font stacks strictly as local fallback stacks; no packaged Cormorant or Inter asset exists in this revision and no remote font was added. Until an approved packaged asset is supplied in later work, the browser resolves `ui-serif` / `ui-sans-serif` fallbacks.
- Raised the existing Start and Pair controls to a 48px minimum block size; the pairing input is also 48px minimum height.
- Added visible keyboard focus treatment to the existing input and buttons.
- Added `prefers-reduced-motion: reduce` treatment for the CSS-only transitions.
- Preserved all existing state labels and error/status text; status continues to be readable text, not color-only information.
- Kept narrow popup width in rem units with `max-width: 100%`, wrapping long IDs and error text rather than forcing horizontal overflow.

## Exact candidate identifiers

| Path | Candidate blob |
|---|---|
| `popup/popup.html` | `f003a81804d15e5fc34fefbeaab228f371a14a7d` |
| `popup/pair.html` | `fd9ebe2eaac7b4ef7b31f3682a1bf91eebb0212a` |

| Tree | Identifier |
|---|---|
| Candidate index tree (two CSS-only file changes staged in a temporary index, not the worktree index) | `130afa99778327b79cc69a494f085493efc4df95` |
| Unchanged `manifest.json` blob | `035373d20b91c05e7fb8b0d628a5570014a812fc` |
| Unchanged `popup/popup.js` blob | `296e3052001027907b40743c7c615085bff7d686` |
| Unchanged `popup/pair.js` blob | `11c0bcb9e324e86e2677a608c00df833be412d11` |
| Unchanged `package.json` blob | `cf10ffb7c120a2faba0860f8a9adce1cc6a505ef` |

The review patch is `UX07_EXTENSION_T1_SOURCE_DIFF.patch` (8,691 bytes; SHA-256 `94ac2e96aab28747e4ea731cdc86ab3937dcf8d8345986bf0a0f27beb525d8ab`).

## Light static evidence executed

| Check | Result |
|---|---|
| Diff path check | Only `popup/popup.html` and `popup/pair.html` changed. |
| Logic/config diff check | No `.js`, `manifest.json`, or `package.json` change. |
| Controller hook check | Retained popup IDs: `empty`, `detail`, `intent-id`, `platform`, `status`, `progress-list`, `error`, `start-import`; retained pair IDs: `hint`, `pair-form`, `code`, `submit`, `error`. |
| Form/module check | Retained `pair-form`, `popup.js`, and `pair.js` module references. |
| Asset/CSP check | No external HTML script, stylesheet, asset, or font link added; manifest unchanged. |
| Contrast calculation | Ink on bone 14.47:1; muted on bone 5.65:1; white on forest 8.99:1; error on error surface 8.52:1; error on bone 8.91:1; ink on disabled fill 7.85:1; forest on bone 8.18:1. All text pairings used by this slice exceed AA’s 4.5:1 body-text minimum. |

No runtime test, install, build, browser interaction, package validation, preview, deployment, publication, or commit was performed while C1 owns the heavy runtime.

## Targeted validation plan (deferred to parent scheduling)

1. Run `git diff --check 0111be661922234d670bbf23e23d270eec1b4a4e -- popup/popup.html popup/pair.html`.
2. Run existing targeted behavior tests without changing their scope: `npm test -- test/popup-start-import.spec.js test/pair-ui-catch.spec.js`.
3. Run the repository’s existing deterministic static suite when the CPU slot permits: `npm run gates`.
4. After packaged-extension validation is explicitly scheduled, load the exact candidate and review the existing pair and status surfaces at default and 200% browser zoom: visible focus, 44px-plus controls, no clipping/overflow, error/disabled states, and reduced-motion parity. This is a presentation inspection only; it must not be claimed as proof of any future UX-03/04/05 state that does not exist on this base.

## Reviewer focus

- Confirm the source-only diff remains presentation-only and no controller contract was altered.
- Confirm the fallback font position is acceptable until approved packaged Cormorant/Inter assets are made available; adding an asset, font loader, CSP change, or external CDN is explicitly outside this T1 candidate.
- Confirm the existing Start control’s behavior remains governed by the unchanged `popup/popup.js`; this candidate does not endorse or alter its future lifecycle authority.
