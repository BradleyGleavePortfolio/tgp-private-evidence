# S10-D D2 binding v1 — independent T3 review (EXEC-FA72EFB2)

Reviewer: T3 independent (D2_BINDING_REVIEW_GRANT.md). Parent session fa72efb2. Read-only: I did not run the runner, fixture, jest, bootstrap or PostgreSQL, did not take `/home/user/workspace/execution/test-validation.lock`, and made no edits or commits (this file is the only write).

## Verdict: **GO**

There are no A/B findings. I found no concrete way for the run to print `Tests: 8 passed, 8 total` without the D2 chain executing live on the s10d2 PG17 lane. I also found no binding-side reason, unrelated to the candidate, for the run to refuse or fail after `STARTED`. Everything I found is C (recorded below).

## Subject (verified)
`binding/v1`: `sha256sum -c BINDING.sha256` gives all 6 files OK.
- `d2-pg-proof.sh`: `9a2f8b36…67e8`, mode 755, 436 lines.
- `d2-fixture.sh`: `0fadafa3…c24b`, equal to `EXPECT_FIXTURE_SHA`.
- DELTA-from-s10c-v6.diff: `d8b7e042…6bd5e`.
- DELTA-fixture.diff: `f38f4e36…49b0`.
- README: `2f16b6c2…12e5`.
- Template v6: `s10c-pg-proof.sh` is `1bb4b564…483d` and `s10c-fixture.sh` is `c1b57239…92e7`, both as the README states. The v6 sentinel reads `RC=0 STAGE=done`.
- Both DELTA files are faithful. I regenerated `diff -u v6 v1` for each and ran `cmp` against the committed diff bodies: identical.
- `bash -n` passes on both files. The runner contains no `__FILL`/`__D2_` strings (count 0). `binding/v1/run/` does not exist, so the run is unconsumed.

## Delta review (emphasis items)
1. **Fresh clone and donor copy, ordered before STARTED.**
   - **Order.** The order is lock → inode check → `LOCKED` → under-lock rechecks (SRC HEAD/branch/clean, land ref, donor client, W absent, hooks) → preflight → `mkdir -- "$W"` (exclusive; `W_CREATED=1` only after it succeeds) → clone → checkout → clone verification → `cp -a` → node_modules verification → `CLONE_READY` → O_EXCL `STARTED`.
   - **Failures before STARTED.** Every `fail` before STARTED goes to `refuse()`. It writes no STARTED and no sentinel, and it removes W only if this run created it.
   - **Consuming handlers.** `LOG`, `finish()` and `fail()` are redefined to the v6 consuming form immediately after STARTED.
   - **Mechanics.** The clone and checkout lines are byte-identical to s11a1 v3 L248–249. That run logged `CLONE rc=0` / `CHECKOUT rc=0` / `CP_A rc=0` and its sentinel reads `RC=0 STAGE=done`. The `cp -a` line is also identical (L257).
   - **Net effect.** The ordering only makes refusals cheaper. It adds no way to pass without proof.
2. **Dropped retained s10-b lane requirement; added refused port 55648.**
   - `clusters/s10-b` is absent in this runtime, so the v6 must-exist check would refuse forever. Dropping it is correct.
   - If an s10-b lane appears, it is still refused as the lane, checked for a postmaster.pid before and after, and fingerprinted by the generic other-lane loop.
   - `clusters/s11` holds logs only, so its fingerprint is `ABSENT:ABSENT` and it has no postmaster.pid. `run/s11` is empty. There are no `proof-*` dirs. Preflight will not refuse on these.
   - Port 55648 was added in both the runner and the fixture, including the fixture `case` literal that the runner greps for.
3. **FROZEN exception.**
   - The FROZEN file sha is `e9c71f09…` and it lists 29 entries.
   - I ran the loop myself against HEAD 144269d1. All 29 match, with `manifest-registry.spec.ts` substituted by `9b5de374…`; its a2c74e90 FROZEN blob was `48ad91ea…`.
   - The exception is scoped to one path, and the exact 8-path pure-add delta independently forbids D2 touching it.
