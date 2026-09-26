#!/usr/bin/env python3
# Builds s11a2/binding/v2/s11-pg-proof.sh + launch-when-free.sh from s11a2/binding/v1 (consumed; FAILED at jest-rls on the
# candidate harness defect, PROOF_V1_FINDING.md) by exact, count-asserted substitutions (T3 builder; source only).
# argv[1] = sha256 of s11a2/binding/v2/FREEZE-s11a2.sha256.
import pathlib, sys
BD = '/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11a2/binding'
T = pathlib.Path(BD + '/v1/s11-pg-proof.sh'); O = pathlib.Path(BD + '/v2/s11-pg-proof.sh')
TL = pathlib.Path(BD + '/v1/launch-when-free.sh'); OL = pathlib.Path(BD + '/v2/launch-when-free.sh')
s = T.read_text()
FREEZE_SHA = sys.argv[1]
assert len(FREEZE_SHA) == 64
subs = [
("#!/usr/bin/env bash\n# EXEC-FA72EFB2 S11-A2 binding v1 —",
 "#!/usr/bin/env bash\n"
 "# EXEC-FA72EFB2 S11-A2 binding v2 — minimum substitution of s11a2/binding/v1 (sha256 7da3029f…3af6; its run was consumed and\n"
 "# FAILED at jest-rls on a candidate harness defect, s11a2/PROOF_V1_FINDING.md) to the r2 candidate: chain dda794d7 -> 03e7a234 (r1)\n"
 "# -> 54be96f1 (r2: resetData drops the direct DELETEs on the three S10-B insert-only tables; cascade only), tree 435fec78.\n"
 "# Changes: two-commit chain check (HEAD^ = R1_HEAD, HEAD^^ = BASE, count 2) + r1->r2 diff check (exactly test/utils/g2-s11-harness.ts),\n"
 "# EXPECT_HARNESS_BLOB 927d7365, FREEZE-s11a2 regenerated at HEAD (11 lines unchanged + harness 502c97c9), fresh clone\n"
 "# worktrees/fa72-s11a2-pg2, own dir/run. Delta (12 paths), other freezes/pins, stages, counts and bounds (outer 13500) unchanged.\n"
 "# Full delta: DELTA-from-v1.diff. Text below is s11a2 v1.\n"
 "# EXEC-FA72EFB2 S11-A2 binding v1 —", 1),
("# Usage (under the separate single-run PG grant): timeout -k 30 13500 bash .../fa72efb2/s11a2/binding/v1/s11-pg-proof.sh\n",
 "# Usage (under the separate single-run PG grant): timeout -k 30 13500 bash .../fa72efb2/s11a2/binding/v2/s11-pg-proof.sh\n", 1),
("D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11a2/binding/v1\n",
 "D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11a2/binding/v2\n", 1),
("# clone source (read-only here): HEAD 03e7a234 (= origin/land/s11a2, branch fa72/s11a2), clean, lefthook hooks\n",
 "# clone source (read-only here): HEAD 54be96f1 (= origin/land/s11a2, branch fa72/s11a2), clean, lefthook hooks\n", 1),
("W=/home/user/workspace/worktrees/fa72-s11a2-pg1 ", "W=/home/user/workspace/worktrees/fa72-s11a2-pg2 ", 1),
("; = 275e458c + 2 S11-B commits) (= HEAD^)\n", "; = 275e458c + 2 S11-B commits) (= HEAD^^)\n", 1),
("EXPECT_HEAD=03e7a2344ef95b019c751983527bbc9f78200921                             # S11-A2 candidate (two-source induction J09-J11), ONE commit on BASE_HEAD\n"
 "EXPECT_TREE=738b711610a570357136ad8e8eb1be176d406c51\n",
 "EXPECT_HEAD=54be96f18c314cae35d1e5d3000af9f06d693d81                             # S11-A2 r2 candidate (resetData cascade-only fix), two commits on BASE_HEAD\n"
 "EXPECT_TREE=435fec782672214c7e8e81b2eb91f8f9266331b4\n"
 "R1_HEAD=03e7a2344ef95b019c751983527bbc9f78200921                                 # S11-A2 r1 (binding v1 candidate) = HEAD^, parent BASE_HEAD\n"
 "R1R2_DELTA=\"test/utils/g2-s11-harness.ts\"   # R1_HEAD..HEAD (the r2 fix), exactly\n", 1),
("EXPECT_HARNESS_BLOB=1b66137a3a59b3bf396660cbc5606f4de444831e                      # test/utils/g2-s11-harness.ts (S11-A2 edit)\n",
 "EXPECT_HARNESS_BLOB=927d73655c586a188556353a59fa1c5939cae09a                      # test/utils/g2-s11-harness.ts (S11-A2 r2 edit)\n", 1),
("S11A2_FREEZE=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11a2/binding/v1/FREEZE-s11a2.sha256\n",
 "S11A2_FREEZE=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11a2/binding/v2/FREEZE-s11a2.sha256\n", 1),
("S11A2_FREEZE_SHA=a73f921125e64a0a21df765c0f9c439f19066ef74bc78b471af3b55552481b59      # FREEZE-s11a2: the 12 S11-A2 paths at HEAD (paths == delta)\n",
 "S11A2_FREEZE_SHA=" + FREEZE_SHA + "      # FREEZE-s11a2 v2: the 12 S11-A2 paths at HEAD r2 (paths == delta)\n", 1),
('$EXPECT_HEAD$EXPECT_TREE$EXPECT_MIGRATIONS_TREE', '$EXPECT_HEAD$EXPECT_TREE$R1_HEAD$EXPECT_MIGRATIONS_TREE', 1),
("# clone source: committed candidate, ONE commit on BASE, pushed, clean, produced through the tracked lefthook hooks\n",
 "# clone source: committed candidate, two commits on BASE (r1, r2), pushed, clean, produced through the tracked lefthook hooks\n", 1),
('[ "$(g rev-parse HEAD^)" = "$BASE_HEAD" ] && [ "$(g rev-list --count "$BASE_HEAD..HEAD")" = 1 ] || { log "PRECONDITION_FAIL chain != $BASE_HEAD -> HEAD (one commit)"; fail 70; }\n',
 '[ "$(g rev-parse HEAD^)" = "$R1_HEAD" ] && [ "$(g rev-parse HEAD^^)" = "$BASE_HEAD" ] && [ "$(g rev-list --count "$BASE_HEAD..HEAD")" = 2 ] || { log "PRECONDITION_FAIL chain != $BASE_HEAD -> $R1_HEAD -> HEAD (two commits)"; fail 70; }\n'
 '[ "$(g diff --name-only "$R1_HEAD" HEAD | sort | tr \'\\n\' \' \' | sed \'s/ $//\')" = "$R1R2_DELTA" ] || { log "PRECONDITION_FAIL r1..r2 delta != [$R1R2_DELTA]"; fail 70; }\n', 1),
('[ "$(git -C "$W" rev-parse HEAD^)" = "$BASE_HEAD" ] \\\n',
 '[ "$(git -C "$W" rev-parse HEAD^)" = "$R1_HEAD" ] && [ "$(git -C "$W" rev-parse HEAD^^)" = "$BASE_HEAD" ] \\\n', 1),
]
for old, new, n in subs:
    c = s.count(old); assert c == n, (c, n, old[:160]); s = s.replace(old, new)
O.write_text(s); O.chmod(0o755)
l = TL.read_text()
for old, new, n in [("# single granted S11-A2 binding v1 proof run detached.", "# single granted S11-A2 binding v2 proof run detached.", 1)]:
    c = l.count(old); assert c == n, (c, n, old); l = l.replace(old, new)
OL.write_text(l)
print('OK', len(subs), 'runner substitutions, 1 launcher substitution')
