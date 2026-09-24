#!/usr/bin/env python3
"""Reproducible derivation of the C/contract PG proof binding (c-pg-proof.sh, c-fixture.sh) from the N/Q1
binding (execution/cf8ff737/nq1/binding/{nq1-pg-proof.sh,nq1-fixture.sh}, filled form e47c9ac1… / 29db46ad…)
by exact-string substitution. Every substitution must match exactly once (or the asserted count); the script
asserts that. Run from /home/user/workspace. Pins EXPECT_HEAD/TREE/SPEC_BLOB/BOOTSTRAP_BLOB/FIXTURE_SHA are
emitted as __FILL_AFTER_COMMIT__, the N/Q1 acceptance head as __NQ1_ACCEPTED_HEAD__ and the C generated-client
sha as __FILL_AFTER_GENERATE__; all are filled by the binding phase after the hooked Bradley commit (PINS.txt).
PHASE 1 DRAFT: nothing here has been executed against PostgreSQL; the runner is executed only under a
SEPARATE single-run PG grant."""
import sys

NB = 'execution/cf8ff737/nq1/binding/'
OUT = sys.argv[1] if len(sys.argv) > 1 else 'execution/cf8ff737/c/binding/'


def sub(s, old, new, count=1):
    n = s.count(old)
    assert n == count, f'expected {count} match(es), got {n} for: {old[:90]!r}'
    return s.replace(old, new)


# ---------------------------------------------------------------- fixture
f = open(NB + 'nq1-fixture.sh').read()
f = sub(f, 'execution/cf8ff737/nq1/binding/nq1-pg-proof.sh', 'execution/cf8ff737/c/binding/c-pg-proof.sh')
f = sub(f, 'N/Q1 proof binding', 'C proof binding')
f = sub(f, "cluster_name = 'nq1-disposable-pg17'", "cluster_name = 'c-disposable-pg17'")
f = sub(f, "port 55481, superuser nq1_super / nq1_local_synthetic", "port 55491, superuser c_super / c_local_synthetic")
f = sub(f, "data directory $PG17_HOME/clusters/nq1/pg-data", "data directory $PG17_HOME/clusters/c-contract/pg-data")
f = sub(f, "PORT=55481; SUPER=nq1_super; PASS=nq1_local_synthetic; MARKER=nq1-disposable-pg17",
        "PORT=55491; SUPER=c_super; PASS=c_local_synthetic; MARKER=c-disposable-pg17")
f = sub(f, "DATA=$PG17_HOME/clusters/nq1/pg-data; LOG=$PG17_HOME/clusters/nq1/pg.log; SOCK=$PG17_HOME/run/nq1",
        "DATA=$PG17_HOME/clusters/c-contract/pg-data; LOG=$PG17_HOME/clusters/c-contract/pg.log; SOCK=$PG17_HOME/run/c-contract")
f = sub(f, "# --- N/Q1 disposable fixture (2 vCPU / 8 GB sandbox) ---", "# --- C/contract disposable fixture (2 vCPU / 8 GB sandbox) ---")
f = sub(f, "lacks the N/Q1 marker", "lacks the C marker")
f = sub(f, "is not the marked N/Q1 cluster", "is not the marked C cluster")
f = sub(f, 'NQ1_STOP_TIMEOUT', 'C_STOP_TIMEOUT', 2)
f = sub(f, 'NQ1_RUNNER_PID', 'C_RUNNER_PID', 5)
f = sub(f, 'nq1-pg-proof.sh', 'c-pg-proof.sh', 3)
f = sub(f, 'nq1-fixture.sh', 'c-fixture.sh', 2)
f = sub(f, 'NQ1_FIXTURE_', 'C_FIXTURE_', 8)
# Header last, so the source reference it carries is not rewritten by the identity substitutions above.
f = sub(f, """# N/Q1 disposable PostgreSQL 17.6 cluster helper (lane nq1 only), derived by substitution from the accepted R
# fixture execution/cf8ff737/r-ready/binding/r-fixture.sh (sha256 6e71d754…). LOCK-FREE BY DESIGN:""",
"""# C/contract disposable PostgreSQL 17.6 cluster helper (lane c-contract only), derived by substitution from the N/Q1
# fixture execution/cf8ff737/nq1/binding/nq1-fixture.sh (sha256 29db46ad…). LOCK-FREE BY DESIGN:""")
# The only residual N/Q1 tokens name the source file in the header (execution/cf8ff737/nq1/binding/nq1-fixture.sh).
assert f.lower().replace('n/q1', '').count('nq1') == 2, 'residual nq1 token in fixture'  # header source ref only
open(OUT + 'c-fixture.sh', 'w').write(f)

