# Recreate the isolated synthetic PostgreSQL 17.6 fixture (no sandbox paths required)

Purpose: run `test/db/s1-rls-close-public-exposure.sh` (and any S5 validation) against a disposable
PostgreSQL **17.6** server — the production major/minor — on a machine that has no PG17 package
(Ubuntu 26.04 ships only PG18). Nothing here touches Supabase, Fly, or real data. All passwords are
synthetic fixtures; the server listens on 127.0.0.1 only.

## 1. Server binaries (portable, no root)
```
mkdir -p ~/pg17 && cd ~/pg17
curl -fsSLO https://repo1.maven.org/maven2/io/zonky/test/postgres/embedded-postgres-binaries-linux-amd64/17.6.0/embedded-postgres-binaries-linux-amd64-17.6.0.jar
curl -fsSLO https://repo1.maven.org/maven2/io/zonky/test/postgres/embedded-postgres-binaries-linux-amd64/17.6.0/embedded-postgres-binaries-linux-amd64-17.6.0.jar.sha1
echo "$(cat embedded-postgres-binaries-linux-amd64-17.6.0.jar.sha1)  embedded-postgres-binaries-linux-amd64-17.6.0.jar" | sha1sum -c -
# expected sha1: 8163322358dbe4e6c2abccc90f2e543f8cfc65db
unzip -o embedded-postgres-binaries-linux-amd64-17.6.0.jar postgres-linux-x86_64.txz
mkdir -p dist && tar -xJf postgres-linux-x86_64.txz -C dist
dist/bin/postgres --version      # -> postgres (PostgreSQL) 17.6
```
The jar is a plain zip wrapper around `postgres-linux-x86_64.txz` (initdb, pg_ctl, postgres, full contrib).
No installer/lifecycle hooks are executed.

## 2. Client tools (psql / pg_dump)
Any psql/pg_dump >= 17 works; on Ubuntu 26.04: `sudo apt-get install -y postgresql-client-18`.
Do **not** put `dist/lib` on `LD_LIBRARY_PATH` for the system psql (libpq symbol clash).
pg_dump >= 17.6/18 emits random `\restrict` tokens; the harness normalises them.

## 3. Lane clusters
`lane-pg.sh` (this directory; copy to `~/pg17/lane-pg.sh`, `chmod +x`) — edit `PGHOME`/paths at the top if
you did not use `~/pg17`:
```
~/pg17/lane-pg.sh s1 init && ~/pg17/lane-pg.sh s1 start     # port 54321, superuser s1_super / s1_local_synthetic, db s1_tgp
~/pg17/lane-pg.sh s5 init && ~/pg17/lane-pg.sh s5 start     # port 54325, superuser s5_super / s5_local_synthetic, db s5_tgp
~/pg17/lane-pg.sh s1 status | url | stop | destroy
```
Settings: listen 127.0.0.1, unix socket dir `~/pg17/run`, shared_buffers 128MB, max_connections 40,
fsync off (throwaway data), `pg_stat_statements` preloaded, `log_lock_waits=on`.

## 4. Run the S1 proof
From a checkout of the backend at the candidate head (`git clone` + `git fetch <bundle>`; see manifest):
```
npm ci --ignore-scripts && npx prisma generate      # Prisma 6.19.3 CLI + client
S1_PG_SUPER_URL='postgresql://s1_super:s1_local_synthetic@127.0.0.1:54321/postgres' \
  test/db/s1-rls-close-public-exposure.sh s1_rls_proof | tee proof.log
```
Expected last line: `== 68 passed, 0 failed (server 17.6, head <short-sha>)`. The harness creates/drops
`s1_rls_proof` and `s1_rls_proof_lock`, creates the fixture roles from
`test/db/_support/supabase-like-bootstrap.sql` (postgres/authenticator/anon/authenticated/service_role,
synthetic passwords, Supabase-like default privileges) plus a scratch `s1_probe` role, and writes a detail
log next to the summary (`S1_PROOF_LOG=` to choose the path).

## 5. Run the serving-role probe locally (packet validation only)
```
DATABASE_URL='postgresql://postgres:postgres_local_synthetic@127.0.0.1:54321/s1_rls_proof' DIRECT_URL=x \
  node -e "$(cat execution/s1-database/whoami-db-role.js)"
```
