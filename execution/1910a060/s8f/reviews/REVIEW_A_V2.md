# S8-F Binding v2 Independent Review A (F-REV-A-V2)

- Reviewer: T4 independent NON-BUILDER reviewer A (same subagent as REVIEW_A.md; did not author v1, v2, the runtime setup or the candidate).
- Written: 2026-09-25 ~21:50Z. Sole write of this assignment. No git commit.
- Reviewed: `tgp-private-evidence/execution/64e33dc7/s8f/binding/v2/` against immutable v1 and against the ACTUAL current environment (`execution/1910a060/runtime/*` receipts, clone `/home/user/workspace/worktrees/1910a060-s8f`, PG dist `/home/user/workspace/execution/1910a060/runtime/pg17/dist`). Reviewer B's v2 report was not read.
- Method limits honoured: no npm/jest/tsc/prisma, no initdb/PG start, no lock taken, no file written outside this report. Read-only inspection and re-hashing only. Disclosure: I ran `./node_modules/.bin/lefthook version` inside the clone once (prints `2.1.9`, no file writes); the clone was verified clean (`git status --porcelain --untracked-files=all` = 0 lines) afterwards. Scratch work from the earlier review remains under `/tmp` only.

## 0. Verdict

**BINDING v2: GO for ONE proof run** under the parent's separate single-run grant, at a moment when the canonical lock is free.

- No class A or class B finding. Every repo-content pin is byte-identical to v1; every environment pin in v2 matches what is on disk now; every v1 refusal/control is preserved; the four class-C items (CB1, CB2, CB3, expected-test-count) are implemented as additional refusals, none weakened.
- Current lock state: the S9-A gate holds `execution/test-validation.lock` (expected). If the runner were started now it would exit 75 at line 75 (`flock -n` fails) BEFORE `finish` is defined, so no sentinel is written and the single run is not consumed. Exactly-once is intact: `binding/v2/run/` does not exist yet.
- This is a binding-readiness verdict, not a prediction that the proof passes and not an acceptance of S8-F. Class C notes in §6.

## 1. Integrity of the v2 package

- `BINDING.sha256` (9 entries) → `sha256sum -c` all OK. `s8f-pg-proof.sh` = `3e43c8c8697c245700f581823816e5a43e1419f1b7739d8651d53b08b6a37f4c`; `s8f-fixture.sh` = `4983477330f11597de5b3350c45aaf9dd1ff0bc4278b00cec980f7d6f11e8f5f` (equals `EXPECT_FIXTURE_SHA` inside the runner and in PINS.txt).
- Independent `diff -u ../v1/s8f-pg-proof.sh s8f-pg-proof.sh` is byte-identical to the shipped `v1-to-v2-proof.diff`; the fixture diff body is identical to `v1-to-v2-fixture.diff`. The complete v1→v2 delta is therefore exactly what §3–§4 below review; there are no hidden edits.
- v1 `BINDING.sha256` re-verified 7/7 OK earlier in this session; v1 untouched.

## 2. Repo-content pins — identical to v1 and true in the clone

