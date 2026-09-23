#!/usr/bin/env bash
# S5 hooked-candidate CONTINUATION step runner = original prep steps/step.sh with ONLY: O -> s5-hooked-candidate-continuation, holder label slot-H -> slot-H2 (grant 2686f427). Original header follows:
#   O  -> execution/6c2a68ac/s5-hooked-candidate-result   (fresh result root; this prep dir is never written by execution)
#   W  -> worktrees/s5-r4
#   holders label 'S3-PREP2 slot-03C' -> 'S5-HOOKED slot-H' (continuation: slot-H2)
#   header: merge_head field dropped (S5 has no MERGE_HEAD); adds GIT_OPTIONAL_LOCKS and status_pin fields
#   GIT_OPTIONAL_LOCKS=0 exported (parent grant)
# NOT EXECUTED during preparation. Usage: step.sh NN label T offline(0|1) workdir cmdfile [postfile]
NN=$1; label=$2; T=$3; offline=$4; workdir=$5; cmdfile=$6; postfile=${7:-}
O=/home/user/workspace/execution/6c2a68ac/s5-hooked-candidate-continuation
P=/home/user/workspace/execution/6c2a68ac/s5-hooked-candidate-prep
W=/home/user/workspace/worktrees/s5-r4
TOOL=/home/user/workspace/execution/s3-composition-prep/tooling/prettier-3.9.6
LOCK=/home/user/workspace/execution/test-validation.lock
export GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1 NODE_OPTIONS=--max-old-space-size=4096 PRISMA_HIDE_UPDATE_MESSAGE=1 npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false CHECKPOINT_DISABLE=1
if [ "$offline" = 1 ]; then export npm_config_offline=true; else unset npm_config_offline; fi
export O P W TOOL
LOG="$O/logs/$NN-$label.log"; CMD=$(cat "$cmdfile")
cd "$workdir" || exit 70
exec 9>"$LOCK"; flock -n 9 || { echo "lock held; not waiting" | tee -a "$LOG"; echo "step_status=75" >> "$LOG"; exit 75; }
echo "S5-HOOKED slot-H2 $label pid=$$ start=$(date -u +%FT%TZ)" >> "$LOCK.holders"
{ echo "label=$label head=$(git -C $W rev-parse HEAD) write_tree=$(git -C $W write-tree) status_pin=$(git -C $W status --porcelain | tr '\n' ';') node=$(node -v) npm=$(npm -v) NODE_OPTIONS='${NODE_OPTIONS:-}' npm_config_offline='${npm_config_offline:-}' CHECKPOINT_DISABLE='${CHECKPOINT_DISABLE:-unset}' PRISMA_GENERATE_SKIP_AUTOINSTALL='${PRISMA_GENERATE_SKIP_AUTOINSTALL:-unset}' GIT_OPTIONAL_LOCKS='${GIT_OPTIONAL_LOCKS:-unset}' cwd=$PWD T=$T loadavg='$(cat /proc/loadavg)' mem_avail_mb=$(awk '/MemAvailable/{print int($2/1024)}' /proc/meminfo) utc=$(date -u +%FT%TZ)"; echo "cmd: $CMD"; } > "$LOG"
if [ "${CHECKPOINT_DISABLE:-unset}" != 1 ]; then echo "STOP: CHECKPOINT_DISABLE unset" >> "$LOG"; echo "step_status=78" >> "$LOG"; flock -u 9; exit 78; fi
timeout --kill-after=30 "$T" bash -c "$CMD" >> "$LOG" 2>&1; rc=$?
echo "exit=$rc (124=timeout,137=killed) utc=$(date -u +%FT%TZ) write_tree_after=$(git -C $W write-tree)" >> "$LOG"
final=$rc
if [ "$rc" -eq 0 ] && [ -n "$postfile" ]; then
  echo "== post-conditions (each line: postcheck rc)" >> "$LOG"
  bash "$postfile" >> "$LOG" 2>&1; prc=$?
  echo "postchecks_exit=$prc" >> "$LOG"; [ "$prc" -eq 0 ] || final=$prc
fi
echo "step_status=$final utc=$(date -u +%FT%TZ)" >> "$LOG"
echo "S5-HOOKED slot-H2 $label pid=$$ exit=$rc step_status=$final end=$(date -u +%FT%TZ)" >> "$LOCK.holders"
flock -u 9
exit "$final"