4. **The single jest command.**
   - The command is `jest -c jest.config.js --runInBand --ci --runTestsByPath test/scout/s10/s10-unseen.pg.spec.ts`. The file matches `roots` (`<rootDir>/test`) and `testRegex` (`\.spec\.ts$`), and it is not matched by `testPathIgnorePatterns` (only `test/rls/` and `test/rls-*.spec.ts`).
   - I re-ran the spec-shape greps read-only on `git show HEAD:<spec>`:
     - 8 `it(` lines and 0 `test(` lines;
     - LIVE line = 1, suite line = 1, `^suite(` = 1, and `LIVE` appears on exactly 2 lines;
     - BADPAT finds no match;
     - the pg-harness and harness `require` lines are each present once.
   - **Pass without proof is closed.** If the suite skipped, jest would print `8 skipped`, and the `^Tests: +8 passed, 8 total` + `1 passed, 1 total` + PASS-line checks would fail. The spec has no `if (!LIVE) return` or early-return path. Every case runs `chain()` against `lane.sql`/Prisma on the lane.
5. **Donor client = expected client (inversion).**
   - The donor shas are `.package-lock.json` = `05bc530a…`, `index.d.ts` = `2c819c8a…` and client `schema.prisma` = `aca7a558…`. All three equal the pins and the rt-setup `NM_OK` line. Prisma is 6.19.3, and the donor's three S10-B models are present.
   - `aca7a558` is the same client-schema sha the v6 template's in-clone generate produced from the same S10-B schema `d6d01f54`. The client-copy vs repo-schema diff is Prisma formatting only.
   - The inversion is therefore correct. The bootstrap still verifies the candidate client structurally (`CANDIDATE_CLIENT_VERIFIED dir=$W/…`).
6. **Pins vs live bytes (SRC = worktrees/fa72-d2).**
   - **Commits and refs:**
     - HEAD = `144269d1…`, tree = `a0bc3c09…`;
     - HEAD^ = `7fdcbc04…`, whose tree is `a802231e…`; `rev-list --count` = 1;
     - `symbolic-ref` = `refs/heads/fa72/d2-r1`, and `origin/land/s10d2` = `144269d1…`.
   - **Delta:** `diff --name-status` shows exactly the 8 paths, all `A` and all mode 100644. The 8 blobs equal the pins (4e21d522 / 6b8695c8 / 94dcc819 / 4d5bf92e / 94e7f567 / 90d644b4 / 41df91ec / 074b0fa0).
   - **Worktree:** porcelain is empty, `core.hooksPath` is unset, and the hooks path is `.git/hooks`.
   - **Hooks:** the shas are `54aa5cd8…` / `dc998a5e…`. Both files are regular files and both contain lefthook.
   - **Contract and landed specs:** the contract blob is `1a5deca5` at both BASE and HEAD. The s10c spec blob is `50a0deae`.
   - **Prisma:**
     - the migrations tree is `7b6fe0ed` at BASE and HEAD: 173 dirs, the last being `…_scout_run_observation_expand`;
     - the package-lock sha is `b7fed5ed…` and the schema sha is `d6d01f54…`;
     - a2c74e90 and a4af8e33 are both ancestors of BASE;
     - the diff since a2c74e90 over prisma, manifests and g2-s10b-* is empty;
     - the prisma delta vs a4af8e33 is schema plus the S10-B pair;
     - the manifest diff vs a4af8e33 is empty.
   - **S10-B harness blobs:** all 10 equal the pins at HEAD.
   - **Tools:** the postgres/initdb/pg_ctl/psql-18/node shas equal the pins. PROVENANCE says `result=success`, and node is v20.20.1.
   - **Runtime state:** the lock inode is 686480, and W `worktrees/fa72-d2-pg1` is absent.
   - **Disk:** 7.4 G is free. The donor is 539 M apparent / 717 M du.

## R8: service_role in-process connection vs the S10-B guard at HEAD bytes
The guard accepts this connection:
- **Guard check at import.** The `g2S10bTestTarget` check runs only on the raw `G2_S10B_DATABASE_URL` when `g2-s10b-pg-harness` is imported. That URL is unchanged from v6, which ran RC=0. Port 55649 is not in `REFUSED_PORTS`, whose last entry is 55646. The user is `s10b_super`, there is no password in the URL, and the confirmation is `g2_s10b_disposable:55649`.
- **Password and role.** The spec calls `withFixturePassword(lane.target.prismaUrl, G2_S10B_PASSWORD, G2_S10B_RUNTIME_ROLE)`. That passes because `service_role` is in `G2_S10B_LOGIN_ROLES` and the plain password `s10b_local_synthetic` matches no `[\s@/:?#]` character.
- **Same pattern as the S10-B worker.** The spec then adds `application_name`, which is not re-validated. The S10-B `worker()` in pg-harness does exactly the same thing (withFixturePassword → runtime role → `application_name`) and was accepted in the S10-B/S10-C runs.
- **Candidate-head guard.** At import, pg-harness requires `G2_S10B_CANDIDATE_HEAD` (= EXPECT_HEAD, exported) to equal `git rev-parse HEAD` in root = W, and `git status --porcelain` to be empty. The runner verifies both just before `STARTED` (`node_modules/` is gitignored), and bootstrap line 51 repeats the check.
- **No hook-registration error.** g2-s10b-harness.ts registers no jest hooks at module scope, so requiring it inside `beforeAll` does not raise a hook-in-hook error.

