#!/usr/bin/env bash
# S5 R4 G2 E->T/Q0 proof runner, revision 7 (validation harness only; synthetic disposable fixture on
# the isolated PostgreSQL 17.6 lane s5). Successor of the frozen checkpoint-5-B3 revision 6
# (sha256 7c290311...). Product, schema, migration and generator sources are never touched.
#
# Revision 7 closes the frozen S5 R3 audit findings on the runner surface only:
#   A-02  ONE supervisor (this process) owns the canonical lock from acquisition through owned-work
#         termination, cleanup stop, liveness verification and the exit record. Every owned child runs
#         in its own process group with a verified group id; an inner deadline (WORK_BUDGET) and
#         TERM/INT/HUP traps terminate and reap that group BEFORE the cleanup stop, inside a stated
#         cleanup budget. The first exit is recorded separately from the cleanup exit. A failed stop,
#         a surviving postmaster or a survivor of an owned group writes a QUARANTINE record that makes
#         every later stage of this lane refuse until the parent removes it explicitly; the runner
#         never "guarantees" cleanup it did not verify.
#   A-03  destroy requires an explicit confirmation variable, goes through the fail-closed fixture
#         (stop failure / survivor / removal failure propagate) and re-verifies absence here.
#   A-04  every mutating stage (bootstrap, live, all, full, resume, reset) requires the preflight
#         snapshot of sessions attached to the disposable database to be exactly zero. This is a
#         snapshot at preflight time, not a connection fence against an uncooperative process.
#   A-05  genctl accepts only the intended refusal class (rc 1 + "Could not resolve @prisma/client");
#         a timeout or unrelated failure is a control failure, not a pass. jest is invoked through the
#         pinned ./node_modules/.bin path, never through npx (which may fetch).
#   A-06  lane paths are grouped in one substitutable block, recorded in the stamp, and the successor
#         recreation packet (RECREATE.md) documents them.
# Preserved from revision 6: pinned literal identity, env override refusal, offline guard before the
# lock, non-blocking canonical lock, read-only 13-fact preflight before any mutation, PIPESTATUS-free
# direct child status, npm-root facts before/after, password never on a command line or in a log.
# Usage: G2_PG17_PASSWORD=<fixture pw> bash execution/s5-r4/run-proof.sh <stage>
#   oldroot    offline: create/verify the detached O checkout (git only; no lock, no DB, no deps)
#   guard      offline jest guard spec (needs node_modules; lock held; no DB connection)
#   preflight  lock + read-only connected identity proof only; mutates nothing
#   reset      preflight, then DROP DATABASE g2_s5_etq0_disposable ONLY if marked and idle
#   bootstrap  preflight, then test/utils/g2-pg17-bootstrap.sh (creates the marked database)
#   live       preflight, then the live spec
#   all        guard -> oldroot -> preflight -> bootstrap -> live (server already running; no reset)
#   init|start|stop|destroy   cluster lifecycle for lane s5 via s5-fixture.sh, under THIS lock
#              (init = FRESH ONLY; destroy additionally needs G2_PG17_DESTROY_CONFIRM=destroy:<datadir>)
#   full       guard -> oldroot -> init(fresh) -> start -> preflight -> bootstrap -> live -> stop
#   resume     guard -> oldroot -> start(marked, stopped) -> preflight -> generate-only -> live -> stop
#   genctl     offline closed-provenance generation controls (negative + positive), no DB
set -uo pipefail
RUNNER_REV=7
# ---- lane constants (the ONLY lines a frozen control driver may substitute; see controls/README.md)
W=/home/user/workspace/worktrees/s5-r4
X=/home/user/workspace/execution
S=$X/s5-r4
PG17_HOME=/home/user/pg17
WORK_BUDGET=1560
REAP_BUDGET=20
STOP_BUDGET=45
# ---- end lane constants
L=$S/logs
LOCK=$X/test-validation.lock
QUARANTINE_DIR=$S/QUARANTINE
mkdir -p "$L"

# ---- Pinned disposable target identity (literals; see test/utils/g2-pg17-db.ts for the markers).
PIN_HOST=127.0.0.1
PIN_PORT=54325
PIN_DB=g2_s5_etq0_disposable
PIN_ADMIN=s5_super
PIN_DATA_DIRECTORY=$PG17_HOME/clusters/s5
PIN_SERVER_VERSION=170006
PIN_CLUSTER_MARKER=s5-disposable-pg17
PIN_DB_MARKER=s5-g2-etq0-synthetic-disposable-fixture-safe-to-drop
# Databases that may exist on the s5 lane cluster (template*, maintenance, ours).
PIN_ALLOWED_DBS=" template0 template1 postgres $PIN_DB "
PG_DIST=$PG17_HOME/dist
PG_PROVENANCE=$PG17_HOME/PROVENANCE.txt
FIXTURE=$S/s5-fixture.sh
PIN_URL="postgresql://$PIN_ADMIN@$PIN_HOST:$PIN_PORT/$PIN_DB?schema=public&connection_limit=2"
PIN_CONFIRM="$PIN_DB:$PIN_PORT"
MAINT_URL="postgresql://$PIN_ADMIN@$PIN_HOST:$PIN_PORT/postgres?connect_timeout=5"

