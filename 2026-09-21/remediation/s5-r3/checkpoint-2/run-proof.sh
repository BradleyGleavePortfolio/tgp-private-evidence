#!/usr/bin/env bash
# S5 R3 G2 E->T/Q0 proof runner, revision 3 (validation harness only; synthetic disposable
# fixture on the isolated PostgreSQL 17.6 lane s5). Supersedes the archived checkpoint-1 runner,
# which the parent refused to execute (wrong lock name in npm-ci.sh, DROP before identity proof,
# cwd side effect inside stamp()). Corrections in this revision:
#   * ONE canonical lock, /home/user/workspace/execution/test-validation.lock, taken NON-BLOCKING
#     (flock -n; rc 75 if busy, never queues) and held by this process across stamp, offline guard,
#     connected preflight and every mutation until the stage exits. Children run with fd 9 closed.
#   * Target identity is PINNED here as literals (host, port, database, roles, data directory,
#     server version, cluster marker, database marker). Environment variables cannot re-point it;
#     a preset G2_PG17_* variable that differs from the pin is refused (rc 2) before anything runs.
#   * Offline guard (no connection, no dependencies) runs before the lock; the connected preflight
#     (read-only, maintenance DB, superuser) proves the disposable identity BEFORE any DROP,
#     CREATE, migrate or test: version, loopback address/port, listen_addresses, data_directory,
#     cluster_name marker, no hosted-platform roles, only expected database names, and for the
#     disposable database itself the pinned COMMENT marker and zero foreign sessions.
#   * stamp() has no side effects; every child command runs from an explicit directory.
#   * Fail-fast; child exit codes preserved through tee (PIPESTATUS); every run (including refused
#     and failed ones) is preserved under execution/s5-r3/logs with head/tree/clean-or-dirty
#     fingerprint, toolchain, lock blob, command, start and end.
# Usage: G2_PG17_PASSWORD=<fixture pw> bash execution/s5-r3/run-proof.sh <stage>
#   oldroot    offline: create/verify the detached O checkout (git only; no lock, no DB, no deps)
#   guard      offline jest guard spec (needs node_modules; lock held; no DB connection)
#   preflight  lock + read-only connected identity proof only; mutates nothing
#   reset      preflight, then DROP DATABASE g2_s5_etq0_disposable ONLY if it carries the marker
#   bootstrap  preflight, then test/utils/g2-pg17-bootstrap.sh (creates the marked database)
#   live       preflight, then the 51-test live spec
#   all        guard -> oldroot -> preflight -> bootstrap -> live (no reset; run reset first)
set -uo pipefail
RUNNER_REV=3
W=/home/user/workspace/worktrees/s5-r3
X=/home/user/workspace/execution
S=$X/s5-r3
L=$S/logs
LOCK=$X/test-validation.lock
mkdir -p "$L"

# ---- Pinned disposable target identity (literals; see test/utils/g2-pg17-db.ts for the markers).
PIN_HOST=127.0.0.1
PIN_PORT=54325
PIN_DB=g2_s5_etq0_disposable
PIN_ADMIN=s5_super
PIN_DATA_DIRECTORY=/home/user/pg17/clusters/s5
PIN_SERVER_VERSION=170006
PIN_CLUSTER_MARKER=s5-disposable-pg17
PIN_DB_MARKER=s5-g2-etq0-synthetic-disposable-fixture-safe-to-drop
# Databases that may exist on the s5 lane cluster (template*, maintenance, S1's lane default DB, ours).
PIN_ALLOWED_DBS=" template0 template1 postgres s5_tgp $PIN_DB "
PIN_URL="postgresql://$PIN_ADMIN@$PIN_HOST:$PIN_PORT/$PIN_DB?schema=public&connection_limit=2"
PIN_CONFIRM="$PIN_DB:$PIN_PORT"
MAINT_URL="postgresql://$PIN_ADMIN@$PIN_HOST:$PIN_PORT/postgres?connect_timeout=5"

STAGE="${1:-}"
case "$STAGE" in oldroot|guard|preflight|reset|bootstrap|live|all) ;; *) echo "usage: $0 oldroot|guard|preflight|reset|bootstrap|live|all" >&2; exit 2;; esac
TS="$(date -u +%Y%m%dT%H%M%SZ)"
START="$(date -u +%FT%TZ)"
RUNLOG="$L/run-$STAGE-$TS.log"
say() { echo "$*" | tee -a "$RUNLOG"; }
refuse() { say "REFUSED rc=$1: $2"; echo "PROOF_EXIT=$1 STAGE=$STAGE TS=$TS START=$START END=$(date -u +%FT%TZ) REFUSED" | tee "$L/exit-$STAGE-$TS.log"; exit "$1"; }

