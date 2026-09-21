# SLOT A1-S5-SETUP / A1-R2 — result (steps 1–2 only; no DB action)

Source: worktrees/s5-r3 @ cf3e72f90ad63d40c1831d8b86141f2d16b7ba05, tree 85d57e9d41dd9cce5699b32b669f90ea459fc01b, CLEAN (unchanged; still clean after both steps).
Toolchain: node v20.20.1, npm 10.8.2. package-lock blob 354de3dae19449970497da6e4d87f0a1225a8f43.

## Step 1 — npm-ci.sh
- attempt 1 (TS 233753, pid 9215): INTERRUPTED at 23:38:20Z — launcher killed with the tool-call process group (nohup insufficient). No exit record; npm debug log healthy to that point. NOT an npm/source failure, NOT a pass. HOLDER line without RELEASE in test-validation.lock.log; lock fd closed with the process (verified free). Log: logs/npm-ci-20260921T233753Z.log, ~/.npm/_logs/2026-09-21T23_37_53_599Z-debug-0.log.
- attempt 2 (TS 234342, pid 11584 / child 11697, setsid-detached; verified live holder + child + no attempt-1 survivors at 23:49:06Z): `npm ci --no-audit --no-fund --ignore-scripts` added 1117 packages in 6m, exit 0 (23:49:33Z); `prisma generate` exit 0, Prisma Client v6.19.3 (23:49:48Z). PROOF_EXIT=0.
  NODE_MODULES_PACKAGE_LOCK_SHA256=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44. Logs: logs/npm-ci-20260921T234342Z.log, logs/exit-npm-ci-20260921T234342Z.log.

## Step 2 — run-proof.sh guard (TS 235017, 23:50:17Z → 23:50:27Z)
- Lock held nonblocking by the runner only; stamp HEAD=cf3e72f9 CLEAN=yes; offline guard OK; no connection attempted.
- `npx jest test/scout/g2-pg17-db-guard.spec.ts`: Test Suites 1 passed; **Tests 27 passed, 27 total** (includes the new marker-pin test). PROOF_EXIT=0.
  Logs: logs/run-guard-20260921T235017Z.log, logs/env-guard-20260921T235017Z.log, logs/guard-unit-20260921T235017Z.log, logs/exit-guard-20260921T235017Z.log.

## State at release (23:50Z)
Lock free; no S5 children alive; worktree clean at cf3e72f9; node_modules present (only write inside the worktree).
Within A1-R2 bound (23:43:42 → 23:56:42). No PG setup/start/connection/bootstrap/live/reset/mark performed. /home/user/pg17 absent, as reported.
Timeline: logs/slot-A1-S5-SETUP.log. Awaiting DB-stage allocation (INITIAL_PLAN steps 3–5 depend on S1's shared PG 17.6 dist, which S5 will not install).
