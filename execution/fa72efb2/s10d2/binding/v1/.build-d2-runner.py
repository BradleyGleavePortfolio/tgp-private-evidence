# Builder helper (kept for audit): derives d2-pg-proof.sh from the accepted s10c v6 runner by exact, asserted substitutions.
import sys
T = '/home/user/workspace/repos/tgp-private-evidence/execution/d3a9f701/s10c/binding/v6/s10c-pg-proof.sh'
O = '/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s10d2/binding/v1/d2-pg-proof.sh'
s = open(T).read()
L = s.split('\n')

# ---- 1. pre-lock git reads move from the (not yet existing) fresh clone W to the clone source SRC.
start = next(i for i, l in enumerate(L) if l.startswith('[ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] || { log "PRECONDITION_FAIL HEAD != $EXPECT_HEAD"'))
end = next(i for i, l in enumerate(L) if l.startswith('PRV=$(cd "$W" && ./node_modules/.bin/prisma --version'))
for i in range(start, end):
    L[i] = L[i].replace('git -C "$W"', 'git -C "$SRC"')
s = '\n'.join(L)

def rep(old, new, n=1):
    global s
    c = s.count(old)
    if c != n:
        sys.exit(f'COUNT {c} != {n} for: {old[:120]!r}')
    s = s.replace(old, new)

# ---- 2. header
h0 = s.index('# S10-C real-PG proof'); h1 = s.index('set -uo pipefail')
rep(s[h0:h1], '''# S10-D D2 real-PG proof — execution binding v1 (EXEC-FA72EFB2). SOURCE ONLY: NOT RUN, NOT GRANTED.
# Derived by MINIMUM substitution from the accepted S10-C binding execution/d3a9f701/s10c/binding/v6/s10c-pg-proof.sh
# (sha256 1bb4b564…483d; ran rc 0, 32/32 on the S10-B harness). Full diff in DELTA-from-s10c-v6.diff; README.md lists every delta.
# D2 deltas (everything else carried unchanged):
#   * fa72efb2 runtime (pg17 dist + PROVENANCE, npm/xdg caches), lock inode 686480, tool/node/psql/nm pins from
#     execution/fa72efb2/runtime/raw/rt-setup.log; donor node_modules = worktrees/fa72-s11a1/node_modules (generated from the
#     same S10-B schema d6d01f54), so the "clone client differs from donor" guard is INVERTED: clone client == donor client
#   * candidate = ONE D2 gate commit on BASE 6a33df9b (branch fa72/d2 in SRC=worktrees/fa72-d2); pre-lock git checks read SRC;
#     under the lock the runner makes the FRESH clone W=worktrees/fa72-d2-pg1 (shared objects, no hooks, detached at the
#     head) and a real `cp -a` copy of the donor node_modules into it (no npm, no prisma generate); W must not pre-exist
#   * BASE..HEAD = exactly the 8 D2 paths; contract unchanged (blob bd715150 at BASE and HEAD); no prisma change
#     (migrations tree 7b6fe0ed, 173); FROZEN S10-A/S10-B bytes at HEAD except the one premise edit 7746a877 made to
#     test/scout/induction/manifest-registry.spec.ts (pinned to its BASE blob)
#   * lane clusters/s10d2 + run/s10d2 on 55649, REUSING the S10-B harness literals; refused lane ports 55646/55647 plus 55648
#     (the S11 lane binding in this runtime); no retained s10-b lane exists in this runtime, so its must-exist requirement is
#     dropped (if one appears it is fingerprinted, must be stopped and unchanged, and is never the lane)
#   * runs ONLY `jest -c jest.config.js --runInBand --ci --runTestsByPath test/scout/s10/s10-unseen.pg.spec.ts` once;
#     it() count pinned at HEAD (8); the only skip form allowed is the file-level env switch in its pinned live form
#   * LAND_REF refs/remotes/origin/land/s10d2 is a fill: `none` (no land ref pushed; not checked) or the pushed 40-hex head
# Carried unchanged: single canonical lock holder (nonblocking flock fd 9 before any state change, held through stop, post
# checks and receipt hashing; lock file never deleted); ALL pin/shape preconditions before the lock and the sentinel
# (prelock.log, PRELOCK_REFUSED does not consume the run); symlink-aware sentinel; under-lock rechecks; first nonzero
# stops; the only cleanup is a bounded fixture stop when this run started the postmaster; data dir RETAINED after stop.
# Pipefail rule (S9C-PROOF-1): never `cmd | grep -q`; producer output is captured first, then grepped as a here-string.
# Inner stage bounds: clone 120+120 + cp 600 + init 60 + start 60 + bootstrap 900 + identity 8x15 + jest 1500 + stop 75
#   = 3555 s soft sum.
# Usage (under the separate single-run PG grant, after the D2 gate commit and fill):
#   timeout -k 30 4500 bash /home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s10d2/binding/v1/d2-pg-proof.sh
# Fill (parent, README.md fill table): every __FILL_*__ below from the D2 gate summary execution/fa72efb2/s10d2/d2_gate_summary.md.
# Placeholders are refused pre-lock (rc 70, run not consumed).
''')

# ---- 3. paths
rep('D=/home/user/workspace/tgp-private-evidence/execution/d3a9f701/s10c/binding/v6   # v6: v5 RC=74 operator lane move during the run (PROOF_V5_FINDING.md); v4 parser; v3 preflight; v2 unrun',
    'D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s10d2/binding/v1   # D2 binding v1 (from s10c v6)')
rep('RUNTIME_ROOT=/home/user/workspace/execution/1910a060/runtime                     # 1910a060 runtime namespace (execution/1910a060/runtime/RUNTIME_SETUP_RECEIPT.md); the fixture carries the same literal and is cross-checked below',
    'RUNTIME_ROOT=/home/user/workspace/execution/fa72efb2/runtime                     # fa72efb2 runtime namespace (evidence execution/fa72efb2/runtime/raw/rt-setup.log); the fixture carries the same literal and is cross-checked below')
rep('W=/home/user/workspace/worktrees/d3a9-s10c\n',
    'SRC=/home/user/workspace/worktrees/fa72-d2                                        # clone source (read-only here): branch fa72/d2 at the D2 gate commit, clean, lefthook hooks\n'
    'W=/home/user/workspace/worktrees/fa72-d2-pg1                                     # the fresh clone this run creates under the lock (must not exist)\n')
rep('DONOR_NM=/home/user/workspace/worktrees/1910a060-s8f/node_modules                 # read-only: must still hold the pre-S10-B client (the gate generated in the clone copy only)',
    'DONOR_NM=/home/user/workspace/worktrees/fa72-s11a1/node_modules                  # read-only donor (npm ci + prisma generate by rt-setup-fa72efb2.sh from the S10-B schema); copied, never regenerated')
rep('R=$D/run; LOG=$R/s10c-pg-proof.log; SENT=$R/s10c-pg-proof.sentinel; JLOG=$R/jest.log',
    'R=$D/run; LOG=$R/d2-pg-proof.log; SENT=$R/d2-pg-proof.sentinel; JLOG=$R/jest.log')

# ---- 4. pins
rep('# ---- pins: head pins are filled by the parent AFTER the S10-C gate commit; placeholders are refused.',
    '# ---- pins: head / tree / D2 blob / hook / land-ref pins are filled by the parent AFTER the D2 gate commit; placeholders are refused.')
rep('BASE_HEAD=711c1f8f8b42157bca97f2a721557be7ef006667                                                   # integration/importer tip the gate committed on (= S10-C gate PINS.env BASE)',
    'BASE_HEAD=6a33df9b2ea1fd246663a2287b92830f0d093abe                                                   # integration/importer tip the D2 gate commits on (C2 landed; reconcile/C2_LANDED_6a33df9b.md)')
rep('BASE_TREE=abc927e47f9e0bb11afa575a4f4c550c1a56c067                                                   # git rev-parse "$BASE_HEAD^{tree}"',
    'BASE_TREE=454fd501b9353bac11a083036aa5340da354e37c                                                   # git rev-parse "$BASE_HEAD^{tree}"')
rep('EXPECT_HEAD=2ec74c56b76d20489188ed1519fdeb2bbe394f44                                               # gate receipt head=',
    'EXPECT_HEAD=__FILL_EXPECT_HEAD__                                               # D2 gate summary head= (the one commit on fa72/d2)')
rep('EXPECT_TREE=98b705e1a5f4bc7351509b8e80801fd279dcee39                                               # gate receipt tree=',
    'EXPECT_TREE=__FILL_EXPECT_TREE__                                               # D2 gate summary tree=')
i0 = s.index('EXPECT_DELTA="src/scout/induction/observation.module.ts'); i1 = s.index('\n', i0)
rep(s[i0:i1], 'EXPECT_DELTA="src/scout/induction/sources/s10_unseen.json src/scout/reconstruct/native/sources/s10_unseen.json src/scout/reconstruct/sources/s10_unseen.json test/fixtures/scout/s10_unseen/signer-test-key.json test/fixtures/scout/s10_unseen/staged-rows.json test/fixtures/scout/s10_unseen/statements.json test/scout/s10/s10-unseen.e2e.spec.ts test/scout/s10/s10-unseen.pg.spec.ts"   # exactly the 8 D2 paths (sorted); must equal D2_OWNED and the gate R40 `git diff --name-only`')
rep('EXPECT_CONTRACT_STATE=unchanged                                  # gate receipt contract_state= (changed|unchanged)',
    'EXPECT_CONTRACT_STATE=unchanged                                  # D2 changes no contract (the 8 paths exclude docs/); kept as the template mechanism')
