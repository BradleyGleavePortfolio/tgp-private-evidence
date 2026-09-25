#!/usr/bin/env bash
# S7-L v4 proof supervisor (EXEC-DACEDDC8 PG-4b; prepared source-only under S7L-WC-1 follow-up, 2026-09-25 ~16:55Z).
# Runs the ONE authorized invocation of the frozen v4 driver, detached, exactly once; records identity; never retries.
#   outer command:  timeout -k 30 3900 bash /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v4/s7l-pg-proof.sh
# This script NEVER opens, flocks, deletes or recreates the canonical lock; the unchanged driver alone takes the
# nonblocking flock on fd9 and holds it to its exit. It never sends a signal to any process. Everything the supervisor
# does before launch is read-only. Modeled on s7l/binding/v3/run/supervisor.sh and s8c/binding/v4/run-prep/supervisor.sh.
# Modes:
#   bash supervisor.sh            parent/launch mode: refusals (read-only) -> setsid nohup re-exec of itself in --child
#                                 mode with stdin </dev/null and output to run-prep/; records LAUNCH.txt; returns at once.
#   bash supervisor.sh --child    detached mode (internal): runs the outer command once, waits, records LAUNCHER.txt.
# Requires S7L_PG4_GRANT=1 in the environment (set only by the executor under the explicit PG-4b grant after dual GO).
# Once-only: refuses if run-prep/LAUNCH.txt or LAUNCHER.txt exists, or if binding/v4/run/ (receipts + sentinel path) exists.
set -uo pipefail
V4=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v4
P=$V4/run-prep; R=$V4/run; DRIVER=$V4/s7l-pg-proof.sh; FIXTURE=$V4/s7l-fixture.sh
W=/home/user/workspace/worktrees/64e33dc7-s7l; LOCK=/home/user/workspace/execution/test-validation.lock
RUNTIME_ROOT=/home/user/workspace/execution/64e33dc7/recovery-reset
LANE=$RUNTIME_ROOT/proof-v4/clusters/s7l; SOCK=$RUNTIME_ROOT/proof-v4/run/s7l; OLDROOT=$RUNTIME_ROOT/proof-v4/s7l/old-root
EXPECT_HEAD=df713fd9217df524915348ef8a42c797f288dde1
EXPECT_TREE=796f437fea80550a379b5f54dc485bc5dbba67e1
EXPECT_PARENT=a68cdac70d81aea384fdc99c01c9c983a08e80eb
EXPECT_WORKER_BLOB=155ffdccd3d4e472cede84e7b11523d18201b450
EXPECT_DRIVER_SHA=8b03f4c247362bc3a255f8490c90e0e8ae546e6c08f89cfb0e3bcbdee0f1fa8f
EXPECT_FIXTURE_SHA=74aed2611c9abb507b65697fa1b88834d5e8afe876e12c7d19f1068873e8e751
EXPECT_BINDING_MANIFEST_SHA=6c912b961e3df418008e60f61f47566019ffd7f79c6ae1aa29dc6a79d527f52c
OUTER_TIMEOUT=3900
CMD="timeout -k 30 $OUTER_TIMEOUT bash $DRIVER"
ts(){ date -u +%FT%TZ; }
sha(){ sha256sum "$1" | cut -c1-64; }

if [ "${1:-}" = "--child" ]; then
  # ---- detached mode: one invocation, wait, record. Never relaunch on any rc; never signal the child.
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
  echo "POST $(ts) lock_holders=$(lslocks 2>/dev/null | grep -c test-validation.lock) postgres_procs=$(pgrep -cx postgres || true) port55641=$(ss -ltn 2>/dev/null | grep -c ':55641 ' || true) sentinel=$( [ -e "$R/s7l-pg-proof.sentinel" ] && cat "$R/s7l-pg-proof.sentinel" || echo ABSENT)" >> "$L"
  ( cd "$P" && sha256sum LAUNCH.txt LAUNCHER.txt driver.stdout driver.stderr > LAUNCH_RECEIPTS.sha256 2>/dev/null )
  echo "END rc=$RC $(ts) receipts=$P/LAUNCH_RECEIPTS.sha256 driver_receipts=$R/RECEIPTS.sha256" >> "$L"
  exit "$RC"