STAGE="${1:-}"
case "$STAGE" in oldroot|guard|preflight|reset|bootstrap|live|all|init|start|stop|destroy|full|resume|genctl) ;; *) echo "usage: $0 oldroot|guard|preflight|reset|bootstrap|live|all|init|start|stop|destroy|full|resume|genctl" >&2; exit 2;; esac
TS="$(date -u +%Y%m%dT%H%M%SZ)"
START="$(date -u +%FT%TZ)"
START_EPOCH=$(date +%s)
DEADLINE=$((START_EPOCH + WORK_BUDGET))
RUNLOG="$L/run-$STAGE-$TS.log"
say() { echo "$*" | tee -a "$RUNLOG"; }
refuse() { say "REFUSED rc=$1: $2"; echo "PROOF_EXIT=$1 FIRST_RC=$1 STAGE=$STAGE TS=$TS START=$START END=$(date -u +%FT%TZ) REFUSED" | tee "$L/exit-$STAGE-$TS.log"; exit "$1"; }

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
# O client is generated INSIDE the O checkout (its node_modules is the symlink to the pinned npm-ci tree), so
# `prisma generate` resolves @prisma/client locally; auto-install is disabled for every child (B2 finding).
export G2_PG17_OLD_ROOT="$S/old-root-925780e0" G2_PG17_OLD_CLIENT="$S/old-root-925780e0/.g2-old-client" PRISMA_GENERATE_SKIP_AUTOINSTALL=1
# Same heap as .github/workflows/ci.yml rls-live-tests; ts-jest OOMs (exit 137) at the 2 GB default (observed 2026-09-20).
export NODE_OPTIONS=--max-old-space-size=4096
export S5_STOP_TIMEOUT="$STOP_BUDGET"

