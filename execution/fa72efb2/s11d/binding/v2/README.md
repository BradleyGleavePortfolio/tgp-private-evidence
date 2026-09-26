# S11-D binding v2 (source only; not run)

Built by minimum substitution from `s11d/binding/v1/s11-pg-proof.sh` (sha256 `8dda61d6fb0122dbfde910aea4acd5f6fb0649b3d6747b7b7933a693dbd46225`). That run was consumed and FAILED at jest-full: J20 passed 4/4, while J19 legs A and B hit spec defects (`s11d/PROOF_V1_FINDING.md`). v1 is left untouched. The build script `.build-s11d-v2.py` makes 16 count-asserted substitutions. Full diff: `DELTA-from-v1.diff`.

## Changed pins (all verified read-only in worktrees/fa72-s11d2 with GIT_OPTIONAL_LOCKS=0)

| Pin | v1 | v2 |
|---|---|---|
| EXPECT_HEAD / tree | 38d0d366 / 075c1513 | aed23289024898cceca7385d3778cd7373b7424d / 6787b25531ab7614c9de70e745381a996d66b119 |
| chain | BASE -> R1 -> HEAD (2) | BASE 54be96f1 = HEAD~3 -> R1 a52d20d6 = HEAD^^ -> R2 38d0d366 = HEAD^ -> HEAD (count 3); the same parent checks apply in the clone check |
| new R2_HEAD | none | 38d0d366730331e4edf19a14cda8247435b89431 |
| r1..r2 check | R1..HEAD | R1..R2 = test/scout/s11/journey-full.pg.spec.ts |
| new r2..r3 check | none | R2..HEAD = test/scout/s11/journey-full.pg.spec.ts (exactly one path, +17/-5) |
| EXPECT_FULL_BLOB | ecfe8cef | 9ca2ebb6c1f0f43d3984dfcaf94021de03abbd6d |
| FREEZE-s11d | 6819f785… (84afc31a… spec) | 60977d8c13be17ec1aeed6b1338d4bac3e12c17cde32ee1432364f3c061befc3 (`110a02df004301f553fdbce44a77872d29f3484d6aa25fa7bb6bc914f79abffe  test/scout/s11/journey-full.pg.spec.ts`) |
| W | worktrees/fa72-s11d2-pg1 | worktrees/fa72-s11d2-pg2 (absent) |
| D / run | s11d/binding/v1 | s11d/binding/v2 (run/ does not exist yet) |

These are unchanged and re-verified by the replay: BASE 54be96f1 / tree 435fec78; LAND_REF origin/land/s11d = aed23289; the BASE..HEAD delta is that single spec, with nothing touched in src, prisma, package.json, package-lock.json or test/utils; FREEZE-s11a2 12/12; FREEZE-v3 kept lines; FREEZE-s11c 7/7; FREEZE-s11b 6/6; all 18 blob pins; migrations 7b6fe0ed / 173 / S10-B; fixture 777e6ac3…1636 (byte-identical copy); lane clusters/s11 absent; run/s11 empty; port 55648; donor fa72-s11a1/node_modules; rg present.

Source hooks are now lefthook regular files (pre-commit acfee2ea…d7, commit-msg 9b4e8c9f…df, installed 18:57Z; they point at fa72-s11d2/node_modules/lefthook-linux-x64, which exists). hooksPath is unset, there is no MERGE_HEAD, and the tree is clean. I did not observe the r3 commit being made. The claim that it went through lefthook comes from the builder report, and it is consistent with the hooks existing before the 19:31:43Z commit time.

## r3 content (spec only)

- Leg A: `redrive.pushes` changes from 1 to 0, because the replayed claim's push is first-claim-only, as in the landed settle-redrive `expectNoClaimSideEffects`.
- Leg B: the report reads `families` instead of `coverage`.
- The static checks still hold: the live switch is at L79, no banned patterns (skip/only/todo/each) appear, and `it(` count = 6 (L168, 341, 515, 524, 552, 595).

## Stages, counts, timeouts (unchanged)

- Stages: bootstrap, then full (`jest --runInBand --ci test/scout/s11/journey-full.pg.spec.ts`, 6 tests, run/jest-full.log), then guard (95, with G2_S11_* unset). That is 101 tests in 2 suites, with stop at the first failure.
- Timeouts: full 4200 s (v1 observed 82 s), inner sum 7230 s, outer `timeout -k 30 7800`.

## J20 scratch worktree

In the v1 run, W pg1 lists only its main worktree afterwards, and no `/tmp/s11d-core-diff-gate-*` directory remains. So cleanup worked, and nothing in the runner changes for this.

## Read-only replay

I extracted the unmodified pre-lock block (lines up to `# ---- lock, then O_EXCL STARTED`) with R pointed at /tmp/s11d-v2-replay and ran it. It returned rc 0 with PRECONDITIONS_OK. It invokes `postgres --version`, `prisma --version` and `node --version`. It starts no server, takes no lock, and runs no jest. No files changed under runtime, the donor or SRC.

## Risks

- C: the J19 fixes are proven only by a live run. v1 bytes are not rerun.
- C: bounds are unchanged and generous, since v1's full stage took 82 s.
- No A or B findings.
