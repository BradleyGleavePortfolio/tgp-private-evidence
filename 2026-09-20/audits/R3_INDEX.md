# TGP R3 independent audit index

Observed 2026-09-20 23:33 UTC. Reports are frozen independent opinions; parent disposition is consequence-based, not a vote. No release or customer acceptance follows from a lane verdict.

| Lane | Frozen candidate | Audit A | Audit B | Parent status |
|---|---|---|---|---|
| S1 | `b7d7fe59` | Active, independent | Active, independent | 89/89 real PG17.6 synthetic checks passed; builder evidence, not clearance |
| S2 | `e15e25c2` | Source review active | Source review active | 172/172 exact-head Jest and adversarial controls passed; final verdicts await real composition proof |
| S3 | `5c7b42b3` unchanged | R2 bounded evidence accepted | R2 bounded evidence accepted | No gratuitous R3 rerun |
| S4 | `84471e99` / package `90883cad…f6a9a7` | [NOT CLEARED](s4-r3/a/revision-1/REPORT.md) | [CLEARED, bounded](s4-r3/b/revision-1/REPORT.md) | NOT CLEARED; two reproduced material session races routed to isolated successor |
| S5 | `9f38ab03` | Not dispatched | Not dispatched | Fixture/assertion source prepared; new live proof pending |
| S6 | Successor of `55db31a0`, not committed | Not dispatched | Not dispatched | SLOT E focused identity/cache tests authorized against fingerprinted dirty source; results pending |

## S4 disposition

S4-R3-A-01 is a demonstrated R3 coalescer regression during pending establishment; S4-R3-A-02 is cumulative obsolete-caller cleanup clearing an acknowledged replacement session, reproduced on R2 and R3. Both block the affected authentication and lane acceptance boundary. The original auth-body timeout repair and measured package/loader evidence are accepted but do not rebut these separate failures.

Audit A report SHA-256 `ba4eae3b7e688a8b8ffa2dc2ab71471b808ad875ae6c066151d184035629154a`; audit B `8ffb1bc2d639d95dd59ff4915718e9d93d5eaaa7d773e1da5f7f698927164dab`. Both packets, probes and baseline controls are preserved unchanged. Neither reviewer saw the current peer's conclusions before freezing.

B independently reproduced the same duplicate-refresh ordering as S4-R3B-01, but rated it nonmaterial based on low estimated customer reachability. Parent does not accept that waiver: same-token refresh reuse and replacement-session loss violate the owned authentication invariant, and A additionally reproduced the actual worker/router cleanup failure. Fail-closed behavior does not make a demonstrated material reliability/recovery defect acceptable under G11. The successor remains T4 because it changes auth ownership and destructive token cleanup; B's suggested T2 follow-up classification is not adopted. This disposition does not alter B's independent report.
