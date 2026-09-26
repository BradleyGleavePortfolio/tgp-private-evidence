#!/usr/bin/env bash
# S10-B real-PG proof — execution binding v1 (EXEC-D3A9F701). SOURCE ONLY: NOT RUN, NOT GRANTED.
# Derived by substitution from the S9-C binding execution/d3a9f701/s9c/binding/v2/s9c-pg-proof.sh (= accepted S9-B v3 +
# the v2 pipefail/SIGPIPE precondition fix; full diff in DELTA-from-s9c-v2.diff) with the S10-B deltas: standalone clone
# worktrees/d3a9-s10b whose candidate head is ONE gate commit on BASE = the S10-A landing commit (itself one commit on
# S10A_PARENT = e6f20300, the S9-C landing merge); lane port 55647 / s10b_super / g2_s10b_disposable / cluster s10b-disposable-pg17 / lane dirs
# runtime/clusters/s10-b + runtime/run/s10-b; S10-B SHIPS A MIGRATION: 173 applied (172 accepted + 20270124000000_
# scout_run_observation_expand, last applied = the S10-B dir), the three S10-B tables present, and the isolated
# node_modules client is the one the S10-B gate regenerated IN THE CLONE from the S10-B schema (EXPECT_NM_CLIENT_SHA from
# the gate receipt; the donor client is never used here and must still be the pre-S10-B client). Runs the NEW spec
# test/rls-g2-s10b.spec.ts exactly once via the repo jest + jest.rls.config.js; no retry, no inherited-proof replay.
# Single canonical lock holder: the nonblocking flock on execution/test-validation.lock is taken on fd 9 before any
# state change and held until this process exits — through stop, post checks and receipt hashing; the lock file is
# never deleted. First nonzero stops; the only cleanup attempted is a bounded fixture stop when this run started the
# postmaster. No autonomous cleanup is GUARANTEED: if the outer timeout kills bash, the stop does not run. What governs
# is the observed terminal evidence — sentinel/log lines, `pgrep -cx postgres`, the port listener count and any
# survivor pid the stop reports — not this header. Data dir RETAINED after stop (destroy = separate marker-gated grant).
# Pipefail rule (S9C-PROOF-1): never `cmd | grep -q`; producer output is captured first, then grepped as a here-string.
# Inner stage bounds: init 60 + start 60 + bootstrap 900 + identity 7x15 + jest 1500 + stop 75 = 2700 s soft sum.
# Usage (under the separate single-run PG grant, after the gate commit and fill): timeout -k 30 3900 bash .../binding/v1/s10b-pg-proof.sh
# Fill (parent): BASE_HEAD / BASE_TREE after S10-A lands; EXPECT_HEAD / EXPECT_TREE / EXPECT_MIGRATIONS_TREE / the six
# post-format EXPECT_*_BLOB / EXPECT_NM_CLIENT_SHA / EXPECT_NM_CLIENT_SCHEMA_SHA from the S10-B gate receipt
# d3a9f701/s10b/gate/HEAD-<12>.txt (lines head=, tree=, migrations_tree=, blob ..., postgen_client ...). README.md.
set -uo pipefail
D=/home/user/workspace/tgp-private-evidence/execution/d3a9f701/s10b/binding/v1
RUNTIME_ROOT=/home/user/workspace/execution/1910a060/runtime                     # 1910a060 runtime namespace (execution/1910a060/runtime/RUNTIME_SETUP_RECEIPT.md); the fixture carries the same literal and is cross-checked below
W=/home/user/workspace/worktrees/d3a9-s10b
DONOR_NM=/home/user/workspace/worktrees/1910a060-s8f/node_modules                 # read-only: must still hold the pre-S10-B client (the gate generated in the clone copy only)
R=$D/run; LOG=$R/s10b-pg-proof.log; SENT=$R/s10b-pg-proof.sentinel; JLOG=$R/jest.log
LOCK=/home/user/workspace/execution/test-validation.lock
# ---- pins: head pins are filled by the parent AFTER the S10-A landing and the S10-B gate commit; placeholders are refused.
BASE_HEAD=__FILL_BASE_HEAD__                                                   # S10-A landing commit (= S10-B gate PINS.env BASE)
BASE_TREE=__FILL_BASE_TREE__                                                   # git rev-parse "$BASE_HEAD^{tree}"
S10A_PARENT=e6f20300b495fa9eee9539ae58d30e3b60e5a78c                           # BASE_HEAD^ (S9-C landing merge = integration/importer tip S10-A lands on)
HARNESS_BASE_HEAD=a4af8e330bd4d6f882f0aebd411200b76d651aba                     # kept: G2_S10B_BASE_HEAD / bootstrap BASE_HEAD literal; ancestor of BASE_HEAD (checked); a4af8e33..e6f20300 touches no prisma
EXPECT_HEAD=__FILL_EXPECT_HEAD__                                               # gate receipt head=
EXPECT_TREE=__FILL_EXPECT_TREE__                                               # gate receipt tree=
EXPECT_MIGRATIONS_TREE=__FILL_EXPECT_MIGRATIONS_TREE__                         # gate receipt migrations_tree= (git rev-parse HEAD:prisma/migrations)
EXPECT_SPEC_BLOB=__FILL_SPEC_BLOB__                                            # blob test/rls-g2-s10b.spec.ts (receipt; devloop-2 bytes hash to b89fec1cb9254a2475908154b1109f16585af0b0)
EXPECT_DB_BLOB=__FILL_DB_BLOB__                                                # blob test/utils/g2-s10b-db.ts (receipt; devloop-2: 3375f08ba0130bee8f20fb8a4f395a8fac4a5e10)
EXPECT_PGH_BLOB=__FILL_PGH_BLOB__                                              # blob test/utils/g2-s10b-pg-harness.ts (receipt; devloop-2: 7cf6d63308d6a2150626ad89d759366a6644d2ec)
EXPECT_HARNESS_BLOB=__FILL_HARNESS_BLOB__                                      # blob test/utils/g2-s10b-harness.ts (receipt; devloop-2: 9956aff77a5664e748a30673760c1a3824c44a7e)
EXPECT_WORKER_BLOB=__FILL_WORKER_BLOB__                                        # blob test/utils/g2-s10b-worker.cjs (receipt; devloop-2: e0af841268a03dbe5fc3db25e7e57a7bfe9f275f)
EXPECT_FIXTURES_BLOB=__FILL_FIXTURES_BLOB__                                    # blob test/utils/g2-s10b-fixtures.ts (receipt; devloop-2: 8055dbefa6a4008a6e04f5f851c8d535f755dee1)
# prettier-independent blobs (no parser / .prettierignore), git hash-object --no-filters on the devloop-2 POSTFORMAT bytes (read-only; unchanged by devloop-2):
EXPECT_BOOTSTRAP_BLOB=3230568302506413d71507c5181525d5af674e45                 # test/utils/g2-s10b-bootstrap.sh (sha256 3fc3f21d…80df, mode 755)
EXPECT_SCHEMA_BLOB=f86c1f5df722e855047899abd483f621b42dabe0                    # prisma/schema.prisma (S10-B, sha256 d6d01f54…eb96)
EXPECT_MIGRATION_BLOB=695c694d30aa46f08e761a44d54797d80a5e318d                 # S10-B migration.sql (sha256 345f12de…aa15)
EXPECT_DOWN_BLOB=b5e5243ef99be16794972e63fc956378e47ca7fb                      # S10-B down.sql (sha256 aee7c735…6905)
EXPECT_FIXTURE_SHA=7d9ee89b4333332ea42adcadf538c68c6815127e161d8941db125ac9873120e8                                       # sha256 of binding/v1/s10b-fixture.sh (frozen with this file; BINDING.sha256)
S10A_FREEZE=/home/user/workspace/tgp-private-evidence/execution/d3a9f701/s10a/land/FREEZE.sha256
S10A_FREEZE_SHA=d54aee78dcc35910200a3c8db93ecff7305a95d1c34a65985e998ad1c71c398a
S10B_MIGRATION=20270124000000_scout_run_observation_expand
BASE_MIGRATIONS_TREE=654550cb99b55473429a9c60ee08319e1b649106                  # BASE:prisma/migrations (172; same tree at a4af8e33 and e6f20300; S10-A touches no prisma)
EXPECT_MIGRATIONS=173
# exact committed delta BASE..HEAD (the 16 S10-B owned paths; sorted, space-separated)
EXPECT_DELTA="prisma/migrations/$S10B_MIGRATION/down.sql prisma/migrations/$S10B_MIGRATION/migration.sql prisma/schema.prisma src/scout/induction/observation.controller.ts src/scout/induction/observation.dto.ts src/scout/induction/observation.module.ts src/scout/induction/observation.service.ts test/rls-g2-s10b.spec.ts test/scout/induction/observation.controller.spec.ts test/scout/induction/observation.service.spec.ts test/utils/g2-s10b-bootstrap.sh test/utils/g2-s10b-db.ts test/utils/g2-s10b-fixtures.ts test/utils/g2-s10b-harness.ts test/utils/g2-s10b-pg-harness.ts test/utils/g2-s10b-worker.cjs"
# ---- tool pins: from the 1910a060 runtime setup receipt (compare only, never adjusted at run time); identical to S9-C v2.
EXPECT_POSTGRES_SHA=23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a
EXPECT_INITDB_SHA=b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a
EXPECT_PGCTL_SHA=af53d826845af4679a0aaba2bda319f5e527f3b94f3794c67fa174049c9b9401
PSQL=/usr/lib/postgresql/18/bin/psql                # CB1: the real client binary, not the /usr/bin/psql pg_wrapper dispatcher
EXPECT_PSQL_REAL_SHA=d1108fdb45b87f2313d7acfbb91a0a65ca97c6c2195f15d8ae9295121029ef67
EXPECT_TESTS=24                                     # it() count in test/rls-g2-s10b.spec.ts (grep -cE '^\s*it\(' on the devloop-2 bytes 5f21ef89; no skip/only/todo/xit/fit; re-checked at HEAD below)
EXPECT_LOCK_INODE=692282                            # execution/d3a9f701/runtime/LOCK_ESTABLISHED.txt (inode=692282)
EXPECT_NODE_SHA=a03953a7b16bff002b94d6fb58ada900b68241cbcaee6efc400b20dadd36dddc       # node v20.x
EXPECT_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44    # node_modules/.package-lock.json (donor copy; package-lock unchanged since 93389265)
EXPECT_NM_CLIENT_SHA=__FILL_NM_CLIENT_SHA__         # $W/node_modules/.prisma/client/index.d.ts as regenerated by the S10-B gate (receipt postgen_client index_dts=)
EXPECT_NM_CLIENT_SCHEMA_SHA=__FILL_NM_CLIENT_SCHEMA_SHA__   # $W/node_modules/.prisma/client/schema.prisma (receipt postgen_client schema=)
DONOR_CLIENT_SHA=9042e713ba5678c99959a345b7b18a60dfc186b2c7d890b8d9c3ed5c8f4edcc6      # pre-S10-B client (BASE schema 0eb41f9a); EXPECT_NM_CLIENT_SHA must differ from it
EXPECT_SCHEMA_SHA=d6d01f546f6c7988d93bdd60588e421bf6ff0a56b312f85eee962e0a6be0eb96   # prisma/schema.prisma at the S10-B head (never reflowed)
EXPECT_PKG_LOCK_SHA=b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55   # package-lock.json (unchanged since 93389265)
DIST=$RUNTIME_ROOT/pg17/dist; CLUSTERS=$RUNTIME_ROOT/clusters; LANE=$CLUSTERS/s10-b; SOCK=$RUNTIME_ROOT/run/s10-b
PORT=55647; DBNAME=g2_s10b_disposable; ADMIN=s10b_super; FIXPASS=s10b_local_synthetic
MARKER=s10b-disposable-pg17; DB_MARKER=s10b-g2-run-observation-synthetic-disposable-fixture-safe-to-drop
FIX=$D/s10b-fixture.sh
export GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1 NODE_OPTIONS=--max-old-space-size=4096 CHECKPOINT_DISABLE=1 \
       PRISMA_HIDE_UPDATE_MESSAGE=1 PRISMA_GENERATE_SKIP_AUTOINSTALL=1 npm_config_offline=true npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false \
       npm_config_cache=$RUNTIME_ROOT/npm-cache XDG_CACHE_HOME=$RUNTIME_ROOT/xdg-cache
