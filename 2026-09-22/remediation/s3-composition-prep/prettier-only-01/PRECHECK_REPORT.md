# S3-PRETTIER-ONLY-01 — formatter pre-check evidence (not hook resolution, not acceptance)

Run 20260922T052750Z by the PREP-1 writer under the grant in execution/EXECUTION_REPAIR_WAVE_2.md §S3-PRETTIER-ONLY-01. Three steps, canonical `execution/test-validation.lock` with `flock -n` per step (holders lines in 05-post-state.txt). Stopped at the first non-zero exit (step 03). No retry, no formatting, no application install, no node_modules/symlink in the worktree, no Prisma, no hooks, no commit.

## Result
| step | command | exit | bound |
|---|---|---|---|
| 01 | tooling `npm ci --ignore-scripts --no-audit --no-fund` in tooling/prettier-3.9.6 | 0 (added 1 package) | 180+30 s |
| 02 | version/integrity/realpath/hash verification | 0 (12/12 OK) | 30+30 s |
| 03 | `node <tool>/node_modules/prettier/bin/prettier.cjs --check <46 files>` from the draft worktree | **1 — 6 files unformatted** | 120+30 s |

## Tooling identity (declared additional tooling; not application-lock provenance)
- prettier 3.9.6, resolved https://registry.npmjs.org/prettier/-/prettier-3.9.6.tgz, integrity sha512-OpN0zzVdiaiAhxpuuj5efpIS4sY9j7bY6uR5mnj5yPzGkdkjNKSJeUThPb60Jw29QuAZgA4o+/iB49kFiaBX6g== — matched in `node_modules/.package-lock.json`; cached tarball at `~/.npm/_cacache/content-v2/sha512/3a/93/74cf…a057ea` (2,800,155 bytes) sha512 re-computed equal; tarball sha256 `997da95cf2ae81053cafc79ef122a6e8dc12e3f2c619d57eb1f2e19525fb212f`.
- binary realpath `execution/s3-composition-prep/tooling/prettier-3.9.6/node_modules/prettier/bin/prettier.cjs` sha256 `6e922134a3c76fd4de202959bb6aef50bde0c994148075003a15569b7197906e`; `--version` 3.9.6; zero dependencies; tooling node_modules contains exactly `.bin`, `.package-lock.json`, `prettier`. Tooling manifests unchanged (package.json 6c39ea3d…, package-lock.json 3e2189ff…). npx cache untouched (0 dirs before/after).
- The only network access was step 01's single registry fetch of that tarball.

## Product state before == after
HEAD d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c; MERGE_HEAD 5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06; `git write-tree` 78a4f0e8c22e9b9e902bbaae0b9f5623b9fbfa69 at every header/footer; product lock blob 354de3da…; worktree dirty vs index 0; product node_modules absent; hooks 0; core.hooksPath unset.

## Finding F1 — six preserved S3 blobs fail `prettier --check` under the repo's own .prettierrc.json
Exact list (staged-46-files.txt sha256 44b8a947…; list re-derived at run time, identical):
`src/filters/throttler-exception.filter.ts`, `src/observability/README.md`, `src/observability/logging.interceptor.ts`, `src/prisma.service.ts`, `src/scout/scout.service.ts`, `test/health-readiness-bounded.spec.ts`.
All six staged blobs are byte-identical to S3 5c7b42b3 and differ from base c23b9d9f and from S2 d5cd9b8b (04-attribution.txt); none is one of the three manually resolved files, so the resolution did not introduce them. The other 40 files (including the three resolved files, S2's ci/gate files and all S3 workflow/policy/fixture files) passed. Whether the base versions of these six were already unformatted is NOT known — that would need a second formatter invocation, which was not granted.

Consequence: the pre-commit `prettier --check {staged_files}` hook, when actually executed on this staged set, will fail on these six files. Any fix (`prettier --write` on preserved S3 source, or a disposition about the hook scope) is a parent/Bradley decision outside this lane's surface; nothing was reformatted.

## What this does not prove
Native hook execution or `npx` resolution inside the hook, application dependency closure, commit, integrated tests/runtime, or acceptance of the composed candidate.

## Files
00-pre-state.txt, staged-46-files.txt, logs/01-tooling-npm-ci.log, logs/02-tooling-verify.log, logs/03-formatter-precheck.log (raw --check output and exit), 04-attribution.txt, 05-post-state.txt, PRECHECK_REPORT.md, SHA256SUMS.txt (excludes itself).
