# S10-D D2 binding v2 — independent T3 delta review (EXEC-FA72EFB2)

Reviewer: fresh T3 agent, not the builder. Grant: `s10d2/D2_BINDING_V2_REVIEW_GRANT.md`. Rules: `execution/fa72efb2/WORKER_RULES.md`.
This review was read-only. It ran no runner, fixture, jest, bootstrap or PostgreSQL. It did not take, probe or `flock` the canonical lock; `stat -c %i` was the only access. It made no edit except this file and no git commit.

## Verdict: **GO** for the single parent-owned v2 real-PG proof run
There are no A or B findings. Every changed pin matches the live bytes in `worktrees/fa72-d2`. The delta from the accepted v1 is limited to the substitutions the grant asked for, plus the two-commit chain lines.

## Subject (verified: `sha256sum -c BINDING.sha256` all 7 OK)
| File | sha256 |
|---|---|
| d2-pg-proof.sh (755) | a3566fea91b2e0105ce7894871f19de4bf2d84c3d28ead8067d3ae2ad82d8008 |
| d2-fixture.sh | 6de009d72d71f1ce905af3b1835078a9f5d270606c37343a79a934adcd5ae4d0 (= runner EXPECT_FIXTURE_SHA) |
| DELTA-from-v1.diff | 7aeb89ea93d343892595c0981efa5d876d9eadb3530ac56e36fbffc7abc012fb |
| DELTA-fixture-from-v1.diff | d50473d5571e8be49f653809f94723ca1b7fd6a353b5e742585b1d876c2269ac |
| launch-when-free.sh | 15a52cc0e421f4d49d4083b645378611c81e408bec6a267dade1c17d78718cb0 |
| README.md | 1d5e963e98887f9228cea1b5b9dbadca8c9a8d30819f5152e0aa35a2ea70eedc |
| .build-d2-v2.py (audit only) | 3ee115d63136e968f748e0bc0e964466e51291323522e1d933ce66f26698ab3b |

- The v1 template is intact: `sha256sum -c v1/BINDING.sha256` returned all 6 OK.
- Both DELTA files are faithful. `diff -u ../v1/X X` regenerated here is byte-identical to each DELTA file below the two header lines, which differ only in the `../v1` vs `v1` path form (cmp rc 0 on `tail -n +3`).
- `bash -n` returned 0 for all three scripts.
- The launcher differs from v1 by one comment line only. Its last line is `exec timeout -k 30 4500 bash "$D/d2-pg-proof.sh"`, and 4500 s is above the inner soft sum of 3555 s (unchanged).

## Delta review (only the changed lines; accepted v1 lines not re-audited)
### Runner delta
The runner delta has 12 hunks.
- **Prose and header.** These are comment-only changes.
- **Changed values.** `D` moves to v2, `W` to `fa72-d2-pg2`, `SRC` stays the same (comment only). EXPECT_HEAD, EXPECT_TREE, EXPECT_D2_BLOB_PG, EXPECT_LAND_REF, EXPECT_FIXTURE_SHA and EXPECT_TESTS_D2=9 change, and D2_V1_HEAD is new. LANE/SOCK move to `s10d2-v2`, together with the matching whole-line lane guards (L154, L172) and the harness-env message.
- **D2_V1_HEAD in the 40-hex loop.** It has been added to the loop.
- **Chain check (L184).** HEAD^=D2_V1_HEAD, D2_V1_HEAD^=BASE_HEAD, `rev-list --count BASE..HEAD`=2.
- **r1→r2 check (L185).** The `--name-status --no-renames D2_V1_HEAD HEAD` output is flattened and must equal `M $D2_SPEC`. D2_SPEC is defined at L91, before this use. On live bytes, `tr`+`sed` gives exactly `M test/scout/s10/s10-unseen.pg.spec.ts`, so the check passes. A rename, add or delete, or any second file, refuses the run pre-lock with rc 70.
- **Clone check (L340).** It now requires HEAD^ = D2_V1_HEAD.
- Nothing else in the runner changed.

### Fixture delta
The fixture delta is prose plus the literal changes `LANE=$RUNTIME_ROOT/clusters/s10d2-v2`, `SOCK=…/run/s10d2-v2` and the `case "$LANE"` guard. The runner's whole-line cross-checks (L172) match these new literals.

