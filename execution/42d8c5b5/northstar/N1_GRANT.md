# N1 GRANT: vendor-name guard (a CI ratchet) + neutral language
Grade: **T1**. It is bounded: CI tooling plus comment/DTO-example wording, with no product logic. Builder: gpt_5_6_terra. Review: gpt_6_sol.
The rule comes from NORTH_STAR.md: no competitor names in core code, and only a shrinking allowlist may contain them.

Repos and bases:
- growth-project-backend: base integration/importer 9668af6c.
- tgp-importer-extension: base main a889f4ad.
- growth-project-mobile: base main 01dd8a3c.

For each repo, open a new branch `ci/vendor-name-guard` and make one PR. Author Bradley Gleave <bradley@bradleytgpcoaching.com>, no AI co-author.
Push with a single non-force push.

1. `scripts/vendor-name-guard.mjs` (node, no dependencies):
   - Scan tracked files (`git ls-files`) case-insensitively for: truecoach, trainerize, everfit, mypthub, "my pt hub", ptdistinction,
     "pt distinction", coachrx, trainheroic, fitsw, teambuildr, kabata.
   - Allowlist: `.vendor-name-guard.json`, entries `{glob, reason, retire}`.
   - Fail (exit 1) on any hit outside the allowlist.
   - ALSO fail on any allowlist entry that matches zero hits. That is the ratchet: stale entries must be removed.
   - Print the counts per entry.
2. Add a CI step in the repo's existing main workflow, following the conventions already in each repo. Also add an npm script `guard:vendors`.
3. Allowlist, kept minimal:
   - Tests and fixtures.
   - Historical docs: docs/decisions/**, docs/ROADMAP.md and the like, which carry SUPERSEDED banners in N0.
   - Backend: `src/scout/reconstruct/sources/truecoach.json` (legacy oracle, retire at V1).
   - Mobile: `src/constants/importPlatforms.ts` (the source-picker shortcuts, as data).
   - Extension, each with retire: "L-slice origin authorization (T4)":
     - extractors/truecoach/** and extractors/truecoach.js, extractors/detect.js (legacy oracle, retire at V1).
     - manifest.json, background.js, shared/capture-policy.js, shared/protocol.js, shared/replay/resolve.js, scripts/browser-load-proof.mjs,
       _locales/en/messages.json, and the gitleaks config.
4. Neutralise wording outside the allowlist:
   - Backend: the three code comments in src/scout/reconstruct/*.ts, plus the swagger `example: 'truecoach'` values and the
     "(truecoach, trainerize, mypthub, …)" description in src/extension-pair/extension-pair.dto.ts and src/scout/*.dto.ts. Use the neutral slug `example-site`.
     Keep every test and contract snapshot green. If a snapshot pins the example, update it in the same commit and name it in the report.
   - Do NOT touch extension runtime files; the T4 slice owns them.
5. Run the guard plus the repo's unit tests and lint locally. No Postgres lanes are needed; the backend changes are comments and swagger examples only.
   Watch CI to green.
DO NOT MERGE. The parent lands after review.
Report: 3 PR numbers, heads, CI conclusion, the allowlist per repo with counts. Write BUILD at execution/42d8c5b5/northstar/N1_BUILD.md (commit locally in the evidence repo; do not push it).
