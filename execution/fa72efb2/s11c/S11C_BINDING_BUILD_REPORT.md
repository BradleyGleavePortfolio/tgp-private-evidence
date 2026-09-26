# S11-C binding build report (T3 builder) — source only, nothing run
Output: binding/v1/ (see binding/v1/BINDING.sha256). Runner s11-pg-proof.sh 5e4b29ec9a00947c004aced3d8b2f309e81f31801092c2b78866734a17ee1c1d (369 LOC; delta +53/-26, 11 hunks).
Changed pins (all verified read-only in worktrees/fa72-s11c): D, SRC=fa72-s11c, W=fa72-s11c-pg1 (absent), BASE_HEAD=3db615c0a5e6…, BASE_TREE=6ea6852ca162…,
EXPECT_HEAD=7fdcbc044dba…, EXPECT_TREE=a802231ee1f4…, LAND_REF=refs/remotes/origin/land/s11c (=7fdcbc04), EXPECT_DELTA=7 S11-C paths,
A1_FILES=old 8-path list (FREEZE-v3 identity at HEAD), S11C_FREEZE_SHA=2d58f9d1…137e, EXPECT_READINESS_BLOB=1afcb07d…6196, EXPECT_SERVICE_BLOB=dfd2e267…a1e5,
EXPECT_DTO_BLOB=9eb9f3d3…f3fc, EXPECT_TESTS_READINESS=6, JLOG4=jest-readiness.log, readiness bound 900 s (soft sum 6810 < 7200).
Unchanged, re-verified at HEAD: all 11 A1 blob pins, migrations tree 7b6fe0ed/173/last S10-B, package-lock b7fed5ed, schema d6d01f54, fixture 777e6ac3, donor lock/client pins, FREEZE-v3 8 files byte-identical, bootstrap BASE_HEAD literal 711c1f8f.
Logic change beyond pins: HARNESS_BASE..BASE_HEAD check split into (prisma/manifests empty) + (test/utils == exactly the 6 A1 test/utils paths); BASE..HEAD check adds test/utils (empty).
Open risk A: runtime/clusters/s11 exists (A1 logs) -> "$LANE exists" PRELOCK refusal; parent must archive+remove before launch.
Open risk C: test/rls-c1-setup.spec.ts changed but its C1-lane real-PG proof is not in this binding (per grant); compose-summary readiness.pg sha f997d0e2 is pre-B1-edit, HEAD bytes 72eda295 are pinned.
Commands run: cat/sed/grep/ls/stat/cmp on evidence+runtime (read-only); git rev-parse/status/config/diff/show/ls-tree/log/merge-base in fa72-s11c (RC 0); sha256sum; python3 substitution script; bash -n (RC 0 runner, RC 0 fixture); diff -u (RC 1 = differences).
