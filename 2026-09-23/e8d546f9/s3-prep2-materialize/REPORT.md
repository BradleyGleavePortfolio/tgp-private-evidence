# S3-PREP2-MATERIALIZE — approved PREP2 tree a584a1b9 as physical input (revision 1, frozen)

Writer: `restore_upstream_proof_inputs_muddwjad`, T4 source-only builder (requested Claude Fable 5; runtime identity not observable). Executed 2026-09-23T01:38:57Z–01:39:14Z. Physical input readiness only — NOT integration, runtime, hook, generator, schema, audit, test or release. Zero authored bytes: copy of the baseline object store + replay of the previously verified frozen patch. No merge commit, no MERGE_HEAD, no commit, no install/network/process/lock/probe.

Boundary check before write: no prior instruction names a different canonical path or forbids this worktree (EXECUTION_SCOPE UPSTREAM-RESTORE row, prep2-format `REPORT.md`, continuation brief searched); `worktrees/s3-prep2` and this directory were ABSENT.

## 1. Identity — `logs/X1-materialize.txt`

| Fact | Value |
|---|---|
| Worktree | `/home/user/workspace/worktrees/s3-prep2`, standalone (byte copy of `source/backend/.git`, origin removed, 0 remotes, no promisor, `GIT_NO_LAZY_FETCH=1`); shallow at c23b as baseline; both parents already in the local odb — no bundle/fetch |
| HEAD (unchanged, detached) | **`d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c`** (S2), clean tree `c0ab87d4dc584b2a7ccad53db16fa551b93fe359`, 2090 tracked, porcelain 0 before replay |
| Replayed patch | `2026-09-22/remediation/s3-composition-prep/prep2-format/patches/full-vs-parent1-d5cd9b8b.patch` sha256 **`91c0096d9918d19b5c958ad3a132e12922127df7f4a175d93bcf1dee3c69ae11`** (packet `SHA256SUMS.txt` 25/25 OK; 7597 lines, 48 files); `git apply --check` OK; `git apply --index` → index and working tree |
| **Index `write-tree`** | **`a584a1b95423f95dae8daabf673ef3776604acbb`** = approved PREP2 tree (same id reproduced earlier from both parents in `upstream/odb-prep2-verify`, `refs/prep2-tree` untouched) |
| S3 candidate (readback) | `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06`, tree `83211d25d714e4c539cd3aa248a06ef0658fc8e7`; refs `refs/restored/s2-d5cd9b8b`, `refs/restored/s3-5c7b42b3` (pointers only); c23b ancestor of both |
| Ancestry | 0 commits added (47 reachable, as baseline); **MERGE_HEAD absent** — the historical PREP2 worktree carried `MERGE_HEAD 5c7b`; deliberately not recreated (no fabricated merge state) |
| Product pins | `package-lock.json` blob `354de3dae19449970497da6e4d87f0a1225a8f43`; `package.json` blob `656d11a20c6abee819a0b04e9f04c0b66c0a05ef` (= prep2 REPORT); `prisma/schema.prisma` blob `341bd148…` identical HEAD/index — patch touches 0 schema/generator/migration paths; **S1 sole schema/generator reservation intact** (only `src/prisma.service.ts` formatting, as archived) |
| Hygiene | `node_modules` absent, `dist` absent, hooks 0, `core.hooksPath` unset |

## 2. Dirty scope (uncommitted, staged == worktree)

48 paths vs HEAD: **26 A, 22 M**, 0 D, 0 unstaged, 0 untracked (full list in `logs/X1`). All six formatted files (`src/filters/throttler-exception.filter.ts`, `src/observability/README.md`, `src/observability/logging.interceptor.ts`, `src/prisma.service.ts`, `src/scout/scout.service.ts`, `test/health-readiness-bounded.spec.ts`) are byte-identical to the archived `prep2-format/after/*` blobs (`logs/X2`). Live `git diff --cached HEAD` differs from the frozen patch text only in 96 `index` lines (7- vs 8-hex abbreviation, same phenomenon as S5); with non-persisted `-c core.abbrev=8` it is byte-identical. No config persisted — the tree id `a584a1b9` is the authority and no runner pin references this diff text.

## 3. Missing runtime inputs (file facts only; none requested here)

Absent by design: `worktrees/s3-prep2/node_modules` and `dist` (any install requires a separate grant and the S1/S2 generator/schema reservation ruling — copying prepared bytes is not schema authorization); no S3 runner/setup packet exists at an `execution/s3-*` path in this workspace (none named by the mail; not created). Present: `package.json`/`package-lock.json` (blob = S2 setup lock `354de3da`, so the S2 install provenance would match the lockfile but is a different worktree), node/npm paths, canonical lock file (not probed). The prep2 REPORT's stated revalidation need (tsc + S3 specs importing the six formatted files) remains unrun.

## 4. Untouched

Baseline `source/backend` (HEAD c23b, porcelain 0, loose 0, refs 2), archive (porcelain unchanged by this slice), `upstream/odb-prep2-verify` (`refs/prep2-tree`=a584a1b9), `worktrees/s2-runner53`.

## 5. Owned outputs

`worktrees/s3-prep2/**`; `execution/e8d546f9/s3-prep2-materialize/{REPORT.md, MANIFEST.sha256, logs/X1, X2}`; `MANIFEST.sha256` covers this directory except itself.
