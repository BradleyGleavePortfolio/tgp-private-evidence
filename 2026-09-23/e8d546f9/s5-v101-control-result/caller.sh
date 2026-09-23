#!/usr/bin/env bash
# S5-V101-CONTROL executor caller (2026-09-23). No errexit, no pipe on the driver, no retry. The granted block is reproduced verbatim
# between the START/END markers; START/END/rc lines and the rc file are the executor's capture of the actual status, nothing else.
R=/home/user/workspace/execution/e8d546f9/s5-v101-control-result
cd /home/user/workspace/execution/e8d546f9/s5-v101 || { echo "REFUSE: cd failed"; exit 9; }
sha256sum -c --quiet SHA256SUMS.s5-v101 || { echo "REFUSE: candidate manifest did not verify"; exit 9; }
[ "$(sha256sum SHA256SUMS.s5-v101 | cut -c1-64)" = 45accac93e91e7d46fe9a75c4460687fcb6d698336c57d61428b62f192cd5b89 ] || { echo "REFUSE: manifest hash mismatch"; exit 9; }
[ "$(id -u)" != 0 ] || { echo "REFUSE: EUID 0"; exit 9; }
[ -z "$(ls -A "$R/data")" ] || { echo "REFUSE: output dir not fresh"; exit 9; }
echo "START $(date -u +%FT%T.%NZ) caller_pid=$$ pgid=$(ps -o pgid= -p $$ | tr -d ' ') sid=$(ps -o sid= -p $$ | tr -d ' ') monitor=$([[ $- == *m* ]] && echo on || echo off) errexit=$([[ $- == *e* ]] && echo on || echo off) cwd=$PWD"
# ---- granted block, verbatim (S5_V101_CONTROL_GRANT.md) ----
S5_V10_OUT=/home/user/workspace/execution/e8d546f9/s5-v101-control-result/data S5_CTL_GRANT=granted-by-parent timeout --foreground -k 10 230 bash controls-v101-t0/ctl-own-launch.v101.sh
rc=$?
echo "ctl-own-launch.v101 rc=$rc"
# ---- end granted block (its `exit "$rc"` is the last line below) ----
echo "END $(date -u +%FT%T.%NZ) rc=$rc"
echo "$rc" > "$R/caller-rc.txt"
exit "$rc"
