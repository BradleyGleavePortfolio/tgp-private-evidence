#!/usr/bin/env bash
# Caller-only observer envelope (S5-SETUP-V1-01). Wraps the UNCHANGED frozen invocation; records the outer timeout
# status to outer.exit regardless of value. `set +e` explicitly so an expected nonzero cannot skip the receipt.
set +e; set -u
L=/home/user/workspace/execution/s5-r4/logs/setup-v1
echo "observer_pid=$$ start=$(date -u +%FT%TZ) flags='timeout -k 30 1290' script_sha256=$(sha256sum /home/user/workspace/execution/s5-r4/setup-v1/run-s5-setup-npm-ci.v1.sh | cut -c1-64)" > "$L/observer.status"
timeout -k 30 1290 bash /home/user/workspace/execution/s5-r4/setup-v1/run-s5-setup-npm-ci.v1.sh > "$L/run-setup.out" 2>&1 < /dev/null
rc=$?
echo "outer_exit=$rc end=$(date -u +%FT%TZ)" > "$L/outer.exit"
echo "observer_end=$(date -u +%FT%TZ) outer_exit=$rc" >> "$L/observer.status"
exit "$rc"
