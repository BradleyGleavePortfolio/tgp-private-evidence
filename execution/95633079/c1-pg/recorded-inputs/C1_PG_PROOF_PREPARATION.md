# C1-only real-PG proof — execution preparation (source-only; nothing run, created or mutated)

Preparer s5_exact_candidate_continuation (T4; requested Claude Fable 5 / High). Sole writes: this directory. Inputs read from fixed git objects in the C1 builder's store (`worktrees/s7-c1`, read-only, `GIT_OPTIONAL_LOCKS=0`): PR526 head `881c4c791727adef8d423931e1cca83a0ffbb9c9`, foundation `5c760b77`, frozen candidate tree `b56e984b` (s7-c1 packet `128496e2`), formatted candidate tree `87798e74`. No runtime, process, probe, install, database, cluster, source, index, object or ref mutation. All pins in `PINS.txt`; retrieved copies in `retrieved/`.

## 1. The exact existing test
`test/rls-c1-setup.spec.ts`, PR526 blob `1dd9decee38f8b04511b46406c18394c1fb7eaf7` (sha256 `258b0d61…`, 363 lines), identical in candidate `b56e984b`; formatter-only variant `cc3b0e4d` in `87798e74` (s7-c1 `format/` evidence). One `describe('C1-S1 real PostgreSQL authority and recovery')`: **15 direct `it` + 3 `it.each` blocks (3 + 2 + 2 rows) = 22 cases**; explicit timeouts: `beforeAll` 30 000 ms, case "recovers a committed init after its process exits" 45 000 ms; all other cases inherit `jest.config.js` `testTimeout: 10000` (jest.rls.config.js spreads the base). Real Prisma client + real psql; **never skips** — every guard failure is a thrown error at module load (suite fails, 0 tests).

## 2. Guard requirements (module-load, verbatim from the spec)
| env / condition | required value |
|---|---|
| `C1_SETUP_TEST_DATABASE_URL` | exactly `postgresql://user@127.0.0.1:55439/c1_setup_disposable` — protocol `postgresql:`, host `127.0.0.1`, port `55439`, path `/c1_setup_disposable`, **no query string, username `user`, no password** |
| `C1_TEST_PSQL` | absolute psql path; only `/usr/bin/psql` exists (18.6 client; PG dist has no psql). Invoked `-X -v ON_ERROR_STOP=1 -At <url>` with inherited env, 15 s timeout |
| `C1_TEST_DATA_DIRECTORY` | must equal `SHOW data_directory` **and** end with `/c1-builder/pg-data` |
| `C1_SETUP_DISPOSABLE_ACK` | `c1-local-only-55439` |
| server | `SHOW data_directory` == the env value → cluster must be initialised with exactly that absolute path (`/home/user/pg17` is a real path, not a symlink) |

Derived database requirements (spec body): database `c1_setup_disposable` **must pre-exist** (spec never creates it); connecting role `user` must be able to `CREATE ROLE … LOGIN BYPASSRLS`, `CREATE TYPE/TABLE/FUNCTION/TRIGGER/SCHEMA/POLICY`, `SET ROLE anon|authenticated|<owner>`, `DROP SCHEMA … CASCADE`, `GRANT` — i.e. **superuser**; the spec itself creates `anon`, `authenticated`, `service_role` (LOGIN BYPASSRLS) if absent, drops/recreates `"User"`, `"ExtensionPairCode"`, `"ImportIntent"`, type `"Role"`, applies `20261222000000_add_extension_pair_codes/migration.sql` (blob `87a0f4a9`, needs only `"User"`) then C1 `20270117000000_durable_import_setup/{migration,down}.sql` (blobs `41a4d5c6`/`ceccd516`; no `auth.*`/extension references — a bare cluster suffices, no full migration history). Prisma connects as **`service_role` with no password** (`serviceUrl.username='service_role'`), and psql as `user` with no password and no `PGPASSWORD` in the spec → **host auth must be `trust` on 127.0.0.1** (Prisma cannot use `.pgpass`/`PGPASSWORD`). Case 2 spawns `node -r ts-node/register -e … ` with cwd = repo root, `TS_NODE_TRANSPILE_ONLY=true` (needs `ts-node` 10.9.2 — present). Service budgets: `$transaction maxWait/timeout 5000`, `lock_timeout 2s`, `statement_timeout 4s`; case 4 asserts rejection < 5000 ms.

