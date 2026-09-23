# S2-V61 — REPORT (T4 Fable sole writer, lane execution/e8d546f9/s2-v61; SOURCE-ONLY, additive)

Purpose: the smallest exact successor of the executed V59 driver (4341ce30…) that corrects the actual V59 control failure S2-V59-K3-PLACEMENT at K3 AND at its two same-class NOT-RUN sites K4 and N4b, as confirmed by both frozen result reviews (Result-A 96e4d876…, Result-B 41b5b5e0…) and permitted by the parent. V60 (2eb52088…, K3-only) stays frozen and immutable; it is provenance only — NOT to be executed or separately audited (its predicted K4 failure is known). One dual review is requested over `diffs/controls-driver-v59-to-v61.diff` (executed → candidate) with `diffs/controls-driver-v60-to-v61.diff` as exact V60→V61 provenance.

Mechanism: ONE driver-only helper pair `step40_arm`/`step40_wait` (the existing N5b seam-controller shape: controller-listed child, latch, runner pid from the runner's own stamp, CURRENT-enclosure validation, single TERM, timed-out wait sends nothing). Trigger = the runner's own step-40 evidence (adoption ack + harness workload line; K4 also the recorded escapee line). Enclosure bounds become fail-safes (12/25/12 s) so the outer status asserted is the runner's own 143 (as N5b). One stamp assertion added at K3 and K4. Declared maxima K3 18, K4 32, N4 40. Runner, stubs, pins, K1 mechanism, all other controls, budgets, selectors, loop, ownership/cleanup authority: unchanged (cmp/diff).

No runtime, probe, lock, network, install, worktree or product action was performed; syntax/hash/diff only. Builder identity: requested Fable/High per scope; runtime model identity is not observable. Builder output is not audit.

## Packet
| File | Note |
|---|---|
| controls-proposed/run-controls-v61.sh (567 lines) | see FINDINGS_MAP_V61.md §2 |
| run-composition-r57-v5.7-when-granted.sh | efa273c7de7d4bcc34b6f5be0fae74e412d73a5e82fc9e504a0e2a4c10367e1c, byte-identical V57=V58=V59=V60=V61 |
| controls-proposed/stubs/*, SHA256SUMS.stubs, k1-predecessor-mechanism.sh | byte-identical to V59/V60 |
| CONTROL_REQUEST_20.md | continuation `k new1 new2 neg neg2`; explicit applicability table (which shared paths changed; no concrete invalidation of P1/W1/C1; K1/K2 inseparable ≈8 s); V61 write set; signal scope |
| PROOF_REQUEST_21.md | paths; prerequisite = CONTROL_REQUEST_20 green + two reviews; R59-01 disclosure carried; bound qualification retained |
| FINDINGS_MAP_V61.md | causal boundary, change table, necessity of 124→143, budgets + residual K6 gate risk, map to Result-A/Result-B items |
| diffs/ (6) | v59→v61, v60→v61 driver; 16→20, 18→20 request; 17→21, 19→21 proof |
| inputs/INPUT_HASHES.txt (97), inputs/K2_K3_STEP_TIMING.txt | exact inputs |

## Implemented / tested / unrun
IMPLEMENTED: the above. TESTED at runtime: **none**. Static: `bash -n` (driver, stubs, K1, runner, embedded bodies, controller body); predicate strings cross-checked against the actual K2/K3 outputs and stub/runner producers. UNRUN: every discriminator (K3 corrected, K4–K6, new1, new2, neg, neg2).

## Known residual (reported, not patched)
Set `k` budget is tight if K4's runner reap consumes its full 10+5 s (K6 `need` gate margin ≈1 s → truthful raw 3, not a false PASS). Changing set budgets would alter the frozen loop; not done without instruction.

## One smallest next action
Dual exact review of V59→V61 (+V60→V61 provenance); then grant CONTROL_REQUEST_20 (continuation, no runtime granted here). No product/release clearance is asserted.