rep('EXPECT_CONTRACT_BLOB=752f9dbe1a6bdee0c20504a35dce60757880d427                                    # gate receipt contract_state ... blob= (= 752f9dbe1a6bdee0c20504a35dce60757880d427 iff unchanged)',
    'EXPECT_CONTRACT_BLOB=bd715150cb9c4d842383f1acccd53ec13fabe95f                                    # = BASE_CONTRACT_BLOB (unchanged)')
rep('EXPECT_HOOK_PRECOMMIT_SHA=e32f6e028411344acdff9ee787decef9ee49fa4414d0deb9aa8e613f30bede06                          # gate receipt "hooks raw pre-commit=<sha256>" (.git/hooks/pre-commit the gate committed through)',
    'EXPECT_HOOK_PRECOMMIT_SHA=__FILL_HOOK_PRECOMMIT_SHA__                          # D2 gate summary: sha256 of $SRC/.git/hooks/pre-commit the gate committed through (observed pre-gate 54aa5cd8…3f9)')
rep('EXPECT_HOOK_COMMITMSG_SHA=efb54d65efd525381d95fe70eef76fa6c2eb03ae3829808e69edb8fe622a2f19                          # gate receipt "hooks raw ... commit-msg=<sha256>"',
    'EXPECT_HOOK_COMMITMSG_SHA=__FILL_HOOK_COMMITMSG_SHA__                          # D2 gate summary: sha256 of $SRC/.git/hooks/commit-msg (observed pre-gate dc998a5e…be0)')
rep('EXPECT_S10C_SPEC_BLOB=50a0deae0e9eee45ec093e87769949f47efd3d8e                                  # gate receipt "blob test/rls-g2-s10c.spec.ts <blob>"',
    'EXPECT_S10C_SPEC_BLOB=50a0deae0e9eee45ec093e87769949f47efd3d8e                                  # landed S10-C spec (BASE blob; not run here, pinned unchanged)\n'
    '# the 8 D2 path blobs at HEAD (D2 gate summary "sha256 per path post-format" + `git rev-parse HEAD:<path>`)\n'
    'EXPECT_D2_BLOB_INDUCTION=__FILL_BLOB_INDUCTION__          # src/scout/induction/sources/s10_unseen.json\n'
    'EXPECT_D2_BLOB_NATIVE=__FILL_BLOB_NATIVE__                # src/scout/reconstruct/native/sources/s10_unseen.json\n'
    'EXPECT_D2_BLOB_MAPPING=__FILL_BLOB_MAPPING__              # src/scout/reconstruct/sources/s10_unseen.json\n'
    'EXPECT_D2_BLOB_KEY=__FILL_BLOB_KEY__                      # test/fixtures/scout/s10_unseen/signer-test-key.json\n'
    'EXPECT_D2_BLOB_ROWS=__FILL_BLOB_ROWS__                    # test/fixtures/scout/s10_unseen/staged-rows.json\n'
    'EXPECT_D2_BLOB_STATEMENTS=__FILL_BLOB_STATEMENTS__        # test/fixtures/scout/s10_unseen/statements.json\n'
    'EXPECT_D2_BLOB_E2E=__FILL_BLOB_E2E__                      # test/scout/s10/s10-unseen.e2e.spec.ts\n'
    'EXPECT_D2_BLOB_PG=__FILL_BLOB_PG__                        # test/scout/s10/s10-unseen.pg.spec.ts (the spec this run executes)\n'
    'LAND_REF=refs/remotes/origin/land/s10d2                   # only if the parent pushes a land ref (seen in SRC as refs/remotes/origin/land/s10d2)\n'
    'EXPECT_LAND_REF=__FILL_LAND_REF__                        # `none` (no land ref pushed: not checked) or the 40-hex the land ref must equal (= EXPECT_HEAD)')
rep('EXPECT_MIGRATIONS_TREE=7b6fe0eda137ab1e3013b8a7c3b0c7637f69a521                # S10-B migrations tree (173); S10-C changes no prisma, so BASE and HEAD both carry it',
    'EXPECT_MIGRATIONS_TREE=7b6fe0eda137ab1e3013b8a7c3b0c7637f69a521                # S10-B migrations tree (173); D2 changes no prisma, so BASE and HEAD both carry it')
rep('BASE_CONTRACT_BLOB=752f9dbe1a6bdee0c20504a35dce60757880d427                    # importer contract blob at a2c74e90 (the gate refuses a BASE that differs)',
    'BASE_CONTRACT_BLOB=bd715150cb9c4d842383f1acccd53ec13fabe95f                    # importer contract blob at BASE 6a33df9b (C2 published the S10-B routes)')
rep('# landed S10-B proof files (s10b/gate/HEAD-a2c74e904ff2.txt); frozen through S10-C (also covered by FROZEN below)',
    '# landed S10-B proof files (s10b/gate/HEAD-a2c74e904ff2.txt); frozen through S10-C and D2 (verified equal at BASE 6a33df9b; also covered by FROZEN below)')
rep('EXPECT_FIXTURE_SHA=c1b57239c40df1353fc98561816353dcdfd8720a318436637f1315b1cb1992e7                                             # sha256 of binding/v1/s10c-fixture.sh (frozen with this file; BINDING.sha256)',
    'EXPECT_FIXTURE_SHA=__D2_FIXTURE_SHA__                                             # sha256 of binding/v1/d2-fixture.sh (builder-filled; README.md)')
rep('FROZEN=/home/user/workspace/tgp-private-evidence/execution/d3a9f701/s10c/gate/FROZEN.sha256',
    'FROZEN=/home/user/workspace/repos/tgp-private-evidence/execution/d3a9f701/s10c/gate/FROZEN.sha256\n'
    'FROZEN_P_PATH=test/scout/induction/manifest-registry.spec.ts   # the ONE FROZEN path the landed premise P (7746a877) re-stated; ancestor of BASE\n'
    'FROZEN_P_BLOB=9b5de3743ec27181b58e8277591a6c8c1a8adc65          # its blob at BASE 6a33df9b (must also be its blob at HEAD: D2 does not touch it)')
i0 = s.index('# the 12 S10-C owned paths'); i1 = s.index('\n', s.index('S10C_OWNED="', i0))
rep(s[i0:i1], '# the 8 D2 paths (execution/d3a9f701/s10d/d2.diff: 8 new 100644 files; D2_GATE_GRANT.md); EXPECT_DELTA must be exactly these\n'
    'D2_OWNED="src/scout/induction/sources/s10_unseen.json src/scout/reconstruct/native/sources/s10_unseen.json src/scout/reconstruct/sources/s10_unseen.json test/fixtures/scout/s10_unseen/signer-test-key.json test/fixtures/scout/s10_unseen/staged-rows.json test/fixtures/scout/s10_unseen/statements.json test/scout/s10/s10-unseen.e2e.spec.ts test/scout/s10/s10-unseen.pg.spec.ts"\n'
    'D2_SPEC=test/scout/s10/s10-unseen.pg.spec.ts')
rep('# ---- tool pins: from the 1910a060 runtime setup receipt (compare only, never adjusted at run time); identical to S10-B v1.',
    '# ---- tool pins: from the fa72efb2 runtime setup log raw/rt-setup.log (compare only, never adjusted at run time); byte-identical to the S10-C v6 pins.')
rep('EXPECT_TESTS_S10B=24                                # it() count in the frozen test/rls-g2-s10b.spec.ts (re-checked at HEAD)',
    'EXPECT_TESTS_S10B=24                                # it() count in the frozen test/rls-g2-s10b.spec.ts (re-checked at HEAD; NOT run here)')
rep('EXPECT_TESTS_S10C=8                                 # it() count in test/rls-g2-s10c.spec.ts (fix-1 bytes 5eeb0fe6; parent 22:34: 24 + 8; re-checked at HEAD; the gate enforced EXPECT_IT_S10C=8)',
    'EXPECT_TESTS_S10C=8                                 # it() count in the landed test/rls-g2-s10c.spec.ts (re-checked at HEAD; NOT run here)\n'
    'EXPECT_TESTS_D2=8                                   # it() count in test/scout/s10/s10-unseen.pg.spec.ts (R39 a-f, R41, R27 live; builder count on the pre-gate bytes 074b0fa0; re-checked at HEAD)')
rep('EXPECT_TESTS=$((EXPECT_TESTS_S10B + EXPECT_TESTS_S10C))   # 32: the one jest run must print "Tests: 32 passed, 32 total"',
    'EXPECT_TESTS=$EXPECT_TESTS_D2                       # 8: the one jest run must print "Tests: 8 passed, 8 total"')
rep('EXPECT_LOCK_INODE=692282                            # execution/d3a9f701/runtime/LOCK_ESTABLISHED.txt (inode=692282)',
    'EXPECT_LOCK_INODE=686480                            # fa72efb2 canonical lock (WORKER_RULES 3; rt-setup.log START "lock inode=686480")')
rep('EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44    # node_modules/.package-lock.json (donor copy; package-lock unchanged since 93389265)',
    'EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44    # node_modules/.package-lock.json (rt-setup NM_OK hidden_lock=; donor and copy)')
rep('EXPECT_NM_CLIENT_SHA=2c819c8a8e2fd4afb59578893122b8e9c406bc1dc7821e643e7ef359c04aa56c         # $W/node_modules/.prisma/client/index.d.ts as regenerated by the S10-C gate (receipt postgen_client index_dts=; same schema as S10-B, so expected 2c819c8a…a56c)',
    'EXPECT_NM_CLIENT_SHA=2c819c8a8e2fd4afb59578893122b8e9c406bc1dc7821e643e7ef359c04aa56c         # $W/node_modules/.prisma/client/index.d.ts = the copied donor client (rt-setup NM_OK client_index_dts=)')
