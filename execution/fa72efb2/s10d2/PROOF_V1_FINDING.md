# S10-D D2 real-PG proof v1 — FAILED (preserved unchanged) — EXEC-FA72EFB2

Run: binding/v1/run (RECEIPTS.sha256 verified), candidate 144269d1 on 7fdcbc04, STARTED 16:04Z, END rc=1 stage=jest 16:05:29Z,
cleanup OK (postgres_procs=0, port free). Bootstrap + identity OK (173 migrations, S10-B harness).
Result: s10-unseen.pg.spec.ts 4 passed / 4 failed:
- FAIL R39 (a) SET.base → expected complete, got partial (spec L294)
- FAIL R41 replay → expected complete, got partial (L316) [same root as (a)]
- FAIL R39 (e) expected reason coverage_basis_unknown, got unresolved_identities (L341)
- FAIL R39 (f) expected coverage_basis_unknown, got unresolved_identities (L348)
- PASS (b), (c), (d), R27 live.
Server log: the reconstruct pass reconstructed every staged row (clients 2/2, u10-routines 1/1, u10-sessions 1/1, failed 0,
unmapped_families []), yet reconcile returns partial/unresolved_identities for the base set.

Classification: B (candidate result, not binding/harness: the four passing cases prove the lane, bootstrap, attested head
and service wiring). CONCRETE HARM: D2's claim "new source → core diff = 0 → complete" is not demonstrated live; landing
would assert an unproven north-star property. EXACT DECISION BLOCKED: landing D2 (#561). MINIMUM CLOSURE: root-cause why
the live reconcile finds unresolved identities for SET.base when every row reconstructed (asset mapping/identity keys vs
fixture staging vs spec expectation), fix within D2-owned paths (0 TS prod LOC) or, if impossible, record a product finding
(core change needed → violates CORE DIFF = 0 → decision). Then a new candidate head, delta review, new binding version,
one new run. These bytes are not rerun. EXECUTION UNLOCKED: D2 landing.

Receipt note (C, all three runners in this execution): RECEIPTS.sha256 is written before the final `END rc=…` line is
appended to the main log (template order, e.g. d2-pg-proof.sh L366 vs L368), so `sha256sum -c` reports the main log as
changed; every other receipt verifies. Not tampering; recorded, no action.
