#!/usr/bin/env python3
"""Reproducible derivation of the S8-B PG proof binding (s8b-pg-proof.sh, s8b-fixture.sh) from the S7-L
binding (execution/ce3748cb/s7l/binding/{s7l-pg-proof.sh,s7l-fixture.sh}, draft form d351870c… / 6b3a76f4…)
by exact-string substitution. Every substitution must match exactly once (or the asserted count); the script
asserts that. Run from /home/user/workspace. Pins EXPECT_HEAD/TREE/SPEC_BLOB/BOOTSTRAP_BLOB/FIXTURE_SHA are
emitted as __FILL_AFTER_COMMIT__, the S8-B generated-client sha as __FILL_AFTER_GENERATE__; OLD_HEAD is the
S8-B base (accepted N/Q1 head 29e60705 while drafting) and is re-pinned to the accepted C head by the mechanical
rebase. The S7-L lane (clusters/s7-l, port 55501) is treated like every other retained lane: hashed if present
and stopped, never started, never adopted. DRAFT: nothing here has been executed against PostgreSQL; the runner
is executed only under a SEPARATE single-run PG grant, after the schema.prisma hunk, the S8-B-only prisma
generate and the hooked commit of the SQL/harness (which are source-only, uncommitted drafts at this stage)."""
import sys

SB = 'execution/ce3748cb/s7l/binding/'
OUT = sys.argv[1] if len(sys.argv) > 1 else 'execution/ce3748cb/s8b/binding/'


def sub(s, old, new, count=1):
    n = s.count(old)
    assert n == count, f'expected {count} match(es), got {n} for: {old[:90]!r}'
    return s.replace(old, new)


# ---------------------------------------------------------------- fixture
f = open(SB + 's7l-fixture.sh').read()
f = sub(f, 'execution/ce3748cb/s7l/binding/s7l-pg-proof.sh', 'execution/ce3748cb/s8b/binding/s8b-pg-proof.sh')
f = sub(f, 'S7-L proof binding', 'S8-B proof binding')
f = sub(f, "cluster_name = 's7l-disposable-pg17'", "cluster_name = 's8b-disposable-pg17'")
f = sub(f, "port 55501, superuser s7l_super / s7l_local_synthetic", "port 55511, superuser s8b_super / s8b_local_synthetic")
f = sub(f, "data directory $PG17_HOME/clusters/s7-l/pg-data", "data directory $PG17_HOME/clusters/s8-b/pg-data")
f = sub(f, "PORT=55501; SUPER=s7l_super; PASS=s7l_local_synthetic; MARKER=s7l-disposable-pg17",
        "PORT=55511; SUPER=s8b_super; PASS=s8b_local_synthetic; MARKER=s8b-disposable-pg17")
f = sub(f, "DATA=$PG17_HOME/clusters/s7-l/pg-data; LOG=$PG17_HOME/clusters/s7-l/pg.log; SOCK=$PG17_HOME/run/s7-l",
        "DATA=$PG17_HOME/clusters/s8-b/pg-data; LOG=$PG17_HOME/clusters/s8-b/pg.log; SOCK=$PG17_HOME/run/s8-b")
f = sub(f, "# --- S7-L disposable fixture (2 vCPU / 8 GB sandbox) ---", "# --- S8-B disposable fixture (2 vCPU / 8 GB sandbox) ---")
f = sub(f, "lacks the S7-L marker", "lacks the S8-B marker")
f = sub(f, "is not the marked S7-L cluster", "is not the marked S8-B cluster")
f = sub(f, 'S7L_STOP_TIMEOUT', 'S8B_STOP_TIMEOUT', 2)
f = sub(f, 'S7L_RUNNER_PID', 'S8B_RUNNER_PID', 5)
f = sub(f, 's7l-pg-proof.sh', 's8b-pg-proof.sh', 3)
f = sub(f, 's7l-fixture.sh', 's8b-fixture.sh', 2)
f = sub(f, 'S7L_FIXTURE_', 'S8B_FIXTURE_', 8)
# Header last, so the source reference it carries is not rewritten by the identity substitutions above.
f = sub(f, """# S7-L disposable PostgreSQL 17.6 cluster helper (lane s7-l only), derived by substitution from the C
# fixture execution/cf8ff737/c/binding/c-fixture.sh (draft sha256 cf342f4b…). LOCK-FREE BY DESIGN:""",
"""# S8-B disposable PostgreSQL 17.6 cluster helper (lane s8-b only), derived by substitution from the S7-L
# fixture execution/ce3748cb/s7l/binding/s7l-fixture.sh (draft sha256 6b3a76f4…). LOCK-FREE BY DESIGN:""")
assert 'clusters/s7-l' not in f and 's7l_super' not in f and '55501' not in f and 'run/s7-l' not in f, 'residual S7-L identity in fixture'
open(OUT + 's8b-fixture.sh', 'w').write(f)

