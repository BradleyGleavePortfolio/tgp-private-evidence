# SLOT REQUEST 05 — SETUP-ONLY allocation (S2-SETUP-FIXTURE-PREP). Request, not a grant. Frozen 2026-09-22.

Purpose: install the client tools, the pinned PG 17.6 distribution and the locked dependency closure needed by the already-frozen proof, **without starting any server, creating any cluster/database, or touching product source.** May be granted while independent source scrutiny of the runner/fixture proceeds (brief §4); no real mutation before all guard evidence is accepted.

## Inputs (exact bytes; any change → new request)
- `execution/s2-setup-prep/infra/_common.sh` `34548a06ca75c787fdf0ac13c4e90233a28d7716ff18e7cac0211b342808fdaf`
- `infra/setup-10-clients.sh` `2d12bf7f9daca68eaaef40914248227501dc7803c4371569dda8073357ddbb58`
- `infra/setup-20-pg17.sh` `5e631d1cd0039c21b76855c830f466e00ac6da20e25ecac631890625eb4227b5`
- `infra/setup-30-npm-ci.sh` `bdd8078948a8b58f074e53d9cf4596e26f9e8cc862c61334e548323a45b404c6`
- `infra/launch-detached.sh` `8d0e2c7ce4721afaa7ff5bdfdfb2cb525790b424b8a163319c9de2e2eb4d7181`; `infra/check-lock.sh` `94ce982b…f544`
- worktree `/home/user/workspace/worktrees/s2-runner53` at `d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c`, clean; `package-lock.json` `62b05b90…1390`

## Steps (sequential, each takes the canonical lock nonblocking for its own duration only; each launched detached with the real PID and exit sentinel)
```
cd /home/user/workspace/execution/s2-setup-prep
./infra/check-lock.sh                                              # precheck: lock FREE (file may not exist yet)
./infra/launch-detached.sh start setup-10 bash /home/user/workspace/execution/s2-setup-prep/infra/setup-10-clients.sh ; ./infra/launch-detached.sh wait setup-10 1600
./infra/launch-detached.sh start setup-20 bash /home/user/workspace/execution/s2-setup-prep/infra/setup-20-pg17.sh    ; ./infra/launch-detached.sh wait setup-20 500
./infra/launch-detached.sh start setup-30 bash /home/user/workspace/execution/s2-setup-prep/infra/setup-30-npm-ci.sh  ; ./infra/launch-detached.sh wait setup-30 2200
```
| Step | What it does | Network / privilege | Bound | Writes | Refusals |
|---|---|---|---|---|---|
| S10 | `apt-get update` + `apt-get install postgresql-client-18` (falls back 17/generic) via `sudo -n` | apt mirrors; sudo | 600 s + 900 s inner | system packages only | client major < 17 → 70 |
| S20 | download zonky `embedded-postgres-binaries-linux-amd64-17.6.0.jar` from Maven Central, verify SHA1 `81633223…` + SHA256 jar/txz/postgres/initdb against S1's recorded values, extract to `/home/user/pg17/dist`, write `/home/user/pg17/PROVENANCE.txt` | repo1.maven.org | 300 s + 60 s | `/home/user/pg17/{download,dist,PROVENANCE.txt}` | any hash mismatch → 70; existing `dist` without provenance → 70 (**no rm -rf**) |
| S30 | `npm ci --ignore-scripts` in `$WT` (1118 packages historically, ~5 min), then `prisma generate` with auto-install disabled; writes stamp `node_modules/.s2-composition-install-stamp` | npm registry | 1500 s + 600 s | `$WT/node_modules` (git-ignored) | head ≠ d5cd / lock hash / dirty / missing prisma / anything appearing under `/home/user` outside `$WT` → 70 |

Resources: ≤2 CPU, <3 GB RAM, ~1.5 GB disk. No server, no `initdb`, no cluster, no DB, no destroy. Sole heavy owner while running.

## Positive criteria (all reported from actual logs under `infra/logs/`, not assumed)
S10 exit 0, `psql --version` ≥ 17 on PATH. S20 exit 0, `PROVENANCE.txt` `result=success` with the four S1-recorded SHA256s. S30 exit 0, `npm_ci_exit=0`, `prisma_generate_exit=0`, `outside_root_before == outside_root_after`, stamp contains `head=d5cd9b8b…`, `lock=62b05b90…`, `prisma_cli_sha256=` (historical value `c2a77456…e1a0` — compare, do not assume), worktree clean after (`clean_after=yes`). Lock FREE after each step (`check-lock.sh`).

## Negative / abnormal
Any nonzero exit is the step's real exit (sentinel); no retry, no repair, no manual install. Partial S20/S30 state is left in place for inspection (never deleted by this request). If S30 refuses on `outside_root` drift, the appearing files are **not** moved or deleted by the builder.

## Not requested here
No fixture init/start, no proof, no controls. Runner/fixture bytes are not inputs to this request and may be reviewed in parallel.
