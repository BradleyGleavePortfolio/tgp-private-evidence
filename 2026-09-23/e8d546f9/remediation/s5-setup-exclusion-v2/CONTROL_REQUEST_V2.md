# CONTROL REQUEST — OP88-S5-SETUP-EXCLUSION v2 private fake controls (NOT GRANTED; NOT EXECUTED)

Requested by the builder for parent decision **after two independent exact reviews** of this frozen packet (`SHA256SUMS.s5-setup-exclusion-v2`). Static expectation only; nothing here is evidence.

## Scope
- Runs `controls-exclusion/ctl-exclusion.v2.sh` (pins launcher v2 `b32cc20d…`; logs fake v2 and driver digests) against `controls-exclusion/fake-runner.v2.sh`. No npm, no canonical lock (`/home/user/workspace/execution/test-validation.lock`), no canonical EX (`/home/user/workspace/execution/s5-r4`); the launcher refuses canonical paths in private mode.
- Cases X1–X7, 11 checks, STOP on first failure. Expected static outcome: 11 PASS, `SUMMARY pass=11 fail=0`, no `UNRESOLVED` line.
- Proves launcher v2 behaviour on synthetic children only (including one runner-created setsid sub-session, X5). Does **not** prove canonical installation exclusion; canonical setup remains a separate grant with fresh prerequisites.

## Exact command (from the packet root, fresh resolved noncanonical output tree)
```
cd /home/user/workspace/execution/e8d546f9/s5-setup-exclusion-v2 && S5X_OUT=<fresh resolved noncanonical dir> S5_CTL_GRANT=granted-by-parent timeout --foreground -k 10 230 bash controls-exclusion/ctl-exclusion.v2.sh
```
`S5X_OUT` must be a fresh directory outside the packet if the packet is to stay byte-frozen (default `control-results/` would be created inside it). The grantor records the actual driver exit code.

## Boundedness statement (per review A)
The driver is bounded (≈110–130 s static estimate; outer 230 s). The launcher is detached (`setsid`, own session, no self-bound, as in canonical use). If any case leaves the holder in SELF-HOLD, the driver reports `UNRESOLVED launcher pid=… ex=… token in LEASE_HOLDER` and exits without killing it; the parent owns that holder's disposition (identity-checked; releases only after positively empty census and publishable RELEASE — there is no handoff path). Fixture children (`sleep`) are bounded (≤ 60 s) and are never pattern-killed.

## Side effects if granted
- Private lock/EX files under `S5X_OUT/<ts>/X1..X7` only; heartbeat log lines every 2 s while a case holds; no writes elsewhere.
- Directory obstacles created by X4/X6 are repaired by removing only the launcher's own `<name>.tmp.<pid>` deposits and the then-empty directories.

## Retain
Driver exit code, `ctl.log`, every `launcher.out`, `launcher.EXIT_RECORD`, `LEASE_HOLDER`, `LEASE_RELEASE`, `SELF_HOLD`, `attempts/*/IDENTITY|ADOPT`, `logs/setup-v1/*` (X5), `DESC_READY`/`SUB_READY`, and the digests logged at `CTL_START`.

## Not requested
Canonical launcher execution; any `npm ci`; any change to V10/V10.1/9-file packets; S2 changes.
