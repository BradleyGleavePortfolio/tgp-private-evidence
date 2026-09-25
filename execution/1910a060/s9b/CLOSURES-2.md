# S9-B CLOSURES-2 (parent disposition 15:31 PT: binding v2 + small source; source-only, no lock/installs/tests/gates/commit/PG)

Pre-edit bytes of every touched file are kept beside this file as `closures-2/pre-*` and hash-verified; the exact
unified diffs are inlined below. Nothing was executed except `bash -n` on the two shell files, `sha256sum`, `grep`
and a standalone regex pass; the runner takes the canonical lock before its first check, so it was NOT run.

## A. Owned test util (clone `/home/user/workspace/worktrees/1910a060-s9b`, HEAD still `1c5fbb04`)

| File | pre sha256 | post sha256 |
| --- | --- | --- |
| `test/utils/g2-s9-db.ts` | `a1611c51c367fc796e5983d7b0aa7f60de68565febd65ead8346acff0545aaf7` | `39ba033bea0402483287da1a59e805b778a652286c359e807c363f5d87ba2ae9` |
| `test/scout/g2-s9-db-guard.spec.ts` | `307d8fa4a60ae3bc09e5a9084273b5c1f79d23147098e3e472c778a2b5452879` | `a99cf9c9e9cef10290d63b52fd773dcecfa22669933532fe78a61dd1e66e4fbf` |

- `REFUSED_PORTS` gains `'55644'` (S8-G's lane, 1910a060/s8g); the lane comment now states 55643 = S8-F
  (64e33dc7/s8f binding v2) and 55644 = S8-G, and 55645 as the chosen (not "suggested") S9 port. Nothing removed.
- The guard spec's `it.each` refusal matrix gains three URL cases: port 55642, 55643, 55644 (it previously enumerated
  only up to 55641). Additive only; no assertion weakened. The other nine owned clone files are unchanged
  (CLOSURES-1 shas stand). R75 policy regex pass on both files: 0 hits.
- `gate/PINS.env` re-pinned `SHA_G2_DB` / `SHA_G2_GUARD_SPEC` (`9e6d0bc7cff1e1199b4159ad20f0bb6d2ca7b2975969f860270e2e968b3962bc` → `ebc12e899ca762883565e363f65633ba5f6cf65ef48fa34aef3c6f9c0659ad97`).

## B. Binding v2 (`binding/v2/`, unrun)

| File | pre sha256 | post sha256 |
| --- | --- | --- |
| `s9b-pg-proof.sh` | `0633ec9217f4788b2fd5eec5bdc59d3b90f5a6f7a1dc896c8320377666c9822b` | `7ba9353b8b53d4284f0f5a69bc5b69b9af1fedb31b7753eaed7c100e0a2cc31e` |
| `s9b-fixture.sh` | `02dd93da33e0696696f62c5e1b927a922d009ea5d1364cba9ac4751ad9244c2c` | `1ee369641ca0d5b2706947eeb6abf46770a51f648700f235dc3d72936a56a66b` |
| `PINS.txt` | `84b548f92f7ce3bef51a1633d922123201fb0c129593b50b933f66e3240d4766` | `1188214305c66f2c148bd4f7d331db437f4e745b84e232e02aa29df5e9bf894b` |
| `README.md` | `4de310520e1a150f0f7d5387c2d66eb076d27b1effb55cfc178d096e179be16e` | `c9210cbd96b14af61c7f226a4008112a14e60dce37712ba961b710df65b87c86` |
| `BINDING.sha256` | (new) | lists the four files above; `sha256sum -c` OK |

Closure map (parent items 1-6):

1. `D=…/binding/v2`; stale v1 labels fixed: runner usage line (old L19), `EXPECT_FIXTURE_SHA` comment (old L44),
   fixture header (L5), PINS.txt header (L1) and fixture-sha comment (L17). The identity comment (old L62) no longer
   repeats `G2_S9_*` as an excluded name; it lists `G2_S8G_*, G2_S8F_*, G2_S8C_*, G2_S8B_*, G2_S7L_*`.
2. Fixture `RUNTIME_ROOT=/home/user/workspace/execution/1910a060/runtime` (was the 64e33dc7 `recovery-reset` root — a
   real defect, not a label); runner carries the same literal (was `__FILL_FROM_RUNTIME_RECEIPT__`) and, right after
   the fixture-sha check, cross-checks whole-line: `grep -qx "RUNTIME_ROOT=$RUNTIME_ROOT" "$FIX"` and
   `grep -qx "PORT=$PORT; SUPER=$ADMIN; PASS=$FIXPASS; MARKER=s9-disposable-pg17" "$FIX"`; mismatch → fail 70.
   Both greps were exercised against the final fixture from a plain shell (match confirmed).
3. psql: `PSQL=/usr/lib/postgresql/18/bin/psql`, `EXPECT_PSQL_REAL_SHA=d1108fdb45b87f2313d7acfbb91a0a65ca97c6c2195f15d8ae9295121029ef67`
   (RUNTIME_SETUP_RECEIPT.md; re-measured now: `sha256sum` == d1108fdb…, `psql (PostgreSQL) 18.6 (Ubuntu
   18.6-0ubuntu0.26.04.1)`), version assertion `^psql \(PostgreSQL\) 18\.`, used for `G2_S9_PSQL`, `psqlq` and the
   PRECONDITIONS_OK line; `EXPECT_PSQL_REAL_SHA` replaces `EXPECT_PSQL_SHA` in the fill-refusal `case` list. Mirrors
   `execution/64e33dc7/s8f/binding/v2/s8f-pg-proof.sh` L49-50/L144-145/L179.
4. `EXPECT_TESTS=10` (`grep -c '^\s*it('` on `test/rls-g2-s9.spec.ts` = 10; no `it.each`/`test(` forms); after
   jest rc 0: `grep -qE "^Tests: +$EXPECT_TESTS passed, $EXPECT_TESTS total"` else `JEST_COUNT_FAIL` → 72.
5. `EXPECT_LOCK_INODE=667698`; asserted via `stat -c %i` immediately after `flock -n 9` succeeds; mismatch → exit 75.
6. Other-lane scan (preflight and post) iterates `"$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-*/clusters/*/`, skips only
   `$LANE`, keys fingerprints by the runtime-root-relative path — covers `clusters/s8-g` (S8-G) and
   `proof-s8f-v2/clusters/s8-f` (S8-F, present on this host). `EXPECT_FIXTURE_SHA` filled (`1ee36964…`);
   `BINDING.sha256` written.