# S10-B-only identity: exactly the G2_S10B_* names the guard/harness/bootstrap read (G2_S10B_DATABASE_URL, _CONFIRM, _PASSWORD,
# _PSQL, _DATA_DIRECTORY, _SERVER_VERSION, _CANDIDATE_HEAD). G2_S10B_BASE_HEAD is a source literal, never read from env;
# G2_S10B_WORKER is set by the harness for its own children only. Every other inherited G2_* is unset.
for v in $(compgen -e | grep -E '^G2_' | grep -vE '^G2_S10B_'); do unset "$v"; done
unset G2_S10B_WORKER
export G2_S10B_DATABASE_URL="postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=4" \
       G2_S10B_CONFIRM="$DBNAME:$PORT" G2_S10B_PASSWORD=$FIXPASS G2_S10B_PSQL=$PSQL \
       G2_S10B_DATA_DIRECTORY=$LANE/pg-data G2_S10B_SERVER_VERSION=170006 \
       G2_S10B_CANDIDATE_HEAD=$EXPECT_HEAD
export S10B_RUNNER_PID=$$ S10B_STOP_TIMEOUT=45
mkdir -p "$R"
# sentinel: an occupied path (file or any symlink, dangling or not) refuses (review A B-1 analogue)
{ [ -e "$SENT" ] || [ -L "$SENT" ]; } && { echo "REFUSED: $SENT exists; this proof runs once, no retry" >&2; exit 76; }
ts(){ date -u +%FT%TZ; }
log(){ echo "$*" | tee -a "$LOG"; }
sha(){ sha256sum "$1" | cut -c1-64; }
# ---- preconditions (read-only) run BEFORE the lock and before anything can write the sentinel (review B1): a stale pin
# or shape mismatch exits here with PRELOCK_REFUSED in $R/prelock.log and does NOT consume the single run. fail()/finish()
# are redefined after the lock is taken; everything below the lock re-verifies only what could move in between.
STAGE=preconditions-prelock; STARTED=0; LOG=$R/prelock.log
fail(){ log "PRELOCK_REFUSED stage=$STAGE rc=$1 $(ts) (no lock taken, no sentinel written; the run is not consumed)"; exit "$1"; }
log "PRELOCK_START $(ts) pid=$$ user=$(id -un) head_expect=$EXPECT_HEAD fixture_expect=$EXPECT_FIXTURE_SHA"
case "$BASE_HEAD$BASE_TREE$EXPECT_HEAD$EXPECT_TREE$EXPECT_MIGRATIONS_TREE$EXPECT_SPEC_BLOB$EXPECT_DB_BLOB$EXPECT_PGH_BLOB$EXPECT_HARNESS_BLOB$EXPECT_WORKER_BLOB$EXPECT_FIXTURES_BLOB$EXPECT_BOOTSTRAP_BLOB$EXPECT_FIXTURE_SHA$EXPECT_NM_CLIENT_SHA$EXPECT_NM_CLIENT_SCHEMA_SHA$PORT$RUNTIME_ROOT$EXPECT_POSTGRES_SHA$EXPECT_INITDB_SHA$EXPECT_PGCTL_SHA$EXPECT_PSQL_REAL_SHA$EXPECT_NODE_SHA$EXPECT_NM_LOCK_SHA" in *__*) log "PRECONDITION_FAIL pins not filled (proposal stage: base, head, blobs, client or tool pins; README.md)"; fail 70;; esac
[ "$EXPECT_HEAD" != "$BASE_HEAD" ] || { log "PRECONDITION_FAIL EXPECT_HEAD is the base, not a candidate"; fail 70; }
[ "$EXPECT_NM_CLIENT_SHA" != "$DONOR_CLIENT_SHA" ] || { log "PRECONDITION_FAIL EXPECT_NM_CLIENT_SHA is the pre-S10-B donor client (no S10-B generate recorded)"; fail 70; }
[ "$(sha "$FIX")" = "$EXPECT_FIXTURE_SHA" ] || { log "PRECONDITION_FAIL fixture sha256 mismatch"; fail 70; }
# the fixture must carry exactly this runner's lane constants (whole-line, literal): one runtime root, one port, one marker
FIXTXT=$(cat "$FIX")
grep -qx "RUNTIME_ROOT=$RUNTIME_ROOT" <<<"$FIXTXT" || { log "PRECONDITION_FAIL fixture RUNTIME_ROOT line != $RUNTIME_ROOT"; fail 70; }
grep -qx "PORT=$PORT; SUPER=$ADMIN; PASS=$FIXPASS; MARKER=$MARKER" <<<"$FIXTXT" || { log "PRECONDITION_FAIL fixture PORT/SUPER/PASS/MARKER line != runner (PORT=$PORT ADMIN=$ADMIN MARKER=$MARKER)"; fail 70; }
grep -qx "LANE=\$RUNTIME_ROOT/clusters/s10-b" <<<"$FIXTXT" && grep -qx "DATA=\$LANE/pg-data; LOG=\$LANE/pg.log; SOCK=\$RUNTIME_ROOT/run/s10-b" <<<"$FIXTXT" || { log "PRECONDITION_FAIL fixture lane/socket lines != clusters/s10-b + run/s10-b"; fail 70; }
[ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] || { log "PRECONDITION_FAIL HEAD != $EXPECT_HEAD"; fail 70; }
[ "$(git -C "$W" rev-parse 'HEAD^{tree}')" = "$EXPECT_TREE" ] || { log "PRECONDITION_FAIL tree mismatch"; fail 70; }
[ "$(git -C "$W" rev-parse "$BASE_HEAD^{tree}")" = "$BASE_TREE" ] || { log "PRECONDITION_FAIL base tree mismatch"; fail 70; }
[ "$(git -C "$W" rev-parse HEAD^)" = "$BASE_HEAD" ] || { log "PRECONDITION_FAIL HEAD^ != $BASE_HEAD (the gate makes exactly one commit on BASE)"; fail 70; }
[ "$(git -C "$W" rev-parse "$BASE_HEAD^")" = "$S10A_PARENT" ] || { log "PRECONDITION_FAIL BASE^ != $S10A_PARENT (S10-A is one commit on $S10A_PARENT)"; fail 70; }
git -C "$W" merge-base --is-ancestor "$HARNESS_BASE_HEAD" "$BASE_HEAD" || { log "PRECONDITION_FAIL harness base $HARNESS_BASE_HEAD not an ancestor of $BASE_HEAD"; fail 70; }
# exact delta: BASE..HEAD = the 16 S10-B paths; S10A_PARENT..BASE = the 14 S10-A FREEZE paths at their frozen bytes
DELTA=$(git -C "$W" diff --name-only "$BASE_HEAD" HEAD | sort | tr '\n' ' ' | sed 's/ $//')
[ "$DELTA" = "$EXPECT_DELTA" ] || { log "PRECONDITION_FAIL BASE..HEAD delta [$DELTA] != the 16 S10-B paths"; fail 70; }
[ -f "$S10A_FREEZE" ] && [ "$(sha "$S10A_FREEZE")" = "$S10A_FREEZE_SHA" ] || { log "PRECONDITION_FAIL S10-A FREEZE file absent or sha mismatch"; fail 70; }
S10A_FILES=$(awk '$1=="POST"{print $3}' "$S10A_FREEZE" | sort | tr '\n' ' ' | sed 's/ $//')
ADELTA=$(git -C "$W" diff --name-only "$S10A_PARENT" "$BASE_HEAD" | sort | tr '\n' ' ' | sed 's/ $//')
[ "$ADELTA" = "$S10A_FILES" ] || { log "PRECONDITION_FAIL $S10A_PARENT..BASE delta != the S10-A FREEZE paths"; fail 70; }
while read -r tag s p; do [ "$tag" = POST ] || continue
  GOT=$(git -C "$W" show "HEAD:$p" | sha256sum | cut -c1-64); [ "$GOT" = "$s" ] || { log "PRECONDITION_FAIL S10-A $p at HEAD != FREEZE"; fail 70; }
