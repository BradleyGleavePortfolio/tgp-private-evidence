#!/usr/bin/env bash
# EXEC-42D8C5B5 PROOF-RT — S11 real-PG lane runner (parameterized; built from fa72efb2 s11a2/binding/v2 + s11d/binding/v2).
# Usage: lane-s11.sh <HEAD_SHA> <RUN_DIR> [--stages bootstrap,rls-g2-s11,journey-core,readiness,settle-redrive,journey-induction,journey-full,guard]
# Stages (fixed order; stop at first failure; never retries): bootstrap, rls-g2-s11 (6), journey-core (8), readiness (6),
# settle-redrive (8), journey-induction (4), journey-full (only if the file exists at HEAD), guard (G2_S11_* unset, no DB).
# Binding = HEAD + tree + this file's sha256 (in RUN_DIR/RESULT). See proof/REPORT.md.
LANE_NAME=s11
LANE_ENV=G2_S11                                   # env prefix read by the S11 harness / bootstrap / specs
DB_TS=test/utils/g2-s11-db.ts                     # G2_S11_DATABASE / G2_S11_ROLE / G2_S11_CLUSTER_MARKER literals (read at HEAD)
BOOT_SH=test/utils/g2-s11-bootstrap.sh            # bootstrap entry point (prints G2_S11_BOOTSTRAP_OK); DB_MARKER literal read at HEAD
CONN_LIMIT=2                                      # connection_limit in the harness URL (s11a2 v2 precedent)
FIXPASS=s11_local_synthetic                       # synthetic fixture password (precedent)
OUTER_TIMEOUT=${LANE_OUTER_TIMEOUT:-18000}        # whole-run watchdog (s)
# name|jest config|timeout s|spec files (space-separated)|kind (live|guard)|required (req|opt: skipped as a stage iff absent at HEAD)
STAGE_TABLE=(
  "rls-g2-s11|jest.rls.config.js|1500|test/rls-g2-s11.spec.ts|live|req"
  "journey-core|jest.config.js|1500|test/scout/s11/journey-core.pg.spec.ts|live|req"
  "readiness|jest.config.js|900|test/scout/s11/readiness.pg.spec.ts|live|req"
  "settle-redrive|jest.config.js|3000|test/scout/s11/settle-redrive.pg.spec.ts|live|req"
  "journey-induction|jest.config.js|3000|test/scout/s11/journey-induction.pg.spec.ts|live|req"
  "journey-full|jest.config.js|4200|test/scout/s11/journey-full.pg.spec.ts|live|opt"
  "guard|jest.config.js|300|test/utils/g2-s11-db-guard.spec.ts|guard|req"
)
NEED_RG_FOR="journey-full"                        # J20 runs scripts/s10-core-diff-gate.sh, which needs rg on PATH
# ======================= common body (byte-identical in lane-s11.sh and lane-s10b.sh) =======================
# Mechanics (simplified from the fa72efb2 bindings; no per-blob pin tables — binding = HEAD + tree + runner sha256):
#  1. args: <HEAD_SHA 40-hex> <RUN_DIR absolute, created O_EXCL (mkdir; parent must exist)>; optional --stages list.
#  2. self re-exec under `timeout -k 180 $OUTER_TIMEOUT` (watchdog). TERM/INT/HUP -> kill the running stage's process group
#     -> teardown -> RESULT. Every child runs setsid + its own `timeout -k 30 <bound>` with fd 9 (lock) closed.
#  3. runtime sentinel must say RC=0; HEAD must exist in /home/user/workspace/repos/backend (parent keeps it fetched).
#  4. canonical lock (inode 657581) taken with `flock -w $LOCK_WAIT` on fd 9 and held until exit; STARTED written O_EXCL.
#  5. fresh scratch clone (git clone --no-hardlinks --no-checkout of the backend, detached checkout of HEAD, push disabled)
#     under /home/user/workspace/execution/42d8c5b5/proof-scratch/<lane>-<run>-<pid>/.
#  6. package-lock.json sha at HEAD must equal the donor's (else REFUSED rc 70); donor node_modules copied `cp -a` (real copy,
#     donor never mutated: its .prisma/@prisma tree signature is compared before/after); `prisma generate` IN THE CLONE.
#  7. fresh PG 17.6 cluster (runtime dist) on the first free port in 55650-55699 not refused by the lane's db.ts at HEAD;
#     marker/DB/role literals read from the lane harness at HEAD; bootstrap; identity (data dir, 170006, cluster_name, DB
#     marker, applied migrations == migration dirs at HEAD, last == max dir).
#  8. jest stages, each once, --runInBand --ci --runTestsByPath, stop at first failure. PASS requires rc 0, 0 failed,
#     0 skipped, 0 todo, passed == total, suites all passed == spec file count, a PASS line per file, and total == the static
#     `it(` count at HEAD (>= when the file uses it.each/test.each/test(). Any skipped test = FAIL.
#  9. teardown (always, from the EXIT trap): stop (fast -> immediate -> KILL), copy pg logs, remove the scratch dir
#     (LANE_KEEP_SCRATCH=1 keeps the clone source but still removes pg-data and node_modules). A failed teardown makes RC 74.
# 10. RUN_DIR/RESULT + RECEIPTS.sha256. RC: 0 ok | 64 usage | 70 precondition/refused | 71 clone/deps | 72 jest count/skip |
#     73 identity | 74 teardown/post | 75 lock | 76 run dir exists | 124 timeout/signal | other = stage command rc.
# Env knobs: LANE_LOCK_WAIT (default 3600 s), LANE_OUTER_TIMEOUT, LANE_KEEP_SCRATCH=1.
set -uo pipefail
SELF=$(readlink -f "${BASH_SOURCE[0]}")
BACKEND=/home/user/workspace/repos/backend
DONOR=/home/user/workspace/worktrees/x42-donor
RT=/home/user/workspace/execution/42d8c5b5/runtime
DIST=$RT/pg17/dist
SENTINEL=/home/user/workspace/repos/tgp-private-evidence/execution/42d8c5b5/runtime/raw/rt-setup.sentinel
LOCK=/home/user/workspace/execution/test-validation.lock; LOCK_INODE=657581
LOCK_WAIT=${LANE_LOCK_WAIT:-3600}
SCRATCH_ROOT=/home/user/workspace/execution/42d8c5b5/proof-scratch
PORT_LO=55650; PORT_HI=55699
usage(){ echo "usage: $(basename "$SELF") <HEAD_SHA 40-hex> <RUN_DIR absolute, must not exist> [--stages a,b,...]" >&2; exit 64; }
[ $# -ge 2 ] || usage
HEAD_SHA=$1; RUN_DIR=${2%/}; shift 2; REQ_STAGES=""
while [ $# -gt 0 ]; do case "$1" in --stages) [ $# -ge 2 ] || usage; REQ_STAGES=$2; shift 2;; --stages=*) REQ_STAGES=${1#--stages=}; shift;; *) usage;; esac; done
[[ "$HEAD_SHA" =~ ^[0-9a-f]{40}$ ]] || usage
case "$RUN_DIR" in /*) ;; *) usage;; esac
if [ -z "${LANE_WATCHDOG:-}" ]; then
  exec timeout -k 180 "$OUTER_TIMEOUT" env LANE_WATCHDOG=1 bash "$SELF" "$HEAD_SHA" "$RUN_DIR" ${REQ_STAGES:+--stages "$REQ_STAGES"}
fi
[ -d "$(dirname "$RUN_DIR")" ] || { echo "REFUSED: parent of $RUN_DIR missing" >&2; exit 76; }
mkdir "$RUN_DIR" 2>/dev/null || { echo "REFUSED: $RUN_DIR exists (O_EXCL run dir; never reused)" >&2; exit 76; }
for v in $(compgen -e | grep -E '^G2_'); do unset "$v"; done
export GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1 GIT_TERMINAL_PROMPT=0 GIT_LFS_SKIP_SMUDGE=1 NODE_OPTIONS=--max-old-space-size=3072 \
       CHECKPOINT_DISABLE=1 PRISMA_HIDE_UPDATE_MESSAGE=1 PRISMA_GENERATE_SKIP_AUTOINSTALL=1 npm_config_offline=true \
       npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false
LOG=$RUN_DIR/runner.log
ts(){ date -u +%FT%TZ; }; now(){ date +%s; }
log(){ echo "$(ts) $*" >>"$LOG"; }
sha(){ sha256sum "$1" 2>/dev/null | cut -c1-64; }
RUNNER_SHA=$(sha "$SELF"); T0=$(now); START_TS=$(ts)
CUR_STAGE=preflight; FINAL_RC=""; CHILD=""; SCR=""; W=""; PGDATA=""; PG_UP=0; PORT=none; TREE=none; PKG_LOCK=none
DONOR_PKG=none; MIG_N=none; LAST_MIG=none; MIG_APPLIED=none; CLIENT_SHA=none; TEARDOWN=none; RES=(); SUM_P=0; SUM_F=0; SUM_S=0; SUM_T=0
die(){ FINAL_RC=$1; shift; log "FAIL stage=$CUR_STAGE rc=$FINAL_RC $*"; exit "$FINAL_RC"; }
run_bounded(){ # <secs> <logfile> <cwd> cmd... : own session + hard timeout, lock fd closed, stdin /dev/null
  local secs=$1 lf=$2 cwd=$3; shift 3
  ( cd "$cwd" && exec setsid timeout -k 30 "$secs" "$@" ) >>"$lf" 2>&1 </dev/null 9>&- &
  CHILD=$!; wait "$CHILD"; local rc=$?; CHILD=""; return $rc; }
pgbin(){ local b=$1; shift; LD_LIBRARY_PATH="$DIST/lib" "$DIST/bin/$b" "$@"; }
pm_pid(){ [ -n "$PGDATA" ] && head -1 "$PGDATA/postmaster.pid" 2>/dev/null; }
pm_alive(){ local p; p=$(pm_pid) || return 1; [ -n "$p" ] && kill -0 "$p" 2>/dev/null && grep -qF -- "$PGDATA" <<<"$(tr '\0' ' ' </proc/"$p"/cmdline 2>/dev/null)"; }
listeners(){ local s; s=$(ss -ltn 2>/dev/null || true); grep -cE "[:.]$1 " <<<"$s" || true; }
csig(){ find "$1/.prisma" "$1/@prisma/client" -printf '%P %s %T@ %m\n' 2>/dev/null | sort | sha256sum | cut -c1-64; }
teardown_all(){ local bad=0 p
  if pm_alive; then
    run_bounded 75 "$RUN_DIR/pg_ctl.log" / env LD_LIBRARY_PATH="$DIST/lib" "$DIST/bin/pg_ctl" -D "$PGDATA" -m fast -w -t 45 stop
    pm_alive && run_bounded 60 "$RUN_DIR/pg_ctl.log" / env LD_LIBRARY_PATH="$DIST/lib" "$DIST/bin/pg_ctl" -D "$PGDATA" -m immediate -w -t 30 stop
    if pm_alive; then p=$(pm_pid); log "TEARDOWN postmaster $p survived fast+immediate stop; SIGKILL"; kill -KILL "$p" 2>/dev/null; sleep 3; fi
  fi
  pm_alive && bad=1
  [ -n "$SCR" ] && [ -f "$SCR/pg.log" ] && cp -p "$SCR/pg.log" "$RUN_DIR/pg.log" 2>/dev/null
  local pl=0; [ "$PORT" != none ] && pl=$(listeners "$PORT")
  [ "$pl" = 0 ] || bad=1
  local sstate=none
  if [ -n "$SCR" ] && [ -d "$SCR" ]; then
    if [ "$bad" = 1 ]; then sstate="kept(postmaster-alive-or-port-busy):$SCR"
    elif [ "${LANE_KEEP_SCRATCH:-0}" = 1 ]; then
      rm -rf -- "$SCR/pg-data" "$W/node_modules" 2>/dev/null; { [ -e "$SCR/pg-data" ] || [ -e "$W/node_modules" ]; } && bad=1; sstate="kept(clone-src-only):$SCR"
    else rm -rf -- "$SCR" 2>/dev/null; [ -e "$SCR" ] && bad=1; sstate=removed; fi
  fi
  TEARDOWN="postmaster_alive=$(pm_alive && echo yes || echo no) port_listeners=$pl scratch=$sstate"
  log "TEARDOWN $TEARDOWN bad=$bad"; return $bad; }
write_result(){ local rc=$1 T1; T1=$(now)
  { echo "RC=$rc"; echo "STAGE=$CUR_STAGE"; echo "LANE=$LANE_NAME"; echo "HEAD=$HEAD_SHA"; echo "TREE=$TREE"
    echo "PKG_LOCK_SHA256=$PKG_LOCK"; echo "DONOR_PKG_LOCK_SHA256=$DONOR_PKG"; echo "MIGRATIONS_AT_HEAD=$MIG_N"; echo "LAST_MIGRATION_AT_HEAD=$LAST_MIG"
    echo "MIGRATIONS_APPLIED=$MIG_APPLIED"; echo "CLIENT_INDEX_DTS_SHA256=$CLIENT_SHA"; echo "RUNNER=$SELF"; echo "RUNNER_SHA256=$RUNNER_SHA"
    echo "STAGES_REQUESTED=${REQ_STAGES:-all}"; echo "PORT=$PORT"
    for l in "${RES[@]}"; do echo "$l"; done
    echo "TOTAL passed=$SUM_P failed=$SUM_F skipped=$SUM_S total=$SUM_T"
    echo "START=$START_TS"; echo "END=$(ts)"; echo "DURATION_S=$((T1 - T0))"; echo "TEARDOWN=$TEARDOWN"
    echo "LOCK_INODE=$(stat -c %i "$LOCK" 2>/dev/null)"; } >"$RUN_DIR/RESULT"
  ( cd "$RUN_DIR" && sha256sum $(ls -A | grep -vx RECEIPTS.sha256) >RECEIPTS.sha256 2>/dev/null ); }
finish(){ local rc=$?; trap - EXIT TERM INT HUP
  [ -n "$FINAL_RC" ] && rc=$FINAL_RC
  if ! teardown_all; then [ "$rc" = 0 ] && { rc=74; CUR_STAGE=teardown; }; fi
  write_result "$rc"; log "END rc=$rc stage=$CUR_STAGE"; exit "$rc"; }
on_signal(){ log "SIGNAL $1 (watchdog/operator) during stage=$CUR_STAGE"
  if [ -n "$CHILD" ]; then kill -TERM -- "-$CHILD" 2>/dev/null; sleep 5; kill -KILL -- "-$CHILD" 2>/dev/null; fi
  RES+=("STAGE_RESULT name=$CUR_STAGE status=ABORTED_BY_SIGNAL_$1 rc=124"); FINAL_RC=124; exit 124; }
trap finish EXIT; trap 'on_signal TERM' TERM; trap 'on_signal INT' INT; trap 'on_signal HUP' HUP
log "START lane=$LANE_NAME head=$HEAD_SHA run_dir=$RUN_DIR runner=$SELF sha256=$RUNNER_SHA stages=${REQ_STAGES:-all} pid=$$"
# ---- preflight (before the lock)
grep -q '^RC=0 ' "$SENTINEL" 2>/dev/null || die 70 "runtime sentinel $SENTINEL is not RC=0"
ALL_NAMES="bootstrap"; for s in "${STAGE_TABLE[@]}"; do ALL_NAMES="$ALL_NAMES ${s%%|*}"; done
if [ -n "$REQ_STAGES" ]; then SEL=" $(tr ',' ' ' <<<"$REQ_STAGES") "
  for n in $SEL; do case " $ALL_NAMES " in *" $n "*) ;; *) die 64 "unknown stage '$n' (known: $ALL_NAMES)";; esac; done
else SEL=" $ALL_NAMES "; fi
NEED_PG=0; case "$SEL" in *" bootstrap "*) NEED_PG=1;; esac
for s in "${STAGE_TABLE[@]}"; do IFS='|' read -r n _ _ _ k _ <<<"$s"; case "$SEL" in *" $n "*) [ "$k" = live ] && NEED_PG=1;; esac; done
[ "$NEED_PG" = 1 ] && case "$SEL" in *" bootstrap "*) ;; *) SEL=" bootstrap$SEL"; log "bootstrap added (a live stage needs the DB)";; esac
git -C "$BACKEND" cat-file -e "$HEAD_SHA^{commit}" 2>/dev/null || die 70 "HEAD $HEAD_SHA not present in $BACKEND (parent fetch needed)"
# ---- canonical lock for the whole run
[ -e "$LOCK" ] && [ "$(stat -c %i "$LOCK")" = "$LOCK_INODE" ] || die 75 "lock $LOCK absent or inode != $LOCK_INODE (never created here)"
exec 9>>"$LOCK"; TL=$(now)
flock -w "$LOCK_WAIT" 9 || die 75 "canonical lock not acquired within ${LOCK_WAIT}s"
[ "$(stat -c %i "$LOCK")" = "$LOCK_INODE" ] || die 75 "lock inode changed"
( set -C; echo "STARTED $(ts) pid=$$ head=$HEAD_SHA" >"$RUN_DIR/STARTED" ) 2>/dev/null || die 76 "STARTED exists"
log "LOCK_HELD fd9 inode=$LOCK_INODE waited_s=$(( $(now) - TL ))"
# ---- tools / donor
CUR_STAGE=tools
NODEV=$(node --version 2>/dev/null); grep -q '^v20\.' <<<"$NODEV" || die 70 "node major != 20 ($NODEV)"
[ -d "$DONOR/node_modules" ] && [ ! -L "$DONOR/node_modules" ] || die 70 "donor node_modules absent or a symlink"
DONOR_PKG=$(sha "$DONOR/package-lock.json"); DONOR_HIDDEN=$(sha "$DONOR/node_modules/.package-lock.json"); DSIG0=$(csig "$DONOR/node_modules")
[ -n "$DONOR_PKG" ] && [ -n "$DONOR_HIDDEN" ] && [ -f "$DONOR/node_modules/.prisma/client/index.d.ts" ] || die 70 "donor package-lock / hidden lock / generated client missing"
if [ "$NEED_PG" = 1 ]; then
  PSQL=$(ls /usr/lib/postgresql/*/bin/psql 2>/dev/null | sort -V | tail -1); [ -x "$PSQL" ] || die 70 "no psql client"
  PGV=$(pgbin postgres --version 2>/dev/null); [ "${PGV##* }" = 17.6 ] || die 70 "server not 17.6 ($PGV)"
  grep -q '^result=success' "$RT/pg17/PROVENANCE.txt" 2>/dev/null || die 70 "pg17 PROVENANCE lacks result=success"
  P=$(pgrep -cx postgres || true); [ "$P" = 0 ] || die 70 "postgres processes already running ($P); lanes never share a server"
fi
log "TOOLS node=$NODEV pg='${PGV:-n/a}' psql=${PSQL:-n/a} donor_head=$(git -C "$DONOR" rev-parse HEAD 2>/dev/null) donor_pkg_lock=$DONOR_PKG donor_hidden_lock=$DONOR_HIDDEN donor_sig=$DSIG0"
# ---- scratch + fresh clone
CUR_STAGE=clone
mkdir -p "$SCRATCH_ROOT" && mkdir "$SCRATCH_ROOT/$LANE_NAME-$(basename "$RUN_DIR")-$$" || die 71 "scratch dir not created exclusively"
SCR=$SCRATCH_ROOT/$LANE_NAME-$(basename "$RUN_DIR")-$$; W=$SCR/clone
export XDG_CACHE_HOME=$SCR/cache npm_config_cache=$SCR/npm-cache
run_bounded 300 "$RUN_DIR/clone.log" "$SCR" git -c core.hooksPath=/dev/null clone --no-hardlinks --no-checkout -q "$BACKEND" "$W" || die 71 "git clone failed"
if ! git -C "$W" cat-file -e "$HEAD_SHA^{commit}" 2>/dev/null; then
  run_bounded 300 "$RUN_DIR/clone.log" "$W" git fetch -q origin '+refs/remotes/origin/*:refs/remotes/src/*' || die 71 "fetch of source remote-tracking refs failed"
  git -C "$W" cat-file -e "$HEAD_SHA^{commit}" 2>/dev/null || die 71 "HEAD not reachable in the scratch clone"
fi
git -C "$W" remote set-url --push origin no_push://disabled
run_bounded 300 "$RUN_DIR/clone.log" "$W" git -c core.hooksPath=/dev/null -c filter.lfs.required=false checkout -q --detach "$HEAD_SHA" || die 71 "checkout failed"
[ "$(git -C "$W" rev-parse HEAD)" = "$HEAD_SHA" ] && [ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] || die 71 "clone not clean at HEAD"
TREE=$(git -C "$W" rev-parse 'HEAD^{tree}'); PKG_LOCK=$(sha "$W/package-lock.json")
MIGS=$(find "$W/prisma/migrations" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | LC_ALL=C sort); MIG_N=$(grep -c . <<<"$MIGS"); LAST_MIG=$(tail -1 <<<"$MIGS")
log "CLONE_OK head=$HEAD_SHA tree=$TREE pkg_lock=$PKG_LOCK migrations=$MIG_N last=$LAST_MIG"
[ "$PKG_LOCK" = "$DONOR_PKG" ] || die 70 "REFUSED: package-lock.json at HEAD ($PKG_LOCK) != donor's ($DONOR_PKG); donor node_modules would not match"
# ---- node_modules (real copy of the donor; donor never mutated) + prisma generate in the clone
CUR_STAGE=node_modules
run_bounded 900 "$RUN_DIR/node_modules.log" "$W" cp -a "$DONOR/node_modules" "$W/node_modules" || die 71 "cp -a donor node_modules failed"
[ -d "$W/node_modules" ] && [ ! -L "$W/node_modules" ] || die 71 "clone node_modules not a real directory"
for d in node_modules/.prisma node_modules/@prisma/client node_modules/prisma; do case "$(readlink -f "$W/$d")" in "$W"/*) ;; *) die 71 "$d resolves outside the clone";; esac; done
[ -z "$(find "$W/node_modules/.prisma" "$W/node_modules/@prisma" "$W/node_modules/prisma" -type l -lname '/*' 2>/dev/null)" ] || die 71 "absolute symlinks in the copied prisma tree"
[ "$(sha "$W/node_modules/.package-lock.json")" = "$DONOR_HIDDEN" ] || die 71 "copied hidden lock != donor's"
CUR_STAGE=prisma_generate
run_bounded 600 "$RUN_DIR/prisma-generate.log" "$W" ./node_modules/.bin/prisma generate --schema prisma/schema.prisma || die 71 "prisma generate failed"
[ "$(csig "$DONOR/node_modules")" = "$DSIG0" ] || die 71 "donor prisma tree changed during generate"
CLIENT_SHA=$(sha "$W/node_modules/.prisma/client/index.d.ts"); [ -n "$CLIENT_SHA" ] || die 71 "no generated client"
[ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] || die 71 "clone dirty after node_modules/generate"
log "DEPS_OK client_index_dts=$CLIENT_SHA jest=$(cd "$W" && ./node_modules/.bin/jest --version 2>/dev/null) prisma=$(cd "$W" && ./node_modules/.bin/prisma --version 2>/dev/null | awk '/^prisma /{print $3}')"
# ---- fresh cluster + bootstrap + identity
if [ "$NEED_PG" = 1 ]; then
  CUR_STAGE=pg-init
  DBTXT=$(cat "$W/$DB_TS" 2>/dev/null) && BOOTTXT=$(cat "$W/$BOOT_SH" 2>/dev/null) || die 70 "lane harness files absent at HEAD ($DB_TS, $BOOT_SH)"
  DBNAME=$(grep -oP "export const ${LANE_ENV}_DATABASE = '\K[^']+" <<<"$DBTXT" | head -1)
  ADMIN=$(grep -oP "export const ${LANE_ENV}_ROLE = '\K[^']+" <<<"$DBTXT" | head -1)
  MARKER=$(grep -oP "export const ${LANE_ENV}_CLUSTER_MARKER = '\K[^']+" <<<"$DBTXT" | head -1)
  BMARKER=$(grep -m1 '^CLUSTER_MARKER=' <<<"$BOOTTXT" | cut -d= -f2-); DB_MARKER=$(grep -m1 '^DB_MARKER=' <<<"$BOOTTXT" | cut -d= -f2-)
  [ -n "$DBNAME" ] && [ -n "$ADMIN" ] && [ -n "$MARKER" ] && [ "$MARKER" = "$BMARKER" ] && [ -n "$DB_MARKER" ] || die 70 "lane literals unreadable/inconsistent at HEAD (db=$DBNAME role=$ADMIN marker=$MARKER/$BMARKER)"
  for p in $(seq "$PORT_LO" "$PORT_HI"); do grep -qE "^ +'$p',\$" <<<"$DBTXT" && continue; [ "$(listeners "$p")" = 0 ] || continue; PORT=$p; break; done
  [ "$PORT" != none ] || die 70 "no free port in $PORT_LO-$PORT_HI"
  PGDATA=$SCR/pg-data; SOCK=$SCR/s; mkdir -p "$SOCK"; PWF=$SCR/pw; echo "$FIXPASS" >"$PWF"
  run_bounded 120 "$RUN_DIR/initdb.log" "$SCR" env LD_LIBRARY_PATH="$DIST/lib" "$DIST/bin/initdb" -D "$PGDATA" -U "$ADMIN" -A scram-sha-256 --pwfile="$PWF" -E UTF8 --locale=C.UTF-8 || die 72 "initdb failed"
  rm -f "$PWF"
  cat >>"$PGDATA/postgresql.conf" <<CONF
# --- 42d8c5b5 proof lane $LANE_NAME (disposable; 2 vCPU / 7 GB sandbox) ---
cluster_name = '$MARKER'
port = $PORT
listen_addresses = '127.0.0.1'
unix_socket_directories = '$SOCK'
shared_buffers = 128MB
work_mem = 8MB
maintenance_work_mem = 64MB
max_connections = 40
fsync = off
synchronous_commit = off
full_page_writes = off
log_min_messages = warning
log_lock_waits = on
deadlock_timeout = 500ms
CONF
  CUR_STAGE=pg-start
  run_bounded 90 "$RUN_DIR/pg_ctl.log" "$SCR" env LD_LIBRARY_PATH="$DIST/lib" "$DIST/bin/pg_ctl" -D "$PGDATA" -l "$SCR/pg.log" -w -t 60 start || die 72 "pg_ctl start failed"
  pm_alive || die 72 "postmaster not alive after start"; PG_UP=1
  log "PG_UP port=$PORT pid=$(pm_pid) data=$PGDATA marker=$MARKER db=$DBNAME role=$ADMIN"
  export "${LANE_ENV}_DATABASE_URL=postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME?schema=public&connection_limit=$CONN_LIMIT" \
         "${LANE_ENV}_CONFIRM=$DBNAME:$PORT" "${LANE_ENV}_PASSWORD=$FIXPASS" "${LANE_ENV}_PSQL=$PSQL" \
         "${LANE_ENV}_DATA_DIRECTORY=$PGDATA" "${LANE_ENV}_SERVER_VERSION=170006" "${LANE_ENV}_CANDIDATE_HEAD=$HEAD_SHA"
  CUR_STAGE=bootstrap; TB=$(now)
  run_bounded 900 "$RUN_DIR/bootstrap.log" "$W" bash "$BOOT_SH" bootstrap; rc=$?
  BL=$(cat "$RUN_DIR/bootstrap.log")
  if [ $rc != 0 ]; then RES+=("STAGE_RESULT name=bootstrap status=FAIL rc=$rc secs=$(( $(now) - TB ))"); die "$rc" "bootstrap rc=$rc"; fi
  grep -q "^${LANE_ENV}_BOOTSTRAP_OK" <<<"$BL" && grep -q "^CANDIDATE_HEAD=$HEAD_SHA" <<<"$BL" && grep -q "^CANDIDATE_CLIENT_VERIFIED dir=$W/node_modules/.prisma/client " <<<"$BL" \
    || { RES+=("STAGE_RESULT name=bootstrap status=FAIL rc=72 secs=$(( $(now) - TB )) reason=markers"); die 72 "bootstrap OK/candidate/client lines missing"; }
  CUR_STAGE=identity
  psqlq(){ PGPASSWORD=$FIXPASS timeout -k 10 15 "$PSQL" -X -v ON_ERROR_STOP=1 -At "postgresql://$ADMIN@127.0.0.1:$PORT/$DBNAME" -c "$1" 2>>"$LOG" 9>&-; }
  DD=$(psqlq 'SHOW data_directory'); VN=$(psqlq 'SHOW server_version_num'); CN=$(psqlq "SELECT current_setting('cluster_name')")
  DM=$(psqlq "SELECT shobj_description(oid,'pg_database') FROM pg_database WHERE datname=current_database()")
  MIG_APPLIED=$(psqlq 'SELECT count(*) FROM "_prisma_migrations" WHERE finished_at IS NOT NULL AND rolled_back_at IS NULL')
  ML=$(psqlq 'SELECT max(migration_name) FROM "_prisma_migrations" WHERE finished_at IS NOT NULL AND rolled_back_at IS NULL'); PT=$(psqlq 'SELECT inet_server_port()')
  ID="data_directory=$DD server_version_num=$VN cluster_name=$CN db_marker_ok=$([ "$DM" = "$DB_MARKER" ] && echo yes || echo NO) applied=$MIG_APPLIED last=$ML port=$PT"
  [ "$DD" = "$PGDATA" ] && [ "$VN" = 170006 ] && [ "$CN" = "$MARKER" ] && [ "$DM" = "$DB_MARKER" ] && [ "$MIG_APPLIED" = "$MIG_N" ] && [ "$ML" = "$LAST_MIG" ] && [ "$PT" = "$PORT" ] \
    || { RES+=("STAGE_RESULT name=bootstrap status=FAIL rc=73 secs=$(( $(now) - TB )) identity=[$ID]"); die 73 "identity mismatch: $ID"; }
  RES+=("STAGE_RESULT name=bootstrap status=PASS rc=0 secs=$(( $(now) - TB )) migrations_applied=$MIG_APPLIED last=$ML")
  log "BOOTSTRAP_IDENTITY_OK $ID"
fi
# ---- jest stages (fixed order, once each, stop at first failure)
GUARD_RE='requires its explicitly confirmed|unsupported or ambiguous connection option|requires a plain fixture password|connects only as a fixture matrix login role|candidate head, not the accepted base|not the attested candidate|uncommitted changes|G2 proof requires|server identity mismatch'
jnum(){ local v; v=$(grep -oE "[0-9]+ $1" <<<"$2" | head -1 | awk '{print $1}'); echo "${v:-0}"; }
for s in "${STAGE_TABLE[@]}"; do
  IFS='|' read -r NAME CFG TMO FILES KIND REQ <<<"$s"
  case "$SEL" in *" $NAME "*) ;; *) continue;; esac
  CUR_STAGE=$NAME; MISSING=""; for f in $FILES; do [ -f "$W/$f" ] || MISSING="$MISSING $f"; done
  if [ -n "$MISSING" ]; then
    if [ "$REQ" = opt ] && [ -z "$REQ_STAGES" ]; then RES+=("STAGE_RESULT name=$NAME status=SKIP_ABSENT_AT_HEAD files=[$FILES]"); log "STAGE $NAME absent at HEAD (optional; not run)"; continue; fi
    RES+=("STAGE_RESULT name=$NAME status=FAIL rc=70 missing=[$MISSING]"); die 70 "stage $NAME spec files absent at HEAD:$MISSING"
  fi
  if case " $NEED_RG_FOR " in *" $NAME "*) true;; *) false;; esac; then command -v rg >/dev/null || { RES+=("STAGE_RESULT name=$NAME status=FAIL rc=70 reason=rg-missing"); die 70 "rg not on PATH"; }; fi
  EXP=0; LB=0; NF=0
  for f in $FILES; do NF=$((NF + 1)); c=$(grep -cE '^\s*it\(' "$W/$f" || true); EXP=$((EXP + c)); grep -qE '\b(it|test)\.each\b|^\s*test\(' "$W/$f" && LB=1; done
  JL=$RUN_DIR/jest-$NAME.log; ENVU=()
  if [ "$KIND" = guard ]; then for v in $(compgen -e | grep -E '^G2_'); do ENVU+=(-u "$v"); done; fi
  log "JEST_START $NAME cfg=$CFG bound=${TMO}s files=[$FILES] static_it=$EXP lower_bound=$LB kind=$KIND"
  TS0=$(now)
  run_bounded "$TMO" "$JL" "$W" env "${ENVU[@]}" ./node_modules/.bin/jest -c "$CFG" --runInBand --ci --runTestsByPath $FILES; JRC=$?
  SECS=$(( $(now) - TS0 )); J=$(cat "$JL")
  TL_=$(grep -E '^Tests:' <<<"$J" | tail -1); SL_=$(grep -E '^Test Suites:' <<<"$J" | tail -1)
  TP=$(jnum passed "$TL_"); TF=$(jnum failed "$TL_"); TS=$(jnum skipped "$TL_"); TT=$(jnum todo "$TL_"); TN=$(jnum total "$TL_")
  SP=$(jnum passed "$SL_"); SF=$(jnum failed "$SL_"); SS=$(jnum skipped "$SL_"); SN=$(jnum total "$SL_")
  grep -qE "$GUARD_RE" <<<"$J" && log "GUARD_REFUSAL_OBSERVED_IN_JEST_LOG $NAME"
  PASSL=1; for f in $FILES; do grep -qE "^PASS .*${f//./\\.}( |\$)" <<<"$J" || PASSL=0; done
  WHY=""
  [ "$JRC" = 0 ] || WHY="$WHY jest_rc=$JRC"
  [ "$TF" = 0 ] || WHY="$WHY failed=$TF"; [ "$TS" = 0 ] || WHY="$WHY skipped=$TS(live-expected)"; [ "$TT" = 0 ] || WHY="$WHY todo=$TT"
  [ "$TN" -gt 0 ] && [ "$TP" = "$TN" ] || WHY="$WHY passed!=total($TP/$TN)"
  if [ "$LB" = 1 ]; then [ "$TN" -ge "$EXP" ] || WHY="$WHY total<static($TN<$EXP)"; else [ "$TN" = "$EXP" ] || WHY="$WHY total!=static($TN!=$EXP)"; fi
  [ "$SP" = "$NF" ] && [ "$SN" = "$NF" ] && [ "$SF" = 0 ] && [ "$SS" = 0 ] || WHY="$WHY suites=$SP/$SN(want $NF/$NF)"
  [ "$PASSL" = 1 ] || WHY="$WHY missing-PASS-line"
  ST=PASS; [ -z "$WHY" ] || ST=FAIL
  SUM_P=$((SUM_P + TP)); SUM_F=$((SUM_F + TF)); SUM_S=$((SUM_S + TS)); SUM_T=$((SUM_T + TN))
  RES+=("STAGE_RESULT name=$NAME status=$ST passed=$TP failed=$TF skipped=$TS todo=$TT total=$TN expected=$([ "$LB" = 1 ] && echo ">=")$EXP suites=$SP/$SN rc=$JRC secs=$SECS${WHY:+ reason=[${WHY# }]}")
  log "JEST_END $NAME status=$ST rc=$JRC secs=$SECS | $SL_ | $TL_${WHY:+ | why:$WHY}"
  if [ "$ST" != PASS ]; then if [ "$JRC" != 0 ]; then die "$JRC" "stage $NAME failed"; else die 72 "stage $NAME count/skip check failed:$WHY"; fi; fi
done
# ---- post (read-only)
CUR_STAGE=post
[ "$(git -C "$W" rev-parse HEAD)" = "$HEAD_SHA" ] && [ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] || die 74 "clone changed during the run"
[ "$(csig "$DONOR/node_modules")" = "$DSIG0" ] || die 74 "donor prisma tree changed during the run"
log "POST_OK clone clean at HEAD, donor unchanged, worktrees=$(git -C "$W" worktree list 2>/dev/null | wc -l)"
CUR_STAGE=done; FINAL_RC=0; exit 0
