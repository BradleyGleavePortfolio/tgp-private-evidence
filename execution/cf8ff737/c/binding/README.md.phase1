# C/contract PG binding — substitution-only PHASE 1 draft (NOT RUN, NOT GRANTED, pins UNFILLED)

Source-only work under `execution/cf8ff737/c/**` (C_BUILD_GRANT phase 1). Nothing here has been executed against
PostgreSQL; no PostgreSQL process, lock, cluster directory, or worktree state was touched by drafting (the derivation
script and `bash -n` were the only things run). Pins are filled only AFTER the hooked Bradley commit exists; the runner is
executed only under a SEPARATE single-run PG grant.

| file | derived from | sha256 (draft, pins unfilled) |
|---|---|---|
| `c-fixture.sh` (95 lines) | N/Q1 `nq1/binding/nq1-fixture.sh` (29db46ad…) by substitution | `cf342f4b21306c677d668343fa46e4ad1c2a9a4104546a445b0d36bf3bf259b3` |
| `c-pg-proof.sh` (214 lines) | N/Q1 `nq1/binding/nq1-pg-proof.sh` (filled form e47c9ac1…) by substitution + added read-only checks | `c84ffb12187f6a99b67a3d6cfcb7c977dfe7481670ad5fe436351e08dbdb04d4` |
| `derive-c-pg-proof.py` | the exact substitution script that produces BOTH files (asserted match counts; re-run reproduces byte-identically) | `4476ec0e48625d94c0d847c1522d9267f6cb4f65a7100a22b5a446fd9c37500a` |
| `c-pg-proof.sh.diff-vs-nq1` | `diff` N/Q1 runner → C runner (219 lines, whole-line) | — |

## Substitutions (identity only)
- lane dir `clusters/nq1` → `clusters/c-contract` (`CDIR`); socket `run/nq1` → `run/c-contract`; `C1DIR`, `BDIR`, `RDIR`, `NDIR`
  all kept as retained stopped clusters (hashed, never started).
- port 55481 → 55491; `nq1_super`/`nq1_local_synthetic` → `c_super`/`c_local_synthetic`; DB `g2_nq1_disposable` →
  `g2_c_disposable`; CONFIRM `g2_c_disposable:55491`.
- markers `nq1-disposable-pg17` → `c-disposable-pg17`; DB comment → `c-g2-contract-synthetic-disposable-fixture-safe-to-drop`.
- env prefix `G2_NQ1_*` → `G2_C_*` (DATABASE_URL, CONFIRM, PASSWORD, PSQL, DATA_DIRECTORY, SERVER_VERSION, OLD_ROOT,
  OLD_CLIENT; bootstrap marker `G2_C_BOOTSTRAP_OK`; old-client dir `.g2-c-old-client`). No `G2_PG17_*`/`G2_B_*`/`G2_R_*`/
  `G2_NQ1_*` exported.
- `NQ1_RUNNER_PID/NQ1_STOP_TIMEOUT/NQ1_FIXTURE_*` → `C_*`; spec `test/rls-g2-c-contract.spec.ts`; bootstrap
  `test/utils/g2-c-bootstrap.sh`; old-root helper `test/utils/g2-c-old-root.sh` (NOT drafted in phase 1 — see open question 8).
- roots: `D=execution/cf8ff737/c/binding`, `RT=execution/cf8ff737/c/runtime` (run/, old-root/), `W=worktrees/s7-c`.
- `EXPECT_NM_CLIENT_SHA` = `__FILL_AFTER_GENERATE__` (C generated client, narrow `@@unique` removed; receipt 03);
  `EXPECT_NM_LOCK_SHA` unchanged `05bc530a…` (receipt 02).

## Structural change vs N/Q1 (the OLD side moves from R to N/Q1)
- New pin `NQ1_HEAD=__NQ1_ACCEPTED_HEAD__`: the accepted N/Q1 head is the OLD side (N writer + Q1 readers). The committed
  N/Q1 candidate is 61b93cff7900b24c17011d481fd6c31f5abb59e4 (tree 7adad696…), read from `s7-nq1` HEAD; it is NOT filled
  until the parent records N/Q1 acceptance. The runner refuses the placeholder (rc 70) together with the other pins.
- Step 4 old root: `test/utils/g2-c-old-root.sh create` (derive from the committed `g2-nq1-old-root.sh` 4569f5fe… by
  substituting OLD_HEAD=NQ1_HEAD, markers `G2_C_OLD_ROOT_OK`, env `G2_C_OLD_ROOT`); runner checks `rev-parse HEAD` == `$NQ1_HEAD`.
- Step 5 bootstrap installs the whole accepted history (169) through the OLD root's `prisma migrate deploy`; C is NOT
  applied by the bootstrap. The spec applies C through the candidate's `prisma migrate deploy` (C01) — the release mechanism.
- Preconditions (added): seven accepted N/Q1 objects blob-identical at the C head (`g2-nq1-{db,pg-harness,harness}.ts`,
  `g2-nq1-bootstrap.sh`, `g2-nq1-old-root.sh`, `g2-nq1-db-guard.spec.ts`, `rls-g2-nq1.spec.ts`, blobs recorded from
  61b93cff); `$NQ1_HEAD` is an ancestor; `git diff --name-only $NQ1_HEAD HEAD -- prisma/migrations` is EXACTLY
  `…/20270121000000_scout_identity_contract/{down.sql,migration.sql}` (no verify.sql). The R-migration-tree `--quiet`
  check is replaced by that exact-two-files check; the accepted S5/B/R blob pins and the B/R ancestor checks are retained.
- Preflight/post: the retained stopped N/Q1 cluster (`clusters/nq1/pg-data`) hashed (postgresql.conf, pg_control), no
  postmaster.pid, unchanged at end — never started. Mirrors the C1/B/R handling.
- Header pre-steps add the chain-harness CI dry-run (PG 15.18 empty DB: deploy → down via psql → re-apply migration.sql →
  byte diff) before the commit, per the brief.

## Pins to fill after the commit (placeholders; script refuses them, rc 70)
`NQ1_HEAD` (on N/Q1 acceptance), `EXPECT_HEAD`, `EXPECT_TREE`, `EXPECT_SPEC_BLOB` (HEAD:test/rls-g2-c-contract.spec.ts),
`EXPECT_BOOTSTRAP_BLOB` (HEAD:test/utils/g2-c-bootstrap.sh), `EXPECT_FIXTURE_SHA` (sha256 of `c-fixture.sh`),
`EXPECT_NM_CLIENT_SHA` (after the C-only generate). Then write `PINS.txt` + refresh `BINDING.sha256`; the parent dispatches
attestations and the single-run PG grant.

## Observed lane state at drafting time
Not observed: phase 1 forbids touching the clusters; `/home/user/pg17/clusters/` was not listed. The runner's own preflight
records C1/B/R/N/Q1 presence as-is and refuses a pre-existing `clusters/c-contract`.