# ---- Offline guard (no connection, no dependencies). Refuses before the lock is even requested.
offline_guard() {
  # A lane quarantined by an earlier unverified cleanup refuses every stage until the parent clears it.
  if [ -e "$QUARANTINE_DIR" ]; then refuse 4 "lane quarantined: $QUARANTINE_DIR exists (unverified stop/survivor from an earlier run); the parent must inspect and remove it explicitly before any stage runs"; fi
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
  case "$STAGE" in init|start|stop|destroy|full|resume)
    [ -x "$FIXTURE" ] || [ -f "$FIXTURE" ] || refuse 2 "fixture helper missing: $FIXTURE"
    [ -x "$PG_DIST/bin/pg_ctl" ] && [ -x "$PG_DIST/bin/initdb" ] && [ -x "$PG_DIST/bin/postgres" ] || refuse 2 "shared PG 17 distribution incomplete at $PG_DIST"
    [ -f "$PG_PROVENANCE" ] && grep -q '^result=success' "$PG_PROVENANCE" || refuse 2 "PG distribution provenance missing or not successful: $PG_PROVENANCE"
    [ "$(LD_LIBRARY_PATH=$PG_DIST/lib "$PG_DIST/bin/postgres" --version 2>/dev/null)" = "postgres (PostgreSQL) 17.6" ] || refuse 2 "shared server binary is not PostgreSQL 17.6"
    [ "$(sha256sum "$PG_DIST/bin/postgres" | cut -c1-64)" = "$(sed -n 's/^postgres_sha256=//p' "$PG_PROVENANCE")" ] || refuse 2 "postgres binary sha256 differs from PROVENANCE.txt"
    [ "$(sha256sum "$PG_DIST/bin/initdb" | cut -c1-64)" = "$(sed -n 's/^initdb_sha256=//p' "$PG_PROVENANCE")" ] || refuse 2 "initdb binary sha256 differs from PROVENANCE.txt"
    grep -qE "(^|; )MARKER=$PIN_CLUSTER_MARKER($|;| )" "$FIXTURE" && grep -q "^PORT=$PIN_PORT;" "$FIXTURE" && grep -q "^DATA=\$PG17_HOME/clusters/s5;" "$FIXTURE" || refuse 2 "fixture helper pins differ from runner pins"
    grep -qxF "PG17_HOME=$PG17_HOME" "$FIXTURE" || refuse 2 "fixture helper PG17_HOME differs from runner lane constant"
    grep -qE '^[^#]*\bflock\b' "$FIXTURE" && refuse 2 "fixture helper must not take the lock itself (nested flock)"
    ;; esac
  if [ "$STAGE" = init ] || [ "$STAGE" = full ]; then
    [ ! -e "$PIN_DATA_DIRECTORY" ] || refuse 3 "$PIN_DATA_DIRECTORY already exists; fresh init only — an unknown existing cluster is never marked, adopted or destroyed by this runner stage"
  fi
  if [ "$STAGE" = resume ]; then
    # resume = start an S5-marked cluster this lane already initialised and bootstrapped, then live; never a foreign directory.
    grep -q "^cluster_name = '$PIN_CLUSTER_MARKER'" "$PIN_DATA_DIRECTORY/postgresql.conf" 2>/dev/null || refuse 3 "$PIN_DATA_DIRECTORY is absent or not the S5-marked cluster; resume refuses"
    [ ! -f "$PIN_DATA_DIRECTORY/postmaster.pid" ] || refuse 3 "postmaster.pid present in $PIN_DATA_DIRECTORY; resume expects a stopped cluster"
  fi
  if [ "$STAGE" = destroy ]; then
    # Destruction is never implicit: the operator names the exact data directory in a separate variable.
    [ "${G2_PG17_DESTROY_CONFIRM:-}" = "destroy:$PIN_DATA_DIRECTORY" ] || refuse 2 "destroy requires G2_PG17_DESTROY_CONFIRM=destroy:$PIN_DATA_DIRECTORY (explicit, exact); refusing"
    [ -e "$PIN_DATA_DIRECTORY" ] || refuse 3 "$PIN_DATA_DIRECTORY is absent; nothing to destroy (not treated as success)"
  fi
  if [ "$STAGE" != oldroot ] && [ "$STAGE" != guard ] && [ "$STAGE" != genctl ] && [ "$STAGE" != init ] && [ "$STAGE" != start ] && [ "$STAGE" != stop ] && [ "$STAGE" != destroy ]; then
    [ -n "${G2_PG17_PASSWORD:-}" ] || refuse 2 "G2_PG17_PASSWORD must come from the environment (fixture password; never from a file)"
    [[ ! "$G2_PG17_PASSWORD" =~ [[:space:]@/:?#] ]] || refuse 2 "fixture password is not in plain form"
    [[ ! "$G2_PG17_PASSWORD" =~ ^(eyJ|sbp_|sb_|postgres|postgresql) ]] || refuse 2 "password looks like a hosted token or URL, not a synthetic fixture password"
    export G2_PG17_PASSWORD   # inherited by bootstrap/jest children; never placed on a command line or in a log
    [ -x "$G2_PG17_PSQL" ] || refuse 2 "psql binary not executable: $G2_PG17_PSQL"
  fi
  case "$STAGE" in guard|bootstrap|live|all|full|resume|genctl)
    [ -d "$W/node_modules/prisma" ] && [ -x "$W/node_modules/.bin/jest" ] && [ -x "$W/node_modules/.bin/prisma" ] || refuse 2 "node_modules missing in $W (run execution/s5-r4/npm-ci.sh under the canonical lock first)"
    ;; esac
}

# Observed facts about stray npm roots outside the worktree (B2 auto-install landed in /home/user). Printed at
# stamp time and again in finish so before/after is real, never reconstructed.
npm_root_facts() {
  local d f
  for d in /home/user /home/user/workspace "$S" "$G2_PG17_OLD_ROOT"; do
    for f in package.json package-lock.json; do
      [ -e "$d/$f" ] && echo "NPM_ROOT_FACT $d/$f size=$(stat -c %s "$d/$f") sha256=$(sha256sum "$d/$f" | cut -c1-64)" || echo "NPM_ROOT_FACT $d/$f absent"
    done
    if [ -L "$d/node_modules" ]; then echo "NPM_ROOT_FACT $d/node_modules symlink->$(readlink "$d/node_modules")"
    elif [ -d "$d/node_modules" ]; then echo "NPM_ROOT_FACT $d/node_modules dir files=$(find "$d/node_modules" -type f | wc -l)"
    else echo "NPM_ROOT_FACT $d/node_modules absent"; fi
  done
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
    echo "TS=$TS STAGE=$STAGE RUNNER=s5-r4 REV=$RUNNER_REV START=$START RUNNER_SHA256=$(sha256sum "$0" | cut -c1-64) FIXTURE_SHA256=$(sha256sum "$FIXTURE" 2>/dev/null | cut -c1-64)"
    echo "LANE W=$W X=$X S=$S PG17_HOME=$PG17_HOME WORK_BUDGET=$WORK_BUDGET REAP_BUDGET=$REAP_BUDGET STOP_BUDGET=$STOP_BUDGET"
    echo "WORKTREE=$W BRANCH=$(git -C "$W" rev-parse --abbrev-ref HEAD)"
    echo "HEAD=$head TREE=$tree CLEAN=$clean DIRTY_FINGERPRINT=$fingerprint"
    [ -n "$status" ] && printf 'DIRTY_PATH %s\n' "$status"
    echo "PACKAGE_LOCK_BLOB=$lockblob NODE_MODULES_PACKAGE_LOCK_SHA256=$nmid"
    echo "node $(node -v 2>/dev/null || echo absent) npm $(npm -v 2>/dev/null || echo absent) git $(git --version | cut -d' ' -f3) psql: $("$G2_PG17_PSQL" --version 2>/dev/null || echo absent)"
    echo "PIN host=$PIN_HOST port=$PIN_PORT db=$PIN_DB admin=$PIN_ADMIN datadir=$PIN_DATA_DIRECTORY version=$PIN_SERVER_VERSION cluster_marker=$PIN_CLUSTER_MARKER db_marker=$PIN_DB_MARKER"
    if [ -x "$PG_DIST/bin/postgres" ]; then
      echo "PG_DIST=$PG_DIST postgres_sha256=$(sha256sum "$PG_DIST/bin/postgres" | cut -c1-64) version=$(LD_LIBRARY_PATH=$PG_DIST/lib "$PG_DIST/bin/postgres" --version 2>/dev/null)"
      [ -f "$PG_PROVENANCE" ] && grep -E '^(artifact|jar_sha256|postgres_sha256|installed_by|utc|result)=' "$PG_PROVENANCE" | sed 's/^/PROVENANCE /'
    else echo "PG_DIST=absent"; fi
    echo "DATA_DIRECTORY_STATE=$([ -e "$PIN_DATA_DIRECTORY" ] && echo present || echo absent)"
    env | grep -E '^(G2_PG17_(DATABASE_URL|CONFIRM|PSQL|OLD_ROOT|OLD_CLIENT|DATA_DIRECTORY|SERVER_VERSION|DESTROY_CONFIRM)|NODE_OPTIONS|PRISMA_GENERATE_SKIP_AUTOINSTALL|S5_STOP_TIMEOUT)=' | sort
  npm_root_facts
    echo "G2_PG17_PASSWORD=<from environment, not logged>"
    echo "cpus=$(nproc) mem_mb=$(free -m | awk '/^Mem:/{print $2}')"
  } | tee "$L/env-$STAGE-$TS.log" | tee -a "$RUNLOG"
}

