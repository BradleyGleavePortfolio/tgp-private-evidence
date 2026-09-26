#!/usr/bin/env bash
# S10-C real-PG proof — execution binding v1 (EXEC-D3A9F701). SOURCE ONLY: NOT RUN, NOT GRANTED.
# Derived by substitution from the landed S10-B binding execution/d3a9f701/s10b/binding/v1/s10b-pg-proof.sh (filled copy
# of the reviewed template; it ran rc 0, 24/24). Full diff in DELTA-from-s10b-v1.diff. S10-C deltas:
#   * clone worktrees/d3a9-s10c; candidate head = ONE gate commit on BASE = the integration/importer tip at gate time
#     (__FILL__ from the S10-C gate PINS.env / receipt). No parent-shape pin on BASE: S10B_HEAD (a2c74e90) and the harness
#     base a4af8e33 must be ANCESTORS of BASE; BASE..HEAD = the S10-C receipt delta (12 owned paths, + the contract iff the
#     gate recorded contract_state=changed); the 29 S10-A/S10-B FROZEN paths carry their a2c74e90 bytes at HEAD
#   * NO prisma change: schema = the S10-B bytes, 173 migrations ending at the S10-B dir, migrations tree 7b6fe0ed at BASE
#     and HEAD; the client is the one the S10-C gate regenerated in the clone (EXPECT_NM_CLIENT_SHA from its receipt)
#   * NEW lane (review B B4): clusters/s10-c + run/s10-c on port 55649, REUSING the S10-B harness literals (cluster marker
#     s10b-disposable-pg17, DB g2_s10b_disposable, role s10b_super) because the harness parameterizes only port and data
#     directory. The retained s10-b lane is never touched: LANE == clusters/s10-b is refused, clusters/s10-b must be
#     present, stopped (no postmaster.pid) and byte-fingerprint-unchanged at the end, like every other lane; ports
#     55646/55647 are refused as lane ports and must have zero listeners before and after
#   * scout.module.ts at HEAD MUST import ObservationModule (S10-C wiring; the S10-B binding required the opposite)
#   * runs ONLY test/rls-g2-s10b.spec.ts + test/rls-g2-s10c.spec.ts exactly once via the repo jest + jest.rls.config.js;
#     it() counts pinned per spec at HEAD (24 + 8) and the run must print "Tests: 32 passed, 32 total" and
#     "Test Suites: 2 passed, 2 total"; no retry, no inherited-proof replay. test/rls-g2-s9c.spec.ts is NOT run (parent:
#     it cannot run at S10 heads)
# Carried unchanged: single canonical lock holder (nonblocking flock fd 9 before any state change, held through stop, post
# checks and receipt hashing; lock file never deleted); ALL pin/shape preconditions before the lock and the sentinel
# (prelock.log, PRELOCK_REFUSED does not consume the run); symlink-aware sentinel; under-lock rechecks; first nonzero
# stops; the only cleanup is a bounded fixture stop when this run started the postmaster; data dir RETAINED after stop.
# Pipefail rule (S9C-PROOF-1): never `cmd | grep -q`; producer output is captured first, then grepped as a here-string.
# Inner stage bounds: init 60 + start 60 + bootstrap 900 + identity 7x15 + jest 1500 + stop 75 = 2700 s soft sum.
# Usage (under the separate single-run PG grant, after the gate commit and fill): timeout -k 30 3900 bash .../binding/v1/s10c-pg-proof.sh
# Fill (parent, README.md): BASE_HEAD / BASE_TREE (= gate PINS.env BASE/BASE_TREE); EXPECT_HEAD / EXPECT_TREE /
# EXPECT_DELTA / EXPECT_CONTRACT_STATE / EXPECT_CONTRACT_BLOB / EXPECT_S10C_SPEC_BLOB / EXPECT_NM_CLIENT_SHA /
# EXPECT_NM_CLIENT_SCHEMA_SHA from the S10-C gate-v2 receipt d3a9f701/s10c/gate-v2/HEAD-<12>.txt (lines head=, tree=, delta=,
# contract_state=, blob test/rls-g2-s10c.spec.ts, postgen_client). Placeholders are refused pre-lock.
set -uo pipefail
D=/home/user/workspace/tgp-private-evidence/execution/d3a9f701/s10c/binding/v3   # v3 (v2 superseded unrun by the review-B R36 delta): run-1 (binding/v1/run, RC=1 28/32) preserved; PROOF_RUN1_FINDING.md
RUNTIME_ROOT=/home/user/workspace/execution/1910a060/runtime                     # 1910a060 runtime namespace (execution/1910a060/runtime/RUNTIME_SETUP_RECEIPT.md); the fixture carries the same literal and is cross-checked below
W=/home/user/workspace/worktrees/d3a9-s10c
DONOR_NM=/home/user/workspace/worktrees/1910a060-s8f/node_modules                 # read-only: must still hold the pre-S10-B client (the gate generated in the clone copy only)
R=$D/run; LOG=$R/s10c-pg-proof.log; SENT=$R/s10c-pg-proof.sentinel; JLOG=$R/jest.log
LOCK=/home/user/workspace/execution/test-validation.lock
# ---- pins: head pins are filled by the parent AFTER the S10-C gate commit; placeholders are refused.
BASE_HEAD=711c1f8f8b42157bca97f2a721557be7ef006667                                                   # integration/importer tip the gate committed on (= S10-C gate PINS.env BASE)
BASE_TREE=abc927e47f9e0bb11afa575a4f4c550c1a56c067                                                   # git rev-parse "$BASE_HEAD^{tree}"
S10B_HEAD=a2c74e904ff227b16881c77ee5a08bd006972d48                             # S10-B landing commit; ancestor of BASE_HEAD (checked)
HARNESS_BASE_HEAD=a4af8e330bd4d6f882f0aebd411200b76d651aba                     # kept: G2_S10B_BASE_HEAD / bootstrap BASE_HEAD literal; ancestor of BASE_HEAD (checked)
EXPECT_HEAD=2ec74c56b76d20489188ed1519fdeb2bbe394f44                                               # gate receipt head=
EXPECT_TREE=98b705e1a5f4bc7351509b8e80801fd279dcee39                                               # gate receipt tree=
EXPECT_DELTA="src/scout/induction/observation.module.ts src/scout/lifecycle/lifecycle.service.ts src/scout/reconciliation/facts.service.ts src/scout/reconciliation/types.ts src/scout/scout.module.ts test/rls-g2-s10c.spec.ts test/rls-g2-s9c.spec.ts test/scout/induction/s10c-wiring.spec.ts test/scout/lifecycle/lifecycle.service.spec.ts test/scout/orchestration/settle-hook.spec.ts test/scout/reconciliation/facts.service.coverage.spec.ts test/scout/reconciliation/facts.service.spec.ts"                                           # gate receipt delta= (sorted, space-separated; drop the trailing space)
EXPECT_CONTRACT_STATE=unchanged                                  # gate receipt contract_state= (changed|unchanged)
EXPECT_CONTRACT_BLOB=752f9dbe1a6bdee0c20504a35dce60757880d427                                    # gate receipt contract_state ... blob= (= 752f9dbe1a6bdee0c20504a35dce60757880d427 iff unchanged)
EXPECT_HOOK_PRECOMMIT_SHA=e32f6e028411344acdff9ee787decef9ee49fa4414d0deb9aa8e613f30bede06                          # gate receipt "hooks raw pre-commit=<sha256>" (.git/hooks/pre-commit the gate committed through)
EXPECT_HOOK_COMMITMSG_SHA=efb54d65efd525381d95fe70eef76fa6c2eb03ae3829808e69edb8fe622a2f19                          # gate receipt "hooks raw ... commit-msg=<sha256>"
EXPECT_S10C_SPEC_BLOB=50a0deae0e9eee45ec093e87769949f47efd3d8e                                  # gate receipt "blob test/rls-g2-s10c.spec.ts <blob>"
EXPECT_MIGRATIONS_TREE=7b6fe0eda137ab1e3013b8a7c3b0c7637f69a521                # S10-B migrations tree (173); S10-C changes no prisma, so BASE and HEAD both carry it
BASE_CONTRACT_BLOB=752f9dbe1a6bdee0c20504a35dce60757880d427                    # importer contract blob at a2c74e90 (the gate refuses a BASE that differs)
# landed S10-B proof files (s10b/gate/HEAD-a2c74e904ff2.txt); frozen through S10-C (also covered by FROZEN below)
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
EXPECT_FIXTURE_SHA=c1b57239c40df1353fc98561816353dcdfd8720a318436637f1315b1cb1992e7                                             # sha256 of binding/v1/s10c-fixture.sh (frozen with this file; BINDING.sha256)
FROZEN=/home/user/workspace/tgp-private-evidence/execution/d3a9f701/s10c/gate/FROZEN.sha256
FROZEN_SHA=e9c71f09462a25e36baafe0fa90ba012ef6b3f384f04b3951fb1c7bbf1f4be21
S10B_MIGRATION=20270124000000_scout_run_observation_expand
EXPECT_MIGRATIONS=173
# the 12 S10-C owned paths (parent 2026-09-25 22:23 + 22:34 + 23:11 settle-hook.spec.ts); EXPECT_DELTA must be exactly these, plus the contract iff changed
S10C_OWNED="src/scout/induction/observation.module.ts src/scout/lifecycle/lifecycle.service.ts src/scout/reconciliation/facts.service.ts src/scout/reconciliation/types.ts src/scout/scout.module.ts test/rls-g2-s10c.spec.ts test/rls-g2-s9c.spec.ts test/scout/induction/s10c-wiring.spec.ts test/scout/lifecycle/lifecycle.service.spec.ts test/scout/orchestration/settle-hook.spec.ts test/scout/reconciliation/facts.service.coverage.spec.ts test/scout/reconciliation/facts.service.spec.ts"
CONTRACT=docs/contracts/importer-openapi.json
# ---- tool pins: from the 1910a060 runtime setup receipt (compare only, never adjusted at run time); identical to S10-B v1.
EXPECT_POSTGRES_SHA=23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a
EXPECT_INITDB_SHA=b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a
EXPECT_PGCTL_SHA=af53d826845af4679a0aaba2bda319f5e527f3b94f3794c67fa174049c9b9401
PSQL=/usr/lib/postgresql/18/bin/psql                # CB1: the real client binary, not the /usr/bin/psql pg_wrapper dispatcher
EXPECT_PSQL_REAL_SHA=d1108fdb45b87f2313d7acfbb91a0a65ca97c6c2195f15d8ae9295121029ef67
EXPECT_TESTS_S10B=24                                # it() count in the frozen test/rls-g2-s10b.spec.ts (re-checked at HEAD)
EXPECT_TESTS_S10C=8                                 # it() count in test/rls-g2-s10c.spec.ts (fix-1 bytes 5eeb0fe6; parent 22:34: 24 + 8; re-checked at HEAD; the gate enforced EXPECT_IT_S10C=8)
EXPECT_TESTS=$((EXPECT_TESTS_S10B + EXPECT_TESTS_S10C))   # 32: the one jest run must print "Tests: 32 passed, 32 total"
EXPECT_LOCK_INODE=692282                            # execution/d3a9f701/runtime/LOCK_ESTABLISHED.txt (inode=692282)
EXPECT_NODE_SHA=a03953a7b16bff002b94d6fb58ada900b68241cbcaee6efc400b20dadd36dddc       # node v20.x
EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44    # node_modules/.package-lock.json (donor copy; package-lock unchanged since 93389265)
EXPECT_NM_CLIENT_SHA=2c819c8a8e2fd4afb59578893122b8e9c406bc1dc7821e643e7ef359c04aa56c         # $W/node_modules/.prisma/client/index.d.ts as regenerated by the S10-C gate (receipt postgen_client index_dts=; same schema as S10-B, so expected 2c819c8a…a56c)
EXPECT_NM_CLIENT_SCHEMA_SHA=aca7a558cd379c154e947447782f2858a9f898039298e34c30b886947aed42e5   # $W/node_modules/.prisma/client/schema.prisma (receipt postgen_client schema=; expected aca7a558…42e5)
DONOR_CLIENT_SHA=9042e713ba5678c99959a345b7b18a60dfc186b2c7d890b8d9c3ed5c8f4edcc6      # pre-S10-B client (BASE schema 0eb41f9a); EXPECT_NM_CLIENT_SHA must differ from it
EXPECT_SCHEMA_SHA=d6d01f546f6c7988d93bdd60588e421bf6ff0a56b312f85eee962e0a6be0eb96   # prisma/schema.prisma (S10-B bytes; S10-C changes no prisma) (never reflowed)
EXPECT_PKG_LOCK_SHA=b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55   # package-lock.json (unchanged since 93389265)
DIST=$RUNTIME_ROOT/pg17/dist; CLUSTERS=$RUNTIME_ROOT/clusters; LANE=$CLUSTERS/s10-c; SOCK=$RUNTIME_ROOT/run/s10-c
S10B_LANE=$CLUSTERS/s10-b                          # RETAINED S10-B lane: must exist, stay stopped and unchanged; never started, never destroyed here
PORT=55649; DBNAME=g2_s10b_disposable; ADMIN=s10b_super; FIXPASS=s10b_local_synthetic   # S10-B harness literals reused (review B B4); only port + data dir differ
REFUSED_LANE_PORTS="55646 55647"                    # S9-C / S10-B lane ports: never this lane, zero listeners before and after
MARKER=s10b-disposable-pg17; DB_MARKER=s10b-g2-run-observation-synthetic-disposable-fixture-safe-to-drop
FIX=$D/s10c-fixture.sh
export GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1 NODE_OPTIONS=--max-old-space-size=4096 CHECKPOINT_DISABLE=1 \
       PRISMA_HIDE_UPDATE_MESSAGE=1 PRISMA_GENERATE_SKIP_AUTOINSTALL=1 npm_config_offline=true npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false \
       npm_config_cache=$RUNTIME_ROOT/npm-cache XDG_CACHE_HOME=$RUNTIME_ROOT/xdg-cache
