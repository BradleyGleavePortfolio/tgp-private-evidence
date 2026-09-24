#!/usr/bin/env python3
"""Reproducible derivation of the N/Q1 PG proof binding (nq1-pg-proof.sh, nq1-fixture.sh) from the accepted
R binding (execution/cf8ff737/r-ready/binding/{r-pg-proof.sh,r-fixture.sh}) by exact-string substitution.
Every substitution must match exactly once; the script asserts that. Run from /home/user/workspace.
Pins EXPECT_HEAD/TREE/SPEC_BLOB/BOOTSTRAP_BLOB/FIXTURE_SHA are emitted as __FILL_AFTER_COMMIT__ and are
filled by the binding phase after the hooked Bradley commit (see PINS.txt)."""
import sys
RB='execution/cf8ff737/r-ready/binding/'
OUT=sys.argv[1] if len(sys.argv)>1 else 'execution/cf8ff737/nq1/binding/'
s=open(RB+'r-pg-proof.sh').read()
hdr_old=s[:s.index('set -uo pipefail')]
hdr_new='''#!/usr/bin/env bash
# S7-3' N/Q1 real-PG proof — minimal execution binding (SOURCE ONLY; NOT RUN; NOT GRANTED; pins __FILL_AFTER_COMMIT__ until the N/Q1 head is committed).
# Derived by substitution from the accepted R binding execution/cf8ff737/r-ready/binding/r-pg-proof.sh (sha256 787d34b0…):
# N/Q1 identity (port 55481, nq1_super, g2_nq1_disposable, cluster nq1), the N/Q1 spec/bootstrap/T-root helper, the N
# generated-client pin, and added read-only checks: the accepted R files (and the R migration directory) are byte-identical
# at the N/Q1 head, the accepted R head 7d2895e1 is an ancestor (it is the T side of this proof), and the retained stopped
# R cluster is hashed and never started. The T root is a detached checkout of the R head (test/utils/g2-nq1-old-root.sh),
# whose own `prisma migrate deploy` installs the whole accepted history (169); N/Q1 ships no migration. Runs the NEW spec
# test/rls-g2-nq1.spec.ts exactly once via the existing repo jest + jest.rls.config.js. No new test framework, no retry,
# no inherited-proof replay (etq0 / fresh51 / C1 / B / R suites are never invoked). Single canonical lock holder; first
# nonzero stops; the only cleanup attempted is a bounded fixture stop when this run started the postmaster. No autonomous
# cleanup is GUARANTEED: if the outer timeout kills bash, the stop does not run. What governs is the observed terminal
# evidence — the sentinel/log lines, `pgrep -cx postgres`, the port listener count and any survivor pid the stop reports —
# not this header. Data dir RETAINED after stop (destroy = separate marker-gated grant).
# Inner stage bounds: init 60 + start 60 + old-root 180 + bootstrap 900 + identity 4x15 + jest 1500 + stop 75 = 2835 s soft sum.
# Usage (later, under the single-run grant): timeout -k 30 3600 bash .../binding/nq1-pg-proof.sh
# Pre-steps (each its own receipt, in this order, BEFORE pins are filled): isolated copy of the accepted R node_modules +
# verify (receipt 02) → N-only prisma generate (receipt 03) → light gates (tsc, eslint, prettier --check, check-r75) →
# heavy gates under the relayed slot (affected + full default jest incl. test/scout/g2-nq1-db-guard.spec.ts) → ordinary
# Bradley-authored hooked commit → fill EXPECT_* from the committed head → separate PG grant for this script.
'''
s=hdr_new+s[len(hdr_old):]
pairs=[
("D=/home/user/workspace/execution/cf8ff737/r-ready/binding","D=/home/user/workspace/execution/cf8ff737/nq1/binding"),
("RT=/home/user/workspace/execution/cf8ff737/r-ready/runtime                # R proof: its own receipt/old-root root",
 "RT=/home/user/workspace/execution/cf8ff737/nq1/runtime                    # N/Q1 proof: its own receipt/old-root root"),
("W=/home/user/workspace/worktrees/s7-r-ready","W=/home/user/workspace/worktrees/s7-nq1"),
("R=$RT/run; LOG=$R/r-pg-proof.log; SENT=$R/r-pg-proof.sentinel; JLOG=$R/jest.log",
 "R=$RT/run; LOG=$R/nq1-pg-proof.log; SENT=$R/nq1-pg-proof.sentinel; JLOG=$R/jest.log"),
("# ---- pins: filled by the parent-approved binding phase AFTER v3 is committed; the script refuses placeholders.",
 "# ---- pins: filled by the binding phase AFTER the N/Q1 head is committed; the script refuses placeholders."),
("EXPECT_HEAD=7d2895e1fe03ea82353e8ce0b07aacaf66af74c8","EXPECT_HEAD=__FILL_AFTER_COMMIT__"),
("EXPECT_TREE=95cdfadc1ae993db23d0d1310ee8029c7867d147","EXPECT_TREE=__FILL_AFTER_COMMIT__"),
("EXPECT_SPEC_BLOB=0ae7b76489460dac33dff5434503a361a0acd063                 # test/rls-g2-r-ready.spec.ts at the R head",
 "EXPECT_SPEC_BLOB=__FILL_AFTER_COMMIT__                 # test/rls-g2-nq1.spec.ts at the N/Q1 head"),
("EXPECT_BOOTSTRAP_BLOB=67b77f7ab91207cdf6e50bb088517bc9624635bc       # test/utils/g2-r-ready-bootstrap.sh at the R head",
 "EXPECT_BOOTSTRAP_BLOB=__FILL_AFTER_COMMIT__       # test/utils/g2-nq1-bootstrap.sh at the N/Q1 head"),
("EXPECT_FIXTURE_SHA=6e71d7540aaf5703b7133e9081bd0146c831f9daa8178de5345983692c8b35f3           # binding/r-fixture.sh",
 "EXPECT_FIXTURE_SHA=__FILL_AFTER_COMMIT__           # binding/nq1-fixture.sh"),
("EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44      # node_modules/.package-lock.json (C1 record, unchanged through B and R; receipt 02)",
 "EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44      # node_modules/.package-lock.json (C1 record, unchanged through B, R and N/Q1; receipt 02)"),
("EXPECT_NM_CLIENT_SHA=7c3674547228cd1cf335bd0e0697c83451f411e28e1ce64e94a719d0a5382f71    # R node_modules/.prisma/client/index.d.ts (receipt 03; R-only generate)",
 "EXPECT_NM_CLIENT_SHA=92d42c56a7f199d41ea518c1f5b9a8c17f34a17f97486942f2691026a1461cf4    # N node_modules/.prisma/client/index.d.ts (receipt 03; N-only generate)"),
("S5DIR=$PG17_HOME/clusters/s5; C1DIR=$PG17_HOME/clusters/c1-builder; BDIR=$PG17_HOME/clusters/b-drain; RDIR=$PG17_HOME/clusters/r-ready",
 "S5DIR=$PG17_HOME/clusters/s5; C1DIR=$PG17_HOME/clusters/c1-builder; BDIR=$PG17_HOME/clusters/b-drain; RDIR=$PG17_HOME/clusters/r-ready; NDIR=$PG17_HOME/clusters/nq1"),
("PORT=55471; DBNAME=g2_r_ready_disposable; ADMIN=r_super; FIXPASS=r_local_synthetic",
 "PORT=55481; DBNAME=g2_nq1_disposable; ADMIN=nq1_super; FIXPASS=nq1_local_synthetic"),
("FIX=$D/r-fixture.sh","FIX=$D/nq1-fixture.sh"),
("""# R-only identity: exactly the G2_R_* names the derived guard/harness/bootstrap read. Nothing G2_PG17_* is exported
# except G2_PG17_OLD_ROOT for the unchanged, identity-free old-root helper (its only input name).
export G2_R_DATABASE_URL="postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=4" \\
       G2_R_CONFIRM="$DBNAME:$PORT" G2_R_PASSWORD=$FIXPASS G2_R_PSQL=/usr/bin/psql \\
       G2_R_DATA_DIRECTORY=$RDIR/pg-data G2_R_SERVER_VERSION=170006 \\
       G2_R_OLD_ROOT=$RT/old-root G2_R_OLD_CLIENT=$RT/old-root/.g2-r-old-client
export R_RUNNER_PID=$$ R_STOP_TIMEOUT=45""",
"""# N/Q1-only identity: exactly the G2_NQ1_* names the derived guard/harness/bootstrap/T-root helper read. Nothing
# G2_PG17_*, G2_B_* or G2_R_* is exported.
export G2_NQ1_DATABASE_URL="postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=4" \\
       G2_NQ1_CONFIRM="$DBNAME:$PORT" G2_NQ1_PASSWORD=$FIXPASS G2_NQ1_PSQL=/usr/bin/psql \\
       G2_NQ1_DATA_DIRECTORY=$NDIR/pg-data G2_NQ1_SERVER_VERSION=170006 \\
       G2_NQ1_OLD_ROOT=$RT/old-root G2_NQ1_OLD_CLIENT=$RT/old-root/.g2-nq1-old-client
export NQ1_RUNNER_PID=$$ NQ1_STOP_TIMEOUT=45"""),
("[ \"$(git -C \"$W\" rev-parse HEAD:test/rls-g2-r-ready.spec.ts)\" = \"$EXPECT_SPEC_BLOB\" ]",
 "[ \"$(git -C \"$W\" rev-parse HEAD:test/rls-g2-nq1.spec.ts)\" = \"$EXPECT_SPEC_BLOB\" ]"),
("[ \"$(git -C \"$W\" rev-parse HEAD:test/utils/g2-r-ready-bootstrap.sh)\" = \"$EXPECT_BOOTSTRAP_BLOB\" ]",
 "[ \"$(git -C \"$W\" rev-parse HEAD:test/utils/g2-nq1-bootstrap.sh)\" = \"$EXPECT_BOOTSTRAP_BLOB\" ]"),
("""git -C "$W" merge-base --is-ancestor 0d69c7ba7e7d257311cfcb21fa325ebb1ddc1f1c HEAD || { log "PRECONDITION_FAIL accepted B head 0d69c7ba not an ancestor"; fail 70; }""",
"""git -C "$W" merge-base --is-ancestor 0d69c7ba7e7d257311cfcb21fa325ebb1ddc1f1c HEAD || { log "PRECONDITION_FAIL accepted B head 0d69c7ba not an ancestor"; fail 70; }
# accepted R files (and the R migration directory) must be byte-identical at the committed head (R head 7d2895e1 = the T side)
for pin in "test/utils/g2-r-ready-db.ts 6af4892adf6e24bff2d84e79d09cec10750213f9" "test/utils/g2-r-ready-pg-harness.ts 4922b641c4715353f87a4b749cbe137e08903833" \\
           "test/utils/g2-r-ready-harness.ts 78cdc57de796e573f467af449bdb2f61e67f1a57" "test/utils/g2-r-ready-bootstrap.sh 67b77f7ab91207cdf6e50bb088517bc9624635bc" \\
           "test/scout/g2-r-ready-db-guard.spec.ts d827099e394a3c64f11b5e52e97be48e027fe170" "test/rls-g2-r-ready.spec.ts 0ae7b76489460dac33dff5434503a361a0acd063" \\
           "test/utils/g2-tq0-worker.cjs aa35e7e2c38f8d1a990a4eac466824963ae866f4" "prisma/migrations/20270120000000_scout_identity_ready b0af7599843b9961c2b77663fe6e9b7d02efd34e"; do set -- $pin
  [ "$(git -C "$W" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL accepted R file $1 changed"; fail 70; }; done
git -C "$W" merge-base --is-ancestor 7d2895e1fe03ea82353e8ce0b07aacaf66af74c8 HEAD || { log "PRECONDITION_FAIL accepted R head 7d2895e1 not an ancestor (T-root fixture impossible)"; fail 70; }
git -C "$W" diff --quiet 7d2895e1fe03ea82353e8ce0b07aacaf66af74c8 HEAD -- prisma/migrations || { log "PRECONDITION_FAIL prisma/migrations differ from the R head (N/Q1 ships no migration)"; fail 70; }"""),
("# dependency tree: an ISOLATED copy of the accepted B tree (not a symlink into s7-b-drain, not a fresh npm ci); client is R's",
 "# dependency tree: an ISOLATED copy of the accepted R tree (not a symlink into s7-r-ready, not a fresh npm ci); client is N's"),
("""[ "$(sha256sum "$W/node_modules/.prisma/client/index.d.ts" | cut -c1-64)" = "$EXPECT_NM_CLIENT_SHA" ] || { log "PRECONDITION_FAIL generated client != R record"; fail 70; }""",
 """[ "$(sha256sum "$W/node_modules/.prisma/client/index.d.ts" | cut -c1-64)" = "$EXPECT_NM_CLIENT_SHA" ] || { log "PRECONDITION_FAIL generated client != N record"; fail 70; }"""),
("""git -C "$W" merge-base --is-ancestor 925780e0a1906593e5383c618311b6b17364b8dc HEAD || { log "PRECONDITION_FAIL O 925780e0 not an ancestor (old-root fixture impossible)"; fail 70; }
""",""),
("# ---- step 1 preflight (read-only): R lane absent; S5 absent recorded as-is; retained C1 and B clusters hashed, never started",
 "# ---- step 1 preflight (read-only): N/Q1 lane absent; S5 absent recorded as-is; retained C1, B and R clusters hashed, never started"),
("""[ ! -e "$RDIR" ] || { log "PREFLIGHT_FAIL $RDIR exists (fresh init only; never adopt)"; fail 71; }""",
 """[ ! -e "$NDIR" ] || { log "PREFLIGHT_FAIL $NDIR exists (fresh init only; never adopt)"; fail 71; }"""),
("""[ ! -e "$S5DIR" ] || { log "PREFLIGHT_FAIL s5 cluster present (parent requires S5 ABSENT for the R lane)"; fail 71; }""",
 """[ ! -e "$S5DIR" ] || { log "PREFLIGHT_FAIL s5 cluster present (parent requires S5 ABSENT for the N/Q1 lane)"; fail 71; }"""),
("""else B_CONF0=ABSENT; B_CTRL0=ABSENT; log "PREFLIGHT b_cluster=ABSENT"; fi
""","""else B_CONF0=ABSENT; B_CTRL0=ABSENT; log "PREFLIGHT b_cluster=ABSENT"; fi
if [ -e "$RDIR/pg-data" ]; then
  [ ! -e "$RDIR/pg-data/postmaster.pid" ] || { log "PREFLIGHT_FAIL r-ready postmaster.pid present"; fail 71; }
  R_CONF0=$(sha256sum "$RDIR/pg-data/postgresql.conf" | cut -c1-64); R_CTRL0=$(sha256sum "$RDIR/pg-data/global/pg_control" | cut -c1-64)
  log "PREFLIGHT r_cluster=PRESENT_STOPPED conf=$R_CONF0 pg_control=$R_CTRL0 (must be unchanged at end; never started)"
else R_CONF0=ABSENT; R_CTRL0=ABSENT; log "PREFLIGHT r_cluster=ABSENT"; fi
"""),
("""log "PREFLIGHT_OK $(ts) rdir=absent port$PORT=free postgres_procs=0 worktree_porcelain_sha=$PORC0\"""",
 """log "PREFLIGHT_OK $(ts) ndir=absent port$PORT=free postgres_procs=0 worktree_porcelain_sha=$PORC0\""""),
("""grep -q "^R_FIXTURE_INIT_OK data=$RDIR/pg-data port=$PORT superuser=$ADMIN cluster_name=r-disposable-pg17" "$LOG\"""",
 """grep -q "^NQ1_FIXTURE_INIT_OK data=$NDIR/pg-data port=$PORT superuser=$ADMIN cluster_name=nq1-disposable-pg17" "$LOG\""""),
("""grep -q "^R_FIXTURE_START_OK pid=" "$LOG\"""","""grep -q "^NQ1_FIXTURE_START_OK pid=" "$LOG\""""),
("""# ---- step 4 preserved-O detached checkout OUTSIDE the candidate (unchanged accepted helper; git only; bound 180 s)
STAGE=old-root
( cd "$W" && G2_PG17_OLD_ROOT=$G2_R_OLD_ROOT timeout -k 30 180 bash test/utils/g2-pg17-old-root.sh create ) >>"$LOG" 2>&1; rc=$?
log "OLD_ROOT rc=$rc $(ts) head=$(git -C "$G2_R_OLD_ROOT" rev-parse HEAD 2>/dev/null)"; [ $rc = 0 ] || fail $rc
# ---- step 5 R bootstrap (derived helper committed at the R head; roles, marked DB, shim, 164 O migrations, O client generate
#      inside the old root — the only `prisma generate` of the run; the R candidate client only VERIFIED) (bound 900 s)
STAGE=bootstrap
( cd "$W" && timeout -k 30 900 bash test/utils/g2-r-ready-bootstrap.sh ) >>"$LOG" 2>&1; rc=$?; log "BOOTSTRAP rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^G2_R_BOOTSTRAP_OK" "$LOG" || { log "BOOTSTRAP marker missing"; fail 72; }""",
"""# ---- step 4 T (accepted R head 7d2895e1) detached checkout OUTSIDE the candidate (derived helper committed at the N/Q1 head; git only; bound 180 s)
STAGE=old-root
( cd "$W" && timeout -k 30 180 bash test/utils/g2-nq1-old-root.sh create ) >>"$LOG" 2>&1; rc=$?
log "OLD_ROOT rc=$rc $(ts) head=$(git -C "$G2_NQ1_OLD_ROOT" rev-parse HEAD 2>/dev/null)"; [ $rc = 0 ] || fail $rc
grep -q "^G2_NQ1_OLD_ROOT_OK" "$LOG" || { log "OLD_ROOT marker missing"; fail 72; }
[ "$(git -C "$G2_NQ1_OLD_ROOT" rev-parse HEAD)" = 7d2895e1fe03ea82353e8ce0b07aacaf66af74c8 ] || { log "OLD_ROOT head is not the accepted R head"; fail 72; }
# ---- step 5 N/Q1 bootstrap (derived helper committed at the N/Q1 head; roles, marked DB, shim, the whole accepted history (169)
#      through the T root's `prisma migrate deploy`, T client generate inside the T root — the only `prisma generate` of the
#      run; the N candidate client only VERIFIED) (bound 900 s)
STAGE=bootstrap
( cd "$W" && timeout -k 30 900 bash test/utils/g2-nq1-bootstrap.sh ) >>"$LOG" 2>&1; rc=$?; log "BOOTSTRAP rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^G2_NQ1_BOOTSTRAP_OK" "$LOG" || { log "BOOTSTRAP marker missing"; fail 72; }"""),
("""DD=$(psqlq 'SHOW data_directory'); [ "$DD" = "$G2_R_DATA_DIRECTORY" ]""","""DD=$(psqlq 'SHOW data_directory'); [ "$DD" = "$G2_NQ1_DATA_DIRECTORY" ]"""),
("""[ "$CN" = r-disposable-pg17 ]""","""[ "$CN" = nq1-disposable-pg17 ]"""),
("""[ "$DM" = r-g2-ready-synthetic-disposable-fixture-safe-to-drop ]""","""[ "$DM" = nq1-g2-synthetic-disposable-fixture-safe-to-drop ]"""),
("""STAGE=jest; log "JEST_START $(ts) cmd='./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-r-ready.spec.ts --runInBand --ci'"
( cd "$W" && timeout -k 30 1500 ./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-r-ready.spec.ts --runInBand --ci )""",
"""STAGE=jest; log "JEST_START $(ts) cmd='./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-nq1.spec.ts --runInBand --ci'"
( cd "$W" && timeout -k 30 1500 ./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-nq1.spec.ts --runInBand --ci )"""),
("""# ---- step 8 stop (bound 45 s + kill 30); data dir RETAINED (destroy only via separate grant: r-fixture.sh destroy)""",
 """# ---- step 8 stop (bound 45 s + kill 30); data dir RETAINED (destroy only via separate grant: nq1-fixture.sh destroy)"""),
("""[ "$P" = 0 ] && [ "$L" = 0 ] && [ ! -e "$RDIR/pg-data/postmaster.pid" ] && [ -d "$RDIR/pg-data" ]""",
 """[ "$P" = 0 ] && [ "$L" = 0 ] && [ ! -e "$NDIR/pg-data/postmaster.pid" ] && [ -d "$NDIR/pg-data" ]"""),
("""log "STOP_STATE_OK postgres_procs=0 port$PORT=free datadir_retained=$RDIR/pg-data\"""",
 """log "STOP_STATE_OK postgres_procs=0 port$PORT=free datadir_retained=$NDIR/pg-data\""""),
("""  log "POST b_cluster unchanged conf=$B_CONF0 pg_control=$B_CTRL0"
fi
""","""  log "POST b_cluster unchanged conf=$B_CONF0 pg_control=$B_CTRL0"
fi
if [ "$R_CONF0" != ABSENT ]; then
  [ "$(sha256sum "$RDIR/pg-data/postgresql.conf" | cut -c1-64)" = "$R_CONF0" ] && [ "$(sha256sum "$RDIR/pg-data/global/pg_control" | cut -c1-64)" = "$R_CTRL0" ] && [ ! -e "$RDIR/pg-data/postmaster.pid" ] || { log "POST_FAIL r-ready cluster changed"; fail 74; }
  log "POST r_cluster unchanged conf=$R_CONF0 pg_control=$R_CTRL0"
fi
"""),
("""( cd "$R" && sha256sum r-pg-proof.log jest.log > RECEIPTS.sha256 )""","""( cd "$R" && sha256sum nq1-pg-proof.log jest.log > RECEIPTS.sha256 )"""),
]
for a,b in pairs:
    assert s.count(a)==1, (s.count(a), a[:90])
    s=s.replace(a,b)