# ---- Environment hygiene: no override of the pin, no hosted credentials reachable by children.
for pair in "G2_PG17_DATABASE_URL=$PIN_URL" "G2_PG17_CONFIRM=$PIN_CONFIRM" "G2_PG17_DATA_DIRECTORY=$PIN_DATA_DIRECTORY" "G2_PG17_SERVER_VERSION=$PIN_SERVER_VERSION"; do
  name="${pair%%=*}"; pinned="${pair#*=}"
  if [ -n "${!name:-}" ] && [ "${!name}" != "$pinned" ]; then refuse 2 "$name is preset to a value different from the runner pin; this runner does not accept target overrides"; fi
done
for v in DATABASE_URL DIRECT_URL SHADOW_DATABASE_URL TEST_DATABASE_URL SUPABASE_URL SUPABASE_ANON_KEY SUPABASE_SERVICE_ROLE_KEY SUPABASE_DB_URL \
         PGHOST PGHOSTADDR PGPORT PGUSER PGDATABASE PGPASSWORD PGPASSFILE PGSERVICE PGSERVICEFILE PGSSLMODE PGOPTIONS PGREQUIRESSL PGCONNECT_TIMEOUT; do
  unset "$v"
done
export G2_PG17_DATABASE_URL="$PIN_URL" G2_PG17_CONFIRM="$PIN_CONFIRM" G2_PG17_DATA_DIRECTORY="$PIN_DATA_DIRECTORY" G2_PG17_SERVER_VERSION="$PIN_SERVER_VERSION"
export G2_PG17_PSQL="${G2_PG17_PSQL:-/usr/bin/psql}"
export G2_PG17_OLD_ROOT="$S/old-root-925780e0" G2_PG17_OLD_CLIENT="$S/old-client-925780e0"
# Same heap as .github/workflows/ci.yml rls-live-tests; ts-jest OOMs (exit 137) at the 2 GB default (observed 2026-09-20).
export NODE_OPTIONS=--max-old-space-size=4096

