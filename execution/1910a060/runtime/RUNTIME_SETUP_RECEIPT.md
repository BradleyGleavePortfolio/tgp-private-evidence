# RUNTIME_SETUP_RECEIPT — EXEC-1910A060 / RT-NEW-1 (T4 runtime setup for the S8-F binding v2)

Scope: bounded runtime setup ONLY, per SCOPE.md (Bradley reset controls), the parent's RT-NEW-1 task and the owner's
14:14 PT PG17.6 clarification. NOT run here: compiler, tests, initdb, any PostgreSQL server, bootstrap, proof, remote
writes, account operations, spending. The predecessor runtime root `execution/64e33dc7/recovery-reset` does not exist on
this host; nothing of it was revived. No old-runtime identity claim is made.

## 1. Runs (all evidence under `raw/`; drivers in this directory, applied as files, never edited under the lock)

| attempt | driver sha256 | lock | outcome |
|---|---|---|---|
| 1 (`raw/attempt1-refused-preflight/`) | ba9f6e67… | not taken | rc 74 preflight refusal: process filter matched other lanes' read-only argv containing "postgres"/"pg_ctl". No state change. |
| 2 (`raw/attempt2-partial/`) | b38971d4… | fd9 21:18:16Z → exit ~21:19Z | CLONE_OK 21:18:28Z (standalone clone created/verified), psql apt install ok, then `set -u` abort on a misnamed variable (`REC_PSQL_SHA`) before any install into the clone. No sentinel. Lock released by exit. |
| 3 (`raw/rt-setup.log`, `raw/rt-setup.sentinel`) | 4a908ed578dec19016beac211757e1129e4c7ca49662744595754e78b6a97cd0 (`rt-setup-1910a060.sh`) | fd9 21:21:24Z → 21:27:42Z (pid 15365) | **rc 0**. Clone re-verified and reused, npm ci, prisma generate check, prettier prefix, verify. |
| pg17 fetch (`raw/pg17-fetch.log`, `raw/pg17-fetch.sentinel`) | 2533d348f86022ffe3665dfdc2103021b902d59e4687f6f43f24da83be892e17 (`pg17-fetch-1910a060.sh`) | **none** (parent 14:29 PT: I/O only, without the slot; S9-A pid 18793 held it) | **rc 0** 21:31:15Z–21:31:43Z. |

Lock: `/home/user/workspace/execution/test-validation.lock`, inode 667698 (== `LOCK_ESTABLISHED.txt`), nonblocking
`flock -n` on fd 9, file never deleted/replaced/recreated. Release receipt: `raw/post-release.txt` 21:29:52Z — no
`lslocks` holder, inode 667698, no postgres/jest/tsc/npm/prisma/lefthook/prettier processes, only :22 listening
(`raw/post-release-procs.txt`: two root-owned platform code-mode `node` daemons, unrelated). `SETUP_READY.md` was the
early notice.

## 2. Source authority (exact, verified, no rebuild)
- Bundle `execution/64e33dc7/s8f/checkpoints/v1/s8f-e1ec2fec.bundle` sha256
  a69b4fc837506cf868135894d2b6f497455de8d787ae8f2e78ea9eab4364c467; `git bundle verify` OK (ref `refs/heads/exec-dace/s8f`
  → e1ec2fec, requires 1c10e2a1).
- Shared clone `/home/user/workspace/growth-project-backend` is a `blob:none` promisor clone (2228 objects missing for the
  base) and was left untouched (head 1c10e2a1 before/after). Base commit blobs were therefore fetched READ-ONLY from
  `https://github.com/BradleyGleavePortfolio/growth-project-backend.git` (`git fetch --no-tags origin 1c10e2a1…`, exit 0,
  `raw/attempt2-partial/git-fetch-base.out`); the candidate came only from the bundle.

## 3. Standalone clone (donor)
- Path `W=/home/user/workspace/worktrees/1910a060-s8f`, own `.git` (66M), NOT a shared git worktree; `git init -b main`,
  `user.name=Bradley Gleave`, `user.email=bradley@bradleytgpcoaching.com`, `core.hooksPath` unset,
  `remote.origin.pushurl=no_push://disabled-by-RT-NEW-1`, `GIT_NO_LAZY_FETCH=1` throughout. No commits made.
