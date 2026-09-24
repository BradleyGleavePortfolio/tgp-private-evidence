# C build grant (T4): phase 1 drafting now, phase 2 after N/Q1 acceptance

**Parent:** EXEC-CF8FF737. **Time:** 18:15Z.

**Input:** `c-prep/C_SLICE_BRIEF.md` (143 lines). It is adopted as the C contract: §1–§4 design, cases C01–C18, owned paths, and T4 routing.

## Parent decisions

### D-C1: late-ingest sealing (F1)

Option (i) is adopted: reconstruction is not a snapshot, the next idempotent replay converges, and the tally is ledger truth.

- No ingest seal code is added, and replay-after-settle keeps its current 202 deduped behaviour.
- This is parent-decidable because it involves no extension-visible behaviour change.
- **C18 is in scope.** It must prove two things:
  - **(a)** After a late ingest between count and paging, the next replay converges, and the tally equals the ledger.
  - **(b)** A row left `staged` after a pass remains observable as `staged` in the ledger and staging state; nothing marks it reconstructed.
- **Carry-forward to S9.** The terminal outcome must not report a complete import while scoped `staged` rows remain unaccounted. This is an explicit reconciliation requirement for S9, not C scope.

### D-C2: production promotion (F2)

This is recorded as owner input. Draft #530 must never be merged or deployed as one unit. Promotion advances `main` stepwise to exact stage commits (brief §5), each with its own dispatch.

This blocks no local work, and the #530 body is updated to say so.

### Other D-C decisions

- **C id and verifier:** the C migration id is `20270121000000_scout_identity_contract`, with no `verify.sql` (brief §1).
- **C.down:** the refusal uses fixed 23505 text with no identifiers. Nothing is deleted or deduplicated (brief §2).

## Phase 1: now, in parallel with the N/Q1 build

**Owner:** one T4 builder. The requested route is Claude Fable 5.1 / High.

**Worktree:** a new worktree `/home/user/workspace/worktrees/s7-c`, created with `git -C /home/user/workspace/worktrees/s7-b-drain worktree add /home/user/workspace/worktrees/s7-c -b s7-c 7d2895e1fe03ea82353e8ce0b07aacaf66af74c8`. Do not install `node_modules` in phase 1, because disk is limited.

**Owned paths in phase 1:** these are disjoint from N/Q1.

- `prisma/migrations/20270121000000_scout_identity_contract/{migration.sql,down.sql}`
- `test/rls-g2-c-contract.spec.ts`
- `test/utils/g2-c-{bootstrap.sh,db.ts,harness.ts,pg-harness.ts}`
- `test/scout/g2-c-db-guard.spec.ts`
- the C PG binding template, under `execution/cf8ff737/c/binding/`
- `docs/decisions/2026-09-24-g2-identity-contract.md`, the runbook covering down order, forward repair and `migrate resolve` after a production C.down

**Out of phase 1:** `prisma/schema.prisma`, `src/**`, `docs/contracts/**`, and the existing specs. These overlap N/Q1 and wait for phase 2.

**Rules for phase 1:**

- Draft only; do not commit.
- No tests, no PG, and no lock.
- Do not touch `s7-nq1`, other worktrees or the clusters. Read-only `git -C … show` of other trees is allowed.

**Output:** write `execution/cf8ff737/c/PHASE1_DRAFT_READY.md`, listing the files, the case-to-test mapping and any open questions. Then stop.

## Phase 2: after the parent records N/Q1 acceptance

The parent will message the builder. Phase 2 covers:

1. Rebase the drafted files onto the N/Q1 accepted head.
2. Apply the `schema.prisma` and `src` doc/text changes, the structural and fake spec flips, and the OpenAPI regeneration (brief §3).
3. Run genuine hooks and make one ordinary commit, with Bradley as author and committer and no trailers.
4. Run light gates: `tsc`, eslint and prettier on touched paths. Default Jest needs the heavy slot, which is requested from the parent.
5. Fill the binding and write `c/SOURCE_READY.md`.

After that come two independent T4 attestations (brief §4 lenses), then one single-run PG grant for C01–C18.

## Parent addendum (18:50Z)

Phase 1 is complete (`c/PHASE1_DRAFT_READY.md`: 8 drafted files and the binding template).

**For phase 2:**

- **Path added:** `test/utils/g2-c-old-root.sh` is added to the owned paths, derived from the committed `g2-nq1-old-root.sh`.
- **Rebase:** the drafted files move onto the N/Q1 accepted head, as the grant already states.
- **In-process ingest service:** using a real in-process `ScoutIngestService` for the ingest cases is accepted. The pinned worker stays untouched.
- **Staging semantics:** the case assertions follow the real behaviour, where staging has no status column and the ledger tally is cumulative.
- **C18(b):** it is satisfied by showing that the ledger has no reconstructed row, and no target, for the late-ingested identity until the replay runs.
