# Additive builder note — timer creation times vs. test timeline (inference aid for the result review; receipt unchanged)

Derived only from the frozen `c5v3.C.inventory.jsonl` (`globalTeardown` snapshot time minus each timer's `ageMs`) and the per-test durations in `c5v3.C.jest.log`. Test-boundary times are reconstructed by summing reported durations from Jest start and are approximate (±0.3 s; Jest overhead between tests not reported). No execution, no product code read beyond what the receipt already cites.

| Timer id | Created (UTC) | Library path | Where it falls in the run (approximate) |
|---|---|---|---|
| 4812 | 05:49:26.665 | F `fetch().finally → scheduleGc` | end of **T0** (T0 ≈ 22.5–26.6 s): the in-flight `me` fetch cancelled by a `clear()` at T0 teardown — either the test body's own `clear()`/`signOut` or the `afterEach` `clear()` |
| 6020 | 05:49:31.253 | R `removeObserver → scheduleGc` | end of **T3** ("cache update landing during signOut", T3 ≈ 29.0–31.3 s) |
| 6146 | 05:49:31.285 | F | end of **T3**, 32 ms after 6020 |
| 6564 | 05:49:33.527 | R | **inside T4** ("normal signOut leaves nothing to restore", T4 ≈ 31.3–35.1 s), ~2.2 s after T4 start — not at a hook boundary; consistent with the production `signOut()` → `authActions.ts:352 queryClient.clear()` executing while the adapter's screen is still mounted |
| 6800 | 05:49:35.102 | F | **1 ms before `sandbox-afterAll` (05:49:35.103)** — i.e. during the file's `afterAll` `clear()`/`unmount()` (which ran just before the preload's `afterAll`): a fetch still in flight at the very end of T4 |

Reading (builder inference, for B to confirm or refute from the same files): three timers (6020, 6146, 6800) sit at hook boundaries (test-teardown `clear()` after `cleanup()`), one (4812) is at a T0 boundary where either the scenario's `signOut` or the hook could be the caller, and one (6564) is mid-test where only the scenario's production `signOut()` calls `clear()`. Which `clear()` call triggered which timer cannot be proven from stacks alone (all creation stacks are library-only promise continuations) — this table is a timing correlation, not a causal trace. The resource owner statement in `C5_CAUSAL_RECEIPT.md` §3 (orphan gc timers of destroyed production-singleton Queries) does not depend on this assignment.

Why the hazard file's existing teardown cannot reach them: `queryClient.clear()` and `queryClient.unmount()` only touch Queries *currently in the cache*; the five Queries were already removed by an earlier `clear()` and are referenced only by their own timer closure. Any teardown fix therefore has to prevent the re-arm (settle/cancel in-flight fetches and unmount observers **before** the `clear()` that destroys them), not clean up afterwards. For orphans created *inside* a scenario by production `signOut()` (6564), a hook-level `cancelQueries()` runs too late by construction — this is the point the parent asked B to assess, and it is left open here.
