# Bounded dev loop (parent disposition 2026-09-25 15:09 PT) — targeted suites only, under the canonical slot

Slot: `dev-loop/hold-slot.sh` polled `flock -n` on inode 667698 (never stealing); HELD 22:09:46Z (waited 0 s — the S9-A composition had released), RELEASED by TERM at 2026-09-25T22:10:37Z (`dev-loop/HELD`, `dev-loop/RELEASED`, `dev-loop/hold.out`). Held ≈1 min of the ≤20 min bound.

| Iteration | Command (clone, attempt-1 node_modules) | Result | Fix |
|---|---|---|---|
| 1 | `jest --ci test/scout/orchestration test/scout/g2-s8g-db-guard.spec.ts` (`dev-loop/iter-1.jest.log`) | **rc 0 — 4 suites / 85 tests passed** (family-plan, reconstruct-run incl. all its cases after FIX-2, settle-hook, g2-s8g-db-guard) | none needed |

No test/fixture edits were made in the loop (0 of 3 iterations consumed by fixes); no product src change, no assertion weakening, no changed acceptance expectation, no skip/only. Working tree identical to `attempt-3/PREFORMAT.sha256` (verified), so the attempt-3 freeze stands. Attempt 3 launched next per disposition.

## Disclosure — slot NOT actually held during iteration 1
`hold.out` shows the holder received SIGTERM and RELEASED at 22:09:52Z — 6 s after HELD — because it was started as a plain
`nohup … &` inside a tool shell whose process group was terminated when that shell call returned (the gate drivers survive
this because `timeout` re-groups its child; the holder had no `timeout` wrapper). The iteration-1 jest run (started ≈22:09:58Z,
10.8 s) therefore executed WITHOUT the canonical lock held. No other holder was observed before or after (`lslocks` 0), no
state other than jest's own cache was written, and no edits resulted — but the run does not satisfy the "under the canonical
lock" condition of the disposition and is reported as such. Attempt 3 (launched with the proven `nohup timeout … &` pattern)
re-runs the same four suites under the lock before the full suite, so the targeted result is re-established slot-compliantly.

## Iteration 2 (review-B B2 / C1 fold-in, parent mail 15:11 PT) — test-util change, slot HELD throughout
Reason: 55643 is the retained S8-F lane; the committed harness must refuse it and the suggested S8-G lane port becomes 55644.
Attempt 3 was deliberately stopped by the builder during full jest, before its commit (`attempt-3/ABORTED`; targeted 85/85 had passed; not a gate failure) so this change lands in the single hooked commit.
Diff: `dev-loop/iter-2.diff` (67 changed lines, two files): `test/utils/g2-s8g-db.ts` — add `'55643'` to `REFUSED_PORTS`, comment updated (55643 = retained S8-F lane, 55644 suggested); `test/scout/g2-s8g-db-guard.spec.ts` — fixture `base`/`ack`/expected `port`/maintenance URL/password URLs move 55643→55644, a new refused case `base.replace('55644','55643')`, the port-mismatched-ack case becomes `:55643`, foreign-database ack cases use `:55644`. No product src change, no assertion weakened (one refused-port assertion ADDED), no acceptance expectation changed, no skip/only, no banned tokens.
Slot: `dev-loop/hold-slot-2.sh` (timeout-wrapped) HELD 22:14:25Z (waited 0 s) → RELEASED 2026-09-25T22:15:22Z; `lslocks` showed the holder before and after the run.
Run: `jest --ci test/scout/orchestration test/scout/g2-s8g-db-guard.spec.ts` (`dev-loop/iter-2.jest.log`) → **rc 0, 4 suites / 86 tests passed**.
Iterations consumed: 2 of 3 (iteration 1 = no-op verification, iteration 2 = this fold-in). Attempt 4 launched next on this tree.
