# S3 evidence completion, unchanged R1 source

Received 2026-09-20 17:30 UTC. Source head `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06`, tree `83211d25d714e4c539cd3aa248a06ef0658fc8e7`, base `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`. Worktree was clean at receipt. No source changes were made after the R1 freeze.

## Preserved packet

`revision-1/` contains the builder's original returned report, every finding disposition, publication manifest, candidate bundle, 16 logs, 10 scripts and original checksum list. Every listed checksum passed before publication; the incremental bundle verifies against the public base. Failed/OOM/timeout evidence remains intact alongside subsequent passing runs. Restore instructions are in `../README.md`.

`revision-2/` is the current corrected builder packet. It preserves the same source, tests and bundle, removes stale status and unmeasured CI-headroom claims, qualifies the contention explanation as inference, and bases deferrals on product consequences rather than audit-binding preservation. Four standalone probe/retained-fixture files are added for recovery. All 34 listed checksums passed; the checksum-list SHA-256 is `8646c0753c2ac566e420a863f180b85fee9827c6d3d524918269d82b116ca9fd`. Revision 1 is retained unchanged for provenance.

The four shard summaries record 545 passing suites, 12 skipped suites, 8,209 passing tests, 159 skipped tests, five todo tests and zero failures. Build, final readiness trio, control-source lint and package-lock advisory checks have separate logs. This index records receipt and preservation, not an independent correctness audit.

## Parent applicability cautions

- Builder-marked finding closure is **proposed closure**, pending both independent auditors' evidence review. Original R1 verdicts remain NOT CLEARED.
- Same-tree timing at different host loads strongly supports contention as the timeout explanation; it does not by itself exclude all alternative causes. The original report's assertion that CI runners are unloaded is not measured.
- Preserving an audit binding is not, by itself, a valid reason to defer a material defect. Nonmaterial deferrals require their own consequence-based justification; auditors must assess those dispositions.
- A few historical findings in the original report retain stale “running” or “pending” language. A bounded documentation correction was requested; the original packet remains unchanged.
- Database/RLS suites, hosted workflows, Docker/Fly execution, production boundaries and integrated release behavior are not proven by these logs.

State: written, locally built/type-checked/linted/tested; **not independently audit-cleared, merged, deployed, enabled or customer-accepted**. S1/S2 remediation remains active; S4–S6 remain held.

Publication status at this update: GitHub rejected the S3 packet push and API reads with HTTP 401 after the earlier checkpoint was successfully published at `2135de9dae6ca2d378574e9a46bf8d92d230bda9`. Reauthorization requested. Both S3 revisions and the updated handoff are also preserved in the attached **TGP S3 completed-proof recovery checkpoint**; no successful GitHub upload of this completion packet is claimed yet.
