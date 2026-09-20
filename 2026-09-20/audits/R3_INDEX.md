# TGP R3 independent audit index

Observed 2026-09-20 23:14 UTC. Reports are frozen independent opinions; parent disposition is consequence-based, not a vote. No release or customer acceptance follows from a lane verdict.

| Lane | Frozen candidate | Audit A | Audit B | Parent status |
|---|---|---|---|---|
| S1 | `7cbbb039` | Not dispatched | Not dispatched | Offline guard passed; local DB proof pending |
| S2 | `1c6db2b6` | Not dispatched | Not dispatched | Offline controls passed; Jest/composition pending |
| S3 | `5c7b42b3` unchanged | R2 bounded evidence accepted | R2 bounded evidence accepted | No gratuitous R3 rerun |
| S4 | `84471e99` / package `90883cad…f6a9a7` | [NOT CLEARED](s4-r3/a/revision-1/REPORT.md) | Independent review active | NOT CLEARED; two reproduced material session races routed to isolated successor |
| S5 | `9f38ab03` | Not dispatched | Not dispatched | Fixture/assertion source prepared; new live proof pending |
| S6 | Successor of `55db31a0`, not committed | Not dispatched | Not dispatched | Source repair and consumer-safety follow-ups; meaningful tests pending |

## S4 disposition

S4-R3-A-01 is a demonstrated R3 coalescer regression during pending establishment; S4-R3-A-02 is cumulative obsolete-caller cleanup clearing an acknowledged replacement session, reproduced on R2 and R3. Both block the affected authentication and lane acceptance boundary. The original auth-body timeout repair and measured package/loader evidence are accepted but do not rebut these separate failures.

Audit A report SHA-256 `ba4eae3b7e688a8b8ffa2dc2ab71471b808ad875ae6c066151d184035629154a`. Its probes and baseline controls are preserved beside the report. Audit B has not been shown Audit A's conclusions; successor repair does not alter the candidate B is reviewing.
