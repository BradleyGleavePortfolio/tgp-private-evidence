# N/Q1 PG binding — substitution-only draft (NOT RUN, NOT GRANTED, pins UNFILLED)

Source-only work under `execution/cf8ff737/nq1/**` (NQ1_BUILD_GRANT). Nothing here has been executed; no
PostgreSQL process, lock, cluster directory, or worktree state was touched by drafting. Pins are filled only
AFTER the hooked Bradley commit exists; the runner is executed only under a SEPARATE single-run PG grant.

| file | derived from | sha256 (draft, pins unfilled) |
|---|---|---|
| `nq1-fixture.sh` (95 lines) | accepted R `r-ready/binding/r-fixture.sh` (6e71d754…) by substitution | `29db46ad3189ca12bd507e79cd2f2b87c3c375aeb454f6db76973bb467ad4bc3` |
| `nq1-pg-proof.sh` (191 lines) | accepted R `r-ready/binding/r-pg-proof.sh` (787d34b0…) by substitution + read-only checks | `e14db001371424385fc558a824a0b654686851480a9d8cd3aae6b3c970d1cd32` |
| `derive-nq1-pg-proof.py` | the exact substitution script that produces BOTH files (asserted single-match; re-run reproduces byte-identically) | `416247925aa4c343d91544b1745d77e266b50c78ff73b55911fc9094c38bfb9e` |
| `nq1-pg-proof.sh.diff-vs-r` | `diff` R runner → N/Q1 runner (204 lines, whole-line) | — |

## Substitutions (identity only)
- lane dir `clusters/r-ready` → `clusters/nq1` (`NDIR`); socket `run/r-ready` → `run/nq1`; `C1DIR`, `BDIR`, `RDIR` all kept as retained stopped clusters (hashed, never started).
- port 55471 → 55481; `r_super`/`r_local_synthetic` → `nq1_super`/`nq1_local_synthetic`; DB `g2_r_ready_disposable` → `g2_nq1_disposable`; CONFIRM `g2_nq1_disposable:55481`.
- markers `r-disposable-pg17` → `nq1-disposable-pg17`; DB comment → `nq1-g2-synthetic-disposable-fixture-safe-to-drop`.
- env prefix `G2_R_*` → `G2_NQ1_*` (DATABASE_URL, CONFIRM, PASSWORD, PSQL, DATA_DIRECTORY, SERVER_VERSION, OLD_ROOT, OLD_CLIENT; bootstrap marker `G2_NQ1_BOOTSTRAP_OK`; old-client dir `.g2-nq1-old-client`). No `G2_PG17_*`/`G2_B_*`/`G2_R_*` exported.
- `R_RUNNER_PID/R_STOP_TIMEOUT/R_FIXTURE_*` → `NQ1_*`; spec `test/rls-g2-nq1.spec.ts`; bootstrap `test/utils/g2-nq1-bootstrap.sh`.
- roots: `D=execution/cf8ff737/nq1/binding`, `RT=execution/cf8ff737/nq1/runtime` (run/, old-root/).
- `EXPECT_NM_CLIENT_SHA` = N generated client `92d42c56…` (receipt 03); `EXPECT_NM_LOCK_SHA` unchanged `05bc530a…` (receipt 02).

## Structural change vs R (the T-root design; recorded as a C qualification in receipt 04)
- Step 4 old root: R used the unchanged S5 helper `g2-pg17-old-root.sh` (hard-pinned to O 925780e0, 164 migrations, ledger WITHOUT
  source_platform). N/Q1's old side is T = the accepted R head 7d2895e1 (169 migrations, ledger `source_platform String?`), so the
  runner calls the derived, committed helper `test/utils/g2-nq1-old-root.sh create` (same clone + detached-checkout recipe, inverted
  identity gate: MUST contain E and R, count 169, candidate `prisma/migrations` byte-identical to the R head). Runner verifies the
  `G2_NQ1_OLD_ROOT_OK` marker and `rev-parse HEAD` == 7d2895e1 after the helper.
- Step 5 bootstrap installs the whole accepted history through the T root's own `prisma migrate deploy` (169 applied) rather than
  file-by-file; N/Q1 ships no migration so T-deploy and candidate-deploy are the same set (N01 asserts candidate deploy = "No pending migrations").

