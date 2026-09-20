#!/usr/bin/env bash
# Bounded heavy-command wrapper for the S4 R3 lane.
# usage: run-heavy.sh <label> <timeout-seconds> <command...>
# - acquires execution/test-validation.lock NONBLOCKING (fails closed if busy)
# - stamps head/tree/dirty/toolchain/command/start/end/exit into logs/<label>.meta.json
# - tees stdout+stderr to logs/<label>.log; preserves the child exit code
set -u
LABEL="$1"; TMO="$2"; shift 2
ROOT=/home/user/workspace
WT=$ROOT/worktrees/s4-r3
OUT=$ROOT/execution/s4-r3/logs
LOCK=$ROOT/execution/test-validation.lock
exec 9>"$LOCK"
if ! flock -n 9; then
  echo "LOCK BUSY: $LOCK — refusing to run $LABEL" >&2
  exit 75
fi
cd "$WT" || exit 70
HEAD=$(git rev-parse HEAD); TREE=$(git rev-parse HEAD^{tree})
DIRTY=$(git status --porcelain | wc -l | tr -d ' ')
START=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "[$START] $LABEL head=$HEAD tree=$TREE dirty_paths=$DIRTY cmd: $*" | tee "$OUT/$LABEL.log"
timeout --kill-after=30 "$TMO" "$@" 2>&1 | tee -a "$OUT/$LABEL.log"
RC=${PIPESTATUS[0]}
END=$(date -u +%Y-%m-%dT%H:%M:%SZ)
python3 - "$OUT/$LABEL.meta.json" "$LABEL" "$HEAD" "$TREE" "$DIRTY" "$START" "$END" "$RC" "$*" <<'PY'
import json,sys,subprocess,hashlib,os
out,label,head,tree,dirty,start,end,rc,cmd=sys.argv[1:]
def sh(c): return subprocess.run(c,shell=True,capture_output=True,text=True).stdout.strip()
def h(p):
    try: return hashlib.sha256(open(p,'rb').read()).hexdigest()
    except Exception as e: return f"missing:{e}"
wt="/home/user/workspace/worktrees/s4-r3"
json.dump({"label":label,"head":head,"tree":tree,"dirty_paths":int(dirty),
 "status_porcelain":sh(f"cd {wt} && git status --porcelain"),
 "node":sh("node -v"),"npm":sh("npm -v"),"os":sh("uname -srm"),
 "package_json_sha256":h(f"{wt}/package.json"),"package_lock_sha256":h(f"{wt}/package-lock.json"),
 "command":cmd,"start_utc":start,"end_utc":end,"exit_code":int(rc),
 "timed_out":int(rc) in (124,137),"lock":"execution/test-validation.lock (flock -n, held for this command)"},
 open(out,"w"),indent=2)
PY
echo "[$END] $LABEL exit=$RC" | tee -a "$OUT/$LABEL.log"
exit "$RC"
