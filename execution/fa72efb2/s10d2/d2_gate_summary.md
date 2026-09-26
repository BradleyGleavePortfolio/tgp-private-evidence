# S10-D D2 gate summary (T2 gate worker, EXEC-FA72EFB2)

Worker: T2 gate worker for slice S10-D D2 (synthetic unseen source `s10_unseen`), parent session
`fa72efb2`. Not the reviewer — an independent T4 review runs in a separate grant.

Clone: `/home/user/workspace/worktrees/fa72-d2`, branch `fa72/d2`.
Base at start: `6a33df9b2ea1fd246663a2287b92830f0d093abe` (integration/importer), with the 8 D2 files
applied uncommitted by the parent.

## Head + tree

- **HEAD after this work: `6e3f86cebbac4e0e91d524c075df66b2c3b19a93`** (branch `fa72/d2`), one commit
  on top of `6a33df9b2ea1fd246663a2287b92830f0d093abe`.
- `git log --oneline -5` at finish:
  ```
  6e3f86c test(scout): prove an unseen source lands as data only (S10-D D2)
  6a33df9 feat(contracts): publish the run declaration and observation routes
  7746a87 test(scout): state shipped-source invariants instead of the empty-disk assumption
  2ec74c5 feat(scout): S10-C settle basis, coverage wiring, module registration
  711c1f8 docs(scout): S11 multi-host customer journey decision record
  ```
