# S5 R3 — slot request (checkpoint 2)

Requesting a named slot on `/home/user/workspace/execution/test-validation.lock` for the S5 lane, steps 1–5 of
`execution/s5-r3/INITIAL_PLAN.md`, in that order, stop-on-first-failure, one infra-class rerun maximum.

- Source: `worktrees/s5-r3` @ `cf3e72f90ad63d40c1831d8b86141f2d16b7ba05` (tree `85d57e9d…`), clean, bundle frozen at
  `execution/s5-r3/checkpoint-2/s5-r3-candidate.bundle`.
- Dependencies: S5's own `package-lock.json` (blob `354de3da…`), `npm ci --ignore-scripts` from the public npm registry only.
- Server: S1's shared PostgreSQL 17.6 distribution at `/home/user/pg17/dist` must already exist (S5 installs nothing);
  lane s5 initialised or marked by `execution/s5-r3/s5-fixture.sh` with `cluster_name='s5-disposable-pg17'`, port 54325,
  loopback only, data dir `/home/user/pg17/clusters/s5`. `/usr/bin/psql` (client 18) must be present.
- Fixture password: synthetic `s5_local_synthetic`, passed only as `G2_PG17_PASSWORD` in the environment of the runner invocation.
- Every connected step is preceded by the read-only identity preflight; identity mismatch → rc 3 and nothing is mutated.
- Bounds: total ≤ 40 min wall, 2 CPUs, node heap 4 GB; writes only to `worktrees/s5-r3/node_modules`,
  `/home/user/pg17/clusters/s5`, `execution/s5-r3/logs/`, `execution/test-validation.lock.log`.
- Lock is taken nonblocking (rc 75) — if another lane holds it the runner exits immediately and I report, no waiting.

Nothing has been executed pending this grant. Parent decides; builder does not self-clear.
