# C readiness brief grant (T3, read-only)

**Parent:** EXEC-CF8FF737. **Time:** 17:55Z.

## Why now

The mission order is N/Q1, then C. The N/Q1 T4 build is active, so preparing C in parallel removes idle time with no slot contention. This follows the same pattern as `nq1-prep/NQ1_SLICE_BRIEF.md`.

## Owner and access

**Owner:** one T3 brief writer. The requested route is Claude Opus 5.5 / XHigh.

**Read-only access:** Git objects only, through `git -C` using `show`, `ls-tree`, `grep <rev>` and `log`. No checkout, no index write and no lock.

- **Product source:** `/home/user/workspace/worktrees/s7-r-ready` at R `7d2895e1`.
- **CI harness:** `/home/user/workspace/worktrees/prod-ci-1` at `c7a5fe8d` (the current `integration/importer` tip).
- **Do not touch `s7-nq1`.** The N/Q1 builder owns it. You may read its uncommitted diff only through `git -C /home/user/workspace/worktrees/s7-nq1 diff` (read-only), to note overlaps.

## Required inputs

Reuse these; do not re-derive them.

- `/tmp/tgp-private-evidence/execution/95633079/s7-b-drain/evidence/CYCLE3_ROLLOUT_IMPLEMENTATION_HANDOFF.3300d315.md`. Relevant parts:
  - the compatibility matrix, column C;
  - the C row of the implementation table (about line 98);
  - the release-artifact separation rule (about line 100);
  - the stage-transition and C.down rules (about lines 150–160);
  - the M-case table (about lines 160–180), especially cases 01, 02 and 08–09;
  - the sizing rows.
- `/tmp/tgp-private-evidence/execution/95633079/s7-b-drain/evidence/RECOVERY_SEQUENCING.3300d315.md`.
- `execution/cf8ff737/nq1-prep/NQ1_SLICE_BRIEF.md` and `NQ1_BUILD_GRANT.md`.
- `r-prep/R_SLICE_BRIEF.md`, `R_LOCAL_ACCEPTANCE.md` and the R PG binding pattern.
- `PROD_CI_1_ACCEPTANCE.md`, covering the order-aware reversibility harness.
- R's `down.sql` and its staged fail-closed design, plus E's and B's.
- Backend `scripts/release.sh` and `.github/workflows/fly-deploy.yml` at `c7a5fe8d`. The handoff says E, R and C must be separate promoted releases; fly-deploy requires `release_sha` to equal the current `main` head.

## Questions to answer

Answer each with file and line evidence.

1. **C migration contract.** Specify `…_scout_identity_contract/{migration.sql,down.sql}` and the matching `schema.prisma` changes:
   - the fresh monotonic id after `20270120`;
   - which exact narrow unique indexes and constraints are dropped, on both staging and ledger;
   - which declarations are removed from Prisma;
   - the preconditions C.up must assert and fail closed on, covering wide keys present and valid, CHECKs, NOT NULL, and no NULL p;
   - lock and statement-timeout posture;
   - verify.sql, if the release script requires one.

2. **C.down contract.** C.down recreates the narrow indexes back to R. It must refuse, atomically and preserving data, when a cross-family collision (M09) exists, and give a clear forward-repair message.
   - Is C.down compatible with PROD-CI-1's chain harness, both as the newest migration and within the chain C.down → R.down → B.down → E.down?
   - Does R.down's staged refusal still hold once C exists?

3. **Code that must change or verify at C.** List everything that still references the narrow selectors or indexes, including the generated client, writers, readers, specs and fixtures. N/Q1 should already use the wide selector only. Also check the ingest `ON CONFLICT DO NOTHING` semantics once only the wide index remains, which enables the M01/M02 cross-family behavior.

4. **Proof plan.** Give the minimum PG cases, reusing R/B harness patterns and M01, M02, M08 and M09, along with the negative controls: R still dedupes, and C.down refuses on collision. State the default-Jest needs.

   Propose the tier, owned paths and an estimate. Note the dependency on N/Q1's accepted head, since both touch `schema.prisma`.

5. **Promotion note.** C must be a separate production release from N/Q1. State what that means for later promoting `integration/importer` to `main`: `main` would be advanced stepwise to exact stage commits, each dispatched separately.
   - This is advisory for the owner's deploy decision only.
   - Flag any production-data-dependent preconditions. For example, B's backfill must run on production data before R, and any NULL-p rows.
   - These are not local blockers.

## Output

Write `execution/cf8ff737/c-prep/C_SLICE_BRIEF.md`: concrete, decision-ready and no longer than 220 lines. Give A/B/C classification only where there is a real consequence.

## Restrictions

- No code.
- No worktree creation.
- No tests.
- No push.
- No PR archaeology.