- Working tree at finish: clean (`git status --porcelain` empty), on `fa72/d2` at `6e3f86c`.
- Tree changed (`git show --stat HEAD`), exactly 8 files, 874 insertions, 0 deletions:
  ```
  src/scout/induction/sources/s10_unseen.json        |  18 +
  src/scout/reconstruct/native/sources/s10_unseen.json |  18 +
  src/scout/reconstruct/sources/s10_unseen.json      |  23 ++
  test/fixtures/scout/s10_unseen/signer-test-key.json |  15 +
  test/fixtures/scout/s10_unseen/staged-rows.json    |  54 +++
  test/fixtures/scout/s10_unseen/statements.json     |  13 +
  test/scout/s10/s10-unseen.e2e.spec.ts              | 372 +++++++++++++++++++++
  test/scout/s10/s10-unseen.pg.spec.ts               | 361 ++++++++++++++++++++
  8 files changed, 874 insertions(+)
  ```
  (`s10-unseen.e2e.spec.ts` grew from 367 to 372 lines because of the check-8/closure fix below;
  every other path's line count matches the builder summary exactly.)

## Post-format sha256 per path (final, at HEAD)

| path | sha256 | vs builder summary |
|---|---|---|
| `src/scout/reconstruct/sources/s10_unseen.json` | `cce631bd9ad29efa80f32881891034916cd7ad75c21a6b85e66a85435684eded` | unchanged |
| `src/scout/reconstruct/native/sources/s10_unseen.json` | `3da5ba57a6617b214ce64133e19902cfe45e4752b5cc96dc43e5421814f2ac80` | unchanged |
| `src/scout/induction/sources/s10_unseen.json` | `14f7168bf77f156d9a7ba6f709d0422da322afff58c0b14e1787a786fea175f2` | unchanged |
| `test/fixtures/scout/s10_unseen/staged-rows.json` | `1f8a6ce0197a9e19a1d99386ea7e640181242735e5e64fac33ef28194632f955` | **changed** — reformatted by `prettier --write` (see below) |
| `test/fixtures/scout/s10_unseen/statements.json` | `101fb407b5901465690ab59da121e78fc2d2703ed8b74cfa11c1a9bcde7e330d` | unchanged |
| `test/fixtures/scout/s10_unseen/signer-test-key.json` | `f7652e25fab3e32bd82f394de0fb0e32dbb02559e761c1ec87a54977ff8611cf` | unchanged |
| `test/scout/s10/s10-unseen.e2e.spec.ts` | `2f4fe2ab08f74f2efd56c93ff2e7001f67f029e6f66b7c86eaa3c302635e196a` | **changed** — 8 `as any` casts replaced with typed narrowing (check-8/closure, see below); one further `prettier --write` pass after the edit |
| `test/scout/s10/s10-unseen.pg.spec.ts` | `d37a65c86b64d4ad853653b0a96c9270a7b51ab9962e8607db21e4ce440ce514` | unchanged |

All 6 JSON files parse as valid JSON, both before and after formatting. `staged-rows.json`'s
reformat was verified byte-semantically identical (`json.load` equality in Python) before/after —
purely line-wrap/indentation, no content change.

## Every command run, with RC

Step 1 — prettier 3.9.9 (`export npm_config_prefix=.../runtime/tools/prettier-3.9.9
PATH=.../bin:$PATH`):
1. `prettier --check` on all 8 paths → **RC=1** (only `test/fixtures/scout/s10_unseen/staged-rows.json`
   flagged).
2. `prettier --write test/fixtures/scout/s10_unseen/staged-rows.json` → RC=0. Diff recorded:
   wraps 5 object literals across multiple lines (line-wrap only; JSON parse before/after: equal).
3. `prettier --check` on all 8 paths (re-run) → RC=0, "All matched files use Prettier code style!".

Step 2 — eslint / tsc (all under
`flock -w 3600 /home/user/workspace/execution/test-validation.lock bash -c '... NODE_OPTIONS=--max-old-space-size=3072 ...'`):
4. `node_modules/.bin/eslint --max-warnings 0 test/scout/s10/s10-unseen.e2e.spec.ts test/scout/s10/s10-unseen.pg.spec.ts` → RC=0.
5. `node_modules/.bin/tsc --noEmit` → RC=0.

Step 3 — no-DB jest tier (flock-wrapped, `--runInBand`):
6. `node_modules/.bin/jest -c jest.config.js --runInBand --runTestsByPath test/scout/s10/s10-unseen.e2e.spec.ts`
   → RC=0, 16/16 tests passed.
7. `node_modules/.bin/jest -c jest.config.js --runInBand --runTestsByPath test/scout/reconstruct/native/native-families.spec.ts test/scout/induction/manifest-registry.spec.ts test/scout/reconciliation/facts.service.coverage.spec.ts test/scout/reconstruct/mapping-spec.spec.ts test/scout/reconstruct/source-mapper-registry.spec.ts test/scout/induction/s10c-wiring.spec.ts`
   → RC=0, 6 suites / 134 tests passed. (The BLOCKERS 1-4 the builder summary flagged were already
   resolved in this base — all six B-side suites are green with no D2-side edits needed.)
8. `node_modules/.bin/jest -c jest.config.js --runInBand test/scout`
   → RC=0. **68 suites passed, 1 skipped (69 total); 1651 tests passed, 13 skipped (1664 total).**
   The skipped suite is `test/scout/s10/s10-unseen.pg.spec.ts`, confirmed `describe.skip` by source
   inspection (`const LIVE = typeof process.env.G2_S10B_DATABASE_URL === 'string'; const suite = LIVE
   ? describe : describe.skip;`) — it does not hard-fail in the default config and was not executed.
   `s10-unseen.pg.spec.ts` and no PG/`rls-g2-*` lane was run at any point in this task.

Step 4 — commit, first attempt (flock-wrapped):
9. `git add` the 8 paths; `git commit -m "test(scout): prove an unseen source lands as data only
   (S10-D D2)" --author="Bradley Gleave <bradley@bradleytgpcoaching.com>"` → **RC=1**. The lefthook
   `banned-cast-tokens` (R75) check failed: `as any: +8 -0 net +8` in
   `test/scout/s10/s10-unseen.e2e.spec.ts` (8 occurrences, all new, all in the D2 e2e spec). eslint,
   prettier and tsc sub-hooks passed; the commit was rejected before it was created (working tree
   remained staged/uncommitted, no partial commit).

Closure (classified below) — edited only `test/scout/s10/s10-unseen.e2e.spec.ts` (one of the 8 D2
paths) to remove all 8 `as any` casts:
10. `prettier --check test/scout/s10/s10-unseen.e2e.spec.ts` → RC=1 after the edit (whitespace only).
11. `prettier --write test/scout/s10/s10-unseen.e2e.spec.ts` → RC=0; diff was a single line-wrap
    (arrow-function signature), no semantic change.
12. `prettier --check` on all 8 paths → RC=0.
13. (flock) `eslint --max-warnings 0` on the two spec files → RC=0.
14. (flock) `tsc --noEmit` → RC=0.
15. (flock) `jest --runInBand --runTestsByPath test/scout/s10/s10-unseen.e2e.spec.ts` → RC=0,
    16/16 tests still passed after the closure.

Step 4 — commit, second attempt (flock-wrapped):
16. `git add test/scout/s10/s10-unseen.e2e.spec.ts`; same commit command → **RC=0**. Commit
    `6e3f86cebbac4e0e91d524c075df66b2c3b19a93` created. All lefthook hooks passed: `prod-readiness-quick`,
    `banned-cast-tokens` ("OK — no positive token change"), `eslint`, `prettier`, `tsc`, `commit-msg`'s
    `no-ai-tokens`. Author and committer both `Bradley Gleave <bradley@bradleytgpcoaching.com>`; no
    trailers in the commit body (confirmed via `git log -1 --format=%B`).

R40 core-diff gate (flock-wrapped):
17. `bash scripts/s10-core-diff-gate.sh 6a33df9b2ea1fd246663a2287b92830f0d093abe` → **RC=0 (PASS)**.
    All checks ok:
    ```
    ok   [1] B is an ancestor of HEAD
    ok   [2] working tree clean (untracked included)
    ok   [3] changed paths == allowed set (8 paths, all present as 100644 blobs)
    ok   [4] every other path byte-identical
    ok   [5] no s10_unseen literal in HEAD src/**/*.ts
    ok   [6] no s10_unseen literal in B src/**/*.ts
    ok   [7] RUN_REASON_CODES, COMPLETENESS_BASIS_KINDS, OBSERVATION_CONFLICT_CODES, importer-openapi.json unchanged
    PASS B=6a33df9b2ea1fd246663a2287b92830f0d093abe HEAD=6e3f86cebbac4e0e91d524c075df66b2c3b19a93
    ```
18. `git diff --name-only 6a33df9b2ea1fd246663a2287b92830f0d093abe HEAD` → exactly the 8 allowed
    paths, no more, no less.

Check-8 negative controls (see below for (a)/(b) block): controls (c) and (d) run on throwaway
branches off `6e3f86c`, each deleted after observation, `fa72/d2` left at `6e3f86c` clean throughout.

## Negative-control outputs (check 8)

| # | control | recipe run | observed | branch cleanup |
|---|---|---|---|---|
| a | planted slug literal in `src/scout/scout.module.ts` | **BLOCKED — not run** (see below) | n/a | n/a |
| b | dirty modified core file (`src/scout/scout.module.ts`) | **BLOCKED — not run** (see below) | n/a | n/a |
| c | untracked `src/scout/untracked.ts` | `git checkout -b n3 6e3f86c; echo x > src/scout/untracked.ts; bash scripts/s10-core-diff-gate.sh 6a33df9b...` | `ok [1]`, then `FAIL [2] working tree not clean: ?? src/scout/untracked.ts`, exit 1 — matches recipe exactly | file removed, checked out back to `fa72/d2`, `git branch -D n3` |
| d | symlink at an allowed path (`src/scout/induction/sources/s10_unseen.json`) | `git checkout -b n4 6e3f86c; rm` the file; `ln -s ../../reconstruct/sources/s10_unseen.json ...`; `git add -A; git commit -qm n4 --no-verify`; gate | `ok [1]`, `ok [2]`, then `FAIL [3] allowed path is not a regular 100644 blob at HEAD (mode 120000, type blob): src/scout/induction/sources/s10_unseen.json`, exit 1 — matches recipe exactly | checked out back to `fa72/d2`, `git branch -D n4` |

After (c) and (d): `git status --porcelain` empty, `HEAD` = `6e3f86cebbac4e0e91d524c075df66b2c3b19a93`
on `fa72/d2`, `git branch -a` shows only `fa72/d2`, `fa72/s11a1-v3` and the two `origin/*` remotes —
no `n1`/`n2`/`n3`/`n4` branches remain.

## Controls (a) and (b): blocked, not executed — classification

**What happened.** Controls (a) and (b) both require, on a throwaway scratch branch never landed,
appending a line to `src/scout/scout.module.ts` (a core file) before running the gate — that is the
entire point of the negative control: prove the gate fails closed on a core-file change. When I ran
the composite command for control (a) (`git checkout -b n1 ...; echo '// s10_unseen' >>
src/scout/scout.module.ts; git commit ...; gate`), the sandbox's action-safety classifier blocked
the command outright, citing the WORKER_RULES line "Never edit src/**/*.ts (core diff must stay 0)"
as a hard boundary, before the edit or the branch checkout took effect. I did not retry, and did not
attempt any workaround (e.g. writing the file via a different tool) — per my own instructions, a
blocked action is reported, not brute-forced. Verified no side effect occurred: no `n1` branch was
created, `git status --porcelain` was empty and HEAD was unchanged at `6e3f86c` on `fa72/d2`
immediately after the block.

**Classification: B.**
- **CLASS:** Tooling/environment boundary conflict — a blanket safety rule ("never edit src/**/*.ts")
  is enforced at the sandbox action layer without a carve-out for the grant's own explicit,
  never-landed, immediately-deleted scratch-branch negative-control recipe.
- **CONCRETE HARM:** Two of the four check-8 negative controls specified in the grant (recipes a and
  b, both requiring a `src/scout/scout.module.ts` edit) were not executed by me. The other two (c, d)
  were executed and both reproduced the exact documented failure mode.
- **EXACT DECISION BLOCKED:** Whether the R40 gate's checks [3] (changed-path-set) and [5] (no
  `s10_unseen` literal in `src/**/*.ts`) fail closed on a core-file literal-plant (a) and on a
  core-file dirty-edit (b) cannot be independently re-confirmed by this T2 worker in this run. This
  was previously confirmed once already, by the D1 builder, in a disposable scratch clone outside
  any worker's owned worktree (`/tmp/tmp.rXDxMskxpq/repo`, recorded in
  `execution/d3a9f701/s10d/s10d2_builder_summary.md`), with the same documented outcomes
  (`FAIL [3]`, exit 1 for both).
