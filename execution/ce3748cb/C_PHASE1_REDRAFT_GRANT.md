# C — phase-1 re-draft + phase-2 preparation grant (T4)

Parent EXEC-CE3748CB, ~20:15Z. Authority: `execution/cf8ff737/C_BUILD_GRANT.md`, `c-prep/C_SLICE_BRIEF.md`, `c/PHASE1_DRAFT_READY.md` (the lost draft's exact specification). The 8 untracked phase-1 files were lost with the predecessor sandbox (C); the preserved binding `c/binding/**` is reused unchanged.

## Parent dispositions of the phase-1 open questions
1. Base: create worktree `/home/user/workspace/worktrees/s7-c` (branch `s7-c`) at N/Q1 v1 `61b93cff`. v2r is test-only on N/Q1-owned files, disjoint from C; the final rebase onto the accepted N/Q1 head is mechanical and happens in phase 2 after N/Q1 acceptance. Placeholders `__NQ1_ACCEPTED_HEAD__` stay until then.
2. Candidate `prisma migrate deploy` for C (stronger than by-file) — ACCEPTED.
3. In-process real `ScoutIngestService` via `ingestClient` — ACCEPTED; do not modify `g2-tq0-worker.cjs`.
4. C16 token semantics — verify against committed Q1 readers at 61b93cff now (they are identical in v2r).
5. `schema.prisma` two `@@unique` removals + C-only generate — phase 2.
6. Verify R.down `wide()` shape from source now.
7. `test/utils/g2-c-old-root.sh` — ADDED to owned paths, derived from committed `g2-nq1-old-root.sh`.
9. Doc/text fixes (controller wording, OpenAPI regen, comments) — phase 2 owned paths.
11. C10 reverse: keep full chain through E.down with ledger emptied for the E step only, re-derived after (as drafted).
F1 (late-ingest) resolved by D-C1 option (i) + C18: next replay converges; S9 carry-forward.

## Owned paths
`worktrees/s7-c/**` limited to: the migration folder `prisma/migrations/20270121000000_scout_identity_contract/{migration,down}.sql`, `test/utils/g2-c-*.{ts,sh}`, `test/scout/g2-c-db-guard.spec.ts`, `test/rls-g2-c-contract.spec.ts`, `docs/decisions/2026-09-24-g2-identity-contract.md`; plus `execution/cf8ff737/c/**` (append-only; binding files unchanged unless a phase-1 re-derivation mismatch is found, then STOP and report).

## Now (phase 1 only, source-only)
Re-author all phase-1 files to the preserved specification (lines/cases C01–C18 + N/Q1 continuity). No node_modules, no tests, no PG, no lock, no commit. `bash -n` on shell files. Verify every "facts verified" item against the 61b93cff source. Write `c/PHASE1_REDRAFT_READY.md` with a file table (path, lines, sha256) and any deviation from the preserved spec, then STOP for the phase-2 message. Do not push. Never touch `s7-nq1`, `/home/user/pg17`, or other lanes.
