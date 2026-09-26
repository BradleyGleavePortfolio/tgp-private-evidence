#!/usr/bin/env bash
# S10-D D2 real-PG proof — execution binding v2 (EXEC-FA72EFB2). SOURCE ONLY: NOT RUN, NOT GRANTED.
# Derived by MINIMUM substitution from the accepted S10-C binding execution/d3a9f701/s10c/binding/v6/s10c-pg-proof.sh
# (sha256 1bb4b564…483d; ran rc 0, 32/32 on the S10-B harness). Full diff in DELTA-from-s10c-v6.diff; README.md lists every delta.
# D2 deltas (everything else carried unchanged):
#   * fa72efb2 runtime (pg17 dist + PROVENANCE, npm/xdg caches), lock inode 686480, tool/node/psql/nm pins from
#     execution/fa72efb2/runtime/raw/rt-setup.log; donor node_modules = worktrees/fa72-s11a1/node_modules (generated from the
#     same S10-B schema d6d01f54), so the "clone client differs from donor" guard is INVERTED: clone client == donor client
#   * candidate = TWO D2 commits on BASE 7fdcbc04 (branch fa72/d2-r1 in SRC=worktrees/fa72-d2): 144269d1 (the v1 candidate: 8 added paths,
#     blobs = gated 6e3f86ce) + 275e458c (diagnose-fix after PROOF_V1_FINDING: ONLY the pg spec modified, 9 it()); pre-lock git checks read SRC;
#     under the lock the runner makes the FRESH clone W=worktrees/fa72-d2-pg2 (shared objects, no hooks, detached at the
#     head) and a real `cp -a` copy of the donor node_modules into it (no npm, no prisma generate); W must not pre-exist
#   * BASE..HEAD = exactly the 8 D2 paths; contract unchanged by D2 (blob 1a5deca5 at BASE and HEAD); no prisma change
#     (migrations tree 7b6fe0ed, 173); FROZEN S10-A/S10-B bytes at HEAD except the one premise edit 7746a877 made to
#     test/scout/induction/manifest-registry.spec.ts (pinned to its BASE blob)
#   * lane clusters/s10d2-v2 + run/s10d2-v2 on 55649 (fresh; the retained stopped v1 lane clusters/s10d2 is an other lane:
#     fingerprinted, never started, must be unchanged), REUSING the S10-B harness literals; refused lane ports 55646/55647 plus 55648
#     (the S11 lane binding in this runtime); no retained s10-b lane exists in this runtime, so its must-exist requirement is
#     dropped (if one appears it is fingerprinted, must be stopped and unchanged, and is never the lane)
#   * runs ONLY `jest -c jest.config.js --runInBand --ci --runTestsByPath test/scout/s10/s10-unseen.pg.spec.ts` once;
#     it() count pinned at HEAD (9); the only skip form allowed is the file-level env switch in its pinned live form
#   * LAND_REF refs/remotes/origin/land/s10d2 must equal EXPECT_HEAD 275e458c (pushed by the parent before launch; fetched into SRC)
# R1 ordering (parent 08:29): lock -> under-lock rechecks -> preflight -> clone/checkout/donor copy + verification -> STARTED;
# a failure before STARTED is PRESTART_REFUSED (not consumed; partial W removed iff this run created it).
# Carried unchanged: single canonical lock holder (nonblocking flock fd 9 before any state change, held through stop, post
# checks and receipt hashing; lock file never deleted); ALL pin/shape preconditions before the lock and the sentinel
# (prelock.log, PRELOCK_REFUSED does not consume the run); symlink-aware sentinel; under-lock rechecks; first nonzero
# stops; the only cleanup is a bounded fixture stop when this run started the postmaster; data dir RETAINED after stop.
# Pipefail rule (S9C-PROOF-1): never `cmd | grep -q`; producer output is captured first, then grepped as a here-string.
# Inner stage bounds: clone 120+120 + cp 600 + init 60 + start 60 + bootstrap 900 + identity 8x15 + jest 1500 + stop 75
#   = 3555 s soft sum.
# Usage (under the separate single-run PG grant, after the D2 gate commit and fill):
#   timeout -k 30 4500 bash /home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s10d2/binding/v2/d2-pg-proof.sh
# Filled (v1: parent 08:53; v2: re-pinned to 275e458c, README.md): values re-derived by `git rev-parse` / `sha256sum` in SRC.
# Placeholders are refused pre-lock (rc 70, run not consumed).
set -uo pipefail
D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s10d2/binding/v2   # D2 binding v2 (from D2 binding v1)
RUNTIME_ROOT=/home/user/workspace/execution/fa72efb2/runtime                     # fa72efb2 runtime namespace (evidence execution/fa72efb2/runtime/raw/rt-setup.log); the fixture carries the same literal and is cross-checked below
SRC=/home/user/workspace/worktrees/fa72-d2                                        # clone source (read-only here): branch fa72/d2-r1 at 275e458c (D2 + diagnose-fix), clean, lefthook hooks
W=/home/user/workspace/worktrees/fa72-d2-pg2                                     # the fresh clone this run creates under the lock (must not exist)
DONOR_NM=/home/user/workspace/worktrees/fa72-s11a1/node_modules                  # read-only donor (npm ci + prisma generate by rt-setup-fa72efb2.sh from the S10-B schema); copied, never regenerated
R=$D/run; LOG=$R/d2-pg-proof.log; SENT=$R/d2-pg-proof.sentinel; JLOG=$R/jest.log
LOCK=/home/user/workspace/execution/test-validation.lock
# ---- pins: all filled (parent 08:53 FILL + REBASE); the placeholder refusal stays as a guard.
BASE_HEAD=7fdcbc044dba1747d0db2f2750ced951f3b6b752                     # integration/importer tip after S11-A1 3db615c0 + S11-C 7fdcbc04 landed; D2 rebased onto it (parent 08:53)
BASE_TREE=a802231ee1f4dd693284b349e7eb078b3688e8d5                     # git rev-parse "$BASE_HEAD^{tree}"
S10B_HEAD=a2c74e904ff227b16881c77ee5a08bd006972d48                             # S10-B landing commit; ancestor of BASE_HEAD (checked)
HARNESS_BASE_HEAD=a4af8e330bd4d6f882f0aebd411200b76d651aba                     # kept: G2_S10B_BASE_HEAD / bootstrap BASE_HEAD literal; ancestor of BASE_HEAD (checked)
EXPECT_HEAD=275e458ca5a6b3684bb6ec83edb2a854056a6fd0                   # D2 diagnose-fix commit on fa72/d2-r1 (pg spec only); PR #561
D2_V1_HEAD=144269d13db5275a2d6689bebb2f7dca8367593c                    # HEAD^: the v1 candidate (8 added D2 paths = gated 6e3f86ce); its parent is BASE_HEAD
EXPECT_TREE=6267ef6a57225af187f5a21fb8a2c3cc3fd6103e                   # git rev-parse HEAD^{tree}
EXPECT_DELTA="src/scout/induction/sources/s10_unseen.json src/scout/reconstruct/native/sources/s10_unseen.json src/scout/reconstruct/sources/s10_unseen.json test/fixtures/scout/s10_unseen/signer-test-key.json test/fixtures/scout/s10_unseen/staged-rows.json test/fixtures/scout/s10_unseen/statements.json test/scout/s10/s10-unseen.e2e.spec.ts test/scout/s10/s10-unseen.pg.spec.ts"   # exactly the 8 D2 paths (sorted); must equal D2_OWNED and the gate R40 `git diff --name-only`
EXPECT_CONTRACT_STATE=unchanged                                  # D2 changes no contract (the 8 paths exclude docs/); kept as the template mechanism
EXPECT_CONTRACT_BLOB=1a5deca500d0dd9422edaca2f9883ed57c33a0e8          # = BASE_CONTRACT_BLOB (unchanged by D2)
EXPECT_HOOK_PRECOMMIT_SHA=54aa5cd8b77c4b8549c8d7c40bd85e5ffc6406a6018661fed4a876f7c58de3f9   # sha256 $SRC/.git/hooks/pre-commit (lefthook)
EXPECT_HOOK_COMMITMSG_SHA=dc998a5e5776895512ee9860763444c1cb9eafa9d64e181c6cbe923c59e11be0   # sha256 $SRC/.git/hooks/commit-msg (lefthook)
EXPECT_S10C_SPEC_BLOB=50a0deae0e9eee45ec093e87769949f47efd3d8e                                  # landed S10-C spec (BASE blob; not run here, pinned unchanged)
# the 8 D2 path blobs at HEAD (D2 gate summary "sha256 per path post-format" + `git rev-parse HEAD:<path>`)
EXPECT_D2_BLOB_INDUCTION=4e21d522772adbde19d8ee3419b30039ec250475          # src/scout/induction/sources/s10_unseen.json
EXPECT_D2_BLOB_NATIVE=6b8695c8b7504e7623bf3b61ef686f3dd4612f9b                # src/scout/reconstruct/native/sources/s10_unseen.json
EXPECT_D2_BLOB_MAPPING=94dcc8198c4b7a6ed27c6bfcf3a57d201effd879              # src/scout/reconstruct/sources/s10_unseen.json
EXPECT_D2_BLOB_KEY=4d5bf92e157f7d44b5f97b92e41fd3ac4b2a88f1                      # test/fixtures/scout/s10_unseen/signer-test-key.json
EXPECT_D2_BLOB_ROWS=94e7f5670e18f88fd7bcc8a728b537683d896f1f                    # test/fixtures/scout/s10_unseen/staged-rows.json
EXPECT_D2_BLOB_STATEMENTS=90d644b4bbb48aec86b293d2a39eb02a670884fe        # test/fixtures/scout/s10_unseen/statements.json
EXPECT_D2_BLOB_E2E=41df91ec0c020c16364956a2abfd9983d6f0f41c                      # test/scout/s10/s10-unseen.e2e.spec.ts
EXPECT_D2_BLOB_PG=352cb34027766b126bb06e6c5b4f164ace2afa26                        # test/scout/s10/s10-unseen.pg.spec.ts (the spec this run executes; 275e458c; v1 074b0fa0)
LAND_REF=refs/remotes/origin/land/s10d2                   # only if the parent pushes a land ref (seen in SRC as refs/remotes/origin/land/s10d2)
EXPECT_LAND_REF=275e458ca5a6b3684bb6ec83edb2a854056a6fd0   # the 40-hex $LAND_REF (refs/remotes/origin/land/s10d2) must equal (= EXPECT_HEAD)
EXPECT_MIGRATIONS_TREE=7b6fe0eda137ab1e3013b8a7c3b0c7637f69a521                # S10-B migrations tree (173); D2 changes no prisma, so BASE and HEAD both carry it
BASE_CONTRACT_BLOB=1a5deca500d0dd9422edaca2f9883ed57c33a0e8            # importer contract blob at BASE 7fdcbc04 (S11-C changed it from bd715150)
# landed S10-B proof files (s10b/gate/HEAD-a2c74e904ff2.txt); frozen through S10-C and D2 (verified equal at BASE 7fdcbc04; also covered by FROZEN below)
EXPECT_SPEC_BLOB=b89fec1cb9254a2475908154b1109f16585af0b0                      # test/rls-g2-s10b.spec.ts
EXPECT_DB_BLOB=3375f08ba0130bee8f20fb8a4f395a8fac4a5e10                        # test/utils/g2-s10b-db.ts
EXPECT_PGH_BLOB=7cf6d63308d6a2150626ad89d759366a6644d2ec                       # test/utils/g2-s10b-pg-harness.ts
EXPECT_HARNESS_BLOB=9956aff77a5664e748a30673760c1a3824c44a7e                   # test/utils/g2-s10b-harness.ts
EXPECT_WORKER_BLOB=e0af841268a03dbe5fc3db25e7e57a7bfe9f275f                    # test/utils/g2-s10b-worker.cjs
EXPECT_FIXTURES_BLOB=8055dbefa6a4008a6e04f5f851c8d535f755dee1                  # test/utils/g2-s10b-fixtures.ts
EXPECT_BOOTSTRAP_BLOB=3230568302506413d71507c5181525d5af674e45                 # test/utils/g2-s10b-bootstrap.sh (sha256 3fc3f21d…80df, mode 755)
EXPECT_SCHEMA_BLOB=f86c1f5df722e855047899abd483f621b42dabe0                    # prisma/schema.prisma (S10-B, sha256 d6d01f54…eb96)
EXPECT_MIGRATION_BLOB=695c694d30aa46f08e761a44d54797d80a5e318d                 # S10-B migration.sql (sha256 345f12de…aa15)
EXPECT_DOWN_BLOB=b5e5243ef99be16794972e63fc956378e47ca7fb                      # S10-B down.sql (sha256 aee7c735…6905)
EXPECT_FIXTURE_SHA=6de009d72d71f1ce905af3b1835078a9f5d270606c37343a79a934adcd5ae4d0                                             # sha256 of binding/v2/d2-fixture.sh (builder-filled; README.md)
FROZEN=/home/user/workspace/repos/tgp-private-evidence/execution/d3a9f701/s10c/gate/FROZEN.sha256
FROZEN_P_PATH=test/scout/induction/manifest-registry.spec.ts   # the ONE FROZEN path the landed premise P (7746a877) re-stated; ancestor of BASE
FROZEN_P_BLOB=9b5de3743ec27181b58e8277591a6c8c1a8adc65          # its blob at BASE 7fdcbc04 (= at 6a33df9b; S11-A1/S11-C did not touch it; D2 does not either)
FROZEN_SHA=e9c71f09462a25e36baafe0fa90ba012ef6b3f384f04b3951fb1c7bbf1f4be21
S10B_MIGRATION=20270124000000_scout_run_observation_expand
EXPECT_MIGRATIONS=173
# the 8 D2 paths (execution/d3a9f701/s10d/d2.diff: 8 new 100644 files; D2_GATE_GRANT.md); EXPECT_DELTA must be exactly these
D2_OWNED="src/scout/induction/sources/s10_unseen.json src/scout/reconstruct/native/sources/s10_unseen.json src/scout/reconstruct/sources/s10_unseen.json test/fixtures/scout/s10_unseen/signer-test-key.json test/fixtures/scout/s10_unseen/staged-rows.json test/fixtures/scout/s10_unseen/statements.json test/scout/s10/s10-unseen.e2e.spec.ts test/scout/s10/s10-unseen.pg.spec.ts"
D2_SPEC=test/scout/s10/s10-unseen.pg.spec.ts
CONTRACT=docs/contracts/importer-openapi.json
# ---- tool pins: from the fa72efb2 runtime setup log raw/rt-setup.log (compare only, never adjusted at run time); byte-identical to the S10-C v6 pins.
EXPECT_POSTGRES_SHA=23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a
EXPECT_INITDB_SHA=b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a
EXPECT_PGCTL_SHA=af53d826845af4679a0aaba2bda319f5e527f3b94f3794c67fa174049c9b9401
PSQL=/usr/lib/postgresql/18/bin/psql                # CB1: the real client binary, not the /usr/bin/psql pg_wrapper dispatcher
EXPECT_PSQL_REAL_SHA=d1108fdb45b87f2313d7acfbb91a0a65ca97c6c2195f15d8ae9295121029ef67
EXPECT_TESTS_S10B=24                                # it() count in the frozen test/rls-g2-s10b.spec.ts (re-checked at HEAD; NOT run here)
EXPECT_TESTS_S10C=8                                 # it() count in the landed test/rls-g2-s10c.spec.ts (re-checked at HEAD; NOT run here)
EXPECT_TESTS_D2=9                                   # it() count in test/scout/s10/s10-unseen.pg.spec.ts (R39 a-f, R41, R27 live, (h) roster; builder count on 352cb340 at 275e458c; re-checked at HEAD)
EXPECT_TESTS=$EXPECT_TESTS_D2                       # 9: the one jest run must print "Tests: 9 passed, 9 total"
EXPECT_LOCK_INODE=686480                            # fa72efb2 canonical lock (WORKER_RULES 3; rt-setup.log START "lock inode=686480")
EXPECT_NODE_SHA=a03953a7b16bff002b94d6fb58ada900b68241cbcaee6efc400b20dadd36dddc       # node v20.x
EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44    # node_modules/.package-lock.json (rt-setup NM_OK hidden_lock=; donor and copy)
EXPECT_NM_CLIENT_SHA=2c819c8a8e2fd4afb59578893122b8e9c406bc1dc7821e643e7ef359c04aa56c         # $W/node_modules/.prisma/client/index.d.ts = the copied donor client (rt-setup NM_OK client_index_dts=)
EXPECT_NM_CLIENT_SCHEMA_SHA=aca7a558cd379c154e947447782f2858a9f898039298e34c30b886947aed42e5   # $W/node_modules/.prisma/client/schema.prisma (rt-setup NM_OK client_schema=)
DONOR_CLIENT_SHA=2c819c8a8e2fd4afb59578893122b8e9c406bc1dc7821e643e7ef359c04aa56c      # donor client, generated from the S10-B schema d6d01f54; INVERTED guard: EXPECT_NM_CLIENT_SHA must EQUAL it
DONOR_CLIENT_SCHEMA_SHA=aca7a558cd379c154e947447782f2858a9f898039298e34c30b886947aed42e5
EXPECT_PRISMA_CLI=6.19.3                            # rt-setup NM_OK prisma=
EXPECT_SCHEMA_SHA=d6d01f546f6c7988d93bdd60588e421bf6ff0a56b312f85eee962e0a6be0eb96   # prisma/schema.prisma (S10-B bytes; D2 changes no prisma) (never reflowed)
EXPECT_PKG_LOCK_SHA=b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55   # package-lock.json (unchanged since 93389265)
DIST=$RUNTIME_ROOT/pg17/dist; CLUSTERS=$RUNTIME_ROOT/clusters; LANE=$CLUSTERS/s10d2-v2; SOCK=$RUNTIME_ROOT/run/s10d2-v2
S10B_LANE=$CLUSTERS/s10-b                          # never the lane; absent in this runtime; if present it must stay stopped and unchanged (never started, never destroyed here)
PORT=55649; DBNAME=g2_s10b_disposable; ADMIN=s10b_super; FIXPASS=s10b_local_synthetic   # S10-B harness literals reused (review B B4); only port + data dir differ
REFUSED_LANE_PORTS="55646 55647 55648"              # S9-C / S10-B / S11 (fa72efb2 s11a1 binding) lane ports: never this lane, zero listeners before and after
MARKER=s10b-disposable-pg17; DB_MARKER=s10b-g2-run-observation-synthetic-disposable-fixture-safe-to-drop
FIX=$D/d2-fixture.sh
export GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1 NODE_OPTIONS=--max-old-space-size=4096 CHECKPOINT_DISABLE=1 \
       PRISMA_HIDE_UPDATE_MESSAGE=1 PRISMA_GENERATE_SKIP_AUTOINSTALL=1 npm_config_offline=true npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false \
       npm_config_cache=$RUNTIME_ROOT/npm-cache XDG_CACHE_HOME=$RUNTIME_ROOT/xdg-cache
