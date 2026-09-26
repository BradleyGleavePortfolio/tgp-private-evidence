# S10-D D2 real-PG proof binding v1 — EXEC-FA72EFB2 (SOURCE ONLY: NOT RUN, NOT GRANTED; FILLED + REBASED onto 7fdcbc04)

Builder: T3 binding build (D2_BINDING_BUILD_GRANT.md). Parent session fa72efb2.

## What was and was not done
- Nothing was executed. The builder did not run the runner, PostgreSQL, initdb, the bootstrap or jest, and did not take `/home/user/workspace/execution/test-validation.lock`.
- The evidence repo was not git-committed. Nothing was pushed, and no worktree was written.

## Files

| File | sha256 |
|---|---|
| `d2-pg-proof.sh` (mode 755) | see `BINDING.sha256` |
| `d2-fixture.sh` | `0fadafa36ff77dbf5621315d5ffca54bc4a57d2a7d8dc0328532798fcea5c24b` (pinned in the runner as `EXPECT_FIXTURE_SHA`) |
| `DELTA-from-s10c-v6.diff` | `diff -u` of `d3a9f701/s10c/binding/v6/s10c-pg-proof.sh` (sha256 `1bb4b564…483d`) against `d2-pg-proof.sh` |
| `DELTA-fixture.diff` | `diff -u` of `d3a9f701/s10c/binding/v6/s10c-fixture.sh` (sha256 `c1b57239…92e7`) against `d2-fixture.sh` |
| `.build-d2-runner.py` | The builder's substitution script (template, then asserted exact replacements, then runner). Kept for audit. It is not part of the binding. |

- **Template.** The template is v6. It has no README, so the v1 README was read as the design reference (the lane and fill rationale carries over).
- **Syntax checks.** `bash -n d2-pg-proof.sh` and `bash -n d2-fixture.sh` both returned RC=0.

## Fixture delta (DELTA-fixture.diff): pure literal substitution plus header prose
- **Runtime root:** `RUNTIME_ROOT=/home/user/workspace/execution/fa72efb2/runtime`.
- **Lane:** `clusters/s10d2` + `run/s10d2`.
- **Runner identity:**
  - `s10c-pg-proof.sh`/`s10c-fixture.sh` → `d2-pg-proof.sh`/`d2-fixture.sh`;
  - `S10C_RUNNER_PID`/`S10C_STOP_TIMEOUT` → `D2_*`;
  - markers `S10C_FIXTURE_*` → `D2_FIXTURE_*`.
- **Refused ports:** `55646|55647` → `55646|55647|55648`. 55648 is the S11 lane of the fa72efb2 s11a1 v3 binding in this same runtime.
- **Unchanged:** port 55649, the S10-B harness literals (`s10b_super` / `s10b_local_synthetic` / `s10b-disposable-pg17`), init/start/stop/destroy logic, bounds, and marker+port gating.

## Runner delta (DELTA-from-s10c-v6.diff), with the reason for each change

1. **Runtime and tools.**
   - RUNTIME_ROOT is the fa72efb2 runtime. `pg17/PROVENANCE.txt` there says `result=success`, and the postgres/initdb/pg_ctl shas equal the v6 pins byte for byte.
   - The psql real binary `/usr/lib/postgresql/18/bin/psql` is sha `d1108fdb…`, node is `a03953a7…` and prisma CLI is 6.19.3. All come from `runtime/raw/rt-setup.log`.
   - Lock inode 686480 (rt-setup START line; `stat` today = 686480).
2. **Paths.**
   - `D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s10d2/binding/v1` (the template used `/home/user/workspace/tgp-private-evidence/…`, which does not exist on this host).
   - SRC=`worktrees/fa72-d2`, W=`worktrees/fa72-d2-pg1`, DONOR_NM=`worktrees/fa72-s11a1/node_modules`.
   - The FROZEN file is read from the repos/ path. It is the same file as before, with the same sha pin `e9c71f09…`.
