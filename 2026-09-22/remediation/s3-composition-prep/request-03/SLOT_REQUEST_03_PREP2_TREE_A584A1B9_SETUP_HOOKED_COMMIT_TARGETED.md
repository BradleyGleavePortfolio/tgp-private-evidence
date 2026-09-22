# SLOT_REQUEST_03 — S3-INTO-S1S2 PREP2 tree `a584a1b9`: bounded app setup, offline hook resolution proof, hook-enabled merge commit, targeted validation incl. six-file applicability

Additive to SLOT_REQUEST_02 (frozen; its §1 lock/attribution pattern, §2 tooling provenance and §6/§7 apply unchanged unless restated here). Preparation only — nothing here is granted or has been run. S6 setup owns the next heavy slot; this runs only on a later named grant. B3 real proof, composed-lock release-path proof (SLOT_REQUEST_02 §6) and two independent non-author attestations keep their order.

## 0. Exact input (frozen PREP2)
- worktree `W=/home/user/workspace/worktrees/s3-composition-prep`, branch `execute/20260922-s3-into-s1s2-prep`; HEAD `d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c`; `.git/MERGE_HEAD` `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06`; base `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`
- **staged index tree `a584a1b95423f95dae8daabf673ef3776604acbb`** (PREP1 `78a4f0e8…` + six formatted S3 files; `git write-tree` must print this before/after every step). Product `package-lock.json` blob `354de3dae19449970497da6e4d87f0a1225a8f43` (sha256 `b7fed5ed…9c55`), `package.json` `656d11a2…`, `lefthook.yml` `54d03749…` — all = S3 5c7b42b3; app closure provenance = SLOT_REQUEST_01 §1 (unchanged).
- Six formatted paths (blobs `f59584d9 8440664f d5c60dfb af24f743 acd38f2d a8885dfd`): `src/filters/throttler-exception.filter.ts`, `src/observability/README.md`, `src/observability/logging.interceptor.ts`, `src/prisma.service.ts`, `src/scout/scout.service.ts`, `test/health-readiness-bounded.spec.ts`. Three resolutions unchanged (`0ad6eb8b be6676d6 04190bd6`).
- Hook file sets from the index: 33 ts/js (eslint glob), 46 ts/js/json/md/yml (prettier glob); same paths as PRETTIER-ONLY-01 list sha256 `44b8a947…` (six blobs differ). Last formatter `--check` on this content: exit 0 (prep2-format/…/logs/03). No re-run of write/check requested.
- Formatter already installed and verified (PRETTIER-ONLY-01 step 02): `TOOL=/home/user/workspace/execution/s3-composition-prep/tooling/prettier-3.9.6`, binary `$TOOL/node_modules/prettier/bin/prettier.cjs` sha256 `6e922134a3c76fd4de202959bb6aef50bde0c994148075003a15569b7197906e`, 3.9.6. **No refetch/npm ci of the tooling.**
- Output `O=/home/user/workspace/execution/s3-composition-prep/slot-03/<UTC>`; `mkdir -p "$O/logs"` first. Per-step: canonical `execution/test-validation.lock`, `flock -n` (exit 75 if held, not started), attributed `.holders` lines, `timeout --kill-after=30 <T>` on the bare command, raw `exit=` line, `git write-tree` in header and footer (SLOT_REQUEST_02 §1 pattern verbatim). Stop the wave at the first non-zero exit; no retry; never `git merge --abort`.
- Env for all steps: `NODE_OPTIONS=--max-old-space-size=4096 PRISMA_HIDE_UPDATE_MESSAGE=1 npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false`; steps 03–14 additionally `npm_config_offline=true`.

