# B2-S1S2-COMPOSITION-R2 — actual result (run 20260922T003854Z) and runner fingerprint explanation

## 1. Runner fingerprint (parent question)
- Granted/quoted: 7642c3c4a49c691f5195659b189d14ddc27f3339f262b4b718f1be96709ca4cc (v4.0). Actually run: 14ca1e8512232d228687dc9c68529de1441c2f5ef339c52c027c9aec160ebcb3 (v4.1).
- Edit time: runner mtime 2026-09-22T00:35:35Z (before the grant at ~00:38Z). FROZEN_COMPOSED_SUCCESSOR.md was rewritten to 14ca1e85 at 00:37:56Z; my
  reply preceding the grant reported "v4.1 sha256 14ca1e85…" and both deltas. The grant quoted the earlier hash from the first FROZEN version (00:34Z).
  I should have re-frozen the request file before reporting readiness rather than editing the runner after the first freeze; noted as my process defect.
- v4.0 was edited in place (not retained as a file). Reconstructed by reverting the two edits: runner-history/run-composition-r2-when-granted.sh.v4.0.reconstructed
  hashes to exactly 7642c3c4…ca4cc (verified). As-run copy: runner-history/run-composition-r2-when-granted.sh.v4.1.as-run (14ca1e85). Diff: runner-history/v4.0-to-v4.1.diff (11 lines, 2 hunks).
- Exact delta: (a) survivor scan regex anchored to child cmdline starts (v4.0 counted any process whose cmdline CONTAINED "s1s2-composition.sh" etc.,
  producing a false 71 in stub run 00:34Z); (b) precheck preserves pre-existing release.sh fixed-path /tmp scratch files into $OUT/preexisting-tmp (never deletes) — in this run none existed.
- Behaviour/scope: no change to inputs, head pin, gates, expected outcomes, lock, namespace, bounds or exit mapping. (a) narrows what counts as a survivor
  toward real fixture/harness processes; listener check unchanged. (b) evidence-preserving only. Nothing was edited during the run.

## 2. Actual B2 result — NOT accepted: harness exit 1
launch 00:38:54Z pid 12508 (sid 12508); end 00:40:31Z; sentinel runs/composition-r2.exit = 1
exit-codes: final=1 guard_spec=0 fixture=0 composition=1 s1_r4_discriminator=notrun fixture_stop=0 survivors=none
guard spec 72/0; refusals 64/64; fresh PG 17.6 cluster clusters/s2comp-r2 (95M, stopped, retained); real 164-parent replay + candidate 165 on s1_rls_s2comp_r2.
harness: 66 passed, 2 failed (head 21ea3252). Both failures are C0 — my harness's construction, not release.sh, not S1:
  FAIL C0 tree: "S2-only tree extracted from e15e25c2 has release.sh identical to integrated head" expected 8831f8f7… (HEAD release.sh) got 9908234e… (e15e25c2 release.sh)
  FAIL C0: "prisma_cli += prisma 6.19.3" in that tree's refusal banner (e15e25c2's release.sh still prints "Prisma schema loaded…" — the D3 defect)
  Cause: C0 builds the "S2-only tree" by `git archive` of the FROZEN S2 head e15e25c2. That was valid at 974 (release.sh unchanged since e15e) but the
  successor changed release.sh (D1/D2/D3), so C0 now compares the OLD release.sh against the new one and asserts the new banner on the old script.
  Not a regression in the shipped release.sh; the S2-only refusal itself was proven (exit 1, "REQUIRED catalog verifier missing", no step 1, no connection, no migrate log).
  Fix (harness only, S2 lane): construct the S2-only tree as the integrated HEAD minus S1-owned paths (prisma/migrations/<S1 dir>, test/db), or extract e15e25c2
  and overlay HEAD:scripts/release.sh. Requires a new successor commit + re-freeze + new slot; not done (no source edits during/after grant without authorization).
  Harness stopped at first failure? No — the harness runs all checks and reports the count; the runner stops after step 40 (exit 1) so step 45 discriminator = notrun.
What the 66 real passes established (D1/D2/D3 and B-01/02/03/07 outcomes, real 6.19.3, real PG 17.6):
  C1 (fresh DB, candidate pending): banner prisma_cli = prisma 6.19.3; pending_migrations_detected = 1 (single line); real migrate deploy applied candidate; verifier invoked;
     verifiers_passed=1 verifiers_required=1; ALL_APPLIED=165 read through @prisma/client $queryRaw.
  C2 (rerun): pending_before=0, exit 0.  C3: verifier failure banner names the S1 verifier.  C4: exit 0 after recovery.  C5/C5r/C7: as at B1 (pass).
  C8 (real failed row → resolve --rolled-back): re-applied candidate ("Applying migration" line), ALL_APPLIED=165 excluding rolled-back row, ledger total 165, verifiers_passed=1.
Cleanup: fixture-stop exit 0; pg_ctl "no server running"; survivors none; no 54321 listener; lock FREE after exit (check-lock.sh). B1 cluster s2comp and S5 cluster untouched.
Evidence: composition-r2/20260922T003854Z/ (stamp.txt, exit-codes.txt, 10–51 step logs, harness/{harness.log,C*.release.log,C*/}, SHA256SUMS.b2-frozen), runs/composition-r2.{log,exit,pid,cmd}.
