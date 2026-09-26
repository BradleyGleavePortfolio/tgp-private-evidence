# S10-B gate + real-PG binding — builder summary (source only, NOT RUN, NOT GRANTED)

What I ran: `bash -n` on every script, plus `--fill-help` read-only git queries against a4af8e33 as a dry probe. I did not run tsc, jest, npm, prisma, postgres or prettier. I did not take the lock, commit, or edit worktrees/d3a9-s10b or r2.

## Files
Evidence root: `/home/user/workspace/private-evidence/execution/d3a9f701/s10b/`

| file | sha256 |
|---|---|
| gate/s10b-gate-d3a9.sh | 6203420761a8924914bfd5b59c3bbb3bbabd9d0d418d5dd35a5f7dfc74a8b1c7 |
| gate/PINS.env | 5e8fe02fdfb4767a8efe3786a0cc96aab662c7ae14114fdb982c82c38bca8433 |
| gate/commit-message.txt | c2dc4e63c0a45757ae76a67f05c17f2173a75858385ee893c38e542d28c062f9 |
| gate/README.md | ab533ce464428d7e4871c6ea3ad70f6dc288838821f879eafea116d09f74d55f |
| gate/DELTA-from-s9c-gate-3.diff | 86fa458c92b75a2f3c1d7b1f103a4364d1e99b735fbc6e3bae8b76cbfb1e6646 |
| binding/v1/s10b-pg-proof.sh | c0a2c2fca55437945a93dcbd157de4614d4240a5e022c124b198a57c79bc7f98 |
| binding/v1/s10b-fixture.sh | 9d0607f6d8b6e92f6c802d4d3c2f297fbef51a84c387662e857ca4c9b1092d91 |
| binding/v1/README.md | 0331196768936f84723fb6690d7a8951602a41c845b2af09087c95c320a92e00 |
| binding/v1/DELTA-from-s9c-v2.diff | 17602b51c623c743b486232468d010b6fa046be44adeaac6da48f8f08d42f7ad |

These hashes are also in `gate/GATE.sha256` and `binding/v1/BINDING.sha256`. Re-hash both after filling.

## __FILL__ pins
- **Gate `PINS.env`:** `BASE`, `BASE_TREE`, `MIGRATIONS_TREE` (expected 654550cb). Fill them with `bash gate/s10b-gate-d3a9.sh --fill-help <S10-A sha>`.
- **Binding:** `BASE_HEAD`, `BASE_TREE`, `EXPECT_HEAD`, `EXPECT_TREE`, `EXPECT_MIGRATIONS_TREE`, six post-format blobs (spec, db, pg-harness, harness, worker, fixtures), `EXPECT_NM_CLIENT_SHA`, `EXPECT_NM_CLIENT_SCHEMA_SHA`. All of these come from the gate receipt `HEAD-<12>.txt`.
- **Already filled in the binding:** the bootstrap, schema, migration and down blobs (git hash-object without -w), and `EXPECT_FIXTURE_SHA`.

## Relay
```
S10B_GATE_RELAY=1 S10B_BASE=<S10-A sha> S10B_DONOR=/home/user/workspace/worktrees/1910a060-s8f/node_modules \
S10B_PRETTIER_PREFIX=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 \
timeout -k 30 7200 bash /home/user/workspace/tgp-private-evidence/execution/d3a9f701/s10b/gate/s10b-gate-d3a9.sh
```
Before the relay, the parent must:
1. Land S10-A.
2. Run `git merge --ff-only <S10-A sha>` in d3a9-s10b.
3. Fill the pins.
4. Set aside any hooks (README step 4).
5. Confirm node_modules is absent and the lock is free.

## Key decisions
- **Contract:** D-S10-8 (L355) says S10-B does not own the OpenAPI bytes; S10-C regenerates them (L356). The gate therefore asserts NO change. It regenerates into a scratch path via `IMPORTER_CONTRACT_OUT`, the result must be byte-identical to `BASE:importer-openapi.json` (blob 8ebf936a), the canonical file is never written, and the contract is forbidden in the delta.
- **Prisma generate:**
  - It always runs, and only in `$W/node_modules`, a `cp -a` real copy. The gate first checks that the `@prisma/client`, `.prisma` and `prisma` directories resolve inside `$W`.
  - The donor's `.prisma` and `@prisma/client` signature and client shas are checked before the copy and after the generate. They must equal the pre-S10-B values 9042e713 and b8439203.
  - The post-generate client is RECORD mode: it is recorded and checked structurally (three models, engine matches `@prisma/engines`, differs from the donor). The binding enforces it through the receipt.
- **Migrations:** BASE has 172 dirs ending at S7-L. The working tree and commit have 173 ending at `20270124000000_scout_run_observation_expand`. The binding requires 173 applied migrations, with `max(migration_name)` equal to the S10-B dir, and all 3 tables with forced RLS.
- **Lessons:**
  1. There are no `| grep -q` pipelines, including the fixture's `data_dir_users`.
  2. Pre-existing hooks cause a refusal (rc 70), with a documented set-aside step.
  3. The commit message is required, and is checked against the banned-token regex before the lock is taken.
  4. R75 staged runs early (after prettier, with the index restored) and again before the commit.
