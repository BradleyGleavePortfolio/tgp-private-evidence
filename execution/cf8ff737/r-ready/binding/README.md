# R/ready PG binding — substitution-only draft (NOT RUN, NOT GRANTED, pins UNFILLED)

Drafted while waiting for the parent heavy-slot relay (source-only work; grant permits writes under
`execution/cf8ff737/r-ready/**`). Nothing here has been executed; no PostgreSQL process, lock, or
worktree state was touched. Pins are filled only AFTER the hooked Bradley commit exists.

| file | derived from | sha256 (draft) |
|---|---|---|
| `r-fixture.sh` (95 lines) | accepted B v5 `fixture-proposal-v3/binding/b-fixture.sh` (4525f01d…) by substitution | `6e71d7540aaf5703b7133e9081bd0146c831f9daa8178de5345983692c8b35f3` |
| `r-pg-proof.sh` (169 lines) | accepted B v5 `runtime-v5/binding/b-pg-proof.sh` (e895b16e…) by substitution + 2 read-only checks | `eba6eb0f0375619b2730501cd69caae99449270d81f488501bc090356f9626f4` (pins unfilled) |
| `derive-r-pg-proof.py` | the exact substitution script that produced `r-pg-proof.sh` (reproducible) | — |
| `r-pg-proof.sh.diff-vs-b-v5` | `diff` B v5 runner → R runner (192 lines, whole-line diff) | — |

## Substitutions (identity only)
- lane dir `clusters/b-drain` → `clusters/r-ready`; socket `run/b-drain` → `run/r-ready`; `BDIR` kept (B cluster, read-only) and `RDIR` added.
- port 55461 → 55471; `b_super`/`b_local_synthetic` → `r_super`/`r_local_synthetic`; DB `g2_b_drain_disposable` → `g2_r_ready_disposable`; CONFIRM `g2_r_ready_disposable:55471`.
- markers `b-disposable-pg17` → `r-disposable-pg17`; DB comment `b-g2-drain-…` → `r-g2-ready-synthetic-disposable-fixture-safe-to-drop`.
- env prefix `G2_B_*` → `G2_R_*` (matches the authored harness/bootstrap/guard exactly: DATABASE_URL, CONFIRM, PASSWORD, PSQL, DATA_DIRECTORY, SERVER_VERSION, OLD_ROOT, OLD_CLIENT; bootstrap marker `G2_R_BOOTSTRAP_OK`).
- `B_RUNNER_PID/B_STOP_TIMEOUT/B_FIXTURE_*` → `R_*`; spec `test/rls-g2-r-ready.spec.ts`; bootstrap `test/utils/g2-r-ready-bootstrap.sh`.
- roots: `D=execution/cf8ff737/r-ready/binding`, `RT=execution/cf8ff737/r-ready/runtime` (run/, old-root/ — a NEW detached O checkout at 925780e0; B's old-root is never reused because its node_modules link points into B's tree).
- `EXPECT_NM_CLIENT_SHA` = R generated client `7c367454…` (receipt 03); `EXPECT_NM_LOCK_SHA` unchanged `05bc530a…` (receipt 02).

## Added read-only checks (beyond B v5)
1. Preconditions: the six accepted B files are blob-identical at the R head (pins from HEAD 0d69c7ba) and 0d69c7ba is an ancestor.
2. Preflight/post: the retained stopped B cluster (`clusters/b-drain/pg-data`) is hashed (postgresql.conf, pg_control), must have no postmaster.pid, and must be unchanged at the end — never started. Mirrors the existing C1 handling.

## Pins to fill after the commit (5 placeholders `__FILL_AFTER_COMMIT__`; script refuses them, rc 70)
`EXPECT_HEAD`, `EXPECT_TREE`, `EXPECT_SPEC_BLOB` (HEAD:test/rls-g2-r-ready.spec.ts), `EXPECT_BOOTSTRAP_BLOB` (HEAD:test/utils/g2-r-ready-bootstrap.sh), `EXPECT_FIXTURE_SHA` (sha256 of `r-fixture.sh`). Then write `PINS.txt` + `BINDING.sha256` and request the single-run grant.

## Observed lane state at drafting time (read-only)
`/home/user/pg17/clusters/`: `b-drain` (stopped, no postmaster.pid), `b-drain.v4-failed-75a2863b-20260924T151250Z`; no `r-ready`, no `s5`; `pgrep -cx postgres` = 0.