# S10-B-harness identity (reused by the S10-C spec): exactly the G2_S10B_* names the guard/harness/bootstrap read (G2_S10B_DATABASE_URL, _CONFIRM, _PASSWORD,
# _PSQL, _DATA_DIRECTORY, _SERVER_VERSION, _CANDIDATE_HEAD). G2_S10B_BASE_HEAD is a source literal, never read from env;
# G2_S10B_WORKER is set by the harness for its own children only. Every other inherited G2_* is unset.
for v in $(compgen -e | grep -E '^G2_' | grep -vE '^G2_S10B_'); do unset "$v"; done
unset G2_S10B_WORKER
export G2_S10B_DATABASE_URL="postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=4" \
       G2_S10B_CONFIRM="$DBNAME:$PORT" G2_S10B_PASSWORD=$FIXPASS G2_S10B_PSQL=$PSQL \
       G2_S10B_DATA_DIRECTORY=$LANE/pg-data G2_S10B_SERVER_VERSION=170006 \
       G2_S10B_CANDIDATE_HEAD=$EXPECT_HEAD
export S10C_RUNNER_PID=$$ S10C_STOP_TIMEOUT=45
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
case "$BASE_HEAD$BASE_TREE$EXPECT_HEAD$EXPECT_TREE$EXPECT_DELTA$EXPECT_CONTRACT_STATE$EXPECT_CONTRACT_BLOB$EXPECT_S10C_SPEC_BLOB$EXPECT_HOOK_PRECOMMIT_SHA$EXPECT_HOOK_COMMITMSG_SHA$EXPECT_FIXTURE_SHA$FROZEN_SHA$EXPECT_NM_CLIENT_SHA$EXPECT_NM_CLIENT_SCHEMA_SHA$PORT$RUNTIME_ROOT$EXPECT_POSTGRES_SHA$EXPECT_INITDB_SHA$EXPECT_PGCTL_SHA$EXPECT_PSQL_REAL_SHA$EXPECT_NODE_SHA$EXPECT_NM_LOCK_SHA" in *__*) log "PRECONDITION_FAIL pins not filled (proposal stage: base, head, delta, contract, spec blob or client; README.md)"; fail 70;; esac
for v in BASE_HEAD BASE_TREE EXPECT_HEAD EXPECT_TREE EXPECT_CONTRACT_BLOB EXPECT_S10C_SPEC_BLOB; do [[ "${!v}" =~ ^[0-9a-f]{40}$ ]] || { log "PRECONDITION_FAIL $v not 40-hex (${!v})"; fail 70; }; done
for v in EXPECT_NM_CLIENT_SHA EXPECT_NM_CLIENT_SCHEMA_SHA EXPECT_HOOK_PRECOMMIT_SHA EXPECT_HOOK_COMMITMSG_SHA EXPECT_FIXTURE_SHA FROZEN_SHA; do [[ "${!v}" =~ ^[0-9a-f]{64}$ ]] || { log "PRECONDITION_FAIL $v not 64-hex (${!v})"; fail 70; }; done
# lane refusals (review B B4): never the retained s10-b lane, never the S9-C/S10-B ports
[ "$LANE" = "$CLUSTERS/s10-c" ] && [ "$LANE" != "$S10B_LANE" ] && [ "$SOCK" = "$RUNTIME_ROOT/run/s10-c" ] || { log "PRECONDITION_FAIL lane $LANE / socket $SOCK is not clusters/s10-c + run/s10-c"; fail 70; }
for rp in $REFUSED_LANE_PORTS; do [ "$PORT" != "$rp" ] || { log "PRECONDITION_FAIL lane port $PORT is a refused lane port ($REFUSED_LANE_PORTS)"; fail 70; }; done
[ "$PORT" = 55649 ] || { log "PRECONDITION_FAIL lane port $PORT != 55649"; fail 70; }
[ "$G2_S10B_DATA_DIRECTORY" = "$LANE/pg-data" ] && [ "$G2_S10B_CONFIRM" = "$DBNAME:$PORT" ] || { log "PRECONDITION_FAIL harness env not bound to the s10-c lane"; fail 70; }
[ -d "$S10B_LANE/pg-data" ] && [ ! -L "$S10B_LANE" ] || { log "PRECONDITION_FAIL retained S10-B lane $S10B_LANE/pg-data absent or a symlink (it must be retained and untouched; README.md)"; fail 70; }
{ [ -e "$S10B_LANE/pg-data/postmaster.pid" ] || [ -L "$S10B_LANE/pg-data/postmaster.pid" ]; } && { log "PRECONDITION_FAIL retained S10-B lane has a postmaster.pid (running or unclean); refusing"; fail 70; }
case "$EXPECT_CONTRACT_STATE" in changed) [ "$EXPECT_CONTRACT_BLOB" != "$BASE_CONTRACT_BLOB" ] || { log "PRECONDITION_FAIL contract_state=changed but blob = base"; fail 70; };;
  unchanged) [ "$EXPECT_CONTRACT_BLOB" = "$BASE_CONTRACT_BLOB" ] || { log "PRECONDITION_FAIL contract_state=unchanged but blob != $BASE_CONTRACT_BLOB"; fail 70; };;
  *) log "PRECONDITION_FAIL EXPECT_CONTRACT_STATE must be changed|unchanged ($EXPECT_CONTRACT_STATE)"; fail 70;; esac