3. **Fresh clone (structural delta; the grant names W as a fresh clone of SRC).**
   - The v6 template ran in the gate's own worktree. For D2, the pre-lock git checks read **SRC**, and `$W` must not exist.
   - Under the lock, after preflight, a new step 1b runs:
     - `git -c core.hooksPath=/dev/null clone --shared --no-checkout SRC W` + `checkout --detach EXPECT_HEAD` (bounded 120+120 s);
     - re-verify head/tree/parent/clean/migrations/harness-base/package-lock/schema in W;
     - `cp -a DONOR_NM W/node_modules` (bounded 600 s; no npm, **no prisma generate**);
     - the template's node_modules checks, moved here and applied to the copy: real dir, resolves inside W, no absolute prisma symlinks, hidden lock, client index.d.ts/schema = pins, the three S10-B models, bins, donor unchanged, clone clean.
   - Mechanics are taken from the fa72efb2 s11a1 v3 runner (the clone and cp lines), minus its in-clone generate.
   - `PORC0` is now computed after the copy. The post step also checks that SRC's porcelain+HEAD signature is unchanged.
4. **R1 ordering (parent order 08:29): nothing is consumed until the clone is ready.**
   - New order: pre-lock preconditions → lock + inode check → `LOCKED` → under-lock rechecks → preflight (`PREFLIGHT_OK`) → `mkdir` W (exclusive) → `CLONE rc` → `CHECKOUT rc` → clone verification → `CP_A rc` → node_modules verification → `CLONE_READY` → O_EXCL `run/STARTED` → `START` → fixture init …
   - Before `STARTED`, `fail()` is a `refuse()`: it logs `PRESTART_REFUSED stage=… rc=… clone=removed|not-created|REMOVE_FAILED` to `prelock.log`, writes **no STARTED and no sentinel** (the run is not consumed; a relaunch is possible) and exits with the stage's existing code (70 rechecks, 71 preflight/clone/copy/verify, 76 STARTED race). The lock is still held until that exit.
   - Partial-W removal: W is created by `mkdir -- "$W"` (fails if W appeared, so a pre-existing W is refused and never touched; the pre-lock and under-lock checks already refuse an existing W). Only after that mkdir is `W_CREATED=1` set; `refuse()` then runs `rm -rf -- "$W"` and verifies it is gone. If the removal fails, it logs `REMOVE_FAILED` and the next relaunch refuses before the lock until the parent removes W.
   - Right after `STARTED`, `LOG` switches to `d2-pg-proof.log` and `finish()`/`fail()` are defined exactly as in v6 (consuming, sentinel written). All later stages are unchanged.
   - Side effect of the ordering: the under-lock rechecks (rc 70) and preflight (rc 71) also moved before `STARTED`, so their failures no longer consume the run either. They are read-only, so this only makes a refusal cheaper.
   - Built by section 11 of `.build-d2-runner.py` (line-anchored moves with a layout assertion).
4. **Inverted donor guard (grant).** The v6 check `EXPECT_NM_CLIENT_SHA != DONOR_CLIENT_SHA` (its donor held a pre-S10-B client) becomes `EXPECT_NM_CLIENT_SHA == DONOR_CLIENT_SHA && EXPECT_NM_CLIENT_SCHEMA_SHA == DONOR_CLIENT_SCHEMA_SHA`, i.e. `2c819c8a…a56c` / `aca7a558…42e5`. The reason: the donor was generated by rt-setup from the S10-B schema `d6d01f54`, which is also the D2 base schema.
5. **Candidate.**
   - **Rebased (parent 08:53).** S11-A1 (3db615c0) and S11-C (7fdcbc04) landed on integration/importer, and D2 was rebased onto it. BASE_HEAD=`7fdcbc044dba1747d0db2f2750ced951f3b6b752`, BASE_TREE=`a802231ee1f4dd693284b349e7eb078b3688e8d5` (both from `git rev-parse` in SRC). The first version pinned 6a33df9b / 454fd501.
   - HEAD^ = BASE, and `rev-list --count BASE..HEAD` = 1. Checked: HEAD 144269d1, parent 7fdcbc04.
   - SRC must be on `refs/heads/fa72/d2-r1` = EXPECT_HEAD. `git symbolic-ref HEAD` = refs/heads/fa72/d2-r1. All three branch-ref sites were renamed from fa72/d2.
   - EXPECT_DELTA = D2_OWNED = the 8 D2 paths, sorted. They must be pure additions (`--diff-filter=A`), all mode 100644, and each blob must equal its fill pin.
   - The S10B_HEAD a2c74e90 and harness base a4af8e33 ancestry checks are kept. Both are verified ancestors of 7fdcbc04 (and 6a33df9b is too).
