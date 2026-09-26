# S11-A1 real-PG binding v1 (EXEC-D3A9F701) — SOURCE ONLY, NOT RUN

This binding is derived from `s10b/binding/v1` (filled `s10b-pg-proof.sh`, sha256 `620f0458…f554`, and `s10b-fixture.sh`, sha256 `7d9ee89b…20e8`), including all of its review fixes. The full diff is in `DELTA-from-s10b.diff`.

## Candidate

| pin | value |
|---|---|
| EXPECT_HEAD | `c8ee9005ff1f75d40934fb85f48e0c7c2266bd9d`: equals `exec-d3a9/s11a1` and `refs/remotes/origin/land/s11a1` |
| EXPECT_TREE | `a86e765b633c3f5aa42cbcf3e1e9a3733f156447` |
| BASE_HEAD (= HEAD^) | `711c1f8f8b42157bca97f2a721557be7ef006667` (tree `abc927e4…`), the integration/importer tip |
| delta BASE..HEAD | the 8 S11-A1 test paths, byte-checked against `s11a1/commit/FREEZE.sha256` (sha256 `7d053684…d895`) |
| migrations tree | `7b6fe0ed…` at both HEAD and BASE. There are 173 directories and the last is `20270124000000_scout_run_observation_expand`. The candidate has no migration, and prisma, package.json and package-lock are unchanged vs BASE. |
| blobs | spec `50de9608`, journey `955b3d81`, guard `e1ace171`, bootstrap `0e234b58`, db `3f04f566`, harness `240a4969`, pg-harness `2cb6e79a`, worker `d1504f6a`, jest.rls.config `44c96915`, jest.config `769a4146`, schema `f86c1f5d` (sha256 `d6d01f54…`) |

## Clone and dependencies
1. **Clone.** The run creates `worktrees/d3a9-s11a1-pg` fresh; it must not already exist. The steps are `git clone --shared --no-checkout` of `worktrees/d3a9-s11a1`, then a detached checkout of EXPECT_HEAD, with hooks disabled for both commands. The runner then verifies the clone's head, tree, parent, clean status and migrations tree.
   - **Deviation from the brief:** the brief says `node_modules` is present in the clone source, but `worktrees/d3a9-s11a1` has **no `node_modules`**.
2. **Dependencies.** The donor is `worktrees/1910a060-s8f/node_modules` (the same donor as the S10-B gate). It is read-only; pins: hidden lock `05bc530a`, client `9042e713`/`b8439203`, prisma CLI 6.19.3. The runner copies it into the clone with `cp -a`, then runs `prisma generate` in the clone.
3. **Client check.** The generated client must equal the S10-B gate's `postgen_client`: `index.d.ts` `2c819c8a…`, `schema.prisma` `aca7a558…`. The schema is the same (d6d01f54), and so are the CLI and the donor. The runner also checks that the engine matches the pinned `@prisma/engines` copy and that the donor tree signature is unchanged.
4. **Disk.** At least 1,500,000 KiB must be free; about 1.9 GB is free at build time.

## Lane
- **Identity:** `runtime/clusters/s11` and `runtime/run/s11`; port **55648**; `s11_super` / `s11_local_synthetic`; DB `g2_s11_disposable`; marker `s11-disposable-pg17`; DB marker `s11-g2-journey-multi-host-synthetic-disposable-fixture-safe-to-drop`.
- **Checked against the harness:** the runner checks these whole-line against the committed `g2-s11-db.ts` and `g2-s11-bootstrap.sh`, and against the fixture.
- **Refused ports:**
  - 55646, 55647 and 55649 are refused as the lane port.
  - The S11 guard's REFUSED_PORTS must contain 55646 and 55647 and must not contain 55648.
  - 55649 is not in the guard's list; the guard spec accepts it as a control. The runner refuses it itself.
- **Existing lanes** (`clusters/*` and `proof-*/clusters/*`, e.g. s8-g, s9-b, s9-c, s10-b and s10-c if present) are fingerprinted before and after the run and never started. No postgres process may be running at preflight.
- **Env:** `G2_S11_DATABASE_URL` (`…?schema=public&connection_limit=2`), `G2_S11_CONFIRM=g2_s11_disposable:55648`, `G2_S11_PASSWORD`, `G2_S11_PSQL`, `G2_S11_DATA_DIRECTORY`, `G2_S11_SERVER_VERSION=170006` and `G2_S11_CANDIDATE_HEAD`.
  - `G2_S11_DATA_DIRECTORY` is added to the brief's list because `g2-s11-pg-harness.ts:44-47` throws without it.
  - `G2_S11_WORKER` is set only by the pg-harness for its children, so it is unset in the runner.
  - Every other `G2_*` variable is unset.

## Commands (each once, no retry)
1. `test/utils/g2-s11-bootstrap.sh bootstrap`. The runner checks for `G2_S11_BOOTSTRAP_OK`, the CANDIDATE_HEAD line and the CANDIDATE_CLIENT_VERIFIED line. Identity is then checked through psql: data_directory, 170006, cluster_name, DB marker, 173 applied migrations with the last = S10-B, the 3 S10-B tables with ENABLE+FORCE RLS, and the port.
2. `jest --config jest.rls.config.js --runInBand --ci test/rls-g2-s11.spec.ts` must report `Tests: 6 passed, 6 total`.
3. `jest --runInBand --ci test/scout/s11/journey-core.pg.spec.ts` (default config) must report `Tests: 8 passed, 8 total`. A skip would change this line, so any skip fails the run. The runner also pins the source form of the spec's live switch.
4. `env -u G2_S11_* jest --runInBand --ci test/utils/g2-s11-db-guard.spec.ts` (no DB) must report `Tests: 94 passed, 94 total`. That is 10 `it` plus `it.each` rows of 61, 20 and 3; devloop-1 ran the same bytes (`4e8c0fee`) and got 94 passed.

Every run must also report `Test Suites: 1 passed, 1 total`. Before the lock, the runner checks that neither PG spec contains skip, only, todo or each, and it pins the `it(` counts.

## Carried forward
- All pins are checked before the lock, STARTED and the sentinel (PRELOCK_REFUSED does not consume the run).
- A nonblocking flock is taken on `execution/test-validation.lock`, and the lock inode must be 692282.
- STARTED is created O_EXCL (`set -C`) immediately after the lock.
- Under the lock, the runner rechecks the fixture, source HEAD/status/land ref, FREEZE, donor client, clone path and lane.
- Hook checks are symlink-aware and must find lefthook (on the source repo that made the commit).
- There is no `cmd | grep -q` anywhere; output is captured first and grepped as a here-string.
- NODE_OPTIONS is `--max-old-space-size=4096`, and the rest of the S10-B env block is kept.

## Teardown (new)
- Whenever this run initialised the lane, it ends with a stop followed by a marker-gated `s11-fixture.sh destroy`, on success and on any failure after init. `destroy` removes only `$LANE/pg-data`.
- The logs `pg.log`, `pg.log.pg_ctl` and `pg-data.initdb.log` stay in `$LANE` and are also copied into `run/`. RECEIPTS.sha256 covers the run logs, the three jest logs and prisma-generate.log.
- If a stop fails, destroy is not attempted and the survivor is reported.
- Because `$LANE` (with its logs) survives, a second run of this binding is refused (fresh-lane rule).
- The clone `worktrees/d3a9-s11a1-pg` is **retained**; removing it is a separate step.

## Usage
`timeout -k 30 7200 bash /home/user/workspace/tgp-private-evidence/execution/d3a9f701/s11a1/binding/v1/s11-pg-proof.sh`, under the separate single-run PG grant. Evidence goes to `run/`.
