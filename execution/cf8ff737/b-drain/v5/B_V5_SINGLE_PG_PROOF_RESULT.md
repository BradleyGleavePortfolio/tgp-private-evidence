# B/drain v5 single real-PostgreSQL proof — actual result: RC=0, 19/19

Grant `execution/cf8ff737/B_V5_SINGLE_PG_PROOF_GRANT.md`. Sole executor `b_drain_exact_recovery_and_remainder_mufn6ybc`. Run exactly once; no retry, no edits, no rerun of S5/C1/inherited proofs. **Not self-accepted** — parent/reviewer disposition.

## PRE-1 preserving rename (receipt `execution/95633079/s7-b-drain/runtime-v5/PRE1_RENAME_RECEIPT.txt`, sha `1dbde659…`)
15:36:10Z. Prechecks all true: src present, target absent, `postmaster.pid` absent, 0 postgres, port 55461 free, canonical lock free.
`mv /home/user/pg17/clusters/b-drain /home/user/pg17/clusters/b-drain.v4-failed-75a2863b-20260924T151250Z` rc 0.
pg_control `d037d71b…` and postgresql.conf `173acaa2…` identical before/after; `du -s` 77372 → 77372; 2559 → 2559 entries. Nothing deleted/started/modified/reused. Re-verified after the run (pg_control still `d037d71b…`).

## Runner (`runtime-v5/binding/b-pg-proof.sh`, sha `e895b16e…` verified immediately before launch)
`timeout -k 30 3600 bash …` launched 15:37:47Z via setsid/nohup (`run/LAUNCH.txt`, launcher pid 17267, runner pid 17271). Outer timeout never fired; no TERM sent.

| Stage | Result | UTC |
|---|---|---|
| preconditions (HEAD `0d69c7ba`, tree `d02f9b12`, spec `9b31fd18`, bootstrap `b4503eef`, fixture `4525f01d`, S5 pins, node_modules/client pins, PG17 binaries 17.6, hooks) | OK | 15:37:48 |
| preflight (bdir absent, port free, 0 postgres, S5 absent, C1 absent) | OK | 15:37:48 |
| fixture init / start (fresh disposable cluster, pid 17529) | rc 0 / rc 0 | 15:37:51 |
| old-root re-created under `runtime-v5/old-root` at O `925780e0`, 164 migrations | rc 0 | 15:37:53 |
| bootstrap: roles, marked DB, shim, 164 O migrations applied, O-client generated (engine `a2924eab…` = candidate client engine) | rc 0, `G2_B_BOOTSTRAP_OK` | 15:38:03 |
| identity (data_directory, 170006, cluster b-disposable-pg17, marker) | OK | 15:38:03 |
| **jest `test/rls-g2-b-drain.spec.ts` --runInBand --ci** | **rc 0 — Test Suites 1/1, Tests 19 passed, 19 total, 52.4 s** | 15:38:56 |
| fixture stop | rc 0; `STOP_STATE_OK postgres_procs=0 port55461=free datadir_retained` | 15:38:57 |
| post (S5 absent unchanged, worktree porcelain unchanged, HEAD unchanged) | OK; `END rc=0 stage=done` | 15:38:57 |

Sentinel: `RC=0 STAGE=done END=2026-09-24T15:38:57Z HEAD=0d69c7ba7e7d257311cfcb21fa325ebb1ddc1f1c`. Total ~70 s.

All 19 cases ✓ including the 8 that failed in v4 (fence-detection, `complete_unfenced`, down.sql fence-absent, and the two cascades): `assigns exactly the staged platform…`, `an O restart re-creates NULL rows…`, `prisma migrate deploy applies exactly B…`, `a raw rerun of B is refused…`, `resolves exactly the 1230 in three chunks…`, `forward provenance recovery…`, `down keeps column, rows and history…`, `re-applying the file restores the identical fence`. No Jest "did not exit" / open-handle message this run (the v4 cascade was a failure-path artefact; unchanged spec, no fix applied).

## Terminal state (observed after exit)
- postgres procs 0; port 55461 listeners 0; no jest/runner survivors; canonical lock free (released on exit).
- New datadir retained stopped: `/home/user/pg17/clusters/b-drain/pg-data` (77M, no postmaster.pid). Destroy = separate grant.
- First-run evidence untouched: `runtime/run/RECEIPTS.sha256` re-verified; `runtime/old-root`, `runtime/binding` (a64d24de…) unchanged; v4 datadir preserved at the renamed path.
- Worktree HEAD `0d69c7ba`, clean.

## Receipts
- Inner: `runtime-v5/run/RECEIPTS.sha256` (`b-pg-proof.log 258c737b…` at write time, `jest.log 0204b5b1…`).
- Outer (sealed after exit): `runtime-v5/OUTER_RECEIPTS.sha256` — b-pg-proof.log `3d182ebf…`, jest.log `0204b5b1…`, sentinel `53462b7d…`, LAUNCH `cf90fce9…`, launcher.out `1eee20e9…`, RECEIPTS `efe2e6df…`, PRE1 receipt `1dbde659…`, runner `e895b16e…`.

## Qualifications (C — record/continue)
- Same as v4: the template hashes `b-pg-proof.log` before appending its own `POST_OK`/`END` lines, so the inner RECEIPTS entry for the log (`258c737b…`) predates the final file (`3d182ebf…`); `jest.log` matches. Outer receipt is authoritative for the final bytes. No template change.
- Jest CLI banner 30.4.1 vs package 30.4.2 (unchanged from v4, pinned C1 tree).
- PG bootstrap NOTICEs about pre-existing role membership grants in `supabase-shim.sql` are benign, identical to v4.

## What this is / is not
Local disposable-DB conformance of head `0d69c7ba` for the G2-B obsolete-writer fence + NULL-provenance backfill. Not deployment, not remote publication, not customer acceptance. Next constraints (parent-owned): reviewer disposition of this result; product-remote publication of `0d69c7ba` (and history) requires a separate owner/parent grant; disposable-cluster disposal (both `b-drain` and `b-drain.v4-failed-…`) requires its marker-gated grant.
