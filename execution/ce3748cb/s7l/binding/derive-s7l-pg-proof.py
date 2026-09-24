#!/usr/bin/env python3
"""Reproducible derivation of the S7-L1 PG proof binding (s7l-pg-proof.sh, s7l-fixture.sh) from the C
binding (execution/cf8ff737/c/binding/{c-pg-proof.sh,c-fixture.sh}, phase-1 draft form c84ffb12… / cf342f4b…)
by exact-string substitution. Every substitution must match exactly once (or the asserted count); the script
asserts that. Run from /home/user/workspace. Pins EXPECT_HEAD/TREE/SPEC_BLOB/BOOTSTRAP_BLOB/FIXTURE_SHA are
emitted as __FILL_AFTER_COMMIT__, the S7-L1 generated-client sha as __FILL_AFTER_GENERATE__; OLD_HEAD is the
S7-L base (N/Q1 v1 61b93cff while drafting) and is re-pinned to the accepted C head by the mechanical rebase.
DRAFT: nothing here has been executed against PostgreSQL; the runner is executed only under a SEPARATE
single-run PG grant, after the schema hunk, the S7-L1-only prisma generate and the hooked commit of the
SQL/harness (which are source-only, uncommitted drafts at this stage)."""
import sys

CB = 'execution/cf8ff737/c/binding/'
OUT = sys.argv[1] if len(sys.argv) > 1 else 'execution/ce3748cb/s7l/binding/'


def sub(s, old, new, count=1):
    n = s.count(old)
    assert n == count, f'expected {count} match(es), got {n} for: {old[:90]!r}'
    return s.replace(old, new)


# ---------------------------------------------------------------- fixture
f = open(CB + 'c-fixture.sh').read()
f = sub(f, 'execution/cf8ff737/c/binding/c-pg-proof.sh', 'execution/ce3748cb/s7l/binding/s7l-pg-proof.sh')
f = sub(f, 'C proof binding', 'S7-L proof binding')
f = sub(f, "cluster_name = 'c-disposable-pg17'", "cluster_name = 's7l-disposable-pg17'")
f = sub(f, "port 55491, superuser c_super / c_local_synthetic", "port 55501, superuser s7l_super / s7l_local_synthetic")
f = sub(f, "data directory $PG17_HOME/clusters/c-contract/pg-data", "data directory $PG17_HOME/clusters/s7-l/pg-data")
f = sub(f, "PORT=55491; SUPER=c_super; PASS=c_local_synthetic; MARKER=c-disposable-pg17",
        "PORT=55501; SUPER=s7l_super; PASS=s7l_local_synthetic; MARKER=s7l-disposable-pg17")
f = sub(f, "DATA=$PG17_HOME/clusters/c-contract/pg-data; LOG=$PG17_HOME/clusters/c-contract/pg.log; SOCK=$PG17_HOME/run/c-contract",
        "DATA=$PG17_HOME/clusters/s7-l/pg-data; LOG=$PG17_HOME/clusters/s7-l/pg.log; SOCK=$PG17_HOME/run/s7-l")
f = sub(f, "# --- C/contract disposable fixture (2 vCPU / 8 GB sandbox) ---", "# --- S7-L disposable fixture (2 vCPU / 8 GB sandbox) ---")
f = sub(f, "lacks the C marker", "lacks the S7-L marker")
f = sub(f, "is not the marked C cluster", "is not the marked S7-L cluster")
f = sub(f, 'C_STOP_TIMEOUT', 'S7L_STOP_TIMEOUT', 2)
f = sub(f, 'C_RUNNER_PID', 'S7L_RUNNER_PID', 5)
f = sub(f, 'c-pg-proof.sh', 's7l-pg-proof.sh', 3)
f = sub(f, 'c-fixture.sh', 's7l-fixture.sh', 2)
f = sub(f, 'C_FIXTURE_', 'S7L_FIXTURE_', 8)
# Header last, so the source reference it carries is not rewritten by the identity substitutions above.
f = sub(f, """# C/contract disposable PostgreSQL 17.6 cluster helper (lane c-contract only), derived by substitution from the N/Q1
# fixture execution/cf8ff737/nq1/binding/nq1-fixture.sh (sha256 29db46ad…). LOCK-FREE BY DESIGN:""",
"""# S7-L disposable PostgreSQL 17.6 cluster helper (lane s7-l only), derived by substitution from the C
# fixture execution/cf8ff737/c/binding/c-fixture.sh (draft sha256 cf342f4b…). LOCK-FREE BY DESIGN:""")
assert 'c-contract' not in f and 'c_super' not in f and '55491' not in f, 'residual C identity in fixture'
open(OUT + 's7l-fixture.sh', 'w').write(f)