- HEAD e1ec2fecb71f315b6721d426ba0dacb84f304498, tree 2fe0201ff132dfdc53ea82b3f26ed0fc8d1c65d6, branch `exec1910/s8f`,
  `HEAD^` == base 1c10e2a1 (tree aa160557), author/committer Bradley Gleave <bradley@bradleytgpcoaching.com>
  2026-09-25T18:19:40Z; base..head = exactly 17 paths (`raw/changed-paths.txt`); v1 blob pins all equal; bootstrap mode
  100755; `package-lock.json` b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55 (unchanged);
  `package.json` afecdb3762df06075723dbe254a80bffe828b028bdb33576030d1ce0f936c5aa; `prisma/schema.prisma` sha256
  0eb41f9a88ef3b77266e908a5ea814206c188d1bdb031bd96d746491fee84015 = blob 2e328bbcab0c902c6adb55dfb5ee172defc5f698;
  172 migration dirs; clean and at the same HEAD/tree after setup.

## 4. Measured tool / dependency pins (1910a060 host: Ubuntu 26.04 LTS, kernel 6.1.155, 2 CPU, 7 GB)
- node `/usr/local/bin/node` v20.20.1 sha256 a03953a7b16bff002b94d6fb58ada900b68241cbcaee6efc400b20dadd36dddc (== record);
  npm 10.8.2 (`npm-cli.js` 8e5f6f3429f8cdbe693cdc29904e9d5a7b127a494bd15c804bd54c7403bfcbe7); git 2.53.0.
- psql: apt `postgresql-client-18 18.6-0ubuntu0.26.04.1` (recorded route; `apt_update_exit=0`, `apt_install_exit=0`).
  `/usr/bin/psql` → `/usr/share/postgresql-common/pg_wrapper` a200e38c89b111d3abdf26927b186fdd423bef3d84f157af0f4b65db6f8e6c94
  (== record, comparison only). **Real binary `/usr/lib/postgresql/18/bin/psql` sha256
  d1108fdb45b87f2313d7acfbb91a0a65ca97c6c2195f15d8ae9295121029ef67**, `psql (PostgreSQL) 18.6` (binding v2 pin, CB1).
- PostgreSQL 17.6 server distribution `/home/user/workspace/execution/1910a060/runtime/pg17/dist` (no initdb, no start):
  origin `https://repo1.maven.org/maven2/io/zonky/test/postgres/embedded-postgres-binaries-linux-amd64/17.6.0/embedded-postgres-binaries-linux-amd64-17.6.0.jar`,
  Maven `.sha1` 8163322358dbe4e6c2abccc90f2e543f8cfc65db (verified), jar sha256
  23da5a044b4fb7a5a081a45008c95749c873305328d73f86aefd56922ce1d29d (14,894,072 B), inner `postgres-linux-x86_64.txz`
  26fa633461a3340913015503d0783d73a28384110257e2f17d9936bdf8b067c0 (14,889,140 B); `bin/postgres`
  23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a (`postgres (PostgreSQL) 17.6`), `bin/initdb`
  b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a, `bin/pg_ctl`
  af53d826845af4679a0aaba2bda319f5e527f3b94f3794c67fa174049c9b9401; full manifest of all 1005 files
  `raw/pg17-dist-files.sha256` (sha256 2c9d8a494c6b7ba476eeadf66273d8bfb7b271f6e22d535d1555a4ece78dee51);
  `pg17/PROVENANCE.txt` `result=success`. Prebuilt artifact: no compiler/configure inputs (none built). All hashes equal
  the predecessor's recorded artifact hashes — a same-bytes statement, not a claim that the old runtime survives.
- Genuine `npm ci --no-audit --no-fund --foreground-scripts` in W (isolated `npm_config_cache=$ROOT/npm-cache`,
  `XDG_CACHE_HOME=$ROOT/xdg-cache`; platform `/home/user/node_modules` signature unchanged 5b85f7d8…): exit 0 at
  21:27:29Z, `added 1117 packages in 6m`, lifecycle scripts ran (unrs-resolver postinstall, `prisma generate`
  postinstall, `lefthook install` prepare → `sync hooks: ✔️(pre-commit, commit-msg)`); `raw/npm-ci.out` sha256
  508cd8ceef9bc930c7ba3ec204645a6a7cee0991448040131637ca9551868d31. `node_modules`: 717M, 649 top-level entries, real dir
  inside W; `node_modules/.package-lock.json` 05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44 (== prior
  donor record); package-lock unchanged. Tool versions only (no compile/test/lint): typescript 5.9.3, jest 30.4.2, ts-node
  v10.9.2, eslint 10.5.0, prisma/@prisma/client 6.19.3, lefthook 2.1.9 (checksum file `a67722ab98bad772e1311a0bf01b4416 1790371106`).
