#!/usr/bin/env bash
# Bounded dev-loop slot holder (parent disposition 15:09 PT): polls flock -n on the canonical lock (never steals),
# then holds it for at most HOLD_MAX seconds (default 1200 = 20 min) while the builder runs ONLY the four targeted
# jest suites in the clone. Releases at exit (kill -TERM or timeout). Lock file never deleted.
set -u
LOCK=/home/user/workspace/execution/test-validation.lock; D=$(dirname "$0"); HOLD_MAX=${HOLD_MAX:-1200}
[ "$(stat -c %i "$LOCK")" = 667698 ] || { echo "REFUSED inode"; exit 75; }
exec 9>>"$LOCK"; w=0
until flock -n 9; do [ $((w % 60)) -ne 0 ] || echo "$(date -u +%FT%TZ) WAITING ${w}s holder=$(lslocks 2>/dev/null | grep test-validation | awk '{print $2}' | tr '\n' ' ')"; sleep 5; w=$((w+5)); [ $w -lt 5400 ] || { echo REFUSED_TIMEOUT; exit 75; }; done
echo "$(date -u +%FT%TZ) HELD pid=$$ waited=${w}s inode=$(stat -c %i "$LOCK")" | tee "$D/HELD"
trap 'echo "$(date -u +%FT%TZ) RELEASED pid=$$" | tee "$D/RELEASED"; exit 0' TERM INT
end=$(( $(date +%s) + HOLD_MAX )); while [ $(date +%s) -lt $end ]; do sleep 2; done
echo "$(date -u +%FT%TZ) RELEASED_TIMEOUT pid=$$" | tee "$D/RELEASED"