rep('EXPECT_NM_CLIENT_SCHEMA_SHA=aca7a558cd379c154e947447782f2858a9f898039298e34c30b886947aed42e5   # $W/node_modules/.prisma/client/schema.prisma (receipt postgen_client schema=; expected aca7a558…42e5)',
    'EXPECT_NM_CLIENT_SCHEMA_SHA=aca7a558cd379c154e947447782f2858a9f898039298e34c30b886947aed42e5   # $W/node_modules/.prisma/client/schema.prisma (rt-setup NM_OK client_schema=)')
rep('DONOR_CLIENT_SHA=9042e713ba5678c99959a345b7b18a60dfc186b2c7d890b8d9c3ed5c8f4edcc6      # pre-S10-B client (BASE schema 0eb41f9a); EXPECT_NM_CLIENT_SHA must differ from it',
    'DONOR_CLIENT_SHA=2c819c8a8e2fd4afb59578893122b8e9c406bc1dc7821e643e7ef359c04aa56c      # donor client, generated from the S10-B schema d6d01f54; INVERTED guard: EXPECT_NM_CLIENT_SHA must EQUAL it\n'
    'DONOR_CLIENT_SCHEMA_SHA=aca7a558cd379c154e947447782f2858a9f898039298e34c30b886947aed42e5\n'
    'EXPECT_PRISMA_CLI=6.19.3                            # rt-setup NM_OK prisma=')
rep('EXPECT_SCHEMA_SHA=d6d01f546f6c7988d93bdd60588e421bf6ff0a56b312f85eee962e0a6be0eb96   # prisma/schema.prisma (S10-B bytes; S10-C changes no prisma) (never reflowed)',
    'EXPECT_SCHEMA_SHA=d6d01f546f6c7988d93bdd60588e421bf6ff0a56b312f85eee962e0a6be0eb96   # prisma/schema.prisma (S10-B bytes; D2 changes no prisma) (never reflowed)')
rep('DIST=$RUNTIME_ROOT/pg17/dist; CLUSTERS=$RUNTIME_ROOT/clusters; LANE=$CLUSTERS/s10-c; SOCK=$RUNTIME_ROOT/run/s10-c',
    'DIST=$RUNTIME_ROOT/pg17/dist; CLUSTERS=$RUNTIME_ROOT/clusters; LANE=$CLUSTERS/s10d2; SOCK=$RUNTIME_ROOT/run/s10d2')
rep('S10B_LANE=$CLUSTERS/s10-b                          # RETAINED S10-B lane: must exist, stay stopped and unchanged; never started, never destroyed here',
    'S10B_LANE=$CLUSTERS/s10-b                          # never the lane; absent in this runtime; if present it must stay stopped and unchanged (never started, never destroyed here)')
rep('REFUSED_LANE_PORTS="55646 55647"                    # S9-C / S10-B lane ports: never this lane, zero listeners before and after',
    'REFUSED_LANE_PORTS="55646 55647 55648"              # S9-C / S10-B / S11 (fa72efb2 s11a1 binding) lane ports: never this lane, zero listeners before and after')
rep('FIX=$D/s10c-fixture.sh', 'FIX=$D/d2-fixture.sh')
rep('# S10-B-harness identity (reused by the S10-C spec)', '# S10-B-harness identity (reused by the D2 spec)')
rep('export S10C_RUNNER_PID=$$ S10C_STOP_TIMEOUT=45', 'export D2_RUNNER_PID=$$ D2_STOP_TIMEOUT=45')

# ---- 5. pre-lock checks
rep('case "$BASE_HEAD$BASE_TREE$EXPECT_HEAD$EXPECT_TREE$EXPECT_DELTA$EXPECT_CONTRACT_STATE$EXPECT_CONTRACT_BLOB$EXPECT_S10C_SPEC_BLOB$EXPECT_HOOK_PRECOMMIT_SHA$EXPECT_HOOK_COMMITMSG_SHA$EXPECT_FIXTURE_SHA$FROZEN_SHA$EXPECT_NM_CLIENT_SHA$EXPECT_NM_CLIENT_SCHEMA_SHA$PORT$RUNTIME_ROOT$EXPECT_POSTGRES_SHA$EXPECT_INITDB_SHA$EXPECT_PGCTL_SHA$EXPECT_PSQL_REAL_SHA$EXPECT_NODE_SHA$EXPECT_NM_LOCK_SHA" in *__*) log "PRECONDITION_FAIL pins not filled (proposal stage: base, head, delta, contract, spec blob or client; README.md)"; fail 70;; esac',
    'D2_BLOBS="$EXPECT_D2_BLOB_INDUCTION$EXPECT_D2_BLOB_NATIVE$EXPECT_D2_BLOB_MAPPING$EXPECT_D2_BLOB_KEY$EXPECT_D2_BLOB_ROWS$EXPECT_D2_BLOB_STATEMENTS$EXPECT_D2_BLOB_E2E$EXPECT_D2_BLOB_PG"\n'
    'case "$BASE_HEAD$BASE_TREE$EXPECT_HEAD$EXPECT_TREE$EXPECT_DELTA$EXPECT_CONTRACT_STATE$EXPECT_CONTRACT_BLOB$EXPECT_S10C_SPEC_BLOB$EXPECT_HOOK_PRECOMMIT_SHA$EXPECT_HOOK_COMMITMSG_SHA$EXPECT_FIXTURE_SHA$FROZEN_SHA$EXPECT_NM_CLIENT_SHA$EXPECT_NM_CLIENT_SCHEMA_SHA$PORT$RUNTIME_ROOT$EXPECT_POSTGRES_SHA$EXPECT_INITDB_SHA$EXPECT_PGCTL_SHA$EXPECT_PSQL_REAL_SHA$EXPECT_NODE_SHA$EXPECT_NM_LOCK_SHA$D2_BLOBS$EXPECT_LAND_REF" in *__*) log "PRECONDITION_FAIL pins not filled (proposal stage: head, tree, D2 blobs, hooks or land ref; README.md fill table)"; fail 70;; esac')
rep('for v in BASE_HEAD BASE_TREE EXPECT_HEAD EXPECT_TREE EXPECT_CONTRACT_BLOB EXPECT_S10C_SPEC_BLOB; do',
    'for v in BASE_HEAD BASE_TREE EXPECT_HEAD EXPECT_TREE EXPECT_CONTRACT_BLOB EXPECT_S10C_SPEC_BLOB EXPECT_D2_BLOB_INDUCTION EXPECT_D2_BLOB_NATIVE EXPECT_D2_BLOB_MAPPING EXPECT_D2_BLOB_KEY EXPECT_D2_BLOB_ROWS EXPECT_D2_BLOB_STATEMENTS EXPECT_D2_BLOB_E2E EXPECT_D2_BLOB_PG FROZEN_P_BLOB; do')
rep('for v in EXPECT_NM_CLIENT_SHA EXPECT_NM_CLIENT_SCHEMA_SHA EXPECT_HOOK_PRECOMMIT_SHA EXPECT_HOOK_COMMITMSG_SHA EXPECT_FIXTURE_SHA FROZEN_SHA; do [[ "${!v}" =~ ^[0-9a-f]{64}$ ]] || { log "PRECONDITION_FAIL $v not 64-hex (${!v})"; fail 70; }; done',
    'for v in EXPECT_NM_CLIENT_SHA EXPECT_NM_CLIENT_SCHEMA_SHA EXPECT_HOOK_PRECOMMIT_SHA EXPECT_HOOK_COMMITMSG_SHA EXPECT_FIXTURE_SHA FROZEN_SHA; do [[ "${!v}" =~ ^[0-9a-f]{64}$ ]] || { log "PRECONDITION_FAIL $v not 64-hex (${!v})"; fail 70; }; done\n'
    'case "$EXPECT_LAND_REF" in none) ;; *) [ "$EXPECT_LAND_REF" = "$EXPECT_HEAD" ] || { log "PRECONDITION_FAIL EXPECT_LAND_REF must be none or = EXPECT_HEAD ($EXPECT_LAND_REF)"; fail 70; };; esac')
rep('# lane refusals (review B B4): never the retained s10-b lane, never the S9-C/S10-B ports',
    '# lane refusals (review B B4): never an s10-b lane, never the S9-C/S10-B/S11 ports')
rep('''[ "$LANE" = "$CLUSTERS/s10-c" ] && [ "$LANE" != "$S10B_LANE" ] && [ "$SOCK" = "$RUNTIME_ROOT/run/s10-c" ] || { log "PRECONDITION_FAIL lane $LANE / socket $SOCK is not clusters/s10-c + run/s10-c"; fail 70; }''',
    '''[ "$LANE" = "$CLUSTERS/s10d2" ] && [ "$LANE" != "$S10B_LANE" ] && [ "$SOCK" = "$RUNTIME_ROOT/run/s10d2" ] || { log "PRECONDITION_FAIL lane $LANE / socket $SOCK is not clusters/s10d2 + run/s10d2"; fail 70; }''')
rep('''|| { log "PRECONDITION_FAIL harness env not bound to the s10-c lane"; fail 70; }''',
    '''|| { log "PRECONDITION_FAIL harness env not bound to the s10d2 lane"; fail 70; }''')
