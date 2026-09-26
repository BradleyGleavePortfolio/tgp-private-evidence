# S11-D binding v2 — independent T3 delta review (EXEC-FA72EFB2)

- **Reviewer:** the independent T3 who accepted s11d binding v1 (`s11d/binding/v1/S11D_BINDING_REVIEW.md`, sha 4d788491…cb64).
- **Scope:** only the v1 → v2 delta: `DELTA-from-v1.diff`, README and launcher, plus the r3 candidate pins.
- **Read-only:** I did not run the runner, fixture, launcher, jest, bootstrap, PostgreSQL or lefthook, and I did not use the lock.
  `bash -n` on the runner is a parse only. Git was run with GIT_OPTIONAL_LOCKS=0 and GIT_NO_LAZY_FETCH=1. I edited nothing except
  this file.

## Verdict: **GO**
- **A findings:** none.
- **B findings:** B1 only, the inherited launch precondition. It needs no byte change.

## Subject (`sha256sum -c BINDING.sha256`: all 7 OK)
- **Template:** v1 is intact. Runner 8dda61d6…6225 and launcher d055014c…dc6dc; `v1/BINDING.sha256` has 0 non-OK entries.
- **v1 sentinel:** `RC=1 STAGE=jest-full END=2026-09-26T19:08:35Z HEAD=38d0d366… LOCK_INODE=686480`. This is the consumed run
  (`PROOF_V1_FINDING.md`), and its bytes are not rerun.
- **Fixture:** `cmp`-identical to v1.
- **Launcher:** the only change is "v1" → "v2" in the header comment.
- **FREEZE-s11d:** now holds one line, `110a02df…9abffe test/scout/s11/journey-full.pg.spec.ts`.
- **DELTA faithful:** its +/- lines equal a fresh `diff -u` for the runner, launcher and FREEZE.
- **Runner:** `bash -n` rc 0.

## Runner delta (complete, read in full)
1. **Header:** a new v2 block of 8 lines, and the Usage path changed to v2.
2. **Paths:**
   - `D` is now v2.
   - SRC is unchanged (fa72-s11d2); only its comment changed.
   - `W` is now `fa72-s11d2-pg2`.
3. **Candidate pins:**
   - `EXPECT_HEAD` is aed23289 and `EXPECT_TREE` is 6787b255.
   - `R1_HEAD` is unchanged (a52d20d6); its comment now says HEAD^^.
   - New `R2_HEAD` 38d0d366 and new `R2R3_DELTA`, which is the spec.
   - `R1R2_DELTA` now means R1..R2.
4. **Spec pins:** `EXPECT_FULL_BLOB` is 9ca2ebb6 and `S11D_FREEZE_SHA` is 60977d8c.
5. **Pins-filled `case`:** now also includes `$R2_HEAD`.
6. **SRC chain check:**
   - HEAD^ = R2, HEAD^^ = R1, HEAD~3 = BASE, and count = 3.
   - R1..R2 and R2..HEAD must each be exactly the spec.
7. **Clone check:** the same three-parent chain is required.

Every other `NAME=` assignment is line-identical to v1 once the changed names are excluded (`diff` rc 0). That covers stages,
`EXPECT_TESTS_*` (full 6, guard 95), bounds, freezes, blob pins, port, donor and lock inode. The `timeout -k 30` census is unchanged:
4200 ×1, 7800 ×1, sum 7230. All new checks come before the lock/STARTED step (L345) and use `fail 70`, so they refuse without
consuming the run. The rg check is L335.

## Pin verification at worktrees/fa72-s11d2 (all PASS)
| check | result |
|---|---|
| HEAD / tree | aed23289024898cceca7385d3778cd7373b7424d / 6787b25531ab7614c9de70e745381a996d66b119 |
| chain | aed23289 → 38d0d366 → a52d20d6 → 54be96f1 (single parents); `rev-list --count BASE..HEAD` = 3; BASE tree 435fec78 |
| deltas | R1..R2 = spec; R2..HEAD = spec (1 file, +17/−5); BASE..HEAD = `A` spec only; src/prisma/package*/test/utils = 0 |
| spec | blob 9ca2ebb6; sha256 110a02df… == FREEZE-s11d; live switch L79; BADPAT 0; `it(` = 6 (L168, 341, 515, 524, 552, 595); `jest.setTimeout(600000)` ×1 |
| land ref | `origin/land/s11d` = aed23289 by fetch fast-forward from GitHub at 19:34:56Z. `repos/backend` shows it as "update by push" at the same second, so it is the real pushed head |
| branch / clean | refs/heads/fa72/s11d-r2; 0 porcelain lines; no MERGE_HEAD; hooksPath unset (rc 1) |
| hooks | pre-commit acfee2ea…d7 and commit-msg 9b4e8c9f…df, unchanged since the v1 review (18:57:20Z); they satisfy the runner's presence and lefthook check |
| r3 commit | Bradley Gleave, author = committer, 19:31:43Z; reflog `commit:` (not a cherry-pick); message clean under the lefthook R3 regex |
| freezes | FREEZE-v3 4 equal (the 4 A2 edits skipped as before); s11c 7/7; s11b 6/6; s11a2 12/12; s11d 1/1 |
| blob pins | all 19 `EXPECT_*_BLOB` equal `HEAD:` |
| J20 range | `3db615c0^..HEAD` = 11 commits (aed23289 added); src-touching commits = dda794d7, 645fb6db, 144269d1, 7fdcbc04, all in SLICE_COMMITS (r3 touches no src) |
| lane | `fa72-s11d2-pg2` absent; `v2/run` absent; `clusters/s11` absent; `run/s11` empty; s10d2, s10d2-v2 and s11b-s10b have no postmaster.pid; `pgrep -cx postgres` = 0; lock inode 686480; `/tmp/s11d-core-diff-gate-*` = 0 |

