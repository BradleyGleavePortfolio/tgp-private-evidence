# C1 PG proof — environment state and minimum recovery inputs (NOT executed)

Observed 2026-09-24 ≈06:09Z, read-only (`ls`, `stat`, `command -v` only): this fresh sandbox has **no** PostgreSQL 17.6 distribution (`/home/user/pg17` absent — no `dist/`, no `clusters/s5`, no `clusters/c1-builder`, no `PROVENANCE.txt`) and **no** `/usr/bin/psql`. The S5 cluster recorded in `PINS.txt` (conf `2b6758f5…`, pg_control `09ba3f27…`) therefore does not exist here; its absence is recorded as-is and it is **not** reconstructed. `c1-pg-proof.sh` treats an absent S5 cluster as `s5_cluster=ABSENT` at preflight and requires it to still be absent at post.

Nothing below was run: no install, download, build, probe, cluster, or process. Environment recovery is the next heavy owner's grant.

## Recorded exact provenance (S1 run 4 → S2 setup, copied to `recorded-inputs/`)

| Input | Recorded value |
|---|---|
| Server artifact | `https://repo1.maven.org/maven2/io/zonky/test/postgres/embedded-postgres-binaries-linux-amd64/17.6.0/embedded-postgres-binaries-linux-amd64-17.6.0.jar` |
| Maven SHA1 (only digest Maven publishes) | `8163322358dbe4e6c2abccc90f2e543f8cfc65db` |
| jar sha256 / bytes | `23da5a044b4fb7a5a081a45008c95749c873305328d73f86aefd56922ce1d29d` / 14 894 072 |
| inner `postgres-linux-x86_64.txz` sha256 / bytes | `26fa633461a3340913015503d0783d73a28384110257e2f17d9936bdf8b067c0` / 14 889 140 |
| `dist/bin/postgres` sha256 | `23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a` |
| `dist/bin/initdb` sha256 | `b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a` |
| `dist/bin/pg_ctl` sha256 (16-char pin only, PINS.txt) | `af53d826845af467…` |
| Server version string | `postgres (PostgreSQL) 17.6` (`server_version_num` 170006) |
| Install location | `/home/user/pg17/dist` (real path, not a symlink); dist ships initdb, pg_ctl, postgres only — no psql/createdb |
| Recorded installer | `setup-20-pg17.sh` sha256 `96a2a44340a56b5d4164f4a9081b5e0549eb5c8bea2066985bcc777b4916c5b0` (+ `_common.sh` `af881779…`), log `setup-20-pg17-20260921T235211Z.log` exit 0, 2026-09-21T23:52:11–13Z |
| Client | Ubuntu apt `postgresql-client-18` `18.6-0ubuntu0.26.04.1` → `/usr/bin/psql` (psql 18.6; PINS records sha `a200e38c89b111d3…`) via `setup-10-clients.sh` sha256 `622f1997…`, log exit 0 |

## Minimum recovery commands (for the next heavy owner; run under the canonical lock; each step refuses on any pin mismatch)

1. Client: `bash recorded-inputs/setup-10-clients.sh` — or its direct equivalent `sudo -n apt-get update -qq && DEBIAN_FRONTEND=noninteractive sudo -n apt-get install -y -qq --no-install-recommends postgresql-client-18`; accept only `psql --version` major ≥ 17 (18.6 recorded). Note: `_common.sh` resolves `ROOT` from its own location and expects `execution/s2-composition`-style paths for logs; the next owner should either copy `recorded-inputs/*.sh` into its own packet dir with `_common.sh` alongside or run the direct equivalents and record the raw exits.
2. Server: `bash recorded-inputs/setup-20-pg17.sh` — downloads the jar (bound 300 s), verifies Maven SHA1 = pinned, jar sha256 = `23da5a04…`, txz sha256 = `26fa6334…`, extracts to `/home/user/pg17/dist`, verifies `postgres`/`initdb` sha256 = recorded, writes `/home/user/pg17/PROVENANCE.txt` with `result=success`. Any mismatch exits 70 without writing provenance.
3. Verify (read-only) before any runtime grant: `sha256sum /home/user/pg17/dist/bin/{postgres,initdb,pg_ctl}`, `LD_LIBRARY_PATH=/home/user/pg17/dist/lib /home/user/pg17/dist/bin/postgres --version`, `/usr/bin/psql --version`, `readlink -f /home/user/pg17`. `c1-pg-proof.sh` re-checks the postgres/initdb hashes and the 17.6 version at its preconditions and refuses (rc 70) otherwise.

No S5 cluster is to be recreated; no other environment change is needed (worktree `s7-c1` already carries jest 30.4.2, ts-node 10.9.2, and a generated Prisma client with `ImportIntent`).
