#!/usr/bin/env python3
# Builds s11-lane-v2/s11-pg-proof.sh from the reviewed-GO s11-lane-v1 runner by exact, count-asserted substitutions
# (T3 builder; source only). Every (old, new, n) must match exactly n times in the v1 bytes. argv[1] = FREEZE-s11b v2 sha256.
import pathlib, sys
BD = '/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding'
T = pathlib.Path(BD + '/s11-lane-v1/s11-pg-proof.sh')
O = pathlib.Path(BD + '/s11-lane-v2/s11-pg-proof.sh')
s = T.read_text()
FREEZE_SHA = sys.argv[1]
assert len(FREEZE_SHA) == 64
OLD5 = ('src/scout/lifecycle/lifecycle.service.ts src/scout/scout.service.ts test/rls-g2-s10c.spec.ts '
        'test/scout/lifecycle/s11b-settle-redrive.spec.ts test/scout/s11/settle-redrive.pg.spec.ts')
NEW6 = ('src/scout/lifecycle/lifecycle.service.ts src/scout/scout.service.ts test/rls-g2-s10c.spec.ts '
        'test/scout/lifecycle/lifecycle.service.spec.ts test/scout/lifecycle/s11b-settle-redrive.spec.ts '
        'test/scout/s11/settle-redrive.pg.spec.ts')
