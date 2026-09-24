# S7 B/drain builder — execution notes (additive; not part of the frozen v2 packet or the fixture proposal manifest)

## 2026-09-24 ~07:25Z — blocked command (no change occurred)
While writing `fixture-proposal/PROPOSAL.sha256`, one shell invocation carried a trailing
`git add -N .` addressed to the frozen worktree `/home/user/workspace/worktrees/s7-b-drain`.
The action safety classifier blocked the WHOLE command before execution: no manifest write, no
index change, no worktree change. The command was re-issued without the git write. Read-only
verification afterwards: HEAD `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992`, tree
`87798e742c7b48f56b05e9b5c30efa877180a9b3`, 7 untracked paths, `frozen-v2/SOURCE.sha256`
verifies (`v2-bytes-intact`). Classification per parent: execution note only — not a product
finding, not a control cycle. Rule going forward: never stage or intent-to-add under an
evidence-only proposal grant.

## Parent correction to proposal §5 ordering (recorded, proposal left unchanged pending findings)
The executable sequence, once granted step by step, is:
1. matching isolated C1 dependency reuse (plain copy) — precedes all affected checks;
2. affected repo-gate checks on the v3 candidate (format check under a NEW grant — the completed
   format-only grant is not reusable);
3. genuine lefthook hook installation;
4. ordinary Bradley-authored commit (v3);
5. only then: bind runtime pins (`EXPECT_HEAD/TREE/SPEC_BLOB/BOOTSTRAP_BLOB/FIXTURE_SHA`) in
   `binding/b-pg-proof.sh`;
6. one bounded proof run under a separate PG runtime grant.
Placeholders in `binding/b-pg-proof.sh` mean the binding is NOT runtime-grantable yet.
Reviewers assess the donor bootstrap delta; O-client generation is provisionally a necessary
distinct-schema fixture dependency; no candidate regenerate, no predecessor assertion rerun.

## State
- `fixture-proposal/` (16 files, `PROPOSAL.sha256`) and `frozen-v2/` unchanged since handoff.
- No install/copy/hooks/commit/PG action taken. Waiting for reviewer findings / next scoped grant.

## 2026-09-24 ~07:55Z — v3 source closure composed and frozen (consolidated minimum source closure grant)
Edits confined to the 7 untracked v2 paths + 4 new adapter paths in worktrees/s7-b-drain (tracked files untouched,
index clean, no hooks, no node_modules). Prettier 3.9.6 (sha verified) --check/--write under flock -n: 2 files
reflowed format-only, 8/8 TS conformant. v3 tree 00b105ffe362c27808a38c44c6db1f733134f074 via temp index (no
commit). Packets: frozen-v3/ (PACKET.v3.sha256), fixture-proposal-v3/ (PROPOSAL.v3.sha256). v1/v2/fixture-proposal
unchanged (PROPOSAL.sha256 and PACKET.v2.sha256 re-verified). No install/copy/hooks/tsc/eslint/jest/commit/PG/probe.

## 2026-09-24 ~08:02Z — reviewer B v3 B-4 (test-only): proposed successor delta prepared, NOT applied
Live v3 source held unchanged (SOURCE.sha256 re-verified) pending reviewer A. Proposed minimal fix staged as
frozen-v3/successor-proposal/B-4.zero-retry-fresh-fixture.diff (+ full proposed file): the zero-retry case uses a
fresh FakeLedger([row('a')]) with fenced=true / faults=['lock'] and asserts that instance (chunks 0, lockFailures 1,
stalledByLocks, 'stalled', transactions 1). To be consolidated with any A result into one successor under a later
grant; no formatter/commit/lock action taken (J3 owns the slot).

## 2026-09-24 ~08:08Z — v4 (B-BD-FRESH-FAKE, test-only) applied, format-checked, frozen
Applied the proposed fresh-FakeLedger hunk to src/scout/scout-ledger-backfill.spec.ts only (11 lines); all other v3
paths/blobs/modes unchanged. One pinned Prettier 3.9.6 --check under flock -n: pass, no write; lock released at once;
no formatter process left. v4 tree f4922ca070e887fb7f613ce955b12621b5c33156 (temp index, no commit); packet
frozen-v4/ (PACKET.v4.sha256). v3 packet and successor-proposal retained as history (PACKET.v3 re-verified).
No env copy/install/generate/tsc/lint/jest/hooks/commit/PG.

## 2026-09-24 08:16–08:19Z — Phase A run 1: stopped by own preflight-style detector after dependency copy (rc 71)
Driver phase-a/phase-a.sh (sha 31e061ec…) under canonical flock -n. PREFLIGHT_OK (base, 11 path/mode/blob = frozen-v4,
accepted/S5 pins, parity, node/npm, identity, no hooks/node_modules). cp -a --reflink=auto of accepted C1 node_modules
completed: 649 entries, 717M, real directory, 0 shared inodes, 0 multi-link files, .package-lock.json and
.prisma/client/index.d.ts SHAs match C1 record. Detector "symlinks_outside_tree" counted 1: node_modules/.bin/prettier
is an ABSOLUTE symlink to the approved external Prettier 3.9.6 CLI (sha 6e922134…), identical in the accepted C1 tree
itself (inherited by the isolated copy, not a link into C1's node_modules). Stopped at stage copy-symlink-outside per
first-nonzero rule; no lefthook install, no staging, no gates, no commit; index clean, 0 hooks, lock released on exit.
Copied node_modules left in place (verified). Minimum closure proposed to parent: whitelist exactly that one known
symlink (pin target sha) in the detector and resume from stage 2 without re-copying. Not self-applied.
