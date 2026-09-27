# N0 GRANT: publish the single north star (docs only)
Grade: **T0**. It is docs only: no runtime behaviour, contracts, data or privilege, and it is mechanically reversible. Builder: gpt_5_6_luna. The parent verifies the diffs.
Canonical text: execution/42d8c5b5/northstar/NORTH_STAR.md (the parent's words). Copy it byte for byte, and do not edit it.

For each repo, make ONE commit on a new branch `docs/north-star`, push with a single non-force push, and open a PR. Author Bradley Gleave <bradley@bradleytgpcoaching.com>, no AI co-author.
1. **tgp-agent-context** (base main):
   - Add `NORTH_STAR.md` at the root.
   - Put a first line in README.md and AGENT_RULES.md: `> Importer work: NORTH_STAR.md is the only importer north star. It supersedes every earlier importer plan.`
   - Prepend this banner to every importer-direction doc under handoffs/, roadmap/, planning/, audit_briefs/ and DECISION_LOG.md that
     frames the importer as TrueCoach-first, platform-matrix or per-platform: `> SUPERSEDED (2026-09-27) by /NORTH_STAR.md. Historical record, do not follow.`
     Find them with `git grep -il truecoach`, then include only the importer ones.
2. **tgp-importer-extension** (base main):
   - Add `docs/NORTH_STAR.md`.
   - Rewrite README.md line 3 so it frames the extension as the browser-side half of the universal importer (any coaching site, see docs/NORTH_STAR.md).
     Label the extractors/truecoach tree in the README layout "quarantined legacy oracle (deleted at V1 parity)".
   - Put the same SUPERSEDED banner on docs/ROADMAP.md, docs/DESIGN.md, docs/AUTO_DISCOVERY.md, docs/REAL_GOAL_EXECUTION_PLAN.md,
     docs/first-principles.md and docs/export-recipes/*.
3. **growth-project-backend** (base integration/importer):
   - Add `docs/importer/NORTH_STAR.md`.
   - Put a one-line pointer at the top of docs/decisions/2026-09-26-s10-induction.md and docs/decisions/2026-09-26-s11-journey.md:
     `> Importer north star: docs/importer/NORTH_STAR.md.` No other edits.
4. **growth-project-mobile** (base main):
   - Add `docs/importer/NORTH_STAR.md`.
   - Put the pointer line at the top of docs/importer/MOBILE_IMPORT_DECISION.md and src/screens/coach/import-journey/README.md.
Banners and pointers only. Never delete or rewrite historical content. Do not touch code, tests or package files.
Report: the four PR numbers and heads, plus the list of files that got banners. Write BUILD in execution/42d8c5b5/northstar/N0_BUILD.md (commit locally in the evidence repo; do not push it).
