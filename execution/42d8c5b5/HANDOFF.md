# HANDOFF — EXEC-42D8C5B5 (TGP importer) — FINAL

Written 2026-09-27 ~22:45Z (15:45 PDT) by the outgoing operator.
**Assume no agent, worktree, sandbox file or local process survives.** Only GitHub exists: the four product repos, plus this evidence repo
(`BradleyGleavePortfolio/tgp-private-evidence`, path `execution/42d8c5b5/`). Everything below points to a GitHub ref or to a file in this repo.
Anything "in progress" is **in the air**: a pushed WIP branch or a patch, not running work.

## 0. Rules you inherit
- **North star, the only one:** `execution/42d8c5b5/northstar/NORTH_STAR.md`. Published copies: agent-context `/NORTH_STAR.md`,
  extension `docs/NORTH_STAR.md`, backend `docs/importer/NORTH_STAR.md`, mobile `docs/importer/NORTH_STAR.md`.
  The evidence copy is newest: it adds the owner's AI-step requirements, i.e. a live contract-derived prompt, injection defence, usage limits and the best model with an eval gate.
- **Grading and routing:**
  - Grade T0–T4 before any work. Builders: T0 gpt_5_6_luna, T1 gpt_5_6_terra, T2 claude_sonnet_5_0, T3 claude_opus_5_5, T4 claude_fable_5.
  - Reviews: gpt_6_sol, plus claude_opus_5_5 as the second T4 lens. T4 needs two independent attestations on the final head; delta reviews are allowed.
- **Size:** there is NO 400-LOC cap; that rule was retired. Over ~1,000 hand-written prod LOC → one structural challenge.
- **Identity:** commits are authored by Bradley Gleave <bradley@bradleytgpcoaching.com>, with no AI co-author. The owner does not care which identity lands merges.
- **Git hygiene:**
  - Only single non-force pushes. Never force-push a reviewed ref, and never bypass hooks (`--no-verify` is blocked).
  - Never kill processes by pattern.
  - Extension repo: squash or rebase merges only. Backend and mobile allow merge commits.
- **Reserved to the owner (Bradley):**
  - production deploy, prod flags, and promoting backend integration/importer → main;
  - destructive prod changes and live source-account operations;
  - Chrome Web Store publishing and new spend;
  - the Q1–Q5 policy answers, and closing PRs this operator did not create.
- **Accepted risk, do not re-raise:** the backend git history holds a committed `.env` (the prod Supabase service_role key and the DB password). The owner will re-privatise the repos after prod.

## 1. DONE (on GitHub, accepted)
| Repo / ref | SHA | Contents |
|---|---|---|
| backend `integration/importer` | `d84cb7c36cd73168b25594f5312504098a92f555` | S11-D/E #565, S8-D1 #569, S12-B2 #570, S12-B1 #571 (proof: S11 133/133, S10-B 42/42), S8-D doc #566, north star #572, vendor guard #573 |
| backend `main` | `1c10e2a1` | Unchanged. **Prod has not received integration.** |
| extension `main` | `30e78a293069340f2b2baad6b36ea3c9bb454f92` | north star #31, vendor guard #34 |
| mobile `main` | `3f91d58ac4bb887d286ee5898d84bd32eb0bb102` | north star #298, vendor guard #299 |
| agent-context `main` | `6ea55c757e3de1850078041376bd124cbfb4593b` | north star #36, plus 25 old importer plans bannered SUPERSEDED |
| extension branch protection | – | Required approvals 1 → 0 (owner-authorized); the `test` and `codeql` checks stay required |

**Authoritative PG proof, reusable:**
- Harness: backend orphan branch `proof/harness`, reviewed commit `0c97a84f1ca833bacdd7c20c2cfabf20430504a9`.
- Trigger: `PROOF_REMOTE=preserve proof/trigger.sh <label> <sha40> EXPECT_TOTAL_s11=N EXPECT_TOTAL_s10b=N EXPECT_guard=95`.
- Accept: `execution/42d8c5b5/proof/gh-accept.sh <run_id> <sha40> <pins>` (sha256 `4da457af…`). **ACCEPT = proof.** Re-run the whole workflow, never only failed jobs.
- Current pins: 133 / 42 / 95.
- Details: `ghlanes/REPORT.md` and `ghlanes/REVIEW_A.md`.