# =============================================================================================
# Supervision (A-02). Owned work runs in its own process group (setsid, verified); the supervisor
# keeps the lock, enforces the inner deadline, terminates/reaps the group on deadline or signal, and
# only then runs the cleanup stop. Nothing here is interruptible into "lock released, daemon alive".
SERVER_STARTED_HERE=0
OWNED_PGID=""            # process group of the currently running owned child ("" when none)
OWNED_SURVIVORS=""       # pids that survived TERM+KILL of an owned group (fatal for the exit record)
SIGNALLED=""             # name of the signal that interrupted owned work, if any
CLEANUP_BEGIN=""
pgid_of() { local s; s="$(cat "/proc/$1/stat" 2>/dev/null)" || { echo ""; return; }; s="${s##*) }"; set -- $s; echo "${3:-}"; }  # state ppid pgrp
children_of() { local p pid s; for p in /proc/[0-9]*; do pid=${p#/proc/}; s="$(cat "$p/stat" 2>/dev/null)" || continue; s="${s##*) }"; set -- $s; [ "${2:-}" = "$1" ] && echo -n "$pid "; done; }
group_members() { # pids whose process group is $1 (excluding this supervisor)
  local p pid; for p in /proc/[0-9]*; do pid=${p#/proc/}; [ "$pid" = "$$" ] && continue
    [ "$(pgid_of "$pid")" = "$1" ] && echo -n "$pid "; done
}
terminate_group() { # <pgid>: TERM, bounded reap, KILL, short reap; records survivors
  local pgid="$1" waited=0 members
  kill -TERM -- "-$pgid" 2>/dev/null
  while [ "$waited" -lt "$REAP_BUDGET" ]; do members="$(group_members "$pgid")"; [ -z "$members" ] && break; sleep 1; waited=$((waited + 1)); done
  members="$(group_members "$pgid")"
  if [ -n "$members" ]; then say "OWNED_GROUP_TERM_INCOMPLETE pgid=$pgid after ${waited}s; sending KILL to: $members"; kill -KILL -- "-$pgid" 2>/dev/null; sleep 2; fi
  members="$(group_members "$pgid")"
  if [ -n "$members" ]; then OWNED_SURVIVORS="$OWNED_SURVIVORS $members"; say "OWNED_GROUP_SURVIVORS pgid=$pgid pids=$members"; return 1; fi
  say "OWNED_GROUP_REAPED pgid=$pgid term_wait=${waited}s"; return 0
}
on_signal() { # <name>: owned work is terminated and reaped BEFORE finish() runs the cleanup stop
  local name="$1" rc
  SIGNALLED="$name"
  case "$name" in TERM) rc=143;; INT) rc=130;; HUP) rc=129;; *) rc=128;; esac
  say "SIGNAL $name received by supervisor pid=$$ at $(date -u +%FT%TZ); owned_pgid=${OWNED_PGID:-none}"
  [ -n "$OWNED_PGID" ] && terminate_group "$OWNED_PGID"
  OWNED_PGID=""
  finish "$rc"
}
trap 'on_signal TERM' TERM
trap 'on_signal INT' INT
trap 'on_signal HUP' HUP
# Run an owned child: explicit directory, lock fd closed, own process group (verified), inner deadline.
# Output goes to <log> only. Returns the child's real exit status, or 124 when the inner deadline
# terminated it (the child's own status after termination is recorded in the log line).
child() { # child <dir> <log> <cmd...>   (never pass secrets as arguments; they would be logged)
  local dir="$1" log="$2"; shift 2
  local pid pgid tries=0 now remaining rc timed_out=0
  remaining=$((DEADLINE - $(date +%s))); [ "$remaining" -ge 1 ] || remaining=1
  echo "CMD (cwd=$dir) $(date -u +%FT%TZ) budget=${remaining}s: $*" | tee -a "$log" >> "$RUNLOG"
  ( cd "$dir" && exec setsid -w "$@" 9>&- ) >>"$log" 2>&1 </dev/null &
  pid=$!
  # setsid applies in-process when the subshell is not a group leader (non-interactive bash without job
  # control), so the child's pgid must become its own pid. Verify; refuse to supervise an unknown group
  # (if setsid had to fork, -w keeps the parent waiting so the forked child can still be found and killed).
  pgid=""
  while [ "$tries" -lt 40 ]; do pgid="$(pgid_of "$pid")"; [ "$pgid" = "$pid" ] && break; kill -0 "$pid" 2>/dev/null || break; sleep 0.05; tries=$((tries + 1)); done
  if [ "$pgid" != "$pid" ] && kill -0 "$pid" 2>/dev/null; then
    local c cg; say "OWNED_GROUP_UNVERIFIED pid=$pid pgid=${pgid:-?}; terminating (fail closed)"
    for c in $(children_of "$pid"); do cg="$(pgid_of "$c")"; [ -n "$cg" ] && [ "$cg" != "$(pgid_of $$)" ] && terminate_group "$cg"; done
    kill -TERM "$pid" 2>/dev/null; sleep 1; kill -KILL "$pid" 2>/dev/null; wait "$pid" 2>/dev/null; return 3
  fi
  OWNED_PGID="$pid"
  while kill -0 "$pid" 2>/dev/null; do
    now=$(date +%s)
    if [ "$now" -ge "$DEADLINE" ]; then timed_out=1; say "OWNED_WORK_DEADLINE pgid=$pid budget=${WORK_BUDGET}s reached at $(date -u +%FT%TZ)"; terminate_group "$pid"; break; fi
    sleep 1
  done
  wait "$pid" 2>/dev/null; rc=$?
  OWNED_PGID=""
  # After a normal exit the group must be empty too: a detached grandchild is a survivor, not a pass.
  local members; members="$(group_members "$pid")"
  if [ -n "$members" ]; then say "OWNED_GROUP_LEFTOVER pgid=$pid after exit rc=$rc: $members"; terminate_group "$pid" || true; [ "$rc" = 0 ] && rc=3; fi
  echo "END (cwd=$dir) $(date -u +%FT%TZ) rc=$rc timed_out=$timed_out pgid=$pid" | tee -a "$log" >> "$RUNLOG"
  [ "$timed_out" = 1 ] && return 124
  return "$rc"
}
# Any process other than this runner holding the lock file open (e.g. a daemon that inherited fd 9)
# is a defect: report it and fail rather than let the lock outlive the run.
lock_exclusive_check() {
  local p pid others=""
  for p in /proc/[0-9]*; do pid=${p#/proc/}; [ "$pid" = "$$" ] && continue
    if ls -l "$p/fd" 2>/dev/null | grep -q "$LOCK"; then others="$others $pid:$(tr '\0' ' ' < "$p/cmdline" 2>/dev/null | cut -c1-60)"; fi
  done
  if [ -n "$others" ]; then say "LOCK_FD_LEAK other holders:$others"; return 1; fi
  say "LOCK_EXCLUSIVE_OK pid=$$"; return 0
}
quarantine() { # <reason>: durable marker that makes every later stage of this lane refuse (offline_guard)
  mkdir -p "$QUARANTINE_DIR"
  { echo "QUARANTINED $(date -u +%FT%TZ) stage=$STAGE ts=$TS pid=$$ reason=$1"
    echo "postmaster_pid=$( [ -f "$PIN_DATA_DIRECTORY/postmaster.pid" ] && head -1 "$PIN_DATA_DIRECTORY/postmaster.pid" || echo none)"
    echo "survivors=${OWNED_SURVIVORS:-none} signalled=${SIGNALLED:-none}"
    echo "The parent must inspect and stop/remove manually; this runner will not retry, destroy or reuse the lane while this directory exists."
  } | tee "$QUARANTINE_DIR/$TS-$STAGE.txt" | tee -a "$RUNLOG"
}
finish() { # $1 first rc — cleanup stop, liveness verification, exit records; the lock is held until exit
  local first_rc="$1" rc="$1"
  trap '' TERM INT HUP   # cleanup itself is not interruptible; the launcher backstop (KILL) is the last resort
  CLEANUP_BEGIN=$(date +%s)
  local stop_rc=na daemon=none
  if [ -n "$OWNED_PGID" ]; then terminate_group "$OWNED_PGID" || true; OWNED_PGID=""; fi
  if [ "$SERVER_STARTED_HERE" = 1 ]; then
    # Cleanup-stop status is recorded separately and never masks the first failure; a surviving
    # postmaster (partial start, failed stop) turns any rc 0 into a failure and quarantines the lane.
    ( cd "$S" && exec env S5_RUNNER_PID=$$ bash "$FIXTURE" stop 9>&- ) >>"$L/fixture-$TS.log" 2>&1 </dev/null; stop_rc=$?
    if [ -f "$PIN_DATA_DIRECTORY/postmaster.pid" ] && kill -0 "$(head -1 "$PIN_DATA_DIRECTORY/postmaster.pid")" 2>/dev/null; then daemon="alive pid=$(head -1 "$PIN_DATA_DIRECTORY/postmaster.pid")"; fi
    if [ "$stop_rc" != 0 ] || [ "$daemon" != none ]; then say "CLEANUP_STOP_FAILED stop_rc=$stop_rc daemon=$daemon"; quarantine "cleanup stop rc=$stop_rc daemon=$daemon"; [ "$rc" = 0 ] && rc=3; fi
  fi
  if [ -n "$OWNED_SURVIVORS" ]; then say "CLEANUP_OWNED_SURVIVORS pids=$OWNED_SURVIVORS"; [ -e "$QUARANTINE_DIR" ] || quarantine "owned-work survivors:$OWNED_SURVIVORS"; [ "$rc" = 0 ] && rc=3; fi
  { echo "# npm-root facts AFTER stage=$STAGE"; npm_root_facts; } >> "$L/env-$STAGE-$TS.log" 2>/dev/null
  local cleanup_s=$(( $(date +%s) - CLEANUP_BEGIN ))
  echo "$(date -u +%FT%TZ) RELEASE=s5-r4 stage=$STAGE first_rc=$first_rc rc=$rc stop_rc=$stop_rc daemon=$daemon survivors=${OWNED_SURVIVORS:-none} signalled=${SIGNALLED:-none} cleanup_s=$cleanup_s" >> "$X/test-validation.lock.log"
  echo "PROOF_EXIT=$rc FIRST_RC=$first_rc STAGE=$STAGE STOP_RC=$stop_rc DAEMON=$daemon SURVIVORS=${OWNED_SURVIVORS:-none} SIGNALLED=${SIGNALLED:-none} CLEANUP_SECONDS=$cleanup_s QUARANTINE=$([ -e "$QUARANTINE_DIR" ] && echo yes || echo no) TS=$TS START=$START END=$(date -u +%FT%TZ)" | tee "$L/exit-$STAGE-$TS.log" | tee -a "$RUNLOG" 9>&-
  exit "$rc"
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
  # A-04: every mutating stage requires zero sessions attached to the disposable database at this
  # snapshot. This is enforced (not merely logged); it is a preflight-time observation, not a fence.
  case "$STAGE" in reset|bootstrap|live|all|full|resume)
    if [ "$TARGET_EXISTS" = 1 ] && [ "$TARGET_SESSIONS" != 0 ]; then
      say "preflight: $TARGET_SESSIONS session(s) attached to $PIN_DB at preflight snapshot; mutating stage $STAGE refuses (required: exactly 0)"; return 3
    fi
    ;; esac
  say "PREFLIGHT_OK target_exists=$TARGET_EXISTS target_sessions=$TARGET_SESSIONS"
  return 0
}