Re-derived in `/home/user/workspace/worktrees/1910a060-s8f` (read-only, `GIT_NO_LAZY_FETCH=1`):
- HEAD `e1ec2fecb71f315b6721d426ba0dacb84f304498`, tree `2fe0201ff132dfdc53ea82b3f26ed0fc8d1c65d6`, `HEAD^` = `1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47`, `HEAD^^{tree}` = `aa160557577f821b6f284435d22037e046991202`; `merge-base --is-ancestor` OK; branch `exec1910/s8f`; own `.git` directory (standalone clone, not a shared worktree); `user.name/email` = Bradley Gleave / bradley@bradleytgpcoaching.com; push URL `no_push://disabled-by-RT-NEW-1`; no `MERGE_HEAD`; porcelain clean (0 lines, untracked included).
- Five S8-F proof-file blobs, worker blob `aa35e7e2`, seven accepted-file blobs (`g2-s8c-db.ts a7d67217`, `g2-s8c-bootstrap.sh 7c3fba47`, `rls-g2-s8c.spec.ts 9d701783`, `src/scout/reconstruct/native dfd8ef66`, `prisma/schema.prisma 2e328bbc`, `supabase-shim.sql 0f99f924`, `jest.rls.config.js 44c96915`): **all 12 equal** at HEAD. Bootstrap mode `100755` in index and on disk.
- `git diff --name-only 1c10e2a1 HEAD | wc -l` = 17; `-- prisma` = 0; 172 migration dirs; `prisma/schema.prisma` sha256 `0eb41f9a…`; `package-lock.json` sha256 `b7fed5ed…`.
- `EXPECT_TESTS=11` independently confirmed from the candidate object (scratch clone): `grep -cE '^\s*it\('` = 11; `.skip(`/`.only(`/`it.each`/`test(` = 0 in `test/rls-g2-s8f.spec.ts` @ `e1ec2fec`. With `jest.rls.config.js` (`testMatch` `test/rls-*.spec.ts`) plus the positional path filter, exactly one suite is selected.
- PINS.txt repo-content section matches v1 PINS.txt value-for-value; `EXPECT_SCHEMA_BLOB=2e328bbc…` is a new explicit anchor for a value v1 already pinned in the accepted-file list.

## 3. Environment pins — every one matches disk now

