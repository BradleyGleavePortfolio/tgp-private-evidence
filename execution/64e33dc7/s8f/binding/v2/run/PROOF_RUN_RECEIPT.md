# S8-F real-PG proof — single run under grant S8F-PG-1 (e064f1b3), executor RT-NEW-1

Pre-launch (`LAUNCH.txt`, 21:45:08Z): lock inode 667698 no holder; postgres procs 0; port 55643 free; lane and `run/`
absent; `BINDING.sha256` 9/9 OK; runner 3e43c8c8697c245700f581823816e5a43e1419f1b7739d8651d53b08b6a37f4c, fixture
4983477330f11597de5b3350c45aaf9dd1ff0bc4278b00cec980f7d6f11e8f5f (== grant). Launched once, unchanged, no env overrides:
`timeout -k 30 3600 bash .../binding/v2/s8f-pg-proof.sh` at 21:45:20Z (pid 28285 took `flock -n` fd 9; `lslocks` showed it).

Terminal sentinel `s8f-pg-proof.sentinel`:
`RC=0 STAGE=done END=2026-09-25T21:46:01Z HEAD=e1ec2fecb71f315b6721d426ba0dacb84f304498 LOCK_INODE=667698`

Stages (all in `s8f-pg-proof.log`): PRECONDITIONS_OK 21:45:22Z (server 17.6, psql 18.6 real binary, node v20.20.1, jest
30.4.1 CLI / prisma 6.19.3) → PREFLIGHT_OK (lane absent, port free, no other lanes) → FIXTURE_INIT rc=0 → FIXTURE_START
rc=0 (pid 28788) → committed `bash test/utils/g2-s8f-bootstrap.sh` rc=0 (172 migrations applied, `G2_S8F_BOOTSTRAP_OK`) →
IDENTITY_OK (data_directory = lane, server_version_num 170006, cluster s8f-disposable-pg17, DB marker, applied 172) →
JEST 21:45:28Z–21:46:01Z rc=0 → JEST_COUNT_OK → FIXTURE_STOP rc=0 → STOP_STATE_OK → POST_OK → END rc=0.

Jest summary (`jest.log`, sha256 fb7d2df2c5a81743522a2f02ea776dd1e263b96cec26d91ebbefc7179d0c5c81):
```
PASS rls-live test/rls-g2-s8f.spec.ts (32.183 s)
Test Suites: 1 passed, 1 total
Tests:       11 passed, 11 total
Snapshots:   0 total
Time:        32.434 s
```
All 11 `it()` cases passed (stage 0 identity; F01/F02; F04 x2; F05 x3; F07 x2; F10 x2). No GUARD_REFUSAL line.

Stop state: `STOP_STATE_OK postgres_procs=0 port55643=free`, data dir RETAINED at
`/home/user/workspace/execution/1910a060/runtime/proof-s8f-v2/clusters/s8-f/pg-data` (75M, no postmaster.pid; also
`pg-data.initdb.log`, `pg.log`, `pg.log.pg_ctl`). Destroy NOT performed (not granted).

Lock: held on fd 9 from 21:45:20Z through post checks, released by process exit at 21:46:01Z. `post-release.txt`
21:46:15Z: `lslocks` no holder, inode 667698, postgres procs 0, port 55643 free, clone clean at e1ec2fec.

Receipts: `RECEIPTS.sha256` (written by the runner's `finish`): s8f-pg-proof.log 7bbfc6cc… , jest.log fb7d2df2… .
Note (inherited v1 ordering, not altered): `finish` hashes the log BEFORE appending its final `END` line, so
7bbfc6cc… equals `head -n -1 s8f-pg-proof.log` (verified); the complete final log hashes 62be7d94… .
`SHA256SUMS` (this directory, after the run) covers the final files: s8f-pg-proof.log 62be7d94…, jest.log fb7d2df2…,
sentinel 5760b351…, RECEIPTS.sha256 f2526933…, LAUNCH.txt 62c0629b…, launcher.out 54d9ec1a…, post-release.txt c8a4b5ae… .
Binding files unchanged after the run (`BINDING.sha256` 9/9 OK).

No retry, no edit, no rerun, no destroy, no other test/gate/commit/push.
