# SLOT_REQUEST_03 — Addendum A: `CHECKPOINT_DISABLE=1` pinned and stamped on every Prisma invocation

Additive to `SLOT_REQUEST_03_PREP2_TREE_A584A1B9_SETUP_HOOKED_COMMIT_TARGETED.md` (sha256 `e707ec2a17b33250595d16b4716b5da1e91aa358cc45b328d2c78e52e4c6497f`, unmodified). Contract: execution/EXECUTION_REPAIR_WAVE_2.md §"S3 request03 prospective environment addendum". Preparation only: no install, refetch, format, test or commit; tree `a584a1b95423f95dae8daabf673ef3776604acbb`, parents and packet unchanged.

## 1. Basis
- The pinned Prisma CLI (`prisma@6.19.3`, lock blob `354de3da…`, bundled CLI `node_modules/prisma/build/index.js`) carries Prisma's optional "checkpoint" telemetry path, which the CLI detaches and which honours `CHECKPOINT_DISABLE=1`. No separate `checkpoint-client` package exists in the product lock (it is bundled inside the CLI build), so the only control is the environment variable. This follows both S2 reviewers' finding on the same pinned CLI and S2's own runner stamping (`execution/s2-runner55/PROOF_REQUEST_09.md`, controls E6). Historical egress by S3's earlier `prisma generate` (S3 log 01, 2026-09-20) is **unobserved**, not asserted.
- `@prisma/client` (runtime used by Jest specs) has no checkpoint dependency in the lock; pinning the variable for those steps is defensive and costless.

## 2. Changes to SLOT_REQUEST_03 (apply on execution; text of 03 is not rewritten)
1. **Global env (§0 "Env for all steps") gains** `CHECKPOINT_DISABLE=1`, exported once before step 01 and inherited by every step 01–14, i.e. also by `npm ci` (step 02, lifecycle scripts already skipped), the lefthook-run hooks (step 07), tsc (13) and Jest (14).
2. **Header stamp for every step log** (§1 pattern) gains the field `CHECKPOINT_DISABLE='${CHECKPOINT_DISABLE:-unset}'` next to `NODE_OPTIONS`/`npm_config_offline`. A header showing `unset` on any step is a stop before running that step's command.
3. **Step 03 command becomes explicit-inline** (belt and braces, so the log line itself carries both guards):
   ```
   CHECKPOINT_DISABLE=1 PRISMA_GENERATE_SKIP_AUTOINSTALL=true PRISMA_HIDE_UPDATE_MESSAGE=1 \
     node node_modules/prisma/build/index.js generate
   ```
   Post-conditions unchanged (`Generated Prisma Client (v6.19.3)`, deepmerge-ts 8.0.0 / @prisma/config 6.19.3 recorded). Add to the footer: `client_boundary: CHECKPOINT_DISABLE=$CHECKPOINT_DISABLE PRISMA_GENERATE_SKIP_AUTOINSTALL=$PRISMA_GENERATE_SKIP_AUTOINSTALL` (same stamp form S2 uses).
4. **Step 06 (offline hook-resolution proof)** gains one line: `echo "CHECKPOINT_DISABLE=${CHECKPOINT_DISABLE-unset}"` → must print `1`, proving inheritance into the shell that will spawn the hooks.
5. **Any future Prisma CLI invocation by this lane** (none other is in request 03; the release-path re-observation of SLOT_REQUEST_02 §6 belongs to the S2 owner, whose harness already stamps `CHECKPOINT_DISABLE=1`) must carry the same inline pair `CHECKPOINT_DISABLE=1 PRISMA_GENERATE_SKIP_AUTOINSTALL=true` and stamp it in its log header. Engine-binary download disclosure (W3) is unaffected by this variable and remains a separate, visible network event.

## 3. What this does not change
Bounds, lock pattern, step order, commit message, identity checks, targeted lists, warnings W1–W8, and the non-grant status of request 03. It adds no claim that egress occurred or was prevented historically; a future run's log header/footer stamps are the first observation.
