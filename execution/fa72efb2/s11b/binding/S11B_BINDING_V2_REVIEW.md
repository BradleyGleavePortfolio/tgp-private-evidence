# S11-B proof bindings v2: independent T3 delta review (EXEC-FA72EFB2)

Reviewer: fresh T3 agent (not the builder), working under `s11b/S11B_BINDING_V2_REVIEW_GRANT.md` and `WORKER_RULES.md`.
Mode: read-only. I did not run a runner, fixture, jest, bootstrap, PostgreSQL or npm. I did not take `test-validation.lock`; I only ran `stat` and `lslocks` on it. The only file I edited is this report.
There was one procedural slip with no effect on state. See C1: it is disclosed there in full.
Scope: only the delta from the accepted v1 bindings (`S11B_BINDING_REVIEW.md`, GO/GO). I did not re-audit the unchanged v1 bytes.

## Verdict
| binding | verdict |
|---|---|
| A — `s11b/binding/s11-lane-v2/` (S11 lane, `s11-pg-proof.sh`, 122 tests / 5 suites) | **GO** |
| B — `s11b/binding/s10b-lane-v2/` (S10-B lane, `s10b-lane-pg-proof.sh`, 32 tests / 2 suites) | **GO** |

**A/B findings: none against the binding bytes.** One launch precondition from the builder still stands. It is not a defect in the bindings:
- **B-PRE (carried from the builder, still open).**
  - CLASS: launch precondition.
  - CONCRETE HARM: `worktrees/fa72-s11b` is the shared clone source.
    - If it moves before launch, the run stops with PRECONDITION_FAIL rc 70 before the lock. That run is not consumed.
    - If it moves between the lock and the clone, A fails 70/71 after STARTED and the run is consumed. B refuses before STARTED.
  - EXACT DECISION BLOCKED: launching either v2 binding.
  - MINIMUM CLOSURE: the parent keeps fa72-s11b frozen on `fa72/s11b-r2` = dda794d7, clean, until both runs end. The grant says it is frozen, and I found it in exactly that state (see Pins).
  - EXECUTION UNLOCKED: the A run, then the B run.

## Subjects (`sha256sum -c BINDING.sha256` rc 0 in each dir; BINDING.sha256 files: A bcdaa03b…6b4, B 3fc92780…e76)
- **A files:**
  - runner 2e683690…1327 (410 lines, 755)
  - fixture 777e6ac3…1636 (`cmp` = v1)
  - FREEZE-s11b 603ffa02…d0
  - DELTA 952d3e84…a481
  - README fd9d8301…ce0ff
  - .build py 53b50979…770f
  - launcher bc80182a…2ba6
