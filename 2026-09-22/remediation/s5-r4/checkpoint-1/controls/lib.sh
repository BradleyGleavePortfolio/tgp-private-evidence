#!/usr/bin/env bash
# S5 R4 frozen control library (NOT EXECUTED by the builder; prepared for parent inspection and a
# separately granted narrow no-DB slot). Everything here is synthetic: a private control root under
# /tmp, a lane-private lock file, fake pg_ctl/initdb/postgres/psql/jest/prisma binaries, and a
# DERIVED copy of the candidate runner + fixture in which ONLY the "lane constants" block is rewritten
# (recorded as a diff so a reviewer can verify no other byte changed). No PostgreSQL, no network,
# no npm, no canonical lock, no real worktree write.
# Dependencies: bash 5, coreutils (uutils 0.8 present in this sandbox), util-linux setsid/flock, git,
# node 20 (only for the genctl/positive resolution probe and the spec wiring probe). No node_modules.
set -uo pipefail
CTL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
S5R4="$(cd "$CTL_DIR/.." && pwd)"
CANDIDATE_RUNNER="$S5R4/run-proof.sh"
CANDIDATE_FIXTURE="$S5R4/s5-fixture.sh"
PRED_FIXTURE="/home/user/workspace/tgp-private-evidence/2026-09-21/remediation/s5-r3/b3-pinned-resume/checkpoint-5-B3/s5-fixture.sh"
PRED_RUNNER="/home/user/workspace/tgp-private-evidence/2026-09-21/remediation/s5-r3/b3-pinned-resume/checkpoint-5-B3/run-proof.sh"
CANDIDATE_WORKTREE=/home/user/workspace/worktrees/s5-r4
OUT="${S5_CTL_OUT:-$S5R4/control-results}"   # results directory (parent-assigned; never the frozen audit dirs)
mkdir -p "$OUT"
CTL_TS="$(date -u +%Y%m%dT%H%M%SZ)"
RESULT_LOG="$OUT/control-$CTL_TS.log"
PASS=0; FAIL=0
log() { echo "$(date -u +%FT%TZ) $*" | tee -a "$RESULT_LOG"; }
check() { # <id> <expr-result-rc> <description>
  if [ "$2" = 0 ]; then PASS=$((PASS + 1)); log "PASS $1 $3"; else FAIL=$((FAIL + 1)); log "FAIL $1 $3"; fi
}
# Refuse to run if the canonical lock is held by anyone or if a real lane artefact would be touched.
control_preconditions() {
  [ ! -e /home/user/workspace/execution/s5-r4/QUARANTINE ] || { log "REFUSE: real lane QUARANTINE exists; controls do not run over it"; exit 4; }
  [ "${S5_CTL_GRANT:-}" = "granted-by-parent" ] || { log "REFUSE: S5_CTL_GRANT=granted-by-parent not set; controls are prepared, not authorized"; exit 2; }
  # Controls never touch the canonical lock; they only record whether it is free at start (a free lock is not permission).
  if exec 8>>/home/user/workspace/execution/test-validation.lock && flock -n 8; then log "CANONICAL_LOCK_FREE_AT_START (not acquired; fd released immediately)"; else log "CANONICAL_LOCK_BUSY_AT_START (controls do not need it; continuing)"; fi
  exec 8>&-
}

