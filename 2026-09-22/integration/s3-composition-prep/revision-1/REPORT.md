# S3-INTO-S1S2-PREP-1 — composition preparation (revision 1)

Written 2026-09-22 ~05:00 UTC. Writer: the S3 integration analyst acting as sole **preparation** writer (requested Claude Fable 5; runtime model/setting not exposed, not claimed). Because I authored this resolution I cannot be one of its two independent attestors.

**State: a staged, uncommitted, untested draft merge tree.** Not a commit, not a candidate head, not built, not linted, not Jest-run, not audited. No install/test/DB/remote/hook execution occurred. Both input heads, their bundles, the audited/restored clones and the builder worktrees are unchanged.

## 1. Inputs and isolation

| Item | Value |
|---|---|
| Worktree | new isolated clone `/home/user/workspace/worktrees/s3-composition-prep` (`git clone --no-local` of `source/backend`, no shared `.git`), branch `execute/20260922-s3-into-s1s2-prep` |
| Parent 1 (HEAD) | S1+S2 frozen `d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c`, tree `c0ab87d4dc584b2a7ccad53db16fa551b93fe359`, fetched from bundle `s2-composition-r3-d5cd9b8b-from-public-c23b9d9.bundle` sha256 `3b6cee481319dd518268b7573ebed142fa234e193b874d8712a6cdf5493c0f75` (`git bundle verify` ok) → `refs/inputs/s2-d5cd` |
| Parent 2 (MERGE_HEAD) | S3 frozen `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06`, tree `83211d25d714e4c539cd3aa248a06ef0658fc8e7`, from `s3-backend-5c7b42b3.bundle` sha256 `940ce711a692b40325f3a1ad77aa0b1153cbfbad29c9fe8ef2a1a85b1c6f7b29` (ok) → `refs/inputs/s3-5c7b` |
| Public base | `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` (merge base of both parents) |
| Merge command | `git merge --no-commit --no-ff refs/inputs/s3-5c7b` → `ci.yml` auto-merged, `CONFLICT (content)` in `.github/workflows/r100-quality-gate.yml` (stdout in `raw/merge-stdout.txt`; raw conflicted file `raw/r100-quality-gate.CONFLICT.yml`, same hunks as the analysis' merge-tree output; byte hash differs only by conflict-marker labels `HEAD` vs `d5cd9b8b`) |
| Mechanical merge tree (conflicted, for reference) | `git merge-tree --write-tree d5cd9b8b 5c7b42b3` in this clone → `14be0c7f64b2cd6eb53c7c628e3daf5ac610f679` |
| **Staged index tree** | **`78a4f0e8c22e9b9e902bbaae0b9f5623b9fbfa69`** (`git write-tree`; stable across re-runs). Unmerged paths 0; worktree identical to index. |
| Commit | **None.** lefthook hooks are not installed (no `node_modules`, `core.hooksPath` unset); per brief, no empty-hook commit was made. `.git/MERGE_HEAD` retained so a future `git commit` under a named slot produces a genuine two-parent merge. `user.name`/`user.email` set locally to Bradley Gleave for that future commit; nothing committed. |

## 2. Manual resolution — exactly three files

Only the three authorized paths differ from the mechanical merge result (`git diff 14be0c7f 78a4f0e8 --name-only` = these three). Everything else in the staged tree is the mechanical merge of the two parents.

### 2.1 `.github/workflows/r100-quality-gate.yml` (index blob `0ad6eb8b…`, 78 lines)
- Job section = S3's `banned-casts` job, byte-for-byte (setup-node 20.20.1, `persist-credentials: false`, non-certifying `workflow_dispatch`, fail-closed missing base/head, `node scripts/check-r75.js --mode=range --base="$BASE_SHA" --head="$HEAD_SHA"`). `git diff 5c7b42b3 -- <file>` shows only the header hunk and the deletion of `loc-budget`/`test-density`.
- S2's retirement of `loc-budget` / `test-density` retained: jobs present = `['banned-casts']`.
- Header: S2's retirement notice kept; S3's "per token / committed checker / hook cannot diverge" sentence merged in; S2's stale "Measurement scope … excluding *.test.* / *.spec.*" paragraph (false against the policy, which scans test sources) replaced by a pointer to the `scan` block of `.github/r75-policy.json`. S3's LOC/test:src/exemption-marker prose dropped (those jobs no longer exist). No `LOC-EXEMPT|TEST-EXEMPT|LOC_LIMIT|RATIO_MIN` inside the `jobs:` section (S2 `delivery-artifact.spec.ts` guard); the two remaining `[LOC-EXEMPT:]`/`[TEST-EXEMPT:]` mentions are S2's own header text.
- YAML parses (python `yaml.safe_load`): `on: [pull_request, workflow_dispatch]`, `jobs: [banned-casts]`. `git diff --check` clean; single trailing newline.

### 2.2 `test/ci/r100-pathspec.spec.ts` (+75/−21 vs parent 1)
- First describe (`git diff -- <pathspec>` plumbing, 5 tests) unchanged; header comment now explains the workflow carries no pathspec and why the plumbing tests are kept.
- Second describe retargeted from "workflow guards against reintroducing the bare pathspec" (which asserted `:(glob)` literals that no longer exist anywhere in the composed workflow) to "workflow delegates measurement scope to the committed checker and policy": (1) job runs `node scripts/check-r75.js --mode=range` with `--base="$BASE_SHA"`/`--head="$HEAD_SHA"`; (2) workflow contains no bare or `:(glob)` file-glob, no `PATHSPEC=(`, no `TOKENS=(`, no `grep -c` (no second implementation to drift); (3) header names `.github/r75-policy.json` and no longer carries the stale `excluding *.d.ts` scope prose; (4) policy DATA scope covers `src/top.ts`, `src/nested/deep.ts`, `src/top.js`, `src/nested/widget.jsx`, `scripts/relevance.js`, `dangerfile.js` (the same fixture set the old pathspec tests protected); (5) test sources are in scope and workflow/policy files are not. The scope predicate mirrors `scripts/check-r75.js inScope()` over the JSON so a policy regression is caught; the checker's own behaviour against real Git objects remains covered by `test/ci/r75-boundaries.spec.ts` / `r75-gate.spec.ts` (stated in the comment). Scope of coverage is not shrunk: every path class the deleted assertions guarded is still asserted, plus the "no inline scan" invariant.

### 2.3 `test/ci/r75-gate.spec.ts` (−6/+4 vs parent 2)
- Removed the single `it('the LOC and density jobs keep their own measurement pathspecs')` (asserted `loc-budget:`, `test-density:`, `:(glob)scripts/**/*.js'` — all retired by S2). Replaced by a comment pointing to the existing coverage: only-`banned-casts` invariant in `test/ci/delivery-artifact.spec.ts`, no-inline-pathspec invariant in `test/ci/r100-pathspec.spec.ts`. All other tests in the describe (checker in range mode, hook in staged mode, no `grep -c`, non-certifying dispatch) unchanged.

Static checks on the three files: `git diff --check` clean; no R75 banned tokens introduced (grep for every literal token; `as` casts limited to the `JSON.parse(...) as {…}` shape already used by `r75-wiring.spec.ts`); line width ≤100 except one pre-existing base line (108) untouched.

## 3. Acceptance-criteria evidence (static only)

| Criterion (brief) | Evidence |
|---|---|
| S3 banned-casts checker retained | `r100-quality-gate.yml` job body identical to S3's; `git diff 5c7b42b3 78a4f0e8 -- .github/r75-policy.json scripts/check-r75.js lefthook.yml` empty |
| S2 retired quota jobs remain absent | YAML `jobs == ['banned-casts']`; `test/ci/r75-gate.spec.ts` no longer demands them |
| Header points to authoritative r75 policy | line 20–23 of the resolved file |
| Workflow-dependent tests match | §2.2/§2.3; assertions statically re-simulated in Python against the resolved files (22/22 predicates true, incl. S2's `delivery-artifact` job-id regex and S3's `r75-gate` string checks) — **not** a Jest run |
| S3 source/lock/dependency-audit blobs preserved | `git diff 5c7b42b3 78a4f0e8 -- src fly.toml package.json package-lock.json lefthook.yml eslint.config.js .github/r75-policy.json scripts/check-r75.js .github/workflows/dependency-audit.yml .github/workflows/danger.yml docs/dependencies test/health-readiness-bounded.spec.ts test/dependency-compatibility.spec.ts test/observability test/scout test/ci/r75-{wiring,enforcement,boundaries}.spec.ts test/ci/dependency-audit.spec.ts test/ci/fly-readiness.spec.ts test/ci/fixtures` → only `A test/ci/fixtures/fake-gh.sh`, `A test/ci/fixtures/gate-lockfile.json` (S2's additions); zero modifications. Blob ids equal for `src/health/health.controller.ts 0d73bd31`, `.github/r75-policy.json fc51e1f5`, `scripts/check-r75.js bf05288a`, `package-lock.json 354de3da`, `dependency-audit.yml d9c0ddf1`. |
| Every S1/S2 migration/verifier/release/harness input preserved | `git diff d5cd9b8b 78a4f0e8 -- prisma test/db scripts docs Dockerfile .dockerignore test/release test/ci/delivery-artifact.spec.ts test/ci/release-evidence-gate.spec.ts .github/workflows/{fly-*,sbom,codeql}.yml` → only `A docs/dependencies/2026-09-op81-dependency-repair.md`, `A scripts/check-r75.js` (S3's additions); zero modifications. Blob ids equal for `verify.sql 11836f0c`, `scripts/release.sh c86b3ab9`, `test/release/s1s2-composition.sh 38b70f54`, `test/db/_support/s1-truncate-controls.sh a07e4f8a`, `Dockerfile 2d66a193`. `fly-logs-dump.yml` stays deleted. |
| Exact tree and parents attributable | `STAGED_TREE_STATE.txt`; `patches/full-vs-parent1-d5cd9b8b.patch` and `patches/full-vs-parent2-5c7b42b3.patch` each re-applied with `git apply --cached` onto a fresh index of the respective parent and reproduce `write-tree == 78a4f0e8c22e9b9e902bbaae0b9f5623b9fbfa69` |
| Changed-path accounting | vs parent 1: 48 paths = S3's 47 + `test/ci/r100-pathspec.spec.ts`; vs parent 2: 42 paths = S2's 41 + `test/ci/r75-gate.spec.ts`. `ci.yml` merged copy contains both S3's `Lint control sources` step and S2's schema-setup note (YAML parses; step present in `build-and-test`). |

## 4. Not done / blocked (unchanged from parent judgment)

- No `git commit`; no Jest, tsc, eslint, `check-r75.js`, build, install, Docker, DB, network, push.
- Dynamic acceptance blocked on: real S1/S2 proof (B3) and TRUNCATE discriminator on untouched `d5cd9b8b`; then composed-lock applicability (release.sh path resolves `deepmerge-ts` 8.0.0 via `@prisma/config` in this tree — see applicability REPORT §3.4); then the targeted checks listed in applicability REPORT §7(d–e) on a committed exact head; then two independent non-author attestations.
- The comment added to `r100-quality-gate.yml` claims `test/ci/r75-boundaries.spec.ts` and `test/ci/r100-pathspec.spec.ts` assert the policy scope; the latter is true only once the edited spec actually runs green — a Jest run is required before that sentence is evidence.
- `patches/manual-resolution-vs-mergetree-0aa8a00a.patch` is an empty artifact from a failed command (that tree id exists only in the analysis clone); superseded by `manual-resolution-vs-mechanical-mergetree-14be0c7f.patch`. Left in place, not evidence.

## 5. Recovery

Immutable inputs untouched. The draft is reproducible from either parent plus the corresponding full patch (verified). Resolved file copies in `resolved/`. If the worktree is discarded, `git read-tree <parent>` + `git apply --cached` of the matching patch recreates tree `78a4f0e8…`; committing it later requires `MERGE_HEAD=5c7b42b3` (or `git commit-tree 78a4f0e8 -p d5cd9b8b -p 5c7b42b3`) under Bradley identity and a named slot for hooks.

## 6. Packet contents

`REPORT.md`, `STAGED_TREE_STATE.txt`, `raw/merge-stdout.txt`, `raw/r100-quality-gate.CONFLICT.yml`, `resolved/.github/workflows/r100-quality-gate.yml`, `resolved/test/ci/r100-pathspec.spec.ts`, `resolved/test/ci/r75-gate.spec.ts`, `resolved/INDEX_ENTRIES.txt`, `patches/*.patch`, `SHA256SUMS.txt` (excludes itself).