# S10-B-harness identity (reused by the D2 spec): exactly the G2_S10B_* names the guard/harness/bootstrap read (G2_S10B_DATABASE_URL, _CONFIRM, _PASSWORD,
# _PSQL, _DATA_DIRECTORY, _SERVER_VERSION, _CANDIDATE_HEAD). G2_S10B_BASE_HEAD is a source literal, never read from env;
# G2_S10B_WORKER is set by the harness for its own children only. Every other inherited G2_* is unset.
for v in $(compgen -e | grep -E '^G2_' | grep -vE '^G2_S10B_'); do unset "$v"; done
unset G2_S10B_WORKER
export G2_S10B_DATABASE_URL="postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=4" \
       G2_S10B_CONFIRM="$DBNAME:$PORT" G2_S10B_PASSWORD=$FIXPASS G2_S10B_PSQL=$PSQL \
       G2_S10B_DATA_DIRECTORY=$LANE/pg-data G2_S10B_SERVER_VERSION=170006 \
       G2_S10B_CANDIDATE_HEAD=$EXPECT_HEAD
export D2_RUNNER_PID=$$ D2_STOP_TIMEOUT=45
mkdir -p "$R"
# sentinel: an occupied path (file or any symlink, dangling or not) refuses (review A B-1 analogue)
{ [ -e "$SENT" ] || [ -L "$SENT" ]; } && { echo "REFUSED: $SENT exists; this proof runs once, no retry" >&2; exit 76; }
{ [ -e "$R/STARTED" ] || [ -L "$R/STARTED" ]; } && { echo "REFUSED: $R/STARTED exists; this proof runs once, no retry" >&2; exit 76; }
ts(){ date -u +%FT%TZ; }
log(){ echo "$*" | tee -a "$LOG"; }
sha(){ sha256sum "$1" | cut -c1-64; }
# ---- preconditions (read-only) run BEFORE the lock and before anything can write the sentinel (review B1): a stale pin
# or shape mismatch exits here with PRELOCK_REFUSED in $R/prelock.log and does NOT consume the single run. fail()/finish()
# are redefined after the lock is taken; everything below the lock re-verifies only what could move in between.
STAGE=preconditions-prelock; STARTED=0; LOG=$R/prelock.log
fail(){ log "PRELOCK_REFUSED stage=$STAGE rc=$1 $(ts) (no lock taken, no sentinel written; the run is not consumed)"; exit "$1"; }
log "PRELOCK_START $(ts) pid=$$ user=$(id -un) head_expect=$EXPECT_HEAD fixture_expect=$EXPECT_FIXTURE_SHA"
D2_BLOBS="$EXPECT_D2_BLOB_INDUCTION$EXPECT_D2_BLOB_NATIVE$EXPECT_D2_BLOB_MAPPING$EXPECT_D2_BLOB_KEY$EXPECT_D2_BLOB_ROWS$EXPECT_D2_BLOB_STATEMENTS$EXPECT_D2_BLOB_E2E$EXPECT_D2_BLOB_PG"
case "$BASE_HEAD$BASE_TREE$EXPECT_HEAD$EXPECT_TREE$EXPECT_DELTA$EXPECT_CONTRACT_STATE$EXPECT_CONTRACT_BLOB$EXPECT_S10C_SPEC_BLOB$EXPECT_HOOK_PRECOMMIT_SHA$EXPECT_HOOK_COMMITMSG_SHA$EXPECT_FIXTURE_SHA$FROZEN_SHA$EXPECT_NM_CLIENT_SHA$EXPECT_NM_CLIENT_SCHEMA_SHA$PORT$RUNTIME_ROOT$EXPECT_POSTGRES_SHA$EXPECT_INITDB_SHA$EXPECT_PGCTL_SHA$EXPECT_PSQL_REAL_SHA$EXPECT_NODE_SHA$EXPECT_NM_LOCK_SHA$D2_BLOBS$EXPECT_LAND_REF" in *__*) log "PRECONDITION_FAIL pins not filled (proposal stage: head, tree, D2 blobs, hooks or land ref; README.md fill table)"; fail 70;; esac
for v in BASE_HEAD BASE_TREE EXPECT_HEAD EXPECT_TREE EXPECT_CONTRACT_BLOB EXPECT_S10C_SPEC_BLOB EXPECT_D2_BLOB_INDUCTION EXPECT_D2_BLOB_NATIVE EXPECT_D2_BLOB_MAPPING EXPECT_D2_BLOB_KEY EXPECT_D2_BLOB_ROWS EXPECT_D2_BLOB_STATEMENTS EXPECT_D2_BLOB_E2E EXPECT_D2_BLOB_PG FROZEN_P_BLOB D2_V1_HEAD; do [[ "${!v}" =~ ^[0-9a-f]{40}$ ]] || { log "PRECONDITION_FAIL $v not 40-hex (${!v})"; fail 70; }; done
for v in EXPECT_NM_CLIENT_SHA EXPECT_NM_CLIENT_SCHEMA_SHA EXPECT_HOOK_PRECOMMIT_SHA EXPECT_HOOK_COMMITMSG_SHA EXPECT_FIXTURE_SHA FROZEN_SHA; do [[ "${!v}" =~ ^[0-9a-f]{64}$ ]] || { log "PRECONDITION_FAIL $v not 64-hex (${!v})"; fail 70; }; done
case "$EXPECT_LAND_REF" in none) ;; *) [ "$EXPECT_LAND_REF" = "$EXPECT_HEAD" ] || { log "PRECONDITION_FAIL EXPECT_LAND_REF must be none or = EXPECT_HEAD ($EXPECT_LAND_REF)"; fail 70; };; esac
# lane refusals (review B B4): never an s10-b lane, never the S9-C/S10-B/S11 ports
[ "$LANE" = "$CLUSTERS/s10d2-v2" ] && [ "$LANE" != "$S10B_LANE" ] && [ "$SOCK" = "$RUNTIME_ROOT/run/s10d2-v2" ] || { log "PRECONDITION_FAIL lane $LANE / socket $SOCK is not clusters/s10d2-v2 + run/s10d2-v2"; fail 70; }
for rp in $REFUSED_LANE_PORTS; do [ "$PORT" != "$rp" ] || { log "PRECONDITION_FAIL lane port $PORT is a refused lane port ($REFUSED_LANE_PORTS)"; fail 70; }; done
[ "$PORT" = 55649 ] || { log "PRECONDITION_FAIL lane port $PORT != 55649"; fail 70; }
[ "$G2_S10B_DATA_DIRECTORY" = "$LANE/pg-data" ] && [ "$G2_S10B_CONFIRM" = "$DBNAME:$PORT" ] || { log "PRECONDITION_FAIL harness env not bound to the s10d2-v2 lane"; fail 70; }
# (no retained S10-B lane in the fa72efb2 runtime: the template's must-exist check is dropped; a present one must be stopped)
[ ! -L "$S10B_LANE" ] || { log "PRECONDITION_FAIL $S10B_LANE is a symlink"; fail 70; }
{ [ -e "$S10B_LANE/pg-data/postmaster.pid" ] || [ -L "$S10B_LANE/pg-data/postmaster.pid" ]; } && { log "PRECONDITION_FAIL an S10-B lane has a postmaster.pid (running or unclean); refusing"; fail 70; }
case "$EXPECT_CONTRACT_STATE" in changed) [ "$EXPECT_CONTRACT_BLOB" != "$BASE_CONTRACT_BLOB" ] || { log "PRECONDITION_FAIL contract_state=changed but blob = base"; fail 70; };;
  unchanged) [ "$EXPECT_CONTRACT_BLOB" = "$BASE_CONTRACT_BLOB" ] || { log "PRECONDITION_FAIL contract_state=unchanged but blob != $BASE_CONTRACT_BLOB"; fail 70; };;
  *) log "PRECONDITION_FAIL EXPECT_CONTRACT_STATE must be changed|unchanged ($EXPECT_CONTRACT_STATE)"; fail 70;; esac
