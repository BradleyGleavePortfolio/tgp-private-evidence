# S5-R4-VALIDATION-SAFETY checkpoint 1 — dirty patch, frozen controls, preparation only

Builder: assigned S5 R4 worker (requested Claude Fable 5 / High; runtime identity not exposed, not attested). 2026-09-22 ~04:30–04:50 UTC. No test, install, DB, network, canonical-lock, destroy or control execution occurred. Only `bash -n`, `node --check`, `git` reads/diff, hashing. Not audit clearance; requires two independent final-head/runner attestations.

## Exact identities
- Bundle sha256 `e42aa021…bd48` verified; restored to isolated `/home/user/workspace/worktrees/s5-r4` (origin no_fetch/no_push). HEAD `143d451ead6ccdbebd92ca3031ba7a89867d6cfc`, tree `d0e122d35022377196908b7d132fc34c1af2fc6b`, clean before edits; `c23b9d9f` ancestor verified; all S5 commits author=committer Bradley Gleave, no AI trailers. Checkpoint-5 SHA256SUMS 5/5 OK. Both frozen R3 reports (A NOT CLEARED; B bounded acceptance) read in full.
- Now DIRTY: 2 files, +50/−4 (`test/rls-g2-pg17-etq0.spec.ts` +16, `test/utils/g2-pg17-bootstrap.sh` +38/−4). Patch `s5-r4-dirty-from-143d451e.patch` sha256 `c36258b39d0c92f0b760f11982a61427c6e7cce963eecffe2554f447346c5491`; dirty fingerprint `6850b32ef19436abe5b02f96c770f4c36ca8bea070e0c759310f17234c616aa0`. `git diff --check` clean. No src/prisma/migration/generator/package change. No `expect(` line or test case removed or altered (probe C12/C13 assert this statically when run). Not typechecked (no node_modules).
- Runner files outside Git (hashes in `SHA256SUMS`): `run-proof.sh` rev 7, `s5-fixture.sh` rev 2, `launch-full.sh` rev 2, `npm-ci.sh` rev 3 (paths only). Controls: `controls/{lib.sh,ctl-lifecycle.sh,ctl-destroy.sh,ctl-genctl.sh,probe-spec-wiring.cjs,teardown-gate/*}` — all UNEXECUTED.
- Not a commit: native hooks (lefthook/tsc/eslint/prettier) cannot run without an ungranted `npm ci`; see `HOOK_DEPENDENCY.md`. Repo-local identity configured and `git var` verified for the later commit.

## Findings disposition (source/runner closure only; nothing executed)
| Finding | Change | Status |
|---|---|---|
| A-01 refused setup still tears down | spec: `teardownAuthorized` flag set after last read-only gate, before first GRANT; afterAll returns with `PG17_TEARDOWN_SKIPPED` if unset; teardown body unchanged | source-closed, unexecuted; controls: probe (Tier 1) + Jest hook control T0–T3 (Tier 2, needs node_modules) |
| A-02 lock/cleanup on abnormal termination | runner: owned children in verified own process groups; inner deadline 1560 s; TERM/INT/HUP traps reap group then cleanup stop under the held lock; FIRST_RC vs PROOF_EXIT separate; CLEANUP_SECONDS recorded; failed stop/survivor → QUARANTINE dir → every later stage refuses rc 4; launcher is a backstop (TERM 1740/KILL +120, margins 100 s/40 s), records OUTER_BOUND_HIT + quarantine, never reacquires the lock | source-closed, unexecuted; control L1–L6 |
| A-03 destroy masks stop failure | fixture: bounded fast stop, refuse rc 4 on stop failure/survivor/data-dir users, rc 5 on removal failure, OK only after verified absence; runner: `G2_PG17_DESTROY_CONFIRM=destroy:<datadir>` required, re-verifies absence, quarantines on refused destroy with live postmaster | source-closed, unexecuted; control D0(pred)–D5 |
| A-04 sessions logged not enforced | preflight refuses every mutating stage unless snapshot sessions = 0 (labelled snapshot, not fence) | source-closed; control L5 |
| A-05 provenance/genctl | bootstrap: `hash_required` fails on missing files (exit 6), candidate runtime resolved from the generated client and pinned, engine equality enforced for BOTH clients, O runtime must end with pinned runtime bytes (header allowance); runner genctl requires rc 1 + "Could not resolve @prisma/client", timeout/other rc = GENCTL_FAIL; jest/prisma via ./node_modules/.bin (no npx) | source-closed; control G1–G4; the tail-equality gate is a fail-closed assumption from B's static observation (130-byte header), unverified by execution here |
| A-06 recreation | `RECREATE.md` exact successor recipe; lane constants in one stamped block | closed as document; fresh full still never run at any head ≥143d |
| A-07 missing npm debug logs | not searched, not fabricated; qualification preserved: raw argv/cwd of the B2 auto-install cannot be rechecked; this sandbox has no `/home/user/.npm/_logs` history, no quarantine dir, no cluster | preserved |
| B-01/03/05/07/08 | fresh full unproven (unchanged); P2028 branch unexecuted (unchanged, out of scope); resume not applicable to the old cluster (historical; cluster absent here); 00:38Z lock touch parent attribution; LOG_SHA256SUMS path note | preserved, no action |

## Known residual/unproven
- Everything above is static. The runner's setsid/group verification, uutils `timeout --foreground` behaviour and the O-runtime tail gate are the highest-risk unexecuted assumptions; the Tier 1 controls are designed to expose them.
- Runner child output now goes to the per-child log only (not duplicated into the launcher log).
- The spec change does not alter what the 51 cases assert; it changes only what a refused `beforeAll` is followed by.

## Next required action (parent)
Inspect `CONTROL_REQUEST.md`; grant Tier 1 controls (≈2.5 min total, no DB/network/install/canonical lock). Later: granted `npm-ci.sh` → Tier 2 gate control → hooks → frozen commit → two independent attestations. No real PG lifecycle proof is requested by this checkpoint.