# =================================================================================================
offline_guard
say "OFFLINE_GUARD_OK stage=$STAGE rev=$RUNNER_REV"

if [ "$STAGE" = oldroot ]; then
  # Offline; git only. No fixture password, DB, dependencies or lock required.
  stamp
  child "$W" "$L/oldroot-$TS.log" bash test/utils/g2-pg17-old-root.sh create; rc=$?
  echo "PROOF_EXIT=$rc FIRST_RC=$rc STAGE=$STAGE TS=$TS START=$START END=$(date -u +%FT%TZ)" | tee "$L/exit-$STAGE-$TS.log" | tee -a "$RUNLOG"; exit "$rc"
fi

# ---- Canonical lock: nonblocking; held from here until finish() for every remaining stage.
exec 9>"$LOCK"
flock -n 9 || { say "test-validation.lock busy; not queueing"; echo "PROOF_EXIT=75 FIRST_RC=75 STAGE=$STAGE TS=$TS START=$START END=$(date -u +%FT%TZ) LOCK_BUSY" | tee "$L/exit-$STAGE-$TS.log"; exit 75; }
echo "$(date -u +%FT%TZ) HOLDER=s5-r4 PURPOSE=g2-pg17-proof-$STAGE pid=$$ rev=$RUNNER_REV work_budget=${WORK_BUDGET}s cleanup_budget=$((REAP_BUDGET + STOP_BUDGET + 15))s" >> "$X/test-validation.lock.log"
say "LOCK_HELD $LOCK stage=$STAGE pid=$$ deadline=$(date -u -d "@$DEADLINE" +%FT%TZ)"
# Every helper runs with fd 9 closed: only THIS process may hold the lock.
stamp 9>&-