- Generated client (landed S7-L schema, blob 2e328bbc): `prisma generate` postinstall produced `.prisma/client/index.d.ts`
  9042e713ba5678c99959a345b7b18a60dfc186b2c7d890b8d9c3ed5c8f4edcc6; an explicit `npx --no-install prisma generate`
  (`raw/prisma-generate.out`, exit 0, 21:27:37Z) reproduced the identical hash (deterministic) and left the hidden lock
  unchanged. `.prisma/client/schema.prisma` b84392033ab86776533007505c31f57930307a210844067a7407ed20d25abf3e,
  `.prisma/client/index.js` 6fd5e6efd1a2e4bab7f42bda83680ec34d854fec5623123374d0e14d4c8139be, `package.json`
  f448f11010462b50dc0fb27f32531411db578fe2208808e4888aa48ea565429e, engine
  `libquery_engine-debian-openssl-3.0.x.so.node` a2924eab1c78a0a7bb67edac5738939fa10589ef073af5542f53812a22e4a7d8
  (binaryTarget debian-openssl-3.0.x, Node v20.20.1). Both index.d.ts and client schema equal the v1 binding pins.
  Client contains `model ImportNativeProvenance` and `target_kind` (CB2 greps pass read-only).
- Hooks in W (`.git/hooks`): `pre-commit` e21bece648d1a2a72fa38e1323dc61d3558e349ff25f764d1c98b494f8af06b1,
  `commit-msg` 277018c46292e87a96e872b68fc792b09f7e1359cafd7ec891ae1586387160b9 (mode 755, lefthook 2.1.9).
- Pinned prettier 3.9.9 tool prefix `/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9` (backend
  pre-commit runs `npx prettier --check`; lock has no prettier): registry metadata (`raw/registry-prettier-3.9.9.json`
  01c0d5a0…) version 3.9.9, 0 dependencies, no scripts; tarball `prettier-3.9.9.tgz` 2,801,547 B, sha256
  c3b162d30c45126873cc6338a539383e92120a390d10de78f373f42c2045b338, integrity
  sha512-Z/CJHIkdujO/OtN7nXUii0Rf3VT5SRuhjBA82Xvu2XhBUgX3nhP67T0LHceBdQLex7OOFGTox+Q5Yg8Jk2Qivg==, shasum
  09b826918c91cd4cbc80e0cbd1d2a922ff04f233 (all == record); offline `npm install --global --prefix` from the verified
  tarball (exit 0); installed tree == tarball (`raw/diff-tarball-vs-installed.txt`, diff exit 0); 56 files, manifest
  `raw/prettier-prefix-files.sha256` sha256 4ca0a333bd50b7d01830ab05b6f5017f694a16f31ccef577581913a2b463219f;
  `bin/prettier.cjs` 6e922134a3c76fd4de202959bb6aef50bde0c994148075003a15569b7197906e (== record); `prettier --version`
  → 3.9.9 directly and via `npx --no-install prettier` from W with `npm_config_prefix=<prefix> npm_config_offline=true`.
  Nothing added to package.json / lock / node_modules.

## 5. Donor-copy instructions (for S9-A and later lanes)
1. `cp -a /home/user/workspace/worktrees/1910a060-s8f/node_modules <target>/node_modules` (real copy; target's
   `package-lock.json` must hash b7fed5ed…; then expect `.package-lock.json` 05bc530a… and client index.d.ts 9042e713…).
2. Hooked-commit shell: `export npm_config_prefix=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 npm_config_offline=true`.
3. PG 17.6: `LD_LIBRARY_PATH=/home/user/workspace/execution/1910a060/runtime/pg17/dist/lib`, binaries in `pg17/dist/bin`
   (no cluster exists; any lane must initdb its own fresh data dir under its own grant).
4. This clone and its node_modules are read-only from RT-NEW-1's side from 21:27:42Z on.

## 6. Binding v2
`tgp-private-evidence/execution/64e33dc7/s8f/binding/v2/` (beside immutable v1): `s8f-pg-proof.sh`
3e43c8c8697c245700f581823816e5a43e1419f1b7739d8651d53b08b6a37f4c, `s8f-fixture.sh`
4983477330f11597de5b3350c45aaf9dd1ff0bc4278b00cec980f7d6f11e8f5f, PINS.txt, README.md, patch scripts, diffs,
tool-pins-reverify.txt, BINDING.sha256. Product pins unchanged; environment pins = the measured values above; class-C
items CB1/CB2/CB3 and the 11-test assertion added. NOT RUN; awaits dual review and a separate parent proof grant.
v1 `BINDING.sha256` re-verified 7/7 OK after v2 was written.

## 7. Blockers
None. Outbound network used: GitHub (read-only fetch of base objects), repo1.maven.org, registry.npmjs.org, Ubuntu apt
mirrors — all no-cost, no account/login, no remote writes.