WANT_DELTA=$(printf '%s\n' $D2_OWNED $( [ "$EXPECT_CONTRACT_STATE" = changed ] && echo "$CONTRACT") | sort | tr '\n' ' ' | sed 's/ $//')
EXPECT_DELTA=$(echo $EXPECT_DELTA)
[ "$EXPECT_DELTA" = "$WANT_DELTA" ] || { log "PRECONDITION_FAIL filled EXPECT_DELTA [$EXPECT_DELTA] != the 8 D2 paths (+ contract iff changed) [$WANT_DELTA]"; fail 70; }
[ "$EXPECT_HEAD" != "$BASE_HEAD" ] || { log "PRECONDITION_FAIL EXPECT_HEAD is the base, not a candidate"; fail 70; }
[ "$EXPECT_CONTRACT_STATE" = unchanged ] || { log "PRECONDITION_FAIL D2 changes no contract (EXPECT_CONTRACT_STATE=$EXPECT_CONTRACT_STATE)"; fail 70; }
[ "$EXPECT_NM_CLIENT_SHA" = "$DONOR_CLIENT_SHA" ] && [ "$EXPECT_NM_CLIENT_SCHEMA_SHA" = "$DONOR_CLIENT_SCHEMA_SHA" ] || { log "PRECONDITION_FAIL INVERTED guard: the donor was generated from the S10-B schema, so the expected clone client must EQUAL the donor client"; fail 70; }
[ "$(sha "$FIX")" = "$EXPECT_FIXTURE_SHA" ] || { log "PRECONDITION_FAIL fixture sha256 mismatch"; fail 70; }
# the fixture must carry exactly this runner's lane constants (whole-line, literal): one runtime root, one port, one marker
FIXTXT=$(cat "$FIX")
grep -qx "RUNTIME_ROOT=$RUNTIME_ROOT" <<<"$FIXTXT" || { log "PRECONDITION_FAIL fixture RUNTIME_ROOT line != $RUNTIME_ROOT"; fail 70; }
grep -qx "PORT=$PORT; SUPER=$ADMIN; PASS=$FIXPASS; MARKER=$MARKER" <<<"$FIXTXT" || { log "PRECONDITION_FAIL fixture PORT/SUPER/PASS/MARKER line != runner (PORT=$PORT ADMIN=$ADMIN MARKER=$MARKER)"; fail 70; }
grep -qx "LANE=\$RUNTIME_ROOT/clusters/s10d2-v2" <<<"$FIXTXT" && grep -qx "DATA=\$LANE/pg-data; LOG=\$LANE/pg.log; SOCK=\$RUNTIME_ROOT/run/s10d2-v2" <<<"$FIXTXT" || { log "PRECONDITION_FAIL fixture lane/socket lines != clusters/s10d2-v2 + run/s10d2-v2"; fail 70; }
grep -qF 'case "$PORT" in 55646|55647|55648)' <<<"$FIXTXT" && grep -qF 'grep -qx "port = $PORT"' <<<"$FIXTXT" || { log "PRECONDITION_FAIL fixture lacks the refused-port / port-bound marker checks"; fail 70; }
grep -qF 'grep -q d2-pg-proof.sh "/proc/$D2_RUNNER_PID/cmdline"' <<<"$FIXTXT" || { log "PRECONDITION_FAIL fixture does not require the D2 runner"; fail 70; }
# clone source: a real repository at the committed candidate; the fresh clone path and the lane must not exist yet
[ -d "$SRC/.git" ] && [ ! -L "$SRC/.git" ] && [ ! -L "$SRC" ] || { log "PRECONDITION_FAIL $SRC/.git is not a real repository directory"; fail 70; }
[ "$(git -C "$SRC" rev-parse --verify -q refs/heads/fa72/d2-r1)" = "$EXPECT_HEAD" ] && [ "$(git -C "$SRC" symbolic-ref -q HEAD)" = refs/heads/fa72/d2-r1 ] || { log "PRECONDITION_FAIL $SRC is not on fa72/d2-r1 at $EXPECT_HEAD"; fail 70; }
case "$EXPECT_LAND_REF" in none) log "PRELOCK land_ref=none ($LAND_REF not checked: no land ref pushed)";;
  *) [ "$(git -C "$SRC" rev-parse --verify -q "$LAND_REF")" = "$EXPECT_HEAD" ] || { log "PRECONDITION_FAIL $LAND_REF != $EXPECT_HEAD"; fail 70; };; esac
{ [ -e "$W" ] || [ -L "$W" ]; } && { log "PRECONDITION_FAIL $W exists (fresh clone only; never reuse)"; fail 70; }
[ "$(git -C "$SRC" rev-parse HEAD)" = "$EXPECT_HEAD" ] || { log "PRECONDITION_FAIL HEAD != $EXPECT_HEAD"; fail 70; }
[ "$(git -C "$SRC" rev-parse 'HEAD^{tree}')" = "$EXPECT_TREE" ] || { log "PRECONDITION_FAIL tree mismatch"; fail 70; }
[ "$(git -C "$SRC" rev-parse "$BASE_HEAD^{tree}")" = "$BASE_TREE" ] || { log "PRECONDITION_FAIL base tree mismatch"; fail 70; }
[ "$(git -C "$SRC" rev-parse HEAD^)" = "$D2_V1_HEAD" ] && [ "$(git -C "$SRC" rev-parse "$D2_V1_HEAD^")" = "$BASE_HEAD" ] && [ "$(git -C "$SRC" rev-list --count "$BASE_HEAD..HEAD")" = 2 ] || { log "PRECONDITION_FAIL chain != $BASE_HEAD -> $D2_V1_HEAD -> HEAD (exactly two D2 commits on BASE)"; fail 70; }
V1D=$(git -C "$SRC" diff --name-status --no-renames "$D2_V1_HEAD" HEAD | tr '\t\n' '  ' | sed 's/ $//'); [ "$V1D" = "M $D2_SPEC" ] || { log "PRECONDITION_FAIL $D2_V1_HEAD..HEAD [$V1D] != the pg spec only (modified)"; fail 70; }
git -C "$SRC" merge-base --is-ancestor "$S10B_HEAD" "$BASE_HEAD" || { log "PRECONDITION_FAIL S10-B landing $S10B_HEAD not an ancestor of $BASE_HEAD"; fail 70; }
git -C "$SRC" merge-base --is-ancestor "$HARNESS_BASE_HEAD" "$BASE_HEAD" || { log "PRECONDITION_FAIL harness base $HARNESS_BASE_HEAD not an ancestor of $BASE_HEAD"; fail 70; }
# exact delta: BASE..HEAD = the 8 D2 paths, all added as 100644 files; FROZEN S10-A/S10-B bytes at HEAD (one premise-P exception)
DELTA=$(git -C "$SRC" diff --name-only "$BASE_HEAD" HEAD | sort | tr '\n' ' ' | sed 's/ $//')
[ "$DELTA" = "$EXPECT_DELTA" ] || { log "PRECONDITION_FAIL BASE..HEAD delta [$DELTA] != receipt delta [$EXPECT_DELTA]"; fail 70; }
DADD=$(git -C "$SRC" diff --name-only --diff-filter=A "$BASE_HEAD" HEAD | sort | tr '\n' ' ' | sed 's/ $//'); [ "$DADD" = "$EXPECT_DELTA" ] || { log "PRECONDITION_FAIL D2 delta is not 8 pure additions [$DADD]"; fail 70; }
DMODES=$(git -C "$SRC" ls-tree HEAD -- $EXPECT_DELTA | awk '{print $1}' | sort -u); [ "$DMODES" = 100644 ] || { log "PRECONDITION_FAIL D2 paths not all mode 100644 [$(echo $DMODES)]"; fail 70; }
for pin in "src/scout/induction/sources/s10_unseen.json $EXPECT_D2_BLOB_INDUCTION" "src/scout/reconstruct/native/sources/s10_unseen.json $EXPECT_D2_BLOB_NATIVE" \
           "src/scout/reconstruct/sources/s10_unseen.json $EXPECT_D2_BLOB_MAPPING" "test/fixtures/scout/s10_unseen/signer-test-key.json $EXPECT_D2_BLOB_KEY" \
           "test/fixtures/scout/s10_unseen/staged-rows.json $EXPECT_D2_BLOB_ROWS" "test/fixtures/scout/s10_unseen/statements.json $EXPECT_D2_BLOB_STATEMENTS" \
           "test/scout/s10/s10-unseen.e2e.spec.ts $EXPECT_D2_BLOB_E2E" "$D2_SPEC $EXPECT_D2_BLOB_PG"; do set -- $pin
  [ "$(git -C "$SRC" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL D2 path $1 blob != gate pin $2"; fail 70; }; done
