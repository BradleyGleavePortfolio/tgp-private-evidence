# R1 GRANT: Roman journey shows the authoritative run status
Grade: **T2**. It is meaningful product behaviour inside an established contract and views. Builder: claude_sonnet_5_0. Review: gpt_6_sol.
North star: NORTH_STAR.md ("the coach experience is the Roman importer journey").
Repo growth-project-mobile, base main 01dd8a3c. Branch `r1/roman-status-binding`, one PR to main, DO NOT MERGE.
Author Bradley Gleave <bradley@bradleytgpcoaching.com>, no AI co-author. ≤400 added prod LOC. Push with single non-force pushes.

## Facts
- The Roman P2 views src/screens/coach/import-journey/{ImportStatusFrame,ImportProgressView,ImportResultView}.tsx were merged on 09-24 but are
  UNMOUNTED. They are waiting for "a future authoritative adapter" (read P2_README.md, the caller contract: "display inputs are not proof").
- The authoritative source exists: useImportRunStatus (S12-B3) plus src/types/importRunStatus.ts. It is shown today only by the plain
  ImportRunVerdictCard, mounted in ExtensionPairingPanel.tsx L263.

## Scope
1. Add one pure adapter, importRunStatus → P2 view props. It maps only fields the server states, with no inference:
   - stale or unavailable stays honest;
   - `complete` is shown only when the server says complete;
   - partial or failed are shown with the server's reasons.
   Unit-test every status branch.
2. Mount the Roman progress/result views in the journey where the verdict card shows today, using the existing hook. Roman on and Roman off both
   use the Roman views, neutral when off. Keep exactly ONE status surface: retire ImportRunVerdictCard's mount, or reduce it to a thin wrapper
   over the Roman views. Do not show two cards.
3. No Start, retry or stop wiring beyond what already exists. No new polling or timers beyond the hook's. No copy changes to P1 dictionaries.

## Proof
Run the targeted jest suites plus typecheck/lint locally (the machine is shared, so keep it to targeted suites), then watch CI to green.
Report: PR, head, CI, prod/test LOC, and the status → view mapping table.
Write BUILD at execution/42d8c5b5/northstar/R1_BUILD.md (commit locally in the evidence repo, no push).