# ---- Control root -------------------------------------------------------------------------------
# Layout: $CR/W (fake candidate tree), $CR/X (fake execution dir; lane-private lock), $CR/X/s5-r4
# (derived runner + fixture + logs), $CR/pg17 (fake dist + clusters), $CR/bin (fake psql/jest/prisma).
make_control_root() {
  CR="$(mktemp -d /tmp/s5-r4-ctl-XXXXXX)"
  export CR
  mkdir -p "$CR/W/test/utils" "$CR/W/test/scout" "$CR/W/node_modules/prisma" "$CR/W/node_modules/.bin" "$CR/W/node_modules/@prisma/client" "$CR/W/prisma" \
           "$CR/X/s5-r4" "$CR/pg17/dist/bin" "$CR/pg17/dist/lib" "$CR/bin" "$CR/scenario"
  # Fake candidate tree: a real (empty-history) git repo so `git -C W rev-parse HEAD` works in stamp().
  ( cd "$CR/W" && git init -q && git config user.email ctl@local && git config user.name ctl
    cat > test/utils/g2-pg17-db.ts <<'TS'
export const G2_PG17_CLUSTER_MARKER = 's5-disposable-pg17';
export const G2_PG17_DATABASE_MARKER = 's5-g2-etq0-synthetic-disposable-fixture-safe-to-drop';
TS
    cat > test/utils/g2-pg17-bootstrap.sh <<'SH'
#!/usr/bin/env bash
# FAKE bootstrap for lifecycle controls: prints the marker lines the runner greps, then succeeds.
CLUSTER_MARKER=s5-disposable-pg17
DB_MARKER=s5-g2-etq0-synthetic-disposable-fixture-safe-to-drop
echo "FAKE_BOOTSTRAP mode=${1:-bootstrap}"; [ -f "$CR/scenario/generate-only-sleep" ] && sleep "$(cat "$CR/scenario/generate-only-sleep")"
[ "${1:-}" = generate-only ] && { echo G2_PG17_GENERATE_OK; exit 0; }; echo G2_PG17_BOOTSTRAP_OK
SH
    cat > test/utils/g2-pg17-old-root.sh <<'SH'
#!/usr/bin/env bash
echo "FAKE_OLD_ROOT $*"; echo G2_PG17_OLD_ROOT_OK
SH
    printf 'generator client {\n  provider = "prisma-client-js"\n}\n' > prisma/schema.prisma
    echo '{"name":"@prisma/client","version":"0.0.0-fake"}' > node_modules/@prisma/client/package.json
    echo '{}' > package.json; echo '{}' > package-lock.json
    git add -A && git commit -q -m ctl )
  # Fake jest: owned work. Scenario file decides: exit code after N seconds; spawns a grandchild so
  # group termination (not just child termination) is what the control observes.
  cat > "$CR/W/node_modules/.bin/jest" <<'SH'
#!/usr/bin/env bash
# FAKE jest (owned work). scenario/jest: "<sleep_seconds> <exit_code>"; default "1 0".
read -r secs code < "$CR/scenario/jest" 2>/dev/null || { secs=1; code=0; }
st="$(cat /proc/$$/stat)"; st="${st##*) }"; set -- $st; echo "FAKE_JEST pid=$$ pgid=${3:-?} sleeping=$secs exit=$code"
sleep "$secs" & echo "FAKE_JEST_GRANDCHILD pid=$!" ; echo "$!" >> "$CR/scenario/jest.grandchildren"
wait; echo "FAKE_JEST_DONE"; exit "$code"
SH
  # Fake prisma CLI for genctl: scenario/prisma: "<exit_code> <stderr-text>"
  cat > "$CR/W/node_modules/.bin/prisma" <<'SH'
#!/usr/bin/env bash
read -r code rest < "$CR/scenario/prisma" 2>/dev/null || { code=1; rest="Error: Could not resolve @prisma/client."; }
echo "FAKE_PRISMA $*" ; echo "$rest" >&2; exit "$code"
SH
  chmod +x "$CR/W/node_modules/.bin/jest" "$CR/W/node_modules/.bin/prisma" "$CR/W/test/utils/"*.sh
  # Fake PostgreSQL distribution. postgres: version banner. initdb: creates DATA with PG_VERSION and a
  # postgresql.conf. pg_ctl: start = spawn a detached fake postmaster (sleep) and write postmaster.pid;
  # status = alive?; stop = per scenario/pg_ctl_stop ("ok" kills daemon + removes pid; "fail" rc 1 and
  # daemon left alive; "hang" sleeps 120). Every stop also records whether the runner's lock is HELD
  # at that instant (flock -n on the lane-private lock) so lock-through-cleanup is observable.
  cat > "$CR/pg17/dist/bin/postgres" <<'SH'
#!/usr/bin/env bash
[ "${1:-}" = --version ] && { echo "postgres (PostgreSQL) 17.6"; exit 0; }; echo "FAKE postgres $*"; exit 1
SH
  cat > "$CR/pg17/dist/bin/initdb" <<'SH'
#!/usr/bin/env bash
D=""; while [ $# -gt 0 ]; do case "$1" in -D) D="$2"; shift;; esac; shift; done
mkdir -p "$D" && echo 17 > "$D/PG_VERSION" && echo "# fake conf" > "$D/postgresql.conf" && echo "FAKE initdb ok $D"
SH
  cat > "$CR/pg17/dist/bin/pg_ctl" <<'SH'
#!/usr/bin/env bash
D=""; cmd=""; for a in "$@"; do case "$prev" in -D) D="$a";; esac; prev="$a"; case "$a" in start|stop|status) cmd="$a";; esac; done
LOCKF="$CR/X/test-validation.lock"
lock_state() { ( exec 7>>"$LOCKF"; if flock -n 7; then echo FREE; else echo HELD; fi ); }
alive() { [ -f "$D/postmaster.pid" ] && kill -0 "$(head -1 "$D/postmaster.pid")" 2>/dev/null; }
case "$cmd" in
  status) alive && { echo "pg_ctl: server is running"; exit 0; } || { echo "pg_ctl: no server running"; exit 3; } ;;
  start)  alive && { echo "already"; exit 0; }
          setsid sleep 3600 </dev/null >/dev/null 2>&1 & echo "$!" > "$D/postmaster.pid"; echo "$!" >> "$CR/scenario/fake-postmasters"
          echo "FAKE pg_ctl start pid=$! lock=$(lock_state)"; exit 0 ;;
  stop)   mode="$(cat "$CR/scenario/pg_ctl_stop" 2>/dev/null || echo ok)"
          echo "FAKE pg_ctl stop mode=$mode lock_at_stop=$(lock_state) $(date -u +%FT%TZ)" | tee -a "$CR/scenario/stop-observations"
          case "$mode" in
            ok)   alive && kill "$(head -1 "$D/postmaster.pid")" 2>/dev/null; sleep 0.2; rm -f "$D/postmaster.pid"; echo "server stopped"; exit 0 ;;
            fail) echo "pg_ctl: could not stop server (fake)"; exit 1 ;;
            hang) sleep 120; exit 1 ;;
          esac ;;
  *) echo "FAKE pg_ctl unknown $*"; exit 2 ;;
