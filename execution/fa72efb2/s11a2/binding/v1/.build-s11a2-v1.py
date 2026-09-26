#!/usr/bin/env python3
# Builds s11a2/binding/v1/s11-pg-proof.sh from the independently reviewed-GO s11b/binding/s11-lane-v2 runner (ran RC=0 122/122,
# 17:32:47Z) by exact, count-asserted substitutions (T3 builder; source only). Every (old, new, n) must match exactly n times in
# the v2 bytes. argv[1] = sha256 of s11a2/binding/v1/FREEZE-s11a2.sha256. Also builds launch-when-free.sh from the v2 launcher.
import pathlib, sys
EV = '/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2'
T = pathlib.Path(EV + '/s11b/binding/s11-lane-v2/s11-pg-proof.sh')
O = pathlib.Path(EV + '/s11a2/binding/v1/s11-pg-proof.sh')
TL = pathlib.Path(EV + '/s11b/binding/s11-lane-v2/launch-when-free.sh')
OL = pathlib.Path(EV + '/s11a2/binding/v1/launch-when-free.sh')
s = T.read_text()
FREEZE_SHA = sys.argv[1]
assert len(FREEZE_SHA) == 64
OLD6 = ('src/scout/lifecycle/lifecycle.service.ts src/scout/scout.service.ts test/rls-g2-s10c.spec.ts '
        'test/scout/lifecycle/lifecycle.service.spec.ts test/scout/lifecycle/s11b-settle-redrive.spec.ts '
        'test/scout/s11/settle-redrive.pg.spec.ts')
NEW12 = ('test/fixtures/scout/s11/s11-sources.ts test/fixtures/scout/s11/s11_second/induction-manifest.json '
         'test/fixtures/scout/s11/s11_second/mapping-spec.json test/fixtures/scout/s11/s11_second/native-rules.json '
         'test/fixtures/scout/s11/s11_second/signer-test-key.json test/fixtures/scout/s11/s11_second/staged-rows.json '
         'test/fixtures/scout/s11/s11_second/statements.json test/scout/s11/journey-induction.pg.spec.ts '
         'test/utils/g2-s11-db-guard.spec.ts test/utils/g2-s11-harness.ts test/utils/g2-s11-pg-harness.ts test/utils/g2-s11-worker.cjs')
