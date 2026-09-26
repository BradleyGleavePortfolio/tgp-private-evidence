# S11-A2 binding v1 — independent T3 delta review (EXEC-FA72EFB2)

Reviewer: fresh T3 agent (not the builder), under `s11a2/S11A2_BINDING_REVIEW_GRANT.md` and `WORKER_RULES.md`.
Mode: read-only. I did not run the runner, fixture, launcher, jest, bootstrap or PostgreSQL. I did not take or probe
`/home/user/workspace/execution/test-validation.lock`, and I did not source or evaluate any runner line. Every pin was
re-derived with read-only `git` (GIT_OPTIONAL_LOCKS=0) / `sha256sum` / `ls` / `stat` / `pgrep` in `worktrees/fa72-s11a2`
and the fa72efb2 runtime at about 18:0xZ. I edited nothing except this file. The one scratch file outside the workspace is
`/tmp/s11a2_rev_runner.diff` (plain `diff` output of v2 against v1).

## Verdict: **GO** (binding bytes may be launched by the parent under a separate single-run PG grant)

No A findings. One B finding, a launch precondition the parent owns. It is inherited template behaviour and needs no binding
change. The remaining items are C.

## Subject and scope
Subject files (sha256 recomputed, all equal to `BINDING.sha256`):
- `s11-pg-proof.sh` 7da3029f67b9a47e4215825f157ba108691f941954e73608827fd07b082d3af6 (440 lines; template 410 lines. Note: README says 411 -> 440)
- `s11-fixture.sh` 777e6ac3db359bc6ecb891c19da37943b8296ac9574ba48220ea9a94cfc31636 (`cmp`-identical to v2)
- `launch-when-free.sh` fc3cb724f943e27cdb7a5e3555b080e560535726e5bd86c99d797ab6b3932be2
- `FREEZE-s11a2.sha256` a73f921125e64a0a21df765c0f9c439f19066ef74bc78b471af3b55552481b59
- `DELTA-from-s11b-v2.diff` b673ff6d79c60754a92e2cac3e93245e5b0011e6f2fbe5fc6996633246908806
- `README.md` 56a1681e41c5eeeebdbf23896a439100c6cc07555dc977ff1e111884b9818cd2
- `.build-s11a2-v1.py` a13a6509f4d890efc0fc6a4e776cf8389396f4a1df2c76226886ad49ff85ef41

Template: `s11b/binding/s11-lane-v2/s11-pg-proof.sh` sha256 2e683690880f0e1c25dfd21b390ef3fa8b76bd8fadc06695f044e569c0ee1327. This
matches the accepted pin, and the v2 sentinel reads `RC=0 STAGE=done END=2026-09-26T17:32:47Z HEAD=dda794d7…`. I reviewed only the
delta. `DELTA-from-s11b-v2.diff` is faithful: its runner hunks and launcher hunks are byte-equal to a fresh `diff -u` of v2 against v1.
Outside the header comments, the runner delta is only the substitutions listed in the README table.