- **Suites:** 7 targeted (the 5 S10-A specs + the 2 observation specs), then the full suite.

## Assumptions for the parent
- S10-A lands as exactly one commit on a4af8e33 with the FREEZE bytes (the gate enforces `BASE^` and the 14-path delta).
- `HARNESS_BASE_HEAD` stays a4af8e33, because the harness literal needs no edit: the prisma diff from it is still exactly three files.
- `prisma generate` 6.19.3 works offline with the copied engines. This is untested; a failure means rc 71 with prisma-generate.log.
- The S9-C merge order ("merges after S9-C lands") is left to landing.
- Disk: 2.7 GB free, the donor is 717 MB.

---
## Review-fix round (reviews A NO-GO B-1, B NO-GO B1/B2/C) — 2026-09-26, source only, NOT RUN
Diffs: `gate/DELTA-review-fix.diff`, `binding/v1/DELTA-review-fix.diff`. The pre-fix copies are kept in `*/pre-review-fix/`.

| file | sha256 |
|---|---|
| gate/s10b-gate-d3a9.sh | 2fe09acb61160c0005cef5f78bb85065c0b1a761492b7aacf0d6ee98055f8a10 |
| gate/PINS.env | 9d16a115b09c3efab3dd63aca2d446d55d9a7e848901a09e586b87bcd8549b74 |
| gate/commit-message.txt | c2dc4e63c0a45757ae76a67f05c17f2173a75858385ee893c38e542d28c062f9 (unchanged) |
| gate/README.md | f8af171451b7a4c01c8eed921f5186ec65f06ac0e6a0f6c1db7ca857db8d11ac |
| gate/DELTA-review-fix.diff | 77214f09b30f26ba837a088ca62b3eff218e641d44a40b1d73f1190df435e5eb |
| binding/v1/s10b-pg-proof.sh | e4b1d599f20fa0a78040a95ab3c9b620878629cafcca2b6f267079d1749872ef |
| binding/v1/s10b-fixture.sh | 7d9ee89b4333332ea42adcadf538c68c6815127e161d8941db125ac9873120e8 |
| binding/v1/README.md | 3d9035d5e0a3bb3dfacb7f47455dd62bda3848c2e8a64cfc9b7db73621f6e0f7 |
| binding/v1/DELTA-review-fix.diff | 16bc84d0df77c18fe106b13b507802c0615c38025d1631763c0a5c740baf6ca0 |

The full set, including the regenerated DELTA-from-s9c diffs, is in GATE.sha256 and BINDING.sha256.

Applied:
1. **Symlink-aware refusal.**
   - Gate: refuses if a hook path passes `[ -e ] || [ -L ]`, and requires the hooks dir to be the plain `.git/hooks` (not a symlink). Both checks run pre-lock and again under the lock.
   - Binding: the sentinel check uses `-e || -L`, the lefthook hooks must be regular non-symlink files, and the lane dir and other-lane postmaster.pid checks count `-L` as present.
   - Fixture: `init` refuses a symlinked `$DATA`, and `destroy` checks for `-L`.
2. **B1: all pin/shape preconditions now run before the sentinel.**
   - Gate: before STARTED, the lock and TERMINAL. Refusals are logged as `REFUSED_PRELOCK` in `gate/prelock.log`, with GIT_OPTIONAL_LOCKS=0.
   - Binding: before the lock and the sentinel. Refusals are logged as `PRELOCK_REFUSED` in `run/prelock.log`.
   - Both re-check the movable state (HEAD, status, hooks, bytes, client) under the lock.
3. **B2:** gate:79 is replaced by `git merge-base --is-ancestor HARNESS_BASE_HEAD BASE` and `... S10A_PARENT`, both pre-lock. The harness stays at a4af8e33.
4. **New pins:** S10A_PARENT=e6f20300b495fa9eee9539ae58d30e3b60e5a78c in PINS.env and s10b-pg-proof.sh; CONTRACT_BLOB=752f9dbe…; SHA_CONTRACT_JSON=2db3f27f….
5. **OWNED_PINS** equal devloop-2/POSTFORMAT.sha256 (16 paths; modes unchanged).
   - The binding's prefilled blobs (bootstrap, schema, migration, down) are unchanged.
   - The comments now carry the devloop-2 blob values for the six receipt fills.
   - EXPECT_TESTS=24 was re-counted.
   - EXPECT_FIXTURE_SHA is now 7d9ee89b.
6. **Stale a4af8e33 wording (review C1)** is fixed in the scripts, PINS and READMEs. The remaining a4af8e33 references are the harness literal only.

BASE, BASE_TREE and MIGRATIONS_TREE are still `__FILL__`. The binding still has 13 `__FILL__` pins.

Not changed: the S10-B harness files, which are owned bytes and outside my scope. Their C1 comments at pg-harness.ts:10/34 and bootstrap:6 still say a4af8e33. Review B3 (dev-loop on the e6f20300 base) and C3 (the land-s10a.sh TIP) are parent actions.
