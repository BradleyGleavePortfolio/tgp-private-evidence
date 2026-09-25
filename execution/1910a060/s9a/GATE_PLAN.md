# S9-A exact freeze and fresh gate plan (A-NEW-1, EXEC-1910A060)

Written 2026-09-25 ~21:20Z by A-NEW-1 (T4). Nothing below has run except source recovery
(`SOURCE_RECOVERED.md`). No lock opened, no install, no hooks, no format, no commit, no push, no PG.

## Authority and what this is not

- Bradley's 14:08 PT reset (1910a060/SCOPE.md): exact recoverable S9-A bytes must be reused; the B-1
  union must not be recreated; the 18:27Z daceddc8 gate is historical incomplete evidence, not a
  successful proof; a fresh freeze and one required gate run are authorized after parent relay.
- Landed contract (docs/decisions/2026-09-25-s9-reconciliation.md at 1c5fbb04, sha cda68d82…):
  S9-A is the pure reconciler with no I/O, no Prisma, no clock; no real-PG proof applies to it. The
  gate is prettier/eslint/tsc/jest (default config) plus one genuine hooked commit.
- Not in this lane: S9-B/S9-C surfaces, S8-G, contract regeneration, pushing, landing, acceptance.

## Exact candidate frozen (pre-format bytes)

| Path | sha256 | git blob (as untracked, pre-prettier) |
| --- | --- | --- |
| `src/scout/reconciliation/types.ts` | `eff1479cd2b735aacadc42ee3e2280dcfaf2e4fcc27a1fb90fd2c2bf2db1dbfa` | `bb28f151…` |
| `src/scout/reconciliation/coverage.ts` | `c6b224fa860261d6240c5bd62b07d419c6b9346c0b0de4eaac64dd9215926701` | `e13c336a…` |
| `src/scout/reconciliation/reconcile.ts` | `83d7673b024513bbee938bf4a5467c4faa9306739f15ae53b69722936d7d9e1f` | `3932cd3c…` |
| `test/scout/reconciliation/reconcile.spec.ts` | `99068057b0b99d95c9601c02130e4eca2b3b07acd0e0088fae146cb2f54edb74` | `df887df5…` |

Frozen copies: `s9a/freeze/preformat-*` (+ `SHA256SUMS`), byte-identical to `daceddc8/s9/gate/preformat-*`.
Working copy: `/home/user/workspace/worktrees/1910a060-s9a` (standalone clone), branch `exec1910/s9a`,
HEAD `1c5fbb0441178e0cfe6e9f8d72e955c645c265e9`; exactly these four untracked files; nothing tracked touched.

These are the bytes both Phase-1 reviews (`daceddc8/s9/reviews/S9_A_REVIEW_A.md`, `_B.md`) covered
after the B-1 closure delta: review A's B-1 is closed in `reconcile.ts` L298 (union per family) plus the
R06 spec row at L795; B-2 and all C items are carried to S9-B/S9-C grants, not S9-A. Review A's predicted
post-prettier sha256s (same prettier 3.9.9 + repo `.prettierrc.json`): types `211b474a…7114`,
coverage `eca66f33…a8e7`, reconcile `63abdee7…021a`, spec `60e79044…5bae`. Phase 2 should compare the
gate's `POSTFORMAT` lines against these; a mismatch is a review question, not a builder edit.

Commit message: `s9a/gate/commit-message.txt`, byte-identical to the daceddc8 one (sha `1669d02c…`),
passes the commit-msg token rule (checked locally with the same regex).

## Fresh environment inputs the parent must relay (RT-NEW-1 outputs)

| Input | Gate variable | Pin the gate enforces |
| --- | --- | --- |
| node_modules donor (npm ci of package-lock `b7fed5ed…` at base H) | `S9A_DONOR=<abs path>/node_modules` | hidden lock `.package-lock.json` = `05bc530a…`; `.bin/{tsc,jest,eslint,lefthook}` present; no `.bin/prettier` |
| Prisma client for base H's schema (`prisma/schema.prisma` = `0eb41f9a…`) | (derived) | `.prisma/client/index.d.ts` = `9042e713…`, `.prisma/client/schema.prisma` = `b8439203…`. If the relayed donor carries a different client (an S8-F schema donor), the gate runs one in-lane `npx --no-install prisma generate` in the S9-A copy only (RT-2 S7-L precedent) and refuses unless the result equals these pins. The donor is never written. |
| Isolated prettier 3.9.9 npm-prefix | `S9A_PRETTIER_PREFIX=<abs dir>` | 56-file manifest `64e33dc7/runtime/formatter/raw/prefix-files.sha256` all OK; `bin/prettier -> ../lib/node_modules/prettier/bin/prettier.cjs`; `npx --no-install prettier --version` = 3.9.9 |
| Canonical lock | fixed | `/home/user/workspace/execution/test-validation.lock`, inode must equal the one in `1910a060/runtime/LOCK_ESTABLISHED.txt` (667698); `flock -n` on fd 9 in the driver process; refuse a live holder; never delete/replace |
| Relay | `S9A_GATE_RELAY=1` | absent → exit 78 before the lock is touched (grant not consumed) |

