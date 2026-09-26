#!/usr/bin/env bash
# EXEC-FA72EFB2 S11-D binding v1 — minimum substitution of s11a2/binding/v2 (sha256 c785752b…c708; ran END rc=0 127/127,
# S11-A2 landed as integration/importer = 54be96f1, PR #564) to the S11-D candidate: chain 54be96f1 (tree 435fec78) -> a52d20d6
# (r1) -> 38d0d366 (r2), tree 075c1513, branch fa72/s11d-r2, land ref land/s11d, clone source worktrees/fa72-s11d2, fresh clone
# worktrees/fa72-s11d2-pg1. Delta = exactly test/scout/s11/journey-full.pg.spec.ts (blob ecfe8cef, 6 it: J19 legs A/B + 4 J20
# checks), pinned by the new FREEZE-s11d; FREEZE-s11a2 (12 paths, no longer the delta), FREEZE-v3 kept lines, FREEZE-s11c,
# FREEZE-s11b and all 18 v2 blob pins must hold unchanged at HEAD; BASE..HEAD touches nothing in src/prisma/package*/test/utils.
# Stages: bootstrap + NEW full (jest-full.log) + guard 95 only; rls/journey/readiness/settle-redrive/induction were accepted at
# BASE in the s11a2 v2 run on unchanged bytes and are NOT rerun (their byte pins/it() counts are still checked). New pre-lock
# tool check: rg on PATH (J20 runs scripts/s10-core-diff-gate.sh at 275e458c, which needs rg). J20 needs history: the clone
# is --shared (objects via alternates to the source); all 10 commits of 3db615c0^..HEAD and every object of their trees are
# present in the source (checked read-only at build). J20's scratch `git worktree add` goes to os.tmpdir() (outside $W) and is
# removed in its finally; .git/worktrees is not in `git status`, so the PORC0 post check is unaffected; the post step logs the
# clone's worktree count (record only). Bounds: full = 6 cases x jest.setTimeout 600 s = 3600 s hard jest ceiling + 600 s
# boot/hooks = 4200 s (J19 legs fork many ts-node harness workers incl. the J12 kill-and-replay, each with its own 90 s kill
# cap; cf. v2 run: journey-core 188 s, redrive 233 s, induction 84 s). Inner sum clone 120 + checkout 120 + cp 600 + generate
# 600 + init 60 + start 60 + bootstrap 900 + identity 8x15 + full 4200 + guard 300 + stop 75 + destroy 75 = 7230 s; outer 7800
# (570 s margin). A timeout is a failure (rc 124), never a retry. Full delta: DELTA-from-s11a2-v2.diff. Text below is s11a2 v2.
# EXEC-FA72EFB2 S11-A2 binding v2 — minimum substitution of s11a2/binding/v1 (sha256 7da3029f…3af6; its run was consumed and
# FAILED at jest-rls on a candidate harness defect, s11a2/PROOF_V1_FINDING.md) to the r2 candidate: chain dda794d7 -> 03e7a234 (r1)
# -> 54be96f1 (r2: resetData drops the direct DELETEs on the three S10-B insert-only tables; cascade only), tree 435fec78.
# Changes: two-commit chain check (HEAD^ = R1_HEAD, HEAD^^ = BASE, count 2) + r1->r2 diff check (exactly test/utils/g2-s11-harness.ts),
# EXPECT_HARNESS_BLOB 927d7365, FREEZE-s11a2 regenerated at HEAD (11 lines unchanged + harness 502c97c9), fresh clone
# worktrees/fa72-s11a2-pg2, own dir/run. Delta (12 paths), other freezes/pins, stages, counts and bounds (outer 13500) unchanged.
# Full delta: DELTA-from-v1.diff. Text below is s11a2 v1.
# EXEC-FA72EFB2 S11-A2 binding v1 — minimum substitution of the independently reviewed-GO S11-B s11-lane-v2 runner
# (s11b/binding/s11-lane-v2/s11-pg-proof.sh, sha256 2e683690…1327, ran RC=0 17:32:47Z, 122/122) to: base dda794d7 (S11-B r2,
# tree 802e1c19), candidate 03e7a234 (S11-A2 two-source induction J09-J11, ONE commit on BASE, tree 738b7116), branch fa72/s11a2,
# land ref land/s11a2, clone source worktrees/fa72-s11a2, fresh clone worktrees/fa72-s11a2-pg1. The S11-B two-commit / r1->r2
# checks are dropped (HEAD^ = BASE, rev-list count 1). Delta = the 12 A2 paths == new FREEZE-s11a2 (own dir). A2 is the D-S11-6
# sequential writer of 4 A1 harness files (guard spec, harness, pg-harness, worker): FREEZE-v3 is kept for the 4 untouched A1
# files only (the 4 edited ones are pinned by FREEZE-s11a2 + new blob pins); FREEZE-s11c (7) and FREEZE-s11b v2 (6, no longer
# the delta, now compared to its own literal path list) must hold unchanged at HEAD. BASE..HEAD: no src/prisma/manifests change;
# test/utils change == exactly the 4 A2 utils. ONE added stage (test/scout/s11/journey-induction.pg.spec.ts, 4, default config,
# jest-induction.log, bound 3000 s) after settle-redrive and before the guard (now 95). Outer bound 10200 -> 13500 s.
# Full delta: DELTA-from-s11b-v2.diff. Text below is s11-lane v2.
# EXEC-FA72EFB2 S11-B S11-lane binding v2 — minimum substitution of the reviewed-GO s11-lane-v1 runner (sha256 ef0024b2…ef36a;
# its run failed only on candidate J13, PROOF_A_V1_FINDING.md) to the r2 candidate REBASED onto the D2 landing (parent redirect
# 17:07Z): base 275e458c (= integration/importer after S10-D D2 landed), chain 275e458c -> 645fb6db (= 4d31616f re-applied)
# -> dda794d7 (= 9149f823 re-applied; 6 delta blobs byte-identical), branch fa72/s11b-r2, land ref land/s11b-r2 (PR #563).
# Changes: two-commit chain check (HEAD^ = R1_HEAD, HEAD^^ = BASE, count 2) + r1->r2 diff check (exactly lifecycle.service.ts +
# lifecycle.service.spec.ts), delta 6 paths (+ test/scout/lifecycle/lifecycle.service.spec.ts), FREEZE-s11b regenerated for the
# 6 paths, EXPECT_LIFECYCLE_BLOB a4a79648, fresh clone worktrees/fa72-s11b-pg3. Stages, counts, bounds (outer 10200) unchanged.
# Full delta: DELTA-from-v1.diff. Text below is s11-lane v1.
# EXEC-FA72EFB2 S11-B S11-lane binding v1 — minimum substitution of the accepted S11-C v1 runner (execution/fa72efb2/s11c/binding/v1/
# s11-pg-proof.sh, sha256 5e4b29ec…1c1d, ran RC=0 15:49:19Z) to: base 7fdcbc04 (= integration/importer after S11-C landed),
# candidate 4d31616f (S11-B settle re-drive, one commit on BASE, PR #562), land ref land/s11b, clone source worktrees/fa72-s11b,
# fresh clone worktrees/fa72-s11b-pg1, FREEZE-s11b (the 5 S11-B paths == BASE..HEAD delta) plus FREEZE-v3 kept as "the 8 A1
# files are byte-identical at HEAD" and FREEZE-s11c re-used as "the 7 S11-C files are byte-identical at HEAD" (no longer the
# delta), and ONE added spec stage (test/scout/s11/settle-redrive.pg.spec.ts, J12-J15 + tenant scope, 8, default config,
# jest-redrive.log, bound 3000 s) after readiness and before the guard. rls 6 / journey 8 / readiness 6 run again as regressions
# (S11-B changes src/scout/lifecycle/lifecycle.service.ts and src/scout/scout.service.ts). Outer bound raised 7200 -> 10200 s.
# Runner filename kept s11-pg-proof.sh (the byte-copied fixture greps it in the runner cmdline). Full delta: DELTA-from-s11c-v1.diff.
# Text below is S11-C v1.
# EXEC-FA72EFB2 S11-C binding v1 — minimum substitution of the accepted A1 v3 runner (execution/fa72efb2/s11a1/binding/v3/
# s11-pg-proof.sh, sha256 201eced2…15f8, ran RC=0 15:27:54Z) to: base 3db615c0 (= integration/importer after S11-A1 landed),
# candidate 7fdcbc04 (S11-C, one commit on BASE), land ref land/s11c, clone source worktrees/fa72-s11c, fresh clone
# worktrees/fa72-s11c-pg1, FREEZE-s11c (the 7 S11-C paths == BASE..HEAD delta) plus FREEZE-v3 kept as "the 8 A1 files are
# byte-identical at HEAD", and ONE added spec stage (test/scout/s11/readiness.pg.spec.ts, 6, default config, jest-readiness.log)
# between journey-core (8, regression: S11-C changes extension-pair.service.ts) and the guard (94). The harness-base check now
# pins the A1 test/utils move HARNESS_BASE..BASE_HEAD to exactly the 6 FREEZE-v3 test/utils paths. Runner filename kept
# s11-pg-proof.sh (the byte-copied fixture greps it in the runner cmdline). Full delta: DELTA-from-s11a1-v3.diff. Text below is v3.
# EXEC-FA72EFB2 binding v3 — re-pin of the reviewed v2 runner (execution/d3a9f701/s11a1/binding/v2/s11-pg-proof.sh, sha256 e9b87830…)
# to: base 6a33df9b (C2 landed), candidate 3db615c0 (v2 + delta-GO PROOF_V2-fix.diff), land ref land/s11a1-v3, FREEZE-v3, this host's
# fresh runtime namespace execution/fa72efb2/runtime, lock inode 686480, donor = npm ci node_modules of the source clone (same hidden
# lock 05bc530a, client generated from the same S10-B schema => donor client == expected clone client; the v2 inequality guard is
# inverted accordingly). Every other line is v2 verbatim; the full delta is DELTA-from-v2.diff. Header below is the v1/v2 text.
# S11-A1 real-PG proof — execution binding v1 (EXEC-D3A9F701). SOURCE ONLY: NOT RUN, NOT GRANTED.
# Derived from the S10-B binding execution/d3a9f701/s10b/binding/v1/s10b-pg-proof.sh (filled, sha256 620f0458…f554, with all
# its review fixes: pins checked before anything can write the sentinel, under-lock rechecks, symlink-aware hook checks, no
# `cmd | grep -q` under pipefail, the pinned lock inode) plus the S10-B gate's O_EXCL STARTED; full diff in DELTA-from-s10b.diff.
# S11-A1 deltas: the candidate is a COMMITTED T2 test-only head c8ee9005 (one commit on BASE 711c1f8f = integration/importer
# tip, pushed as land/s11a1) in the clone source worktrees/d3a9-s11a1; this runner makes a FRESH CLEAN CLONE of it at
# $W (git clone --shared --no-checkout + detached checkout of EXPECT_HEAD; the bootstrap and pg-harness require the attested
# head checked out clean), copies the pinned donor node_modules into the clone (cp -a, real dir) and runs `prisma generate`
# IN THE CLONE (the donor holds the pre-S10-B client; the base schema is the landed S10-B schema d6d01f54, so the generated
# client must equal the S10-B gate's postgen client 2c819c8a/aca7a558). NO MIGRATION: HEAD:prisma/migrations == BASE's
# (7b6fe0ed, 173 dirs, last = S10-B). Lane s11: port 55648 / s11_super / g2_s11_disposable / cluster s11-disposable-pg17 /
# runtime/clusters/s11 + runtime/run/s11 (exactly the literals in test/utils/g2-s11-db.ts and g2-s11-bootstrap.sh at
# c8ee9005). Ports 55646 (S9-C), 55647 (S10-B), 55649 (S10-C) and every existing lane are refused/fingerprinted, never touched.
# Commands, each exactly once, no retry: the S11 bootstrap; jest -c jest.rls.config.js test/rls-g2-s11.spec.ts (6);
# jest test/scout/s11/journey-core.pg.spec.ts (8, default config; live only because G2_S11_DATABASE_URL is set — any skip
# fails the count); the static guard spec test/utils/g2-s11-db-guard.spec.ts (94, no DB: every G2_S11_* removed from its env).
# Single canonical lock holder: nonblocking flock on execution/test-validation.lock (fd 9, inode 692282) held until exit;
# the lock file is never deleted. STARTED is created O_EXCL right after the lock: from then on the run is consumed.
# TEARDOWN: when this run initialised the lane, it is stopped and then destroyed (marker-gated `s11-fixture.sh destroy`,
# which removes only $LANE/pg-data) at the end — on success and on any failure after init. pg.log / pg.log.pg_ctl /
# pg-data.initdb.log stay in $LANE and are copied into $R first. The clone $W is RETAINED (removal is a separate step).
# No autonomous cleanup is GUARANTEED: if the outer timeout kills bash, stop/destroy do not run; what governs is the observed
# terminal evidence (sentinel/log lines, `pgrep -cx postgres`, port listener count, survivor pid), not this header.
# Pipefail rule (S9C-PROOF-1): never `cmd | grep -q`; producer output is captured first, then grepped as a here-string.
# Inner stage bounds: clone 120 + cp 600 + generate 600 + init 60 + start 60 + bootstrap 900 + identity 8x15 + jest 1500 +
# 1500 + readiness 900 + settle-redrive 3000 + 300 + stop 75 + destroy 75 = 9810 s soft sum (S11-B: outer bound raised
# 7200 -> 10200 s, same 390 s margin). Redrive bound: J12/J13 fork harness workers whose own kill timer is 90 s
# (g2-s11-pg-harness.ts worker()); jest.setTimeout is 600 s per case; journey-core (8 cases, same harness) took 177 s in the
# S11-C run. 3000 s is ~17x that, and still leaves >2000 s if each of the 8 cases lost one worker to its 90 s kill cap;
# a timeout here is a failure (rc 124), never a retry.
# A2 bounds: true inner sum clone 120 + checkout 120 + cp 600 + generate 600 + init 60 + start 60 + bootstrap 900 + identity 8x15
# + rls 1500 + journey 1500 + readiness 900 + redrive 3000 + induction 3000 + guard 300 + stop 75 + destroy 75 = 12930 s; outer
# 13500 (570 s margin). Induction bound: 4 cases x jest.setTimeout 600 s = 2400 s hard jest ceiling + 600 s for boot/hooks; ~38
# ts-node worker processes (J09 15, J10 11, J11a 6, J11b 6; each harness worker has its own 90 s kill cap), cf. journey-core
# 8 cases 180 s and redrive 226 s in the v2 run. A timeout is a failure (rc 124), never a retry.
# Usage (under the separate single-run PG grant): timeout -k 30 7800 bash .../fa72efb2/s11d/binding/v1/s11-pg-proof.sh
set -uo pipefail
D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11d/binding/v1
RUNTIME_ROOT=/home/user/workspace/execution/fa72efb2/runtime                     # fa72efb2 runtime namespace (rt-setup-fa72efb2.sh RC=0); the fixture carries the same literal (cross-checked below)
SRC=/home/user/workspace/worktrees/fa72-s11d2                                    # clone source (read-only here): HEAD 38d0d366 (= origin/land/s11d, branch fa72/s11d-r2), clean, lefthook hooks
W=/home/user/workspace/worktrees/fa72-s11d2-pg1                                  # the fresh clone this run creates (must not exist)
DONOR_NM=/home/user/workspace/worktrees/fa72-s11a1/node_modules                  # read-only donor (npm ci + prisma generate at 3db615c0 by rt-setup-fa72efb2.sh); copied, never regenerated
R=$D/run; LOG=$R/s11-pg-proof.log; SENT=$R/s11-pg-proof.sentinel; STARTED_F=$R/STARTED
JLOG1=$R/jest-rls.log; JLOG2=$R/jest-journey.log; JLOG3=$R/jest-guard.log; JLOG4=$R/jest-readiness.log; JLOG5=$R/jest-redrive.log; JLOG6=$R/jest-induction.log; JLOG7=$R/jest-full.log; GENLOG=$R/prisma-generate.log
LOCK=/home/user/workspace/execution/test-validation.lock
# ---- pins (from the clone source at c8ee9005 and its FREEZE; compare only)
BASE_HEAD=54be96f18c314cae35d1e5d3000af9f06d693d81                               # S11-A2 r2 (proof RC=0 127/127; landed = integration/importer, PR #564) (= HEAD^^)
HARNESS_BASE=711c1f8f8b42157bca97f2a721557be7ef006667                            # harness literal (bootstrap BASE_HEAD / G2_S11_BASE_HEAD); must be an ancestor of HEAD
BASE_TREE=435fec782672214c7e8e81b2eb91f8f9266331b4
EXPECT_HEAD=38d0d366730331e4edf19a14cda8247435b89431                             # S11-D r2 candidate (J20 live-gated, roster-bridge qualifier, full range), two commits on BASE_HEAD
EXPECT_TREE=075c1513d54367abb796c35faac0bf2872acbace
R1_HEAD=a52d20d6827ae51da58505050ab0d29327659796                                 # S11-D r1 (J19 + J20) = HEAD^, parent BASE_HEAD
R1R2_DELTA="test/scout/s11/journey-full.pg.spec.ts"   # R1_HEAD..HEAD (the r2 review fixes), exactly
LAND_REF=refs/remotes/origin/land/s11d
EXPECT_MIGRATIONS_TREE=7b6fe0eda137ab1e3013b8a7c3b0c7637f69a521                  # HEAD:prisma/migrations == BASE:prisma/migrations (no candidate migration)
EXPECT_MIGRATIONS=173
S10B_MIGRATION=20270124000000_scout_run_observation_expand                       # last accepted migration directory
EXPECT_SPEC_BLOB=a4ba04ee14899d4db79c9a8b1a925a16a1eab72c                         # test/rls-g2-s11.spec.ts
EXPECT_JOURNEY_BLOB=95aee484b1f1a0e3aaf2e517476bd6b1c5eb2e75                      # test/scout/s11/journey-core.pg.spec.ts
EXPECT_GUARD_BLOB=3975aab13e40ebd43d38c1b772ae54718ceb9d41                        # test/utils/g2-s11-db-guard.spec.ts (S11-A2 edit)
EXPECT_BOOTSTRAP_BLOB=0e234b5835bdc060edf080928676c0994525598a                    # test/utils/g2-s11-bootstrap.sh (mode 100755)
EXPECT_DB_BLOB=3f04f5665c4ecc3f50c029be9d4b29cde0bff3b7                           # test/utils/g2-s11-db.ts
EXPECT_HARNESS_BLOB=927d73655c586a188556353a59fa1c5939cae09a                      # test/utils/g2-s11-harness.ts (S11-A2 r2 edit)
EXPECT_PGH_BLOB=ad32b5693390228bba001184acc2145b898879ac                          # test/utils/g2-s11-pg-harness.ts (S11-A2 edit)
EXPECT_WORKER_BLOB=562038a1127f82ec5eb285010f8d8eade4cb2c8e                       # test/utils/g2-s11-worker.cjs (S11-A2 edit)
EXPECT_INDUCTION_BLOB=1b9832bcbce7a51da6a58df60c312a5b0416f144                    # test/scout/s11/journey-induction.pg.spec.ts (S11-A2, new)
EXPECT_FULL_BLOB=ecfe8cef35eb99f955d7b0acdaddeb84d3cef8e2                         # test/scout/s11/journey-full.pg.spec.ts (S11-D r2, new; the delta)
EXPECT_JEST_RLS_BLOB=44c9691533be2ea27f9a416271d9ff400f7faa3f                     # jest.rls.config.js
EXPECT_JEST_BLOB=769a414698125340d6e347160f6ad81122cce863                         # jest.config.js
EXPECT_READINESS_BLOB=1afcb07d715b6bceca70daf046538e8ecdff6196                    # test/scout/s11/readiness.pg.spec.ts (S11-C)
EXPECT_SERVICE_BLOB=dfd2e2679d991532b7ac1c726ca10d8f0464e1a5                      # src/extension-pair/extension-pair.service.ts (S11-C)
EXPECT_DTO_BLOB=9eb9f3d3240453aa14a689b65344005f439ff3fc                          # src/extension-pair/extension-pair.dto.ts (S11-C)
EXPECT_REDRIVE_BLOB=aac3f7a8eb2fd49e65b858053fc71bea8c64d3ba                      # test/scout/s11/settle-redrive.pg.spec.ts (S11-B, new)
EXPECT_LIFECYCLE_BLOB=a4a79648b911a6099972f80a13f24837e630cbd7                    # src/scout/lifecycle/lifecycle.service.ts (S11-B r2)
EXPECT_SCOUTSVC_BLOB=9afaac48f250bfbceb21043f6005b6a89eb3ef23                     # src/scout/scout.service.ts (S11-B)
EXPECT_SCHEMA_BLOB=f86c1f5df722e855047899abd483f621b42dabe0                       # prisma/schema.prisma (== BASE, == S10-B)
EXPECT_SCHEMA_SHA=d6d01f546f6c7988d93bdd60588e421bf6ff0a56b312f85eee962e0a6be0eb96
S11_FREEZE=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11a1/binding/v3/FREEZE-v3.sha256
S11_FREEZE_SHA=e6e3a15a8f2d262bbeb06c7be3ec13581bbb59ca237936fbcd6278dbc9e24187        # A1 FREEZE-v3: 8 A1 lines; the 4 NOT in A2_A1_EDITS must be byte-identical at HEAD
A2_A1_EDITS="test/utils/g2-s11-db-guard.spec.ts test/utils/g2-s11-harness.ts test/utils/g2-s11-pg-harness.ts test/utils/g2-s11-worker.cjs"   # A1 files A2 rewrites (D-S11-6 sequential writer): pinned by FREEZE-s11a2, skipped in FREEZE-v3
A1_FILES="test/rls-g2-s11.spec.ts test/scout/s11/journey-core.pg.spec.ts test/utils/g2-s11-bootstrap.sh test/utils/g2-s11-db-guard.spec.ts test/utils/g2-s11-db.ts test/utils/g2-s11-harness.ts test/utils/g2-s11-pg-harness.ts test/utils/g2-s11-worker.cjs"
S11C_FREEZE=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11c/binding/v1/FREEZE-s11c.sha256
S11C_FREEZE_SHA=2d58f9d1d810c2871f09110c53c4305f255ffef3e4677bbac5c3f12f7d25137e       # FREEZE-s11c: the 7 S11-C files, byte-identical at HEAD (S11-B: no longer the delta)
S11C_FILES="docs/contracts/importer-openapi.json src/extension-pair/__tests__/readiness.spec.ts src/extension-pair/extension-pair.dto.ts src/extension-pair/extension-pair.service.ts test/contracts/importer-contract.spec.ts test/rls-c1-setup.spec.ts test/scout/s11/readiness.pg.spec.ts"
S11B_FREEZE=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s11-lane-v2/FREEZE-s11b.sha256
S11B_FREEZE_SHA=603ffa02a95d0e712bba45ca6cda4507295a9331bea827c7809ff0c9b2e4f1d0       # FREEZE-s11b v2: the 6 S11-B files, byte-identical at HEAD (S11-A2: no longer the delta)
S11B_FILES="src/scout/lifecycle/lifecycle.service.ts src/scout/scout.service.ts test/rls-g2-s10c.spec.ts test/scout/lifecycle/lifecycle.service.spec.ts test/scout/lifecycle/s11b-settle-redrive.spec.ts test/scout/s11/settle-redrive.pg.spec.ts"
S11A2_FREEZE=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11a2/binding/v2/FREEZE-s11a2.sha256
S11A2_FREEZE_SHA=51d901ef8689b396ed23074911dbea1daaf5058ebc54864135484b3d80047290      # FREEZE-s11a2 v2: the 12 S11-A2 files, byte-identical at HEAD (S11-D: no longer the delta)
S11A2_FILES="test/fixtures/scout/s11/s11-sources.ts test/fixtures/scout/s11/s11_second/induction-manifest.json test/fixtures/scout/s11/s11_second/mapping-spec.json test/fixtures/scout/s11/s11_second/native-rules.json test/fixtures/scout/s11/s11_second/signer-test-key.json test/fixtures/scout/s11/s11_second/staged-rows.json test/fixtures/scout/s11/s11_second/statements.json test/scout/s11/journey-induction.pg.spec.ts test/utils/g2-s11-db-guard.spec.ts test/utils/g2-s11-harness.ts test/utils/g2-s11-pg-harness.ts test/utils/g2-s11-worker.cjs"
S11D_FREEZE=$D/FREEZE-s11d.sha256
S11D_FREEZE_SHA=6819f7854806e862faa9bb12da5dd4f991a1d1150d517fe7caad8abf05cd1f9f      # FREEZE-s11d v1: the 1 S11-D path at HEAD r2 (paths == delta)
EXPECT_DELTA="test/scout/s11/journey-full.pg.spec.ts"
EXPECT_TESTS_RLS=6          # it( in test/rls-g2-s11.spec.ts (no each/skip/only/todo)
EXPECT_TESTS_JOURNEY=8      # it( in test/scout/s11/journey-core.pg.spec.ts (no each/skip/only/todo; describe.skip only when G2_S11_DATABASE_URL is unset)
EXPECT_TESTS_READINESS=6   # it( in test/scout/s11/readiness.pg.spec.ts (no each/skip/only/todo; describe.skip only when G2_S11_DATABASE_URL is unset)
EXPECT_TESTS_REDRIVE=8     # it( in test/scout/s11/settle-redrive.pg.spec.ts: J12, J12 edge, J13, J14, J15 a/b/c, tenant scope (no each/skip/only/todo; describe.skip only when G2_S11_DATABASE_URL is unset)
EXPECT_TESTS_INDUCTION=4   # it( in test/scout/s11/journey-induction.pg.spec.ts: J09, J10, J11(a), J11(b) (no each/skip/only/todo; describe.skip only when G2_S11_DATABASE_URL is unset)
EXPECT_TESTS_GUARD=95       # 11 it + it.each 61 + 20 + 3 (S11-A2 adds one it; A2 builder no-DB run on 03e7a234: 95 passed)
EXPECT_TESTS_FULL=6         # it( in test/scout/s11/journey-full.pg.spec.ts: J19 leg A, J19 leg B, J20 x4 (no each/skip/only/todo; describe.skip only when G2_S11_DATABASE_URL is unset)
EXPECT_FIXTURE_SHA=777e6ac3db359bc6ecb891c19da37943b8296ac9574ba48220ea9a94cfc31636  # sha256 of binding/v3/s11-fixture.sh (v2 fixture + RUNTIME_ROOT literal)
# ---- tool / dependency pins (identical to the S10-B binding; S10-B gate receipt for the generated client)
EXPECT_POSTGRES_SHA=23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a
EXPECT_INITDB_SHA=b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a
EXPECT_PGCTL_SHA=af53d826845af4679a0aaba2bda319f5e527f3b94f3794c67fa174049c9b9401
PSQL=/usr/lib/postgresql/18/bin/psql                # CB1: the real client binary, not the /usr/bin/psql pg_wrapper
EXPECT_PSQL_REAL_SHA=d1108fdb45b87f2313d7acfbb91a0a65ca97c6c2195f15d8ae9295121029ef67
EXPECT_LOCK_INODE=686480
EXPECT_NODE_SHA=a03953a7b16bff002b94d6fb58ada900b68241cbcaee6efc400b20dadd36dddc
EXPECT_PRISMA_CLI=6.19.3
EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44    # node_modules/.package-lock.json (donor and copy)
EXPECT_PKG_LOCK_SHA=b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55   # package-lock.json at HEAD
DONOR_CLIENT_SHA=2c819c8a8e2fd4afb59578893122b8e9c406bc1dc7821e643e7ef359c04aa56c      # donor .prisma/client/index.d.ts (rt-setup-fa72efb2 NM_OK; generated from the same S10-B schema d6d01f54)
DONOR_CLIENT_SCHEMA_SHA=aca7a558cd379c154e947447782f2858a9f898039298e34c30b886947aed42e5
EXPECT_NM_CLIENT_SHA=2c819c8a8e2fd4afb59578893122b8e9c406bc1dc7821e643e7ef359c04aa56c   # clone client index.d.ts after generate (= S10-B gate postgen_client, same schema d6d01f54, same CLI)
EXPECT_NM_CLIENT_SCHEMA_SHA=aca7a558cd379c154e947447782f2858a9f898039298e34c30b886947aed42e5
MIN_FREE_KB=1500000                                 # donor copy ~717M + clone ~28M + lane ~80M + logs
DIST=$RUNTIME_ROOT/pg17/dist; CLUSTERS=$RUNTIME_ROOT/clusters; LANE=$CLUSTERS/s11; SOCK=$RUNTIME_ROOT/run/s11
PORT=55648; DBNAME=g2_s11_disposable; ADMIN=s11_super; FIXPASS=s11_local_synthetic
MARKER=s11-disposable-pg17; DB_MARKER=s11-g2-journey-multi-host-synthetic-disposable-fixture-safe-to-drop
REFUSED_LANE_PORTS="55646 55647 55649"              # S9-C, S10-B, S10-C: never this lane's port, never probed or touched
FIX=$D/s11-fixture.sh
ENGINE=libquery_engine-debian-openssl-3.0.x.so.node
export GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1 GIT_TERMINAL_PROMPT=0 NODE_OPTIONS=--max-old-space-size=4096 CHECKPOINT_DISABLE=1 \
       PRISMA_HIDE_UPDATE_MESSAGE=1 PRISMA_GENERATE_SKIP_AUTOINSTALL=1 npm_config_offline=true npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false \
       npm_config_cache=$RUNTIME_ROOT/npm-cache XDG_CACHE_HOME=$RUNTIME_ROOT/xdg-cache
