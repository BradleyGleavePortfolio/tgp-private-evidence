# R single real-PG proof grant

**Parent:** EXEC-CF8FF737. **Time:** 17:00Z.

## Basis

Both independent T4 reviewers have issued a delta re-attestation of GO with no new A or B:

- `r-review-a/R_REATTEST_A.md`
- `r-review-b/R_REATTEST_B.md`

## Bound identity

| Item | Value |
|---|---|
| Head | `7d2895e1fe03ea82353e8ce0b07aacaf66af74c8` |
| Tree | `95cdfadc1ae993db23d0d1310ee8029c7867d147` |
| Spec blob | `0ae7b76489460dac33dff5434503a361a0acd063` |
| Binding `r-pg-proof.sh` sha256 | `787d34b08f7abcbc18fa077eed29b15167fc762983f47fe58e3de6beb89b3cc2` |
| Fixture sha | `6e71d754…` |

## Lane conditions (PRE-R3)

The parent verified these at 17:00Z:

- no `clusters/r-ready`;
- no `r-ready/runtime`;
- 0 postgres processes;
- port 55471 free;
- both retained B clusters stopped, with no `postmaster.pid`;
- `test-validation.lock` free;
- 3.6 GiB free disk.

**Disk (C).** 3.6 GiB is above the grant's 3 GiB floor. Reviewer A's earlier 4 GiB figure was advisory. The binding has no disk check of its own. The B v5 cluster reached 77 MB.

## Grant

The R builder `r_slice_source_only_preparation_mufnlmx0` may run exactly once:

`timeout -k 30 3600 bash execution/cf8ff737/r-ready/binding/r-pg-proof.sh`

It must take the heavy slot through the binding's own nonblocking `flock`. The heavy slot is relayed now.

## Conditions

**Retained B clusters**

- The binding may only read their hashes. It must never start or write them.
- Neither cluster may be disposed of.

**No retry**

- A fail-closed stop is final for this grant, including the sentinel.
- The first nonzero result is reported unchanged.

**Report and review**

- The builder writes `r-ready/R_PG_PROOF_RESULT.md`, including the receipts.
- Both reviewers then write their final findings.
- If both ACCEPT, R becomes landable to backend `integration/importer` as a fast-forward from B, under the owner amendment.