rep('''[ -d "$S10B_LANE/pg-data" ] && [ ! -L "$S10B_LANE" ] || { log "PRECONDITION_FAIL retained S10-B lane $S10B_LANE/pg-data absent or a symlink (it must be retained and untouched; README.md)"; fail 70; }
{ [ -e "$S10B_LANE/pg-data/postmaster.pid" ] || [ -L "$S10B_LANE/pg-data/postmaster.pid" ]; } && { log "PRECONDITION_FAIL retained S10-B lane has a postmaster.pid (running or unclean); refusing"; fail 70; }''',
    '''# (no retained S10-B lane in the fa72efb2 runtime: the template's must-exist check is dropped; a present one must be stopped)
[ ! -L "$S10B_LANE" ] || { log "PRECONDITION_FAIL $S10B_LANE is a symlink"; fail 70; }
{ [ -e "$S10B_LANE/pg-data/postmaster.pid" ] || [ -L "$S10B_LANE/pg-data/postmaster.pid" ]; } && { log "PRECONDITION_FAIL an S10-B lane has a postmaster.pid (running or unclean); refusing"; fail 70; }''')
rep('''WANT_DELTA=$(printf '%s\\n' $S10C_OWNED $( [ "$EXPECT_CONTRACT_STATE" = changed ] && echo "$CONTRACT") | sort | tr '\\n' ' ' | sed 's/ $//')''',
    '''WANT_DELTA=$(printf '%s\\n' $D2_OWNED $( [ "$EXPECT_CONTRACT_STATE" = changed ] && echo "$CONTRACT") | sort | tr '\\n' ' ' | sed 's/ $//')''')
rep('''!= the 12 S10-C owned paths (+ contract iff changed) [$WANT_DELTA]"''', '''!= the 8 D2 paths (+ contract iff changed) [$WANT_DELTA]"''')
rep('''[ "$EXPECT_NM_CLIENT_SHA" != "$DONOR_CLIENT_SHA" ] || { log "PRECONDITION_FAIL EXPECT_NM_CLIENT_SHA is the pre-S10-B donor client (no in-clone generate recorded)"; fail 70; }''',
    '''[ "$EXPECT_CONTRACT_STATE" = unchanged ] || { log "PRECONDITION_FAIL D2 changes no contract (EXPECT_CONTRACT_STATE=$EXPECT_CONTRACT_STATE)"; fail 70; }
[ "$EXPECT_NM_CLIENT_SHA" = "$DONOR_CLIENT_SHA" ] && [ "$EXPECT_NM_CLIENT_SCHEMA_SHA" = "$DONOR_CLIENT_SCHEMA_SHA" ] || { log "PRECONDITION_FAIL INVERTED guard: the donor was generated from the S10-B schema, so the expected clone client must EQUAL the donor client"; fail 70; }''')
rep('''grep -qx "LANE=\\$RUNTIME_ROOT/clusters/s10-c" <<<"$FIXTXT" && grep -qx "DATA=\\$LANE/pg-data; LOG=\\$LANE/pg.log; SOCK=\\$RUNTIME_ROOT/run/s10-c" <<<"$FIXTXT" || { log "PRECONDITION_FAIL fixture lane/socket lines != clusters/s10-c + run/s10-c"; fail 70; }''',
    '''grep -qx "LANE=\\$RUNTIME_ROOT/clusters/s10d2" <<<"$FIXTXT" && grep -qx "DATA=\\$LANE/pg-data; LOG=\\$LANE/pg.log; SOCK=\\$RUNTIME_ROOT/run/s10d2" <<<"$FIXTXT" || { log "PRECONDITION_FAIL fixture lane/socket lines != clusters/s10d2 + run/s10d2"; fail 70; }''')
rep('''grep -qF 'case "$PORT" in 55646|55647)' <<<"$FIXTXT"''', '''grep -qF 'case "$PORT" in 55646|55647|55648)' <<<"$FIXTXT"''')
rep('''grep -qF 'grep -q s10c-pg-proof.sh "/proc/$S10C_RUNNER_PID/cmdline"' <<<"$FIXTXT" || { log "PRECONDITION_FAIL fixture does not require the S10-C runner"; fail 70; }''',
    '''grep -qF 'grep -q d2-pg-proof.sh "/proc/$D2_RUNNER_PID/cmdline"' <<<"$FIXTXT" || { log "PRECONDITION_FAIL fixture does not require the D2 runner"; fail 70; }
# clone source: a real repository at the committed candidate; the fresh clone path and the lane must not exist yet
[ -d "$SRC/.git" ] && [ ! -L "$SRC/.git" ] && [ ! -L "$SRC" ] || { log "PRECONDITION_FAIL $SRC/.git is not a real repository directory"; fail 70; }
[ "$(git -C "$SRC" rev-parse --verify -q refs/heads/fa72/d2)" = "$EXPECT_HEAD" ] && [ "$(git -C "$SRC" symbolic-ref -q HEAD)" = refs/heads/fa72/d2 ] || { log "PRECONDITION_FAIL $SRC is not on fa72/d2 at $EXPECT_HEAD"; fail 70; }
case "$EXPECT_LAND_REF" in none) log "PRELOCK land_ref=none ($LAND_REF not checked: no land ref pushed)";;
  *) [ "$(git -C "$SRC" rev-parse --verify -q "$LAND_REF")" = "$EXPECT_HEAD" ] || { log "PRECONDITION_FAIL $LAND_REF != $EXPECT_HEAD"; fail 70; };; esac
{ [ -e "$W" ] || [ -L "$W" ]; } && { log "PRECONDITION_FAIL $W exists (fresh clone only; never reuse)"; fail 70; }''')
rep('''[ "$(git -C "$SRC" rev-parse HEAD^)" = "$BASE_HEAD" ] || { log "PRECONDITION_FAIL HEAD^ != $BASE_HEAD (the gate makes exactly one commit on BASE)"; fail 70; }''',
    '''[ "$(git -C "$SRC" rev-parse HEAD^)" = "$BASE_HEAD" ] && [ "$(git -C "$SRC" rev-list --count "$BASE_HEAD..HEAD")" = 1 ] || { log "PRECONDITION_FAIL HEAD^ != $BASE_HEAD (the gate makes exactly one commit on BASE)"; fail 70; }''')
rep('''# exact delta: BASE..HEAD = the gate receipt delta (12 S10-C paths, + contract iff changed); FROZEN S10-A/S10-B bytes at HEAD''',
    '''# exact delta: BASE..HEAD = the 8 D2 paths, all added as 100644 files; FROZEN S10-A/S10-B bytes at HEAD (one premise-P exception)''')
rep('''[ "$DELTA" = "$EXPECT_DELTA" ] || { log "PRECONDITION_FAIL BASE..HEAD delta [$DELTA] != receipt delta [$EXPECT_DELTA]"; fail 70; }''',
    '''[ "$DELTA" = "$EXPECT_DELTA" ] || { log "PRECONDITION_FAIL BASE..HEAD delta [$DELTA] != receipt delta [$EXPECT_DELTA]"; fail 70; }
DADD=$(git -C "$SRC" diff --name-only --diff-filter=A "$BASE_HEAD" HEAD | sort | tr '\\n' ' ' | sed 's/ $//'); [ "$DADD" = "$EXPECT_DELTA" ] || { log "PRECONDITION_FAIL D2 delta is not 8 pure additions [$DADD]"; fail 70; }
DMODES=$(git -C "$SRC" ls-tree HEAD -- $EXPECT_DELTA | awk '{print $1}' | sort -u); [ "$DMODES" = 100644 ] || { log "PRECONDITION_FAIL D2 paths not all mode 100644 [$(echo $DMODES)]"; fail 70; }
for pin in "src/scout/induction/sources/s10_unseen.json $EXPECT_D2_BLOB_INDUCTION" "src/scout/reconstruct/native/sources/s10_unseen.json $EXPECT_D2_BLOB_NATIVE" \\
           "src/scout/reconstruct/sources/s10_unseen.json $EXPECT_D2_BLOB_MAPPING" "test/fixtures/scout/s10_unseen/signer-test-key.json $EXPECT_D2_BLOB_KEY" \\
           "test/fixtures/scout/s10_unseen/staged-rows.json $EXPECT_D2_BLOB_ROWS" "test/fixtures/scout/s10_unseen/statements.json $EXPECT_D2_BLOB_STATEMENTS" \\
           "test/scout/s10/s10-unseen.e2e.spec.ts $EXPECT_D2_BLOB_E2E" "$D2_SPEC $EXPECT_D2_BLOB_PG"; do set -- $pin
  [ "$(git -C "$SRC" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL D2 path $1 blob != gate pin $2"; fail 70; }; done''')
rep('''  [ "$(git -C "$SRC" rev-parse "HEAD:$p" 2>/dev/null)" = "$b" ] || { log "PRECONDITION_FAIL frozen $p at HEAD != $b"; fail 70; }''',
    '''  [ "$p" = "$FROZEN_P_PATH" ] && b=$FROZEN_P_BLOB   # premise P (7746a877, ancestor of BASE) re-stated this spec; pinned to its BASE blob
  [ "$(git -C "$SRC" rev-parse "HEAD:$p" 2>/dev/null)" = "$b" ] || { log "PRECONDITION_FAIL frozen $p at HEAD != $b"; fail 70; }''')
rep('''|| { log "PRECONDITION_FAIL prisma / dependency manifests differ from base (S10-C changes no prisma)"; fail 70; }''',
    '''|| { log "PRECONDITION_FAIL prisma / dependency manifests differ from base (D2 changes no prisma)"; fail 70; }''')
# spec reads
rep('''  && SPEC_C_AT_HEAD=$(git -C "$SRC" show HEAD:test/rls-g2-s10c.spec.ts) || { log "PRECONDITION_FAIL cannot read harness bytes at HEAD"; fail 70; }''',
    '''  && SPEC_C_AT_HEAD=$(git -C "$SRC" show HEAD:test/rls-g2-s10c.spec.ts) && SPEC_D2_AT_HEAD=$(git -C "$SRC" show "HEAD:$D2_SPEC") || { log "PRECONDITION_FAIL cannot read harness bytes at HEAD"; fail 70; }''')
