# S2 fresh setup grant

Parent EXEC-6c2a68ac, 2026-09-23. CONDITIONAL, NOT ACTIVE until explicit parent activation after the V61 continuation result is frozen, independently accepted by two nonbuilders and its runtime ownership is closed. Sole executor `restore_s2_substrate_mue9eidh`, requested Claude Fable 5 / High; requested identity is not runtime telemetry.

Tier T4 individual and cumulative. Why: consequential validation provenance, controlled installation and canonical runtime ownership. T4 triggers: trusted validation/recovery/privileged environment actions. T3 triggers: dependency and lifecycle ownership. Bounded T1: NO, privilege and recovery. Parent owner EXEC-6c2a68ac. Acceptance: actual S10/S20/S30 raw0 with exact provenance, unchanged product inputs and outside-root state, no surviving attributable workload, scoped lock release. Stop triggers: first nonzero/unknown, mismatch, unexpected write, collision, scope expansion or ownership uncertainty.

## Exact applicability

This activates no new source. The unchanged scripts and scope are those in archived `execution/e8d546f9/S2_SETUP_GRANT.md`, `2026-09-22/op88/s2-fresh-setup-readiness/READY.md`, `execution/s2-setup-prep/SLOT_REQUEST_05_SETUP_ONLY.md` and the retained SETUP05 result. Historical successes are not reused as current installation evidence.

Read those documents and every executable completely before use. Frozen predecessor manifest remains 37/37. Exact worktree HEAD `d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c`, tree `c0ab87d4dc584b2a7ccad53db16fa551b93fe359`, repository lockfile `62b05b908c835dae51e54af1e553d91f763a070da21813c4419d66e018d61390`, clean including untracked files.

- `_common.sh`: `34548a06ca75c787fdf0ac13c4e90233a28d7716ff18e7cac0211b342808fdaf`.
- `setup-10-clients.sh`: `2d12bf7f9daca68eaaef40914248227501dc7803c4371569dda8073357ddbb58`.
- `setup-20-pg17.sh`: `5e631d1cd0039c21b76855c830f466e00ac6da20e25ecac631890625eb4227b5`.
- `setup-30-npm-ci.sh`: `bdd8078948a8b58f074e53d9cf4596e26f9e8cc862c61334e548323a45b404c6`.
- `launch-detached.sh`: `8d0e2c7ce4721afaa7ff5bdfdfb2cb525790b424b8a163319c9de2e2eb4d7181`.
- `check-lock.sh`: `94ce982b1685e39a4e0afb8b1297ec8428ac06b54b507ec86fb47c8d3b0cf544`.

## Environment and exclusive ownership

Upon activation only, verify current capacity (at least 3GB disk free), fresh identities, no conflicting workload and no other runtime grant. Version/resource/process observations and exact nonblocking canonical lock checks are allowed; never use historical PIDs. The canonical lock may be created by the exact check script and taken by each exact step, never displaced.

ENV01 permits only new writable `execution/s2-setup-prep/infra/logs` and `execution/s2-setup-prep/runs`: temporarily add parent owner-write only to create the directories, restore original0555 modes immediately, keep frozen source files nonwritable. Existing control output remains untouched. Fresh executor evidence is `execution/6c2a68ac/s2-setup-result`, not the old session's result directory.

Allowed endpoints/actions: Ubuntu apt client-package update/install via noninteractive sudo; exact pinned PostgreSQL17.6 Maven binary artifact; locked npm graph plus guarded local Prisma generate with autoinstall disabled. No new vendor, spending or credential. Preserve platform `/home/user/node_modules` and `/home/user/package*.json` state, inventory before/after and promptly preserve raw npm debug logs.

Allowed writes are only enumerated evidence/output directories, client system packages, `/home/user/pg17/{download,dist,PROVENANCE.txt}`, S2 worktree `node_modules`, normal npm cache/logs, and canonical lock file. No server/start/initdb/cluster/database connection or destroy, no hooks, product/schema/generator source edits, Git commits or remote product action. At most two CPU and under3GB RAM; approximately1.5GB disk expectation is not a guarantee.

## Exact sequence

One attempt per step, sequential, first failure or unknown stops all later steps. Preserve each actual start/wait/check status and raw exit sentinel; do not run this as an unchecked list.

```sh
bash /home/user/workspace/execution/s2-setup-prep/infra/check-lock.sh
bash /home/user/workspace/execution/s2-setup-prep/infra/launch-detached.sh start setup-10-6c2a68ac timeout --kill-after=60 1560 bash /home/user/workspace/execution/s2-setup-prep/infra/setup-10-clients.sh
bash /home/user/workspace/execution/s2-setup-prep/infra/launch-detached.sh wait setup-10-6c2a68ac 1700
bash /home/user/workspace/execution/s2-setup-prep/infra/check-lock.sh
bash /home/user/workspace/execution/s2-setup-prep/infra/launch-detached.sh start setup-20-6c2a68ac timeout --kill-after=60 480 bash /home/user/workspace/execution/s2-setup-prep/infra/setup-20-pg17.sh
bash /home/user/workspace/execution/s2-setup-prep/infra/launch-detached.sh wait setup-20-6c2a68ac 600
bash /home/user/workspace/execution/s2-setup-prep/infra/check-lock.sh
bash /home/user/workspace/execution/s2-setup-prep/infra/launch-detached.sh start setup-30-6c2a68ac timeout --kill-after=60 2160 bash /home/user/workspace/execution/s2-setup-prep/infra/setup-30-npm-ci.sh
bash /home/user/workspace/execution/s2-setup-prep/infra/launch-detached.sh wait setup-30-6c2a68ac 2300
bash /home/user/workspace/execution/s2-setup-prep/infra/check-lock.sh
```

Only session-unique run names differ from the previous grant's exact command sequence. The scripts are unchanged. A wait/tool return is not a process exit: require `runs/<name>.exit` present and exactly0, accountable disappearance of attributable workload and positive scoped lock-free observations before the next step. `check-lock.sh` output and current ownership evidence, not merely its incidental shell exit, establish the lock observation. Do not infer unrestricted absence from unreadable process tables.

No retry, resumed control, manual cleanup, deletion of partial installs, unowned signal or automatic recovery. A missing sentinel, surviving workload after observation bound, nonzero/refusal/timeout or unexpected path means STOP and preserve.

## Result

S10: raw0 and client major at least17. S20: raw0, PG17.6 and all four pinned hashes, successful provenance, no server/cluster. S30: raw npm/prisma0, exact head/lock/CLI stamp, unchanged outside-root inventory and clean source. Freeze full commands/logs/raw statuses, identities, before/after source manifests, npm logs and final ownership accounting under a non-self-including manifest.

Success proves fresh setup only. Real S1/S2 composition/discriminator proof remains a separate exact activation after current setup acceptance and control-result closure. Bradley decision required: NO within this bounded authorized local scope.