## Pin verification at worktrees/fa72-s11a2 (all PASS)
| check | result |
|---|---|
| HEAD / tree | 03e7a2344ef95b019c751983527bbc9f78200921 / 738b711610a570357136ad8e8eb1be176d406c51 |
| branch / land ref | refs/heads/fa72/s11a2; refs/remotes/origin/land/s11a2 = 03e7a234 |
| one-commit chain | HEAD^ = dda794d7e8bee0482a7ad373795fcc51dcf54bb5; `rev-list --count BASE..HEAD` = 1; BASE^{tree} = 802e1c19…d760 |
| author/committer | both `Bradley Gleave <bradley@bradleytgpcoaching.com>`; no trailers |
| clean / MERGE_HEAD / hooksPath | porcelain 0 lines; no MERGE_HEAD; core.hooksPath unset |
| delta | 12 paths (8 A, 4 M, all 100644). In `sort` order they equal `EXPECT_DELTA` exactly |
| scope | `diff BASE HEAD -- src prisma package.json package-lock.json` = 0 files; `-- test/utils` = exactly `A2_A1_EDITS` (4) |
| FREEZE-s11a2 | 12 lines, paths == delta, 12/12 byte-equal at HEAD (`git show HEAD:p | sha256sum`) |
| FREEZE-v3 split | file sha e6e3a15a… unchanged. Byte-equal: rls spec, journey-core, bootstrap, db.ts (4). DIFF: exactly guard spec, harness, pg-harness, worker (the 4 in `A2_A1_EDITS`, which FREEZE-s11a2 covers). The skip is a `case` on exact space-delimited path, so no other line can be skipped |
| FREEZE-s11c | sha 2d58f9d1… ; 7/7 byte-equal |
| FREEZE-s11b | sha 603ffa02… ; 6/6 byte-equal; its paths == new literal `S11B_FILES` |
| changed blob pins | guard 3975aab1, harness 1b66137a, pg-harness ad32b569, worker 562038a1, induction 1b9832bc: all equal `git ls-tree HEAD`. The old v2 pins e1ace171/240a4969/2cb6e79a/d1504f6a equal the BASE blobs, which confirms these files really changed |
| unchanged blob pins | rls a4ba04ee, journey 95aee484, bootstrap 0e234b58 (100755), db.ts 3f04f566, jest.rls 44c96915, jest 769a4146, readiness 1afcb07d, service dfd2e267, dto 9eb9f3d3, redrive aac3f7a8, lifecycle a4a79648, scout.service 9afaac48, schema f86c1f5d (sha d6d01f54…): all equal at HEAD |
| migrations | tree 7b6fe0ed at both HEAD and BASE; 173 dirs; HARNESS_BASE 711c1f8f is an ancestor of HEAD |
| induction spec bytes | pinned live switch at L52; BADPAT (incl. `it.each`) matches 0 lines; `^\s*it\(` = 4 (L157 J09, L316 J10, L437 J11(a), L477 J11(b)); `jest.setTimeout(600000)` L50; one top-level `live(...)` L85 |
| guard 95 | at HEAD `^\s*it\(` = 11 (BASE 10). The 3 `it.each` tables start at L25/L93/L121, and the A2 hunks start at L294, so the tables are untouched. The 3-row table (`'55648','55649','55650'`) is visible. The v2 run logged `Tests: 94 passed, 94 total`, so 94 + 1 = 95 |
| G2_S11_CANDIDATE_HEAD | runner L170 `G2_S11_CANDIDATE_HEAD=$EXPECT_HEAD` is unchanged, so it now resolves to 03e7a234. db.ts L137-151 requires it to equal the checked-out HEAD, and the clone is checked out detached at `$EXPECT_HEAD` |
| lane / clone absence | `worktrees/fa72-s11a2-pg1` absent; `runtime/clusters/s11` absent; `run/s11` empty; `v1/run` absent (no STARTED or sentinel); other clusters s10d2, s10d2-v2, s11b-s10b have no postmaster.pid; `pgrep -cx postgres` = 0; lock inode 686480 == `EXPECT_LOCK_INODE` |

## Induction stage (mirrors the other stages): PASS
- Command `./node_modules/.bin/jest --runInBand --ci test/scout/s11/journey-induction.pg.spec.ts`, default config. This is the same form
  as journey-core, readiness and redrive, which ran under the default config in v2. It runs in `$W` under `timeout -k 30 3000`, once,
  with no retry, no `--testTimeout` and no `--forceExit`.
- It logs to `JLOG6=$R/jest-induction.log`, which is added to the RECEIPTS list in `finish()`.
- `jcheck induction "$JLOG6" "$JRC" "$EXPECT_TESTS_INDUCTION"` requires rc 0, `Test Suites: 1 passed, 1 total` and
  `Tests: 4 passed, 4 total`. Any failure goes to `fail` -> teardown -> sentinel (stop at first failure).
