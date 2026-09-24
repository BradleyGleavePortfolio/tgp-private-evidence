# PROD-CI-1 SOURCE_READY

**Status:** source ready at the grant's stop point. No push was made, no PostgreSQL was started, and no remote CI has run on this head. Acceptance needs remote CI green on the parent's `land/prod-ci-1` PR plus one independent T3 review. Written 2026-09-24 ~17:23Z.

## Binding

| Field | Value |
|---|---|
| Repo | `BradleyGleavePortfolio/growth-project-backend` |
| Worktree / branch | `/home/user/workspace/worktrees/prod-ci-1` / `prod-ci-1` |
| Base (parent) | `7d2895e1fe03ea82353e8ce0b07aacaf66af74c8` (the #530 head, `integration/importer`) |
| **Head** | `c7a5fe8dd0b82fb2c81847d875e0e03912faff26` |
| **Tree** | `74b9706497d995bf4bf07744a63793b423e88983` |
| Author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` on both fields. Unsigned (`%G?`=N). |
| Commit count and trailers | 1 commit on the base. `git interpret-trailers --parse` returns empty. |
| Files | `M .github/workflows/migration-dry-run.yml` (blob `ee17ac1`→`7599edf`), `M scripts/release.sh` (blob `c86b3ab`→`9cdf29f`, mode 100755 kept). Nothing else changed. |
| Status | Clean: 0 tracked-change lines. |
| Diff file | `PROD_CI_1.diff` (sha256 `2b0c4d89c79a6f36d32c0dd527bc0a8addce62555eb148cdab94a8b529e33747`, 116 lines) |

Commit message: `COMMIT_MSG.txt`. Subject: `ci: silence intended SC2016 in release.sh and reverse staged downs in chain order`.

## What changed

- **A. `scripts/release.sh`** gets one comment line immediately before the `if APPLIED_COUNT=$(… node -e '` line, and nothing else. The line is exactly the text the grant specifies.
- **B. `migration-dry-run.yml`** changes in the `run:` block of the step "Enforce reversibility + prove schema parity on each NEW migration" (job `reversibility-check`) and nowhere else.
  - `ALL_DIRS` holds every `prisma/migrations/*` directory, sorted with `LC_ALL=C sort`.
  - For each new directory X that has a `down.sql`:
    1. If any later directory lacks a `down.sql`, FAIL with an explicit message.
    2. Reset and migrate forward, as today, and take the BEFORE dump.
    3. Apply the `down.sql` of each later directory, newest first, then X's `down.sql`.
    4. Re-apply X's `migration.sql` and each later `migration.sql`, oldest first.
    5. Take the AFTER dump and require a byte-identical `diff -u`, as today.
  - The IRREVERSIBLE and "neither" paths are unchanged.

## Exact diff

```diff
diff --git a/.github/workflows/migration-dry-run.yml b/.github/workflows/migration-dry-run.yml
index ee17ac1..7599edf 100644
--- a/.github/workflows/migration-dry-run.yml
+++ b/.github/workflows/migration-dry-run.yml
@@ -570,6 +570,11 @@ jobs:
             npx prisma migrate deploy >/dev/null
           }
 
+          # Every migration directory in apply order: byte-wise ascending by
+          # directory name, in the same prisma/migrations/<name> form as
+          # NEW_DIRS. Used to reverse each NEW directory as part of its chain.
+          mapfile -t ALL_DIRS < <(find prisma/migrations -mindepth 1 -maxdepth 1 -type d | LC_ALL=C sort)
+
           FAIL=0
           while IFS= read -r dir; do
             [ -z "$dir" ] && continue
@@ -592,22 +597,65 @@ jobs:
             fi
 
             # down.sql present — prove it actually reverses the migration.
-            echo "  down.sql present — verifying forward → down → forward schema parity."
+            #
+            # Staged down.sql files are fail-closed and refuse while a later
+            # migration's objects are still present (the G2 downs must run
+            # R, then B, then E). So reverse $dir in its only valid order:
+            # from the migrated tip, apply the down.sql of every later
+            # directory (newest first), then $dir/down.sql; re-apply
+            # $dir/migration.sql and every later migration.sql (oldest
+            # first); require a byte-identical schema. With no later
+            # directory this is forward → down → forward on $dir alone.
+            idx=-1
+            for i in "${!ALL_DIRS[@]}"; do
+              if [ "${ALL_DIRS[$i]}" = "$dir" ]; then
+                idx=$i
+                break
+              fi
+            done
+            if [ "$idx" -lt 0 ]; then
+              echo "  FAIL: $dir is not a directory under prisma/migrations."
+              FAIL=1
+              continue
+            fi
+            CHAIN=("${ALL_DIRS[@]:$idx}")
+            missing=0
+            for later in "${CHAIN[@]:1}"; do
+              if [ ! -f "$later/down.sql" ]; then
+                echo "  FAIL: $later applies after $dir but has no down.sql; $dir cannot be reversed in chain order."
+                missing=1
+              fi
+            done
+            if [ "$missing" -ne 0 ]; then
+              FAIL=1
+              continue
+            fi
+            echo "  down.sql present — verifying forward → down chain (${#CHAIN[@]} dir(s), newest first) → forward schema parity."
 
             reset_and_migrate_forward
             BEFORE=$(mktemp)
             dump_normalized > "$BEFORE"
 
-            echo "  Applying $dir/down.sql ..."
-            if ! $PSQL -f "$dir/down.sql" >/dev/null; then
-              echo "  FAIL: $dir/down.sql did not apply cleanly."
-              FAIL=1
-              continue
+            chain_ok=1
+            for (( i = ${#CHAIN[@]} - 1; i >= 0; i-- )); do
+              echo "  Applying ${CHAIN[$i]}/down.sql ..."
+              if ! $PSQL -f "${CHAIN[$i]}/down.sql" >/dev/null; then
+                echo "  FAIL: ${CHAIN[$i]}/down.sql did not apply cleanly (reversing $dir)."
+                chain_ok=0
+                break
+              fi
+            done
+            if [ "$chain_ok" -eq 1 ]; then
+              for mig in "${CHAIN[@]}"; do
+                echo "  Re-applying $mig/migration.sql ..."
+                if ! $PSQL -f "$mig/migration.sql" >/dev/null; then
+                  echo "  FAIL: re-applying $mig/migration.sql after the down chain for $dir failed."
+                  chain_ok=0
+                  break
+                fi
+              done
             fi
-
-            echo "  Re-applying $dir/migration.sql ..."
-            if ! $PSQL -f "$dir/migration.sql" >/dev/null; then
-              echo "  FAIL: re-applying $dir/migration.sql after down.sql failed."
+            if [ "$chain_ok" -eq 0 ]; then
               FAIL=1
               continue
             fi
@@ -616,9 +664,9 @@ jobs:
             dump_normalized > "$AFTER"
 
             if diff -u "$BEFORE" "$AFTER" > schema-parity.diff; then
-              echo "  OK: schema is byte-identical after forward → down → forward."
+              echo "  OK: schema is byte-identical after forward → down chain → forward."
             else
-              echo "  FAIL: $dir/down.sql does not faithfully reverse migration.sql."
+              echo "  FAIL: $dir/down.sql (with its down chain) does not faithfully reverse the migrations."
               echo "        Schema differs after re-applying forward:"
               sed 's/^/        /' schema-parity.diff
               FAIL=1
diff --git a/scripts/release.sh b/scripts/release.sh
index c86b3ab..9cdf29f 100755
--- a/scripts/release.sh
+++ b/scripts/release.sh
@@ -323,6 +323,7 @@ echo "[release]   verifiers_passed = ${VERIFIER_COUNT} (discovered=${DISCOVERED_
 # leaves ALL_APPLIED=unknown (observability metric; gating unchanged).
 # (S2 B1 finding D2, 2026-09-22)
 APPLIED_TMP=$(mktemp)
+# shellcheck disable=SC2016  # JS source for node -e; $queryRaw must not expand
 if APPLIED_COUNT=$(DIRECT_URL="${DIRECT_URL}" node -e '
   const { PrismaClient } = require("@prisma/client");
   const prisma = new PrismaClient({ datasourceUrl: process.env.DIRECT_URL, log: [] });
```

## Local receipts

The full output is in `LINT_RECEIPTS.txt`. Tools:

- Official shellcheck **0.9.0** release binary, the same version CI uses (tarball sha256 `700324c6…`).
- actionlint **1.7.7**, the version the CI workflow pins (sha256 `023070a2…`).
- Local shellcheck 0.11.0.

Both downloaded binaries sit in the scratch folder `/tmp/prod-ci-1-tools`, outside the workspace.

| # | Check | Result |
|---|---|---|
| R1 | Replica of the CI command: shellcheck 0.9.0 on all 10 `scripts/*.sh` at HEAD | **rc=0** |
| R2 | Same check on the base `release.sh` | rc=1, SC2016 at line 326. This matches the #530 CI log (`ci_530_shellcheck_job.log`). |
| R3 | shellcheck 0.11 at HEAD | rc=1 on SC2329 at `release.sh:72` only. This is pre-existing on `main`, and 0.9.0 does not flag it, so it is **C** and nothing was added for it. |
| R4 | Scope probe: a copy with an extra SC2016 after the `fi` | Still reported. The directive covers only the `if`…`fi` compound, and the only other single-quoted string in that compound is a `sed` expression with no `$`. |
| R5 | HEAD `release.sh` minus the added comment line, compared with base | Identical, so the executed bytes are unchanged. `bash -n` rc=0. |
| R6 | actionlint 1.7.7 on the whole repo, with shellcheck 0.9.0 on PATH | **rc=0** |
| R6b | actionlint with shellcheck 0.11 on `migration-dry-run.yml` | rc=0 |
| R6c | Negative control: an unquoted expansion injected into the edited step | actionlint reports SC2086, rc=1. This proves the step's script really goes through shellcheck. |
| R7 | Extracted step script at HEAD: `bash -n`, shellcheck 0.9.0 and 0.11 (`-s bash`) | All rc=0. Parsed YAML with the target `run:` masked equals the base, so every other job, step, trigger, env, `if:`, `timeout` and the `new_dirs` detection step is unchanged. |
| R8 | Location of the diff hunks | All at base lines 570–624, inside the step's `run:` block (which starts at line 524). |
| R9 | Directory order | `LC_ALL=C sort` matches the `localeCompare` order in Prisma 6.19.3 `listMigrations` for all 169 directories. The Prisma code was read from `s7-r-ready/node_modules/prisma/build/index.js` without modifying it. |

## Dry run of the harness logic without PostgreSQL

`psql`, `pg_dump` and `npx` were replaced by stubs (`scratch/stubbin/stubdb.py`) that model the schema as the set of applied migrations. In the stub, staged downs refuse unless they are the newest applied migration, which is the G2 fail-closed model. The stub dump prints randomized `\restrict` tokens so the existing normalizer is exercised.

The real tree used the #530 NEW_DIRS: `20261224…`, `20270117…`, E, B and R, taken from `ci_530_reversibility_job.log`.

| Run | Result |
|---|---|
| S2: old step, real tree | exit 1. E and B fail at `down.sql` while 20261224, 17 and R pass, which **reproduces the #530 CI pattern**. |
| S1: new step, real tree | exit 0. Chains of 5, 4, 3, 2 and 1 directories run as R→B→E→17→20261224 downs and then ascending ups, and all five pass. |
| N0 | Fixture where every directory has a down: pass |
| N1 | A later directory without `down.sql`: explicit FAIL naming every missing one. IRREVERSIBLE is still OK, and "neither" still FAILs. The old step passed X here, so the new step is stricter. |
| N2 | A lossy later down: parity FAIL. N2b: the same lossy down outside X's chain does not affect X. |
| N3 | A later down refuses: FAIL |
| N4 | A later up fails to re-apply: FAIL |
| N5 / N5b | X's own down is lossy: FAIL under both the new and the old step |

Receipts are in `scratch/dryrun_real530_receipts.txt` and `scratch/dryrun_negative_receipts.txt`. The runner is `scratch/run_dryrun.sh`. `errexit` and the arithmetic reverse loop were exercised under `bash -eo pipefail`, matching the Actions `shell: bash`.

**Not proven locally:** real PG15 `pg_dump` parity of the E, B, 17 and 20261224 chains. That is the remote CI gate.

Reasoning in support: E, B and R wrap their SQL in their own `BEGIN`/`COMMIT`, so the psql re-apply matches the prisma apply. E.down's guard is satisfied once R.down (NOT NULL, CHECK and indexes) and B.down (fence) have run, which matches R attestation A. The re-added columns (`ScoutReconstructionLedger.source_platform` and `ExtensionPairCode.import_intent_id`) have no later columns after them, so the dump column order is preserved. The extra work is about 20 small `psql -f` calls and 2 dumps against the #530 baseline of 1m10s, well inside the job's unchanged `timeout-minutes: 10`.

## Why the gate is at least as strict

1. **Newest new directory (R):** CHAIN has length 1, so the procedure is the same as today: reset, BEFORE, X.down, X.migration, AFTER, byte diff. Only the message wording changed.
2. **Older new directory X:** every assertion the old step made is still made. X.down must apply cleanly, X.migration must re-apply cleanly, and the whole schema must be byte-identical to the migrated tip. The new step adds these assertions:
   - every later directory must have a `down.sql`, or the step FAILs explicitly;
   - every later `down.sql` must apply cleanly in reverse order;
   - every later `migration.sql` must re-apply cleanly in order.
3. **The only condition dropped** is "X.down applies while later migrations are still present". That is exactly the state the fail-closed staged downs exist to refuse, and it is not a valid rollback path. Keeping it would force the guards to be weakened, which is the harm the grant names.
4. **The step fails closed on its own anomalies:**
   - X missing from the listing, or an empty listing: FAIL.
   - If the sort ever diverged from Prisma's order, a directory could only move into or out of X's chain. That produces either a conservative FAIL or the old single-directory check, never a weaker one. The order is identical for this tree (R9).
5. The IRREVERSIBLE path, the "neither" path, `new_dirs` detection, triggers, the job and every other step are unchanged (R7, R8).

## Recorded, not closed (C)

- **C-1, masking blind spot.** Byte parity is observed after the later ups are re-applied. If X.down over-dropped an earlier object and a later `migration.sql` idempotently re-created it, the check would miss it. The old gate had the same blind spot with respect to X's own `migration.sql`; the new gate only widens which statements could mask the over-drop.
  - Optional closure, not applied because it is outside the granted minimum: add a dump before and after X's own down/up at its chain position and diff the two.
- **C-2, stale header comment.** Item 4 of the file header (lines 88–95) still describes the single-directory procedure. It was left untouched to keep the edit inside the step, and the in-step comment describes the new behaviour.
- **C-3, IRREVERSIBLE later migrations.** A new directory with a `down.sql` that is followed by an IRREVERSIBLE later migration now always FAILs. This is conservative, as the grant specifies.
- **C-4, local hooks.** Genuine Lefthook hooks ran:
  - pre-commit `banned-cast-tokens`: rc 0, "no positive token change";
  - `prod-readiness-quick`: a no-op, because its script is absent;
  - commit-msg `no-ai-tokens`: rc 0.

  `tsc`, `eslint` and `prettier` were excluded with `LEFTHOOK_EXCLUDE`, for these reasons:
  - the worktree has no `node_modules`, as the grant allows;
  - no TS or JS file is staged, so eslint's glob would match nothing;
  - tsc is a heavy-slot operation this grant does not include;
  - prettier is not a CI gate, and the YAML edits sit inside a block scalar.

  Output is in `commit_hook_output.txt`.
- **C-5, Lefthook rewrote shared hook files.** Lefthook's automatic "sync hooks" rewrote the shared hook shims `s7-b-drain/.git/hooks/{pre-commit,commit-msg}` and `info/lefthook.checksum` in the common git dir at 17:21:22Z. It used the same lefthook 2.1.9 binary and a `lefthook.yml` that is byte-identical in `prod-ci-1`, `s7-b-drain` and `s7-r-ready` (md5 `43d8aa1b…`). The new worktree's `lefthook.yml` mtime triggered the sync. No other worktree's files were touched.

## Honesty notes

- Requested route: Claude Opus 5 / XHigh. **No telemetry is claimed.**
- GitHub use was read-only: PR #530 checks and the two failing job logs were saved as `ci_530_*.log`.
- Nothing was pushed. No PG cluster was started or touched, the heavy-slot lock was not touched, and no deploy config was changed.
- Writes were limited to the `prod-ci-1` worktree, this directory, the scratch tools folder `/tmp/prod-ci-1-tools`, and the Lefthook shim sync in C-5.

## Next (parent)

Push `c7a5fe8d` as `land/prod-ci-1` and open a PR to `integration/importer`. The workflow's own path triggers `migration-dry-run`. Then run the remote CI and one independent T3 review. After landing, re-run `infra-lint` on #530.