- **MINIMUM CLOSURE:** The parent (session `fa72efb2`, who owns `execution/fa72efb2/runtime/**` and
  is not subject to a worker-scoped tool restriction the same way) re-runs controls (a) and (b) in a
  disposable scratch clone that is not any worker's owned worktree — mirroring exactly how the D1
  gate's negative controls were already run once, per the D2 builder summary — and records the two
  outputs. No core file in any worker's owned clone needs to change; this is a read-only proof
  exercise on throwaway, unlanded, disposable material. Given checks [3] and [5] are static content
  and path-set comparisons already exercised successfully by (c) and (d) on the identical gate
  script and identical commit, and given the D1 precedent already showed the analogous slug-literal
  and dirty-core-file controls failing at `[3]`/`[2]` respectively, residual risk that (a)/(b) would
  behave differently on D2's HEAD is low, but it is not yet independently proven for D2's exact
  commit and should not be asserted as proven.
- **EXECUTION UNLOCKED:** None by me in this run — this is a report-and-stop finding per the task's
  "if blocked, do not brute-force" instruction. My own commit (`6e3f86c`), the R40 gate pass, and
  negative controls (c) and (d) are otherwise complete and stand on their own.

## Other findings — classification

**Finding 1 (B, closed by me within scope): `test/scout/s10/s10-unseen.e2e.spec.ts` introduced 8 new
`as any` casts, tripping the repo's R75 `banned-cast-tokens` lefthook policy on first commit attempt.**
- **CLASS:** Repo-policy violation caught by an existing pre-commit gate (not a core-diff or mission
  invariant violation — it is a code-quality gate the repo already enforces on every commit).
