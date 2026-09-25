# RT-NEW-1 SETUP READY — heavy slot RELEASED (early notice for the parent / S9-A relay)

- Driver: `rt-setup-1910a060.sh` (sha256 4a908ed578dec19016beac211757e1129e4c7ca49662744595754e78b6a97cd0), attempt 3, pid 15365,
  START 2026-09-25T21:21:24Z → `END rc=0 stage=done 2026-09-25T21:27:42Z`. Sentinel `raw/rt-setup.sentinel`.
- Lock: `/home/user/workspace/execution/test-validation.lock` inode 667698 (matches LOCK_ESTABLISHED), taken with
  nonblocking `flock -n` on fd 9 at 21:21:24Z (holder pid 15365 observed by `lslocks`), released by process exit at
  21:27:42Z; file never deleted/replaced. Post-release check 21:29:52Z: `lslocks` shows no holder, inode still 667698,
  no postgres/jest/tsc/npm/prisma/lefthook/prettier processes, only :22 listening (`raw/post-release.txt`; the two
  `node` pids listed in `raw/post-release-procs.txt` are the platform's root-owned code-mode daemon, not ours).
- Attempts 1 and 2 (preserved under `raw/attempt1-refused-preflight/`, `raw/attempt2-partial/`): 1 = preflight refusal
  (rc 74) from an over-broad process filter (other lanes' read-only argv mentioned "postgres"); no lock taken, no state.
  2 = took the lock 21:18:16Z, created and verified the clone (CLONE_OK 21:18:28Z), installed postgresql-client-18, then
  died on an unbound-variable bug in the client stage (lock released by exit ~21:19Z; no sentinel). Attempt 3 re-verified
  and reused that clone (identity, HEAD, branch, no node_modules), then completed all stages.

## For S9-A (A-NEW-1)
1. Donor `node_modules` (genuine `npm ci --foreground-scripts`, lifecycle scripts ran: unrs-resolver postinstall,
   `prisma generate` postinstall, `lefthook install` prepare; `added 1117 packages in 6m`):
   `/home/user/workspace/worktrees/1910a060-s8f/node_modules` (717M, 649 top-level entries, real dir inside the clone).
   - `package-lock.json` sha256 b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55 (unchanged, expected)
   - `node_modules/.package-lock.json` sha256 05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44 (== prior record)
   - Generated client: from `prisma/schema.prisma` blob 2e328bbcab0c902c6adb55dfb5ee172defc5f698 (sha256 0eb41f9a…, the
     landed S7-L schema at 1c10e2a1 == e1ec2fec; S8-F changes no prisma file), Prisma 6.19.3, binaryTarget debian-openssl-3.0.x:
     `.prisma/client/index.d.ts` 9042e713ba5678c99959a345b7b18a60dfc186b2c7d890b8d9c3ed5c8f4edcc6 (postinstall == explicit
     `prisma generate` rerun, deterministic; == v1 binding pin), `.prisma/client/schema.prisma`
     b84392033ab86776533007505c31f57930307a210844067a7407ed20d25abf3e (== v1 pin), `.prisma/client/index.js`
     6fd5e6efd1a2e4bab7f42bda83680ec34d854fec5623123374d0e14d4c8139be, engine
     `libquery_engine-debian-openssl-3.0.x.so.node` a2924eab1c78a0a7bb67edac5738939fa10589ef073af5542f53812a22e4a7d8.
   - Copy with `cp -a` (real copy). RT-NEW-1 will not modify this tree further (read-only from now on; clone stays clean at e1ec2fec).
2. Isolated prettier 3.9.9 prefix: `/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9`
   (registry metadata verified, tarball sha256 c3b162d30c45126873cc6338a539383e92120a390d10de78f373f42c2045b338 == record,
   integrity sha512-Z/CJHIkd…, offline `npm install --global --prefix` from the verified tarball; installed tree == tarball
   (diff exit 0); 56 files, manifest sha256 4ca0a333bd50b7d01830ab05b6f5017f694a16f31ccef577581913a2b463219f
   (`raw/prettier-prefix-files.sha256`); `bin/prettier.cjs` 6e922134… == record; `npx --no-install prettier --version` → 3.9.9
   from the clone with `npm_config_prefix=<prefix> npm_config_offline=true`). Nothing added to package.json/lock/node_modules.
3. Also present: psql via apt `postgresql-client-18 18.6-0ubuntu0.26.04.1` (`/usr/bin/psql` → pg_wrapper a200e38c… == record;
   real binary `/usr/lib/postgresql/18/bin/psql` sha256 d1108fdb45b87f2313d7acfbb91a0a65ca97c6c2195f15d8ae9295121029ef67).
   Node /usr/local/bin/node v20.20.1 sha256 a03953a7… (== record), npm 10.8.2. Hooks installed in the clone by lefthook 2.1.9
   (pre-commit e21bece6…, commit-msg 277018c4…, core.hooksPath unset).

## Not done under the slot (by design)
PG 17.6 server distribution (download + sha verify + extract only, no lock; separate `pg17-fetch-1910a060.sh`, running
after this release per parent 14:19/14:29 PT). No compiler, tests, initdb, PG server, bootstrap or proof ran.
