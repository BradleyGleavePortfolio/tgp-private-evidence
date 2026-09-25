# S9-A Phase-2 independent review B (T4, non-builder) — exact candidate be88909f

- Reviewer: S9-A final reviewer B (EXEC-1910A060). Independent of reviewer A; reviewer A's Phase-2
  output was not read (the `s9a/reviews/` directory held no file from A when this review was written).
- Read-only against the candidate: git object inspection only in `/home/user/workspace/worktrees/1910a060-s9a`
  (`git cat-file`, `git show`, `git ls-tree`, `git diff-tree`, `git log`). No npm/jest/tsc/prettier/hooks,
  no lock, no commit, no push, no evidence-repo commit. This file is the only file written.
  (A throwaway token-comparison script was briefly created under `reviews/` by mistake and moved to
  `/tmp` before any other action; the evidence tree contains no residue from it.)
- Written 2026-09-25 ~22:00Z. Inputs read in full: `1910a060/SCOPE.md`, `AGENT_RULES.md`, Safety-ROI
  doctrine (`6c2a68ac/OWNER_SAFETY_ROI_AND_EXECUTION_DOCTRINE.md`), Phase-1 `S9_A_REVIEW_A.md` and
  `S9_A_REVIEW_B.md`, `S9_A_SOURCE_READY.md`, landed decision doc at `1c5fbb04` (sha re-hashed
  `cda68d826be08e5bf5cd1152ecbb092b10dfc373c7234bd73943815d0d07bab1` ✓), `s9a/SOURCE_RECOVERED.md`,
  `s9a/GATE_PLAN.md`, `s9a/COMMIT_READY.md`, `s9a/freeze/**`, `s9a/gate/**`. Accepted S9-0 was not re-audited.

## 1. Exact candidate and lineage

| Check | Observed | Result |
| --- | --- | --- |
| Commit object | `be88909f4bf6a727a3bd376385aba91f209f989a`; `tree 54349476c9f92296f4595bda45d64a48534c4553`; single `parent 1c5fbb0441178e0cfe6e9f8d72e955c645c265e9` | ✓ matches the task pin exactly |
| Author / committer | both `Bradley Gleave <bradley@bradleytgpcoaching.com>`, `1790372107 +0000` (2026-09-25T21:35:07Z) | ✓ (G05) |
| Trailers | `git log --format=%(trailers)` empty; message grep for `co-authored|generated|signed-off|claude|anthropic|openai|gpt|perplexity|\bai\b|\bagent\b` → none | ✓ no trailers, no identity tokens |
| Message | `gate/committed-message.txt` = `gate/commit-message.txt` (sha `1669d02c…`) except the trailing newline `%B` appends | ✓ |
| Delta vs parent | `git diff-tree -r --name-status 1c5fbb04 be88909f` = exactly `A` ×4: `src/scout/reconciliation/{coverage,reconcile,types}.ts`, `test/scout/reconciliation/reconcile.spec.ts`; 2614 insertions, 0 deletions, no mode/rename | ✓ 4 added paths only |
| Committed blobs | types `b7599427…`, coverage `f50d9401…`, reconcile `bcc85e49…`, spec `11f2a524…` = the `STAGED_BLOB` lines in `gate.log` and `HEAD-be88909f4bf6.txt` | ✓ staged tree = committed tree (`STAGED_TREE` = `54349476…`) |
| Worktree state | `HEAD` = `be88909f`, branch `exec1910/s9a`, `git status --short --ignored` = only `!! node_modules/`; `core.hooksPath` unset | ✓ clean, candidate not amended after the gate |
| Patch receipt | `git diff --binary 1c5fbb04 be88909f | sha256sum` = `e07068db…` = recorded `s9a-1c5fbb044117-to-be88909f4bf6.patch` | ✓ |

## 2. Committed bytes = frozen preformat bytes modulo layout-only formatting

Frozen inputs re-hashed: `s9a/freeze/preformat-*` = `eff1479c…` / `c6b224fa…` / `83d7673b…` / `99068057…`, byte-identical to
`daceddc8/s9/gate/preformat-*` and to the SOURCE_READY post-B-1 table. Committed bytes re-hashed from the git objects:
types `211b474a…7114`, coverage `eca66f33…a8e7`, reconcile `d16158ad…30ab`, spec `dc084dce…08ee` = `gate/postformat-*` and the
`POSTFORMAT` log lines.

Independent token-stream comparison (my own tokenizer: strings, template literals, comments, identifiers, numbers, punctuation;
whitespace dropped; comment text whitespace-normalised; trailing commas before `) ] }` normalised on both sides), frozen → committed:

