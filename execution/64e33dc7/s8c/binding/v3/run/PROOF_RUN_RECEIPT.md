# S8-C first PG proof run — terminal receipt (S8C_SINGLE_PG_PROOF_GRANT, relay 2026-09-25 05:32Z)

## Result: FIRST FAILURE at stage `bootstrap`, rc=7, natural exit — proof NOT obtained; Jest never ran

## Candidate identity (frozen, re-verified read-only at 05:33Z immediately before launch)
- HEAD `87018a421f5be1064767d2cdd32e75ca935f7cdb`, tree `cec7d05a91876ec3f6badb1020bb97aacdb9331d`, parent `af9f7f5438fa545394b6d28792411439ded66caf`, worktree porcelain 0; proof spec blob `dc804fdef00757732a7e75eeb13dcd30d1920cb4`.
- Driver `s8c-pg-proof.sh` `9ddb52de66c306601080141c38867d25cd048c951e7c57086996ee4ef40eacd8`; fixture `1a7faa5ff4a4937216c329fa8ce810f559085c7ca8f9295c15f9e7a57c0a07b3`; `BINDING.sha256` `ede987a6536f35103f978d97690e45ed84d58c196615560561fbef3d9f7514ec` (manifest re-verified OK); REVIEW_A_V3 `f9a05280…`, REVIEW_B_V3 `6b7e1357…`.
- Live preconditions at launch: lock inode 691716, 0 holders; no postgres/psql/test/tool processes (only platform node 415/454); ports 55641/55642 free; S8-C lane, socket dir, `run/` and sentinel absent.

## Invocation (exactly one; never repeated)
- Command: `timeout -k 30 3600 bash /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c/binding/v3/s8c-pg-proof.sh`
- Supervisor: `setsid nohup bash -c …` PID 29405, stdin `</dev/null`, stdout → `run/supervisor.stdout`, stderr → `run/supervisor.stderr`, launch record `run/LAUNCH.txt`; timeout PID 29407; driver PID 29408 (held canonical flock on fd9, inode 691716, from `START` to `END`).
- START 05:33:12Z → END 05:33:24Z. `SUPERVISOR_RC=7` (natural driver exit; no timeout, no signal, no forced kill).

## Driver stage record (`run/s8c-pg-proof.log`, sha `7d9fa528…`)
- PRECONDITIONS_OK 05:33:14Z (server postgres 17.6; psql 18.6; node v20.20.1; jest 30.4.1; ts-node 10.9.2; prisma 6.19.3).
- PREFLIGHT other lane `s7l` conf/control `ae1fc878…` / `c2d8ebd8…` (matches grant observation; never started). PREFLIGHT_OK 05:33:16Z lane=absent, port free, postgres 0.
- FIXTURE_INIT rc=0 05:33:19Z (`recovery-reset/clusters/s8-c/pg-data`, port 55642, superuser `s8c_super`, cluster `s8c-disposable-pg17`, socket `recovery-reset/run/s8-c`). FIXTURE_START rc=0 05:33:20Z, postmaster pid 29903.
- BOOTSTRAP: supabase shim applied (3 benign "already granted" NOTICEs), Prisma datasource `g2_s8c_disposable` at 127.0.0.1:55642, **171 migrations found and all applied successfully**; then `test/utils/g2-s8c-bootstrap.sh` step 6 (client verification) failed:
  `candidate client schema is not the candidate prisma/schema.prisma (stale client; regenerate in the runtime slot, never here)` → **BOOTSTRAP rc=7 05:33:24Z; STOP_FIRST_FAILURE stage=bootstrap rc=7**.
- Bound cleanup: `S8C_FIXTURE_STOP_OK`; `CLEANUP_STOP rc=0 postgres_procs=0 port55642_listeners=0 survivor_pid=none`; `END rc=7 stage=bootstrap`.
- Sentinel written: `RC=7 STAGE=bootstrap END=2026-09-25T05:33:24Z HEAD=87018a42… LOCK_INODE=691716`; `RECEIPTS.sha256` holds the driver log hash. No `jest.log` (Jest stage never reached; raw Jest totals: none).

## Exact minimum cause (read-only diagnosis; nothing changed)
`g2-s8c-bootstrap.sh` L197 does `cmp -s node_modules/.prisma/client/schema.prisma prisma/schema.prisma`. In the worktree:
- `prisma/schema.prisma` sha `77f33bcd…`, blob `32e44110…` = identical to accepted base `93389265` (candidate never touched the schema).
- `node_modules/.prisma/client/schema.prisma` sha `ded50406…`, mtime 2026-09-25 03:29:36Z (runtime-setup/donor-generated client, not produced by this lane).
- Difference confined to the `ExtensionPairCode` model (lines 6739–6757): column-alignment whitespace on 9 field lines, plus `@@unique([import_intent_id, coach_id])` positioned before vs after the `@@index` lines — i.e. `prisma format`-style normalisation of the committed schema by the generator. Same model set, fields and attributes; no semantic difference observed.
This is an environmental mismatch between the pre-generated client copy and the committed (unformatted) base schema, surfaced by the bootstrap's byte-exact check. It is outside the seven-path candidate delta and outside this grant (no generate/install/regenerate/edit performed). Whether the bootstrap's byte-exact comparison should be normalised, or the runtime slot should regenerate the client from the exact committed schema, is a parent disposition.

## Observed post-state (05:34Z)
- Lock: 0 holders, inode 691716 intact, never removed. Processes: no postgres/psql/jest/driver/timeout survivors. Port 55642: no listener.
- Data retained as designed: `recovery-reset/clusters/s8-c/pg-data` (75 MB, 171 migrations applied, no `postmaster.pid`); socket dir `recovery-reset/run/s8-c` absent after stop. S7-L v2 lane untouched (never started).
- Sentinel present → the driver will refuse any re-invocation (rc 76); none attempted. No source edit, commit, push, retry, fixture destroy, sentinel removal, broad kill or other gate.

## Receipt hashes (`run/`)
`s8c-pg-proof.log` `7d9fa528de578ac749056adc4f3f3b0b3335429e258c95885207bdf4064eb80f`; `s8c-pg-proof.sentinel` `bb89d7b7…`; `LAUNCH.txt` `1843dd4d…`; `supervisor.stdout` `79d2a41a…` (driver stderr merged: the `stale client` line and NOTICEs); `supervisor.stderr` empty (`e3b0c442…`); `RECEIPTS.sha256` (driver-written).

Status: terminal; proof authority consumed by this single failed invocation; candidate frozen; awaiting narrow parent disposition.
