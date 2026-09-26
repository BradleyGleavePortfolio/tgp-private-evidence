# S11-B real-PG proof binding — S11 lane v1 (EXEC-FA72EFB2) — SOURCE ONLY, NOT RUN

Built by the T3 binding builder under `s11b/S11B_BINDING_BUILD_GRANT.md`. Nothing was run: no runner, fixture, jest, bootstrap,
PostgreSQL, or lock. Every pin below was re-derived read-only (`git rev-parse` / `git show | sha256sum` / `sha256sum` / `stat`)
in `/home/user/workspace/worktrees/fa72-s11b` and the fa72efb2 runtime.

## Provenance
- Template: `execution/fa72efb2/s11c/binding/v1/s11-pg-proof.sh` (sha256 5e4b29ec9a00947c004aced3d8b2f309e81f31801092c2b78866734a17ee1c1d,
  matches that binding's BINDING.sha256; sentinel `RC=0 STAGE=done END=2026-09-26T15:49:19Z`), read in full.
- Built by `.build-s11-lane-runner.py`: 25 exact substitutions, each asserted to match exactly once in the template.
- Full delta: `DELTA-from-s11c-v1.diff` (11 hunks, +54/-24; 369 -> 399 lines). `bash -n` rc 0 for the runner and the fixture.
- Fixture `s11-fixture.sh` is a byte copy of the S11-C v1 fixture (`cmp` identical, sha256 777e6ac3…1636), so `EXPECT_FIXTURE_SHA`
  is unchanged. The runner filename stays `s11-pg-proof.sh` because the fixture requires that name in `/proc/$S11_RUNNER_PID/cmdline`.

## Changed pins (everything else is the template verbatim)
| pin | S11-C v1 | S11-lane v1 (verified at fa72-s11b) |
|---|---|---|
| D | s11c/binding/v1 | s11b/binding/s11-lane-v1 |
| SRC / W | worktrees/fa72-s11c / fa72-s11c-pg1 | worktrees/fa72-s11b / fa72-s11b-pg1 (absent) |
| BASE_HEAD / BASE_TREE | 3db615c0 / 6ea6852c | 7fdcbc044dba1747d0db2f2750ced951f3b6b752 / a802231ee1f4dd693284b349e7eb078b3688e8d5 |
| EXPECT_HEAD / EXPECT_TREE | 7fdcbc04 / a802231e | 4d31616f9288402c0cdd6a74fb30b4b15d0658d3 / 366efa9f807cf8c1550bfc8a3394b6840f90287b (HEAD^ = BASE, 1 commit) |
| LAND_REF | origin/land/s11c | refs/remotes/origin/land/s11b = 4d31616f |
| EXPECT_DELTA | 7 S11-C paths | 5 S11-B paths (== `git diff --name-only BASE HEAD`) |
| FREEZE-s11c (S11C_FREEZE_SHA 2d58f9d1…137e) | == delta | re-used as "7 S11-C files byte-identical at HEAD" via new `S11C_FILES` (all 7 verified OK) |
| FREEZE-v3 (e6e3a15a…4187) | 8 A1 files | unchanged (all 8 verified OK at HEAD) |
| new S11B_FREEZE / _SHA | — | `FREEZE-s11b.sha256` / ca321526e5363ba553dce66f70f3674b18579962cbe926428916cc03ce6424f4 (paths == delta) |
| new EXPECT_REDRIVE_BLOB | — | aac3f7a8eb2fd49e65b858053fc71bea8c64d3ba test/scout/s11/settle-redrive.pg.spec.ts |
| new EXPECT_LIFECYCLE_BLOB | — | 974e2c831c1c963c4bf1b68381af48136cf78266 src/scout/lifecycle/lifecycle.service.ts |
| new EXPECT_SCOUTSVC_BLOB | — | 9afaac48f250bfbceb21043f6005b6a89eb3ef23 src/scout/scout.service.ts |
| new EXPECT_TESTS_REDRIVE | — | 8 (`^\s*it\(` at HEAD; live switch = pinned form; BADPAT no match) |
| new stage | — | jest-redrive: `./node_modules/.bin/jest --runInBand --ci test/scout/s11/settle-redrive.pg.spec.ts`, default config, `jest-redrive.log`, bound 3000 s, between readiness and guard |
| outer bound | 7200 | **10200** (soft sum 6810 + 3000 = 9810; same 390 s margin) |

Unchanged pins re-verified at HEAD: all 14 template blob pins (A1 8 + jest.rls/jest config + readiness + S11-C service/dto + schema),
migrations tree 7b6fe0ed at BASE and HEAD (173 dirs, last 20270124000000_scout_run_observation_expand), package-lock b7fed5ed…,
schema d6d01f54…, HARNESS_BASE 711c1f8f ancestor of BASE with HARNESS_BASE..BASE test/utils == the 6 A1 utils and no prisma/deps
change, BASE..HEAD touches no prisma/manifests/test/utils/docs; donor hidden lock 05bc530a…, donor client 2c819c8a…/aca7a558…;
postgres/initdb/pg_ctl/psql/node sha256 as pinned; lock inode 686480; pg17 PROVENANCE result=success; source clean, hooks lefthook.

## Expected counts (one command each, no retry)
bootstrap (G2_S11_BOOTSTRAP_OK) -> identity -> rls `jest.rls.config.js test/rls-g2-s11.spec.ts` **6** -> journey
`test/scout/s11/journey-core.pg.spec.ts` **8** -> readiness `test/scout/s11/readiness.pg.spec.ts` **6** -> **settle-redrive
`test/scout/s11/settle-redrive.pg.spec.ts` 8** (J12, J12 edge, J13, J14, J15 a/b/c, tenant scope) -> guard
`test/utils/g2-s11-db-guard.spec.ts` **94** (no DB) -> teardown (stop + marker-gated destroy of clusters/s11/pg-data) -> post.
Each stage requires `Test Suites: 1 passed, 1 total` and `Tests: N passed, N total`. Total 122 tests / 5 suites.
Receipts: RECEIPTS.sha256 adds `jest-redrive.log` to the template list.

Redrive bound: harness workers carry a 90 s kill timer (`g2-s11-pg-harness.ts` worker()), `jest.setTimeout(600000)` per case;
journey-core (8 cases, same harness) took 177 s in the S11-C run. 3000 s is ~17x that; a stage timeout is a failure (rc 124).

Usage (parent only, under a separate single-run PG grant):
`timeout -k 30 10200 bash /home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11b/binding/s11-lane-v1/s11-pg-proof.sh`

## Open risks
- **A — lane dir present, run will PRELOCK_REFUSE.** CLASS: launch precondition. CONCRETE HARM: `runtime/clusters/s11` exists
  (S11-C teardown removed only pg-data; it holds pg.log, pg.log.pg_ctl, pg-data.initdb.log), so the verbatim template refusal
  "$LANE exists (fresh lane only; never adopt)" exits rc 70 before the lock (run NOT consumed). DECISION BLOCKED: launching this
  binding. MINIMUM CLOSURE (parent; runtime is parent-only): archive those 3 files into the S11-C evidence and remove the empty
  `clusters/s11` dir (`runtime/run/s11` is already empty). EXECUTION UNLOCKED: the S11-lane run.
- **B — outer timeout.** CLASS: launch parameter. HARM: a launcher copied from s11c (`timeout -k 30 7200`) can kill bash mid-stage
  before teardown (the header already states no autonomous cleanup is guaranteed then). DECISION: launch command. CLOSURE: use 10200.
  UNLOCKED: an honest bound for the added stage.
- C — the 3000 s redrive bound is a judgment bound (not the 8x600 s theoretical jest ceiling); record the observed Time.
- C — `test/scout/lifecycle/s11b-settle-redrive.spec.ts` (unit) is not run here; it is only frozen via FREEZE-s11b.
- C — `runtime/clusters/s10d2/pg-data` (D2 run, stopped, no postmaster.pid) and, if Binding B ran first, `clusters/s11b-s10b/pg-data`
  are fingerprinted by preflight/post and must stay unchanged; they do not block.
- C — header comments below the S11-B paragraph are template history (e.g. "pins (from the clone source at c8ee9005…)").
