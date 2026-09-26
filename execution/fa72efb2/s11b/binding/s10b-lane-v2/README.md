# S11-B real-PG proof binding — S10-B lane v2 (R36 flip) (EXEC-FA72EFB2) — SOURCE ONLY, NOT RUN

Built by the T3 binding builder under `s11b/S11B_BINDING_V2_BUILD_GRANT.md` and the parent redirect below. Nothing was run: no
runner, fixture, jest, bootstrap, PostgreSQL or lock. Pins were re-derived read-only in `/home/user/workspace/worktrees/fa72-s11b`
(GIT_OPTIONAL_LOCKS=0) and the fa72efb2 runtime.

## Parent redirect (recorded as required)
The grant named candidate 9149f823 on base 7fdcbc04. At 17:07Z (mail from parent fa72efb2) the candidate changed: D2 landed on
integration/importer at 275e458c (17:04:56Z), and S11-B r1+r2 were re-applied onto it on branch `fa72/s11b-r2`:
`275e458c -> 645fb6db (= 4d31616f re-applied, tree fb6ef752) -> dda794d7 (= 9149f823 re-applied)`, pushed as `land/s11b-r2`
(PR #563; land/s11b / #562 closed as superseded). Builder-verified: the 6 delta blobs at dda794d7 equal 9149f823's; `git diff
9149f823 dda794d7` = exactly D2's 8 pure additions (= `git diff 7fdcbc04 275e458c`).

## Provenance
- Template: `s10b-lane-v1/s10b-lane-pg-proof.sh` (sha256 2a5c5d195b91e39548dee4b06acbb09ee49dada0f3856e73793c3424d4f32a3b; reviewed GO
  in `S11B_BINDING_REVIEW.md`; never ran; `sha256sum -c` of v1 BINDING rc 0).
- Built by `.build-s10b-lane-v2.py <FREEZE sha>`: 20 exact substitutions (19 single-match + the branch ref, asserted 3 matches).
  The script also asserts the fixture sha is the v1 value. Full delta: `DELTA-from-v1.diff` (runner 8 hunks + launcher 1 + FREEZE 1;
  421 -> 432 lines). `bash -n` rc 0 (runner, fixture, launcher).
- `s10b-lane-fixture.sh` is a byte copy of v1 (`cmp` identical, sha256 2fc8012d…a5db2a); `EXPECT_FIXTURE_SHA` unchanged (its comment
  still says "sha256 of s10b-lane-v1/s10b-lane-fixture.sh", which is true of these bytes).

## Changed pins (everything else is v1 verbatim)
| pin | s10b-lane v1 | s10b-lane v2 (verified at fa72-s11b) |
|---|---|---|
| D | s11b/binding/s10b-lane-v1 | s11b/binding/s10b-lane-v2 |
| branch (pre-lock ref + symbolic-ref, under-lock ref) | fa72/s11b-r1 | fa72/s11b-r2 (= dda794d7; SRC HEAD symbolic-ref) |
| BASE_HEAD / BASE_TREE | 7fdcbc04 / a802231e | 275e458ca5a6b3684bb6ec83edb2a854056a6fd0 / 6267ef6a57225af187f5a21fb8a2c3cc3fd6103e |
| EXPECT_HEAD / EXPECT_TREE | 4d31616f / 366efa9f | dda794d7e8bee0482a7ad373795fcc51dcf54bb5 / 802e1c196c7a0bd27f091218407f5f0b031dd760 |
| new R1_HEAD (in the pins-filled and 40-hex guards) | — | 645fb6db022f2ef6299ed4aa2bcd3f409d2a8298 |
| chain check | HEAD^ = BASE, count 1 | HEAD^ = R1_HEAD, HEAD^^ = BASE, count 2 (pre-lock and on the fresh clone) |
| new r1->r2 check (R1R2_DELTA) | — | `git diff --name-only R1_HEAD HEAD` = exactly lifecycle.service.ts + lifecycle.service.spec.ts |
| LAND_REF / EXPECT_LAND_REF | land/s11b = 4d31616f | refs/remotes/origin/land/s11b-r2 = dda794d7 |
| EXPECT_DELTA / S11B_OWNED | 5 paths | 6 paths (+ test/scout/lifecycle/lifecycle.service.spec.ts), all 100644 |
| FREEZE-s11b / S11B_FREEZE_SHA | ca321526…24f4 | own-dir copy 603ffa02a95d0e712bba45ca6cda4507295a9331bea827c7809ff0c9b2e4f1d0 (6 lines; `cp -p` of s11-lane-v2's) |
| launcher | header said "S11-A1 v3" | header names S11-B S10-B-lane v2; `exec timeout -k 30 4500 bash "$D/s10b-lane-pg-proof.sh"` |
| comments | BASE 7fdcbc04 | BASE_CONTRACT_BLOB / FROZEN_P_BLOB comments now cite 275e458c (values unchanged) |

Unchanged pins re-verified at dda794d7 / 275e458c: EXPECT_S10C_SPEC_BLOB 4a5a6bb6 (R36 flip; BASE 50a0deae); the 10 S10-B proof-file
blobs (spec b89fec1c, db/pg-harness/harness/worker/fixtures/bootstrap, schema, migration, down); contract 1a5deca5 at BASE and HEAD
(state unchanged, no docs delta); FROZEN (e9c71f09…) 28/29 blob-equal at HEAD plus the premise-P path at 9b5de374 (BASE = HEAD);
S10B_HEAD a2c74e90, HARNESS_BASE_HEAD a4af8e33 and 7746a877 ancestors of BASE; `S10B_HEAD..HEAD -- prisma package.json
package-lock.json test/utils/g2-s10b-*` empty; HARNESS_BASE_HEAD..HEAD prisma = exactly schema + the S10-B migration pair; migrations
tree 7b6fe0ed (173); hooks 67e578d1… / 18e15068…, hooksPath unset; it() s10b 24 / s10c 8; jest.rls.config.js 44c96915.

## D2-in-BASE impact (checked)
The D2-inherited mechanics of this runner (lock/prestart/clone/donor-copy/bootstrap; the 8-blob D2 checks were already removed in v1)
reference only BASE_HEAD/HEAD and the S10-B literals; with BASE = 275e458c every such check was re-evaluated and holds. D2's 8 added
paths touch no prisma, manifests, test/utils, jest config, docs, or either lane spec; the g2-s10b bootstrap diff vs a4af8e33 is
unchanged. The jest command names the two specs explicitly, so the new `test/scout/s10/s10-unseen.pg.spec.ts` is not collected.

## Expected counts — unchanged from v1
bootstrap once -> identity -> ONE jest run `./node_modules/.bin/jest -c jest.rls.config.js --runInBand --ci test/rls-g2-s10b.spec.ts
test/rls-g2-s10c.spec.ts`: `Tests: 32 passed, 32 total`, `Test Suites: 2 passed, 2 total` (24 + 8; PASS set = both specs).

Usage (parent only, under a separate single-run PG grant): `bash launch-when-free.sh` or
`timeout -k 30 4500 bash /home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s10b-lane-v2/s10b-lane-pg-proof.sh`

## Lane decision
Lane `runtime/clusters/s11b-s10b` + `run/s11b-s10b` (port 55649) kept: both ABSENT (never created). W = worktrees/fa72-s11b-pg2
(absent). Refused ports 55646/55647/55648 unchanged.

## Open risks
- **B — SRC is a shared, moving worktree.** CLASS: launch precondition. CONCRETE HARM: fa72-s11b changed branch/HEAD twice during this
  build; this runner additionally requires `symbolic-ref HEAD = refs/heads/fa72/s11b-r2`. Any drift = PRECONDITION_FAIL rc 70 (not
  consumed) or, after STARTED, a consumed failed run. DECISION BLOCKED: launching. MINIMUM CLOSURE: parent freezes fa72-s11b at
  fa72/s11b-r2 = dda794d7, clean, until both lane runs end. EXECUTION UNLOCKED: the S10-B-lane v2 run.
- C — port 55649 and marker `s10b-disposable-pg17` are shared with the stopped `clusters/s10d2/pg-data` and `clusters/s10d2-v2/pg-data`
  (both no postmaster.pid). Safe: single lock, port-free and zero-postgres preflight, other lanes fingerprinted. Do not start them.
- C — `clusters/s11b-s10b/pg-data` is retained after stop (template); the S11-lane runner fingerprints it (no block). Either order works;
  the two runs cannot overlap (one lock) — launch them one after the other.
- C — the lifecycle unit specs are frozen but not run in this lane.
- C — inherited stale comments (inode 692282, "D2 changes no prisma", D2 v1 header) are never compared.
