# R closure 1 grant

**Parent:** EXEC-CF8FF737. **Time:** 16:40Z.

**Basis:** `r-review-a/R_ATTESTATION_A.md` (B-1, B-2, B-3) and `r-review-b/R_ATTESTATION_B.md` (B-1, B-2). Every finding below is B, proof-invalidating. None is A, and neither reviewer found any product data-safety defect. The single PG grant stays withheld until the preconditions below are all met.

**Owner:** the R builder `r_slice_source_only_preparation_mufnlmx0`, working in `worktrees/s7-r-ready` on top of `df36e331`.

## Minimum closure, in one hooked Bradley commit plus one binding refill

### 1. Guard order (review A B-1), option (a)

In `migration.sql`, move the "G2-R wide identity already present" gate so it runs before the column-prerequisite gate. It should sit immediately after the narrow-index loop.

- The gate's text and predicate stay byte-identical. Only its position changes.
- Nothing else in `migration.sql` changes, and `down.sql` does not change.
- The spec lines at 452, 462 and 660 stay unchanged.

### 2. R11 decoy assertion (review B B-2)

This is a change to the spec file only.

- In R11, after the decoy is created, snapshot `wide()`.
- Assert that `wide()` equals that snapshot after the refusal.
- Also assert `ledgerNotNull === false`, and that no R-named object exists on the two real tables.
- An equivalent route is also acceptable: give `expectRefusedUp` an optional `expectedWide` argument that defaults to `ABSENT`.
- No harness, fixture or other test changes.

### 3. Commit

Make one new commit on `s7-r-ready`.

- Author and committer are both Bradley Gleave <bradley@bradleytgpcoaching.com>, with no trailers.
- The genuine Lefthook hooks must run: tsc, eslint, prettier, check-r75 and default Jest. No `--no-verify`.
- The diff must be confined to `prisma/migrations/20270120000000_scout_identity_ready/migration.sql` and `test/rls-g2-r-ready.spec.ts`.
- Take the heavy slot only when the parent relays it. The first nonzero result stops the run.

### 4. Binding refill

Edit `r-ready/binding/r-pg-proof.sh` and mirror each change in `derive-r-pg-proof.py`:

- **B-2A / B-1B:** change line 45 to `G2_R_DATA_DIRECTORY=$RDIR/pg-data`.
- **B-3A:** find the hooks with `H=$(git -C "$W" rev-parse --git-path hooks)`, then check `$H/pre-commit` and `$H/commit-msg`.
- **Pins:** refill `EXPECT_HEAD`, `TREE` and `SPEC_BLOB` from the new head. Also refill `BOOTSTRAP` only if it changed. The fixture sha must stay `6e71d754…`.
- **Checksums:** recompute `PINS.txt` and `BINDING.sha256`.

### 5. Report

Write `r-ready/R_CLOSURE_1_READY.md`. It must contain:

- the new head, tree and spec blob;
- the exact diff since `df36e331`;
- the hook receipts, appended rather than rewritten;
- the old and new binding sha;
- the binding diff.

## After the report

Both reviewers re-attest only the delta: the moved gate, the R11 hunk and the binding lines. The unchanged bytes are not re-reviewed.

Once both say GO, the parent writes `R_SINGLE_PG_PROOF_GRANT.md`. The conditions in PRE-R3 still apply: no `r-ready` cluster, the B clusters stopped and untouched, port 55471 free, and at least 3 GiB free.

## Qualified, no work created

C-R1 through C-R9 from review A, and C-1 from review B (run R as a BYPASSRLS role), are carried into the release runbook notes. C-R7 (`MERGE_HEAD` in a linked worktree) is left as-is.
