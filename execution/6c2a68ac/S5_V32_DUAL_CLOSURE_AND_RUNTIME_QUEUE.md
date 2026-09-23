# S5 V32 dual closure and private-proof queue

Parent EXEC-6c2a68ac, 2026-09-23. T4 individual/cumulative disposition. This is not an independent audit and does not itself activate runtime while S2 owns the single runtime slot.

## Exact candidate and attestations

Frozen V32 top seal `1f23abdcf2ca328f23371fa6018ceb1753553e8e21c65e8765881f814d0e0691`, source seal `addc713d7297796cc98fccfb7c05bde770bedf341322a17a38850ed0cd25adba`, controls seal `b99771a79d80e768a710475cd772e0fd1ccc37ca504fbfc723acabed039f036e`.

- Independent A seal `9bbb8a268efa32050e6cbdc97fcbd96b27cd93b1bab8b7864b90f33a821778b5`: source CLOSED, one private proof grantable, no A/B blocker; post-evaluation diagnostic qualification is C.
- Independent B seal `5a85d3e13729da62efff3790a746ebea2c6987e38726f5c16c3400518471b6af`: source CLOSED, one private proof grantable as-is, no A/B blocker; current peer output not used as evidence.

Both independently verify launcher `55acc00f`, real runner `61b565e4`, driver `4323dc41`, fake `045d5284`, unchanged primitive `4aebf96f`, ten unchanged predecessor assertions plus exactly one finding-specific P3c negative. The prior exact-attempt and P1 acknowledgement class B findings are CLOSED. No majority waiver is involved because neither review reports a concrete A/B finding.

Class C qualifications are recorded and nonblocking: PGID mismatch would fail closed and P3b observes it; negligible token-collision residual; wall-clock step-back produces false FAIL only; FAIL diagnostics are post-evaluation snapshots; fake hash is sealed but not driver-pinned. Historical V2 remains failed at X6 with unknown failed operand and no rerun.

## Purchased decision

The exact `S5_V32_PRIVATE_CONTROLS_GRANT.md` is now technically cleared for one run. Runtime is QUEUED, not active, because the already-activated S2 real composition proof exclusively owns the shared runtime slot. Immediately after S2 returns ownership and the parent evaluates no surviving conflict, activate the exact private command once.

No new audit, source change, framework or preliminary control is authorized. A failure stops and preserves evidence; success requires raw0 and actual 11/11. This proof then unlocks the separate canonical S5 setup/T0 and narrow S6 two-consumer successor; it does not itself clear either boundary or the product.
