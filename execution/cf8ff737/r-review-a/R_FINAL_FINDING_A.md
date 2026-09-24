# R_FINAL_FINDING_A — independent T4 reviewer A, final finding on the single real-PG proof run

## Verdict: **ACCEPT** (local disposable PG17 synthetic proof of the R slice at head `7d2895e1`)

Bound from raw receipts only (`r-ready/runtime/run/*`, `runtime/LAUNCH.txt`, `runtime/outer.stdout`, live lane state). The builder's `R_PG_PROOF_RESULT.md` did not exist when this was written and was not consulted. Reviewer B's directory never read. Read-only throughout; no PG, no tsc/Jest, no lock. Written 2026-09-24 ~16:58Z. Route requested Claude Fable 5 / High — no telemetry, not claimed.

## 1. Run identity
| Item | Raw source | Value |
|---|---|---|
| Grant | `R_SINGLE_PG_PROOF_GRANT.md` (17:00Z per its header; file mtime 16:48Z) | head 7d2895e1, tree 95cdfadc, spec 0ae7b764, binding 787d34b0, fixture 6e71d754 |
| Launch | `runtime/LAUNCH.txt` | `LAUNCH 2026-09-24T16:49:06Z cmd='timeout -k 30 3600 bash …/binding/r-pg-proof.sh' binding_sha=787d34b0…` |
| Binding executed | `sha256sum binding/r-pg-proof.sh` now | 787d34b08f7abcbc18fa077eed29b15167fc762983f47fe58e3de6beb89b3cc2 (= grant, = my R_REATTEST_A GO) |
| START | `run/r-pg-proof.log` | `START 2026-09-24T16:49:06Z pid=1004 head_expect=7d2895e1… fixture_expect=6e71d754… node=v20.20.1` |
| Sentinel | `run/r-pg-proof.sentinel` | `RC=0 STAGE=done END=2026-09-24T16:54:09Z HEAD=7d2895e1fe03ea82353e8ce0b07aacaf66af74c8` |
| Outer | `runtime/LAUNCH.txt` | `OUTER_RC=0 2026-09-24T16:54:09Z` |
| Once-only | sentinel exists → any rerun refused rc 76 | ✔ single run; wall time 5 min 03 s |

## 2. Stage evidence (r-pg-proof.log, verbatim markers)
- `PRECONDITIONS_OK 16:49:10Z server='postgres (PostgreSQL) 17.6' … jest=30.4.1 pg17_provenance='postgres_sha256=23cd1748…'` — all pins (head/tree/spec/bootstrap blobs, fixture sha, S5+B donor blobs, B and O ancestry, isolated node_modules lock 05bc530a / client 7c367454, PG binaries, lefthook hooks via `--git-path hooks`) passed.
- `PREFLIGHT s5_cluster=ABSENT`, `c1_cluster=ABSENT`, `b_cluster=PRESENT_STOPPED conf=173acaa2… pg_control=9b99d606…`, `PREFLIGHT_OK 16:49:11Z rdir=absent port55471=free postgres_procs=0 worktree_porcelain_sha=e3b0c442…` (sha of empty = clean).
- `R_FIXTURE_INIT_OK data=/home/user/pg17/clusters/r-ready/pg-data port=55471 superuser=r_super cluster_name=r-disposable-pg17 pg_version=17`; `FIXTURE_INIT rc=0`; `R_FIXTURE_START_OK pid=3050`; `FIXTURE_START rc=0 16:49:20Z`.
- `OLD_ROOT rc=0 16:49:23Z head=925780e0…` / `old_root=…/runtime/old-root head=925780e0… detached=yes migrations=164 alternates=none`.
- `BOOTSTRAP rc=0 16:50:02Z`, `G2_R_BOOTSTRAP_OK` ("All migrations have been successfully applied" for the 164 O migrations; O client generated in old-root).
- `IDENTITY_OK 16:50:03Z data_directory=/home/user/pg17/clusters/r-ready/pg-data server_version_num=170006 cluster_name=r-disposable-pg17` (B-2 closure confirmed live).
- `JEST_START 16:50:03Z cmd='./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-r-ready.spec.ts --runInBand --ci'` → `JEST_END rc=0 16:54:09Z`. No `GUARD_REFUSAL_OBSERVED_IN_JEST_LOG` line.
- `FIXTURE_STOP rc=0 16:54:09Z`, `R_FIXTURE_STOP_OK`, `STOP_STATE_OK postgres_procs=0 port55471=free datadir_retained=/home/user/pg17/clusters/r-ready/pg-data`.
- `POST s5_cluster=ABSENT unchanged`; `POST b_cluster unchanged conf=173acaa2… pg_control=9b99d606…`; worktree porcelain and HEAD unchanged (POST_FAIL absent); `POST_OK 16:54:09Z`; `END rc=0 stage=done`.