[ -f "$FROZEN" ] && [ ! -L "$FROZEN" ] && [ "$(sha "$FROZEN")" = "$FROZEN_SHA" ] || { log "PRECONDITION_FAIL FROZEN file absent, a symlink or sha mismatch"; fail 70; }
NF=0; while read -r tag s b p; do [ "$tag" = FROZEN ] || continue; NF=$((NF+1))
  [ "$p" = "$FROZEN_P_PATH" ] && b=$FROZEN_P_BLOB   # premise P (7746a877, ancestor of BASE) re-stated this spec; pinned to its BASE blob
  [ "$(git -C "$SRC" rev-parse "HEAD:$p" 2>/dev/null)" = "$b" ] || { log "PRECONDITION_FAIL frozen $p at HEAD != $b"; fail 70; }
done < "$FROZEN"; [ "$NF" = 29 ] || { log "PRECONDITION_FAIL FROZEN lists $NF paths (want 29)"; fail 70; }
[ -z "$(git -C "$SRC" diff --name-only "$S10B_HEAD" HEAD -- prisma package.json package-lock.json 'test/utils/g2-s10b-*')" ] || { log "PRECONDITION_FAIL prisma / manifests / test/utils/g2-s10b-* differ from the S10-B landing (other test/utils files, e.g. S11-A1 g2-s11-*, may change)"; fail 70; }
[ "$(git -C "$SRC" rev-parse "HEAD:$CONTRACT")" = "$EXPECT_CONTRACT_BLOB" ] && [ "$(git -C "$SRC" rev-parse "$BASE_HEAD:$CONTRACT")" = "$BASE_CONTRACT_BLOB" ] || { log "PRECONDITION_FAIL contract blob BASE/HEAD != $BASE_CONTRACT_BLOB/$EXPECT_CONTRACT_BLOB ($EXPECT_CONTRACT_STATE)"; fail 70; }
# prisma: the candidate delta is exactly schema + the S10-B migration pair (vs BASE and vs the harness base); 173 dirs
PD=$(git -C "$SRC" diff --name-only "$HARNESS_BASE_HEAD" HEAD -- prisma | sort | tr '\n' ' ' | sed 's/ $//')
[ "$PD" = "prisma/migrations/$S10B_MIGRATION/down.sql prisma/migrations/$S10B_MIGRATION/migration.sql prisma/schema.prisma" ] || { log "PRECONDITION_FAIL prisma delta vs harness base [$PD]"; fail 70; }
[ -z "$(git -C "$SRC" diff --name-only --diff-filter=DMR "$BASE_HEAD" HEAD -- prisma/migrations)" ] || { log "PRECONDITION_FAIL an accepted migration was modified/renamed/deleted"; fail 70; }
[ -z "$(git -C "$SRC" diff --name-only "$HARNESS_BASE_HEAD" HEAD -- package.json package-lock.json)" ] || { log "PRECONDITION_FAIL dependency manifests differ from the harness base $HARNESS_BASE_HEAD (g2-s10b-bootstrap.sh L158 would refuse mid-run)"; fail 70; }
[ -z "$(git -C "$SRC" diff --name-only "$BASE_HEAD" HEAD -- prisma package.json package-lock.json)" ] || { log "PRECONDITION_FAIL prisma / dependency manifests differ from base (D2 changes no prisma)"; fail 70; }
DOCD=$(git -C "$SRC" diff --name-only "$BASE_HEAD" HEAD -- docs | tr '\n' ' ' | sed 's/ $//'); [ -z "$DOCD" ] || [ "$DOCD" = "$CONTRACT" ] || { log "PRECONDITION_FAIL docs delta [$DOCD] beyond the contract artifact"; fail 70; }
[ "$(git -C "$SRC" rev-parse "$BASE_HEAD:prisma/migrations")" = "$EXPECT_MIGRATIONS_TREE" ] || { log "PRECONDITION_FAIL BASE prisma/migrations tree != $EXPECT_MIGRATIONS_TREE (a migration landed after S10-B; the reused harness pins 173)"; fail 70; }
[ "$(git -C "$SRC" rev-parse HEAD:prisma/migrations)" = "$EXPECT_MIGRATIONS_TREE" ] || { log "PRECONDITION_FAIL HEAD prisma/migrations tree != $EXPECT_MIGRATIONS_TREE"; fail 70; }
HMIG=$(git -C "$SRC" ls-tree -d --name-only HEAD prisma/migrations/ | sed 's|^prisma/migrations/||' | sort)
[ "$(wc -l <<<"$HMIG")" = "$EXPECT_MIGRATIONS" ] && [ "$(tail -1 <<<"$HMIG")" = "$S10B_MIGRATION" ] || { log "PRECONDITION_FAIL HEAD migrations $(wc -l <<<"$HMIG")/$(tail -1 <<<"$HMIG") != $EXPECT_MIGRATIONS/$S10B_MIGRATION"; fail 70; }
# harness literals must match this runner (lane identity, base pin, migrations): read from the committed bytes at HEAD
BOOT_AT_HEAD=$(git -C "$SRC" show HEAD:test/utils/g2-s10b-bootstrap.sh) && DBTS_AT_HEAD=$(git -C "$SRC" show HEAD:test/utils/g2-s10b-db.ts) \
  && PGH_AT_HEAD=$(git -C "$SRC" show HEAD:test/utils/g2-s10b-pg-harness.ts) && SPEC_AT_HEAD=$(git -C "$SRC" show HEAD:test/rls-g2-s10b.spec.ts) \
  && SPEC_C_AT_HEAD=$(git -C "$SRC" show HEAD:test/rls-g2-s10c.spec.ts) && SPEC_D2_AT_HEAD=$(git -C "$SRC" show "HEAD:$D2_SPEC") || { log "PRECONDITION_FAIL cannot read harness bytes at HEAD"; fail 70; }
