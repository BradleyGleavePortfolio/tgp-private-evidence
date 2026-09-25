# S9-B PG proof binding — DRAFT v1 (source-only; nothing here has been executed, granted or locked)

Derived by literal substitution from the accepted S8-C binding `execution/64e33dc7/s8c/binding/` (unfilled template
`s8c-pg-proof.sh.unfilled` + `s8c-fixture.sh`, both unchanged there). Deltas are the EXEC-1910A060 lane constants and
the S9-B proof target; the doctrine (single canonical nonblocking `flock -n` on fd 9 of
`execution/test-validation.lock`, once-only sentinel, first-nonzero-stops, bounded stages, data dir retained,
destroy = separate marker-gated grant) is inherited verbatim.

Files
- `s9b-pg-proof.sh` — the complete one-run orchestration for `test/rls-g2-s9.spec.ts` via the repo jest +
  `jest.rls.config.js` (`--runInBand --ci`, exactly once). Refuses while ANY pin is unfilled (head pins, lane `PORT`,
  `RUNTIME_ROOT`, tool pins). Adds to the S8-C preconditions: accepted-path blobs at 1c5fbb04 unchanged (prisma tree,
  jest.rls config, `src/scout/reconstruct`, `src/scout/lifecycle`, `scout-reconstruct.service.ts`, all seven S8-C proof
  files), the four frozen S9-A files present exactly as frozen, the S9-B facts files present, no native sidecar.
  Identity stage asserts cluster `s9-disposable-pg17`, marker
  `s9-g2-reconciliation-facts-synthetic-disposable-fixture-safe-to-drop`, 172 applied migrations, 17.6 (170006).
  Outer bound: `timeout -k 30 3900`.
- `s9b-fixture.sh` — lock-free lane helper (`init|start|stop|status|destroy`); refuses standalone use unless
  `S9B_RUNNER_PID` is a live `s9b-pg-proof.sh`; refuses while `PORT` is unfilled; data/socket under
  `$RUNTIME_ROOT/clusters/s9-b` and `$RUNTIME_ROOT/run/s9-b`.
- `PINS.txt` — all pins. Filled now (read-only, from the standalone clone at 1c5fbb04): base head/tree, schema and
  package-lock sha256, accepted-path blobs, frozen S9-A blobs. Unfilled: nine head-derived pins, `PORT`,
  `RUNTIME_ROOT`, seven tool pins (to be filled from the 1c5fbb04 runtime setup receipt, never copied blindly from
  the 64e33dc7 record, which is listed for comparison only).

Order: runtime setup for 1c5fbb04 → parent fixes the lane port (55645 suggested; `g2-s9-db.ts` refuses 55642/55643 and
all earlier lane ports) → S9-A composition → S9-B source gates → hooked Bradley commit → export → fill pins from the
committed head → dual attestation → separate parent-granted single real-PG proof → this runner once. No initdb, server,
bootstrap, migration, PG test or lock acquisition before that grant.
