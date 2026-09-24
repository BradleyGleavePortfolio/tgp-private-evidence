#!/usr/bin/env bash
# S7-3' G2 C/contract real-PG proof — minimal execution binding (PHASE 1 DRAFT; NOT RUN; NOT GRANTED; pins __FILL_AFTER_COMMIT__ until the C head is committed).
# Derived by substitution from the N/Q1 binding execution/cf8ff737/nq1/binding/nq1-pg-proof.sh (filled sha256 e47c9ac1…):
# C identity (port 55491, c_super, g2_c_disposable, cluster c-contract), the C spec/bootstrap/old-root helper, the C
# generated-client pin, and added read-only checks: the accepted N/Q1 files are byte-identical at the C head, the accepted
# N/Q1 head is an ancestor (it is the OLD side of this proof: N writer + Q1 readers), the candidate's prisma/migrations differ
# from it by exactly C's migration.sql + down.sql (no verify.sql), and the retained stopped R and N/Q1 clusters are hashed and
# never started. The old root is a detached checkout of the N/Q1 head (test/utils/g2-c-old-root.sh), whose own
# `prisma migrate deploy` installs the whole accepted history (169); the candidate's `prisma migrate deploy` applies exactly C
# inside the spec (C01). Runs the NEW spec test/rls-g2-c-contract.spec.ts exactly once via the existing repo jest +
# jest.rls.config.js. No new test framework, no retry, no inherited-proof replay (etq0 / fresh51 / C1 / B / R / N/Q1 suites are
# never invoked). Single canonical lock holder; first nonzero stops; the only cleanup attempted is a bounded fixture stop when
# this run started the postmaster. No autonomous cleanup is GUARANTEED: if the outer timeout kills bash, the stop does not run.
# What governs is the observed terminal evidence — the sentinel/log lines, `pgrep -cx postgres`, the port listener count and any
# survivor pid the stop reports — not this header. Data dir RETAINED after stop (destroy = separate marker-gated grant).
# Inner stage bounds: init 60 + start 60 + old-root 180 + bootstrap 900 + identity 4x15 + jest 1500 + stop 75 = 2835 s soft sum.
# Usage (later, under the single-run grant): timeout -k 30 3600 bash .../binding/c-pg-proof.sh
# Pre-steps (each its own receipt, in this order, BEFORE pins are filled): isolated copy of the accepted N/Q1 node_modules +
# verify (receipt 02) → C-only prisma generate (receipt 03; schema without the narrow @@unique) → light gates (tsc, eslint,
# prettier --check, check-r75) → heavy gates under the relayed slot (affected + full default jest incl.
# test/scout/g2-c-db-guard.spec.ts) → chain-harness CI dry-run on PG 15.18 (deploy → down → re-apply → byte diff) → ordinary
# Bradley-authored hooked commit → fill EXPECT_* from the committed head → separate PG grant for this script.
set -uo pipefail
D=/home/user/workspace/execution/cf8ff737/c/binding
RT=/home/user/workspace/execution/cf8ff737/c/runtime                      # C proof: its own receipt/old-root root
W=/home/user/workspace/worktrees/s7-c
R=$RT/run; LOG=$R/c-pg-proof.log; SENT=$R/c-pg-proof.sentinel; JLOG=$R/jest.log
LOCK=/home/user/workspace/execution/test-validation.lock
# ---- pins: filled by the binding phase AFTER the C head is committed; the script refuses placeholders.
NQ1_HEAD=__NQ1_ACCEPTED_HEAD__                                            # accepted N/Q1 head = the OLD side (committed candidate 61b93cff…; fill on acceptance)
EXPECT_HEAD=__FILL_AFTER_COMMIT__
EXPECT_TREE=__FILL_AFTER_COMMIT__
EXPECT_SPEC_BLOB=__FILL_AFTER_COMMIT__                 # test/rls-g2-c-contract.spec.ts at the C head
EXPECT_BOOTSTRAP_BLOB=__FILL_AFTER_COMMIT__       # test/utils/g2-c-bootstrap.sh at the C head
EXPECT_FIXTURE_SHA=__FILL_AFTER_COMMIT__           # binding/c-fixture.sh
EXPECT_POSTGRES_SHA=23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a   # S1/S2 PG17_PROVENANCE (unchanged)
EXPECT_INITDB_SHA=b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a
EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44      # node_modules/.package-lock.json (C1 record, unchanged through B, R, N/Q1 and C; receipt 02)
EXPECT_NM_CLIENT_SHA=__FILL_AFTER_GENERATE__    # C node_modules/.prisma/client/index.d.ts (receipt 03; C-only generate, narrow @@unique removed)
PG17_HOME=/home/user/pg17; DIST=$PG17_HOME/dist
S5DIR=$PG17_HOME/clusters/s5; C1DIR=$PG17_HOME/clusters/c1-builder; BDIR=$PG17_HOME/clusters/b-drain; RDIR=$PG17_HOME/clusters/r-ready; NDIR=$PG17_HOME/clusters/nq1; CDIR=$PG17_HOME/clusters/c-contract
PORT=55491; DBNAME=g2_c_disposable; ADMIN=c_super; FIXPASS=c_local_synthetic
FIX=$D/c-fixture.sh
export GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1 NODE_OPTIONS=--max-old-space-size=4096 CHECKPOINT_DISABLE=1 \
       PRISMA_HIDE_UPDATE_MESSAGE=1 npm_config_offline=true npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false