6. **Contract.** `EXPECT_CONTRACT_STATE=unchanged` is now enforced. BASE_CONTRACT_BLOB = EXPECT_CONTRACT_BLOB = `1a5deca500d0dd9422edaca2f9883ed57c33a0e8`, the blob at 7fdcbc04 and at HEAD. S11-C changed it from `bd715150` (6a33df9b), and C2 had changed that from the template's 752f9dbe. `test/contracts/importer-contract.spec.ts` (also changed by S11-C) is not pinned by this runner, and it is not in FROZEN.
7. **FROZEN.**
   - **Re-derived at 7fdcbc04:** `git diff --name-only 6a33df9b 7fdcbc04` touches **none** of the 29 FROZEN paths. S11-A1/S11-C changed the contract, `test/contracts/importer-contract.spec.ts`, `test/rls-c1-setup.spec.ts`, `src/extension-pair/*` and new `test/**/s11*`/`g2-s11-*` files. So no FROZEN path needed re-pinning; the 29-path loop was re-checked against HEAD 144269d1 (all match; FROZEN file sha `e9c71f09…` unchanged).
   - 28 of the 29 S10-A/S10-B FROZEN blobs equal BASE. The exception is `test/scout/induction/manifest-registry.spec.ts`, which premise P (7746a877, an ancestor of BASE) re-stated.
   - That one path is pinned to its BASE blob, `9b5de3743ec27181b58e8277591a6c8c1a8adc65`, which is the same at 6a33df9b, 7fdcbc04 and 144269d1. D2 must not touch it, and the exact delta enforces that anyway.
   - Everything else in the loop is unchanged, including the count of 29.
8. **No prisma change.** These checks are carried unchanged:
   - migrations tree `7b6fe0ed…` with 173 dirs, the last being `20270124000000_scout_run_observation_expand`, at BASE and HEAD;
   - the prisma delta vs a4af8e33 = schema + the S10-B pair;
   - no prisma/package/`test/utils/g2-s10b-*` change since S10B_HEAD (re-verified empty at HEAD 144269d1; migrations tree 7b6fe0ed, 173 dirs, same at 7fdcbc04; S10-B harness blobs all unchanged at 7fdcbc04 and HEAD).

   Package-lock and schema shas are read from the committed HEAD bytes before the lock and from the W files after the clone.
9. **Lane.**
   - `clusters/s10d2` + `run/s10d2` on 55649. 55649 is not in `test/utils/g2-s10b-db.ts` REFUSED_PORTS, which stops at 55646; the runner re-checks this at HEAD.
   - The S10-B harness identity literals are kept.
   - REFUSED_LANE_PORTS=`55646 55647 55648`. Each must have zero listeners before and after the run.
   - This runtime has no retained `clusters/s10-b` lane, so the template's three checks that it exists, is fingerprinted and is complete are **dropped**. At fill time `clusters/s11/` exists (logs only, no `pg-data`). The generic other-lane scan fingerprints it as `ABSENT:ABSENT` and must find it unchanged at the end.
   - An s10-b lane can still never be the lane. If one appears, it must have no postmaster.pid, and the generic other-lane fingerprint must be unchanged at the end.