rep('''for sp in "$SPEC_AT_HEAD" "$SPEC_C_AT_HEAD"; do ! grep -qE '\\b(it|describe|test)\\.(skip|only|todo)\\b|\\b(xit|fit|xdescribe|fdescribe)\\(' <<<"$sp" || { log "PRECONDITION_FAIL a live spec carries skip/only/todo"; fail 70; }; done
grep -qF "from './utils/g2-s10b-harness'" <<<"$SPEC_C_AT_HEAD" && ! grep -qE "g2-s10c-|G2_S10C_" <<<"$SPEC_C_AT_HEAD" || { log "PRECONDITION_FAIL test/rls-g2-s10c.spec.ts does not reuse the S10-B harness (or references an S10-C harness)"; fail 70; }''',
    '''for sp in "$SPEC_AT_HEAD" "$SPEC_C_AT_HEAD"; do ! grep -qE '\\b(it|describe|test)\\.(skip|only|todo)\\b|\\b(xit|fit|xdescribe|fdescribe)\\(' <<<"$sp" || { log "PRECONDITION_FAIL a live spec carries skip/only/todo"; fail 70; }; done
grep -qF "from './utils/g2-s10b-harness'" <<<"$SPEC_C_AT_HEAD" && ! grep -qE "g2-s10c-|G2_S10C_" <<<"$SPEC_C_AT_HEAD" || { log "PRECONDITION_FAIL test/rls-g2-s10c.spec.ts does not reuse the S10-B harness (or references an S10-C harness)"; fail 70; }
# the D2 spec (the ONLY spec this run executes): pinned it() count; the ONLY skip allowed is the file-level env switch in its
# pinned live form (LIVE iff G2_S10B_DATABASE_URL is a string, which this runner exports); no other skip/only/todo/each
NTD=$(grep -cE '^\\s*it\\(' <<<"$SPEC_D2_AT_HEAD" || true); [ "$NTD" = "$EXPECT_TESTS_D2" ] || { log "PRECONDITION_FAIL it() count in committed $D2_SPEC $NTD != $EXPECT_TESTS_D2"; fail 70; }
D2_LIVE_LINE="const LIVE = typeof process.env.G2_S10B_DATABASE_URL === 'string';"; D2_SUITE_LINE='const suite = LIVE ? describe : describe.skip;'
[ "$(grep -cxF "$D2_LIVE_LINE" <<<"$SPEC_D2_AT_HEAD" || true)" = 1 ] && [ "$(grep -cxF "$D2_SUITE_LINE" <<<"$SPEC_D2_AT_HEAD" || true)" = 1 ] \\
  && [ "$(grep -cE '^suite\\(' <<<"$SPEC_D2_AT_HEAD" || true)" = 1 ] && [ "$(grep -cF 'LIVE' <<<"$SPEC_D2_AT_HEAD" || true)" = 2 ] || { log "PRECONDITION_FAIL $D2_SPEC env switch is not the pinned live form (LIVE line, suite line, one suite( block)"; fail 70; }
SPEC_D2_REST=$(grep -vxF "$D2_SUITE_LINE" <<<"$SPEC_D2_AT_HEAD" | grep -vE '^\\s*(\\*|//|/\\*)' || true)   # comment lines excluded (the header prose names `describe.skip`)
[ "$(grep -cE '^\\s*test\\(' <<<"$SPEC_D2_AT_HEAD" || true)" = 0 ] || { log "PRECONDITION_FAIL $D2_SPEC has test( cases outside the pinned it() count"; fail 70; }
! grep -qE '\\b(it|describe|test|suite)\\.(skip|only|todo|each|concurrent|failing)\\b|\\b(xit|fit|xtest|xdescribe|fdescribe)\\(' <<<"$SPEC_D2_REST" || { log "PRECONDITION_FAIL $D2_SPEC carries skip/only/todo/each beyond the pinned env switch"; fail 70; }
grep -qF "require('../../utils/g2-s10b-pg-harness')" <<<"$SPEC_D2_AT_HEAD" && grep -qF "require('../../utils/g2-s10b-harness')" <<<"$SPEC_D2_AT_HEAD" \\
  && ! grep -qE "g2-s10c-|G2_S10C_|g2-s10d|G2_S10D|g2-s11-|G2_S11_" <<<"$SPEC_D2_AT_HEAD" || { log "PRECONDITION_FAIL $D2_SPEC does not reuse the S10-B lane by import (or references another harness)"; fail 70; }''')
rep('''|| { log "PRECONDITION_FAIL test/rls-g2-s10c.spec.ts blob != receipt $EXPECT_S10C_SPEC_BLOB"; fail 70; }''',
    '''|| { log "PRECONDITION_FAIL test/rls-g2-s10c.spec.ts blob != landed $EXPECT_S10C_SPEC_BLOB"; fail 70; }''')
rep('''[ -z "$(git -C "$SRC" status --porcelain --untracked-files=all)" ] || { log "PRECONDITION_FAIL worktree not clean"; fail 70; }''',
    '''[ -z "$(git -C "$SRC" status --porcelain --untracked-files=all)" ] || { log "PRECONDITION_FAIL clone source worktree not clean"; fail 70; }''')
rep('''# the committed head must have been produced through the tracked lefthook hooks (installed by the S10-C gate)''',
    '''# the committed head must have been produced through the tracked lefthook hooks of the clone source (the D2 gate commits in $SRC)''')
rep('''H=$(git -C "$SRC" rev-parse --git-path hooks); case "$H" in /*) ;; *) H="$W/$H";; esac
[ "$H" = "$W/.git/hooks" ] && [ -d "$H" ] && [ ! -L "$H" ] || { log "PRECONDITION_FAIL hooks dir [$H] is not the plain $W/.git/hooks directory"; fail 70; }''',
    '''H=$(git -C "$SRC" rev-parse --git-path hooks); case "$H" in /*) ;; *) H="$SRC/$H";; esac
[ "$H" = "$SRC/.git/hooks" ] && [ -d "$H" ] && [ ! -L "$H" ] || { log "PRECONDITION_FAIL hooks dir [$H] is not the plain $SRC/.git/hooks directory"; fail 70; }''')
rep('''|| { log "PRECONDITION_FAIL hook sha256 pre-commit=$(sha "$H/pre-commit") commit-msg=$(sha "$H/commit-msg") != gate receipt hooks raw ($EXPECT_HOOK_PRECOMMIT_SHA / $EXPECT_HOOK_COMMITMSG_SHA)"; fail 70; }''',
    '''|| { log "PRECONDITION_FAIL hook sha256 pre-commit=$(sha "$H/pre-commit") commit-msg=$(sha "$H/commit-msg") != D2 gate pins ($EXPECT_HOOK_PRECOMMIT_SHA / $EXPECT_HOOK_COMMITMSG_SHA)"; fail 70; }''')
rep('''# S10-C wiring: ScoutModule imports ObservationModule at HEAD (the S10-B binding required the opposite)''',
    '''# S10-C wiring (landed in BASE; the D2 chain needs it): ScoutModule imports ObservationModule at HEAD''')
# node_modules block: pre-lock now checks the DONOR (W does not exist yet); the copy is verified after step 2
i0 = s.index('# dependency tree: the ISOLATED real copy the S10-C gate made')
i1 = s.index('# tools: pinned PG 17.6 server binaries')
rep(s[i0:i1], '''# dependency tree (pre-lock): the read-only DONOR the copy will be taken from (W does not exist yet; the copy is verified in
# step 2 under the lock). Manifests and schema are checked on the committed bytes at HEAD.
[ -d "$DONOR_NM" ] && [ ! -L "$DONOR_NM" ] || { log "PRECONDITION_FAIL donor $DONOR_NM absent or a symlink"; fail 70; }
[ "$(git -C "$SRC" show HEAD:package-lock.json | sha256sum | cut -c1-64)" = "$EXPECT_PKG_LOCK_SHA" ] || { log "PRECONDITION_FAIL package-lock.json at HEAD != base record"; fail 70; }
[ "$(sha "$DONOR_NM/.package-lock.json")" = "$EXPECT_NM_LOCK_SHA" ] || { log "PRECONDITION_FAIL donor node_modules/.package-lock.json != rt-setup record"; fail 70; }
[ "$(git -C "$SRC" show HEAD:prisma/schema.prisma | sha256sum | cut -c1-64)" = "$EXPECT_SCHEMA_SHA" ] || { log "PRECONDITION_FAIL prisma/schema.prisma at HEAD != S10-B d6d01f54"; fail 70; }
[ "$(sha "$DONOR_NM/.prisma/client/index.d.ts" 2>/dev/null)" = "$DONOR_CLIENT_SHA" ] && [ "$(sha "$DONOR_NM/.prisma/client/schema.prisma" 2>/dev/null)" = "$DONOR_CLIENT_SCHEMA_SHA" ] || { log "PRECONDITION_FAIL donor client != rt-setup client (never regenerate $DONOR_NM)"; fail 70; }
CSCH=$(cat "$DONOR_NM/.prisma/client/schema.prisma")
for m_ in ScoutRunDeclaration ScoutRunObservation ScoutRunSettledBasis; do grep -qE "^model $m_ \\{" <<<"$CSCH" || { log "PRECONDITION_FAIL donor client lacks $m_"; fail 70; }; done
[ -x "$DONOR_NM/.bin/jest" ] && [ -x "$DONOR_NM/.bin/ts-node" ] && [ -x "$DONOR_NM/.bin/prisma" ] || { log "PRECONDITION_FAIL donor jest/ts-node/prisma missing"; fail 70; }
DPV=$("$DONOR_NM/.bin/prisma" --version 2>/dev/null || true); DPV=$(awk '/^prisma /{print $3}' <<<"$DPV")
[ "$DPV" = "$EXPECT_PRISMA_CLI" ] || { log "PRECONDITION_FAIL donor prisma CLI '$DPV' != $EXPECT_PRISMA_CLI"; fail 70; }
''')
rep('''# tools: pinned PG 17.6 server binaries in the 1910a060 namespace''', '''# tools: pinned PG 17.6 server binaries in the fa72efb2 namespace''')
rep('''PRV=$(cd "$W" && ./node_modules/.bin/prisma --version 2>/dev/null || true)
log "PRECONDITIONS_OK (pre-lock) $(ts) server='$PGV' psql='$PSQLV' node=$NODEV jest=$(cd "$W" && ./node_modules/.bin/jest --version) ts_node=$(cd "$W" && ./node_modules/.bin/ts-node --version 2>/dev/null) prisma=$(awk '/^prisma /{print $3}' <<<"$PRV")"
LOG=$R/s10c-pg-proof.log''',
    '''log "PRECONDITIONS_OK (pre-lock) $(ts) server='$PGV' psql='$PSQLV' node=$NODEV donor_jest=$("$DONOR_NM/.bin/jest" --version) donor_ts_node=$("$DONOR_NM/.bin/ts-node" --version 2>/dev/null) prisma=$DPV"
LOG=$R/d2-pg-proof.log''')
rep('''( cd "$R" && sha256sum s10c-pg-proof.log prelock.log''', '''( cd "$R" && sha256sum d2-pg-proof.log prelock.log''')

