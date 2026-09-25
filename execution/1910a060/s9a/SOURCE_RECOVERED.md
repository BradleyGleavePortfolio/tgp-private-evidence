# S9-A SOURCE_RECOVERED (A-NEW-1, EXEC-1910A060)

Written 2026-09-25T21:13:42Z by A-NEW-1 (sole S9-A source recovery/freezer, T4). Source recovery only: no install, gate, hooks, format, commit, push or PG. Lock at /home/user/workspace/execution/test-validation.lock (inode 667698) NOT opened or touched.

## Standalone clone

- Path: /home/user/workspace/worktrees/1910a060-s9a (fresh `git clone --no-checkout --single-branch --branch integration/importer` from https://github.com/BradleyGleavePortfolio/growth-project-backend.git; own .git, index, config; .git/hooks contains only git sample hooks, no lefthook installed, no core.hooksPath; not a shared worktree).
- Branch: exec1910/s9a at HEAD 1c5fbb0441178e0cfe6e9f8d72e955c645c265e9 (= remote integration/importer at clone time; landed S9-0).
- Landed S9-0 doc docs/decisions/2026-09-25-s9-reconciliation.md sha256 cda68d826be08e5bf5cd1152ecbb092b10dfc373c7234bd73943815d0d07bab1 (= frozen cda68d82 that S9-A was built against).
- No node_modules; no tracked file touched.

## Exact copy (mechanical cp from private evidence daceddc8/s9/gate/preformat-*)

Source hashes verified against the recorded values BEFORE copy, then destination verified byte-for-byte (sha256 + cmp) AFTER copy. No edit, no refactor, no recreation; the B-1 union (reconcile.ts closeRelationships, `prev === undefined ? o.verified : new Set([...prev, ...o.verified])`, L298) and the R06 review-B-1 spec row (L795) are present in the recovered bytes.

| Path | sha256 | lines | git blob |
| --- | --- | --- | --- |
| `src/scout/reconciliation/types.ts` | `eff1479cd2b735aacadc42ee3e2280dcfaf2e4fcc27a1fb90fd2c2bf2db1dbfa` | 386 | `bb28f151a88435abc69d337a92dd3bc2ab7203bd` |
| `src/scout/reconciliation/coverage.ts` | `c6b224fa860261d6240c5bd62b07d419c6b9346c0b0de4eaac64dd9215926701` | 77 | `e13c336ad35a43a26a5e8856a8e810eb96c5dd99` |
| `src/scout/reconciliation/reconcile.ts` | `83d7673b024513bbee938bf4a5467c4faa9306739f15ae53b69722936d7d9e1f` | 428 | `3932cd3caed21d705c5718e547e225c1a326d5ad` |
| `test/scout/reconciliation/reconcile.spec.ts` | `99068057b0b99d95c9601c02130e4eca2b3b07acd0e0088fae146cb2f54edb74` | 1236 | `df887df51a25f48b77564931eac75af5ed71a153` |

Expected (task/SCOPE): types eff1479c…1dbfa; coverage c6b224fa…6701; reconcile 83d7673b…9e1f; spec 99068057…db74. All four match.

```
?? src/scout/reconciliation/coverage.ts
?? src/scout/reconciliation/reconcile.ts
?? src/scout/reconciliation/types.ts
?? test/scout/reconciliation/reconcile.spec.ts
```

## Interface note for S9-B (mail b78194d9)

types.ts is byte-identical to eff1479c…; S9-B may read it as a read-only dependency. Prettier in the gate will change layout only (review A predicted post-format sha 211b474a…7114 for types.ts); no exported name, type or value changes are planned or permitted in this lane.

## Not done (awaiting parent relay)

node_modules copy/install, prettier 3.9.9 prefix, prettier/eslint/tsc/jest, lefthook install, commit. See GATE_PLAN.md and s9a-gate-1910.sh (prepared, unrun).
