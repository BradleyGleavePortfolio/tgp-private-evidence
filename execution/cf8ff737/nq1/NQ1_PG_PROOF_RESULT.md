# N/Q1 single real-PG proof — RESULT: **FAILED (rc=1, stage=jest)**

Grant: `execution/cf8ff737/NQ1_SINGLE_PG_PROOF_GRANT.md` (18:37Z). Run exactly once, no retry, reported unchanged.
Builder `nq1_final_writer_reader_t4_build`. Requested route Claude Fable 5 / High — no telemetry; I claim none.

## Terminal evidence (unchanged)
| item | value |
|---|---|
| command | `timeout -k 30 3600 bash execution/cf8ff737/nq1/binding/nq1-pg-proof.sh` from `/home/user/workspace`, started 18:37:49Z |
| binding verified before run | `sha256sum -c binding/BINDING.sha256` → all three OK (`nq1-pg-proof.sh` `e47c9ac1…`) |
| sentinel `runtime/run/nq1-pg-proof.sentinel` | `RC=1 STAGE=jest END=2026-09-24T18:41:30Z HEAD=61b93cff7900b24c17011d481fd6c31f5abb59e4` |
| outer rc | `OUTER_RC=1 2026-09-24T18:41:30Z` (receipt 14) |
| runner log | `STOP_FIRST_FAILURE stage=jest rc=1 18:41:29Z` → `NQ1_FIXTURE_STOP_OK` → `CLEANUP_STOP rc=0 postgres_procs=0 port55481_listeners=0` → `END rc=1 stage=jest` |
| stages before jest | PRECONDITIONS_OK (PG 17.6, jest 30.4.1, provenance `23cd1748…`), PREFLIGHT_OK (ndir absent, port free, 0 procs, worktree clean), FIXTURE_INIT rc=0, FIXTURE_START rc=0 (pid 5196), OLD_ROOT rc=0 (head 7d2895e1, detached, 169 migrations), BOOTSTRAP rc=0 (`G2_NQ1_BOOTSTRAP_OK`, applied 169, engine `a2924eab…`), IDENTITY_OK (data_directory `/home/user/pg17/clusters/nq1/pg-data`, 170006, `nq1-disposable-pg17`) |
| jest | `Test Suites: 1 failed, 1 total · Tests: 5 failed, 15 passed, 20 total · Time: 190.7 s` |

## Receipts
| file | sha256 |
|---|---|
| `runtime/run/nq1-pg-proof.log` | `96558929ff3a9c43d1633f04b5c579a753dc2ecae3f6cc3406ab40bd86aef17a` |
| `runtime/run/jest.log` | `83f2de3b484541ba11e5b4072c1395d439ba05e22c05a3917717f2dd30d1c8aa` |
| `runtime/run/nq1-pg-proof.sentinel` | in `runtime/run/RECEIPTS.sha256` |
| `receipts/14-pg-proof-run.txt` | start/outer-rc + the run manifest |
| `receipts/15-pg-proof-jest-matrix.txt` | pass/fail matrix + the five failure blocks (ANSI stripped) |

## Pass/fail matrix
PASS: N01, N04, N05 (writer surfaced **409 `reconstruction provenance conflict`**, logged `PG17_N05_WRITER`), Q01 ×2, Q02 ×2, Q03 ×2, Q04 ×2, Q06 ×2, Q07 ×2.
FAIL: N02, N03, N06, Q05 ×2.

| case | assertion | expected | received |
|---|---|---|---|
| N02 | `fromN.result` tally (`spec:272`) — after `tally(N) == tally(T)` at line 271 **passed** | clients `reconstructed 20 / failed 4` | `24 / 0` (T identical) |
| N03(a) | `n1.result` (`spec:302`) | `reconstructed: 1` | `reconstructed: 4` |
| N06 | `n.result` (`spec:437`) | clients `reconstructed: 9` | `12` |
| Q05 ×2 | foreign coach with a scoped v2 token (`spec:654`) | 404 | 400 |

## Builder's post-hoc reading (read-only; NOT a rerun; classification is for the attesters/parent)
Every failed assertion is a **spec-authored expectation**, and in each the N and T sides agree with each other:
1. **N02 / N06 — inert `failEvery` knob.** The harness' `stageMany(..., failEvery)` writes `name='FAIL'` on every k-th row
   (inherited verbatim from R's harness, where R never asserted failures). Nothing in `src/scout` treats that name as a
   mapper failure, so no `failed` rows arise; N and T both reconstruct 24 (N02, where the N==T equality assertion passed) and
   12 (N06). Test-only expectation defect.
2. **N03(a) — fixture isolation.** N03(a) stages `m1` without `resetData()` first; N01's three default-scope staged rows are
   still present, so the N run reconstructs 4 (1 + 3). N03(b)–(d) reset before staging. Test-only isolation defect.
3. **Q05 — ordering of scope-400 vs 404.** Both readers (candidate and the accepted R reader at 7d2895e1, same lines)
   decode/scope-check the token **before** the `ScoutImport` lookup that yields 404 ("no existence oracle"); a token whose
   `c` ≠ the request coach is therefore 400 `'malformed cursor'`. The spec's 404 expectation contradicts the accepted R
   ordering and the brief's own "outside its (coach, intent, family) scope is 400". Test-only expectation defect.
No product path, contract, schema, or data behaviour was observed differing from the accepted T side; no writer wrote
under conflict; retained clusters were never started.

## Post-run lane state (hash only)
- `pgrep -cx postgres` = 0; port 55481 listeners 0; `test-validation.lock` free.
- `clusters/nq1/pg-data` **retained, stopped** (no postmaster.pid) — disposal only under a separate destroy grant.
- `b-drain`: conf `173acaa2…` / pg_control `9b99d606…`, no pid — identical to PREFLIGHT. `r-ready`: conf `d09e9363…` / pg_control `ed3241cb…`, no pid — identical to PREFLIGHT. (The runner's own POST hash step did not execute because the run stopped at jest; these are my read-only re-hashes.)
- `s7-nq1` clean at `61b93cff…`; `s7-r-ready` clean at `7d2895e1`; `runtime/old-root` detached at `7d2895e1` (has `.g2-nq1-old-client` + `node_modules` symlink into the candidate's tree).

## Status
Grant consumed; fail-closed stop is final. No retry attempted. Any spec correction (N02/N06 expectation, N03(a) reset,
Q05 → 400) is a new candidate head and a new single-run grant; the binding's pins would need re-filling for that head.
