# S11-D binding v1 (source only; not run)

Built by minimum substitution from `s11a2/binding/v2/s11-pg-proof.sh` (sha256 `c785752b88e287238c676e27a83e772addb39da2fdb42e93147e574009d0c708`, ran END rc=0 127/127). Build script `.build-s11d-v1.py`: 33 count-asserted substitutions. Full diff: `DELTA-from-s11a2-v2.diff`. Grant: `s11d/S11D_BINDING_BUILD_GRANT.md`.

## Pins (verified read-only, GIT_OPTIONAL_LOCKS=0, in worktrees/fa72-s11d2)

| Pin | v2 | S11-D v1 |
|---|---|---|
| SRC | worktrees/fa72-s11a2 | worktrees/fa72-s11d2 (branch fa72/s11d-r2, clean, no MERGE_HEAD, hooksPath unset) |
| W | worktrees/fa72-s11a2-pg2 | worktrees/fa72-s11d2-pg1 (absent) |
| BASE_HEAD / tree | dda794d7 / 802e1c19 | 54be96f18c314cae35d1e5d3000af9f06d693d81 / 435fec782672214c7e8e81b2eb91f8f9266331b4 (= HEAD^^) |
| R1_HEAD | 03e7a234 | a52d20d6827ae51da58505050ab0d29327659796 (= HEAD^) |
| EXPECT_HEAD / tree | 54be96f1 / 435fec78 | 38d0d366730331e4edf19a14cda8247435b89431 / 075c1513d54367abb796c35faac0bf2872acbace |
| chain count | 2 | 2 (BASE..HEAD) |
| R1R2_DELTA | test/utils/g2-s11-harness.ts | test/scout/s11/journey-full.pg.spec.ts |
| LAND_REF | origin/land/s11a2 | origin/land/s11d = 38d0d366 |
| EXPECT_DELTA | 12 S11-A2 paths | test/scout/s11/journey-full.pg.spec.ts (1 path) |
| new EXPECT_FULL_BLOB | — | ecfe8cef35eb99f955d7b0acdaddeb84d3cef8e2 (= c61b71e9's reviewed blob; a52d20d6's = 5f54d6ec = fbb97b30's) |
| FREEZE-s11a2 | own, paths == delta | s11a2/binding/v2/FREEZE-s11a2.sha256 (51d901ef…7290), paths == literal S11A2_FILES (12), 12/12 byte-identical at HEAD |
| new FREEZE-s11d | — | FREEZE-s11d.sha256 (6819f785…1f9f): `84afc31a…3820  test/scout/s11/journey-full.pg.spec.ts`, paths == delta |
| test/utils BASE..HEAD | == the 4 A2 edits | empty |

Unchanged and re-verified at HEAD: FREEZE-v3 (4 kept lines ok; the 4 A2_A1_EDITS lines skipped as in v2), FREEZE-s11c 7/7, FREEZE-s11b 6/6, all 18 v2 blob pins, migrations tree 7b6fe0ed / 173 / 20270124000000_scout_run_observation_expand, BASE..HEAD touches nothing in src/prisma/package.json/package-lock.json/test/utils, fixture 777e6ac3…1636 (copied byte-identical), lane clusters/s11 (absent), run/s11 (empty), port 55648, donor fa72-s11a1/node_modules.

## Stages and counts

bootstrap (`test/utils/g2-s11-bootstrap.sh bootstrap`) → identity → **full** `jest --runInBand --ci test/scout/s11/journey-full.pg.spec.ts` (default config, `run/jest-full.log`, jcheck: `Test Suites: 1 passed, 1 total`, `Tests: 6 passed, 6 total`, stop on first failure) → **guard** 95 (G2_S11_* unset) → teardown → post. Total 101 tests / 2 suites.
Dropped (accepted at BASE in s11a2 v2 on unchanged bytes; must not be rerun): rls, journey-core, readiness, settle-redrive, induction. Their byte pins and static it() counts are still checked.
Static full-spec checks: pinned live switch at L79, BADPAT none, `^\s*it\(` = 6 (L162 J19 A, L329 J19 B, L503/512/540/583 J20).

## Timeouts

full 4200 s (6 × jest.setTimeout 600 s = 3600 s hard ceiling + 600 s boot/hooks; v2 comparables: journey-core 188 s, redrive 233 s, induction 84 s). Inner sum 120+120+600+600+60+60+900+120+4200+300+75+75 = 7230 s; outer `timeout -k 30 7800` (570 s margin, same as v2) in Usage and `launch-when-free.sh`.

## J20 history / scratch worktree

- Clone is `git clone --shared --no-checkout` (alternates to SRC objects). SRC is a partial clone (promisor packs; 20336 old-history objects absent), but read-only checks found all 10 commits of `3db615c0^..HEAD` (3db615c0^ = 6a33df9b) plus every object of their full trees present (0 missing), all 7 SLICE_COMMITS are ancestors of HEAD, and every src blob J20's slug scan reads exists. Prior S11 sources were partial as well, and their shared clones ran cleanly.
- The scratch `git worktree add --detach` goes to `os.tmpdir()` (`/tmp/s11d-core-diff-gate-*`), outside W, and `git worktree remove --force` runs in its finally. It writes W/.git/worktrees/<name>, which the post-run checks never read: the PORC0 check is `git status --porcelain --untracked-files=all` of W's own tree, and SRCSIG covers SRC only. The W clone holds only template sample hooks, so no post-checkout hook fires. New: `POST clone_worktrees=N` is logged as a record and cannot fail the run.
- The gate script at 275e458c needs `rg`. A new pre-lock check requires it (found /usr/bin/rg, ripgrep 15.1.0).

## Risks

- **B — source hooks absent (blocks launch; the run is not consumed).** fa72-s11d2/.git/hooks holds only `*.sample` files, with no lefthook pre-commit or commit-msg. Its reflog shows it was cloned from fa72-s11d, and a52d20d6 and 38d0d366 were cherry-picked onto 54be96f1, so no hooks ran. The inherited pre-lock check refuses with rc 70 PRELOCK_REFUSED before the lock is taken or STARTED is written. The read-only replay showed exactly this. CLASS: provenance precondition. CONCRETE HARM: the launch refuses and time is lost; nothing is consumed. EXACT DECISION BLOCKED: launching the S11-D proof. MINIMUM CLOSURE: the parent installs the tracked lefthook hooks in fa72-s11d2 (regular files, no symlinks, hooksPath unset), or decides that cherry-picked hook-produced blobs are acceptable and has the hook checks re-bound (v2 fa72-s11a2 hooks point at that clone's node_modules, so copying them over is not neutral). EXECUTION UNLOCKED: the single S11-D PG run.
- C — J19 run time is not yet observed. The bound rests on the jest ceiling, not on a measurement.
- C — if J20's cleanup fails, a /tmp scratch worktree and a W/.git/worktrees entry are left behind. They are recorded only and do not change the proof.
- C — the spec shells out to `git`/`rg` under the runner env (GIT_NO_LAZY_FETCH=1). Any missing object is a hard failure, never a fetch.