Still unfilled and refused by the runner: `BASE_HEAD`/`BASE_TREE` (M2), `EXPECT_HEAD`/`EXPECT_TREE`, six S9-B blob
pins, and the six remaining tool pins (postgres/initdb/pg_ctl/node/nm-lock/nm-client — to be copied from the receipt
at fill after re-verification). Runner: `bash -n` clean, 215 lines (was 202). Fixture: `bash -n` clean.

## Exact diffs

### g2-s9-db.ts

```diff
--- a/test/utils/g2-s9-db.ts
+++ b/test/utils/g2-s9-db.ts
@@ -47,8 +47,9 @@
 // 55461 is the retained stopped B lane (accepted proof at 0d69c7ba); 55471 is the retained stopped
 // R lane (accepted proof at 7d2895e1); 55481 is the N/Q1 lane; 55491 is the C lane; 55501 is the
 // S7-L lane; 55511 is the accepted S8-B lane; 55641 is the concurrent S7-L (64e33dc7) lane; 55642
-// is the S8-C lane; 55643 is the S8-G lane (64e33dc7/s8g). The S9 lane port is chosen by the parent
-// (55645 suggested; execution/1910a060), double-entered by the operator, never hard-coded.
+// is the S8-C lane; 55643 is the S8-F lane (64e33dc7/s8f binding v2); 55644 is the S8-G lane
+// (1910a060/s8g). The S9 lane port is chosen by the parent (55645; execution/1910a060),
+// double-entered by the operator, never hard-coded.
 const REFUSED_PORTS = new Set([
   '5432',
   '5433',
@@ -66,6 +67,7 @@
   '55641',
   '55642',
   '55643',
+  '55644',
 ]);
 const PRISMA_ONLY = new Set(['schema', 'connection_limit']);
 
```

### g2-s9-db-guard.spec.ts

```diff
--- a/test/scout/g2-s9-db-guard.spec.ts
+++ b/test/scout/g2-s9-db-guard.spec.ts
@@ -36,6 +36,9 @@
     base.replace('55645', '55501'),
     base.replace('55645', '55511'),
     base.replace('55645', '55641'),
+    base.replace('55645', '55642'),
+    base.replace('55645', '55643'),
+    base.replace('55645', '55644'),
     base.replace('g2_s9_disposable', 'g2_b_drain_disposable'),
     base.replace('g2_s9_disposable', 'g2_r_ready_disposable'),
     base.replace('g2_s9_disposable', 'g2_nq1_disposable'),
```

### s9b-pg-proof.sh

