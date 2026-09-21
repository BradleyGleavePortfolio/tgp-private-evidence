#!/usr/bin/env bash
# Bounded heavy-command wrapper for the S4 R4 lane (reimplementation).
# usage: run-slot.sh <label> <timeout-seconds> <command...>
# - acquires /home/user/workspace/execution/test-validation.lock NONBLOCKING
#   (exit 75, nothing run, if busy)
# - stamps head/tree/dirty/toolchain/lock/command/start/end/exit into
#   execution/s4-r4/logs/<label>.meta.json; tees output to logs/<label>.log
# - preserves the child exit code (no fake pass)
set -u
LABEL="$1"; TMO="$2"; shift 2
ROOT=/home/user/workspace
WT=${S4R4_WT:-$ROOT/worktrees/s4-r4}
OUT=$ROOT/execution/s4-r4/logs
LOCK=$ROOT/execution/test-validation.lock
mkdir -p "$OUT"
if [ "${S4R4_LOCK_HELD_BY_PARENT_SHELL:-0}" = "1" ]; then
  LOCKNOTE="held by enclosing slot-run shell (flock -n), not re-taken"
else
  exec 9>"$LOCK"
  if ! flock -n 9; then
    echo "LOCK BUSY: $LOCK — refusing to run $LABEL" >&2
    exit 75
  fi
  LOCKNOTE="flock -n on fd 9, held for this command only"
fi
cd "$WT" || exit 70
HEAD=$(git rev-parse HEAD); TREE=$(git rev-parse 'HEAD^{tree}')
DIRTY=$(git status --porcelain | wc -l | tr -d ' ')
DIFFSHA=$(git diff HEAD | sha256sum | cut -d' ' -f1)
START=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "[$START] $LABEL wt=$WT head=$HEAD tree=$TREE dirty_paths=$DIRTY diff_sha256=$DIFFSHA cmd: $*" | tee "$OUT/$LABEL.log"
timeout --kill-after=30 "$TMO" "$@" 2>&1 | tee -a "$OUT/$LABEL.log"
RC=${PIPESTATUS[0]}
END=$(date -u +%Y-%m-%dT%H:%M:%SZ)
python3 - "$OUT/$LABEL.meta.json" "$LABEL" "$WT" "$HEAD" "$TREE" "$DIRTY" "$DIFFSHA" "$START" "$END" "$RC" "$LOCKNOTE" "$*" <<'PY'
import json,sys,subprocess,hashlib
out,label,wt,head,tree,dirty,diffsha,start,end,rc,locknote,cmd=sys.argv[1:]
def sh(c): return subprocess.run(c,shell=True,capture_output=True,text=True).stdout.strip()
def h(p):
    try: return hashlib.sha256(open(p,'rb').read()).hexdigest()
    except Exception as e: return f"missing:{e}"
json.dump({"label":label,"worktree":wt,"head":head,"tree":tree,"dirty_paths":int(dirty),
 "working_diff_sha256":diffsha,
 "status_porcelain":sh(f"cd {wt} && git status --porcelain"),
 "node":sh("node -v"),"npm":sh("npm -v"),"os":sh("uname -srm"),
 "package_json_sha256":h(f"{wt}/package.json"),"package_lock_sha256":h(f"{wt}/package-lock.json"),
 "command":cmd,"start_utc":start,"end_utc":end,"exit_code":int(rc),
 "timed_out":int(rc) in (124,137),
 "lock":"/home/user/workspace/execution/test-validation.lock ("+locknote+")"},
 open(out,"w"),indent=2)
PY
echo "[$END] $LABEL exit=$RC" | tee -a "$OUT/$LABEL.log"
exit "$RC"