## 3. Jest results (run/jest.log, raw)
- `PASS rls-live test/rls-g2-r-ready.spec.ts (239.118 s)`; `Test Suites: 1 passed, 1 total`; `Tests: 17 passed, 17 total`; `Time: 241.159 s`.
- ✕ markers: 0. Skipped/todo tests: 0 (the 7 `skipped` hits are `"skipped":0` inside `PG17_PROCESS` worker JSON, i.e. 0 skipped reconstructions; the 7 `failed` hits are `"failed":0` likewise).
- R01–R12 each present as a passing test title, R11 twice (decoy + shadow search_path): R01 ✓ R02 ✓ R03 ✓ R04 ✓ R05 ✓ R06 ✓ R07 ✓ R08 ✓ R09 ✓ R10 ✓ R11 ✓✓ R12 ✓; plus 5 stage-scaffold tests (S1/C1/E+T, B+deploy-clean, T-after-down, re-up identical + rerun refused) — 17 total, matching the spec structure attested in Phase 1.
- Closure effects observed live: R05 / R11-shadow / stage-5 re-up rerun refusals passed with `/G2-R wide identity already present/` (B-1 closed); R11 decoy passed with the pinned `wide()` snapshot (reviewer B's B-2 closed).
- Catalog as installed (`PG17_WIDE` warn line): both CHECKs validated, `pg_get_constraintdef` = `CHECK (((source_platform COLLATE "C") ~ '^[a-z0-9][a-z0-9._:-]{0,255}$'::text))` on both tables — resolves my Phase 1 C-R6 as predicted.

## 4. Isolation and survivors (live lane, 16:56Z)
- `/home/user/pg17/clusters/` = `b-drain`, `b-drain.v4-failed-75a2863b-20260924T151250Z`, `r-ready` (new, 76 MB, retained, no `postmaster.pid`).
- `pgrep -cx postgres` = 0; port 55471 listeners = 0; no survivor pid reported by the fixture stop.
- Retained B cluster untouched: `postgresql.conf` 173acaa2… and `global/pg_control` 9b99d606… recomputed by me now == PREFLIGHT == POST; mtimes 15:37:51Z / 15:38:56Z (before the run); no `postmaster.pid`. `b-drain.v4-failed-*` mtimes 15:12:22Z / 15:14:50Z; never referenced by the binding.
- Worktree `s7-r-ready`: HEAD 7d2895e1, porcelain 0 lines after the run. No push (binding has none; no remote action in any receipt).
- `test-validation.lock`: released (flock -n succeeds).

## 5. Receipt integrity
- `run/RECEIPTS.sha256`: `jest.log` OK (0c92f238…). `r-pg-proof.log` recorded 54de0d6f… ≠ current f6802dc2… **by design**: the binding hashes the log at line 168 and then appends the `POST_OK` and `END rc=0` lines; `head -n -2 r-pg-proof.log | sha256sum` = 54de0d6f… exactly. Same construction as accepted B v5 (`b-pg-proof.sh` line 152). Recorded as C; final hashes are in `MANIFEST_A.sha256`.

## 6. Findings
- **A: none. B: none.**
- C-R12: RECEIPTS.sha256 log hash is pre-terminal by construction (above); manifest in this directory carries the terminal hashes.
- C-R13: grant header says 17:00Z while file mtime and LAUNCH are 16:48–16:49Z — clock/label drift in prose only; the bound identities match.
- C-R6 closed by observation (§3). C-R1–C-R5, C-R7–C-R11 stand as recorded; no new work.

## 7. Scope (honest)
This ACCEPT covers: the R slice at `7d2895e1` (migration up/down, wide identity, canonical CHECK, NOT NULL, DTO parity harness path via the spec's HTTP stages) proven once on a fresh local disposable PostgreSQL 17.6 cluster with synthetic data, against the accepted B v5 base 0d69c7ba, under the frozen binding 787d34b0. It does **not** cover: PG15 CI, any push or fast-forward to `integration/importer`, deploy, real drain, customer data, or production ordering of R.down vs N writers (C-R2 runbook note). The unchanged bytes from Phase 1 were accepted by attestation, not re-run.

## 8. Files in r-review-a/
`R_ATTESTATION_A.md` (Phase 1, B-1/B-2/B-3), `R_REATTEST_A.md` (closure 1, GO), `R_FINAL_FINDING_A.md` (this), `MANIFEST_A.sha256`.
