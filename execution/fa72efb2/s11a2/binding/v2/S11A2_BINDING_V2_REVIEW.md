# S11-A2 binding v2 — independent T3 delta review (EXEC-FA72EFB2)

Reviewer: the same independent T3 agent that accepted binding v1 (`v1/S11A2_BINDING_REVIEW.md`, GO). Scope, per the parent mail
(18:25Z): only the delta `s11a2/binding/v2/DELTA-from-v1.diff`, plus the README and launcher, against the accepted v1.
Read-only: I did not run the runner, fixture, launcher, jest, bootstrap or PostgreSQL. I did not take or probe the lock, and I did
not source or evaluate any runner line. Pins were re-derived with `git` (GIT_OPTIONAL_LOCKS=0) / `sha256sum` / `ls` / `stat` /
`pgrep` in `worktrees/fa72-s11a2`. I edited nothing except this file.

## Verdict: **GO** (launchable by the parent under a separate single-run PG grant)
No A findings. The one B finding is an inherited parent launch precondition and needs no byte change.

## Subject (sha256 recomputed, all equal to v2 `BINDING.sha256`)
- `s11-pg-proof.sh` c785752b88e287238c676e27a83e772addb39da2fdb42e93147e574009d0c708 (450 lines; v1 440)
- `launch-when-free.sh` 9bd00b1daa0a1aff9ec00c5c57a77b69bf5461ee3208228d38797044c5335c79
- `FREEZE-s11a2.sha256` 51d901ef8689b396ed23074911dbea1daaf5058ebc54864135484b3d80047290
- `DELTA-from-v1.diff` d04027e4012fda54222e06d77f3b23f22b3e240accff439f7ee8aa8d8ab0c72c
- `README.md` d775a3c6aa2029ff3a647305ff8575bb024d5ed49cc8b89111d2ff3936cf7305
- `s11-fixture.sh` 777e6ac3… (`cmp`-identical to v1); `.build-s11a2-v2.py` 8ca47930…

The template is still intact: v1 runner 7da3029f… and launcher fc3cb724…, and `sha256sum -c v1/BINDING.sha256` gave 0 non-OK lines.
`DELTA-from-v1.diff` is faithful: its +/- lines equal a fresh `diff -u` of v1 against v2 for the runner, launcher and FREEZE.

## Delta content (runner, complete)
1. Header comment block (+7 lines) and the Usage path v1 -> v2.
2. `D` -> `s11a2/binding/v2`, so the run dir `v2/run` is separate from the consumed `v1/run`. `W` -> `worktrees/fa72-s11a2-pg2`.
   The SRC comment now says 54be96f1.
3. `EXPECT_HEAD` 54be96f1…3d81, `EXPECT_TREE` 435fec78…31b4. New `R1_HEAD=03e7a234…0921` and new `R1R2_DELTA="test/utils/g2-s11-harness.ts"`.
   The `BASE_HEAD` comment now reads (= HEAD^^).
4. `EXPECT_HARNESS_BLOB` -> 927d73655c586a188556353a59fa1c5939cae09a.
5. `S11A2_FREEZE` -> v2 own dir, sha 51d901ef….
6. The pins-filled `case` now includes `$R1_HEAD`.
7. Pre-lock chain check: HEAD^ = R1_HEAD, HEAD^^ = BASE and `rev-list --count` = 2. A new pre-lock check requires
   `diff --name-only R1_HEAD HEAD` to equal `R1R2_DELTA`.
8. Fresh-clone check now adds HEAD^ = R1_HEAD and HEAD^^ = BASE.

These restore exactly the S11-B v2 two-commit pattern that v1 removed, and the lines are byte-shaped like the accepted s11-lane-v2.
The launcher changes only the header text. Stages, counts (6/8/6/8/4/95), timeouts (sum 12930, outer 13500), lock handling,
STARTED placement, teardown and post are unchanged.