subs = [
# ---- header: new v2 paragraph on top; v1 text below stays as history
("#!/usr/bin/env bash\n# EXEC-FA72EFB2 S11-B S11-lane binding v1 —",
 "#!/usr/bin/env bash\n"
 "# EXEC-FA72EFB2 S11-B S11-lane binding v2 — minimum substitution of the reviewed-GO s11-lane-v1 runner (sha256 ef0024b2…ef36a;\n"
 "# its run failed only on candidate J13, PROOF_A_V1_FINDING.md) to the r2 candidate REBASED onto the D2 landing (parent redirect\n"
 "# 17:07Z): base 275e458c (= integration/importer after S10-D D2 landed), chain 275e458c -> 645fb6db (= 4d31616f re-applied)\n"
 "# -> dda794d7 (= 9149f823 re-applied; 6 delta blobs byte-identical), branch fa72/s11b-r2, land ref land/s11b-r2 (PR #563).\n"
 "# Changes: two-commit chain check (HEAD^ = R1_HEAD, HEAD^^ = BASE, count 2) + r1->r2 diff check (exactly lifecycle.service.ts +\n"
 "# lifecycle.service.spec.ts), delta 6 paths (+ test/scout/lifecycle/lifecycle.service.spec.ts), FREEZE-s11b regenerated for the\n"
 "# 6 paths, EXPECT_LIFECYCLE_BLOB a4a79648, fresh clone worktrees/fa72-s11b-pg3. Stages, counts, bounds (outer 10200) unchanged.\n"
 "# Full delta: DELTA-from-v1.diff. Text below is s11-lane v1.\n"
 "# EXEC-FA72EFB2 S11-B S11-lane binding v1 —", 1),
("# Usage (under the separate single-run PG grant): timeout -k 30 10200 bash .../fa72efb2/s11b/binding/s11-lane-v1/s11-pg-proof.sh\n",
 "# Usage (under the separate single-run PG grant): timeout -k 30 10200 bash .../fa72efb2/s11b/binding/s11-lane-v2/s11-pg-proof.sh\n", 1),
("D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s11-lane-v1\n",
 "D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s11-lane-v2\n", 1),
("# clone source (read-only here): HEAD 4d31616f (= origin/land/s11b), clean, lefthook hooks\n",
 "# clone source (read-only here): HEAD dda794d7 (= origin/land/s11b-r2, branch fa72/s11b-r2), clean, lefthook hooks\n", 1),
("W=/home/user/workspace/worktrees/fa72-s11b-pg1 ",
 "W=/home/user/workspace/worktrees/fa72-s11b-pg3 ", 1),
("BASE_HEAD=7fdcbc044dba1747d0db2f2750ced951f3b6b752                               # integration/importer tip after S11-C landed (= HEAD^)\n",
 "BASE_HEAD=275e458ca5a6b3684bb6ec83edb2a854056a6fd0                               # integration/importer tip after S10-D D2 landed (= HEAD^^)\n", 1),
("BASE_TREE=a802231ee1f4dd693284b349e7eb078b3688e8d5\n",
 "BASE_TREE=6267ef6a57225af187f5a21fb8a2c3cc3fd6103e\n", 1),
("EXPECT_HEAD=4d31616f9288402c0cdd6a74fb30b4b15d0658d3                             # S11-B candidate (settle re-drive), one commit on BASE_HEAD (PR #562)\n"
 "EXPECT_TREE=366efa9f807cf8c1550bfc8a3394b6840f90287b\n"
 "LAND_REF=refs/remotes/origin/land/s11b\n",
 "EXPECT_HEAD=dda794d7e8bee0482a7ad373795fcc51dcf54bb5                             # S11-B r2 candidate (= 9149f823 re-applied), two commits on BASE_HEAD (PR #563)\n"
 "EXPECT_TREE=802e1c196c7a0bd27f091218407f5f0b031dd760\n"
 "R1_HEAD=645fb6db022f2ef6299ed4aa2bcd3f409d2a8298                                 # S11-B r1 (= 4d31616f re-applied) = HEAD^, parent BASE_HEAD\n"
 "R1R2_DELTA=\"src/scout/lifecycle/lifecycle.service.ts test/scout/lifecycle/lifecycle.service.spec.ts\"   # R1_HEAD..HEAD (the r2 fix), exactly\n"
 "LAND_REF=refs/remotes/origin/land/s11b-r2\n", 1),
("EXPECT_LIFECYCLE_BLOB=974e2c831c1c963c4bf1b68381af48136cf78266                    # src/scout/lifecycle/lifecycle.service.ts (S11-B)\n",
 "EXPECT_LIFECYCLE_BLOB=a4a79648b911a6099972f80a13f24837e630cbd7                    # src/scout/lifecycle/lifecycle.service.ts (S11-B r2)\n", 1),
("S11B_FREEZE=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s11-lane-v1/FREEZE-s11b.sha256\n"
 "S11B_FREEZE_SHA=ca321526e5363ba553dce66f70f3674b18579962cbe926428916cc03ce6424f4       # FREEZE-s11b: the 5 S11-B paths at HEAD (paths == delta)\n",
 "S11B_FREEZE=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s11-lane-v2/FREEZE-s11b.sha256\n"
 "S11B_FREEZE_SHA=" + FREEZE_SHA + "       # FREEZE-s11b v2: the 6 S11-B paths at HEAD (paths == delta)\n", 1),
('EXPECT_DELTA="' + OLD5 + '"\n', 'EXPECT_DELTA="' + NEW6 + '"\n', 1),
# pins-not-filled guard also covers the new R1_HEAD pin
('$EXPECT_HEAD$EXPECT_TREE$EXPECT_MIGRATIONS_TREE', '$EXPECT_HEAD$EXPECT_TREE$R1_HEAD$EXPECT_MIGRATIONS_TREE', 1),
# pre-lock chain check: two commits on BASE, r1 -> r2 exactly the two lifecycle files
("# clone source: committed candidate, one commit on BASE, pushed, clean, produced through the tracked lefthook hooks\n",
 "# clone source: committed candidate, two commits on BASE (r1, r2), pushed, clean, produced through the tracked lefthook hooks\n", 1),
('[ "$(g rev-parse HEAD^)" = "$BASE_HEAD" ] || { log "PRECONDITION_FAIL HEAD^ != $BASE_HEAD"; fail 70; }\n',
 '[ "$(g rev-parse HEAD^)" = "$R1_HEAD" ] && [ "$(g rev-parse HEAD^^)" = "$BASE_HEAD" ] && [ "$(g rev-list --count "$BASE_HEAD..HEAD")" = 2 ] || { log "PRECONDITION_FAIL chain != $BASE_HEAD -> $R1_HEAD -> HEAD (two commits)"; fail 70; }\n'
 '[ "$(g diff --name-only "$R1_HEAD" HEAD | sort | tr \'\\n\' \' \' | sed \'s/ $//\')" = "$R1R2_DELTA" ] || { log "PRECONDITION_FAIL r1..r2 delta != [$R1R2_DELTA]"; fail 70; }\n', 1),
('!= the 5 S11-B paths"; fail 70; }', '!= the 6 S11-B paths"; fail 70; }', 1),
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
print('OK', len(subs), 'substitutions')
