# TGP R2 audit index

Current round authorized in [continuation thread](https://www.perplexity.ai/computer/tasks/c505dc43-b768-4295-854f-22090ae173a6). All S1–S5 candidates remain frozen while independent A/B reviews complete; S6 remediation is a separate writable lane. No product landing or live action is authorized by a returned report.

| Lane | Candidate | A | B |
|---|---|---|---|
| S1 | 90a6647513f3566393764eee87237d9b5b1f150b | [NOT CLEARED](s1-r2/a/revision-1/REPORT.md) | In progress |
| S2 | 0b05fcf5352287109ac88ed2ba3682e441e3a076 | [NOT CLEARED](s2-r2/a/revision-1/REPORT.md) | In progress |
| S3 | 5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06 | [Affirmative bounded source/local re-attestation; overall landing/release not cleared](s3-r2/a/revision-1/REPORT.md) | In progress |
| S4 | c5a5ae12c5b3c3e32a4601c99319ad7c0d980057 | In progress | In progress |
| S5 | 485c67973b56758fb9b8404579f5ddaec87136bd | In progress | In progress |

## Interpretation and recovery

Original reports and bounded probes are preserved unchanged with per-directory SHA256SUMS. Reports may include relative links to their original workspace layout; use the frozen head's source bundle and remediation packet to resolve those references. Report-local probe/log links remain adjacent. Approximate author timestamps do not override exact Git identities or parent capture records.

S2-A identifies privileged input-to-shell execution, a machine-start route mislabeled read-only, verifier enumeration failure handling, and recovery wording. These remain independent findings pending parent disposition and peer completion; no remediation has changed the frozen S2 candidate.

S1-A identifies a missing disposable-target guard on the destructive test harness and non-discriminating atomicity/timeout-reset assertions. Its bounded additional-execution request is preserved beside the report; no database test was run by that auditor or by the parent in this round.

S3-A closes inherited local-evidence gaps but explicitly preserves governance, artifact, database and hosted recovery prerequisites. Its c12 contention explanation remains an inference, not proven causation. One affirmative lens cannot stand in for the other.

Original R1 reports and all superseded evidence remain available in their existing paths. The historical R1 index's hold statements describe that capture, not the current authorization. See [dispatch record](r2-dispatch/README.md).
