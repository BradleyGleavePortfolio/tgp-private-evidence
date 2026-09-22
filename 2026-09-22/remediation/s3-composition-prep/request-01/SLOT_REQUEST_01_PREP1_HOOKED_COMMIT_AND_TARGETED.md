# SLOT_REQUEST_01 — S3-INTO-S1S2-PREP-1: native setup, hook-enabled merge commit, targeted validation

Requested 2026-09-22 ~05:05 UTC by the PREP-1 writer. Nothing below has been run. Execute only on a named grant after S2's real proof; a free lock is not a grant.

## 0. Fixed identities
- worktree `/home/user/workspace/worktrees/s3-composition-prep`, branch `execute/20260922-s3-into-s1s2-prep`
- HEAD (parent 1) `d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c` tree `c0ab87d4dc584b2a7ccad53db16fa551b93fe359`
- `.git/MERGE_HEAD` (parent 2) `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06` tree `83211d25d714e4c539cd3aa248a06ef0658fc8e7`
- staged index tree `78a4f0e8c22e9b9e902bbaae0b9f5623b9fbfa69` (must be unchanged at every step: `git write-tree`)
- lock inputs in that tree: `package-lock.json` blob `354de3dae19449970497da6e4d87f0a1225a8f43` sha256 `b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55`; `package.json` blob `656d11a20c6abee819a0b04e9f04c0b66c0a05ef` sha256 `afecdb3762df06075723dbe254a80bffe828b028bdb33576030d1ce0f936c5aa`; `lefthook.yml` blob `54d037490460fcddf2523ce05801bae9860489ff`. All three are byte-identical to S3 `5c7b42b3` (S2 left them at base).

## 1. Dependency provenance for the changed S3 lock (what the install resolves)
- Lockfile v3, 1150 entries, all `registry.npmjs.org` with `integrity` (S3 REPORT; R2-A audit_checks). Versus base: 44 version changes / 20 added / 21 removed; production closure 357→358 entries, 11 prod version changes (`deepmerge-ts` 7.1.5→8.0.0 sole dependent `@prisma/config`; `js-yaml` 4.3.2; `multer` 2.3.0; `qs` 6.16.0; `ws` 8.21.0; `body-parser`, `form-data`, `hasown`, `side-channel`, `type-is`, `undici`). Overrides: `qs 6.16.0`, `diff 9.0.0`, `@prisma/config@6.19.3→deepmerge-ts 8.0.0`, `@nestjs/platform-express@11.1.26→multer 2.3.0`, `@nestjs/swagger@11.4.4→js-yaml 4.3.2`.
- Prior install evidence on this exact lock: S3 log `01-npm-ci.log` (`npm ci --ignore-scripts --no-audit --no-fund` exit 0, 1117 packages; `PRISMA_HIDE_UPDATE_MESSAGE=1 npx prisma generate` → Prisma Client 6.19.3), node v20.20.1 / npm 10.8.2. Sandbox node is v20.20.1. `npm audit` on this lock: 0 high/critical at 2026-09-20T17:26Z (log 15; time-dependent).
- Not in the lock: `prettier` (see blocker B1). `lefthook` 2.1.9 and `eslint` 10.5.0 are in the lock.

## 2. Native setup (heavy lock; ~6–8 min; private node_modules; no network beyond registry.npmjs.org reads by `npm ci`)
```
cd /home/user/workspace/worktrees/s3-composition-prep
git write-tree                      # expect 78a4f0e8c22e9b9e902bbaae0b9f5623b9fbfa69
test ! -e node_modules
exec 9>/home/user/workspace/execution/heavy-validation.lock && flock 9     # named grant, not free lock
npm ci --ignore-scripts --no-audit --no-fund                                # same as S3 log 01
PRISMA_HIDE_UPDATE_MESSAGE=1 npx --no-install prisma generate               # explicit, reviewed lifecycle step
npx --no-install lefthook install                                           # installs the repo's real hooks (`prepare` skipped by --ignore-scripts)
sha256sum package-lock.json                                                 # expect b7fed5ed…9c55 (npm ci must not rewrite it)
git write-tree; git status --porcelain | grep -v -E '^[MAD]  ' | wc -l      # expect 78a4f0e8…, 0
node -p "require('deepmerge-ts/package.json').version"                      # expect 8.0.0 (composed release-path input, §5)
node -p "require('@prisma/config/package.json').version + ' ' + require('prisma/package.json').version"   # expect 6.19.3 6.19.3
```
Stamp every log header with `head`, `write-tree`, `node -v`, `npm -v`, `NODE_OPTIONS`, loadavg, UTC (reuse `run-step2.sh` semantics with `WORKTREE=` set; note it does not propagate the child exit — read the printed `exit=` line, S3-R2A-001).