# ---------------------------------------------------------------- runner
s = open(SB + 's7l-pg-proof.sh').read()
hdr_old = s[:s.index('set -uo pipefail')]
hdr_new = '''#!/usr/bin/env bash
# S8-B real-PG proof — minimal execution binding (DRAFT; NOT RUN; NOT GRANTED; pins __FILL_AFTER_COMMIT__ until the S8-B head is committed).
# Derived by substitution from the S7-L binding execution/ce3748cb/s7l/binding/s7l-pg-proof.sh (draft sha256 d351870c…):
# S8-B identity (port 55511, s8b_super, g2_s8b_disposable, cluster s8-b), the S8-B spec/bootstrap/old-root helper, the S8-B
# generated-client pin, and the read-only checks: the accepted S5/B/R/N/Q1 files are byte-identical at the S8-B head, OLD_HEAD
# (the S8-B base: the accepted N/Q1 head 29e60705 while drafting; re-pinned to the accepted C head after the mechanical rebase)
# is an ancestor (it is the OLD side of this proof: the unchanged N/Q1 reconstruction writer and roster reader), the candidate's
# prisma/migrations differ from it by exactly S8-B's migration.sql + down.sql, and the retained stopped C1/B/R/N/Q1/C/S7-L
# clusters are hashed and never started. The old root is a detached checkout of OLD_HEAD (test/utils/g2-s8b-old-root.sh), whose
# own `prisma migrate deploy` installs the whole accepted history; the candidate's `prisma migrate deploy` applies exactly S8-B
# inside the spec (P01). Runs the NEW spec test/rls-g2-s8b.spec.ts exactly once via the existing repo jest + jest.rls.config.js.
# No new test framework, no retry, no inherited-proof replay (etq0 / fresh51 / C1 / B / R / N/Q1 / C / S7-L suites are never
# invoked). Single canonical lock holder; first nonzero stops; the only cleanup attempted is a bounded fixture stop when this run
# started the postmaster. No autonomous cleanup is GUARANTEED: if the outer timeout kills bash, the stop does not run. What
# governs is the observed terminal evidence — the sentinel/log lines, `pgrep -cx postgres`, the port listener count and any
# survivor pid the stop reports — not this header. Data dir RETAINED after stop (destroy = separate marker-gated grant).
# Order-independent of S7-L1 (20270123): this proof needs only the accepted C head as OLD_HEAD; S7-L1 may land before or after.
# Inner stage bounds: init 60 + start 60 + old-root 180 + bootstrap 900 + identity 4x15 + jest 1500 + stop 75 = 2835 s soft sum.
# Usage (later, under the single-run grant): timeout -k 30 3600 bash .../binding/s8b-pg-proof.sh
# Pre-steps (each its own receipt, in this order, BEFORE pins are filled): mechanical rebase onto the accepted C head (re-pin
# OLD_HEAD here and in g2-s8b-{bootstrap,old-root}.sh / g2-s8b-pg-harness.ts / EXPECTED_HISTORY in rls-g2-s8b.spec.ts;
# EXPECTED_MIGRATIONS 169 → 170; add the C file pins) → isolated copy of the verified node_modules (receipt 01, DONE at draft) →
# schema.prisma ImportNativeProvenance/ScoutReconstructionLedger.target_kind/ImportIntent back-relation hunk → S8-B-only prisma
# generate (receipt 04) → light gates (tsc, eslint, prettier --check, check-r75) → heavy gates under the relayed slot (affected +
# full default jest incl. test/scout/g2-s8b-db-guard.spec.ts) → chain-harness CI dry-run on PG 15.18 (deploy → down → re-apply →
# byte diff) → ordinary Bradley-authored hooked commit → fill EXPECT_* from the committed head → separate PG grant for this script.
'''
s = hdr_new + s[len(hdr_old):]
pairs = [
    ("D=/home/user/workspace/execution/ce3748cb/s7l/binding", "D=/home/user/workspace/execution/ce3748cb/s8b/binding"),
    ("RT=/home/user/workspace/execution/ce3748cb/s7l/runtime                    # S7-L proof: its own receipt/old-root root",
     "RT=/home/user/workspace/execution/ce3748cb/s8b/runtime                    # S8-B proof: its own receipt/old-root root"),
    ("W=/home/user/workspace/worktrees/s7-l", "W=/home/user/workspace/worktrees/s8-b"),
    ("R=$RT/run; LOG=$R/s7l-pg-proof.log; SENT=$R/s7l-pg-proof.sentinel; JLOG=$R/jest.log",
     "R=$RT/run; LOG=$R/s8b-pg-proof.log; SENT=$R/s8b-pg-proof.sentinel; JLOG=$R/jest.log"),
    ("# ---- pins: filled by the binding phase AFTER the S7-L1 head is committed; the script refuses placeholders.\n"
     "OLD_HEAD=61b93cff7900b24c17011d481fd6c31f5abb59e4                         # S7-L base = the OLD side (N/Q1 v1 while drafting; re-pin to the accepted C head after the rebase)",
     "# ---- pins: filled by the binding phase AFTER the S8-B head is committed; the script refuses placeholders.\n"
     "OLD_HEAD=29e60705d8c4e1228fd1d2f248c7e53b6b8e56dd                         # S8-B base = the OLD side (accepted N/Q1 head while drafting; re-pin to the accepted C head after the rebase)"),
    ("EXPECT_SPEC_BLOB=__FILL_AFTER_COMMIT__                 # test/rls-g2-s7l.spec.ts at the S7-L1 head",
     "EXPECT_SPEC_BLOB=__FILL_AFTER_COMMIT__                 # test/rls-g2-s8b.spec.ts at the S8-B head"),
    ("EXPECT_BOOTSTRAP_BLOB=__FILL_AFTER_COMMIT__       # test/utils/g2-s7l-bootstrap.sh at the S7-L1 head",
     "EXPECT_BOOTSTRAP_BLOB=__FILL_AFTER_COMMIT__       # test/utils/g2-s8b-bootstrap.sh at the S8-B head"),
    ("EXPECT_FIXTURE_SHA=__FILL_AFTER_COMMIT__           # binding/s7l-fixture.sh",
     "EXPECT_FIXTURE_SHA=__FILL_AFTER_COMMIT__           # binding/s8b-fixture.sh"),
    ("EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44      # node_modules/.package-lock.json (C1 record, unchanged through B, R, N/Q1, C and S7-L; receipt 01)",
     "EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44      # node_modules/.package-lock.json (C1 record, unchanged through B, R, N/Q1, C, S7-L and S8-B; receipt 01)"),
    ("EXPECT_NM_CLIENT_SHA=__FILL_AFTER_GENERATE__    # S7-L1 node_modules/.prisma/client/index.d.ts (receipt 03; S7-L1-only generate, ScoutImport lifecycle fields)",
     "EXPECT_NM_CLIENT_SHA=__FILL_AFTER_GENERATE__    # S8-B node_modules/.prisma/client/index.d.ts (receipt 04; S8-B-only generate, ImportNativeProvenance + ledger target_kind)"),
    ("S5DIR=$PG17_HOME/clusters/s5; C1DIR=$PG17_HOME/clusters/c1-builder; BDIR=$PG17_HOME/clusters/b-drain; RDIR=$PG17_HOME/clusters/r-ready; NDIR=$PG17_HOME/clusters/nq1; CDIR=$PG17_HOME/clusters/c-contract; LDIR=$PG17_HOME/clusters/s7-l",
     "S5DIR=$PG17_HOME/clusters/s5; C1DIR=$PG17_HOME/clusters/c1-builder; BDIR=$PG17_HOME/clusters/b-drain; RDIR=$PG17_HOME/clusters/r-ready; NDIR=$PG17_HOME/clusters/nq1; CDIR=$PG17_HOME/clusters/c-contract; LDIR=$PG17_HOME/clusters/s7-l; BDIR8=$PG17_HOME/clusters/s8-b"),
    ("PORT=55501; DBNAME=g2_s7l_disposable; ADMIN=s7l_super; FIXPASS=s7l_local_synthetic",
     "PORT=55511; DBNAME=g2_s8b_disposable; ADMIN=s8b_super; FIXPASS=s8b_local_synthetic"),
    ("FIX=$D/s7l-fixture.sh", "FIX=$D/s8b-fixture.sh"),
    ("""# S7-L-only identity: exactly the G2_S7L_* names the derived guard/harness/bootstrap/old-root helper read. Nothing
# G2_PG17_*, G2_B_*, G2_R_*, G2_NQ1_* or G2_C_* is exported.
export G2_S7L_DATABASE_URL="postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=4" \\
       G2_S7L_CONFIRM="$DBNAME:$PORT" G2_S7L_PASSWORD=$FIXPASS G2_S7L_PSQL=/usr/bin/psql \\
       G2_S7L_DATA_DIRECTORY=$LDIR/pg-data G2_S7L_SERVER_VERSION=170006 \\
       G2_S7L_OLD_ROOT=$RT/old-root G2_S7L_OLD_CLIENT=$RT/old-root/.g2-s7l-old-client
export S7L_RUNNER_PID=$$ S7L_STOP_TIMEOUT=45""",
     """# S8-B-only identity: exactly the G2_S8B_* names the derived guard/harness/bootstrap/old-root helper read. Nothing
# G2_PG17_*, G2_B_*, G2_R_*, G2_NQ1_*, G2_C_* or G2_S7L_* is exported.
export G2_S8B_DATABASE_URL="postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=4" \\
       G2_S8B_CONFIRM="$DBNAME:$PORT" G2_S8B_PASSWORD=$FIXPASS G2_S8B_PSQL=/usr/bin/psql \\
       G2_S8B_DATA_DIRECTORY=$BDIR8/pg-data G2_S8B_SERVER_VERSION=170006 \\
       G2_S8B_OLD_ROOT=$RT/old-root G2_S8B_OLD_CLIENT=$RT/old-root/.g2-s8b-old-client
export S8B_RUNNER_PID=$$ S8B_STOP_TIMEOUT=45"""),
    ('[ "$(git -C "$W" rev-parse HEAD:test/rls-g2-s7l.spec.ts)" = "$EXPECT_SPEC_BLOB" ]',
     '[ "$(git -C "$W" rev-parse HEAD:test/rls-g2-s8b.spec.ts)" = "$EXPECT_SPEC_BLOB" ]'),
    ('[ "$(git -C "$W" rev-parse HEAD:test/utils/g2-s7l-bootstrap.sh)" = "$EXPECT_BOOTSTRAP_BLOB" ]',
     '[ "$(git -C "$W" rev-parse HEAD:test/utils/g2-s8b-bootstrap.sh)" = "$EXPECT_BOOTSTRAP_BLOB" ]'),
    ("""# the candidate ships exactly S7-L1: its migration tree differs from OLD_HEAD by migration.sql + down.sql of S7-L1 and nothing else
LM=20270123000000_scout_run_lifecycle_expand
[ "$(git -C "$W" diff --name-only "$OLD_HEAD" HEAD -- prisma/migrations | sort | tr '\\n' ' ')" = "prisma/migrations/$LM/down.sql prisma/migrations/$LM/migration.sql " ] \\
  || { log "PRECONDITION_FAIL prisma/migrations differ from OLD_HEAD by other than exactly S7-L1's two files"; fail 70; }
# the S7-L1 schema hunk is present and the draft-stage exclusions hold: no service/route code under src/scout/lifecycle, no contract regen
grep -q '^ *mode  *String' "$W/prisma/schema.prisma" && awk '/model ScoutImport \\{/,/\\}/' "$W/prisma/schema.prisma" | grep -q 'import_intent_id' \\
  || { log "PRECONDITION_FAIL prisma/schema.prisma lacks the S7-L1 ScoutImport hunk"; fail 70; }
[ ! -e "$W/src/scout/lifecycle" ] || { log "PRECONDITION_FAIL src/scout/lifecycle present (S7-L2 is not part of this proof)"; fail 70; }""",
     """# the candidate ships exactly S8-B: its migration tree differs from OLD_HEAD by migration.sql + down.sql of S8-B and nothing else
PM=20270122000000_scout_native_provenance_expand
[ "$(git -C "$W" diff --name-only "$OLD_HEAD" HEAD -- prisma/migrations | sort | tr '\\n' ' ')" = "prisma/migrations/$PM/down.sql prisma/migrations/$PM/migration.sql " ] \\
  || { log "PRECONDITION_FAIL prisma/migrations differ from OLD_HEAD by other than exactly S8-B's two files"; fail 70; }
# the S8-B schema hunk is present and the draft-stage exclusions hold: schema-only (no S8-C/S8-D/S8-E writer code under src/scout/native)
grep -q '^model ImportNativeProvenance ' "$W/prisma/schema.prisma" && awk '/model ScoutReconstructionLedger \\{/,/\\}/' "$W/prisma/schema.prisma" | grep -Eq '^ +target_kind +String\\?' \\
  || { log "PRECONDITION_FAIL prisma/schema.prisma lacks the S8-B ImportNativeProvenance / ledger target_kind hunk"; fail 70; }
[ ! -e "$W/src/scout/native" ] || { log "PRECONDITION_FAIL src/scout/native present (S8-C..E writers are not part of this proof)"; fail 70; }
# the OLD-side writer/reader the mixed-version stage depends on is byte-identical at the S8-B head (N writer never names target_kind)
for file in src/scout/scout-reconstruct.service.ts src/scout/scout-roster.service.ts src/scout/scout-entities.service.ts src/scout/reconstruct/families.ts; do
  [ "$(git -C "$W" rev-parse "HEAD:$file")" = "$(git -C "$W" rev-parse "$OLD_HEAD:$file")" ] || { log "PRECONDITION_FAIL $file differs from OLD_HEAD (mixed-version basis broken)"; fail 70; }; done"""),
    ("# dependency tree: an ISOLATED copy of the verified N/Q1 tree (not a symlink into s7-nq1, not a fresh npm ci; receipt 01); client is S7-L1's",
     "# dependency tree: an ISOLATED copy of the verified N/Q1 tree (not a symlink into s7-nq1, not a fresh npm ci; receipt 01); client is S8-B's"),
    ('{ log "PRECONDITION_FAIL generated client != S7-L1 record"; fail 70; }', '{ log "PRECONDITION_FAIL generated client != S8-B record"; fail 70; }'),
    ("# ---- step 1 preflight (read-only): S7-L lane absent; S5 absent recorded as-is; retained C1, B, R, N/Q1 and C clusters hashed, never started",
     "# ---- step 1 preflight (read-only): S8-B lane absent; S5 absent recorded as-is; retained C1, B, R, N/Q1, C and S7-L clusters hashed, never started"),
    ("""[ ! -e "$LDIR" ] || { log "PREFLIGHT_FAIL $LDIR exists (fresh init only; never adopt)"; fail 71; }""",
     """[ ! -e "$BDIR8" ] || { log "PREFLIGHT_FAIL $BDIR8 exists (fresh init only; never adopt)"; fail 71; }"""),
    ("""(parent requires S5 ABSENT for the S7-L lane)""", """(parent requires S5 ABSENT for the S8-B lane)"""),
    ("""else C_CONF0=ABSENT; C_CTRL0=ABSENT; log "PREFLIGHT c_cluster=ABSENT"; fi
""", """else C_CONF0=ABSENT; C_CTRL0=ABSENT; log "PREFLIGHT c_cluster=ABSENT"; fi
if [ -e "$LDIR/pg-data" ]; then
  [ ! -e "$LDIR/pg-data/postmaster.pid" ] || { log "PREFLIGHT_FAIL s7-l postmaster.pid present"; fail 71; }
  L_CONF0=$(sha256sum "$LDIR/pg-data/postgresql.conf" | cut -c1-64); L_CTRL0=$(sha256sum "$LDIR/pg-data/global/pg_control" | cut -c1-64)
  log "PREFLIGHT s7l_cluster=PRESENT_STOPPED conf=$L_CONF0 pg_control=$L_CTRL0 (must be unchanged at end; never started)"
else L_CONF0=ABSENT; L_CTRL0=ABSENT; log "PREFLIGHT s7l_cluster=ABSENT"; fi
"""),
    ("""log "PREFLIGHT_OK $(ts) ldir=absent port$PORT=free""", """log "PREFLIGHT_OK $(ts) bdir8=absent port$PORT=free"""),
    ("""grep -q "^S7L_FIXTURE_INIT_OK data=$LDIR/pg-data port=$PORT superuser=$ADMIN cluster_name=s7l-disposable-pg17" "$LOG\"""",
     """grep -q "^S8B_FIXTURE_INIT_OK data=$BDIR8/pg-data port=$PORT superuser=$ADMIN cluster_name=s8b-disposable-pg17" "$LOG\""""),
    ("""grep -q "^S7L_FIXTURE_START_OK pid=" "$LOG\"""", """grep -q "^S8B_FIXTURE_START_OK pid=" "$LOG\""""),
    ("""# ---- step 4 OLD (OLD_HEAD) detached checkout OUTSIDE the candidate (derived helper committed at the S7-L1 head; git only; bound 180 s)
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
grep -q "^G2_S7L_BOOTSTRAP_OK" "$LOG" || { log "BOOTSTRAP marker missing"; fail 72; }""",
     """# ---- step 4 OLD (OLD_HEAD) detached checkout OUTSIDE the candidate (derived helper committed at the S8-B head; git only; bound 180 s)
STAGE=old-root
( cd "$W" && timeout -k 30 180 bash test/utils/g2-s8b-old-root.sh create ) >>"$LOG" 2>&1; rc=$?
log "OLD_ROOT rc=$rc $(ts) head=$(git -C "$G2_S8B_OLD_ROOT" rev-parse HEAD 2>/dev/null)"; [ $rc = 0 ] || fail $rc
grep -q "^G2_S8B_OLD_ROOT_OK" "$LOG" || { log "OLD_ROOT marker missing"; fail 72; }
[ "$(git -C "$G2_S8B_OLD_ROOT" rev-parse HEAD)" = "$OLD_HEAD" ] || { log "OLD_ROOT head is not OLD_HEAD"; fail 72; }
# ---- step 5 S8-B bootstrap (derived helper committed at the S8-B head; roles, marked DB, shim, the whole accepted history
#      through the old root's `prisma migrate deploy` — S8-B NOT applied here (the spec applies it through the candidate's
#      `prisma migrate deploy`, P01) — old client generate inside the old root, the only `prisma generate` of the run; the
#      S8-B candidate client only VERIFIED) (bound 900 s)
STAGE=bootstrap
( cd "$W" && timeout -k 30 900 bash test/utils/g2-s8b-bootstrap.sh ) >>"$LOG" 2>&1; rc=$?; log "BOOTSTRAP rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^G2_S8B_BOOTSTRAP_OK" "$LOG" || { log "BOOTSTRAP marker missing"; fail 72; }"""),
    ("""DD=$(psqlq 'SHOW data_directory'); [ "$DD" = "$G2_S7L_DATA_DIRECTORY" ]""", """DD=$(psqlq 'SHOW data_directory'); [ "$DD" = "$G2_S8B_DATA_DIRECTORY" ]"""),
    ("""[ "$CN" = s7l-disposable-pg17 ]""", """[ "$CN" = s8b-disposable-pg17 ]"""),
    ("""[ "$DM" = s7l-g2-lifecycle-synthetic-disposable-fixture-safe-to-drop ]""", """[ "$DM" = s8b-g2-provenance-synthetic-disposable-fixture-safe-to-drop ]"""),
    ("""STAGE=jest; log "JEST_START $(ts) cmd='./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s7l.spec.ts --runInBand --ci'"
( cd "$W" && timeout -k 30 1500 ./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s7l.spec.ts --runInBand --ci )""",
     """STAGE=jest; log "JEST_START $(ts) cmd='./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s8b.spec.ts --runInBand --ci'"
( cd "$W" && timeout -k 30 1500 ./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s8b.spec.ts --runInBand --ci )"""),
    ("""# ---- step 8 stop (bound 45 s + kill 30); data dir RETAINED (destroy only via separate grant: s7l-fixture.sh destroy)""",
     """# ---- step 8 stop (bound 45 s + kill 30); data dir RETAINED (destroy only via separate grant: s8b-fixture.sh destroy)"""),
    ("""[ ! -e "$LDIR/pg-data/postmaster.pid" ] && [ -d "$LDIR/pg-data" ] || { log "STOP_STATE_FAIL postgres_procs=$P listeners=$L"; fail 74; }
log "STOP_STATE_OK postgres_procs=0 port$PORT=free datadir_retained=$LDIR/pg-data\"""",
     """[ ! -e "$BDIR8/pg-data/postmaster.pid" ] && [ -d "$BDIR8/pg-data" ] || { log "STOP_STATE_FAIL postgres_procs=$P listeners=$L"; fail 74; }
log "STOP_STATE_OK postgres_procs=0 port$PORT=free datadir_retained=$BDIR8/pg-data\""""),
    ("""  log "POST c_cluster unchanged conf=$C_CONF0 pg_control=$C_CTRL0"
fi
""", """  log "POST c_cluster unchanged conf=$C_CONF0 pg_control=$C_CTRL0"
fi
if [ "$L_CONF0" != ABSENT ]; then
  [ "$(sha256sum "$LDIR/pg-data/postgresql.conf" | cut -c1-64)" = "$L_CONF0" ] && [ "$(sha256sum "$LDIR/pg-data/global/pg_control" | cut -c1-64)" = "$L_CTRL0" ] && [ ! -e "$LDIR/pg-data/postmaster.pid" ] || { log "POST_FAIL s7-l cluster changed"; fail 74; }
  log "POST s7l_cluster unchanged conf=$L_CONF0 pg_control=$L_CTRL0"
fi
"""),
    ("""( cd "$R" && sha256sum s7l-pg-proof.log jest.log > RECEIPTS.sha256 )""", """( cd "$R" && sha256sum s8b-pg-proof.log jest.log > RECEIPTS.sha256 )"""),
]
for old, new in pairs:
    s = sub(s, old, new)
# Residual identity tokens: none of the S7-L lane identity may survive in executable lines except the retained-cluster
# hashing of $LDIR (clusters/s7-l), which is read-only and identical in kind to the C1/B/R/N/Q1/C retained lanes.
body = '\n'.join(l for l in s[len(hdr_new):].split('\n') if not l.lstrip().startswith('#'))
for token in ('G2_S7L_', 's7l_super', '55501', 'g2_s7l_disposable', 's7l-disposable-pg17', 'S7L_RUNNER_PID', 'S7L_STOP_TIMEOUT',
              'S7L_FIXTURE_', 'g2-s7l-', 'rls-g2-s7l', 's7l-fixture.sh', 's7l-pg-proof', 'lifecycle', 'src/scout/lifecycle'):
    assert token not in body, f'residual S7-L token in runner body: {token}'
assert body.count('clusters/s7-l') == 1, 'clusters/s7-l must appear exactly once (retained-lane LDIR definition)'
open(OUT + 's8b-pg-proof.sh', 'w').write(s)
print('derived s8b-fixture.sh and s8b-pg-proof.sh')
