# TGP R2 audit index

Current round authorized in [continuation thread](https://www.perplexity.ai/computer/tasks/c505dc43-b768-4295-854f-22090ae173a6). All S1–S5 candidates remain frozen while independent A/B reviews complete; S6 remediation is a separate writable lane. No product landing or live action is authorized by a returned report.

| Lane | Candidate | A | B |
|---|---|---|---|
| S1 | 90a6647513f3566393764eee87237d9b5b1f150b | [NOT CLEARED](s1-r2/a/revision-1/REPORT.md) | [No material source defect found; conditional merge eligibility, live hold](s1-r2/b/revision-1/REPORT.md) |
| S2 | 0b05fcf5352287109ac88ed2ba3682e441e3a076 | [NOT CLEARED](s2-r2/a/revision-1/REPORT.md) | In progress |
| S3 | 5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06 | [Affirmative bounded source/local re-attestation; overall landing/release not cleared](s3-r2/a/revision-1/REPORT.md) | [CLEARED bounded S3-lane merge eligibility only](s3-r2/b/revision-1/REPORT.md) |
| S4 | c5a5ae12c5b3c3e32a4601c99319ad7c0d980057 | [NOT CLEARED](s4-r2/a/revision-1/REPORT.md) | [CLEARED bounded merge boundary; parent hold remains](s4-r2/b/revision-1/REPORT.md) |
| S5 | 485c67973b56758fb9b8404579f5ddaec87136bd | [Accept bounded synthetic E→T/Q0 evidence; cumulative G2 NOT CLEARED](s5-r2/a/revision-1/REPORT.md) | [CLEARED bounded validation evidence; E/T releases NOT CLEARED](s5-r2/b/revision-1/REPORT.md) |

## Interpretation and recovery

Original reports and bounded probes are preserved unchanged with per-directory SHA256SUMS. Reports may include relative links to their original workspace layout; use the frozen head's source bundle and remediation packet to resolve those references. Report-local probe/log links remain adjacent. Approximate author timestamps do not override exact Git identities or parent capture records.

S2-A identifies privileged input-to-shell execution, a machine-start route mislabeled read-only, verifier enumeration failure handling, and recovery wording. These remain independent findings pending parent disposition and peer completion; no remediation has changed the frozen S2 candidate.

S1-A identifies a missing disposable-target guard on the destructive test harness and non-discriminating atomicity/timeout-reset assertions. Its bounded additional-execution request is preserved beside the report; no database test was run by that auditor or by the parent in this round.

**Parent S1 disposition:** NOT CLEARED. B independently confirms both proof limitations but grades them nonmaterial to tightening-only DDL. That narrower source acceptance does not resolve A's destructive harness boundary or justify the broader packet claims. Guard the harness before any new DB execution, then prove late-statement rollback and same-session reset (including explicit failure-path claim limits). B additionally flags verifier grant assumptions and the unproven `prisma db execute` failure exit path for the integrated S1/S2 gate. Do not add broad grants or demote a verifier automatically: establish the actual intended role contract first, preserve fail-closed behavior, and test the exact integrated invocation.

S3-A closes inherited local-evidence gaps but explicitly preserves governance, artifact, database and hosted recovery prerequisites. Its c12 contention explanation remains an inference, not proven causation. One affirmative lens cannot stand in for the other.

S4-A accepts loader/package and R1 evidence repairs but reproduces an unbounded authentication response-body wait on both baseline and candidate. That cumulative reliability finding is not an R2 regression. Dormant legacy diagnostic and harness-egress claim limitations are recorded separately; loader proof remains distinct from native customer completion.

**Parent S4 disposition:** B's bounded acceptance does not override A's reproduced cumulative authentication defect. B explicitly did not re-read unchanged session/net modules line-by-line in R2; the two reports have different coverage, not interchangeable votes. S4 remains NOT CLEARED pending narrow remediation and independent final-head re-attestation. Existing `debugger` is granted ambient capability even though the shipped flow lacks a caller; absence of a sender is not absence of permission. Distribution permission disposition remains open.

**Publication correction for S4-R2B-03:** the builder report's §4 extension IDs belong to r2b-dry, not r2c. The r2c positive ID is `opefelmelhcgipfoogkclefmdadflhpd`; control is `gndnloahgmmibdheomeedhpamgeihnjl`. Original reports/JSON are preserved unchanged; this footnote corrects attribution without rewriting evidence.

S3's independent pair accepts bounded source/local evidence on the unchanged head; cross-lane merge/release prerequisites remain open. B requests an optional stamped type-check follow-up. The restored current worktree lacks dependencies and is not the historical builder environment; the parent's scheduling decision must account for that rather than assume a two-minute ready-to-run command.

S5-A accepts the exact-head synthetic run, not production applicability. It records an E-specific recovery-guidance gap, missing terminal-result/target assertions in one race characterization, and an archive-only O restoration recipe incompatible with the bootstrap Git identity gate. No database repeat is required merely to preserve the accepted historical evidence.

S5-B independently accepts the same bounded validation evidence and preserves the E/T release holds. Its proposed replay's archive-only O restoration inherits the recipe defect identified by A; do not execute it verbatim. Use an identity-checked detached Git worktree/clone for O. The E recovery packet must verify catalog/history, table identities, policies and data invariants, not treat column presence alone as sufficient truth. Ledger totals on unstaged synthetic legacy rows are characterization, not proof of erroneous normal-operation per-run counts.

Original R1 reports and all superseded evidence remain available in their existing paths. The historical R1 index's hold statements describe that capture, not the current authorization. See [dispatch record](r2-dispatch/README.md).
