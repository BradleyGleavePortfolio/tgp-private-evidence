# controls-v6-gate — Tier 2 driver successor closing audit B T2-1 (+ optional T2-2), PREPARATION ONLY, not executed

New file `controls-v6-gate/ctl-teardown-gate.sh` (see SHA256SUMS.controls-v6-gate); diff vs v5 `4d09589c` = `controls-v5-to-v6-gate.diff` (43 lines, 12 added). v3/v5 packets, fake harness `2de5fe24…`, control jest config `a6eeb1cd…`, specs, product, patch unchanged. Static check only (`bash -n`).

Changes (all in the driver):
1. T2-1 — three named refusal-reason checks read from the Jest logs, each excluding `Exceeded timeout`:
   - `T1.refusal_reason`: `not_the_disposable_db` AND `toMatchObject` present → beforeAll failed at the identity gate (spec line 46), supported by fake harness `identity()` returning `database: 'not_the_disposable_db'` for scenario refused-identity.
   - `T2.refusal_reason`: `Received: "165"` AND `Expected: "164"` present, `not_the_disposable_db` absent → failed at `expect(appliedMigrations()).toBe('164')` (spec line 60) after the identity gates passed; supported by the fake `_prisma_migrations … finished_at` answer `'165'` for refused-prestate.
   - `T0.refusal_reason`: same identity pattern on the predecessor log, so T0's mutating teardown is attributed to a refused identity, not a timeout or harness exception.
2. T2-2 (optional, disclosed, one line): dirty-fingerprint gate against pinned `6850b32e…6aa0` next to the HEAD gate; refuses rc 2 before any child. Makes the driver self-attributing to the frozen dirty patch.
Everything else identical to v5: pinned-input hashes, dependency/identity gate, owned setsid Jest groups (90 s → TERM → 10 s → KILL), `Tn.owned` census checks, aggregate 380 s, first failed check stops with owned reap, root retained on survivors/`S5_CTL_KEEP=1`.

Expected positive: I0, T1.{zero_mutation,skipped_marker,jest_failed,refusal_reason,owned}, T2.{zero_mutation,skipped_marker,refusal_reason,owned}, T3.{setup_partial,teardown_ran,no_skip,owned}, T0.{defect,refusal_reason,owned}. Expected negative/failing behaviour asserted: T0 predecessor mutating teardown. Jest rc nonzero in all four by design. A hook timeout or harness exception would now fail the refusal_reason check and stop the driver (raw logs retained), instead of passing as before.

Launch only after: positive setup-v1 record (FINAL 0, identities OK) and B narrow-delta closure/separate grant:
`cd /home/user/workspace/execution/s5-r4 && mkdir -p control-results && S5_CTL_GRANT=granted-by-parent S5_CTL_KEEP=1 timeout --foreground -k 20 400 bash controls-v6-gate/ctl-teardown-gate.sh`
No lock, network, DB, npx, install, Prisma generate, hook, commit or real PG.
