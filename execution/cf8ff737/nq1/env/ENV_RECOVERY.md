# N/Q1 v2r Phase E — environment recovery receipts (NQ1_V2R_REBUILD_GRANT, 2026-09-24)

Sandbox loss removed PG17 tooling, psql, node_modules and all retained clusters. Recovered mechanically from pinned artifacts;
every pin equals the accepted record. No cluster was created (`/home/user/pg17/clusters` is ABSENT; the fixture creates `nq1` at the PG grant).

| step | script / log | result | pins |
|---|---|---|---|
| E1 PG17 17.6 | `e1-pg17-install.sh` / `E1-pg17-install.log` | rc=0, 20:10:55–56Z | Maven sha1 `8163322358…` OK; jar `23da5a04…` OK; txz `26fa6334…` OK; postgres `23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a` OK; initdb `b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a` OK; `/home/user/pg17/PROVENANCE.txt` written (result=success) |
| E2 psql client | `e2-psql-client.sh` / `E2-psql-client.log` | rc=0, 20:11:10–23Z | apt `postgresql-client-18 18.6-0ubuntu0.26.04.1` (same package/version as the S1/S2 historical install); `/usr/bin/psql` → psql (PostgreSQL) 18.6 |
| E3 node_modules + N generate | `e3-npm-ci-generate.sh` / `E3-npm-ci-generate.log` | rc=0, 20:12:01–20:17:36Z, under `execution/test-validation.lock` (flock -n, released on exit) | package-lock `b7fed5ed…` OK; `npm ci --ignore-scripts` rc=0; `node_modules/.package-lock.json` `05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44` OK; N-only `prisma generate` (6.19.3) rc=0; `.prisma/client/index.d.ts` `92d42c56a7f199d41ea518c1f5b9a8c17f34a17f97486942f2691026a1461cf4` OK; engine `a2924eab…` OK; hidden lock unchanged after generate; `/home/user/node_modules` (209 entries, platform-owned) unchanged |
| hooks | `receipts/20-lefthook-install.txt` | rc=0 | recovered clone had only `.sample` hooks; `npx lefthook install` from the isolated tree → `pre-commit`, `commit-msg` (lefthook v2.1.9) in the shared git dir `repos/growth-project-backend/.git/hooks` |

Qualifications (C, recorded): E3 log shows `clean_after=NO` because the builder's Phase V working edits to the two owned test files were
already in the worktree during the install (not an install artifact; `git status` listed exactly those two files). The runner comment
"ISOLATED copy of the accepted R tree (not a fresh npm ci)" describes v1's method; the grant directs `npm ci` from the committed lock and the
runner's machine check is the hash, which matches (`05bc530a…`). PG17 install did not take the validation lock (download/extract only).
