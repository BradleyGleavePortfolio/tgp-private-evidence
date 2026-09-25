# EXEC-DACEDDC8 scope and grants

Executive operator: session `daceddc8-dd20-4059-bf36-3a97530ca811` (Computer). Authority: Bradley's current takeover prompt ("FULL PROJECT TAKEOVER — RESUME FROM DURABLE STATE"), with standing EXECUTE and autonomous non-production landing. It supersedes the 05:56Z owner handoff freeze (`64e33dc7/HANDOFF_FREEZE.md`) because it is Bradley's later explicit instruction. That freeze's evidence stays immutable. Every 64e33dc7 grant, relay and worker stays revoked unless it is re-issued here.

Owner-reserved, never crossed: production deployment or `integration/importer` → backend `main` (PR #530), customer enablement, destructive production mutation, live source-account operation, security governance, branch-protection changes or bypass, extension approval bypass (PR #27), Chrome Web Store, external commitments, new spending, S8-D/S8-E principal policy (D-S8-2), G3-AUTH.

Invariants: Bradley Gleave `<bradley@bradleytgpcoaching.com>` author and committer, ordinary genuine-hook commits, no AI trailers, no amend/bypass/force push. One canonical heavy slot, `/home/user/workspace/execution/test-validation.lock`, taken nonblocking in the working process. Never delete, steal or replace the lock. No concurrent real-PG proofs. Consumed drivers and failed lanes stay immutable. A failure is preserved and stopped for disposition, never looped.

## Fresh-sandbox facts (16:10–16:20Z)

This sandbox started with no `/home/user/workspace/execution`, no lock file, no PG, no psql and no builder `node_modules`. Historical inode 691716 does not exist here. The first holder creates the lock file via `exec 9>>"$LOCK"`. That does not delete or replace a lock; no lock existed to inherit. Node `/usr/local/bin/node` v20.20.1 sha `a03953a7…`, npm 10.8.2, Ubuntu 26.04, 209 platform `node_modules` entries.

## RT-2: runtime re-provision (T3, parent-executed; heavy slot)

- Run `daceddc8/runtime/rt-setup.sh` (sha `ab723822…`) once under `timeout -k 30 2400`. It is byte-identical to consumed `64e33dc7/runtime/rt-setup.sh` (`f6801d30…`) except the one EVD/receipt line (see `rt-setup.diff-from-64e33dc7`). The old sentinel is never reused. All pins, refusals and the ROOT path `/home/user/workspace/execution/64e33dc7/recovery-reset` are unchanged, so every frozen v3/v4 path constant stays valid. PG 17.6 pins: jar `23da5a04…`, txz `26fa6334…`, postgres `23cd1748…`, initdb `b7db9bc2…`. Donor at `93389265`: genuine `npm ci` and `npx prisma generate`, expected client `b6716a86…` and hidden lock `05bc530a…`.
- Then run `daceddc8/runtime/formatter/fmt-tool.sh` (sha `861a831d…`) once. It is identical to `64e33dc7/runtime/formatter/fmt-tool.sh` except the EVD line. Pins: prettier@3.9.9 integrity `sha512-Z/CJHIkd…`.
- Then run `daceddc8/runtime/lane-provision.sh` (sha `c1bd42ec…`) once. Written and hashed before it runs, it does the following:
  - Real `cp -a` of donor `node_modules` into both builder worktrees.
  - Verifies the hidden lock `05bc530a…` in each.
  - In S7-L only, `npx --no-install prisma generate` from its committed schema (`0eb41f9a…`). The result must equal the recorded `9042e713…`.
  - Copies the isolated prettier prefix into `recovery-reset/{s7l,s8c}/tools/prettier-3.9.9` and verifies it against the 56-file manifest.
- Any mismatch refuses. Nothing is repinned.
- No initdb, cluster, bootstrap, Jest, tsc or proof happens under RT-2.

## S8C-BC-2: bootstrap correction completion (T4; parent executes the prepared mechanical steps)

- The exact WIP is already reapplied on `87018a42` (blob `7c3fba47…`, +7/−2).
- After RT-2 releases the lock, run the prepared `64e33dc7/s8c/handoff-freeze/scripts-and-previews/s8c-bootstrap-gate.sh` (`b589713b…`) unchanged, with `S8C_BOOTSTRAP_RELAY=1`: one genuine hooked commit, first failure stops.
- Export `s8c/checkpoints/v6/` (bundle and manifest) and write `s8c/bootstrap-correction/CORRECTION_RECEIPT.md`.
- Prepare `s8c/binding/v4/` with `prepare-binding-v4.sh`. The single recorded reconsideration: both other-lane loops enumerate `"$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-v3/clusters/*/ "$RUNTIME_ROOT"/proof-v4/clusters/*/` and exclude own `$LANE/` by path, so a concurrently prepared sibling v4 lane is protected. Nonexistent directories are skipped by the existing `[ -d ]` guard.
- The derived script and its diff are recorded under `s8c/bootstrap-correction/`. Other pins are unchanged.
- No PG.

## S7L-WC-1: worker runtime-identity correction (T4 builder subagent, sole writer of `worktrees/64e33dc7-s7l`)

- Ordinary follow-up on `a68cdac7`. The only product path is `test/utils/g2-s7l-worker.cjs`.
- Resolver: redirect `'@prisma/client/runtime/library'` and its `.js` form to `join(input.client,'runtime/library.js')` when that file exists, else fall through. This is the minimum closure both runtime reviews agree on (A `02a60a70…`, B `b1369f8a…`).
- Only on the parent's slot relay: scoped pinned prettier/eslint on that file, then one genuine hooked commit with heap 4096. No Jest, no PG.
- Export `s7l/bundle/v4` and write `s7l/worker-correction/CORRECTION_RECEIPT.md`.
- Prepare `s7l/binding/v4/`:
  - Fresh `proof-v4/clusters/s7l`, `proof-v4/run/s7l` and `proof-v4/s7l/old-root`.
  - `EXPECT_PARENT=a68cdac7`, with the lineage and one-path delta updated.
  - New HEAD, TREE, WORKER blob and fixture sha.
  - The same three-glob loop enumeration as S8C-BC-2.
  - All other pins unchanged.
- Source-only binding checks.

## REV-2: independent changed-question reviews (T4, read-only, nonbuilder, no peer reads)

- S8-C: `s8c/reviews/BOOTSTRAP_CORRECTION_REVIEW_A.md` and `_B.md`.
- S7-L: `s7l/reviews/WORKER_CORRECTION_REVIEW_A.md` and `_B.md`.
- Scope: the changed bytes, lineage, gate receipts, and the exact v4 binding and fresh paths only. No accepted-source re-audit.

## PG-4: single proofs (granted separately after dual GO)

Each candidate gets exactly one `timeout -k 30 3900 bash <lane>/binding/v4/<driver>.sh`, serialized on the lock, with a terminal receipt. A full pass means acceptance of that exact candidate only.

## Heavy-slot queue

1. RT-2.
2. S8-C gate commit.
3. S7-L gate commit (on relay).
4. S8-C v4 proof.
5. S7-L v4 proof.
6. Composition gates.

Reviews and source work run in parallel with the slot.

## Routing

T4 builders and reviewers request `claude_fable_5_1` (doctrine). Requested route is not telemetry. Any platform refusal of that route is recorded here verbatim; no local substitution is invented. 16:27Z: the platform accepted `claude_fable_5_1` for `s7_l_worker_correction_muh68jv6`.

## RT-2 result (16:34Z)

All three steps finished RC=0: rt-setup 16:29:20Z, fmt-tool 16:30:03Z, lane-provision 16:33:54Z. Every pin reproduced:

- psql 18.6 `a200e38c…`
- PG 17.6 jar, txz, postgres, initdb and pg_ctl
- donor hidden lock `05bc530a…`, client `b6716a86…`
- hooks: pre-commit `3b741de3…`, commit-msg `71029ce8…`
- S7-L in-lane client `9042e713…` and client schema `b8439203…`
- S8-C client `b6716a86…`
- both prettier prefixes: 56 files, `npx prettier` 3.9.9

Canonical lock inode is 674373, new in this sandbox. The first lane-provision launch refused at preflight: rc75, lock busy in the same second fmt-tool exited, no work done, no sentinel written. It was relaunched once and the attempt is preserved. Slot was free at 16:34:00Z.

## Orchestrator-only operating mode (Bradley, 16:32Z)

Per Bradley's 16:32Z instruction, the parent orchestrates only. Coding, gates, bindings and reviews go to subagents. Parent-prepared helper scripts (`s8c/bootstrap-correction/prepare-binding-v4-daceddc8.sh` `7c21f142…`, `export-v6-daceddc8.sh`) are handed to the S8-C builder, which verifies and owns them.

## Additional grants (16:35Z)

- **S8C-BC-2 builder:** `s8c_bootstrap_completion` (T4, `claude_fable_5_1`) owns `worktrees/64e33dc7-s8c` plus new `s8c/bootstrap-correction/run/`, `s8c/checkpoints/v6/`, `s8c/binding/v4/` and `CORRECTION_RECEIPT.md`. It is sole heavy-slot grantee now, for the gate commit only.
- **S8F-COMP-1:** `s8f_composition_prep` (T4, `claude_fable_5_1`) owns new worktree `worktrees/daceddc8-s8f` (detached at `87018a42`, later moved onto the accepted S8-C head) plus `64e33dc7/s8f/composition/**`.
  - Scope: compose the frozen 15-path draft onto S8-C, the F03 `programs` unskip, and a contract-regeneration plan.
  - Source only. No lock, gates, commit or PG.
- **S8G-DRAFT-1:** `s8g_design_test_draft` (T4, `claude_fable_5_1`). Evidence only, under `64e33dc7/s8g/draft/**`: design and acceptance-test drafting from READINESS E1–E6/N1–N4 on the DRAFT_READY pins. No product bytes, worktree writes, gates or PG.
- **LAND-PREP-1:** `landing_composition_prep` (T3, `claude_opus_5_5`). Read-only plan and scripts under `daceddc8/landing/**` for landing S7-L and S8-C onto `integration/importer`: order, the `importer-openapi.json` overlap and regeneration ownership, CI, and the PR/FF procedure. No pushes, PRs or heavy runs.
- **S9-READY-1:** `s9_readiness` (T4, `claude_fable_5_1`). Read-only readiness brief under `daceddc8/s9/READINESS.md`. No product writes.

## PG-4a grant: S8-C v4 single real-PG proof (16:48Z)

- **Preconditions met:** `BOOTSTRAP_CORRECTION_REVIEW_A.md` (`c63de02f…`) and `_B.md` are both final GO. All findings are class C: HEAD.txt label, PINS.txt L57 documentary line, and a no-op reflog reset.
- **Parent read-only preflight (16:46:29Z):**
  - lock inode 674373, 0 holders
  - 0 postgres; 55641, 55642 and 55643 free
  - `proof-v4/{clusters,run}/s8-c` absent; `binding/v4/run/` absent
  - supervisor `798d9f7c…`, RUN_PREP 2/2 OK
- **Grantee:** `s8c_bootstrap_completion` as proof executor.
- **Launch:** exactly once, `S8C_PG4_GRANT=1 bash …/s8c/binding/v4/run-prep/supervisor.sh`. That runs one detached `timeout -k 30 3900 bash …/s8c/binding/v4/s8c-pg-proof.sh` against candidate `e0cee7e0…` (tree `b249efb6…`), with driver `73b291db…`, fixture `c59326b5…` and manifest `c2cfd0a3…`.
- **Rules:** no rerun on any rc, no edits, preserve all receipts. A full pass (END rc=0, stage=post, all Jest passed) means the parent may accept and land. Anything else goes to disposition.
- **Heavy queue:** the S7-L v4 proof waits for this run's release plus its own dual GO.

## PG-4a result and S8C-BC-3 grant (16:56Z)

PG-4a is consumed. It FAILED `RC=1 STAGE=jest`: 13 of 13 tests failed in harness `catalog()` on the `ExerciseCatalogItem.updated_at` NOT NULL. See `64e33dc7/S8C_V4_FAILED_PROOF_DISPOSITION.md` (class B, harness-only).

- **Grantee:** `s8c_bootstrap_completion` (T4, `claude_fable_5_1`) under **S8C-BC-3**.
- **Harness correction:** minimum harness-only fix plus a full sweep of the raw SQL in S8-C test support.
- **Diagnostics:** scratch-lane diagnostics under the slot, as the disposition allows.
- **Commit:** one genuine hooked Bradley commit on `exec64/s8c-replacement` (child of `e0cee7e0`).
- **Evidence:** checkpoint v7 and binding v5, derived mechanically from v4 (paths under `proof-v5`, head/tree/changed-blob pins, fixture pin), plus `run-prep` v5 and a receipt. All writes go under `s8c/harness-correction/**`, `s8c/checkpoints/v7/` and `s8c/binding/v5/`.
- **Slot:** the builder must acquire the canonical lock with `flock -n` and yield to any holder, and must never run concurrently with the S7-L proof.

## LAND-1 grant: order swap and CI pre-staging (17:00Z)

LAND-PREP-1 returned PLAN_READY (`daceddc8/landing/`, all risks class C). S8-C's v4 proof failed, and S7-L is next in the proof queue, so the parent takes the plan's symmetric alternative: **S7-L lands first by fast-forward, then S8-C is composed second.**

**R5 decision:** pre-staging CI is allowed, as it was for PR #531. `landing_composition_prep` (T3, `claude_opus_5_5`) may:
- push branch `land/s7-l-accepted` pointing exactly at `df713fd9217df524915348ef8a42c797f288dde1` (no new commits);
- open a DRAFT PR to `integration/importer` titled "Land S7-L: …";
- watch CI and record the check results.

It may not:
- mark the PR ready, merge, or push `integration/importer`;
- touch `main`, protection or settings, or force-push.

Acceptance and the fast-forward happen only on the parent's word, after the S7-L PG-4b proof passes.

## PG-4b grant: S7-L v4 single real-PG proof (16:58Z)

- **Preconditions met:** `WORKER_CORRECTION_REVIEW_A.md` and `_B.md` (`d9634549…`) are both final GO, class C only.
- **B's C-8 item:** the parent verified run-prep separately: supervisor `eb9bb86b…`, RUN_PREP 2/2 OK, only 3 files, `binding/v4/run` absent.
- **Parent preflight (16:57:24Z):**
  - lock inode 674373, 0 holders; 0 postgres; no 556xx listeners
  - `proof-v4/{clusters,run}/s7l` and `proof-v4/s7l/old-root` absent
  - no jest/tsc/prisma/prettier/eslint/lefthook/driver process
- **Grantee:** `s7_l_worker_correction` as proof executor.
- **Launch:** exactly once, `S7L_PG4_GRANT=1 bash …/s7l/binding/v4/run-prep/supervisor.sh`. That runs one detached `timeout -k 30 3900 bash …/s7l/binding/v4/s7l-pg-proof.sh` against `df713fd9…` (tree `796f437f…`), with driver `8b03f4c2…`, fixture `74aed261…` and manifest `6c912b96…`.
- **Rules:** a lock-busy refusal before `LAUNCH.txt` or the sentinel does not consume the grant. No rerun on any consumed rc. A full pass means accept, then land by FF under LAND-1.
- **Slot:** the S8-C diagnostics yield until this run ends.

## S7-L accepted; LAND-1 fast-forward authorized (17:03Z)

See `64e33dc7/S7L_ACCEPTANCE.md`. `landing_composition_prep` may, once the draft PR's CI shows green apart from the known class C Danger title rule:
1. mark the PR ready;
2. fast-forward `integration/importer` from `93389265` to `df713fd9` with one ordinary push, no force;
3. verify the remote head and record it.

Owner-reserved limits are unchanged: never touch `main`.

The canonical slot passes to S8-C BC-3 diagnostics.