10. **Hooks.** The hooks checks (core.hooksPath unset, plain `.git/hooks`, regular lefthook files, sha pins, under-lock recheck) now target **SRC**, where the gate commits. W is cloned with hooks disabled.
11. **Command and count.**
    - The command is: `./node_modules/.bin/jest -c jest.config.js --runInBand --ci --runTestsByPath test/scout/s10/s10-unseen.pg.spec.ts`, run once in W.
    - The run must print `Tests: 8 passed, 8 total` and `Test Suites: 1 passed, 1 total`, and the PASS lines must be exactly the D2 spec.
    - `jest.config.js` has no displayName, and its `testPathIgnorePatterns` ignore only `test/rls*`, so the spec is not excluded.
12. **Spec shape (checked before the lock on the committed bytes).**
    - it() count = 8, and there are zero `test(` lines.
    - The env switch must be the pinned live form:
      - exactly one `const LIVE = typeof process.env.G2_S10B_DATABASE_URL === 'string';`;
      - exactly one `const suite = LIVE ? describe : describe.skip;`;
      - exactly one `suite(` block and exactly 2 `LIVE` lines.
    - With that suite line and comment lines removed (the header prose contains `` `describe.skip` ``), there is no `skip|only|todo|each|concurrent|failing` on it/describe/test/suite and no x/f variants.
    - The spec must `require` `../../utils/g2-s10b-pg-harness` and `../../utils/g2-s10b-harness`, and must not reference any s10c/s10d/s11 harness.
    - The builder ran this block read-only, on the pre-gate bytes and in two mutated copies. It passed on the real bytes and refused (rc 70) both an `it.skip` and a changed switch.
    - The s10b (24) and s10c (8) it-count and blob pins are kept as frozen-file checks only. Those specs are **not run**.
13. **LAND_REF.** `LAND_REF=refs/remotes/origin/land/s10d2` (as seen in SRC). The runner's mechanism takes `EXPECT_LAND_REF` as `none` or a 40-hex that must equal EXPECT_HEAD and the ref, both before and under the lock. It is filled with `144269d13db5275a2d6689bebb2f7dca8367593c` (`git rev-parse refs/remotes/origin/land/s10d2` = that), so the ref name the parent gave is `LAND_REF` and its required value is `EXPECT_LAND_REF`.
14. **Carried unchanged:**
    - sentinel and `run/STARTED` one-shot (symlink-aware, `set -C`);
    - PRELOCK_REFUSED that does not consume the run;
    - nonblocking flock fd 9 with the inode check;
    - under-lock rechecks;
    - fixture init/start, the S10-B bootstrap (`test/utils/g2-s10b-bootstrap.sh bootstrap`, 900 s) and its three marker lines;
    - 8 identity queries;
    - GUARD_REFUSAL grep;
    - bounded stop with the data dir retained;
    - other-lane fingerprints;
    - receipts and `finish()`;
    - the pipefail rule (no `cmd | grep -q`; the new lines use captured here-strings or `grep -c … || true`).
    - Relay bound: `timeout -k 30 4500` (soft sum 3555 s).

## Fill table (FILLED, parent order 08:53; no `__FILL_*__` remains)

Every value was read by the builder in SRC=`worktrees/fa72-d2` (read-only `git rev-parse` / `sha256sum`). The placeholder refusal stays in the runner as a guard.

