# Grant: compose UX-07 extension presentation onto S4 (T2)

**Parent:** EXEC-CF8FF737. **Time:** 16:50Z.

**Why.** The owner amendment requires landing the accepted UX-07 extension presentation, `6fd7e4a9` (paths `popup/popup.html` and `popup/pair.html`). S4, `91990ae9`, is the other accepted extension slice. The two branches were cut independently from `main` `0111be66`, and `git merge-tree` reports a genuine content conflict in `popup/popup.html`:

- **UX-07** restyles the pre-S4 popup with the Roman token palette.
- **S4** adds new popup structure with the old dark styling: outcome coverage/native/no-receipt, `#outcome-guidance`, `.transfer-family`, `details`/`summary`, `.actions` buttons, `#action-feedback` and `#intent-id`.

S4 is being landed as-is through PR #27.

## Classification

This is a **B finding scoped only to the UX-07 extension landing**. Harm: if the conflict is resolved mechanically, either the accepted Roman presentation is lost, or S4's new elements keep the dark styling, which fails contrast against the bone background. The blocked decision is landing UX-07 on the extension. The minimum closure is this bounded composition. It unlocks that landing.

## Owner

One T2 builder (requested route: Claude Sonnet 5 / High) and one independent T2 reviewer.

- **Worktree:** `/home/user/workspace/worktrees/ext-ux07-on-s4`. Make it a full clone of `/tmp/landing/ext-full`, checked out at `91990ae9` on branch `ux07-on-s4`.
- **No push.** The parent pushes to `land/ux07-on-s4`, where the extension CI runs on every branch push. That CI is the deterministic remote gate.

## Allowed edits

**Where edits may go**

- Only `popup/popup.html` and `popup/pair.html` may change.
- In `popup.html`, edit only the `<style>` block and presentation-only attributes.

**What must stay byte-identical to S4**

- Every S4 element, id, class, `hidden` attribute, `aria-*` attribute, text node and script reference.
- `popup/popup.js`.
- Every other S4 file.

**Commit**

- Make one ordinary merge commit of `6fd7e4a9` into `91990ae9`, resolving only the conflict. Author and committer are both Bradley Gleave <bradley@bradleytgpcoaching.com>. No trailers.
- Alternatively, if the repository enforces linear history, make a single commit on `91990ae9` that applies UX-07's token styling. State which route you used.

## Design direction

Apply UX-07's accepted token system to the new S4 elements. The tokens are `--bone`, `--cream`, `--ink`, `--forest`, `--forest-pressed`, `--muted`, `--line`, `--error`, `--error-surface` and `--focus-ring`, with the Cormorant Garamond heading and Inter body. Follow these sources, in priority order:

1. The accepted UX-07 styling itself, and its acceptance and review records:
   - `/tmp/tgp-private-evidence/execution/95633079/ux/EXTENSION_PRESENTATION_ACCEPTANCE.md`
   - `/tmp/tgp-private-evidence/execution/95633079/ux/extension-review/**`
   - Include the A-01 input-border contrast closure.
2. The project UX rules as applied in `/tmp/tgp-private-evidence/execution/cf8ff737/ux-doctrine/UX_DOCTRINE_APPLICABILITY.md`:
   - **One concept per moment:** one headline, one plain sentence and one primary action.
   - **Error and caution copy** states the fact, the remedy and the retained progress. This composition does not change text, so the rule governs visual weight only: caution must not read as failure.
   - **Hidden complexity:** the technical `#intent-id` and `details` content stay visually secondary.
   - **Mascot:** no mascot, gamification, streak, badge or decorative motion.
3. The Bradley-supplied mobile design doctrine, `/home/user/workspace/uploaded_attachments/f5e929f954f94e4d81f5d5307bf96b75/Mobile-App-Design-Intelligence-Exhaustive-Agent-Training.docx`. Relevant parts:
   - Part VII.2–VII.3: invisible interface, one decision per moment, smart defaults.
   - Part II.2: error states as trust-building.
   - Part III: avoid points, badges and leaderboards.

   It is generic guidance and never overrides 1 or 2.

## Hard accessibility bar

This is the project's own bar.

- **Contrast:** WCAG AA, at least 4.5:1 for body text and at least 3:1 for large text and non-text UI (borders, focus ring) against its actual background. Compute every text/background pair you introduce or recolor and table them.
- **Caution:** `.transfer-family p + p` must not reuse the dark theme's yellow `#fbbf24` on the bone background. Use a token pair that passes and still reads as caution, not error.
- **Targets:** action buttons and `summary` keep a minimum height of 44px, and `:focus-visible` stays visible.
- **Motion:** if any transition exists, it respects `prefers-reduced-motion`.
- **Layout:** no horizontal overflow at a 22.5rem body width. Long ids wrap.

## Gates

These are light and need no heavy slot.

1. Run `npm ci` in the worktree. Stop if less than 3 GiB of disk would remain; the extension's `node_modules` is small.
2. Run `npm test`.
3. Run `npm run gates`.

Record the rc and counts. The first nonzero result stops the run; report it and do not fix outside the grant.

## Deliverables

Write `execution/cf8ff737/ux07-ext-on-s4/SOURCE_READY.md` with:

- the head, tree and parents;
- the exact diff against `91990ae9`, and the resolution hunk for the conflict;
- proof that S4's markup and scripts are unchanged: strip `<style>` and compare, and diff `popup.js` and every other path;
- the contrast table;
- the gate receipts;
- a bundle and a patch.

Then stop for the parent. The parent pushes the branch for CI and dispatches the independent T2 review.
