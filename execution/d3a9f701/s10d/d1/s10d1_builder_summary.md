# S10-D D1 builder summary

**Where:**
- Worktree: `/home/user/workspace/worktrees/d3a9-s10d`, branch `exec-d3a9/s10d`, base `92b96715`.
- Spec: `docs/decisions/2026-09-26-s10-induction.md`, D-S10-7 row S10-D (L357), D-S10-5 (L297-321) and D-S10-1 "G2 packaging" (L94-96).

**Rules followed:** I ran no npm, jest or tsc, took no lock and made no commit. Only the two owned paths changed (`git status`: ` M nest-cli.json`, `?? scripts/s10-core-diff-gate.sh`). D2 is not touched.

## Files

| Path | sha256 | Notes |
| --- | --- | --- |
| `nest-cli.json` | `3fd103daca90a295ce5dabacf3e03b8fb008225edacf0dcda00abc1afbdc7c87` | +2 asset entries (diff below) |
| `scripts/s10-core-diff-gate.sh` | `4741d776246ad24d876cbd2be48804db96d14fcbabe9e992ca63d56555a56d9f` | 183 lines, mode 0755 (the executable bit is set in the worktree; `git add` records it) |

`nest-cli.json` diff. These are the two generic entries D-S10-1 names; the existing entry only gains a trailing comma:

```
-      { "include": "scout/reconstruct/sources/*.json", "outDir": "dist" }
+      { "include": "scout/reconstruct/sources/*.json", "outDir": "dist" },
+      { "include": "scout/reconstruct/native/sources/*.json", "outDir": "dist" },
+      { "include": "scout/induction/sources/*.json", "outDir": "dist" }
```

They match the loaders' `join(__dirname, 'sources')` directories: `native-rule-registry.ts` L6-12, and `INDUCTION_MANIFESTS_DIR` in `src/scout/induction/manifest-registry.ts`. The file parses as JSON.

## Invocation

```
scripts/s10-core-diff-gate.sh <B-full-40-hex> [<HEAD>]
```

- Run it from anywhere in the repository (it `cd`s to the top level).
- `<HEAD>` is optional but must resolve to the checked-out HEAD. Checks 2 and 5 read the working tree, so gating a different commit is refused rather than silently gating the checkout.
- Exit 0 means PASS. Any other exit means FAIL, with the failing check number on stderr. Each passed check prints an `ok [n]` line.

The checks follow D-S10-5 in order. Any failure, or any tool exit ≥ 2, fails the gate.

| # | Check |
| --- | --- |
| 1 | `git merge-base --is-ancestor B HEAD` |
| 2 | `git status --porcelain --untracked-files=all` is empty |
| 3 | `git diff --no-renames --name-only B HEAD`, sorted and de-duplicated, **equals** the 8-path allowed set exactly, and every allowed path exists at HEAD (so none may be missing or deleted) |
| 4 | `git diff --no-renames --binary --exit-code --quiet B HEAD -- . ':(exclude,literal)<each allowed path>'` |
| 5 | `rg -F -l s10_unseen src --type ts` exits exactly 1. Exit 0 (a hit) or ≥ 2 (a tool error) fails. |
| 6 | The same over B's `src/`, extracted with `git archive B src` into a `mktemp -d` scratch directory (removed on exit) |
| 7 | B declares each of `RUN_REASON_CODES` (`src/scout/lifecycle/reason-codes.ts`), `COMPLETENESS_BASIS_KINDS` and `OBSERVATION_CONFLICT_CODES` (`src/scout/induction/contract.ts`), and those two files plus `docs/contracts/importer-openapi.json` are byte-identical between B and HEAD |

**Allowed set** (from D-S10-5, verbatim):
- `src/scout/{reconstruct/sources,reconstruct/native/sources,induction/sources}/s10_unseen.json`
- `test/fixtures/scout/s10_unseen/{staged-rows,statements,signer-test-key}.json`
- `test/scout/s10/{s10-unseen.e2e.spec.ts,s10-unseen.pg.spec.ts}`

**Pipefail rule:** there is no `cmd | grep -q` anywhere. Every command runs under `set +e`, its output and exit code are captured, and then both are tested. The comparisons use bash string equality and `case`, never a pipe into grep.

**Hardening:**
- `set -euo pipefail`.
- `RIPGREP_CONFIG_PATH`, `GIT_DIR` and `GIT_WORK_TREE` are unset.
- `LC_ALL=C sort`, and `core.quotePath=false` so non-ASCII paths compare literally.
- `--no-renames`, so a rename shows up as a delete plus an add and cannot hide a removed core path.

## What it refuses (arguments)

- A missing, extra or non-40-hex B, including short ids (tested).
- A B that does not resolve to itself as a commit.
- A B equal to HEAD.
- A `<HEAD>` other than the checked-out commit.
- Running outside a git work tree.
- `git` or `rg` not installed.

