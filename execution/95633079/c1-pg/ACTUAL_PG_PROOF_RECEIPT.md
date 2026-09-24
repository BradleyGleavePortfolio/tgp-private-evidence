# C1 real-PostgreSQL proof — compact frozen actual receipt (executor record, not an attestation)

Sole executor, session 95633079, heavy slot transferred by parent 06:27Z. Both grants executed exactly once under the parent's GO; no retry, no test/timeout/harness change, no suite expansion. Raw receipts govern; this file only indexes them.

## Grant 1 — pinned environment recovery (`c1-env-recovery.sh` `0db738a6f917b8e9b306f474b52fd7111f7a670e86e4816041f597267c06508f`)
Launched 06:27:38Z as `timeout -k 30 1500 bash …/c1-env-recovery.sh`, own single `flock -n` on the canonical lock; sentinel `RC=0 STAGE=done END=2026-09-24T06:29:19Z`. Flock released at exit; 0 lock holders observed before grant 2.

| Recovered input | Observed (all == recorded) |
|---|---|
| Client | `postgresql-client-18 18.6-0ubuntu0.26.04.1` → `/usr/bin/psql` 18.6, sha256 `a200e38c89b111d3abdf26927b186fdd423bef3d84f157af0f4b65db6f8e6c94` (recorded prefix `a200e38c89b111d3`) |
| Maven SHA1 | `8163322358dbe4e6c2abccc90f2e543f8cfc65db` == pinned |
| jar / txz sha256 | `23da5a04…1d29d` (14 894 072 B) / `26fa6334…067c0` (14 889 140 B) == S1-recorded |
| `dist/bin/postgres` / `initdb` | `23cd1748…873a` / `b7db9bc2…882a` == S1-recorded; `postgres --version` = 17.6 |
| `dist/bin/pg_ctl` | `af53d826845af4679a0aaba2bda319f5e527f3b94f3794c67fa174049c9b9401` (recorded 16-char prefix matches) |
| `/home/user/pg17/PROVENANCE.txt` | written, `result=success`, sha256 `aba2a25a…`; `/home/user/pg17` real path |
| Not touched | worktrees, node_modules, any cluster; `clusters/` dir absent after recovery; 0 postgres |

## Grant 2 — the one proof run (`c1-pg-proof.sh` `505061752aa09d4b6cfbd60bbc45835ee3613932dbcca1816130bed975c4eef2`, fixture `27b816af…`)
Launched 06:29:57Z as `timeout -k 30 900 bash …/c1-pg-proof.sh` (pid 21910); v1 packet manifest verified immediately before launch. Sentinel: **`RC=0 STAGE=done END=2026-09-24T06:30:27Z HEAD=a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992`**. Wall 30 s.

| Stage | Raw status |
|---|---|
| Preconditions | OK 06:29:57Z — fixture/HEAD/tree/spec-blob/clean/MERGE_HEAD/jest/ts-node/ImportIntent/PG hashes/17.6/psql/realpath all matched |
| Preflight | OK — `c1-builder` absent, port 55439 free, 0 postgres, **`s5_cluster=ABSENT` recorded as-is (not reconstructed)**, porcelain sha `e3b0c442…` (empty) |
| Fixture init | rc 0 — `C1_FIXTURE_INIT_OK data=/home/user/pg17/clusters/c1-builder/pg-data port=55439 superuser=user cluster_name=c1-disposable-pg17 pg_version=17` |
| Fixture start | rc 0 — `C1_FIXTURE_START_OK pid=22075` |
| `CREATE DATABASE c1_setup_disposable` | rc 0 |
| Identity | `SHOW data_directory` = `/home/user/pg17/clusters/c1-builder/pg-data`; `server_version_num` = **170006** |
| Jest (exact command, no `--testTimeout`) | **rc 0 — `Test Suites: 1 passed, 1 total`; `Tests: 22 passed, 22 total`; Snapshots 0; Time 26.684 s; `PASS rls-live test/rls-c1-setup.spec.ts (26.431 s)`**; 0 skipped/todo/failed; 0 guard-refusal strings in `jest.log` |
| Fixture stop | rc 0 — `C1_FIXTURE_STOP_OK`; `STOP_STATE_OK postgres_procs=0 port55439=free datadir_retained` |
| Post | `s5_cluster=ABSENT unchanged`; worktree HEAD `a0ea1bea…` and porcelain unchanged (0); `POST_OK` |

Observed jest CLI banner `30.4.1` (`jest --version`) while `node_modules/jest/package.json` and `jest-cli/package.json` are `30.4.2` (the recorded pin); recorded as observed, no action.

## Raw terminal state after both grants (06:30:50Z, independent re-check)
`pgrep -cx postgres` = 0; port 55439 listeners = 0; `pg-data/postmaster.pid` absent; data dir `/home/user/pg17/clusters/c1-builder/pg-data` RETAINED (`cluster_name = 'c1-disposable-pg17'`, `port = 55439`, `listen_addresses = '127.0.0.1'`, pg_hba `trust` on local/127.0.0.1/::1 only); `clusters/s5` absent; no jest/node/pg_ctl/timeout/proof/fixture processes (an earlier "3 procs" reading was the checking shell matching its own `pgrep -f` pattern); canonical lock: **0 holders** — released by the binding at exit; this worker holds nothing. No autonomous-cleanup guarantee is claimed (C08); the above is the observed state.

## Receipts (raw, additive) — `execution/95633079/c1-pg/`
| File | sha256 |
|---|---|
| `run/c1-pg-proof.sentinel` | `431b4cfc9be277ee5258e21d73947664ed38e01b780265a955262dcadd10d763` |
| `run/c1-pg-proof.log` (23 lines, final) | `c0b13a6ea75c048d0f583ae48916aff15761b8225544a8c0b965c51841e298ed` |
| `run/jest.log` (31 lines) | `33b1695ec06e9edd998806fd220a917bc4e85b7fb0a911a361fe31323e522261` |
| `run/RECEIPTS.sha256` | pre-final snapshot per C07: proof.log `96fe471e…` (before `POST_OK`/`END` appended) — expected mismatch, not a failure; jest.log digest identical |
| `run/LAUNCH.txt` / `run/launcher.out` | `292da629…` / empty |
| `env/c1-env-recovery.sentinel` / `.log` / `LAUNCH.txt` | `9131413d…` / `5d90930a…` / `d070b017…` |

## Scope of what this run shows and does not show
Shows: the existing 22-case `test/rls-c1-setup.spec.ts` (blob `cc3b0e4d`) at committed head `a0ea1bea…` passes once against a fresh, pinned, disposable PostgreSQL 17.6 cluster with the frozen §5 sequence and §6 acceptance as written. Does not show or claim: E/T-Q0, S1–S3 suites, the 190-test targeted lane (already sealed, not repeated), migration drift on a full history, production readiness, or any remote/deploy state. No product source, test, fixture, or binding changed during either grant. Original `13-C1_ACTUAL_RESULTS_SEAL.md` untouched.
