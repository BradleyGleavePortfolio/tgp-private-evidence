# S10-C real-PG proof binding v1 — EXEC-D3A9F701 (SOURCE ONLY: NOT RUN, NOT GRANTED)

Derived from the landed S10-B binding (`../../../s10b/binding/v1/s10b-pg-proof.sh` and `s10b-fixture.sh`; that run was rc 0, 24/24).
Diffs: `DELTA-from-s10b-v1.diff` (runner, against the filled S10-B copy) and `DELTA-from-s10b-v1-fixture.diff`. Hashes: `BINDING.sha256`.

## Lane (review B B4)
- **New lane, new port.** The lane is `runtime/clusters/s10-c` with socket `runtime/run/s10-c` on port **55649**.
- **Harness literals are reused.** These are cluster marker `s10b-disposable-pg17`, DB `g2_s10b_disposable`, role `s10b_super` / `s10b_local_synthetic`, and DB marker `s10b-g2-run-observation-synthetic-disposable-fixture-safe-to-drop`. `test/rls-g2-s10c.spec.ts` drives the landed S10-B harness by parameter, and that harness only parameterizes port (`G2_S10B_DATABASE_URL`/`_CONFIRM`) and data directory (`G2_S10B_DATA_DIRECTORY`).
- **How the lane is told apart.** The marker is shared with the retained s10-b lane, so identity rests on data dir and port. The fixture's `start`/`destroy` require the marker **and** `port = 55649` in this data dir. The runner's identity step checks `SHOW data_directory` = `clusters/s10-c/pg-data` and `inet_server_port()` = 55649.
- **Refusals:**
  - LANE ≠ clusters/s10-c, or LANE = clusters/s10-b: refused by both runner and fixture.
  - Port 55646 or 55647: refused as the lane port. They must also have zero listeners before and after the run.
  - Port 55649 appearing in the harness `REFUSED_PORTS`: refused. 55646 must be in that list.
- **Retained s10-b lane.** `clusters/s10-b/pg-data` must exist with postgresql.conf and pg_control present, and have no postmaster.pid. It is fingerprinted with all other lanes and must be unchanged at the end. It is never started or destroyed here.
- **Fixture runner check.** The fixture requires `S10C_RUNNER_PID` to be a live `s10c-pg-proof.sh`. Its RUNTIME_ROOT / PORT / LANE / DATA lines and the refusal lines are cross-checked by the runner as whole lines.

## Run
`jest --config jest.rls.config.js test/rls-g2-s10b.spec.ts test/rls-g2-s10c.spec.ts --runInBand --ci` runs exactly once.
- **Before the lock, on the committed bytes:** it() counts are 24 (s10b) and 8 (s10c), with no skip/only/todo. The s10c spec must import `./utils/g2-s10b-harness` and reference no `g2-s10c-`/`G2_S10C_`.
- **Required output:** `Tests: 32 passed, 32 total`, `Test Suites: 2 passed, 2 total`, and exactly the two `PASS` lines.
- **Not run:** `test/rls-g2-s9c.spec.ts`.

## Other checks (all before the lock, read-only; PRELOCK_REFUSED does not consume the run)
- HEAD^ = BASE_HEAD. S10B_HEAD and a4af8e33 are ancestors of BASE_HEAD.
- BASE..HEAD equals the filled EXPECT_DELTA, which must itself equal the 11 owned paths, plus `docs/contracts/importer-openapi.json` if and only if `EXPECT_CONTRACT_STATE=changed`.
- The contract blob at BASE is 752f9dbe. At HEAD it equals EXPECT_CONTRACT_BLOB, which must be 752f9dbe exactly when the state is unchanged.
- The 29 FROZEN blobs are present at HEAD (the file is shared with the gate and its sha is pinned).
- No prisma, package or test/utils change since S10B_HEAD. Package files are unchanged since a4af8e33, which the bootstrap requires at L158.
- The migrations tree is 7b6fe0ed at BASE and HEAD: 173 dirs, the last being the S10-B dir.
- scout.module.ts at HEAD **imports** ObservationModule.
- The client equals the S10-C gate receipt and differs from the donor 9042e713. The donor is unchanged.
- The worktree is clean. Hooks are regular lefthook files.
- Tool pins match S10-B v1.
- **Carried:** symlink-aware sentinel + `run/STARTED` created O_EXCL (`set -C`) right after the flock, nonblocking flock fd 9 with inode 692282, under-lock rechecks, no `cmd | grep -q`, bounded stop, and the data dir retained.

## Fill (parent, from the S10-C gate receipt `../../gate/HEAD-<12>.txt`)
Copy `s10c-pg-proof.sh.template` to `s10c-pg-proof.sh`, then replace:

| Placeholder | Receipt line |
|---|---|
| `__FILL_BASE_HEAD__` / `__FILL_BASE_TREE__` | `base=` / `base_tree=` |
| `__FILL_EXPECT_HEAD__` / `__FILL_EXPECT_TREE__` | `head=` / `tree=` |
| `__FILL_EXPECT_DELTA__` | `delta=` (trailing space is tolerated) |
| `__FILL_CONTRACT_STATE__` / `__FILL_CONTRACT_BLOB__` | `contract_state=<state> blob=<blob>` |
| `__FILL_S10C_SPEC_BLOB__` | `blob test/rls-g2-s10c.spec.ts <blob>` |
| `__FILL_HOOK_PRECOMMIT_SHA__` / `__FILL_HOOK_COMMITMSG_SHA__` | `hooks raw pre-commit=<sha256> commit-msg=<sha256>` |
| `__FILL_NM_CLIENT_SHA__` / `__FILL_NM_CLIENT_SCHEMA_SHA__` | `postgen_client index_dts=` / `schema=` (expected 2c819c8a… / aca7a558…) |

If the receipt's `it_count` is not 24 + 8, stop. The gate enforces 8, so this indicates drift.

Relay: `timeout -k 30 3900 bash /home/user/workspace/tgp-private-evidence/execution/d3a9f701/s10c/binding/v1/s10c-pg-proof.sh`

Destroying the lane afterwards needs a separate grant: `S10C_RUNNER_PID` must be a live runner, so standalone `s10c-fixture.sh destroy` is refused.

## Assumptions to verify
- **Clean start state.** `clusters/s10-c` and `run/s10-c` must not exist, and no postgres may be running (preflight refuses otherwise).
- **Port choice.** 55649 is assumed free and is absent from the harness REFUSED_PORTS. 55648 is not used.
- **The s10b spec on the S10-C head.** The S10-B spec's real `complete` (L403-415) now also writes the settled-basis row, so it depends on the S10-C code being correct. That is the point of running both specs.
- **Worker registry.** The S10-B worker builds the default registry (no on-disk manifests), so the live `complete` exercises only the structural D-S10-4 half (builder's open question 1).

## Review fixes (s10c_gate_binding_review.md; diff: DELTA-review-fix.diff)
- **B1.** The no-change-since-S10-B pathspec is narrowed from `test/utils` to `'test/utils/g2-s10b-*'`. S11-A1 (c8ee9005) adds `g2-s11-*` files.
- **B2.** Mirrors the S11 runner fix:
  - `core.hooksPath` must be unset;
  - the hooks dir must be the plain `$W/.git/hooks` directory, not a symlink;
  - both hook files must be regular files with sha256 equal to the two new `__FILL__` pins from the receipt's `hooks raw` line.
  All of this is re-asserted under the lock.
