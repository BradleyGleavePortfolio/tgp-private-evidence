# Formatter tooling receipt: isolated prettier@3.9.9 (tooling only)

- **Grant:** `64e33dc7/FORMATTER_TOOLING_GRANT.md`.
- **Executor:** `replacement_runtime_setup_muge72qn`.
- **Driver:** `runtime/formatter/fmt-tool.sh`, SHA-256 `4f92c3810838adc4dce478ffc3a6a639388978c2b317e0f33813eda564cb8aef`.
- **Run:** once, `timeout -k 30 600`, launched in the background (pid 24744, driver pid 24746).
- **Result: RC=0 STAGE=done, 2026-09-25T04:23:33Z to 04:23:36Z.**
- **Raw log:** `raw/fmt-tool.log`.

## Slot
- **Before the run:** lock file present (inode 691716), no holder. No relevant process (postgres, jest, tsc, npm, npx, prisma, prettier, lefthook).
- **Held:** the driver process itself took `flock -n` on fd9. No separate holder. `lslocks` inside the run showed only holder `24746`.
- **Released:** on driver exit at 04:23:36Z. The lock file was kept, not deleted.
- **Post-exit check (04:24:03Z, `raw/post-release.txt`):** `lslocks` shows no entry for test-validation, the driver is not alive, and the inode is unchanged.

## Registry pin
- **Exact version document:** `https://registry.npmjs.org/prettier/3.9.9`, raw copy `raw/registry-prettier-3.9.9.json` (sha256 `01c0d5a0…66b1`). An isolated `npm view` gives the same values (`raw/npm-view-prettier-3.9.9.json`).
- **Tarball URL:** `https://registry.npmjs.org/prettier/-/prettier-3.9.9.tgz`.
- **integrity:** `sha512-Z/CJHIkdujO/OtN7nXUii0Rf3VT5SRuhjBA82Xvu2XhBUgX3nhP67T0LHceBdQLex7OOFGTox+Q5Yg8Jk2Qivg==`.
- **shasum:** `09b826918c91cd4cbc80e0cbd1d2a922ff04f233`.
- **Package contents:** 0 dependencies, no install scripts.
- **Fetched tarball:** 2801547 B, sha256 `c3b162d30c45126873cc6338a539383e92120a390d10de78f373f42c2045b338`. Its sha512 and sha1 both match the metadata. Its `package.json` version is 3.9.9.
- **Tarball location:** `/home/user/workspace/execution/64e33dc7/recovery-reset/tools/download/prettier-3.9.9/prettier-3.9.9.tgz`.

## Installed tool
- **Prefix:** `/home/user/workspace/execution/64e33dc7/recovery-reset/tools/prettier-3.9.9`. It uses the npm global layout, created by `npm install --global --prefix <P> --offline <verified tgz>` (exit 0, "added 1 package"). The npm cache was isolated at `recovery-reset/tools/npm-cache-prettier-3.9.9`.
  - `<P>/lib/node_modules/prettier`: `package.json` version 3.9.9, sha256 `8453a79e…1c30`. `diff -r` against the extracted verified tarball returned 0, so the files are byte-identical.
  - `<P>/bin/prettier` is a relative symlink to `../lib/node_modules/prettier/bin/prettier.cjs`. That file has sha256 `6e922134a3c76fd4de202959bb6aef50bde0c994148075003a15569b7197906e`, which equals the historical recorded launcher hash.
  - **Manifests:** `raw/prefix-files.sha256` covers 56 files (sha `4ca0a333bd50b7d01830ab05b6f5017f694a16f31ccef577581913a2b463219f`). `raw/prefix-entries.txt` lists files and symlinks (sha `51bd770a…9264851`).
- **Version checks (the only commands run with the tool):**
  - `<P>/bin/prettier --version` returned `3.9.9`, exit 0.
  - From a neutral directory (`recovery-reset/tools`), `npm_config_prefix=<P> npm_config_offline=true npx --no-install prettier --version` returned `3.9.9`, exit 0.
- **Nothing else was touched:**
  - Platform `/home/user/node_modules`: signature `cca57efd…f10d` before and after.
  - Donor worktree:
    - `.package-lock.json` is `05bc530a…` before and after.
    - It still has 649 top-level entries in `node_modules`.
    - It has no `.bin/prettier`.
    - It is clean at HEAD `93389265`.
  - No builder worktree or tracked file was written. No formatting, test, compile or PG action was run.

## How `npx prettier` resolves this pin offline
In npm 10.8.2, `npx` looks in two places, in this order (`libnpmexec/lib/index.js`, lines 151–156):
1. `node_modules/.bin/<cmd>`, walking up from the current directory.
2. `${npm prefix}/bin/<cmd>`, where the npm prefix is taken from `npm_config_prefix`.

Only if both miss does it try to install. The backend lock contains no Prettier, and neither the donor copy nor `/home/user/node_modules/.bin` has a prettier. So setting `npm_config_prefix` makes the existing lefthook command `npx prettier --check {staged_files}` resolve to this pinned binary. Nothing is added to any `node_modules`, `package.json` or lockfile.

## Builder-local copy instructions (under the builder's own relayed slot)
1. Take `execution/test-validation.lock` with `flock -n` in the process that does the work, and never delete it. Pick a fresh builder-owned directory `B` under `recovery-reset/` that is not a worktree, for example `recovery-reset/<lane>/tools/prettier-3.9.9`. Confirm `B` is absent.
2. Copy the prefix: `cp -a /home/user/workspace/execution/64e33dc7/recovery-reset/tools/prettier-3.9.9 "$B"`. `cp -a` keeps the relative `bin/prettier` symlink.
3. Verify the copy:
   - `(cd "$B" && sha256sum -c /home/user/workspace/tgp-private-evidence/execution/64e33dc7/runtime/formatter/raw/prefix-files.sha256)` passes for all 56 files.
   - `readlink "$B/bin/prettier"` prints `../lib/node_modules/prettier/bin/prettier.cjs`.
4. In the shell that runs the genuine hooked commit, set `export npm_config_prefix="$B" npm_config_offline=true`. Then, inside the builder worktree, `npx --no-install prettier --version` must print `3.9.9` before you commit.
5. Commit normally with `git commit`, so lefthook runs `npx prettier --check`. Do not use `--no-verify`. Do not add `prettier` to `package.json`, the lockfile or `node_modules/.bin`, and do not run `npm i` or `npm i -g` without `--prefix`.
6. While `npm_config_prefix` is set, run no global npm commands except `npx`. Unset it after the commit.

## Files (runtime/formatter/)
- `fmt-tool.sh`
- `FORMATTER_TOOLING_RECEIPT.md`
- `MANIFEST.sha256`
- `raw/`:
  - `LAUNCH.txt`
  - `launcher.out`
  - `fmt-tool.log`
  - `fmt-tool.sentinel` (`RC=0 STAGE=done END=2026-09-25T04:23:36Z`)
  - `registry-prettier-3.9.9.json`
  - `npm-view-prettier-3.9.9.json`
  - `npm-install.out`
  - `diff-tarball-vs-installed.txt` (empty)
  - `prefix-files.sha256`
  - `prefix-entries.txt`
  - `post-release.txt`

There was no commit and no push; the parent publishes.
