# TGP R1 Audit Index

All 12 independent R1 reports returned and archived on 2026-09-20. All six lanes are T4. Every verdict is **NOT CLEARED**. This is completion of the requested report round, not completion of testing, closure of findings, or permission to merge, deploy, enable, or claim customer acceptance.

Bradley instructed: **finish R1 only; do not start fixers.** Builders were told to hold remediation and stop starting validation. No R2 has been commissioned. Some pre-hold changes exist separately; they are not these audited candidates.

## Exact candidates and reports

| Lane | Frozen head | Auditor A | Auditor B |
|---|---|---|---|
| S1 database | `620b47fc8517fa5e5950c5b673baf8b002f5c78a` | [NOT CLEARED](s1-r1/a/revision-1/REPORT.md) | [NOT CLEARED](s1-r1/b/revision-1/REPORT.md) |
| S2 delivery | `b801a776558d18acea2d03f19029f0ea85ffca39` | [NOT CLEARED](s2-r1/a/revision-1/REPORT.md) | [NOT CLEARED](s2-r1/b/revision-1/REPORT.md) |
| S3 backend reliability | `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06` | [NOT CLEARED](s3-r1/a/revision-1/REPORT.md) | [NOT CLEARED](s3-r1/b/revision-1/REPORT.md) |
| S4 extension | `a6d885a10d7dbc64e99961f44e0f6fe7bea5dfba` | [NOT CLEARED](s4-r1/a/revision-1/REPORT.md) | [NOT CLEARED](s4-r1/b/revision-1/REPORT.md) |
| S5 G2 proof | `785d902286b5bfd15eac71c544f4837fb81ba0c0` | [NOT CLEARED](s5-r1/a/revision-1/REPORT.md) | [NOT CLEARED](s5-r1/b/revision-1/REPORT.md) |
| S6 mobile | `27b48f64b1dc8df139310941e6a6d7676ce587e6` | [NOT CLEARED, finalized amendment](s6-r1/a/revision-2/REPORT.md) | [NOT CLEARED](s6-r1/b/revision-1/REPORT.md) |

Each report records tree/base, reviewed scope, actions, findings, and evidence limitations. S5 builder commit `65b1da27d9dab4f51f5fad6d8a05be8b64e53dde` has the same tree as its audit-only snapshot; that establishes content equivalence, not release clearance.

## Preservation and interpretation

- Originals are copied unchanged with SHA256SUMS. All 12 latest copies matched their local returned originals at archival verification. S6-A revision 1 is retained alongside its finalized revision 2.
- Source-review completion is limited to each report's stated scope. Unreviewed areas and missing execution are not silently treated as audited or passed.
- Recommendations are auditor findings, not approved fixes. Severity disagreements and differing observations are preserved, not reconciled by editing reports.
- Several reports contain inconsistent approximate timestamps or observations of moving builder branches. Use Git capture history and CAPTURED_AT where present for archive timing; use frozen head/tree for applicability.
- S1 A/B differ on the certainty of Prisma transaction semantics. S5's proposed `migrate resolve --rolled-back` recovery for an already-successful migration conflicts with S1's recorded P3012 limitation. S5-A's drain-order wording also requires reconciliation with the approved phased DAG. These are unresolved review-disposition items, not instructions to execute.
- S2 A/B differ on mutable-action severity and landing-proposal availability. S4 A independently ran gates which B reports unavailable within B's window. Preserve that provenance; do not infer disagreement about the same observed run.

## Held work, not covered by these verdicts

- S2: pre-hold commits through `cb0bc910`, preserved on `s2-post-r1-held`; builder restored the frozen R1 worktree.
- S3: builder reports no source delta from R1; a previously launched detached test may still append logs. Later evidence does not rewrite these verdicts.
- S4: uncommitted browser-harness changes preserved in patch/stash; worktree restored to R1; browser proof not established.
- S5: builder commit has identical audited tree; bootstrap/runner changes held separately.
- S6: pre-hold test/dependency commit `4dcc16496b67792f45cd428d4770c405e707319b`, not attested.
- S1: held-status confirmation pending at index creation. No live application authorized.

Next step, only after the hold is lifted: disposition the complete report set, resolve conflicting recommendations, then scope remediation and risk-based re-attestation. Do not restart reconnaissance.