## 1. Steps and mandatory bounds
| NN | label | command (from `$W`) | T (s) | expected |
|---|---|---|---|---|
| 01 | tool-reverify | `node $TOOL/node_modules/prettier/bin/prettier.cjs --version; sha256sum $TOOL/node_modules/prettier/bin/prettier.cjs; find $TOOL/node_modules -mindepth 1 -maxdepth 1` | 30 | `3.9.6`; `6e922134…`; exactly `.bin .package-lock.json prettier` |
| 02 | app-npm-ci | `test ! -e node_modules && npm ci --ignore-scripts --no-audit --no-fund` | 900 | exit 0 (S3 log 01: 1117 pkgs, 6m); then `sha256sum package-lock.json` = `b7fed5ed…9c55`; `test ! -e node_modules/.bin/prettier` (prettier not in app graph); `git write-tree` = `a584a1b9…`; `git status --porcelain \| grep -v -E '^[MAD]  ' \| wc -l` = 0. Only registry.npmjs.org reads per the lock. |
| 03 | prisma-generate-guarded | `PRISMA_GENERATE_SKIP_AUTOINSTALL=true node node_modules/prisma/build/index.js generate` | 300 | `Generated Prisma Client (v6.19.3)`. Autoinstall explicitly off; no npx. Disclosure: `@prisma/engines` postinstall was skipped by `--ignore-scripts`, so engine binaries may be fetched from binaries.prisma.sh exactly as in S3 log 01 — must be visible in the log. Also record `node -p "require('deepmerge-ts/package.json').version"` → `8.0.0`, `require('@prisma/config/package.json').version` → `6.19.3`. |
| 04 | lefthook-install | `node node_modules/lefthook/bin/index.js install` | 60 | `.git/hooks/pre-commit` and `commit-msg` present and name lefthook; `git config core.hooksPath` unset; no `lefthook-local.yml`/`.lefthook-local.yml`. (`prepare` lifecycle was skipped by `--ignore-scripts`; this is the reviewed replacement.) |
| 05 | link-formatter | `ln -s $TOOL/node_modules/prettier/bin/prettier.cjs node_modules/.bin/prettier` | 10 | untracked (node_modules is gitignored); `git write-tree` unchanged. Declared tooling link, not a lock-provided binary; destroyed by any future `npm ci`. |
| 06 | hook-resolution-offline-proof | see §2 | 60 | all lines hold |
| 07 | hooked-commit | `git commit -F -` with the message in §3 | 1200 | exit 0 with all hooks executed |
| 08 | post-commit-identity | see §3 | 30 | all lines hold |
| 09 | bundle | `git bundle create $O/s3-into-s1s2-$(git rev-parse --short=8 HEAD)-from-public-c23b9d9.bundle c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7..HEAD && git bundle verify <bundle> && sha256sum <bundle>` | 60 | verify ok |
| 10 | check-r75-range-c23b | `node scripts/check-r75.js --mode=range --base=c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7 --head=HEAD` | 60 | exit 0 |
| 11 | check-r75-range-d5cd | `node scripts/check-r75.js --mode=range --base=d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c --head=HEAD` | 60 | exit 0 |
| 12 | control-source-lint | `npx --no-install eslint --max-warnings 0 scripts/check-r75.js test/ci/r75-gate.spec.ts test/ci/r75-boundaries.spec.ts test/ci/r75-wiring.spec.ts test/ci/r75-enforcement.spec.ts test/ci/r100-pathspec.spec.ts test/ci/dependency-audit.spec.ts` | 300 | exit 0 (S3 log 12: 2 s) |
| 13 | tsc-noemit | `npx --no-install tsc --noEmit -p tsconfig.json` | 900 | exit 0 (S3 log 09); covers the five formatted .ts files' syntax/types |
| 14 | jest-targeted | `npx --no-install jest --ci --runInBand --verbose <list in §4>` | 1800 | all suites pass |

