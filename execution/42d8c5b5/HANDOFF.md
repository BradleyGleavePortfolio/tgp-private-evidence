# HANDOFF — EXEC-42D8C5B5 (TGP importer)

Owner: Bradley Gleave. Written 2026-09-27 ~22:20Z (15:20 PDT). The owner instruction is "finish in-route work only, no new subagents, clean handoff".
This file is updated as the in-flight lanes settle. The end state is recorded in the **FINAL STATE** section at the bottom.

## 0. Read first
1. North star, the only one: `execution/42d8c5b5/northstar/NORTH_STAR.md`. It is also published in each repo: agent-context `/NORTH_STAR.md`, extension `docs/NORTH_STAR.md`,
   backend `docs/importer/NORTH_STAR.md`, mobile `docs/importer/NORTH_STAR.md`. It covers:
   - the universal self-learning importer: any site, Start once, AI decodes, learns and remembers, then imports and reports the truth;
   - the Roman journey as the coach UX;
   - retirement of the TrueCoach framing, with the legacy extractor and truecoach.json kept only as quarantined oracles until V1 parity;
   - the AI step: a live, contract-derived prompt, injection defence, hard usage limits, and the best model with an eval gate.
2. Governance: T0–T4 grading before any work, with routing T0 luna, T1 terra, T2 sonnet, T3 opus, T4 fable. Reviews use gpt_6_sol, and T4 adds claude_opus_5_5.
   T4 needs two independent final-head attestations. Commits are authored by Bradley Gleave <bradley@bradleytgpcoaching.com>, with no AI co-author.
   **There is NO 400-LOC cap.** Over ~1,000 prod LOC → one structural challenge.
3. `WORKER_RULES.md`: never kill processes by pattern; only single non-force pushes; never force-push reviewed refs.
   The extension repo disallows merge commits (use squash or rebase); backend and mobile allow merges.
4. Reserved to the owner: production deploy, prod flags, promoting integration/importer → main, destructive prod changes, live source-account
   operations, Chrome Web Store publishing, new spend, and resolving the Q1–Q5 policy questions.

## 1. Live refs at handoff start
| Repo | Ref | SHA |
|---|---|---|
| backend | integration/importer | 987cba29 (9668af6c + #572 docs) |
| backend | main | 1c10e2a1 (prod has NOT received integration) |
| extension | main | 63873237 |
| mobile | main | 3f91d58a |
| agent-context | main | 6ea55c75 |

## 2. Landed this session
- **backend integration/importer**, a fast-forward 54be96f1 → 419a756d:
  - S11-D/E #565, S8-D1 #569, S12-B2 #570 and S12-B1 #571.
  - Proof on the exact head: S11 133/133 and S10-B 42/42, both local and on GH lanes.
  - Then #566 (S8-D decision doc) → 9668af6c, and #572 (north star) → 987cba29.
- **North star N0:** agent-context #36, extension #31, backend #572, mobile #298.
- **Vendor guard N1 mobile:** #299.
- **Extension main protection:** required approvals 1 → 0. This was owner-authorized; the `test` and `codeql` checks and enforce_admins are kept.

## 3. Proof infrastructure (authoritative)
- **GitHub proof lanes:** harness `proof/harness` at **0c97a84f1ca833bacdd7c20c2cfabf20430504a9** (review GO). The launcher head 875aee68 only sets the default HARNESS_SHA.
  - Trigger, from worktrees/ghlanes-harness: `PROOF_REMOTE=preserve proof/trigger.sh <new-label> <sha40> EXPECT_TOTAL_s11=N EXPECT_TOTAL_s10b=N EXPECT_guard=95`
  - Accept: `execution/42d8c5b5/proof/gh-accept.sh <run_id> <sha40> <same pins>` (sha256 4da457af…, review GO). **ACCEPT = proof.**
  - Re-run the whole workflow, never only failed jobs. A full run takes about 14 min.
  - Current pins on integration: s11=133, s10b=42, guard=95.
- **Local fallback:** proof/lane-s11.sh and proof/lane-s10b.sh.

## 4. In-flight lanes at handoff start
The open repo items are backend #573/#574, extension #32/#34/#35 and mobile #300. The other lanes have no PR yet.

| Lane | Grade | PR / branch | State at 22:20Z |
|---|---|---|---|
| N1 vendor guard, backend | T1 | backend #573 @141c07b5 | Fixes done, CI green, final delta review running |
| N1 vendor guard, extension | T1 | extension #34 @0724f8ff (replaces the closed #33) | Fixes done, CI green, final delta review running |
| X1 origin authorization | T4 | extension #35 @7ac1fe9a | Review A NO-GO (3 A + 2 B). The builder is fixing and rebasing onto main. Review B running |
| C2b-1 endpoint roles | T3 | extension #32 @cb614bab | B2/B3 closed. B1 is being fixed with the positive-evidence rule (≥2 distinct-id observations prove a literal is structural) |
| R1 Roman status binding | T2 | mobile #300 @86144f34 | Review NO-GO. Being rebuilt to reuse ImportRunVerdictCard content inside the Roman frame, with a rendered parity test |
| L0 learn-and-remember design | T4 | backend branch cand/x42/learn-doc (doc only) | Writing. Must include X1/R1 as inputs, the AI-step requirements, the vendor-lock removal and V1 plus the deletion slice |
| S8-D2 imported people on roster | T4 | cand/x42/s8d2 | Building |
| S12-B4 pilot runbook / SQL pack | T2 | cand/x42/s12b4 | Building |
| S12-B5 prod RLS check script (never run on prod) | T2 | cand/x42/s12b5 | Building |
| S12-B6 flag workflow (reconstruct + pilot allowlist) | T2 | cand/x42/s12b6 | Building |
| S11-DE commit 3 (historical rls-g2 v3 cursor tests) | T2 | backend #574 @2bd2d85d | PARKED. It is in no proof lane, and Q07 needs a two-head PG run. B-class hygiene only |

## 5. Known items left alone (no authority to act)
- **Extension #30** (a draft whose head a889f4ad is already on main) should be closed. The classifier blocked closing it because it was not created this session. The owner can close it.
- **Secrets:** the backend history contains a committed `.env` with the prod Supabase service_role key and the DB password. The owner accepted the risk; re-privatise the repo after prod. Do not raise it again.
- **Off-path PRs:** old drafts #525–529, #522, #491, #427/428 and the dependabot PRs are off the importer path and untouched.

## 6. Next state transitions, for the next operator
1. Land every lane whose final review is GO. For extension, land with --squash or --rebase. Backend changes that touch PG need a GH-lane proof with ACCEPT first.
2. X1: after the fixes, run a delta review by both reviewers on the final head; land; then shrink the extension vendor-guard allowlist to legacy/** plus tests.
3. L0 → two reviews → land the doc → execute its slice plan. The expected chain is:
   1. C2b rest / C2c on the extension;
   2. C3, the one-process Start;
   3. the backend AI mapping step (T4, with the adversarial corpus and eval harness);
   4. the learned-memory store and runtime registry;
   5. the V1 real never-hand-mapped platform proof;
   6. the legacy TrueCoach deletion at parity.
4. The pilot needs owner decisions, collected on one sheet:
   - platform access, i.e. authority over the live source account;
   - the AI provider/key and the daily spend cap;
   - integration → main, deploy, and prod flags.
