# S7-L minimum correction (Review B F1/F2) — RECEIPT 2026-09-25T05:00Z — frozen for v2 re-attestation

## Lineage
base 93389265a846095b846fa8f1fb0dad782fb6ee9f -> v1 candidate 839b54c53ccb252f95b4ec63df0b08595bbe7698 (tree f02205c6, PRESERVED, not amended) -> **v2 follow-up head 54970cd937afc8dea689b33243961abfef8b9dd6, tree 513c71d7c1390787e1521ccbfa46b30bb52b5462**, branch exec64/s7l-replacement, worktree clean.
Ordinary commit, Bradley Gleave author+committer, no trailer block; genuine lefthook pre-commit (prod-readiness-quick, banned-cast-tokens, prettier 3.9.9 isolated prefix, eslint, tsc heap 4096) + commit-msg no-ai-tokens all pass — `correction/commit-attempt-1.raw.log`.

## Delta from 839b54c5 (exactly the 3 granted paths; +30/-5) — `bundle/v2/s7l-v2-followup-839b54c53ccb-to-54970cd937af.patch`
- `src/scout/lifecycle/lifecycle.service.ts` (blob 5949a293): in `classifyClosed`, an open row (terminal_status/fenced_at NULL) whose `deadline_at` is still in the future returns `{kind:'not_started'}` before any fence; the expired-row lazy `timed_out` path and all other branches unchanged. Comment extended. A null deadline is left on its previous path (no widening).
- `test/scout/lifecycle/lifecycle.service.spec.ts` (blob 52d4f144): one added case — future-deadline open row → `not_started`, 409 `run_not_started`, `$transaction`/`$queryRaw`/`$executeRaw`/analytics never called. Existing expired-row case and all others untouched. Suite 29/29.
- `test/rls-g2-s7l.spec.ts` (blob 052fa35d): L06 anon/authenticated reached via owner-session `SET ROLE ${role}; …` inside each statement (S8-B P06 pattern; bootstrap grants those roles to postgres WITH ADMIN OPTION) for the SELECT, refused INSERT (`row-level security`), UPDATE and DELETE; service_role rollback case and all assertions unchanged. Comment added.

## Gates (slot pid 10350, in-process flock fd9, 04:56:44Z–04:57:54Z, `correction/slot-4.log`)
prettier --check 3 files rc0 (no rewrite), eslint 3 files rc0, R75 staged rc0, changed unit spec 29/29, hooks pass, checkpoint `correction-01-precommit`. Not run (per grant): 48 unaffected suites, contract regeneration, any PG. Released at exit; probe exit 0, lslocks 0 afterwards.

## Exports `bundle/v2/` (SHA256SUMS 6/6)
thin `s7l-v2-54970cd937af.bundle` (prereq 93389265), `s7l-v2-54970cd937af-full-history.bundle` (verify: complete), follow-up patch, cumulative patch 9338→5497, manifest, `HEAD-54970cd937af.txt`. v1 exports/checkpoints unchanged.

## Binding v2 `binding/v2/` — frozen 04:59:28Z, `BINDING.sha256`
`s7l-pg-proof.sh` 0287a941655b0ff9ec19a306af943fd93c357c00b6187f6ad31dfc90c1de2705 (EXPECT_HEAD 54970cd9, TREE 513c71d7, EXPECT_PARENT 839b54c5 with tree + base-ancestry + 3-path-delta checks, spec blob 052fa35d; all other proof-object and tool pins identical to v1), `s7l-fixture.sh` dc77a7c9…3dd2 (byte-identical to v1), `freeze-v2.sh` 9662dfcc…, `PINS.txt` 7adcc31f…, `README.md` 518d6def…, `DELTA-v1-to-v2.md` bc96f379…, `driver-v1-to-v2.diff` (44 lines). freeze-v2: 13 HEAD_PIN_OK incl. EXPECT_PARENT, 10 TOOL_PIN_OK, 0 mismatches. v1 `binding/BINDING.sha256 -c` intact. First freeze pass (04:58:26Z, before docs were v2) retained as `BINDING.sha256.first-pass-04-58-26Z`; driver/fixture hashes identical between passes.

## Not done / not claimed
No PG, no fixture init, no bootstrap, no 48-suite rerun, no contract regen, no push, no C-observation fixes, no edits to v1 binding, historical evidence, S8-B/S8-C paths.
