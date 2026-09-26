# S10-D D2 real-PG proof binding v2 — EXEC-FA72EFB2 (SOURCE ONLY: NOT RUN, NOT GRANTED)

Builder: T3 binding build (`s10d2/D2_BINDING_V2_BUILD_GRANT.md`). Parent session fa72efb2. Derived from `s10d2/binding/v1`
(reviewed GO; v1 run reached jest and failed only on candidate assertions, `PROOF_V1_FINDING.md`) by minimum substitution.
The builder ran no runner, fixture, jest, bootstrap or PostgreSQL. It did not take the canonical lock, did not git-commit
the evidence repo and did not write in any worktree or runtime path.

## Files (sha256 of every file, including this README, listed in `BINDING.sha256` with relative paths)
| File | Role |
|---|---|
| `d2-pg-proof.sh` (mode 755) | runner v2 |
| `d2-fixture.sh` | fixture v2; sha256 `6de009d72d71f1ce905af3b1835078a9f5d270606c37343a79a934adcd5ae4d0` = runner `EXPECT_FIXTURE_SHA` |
| `DELTA-from-v1.diff` | `diff -u ../v1/d2-pg-proof.sh d2-pg-proof.sh` |
| `DELTA-fixture-from-v1.diff` | `diff -u ../v1/d2-fixture.sh d2-fixture.sh` (literal lane substitution + prose only) |
| `launch-when-free.sh` | v1 launcher; a one-line comment fix (v1 said "S11-A1 v3" in error). Last line: `exec timeout -k 30 4500 bash "$D/d2-pg-proof.sh"` (`D` = this dir) |
| `.build-d2-v2.py` | the builder's substitution script: every replacement asserts its exact count on the v1 bytes. Audit only, not part of the binding |

`bash -n` = 0 for `d2-pg-proof.sh`, `d2-fixture.sh` and `launch-when-free.sh`. The v1 binding verified before derivation
(`sha256sum -c v1/BINDING.sha256`: all OK).

## Changed pins (v1 → v2); every value read by the builder in SRC = `worktrees/fa72-d2` (read-only git / sha256sum)
| Variable | v1 | v2 | Provenance |
|---|---|---|---|
| `D` | `…/s10d2/binding/v1` | `…/s10d2/binding/v2` | this dir (so `R=$D/run` is a fresh, empty run dir; v1 `run/` untouched) |
| `W` | `worktrees/fa72-d2-pg1` | `worktrees/fa72-d2-pg2` | absent (checked); pg1 (v1 clone, 745 MB) still exists and is not touched |
| `EXPECT_HEAD` | `144269d1…593c` | `275e458ca5a6b3684bb6ec83edb2a854056a6fd0` | `git rev-parse HEAD` = `refs/heads/fa72/d2-r1`; `symbolic-ref HEAD` = `refs/heads/fa72/d2-r1` |
| `EXPECT_TREE` | `a0bc3c09…` | `6267ef6a57225af187f5a21fb8a2c3cc3fd6103e` | `rev-parse HEAD^{tree}` |
| `D2_V1_HEAD` (new) | — | `144269d13db5275a2d6689bebb2f7dca8367593c` | `rev-parse HEAD^`; `rev-parse 144269d1^` = BASE 7fdcbc04 |
| `EXPECT_D2_BLOB_PG` | `074b0fa0…` | `352cb34027766b126bb06e6c5b4f164ace2afa26` | `rev-parse HEAD:test/scout/s10/s10-unseen.pg.spec.ts` (mode 100644; content sha256 a3dfcd93…8403) |
| `EXPECT_LAND_REF` (`LAND_REF=refs/remotes/origin/land/s10d2`) | `144269d1…` | `275e458c…` | `rev-parse refs/remotes/origin/land/s10d2` in SRC already = 275e458c at build time |
| `EXPECT_TESTS_D2` / `EXPECT_TESTS` | 8 | **9** | `grep -cE '^\s*it\('` on HEAD bytes = 9, `test(` = 0 |
| `EXPECT_FIXTURE_SHA` | `0fadafa3…` | `6de009d7…4d0` | `sha256sum d2-fixture.sh` (v2) |
| `LANE` / `SOCK` | `clusters/s10d2` / `run/s10d2` | `clusters/s10d2-v2` / `run/s10d2-v2` | lane decision below; both absent (checked) |