## Pin verification (read-only git / sha256sum in SRC = /home/user/workspace/worktrees/fa72-d2)
| Check | Live value | Result |
|---|---|---|
| `symbolic-ref HEAD` | refs/heads/fa72/d2-r1 | ok |
| HEAD | 275e458ca5a6b3684bb6ec83edb2a854056a6fd0 | = EXPECT_HEAD |
| HEAD^{tree} | 6267ef6a57225af187f5a21fb8a2c3cc3fd6103e | = EXPECT_TREE |
| HEAD^ | 144269d13db5275a2d6689bebb2f7dca8367593c | = D2_V1_HEAD |
| HEAD^^ and 144269d1^ | 7fdcbc044dba1747d0db2f2750ced951f3b6b752 | = BASE_HEAD; base tree a802231e ok |
| `rev-list --count 7fdcbc04..HEAD` | 2 | ok |
| `diff --name-status --no-renames 144269d1 HEAD` | `M test/scout/s10/s10-unseen.pg.spec.ts` | the 1-file check holds |
| refs/remotes/origin/land/s10d2 | 275e458c… | = EXPECT_LAND_REF |
| HEAD:pg spec | 352cb34027766b126bb06e6c5b4f164ace2afa26 (mode 100644; content sha256 a3dfcd93…8403); v1 blob 074b0fa0 at 144269d1 | = EXPECT_D2_BLOB_PG |
| The 7 other D2 blobs | 4e21d522, 6b8695c8, 94dcc819, 4d5bf92e, 94e7f567, 90d644b4, 41df91ec | identical at 144269d1 and HEAD, and equal to the runner pins |
| BASE..HEAD | the 8 paths, all `A`, all 100644 | exact delta, pure additions and modes all still hold |
| it() count at HEAD | `grep -cE '^\s*it\('` = 9 (L311, 338, 348, 365, 383, 389, 404, 415, 429); `test(` = 0 | = EXPECT_TESTS_D2 = 9 |
| Spec shape (the runner's own greps, re-run on HEAD bytes) | LIVE line 1, suite line 1, `^suite(` 1, LIVE ×2, BADPAT on non-comment rest: no match | ok |
| Harness requires | `require('../../utils/g2-s10b-pg-harness')` and `…/g2-s10b-harness` present; no s10c/s10d/s11 harness reference | ok |
| FROZEN | sha e9c71f09…be21; 29/29 at HEAD (P exception applied) | ok |
| Contract | docs/contracts/importer-openapi.json = 1a5deca5 | ok |
| prisma/migrations tree | 7b6fe0ed | ok |
| SRC | clean (0 porcelain lines) | ok |
| SRC hooks | 54aa5cd8… / dc998a5e…; `core.hooksPath` unset (rc 1) | ok |
| Donor node_modules | present | ok |
| Commits | author and committer on both D2 commits are Bradley Gleave <bradley@bradleytgpcoaching.com> | ok |

Because `144269d1..HEAD` touches only the pg spec, every other HEAD-path precondition reads the same bytes as the v1 run. That run passed all pre-lock and prestart checks and reached jest.

## Lanes and runtime state (read-only listing)
- **Lane decision.** A fresh lane, `clusters/s10d2-v2` + `run/s10d2-v2`, is correct and needed. The v1 lane `clusters/s10d2` exists, and preflight refuses an existing `$LANE` (rc 71). Reuse would have destroyed retained evidence.
- **v2 paths.** `clusters/s10d2-v2`, `run/s10d2-v2` and `worktrees/fa72-d2-pg2` are all absent.
- **v1 run dir.** `binding/v2/run` does not exist yet, so the run is unconsumed.
- **v1 lane protection.** `clusters/s10d2` has no `pg-data/postmaster.pid`. Its postgresql.conf sha256 is c4c16872…e19d and its pg_control sha256 is 78be3299…ac05, both equal to the README. The generic other-lane loop (L325–328; v1 bytes, unchanged) refuses a postmaster.pid, fingerprints the lane, and requires it unchanged at post. The fixture's `case "$LANE"` guard refuses any lane other than s10d2-v2, so the v1 lane can never be started or destroyed.
- **Other runtime state.** It is currently the only directory under `clusters/`. `run/s10d2` is empty, and neither `run/s10d2` nor `run/s11` is scanned.
- **Processes, ports and lock.** No postgres process is running and there are no listeners on 55646–55649. The lock inode is 686480 (= EXPECT_LOCK_INODE).
- **Pre-STARTED refusals do not consume the run:**
  - pre-lock `fail` exits with PRELOCK_REFUSED, before the lock and with no sentinel;
  - the prestart `refuse` (L298–303) removes W only if this run created it by exclusive `mkdir` (L336–337);
  - the one-shot checks are only `$SENT` and `$R/STARTED`, and STARTED is written with O_EXCL after the clone, node_modules copy and verification (L367).

  These are v1 mechanics, unchanged by the delta.

## Findings
**A: none. B: none.**

**C (record, qualify, continue):**
- **C1 — stale README text.** README says v1 clone `fa72-d2-pg1` "still exists and is not touched" (pins table and R2). In fact the parent has removed it (the grant says so; `ls` confirms absent). This has no effect on the run: the runner never references pg1. Disk now has 6.3 GB free, enough for the roughly 750 MB clone plus node_modules copy.
- **C2 — receipts order (carried).** RECEIPTS.sha256 is still written before the END line (L370 vs L372). After the run, `sha256sum -c` will report the main log as changed and all other receipts verify. The builder's reason for not moving it is sound: END and `exit` share one line, so the fix is an edit rather than a one-line move. This is recorded, as in PROOF_V1_FINDING.
- **C3 — the land ref is already at 275e458c in SRC.** If it moves before launch, the run refuses pre-lock with rc 70 and is not consumed.
- **C4 — shared port 55649 with S11-B.** The S11-B s10b-lane binding uses the same port. The two runs must be sequential under the lock, and the parent should launch them one after another. Whichever runs second fingerprints the other's stopped lane. A concurrent loser refuses with rc 75 before STARTED.
- **C5 — a 9-case failure would be a candidate result, not a binding defect.** The spec's expectations are candidate bytes (r2 review GO, `d2_r2_review.md`).

## Commands run (all read-only; RC)
- **Reading rules, grants and README:** `cat` of WORKER_RULES.md, D2_BINDING_V2_REVIEW_GRANT.md, D2_BINDING_V2_BUILD_GRANT.md, D2_BINDING_REVIEW_GRANT.md, PROOF_V1_FINDING.md and v2/README.md. RC 0. An initial `cat` of the review grant gave RC 1 because the file was not yet present; it appeared at 16:59Z.
- **Listing:** `find`/`ls -la` of s10d2 and the evidence repo. `git -C tgp-private-evidence log -5` / `status --short`. RC 0.
- **Binding integrity:** `sha256sum -c BINDING.sha256` in v2 and v1, RC 0. `bash -n` ×3, RC 0. `diff -u … | cmp - DELTA…`: RC 1 on the full files (header path form only), RC 0 on `tail -n +3`. `diff v1/launch-when-free.sh v2/launch-when-free.sh` RC 1, with the one comment line. `sha256sum d2-fixture.sh` RC 0.
- **Git reads in SRC:** `git -C worktrees/fa72-d2` `symbolic-ref`, `rev-parse` (HEAD, tree, parents, land ref, blobs), `rev-list --count`, `diff --name-status/--name-only/--stat`, `status --porcelain`, `log -3`, `show HEAD:<spec>` piped to grep/sha256sum, `ls-tree`, `config --get core.hooksPath` (RC 1 = unset). All other RCs were 0 (grep no-match RCs are expected).
- **Pin evaluation:** `eval` of plain pin-assignment lines from the runner, in the shell only. FROZEN loop on HEAD blobs. `sha256sum` of FROZEN, the SRC hooks, and the v1 lane postgresql.conf/pg_control. RC 0.
- **Runtime state:** `ls` of runtime clusters/run, worktrees/fa72-d2-pg* (RC 2, absent) and the v1 postmaster.pid (RC 2, absent). `stat -c %i` of the lock. `df -h`. `pgrep -a postgres` (RC 1, none). `ss -ltn | grep 5564[6-9]` (RC 1, none).
- **Runner and review excerpts:** `sed -n`/`grep -n` over d2-pg-proof.sh; `grep` of d2_r2_review.md for its verdict; `tail` of v1/launcher.out. RC 0.
- **Output:** this report, written with the write tool.
