#!/usr/bin/env bash
# S5 T0 detached caller (accepted transport). Job control and errexit off; literal grant command; raw status captured directly.
set +e +m
RES=/home/user/workspace/execution/6c2a68ac/s5-t0-result
unset S5X_OUT S5X_ROOT S5_LEASE_INHERITED
echo "CALLER_START $(date -u +%FT%TZ) pid=$$ sid=$(ps -o sid= -p $$ | tr -d ' ') pgid=$(ps -o pgid= -p $$ | tr -d ' ') monitor=$([[ -o monitor ]] && echo on || echo off)" > "$RES/caller.receipt"
S5_CTL_OUT=/home/user/workspace/execution/6c2a68ac/s5-t0-result/data \
S5_CTL_KEEP=1 S5_CTL_GRANT=granted-by-parent \
timeout --foreground -k 20 140 bash \
  /home/user/workspace/execution/6c2a68ac/s5-t0-input/controls-v101-t0/ctl-t0-only.v101.sh > "$RES/driver.stdout" 2> "$RES/driver.stderr"
rc=$?
printf 't0_driver_raw=%s\n' "$rc" > "$RES/driver.raw_status"
echo "CALLER_END $(date -u +%FT%TZ) t0_driver_raw=$rc" >> "$RES/caller.receipt"
exit "$rc"
