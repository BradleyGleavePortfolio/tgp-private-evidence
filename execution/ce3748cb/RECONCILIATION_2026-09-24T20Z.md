# EXEC-CE3748CB — cross-repository reconciliation (2026-09-24 ~20:10Z)

Parent: session ce3748cb (successor to cf8ff737, blocked at 19:00Z; sandbox lost). Read-only live verification via `git ls-remote`, `gh api`, local ancestry checks. No product remote write in this step.

## Live remote heads (verified)

| Repo | Ref | Head | Notes |
|---|---|---|---|
| backend | `main` | `c23b9d9f3fcc` | production (Fly auto-deploy); unprotected; unchanged |
| backend | `integration/importer` | `c7a5fe8dd0b8` | = `land/prod-ci-1`; main..integration = 67, integration..main = 0 |
| backend | `land/s7-b-drain` | `0d69c7ba7e7d` | historical landing ref |
| mobile | `main` | `c7641cb3a4b6` | unprotected |
| extension | `main` | `0111be661922` | protected: 1 approval, enforce_admins, linear, checks test+codeql, conversation resolution |
| extension | `land/s4-r6` = `land/s4-cq` | `aa0abd8310af` | PR #27 head; 24 commits over main, 0 merges |
| extension | `land/ux07-on-s4` | `322b749a75d8` | |
| private-evidence | `main` | `4b5610e65df2` | last publication 18:46:49Z |

## Accepted boundary containment (ancestry verified)

- backend `integration/importer`: S1 56fb0d22, S2 d5cd9b8b, S3 be0ba827, S5 98d39610, S7F 5c760b77, C1 a0ea1bea, B 0d69c7ba, R 7d2895e1, PROD-CI-1 c7a5fe8d, main c23b9d9f — all IN.
- mobile `main`: S6 bc7b4e96, UX-02/07 df0ad112, UX-01 8fd4cf75, composition 716a606e, J3 9ff749c3, UX-03a 797be968, UX-03b 519b0122, UX-03c c7641cb3 — all IN.
- extension `land/s4-r6`: S4 91990ae9, UX-07-on-S4 322b749a (tree cce80315), S4-CQ aa0abd83 (tree d1f9721c), main 0111be66 — IN. UX-07 leaf 6fd7e4a9 NOT an ancestor by design (linearized into 322b749a, same content). Both commits Bradley author+committer.

## PR state (live)

- ext #27 `land/s4-r6`→main @aa0abd83: codeql/test×2/secrets-scan PASS; REVIEW_REQUIRED, BLOCKED. Owner step: non-author approval; G05 note — GitHub rebase/squash merge rewrites committer (recorded owner decision, unchanged).
- backend #530 DRAFT `integration/importer`→main @c7a5fe8d: all checks pass (deploy-readiness-gate skipping by design). Owner production boundary; stepwise promotion per D-C2.
- Superseded drafts still open (census disposition "close as superseded"): backend #524–#529, mobile #290–#294, extension #20/#21/#23/#24/#25/#26. Not closed this step (C; closing is reversible hygiene, no product consequence).

## Lost-sandbox object census

| Object | State | Disposition |
|---|---|---|
| N/Q1 v1 `61b93cff` (tree 7adad696) | not on any remote; **recovered byte-exact** from `nq1/export/nq1-61b93cff….patch` (sha 55a534d5…) via `git am --committer-date-is-author-date` on R `7d2895e1`; SHA and tree identical | worktree `worktrees/s7-nq1`, branch `s7-nq1`. Identical object ⇒ original hooked-commit evidence (receipt 13) applies; no hook claim for the recovery apply itself |
| N/Q1 v2 `8c33e00f` (tree 9ff9a9bf) | never exported off the lost sandbox; **unrecoverable** | C. Design recorded in the predecessor transcript (turn 43). Rebuild as a new head under `NQ1_V2R_REBUILD_GRANT.md`; the delta re-attestation of 8c33e00f never completed, so nothing accepted is lost |
| C phase-1 draft (8 untracked files) | lost; only `c/PHASE1_DRAFT_READY.md` + `c/binding/**` preserved | C. Re-draft from the preserved record under `C_PHASE1_REDRAFT_GRANT.md` |
| PG17 tooling, retained clusters (s5, c1-builder, b-drain, r-ready, nq1) | absent | PG17 is reproducible from pinned Maven artifact (`PG17_PROVENANCE.txt`, jar sha 23da5a04…, postgres sha 23cd1748…). Retained clusters of accepted lanes are gone: B-class for the runner preconditions only (they hash never-started donor clusters); minimum closure in the rebuild grant |
| node_modules | absent | `setup-30-npm-ci.sh` + lock sha pin 05bc530a… |

## Frozen decisions carried (unchanged)

P1–P3 (N/Q1), D-C1 option (i) + C18 + S9 carry-forward (resolves F1 for C activation), D-C2 staged production promotion (owner).