```diff
--- a/binding/v2/s9b-pg-proof.sh
+++ b/binding/v2/s9b-pg-proof.sh
@@ -1,7 +1,9 @@
 #!/usr/bin/env bash
-# S9-B real-PG proof — complete source-only execution binding DRAFT v2 (base re-pinned to M2, S9-A blobs = be88909f post-format, PORT=55645; UNFILLED head/runtime/tool pins; NOT RUN; NOT GRANTED).
+# S9-B real-PG proof — complete source-only execution binding DRAFT v2 (base re-pinned to M2, S9-A blobs = be88909f post-format, PORT=55645,
+# RUNTIME_ROOT = the 1910a060 runtime, real psql binary pinned (CB1 mirror of 64e33dc7/s8f/binding/v2), EXPECT_TESTS=10, lock inode 667698 asserted,
+# other-lane fingerprint scan covers clusters/* and proof-*/clusters/*; UNFILLED head + remaining tool pins; NOT RUN; NOT GRANTED).
 # Derived by substitution from the accepted S8-C binding execution/64e33dc7/s8c/binding/s8c-pg-proof.sh (unfilled
-# template, unchanged there) with the EXEC-1910A060 deltas: standalone clone worktrees/1910a060-s9b at base 1c5fbb04,
+# template, unchanged there) with the EXEC-1910A060 deltas: standalone clone worktrees/1910a060-s9b re-based onto M2 (S9-A be88909f on 62471b11; schema/lock identical to 1c5fbb04),
 # lane port 55645 / s9_super / g2_s9_disposable / cluster s9-disposable-pg17, NO OLD side (S9-B ships no
 # migration, D-S9-5: the base 1c5fbb04 prisma tree — 172 migrations, S8-B and S7-L included — is the only schema and
 # the accepted S7-L + S8-B + S8-C objects are the proof target), the candidate binding G2_S9_CANDIDATE_HEAD, and the
@@ -16,17 +18,17 @@
 # is the observed terminal evidence — sentinel/log lines, `pgrep -cx postgres`, the port listener count and any
 # survivor pid the stop reports — not this header. Data dir RETAINED after stop (destroy = separate marker-gated grant).
 # Inner stage bounds: init 60 + start 60 + bootstrap 900 + identity 5x15 + jest 1500 + stop 75 = 2670 s soft sum.
-# Usage (later, under the separate single-run PG grant): timeout -k 30 3900 bash .../binding/v1/s9b-pg-proof.sh
-# Pre-steps (each its own receipt, BEFORE the pins are filled): runtime setup for 1c5fbb04 (isolated node_modules copy +
-# in-lane `npx prisma generate` from the committed schema; its receipt fills RUNTIME_ROOT and the tool pins) → S9-A
+# Usage (later, under the separate single-run PG grant after dual review of v2): timeout -k 30 3900 bash .../binding/v2/s9b-pg-proof.sh
+# Pre-steps (each its own receipt, BEFORE the head pins are filled): runtime setup DONE (execution/1910a060/runtime/RUNTIME_SETUP_RECEIPT.md
+# fixes RUNTIME_ROOT, the real psql pin and the lock inode here; the remaining tool pins are copied from it at fill after re-verification) → S9-A
 # gates/commit (parent composition) → S9-B source gates (prettier --check, eslint --max-warnings 0, tsc, check-r75,
 # default jest incl. test/scout/reconciliation/facts.service.spec.ts and test/scout/g2-s9-db-guard.spec.ts) → ordinary
 # Bradley-authored hooked commit → source/binding export → two independent non-builder final-head attestations → fill
 # EXPECT_HEAD/EXPECT_TREE/EXPECT_*_BLOB/EXPECT_FIXTURE_SHA from the attested head (PINS.txt) → separate PG grant → this
 # script, once.
 set -uo pipefail
-D=/home/user/workspace/tgp-private-evidence/execution/1910a060/s9b/binding/v1
-RUNTIME_ROOT=__FILL_FROM_RUNTIME_RECEIPT__                                       # fresh runtime namespace for 1c5fbb04 (runtime setup lane; the 64e33dc7 root is the prior record)
+D=/home/user/workspace/tgp-private-evidence/execution/1910a060/s9b/binding/v2
+RUNTIME_ROOT=/home/user/workspace/execution/1910a060/runtime                     # 1910a060 runtime namespace (execution/1910a060/runtime/RUNTIME_SETUP_RECEIPT.md); the fixture carries the same literal and is cross-checked below
 W=/home/user/workspace/worktrees/1910a060-s9b
 R=$D/run; LOG=$R/s9b-pg-proof.log; SENT=$R/s9b-pg-proof.sentinel; JLOG=$R/jest.log
 LOCK=/home/user/workspace/execution/test-validation.lock
@@ -41,13 +43,16 @@
 EXPECT_PGH_BLOB=__FILL_AFTER_ATTESTATION__                                  # test/utils/g2-s9-pg-harness.ts
 EXPECT_HARNESS_BLOB=__FILL_AFTER_ATTESTATION__                              # test/utils/g2-s9-harness.ts
 EXPECT_WORKER_BLOB=__FILL_AFTER_ATTESTATION__                               # test/utils/g2-s9-worker.cjs
-EXPECT_FIXTURE_SHA=__FILL_AFTER_ATTESTATION__                               # sha256 of binding/v1/s9b-fixture.sh (frozen with this file)
-# ---- tool pins: filled from the 1c5fbb04 runtime setup receipt (compare only, never adjusted at run time). Prior
+EXPECT_FIXTURE_SHA=1ee369641ca0d5b2706947eeb6abf46770a51f648700f235dc3d72936a56a66b                                          # sha256 of binding/v2/s9b-fixture.sh (frozen with this file; filled below by the CLOSURES-2 pin step, not at attestation)
+# ---- tool pins: filled from the 1910a060 runtime setup receipt (compare only, never adjusted at run time). Prior
 #      64e33dc7 records are listed in PINS.txt for comparison; a pin is copied only when the receipt re-verifies it.
 EXPECT_POSTGRES_SHA=__FILL_FROM_RUNTIME_RECEIPT__
 EXPECT_INITDB_SHA=__FILL_FROM_RUNTIME_RECEIPT__
 EXPECT_PGCTL_SHA=__FILL_FROM_RUNTIME_RECEIPT__
-EXPECT_PSQL_SHA=__FILL_FROM_RUNTIME_RECEIPT__       # readlink -f /usr/bin/psql
+PSQL=/usr/lib/postgresql/18/bin/psql                # CB1: the real client binary, not the /usr/bin/psql pg_wrapper dispatcher (64e33dc7/s8f/binding/v2 mirror)
+EXPECT_PSQL_REAL_SHA=d1108fdb45b87f2313d7acfbb91a0a65ca97c6c2195f15d8ae9295121029ef67   # sha256 of $PSQL (postgresql-client-18 18.6-0ubuntu0.26.04.1; RUNTIME_SETUP_RECEIPT.md, re-measured 2026-09-25)
+EXPECT_TESTS=10                                     # it() count in test/rls-g2-s9.spec.ts (verified by grep on the source; re-verify at fill against the attested head)
+EXPECT_LOCK_INODE=667698                            # execution/1910a060/runtime/LOCK_ESTABLISHED.txt
 EXPECT_NODE_SHA=__FILL_FROM_RUNTIME_RECEIPT__       # node v20.x
 EXPECT_NM_LOCK_SHA=__FILL_FROM_RUNTIME_RECEIPT__    # node_modules/.package-lock.json (donor; package-lock unchanged since 93389265)
 EXPECT_NM_CLIENT_SHA=__FILL_FROM_RUNTIME_RECEIPT__  # node_modules/.prisma/client/index.d.ts generated from schema 0eb41f9a (S9-B ships no schema change)
@@ -59,9 +64,9 @@
 export GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1 NODE_OPTIONS=--max-old-space-size=4096 CHECKPOINT_DISABLE=1 \
        PRISMA_HIDE_UPDATE_MESSAGE=1 npm_config_offline=true npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false \
        npm_config_cache=$RUNTIME_ROOT/npm-cache XDG_CACHE_HOME=$RUNTIME_ROOT/xdg-cache
-# S9-only identity: exactly the G2_S9_* names the guard/harness/bootstrap read. Nothing G2_S9_*, G2_S8B_*, G2_S7L_* or earlier is exported.
+# S9-only identity: exactly the G2_S9_* names the guard/harness/bootstrap read. Nothing G2_S8G_*, G2_S8F_*, G2_S8C_*, G2_S8B_*, G2_S7L_* or earlier is exported.
 export G2_S9_DATABASE_URL="postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=4" \
-       G2_S9_CONFIRM="$DBNAME:$PORT" G2_S9_PASSWORD=$FIXPASS G2_S9_PSQL=/usr/bin/psql \
+       G2_S9_CONFIRM="$DBNAME:$PORT" G2_S9_PASSWORD=$FIXPASS G2_S9_PSQL=$PSQL \
        G2_S9_DATA_DIRECTORY=$LANE/pg-data G2_S9_SERVER_VERSION=170006 \
        G2_S9_CANDIDATE_HEAD=$EXPECT_HEAD
 export S9B_RUNNER_PID=$$ S9B_STOP_TIMEOUT=45
@@ -69,6 +74,7 @@
 [ -e "$SENT" ] && { echo "REFUSED: $SENT exists; this proof runs once, no retry" >&2; exit 76; }
 [ -e "$LOCK" ] || { echo "REFUSED: canonical lock file $LOCK absent; runtime setup created it and it is never deleted or recreated here" >&2; exit 75; }
 exec 9>>"$LOCK"; flock -n 9 || { echo "REFUSED: canonical lock busy ($LOCK)" >&2; exit 75; }
+[ "$(stat -c %i "$LOCK")" = "$EXPECT_LOCK_INODE" ] || { echo "REFUSED: $LOCK inode $(stat -c %i "$LOCK") != $EXPECT_LOCK_INODE (LOCK_ESTABLISHED.txt); not the canonical lock file" >&2; exit 75; }
 ts(){ date -u +%FT%TZ; }
 log(){ echo "$*" | tee -a "$LOG"; }
 sha(){ sha256sum "$1" | cut -c1-64; }
@@ -85,9 +91,12 @@
   finish "$rc"; }
 log "START $(ts) pid=$$ user=$(id -un) lock=$LOCK(held nonblocking fd9, inode $(stat -c %i "$LOCK")) head_expect=$EXPECT_HEAD fixture_expect=$EXPECT_FIXTURE_SHA"
 # ---- preconditions (read-only)
-case "$EXPECT_HEAD$EXPECT_TREE$EXPECT_SPEC_BLOB$EXPECT_BOOTSTRAP_BLOB$EXPECT_DB_BLOB$EXPECT_PGH_BLOB$EXPECT_HARNESS_BLOB$EXPECT_WORKER_BLOB$EXPECT_FIXTURE_SHA$PORT$RUNTIME_ROOT$EXPECT_POSTGRES_SHA$EXPECT_INITDB_SHA$EXPECT_PGCTL_SHA$EXPECT_PSQL_SHA$EXPECT_NODE_SHA$EXPECT_NM_LOCK_SHA$EXPECT_NM_CLIENT_SHA$BASE_HEAD$BASE_TREE" in *__*) log "PRECONDITION_FAIL pins not filled (proposal stage: head, port, runtime root or tool pins)"; fail 70;; esac
+case "$EXPECT_HEAD$EXPECT_TREE$EXPECT_SPEC_BLOB$EXPECT_BOOTSTRAP_BLOB$EXPECT_DB_BLOB$EXPECT_PGH_BLOB$EXPECT_HARNESS_BLOB$EXPECT_WORKER_BLOB$EXPECT_FIXTURE_SHA$PORT$RUNTIME_ROOT$EXPECT_POSTGRES_SHA$EXPECT_INITDB_SHA$EXPECT_PGCTL_SHA$EXPECT_PSQL_REAL_SHA$EXPECT_NODE_SHA$EXPECT_NM_LOCK_SHA$EXPECT_NM_CLIENT_SHA$BASE_HEAD$BASE_TREE" in *__*) log "PRECONDITION_FAIL pins not filled (proposal stage: head, port, runtime root or tool pins)"; fail 70;; esac
 [ "$EXPECT_HEAD" != "$BASE_HEAD" ] || { log "PRECONDITION_FAIL EXPECT_HEAD is the base, not a candidate"; fail 70; }
 [ "$(sha "$FIX")" = "$EXPECT_FIXTURE_SHA" ] || { log "PRECONDITION_FAIL fixture sha256 mismatch"; fail 70; }
+# the fixture must carry exactly this runner's lane constants (whole-line, literal): one runtime root, one port, one marker
+grep -qx "RUNTIME_ROOT=$RUNTIME_ROOT" "$FIX" || { log "PRECONDITION_FAIL fixture RUNTIME_ROOT line != $RUNTIME_ROOT"; fail 70; }
+grep -qx "PORT=$PORT; SUPER=$ADMIN; PASS=$FIXPASS; MARKER=s9-disposable-pg17" "$FIX" || { log "PRECONDITION_FAIL fixture PORT/SUPER/PASS/MARKER line != runner (PORT=$PORT ADMIN=$ADMIN MARKER=s9-disposable-pg17)"; fail 70; }
 [ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] || { log "PRECONDITION_FAIL HEAD != $EXPECT_HEAD"; fail 70; }
 [ "$(git -C "$W" rev-parse 'HEAD^{tree}')" = "$EXPECT_TREE" ] || { log "PRECONDITION_FAIL tree mismatch"; fail 70; }
 [ "$(git -C "$W" rev-parse "$BASE_HEAD^{tree}")" = "$BASE_TREE" ] || { log "PRECONDITION_FAIL base tree mismatch"; fail 70; }
@@ -128,30 +137,32 @@
 [ "$(sha "$W/prisma/schema.prisma")" = "$EXPECT_SCHEMA_SHA" ] || { log "PRECONDITION_FAIL prisma/schema.prisma != 0eb41f9a"; fail 70; }
 [ "$(sha "$W/node_modules/.prisma/client/index.d.ts")" = "$EXPECT_NM_CLIENT_SHA" ] || { log "PRECONDITION_FAIL generated client != runtime receipt record (no S9-B generate expected)"; fail 70; }
 [ -x "$W/node_modules/.bin/jest" ] && [ -x "$W/node_modules/.bin/ts-node" ] && [ -x "$W/node_modules/.bin/prisma" ] || { log "PRECONDITION_FAIL jest/ts-node/prisma missing"; fail 70; }
-# tools: pinned PG 17.6 server binaries in the fresh namespace, the recorded psql 18.6 client and Node 20
+# tools: pinned PG 17.6 server binaries in the 1910a060 namespace, the real psql 18.6 client binary (CB1) and Node 20
 [ -x "$DIST/bin/postgres" ] && [ -x "$DIST/bin/initdb" ] && [ -x "$DIST/bin/pg_ctl" ] || { log "PRECONDITION_FAIL PG17 dist absent at $DIST"; fail 70; }
 [ "$(sha "$DIST/bin/postgres")" = "$EXPECT_POSTGRES_SHA" ] || { log "PRECONDITION_FAIL postgres binary sha256 != pin"; fail 70; }
 [ "$(sha "$DIST/bin/initdb")" = "$EXPECT_INITDB_SHA" ] || { log "PRECONDITION_FAIL initdb binary sha256 != pin"; fail 70; }
 [ "$(sha "$DIST/bin/pg_ctl")" = "$EXPECT_PGCTL_SHA" ] || { log "PRECONDITION_FAIL pg_ctl binary sha256 != pin"; fail 70; }
 PGV=$(LD_LIBRARY_PATH=$DIST/lib "$DIST/bin/postgres" --version 2>/dev/null); [ "${PGV##* }" = 17.6 ] || { log "PRECONDITION_FAIL server not 17.6: $PGV"; fail 70; }
-[ -x /usr/bin/psql ] && [ "$(sha "$(readlink -f /usr/bin/psql)")" = "$EXPECT_PSQL_SHA" ] || { log "PRECONDITION_FAIL /usr/bin/psql absent or sha256 != pin"; fail 70; }
+[ -x "$PSQL" ] && [ "$(sha "$PSQL")" = "$EXPECT_PSQL_REAL_SHA" ] || { log "PRECONDITION_FAIL $PSQL absent or sha256 != pin"; fail 70; }
+"$PSQL" --version | grep -qE "^psql \(PostgreSQL\) 18\." || { log "PRECONDITION_FAIL psql major != 18: $("$PSQL" --version)"; fail 70; }
 NODE=$(command -v node); [ "$(sha "$(readlink -f "$NODE")")" = "$EXPECT_NODE_SHA" ] || { log "PRECONDITION_FAIL node sha256 != pin ($NODE)"; fail 70; }
 node --version | grep -q '^v20\.' || { log "PRECONDITION_FAIL node major != 20"; fail 70; }
 [ "$(readlink -f "$RUNTIME_ROOT")" = "$RUNTIME_ROOT" ] || { log "PRECONDITION_FAIL $RUNTIME_ROOT is not a real path"; fail 70; }
 grep -q '^result=success' "$RUNTIME_ROOT/pg17/PROVENANCE.txt" 2>/dev/null || { log "PRECONDITION_FAIL pg17 PROVENANCE.txt lacks result=success"; fail 70; }
-log "PRECONDITIONS_OK $(ts) server='$PGV' psql='$(/usr/bin/psql --version)' node=$(node --version) jest=$(cd "$W" && ./node_modules/.bin/jest --version) ts_node=$(cd "$W" && ./node_modules/.bin/ts-node --version 2>/dev/null | head -1) prisma=$(cd "$W" && ./node_modules/.bin/prisma --version 2>/dev/null | awk '/^prisma /{print $3}')"
-# ---- step 1 preflight (read-only): S9-B lane absent; lane port free; no postgres; other lanes under the runtime root recorded and never started
+log "PRECONDITIONS_OK $(ts) server='$PGV' psql='$("$PSQL" --version)' node=$(node --version) jest=$(cd "$W" && ./node_modules/.bin/jest --version) ts_node=$(cd "$W" && ./node_modules/.bin/ts-node --version 2>/dev/null | head -1) prisma=$(cd "$W" && ./node_modules/.bin/prisma --version 2>/dev/null | awk '/^prisma /{print $3}')"
+# ---- step 1 preflight (read-only): S9-B lane absent; lane port free; no postgres; other lanes under the runtime root (clusters/* incl. S8-G's
+#      clusters/s8-g, and proof-*/clusters/* incl. S8-F's proof-s8f-v2/clusters/s8-f) fingerprinted and never started
 STAGE=preflight
 [ ! -e "$LANE" ] || { log "PREFLIGHT_FAIL $LANE exists (fresh init only; never adopt)"; fail 71; }
 [ ! -e "$SOCK" ] || [ -z "$(ls -A "$SOCK" 2>/dev/null)" ] || { log "PREFLIGHT_FAIL socket dir $SOCK not empty"; fail 71; }
 L=$(ss -ltn 2>/dev/null | grep -c ":$PORT " || true); [ "$L" = 0 ] || { log "PREFLIGHT_FAIL port $PORT listeners=$L"; fail 71; }
 P=$(pgrep -cx postgres || true); [ "$P" = 0 ] || { log "PREFLIGHT_FAIL postgres procs=$P (another lane live; this proof never shares a server)"; fail 71; }
 OTHER0=""
-for d in "$CLUSTERS"/*/; do [ -d "$d" ] || continue; n=$(basename "$d"); [ "$n" != s9-b ] || continue
+for d in "$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-*/clusters/*/; do [ -d "$d" ] || continue; [ "${d%/}" != "$LANE" ] || continue; n=${d#$RUNTIME_ROOT/}; n=${n%/}
   [ ! -e "$d/pg-data/postmaster.pid" ] || { log "PREFLIGHT_FAIL $n postmaster.pid present"; fail 71; }
   h="$n:$(sha "$d/pg-data/postgresql.conf" 2>/dev/null || echo ABSENT):$(sha "$d/pg-data/global/pg_control" 2>/dev/null || echo ABSENT)"; OTHER0="$OTHER0 $h"
   log "PREFLIGHT other_lane=$h (must be unchanged at end; never started)"; done
-[ -e "$CLUSTERS" ] || log "PREFLIGHT clusters_dir=ABSENT (first lane under the runtime root)"
+[ -e "$CLUSTERS" ] || log "PREFLIGHT clusters_dir=ABSENT (no clusters/* lane yet under the runtime root; proof-*/clusters/* scanned above)"
 PORC0=$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)
 log "PREFLIGHT_OK $(ts) lane=absent port$PORT=free postgres_procs=0 worktree_porcelain_sha=$PORC0 lock_inode=$(stat -c %i "$LOCK")"
 # ---- step 2 init (bound 60 s)
@@ -169,7 +180,7 @@
 grep -q "^CANDIDATE_HEAD=$EXPECT_HEAD" "$LOG" || { log "BOOTSTRAP candidate binding line missing"; fail 72; }
 # ---- step 5 identity (read-only, bound 15 s each; admin login with PGPASSWORD only, never a URL password)
 STAGE=identity
-psqlq(){ PGPASSWORD=$FIXPASS timeout -k 30 15 /usr/bin/psql -X -v ON_ERROR_STOP=1 -At "postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME" -c "$1" 2>>"$LOG"; }
+psqlq(){ PGPASSWORD=$FIXPASS timeout -k 30 15 "$PSQL" -X -v ON_ERROR_STOP=1 -At "postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME" -c "$1" 2>>"$LOG"; }
 DD=$(psqlq 'SHOW data_directory'); [ "$DD" = "$G2_S9_DATA_DIRECTORY" ] || { log "IDENTITY_FAIL data_directory='$DD'"; fail 73; }
 VN=$(psqlq 'SHOW server_version_num'); [ "$VN" = 170006 ] || { log "IDENTITY_FAIL server_version_num='$VN'"; fail 73; }
 CN=$(psqlq "SELECT current_setting('cluster_name')"); [ "$CN" = s9-disposable-pg17 ] || { log "IDENTITY_FAIL cluster_name='$CN'"; fail 73; }
@@ -183,6 +194,8 @@
 log "JEST_END rc=$JRC $(ts)"; grep -E '^(Test Suites|Tests|Snapshots|Time):' "$JLOG" | tee -a "$LOG"
 grep -E 'requires an explicitly acknowledged|not the permitted disposable database|server identity mismatch|G2 proof requires|not the attested candidate|uncommitted changes' "$JLOG" >/dev/null && log "GUARD_REFUSAL_OBSERVED_IN_JEST_LOG"
 [ $JRC = 0 ] || fail $JRC
+grep -qE "^Tests: +$EXPECT_TESTS passed, $EXPECT_TESTS total" "$JLOG" || { log "JEST_COUNT_FAIL expected 'Tests: $EXPECT_TESTS passed, $EXPECT_TESTS total' (got: $(grep -E '^Tests:' "$JLOG" | head -1))"; fail 72; }
+log "JEST_COUNT_OK tests=$EXPECT_TESTS"
 # ---- step 7 stop (bound 45 s + kill 30); data dir RETAINED (destroy only via separate grant: s9b-fixture.sh destroy)
 STAGE=fixture-stop; STARTED=0; timeout -k 30 75 bash "$FIX" stop >>"$LOG" 2>&1; rc=$?; log "FIXTURE_STOP rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
 P=$(pgrep -cx postgres || true); L=$(ss -ltn 2>/dev/null | grep -c ":$PORT " || true)
@@ -191,7 +204,7 @@
 # ---- step 8 post (read-only)
 STAGE=post
 OTHER1=""
-for d in "$CLUSTERS"/*/; do [ -d "$d" ] || continue; n=$(basename "$d"); [ "$n" != s9-b ] || continue
+for d in "$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-*/clusters/*/; do [ -d "$d" ] || continue; [ "${d%/}" != "$LANE" ] || continue; n=${d#$RUNTIME_ROOT/}; n=${n%/}
   [ ! -e "$d/pg-data/postmaster.pid" ] || { log "POST_FAIL $n postmaster.pid appeared"; fail 74; }
   OTHER1="$OTHER1 $n:$(sha "$d/pg-data/postgresql.conf" 2>/dev/null || echo ABSENT):$(sha "$d/pg-data/global/pg_control" 2>/dev/null || echo ABSENT)"; done
 [ "$OTHER0" = "$OTHER1" ] || { log "POST_FAIL other lanes changed: before=[$OTHER0] after=[$OTHER1]"; fail 74; }
```

