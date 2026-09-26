# S11-D real-PG proof v1 — FAILED (preserved unchanged) — EXEC-FA72EFB2
Run s11d/binding/v1/run, candidate 38d0d366 on 54be96f1, LAUNCH 19:04:13Z, END rc=1 stage=jest-full 19:08:35Z; teardown clean;
lane logs archived to run/post-teardown; clusters/s11 removed. Guard stage not reached.
Result: journey-full 4 passed / 2 failed. J20 (4 checks) PASSED live: pins real, full-range src coverage, no slug in any S11 src
hunk, s10-core-diff-gate PASS at its pinned B/HEAD.
- J19 leg A FAILED at journey-full.pg.spec.ts:270 `expect(redrive.pushes).toBe(1)` — received 0 (the re-drive after the J12
  interrupt pushed nothing where the spec expected one push).
- J19 leg B FAILED at :157 via :376 — `report.coverage` undefined (the spec reads the settled-basis report under a shape the code
  does not produce).
Classification: B (candidate spec defects; the T2 spec was never run live before the proof; no src change in S11-D, so no product
finding is implied yet — the diagnosis must show which assumption is wrong against the landed S11-B settle-redrive spec and D2
case (h), which pass live). CONCRETE HARM: J19 unproven. EXACT DECISION BLOCKED: landing S11-D (#565) and the stacked S8-D doc
(#566). MINIMUM CLOSURE: diagnose both against passing live specs, fix the spec only, new commit (r3), independent delta review,
binding v2, one new run. These bytes are not rerun. EXECUTION UNLOCKED: S11-D landing.
