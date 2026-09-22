# SLOT B3-S5-PINNED-RESUME — result (builder report, not an audit)

Source 143d451ead6ccdbebd92ca3031ba7a89867d6cfc / tree d0e122d35022377196908b7d132fc34c1af2fc6b, CLEAN=yes; A1 deps (NODE_MODULES_PACKAGE_LOCK_SHA256 05bc530a…). Runner rev 6 (checkpoint-4). No init/reset/destroy; no source edit during the slot; no network/install.

## Stage 1 genctl — 00:28:59Z→00:29:02Z, runner pid 30037, PROOF_EXIT=0 (logs/genctl-20260922T002859Z.*, run-/env-/exit-genctl-20260922T002859Z.log)
- Negative: `prisma generate` (pinned CLI 6.19.3, PRISMA_GENERATE_SKIP_AUTOINSTALL=1) into /tmp/s5-genctl-*/no-root/out → rc 1 with the intended message `Error: Could not resolve @prisma/client.` (schema loaded; no other error). No npm invocation logged (npm log before==after), no package.json/node_modules created under the temp dir or /tmp.
- Positive: `@prisma/client/package.json` from `old-root-925780e0/.g2-old-client` → `/home/user/workspace/worktrees/s5-r3/node_modules/@prisma/client/package.json` == pinned.
- Ancestor roots: /home/user/{package.json,package-lock.json,node_modules} absent before and after.

## Stage 2 resume — 00:29:32Z→00:33:40Z, launcher 30907 / timeout 30910 / runner 30911, sentinel logs/full-20260922T002932Z.sentinel `FULL_EXIT=0 CLEANUP_STOP_RC=na`
One lock holder (HOLDER 00:29:32Z pid 30911 → RELEASE 00:33:40Z rc=0 stop_rc=0 daemon=none):
guard 27/27 → G2_PG17_OLD_ROOT_OK → S5_FIXTURE_START_OK (postmaster 31307, existing marked stopped cluster) → LOCK_EXCLUSIVE_OK → PREFLIGHT_OK: version 170006, cluster s5-disposable-pg17, datadir /home/user/pg17/clusters/s5, listen/addr 127.0.0.1, port 54325, user s5_super super=t, hosted_roles=0, dbs=[g2_s5_etq0_disposable postgres template0 template1], target_exists=1 with database marker → generate-only: `O_CLIENT_RESOLUTION pinned=…/worktrees/s5-r3/node_modules/@prisma/client/package.json version=6.19.3 skip_autoinstall=1`; `O_CLIENT_GENERATED dir=…/old-root-925780e0/.g2-old-client engine_sha256=a2924eab1c78a0a7bb67edac5738939fa10589ef073af5542f53812a22e4a7d8 runtime_sha256=5a72b6f6…`; `CANDIDATE_CLIENT_GENERATED dir=…/worktrees/s5-r3/node_modules/.prisma/client engine_sha256=a2924eab…`; G2_PG17_GENERATE_OK → live: **Tests: 51 passed, 51 total** (225.6 s; spec beforeAll asserted 164 applied / E absent / source_platform absent and both markers before mutating; claim-race branch observed `down-applied`, PG17_RESOLVE_ROLLED_BACK P3012 path exercised, PG17_CLAIM_REFUSED_WORKER observed) → S5_FIXTURE_STOP_OK → `PROOF_EXIT=0 STAGE=resume STOP_RC=0 DAEMON=none`.
- npm logs in the window: only the two `npm exec jest` invocations; no install. NPM_ROOT_FACT /home/user/* absent before and after (env-resume-20260922T002932Z.log).
- Post-run: no postmaster.pid, no S5 children, lock FREE. Cluster left stopped, now mutated by the 51 tests (E applied/rolled back per spec) — not pristine; any later run needs parent decision (destroy+full or accept state).

Logs: logs/{run,env,exit,guard-unit,oldroot,fixture,generate-only,live-etq0}-*20260922T002932Z*.log, logs/full-20260922T002932Z.{pid,sentinel,launcher.log}, logs/slot-B3.log. B2 logs, checkpoint-3/4 untouched.