case "$STAGE" in
  init)    child "$S" "$L/fixture-$TS.log" env S5_RUNNER_PID=$$ bash "$FIXTURE" init; finish $? ;;
  start)   child "$S" "$L/fixture-$TS.log" env S5_RUNNER_PID=$$ bash "$FIXTURE" start; rc=$?; [ "$rc" = 0 ] && { lock_exclusive_check 9>&- || rc=3; }; finish "$rc" ;;
  stop)    child "$S" "$L/fixture-$TS.log" env S5_RUNNER_PID=$$ bash "$FIXTURE" stop; rc=$?
           if [ -f "$PIN_DATA_DIRECTORY/postmaster.pid" ] && kill -0 "$(head -1 "$PIN_DATA_DIRECTORY/postmaster.pid")" 2>/dev/null; then say "STOP_SURVIVOR pid=$(head -1 "$PIN_DATA_DIRECTORY/postmaster.pid")"; quarantine "explicit stop rc=$rc left a live postmaster"; [ "$rc" = 0 ] && rc=3; fi
           finish "$rc" ;;
  destroy) # A-03: fail-closed fixture destroy (stop failure/survivor/removal failure propagate), re-verified here.
           child "$S" "$L/fixture-$TS.log" env S5_RUNNER_PID=$$ bash "$FIXTURE" destroy; rc=$?
           if [ "$rc" = 0 ] && [ -e "$PIN_DATA_DIRECTORY" ]; then say "DESTROY_INCOMPLETE $PIN_DATA_DIRECTORY still present after DESTROY_OK"; rc=3; fi
           if [ "$rc" != 0 ] && [ -f "$PIN_DATA_DIRECTORY/postmaster.pid" ] && kill -0 "$(head -1 "$PIN_DATA_DIRECTORY/postmaster.pid")" 2>/dev/null; then quarantine "destroy refused with a live postmaster (rc=$rc)"; fi
           finish "$rc" ;;