## 2. Step 06 — offline hook resolution proof, BEFORE any commit (all must hold, else stop)
Basis: npm 10.8.2 `libnpmexec` resolves bare `npx prettier` by walking up from `$W` for `node_modules/.bin/prettier`, then global bin, then install (`/usr/local/lib/node_modules/npm/node_modules/libnpmexec/lib/{index,file-exists}.js`, read in SLOT_REQUEST_02).
```
export npm_config_offline=true
N0=$(ls -d "$HOME/.npm/_npx"/* 2>/dev/null | wc -l)                     # npx cache dirs before (was 0 on 2026-09-22)
readlink -f node_modules/.bin/prettier                                  # $TOOL/node_modules/prettier/bin/prettier.cjs
sha256sum "$(readlink -f node_modules/.bin/prettier)"                   # 6e922134…906e
npx --no-install prettier --version                                     # 3.9.6
npx prettier --version                                                  # 3.9.6 — the hook's exact form; no "Need to install" prompt, no cache path printed
test "$(ls -d "$HOME/.npm/_npx"/* 2>/dev/null | wc -l)" = "$N0"        # no npx-cache install happened
npx --no-install tsc --version                                          # Version 5.9.3 (product lock)
npx --no-install eslint --version                                       # v10.5.0 (product lock; shadows platform /home/user/node_modules/.bin/eslint — W1)
test -f scripts/check-r75.js && node scripts/check-r75.js --mode=staged; echo "staged-mode exit=$?"   # exit 0 = R75 clean index (dependency-free; same command the hook runs)
git write-tree                                                          # a584a1b9…
```
This proves resolution of the hook's binaries offline; it does not claim the hooks have executed.

## 3. Step 07/08 — hook-enabled merge commit and exact identity
```
git var GIT_AUTHOR_IDENT; git var GIT_COMMITTER_IDENT     # both "Bradley Gleave <bradley@bradleytgpcoaching.com>" (repo-local config)
git commit -F - <<'MSG'
merge(s3): compose preserved S3 reliability candidate 5c7b42b3 into S1+S2 successor d5cd9b8b

R100 gate: keep the committed R75 checker job from S3 and the S2 retirement of
the loc-budget/test-density jobs; scope prose now points at .github/r75-policy.json.
test/ci/r100-pathspec.spec.ts asserts checker delegation and policy scope instead
of inline workflow pathspecs; test/ci/r75-gate.spec.ts drops the retired-jobs check.
Six inherited S3 files reformatted with the repository prettier config (no code changes):
src/filters/throttler-exception.filter.ts, src/observability/README.md,
src/observability/logging.interceptor.ts, src/prisma.service.ts,
src/scout/scout.service.ts, test/health-readiness-bounded.spec.ts.
MSG
```
Hooks that execute (lefthook.yml `54d03749…`): pre-commit `banned-cast-tokens` (`node scripts/check-r75.js --mode=staged`), `tsc` (`npx tsc --noEmit`, needs the exported heap), `eslint --no-warn-ignored --max-warnings 0` over 33 staged ts/js (now including the six formatted blobs), `prettier --check` over 46 staged files (resolves via step 05 link, offline), `prod-readiness-quick` (no-op, script absent); commit-msg `no-ai-tokens` (message above: 0 hits against the hook regex, checked locally). If a hook fails: MERGE_HEAD stays, preserve raw output, stop.

Step 08 (stop on any mismatch):
```
git log -1 --format='%H%n%T%n%P%n%an <%ae>%n%cn <%ce>%n%B'
# %T == a584a1b95423f95dae8daabf673ef3776604acbb   (hooks must not have rewritten the tree)
# %P == "d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c 5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06"
# author == committer == Bradley Gleave <bradley@bradleytgpcoaching.com>; no trailers
git diff --quiet a584a1b95423f95dae8daabf673ef3776604acbb HEAD^{tree} && echo tree-identical
test ! -e .git/MERGE_HEAD; git status --porcelain | wc -l        # 0
git cat-file -p HEAD | grep -c -iE 'co-authored|generated|claude|anthropic|openai|perplexity'   # 0
```

## 4. Step 14 — targeted Jest list (de-duplicated; no full suite)
Workflow/policy readers (unchanged from SLOT_REQUEST_02): `test/ci/r100-pathspec.spec.ts test/ci/r75-gate.spec.ts test/ci/r75-wiring.spec.ts test/ci/r75-enforcement.spec.ts test/ci/r75-boundaries.spec.ts test/ci/delivery-artifact.spec.ts test/ci/release-evidence-gate.spec.ts test/ci/dependency-audit.spec.ts test/ci/fly-readiness.spec.ts`

