# S5 V2 diagnostic stop and accountable recovery

Parent EXEC-e8d546f9, 2026-09-23. The one private V2 diagnostic FAILED: actual driver exit 1, SUMMARY pass=8 fail=1, stopped at X6.normal_release_failure_holds. X6.release_after_exact_repair and X7 remain NOT RUN. There is no canonical setup/T0, V31, S6 or product clearance.

## Evidence identity

Initial result inventory `3c3fc4e2340c445d958a82c4472cc458dc5cd4acc898f046d56e0d805637eb06` is preserved unchanged. It recorded a point-in-time view while a holder was still alive; it is not a successful immutable snapshot of all live originals. Three entries subsequently differ: heartbeat-updated LEASE_HOLDER, appended launcher.EXIT_RECORD and the exactly removed fixture deposit. Immutable pre-recovery copies and timestamps remain separate.

Recovery grant `1c54c032204b428bc8c3f4f8fc774a51aa85afcfb8dd2fc53546256f8b880de6` was explicitly delivered before the repair but was not yet committed in the private repository at execution time. This publication records that chronology, not a fictional earlier commit. Post-recovery evidence manifest `0125215960b29e368a61ea7e58a0bda09a7db3402c60d93a4b83fed778605075` binds 20 entries and the now-quiescent final X6 records.

## Recovery and resource disposition

At 02:16:20 UTC, executor revalidated 17 exact guards for PID26214/start519891/SID26214/EUID2000/token20260923T020634Z-26214-18852, fd9 to this case's private lock, and empty workload session26278. The only obstacle was the real directory LEASE_RELEASE containing the known regular deposit LEASE_RELEASE.tmp.26214.

At 02:16:21 UTC the executor removed only that deposit and the empty directory on attempt 1/5, with no chmod, signal, handoff, lock probe or source change. The holder's existing retry published LEASE_RELEASED and state RELEASED, then the process disappeared. Both holder and workload sessions were empty. The readable-process fd census found no links to this private lock; 63 unreadable processes remain a visibility qualification, not a global lock-free assertion.

The launcher's `final_rc=90` is a recorded intended exit plus process disappearance, not a wait-observed 90: the original parent driver had already exited. Driver raw1 remains the actual execution result. Parent independently observed the holder absent and both exact sessions empty at 02:18:04 UTC, verified the recovery manifest, and ACCEPTS this known private slot's accountable closure.

## Next scope

Independent nonbuilder result reviews will assess exact failed-check attribution, preserved passes and recovery evidence without another run. The old conjunction did not record which operand failed; log-before-holder-publication sequencing alone must not be inflated into an observed operand value. No old V2 packet edit, repeat, resumed check or retrospective PASS.

The disjoint S2 V61 continuation may be activated under its already dual-cleared, separate grant after publication. S5 V31 source and final-control review continue independently; a new control packet corrects the concretely identified P2 acknowledgement ordering without modifying this failed V2 execution.