esac

if [ "$STAGE" = genctl ]; then
  # Negative control (offline, no DB, no network): with auto-install off, generating into a directory that
  # resolves no @prisma/client must FAIL FOR THAT REASON (rc 1, "Could not resolve @prisma/client"), must
  # not create package.json/node_modules anywhere, and the positive path must resolve to the pinned tree.
  T="$(mktemp -d /tmp/s5-genctl-XXXXXX)"; mkdir -p "$T/no-root/out"
  sed "s|provider = \"prisma-client-js\"|provider = \"prisma-client-js\"\n  output   = \"$T/no-root/out\"|" "$W/prisma/schema.prisma" > "$T/schema.prisma"
  before="$(ls -t /home/user/.npm/_logs 2>/dev/null | head -1)"
  child "$T/no-root" "$L/genctl-negative-$TS.log" env PRISMA_GENERATE_SKIP_AUTOINSTALL=1 "$W/node_modules/.bin/prisma" generate --schema "$T/schema.prisma"; nrc=$?
  after="$(ls -t /home/user/.npm/_logs 2>/dev/null | head -1)"
  say "GENCTL negative: prisma generate outside any package root rc=$nrc (expected exactly 1 with the missing-client refusal) npm_log_before=$before npm_log_after=$after"
  if [ "$nrc" = 124 ]; then say "GENCTL_FAIL negative control hit the inner deadline (timeout is not a refusal)"; finish 3; fi
  [ "$nrc" = 1 ] || { say "GENCTL_FAIL negative control exited $nrc, not the intended refusal class (rc 1)"; finish 3; }
  grep -qF 'Could not resolve @prisma/client' "$L/genctl-negative-$TS.log" || { say "GENCTL_FAIL negative control failed for a reason other than the intended missing-client refusal (see $L/genctl-negative-$TS.log)"; finish 3; }
  [ ! -e "$T/package.json" ] && [ ! -e "$T/no-root/package.json" ] && [ ! -e /tmp/package.json ] && [ ! -d "$T/node_modules" ] && [ ! -d "$T/no-root/node_modules" ] || { say "GENCTL_FAIL auto-install artefacts created under $T or /tmp"; finish 3; }
  [ "$before" = "$after" ] || { say "GENCTL_FAIL a new npm invocation was logged during the negative control"; finish 3; }
  pos="$(node -p 'try { require("fs").realpathSync(require.resolve("@prisma/client/package.json", { paths: [process.argv[1]] })) } catch (e) { "UNRESOLVED" }' "$G2_PG17_OLD_CLIENT" 2>/dev/null)"
  exp="$(cd "$W" && node -p 'require("fs").realpathSync(require.resolve("@prisma/client/package.json"))')"
  say "GENCTL positive: @prisma/client from $G2_PG17_OLD_CLIENT -> $pos (pinned $exp)"
  [ "$pos" = "$exp" ] || { say "GENCTL_FAIL O client output does not resolve to the pinned @prisma/client (old root present? $([ -L "$G2_PG17_OLD_ROOT/node_modules" ] && echo symlink || echo no-symlink))"; finish 3; }
  say "GENCTL_OK intended_refusal=rc1:Could-not-resolve"; finish 0