## Pin verification at worktrees/fa72-s11a2 (all PASS)
| check | result |
|---|---|
| HEAD / tree | 54be96f18c314cae35d1e5d3000af9f06d693d81 / 435fec782672214c7e8e81b2eb91f8f9266331b4 |
| chain | parents: 54be96f1 -> 03e7a234 -> dda794d7 (single-parent each); `rev-list --count BASE..HEAD` = 2; BASE tree 802e1c19 |
| branch / land ref | refs/heads/fa72/s11a2; refs/remotes/origin/land/s11a2 = 54be96f1 |
| clean / MERGE_HEAD / hooksPath | 0 porcelain lines (incl. untracked); no MERGE_HEAD; hooksPath unset |
| r2 commit | author and committer Bradley Gleave; no co-author trailer; subject "test(scout): S11-A2 r2 reset the S10-B tables only by cascade" |
| r1 -> r2 | exactly `test/utils/g2-s11-harness.ts`, +5/-3. The one executable change removes the direct `DELETE FROM` of OBSERVATION/DECLARATION/SETTLED_BASIS in `resetData`; the rest is comments |
| harness blob / file sha | 927d7365… / 502c97c9…, equal to the pin and to the FREEZE-s11a2 v2 line |
| FREEZE-s11a2 v2 | 12 lines; paths == `EXPECT_DELTA`; 12/12 byte-equal at HEAD; differs from v1 only in the harness line (494a683a -> 502c97c9) |
| delta / scope | BASE..HEAD = the same 12 paths; src/prisma/package.json/package-lock.json = 0; test/utils = the 4 A2 utils |
| FREEZE-v3 split | 4 untouched A1 files byte-equal; exactly the 4 `A2_A1_EDITS` differ (skipped) |
| FREEZE-s11c / s11b | 7/7, 6/6 byte-equal (file shas 2d58f9d1…, 603ffa02… unchanged) |
| all 18 blob pins | each `EXPECT_*_BLOB` equals `git rev-parse HEAD:<path>` (scripted over the runner's pin lines) |
| migrations | tree 7b6fe0ed, 173 dirs |
| counts | guard spec and induction spec unchanged r1 -> r2 (`git diff --quiet` rc 0): guard 11 `it` (-> 95), induction 4 |
| G2_S11_CANDIDATE_HEAD | runner L179 `=$EXPECT_HEAD`, so it resolves to 54be96f1 |
| lane / clone / run | `fa72-s11a2-pg2` absent; `v2/run` absent; `clusters/s11` absent; `run/s11` empty; s10d2, s10d2-v2, s11b-s10b have no postmaster.pid; `pgrep -cx postgres` = 0; lock inode 686480 |
| pre-STARTED refusals | the new chain and r1..r2 checks are in the pre-lock block (`PRELOCK_REFUSED`, exit 70, no lock, no STARTED), so a failure there does not consume the run. Everything else is v1 verbatim |

Guard-spec compatibility with the r2 text (a guard failure would come late and consume the run). The guard's static checks on
`g2-s11-harness.ts` are the forbidden-name regexes (L371, L377), the real-platform slug check (L370, L427) and the fixture import and
`INDUCTION` export (L424-425). The r2 added lines match none of the forbidden regexes and none of the 11 non-conformance source slugs.
The guard text does not reference `resetData` or the removed DELETE lines. I found no reason the guard would change from 95.

## Findings (Safety ROI)

### A
None.

### B1 — launch preconditions (inherited from v1 / s11-lane-v2; no byte change)
- CLASS: launch precondition (parent-owned).
- CONCRETE HARM: any of these consumes the single-run grant with no proof:
  - a live `postgres` process at launch (preflight rc 71, after STARTED);
  - `fa72-s11a2` or `origin/land/s11a2` moving between the pre-lock checks and the under-lock recheck (rc 70 after STARTED);
  - either moving after the clone (POST rc 74).
  The builder notes that the land ref read 03e7a234 at build start and 54be96f1 at build end. It is 54be96f1 now.
- EXACT DECISION BLOCKED: the launch moment only, not the binding GO.
- MINIMUM CLOSURE: keep `fa72-s11a2` (fa72/s11a2 = 54be96f1, clean) and `origin/land/s11a2` = 54be96f1 frozen until the run ends.
  Confirm `pgrep -cx postgres` = 0 immediately before `bash launch-when-free.sh`, which carries the 13500 outer bound.
- EXECUTION UNLOCKED: the single S11-A2 v2 real-PG run.

### C
- C1: The r2 fix is proven only by the live run. The cascade-past-trigger argument (FK ON DELETE CASCADE permitted by the insert-only
  trigger) is static, from the T4 Round 2 review. The no-DB gates cannot see the trigger (PROOF_V1_FINDING).
- C2: The old v1 clone `worktrees/fa72-s11a2-pg1` still exists. v2 uses `-pg2`, so this is harmless. It is kept as v1 evidence;
  cleanup is the parent's call.
- C3: The r2 harness header now says "`resetData` is UNCHANGED", meaning byte-equal to the A1 base function (T4 R2-4 `cmp` rc 0).
  The wording is accurate but terse. Not a binding matter.
- C4: Carried from v1: the J11 10 s lock-wait window under load; `sort` is locale-dependent (only C locales are installed); the
  kill-grace worst case exceeds the 570 s margin; the launcher falls through after about 1 h, but the runner then refuses rc 75 before
  STARTED; `clusters/s11` needs archive-and-remove after the run.

## Commands run (all read-only; RC)
1. `ls -la binding/v2`; `head PROOF_V1_FINDING.md`; `cat v2/README.md`; `sha256sum v2/*`; `cat v2/BINDING.sha256` — 0
2. `sha256sum` v1 runner/launcher; `cmp` fixtures; `diff` v1 v2 for runner, launcher and FREEZE; `wc -l` — 0 (the diff rc 1 is expected)
3. In fa72-s11a2:
   - `git rev-parse HEAD HEAD^{tree} HEAD^ HEAD^^ BASE^{tree}`, `symbolic-ref`, `rev-list --count`, `rev-list --parents -n 2`
   - land-ref `rev-parse --verify`, `status --porcelain --untracked-files=all`, MERGE_HEAD test, `config --get core.hooksPath` (rc 1 = unset)
   - `log -2`, trailer grep (count 0), `diff --name-only/--stat/diff R1 HEAD`, BASE..HEAD delta and scope, harness `ls-tree`, `show | sha256sum`
   - All 0.
4. The 4 FREEZE files checked line by line with `git show HEAD:p | sha256sum`; the blob-pin loop over the runner's `EXPECT_*_BLOB` lines; migrations tree and count; it-counts; `diff --quiet R1 HEAD` on the guard and induction specs — 0
5. Guard grep for S10B/resetData; `sed` of guard L190-215; `grep` of the T4 Round 2 section; DELTA faithfulness diff; grep of CANDIDATE_HEAD, 13500, counts and LAND_REF; `sha256sum -c v1/BINDING.sha256` — 0. My first `-c` ran from the wrong cwd and gave spurious non-OK lines; rerun inside v1 it gave 0 non-OK.
6. Guard grep for harness reads and negative assertions; `ls` of the pg2/v2 run/clusters/s11/run/s11 paths; postmaster.pid scan; `pgrep -cx postgres`; `stat` of the lock inode — 0 (the ls "No such file" results are the expected absence)
7. `sed` of guard L285-300 and L420-440; grep of negative assertions; `sed` of L360-370 — 0
8. r2 added lines checked against the guard's forbidden regexes (0 hits) and against every non-conformance source slug (0 hits) — 0
