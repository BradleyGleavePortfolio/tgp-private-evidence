# EXEC-e8d546f9 S2 fresh setup grant

T4 execution-only environment slice. Parent grants the existing SETUP05 bytes, not new source, conditional on restoration checks below. Sole executor `restore_upstream_proof_inputs_muddwjad`, Claude Fable5 requested; all other workers remain source/review-only. This is a fresh grant, not inheritance of a historical slot.

## Exact inputs and permitted scope

Read entire preserved `2026-09-22/op88/s2-fresh-setup-readiness/READY.md`, `2026-09-22/remediation/s2-setup-prep/proposal-1/SLOT_REQUEST_05_SETUP_ONLY.md`, setup05 result and each executable before use. Existing source/evidence applicability is unchanged. Runner controls and real proof are separate and NOT granted.

Verify predecessor37-file manifest at execution/s2-setup-prep, exact clean worktree d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c/treec0ab87d4dc584b2a7ccad53db16fa551b93fe359, repository lockfile62b05b908c835dae51e54af1e553d91f763a070da21813c4419d66e018d61390.

Exact scripts:
- `_common.sh`34548a06ca75c787fdf0ac13c4e90233a28d7716ff18e7cac0211b342808fdaf
- `setup-10-clients.sh`2d12bf7f9daca68eaaef40914248227501dc7803c4371569dda8073357ddbb58
- `setup-20-pg17.sh`5e631d1cd0039c21b76855c830f466e00ac6da20e25ecac631890625eb4227b5
- `setup-30-npm-ci.sh`bdd8078948a8b58f074e53d9cf4596e26f9e8cc862c61334e548323a45b404c6
- `launch-detached.sh`8d0e2c7ce4721afaa7ff5bdfdfb2cb525790b424b8a163319c9de2e2eb4d7181
- `check-lock.sh`94ce982b1685e39a4e0afb8b1297ec8428ac06b54b507ec86fb47c8d3b0cf544

Before start observe resource capacity and canonical lock ownership without displacing anyone; ≥3GB free and no other heavy grant. Parent observed9.7GB00:52UTC, recheck actual. Never use old PIDs.

## Additive paths and authority

ENV01: create only execution/s2-setup-prep/infra/logs and execution/s2-setup-prep/runs as new writable output directories, preserving37source-file bytes; if source parents are0555, temporarily add owner write only to create these two dirs then restore parent modes. No write permission on archived source files. Create new execution/e8d546f9/s2-setup-result for logs/index. Grant allows canonical lock creation/use by exact check-lock and step scripts; nonblocking only.

Allowed install endpoints/actions: sudo apt update/install for PostgreSQL client only; Maven Central exact pinned PostgreSQL17.6 binaries; npm locked graph in worktrees/s2-runner53 using --ignore-scripts then guarded local Prisma generate. No new vendor/spend or credentials. Retain global platform /home/user/node_modules untouched and verify before/after.

Allowed writes: listed outputs; system client packages; /home/user/pg17/{download,dist,PROVENANCE.txt}; worktrees/s2-runner53/node_modules; normal npm logs/cache. No server/initdb/cluster/database/network DB connection/destroy, product source, schema or generator source edit, Git hook/commit, public/remote actions.

## Exact execution and bounds

Use the unchanged launcher, unique run names below and exact outer bounds. All paths absolute, source bytes unchanged. Run sequentially, ONE attempt per step, stop on first nonzero/unknown.

```
bash /home/user/workspace/execution/s2-setup-prep/infra/check-lock.sh
bash /home/user/workspace/execution/s2-setup-prep/infra/launch-detached.sh start setup-10-e8d546f9 timeout --kill-after=60 1560 bash /home/user/workspace/execution/s2-setup-prep/infra/setup-10-clients.sh
bash /home/user/workspace/execution/s2-setup-prep/infra/launch-detached.sh wait setup-10-e8d546f9 1700
bash /home/user/workspace/execution/s2-setup-prep/infra/check-lock.sh
bash /home/user/workspace/execution/s2-setup-prep/infra/launch-detached.sh start setup-20-e8d546f9 timeout --kill-after=60 480 bash /home/user/workspace/execution/s2-setup-prep/infra/setup-20-pg17.sh
bash /home/user/workspace/execution/s2-setup-prep/infra/launch-detached.sh wait setup-20-e8d546f9 600
bash /home/user/workspace/execution/s2-setup-prep/infra/check-lock.sh
bash /home/user/workspace/execution/s2-setup-prep/infra/launch-detached.sh start setup-30-e8d546f9 timeout --kill-after=60 2160 bash /home/user/workspace/execution/s2-setup-prep/infra/setup-30-npm-ci.sh
bash /home/user/workspace/execution/s2-setup-prep/infra/launch-detached.sh wait setup-30-e8d546f9 2300
bash /home/user/workspace/execution/s2-setup-prep/infra/check-lock.sh
```

Capture each actual command status immediately. Launcher wait success alone is insufficient: require actual runs/<name>.exit sentinel exists and exactly0, no surviving attributable stage workload, lock free and source clean before next step. Missing sentinel, live process after observation bound, unknown ownership, nonzero or refusal means STOP/report, not retry or unowned signalling. Keep partial state and all original logs; no manual cleanup/destruction/reinstall.

Bounds: ≤2CPU,<3GBRAM,approximately1.5GBdisk. Inner commands and frozen outer timeouts bound each stage; do not relabel an observer return as confirmed process termination. Parent retains sole slot scheduling; no parallel control/test/browser/install in this workspace during this grant.

## Acceptance and return

S10: raw0, client≥17. S20: raw0, exact four SHA256 pins and result=success, no cluster/server. S30: raw0, npm/prisma raw0, unchanged outside-root inventory, exact head/lock/CLI stamp, clean source. Each step: actual start/end/status, current ownership and cleanup/lock observation. Preserve npm debug logs safely, no tokens or customer data.

Freeze result with non-self-including manifest; record negative/refusal if encountered, do not fabricate success. Success proves fresh environment only, never controls, real composition, S1TRUNCATE, final audit or release.
