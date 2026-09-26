#!/usr/bin/env python3
# D2 binding v2 builder (EXEC-FA72EFB2, T3): minimum substitution from binding/v1. Every replacement asserts its exact
# occurrence count on the v1 bytes; nothing else changes. Not part of the binding (kept for audit).
import hashlib, os, re, sys
E = "/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s10d2/binding"
V1, V2 = E + "/v1", E + "/v2"

def sub(txt, old, new, n, what):
    c = txt.count(old)
    if c != n:
        sys.exit(f"ASSERT {what}: {old!r} count {c} != {n}")
    return txt.replace(old, new)

# ---------------- fixture ----------------
fx = open(V1 + "/d2-fixture.sh").read()
fx = sub(fx, "(lane s10d2 only,", "(lane s10d2-v2 only,", 1, "fx lane prose")
fx = sub(fx, "s10d2/binding/v1/d2-pg-proof.sh", "s10d2/binding/v2/d2-pg-proof.sh", 1, "fx binding path")
fx = sub(fx, "clusters/s10d2", "clusters/s10d2-v2", 6, "fx clusters")
fx = sub(fx, "run/s10d2", "run/s10d2-v2", 3, "fx run")
open(V2 + "/d2-fixture.sh", "w").write(fx)
fx_sha = hashlib.sha256(fx.encode()).hexdigest()

# ---------------- runner ----------------
r = open(V1 + "/d2-pg-proof.sh").read()
V1H = "144269d13db5275a2d6689bebb2f7dca8367593c"
NH, NT = "275e458ca5a6b3684bb6ec83edb2a854056a6fd0", "6267ef6a57225af187f5a21fb8a2c3cc3fd6103e"
# header prose
r = sub(r, "execution binding v1 (EXEC-FA72EFB2)", "execution binding v2 (EXEC-FA72EFB2)", 1, "hdr title")
r = sub(r, "#   * candidate = ONE D2 commit (rebased; 8 blobs = gated 6e3f86ce) on BASE 7fdcbc04 (branch fa72/d2-r1 in SRC=worktrees/fa72-d2); pre-lock git checks read SRC;\n",
        "#   * candidate = TWO D2 commits on BASE 7fdcbc04 (branch fa72/d2-r1 in SRC=worktrees/fa72-d2): 144269d1 (the v1 candidate: 8 added paths,\n"
        "#     blobs = gated 6e3f86ce) + 275e458c (diagnose-fix after PROOF_V1_FINDING: ONLY the pg spec modified, 9 it()); pre-lock git checks read SRC;\n", 1, "hdr candidate")
r = sub(r, "W=worktrees/fa72-d2-pg1 (shared", "W=worktrees/fa72-d2-pg2 (shared", 1, "hdr W")
r = sub(r, "#   * lane clusters/s10d2 + run/s10d2 on 55649,", "#   * lane clusters/s10d2-v2 + run/s10d2-v2 on 55649 (fresh; the retained stopped v1 lane clusters/s10d2 is an other lane:\n#     fingerprinted, never started, must be unchanged),", 1, "hdr lane")
r = sub(r, "it() count pinned at HEAD (8);", "it() count pinned at HEAD (9);", 1, "hdr count")
r = sub(r, "must equal EXPECT_HEAD 144269d1 (pushed;", "must equal EXPECT_HEAD 275e458c (pushed by the parent before launch;", 1, "hdr land")
r = sub(r, "s10d2/binding/v1/d2-pg-proof.sh\n# Filled (parent 08:53, README.md fill table): values re-derived by `git rev-parse` / `sha256sum` in SRC at 144269d1.",
        "s10d2/binding/v2/d2-pg-proof.sh\n# Filled (v1: parent 08:53; v2: re-pinned to 275e458c, README.md): values re-derived by `git rev-parse` / `sha256sum` in SRC.", 1, "hdr usage")
