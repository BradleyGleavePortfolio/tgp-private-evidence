# S3 FINAL-HEAD-B — source/applicability + targeted-validation portion (interim, NOT the all-evidence verdict)

Attestor B `audit_s5_failure_lens_b_mue9oser`, parent EXEC-6c2a68ac. Scope `S3_FINAL_HEAD_REVIEW_SCOPE.md` sha256 `f7230b0fa356d3c4…`. Method: Git object reads (`GIT_OPTIONAL_LOCKS=0 git cat-file/ls-tree/show/diff/rev-list/bundle verify`), file hashes, byte/line diffs, one scratch `index-pack` of the bundle pack into `/tmp` with a read-only alternates pointer. No tests, node, probes, locks, index/worktree/hook/config/private writes. Peer dir `audits/s3-final-head-a/**` and parent disposition files (`S3_STEP08_DISPOSITION_AND_VALIDATION_ACTIVATION.md`) not read.

Status: **SOURCE-READY and TARGETED-VALIDATION-CONSISTENT; final all-evidence verdict withheld** until the frozen composed-proof (S2-owner composed-lock deepmerge 8 release proof) result is supplied. This is the same owned review; no second source audit will be run.

## 1. Exact head (independent from objects)

| Item | Observed | Expected |
|---|---|---|
| HEAD / `refs` | `be0ba8274e486dee77f15d18fe367a13ff08ecf5`, detached, no ref points at it (`for-each-ref` 0 hits) | be0ba827 |
| Tree | `a584a1b95423f95dae8daabf673ef3776604acbb` == `refs/restored/prep2-tree`; `git diff --quiet a584 be0ba827^{tree}` identical | a584 |
| Parents | `d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c` `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06` (merge-base `c23b9d9f…`) | same |
| Author == committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` 1790182437 +0000 | same |
| Trailers | `%(trailers)` empty; `gpgsig` lines 0 | none |
| Message | 719 bytes, byte-identical (`cmp`) to `s3-integration-continuation/steps/07-commit-message.txt` (sha256 `987ba832…`); banned-token grep 0 | authored file |
| Commit object sha256 | `297de278899a32f92d5529294c09d8f37317fc77eacebe9b2aa7486e7c4833c8` | matches 08D and V9 |
| Worktree | `MERGE_HEAD` absent, porcelain 0 (`--untracked-files=all`), hooks `pre-commit`/`commit-msg` present, `core.hooksPath` unset, repo-local `[user]` = operator identity | |

## 2. Preservation matrix independently re-derived (ls-tree of a584 vs d5cd, 5c7b, c23b)

Result: 2116 paths in a584; **38 S1S2_PRESERVED** (blob == d5cd, != 5c7b), **38 S3_PRESERVED** (blob == 5c7b, != d5cd), **10 CHANGED** (blob matches neither parent), **0 unexpected**; no path present in d5cd is missing from a584; `.github/workflows/fly-logs-dump.yml` absent in a584 follows d5cd (S1/S2 deletion). Path/class columns equal both `s3-restore/PRESERVATION_MATRIX.rederived.tsv` and `prep2-format/PRESERVATION_MATRIX.tsv` (both sha256 `2d75f532f9f46454…`).

The 10 changed paths and what each actually is:

| Path | Class | Independent observation |
|---|---|---|
| `.github/workflows/ci.yml` | AUTO_MERGED | `git merge-file` of d5cd/c23b/5c7b reproduces a584 byte-for-byte (rc 0). S3 side adds one `Lint control sources` step (7 files, all present in a584); S2 side is a comment-only NOTE rewrite in the RLS job. |
| `.github/workflows/r100-quality-gate.yml` | RESOLVED | 3-way merge conflicts (rc 2). a584 = S3 `banned-casts` job block **byte-identical** to 5c7b (first 42 lines of the jobs section; diff shows only the deletion of `loc-budget`/`test-density`), S2 retirement of those two jobs applied, `on/permissions/concurrency` block identical to d5cd, header prose now points to `.github/r75-policy.json`. Single job `banned-casts` running `node scripts/check-r75.js --mode=range --base="$BASE_SHA" --head="$HEAD_SHA"`; non-certifying `workflow_dispatch` path and missing-base fail-closed retained. |
| `test/ci/r100-pathspec.spec.ts` | RESOLVED | merge-file is textually clean but PREP1 deliberately replaced the workflow-guard describe: the old bare-pathspec / density-denominator assertions (which would fail against a workflow with no pathspec) are replaced by assertions that the workflow delegates to the checker, carries no `PATHSPEC=(`/`TOKENS=(`/`grep -c`/`:(glob)` of its own, names the policy file, and that policy scope includes top-level+nested src TS/JS, `scripts/*.js`, `dangerfile.js`, test sources, and excludes workflow/policy files. `inPolicyScope` in the spec mirrors `scripts/check-r75.js` `inScope()` line-for-line (verified). Git-plumbing block (first describe) unchanged. Not a weakening: assertions moved to the data that now defines scope. |
| `test/ci/r75-gate.spec.ts` | RESOLVED | Only change vs 5c7b: the `it('the LOC and density jobs keep their own measurement pathspecs')` test (asserting `loc-budget:`/`test-density:` exist) is removed with a comment pointing at `test/ci/delivery-artifact.spec.ts` (`jobIds toEqual(['banned-casts'])`, `not.toMatch(/LOC budget|Test density/)`) — confirmed present in a584 (== d5cd). All other R75 gate tests retained. |
| `src/filters/throttler-exception.filter.ts`, `src/scout/scout.service.ts` | FORMATTED | Equal to 5c7b after stripping all whitespace. |
| `src/observability/logging.interceptor.ts`, `src/prisma.service.ts`, `test/health-readiness-bounded.spec.ts` | FORMATTED | Equal to 5c7b after stripping whitespace **and commas**; the only non-whitespace deltas are Prettier trailing commas (import collapse −1; two argument wraps +1 each). Diff bodies inspected: import collapse, `getRequest<…>()` wrap, `logger.warn(` wrap, `toMatchObject({` wrap. |
| `src/observability/README.md` | FORMATTED | Equal to 5c7b after stripping whitespace and `-`; the only deltas are five markdown table separator rows re-padded. |

No conflict markers in any of the 10 files. d5cd equals base for the five formatted source files (S2 did not touch them), so "formatting-only relative to S3" is the exact and correct claim.

## 3. Failures recorded independently from receipts (not relabelled)

- **Original step 03** (`s3-integration-result`, manifest `bf7800bd…` 20/20 OK, untouched): raw `exit=0`, `Generated Prisma Client (v6.19.3)` rc 0, postcheck `deepmerge-ts version rc=1 expected=8.0.0 actual=` → `step_status=1`. Stays a failure of the recording expression (`require('deepmerge-ts/package.json')` against an exports map without `./package.json`), per my sealed `s3-step03-bfix` (`25f049dd…`). 03D fs-read shows 8.0.0.
- **03R** (continuation, `ca604a0d…` 23/23 OK): separate fs-read observation, printed exactly `8.0.0`, installed package.json sha256 `9db12600…`, lock entry 8.0.0, lock sha256 `b7fed5ed…`, write-tree a584, no nested deepmerge-ts under `@prisma/config`; raw 0, `step_status=0`; log itself states the original step 03 keeps `step_status=1`.
- **Step 07** hooked commit: lefthook v2.1.9 pre-commit ran `prod-readiness-quick`, `banned-cast-tokens` (`check-r75.js --mode=staged`), `prettier --check` ("All matched files use Prettier code style!"), `eslint`, `tsc` — all ✔ (46.98 s); commit-msg `no-ai-tokens` job ran; `LEFTHOOK`/`LEFTHOOK_EXCLUDE` unset; no `--no-verify`.
- **Step 08 raw 127**: `logs/08-post-commit-identity.log` shows the first four post-checks (%T, %P, author, committer) rc 0, then `bash: -c: line 7: syntax error near unexpected token '('` at the lane's own unquoted `--format=%(trailers)`; `exit=127`, `step_status=127`. This is a defect in the lane's check script line, not in the commit. Stays recorded as 127.
- **08D** (read-only diagnostic) and **my §1 re-derivation** independently satisfy every request-03 §3 identity line (tree, parents, author==committer, no trailers, message bytes, tree-identical, MERGE_HEAD absent, porcelain 0, banned tokens 0, gpgsig 0).
- Continuation grant pin: R0 pinned `S3_STEP03_RECORDING_CONTINUATION.md` = `17d21fa8…`; the file now hashes `fd0c5717…`. Reconstructed from private history: `17d21fa8` = the file at commit 2641f29; the later commit 90ff9a6 changed only the status sentence (ACTIVE → CONSUMED, pointer to the step-08 disposition). Documentary, not a change of the executed instructions.

## 4. Targeted validation packet (`s3-integration-validation`, supplied 10:14) — inspected independently

- Manifest `1513911d7b9bea05…` 27 entries, 27/27 OK, non-self-including. Packet: REPORT, bundle, bundle.sha256, logs 09–14 + V0/V9 + two empty runner.out, steps.
- Every step header pins `head=be0ba827 merge_head= write_tree=a584`, every footer `write_tree_after=a584`, every post-check `write-tree`/`HEAD unchanged` rc 0, `postchecks_exit=0`, `step_status=0`; V9: porcelain 0, lock `b7fed5ed…`, hooks present, npx cache 0, lane procs 0, canonical lock not held.
- **09 bundle**: file sha256 `d204a582acab8c07ec108ceca5411fa2786756742b1917c89fe76f85195e2d7b` (matches `bundle.sha256`); header v2, prerequisite `c23b9d9f…`, single head `be0ba827 HEAD`; `git bundle verify` against the worktree "is okay"; scratch index of its pack: 47 commits / 243 trees / 214 blobs, commit set **identical** to `rev-list c23b9d9f..be0ba827` (47), contains tree a584, commit object sha256 `297de278…`.
- **10/11 check-r75 range** (base c23b and base d5cd → HEAD, policy read from `be0ba827:.github/r75-policy.json`): "as any: +2 -2 net 0 — OK, no positive token change", raw 0.
- **12 control-source lint**: file list identical to request-03 step 12 **and** to the `Lint control sources` step in a584's `ci.yml`; zero output, raw 0.
- **13 tsc --noEmit**: zero diagnostics, raw 0 (covers the five formatted .ts files).
- **14 Jest targeted**: executed 20-path list identical (set compare) to request-03 §4 final list; `31 suites passed / 825 tests passed / 0 failed / 0 snapshots`, 825 `✓` lines, 0 `✕`, 0 console/error lines, 288.956 s (< 1800 s bound). The six-file applicability rows (rate-limit, orm-composed-http, importer-contract, observability dir, feature-flag bootstrap, scout suite, health readiness bounded/public) are all present in the PASS list.
- Not claimed by the packet and not by me: full suite, build, deployment, composed-lock release proof.

## 5. Classification (Bradley A/B/C)

No A. No B. C items recorded in `FINDINGS.md` (FHB-01…FHB-04); none moves the frozen acceptance or warrants a new audit cycle.

## 6. Position for the parent

Source/applicability portion and targeted validation portion: **consistent, no concrete material defect; source-ready.** Retained unchanged evidence (S3 applicability rev-1 `1f2a9c69…`, prep2-format `c49487ed…`, s3-restore `bd9e6cd8…`) remains applicable to head be0ba827 because tree a584 is exactly what those documents analysed. Awaiting the frozen composed-proof result to complete the SAME review and issue the non-self-including input/result seal; until then no all-evidence verdict is issued here.