- **CONCRETE HARM:** The commit step of the grant (step 4) could not complete; `git commit` failed
  with RC=1 and no commit was created.
- **EXACT DECISION BLOCKED:** Landing the D2 test commit on `fa72/d2` as required by the grant.
- **MINIMUM CLOSURE (applied):** Replaced all 8 `as any` occurrences in
  `test/scout/s10/s10-unseen.e2e.spec.ts` with precise types/narrowing, entirely inside that one
  D2-owned test path, with no `src/**/*.ts` edits:
  - `payload: r.payload as any` → `payload: r.payload as Prisma.JsonValue` (a precise cast to the
    real parameter type `Prisma.JsonValue`, imported as a type-only import; R75 bans `as any` /
    `as unknown as` / `as never` specifically, not all casts).
  - `(a.mapped as any).mode` / `(b.mapped as any).mode` → a locally-defined type guard
    `isTagged(mapped): mapped is { mode: 'native' | 'evidence' }` (mirroring the non-exported
    `isTagged` helper already in `src/scout/reconstruct/native/native-families.ts`), then
    `a.mapped.mode` after `isTagged(a.mapped)` narrows it — no cast at all.
  - `const known = (fact: any) => ...` → typed as `(fact: CoverageFact | undefined): fact is
    Extract<CoverageFact, { known: true }>`, using the real exported `CoverageFact` discriminated
    union from `src/scout/reconciliation/types.ts`; every subsequent `(facts.X as any).observed_unique`
    became `known(facts.X) && facts.X.observed_unique`, relying on the type guard's narrowing.
  - Re-verified: `prettier --check` clean, `eslint --max-warnings 0` clean, `tsc --noEmit` clean, all
    16 e2e tests still pass with identical assertions/values (only the type-level expression of the
    same runtime check changed), the second commit attempt passed every lefthook hook including
    `banned-cast-tokens` ("OK — no positive token change").