| Variable | Value | Provenance | Changed vs first version? |
|---|---|---|---|
| `BASE_HEAD` | `7fdcbc044dba1747d0db2f2750ced951f3b6b752` | S11-C landing; `git rev-parse HEAD^` | yes (was 6a33df9b…) |
| `BASE_TREE` | `a802231ee1f4dd693284b349e7eb078b3688e8d5` | `git rev-parse 7fdcbc04^{tree}` | yes (was 454fd501…) |
| `EXPECT_HEAD` | `144269d13db5275a2d6689bebb2f7dca8367593c` | `git rev-parse HEAD` = `refs/heads/fa72/d2-r1` | filled |
| `EXPECT_TREE` | `a0bc3c09f82edd8fa13932913437813911d5be38` | `git rev-parse HEAD^{tree}` | filled |
| branch ref | `refs/heads/fa72/d2-r1` | `git symbolic-ref HEAD` | yes (was fa72/d2) |
| `BASE_CONTRACT_BLOB` = `EXPECT_CONTRACT_BLOB` | `1a5deca500d0dd9422edaca2f9883ed57c33a0e8` | `rev-parse 7fdcbc04:docs/contracts/importer-openapi.json` = HEAD's | yes (was bd715150…) |
| `EXPECT_HOOK_PRECOMMIT_SHA` | `54aa5cd8b77c4b8549c8d7c40bd85e5ffc6406a6018661fed4a876f7c58de3f9` | `sha256sum .git/hooks/pre-commit` (lefthook) | filled (= pre-gate observation) |
| `EXPECT_HOOK_COMMITMSG_SHA` | `dc998a5e5776895512ee9860763444c1cb9eafa9d64e181c6cbe923c59e11be0` | `sha256sum .git/hooks/commit-msg` | filled (= pre-gate observation) |
| `EXPECT_D2_BLOB_INDUCTION` | `4e21d522772adbde19d8ee3419b30039ec250475` | `rev-parse HEAD:src/scout/induction/sources/s10_unseen.json` (= 6e3f86ce) | filled (= pre-gate) |
| `EXPECT_D2_BLOB_NATIVE` | `6b8695c8b7504e7623bf3b61ef686f3dd4612f9b` | `HEAD:src/scout/reconstruct/native/sources/s10_unseen.json` (= 6e3f86ce) | filled (= pre-gate) |
| `EXPECT_D2_BLOB_MAPPING` | `94dcc8198c4b7a6ed27c6bfcf3a57d201effd879` | `HEAD:src/scout/reconstruct/sources/s10_unseen.json` (= 6e3f86ce) | filled (= pre-gate) |
| `EXPECT_D2_BLOB_KEY` | `4d5bf92e157f7d44b5f97b92e41fd3ac4b2a88f1` | `HEAD:test/fixtures/scout/s10_unseen/signer-test-key.json` (= 6e3f86ce) | filled (= pre-gate) |
| `EXPECT_D2_BLOB_ROWS` | `94e7f5670e18f88fd7bcc8a728b537683d896f1f` | `HEAD:test/fixtures/scout/s10_unseen/staged-rows.json` (= 6e3f86ce) | filled; **differs** from pre-gate 4f228154 (gate reformat) |
| `EXPECT_D2_BLOB_STATEMENTS` | `90d644b4bbb48aec86b293d2a39eb02a670884fe` | `HEAD:test/fixtures/scout/s10_unseen/statements.json` (= 6e3f86ce) | filled (= pre-gate) |
| `EXPECT_D2_BLOB_E2E` | `41df91ec0c020c16364956a2abfd9983d6f0f41c` | `HEAD:test/scout/s10/s10-unseen.e2e.spec.ts` (= 6e3f86ce) | filled; **differs** from pre-gate 8f132cf9 (gate reformat) |
| `EXPECT_D2_BLOB_PG` | `074b0fa0f0472be23e312ca68a9b0528c28230c5` | `HEAD:test/scout/s10/s10-unseen.pg.spec.ts` (= 6e3f86ce); 8 `it(` lines, 0 s11/s10c refs | filled (= pre-gate) |
| `LAND_REF` / `EXPECT_LAND_REF` | `refs/remotes/origin/land/s10d2` / `144269d13db5275a2d6689bebb2f7dca8367593c` | `rev-parse refs/remotes/origin/land/s10d2` = HEAD | filled |