- Order: after settle-redrive and before the no-DB guard stage (95).
- The pre-lock checks add IND to the harness-bytes read, the live-switch grep, BADPAT, the `N5` it-count, the blob-pin loop and the
  `$EXPECT_INDUCTION_BLOB` / `$S11A2_FREEZE_SHA` entries in the pins-filled `case`.

## Timeouts: PASS
The inner sum is 120+120+600+600+60+60+900+8x15+1500+1500+900+3000+3000+300+75+75 = **12930 s** (recomputed). The outer bound is
13500 in both the launcher `exec timeout -k 30 13500` and the Usage line, leaving a 570 s margin. The launcher delta is only the
comment and 10200 -> 13500.

## Pre-STARTED refusals: PASS (unconsumed)
Every new A2 check sits in the pre-lock block (L185-283). That block uses `fail(){ … PRELOCK_REFUSED …; exit }`, which writes
`prelock.log` only: no lock, no STARTED, no sentinel. `mkdir -p $R`, the STARTED/sentinel refusal (76), lock absent/busy/inode (75)
and O_EXCL STARTED are positioned exactly as in v2 (offset +20 lines for the header). The under-lock recheck adds
`sha FREEZE-s11a2`. As in v2, a mismatch there comes after STARTED and consumes the run. That is the accepted template semantics.

## Findings (Safety ROI)

### A
None.

### B1 — postgres-idle preflight sits after STARTED (builder's B, confirmed as template behaviour)
Confirmed as inherited: v2 has STARTED at L268 and `PREFLIGHT_FAIL postgres procs` at L299. v1 has them at L295 and L326. The bytes
are identical and the delta does not touch them. The accepted v2 T3 GO ran with this ordering.
- CLASS: launch precondition (parent-owned operational discipline; not a binding defect, no byte change required).
- CONCRETE HARM: if any `postgres` process is live at launch (for example another lane), preflight exits rc 71 after STARTED. That
  consumes the single-run grant with no proof produced, and a new grant/binding round is needed.
- EXACT DECISION BLOCKED: the moment the parent launches (not whether the binding is GO). `launch-when-free.sh` waits only for the
  lock, not for postgres idleness.
- MINIMUM CLOSURE: immediately before `bash launch-when-free.sh`, the parent confirms `pgrep -cx postgres` = 0 and that no other
  lane is scheduled to start during the lock wait. It was 0 at review time.
- EXECUTION UNLOCKED: the single S11-A2 real-PG lane run.

The builder's other two B items (shared SRC worktree frozen until the run ends; launch only with the 13500 bound) are correct parent
launch conditions. The binding already satisfies both: the parent has frozen the SRC, and the launcher carries 13500. I record them
as agreed. They add no new closure beyond "keep fa72-s11a2 frozen at 03e7a234 and use `launch-when-free.sh`".

### C (record, qualify, continue)
- C1: The fresh-clone check drops `HEAD^^` and checks `HEAD = EXPECT_HEAD`, `HEAD^{tree}` and `HEAD^ = BASE`. It does not repeat
  `rev-list --count` in the clone. The README says the count is checked "pre-lock and fresh clone", but only the pre-lock check exists.
  This is harmless, because HEAD is pinned to the exact commit sha, whose parent set was already verified pre-lock and under lock.
  The only issue is README wording.
- C2: The README says the runner went from "411 -> 440 lines". `wc -l` gives 410 -> 440. This is cosmetic.
- C3: The 570 s outer margin does not cover the theoretical worst case where every timed stage hits its bound and then needs the
  30 s `-k` grace (up to 24 x 30 s). The same property held in v2, with a 270 s margin. A realistic run is about 15-20 min against
  13500 s. An outer kill still ends as a loud failure, and the fixture's lane markers stay in place for a marker-gated destroy.
- C4: `launch-when-free.sh` falls through after 720 polls (about 1 h) and execs the runner anyway. If the lock is still busy, the
  runner refuses with rc 75 before STARTED, so the run is not consumed. This is inherited from v2.
