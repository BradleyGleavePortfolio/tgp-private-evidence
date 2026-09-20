# S1 R3 bounded setup + synthetic run — prepared commands (NOT executed)

Everything below waits for the parent's explicit grant after S4 releases SLOT B. Each step takes the canonical `execution/test-validation.lock` nonblocking for exactly its own duration (exit 75 if busy, never waits), logs to `execution/s1-r3/infra/logs/<step>-<utc>.log`, fails closed with its real exit code, and is idempotent (re-run detects "already present"). Nothing here touches hosted/provider/customer endpoints; the only server is a loopback PG 17.6 cluster under `/home/user/pg17/clusters/s1`.

| # | Command (cwd = `/home/user/workspace`) | Est. | Provenance / check | Output |
|---|---|---|---|---|
| 10 | `execution/s1-r3/infra/setup-10-clients.sh` | 1–2 min | Ubuntu 26.04 apt (`postgresql-client-18`, fallback 17 / unversioned); refuses a client < 17; records `dpkg-query` version | psql/pg_dump on PATH |
| 20 | `execution/s1-r3/infra/setup-20-pg17.sh` | 1–2 min | Maven Central `embedded-postgres-binaries-linux-amd64-17.6.0.jar`; Maven `.sha1` fetched AND compared to pinned `8163322358dbe4e6c2abccc90f2e543f8cfc65db`; **limitation: Maven publishes only SHA1/MD5 for this artifact — the script records the SHA256 of the jar and of the inner `postgres-linux-x86_64.txz` and of `initdb`/`postgres` so the download is byte-comparable later**; extract only; refuses if `postgres --version` ≠ 17.6 | `/home/user/pg17/dist` |
| 30 | `execution/s1-r3/infra/setup-30-npm-ci.sh` | 3–6 min (2 CPU) | In `worktrees/s1-r3` (head 7cbbb03, must be clean before and after; `node_modules/` git-ignored); refuses unless `package-lock.json` sha256 starts with parent-verified `62b05b90`; `npm ci --ignore-scripts` then explicit `prisma generate`; records prisma CLI sha256 + version, installed `.package-lock.json` sha256 | **Shared S1/S2 tree.** S2 uses read-only: `S1_PRISMA_CLI=/home/user/workspace/worktrees/s1-r3/node_modules/prisma/build/index.js` or `node /home/user/workspace/worktrees/s1-r3/node_modules/prisma/build/index.js …`. No other Prisma install. |
| 40 | `execution/s1-r3/infra/s1-fixture.sh init && execution/s1-r3/infra/s1-fixture.sh start` | <1 min | initdb PG 17.6, superuser `s1_super`/`s1_local_synthetic` (synthetic), `cluster_name='s1-disposable-pg17'`, data dir `/home/user/pg17/clusters/s1`, listen 127.0.0.1:54321, **no extra database** (R2's `s1_tgp` would now be refused as foreign); `start` prints version/cluster/datadir/addr/dbs as seen by psql | running fixture |
| 50 | `S1_PG_SUPER_URL="$(execution/s1-r3/infra/s1-fixture.sh url)" S1_PG_PORT=54321 S1_PG_DISPOSABLE_CONFIRM='DESTROY-127.0.0.1:54321/s1_rls_proof,s1_rls_proof_lock' S1_PRISMA_CLI=/home/user/workspace/worktrees/s1-r3/node_modules/prisma/build/index.js execution/s1-r3/run-proof.sh 1` | 4–8 min | wrapper rev 2: clean tree → guard offline → lock → guard preflight → required stamps → `timeout --foreground 1800` harness; real exit preserved; 124 = TIMEOUT (not a verdict) | `execution/s1-r3/proof-run-01-head-7cbbb03.log` + `-harness-detail.log` |
| 60 | `execution/s1-r3/infra/s1-fixture.sh stop` (leave data dir for a rerun; `destroy` only if parent wants a fresh cluster) | — | — | fixture stopped, lock free |

Total DB/heavy time requested ≈ 12–20 min in one slot; steps 10–30 could be granted separately from 40–50 if the parent prefers to split install from execution. Steps 10–30 hold the lock only while installing; between steps the lock is free.

## Not requested / not done
- No S5 run (S5 runner reset guard under repair; S5 uses a different dependency graph and would need its own tree).
- No PG15. The guard admits PG 17.x only; PG15 CI remains a separate gate.
- No push, PR, hosted access, activation.

## If step 50 fails
The wrapper preserves the failed log (`proof-run-NN-…`); the harness prints `FAIL` lines with expected/actual. I will report the failure as-is, classify (harness-design vs. guard vs. environment vs. source defect), and only then propose a source change on top of the frozen 7cbbb03 — never edit the frozen head or reuse a stale log.
