#!/usr/bin/env bash
# Private fake runner v2 for the exclusion controls (no npm, no canonical paths). Verifies the inherited lease like v10x/v101x, then acts per S5X_SCENARIO.
# v2 (SEB-B-06 / S5X-A-01 control gap): descendant publishes its pid (typed state checks replace pattern matching); new subsession-90 models the canonical
# shape — a child in its OWN setsid session (fd 9 closed) that outlives the runner, the runner's own IDENTITY/EXIT_RECORD truth, and runner exit 90; new
# normal-slow gives the driver an acknowledged window (state=RUNNING) to install a publication obstacle before normal completion (S5X-A-03 / SEB-B-03).
set -u; [ "$(readlink /proc/$$/fd/9 2>/dev/null)" = "${S5X_LOCK:?}" ] || exit 75; [ -n "${S5_LEASE_INHERITED:-}" ] || exit 75
case "${S5X_SCENARIO:?}" in
  normal)      exit 0 ;;
  normal-slow) sleep "${S5X_SLOW:-4}"; exit 0 ;;
  descendant)  ( trap "" TERM; echo "$BASHPID" > "$S5X_EX/DESC_READY.tmp" && mv -f "$S5X_EX/DESC_READY.tmp" "$S5X_EX/DESC_READY"; exec sleep 60 ) 9>&- & until [ -s "$S5X_EX/DESC_READY" ]; do sleep 0.05; done; exit 0 ;;   # TERM-ignoring same-session descendant; pid published
  overrun)     exec sleep 60 ;;                                                                                                                # inner timeout must end it
  subsession-90) # canonical shape: inner session created by the runner (like OWN-BLOCK setsid npm), fd 9 closed, outlives the runner; runner publishes IDENTITY + EXIT_RECORD truth, exits 90
    IL=$S5X_EX/logs/setup-v1; A=$IL/attempts/attempt-fake; mkdir -p "$A" || exit 74; R=$IL/setup.EXIT_RECORD; MYSID=$(ps -o sid= -p $$ | tr -d ' ')
    ( exec setsid sleep "${S5X_SUB_SLEEP:-10}" ) 9>&- < /dev/null > /dev/null 2>&1 & SP=$!
    i=0; until [ "$(ps -o sid= -p "$SP" 2>/dev/null | tr -d ' ')" = "$SP" ]; do i=$((i+1)); [ $i -ge 100 ] && exit 70; sleep 0.05; done   # wait until the child is its own session leader
    printf '%s\n' "pid=$SP attempt=attempt-fake pgid_sid=[$SP $SP] self_pgid=$(ps -o pgid= -p $$ | tr -d ' ') self_sid=$MYSID decoy=none budget=fake grace=fake" > "$A/IDENTITY.tmp" && mv -f "$A/IDENTITY.tmp" "$A/IDENTITY" || exit 74
    { echo "START pid=$$ fake"; echo "npm-ci IDENTITY attempt=attempt-fake identity_rc=0 adoption=published state=released"; echo "EXCLUSION_UNPRESERVED after 0s: fake owned work unresolved and no marker written"; echo "CLEANUP_FAILURES=1"; echo "FINAL rc=90 (fake)"; } > "$R" || exit 74
    echo "$SP" > "$S5X_EX/SUB_READY.tmp" && mv -f "$S5X_EX/SUB_READY.tmp" "$S5X_EX/SUB_READY" || exit 74; exit 90 ;;
  *) exit 64 ;;
esac
