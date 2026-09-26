#!/usr/bin/env python3
# Builds s11-lane-v1/s11-pg-proof.sh from the accepted S11-C v1 runner by exact, count-asserted substitutions (T3 builder;
# source only). Every replacement must match exactly once in the template.
import pathlib, sys
T = pathlib.Path('/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11c/binding/v1/s11-pg-proof.sh')
O = pathlib.Path('/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s11-lane-v1/s11-pg-proof.sh')
s = T.read_text()
FREEZE_S11B_SHA = sys.argv[1]
subs = [
# ---- header: new S11-B paragraph on top; the S11-C paragraph and everything below stay as history
("#!/usr/bin/env bash\n# EXEC-FA72EFB2 S11-C binding v1 —",
 "#!/usr/bin/env bash\n"
 "# EXEC-FA72EFB2 S11-B S11-lane binding v1 — minimum substitution of the accepted S11-C v1 runner (execution/fa72efb2/s11c/binding/v1/\n"
 "# s11-pg-proof.sh, sha256 5e4b29ec…1c1d, ran RC=0 15:49:19Z) to: base 7fdcbc04 (= integration/importer after S11-C landed),\n"
 "# candidate 4d31616f (S11-B settle re-drive, one commit on BASE, PR #562), land ref land/s11b, clone source worktrees/fa72-s11b,\n"
 "# fresh clone worktrees/fa72-s11b-pg1, FREEZE-s11b (the 5 S11-B paths == BASE..HEAD delta) plus FREEZE-v3 kept as \"the 8 A1\n"
 "# files are byte-identical at HEAD\" and FREEZE-s11c re-used as \"the 7 S11-C files are byte-identical at HEAD\" (no longer the\n"
 "# delta), and ONE added spec stage (test/scout/s11/settle-redrive.pg.spec.ts, J12-J15 + tenant scope, 8, default config,\n"
 "# jest-redrive.log, bound 3000 s) after readiness and before the guard. rls 6 / journey 8 / readiness 6 run again as regressions\n"
 "# (S11-B changes src/scout/lifecycle/lifecycle.service.ts and src/scout/scout.service.ts). Outer bound raised 7200 -> 10200 s.\n"
 "# Runner filename kept s11-pg-proof.sh (the byte-copied fixture greps it in the runner cmdline). Full delta: DELTA-from-s11c-v1.diff.\n"
 "# Text below is S11-C v1.\n"
 "# EXEC-FA72EFB2 S11-C binding v1 —"),
("# Inner stage bounds: clone 120 + cp 600 + generate 600 + init 60 + start 60 + bootstrap 900 + identity 8x15 + jest 1500 +\n"
 "# 1500 + readiness 900 + 300 + stop 75 + destroy 75 = 6810 s soft sum (< the unchanged 7200 s outer bound).\n"
 "# Usage (under the separate single-run PG grant): timeout -k 30 7200 bash .../fa72efb2/s11c/binding/v1/s11-pg-proof.sh\n",
 "# Inner stage bounds: clone 120 + cp 600 + generate 600 + init 60 + start 60 + bootstrap 900 + identity 8x15 + jest 1500 +\n"
 "# 1500 + readiness 900 + settle-redrive 3000 + 300 + stop 75 + destroy 75 = 9810 s soft sum (S11-B: outer bound raised\n"
 "# 7200 -> 10200 s, same 390 s margin). Redrive bound: J12/J13 fork harness workers whose own kill timer is 90 s\n"
 "# (g2-s11-pg-harness.ts worker()); jest.setTimeout is 600 s per case; journey-core (8 cases, same harness) took 177 s in the\n"
 "# S11-C run. 3000 s is ~17x that, and still leaves >2000 s if each of the 8 cases lost one worker to its 90 s kill cap;\n"
 "# a timeout here is a failure (rc 124), never a retry.\n"
 "# Usage (under the separate single-run PG grant): timeout -k 30 10200 bash .../fa72efb2/s11b/binding/s11-lane-v1/s11-pg-proof.sh\n"),
("D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11c/binding/v1\n",
 "D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s11-lane-v1\n"),
("SRC=/home/user/workspace/worktrees/fa72-s11c                                     # clone source (read-only here): HEAD 7fdcbc04 (= origin/land/s11c), clean, lefthook hooks\n",
 "SRC=/home/user/workspace/worktrees/fa72-s11b                                     # clone source (read-only here): HEAD 4d31616f (= origin/land/s11b), clean, lefthook hooks\n"),
("W=/home/user/workspace/worktrees/fa72-s11c-pg1 ",
 "W=/home/user/workspace/worktrees/fa72-s11b-pg1 "),
("JLOG4=$R/jest-readiness.log; GENLOG=$R/prisma-generate.log\n",
 "JLOG4=$R/jest-readiness.log; JLOG5=$R/jest-redrive.log; GENLOG=$R/prisma-generate.log\n"),
("BASE_HEAD=3db615c0a5e64a63b910d34ce7c732ee6e63f24d                               # integration/importer tip after S11-A1 landed (= HEAD^)\n",
 "BASE_HEAD=7fdcbc044dba1747d0db2f2750ced951f3b6b752                               # integration/importer tip after S11-C landed (= HEAD^)\n"),
("BASE_TREE=6ea6852ca16253f7e5b269aa9a1cdfb69bac2ddb\n",
 "BASE_TREE=a802231ee1f4dd693284b349e7eb078b3688e8d5\n"),
("EXPECT_HEAD=7fdcbc044dba1747d0db2f2750ced951f3b6b752                             # S11-C candidate (extension-pair readiness), one commit on BASE_HEAD\n"
 "EXPECT_TREE=a802231ee1f4dd693284b349e7eb078b3688e8d5\n"
 "LAND_REF=refs/remotes/origin/land/s11c\n",
 "EXPECT_HEAD=4d31616f9288402c0cdd6a74fb30b4b15d0658d3                             # S11-B candidate (settle re-drive), one commit on BASE_HEAD (PR #562)\n"
 "EXPECT_TREE=366efa9f807cf8c1550bfc8a3394b6840f90287b\n"
 "LAND_REF=refs/remotes/origin/land/s11b\n"),
("EXPECT_DTO_BLOB=9eb9f3d3240453aa14a689b65344005f439ff3fc                          # src/extension-pair/extension-pair.dto.ts (S11-C)\n",
 "EXPECT_DTO_BLOB=9eb9f3d3240453aa14a689b65344005f439ff3fc                          # src/extension-pair/extension-pair.dto.ts (S11-C)\n"
 "EXPECT_REDRIVE_BLOB=aac3f7a8eb2fd49e65b858053fc71bea8c64d3ba                      # test/scout/s11/settle-redrive.pg.spec.ts (S11-B, new)\n"
 "EXPECT_LIFECYCLE_BLOB=974e2c831c1c963c4bf1b68381af48136cf78266                    # src/scout/lifecycle/lifecycle.service.ts (S11-B)\n"
 "EXPECT_SCOUTSVC_BLOB=9afaac48f250bfbceb21043f6005b6a89eb3ef23                     # src/scout/scout.service.ts (S11-B)\n"),
("S11C_FREEZE_SHA=2d58f9d1d810c2871f09110c53c4305f255ffef3e4677bbac5c3f12f7d25137e       # FREEZE-s11c: the 7 S11-C paths at HEAD (paths == delta)\n"
 "EXPECT_DELTA=\"docs/contracts/importer-openapi.json src/extension-pair/__tests__/readiness.spec.ts src/extension-pair/extension-pair.dto.ts src/extension-pair/extension-pair.service.ts test/contracts/importer-contract.spec.ts test/rls-c1-setup.spec.ts test/scout/s11/readiness.pg.spec.ts\"\n",
 "S11C_FREEZE_SHA=2d58f9d1d810c2871f09110c53c4305f255ffef3e4677bbac5c3f12f7d25137e       # FREEZE-s11c: the 7 S11-C files, byte-identical at HEAD (S11-B: no longer the delta)\n"
 "S11C_FILES=\"docs/contracts/importer-openapi.json src/extension-pair/__tests__/readiness.spec.ts src/extension-pair/extension-pair.dto.ts src/extension-pair/extension-pair.service.ts test/contracts/importer-contract.spec.ts test/rls-c1-setup.spec.ts test/scout/s11/readiness.pg.spec.ts\"\n"
 "S11B_FREEZE=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s11-lane-v1/FREEZE-s11b.sha256\n"
 f"S11B_FREEZE_SHA={FREEZE_S11B_SHA}       # FREEZE-s11b: the 5 S11-B paths at HEAD (paths == delta)\n"
 "EXPECT_DELTA=\"src/scout/lifecycle/lifecycle.service.ts src/scout/scout.service.ts test/rls-g2-s10c.spec.ts test/scout/lifecycle/s11b-settle-redrive.spec.ts test/scout/s11/settle-redrive.pg.spec.ts\"\n"),
("EXPECT_TESTS_READINESS=6   # it( in test/scout/s11/readiness.pg.spec.ts (no each/skip/only/todo; describe.skip only when G2_S11_DATABASE_URL is unset)\n",
 "EXPECT_TESTS_READINESS=6   # it( in test/scout/s11/readiness.pg.spec.ts (no each/skip/only/todo; describe.skip only when G2_S11_DATABASE_URL is unset)\n"
 "EXPECT_TESTS_REDRIVE=8     # it( in test/scout/s11/settle-redrive.pg.spec.ts: J12, J12 edge, J13, J14, J15 a/b/c, tenant scope (no each/skip/only/todo; describe.skip only when G2_S11_DATABASE_URL is unset)\n"),
("$EXPECT_READINESS_BLOB$EXPECT_SERVICE_BLOB$EXPECT_DTO_BLOB$EXPECT_FIXTURE_SHA",
 "$EXPECT_READINESS_BLOB$EXPECT_SERVICE_BLOB$EXPECT_DTO_BLOB$EXPECT_REDRIVE_BLOB$EXPECT_LIFECYCLE_BLOB$EXPECT_SCOUTSVC_BLOB$EXPECT_FIXTURE_SHA"),
("$S11_FREEZE_SHA$S11C_FREEZE_SHA\" in *__*)",
 "$S11_FREEZE_SHA$S11C_FREEZE_SHA$S11B_FREEZE_SHA\" in *__*)"),
("!= the 7 S11-C paths\"; fail 70; }\n",
 "!= the 5 S11-B paths\"; fail 70; }\n"),
("[ \"$CFILES\" = \"$EXPECT_DELTA\" ] || { log \"PRECONDITION_FAIL FREEZE-s11c paths != delta\"; fail 70; }\n"
 "while read -r s p; do GOT=$(g show \"HEAD:$p\" | sha256sum | cut -c1-64); [ \"$GOT\" = \"$s\" ] || { log \"PRECONDITION_FAIL $p at HEAD != FREEZE-s11c\"; fail 70; }; done < \"$S11C_FREEZE\"\n",
 "[ \"$CFILES\" = \"$S11C_FILES\" ] || { log \"PRECONDITION_FAIL FREEZE-s11c paths != the 7 S11-C files\"; fail 70; }\n"
 "while read -r s p; do GOT=$(g show \"HEAD:$p\" | sha256sum | cut -c1-64); [ \"$GOT\" = \"$s\" ] || { log \"PRECONDITION_FAIL S11-C file $p at HEAD != FREEZE-s11c\"; fail 70; }; done < \"$S11C_FREEZE\"\n"
 "[ -f \"$S11B_FREEZE\" ] && [ \"$(sha \"$S11B_FREEZE\")\" = \"$S11B_FREEZE_SHA\" ] || { log \"PRECONDITION_FAIL S11-B FREEZE absent or sha mismatch\"; fail 70; }\n"
 "BFILES=$(awk '{print $2}' \"$S11B_FREEZE\" | sort | tr '\\n' ' ' | sed 's/ $//'); [ \"$BFILES\" = \"$EXPECT_DELTA\" ] || { log \"PRECONDITION_FAIL FREEZE-s11b paths != delta\"; fail 70; }\n"
 "while read -r s p; do GOT=$(g show \"HEAD:$p\" | sha256sum | cut -c1-64); [ \"$GOT\" = \"$s\" ] || { log \"PRECONDITION_FAIL $p at HEAD != FREEZE-s11b\"; fail 70; }; done < \"$S11B_FREEZE\"\n"),
("  && READY=$(g show HEAD:test/scout/s11/readiness.pg.spec.ts) || {",
 "  && READY=$(g show HEAD:test/scout/s11/readiness.pg.spec.ts) && REDRIVE=$(g show HEAD:test/scout/s11/settle-redrive.pg.spec.ts) || {"),
("grep -qF \"const live = process.env.G2_S11_DATABASE_URL ? describe : describe.skip;\" <<<\"$READY\" || { log \"PRECONDITION_FAIL readiness spec live switch not the pinned form\"; fail 70; }\n",
 "grep -qF \"const live = process.env.G2_S11_DATABASE_URL ? describe : describe.skip;\" <<<\"$READY\" || { log \"PRECONDITION_FAIL readiness spec live switch not the pinned form\"; fail 70; }\n"
 "grep -qF \"const live = process.env.G2_S11_DATABASE_URL ? describe : describe.skip;\" <<<\"$REDRIVE\" || { log \"PRECONDITION_FAIL settle-redrive spec live switch not the pinned form\"; fail 70; }\n"),
("! grep -qE \"$BADPAT\" <<<\"$READY\" || { log \"PRECONDITION_FAIL readiness spec carries skip/only/todo/each\"; fail 70; }\n",
 "! grep -qE \"$BADPAT\" <<<\"$READY\" || { log \"PRECONDITION_FAIL readiness spec carries skip/only/todo/each\"; fail 70; }\n"
 "! grep -qE \"$BADPAT\" <<<\"$REDRIVE\" || { log \"PRECONDITION_FAIL settle-redrive spec carries skip/only/todo/each\"; fail 70; }\n"),
("N3=$(grep -cE '^\\s*it\\(' <<<\"$READY\" || true)\n"
 "[ \"$N1\" = \"$EXPECT_TESTS_RLS\" ] && [ \"$N2\" = \"$EXPECT_TESTS_JOURNEY\" ] && [ \"$N3\" = \"$EXPECT_TESTS_READINESS\" ] || { log \"PRECONDITION_FAIL it() counts rls=$N1 journey=$N2 readiness=$N3 != $EXPECT_TESTS_RLS/$EXPECT_TESTS_JOURNEY/$EXPECT_TESTS_READINESS\"; fail 70; }\n",
 "N3=$(grep -cE '^\\s*it\\(' <<<\"$READY\" || true); N4=$(grep -cE '^\\s*it\\(' <<<\"$REDRIVE\" || true)\n"
 "[ \"$N1\" = \"$EXPECT_TESTS_RLS\" ] && [ \"$N2\" = \"$EXPECT_TESTS_JOURNEY\" ] && [ \"$N3\" = \"$EXPECT_TESTS_READINESS\" ] && [ \"$N4\" = \"$EXPECT_TESTS_REDRIVE\" ] || { log \"PRECONDITION_FAIL it() counts rls=$N1 journey=$N2 readiness=$N3 redrive=$N4 != $EXPECT_TESTS_RLS/$EXPECT_TESTS_JOURNEY/$EXPECT_TESTS_READINESS/$EXPECT_TESTS_REDRIVE\"; fail 70; }\n"),
("           \"src/extension-pair/extension-pair.service.ts $EXPECT_SERVICE_BLOB\" \"src/extension-pair/extension-pair.dto.ts $EXPECT_DTO_BLOB\"; do set -- $pin\n",
 "           \"src/extension-pair/extension-pair.service.ts $EXPECT_SERVICE_BLOB\" \"src/extension-pair/extension-pair.dto.ts $EXPECT_DTO_BLOB\" \\\n"
 "           \"test/scout/s11/settle-redrive.pg.spec.ts $EXPECT_REDRIVE_BLOB\" \"src/scout/lifecycle/lifecycle.service.ts $EXPECT_LIFECYCLE_BLOB\" \"src/scout/scout.service.ts $EXPECT_SCOUTSVC_BLOB\"; do set -- $pin\n"),
("[ \"$(sha \"$S11C_FREEZE\")\" = \"$S11C_FREEZE_SHA\" ] \\\n",
 "[ \"$(sha \"$S11C_FREEZE\")\" = \"$S11C_FREEZE_SHA\" ] && [ \"$(sha \"$S11B_FREEZE\")\" = \"$S11B_FREEZE_SHA\" ] \\\n"),
("for f in jest-rls.log jest-journey.log jest-readiness.log jest-guard.log ",
 "for f in jest-rls.log jest-journey.log jest-readiness.log jest-redrive.log jest-guard.log "),
("jcheck readiness \"$JLOG4\" \"$JRC\" \"$EXPECT_TESTS_READINESS\"\n",
 "jcheck readiness \"$JLOG4\" \"$JRC\" \"$EXPECT_TESTS_READINESS\"\n"
 "STAGE=jest-redrive; log \"JEST_START redrive $(ts) cmd='./node_modules/.bin/jest --runInBand --ci test/scout/s11/settle-redrive.pg.spec.ts'\"\n"
 "( cd \"$W\" && timeout -k 30 3000 ./node_modules/.bin/jest --runInBand --ci test/scout/s11/settle-redrive.pg.spec.ts ) >\"$JLOG5\" 2>&1; JRC=$?\n"
 "jcheck redrive \"$JLOG5\" \"$JRC\" \"$EXPECT_TESTS_REDRIVE\"\n"),
("# ---- step 8 the four specs, each exactly once;",
 "# ---- step 8 the five specs, each exactly once;"),
]
for a, b in subs:
    n = s.count(a)
    if n != 1:
        sys.exit(f'substitution matched {n} times: {a[:90]!r}')
    s = s.replace(a, b)
O.write_text(s)
O.chmod(0o755)
print('wrote', O, len(s.splitlines()), 'lines')