# ---- 6. under-lock rechecks (source, donor, fresh-clone path)
rep('''[ "$(sha "$FIX")" = "$EXPECT_FIXTURE_SHA" ] && [ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] && [ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] \\
  && [ "$(sha "$W/node_modules/.prisma/client/index.d.ts")" = "$EXPECT_NM_CLIENT_SHA" ] && [ "$(sha "$DONOR_NM/.prisma/client/index.d.ts" 2>/dev/null)" = "$DONOR_CLIENT_SHA" ] \\
  || { log "PRECONDITION_FAIL fixture/HEAD/worktree/client moved after the pre-lock preconditions"; fail 70; }
[ -z "$(git -C "$W" config --get core.hooksPath)" ] && [ "$(git -C "$W" rev-parse --git-path hooks)" = .git/hooks ] && [ -d "$H" ] && [ ! -L "$H" ] \\''',
    '''[ "$(sha "$FIX")" = "$EXPECT_FIXTURE_SHA" ] && [ "$(git -C "$SRC" rev-parse HEAD)" = "$EXPECT_HEAD" ] && [ -z "$(git -C "$SRC" status --porcelain --untracked-files=all)" ] \\
  && [ "$(git -C "$SRC" rev-parse --verify -q refs/heads/fa72/d2)" = "$EXPECT_HEAD" ] && { [ "$EXPECT_LAND_REF" = none ] || [ "$(git -C "$SRC" rev-parse --verify -q "$LAND_REF")" = "$EXPECT_HEAD" ]; } \\
  && [ "$(sha "$DONOR_NM/.prisma/client/index.d.ts" 2>/dev/null)" = "$DONOR_CLIENT_SHA" ] && [ ! -e "$W" ] && [ ! -L "$W" ] \\
  || { log "PRECONDITION_FAIL fixture/source HEAD/source worktree/land ref/donor client/clone path moved after the pre-lock preconditions"; fail 70; }
[ -z "$(git -C "$SRC" config --get core.hooksPath)" ] && [ "$(git -C "$SRC" rev-parse --git-path hooks)" = .git/hooks ] && [ -d "$H" ] && [ ! -L "$H" ] \\''')

# ---- 7. preflight: no retained s10-b lane requirement; PORC0 moves to after the clone
rep('''# ---- step 1 preflight (read-only): S10-B lane absent; lane port free; no postgres; other lanes under the runtime root (clusters/*
#      incl. clusters/s8-g, s9-b, s9-c, and proof-*/clusters/*) fingerprinted and never started''',
    '''# ---- step 1 preflight (read-only): s10d2 lane absent; lane port free; no postgres; other lanes under the runtime root (clusters/*
#      incl. clusters/s11 if the S11 binding ran, and proof-*/clusters/*) fingerprinted and never started''')
rep('''case " $OTHER0 " in *" clusters/s10-b:"*) ;; *) log "PREFLIGHT_FAIL retained S10-B lane not in the fingerprint set"; fail 71;; esac
[ -f "$S10B_LANE/pg-data/postgresql.conf" ] && [ -f "$S10B_LANE/pg-data/global/pg_control" ] || { log "PREFLIGHT_FAIL retained S10-B lane fingerprint incomplete (postgresql.conf / global/pg_control absent)"; fail 71; }
log "PREFLIGHT retained_s10b_lane=$S10B_LANE (fingerprinted; must be unchanged at end; never started)"
''', '''log "PREFLIGHT s10b_lane=$( [ -e "$S10B_LANE" ] && echo "present (fingerprinted above; must be unchanged at end; never started)" || echo absent)"
''')
rep('''PORC0=$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)
log "PREFLIGHT_OK $(ts) lane=absent port$PORT=free postgres_procs=0 worktree_porcelain_sha=$PORC0 lock_inode=$(stat -c %i "$LOCK")"''',
    '''SRCSIG0=$(git -C "$SRC" status --porcelain --untracked-files=all | sha256sum | cut -c1-64):$(git -C "$SRC" rev-parse HEAD)
log "PREFLIGHT_OK $(ts) lane=absent port$PORT=free postgres_procs=0 source_sig=$SRCSIG0 clone=absent lock_inode=$(stat -c %i "$LOCK")"
# ---- step 1b fresh clean clone at the attested head (objects shared read-only with the source; no hooks run) + a real copy of
#      the donor node_modules (donor read-only; no npm, no prisma generate: the donor client IS the S10-B client) (bound 120+120+600 s)
STAGE=clone
timeout -k 30 120 git -c core.hooksPath=/dev/null clone --quiet --shared --no-checkout "$SRC" "$W" >>"$LOG" 2>&1; rc=$?; log "CLONE rc=$rc $(ts)"; [ $rc = 0 ] || fail 71
timeout -k 30 120 git -C "$W" -c core.hooksPath=/dev/null checkout --quiet --detach "$EXPECT_HEAD" >>"$LOG" 2>&1; rc=$?; log "CHECKOUT rc=$rc $(ts)"; [ $rc = 0 ] || fail 71
[ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] && [ "$(git -C "$W" rev-parse 'HEAD^{tree}')" = "$EXPECT_TREE" ] && [ "$(git -C "$W" rev-parse HEAD^)" = "$BASE_HEAD" ] \\
  && [ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] && [ "$(git -C "$W" rev-parse HEAD:prisma/migrations)" = "$EXPECT_MIGRATIONS_TREE" ] \\
  && git -C "$W" merge-base --is-ancestor "$HARNESS_BASE_HEAD" HEAD && [ -z "$(git -C "$W" config --get core.hooksPath)" ] \\
  || { log "CLONE_FAIL clone head/tree/parent/clean/migrations/harness-base mismatch"; fail 71; }
[ "$(find "$W/prisma/migrations" -mindepth 1 -maxdepth 1 -type d | wc -l)" = "$EXPECT_MIGRATIONS" ] || { log "CLONE_FAIL migration dir count"; fail 71; }
[ "$(sha "$W/package-lock.json")" = "$EXPECT_PKG_LOCK_SHA" ] && [ "$(sha "$W/prisma/schema.prisma")" = "$EXPECT_SCHEMA_SHA" ] || { log "CLONE_FAIL package-lock/schema bytes"; fail 71; }
STAGE=node_modules
( cd "$W" && timeout -k 30 600 cp -a "$DONOR_NM" node_modules ) >>"$LOG" 2>&1; rc=$?; log "CP_A rc=$rc $(ts) entries=$(ls "$W/node_modules" 2>/dev/null | wc -l)"; [ $rc = 0 ] || fail 71
# dependency tree: the ISOLATED real copy just made (not a symlink, not the donor, not a fresh npm ci) carrying the donor's
# S10-B client; the donor is unchanged (never regenerated)
[ -d "$W/node_modules" ] && [ ! -L "$W/node_modules" ] || { log "NM_FAIL $W/node_modules absent or a symlink (isolated copy required)"; fail 71; }
for d in "$W/node_modules" "$W/node_modules/.prisma/client" "$W/node_modules/@prisma/client"; do case "$(readlink -f "$d")" in "$W"/*) ;; *) log "NM_FAIL $d resolves outside $W"; fail 71;; esac; done
ABS_LINKS=$(find "$W/node_modules/.prisma" "$W/node_modules/@prisma" "$W/node_modules/prisma" -type l -lname '/*' 2>/dev/null)
[ -z "$ABS_LINKS" ] || { log "NM_FAIL absolute symlinks in the copied prisma tree: $(echo $ABS_LINKS)"; fail 71; }
[ "$(sha "$W/node_modules/.package-lock.json")" = "$EXPECT_NM_LOCK_SHA" ] || { log "NM_FAIL node_modules/.package-lock.json != donor record"; fail 71; }
[ "$(sha "$W/node_modules/.prisma/client/index.d.ts")" = "$EXPECT_NM_CLIENT_SHA" ] || { log "NM_FAIL copied client index.d.ts != donor client (no generate here; stale or foreign client)"; fail 71; }
[ "$(sha "$W/node_modules/.prisma/client/schema.prisma")" = "$EXPECT_NM_CLIENT_SCHEMA_SHA" ] || { log "NM_FAIL copied client schema.prisma != donor client"; fail 71; }
CSCH=$(cat "$W/node_modules/.prisma/client/schema.prisma")
for m_ in ScoutRunDeclaration ScoutRunObservation ScoutRunSettledBasis; do grep -qE "^model $m_ \\{" <<<"$CSCH" || { log "NM_FAIL candidate client lacks $m_"; fail 71; }; done
[ "$(sha "$DONOR_NM/.prisma/client/index.d.ts" 2>/dev/null)" = "$DONOR_CLIENT_SHA" ] || { log "NM_FAIL donor client changed (the copy must never touch $DONOR_NM)"; fail 71; }
[ -x "$W/node_modules/.bin/jest" ] && [ -x "$W/node_modules/.bin/ts-node" ] && [ -x "$W/node_modules/.bin/prisma" ] || { log "NM_FAIL jest/ts-node/prisma missing"; fail 71; }
[ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] || { log "NM_FAIL clone not clean after the copy"; fail 71; }
PORC0=$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)
PRV=$(cd "$W" && ./node_modules/.bin/prisma --version 2>/dev/null || true)
log "CLONE_READY $(ts) head=$EXPECT_HEAD worktree_porcelain_sha=$PORC0 jest=$(cd "$W" && ./node_modules/.bin/jest --version) ts_node=$(cd "$W" && ./node_modules/.bin/ts-node --version 2>/dev/null) prisma=$(awk '/^prisma /{print $3}' <<<"$PRV")"''')

