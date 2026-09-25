#!/usr/bin/env bash
# v3 proof supervisor (S7L_V3_SINGLE_PG_PROOF_GRANT): runs the one authorized invocation once; records identity; never relaunches.
R=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v3/run
CMD='timeout -k 30 3900 bash /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v3/s7l-pg-proof.sh'
echo "SUPERVISOR_START $(date -u +%FT%TZ) supervisor_pid=$$ pgid=$(ps -o pgid= -p $$ | tr -d ' ') cmd='$CMD' stdin=/dev/null stdout+stderr=$R/launcher.stdout" >> $R/LAUNCHER.txt
timeout -k 30 3900 bash /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v3/s7l-pg-proof.sh < /dev/null > $R/launcher.stdout 2>&1 &
DP=$!; echo "TIMEOUT_WRAPPER_PID=$DP $(date -u +%FT%TZ)" >> $R/LAUNCHER.txt
wait $DP; RC=$?
echo "LAUNCHER_EXIT rc=$RC $(date -u +%FT%TZ)" >> $R/LAUNCHER.txt