# paths / pins
r = sub(r, "s10d2/binding/v1   # D2 binding v1 (from s10c v6)", "s10d2/binding/v2   # D2 binding v2 (from D2 binding v1)", 1, "D")
r = sub(r, "branch fa72/d2-r1 at 144269d1 (rebased D2)", "branch fa72/d2-r1 at 275e458c (D2 + diagnose-fix)", 1, "SRC comment")
r = sub(r, "W=/home/user/workspace/worktrees/fa72-d2-pg1 ", "W=/home/user/workspace/worktrees/fa72-d2-pg2 ", 1, "W")
r = sub(r, "EXPECT_HEAD=" + V1H + "                   # D2 rebased commit on fa72/d2-r1 (8 D2 blobs = gated 6e3f86ce); PR #561\n",
        "EXPECT_HEAD=" + NH + "                   # D2 diagnose-fix commit on fa72/d2-r1 (pg spec only); PR #561\n"
        "D2_V1_HEAD=" + V1H + "                    # HEAD^: the v1 candidate (8 added D2 paths = gated 6e3f86ce); its parent is BASE_HEAD\n", 1, "EXPECT_HEAD")
r = sub(r, "EXPECT_TREE=a0bc3c09f82edd8fa13932913437813911d5be38", "EXPECT_TREE=" + NT, 1, "EXPECT_TREE")
r = sub(r, "EXPECT_D2_BLOB_PG=074b0fa0f0472be23e312ca68a9b0528c28230c5                        # test/scout/s10/s10-unseen.pg.spec.ts (the spec this run executes)",
        "EXPECT_D2_BLOB_PG=352cb34027766b126bb06e6c5b4f164ace2afa26                        # test/scout/s10/s10-unseen.pg.spec.ts (the spec this run executes; 275e458c; v1 074b0fa0)", 1, "blob pg")
r = sub(r, "EXPECT_LAND_REF=" + V1H, "EXPECT_LAND_REF=" + NH, 1, "land")
r = sub(r, "EXPECT_FIXTURE_SHA=0fadafa36ff77dbf5621315d5ffca54bc4a57d2a7d8dc0328532798fcea5c24b", "EXPECT_FIXTURE_SHA=" + fx_sha, 1, "fixture sha")
r = sub(r, "# sha256 of binding/v1/d2-fixture.sh", "# sha256 of binding/v2/d2-fixture.sh", 1, "fixture sha comment")
r = sub(r, "EXPECT_TESTS_D2=8                                   # it() count in test/scout/s10/s10-unseen.pg.spec.ts (R39 a-f, R41, R27 live; builder count on the pre-gate bytes 074b0fa0; re-checked at HEAD)",
        "EXPECT_TESTS_D2=9                                   # it() count in test/scout/s10/s10-unseen.pg.spec.ts (R39 a-f, R41, R27 live, (h) roster; builder count on 352cb340 at 275e458c; re-checked at HEAD)", 1, "tests d2")
r = sub(r, "EXPECT_TESTS=$EXPECT_TESTS_D2                       # 8: the one jest run must print \"Tests: 8 passed, 8 total\"",
        "EXPECT_TESTS=$EXPECT_TESTS_D2                       # 9: the one jest run must print \"Tests: 9 passed, 9 total\"", 1, "tests")
r = sub(r, "EXPECT_D2_BLOB_E2E EXPECT_D2_BLOB_PG FROZEN_P_BLOB; do", "EXPECT_D2_BLOB_E2E EXPECT_D2_BLOB_PG FROZEN_P_BLOB D2_V1_HEAD; do", 1, "40hex loop")
# lane
r = sub(r, "LANE=$CLUSTERS/s10d2; SOCK=$RUNTIME_ROOT/run/s10d2\n", "LANE=$CLUSTERS/s10d2-v2; SOCK=$RUNTIME_ROOT/run/s10d2-v2\n", 1, "lane vars")
r = sub(r, "[ \"$LANE\" = \"$CLUSTERS/s10d2\" ] && [ \"$LANE\" != \"$S10B_LANE\" ] && [ \"$SOCK\" = \"$RUNTIME_ROOT/run/s10d2\" ] || { log \"PRECONDITION_FAIL lane $LANE / socket $SOCK is not clusters/s10d2 + run/s10d2\"",
        "[ \"$LANE\" = \"$CLUSTERS/s10d2-v2\" ] && [ \"$LANE\" != \"$S10B_LANE\" ] && [ \"$SOCK\" = \"$RUNTIME_ROOT/run/s10d2-v2\" ] || { log \"PRECONDITION_FAIL lane $LANE / socket $SOCK is not clusters/s10d2-v2 + run/s10d2-v2\"", 1, "lane check")
