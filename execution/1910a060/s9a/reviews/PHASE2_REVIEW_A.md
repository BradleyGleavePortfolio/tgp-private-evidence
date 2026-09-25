# S9-A Phase-2 independent review A (T4, non-builder) — exact candidate be88909f

- Reviewer: `S9-A final review A` (EXEC-1910A060). Read-only: the standalone clone was inspected with
  `git show/diff/ls-tree/cat-file/rev-parse/log` and `git hash-object` (no `-w`) only; no npm, jest, tsc,
  prettier, hooks, commit or lock touched. Reviewer-side checks ran on copies in `/tmp/p2a` (TypeScript 5.9.3
  scanner from `worktrees/1910a060-s8f/node_modules` used as a tokenizer, read-only). This file is the only write.
- Written 2026-09-25 ~21:50Z. Reviewer B's Phase-2 output was not read. Accepted S9-0 architecture not re-audited.
- Read fully: `1910a060/SCOPE.md`, `tgp-agent-context/AGENT_RULES.md`, `6c2a68ac/OWNER_SAFETY_ROI_AND_EXECUTION_DOCTRINE.md`,
  `daceddc8/s9/reviews/S9_A_REVIEW_A.md` + `S9_A_REVIEW_B.md` (checklists), `daceddc8/s9/S9_A_SOURCE_READY.md`,
  `1910a060/s9a/{SOURCE_RECOVERED,GATE_PLAN,COMMIT_READY}.md`, `s9a/SHA256SUMS`, `s9a/freeze/**`, `s9a/gate/**`
  (incl. `gate.log`, `jest.raw.log`, `commit-attempt-1.raw.log`, `s9a-gate-1910.sh`, its diff from the daceddc8 driver).

## 1. Exact candidate (verified in `/home/user/workspace/worktrees/1910a060-s9a`)

| Item | Observed | Expected | ✓ |
| --- | --- | --- | --- |
| HEAD / branch | `be88909f4bf6a727a3bd376385aba91f209f989a`, `exec1910/s9a`, `git status --short` empty | same | ✓ |
| tree | `54349476c9f92296f4595bda45d64a48534c4553` (= `STAGED_TREE` written at 21:35:06Z before the commit) | same | ✓ |
| parent | `1c5fbb0441178e0cfe6e9f8d72e955c645c265e9` (single parent; parent tree `82b56ad3`) | H | ✓ |
| delta H→HEAD | `git diff --name-status`: exactly 4 `A` rows; `git diff --name-status -- . ':!src/scout/reconciliation' ':!test/scout/reconciliation'` = 0 lines; 2614 insertions, 0 deletions | 4 added paths, nothing tracked touched | ✓ |
| blobs | types `b7599427…`, coverage `f50d9401…`, reconcile `bcc85e49…`, spec `11f2a524…` (`ls-tree` = `STAGED_BLOB` lines = `HEAD-be88909f4bf6.txt`) | same | ✓ |
| author / committer | both `Bradley Gleave <bradley@bradleytgpcoaching.com>`, 2026-09-25T21:35:07Z (`cat-file -p`) | G05 identity | ✓ |
| trailers | `%(trailers)` empty; message has 0 hits for `claude|anthropic|openai|gpt|co-authored|generated|perplexity|\b(ai|agent)\b`; unsigned (`%G?`=N, not required) | none | ✓ |
| message | `gate/commit-message.txt` sha `1669d02c…` = daceddc8's message byte-for-byte; `committed-message.txt` = same + one trailing newline (`%B`) | byte-identical | ✓ |
| working tree = commit | clone's `src/…/reconcile.ts` sha `d16158ad…`, spec `dc084dce…` = committed blobs | — | ✓ |

## 2. Committed bytes vs frozen pre-format bytes (layout-only)

Committed blobs are byte-identical to `gate/postformat-*` (cmp) and their sha256s equal the `POSTFORMAT` lines in
`gate.log` and the `HEAD-*.txt` receipt. Frozen `freeze/preformat-*` sha256s equal the SOURCE_READY / SOURCE_RECOVERED /
Phase-1 table (types `eff1479c…`, coverage `c6b224fa…`, reconcile `83d7673b…`, spec `99068057…`) and are byte-identical
to `daceddc8/s9/gate/preformat-*` (same git blob ids `bb28f151/e13c336a/3932cd3c/df887df5`).