WANT_DELTA=$(printf '%s\n' $S10C_OWNED $( [ "$EXPECT_CONTRACT_STATE" = changed ] && echo "$CONTRACT") | sort | tr '\n' ' ' | sed 's/ $//')
EXPECT_DELTA=$(echo $EXPECT_DELTA)
[ "$EXPECT_DELTA" = "$WANT_DELTA" ] || { log "PRECONDITION_FAIL filled EXPECT_DELTA [$EXPECT_DELTA] != the 12 S10-C owned paths (+ contract iff changed) [$WANT_DELTA]"; fail 70; }
[ "$EXPECT_HEAD" != "$BASE_HEAD" ] || { log "PRECONDITION_FAIL EXPECT_HEAD is the base, not a candidate"; fail 70; }
[ "$EXPECT_NM_CLIENT_SHA" != "$DONOR_CLIENT_SHA" ] || { log "PRECONDITION_FAIL EXPECT_NM_CLIENT_SHA is the pre-S10-B donor client (no in-clone generate recorded)"; fail 70; }
[ "$(sha "$FIX")" = "$EXPECT_FIXTURE_SHA" ] || { log "PRECONDITION_FAIL fixture sha256 mismatch"; fail 70; }
# the fixture must carry exactly this runner's lane constants (whole-line, literal): one runtime root, one port, one marker
FIXTXT=$(cat "$FIX")
grep -qx "RUNTIME_ROOT=$RUNTIME_ROOT" <<<"$FIXTXT" || { log "PRECONDITION_FAIL fixture RUNTIME_ROOT line != $RUNTIME_ROOT"; fail 70; }
grep -qx "PORT=$PORT; SUPER=$ADMIN; PASS=$FIXPASS; MARKER=$MARKER" <<<"$FIXTXT" || { log "PRECONDITION_FAIL fixture PORT/SUPER/PASS/MARKER line != runner (PORT=$PORT ADMIN=$ADMIN MARKER=$MARKER)"; fail 70; }
grep -qx "LANE=\$RUNTIME_ROOT/clusters/s10-c" <<<"$FIXTXT" && grep -qx "DATA=\$LANE/pg-data; LOG=\$LANE/pg.log; SOCK=\$RUNTIME_ROOT/run/s10-c" <<<"$FIXTXT" || { log "PRECONDITION_FAIL fixture lane/socket lines != clusters/s10-c + run/s10-c"; fail 70; }
grep -qF 'case "$PORT" in 55646|55647)' <<<"$FIXTXT" && grep -qF 'grep -qx "port = $PORT"' <<<"$FIXTXT" || { log "PRECONDITION_FAIL fixture lacks the refused-port / port-bound marker checks"; fail 70; }
grep -qF 'grep -q s10c-pg-proof.sh "/proc/$S10C_RUNNER_PID/cmdline"' <<<"$FIXTXT" || { log "PRECONDITION_FAIL fixture does not require the S10-C runner"; fail 70; }
[ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] || { log "PRECONDITION_FAIL HEAD != $EXPECT_HEAD"; fail 70; }
[ "$(git -C "$W" rev-parse 'HEAD^{tree}')" = "$EXPECT_TREE" ] || { log "PRECONDITION_FAIL tree mismatch"; fail 70; }
[ "$(git -C "$W" rev-parse "$BASE_HEAD^{tree}")" = "$BASE_TREE" ] || { log "PRECONDITION_FAIL base tree mismatch"; fail 70; }
[ "$(git -C "$W" rev-parse HEAD^)" = "$BASE_HEAD" ] || { log "PRECONDITION_FAIL HEAD^ != $BASE_HEAD (the gate makes exactly one commit on BASE)"; fail 70; }
git -C "$W" merge-base --is-ancestor "$S10B_HEAD" "$BASE_HEAD" || { log "PRECONDITION_FAIL S10-B landing $S10B_HEAD not an ancestor of $BASE_HEAD"; fail 70; }
git -C "$W" merge-base --is-ancestor "$HARNESS_BASE_HEAD" "$BASE_HEAD" || { log "PRECONDITION_FAIL harness base $HARNESS_BASE_HEAD not an ancestor of $BASE_HEAD"; fail 70; }
# exact delta: BASE..HEAD = the gate receipt delta (12 S10-C paths, + contract iff changed); FROZEN S10-A/S10-B bytes at HEAD
DELTA=$(git -C "$W" diff --name-only "$BASE_HEAD" HEAD | sort | tr '\n' ' ' | sed 's/ $//')
[ "$DELTA" = "$EXPECT_DELTA" ] || { log "PRECONDITION_FAIL BASE..HEAD delta [$DELTA] != receipt delta [$EXPECT_DELTA]"; fail 70; }
[ -f "$FROZEN" ] && [ ! -L "$FROZEN" ] && [ "$(sha "$FROZEN")" = "$FROZEN_SHA" ] || { log "PRECONDITION_FAIL FROZEN file absent, a symlink or sha mismatch"; fail 70; }
NF=0; while read -r tag s b p; do [ "$tag" = FROZEN ] || continue; NF=$((NF+1))
  [ "$(git -C "$W" rev-parse "HEAD:$p" 2>/dev/null)" = "$b" ] || { log "PRECONDITION_FAIL frozen $p at HEAD != $b"; fail 70; }