r = sub(r, "harness env not bound to the s10d2 lane", "harness env not bound to the s10d2-v2 lane", 1, "harness env msg")
r = sub(r, "grep -qx \"LANE=\\$RUNTIME_ROOT/clusters/s10d2\" <<<\"$FIXTXT\" && grep -qx \"DATA=\\$LANE/pg-data; LOG=\\$LANE/pg.log; SOCK=\\$RUNTIME_ROOT/run/s10d2\" <<<\"$FIXTXT\" || { log \"PRECONDITION_FAIL fixture lane/socket lines != clusters/s10d2 + run/s10d2\"",
        "grep -qx \"LANE=\\$RUNTIME_ROOT/clusters/s10d2-v2\" <<<\"$FIXTXT\" && grep -qx \"DATA=\\$LANE/pg-data; LOG=\\$LANE/pg.log; SOCK=\\$RUNTIME_ROOT/run/s10d2-v2\" <<<\"$FIXTXT\" || { log \"PRECONDITION_FAIL fixture lane/socket lines != clusters/s10d2-v2 + run/s10d2-v2\"", 1, "fixture lane grep")
r = sub(r, "# ---- step 1 preflight (read-only): s10d2 lane absent;", "# ---- step 1 preflight (read-only): s10d2-v2 lane absent (v1 lane clusters/s10d2 = an other lane);", 1, "preflight prose")
# commit chain: BASE -> D2_V1_HEAD (8 pure additions) -> HEAD (pg spec only, modified)
r = sub(r, "[ \"$(git -C \"$SRC\" rev-parse HEAD^)\" = \"$BASE_HEAD\" ] && [ \"$(git -C \"$SRC\" rev-list --count \"$BASE_HEAD..HEAD\")\" = 1 ] || { log \"PRECONDITION_FAIL HEAD^ != $BASE_HEAD (the gate makes exactly one commit on BASE)\"; fail 70; }\n",
        "[ \"$(git -C \"$SRC\" rev-parse HEAD^)\" = \"$D2_V1_HEAD\" ] && [ \"$(git -C \"$SRC\" rev-parse \"$D2_V1_HEAD^\")\" = \"$BASE_HEAD\" ] && [ \"$(git -C \"$SRC\" rev-list --count \"$BASE_HEAD..HEAD\")\" = 2 ] || { log \"PRECONDITION_FAIL chain != $BASE_HEAD -> $D2_V1_HEAD -> HEAD (exactly two D2 commits on BASE)\"; fail 70; }\n"
        "V1D=$(git -C \"$SRC\" diff --name-status --no-renames \"$D2_V1_HEAD\" HEAD | tr '\\t\\n' '  ' | sed 's/ $//'); [ \"$V1D\" = \"M $D2_SPEC\" ] || { log \"PRECONDITION_FAIL $D2_V1_HEAD..HEAD [$V1D] != the pg spec only (modified)\"; fail 70; }\n", 1, "chain")
r = sub(r, "[ \"$(git -C \"$W\" rev-parse HEAD^)\" = \"$BASE_HEAD\" ] \\\n", "[ \"$(git -C \"$W\" rev-parse HEAD^)\" = \"$D2_V1_HEAD\" ] \\\n", 1, "clone parent")
left = re.findall(r"__FILL_|__D2_", r)
if left: sys.exit("FILL LEFT")
open(V2 + "/d2-pg-proof.sh", "w").write(r)
os.chmod(V2 + "/d2-pg-proof.sh", 0o755)
print("fixture_sha", fx_sha)