- C5: `sort` is locale-dependent for `EXPECT_DELTA`, FREEZE-s11a2 and `A2_A1_EDITS`. The host has only C/C.utf8/POSIX installed and
  LANG/LC_* are unset. I verified that `s11-sources.ts` sorts before `s11_second/`. A different locale would fail pre-lock (rc 70,
  not consumed).
- C6: I agree with and carry forward the builder's C items: the J11 10 s lock-wait window under load (fails loudly, never a false
  pass); induction expectations not yet proven live (A2 C1); hook time beyond 600 s inside the 3000 s bound; `clusters/s11` will again
  need archive-and-remove after this run; inherited header history comments ("pins from c8ee9005", inode 692282) are never compared;
  unit specs adjacent to S11-B are covered only by FREEZE-s11b byte equality.

## Commands run (all read-only; RC)
1. `cat WORKER_RULES.md; cat s11a2/S11A2_BINDING_REVIEW_GRANT.md; ls -la s11a2 s11a2/binding/v1` — RC 0
2. `cat README.md BINDING.sha256 FREEZE-s11a2.sha256; sha256sum *; cat launch-when-free.sh; ls s11b/binding/s11-lane-v2` — RC 0
3. `sha256sum` v2 runner/fixture/launcher; `cmp` fixtures; `diff` launchers; `diff v2 v1 runner > /tmp/s11a2_rev_runner.diff`; `wc -l` — RC 0 (diff rc 1 = differences, expected)
4. `cat /tmp/s11a2_rev_runner.diff` — RC 0
5. In fa72-s11a2: `git rev-parse HEAD HEAD^{tree} HEAD^ BASE^{tree}`, `symbolic-ref`, `rev-list --count`, `rev-parse --verify land ref`, `status --porcelain`, `rev-parse --git-dir`, MERGE_HEAD test, `config --get core.hooksPath` (rc 1 = unset), `log -1`, `diff --name-status/--name-only/--raw` — RC 0
6. `sed -n 81,140p s11-pg-proof.sh` — RC 0
7. For the 4 FREEZE files: `sha256sum` + per-line `git show HEAD:p | sha256sum`; path sorts. RC 1 came only from my final ad-hoc diff of FREEZE against BINDING.sha256. That compared the wrong file and I disregarded it; it has no bearing on the result.
8. `git ls-tree HEAD -- <18 paths>`, migrations tree/count, schema sha, `merge-base --is-ancestor`, BASE blobs of the 4 A2 files — RC 0
9. `grep -n` over the runner for BADPAT/jcheck/STARTED/pgrep/flock/fail — RC 0
10. `git show HEAD:<induction spec>` / `<guard spec>` through grep (live switch, BADPAT, it-counts, it.each lines, diff hunks) — RC 0
11. `sed -n 284,345p` and `sed -n 345,440p` of the runner (read, not executed) — RC 0
12. `grep` for G2_S11_CANDIDATE_HEAD/PORT/lane/inode lines in v1, the preflight-postgres and STARTED line numbers in v2 and v1, and `git show HEAD:test/utils/g2-s11-db.ts | sed -n 135,152p` — RC 0
13. `ls` of pg1 clone/clusters/s11/run/s11/v1 run/postmaster.pid; `pgrep -cx postgres`; `stat -c %i` lock; `sha256sum` of the 3 prior FREEZE files; grep of s11a2_review.md; DELTA headers — RC 0 (ls "No such file" results are the expected absence)
14. Comparison of DELTA hunks against a fresh `diff -u` (runner, launcher); `locale -a`; LANG/LC env; sort-order probe; timeout-sum arithmetic; `timeout -k` bound census — RC 0
15. `sed -n 172,184p` of the runner; `mkdir`/prelock line positions v2 against v1; `ls` of the v2 run dir — RC 0
16. `grep '^Tests:'` of the v2 jest-guard.log; `cat` of the v2 sentinel; grep of s11a2_build.md — RC 0

## Open risks
The live induction outcome is unproven until the parent runs the binding (A2 C1). No binding-level risk blocks launch beyond B1's
postgres-idle check.