All 8 D2 paths are `A` 100644 in `git diff --name-status 7fdcbc04 HEAD`, and that diff has exactly 8 entries. SRC `status --porcelain --untracked-files=all` is empty. W `worktrees/fa72-d2-pg1` is absent. Lock inode is 686480 (unchanged).

**Unchanged at the new base (re-derived at 7fdcbc04 and HEAD):** S10-B harness blobs b89fec1c / 3375f08b / 7cf6d633 / 9956aff7 / e0af8412 / 8055dbef / 32305683 / f86c1f5d / 695c694d / b5e5243e; S10-C spec 50a0deae (8 it); s10b spec 24 it; migrations tree 7b6fe0ed (173, last = S10-B); prisma delta vs a4af8e33 = schema + S10-B pair; manifests unchanged vs a4af8e33 (package-lock sha256 b7fed5ed…, schema sha256 d6d01f54…); FROZEN 29/29 at HEAD (with the P exception 9b5de374); 55649 not in the S10-B guard's REFUSED_PORTS; donor NM lock/client/schema shas 05bc530a / 2c819c8a / aca7a558 unchanged.

- **Pre-filled by the builder (verified at build time):**
  - EXPECT_DELTA (8 paths), `EXPECT_S10C_SPEC_BLOB` 50a0deae (the landed S10-C spec); BASE_HEAD/BASE_TREE/contract are now the rebased values in the table above;
  - all S10-B harness blobs (b89fec1c / 3375f08b / 7cf6d633 / 9956aff7 / e0af8412 / 8055dbef / 32305683 / f86c1f5d / 695c694d / b5e5243e, all equal at 6a33df9b, 7fdcbc04 and 144269d1);
  - FROZEN_P_BLOB, the tool pins, the NM lock/client pins, the lock inode, EXPECT_FIXTURE_SHA.
- **Fill is text-only.** Filling changes only `d2-pg-proof.sh`, not the fixture, so `EXPECT_FIXTURE_SHA` stays valid. Re-run `bash -n` and record the filled runner's sha256 after filling.
- **If the gate reformatted any D2 path,** the post-format blobs are the pins. The spec checks (8 it(), pinned switch) then re-run on those bytes before the lock.

## Expected count
- **8 it() cases** in `test/scout/s10/s10-unseen.pg.spec.ts` (pre-gate bytes 074b0fa0). The cases are:
  - R39 (a) through (f): 6 cases;
  - R41 replay: 1 case;
  - R27 live canonical-token: 1 case.
- **Required jest output:** `Tests: 8 passed, 8 total`, `Test Suites: 1 passed, 1 total`, and one PASS line for the D2 spec.
- **Only this spec runs.** No other spec is run.