done < "$S10A_FREEZE"
# prisma: the candidate delta is exactly schema + the S10-B migration pair (vs BASE and vs the harness base); 173 dirs
PD=$(git -C "$W" diff --name-only "$HARNESS_BASE_HEAD" HEAD -- prisma | sort | tr '\n' ' ' | sed 's/ $//')
[ "$PD" = "prisma/migrations/$S10B_MIGRATION/down.sql prisma/migrations/$S10B_MIGRATION/migration.sql prisma/schema.prisma" ] || { log "PRECONDITION_FAIL prisma delta vs harness base [$PD]"; fail 70; }
[ -z "$(git -C "$W" diff --name-only --diff-filter=DMR "$BASE_HEAD" HEAD -- prisma/migrations)" ] || { log "PRECONDITION_FAIL an accepted migration was modified/renamed/deleted"; fail 70; }
[ -z "$(git -C "$W" diff --name-only "$BASE_HEAD" HEAD -- package.json package-lock.json docs scripts src/scout/scout.module.ts)" ] || { log "PRECONDITION_FAIL dependency manifests / docs / scripts / scout.module.ts differ from base"; fail 70; }
[ "$(git -C "$W" rev-parse "$BASE_HEAD:prisma/migrations")" = "$BASE_MIGRATIONS_TREE" ] || { log "PRECONDITION_FAIL BASE prisma/migrations tree != $BASE_MIGRATIONS_TREE"; fail 70; }
[ "$(git -C "$W" rev-parse HEAD:prisma/migrations)" = "$EXPECT_MIGRATIONS_TREE" ] || { log "PRECONDITION_FAIL HEAD prisma/migrations tree != gate receipt $EXPECT_MIGRATIONS_TREE"; fail 70; }
HMIG=$(git -C "$W" ls-tree -d --name-only HEAD prisma/migrations/ | sed 's|^prisma/migrations/||' | sort)
[ "$(wc -l <<<"$HMIG")" = "$EXPECT_MIGRATIONS" ] && [ "$(tail -1 <<<"$HMIG")" = "$S10B_MIGRATION" ] || { log "PRECONDITION_FAIL HEAD migrations $(wc -l <<<"$HMIG")/$(tail -1 <<<"$HMIG") != $EXPECT_MIGRATIONS/$S10B_MIGRATION"; fail 70; }
# harness literals must match this runner (lane identity, base pin, migrations): read from the committed bytes at HEAD
BOOT_AT_HEAD=$(git -C "$W" show HEAD:test/utils/g2-s10b-bootstrap.sh) && DBTS_AT_HEAD=$(git -C "$W" show HEAD:test/utils/g2-s10b-db.ts) \
  && PGH_AT_HEAD=$(git -C "$W" show HEAD:test/utils/g2-s10b-pg-harness.ts) && SPEC_AT_HEAD=$(git -C "$W" show HEAD:test/rls-g2-s10b.spec.ts) || { log "PRECONDITION_FAIL cannot read harness bytes at HEAD"; fail 70; }
