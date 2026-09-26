# S11-D binding v1 — independent T3 delta review (EXEC-FA72EFB2)

Reviewer: the independent T3 agent that accepted s11a2 binding v1 and v2. The parent asked for this review by mail at 18:58Z.
Scope: only the delta `DELTA-from-s11a2-v2.diff` (runner, launcher, FREEZE), README and launcher against the accepted s11a2 v2,
plus the parent's hook closure (`s11d/PARENT_REBASE_NOTE.md`) and the J20 needs.
Read-only: I did not run the runner, fixture, launcher, jest, bootstrap, PostgreSQL, lefthook or any repo script. I did not take or
probe the lock, and I did not source or evaluate any runner line. The only runner command I used was `bash -n`, which parses and does
not execute. Pins were checked with `git` (GIT_OPTIONAL_LOCKS=0, GIT_NO_LAZY_FETCH=1) / `sha256sum` / `ls` / `stat` / `pgrep` in
`worktrees/fa72-s11d2`. I edited nothing except this file.

## Verdict: **GO** (launchable by the parent under a separate single-run PG grant)
No A findings. The builder's launch-blocking B (source hooks absent) is **closed**. The closure is honest and sufficient for the
runner's hook check (see "Hook closure"). One B remains: the inherited launch precondition, which needs no byte change.

## Subject (sha256; `sha256sum -c BINDING.sha256` all 7 OK)
- `s11-pg-proof.sh` 8dda61d6fb0122dbfde910aea4acd5f6fb0649b3d6747b7b7933a693dbd46225 (468 lines; v2 450; `bash -n` rc 0)
- `launch-when-free.sh` d055014c1866152605b5abeec49f22d1207bce30b417927c3101f81d28bdc6dc
- `FREEZE-s11d.sha256` 6819f7854806e862faa9bb12da5dd4f991a1d1150d517fe7caad8abf05cd1f9f (1 line: 84afc31a…3820 journey-full spec)
- `DELTA-from-s11a2-v2.diff` bec801d2…a05b; `README.md` b5372ed2…87b7; `.build-s11d-v1.py` a27b1f1c…d20e
- `s11-fixture.sh` 777e6ac3… (`cmp`-identical to v2)

The template is intact: v2 runner c785752b… and `v2/BINDING.sha256` all OK. The v2 sentinel reads
`RC=0 STAGE=done END=2026-09-26T18:39:47Z HEAD=54be96f1…`. The DELTA is faithful: its +/- lines equal a fresh `diff -u` for the
runner, launcher and FREEZE.

## Runner delta (complete)
- Header block (+17 lines) and the Usage line (13500 -> 7800, path).
- `D`, `SRC=worktrees/fa72-s11d2`, `W=worktrees/fa72-s11d2-pg1`, and `JLOG7=jest-full.log`.
- `BASE_HEAD=54be96f1`, `BASE_TREE=435fec78`, `EXPECT_HEAD=38d0d366`, `EXPECT_TREE=075c1513`, `R1_HEAD=a52d20d6`,
  `R1R2_DELTA=journey-full spec`, `LAND_REF=origin/land/s11d`.
- New pin `EXPECT_FULL_BLOB=ecfe8cef`. `S11A2_FILES` (12) is now the literal path list for FREEZE-s11a2. New FREEZE-s11d pins with
  paths == `EXPECT_DELTA` (1 path).
- `EXPECT_TESTS_FULL=6`.
- Pins-filled `case` now also includes `$EXPECT_FULL_BLOB$S11D_FREEZE_SHA`.
- FREEZE-s11a2 paths are compared to `S11A2_FILES` and checked 12/12 byte-equal. FREEZE-s11d is added pre-lock and in the under-lock
  sha recheck.
- `BASE..HEAD -- test/utils` must now be empty.
- Full spec: live-switch grep, BADPAT check, `N6` it-count and blob-pin loop entry.
- New pre-lock `rg --version` check (`^ripgrep `).
- RECEIPTS list gains `jest-full.log`.
- Stages: rls/journey/readiness/redrive/induction are replaced by `jest-full` (`timeout -k 30 4200`, `jcheck full … 6`).
- A POST `clone_worktrees=N` log line, record only.

The chain check (HEAD^ = R1, HEAD^^ = BASE, count 2, r1..r2 diff), the fresh-clone parent check, guard 95, teardown and lock/STARTED
handling are v2 verbatim. The launcher changes only its header text and 13500 -> 7800.

