# REVIEW_B_V2 — S8-F binding v2, independent reviewer B (F-REV-B-V2)

Reviewer: T4 independent non-builder reviewer B (read-only; sole writer of this file). Reviewer A's v2 report was NOT read.
Assignment: Bradley/parent mail 14:37 PT (F-REV-B-V2). Written 2026-09-25 ~14:55 PT. No git commit; no product, gate, test, hook, PG, install, lock or remote mutation.
Object: `tgp-private-evidence/execution/64e33dc7/s8f/binding/v2/` reviewed against immutable v1 (`../v1/`), the runtime receipts `tgp-private-evidence/execution/1910a060/runtime/`, the clone `W=/home/user/workspace/worktrees/1910a060-s8f`, and the PG dist `/home/user/workspace/execution/1910a060/runtime/pg17/dist`.
Method: `sha256sum`, `diff`, `git rev-parse|status|diff --name-only|ls-files` with `GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1`, `ldd`, `ss -ltn`, `pgrep`, `stat`, `rg`. Not run: npm, jest, tsc, prisma, initdb/pg_ctl/postgres, the binding itself.

**VERDICT: BINDING v2 — GO for ONE proof run** (source verdict from REVIEW_B.md unchanged; this is a binding verdict, not acceptance or proof). No class A or B finding. Class C items recorded in §7; one reviewer-side disclosure in §7 C-V2-0.

---

## 1. Identity of the reviewed object

| file | sha256 (BINDING.sha256, re-verified 9/9 OK) |
|---|---|
| s8f-pg-proof.sh | 3e43c8c8697c245700f581823816e5a43e1419f1b7739d8651d53b08b6a37f4c |
| s8f-fixture.sh | 4983477330f11597de5b3350c45aaf9dd1ff0bc4278b00cec980f7d6f11e8f5f |
| PINS.txt / README.md | d99b0827… / 6c5ef860… |
| v1-to-v2-proof.diff / v1-to-v2-fixture.diff | b366bd38… / b66a3106… |
| v1-to-v2-proof.patch.py / v1-to-v2-fixture.patch.py | 0cdca85d… / c0444209… |
| tool-pins-reverify.txt | a4725601… |

v1 (`../v1/BINDING.sha256`) re-verified 7/7 OK — v1 untouched (driver e4b73c59…, fixture 88e8b2f3…).

**No undisclosed change:** I recomputed `diff -u ../v1/s8f-pg-proof.sh s8f-pg-proof.sh` and `diff -u ../v1/s8f-fixture.sh s8f-fixture.sh` (headers stripped) and both are byte-identical to the published `v1-to-v2-proof.diff` / `v1-to-v2-fixture.diff`. v2 = v1 + exactly the published diffs.

## 2. Repo-content pins — identical to v1 (verified in W, not from PINS.txt)

