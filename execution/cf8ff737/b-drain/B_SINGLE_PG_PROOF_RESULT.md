# B single real-PostgreSQL proof — actual result: RC=1 (stage jest), FAILURE PRESERVED

Grant `execution/cf8ff737/B_SINGLE_PG_PROOF_GRANT.md`. Executor `b_drain_exact_recovery_and_remainder_mufn6ybc`. Runner `execution/95633079/s7-b-drain/runtime/binding/b-pg-proof.sh` sha256 `a64d24de…b6b9` (== grant), run **once**, unchanged, `timeout -k 30 3600`, launched 15:12:20Z. Raw receipts: `execution/95633079/s7-b-drain/runtime/run/{b-pg-proof.log,jest.log,b-pg-proof.sentinel,LAUNCH.txt,launcher.out}`; old-client at `runtime/old-root/`; datadir retained `/home/user/pg17/clusters/b-drain/pg-data` (76M) + `pg.log`, `pg-data.initdb.log`.

## Sequence (first nonzero stop)

| Stage | Result |
|---|---|
| PRECONDITIONS | OK 15:12:20Z — head/tree/spec/bootstrap/fixture pins, postgres 17.6 (sha `23cd1748…`), psql 18.6, jest 30.4.1 (CLI print; package 30.4.2 recorded earlier), provenance result=success |
| PREFLIGHT | OK — bdir absent, port 55461 free, 0 postgres procs, worktree porcelain empty |
| FIXTURE_INIT / FIXTURE_START | rc 0 / rc 0 15:12:22Z |
| BOOTSTRAP (sealed; old migrations 164 applied, O-client generated, candidate client verified engine `a2924eab…`) | rc 0 15:12:33Z, `G2_B_BOOTSTRAP_OK` |
| IDENTITY | OK — data_directory `/home/user/pg17/clusters/b-drain/pg-data`, server_version_num 170006, cluster_name b-disposable-pg17 |
| JEST `--config jest.rls.config.js test/rls-g2-b-drain.spec.ts --runInBand --ci` | **rc 1** 15:14:49Z — `Tests: 8 failed, 11 passed, 19 total`, 52.1 s, then "Jest did not exit one second after the test run" (open handles) — Jest exited by itself ~2 min later; no TERM was sent, the 1500 s inner bound was not reached |
| STOP_FIRST_FAILURE → CLEANUP_STOP | rc 0 — `postgres_procs=0 port55461_listeners=0` |
| END | `RC=1 STAGE=jest END=2026-09-24T15:14:50Z HEAD=75a2863b…` |

Post-exit verification 15:15Z: 0 postgres processes, no 55461 listener, no jest/runner/timeout processes, canonical slot **free**, candidate head `75a2863b` clean (porcelain empty), no source edits. Slot released for J3.

## Observed failures (from jest.log; no source audit performed)

Passed (11): stages 1–4 incl. "prisma migrate deploy applies exactly B; identity, RLS and indexes are untouched", "refuses a NULL-provenance INSERT from the owner and from the runtime role", "the actual O binary fails closed on a new staged row", "T creates with provenance and claims a re-opened NULL row through the fence", stage-5 fixture build 1238 NULL rows, stage-5 "rerun is idempotent".

Failed (8):
1. stage 5 `resolves exactly the 1230 in three chunks…` — report `fenced: false`, expected `true`; all other fields matched (batch 500, ledgerTotal 1250, nullBefore 1238, nullAfter 8, mismatch 2, outcome unresolved). spec:418.
2. stage 5 `forward provenance recovery…` — same `fenced: false` (nullBefore 8 → nullAfter 0 matched).
3. stage 6 `skips a row locked by another transaction…` — outcome `complete_unfenced`, expected `drained` (rows examined/updated matched). spec:509.
4–6. stage 6 `T paused after reading staging…`, `T paused inside its claim…`, `a concurrent staging writer…` — fail (same suite; detail in jest.log).
7. stage 7 `down keeps column, rows and history…` — psql down.sql:70 `ERROR: G2-B fence absent` (+ WARNING "already a transaction in progress" from `--single-transaction`). spec:597.
8. stage 7 `re-applying the file restores the identical fence` — fail.

Common observed shape: the backfill's `fenced` detection reports the fence absent (`complete_unfenced`) although stage-4 fence tests passed on the same database; stage-7 `down.sql` also finds "fence absent". Whether this is a spec/fixture-sequencing defect, a detector query defect, or a real fence gap is for the reviewers' triage — not determined here. This is the candidate's first real-PG execution; the earlier unit gates (42/42) do not cover these stages.

## Classification (for parent/reviewers)

B for the B/drain proof: the sealed acceptance suite does not pass on the exact candidate; blocks only B acceptance/PG proof. Not A on any customer path (local disposable fixture, no product write). No retry, no fix, no gate change performed. Predecessor RC71 and C1/S5 evidence untouched.

## Smallest closure (proposal only)

Reviewers triage `fenced` detection vs. spec stages 5–7 on head `75a2863b` using the preserved jest.log/datadir; any source change is a new candidate (v5) requiring the ordinary stage/gate/commit path and one new single proof — not a rerun of this one.