## 3. Hook-enabled merge commit (test lock; no `--no-verify`, no `LEFTHOOK=0`, no `LEFTHOOK_EXCLUDE`)
```
export NODE_OPTIONS=--max-old-space-size=4096        # pre-commit `tsc` OOMs at default heap (S3 log 05 exit 134; CI sets the same)
git var GIT_AUTHOR_IDENT; git var GIT_COMMITTER_IDENT # both "Bradley Gleave <bradley@bradleytgpcoaching.com>" (repo-local config already set)
git commit -F - <<'MSG'
merge(s3): compose preserved S3 reliability candidate 5c7b42b3 into S1+S2 successor d5cd9b8b

R100 gate: keep the committed R75 checker job from S3 and the S2 retirement of
the loc-budget/test-density jobs; scope prose now points at .github/r75-policy.json.
test/ci/r100-pathspec.spec.ts asserts checker delegation and policy scope instead
of inline workflow pathspecs; test/ci/r75-gate.spec.ts drops the retired-jobs check.
MSG
```
Hooks that will run (from `lefthook.yml` in the tree): pre-commit `banned-cast-tokens` (`node scripts/check-r75.js --mode=staged`), `tsc` (`npx tsc --noEmit`), `eslint --no-warn-ignored --max-warnings 0 {staged_files}` over the 33 staged `.ts/.js/.cjs` files, `prettier --check {staged_files}` over the 44 staged ts/js/json/md/yml files, `prod-readiness-quick` (no-op: `scripts/prod-readiness-precheck.sh` absent in tree); commit-msg `no-ai-tokens` (message above contains none of the banned tokens).

Post-commit identity verification (stop and report if any line differs):
```
git log -1 --format='%H%n%T%n%P%n%an <%ae>%n%cn <%ce>%n%B'
# %T must be 78a4f0e8c22e9b9e902bbaae0b9f5623b9fbfa69 (hooks must not have rewritten the tree)
# %P must be "d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c 5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06"
# author and committer both Bradley Gleave <bradley@bradleytgpcoaching.com>; no trailers
git diff --quiet 78a4f0e8c22e9b9e902bbaae0b9f5623b9fbfa69 HEAD^{tree} && echo tree-identical
git status --porcelain | wc -l                      # 0
git bundle create /home/user/workspace/execution/s3-composition-prep/s3-into-s1s2-<head8>-from-public-c23b9d9.bundle c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7..HEAD
git bundle verify <bundle>; sha256sum <bundle>
```

## 4. Targeted validation on the committed head (test lock; each step logged separately; NODE_OPTIONS exported)
```
node scripts/check-r75.js --mode=range --base=c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7 --head=HEAD   # full composed range
node scripts/check-r75.js --mode=range --base=d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c --head=HEAD   # S3 + resolution delta only
npx --no-install eslint --max-warnings 0 scripts/check-r75.js test/ci/r75-gate.spec.ts test/ci/r75-boundaries.spec.ts test/ci/r75-wiring.spec.ts test/ci/r75-enforcement.spec.ts test/ci/r100-pathspec.spec.ts test/ci/dependency-audit.spec.ts   # exact CI "Lint control sources"
npx --no-install tsc --noEmit -p tsconfig.json                                                        # with NODE_OPTIONS stamped in header (closes S3-R2B-01 for this head)
npx --no-install jest --runInBand --verbose \
  test/ci/r100-pathspec.spec.ts test/ci/r75-gate.spec.ts test/ci/r75-wiring.spec.ts test/ci/r75-enforcement.spec.ts test/ci/r75-boundaries.spec.ts \
  test/ci/delivery-artifact.spec.ts test/ci/release-evidence-gate.spec.ts test/ci/dependency-audit.spec.ts test/ci/fly-readiness.spec.ts test/ci/r100-pathspec.spec.ts
```
Rationale per spec: first five read the merged `r100-quality-gate.yml`/`ci.yml`/policy/hook (two were edited); `delivery-artifact` and `release-evidence-gate` are S2's workflow readers never run with S3's `ci.yml` step / `dependency-audit.yml` present; `dependency-audit`/`fly-readiness` read S3 files whose neighbours changed. Expected: all PASS; `check-r75` exit 0. Any failure outside the three resolved files is a new finding → stop, no retry, no fix in this slice. Not requested: full default suite, build, Docker, Fly, RLS, DB (normal CI gates / S2 owner).