## 3. Dependency / worktree requirements
- Tree with C1 product + tests and a **generated Prisma client containing `ImportIntent`**: only the C1 builder's `worktrees/s7-c1` has it today (`node_modules/.prisma/client/index.d.ts` `bf679a16…`, 1173 `ImportIntent` occurrences, engine `a2924eab…`, installed record `05bc530a…`; jest 30.4.2 / ts-jest 29.4.9 / @prisma/client 6.19.3 / ws 8.21.0). Any other worktree would need the C1 builder's `prisma generate` step (its exclusive generator ownership) — not this preparer's.
- `jest.rls.config.js` (blob `44c96915`) `testMatch` includes `test/rls-*.spec.ts`; base `jest.setup.ts` (`7dd7e7e7`) sets Supabase/DATABASE_URL placeholders only. `src/prisma.service.ts` unchanged from foundation (`af24f743`); `PrismaService({datasources})` constructor path used by the spec.
- Run must occur **after** the C1 commit (or on the retained staged tree) — the spec bytes are identical either way (`1dd9dece` / formatter-only `cc3b0e4d`).

## 4. Fixture: what exists, what is missing (concrete gap, minimum closure — NOT built here)
Existing: PG 17.6 dist `/home/user/pg17/dist` (postgres `23cd1748…`, initdb `b7db9bc2…`, pg_ctl `af53d826…`; bins = initdb, pg_ctl, postgres only), S5 fixture `execution/s5-r4/s5-fixture.sh` (`3a7d57bf…`), S5 runner/launcher (lane-bound to stage list guard→oldroot→init→start→preflight→bootstrap→live etq0). S5 stopped cluster `/home/user/pg17/clusters/s5` retained (pg_control `09ba3f27…`, mtime 20:43:12Z, no postmaster) — **must stay untouched**; `clusters/c1-builder` absent; port 55439 free; 0 postgres processes.

**Gap:** no existing script provisions the C1 target. `s5-fixture.sh` cannot be reused unchanged: (a) constants `PORT=54325 SUPER=s5_super MARKER DATA=clusters/s5 LOG SOCK` must be re-bound; (b) its `initdb -A scram-sha-256 --pwfile` line must become `-A trust` without pwfile (spec forbids URL passwords and Prisma cannot supply one) — a one-line logic change, not a constant; (c) its standalone-refusal guard (`S5_RUNNER_PID` must name a live `run-proof.sh`) blocks any non-S5 caller; (d) it has no database-creation step (S5 created the DB in bootstrap). The S5 runner's stage graph is E/T-Q0-specific and cannot be substituted into a C1 run without effectively writing a new runner.

**Minimum closure (for reviewer/parent disposition):** one C1 variant of `s5-fixture.sh` produced by exact substitution only — `PORT=55439`, `SUPER=user`, `MARKER=c1-disposable-pg17`, `DATA=/home/user/pg17/clusters/c1-builder/pg-data`, `LOG=/home/user/pg17/clusters/c1-builder/pg.log`, `SOCK=/home/user/pg17/run/c1`, `initdb -A trust` (drop `PASS`/pwfile lines), guard line re-pointed at the C1 caller (or removed for a single lock-holding caller); everything else (fresh-init-only refusal, marker checks, bounded stop, survivor detection, destroy semantics) byte-identical. Plus **one** database-creation command using the existing client: `psql -X -v ON_ERROR_STOP=1 postgresql://user@127.0.0.1:55439/postgres -c 'CREATE DATABASE c1_setup_disposable'`. No other new logic. If the reviewers prefer, the variant can be diffed against `3a7d57bf` to show only those lines changed.

