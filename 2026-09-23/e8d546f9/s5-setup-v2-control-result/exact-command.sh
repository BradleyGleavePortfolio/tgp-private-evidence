cd /home/user/workspace/execution/e8d546f9/s5-setup-exclusion-v2 || exit 70
S5X_OUT=/home/user/workspace/execution/e8d546f9/s5-setup-v2-control-result/data S5_CTL_GRANT=granted-by-parent timeout --foreground -k 10 230 bash controls-exclusion/ctl-exclusion.v2.sh
rc=$?
printf 'ctl-exclusion.v2 rc=%s\n' "$rc"
exit "$rc"
