# S11-A2 real-PG proof binding v2 (EXEC-FA72EFB2) — SOURCE ONLY, NOT RUN

Built by the T3 binding builder on the parent mail (18:22Z) (v1 consumed, FAILED at jest-rls, candidate defect,
`s11a2/PROOF_V1_FINDING.md`). v1 and `v1/run/` were NOT edited (`sha256sum -c v1/BINDING.sha256` rc 0 at build time). Nothing was
run: no runner, fixture, jest, bootstrap, PostgreSQL or lock. Pins re-derived read-only in `/home/user/workspace/worktrees/fa72-s11a2`
(GIT_OPTIONAL_LOCKS=0).

## Provenance
- Template: `s11a2/binding/v1/s11-pg-proof.sh` (sha256 7da3029f67b9a47e4215825f157ba108691f941954e73608827fd07b082d3af6).
- Built by `.build-s11a2-v2.py <FREEZE-s11a2 v2 sha>`: 14 exact runner substitutions + 1 launcher substitution (header text), each
  asserted to match once. Full delta `DELTA-from-v1.diff` (runner 440 -> 450 lines; launcher 1 line; FREEZE 1 line; fixture = no diff).
  `bash -n` rc 0 on runner, fixture, launcher. `s11-fixture.sh` byte copy of v1 (`cmp` identical, 777e6ac3…1636).
- A read-only replay of the pre-lock pin checks (pin block sourced in a subshell, git reads + sha256sum only) returned OK for: head/tree,
  two-commit chain, r1..r2 = harness only, base tree, land ref, clean, delta 12, FREEZE-v3 4 kept lines, FREEZE-s11c 7/7, FREEZE-s11b 6/6,
  FREEZE-s11a2 v2 12/12 (== delta), no src/prisma/package change, test/utils = 4 A2 utils, 18 blob pins, migrations tree, W absent,
  lane absent, run/s11 empty, own run dir absent, fixture sha. I checked the pins only. I did not run the runner.

## Changed pins (everything else is v1 verbatim)
| pin | v1 | v2 (verified) |
|---|---|---|
| D / run dir | s11a2/binding/v1 (+ run/) | s11a2/binding/v2 (run/ absent; created by the run) |
| W | worktrees/fa72-s11a2-pg1 (v1 run clone) | worktrees/fa72-s11a2-pg2 (absent) |
| EXPECT_HEAD / EXPECT_TREE | 03e7a234 / 738b7116 | 54be96f18c314cae35d1e5d3000af9f06d693d81 / 435fec782672214c7e8e81b2eb91f8f9266331b4 (author+committer Bradley Gleave, subject "test(scout): S11-A2 r2 reset the S10-B tables only by cascade") |
| R1_HEAD (new) | — | 03e7a2344ef95b019c751983527bbc9f78200921 (= HEAD^, parent BASE dda794d7) |
| chain | HEAD^ = BASE, count 1 | HEAD^ = R1_HEAD, HEAD^^ = BASE, `rev-list --count BASE..HEAD` = 2 (pre-lock and fresh clone) |
| R1R2_DELTA (new) | — | `git diff --name-only R1_HEAD HEAD` = exactly `test/utils/g2-s11-harness.ts` (+5/−3: drops the three direct DELETEs from resetData; comments) |
| LAND_REF | origin/land/s11a2 = 03e7a234 | same ref, now = 54be96f1 (re-checked at build end) |
| EXPECT_HARNESS_BLOB | 1b66137a | 927d73655c586a188556353a59fa1c5939cae09a (file sha256 502c97c9f54e9ed6da7d16404559bddf87c6c45faf857046d14b20b5b1ce7be3) |
| FREEZE-s11a2 / S11A2_FREEZE_SHA | v1 a73f9211… | own-dir v2 51d901ef8689b396ed23074911dbea1daaf5058ebc54864135484b3d80047290 (11 lines identical to v1, harness line 494a683a -> 502c97c9) |
| BASE_HEAD comment | (= HEAD^) | (= HEAD^^) |
| launcher | "S11-A2 binding v1" | "S11-A2 binding v2"; `exec timeout -k 30 13500 bash "$D/s11-pg-proof.sh"` (in BINDING.sha256) |

Unchanged and re-verified at 54be96f1: BASE dda794d7 / tree 802e1c19; delta = the same 12 paths; no src/prisma/package.json/
package-lock.json change vs BASE; test/utils change = guard spec, harness, pg-harness, worker; FREEZE-v3 (e6e3a15a…) 4 untouched A1 lines
byte-equal; FREEZE-s11c (2d58f9d1…) 7/7; FREEZE-s11b v2 (603ffa02…) 6/6; the other 17 blob pins (guard 3975aab1, pg-harness ad32b569,
worker 562038a1, induction 1b9832bc, ...); migrations tree 7b6fe0ed; guard spec unchanged since r1 (11 `it` → 95); induction spec unchanged.
`G2_S11_CANDIDATE_HEAD=$EXPECT_HEAD` = 54be96f1.

## Expected counts (unchanged)
bootstrap -> identity -> rls **6** -> journey **8** -> readiness **6** -> settle-redrive **8** -> induction **4** -> guard **95** -> teardown
-> post. Total 127 tests / 6 suites.

## Timeouts (unchanged)
Inner stage bounds sum to 12930 s (redrive 3000, induction 3000). Outer bound is **13500** (runner Usage line and launcher).

## Lane
`clusters/s11` absent (v1 leftovers archived to v1/run/post-teardown and removed, per the finding). `run/s11` empty. Port 55648.
The stopped clusters s10d2, s10d2-v2 and s11b-s10b have no postmaster.pid, so they are fingerprinted and do not block.
`pgrep -cx postgres` = 0 at build time.

## Findings (Safety ROI)
No A findings.
- **B — shared SRC and land ref.** CLASS: launch precondition. CONCRETE HARM: any move of fa72-s11a2 (HEAD/branch/clean) or of
  `origin/land/s11a2` away from 54be96f1 before launch gives PRECONDITION_FAIL rc 70 (not consumed); after the clone it gives POST rc 74
  (consumed). Note that the land ref read 03e7a234 at the start of this build and 54be96f1 at the end. DECISION BLOCKED: launch.
  MINIMUM CLOSURE: freeze both until the run ends. EXECUTION UNLOCKED: the v2 run.
- **B — launch conditions (inherited).** Launch with the 13500 outer bound and only when `pgrep -cx postgres` = 0. Otherwise the
  preflight fails with rc 71 after STARTED.
- C — the r2 fix is proven only by the live run. No-DB gates cannot see the S10-B insert-only trigger (v1 finding).
- C — inherited from v1: the J11 `blocked()` window is 10 s; `sort` is locale-dependent (only C locales are installed); hook time beyond
  600 s in the induction stage is not covered; `clusters/s11` needs the archive-and-remove step after this run.
