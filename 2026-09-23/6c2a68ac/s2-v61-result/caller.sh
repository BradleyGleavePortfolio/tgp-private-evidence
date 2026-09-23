#!/usr/bin/env bash
# S2-V61 five-set continuation caller (EXEC-6c2a68ac, 2026-09-23). No errexit; the grant's exact block is reproduced BYTE-VERBATIM between the markers.
# Executor additions: preflight refusals, START/END lines, done marker — capture only, no relabeling, no pipe on the driver, no enclosure.
R=/home/user/workspace/execution/6c2a68ac/s2-v61-result
cd /home/user/workspace/execution/e8d546f9/s2-v61 || { echo "REFUSE: cd"; exit 9; }
sha256sum -c --quiet SHA256SUMS.outer && echo LANE-OK || { echo "REFUSE: V61 manifest"; exit 9; }
[ "$(sha256sum SHA256SUMS.outer | cut -c1-64)" = ed2413420bd1ae917649cff6924683c8279f45fb31505e46ff10051d513d7b7a ] || { echo "REFUSE: V61 manifest hash"; exit 9; }
[ "$(sha256sum controls-proposed/run-controls-v61.sh | cut -c1-64)" = 42d9362b8234141bf5f68a997a5c113ced8154f068fdb87384674b7dd875ddc1 ] || { echo "REFUSE: driver hash"; exit 9; }
(cd /home/user/workspace/execution/op88/s2-v57 && sha256sum -c --quiet SHA256SUMS.outer && echo "op88-v57-OK") || { echo "REFUSE: op88 v57 manifest"; exit 9; }
(cd /home/user/workspace/execution/s2-setup-prep && sha256sum -c --quiet SHA256SUMS.outer && echo PRE-OK) || { echo "REFUSE: setup-prep manifest"; exit 9; }
[ "$(git -C /home/user/workspace/worktrees/s2-runner53 rev-parse HEAD)" = d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c ] && [ -z "$(GIT_OPTIONAL_LOCKS=0 git -C /home/user/workspace/worktrees/s2-runner53 status --porcelain)" ] && echo WT-OK || { echo "REFUSE: worktree"; exit 9; }
[ "$(id -u)" != 0 ] || { echo "REFUSE: EUID 0"; exit 9; }
echo "START $(date -u +%FT%T.%NZ) caller_pid=$$ pgid=$(ps -o pgid= -p $$ | tr -d ' ') sid=$(ps -o sid= -p $$ | tr -d ' ') monitor=$([[ $- == *m* ]] && echo on || echo off) errexit=$([[ $- == *e* ]] && echo on || echo off) cwd=$PWD"
# ---- S2_V61_CONTINUATION_GRANT exact block, BYTE-VERBATIM ----
export GIT_OPTIONAL_LOCKS=0   # B57-06 (parent-allowed): the runner's read-only git status calls must not refresh the worktree index cache; inherited through env
D=/home/user/workspace/execution/e8d546f9/s2-v61/controls-proposed/run-controls-v61.sh
declare -A B=([probe]=20 [wdtest]=20 [wdcancel]=20 [k]=120 [new1]=60 [new2]=60 [neg]=90 [neg2]=150)
for s in k new1 new2 neg neg2; do   # CONTINUATION: probe/wdtest/wdcancel evidence retained from the V59 run (0/0/3), not repeated
  CTL_SET=$s CTL_BUDGET=${B[$s]} bash "$D"; rc=$?; echo "$s=$rc"
  if [ "$rc" -eq 0 ] || { [ "$s" = wdcancel ] && [ "$rc" -eq 3 ]; }; then continue; fi
  echo "STOP at $s (aggregate $rc)"; break
done
# ---- end exact block ----
echo "END $(date -u +%FT%T.%NZ)"; echo done > "$R/caller-done.txt"