done < "$FROZEN"; [ "$NF" = 29 ] || { log "PRECONDITION_FAIL FROZEN lists $NF paths (want 29)"; fail 70; }
[ -z "$(git -C "$W" diff --name-only "$S10B_HEAD" HEAD -- prisma package.json package-lock.json 'test/utils/g2-s10b-*')" ] || { log "PRECONDITION_FAIL prisma / manifests / test/utils/g2-s10b-* differ from the S10-B landing (other test/utils files, e.g. S11-A1 g2-s11-*, may change)"; fail 70; }
[ "$(git -C "$W" rev-parse "HEAD:$CONTRACT")" = "$EXPECT_CONTRACT_BLOB" ] && [ "$(git -C "$W" rev-parse "$BASE_HEAD:$CONTRACT")" = "$BASE_CONTRACT_BLOB" ] || { log "PRECONDITION_FAIL contract blob BASE/HEAD != $BASE_CONTRACT_BLOB/$EXPECT_CONTRACT_BLOB ($EXPECT_CONTRACT_STATE)"; fail 70; }
# prisma: the candidate delta is exactly schema + the S10-B migration pair (vs BASE and vs the harness base); 173 dirs
PD=$(git -C "$W" diff --name-only "$HARNESS_BASE_HEAD" HEAD -- prisma | sort | tr '\n' ' ' | sed 's/ $//')
[ "$PD" = "prisma/migrations/$S10B_MIGRATION/down.sql prisma/migrations/$S10B_MIGRATION/migration.sql prisma/schema.prisma" ] || { log "PRECONDITION_FAIL prisma delta vs harness base [$PD]"; fail 70; }
[ -z "$(git -C "$W" diff --name-only --diff-filter=DMR "$BASE_HEAD" HEAD -- prisma/migrations)" ] || { log "PRECONDITION_FAIL an accepted migration was modified/renamed/deleted"; fail 70; }
[ -z "$(git -C "$W" diff --name-only "$HARNESS_BASE_HEAD" HEAD -- package.json package-lock.json)" ] || { log "PRECONDITION_FAIL dependency manifests differ from the harness base $HARNESS_BASE_HEAD (g2-s10b-bootstrap.sh L158 would refuse mid-run)"; fail 70; }
[ -z "$(git -C "$W" diff --name-only "$BASE_HEAD" HEAD -- prisma package.json package-lock.json)" ] || { log "PRECONDITION_FAIL prisma / dependency manifests differ from base (S10-C changes no prisma)"; fail 70; }
DOCD=$(git -C "$W" diff --name-only "$BASE_HEAD" HEAD -- docs | tr '\n' ' ' | sed 's/ $//'); [ -z "$DOCD" ] || [ "$DOCD" = "$CONTRACT" ] || { log "PRECONDITION_FAIL docs delta [$DOCD] beyond the contract artifact"; fail 70; }
[ "$(git -C "$W" rev-parse "$BASE_HEAD:prisma/migrations")" = "$EXPECT_MIGRATIONS_TREE" ] || { log "PRECONDITION_FAIL BASE prisma/migrations tree != $EXPECT_MIGRATIONS_TREE (a migration landed after S10-B; the reused harness pins 173)"; fail 70; }
[ "$(git -C "$W" rev-parse HEAD:prisma/migrations)" = "$EXPECT_MIGRATIONS_TREE" ] || { log "PRECONDITION_FAIL HEAD prisma/migrations tree != $EXPECT_MIGRATIONS_TREE"; fail 70; }
HMIG=$(git -C "$W" ls-tree -d --name-only HEAD prisma/migrations/ | sed 's|^prisma/migrations/||' | sort)
[ "$(wc -l <<<"$HMIG")" = "$EXPECT_MIGRATIONS" ] && [ "$(tail -1 <<<"$HMIG")" = "$S10B_MIGRATION" ] || { log "PRECONDITION_FAIL HEAD migrations $(wc -l <<<"$HMIG")/$(tail -1 <<<"$HMIG") != $EXPECT_MIGRATIONS/$S10B_MIGRATION"; fail 70; }
# harness literals must match this runner (lane identity, base pin, migrations): read from the committed bytes at HEAD
BOOT_AT_HEAD=$(git -C "$W" show HEAD:test/utils/g2-s10b-bootstrap.sh) && DBTS_AT_HEAD=$(git -C "$W" show HEAD:test/utils/g2-s10b-db.ts) \
  && PGH_AT_HEAD=$(git -C "$W" show HEAD:test/utils/g2-s10b-pg-harness.ts) && SPEC_AT_HEAD=$(git -C "$W" show HEAD:test/rls-g2-s10b.spec.ts) \
  && SPEC_C_AT_HEAD=$(git -C "$W" show HEAD:test/rls-g2-s10c.spec.ts) || { log "PRECONDITION_FAIL cannot read harness bytes at HEAD"; fail 70; }
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
for pin in "test/rls-g2-s10b.spec.ts $EXPECT_SPEC_BLOB" "test/utils/g2-s10b-bootstrap.sh $EXPECT_BOOTSTRAP_BLOB" "test/utils/g2-s10b-db.ts $EXPECT_DB_BLOB" \
           "test/utils/g2-s10b-pg-harness.ts $EXPECT_PGH_BLOB" "test/utils/g2-s10b-harness.ts $EXPECT_HARNESS_BLOB" "test/utils/g2-s10b-worker.cjs $EXPECT_WORKER_BLOB" \
           "test/utils/g2-s10b-fixtures.ts $EXPECT_FIXTURES_BLOB" "prisma/schema.prisma $EXPECT_SCHEMA_BLOB" \
           "prisma/migrations/$S10B_MIGRATION/migration.sql $EXPECT_MIGRATION_BLOB" "prisma/migrations/$S10B_MIGRATION/down.sql $EXPECT_DOWN_BLOB"; do set -- $pin
  [ "$(git -C "$W" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL S10-B proof file $1 blob mismatch"; fail 70; }; done
