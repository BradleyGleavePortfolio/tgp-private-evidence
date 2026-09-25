# EXEC-64E33DC7 replacement runtime setup receipt (tooling + donor only)

Grant: `64e33dc7/RUNTIME_SETUP_GRANT.md`. Executor: `replacement_runtime_setup_muge72qn`. Driver: `runtime/rt-setup.sh`, SHA-256 `f6801d30984854453a47e6a376d282f8e1a519ce585505ce42f07e480dc1f09e`. It uses the pins and refusal rules (rc 70) from `cf8ff737/b-drain/pg-tooling/b-pg-env-recovery.sh` and `cf8ff737/nq1/env/e3-npm-ci-generate.sh`, with the deltas the grant requires: a fresh namespace; a detached environment worktree; a real `npm ci` with lifecycle scripts running (no `--ignore-scripts`); and one lock held for the whole run. It ran once, with the command `timeout -k 30 2400`, launched in the background (`raw/LAUNCH.txt`, pid 10506). There was no retry and no edit after the run.

**Result: RC=0 STAGE=done. Start 2026-09-25T03:23:02Z, end 03:29:43Z.** Raw log: `raw/rt-setup.log`.

## Canonical slot and processes
- Preflight at 03:23:02Z: `/home/user/workspace/execution/test-validation.lock` was ABSENT. No postgres, pg_ctl, initdb, jest, tsc, npm or prisma process was running. Only :22 was listening, so 55641 and 55642 were free. The builder worktrees `64e33dc7-s7l` and `64e33dc7-s8c` already existed. This run did not write to them.
- The driver acquired the lock with `flock -n` on fd9 (append-open, inode 691716) at 03:23:02Z. It held the lock for the whole run and released it when the process exited at 03:29:43Z. The lock file was left in place and not deleted.
- Post-run in the driver: no relevant processes, `postgres` count 0, `clusters` absent.
- Parent's observation: rc0 at 03:29:43Z, no `lslocks` entry, no test or server started. By parent instruction, no further checks were run after exit.

## Toolchain
- CI requirement: `ci.yml` uses `actions/setup-node@v6` with node-version `'20'`, then `npm ci`, then `npx prisma generate`. The Dockerfile uses `node:20-slim`. The accepted tree has no `engines`, `.nvmrc` or `.npmrc`. The existing platform Node satisfies this, so no other Node was installed.
- node: `/usr/local/bin/node` v20.20.1, sha256 `a03953a7b16bff002b94d6fb58ada900b68241cbcaee6efc400b20dadd36dddc`.
- npm: `/usr/local/bin/npm` resolves to `/usr/local/lib/node_modules/npm/bin/npm-cli.js`, version 10.8.2, sha256 `8e5f6f3429f8cdbe693cdc29904e9d5a7b127a494bd15c804bd54c7403bfcbe7`.
- Other: git 2.53.0, OpenSSL 3.5.5, Ubuntu 26.04 LTS.

## PostgreSQL tooling (reusable, no cluster)
- Server location: `/home/user/workspace/execution/64e33dc7/recovery-reset/pg17/dist`. Provenance file: `.../pg17/PROVENANCE.txt` (result=success). Download directory: `.../pg17/download`.
- Maven sha1 `8163322358dbe4e6c2abccc90f2e543f8cfc65db` matches the pin.
- jar `23da5a044b4fb7a5a081a45008c95749c873305328d73f86aefd56922ce1d29d` (14894072 B) matches the pin.
- txz `26fa633461a3340913015503d0783d73a28384110257e2f17d9936bdf8b067c0` (14889140 B) matches the pin.
- `postgres --version` reports 17.6 (run with `LD_LIBRARY_PATH=<dist>/lib`).
- Binary hashes:
  - `bin/postgres` `23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a` matches the pin.
  - `bin/initdb` `b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a` matches the pin.
  - `bin/pg_ctl` `af53d826845af4679a0aaba2bda319f5e527f3b94f3794c67fa174049c9b9401` matches the recorded prefix.
- Full file manifest: `raw/pg17-dist-files.sha256` (1005 files, manifest sha `2c9d8a494c6b7ba476eeadf66273d8bfb7b271f6e22d535d1555a4ece78dee51`).
- Client: installed by the recorded apt route as `postgresql-client-18 18.6-0ubuntu0.26.04.1`.
  - `/usr/bin/psql` points to `pg_wrapper` and reports psql 18.6, sha256 `a200e38c89b111d3abdf26927b186fdd423bef3d84f157af0f4b65db6f8e6c94` (same as the historical record). pg_dump is also 18.6.
  - This is a system package install, which the grant allows by the recorded route.
- Nothing was started: no initdb, server, cluster, database, migration or bootstrap. `clusters` is absent.

## Environment worktree and dependency donor
- Worktree: `/home/user/workspace/worktrees/64e33dc7-env`, detached HEAD `93389265a846095b846fa8f1fb0dad782fb6ee9f`, tree `a315dd651b8c54c2e82f2260fcc6058f0d13b64a`. It was clean before and after the install.
- Input identities:
  - `package-lock.json` `b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55`
  - `package.json` `afecdb3762df06075723dbe254a80bffe828b028bdb33576030d1ce0f936c5aa`
  - `prisma/schema.prisma` `77f33bcdc36802f8e1d52553d011f546f56f757cacb391f23436ab266a148589` (same as the S8-B record)