# ---- Offline guard (no connection, no dependencies). Refuses before the lock is even requested.
offline_guard() {
  [ -d "$W/.git" ] || [ -f "$W/.git" ] || refuse 2 "candidate worktree $W missing"
  [ -d "$W/test/utils" ] || refuse 2 "candidate tree lacks test/utils"
  # Marker literals must be identical in source and runner (single point of truth is the TS module).
  grep -qF "G2_PG17_CLUSTER_MARKER = '$PIN_CLUSTER_MARKER'" "$W/test/utils/g2-pg17-db.ts" || refuse 2 "cluster marker literal differs between runner and test/utils/g2-pg17-db.ts"
  grep -qF "G2_PG17_DATABASE_MARKER = '$PIN_DB_MARKER'" "$W/test/utils/g2-pg17-db.ts" || refuse 2 "database marker literal differs between runner and test/utils/g2-pg17-db.ts"
  grep -qxF "CLUSTER_MARKER=$PIN_CLUSTER_MARKER" "$W/test/utils/g2-pg17-bootstrap.sh" || refuse 2 "cluster marker literal differs between runner and bootstrap"
  grep -qxF "DB_MARKER=$PIN_DB_MARKER" "$W/test/utils/g2-pg17-bootstrap.sh" || refuse 2 "database marker literal differs between runner and bootstrap"
  # Pinned URL shape: loopback, pinned high port, disposable database, admin role, no password/fragment.
  [[ "$PIN_URL" =~ ^postgresql://s5_super@127\.0\.0\.1:54325/g2_s5_etq0_disposable\?schema=public\&connection_limit=2$ ]] || refuse 2 "pinned URL shape violated"
  [[ "$PIN_CONFIRM" == "g2_s5_etq0_disposable:54325" ]] || refuse 2 "pinned confirmation violated"
  case "$PIN_PORT" in 5432|5433|6543|54321|54322|55439) refuse 2 "pinned port is a refused application/pooler/S1 port";; esac
  if [ "$STAGE" != oldroot ] && [ "$STAGE" != guard ]; then
    [ -n "${G2_PG17_PASSWORD:-}" ] || refuse 2 "G2_PG17_PASSWORD must come from the environment (fixture password; never from a file)"
    [[ ! "$G2_PG17_PASSWORD" =~ [[:space:]@/:?#] ]] || refuse 2 "fixture password is not in plain form"
    [[ ! "$G2_PG17_PASSWORD" =~ ^(eyJ|sbp_|sb_|postgres|postgresql) ]] || refuse 2 "password looks like a hosted token or URL, not a synthetic fixture password"
    export G2_PG17_PASSWORD   # inherited by bootstrap/jest children; never placed on a command line or in a log
    [ -x "$G2_PG17_PSQL" ] || refuse 2 "psql binary not executable: $G2_PG17_PSQL"
  fi
  if [ "$STAGE" != oldroot ] && [ "$STAGE" != preflight ] && [ "$STAGE" != reset ]; then
    [ -d "$W/node_modules/prisma" ] && [ -x "$W/node_modules/.bin/jest" ] || refuse 2 "node_modules missing in $W (run execution/s5-r3/npm-ci.sh under the canonical lock first)"
  fi
}

# ---- Stamp: pure observation, no cwd change, no writes outside logs. Password never logged.
stamp() {
  local head tree status clean fingerprint lockblob nmid
  head="$(git -C "$W" rev-parse HEAD)"; tree="$(git -C "$W" rev-parse HEAD^{tree})"
  status="$(git -C "$W" status --porcelain --untracked-files=all)"
  if [ -z "$status" ]; then clean=yes; fingerprint=none; else clean=no
    fingerprint="$( { git -C "$W" diff HEAD; printf '%s\n' "$status"; } | sha256sum | cut -c1-64)"; fi
  lockblob="$(git -C "$W" rev-parse HEAD:package-lock.json)"
  nmid="$([ -f "$W/node_modules/.package-lock.json" ] && sha256sum "$W/node_modules/.package-lock.json" | cut -c1-64 || echo absent)"
  {
    echo "TS=$TS STAGE=$STAGE RUNNER=s5-r3 REV=$RUNNER_REV START=$START"
    echo "WORKTREE=$W BRANCH=$(git -C "$W" rev-parse --abbrev-ref HEAD)"
    echo "HEAD=$head TREE=$tree CLEAN=$clean DIRTY_FINGERPRINT=$fingerprint"
    [ -n "$status" ] && printf 'DIRTY_PATH %s\n' "$status"
    echo "PACKAGE_LOCK_BLOB=$lockblob NODE_MODULES_PACKAGE_LOCK_SHA256=$nmid"
    echo "node $(node -v 2>/dev/null || echo absent) npm $(npm -v 2>/dev/null || echo absent) git $(git --version | cut -d' ' -f3) psql: $("$G2_PG17_PSQL" --version 2>/dev/null || echo absent)"
    echo "PIN host=$PIN_HOST port=$PIN_PORT db=$PIN_DB admin=$PIN_ADMIN datadir=$PIN_DATA_DIRECTORY version=$PIN_SERVER_VERSION cluster_marker=$PIN_CLUSTER_MARKER db_marker=$PIN_DB_MARKER"
    env | grep -E '^(G2_PG17_(DATABASE_URL|CONFIRM|PSQL|OLD_ROOT|OLD_CLIENT|DATA_DIRECTORY|SERVER_VERSION)|NODE_OPTIONS)=' | sort
    echo "G2_PG17_PASSWORD=<from environment, not logged>"
    echo "cpus=$(nproc) mem_mb=$(free -m | awk '/^Mem:/{print $2}')"
  } | tee "$L/env-$STAGE-$TS.log" | tee -a "$RUNLOG"
}

finish() { # $1 rc  — records END, releases the lock by exiting (fd 9 closes with this process)
  local rc="$1"
  echo "$(date -u +%FT%TZ) RELEASE=s5-r3 stage=$STAGE rc=$rc" >> "$X/test-validation.lock.log"
  echo "PROOF_EXIT=$rc STAGE=$STAGE TS=$TS START=$START END=$(date -u +%FT%TZ)" | tee "$L/exit-$STAGE-$TS.log" | tee -a "$RUNLOG" 9>&-
  exit "$rc"
}
# Run a child from an explicit directory with the lock fd closed; stdout/stderr appended to a log.
child() { # child <dir> <log> <cmd...>   (never pass secrets as arguments; they would be logged)
  local dir="$1" log="$2"; shift 2
  echo "CMD (cwd=$dir) $(date -u +%FT%TZ): $*" | tee -a "$log" >> "$RUNLOG"
  ( cd "$dir" && exec "$@" 9>&- ) 2>&1 | tee -a "$log"
  return "${PIPESTATUS[0]}"
}

# ---- Connected preflight (read-only; maintenance DB; superuser). Proves the disposable identity
#      BEFORE any mutation. All lines below are produced by ONE psql invocation, in fixed order.
psql_maint() { PGPASSWORD="$G2_PG17_PASSWORD" "$G2_PG17_PSQL" -X -w -qAt -v ON_ERROR_STOP=1 "$MAINT_URL" "$@" 9>&-; }
preflight() {
  local out
  out="$(psql_maint <<'SQL' 2>>"$RUNLOG"
SELECT current_setting('server_version_num');
SELECT current_setting('cluster_name');
SELECT current_setting('data_directory');
SELECT current_setting('listen_addresses');
SELECT host(inet_server_addr());
SELECT inet_server_port();
SELECT current_user;
SELECT rolsuper FROM pg_roles WHERE rolname=current_user;
SELECT count(*) FROM pg_roles WHERE rolname IN ('supabase_admin','supabase_auth_admin','supabase_storage_admin','authenticator','pgbouncer');
SELECT string_agg(datname,' ' ORDER BY datname) FROM pg_database;
SELECT count(*) FROM pg_database WHERE datname='g2_s5_etq0_disposable';
SELECT COALESCE((SELECT shobj_description(oid,'pg_database') FROM pg_database WHERE datname='g2_s5_etq0_disposable'),'<absent>');
SELECT count(*) FROM pg_stat_activity WHERE datname='g2_s5_etq0_disposable';
SQL
)" || { say "preflight: connection or query failed (see $RUNLOG)"; return 3; }
  local -a f; mapfile -t f <<<"$out"
  [ "${#f[@]}" = 13 ] || { say "preflight: expected 13 identity lines, got ${#f[@]}"; return 3; }
  printf 'PREFLIGHT version=%s cluster=%s datadir=%s listen=%s addr=%s port=%s user=%s super=%s hosted_roles=%s dbs=[%s] target_exists=%s target_marker=%s target_sessions=%s\n' "${f[@]}" | tee -a "$RUNLOG" | tee "$L/preflight-$STAGE-$TS.log"
  [ "${f[0]}" = "$PIN_SERVER_VERSION" ] || { say "preflight: server_version_num ${f[0]} != $PIN_SERVER_VERSION"; return 3; }
  [ "${f[1]}" = "$PIN_CLUSTER_MARKER" ] || { say "preflight: cluster_name '${f[1]}' is not the S5 marker '$PIN_CLUSTER_MARKER' (blank/foreign cluster refused)"; return 3; }
  [ "${f[2]}" = "$PIN_DATA_DIRECTORY" ] || { say "preflight: data_directory ${f[2]} != $PIN_DATA_DIRECTORY"; return 3; }
  [ "${f[3]}" = "$PIN_HOST" ] || { say "preflight: listen_addresses '${f[3]}' is not loopback-only"; return 3; }
  [ "${f[4]}" = "$PIN_HOST" ] || { say "preflight: server address ${f[4]} is not loopback"; return 3; }
  [ "${f[5]}" = "$PIN_PORT" ] || { say "preflight: server port ${f[5]} != $PIN_PORT"; return 3; }
  [ "${f[6]}" = "$PIN_ADMIN" ] || { say "preflight: connected as ${f[6]}, not $PIN_ADMIN"; return 3; }
  [ "${f[7]}" = "t" ] || { say "preflight: $PIN_ADMIN is not superuser on this cluster"; return 3; }
  [ "${f[8]}" = "0" ] || { say "preflight: hosted-platform roles present (${f[8]}); not a synthetic fixture"; return 3; }
  local d; for d in ${f[9]}; do case "$PIN_ALLOWED_DBS" in *" $d "*) ;; *) say "preflight: unexpected database '$d' on the cluster; foreign server refused"; return 3;; esac; done
  TARGET_EXISTS="${f[10]}"; TARGET_MARKER="${f[11]}"; TARGET_SESSIONS="${f[12]}"
  if [ "$TARGET_EXISTS" = 1 ]; then
    [ "$TARGET_MARKER" = "$PIN_DB_MARKER" ] || { say "preflight: $PIN_DB exists WITHOUT the S5 disposable marker comment; refusing (operator must inspect/remove it explicitly)"; return 3; }
  fi
  say "PREFLIGHT_OK target_exists=$TARGET_EXISTS"
  return 0
}

# =================================================================================================
offline_guard
say "OFFLINE_GUARD_OK stage=$STAGE rev=$RUNNER_REV"

if [ "$STAGE" = oldroot ]; then
  # Offline; git only. No fixture password, DB, dependencies or lock required.
  stamp
  child "$W" "$L/oldroot-$TS.log" bash test/utils/g2-pg17-old-root.sh create; rc=$?
  echo "PROOF_EXIT=$rc STAGE=$STAGE TS=$TS START=$START END=$(date -u +%FT%TZ)" | tee "$L/exit-$STAGE-$TS.log" | tee -a "$RUNLOG"; exit "$rc"
fi

# ---- Canonical lock: nonblocking; held from here until finish() for every remaining stage.
exec 9>"$LOCK"
flock -n 9 || { say "test-validation.lock busy; not queueing"; echo "PROOF_EXIT=75 STAGE=$STAGE TS=$TS START=$START END=$(date -u +%FT%TZ) LOCK_BUSY" | tee "$L/exit-$STAGE-$TS.log"; exit 75; }
echo "$(date -u +%FT%TZ) HOLDER=s5-r3 PURPOSE=g2-pg17-proof-$STAGE pid=$$" >> "$X/test-validation.lock.log"
say "LOCK_HELD $LOCK stage=$STAGE pid=$$"
# Every helper runs with fd 9 closed: only THIS process may hold the lock. (Observed 2026-09-21:
# the sandbox git is a wrapper that lingers ~1 s after exit; with fd 9 inherited it kept the
# lock busy for the next runner, rc 75 — fixed by closing 9 for stamp/preflight/finish children.)
stamp 9>&-

if [ "$STAGE" = all ] || [ "$STAGE" = guard ]; then
  child "$W" "$L/guard-unit-$TS.log" npx jest test/scout/g2-pg17-db-guard.spec.ts; rc=$?
  [ "$rc" = 0 ] || { say "guard stage failed rc=$rc; stopping"; finish "$rc"; }
  [ "$STAGE" = guard ] && finish 0
fi
if [ "$STAGE" = all ]; then
  child "$W" "$L/oldroot-$TS.log" bash test/utils/g2-pg17-old-root.sh create; rc=$?
  [ "$rc" = 0 ] || { say "old-root stage failed rc=$rc; no connection attempted"; finish "$rc"; }
fi

# ---- Connected identity proof precedes every mutation (reset/bootstrap/live/all).
preflight 9>&- || finish 3
[ "$STAGE" = preflight ] && finish 0

if [ "$STAGE" = reset ]; then
  if [ "$TARGET_EXISTS" = 0 ]; then say "reset: $PIN_DB absent; nothing to drop"; finish 0; fi
  [ "$TARGET_SESSIONS" = 0 ] || { say "reset: $TARGET_SESSIONS session(s) still attached to $PIN_DB; refusing to drop"; finish 3; }
  # Marker verified in preflight under the same lock; the DROP names the pinned database literally.
  echo "CMD: DROP DATABASE g2_s5_etq0_disposable (marker-verified, lane s5, as $PIN_ADMIN)" | tee -a "$RUNLOG" | tee "$L/reset-$TS.log"
  psql_maint -c 'DROP DATABASE g2_s5_etq0_disposable' 2>&1 | tee -a "$L/reset-$TS.log"; rc=${PIPESTATUS[0]}
  [ "$rc" = 0 ] || { say "reset: DROP DATABASE failed rc=$rc"; finish "$rc"; }
  [ "$(psql_maint -c "SELECT count(*) FROM pg_database WHERE datname='g2_s5_etq0_disposable'")" = 0 ] || { say "reset: database still present after DROP"; finish 3; }
  say "RESET_OK"; finish 0
fi
if [ "$STAGE" = all ] || [ "$STAGE" = bootstrap ]; then
  [ "$TARGET_EXISTS" = 0 ] || say "bootstrap: $PIN_DB already exists with the marker; bootstrap will refuse if it carries tables"
  child "$W" "$L/bootstrap-$TS.log" bash test/utils/g2-pg17-bootstrap.sh; rc=$?
  [ "$rc" = 0 ] || { say "bootstrap failed rc=$rc; live proof NOT started"; finish "$rc"; }
fi
if [ "$STAGE" = all ] || [ "$STAGE" = live ]; then
  child "$W" "$L/live-etq0-$TS.log" npx jest --config jest.rls.config.js test/rls-g2-pg17-etq0.spec.ts --runInBand --testTimeout=180000; rc=$?
  [ "$rc" = 0 ] || finish "$rc"
fi
finish 0
