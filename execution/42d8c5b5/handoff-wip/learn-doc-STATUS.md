# learn-doc (L0 decision record, T4) — HANDOFF STATUS

- Repo: growth-project-backend. Branch `cand/x42/learn-doc`. Base 9668af6c (integration/importer, Merge #566).
- Pushed head: 982bd2861f7a07f53a590858acef258646bf807a (one commit, one non-force push to `preserve`; no PR).
- File: docs/decisions/2026-09-27-learn-and-remember.md, 629 lines (grant target ≤600; overage = three binding
  addenda: gateway reuse + injection defence + prompt construction + limits + best model).
- Author/committer Bradley Gleave; lefthook pre-commit (r75, prettier, tsc) and commit-msg passed; no bypass.

## DONE and verified
- D-L0-1..9 decided: 11-step one-process flow mapped to Roman screens + status contract; AI backend-only via
  existing gateway capability `importer.mapping`; value-free StructureDigestV1; LearnedProposalV1 grammar,
  V-L0..V-L9, C1-C4; memory tables + one SourceRegistryProvider (CORE DIFF 0); truthfulness (partial until Q2);
  D-L0-7.1 prompt from contract (hash tests L11/L12), 7.2 injection defence + adversarial corpus (L13),
  7.3 limits table with env names + `learning_budget_exhausted`, 7.4 best model + eval harness + no silent
  downgrade, 7.5 fallback; V1 proof (7 items incl. TrueCoach oracle parity) + DEL slice.
- Slices (post-400-LOC rule): L1 backend T4 ~950 (AI step, PROCEED) | L2 backend T4 ~900 (memory, PROCEED) |
  X2 ext T2 ~460 | X3 ext T4 ~580 | L3 backend T4 ~250 (blocked Q2) | V1 | DEL. L1, X2 parallel now.

## NOT done
- learn/L0_BUILD.md is stale (pre-addenda placeholders, old slice table); regenerate from this STATUS + the doc.
- Citations into E#20 (93a678a4) may move when C2b-1 rescue lands (line refs only).

## Open review findings: unreviewed. Check D-L0-7.3 provisional $20/day spend default; D-L0-7.2 sends no value
samples (stricter than owner text); L1 ~950 LOC accepted with PROCEED. learn-doc.patch is superseded by the commit.

## Owner questions (doc §6): Q-L0-1 basis for complete (=S10 Q2); Q-L0-2 V1 live account/consent; Q-L0-3 provider
account/key + default daily spend cap; Q-L0-4 prod flags; Q-L0-5 Chrome Web Store broad optional host permission;
Q-L0-6 NS resolves Q-S11-2; Q-L0-7 cross-tenant reuse/review step; Q-L0-8 retention.

## Next step for a new operator
Review 982bd286 on cand/x42/learn-doc against L0_GRANT.md + the three addenda; then grant L1 and X2 (parallel).
