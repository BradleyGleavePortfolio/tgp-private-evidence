# N/Q1 readiness brief grant (T3, read-only)

**Parent:** EXEC-CF8FF737. **Time:** 17:05Z.

## Why now

The mission order is B, then R, then N/Q1, then C. R's single PG proof is running. Preparing N/Q1 in parallel removes idle time without contending for the heavy slot. This mirrors `r-prep/R_SLICE_BRIEF.md`, which is the reuse model for this brief.

## Owner and access

**Owner:** one T3 brief writer. The requested route is Claude Opus 5 / XHigh.

**Read-only access:**

- Git objects only, through `git -C /home/user/workspace/worktrees/s7-r-ready` using `show`, `ls-tree`, `grep <rev>` and `log`.
- No checkout, no index write and no lock. The R proof is running from that worktree.

**Base:** R head `7d2895e1`. That is B `0d69c7ba` plus R `df36e331` and `7d2895e1`. B is already landed on `integration/importer`.

## Required inputs

Reuse these; do not re-derive them.

- `/tmp/tgp-private-evidence/execution/95633079/s7-b-drain/evidence/CYCLE3_ROLLOUT_IMPLEMENTATION_HANDOFF.3300d315.md`. Relevant parts:
  - the compatibility matrix;
  - "Q0 → Q1";
  - rows M09 and N+Q1;
  - the sizing rows.
- `/tmp/tgp-private-evidence/execution/95633079/s7-b-drain/evidence/RECOVERY_SEQUENCING.3300d315.md`, including the source-level counterexample about readers in `scout-roster.service.ts` and `scout-entities.service.ts`.
- `/tmp/tgp-private-evidence/execution/e7d2385c/s7-mapping/S7_CANONICAL_CONTINUATION_MAP.md`.
- `execution/cf8ff737/r-prep/R_SLICE_BRIEF.md`, `R_IMPLEMENTATION_DECISIONS_PENDING_B_ACCEPTANCE.md` (decisions D1–D4) and `R_IDENTITY_READY_BUILD_GRANT.md`.
- `/tmp/tgp-private-evidence/execution/95633079/C1_FINAL_ACCEPTANCE.md`.
- The mobile and extension consumers of these reader endpoints, if any. Check read-only in `/tmp/landing/growth-project-mobile` (main `c7641cb3`) and `/tmp/landing/ext-full`.

## Questions to answer

Answer each with file and line evidence at `7d2895e1`.

1. **Current reader state.** For each reader on the scout ledger, including roster and entities and any others you find:
   - What does its cursor currently encode, and how does it order and filter?
   - Does any Q0 dual decoder already exist?
   - What does the current writer's selector do after R?

   The purpose is to establish exactly what N/Q1 must add. Q0 may be absent, in which case Q0 and Q1 collapse into one reader slice that decodes both formats and emits v2 only once all readers decode it.

2. **Cursor v2 contract.** Define the minimum contract:
   - the format;
   - the roundtrip;
   - scope and endpoint binding;
   - length bounds;
   - how a legacy boundary resolves to p when exactly one surviving scoped row exists;
   - the documented restart/400 response for an ambiguous or missing boundary;
   - roster legacy tokens staying unbound.

   Decide it concretely from the handoff. Frame it as parent-decidable technical contract choices. Flag anything that truly needs an owner decision, such as external API deprecation commitments. Mobile and extension are first-party consumers.

3. **Final writer on R.** Specify the required-p writer. It uses the wide selector and the five-field client, and must not package any C migration.

4. **Slice decomposition and dependencies.** Determine the ordering constraint "emit v2 only after all live readers decode v2". Is it satisfied inside one release, or does it need two slices? Check the deployed consumers: do mobile or extension parse or emit these cursors, or treat them as opaque? Then propose:
   - a T-tier for each slice;
   - owned paths;
   - PG-proof needs (cases from M09 and the N+Q1 row);
   - default-Jest needs;
   - an estimate.

5. **Reuse, and what stays out.**
   - Reuse existing tests, fixtures, harnesses and the R/B PG binding pattern.
   - C (narrow-key contraction and C.down refusal) is out of scope, as are native writers and anything G3-AUTH.

## Output

Write `execution/cf8ff737/nq1-prep/NQ1_SLICE_BRIEF.md`: concrete, decision-ready and no longer than 250 lines. Give A/B/C classification only where there is a real consequence.

## Restrictions

- No code.
- No worktree creation.
- No tests.
- No push.
- No historical PR archaeology beyond what these inputs cite.
