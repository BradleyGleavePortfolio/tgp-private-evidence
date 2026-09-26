# S11-B bindings v2 build report (T3 builder, parent fa72efb2) — SOURCE ONLY

Grant: `s11b/S11B_BINDING_V2_BUILD_GRANT.md` + parent redirect mail (17:07Z): build against the rebased composition
BASE 275e458c (D2 landed) -> 645fb6db (r1) -> dda794d7 (r2), branch fa72/s11b-r2, LAND_REF land/s11b-r2 (PR #563) — not 9149f823.
Nothing was executed: no runner, fixture, jest, bootstrap, PostgreSQL, npm, or lock. worktrees/fa72-s11b was only read. The
evidence repo is not committed (`git status`: `?? execution/fa72efb2/s11b/binding/s11-lane-v2/`, `?? …/s10b-lane-v2/`).

## Binding A — `s11b/binding/s11-lane-v2/` (BINDING.sha256 bcdaa03b6abeaeaaa8c01aea5f258b507677b49691df931c4ad6d7479d5d16b4, `sha256sum -c` rc 0)
| file | sha256 | note |
|---|---|---|
| s11-pg-proof.sh (755) | 2e683690880f0e1c25dfd21b390ef3fa8b76bd8fadc06695f044e569c0ee1327 | 410 lines, 16 count-asserted subs from v1 |
| s11-fixture.sh | 777e6ac3db359bc6ecb891c19da37943b8296ac9574ba48220ea9a94cfc31636 | byte copy of v1 |
| FREEZE-s11b.sha256 | 603ffa02a95d0e712bba45ca6cda4507295a9331bea827c7809ff0c9b2e4f1d0 | 6 paths |
| DELTA-from-v1.diff | 952d3e845911af28e2962fea4e213167ab11dc5d73c996229199f6c838a7a481 | runner 8 hunks, launcher 1, FREEZE 1 |
| README.md | fd9d83017acc0e456dcecadac1776a0b2bedfbcf5c2b1e8e95dbbe4a747ce0ff | pins, redirect, counts, lane, risks |
| .build-s11-lane-v2.py | 53b509795d85518ecaacb0dca180ba2a36d0e635ae69b10f8a58429772fc770f | |
| launch-when-free.sh | bc80182a128e06a4bc9cdcdfec5881630f0b7c6988f512aefb0c93ac363d2ba6 | `exec timeout -k 30 10200 bash "$D/s11-pg-proof.sh"` |

## Binding B — `s11b/binding/s10b-lane-v2/` (BINDING.sha256 3fc92780513aa97c15dd11afdd9715ec832234b84a68638b2ab36499415cfe76, rc 0)
| file | sha256 | note |
|---|---|---|
| s10b-lane-pg-proof.sh (755) | 162d9a1da4c615a489b36657c81543ea2acd9c645c17eb6a1965d763fe460cd2 | 432 lines, 20 count-asserted subs from v1 |
| s10b-lane-fixture.sh | 2fc8012dea542751228a9b1b98e6367fa40cd3d5849e73bcd6f2019147a5db2a | byte copy of v1 (EXPECT_FIXTURE_SHA unchanged) |
| FREEZE-s11b.sha256 | 603ffa02a95d0e712bba45ca6cda4507295a9331bea827c7809ff0c9b2e4f1d0 | cp -p of A's |
| DELTA-from-v1.diff | 9f75b3b6ae2a10f02790e4bf3cd1d2f2ec1124200d0d7502144a0ae64cbfa7b1 | runner 8 hunks, launcher 1, FREEZE 1 |
| README.md | 3619ff4f7ad5123f7bcad50aaebf301ae901b19338dbf7096c6c05107ed5f741 | |
| .build-s10b-lane-v2.py | 894493bc864f6b53507afb3722ce91f17d4c669dad0004e5762e82e7ca472624 | |
| launch-when-free.sh | 4439dca7c002fe60b8ba98a9001106f5ddeaa797adde9b9aa73b1fbfd9e897a5 | `exec timeout -k 30 4500 bash "$D/s10b-lane-pg-proof.sh"` |

Launchers are now listed in BINDING.sha256 and their headers name the right binding (closes v1 review C1).

## Changed pins (both lanes unless noted)
BASE 275e458ca5a6b3684bb6ec83edb2a854056a6fd0 / tree 6267ef6a57225af187f5a21fb8a2c3cc3fd6103e; HEAD dda794d7e8bee0482a7ad373795fcc51dcf54bb5 /
tree 802e1c196c7a0bd27f091218407f5f0b031dd760; new R1_HEAD 645fb6db022f2ef6299ed4aa2bcd3f409d2a8298; chain HEAD^ = R1, HEAD^^ = BASE, count 2
(pre-lock and fresh-clone checks); new r1->r2 check = exactly lifecycle.service.ts + lifecycle.service.spec.ts; LAND_REF
refs/remotes/origin/land/s11b-r2 = dda794d7; delta 6 paths (+ test/scout/lifecycle/lifecycle.service.spec.ts); FREEZE-s11b 603ffa02…;
A: EXPECT_LIFECYCLE_BLOB a4a79648b911a6099972f80a13f24837e630cbd7, W fa72-s11b-pg3; B: branch fa72/s11b-r2 (3 refs), EXPECT_LAND_REF dda794d7.

## Verification (read-only, at 17:10–17:14Z)
SRC on refs/heads/fa72/s11b-r2 = dda794d7, clean, no MERGE_HEAD; both authors/committers Bradley Gleave; the 6 delta blobs equal
9149f823's; 9149f823..dda794d7 = D2's 8 pure additions = 7fdcbc04..275e458c. A shell emulation of each runner's changed git checks,
using the pins taken from the built files, passed every check (head, tree, chain, r1r2, base tree, land ref, delta, FREEZE sha/paths/bytes,
lifecycle blob; B: owned, branch, EXPECT_LAND_REF). The unchanged pins were re-verified at the new HEAD/BASE: all blob pins, FREEZE-v3 8/8,
FREEZE-s11c 7/7, FROZEN 28 + premise-P, contract 1a5deca5, migrations 7b6fe0ed/173, schema/package-lock, ancestors, hooks, it() counts
6/8/6/8/24/8. D2 impact: its paths touch no lane input. The S11 guard's slug scan now also sees `s10_unseen`, and no S11 file contains it.
The guard's it.each tables are static, so 94 still holds.

## Expected counts
A: rls 6 / journey 8 / readiness 6 / settle-redrive 8 / guard 94 (122 tests, 5 suites). B: 32 (24 + 8), 2 suites.

## Lane decisions
A: clusters/s11 confirmed ABSENT (v1 leftovers archived in s11-lane-v1/run/post-teardown). run/s11 exists and is empty, which is allowed. Port 55648. W = pg3 (pg1 = v1 clone, retained).
B: clusters/s11b-s10b + run/s11b-s10b ABSENT (never created). Port 55649. W = fa72-s11b-pg2 ABSENT.
Other lanes: clusters/s10d2 and s10d2-v2 are stopped (no postmaster.pid) and fingerprinted. pgrep postgres = 0. Lock inode 686480 (stat only).

## Risks
- **B — shared moving SRC.** fa72-s11b moved twice during this build. At 17:05Z it went from r1@9149f823 to a checkout of r2@275e458c with a staged cherry-pick. It then moved to dda794d7. The parent must freeze it at fa72/s11b-r2 = dda794d7, clean, until both runs end. Otherwise the runner exits rc 70 before the lock, or a consumed run fails.
- **B — outer bounds.** Launch A with 10200 and B with 4500; the launchers already use these.
- C — lifecycle unit specs are frozen, not run, in either lane. v1 bindings are superseded (do not launch s10b-lane-v1). Inherited stale comments. Shared port 55649 with the stopped s10d2 lanes. Run A and B one after the other.

## Commands run (rc)
- cat/sed/grep/ls/stat/wc/pgrep/ps on grants, v1 bindings, reports, runtime, worktree: rc 0. Expected no-match greps returned rc 1, and a probe for the then-absent v2 grant returned rc 1.
- `git rev-parse|log|diff|ls-tree|show|merge-base --is-ancestor|status|symbolic-ref|reflog|branch|worktree list|config` in fa72-s11b with GIT_OPTIONAL_LOCKS=0: rc 0. `git config --get core.hooksPath` returned rc 1 (unset).
- sha256sum on the files and on `git show <rev>:<path>`: rc 0. The v1 `sha256sum -c BINDING.sha256` checks both returned rc 0.
- `python3 .build-s11-lane-v2.py 603ffa02…` rc 0 (16 subs). `python3 .build-s10b-lane-v2.py 603ffa02…` rc 0 (20 subs).
- `bash -n` on 2 runners, 2 fixtures and 2 launchers: rc 0. `cmp` fixtures v1 vs v2: identical, rc 0. `diff -u` ×6 for the DELTA files: rc 1 (expected). `sha256sum -c BINDING.sha256` ×2: rc 0.
- An earlier FROZEN loop parsed the columns wrongly. It was rerun with the right 4-column parse (28 OK + premise-P).