# ---------------------------------------------------------------- runner
s = open(CB + 'c-pg-proof.sh').read()
hdr_old = s[:s.index('set -uo pipefail')]
hdr_new = '''#!/usr/bin/env bash
# S7-L1 real-PG proof — minimal execution binding (DRAFT; NOT RUN; NOT GRANTED; pins __FILL_AFTER_COMMIT__ until the S7-L1 head is committed).
# Derived by substitution from the C binding execution/cf8ff737/c/binding/c-pg-proof.sh (draft sha256 c84ffb12…):
# S7-L identity (port 55501, s7l_super, g2_s7l_disposable, cluster s7-l), the S7-L spec/bootstrap/old-root helper, the S7-L1
# generated-client pin, and the read-only checks: the accepted S5/B/R/N/Q1 files are byte-identical at the S7-L1 head, OLD_HEAD
# (the S7-L base: N/Q1 v1 61b93cff while drafting; re-pinned to the accepted C head after the mechanical rebase) is an ancestor
# (it is the OLD side of this proof: the pre-S7-L1 `/complete` writer), the candidate's prisma/migrations differ from it by
# exactly S7-L1's migration.sql + down.sql, and the retained stopped C1/B/R/N/Q1/C clusters are hashed and never started. The
# old root is a detached checkout of OLD_HEAD (test/utils/g2-s7l-old-root.sh), whose own `prisma migrate deploy` installs the
# whole accepted history; the candidate's `prisma migrate deploy` applies exactly S7-L1 inside the spec (L01). Runs the NEW
# spec test/rls-g2-s7l.spec.ts exactly once via the existing repo jest + jest.rls.config.js. No new test framework, no retry,
# no inherited-proof replay (etq0 / fresh51 / C1 / B / R / N/Q1 / C suites are never invoked). Single canonical lock holder;
# first nonzero stops; the only cleanup attempted is a bounded fixture stop when this run started the postmaster. No autonomous
# cleanup is GUARANTEED: if the outer timeout kills bash, the stop does not run. What governs is the observed terminal
# evidence — the sentinel/log lines, `pgrep -cx postgres`, the port listener count and any survivor pid the stop reports — not
# this header. Data dir RETAINED after stop (destroy = separate marker-gated grant).
# Inner stage bounds: init 60 + start 60 + old-root 180 + bootstrap 900 + identity 4x15 + jest 1500 + stop 75 = 2835 s soft sum.
# Usage (later, under the single-run grant): timeout -k 30 3600 bash .../binding/s7l-pg-proof.sh
# Pre-steps (each its own receipt, in this order, BEFORE pins are filled): mechanical rebase onto the accepted C head (re-pin
# OLD_HEAD here and in g2-s7l-{bootstrap,old-root}.sh / g2-s7l-pg-harness.ts; EXPECTED_MIGRATIONS 169 → 170; add the C file
# pins) → isolated copy of the verified node_modules (receipt 01) → schema.prisma ScoutImport/ImportIntent hunk → S7-L1-only
# prisma generate (receipt 03) → light gates (tsc, eslint, prettier --check, check-r75) → heavy gates under the relayed slot
# (affected + full default jest incl. test/scout/g2-s7l-db-guard.spec.ts) → chain-harness CI dry-run on PG 15.18 (deploy →
# down → re-apply → byte diff) → ordinary Bradley-authored hooked commit → fill EXPECT_* from the committed head → separate PG
# grant for this script.
'''
s = hdr_new + s[len(hdr_old):]
pairs = [
    ("D=/home/user/workspace/execution/cf8ff737/c/binding", "D=/home/user/workspace/execution/ce3748cb/s7l/binding"),
    ("RT=/home/user/workspace/execution/cf8ff737/c/runtime                      # C proof: its own receipt/old-root root",
     "RT=/home/user/workspace/execution/ce3748cb/s7l/runtime                    # S7-L proof: its own receipt/old-root root"),
    ("W=/home/user/workspace/worktrees/s7-c", "W=/home/user/workspace/worktrees/s7-l"),
    ("R=$RT/run; LOG=$R/c-pg-proof.log; SENT=$R/c-pg-proof.sentinel; JLOG=$R/jest.log",
     "R=$RT/run; LOG=$R/s7l-pg-proof.log; SENT=$R/s7l-pg-proof.sentinel; JLOG=$R/jest.log"),
    ("# ---- pins: filled by the binding phase AFTER the C head is committed; the script refuses placeholders.\n"
     "NQ1_HEAD=__NQ1_ACCEPTED_HEAD__                                            # accepted N/Q1 head = the OLD side (committed candidate 61b93cff…; fill on acceptance)",
     "# ---- pins: filled by the binding phase AFTER the S7-L1 head is committed; the script refuses placeholders.\n"
     "OLD_HEAD=61b93cff7900b24c17011d481fd6c31f5abb59e4                         # S7-L base = the OLD side (N/Q1 v1 while drafting; re-pin to the accepted C head after the rebase)"),
    ("EXPECT_SPEC_BLOB=__FILL_AFTER_COMMIT__                 # test/rls-g2-c-contract.spec.ts at the C head",
     "EXPECT_SPEC_BLOB=__FILL_AFTER_COMMIT__                 # test/rls-g2-s7l.spec.ts at the S7-L1 head"),
    ("EXPECT_BOOTSTRAP_BLOB=__FILL_AFTER_COMMIT__       # test/utils/g2-c-bootstrap.sh at the C head",
     "EXPECT_BOOTSTRAP_BLOB=__FILL_AFTER_COMMIT__       # test/utils/g2-s7l-bootstrap.sh at the S7-L1 head"),
    ("EXPECT_FIXTURE_SHA=__FILL_AFTER_COMMIT__           # binding/c-fixture.sh",
     "EXPECT_FIXTURE_SHA=__FILL_AFTER_COMMIT__           # binding/s7l-fixture.sh"),
    ("EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44      # node_modules/.package-lock.json (C1 record, unchanged through B, R, N/Q1 and C; receipt 02)",
     "EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44      # node_modules/.package-lock.json (C1 record, unchanged through B, R, N/Q1, C and S7-L; receipt 01)"),
    ("EXPECT_NM_CLIENT_SHA=__FILL_AFTER_GENERATE__    # C node_modules/.prisma/client/index.d.ts (receipt 03; C-only generate, narrow @@unique removed)",
     "EXPECT_NM_CLIENT_SHA=__FILL_AFTER_GENERATE__    # S7-L1 node_modules/.prisma/client/index.d.ts (receipt 03; S7-L1-only generate, ScoutImport lifecycle fields)"),
    ("S5DIR=$PG17_HOME/clusters/s5; C1DIR=$PG17_HOME/clusters/c1-builder; BDIR=$PG17_HOME/clusters/b-drain; RDIR=$PG17_HOME/clusters/r-ready; NDIR=$PG17_HOME/clusters/nq1; CDIR=$PG17_HOME/clusters/c-contract",
     "S5DIR=$PG17_HOME/clusters/s5; C1DIR=$PG17_HOME/clusters/c1-builder; BDIR=$PG17_HOME/clusters/b-drain; RDIR=$PG17_HOME/clusters/r-ready; NDIR=$PG17_HOME/clusters/nq1; CDIR=$PG17_HOME/clusters/c-contract; LDIR=$PG17_HOME/clusters/s7-l"),
    ("PORT=55491; DBNAME=g2_c_disposable; ADMIN=c_super; FIXPASS=c_local_synthetic",
     "PORT=55501; DBNAME=g2_s7l_disposable; ADMIN=s7l_super; FIXPASS=s7l_local_synthetic"),
    ("FIX=$D/c-fixture.sh", "FIX=$D/s7l-fixture.sh"),
    ("""# C-only identity: exactly the G2_C_* names the derived guard/harness/bootstrap/old-root helper read. Nothing
# G2_PG17_*, G2_B_*, G2_R_* or G2_NQ1_* is exported.
export G2_C_DATABASE_URL="postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=4" \\
       G2_C_CONFIRM="$DBNAME:$PORT" G2_C_PASSWORD=$FIXPASS G2_C_PSQL=/usr/bin/psql \\
       G2_C_DATA_DIRECTORY=$CDIR/pg-data G2_C_SERVER_VERSION=170006 \\
       G2_C_OLD_ROOT=$RT/old-root G2_C_OLD_CLIENT=$RT/old-root/.g2-c-old-client
export C_RUNNER_PID=$$ C_STOP_TIMEOUT=45""",
     """# S7-L-only identity: exactly the G2_S7L_* names the derived guard/harness/bootstrap/old-root helper read. Nothing
# G2_PG17_*, G2_B_*, G2_R_*, G2_NQ1_* or G2_C_* is exported.
export G2_S7L_DATABASE_URL="postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=4" \\
       G2_S7L_CONFIRM="$DBNAME:$PORT" G2_S7L_PASSWORD=$FIXPASS G2_S7L_PSQL=/usr/bin/psql \\
       G2_S7L_DATA_DIRECTORY=$LDIR/pg-data G2_S7L_SERVER_VERSION=170006 \\
       G2_S7L_OLD_ROOT=$RT/old-root G2_S7L_OLD_CLIENT=$RT/old-root/.g2-s7l-old-client
export S7L_RUNNER_PID=$$ S7L_STOP_TIMEOUT=45"""),
    ('case "$NQ1_HEAD$EXPECT_HEAD$EXPECT_TREE$EXPECT_SPEC_BLOB$EXPECT_BOOTSTRAP_BLOB$EXPECT_FIXTURE_SHA$EXPECT_NM_CLIENT_SHA" in *__*)',
     'case "$OLD_HEAD$EXPECT_HEAD$EXPECT_TREE$EXPECT_SPEC_BLOB$EXPECT_BOOTSTRAP_BLOB$EXPECT_FIXTURE_SHA$EXPECT_NM_CLIENT_SHA" in *__*)'),
    ('[ "$(git -C "$W" rev-parse HEAD:test/rls-g2-c-contract.spec.ts)" = "$EXPECT_SPEC_BLOB" ]',
     '[ "$(git -C "$W" rev-parse HEAD:test/rls-g2-s7l.spec.ts)" = "$EXPECT_SPEC_BLOB" ]'),
    ('[ "$(git -C "$W" rev-parse HEAD:test/utils/g2-c-bootstrap.sh)" = "$EXPECT_BOOTSTRAP_BLOB" ]',
     '[ "$(git -C "$W" rev-parse HEAD:test/utils/g2-s7l-bootstrap.sh)" = "$EXPECT_BOOTSTRAP_BLOB" ]'),
    ("""git -C "$W" merge-base --is-ancestor "$NQ1_HEAD" HEAD || { log "PRECONDITION_FAIL accepted N/Q1 head $NQ1_HEAD not an ancestor (old-root fixture impossible)"; fail 70; }
# the candidate ships exactly C: its migration tree differs from the N/Q1 head by migration.sql + down.sql of C and nothing else (no verify.sql)
CM=20270121000000_scout_identity_contract
[ "$(git -C "$W" diff --name-only "$NQ1_HEAD" HEAD -- prisma/migrations | sort | tr '\\n' ' ')" = "prisma/migrations/$CM/down.sql prisma/migrations/$CM/migration.sql " ] \\
  || { log "PRECONDITION_FAIL prisma/migrations differ from the N/Q1 head by other than exactly C's two files"; fail 70; }""",
     """git -C "$W" merge-base --is-ancestor 61b93cff7900b24c17011d481fd6c31f5abb59e4 HEAD || { log "PRECONDITION_FAIL N/Q1 v1 head 61b93cff not an ancestor"; fail 70; }
# accepted C files (g2-c-*, rls-g2-c-contract.spec.ts, 20270121000000_scout_identity_contract): add their blob pins here on the
# mechanical rebase onto the accepted C head (none exist at the N/Q1 v1 base this draft is written on).
git -C "$W" merge-base --is-ancestor "$OLD_HEAD" HEAD || { log "PRECONDITION_FAIL OLD head $OLD_HEAD not an ancestor (old-root fixture impossible)"; fail 70; }
# the candidate ships exactly S7-L1: its migration tree differs from OLD_HEAD by migration.sql + down.sql of S7-L1 and nothing else
LM=20270123000000_scout_run_lifecycle_expand
[ "$(git -C "$W" diff --name-only "$OLD_HEAD" HEAD -- prisma/migrations | sort | tr '\\n' ' ')" = "prisma/migrations/$LM/down.sql prisma/migrations/$LM/migration.sql " ] \\
  || { log "PRECONDITION_FAIL prisma/migrations differ from OLD_HEAD by other than exactly S7-L1's two files"; fail 70; }
# the S7-L1 schema hunk is present and the draft-stage exclusions hold: no service/route code under src/scout/lifecycle, no contract regen
grep -q '^ *mode  *String' "$W/prisma/schema.prisma" && awk '/model ScoutImport \\{/,/\\}/' "$W/prisma/schema.prisma" | grep -q 'import_intent_id' \\
  || { log "PRECONDITION_FAIL prisma/schema.prisma lacks the S7-L1 ScoutImport hunk"; fail 70; }
[ ! -e "$W/src/scout/lifecycle" ] || { log "PRECONDITION_FAIL src/scout/lifecycle present (S7-L2 is not part of this proof)"; fail 70; }"""),
    ("# dependency tree: an ISOLATED copy of the accepted N/Q1 tree (not a symlink into s7-nq1, not a fresh npm ci); client is C's",
     "# dependency tree: an ISOLATED copy of the verified N/Q1 tree (not a symlink into s7-nq1, not a fresh npm ci; receipt 01); client is S7-L1's"),
    ('{ log "PRECONDITION_FAIL generated client != C record"; fail 70; }', '{ log "PRECONDITION_FAIL generated client != S7-L1 record"; fail 70; }'),
    ("# ---- step 1 preflight (read-only): C lane absent; S5 absent recorded as-is; retained C1, B, R and N/Q1 clusters hashed, never started",
     "# ---- step 1 preflight (read-only): S7-L lane absent; S5 absent recorded as-is; retained C1, B, R, N/Q1 and C clusters hashed, never started"),
    ("""[ ! -e "$CDIR" ] || { log "PREFLIGHT_FAIL $CDIR exists (fresh init only; never adopt)"; fail 71; }""",
     """[ ! -e "$LDIR" ] || { log "PREFLIGHT_FAIL $LDIR exists (fresh init only; never adopt)"; fail 71; }"""),
    ("""(parent requires S5 ABSENT for the C lane)""", """(parent requires S5 ABSENT for the S7-L lane)"""),
    ("""else N_CONF0=ABSENT; N_CTRL0=ABSENT; log "PREFLIGHT nq1_cluster=ABSENT"; fi
""", """else N_CONF0=ABSENT; N_CTRL0=ABSENT; log "PREFLIGHT nq1_cluster=ABSENT"; fi
if [ -e "$CDIR/pg-data" ]; then
  [ ! -e "$CDIR/pg-data/postmaster.pid" ] || { log "PREFLIGHT_FAIL c-contract postmaster.pid present"; fail 71; }
  C_CONF0=$(sha256sum "$CDIR/pg-data/postgresql.conf" | cut -c1-64); C_CTRL0=$(sha256sum "$CDIR/pg-data/global/pg_control" | cut -c1-64)
  log "PREFLIGHT c_cluster=PRESENT_STOPPED conf=$C_CONF0 pg_control=$C_CTRL0 (must be unchanged at end; never started)"
else C_CONF0=ABSENT; C_CTRL0=ABSENT; log "PREFLIGHT c_cluster=ABSENT"; fi
"""),
    ("""log "PREFLIGHT_OK $(ts) cdir=absent port$PORT=free""", """log "PREFLIGHT_OK $(ts) ldir=absent port$PORT=free"""),
    ("""grep -q "^C_FIXTURE_INIT_OK data=$CDIR/pg-data port=$PORT superuser=$ADMIN cluster_name=c-disposable-pg17" "$LOG\"""",
     """grep -q "^S7L_FIXTURE_INIT_OK data=$LDIR/pg-data port=$PORT superuser=$ADMIN cluster_name=s7l-disposable-pg17" "$LOG\""""),
    ("""grep -q "^C_FIXTURE_START_OK pid=" "$LOG\"""", """grep -q "^S7L_FIXTURE_START_OK pid=" "$LOG\""""),
    ("""# ---- step 4 OLD (accepted N/Q1 head) detached checkout OUTSIDE the candidate (derived helper committed at the C head; git only; bound 180 s)
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
grep -q "^G2_C_BOOTSTRAP_OK" "$LOG" || { log "BOOTSTRAP marker missing"; fail 72; }""",
     """# ---- step 4 OLD (OLD_HEAD) detached checkout OUTSIDE the candidate (derived helper committed at the S7-L1 head; git only; bound 180 s)
STAGE=old-root
( cd "$W" && timeout -k 30 180 bash test/utils/g2-s7l-old-root.sh create ) >>"$LOG" 2>&1; rc=$?
log "OLD_ROOT rc=$rc $(ts) head=$(git -C "$G2_S7L_OLD_ROOT" rev-parse HEAD 2>/dev/null)"; [ $rc = 0 ] || fail $rc
grep -q "^G2_S7L_OLD_ROOT_OK" "$LOG" || { log "OLD_ROOT marker missing"; fail 72; }
[ "$(git -C "$G2_S7L_OLD_ROOT" rev-parse HEAD)" = "$OLD_HEAD" ] || { log "OLD_ROOT head is not OLD_HEAD"; fail 72; }
# ---- step 5 S7-L bootstrap (derived helper committed at the S7-L1 head; roles, marked DB, shim, the whole accepted history
#      through the old root's `prisma migrate deploy` — S7-L1 NOT applied here (the spec applies it through the candidate's
#      `prisma migrate deploy`, L01) — old client generate inside the old root, the only `prisma generate` of the run; the
#      S7-L1 candidate client only VERIFIED) (bound 900 s)
STAGE=bootstrap
( cd "$W" && timeout -k 30 900 bash test/utils/g2-s7l-bootstrap.sh ) >>"$LOG" 2>&1; rc=$?; log "BOOTSTRAP rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^G2_S7L_BOOTSTRAP_OK" "$LOG" || { log "BOOTSTRAP marker missing"; fail 72; }"""),
    ("""DD=$(psqlq 'SHOW data_directory'); [ "$DD" = "$G2_C_DATA_DIRECTORY" ]""", """DD=$(psqlq 'SHOW data_directory'); [ "$DD" = "$G2_S7L_DATA_DIRECTORY" ]"""),
    ("""[ "$CN" = c-disposable-pg17 ]""", """[ "$CN" = s7l-disposable-pg17 ]"""),
    ("""[ "$DM" = c-g2-contract-synthetic-disposable-fixture-safe-to-drop ]""", """[ "$DM" = s7l-g2-lifecycle-synthetic-disposable-fixture-safe-to-drop ]"""),
    ("""STAGE=jest; log "JEST_START $(ts) cmd='./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-c-contract.spec.ts --runInBand --ci'"
( cd "$W" && timeout -k 30 1500 ./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-c-contract.spec.ts --runInBand --ci )""",
     """STAGE=jest; log "JEST_START $(ts) cmd='./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s7l.spec.ts --runInBand --ci'"
( cd "$W" && timeout -k 30 1500 ./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s7l.spec.ts --runInBand --ci )"""),
    ("""# ---- step 8 stop (bound 45 s + kill 30); data dir RETAINED (destroy only via separate grant: c-fixture.sh destroy)""",
     """# ---- step 8 stop (bound 45 s + kill 30); data dir RETAINED (destroy only via separate grant: s7l-fixture.sh destroy)"""),
    ("""[ ! -e "$CDIR/pg-data/postmaster.pid" ] && [ -d "$CDIR/pg-data" ] || { log "STOP_STATE_FAIL postgres_procs=$P listeners=$L"; fail 74; }
log "STOP_STATE_OK postgres_procs=0 port$PORT=free datadir_retained=$CDIR/pg-data\"""",
     """[ ! -e "$LDIR/pg-data/postmaster.pid" ] && [ -d "$LDIR/pg-data" ] || { log "STOP_STATE_FAIL postgres_procs=$P listeners=$L"; fail 74; }
log "STOP_STATE_OK postgres_procs=0 port$PORT=free datadir_retained=$LDIR/pg-data\""""),
    ("""  log "POST nq1_cluster unchanged conf=$N_CONF0 pg_control=$N_CTRL0"
fi
""", """  log "POST nq1_cluster unchanged conf=$N_CONF0 pg_control=$N_CTRL0"
fi
if [ "$C_CONF0" != ABSENT ]; then
  [ "$(sha256sum "$CDIR/pg-data/postgresql.conf" | cut -c1-64)" = "$C_CONF0" ] && [ "$(sha256sum "$CDIR/pg-data/global/pg_control" | cut -c1-64)" = "$C_CTRL0" ] && [ ! -e "$CDIR/pg-data/postmaster.pid" ] || { log "POST_FAIL c-contract cluster changed"; fail 74; }
  log "POST c_cluster unchanged conf=$C_CONF0 pg_control=$C_CTRL0"
fi
"""),
    ("""( cd "$R" && sha256sum c-pg-proof.log jest.log > RECEIPTS.sha256 )""", """( cd "$R" && sha256sum s7l-pg-proof.log jest.log > RECEIPTS.sha256 )"""),
]
for old, new in pairs:
    s = sub(s, old, new)
# Residual identity tokens: none of the C lane identity may survive in executable lines (comments may reference C).
body = '\n'.join(l for l in s[len(hdr_new):].split('\n') if not l.lstrip().startswith('#'))
for token in ('G2_C_', 'c_super', '55491', 'g2_c_disposable', 'c-disposable-pg17', 'C_RUNNER_PID', 'C_STOP_TIMEOUT',
              'C_FIXTURE_', 'g2-c-', 'rls-g2-c-contract', 'NQ1_HEAD', 'c-fixture.sh', 'c-pg-proof'):
    assert token not in body, f'residual C token in runner body: {token}'
open(OUT + 's7l-pg-proof.sh', 'w').write(s)
print('derived s7l-fixture.sh and s7l-pg-proof.sh')
