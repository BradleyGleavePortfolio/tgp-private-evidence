#!/usr/bin/env bash
# S2-V59-CONTROLS executor caller (2026-09-23). No errexit; the frozen CONTROL_REQUEST_16 loop is reproduced verbatim between the markers.
# Executor additions: preflight refusals, START/END/per-set timestamp lines, a set ledger file — capture only, no relabeling, no pipe on the driver.
R=/home/user/workspace/execution/e8d546f9/s2-v59-control-result
cd /home/user/workspace/execution/e8d546f9/s2-v59 || { echo "REFUSE: cd"; exit 9; }
sha256sum -c --quiet SHA256SUMS.outer && echo LANE-OK || { echo "REFUSE: V59 manifest"; exit 9; }
[ "$(sha256sum SHA256SUMS.outer | cut -c1-64)" = 4341ce30553bf950c32b40ef0f6466502bd2f189c99643733fa141dc5bd08bb5 ] || { echo "REFUSE: V59 manifest hash"; exit 9; }
(cd /home/user/workspace/execution/op88/s2-v57 && sha256sum -c --quiet SHA256SUMS.outer && echo "op88-v57-OK") || { echo "REFUSE: op88 v57 manifest"; exit 9; }
(cd /home/user/workspace/execution/s2-setup-prep && sha256sum -c --quiet SHA256SUMS.outer && echo PRE-OK) || { echo "REFUSE: setup-prep manifest"; exit 9; }
[ "$(id -u)" != 0 ] || { echo "REFUSE: EUID 0"; exit 9; }
echo "START $(date -u +%FT%T.%NZ) caller_pid=$$ pgid=$(ps -o pgid= -p $$ | tr -d ' ') sid=$(ps -o sid= -p $$ | tr -d ' ') monitor=$([[ $- == *m* ]] && echo on || echo off) errexit=$([[ $- == *e* ]] && echo on || echo off) cwd=$PWD"
# ---- frozen CONTROL_REQUEST_16 loop, BYTE-VERBATIM (per-set timing comes from the drivers' own result directories/logs) ----
export GIT_OPTIONAL_LOCKS=0   # B57-06 (parent-allowed): the runner's read-only git status calls must not refresh the worktree index cache; inherited through env
D=/home/user/workspace/execution/e8d546f9/s2-v59/controls-proposed/run-controls-v59.sh
declare -A B=([probe]=20 [wdtest]=20 [wdcancel]=20 [k]=60 [new1]=60 [new2]=60 [neg]=90 [neg2]=150)
for s in probe wdtest wdcancel k new1 new2 neg neg2; do
  CTL_SET=$s CTL_BUDGET=${B[$s]} bash "$D"; rc=$?; echo "$s=$rc"
  if [ "$rc" -eq 0 ] || { [ "$s" = wdcancel ] && [ "$rc" -eq 3 ]; }; then continue; fi
  echo "STOP at $s (aggregate $rc)"; break
done
# ---- end frozen loop ----
echo "END $(date -u +%FT%T.%NZ)"; echo done > "$R/caller-done.txt"
