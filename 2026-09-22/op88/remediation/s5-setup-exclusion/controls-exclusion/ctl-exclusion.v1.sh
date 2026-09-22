#!/usr/bin/env bash
# OP88-S5-SETUP-EXCLUSION deterministic PRIVATE fault controls (NOT EXECUTED by the builder; separate grant). Runs the exact launcher bytes with
# S5X_PRIVATE=1 against a private lock/EX tree and the fake runner; proves the A-04 boundary only: (1) normal release after verified-empty,
# (2) descendant left in the owned session -> one escalation -> release, (3) inner timeout ends an overrunning runner -> release,
# (4) failed marker publication with unresolved ownership -> observable SELF-HOLD retaining the lock -> checked handoff release.
# Bounds: each case <= 40 s (S5X_INNER_BOUND=5, NORMAL_BOUND 12, HEARTBEAT 2); outer timeout --foreground -k 10 200. No network/install/canonical lock.
set -uo pipefail; HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; PKT="$(cd "$HERE/.." && pwd)"
[ "${S5_CTL_GRANT:-}" = "granted-by-parent" ] || { echo "REFUSE: S5_CTL_GRANT=granted-by-parent not set"; exit 2; }
PIN_L=1773ac7d2b37670c2dd711347a3cc1515fb5fbb68adcc680381a26434f30e033; [ "$(sha256sum "$PKT/launch-s5-setup-exclusion.v1.sh" | cut -c1-64)" = "$PIN_L" ] || { echo "REFUSE launcher hash"; exit 2; }
OUT="${S5X_OUT:-$PKT/control-results}/$(date -u +%Y%m%dT%H%M%SZ)"; mkdir -p "$OUT" || exit 74; LOG="$OUT/ctl.log"; PASS=0; FAIL=0; LPID=""
log() { echo "$(date -u +%FT%TZ) $*" | tee -a "$LOG"; }
check() { if [ "$2" = 0 ]; then PASS=$((PASS+1)); log "PASS $1 $3"; else FAIL=$((FAIL+1)); log "FAIL $1 $3"; log "STOP_ON_FIRST_FAILURE $1"; exit 1; fi; }
lock_free() { ( exec 8>"$1"; flock -n 8 ) 2>/dev/null; }   # PRIVATE lock only: probe by acquiring in a subshell that exits immediately
launch() { # <case> <scenario> -> EXD LPID; launcher runs detached in its own session, unbounded (as in canonical use)
  EXD="$OUT/$1"; mkdir -p "$EXD"; export S5X_PRIVATE=1 S5X_LOCK="$EXD/private.lock" S5X_EX="$EXD" S5X_RUNNER="$HERE/fake-runner.sh" S5X_SCENARIO=$2 S5X_INNER_BOUND=5 S5X_INNER_KILL=2 S5X_NORMAL_BOUND=12 S5X_HEARTBEAT=2 S5_SETUP_GRANT=granted-by-parent
  setsid bash "$PKT/launch-s5-setup-exclusion.v1.sh" > "$EXD/launcher.out" 2>&1 < /dev/null & LPID=$!; }