# ---- 8. fixture markers
rep('''grep -q "^S10C_FIXTURE_INIT_OK data=''', '''grep -q "^D2_FIXTURE_INIT_OK data=''')
rep('''grep -q "^S10C_FIXTURE_START_OK pid=''', '''grep -q "^D2_FIXTURE_START_OK pid=''')

# ---- 9. the proof command
rep('''# ---- step 6 the proof, exactly once (bound 1500 s); no --testTimeout/--forceExit/--detectOpenHandles/coverage
STAGE=jest; log "JEST_START $(ts) cmd='./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s10b.spec.ts test/rls-g2-s10c.spec.ts --runInBand --ci' candidate_head=$G2_S10B_CANDIDATE_HEAD expect_tests=$EXPECT_TESTS_S10B+$EXPECT_TESTS_S10C"
( cd "$W" && timeout -k 30 1500 ./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s10b.spec.ts test/rls-g2-s10c.spec.ts --runInBand --ci ) >"$JLOG" 2>&1; JRC=$?''',
    '''# ---- step 6 the proof, exactly once (bound 1500 s); no --testTimeout/--forceExit/--detectOpenHandles/coverage
STAGE=jest; log "JEST_START $(ts) cmd='./node_modules/.bin/jest -c jest.config.js --runInBand --ci --runTestsByPath $D2_SPEC' candidate_head=$G2_S10B_CANDIDATE_HEAD expect_tests=$EXPECT_TESTS_D2"
( cd "$W" && timeout -k 30 1500 ./node_modules/.bin/jest -c jest.config.js --runInBand --ci --runTestsByPath "$D2_SPEC" ) >"$JLOG" 2>&1; JRC=$?''')
rep('''grep -qE "^Test Suites: +2 passed, 2 total" "$JLOG" || { log "JEST_COUNT_FAIL expected 'Test Suites: 2 passed, 2 total' (got: $(grep -E '^Test Suites:' "$JLOG" | head -1))"; fail 72; }
JP=$(grep -E '^PASS ' "$JLOG" | grep -oE 'test/[^ ]+\\.spec\\.ts' | sort | tr '\\n' ' ')   # v5: jest.rls.config.js displayName (rls-live) precedes the path
[ "$JP" = "test/rls-g2-s10b.spec.ts test/rls-g2-s10c.spec.ts " ] || { log "JEST_COUNT_FAIL PASS lines [$JP] != the two specs"; fail 72; }
log "JEST_COUNT_OK tests=$EXPECT_TESTS (s10b=$EXPECT_TESTS_S10B + s10c=$EXPECT_TESTS_S10C pinned at HEAD) suites=2"''',
    '''grep -qE "^Test Suites: +1 passed, 1 total" "$JLOG" || { log "JEST_COUNT_FAIL expected 'Test Suites: 1 passed, 1 total' (got: $(grep -E '^Test Suites:' "$JLOG" | head -1))"; fail 72; }
JP=$(grep -E '^PASS ' "$JLOG" | grep -oE 'test/[^ ]+\\.spec\\.ts' | sort | tr '\\n' ' ')   # jest.config.js has no displayName; the parser tolerates one
[ "$JP" = "$D2_SPEC " ] || { log "JEST_COUNT_FAIL PASS lines [$JP] != the D2 spec"; fail 72; }
log "JEST_COUNT_OK tests=$EXPECT_TESTS (d2=$EXPECT_TESTS_D2 pinned at HEAD) suites=1"''')
rep('''# ---- step 7 stop (bound 45 s + kill 30); data dir RETAINED (destroy only via separate grant: s10c-fixture.sh destroy)''',
    '''# ---- step 7 stop (bound 45 s + kill 30); data dir RETAINED (destroy only via separate grant: d2-fixture.sh destroy)''')

# ---- 10. post
rep('''[ ! -e "$S10B_LANE/pg-data/postmaster.pid" ] && [ ! -L "$S10B_LANE/pg-data/postmaster.pid" ] || { log "POST_FAIL retained S10-B lane postmaster.pid appeared"; fail 74; }
log "POST other_lanes_unchanged=[${OTHER0:-none}] retained_s10b_lane=unchanged,stopped refused_ports=[$REFUSED_LANE_PORTS] free"''',
    '''[ ! -e "$S10B_LANE/pg-data/postmaster.pid" ] && [ ! -L "$S10B_LANE/pg-data/postmaster.pid" ] || { log "POST_FAIL S10-B lane postmaster.pid appeared"; fail 74; }
log "POST other_lanes_unchanged=[${OTHER0:-none}] s10b_lane=$( [ -e "$S10B_LANE" ] && echo unchanged,stopped || echo absent) refused_ports=[$REFUSED_LANE_PORTS] free"''')
rep('''|| { log "POST_FAIL worktree changed"; fail 74; }''',
    '''|| { log "POST_FAIL worktree changed"; fail 74; }
[ "$(git -C "$SRC" status --porcelain --untracked-files=all | sha256sum | cut -c1-64):$(git -C "$SRC" rev-parse HEAD)" = "$SRCSIG0" ] || { log "POST_FAIL clone source changed during the proof"; fail 74; }''')

# ---- 11. R1 closure (parent 08:29): lock -> under-lock rechecks -> preflight -> fresh clone + checkout + donor copy + their
#      verifications -> ONLY THEN the O_EXCL STARTED marker. Everything before STARTED refuses without consuming the run
#      (no STARTED, no sentinel) and removes the partial W that THIS run created (mkdir-exclusive), never a pre-existing W.
Ls = s.split('\n')
def idx(prefix, start=0):
    r = [i for i, l in enumerate(Ls) if i >= start and l.startswith(prefix)]
    if len(r) != 1: sys.exit(f'IDX {len(r)} for {prefix!r}')
    return r[0]
i_log   = idx('LOG=$R/d2-pg-proof.log')
i_sent  = idx('{ [ -e "$SENT" ] || [ -L "$SENT" ]; } && { echo "REFUSED: $SENT exists; this proof runs once, no retry" >&2; exit 76; }', i_log)
i_lockf = idx('[ -e "$LOCK" ] || { echo "REFUSED: canonical lock file')
i_exec  = idx('exec 9>>"$LOCK"; flock -n 9')
i_inode = idx('[ "$(stat -c %i "$LOCK")" = "$EXPECT_LOCK_INODE" ]')
i_start = idx('( set -C; date -u +%FT%TZ > "$R/STARTED" )')
i_stage = idx('STAGE=preconditions', i_start)
i_fin   = idx('finish(){ local rc=$1')
i_lst   = idx('listeners(){ ')
i_prt   = idx('portl(){ ')
i_slog  = idx('log "START $(ts) pid=$$')
i_recheck = idx('# re-verify under the lock the state that could have moved')
i_ready = idx('log "CLONE_READY $(ts)')
i_clone = idx('timeout -k 30 120 git -c core.hooksPath=/dev/null clone')
assert (i_log+1 == i_sent and i_sent+1 == i_lockf and i_lockf+1 == i_exec and i_exec+1 == i_inode and i_inode+1 == i_start
        and i_start+1 == i_stage and i_stage+1 == i_fin and i_fin < i_lst and i_lst+1 == i_prt and i_prt+1 == i_slog
        and i_slog+1 == i_recheck and i_recheck < i_clone < i_ready), 'layout'
fin_fail = Ls[i_fin:i_lst]
old_started = Ls[i_start]
started = old_started.replace('{ echo "REFUSED: $R/STARTED exists (or is a symlink) at lock time; this proof runs once, no retry" >&2; exit 76; }',
    '{ log "REFUSED: $R/STARTED exists (or is a symlink) at STARTED time; this proof runs once, no retry"; refuse 76; }')
