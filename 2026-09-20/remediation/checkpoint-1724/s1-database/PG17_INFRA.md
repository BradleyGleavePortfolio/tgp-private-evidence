# Isolated PostgreSQL 17.6 infrastructure (S1 + S5) — synthetic data only

Owner: S1 database lane. Installed 2026-09-20 ~16:19 UTC under `execution/heavy-validation.lock`.

## What was installed (assessed)
- Server: PostgreSQL **17.6** (matches production 17.6) from `io.zonky.test.postgres:embedded-postgres-binaries-linux-amd64:17.6.0` (Maven Central), jar sha1 verified against `.sha1` published alongside; extracted to `/home/user/pg17/dist` (bin: initdb, pg_ctl, postgres; full contrib: pgcrypto, uuid-ossp, pg_stat_statements, citext, pg_trgm, btree_gist, …). No lifecycle hooks executed; plain tar extraction.
- Client tools: Ubuntu `postgresql-client-18` (psql/pg_dump/pg_restore 18.6) via apt — v18 clients are compatible with a v17 server. Ubuntu 26.04 has no PG17 server package, hence the portable binary.
- Not installed: docker/podman (not needed), PGDG repo (no "resolute" support assumed).

## Clusters (separate data dirs, ports, superusers, DBs)
| Lane | Port | Superuser | Password | DB | Data dir |
|---|---|---|---|---|---|
| S1 | 54321 | `s1_super` | `s1_local_synthetic` | `s1_tgp` | `/home/user/pg17/clusters/s1` |
| S5 | 54325 | `s5_super` | `s5_local_synthetic` | `s5_tgp` | `/home/user/pg17/clusters/s5` |

Listen `127.0.0.1` only; unix sockets in `/home/user/pg17/run`. Tuned for the 2 vCPU/8 GB sandbox (shared_buffers 128MB, max_connections 40, fsync off — throwaway synthetic data). `pg_stat_statements` preloaded; `log_lock_waits=on`.

## Control script
```
/home/user/pg17/lane-pg.sh <s1|s5> <init|start|stop|status|url|destroy>
/home/user/pg17/lane-pg.sh s5 url   # -> postgresql://s5_super:s5_local_synthetic@127.0.0.1:54325/s5_tgp
```
`start` is idempotent and creates the lane DB if missing. Each lane may create extra databases/roles inside its own cluster (e.g. `CREATE DATABASE s5_test_x`) without touching the other lane. S5 should not touch port 54321 / `clusters/s1`.

## Rules
- Nothing here connects to Supabase/production; connection strings are local-only.
- Heavy runs (full migration replay, suites) still go through `execution/heavy-validation.lock` (flock). The clusters themselves stay running between runs; do not `destroy` the other lane's cluster.
- Important: do **not** export the bundled `dist/lib` on `LD_LIBRARY_PATH` in shells that run system `psql` (libpq 5.17 vs psql 18 symbol clash); the script scopes it to server binaries only.
