# S11-C recovery, composition, regeneration and gate grant (EXEC-FA72EFB2)

Slice: S11-C readiness block on the setup reads (D-S11-5, J17-J18, D-S11-8 row). Grade: T3 (contract + customer-visible
wording) with T2 tests. Requested route: Claude Opus 5.5 (doctrine T3 = Claude Opus 5; nearest available recorded).
Source review: GO already exists (execution/d3a9f701/s11c/s11c_review.md, no A/B) — do not redesign; recover.

Clone: /home/user/workspace/worktrees/fa72-s11c (branch fa72/s11c) at 3db615c0 = S11-A1 v3 (harness present).

Recovery (exact bytes first, then compose):
1. The six S11-C files as of the reviewed candidate on base 711c1f8f are: preformat copies in
   execution/d3a9f701/s11c/devloop-1/preformat/** whose post-prettier sha256 must equal devloop-1/POSTFORMAT.sha256
   (and the builder summary table). Reproduce the POSTFORMAT bytes (prettier 3.9.9) and verify every sha256; if any
   mismatch, STOP and report (do not hand-fix).
2. Compose onto 3db615c0 by DELTA, never by whole-file copy: `test/contracts/importer-contract.spec.ts` changed
   between 711c1f8f and 6a33df9b (S10-C2), so apply only the S11-C hunk (s11c_fix0.diff) with a 3-way merge; for the
   other five paths check `git diff 711c1f8f 6a33df9b -- <path>` is empty and then place the verified bytes.
   Verify afterwards that `git diff 3db615c0 -- <path>` equals the S11-C delta and nothing else.
3. devloop-1 (predecessor, base 711c1f8f) was red only on: missing g2-s11 harness (fixed by the base), TS7006 at
   test/scout/s11/readiness.pg.spec.ts:67 (`q` implicit any; re-check — it may resolve with the harness types; if not,
   the minimum closure is a type annotation on that one parameter, test-only), and the expected contract drift.
4. Regenerate docs/contracts/importer-openapi.json with the repository generator (you are the sole generator writer
   for this slice). The resulting diff vs 3db615c0 must be ONLY `PairSessionResult.readiness` plus the new
   `PairReadiness` schema (J18 additive-only). Anything else: STOP and report.

Owned paths: src/extension-pair/extension-pair.dto.ts, src/extension-pair/extension-pair.service.ts,
src/extension-pair/__tests__/readiness.spec.ts, test/contracts/importer-contract.spec.ts,
test/rls-c1-setup.spec.ts, test/scout/s11/readiness.pg.spec.ts, docs/contracts/importer-openapi.json (generated only).

Gates (under the flock rule): prettier --check; eslint --max-warnings 0 on owned TS; `npx tsc --noEmit`;
check-r75 staged; generator re-run is byte-stable; jest --runInBand on src/extension-pair/__tests__ and
test/contracts/importer-contract.spec.ts (drift + cross-process determinism must pass). NOT test/rls-c1-setup.spec.ts
live or readiness.pg.spec.ts (parent bindings; state their exact commands).
When green: one local commit on fa72/s11c through the hooks (Bradley author+committer, no trailers), subject
"feat(extension-pair): report import readiness on the setup reads (S11-C)".

Report: execution/fa72efb2/s11c/s11c_compose_summary.md — recovery sha table (expected vs got), compose method per path,
the regenerated contract diff summary, every command with RC, head/tree, exact parent live commands, open risks.
