# Copied verbatim from the S1 R3 evidence packet (infra/_common.sh) and retargeted to the S2 composition lane.
# shared by the setup steps: canonical nonblocking lock held only for the step,
# fail-closed logging, redaction. Source, do not execute.
set -euo pipefail
ROOT=/home/user/workspace
LOCK=$ROOT/execution/test-validation.lock
INFRA=$ROOT/execution/s2-composition/infra
LOGDIR=$INFRA/logs
PG17_HOME=/home/user/pg17
mkdir -p "$LOGDIR"
step_begin(){ # step_begin <name>  -> opens log, takes lock nonblocking
  STEP=$1; STEP_LOG=$LOGDIR/$STEP-$(date -u +%Y%m%dT%H%M%SZ).log
  exec 9>"$LOCK"
  if ! flock -n 9; then echo "[$STEP] validation lock busy ($LOCK); not waiting" | tee "$STEP_LOG"; exit 75; fi
  exec > >(tee -a "$STEP_LOG") 2>&1
  echo "== $STEP start_utc=$(date -u +%FT%TZ) pid=$$ lock=$LOCK(held nonblocking) cwd=$(pwd)"
}
step_end(){ echo "== $STEP end_utc=$(date -u +%FT%TZ) exit=0 log=$STEP_LOG"; }
trap 'rc=$?; [ $rc -ne 0 ] && echo "== ${STEP:-?} FAILED exit=$rc utc=$(date -u +%FT%TZ)" >&2; exit $rc' EXIT
sha(){ sha256sum "$1" | cut -c1-64; }
