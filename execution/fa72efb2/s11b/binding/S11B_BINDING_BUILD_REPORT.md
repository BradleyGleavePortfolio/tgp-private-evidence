# S11-B binding build report (T3 builder, parent fa72efb2) — SOURCE ONLY

Nothing was executed: no runner, fixture, jest, bootstrap, PostgreSQL, npm or lock. `execution/test-validation.lock` was only
`stat`-ed. worktrees/fa72-s11a1, runtime/** and the clusters were not modified. The evidence repo is not committed
(`git status` shows `?? execution/fa72efb2/s11b/binding/`).

## Binding A — `s11b/binding/s11-lane-v1/` (settle re-drive J12–J16 + regressions)
| file | sha256 | lines |
|---|---|---|
| s11-pg-proof.sh (755) | ef0024b2036e5a2ba9dca1fb487f3bd5c4f3ac601454f1aac2916e6d370ef36a | 399 |
| s11-fixture.sh (byte copy of s11c v1) | 777e6ac3db359bc6ecb891c19da37943b8296ac9574ba48220ea9a94cfc31636 | — |
| FREEZE-s11b.sha256 | ca321526e5363ba553dce66f70f3674b18579962cbe926428916cc03ce6424f4 | 5 |
| DELTA-from-s11c-v1.diff | 4a9fb798e84888578b602d25ed64ce5f758a462c1c37e81e63d4073e3eefa978 | 11 hunks +54/-24 |
| README.md | a539c05978ea22e75d7c997f82427b64a87ad1e140d116ecf4d530662d306625 | 67 |
| .build-s11-lane-runner.py | d35ce45cd41ad37f5d3c4f269001198b5bba49de21fb1949f9292fb5b20b1c2f | 25 count-asserted subs |
| BINDING.sha256 | 4a52c5419bede3c9e48d1f8b8b0bdd92cd135694e85f4ff3f5bd7cea6ad53fbb | `sha256sum -c` rc 0 |

Expected: bootstrap once; rls 6, journey 8, readiness 6, **settle-redrive 8 (new stage)**, guard 94. That is 122 tests in 5 suites.
Outer bound: `timeout -k 30 10200` (raised from 7200 because the redrive stage bound is 3000 s).

## Binding B — `s11b/binding/s10b-lane-v1/` (R36 flip in test/rls-g2-s10c.spec.ts)
| file | sha256 | lines |
|---|---|---|
| s10b-lane-pg-proof.sh (755) | 2a5c5d195b91e39548dee4b06acbb09ee49dada0f3856e73793c3424d4f32a3b | 421 |
| s10b-lane-fixture.sh | 2fc8012dea542751228a9b1b98e6367fa40cd3d5849e73bcd6f2019147a5db2a | 111 |
| FREEZE-s11b.sha256 (cp -p of A's) | ca321526e5363ba553dce66f70f3674b18579962cbe926428916cc03ce6424f4 | 5 |
| DELTA-from-d2-v1.diff | 5de16b47d8e289f1d4145de8020e0ee4edf71b2858214e54fe1b5b101a7cf318 | 14 hunks +72/-87 |
| DELTA-fixture-from-d2.diff | fbc4592963ae0f417b707725d493eeaa395a3a21c80ea3f32fd976e0f2e4b6f6 | 4 hunks +12/-7 |
| README.md | 5cb3f4ea6b0bde31fd7bf28dae6427c5f795eaffe9e48fb97971caa9ab17e447 | 55 |
| .build-s10b-lane.py | f9ff9a9a7c5cfcb4695f72b8fef657a1b169eca53cb2ee9b0baf16eb0957bf8c | — |
| BINDING.sha256 | 31f9a7e5f68cba8c4c5994b20cc2a8096d6fa66534d1242149eaa3fcca3b17d0 | `sha256sum -c` rc 0 |

Expected: bootstrap once, then ONE jest run `-c jest.rls.config.js` over rls-g2-s10b (24) + rls-g2-s10c (8) = **32 passed, 2 suites**.
Lane clusters/s11b-s10b, port 55649, W=worktrees/fa72-s11b-pg2. Outer bound `timeout -k 30 4500`.

The changed pins are listed in each README table. The candidate for both is 4d31616f9288402c0cdd6a74fb30b4b15d0658d3
(tree 366efa9f…, parent = BASE 7fdcbc04, land/s11b = HEAD). The delta is exactly the 5 S11-B paths, all mode 100644.

## Template pins confirmed
s11c v1 runner 5e4b29ec…1c1d (sentinel RC=0 15:49:19Z); d2 v1 runner 9a2f8b36…67e8 and fixture 0fadafa3…c24b.
Both match their BINDING.sha256.

## Commands run (all read-only or builder-local)
- `cat`/`sed`/`grep`/`ls`/`stat`/`wc`/`df`, `pgrep`, `ss` on the templates, the runtime and the worktree: rc 0 (grep with no match rc 1)
- `git rev-parse|show|diff --name-only|ls-tree|merge-base --is-ancestor|status|log|symbolic-ref|cat-file` in fa72-s11b with GIT_OPTIONAL_LOCKS=0: rc 0
- `sha256sum` on the files and on `git show HEAD:<path>`: rc 0
- `python3 .build-s11-lane-runner.py <freeze sha>`: rc 0. `python3 .build-s10b-lane.py <freeze sha>`: rc 0
- `bash -n` on all 3 built shell files: rc 0. `cmp` fixture A vs s11c: identical, rc 0
- `diff -u` for the 3 DELTA files: rc 1 (differences, as expected). `cp -p` FREEZE: rc 0. `sha256sum -c BINDING.sha256` ×2: rc 0

## Open risks
- **A (blocks Binding A launch):** `runtime/clusters/s11` still exists and contains the S11-C leftovers pg.log, pg.log.pg_ctl and
  pg-data.initdb.log (confirmed by ls). The runner's "lane exists" check will make it exit PRELOCK_REFUSED rc 70 before the lock,
  and the run is not consumed. Minimum closure (parent): archive the 3 files into the S11-C evidence and remove the empty dir. This
  unlocks the S11-lane run.
- **B:** Binding A must be launched with `timeout -k 30 10200`. Reusing a 7200 launcher could kill the run mid-stage before teardown.
- C: the 3000 s redrive bound is a practical bound, not the theoretical ceiling (8×600 s). A timeout counts as a failure.
- C: Binding B keeps its pg-data after stop (template behaviour). `clusters/s10d2/pg-data` (stopped) is fingerprinted by both runners.
  The two runners cannot run concurrently; either order works.
- C: B's fixture keeps the D2_* protocol token names by design. B does not blob-pin jest.rls.config.js (template), but it was verified unchanged.
- C: the unit spec s11b-settle-redrive.spec.ts is frozen but is run by neither lane.