## Added read-only checks (beyond R)
1. Preconditions: eight accepted R objects blob-identical at the N/Q1 head (`g2-r-ready-{db,pg-harness,harness}.ts`,
   `g2-r-ready-bootstrap.sh`, `g2-r-ready-db-guard.spec.ts`, `rls-g2-r-ready.spec.ts`, `g2-tq0-worker.cjs`, migration dir
   `20270120000000_scout_identity_ready`), 7d2895e1 is an ancestor, and `git diff --quiet 7d2895e1 HEAD -- prisma/migrations`.
   The O-ancestor check (925780e0) is dropped because the O helper is no longer called (7d2895e1 ancestry implies it).
2. Preflight/post: the retained stopped R cluster (`clusters/r-ready/pg-data`) hashed (postgresql.conf, pg_control), no
   postmaster.pid, unchanged at end — never started. Mirrors the existing C1/B handling.

## Pins to fill after the commit (5 placeholders `__FILL_AFTER_COMMIT__`; script refuses them, rc 70)
`EXPECT_HEAD`, `EXPECT_TREE`, `EXPECT_SPEC_BLOB` (HEAD:test/rls-g2-nq1.spec.ts), `EXPECT_BOOTSTRAP_BLOB`
(HEAD:test/utils/g2-nq1-bootstrap.sh), `EXPECT_FIXTURE_SHA` (sha256 of `nq1-fixture.sh`). Then write `PINS.txt` +
refresh `BINDING.sha256`; the parent dispatches attestations and the single-run PG grant.

## Observed lane state at drafting time (read-only)
`/home/user/pg17/clusters/`: `b-drain`, `b-drain.v4-failed-75a2863b-20260924T151250Z`, `r-ready` (all stopped by
observation; none touched); no `nq1`, no `s5`, no `c1-builder`.

## Filled (after commit 61b93cff7900b24c17011d481fd6c31f5abb59e4, 2026-09-24T18:24:33Z)
Pins filled from the committed head (see PINS.txt): HEAD 61b93cff…, TREE 7adad696…, SPEC 8ad3af3f…, BOOTSTRAP 96b7668d…,
FIXTURE 29db46ad…. Header line 2 updated to say FILLED. `nq1-pg-proof.sh` filled sha256 = `e47c9ac1bd073e2b92432bf1a4809bd2d30e4c63c61aec33fa0ccc339746a190`.
`derive-nq1-pg-proof.py` still reproduces the substitution-only form (e14db001…); the fill is the five sed
substitutions plus the header word change and is fully described by PINS.txt. Still NOT RUN and NOT GRANTED.

## v2r refill (after the amended single commit 29e60705d8c4e1228fd1d2f248c7e53b6b8e56dd, 2026-09-24T20:3xZ; NQ1_V2R_REBUILD_GRANT)
Pins refilled from the v2r head: HEAD 29e60705…, TREE 511710ee…, SPEC a9338260…; BOOTSTRAP 96b7668d… and FIXTURE 29db46ad… unchanged.
Header line 2 names the v2r head. `nq1-pg-proof.sh` v2r sha256 = `aec602521f377a2b825026b1437fa57439794236321cb617129c48dc7e134756`;
the v1 filled runner is kept byte-exact as `nq1-pg-proof.sh.v1-61b93cff` (e47c9ac1…) with `BINDING.sha256.v1-61b93cff`.
Runner delta vs v1: the three EXPECT_ lines + the header word only. Donor clusters (s5, c1-builder, b-drain, r-ready) are ABSENT after the
sandbox loss; the runner's preflight already records ABSENT itself (else-branches) and requires only S5 absence, so no mechanical
"ABSENT" edit was needed. An intermediate fill for 3f2d7a77 (superseded before attestation; see PINS.txt) is recorded, not hidden.
Lane flags for the next PG grant (v1 leftovers, untouched): `runtime/run/nq1-pg-proof.sentinel` exists → runner refuses rc 76 until the
parent grants the preserving rename of the v1 `runtime/` (alongside the planned `clusters/nq1` rename, which is now moot: no cluster exists).
Still NOT RUN and NOT GRANTED.
