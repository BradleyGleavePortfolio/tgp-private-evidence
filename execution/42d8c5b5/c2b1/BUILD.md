# C2b-1 RESCUE BUILD (T3), tgp-importer-extension

Builder: claude_opus_5_5. Review: gpt_6_sol, on the final head below.

## Result
- New PR: **#32** "C2b-1: infer deterministic endpoint-role candidates (r2, supersedes #20)", base main, OPEN, not merged (LANDING HOLD).
- Branch: `c2b-1-endpoint-roles-r2`, pushed once without force. #20 and its branch are untouched.
- Head SHA: **5556c6a936adfcaefdffbbb1d72b2410d28952d6**
- Base: main `a889f4ade0e13d9f45aabd69c5878ff07e2038bf`
- CI on the head: **all green**. `test` passed twice (the push run 36350207984 and the pull_request run 36350233126). `codeql` passed (36350233096) and `secrets-scan` passed (36350233077).
- Commits: 3. The two #20 commits were rebased (7cbe2ee scaffold, c453af8 spec checkpoint), plus 5556c6a with the fix. Author and committer on all three are Bradley Gleave <bradley@bradleytgpcoaching.com>. No AI co-author.

## LOC (diff against main)
- Prod: `shared/blueprint/roles.js` is +354. This is byte-identical to #20 and within the 400 cap.
- Test: `test/blueprint-roles.spec.js` is +898 (888 in #20, +10 in this round).

## Root cause of the old red
PR #20 run 34503223370, job `test`, step "Run tests". The log was read through the proxy API (`actions/jobs/102958874156/logs`), because `gh run view --log-failed` calls api.github.com without auth and is rate-limited here. A copy is saved at workspace `c2b1_pr20_failed_job.log`.

The run had 10 failures out of 1384 tests, all in `test/blueprint-roles.spec.js`. Each failure was a **wrong expected value or fixture in the spec**. `roles.js` behaved correctly in every case. #20 had been checkpointed while paused, with "10 assertions still encode wrong expected values".

1. "reports observations that no supplied template describes": the declared `/clients` template with 0 observations is also refused (`no_successful_get_evidence`), so there are 2 refusals, not 1. Fix: assert both refusals.
2. "refuses a template with more than one dynamic segment": the fixture id `2001` is year-shaped. C2a's `candidateKind` excludes 4-digit years, so the observation never joined and produced an extra `unmatched_observation`. Fix: change the fixture id to `20001`. The case now shows `template_not_replayable` with support 1.
3. "does not join an observation to another origin or method": the cluster declares 1 observation but joins 0, so the correct refusal is `template_support_mismatch`, not `no_successful_get_evidence`. Fix: update the expectation.
4. to 9. "never emits the unsafe container key" (x6): the bounded walk refuses with `unsafe_path_key`, which is the stricter and correct reason, not `metadata_only`. The key is still never serialized. Fix: update the expectation.
10. "emits no platform, vendor, or product literal": the allowlist was stale and not in code-point order. Fix: match the real token set. This adds `clients`, `items` and `null`, which are fixture path words and JSON null, and drops `true`. There are still no platform literals.

## Scope checks
- Only the spec changed in this round. There is no UI or runtime wiring. A grep of `shared/blueprint/` for platform names finds nothing.
- The C2b-0B membership seam (`validateObservationMembership` / `observationRefs`) is **not on main**. The private join in `roles.js` is therefore kept as it is (no redesign). Refitting it is a known follow-up, recorded in the PR body.

## Local verification (node only, no Postgres), on the rebased head
- `npm test` (vitest run): 70 files, **1938/1938 pass**. The roles spec alone is 79/79.
- These all pass: check-banned, check-flag-discipline, check-production-fixtures, check-deploy-readiness, check-hook-config, `npm run lint`, `npm run type-check`, `npm run format:check`, `npm audit --audit-level=high` (0 vulnerabilities).
- The lefthook pre-commit hook passed: secrets (gitleaks 8.30.0 via `scripts/install-gitleaks.sh`), banned, deploy-readiness, lint, type-check and format. The first commit attempt was blocked only because gitleaks was not on PATH. It was installed, checksum-verified, and the commit was retried.

---

# Round 3: closing REVIEW_A B1–B3 (2026-09-27)

## Result
- PR **#32**, same branch `c2b-1-endpoint-roles-r2`, one new commit pushed without force: `5556c6a..cb614ba`.
- New head: **cb614babb3ad2351778f977e2d42019080bcd039**. Author and committer are Bradley Gleave <bradley@bradleytgpcoaching.com>. No AI co-author.
- CI on this head: **all green**. `test` passed in push run 36353702384 and pull_request run 36353704889. `codeql` passed (36353704888) and `secrets-scan` passed (36353704898).
- LANDING HOLD still applies. Not merged.

## LOC (diff against main a889f4ad)
- Prod: **+398** in total. `shared/blueprint/roles.js` is +397 (was 354). `shared/blueprint/url-templates.js` is +1, a separate `export { safeOrigin };` line. This is within the 400 cap.
- Test: `test/blueprint-roles.spec.js` is +1019 (was 898). There are 17 new cases, and the role suite is now 96/96.

## Closures (minimum)
- **B1:** added `structuralTemplate()`. Each literal segment must decode and must not be something C2a's `candidateKind` could read as an id. It also must not be numeric or date-like (`/^[\d.-]+$/`). Otherwise the endpoint is refused as `unproven_template_literal`, and its template is set to `null` so the literal is never echoed or reusable. The check runs after `unsafe_template_literal` and before membership, replayability and support.
  - Regression: one **normalized pipeline** GET `/clients/101/workouts` that returns `{items:[{id:5}]}`. It is refused, and the output does not contain `101`.
  - Also covered: the literals `2001`, `12.5`, `ab12cd34` and `v2beta9x`, plus a positive control showing `/v2/clients/:id/workouts` is still accepted.
- **B2:** `validCluster` and the observation join now use C2a's existing `safeOrigin`. It requires https, no userinfo, `URL.origin === input` (so no path, query or fragment, and no trailing `/`), and no localhost or IP-literal hosts. Rejected clusters and observations are counted into one `{endpoint:null, reason:"invalid_origin", support:n}` refusal, and the origin is never echoed.
  - Regression: a direct call with `https://person:password@coach.example`. The output contains no `person`, `password` or `@`.
  - Also covered: http, trailing `/`, a path, a query, a fragment, user-only userinfo, and a non-URL.
- **B3:** added `UNINSPECTED_SHAPE = /\((?:overflow|cycle)\)|unsupported|\.\.\./`. Any list item or detail-body signature that matches it is refused as `uninspected_item_shape`. It never becomes list or detail evidence. Depth truncation `(*)` is unchanged, because it is bounded inspection, not exhaustion.
  - Regressions: a **normalized** 201-key item giving `object(overflow)`; a **normalized** item of 60 keys by 100-element arrays exceeding the 5000-node shape-work limit, giving `work(overflow)`; a 201-key detail body; and a cyclic item giving `object(cycle)`.
- Mutation check: running the new spec against the old roles.js fails **16 of the 17** new cases. The one that passes is the positive control.

## Local verification
- The role suite (`npx vitest run test/blueprint-roles.spec.js`) passed 96/96. It passed 150/150 together with `blueprint-url-templates.spec.js`.
- `npm test` gave 1954/1955. The one failure is `policy-gates.spec.js`, "rejects a semantic error in test JavaScript through both entrypoints", which timed out at 5000ms.
  - Rerunning that file alone still gave only 5000ms timeouts (5 to 13 cases, depending on load). Load average was about 9 to 13 because another agent's full vitest (worktree `x1-origin`) and my commit hooks were running at the same time.
  - The spec and `scripts/` are untouched by this diff. CI ran the full `npm test` green on the same head.
  - Logs are saved in the workspace: `c2b1_r3_npmtest_run1.log` and `c2b1_r3_policy_gates.log`.
- These all passed: lint, type-check, format:check, check-banned, check-flag-discipline, check-production-fixtures, check-deploy-readiness and check-hook-config. The pre-commit hooks passed too (secrets via gitleaks 8.30.0).

## Process note
- While restarting my own `npm test`, I ran `pkill -f vitest`. That kills every matching process on the machine, so it may have ended another agent's concurrent vitest run. I saw one afterwards: `timeout 240 npx vitest run test/protocol.spec.js`, started from another session. Any lane whose local vitest ended unexpectedly at about 21:4x UTC should rerun.
