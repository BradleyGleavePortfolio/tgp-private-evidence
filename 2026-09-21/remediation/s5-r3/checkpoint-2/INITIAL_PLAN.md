# S5 R3 — smallest execution / DB-safety plan (checkpoint 2, runner revision 3)

Status: **REQUEST ONLY — nothing below has been executed.** No install, build, test, server start or
database connection has happened in this lane. Requires a parent-granted named slot on the canonical
lock before any step runs.

## Source fingerprint (exact)
| item | value |
|---|---|
| worktree | `/home/user/workspace/worktrees/s5-r3` (separate clone; `origin` push URL = `no_push`) |
| branch | `execute/20260921-s5-r3` |
| HEAD | `cf3e72f90ad63d40c1831d8b86141f2d16b7ba05` |
| tree | `85d57e9d41dd9cce5699b32b669f90ea459fc01b` |
| parent | `9f38ab033b08ae30ce2fc62d0150520239d6a5c8` (frozen S5 base, checkpoint 1) |
| working tree | clean (`git status --porcelain` empty at freeze) |
| author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` (both; no trailers) |
| package-lock blob | `354de3dae19449970497da6e4d87f0a1225a8f43` (S5's own lock; npm-ci.sh refuses any other) |
| delta 9f38ab03..HEAD | 4 files, +55/−1, all under `test/` (validation only) |
| bundle | `execution/s5-r3/checkpoint-2/s5-r3-candidate.bundle` (needs public main `c23b9d9f`), sha256 `cd6595b1…9c5f` |

## Commands, in order (each one is a separate slot-gated step; stop on first non-zero)
All take `/home/user/workspace/execution/test-validation.lock` NON-BLOCKING (rc 75 if busy; never queue).

| # | command | needs | writes | bound |
|---|---|---|---|---|
| 0 | `bash execution/s5-r3/run-proof.sh oldroot` | git only (no lock, no DB, no deps) | `execution/s5-r3/old-root-925780e0` (already exists, verify-only) | ≤ 60 s |
| 1 | `bash execution/s5-r3/npm-ci.sh` | npm registry per package-lock.json only | `worktrees/s5-r3/node_modules`, prisma client | ≤ 10 min, ≤ 2 CPU, ≤ 3 GB |
| 2 | `bash execution/s5-r3/run-proof.sh guard` | node_modules | logs only | ≤ 3 min |
| 3 | `bash execution/s5-r3/s5-fixture.sh init && bash execution/s5-r3/s5-fixture.sh start` (or `mark` + restart if the R2 lane-pg.sh s5 cluster exists) | S1's shared PG 17.6 at `/home/user/pg17/dist`; `/usr/bin/psql` | `/home/user/pg17/clusters/s5` only | ≤ 2 min |
| 4 | `G2_PG17_PASSWORD=<fixture pw> bash execution/s5-r3/run-proof.sh preflight` | server up | nothing (read-only) | ≤ 30 s |
| 5 | `G2_PG17_PASSWORD=<fixture pw> bash execution/s5-r3/run-proof.sh all` | 1–4 green | roles + database `g2_s5_etq0_disposable` on lane s5 only | ≤ 25 min wall, heap 4 GB |
| 6 (only if 5 leaves a marked DB behind and a rerun is authorised) | `… run-proof.sh reset` | marker verified, 0 sessions | DROP of the marked database only | ≤ 30 s |

One infra-class rerun maximum; a failing assertion is reported, never rerun to green.

## Target identity (pinned literals inside run-proof.sh; environment cannot override — differing presets are refused rc 2)
host `127.0.0.1` · port `54325` · db `g2_s5_etq0_disposable` · admin `s5_super` (superuser on the lane) ·
data dir `/home/user/pg17/clusters/s5` · server_version_num `170006` · `cluster_name = 's5-disposable-pg17'` ·
database comment `s5-g2-etq0-synthetic-disposable-fixture-safe-to-drop` · allowed databases on the cluster
`{template0, template1, postgres, s5_tgp, g2_s5_etq0_disposable}` · zero hosted roles
(`supabase_admin, supabase_auth_admin, supabase_storage_admin, authenticator, pgbouncer`).
Fixture password only via `G2_PG17_PASSWORD` (synthetic `s5_local_synthetic` documented in s5-fixture.sh); never on a command line, never logged
(control C20: no log contains it). `DATABASE_URL`/`DIRECT_URL`/`SHADOW_DATABASE_URL`/`SUPABASE_*`/`PG*` are unset for all children.

## Order of proof before any mutation
offline guard (URL shape, refused ports, marker literals identical in TS/bootstrap/runner, psql executable, password plain-form)
→ lock (nonblocking) → stamp → [guard spec] → [old root] → connected READ-ONLY preflight on maintenance DB
(13 identity facts; any mismatch rc 3, connection failure rc 3) → only then bootstrap / live / reset, under the same lock.
`reset` drops only when the marker comment matches AND no sessions are attached. Bootstrap additionally re-checks
cluster marker + hosted roles itself and refuses an unmarked same-named database (exit 3); it never drops.

## Negative controls already executed offline (no server, no deps)
`execution/s5-r3/logs/runner-negatives-20260921T233017Z.log` — N1–N8 (usage 2; URL/DATA_DIRECTORY/SERVER_VERSION override 2; missing/URL-shaped password 2; bad psql 2; missing node_modules 2) — all refused BEFORE the lock is opened.
`execution/s5-r3/logs/runner-preflight-stub-controls-20260921T233236Z.log` — C1–C22 against an offline psql stand-in
(`execution/s5-r3/stubs/psql-stub.sh`): blank/foreign cluster_name, hosted roles, foreign database name, wrong version/datadir/port,
non-loopback, non-superuser, unmarked or wrong-marker target → rc 3 with **zero DROP calls**; marked+busy → rc 3, no DROP; marked+idle → DROP
only after the full preflight batch; absent → no-op rc 0; connection failure rc 3; lock held elsewhere → rc 75 with no connection attempt;
lock free immediately after exit; password absent from every log.
`execution/s5-r3/logs/oldroot-*.log` — real detached O checkout created/verified; 6 identity-gate negatives.

## Artifact destinations
`execution/s5-r3/logs/{run,env,preflight,guard-unit,oldroot,bootstrap,live-etq0,reset,exit}-<stage>-<TS>.log`;
lock holder/release lines appended to `execution/test-validation.lock.log`; nothing written inside the worktree except `node_modules`.

## Expected proof outcome
guard 27/27 · `G2_PG17_OLD_ROOT_OK` · `PREFLIGHT_OK` · `G2_PG17_BOOTSTRAP_OK` (164 migrations, then E → 165 inside the spec) ·
live 51/51 with `PG17_DATABASE` line showing `clusters/s5`, version 170006, port 54325 · `PROOF_EXIT=0`.
