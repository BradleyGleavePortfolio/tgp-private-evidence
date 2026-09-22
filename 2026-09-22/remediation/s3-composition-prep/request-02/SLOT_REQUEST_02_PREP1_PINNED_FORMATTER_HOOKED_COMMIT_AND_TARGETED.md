# SLOT_REQUEST_02 — S3-INTO-S1S2-PREP-1: pinned formatter tooling, native setup, hook-enabled merge commit, targeted validation

Supersedes SLOT_REQUEST_01 (kept immutable) per parent disposition in `execution/VALIDATION_PREPARATION_20260922.md` §"S3 native-tooling preparation disposition". Nothing below has been run; no install/probe is granted by this document. Every step waits for a named grant after S2's real proof.

Non-negotiables carried: no `--no-verify` / `LEFTHOOK=0` / `LEFTHOOK_EXCLUDE` / `commit-tree` bypass; no `npx` fetch during hooks; no product `package.json`/`package-lock.json` change; no fourth product-file edit; stop at the first unexplained failure, preserve raw exit, no silent retry; never `git merge --abort`.

## 0. Fixed identities (unchanged from REPORT.md / SLOT_REQUEST_01)
- worktree `W=/home/user/workspace/worktrees/s3-composition-prep`, branch `execute/20260922-s3-into-s1s2-prep`; HEAD `d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c`; `.git/MERGE_HEAD` `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06`; public base `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`
- staged index tree `78a4f0e8c22e9b9e902bbaae0b9f5623b9fbfa69` — `git write-tree` must print this before and after every step; product lock blob `354de3dae19449970497da6e4d87f0a1225a8f43` (sha256 `b7fed5ed…9c55`), `package.json` blob `656d11a2…`, `lefthook.yml` blob `54d03749…` (all = S3 5c7b42b3). Application-lock provenance is §1 of SLOT_REQUEST_01 and is not extended by anything here.
- Output root `O=/home/user/workspace/execution/s3-composition-prep/slot-02/<UTC>`; logs `$O/logs/NN-<label>.log`.

