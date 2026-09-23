bash -c 'cd /home/user/workspace/execution/s4-r6-validation/v6 || exit 70; if bash controls/run-controls-v6.sh; then rc=0; else rc=$?; fi; printf "driver exit=%s\n" "$rc"; exit "$rc"'
