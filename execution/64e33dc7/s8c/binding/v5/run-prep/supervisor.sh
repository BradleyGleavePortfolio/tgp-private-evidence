#!/usr/bin/env bash
# S8-C v5 proof supervisor (EXEC-DACEDDC8 PG-5; prepared under S8C-BC-5, 2026-09-25 ~17:25Z).
# Runs the ONE authorized invocation of the frozen v5 driver, detached, exactly once; records identity; never retries.
#   outer command:  timeout -k 30 3900 bash /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c/binding/v5/s8c-pg-proof.sh
# This script NEVER opens, flocks, deletes or recreates the canonical lock; the unchanged driver alone takes the
# nonblocking flock on fd9 and holds it to its exit. Everything the supervisor does before launch is read-only.
# Modes:
#   bash supervisor.sh            parent/launch mode: refusals (read-only) -> setsid nohup re-exec of itself in --child
#                                 mode with stdin </dev/null and output to run-prep/; records LAUNCH.txt; returns at once.
#   bash supervisor.sh --child    detached mode (internal): runs the outer command once, waits, records LAUNCHER.txt.
# Requires S8C_PG5_GRANT=1 in the environment (set only by the executor under the explicit PG-5 grant after dual GO).
# Once-only: refuses if run-prep/LAUNCH.txt or LAUNCHER.txt exists, or if binding/v5/run/ or its sentinel exists.
set -uo pipefail
V5=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c/binding/v5
P=$V5/run-prep; R=$V5/run; DRIVER=$V5/s8c-pg-proof.sh; FIXTURE=$V5/s8c-fixture.sh
W=/home/user/workspace/worktrees/64e33dc7-s8c; LOCK=/home/user/workspace/execution/test-validation.lock
RUNTIME_ROOT=/home/user/workspace/execution/64e33dc7/recovery-reset
LANE=$RUNTIME_ROOT/proof-v5/clusters/s8-c; SOCK=$RUNTIME_ROOT/proof-v5/run/s8-c
EXPECT_HEAD=f428db9ab65f638da1651b8cd792c6f93b4983c1
EXPECT_TREE=f2623be642ddfbba025ffe8360256a683ac57997
EXPECT_DRIVER_SHA=b641db2d5fae07d9220e573a04cb512c5ec35814b08ae7c506c02499c314fd1d
EXPECT_FIXTURE_SHA=34a42ab8b2ffa75256f5fa600ca7a51bcdb3ae1f224ad989ff1ca7a4dd716f10
EXPECT_BINDING_MANIFEST_SHA=2995ed837fd352e3ea663949cc74e66ca5eec4566444739e8b7f53aab87c9eba
OUTER_TIMEOUT=3900
CMD="timeout -k 30 $OUTER_TIMEOUT bash $DRIVER"
ts(){ date -u +%FT%TZ; }
sha(){ sha256sum "$1" | cut -c1-64; }

if [ "${1:-}" = "--child" ]; then
  # ---- detached mode: one invocation, wait, record. Never relaunch on any rc.
  L=$P/LAUNCHER.txt
  echo "SUPERVISOR_START $(ts) supervisor_pid=$$ pgid=$(ps -o pgid= -p $$ | tr -d ' ') sid=$(ps -o sid= -p $$ | tr -d ' ') cmd='$CMD' stdin=/dev/null stdout=$P/driver.stdout stderr=$P/driver.stderr" >> "$L"
  echo "PRE_LAUNCH $(ts) lock_inode=$(stat -c %i "$LOCK" 2>/dev/null || echo ABSENT) lock_holders=$(lslocks 2>/dev/null | grep -c test-validation.lock) postgres_procs=$(pgrep -cx postgres || true) port55641=$(ss -ltn 2>/dev/null | grep -c ':55641 ' || true) port55642=$(ss -ltn 2>/dev/null | grep -c ':55642 ' || true)" >> "$L"
  timeout -k 30 "$OUTER_TIMEOUT" bash "$DRIVER" < /dev/null > "$P/driver.stdout" 2> "$P/driver.stderr" &
  DP=$!
  sleep 1
  DRV=$(pgrep -P "$DP" 2>/dev/null | head -1)
  echo "TIMEOUT_WRAPPER_PID=$DP DRIVER_PID=${DRV:-unknown} $(ts)" >> "$L"
  wait "$DP"; RC=$?
  echo "LAUNCHER_EXIT rc=$RC $(ts) (124/137=outer timeout; anything else = driver's own rc)" >> "$L"
  echo "POST $(ts) lock_holders=$(lslocks 2>/dev/null | grep -c test-validation.lock) postgres_procs=$(pgrep -cx postgres || true) port55642=$(ss -ltn 2>/dev/null | grep -c ':55642 ' || true) sentinel=$( [ -e "$R/s8c-pg-proof.sentinel" ] && cat "$R/s8c-pg-proof.sentinel" || echo ABSENT)" >> "$L"
  ( cd "$P" && sha256sum LAUNCH.txt LAUNCHER.txt driver.stdout driver.stderr > LAUNCH_RECEIPTS.sha256 2>/dev/null )
  echo "END rc=$RC $(ts) receipts=$P/LAUNCH_RECEIPTS.sha256 driver_receipts=$R/RECEIPTS.sha256" >> "$L"
  exit "$RC"