fi

# ---- launch mode: read-only refusals, then detach. Any refusal exits WITHOUT launching and writes nothing but REFUSED.txt.
refuse(){ echo "REFUSED rc=$1 $(ts): $2" | tee -a "$P/REFUSED.txt" >&2; exit "$1"; }
[ "${S7L_PG4_GRANT:-}" = 1 ] || refuse 70 "S7L_PG4_GRANT=1 not set (explicit PG-4b grant after dual GO required)"
[ ! -e "$P/LAUNCH.txt" ] && [ ! -e "$P/LAUNCHER.txt" ] || refuse 76 "run-prep already launched once (LAUNCH.txt/LAUNCHER.txt exist); this proof runs once, no retry"
[ ! -e "$R" ] || refuse 76 "$R exists (driver receipts/sentinel path must be fresh)"
[ -r "$DRIVER" ] && [ -r "$FIXTURE" ] || refuse 71 "driver/fixture missing or unreadable (invoked via bash; frozen mode 644 is expected)"
[ "$(sha "$DRIVER")" = "$EXPECT_DRIVER_SHA" ] || refuse 71 "driver sha $(sha "$DRIVER") != $EXPECT_DRIVER_SHA"
[ "$(sha "$FIXTURE")" = "$EXPECT_FIXTURE_SHA" ] || refuse 71 "fixture sha $(sha "$FIXTURE") != $EXPECT_FIXTURE_SHA"
[ "$(sha "$V4/BINDING.sha256")" = "$EXPECT_BINDING_MANIFEST_SHA" ] || refuse 71 "BINDING.sha256 sha drifted"
(cd "$V4" && sha256sum -c --quiet BINDING.sha256 >/dev/null 2>&1) || refuse 71 "BINDING.sha256 verification failed"
# the driver's own pins must be the frozen values this supervisor expects (no silent rebind)
[ "$(sed -n 's/^EXPECT_HEAD=\([0-9a-f]\{40\}\).*/\1/p' "$DRIVER")" = "$EXPECT_HEAD" ] || refuse 71 "driver EXPECT_HEAD pin != $EXPECT_HEAD"
[ "$(sed -n 's/^EXPECT_TREE=\([0-9a-f]\{40\}\).*/\1/p' "$DRIVER")" = "$EXPECT_TREE" ] || refuse 71 "driver EXPECT_TREE pin != $EXPECT_TREE"
[ "$(sed -n 's/^EXPECT_PARENT=\([0-9a-f]\{40\}\).*/\1/p' "$DRIVER")" = "$EXPECT_PARENT" ] || refuse 71 "driver EXPECT_PARENT pin != $EXPECT_PARENT"
[ "$(sed -n 's/^EXPECT_WORKER_BLOB=\([0-9a-f]\{40\}\).*/\1/p' "$DRIVER")" = "$EXPECT_WORKER_BLOB" ] || refuse 71 "driver EXPECT_WORKER_BLOB pin != $EXPECT_WORKER_BLOB"
[ "$(sed -n 's/^EXPECT_FIXTURE_SHA=\([0-9a-f]\{64\}\).*/\1/p' "$DRIVER")" = "$EXPECT_FIXTURE_SHA" ] || refuse 71 "driver EXPECT_FIXTURE_SHA pin != $EXPECT_FIXTURE_SHA"
[ "$(git -C "$W" rev-parse HEAD 2>/dev/null)" = "$EXPECT_HEAD" ] || refuse 71 "worktree HEAD != $EXPECT_HEAD"
[ "$(git -C "$W" rev-parse 'HEAD^{tree}' 2>/dev/null)" = "$EXPECT_TREE" ] || refuse 71 "worktree tree != $EXPECT_TREE"
[ "$(git -C "$W" rev-parse HEAD^ 2>/dev/null)" = "$EXPECT_PARENT" ] || refuse 71 "worktree HEAD^ != $EXPECT_PARENT"
[ "$(git -C "$W" rev-parse HEAD:test/utils/g2-s7l-worker.cjs 2>/dev/null)" = "$EXPECT_WORKER_BLOB" ] || refuse 71 "worker blob != $EXPECT_WORKER_BLOB"
[ -z "$(git -C "$W" status --porcelain --untracked-files=all 2>/dev/null)" ] || refuse 71 "worktree dirty"
[ -e "$LOCK" ] || refuse 75 "canonical lock file absent (never created here)"
[ "$(lslocks 2>/dev/null | grep -c test-validation.lock)" = 0 ] || refuse 75 "canonical lock has a live holder (heavy slot busy); not launching"
[ "$(pgrep -cx postgres || true)" = 0 ] || refuse 75 "postgres process(es) running"
[ -z "$(pgrep -f 's7l-pg-proof.sh|s8c-pg-proof.sh|/jest |node_modules/.bin/jest' 2>/dev/null | grep -vx "$$")" ] || refuse 75 "another proof driver or jest process is live"
[ "$(ss -ltn 2>/dev/null | grep -c ':55641 ' || true)" = 0 ] || refuse 75 "port 55641 (S7-L) has a listener"
[ "$(ss -ltn 2>/dev/null | grep -c ':55642 ' || true)" = 0 ] || refuse 75 "port 55642 (S8-C) has a listener"
[ ! -e "$LANE" ] || refuse 71 "fresh lane $LANE already exists (never adopt)"
[ ! -e "$SOCK" ] || [ -z "$(ls -A "$SOCK" 2>/dev/null)" ] || refuse 71 "socket dir $SOCK not empty"
[ ! -e "$OLDROOT" ] || refuse 71 "fresh OLD root $OLDROOT already exists (never adopt)"
[ -x "$RUNTIME_ROOT/pg17/dist/bin/postgres" ] || refuse 71 "pinned PG binaries absent under $RUNTIME_ROOT/pg17/dist"
[ -d "$W/node_modules" ] && [ ! -L "$W/node_modules" ] || refuse 71 "builder node_modules absent or a symlink"
mkdir -p "$P"
{ echo "LAUNCH_UTC=$(ts)"; echo "GRANT=PG-4b (execution/daceddc8/SCOPE.md); executor pid=$$ user=$(id -un)"
  echo "CMD=$CMD"; echo "SUPERVISOR_SHA256=$(sha "$P/supervisor.sh")"
  echo "DRIVER_SHA256=$EXPECT_DRIVER_SHA FIXTURE_SHA256=$EXPECT_FIXTURE_SHA BINDING_MANIFEST_SHA256=$EXPECT_BINDING_MANIFEST_SHA"
  echo "HEAD=$EXPECT_HEAD TREE=$EXPECT_TREE PARENT=$EXPECT_PARENT WORKER_BLOB=$EXPECT_WORKER_BLOB"
  echo "LOCK_PRE=inode $(stat -c %i "$LOCK") holders 0; postgres 0; 55641 free; 55642 free; lane absent; socket empty/absent; old-root absent; $R absent"; } > "$P/LAUNCH.txt"
S7L_PG4_GRANT=1 setsid nohup bash "$P/supervisor.sh" --child < /dev/null > "$P/supervisor.stdout" 2> "$P/supervisor.stderr" &
SP=$!
echo "SUPERVISOR_PID=$SP DETACHED=$(ts)" >> "$P/LAUNCH.txt"
echo "LAUNCHED supervisor_pid=$SP; poll $P/LAUNCHER.txt for LAUNCHER_EXIT/END; never invoke again"
exit 0