# C-only identity: exactly the G2_C_* names the derived guard/harness/bootstrap/old-root helper read. Nothing
# G2_PG17_*, G2_B_*, G2_R_* or G2_NQ1_* is exported.
export G2_C_DATABASE_URL="postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=4" \
       G2_C_CONFIRM="$DBNAME:$PORT" G2_C_PASSWORD=$FIXPASS G2_C_PSQL=/usr/bin/psql \
       G2_C_DATA_DIRECTORY=$CDIR/pg-data G2_C_SERVER_VERSION=170006 \
       G2_C_OLD_ROOT=$RT/old-root G2_C_OLD_CLIENT=$RT/old-root/.g2-c-old-client
export C_RUNNER_PID=$$ C_STOP_TIMEOUT=45
mkdir -p "$R"
[ -e "$SENT" ] && { echo "REFUSED: $SENT exists; this proof runs once, no retry" >&2; exit 76; }
exec 9>"$LOCK"; flock -n 9 || { echo "REFUSED: canonical lock busy ($LOCK)" >&2; exit 75; }
ts(){ date -u +%FT%TZ; }
log(){ echo "$*" | tee -a "$LOG"; }
STAGE=preconditions; STARTED=0
finish(){ local rc=$1
  echo "RC=$rc STAGE=$STAGE END=$(ts) HEAD=$(git -C "$W" rev-parse HEAD 2>/dev/null)" >"$SENT"
  log "END rc=$rc stage=$STAGE $(ts)"; exit "$rc"; }
fail(){ local rc=$1; log "STOP_FIRST_FAILURE stage=$STAGE rc=$rc $(ts)"
  if [ "$STARTED" = 1 ]; then
    local src=0; timeout -k 30 60 bash "$FIX" stop >>"$LOG" 2>&1 || src=$?
    log "CLEANUP_STOP rc=$src postgres_procs=$(pgrep -cx postgres || true) port${PORT}_listeners=$(ss -ltn 2>/dev/null | grep -c ":$PORT " || true)"
  fi
  finish "$rc"; }