Unchanged and re-verified at 275e458c: BASE 7fdcbc04 / tree a802231e; the 7 other D2 blobs (4e21d522, 6b8695c8, 94dcc819, 4d5bf92e,
94e7f567, 90d644b4, 41df91ec; identical at 144269d1 and HEAD); contract 1a5deca5 at BASE and HEAD; S10-B harness blobs and schema/migration
blobs; S10-C spec 50a0deae; it() s10b 24 / s10c 8; migrations tree 7b6fe0ed, 173 dirs; no prisma/manifest/`g2-s10b-*` diff since S10B_HEAD;
package-lock / schema sha256 pins; S10B_HEAD and harness base ancestors of BASE; FROZEN file sha e9c71f09 and 29/29 at HEAD (P exception
9b5de374); SRC hooks 54aa5cd8 / dc998a5e, no core.hooksPath; SRC clean; donor client 2c819c8a and NM lock 05bc530a; lock inode 686480.

## Structural checks changed by the spec change (base remains 7fdcbc04)
- **Commit chain (v1 L181: `HEAD^ = BASE`, `rev-list --count = 1`).** The candidate is now two commits, so this becomes `HEAD^ = D2_V1_HEAD`,
  `D2_V1_HEAD^ = BASE_HEAD`, `rev-list --count BASE..HEAD = 2`. One new line then requires
  `git diff --name-status --no-renames D2_V1_HEAD HEAD` = exactly `M test/scout/s10/s10-unseen.pg.spec.ts` (verified).
- **Clone check (v1 L336 `HEAD^ = BASE` in W)** becomes `HEAD^ = D2_V1_HEAD`.
- `D2_V1_HEAD` is added to the 40-hex pin loop.
- **Unchanged and still valid:** the 8-path exact delta, `--diff-filter=A` pure-additions and all-100644 checks are all computed BASE..HEAD.
  Against BASE the modified spec is still an added file, so all three hold at 275e458c (verified). The 8-blob loop is unchanged except the PG pin.
- **Spec shape** (it count, one LIVE line, one suite line, one `suite(`, LIVE ×2, no skip/only/todo/each outside comments, requires the two
  S10-B harness modules, no s10c/s10d/s11 harness reference). This was re-evaluated with the runner's own grep expressions on the HEAD bytes, and all pass.

## Expected count
- 9 `it()` in `test/scout/s10/s10-unseen.pg.spec.ts` @ 352cb340. The cases are:
  - R39 (a)–(f): 6 cases (L311, 348, 365, 383, 389, 404);
  - R41 replay: 1 case (L338);
  - R27 live: 1 case (L415);
  - (h) staged clients rows → partial / unresolved_identities: 1 case (L429).
- Required jest output: `Tests: 9 passed, 9 total`, `Test Suites: 1 passed, 1 total`, and one PASS line equal to the D2 spec.

## Lane decision: fresh lane directory `clusters/s10d2-v2` + `run/s10d2-v2` (the parent does NOT need to archive/remove the v1 lane)
- **Why the v1 lane can't be reused.** The v1 runner refuses at preflight (`[ ! -e "$LANE" ]`, rc 71, "fresh init only; never adopt").
  The fixture `init` also refuses an existing data dir. `runtime/clusters/s10d2` exists, with pg-data retained. Reusing it would require the
  parent to destroy retained v1 evidence.
- **Why a fresh lane works.** v2 uses a new lane dir. The fixture's lane literals (LANE, SOCK, the `case "$LANE"` guard) and the runner's
  matching whole-line cross-checks are substituted to `s10d2-v2`.
- **How the v1 lane is treated.** The generic other-lane scan then fingerprints `clusters/s10d2` as an other lane and requires three things:
  - no postmaster.pid (verified absent; v1 stopped cleanly);
  - it is never started;
  - its `postgresql.conf` / `pg_control` sha256 are unchanged at post. At build time those are `c4c16872…e19d` / `78be3299…ac05`.
