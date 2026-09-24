import re
src=open('execution/95633079/s7-b-drain/runtime-v5/binding/b-pg-proof.sh').read()
s=src
subs=[
("execution/95633079/s7-b-drain/fixture-proposal-v3/binding","execution/cf8ff737/r-ready/binding"),
("execution/95633079/s7-b-drain/runtime-v5       # v5 proof: separate receipt/old-root root (first proof runtime/ preserved)","execution/cf8ff737/r-ready/runtime                # R proof: its own receipt/old-root root"),
("W=/home/user/workspace/worktrees/s7-b-drain","W=/home/user/workspace/worktrees/s7-r-ready"),
("b-pg-proof","r-pg-proof"),
("b-fixture.sh","r-fixture.sh"),
("test/rls-g2-b-drain.spec.ts","test/rls-g2-r-ready.spec.ts"),
("test/utils/g2-b-drain-bootstrap.sh","test/utils/g2-r-ready-bootstrap.sh"),
("test/scout/g2-b-drain-db-guard.spec.ts","test/scout/g2-r-ready-db-guard.spec.ts"),
("G2_B_","G2_R_"),
("B_RUNNER_PID","R_RUNNER_PID"),("B_STOP_TIMEOUT","R_STOP_TIMEOUT"),("B_FIXTURE_","R_FIXTURE_"),
("b-disposable-pg17","r-disposable-pg17"),
("b-g2-drain-synthetic-disposable-fixture-safe-to-drop","r-g2-ready-synthetic-disposable-fixture-safe-to-drop"),
("PORT=55461; DBNAME=g2_b_drain_disposable; ADMIN=b_super; FIXPASS=b_local_synthetic","PORT=55471; DBNAME=g2_r_ready_disposable; ADMIN=r_super; FIXPASS=r_local_synthetic"),
("S5DIR=$PG17_HOME/clusters/s5; C1DIR=$PG17_HOME/clusters/c1-builder; BDIR=$PG17_HOME/clusters/b-drain","S5DIR=$PG17_HOME/clusters/s5; C1DIR=$PG17_HOME/clusters/c1-builder; BDIR=$PG17_HOME/clusters/b-drain; RDIR=$PG17_HOME/clusters/r-ready"),
(".g2-b-old-client",".g2-r-old-client"),
("EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44      # C1 node_modules/.package-lock.json",
 "EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44      # node_modules/.package-lock.json (C1 record, unchanged through B and R; receipt 02)"),
("EXPECT_NM_CLIENT_SHA=bf679a16e50a6f0c39528887b80c2a03c5d0825b816cec3417fcbc94300b72d5    # C1 node_modules/.prisma/client/index.d.ts",
 "EXPECT_NM_CLIENT_SHA=7c3674547228cd1cf335bd0e0697c83451f411e28e1ce64e94a719d0a5382f71    # R node_modules/.prisma/client/index.d.ts (receipt 03; R-only generate)"),
("# dependency tree: an ISOLATED copy of the accepted C1 tree (not a symlink into s7-c1, not a fresh npm ci)",
 "# dependency tree: an ISOLATED copy of the accepted B tree (not a symlink into s7-b-drain, not a fresh npm ci); client is R's"),
('generated client != C1 record','generated client != R record'),
('.package-lock.json != C1 record','.package-lock.json != C1/B record'),
('# ---- step 1 preflight (read-only): B lane absent; S5 absent recorded as-is; retained C1 cluster hashed, never started',
 '# ---- step 1 preflight (read-only): R lane absent; S5 absent recorded as-is; retained C1 and B clusters hashed, never started'),
('[ ! -e "$BDIR" ] || { log "PREFLIGHT_FAIL $BDIR exists (fresh init only; never adopt)"; fail 71; }',
 '[ ! -e "$RDIR" ] || { log "PREFLIGHT_FAIL $RDIR exists (fresh init only; never adopt)"; fail 71; }'),
('(parent requires S5 ABSENT for the B lane)','(parent requires S5 ABSENT for the R lane)'),
('log "PREFLIGHT_OK $(ts) bdir=absent port$PORT=free','log "PREFLIGHT_OK $(ts) rdir=absent port$PORT=free'),
('grep -q "^R_FIXTURE_INIT_OK data=$BDIR/pg-data','grep -q "^R_FIXTURE_INIT_OK data=$RDIR/pg-data'),
('[ ! -e "$BDIR/pg-data/postmaster.pid" ] && [ -d "$BDIR/pg-data" ] || { log "STOP_STATE_FAIL','[ ! -e "$RDIR/pg-data/postmaster.pid" ] && [ -d "$RDIR/pg-data" ] || { log "STOP_STATE_FAIL'),
('datadir_retained=$BDIR/pg-data','datadir_retained=$RDIR/pg-data'),
('# ---- step 5 B bootstrap (derived helper committed at v3;','# ---- step 5 R bootstrap (derived helper committed at the R head;'),
('the only `prisma generate` of the lane; candidate client only VERIFIED)','the only `prisma generate` of the run; the R candidate client only VERIFIED)'),
('# B-only identity: exactly the G2_R_* names','# R-only identity: exactly the G2_R_* names'),
# closure 1 (review A B-2/B-3, review B B-1): the R data directory is the R lane, and hooks are
# resolved through git (linked worktree: .git is a file; hooks live in the common dir).
('G2_R_DATA_DIRECTORY=$BDIR/pg-data','G2_R_DATA_DIRECTORY=$RDIR/pg-data'),
('grep -q lefthook "$W/.git/hooks/pre-commit" 2>/dev/null && grep -q lefthook "$W/.git/hooks/commit-msg" 2>/dev/null \\\n  || { log "PRECONDITION_FAIL .git/hooks/pre-commit or commit-msg absent or not lefthook (hookless commit)"; fail 70; }',
 'H=$(git -C "$W" rev-parse --git-path hooks); case "$H" in /*) ;; *) H="$W/$H";; esac\ngrep -q lefthook "$H/pre-commit" 2>/dev/null && grep -q lefthook "$H/commit-msg" 2>/dev/null \\\n  || { log "PRECONDITION_FAIL $H/pre-commit or commit-msg absent or not lefthook (hookless commit)"; fail 70; }'),
]
for a,b in subs:
    assert a in s, a
    s=s.replace(a,b)
