# S11-A1 binding v3 independent delta review (EXEC-FA72EFB2)

Grade T3 (proof-bearing runner re-pin; the runner body was already reviewed GO at v2 incl. the B-1 hook-identity fix).
Requested route: Claude Opus 5.5 (doctrine T3 = Claude Opus 5; nearest recorded). Read-only: do not run the runner, jest,
PG, or take the lock; no edits.

Review ONLY the delta (Safety ROI: accepted v2 lines are not re-audited):
- execution/fa72efb2/s11a1/binding/v3/DELTA-from-v2.diff (runner) and DELTA-fixture-from-v2.diff (fixture).
- Verify every new pin against live bytes (read-only git in /home/user/workspace/worktrees/fa72-s11a1 and
  /home/user/workspace/repos/backend): BASE_HEAD/TREE 6a33df9b/454fd501, EXPECT_HEAD/TREE 3db615c0/6ea6852c,
  LAND_REF origin/land/s11a1-v3, spec blob a4ba04ee, FREEZE-v3.sha256 contents (sha256 of each path at HEAD) and its
  sha e6e3a15a…, fixture sha 777e6ac3…, lock inode (stat /home/user/workspace/execution/test-validation.lock),
  donor pins vs execution/fa72efb2/runtime/raw/rt-setup.log (hidden lock 05bc530a, client 2c819c8a/aca7a558,
  prisma 6.19.3), PG/psql/node shas vs that log.
- The one semantic change: the v2 guard `EXPECT_NM_CLIENT_SHA != DONOR_CLIENT_SHA` (it detected a pre-S10-B donor) is
  inverted to `==` because the v3 donor was generated from the base schema. Does this weaken what the proof proves?
  (The clone still runs prisma generate in-clone and the POSTGEN pin + bootstrap CANDIDATE_CLIENT_VERIFIED remain.)
- Anything in the unchanged v2 body that the NEW environment makes wrong (paths, partial-clone source with
  GIT_NO_LAZY_FETCH=1 — the parent dry-ran `git clone --shared --no-checkout` + detached checkout of 3db615c0 from this
  source with that env: rc 0, clean, tree 6ea6852c; test counts rls 6 / journey 8 / guard 94 at 3db615c0).
Context: v2 proof failure PROOF_V2_FINDING.md and its fix PROOF_V2-fix.diff with delta GO are in
execution/d3a9f701/s11a1/ (reviews-s11a1_binding_review.md). Rules: execution/fa72efb2/WORKER_RULES.md.
Verdict GO/NO-GO; A/B only with CLASS, HARM, DECISION BLOCKED, MINIMUM CLOSURE, EXECUTION UNLOCKED.
Report: execution/fa72efb2/s11a1/s11a1_v3_binding_review.md.