**r3 content (spot check, not a re-review).** Leg A's `pushes` changes from 1 to 0. This matches the live-passing
`settle-redrive.pg.spec.ts` `expectNoClaimSideEffects` (L232-236, `pushes` 0) that is applied to the replay (L264). Leg B's
`report.coverage` changes to `report.families`. This matches `types.ts` L324
(`readonly families: readonly ReconciliationFamilyV1[]`). The fix aligns the spec with landed behaviour and live-passing precedent;
it does not weaken an assertion to hide a defect. S11-D review Round 3 is GO (`s11d_review.md` L97).

## Findings

### A
None.

### B1 — launch preconditions (inherited; no byte change)
- **CLASS:** launch precondition (owned by the parent).
- **CONCRETE HARM:** the single run is consumed after STARTED if any of these happen:
  - postgres is live at launch (rc 71);
  - `fa72-s11d2`'s HEAD, clean state or hook bytes move, for example through `lefthook install` or npm (rc 70 under the lock via
    HOOKSIG0 or SRCSIG);
  - `origin/land/s11d` moves off aed23289 between the early checks and the clone.
- **EXACT DECISION BLOCKED:** only the moment of launch.
- **MINIMUM CLOSURE:** keep fa72-s11d2 and the land ref frozen until END. Confirm `pgrep -cx postgres` = 0 immediately before
  `bash s11d/binding/v2/launch-when-free.sh` (outer 7800).
- **EXECUTION UNLOCKED:** the single S11-D v2 real-PG run.

### C
- **C1:** I did not observe r3 going through the hooks. The builder report (`s11d_build.md` L575-586) records the gates:
  - Hook attempt 1 failed with RC 1: the hook's own tsc ran out of memory while a sibling worker held a tsc flock. No commit was
    created.
  - Attempt 2 passed all 6 hooks with a larger NODE_OPTIONS heap.
  - The reflog `commit:` entry at 19:31:43Z comes after the hooks were installed, which is consistent. Unlike the r1/r2 closure, there
    is no hookless deviation.
  - The flock in attempt 1 is a tsc/build lock named by the builder. It is not claimed to be `test-validation.lock`, and I did not
    probe it.
- **C2:** The builder's read-only replay of the pre-lock block left `/tmp/s11d-v2-replay` (a.sh, prelock.log, 19:36Z). The runner
  never references it (grep 0). It is harmless and should be left in place as builder evidence.
- **C3:** The J19 fixes are proven only by the live run. v1's full stage took 82 s, well under the 4200 s bound.
- **C4:** The J20 cleanup worked in v1: the pg1 worktree list shows only its main worktree, and there are 0 leftover /tmp dirs. The
  record-only POST line is still present.
- **C5:** The C items from v1 still apply:
  - `node_modules` is hard-linked to the donor; the donor pins are checked before the lock.
  - Kill-grace worst case against the 570 s margin.
  - `sort` locale.
  - `clusters/s11` must be archived and removed after the run.
  - The pg1 clone from v1 is retained as run evidence, and the new W is pg2, so there is no collision.

## Commands run (all read-only; RC)
1. `ls -la s11d/binding/v2`; `head PROOF_V1_FINDING.md`; `cat README.md`; `sha256sum -c` of v2 (7 OK) and v1 (0 non-OK); v1 shas; `cmp` fixture; `diff` of launchers and FREEZE: rc 1 (differences, expected).
2. `diff` of the v1 and v2 runners: rc 1 (expected). DELTA faithfulness check: FAITHFUL. DELTA header grep; `bash -n`: 0.
3. In fa72-s11d2: `rev-parse` (HEAD, tree, ^, ^^, ~3, BASE tree), `symbolic-ref`, `rev-list --count/--parents`, land ref and reflog, repos/backend land ref and reflog, `status --porcelain`, MERGE_HEAD test, `config core.hooksPath` (rc 1 = unset), hook sha256/`ls`, `log -1`, R3 grep, HEAD reflog, the three `diff --name-only`, `diff --stat`, `ls-tree`, `show|sha256sum`, spec it/BADPAT/live/timeout greps, `diff R2 HEAD`: 0.
4. `git show` of settle-redrive L255-270 and `expectNoClaimSideEffects`; `types.ts` L322-326; `rg` Round 3 in `s11d_review.md`: 0.
5. Freeze loops (5 files); blob-pin loop; assignment `diff` against v1 (rc 0); timeout census; line positions; J20 range and src census; lane/clone/run `ls`; postmaster.pid scan; `pgrep`; lock `stat`; /tmp census; v1 sentinel; pg1 `worktree list`; `rg` of `s11d_build.md`: 0, except `ls` of the absent paths.
6. `sed` of `s11d_build.md` L575-590; `ls` of /tmp/s11d-v2-replay; runner grep for it (0 matches): rc 1 (grep no match, expected).