### s9b-fixture.sh

```diff
--- a/binding/v2/s9b-fixture.sh
+++ b/binding/v2/s9b-fixture.sh
@@ -2,16 +2,18 @@
 # S9-B disposable PostgreSQL 17.6 cluster helper (lane s9-b only, EXEC-1910A060), derived by substitution from the
 # accepted S8-C fixture execution/64e33dc7/s8c/binding/s8c-fixture.sh (unchanged there). LOCK-FREE BY DESIGN: it
 # takes no flock itself and must be invoked only by the S9-B proof binding
-# execution/1910a060/s9b/binding/v1/s9b-pg-proof.sh, the single canonical lock holder. Standalone use is refused
+# execution/1910a060/s9b/binding/v2/s9b-pg-proof.sh, the single canonical lock holder. Standalone use is refused
 # unless S9B_RUNNER_PID names a live s9b-pg-proof.sh process.
 #   * cluster_name = 's9-disposable-pg17' (pinned marker required by start, bootstrap and destroy; identical to
 #     test/utils/g2-s9-db.ts G2_S9_CLUSTER_MARKER)
 #   * FRESH INIT ONLY: init refuses if the data directory exists (no marking/adopting unknown clusters)
-#   * listen 127.0.0.1 only, port 55645 (lane port chosen by the parent, execution/1910a060; 55645 suggested), superuser s9_super / s9_local_synthetic
+#   * listen 127.0.0.1 only, port 55645 (lane port chosen by the parent 14:59 PT, execution/1910a060), superuser s9_super / s9_local_synthetic
 #     (synthetic value; scram, S5 shape)
-#   * FRESH NAMESPACE (RUNTIME_SETUP_RECEIPT §Donor-copy 6-7): binaries from the SHA-pinned
-#     recovery-reset/pg17/dist; data and socket directories under recovery-reset/clusters/s9-b and
-#     recovery-reset/run/s9-b — never pg17/dist as a data root, never the historical /home/user/pg17 paths.
+#   * 1910a060 NAMESPACE (execution/1910a060/runtime/RUNTIME_SETUP_RECEIPT.md): binaries from the SHA-pinned
+#     1910a060/runtime/pg17/dist; data and socket directories under 1910a060/runtime/clusters/s9-b and
+#     1910a060/runtime/run/s9-b — never pg17/dist as a data root, never the historical /home/user/pg17 or
+#     64e33dc7/recovery-reset paths. The RUNTIME_ROOT / PORT / MARKER lines below are literals the runner
+#     cross-checks whole-line (grep -qx) against its own before init.
 # `destroy` never discards a stop failure (S5-R3-A-03 revision 2 inherited): a running marked cluster is stopped
 # with a bounded fast stop; a failed stop, a surviving postmaster or any process still referencing the data
 # directory REFUSES removal (rc 4); a failed or incomplete removal is propagated (rc 5) and DESTROY_OK is printed
@@ -19,7 +21,7 @@
 # Usage (via runner): s9b-fixture.sh init|start|stop|status|destroy
 set -euo pipefail
 # ---- lane constants
-RUNTIME_ROOT=/home/user/workspace/execution/64e33dc7/recovery-reset
+RUNTIME_ROOT=/home/user/workspace/execution/1910a060/runtime
 # ---- end lane constants
 PGHOME=$RUNTIME_ROOT/pg17/dist
 PORT=55645; SUPER=s9_super; PASS=s9_local_synthetic; MARKER=s9-disposable-pg17
```

