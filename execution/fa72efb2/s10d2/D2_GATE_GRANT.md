# S10-D D2 composition gate grant (EXEC-FA72EFB2)

Slice: S10-D D2 synthetic unseen source `s10_unseen` (D-S10-5; R27, R39, R40, R41). The proof slice for
"NEW SOURCE -> CORE DIFF = 0". Grade: T4 overall (the live R39 chain is proof-bearing); this grant is the T2 mechanical
gate part. Requested route: Claude Sonnet 5.0 (doctrine T2 = Claude Sonnet 5; nearest recorded). An independent T4
review runs in parallel (separate grant); you are not the reviewer.

Clone: /home/user/workspace/worktrees/fa72-d2 (branch fa72/d2) at integration/importer 6a33df9b. The parent applied
execution/d3a9f701/s10d/d2.diff: exactly 8 new 100644 files, all sha256 equal to s10d2_builder_summary.md (verified
15:1xZ). P (7746a877, the B-side premise edits the D2 summary listed as BLOCKERS 1-4) is landed in this base.

Do:
1. prettier 3.9.9 `--check` on the 8 paths; if it fails, `--write` ONLY those paths and record the exact diff (format-only;
   anything semantic = STOP). JSON files must stay valid.
2. eslint --max-warnings 0 on the two spec files; `npx tsc --noEmit`.
3. No-DB tier: `npx jest --runInBand --runTestsByPath test/scout/s10/s10-unseen.e2e.spec.ts` and the B-side suites
   test/scout/reconstruct/native/native-families.spec.ts test/scout/induction/manifest-registry.spec.ts
   test/scout/reconciliation/facts.service.coverage.spec.ts test/scout/reconstruct/mapping-spec.spec.ts
   test/scout/reconstruct/source-mapper-registry.spec.ts test/scout/induction/s10c-wiring.spec.ts, plus the full
   `test/scout` unit tree with the PG specs skipped by their own env guards (confirm s10-unseen.pg.spec.ts is
   describe.skip without G2_S10B_DATABASE_URL, i.e. it must not hard-fail in the default config).
4. Commit (one local commit on fa72/d2 via hooks; Bradley author+committer; no trailers; subject
   "test(scout): prove an unseen source lands as data only (S10-D D2)"). Then R40 gate:
   `bash scripts/s10-core-diff-gate.sh 6a33df9b2ea1fd246663a2287b92830f0d093abe` must exit 0 with `git diff --name-only`
   exactly the 8 paths; then check-8 negative controls a-d exactly per the D2 summary recipe, each on a throwaway local
   branch off your commit, each must FAIL at the stated check; delete those throwaway branches afterwards and leave
   fa72/d2 at your commit, clean.
All heavy commands under the flock rule (WORKER_RULES 3). Do NOT run s10-unseen.pg.spec.ts or any S10-B lane.
If a no-DB test fails: classify (A/B/C per WORKER_RULES 5) with the failing assertion and the smallest closure; do not
edit core (src/**/*.ts) — core diff must stay 0; test-only closures inside the 8 D2 paths only, stated exactly.

Report: execution/fa72efb2/s10d2/d2_gate_summary.md (head/tree, sha256 per path post-format, every command + RC,
gate output, negative-control outputs, any closures, open risks).