assert started != old_started
started = started.replace('# O_EXCL one-shot marker (gate DELTA-2 analogue)', '# O_EXCL one-shot marker (gate DELTA-2 analogue); written only AFTER clone/copy/verify (R1)')
body = Ls[i_recheck:i_ready+1]
k = i_clone - i_recheck
body = body[:k] + [
    'mkdir -- "$W" 2>>"$LOG" || { log "CLONE_FAIL $W could not be created exclusively (it appeared after the pre-lock check; never adopted, never removed)"; fail 71; }',
    'W_CREATED=1   # from here a prestart refusal removes $W (this run created it, empty, by mkdir-exclusive; git clone accepts an empty dir)',
] + body[k:]
new = Ls[i_sent:i_inode+1] + [
    '# ---- R1 ordering (parent 08:29): with the lock held and BEFORE the one-shot STARTED marker, re-verify, preflight, make the',
    '#      fresh clone + donor copy and verify them. Any failure here is a PRESTART refusal (rc 70/71/76 as before) that writes NO',
    '#      STARTED and NO sentinel (the run is not consumed); the partial $W is removed iff THIS run created it (mkdir-exclusive);',
    '#      a $W that existed before this run is refused pre-lock or at mkdir and never touched. Prestart lines go to prelock.log.',
    'STAGE=prestart-recheck; W_CREATED=0',
    'refuse(){ local rc=$1 wrm=not-created',
    '  if [ "$W_CREATED" = 1 ]; then wrm=removed; rm -rf -- "$W" 2>>"$LOG" || wrm=REMOVE_FAILED; { [ -e "$W" ] || [ -L "$W" ]; } && wrm=REMOVE_FAILED; fi',
    '  log "PRESTART_REFUSED stage=$STAGE rc=$rc $(ts) clone=$wrm (lock fd9 held until this exit; no STARTED, no sentinel written; the run is not consumed$( [ "$wrm" = REMOVE_FAILED ] && echo "; $W remains, so a relaunch refuses pre-lock until the parent removes it"))"',
    '  exit "$rc"; }',
    'fail(){ refuse "$1"; }   # prestart fail(); redefined as the consuming fail() right after STARTED',
] + Ls[i_lst:i_prt+1] + [
    'log "LOCKED $(ts) pid=$$ lock=$LOCK(held nonblocking fd9, inode $(stat -c %i "$LOCK")) (prestart: nothing consumed yet)"',
] + body + [
    '# ---- one-shot: from here on the run is consumed',
    'STAGE=started',
    started,
    'LOG=$R/d2-pg-proof.log',
] + fin_fail + [
    Ls[i_slog].replace('head_expect=$EXPECT_HEAD', 'head_expect=$EXPECT_HEAD clone_ready=$W worktree_porcelain_sha=$PORC0'),
]
Ls = Ls[:i_log] + new + Ls[i_ready+1:]
s = '\n'.join(Ls)
rep('# Carried unchanged: single canonical lock holder (nonblocking flock fd 9 before any state change',
    '# R1 ordering (parent 08:29): lock -> under-lock rechecks -> preflight -> clone/checkout/donor copy + verification -> STARTED;\n'
    '# a failure before STARTED is PRESTART_REFUSED (not consumed; partial W removed iff this run created it).\n'
    '# Carried unchanged: single canonical lock holder (nonblocking flock fd 9 before any state change')
# ---- 12. FILL + REBASE (parent 08:53): D2 rebased onto S11-C 7fdcbc04 (S11-A1 3db615c0 + S11-C landed); candidate
#      144269d1 on fa72/d2-r1, pushed as land/s10d2. Every value below re-derived by `git rev-parse` in SRC (README fill table).
import re
NB, NT = '7fdcbc044dba1747d0db2f2750ced951f3b6b752', 'a802231ee1f4dd693284b349e7eb078b3688e8d5'
H, HT = '144269d13db5275a2d6689bebb2f7dca8367593c', 'a0bc3c09f82edd8fa13932913437813911d5be38'
NC = '1a5deca500d0dd9422edaca2f9883ed57c33a0e8'
def sub_line(prefix, new):
    global s
    L = s.split('\n'); hit = [i for i, l in enumerate(L) if l.startswith(prefix)]
    if len(hit) != 1: sys.exit(f'LINE {len(hit)} for {prefix!r}')
    L[hit[0]] = new; s = '\n'.join(L)
sub_line('BASE_HEAD=', f'BASE_HEAD={NB}                     # integration/importer tip after S11-A1 3db615c0 + S11-C 7fdcbc04 landed; D2 rebased onto it (parent 08:53)')
sub_line('BASE_TREE=', f'BASE_TREE={NT}                     # git rev-parse "$BASE_HEAD^{{tree}}"')
sub_line('EXPECT_HEAD=', f'EXPECT_HEAD={H}                   # D2 rebased commit on fa72/d2-r1 (8 D2 blobs = gated 6e3f86ce); PR #561')
sub_line('EXPECT_TREE=', f'EXPECT_TREE={HT}                   # git rev-parse HEAD^{{tree}}')
sub_line('EXPECT_CONTRACT_BLOB=', f'EXPECT_CONTRACT_BLOB={NC}          # = BASE_CONTRACT_BLOB (unchanged by D2)')
sub_line('BASE_CONTRACT_BLOB=', f'BASE_CONTRACT_BLOB={NC}            # importer contract blob at BASE 7fdcbc04 (S11-C changed it from bd715150)')
sub_line('EXPECT_HOOK_PRECOMMIT_SHA=', 'EXPECT_HOOK_PRECOMMIT_SHA=54aa5cd8b77c4b8549c8d7c40bd85e5ffc6406a6018661fed4a876f7c58de3f9   # sha256 $SRC/.git/hooks/pre-commit (lefthook)')
sub_line('EXPECT_HOOK_COMMITMSG_SHA=', 'EXPECT_HOOK_COMMITMSG_SHA=dc998a5e5776895512ee9860763444c1cb9eafa9d64e181c6cbe923c59e11be0   # sha256 $SRC/.git/hooks/commit-msg (lefthook)')
for k, v in [('INDUCTION', '4e21d522772adbde19d8ee3419b30039ec250475'), ('NATIVE', '6b8695c8b7504e7623bf3b61ef686f3dd4612f9b'),
             ('MAPPING', '94dcc8198c4b7a6ed27c6bfcf3a57d201effd879'), ('KEY', '4d5bf92e157f7d44b5f97b92e41fd3ac4b2a88f1'),
             ('ROWS', '94e7f5670e18f88fd7bcc8a728b537683d896f1f'), ('STATEMENTS', '90d644b4bbb48aec86b293d2a39eb02a670884fe'),
             ('E2E', '41df91ec0c020c16364956a2abfd9983d6f0f41c'), ('PG', '074b0fa0f0472be23e312ca68a9b0528c28230c5')]:
    rep(f'EXPECT_D2_BLOB_{k}=__FILL_BLOB_{k}__', f'EXPECT_D2_BLOB_{k}={v}')
sub_line('EXPECT_LAND_REF=', f'EXPECT_LAND_REF={H}   # the 40-hex $LAND_REF (refs/remotes/origin/land/s10d2) must equal (= EXPECT_HEAD)')
rep('FROZEN_P_BLOB=9b5de3743ec27181b58e8277591a6c8c1a8adc65          # its blob at BASE 6a33df9b (must also be its blob at HEAD: D2 does not touch it)',
    'FROZEN_P_BLOB=9b5de3743ec27181b58e8277591a6c8c1a8adc65          # its blob at BASE 7fdcbc04 (= at 6a33df9b; S11-A1/S11-C did not touch it; D2 does not either)')
rep('verified equal at BASE 6a33df9b; also covered by FROZEN below', 'verified equal at BASE 7fdcbc04; also covered by FROZEN below')
n0 = len(re.findall(r'refs/heads/fa72/d2(?![-\w])', s))
if n0 != 3: sys.exit(f'BRANCH REF COUNT {n0} != 3')
s = re.sub(r'refs/heads/fa72/d2(?![-\w])', 'refs/heads/fa72/d2-r1', s)
rep('is not on fa72/d2 at $EXPECT_HEAD', 'is not on fa72/d2-r1 at $EXPECT_HEAD')
rep('#   * candidate = ONE D2 gate commit on BASE 6a33df9b (branch fa72/d2 in SRC=worktrees/fa72-d2)',
    '#   * candidate = ONE D2 commit (rebased; 8 blobs = gated 6e3f86ce) on BASE 7fdcbc04 (branch fa72/d2-r1 in SRC=worktrees/fa72-d2)')
rep('contract unchanged (blob bd715150 at BASE and HEAD)', 'contract unchanged by D2 (blob 1a5deca5 at BASE and HEAD)')
rep('#   * LAND_REF refs/remotes/origin/land/s10d2 is a fill: `none` (no land ref pushed; not checked) or the pushed 40-hex head',
    '#   * LAND_REF refs/remotes/origin/land/s10d2 must equal EXPECT_HEAD 144269d1 (pushed; fetched into SRC)')
rep('# ---- pins: head / tree / D2 blob / hook / land-ref pins are filled by the parent AFTER the D2 gate commit; placeholders are refused.',
    '# ---- pins: all filled (parent 08:53 FILL + REBASE); the placeholder refusal stays as a guard.')
rep('# clone source (read-only here): branch fa72/d2 at the D2 gate commit, clean, lefthook hooks', '# clone source (read-only here): branch fa72/d2-r1 at 144269d1 (rebased D2), clean, lefthook hooks')
rep('# Fill (parent, README.md fill table): every __FILL_*__ below from the D2 gate summary execution/fa72efb2/s10d2/d2_gate_summary.md.',
    '# Filled (parent 08:53, README.md fill table): values re-derived by `git rev-parse` / `sha256sum` in SRC at 144269d1.')
if '__FILL_' in s.split('case "$BASE_HEAD')[0]: sys.exit('FILL LEFT in the pin block')
open(O, 'w').write(s)
print('OK')