## 5. Release-path re-observation required by deepmerge-ts 8 (S2 heavy owner; DB; after B3 passes on untouched d5cd)
Reason: `scripts/release.sh` runs `npx prisma migrate status/deploy`; the prisma CLI loads `@prisma/config` → c12 → `deepmerge-ts`; in this tree that resolves 8.0.0 instead of the 7.1.5 B1/B2/B3 ran under. `prisma`, `@prisma/client`, `@prisma/engines`, `@prisma/config` lock entries are identical (version + integrity); only the transitive merger changes. No repo-root `prisma.config.*` exists.
- Smallest meaningful observation: run the existing `test/release/s1s2-composition.sh` (unchanged blob `38b70f54…`) once on the committed composed head with S2's frozen runner semantics (fresh cluster namespace, `EXPECT_HEAD=<composed head>`), and diff its `[release]` step-0/1/2 outputs, `prisma_version`, `sha256 package-lock.json` stamp (`b7fed5ed…`) and exit codes against the d5cd B3 run. No new harness; no S1 path changes to interpret.
- Offline precursor already in §2 (`deepmerge-ts` 8.0.0 present) and §4 (`dependency-compatibility` is part of the full suite, not requested here; S3 logs 08/10/14 remain the jest-level proof).

## 6. Blockers and disclosures (need parent disposition before §3)
- **B1 — hook tool not in lock:** pre-commit `prettier: npx prettier --check {staged_files}` — `prettier` is absent from `package-lock.json` and `devDependencies`. `npx` would fetch it from the registry = hidden install; `npx --no-install` would fail the hook. This is a pre-existing repository defect, present identically at base, d5cd and 5c7b. Neither S3's 23 commits (S3 REPORT: hooks NOT installed in its worktree) nor S2's have ever executed these hooks. Options for parent: (a) add `prettier` pinned to devDependencies + lock — a 4th product-file edit outside PREP-1's surface, and it changes the lock hash above; (b) explicit recorded disposition to run the commit with `LEFTHOOK_EXCLUDE=prettier` — this IS skipping a hook and is not requested by me; (c) commit-tree path `git commit-tree 78a4f0e8… -p d5cd9b8b -p 5c7b42b3` with hooks not run, honestly labelled "hooks not executed" as every prior lane commit was, followed by the §4 checks (which cover the same tools except prettier) plus an explicit `npx --no-install prettier` disclosure. I recommend (a) or (c) decided by parent; I will not choose.
- **B2 — hook eslint scope:** `--max-warnings 0` over all 33 staged ts/js files includes S3-authored test/src files never hook-linted (S3 `npm run lint` covers `src/**` only: 0 errors/21 warnings all in unchanged files; CI control-source lint covered 7 files). A warning in any other S3 file fails the commit and is outside my 3-file surface → stop and report, not fix.
- **B3 — heap:** hook `tsc` needs `NODE_OPTIONS=--max-old-space-size=4096` (S3 log 05 OOM). Exported in §3; must appear in the log header.
- **B4 — merge state vs gates:** the existing `--no-commit` merge state does not block Jest/tsc/eslint/prettier (they read the worktree) or `check-r75 --mode=staged`; it does block `check-r75 --mode=range` and any CI/Danger run, which need a commit. Nothing in §4 is runnable as evidence before §3.
- **B5 — no product commit exists yet;** `MERGE_HEAD` is intact. If `git commit` fails in a hook, the merge state remains; do not `git merge --abort` (it would discard the staged resolution — recover from `patches/full-vs-parent1-d5cd9b8b.patch` if it ever happens).
- Time-dependent: `npm audit` result is from 2026-09-20; S3's `dependency-audit.yml` re-evaluates in CI.

## 7. Outputs this slot must leave
`execution/s3-composition-prep/slot-01/<utc>/` with: stamped logs per step, `git log -1` identity block, bundle + sha256, `SHA256SUMS` (non-self-including). Success proves: hook-enabled (or honestly labelled) exact two-parent commit of tree `78a4f0e8…`, targeted specs/tsc/control-lint/R75 range green on that head. Does not prove: full suite, build/image, Fly, S1/S2 dynamic behaviour, deepmerge-8 release path (§5), or audit clearance; two independent non-author attestations still required.
