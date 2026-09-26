# S11-B real-PG proof binding — S11 lane v2 (EXEC-FA72EFB2) — SOURCE ONLY, NOT RUN

Built by the T3 binding builder under `s11b/S11B_BINDING_V2_BUILD_GRANT.md` and the parent redirect below. Nothing was run: no
runner, fixture, jest, bootstrap, PostgreSQL or lock. Every pin below was re-derived read-only (`git rev-parse` / `git diff` /
`git show | sha256sum` / `sha256sum` / `ls`) in `/home/user/workspace/worktrees/fa72-s11b` (GIT_OPTIONAL_LOCKS=0) and the fa72efb2 runtime.

## Parent redirect (recorded as required)
The grant named candidate 9149f823 on base 7fdcbc04. At 17:07Z (mail from parent fa72efb2) the candidate changed: D2 landed on
integration/importer at 275e458c (17:04:56Z), and S11-B r1+r2 were re-applied onto it on branch `fa72/s11b-r2`:
`275e458c -> 645fb6db (= 4d31616f re-applied, tree fb6ef752) -> dda794d7 (= 9149f823 re-applied)`, pushed as
`land/s11b-r2` (PR #563; land/s11b / #562 closed as superseded, not force-pushed). This binding pins the rebased composition.
Builder-verified: all 6 delta blobs at dda794d7 equal those at 9149f823; `git diff 9149f823 dda794d7` = exactly D2's 8 pure
additions (A only, 100644: 3 `s10_unseen.json` sources, 3 `test/fixtures/scout/s10_unseen/*`, `test/scout/s10/s10-unseen.{e2e,pg}.spec.ts`),
which are identical to `git diff 7fdcbc04 275e458c`. Authorship of 645fb6db/dda794d7: Bradley Gleave author+committer.

## Provenance
- Template: `s11-lane-v1/s11-pg-proof.sh` (sha256 ef0024b2036e5a2ba9dca1fb487f3bd5c4f3ac601454f1aac2916e6d370ef36a; reviewed GO in
  `S11B_BINDING_REVIEW.md`; its run failed only on candidate J13, `PROOF_A_V1_FINDING.md`; `sha256sum -c` of v1 BINDING rc 0).
- Built by `.build-s11-lane-v2.py <FREEZE sha>`: 16 exact substitutions, each asserted to match exactly once. Full delta:
  `DELTA-from-v1.diff` (runner 8 hunks + launcher 1 + FREEZE 1; 399 -> 410 lines). `bash -n` rc 0 (runner, fixture, launcher).
- `s11-fixture.sh` is a byte copy of v1 (`cmp` identical, sha256 777e6ac3…1636), so `EXPECT_FIXTURE_SHA` is unchanged.

## Changed pins (everything else is v1 verbatim)
| pin | s11-lane v1 | s11-lane v2 (verified at fa72-s11b) |
|---|---|---|
| D | s11b/binding/s11-lane-v1 | s11b/binding/s11-lane-v2 |
| W | worktrees/fa72-s11b-pg1 (v1 run clone, retained) | worktrees/fa72-s11b-pg3 (absent) |
| BASE_HEAD / BASE_TREE | 7fdcbc04 / a802231e | 275e458ca5a6b3684bb6ec83edb2a854056a6fd0 / 6267ef6a57225af187f5a21fb8a2c3cc3fd6103e |
| EXPECT_HEAD / EXPECT_TREE | 4d31616f / 366efa9f | dda794d7e8bee0482a7ad373795fcc51dcf54bb5 / 802e1c196c7a0bd27f091218407f5f0b031dd760 |
| new R1_HEAD | — | 645fb6db022f2ef6299ed4aa2bcd3f409d2a8298 (= HEAD^; its parent = BASE) |
| chain check | HEAD^ = BASE | HEAD^ = R1_HEAD, HEAD^^ = BASE, `rev-list --count BASE..HEAD` = 2 (pre-lock and on the fresh clone) |
| new r1->r2 check (R1R2_DELTA) | — | `git diff --name-only R1_HEAD HEAD` = exactly `src/scout/lifecycle/lifecycle.service.ts test/scout/lifecycle/lifecycle.service.spec.ts` |
| LAND_REF | refs/remotes/origin/land/s11b = 4d31616f | refs/remotes/origin/land/s11b-r2 = dda794d7 |
| EXPECT_DELTA | 5 paths | 6 paths (+ test/scout/lifecycle/lifecycle.service.spec.ts), all 100644, == `git diff --name-only BASE HEAD` |
| FREEZE-s11b / S11B_FREEZE_SHA | ca321526…24f4 (5 lines) | own-dir `FREEZE-s11b.sha256` 603ffa02a95d0e712bba45ca6cda4507295a9331bea827c7809ff0c9b2e4f1d0 (6 lines; lifecycle 8e7db85c…, spec cbb0d0b2…; other 4 unchanged) |
| EXPECT_LIFECYCLE_BLOB | 974e2c83 | a4a79648b911a6099972f80a13f24837e630cbd7 |
| launcher | header said "S11-A1 v3" | header names S11-B S11-lane v2; `exec timeout -k 30 10200 bash "$D/s11-pg-proof.sh"` (listed in BINDING.sha256) |

Unchanged pins re-verified at dda794d7 / 275e458c: all 17 blob pins (A1 8, jest.rls/jest config, readiness, S11-C service/dto,
redrive aac3f7a8, scout.service 9afaac48, schema f86c1f5d); FREEZE-v3 (e6e3a15a…) 8/8 and FREEZE-s11c (2d58f9d1…) 7/7 byte-equal at
HEAD; migrations tree 7b6fe0ed at BASE and HEAD (173 dirs, last 20270124000000_scout_run_observation_expand); schema d6d01f54…,
package-lock b7fed5ed…; HARNESS_BASE 711c1f8f ancestor of BASE, HARNESS_BASE..BASE test/utils = the 6 A1 utils, no prisma/deps
change; BASE..HEAD touches no prisma/manifests/test/utils/docs; hooks lefthook (67e578d1… / 18e15068…), core.hooksPath unset;
SRC on fa72/s11b-r2 at dda794d7, clean, no MERGE_HEAD (at 17:10Z); it() counts rls 6 / journey 8 / readiness 6 / redrive 8.

## D2-in-BASE impact (checked)
D2's 8 added paths touch no test/utils, prisma, manifests, jest config, docs, or any S11/S10-B lane spec. The S11 guard spec reads
`src/scout/reconstruct/sources` slugs (now + `s10_unseen`) and asserts no S11 harness file contains a slug: `grep` finds
`s10_unseen`/`truecoach` in none of the 7 s11Files; its it.each tables are static literals, so the guard count stays 94. The
g2-s11 bootstrap compares against its literal 711c1f8f (prisma/deps unchanged since). No S11-lane pin changes because of D2.

## Expected counts (one command each, no retry) — unchanged from v1
bootstrap (G2_S11_BOOTSTRAP_OK) -> identity -> rls `jest.rls.config.js test/rls-g2-s11.spec.ts` **6** -> journey **8** -> readiness
**6** -> settle-redrive `test/scout/s11/settle-redrive.pg.spec.ts` **8** (J12, J12 edge, J13, J14, J15 a/b/c, tenant scope) -> guard
**94** (no DB) -> teardown -> post. Total 122 tests / 5 suites. J13 is the case the r2 fix targets (v1: HTTP 500 P2010).

Usage (parent only, under a separate single-run PG grant): `bash launch-when-free.sh` or
`timeout -k 30 10200 bash /home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s11-lane-v2/s11-pg-proof.sh`

## Lane decision
Lane `runtime/clusters/s11` (port 55648, socket `run/s11`) is reused: `clusters/s11` is ABSENT now (v1 leftovers archived to
`s11-lane-v1/run/post-teardown`, POST_TEARDOWN.sha256); `run/s11` exists and is empty (preflight allows it, as in v1).
`runtime/clusters` holds s10d2 and s10d2-v2 (both stopped: no postmaster.pid; cluster_name s10b-disposable-pg17, port 55649) —
fingerprinted, not blocking. W = fa72-s11b-pg3 (absent; pg1 = the v1 clone, pg2 reserved for the S10-B lane).

## Open risks
- **B — SRC is a shared, moving worktree.** CLASS: launch precondition. CONCRETE HARM: fa72-s11b moved twice during this build
  (fa72/s11b-r1@9149f823 -> checkout of fa72/s11b-r2@275e458c with a staged cherry-pick at 17:05Z -> dda794d7). Any HEAD/branch/clean
  change before launch makes the runner PRECONDITION_FAIL rc 70 pre-lock (not consumed); a change after the clone fails POST rc 74.
  DECISION BLOCKED: launching this binding. MINIMUM CLOSURE: the parent freezes fa72-s11b at fa72/s11b-r2 = dda794d7, clean,
  until both S11-B lane runs end. EXECUTION UNLOCKED: the S11-lane v2 run.
- **B — outer timeout.** Use 10200 (the launcher does). A 7200 launcher can kill bash mid-stage before teardown.
- C — after this run, `clusters/s11` will again hold pg.log / pg.log.pg_ctl / pg-data.initdb.log (teardown destroys only pg-data);
  a later S11-lane binding needs the same archive-and-remove step.
- C — neither lane runs the unit specs `test/scout/lifecycle/lifecycle.service.spec.ts` (r2 tests) or `s11b-settle-redrive.spec.ts`;
  they are frozen via FREEZE-s11b only (their unit results are in `s11b_r2_jest.log`).
- C — the 3000 s redrive bound is a practical bound, not the 8x600 s jest ceiling; a timeout is a failure (rc 124).
- C — v1 header history comments (inode 692282, "pins from c8ee9005", soft-sum 9810 vs true 9930) are inherited, never compared.
- C — s11-lane-v1 and s10b-lane-v1 are superseded (candidate 4d31616f / base 7fdcbc04); do not launch s10b-lane-v1.
