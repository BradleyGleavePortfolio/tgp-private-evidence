# N/Q1 single real-PG proof grant

**Parent:** EXEC-CF8FF737. **Time:** 18:37Z.

## Basis

Both independent T4 attestations are GO, with no A or B.

| Attestation | Findings | File |
|---|---|---|
| A (writer and contract) | 5 C | `nq1-att-a/NQ1_ATTESTATION_A.md` |
| B (readers and proof) | 9 C | `nq1-att-b/NQ1_ATTESTATION_B.md` |

## Bound identity

| Item | Value |
|---|---|
| Head | `61b93cff7900b24c17011d481fd6c31f5abb59e4` |
| Tree | `7adad6965d60269046b3240343b54d7f71582d70` |
| Parent | R `7d2895e1` |
| Binding `nq1-pg-proof.sh` sha256 | `e47c9ac1bd073e2b92432bf1a4809bd2d30e4c63c61aec33fa0ccc339746a190` |
| Fixture sha | `29db46ad…` |
| Spec blob | `8ad3af3f…` |
| Bootstrap blob | `96b7668d…` |

## Lane conditions

The parent verified these at 18:37:16Z:

- no `clusters/nq1`;
- no `nq1/runtime`;
- 0 postgres processes;
- port 55481 free;
- retained clusters `b-drain`, `b-drain.v4-failed-…` and `r-ready` all stopped, with no `postmaster.pid`;
- `test-validation.lock` free;
- 4.5 GiB free disk (floor 3 GiB);
- the worktree clean at the head.

## Grant

The N/Q1 builder `n_q1_final_writer_reader_t4_build_mufshyuw` may run exactly once:

`timeout -k 30 3600 bash execution/cf8ff737/nq1/binding/nq1-pg-proof.sh`

It must take the heavy slot through the binding's own nonblocking `flock`. The slot is relayed now.

## Conditions

**Retained clusters**

- The binding may only hash the retained clusters. It must never start or write them.
- None may be disposed of.

**No retry**

- A fail-closed stop is final for this grant, including the sentinel.
- The first nonzero result is reported unchanged.

**Report and review**

- The builder writes `nq1/NQ1_PG_PROOF_RESULT.md`, including the receipts.
- Both attesters then write their final findings.
- If both ACCEPT, N/Q1 becomes landable to backend `integration/importer` as a fast-forward from `c7a5fe8d`, if that is still the tip.
- Because N/Q1's parent is `7d2895e1` and PROD-CI-1 `c7a5fe8d` is its sibling, landing needs a Bradley no-conflict merge, or a rebase of N/Q1 onto `c7a5fe8d`. The paths are disjoint.
- The parent decides that at landing. Whichever option is chosen, the landed tree must equal the three-way union, and no PG rerun is required, because PROD-CI-1 touches only the CI workflow and `release.sh`.
