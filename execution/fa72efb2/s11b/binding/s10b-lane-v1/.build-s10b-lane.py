#!/usr/bin/env python3
# Builds s10b-lane-v1/{s10b-lane-fixture.sh,s10b-lane-pg-proof.sh} from the reviewed D2 binding v1 (execution/fa72efb2/s10d2/binding/v1)
# by exact, count-asserted substitutions (T3 builder; source only). argv: <FREEZE-s11b sha256> ; the fixture sha is computed here.
import hashlib, pathlib, sys
TD = pathlib.Path('/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s10d2/binding/v1')
OD = pathlib.Path('/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s10b-lane-v1')
FREEZE_SHA = sys.argv[1]

def apply(s, subs):
    for a, b in subs:
        n = s.count(a)
        if n != 1:
            sys.exit(f'substitution matched {n} times: {a[:100]!r}')
        s = s.replace(a, b)
    return s

# ------------------------------------------------------------------ fixture
fx = (TD / 'd2-fixture.sh').read_text()
fx = apply(fx, [
("#!/usr/bin/env bash\n# S10-D D2 disposable",
 "#!/usr/bin/env bash\n"
 "# EXEC-FA72EFB2 S11-B S10-B-lane fixture v1: minimum substitution of the reviewed D2 fixture execution/fa72efb2/s10d2/binding/v1/\n"
 "# d2-fixture.sh (sha256 0fadafa3…c24b): lane clusters/s10d2 + run/s10d2 -> clusters/s11b-s10b + run/s11b-s10b, required runner\n"
 "# d2-pg-proof.sh -> s10b-lane-pg-proof.sh, lane labels. Port 55649, the reused S10-B harness literals, the refused ports and\n"
 "# every mechanism are unchanged; the D2_RUNNER_PID / D2_STOP_TIMEOUT / D2_FIXTURE_* names are template protocol tokens carried\n"
 "# verbatim (the runner greps them). Full delta: DELTA-fixture-from-d2.diff. Text below is the D2 fixture header.\n"
 "# S10-D D2 disposable"),
("LANE=$RUNTIME_ROOT/clusters/s10d2\n", "LANE=$RUNTIME_ROOT/clusters/s11b-s10b\n"),
("DATA=$LANE/pg-data; LOG=$LANE/pg.log; SOCK=$RUNTIME_ROOT/run/s10d2\n", "DATA=$LANE/pg-data; LOG=$LANE/pg.log; SOCK=$RUNTIME_ROOT/run/s11b-s10b\n"),
("case \"$LANE\" in \"$RUNTIME_ROOT/clusters/s10d2\") ;; *) echo \"REFUSED: lane $LANE is not clusters/s10d2 ",
 "case \"$LANE\" in \"$RUNTIME_ROOT/clusters/s11b-s10b\") ;; *) echo \"REFUSED: lane $LANE is not clusters/s11b-s10b "),
("grep -q d2-pg-proof.sh \"/proc/$D2_RUNNER_PID/cmdline\" \\\n  || { echo \"d2-fixture.sh must be invoked by d2-pg-proof.sh (single lock holder)",
 "grep -q s10b-lane-pg-proof.sh \"/proc/$D2_RUNNER_PID/cmdline\" \\\n  || { echo \"s10b-lane-fixture.sh must be invoked by s10b-lane-pg-proof.sh (single lock holder)"),
("# --- S10-D D2 disposable fixture (S10-B harness marker reused)", "# --- S11-B S10-B-lane disposable fixture (S10-B harness marker reused)"),
("not the marked S10-D D2 lane cluster", "not the marked S11-B S10-B-lane cluster"),
])
(OD / 's10b-lane-fixture.sh').write_text(fx)
FIX_SHA = hashlib.sha256(fx.encode()).hexdigest()

# ------------------------------------------------------------------ runner
S11B = ("src/scout/lifecycle/lifecycle.service.ts src/scout/scout.service.ts test/rls-g2-s10c.spec.ts "
        "test/scout/lifecycle/s11b-settle-redrive.spec.ts test/scout/s11/settle-redrive.pg.spec.ts")
