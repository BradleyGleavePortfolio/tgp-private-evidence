#!/usr/bin/env bash
# Detached caller (transport/wait only; S5_CANONICAL_SETUP_ACTIVATION.md pattern). Unsets every private override, then runs the frozen launcher as its own session leader
# via `setsid -w` and records the launcher's direct return. No timeout, supervisor, observer, retry or signal.
RES=/home/user/workspace/execution/6c2a68ac/s5-canonical-setup-result
L=/home/user/workspace/execution/6c2a68ac/s5-v32-builder/s5-setup-exclusion-v32/launch-s5-setup-exclusion.v32.sh
for v in $(env | sed -n 's/^\(S5X_[A-Za-z0-9_]*\)=.*/\1/p'); do unset "$v"; done; unset S5_LEASE_INHERITED
echo "caller_pid=$$ caller_sid=$(ps -o sid= -p $$ | tr -d ' ') launched_at=$(date -u +%FT%TZ) s5_env_after_unset=[$(env | grep -E '^(S5X_|S5_LEASE)' | tr '\n' ' ')]" > "$RES/caller.receipt"
setsid -w env CHECKPOINT_DISABLE=1 S5_SETUP_GRANT=granted-by-parent bash "$L" > "$RES/launcher.stdout" 2> "$RES/launcher.stderr" < /dev/null
rc=$?
echo "launcher_raw_wait_status=$rc waited_at=$(date -u +%FT%TZ) (direct return of setsid -w env ... bash launcher; NOT the runner's rc)" >> "$RES/caller.receipt"
echo "$rc" > "$RES/launcher.raw_wait_status"