The old 64e33dc7 recovery-reset paths do not exist in this sandbox; nothing from them is assumed except the
manifest file, which is in the private evidence repo.

## Gate driver

`s9a/gate/s9a-gate-1910.sh` (sha256 `35a0d112…`, `bash -n` clean, dry refusal rc 78 verified without
touching the lock). Derived from the historical `daceddc8/s9/gate/s9a-gate.sh`; full diff at
`s9a/gate/s9a-gate-1910.diff-from-daceddc8.txt`. Differences, all environment/namespace, no step removed:

1. Namespace: evidence `1910a060/s9a/gate/**`, worktree `worktrees/1910a060-s9a`, branch `exec1910/s9a`.
   The daceddc8 `gate.log` is never appended to.
2. Relay/one-shot: requires `S9A_GATE_RELAY=1`, `S9A_DONOR`, `S9A_PRETTIER_PREFIX`; writes `STARTED`
   only after `ACQUIRED`; refuses if `STARTED` exists; writes `TERMINAL` (`RC= STAGE= END=`) on every exit.
3. Lock: verifies the recorded inode before `flock -n`.
4. Preconditions add: `core.hooksPath` unset; the four files equal the `freeze/` copies; `prisma/schema.prisma`,
   `package-lock.json` and the S9-0 doc shas; no pre-existing `.git/hooks/{pre-commit,commit-msg}`.
5. Donor: pins hidden lock + client; optional in-lane `prisma generate` fallback as above; donor read-only.
6. Genuine hooks: `npx --no-install lefthook install` into this clone's `.git/hooks`; pre-commit / commit-msg
   bodies must equal the recorded lefthook 2.1.9 hooks (`3b741de3…`, `71029ce8…`), else refuse.
7. Prettier `--write` is refused if any file it wants to touch is outside the four paths; post-format
   copies saved as `gate/postformat-*`; a tracked-file change after formatting fails the gate.
8. Commit: additionally asserts author and committer are both `Bradley Gleave <bradley@bradleytgpcoaching.com>`.
9. Receipts add hook shas, prettier prefix, donor pins and lock inode to `HEAD-<sha>.txt`.

Step order (unchanged from the historical driver): preflight → cp -a node_modules → [prisma generate if
needed] → lefthook install → prettier prefix verify → scoped prettier check/format → scoped eslint →
`tsc --noEmit` (heap 4096, whole repo) → `jest --ci` on the 10 affected suites (all present at 1c5fbb04;
default config, no PG) → `git add` exactly the four paths → `git commit -F commit-message.txt` through the
real hooks (R75 staged, tsc, eslint, prettier --check, prod-readiness-quick, commit-msg) → receipts.

Launch, exactly once, by the parent's relay:

```
S9A_GATE_RELAY=1 S9A_DONOR=/abs/path/node_modules S9A_PRETTIER_PREFIX=/abs/prefix \
timeout -k 30 3600 bash /home/user/workspace/tgp-private-evidence/execution/1910a060/s9a/gate/s9a-gate-1910.sh
```

Exit codes: 78 relay/env missing (pre-lock), 76 sentinel exists or commit failed, 75 lock, 70 preconditions,
71 environment (donor/hooks/prefix/client), 72 prettier, 74 eslint, 73 tsc/jest, 0 done. Any non-zero
result is preserved (`gate.log`, raw logs, `TERMINAL`) and stops for parent disposition; no rerun by this lane.

## Failure disposition rule for the gate (source is frozen)

- tsc/eslint/jest failure inside the four files: STOP. Record it. A source change would produce a NEW
  candidate needing a fresh freeze and re-review; it is not made silently under the same grant (the old
  "fix and re-enter from step 4" clause is dropped because the candidate is frozen to reviewed bytes).
- Failure outside the four files (composed-tree tsc error, unrelated suite): STOP, record; not S9-A's to fix.
- Environment refusal (71/75): grant not consumed only if before `ACQUIRED`; otherwise preserved as a consumed
  attempt and the parent decides.

## After the gate (parent-owned)

Genuine Bradley commit on `exec1910/s9a` (child of 1c5fbb04, exactly four added paths) → Phase-2
independent changed-hunk/exact-candidate reviews (A and B checklists in their Phase-1 files: committed bytes =
frozen bytes modulo prettier, token-stream identity, hook/gate receipts, identity, post-format shas) → parent
acceptance and landing by FF/PR. This lane does not push.

## Notes for the parallel lanes

- S9-B reads `types.ts` (`eff1479c…`) as a read-only dependency; prettier will change layout only, no
  exported symbol or type changes are planned or permitted here.
- The worktree contains no node_modules until the gate; independent delta reviews can read the four files now.