| pin | value in v2 runner | verified in W (`git rev-parse HEAD:…`) |
|---|---|---|
| BASE_HEAD / BASE_TREE | 1c10e2a1 / aa160557 | HEAD^ = 1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47, tree aa160557577f821b6f284435d22037e046991202 ✓ |
| EXPECT_HEAD / EXPECT_TREE | e1ec2fec / 2fe0201f | e1ec2fecb71f315b6721d426ba0dacb84f304498 / 2fe0201ff132dfdc53ea82b3f26ed0fc8d1c65d6 ✓, branch `exec1910/s8f`, base is ancestor ✓ |
| EXPECT_SPEC_BLOB | 77785ec5 | 77785ec5fa3d0bb15731ba7787c4ede4968eb51d ✓ |
| EXPECT_BOOTSTRAP_BLOB (100755) | 5ac2753b | 5ac2753bdc0498899d1a9eef297ef4acc467ccb8, mode 100755 ✓ |
| EXPECT_DB_BLOB / PGH_BLOB / WORKER_BLOB | aeff4cb0 / a8acd231 / aa35e7e2 | ✓ ✓ ✓ |
| NEW EXPECT_SCHEMA_BLOB | 2e328bbc | 2e328bbcab0c902c6adb55dfb5ee172defc5f698 ✓ (same blob as v1's accepted-file list; now an explicit anchor) |
| 7 accepted-at-base file pins (g2-s8c-db a7d67217, g2-s8c-bootstrap 7c3fba47, rls-g2-s8c.spec 9d701783, src/scout/reconstruct/native tree dfd8ef66, schema 2e328bbc, supabase-shim 0f99f924, jest.rls.config 44c96915) | unchanged from v1 | all 7 equal at HEAD ✓ |
| 17-path delta regex | unchanged | `git diff --name-only 1c10e2a1 HEAD` = 17 paths, 0 under `prisma/` ✓ |
| 172 migration dirs | unchanged | 172 ✓ |
| NEW EXPECT_TESTS=11 | — | `grep -cE '^\s*it\('` on test/rls-g2-s8f.spec.ts = 11; `.skip/.only` = 0 ✓; no `it.each` |

Lock path, PORT 55643, DBNAME, ADMIN, FIXPASS, marker `s8f-disposable-pg17`, `G2_S8F_SERVER_VERSION=170006`, JEST invocation: unchanged from v1.
`jest.rls.config.js` (blob 44c96915) `testMatch` includes `<rootDir>/test/rls-*.spec.ts` → the spec path passed on the command line is selectable ✓. Worker (aa35e7e2) exposes `roster`/`entities` actions used by the spec ✓.

## 3. Environment pins — every one matches disk now (hashed by me, read-only)

| pin | v2 value | on disk now |
|---|---|---|
| pg17/dist/bin/postgres | 23cd1748…bf873a | equal ✓; `--version` → `postgres (PostgreSQL) 17.6` |
| pg17/dist/bin/initdb | b7db9bc2…0882a | equal ✓ |
| pg17/dist/bin/pg_ctl | af53d826…9401 | equal ✓ |
| PSQL=/usr/lib/postgresql/18/bin/psql | d1108fdb…ef67 | equal ✓; `--version` → `psql (PostgreSQL) 18.6 (Ubuntu 18.6-0ubuntu0.26.04.1)` → runner regex `^psql \(PostgreSQL\) 18\.` matches ✓. `/usr/bin/psql` → pg_wrapper (a200e38c, v1's pin) is no longer the pinned object — v1 CB1 closed. |
| node (`readlink -f $(command -v node)` = /usr/local/bin/node) | a03953a7…dddc | equal ✓; v20.20.1 |
| W/node_modules/.package-lock.json | 05bc530a…6a44 | equal ✓ |
| W/node_modules/.prisma/client/index.d.ts | 9042e713…dcc6 | equal ✓; contains `ImportNativeProvenance` (531 hits) and `target_kind` (30) |
| W/node_modules/.prisma/client/schema.prisma | b8439203…abf3e | equal ✓; `model ImportNativeProvenance ` 1, `target_kind` 1 → v2 CB2 greps will pass |
| W/prisma/schema.prisma | 0eb41f9a…4015 | equal ✓ (= blob 2e328bbc) |
| W/package-lock.json | b7fed5ed…9c55 | equal ✓ |
| EXPECT_FIXTURE_SHA | 49834773… | = sha256 of binding/v2/s8f-fixture.sh ✓ |

Clone W: standalone (own `.git`, `git worktree list` shows only itself), `status --porcelain --untracked-files=all` empty, no MERGE_HEAD, `.git/hooks/{pre-commit,commit-msg}` are lefthook stubs, `node_modules` is a real directory inside W (not a symlink), `origin` pushurl `no_push://disabled-by-RT-NEW-1`.
PG dist: `bin/ lib/ share/postgresql/` present (postgres.bki, pg_hba.conf.sample), `ldd` of postgres/initdb/pg_ctl (with `LD_LIBRARY_PATH=dist/lib`) and of psql 18 resolve fully; `C.utf8` locale present (fixture uses `--locale=C.UTF-8`). `pg17/PROVENANCE.txt` `result=success`, artifact = zonky embedded-postgres-binaries-linux-amd64 17.6.0 (maven sha1 8163322…; jar sha256 23da5a04…; txz 26fa6334…) and the three binary hashes equal the predecessor's recorded values — a same-bytes statement only, not an old-runtime-instance claim (correctly worded in PINS.txt and RUNTIME_SETUP_RECEIPT §4).
Runtime receipts: `MANIFEST.sha256` verifies with 0 non-OK lines (33 entries); `raw/prisma-generate.out` shows the explicit `prisma generate` (v6.19.3) exit 0; `raw/rt-setup.sentinel` and `raw/pg17-fetch.sentinel` present; receipt §3/§4 values agree with everything I measured.

Live state at review time: lane `$RUNTIME_ROOT/proof-s8f-v2/` absent (no clusters, no socket dir); `$RUNTIME_ROOT/clusters/` absent and no `proof-*/clusters/*` lanes exist under the 1910a060 root; `ss -ltn` shows 0 listeners on :55643; `pgrep -cx postgres` = 0; `binding/v2/run/` absent (no sentinel); lock file `/home/user/workspace/execution/test-validation.lock` exists, inode 667698 (= PINS.txt, LOCK_ESTABLISHED.txt), 0 bytes. At my check the lock was **not** held (S9-A had evidently finished or not yet started) — see C-V2-0.

## 4. Control logic preserved (v1 → v2 delta is confined to what §2/§3 describe)

Per the recomputed diff, the only runner changes are: `D`→binding/v2; `RUNTIME_ROOT`, `W`, `LANE`, `SOCK` re-pointed to the 1910a060 root / `proof-s8f-v2`; `EXPECT_FIXTURE_SHA`; `PSQL` variable + `EXPECT_PSQL_SHA` + major-18 version assertion; `G2_S8F_PSQL=$PSQL`, `psqlq` uses `$PSQL`; new `EXPECT_SCHEMA_BLOB` check; two new CB2 greps; new `EXPECT_TESTS` assertion (fail 72) after jest; comments (CB3, "genuine npm ci"). Fixture changes are the three lane constants and comments only. Unchanged: sentinel-before-lock, `flock -n` on fd 9 (append-open, never deleted), preflight (`pgrep -cx postgres` 0, port free, lane absent, other lanes hashed pre/post and never started), identity block (HEAD/tree/blob/mode/17-path/172-migrations/clean-tree/hooks), fixture hash gate, init→start→bootstrap→jest→stop→post sequence, `fail()` bounded stop when STARTED=1, post checks (no postmaster, port free, W still clean at same HEAD, other lanes unchanged), receipts hashing, sentinel written in `finish()`.

Every refusal present in v1 is present in v2 with the same or stricter effect; nothing was weakened. New assertions only add failure paths (rc 70/72).

## 5. CB1 / CB2 / CB3 / test-count

- **CB1 (psql)**: implemented — real binary pinned by sha256, `--version` asserted major 18 (client 18 against server 17.6 is fine; harness uses `G2_S8F_PSQL` for `psql`-driven bootstrap steps). Closed.
- **CB2 (client ↔ schema)**: implemented — `HEAD:prisma/schema.prisma` blob asserted = 2e328bbc, generated client index.d.ts and client schema hashed, plus `ImportNativeProvenance` / `target_kind` greps in both. Correspondence is still by pins + greps rather than regeneration (regeneration is forbidden here); the runtime receipt records that postinstall and an explicit re-generate produced the identical 9042e713 hash. Adequate for one proof. Closed as a class-C residual only.
- **CB3 (hooks)**: comment-only; runner checks hooks are installed now, evidence that e1ec2fec was hook-produced is the original gate log (`COMMIT rc=0 hook_lines=8`). This is the correct division; nothing the runner can prove retroactively. Acceptable.
- **Test count**: `EXPECT_TESTS=11` matches the spec's 11 `it()` (stage0:1, stage1:3, stage2:3, stage3:2, stage4:2), no `.skip/.only/it.each`; regex `^Tests: +11 passed, 11 total` matches Jest 30 summary format and correctly rejects any `skipped`/`failed` variant. Implemented without weakening.

## 6. Safety

- **Cleanup/stop**: fixture `stop` = `pg_ctl -m fast -w -t $STOP_TIMEOUT`, survivor/postmaster check, never discards a stop failure; runner `fail()` attempts bounded stop only if STARTED=1; `destroy` never invoked by the runner (data dir retained). ✓
- **Retained data dir**: lane `proof-s8f-v2/clusters/s8-f` retained after run; FRESH INIT ONLY — init refuses if data dir exists; other lanes hashed, never started/adopted. ✓
- **Port free / no shared server**: preflight requires 0 `postgres` processes and no :55643 listener; server listens 127.0.0.1 only, cluster_name marker required by start/bootstrap; committed guard refuses 55511/55641/55642 and requires the marker + DB marker. ✓
- **Writes only inside lane**: fixture writes only `$LANE` and `$SOCK` (under `proof-s8f-v2/`); runner writes receipts only under `binding/v2/run/`; `npm_config_cache`/`XDG_CACHE_HOME` pointed under RUNTIME_ROOT; lock opened append-only, never written; W must be clean and at the same HEAD post-run. Data dir cannot be inside `$PGHOME` (refused). See C-V2-2/C-V2-3 for two harmless outside-lane byproducts. ✓
- **Exactly-once sentinel**: `[ -e $SENT ] && exit 76` before the lock; sentinel written in `finish()` on every terminated path (success or `fail`). A lock-busy refusal (rc 75) exits before `finish` and does NOT consume the run — correct. ✓

## 7. Findings

No class A. No class B.

Class C (record, continue):

- **C-V2-0 (reviewer disclosure, not a binding defect)**: while checking lock state I ran `flock -n <lock> true`, which momentarily acquired and released the canonical lock (reported "free"). No content, inode or state changed (inode still 667698, 0 bytes). The assignment said not to take the lock; this was an unintended sub-second acquisition. Recorded for the ledger.
- **C-V2-1**: precondition/identity failures (rc 70–72) go through `finish()` and write the sentinel, so a refusal before any cluster exists still consumes the single run and would require a v3 binding. Same as v1; deliberate fail-closed design; recorded so the parent schedules the run only when the lock is free and `pgrep -cx postgres` = 0 (an S9-A postmaster or lock hold at launch → rc 75 without sentinel, but a live postmaster with a free lock → rc 71 with sentinel).
- **C-V2-2**: `mkdir -p "$R"` (binding/v2/run) executes before the sentinel/lock checks — a trivial directory creation in the evidence tree outside the lock. Harmless.
- **C-V2-3**: Jest's default `cacheDirectory` (`/tmp/jest_*`) is outside the lane; ts-node/prisma caches are redirected under RUNTIME_ROOT. Harmless, not in W (post-run W cleanliness check guards the repo).
- **C-V2-4**: the 11 spec cases were `skipped` in the historical 33/33 gate (666 passed / 11 skipped: no DB); this proof is their first live execution. A jest failure would be a source-behaviour outcome to be classified against the source, not a binding defect.
- **C-V2-5**: v2 PINS.txt header cites "REVIEW_A §5.3 / REVIEW_B §2.2" — the builder read both reviews (expected for closure); the binding itself carries no content from either beyond the environment re-pins and CB1–CB3.
- **C-V2-6**: CB2 residual — client↔schema equivalence rests on hash pins and greps plus the runtime receipt's deterministic re-generate; not re-derived by the runner (correctly, since `prisma generate` is out of scope for the proof).

## 8. Verdict

**BINDING v2: GO for ONE proof run** via `binding/v2/s8f-pg-proof.sh` under a separate parent grant, when the canonical lock is free and no postmaster is live. Repo-content pins are byte-identical to v1 and match W; all ten environment pins match disk now; control logic is v1's with only additive assertions; CB1/CB2/CB3/test-count implemented without weakening any refusal; cleanup/stop, retained lane, port, no-shared-server, in-lane writes and exactly-once sentinel are sound. This is a binding verdict only — not acceptance of S8-F and not proof.
