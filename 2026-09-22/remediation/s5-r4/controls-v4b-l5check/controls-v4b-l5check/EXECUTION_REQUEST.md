# L5 checker v4b — separate pure-read execution request (NOT executed; Wave 2 NOT relabelled)
Fix vs v4: `say()` returns 0 explicitly (v4's `[ "$1" = FAIL ] && fail=1` made PASS return 1, so `test && say PASS || say FAIL` chains marked FAIL). Driver `l5-run.sh`: per-file expected rc (00-/P2- → 0, N1–N5 → 1), raw rc + predicates captured to `<out>/<file>.out`, stop on first mismatch (exit 1), explicit aggregate bound 10 s + 2 s kill grace (exit 124).
Command (once): `cd /home/user/workspace/execution/s5-r4 && mkdir -p control-results/wave-l5check && timeout --foreground -k 2 12 bash controls-v4b-l5check/l5-run.sh control-results/wave-l5check > control-results/wave-l5check/l5-run.stdout 2>&1; echo RC=$?`
Pass: `L5_CHECKER_CONTROL_OK files=7`, rc 0. Any other outcome is reported raw.