| File | Tokens frozen → committed | Non-whitespace, non-trailing-comma differences | Layout-only? |
| --- | --- | --- | --- |
| `types.ts` | 1024 → 1023 | one leading `\|` removed from the `ProvenanceNative`-style union at L101-105 (union collapsed to one line) | ✓ |
| `coverage.ts` | 388 → 389 | none (one trailing comma added; `familyCoverage` signature joined, two return objects expanded) | ✓ |
| `reconcile.ts` | 2562 → 2563 | one pair of parentheses added around the arrow body in `.sort((a, b) => (…))` at L377; the ternary at L145 joined onto one line | ✓ |
| `reconcile.spec.ts` | 9815 → 9920 | none (105 trailing commas added by rewrapping the long `it.each`/`cases` rows; every string literal, label and expected value identical) | ✓ |

Conclusion: every difference between frozen and committed bytes is whitespace, trailing commas, one redundant parenthesis pair and one
leading union bar — exactly the classes reviewer A predicted in Phase 1. Reviewer A's predicted post-format shas match exactly for
`types.ts` and `coverage.ts`, which also confirms the gate used the same prettier build/config; `reconcile.ts` and the spec differ from
A's prediction only because A predicted on the pre-B-1 bytes (`efb8f799…`/`5b015fae…`), consistent with SOURCE_READY (+8 lines in
`closeRelationships`, +29 lines for one spec row: 420→428 and 1207→1236 preformat lines). The pre-B-1 bytes are not present in this
sandbox, so the B-1 delta was verified by reading the committed hunk and row directly (§3) rather than by a three-way diff.
No exported name, type or value in `types.ts` changed (token-identical), so S9-B's read-only dependency is unaffected.

## 3. B-1 duplicate-family union closure and its regression row (at the committed bytes)

- `reconcile.ts` L289-298 (`closeRelationships`): `verifiedByFamily` is built as a **union per family name** —
  `prev === undefined ? o.verified : new Set([...prev, ...o.verified])` — with the explanatory comment. This is the exact 3-line closure
  reviewer A specified as B-1 option (a). Edge lookup at L303 (`from`) and `edgeVerified` at L268 (`to`) both read the union, so a
  failing edge from an identity in an earlier same-named entry can no longer be skipped.
- Spec row `reconcile.spec.ts` L1143-1172: two `mapped:true` `workouts` entries under different tokens (`workouts`, `workout_templates`),
  one `programs` family, one `program_parent` edge from the **first** `workouts` identity with `consistent:false`, `covered(...)`
  (coverage `known:true` for every family, claim `success`, `spec_families` = mapped families). Asserts verdict
  `{outcome:'partial', reason_code:'relationship_unverified'}`, `conditions` **exactly** `['relationship_unverified']`, and
  `relationship_unverified === 1` on both `workouts` rows. Because C-FAM, C-ID and C-COV are asserted false, this input would have
  settled `complete` under the old last-writer-wins map: the row discriminates the defect. It runs through the same `it.each` runner as
  every other verdict row (`toEqual` on the verdict, `expectWellFormed`, `check`). Verdict table now 45 rows (counted).
- Side-effect check of the union: `checked`/`failing`/`out` remain keyed by family name, so both same-named rows carry the same
  closure and the same `relationship_unverified` count (asserted by the row). Histogram-level duplication in a doc-forbidden input
  shape only; the verdict is unaffected. Class C, recorded below (C-3).

## 4. Purity / determinism and `complete` unreachable in v1 — not regressed

- Token-stream identity (§2) is sufficient: formatting cannot change control flow, imports or literals. Independently re-grepped the
  three committed `src` files: imports are `import type` from `../lifecycle/{arbiter,reason-codes}` and `./coverage`/`./types` only;
  no `Date`, `Math.random`, `console`, `localeCompare`, `throw`, `process`, `require`, `Prisma`, `as any`, `as unknown`, `@ts-`.
- Re-read the committed verdict path: `familyCoverage(undefined, …)` → `UNKNOWN`; `coverageOf` passes `undefined` when
  `facts.coverage === null`; `coverageConditionHolds` returns `true` when `required` is `null`/empty or any required family is not
  `known`. With `coverage: null` every family is unknown, so C-COV holds on every run → `partial/coverage_basis_unknown` at worst
  position; the single verdict literal site (L407-410) can emit `complete` only when `held.length === 0`. `complete` is unreachable in
  v1 at the committed bytes.

