# N1 independent T1 review — 2026-09-27

Scope: [N1 grant](./N1_GRANT.md), [north star](./NORTH_STAR.md); reviewed [extension PR #33](https://github.com/BradleyGleavePortfolio/tgp-importer-extension/pull/33) at `1087d2a4934b8cfddfc82ff706952766c6a6f071` against `a889f4ad`, and [mobile PR #299](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/299) at `303857220769c6244b6860470bf06740de935aef` against `01dd8a3c`. Backend PR #573 is **pending a corrected head and has not been reviewed here**. Nothing was pushed or committed.

## Verdicts

| PR | Verdict | Closure |
| --- | --- | --- |
| Extension #33 | **NO-GO** | B1 below: remove the nonwording implementation-format change to `extractors/_interface.js`; resolve the explicit no-extension-runtime-files restriction with the owner before landing its necessary comment neutralization. Re-run guard and CI at the resulting head. |
| Mobile #299 | **GO** | No blocking finding at reviewed head. |
| Backend #573 | Pending | Wait for corrected head; review separately. |

## Findings

**B1 — Extension runtime file changed beyond wording scope.** [PR #33's diff](https://github.com/BradleyGleavePortfolio/tgp-importer-extension/pull/33/files) changes `extractors/_interface.js`: besides neutralizing the vendor-name comment, it reformats the executable `makeEntity` return body (8 deletions and 8 additions overall). The function's behavior is unchanged, but the grant expressly says **“Do NOT touch extension runtime files; the T4 slice owns them.”** Minimum closure: revert the `makeEntity` formatting, leaving no executable-body diff. The remaining comment change is required for the current guard to pass yet is in a runtime file; obtain an explicit grant interpretation/exception (comment-only wording) or defer this file to T4 and agree on a narrowly scoped interim exception before GO. Do not merely allowlist all `extractors/**`.

**C1 — Extension README layout is imprecise.** [PR #33's diff](https://github.com/BradleyGleavePortfolio/tgp-importer-extension/pull/33/files) replaces real file names with `legacy oracle modules/`, which is not a literal directory in the tree. Optional closure: describe the retained layout accurately without competitor names. This does not independently block landing.

No class-A finding identified in the two reviewed heads. Mobile's `LogScreen.tsx`, `api.ts`, `mapFoodItem.ts`, and `types.ts` edits are vendor-wording comments only, with no executable or product-behavior change. Mobile also contains the N0 north-star documentation merge in the PR comparison against `01dd8a3c`; the N1-specific diff against `81132f4` is guard/CI/wording only ([PR #299 files](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/299/files)).

## Guard verification

- Worktrees: `/home/user/workspace/worktrees/rev-n1-extension` and `/home/user/workspace/worktrees/rev-n1-mobile`. Both `npm run guard:vendors` commands exited **0** at their clean reviewed heads. Worktrees were clean again after temporary probes.
- Both scripts enumerate the whole tracked index via `git ls-files -z`, read every listed file, use a global case-insensitive regexp containing all twelve required spellings (including both spaced alternatives), apply anchored path globs, report each entry's hit count, exit 1 for an unallowlisted hit, and exit 1 for any zero-hit entry. The globs are scoped to test/fixture directories or exact files and historical documents; none is a catch-all for core paths. Neither script has a changed-files-only filter. This is a tracked-file gate, as specified; new untracked working-tree files are not in its domain.
- **Actual failure probes:** in each worktree I temporarily inserted `TrueCoach` into a tracked core file (`extractors/_interface.js` and `src/services/api.ts`, respectively). Each guard printed `1 prohibited name hit(s) outside the allowlist` at that exact path and exited **1**. Both edits were reverted without commit/push.
- **Ratchet probe:** temporarily moving `.gitleaks.toml` to `.gitleaksXtoml` in extension, and `src/constants/importPlatforms.ts` to `src/constants/importPlatformsXts` in mobile, made their exact-file entries report zero hits and exit **1**; the moves were reversed. This also demonstrated that a similarly spelled core path does not overmatch the exact allowlist glob.
- Both main CI workflows run `npm run guard:vendors` after `npm ci` as a plain `run` step with no `continue-on-error` or permissive shell wrapper; exit 1 fails the job. [Extension CI](https://github.com/BradleyGleavePortfolio/tgp-importer-extension/blob/1087d2a4934b8cfddfc82ff706952766c6a6f071/.github/workflows/ci.yml) and [mobile CI](https://github.com/BradleyGleavePortfolio/growth-project-mobile/blob/303857220769c6244b6860470bf06740de935aef/.github/workflows/ci.yml) were green at the reviewed heads ([extension checks](https://github.com/BradleyGleavePortfolio/tgp-importer-extension/actions/runs/36352084087), [mobile checks](https://github.com/BradleyGleavePortfolio/growth-project-mobile/actions/runs/36352081857)).

## Allowlist audit

Each listed entry has a nonzero observed hit count; counts are name occurrences, not matching-file counts. No unused or broad core-path exception was found. Reasons correspond to test evidence, historical records, legacy oracle/origin authorization, or mobile source-picker data. All extension runtime exceptions carry the exact grant retirement label `L-slice origin authorization (T4)`. Other V1/historical/neutral-entry retirement descriptions are consistent with their respective uses.

**Extension** ([configuration](https://github.com/BradleyGleavePortfolio/tgp-importer-extension/blob/1087d2a4934b8cfddfc82ff706952766c6a6f071/.vendor-name-guard.json)): `.vendor-name-guard.json` 2; `test/**` 249; `docs/AUTO_DISCOVERY.md` 21; `docs/DECISION_V03_AUTONOMOUS_CRAWL.md` 14; `docs/DESIGN.md` 22; `docs/PACKAGE_PROOF.md` 1; `docs/REAL_GOAL_EXECUTION_PLAN.md` 8; `docs/ROADMAP.md` 53; `docs/SECRETS_SCANNING.md` 1; `docs/TIER0_CONTRACT_INTEGRITY.md` 2; `docs/first-principles.md` 3; `extractors/truecoach/**` 26; `extractors/truecoach.js` 10; `extractors/detect.js` 16; `manifest.json` 4; `background.js` 5; `shared/capture-policy.js` 3; `shared/protocol.js` 2; `shared/replay/resolve.js` 4; `scripts/browser-load-proof.mjs` 1; `_locales/en/messages.json` 1; `.gitleaks.toml` 1.

**Mobile** ([configuration](https://github.com/BradleyGleavePortfolio/growth-project-mobile/blob/303857220769c6244b6860470bf06740de935aef/.vendor-name-guard.json)): `docs/importer/NORTH_STAR.md` 3; `src/**/__tests__/**` 275; `src/**/__fixtures__/**` 11; `src/constants/importPlatforms.ts` 11.
