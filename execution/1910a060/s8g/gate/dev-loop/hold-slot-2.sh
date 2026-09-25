#!/usr/bin/env bash
# Dev-loop slot holder v2: identical to hold-slot.sh but launched under `timeout` so it survives the tool shell's
# process-group teardown (the v1 holder died 6 s after HELD — see DEV-LOOP.md disclosure).
set -u; LOCK=/home/user/workspace/execution/test-validation.lock; D=$(dirname "$0"); HOLD_MAX=${HOLD_MAX:-1200}
[ "$(stat -c %i "$LOCK")" = 667698 ] || { echo "REFUSED inode"; exit 75; }
exec 9>>"$LOCK"; w=0
until flock -n 9; do [ $((w % 60)) -ne 0 ] || echo "$(date -u +%FT%TZ) WAITING ${w}s"; sleep 5; w=$((w+5)); [ $w -lt 5400 ] || exit 75; done
echo "$(date -u +%FT%TZ) HELD pid=$$ waited=${w}s inode=$(stat -c %i "$LOCK")" | tee "$D/HELD-2"
trap 'echo "$(date -u +%FT%TZ) RELEASED pid=$$" | tee "$D/RELEASED-2"; exit 0' TERM INT
end=$(( $(date +%s) + HOLD_MAX )); while [ $(date +%s) -lt $end ]; do sleep 2; done
echo "$(date -u +%FT%TZ) RELEASED_TIMEOUT pid=$$" | tee "$D/RELEASED-2"