## Findings (all C: record, qualify, continue)
- **C1 — jest.config.js, test/jest.setup.ts and test/__mocks__/jose.ts are not blob-pinned individually.** They are fixed by EXPECT_TREE plus the exact pure-add delta, so they carry BASE bytes.
  - `jest.setup.ts` supplies a default `DATABASE_URL`. The spec does not use it: it passes an explicit datasource URL to `PrismaClient`, and the services receive that client.
  - The `jose` mock throws if it is called, so it fails closed and cannot fake a pass.
- **C2 — an outer `timeout -k 30 4500` SIGKILL during prestart would skip `refuse()`.** A partial W could then remain. The next launch refuses before the lock (W exists) until the parent removes W, so the run is not consumed. This is as the README describes.
- **C3 — the pre-lock checks run the donor's `prisma --version` and `jest`/`ts-node --version`.** These are read-only invocations and write nothing to the donor tree. The donor client sha is re-checked under the lock and after the run.
- **C4 — `fa72-s11a1-pg3`, the S11 clone of about 539 M, is still present.** It is not touched by this runner. Disk headroom (7.4 G) is sufficient for the copy plus the lane.
- **C5 — the builder note that the s11a1 v3 file writes STARTED before its clone is accurate** (L200–206 vs L248). The D2 order follows the parent's 08:29 order, not those bytes. That is the intended and safer order.
- **C6 — some risks are candidate-side, not binding-side.** Spec behaviour (for example the `reset()` table list, or ts-jest type-check of the dynamically required `src/**`) belongs to the gate/T4 review. A failure there would be a genuine candidate result, not binding waste. The parent's e2e 16/16 run at 144269d1 under the same jest.config.js exercises the same `src` module graph.

## Minimum closures
None required for GO. Before launch the parent should confirm, as the runner itself also checks:
- W `worktrees/fa72-d2-pg1` is still absent;
- `binding/v1/run/` has no sentinel or STARTED;
- no postgres is running and ports 55646–55649 are free (the s11 lane is stopped).

## Commands run (all read-only; RC)
- `cat` WORKER_RULES.md, the grants and the README; `sha256sum -c BINDING.sha256`; `ls`. RC 0.
- `read` of DELTA-from-s10c-v6.diff (full) and `grep` over DELTA-fixture.diff. RC 0.
- `git -C worktrees/fa72-d2` with `rev-parse`, `symbolic-ref`, `rev-list`, `diff --name-status/--name-only`, `ls-tree`, `status --porcelain`, `config --get core.hooksPath` (RC 1: unset, as expected), `merge-base --is-ancestor` and `show HEAD:<file>` (the spec, harnesses, jest.config.js, jest.setup.ts, jose mock, .gitignore, bootstrap). RC 0.
- The FROZEN loop, reproduced as a read-only shell `while read` over `git rev-parse HEAD:<path>`. RC 0; no mismatch.
- `sha256sum`/`stat`: donor NM files, tools, hooks, FROZEN, v6 files; lock inode via `stat -c %i` only. RC 0.
- `ls` of W, which was absent (RC 2 as expected); `ls` of runtime clusters/run (RC 2 only for the absent `proof-*` glob); `df`; `du --apparent-size`. RC 0.
- `diff -u v6 v1 | cmp` against both DELTA bodies (RC 0); `bash -n` on both scripts (RC 0); grep of the s11a1 v3 runner and its run log/sentinel (RC 0).
- A read-only diff of the repo schema vs the donor client schema (RC 1: differences, formatting only).

I did not run the runner, fixture, jest, bootstrap, PG, npm or prisma generate, and did not take the lock.
