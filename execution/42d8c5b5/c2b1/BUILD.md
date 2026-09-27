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