- Install run: `npm ci --no-audit --no-fund --foreground-scripts`, rc 0. It added 1117 packages in about 6 minutes (full output: `raw/npm-ci.out`, sha `fe6c71ac…`).
  - Both lifecycle scripts really ran: `postinstall` (prisma generate) and `prepare` (lefthook install).
  - The npm and XDG caches were kept isolated under `recovery-reset/npm-cache` and `recovery-reset/xdg-cache`.
- Lock inside node_modules: `node_modules/.package-lock.json` `05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44`. It matches the prior record and did not change after generate.
- Generated client: `npx prisma generate` ran as the CI step, rc 0 (`raw/prisma-generate.out`). prisma and @prisma/client are 6.19.3; engines hash `c2990dca591cba766e3b7ef5d9e8a84796e47ab7`. Output hashes:
  - `node_modules/.prisma/client/index.d.ts` `b6716a865a705ffc0efab30ed88cd163b461e5344ad64e5926a0dff078b49f44`. It is the same after postinstall and after the CI generate, and matches S8-B PINS `NM_CLIENT`.
  - `index.js` `dc2c49166b1fff3660828714be3e7af4ae16cac82d9ce8ad31a5472323ffc573`
  - `schema.prisma` `ded50406332707e4fd473a75e0a5407d54eb309085a99edcaaceaa05cb25b249`
  - `package.json` `c91d7b4f2b1a22a9e614e87ba74bd7ca2d110895ef96733e73aa5aa6559532e8`
  - engine `libquery_engine-debian-openssl-3.0.x.so.node` `a2924eab1c78a0a7bb67edac5738939fa10589ef073af5542f53812a22e4a7d8`
- Other versions (recorded only; nothing was compiled or tested): TypeScript 5.9.3, jest 30.4.2. node_modules has 649 top-level entries and uses 717M.
- Platform `/home/user/node_modules` is unchanged: 209 entries, listing sha `cca57efd2bcc74b23fa5f57ecb0d1f73018e5a12a74e4ffe763d93525f55f10d` before and after.

## Hooks
- The `prepare` script ran `lefthook install` for real (lefthook 2.1.9): "sync hooks: commit-msg, pre-commit". `core.hooksPath` is unset.
- Hooks were installed in the shared git directory `/home/user/workspace/growth-project-backend/.git/hooks`, which both builder worktrees use:
  - `pre-commit` `3b741de3dd006d6265c6ca6698b7b5ce8aa9a2a5ba2743a8615d85e72b4a140d` (mode 755)
  - `commit-msg` `71029ce88d76d5b885e12f978093ad3e046e93f5c5fc629b6fbba635d9f8a61b` (mode 755)
- Checksum file `info/lefthook.checksum`: `a67722ab98bad772e1311a0bf01b4416 1790306596`.
- Before the run, that directory held only `.sample` files.

## Donor-copy instructions (for builders, only after the parent relays the slot)
1. Take `execution/test-validation.lock` with `flock -n` and never delete it.
2. Confirm that `<builder-wt>/node_modules` is absent, then copy the donor into the builder worktree:
   `cp -a /home/user/workspace/worktrees/64e33dc7-env/node_modules <builder-wt>/node_modules`
   Make a real copy. Do not use symlinks, `cp -l` or hardlinks, because a later generate would change the donor.
3. Verify that `<builder-wt>/node_modules/.package-lock.json` is `05bc530a…` and that the builder's `package-lock.json` is still `b7fed5ed…`. If either lockfile differs, stop and do a fresh `npm ci` instead.
4. If the builder's `prisma/schema.prisma` differs from `77f33bcd…` (for example S7-L schema work), run `npx prisma generate` inside the builder copy and record the new `index.d.ts`. Never run it in the donor.
5. Hooks are already installed in the shared git directory, and the hook scripts find lefthook through the copied node_modules. Do not use `--no-verify`.
6. For PG use `PG=/home/user/workspace/execution/64e33dc7/recovery-reset/pg17/dist`: call `$PG/bin/{initdb,pg_ctl,postgres}` with `LD_LIBRARY_PATH=$PG/lib`, and use the client at `/usr/bin/psql` (18.6).
7. New proofs create their own fresh data and socket directories on ports 55641 and 55642. They must not use `pg17/dist` as a data root and must not reuse historical `/home/user/pg17` paths.
8. Leave the donor worktree read-only.

## Qualifications
- One of my monitoring shell calls (`sleep`/`tail`) was reported by the tool as timed out at about 630 s. It was a read-only poll, and the background driver completed normally (rc 0).
- The Prisma "update available 8.0.0-rc" banner is only an informational message; nothing was upgraded.
- No product, dependency or lockfile edits were made. There was no commit or push, and no test, compile or lint was run.

## Files (runtime/)
- `rt-setup.sh`
- `raw/LAUNCH.txt` `0341463c…`
- `raw/launcher.out` `0f17607e…`
- `raw/rt-setup.log` `e00740b5892260b4a50851e5048af7d5637f35e079041274410130deed7befa0`
- `raw/rt-setup.sentinel` `2de1e794…` (`RC=0 STAGE=done END=2026-09-25T03:29:43Z`)
- `raw/npm-ci.out` `fe6c71ac…`
- `raw/prisma-generate.out` `983816e5…`
- `raw/pg17-dist-files.sha256` `2c9d8a49…`
- `MANIFEST.sha256`