### PINS.txt

```diff
--- a/binding/v2/PINS.txt
+++ b/binding/v2/PINS.txt
@@ -1,7 +1,8 @@
-# S9-B PG proof binding pins — DRAFT v1 (execution/1910a060/s9b/binding/v1). NOTHING HERE HAS BEEN EXECUTED.
+# S9-B PG proof binding pins — DRAFT v2 (execution/1910a060/s9b/binding/v2; CLOSURES-2 revision). NOTHING HERE HAS BEEN EXECUTED.
 # Every value marked __FILL_*__ is unfilled; s9b-pg-proof.sh refuses to run while any pin is unfilled.
-# Fill ORDER (same doctrine as 64e33dc7/s8c/binding/PINS.txt): runtime setup for 1c5fbb04 (its receipt fills
-# RUNTIME_ROOT + tool pins) -> parent chooses the lane port -> S9-A composition + S9-B gates -> hooked Bradley commit
+# Fill ORDER (same doctrine as 64e33dc7/s8c/binding/PINS.txt): runtime setup DONE (execution/1910a060/runtime/
+# RUNTIME_SETUP_RECEIPT.md: RUNTIME_ROOT, real-psql pin and lock inode are literal below; the remaining tool pins are
+# copied from it at fill after re-verification) -> lane port 55645 chosen (14:59 PT) -> M2 fills BASE_* -> S9-B gates -> hooked Bradley commit
 # -> fill the head pins from that head (authorized preparation, not a PG run) -> record template->filled diff + sha256
 # in BINDING.sha256 -> dual independent review attests final head + FILLED binding -> separate execution grant.
 # Never fill from an uncommitted tree. Never adjust a tool pin to pass: a mismatch is reported.
@@ -14,8 +15,9 @@
 #   EXPECT_PGH_BLOB       = git -C $W rev-parse HEAD:test/utils/g2-s9-pg-harness.ts
 #   EXPECT_HARNESS_BLOB   = git -C $W rev-parse HEAD:test/utils/g2-s9-harness.ts
 #   EXPECT_WORKER_BLOB    = git -C $W rev-parse HEAD:test/utils/g2-s9-worker.cjs
-#   EXPECT_FIXTURE_SHA    = sha256sum binding/v1/s9b-fixture.sh                  (frozen together with the filled runner)
-#   PORT                  = lane port chosen by the parent (55645 suggested; 55642 S8-C and 55643 S8-G are refused by g2-s9-db.ts)
+#   EXPECT_FIXTURE_SHA    = sha256sum binding/v2/s9b-fixture.sh                  (FILLED at CLOSURES-2; the fixture is head-independent and frozen with the runner)
+#   PORT                  = 55645 (parent 14:59 PT; 55642 S8-C, 55643 S8-F and 55644 S8-G are refused by g2-s9-db.ts)
+#   EXPECT_TESTS          = grep -c '^\s*it(' test/rls-g2-s9.spec.ts at the attested head (10 on the reviewed source; re-verify at fill)
 BASE_HEAD=__FILL_M2__   # M2 (S9-A be88909f composed onto 62471b11); accepted-path blobs below verified identical at 1c5fbb04 and 62471b11
 BASE_TREE=__FILL_M2__
 EXPECT_HEAD=__FILL_AFTER_ATTESTATION__
@@ -26,19 +28,22 @@
 EXPECT_PGH_BLOB=__FILL_AFTER_ATTESTATION__
 EXPECT_HARNESS_BLOB=__FILL_AFTER_ATTESTATION__
 EXPECT_WORKER_BLOB=__FILL_AFTER_ATTESTATION__
-EXPECT_FIXTURE_SHA=__FILL_AFTER_ATTESTATION__   # current draft s9b-fixture.sh sha256 = 6fb78034d87ebf429bb041cfe537f8d7db04445ab96ad97954f9f28ad2062b4c (changes when PORT is filled)
+EXPECT_FIXTURE_SHA=1ee369641ca0d5b2706947eeb6abf46770a51f648700f235dc3d72936a56a66b   # binding/v2/s9b-fixture.sh after CLOSURES-2 (v1 draft was 6fb78034…)
 PORT=55645
-RUNTIME_ROOT=__FILL_FROM_RUNTIME_RECEIPT__
+RUNTIME_ROOT=/home/user/workspace/execution/1910a060/runtime   # literal in runner AND fixture; runner grep -qx cross-checks the fixture's RUNTIME_ROOT= and PORT=/SUPER=/PASS=/MARKER= lines
+PSQL=/usr/lib/postgresql/18/bin/psql                            # CB1: real client binary (never the /usr/bin/psql pg_wrapper dispatcher a200e38c…)
+EXPECT_PSQL_REAL_SHA=d1108fdb45b87f2313d7acfbb91a0a65ca97c6c2195f15d8ae9295121029ef67   # RUNTIME_SETUP_RECEIPT.md; re-measured 2026-09-25 15:3x PT: sha256sum == d1108fdb…, `psql (PostgreSQL) 18.6 (Ubuntu 18.6-0ubuntu0.26.04.1)`
+EXPECT_TESTS=10
+EXPECT_LOCK_INODE=667698                                        # execution/1910a060/runtime/LOCK_ESTABLISHED.txt; asserted right after flock -n, refusal 75
 # Tool pins: filled from the 1c5fbb04 runtime setup receipt. Prior 64e33dc7 records (compare only; copy a value ONLY
 # when the new receipt re-verifies the same binary/file):
 #   postgres 23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a  initdb b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a
-#   pg_ctl   af53d826845af4679a0aaba2bda319f5e527f3b94f3794c67fa174049c9b9401  psql   a200e38c89b111d3abdf26927b186fdd423bef3d84f157af0f4b65db6f8e6c94
+#   pg_ctl   af53d826845af4679a0aaba2bda319f5e527f3b94f3794c67fa174049c9b9401  (psql wrapper a200e38c… is NOT a pin any more; the real binary is pinned above)
 #   node     a03953a7b16bff002b94d6fb58ada900b68241cbcaee6efc400b20dadd36dddc  nm-lock 05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44
 #   generated client for schema 0eb41f9a (S7-L lane record, lane-provision.sh S7L_CLIENT): 9042e713ba5678c99959a345b7b18a60dfc186b2c7d890b8d9c3ed5c8f4edcc6
 EXPECT_POSTGRES_SHA=__FILL_FROM_RUNTIME_RECEIPT__
 EXPECT_INITDB_SHA=__FILL_FROM_RUNTIME_RECEIPT__
 EXPECT_PGCTL_SHA=__FILL_FROM_RUNTIME_RECEIPT__
-EXPECT_PSQL_SHA=__FILL_FROM_RUNTIME_RECEIPT__
 EXPECT_NODE_SHA=__FILL_FROM_RUNTIME_RECEIPT__
 EXPECT_NM_LOCK_SHA=__FILL_FROM_RUNTIME_RECEIPT__
 EXPECT_NM_CLIENT_SHA=__FILL_FROM_RUNTIME_RECEIPT__
```