## 5. Gate / hook receipts — genuine and complete

| Receipt | Observed | Result |
| --- | --- | --- |
| One-shot relay | `LAUNCH.txt` pid 18788 21:30:25Z; `RELAY.txt` records the pre-launch hook-check correction and the final script sha `ef78b007…`; `STARTED` 21:30:25Z (single); `TERMINAL` `RC=0 STAGE=done END=21:35:53Z` | ✓ one attempt, terminal recorded |
| Driver integrity | `s9a-gate-1910.sh` re-hashed `ef78b007…` = RELAY/COMMIT_READY; `diff daceddc8/s9/gate/s9a-gate.sh s9a-gate-1910.sh` recomputed = recorded `s9a-gate-1910.diff-from-daceddc8.txt` byte-for-byte | ✓ the recorded diff describes the script that ran |
| Lock | `ACQUIRED … fd9 inode=667698 lslocks=1`; `LOCK_ESTABLISHED.txt` inode 667698; lock file present now with inode 667698; `RELEASING … lock file preserved` | ✓ |
| Donor / client pins | donor `worktrees/1910a060-s8f/node_modules` (HEAD `e1ec2fec`), hidden lock `05bc530a…`, client `index.d.ts` `9042e713…`, client schema `b8439203…`, 649 entries; `cp -a` rc 0 149 s; no in-lane `prisma generate` needed | ✓ base-H pins met |
| Hooks | `lefthook install` rc 0 (`sync hooks: ✔️(pre-commit, commit-msg)`), lefthook 2.1.9 (`node_modules/lefthook/package.json` 2.1.9; binary present). Installed hook bodies read in full: standard lefthook 2.1.9 stub calling `lefthook run pre-commit`/`commit-msg`, referencing this clone's `node_modules/lefthook-linux-x64/bin/lefthook`; no `LEFTHOOK=0`, no `--no-verify` anywhere in the driver. Raw shas `57303fa4…`/`a2ae3de7…` match `HOOK_RAW`; I re-derived the root-normalised comparison against the S8-F clone's hooks (`e21bece6…`/`277018c4…`) myself: identical after substituting each clone root | ✓ genuine hooks |
| Prettier | prefix manifest 56/56 OK, `readlink` = `../lib/node_modules/prettier/bin/prettier.cjs`, `npx` 3.9.9; check-1 rc 1 naming exactly the four files; `--write` touched exactly those four (`prettier-write-1.log`); check-2 rc 0; `SCOPE_FAIL` guard passed (no tracked file changed) | ✓ |
| eslint | rc 0, `--no-warn-ignored --max-warnings 0` on the four files; `eslint.raw.log` empty (sha `e3b0c442…` = empty) — consistent with rc 0 | ✓ |
| tsc | whole-repo `tsc --noEmit` rc 0, 0 lines | ✓ |
| jest | `jest --ci` on the 10 listed suites: `Test Suites: 10 passed, 10 total`; `Tests: 1 skipped, 418 passed, 419 total`; `PASS test/scout/reconciliation/reconcile.spec.ts` present; 75.34 s | ✓ |
| The 1 skip identified | Grepped all ten suites at `be88909f` for `it/test/describe.skip|.todo|xit|xdescribe|skipIf`: the only hit is `test/deploy-readiness.spec.ts` L1189 `const gateDescribe = resolveStrict(process.env) ? it : it.skip;` — the STRICT prod-deploy gate, skipped whenever `DEPLOY_READINESS_STRICT` is unset (PR/local runs). File unchanged vs parent (`git diff 1c5fbb04 be88909f -- test/deploy-readiness.spec.ts` empty). No skip in `reconcile.spec.ts` | ✓ pre-existing, intentional, outside S9-A |
| Pre-commit hook run | `commit-attempt-1.raw.log`: lefthook v2.1.9 pre-commit — `prod-readiness-quick` ✔, `banned-cast-tokens` ✔ (`R75 --cached … OK — no positive token change`), `prettier` ✔ (`All matched files use Prettier code style!`), `eslint` ✔, `tsc` ✔ (45.27 s); commit-msg — `no-ai-tokens` ✔; then `[exec1910/s9a be88909f] … 4 files changed, 2614 insertions(+)`. Matches `lefthook.yml` at `1c5fbb04` (5 pre-commit commands + 1 commit-msg). Author timestamp 21:35:07Z vs `GIT_COMMIT rc=0` 21:35:52Z = the 45 s hook run | ✓ genuine hooked commit |
| Post-commit asserts | driver checked parent = H, clean tree, delta = exactly the 4 paths, author+committer identity, no `co-authored-by|generated` in the message; all re-verified independently in §1 | ✓ |