- **B files:**
  - runner 162d9a1d…0cd2 (432 lines, 755)
  - fixture 2fc8012d…db2a (`cmp` = v1, equal to EXPECT_FIXTURE_SHA)
  - FREEZE-s11b 603ffa02…d0 (`cmp` = A's)
  - DELTA 9f75b3b6…b7fa
  - README 3619ff4f…f741
  - .build py 894493bc…2624
  - launcher 4439dca7…97a5
- **v1 templates:** unchanged. Both v1 `sha256sum -c` checks return rc 0. The runner hashes are ef0024b2…ef36a and 2a5c5d19…2a3b, equal to the values in the v1 review.
- **Builder DELTA files:** I regenerated `diff -u v1 v2` for both runners. After the header they are byte-identical to the runner sections of `DELTA-from-v1.diff`.
- **Launcher delta:** only the header comment changed. The body is v1: A uses `exec timeout -k 30 10200`, B uses `exec timeout -k 30 4500`.
- **Launchers are now listed in BINDING.sha256.** This closes C1 from the v1 review.
- `bash -n` returns rc 0 for both runners and both launchers.

## Delta reviewed (runner hunks)
Both runners contain only these substitutions:
- D
- the SRC comment
- W (A: pg1 → pg3; B: pg2 is kept)
- BASE_HEAD and BASE_TREE
- EXPECT_HEAD and EXPECT_TREE
- new R1_HEAD and R1R2_DELTA
- LAND_REF (and B's EXPECT_LAND_REF)
- the S11B_FREEZE path and sha
- EXPECT_DELTA (and B's S11B_OWNED): 6 paths
- A only: EXPECT_LIFECYCLE_BLOB
- B only: branch `fa72/s11b-r2` in its 3 places (pre-lock rev-parse, symbolic-ref, under-lock)

R1_HEAD was added to the pins-not-filled `case` in both runners, and to B's 40-hex loop. Each chain check now requires HEAD^ = R1_HEAD, HEAD^^ = BASE and `rev-list --count` = 2. It runs in two places:
- pre-lock, in the PRELOCK_REFUSED path, where the run is not consumed;
- on the fresh clone, where it adds HEAD^^.

A new r1→r2 `diff --name-only` check runs pre-lock. It uses the same sort/tr/sed normalisation as the existing DELTA check, so the comparison is exact. No stage, count, bound, lane, port, jest command, parser or teardown line changed.

## Pins verified at worktrees/fa72-s11b (read-only git, GIT_OPTIONAL_LOCKS=0)
**Candidate state**
- HEAD dda794d7e8bee0482a7ad373795fcc51dcf54bb5, tree 802e1c196c7a0bd27f091218407f5f0b031dd760.
- HEAD^ = 645fb6db022f2ef6299ed4aa2bcd3f409d2a8298 (tree fb6ef752). HEAD^^ = 275e458ca5a6b3684bb6ec83edb2a854056a6fd0, with tree 6267ef6a57225af187f5a21fb8a2c3cc3fd6103e = BASE_TREE.
- `rev-list --count BASE..HEAD` = 2.
- The symbolic-ref is `refs/heads/fa72/s11b-r2`. `refs/heads/fa72/s11b-r2`, `origin/land/s11b-r2` and HEAD are all dda794d7. `origin/integration/importer` = 275e458c.
- The worktree is clean (porcelain 0 lines). There is no MERGE_HEAD or CHERRY_PICK_HEAD. `.git` is a real directory.
- hooksPath is unset (rc 1). The hooks are pre-commit 67e578d1…6a49 and commit-msg 18e15068…a9, equal to B's pins.
- Author and committer of 645fb6db, dda794d7 and 275e458c are all Bradley Gleave <bradley@bradleytgpcoaching.com>.

**Deltas**
- `git diff --name-only R1 HEAD` = exactly `src/scout/lifecycle/lifecycle.service.ts` and `test/scout/lifecycle/lifecycle.service.spec.ts`, which equals R1R2_DELTA.
- BASE..HEAD has 6 paths, all 100644:
  - M lifecycle.service.ts
  - M scout.service.ts
  - M test/rls-g2-s10c.spec.ts
  - M lifecycle.service.spec.ts
  - A s11b-settle-redrive.spec.ts
  - A settle-redrive.pg.spec.ts
- Sorted, these equal EXPECT_DELTA in both runners and B's S11B_OWNED.
- The 5 r1 blobs at 645fb6db equal the blobs at 4d31616f.
- The 6 delta blobs at dda794d7 equal those at 9149f823 (the T4 GO in `s11b_r2_review.md`).
- `git diff --raw 9149f823 dda794d7` = `git diff --raw 7fdcbc04 275e458c` = D2's 8 pure additions (000000 → 100644, over 2 commits).

**FREEZE-s11b v2**
- The 6 paths equal the delta, and `git show HEAD:<p> | sha256sum` matches all 6 lines.
- The diff against v1 is only the lifecycle line (7c8c42c3 → 8e7db85c) plus the added spec line (cbb0d0b2).

**A blob and freeze pins**
- EXPECT_LIFECYCLE_BLOB a4a79648 = `HEAD:src/scout/lifecycle/lifecycle.service.ts`.
- All 17 blob pins in the runner's loop match `rev-parse HEAD:<p>`. That includes redrive aac3f7a8, scout.service 9afaac48 and schema f86c1f5d.
- FREEZE-v3: sha OK, 8/8 at HEAD. FREEZE-s11c: sha OK, 7/7, and its paths equal `S11C_FILES`.

**A prisma, manifests and ancestry**
- HARNESS_BASE 711c1f8f is an ancestor of the new BASE.
- HARNESS_BASE..BASE shows no prisma or deps change, and its test/utils changes are exactly the 6 A1 utils.
- BASE..HEAD shows no change to prisma, package.json, package-lock.json or test/utils.
- The migrations tree is 7b6fe0ed at both HEAD and BASE: 173 dirs, the last being 20270124000000_scout_run_observation_expand.

**B pins**
- All 10 S10-B proof blob pins are OK at HEAD. EXPECT_S10C_SPEC_BLOB is 4a5a6bb6.
- The contract blob is 1a5deca5 at both HEAD and BASE.
- FROZEN sha e9c71f09…: 29 FROZEN rows, 29 OK at HEAD with the premise-P rule.
- S10B_HEAD a2c74e90 and HARNESS_BASE_HEAD a4af8e33 are ancestors of BASE.
- `git diff S10B_HEAD HEAD -- prisma package.json package-lock.json 'test/utils/g2-s10b-*'` is empty.

## Counts (at HEAD, `^\s*it\(`)
- **A:** rls 6, journey 8, readiness 6, settle-redrive 8. These equal the runner's EXPECT_TESTS_*. Guard 94 is a pin.
- **B:** s10b 24 and s10c 8, with no only/skip/todo/x-prefix. The total is 32, as the grant and README expect.

## D2 in the base changes no lane input
D2's 8 paths are 3 `s10_unseen.json` sources, 3 `test/fixtures/scout/s10_unseen/*` files and `test/scout/s10/s10-unseen.{e2e,pg}.spec.ts`. None of them is:
- in test/utils, prisma, the manifests, jest configs or docs;
- in FREEZE-v3, FREEZE-s11c, FREEZE-s11b or FROZEN, all of which verified at HEAD;
- a blob pin.

Every lane jest command names explicit spec paths, and none of those patterns matches `s10-unseen`. The only side effect is on the S11 guard's slug test (`g2-s11-db-guard.spec.ts` L335–343). That test reads `src/scout/reconstruct/sources/*.json`, so it now includes the `s10_unseen` slug. `grep -c s10_unseen` returns 0 for all 10 S11 harness and spec files at HEAD, so the assertion still holds. The it.each tables are static, so the count stays 94.

## Lanes, clones, one-shot
- **A lane:** `runtime/clusters/s11` is absent. `run/s11` exists and is empty, which the preflight allows.
- **B lane:** `clusters/s11b-s10b` and `run/s11b-s10b` are both absent. `runtime/clusters` holds only s10d2 and s10d2-v2, neither with a postmaster.pid.
- **Clones:** W `fa72-s11b-pg3` (A) and `fa72-s11b-pg2` (B) are both absent.
- **Run dirs:** neither v2 dir has `run/`.
- **Processes and lock:** `pgrep -c postgres` = 0. The lock inode is 686480.
- **Refusals before STARTED stay unconsumed:**
  - All new A checks sit in the pre-lock `fail` (PRELOCK_REFUSED, exit, no lock, no STARTED). The added clone-side HEAD^^ comparison sits after STARTED, as the v1 clone check did. It is redundant with the pre-lock chain check, because HEAD is content-addressed and is rechecked under the lock.
  - All new B checks are pre-lock. B's clone check runs before STARTED (`STARTED=1` is set at fixture-start), so a failure there gives PRESTART_REFUSED, the same as v1.

## C findings (record, qualify, continue)
- **C1 — reviewer procedural slip, disclosed.**
  - What happened: to emulate A's pins, I `eval`ed the runner's `^VAR=` lines in a read-only subshell. My regex also matched several compound lines (`STAGE=…; …`). Two of them, L343 and L345, contain `timeout … bash "$FIX" init|start >>"$LOG"`.
  - Why nothing executed: `FIX`, `D` and `R` were not set (my filter excluded them), so `LOG` was `/prelock.log`. Bash failed the redirection with EACCES before it ran either command (stderr: `/prelock.log: Permission denied`). `log`, `ts`, `fail` and `finish` were undefined ("command not found"). No fixture, PG, lock or file write took place.
  - Verified afterwards:
    - `/prelock.log` is absent;
    - `clusters/` holds only s10d2 and s10d2-v2;
    - `run/s11` is empty;
    - pg2 and pg3 are absent;
    - the v2 dirs have no `run/`;
    - `pgrep postgres` = 0;
    - both BINDING checks are still rc 0.
  - After this I checked B with a per-variable `grep | sed` extraction and no eval. No bytes under review changed.
- **C2 — lock currently held.** `lslocks` shows pid 19167 (`flock`) holding `test-validation.lock` at review time. This is not this reviewer. `launch-when-free.sh` waits for 3 free polls, so it is harmless. The parent should launch A, and then B only after A ends. Running both together gives an rc 75 refusal, which is not consumed.
- **C3 — stale comment text is inherited.** Examples: "inode 692282"; "pins from c8ee9005"; B's `EXPECT_FIXTURE_SHA` comment says "sha256 of s10b-lane-v1/…", which is byte-true because the fixture is identical; the fixture headers say v1/v3. These comments are never compared.
- **C4 — the unit specs are frozen, not run.** `lifecycle.service.spec.ts` (the r2 tests) and `s11b-settle-redrive.spec.ts` are frozen via FREEZE-s11b but not run in either lane. Their evidence is `s11b_r2_jest.log`.
- **C5 — carried from v1.**
  - A's soft-sum comment says 9810, but the true sum is 9930, still under 10200.
  - B shares port 55649 and its marker with the stopped s10d2 and s10d2-v2 lanes. They are fingerprinted, and the preflight requires 0 postgres processes and a free port.
  - After A runs, `clusters/s11` will again hold the lane logs. Any later S11-lane binding needs the archive step.
- **C6 — v1 is superseded.** `s11-lane-v1` (consumed) and `s10b-lane-v1` (never run, on candidate 4d31616f / base 7fdcbc04) are superseded. Do not launch `s10b-lane-v1`: its pre-lock checks would refuse it anyway (HEAD, branch and land ref).

## Commands run (all read-only; rc)
- **Reading files:** `cat` of WORKER_RULES, the v2 review and build grants, the v2 build report, `S11B_BINDING_REVIEW.md`, PROOF_A_V1_FINDING, S11B_PG_PROOF_GRANT, both v2 READMEs, BINDING and FREEZE files and launchers. `ls -la(R)` of the binding, runtime and worktrees dirs. All rc 0; the expected-absent `ls` calls returned rc 2.
- **Checksums:** `sha256sum -c BINDING.sha256` in s11-lane-v1, s10b-lane-v1, s11-lane-v2 and s10b-lane-v2: rc 0 ×4. `sha256sum` of the runners and BINDING files: rc 0.
- **Comparisons:** `cmp` of fixtures v1/v2 (×2) and of FREEZE A/B: rc 0. `diff -u` v1→v2 on the runners, launchers and FREEZE: rc 1 (differences, expected). `cmp` of the regenerated runner diffs against the DELTA sections: rc 0 ×2.
- **Syntax:** `bash -n` on 2 runners and 2 launchers: rc 0.
- **Git, in fa72-s11b with GIT_OPTIONAL_LOCKS=0:** `rev-parse`, `symbolic-ref`, `rev-list --count`, `status --porcelain`, `diff --name-only|--name-status|--raw`, `log -3 --format`, `show <rev>:<p>` piped to `sha256sum`, `ls-tree`, `merge-base --is-ancestor`, `show --stat`, `config --get core.hooksPath`. All rc 0, except hooksPath rc 1 (unset). One `git cat-file -t a b` call had a usage error (rc 128/1) and was not needed.
- **Pin emulation:** the A pin emulation eval returned rc 0, with the side-effect-free errors described in C1. The B pin emulation used grep/sed extraction and returned rc 0.
- **grep and sed:** on the runners, the guard spec at HEAD and the `s11b_r2_review.md` verdict line. `grep -c s10_unseen` over the 10 S11 files: all 0.
- **Environment:** `stat -c %i` on the lock (686480). `lslocks` (holder pid 19167). `pgrep -c postgres` (0, rc 1). `find clusters -name postmaster.pid` (none). `git status --porcelain` in the evidence repo (the v2 dirs, reports and grant are untracked; the parent commits them).

## Open risks
- B-PRE: source freeze until both runs end (above).
- C1–C6 as recorded.
