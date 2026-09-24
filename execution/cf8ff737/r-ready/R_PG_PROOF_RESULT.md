# R identity-ready — single real-PG proof RESULT

T4 R builder → parent (cf8ff737), under `R_SINGLE_PG_PROOF_GRANT.md` (17:00Z). Run exactly once; no retry; no push.
Fable/High requested for this builder; no telemetry claimed.

## Result: **rc 0 — PASS, 17/17 tests, all stages OK**

| Item | Value |
|---|---|
| Command | `timeout -k 30 3600 bash execution/cf8ff737/r-ready/binding/r-pg-proof.sh` |
| Binding sha at launch | `787d34b08f7abcbc18fa077eed29b15167fc762983f47fe58e3de6beb89b3cc2` (= grant) |
| Head verified by binding | `7d2895e1fe03ea82353e8ce0b07aacaf66af74c8`; tree `95cdfadc…`; spec blob `0ae7b764…`; bootstrap `67b77f7a…`; fixture `6e71d754…` |
| START / END | 2026-09-24T16:49:06Z → 16:54:09Z (303 s wall) |
| Sentinel | `runtime/run/r-pg-proof.sentinel`: `RC=0 STAGE=done END=2026-09-24T16:54:09Z HEAD=7d2895e1…` |
| Outer `timeout` rc | 0 (`runtime/LAUNCH.txt`) |
| Jest | `jest --config jest.rls.config.js test/rls-g2-r-ready.spec.ts --runInBand --ci` → **PASS rls-live, 1 suite, 17 passed / 17, 241.2 s**; no `--forceExit/--detectOpenHandles/--testTimeout` |
| Heavy slot | taken by the binding's own `flock -n`; released at process exit; **verified free 16:57:10Z** |

## Stage receipts (from `runtime/run/r-pg-proof.log`)
- PRECONDITIONS_OK 16:49:10Z — server `postgres (PostgreSQL) 17.6`, psql client 18.6 (same as accepted B v5, C), jest 30.4.1, PG17 provenance sha `23cd1748…` result=success; hooks check via `git rev-parse --git-path hooks` passed; B files/S5 files blob-identical; node_modules isolated; client `7c367454…`.
- PREFLIGHT_OK 16:49:11Z — s5 ABSENT, c1 ABSENT, **b_cluster PRESENT_STOPPED** conf `173acaa2…6a56` pg_control `9b99d606…2158`; rdir absent; port 55471 free; postgres procs 0; worktree porcelain sha = empty-string sha (clean).
- FIXTURE_INIT rc 0 16:49:20Z (`R_FIXTURE_INIT_OK data=/home/user/pg17/clusters/r-ready/pg-data port=55471 superuser=r_super cluster_name=r-disposable-pg17 pg_version=17`)
- FIXTURE_START rc 0 16:49:20Z (pid 3050)
- OLD_ROOT rc 0 16:49:23Z — new detached checkout at `runtime/old-root`, head 925780e0, 164 migrations, alternates none
- BOOTSTRAP rc 0 16:50:02Z — `G2_R_BOOTSTRAP_OK`; identity JSON `{database g2_r_ready_disposable, version 170006, directory /home/user/pg17/clusters/r-ready/pg-data, port 55471, applied 164}`; O client generated inside old root (engine `a2924eab…`), candidate client only VERIFIED
- IDENTITY_OK 16:50:03Z — data_directory `/home/user/pg17/clusters/r-ready/pg-data`, server_version_num 170006, cluster_name r-disposable-pg17
- JEST_START 16:50:03Z → JEST_END rc 0 16:54:09Z
- FIXTURE_STOP rc 0 16:54:09Z; STOP_STATE_OK postgres_procs=0 port55471=free, data dir RETAINED (76 MB)
- POST: s5 ABSENT unchanged; **b_cluster unchanged** conf `173acaa2…6a56` pg_control `9b99d606…2158`, no postmaster.pid; worktree porcelain and HEAD unchanged; POST_OK; END rc=0 stage=done

## R01–R12 mapping (all ✓, durations from jest.log)
S1/C1/E by file + T writes (40.5 s) · R04 fence-absent refusal (3.1 s) · B by file, nothing pending before R (12.2 s) · R02 NULL refusal then T reclaims (16.0 s) · R03 noncanonical ledger/staging refusals, atomic (10.8 s) · **R11 decoy** relation/constraint refusal, decoy untouched (7.5 s) · R10 lock_timeout 55P03, nothing applied, release → free (8.0 s) · R01 `prisma migrate deploy` applies exactly R; narrow keys, fence, RLS, policies untouched (6.6 s) · R05 raw rerun refused atomically, OIDs/rows/history unchanged, nothing pending (2.7 s) · R11 shadow search_path still refused (0.3 s) · R06 T on R with provenance, replay identical (2.8 s) · R07 narrow keys still arbitrate (0.5 s) · R08 CHECK/NOT NULL refusals for owner+runtime role, API roles by policy (1.3 s) · R09 O binary fails closed 500, no row, T reconstructs (4.6 s) · R12 down keeps rows/values/narrow/fence/column/history, wide+checks+NOT NULL gone (2.4 s) · T continues on E+B after down (1.9 s) · re-up identical shape, raw rerun refused again (0.4 s).

Installed R shape observed (`PG17_WIDE` in jest.log): CHECKs `ScoutIngestEntity_source_platform_canonical` / `ScoutReconstructionLedger_source_platform_canonical` = `CHECK (((source_platform COLLATE "C") ~ '^[a-z0-9][a-z0-9._:-]{0,255}$'::text))`, validated; unique indexes `ScoutIngestEntity_identity_key` / `ScoutReconstructionLedger_identity_key` on `(coach_id, intent_id, entity_type, source_platform, source_id)`; `ledgerNotNull: true`.

## Receipt hashes
- `runtime/run/RECEIPTS.sha256` (written by the binding): `r-pg-proof.log 54de0d6f…`, `jest.log 0c92f238…`.
  Note (C, same as accepted B v5): the binding hashes the log before appending its own final `POST_OK`/`END` lines, so `sha256sum -c` reports the log as changed by exactly those two lines; jest.log verifies OK.
- `runtime/run/RECEIPTS.final.sha256` (builder, after END): `r-pg-proof.log f6802dc267850ec0608e37d2f2d5fb0ecdc1bc5ef67d0443fefda4add35f09a5` (539 lines), `jest.log 0c92f238defb0d873f71edfca3aaaf621645cfd90ca3d453bdad3c7df23bc159` (180 lines).
- `runtime/LAUNCH.txt` (launch time, command, binding sha, OUTER_RC=0), `runtime/outer.stdout`.

## Lane state after the run (read-only, 16:57Z)
- postgres processes 0; port 55471 listeners 0; heavy slot free.
- `/home/user/pg17/clusters/`: `b-drain` (conf `173acaa2…`, pg_control `9b99d606…`, no pid — unchanged), `b-drain.v4-failed-75a2863b-20260924T151250Z` (conf `173acaa2…`, pg_control `d037d71b…`, no pid — matches reviewer B's 16:35Z baseline), `r-ready` (stopped, retained, 76 MB; destroy = separate marker-gated grant).
- Neither B cluster was started or written; only hashed.
- Worktree `s7-r-ready` at `7d2895e1…`, clean. Disk 3.5 GiB free.

## Scope statement
Local disposable PG17 synthetic lane only. Not PG15 CI, not a deployment, not a real-database drain, not customer acceptance. This is a run result on the bound head/binding; acceptance is the reviewers'/parent's decision.
