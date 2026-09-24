# S8-B — single PG proof RESULT (rc=0, stage=done, 14/14; one run, no retry)

Grant: `execution/ce3748cb/S8_B_SINGLE_PG_PROOF_GRANT.md`. Executor: `s8_b_provenance_ledger_draft_mug1i9py` (sole). Run
2026-09-24 22:32:13Z → 22:33:37Z (84 s wall). Candidate `8a0075de1ac6ec6cef439af77105896ad0862859` (tree `b8aab8e6`, parent
`edd6dc6b` → C `1b6cc661`). Runner `binding/s8b-pg-proof.sh` sha `be7981eb…` — self-checked `sha256sum -c BINDING.sha256`
10/10 OK inside `binding/` before launch, byte-unchanged during the run. Nothing pushed; no commit made; worktree `s8-b` clean
before and after (porcelain sha `e3b0c442…` = empty, HEAD unchanged).

## Terminal evidence
| item | value |
|---|---|
| sentinel `runtime/run/s8b-pg-proof.sentinel` | `RC=0 STAGE=done END=2026-09-24T22:33:37Z HEAD=8a0075de1ac6ec6cef439af77105896ad0862859` |
| outer `timeout -k 30 3600` rc | `OUTER_RC=0` (wrapper receipt 18) |
| lock | canonical `execution/test-validation.lock`: free at first poll (`LOCK_FREE_AFTER_POLLS=0`), taken by the runner on fd 9 for the whole run, released at exit; never removed |
| stages | `PRECONDITIONS_OK` 22:32:17 → `PREFLIGHT_OK` (bdir8 absent, port 55511 free, postgres_procs 0) → `FIXTURE_INIT rc=0` → `FIXTURE_START rc=0` (pid 25568) → `OLD_ROOT rc=0` head `1b6cc661` → `BOOTSTRAP rc=0` (`G2_S8B_OLD_ROOT_OK`, `G2_S8B_BOOTSTRAP_OK`) → `IDENTITY_OK` (data_directory `/home/user/pg17/clusters/s8-b/pg-data`, server_version_num 170006, cluster_name `s8b-disposable-pg17`, DB marker matched) → `JEST_END rc=0` → `FIXTURE_STOP rc=0` → `STOP_STATE_OK` → `POST_OK` → `END rc=0 stage=done` |
| jest | `./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s8b.spec.ts --runInBand --ci`: **Test Suites 1 passed; Tests 14 passed, 14 total; 54.2 s**. No `GUARD_REFUSAL_OBSERVED_IN_JEST_LOG` |
| fixture identity (spec `PG17_DATABASE`) | `{"port":55511,"user":"postgres","owner":"postgres","super":false,"address":"127.0.0.1","version":"170006","database":"g2_s8b_disposable","bypassrls":true,"directory":"/home/user/pg17/clusters/s8-b/pg-data"}` |
| server / tools | PostgreSQL 17.6 (`postgres` sha `23cd1748…` = S1/S2 provenance), psql 18.6 client, jest 30.4.1, node v20.20.1 |
| receipts | `runtime/run/RECEIPTS.sha256`: `s8b-pg-proof.log` `bc6d1299…`, `jest.log` `40dd8bee…`; wrapper `receipts/18-pg-proof-wrapper.{sh,log}` (log `7cc6a848…`); `receipts/RECEIPTS.sha256` resealed 18/18 |

