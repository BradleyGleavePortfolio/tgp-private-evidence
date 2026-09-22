#!/usr/bin/env bash
# S2-SETUP-FIXTURE-PREP copy (2026-09-22) of setup-and-runner-readiness/launch-detached.sh sha256 64302b3e77de039a8c74f601227cf431d655f8e1251d5489febb4fb72db0a36d.
# ONLY change: LANE repointed to execution/s2-setup-prep (runs/ under it). Original header follows.
# Durable launcher for the S2 lane's long steps (setup S10/S20/S30, runner). The sandbox tears down the tool-call
# process group when a call returns, so a plain `nohup … &` child dies. This starts the step in its OWN session
# (setsid, new process group, stdin from /dev/null), records the real PID, and writes an EXIT sentinel with the
# child's actual exit code when it finishes — so "log exists" is never mistaken for "running" or "passed".
#
#   launch-detached.sh start <name> <command...>   → runs/<name>.{pid,log,exit,cmd}; prints pid; returns immediately
#   launch-detached.sh status <name>               → RUNNING pid=… | EXITED code=… | DEAD-NO-SENTINEL (killed) ; exit 0/1/2
#   launch-detached.sh wait <name> [secs]          → polls until sentinel or timeout; prints status
# Nothing here changes the child's own locking: the step scripts still take the canonical flock -n themselves.
set -u
LANE=/home/user/workspace/execution/s2-setup-prep
RUNS=$LANE/runs; mkdir -p "$RUNS"
mode=${1-}; name=${2-}; [ -n "$mode" ] && [ -n "$name" ] || { echo "usage: $0 start|status|wait <name> [command...]"; exit 2; }
PID=$RUNS/$name.pid; LOGF=$RUNS/$name.log; EXITF=$RUNS/$name.exit; CMDF=$RUNS/$name.cmd
case $mode in
  start)
    shift 2; [ $# -gt 0 ] || { echo "no command"; exit 2; }
    if [ -f "$PID" ] && kill -0 "$(cat "$PID")" 2>/dev/null; then echo "REFUSED: $name already running pid=$(cat "$PID")"; exit 3; fi
    rm -f "$EXITF"; printf '%q ' "$@" > "$CMDF"; echo >> "$CMDF"
    # inner wrapper: run the command, then persist its real exit code atomically (tmp+mv) with an end timestamp
    setsid -f bash -c '
      echo "launch_utc=$(date -u +%FT%TZ) pid=$$ pgid=$(ps -o pgid= -p $$ | tr -d " ") sid=$(ps -o sid= -p $$ | tr -d " ") cmd: $*" 
      "$@"; rc=$?
      echo "end_utc=$(date -u +%FT%TZ) exit=$rc"
      printf "%s\n" "$rc" > "'"$EXITF"'.tmp" && mv -f "'"$EXITF"'.tmp" "'"$EXITF"'"
      exit $rc' _ "$@" </dev/null >"$LOGF" 2>&1 &
    sleep 0.3
    # setsid -f forks; find the session leader running our wrapper by matching the log's pid line
    p=$(sed -n 's/^launch_utc=.* pid=\([0-9]*\) .*/\1/p' "$LOGF" | head -1)
    [ -n "$p" ] || { sleep 1; p=$(sed -n 's/^launch_utc=.* pid=\([0-9]*\) .*/\1/p' "$LOGF" | head -1); }
    echo "$p" > "$PID"; echo "started $name pid=$p log=$LOGF exit_sentinel=$EXITF"; head -1 "$LOGF";;
  status|wait)
    deadline=$(( $(date +%s) + ${3:-0} ))
    while :; do
      if [ -f "$EXITF" ]; then echo "EXITED name=$name code=$(cat "$EXITF") log=$LOGF"; tail -2 "$LOGF" | sed 's/^/  /'; exit "$( [ "$(cat "$EXITF")" = 0 ] && echo 0 || echo 1 )"; fi
      p=$(cat "$PID" 2>/dev/null || true)
      if [ -n "$p" ] && kill -0 "$p" 2>/dev/null; then st="RUNNING name=$name pid=$p since=$(ps -o lstart= -p "$p" | sed 's/^ *//') log_lines=$(wc -l <"$LOGF")"
      else st="DEAD-NO-SENTINEL name=$name pid=${p:-?} (killed before writing exit; treat as FAILED/unknown) log=$LOGF"; fi
      [ "$mode" = wait ] && [ "$(date +%s)" -lt "$deadline" ] && { sleep 5; continue; }
      echo "$st"; case $st in RUNNING*) exit 0;; *) exit 2;; esac
    done;;
  *) echo "unknown mode $mode"; exit 2;;
esac