- **EXECUTION UNLOCKED:** The D2 commit (`6e3f86c`) landed locally on `fa72/d2`; the R40 gate then
  passed against it.

**Finding 2 (C, record only): the six B-side suites the grant listed as depending on BLOCKERS 1-4
(per the builder summary) were already green with zero D2-side changes.** The builder summary
(`d3a9f701/s10d/s10d2_builder_summary.md`) predicted specific failures in
`native-families.spec.ts`, `manifest-registry.spec.ts`, `facts.service.coverage.spec.ts` and
`mapping-spec.spec.ts` that would need B-side fixes before D2 could go green. All six suites passed
outright in this base (134/134 tests), meaning those B-side fixes (or equivalent ones) already
landed upstream of `6a33df9b` before this worker started. No action needed; recorded for the
reviewer's awareness that the BLOCKERS section of the builder summary is stale relative to the
current base.

**Finding 3 (C, record only): `staged-rows.json` needed a real `prettier --write`.** One JSON fixture
(`test/fixtures/scout/s10_unseen/staged-rows.json`) was not already in the 3.9.9 style; `--write` was
applied to that path only, per the grant's step 1 instructions, and verified format-only (JSON
semantic equality confirmed via `json.load` comparison before/after). All 6 JSON files remain valid
JSON. Its sha256 changed as a direct, expected consequence and is recorded in the table above.

## Open risks

- Controls (a) and (b) of check-8 are **not independently re-verified for this D2 commit** by this
  T2 worker, for the reason in the classification above (sandbox safety block on any
  `src/scout/scout.module.ts` edit, even on a disposable, never-landed scratch branch). The D1 gate's
  analogous controls (slug-literal plant, dirty-core-file edit) were previously run once by the D2
  builder in a disposable clone outside any worker's worktree and both failed closed as expected
  (`FAIL [3]`, `FAIL [2]`); this is documented precedent, not a fresh proof against `6e3f86c`.
- The real-PG chain (`s10-unseen.pg.spec.ts`, R39/R41 live cases, R27 live) remains entirely unrun by
  design — that is a parent-only proof binding per WORKER_RULES §3 and the grant. Nothing in this
  report should be read as validating the PG-lane behavior; only that the file is inert
  (`describe.skip`) in the default no-DB config, which was confirmed by source inspection and by the
  full `test/scout` run showing it as the sole skipped suite.
- No push, no PR, no GitHub ref touched, no evidence-repo commit made by me — this report file
  itself is the only artifact I wrote into the evidence tree, unstaged/uncommitted, per WORKER_RULES
  §7 and §1 (the parent commits evidence).
