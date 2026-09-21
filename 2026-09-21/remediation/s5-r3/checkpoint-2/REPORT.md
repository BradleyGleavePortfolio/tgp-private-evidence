# S5 R3 validation fixer — builder report, checkpoint 2 (runner revision 3)

Builder report only; not an audit, no self-clearance. Requested model: Claude Fable 5 / High; the runtime
identity is not verifiable from inside the session and is reported as requested-not-observed.

## Frozen state
| | |
|---|---|
| worktree / branch | `/home/user/workspace/worktrees/s5-r3` · `execute/20260921-s5-r3` |
| HEAD / tree | `cf3e72f90ad63d40c1831d8b86141f2d16b7ba05` / `85d57e9d41dd9cce5699b32b669f90ea459fc01b` |
| parent | `9f38ab033b08ae30ce2fc62d0150520239d6a5c8` (checkpoint-1 frozen base; contains O `925780e0` as ancestor) |
| clean | yes at freeze; `git diff --check` clean |
| identity | author = committer = `Bradley Gleave <bradley@bradleytgpcoaching.com>`; `git var` verified before, `git log` fields after; no trailers |
| remote | `origin` push URL `no_push`; nothing pushed, no live action, no history search |
| bundle | `execution/s5-r3/checkpoint-2/s5-r3-candidate.bundle` — `git bundle verify` okay; requires public main `c23b9d9f`; sha256 `cd6595b15f95d15a4f465064ebc5b4c0f7e0365ce78e03018182fbd681fb9c5f` |
| delta | 9f38ab03..cf3e72f9: 4 files +55/−1, all `test/` (`checkpoint-2/delta-9f38ab03..cf3e72f9.patch`). Delta vs public main also shows `src/`/`prisma/` files — those are inherited from the frozen base lineage (S1/S2 ownership), untouched by S5. |
| `initialization/recovered/*` | not modified |

## What changed (source, S5-owned, validation only)
1. `test/utils/g2-pg17-db.ts` — exports `G2_PG17_CLUSTER_MARKER='s5-disposable-pg17'` and
   `G2_PG17_DATABASE_MARKER='s5-g2-etq0-synthetic-disposable-fixture-safe-to-drop'` as pinned literals (not env-derived).
2. `test/utils/g2-pg17-bootstrap.sh` — step 1b (before any write): `current_setting('cluster_name')` must equal the cluster
   marker and hosted-platform role count must be 0, else exit 3; step 3 stamps `COMMENT ON DATABASE` with the DB marker at
   CREATE and refuses (exit 3) a same-named database whose comment differs. Still never drops anything.
3. `test/scout/g2-pg17-db-guard.spec.ts` — one added test (26 → 27) pinning both markers (`^s5-[a-z0-9-]{8,}$`, contains
   `disposable`) and asserting the bootstrap carries the identical literals and does not read them from `${…}`.
4. `test/rls-g2-pg17-etq0.spec.ts` — two `expect`s added to `beforeAll` (cluster marker, database comment). The 51 test
   cases and all terminal/race assertions are untouched (diff is +6 lines: import + 2 assertions + comment).
No `src/`, `prisma/`, generator, migration or workflow files touched.

## What changed (runner / evidence, `execution/s5-r3/`)
- `run-proof.sh` rev 3 (replaces the refused checkpoint-1 runner):
  - single canonical lock `execution/test-validation.lock`, `flock -n` (rc 75, never queues), **held by one process across
    stamp → guard → old root → connected preflight → bootstrap/live/reset → END**; every child/helper runs with fd 9 closed.
  - target identity pinned as literals; preset `G2_PG17_{DATABASE_URL,CONFIRM,DATA_DIRECTORY,SERVER_VERSION}` that differ are
    refused rc 2 before anything else; `DATABASE_URL`/`DIRECT_URL`/`SHADOW_DATABASE_URL`/`SUPABASE_*`/`PG*` unset for children.
  - offline guard (no connection) → read-only connected preflight of 13 identity facts (version, cluster marker, data dir,
    listen_addresses, server addr/port, user, superuser, hosted roles = 0, database names ⊆ allow-list, target existence,
    target marker comment, attached sessions) → only then mutation. `reset` drops solely a marker-verified, idle database.
  - `stamp()` is side-effect-free (`git -C`, explicit `(cd … && exec …)` subshells, PIPESTATUS preserved): head/tree/branch,
    CLEAN or DIRTY_FINGERPRINT (sha256 of diff+status), package-lock blob, `node_modules/.package-lock.json` sha256, toolchain
    versions, pinned target, cpus/mem, START; END + rc at release; holder/release lines in `test-validation.lock.log`.
  - fixture password only from `G2_PG17_PASSWORD`, exported to children, never on a command line or in a log.
- `npm-ci.sh` rev 2 — canonical lock name fixed (rev 1 used `heavy-validation.lock`), nonblocking, refuses a foreign
  package-lock blob or dirty package files, `npm ci --no-audit --no-fund --ignore-scripts` + `prisma generate`, rc preserved.
- `s5-fixture.sh` — lane s5 init with `cluster_name='s5-disposable-pg17'`, port 54325, `s5_super`, loopback only,
  data dir `/home/user/pg17/clusters/s5`; `mark` stamps an existing R2 lane-pg.sh cluster (config only; restart needed).
  An unmarked R2 cluster is refused by preflight and bootstrap until marked. Requires S1's shared PG 17.6 dist; installs nothing.
- `stubs/psql-stub.sh` — offline stand-in used only for runner negative controls (never connects).

## Defect found and fixed during offline controls
The sandbox `git` (`/usr/bin/git`) is a shell telemetry wrapper that lingers ~1 s after each command. With the lock fd
inherited, the first runner's git children kept the lock busy for the next invocation (rc 75 cascade in
`logs/runner-preflight-stub-controls-20260921T233108Z.log`). Fixed by closing fd 9 for `stamp`, `preflight`, `finish` and
all children; re-run back-to-back with no sleeps is clean (`…-20260921T233236Z.log`, C19 `LOCK_FREE_IMMEDIATELY`).

## Offline proof performed (no install, no DB, no server; no slot needed)
- `bash -n` on all shell files, `node --check` on the worker, `git diff --check`: clean.
- `logs/runner-negatives-20260921T233017Z.log` N1–N8: all refused rc 2 before the lock is opened.
- `logs/runner-preflight-stub-controls-20260921T233236Z.log` C1–C22: 12 identity-mismatch scenarios → rc 3, 0 DROP calls;
  marked+busy → rc 3, 0 DROP; marked+idle → DROP after the full preflight batch, rc 0; absent → no-op; connect failure rc 3;
  lock busy → rc 75 with 0 connection attempts; lock released immediately; password absent from all logs.
- `run-proof.sh oldroot` (real, offline): `G2_PG17_OLD_ROOT_OK`, detached at `925780e0`, 164 migrations, alternates none.

## Pending proof (needs a parent-granted slot; see INITIAL_PLAN.md and READY_REQUEST.md)
- TypeScript compile of the edited specs (no `tsc`/ts-jest available offline) — first proven by step 2 (`guard`, expected 27/27).
- Bootstrap marker path against a real server (COMMENT interpolation via `-v marker … :'marker'` on stdin).
- Live 51/51 on lane s5 with the marker assertions in `beforeAll`.
- Real-server preflight facts (the stub only proves the runner's decision logic, not PostgreSQL's answers).

## Not done / out of scope
No push, no live action, no history search, no schema or E recovery text changes (S1 owns), no install, no cluster created.
