# S1 milestone 01 — PG 17.6 server infrastructure ready (16:19 UTC)

**Server is PostgreSQL 17.6 (exact production minor), not 18.** `SELECT version()` on both clusters returns
`PostgreSQL 17.6 on x86_64-pc-linux-gnu`. Only the *client* tools (psql/pg_dump 18.6) come from Ubuntu;
Ubuntu 26.04 has no PG17 server package, so the server is the official 17.6 build packaged by
zonky `embedded-postgres-binaries-linux-amd64:17.6.0` (Maven Central, sha1 verified). Full contrib present.

| Lane | URL (local only, synthetic) |
|---|---|
| S1 | `postgresql://s1_super:s1_local_synthetic@127.0.0.1:54321/s1_tgp` |
| S5 | `postgresql://s5_super:s5_local_synthetic@127.0.0.1:54325/s5_tgp` |

Control: `/home/user/pg17/lane-pg.sh <s1|s5> <start|stop|status|url>`. Details: `execution/s1-database/PG17_INFRA.md`.
S5 can start preparing tests against port 54325 now; each lane may create its own databases/roles inside its own cluster.

Next for S1: caller/role mapping from source (PrismaService RLS chain, release.sh migration path), then the smallest
caller-compatible repair candidate for the 18 relations + partition + mutable search_path, tested on the S1 cluster.