## Open risks (Safety ROI; WORKER_RULES 5)
- **R1 — C (was B; closed by ordering, parent order 08:29): fresh-clone + `cp -a` step.** The clone, checkout, donor copy and all their verifications now run under the lock but BEFORE the O_EXCL `STARTED` marker (runner delta item 4). A failure there is `PRESTART_REFUSED`: no STARTED, no sentinel, the partial W this run created is removed, and a W that existed before is never touched. So a clone/copy failure no longer consumes the one run. What remains is informational: the copied tree differs from v6's gate-made tree, and the verification pins (head/tree/clean/lock/client shas) cover that. Builder note: the file `fa72efb2/s11a1/binding/v3/s11-pg-proof.sh` as read here writes STARTED at L206, before its clone at L248. The PREFLIGHT_OK → CLONE → CHECKOUT → STARTED order in the parent order was therefore implemented from the order itself, not copied from that file's bytes.
- **R2 — C: FROZEN exception.** `manifest-registry.spec.ts` is pinned to its BASE blob (P 7746a877) instead of the a2c74e90 blob. The other 28 entries and the count of 29 are unchanged.
- **R3 — C: added refused port 55648.** Added because the S11 lane binding lives in the same runtime. The change only makes the checks stricter.
- **R4 — C: retained-s10-b-lane must-exist checks dropped.** No such lane exists in this runtime. The template's precondition would refuse forever.
- **R5 — C: `jest.config.js` instead of `jest.rls.config.js`.** This is per the grant. The base `testTimeout` is 10000, but the spec calls `jest.setTimeout(300000)`. The type-checking ts-jest transform with `strict: false` compiles the spec in W. Compile errors would show up as a failed suite (consumed run), and the gate's `tsc --noEmit` covers that.
- **R6 — C: hook shas (now filled).** The fa72-d2 hooks (`54aa5cd8…` / `dc998a5e…`) differ from rt-setup's hooks (`5d073f65` / `3d7d0fd5`) because each clone has its own install. They are pinned from a direct `sha256sum` of the SRC hooks at 144269d1.
- **R9 — C: the base moved after the gate.** The gated commit was 6e3f86ce; the candidate is the rebase 144269d1 onto 7fdcbc04. The 8 D2 blobs are identical (verified here per path), and the parent reports the core-diff gate PASS at 7fdcbc04 and e2e 16/16 at 144269d1 (not re-run by the builder). This binding proves the rebased commit only.
- **R7 — C: disk.** `cp -a` copies about 539 MB (apparent size). About 7.1 GB was free at build time. If the S11 run's `fa72-s11a1-pg3` copy is still present, that is roughly 1.1 GB in total.
- **R8 — C: the spec connects as `service_role`.** The spec connects through `db.withFixturePassword(..., G2_S10B_RUNTIME_ROLE)` in-process. Whether the S10-B guard accepts that is a property of the spec and harness bytes, which belong to the gate/T4 review, not this binding. A refusal would show up as `GUARD_REFUSAL_OBSERVED_IN_JEST_LOG` plus a jest failure.

## Commands run by the builder (all read-only; RC)
- **Reads:** `cat`/`sed`/`grep` of WORKER_RULES, the grants, the v6 runner and fixture, the v1 README, the s11a1 v3 runner, `rt-setup.log` and `PROVENANCE.txt`. RC 0.
- **Git in SRC:** `git -C worktrees/fa72-d2 log/status/rev-parse/diff/ls-tree/merge-base/for-each-ref/hash-object`. RC 0. `hash-object` was run without `-w`.
- **Hashes and stats:** `sha256sum` / `stat` on the donor node_modules, the SRC hooks and the lock (inode only). RC 0.
- **Fill + rebase (08:53):** read-only `git rev-parse/diff/ls-tree/show/merge-base/symbolic-ref/status` in SRC, `sha256sum` of the SRC hooks, donor NM files and FROZEN, `stat` of the lock inode, `ls` of the runtime and of W, and `df`. All RC 0, except `ls W` (RC 2: absent, as required). One build attempt stopped on its own guard (`FILL LEFT`, because a header comment still named `__FILL_*__`) and wrote nothing. After that fix, `python3 .build-d2-runner.py` returned RC 0, followed by `sed` of the fixture sha (RC 0) and `bash -n` (RC 0). `grep -c '__FILL\|__D2_' d2-pg-proof.sh` = 0.
- **Builds:** `python3 .build-d2-runner.py`, run twice. RC 0. For R1, one heredoc attempt to patch the build script failed with a Python SyntaxError and changed nothing. After the edit, the script was run once more (RC 0), then the fixture sha was filled with `sed` (RC 0).
- **Diff check:** `patch` of the v6 files with each DELTA, then `cmp` against the new files. RC 0.
- **Syntax:** `bash -n d2-pg-proof.sh` and `bash -n d2-fixture.sh`. RC 0.
- **Spec-check block:** the extracted spec-check block, run on the real and on 2 mutated copies. RC 0, 70 and 70 respectively.
- **Diffs:** `diff -u` to produce the two DELTA files. RC 1, which means differences were found, as expected.
