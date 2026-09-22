# FROZEN composed successor for B2 (S1S2 composition, R2 lane) — 2026-09-22T00:38Z

head 21ea3252de90cab66c591cf907b65a0ee7eef879
tree 5aa6630b7b293cc00c4841961967f3d9eeba1fbe
parents 3f49ffc8ac654e96e7eb9921de70a19cc0cba389 (S2 successor: release.sh D1/D2/D3, harness, spec, recovery docs) + 56fb0d227558c86fe824f9fb1bc15e222411504f (frozen S1 test-only successor, tree 79ebf175, parent 41f4d6a9)
lineage c23b9d9f → e15e25c2 + b7d7fe59 → 0af39f6c → eb6904d1 + 41f4d6a9 → 9742037b → 93a85544 → 3f49ffc8 (+56fb0d22) → 21ea3252de90cab66c591cf907b65a0ee7eef879
branch execute/20260921-s2-composition-r2, worktree /home/user/workspace/worktrees/s2-composition-r2 (clean); frozen 9742037b worktree untouched
merge: genuine --no-ff, 0 conflicts, disjoint paths (S1 delta = test/db/_support/s1-truncate-controls.sh, test/db/s1-r4-truncate-discriminator.sh, +test/db/s1-r4-truncate-message-spec.sh)
author=committer Bradley Gleave <bradley@bradleytgpcoaching.com> on all commits; no trailers
bundle bundle/s2-composition-r2-21ea3252-from-public-c23b9d9.bundle sha256 88bdc85d7b2b8ef73972a16e6bd007dcf99e2b1e961d8de9de170ee153376034 (verify ok; requires public c23b9d9f); commits list bundle/commits-r2.txt

## Blob identity (composed HEAD)
S1 paths == 56fb0d22 (all SAME): verify.sql 266e62e9…9448, migration.sql 72b0ad5a…, down.sql dd7dd6f3…, s1-target-guard.sh 6f66e436…, supabase-like-bootstrap.sql e8c42d2e…,
  s1-rls-close-public-exposure.sh 776a0339…, s1-truncate-controls.sh 6a88a98c…a65c, s1-r4-truncate-discriminator.sh 82da49b2…9921, s1-r4-truncate-message-spec.sh b8be189d…b937
  (matches INTEGRATION_FOR_S2.md hashes). git diff 56fb0d22..HEAD -- prisma/migrations test/db : empty.
predecessor verifier reachable: git show b7d7fe59:…/verify.sql sha256 2bbce0d7…323e (controls fail closed otherwise).
S2 paths == 3f49ffc8 (git diff 3f49ffc8..HEAD -- scripts docs test/release test/ci : empty); release.sh sha256 8831f8f744d1b42499c8eae7f34e21651c65cf3e831ab82d064434a36482f073;
  harness test/release/s1s2-composition.sh 4473754970c85819855fde6ae8c26035d93c0458e55d6de9697dc752510801b6.
package-lock.json 62b05b90…1390, package.json, prisma/schema.prisma byte-identical to 9742037b (dependency closure reuse admissible).

## Cheap offline checks in the composed tree (no DB)
S1 message spec test/db/s1-r4-truncate-message-spec.sh: 24 passed, 0 failed, exit 0 (0.2 s).
S1 guard spec test/db/s1-harness-guard.spec.sh: == 72 passed, 0 failed (guard spec, offline, head 21ea3252).
R2 runner stub success at pinned head: final 0, all steps reached (runner-selftest-r2/).
Earlier at 3f49ffc8 (S2 files unchanged since): jest delivery-artifact.spec.ts -t "fake prisma" 9/9; route-doc-drift 5/5; D1/D2/D3 offline controls (see SUCCESSOR_R2_DELTA_AND_SLOT_REQUEST_02.md).

## Runner pinned for B2
run-composition-r2-when-granted.sh sha256 14ca1e8512232d228687dc9c68529de1441c2f5ef339c52c027c9aec160ebcb3 — EXPECT_HEAD 21ea3252de90cab66c591cf907b65a0ee7eef879, DB s1_rls_s2comp_r2, namespace clusters/s2comp-r2 (fresh-only), output composition-r2/<utc>/.
Expected: harness 68 checks / 0 failed; step 45 S1 R4 discriminator exit 0 with 47 checks (48 with marker row) per INTEGRATION_FOR_S2.md — S1's result to interpret.
Launch only on a central grant (a free lock is not a grant): ./launch-detached.sh start composition-r2 env -u S2_RUNNER_STUBS timeout --foreground -k 60 2100 bash /home/user/workspace/execution/s2-composition/run-composition-r2-when-granted.sh

## Runner v4.1 note (00:40Z) sha256 14ca1e8512232d228687dc9c68529de1441c2f5ef339c52c027c9aec160ebcb3
Stub run at 00:34Z gave a FALSE survivor (a tool-call shell whose command text contained the harness name). Survivor scan is now anchored to the
children's real cmdline starts (^/home/user/pg17/dist/bin/postgres, ^bash test/release/s1s2-composition.sh, ^bash test/db/s1-r4-…, ^psql …54321,
^node …prisma/build/index.js) + 54321 listener; re-tested 00:35Z: shell containing the names → survivors=none, final 0; real stub daemon → survivors=present, 71.
Pre-existing release.sh /tmp scratch files (fixed paths) are preserved into composition-r2/<utc>/preexisting-tmp/ with listing+heads, never deleted.
Disclosure: my own jest "fake prisma" runs (00:25Z) left such files; moved to execution/s2-composition/preexisting-tmp/20260922T003455Z-my-jest-fake-runs/.
Note: another lane's jest run of test/ci/delivery-artifact.spec.ts will recreate them (release.sh fixed paths) — runner handles it as above.