grep -qx "BASE_HEAD=$HARNESS_BASE_HEAD" <<<"$BOOT_AT_HEAD" || { log "PRECONDITION_FAIL bootstrap BASE_HEAD != $HARNESS_BASE_HEAD"; fail 70; }
grep -qx "CLUSTER_MARKER=$MARKER" <<<"$BOOT_AT_HEAD" && grep -qx "DB_MARKER=$DB_MARKER" <<<"$BOOT_AT_HEAD" \
  && grep -qx "EXPECTED_MIGRATIONS=$EXPECT_MIGRATIONS" <<<"$BOOT_AT_HEAD" && grep -qx "S10B_MIGRATION=$S10B_MIGRATION" <<<"$BOOT_AT_HEAD" || { log "PRECONDITION_FAIL bootstrap marker/migration literals != runner"; fail 70; }
grep -qF "export const EXPECTED_MIGRATIONS = $EXPECT_MIGRATIONS;" <<<"$PGH_AT_HEAD" && grep -qF "export const S10B_MIGRATION = '$S10B_MIGRATION';" <<<"$PGH_AT_HEAD" || { log "PRECONDITION_FAIL g2-s10b-pg-harness.ts migration literals != runner"; fail 70; }
grep -qF "G2_S10B_DATABASE = '$DBNAME'" <<<"$DBTS_AT_HEAD" && grep -qF "G2_S10B_ROLE = '$ADMIN'" <<<"$DBTS_AT_HEAD" \
  && grep -qF "G2_S10B_CLUSTER_MARKER = '$MARKER'" <<<"$DBTS_AT_HEAD" && grep -qF "'$DB_MARKER'" <<<"$DBTS_AT_HEAD" \
  && grep -qF "G2_S10B_BASE_HEAD = '$HARNESS_BASE_HEAD'" <<<"$DBTS_AT_HEAD" || { log "PRECONDITION_FAIL g2-s10b-db.ts literals != runner"; fail 70; }
! grep -qE "^ +'$PORT',\$" <<<"$DBTS_AT_HEAD" || { log "PRECONDITION_FAIL lane port $PORT is in the S10-B guard's REFUSED_PORTS"; fail 70; }
grep -qE "^ +'55646',\$" <<<"$DBTS_AT_HEAD" || { log "PRECONDITION_FAIL S9-C lane port 55646 missing from the S10-B guard's REFUSED_PORTS"; fail 70; }
NT=$(grep -cE '^\s*it\(' <<<"$SPEC_AT_HEAD" || true); [ "$NT" = "$EXPECT_TESTS_S10B" ] || { log "PRECONDITION_FAIL it() count in committed test/rls-g2-s10b.spec.ts $NT != $EXPECT_TESTS_S10B"; fail 70; }
NTC=$(grep -cE '^\s*it\(' <<<"$SPEC_C_AT_HEAD" || true); [ "$NTC" = "$EXPECT_TESTS_S10C" ] || { log "PRECONDITION_FAIL it() count in committed test/rls-g2-s10c.spec.ts $NTC != $EXPECT_TESTS_S10C"; fail 70; }
for sp in "$SPEC_AT_HEAD" "$SPEC_C_AT_HEAD"; do ! grep -qE '\b(it|describe|test)\.(skip|only|todo)\b|\b(xit|fit|xdescribe|fdescribe)\(' <<<"$sp" || { log "PRECONDITION_FAIL a live spec carries skip/only/todo"; fail 70; }; done
grep -qF "from './utils/g2-s10b-harness'" <<<"$SPEC_C_AT_HEAD" && ! grep -qE "g2-s10c-|G2_S10C_" <<<"$SPEC_C_AT_HEAD" || { log "PRECONDITION_FAIL test/rls-g2-s10c.spec.ts does not reuse the S10-B harness (or references an S10-C harness)"; fail 70; }
# the D2 spec (the ONLY spec this run executes): pinned it() count; the ONLY skip allowed is the file-level env switch in its
# pinned live form (LIVE iff G2_S10B_DATABASE_URL is a string, which this runner exports); no other skip/only/todo/each
NTD=$(grep -cE '^\s*it\(' <<<"$SPEC_D2_AT_HEAD" || true); [ "$NTD" = "$EXPECT_TESTS_D2" ] || { log "PRECONDITION_FAIL it() count in committed $D2_SPEC $NTD != $EXPECT_TESTS_D2"; fail 70; }
D2_LIVE_LINE="const LIVE = typeof process.env.G2_S10B_DATABASE_URL === 'string';"; D2_SUITE_LINE='const suite = LIVE ? describe : describe.skip;'
[ "$(grep -cxF "$D2_LIVE_LINE" <<<"$SPEC_D2_AT_HEAD" || true)" = 1 ] && [ "$(grep -cxF "$D2_SUITE_LINE" <<<"$SPEC_D2_AT_HEAD" || true)" = 1 ] \
  && [ "$(grep -cE '^suite\(' <<<"$SPEC_D2_AT_HEAD" || true)" = 1 ] && [ "$(grep -cF 'LIVE' <<<"$SPEC_D2_AT_HEAD" || true)" = 2 ] || { log "PRECONDITION_FAIL $D2_SPEC env switch is not the pinned live form (LIVE line, suite line, one suite( block)"; fail 70; }
SPEC_D2_REST=$(grep -vxF "$D2_SUITE_LINE" <<<"$SPEC_D2_AT_HEAD" | grep -vE '^\s*(\*|//|/\*)' || true)   # comment lines excluded (the header prose names `describe.skip`)
[ "$(grep -cE '^\s*test\(' <<<"$SPEC_D2_AT_HEAD" || true)" = 0 ] || { log "PRECONDITION_FAIL $D2_SPEC has test( cases outside the pinned it() count"; fail 70; }
! grep -qE '\b(it|describe|test|suite)\.(skip|only|todo|each|concurrent|failing)\b|\b(xit|fit|xtest|xdescribe|fdescribe)\(' <<<"$SPEC_D2_REST" || { log "PRECONDITION_FAIL $D2_SPEC carries skip/only/todo/each beyond the pinned env switch"; fail 70; }
grep -qF "require('../../utils/g2-s10b-pg-harness')" <<<"$SPEC_D2_AT_HEAD" && grep -qF "require('../../utils/g2-s10b-harness')" <<<"$SPEC_D2_AT_HEAD" \
  && ! grep -qE "g2-s10c-|G2_S10C_|g2-s10d|G2_S10D|g2-s11-|G2_S11_" <<<"$SPEC_D2_AT_HEAD" || { log "PRECONDITION_FAIL $D2_SPEC does not reuse the S10-B lane by import (or references another harness)"; fail 70; }
for pin in "test/rls-g2-s10b.spec.ts $EXPECT_SPEC_BLOB" "test/utils/g2-s10b-bootstrap.sh $EXPECT_BOOTSTRAP_BLOB" "test/utils/g2-s10b-db.ts $EXPECT_DB_BLOB" \
           "test/utils/g2-s10b-pg-harness.ts $EXPECT_PGH_BLOB" "test/utils/g2-s10b-harness.ts $EXPECT_HARNESS_BLOB" "test/utils/g2-s10b-worker.cjs $EXPECT_WORKER_BLOB" \
           "test/utils/g2-s10b-fixtures.ts $EXPECT_FIXTURES_BLOB" "prisma/schema.prisma $EXPECT_SCHEMA_BLOB" \
           "prisma/migrations/$S10B_MIGRATION/migration.sql $EXPECT_MIGRATION_BLOB" "prisma/migrations/$S10B_MIGRATION/down.sql $EXPECT_DOWN_BLOB"; do set -- $pin
  [ "$(git -C "$SRC" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL S10-B proof file $1 blob mismatch"; fail 70; }; done