log "START $(ts) pid=$$ head_expect=$EXPECT_HEAD fixture_expect=$EXPECT_FIXTURE_SHA node=$(node --version 2>/dev/null)"
# ---- preconditions (read-only)
case "$NQ1_HEAD$EXPECT_HEAD$EXPECT_TREE$EXPECT_SPEC_BLOB$EXPECT_BOOTSTRAP_BLOB$EXPECT_FIXTURE_SHA$EXPECT_NM_CLIENT_SHA" in *__*) log "PRECONDITION_FAIL pins not filled (proposal stage)"; fail 70;; esac
[ "$(sha256sum "$FIX" | cut -c1-64)" = "$EXPECT_FIXTURE_SHA" ] || { log "PRECONDITION_FAIL fixture sha256 mismatch"; fail 70; }
[ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] || { log "PRECONDITION_FAIL HEAD != $EXPECT_HEAD"; fail 70; }
[ "$(git -C "$W" rev-parse 'HEAD^{tree}')" = "$EXPECT_TREE" ] || { log "PRECONDITION_FAIL tree mismatch"; fail 70; }
[ "$(git -C "$W" rev-parse HEAD:test/rls-g2-c-contract.spec.ts)" = "$EXPECT_SPEC_BLOB" ] || { log "PRECONDITION_FAIL spec blob mismatch"; fail 70; }
[ "$(git -C "$W" rev-parse HEAD:test/utils/g2-c-bootstrap.sh)" = "$EXPECT_BOOTSTRAP_BLOB" ] || { log "PRECONDITION_FAIL bootstrap blob mismatch"; fail 70; }
[ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] || { log "PRECONDITION_FAIL worktree not clean"; fail 70; }
[ ! -e "$W/.git/MERGE_HEAD" ] || { log "PRECONDITION_FAIL MERGE_HEAD present"; fail 70; }
# the committed head must have been produced through the tracked lefthook hooks (installed from the isolated tree)
H=$(git -C "$W" rev-parse --git-path hooks); case "$H" in /*) ;; *) H="$W/$H";; esac
grep -q lefthook "$H/pre-commit" 2>/dev/null && grep -q lefthook "$H/commit-msg" 2>/dev/null \
  || { log "PRECONDITION_FAIL $H/pre-commit or commit-msg absent or not lefthook (hookless commit)"; fail 70; }
# accepted S5 donor files must be byte-identical at the committed head (machine check of "S5 files unchanged")
for pin in "test/utils/g2-pg17-db.ts 0e73d76d8f06328872d09c6a76db20715547ebe0" "test/utils/g2-pg17-harness.ts ab9aaab4ba3e2c55671f66d5f2ee7a23674337be" \
           "test/utils/g2-pg17-bootstrap.sh 85a636ba75607604032cef7af1d285cb198ca263" "test/scout/g2-pg17-db-guard.spec.ts 4fed8bcd57218b6f1bb174948f1adc6e0e3252ba" \
           "test/utils/g2-pg17-old-root.sh b9080538b4ba4838db89d03d90e2cc206b3860b7"; do set -- $pin
  [ "$(git -C "$W" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL accepted S5 file $1 changed"; fail 70; }; done
# accepted B files must be byte-identical at the committed head (machine check of "B files unchanged"; B head 0d69c7ba)
for pin in "test/utils/g2-b-drain-db.ts cb60f3f47a18d11dd31b970ee49bcf1ed4ff2db3" "test/utils/g2-b-drain-pg-harness.ts c22a72c4ebed9710cbb66de5581441a1508ad730" \
           "test/utils/g2-b-drain-harness.ts 469cbd2a76a7e56ca65eff5aa4a734c120e5c2a9" "test/utils/g2-b-drain-bootstrap.sh b4503eef525baa531eedb148f47828db3a4ade6f" \
           "test/scout/g2-b-drain-db-guard.spec.ts 4e1ed6ff932be9681fc943e122d0806eb095afb2" "test/rls-g2-b-drain.spec.ts 9b31fd1813d25a1624ab04666e0b1be4743277ab"; do set -- $pin
  [ "$(git -C "$W" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL accepted B file $1 changed"; fail 70; }; done
git -C "$W" merge-base --is-ancestor 0d69c7ba7e7d257311cfcb21fa325ebb1ddc1f1c HEAD || { log "PRECONDITION_FAIL accepted B head 0d69c7ba not an ancestor"; fail 70; }
# accepted R files (and the R migration directory) must be byte-identical at the committed head (R head 7d2895e1 = the T side)
for pin in "test/utils/g2-r-ready-db.ts 6af4892adf6e24bff2d84e79d09cec10750213f9" "test/utils/g2-r-ready-pg-harness.ts 4922b641c4715353f87a4b749cbe137e08903833" \
           "test/utils/g2-r-ready-harness.ts 78cdc57de796e573f467af449bdb2f61e67f1a57" "test/utils/g2-r-ready-bootstrap.sh 67b77f7ab91207cdf6e50bb088517bc9624635bc" \
           "test/scout/g2-r-ready-db-guard.spec.ts d827099e394a3c64f11b5e52e97be48e027fe170" "test/rls-g2-r-ready.spec.ts 0ae7b76489460dac33dff5434503a361a0acd063" \
           "test/utils/g2-tq0-worker.cjs aa35e7e2c38f8d1a990a4eac466824963ae866f4" "prisma/migrations/20270120000000_scout_identity_ready b0af7599843b9961c2b77663fe6e9b7d02efd34e"; do set -- $pin
  [ "$(git -C "$W" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL accepted R file $1 changed"; fail 70; }; done
git -C "$W" merge-base --is-ancestor 7d2895e1fe03ea82353e8ce0b07aacaf66af74c8 HEAD || { log "PRECONDITION_FAIL accepted R head 7d2895e1 not an ancestor"; fail 70; }
# accepted N/Q1 files must be byte-identical at the committed head (machine check of "N/Q1 files unchanged"; blobs at 61b93cff)
for pin in "test/utils/g2-nq1-db.ts dbe10bcb84b01175a54fa0c4eceb8021fc933719" "test/utils/g2-nq1-pg-harness.ts c8f6fea830304a5b117030eb3c4b97934c55d3fe" \
           "test/utils/g2-nq1-harness.ts a629c5915b9a2bbebaa15accf2dff4dbc277dbf1" "test/utils/g2-nq1-bootstrap.sh 96b7668dff7498cee5ed17ab988aae0f38ac512d" \
           "test/utils/g2-nq1-old-root.sh 4569f5febd963379be106d94d8d4612c85bf0c82" "test/scout/g2-nq1-db-guard.spec.ts 9bc14800ddaa81c2148dfd5d8af64b83f45d6eca" \
           "test/rls-g2-nq1.spec.ts 8ad3af3f1f8a43d9006b929fea5e9cb3ae35a7b2"; do set -- $pin
  [ "$(git -C "$W" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL accepted N/Q1 file $1 changed"; fail 70; }; done
git -C "$W" merge-base --is-ancestor "$NQ1_HEAD" HEAD || { log "PRECONDITION_FAIL accepted N/Q1 head $NQ1_HEAD not an ancestor (old-root fixture impossible)"; fail 70; }
# the candidate ships exactly C: its migration tree differs from the N/Q1 head by migration.sql + down.sql of C and nothing else (no verify.sql)
CM=20270121000000_scout_identity_contract
[ "$(git -C "$W" diff --name-only "$NQ1_HEAD" HEAD -- prisma/migrations | sort | tr '\n' ' ')" = "prisma/migrations/$CM/down.sql prisma/migrations/$CM/migration.sql " ] \
  || { log "PRECONDITION_FAIL prisma/migrations differ from the N/Q1 head by other than exactly C's two files"; fail 70; }
# dependency tree: an ISOLATED copy of the accepted N/Q1 tree (not a symlink into s7-nq1, not a fresh npm ci); client is C's
[ -d "$W/node_modules" ] && [ ! -L "$W/node_modules" ] || { log "PRECONDITION_FAIL $W/node_modules absent or a symlink (isolated copy required)"; fail 70; }
case "$(readlink -f "$W/node_modules")" in "$W"/*) ;; *) log "PRECONDITION_FAIL node_modules resolves outside $W"; fail 70;; esac
[ "$(sha256sum "$W/node_modules/.package-lock.json" | cut -c1-64)" = "$EXPECT_NM_LOCK_SHA" ] || { log "PRECONDITION_FAIL node_modules/.package-lock.json != C1/B record"; fail 70; }
[ "$(sha256sum "$W/node_modules/.prisma/client/index.d.ts" | cut -c1-64)" = "$EXPECT_NM_CLIENT_SHA" ] || { log "PRECONDITION_FAIL generated client != C record"; fail 70; }
[ -x "$W/node_modules/.bin/jest" ] && [ -x "$W/node_modules/.bin/ts-node" ] && [ -x "$W/node_modules/.bin/prisma" ] || { log "PRECONDITION_FAIL jest/ts-node/prisma missing"; fail 70; }
[ -x "$DIST/bin/postgres" ] && [ -x "$DIST/bin/initdb" ] && [ -x "$DIST/bin/pg_ctl" ] || { log "PRECONDITION_FAIL PG17 dist absent at $DIST"; fail 70; }
[ "$(sha256sum "$DIST/bin/postgres" | cut -c1-64)" = "$EXPECT_POSTGRES_SHA" ] || { log "PRECONDITION_FAIL postgres binary sha256 != recorded"; fail 70; }
[ "$(sha256sum "$DIST/bin/initdb" | cut -c1-64)" = "$EXPECT_INITDB_SHA" ] || { log "PRECONDITION_FAIL initdb binary sha256 != recorded"; fail 70; }
PGV=$(LD_LIBRARY_PATH=$DIST/lib "$DIST/bin/postgres" --version 2>/dev/null); [ "${PGV##* }" = 17.6 ] || { log "PRECONDITION_FAIL server not 17.6: $PGV"; fail 70; }
[ -x /usr/bin/psql ] || { log "PRECONDITION_FAIL /usr/bin/psql absent"; fail 70; }
[ "$(readlink -f "$PG17_HOME")" = "$PG17_HOME" ] || { log "PRECONDITION_FAIL $PG17_HOME is not a real path"; fail 70; }
log "PRECONDITIONS_OK $(ts) server='$PGV' psql='$(/usr/bin/psql --version)' jest=$(cd "$W" && ./node_modules/.bin/jest --version) pg17_provenance='$(grep -E '^(postgres_sha256|result)=' "$PG17_HOME/PROVENANCE.txt" 2>/dev/null | tr '\n' ' ')'"
# ---- step 1 preflight (read-only): C lane absent; S5 absent recorded as-is; retained C1, B, R and N/Q1 clusters hashed, never started
STAGE=preflight
[ ! -e "$CDIR" ] || { log "PREFLIGHT_FAIL $CDIR exists (fresh init only; never adopt)"; fail 71; }
[ ! -e "$RT/old-root" ] || { log "PREFLIGHT_FAIL $RT/old-root exists (once-only fixture; no reuse)"; fail 71; }
L=$(ss -ltn 2>/dev/null | grep -c ":$PORT " || true); [ "$L" = 0 ] || { log "PREFLIGHT_FAIL port $PORT listeners=$L"; fail 71; }
P=$(pgrep -cx postgres || true); [ "$P" = 0 ] || { log "PREFLIGHT_FAIL postgres procs=$P"; fail 71; }
[ ! -e "$S5DIR" ] || { log "PREFLIGHT_FAIL s5 cluster present (parent requires S5 ABSENT for the C lane)"; fail 71; }
log "PREFLIGHT s5_cluster=ABSENT (recorded as-is, not reconstructed)"
if [ -e "$C1DIR/pg-data" ]; then
  [ ! -e "$C1DIR/pg-data/postmaster.pid" ] || { log "PREFLIGHT_FAIL c1 postmaster.pid present"; fail 71; }
  C1_CONF0=$(sha256sum "$C1DIR/pg-data/postgresql.conf" | cut -c1-64); C1_CTRL0=$(sha256sum "$C1DIR/pg-data/global/pg_control" | cut -c1-64)
  log "PREFLIGHT c1_cluster=PRESENT_STOPPED conf=$C1_CONF0 pg_control=$C1_CTRL0 (must be unchanged at end; never started)"
else C1_CONF0=ABSENT; C1_CTRL0=ABSENT; log "PREFLIGHT c1_cluster=ABSENT"; fi
if [ -e "$BDIR/pg-data" ]; then
  [ ! -e "$BDIR/pg-data/postmaster.pid" ] || { log "PREFLIGHT_FAIL b-drain postmaster.pid present"; fail 71; }
  B_CONF0=$(sha256sum "$BDIR/pg-data/postgresql.conf" | cut -c1-64); B_CTRL0=$(sha256sum "$BDIR/pg-data/global/pg_control" | cut -c1-64)
  log "PREFLIGHT b_cluster=PRESENT_STOPPED conf=$B_CONF0 pg_control=$B_CTRL0 (must be unchanged at end; never started)"
else B_CONF0=ABSENT; B_CTRL0=ABSENT; log "PREFLIGHT b_cluster=ABSENT"; fi
if [ -e "$RDIR/pg-data" ]; then
  [ ! -e "$RDIR/pg-data/postmaster.pid" ] || { log "PREFLIGHT_FAIL r-ready postmaster.pid present"; fail 71; }
  R_CONF0=$(sha256sum "$RDIR/pg-data/postgresql.conf" | cut -c1-64); R_CTRL0=$(sha256sum "$RDIR/pg-data/global/pg_control" | cut -c1-64)
  log "PREFLIGHT r_cluster=PRESENT_STOPPED conf=$R_CONF0 pg_control=$R_CTRL0 (must be unchanged at end; never started)"
else R_CONF0=ABSENT; R_CTRL0=ABSENT; log "PREFLIGHT r_cluster=ABSENT"; fi
if [ -e "$NDIR/pg-data" ]; then
  [ ! -e "$NDIR/pg-data/postmaster.pid" ] || { log "PREFLIGHT_FAIL nq1 postmaster.pid present"; fail 71; }
  N_CONF0=$(sha256sum "$NDIR/pg-data/postgresql.conf" | cut -c1-64); N_CTRL0=$(sha256sum "$NDIR/pg-data/global/pg_control" | cut -c1-64)
  log "PREFLIGHT nq1_cluster=PRESENT_STOPPED conf=$N_CONF0 pg_control=$N_CTRL0 (must be unchanged at end; never started)"
else N_CONF0=ABSENT; N_CTRL0=ABSENT; log "PREFLIGHT nq1_cluster=ABSENT"; fi
PORC0=$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)
log "PREFLIGHT_OK $(ts) cdir=absent port$PORT=free postgres_procs=0 worktree_porcelain_sha=$PORC0"
# ---- step 2 init (bound 60 s)
STAGE=fixture-init; timeout -k 30 60 bash "$FIX" init >>"$LOG" 2>&1; rc=$?; log "FIXTURE_INIT rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^C_FIXTURE_INIT_OK data=$CDIR/pg-data port=$PORT superuser=$ADMIN cluster_name=c-disposable-pg17" "$LOG" || { log "FIXTURE_INIT marker missing"; fail 72; }
# ---- step 3 start (bound 60 s)
STAGE=fixture-start; STARTED=1; timeout -k 30 60 bash "$FIX" start >>"$LOG" 2>&1; rc=$?; log "FIXTURE_START rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^C_FIXTURE_START_OK pid=" "$LOG" || { log "FIXTURE_START marker missing"; fail 72; }
# ---- step 4 OLD (accepted N/Q1 head) detached checkout OUTSIDE the candidate (derived helper committed at the C head; git only; bound 180 s)
STAGE=old-root
( cd "$W" && timeout -k 30 180 bash test/utils/g2-c-old-root.sh create ) >>"$LOG" 2>&1; rc=$?
log "OLD_ROOT rc=$rc $(ts) head=$(git -C "$G2_C_OLD_ROOT" rev-parse HEAD 2>/dev/null)"; [ $rc = 0 ] || fail $rc
grep -q "^G2_C_OLD_ROOT_OK" "$LOG" || { log "OLD_ROOT marker missing"; fail 72; }
[ "$(git -C "$G2_C_OLD_ROOT" rev-parse HEAD)" = "$NQ1_HEAD" ] || { log "OLD_ROOT head is not the accepted N/Q1 head"; fail 72; }
# ---- step 5 C bootstrap (derived helper committed at the C head; roles, marked DB, shim, the whole accepted history (169)
#      through the old root's `prisma migrate deploy` — C NOT applied here (the spec applies it through the candidate's
#      `prisma migrate deploy`, C01) — old client generate inside the old root, the only `prisma generate` of the run; the C
#      candidate client only VERIFIED) (bound 900 s)
STAGE=bootstrap
( cd "$W" && timeout -k 30 900 bash test/utils/g2-c-bootstrap.sh ) >>"$LOG" 2>&1; rc=$?; log "BOOTSTRAP rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^G2_C_BOOTSTRAP_OK" "$LOG" || { log "BOOTSTRAP marker missing"; fail 72; }
# ---- step 6 identity (read-only, bound 15 s each; admin login with PGPASSWORD only, never a URL password)
STAGE=identity
psqlq(){ PGPASSWORD=$FIXPASS timeout -k 30 15 /usr/bin/psql -X -v ON_ERROR_STOP=1 -At "postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME" -c "$1" 2>>"$LOG"; }
DD=$(psqlq 'SHOW data_directory'); [ "$DD" = "$G2_C_DATA_DIRECTORY" ] || { log "IDENTITY_FAIL data_directory='$DD'"; fail 73; }
VN=$(psqlq 'SHOW server_version_num'); [ "$VN" = 170006 ] || { log "IDENTITY_FAIL server_version_num='$VN'"; fail 73; }
CN=$(psqlq "SELECT current_setting('cluster_name')"); [ "$CN" = c-disposable-pg17 ] || { log "IDENTITY_FAIL cluster_name='$CN'"; fail 73; }
DM=$(psqlq "SELECT shobj_description(oid,'pg_database') FROM pg_database WHERE datname=current_database()")
[ "$DM" = c-g2-contract-synthetic-disposable-fixture-safe-to-drop ] || { log "IDENTITY_FAIL db marker='$DM'"; fail 73; }
log "IDENTITY_OK $(ts) data_directory=$DD server_version_num=$VN cluster_name=$CN"
# ---- step 7 the proof, exactly once (bound 1500 s); no --testTimeout/--forceExit/--detectOpenHandles/coverage
STAGE=jest; log "JEST_START $(ts) cmd='./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-c-contract.spec.ts --runInBand --ci'"
( cd "$W" && timeout -k 30 1500 ./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-c-contract.spec.ts --runInBand --ci ) >"$JLOG" 2>&1; JRC=$?
log "JEST_END rc=$JRC $(ts)"; grep -E '^(Test Suites|Tests|Snapshots|Time):' "$JLOG" | tee -a "$LOG"
grep -E 'requires an explicitly acknowledged|not the permitted disposable database|server identity mismatch|G2 proof requires' "$JLOG" >/dev/null && log "GUARD_REFUSAL_OBSERVED_IN_JEST_LOG"
[ $JRC = 0 ] || fail $JRC
# ---- step 8 stop (bound 45 s + kill 30); data dir RETAINED (destroy only via separate grant: c-fixture.sh destroy)
STAGE=fixture-stop; STARTED=0; timeout -k 30 75 bash "$FIX" stop >>"$LOG" 2>&1; rc=$?; log "FIXTURE_STOP rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
P=$(pgrep -cx postgres || true); L=$(ss -ltn 2>/dev/null | grep -c ":$PORT " || true)
[ "$P" = 0 ] && [ "$L" = 0 ] && [ ! -e "$CDIR/pg-data/postmaster.pid" ] && [ -d "$CDIR/pg-data" ] || { log "STOP_STATE_FAIL postgres_procs=$P listeners=$L"; fail 74; }
log "STOP_STATE_OK postgres_procs=0 port$PORT=free datadir_retained=$CDIR/pg-data"
# ---- step 9 post (read-only)
STAGE=post
[ ! -e "$S5DIR" ] || { log "POST_FAIL s5 cluster appeared"; fail 74; }; log "POST s5_cluster=ABSENT unchanged"
if [ "$C1_CONF0" != ABSENT ]; then
  [ "$(sha256sum "$C1DIR/pg-data/postgresql.conf" | cut -c1-64)" = "$C1_CONF0" ] && [ "$(sha256sum "$C1DIR/pg-data/global/pg_control" | cut -c1-64)" = "$C1_CTRL0" ] && [ ! -e "$C1DIR/pg-data/postmaster.pid" ] || { log "POST_FAIL c1 cluster changed"; fail 74; }
  log "POST c1_cluster unchanged conf=$C1_CONF0 pg_control=$C1_CTRL0"
fi
if [ "$B_CONF0" != ABSENT ]; then
  [ "$(sha256sum "$BDIR/pg-data/postgresql.conf" | cut -c1-64)" = "$B_CONF0" ] && [ "$(sha256sum "$BDIR/pg-data/global/pg_control" | cut -c1-64)" = "$B_CTRL0" ] && [ ! -e "$BDIR/pg-data/postmaster.pid" ] || { log "POST_FAIL b-drain cluster changed"; fail 74; }
  log "POST b_cluster unchanged conf=$B_CONF0 pg_control=$B_CTRL0"
fi
if [ "$R_CONF0" != ABSENT ]; then
  [ "$(sha256sum "$RDIR/pg-data/postgresql.conf" | cut -c1-64)" = "$R_CONF0" ] && [ "$(sha256sum "$RDIR/pg-data/global/pg_control" | cut -c1-64)" = "$R_CTRL0" ] && [ ! -e "$RDIR/pg-data/postmaster.pid" ] || { log "POST_FAIL r-ready cluster changed"; fail 74; }
  log "POST r_cluster unchanged conf=$R_CONF0 pg_control=$R_CTRL0"
fi
if [ "$N_CONF0" != ABSENT ]; then
  [ "$(sha256sum "$NDIR/pg-data/postgresql.conf" | cut -c1-64)" = "$N_CONF0" ] && [ "$(sha256sum "$NDIR/pg-data/global/pg_control" | cut -c1-64)" = "$N_CTRL0" ] && [ ! -e "$NDIR/pg-data/postmaster.pid" ] || { log "POST_FAIL nq1 cluster changed"; fail 74; }
  log "POST nq1_cluster unchanged conf=$N_CONF0 pg_control=$N_CTRL0"
fi
[ "$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)" = "$PORC0" ] && [ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] || { log "POST_FAIL worktree changed"; fail 74; }
( cd "$R" && sha256sum c-pg-proof.log jest.log > RECEIPTS.sha256 ); log "POST_OK $(ts) receipts=$R/RECEIPTS.sha256"
STAGE=done; finish 0