# S11-only identity: exactly the G2_S11_* names the guard/harness/bootstrap read (DATABASE_URL, CONFIRM, PASSWORD, PSQL,
# DATA_DIRECTORY, SERVER_VERSION, CANDIDATE_HEAD). G2_S11_WORKER is set by the pg-harness for its own children only.
for v in $(compgen -e | grep -E '^G2_' | grep -vE '^G2_S11_'); do unset "$v"; done
unset G2_S11_WORKER
export G2_S11_DATABASE_URL="postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=2" \
       G2_S11_CONFIRM="$DBNAME:$PORT" G2_S11_PASSWORD=$FIXPASS G2_S11_PSQL=$PSQL \
       G2_S11_DATA_DIRECTORY=$LANE/pg-data G2_S11_SERVER_VERSION=170006 \
       G2_S11_CANDIDATE_HEAD=$EXPECT_HEAD
G2_S11_VARS="G2_S11_DATABASE_URL G2_S11_CONFIRM G2_S11_PASSWORD G2_S11_PSQL G2_S11_DATA_DIRECTORY G2_S11_SERVER_VERSION G2_S11_CANDIDATE_HEAD G2_S11_WORKER"
export S11_RUNNER_PID=$$ S11_STOP_TIMEOUT=45
mkdir -p "$R"
# one-shot markers: an occupied path (file or any symlink, dangling or not) refuses
for f in "$SENT" "$STARTED_F"; do { [ -e "$f" ] || [ -L "$f" ]; } && { echo "REFUSED: $f exists; this proof runs once, no retry" >&2; exit 76; }; done
ts(){ date -u +%FT%TZ; }
log(){ echo "$*" | tee -a "$LOG"; }
sha(){ sha256sum "$1" | cut -c1-64; }
g(){ git -C "$SRC" "$@"; }
# ---- preconditions (read-only) BEFORE the lock and before anything can write STARTED or the sentinel: a stale pin exits
# with PRELOCK_REFUSED in $R/prelock.log and does NOT consume the run.
STAGE=preconditions-prelock; LOG=$R/prelock.log
fail(){ log "PRELOCK_REFUSED stage=$STAGE rc=$1 $(ts) (no lock taken, no STARTED, no sentinel; the run is not consumed)"; exit "$1"; }
log "PRELOCK_START $(ts) pid=$$ user=$(id -un) head_expect=$EXPECT_HEAD fixture_expect=$EXPECT_FIXTURE_SHA"
case "$BASE_HEAD$BASE_TREE$EXPECT_HEAD$EXPECT_TREE$R1_HEAD$EXPECT_MIGRATIONS_TREE$EXPECT_SPEC_BLOB$EXPECT_JOURNEY_BLOB$EXPECT_GUARD_BLOB$EXPECT_BOOTSTRAP_BLOB$EXPECT_DB_BLOB$EXPECT_HARNESS_BLOB$EXPECT_PGH_BLOB$EXPECT_WORKER_BLOB$EXPECT_READINESS_BLOB$EXPECT_SERVICE_BLOB$EXPECT_DTO_BLOB$EXPECT_REDRIVE_BLOB$EXPECT_INDUCTION_BLOB$EXPECT_LIFECYCLE_BLOB$EXPECT_SCOUTSVC_BLOB$EXPECT_FIXTURE_SHA$EXPECT_NM_CLIENT_SHA$EXPECT_NM_CLIENT_SCHEMA_SHA$PORT$RUNTIME_ROOT$S11_FREEZE_SHA$S11C_FREEZE_SHA$S11B_FREEZE_SHA$S11A2_FREEZE_SHA$EXPECT_FULL_BLOB$S11D_FREEZE_SHA" in *__*) log "PRECONDITION_FAIL pins not filled"; fail 70;; esac
for p in $REFUSED_LANE_PORTS; do [ "$PORT" != "$p" ] || { log "PRECONDITION_FAIL lane port $PORT is a refused lane port ($REFUSED_LANE_PORTS)"; fail 70; }; done
[ "$EXPECT_HEAD" != "$BASE_HEAD" ] || { log "PRECONDITION_FAIL EXPECT_HEAD is the base"; fail 70; }
[ "$EXPECT_NM_CLIENT_SHA" = "$DONOR_CLIENT_SHA" ] || { log "PRECONDITION_FAIL v3 donor was generated from the base schema; expected clone client must equal the donor client"; fail 70; }
[ "$(sha "$FIX")" = "$EXPECT_FIXTURE_SHA" ] || { log "PRECONDITION_FAIL fixture sha256 mismatch"; fail 70; }
FIXTXT=$(cat "$FIX")
grep -qx "RUNTIME_ROOT=$RUNTIME_ROOT" <<<"$FIXTXT" || { log "PRECONDITION_FAIL fixture RUNTIME_ROOT line != $RUNTIME_ROOT"; fail 70; }
grep -qx "PORT=$PORT; SUPER=$ADMIN; PASS=$FIXPASS; MARKER=$MARKER" <<<"$FIXTXT" || { log "PRECONDITION_FAIL fixture PORT/SUPER/PASS/MARKER line != runner"; fail 70; }
grep -qx "LANE=\$RUNTIME_ROOT/clusters/s11" <<<"$FIXTXT" && grep -qx "DATA=\$LANE/pg-data; LOG=\$LANE/pg.log; SOCK=\$RUNTIME_ROOT/run/s11" <<<"$FIXTXT" || { log "PRECONDITION_FAIL fixture lane/socket lines != clusters/s11 + run/s11"; fail 70; }
# clone source: committed candidate, two commits on BASE (r1, r2), pushed, clean, produced through the tracked lefthook hooks
[ -d "$SRC/.git" ] && [ ! -L "$SRC/.git" ] || { log "PRECONDITION_FAIL $SRC/.git is not a real repository directory"; fail 70; }
[ "$(g rev-parse HEAD)" = "$EXPECT_HEAD" ] || { log "PRECONDITION_FAIL source HEAD != $EXPECT_HEAD"; fail 70; }
[ "$(g rev-parse 'HEAD^{tree}')" = "$EXPECT_TREE" ] || { log "PRECONDITION_FAIL source tree mismatch"; fail 70; }
[ "$(g rev-parse HEAD^)" = "$R1_HEAD" ] && [ "$(g rev-parse HEAD^^)" = "$BASE_HEAD" ] && [ "$(g rev-list --count "$BASE_HEAD..HEAD")" = 2 ] || { log "PRECONDITION_FAIL chain != $BASE_HEAD -> $R1_HEAD -> HEAD (two commits)"; fail 70; }
[ "$(g diff --name-only "$R1_HEAD" HEAD | sort | tr '\n' ' ' | sed 's/ $//')" = "$R1R2_DELTA" ] || { log "PRECONDITION_FAIL r1..r2 delta != [$R1R2_DELTA]"; fail 70; }
g merge-base --is-ancestor "$HARNESS_BASE" "$BASE_HEAD" || { log "PRECONDITION_FAIL harness base $HARNESS_BASE is not an ancestor of $BASE_HEAD"; fail 70; }
[ -z "$(g diff --name-only "$HARNESS_BASE" "$BASE_HEAD" -- prisma package.json package-lock.json)" ] || { log "PRECONDITION_FAIL prisma/deps moved between the harness base and BASE_HEAD"; fail 70; }
A1_UTILS=$(tr ' ' '\n' <<<"$A1_FILES" | grep '^test/utils/' | tr '\n' ' ' | sed 's/ $//')
[ "$(g diff --name-only "$HARNESS_BASE" "$BASE_HEAD" -- test/utils | sort | tr '\n' ' ' | sed 's/ $//')" = "$A1_UTILS" ] || { log "PRECONDITION_FAIL test/utils moved between the harness base and BASE_HEAD beyond the 6 FREEZE-v3 A1 paths"; fail 70; }
[ "$(g rev-parse "$BASE_HEAD^{tree}")" = "$BASE_TREE" ] || { log "PRECONDITION_FAIL base tree mismatch"; fail 70; }
[ "$(g rev-parse --verify -q "$LAND_REF")" = "$EXPECT_HEAD" ] || { log "PRECONDITION_FAIL $LAND_REF != $EXPECT_HEAD (candidate not the pushed head)"; fail 70; }
[ -z "$(g status --porcelain --untracked-files=all)" ] || { log "PRECONDITION_FAIL clone source not clean"; fail 70; }
[ ! -e "$(g rev-parse --git-path MERGE_HEAD)" ] || { log "PRECONDITION_FAIL MERGE_HEAD present in source"; fail 70; }
[ -z "$(g config --get core.hooksPath)" ] || { log "PRECONDITION_FAIL core.hooksPath is set in the source (alternate hook directory refused)"; fail 70; }
H=$(g rev-parse --git-path hooks); case "$H" in /*) ;; *) H="$SRC/$H";; esac
[ "$H" = "$SRC/.git/hooks" ] && [ -d "$H" ] && [ ! -L "$H" ] || { log "PRECONDITION_FAIL source hooks dir [$H] is not the plain $SRC/.git/hooks directory"; fail 70; }
for hk in pre-commit commit-msg; do [ -f "$H/$hk" ] && [ ! -L "$H/$hk" ] || { log "PRECONDITION_FAIL $H/$hk is not a regular file (absent or a symlink)"; fail 70; }; done
grep -q lefthook "$H/pre-commit" 2>/dev/null && grep -q lefthook "$H/commit-msg" 2>/dev/null || { log "PRECONDITION_FAIL source hooks not lefthook (hookless commit)"; fail 70; }
HOOKSIG0="$(sha "$H/pre-commit"):$(sha "$H/commit-msg")"; log "PRELOCK source_hooks=$HOOKSIG0"
DELTA=$(g diff --name-only "$BASE_HEAD" HEAD | sort | tr '\n' ' ' | sed 's/ $//')
[ "$DELTA" = "$EXPECT_DELTA" ] || { log "PRECONDITION_FAIL BASE..HEAD delta [$DELTA] != [$EXPECT_DELTA]"; fail 70; }
[ -f "$S11_FREEZE" ] && [ "$(sha "$S11_FREEZE")" = "$S11_FREEZE_SHA" ] || { log "PRECONDITION_FAIL S11-A1 FREEZE absent or sha mismatch"; fail 70; }
FFILES=$(awk '{print $2}' "$S11_FREEZE" | sort | tr '\n' ' ' | sed 's/ $//'); [ "$FFILES" = "$A1_FILES" ] || { log "PRECONDITION_FAIL FREEZE-v3 paths != the 8 A1 files"; fail 70; }
while read -r s p; do case " $A2_A1_EDITS " in *" $p "*) continue;; esac; GOT=$(g show "HEAD:$p" | sha256sum | cut -c1-64); [ "$GOT" = "$s" ] || { log "PRECONDITION_FAIL A1 file $p at HEAD != FREEZE-v3"; fail 70; }; done < "$S11_FREEZE"
[ -f "$S11C_FREEZE" ] && [ "$(sha "$S11C_FREEZE")" = "$S11C_FREEZE_SHA" ] || { log "PRECONDITION_FAIL S11-C FREEZE absent or sha mismatch"; fail 70; }
CFILES=$(awk '{print $2}' "$S11C_FREEZE" | sort | tr '\n' ' ' | sed 's/ $//'); [ "$CFILES" = "$S11C_FILES" ] || { log "PRECONDITION_FAIL FREEZE-s11c paths != the 7 S11-C files"; fail 70; }
while read -r s p; do GOT=$(g show "HEAD:$p" | sha256sum | cut -c1-64); [ "$GOT" = "$s" ] || { log "PRECONDITION_FAIL S11-C file $p at HEAD != FREEZE-s11c"; fail 70; }; done < "$S11C_FREEZE"
[ -f "$S11B_FREEZE" ] && [ "$(sha "$S11B_FREEZE")" = "$S11B_FREEZE_SHA" ] || { log "PRECONDITION_FAIL S11-B FREEZE absent or sha mismatch"; fail 70; }
BFILES=$(awk '{print $2}' "$S11B_FREEZE" | sort | tr '\n' ' ' | sed 's/ $//'); [ "$BFILES" = "$S11B_FILES" ] || { log "PRECONDITION_FAIL FREEZE-s11b paths != the 6 S11-B files"; fail 70; }
while read -r s p; do GOT=$(g show "HEAD:$p" | sha256sum | cut -c1-64); [ "$GOT" = "$s" ] || { log "PRECONDITION_FAIL S11-B file $p at HEAD != FREEZE-s11b"; fail 70; }; done < "$S11B_FREEZE"
[ -f "$S11A2_FREEZE" ] && [ "$(sha "$S11A2_FREEZE")" = "$S11A2_FREEZE_SHA" ] || { log "PRECONDITION_FAIL S11-A2 FREEZE absent or sha mismatch"; fail 70; }
AFILES=$(awk '{print $2}' "$S11A2_FREEZE" | sort | tr '\n' ' ' | sed 's/ $//'); [ "$AFILES" = "$S11A2_FILES" ] || { log "PRECONDITION_FAIL FREEZE-s11a2 paths != the 12 S11-A2 files"; fail 70; }
while read -r s p; do GOT=$(g show "HEAD:$p" | sha256sum | cut -c1-64); [ "$GOT" = "$s" ] || { log "PRECONDITION_FAIL S11-A2 file $p at HEAD != FREEZE-s11a2"; fail 70; }; done < "$S11A2_FREEZE"
[ -f "$S11D_FREEZE" ] && [ "$(sha "$S11D_FREEZE")" = "$S11D_FREEZE_SHA" ] || { log "PRECONDITION_FAIL S11-D FREEZE absent or sha mismatch"; fail 70; }
DFILES=$(awk '{print $2}' "$S11D_FREEZE" | sort | tr '\n' ' ' | sed 's/ $//'); [ "$DFILES" = "$EXPECT_DELTA" ] || { log "PRECONDITION_FAIL FREEZE-s11d paths != delta"; fail 70; }
while read -r s p; do GOT=$(g show "HEAD:$p" | sha256sum | cut -c1-64); [ "$GOT" = "$s" ] || { log "PRECONDITION_FAIL $p at HEAD != FREEZE-s11d"; fail 70; }; done < "$S11D_FREEZE"
# prisma: no candidate migration; migrations tree == BASE's; 173 dirs, last = S10-B; manifests unchanged
[ -z "$(g diff --name-only "$BASE_HEAD" HEAD -- src prisma package.json package-lock.json)" ] || { log "PRECONDITION_FAIL src, prisma or dependency manifests differ from BASE"; fail 70; }
[ -z "$(g diff --name-only "$BASE_HEAD" HEAD -- test/utils)" ] || { log "PRECONDITION_FAIL BASE..HEAD touches test/utils (S11-D changes no harness file)"; fail 70; }
[ "$(g rev-parse HEAD:prisma/migrations)" = "$EXPECT_MIGRATIONS_TREE" ] && [ "$(g rev-parse "$BASE_HEAD:prisma/migrations")" = "$EXPECT_MIGRATIONS_TREE" ] || { log "PRECONDITION_FAIL migrations tree != $EXPECT_MIGRATIONS_TREE at HEAD or BASE"; fail 70; }
HMIG=$(g ls-tree -d --name-only HEAD prisma/migrations/ | sed 's|^prisma/migrations/||' | LC_ALL=C sort)
[ "$(wc -l <<<"$HMIG")" = "$EXPECT_MIGRATIONS" ] && [ "$(tail -1 <<<"$HMIG")" = "$S10B_MIGRATION" ] || { log "PRECONDITION_FAIL HEAD migrations != $EXPECT_MIGRATIONS/$S10B_MIGRATION"; fail 70; }
# harness literals at HEAD must equal this runner's lane identity
BOOT=$(g show HEAD:test/utils/g2-s11-bootstrap.sh) && DBTS=$(g show HEAD:test/utils/g2-s11-db.ts) && PGH=$(g show HEAD:test/utils/g2-s11-pg-harness.ts) \
  && SPEC=$(g show HEAD:test/rls-g2-s11.spec.ts) && JOUR=$(g show HEAD:test/scout/s11/journey-core.pg.spec.ts) && GRD=$(g show HEAD:test/utils/g2-s11-db-guard.spec.ts) \
  && READY=$(g show HEAD:test/scout/s11/readiness.pg.spec.ts) && REDRIVE=$(g show HEAD:test/scout/s11/settle-redrive.pg.spec.ts) \
  && IND=$(g show HEAD:test/scout/s11/journey-induction.pg.spec.ts) && FULL=$(g show HEAD:test/scout/s11/journey-full.pg.spec.ts) || { log "PRECONDITION_FAIL cannot read harness bytes at HEAD"; fail 70; }
grep -qx "BASE_HEAD=$HARNESS_BASE" <<<"$BOOT" && grep -qx "CLUSTER_MARKER=$MARKER" <<<"$BOOT" && grep -qx "DB_MARKER=$DB_MARKER" <<<"$BOOT" \
  && grep -qx "EXPECTED_MIGRATIONS=$EXPECT_MIGRATIONS" <<<"$BOOT" && grep -qx "S10B_MIGRATION=$S10B_MIGRATION" <<<"$BOOT" || { log "PRECONDITION_FAIL bootstrap literals != runner"; fail 70; }
grep -qF "export const G2_S11_DATABASE = '$DBNAME';" <<<"$DBTS" && grep -qF "export const G2_S11_ROLE = '$ADMIN';" <<<"$DBTS" \
  && grep -qF "export const G2_S11_CLUSTER_MARKER = '$MARKER';" <<<"$DBTS" && grep -qF "'$DB_MARKER'" <<<"$DBTS" \
  && grep -qF "export const G2_S11_BASE_HEAD = '$HARNESS_BASE';" <<<"$DBTS" || { log "PRECONDITION_FAIL g2-s11-db.ts literals != runner"; fail 70; }
! grep -qE "^ +'$PORT',\$" <<<"$DBTS" || { log "PRECONDITION_FAIL lane port $PORT is in the S11 guard's REFUSED_PORTS"; fail 70; }
for p in 55646 55647; do grep -qE "^ +'$p',\$" <<<"$DBTS" || { log "PRECONDITION_FAIL port $p missing from the S11 guard's REFUSED_PORTS"; fail 70; }; done
grep -qF "export const EXPECTED_MIGRATIONS = $EXPECT_MIGRATIONS;" <<<"$PGH" && grep -qF "export const S10B_MIGRATION = '$S10B_MIGRATION';" <<<"$PGH" || { log "PRECONDITION_FAIL g2-s11-pg-harness.ts literals != runner"; fail 70; }
grep -qF "const live = process.env.G2_S11_DATABASE_URL ? describe : describe.skip;" <<<"$JOUR" || { log "PRECONDITION_FAIL journey spec live switch not the pinned form"; fail 70; }
grep -qF "const live = process.env.G2_S11_DATABASE_URL ? describe : describe.skip;" <<<"$READY" || { log "PRECONDITION_FAIL readiness spec live switch not the pinned form"; fail 70; }
grep -qF "const live = process.env.G2_S11_DATABASE_URL ? describe : describe.skip;" <<<"$REDRIVE" || { log "PRECONDITION_FAIL settle-redrive spec live switch not the pinned form"; fail 70; }
grep -qF "const live = process.env.G2_S11_DATABASE_URL ? describe : describe.skip;" <<<"$IND" || { log "PRECONDITION_FAIL induction spec live switch not the pinned form"; fail 70; }
grep -qF "const live = process.env.G2_S11_DATABASE_URL ? describe : describe.skip;" <<<"$FULL" || { log "PRECONDITION_FAIL full spec live switch not the pinned form"; fail 70; }
BADPAT='\.(only|todo)\(|\bx(it|describe)\(|\bf(it|describe)\(|\bit\.skip\(|\btest\.skip\(|it\.each'
! grep -qE "$BADPAT|describe\.skip\(" <<<"$SPEC" || { log "PRECONDITION_FAIL rls spec carries skip/only/todo/each"; fail 70; }
! grep -qE "$BADPAT" <<<"$JOUR" || { log "PRECONDITION_FAIL journey spec carries skip/only/todo/each"; fail 70; }
! grep -qE "$BADPAT" <<<"$READY" || { log "PRECONDITION_FAIL readiness spec carries skip/only/todo/each"; fail 70; }
! grep -qE "$BADPAT" <<<"$REDRIVE" || { log "PRECONDITION_FAIL settle-redrive spec carries skip/only/todo/each"; fail 70; }
! grep -qE "$BADPAT" <<<"$IND" || { log "PRECONDITION_FAIL induction spec carries skip/only/todo/each"; fail 70; }
! grep -qE "$BADPAT" <<<"$FULL" || { log "PRECONDITION_FAIL full spec carries skip/only/todo/each"; fail 70; }
N1=$(grep -cE '^\s*it\(' <<<"$SPEC" || true); N2=$(grep -cE '^\s*it\(' <<<"$JOUR" || true); N3=$(grep -cE '^\s*it\(' <<<"$READY" || true); N4=$(grep -cE '^\s*it\(' <<<"$REDRIVE" || true); N5=$(grep -cE '^\s*it\(' <<<"$IND" || true)
[ "$N1" = "$EXPECT_TESTS_RLS" ] && [ "$N2" = "$EXPECT_TESTS_JOURNEY" ] && [ "$N3" = "$EXPECT_TESTS_READINESS" ] && [ "$N4" = "$EXPECT_TESTS_REDRIVE" ] && [ "$N5" = "$EXPECT_TESTS_INDUCTION" ] || { log "PRECONDITION_FAIL it() counts rls=$N1 journey=$N2 readiness=$N3 redrive=$N4 induction=$N5 != $EXPECT_TESTS_RLS/$EXPECT_TESTS_JOURNEY/$EXPECT_TESTS_READINESS/$EXPECT_TESTS_REDRIVE/$EXPECT_TESTS_INDUCTION"; fail 70; }
N6=$(grep -cE '^\s*it\(' <<<"$FULL" || true); [ "$N6" = "$EXPECT_TESTS_FULL" ] || { log "PRECONDITION_FAIL it() count full=$N6 != $EXPECT_TESTS_FULL"; fail 70; }
for pin in "test/rls-g2-s11.spec.ts $EXPECT_SPEC_BLOB" "test/scout/s11/journey-core.pg.spec.ts $EXPECT_JOURNEY_BLOB" "test/utils/g2-s11-db-guard.spec.ts $EXPECT_GUARD_BLOB" \
           "test/utils/g2-s11-bootstrap.sh $EXPECT_BOOTSTRAP_BLOB" "test/utils/g2-s11-db.ts $EXPECT_DB_BLOB" "test/utils/g2-s11-harness.ts $EXPECT_HARNESS_BLOB" \
           "test/utils/g2-s11-pg-harness.ts $EXPECT_PGH_BLOB" "test/utils/g2-s11-worker.cjs $EXPECT_WORKER_BLOB" "jest.rls.config.js $EXPECT_JEST_RLS_BLOB" \
           "jest.config.js $EXPECT_JEST_BLOB" "prisma/schema.prisma $EXPECT_SCHEMA_BLOB" "test/scout/s11/readiness.pg.spec.ts $EXPECT_READINESS_BLOB" \
           "src/extension-pair/extension-pair.service.ts $EXPECT_SERVICE_BLOB" "src/extension-pair/extension-pair.dto.ts $EXPECT_DTO_BLOB" \
           "test/scout/s11/settle-redrive.pg.spec.ts $EXPECT_REDRIVE_BLOB" "src/scout/lifecycle/lifecycle.service.ts $EXPECT_LIFECYCLE_BLOB" "src/scout/scout.service.ts $EXPECT_SCOUTSVC_BLOB" \
           "test/scout/s11/journey-induction.pg.spec.ts $EXPECT_INDUCTION_BLOB" "test/scout/s11/journey-full.pg.spec.ts $EXPECT_FULL_BLOB"; do set -- $pin
  [ "$(g rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL $1 blob mismatch"; fail 70; }; done
# the fresh clone and the lane must not exist yet
{ [ -e "$W" ] || [ -L "$W" ]; } && { log "PRECONDITION_FAIL $W exists (fresh clone only; never reuse)"; fail 70; }
{ [ -e "$LANE" ] || [ -L "$LANE" ]; } && { log "PRECONDITION_FAIL $LANE exists (fresh lane only; never adopt)"; fail 70; }
# donor: real dir, pinned hidden lock and pre-S10-B client
[ -d "$DONOR_NM" ] && [ ! -L "$DONOR_NM" ] || { log "PRECONDITION_FAIL donor $DONOR_NM absent or a symlink"; fail 70; }
[ "$(sha "$DONOR_NM/.package-lock.json")" = "$EXPECT_NM_LOCK_SHA" ] || { log "PRECONDITION_FAIL donor hidden lock != pin"; fail 70; }
[ "$(sha "$DONOR_NM/.prisma/client/index.d.ts" 2>/dev/null)" = "$DONOR_CLIENT_SHA" ] && [ "$(sha "$DONOR_NM/.prisma/client/schema.prisma" 2>/dev/null)" = "$DONOR_CLIENT_SCHEMA_SHA" ] || { log "PRECONDITION_FAIL donor client != pinned rt-setup client"; fail 70; }
[ "$(g show HEAD:package-lock.json | sha256sum | cut -c1-64)" = "$EXPECT_PKG_LOCK_SHA" ] || { log "PRECONDITION_FAIL package-lock.json at HEAD != pin"; fail 70; }
[ "$(g show HEAD:prisma/schema.prisma | sha256sum | cut -c1-64)" = "$EXPECT_SCHEMA_SHA" ] || { log "PRECONDITION_FAIL schema at HEAD != d6d01f54"; fail 70; }
DPV=$("$DONOR_NM/.bin/prisma" --version 2>/dev/null || true); DPV=$(awk '/^prisma /{print $3}' <<<"$DPV")
[ "$DPV" = "$EXPECT_PRISMA_CLI" ] || { log "PRECONDITION_FAIL donor prisma CLI '$DPV' != $EXPECT_PRISMA_CLI"; fail 70; }
FREE=$(df -Pk "$(dirname "$W")" | awk 'NR==2{print $4}'); [ "$FREE" -ge "$MIN_FREE_KB" ] || { log "PRECONDITION_FAIL free ${FREE}K < ${MIN_FREE_KB}K"; fail 70; }
# tools
[ -x "$DIST/bin/postgres" ] && [ -x "$DIST/bin/initdb" ] && [ -x "$DIST/bin/pg_ctl" ] || { log "PRECONDITION_FAIL PG17 dist absent at $DIST"; fail 70; }
[ "$(sha "$DIST/bin/postgres")" = "$EXPECT_POSTGRES_SHA" ] && [ "$(sha "$DIST/bin/initdb")" = "$EXPECT_INITDB_SHA" ] && [ "$(sha "$DIST/bin/pg_ctl")" = "$EXPECT_PGCTL_SHA" ] || { log "PRECONDITION_FAIL PG binary sha256 != pin"; fail 70; }
PGV=$(LD_LIBRARY_PATH=$DIST/lib "$DIST/bin/postgres" --version 2>/dev/null); [ "${PGV##* }" = 17.6 ] || { log "PRECONDITION_FAIL server not 17.6: $PGV"; fail 70; }
[ -x "$PSQL" ] && [ "$(sha "$PSQL")" = "$EXPECT_PSQL_REAL_SHA" ] || { log "PRECONDITION_FAIL $PSQL absent or sha256 != pin"; fail 70; }
PSQLV=$("$PSQL" --version); grep -qE "^psql \(PostgreSQL\) 18\." <<<"$PSQLV" || { log "PRECONDITION_FAIL psql major != 18: $PSQLV"; fail 70; }
NODE=$(command -v node); [ "$(sha "$(readlink -f "$NODE")")" = "$EXPECT_NODE_SHA" ] || { log "PRECONDITION_FAIL node sha256 != pin ($NODE)"; fail 70; }
NODEV=$(node --version); grep -q '^v20\.' <<<"$NODEV" || { log "PRECONDITION_FAIL node major != 20"; fail 70; }
RGV=$(rg --version 2>/dev/null | head -1); grep -q '^ripgrep ' <<<"$RGV" || { log "PRECONDITION_FAIL rg not on PATH (J20 runs scripts/s10-core-diff-gate.sh, which requires rg)"; fail 70; }; log "PRELOCK rg=$(command -v rg) $RGV"
[ "$(readlink -f "$RUNTIME_ROOT")" = "$RUNTIME_ROOT" ] || { log "PRECONDITION_FAIL $RUNTIME_ROOT is not a real path"; fail 70; }
grep -q '^result=success' "$RUNTIME_ROOT/pg17/PROVENANCE.txt" 2>/dev/null || { log "PRECONDITION_FAIL pg17 PROVENANCE.txt lacks result=success"; fail 70; }
log "PRECONDITIONS_OK (pre-lock) $(ts) server='$PGV' psql='$PSQLV' node=$NODEV prisma=$DPV free=${FREE}K"
# ---- lock, then O_EXCL STARTED (from here on the run is consumed)
LOG=$R/s11-pg-proof.log
for f in "$SENT" "$STARTED_F"; do { [ -e "$f" ] || [ -L "$f" ]; } && { echo "REFUSED: $f exists; this proof runs once, no retry" >&2; exit 76; }; done
[ -e "$LOCK" ] || { echo "REFUSED: canonical lock file $LOCK absent; never created here" >&2; exit 75; }
exec 9>>"$LOCK"; flock -n 9 || { echo "REFUSED: canonical lock busy ($LOCK)" >&2; exit 75; }
[ "$(stat -c %i "$LOCK")" = "$EXPECT_LOCK_INODE" ] || { echo "REFUSED: $LOCK inode $(stat -c %i "$LOCK") != $EXPECT_LOCK_INODE" >&2; exit 75; }
( set -C; echo "STARTED $(ts) pid=$$ head=$EXPECT_HEAD" > "$STARTED_F" ) 2>/dev/null || { echo "REFUSED: $STARTED_F appeared (or is a symlink) at lock time" >&2; exit 76; }   # O_EXCL
STAGE=preconditions; INITED=0; PG_UP=0
teardown(){ # stop (if up) then marker-gated destroy (if this run initialised the lane); logs copied first
  local src=0 drc=0
  for f in pg.log pg.log.pg_ctl pg-data.initdb.log; do [ -f "$LANE/$f" ] && cp -p "$LANE/$f" "$R/lane-$f" 2>/dev/null; done
  if [ "$PG_UP" = 1 ]; then timeout -k 30 75 bash "$FIX" stop >>"$LOG" 2>&1 || src=$?; log "TEARDOWN_STOP rc=$src $(ts)"; [ "$src" = 0 ] && PG_UP=0; fi
  if [ "$INITED" = 1 ] && [ "$PG_UP" = 0 ]; then timeout -k 30 75 bash "$FIX" destroy >>"$LOG" 2>&1 || drc=$?; log "TEARDOWN_DESTROY rc=$drc $(ts)"; [ "$drc" = 0 ] && INITED=0; fi
  local ssl; ssl=$(ss -ltn 2>/dev/null || true)
  log "TEARDOWN_STATE postgres_procs=$(pgrep -cx postgres || true) port${PORT}_listeners=$(grep -c ":$PORT " <<<"$ssl" || true) survivor_pid=$(head -1 "$LANE/pg-data/postmaster.pid" 2>/dev/null || echo none) datadir=$( [ -e "$LANE/pg-data" ] && echo PRESENT || echo absent)"
  [ "$src" = 0 ] && [ "$drc" = 0 ] && [ "$PG_UP" = 0 ] && [ "$INITED" = 0 ]; }
finish(){ local rc=$1
  ( cd "$R" && sha256sum s11-pg-proof.log prelock.log STARTED $(for f in jest-rls.log jest-journey.log jest-readiness.log jest-redrive.log jest-induction.log jest-full.log jest-guard.log prisma-generate.log lane-pg.log lane-pg.log.pg_ctl lane-pg-data.initdb.log; do [ -e "$f" ] && echo "$f"; done) > RECEIPTS.sha256 2>/dev/null )
  echo "RC=$rc STAGE=$STAGE END=$(ts) HEAD=$(git -C "$W" rev-parse HEAD 2>/dev/null || echo no-clone) LOCK_INODE=$(stat -c %i "$LOCK")" >"$SENT"
  log "END rc=$rc stage=$STAGE $(ts) (lock fd9 held until this exit; receipts=$R/RECEIPTS.sha256)"; exit "$rc"; }
fail(){ local rc=$1; log "STOP_FIRST_FAILURE stage=$STAGE rc=$rc $(ts)"; teardown || log "TEARDOWN_INCOMPLETE (see TEARDOWN_* lines; lane may need a separate marker-gated destroy)"; finish "$rc"; }
listeners(){ local s; s=$(ss -ltn 2>/dev/null || true); grep -c ":$PORT " <<<"$s" || true; }
csig(){ find "$1/.prisma" "$1/@prisma/client" -printf '%P %s %T@ %m\n' 2>/dev/null | sort | sha256sum | cut -c1-64; }
log "START $(ts) pid=$$ user=$(id -un) lock=$LOCK(fd9, inode $(stat -c %i "$LOCK")) head_expect=$EXPECT_HEAD fixture_expect=$EXPECT_FIXTURE_SHA"
# under-lock recheck of everything that could have moved since the pre-lock preconditions (cheap, read-only)
[ "$(sha "$FIX")" = "$EXPECT_FIXTURE_SHA" ] && [ "$(g rev-parse HEAD)" = "$EXPECT_HEAD" ] && [ -z "$(g status --porcelain --untracked-files=all)" ] \
  && [ "$(g rev-parse --verify -q "$LAND_REF")" = "$EXPECT_HEAD" ] && [ "$(sha "$S11_FREEZE")" = "$S11_FREEZE_SHA" ] && [ "$(sha "$S11C_FREEZE")" = "$S11C_FREEZE_SHA" ] && [ "$(sha "$S11B_FREEZE")" = "$S11B_FREEZE_SHA" ] && [ "$(sha "$S11A2_FREEZE")" = "$S11A2_FREEZE_SHA" ] && [ "$(sha "$S11D_FREEZE")" = "$S11D_FREEZE_SHA" ] \
  && [ "$(sha "$DONOR_NM/.prisma/client/index.d.ts" 2>/dev/null)" = "$DONOR_CLIENT_SHA" ] && [ ! -e "$W" ] && [ ! -L "$W" ] && [ ! -e "$LANE" ] && [ ! -L "$LANE" ] \
  || { log "PRECONDITION_FAIL fixture/source/FREEZE/donor/clone-path/lane moved after the pre-lock preconditions"; fail 70; }
[ -z "$(g config --get core.hooksPath)" ] && [ "$(g rev-parse --git-path hooks)" = .git/hooks ] && [ -d "$H" ] && [ ! -L "$H" ] \
  && [ -f "$H/pre-commit" ] && [ ! -L "$H/pre-commit" ] && [ -f "$H/commit-msg" ] && [ ! -L "$H/commit-msg" ] \
  && [ "$(sha "$H/pre-commit"):$(sha "$H/commit-msg")" = "$HOOKSIG0" ] \
  || { log "PRECONDITION_FAIL source hook identity/hooksPath changed after the pre-lock preconditions"; fail 70; }
# ---- step 1 preflight (read-only): lane absent; port free; no postgres at all; every other lane fingerprinted, never started
STAGE=preflight
[ ! -e "$SOCK" ] || [ -z "$(ls -A "$SOCK" 2>/dev/null)" ] || { log "PREFLIGHT_FAIL socket dir $SOCK not empty"; fail 71; }
L=$(listeners); [ "$L" = 0 ] || { log "PREFLIGHT_FAIL port $PORT listeners=$L"; fail 71; }
P=$(pgrep -cx postgres || true); [ "$P" = 0 ] || { log "PREFLIGHT_FAIL postgres procs=$P (another lane live; this proof never shares a server)"; fail 71; }
OTHER0=""
for d in "$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-*/clusters/*/; do [ -d "$d" ] || continue; [ "${d%/}" != "$LANE" ] || continue; n=${d#$RUNTIME_ROOT/}; n=${n%/}
  [ ! -e "$d/pg-data/postmaster.pid" ] && [ ! -L "$d/pg-data/postmaster.pid" ] || { log "PREFLIGHT_FAIL $n postmaster.pid present"; fail 71; }
  h="$n:$(sha "$d/pg-data/postgresql.conf" 2>/dev/null || echo ABSENT):$(sha "$d/pg-data/global/pg_control" 2>/dev/null || echo ABSENT)"; OTHER0="$OTHER0 $h"
  log "PREFLIGHT other_lane=$h (must be unchanged at end; never started)"; done
SRCSIG0=$(g status --porcelain --untracked-files=all | sha256sum | cut -c1-64):$(g rev-parse HEAD)
DSIG0=$(csig "$DONOR_NM")
log "PREFLIGHT_OK $(ts) lane=absent port$PORT=free postgres_procs=0 refused_lane_ports=[$REFUSED_LANE_PORTS] donor_sig=$DSIG0"
# ---- step 2 fresh clean clone at the attested head (objects shared read-only with the source; no hooks run)
STAGE=clone
timeout -k 30 120 git -c core.hooksPath=/dev/null clone --quiet --shared --no-checkout "$SRC" "$W" >>"$LOG" 2>&1; rc=$?; log "CLONE rc=$rc $(ts)"; [ $rc = 0 ] || fail 71
timeout -k 30 120 git -C "$W" -c core.hooksPath=/dev/null checkout --quiet --detach "$EXPECT_HEAD" >>"$LOG" 2>&1; rc=$?; log "CHECKOUT rc=$rc $(ts)"; [ $rc = 0 ] || fail 71
[ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] && [ "$(git -C "$W" rev-parse 'HEAD^{tree}')" = "$EXPECT_TREE" ] && [ "$(git -C "$W" rev-parse HEAD^)" = "$R1_HEAD" ] && [ "$(git -C "$W" rev-parse HEAD^^)" = "$BASE_HEAD" ] \
  && [ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] && [ "$(git -C "$W" rev-parse HEAD:prisma/migrations)" = "$EXPECT_MIGRATIONS_TREE" ] \
  || { log "CLONE_FAIL clone head/tree/parent/clean/migrations mismatch"; fail 71; }
[ "$(find "$W/prisma/migrations" -mindepth 1 -maxdepth 1 -type d | wc -l)" = "$EXPECT_MIGRATIONS" ] || { log "CLONE_FAIL migration dir count"; fail 71; }
[ "$(sha "$W/package-lock.json")" = "$EXPECT_PKG_LOCK_SHA" ] && [ "$(sha "$W/prisma/schema.prisma")" = "$EXPECT_SCHEMA_SHA" ] || { log "CLONE_FAIL package-lock/schema bytes"; fail 71; }
# ---- step 3 isolated node_modules: real copy of the donor (donor read-only), then prisma generate IN THE CLONE
STAGE=node_modules
( cd "$W" && timeout -k 30 600 cp -a "$DONOR_NM" node_modules ) >>"$LOG" 2>&1; rc=$?; log "CP_A rc=$rc $(ts) entries=$(ls "$W/node_modules" 2>/dev/null | wc -l)"; [ $rc = 0 ] || fail 71
[ -d "$W/node_modules" ] && [ ! -L "$W/node_modules" ] || { log "NM_FAIL node_modules is not a real directory"; fail 71; }
for d in node_modules node_modules/@prisma/client node_modules/.prisma node_modules/.prisma/client node_modules/prisma; do
  [ -d "$W/$d" ] && [ ! -L "$W/$d" ] || { log "NM_FAIL $d missing or a symlink"; fail 71; }
  case "$(readlink -f "$W/$d")" in "$W"/*) ;; *) log "NM_FAIL $d resolves outside $W"; fail 71;; esac; done
ABS_LINKS=$(find "$W/node_modules/.prisma" "$W/node_modules/@prisma" "$W/node_modules/prisma" -type l -lname '/*' 2>/dev/null)
[ -z "$ABS_LINKS" ] || { log "NM_FAIL absolute symlinks in the copied prisma tree: $(echo $ABS_LINKS)"; fail 71; }
[ "$(sha "$W/node_modules/.package-lock.json")" = "$EXPECT_NM_LOCK_SHA" ] || { log "NM_FAIL copied hidden lock != pin"; fail 71; }
PV=$(cd "$W" && ./node_modules/.bin/prisma --version 2>/dev/null || true); PV=$(awk '/^prisma /{print $3}' <<<"$PV")
[ "$PV" = "$EXPECT_PRISMA_CLI" ] || { log "NM_FAIL clone prisma CLI '$PV' != $EXPECT_PRISMA_CLI"; fail 71; }
STAGE=prisma_generate
( cd "$W" && timeout -k 30 600 ./node_modules/.bin/prisma generate --schema prisma/schema.prisma ) >"$GENLOG" 2>&1; rc=$?
log "PRISMA_GENERATE_INCLONE rc=$rc $(ts) out=$W/node_modules/.prisma/client (never the donor)"; [ $rc = 0 ] || { tail -30 "$GENLOG" >>"$LOG"; fail 71; }
[ "$(csig "$DONOR_NM")" = "$DSIG0" ] && [ "$(sha "$DONOR_NM/.prisma/client/index.d.ts")" = "$DONOR_CLIENT_SHA" ] || { log "DONOR_CHANGED during generate; refusing"; fail 71; }
NM_IDX=$(sha "$W/node_modules/.prisma/client/index.d.ts" 2>/dev/null || echo absent); NM_SCH=$(sha "$W/node_modules/.prisma/client/schema.prisma" 2>/dev/null || echo absent)
NM_ENG=$(sha "$W/node_modules/.prisma/client/$ENGINE" 2>/dev/null || echo absent); PIN_ENG=$(sha "$W/node_modules/@prisma/engines/$ENGINE" 2>/dev/null || echo absent)
log "POSTGEN_CLIENT index_dts=$NM_IDX schema=$NM_SCH engine=$NM_ENG pinned_engine=$PIN_ENG"
[ "$NM_IDX" = "$EXPECT_NM_CLIENT_SHA" ] && [ "$NM_SCH" = "$EXPECT_NM_CLIENT_SCHEMA_SHA" ] || { log "NM_FAIL generated client != pinned S10-B postgen client"; fail 71; }
[ "$NM_ENG" = "$PIN_ENG" ] && [ "$NM_ENG" != absent ] || { log "NM_FAIL clone client engine != pinned @prisma/engines copy"; fail 71; }
for b in jest ts-node prisma; do [ -x "$W/node_modules/.bin/$b" ] || { log "NM_FAIL node_modules/.bin/$b missing"; fail 71; }; done
[ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] || { log "NM_FAIL clone not clean after copy/generate"; fail 71; }
PORC0=$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)
log "CLONE_READY $(ts) head=$EXPECT_HEAD jest=$(cd "$W" && ./node_modules/.bin/jest --version) ts_node=$(cd "$W" && ./node_modules/.bin/ts-node --version 2>/dev/null)"
# ---- step 4 init (bound 60 s) / step 5 start (bound 60 s)
STAGE=fixture-init; INITED=1; timeout -k 30 60 bash "$FIX" init >>"$LOG" 2>&1; rc=$?; log "FIXTURE_INIT rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
IL=$(cat "$LOG"); grep -q "^S11_FIXTURE_INIT_OK data=$LANE/pg-data port=$PORT superuser=$ADMIN cluster_name=$MARKER socket=$SOCK " <<<"$IL" || { log "FIXTURE_INIT marker missing"; fail 72; }
STAGE=fixture-start; PG_UP=1; timeout -k 30 60 bash "$FIX" start >>"$LOG" 2>&1; rc=$?; log "FIXTURE_START rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
IL=$(cat "$LOG"); grep -q "^S11_FIXTURE_START_OK pid=" <<<"$IL" || { log "FIXTURE_START marker missing"; fail 72; }
# ---- step 6 S11 bootstrap from the clone (roles, marked DB, extensions, 173 accepted migrations via the candidate's
#      `prisma migrate deploy` as postgres, S7-L/S8-B/S10-B objects asserted, clone client VERIFIED structurally) (bound 900 s)
STAGE=bootstrap
( cd "$W" && timeout -k 30 900 bash test/utils/g2-s11-bootstrap.sh bootstrap ) >>"$LOG" 2>&1; rc=$?; log "BOOTSTRAP rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
IL=$(cat "$LOG"); grep -q "^G2_S11_BOOTSTRAP_OK" <<<"$IL" && grep -q "^CANDIDATE_HEAD=$EXPECT_HEAD" <<<"$IL" && grep -q "^CANDIDATE_CLIENT_VERIFIED dir=$W/node_modules/.prisma/client " <<<"$IL" \
  || { log "BOOTSTRAP marker/candidate/client line missing"; fail 72; }
# ---- step 7 identity (read-only, bound 15 s each; admin login via PGPASSWORD only)
STAGE=identity
psqlq(){ PGPASSWORD=$FIXPASS timeout -k 30 15 "$PSQL" -X -v ON_ERROR_STOP=1 -At "postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME" -c "$1" 2>>"$LOG"; }
DD=$(psqlq 'SHOW data_directory'); [ "$DD" = "$G2_S11_DATA_DIRECTORY" ] || { log "IDENTITY_FAIL data_directory='$DD'"; fail 73; }
VN=$(psqlq 'SHOW server_version_num'); [ "$VN" = 170006 ] || { log "IDENTITY_FAIL server_version_num='$VN'"; fail 73; }
CN=$(psqlq "SELECT current_setting('cluster_name')"); [ "$CN" = "$MARKER" ] || { log "IDENTITY_FAIL cluster_name='$CN'"; fail 73; }
DM=$(psqlq "SELECT shobj_description(oid,'pg_database') FROM pg_database WHERE datname=current_database()"); [ "$DM" = "$DB_MARKER" ] || { log "IDENTITY_FAIL db marker='$DM'"; fail 73; }
MC=$(psqlq 'SELECT count(*) FROM "_prisma_migrations" WHERE finished_at IS NOT NULL AND rolled_back_at IS NULL'); [ "$MC" = "$EXPECT_MIGRATIONS" ] || { log "IDENTITY_FAIL applied migrations=$MC"; fail 73; }
ML=$(psqlq 'SELECT max(migration_name) FROM "_prisma_migrations" WHERE finished_at IS NOT NULL AND rolled_back_at IS NULL'); [ "$ML" = "$S10B_MIGRATION" ] || { log "IDENTITY_FAIL last applied migration='$ML'"; fail 73; }
NTB=$(psqlq "SELECT count(*) FROM pg_class WHERE relnamespace='public'::regnamespace AND relkind='r' AND relname IN ('ScoutRunDeclaration','ScoutRunObservation','ScoutRunSettledBasis') AND relrowsecurity AND relforcerowsecurity")
[ "$NTB" = 3 ] || { log "IDENTITY_FAIL S10-B tables with ENABLE+FORCE RLS=$NTB (want 3)"; fail 73; }
PT=$(psqlq 'SELECT inet_server_port()'); [ "$PT" = "$PORT" ] || { log "IDENTITY_FAIL inet_server_port='$PT'"; fail 73; }
log "IDENTITY_OK $(ts) data_directory=$DD server_version_num=$VN cluster_name=$CN applied_migrations=$MC last=$ML s10b_tables_forced_rls=$NTB"
# ---- step 8 the two specs (full, guard), each exactly once; no --testTimeout/--forceExit/--detectOpenHandles/coverage/retry
GUARD_RE='requires its explicitly confirmed|unsupported or ambiguous connection option|requires a plain fixture password|connects only as a fixture matrix login role|candidate head, not the accepted base|not the attested candidate|uncommitted changes|G2 proof requires|server identity mismatch'
jcheck(){ # <label> <log> <rc> <expected count>
  local J; J=$(cat "$2"); log "JEST_END $1 rc=$3 $(ts)"; grep -E '^(Test Suites|Tests|Snapshots|Time):' <<<"$J" | tee -a "$LOG"
  grep -qE "$GUARD_RE" <<<"$J" && log "GUARD_REFUSAL_OBSERVED_IN_JEST_LOG $1"
  [ "$3" = 0 ] || fail "$3"
  grep -qE "^Test Suites: +1 passed, 1 total\$" <<<"$J" || { log "JEST_SUITE_FAIL $1 (want 'Test Suites: 1 passed, 1 total')"; fail 72; }
  grep -qE "^Tests: +$4 passed, $4 total\$" <<<"$J" || { log "JEST_COUNT_FAIL $1 want 'Tests: $4 passed, $4 total' (got: $(grep -E '^Tests:' <<<"$J" | head -1))"; fail 72; }
  log "JEST_COUNT_OK $1 tests=$4"; }
STAGE=jest-full; log "JEST_START full $(ts) cmd='./node_modules/.bin/jest --runInBand --ci test/scout/s11/journey-full.pg.spec.ts'"
( cd "$W" && timeout -k 30 4200 ./node_modules/.bin/jest --runInBand --ci test/scout/s11/journey-full.pg.spec.ts ) >"$JLOG7" 2>&1; JRC=$?
jcheck full "$JLOG7" "$JRC" "$EXPECT_TESTS_FULL"
STAGE=jest-guard; log "JEST_START guard $(ts) cmd='env -u G2_S11_* ./node_modules/.bin/jest --runInBand --ci test/utils/g2-s11-db-guard.spec.ts' (no DB)"
UNSET=(); for v in $G2_S11_VARS; do UNSET+=(-u "$v"); done
( cd "$W" && timeout -k 30 300 env "${UNSET[@]}" ./node_modules/.bin/jest --runInBand --ci test/utils/g2-s11-db-guard.spec.ts ) >"$JLOG3" 2>&1; JRC=$?
jcheck guard "$JLOG3" "$JRC" "$EXPECT_TESTS_GUARD"
# ---- step 9 teardown: stop then marker-gated destroy of $LANE/pg-data (logs kept in $LANE and copied into $R)
STAGE=teardown
teardown || { log "TEARDOWN_FAIL"; fail 74; }
P=$(pgrep -cx postgres || true); L=$(listeners)
[ "$P" = 0 ] && [ "$L" = 0 ] && [ ! -e "$LANE/pg-data" ] && [ ! -L "$LANE/pg-data" ] || { log "TEARDOWN_STATE_FAIL postgres_procs=$P listeners=$L"; fail 74; }
log "TEARDOWN_OK postgres_procs=0 port$PORT=free datadir=destroyed logs=$LANE/{pg.log,pg.log.pg_ctl,pg-data.initdb.log} (+ copies in $R)"
# ---- step 10 post (read-only)
STAGE=post
OTHER1=""
for d in "$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-*/clusters/*/; do [ -d "$d" ] || continue; [ "${d%/}" != "$LANE" ] || continue; n=${d#$RUNTIME_ROOT/}; n=${n%/}
  [ ! -e "$d/pg-data/postmaster.pid" ] || { log "POST_FAIL $n postmaster.pid appeared"; fail 74; }
  OTHER1="$OTHER1 $n:$(sha "$d/pg-data/postgresql.conf" 2>/dev/null || echo ABSENT):$(sha "$d/pg-data/global/pg_control" 2>/dev/null || echo ABSENT)"; done
[ "$OTHER0" = "$OTHER1" ] || { log "POST_FAIL other lanes changed: before=[$OTHER0] after=[$OTHER1]"; fail 74; }
log "POST other_lanes_unchanged=[${OTHER0:-none}]"
[ "$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)" = "$PORC0" ] && [ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] || { log "POST_FAIL clone changed"; fail 74; }
log "POST clone_worktrees=$(git -C "$W" worktree list --porcelain | grep -c '^worktree ') (1 = J20 scratch worktree removed; record only)"
[ "$(g status --porcelain --untracked-files=all | sha256sum | cut -c1-64):$(g rev-parse HEAD)" = "$SRCSIG0" ] || { log "POST_FAIL clone source changed"; fail 74; }
[ "$(sha "$W/node_modules/.prisma/client/index.d.ts")" = "$EXPECT_NM_CLIENT_SHA" ] || { log "POST_FAIL clone client changed during the proof"; fail 74; }
[ "$(csig "$DONOR_NM")" = "$DSIG0" ] || { log "POST_FAIL donor client tree changed during the proof"; fail 74; }
log "POST_OK $(ts) lock_still_held_fd9 inode=$(stat -c %i "$LOCK") clone_retained=$W"
STAGE=done; finish 0