fi
if [ "$STAGE" = all ] || [ "$STAGE" = full ] || [ "$STAGE" = resume ] || [ "$STAGE" = guard ]; then
  child "$W" "$L/guard-unit-$TS.log" ./node_modules/.bin/jest test/scout/g2-pg17-db-guard.spec.ts; rc=$?
  [ "$rc" = 0 ] || { say "guard stage failed rc=$rc; stopping"; finish "$rc"; }
  [ "$STAGE" = guard ] && finish 0
fi
if [ "$STAGE" = all ] || [ "$STAGE" = full ] || [ "$STAGE" = resume ]; then
  child "$W" "$L/oldroot-$TS.log" bash test/utils/g2-pg17-old-root.sh create; rc=$?
  [ "$rc" = 0 ] || { say "old-root stage failed rc=$rc; no connection attempted"; finish "$rc"; }
fi
if [ "$STAGE" = full ]; then
  # Fresh cluster under the same lock: init (refuses an existing directory), start, then prove the
  # postmaster did not inherit the lock fd before any connection is made.
  child "$S" "$L/fixture-$TS.log" env S5_RUNNER_PID=$$ bash "$FIXTURE" init; rc=$?
  [ "$rc" = 0 ] || { say "init failed rc=$rc; no server started"; finish "$rc"; }
fi
if [ "$STAGE" = full ] || [ "$STAGE" = resume ]; then
  SERVER_STARTED_HERE=1   # set BEFORE start so a partial/failed start is still cleaned up in finish
  child "$S" "$L/fixture-$TS.log" env S5_RUNNER_PID=$$ bash "$FIXTURE" start; rc=$?
  [ "$rc" = 0 ] || { say "start failed rc=$rc"; finish "$rc"; }
  lock_exclusive_check 9>&- || finish 3
fi

# ---- Connected identity proof precedes every mutation (reset/bootstrap/live/all/full/resume).
preflight 9>&- || finish 3
[ "$STAGE" = preflight ] && finish 0
if [ "$STAGE" = resume ]; then
  # Bootstrap already proven for this cluster (G2_PG17_BOOTSTRAP_OK); the marked target must exist and the spec's
  # beforeAll re-asserts 164 applied migrations + both markers before any test mutates it (and, since R4,
  # a refused beforeAll issues no teardown DDL/DML).
  [ "$TARGET_EXISTS" = 1 ] || { say "resume: marked target $PIN_DB absent; use full on a fresh directory instead"; finish 3; }
  child "$W" "$L/generate-only-$TS.log" bash test/utils/g2-pg17-bootstrap.sh generate-only; rc=$?
  [ "$rc" = 0 ] || { say "generate-only failed rc=$rc; live proof NOT started"; finish "$rc"; }
fi

if [ "$STAGE" = reset ]; then
  if [ "$TARGET_EXISTS" = 0 ]; then say "reset: $PIN_DB absent; nothing to drop"; finish 0; fi
  # Marker and zero-session snapshot verified in preflight under the same lock; the DROP names the pinned database literally.
  echo "CMD: DROP DATABASE g2_s5_etq0_disposable (marker-verified, idle at preflight, lane s5, as $PIN_ADMIN)" | tee -a "$RUNLOG" | tee "$L/reset-$TS.log"
  psql_maint -c 'DROP DATABASE g2_s5_etq0_disposable' >>"$L/reset-$TS.log" 2>&1; rc=$?
  [ "$rc" = 0 ] || { say "reset: DROP DATABASE failed rc=$rc"; finish "$rc"; }
  [ "$(psql_maint -c "SELECT count(*) FROM pg_database WHERE datname='g2_s5_etq0_disposable'")" = 0 ] || { say "reset: database still present after DROP"; finish 3; }
  say "RESET_OK"; finish 0
fi
if [ "$STAGE" = all ] || [ "$STAGE" = full ] || [ "$STAGE" = bootstrap ]; then
  [ "$TARGET_EXISTS" = 0 ] || say "bootstrap: $PIN_DB already exists with the marker; bootstrap will refuse if it carries tables"
  child "$W" "$L/bootstrap-$TS.log" bash test/utils/g2-pg17-bootstrap.sh; rc=$?
  [ "$rc" = 0 ] || { say "bootstrap failed rc=$rc; live proof NOT started"; finish "$rc"; }
fi
if [ "$STAGE" = all ] || [ "$STAGE" = full ] || [ "$STAGE" = resume ] || [ "$STAGE" = live ]; then
  child "$W" "$L/live-etq0-$TS.log" ./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-pg17-etq0.spec.ts --runInBand --testTimeout=180000; rc=$?
  [ "$rc" = 0 ] || finish "$rc"
fi
finish 0
