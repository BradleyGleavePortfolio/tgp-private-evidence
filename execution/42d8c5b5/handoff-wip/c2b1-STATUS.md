# c2b1 handoff STATUS
- Repo: BradleyGleavePortfolio/tgp-importer-extension. Base: main a889f4ade0e13d9f45aabd69c5878ff07e2038bf.
- PR #32 (open, LANDING HOLD, do not merge) is on branch `c2b-1-endpoint-roles-r2` at reviewed head cb614babb3ad2351778f977e2d42019080bcd039. CI was green there.
- WIP pushed to NEW branch `c2b-1-endpoint-roles-r2-wip`, head **607c93e508d59bdd758c413987b480d8c9f94ba7** (one commit on top of cb614ba, pushed without force). Author is Bradley Gleave; no AI co-author.
## DONE and verified
- The 10 wrong test expectations are fixed; the review confirmed them. B2 (origin validation) and B3 (uninspected shapes) are closed per the round-3 delta review.
- The round-4 B1 positive-evidence rule is in 607c93e (roles.js `provenTemplate` replaces `structuralTemplate`):
  - A template is proven only if its joined observations show at least 2 distinct decoded values at one `:id` position.
  - Otherwise `endpoint.template` is null in every candidate and refusal, with `replayCompatible:false` and reason `unproven_template_literal`.
  - The contact-literal guard (`safeTemplateLiteral`) is kept, because a proven template can still hold a phone-like literal.
- Regressions:
  - Single normalized alice, jane-doe and 101 `/clients/<x>/workouts` GETs are literal-free and non-replayable.
  - Two distinct ids at C2a `minDistinct:2` give a replayable `/clients/:id/workouts` and `/v2/clients/:id/workouts`. At C2a's default of 3 the pair fails closed.
  - Repeated ids and encoded repeats stay unproven, and refusals of unproven clusters withhold the template.
  - The 7 negative B1 cases fail against cb614ba.
- Local results: the role suite passed 99/99. lint, type-check, the check-* scripts, scoped format and the pre-commit hooks passed.
- Full `npm test` gave 1950/1958. All 8 failures were 5000ms timeouts in policy-gates/policy-alignment under machine load. The log is in workspace `c2b1_r4_npmtest.log`. These files are untouched by the diff.
- Prod diff against main: roles.js +397, url-templates.js +1 (the `export { safeOrigin }` line).
## NOT done
- CI has not run on 607c93e. There is no PR for the -wip branch, and #32 does not yet include this commit.
- c2b1/BUILD.md has no round-4 section. Round 3 is committed locally only (evidence commit 7675e04).
## Open review findings
- B1 round-4 closure is unreviewed. Earlier existing tests were changed to the new rule, so the reviewer should check them:
  - lone `/clients` lists now expect template null and non-replayable;
  - the join, determinism and replay-seam tests now use proven `:id` fixtures.
## Exact next step
1. Push 607c93e to the PR branch (fast-forward, no force): `git push origin 607c93e:c2b-1-endpoint-roles-r2`, or open a PR from -wip that supersedes #32.
2. Run `gh pr checks 32 --watch` until green.
3. Add the round-4 section to BUILD.md.
4. Request the B1 delta review on the new head.