Six-file applicability (specs that import or are the formatted files, found by `git grep` on tree `a584a1b9`):
| formatted file | hunk | exercising specs |
|---|---|---|
| `src/filters/throttler-exception.filter.ts` | `getRequest<…>()` generic wrap | `test/rate-limit.spec.ts test/observability/orm-composed-http.spec.ts test/contracts/importer-contract.spec.ts` |
| `src/observability/logging.interceptor.ts` | import collapse; `switchToHttp().getRequest<…>()` wrap | `test/observability/orm-composed-http.spec.ts` + `test/observability` directory (S3 focused set) |
| `src/prisma.service.ts` | `logger.warn(…)` argument wrap + trailing comma | `test/common/feature-flag-not-found.bootstrap.spec.ts` (imports PrismaService); type-level by step 13 |
| `src/scout/scout.service.ts` | `notifyComplete` ternary wrap | `src/scout/scout.service.spec.ts test/scout/scout-diagnostics-boundary.spec.ts test/scout/scout-diagnostics-public-cause.spec.ts test/scout/scout-diagnostics-public.spec.ts test/scout/scout-diagnostics.integrity.spec.ts` |
| `test/health-readiness-bounded.spec.ts` | `toMatchObject({...})` wrap | itself, plus `test/health-readiness-public.spec.ts` (same controller) |
| `src/observability/README.md` | 5 markdown table separators | no runtime importer; documentation only — covered by the formatter check already recorded, nothing to run |

Final list for step 14 (paths de-duplicated; `test/observability` expands to its specs):
`test/ci/r100-pathspec.spec.ts test/ci/r75-gate.spec.ts test/ci/r75-wiring.spec.ts test/ci/r75-enforcement.spec.ts test/ci/r75-boundaries.spec.ts test/ci/delivery-artifact.spec.ts test/ci/release-evidence-gate.spec.ts test/ci/dependency-audit.spec.ts test/ci/fly-readiness.spec.ts test/rate-limit.spec.ts test/observability test/contracts/importer-contract.spec.ts test/common/feature-flag-not-found.bootstrap.spec.ts src/scout/scout.service.spec.ts test/scout/scout-diagnostics-boundary.spec.ts test/scout/scout-diagnostics-public-cause.spec.ts test/scout/scout-diagnostics-public.spec.ts test/scout/scout-diagnostics.integrity.spec.ts test/health-readiness-bounded.spec.ts test/health-readiness-public.spec.ts`
Baseline: S3 log 02 ran a 28-suite superset of the non-CI part in 812 s (1 known failure there was the readiness-red-on-925780e case, later closed in log 11/16) — hence T=1800. A failure in any suite is a new finding → stop; no fix in this slice.

## 5. Blockers / warnings carried (SLOT_REQUEST_02 §7 W1–W5 still apply) plus
- W6 eslint hook now sees the six reformatted blobs; eslint config carries no prettier plugin (eslint.config.js blob unchanged from S3), so formatting alone should not add warnings — but this has not been observed; `--max-warnings 0` failure in any S3 file remains outside the slice.
- W7 Six S3 source-review conclusions are no longer byte-current for the formatted paths (PREP2 matrix); steps 13/14 are the minimum revalidation and do not replace the two independent exact-head attestations.
- W8 No product node_modules exists today; `npm ci` (step 02) is the first heavy allocation of this lane and must not overlap S6's slot.

## 6. Outputs
`$O/logs/01..14-*.log` (header + `exit=`), `$O/identity.txt` (step 08), bundle + sha256, `$O/SHA256SUMS.txt` (non-self-including). Success proves: hook-enabled exact two-parent commit of tree `a584a1b9…` with pinned offline-resolved formatter; R75 range, control lint, tsc and the targeted suites green on that head. It does not prove: full suite, build/image, Fly, S1/S2 dynamic behaviour, composed-lock release path (SLOT_REQUEST_02 §6), or acceptance.
