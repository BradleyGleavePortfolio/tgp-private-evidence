# S5-TIER2-V6-NARROW-CLOSURE B — addendum 1: Tier-2 driver v6 `b7207f46` (delta review; nothing executed)

Reviewer B (`s4_r6_independent_audit_b_muc70jfl`; API-hosted AI subagent, model not exposed). Read-only: `sha256sum`, `diff`, `git show`/grep on the s5-r4 worktree. No execution, syntax checks or probes. Root `REPORT.md`/`SUMMARY.json` in this directory unchanged. Source closure, not a grant.

## Inputs (re-hashed)
| File | SHA256 |
|---|---|
| `s5-r4/controls-v6-gate/ctl-teardown-gate.sh` (target) | `b7207f46a69eaa8fe984d7bc61a6c666ea568367a0a45104d47d8eb5abdad7c3` |
| `s5-r4/controls-v5-gate/ctl-teardown-gate.sh` (predecessor, reviewed in root report) | `4d09589c34281975868631c5d2e4f90dd0b3a84ecce3a963226b5be45975c5f6` |
| `s5-r4/controls-v5-to-v6-gate.diff` (43 lines, 12 `+`) | `3efdb856ea5fa4782f4ea10abab8e9c433ebf4463bcaeb3d83a053eb6b92f466` |
| `s5-r4/TIER2_GATE_REQUEST_V6.md` | `cc6b14be9fc5a7c2479adde8883643399bf0afaa7d034e2499d07aff2e684357` |
| `s5-r4/controls-v6-gate/SHA256SUMS.controls-v6-gate` (3 entries, verify 3/3 from `controls-v6-gate/`) | `2dc9d9ab120ef312055c8305cc576d2e67240b897ff8bb454a5b1a1bb7e77208` |
Fake harness `2de5fe24…`, control config `a6eeb1cd…`, `controls-v3/lib.sh` `a08b762b…`, specs and dirty patch unchanged (pins in the driver unchanged; files re-hashed in the root report).

## Delta check
My `diff -u` of v5 → v6 is byte-identical to the declared patch. All 12 added lines: header comments (L2–7), `PIN_DIRTY_FINGERPRINT` (L23), fingerprint gate (L28), `T1.refusal_reason` (L73), `T2.refusal_reason` (L77), `T0.refusal_reason` (L84). No removed or altered lines: gates, owned `setsid` groups, 90/10 budgets, `Tn.owned` census, 380 s aggregate, first-failure stop, EXIT-trap reap and root retention are the v5 bytes.

## T2-1 — CLOSED (L73, L77, L84)
- **T1 (L73):** log contains `not_the_disposable_db` and `toMatchObject`, and not `Exceeded timeout`. `not_the_disposable_db` is the fake `identity()` value for refused-identity and appears in the Jest log only inside the received diff of the failing `expect(identity).toMatchObject(...)` (spec L46) — it is not in the spec text, and `console.warn('PG17_DATABASE', …)` is after that expect, so it cannot be printed on any other path. A hook timeout, compile failure or harness exception before/after that point does not produce it.
- **T2 (L77):** `Received: "165"` and `Expected: "164"` present (Jest `toBe` output for `expect(appliedMigrations()).toBe('164')`, spec L60, fake returns `'165'` for refused-prestate), `not_the_disposable_db` absent (identity gate passed), no `Exceeded timeout`. Together with v5's `_prisma_migrations` record predicate this pins the refusal to the pre-state gate.
- **T0 (L84):** same identity pattern on the predecessor log; the HEAD spec (`git show 143d451e:…`) contains the identical identity `toMatchObject`, so the anchor applies. The mutating teardown asserted by `T0.defect` is thereby attributed to a refused identity, not to a timeout or harness exception.
Each check runs through lib `check` → first failure stops the driver with owned reap and retained root. Predicates are named, read from the Jest log the driver already writes, add no framework, and match the closure I specified.

## T2-2 — CLOSED (optional, L23/L28)
Dirty-fingerprint gate uses the same formula as the setup runner and `RECREATE.md` (`git diff HEAD` + porcelain incl. untracked → sha256) against `6850b32e…6aa0`, placed with the rc-2 gates before any child. Reproduces on the worktree now. The driver is self-attributing to the frozen dirty patch.

## Verdict
Tier-2 driver v6 `b7207f46`: **no remaining findings from the root report**; source-grantable. Execute only after a positive setup `74736a58` record (`FINAL rc=0`, identities OK) and a separate parent grant, with the stated invocation (`S5_CTL_GRANT=granted-by-parent S5_CTL_KEEP=1 timeout --foreground -k 20 400 …`). Positive = I0; T1.{zero_mutation,skipped_marker,jest_failed,refusal_reason,owned}; T2.{zero_mutation,skipped_marker,refusal_reason,owned}; T3.{setup_partial,teardown_ran,no_skip,owned}; T0.{defect,refusal_reason,owned}; Jest rc nonzero in all four by design. A positive run proves real jest-circus hook semantics on the real spec text under a fake harness only — not DB behaviour, the live run, hooks/formatter, or the final S5 commit.
