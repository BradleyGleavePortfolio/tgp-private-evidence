# B/drain — v5 single PG proof binding and FINAL B finding (reviewer A, successor; same review)

Read-only recomputation against `execution/95633079/s7-b-drain/runtime-v5/{run,binding,PRE1_RENAME_RECEIPT.txt}`, the live worktree, and host state, 15:39–15:42Z. No rerun, no PG start, no source re-audit, no peer B report read. Fable/High requested only; no telemetry observed or claimed. Successor reviewer A, not the former reviewer.

## 0. Final finding
**B/drain candidate head `0d69c7ba7e7d257311cfcb21fa325ebb1ddc1f1c` (tree `d02f9b124bee52107f8ad2f286f8af611b859fe6`, parent `75a2863b…`, base `a0ea1bea…`) PASSES the single authorised PG proof: 19/19 live tests against a fresh PostgreSQL 17.6 disposable cluster, honest stop, clean state. Reviewer A finds no open A/B item against the B candidate. The earlier v4 proof remains RC1 8/19-failed history; it is not rewritten. Acceptance of B/drain at `0d69c7ba…` is, from reviewer A's side, GRANTABLE by the parent/owner.**

Scope of this verdict (G05 honesty): local proof on a disposable synthetic fixture under the sealed template; it is not deployment, migration of a real database, or customer acceptance. The predicate defect found by the first proof is closed by exactly the two-line v5 delta and nothing else.

## 1. PRE-1 preserving rename — receipt bound
`runtime-v5/PRE1_RENAME_RECEIPT.txt`: 15:36:10Z, `mv /home/user/pg17/clusters/b-drain → …/b-drain.v4-failed-75a2863b-20260924T151250Z`, rc 0; pre-checks postmaster.pid absent, 0 postgres procs, 0 listeners, lock free; `pg_control` `d037d71b…` and `postgresql.conf` `173acaa2…` identical before/after; 2559 entries / 77372 KB before/after. My recheck now: both hashes still `d037d71b…`/`173acaa2…`, no pidfile — the failed-run datadir is preserved intact, not deleted. Exactly the one filesystem action the grant named; nothing else outside the builder's areas.

## 2. Run receipts — recomputed
| Item | Observed |
|---|---|
| Launch | `LAUNCH.txt` 15:37:47Z `timeout -k 30 3600 bash …/runtime-v5/binding/b-pg-proof.sh runner_sha=e895b16e` ; runner on disk still `e895b16e1ef369a6a8a952ae224d5cd202b3da54b74614e14d0d4c3a9b4a0123` (the binding I attested; unchanged) |
| Pins enforced | script lines 64–67 refuse placeholders and require `HEAD == 0d69c7ba…` and `HEAD^{tree} == d02f9b12…` before `PRECONDITIONS_OK` — logged 15:37:48Z; live worktree HEAD `0d69c7ba…`, porcelain 0 (`worktree_porcelain_sha` = empty-string sha) |
| Preconditions | server `postgres (PostgreSQL) 17.6` (`23cd1748…`), psql 18.6, provenance `result=success`; `PREFLIGHT_OK bdir=absent port55461=free postgres_procs=0` |
| Fixture | `B_FIXTURE_INIT_OK … cluster_name=b-disposable-pg17 pg_version=17`, init/start rc 0 |
| Old-root | re-created under `runtime-v5/old-root`, head `925780e0…` detached, 164 migrations, `alternates=none`; O client generated with engine `a2924eab…`; candidate client verified (same engine) |
| Bootstrap / identity | `G2_B_BOOTSTRAP_OK` rc 0; `IDENTITY_OK data_directory=/home/user/pg17/clusters/b-drain/pg-data server_version_num=170006 cluster_name=b-disposable-pg17` |
| Jest | `--config jest.rls.config.js test/rls-g2-b-drain.spec.ts --runInBand --ci`, 15:38:03→15:38:56Z, `JEST_END rc=0`; **PASS 1 suite, 19 passed / 19 total, 0 skipped/todo, 52.4 s** |
| Stop / post | `B_FIXTURE_STOP_OK`, `STOP_STATE_OK postgres_procs=0 port55461=free datadir_retained=…/b-drain/pg-data`, `POST s5_cluster=ABSENT unchanged`, `END rc=0 stage=done 15:38:57Z`; sentinel `RC=0 STAGE=done END=2026-09-24T15:38:57Z HEAD=0d69c7ba…` |
| Receipts | `RECEIPTS.sha256`: `jest.log` OK; `b-pg-proof.log` recorded hash equals the log prefix up to the `POST_OK` line (the template appends `POST_OK`/`END` after sealing — same behaviour as the first run; C) |
| Outer manifest | `runtime-v5/OUTER_RECEIPTS.sha256` (8 entries: full final `b-pg-proof.log` `3d182ebf…`, `jest.log` `0204b5b1…`, sentinel, LAUNCH, launcher.out, inner `RECEIPTS.sha256`, `PRE1_RENAME_RECEIPT.txt` `1dbde659…`, runner `e895b16e…`) — `sha256sum -c` 8/8 OK at 15:41Z; the outer manifest covers the complete log including the `POST_OK`/`END` lines, closing the inner-manifest C item |
| Host now | 0 postgres processes, port 55461 not listening, no pidfile in either datadir, canonical lock free; first-run `runtime/run/{jest.log,sentinel}` hashes unchanged vs its own `RECEIPTS.sha256` |

## 3. The 8 former failures — resolved as predicted, no other change
All six root-cause tests now pass with the corrected probe (`fenced:true` → `drained`; `down.sql` recognises the fence): st5 "resolves exactly the 1230 …" and "forward provenance recovery", st6 "locked row", "T paused after reading staging", "concurrent staging writer", st7 "down keeps column, rows and history". The two cascades (st6 "T paused inside its claim", st7 "re-applying the file restores the identical fence") pass as well. The 11 previously-passing tests still pass, with the same counts (430 legacy rows, 1238 NULL / 1230 resolvable / 8 remaining by class, 1244 reconstructed in g2b_10). Only the two predicate blobs differ between the failed and passing runs' candidates (`diff-tree 75a2863b 0d69c7ba` = 2 entries), so the pass is attributable to the fix alone.

## 4. C items (recorded, continue; no action)
- `jest --version` prints 30.4.1 (jest-cli) while `node_modules/jest/package.json` is 30.4.2 — identical string in both proof runs and covered by the lock-hash pin; not a drift.
- `RECEIPTS.sha256` log-hash trailing-lines behaviour (above).
- First-run datadir is preserved under the renamed path; the new datadir is retained per template. Disposal of either is an owner/parent hygiene decision later, not part of this review.

## 5. Reviewer A's own record
The v4 source miss (int2vector/int2[] equality) is recorded in `B_DRAIN_PG_PROOF_FAILURE_TRIAGE_A.md` §2 and stands. The phase-A source verdict for v4 was correct for everything the PG proof did not contradict; v5 changes only what the proof contradicted.

Files in `/home/user/workspace/execution/cf8ff737/b-review-a/`: prelim note, v4 actual-head binding, failure triage, v5 delta binding, v5 actual-head/binding attestation, this final finding, `v5-expect/`, `MANIFEST.sha256`.
