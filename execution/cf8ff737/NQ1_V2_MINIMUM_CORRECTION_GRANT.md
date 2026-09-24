# N/Q1 v2 minimum correction grant (T4)

**Parent:** EXEC-CF8FF737. **Time:** 18:50Z.

## Failure

The single PG proof at `61b93cff` failed with rc 1 at the jest stage: 15 of 20 passed, and 5 failed (N02, N03(a), N06, and Q05 ×2). The failure stays recorded (`nq1/NQ1_PG_PROOF_RESULT.md`, receipts 14–15). It is not rewritten.

## Classification

This is **B, blocking the N/Q1 proof only.** It does not affect the product path and does not block C phase 2's drafting.

**Evidence that the failures are in the spec:**

- In every failing case, N and T agree. The N==T tally assertion passed just before each failing line.
- **Q05:** the brief (`nq1-prep/NQ1_SLICE_BRIEF.md` L103) specifies that a foreign coach or intent gets 400 `malformed cursor`. The observed 400 matches the contract. The spec's 404 expectation was wrong.
- **N03(a):** it is missing a `resetData()` call before staging `m1`, so three leftover rows from N01 were counted.
- **N02 and N06:** the inherited `failEvery` knob (`name='FAIL'`) is inert. Nothing in `src/scout` fails those rows. The expected 20/4 split was never reachable.

**Concrete harm:** N/Q1 cannot be accepted or landed, and C phase 2 (which rebases onto N/Q1) waits.

**Consequence for the proof (important):** N03 requires "success dominates failed/skipped both ways" (brief L95). With the knob inert, no genuine failed or skipped outcome exists in the fixture. Simply changing the expectations to 24/0 would drop required coverage, so it is **not** an acceptable closure.

## Minimum closure

One new commit on `61b93cff`, with Bradley as author and committer, no trailers and genuine hooks. Only spec and N/Q1 harness paths may change: `test/rls-g2-nq1.spec.ts`, plus `test/utils/g2-nq1-*` only if needed.

- **No change to:** `src/**`, `prisma/**`, the contract, or any pinned R, B or S5 object.

**The four corrections:**

1. **Q05:** a foreign coach and a foreign intent each assert 400 `malformed cursor`, with no page read and no reflection. This matches the brief.
2. **N03(a):** call `resetData()` before staging `m1`. The assertions stay unchanged.
3. **N02 and N06:** replace the inert knob with a genuine, data-reachable non-success path that the current `src/scout` actually produces.
   - Prefer the existing "unknown platform → skipped" path, or another failed or skipped path the product really takes.
   - Keep the N==T tally equality.
   - The expected numbers must follow from the fixture and the product's logic. Do not tune them to what was observed.
4. **N03:** ensure "success dominates" is exercised against a genuine failed or skipped outcome in both orders.

**Stop condition:** if no genuine non-success path is reachable through data, STOP and report. Do not add product code.

## Gates

These are light: `tsc`, eslint, prettier and check-r75 on the touched files. The default-Jest db-guard runs if touched. The PG spec is excluded from default Jest.

Then refill the five pins, reseal the binding, and write `nq1/SOURCE_READY_V2.md`.

## Lane

Before the next run, the parent grants a preserving rename of the retained `clusters/nq1` to `clusters/nq1.v1-failed-61b93cff-<UTC>`, following the B v4 PRE-1 precedent. The builder performs the rename only at the start of the next PG grant. Nothing is deleted.

## Next

1. Both attesters give a delta re-attestation, bound to the new head: the spec delta, plus a check that the five failures were spec-only.
2. Then a new single-run PG grant.