open(OUT+'nq1-pg-proof.sh','w').write(s)
f=open(RB+'r-fixture.sh').read()
fp=[
("""# R/ready disposable PostgreSQL 17.6 cluster helper (lane r-ready only), derived by substitution from the accepted B v5
# fixture execution/95633079/s7-b-drain/fixture-proposal-v3/binding/b-fixture.sh (sha256 4525f01d…). LOCK-FREE BY DESIGN: it takes no flock itself and must be
# invoked only by the frozen R proof binding execution/cf8ff737/r-ready/binding/r-pg-proof.sh,
# the single canonical lock holder. Standalone use is refused unless R_RUNNER_PID names a live r-pg-proof.sh process.
#   * cluster_name = 'r-disposable-pg17' (pinned marker required by start, bootstrap and destroy)
#   * FRESH INIT ONLY: init refuses if the data directory exists (no marking/adopting unknown clusters)
#   * listen 127.0.0.1 only, port 55471, superuser r_super / r_local_synthetic (synthetic value; scram, S5 shape)
#   * data directory $PG17_HOME/clusters/r-ready/pg-data; binaries from S2's SHA-pinned $PG17_HOME/dist""",
"""# N/Q1 disposable PostgreSQL 17.6 cluster helper (lane nq1 only), derived by substitution from the accepted R
# fixture execution/cf8ff737/r-ready/binding/r-fixture.sh (sha256 6e71d754…). LOCK-FREE BY DESIGN: it takes no flock itself and must be
# invoked only by the frozen N/Q1 proof binding execution/cf8ff737/nq1/binding/nq1-pg-proof.sh,
# the single canonical lock holder. Standalone use is refused unless NQ1_RUNNER_PID names a live nq1-pg-proof.sh process.
#   * cluster_name = 'nq1-disposable-pg17' (pinned marker required by start, bootstrap and destroy)
#   * FRESH INIT ONLY: init refuses if the data directory exists (no marking/adopting unknown clusters)
#   * listen 127.0.0.1 only, port 55481, superuser nq1_super / nq1_local_synthetic (synthetic value; scram, S5 shape)
#   * data directory $PG17_HOME/clusters/nq1/pg-data; binaries from S2's SHA-pinned $PG17_HOME/dist"""),
("""# `stop` is bounded by R_STOP_TIMEOUT (runner-supplied; default 45 s) and reports a survivor.
# Usage (via runner): r-fixture.sh init|start|stop|status|destroy""",
"""# `stop` is bounded by NQ1_STOP_TIMEOUT (runner-supplied; default 45 s) and reports a survivor.
# Usage (via runner): nq1-fixture.sh init|start|stop|status|destroy"""),
("""PORT=55471; SUPER=r_super; PASS=r_local_synthetic; MARKER=r-disposable-pg17
DATA=$PG17_HOME/clusters/r-ready/pg-data; LOG=$PG17_HOME/clusters/r-ready/pg.log; SOCK=$PG17_HOME/run/r-ready
STOP_TIMEOUT="${R_STOP_TIMEOUT:-45}\"""",
"""PORT=55481; SUPER=nq1_super; PASS=nq1_local_synthetic; MARKER=nq1-disposable-pg17
DATA=$PG17_HOME/clusters/nq1/pg-data; LOG=$PG17_HOME/clusters/nq1/pg.log; SOCK=$PG17_HOME/run/nq1
STOP_TIMEOUT="${NQ1_STOP_TIMEOUT:-45}\""""),
("""[ -n "${R_RUNNER_PID:-}" ] && [ -d "/proc/$R_RUNNER_PID" ] && grep -q r-pg-proof.sh "/proc/$R_RUNNER_PID/cmdline" \\
  || { echo "r-fixture.sh must be invoked by r-pg-proof.sh (single lock holder); refusing standalone $cmd" >&2; exit 2; }""",
"""[ -n "${NQ1_RUNNER_PID:-}" ] && [ -d "/proc/$NQ1_RUNNER_PID" ] && grep -q nq1-pg-proof.sh "/proc/$NQ1_RUNNER_PID/cmdline" \\
  || { echo "nq1-fixture.sh must be invoked by nq1-pg-proof.sh (single lock holder); refusing standalone $cmd" >&2; exit 2; }"""),
("""[ "$pid" = "${R_RUNNER_PID:-x}" ] && continue""","""[ "$pid" = "${NQ1_RUNNER_PID:-x}" ] && continue"""),
("""# --- R/ready disposable fixture (2 vCPU / 8 GB sandbox) ---""","""# --- N/Q1 disposable fixture (2 vCPU / 8 GB sandbox) ---"""),
("""    echo "R_FIXTURE_INIT_OK data=""","""    echo "NQ1_FIXTURE_INIT_OK data="""),
("""{ echo "REFUSED: $DATA lacks the R marker; not starting a foreign cluster" >&2; exit 3; }""","""{ echo "REFUSED: $DATA lacks the N/Q1 marker; not starting a foreign cluster" >&2; exit 3; }"""),
("""    echo "R_FIXTURE_START_OK pid=""","""    echo "NQ1_FIXTURE_START_OK pid="""),
("""echo "R_FIXTURE_STOP_FAILED pg_ctl_rc=$rc survivor_pid=""","""echo "NQ1_FIXTURE_STOP_FAILED pg_ctl_rc=$rc survivor_pid="""),
("""{ echo "R_FIXTURE_STOP_FAILED pg_ctl_rc=$rc (no postmaster.pid survivor observed)" >&2; exit "$rc"; }""","""{ echo "NQ1_FIXTURE_STOP_FAILED pg_ctl_rc=$rc (no postmaster.pid survivor observed)" >&2; exit "$rc"; }"""),
("""    echo "R_FIXTURE_STOP_OK" ;;""","""    echo "NQ1_FIXTURE_STOP_OK" ;;"""),
("""{ echo "REFUSED: $DATA is not the marked R cluster; not destroying" >&2; exit 3; }""","""{ echo "REFUSED: $DATA is not the marked N/Q1 cluster; not destroying" >&2; exit 3; }"""),
("""      echo "R_FIXTURE_DESTROY_STOPPED_FIRST\"""","""      echo "NQ1_FIXTURE_DESTROY_STOPPED_FIRST\""""),
("""      echo "R_FIXTURE_DESTROY_ALREADY_STOPPED\"""","""      echo "NQ1_FIXTURE_DESTROY_ALREADY_STOPPED\""""),
("""    echo "R_FIXTURE_DESTROY_OK $DATA" ;;""","""    echo "NQ1_FIXTURE_DESTROY_OK $DATA" ;;"""),
]
for a,b in fp:
    assert f.count(a)==1, (f.count(a), a[:90])
    f=f.replace(a,b)
open(OUT+'nq1-fixture.sh','w').write(f)
print("derived", OUT+'nq1-pg-proof.sh', OUT+'nq1-fixture.sh')
