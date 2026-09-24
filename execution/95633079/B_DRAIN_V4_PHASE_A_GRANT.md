# B/drain v4 phase-A local execution grant

Parent EXEC-95633079 grants the existing B builder local environment reuse, genuine tracked hooks, affected gates and an ordinary exact-tree commit. Both independent same-review v4 dispositions are SOURCE_GRANTABLE with no open source A/B findings. This is not a PostgreSQL runtime or deployment grant.

## Source and ownership

- **Builder:** `s7_b_drain_builder_muf5xlqn`, sole writer of `worktrees/s7-b-drain/**` and its existing execution evidence area.
- **Base:** `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992`.
- **Granted tree:** `f4922ca070e887fb7f613ce955b12621b5c33156`, eleven added paths, +2323 against base.
- **Reviews:** `audits/b-drain-a/B_DRAIN_V4_BINDING_REVIEW_A.md` and `audits/b-drain-b/B_DRAIN_REVIEW_B_V4.md`.
- **Slot:** the next canonical `execution/test-validation.lock` slot, after J3 r4 stopped and explicitly released it. Nonblocking `flock`; no other runtime owner is granted concurrently.

No product/source edits or formatting writes are authorized. Preserve every v1–v4 freeze and accepted C1/S5 byte boundary.

## Ordered phase-A execution

Preflight exact base, eleven paths/modes/blobs, unchanged accepted paths, Node `20.20.1`, npm `10.8.2`, and package/lock/schema input parity with accepted `worktrees/s7-c1`. Copy its accepted dependencies into an isolated real directory with `cp -a --reflink=auto`; no installation, generation or shared symlink/hardlink tree.

Verify copied `node_modules/.package-lock.json` SHA-256 `05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44` and `.prisma/client/index.d.ts` SHA-256 `bf679a16e50a6f0c39528887b80c2a03c5d0825b816cec3417fcbc94300b72d5`. Known generated-schema whitespace normalization is not a semantic mismatch and does not authorize regeneration.

Install the tracked native hooks using the local Lefthook binary in this standalone worktree only. Confirm actual pre-commit and commit-msg hooks reference Lefthook; do not repeat the earlier C1 literal-path detector mistake. Stage only the eleven v4 paths and verify the actual tree equals the granted tree.

Run local binaries, in order, stopping at the first nonzero:

1. `tsc --noEmit -p tsconfig.json`, 300 seconds.
2. `eslint --no-warn-ignored --max-warnings 0` on all eight TypeScript paths in the frozen eleven-path set, 180 seconds.
3. `prettier --check` on those same eight paths, 120 seconds, no write.
4. `node scripts/check-r75.js --mode=staged`, 60 seconds.
5. `jest src/scout/scout-ledger-backfill.spec.ts test/scout/g2-b-drain-db-guard.spec.ts --runInBand`, 300 seconds.

The eight-path set includes the CLI, which is new versus base although unchanged versus v2. Native-hook `npx` resolution may use the installed local binaries offline, not fetch tools. No wider predecessor proof is requested.

If green, create an ordinary local commit with genuine native pre-commit/commit-msg execution, bounded at 300 seconds. Both author and committer must be Bradley Gleave `<bradley@bradleytgpcoaching.com>`, verified by `git var`. Use the exact message in `B_DRAIN_SOURCE_HANDOFF.md` section 7, no trailers/amend/rebase/bypass. Actual tree must equal v4 and parent must equal accepted C1.

## Filled binding copy, not execution

Only after the successful commit, copy the reviewed `fixture-proposal-v3/binding/b-pg-proof.sh` to `runtime/binding/b-pg-proof.sh` and replace only its five placeholders. The sealed proposal remains untouched, and `D` still points to its unchanged fixture.

- **EXPECT_HEAD:** actual committed head.
- **EXPECT_TREE:** `f4922ca070e887fb7f613ce955b12621b5c33156`.
- **EXPECT_SPEC_BLOB:** `9b31fd1813d25a1624ab04666e0b1be4743277ab`, the live PG spec, not the unit spec.
- **EXPECT_BOOTSTRAP_BLOB:** `b4503eef525baa531eedb148f47828db3a4ade6f`.
- **EXPECT_FIXTURE_SHA:** `4525f01d06333918bdb1fca3fd70f4d4e3936ee1cefc01eb5ac6d0ba9d501eb9`.

Save the substitution-only diff, actual pins and script hash. The template's historical “v3” comments do not override the actual v4 pins.

Do not run that script or create a cluster, database or O-root. No PG probe/bootstrap/client generation is authorized in this phase. Both same reviewers will bind the actual head, gate receipts and filled script before a separate single-run PG grant.

## Stop and receipts

No automatic fix, retry or gate expansion follows a nonzero. Save additive raw commands, status/logs, identity, environment, hooks, commit/tree/message, lock and portable bundle/patch receipts; preserve failures honestly. Release the slot, report actual owned invocation termination and final status, and return for disposition without self-acceptance.

## First-run stop and exact stage-2 remainder

The first driver stopped at `RC=71 STAGE=copy-symlink-outside`, terminal `2026-09-24T08:18:57Z`, before hooks, staging, gates or commit. The completed dependency copy is verified: 649 entries, 717M, both required hashes matched, zero shared source inodes and zero multi-link files.

Its detector rejected the one inherited absolute `node_modules/.bin/prettier` link to the already-approved external Prettier 3.9.6 CLI. Parent independently read both C1/B links and computed the target SHA-256 `6e922134a3c76fd4de202959bb6aef50bde0c994148075003a15569b7197906e`. This is a shared immutable approved tool, not a dependency-tree link into the accepted C1 worktree. The overstrict detector is an execution-only proof blocker, not a product or copied-environment defect.

Parent grants an additive remainder from stage 2 under the same canonical slot. Reassert the two dependency hashes, this exact formatter target/hash, and unchanged v4 source/base; then run the previously granted hooks, stage/gates, hooked commit, filled-binding copy and exports. Do not recopy dependencies, reinstall, regenerate, repeat a full inode census, widen the symlink exception or add new gates.

Preserve the original driver, logs and RC71 sentinel unchanged. Use separate remainder receipts with the same first-failure stop. No PG action is unlocked by this disposition; actual-head and filled-binding review still precede a separate PG grant.