## 1. Lock, attribution, bounds (all steps)
- Canonical lock only: `execution/test-validation.lock`, non-blocking. Pattern for every step (no wrapper script; exit code is the command's own):
```
cd "$W"; LOCK=/home/user/workspace/execution/test-validation.lock
exec 9>"$LOCK"; flock -n 9 || { echo "lock held; not waiting" ; exit 75; }
echo "S3-PREP1 slot-02 <label> pid=$$ start=$(date -u +%FT%TZ)" >> "$LOCK.holders"
{ echo "label=<label> head=$(git rev-parse HEAD) merge_head=$(cat .git/MERGE_HEAD 2>/dev/null) write_tree=$(git write-tree) node=$(node -v) npm=$(npm -v) NODE_OPTIONS='${NODE_OPTIONS:-}' npm_config_offline='${npm_config_offline:-}' loadavg='$(cat /proc/loadavg)' utc=$(date -u +%FT%TZ)"; echo "cmd: <exact command>"; } > "$O/logs/NN-<label>.log"
timeout --kill-after=30 <T> <exact command> >> "$O/logs/NN-<label>.log" 2>&1; rc=$?
echo "exit=$rc (124=timeout,137=killed) utc=$(date -u +%FT%TZ) write_tree_after=$(git write-tree)" >> "$O/logs/NN-<label>.log"
echo "S3-PREP1 slot-02 <label> pid=$$ exit=$rc end=$(date -u +%FT%TZ)" >> "$LOCK.holders"; flock -u 9
[ "$rc" -eq 0 ] || exit "$rc"      # stop the wave; do not continue to the next step
```
- Mandatory `timeout` values (baseline from S3 revision-2 logs, node v20.20.1 / npm 10.8.2 — the sandbox's current versions):

| NN | label | T (s) | baseline |
|---|---|---|---|
| 01 | tooling-npm-ci | 180 | single 0-dependency tarball |
| 02 | tooling-verify | 30 | — |
| 03 | product-npm-ci | 900 | 6m00s (S3 log 01) |
| 04 | prisma-generate | 300 | 15s (S3 log 01) |
| 05 | lefthook-install | 60 | — |
| 06 | hook-resolution-verify | 60 | — |
| 07 | formatter-precheck | 120 | 46 files |
| 08 | hooked-commit | 1200 | hook tsc ≈ log 09 duration + eslint 33 files + prettier 46 files + check-r75 staged |
| 09 | post-commit-identity | 30 | — |
| 10 | bundle | 60 | — |
| 11 | check-r75-range-c23b | 60 | log 04 |
| 12 | check-r75-range-d5cd | 60 | — |
| 13 | control-source-lint | 300 | 2s (log 12) |
| 14 | tsc-noemit | 900 | log 09 |
| 15 | jest-targeted | 1500 | 9 suites; log 02 ran 28 suites in 812s |

Environment for every step: `export NODE_OPTIONS=--max-old-space-size=4096 PRISMA_HIDE_UPDATE_MESSAGE=1 npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false`. Steps 05–15 additionally `export npm_config_offline=true` (npm/npx registry access disabled; any fallback fetch fails instead of downloading).

## 2. Declared tooling: Prettier 3.9.6 outside the product graph
- Manifests already written (no install performed): `execution/s3-composition-prep/tooling/prettier-3.9.6/{package.json,package-lock.json,PROVENANCE.md,.gitignore}` — `package.json` sha256 `6c39ea3db029c5dda4d663f256419496b494129619a034e60e0f609711a4a774`, `package-lock.json` sha256 `3e2189ffec7b867997fd37f28ae77ac0bed5aef745a42e8d5687cc711c5a53b7`.
- Pin, copied from preserved `worktrees/s4-r6/package-lock.json` (blob `4455f53a6e0118ea2c4dd58f948da6e34fa920d9`, head `91990ae9aec72f47a67591892ac09fa1f59d2f16`): `prettier@3.9.6`, resolved `https://registry.npmjs.org/prettier/-/prettier-3.9.6.tgz`, integrity `sha512-OpN0zzVdiaiAhxpuuj5efpIS4sY9j7bY6uR5mnj5yPzGkdkjNKSJeUThPb60Jw29QuAZgA4o+/iB49kFiaBX6g==` (hex `3a9374cf…a057ea`), bin `bin/prettier.cjs`, zero dependencies. Tarball is not in `~/.npm/_cacache` today → step 01 is the single, declared registry read; it is tooling provenance, not application-lock provenance.
- Step 01 (`TOOL=/home/user/workspace/execution/s3-composition-prep/tooling/prettier-3.9.6`, run from `$TOOL`, not `$W`): `npm ci --ignore-scripts --no-audit --no-fund` — npm verifies the integrity above and fails on mismatch. Then `git -C $W write-tree` unchanged; `$TOOL/package-lock.json` sha256 unchanged (`3e2189ff…`).
- Step 02 verify (all must hold, else stop):
```
node "$TOOL/node_modules/prettier/bin/prettier.cjs" --version            # 3.9.6
node -p "require('$TOOL/node_modules/prettier/package.json').version"     # 3.9.6
ls "$HOME/.npm/_cacache/content-v2/sha512/3a/93/74cf355d89a880871a6eba3e5e7e9212e2c63d8fb6d8eae4799a78f9c8fcc691d92334a4897944e13dbeb4270dbd42e019800e28fbf881e3d90589a057ea"   # cached tarball at the integrity address
sha512sum <that file> | cut -d' ' -f1                                      # 3a9374cf…a057ea
sha256sum "$TOOL/node_modules/prettier/bin/prettier.cjs" "$TOOL/node_modules/prettier/package.json"   # record; reused in step 06
find "$TOOL/node_modules" -mindepth 1 -maxdepth 1 | sort                   # exactly .bin, .package-lock.json, prettier
```

## 3. Product native setup (`$W`; product graph only)
- Step 03: `npm ci --ignore-scripts --no-audit --no-fund` (identical to S3 log 01). Preconditions: `test ! -e node_modules`; afterwards `sha256sum package-lock.json` = `b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55`, `git write-tree` = `78a4f0e8…`, `git status --porcelain | grep -v -E '^[MAD]  ' | wc -l` = 0, `test ! -e node_modules/.bin/prettier` (confirms prettier is absent from the product graph).
- Step 04 guarded local Prisma client generation (lifecycle `postinstall` was skipped by `--ignore-scripts`; this is the reviewed replacement): `PRISMA_GENERATE_SKIP_AUTOINSTALL=true node node_modules/prisma/build/index.js generate` (same CLI file S2's harness uses; `--no-install` semantics by direct path; no `npx`). Expect `Generated Prisma Client (v6.19.3)`. Disclosure: with `--ignore-scripts`, `@prisma/engines` postinstall did not run, so this step may download the query/schema engine binaries from `binaries.prisma.sh` exactly as S3 log 01 did; this is the only non-npm network access in the setup and must be visible in the log (`PRISMA_ENGINES_MIRROR` unset). Record `node -p "require('deepmerge-ts/package.json').version"` → `8.0.0`, `require('@prisma/config/package.json').version` → `6.19.3` (§6 release-path input).
- Step 05 (offline from here): `node node_modules/lefthook/bin/index.js install` (installs the repo's real hooks from `lefthook.yml`; `prepare` lifecycle was skipped by `--ignore-scripts`). Verify `ls .git/hooks` contains lefthook-generated `pre-commit` and `commit-msg` (record any others it adds), `head -3 .git/hooks/pre-commit` names lefthook, `git config core.hooksPath` is unset, and `.lefthook-local.yml`/`lefthook-local.yml` are absent (no local override). Note: `worktrees/s2-runner53` (S2's installed runner) has no lefthook hooks in `.git/hooks` either — S2 commits were also made without them (W2).
- Linking the tooling binary so the existing, unmodified hook resolves it locally. npm 10.8.2 `libnpmexec` resolves a bare `npx prettier` by walking up from `$W` looking for `node_modules/.bin/prettier`, then the global bin, and only then installs (read from `/usr/local/lib/node_modules/npm/node_modules/libnpmexec/lib/{index,file-exists}.js`). Therefore:
```
ln -s "$TOOL/node_modules/prettier/bin/prettier.cjs" "$W/node_modules/.bin/prettier"   # untracked; node_modules is gitignored; product index/lock untouched
```
  This symlink lives in the disposable install directory, not in the repository tree, and is destroyed by any future `npm ci`. It is declared here so no reviewer mistakes it for a lockfile-provided binary.
- Step 06 hook-resolution verify, offline, BEFORE any commit (all must hold, else stop):
```
export npm_config_offline=true
readlink -f node_modules/.bin/prettier                      # $TOOL/node_modules/prettier/bin/prettier.cjs
sha256sum "$(readlink -f node_modules/.bin/prettier)"       # equals step-02 hash
npx --no-install prettier --version                         # 3.9.6 (resolved via node_modules/.bin, no fetch)
npx prettier --version                                      # 3.9.6 — the hook's exact form; must not print any "Need to install" prompt or npx cache path
ls -d "$HOME/.npm/_npx"/* 2>/dev/null | wc -l               # must be unchanged from a count taken before step 06 (no npx-cache install happened)
npx --no-install tsc --version; npx --no-install eslint --version; test -f scripts/check-r75.js && echo checker-present   # tsc 5.9.3 and eslint 10.5.0 per product lock
git write-tree                                              # 78a4f0e8…
```
- Step 07 formatter pre-check (the hook's exact command over the hook's exact file set, run once outside the hook so a failure is attributable): `npx prettier --check $(git diff --name-only --cached --diff-filter=ACMR | grep -E '\.(ts|tsx|js|jsx|json|md|yml|yaml)$')` — 46 files (31 ts, 2 js, 6 json, 2 md, 5 yml; `package-lock.json` is `.prettierignore`d). Config `.prettierrc.json`/`.prettierignore` unchanged from base. **Any file reported is a stop**: if it is one of the three resolved files, report to parent for a formatting-only revision of the draft (new tree, new request); if it is an S3- or S2-authored file, it is a pre-existing format defect never hook-checked in either lane — report, do not rewrite preserved S3/S2 source.

## 4. Hook-enabled merge commit (step 08; offline env exported; hooks active)
```
git var GIT_AUTHOR_IDENT; git var GIT_COMMITTER_IDENT       # both Bradley Gleave <bradley@bradleytgpcoaching.com>
git commit -F - <<'MSG'
merge(s3): compose preserved S3 reliability candidate 5c7b42b3 into S1+S2 successor d5cd9b8b

R100 gate: keep the committed R75 checker job from S3 and the S2 retirement of
the loc-budget/test-density jobs; scope prose now points at .github/r75-policy.json.
test/ci/r100-pathspec.spec.ts asserts checker delegation and policy scope instead
of inline workflow pathspecs; test/ci/r75-gate.spec.ts drops the retired-jobs check.
MSG
```
Hooks that execute (from `lefthook.yml` blob `54d03749…`): pre-commit `banned-cast-tokens` (`node scripts/check-r75.js --mode=staged`), `tsc` (`npx tsc --noEmit`), `eslint --no-warn-ignored --max-warnings 0` over the 33 staged ts/js files, `prettier --check` over the 46 files, `prod-readiness-quick` (no-op: script absent in tree); commit-msg `no-ai-tokens` (message above: 0 regex hits, checked locally). If any hook fails: the merge state remains (MERGE_HEAD intact), record the raw hook output, stop.

Step 09 post-commit identity (stop and report on any mismatch):
```
git log -1 --format='%H%n%T%n%P%n%an <%ae>%n%cn <%ce>%n%B'
# %T == 78a4f0e8c22e9b9e902bbaae0b9f5623b9fbfa69 ; %P == "d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c 5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06"
# author == committer == Bradley Gleave <bradley@bradleytgpcoaching.com>; no trailers; test ! -e .git/MERGE_HEAD
git diff --quiet 78a4f0e8c22e9b9e902bbaae0b9f5623b9fbfa69 HEAD^{tree} && echo tree-identical
git status --porcelain | wc -l                               # 0
git cat-file -p HEAD | grep -c -iE 'co-authored|generated|claude|anthropic|openai|perplexity'   # 0
```
Step 10: `git bundle create "$O/s3-into-s1s2-$(git rev-parse --short=8 HEAD)-from-public-c23b9d9.bundle" c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7..HEAD && git bundle verify <bundle> && sha256sum <bundle>`.

## 5. Targeted validation on the committed head (steps 11–15; offline env)
```
11  node scripts/check-r75.js --mode=range --base=c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7 --head=HEAD
12  node scripts/check-r75.js --mode=range --base=d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c --head=HEAD
13  npx --no-install eslint --max-warnings 0 scripts/check-r75.js test/ci/r75-gate.spec.ts test/ci/r75-boundaries.spec.ts test/ci/r75-wiring.spec.ts test/ci/r75-enforcement.spec.ts test/ci/r100-pathspec.spec.ts test/ci/dependency-audit.spec.ts
14  npx --no-install tsc --noEmit -p tsconfig.json
15  npx --no-install jest --ci --runInBand --verbose test/ci/r100-pathspec.spec.ts test/ci/r75-gate.spec.ts test/ci/r75-wiring.spec.ts test/ci/r75-enforcement.spec.ts test/ci/r75-boundaries.spec.ts test/ci/delivery-artifact.spec.ts test/ci/release-evidence-gate.spec.ts test/ci/dependency-audit.spec.ts test/ci/fly-readiness.spec.ts
```
Step 15 list is de-duplicated (9 suites). Expected: exit 0 everywhere; a failure outside the three resolved files is a new finding → stop. Not requested here: full suite, build, Docker, Fly, RLS, DB.

## 6. Release-path re-observation required by deepmerge-ts 8.0.0 (S2 heavy owner; DB; after B3 on untouched d5cd)
Unchanged from SLOT_REQUEST_01 §5: one run of the unchanged `test/release/s1s2-composition.sh` (blob `38b70f54…`) on the committed composed head, diffing `[release]` steps, `prisma_version`, `sha256 package-lock.json` (`b7fed5ed…`) and exit codes against the d5cd B3 run. Its `PRISMA_CLI=node_modules/prisma/build/index.js` resolves `@prisma/config` → c12 → `deepmerge-ts` 8.0.0 in this tree (7.1.5 in every prior B-run).

## 7. Warnings surfaced (no action taken; no preserved source rewritten)
- W1 `/home/user/node_modules` (platform-owned, 209 packages) exposes `.bin/eslint` (and `acorn`, `semver`, `playwright`, …) on npm's walk-up path. After step 03 the product's own `node_modules/.bin/eslint` (10.5.0) shadows it; before step 03, or if step 03 fails, any `npx eslint` from `$W` would resolve the platform copy. `tsc`, `jest`, `prettier` are not present there. Step 06 records `npx --no-install eslint --version` to prove the product copy is in effect.
- W2 The formatter and `eslint --max-warnings 0` hooks have never run on any S3 (23 commits, hooks not installed per S3 REPORT) or S2 commit; step 07/08 may therefore surface pre-existing format/lint defects in preserved S3/S2 files. Those are findings for the parent, not edits for this slice.
- W3 Prisma engine binaries may be fetched in step 04 (see §3); if the operator wants zero non-npm network, the alternative is a disposition to reuse engines from an already-installed preserved worktree via `PRISMA_QUERY_ENGINE_LIBRARY`/`PRISMA_SCHEMA_ENGINE_BINARY` — not requested by me because it changes the environment the tests observe.
- W4 The `.holders` file and the lock file are shared with S2/S4/S5 lanes; `flock -n` guarantees this lane never blocks or waits on them. `exit 75` on a held lock is "not started", not a failure.
- W5 `npm ci` in step 01 writes only under `$TOOL/node_modules` and the npm cache; nothing under `$W` or any preserved worktree.

## 8. Outputs this slot must leave
`$O/logs/01..15-*.log` (each with header + `exit=`), `$O/tooling-verify.txt` (step 02/06 hashes), `$O/identity.txt` (step 09), bundle + sha256, `SHA256SUMS` (non-self-including). Success proves: hook-enabled exact two-parent commit of tree `78a4f0e8…` with a declared, pinned, offline-resolved formatter; targeted specs/tsc/control-lint/R75 range green on that head. It does not prove: full suite, build/image, Fly, S1/S2 dynamic behaviour, the deepmerge-8 release path (§6), or audit clearance; two independent non-author attestations remain required.