rn = (TD / 'd2-pg-proof.sh').read_text()
rn = apply(rn, [
("#!/usr/bin/env bash\n# S10-D D2 real-PG proof",
 "#!/usr/bin/env bash\n"
 "# EXEC-FA72EFB2 S11-B S10-B-lane binding v1 (the R36 flip in test/rls-g2-s10c.spec.ts). SOURCE ONLY: NOT RUN.\n"
 "# Minimum substitution of the reviewed D2 binding execution/fa72efb2/s10d2/binding/v1/d2-pg-proof.sh (sha256 9a2f8b36…67e8;\n"
 "# its lock/prestart/fresh-clone/donor-copy/bootstrap mechanics ran in this runtime at 16:05Z and failed only on D2 assertions)\n"
 "# with the spec command and counts of the accepted execution/d3a9f701/s10c/binding/v6 (rls-g2-s10b 24 + rls-g2-s10c 8 = 32 via\n"
 "# jest.rls.config.js, rc 0 32/32). Changes: candidate 4d31616f (S11-B, one commit on BASE 7fdcbc04, branch fa72/s11b-r1 in\n"
 "# SRC=worktrees/fa72-s11b, land ref land/s11b); fresh clone W=worktrees/fa72-s11b-pg2; lane clusters/s11b-s10b + run/s11b-s10b\n"
 "# (port 55649, S10-B harness literals reused); the D2-specific 8-blob / pure-addition / mode / D2-spec checks are replaced by\n"
 "# the S11-B delta (5 paths) + FREEZE-s11b checks; test/rls-g2-s10c.spec.ts is pinned to its S11-B blob 4a5a6bb6 and is RUN.\n"
 "# Runner/fixture renamed s10b-lane-pg-proof.sh / s10b-lane-fixture.sh (the fixture requires this runner name in the cmdline).\n"
 "# Full delta: DELTA-from-d2-v1.diff. Text below is the D2 v1 header.\n"
 "# S10-D D2 real-PG proof"),
("#   timeout -k 30 4500 bash /home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s10d2/binding/v1/d2-pg-proof.sh\n",
 "#   timeout -k 30 4500 bash /home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s10b-lane-v1/s10b-lane-pg-proof.sh\n"),
("D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s10d2/binding/v1   # D2 binding v1 (from s10c v6)\n",
 "D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s10b-lane-v1   # S11-B S10-B-lane binding v1 (from D2 v1)\n"),
("SRC=/home/user/workspace/worktrees/fa72-d2                                        # clone source (read-only here): branch fa72/d2-r1 at 144269d1 (rebased D2), clean, lefthook hooks\n"
 "W=/home/user/workspace/worktrees/fa72-d2-pg1 ",
 "SRC=/home/user/workspace/worktrees/fa72-s11b                                      # clone source (read-only here): branch fa72/s11b-r1 at 4d31616f (S11-B), clean, lefthook hooks\n"
 "W=/home/user/workspace/worktrees/fa72-s11b-pg2 "),
("R=$D/run; LOG=$R/d2-pg-proof.log; SENT=$R/d2-pg-proof.sentinel; JLOG=$R/jest.log\n",
 "R=$D/run; LOG=$R/s10b-lane-pg-proof.log; SENT=$R/s10b-lane-pg-proof.sentinel; JLOG=$R/jest.log\n"),
("BASE_HEAD=7fdcbc044dba1747d0db2f2750ced951f3b6b752                     # integration/importer tip after S11-A1 3db615c0 + S11-C 7fdcbc04 landed; D2 rebased onto it (parent 08:53)\n",
 "BASE_HEAD=7fdcbc044dba1747d0db2f2750ced951f3b6b752                     # integration/importer tip after S11-A1 3db615c0 + S11-C 7fdcbc04 landed (= S11-B HEAD^)\n"),
("EXPECT_HEAD=144269d13db5275a2d6689bebb2f7dca8367593c                   # D2 rebased commit on fa72/d2-r1 (8 D2 blobs = gated 6e3f86ce); PR #561\n"
 "EXPECT_TREE=a0bc3c09f82edd8fa13932913437813911d5be38                   # git rev-parse HEAD^{tree}\n",
 "EXPECT_HEAD=4d31616f9288402c0cdd6a74fb30b4b15d0658d3                   # S11-B commit on fa72/s11b-r1 (blobs = reviewed 45b4da1d); PR #562\n"
 "EXPECT_TREE=366efa9f807cf8c1550bfc8a3394b6840f90287b                   # git rev-parse HEAD^{tree}\n"),
("EXPECT_DELTA=\"src/scout/induction/sources/s10_unseen.json src/scout/reconstruct/native/sources/s10_unseen.json src/scout/reconstruct/sources/s10_unseen.json test/fixtures/scout/s10_unseen/signer-test-key.json test/fixtures/scout/s10_unseen/staged-rows.json test/fixtures/scout/s10_unseen/statements.json test/scout/s10/s10-unseen.e2e.spec.ts test/scout/s10/s10-unseen.pg.spec.ts\"   # exactly the 8 D2 paths (sorted); must equal D2_OWNED and the gate R40 `git diff --name-only`\n"
 "EXPECT_CONTRACT_STATE=unchanged                                  # D2 changes no contract (the 8 paths exclude docs/); kept as the template mechanism\n"
 "EXPECT_CONTRACT_BLOB=1a5deca500d0dd9422edaca2f9883ed57c33a0e8          # = BASE_CONTRACT_BLOB (unchanged by D2)\n"
 "EXPECT_HOOK_PRECOMMIT_SHA=54aa5cd8b77c4b8549c8d7c40bd85e5ffc6406a6018661fed4a876f7c58de3f9   # sha256 $SRC/.git/hooks/pre-commit (lefthook)\n"
 "EXPECT_HOOK_COMMITMSG_SHA=dc998a5e5776895512ee9860763444c1cb9eafa9d64e181c6cbe923c59e11be0   # sha256 $SRC/.git/hooks/commit-msg (lefthook)\n"
 "EXPECT_S10C_SPEC_BLOB=50a0deae0e9eee45ec093e87769949f47efd3d8e                                  # landed S10-C spec (BASE blob; not run here, pinned unchanged)\n"
 "# the 8 D2 path blobs at HEAD (D2 gate summary \"sha256 per path post-format\" + `git rev-parse HEAD:<path>`)\n"
 "EXPECT_D2_BLOB_INDUCTION=4e21d522772adbde19d8ee3419b30039ec250475          # src/scout/induction/sources/s10_unseen.json\n"
 "EXPECT_D2_BLOB_NATIVE=6b8695c8b7504e7623bf3b61ef686f3dd4612f9b                # src/scout/reconstruct/native/sources/s10_unseen.json\n"
 "EXPECT_D2_BLOB_MAPPING=94dcc8198c4b7a6ed27c6bfcf3a57d201effd879              # src/scout/reconstruct/sources/s10_unseen.json\n"
 "EXPECT_D2_BLOB_KEY=4d5bf92e157f7d44b5f97b92e41fd3ac4b2a88f1                      # test/fixtures/scout/s10_unseen/signer-test-key.json\n"
 "EXPECT_D2_BLOB_ROWS=94e7f5670e18f88fd7bcc8a728b537683d896f1f                    # test/fixtures/scout/s10_unseen/staged-rows.json\n"
 "EXPECT_D2_BLOB_STATEMENTS=90d644b4bbb48aec86b293d2a39eb02a670884fe        # test/fixtures/scout/s10_unseen/statements.json\n"
 "EXPECT_D2_BLOB_E2E=41df91ec0c020c16364956a2abfd9983d6f0f41c                      # test/scout/s10/s10-unseen.e2e.spec.ts\n"
 "EXPECT_D2_BLOB_PG=074b0fa0f0472be23e312ca68a9b0528c28230c5                        # test/scout/s10/s10-unseen.pg.spec.ts (the spec this run executes)\n"
 "LAND_REF=refs/remotes/origin/land/s10d2                   # only if the parent pushes a land ref (seen in SRC as refs/remotes/origin/land/s10d2)\n"
 "EXPECT_LAND_REF=144269d13db5275a2d6689bebb2f7dca8367593c   # the 40-hex $LAND_REF (refs/remotes/origin/land/s10d2) must equal (= EXPECT_HEAD)\n",
 f"EXPECT_DELTA=\"{S11B}\"   # exactly the 5 S11-B paths (sorted); must equal S11B_OWNED and FREEZE-s11b\n"
 "EXPECT_CONTRACT_STATE=unchanged                                  # S11-B changes no contract (the 5 paths exclude docs/); kept as the template mechanism\n"
 "EXPECT_CONTRACT_BLOB=1a5deca500d0dd9422edaca2f9883ed57c33a0e8          # = BASE_CONTRACT_BLOB (unchanged by S11-B)\n"
 "EXPECT_HOOK_PRECOMMIT_SHA=67e578d15a4b0d52bd517f06052efbb0e397f7d945fd5582ab639b9928e46a49   # sha256 $SRC/.git/hooks/pre-commit (lefthook)\n"
 "EXPECT_HOOK_COMMITMSG_SHA=18e15068a4c266d4499eafda9cd1d4d5180eb1e95b02939cf5a400c23260f1a9   # sha256 $SRC/.git/hooks/commit-msg (lefthook)\n"
 "EXPECT_S10C_SPEC_BLOB=4a5a6bb6c29222c5c290f3680b4f5b5bd3d209ff                                  # test/rls-g2-s10c.spec.ts at HEAD: the S11-B R36 flip (BASE blob 50a0deae); RUN here\n"
 "S11B_FREEZE=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s10b-lane-v1/FREEZE-s11b.sha256\n"
 f"S11B_FREEZE_SHA={FREEZE_SHA}   # FREEZE-s11b: sha256 of the 5 S11-B paths at HEAD (paths == delta)\n"
 "LAND_REF=refs/remotes/origin/land/s11b                    # PR #562 head, seen in SRC as refs/remotes/origin/land/s11b\n"
 "EXPECT_LAND_REF=4d31616f9288402c0cdd6a74fb30b4b15d0658d3   # the 40-hex $LAND_REF (refs/remotes/origin/land/s11b) must equal (= EXPECT_HEAD)\n"),
("FROZEN_P_BLOB=9b5de3743ec27181b58e8277591a6c8c1a8adc65          # its blob at BASE 7fdcbc04 (= at 6a33df9b; S11-A1/S11-C did not touch it; D2 does not either)\n",
 "FROZEN_P_BLOB=9b5de3743ec27181b58e8277591a6c8c1a8adc65          # its blob at BASE 7fdcbc04 (= at 6a33df9b; S11-A1/S11-C did not touch it; S11-B does not either)\n"),
("# the 8 D2 paths (execution/d3a9f701/s10d/d2.diff: 8 new 100644 files; D2_GATE_GRANT.md); EXPECT_DELTA must be exactly these\n"
 "D2_OWNED=\"src/scout/induction/sources/s10_unseen.json src/scout/reconstruct/native/sources/s10_unseen.json src/scout/reconstruct/sources/s10_unseen.json test/fixtures/scout/s10_unseen/signer-test-key.json test/fixtures/scout/s10_unseen/staged-rows.json test/fixtures/scout/s10_unseen/statements.json test/scout/s10/s10-unseen.e2e.spec.ts test/scout/s10/s10-unseen.pg.spec.ts\"\n"
 "D2_SPEC=test/scout/s10/s10-unseen.pg.spec.ts\n",
 "# the 5 S11-B paths (S11B_BINDING_BUILD_GRANT.md; reviewed 45b4da1d); EXPECT_DELTA must be exactly these\n"
 f"S11B_OWNED=\"{S11B}\"\n"),
("EXPECT_TESTS_S10B=24                                # it() count in the frozen test/rls-g2-s10b.spec.ts (re-checked at HEAD; NOT run here)\n"
 "EXPECT_TESTS_S10C=8                                 # it() count in the landed test/rls-g2-s10c.spec.ts (re-checked at HEAD; NOT run here)\n"
 "EXPECT_TESTS_D2=8                                   # it() count in test/scout/s10/s10-unseen.pg.spec.ts (R39 a-f, R41, R27 live; builder count on the pre-gate bytes 074b0fa0; re-checked at HEAD)\n"
 "EXPECT_TESTS=$EXPECT_TESTS_D2                       # 8: the one jest run must print \"Tests: 8 passed, 8 total\"\n",
 "EXPECT_TESTS_S10B=24                                # it() count in the frozen test/rls-g2-s10b.spec.ts (re-checked at HEAD; RUN here)\n"
 "EXPECT_TESTS_S10C=8                                 # it() count in test/rls-g2-s10c.spec.ts at HEAD (R36 flip is inside one of the 8; re-checked at HEAD; RUN here)\n"
 "EXPECT_TESTS=$((EXPECT_TESTS_S10B + EXPECT_TESTS_S10C))   # 32 (s10c v6): the one jest run must print \"Tests: 32 passed, 32 total\"\n"),
("LANE=$CLUSTERS/s10d2; SOCK=$RUNTIME_ROOT/run/s10d2\n", "LANE=$CLUSTERS/s11b-s10b; SOCK=$RUNTIME_ROOT/run/s11b-s10b\n"),
("FIX=$D/d2-fixture.sh\n", "FIX=$D/s10b-lane-fixture.sh\n"),
("# S10-B-harness identity (reused by the D2 spec):", "# S10-B-harness identity (used by both S10-B-lane specs):"),
("D2_BLOBS=\"$EXPECT_D2_BLOB_INDUCTION$EXPECT_D2_BLOB_NATIVE$EXPECT_D2_BLOB_MAPPING$EXPECT_D2_BLOB_KEY$EXPECT_D2_BLOB_ROWS$EXPECT_D2_BLOB_STATEMENTS$EXPECT_D2_BLOB_E2E$EXPECT_D2_BLOB_PG\"\n", ""),
("$EXPECT_NM_LOCK_SHA$D2_BLOBS$EXPECT_LAND_REF\" in *__*) log \"PRECONDITION_FAIL pins not filled (proposal stage: head, tree, D2 blobs, hooks or land ref; README.md fill table)\"",
 "$EXPECT_NM_LOCK_SHA$S11B_FREEZE_SHA$EXPECT_LAND_REF\" in *__*) log \"PRECONDITION_FAIL pins not filled (head, tree, FREEZE-s11b, hooks or land ref; README.md)\""),
("for v in BASE_HEAD BASE_TREE EXPECT_HEAD EXPECT_TREE EXPECT_CONTRACT_BLOB EXPECT_S10C_SPEC_BLOB EXPECT_D2_BLOB_INDUCTION EXPECT_D2_BLOB_NATIVE EXPECT_D2_BLOB_MAPPING EXPECT_D2_BLOB_KEY EXPECT_D2_BLOB_ROWS EXPECT_D2_BLOB_STATEMENTS EXPECT_D2_BLOB_E2E EXPECT_D2_BLOB_PG FROZEN_P_BLOB; do",
 "for v in BASE_HEAD BASE_TREE EXPECT_HEAD EXPECT_TREE EXPECT_CONTRACT_BLOB EXPECT_S10C_SPEC_BLOB FROZEN_P_BLOB; do"),
("for v in EXPECT_NM_CLIENT_SHA EXPECT_NM_CLIENT_SCHEMA_SHA EXPECT_HOOK_PRECOMMIT_SHA EXPECT_HOOK_COMMITMSG_SHA EXPECT_FIXTURE_SHA FROZEN_SHA; do",
 "for v in EXPECT_NM_CLIENT_SHA EXPECT_NM_CLIENT_SCHEMA_SHA EXPECT_HOOK_PRECOMMIT_SHA EXPECT_HOOK_COMMITMSG_SHA EXPECT_FIXTURE_SHA FROZEN_SHA S11B_FREEZE_SHA; do"),
("[ \"$LANE\" = \"$CLUSTERS/s10d2\" ] && [ \"$LANE\" != \"$S10B_LANE\" ] && [ \"$SOCK\" = \"$RUNTIME_ROOT/run/s10d2\" ] || { log \"PRECONDITION_FAIL lane $LANE / socket $SOCK is not clusters/s10d2 + run/s10d2\"; fail 70; }\n",
 "[ \"$LANE\" = \"$CLUSTERS/s11b-s10b\" ] && [ \"$LANE\" != \"$S10B_LANE\" ] && [ \"$SOCK\" = \"$RUNTIME_ROOT/run/s11b-s10b\" ] || { log \"PRECONDITION_FAIL lane $LANE / socket $SOCK is not clusters/s11b-s10b + run/s11b-s10b\"; fail 70; }\n"),
("|| { log \"PRECONDITION_FAIL harness env not bound to the s10d2 lane\"; fail 70; }\n",
 "|| { log \"PRECONDITION_FAIL harness env not bound to the s11b-s10b lane\"; fail 70; }\n"),
("WANT_DELTA=$(printf '%s\\n' $D2_OWNED $(", "WANT_DELTA=$(printf '%s\\n' $S11B_OWNED $("),
("!= the 8 D2 paths (+ contract iff changed) [$WANT_DELTA]\"; fail 70; }\n", "!= the 5 S11-B paths (+ contract iff changed) [$WANT_DELTA]\"; fail 70; }\n"),
("|| { log \"PRECONDITION_FAIL D2 changes no contract (EXPECT_CONTRACT_STATE=$EXPECT_CONTRACT_STATE)\"; fail 70; }\n",
 "|| { log \"PRECONDITION_FAIL S11-B changes no contract (EXPECT_CONTRACT_STATE=$EXPECT_CONTRACT_STATE)\"; fail 70; }\n"),
("grep -qx \"LANE=\\$RUNTIME_ROOT/clusters/s10d2\" <<<\"$FIXTXT\" && grep -qx \"DATA=\\$LANE/pg-data; LOG=\\$LANE/pg.log; SOCK=\\$RUNTIME_ROOT/run/s10d2\" <<<\"$FIXTXT\" || { log \"PRECONDITION_FAIL fixture lane/socket lines != clusters/s10d2 + run/s10d2\"; fail 70; }\n",
 "grep -qx \"LANE=\\$RUNTIME_ROOT/clusters/s11b-s10b\" <<<\"$FIXTXT\" && grep -qx \"DATA=\\$LANE/pg-data; LOG=\\$LANE/pg.log; SOCK=\\$RUNTIME_ROOT/run/s11b-s10b\" <<<\"$FIXTXT\" || { log \"PRECONDITION_FAIL fixture lane/socket lines != clusters/s11b-s10b + run/s11b-s10b\"; fail 70; }\n"),
("grep -qF 'grep -q d2-pg-proof.sh \"/proc/$D2_RUNNER_PID/cmdline\"' <<<\"$FIXTXT\" || { log \"PRECONDITION_FAIL fixture does not require the D2 runner\"; fail 70; }\n",
 "grep -qF 'grep -q s10b-lane-pg-proof.sh \"/proc/$D2_RUNNER_PID/cmdline\"' <<<\"$FIXTXT\" || { log \"PRECONDITION_FAIL fixture does not require this runner\"; fail 70; }\n"),
("[ \"$(git -C \"$SRC\" rev-parse --verify -q refs/heads/fa72/d2-r1)\" = \"$EXPECT_HEAD\" ] && [ \"$(git -C \"$SRC\" symbolic-ref -q HEAD)\" = refs/heads/fa72/d2-r1 ] || { log \"PRECONDITION_FAIL $SRC is not on fa72/d2-r1 at $EXPECT_HEAD\"; fail 70; }\n",
 "[ \"$(git -C \"$SRC\" rev-parse --verify -q refs/heads/fa72/s11b-r1)\" = \"$EXPECT_HEAD\" ] && [ \"$(git -C \"$SRC\" symbolic-ref -q HEAD)\" = refs/heads/fa72/s11b-r1 ] || { log \"PRECONDITION_FAIL $SRC is not on fa72/s11b-r1 at $EXPECT_HEAD\"; fail 70; }\n"),
("# exact delta: BASE..HEAD = the 8 D2 paths, all added as 100644 files; FROZEN S10-A/S10-B bytes at HEAD (one premise-P exception)\n",
 "# exact delta: BASE..HEAD = the 5 S11-B paths, byte-equal to FREEZE-s11b; FROZEN S10-A/S10-B bytes at HEAD (one premise-P exception)\n"),
("DADD=$(git -C \"$SRC\" diff --name-only --diff-filter=A \"$BASE_HEAD\" HEAD | sort | tr '\\n' ' ' | sed 's/ $//'); [ \"$DADD\" = \"$EXPECT_DELTA\" ] || { log \"PRECONDITION_FAIL D2 delta is not 8 pure additions [$DADD]\"; fail 70; }\n"
 "DMODES=$(git -C \"$SRC\" ls-tree HEAD -- $EXPECT_DELTA | awk '{print $1}' | sort -u); [ \"$DMODES\" = 100644 ] || { log \"PRECONDITION_FAIL D2 paths not all mode 100644 [$(echo $DMODES)]\"; fail 70; }\n"
 "for pin in \"src/scout/induction/sources/s10_unseen.json $EXPECT_D2_BLOB_INDUCTION\" \"src/scout/reconstruct/native/sources/s10_unseen.json $EXPECT_D2_BLOB_NATIVE\" \\\n"
 "           \"src/scout/reconstruct/sources/s10_unseen.json $EXPECT_D2_BLOB_MAPPING\" \"test/fixtures/scout/s10_unseen/signer-test-key.json $EXPECT_D2_BLOB_KEY\" \\\n"
 "           \"test/fixtures/scout/s10_unseen/staged-rows.json $EXPECT_D2_BLOB_ROWS\" \"test/fixtures/scout/s10_unseen/statements.json $EXPECT_D2_BLOB_STATEMENTS\" \\\n"
 "           \"test/scout/s10/s10-unseen.e2e.spec.ts $EXPECT_D2_BLOB_E2E\" \"$D2_SPEC $EXPECT_D2_BLOB_PG\"; do set -- $pin\n"
 "  [ \"$(git -C \"$SRC\" rev-parse \"HEAD:$1\")\" = \"$2\" ] || { log \"PRECONDITION_FAIL D2 path $1 blob != gate pin $2\"; fail 70; }; done\n",
 "[ -f \"$S11B_FREEZE\" ] && [ ! -L \"$S11B_FREEZE\" ] && [ \"$(sha \"$S11B_FREEZE\")\" = \"$S11B_FREEZE_SHA\" ] || { log \"PRECONDITION_FAIL FREEZE-s11b absent, a symlink or sha mismatch\"; fail 70; }\n"
 "BFILES=$(awk '{print $2}' \"$S11B_FREEZE\" | sort | tr '\\n' ' ' | sed 's/ $//'); [ \"$BFILES\" = \"$EXPECT_DELTA\" ] || { log \"PRECONDITION_FAIL FREEZE-s11b paths [$BFILES] != delta\"; fail 70; }\n"
 "while read -r s p; do GOT=$(git -C \"$SRC\" show \"HEAD:$p\" | sha256sum | cut -c1-64); [ \"$GOT\" = \"$s\" ] || { log \"PRECONDITION_FAIL $p at HEAD != FREEZE-s11b\"; fail 70; }; done < \"$S11B_FREEZE\"\n"),
("|| { log \"PRECONDITION_FAIL prisma / dependency manifests differ from base (D2 changes no prisma)\"; fail 70; }\n",
 "|| { log \"PRECONDITION_FAIL prisma / dependency manifests differ from base (S11-B changes no prisma)\"; fail 70; }\n"),
("  && SPEC_C_AT_HEAD=$(git -C \"$SRC\" show HEAD:test/rls-g2-s10c.spec.ts) && SPEC_D2_AT_HEAD=$(git -C \"$SRC\" show \"HEAD:$D2_SPEC\") || {",
 "  && SPEC_C_AT_HEAD=$(git -C \"$SRC\" show HEAD:test/rls-g2-s10c.spec.ts) || {"),
("# the D2 spec (the ONLY spec this run executes): pinned it() count; the ONLY skip allowed is the file-level env switch in its\n"
 "# pinned live form (LIVE iff G2_S10B_DATABASE_URL is a string, which this runner exports); no other skip/only/todo/each\n"
 "NTD=$(grep -cE '^\\s*it\\(' <<<\"$SPEC_D2_AT_HEAD\" || true); [ \"$NTD\" = \"$EXPECT_TESTS_D2\" ] || { log \"PRECONDITION_FAIL it() count in committed $D2_SPEC $NTD != $EXPECT_TESTS_D2\"; fail 70; }\n"
 "D2_LIVE_LINE=\"const LIVE = typeof process.env.G2_S10B_DATABASE_URL === 'string';\"; D2_SUITE_LINE='const suite = LIVE ? describe : describe.skip;'\n"
 "[ \"$(grep -cxF \"$D2_LIVE_LINE\" <<<\"$SPEC_D2_AT_HEAD\" || true)\" = 1 ] && [ \"$(grep -cxF \"$D2_SUITE_LINE\" <<<\"$SPEC_D2_AT_HEAD\" || true)\" = 1 ] \\\n"
 "  && [ \"$(grep -cE '^suite\\(' <<<\"$SPEC_D2_AT_HEAD\" || true)\" = 1 ] && [ \"$(grep -cF 'LIVE' <<<\"$SPEC_D2_AT_HEAD\" || true)\" = 2 ] || { log \"PRECONDITION_FAIL $D2_SPEC env switch is not the pinned live form (LIVE line, suite line, one suite( block)\"; fail 70; }\n"
 "SPEC_D2_REST=$(grep -vxF \"$D2_SUITE_LINE\" <<<\"$SPEC_D2_AT_HEAD\" | grep -vE '^\\s*(\\*|//|/\\*)' || true)   # comment lines excluded (the header prose names `describe.skip`)\n"
 "[ \"$(grep -cE '^\\s*test\\(' <<<\"$SPEC_D2_AT_HEAD\" || true)\" = 0 ] || { log \"PRECONDITION_FAIL $D2_SPEC has test( cases outside the pinned it() count\"; fail 70; }\n"
 "! grep -qE '\\b(it|describe|test|suite)\\.(skip|only|todo|each|concurrent|failing)\\b|\\b(xit|fit|xtest|xdescribe|fdescribe)\\(' <<<\"$SPEC_D2_REST\" || { log \"PRECONDITION_FAIL $D2_SPEC carries skip/only/todo/each beyond the pinned env switch\"; fail 70; }\n"
 "grep -qF \"require('../../utils/g2-s10b-pg-harness')\" <<<\"$SPEC_D2_AT_HEAD\" && grep -qF \"require('../../utils/g2-s10b-harness')\" <<<\"$SPEC_D2_AT_HEAD\" \\\n"
 "  && ! grep -qE \"g2-s10c-|G2_S10C_|g2-s10d|G2_S10D|g2-s11-|G2_S11_\" <<<\"$SPEC_D2_AT_HEAD\" || { log \"PRECONDITION_FAIL $D2_SPEC does not reuse the S10-B lane by import (or references another harness)\"; fail 70; }\n",
 ""),
("|| { log \"PRECONDITION_FAIL test/rls-g2-s10c.spec.ts blob != landed $EXPECT_S10C_SPEC_BLOB\"; fail 70; }\n",
 "|| { log \"PRECONDITION_FAIL test/rls-g2-s10c.spec.ts blob != S11-B R36-flip blob $EXPECT_S10C_SPEC_BLOB\"; fail 70; }\n"),
("# the committed head must have been produced through the tracked lefthook hooks of the clone source (the D2 gate commits in $SRC)\n",
 "# the committed head must have been produced through the tracked lefthook hooks of the clone source (the S11-B builder committed in $SRC)\n"),
("!= D2 gate pins ($EXPECT_HOOK_PRECOMMIT_SHA / $EXPECT_HOOK_COMMITMSG_SHA)\"", "!= S11-B source pins ($EXPECT_HOOK_PRECOMMIT_SHA / $EXPECT_HOOK_COMMITMSG_SHA)\""),
("# S10-C wiring (landed in BASE; the D2 chain needs it): ScoutModule imports ObservationModule at HEAD\n",
 "# S10-C wiring (landed in BASE; the S10-C spec needs it): ScoutModule imports ObservationModule at HEAD\n"),
("  && [ \"$(git -C \"$SRC\" rev-parse --verify -q refs/heads/fa72/d2-r1)\" = \"$EXPECT_HEAD\" ] && {",
 "  && [ \"$(git -C \"$SRC\" rev-parse --verify -q refs/heads/fa72/s11b-r1)\" = \"$EXPECT_HEAD\" ] && [ \"$(sha \"$S11B_FREEZE\")\" = \"$S11B_FREEZE_SHA\" ] && {"),
("  || { log \"PRECONDITION_FAIL fixture/source HEAD/source worktree/land ref/donor client/clone path moved after the pre-lock preconditions\"; fail 70; }\n",
 "  || { log \"PRECONDITION_FAIL fixture/source HEAD/source worktree/FREEZE-s11b/land ref/donor client/clone path moved after the pre-lock preconditions\"; fail 70; }\n"),
("# ---- step 1 preflight (read-only): s10d2 lane absent;", "# ---- step 1 preflight (read-only): s11b-s10b lane absent;"),
("#      incl. clusters/s11 if the S11 binding ran, and proof-*/clusters/*)", "#      incl. clusters/s11 and clusters/s10d2 if present, and proof-*/clusters/*)"),
("LOG=$R/d2-pg-proof.log\nfinish(){ local rc=$1\n  ( cd \"$R\" && sha256sum d2-pg-proof.log prelock.log",
 "LOG=$R/s10b-lane-pg-proof.log\nfinish(){ local rc=$1\n  ( cd \"$R\" && sha256sum s10b-lane-pg-proof.log prelock.log"),
("STAGE=jest; log \"JEST_START $(ts) cmd='./node_modules/.bin/jest -c jest.config.js --runInBand --ci --runTestsByPath $D2_SPEC' candidate_head=$G2_S10B_CANDIDATE_HEAD expect_tests=$EXPECT_TESTS_D2\"\n"
 "( cd \"$W\" && timeout -k 30 1500 ./node_modules/.bin/jest -c jest.config.js --runInBand --ci --runTestsByPath \"$D2_SPEC\" ) >\"$JLOG\" 2>&1; JRC=$?\n",
 "STAGE=jest; log \"JEST_START $(ts) cmd='./node_modules/.bin/jest -c jest.rls.config.js --runInBand --ci test/rls-g2-s10b.spec.ts test/rls-g2-s10c.spec.ts' candidate_head=$G2_S10B_CANDIDATE_HEAD expect_tests=$EXPECT_TESTS_S10B+$EXPECT_TESTS_S10C\"\n"
 "( cd \"$W\" && timeout -k 30 1500 ./node_modules/.bin/jest -c jest.rls.config.js --runInBand --ci test/rls-g2-s10b.spec.ts test/rls-g2-s10c.spec.ts ) >\"$JLOG\" 2>&1; JRC=$?\n"),
("grep -qE \"^Test Suites: +1 passed, 1 total\" \"$JLOG\" || { log \"JEST_COUNT_FAIL expected 'Test Suites: 1 passed, 1 total' (got: $(grep -E '^Test Suites:' \"$JLOG\" | head -1))\"; fail 72; }\n"
 "JP=$(grep -E '^PASS ' \"$JLOG\" | grep -oE 'test/[^ ]+\\.spec\\.ts' | sort | tr '\\n' ' ')   # jest.config.js has no displayName; the parser tolerates one\n"
 "[ \"$JP\" = \"$D2_SPEC \" ] || { log \"JEST_COUNT_FAIL PASS lines [$JP] != the D2 spec\"; fail 72; }\n"
 "log \"JEST_COUNT_OK tests=$EXPECT_TESTS (d2=$EXPECT_TESTS_D2 pinned at HEAD) suites=1\"\n",
 "grep -qE \"^Test Suites: +2 passed, 2 total\" \"$JLOG\" || { log \"JEST_COUNT_FAIL expected 'Test Suites: 2 passed, 2 total' (got: $(grep -E '^Test Suites:' \"$JLOG\" | head -1))\"; fail 72; }\n"
 "JP=$(grep -E '^PASS ' \"$JLOG\" | grep -oE 'test/[^ ]+\\.spec\\.ts' | sort | tr '\\n' ' ')   # v5: jest.rls.config.js displayName (rls-live) precedes the path\n"
 "[ \"$JP\" = \"test/rls-g2-s10b.spec.ts test/rls-g2-s10c.spec.ts \" ] || { log \"JEST_COUNT_FAIL PASS lines [$JP] != the two specs\"; fail 72; }\n"
 "log \"JEST_COUNT_OK tests=$EXPECT_TESTS (s10b=$EXPECT_TESTS_S10B + s10c=$EXPECT_TESTS_S10C pinned at HEAD) suites=2\"\n"),
("data dir RETAINED (destroy only via separate grant: d2-fixture.sh destroy)", "data dir RETAINED (destroy only via separate grant: s10b-lane-fixture.sh destroy)"),
])
rn = apply(rn, [(
 "EXPECT_FIXTURE_SHA=0fadafa36ff77dbf5621315d5ffca54bc4a57d2a7d8dc0328532798fcea5c24b                                             # sha256 of binding/v1/d2-fixture.sh (builder-filled; README.md)\n",
 f"EXPECT_FIXTURE_SHA={FIX_SHA}                                             # sha256 of s10b-lane-v1/s10b-lane-fixture.sh (builder-filled; README.md)\n")])
out = OD / 's10b-lane-pg-proof.sh'
out.write_text(rn); out.chmod(0o755)
print('fixture', FIX_SHA, len(fx.splitlines()), 'lines; runner', len(rn.splitlines()), 'lines')