wait_launcher() { local i=0; while kill -0 "$LPID" 2>/dev/null && [ $i -lt $(( $1 * 10 )) ]; do sleep 0.1; i=$((i+1)); done; ! kill -0 "$LPID" 2>/dev/null; }
rel() { grep -q "how=$2" "$EXD/LEASE_RELEASE" 2>/dev/null; }
finish() { [ -n "$LPID" ] && kill -0 "$LPID" 2>/dev/null && log "UNRESOLVED launcher pid=$LPID still holding (not killed: parent boundary)"; log "SUMMARY pass=$PASS fail=$FAIL"; }
trap finish EXIT
launch X1 normal; wait_launcher 30; wait "$LPID"; RC=$?
check X1.normal_release "$( [ "$RC" = 0 ] && rel X1 normal && grep -q 'raw=observed 0' "$EXD/LEASE_RELEASE" && lock_free "$EXD/private.lock" && grep -q 'state=RELEASED' "$EXD/LEASE_HOLDER" && [ -s "$EXD/attempts"/*/IDENTITY ]; echo $? )" "holder published before launch, IDENTITY before ADOPT, raw 0 observed, session verified empty, RELEASE published, lock free"
launch X2 descendant; wait_launcher 60; wait "$LPID"; RC=$?
check X2.descendant_escalated "$( [ "$RC" = 90 ] && rel X2 'session-live-after-runner-then-empty' && grep -q 'GROUP_REAPED\|KILL' "$EXD/logs/setup-exclusion/launcher.EXIT_RECORD" && lock_free "$EXD/private.lock" && ! pgrep -f "$EXD/DESC_READY" >/dev/null; echo $? )" "TERM-ignoring descendant escalated once inside the owned session, then verified empty and released (rc 90, raw 0 kept separate)"
launch X3 overrun; wait_launcher 40; wait "$LPID"; RC=$?
check X3.inner_timeout "$( rel X3 normal && grep -Eq 'raw=observed (124|137|143)' "$EXD/LEASE_RELEASE" && lock_free "$EXD/private.lock"; echo $? )" "overrunning runner ended by the inner timeout; raw status recorded; released after verified empty (rc=$RC)"
# X4: marker publication failure with unresolved ownership -> SELF-HOLD -> checked handoff
launch X4 descendant; sleep 1; mkdir -p "$EXD/LEASE_RELEASE" "$EXD/SELF_HOLD" "$EXD/logs/setup-exclusion/SELF_HOLD"   # after LEASE_HOLDER exists: RELEASE/SELF_HOLD records cannot be published (paths are directories)
i=0; until grep -q 'SELF_HOLD PUBLICATION FAILED' "$EXD/launcher.out" 2>/dev/null || [ $i -ge 600 ]; do sleep 0.1; i=$((i+1)); done
check X4.self_hold_observable "$( kill -0 "$LPID" 2>/dev/null && ! lock_free "$EXD/private.lock" && grep -q 'SELF_HOLD PUBLICATION FAILED' "$EXD/launcher.out" && grep -q 'state=SELF-HOLD' "$EXD/LEASE_HOLDER"; echo $? )" "with RELEASE/SELF_HOLD markers unpublishable the launcher retains the lock alive (holder record state=SELF-HOLD, busy lock, stderr), no forced exit"
TOK=$(sed -n 's/^token=\([^ ]*\) .*/\1/p' "$EXD/LEASE_HOLDER" | head -1); ST=$(sed -n 's/.* start_time=\([0-9]*\) .*/\1/p' "$EXD/LEASE_HOLDER" | head -1)
printf 'accept token=WRONG holder_pid=%s start_time=%s acceptor=ctl\n' "$LPID" "$ST" > "$EXD/RECOVERY_ACCEPT"; sleep 5
check X4.wrong_token_refused "$( kill -0 "$LPID" 2>/dev/null && ! lock_free "$EXD/private.lock"; echo $? )" "handoff with a wrong token is ignored; hold retained"
rmdir "$EXD/LEASE_RELEASE"; printf 'accept token=%s holder_pid=%s start_time=%s acceptor=ctl\n' "$TOK" "$LPID" "$ST" > "$EXD/RECOVERY_ACCEPT"; wait_launcher 15; wait "$LPID"; RC=$?
check X4.handoff_release "$( [ "$RC" = 90 ] && rel X4 handoff && grep -q 'recovery=handoff-accepted:ctl' "$EXD/LEASE_RELEASE" && grep -q 'publication=SELF_HOLD-failed' "$EXD/LEASE_RELEASE" && lock_free "$EXD/private.lock"; echo $? )" "checked handoff (exact token+pid+start time) releases with RELEASE record carrying the publication-failure truth; lock free"
pkill -KILL -f "$OUT/X4/DESC_READY" 2>/dev/null; LPID=""; log "ALL_CASES_DONE pass=$PASS fail=$FAIL"