Spec test count sanity: static tally of the committed `reconcile.spec.ts` = 16 (parse) + 24 (classify) + 7 + 5 (coverage tables)
+ 45 (verdict rows) + 12 (edge) + 15 plain `it` = 124 tests (builder's tally 126; difference is my count of standalone `it`s, immaterial).
The raw jest log is not `--verbose`, so the per-suite split of 418 is not receipted; `PASS` on the suite line means every test in it passed.

## 6. Safety-ROI findings

**Class A: none. Class B: none.** No defect in the candidate's behaviour was found, and the evidence set is sufficient to tell that
the committed candidate is the reviewed candidate: frozen bytes → prettier-only layout change → committed blobs → single hooked
Bradley commit, each link re-derived here from primary objects rather than from the builder's prose.

**Class C (record; none blocks; no closure cycle):**

- **C-1. `gate/SHA256SUMS` is stale for three entries.** The driver writes `sha256sum * > SHA256SUMS` before its `DONE`/`RELEASING`
  lines and before `TERMINAL`, so `gate/SHA256SUMS` lists `gate.log` `e34fce36…` and `launcher.out` `aa80b997…` (current: `45520988…`
  and `05f75ceb…`) and omits `TERMINAL`. The later top-level `s9a/SHA256SUMS` matches every current file. Hygiene only; the
  authoritative receipts (`HEAD-*.txt`, blobs, patch, raw logs) all match. If the driver is reused, move the manifest write after
  `finish`'s last log line.
- **C-2. Hook check was corrected at relay time** from fixed hook shas (`3b741de3…`/`71029ce8…`, GATE_PLAN) to a root-normalised
  comparison against the S8-F clone's hooks, because lefthook 2.1.9 embeds the clone's absolute path. Recorded in `RELAY.txt`, the
  script sha and the recomputed diff agree, and I re-derived the normalised equality independently; the hook bodies are the genuine
  lefthook stub. Not a weakening; recorded because GATE_PLAN's text predates it.
- **C-3. Union closure reports the same failing identity on every same-named row** (`checked`/`failing`/`out` keyed by family name).
  Histogram-only, only for inputs D-S9-2 "Grouping" forbids, verdict identical; the spec row pins the current behaviour. Carry with
  Phase-1 C-2/C-4 (keying by `(mapped, family)` or entry index) to the S9-B grant invariant "one entry per `(mapped, family)`".
- **C-4. Jest receipt is not per-suite.** `--verbose` (or `--json`) would bind the 124-test count and the one skip to their suites in
  the raw log instead of by static inspection. Optional for future drivers; not needed for this decision.
- **C-5. Phase-1 class C items (A: C-1…C-9; B: C-1…C-12) and B-2 are unchanged** at the committed bytes and remain carried to the
  S9-B/S9-C grants and the next doc edit, as both Phase-1 reviews and SOURCE_READY already record. No re-listing.

## 7. What this review does not claim

- I did not run prettier, eslint, tsc, jest or the hooks; the receipts were read, cross-checked against git objects and, where possible,
  re-derived (hashes, diffs, patch, hook normalisation, skip identity). Tool outputs are attributed to the gate run, not to me.
- The pre-B-1 source bytes are not available here; the B-1 delta is verified as content at the committed head, not as a three-way diff.
- Nothing here is landing, acceptance publication or a release-readiness statement; S9-A remains unwired until S9-C, and `complete`
  remains unreachable until S10 supplies a coverage basis.

## Verdict

**FINAL GO for acceptance of exact `be88909f4bf6a727a3bd376385aba91f209f989a` (tree `54349476…`, parent `1c5fbb04…`).**
Four added paths only; committed bytes are the frozen, dual-reviewed bytes modulo prettier layout (token-stream identical after
trailing-comma normalisation, plus one parenthesis pair and one leading union bar); the B-1 union closure and its discriminating
regression row are present and correct; purity, determinism and v1 `complete`-unreachability hold at the committed bytes; the gate and
hook receipts are genuine, single-attempt, complete and consistent with each other and with the git objects (jest 10/10 suites,
418 passed, 1 pre-existing strict-mode skip in `deploy-readiness.spec.ts`); author and committer are Bradley Gleave with no trailers.
No class A or B finding; class C items recorded above for the parent to carry, none requiring another cycle.

PHASE2 DONE (reviewer B).
