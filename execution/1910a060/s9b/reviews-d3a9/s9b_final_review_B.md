# S9-B final-head + binding review — Reviewer B

Scope: read-only. I ran only git read commands, sha256sum, stat, readlink, diff/cmp, rg/find, a python token comparer in /tmp, and `node --version`. I did not run tsc, jest, npm, npx, prettier or postgres, and I did not touch test-validation.lock (I only ran `stat` on it).

## Verdict: **GO** (Q1 GO, Q2 GO). No A or B findings. There are three C findings (notes only).

## Q1: final head 1e6e5735

| Check | Result |
|---|---|
| `git log -1 1e6e5735`: tree / parent | db6dde16c212ee1d2cf42da6bc71bacb68452b8e / 9497ca5275938c9228c6ec6fa0dfa8c34f39f724. Worktree HEAD = 1e6e5735 |
| Author / committer | both `Bradley Gleave <bradley@bradleytgpcoaching.com>` |
| Trailers | `git interpret-trailers --parse` finds none. The message has no Co-authored-by or Signed-off-by lines |
| `git diff --name-status 9497ca52 1e6e5735` | exactly 11 paths: M docs/decisions/2026-09-25-s9-reconciliation.md, plus A for facts.service.ts, reconciliation.module.ts, rls-g2-s9.spec.ts, g2-s9-db-guard.spec.ts, facts.service.spec.ts, g2-s9-bootstrap.sh, g2-s9-db.ts, g2-s9-harness.ts, g2-s9-pg-harness.ts, g2-s9-worker.cjs |
| Committed blob sha256 vs gate-2 POSTFORMAT | all 11 match (a760fb6a, 48040a5a, f20099a1, a99cf9c9, aa41b3a7, 87995257, 39ba033b, 0378563b, 3a6bd56a, 028979e9, 7c516a63). They also match attempt-2/postformat/* and the final gate.log POSTFORMAT lines |
| Doc delta vs base | numstat 99/0. The diff starts at L531 context, so the lines above Addendum A are unchanged |
| Driver delta (attempt-2 vs final s9b-gate-1910.sh) | one line only (L203): the `node scripts/check-r75.js` worktree call (which failed rc=2: "range mode requires a nonempty base") is replaced by a log-only line. R75 is still enforced at L220 (`--mode=staged`) and by the pre-commit hook |
| R75_STAGED | `R75_STAGED rc=0` in gate.log. r75-staged.raw.log says "OK — no positive token change". TERMINAL: `RC=0 STAGE=done` |
| Other gate stages | PRETTIER_CHECK_1 rc=0 (the tree was already formatted by attempt 2), ESLINT 0, TSC 0, JEST_TARGETED 356/356, JEST_FULL rc=0, GIT_COMMIT 0 |
| PINS.env (final) vs attempt-2/PINS.env | only 5 values differ: SHA_FACTS_SERVICE, SHA_FACTS_SPEC, SHA_G2_WORKER, SHA_RLS_SPEC and SHA_DOC_ADDENDUM, each re-pinned from its pre-format to its post-format value |

### Pre→post-format, recovered files
The pre-format bytes in tgp/backend-s9b-recovery/recovery/candidate are identical to the recovery-d3a9 tarball. They match the attempt-2 pre-format pins (e2f40a79 / 9dcfbd96 / be591e97; db.ts and guard-spec are unchanged by formatting).
- **facts.service.ts** (+16/−7): the only changes are import wrapping, `if (` condition wrapping, `for` body wrapping, and a property-value wrap. A string-aware token comparison (trailing commas before closers ignored) leaves one difference: prettier removed the redundant grouping parens in `return ( value !== null && … )` in `isLedgerTargetKind`. The expression is the same, so this is not a semantic change.
- **facts.service.spec.ts** (+211/−35): all changes are call and object wrapping plus trailing commas. The token comparison leaves one difference: a `;` separator added after the last member of the inline type literal `Partial<{ …; reason: string | null; }>`. This is layout only.
- **doc** (+2/−2): the text is identical once whitespace is removed. Prettier removed the 2-space indent from two list-item continuation lines that begin inside a multi-line code span (`source_id)`…` and `∈ mapped families…`). Both are lazy paragraph continuations and a code span turns the line ending into a space, so the rendered output is unchanged. See C-1.

### Pre→post-format, rebuilt files (rls-g2-s9.spec.ts, g2-s9-worker.cjs)
I could not find the pre-format bytes anywhere (ff84db29… / d2fba3a8…). I searched the workspace files by name and content, the worktree's git object store, and the private-evidence git object store. `prettier --write` overwrote them in place, and the reviewed builder output was not archived, so I could not run a byte-level or `-w` comparison. What is on record: attempt-2's `chk` (driver L95/L98, which exits 70 on mismatch) passed with SHA_G2_WORKER=d2fba3a8 and SHA_RLS_SPEC=ff84db29, which are the dual-GO reviewed bytes, before PRETTIER_WRITE. The only writer between those checks and POSTFORMAT was the pinned prettier 3.9.9 (PREFIX_VERIFY 56/56, NPX_PRETTIER_VERSION=3.9.9). R75 staged reported no positive token change, and the committed rls spec still has exactly 10 `it(`, which matches EXPECT_TESTS. See C-2.

## Q2: binding v2 → v3
`diff v2/s9b-pg-proof.sh v3/s9b-pg-proof.sh` matches DELTA-v2-v3.diff exactly. It changes 19 lines, and every one is a value fill. No logic line changed.

| Line | v3 value | Verified against |
|---|---|---|
| D | …/binding/v3 | the path goes through the `tgp-private-evidence` symlink to /home/user/workspace/private-evidence. v2 used the same prefix |
| EXPECT_HEAD / EXPECT_TREE | 1e6e5735… / db6dde16… | `git rev-parse 1e6e5735`, `1e6e5735^{tree}` |
| SPEC / BOOTSTRAP / DB / PGH / HARNESS / WORKER blobs | cbde1f53 / ce61b586 / 02ee7bc8 / 88f3d050 / cdbf1543 / 9fcff4c9 | `git rev-parse 1e6e5735:<path>` all equal. They also match the gate STAGED_BLOB lines |
| POSTGRES / INITDB / PGCTL | 23cd1748 / b7db9bc2 / af53d826 | sha256 of runtime/pg17/dist/bin/{postgres,initdb,pg_ctl} |
| NODE | a03953a7… | sha256 of readlink -f $(command -v node) = /usr/local/bin/node (v20.20.1) |
| NM_LOCK / NM_CLIENT | 05bc530a / 9042e713 | sha256 of W node_modules/.package-lock.json and .prisma/client/index.d.ts |
| LOCK_INODE | 692282 (was 667698) | `stat -c %i` of the lock = 692282. private-evidence/execution/d3a9f701/runtime/LOCK_ESTABLISHED.txt says inode=692282 |
| Fixture | EXPECT_FIXTURE_SHA unchanged = 1ee36964…; v2 and v3 s9b-fixture.sh are byte-identical (cmp), sha 1ee36964… | |
| BINDING.sha256 | pg-proof e291cb12 and fixture 1ee36964 both match the actual files | |

Also unchanged and still correct: BASE_HEAD 9497ca52 and BASE_TREE 737c34a3 (= `9497ca52^{tree}`), and EXPECT_TESTS=10. The placeholder guard (L94, which refuses on `__`) is intact, and none of the filled values contain `__`.

## Findings
- **C-1 (doc cosmetic).** Prettier de-indented two continuation lines in Addendum A (the `source_id)`… and `∈ mapped families…` lines). The rendered markdown is the same, but the source is slightly less readable. Minimum fix: none required. Optionally re-indent in a later doc touch, but prettier will undo it unless the code span is kept on one line.
- **C-2 (evidence gap, not a defect).** The pre-format bytes of the two rebuilt reflowed files (rls-g2-s9.spec.ts ff84db29, g2-s9-worker.cjs d2fba3a8) were not archived, so a direct pre→post layout-only comparison cannot be made for them. The pin check before the write plus the pinned-prettier-only write chain is strong indirect evidence. Minimum fix: none for this head. For future gates, copy pre-format bytes to `attempt-N/preformat/` before `prettier --write`.
- **C-3 (stale comments in binding v3, not logic).** L55's comment still cites `execution/1910a060/runtime/LOCK_ESTABLISHED.txt`, which records the old inode 667698. The correct record is d3a9f701. L46's comment says "sha256 of binding/v2/s9b-fixture.sh", but the v3 fixture is byte-identical. Minimum fix: none required. Optionally correct the comments in a future binding revision (that would change the pg-proof sha and BINDING.sha256).