## 5. Minimum execution sequence for ONE C1 proof (frozen; granted separately, run once, no retry)
Caller holds the canonical lock (`flock -n 9` on `execution/test-validation.lock`, 75 = busy → do not start), records raw exits, stops at first nonzero. From the C1 worktree root (`W=/home/user/workspace/worktrees/s7-c1`, must show HEAD = the C1 commit or the retained `87798e74` index with `porcelain` unstaged 0):
```
# env for every step
export GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1 NODE_OPTIONS=--max-old-space-size=4096 CHECKPOINT_DISABLE=1 \
       PRISMA_HIDE_UPDATE_MESSAGE=1 npm_config_offline=true npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false
export C1_SETUP_TEST_DATABASE_URL=postgresql://user@127.0.0.1:55439/c1_setup_disposable \
       C1_TEST_PSQL=/usr/bin/psql C1_TEST_DATA_DIRECTORY=/home/user/pg17/clusters/c1-builder/pg-data \
       C1_SETUP_DISPOSABLE_ACK=c1-local-only-55439
# 1 preflight (read-only): [ ! -e /home/user/pg17/clusters/c1-builder ]; ss -ltn | grep -c ':55439 ' == 0; pgrep -cx postgres == 0;
#   /home/user/pg17/clusters/s5/postmaster.pid absent; sha256 of s5 postgresql.conf and global/pg_control recorded (must be unchanged at the end)
# 2 c1-fixture init      (bound 60 s)  -> expect  *_FIXTURE_INIT_OK data=/home/user/pg17/clusters/c1-builder/pg-data port=55439 superuser=user
# 3 c1-fixture start     (bound 60 s)  -> expect  *_FIXTURE_START_OK pid=…
# 4 psql -X -v ON_ERROR_STOP=1 -At postgresql://user@127.0.0.1:55439/postgres -c 'CREATE DATABASE c1_setup_disposable'   (bound 30 s)
# 5 identity check (read-only): psql … -At $C1_SETUP_TEST_DATABASE_URL -c 'SHOW data_directory' == $C1_TEST_DATA_DIRECTORY; 'SHOW server_version_num' == 170006
# 6 the proof (bound 600 s; WORK budget), exactly once:
cd $W && ./node_modules/.bin/jest --config jest.rls.config.js test/rls-c1-setup.spec.ts --runInBand --ci
# 7 c1-fixture stop      (bound 45 s)  -> expect  *_FIXTURE_STOP_OK ; then: 0 postgres processes, port 55439 free, data dir RETAINED (no destroy)
# 8 post: s5 cluster hashes unchanged; C1 worktree porcelain unchanged (spec writes nothing to the tree); logs + sha256 into the receipt
```
Not passed: `--testTimeout` (the spec carries its own 30 s/45 s; others use the repo default 10 s). S5's etq0 precedent used `--testTimeout=180000` — if the parent wants parity, that is a command option, not a test change; record either way. No `--forceExit`, no `--detectOpenHandles`, no coverage.

## 6. Frozen acceptance for the single run (no new criteria; observed as-is)
- Guards pass: none of `requires an explicitly acknowledged disposable cluster`, `not the permitted disposable database`, `server identity mismatch` in the log.
- `Test Suites: 1 passed, 1 total`; **`Tests: 22 passed, 22 total`**; 0 skipped/todo/failed; jest rc 0; `PG17_…`-style identity lines are not emitted by this spec (none expected).
- Fixture: init/start/stop raw rc 0; stop leaves 0 postgres processes and no `postmaster.pid`; data dir `/home/user/pg17/clusters/c1-builder/pg-data` retained; `clusters/s5` byte-unchanged (conf `2b6758f5…`, pg_control `09ba3f27…`) and never started.
- Bounds respected (step bounds above; outer ≤ 900 s); no survivors, no QUARANTINE, lock released; any timeout/refusal/survivor recorded as observed, never relabelled.
- Not covered by this proof and not claimed: E/T-Q0 (S5 fresh51), S1/S2/S3 composed suites, C1 unit/contract suites (hook/targeted-jest lane), migration drift on a full history.

## 7. Prerequisites before a grant
1. C1 builder finalises the formatted candidate (`87798e74`) and hook commit; the run uses that worktree (only place with the `ImportIntent` client).
2. Parent/reviewers dispose of §4's minimum closure (fixture variant + trust auth on loopback + one CREATE DATABASE) — or name an alternative existing tool.
3. Heavy slot transfer; S5 cluster remains stopped; the S6 lane is idle.
4. Runtime env exactly as §5; the executor freezes the fixture variant's sha256 and the `diff` vs `3a7d57bf` in its packet before launch.

## 8. Not done / not claimed
No fixture written, no cluster, no database, no psql/jest/node/prisma invocation, no probe beyond `ls`/`ss`/`pgrep`/`sha256sum`/git reads; S7/S5/S6/C1-builder paths untouched. Release: no hold, no lock, no process.
