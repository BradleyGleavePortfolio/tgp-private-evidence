# R1 Roman status binding — HANDOFF STATUS

Repo: growth-project-mobile. Base: `main@01dd8a3c`.
Reviewed branch (NO-GO): `r1/roman-status-binding`, head `86144f34dd833889038d1d5c86ccd0993930b181`, PR #300 (open, unmerged).
**New WIP branch (unreviewed): `r1/roman-status-binding-wip`, pushed head `41812117b44ccbcf0f2acaa340f01029c6480310`.**

## DONE and verified (local, this WIP commit)
- Extracted card's pure copy (`VERDICT_COPY`, `LEGACY_NOTE`, `UNKNOWN_VERDICT`, `PHASE_COPY`, `REASON_COPY`, `verdictLines`, new `staleNote`) into shared `src/components/coach/importVerdictContent.ts`. `ImportRunVerdictCard.tsx` re-exports unchanged; its own 57-test suite passes untouched.
- Exported `ImportedRosterSection` from the card for reuse (fixes review B5).
- Rewrote `ImportRunStatusJourney.tsx`: running state keeps `ImportProgressView` (+ wired existing `run.refresh` as `checkResultAction`); every other state (loading/error/notFound/unreadable/terminal/unknown) renders the card's exact `verdictLines`/`staleNote` text inside the Roman `ImportStatusFrame` shell, with a "Check again" refresh action and the gated `ImportedRosterSection`.
- Removed now-dead `importRunStatusAdapter.ts`+test; reverted `ImportResultView.tsx`'s unused `serverVerdict` addition.
- New `ImportRunStatusJourney.parity.test.tsx`: renders card + Roman surface under identical mocked hook state across status × stale × mode × all 9 reason codes + completedAt + refresh + roster-on. **50/50 passing.**
- Rewrote `ImportRunStatusJourney.test.tsx` for new rendering. **9/9 passing.** `tsc --noEmit` clean.

## NOT done
- Full targeted-suite rerun (`ExtensionPairingPanel.*.test.tsx`, `import-journey/__tests__/*`) not re-run after this change — risk of regression in adjacent files is UNVERIFIED.
- `ExtensionPairingPanel.verdict.test.tsx` still stubs the journey module by mock; likely fine but unverified against latest component signature.
- No eslint run on new/changed files this pass.
- LOC tally not recomputed (note: parent said the 400-cap rule was retired — not a blocker).
- Not pushed as a PR; no CI run on this WIP branch.
- `R1_BUILD.md` not updated for this WIP state.

## Open review findings (from R1_REVIEW.md, addressed in this WIP but UNVERIFIED end-to-end)
A1 stale terminals unlabelled, A2 reason remapping asserted wrong cause, B3 parity test didn't render/compare text, B4 legacy exception too broad, B5 roster section lost. This WIP's approach: reuse card's `verdictLines`/`staleNote` verbatim instead of re-deriving, per parent's "simplify, reuse the card" instruction.

## Exact next step for a new operator
1. `cd /home/user/workspace/worktrees/r1-roman && git fetch && git checkout r1/roman-status-binding-wip`.
2. Run full targeted suites: `ExtensionPairingPanel.*.test.tsx`, `import-journey/__tests__/*`, plus the two files above, then `npx eslint` on changed files.
3. Fix any regressions found (most likely spot: `ExtensionPairingPanel.verdict.test.tsx` mock shape vs new component).
4. If green: merge/rebase this WIP onto `r1/roman-status-binding` (or force-push-free fast-forward if possible) OR open a fresh PR from `r1/roman-status-binding-wip` against `main`, superseding PR #300.
5. Update `R1_BUILD.md`, watch CI green, report head SHA + status→view table per the original grant's final-reply format.
