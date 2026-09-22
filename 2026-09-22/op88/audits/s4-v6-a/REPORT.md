# OP88-S4-V6-A — audit evidence index

**Stage 1: HOLD two concrete next-proof defects. Stage 2: HOLD, not applicable yet.** The authoritative machine-readable audit contains the mechanisms, supported-path counterexamples, exact line references and smallest corrections. [Findings](FINDINGS.json)

1. **S4-V6-A-01:** Both census functions read `PIPESTATUS` in the outer shell after an assignment, not inside the `timeout pgrep | tr` command substitution; ordinary no-match becomes MEMBERS with empty output, as does a timeout when `tr` succeeds. [Launcher census](../../s4-v6/launcher/s4-r6-launch-v6.sh#L102-L110) [Driver census](../../s4-v6/controls/run-controls-v6.sh#L108-L114)
2. **S4-V6-A-02:** `local d=$1 f=$d/QUARANTINE_LEASE_HOLDER` expands an unset outer `d` at the ordinary top-level holder lookup under `set -u`, so a valid holder is treated as absent before recovery. [Reader](../../s4-v6/controls/run-controls-v6.sh#L117-L130) [Call/recovery gate](../../s4-v6/controls/run-controls-v6.sh#L247-L266)

The V5 current-run binding, once-budgeted cancellation, receipt-failure retention and successful-path terminal-receipt changes are source-closed for their named counterexamples; the census correction is not closed, and private recovery is blocked by the dependent-local regression. [Closure ledger](FINDINGS.json#L28-L64)

The four faults reach real launcher branches, but the UNKNOWN seam overwrites the state after defective raw-status capture and cannot certify that capture; all fault selectors remain CONTROL-gated and inert for native VALIDATION. [Seams](../../s4-v6/launcher/s4-r6-launch-v6.sh#L96-L110) [Holder seam](../../s4-v6/launcher/s4-r6-launch-v6.sh#L140-L151) [Receipt seam](../../s4-v6/launcher/s4-r6-launch-v6.sh#L283-L295)

The owner's 22:03 course correction is applied: no blanket standby-loss/SELF-HOLD coverage gate or new harness is demanded; the two concrete defects alone block the next proof. [Updated recovery ruling](../../S4_V6_RECOVERY_RULING.md#L11-L25)

Inputs, full packet hashes and independent diff/manifest checks are recorded separately; V6 remained `8b04adaf7d4f0a511ee68e960d880e0ec386187335b7da9fde9c44c1c74a050b`, 12/12 verified, and the supplied V5→V6 diff reproduced byte-for-byte. [Exact inputs](INPUTS.json)

No candidate execution, probes, syntax checks, lock operations, network, source edits, current S4 peer access or product/runtime acceptance. Sole audit writes are in this directory. A briefly routed S2 assignment caused read-only intake, then was withdrawn; **no S2 writes occurred**.

Freeze clock observation: `2026-09-22T22:09:35Z`; runtime model/settings unexposed.