[ "$(git -C "$W" rev-parse HEAD:test/rls-g2-s10c.spec.ts)" = "$EXPECT_S10C_SPEC_BLOB" ] || { log "PRECONDITION_FAIL test/rls-g2-s10c.spec.ts blob != receipt $EXPECT_S10C_SPEC_BLOB"; fail 70; }
[ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] || { log "PRECONDITION_FAIL worktree not clean"; fail 70; }
[ ! -e "$(git -C "$W" rev-parse --git-path MERGE_HEAD)" ] || { log "PRECONDITION_FAIL MERGE_HEAD present"; fail 70; }
# the committed head must have been produced through the tracked lefthook hooks (installed by the S10-C gate)
[ -z "$(git -C "$W" config --get core.hooksPath)" ] || { log "PRECONDITION_FAIL core.hooksPath is set (alternate hook directory refused)"; fail 70; }
H=$(git -C "$W" rev-parse --git-path hooks); case "$H" in /*) ;; *) H="$W/$H";; esac
[ "$H" = "$W/.git/hooks" ] && [ -d "$H" ] && [ ! -L "$H" ] || { log "PRECONDITION_FAIL hooks dir [$H] is not the plain $W/.git/hooks directory"; fail 70; }
# symlink-aware (review A B-1 analogue): both hooks must be regular files, never symlinks (dangling or not)
for hk in pre-commit commit-msg; do [ -f "$H/$hk" ] && [ ! -L "$H/$hk" ] || { log "PRECONDITION_FAIL $H/$hk is not a regular file (absent or a symlink)"; fail 70; }; done
grep -q lefthook "$H/pre-commit" 2>/dev/null && grep -q lefthook "$H/commit-msg" 2>/dev/null \
  || { log "PRECONDITION_FAIL $H/pre-commit or commit-msg absent or not lefthook (hookless commit)"; fail 70; }
[ "$(sha "$H/pre-commit")" = "$EXPECT_HOOK_PRECOMMIT_SHA" ] && [ "$(sha "$H/commit-msg")" = "$EXPECT_HOOK_COMMITMSG_SHA" ] \
  || { log "PRECONDITION_FAIL hook sha256 pre-commit=$(sha "$H/pre-commit") commit-msg=$(sha "$H/commit-msg") != gate receipt hooks raw ($EXPECT_HOOK_PRECOMMIT_SHA / $EXPECT_HOOK_COMMITMSG_SHA)"; fail 70; }
# S10-C wiring: ScoutModule imports ObservationModule at HEAD (the S10-B binding required the opposite)
MOD_AT_HEAD=$(git -C "$W" show HEAD:src/scout/scout.module.ts) || { log "PRECONDITION_FAIL cannot read scout.module.ts at HEAD"; fail 70; }
grep -qF "ObservationModule" <<<"$MOD_AT_HEAD" || { log "PRECONDITION_FAIL scout.module.ts does not import ObservationModule (no S10-C wiring at HEAD)"; fail 70; }
# dependency tree: the ISOLATED real copy the S10-C gate made (not a symlink, not the donor, not a fresh npm ci), with the
# client the S10-C gate regenerated in the clone from the (unchanged) S10-B schema; the donor still holds the pre-S10-B client (never regenerated)
[ -d "$W/node_modules" ] && [ ! -L "$W/node_modules" ] || { log "PRECONDITION_FAIL $W/node_modules absent or a symlink (isolated copy required)"; fail 70; }
for d in "$W/node_modules" "$W/node_modules/.prisma/client" "$W/node_modules/@prisma/client"; do case "$(readlink -f "$d")" in "$W"/*) ;; *) log "PRECONDITION_FAIL $d resolves outside $W"; fail 70;; esac; done
[ "$(sha "$W/package-lock.json")" = "$EXPECT_PKG_LOCK_SHA" ] || { log "PRECONDITION_FAIL package-lock.json != base record"; fail 70; }
[ "$(sha "$W/node_modules/.package-lock.json")" = "$EXPECT_NM_LOCK_SHA" ] || { log "PRECONDITION_FAIL node_modules/.package-lock.json != donor record"; fail 70; }
[ "$(sha "$W/prisma/schema.prisma")" = "$EXPECT_SCHEMA_SHA" ] || { log "PRECONDITION_FAIL prisma/schema.prisma != S10-B d6d01f54"; fail 70; }
[ "$(sha "$W/node_modules/.prisma/client/index.d.ts")" = "$EXPECT_NM_CLIENT_SHA" ] || { log "PRECONDITION_FAIL generated client index.d.ts != S10-C gate receipt (no generate here; stale or foreign client)"; fail 70; }
[ "$(sha "$W/node_modules/.prisma/client/schema.prisma")" = "$EXPECT_NM_CLIENT_SCHEMA_SHA" ] || { log "PRECONDITION_FAIL generated client schema.prisma != S10-C gate receipt"; fail 70; }
CSCH=$(cat "$W/node_modules/.prisma/client/schema.prisma")
for m_ in ScoutRunDeclaration ScoutRunObservation ScoutRunSettledBasis; do grep -qE "^model $m_ \{" <<<"$CSCH" || { log "PRECONDITION_FAIL candidate client lacks $m_"; fail 70; }; done
[ "$(sha "$DONOR_NM/.prisma/client/index.d.ts" 2>/dev/null)" = "$DONOR_CLIENT_SHA" ] || { log "PRECONDITION_FAIL donor client changed (the in-clone generate must never touch $DONOR_NM)"; fail 70; }
[ -x "$W/node_modules/.bin/jest" ] && [ -x "$W/node_modules/.bin/ts-node" ] && [ -x "$W/node_modules/.bin/prisma" ] || { log "PRECONDITION_FAIL jest/ts-node/prisma missing"; fail 70; }
# tools: pinned PG 17.6 server binaries in the 1910a060 namespace, the real psql 18.6 client binary (CB1) and Node 20
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
PRV=$(cd "$W" && ./node_modules/.bin/prisma --version 2>/dev/null || true)
log "PRECONDITIONS_OK (pre-lock) $(ts) server='$PGV' psql='$PSQLV' node=$NODEV jest=$(cd "$W" && ./node_modules/.bin/jest --version) ts_node=$(cd "$W" && ./node_modules/.bin/ts-node --version 2>/dev/null) prisma=$(awk '/^prisma /{print $3}' <<<"$PRV")"
LOG=$R/s10c-pg-proof.log
{ [ -e "$SENT" ] || [ -L "$SENT" ]; } && { echo "REFUSED: $SENT exists; this proof runs once, no retry" >&2; exit 76; }
[ -e "$LOCK" ] || { echo "REFUSED: canonical lock file $LOCK absent; runtime setup created it and it is never deleted or recreated here" >&2; exit 75; }
exec 9>>"$LOCK"; flock -n 9 || { echo "REFUSED: canonical lock busy ($LOCK)" >&2; exit 75; }
[ "$(stat -c %i "$LOCK")" = "$EXPECT_LOCK_INODE" ] || { echo "REFUSED: $LOCK inode $(stat -c %i "$LOCK") != $EXPECT_LOCK_INODE (LOCK_ESTABLISHED.txt); not the canonical lock file" >&2; exit 75; }
( set -C; date -u +%FT%TZ > "$R/STARTED" ) 2>/dev/null || { echo "REFUSED: $R/STARTED exists (or is a symlink) at lock time; this proof runs once, no retry" >&2; exit 76; }   # O_EXCL one-shot marker (gate DELTA-2 analogue)
STAGE=preconditions
finish(){ local rc=$1
  ( cd "$R" && sha256sum s10c-pg-proof.log prelock.log $( [ -e jest.log ] && echo jest.log ) > RECEIPTS.sha256 2>/dev/null )
  echo "RC=$rc STAGE=$STAGE END=$(ts) HEAD=$(git -C "$W" rev-parse HEAD 2>/dev/null) LOCK_INODE=$(stat -c %i "$LOCK")" >"$SENT"
  log "END rc=$rc stage=$STAGE $(ts) (lock fd9 held until this exit; receipts=$R/RECEIPTS.sha256)"; exit "$rc"; }
fail(){ local rc=$1; log "STOP_FIRST_FAILURE stage=$STAGE rc=$rc $(ts)"
  if [ "$STARTED" = 1 ]; then
    local src=0; timeout -k 30 60 bash "$FIX" stop >>"$LOG" 2>&1 || src=$?
    local ssl; ssl=$(ss -ltn 2>/dev/null || true)
    log "CLEANUP_STOP rc=$src postgres_procs=$(pgrep -cx postgres || true) port${PORT}_listeners=$(grep -c ":$PORT " <<<"$ssl" || true) survivor_pid=$(head -1 "$LANE/pg-data/postmaster.pid" 2>/dev/null || echo none)"
  fi
  finish "$rc"; }
listeners(){ local s; s=$(ss -ltn 2>/dev/null || true); grep -c ":$PORT " <<<"$s" || true; }
portl(){ local s; s=$(ss -ltn 2>/dev/null || true); grep -c ":$1 " <<<"$s" || true; }
log "START $(ts) pid=$$ user=$(id -un) lock=$LOCK(held nonblocking fd9, inode $(stat -c %i "$LOCK")) head_expect=$EXPECT_HEAD fixture_expect=$EXPECT_FIXTURE_SHA"
# re-verify under the lock the state that could have moved since the pre-lock preconditions (cheap, read-only)
[ "$(sha "$FIX")" = "$EXPECT_FIXTURE_SHA" ] && [ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] && [ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] \
  && [ "$(sha "$W/node_modules/.prisma/client/index.d.ts")" = "$EXPECT_NM_CLIENT_SHA" ] && [ "$(sha "$DONOR_NM/.prisma/client/index.d.ts" 2>/dev/null)" = "$DONOR_CLIENT_SHA" ] \
  || { log "PRECONDITION_FAIL fixture/HEAD/worktree/client moved after the pre-lock preconditions"; fail 70; }
[ -z "$(git -C "$W" config --get core.hooksPath)" ] && [ "$(git -C "$W" rev-parse --git-path hooks)" = .git/hooks ] && [ -d "$H" ] && [ ! -L "$H" ] \
  && [ -f "$H/pre-commit" ] && [ ! -L "$H/pre-commit" ] && [ -f "$H/commit-msg" ] && [ ! -L "$H/commit-msg" ] \
  && [ "$(sha "$H/pre-commit")" = "$EXPECT_HOOK_PRECOMMIT_SHA" ] && [ "$(sha "$H/commit-msg")" = "$EXPECT_HOOK_COMMITMSG_SHA" ] \
  || { log "PRECONDITION_FAIL hook identity/hooksPath changed after the pre-lock preconditions"; fail 70; }
# ---- step 1 preflight (read-only): S10-B lane absent; lane port free; no postgres; other lanes under the runtime root (clusters/*
#      incl. clusters/s8-g, s9-b, s9-c, and proof-*/clusters/*) fingerprinted and never started
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
case " $OTHER0 " in *" clusters/s10-b:"*) ;; *) log "PREFLIGHT_FAIL retained S10-B lane not in the fingerprint set"; fail 71;; esac
[ -f "$S10B_LANE/pg-data/postgresql.conf" ] && [ -f "$S10B_LANE/pg-data/global/pg_control" ] || { log "PREFLIGHT_FAIL retained S10-B lane fingerprint incomplete (postgresql.conf / global/pg_control absent)"; fail 71; }
log "PREFLIGHT retained_s10b_lane=$S10B_LANE (fingerprinted; must be unchanged at end; never started)"
[ -e "$CLUSTERS" ] || log "PREFLIGHT clusters_dir=ABSENT (no clusters/* lane yet under the runtime root; proof-*/clusters/* scanned above)"
PORC0=$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)
log "PREFLIGHT_OK $(ts) lane=absent port$PORT=free postgres_procs=0 worktree_porcelain_sha=$PORC0 lock_inode=$(stat -c %i "$LOCK")"
# ---- step 2 init (bound 60 s)
STAGE=fixture-init; timeout -k 30 60 bash "$FIX" init >>"$LOG" 2>&1; rc=$?; log "FIXTURE_INIT rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^S10C_FIXTURE_INIT_OK data=$LANE/pg-data port=$PORT superuser=$ADMIN cluster_name=$MARKER socket=$SOCK " "$LOG" || { log "FIXTURE_INIT marker missing"; fail 72; }
# ---- step 3 start (bound 60 s)
STAGE=fixture-start; STARTED=1; timeout -k 30 60 bash "$FIX" start >>"$LOG" 2>&1; rc=$?; log "FIXTURE_START rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^S10C_FIXTURE_START_OK pid=" "$LOG" || { log "FIXTURE_START marker missing"; fail 72; }
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
STAGE=jest; log "JEST_START $(ts) cmd='./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s10b.spec.ts test/rls-g2-s10c.spec.ts --runInBand --ci' candidate_head=$G2_S10B_CANDIDATE_HEAD expect_tests=$EXPECT_TESTS_S10B+$EXPECT_TESTS_S10C"
( cd "$W" && timeout -k 30 1500 ./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s10b.spec.ts test/rls-g2-s10c.spec.ts --runInBand --ci ) >"$JLOG" 2>&1; JRC=$?
log "JEST_END rc=$JRC $(ts)"; grep -E '^(Test Suites|Tests|Snapshots|Time):' "$JLOG" | tee -a "$LOG"
grep -E 'requires its explicitly confirmed|unsupported or ambiguous connection option|requires a plain fixture password|connects only as a fixture matrix login role|candidate head, not the accepted base|not the attested candidate|uncommitted changes|G2 proof requires|server identity mismatch' "$JLOG" >/dev/null && log "GUARD_REFUSAL_OBSERVED_IN_JEST_LOG"
[ $JRC = 0 ] || fail $JRC
grep -qE "^Tests: +$EXPECT_TESTS passed, $EXPECT_TESTS total" "$JLOG" || { log "JEST_COUNT_FAIL expected 'Tests: $EXPECT_TESTS passed, $EXPECT_TESTS total' (got: $(grep -E '^Tests:' "$JLOG" | head -1))"; fail 72; }
grep -qE "^Test Suites: +2 passed, 2 total" "$JLOG" || { log "JEST_COUNT_FAIL expected 'Test Suites: 2 passed, 2 total' (got: $(grep -E '^Test Suites:' "$JLOG" | head -1))"; fail 72; }
JP=$(grep -E '^PASS ' "$JLOG" | awk '{print $2}' | sort | tr '\n' ' ')
[ "$JP" = "test/rls-g2-s10b.spec.ts test/rls-g2-s10c.spec.ts " ] || { log "JEST_COUNT_FAIL PASS lines [$JP] != the two specs"; fail 72; }
log "JEST_COUNT_OK tests=$EXPECT_TESTS (s10b=$EXPECT_TESTS_S10B + s10c=$EXPECT_TESTS_S10C pinned at HEAD) suites=2"
# ---- step 7 stop (bound 45 s + kill 30); data dir RETAINED (destroy only via separate grant: s10c-fixture.sh destroy)
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
[ ! -e "$S10B_LANE/pg-data/postmaster.pid" ] && [ ! -L "$S10B_LANE/pg-data/postmaster.pid" ] || { log "POST_FAIL retained S10-B lane postmaster.pid appeared"; fail 74; }
log "POST other_lanes_unchanged=[${OTHER0:-none}] retained_s10b_lane=unchanged,stopped refused_ports=[$REFUSED_LANE_PORTS] free"
[ "$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)" = "$PORC0" ] && [ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] || { log "POST_FAIL worktree changed"; fail 74; }
[ "$(sha "$W/node_modules/.prisma/client/index.d.ts")" = "$EXPECT_NM_CLIENT_SHA" ] || { log "POST_FAIL generated client changed during the proof"; fail 74; }
[ "$(sha "$DONOR_NM/.prisma/client/index.d.ts" 2>/dev/null)" = "$DONOR_CLIENT_SHA" ] || { log "POST_FAIL donor client changed during the proof"; fail 74; }
log "POST_OK $(ts) lock_still_held_fd9 inode=$(stat -c %i "$LOCK")"
STAGE=done; finish 0