[ "$(git -C "$SRC" rev-parse HEAD:test/rls-g2-s10c.spec.ts)" = "$EXPECT_S10C_SPEC_BLOB" ] || { log "PRECONDITION_FAIL test/rls-g2-s10c.spec.ts blob != landed $EXPECT_S10C_SPEC_BLOB"; fail 70; }
[ -z "$(git -C "$SRC" status --porcelain --untracked-files=all)" ] || { log "PRECONDITION_FAIL clone source worktree not clean"; fail 70; }
[ ! -e "$(git -C "$SRC" rev-parse --git-path MERGE_HEAD)" ] || { log "PRECONDITION_FAIL MERGE_HEAD present"; fail 70; }
# the committed head must have been produced through the tracked lefthook hooks of the clone source (the D2 gate commits in $SRC)
[ -z "$(git -C "$SRC" config --get core.hooksPath)" ] || { log "PRECONDITION_FAIL core.hooksPath is set (alternate hook directory refused)"; fail 70; }
H=$(git -C "$SRC" rev-parse --git-path hooks); case "$H" in /*) ;; *) H="$SRC/$H";; esac
[ "$H" = "$SRC/.git/hooks" ] && [ -d "$H" ] && [ ! -L "$H" ] || { log "PRECONDITION_FAIL hooks dir [$H] is not the plain $SRC/.git/hooks directory"; fail 70; }
# symlink-aware (review A B-1 analogue): both hooks must be regular files, never symlinks (dangling or not)
for hk in pre-commit commit-msg; do [ -f "$H/$hk" ] && [ ! -L "$H/$hk" ] || { log "PRECONDITION_FAIL $H/$hk is not a regular file (absent or a symlink)"; fail 70; }; done
grep -q lefthook "$H/pre-commit" 2>/dev/null && grep -q lefthook "$H/commit-msg" 2>/dev/null \
  || { log "PRECONDITION_FAIL $H/pre-commit or commit-msg absent or not lefthook (hookless commit)"; fail 70; }
[ "$(sha "$H/pre-commit")" = "$EXPECT_HOOK_PRECOMMIT_SHA" ] && [ "$(sha "$H/commit-msg")" = "$EXPECT_HOOK_COMMITMSG_SHA" ] \
  || { log "PRECONDITION_FAIL hook sha256 pre-commit=$(sha "$H/pre-commit") commit-msg=$(sha "$H/commit-msg") != D2 gate pins ($EXPECT_HOOK_PRECOMMIT_SHA / $EXPECT_HOOK_COMMITMSG_SHA)"; fail 70; }
# S10-C wiring (landed in BASE; the D2 chain needs it): ScoutModule imports ObservationModule at HEAD
MOD_AT_HEAD=$(git -C "$SRC" show HEAD:src/scout/scout.module.ts) || { log "PRECONDITION_FAIL cannot read scout.module.ts at HEAD"; fail 70; }
grep -qF "ObservationModule" <<<"$MOD_AT_HEAD" || { log "PRECONDITION_FAIL scout.module.ts does not import ObservationModule (no S10-C wiring at HEAD)"; fail 70; }
# dependency tree (pre-lock): the read-only DONOR the copy will be taken from (W does not exist yet; the copy is verified in
# step 2 under the lock). Manifests and schema are checked on the committed bytes at HEAD.
[ -d "$DONOR_NM" ] && [ ! -L "$DONOR_NM" ] || { log "PRECONDITION_FAIL donor $DONOR_NM absent or a symlink"; fail 70; }
[ "$(git -C "$SRC" show HEAD:package-lock.json | sha256sum | cut -c1-64)" = "$EXPECT_PKG_LOCK_SHA" ] || { log "PRECONDITION_FAIL package-lock.json at HEAD != base record"; fail 70; }
[ "$(sha "$DONOR_NM/.package-lock.json")" = "$EXPECT_NM_LOCK_SHA" ] || { log "PRECONDITION_FAIL donor node_modules/.package-lock.json != rt-setup record"; fail 70; }
[ "$(git -C "$SRC" show HEAD:prisma/schema.prisma | sha256sum | cut -c1-64)" = "$EXPECT_SCHEMA_SHA" ] || { log "PRECONDITION_FAIL prisma/schema.prisma at HEAD != S10-B d6d01f54"; fail 70; }
[ "$(sha "$DONOR_NM/.prisma/client/index.d.ts" 2>/dev/null)" = "$DONOR_CLIENT_SHA" ] && [ "$(sha "$DONOR_NM/.prisma/client/schema.prisma" 2>/dev/null)" = "$DONOR_CLIENT_SCHEMA_SHA" ] || { log "PRECONDITION_FAIL donor client != rt-setup client (never regenerate $DONOR_NM)"; fail 70; }
CSCH=$(cat "$DONOR_NM/.prisma/client/schema.prisma")
for m_ in ScoutRunDeclaration ScoutRunObservation ScoutRunSettledBasis; do grep -qE "^model $m_ \{" <<<"$CSCH" || { log "PRECONDITION_FAIL donor client lacks $m_"; fail 70; }; done
[ -x "$DONOR_NM/.bin/jest" ] && [ -x "$DONOR_NM/.bin/ts-node" ] && [ -x "$DONOR_NM/.bin/prisma" ] || { log "PRECONDITION_FAIL donor jest/ts-node/prisma missing"; fail 70; }
DPV=$("$DONOR_NM/.bin/prisma" --version 2>/dev/null || true); DPV=$(awk '/^prisma /{print $3}' <<<"$DPV")
[ "$DPV" = "$EXPECT_PRISMA_CLI" ] || { log "PRECONDITION_FAIL donor prisma CLI '$DPV' != $EXPECT_PRISMA_CLI"; fail 70; }
# tools: pinned PG 17.6 server binaries in the fa72efb2 namespace, the real psql 18.6 client binary (CB1) and Node 20
[ -x "$DIST/bin/postgres" ] && [ -x "$DIST/bin/initdb" ] && [ -x "$DIST/bin/pg_ctl" ] || { log "PRECONDITION_FAIL PG17 dist absent at $DIST"; fail 70; }
[ "$(sha "$DIST/bin/postgres")" = "$EXPECT_POSTGRES_SHA" ] || { log "PRECONDITION_FAIL postgres binary sha256 != pin"; fail 70; }
[ "$(sha "$DIST/bin/initdb")" = "$EXPECT_INITDB_SHA" ] || { log "PRECONDITION_FAIL initdb binary sha256 != pin"; fail 70; }
[ "$(sha "$DIST/bin/pg_ctl")" = "$EXPECT_PGCTL_SHA" ] || { log "PRECONDITION_FAIL pg_ctl binary sha256 != pin"; fail 70; }
PGV=$(LD_LIBRARY_PATH=$DIST/lib "$DIST/bin/postgres" --version 2>/dev/null); [ "${PGV##* }" = 17.6 ] || { log "PRECONDITION_FAIL server not 17.6: $PGV"; fail 70; }
[ -x "$PSQL" ] && [ "$(sha "$PSQL")" = "$EXPECT_PSQL_REAL_SHA" ] || { log "PRECONDITION_FAIL $PSQL absent or sha256 != pin"; fail 70; }
PSQLV=$("$PSQL" --version); grep -qE "^psql \(PostgreSQL\) 18\." <<<"$PSQLV" || { log "PRECONDITION_FAIL psql major != 18: $PSQLV"; fail 70; }
NODE=$(command -v node); [ "$(sha "$(readlink -f "$NODE")")" = "$EXPECT_NODE_SHA" ] || { log "PRECONDITION_FAIL node sha256 != pin ($NODE)"; fail 70; }
NODEV=$(node --version); grep -q '^v20\.' <<<"$NODEV" || { log "PRECONDITION_FAIL node major != 20"; fail 70; }
[ "$(readlink -f "$RUNTIME_ROOT")" = "$RUNTIME_ROOT" ] || { log "PRECONDITION_FAIL $RUNTIME_ROOT is not a real path"; fail 70; }
grep -q '^result=success' "$RUNTIME_ROOT/pg17/PROVENANCE.txt" 2>/dev/null || { log "PRECONDITION_FAIL pg17 PROVENANCE.txt lacks result=success"; fail 70; }
log "PRECONDITIONS_OK (pre-lock) $(ts) server='$PGV' psql='$PSQLV' node=$NODEV donor_jest=$("$DONOR_NM/.bin/jest" --version) donor_ts_node=$("$DONOR_NM/.bin/ts-node" --version 2>/dev/null) prisma=$DPV"
{ [ -e "$SENT" ] || [ -L "$SENT" ]; } && { echo "REFUSED: $SENT exists; this proof runs once, no retry" >&2; exit 76; }
[ -e "$LOCK" ] || { echo "REFUSED: canonical lock file $LOCK absent; runtime setup created it and it is never deleted or recreated here" >&2; exit 75; }
exec 9>>"$LOCK"; flock -n 9 || { echo "REFUSED: canonical lock busy ($LOCK)" >&2; exit 75; }
[ "$(stat -c %i "$LOCK")" = "$EXPECT_LOCK_INODE" ] || { echo "REFUSED: $LOCK inode $(stat -c %i "$LOCK") != $EXPECT_LOCK_INODE (LOCK_ESTABLISHED.txt); not the canonical lock file" >&2; exit 75; }
# ---- R1 ordering (parent 08:29): with the lock held and BEFORE the one-shot STARTED marker, re-verify, preflight, make the
#      fresh clone + donor copy and verify them. Any failure here is a PRESTART refusal (rc 70/71/76 as before) that writes NO
#      STARTED and NO sentinel (the run is not consumed); the partial $W is removed iff THIS run created it (mkdir-exclusive);
#      a $W that existed before this run is refused pre-lock or at mkdir and never touched. Prestart lines go to prelock.log.
STAGE=prestart-recheck; W_CREATED=0
refuse(){ local rc=$1 wrm=not-created
  if [ "$W_CREATED" = 1 ]; then wrm=removed; rm -rf -- "$W" 2>>"$LOG" || wrm=REMOVE_FAILED; { [ -e "$W" ] || [ -L "$W" ]; } && wrm=REMOVE_FAILED; fi
  log "PRESTART_REFUSED stage=$STAGE rc=$rc $(ts) clone=$wrm (lock fd9 held until this exit; no STARTED, no sentinel written; the run is not consumed$( [ "$wrm" = REMOVE_FAILED ] && echo "; $W remains, so a relaunch refuses pre-lock until the parent removes it"))"
  exit "$rc"; }
fail(){ refuse "$1"; }   # prestart fail(); redefined as the consuming fail() right after STARTED
listeners(){ local s; s=$(ss -ltn 2>/dev/null || true); grep -c ":$PORT " <<<"$s" || true; }
portl(){ local s; s=$(ss -ltn 2>/dev/null || true); grep -c ":$1 " <<<"$s" || true; }
log "LOCKED $(ts) pid=$$ lock=$LOCK(held nonblocking fd9, inode $(stat -c %i "$LOCK")) (prestart: nothing consumed yet)"
# re-verify under the lock the state that could have moved since the pre-lock preconditions (cheap, read-only)
[ "$(sha "$FIX")" = "$EXPECT_FIXTURE_SHA" ] && [ "$(git -C "$SRC" rev-parse HEAD)" = "$EXPECT_HEAD" ] && [ -z "$(git -C "$SRC" status --porcelain --untracked-files=all)" ] \
  && [ "$(git -C "$SRC" rev-parse --verify -q refs/heads/fa72/d2-r1)" = "$EXPECT_HEAD" ] && { [ "$EXPECT_LAND_REF" = none ] || [ "$(git -C "$SRC" rev-parse --verify -q "$LAND_REF")" = "$EXPECT_HEAD" ]; } \
  && [ "$(sha "$DONOR_NM/.prisma/client/index.d.ts" 2>/dev/null)" = "$DONOR_CLIENT_SHA" ] && [ ! -e "$W" ] && [ ! -L "$W" ] \
  || { log "PRECONDITION_FAIL fixture/source HEAD/source worktree/land ref/donor client/clone path moved after the pre-lock preconditions"; fail 70; }
[ -z "$(git -C "$SRC" config --get core.hooksPath)" ] && [ "$(git -C "$SRC" rev-parse --git-path hooks)" = .git/hooks ] && [ -d "$H" ] && [ ! -L "$H" ] \
  && [ -f "$H/pre-commit" ] && [ ! -L "$H/pre-commit" ] && [ -f "$H/commit-msg" ] && [ ! -L "$H/commit-msg" ] \
  && [ "$(sha "$H/pre-commit")" = "$EXPECT_HOOK_PRECOMMIT_SHA" ] && [ "$(sha "$H/commit-msg")" = "$EXPECT_HOOK_COMMITMSG_SHA" ] \
  || { log "PRECONDITION_FAIL hook identity/hooksPath changed after the pre-lock preconditions"; fail 70; }
# ---- step 1 preflight (read-only): s10d2-v2 lane absent (v1 lane clusters/s10d2 = an other lane); lane port free; no postgres; other lanes under the runtime root (clusters/*
#      incl. clusters/s11 if the S11 binding ran, and proof-*/clusters/*) fingerprinted and never started
STAGE=preflight
[ ! -e "$LANE" ] && [ ! -L "$LANE" ] || { log "PREFLIGHT_FAIL $LANE exists (fresh init only; never adopt)"; fail 71; }
[ ! -e "$SOCK" ] || [ -z "$(ls -A "$SOCK" 2>/dev/null)" ] || { log "PREFLIGHT_FAIL socket dir $SOCK not empty"; fail 71; }
L=$(listeners); [ "$L" = 0 ] || { log "PREFLIGHT_FAIL port $PORT listeners=$L"; fail 71; }
for rp in $REFUSED_LANE_PORTS; do RL=$(portl "$rp"); [ "$RL" = 0 ] || { log "PREFLIGHT_FAIL refused lane port $rp has listeners=$RL (S9-C/S10-B lane live)"; fail 71; }; done
P=$(pgrep -cx postgres || true); [ "$P" = 0 ] || { log "PREFLIGHT_FAIL postgres procs=$P (another lane live; this proof never shares a server)"; fail 71; }
OTHER0=""
for d in "$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-*/clusters/*/; do [ -d "$d" ] || continue; [ "${d%/}" != "$LANE" ] || continue; n=${d#$RUNTIME_ROOT/}; n=${n%/}
  [ ! -e "$d/pg-data/postmaster.pid" ] && [ ! -L "$d/pg-data/postmaster.pid" ] || { log "PREFLIGHT_FAIL $n postmaster.pid present"; fail 71; }
  h="$n:$(sha "$d/pg-data/postgresql.conf" 2>/dev/null || echo ABSENT):$(sha "$d/pg-data/global/pg_control" 2>/dev/null || echo ABSENT)"; OTHER0="$OTHER0 $h"
  log "PREFLIGHT other_lane=$h (must be unchanged at end; never started)"; done
log "PREFLIGHT s10b_lane=$( [ -e "$S10B_LANE" ] && echo "present (fingerprinted above; must be unchanged at end; never started)" || echo absent)"
[ -e "$CLUSTERS" ] || log "PREFLIGHT clusters_dir=ABSENT (no clusters/* lane yet under the runtime root; proof-*/clusters/* scanned above)"
SRCSIG0=$(git -C "$SRC" status --porcelain --untracked-files=all | sha256sum | cut -c1-64):$(git -C "$SRC" rev-parse HEAD)
log "PREFLIGHT_OK $(ts) lane=absent port$PORT=free postgres_procs=0 source_sig=$SRCSIG0 clone=absent lock_inode=$(stat -c %i "$LOCK")"
# ---- step 1b fresh clean clone at the attested head (objects shared read-only with the source; no hooks run) + a real copy of
#      the donor node_modules (donor read-only; no npm, no prisma generate: the donor client IS the S10-B client) (bound 120+120+600 s)
STAGE=clone
mkdir -- "$W" 2>>"$LOG" || { log "CLONE_FAIL $W could not be created exclusively (it appeared after the pre-lock check; never adopted, never removed)"; fail 71; }
W_CREATED=1   # from here a prestart refusal removes $W (this run created it, empty, by mkdir-exclusive; git clone accepts an empty dir)
timeout -k 30 120 git -c core.hooksPath=/dev/null clone --quiet --shared --no-checkout "$SRC" "$W" >>"$LOG" 2>&1; rc=$?; log "CLONE rc=$rc $(ts)"; [ $rc = 0 ] || fail 71
timeout -k 30 120 git -C "$W" -c core.hooksPath=/dev/null checkout --quiet --detach "$EXPECT_HEAD" >>"$LOG" 2>&1; rc=$?; log "CHECKOUT rc=$rc $(ts)"; [ $rc = 0 ] || fail 71
[ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] && [ "$(git -C "$W" rev-parse 'HEAD^{tree}')" = "$EXPECT_TREE" ] && [ "$(git -C "$W" rev-parse HEAD^)" = "$D2_V1_HEAD" ] \
  && [ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] && [ "$(git -C "$W" rev-parse HEAD:prisma/migrations)" = "$EXPECT_MIGRATIONS_TREE" ] \
  && git -C "$W" merge-base --is-ancestor "$HARNESS_BASE_HEAD" HEAD && [ -z "$(git -C "$W" config --get core.hooksPath)" ] \
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
for m_ in ScoutRunDeclaration ScoutRunObservation ScoutRunSettledBasis; do grep -qE "^model $m_ \{" <<<"$CSCH" || { log "NM_FAIL candidate client lacks $m_"; fail 71; }; done
[ "$(sha "$DONOR_NM/.prisma/client/index.d.ts" 2>/dev/null)" = "$DONOR_CLIENT_SHA" ] || { log "NM_FAIL donor client changed (the copy must never touch $DONOR_NM)"; fail 71; }
[ -x "$W/node_modules/.bin/jest" ] && [ -x "$W/node_modules/.bin/ts-node" ] && [ -x "$W/node_modules/.bin/prisma" ] || { log "NM_FAIL jest/ts-node/prisma missing"; fail 71; }
[ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] || { log "NM_FAIL clone not clean after the copy"; fail 71; }
PORC0=$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)
PRV=$(cd "$W" && ./node_modules/.bin/prisma --version 2>/dev/null || true)
log "CLONE_READY $(ts) head=$EXPECT_HEAD worktree_porcelain_sha=$PORC0 jest=$(cd "$W" && ./node_modules/.bin/jest --version) ts_node=$(cd "$W" && ./node_modules/.bin/ts-node --version 2>/dev/null) prisma=$(awk '/^prisma /{print $3}' <<<"$PRV")"
# ---- one-shot: from here on the run is consumed
STAGE=started
( set -C; date -u +%FT%TZ > "$R/STARTED" ) 2>/dev/null || { log "REFUSED: $R/STARTED exists (or is a symlink) at STARTED time; this proof runs once, no retry"; refuse 76; }   # O_EXCL one-shot marker (gate DELTA-2 analogue); written only AFTER clone/copy/verify (R1)
LOG=$R/d2-pg-proof.log
finish(){ local rc=$1
  ( cd "$R" && sha256sum d2-pg-proof.log prelock.log $( [ -e jest.log ] && echo jest.log ) > RECEIPTS.sha256 2>/dev/null )
  echo "RC=$rc STAGE=$STAGE END=$(ts) HEAD=$(git -C "$W" rev-parse HEAD 2>/dev/null) LOCK_INODE=$(stat -c %i "$LOCK")" >"$SENT"
  log "END rc=$rc stage=$STAGE $(ts) (lock fd9 held until this exit; receipts=$R/RECEIPTS.sha256)"; exit "$rc"; }
fail(){ local rc=$1; log "STOP_FIRST_FAILURE stage=$STAGE rc=$rc $(ts)"
  if [ "$STARTED" = 1 ]; then
    local src=0; timeout -k 30 60 bash "$FIX" stop >>"$LOG" 2>&1 || src=$?
    local ssl; ssl=$(ss -ltn 2>/dev/null || true)
    log "CLEANUP_STOP rc=$src postgres_procs=$(pgrep -cx postgres || true) port${PORT}_listeners=$(grep -c ":$PORT " <<<"$ssl" || true) survivor_pid=$(head -1 "$LANE/pg-data/postmaster.pid" 2>/dev/null || echo none)"
  fi
  finish "$rc"; }
log "START $(ts) pid=$$ user=$(id -un) lock=$LOCK(held nonblocking fd9, inode $(stat -c %i "$LOCK")) head_expect=$EXPECT_HEAD clone_ready=$W worktree_porcelain_sha=$PORC0 fixture_expect=$EXPECT_FIXTURE_SHA"
# ---- step 2 init (bound 60 s)
STAGE=fixture-init; timeout -k 30 60 bash "$FIX" init >>"$LOG" 2>&1; rc=$?; log "FIXTURE_INIT rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^D2_FIXTURE_INIT_OK data=$LANE/pg-data port=$PORT superuser=$ADMIN cluster_name=$MARKER socket=$SOCK " "$LOG" || { log "FIXTURE_INIT marker missing"; fail 72; }
# ---- step 3 start (bound 60 s)
STAGE=fixture-start; STARTED=1; timeout -k 30 60 bash "$FIX" start >>"$LOG" 2>&1; rc=$?; log "FIXTURE_START rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^D2_FIXTURE_START_OK pid=" "$LOG" || { log "FIXTURE_START marker missing"; fail 72; }
# ---- step 4 S10-B bootstrap (committed helper at the attested head; roles, marked DB, extensions, the 172 accepted migrations
#      + the S10-B expand (173) through the candidate's `prisma migrate deploy` as postgres, S7-L/S8-B objects asserted,
#      candidate client VERIFIED structurally incl. the three S10-B models — no generate) (bound 900 s)
STAGE=bootstrap
( cd "$W" && timeout -k 30 900 bash test/utils/g2-s10b-bootstrap.sh bootstrap ) >>"$LOG" 2>&1; rc=$?; log "BOOTSTRAP rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^G2_S10B_BOOTSTRAP_OK" "$LOG" || { log "BOOTSTRAP marker missing"; fail 72; }
grep -q "^CANDIDATE_HEAD=$EXPECT_HEAD" "$LOG" || { log "BOOTSTRAP candidate binding line missing"; fail 72; }
grep -q "^CANDIDATE_CLIENT_VERIFIED dir=$W/node_modules/.prisma/client " "$LOG" || { log "BOOTSTRAP candidate client line missing"; fail 72; }
# ---- step 5 identity (read-only, bound 15 s each; admin login with PGPASSWORD only, never a URL password)
STAGE=identity
psqlq(){ PGPASSWORD=$FIXPASS timeout -k 30 15 "$PSQL" -X -v ON_ERROR_STOP=1 -At "postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME" -c "$1" 2>>"$LOG"; }
DD=$(psqlq 'SHOW data_directory'); [ "$DD" = "$G2_S10B_DATA_DIRECTORY" ] || { log "IDENTITY_FAIL data_directory='$DD'"; fail 73; }
VN=$(psqlq 'SHOW server_version_num'); [ "$VN" = 170006 ] || { log "IDENTITY_FAIL server_version_num='$VN'"; fail 73; }
CN=$(psqlq "SELECT current_setting('cluster_name')"); [ "$CN" = "$MARKER" ] || { log "IDENTITY_FAIL cluster_name='$CN'"; fail 73; }
DM=$(psqlq "SELECT shobj_description(oid,'pg_database') FROM pg_database WHERE datname=current_database()")
[ "$DM" = "$DB_MARKER" ] || { log "IDENTITY_FAIL db marker='$DM'"; fail 73; }
MC=$(psqlq 'SELECT count(*) FROM "_prisma_migrations" WHERE finished_at IS NOT NULL AND rolled_back_at IS NULL'); [ "$MC" = "$EXPECT_MIGRATIONS" ] || { log "IDENTITY_FAIL applied migrations=$MC (want $EXPECT_MIGRATIONS)"; fail 73; }
ML=$(psqlq 'SELECT max(migration_name) FROM "_prisma_migrations" WHERE finished_at IS NOT NULL AND rolled_back_at IS NULL'); [ "$ML" = "$S10B_MIGRATION" ] || { log "IDENTITY_FAIL last applied migration='$ML' (want $S10B_MIGRATION)"; fail 73; }
NTB=$(psqlq "SELECT count(*) FROM pg_class WHERE relnamespace='public'::regnamespace AND relkind='r' AND relname IN ('ScoutRunDeclaration','ScoutRunObservation','ScoutRunSettledBasis') AND relrowsecurity AND relforcerowsecurity")
[ "$NTB" = 3 ] || { log "IDENTITY_FAIL S10-B tables with ENABLE+FORCE RLS=$NTB (want 3)"; fail 73; }
PT=$(psqlq 'SELECT inet_server_port()'); [ "$PT" = "$PORT" ] || { log "IDENTITY_FAIL inet_server_port='$PT'"; fail 73; }
log "IDENTITY_OK $(ts) data_directory=$DD server_version_num=$VN cluster_name=$CN applied_migrations=$MC last=$ML s10b_tables_forced_rls=$NTB"
# ---- step 6 the proof, exactly once (bound 1500 s); no --testTimeout/--forceExit/--detectOpenHandles/coverage
STAGE=jest; log "JEST_START $(ts) cmd='./node_modules/.bin/jest -c jest.config.js --runInBand --ci --runTestsByPath $D2_SPEC' candidate_head=$G2_S10B_CANDIDATE_HEAD expect_tests=$EXPECT_TESTS_D2"
( cd "$W" && timeout -k 30 1500 ./node_modules/.bin/jest -c jest.config.js --runInBand --ci --runTestsByPath "$D2_SPEC" ) >"$JLOG" 2>&1; JRC=$?
log "JEST_END rc=$JRC $(ts)"; grep -E '^(Test Suites|Tests|Snapshots|Time):' "$JLOG" | tee -a "$LOG"
grep -E 'requires its explicitly confirmed|unsupported or ambiguous connection option|requires a plain fixture password|connects only as a fixture matrix login role|candidate head, not the accepted base|not the attested candidate|uncommitted changes|G2 proof requires|server identity mismatch' "$JLOG" >/dev/null && log "GUARD_REFUSAL_OBSERVED_IN_JEST_LOG"
[ $JRC = 0 ] || fail $JRC
grep -qE "^Tests: +$EXPECT_TESTS passed, $EXPECT_TESTS total" "$JLOG" || { log "JEST_COUNT_FAIL expected 'Tests: $EXPECT_TESTS passed, $EXPECT_TESTS total' (got: $(grep -E '^Tests:' "$JLOG" | head -1))"; fail 72; }
grep -qE "^Test Suites: +1 passed, 1 total" "$JLOG" || { log "JEST_COUNT_FAIL expected 'Test Suites: 1 passed, 1 total' (got: $(grep -E '^Test Suites:' "$JLOG" | head -1))"; fail 72; }
JP=$(grep -E '^PASS ' "$JLOG" | grep -oE 'test/[^ ]+\.spec\.ts' | sort | tr '\n' ' ')   # jest.config.js has no displayName; the parser tolerates one
[ "$JP" = "$D2_SPEC " ] || { log "JEST_COUNT_FAIL PASS lines [$JP] != the D2 spec"; fail 72; }
log "JEST_COUNT_OK tests=$EXPECT_TESTS (d2=$EXPECT_TESTS_D2 pinned at HEAD) suites=1"
# ---- step 7 stop (bound 45 s + kill 30); data dir RETAINED (destroy only via separate grant: d2-fixture.sh destroy)
STAGE=fixture-stop; STARTED=0; timeout -k 30 75 bash "$FIX" stop >>"$LOG" 2>&1; rc=$?; log "FIXTURE_STOP rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
P=$(pgrep -cx postgres || true); L=$(listeners)
[ "$P" = 0 ] && [ "$L" = 0 ] && [ ! -e "$LANE/pg-data/postmaster.pid" ] && [ -d "$LANE/pg-data" ] || { log "STOP_STATE_FAIL postgres_procs=$P listeners=$L"; fail 74; }
log "STOP_STATE_OK postgres_procs=0 port$PORT=free datadir_retained=$LANE/pg-data"
# ---- step 8 post (read-only)
STAGE=post
OTHER1=""
for d in "$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-*/clusters/*/; do [ -d "$d" ] || continue; [ "${d%/}" != "$LANE" ] || continue; n=${d#$RUNTIME_ROOT/}; n=${n%/}
  [ ! -e "$d/pg-data/postmaster.pid" ] || { log "POST_FAIL $n postmaster.pid appeared"; fail 74; }
  OTHER1="$OTHER1 $n:$(sha "$d/pg-data/postgresql.conf" 2>/dev/null || echo ABSENT):$(sha "$d/pg-data/global/pg_control" 2>/dev/null || echo ABSENT)"; done
[ "$OTHER0" = "$OTHER1" ] || { log "POST_FAIL other lanes changed: before=[$OTHER0] after=[$OTHER1]"; fail 74; }
for rp in $REFUSED_LANE_PORTS; do RL=$(portl "$rp"); [ "$RL" = 0 ] || { log "POST_FAIL refused lane port $rp listeners=$RL"; fail 74; }; done
[ ! -e "$S10B_LANE/pg-data/postmaster.pid" ] && [ ! -L "$S10B_LANE/pg-data/postmaster.pid" ] || { log "POST_FAIL S10-B lane postmaster.pid appeared"; fail 74; }
log "POST other_lanes_unchanged=[${OTHER0:-none}] s10b_lane=$( [ -e "$S10B_LANE" ] && echo unchanged,stopped || echo absent) refused_ports=[$REFUSED_LANE_PORTS] free"
[ "$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)" = "$PORC0" ] && [ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] || { log "POST_FAIL worktree changed"; fail 74; }
[ "$(git -C "$SRC" status --porcelain --untracked-files=all | sha256sum | cut -c1-64):$(git -C "$SRC" rev-parse HEAD)" = "$SRCSIG0" ] || { log "POST_FAIL clone source changed during the proof"; fail 74; }
[ "$(sha "$W/node_modules/.prisma/client/index.d.ts")" = "$EXPECT_NM_CLIENT_SHA" ] || { log "POST_FAIL generated client changed during the proof"; fail 74; }
[ "$(sha "$DONOR_NM/.prisma/client/index.d.ts" 2>/dev/null)" = "$DONOR_CLIENT_SHA" ] || { log "POST_FAIL donor client changed during the proof"; fail 74; }
log "POST_OK $(ts) lock_still_held_fd9 inode=$(stat -c %i "$LOCK")"
STAGE=done; finish 0
