# R identity-ready — independent T4 reviewer B, FINAL FINDING

Reviewer B, EXEC-CF8FF737, 2026-09-24 ~17:00Z. Bound from raw receipts under `execution/cf8ff737/r-ready/runtime/` (not from the builder's `R_PG_PROOF_RESULT.md`, which I read afterwards only to cross-check). Read-only throughout; no tsc/Jest/PG/install/push; never read `r-review-a/`. Requested route Claude Fable 5 / High only; no model/effort telemetry claimed. Two momentary nonblocking `flock -n … true` probes disclosed in the attestation files; no effect on any lane.

## Verdict: ACCEPT (scope: local disposable PG17 synthetic fixture only)

No A. No open B. Both Phase 1 B findings (B-1 binding data-directory pin; B-2 R11 decoy assertion) were closed in closure 1 and their closure is demonstrated by the run itself (IDENTITY_OK on `…/r-ready/pg-data`; R11 decoy test ✓ with no cascade into R01).

## 1. What was proven (bound from raw receipts)

| Item | Raw receipt value | Source |
|---|---|---|
| Launch | `LAUNCH 2026-09-24T16:49:06Z cmd='timeout -k 30 3600 bash execution/cf8ff737/r-ready/binding/r-pg-proof.sh' binding_sha=787d34b0…3cc2`; `OUTER_RC=0 16:54:09Z` | `runtime/LAUNCH.txt` |
| Grant precedes launch | grant file mtime 16:48:50Z; my GO 16:39:01Z; launch 16:49:06Z | fs mtimes |
| Binding sha at launch | `787d34b08f7abcbc18fa077eed29b15167fc762983f47fe58e3de6beb89b3cc2` = grant = my re-attestation; recomputed now, unchanged | `sha256sum binding/r-pg-proof.sh` |
| Head verified by binding | `head_expect=7d2895e1…`; worktree HEAD now `7d2895e1fe03ea82353e8ce0b07aacaf66af74c8`, porcelain 0; POST worktree check passed | log line 1, `git rev-parse` |
| Preconditions | `PRECONDITIONS_OK 16:49:10Z` server `PostgreSQL 17.6`, jest 30.4.1, PG17 provenance `23cd1748…` success | log line 2 |
| Preflight | s5 ABSENT; c1 ABSENT; `b_cluster=PRESENT_STOPPED conf=173acaa2…6a56 pg_control=9b99d606…2158`; `rdir=absent port55471=free postgres_procs=0`; porcelain sha = empty-input sha (clean) | log lines 3–6 |
| Fixture | `FIXTURE_INIT rc=0`, `FIXTURE_START rc=0` 16:49:20Z on `/home/user/pg17/clusters/r-ready/pg-data` port 55471 | log lines 8–10 |
| Old root | `OLD_ROOT rc=0 head=925780e0…`, 164 base migrations applied | log |
| Bootstrap | `G2_R_BOOTSTRAP_OK`; identity JSON `{g2_r_ready_disposable, 170006, /home/user/pg17/clusters/r-ready/pg-data, 127.0.0.1, 55471, applied 164}` | log lines 523–525 |
| Identity | `IDENTITY_OK 16:50:03Z data_directory=/home/user/pg17/clusters/r-ready/pg-data server_version_num=170006 cluster_name=r-disposable-pg17` (B-1 closure effective) | log line 526 |
| Jest | `JEST_START 16:50:03Z` exact pinned command; `JEST_END rc=0 16:54:09Z`; `Test Suites: 1 passed, 1 total`; `Tests: 17 passed, 17 total`; `Time: 241.159 s`; `✓` count 17, `✕` count 0; no `GUARD_REFUSAL_OBSERVED_IN_JEST_LOG` line | log 527–532, `jest.log` |
| R01–R12 | every label R01…R12 present as a `✓` line: R01, R02, R03, R04, R05, R06, R07, R08, R09, R10, R11 (decoy) + R11 (shadow search_path), R12; plus 4 scaffolding cases (S1/C1/E+T, B, T on E+B after down, re-up) = 17 | `jest.log` |
| R09 evidence | `PG17_PROCESS g2r_5 old:true … failure {status 500}`; 16 PG17_PROCESS lines, all T results `failed:0` | `jest.log` lines 97 etc. |
| Stop | `FIXTURE_STOP rc=0`; `STOP_STATE_OK postgres_procs=0 port55471=free datadir_retained=/home/user/pg17/clusters/r-ready/pg-data` | log 534–535 |
| Post | `POST s5_cluster=ABSENT unchanged`; `POST b_cluster unchanged conf=173acaa2…6a56 pg_control=9b99d606…2158`; `POST_OK`; `END rc=0 stage=done 16:54:09Z` | log 536–539 |
| Sentinel | `RC=0 STAGE=done END=2026-09-24T16:54:09Z HEAD=7d2895e1…` (once-only consumed) | `run/r-pg-proof.sentinel` |
| Lane now (17:00Z) | 0 postgres processes; port 55471 not listening; `r-ready/pg-data` has no `postmaster.pid` (retained, stopped) | `pgrep`, `ss`, fs |

Retained B clusters, my own independent hashes (Phase 1 baseline 16:35Z → now):
- `b-drain`: conf `173acaa26e8c3b67…` → same; pg_control `9b99d606845d08ee…` → same; no postmaster.pid → same.
- `b-drain.v4-failed-75a2863b-20260924T151250Z` (not hashed by the binding, C-6): conf `173acaa26e8c3b67…` → same; pg_control `d037d71b8c93cc98…` → same; no postmaster.pid → same.
Both untouched.

Receipt hashes: `run/RECEIPTS.sha256` (binding-written) lists `r-pg-proof.log 54de0d6f…`, `jest.log 0c92f238…`; `jest.log` verifies OK; the log entry equals sha256 of the log minus its final two lines (`POST_OK`, `END`), which the binding appends after writing the manifest — I reproduced `54de0d6f…` from `head -n -2`. Full-file `r-pg-proof.log` sha256 `f6802dc267850ec0608e37d2f2d5fb0ecdc1bc5ef67d0443fefda4add35f09a5` (539 lines); `jest.log` `0c92f238defb0d873f71edfca3aaaf621645cfd90ca3d453bdad3c7df23bc159`; sentinel `8a990c05ba64c6f85bf5f8ae5f45d80c9653a2490c04ca9846d2a837ec878c81`.

## 2. Findings

A: none.
B: none open. Closed: B-1 (binding data dir), B-2 (R11 ABSENT assertion) — see `R_ATTESTATION_B.md` and `R_REATTEST_B.md`.

C (recorded only, none creates work):
- C-1 Migration role must be BYPASSRLS for the NULL/noncanonical data gates to be non-vacuous; DDL still fails closed otherwise. Carry into the release runbook (already carried by the parent in `R_CLOSURE_1_GRANT.md`).
- C-2 `down.sql` lacks the brief §4 N-ordering comment and does not require the fence; lossless either way.
- C-3 PG18 would fail the staging column gate closed (NOT NULL in `pg_constraint`); lane PG17, CI PG15.
- C-4 Commit `df36e331` message says NOT NULL on both tables; only the ledger is altered.
- C-5 R12 pg_dump parity is via catalog observations, not `pg_dump -s`.
- C-6 Binding hashes only `clusters/b-drain`, not the v4-failed retained cluster; independently verified unchanged above.
- C-7 Contract pair-surface: `docs/contracts/importer-openapi.json` not in either diff; drift test passed at gate on `df36e331`; closure 1 touched no `src/` file.
- C-8 Default Jest was not re-run on `7d2895e1` (Lefthook has no Jest step); the delta touched no default-Jest input. Receipt 11 (3 suites / 90 tests) on `df36e331` remains applicable.
- C-9 `RECEIPTS.sha256` log-entry offset (manifest written before the last two log lines), inherited from B v5; full-file hash recorded here.
- C-10 The psql client is 18.6 against a 17.6 server (same as accepted B v5).
- C-11 Parent document time labels (e.g. grant "17:00Z") run ~10 min ahead of file mtimes/UTC; ordering (grant → launch) is established by mtimes and is correct.

## 3. Scope, honestly

Proven: on a freshly initialised, disposable, synthetic PG17.6 cluster, with the 164 base migrations + S1/C1/E + B applied through `prisma migrate deploy`, the R migration at head `7d2895e1` (a) refuses — never coerces — NULL provenance, noncanonical values, a missing fence, decoy/rerun name collisions and a held lock, leaving rows, history and catalog byte/OID-identical; (b) applies exactly the two wide unique indexes, two CHECKs and ledger NOT NULL via the release mechanism; (c) leaves the narrow keys, fence, RLS and policies untouched, with T reconstructing on R and the wide keys not arbitrating; (d) refuses content at runtime by CHECK/NOT NULL for owner and runtime roles; (e) the accepted O binary fails closed (500, no rows); (f) down removes only R's four objects and NOT NULL without data loss, T continues on E+B, and re-up restores the identical shape. DTO/`isCanonicalPlatform` parity and contract byte-stability were proven at the default-Jest gate on `df36e331`.

Not proven and not claimed: PG15 CI dry-run, any deployed or real database, production data volume/timing under the 30 s statement_timeout, customer acceptance, `pg_dump -s` textual parity, PG18 behaviour, model/effort telemetry.

## 4. Decision unlocked

With both reviewers at ACCEPT, R (`7d2895e1`, tree `95cdfadc`) is landable to backend `integration/importer` as a fast-forward from B under the owner amendment, per `R_SINGLE_PG_PROOF_GRANT.md`. Release-runbook preconditions: BYPASSRLS migration role (C-1); N-ordering note for `down.sql` (C-2).