## Pin verification at worktrees/fa72-s11d2 (all PASS)
| check | result |
|---|---|
| HEAD / tree | 38d0d366730331e4edf19a14cda8247435b89431 / 075c1513d54367abb796c35faac0bf2872acbace |
| chain | 38d0d366 -> a52d20d6 -> 54be96f1 (single parents); `rev-list --count BASE..HEAD` = 2; BASE tree 435fec78 |
| r1..r2 / BASE..HEAD | both exactly `test/scout/s11/journey-full.pg.spec.ts` (A, 100644); src/prisma/package*/test/utils = 0 |
| full spec | blob ecfe8cef (r1's is 5f54d6ec); sha256 84afc31a… == FREEZE-s11d; live switch L79; BADPAT 0; `^\s*it\(` = 6 (L162, L329, L503, L512, L540, L583); `jest.setTimeout(600000)` |
| branch / land ref | refs/heads/fa72/s11d-r2. `refs/remotes/origin/land/s11d` = 38d0d366, created by `fetch … growth-project-backend.git refs/heads/land/s11d` at 18:46:05Z. `repos/backend` shows the same ref "update by push" at 18:46:03Z, so this is the real pushed head and not a hand-set ref. `origin/integration/importer` = 54be96f1 |
| clean / MERGE_HEAD / hooksPath | 0 porcelain lines (node_modules is gitignored); no MERGE_HEAD; hooksPath unset; `.git` is a real directory; remote url `no_push://disabled-fa72efb2` |
| freezes | FREEZE-v3 4 kept lines equal (the 4 A2 edits skipped as in v2); FREEZE-s11c 7/7; FREEZE-s11b 6/6; FREEZE-s11a2 12/12; FREEZE-s11d 1/1 |
| blob pins | all 18 v2 pins are byte-identical in the runner (`diff` of the pin lines) and equal both `HEAD:` and `54be96f1:`, i.e. unchanged from the bytes v2 ran. EXPECT_FULL_BLOB equals `HEAD:` |
| other pins | `EXPECT_TESTS_*` (rls 6, journey 8, readiness 6, redrive 8, induction 4, guard 95), migrations 7b6fe0ed / 173, schema, package-lock, NM/PG/node/prisma/psql/fixture pins, FREEZE shas, HARNESS_BASE, DONOR, PORT and lock inode are line-identical to v2 (only `EXPECT_TESTS_FULL` added) |
| lane / clone / run | `fa72-s11d2-pg1` absent; `s11d/binding/v1/run` absent; `clusters/s11` absent; `run/s11` empty; s10d2, s10d2-v2, s11b-s10b have no postmaster.pid; `pgrep -cx postgres` = 0; lock inode 686480; no `/tmp/s11d-core-diff-gate-*` present |

**Dropped stages.** BASE..HEAD is the one spec file. Every file the dropped stages read keeps the v2-run blob, still pinned pre-lock:
rls spec, journey-core, readiness, settle-redrive, induction, harness, pg-harness, worker, db.ts, bootstrap, jest configs, and the
S11-B/S11-C src files. Their static it() counts and BADPAT and live-switch checks are also still enforced. Dropping them is sound:
their bytes were proven RC 0 in the s11a2 v2 run at 54be96f1 = this BASE.

## Hook closure (builder's B): honest and sufficient
**What the runner checks.** Pre-lock L240-243: the hooks dir is the plain `$SRC/.git/hooks`, pre-commit and commit-msg are regular
non-symlink files, and both contain `lefthook`. Under the lock, `HOOKSIG0` requires the same two sha256s. It is a presence and
identity proxy; it cannot prove that the commits were produced through the hooks.

**Current state.** Both hooks are regular files (2233 B, 18:57Z, 32 `lefthook` lines each; sha256 acfee2ea… / 9b4e8c9f…). They call
`fa72-s11d2/node_modules/lefthook-linux-x64/bin/lefthook`, which exists. The check will pass.

**Honesty.** The note discloses that the two cherry-picks ran with `core.hooksPath=/dev/null`. This matches the reflog (clone from
fa72-s11d 18:42:58Z, checkout, two cherry-picks 18:43:00Z). The note's "18:5xZ" start time is imprecise; see C2.

**Sufficiency: substantive equivalence, verified read-only.**
- a52d20d6 ≡ fbb97b30 and 38d0d366 ≡ c61b71e9: identical `patch-id --stable`, identical full message, identical author and author
  date. The r2 blob is the same ecfe8cef.
- The originals passed all six lefthook commands in fa72-s11d (`s11d_build.md` L105/L109/L172/L325/L387: prod-readiness-quick,
  banned-cast-tokens, prettier, eslint, tsc, and commit-msg no-ai-tokens).
- The only base change, 03e7a234 -> 54be96f1, is `test/utils/g2-s11-harness.ts`. `scripts`, `lefthook.yml`, eslint, prettier,
  tsconfig and package.json are unchanged (`git diff --quiet` rc 0). So the content-only hooks are deterministic and give the same
  result: prettier, banned-cast staged checker/policy, and prod-readiness-quick.
- The only hooks that can see the harness change are tsc and eslint. The parent re-ran both, with prettier, at HEAD (RC 0 claimed).
- I re-checked commit-msg myself: the R3 regex from `lefthook.yml` against both messages gave clean for each.

Conclusion: the closure satisfies the runner check literally, and the missing hook invocation is covered in substance. It is not a
false pass.

## J20 needs: PASS
- **rg:** new pre-lock check (L324) before the lock, so a missing rg refuses rc 70 without using up the run. `/usr/bin/rg` is
  ripgrep 15.1.0. The runner does not change PATH, so jest children inherit it. The gate script at 275e458c requires only git and rg.
- **History and objects via `--shared`:**
  - SRC has 18 promisor packs and no alternates. The W clone reaches SRC objects through alternates, and the runner exports
    `GIT_NO_LAZY_FETCH=1`, so a missing object is a hard failure, never a fetch.
  - `rev-list 3db615c0^..HEAD` = 10 commits, which include all 7 SLICE_COMMITS; all are ancestors of HEAD.
  - GATE_B 7fdcbc04 is an ancestor of GATE_HEAD 275e458c.
  - Every tree and blob of those 10 commits plus 3db615c0^ is present: 2882 objects, `cat-file --batch-check` missing = 0.
  - The src-touching commits in range are 7fdcbc04, 144269d1, 645fb6db and dda794d7, all in SLICE_COMMITS, so J20 test 2 will not trip.
- **Scratch worktree:**
  - It is created at `os.tmpdir()/s11d-core-diff-gate-<pid>-<ts>-<rand>`. TMPDIR is unset, so this is /tmp, outside W, on the same
    filesystem as W (5.8 GB free; the 275e458c tree is about 21 MB), and inside the runner's `MIN_FREE_KB` margin.
  - `git worktree remove --force` runs in `finally`, with failures swallowed. The assertions come after cleanup.
  - The gate's clean-tree check 2 applies to the fresh scratch checkout.
  - W's `.git/worktrees/<n>` is not in `git status`, so PORC0 and POST are unaffected, and SRCSIG covers SRC only.
  - The W clone's hooks are template samples only, so no post-checkout hook fires.
  - The `POST clone_worktrees` line is logging only (under `pipefail` with no errexit it cannot fail the run).
- **Timeouts:**
  - Full stage 4200 = 6 × 600 s jest ceiling + 600 s.
  - Inner sum recomputed: 120+120+600+600+60+60+900+8×15+4200+300+75+75 = 7230.
  - Outer 7800 appears in both the launcher and the Usage line (570 s margin, as in v2). The `timeout -k` census matches (4200 ×1,
    7800 ×1 in Usage; no 1500/3000 left).

## Findings (Safety ROI)

### A
None.

### B1 — launch preconditions (inherited; no byte change)
- CLASS: launch precondition (parent-owned).
- CONCRETE HARM: any of these uses up the single-run grant:
  - a live `postgres` at launch (preflight rc 71, after STARTED);
  - `fa72-s11d2` (HEAD, branch, clean, **hook bytes**) or `origin/land/s11d` moving between the pre-lock and under-lock checks
    (rc 70 after STARTED), or after the clone (POST rc 74).
  Re-running `lefthook install` would also change the hook sha and trip `HOOKSIG0` under the lock.
- EXACT DECISION BLOCKED: the launch moment only.
- MINIMUM CLOSURE: freeze `fa72-s11d2` (38d0d366, clean, current hooks) and `origin/land/s11d` until the run ends. Do not run
  npm or lefthook in fa72-s11d2. Confirm `pgrep -cx postgres` = 0 immediately before `bash launch-when-free.sh`, which carries the
  7800 outer bound.
- EXECUTION UNLOCKED: the single S11-D real-PG run.

### C
- C1: Hookless cherry-picks with `core.hooksPath=/dev/null` are a parent-owned deviation from the "commits through hooks" doctrine.
  They are disclosed and covered by the equivalence above. Record them in the S11-D acceptance so the runner comment "produced
  through the tracked lefthook hooks" is read with that qualifier. The runner banner is not wrong about what it checks.
- C2: The parent note says "18:5xZ" for the clone and cherry-picks; the reflog says 18:42:58-18:43:00Z. The hook install is at
  18:57Z, which matches the note's 19:1xZ closure only loosely. Cosmetic.
- C3: The parent's prettier/eslint/tsc RC 0 at HEAD is stated in the note without a log file in the evidence tree. I did not re-run
  them, and I could not verify them beyond the note. The run's bootstrap still compiles the harness through ts-node/jest, so a type
  failure would show loudly.
- C4: `fa72-s11d2/node_modules` is a `cp -al` hard-link copy of the donor `fa72-s11a1/node_modules`. Any in-place write there would
  also change the donor. The runner pins the donor pre-lock (hidden lock, client, schema, prisma CLI), so this would refuse rc 70
  without using up the run, and the in-run `csig` catches it later.
- C5: If J20's cleanup fails, a /tmp scratch worktree and a W `.git/worktrees` entry are left behind. They are recorded only, as the
  builder noted.
- C6: J19's run time has not been observed. The 4200 bound rests on the jest ceiling (v2 comparables: 84-233 s).
- C7: Carried from v1/v2: `sort` locale (only C locales installed); kill-grace worst case versus the 570 s margin; the launcher
  falls through after about 1 h, but the runner then refuses rc 75 before STARTED; `clusters/s11` needs archive-and-remove after
  the run.

## Commands run (all read-only; RC)
1. `ls -la s11d s11d/binding/v1`; `cat PARENT_REBASE_NOTE.md README.md` — 0
2. `cat`/`sha256sum -c` of the s11d `BINDING.sha256` (7 OK); v2 runner/launcher sha and `sha256sum -c` (0 non-OK); `cmp` fixture; `cat FREEZE-s11d`; `diff` launchers; `ls`/`cat` of the v2 run sentinel; `wc -l`; `cat` of the build grant — 0 (diff rc 1 expected)
3. `diff` of the v2 and s11d runners — 1 (differences, expected)
4. In fa72-s11d2: `rev-parse`, `symbolic-ref`, `rev-list --count/--parents`, land-ref and integration-ref `rev-parse`, `status --porcelain --untracked-files=all`, MERGE_HEAD test, `config --get core.hooksPath` (rc 1 = unset), `log -3`, trailer grep, `diff --name-status/--name-only/--stat`, `ls-tree`, `show | sha256sum`, remote config — the final `config --get remote.origin.pushurl` returned 1 (unset); otherwise 0
5. `remote -v`, `for-each-ref refs/remotes`, reflog of the land ref and HEAD, `.git/logs` read; `repos/backend` land/integration refs and reflog — 0
6. Blob comparison of c61b71e9/fbb97b30; `log`/`diff` of the originals; `ls` and `head` of the hooks; `file`; hook sha256; `git show HEAD:lefthook.yml` — 0
7. R3 regex on both messages; message, author and patch-id equality; base diff; hook-input `diff --quiet`; fa72-s11d hooks listing; `rg` of `s11d_build.md` — 0
8. `ls` of execution/fa72efb2; `rg -l 38d0d366`; `check-ignore node_modules`; `git show` of the prod-readiness script head — 0
9. `grep`/`sed` of the full spec (J20 section L466-500, L540-621) and the runner env line — 0
10. `git show 275e458c:scripts/s10-core-diff-gate.sh | head -80` — 0
11. Promisor/alternates config; `rev-list 3db615c0^..HEAD`; object presence via `ls-tree -r -t` + `cat-file --batch-check` (missing 0 of 2882); ancestry of the 7 pins and GATE_B; src-touch census; `rg --version`; `df`; tree size — 0
12. Runner grep for PATH/TMPDIR/export and MIN_FREE_KB — 0
13. The 5 FREEZE files line-checked at HEAD; blob-pin loop at HEAD and 54be96f1; pin-line `diff` against v2 (only `EXPECT_TESTS_FULL` added); migrations; spec it/BADPAT/live counts — 0
14. Grep for spec hooks/`test(`; `timeout -k` census; pre-lock line positions; `ls` of lane/clone/run paths; postmaster.pid scan; `pgrep -cx postgres`; `stat` lock inode; `/tmp` scratch count — 1 (only because `ls` of the absent paths failed, as expected)
15. Runner `set`/worktree/POST grep; `sed` of POST; `git show HEAD:jest.config.js | head` — 0
16. DELTA header grep; faithfulness compare (first attempt used the wrong FREEZE pair and gave CHECK; the correct pair gave FAITHFUL); `bash -n` of the runner (parse only) — 0; `rg` of the s11d_review Round 2 — 0
17. Runner `H=` grep; `ls -la`/`test -L` of the SRC hooks and `.git`; `grep -c lefthook`; `ls` of the lefthook binary — 0