# ---------------------------------------------------------------- runner
s = open(NB + 'nq1-pg-proof.sh').read()
hdr_old = s[:s.index('set -uo pipefail')]
hdr_new = '''#!/usr/bin/env bash
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
'''
s = hdr_new + s[len(hdr_old):]
pairs = [
    ("D=/home/user/workspace/execution/cf8ff737/nq1/binding", "D=/home/user/workspace/execution/cf8ff737/c/binding"),
    ("RT=/home/user/workspace/execution/cf8ff737/nq1/runtime                    # N/Q1 proof: its own receipt/old-root root",
     "RT=/home/user/workspace/execution/cf8ff737/c/runtime                      # C proof: its own receipt/old-root root"),
    ("W=/home/user/workspace/worktrees/s7-nq1", "W=/home/user/workspace/worktrees/s7-c"),
    ("R=$RT/run; LOG=$R/nq1-pg-proof.log; SENT=$R/nq1-pg-proof.sentinel; JLOG=$R/jest.log",
     "R=$RT/run; LOG=$R/c-pg-proof.log; SENT=$R/c-pg-proof.sentinel; JLOG=$R/jest.log"),
    ("# ---- pins: filled by the binding phase AFTER the N/Q1 head is committed; the script refuses placeholders.",
     "# ---- pins: filled by the binding phase AFTER the C head is committed; the script refuses placeholders.\n"
     "NQ1_HEAD=__NQ1_ACCEPTED_HEAD__                                            # accepted N/Q1 head = the OLD side (committed candidate 61b93cff…; fill on acceptance)"),
    ("EXPECT_HEAD=61b93cff7900b24c17011d481fd6c31f5abb59e4", "EXPECT_HEAD=__FILL_AFTER_COMMIT__"),
    ("EXPECT_TREE=7adad6965d60269046b3240343b54d7f71582d70", "EXPECT_TREE=__FILL_AFTER_COMMIT__"),
    ("EXPECT_SPEC_BLOB=8ad3af3f1f8a43d9006b929fea5e9cb3ae35a7b2                 # test/rls-g2-nq1.spec.ts at the N/Q1 head",
     "EXPECT_SPEC_BLOB=__FILL_AFTER_COMMIT__                 # test/rls-g2-c-contract.spec.ts at the C head"),
    ("EXPECT_BOOTSTRAP_BLOB=96b7668dff7498cee5ed17ab988aae0f38ac512d       # test/utils/g2-nq1-bootstrap.sh at the N/Q1 head",
     "EXPECT_BOOTSTRAP_BLOB=__FILL_AFTER_COMMIT__       # test/utils/g2-c-bootstrap.sh at the C head"),
    ("EXPECT_FIXTURE_SHA=29db46ad3189ca12bd507e79cd2f2b87c3c375aeb454f6db76973bb467ad4bc3           # binding/nq1-fixture.sh",
     "EXPECT_FIXTURE_SHA=__FILL_AFTER_COMMIT__           # binding/c-fixture.sh"),
    ("EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44      # node_modules/.package-lock.json (C1 record, unchanged through B, R and N/Q1; receipt 02)",
     "EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44      # node_modules/.package-lock.json (C1 record, unchanged through B, R, N/Q1 and C; receipt 02)"),
    ("EXPECT_NM_CLIENT_SHA=92d42c56a7f199d41ea518c1f5b9a8c17f34a17f97486942f2691026a1461cf4    # N node_modules/.prisma/client/index.d.ts (receipt 03; N-only generate)",
     "EXPECT_NM_CLIENT_SHA=__FILL_AFTER_GENERATE__    # C node_modules/.prisma/client/index.d.ts (receipt 03; C-only generate, narrow @@unique removed)"),
    ("S5DIR=$PG17_HOME/clusters/s5; C1DIR=$PG17_HOME/clusters/c1-builder; BDIR=$PG17_HOME/clusters/b-drain; RDIR=$PG17_HOME/clusters/r-ready; NDIR=$PG17_HOME/clusters/nq1",
     "S5DIR=$PG17_HOME/clusters/s5; C1DIR=$PG17_HOME/clusters/c1-builder; BDIR=$PG17_HOME/clusters/b-drain; RDIR=$PG17_HOME/clusters/r-ready; NDIR=$PG17_HOME/clusters/nq1; CDIR=$PG17_HOME/clusters/c-contract"),
    ("PORT=55481; DBNAME=g2_nq1_disposable; ADMIN=nq1_super; FIXPASS=nq1_local_synthetic",
     "PORT=55491; DBNAME=g2_c_disposable; ADMIN=c_super; FIXPASS=c_local_synthetic"),
    ("FIX=$D/nq1-fixture.sh", "FIX=$D/c-fixture.sh"),
    ("""# N/Q1-only identity: exactly the G2_NQ1_* names the derived guard/harness/bootstrap/T-root helper read. Nothing
# G2_PG17_*, G2_B_* or G2_R_* is exported.
export G2_NQ1_DATABASE_URL="postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=4" \\
       G2_NQ1_CONFIRM="$DBNAME:$PORT" G2_NQ1_PASSWORD=$FIXPASS G2_NQ1_PSQL=/usr/bin/psql \\
       G2_NQ1_DATA_DIRECTORY=$NDIR/pg-data G2_NQ1_SERVER_VERSION=170006 \\
       G2_NQ1_OLD_ROOT=$RT/old-root G2_NQ1_OLD_CLIENT=$RT/old-root/.g2-nq1-old-client
export NQ1_RUNNER_PID=$$ NQ1_STOP_TIMEOUT=45""",
     """# C-only identity: exactly the G2_C_* names the derived guard/harness/bootstrap/old-root helper read. Nothing
# G2_PG17_*, G2_B_*, G2_R_* or G2_NQ1_* is exported.
export G2_C_DATABASE_URL="postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=4" \\
       G2_C_CONFIRM="$DBNAME:$PORT" G2_C_PASSWORD=$FIXPASS G2_C_PSQL=/usr/bin/psql \\
       G2_C_DATA_DIRECTORY=$CDIR/pg-data G2_C_SERVER_VERSION=170006 \\
       G2_C_OLD_ROOT=$RT/old-root G2_C_OLD_CLIENT=$RT/old-root/.g2-c-old-client
export C_RUNNER_PID=$$ C_STOP_TIMEOUT=45"""),
    ('case "$EXPECT_HEAD$EXPECT_TREE$EXPECT_SPEC_BLOB$EXPECT_BOOTSTRAP_BLOB$EXPECT_FIXTURE_SHA" in *__*)',
     'case "$NQ1_HEAD$EXPECT_HEAD$EXPECT_TREE$EXPECT_SPEC_BLOB$EXPECT_BOOTSTRAP_BLOB$EXPECT_FIXTURE_SHA$EXPECT_NM_CLIENT_SHA" in *__*)'),
    ('[ "$(git -C "$W" rev-parse HEAD:test/rls-g2-nq1.spec.ts)" = "$EXPECT_SPEC_BLOB" ]',
     '[ "$(git -C "$W" rev-parse HEAD:test/rls-g2-c-contract.spec.ts)" = "$EXPECT_SPEC_BLOB" ]'),
    ('[ "$(git -C "$W" rev-parse HEAD:test/utils/g2-nq1-bootstrap.sh)" = "$EXPECT_BOOTSTRAP_BLOB" ]',
     '[ "$(git -C "$W" rev-parse HEAD:test/utils/g2-c-bootstrap.sh)" = "$EXPECT_BOOTSTRAP_BLOB" ]'),
    ("""git -C "$W" merge-base --is-ancestor 7d2895e1fe03ea82353e8ce0b07aacaf66af74c8 HEAD || { log "PRECONDITION_FAIL accepted R head 7d2895e1 not an ancestor (T-root fixture impossible)"; fail 70; }
git -C "$W" diff --quiet 7d2895e1fe03ea82353e8ce0b07aacaf66af74c8 HEAD -- prisma/migrations || { log "PRECONDITION_FAIL prisma/migrations differ from the R head (N/Q1 ships no migration)"; fail 70; }""",
     """git -C "$W" merge-base --is-ancestor 7d2895e1fe03ea82353e8ce0b07aacaf66af74c8 HEAD || { log "PRECONDITION_FAIL accepted R head 7d2895e1 not an ancestor"; fail 70; }
# accepted N/Q1 files must be byte-identical at the committed head (machine check of "N/Q1 files unchanged"; blobs at 61b93cff)
for pin in "test/utils/g2-nq1-db.ts dbe10bcb84b01175a54fa0c4eceb8021fc933719" "test/utils/g2-nq1-pg-harness.ts c8f6fea830304a5b117030eb3c4b97934c55d3fe" \\
           "test/utils/g2-nq1-harness.ts a629c5915b9a2bbebaa15accf2dff4dbc277dbf1" "test/utils/g2-nq1-bootstrap.sh 96b7668dff7498cee5ed17ab988aae0f38ac512d" \\
           "test/utils/g2-nq1-old-root.sh 4569f5febd963379be106d94d8d4612c85bf0c82" "test/scout/g2-nq1-db-guard.spec.ts 9bc14800ddaa81c2148dfd5d8af64b83f45d6eca" \\
           "test/rls-g2-nq1.spec.ts 8ad3af3f1f8a43d9006b929fea5e9cb3ae35a7b2"; do set -- $pin
  [ "$(git -C "$W" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL accepted N/Q1 file $1 changed"; fail 70; }; done
git -C "$W" merge-base --is-ancestor "$NQ1_HEAD" HEAD || { log "PRECONDITION_FAIL accepted N/Q1 head $NQ1_HEAD not an ancestor (old-root fixture impossible)"; fail 70; }
# the candidate ships exactly C: its migration tree differs from the N/Q1 head by migration.sql + down.sql of C and nothing else (no verify.sql)
CM=20270121000000_scout_identity_contract
[ "$(git -C "$W" diff --name-only "$NQ1_HEAD" HEAD -- prisma/migrations | sort | tr '\\n' ' ')" = "prisma/migrations/$CM/down.sql prisma/migrations/$CM/migration.sql " ] \\
  || { log "PRECONDITION_FAIL prisma/migrations differ from the N/Q1 head by other than exactly C's two files"; fail 70; }"""),
    ("# dependency tree: an ISOLATED copy of the accepted R tree (not a symlink into s7-r-ready, not a fresh npm ci); client is N's",
     "# dependency tree: an ISOLATED copy of the accepted N/Q1 tree (not a symlink into s7-nq1, not a fresh npm ci); client is C's"),
    ('{ log "PRECONDITION_FAIL generated client != N record"; fail 70; }', '{ log "PRECONDITION_FAIL generated client != C record"; fail 70; }'),
    ("# ---- step 1 preflight (read-only): N/Q1 lane absent; S5 absent recorded as-is; retained C1, B and R clusters hashed, never started",
     "# ---- step 1 preflight (read-only): C lane absent; S5 absent recorded as-is; retained C1, B, R and N/Q1 clusters hashed, never started"),
    ("""[ ! -e "$NDIR" ] || { log "PREFLIGHT_FAIL $NDIR exists (fresh init only; never adopt)"; fail 71; }""",
     """[ ! -e "$CDIR" ] || { log "PREFLIGHT_FAIL $CDIR exists (fresh init only; never adopt)"; fail 71; }"""),
    ("""(parent requires S5 ABSENT for the N/Q1 lane)""", """(parent requires S5 ABSENT for the C lane)"""),
    ("""else R_CONF0=ABSENT; R_CTRL0=ABSENT; log "PREFLIGHT r_cluster=ABSENT"; fi
""", """else R_CONF0=ABSENT; R_CTRL0=ABSENT; log "PREFLIGHT r_cluster=ABSENT"; fi
if [ -e "$NDIR/pg-data" ]; then
  [ ! -e "$NDIR/pg-data/postmaster.pid" ] || { log "PREFLIGHT_FAIL nq1 postmaster.pid present"; fail 71; }
  N_CONF0=$(sha256sum "$NDIR/pg-data/postgresql.conf" | cut -c1-64); N_CTRL0=$(sha256sum "$NDIR/pg-data/global/pg_control" | cut -c1-64)
  log "PREFLIGHT nq1_cluster=PRESENT_STOPPED conf=$N_CONF0 pg_control=$N_CTRL0 (must be unchanged at end; never started)"
else N_CONF0=ABSENT; N_CTRL0=ABSENT; log "PREFLIGHT nq1_cluster=ABSENT"; fi
"""),
    ("""log "PREFLIGHT_OK $(ts) ndir=absent port$PORT=free""", """log "PREFLIGHT_OK $(ts) cdir=absent port$PORT=free"""),
    ("""grep -q "^NQ1_FIXTURE_INIT_OK data=$NDIR/pg-data port=$PORT superuser=$ADMIN cluster_name=nq1-disposable-pg17" "$LOG\"""",
     """grep -q "^C_FIXTURE_INIT_OK data=$CDIR/pg-data port=$PORT superuser=$ADMIN cluster_name=c-disposable-pg17" "$LOG\""""),
    ("""grep -q "^NQ1_FIXTURE_START_OK pid=" "$LOG\"""", """grep -q "^C_FIXTURE_START_OK pid=" "$LOG\""""),
    ("""# ---- step 4 T (accepted R head 7d2895e1) detached checkout OUTSIDE the candidate (derived helper committed at the N/Q1 head; git only; bound 180 s)
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
grep -q "^G2_NQ1_BOOTSTRAP_OK" "$LOG" || { log "BOOTSTRAP marker missing"; fail 72; }""",
     """# ---- step 4 OLD (accepted N/Q1 head) detached checkout OUTSIDE the candidate (derived helper committed at the C head; git only; bound 180 s)
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
grep -q "^G2_C_BOOTSTRAP_OK" "$LOG" || { log "BOOTSTRAP marker missing"; fail 72; }"""),
    ("""DD=$(psqlq 'SHOW data_directory'); [ "$DD" = "$G2_NQ1_DATA_DIRECTORY" ]""", """DD=$(psqlq 'SHOW data_directory'); [ "$DD" = "$G2_C_DATA_DIRECTORY" ]"""),
    ("""[ "$CN" = nq1-disposable-pg17 ]""", """[ "$CN" = c-disposable-pg17 ]"""),
    ("""[ "$DM" = nq1-g2-synthetic-disposable-fixture-safe-to-drop ]""", """[ "$DM" = c-g2-contract-synthetic-disposable-fixture-safe-to-drop ]"""),
    ("""STAGE=jest; log "JEST_START $(ts) cmd='./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-nq1.spec.ts --runInBand --ci'"
( cd "$W" && timeout -k 30 1500 ./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-nq1.spec.ts --runInBand --ci )""",
     """STAGE=jest; log "JEST_START $(ts) cmd='./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-c-contract.spec.ts --runInBand --ci'"
( cd "$W" && timeout -k 30 1500 ./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-c-contract.spec.ts --runInBand --ci )"""),
    ("""# ---- step 8 stop (bound 45 s + kill 30); data dir RETAINED (destroy only via separate grant: nq1-fixture.sh destroy)""",
     """# ---- step 8 stop (bound 45 s + kill 30); data dir RETAINED (destroy only via separate grant: c-fixture.sh destroy)"""),
    ("""[ ! -e "$NDIR/pg-data/postmaster.pid" ] && [ -d "$NDIR/pg-data" ] || { log "STOP_STATE_FAIL postgres_procs=$P listeners=$L"; fail 74; }
log "STOP_STATE_OK postgres_procs=0 port$PORT=free datadir_retained=$NDIR/pg-data\"""",
     """[ ! -e "$CDIR/pg-data/postmaster.pid" ] && [ -d "$CDIR/pg-data" ] || { log "STOP_STATE_FAIL postgres_procs=$P listeners=$L"; fail 74; }
log "STOP_STATE_OK postgres_procs=0 port$PORT=free datadir_retained=$CDIR/pg-data\""""),
    ("""  log "POST r_cluster unchanged conf=$R_CONF0 pg_control=$R_CTRL0"
fi
""", """  log "POST r_cluster unchanged conf=$R_CONF0 pg_control=$R_CTRL0"
fi
if [ "$N_CONF0" != ABSENT ]; then
  [ "$(sha256sum "$NDIR/pg-data/postgresql.conf" | cut -c1-64)" = "$N_CONF0" ] && [ "$(sha256sum "$NDIR/pg-data/global/pg_control" | cut -c1-64)" = "$N_CTRL0" ] && [ ! -e "$NDIR/pg-data/postmaster.pid" ] || { log "POST_FAIL nq1 cluster changed"; fail 74; }
  log "POST nq1_cluster unchanged conf=$N_CONF0 pg_control=$N_CTRL0"
fi
"""),
    ("""( cd "$R" && sha256sum nq1-pg-proof.log jest.log > RECEIPTS.sha256 )""", """( cd "$R" && sha256sum c-pg-proof.log jest.log > RECEIPTS.sha256 )"""),
]
for old, new in pairs:
    s = sub(s, old, new)
# Residual N/Q1 identity tokens are allowed only where they name the retained N/Q1 cluster, the accepted N/Q1 files
# or the N/Q1 head (the OLD side). None may name this lane's own identity.
for forbidden in ['export G2_NQ1_', '$G2_NQ1_', '^G2_NQ1_', 'NQ1_RUNNER_PID', 'NQ1_STOP_TIMEOUT', 'nq1_super', 'g2_nq1_disposable', '55481', 'nq1-disposable-pg17',
                  'rls-g2-nq1.spec.ts --runInBand', 'g2-nq1-bootstrap.sh )', 'nq1-fixture.sh', 'nq1-pg-proof.log']:
    assert forbidden not in s, f'residual N/Q1 lane token in runner: {forbidden}'
open(OUT + 'c-pg-proof.sh', 'w').write(s)
print('derived', OUT + 'c-fixture.sh', OUT + 'c-pg-proof.sh')
