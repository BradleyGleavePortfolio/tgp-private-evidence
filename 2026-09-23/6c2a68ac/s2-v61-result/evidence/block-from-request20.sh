export GIT_OPTIONAL_LOCKS=0   # B57-06 (parent-allowed): the runner's read-only git status calls must not refresh the worktree index cache; inherited through env
D=/home/user/workspace/execution/e8d546f9/s2-v61/controls-proposed/run-controls-v61.sh
declare -A B=([probe]=20 [wdtest]=20 [wdcancel]=20 [k]=60 [new1]=60 [new2]=60 [neg]=90 [neg2]=150)
for s in k new1 new2 neg neg2; do   # CONTINUATION: probe/wdtest/wdcancel evidence retained from the V59 run (0/0/3), not repeated
  CTL_SET=$s CTL_BUDGET=${B[$s]} bash "$D"; rc=$?; echo "$s=$rc"
  if [ "$rc" -eq 0 ] || { [ "$s" = wdcancel ] && [ "$rc" -eq 3 ]; }; then continue; fi
  echo "STOP at $s (aggregate $rc)"; break
done
