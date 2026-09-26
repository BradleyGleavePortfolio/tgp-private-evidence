#!/usr/bin/env python3
# Builds s10b-lane-v2/s10b-lane-pg-proof.sh from the reviewed-GO s10b-lane-v1 runner by exact, count-asserted substitutions
# (T3 builder; source only). Every (old, new, n) must match exactly n times in the v1 bytes. argv[1] = FREEZE-s11b v2 sha256.
# The fixture is a byte copy of s10b-lane-v1/s10b-lane-fixture.sh, so EXPECT_FIXTURE_SHA is unchanged (asserted below).
import pathlib, sys, hashlib
BD = '/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding'
T = pathlib.Path(BD + '/s10b-lane-v1/s10b-lane-pg-proof.sh')
O = pathlib.Path(BD + '/s10b-lane-v2/s10b-lane-pg-proof.sh')
FIX = pathlib.Path(BD + '/s10b-lane-v2/s10b-lane-fixture.sh')
s = T.read_text()
FREEZE_SHA = sys.argv[1]
assert len(FREEZE_SHA) == 64
FIX_SHA = hashlib.sha256(FIX.read_bytes()).hexdigest()
assert FIX_SHA == '2fc8012dea542751228a9b1b98e6367fa40cd3d5849e73bcd6f2019147a5db2a', FIX_SHA
assert s.count('EXPECT_FIXTURE_SHA=' + FIX_SHA) == 1
OLD5 = ('src/scout/lifecycle/lifecycle.service.ts src/scout/scout.service.ts test/rls-g2-s10c.spec.ts '
        'test/scout/lifecycle/s11b-settle-redrive.spec.ts test/scout/s11/settle-redrive.pg.spec.ts')
NEW6 = ('src/scout/lifecycle/lifecycle.service.ts src/scout/scout.service.ts test/rls-g2-s10c.spec.ts '
        'test/scout/lifecycle/lifecycle.service.spec.ts test/scout/lifecycle/s11b-settle-redrive.spec.ts '
        'test/scout/s11/settle-redrive.pg.spec.ts')