### README.md

```diff
--- a/binding/v2/README.md
+++ b/binding/v2/README.md
@@ -17,7 +17,32 @@
   `reconcile` `bcc85e49`, `reconcile.spec` `11f2a524`; sha256 `211b474a`/`eca66f33`/`d16158ad`/`dc084dce`), replacing
   the pre-format read-only copies (`bb28f151`/`e13c336a`/`3932cd3c`/`df887df5`).
 
-Still unfilled (refused by the runner): `EXPECT_HEAD`, `EXPECT_TREE`, six S9-B blob pins, `EXPECT_FIXTURE_SHA`
-(fill AFTER the gate's hooked commit; blobs are post-format), `RUNTIME_ROOT` and the seven tool pins (from the
-runtime receipt), `BASE_HEAD`/`BASE_TREE` (M2). Fill order, roles, lane dirs, lock (`flock -n` fd 9 on the canonical
-`test-validation.lock`, inode 667698), timeouts and stop semantics are as in `../v1/README.md`.
+Changes at CLOSURES-2 (parent disposition 15:31 PT after dual review of v2 — NO-GO as written, GO-for-one-run-after-fill
+once closed; see `../../CLOSURES-2.md` for exact diffs):
+
+1. `D=…/binding/v2`; every stale `v1` label removed (runner usage line and `EXPECT_FIXTURE_SHA` comment, fixture
+   header, `PINS.txt` header / fixture-sha comment); the `G2_S8B_*` identity comment now lists `G2_S8G_*`, `G2_S8F_*`,
+   `G2_S8C_*`, `G2_S8B_*`, `G2_S7L_*`.
+2. `RUNTIME_ROOT=/home/user/workspace/execution/1910a060/runtime` is a literal in BOTH the fixture and the runner
+   (the fixture previously pointed at the 64e33dc7 `recovery-reset` root). The runner cross-checks the fixture
+   whole-line with `grep -qx`: `RUNTIME_ROOT=<its own>` and `PORT=55645; SUPER=s9_super; PASS=s9_local_synthetic;
+   MARKER=s9-disposable-pg17`; any mismatch is refusal 70 before init.
+3. psql: `PSQL=/usr/lib/postgresql/18/bin/psql` (the real client binary, not the `/usr/bin/psql` pg_wrapper),
+   `EXPECT_PSQL_REAL_SHA=d1108fdb…` (RUNTIME_SETUP_RECEIPT.md; re-measured on this host), `--version` asserted
+   `^psql \(PostgreSQL\) 18\.`, used for `G2_S9_PSQL`, `psqlq` and the PRECONDITIONS_OK line — mirror of
+   `execution/64e33dc7/s8f/binding/v2/s8f-pg-proof.sh` CB1. `EXPECT_PSQL_REAL_SHA` is in the fill-refusal case list.
+4. `EXPECT_TESTS=10` (`grep -c '^\s*it('` on `test/rls-g2-s9.spec.ts`); after jest rc 0 the runner requires
+   `^Tests: +10 passed, 10 total` in `jest.log`, else `JEST_COUNT_FAIL` → 72.
+5. `EXPECT_LOCK_INODE=667698`: asserted with `stat -c %i` immediately after `flock -n` succeeds; mismatch → 75.
+6. Other-lane fingerprint scan (preflight and post) now iterates `$CLUSTERS/*/` (S8-G's `clusters/s8-g`) AND
+   `$RUNTIME_ROOT/proof-*/clusters/*/` (S8-F's `proof-s8f-v2/clusters/s8-f`), keyed by the path relative to the
+   runtime root, skipping only `$LANE`.
+7. `EXPECT_FIXTURE_SHA` is FILLED now (`1ee36964…`, the fixture is head-independent) and `BINDING.sha256` lists the
+   v2 files.
+
+Still unfilled (refused by the runner): `BASE_HEAD`/`BASE_TREE` (M2), `EXPECT_HEAD`, `EXPECT_TREE`, six S9-B blob
+pins (fill AFTER the gate's hooked commit; blobs are post-format), and the six remaining tool pins
+(`EXPECT_POSTGRES_SHA`, `EXPECT_INITDB_SHA`, `EXPECT_PGCTL_SHA`, `EXPECT_NODE_SHA`, `EXPECT_NM_LOCK_SHA`,
+`EXPECT_NM_CLIENT_SHA` — copy from `RUNTIME_SETUP_RECEIPT.md` at fill only after re-verifying each value). Fill order,
+roles, lane dirs, lock (`flock -n` fd 9 on the canonical `test-validation.lock`, inode 667698), timeouts and stop
+semantics are as in `../v1/README.md`. The runner has NOT been executed (it takes the lock before its first check).
```

### PINS.env

```diff
--- a/gate/PINS.env
+++ b/gate/PINS.env
@@ -7,12 +7,12 @@
 SHA_FACTS_SERVICE=e2f40a794b6cf9aa75e37e7d30ca66dd209280e70a5aa963c58eda085de58357
 SHA_MODULE=f2c1e4476f21830fcc51921ac2b612235b650f1cf74e39bb38a62d80decd84e1
 SHA_FACTS_SPEC=9dcfbd966757cc125262e8bdc353b97dc1baf2b5a6ff211a84bc90b382014f3c
-SHA_G2_DB=a1611c51c367fc796e5983d7b0aa7f60de68565febd65ead8346acff0545aaf7
+SHA_G2_DB=39ba033bea0402483287da1a59e805b778a652286c359e807c363f5d87ba2ae9
 SHA_G2_PGH=8274a85b011f00e60fc9247b550373f9391d27b40c375f55e98f7accb70e2def
 SHA_G2_HARNESS=16a5aeac75f189de09bba7b55b8a829ff96120e42b7e4a619d99b60d17e387ff
 SHA_G2_WORKER=5e52b9188cc6a46232723dba7ee0db1cfb9241934644bc3992f656b8bfe622db
 SHA_G2_BOOTSTRAP=8452feba381d790f703c956403a0798d56f498def3663df0b6c32155d63ea682
-SHA_G2_GUARD_SPEC=307d8fa4a60ae3bc09e5a9084273b5c1f79d23147098e3e472c778a2b5452879
+SHA_G2_GUARD_SPEC=a99cf9c9e9cef10290d63b52fd773dcecfa22669933532fe78a61dd1e66e4fbf
 SHA_RLS_SPEC=b854fd59ab1cb174ce55afff3da62974e8373e9d2f672140b34a9a793d485fb6
 # S9-0 decision doc: landed bytes (1c5fbb04 == 62471b11 == M2 expected) and the bytes with Addendum A appended (+DOC_ADDED_LINES/-0)
 DOC_ADDED_LINES=99
```
