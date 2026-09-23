# B61-01 grant-delta note (lane B, additive; S2_V61_REVIEW_B.md 7cdaca12… / MANIFEST 3e2b7744… stay immutable)

Object: parent grant superseding ONE associative-array value of the frozen CONTROL_REQUEST_20 loop (L28): `[k]=60` → `[k]=120` through the existing `CTL_BUDGET` input; other sets 60/60/90/150 unchanged; driver 42d9362b… (lane ed241342…) unchanged. Source read only (driver `grep BUDGET`); nothing executed.

## Applicability of the remedy — CONFIRMED, bounded
Every use of `BUDGET` in the V61 driver (D106 input; D115 watchdog schedule; D120 `left`; D239/242 aggregate-deadline check; D251 `need` gate; D253 `clip`; D220/240/291 receipt/banner recording; D466/480/481 W1/C1 bodies — not in set `k`). Nested child drivers set their own budgets explicitly (D435 20, D442 30, D449 9, D542 20, D552 20, D560 20), so the caller value reaches ONLY the top-level `k` invocation.

## Semantic implications (all bounded; none touches authority)
1. `need` gates: K6 `need 10` now passes for any start t ≤ 102 s; declared sum 98 + reserve 8 = 106 ≤ 120 → 14 s bookkeeping headroom (parent arithmetic confirmed). Truthful raw 3 remains possible only under a gross anomaly.
2. `clip` (D253: bound → min(bound, left−8−KA)): at 60 s the late controls would have run under SHORTER outer TERM bounds than declared (projection: K5 `15` clipped to ≈14 at t≈33; K6 `10` clipped to ≈8 at t≈39). At 120 s no clipping occurs, so K5/K6 (and K4's 25 s fail-safe) run under exactly their declared bounds — a more faithful, not weaker, application; no expected outcome change (K5 ≈5.5 s, K6 ≈1 s).
3. Watchdog schedule (D115): TERM/KILL/cancel at 112/116/118 s instead of 52/56/58 s. Later last-resort cap, still finite; target selection unchanged (`$CURF` only). Aggregate deadline check (D239/242) now 120 s.
4. Ownership, controller/enclosure authority, ONE-STRIKE, publication, result format, signal scope: no dependence on `BUDGET` — unchanged.
5. Evidence self-describes the value: banner `budget=120s` (D291) and receipt `wall=… of 120s` (D240) will differ from CONTROL_REQUEST_20 L28; result reviewers must compare the caller against the GRANT (one-value supersession), not the request bytes. Recommend the executor's `caller.sh` reproduce L28 verbatim except that token, and the grant file record the token.
6. Safety cap, not completion guarantee; no auto-rerun — consistent with B61-01 as written.

Verdict: the one-value grant delta is an exact, bounded, semantically benign application of an existing documented input; no driver, framework, authority or predicate change; CONTROL_REQUEST_20 grantability (static) unchanged. Runtime still unrun.