grep -qx "BASE_HEAD=$HARNESS_BASE_HEAD" <<<"$BOOT_AT_HEAD" || { log "PRECONDITION_FAIL bootstrap BASE_HEAD != $HARNESS_BASE_HEAD"; fail 70; }
grep -qx "CLUSTER_MARKER=$MARKER" <<<"$BOOT_AT_HEAD" && grep -qx "DB_MARKER=$DB_MARKER" <<<"$BOOT_AT_HEAD" \
  && grep -qx "EXPECTED_MIGRATIONS=$EXPECT_MIGRATIONS" <<<"$BOOT_AT_HEAD" && grep -qx "S10B_MIGRATION=$S10B_MIGRATION" <<<"$BOOT_AT_HEAD" || { log "PRECONDITION_FAIL bootstrap marker/migration literals != runner"; fail 70; }
grep -qF "export const EXPECTED_MIGRATIONS = $EXPECT_MIGRATIONS;" <<<"$PGH_AT_HEAD" && grep -qF "export const S10B_MIGRATION = '$S10B_MIGRATION';" <<<"$PGH_AT_HEAD" || { log "PRECONDITION_FAIL g2-s10b-pg-harness.ts migration literals != runner"; fail 70; }
grep -qF "G2_S10B_DATABASE = '$DBNAME'" <<<"$DBTS_AT_HEAD" && grep -qF "G2_S10B_ROLE = '$ADMIN'" <<<"$DBTS_AT_HEAD" \
  && grep -qF "G2_S10B_CLUSTER_MARKER = '$MARKER'" <<<"$DBTS_AT_HEAD" && grep -qF "'$DB_MARKER'" <<<"$DBTS_AT_HEAD" \
  && grep -qF "G2_S10B_BASE_HEAD = '$HARNESS_BASE_HEAD'" <<<"$DBTS_AT_HEAD" || { log "PRECONDITION_FAIL g2-s10b-db.ts literals != runner"; fail 70; }