## 2. IN THE AIR (pushed but not accepted), in priority order
| # | Lane | Grade | Where it is on GitHub | Honest state | Next step |
|---|---|---|---|---|---|
| 1 | **L0 learn-and-remember design** (drives the whole north star) | T4 | backend `cand/x42/learn-doc` @ `982bd2861f7a07f53a590858acef258646bf807a` (629-line doc with all addenda; the `-wip` branch @ `e7a882bb` has an identical tree) | Complete draft, UNREVIEWED; `learn/L0_BUILD.md` is stale, so read `handoff-wip/learn-doc-STATUS.md` instead | Read it against NORTH_STAR, including the AI-step section. Then two reviews (gpt_6_sol + claude_opus_5_5) → land the doc on integration → execute its slice plan |
| 2 | **X1 extension origin authorization** (removes the vendor lock) | T4 | extension PR #35 @ `7ac1fe9a`; WIP fixes ONLY as the patch `handoff-wip/x1-origin-authorization.patch` (hooks blocked commit) | Review A NO-GO (3 A + 2 B); review B PARTIAL NO-GO (4 B). The patch closes most of review A but has two hook failures | Apply the patch to #35's branch, fix the 2 hook errors, add the remaining regressions, close review B's B1–B4, rebase onto `30e78a29` and shrink the vendor-guard allowlist to `legacy/**`. Then a delta review by both reviewers. See `x1-origin-authorization-STATUS.md`, `northstar/X1_REVIEW_A.md` and `X1_REVIEW_B.md` |
| 3 | **C2b-1 endpoint roles** (decoding) | T3 | extension PR #32 @ `cb614bab`; WIP `c2b-1-endpoint-roles-r2-wip` @ `607c93e5` | B2/B3 closed (GO); the B1 fix is on the WIP branch, unreviewed, and CI has not run | Push `607c93e5` onto #32's branch (a fast-forward), then CI, then a delta review of B1 (positive-evidence rule). Land after L0 confirms the deterministic role layer. See `c2b1-STATUS.md` and `c2b1/REVIEW_A.md` |
| 4 | **R1 Roman status binding** | T2 | mobile PR #300 @ `86144f34`; WIP `r1/roman-status-binding-wip` @ `41812117` | Review NO-GO (A stale, A reason remap, B parity). The WIP reuses the card content inside the Roman frame, and the parity test passes 50/50 locally | Lint, the targeted suites and CI on the WIP, then open or update the PR, then a delta review. See `r1-roman-STATUS.md` and `northstar/R1_REVIEW.md` |
| 5 | **S8-D2** imported people on the roster | T4 | backend `cand/x42/s8d2` @ `854fc456` | Built, local gates green, NOT PG-proven and NOT reviewed | Run the GH proof and ACCEPT (new expected counts per `s8d2-STATUS.md`), then two reviews, then land |
| 6 | **S12-B4** pilot runbook + read-only SQL pack | T2 | backend `cand/x42/s12b4` @ `4fee2adc` | Built (docs/pilot/** only) | One review (gpt_6_sol), then land |
| 7 | **S12-B5** prod RLS catalog check script (never run on prod) | T2 | backend `cand/x42/s12b5` @ `fdd19af4` | Built; its local-PG proof was not run | Run it against a disposable PG, then review, then land |
| 8 | **S12-B6** flag workflow (reconstruct flag + pilot allowlist inputs) | T2 | backend `cand/x42/s12b6` @ `dbfe3558` | Built, gates green, no workflow run | Review, then land. Running the workflow against Fly is owner-reserved |
| 9 | S11-DE commit 3 (historical rls-g2 tests expect the v3 cursor) | T2 | backend PR #574 @ `2bd2d85d` | PARKED: it is in no proof lane, and Q07 needs a two-head PG run. Hygiene only | Low priority |

The STATUS files for every lane are in `execution/42d8c5b5/handoff-wip/`. Build and review reports are in the per-lane dirs (`s8d2/`, `s12b4/`, `s12b5/`, `s12b6/`, `c2b1/`, `northstar/`, `learn/`).

## 3. What the north star still needs (the expected L0 slice chain)
1. X1 origin authorization (#2 above).
2. The rest of C2b and C2c: turn captured traffic into a blueprint (data only).
3. C3: the one-process Start. It decodes, learns and imports with zero coach steps, and the Roman journey is the UX (R1).
4. The backend AI mapping step (T4). It reuses `src/ai/gateway` and needs:
   - a live, contract-derived prompt (goal plus TGP structure, generated from the validator contract);
   - injection defence;
   - hard usage limits;
   - the best model, behind an eval harness;
   - strict validators and conformance against the real rows.
5. Learned-platform memory (structure only, versioned, invalidated on drift) and the runtime registry: no deploy per site, CORE DIFF = 0.
6. V1: a real site that was never hand-mapped, imported end to end from one Start.
7. Delete the legacy TrueCoach extractor and `truecoach.json` at parity, then shrink the guard allowlists to tests only.

## 4. Owner decisions pending
- **Pilot:** which real platform to use, and authority over the coach's live source account.
- **AI step:** the provider account/key and the default daily spend cap.
- **Release:** promote integration → main, deploy, set prod flags (plus the Fly invoice or deploy preconditions noted in earlier evidence).
- **Stale PR:** close extension #30 (a draft whose head a889f4ad is already on main). This operator was not permitted to close it.
- **Chrome Web Store:** publishing X1 later (optional host permissions → possible extra review).

## 5. Off-path, untouched
Backend drafts #525–529, #522, #491, #427/#428 and the dependabot PRs.