## Self-test

The D-S10-7 owned set for D1 is exactly `nest-cli.json` plus the script, so I shipped no committed self-test. Instead I exercised the script by hand. I made a throwaway `git clone --shared` of the worktree in `/tmp/tmp.QSwewgz5nF`, outside the workspace, with nothing pushed. In it I committed B (the D1 files) and then a synthetic D2 containing only the 8 allowed paths.

| Case | Result |
| --- | --- |
| Positive: D2 against B | PASS, exit 0 (all 7 `ok` lines) |
| N1 planted slug literal in a core file (`src/scout/induction/contract.ts`, committed) | FAIL [3]. With check 3 disabled in a copy: FAIL [4]. With checks 3 and 4 disabled: FAIL [5], naming the file. Every layer discriminates on its own. |
| N2 dirty modified core file (`src/main.ts`, uncommitted) | FAIL [2] |
| N3 untracked `src/zz_untracked.ts` | FAIL [2] |
| N4 one allowed path deleted | FAIL [3] |
| N5 12-hex B | FAIL [args] |
| N6 `nest-cli.json` changed in D2 | FAIL [3] |
| N7 `reason-codes.ts` changed, checks 3 and 4 disabled in a copy | FAIL [7] |

N1–N3 are the three D-S10-5 (8) negative controls. D-S10-5 says those are parent-run on scratch branches and never landed, so for R40 you need to re-run them against the real pinned B.

**Manual recipe for R40.** In a scratch clone checked out at the D2 commit:
- **Positive:** `scripts/s10-core-diff-gate.sh <B>`, expect exit 0.
- **(a)** Commit a `'s10_unseen'` literal into any `src/**/*.ts` core file, expect exit 1.
- **(b)** Modify a core file without committing, expect FAIL [2].
- **(c)** `touch src/x.ts`, expect FAIL [2].

## Notes and limits

- **What B must contain:** B must include this script and the S10-A/B/C files. Check 7 requires `src/scout/induction/contract.ts` at B, which S10-A (`92b96715`) provides.
- **The gate script is itself outside the allowed set.** So D2 cannot modify the gate: check 4 would catch it.
- **Check 5 reads the working tree.** Check 2 has already required that tree to be clean and on HEAD, so it is equivalent to HEAD's tree.

## Fix round 1 (D1 review NO-GO: object modes)

**Finding:** check 3 verified that the allowed pathnames were present at HEAD, but not their git object mode. A committed symlink at an allowed JSON path passed the gate.

**Fix:** only `scripts/s10-core-diff-gate.sh` changed.
- Check 3 now runs `git ls-tree --full-tree HEAD -- <path>` for every allowed path. It captures the output and exit code first, then tests them:
  - the tool must exit 0;
  - there must be exactly one entry, and its name must equal the path;
  - the mode must be exactly `100644` and the type exactly `blob`.
- Anything else fails `[3]`: symlink `120000`, gitlink `160000` (type commit), executable `100755` (the doc allows no executable path), a tree, or a missing path.
- There is no `| grep -q`. Parsing uses bash parameter expansion and `case`.

| File | sha256 | Lines |
| --- | --- | --- |
| `scripts/s10-core-diff-gate.sh` | `0af7ee2b3092c8632b62afbf7e9ba463203b71adb295c9aad70627df866d268f` | 200 |

The diff (old sha `4741d776…a56d9f` → new) is at `/home/user/workspace/private-evidence/execution/d3a9f701/s10d/d1-fix-1.diff`. `nest-cli.json` is unchanged.

**Self-test** (same `/tmp` scratch clone; the worktree script was run against the scratch repo):

| Case | Result |
| --- | --- |
| Positive: synthetic D2 against B | PASS, exit 0 |
| S1 symlink: `src/scout/induction/sources/s10_unseen.json` committed as a `120000` link to `../../../../package.json` | new gate: FAIL [3] `mode 120000, type blob`; old gate (the B copy): **PASS**, which reproduces the finding |
| S2 `test/scout/s10/s10-unseen.pg.spec.ts` committed as `100755` | FAIL [3] `mode 100755` |
| S3 `test/fixtures/scout/s10_unseen/statements.json` committed as a `160000` gitlink | FAIL [3] `mode 160000, type commit` |

**Check-8 recipe, updated for R40.** Run these on scratch branches against the real pinned B; none may land.
- **(a)** Planted slug literal in a core file: expect exit 1.
- **(b)** Dirty modified core file: expect FAIL [2].
- **(c)** Untracked `src/` file: expect FAIL [2].
- **(d)** Symlink at an allowed path. Replace, for example, `src/scout/induction/sources/s10_unseen.json` with a symlink (`ln -s ../../../../package.json …`), then `git add -A && git commit`. Expect FAIL [3] `mode 120000`.