fi

# ---- launch mode: read-only refusals, then detach. Any refusal exits WITHOUT launching and writes nothing but REFUSED.txt.
refuse(){ echo "REFUSED rc=$1 $(ts): $2" | tee -a "$P/REFUSED.txt" >&2; exit "$1"; }
[ "${S8C_PG5_GRANT:-}" = 1 ] || refuse 70 "S8C_PG5_GRANT=1 not set (explicit PG-5 grant after dual GO required)"
[ ! -e "$P/LAUNCH.txt" ] && [ ! -e "$P/LAUNCHER.txt" ] || refuse 76 "run-prep already launched once (LAUNCH.txt/LAUNCHER.txt exist); this proof runs once, no retry"
[ ! -e "$R" ] || refuse 76 "$R exists (driver receipts/sentinel path must be fresh)"
[ -x "$DRIVER" ] && [ -x "$FIXTURE" ] || refuse 71 "driver/fixture missing or not executable"
[ "$(sha "$DRIVER")" = "$EXPECT_DRIVER_SHA" ] || refuse 71 "driver sha $(sha "$DRIVER") != $EXPECT_DRIVER_SHA"
[ "$(sha "$FIXTURE")" = "$EXPECT_FIXTURE_SHA" ] || refuse 71 "fixture sha $(sha "$FIXTURE") != $EXPECT_FIXTURE_SHA"
[ "$(sha "$V5/BINDING.sha256")" = "$EXPECT_BINDING_MANIFEST_SHA" ] || refuse 71 "BINDING.sha256 sha drifted"
(cd "$V5" && sha256sum -c --quiet BINDING.sha256 >/dev/null 2>&1) || refuse 71 "BINDING.sha256 verification failed"
[ "$(git -C "$W" rev-parse HEAD 2>/dev/null)" = "$EXPECT_HEAD" ] || refuse 71 "worktree HEAD != $EXPECT_HEAD"
[ "$(git -C "$W" rev-parse 'HEAD^{tree}' 2>/dev/null)" = "$EXPECT_TREE" ] || refuse 71 "worktree tree != $EXPECT_TREE"
[ -z "$(git -C "$W" status --porcelain --untracked-files=all 2>/dev/null)" ] || refuse 71 "worktree dirty"
[ -e "$LOCK" ] || refuse 75 "canonical lock file absent (never created here)"
[ "$(lslocks 2>/dev/null | grep -c test-validation.lock)" = 0 ] || refuse 75 "canonical lock has a live holder (heavy slot busy); not launching"
[ "$(pgrep -cx postgres || true)" = 0 ] || refuse 75 "postgres process(es) running"
[ "$(ss -ltn 2>/dev/null | grep -c ':55641 ' || true)" = 0 ] || refuse 75 "port 55641 (S7-L) has a listener"
[ "$(ss -ltn 2>/dev/null | grep -c ':55642 ' || true)" = 0 ] || refuse 75 "port 55642 (S8-C) has a listener"
[ ! -e "$LANE" ] || refuse 71 "fresh lane $LANE already exists (never adopt)"
[ ! -e "$SOCK" ] || [ -z "$(ls -A "$SOCK" 2>/dev/null)" ] || refuse 71 "socket dir $SOCK not empty"
[ -x "$RUNTIME_ROOT/pg17/dist/bin/postgres" ] || refuse 71 "pinned PG binaries absent under $RUNTIME_ROOT/pg17/dist"
mkdir -p "$P"
{ echo "LAUNCH_UTC=$(ts)"; echo "GRANT=PG-5 (execution/daceddc8/SCOPE.md); executor pid=$$ user=$(id -un)"
  echo "CMD=$CMD"; echo "SUPERVISOR_SHA256=$(sha "$P/supervisor.sh")"
  echo "DRIVER_SHA256=$EXPECT_DRIVER_SHA FIXTURE_SHA256=$EXPECT_FIXTURE_SHA BINDING_MANIFEST_SHA256=$EXPECT_BINDING_MANIFEST_SHA"
  echo "HEAD=$EXPECT_HEAD TREE=$EXPECT_TREE"
  echo "LOCK_PRE=inode $(stat -c %i "$LOCK") holders 0; postgres 0; 55641 free; 55642 free; lane absent; socket empty/absent; $R absent"; } > "$P/LAUNCH.txt"
S8C_PG5_GRANT=1 setsid nohup bash "$P/supervisor.sh" --child < /dev/null > "$P/supervisor.stdout" 2> "$P/supervisor.stderr" &
SP=$!
echo "SUPERVISOR_PID=$SP DETACHED=$(ts)" >> "$P/LAUNCH.txt"
echo "LAUNCHED supervisor_pid=$SP; poll $P/LAUNCHER.txt for LAUNCHER_EXIT/END; never invoke again"
exit 0