! grep -qE "^ +'$PORT',\$" <<<"$DBTS_AT_HEAD" || { log "PRECONDITION_FAIL lane port $PORT is in the S10-B guard's REFUSED_PORTS"; fail 70; }
grep -qE "^ +'55646',\$" <<<"$DBTS_AT_HEAD" || { log "PRECONDITION_FAIL S9-C lane port 55646 missing from the S10-B guard's REFUSED_PORTS"; fail 70; }
NT=$(grep -cE '^\s*it\(' <<<"$SPEC_AT_HEAD" || true); [ "$NT" = "$EXPECT_TESTS" ] || { log "PRECONDITION_FAIL it() count in committed test/rls-g2-s10b.spec.ts $NT != $EXPECT_TESTS"; fail 70; }
for pin in "test/rls-g2-s10b.spec.ts $EXPECT_SPEC_BLOB" "test/utils/g2-s10b-bootstrap.sh $EXPECT_BOOTSTRAP_BLOB" "test/utils/g2-s10b-db.ts $EXPECT_DB_BLOB" \
           "test/utils/g2-s10b-pg-harness.ts $EXPECT_PGH_BLOB" "test/utils/g2-s10b-harness.ts $EXPECT_HARNESS_BLOB" "test/utils/g2-s10b-worker.cjs $EXPECT_WORKER_BLOB" \
           "test/utils/g2-s10b-fixtures.ts $EXPECT_FIXTURES_BLOB" "prisma/schema.prisma $EXPECT_SCHEMA_BLOB" \
           "prisma/migrations/$S10B_MIGRATION/migration.sql $EXPECT_MIGRATION_BLOB" "prisma/migrations/$S10B_MIGRATION/down.sql $EXPECT_DOWN_BLOB"; do set -- $pin
  [ "$(git -C "$W" rev-parse "HEAD:$1")" = "$2" ] || { log "PRECONDITION_FAIL S10-B proof file $1 blob mismatch"; fail 70; }; done
[ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] || { log "PRECONDITION_FAIL worktree not clean"; fail 70; }
[ ! -e "$(git -C "$W" rev-parse --git-path MERGE_HEAD)" ] || { log "PRECONDITION_FAIL MERGE_HEAD present"; fail 70; }
# the committed head must have been produced through the tracked lefthook hooks (installed by the S10-B gate)
H=$(git -C "$W" rev-parse --git-path hooks); case "$H" in /*) ;; *) H="$W/$H";; esac
# symlink-aware (review A B-1 analogue): both hooks must be regular files, never symlinks (dangling or not)
for hk in pre-commit commit-msg; do [ -f "$H/$hk" ] && [ ! -L "$H/$hk" ] || { log "PRECONDITION_FAIL $H/$hk is not a regular file (absent or a symlink)"; fail 70; }; done
grep -q lefthook "$H/pre-commit" 2>/dev/null && grep -q lefthook "$H/commit-msg" 2>/dev/null \
  || { log "PRECONDITION_FAIL $H/pre-commit or commit-msg absent or not lefthook (hookless commit)"; fail 70; }
# the S10-B module is not mounted (S10-C wiring); the importer contract is BASE's
MOD_AT_HEAD=$(git -C "$W" show HEAD:src/scout/scout.module.ts) || { log "PRECONDITION_FAIL cannot read scout.module.ts at HEAD"; fail 70; }
! grep -qF "ObservationModule" <<<"$MOD_AT_HEAD" || { log "PRECONDITION_FAIL scout.module.ts references ObservationModule (S10-C wiring in an S10-B head)"; fail 70; }
# dependency tree: the ISOLATED real copy the S10-B gate made (not a symlink, not the donor, not a fresh npm ci), with the
# client the gate regenerated from the S10-B schema; the donor still holds the pre-S10-B client (never regenerated)
[ -d "$W/node_modules" ] && [ ! -L "$W/node_modules" ] || { log "PRECONDITION_FAIL $W/node_modules absent or a symlink (isolated copy required)"; fail 70; }
for d in "$W/node_modules" "$W/node_modules/.prisma/client" "$W/node_modules/@prisma/client"; do case "$(readlink -f "$d")" in "$W"/*) ;; *) log "PRECONDITION_FAIL $d resolves outside $W"; fail 70;; esac; done
[ "$(sha "$W/package-lock.json")" = "$EXPECT_PKG_LOCK_SHA" ] || { log "PRECONDITION_FAIL package-lock.json != base record"; fail 70; }
[ "$(sha "$W/node_modules/.package-lock.json")" = "$EXPECT_NM_LOCK_SHA" ] || { log "PRECONDITION_FAIL node_modules/.package-lock.json != donor record"; fail 70; }
[ "$(sha "$W/prisma/schema.prisma")" = "$EXPECT_SCHEMA_SHA" ] || { log "PRECONDITION_FAIL prisma/schema.prisma != S10-B d6d01f54"; fail 70; }
[ "$(sha "$W/node_modules/.prisma/client/index.d.ts")" = "$EXPECT_NM_CLIENT_SHA" ] || { log "PRECONDITION_FAIL generated client index.d.ts != S10-B gate receipt (no generate here; stale or foreign client)"; fail 70; }
[ "$(sha "$W/node_modules/.prisma/client/schema.prisma")" = "$EXPECT_NM_CLIENT_SCHEMA_SHA" ] || { log "PRECONDITION_FAIL generated client schema.prisma != S10-B gate receipt"; fail 70; }
CSCH=$(cat "$W/node_modules/.prisma/client/schema.prisma")
for m_ in ScoutRunDeclaration ScoutRunObservation ScoutRunSettledBasis; do grep -qE "^model $m_ \{" <<<"$CSCH" || { log "PRECONDITION_FAIL candidate client lacks $m_"; fail 70; }; done
[ "$(sha "$DONOR_NM/.prisma/client/index.d.ts" 2>/dev/null)" = "$DONOR_CLIENT_SHA" ] || { log "PRECONDITION_FAIL donor client changed (the S10-B generate must never touch $DONOR_NM)"; fail 70; }
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
LOG=$R/s10b-pg-proof.log
{ [ -e "$SENT" ] || [ -L "$SENT" ]; } && { echo "REFUSED: $SENT exists; this proof runs once, no retry" >&2; exit 76; }
[ -e "$LOCK" ] || { echo "REFUSED: canonical lock file $LOCK absent; runtime setup created it and it is never deleted or recreated here" >&2; exit 75; }
exec 9>>"$LOCK"; flock -n 9 || { echo "REFUSED: canonical lock busy ($LOCK)" >&2; exit 75; }
[ "$(stat -c %i "$LOCK")" = "$EXPECT_LOCK_INODE" ] || { echo "REFUSED: $LOCK inode $(stat -c %i "$LOCK") != $EXPECT_LOCK_INODE (LOCK_ESTABLISHED.txt); not the canonical lock file" >&2; exit 75; }
STAGE=preconditions
finish(){ local rc=$1
  ( cd "$R" && sha256sum s10b-pg-proof.log prelock.log $( [ -e jest.log ] && echo jest.log ) > RECEIPTS.sha256 2>/dev/null )
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
log "START $(ts) pid=$$ user=$(id -un) lock=$LOCK(held nonblocking fd9, inode $(stat -c %i "$LOCK")) head_expect=$EXPECT_HEAD fixture_expect=$EXPECT_FIXTURE_SHA"
# re-verify under the lock the state that could have moved since the pre-lock preconditions (cheap, read-only)
[ "$(sha "$FIX")" = "$EXPECT_FIXTURE_SHA" ] && [ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] && [ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] \
  && [ "$(sha "$W/node_modules/.prisma/client/index.d.ts")" = "$EXPECT_NM_CLIENT_SHA" ] && [ "$(sha "$DONOR_NM/.prisma/client/index.d.ts" 2>/dev/null)" = "$DONOR_CLIENT_SHA" ] \
  || { log "PRECONDITION_FAIL fixture/HEAD/worktree/client moved after the pre-lock preconditions"; fail 70; }
# ---- step 1 preflight (read-only): S10-B lane absent; lane port free; no postgres; other lanes under the runtime root (clusters/*
#      incl. clusters/s8-g, s9-b, s9-c, and proof-*/clusters/*) fingerprinted and never started
STAGE=preflight
[ ! -e "$LANE" ] && [ ! -L "$LANE" ] || { log "PREFLIGHT_FAIL $LANE exists (fresh init only; never adopt)"; fail 71; }
[ ! -e "$SOCK" ] || [ -z "$(ls -A "$SOCK" 2>/dev/null)" ] || { log "PREFLIGHT_FAIL socket dir $SOCK not empty"; fail 71; }
L=$(listeners); [ "$L" = 0 ] || { log "PREFLIGHT_FAIL port $PORT listeners=$L"; fail 71; }
P=$(pgrep -cx postgres || true); [ "$P" = 0 ] || { log "PREFLIGHT_FAIL postgres procs=$P (another lane live; this proof never shares a server)"; fail 71; }
OTHER0=""
for d in "$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-*/clusters/*/; do [ -d "$d" ] || continue; [ "${d%/}" != "$LANE" ] || continue; n=${d#$RUNTIME_ROOT/}; n=${n%/}
  [ ! -e "$d/pg-data/postmaster.pid" ] && [ ! -L "$d/pg-data/postmaster.pid" ] || { log "PREFLIGHT_FAIL $n postmaster.pid present"; fail 71; }
  h="$n:$(sha "$d/pg-data/postgresql.conf" 2>/dev/null || echo ABSENT):$(sha "$d/pg-data/global/pg_control" 2>/dev/null || echo ABSENT)"; OTHER0="$OTHER0 $h"
  log "PREFLIGHT other_lane=$h (must be unchanged at end; never started)"; done
[ -e "$CLUSTERS" ] || log "PREFLIGHT clusters_dir=ABSENT (no clusters/* lane yet under the runtime root; proof-*/clusters/* scanned above)"
PORC0=$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)
log "PREFLIGHT_OK $(ts) lane=absent port$PORT=free postgres_procs=0 worktree_porcelain_sha=$PORC0 lock_inode=$(stat -c %i "$LOCK")"
# ---- step 2 init (bound 60 s)
STAGE=fixture-init; timeout -k 30 60 bash "$FIX" init >>"$LOG" 2>&1; rc=$?; log "FIXTURE_INIT rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^S10B_FIXTURE_INIT_OK data=$LANE/pg-data port=$PORT superuser=$ADMIN cluster_name=$MARKER socket=$SOCK " "$LOG" || { log "FIXTURE_INIT marker missing"; fail 72; }
# ---- step 3 start (bound 60 s)
STAGE=fixture-start; STARTED=1; timeout -k 30 60 bash "$FIX" start >>"$LOG" 2>&1; rc=$?; log "FIXTURE_START rc=$rc $(ts)"; [ $rc = 0 ] || fail $rc
grep -q "^S10B_FIXTURE_START_OK pid=" "$LOG" || { log "FIXTURE_START marker missing"; fail 72; }
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
STAGE=jest; log "JEST_START $(ts) cmd='./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s10b.spec.ts --runInBand --ci' candidate_head=$G2_S10B_CANDIDATE_HEAD"
( cd "$W" && timeout -k 30 1500 ./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s10b.spec.ts --runInBand --ci ) >"$JLOG" 2>&1; JRC=$?
log "JEST_END rc=$JRC $(ts)"; grep -E '^(Test Suites|Tests|Snapshots|Time):' "$JLOG" | tee -a "$LOG"
grep -E 'requires its explicitly confirmed|unsupported or ambiguous connection option|requires a plain fixture password|connects only as a fixture matrix login role|candidate head, not the accepted base|not the attested candidate|uncommitted changes|G2 proof requires|server identity mismatch' "$JLOG" >/dev/null && log "GUARD_REFUSAL_OBSERVED_IN_JEST_LOG"
[ $JRC = 0 ] || fail $JRC
grep -qE "^Tests: +$EXPECT_TESTS passed, $EXPECT_TESTS total" "$JLOG" || { log "JEST_COUNT_FAIL expected 'Tests: $EXPECT_TESTS passed, $EXPECT_TESTS total' (got: $(grep -E '^Tests:' "$JLOG" | head -1))"; fail 72; }
log "JEST_COUNT_OK tests=$EXPECT_TESTS"
# ---- step 7 stop (bound 45 s + kill 30); data dir RETAINED (destroy only via separate grant: s10b-fixture.sh destroy)
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
log "POST other_lanes_unchanged=[${OTHER0:-none}]"
[ "$(git -C "$W" status --porcelain --untracked-files=all | sha256sum | cut -c1-64)" = "$PORC0" ] && [ "$(git -C "$W" rev-parse HEAD)" = "$EXPECT_HEAD" ] || { log "POST_FAIL worktree changed"; fail 74; }
[ "$(sha "$W/node_modules/.prisma/client/index.d.ts")" = "$EXPECT_NM_CLIENT_SHA" ] || { log "POST_FAIL generated client changed during the proof"; fail 74; }
[ "$(sha "$DONOR_NM/.prisma/client/index.d.ts" 2>/dev/null)" = "$DONOR_CLIENT_SHA" ] || { log "POST_FAIL donor client changed during the proof"; fail 74; }
log "POST_OK $(ts) lock_still_held_fd9 inode=$(stat -c %i "$LOCK")"
STAGE=done; finish 0
