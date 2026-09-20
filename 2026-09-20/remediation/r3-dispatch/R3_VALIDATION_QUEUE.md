# R3 validation scheduling

Parent owns scheduling. All moderate/heavy commands require an explicit slot and nonblocking `execution/test-validation.lock`. Source edits and bounded cheap offline checks may proceed in isolated lanes.

## Current slot

S6 combined R2 head `55db31a0`: final two cold exports completing after successful natural-exit full suite. Owner `s6_mobile_fixer_muabkqbw`. R3 workers must not overlap.

## Awaiting specific execution requests

- S1 `s1_r3_safety_fixer_muaeeplu`: offline guard negative tests before any DB connection; parent review of boundary before synthetic DB slot.
- S2 `s2_r3_delivery_fixer_muaeepli`: adversarial workflow/discovery controls and real shell/action lint; coordinate expected verifier interface with S1.
- S4 `s4_r3_auth_fixer_muaeepla`: focused stalled-body/recovery tests, then final gates/package/loader.
- S5 `s5_r3_validation_fixer_muaeeplq`: fixture recreation and targeted terminal/race assertions; no duplicate accepted broad run merely for replay; synthetic execution after safety review.
- S6 R3 `s6_export_blocker_fixer_muad8hz5`: cache/identity composition negative control and focused checks; final full suite and export applicability after stable auth repair.

This is not a FIFO blocking lock. Parent orders ready requests by dependency and risk, permits one heavy owner, and updates on actual acquisition/release. No hosted or customer execution is in this queue.