- **v1 run directory.** The empty `runtime/run/s10d2` is not scanned and not used.
- **Socket path.** `…/runtime/run/s10d2-v2/.s.PGSQL.55649` is 75 bytes, under the 107-byte limit.
- **Harness.** The S10-B harness/bootstrap pin no cluster path; the data dir is passed as `G2_S10B_DATA_DIRECTORY=$LANE/pg-data` and checked by identity `SHOW data_directory`.
- **Precedent.** The S11-B binding uses the same pattern (`clusters/s11b-s10b`).
- **Port 55649 is shared with the S11-B S10-B-lane binding** (`s11b/binding/s10b-lane-v1`: lane `clusters/s11b-s10b`, W `fa72-s11b-pg2`).
  The two runs are sequential under the canonical lock, and each refuses a live 55649 listener or any postgres process at preflight. Whichever
  runs second fingerprints the other's retained stopped lane as an other lane (it must have no postmaster.pid). The lane dirs and clones are
  disjoint. The launcher waits for 3 idle polls, but two launchers started together could both pass the poll. The loser then gets
  `REFUSED: canonical lock busy` (rc 75, pre-STARTED, not consumed). The parent should launch them one after another.

## Receipts order (C, left as template)
`finish()` hashes RECEIPTS before `log "END …"; exit` on the next line. Moving the receipt line after END would be unreachable, because END
and `exit` share one line. Fixing it needs a split/edit, not a one-line move, so per the grant it is left unchanged. After the run,
`sha256sum -c` will again report the main log as changed, and all other receipts verify.

## Open risks (Safety ROI)
- **R1 — C.** The land ref already equals 275e458c in SRC (`refs/remotes/origin/land/s10d2`). If the parent re-pushes or re-fetches and it
  moves, the run refuses pre-lock (rc 70, not consumed).
- **R2 — C.** Disk: 5.6 GB is free. The v1 clone `fa72-d2-pg1` (745 MB) plus the new `cp -a` copy of about 750 MB fit, and `fa72-s11*-pg*`
  clones also exist. Removing pg1 is the parent's decision and is not required.
- **R3 — C.** The candidate chain is 2 commits. The chain check pins both, and HEAD's own delta is the pg spec only.
  The e2e / core-diff gate status at 275e458c is the reviewer's (D2_R2_REVIEW_GRANT). This binding does not assert it.
- **R4 — C.** The spec's new expectations are candidate bytes. A 9-case failure is a candidate result (as in v1), not a binding defect.
- Carried v1 risks R2–R9 are unchanged (FROZEN P exception, port 55648 refusal, dropped s10-b must-exist, jest.config.js, hook shas,
  `service_role` connection).

## Commands run by the builder (all read-only unless noted; RC)
- **Reads:** `cat`/`sed`/`grep`/`ls` of WORKER_RULES, the grant, PROOF_V1_FINDING, v1 README/runner/fixture/launcher/launcher.out, and the s11b s10b-lane binding. RC 0.
- **Verify v1:** `sha256sum -c BINDING.sha256` in v1: all OK, RC 0.
- **Git in SRC:** `git -C worktrees/fa72-d2` `rev-parse`/`symbolic-ref`/`status`/`rev-list`/`diff`/`log`/`ls-tree`/`show`/`cat-file`/`merge-base`/`config --get`. RC 0 (`config --get core.hooksPath` RC 1 = unset).
- **Hashes/stats:** `sha256sum` on the SRC hooks, the donor NM files, FROZEN, and the v1 lane `postgresql.conf`/`pg_control`; `stat -c %i` on the lock; `df`; `du` of pg1. RC 0. `ls` of the v2 lane/sock/W: RC 2 (absent, as required).
- **Pin evaluation:** the runner's pin-assignment lines were `eval`'d in a subshell (plain assignments only), then the chain/delta/blob/FROZEN/count checks were re-run by hand. All ok.
- **Build:** `python3 .build-d2-v2.py` → RC 0. `bash -n` ×3 → RC 0. `diff -u` ×2 → RC 1 (differences, as expected). `sed` for the launcher comment → RC 0.
