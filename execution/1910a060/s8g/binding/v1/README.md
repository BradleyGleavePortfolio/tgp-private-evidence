# S8-G PG proof binding v1 (source-only; NOTHING here has been executed; NOT granted)

Derived by substitution from the accepted S8-C binding `execution/64e33dc7/s8c/binding/v3/{s8c-pg-proof.sh,s8c-fixture.sh}`
for the S8-G lane of execution 1910a060: runtime root `execution/1910a060/runtime` (RT-NEW-1 receipt), base
`1c5fbb0441178e0cfe6e9f8d72e955c645c265e9`, clone `worktrees/1910a060-s8g`, identity `g2_s8g_disposable` / `s8g_super` /
`s8g-disposable-pg17` / port 55643 (operator-chosen), 172 migrations, no OLD side, spec `test/rls-g2-s8g.spec.ts` run
exactly once via `jest.rls.config.js`.

Files
- `s8g-pg-proof.sh.unfilled` — one-run orchestration (canonical `flock -n` on inode 667698 fd 9, once-only sentinel, pins,
  fresh-lane preflight, init → start → bootstrap → identity (172 applied migrations, markers) → jest once → bounded stop →
  post checks → receipts). Nine `__FILL_AFTER_ATTESTATION__` pins; refuses to run while unfilled. `bash -n` OK.
- `s8g-fixture.sh` — lock-free lane helper (`init|start|stop|status|destroy`), refuses standalone use unless
  `S8G_RUNNER_PID` is a live runner. `bash -n` OK.
- `PINS.txt.unfilled` — all pins; accepted-file blobs at 1c5fbb04 computed read-only now; runtime/tool pins copied from
  RUNTIME_SETUP_RECEIPT.md (postgres, node_modules lock, generated client re-measured read-only here and equal).

Dependency assumption: the S8-C pattern requires an ISOLATED real copy of donor `node_modules` inside `W`. The 1910a060
donor is `worktrees/1910a060-s8f/node_modules` (client generated from schema blob 2e328bbc, identical to 1c5fbb04's
schema). Copying it into `worktrees/1910a060-s8g` is a gate-time action for the parent relay, not done here.

Order: source gates → hooked commit → fill pins → attestation → separate PG grant → this runner once.