Re-hashed by me at ~21:45Z (all equal to the runner's constants and to `tool-pins-reverify.txt`):
- `RUNTIME_ROOT=/home/user/workspace/execution/1910a060/runtime` exists, `readlink -f` = itself; contents `npm-cache pg17 tools xdg-cache`; **no** `clusters/` and **no** `proof-*/` (so other-lane hashing yields an empty set, consistently pre/post). `pg17/PROVENANCE.txt` has `result=success` and lists the same three binary hashes.
- `pg17/dist/bin/postgres 23cd1748…`, `initdb b7db9bc2…`, `pg_ctl af53d826…`; `postgres --version` = `postgres (PostgreSQL) 17.6` (server_version_num 170006 — matches `G2_S8F_SERVER_VERSION=170006`, the identity-stage literal and the bootstrap default). Full dist manifest `raw/pg17-dist-files.sha256` (1005 files, sha256 `2c9d8a49…`) verified with `sha256sum -c` from the dist root: **rc 0, all files match**. `lib/` carries libpq.
- CB1: `PSQL=/usr/lib/postgresql/18/bin/psql` sha256 `d1108fdb…`; `--version` = `psql (PostgreSQL) 18.6 (Ubuntu 18.6-0ubuntu0.26.04.1)` → the new `^psql \(PostgreSQL\) 18\.` assertion passes. The pg_wrapper hash is no longer a pin; `/usr/bin/psql` is not referenced anywhere in v2 (grep confirms).
- `node` `/usr/local/bin/node` sha256 `a03953a7…`, v20.20.1.
- Clone dependency tree: `node_modules` is a real directory resolving inside `W`; `.package-lock.json 05bc530a…`; `.bin/jest`, `.bin/ts-node`, `.bin/prisma` executable; prisma / @prisma/client 6.19.3.
- CB2: `.prisma/client/index.d.ts 9042e713…`, `.prisma/client/schema.prisma b8439203…`; greps: client schema contains `model ImportNativeProvenance ` (1) and `target_kind` (1); `index.d.ts` contains `ImportNativeProvenance` (531) and `target_kind` (30); `HEAD:prisma/schema.prisma` = `2e328bbc` — all four new refusals pass on disk. Generated `index.js 6fd5e6ef…` and engine `libquery_engine-debian-openssl-3.0.x.so.node a2924eab…` match the receipt. `cmp` of client schema vs source schema differs in bytes (generator normalisation) → the runner logs the NOTE and continues, as in v1.
- CB3: hooks `.git/hooks/pre-commit e21bece6…`, `commit-msg 277018c4…`, both contain `lefthook` (32 lines each), lefthook 2.1.9 — the current-state check passes; hook evidence for `e1ec2fec` itself is correctly attributed to the original gate log (`COMMIT rc=0 hook_lines=8`), not to this runner.
- Lock: `/home/user/workspace/execution/test-validation.lock` inode `667698` = `LOCK_ESTABLISHED.txt`; v2 commentary corrected from the stale `674373`. The runner never pins the inode (logs only) — unchanged.
- Lane: `PORT=55643` — `ss -ltn` shows 0 listeners; `pgrep -cx postgres` = 0; `$LANE` (`proof-s8f-v2/clusters/s8-f`) and `$SOCK` (`proof-s8f-v2/run/s8-f`) absent; `binding/v2/run/` absent (no sentinel). 55643 is outside the committed guard's refused-port set and equals the confirmation string `g2_s8f_disposable:55643`.
- Runtime receipts: `execution/1910a060/runtime/MANIFEST.sha256` (33 entries) → `sha256sum -c` all OK; `RUNTIME_SETUP_RECEIPT.md` §4 values equal my measurements above; `raw/` contains the npm-ci, prisma-generate, pg17-fetch logs and sentinels referenced. The receipt's "same bytes as the predecessor artifact" statement is a hash statement only and v2 makes no old-runtime-instance claim.

## 4. Control logic preserved (line-by-line against v1)

The v2 delta touches only: header comments; `D`, `RUNTIME_ROOT`, `W`; `EXPECT_FIXTURE_SHA`; tool-pin block (adds `PSQL`, re-records `EXPECT_PSQL_SHA`, adds `EXPECT_SCHEMA_BLOB`, `EXPECT_TESTS`); `LANE`/`SOCK` to `proof-s8f-v2`; `G2_S8F_PSQL=$PSQL`; hooks comment (logic unchanged); node_modules comment (logic unchanged); four new CB2 refusals (`fail 70`); psql path/sha check now on `$PSQL` plus a new major-version refusal (`fail 70`); `PRECONDITIONS_OK` log uses `$PSQL`; `psqlq` uses `$PSQL`; new post-jest count refusal (`fail 72`). Nothing else differs.

Unchanged and verified present: once-only sentinel (`exit 76`), lock-present and `flock -n` fd 9 refusals (`exit 75`, pre-sentinel, no state change), placeholder refusal, head/tree/base-tree/ancestor/one-commit checks, blob pins, clean-worktree and MERGE_HEAD checks, prisma-delta-empty, seven accepted-file pins, 17-path count + allow-list regex, isolated real `node_modules`, schema/lock/client shas, jest/ts-node/prisma present, 172 migrations, PG binaries + 17.6, node sha + major 20, real runtime path, PROVENANCE, preflight (lane absent, socket dir empty, port free, `pgrep -cx postgres`=0, other lanes hashed), bounded stages (60/60/900/5×15/1500/75) inside outer `timeout -k 30 3600`, committed bootstrap without subcommand + `G2_S8F_BOOTSTRAP_OK` marker, identity stage (data_directory = `$LANE/pg-data`, 170006, cluster marker, DB marker, applied = 172), single jest invocation with the repo binary and `jest.rls.config.js`, rc gate, bounded fixture stop with data dir RETAINED, stop-state check (no postgres, port free, no postmaster.pid, data dir present), post checks (other lanes unchanged, porcelain sha unchanged, HEAD unchanged, generated client unchanged), receipts hashed, lock held through `finish`.

Fixture v2 = v1 with only `RUNTIME_ROOT`/`LANE`/`SOCK` constants and comments changed: runner-PID gate (`S8F_RUNNER_PID` must be a live `s8f-pg-proof.sh`), refuses data dir inside `pg17/dist` or historical `/home/user/pg17`, fresh-init only, marker-gated `start`/`destroy`, loopback only, `C.UTF-8`, bounded `-m fast` stop that never discards a failure, `destroy` refuses on survivor or any process referencing the data dir, fd 9 closed for children.

### 4.1 Class-C items — implemented without weakening
- **CB1 (real psql binary)**: pin moved to `/usr/lib/postgresql/18/bin/psql` with sha + major assertion; all psql calls (`psqlq`, `G2_S8F_PSQL` for bootstrap/harness) use the pinned path. Strictly stronger than v1.
- **CB2 (client provenance)**: adds `HEAD:prisma/schema.prisma == 2e328bbc` and four content greps on the generated client; the sha pins from v1 remain. Strictly stronger.
- **CB3 (hook evidence)**: refusal unchanged; comment now states truthfully what it proves. No weakening.
- **Expected test count**: `grep -qE "^Tests: +11 passed, 11 total" jest.log` after the rc gate; any skipped/failed/extra test changes the line (`N skipped, …`) and fails with rc 72, which (STARTED=1) triggers the bounded fixture stop before `finish`. Strictly stronger.

### 4.2 Exit / cleanup safety
- Pre-lock refusals (76/75) exit without sentinel or state change. Every post-lock failure goes through `fail` → bounded `stop` if this run started the postmaster → `finish` (receipts + sentinel + lock held to exit). Outer `timeout -k 30 3600` bounds a hang; the header truthfully states that cleanup is not guaranteed under an external kill and that observed terminal evidence governs.
- Data dir retained after stop; destroy is a separate grant. No shared server: preflight requires zero `postgres` processes and a free 55643 before init; fresh init only.
- Write footprint: `binding/v2/run/` (receipts), `$LANE`, `$SOCK`, `$RUNTIME_ROOT/{npm-cache,xdg-cache}` (env only; no npm runs), `mktemp` password file (removed), jest's default cache under `/tmp` (base `jest.config.js` sets no `cacheDirectory`), the disposable database. Nothing under `W` is written (post check verifies porcelain and client unchanged), nothing under v1, nothing under other lanes (none exist).

## 5. Class A / B findings
None. I looked specifically for: a weakened or removed refusal; an environment pin that does not match disk; a pin still pointing at the absent predecessor root; a path that could write outside the lane or into v1; a way to consume the sentinel on a lock-busy attempt; a way for the jest step to pass with fewer than 11 tests; a stale `/usr/bin/psql` reference; a hook or client check that could be satisfied by the wrong tree. Found none.

## 6. Class C (recorded; no action required before the run)
- **C-V2-1** `pgrep -cx postgres` = 0 is a host-wide requirement: any unrelated PostgreSQL server appearing on this host (e.g. another lane) makes preflight refuse (rc 71). By design; noted so a refusal is read correctly.
- **C-V2-2** The Prisma engine `libquery_engine-debian-openssl-3.0.x.so.node` on Ubuntu 26.04 has not been exercised by any test on this host (RT-NEW-1 ran no tests, correctly). A load failure would surface as worker/jest failure (fail-closed), never as a false pass.
- **C-V2-3** Stage bounds are inherited from v1 (init 60 s, bootstrap 900 s, jest 1500 s). `npm ci` took ~6 min on this 2-CPU host; `initdb` and 172 migrations are normally far below the bounds, but a timeout would be an environment refusal (rc 124), not a defect.
- **C-V2-4** `"$PSQL" --version | grep -qE …` under `pipefail`: single short write, SIGPIPE risk negligible.
- **C-V2-5** Jest cache lands in the default `/tmp/jest_*` outside the lane; harmless and standard, but not hashed pre/post.
- **C-V2-6** `RUNTIME_SETUP_RECEIPT.md` §5 designates the clone's `node_modules` as donor for later lanes; the runner's post check protects it during the proof, and RT-NEW-1 declares it read-only from 21:27:42Z. Any later donor copy must be `cp -a`, never a move.

## 7. Summary of what was independently measured
12/12 repo blob pins in the clone; 17-path delta; 0 prisma delta; 172 migrations; 11 `it(` / 0 skip-only in the live spec; 11/11 tool and file hashes in `tool-pins-reverify.txt`; 1005/1005 PG dist files; 33/33 runtime manifest entries; 9/9 v2 binding hashes; v1→v2 diffs reproduced byte-for-byte; port 55643 free; no postgres process; lane, socket, run dir and sentinel absent; lock inode 667698 present (held by S9-A now — expected).