esac
SH
  chmod +x "$CR/pg17/dist/bin/"*
  { echo "result=success"; echo "postgres_sha256=$(sha256sum "$CR/pg17/dist/bin/postgres" | cut -c1-64)"; echo "initdb_sha256=$(sha256sum "$CR/pg17/dist/bin/initdb" | cut -c1-64)"; echo "artifact=fake-control-dist"; echo "installed_by=control"; echo "utc=$CTL_TS"; } > "$CR/pg17/PROVENANCE.txt"
  # Fake psql: prints the 13 preflight identity lines for the fake cluster; scenario/psql_sessions sets
  # the attached-session count (default 0). Any -c query answers "0" (used only by reset, not here).
  cat > "$CR/bin/psql" <<'SH'
#!/usr/bin/env bash
[ "${1:-}" = --version ] && { echo "psql (PostgreSQL) 17.6-fake"; exit 0; }
for a in "$@"; do [ "$a" = -c ] && { echo 0; exit 0; }; done
sess="$(cat "$CR/scenario/psql_sessions" 2>/dev/null || echo 0)"
printf '%s\n' 170006 s5-disposable-pg17 "$CR/pg17/clusters/s5" 127.0.0.1 127.0.0.1 54325 s5_super t 0 "g2_s5_etq0_disposable postgres template0 template1" 1 s5-g2-etq0-synthetic-disposable-fixture-safe-to-drop "$sess"
SH
  chmod +x "$CR/bin/psql"
  derive_runner "$CANDIDATE_RUNNER" "$CR/X/s5-r4/run-proof.sh" 1560 20 45
  derive_fixture "$CANDIDATE_FIXTURE" "$CR/X/s5-r4/s5-fixture.sh"
  log "CONTROL_ROOT $CR"
}
# Derived runner: rewrite ONLY the lane-constants block; record the diff against the candidate.
derive_runner() { # <src> <dst> <work_budget> <reap> <stop>
  sed -e "s|^W=/home/user/workspace/worktrees/s5-r4\$|W=$CR/W|" \
      -e "s|^X=/home/user/workspace/execution\$|X=$CR/X|" \
      -e "s|^PG17_HOME=/home/user/pg17\$|PG17_HOME=$CR/pg17|" \
      -e "s|^WORK_BUDGET=1560\$|WORK_BUDGET=$3|" -e "s|^REAP_BUDGET=20\$|REAP_BUDGET=$4|" -e "s|^STOP_BUDGET=45\$|STOP_BUDGET=$5|" "$1" > "$2"
  diff "$1" "$2" > "$2.derivation.diff"; local n; n=$(grep -c '^[<>]' "$2.derivation.diff")
  log "DERIVED_RUNNER $2 sha256=$(sha256sum "$2" | cut -c1-64) from=$(sha256sum "$1" | cut -c1-64) changed_lines=$n (expected <= 12: 6 constants x 2)"
}
derive_fixture() { # <src> <dst>
  sed -e "s|^PG17_HOME=/home/user/pg17\$|PG17_HOME=$CR/pg17|" -e "s|^PG17_HOME=/home/user/pg17; PGHOME=\$PG17_HOME/dist\$|PG17_HOME=$CR/pg17; PGHOME=\$PG17_HOME/dist|" "$1" > "$2"
  diff "$1" "$2" > "$2.derivation.diff"; local n; n=$(grep -c '^[<>]' "$2.derivation.diff")
  log "DERIVED_FIXTURE $2 sha256=$(sha256sum "$2" | cut -c1-64) from=$(sha256sum "$1" | cut -c1-64) changed_lines=$n (expected 2)"
}
# Runner invocation with the control environment; returns the runner rc. Background variant for signals.
run_derived() { # <stage> [env...]; stdout/stderr -> $CR/X/s5-r4/stage-<stage>.out
  local stage="$1"; shift
  ( cd "$CR/X/s5-r4" && env -i PATH="$CR/bin:/usr/local/bin:/usr/bin:/bin" HOME="$CR" CR="$CR" G2_PG17_PSQL="$CR/bin/psql" G2_PG17_PASSWORD=s5_local_synthetic "$@" \
      bash "$CR/X/s5-r4/run-proof.sh" "$stage" ) >> "$CR/X/s5-r4/stage-$stage.out" 2>&1
}
run_derived_bg() { # <stage> [env...]; sets RUNNER_PID
  local stage="$1"; shift
  ( cd "$CR/X/s5-r4" && exec env -i PATH="$CR/bin:/usr/local/bin:/usr/bin:/bin" HOME="$CR" CR="$CR" G2_PG17_PSQL="$CR/bin/psql" G2_PG17_PASSWORD=s5_local_synthetic "$@" \
      bash "$CR/X/s5-r4/run-proof.sh" "$stage" ) >> "$CR/X/s5-r4/stage-$stage.out" 2>&1 &
  RUNNER_PID=$!
}
latest() { ls -t "$CR/X/s5-r4/logs/$1"* 2>/dev/null | head -1; }
exit_field() { # <exit-file> <FIELD>
  tr ' ' '\n' < "$1" | sed -n "s/^$2=//p" | head -1
}
# Owned cleanup of everything the control created: fake postmasters and jest grandchildren by recorded pid
# (never by name), then the control root. Failures are reported, never hidden.
control_cleanup() {
  local p rc=0
  for f in fake-postmasters jest.grandchildren; do
    [ -f "$CR/scenario/$f" ] || continue
    while read -r p; do [ -n "$p" ] && kill -0 "$p" 2>/dev/null && { kill -TERM "$p" 2>/dev/null; sleep 0.2; kill -0 "$p" 2>/dev/null && kill -KILL "$p" 2>/dev/null; log "CLEANUP killed recorded $f pid=$p"; }; done < "$CR/scenario/$f"
  done
  sleep 0.3
  for f in fake-postmasters jest.grandchildren; do [ -f "$CR/scenario/$f" ] && while read -r p; do [ -n "$p" ] && kill -0 "$p" 2>/dev/null && { log "CLEANUP_SURVIVOR $f pid=$p"; rc=1; }; done < "$CR/scenario/$f"; done
  if [ "${S5_CTL_KEEP:-}" = 1 ] || [ "$rc" != 0 ]; then log "CONTROL_ROOT_RETAINED $CR (keep=${S5_CTL_KEEP:-0} survivors_rc=$rc)"; else cp -r "$CR/X/s5-r4/logs" "$OUT/logs-$CTL_TS-$(basename "$CR")" 2>/dev/null; rm -rf "$CR"; log "CONTROL_ROOT_REMOVED (logs copied to $OUT)"; fi
  return $rc
}
summary() { log "SUMMARY pass=$PASS fail=$FAIL result_log=$RESULT_LOG"; [ "$FAIL" = 0 ] || return 1; }