A2_UTILS = 'test/utils/g2-s11-db-guard.spec.ts test/utils/g2-s11-harness.ts test/utils/g2-s11-pg-harness.ts test/utils/g2-s11-worker.cjs'
subs = [
# ---- header: new A2 paragraph on top; v2 text below stays as history
("#!/usr/bin/env bash\n# EXEC-FA72EFB2 S11-B S11-lane binding v2 —",
 "#!/usr/bin/env bash\n"
 "# EXEC-FA72EFB2 S11-A2 binding v1 — minimum substitution of the independently reviewed-GO S11-B s11-lane-v2 runner\n"
 "# (s11b/binding/s11-lane-v2/s11-pg-proof.sh, sha256 2e683690…1327, ran RC=0 17:32:47Z, 122/122) to: base dda794d7 (S11-B r2,\n"
 "# tree 802e1c19), candidate 03e7a234 (S11-A2 two-source induction J09-J11, ONE commit on BASE, tree 738b7116), branch fa72/s11a2,\n"
 "# land ref land/s11a2, clone source worktrees/fa72-s11a2, fresh clone worktrees/fa72-s11a2-pg1. The S11-B two-commit / r1->r2\n"
 "# checks are dropped (HEAD^ = BASE, rev-list count 1). Delta = the 12 A2 paths == new FREEZE-s11a2 (own dir). A2 is the D-S11-6\n"
 "# sequential writer of 4 A1 harness files (guard spec, harness, pg-harness, worker): FREEZE-v3 is kept for the 4 untouched A1\n"
 "# files only (the 4 edited ones are pinned by FREEZE-s11a2 + new blob pins); FREEZE-s11c (7) and FREEZE-s11b v2 (6, no longer\n"
 "# the delta, now compared to its own literal path list) must hold unchanged at HEAD. BASE..HEAD: no src/prisma/manifests change;\n"
 "# test/utils change == exactly the 4 A2 utils. ONE added stage (test/scout/s11/journey-induction.pg.spec.ts, 4, default config,\n"
 "# jest-induction.log, bound 3000 s) after settle-redrive and before the guard (now 95). Outer bound 10200 -> 13500 s.\n"
 "# Full delta: DELTA-from-s11b-v2.diff. Text below is s11-lane v2.\n"
 "# EXEC-FA72EFB2 S11-B S11-lane binding v2 —", 1),
("# Usage (under the separate single-run PG grant): timeout -k 30 10200 bash .../fa72efb2/s11b/binding/s11-lane-v2/s11-pg-proof.sh\n",
 "# A2 bounds: true inner sum clone 120 + checkout 120 + cp 600 + generate 600 + init 60 + start 60 + bootstrap 900 + identity 8x15\n"
 "# + rls 1500 + journey 1500 + readiness 900 + redrive 3000 + induction 3000 + guard 300 + stop 75 + destroy 75 = 12930 s; outer\n"
 "# 13500 (570 s margin). Induction bound: 4 cases x jest.setTimeout 600 s = 2400 s hard jest ceiling + 600 s for boot/hooks; ~38\n"
 "# ts-node worker processes (J09 15, J10 11, J11a 6, J11b 6; each harness worker has its own 90 s kill cap), cf. journey-core\n"
 "# 8 cases 180 s and redrive 226 s in the v2 run. A timeout is a failure (rc 124), never a retry.\n"
 "# Usage (under the separate single-run PG grant): timeout -k 30 13500 bash .../fa72efb2/s11a2/binding/v1/s11-pg-proof.sh\n", 1),
("D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s11-lane-v2\n",
 "D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11a2/binding/v1\n", 1),
("SRC=/home/user/workspace/worktrees/fa72-s11b                                     # clone source (read-only here): HEAD dda794d7 (= origin/land/s11b-r2, branch fa72/s11b-r2), clean, lefthook hooks\n",
 "SRC=/home/user/workspace/worktrees/fa72-s11a2                                    # clone source (read-only here): HEAD 03e7a234 (= origin/land/s11a2, branch fa72/s11a2), clean, lefthook hooks\n", 1),
("W=/home/user/workspace/worktrees/fa72-s11b-pg3 ",
 "W=/home/user/workspace/worktrees/fa72-s11a2-pg1", 1),
("JLOG5=$R/jest-redrive.log; GENLOG=",
 "JLOG5=$R/jest-redrive.log; JLOG6=$R/jest-induction.log; GENLOG=", 1),
("BASE_HEAD=275e458ca5a6b3684bb6ec83edb2a854056a6fd0                               # integration/importer tip after S10-D D2 landed (= HEAD^^)\n",
 "BASE_HEAD=dda794d7e8bee0482a7ad373795fcc51dcf54bb5                               # S11-B r2 (proof RC=0 122/122; = 275e458c + 2 S11-B commits) (= HEAD^)\n", 1),
("BASE_TREE=6267ef6a57225af187f5a21fb8a2c3cc3fd6103e\n",
 "BASE_TREE=802e1c196c7a0bd27f091218407f5f0b031dd760\n", 1),
("EXPECT_HEAD=dda794d7e8bee0482a7ad373795fcc51dcf54bb5                             # S11-B r2 candidate (= 9149f823 re-applied), two commits on BASE_HEAD (PR #563)\n"
 "EXPECT_TREE=802e1c196c7a0bd27f091218407f5f0b031dd760\n"
 "R1_HEAD=645fb6db022f2ef6299ed4aa2bcd3f409d2a8298                                 # S11-B r1 (= 4d31616f re-applied) = HEAD^, parent BASE_HEAD\n"
 "R1R2_DELTA=\"src/scout/lifecycle/lifecycle.service.ts test/scout/lifecycle/lifecycle.service.spec.ts\"   # R1_HEAD..HEAD (the r2 fix), exactly\n"
 "LAND_REF=refs/remotes/origin/land/s11b-r2\n",
 "EXPECT_HEAD=03e7a2344ef95b019c751983527bbc9f78200921                             # S11-A2 candidate (two-source induction J09-J11), ONE commit on BASE_HEAD\n"
 "EXPECT_TREE=738b711610a570357136ad8e8eb1be176d406c51\n"
 "LAND_REF=refs/remotes/origin/land/s11a2\n", 1),
("EXPECT_GUARD_BLOB=e1ace171738934a209b10f58039db9d86031b831                        # test/utils/g2-s11-db-guard.spec.ts\n",
 "EXPECT_GUARD_BLOB=3975aab13e40ebd43d38c1b772ae54718ceb9d41                        # test/utils/g2-s11-db-guard.spec.ts (S11-A2 edit)\n", 1),
("EXPECT_HARNESS_BLOB=240a49691315a274b2a63ed0076d251821e0b180                      # test/utils/g2-s11-harness.ts\n",
 "EXPECT_HARNESS_BLOB=1b66137a3a59b3bf396660cbc5606f4de444831e                      # test/utils/g2-s11-harness.ts (S11-A2 edit)\n", 1),
("EXPECT_PGH_BLOB=2cb6e79a4ee602ce87dccc8c5adf0727e3373bca                          # test/utils/g2-s11-pg-harness.ts\n",
 "EXPECT_PGH_BLOB=ad32b5693390228bba001184acc2145b898879ac                          # test/utils/g2-s11-pg-harness.ts (S11-A2 edit)\n", 1),
("EXPECT_WORKER_BLOB=d1504f6a487f140e61ebfce0ff72e9d5327a1243                       # test/utils/g2-s11-worker.cjs\n",
 "EXPECT_WORKER_BLOB=562038a1127f82ec5eb285010f8d8eade4cb2c8e                       # test/utils/g2-s11-worker.cjs (S11-A2 edit)\n"
 "EXPECT_INDUCTION_BLOB=1b9832bcbce7a51da6a58df60c312a5b0416f144                    # test/scout/s11/journey-induction.pg.spec.ts (S11-A2, new)\n", 1),
("S11_FREEZE_SHA=e6e3a15a8f2d262bbeb06c7be3ec13581bbb59ca237936fbcd6278dbc9e24187        # A1 FREEZE-v3: the 8 A1 files, byte-identical at HEAD\n",
 "S11_FREEZE_SHA=e6e3a15a8f2d262bbeb06c7be3ec13581bbb59ca237936fbcd6278dbc9e24187        # A1 FREEZE-v3: 8 A1 lines; the 4 NOT in A2_A1_EDITS must be byte-identical at HEAD\n"
 "A2_A1_EDITS=\"" + A2_UTILS + "\"   # A1 files A2 rewrites (D-S11-6 sequential writer): pinned by FREEZE-s11a2, skipped in FREEZE-v3\n", 1),
("S11B_FREEZE_SHA=603ffa02a95d0e712bba45ca6cda4507295a9331bea827c7809ff0c9b2e4f1d0       # FREEZE-s11b v2: the 6 S11-B paths at HEAD (paths == delta)\n",
 "S11B_FREEZE_SHA=603ffa02a95d0e712bba45ca6cda4507295a9331bea827c7809ff0c9b2e4f1d0       # FREEZE-s11b v2: the 6 S11-B files, byte-identical at HEAD (S11-A2: no longer the delta)\n"
 "S11B_FILES=\"" + OLD6 + "\"\n"
 "S11A2_FREEZE=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11a2/binding/v1/FREEZE-s11a2.sha256\n"
 "S11A2_FREEZE_SHA=" + FREEZE_SHA + "      # FREEZE-s11a2: the 12 S11-A2 paths at HEAD (paths == delta)\n", 1),
('EXPECT_DELTA="' + OLD6 + '"\n', 'EXPECT_DELTA="' + NEW12 + '"\n', 1),
("EXPECT_TESTS_GUARD=94       # 10 it + it.each 61 + 20 + 3 (devloop-1 on the same bytes 4e8c0fee: 94 passed)\n",
 "EXPECT_TESTS_INDUCTION=4   # it( in test/scout/s11/journey-induction.pg.spec.ts: J09, J10, J11(a), J11(b) (no each/skip/only/todo; describe.skip only when G2_S11_DATABASE_URL is unset)\n"
 "EXPECT_TESTS_GUARD=95       # 11 it + it.each 61 + 20 + 3 (S11-A2 adds one it; A2 builder no-DB run on 03e7a234: 95 passed)\n", 1),
# pins-not-filled guard: R1_HEAD gone, induction blob + A2 freeze added
('$EXPECT_HEAD$EXPECT_TREE$R1_HEAD$EXPECT_MIGRATIONS_TREE', '$EXPECT_HEAD$EXPECT_TREE$EXPECT_MIGRATIONS_TREE', 1),
('$EXPECT_REDRIVE_BLOB$EXPECT_LIFECYCLE_BLOB', '$EXPECT_REDRIVE_BLOB$EXPECT_INDUCTION_BLOB$EXPECT_LIFECYCLE_BLOB', 1),
('$S11C_FREEZE_SHA$S11B_FREEZE_SHA\" in *__*)', '$S11C_FREEZE_SHA$S11B_FREEZE_SHA$S11A2_FREEZE_SHA\" in *__*)', 1),
# pre-lock chain check: exactly one commit on BASE (the S11-B two-commit + r1->r2 checks dropped)
("# clone source: committed candidate, two commits on BASE (r1, r2), pushed, clean, produced through the tracked lefthook hooks\n",
 "# clone source: committed candidate, ONE commit on BASE, pushed, clean, produced through the tracked lefthook hooks\n", 1),
('[ "$(g rev-parse HEAD^)" = "$R1_HEAD" ] && [ "$(g rev-parse HEAD^^)" = "$BASE_HEAD" ] && [ "$(g rev-list --count "$BASE_HEAD..HEAD")" = 2 ] || { log "PRECONDITION_FAIL chain != $BASE_HEAD -> $R1_HEAD -> HEAD (two commits)"; fail 70; }\n'
 '[ "$(g diff --name-only "$R1_HEAD" HEAD | sort | tr \'\\n\' \' \' | sed \'s/ $//\')" = "$R1R2_DELTA" ] || { log "PRECONDITION_FAIL r1..r2 delta != [$R1R2_DELTA]"; fail 70; }\n',
 '[ "$(g rev-parse HEAD^)" = "$BASE_HEAD" ] && [ "$(g rev-list --count "$BASE_HEAD..HEAD")" = 1 ] || { log "PRECONDITION_FAIL chain != $BASE_HEAD -> HEAD (one commit)"; fail 70; }\n', 1),
('!= the 6 S11-B paths"; fail 70; }', '!= the 12 S11-A2 paths"; fail 70; }', 1),
# FREEZE-v3: only the A1 files A2 does not edit
('while read -r s p; do GOT=$(g show "HEAD:$p" | sha256sum | cut -c1-64); [ "$GOT" = "$s" ] || { log "PRECONDITION_FAIL A1 file $p at HEAD != FREEZE-v3"; fail 70; }; done < "$S11_FREEZE"\n',
 'while read -r s p; do case " $A2_A1_EDITS " in *" $p "*) continue;; esac; GOT=$(g show "HEAD:$p" | sha256sum | cut -c1-64); [ "$GOT" = "$s" ] || { log "PRECONDITION_FAIL A1 file $p at HEAD != FREEZE-v3"; fail 70; }; done < "$S11_FREEZE"\n', 1),
# FREEZE-s11b: compared to its own path list (no longer the delta); then FREEZE-s11a2 == delta
('[ "$BFILES" = "$EXPECT_DELTA" ] || { log "PRECONDITION_FAIL FREEZE-s11b paths != delta"; fail 70; }\n',
 '[ "$BFILES" = "$S11B_FILES" ] || { log "PRECONDITION_FAIL FREEZE-s11b paths != the 6 S11-B files"; fail 70; }\n', 1),
('{ log "PRECONDITION_FAIL $p at HEAD != FREEZE-s11b"; fail 70; }; done < "$S11B_FREEZE"\n',
 '{ log "PRECONDITION_FAIL S11-B file $p at HEAD != FREEZE-s11b"; fail 70; }; done < "$S11B_FREEZE"\n'
 '[ -f "$S11A2_FREEZE" ] && [ "$(sha "$S11A2_FREEZE")" = "$S11A2_FREEZE_SHA" ] || { log "PRECONDITION_FAIL S11-A2 FREEZE absent or sha mismatch"; fail 70; }\n'
 'AFILES=$(awk \'{print $2}\' "$S11A2_FREEZE" | sort | tr \'\\n\' \' \' | sed \'s/ $//\'); [ "$AFILES" = "$EXPECT_DELTA" ] || { log "PRECONDITION_FAIL FREEZE-s11a2 paths != delta"; fail 70; }\n'
 'while read -r s p; do GOT=$(g show "HEAD:$p" | sha256sum | cut -c1-64); [ "$GOT" = "$s" ] || { log "PRECONDITION_FAIL $p at HEAD != FREEZE-s11a2"; fail 70; }; done < "$S11A2_FREEZE"\n', 1),
# BASE..HEAD: no src/prisma/manifests change; test/utils change == exactly the 4 A2 utils
('[ -z "$(g diff --name-only "$BASE_HEAD" HEAD -- prisma package.json package-lock.json test/utils)" ] || { log "PRECONDITION_FAIL prisma, dependency manifests or test/utils differ from BASE"; fail 70; }\n',
 '[ -z "$(g diff --name-only "$BASE_HEAD" HEAD -- src prisma package.json package-lock.json)" ] || { log "PRECONDITION_FAIL src, prisma or dependency manifests differ from BASE"; fail 70; }\n'
 '[ "$(g diff --name-only "$BASE_HEAD" HEAD -- test/utils | sort | tr \'\\n\' \' \' | sed \'s/ $//\')" = "$A2_A1_EDITS" ] || { log "PRECONDITION_FAIL BASE..HEAD test/utils != the 4 A2 harness edits"; fail 70; }\n', 1),
# induction spec bytes: live switch, no skip/only/todo/each, it() count
('&& READY=$(g show HEAD:test/scout/s11/readiness.pg.spec.ts) && REDRIVE=$(g show HEAD:test/scout/s11/settle-redrive.pg.spec.ts) ||',
 '&& READY=$(g show HEAD:test/scout/s11/readiness.pg.spec.ts) && REDRIVE=$(g show HEAD:test/scout/s11/settle-redrive.pg.spec.ts) \\\n'
 '  && IND=$(g show HEAD:test/scout/s11/journey-induction.pg.spec.ts) ||', 1),
('grep -qF "const live = process.env.G2_S11_DATABASE_URL ? describe : describe.skip;" <<<"$REDRIVE" || { log "PRECONDITION_FAIL settle-redrive spec live switch not the pinned form"; fail 70; }\n',
 'grep -qF "const live = process.env.G2_S11_DATABASE_URL ? describe : describe.skip;" <<<"$REDRIVE" || { log "PRECONDITION_FAIL settle-redrive spec live switch not the pinned form"; fail 70; }\n'
 'grep -qF "const live = process.env.G2_S11_DATABASE_URL ? describe : describe.skip;" <<<"$IND" || { log "PRECONDITION_FAIL induction spec live switch not the pinned form"; fail 70; }\n', 1),
('! grep -qE "$BADPAT" <<<"$REDRIVE" || { log "PRECONDITION_FAIL settle-redrive spec carries skip/only/todo/each"; fail 70; }\n',
 '! grep -qE "$BADPAT" <<<"$REDRIVE" || { log "PRECONDITION_FAIL settle-redrive spec carries skip/only/todo/each"; fail 70; }\n'
 '! grep -qE "$BADPAT" <<<"$IND" || { log "PRECONDITION_FAIL induction spec carries skip/only/todo/each"; fail 70; }\n', 1),
('N4=$(grep -cE \'^\\s*it\\(\' <<<"$REDRIVE" || true)\n',
 'N4=$(grep -cE \'^\\s*it\\(\' <<<"$REDRIVE" || true); N5=$(grep -cE \'^\\s*it\\(\' <<<"$IND" || true)\n', 1),
('[ "$N4" = "$EXPECT_TESTS_REDRIVE" ] || { log "PRECONDITION_FAIL it() counts rls=$N1 journey=$N2 readiness=$N3 redrive=$N4 != $EXPECT_TESTS_RLS/$EXPECT_TESTS_JOURNEY/$EXPECT_TESTS_READINESS/$EXPECT_TESTS_REDRIVE"; fail 70; }\n',
 '[ "$N4" = "$EXPECT_TESTS_REDRIVE" ] && [ "$N5" = "$EXPECT_TESTS_INDUCTION" ] || { log "PRECONDITION_FAIL it() counts rls=$N1 journey=$N2 readiness=$N3 redrive=$N4 induction=$N5 != $EXPECT_TESTS_RLS/$EXPECT_TESTS_JOURNEY/$EXPECT_TESTS_READINESS/$EXPECT_TESTS_REDRIVE/$EXPECT_TESTS_INDUCTION"; fail 70; }\n', 1),
('"src/scout/lifecycle/lifecycle.service.ts $EXPECT_LIFECYCLE_BLOB" "src/scout/scout.service.ts $EXPECT_SCOUTSVC_BLOB"; do set -- $pin\n',
 '"src/scout/lifecycle/lifecycle.service.ts $EXPECT_LIFECYCLE_BLOB" "src/scout/scout.service.ts $EXPECT_SCOUTSVC_BLOB" \\\n'
 '           "test/scout/s11/journey-induction.pg.spec.ts $EXPECT_INDUCTION_BLOB"; do set -- $pin\n', 1),
# under-lock recheck also covers FREEZE-s11a2
('[ "$(sha "$S11B_FREEZE")" = "$S11B_FREEZE_SHA" ] \\\n',
 '[ "$(sha "$S11B_FREEZE")" = "$S11B_FREEZE_SHA" ] && [ "$(sha "$S11A2_FREEZE")" = "$S11A2_FREEZE_SHA" ] \\\n', 1),
# fresh-clone parent check: one commit
('[ "$(git -C "$W" rev-parse HEAD^)" = "$R1_HEAD" ] && [ "$(git -C "$W" rev-parse HEAD^^)" = "$BASE_HEAD" ] \\\n',
 '[ "$(git -C "$W" rev-parse HEAD^)" = "$BASE_HEAD" ] \\\n', 1),
# receipts include the new log
('jest-redrive.log jest-guard.log prisma-generate.log', 'jest-redrive.log jest-induction.log jest-guard.log prisma-generate.log', 1),
("# ---- step 8 the five specs, each exactly once;", "# ---- step 8 the six specs, each exactly once;", 1),
# NEW induction stage after settle-redrive, before the guard
('jcheck redrive "$JLOG5" "$JRC" "$EXPECT_TESTS_REDRIVE"\n',
 'jcheck redrive "$JLOG5" "$JRC" "$EXPECT_TESTS_REDRIVE"\n'
 'STAGE=jest-induction; log "JEST_START induction $(ts) cmd=\'./node_modules/.bin/jest --runInBand --ci test/scout/s11/journey-induction.pg.spec.ts\'"\n'
 '( cd "$W" && timeout -k 30 3000 ./node_modules/.bin/jest --runInBand --ci test/scout/s11/journey-induction.pg.spec.ts ) >"$JLOG6" 2>&1; JRC=$?\n'
 'jcheck induction "$JLOG6" "$JRC" "$EXPECT_TESTS_INDUCTION"\n', 1),
]
for old, new, n in subs:
    c = s.count(old)
    assert c == n, (c, n, old[:160])
    s = s.replace(old, new)
assert '$R1_HEAD' not in s and 'R1_HEAD=' not in s and '$R1R2_DELTA' not in s, 'stale S11-B r1 pin left'
O.write_text(s)
O.chmod(0o755)
l = TL.read_text()
lsubs = [
("# single granted S11-B S11-lane v2 proof run detached.", "# single granted S11-A2 binding v1 proof run detached.", 1),
('exec timeout -k 30 10200 bash "$D/s11-pg-proof.sh"\n', 'exec timeout -k 30 13500 bash "$D/s11-pg-proof.sh"\n', 1),
]
for old, new, n in lsubs:
    c = l.count(old)
    assert c == n, (c, n, old)
    l = l.replace(old, new)
OL.write_text(l)
print('OK', len(subs), 'runner substitutions,', len(lsubs), 'launcher substitutions')
