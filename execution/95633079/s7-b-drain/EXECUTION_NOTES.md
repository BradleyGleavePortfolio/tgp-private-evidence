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