s=re.sub(r"EXPECT_HEAD=\S+", "EXPECT_HEAD=__FILL_AFTER_COMMIT__", s)
s=re.sub(r"EXPECT_TREE=\S+", "EXPECT_TREE=__FILL_AFTER_COMMIT__", s)
s=re.sub(r"EXPECT_SPEC_BLOB=\S+\s+# test/rls-g2-r-ready.spec.ts at v3", "EXPECT_SPEC_BLOB=__FILL_AFTER_COMMIT__                 # test/rls-g2-r-ready.spec.ts at the R head", s)
s=re.sub(r"EXPECT_BOOTSTRAP_BLOB=\S+\s+# test/utils/g2-r-ready-bootstrap.sh at v3", "EXPECT_BOOTSTRAP_BLOB=__FILL_AFTER_COMMIT__       # test/utils/g2-r-ready-bootstrap.sh at the R head", s)
s=re.sub(r"EXPECT_FIXTURE_SHA=\S+\s+# binding/r-fixture.sh", "EXPECT_FIXTURE_SHA=__FILL_AFTER_COMMIT__           # binding/r-fixture.sh", s)
assert s.count("__FILL_AFTER_COMMIT__")==5
head_old=s[:s.index("set -uo pipefail")]
head_new="""#!/usr/bin/env bash
# S7-3' R/ready real-PG proof — minimal execution binding (SOURCE ONLY; NOT RUN; NOT GRANTED; pins unfilled).
# Derived by substitution from the accepted B v5 binding execution/95633079/s7-b-drain/runtime-v5/binding/b-pg-proof.sh
# (sha256 e895b16e…): R identity (port 55471, r_super, g2_r_ready_disposable, cluster r-ready), the R spec/bootstrap,
# the R generated-client pin, and two added read-only checks: the accepted B files are byte-identical at the R head and
# the retained stopped B cluster is hashed and never started. Runs the NEW spec test/rls-g2-r-ready.spec.ts exactly once
# via the existing repo jest + jest.rls.config.js. No new test framework, no retry, no inherited-proof replay (etq0 /
# fresh51 / C1 / B suites are never invoked). Single canonical lock holder; first nonzero stops; the only cleanup
# attempted is a bounded fixture stop when this run started the postmaster. No autonomous cleanup is GUARANTEED: if the
# outer timeout kills bash, the stop does not run. What governs is the observed terminal evidence — the sentinel/log
# lines, `pgrep -cx postgres`, the port listener count and any survivor pid the stop reports — not this header. Data dir
# RETAINED after stop (destroy = separate marker-gated grant).
# Inner stage bounds: init 60 + start 60 + old-root 180 + bootstrap 900 + identity 4x15 + jest 1500 + stop 75 = 2835 s soft sum.
# Usage (later, under the single-run grant): timeout -k 30 3600 bash .../binding/r-pg-proof.sh
# Pre-steps (each its own receipt, in this order, BEFORE pins are filled): isolated copy of the accepted B node_modules +
# verify (receipt 02) → R-only prisma generate (receipt 03) → affected gates (tsc, eslint, prettier --check, check-r75,
# DB-free jest incl. test/scout/g2-r-ready-db-guard.spec.ts) → ordinary Bradley-authored hooked commit → fill EXPECT_*
# from the committed head → separate PG grant for this script.
"""
s=head_new+s[len(head_old):]
anchor='''  [ "$(git -C "$W" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL accepted S5 file $1 changed"; fail 70; }; done
'''
assert anchor in s
s=s.replace(anchor, anchor+'''# accepted B files must be byte-identical at the committed head (machine check of "B files unchanged"; B head 0d69c7ba)
for pin in "test/utils/g2-b-drain-db.ts cb60f3f47a18d11dd31b970ee49bcf1ed4ff2db3" "test/utils/g2-b-drain-pg-harness.ts c22a72c4ebed9710cbb66de5581441a1508ad730" \\
           "test/utils/g2-b-drain-harness.ts 469cbd2a76a7e56ca65eff5aa4a734c120e5c2a9" "test/utils/g2-b-drain-bootstrap.sh b4503eef525baa531eedb148f47828db3a4ade6f" \\
           "test/scout/g2-b-drain-db-guard.spec.ts 4e1ed6ff932be9681fc943e122d0806eb095afb2" "test/rls-g2-b-drain.spec.ts 9b31fd1813d25a1624ab04666e0b1be4743277ab"; do set -- $pin
  [ "$(git -C "$W" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL accepted B file $1 changed"; fail 70; }; done
git -C "$W" merge-base --is-ancestor 0d69c7ba7e7d257311cfcb21fa325ebb1ddc1f1c HEAD || { log "PRECONDITION_FAIL accepted B head 0d69c7ba not an ancestor"; fail 70; }
''')
c1block='''else C1_CONF0=ABSENT; C1_CTRL0=ABSENT; log "PREFLIGHT c1_cluster=ABSENT"; fi
'''
assert c1block in s
s=s.replace(c1block, c1block+'''if [ -e "$BDIR/pg-data" ]; then
  [ ! -e "$BDIR/pg-data/postmaster.pid" ] || { log "PREFLIGHT_FAIL b-drain postmaster.pid present"; fail 71; }
  B_CONF0=$(sha256sum "$BDIR/pg-data/postgresql.conf" | cut -c1-64); B_CTRL0=$(sha256sum "$BDIR/pg-data/global/pg_control" | cut -c1-64)
  log "PREFLIGHT b_cluster=PRESENT_STOPPED conf=$B_CONF0 pg_control=$B_CTRL0 (must be unchanged at end; never started)"
else B_CONF0=ABSENT; B_CTRL0=ABSENT; log "PREFLIGHT b_cluster=ABSENT"; fi
''')
postc1='''  log "POST c1_cluster unchanged conf=$C1_CONF0 pg_control=$C1_CTRL0"
fi
'''
assert postc1 in s
s=s.replace(postc1, postc1+'''if [ "$B_CONF0" != ABSENT ]; then
  [ "$(sha256sum "$BDIR/pg-data/postgresql.conf" | cut -c1-64)" = "$B_CONF0" ] && [ "$(sha256sum "$BDIR/pg-data/global/pg_control" | cut -c1-64)" = "$B_CTRL0" ] && [ ! -e "$BDIR/pg-data/postmaster.pid" ] || { log "POST_FAIL b-drain cluster changed"; fail 74; }
  log "POST b_cluster unchanged conf=$B_CONF0 pg_control=$B_CTRL0"
fi
''')
open('execution/cf8ff737/r-ready/binding/r-pg-proof.sh','w').write(s)
print("written")
