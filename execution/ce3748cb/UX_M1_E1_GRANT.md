# UX M1 + E1 build grants (T2) — parent EXEC-CE3748CB ~20:55Z

Planning input accepted: `ux-readiness/UX04_06_BRIEF.md`. Prior claim "4 of 5 extension panels unbuilt" REFUTED (C, recorded). Latent risk recorded: mobile `importReview` flag must stay off until the UX-06 review-alignment slice (A, customer-enablement path only; flags dark).

## M1 — mobile UX-04/05 dormant status/result views (T2; T4 the moment anything mounts/binds them)
Sole writer; worktree `/home/user/workspace/worktrees/ux-m1` (branch `ux-m1`) from mobile `main` `c7641cb3`. Donor `5cbf0de3` (PR #294 head; fetch `agent/builder/roman-importer-ux-p2`). Exactly the 11 paths in brief (byte-identical to donor where the brief says so; the three additive files merged minimally). No mount/import outside `src/screens/coach/import-journey/`. Gates: `npm ci` (heavy slot), typecheck, lint, targeted Jest. One ordinary commit, Bradley author+committer, no trailers (mobile has no configured hooks; claim none). No push. Report `execution/ce3748cb/ux-m1/SOURCE_READY.md`.

## E1 — extension UX-05 no-run error copy (T2)
Sole writer; worktree `/home/user/workspace/worktrees/ux-e1` (branch `ux-e1`) from `aa0abd83` (land/s4-r6). Paths: `popup/popup.js`, `popup/outcome.js`, `_locales/**/messages.json` (whichever locale files exist), tests. Seven existing error families → approved fact+remedy copy; one generic line for unknown; no vendor names in user copy. Gates: `npm ci` (heavy slot), full `npm test` (baseline 65 files / 1743), `npm run gates`. One ordinary commit with the repo's genuine hooks if configured, Bradley author+committer, no trailers. No push (parent pushes a CI branch). Report `execution/ce3748cb/ux-e1/SOURCE_READY.md`.

Heavy slot for both: `/home/user/workspace/execution/test-validation.lock` via `flock -n`; if busy, wait and retry; never delete it. Hold it only for install/test runs.