Token-stream comparison (TypeScript scanner, trivia skipped, template/regex re-scans handled), frozen → committed:

| File | Raw token delta (post − pre) | After removing trailing commas / arrow-param parens / leading `\|` | Whitespace-insensitive `diff -w` |
| --- | --- | --- | --- |
| `types.ts` (386→382 lines) | `BarToken −1` | identical except the one leading `\|` | one hunk: `NativeTargetCheck` union collapsed onto one line (L101-105 → L101) |
| `coverage.ts` (77→82) | `CommaToken +1` | **identical** (369 = 369) | signature un-wrapped; two object literals re-wrapped; one trailing comma |
| `reconcile.ts` (428→424) | `CommaToken −1, OpenParen +1, CloseParen +1` | identical except prettier's parens around a ternary arrow body | two hunks: L145 ternary joined; L379 `.sort((a, b) => (…))` |
| `reconcile.spec.ts` (1236→1726) | `CommaToken +105` | **identical** (9480 = 9480) | 736 changed lines, all rewraps of `it.each`/case rows + trailing commas |

Comments compared as trivia: equal modulo whitespace in all four files (86/14/19/8). String-literal text is part of the
token key, so no string changed. Conclusion: the only difference between frozen and committed bytes is prettier 3.9.9
layout under the repo `.prettierrc.json` (`singleQuote`, `trailingComma: all`, `printWidth 100`); semantics unchanged.
This is consistent with the gate: `--check` rc 1 on exactly the 4 files → `--write` on exactly those 4
(`prettier-write-1.log`) → `--check` rc 0; untracked-set check after formatting still equal to the 4 paths (driver L152).

### Phase-1 predicted post-format sha256s

| File | Review A prediction | Committed | Match |
| --- | --- | --- | --- |
| `types.ts` | `211b474a…7114` | `211b474ac29e6fb04c5dadbf5bca9bf3cb86e8da7fb0256bd111d57f68c77114` | ✓ exact |
| `coverage.ts` | `eca66f33…a8e7` | `eca66f334b73ce3eb3c5902a8392829104e38b3cdef49e9a5c00f35e46eaa8e7` | ✓ exact |
| `reconcile.ts` | `63abdee7…021a` | `d16158ad4f2c1c6315fd04ac4ca35c8d3c2f94bf8df1fe3905147ab2583d30ab` | ✗ explained below |
| `reconcile.spec.ts` | `60e79044…5bae` | `dc084dcefe607a09575bdb23bcca57c5ee665509d89e17c007d471a57a2408ee` | ✗ explained below |