subs = [
("#!/usr/bin/env bash\n# EXEC-FA72EFB2 S11-B S10-B-lane binding v1 (the R36 flip in test/rls-g2-s10c.spec.ts). SOURCE ONLY: NOT RUN.\n",
 "#!/usr/bin/env bash\n"
 "# EXEC-FA72EFB2 S11-B S10-B-lane binding v2 (the R36 flip in test/rls-g2-s10c.spec.ts). SOURCE ONLY: NOT RUN.\n"
 "# Minimum substitution of the reviewed-GO s10b-lane-v1 runner (sha256 2a5c5d19…2a3b; never ran) to the r2 candidate REBASED\n"
 "# onto the D2 landing (parent redirect 17:07Z): base 275e458c (= integration/importer after S10-D D2 landed), chain\n"
 "# 275e458c -> 645fb6db (= 4d31616f re-applied) -> dda794d7 (= 9149f823 re-applied; 6 delta blobs byte-identical), branch\n"
 "# fa72/s11b-r2, land ref land/s11b-r2 (PR #563). Changes: two-commit chain check (HEAD^ = R1_HEAD, HEAD^^ = BASE, count 2) +\n"
 "# r1->r2 diff check (exactly lifecycle.service.ts + lifecycle.service.spec.ts), delta/S11B_OWNED 6 paths (+ test/scout/lifecycle/\n"
 "# lifecycle.service.spec.ts), FREEZE-s11b regenerated for the 6 paths. Fixture byte-identical to v1; lane, W (fa72-s11b-pg2),\n"
 "# jest command, 32 / 2 suites and bounds (outer 4500) unchanged. Full delta: DELTA-from-v1.diff. Text below is s10b-lane v1.\n"
 "# EXEC-FA72EFB2 S11-B S10-B-lane binding v1 (the R36 flip in test/rls-g2-s10c.spec.ts). SOURCE ONLY: NOT RUN.\n", 1),
("fa72efb2/s11b/binding/s10b-lane-v1/s10b-lane-pg-proof.sh\n", "fa72efb2/s11b/binding/s10b-lane-v2/s10b-lane-pg-proof.sh\n", 1),
("D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s10b-lane-v1   # S11-B S10-B-lane binding v1 (from D2 v1)\n",
 "D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s10b-lane-v2   # S11-B S10-B-lane binding v2 (from s10b-lane v1)\n", 1),
("# clone source (read-only here): branch fa72/s11b-r1 at 4d31616f (S11-B), clean, lefthook hooks\n",
 "# clone source (read-only here): branch fa72/s11b-r2 at dda794d7 (S11-B r2 on D2), clean, lefthook hooks\n", 1),
("BASE_HEAD=7fdcbc044dba1747d0db2f2750ced951f3b6b752                     # integration/importer tip after S11-A1 3db615c0 + S11-C 7fdcbc04 landed (= S11-B HEAD^)\n"
 "BASE_TREE=a802231ee1f4dd693284b349e7eb078b3688e8d5 ",
 "BASE_HEAD=275e458ca5a6b3684bb6ec83edb2a854056a6fd0                     # integration/importer tip after S11-A1 3db615c0 + S11-C 7fdcbc04 + S10-D D2 275e458c landed (= S11-B r2 HEAD^^)\n"
 "BASE_TREE=6267ef6a57225af187f5a21fb8a2c3cc3fd6103e ", 1),
("EXPECT_HEAD=4d31616f9288402c0cdd6a74fb30b4b15d0658d3                   # S11-B commit on fa72/s11b-r1 (blobs = reviewed 45b4da1d); PR #562\n"
 "EXPECT_TREE=366efa9f807cf8c1550bfc8a3394b6840f90287b                   # git rev-parse HEAD^{tree}\n",
 "EXPECT_HEAD=dda794d7e8bee0482a7ad373795fcc51dcf54bb5                   # S11-B r2 commit on fa72/s11b-r2 (= 9149f823 re-applied); PR #563\n"
 "EXPECT_TREE=802e1c196c7a0bd27f091218407f5f0b031dd760                   # git rev-parse HEAD^{tree}\n"
 "R1_HEAD=645fb6db022f2ef6299ed4aa2bcd3f409d2a8298                       # S11-B r1 (= 4d31616f re-applied) = HEAD^, parent BASE_HEAD\n"
 "R1R2_DELTA=\"src/scout/lifecycle/lifecycle.service.ts test/scout/lifecycle/lifecycle.service.spec.ts\"   # R1_HEAD..HEAD (the r2 fix), exactly\n", 1),
('EXPECT_DELTA="' + OLD5 + '"   # exactly the 5 S11-B paths',
 'EXPECT_DELTA="' + NEW6 + '"   # exactly the 6 S11-B paths', 1),
("S11B_FREEZE=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s10b-lane-v1/FREEZE-s11b.sha256\n"
 "S11B_FREEZE_SHA=ca321526e5363ba553dce66f70f3674b18579962cbe926428916cc03ce6424f4   # FREEZE-s11b: sha256 of the 5 S11-B paths at HEAD (paths == delta)\n",
 "S11B_FREEZE=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s10b-lane-v2/FREEZE-s11b.sha256\n"
 "S11B_FREEZE_SHA=" + FREEZE_SHA + "   # FREEZE-s11b v2: sha256 of the 6 S11-B paths at HEAD (paths == delta)\n", 1),
("LAND_REF=refs/remotes/origin/land/s11b                    # PR #562 head, seen in SRC as refs/remotes/origin/land/s11b\n"
 "EXPECT_LAND_REF=4d31616f9288402c0cdd6a74fb30b4b15d0658d3   # the 40-hex $LAND_REF (refs/remotes/origin/land/s11b) must equal (= EXPECT_HEAD)\n",
 "LAND_REF=refs/remotes/origin/land/s11b-r2                 # PR #563 head, seen in SRC as refs/remotes/origin/land/s11b-r2\n"
 "EXPECT_LAND_REF=dda794d7e8bee0482a7ad373795fcc51dcf54bb5   # the 40-hex $LAND_REF (refs/remotes/origin/land/s11b-r2) must equal (= EXPECT_HEAD)\n", 1),
("# importer contract blob at BASE 7fdcbc04 (S11-C changed it from bd715150)\n",
 "# importer contract blob at BASE 275e458c (= at 7fdcbc04; S11-C changed it from bd715150; D2 did not touch it)\n", 1),
("# its blob at BASE 7fdcbc04 (= at 6a33df9b; S11-A1/S11-C did not touch it; S11-B does not either)\n",
 "# its blob at BASE 275e458c (= at 7fdcbc04 / 6a33df9b; S11-A1/S11-C/D2 did not touch it; S11-B does not either)\n", 1),
("# the 5 S11-B paths (S11B_BINDING_BUILD_GRANT.md; reviewed 45b4da1d); EXPECT_DELTA must be exactly these\n"
 'S11B_OWNED="' + OLD5 + '"\n',
 "# the 6 S11-B r2 paths (S11B_BINDING_V2_BUILD_GRANT.md; r1 reviewed 45b4da1d, r2 delta review GO s11b_r2_review.md); EXPECT_DELTA must be exactly these\n"
 'S11B_OWNED="' + NEW6 + '"\n', 1),
# pins-not-filled / 40-hex guards also cover R1_HEAD
('$EXPECT_HEAD$EXPECT_TREE$EXPECT_DELTA', '$EXPECT_HEAD$EXPECT_TREE$R1_HEAD$EXPECT_DELTA', 1),
('for v in BASE_HEAD BASE_TREE EXPECT_HEAD EXPECT_TREE EXPECT_CONTRACT_BLOB', 'for v in BASE_HEAD BASE_TREE EXPECT_HEAD EXPECT_TREE R1_HEAD EXPECT_CONTRACT_BLOB', 1),
("!= the 5 S11-B paths (+ contract iff changed)", "!= the 6 S11-B paths (+ contract iff changed)", 1),
# branch: fa72/s11b-r1 -> fa72/s11b-r2 (pre-lock ref + symbolic-ref + message; under-lock ref)
("refs/heads/fa72/s11b-r1", "refs/heads/fa72/s11b-r2", 3),
("is not on fa72/s11b-r1 at $EXPECT_HEAD", "is not on fa72/s11b-r2 at $EXPECT_HEAD", 1),
# chain: two commits on BASE, r1 -> r2 exactly the two lifecycle files
('[ "$(git -C "$SRC" rev-parse HEAD^)" = "$BASE_HEAD" ] && [ "$(git -C "$SRC" rev-list --count "$BASE_HEAD..HEAD")" = 1 ] || { log "PRECONDITION_FAIL HEAD^ != $BASE_HEAD (the gate makes exactly one commit on BASE)"; fail 70; }\n',
 '[ "$(git -C "$SRC" rev-parse HEAD^)" = "$R1_HEAD" ] && [ "$(git -C "$SRC" rev-parse HEAD^^)" = "$BASE_HEAD" ] && [ "$(git -C "$SRC" rev-list --count "$BASE_HEAD..HEAD")" = 2 ] || { log "PRECONDITION_FAIL chain != $BASE_HEAD -> $R1_HEAD -> HEAD (two commits on BASE)"; fail 70; }\n'
 '[ "$(git -C "$SRC" diff --name-only "$R1_HEAD" HEAD | sort | tr \'\\n\' \' \' | sed \'s/ $//\')" = "$R1R2_DELTA" ] || { log "PRECONDITION_FAIL r1..r2 delta != [$R1R2_DELTA]"; fail 70; }\n', 1),
("# exact delta: BASE..HEAD = the 5 S11-B paths,", "# exact delta: BASE..HEAD = the 6 S11-B paths,", 1),
# fresh-clone parent check follows the chain
('[ "$(git -C "$W" rev-parse HEAD^)" = "$BASE_HEAD" ] \\\n',
 '[ "$(git -C "$W" rev-parse HEAD^)" = "$R1_HEAD" ] && [ "$(git -C "$W" rev-parse HEAD^^)" = "$BASE_HEAD" ] \\\n', 1),
]
for old, new, n in subs:
    c = s.count(old)
    assert c == n, (c, n, old[:120])
    s = s.replace(old, new)
O.write_text(s)
O.chmod(0o755)
print('OK', len(subs), 'substitutions; fixture sha', FIX_SHA)
