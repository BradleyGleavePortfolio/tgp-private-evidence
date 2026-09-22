# S5 successor frozen: closed dependency provenance — next-slot request (no execution performed)

## Frozen source (worktree clean, author=committer Bradley Gleave)
- cf3e72f9 (B2 run) → b94c2488 (type import, +1) → **143d451ead6ccdbebd92ca3031ba7a89867d6cfc**, tree d0e122d35022377196908b7d132fc34c1af2fc6b, +26 lines in `test/utils/g2-pg17-bootstrap.sh` only. No schema/migration/application/assertion change. Bundle checkpoint-4/s5-r3-candidate.bundle (verify okay, sha e42aa021…), patch cf3e72f9..143d451e.patch, SHA256SUMS. checkpoint-3 and B2 logs untouched.

## Bootstrap change (143d451e)
1. `export PRISMA_GENERATE_SKIP_AUTOINSTALL=1` before any `prisma` call.
2. `G2_PG17_OLD_CLIENT` must be inside `G2_PG17_OLD_ROOT` (exit 2 otherwise) — the O checkout's `node_modules` is the shared symlink to the pinned npm-ci tree, so resolution is local.
3. Fail-closed resolution: `require.resolve('@prisma/client/package.json', {paths:[OLD_CLIENT]})` (realpath) must equal the candidate's `$ROOT/node_modules/@prisma/client/package.json`, else exit 6 before generating. Prints `O_CLIENT_RESOLUTION pinned=… version=… skip_autoinstall=1`.
4. Generated O engine must equal `$ROOT/node_modules/@prisma/engines/libquery_engine-debian-openssl-3.0.x.so.node` (exit 6); prints `O_CLIENT_GENERATED … engine_sha256 runtime_sha256` and `CANDIDATE_CLIENT_GENERATED …` for the client the spec imports.
5. `generate-only` mode = steps 4, 6, 7 (O identity, both generations), no connection, ends `G2_PG17_GENERATE_OK`; default `bootstrap` mode unchanged otherwise.

## Runner rev 6 (checkpoint-4/run-proof.sh sha 7c290311…)
- `G2_PG17_OLD_CLIENT=$S/old-root-925780e0/.g2-old-client` (inside the O checkout); `PRISMA_GENERATE_SKIP_AUTOINSTALL=1` exported to every child. Consumer alignment: the spec reads `oldClient = process.env.G2_PG17_OLD_CLIENT` (harness line 20), so it follows the runner env; the old B2 output dir `old-client-925780e0/` stays as evidence, unused.
- `resume` now = guard → oldroot → start (marked, stopped) → LOCK_EXCLUSIVE → 13-fact preflight (target must exist) → **bootstrap.sh generate-only** → live 51 → stop.
- Stamp and finish print `NPM_ROOT_FACT` lines (package.json/package-lock.json size+sha256 or `absent`; node_modules symlink/dir file count/absent) for /home/user, /home/user/workspace, execution/s5-r3, old root — recorded before AND after each run from now on. No pre-B2 "before" exists and none is fabricated; the only B2-era facts are npm's own logs and the quarantined files (parent hashes 81b8f6c9 / fb68359c / fd6895a8).
- Small negative control stage `genctl` (offline, no DB, no network): with auto-install off, `prisma generate` into a temp dir outside any package root must fail, create no package.json/node_modules, add no npm log; positive: `@prisma/client` from the new O-client path resolves to the pinned tree. Not a log-scanner system; one-off check under the lock.

## Disclosure
At 00:24:31Z my usage probe `run-proof.sh genctl` passed the offline guard and attempted the lock; it returned rc 75 LOCK_BUSY (S6 holds it) — nothing ran, no lock, no npm log (`00_24_12Z` npm log is not mine). Should have stopped at usage; noted. Quarantine not touched.

## Requested next slot (single lock acquisition each, sequential, no init/reset/destroy)
1. `bash execution/s5-r3/run-proof.sh genctl` — ≤3 min, cheap CLI, expect `GENCTL_OK`, PROOF_EXIT=0.
2. `G2_PG17_PASSWORD=s5_local_synthetic STAGE=resume bash execution/s5-r3/launch-full.sh` — ≤30 min + 60 s cleanup; expect guard 27, OLD_ROOT_OK, START_OK, LOCK_EXCLUSIVE_OK, PREFLIGHT_OK target_exists=1 with both markers, pre-state 164 ledger / E absent / source_platform absent (spec beforeAll), `O_CLIENT_RESOLUTION` → pinned, `G2_PG17_GENERATE_OK`, live 51/51, STOP_RC=0, DAEMON=none, NPM_ROOT_FACT before==after (all /home/user roots absent), PROOF_EXIT=0.
