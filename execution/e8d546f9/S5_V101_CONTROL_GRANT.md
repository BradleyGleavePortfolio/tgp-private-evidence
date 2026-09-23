# S5 V10.1 single private diagnostic grant

Parent EXEC-e8d546f9, 2026-09-23. Individually T4: consequential ownership, cleanup and publication evidence. Sole executor `s2_v5_8_concrete_repair_mude34f9`, requested Claude Fable 5 / High, not observed runtime telemetry. This worker is not a V10.1 auditor and does not change its source.

## Closed prerequisites and exact binding

Both independent nonbuilder changed-candidate reviews are frozen: A manifest `a05b466f91c314b5fbeef81e91ba49a268a8f8d07d5d0638e9797123531ba3ca`; B manifest `f7965a774998fde888adb8f8fd1b42c5393bb62eba440584609e1752aacc3832`. Both source-close A01/A02/A03 and identify no introduced material defect for this private diagnostic.

Candidate root `/home/user/workspace/execution/e8d546f9/s5-v101`; `SHA256SUMS.s5-v101` must hash to `45accac93e91e7d46fe9a75c4460687fcb6d698336c57d61428b62f192cd5b89` and verify 24/24 before any launch. Candidate, prior packets and audits remain unchanged.

S4 Stage1 and S2 setup slots are closed with attributable clean accounting. This is the sole runtime slot on activation. Source-only work and read-only audits may continue.

## One authorized invocation

Preflight: unprivileged user (EUID not 0), non-job-control shell, required tools present, exact manifest/pins and fresh output path. Failure refuses launch. Set `S5_V10_OUT=/home/user/workspace/execution/e8d546f9/s5-v101-control-result/data`; no prior output may be overwritten or reused.

After verified `cd` to the exact candidate root, without ambient errexit:

```sh
S5_V10_OUT=/home/user/workspace/execution/e8d546f9/s5-v101-control-result/data S5_CTL_GRANT=granted-by-parent timeout --foreground -k 10 230 bash controls-v101-t0/ctl-own-launch.v101.sh
rc=$?
echo "ctl-own-launch.v101 rc=$rc"
exit "$rc"
```

Execute exactly once. Capture, report and return the actual status immediately. Retain the reviewed 190-second admission and external 230+10-second allowance; these are not successful-cleanup guarantees. No automatic retry, patched caller, reclassification or new harness.

## Sole writes and scope

All runtime results and executor evidence under `execution/e8d546f9/s5-v101-control-result/`. Preserve the entire `data` directory, including the driver log one level above its timestamped case directory. Source hashes and T0/setup text may be read by the reviewed driver; those consumers must not be executed.

Only exact reviewed primitive/fixture/driver-owned synthetic child actions are authorized. No ad hoc or pattern-based cleanup, canonical-lock acquisition, installation, network, DB, Jest, npm, worktree/product/source change, commit, T0, setup or S6 execution.

## Pass, stop and closure

PASS requires raw final 0; all 25 expected checks PASS with no FAIL; final `primary_rc=0`, `enclosure_reap_rc=0`, `unresolved=0`, `publication_failures=0`; and required IDENTITY/ADOPT/EXIT and per-case raw evidence retained where applicable. PASS count alone is insufficient.

Any nonzero, timeout, unresolved ownership, missing required evidence or unexpected result is STOP. Preserve all failures/partial outputs and return the exact evidence; do not retry or clear it yourself. No source repair is included.

Return exact command/start/end/raw exit, all predicates/status classes, process/ownership accounting and pre/post candidate manifest verification. Freeze the full result with a non-self-including manifest. Slot closure needs attributable outcome plus cleanup/retention accounting.

This proves only the reviewed synthetic-child diagnostic, not unknown-census runtime coverage, T0/setup/S6, installation, product or customer acceptance. Old V10 B remains incomplete; no clearance is inherited from it. Parent activation after publication is required.