The two mismatches are exactly the two files the B-1 closure (17:58Z) changed after the prediction was made on
`efb8f799…`/`5b015fae…`. I verified this **byte-exactly** without needing the old files: reverting the frozen
`reconcile.ts` L291-300 (the two comment lines plus the 7-line union loop) to the single line
`for (const o of outcomes) verifiedByFamily.set(o.facts.family, o.verified);` reproduces sha256
`efb8f799f1c5f26b31c7ff9fedfe058c77297ee4d2c2db2a78cca14267c83263` (= Review A's reviewed `reconcile.ts`, 420 lines).
Removing the frozen spec's L794-822 (the single 29-line "review B-1" verdict row) reproduces
`5b015fae6cd8c50861f87d37b288f8a8f01b60c308f47f564679cb26fa01fe85` (= reviewed spec, 1207 lines). So the Phase-1
reviewed bytes + exactly the SOURCE_READY-described B-1 delta = frozen bytes; the two files that match the prediction are
the two the delta did not touch, and the same prettier build/config produced them. A prettier re-run on the reconstructed
pre-B-1 files would only re-derive the prediction and buys no decision; not done.

## 3. B-1 closure (the only changed hunk since Phase 1) — correct, no new A/B

`reconcile.ts` `closeRelationships` (committed L287-323):

```ts
const verifiedByFamily = new Map<string, ReadonlySet<string>>();
for (const o of outcomes) {
  const prev = verifiedByFamily.get(o.facts.family);
  verifiedByFamily.set(o.facts.family, prev === undefined ? o.verified : new Set([...prev, ...o.verified]));
}
```

- `o.verified` is populated only for bucket-j identities (`reconcileFamily` L225-226), so the union is exactly "all
  bucket-j identities under this family name". `edgeVerified` (L262-270) and the from-side check (L303) use only `.has`,
  so Set iteration order never reaches the output; no input is mutated (a new `Set` is built; `o.verified` untouched).
  `Set<string>` is assignable to `ReadonlySet<string>`; tsc rc 0.
- Effect on the from-side: strictly more edges are checked, so `failing` can only grow — the B-1 false `complete`
  (edge from an overwritten first entry silently skipped) is closed. Effect on the to-side: a target that is bucket j in
  an overwritten same-named entry is now found, so an edge that previously failed *spuriously* now passes when
  `consistent === true`; that is the doc-correct answer (the target genuinely is bucket j in `to_family`), not a new
  false-`complete` path. An unmapped entry's `verified` is empty (all bucket a), so the union also removes the spurious
  `unverified` half of Phase-1 C-2 without adding anything.
- The rest of the function is unchanged from the Phase-1-reviewed bytes (§2 reconstruction), including the `checked`/
  `failing`/`out` maps keyed by family name (see C-P2-2).

Regression row (spec L794-822 frozen; committed inside the 45-row `cases` table run by `it.each` at L1496-1503 with
`expect(result.verdict).toEqual(...)`, `expect(report.conditions).toEqual(c.conditions)`, `expectWellFormed`, `check`):
two `mapped:true` `workouts` entries (tokens `workouts` / `workout_templates`, one bucket-j identity each), one
`programs` entry, one `program_parent` edge from `workouts-first` → `programs-0` with `consistent:false`, coverage
`known` for `programs` and `workouts` via `coverFor`, claim `success`, spec = mapped families. Traced by hand:
pre-fix, sorted entries keep input order, last writer = second entry, edge from `workouts-first` skipped →
`not_applicable`, all other conditions false → **`complete`** (Review A's original reproduction); post-fix, union finds
`workouts-first`, target is j, `consistent:false` → fails → `unverified=1` → C-REL only → `partial /
relationship_unverified`, `conditions === ['relationship_unverified']`. The row therefore fails on the pre-fix code and
passes on the fix: a genuine discriminating regression test for exactly the B-1 defect, not vacuous. An AST count (TypeScript
parser, `it`/`it.each` table lengths) of the committed `reconcile.spec.ts` gives 124 tests, equal to Review B's expected
tally (17 parse, 27 classify, 13 coverage, 45 verdict rows + 2 invariants, 12 edge, 4 determinism, 4 arbiter); the
`cases` table has 45 entries including this row, and the suite is listed `PASS` in `jest.raw.log`.

**B-1: CLOSED at be88909f.** B-2 remains an S9-B grant sentence (no S9-A change), as both Phase-1 reviews disposed.

## 4. Gate receipts — genuine and bound to this head

- Driver `gate/s9a-gate-1910.sh` sha256 `ef78b007…` matches `RELAY.txt`, `COMMIT_READY.md` and both SHA256SUMS; read in
  full. It refuses without `S9A_GATE_RELAY=1` (pre-lock), is one-shot (`STARTED` sentinel), opens the existing canonical
  lock with `flock -n` on fd 9 after verifying inode `667698` against `runtime/LOCK_ESTABLISHED.txt` (I re-stat'ed the
  lock file: inode 667698; `lslocks` shows 0 holders now), and writes `TERMINAL` on every exit. `TERMINAL` =
  `RC=0 STAGE=done END=2026-09-25T21:35:53Z`; `STARTED` 21:30:25Z = `LAUNCH.txt`.
- Preconditions logged/enforced (L71-86): HEAD==H, branch, exactly the 4 untracked paths, each equal to the `freeze/`
  copy (`cmp`) and its pinned sha, no node_modules, `prisma/schema.prisma` `0eb41f9a…` and `package-lock.json`
  `b7fed5ed…` (I re-hashed both at `1c5fbb04`: match), S9-0 doc `cda68d82…`, no pre-existing hooks, `core.hooksPath`
  unset (still unset now).
- node_modules: `cp -a` from the read-only donor `worktrees/1910a060-s8f/node_modules`; hidden lock `05bc530a…`, client
  `index.d.ts` `9042e713…` and client `schema.prisma` `b8439203…` equal the base-H pins recorded by the daceddc8 runtime
  and 18:27Z gate; no in-lane `prisma generate` needed. I diffed the clone's `.prisma/client/schema.prisma` against
  `prisma/schema.prisma` at H: identical modulo whitespace and one `@@unique` attribute position (prisma-format
  reordering) — the client belongs to H's schema. S9-A itself imports no Prisma.
- Hooks: `lefthook install` 2.1.9 into this clone (`lefthook-install.log`: `sync hooks: ✔️(pre-commit, commit-msg)`);
  raw shas `57303fa4…`/`a2ae3de7…` — I re-hashed `.git/hooks/{pre-commit,commit-msg}` now: identical; path-normalised
  bodies equal the S8-F reference clone's (`9dcf80f4…`/`4ab9b419…`); hooks reference this clone's
  `node_modules/lefthook-linux-x64/bin/lefthook`. `lefthook.yml` at be88909f defines pre-commit
  `banned-cast-tokens` (R75 `--mode=staged`), `tsc`, `eslint --max-warnings 0`, `prettier --check`,
  `prod-readiness-quick` and commit-msg `no-ai-tokens`. `commit-attempt-1.raw.log` shows the lefthook v2.1.9
  pre-commit banner, R75 `OK — no positive token change`, prettier `All matched files use Prettier code style!`,
  all five ✔ (tsc 45.27 s), then the commit-msg hook `no-ai-tokens` ✔, then git's `[exec1910/s9a be88909f] … 4 files
  changed, 2614 insertions(+)`. `git commit -F` with no `--no-verify` (driver L171). Hooks ran.
- Prettier: isolated prefix `/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9`, 56/56 manifest
  lines OK, `bin/prettier → ../lib/node_modules/prettier/bin/prettier.cjs`, `npx --no-install prettier --version` =
  3.9.9; no `node_modules/.bin/prettier` in the product tree (L110). check-1 rc 1 (4 warns) → write (4 files) →
  check-2 rc 0. ✓
- eslint: `--no-warn-ignored --max-warnings 0` on the 4 files, rc 0, empty raw log (sha `e3b0c442…` = empty). ✓
- tsc: `--noEmit` whole repo (tsconfig has no `include`, so `test/` is checked), rc 0, 0 output lines. ✓
- jest: `./node_modules/.bin/jest --ci` on the 10 named suites; raw log lists `PASS` for all 10 including
  `test/scout/reconciliation/reconcile.spec.ts`; `Test Suites: 10 passed, 10 total`, `Tests: 1 skipped, 418 passed,
  419 total`, 75.34 s, `Ran all test suites matching <the 10 paths>`. ✓
- **The 1 skip, identified:** `test/deploy-readiness.spec.ts` L1189-1201:
  `const gateDescribe = resolveStrict(process.env) ? it : it.skip;` guarding `'STRICT prod-deploy gate against this
  repository is ALL CLEAR (hard block)'`; `resolveStrict` (L113-115) is true only when `DEPLOY_READINESS_STRICT` is
  `1`/`true`, which the gate environment does not set (by design: "Skipped entirely outside strict mode so it never
  false-fails a PR"). The file is not in the candidate delta and the identical line exists at `1c5fbb04`, so the skip
  is **pre-existing, intentional, and unrelated to S9-A**; consistent with the raw log printing the two informational
  boards (L1134, L1146) and not the strict board. No other `.skip`/`xit`/`xdescribe`/`.todo` in the 10 suites at
  be88909f. Effect on acceptance: none.
- Post-commit assertions in the driver (L175-179): parent == H, clean tree, delta == the 4 paths, author|committer
  identity, no `co-authored-by|generated` in the message — all passed (rc 0 path reached `DONE`).
- Historical `daceddc8/s9/gate/gate.log` last changed in evidence commit `e8dbb2b` (18:31Z, predecessor); untouched by
  the 1910a060 lane. Evidence for `1910a060/s9a/**` is committed (`8a7519e`), working tree clean.

## 5. Findings (Safety-ROI classes)

**Class A: none. Class B: none.** No new A/B in the changed hunk; B-1 closed; B-2 carried (S9-B grant).

Class C (record, qualify, continue — none blocks, none needs a builder cycle):

- **C-P2-1 stale entries in `gate/SHA256SUMS`.** The driver writes `gate/SHA256SUMS` at L185 and then appends the
  `DONE`/`RELEASING` lines to `gate.log` (and the launcher's tee to `launcher.out`), so that manifest records
  `gate.log` `e34fce36…`/`launcher.out` `aa80b997…` while the files are `45520988…`/`05f75ceb…`. The builder's later
  top-level `s9a/SHA256SUMS` is correct for all 34 entries (`sha256sum -c`: all OK). Provenance hygiene only; a future
  driver should write the manifest last.
- **C-P2-2 shared attribution for same-named entries (report only).** `closeRelationships` keys `checked`/`failing`/
  `out` by family name, so the B-1 row's one failing identity is reported as `relationship_unverified: 1` on *both*
  `workouts` rows (the row's `check` pins this). C-REL is boolean (`some(f => f.relationship_unverified > 0)`), so the
  verdict is unaffected; the input is outside D-S9-2's grouping (S9-B invariant). Same root as Phase-1 Review B C-4
  (key by entry index) — carry to the next S9 touch of this file; no S9-A change.
- **C-P2-3 prediction provenance.** Review A's post-format hashes for `reconcile.ts`/spec were not recomputed after the
  17:58Z B-1 delta; the mismatch is fully explained by the byte-exact reconstruction in §2. Future Phase-1 notes should
  re-pin predictions after any delta.
- **C-P2-4 hook binary selection not logged.** The lefthook pre-commit wrapper prefers a `lefthook` on `PATH` before the
  clone's `node_modules/lefthook-linux-x64/bin/lefthook`. The gate verified version 2.1.9 and normalised hook-body
  equality and the run banner shows v2.1.9; which binary actually executed was not recorded. No effect on the result.
- Not independently re-derived: the other nine suites' 295-test contribution (loop-generated tests defeat a static count);
  the per-suite `PASS` lines and totals are taken from the raw log. No new gate run is warranted (S9-A is pure; tsc/eslint/
  jest ran on this exact tree).

## 6. What this review does not claim

No gate, hook, test or formatter was run by me; §4 attests to receipts produced on this exact tree by the one relayed
run. R11/R13/R15/R16, S9-B facts correctness and the B-2 grant sentence remain outside S9-A. Landing (FF/PR),
acceptance publication and push are parent-owned; equal source trees do not by themselves make a later merge commit
inherit this attestation (G09/G17).

---

## VERDICT: **FINAL GO** for acceptance of exact commit `be88909f4bf6a727a3bd376385aba91f209f989a` (tree `54349476…`, parent `1c5fbb04…`).

Exactly four added paths; committed bytes are the frozen, dual-reviewed bytes modulo prettier 3.9.9 layout (token-stream
identity shown for all four files, with the two prediction mismatches byte-exactly traced to the B-1 delta); the B-1
union closure is correct, monotone toward safety, and pinned by a discriminating regression row; prettier/eslint/tsc/jest
(10 suites, 418 passed, 1 pre-existing intentional skip in `deploy-readiness.spec.ts`) and genuine lefthook
pre-commit/commit-msg hooks ran on this tree; author and committer are Bradley Gleave with no trailers. No class A or B
findings; four class C items recorded above.

PHASE2 DONE.