## Matrix (14 cases, all ✓; durations from jest)
| stage | case | result |
|---|---|---|
| 1 | OLD N writer reconstructs a family on the pre-S8-B schema (baseline; `{intent_id:'intent',staged:1,reconstructed:1,skipped:0,failed:0}`, 11 queries) | ✓ 1.5 s |
| 1 | decoy relation holding the provenance name refuses up; decoy and ledger untouched | ✓ 2.0 s |
| 1 | decoy ledger constraint holding an S8-B name refuses up; nothing created | ✓ 1.7 s |
| 1 | held ledger transaction → up hits `lock_timeout` 55P03 (elapsed 5038 ms); nothing applied; release → free | ✓ 6.3 s |
| 2 | **P01** `prisma migrate deploy` applies exactly S8-B (history 170 → 171); both catalogs exact; ledger RLS/rows untouched | ✓ 3.3 s |
| 2 | **P02** raw rerun refused atomically (`G2-S8B provenance already present`); OIDs/rows/history unchanged; deploy has nothing pending | ✓ 2.7 s |
| 3 | **P05** OLD image N writer (pre-S8-B client) reconstructs on S8-B unchanged; ledger rows `target_kind NULL`; replay converges | ✓ 2.3 s |
| 3 | **P05** candidate image N writer + both images' roster read identical on S8-B; cross-tenant 404 on both | ✓ 5.0 s |
| 3 | CHECK/FK refuse every malformed provenance / typed-ledger row for owner and `service_role`; nothing written | ✓ 1.6 s |
| 3 | D-S8-3 identity, child `source_id` encodings (`#id:` / `#ord:`), typed ledger target accepted exactly once; bound intent `ON DELETE RESTRICT` | ✓ 0.9 s |
| 3 | **P06** anon/authenticated refused by privilege AND by policy; `service_role` rollback persists nothing | ✓ 0.9 s |
| 4 | **P03** down refuses with provenance rows, then typed ledger rows (fixed forward-repair text); nothing deleted; schema/OIDs/history unchanged | ✓ 2.1 s |
| 4 | **P04** down on an empty fact set removes exactly S8-B; every ledger row/value kept; OLD writer continues; second down refuses (`G2-S8B provenance absent`) | ✓ 3.5 s |
| 4 | re-apply restores the identical shape (OIDs aside); ledger rows keep `target_kind NULL`; raw rerun refused again | ✓ 2.9 s |

Acceptance criteria designed for in `S8_B_DRAFT_GRANT.md` — expand / refusing down (refuses once any provenance row exists;
forward repair) / rerun idempotence / RLS anon+authenticated deny, service_role only / closed CHECK on `target_kind` and
`outcome` / mixed-version (N/Q1+C writer unchanged on the S8-B schema) — each exercised by at least one passing case above.
The phase-1 finding 8 risk (UNVERIFIED `pg_get_*def` rendering strings) did not materialise: P01's exact-catalog assertions
passed on the first and only run.

## Cleanup / retained state
| item | state |
|---|---|
| postgres processes | 0 after `FIXTURE_STOP rc=0` (`S8B_FIXTURE_STOP_OK`); `WRAPPER_END pgrep_postgres=0 listeners_55511=0`; re-checked 0 at report time |
| port 55511 | free |
| data dir | **RETAINED, stopped**: `/home/user/pg17/clusters/s8-b/pg-data` (75 MB, no `postmaster.pid`). Destroy = separate marker-gated grant (`s8b-fixture.sh destroy`) |
| old root | **RETAINED**: `execution/ce3748cb/s8b/runtime/old-root` (144 MB, detached `1b6cc661`, own OLD client under `.g2-s8b-old-client`) — once-only fixture; the runner refuses to reuse it |
| retained lanes | `nq1` and `c-contract` clusters: `POST … unchanged` (conf + pg_control hashes identical pre/post; never started); `s5`, `c1-builder`, `b-drain`, `r-ready`, `s7-l`: ABSENT before and after |
| worktree `s8-b` | clean, HEAD `8a0075de`, no commit, no push; `node_modules` client still `b6716a86…` |
| lock | `execution/test-validation.lock` present, released |
| sentinel | present → the runner refuses a second run (rc 76) by design |

## Not done / limits (C)
- No CI chain-harness PG15 dry-run here (no PG15 server; deferred to the PR's `migration-dry-run` as recorded in
  `SOURCE_READY.md`).
- Spec `console.warn` lines (`PG17_DATABASE`, `PG17_PROCESS`, `PG17_LOCK_TIMEOUT`, `PG17_HISTORY`) are the accepted proofs'
  observability convention, not failures.

**rc=0 · stage=done · 14/14 · postgres 0 · port 55511 free · data dir + old root retained.** Next (parent): acceptance record
for S8-B at `8a0075de`; land via PR after #536 (and S8-A); S7-L re-pins onto the S8-B head before its PG run per
`POST_C_SEQUENCING.md`; S8-C proceeds on the accepted head.
